--[[
	Economy simulation: a greedy "average active player" plays the game using the real
	Config + Formulas + DumbbellStats modules, and we print when they reach each milestone.

	lune run build/tools/sim.luau [minutes] [v]        -- one run (v = verbose)
	lune run build/tools/sim.luau calibrate            -- suggest zone costs / rebirth curve

	The simulated player is efficient, so real players take roughly 1.3-1.6x longer.
]]

local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Sandbox = require("../lib/Sandbox")
local Source = require("../lib/Source")

local game = roblox.Instance.new("DataModel")
Source.Load(game, "./src")
local sb = Sandbox.new(game)
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = Shared.Config
local Materials = sb.require(Config.Materials)
local Zones = sb.require(Config.Zones)
local Upgrades = sb.require(Config.Upgrades)
local Rebirths = sb.require(Config.Rebirths)
local Balance = sb.require(Config.Balance)
local Formulas = sb.require(Shared.Formulas)
local DumbbellStats = sb.require(Shared.DumbbellStats)
local PlayerStats = sb.require(Shared.PlayerStats)
local Format = sb.require(Shared.Util.Format)

local LIFT_EFF = 0.8 -- humans don't click at the exact max rate
local WALK_PER_NODE = 1.8 -- seconds walking between nodes
local TRIP_HOME = 14 -- teleport home, deposit, launch back
local CRAFT_OVERHEAD = 7
local QUALITY_EV = 1.3
local UPGRADE_PRIORITY = { "ForgeLevel", "LiftSpeed", "CoinBoost", "Backpack", "Hammer", "CritChance", "CritPower", "ComboMastery", "SmashSpeed", "Yield", "WalkSpeed" }

local function run(T_MAX: number, verbose: boolean)
	local data = {
		Strength = 0, Coins = 0, Rebirths = 0, Upgrades = {}, Perks = {}, Zones = { StarterYard = true },
		Boosts = {}, BonusLuck = 0,
	}
	local inventory: { [string]: number } = {}
	local dumbbells = {}
	local tokens = 0
	local t = 0
	local log = {}
	local events = {}

	local function note(text: string)
		table.insert(log, string.format("%8s  %-58s S=%-8s C=%-8s", Format.Time(t), text, Format.Short(data.Strength), Format.Short(data.Coins)))
	end

	local function stats()
		return PlayerStats.Compute(data, { Now = 0 })
	end

	local function highestTier(): number
		local best = 1
		for id in data.Zones do
			best = math.max(best, Zones.ById[id].Tier)
		end
		return best
	end

	local function record(plate: string, handle: string, size: number)
		return {
			Parts = { { Material = plate }, { Material = handle }, { Material = plate } },
			Size = size, Quality = "Normal", Level = 1,
		}
	end

	local function bestHandle(exclude: string?, extra: number?): string?
		local best, bestPower = nil, -1
		for id, n in inventory do
			local need = (id == exclude) and ((extra or 0) + 1) or 1
			if n >= need then
				local m = Materials.ById[id]
				local st = DumbbellStats.Compute(record(exclude or id, id, 1))
				if m.Power > bestPower and st.RequiredStrength <= data.Strength then
					best, bestPower = id, m.Power
				end
			end
		end
		return best
	end

	local function sessionMult(lf, reps: number): number
		local crit = 1 + lf.CritChance * (lf.CritMult - 1) + lf.SuperChance * (lf.SuperMult - 1)
		local comboSum = 0
		for i = 1, reps do
			comboSum += Formulas.ComboBonus(i, lf.ComboMastery)
		end
		return crit * (1 + comboSum / math.max(reps, 1))
	end

	local function nodeTime(materialId: string, zoneId: string): number
		local st = stats()
		local power = Formulas.SmashPower(data.Strength, st.Hammer)
		local hits = Formulas.HitsToBreak(power, Formulas.NodeToughness(zoneId, materialId))
		if hits == math.huge then
			return math.huge
		end
		return hits * st.SmashCooldown + WALK_PER_NODE
	end

	local function chooseTarget()
		local st = stats()
		local best = nil
		for zoneId in data.Zones do
			local zoneMats = Materials.ByZone[zoneId]
			local total = 0
			for _, m in zoneMats do
				total += m.Spawn
			end
			for _, m in zoneMats do
				local share = m.Spawn / total
				local size = 0
				for s = math.floor(st.MaxPlateSize), 1, -1 do
					if DumbbellStats.Compute(record(m.Id, m.Id, s)).RequiredStrength <= data.Strength then
						size = s
						break
					end
				end
				if size > 0 then
					local need = math.max(0, size * 2 + 1 - (inventory[m.Id] or 0))
					local perDrop = nodeTime(m.Id, zoneId)
					local yield = 1 + st.Yield
					local timeNeeded = need / share / yield * perDrop
					timeNeeded += math.ceil(need / share / yield / st.Backpack) * TRIP_HOME
					local power = DumbbellStats.Compute(record(m.Id, m.Id, size)).Power
					local score = power / (1 + timeNeeded / 150)
					if not best or score > best.score then
						best = { material = m.Id, zone = zoneId, size = size, need = need, time = timeNeeded, share = share, score = score, power = power }
					end
				end
			end
		end
		return best
	end

	local function gather(target)
		local st = stats()
		local zoneMats = Materials.ByZone[target.zone]
		local total = 0
		for _, m in zoneMats do
			total += m.Spawn
		end
		local drops = math.min(st.Backpack, math.ceil(target.need / target.share / (1 + st.Yield)))
		local time = 0
		for _, m in zoneMats do
			inventory[m.Id] = (inventory[m.Id] or 0) + drops * m.Spawn / total * (1 + st.Yield)
			time += drops * m.Spawn / total * nodeTime(m.Id, target.zone)
		end
		t += time + TRIP_HOME
	end

	local function bestLiftable()
		local best = nil
		for _, d in dumbbells do
			if d.stats.RequiredStrength <= data.Strength and (not best or d.stats.Power > best.stats.Power) then
				best = d
			end
		end
		return best
	end

	local function bestCraftable()
		local st = stats()
		local best = nil
		for id, n in inventory do
			local maxSize = math.min(math.floor(st.MaxPlateSize), math.floor(n / 2))
			for size = maxSize, 1, -1 do
				local handle = bestHandle(id, size * 2) or id
				if handle == id and n < size * 2 + 1 then
					continue
				end
				local s = DumbbellStats.Compute(record(id, handle, size))
				if s.RequiredStrength <= data.Strength then
					if not best or s.Power > best.power then
						best = { material = id, handle = handle, size = size, power = s.Power }
					end
					break
				end
			end
		end
		return best
	end

	local function craftBest()
		local c = bestCraftable()
		local current = bestLiftable()
		if c and (not current or c.power * QUALITY_EV > current.stats.Power * 1.05) then
			inventory[c.material] -= c.size * 2
			inventory[c.handle] = (inventory[c.handle] or 0) - 1
			local s = DumbbellStats.Compute(record(c.material, c.handle, c.size))
			s.Power *= QUALITY_EV
			table.insert(dumbbells, { stats = s })
			t += CRAFT_OVERHEAD
		end
	end

	local function lift(seconds: number)
		local st = stats()
		local db = bestLiftable()
		local lf = PlayerStats.ForLift(st, db and db.stats)
		local reps = math.floor(seconds / lf.Cooldown * LIFT_EFF)
		local per = lf.Power * lf.Gains * sessionMult(lf, reps)
		data.Strength += per * reps
		data.Coins += per * reps * Balance.CoinsPerStrength * (lf.Coins / lf.Gains)
		t += seconds
	end

	local function shop()
		local bought = true
		while bought do
			bought = false
			local nextZone = Zones.ByTier[highestTier() + 1]
			if nextZone and data.Rebirths >= nextZone.RebirthReq and data.Coins >= nextZone.Cost then
				data.Coins -= nextZone.Cost
				data.Zones[nextZone.Id] = true
				local st0 = stats()
				local power0 = Formulas.SmashPower(data.Strength, st0.Hammer)
				local common = Materials.ByZone[nextZone.Id][1]
				note(string.format("UNLOCK %s  power=%s hits(common)=%s hammer=x%s", nextZone.Name, Format.Short(power0),
					tostring(Formulas.HitsToBreak(power0, Formulas.NodeToughness(nextZone.Id, common.Id))), tostring(st0.Hammer)))
				table.insert(events, { kind = "zone", id = nextZone.Id, rebirths = data.Rebirths, t = t })
				bought = true
				continue
			end
			local saving = nextZone and data.Rebirths >= nextZone.RebirthReq and nextZone.Cost <= data.Coins * 3
			local cheapest, cheapestCost = nil, math.huge
			for _, id in UPGRADE_PRIORITY do
				local u = Upgrades.ById[id]
				local level = data.Upgrades[id] or 0
				if level < Upgrades.MaxLevel(u) then
					local cost = Formulas.UpgradeCost(u, level)
					if cost < cheapestCost then
						cheapest, cheapestCost = id, cost
					end
				end
			end
			local budget = saving and data.Coins * 0.15 or data.Coins
			if cheapest and cheapestCost <= budget then
				data.Coins -= cheapestCost
				data.Upgrades[cheapest] = (data.Upgrades[cheapest] or 0) + 1
				if cheapest == "ForgeLevel" and verbose then
					note(string.format("Forge Level -> max plate %d", stats().MaxPlateSize))
				end
				bought = true
			end
		end
	end

	local function tryRebirth()
		local req = Formulas.RebirthRequirement(data.Rebirths)
		if data.Strength < req then
			return
		end
		tokens += Formulas.RebirthTokens(data.Rebirths)
		data.Rebirths += 1
		data.Strength = 0
		data.Coins = 0
		data.Zones = { StarterYard = true }
		data.Upgrades = {}
		local spent = true
		while spent do
			spent = false
			for _, id in { "MuscleMemory", "BigForge", "LuckyGenes", "HeadStart" } do
				local p = Rebirths.PerkById[id]
				local lvl = data.Perks[id] or 0
				local cost = Rebirths.PerkCost(p, lvl)
				if lvl < p.Max and tokens >= cost then
					tokens -= cost
					data.Perks[id] = lvl + 1
					spent = true
				end
			end
		end
		for i = 1, data.Perks.HeadStart or 0 do
			data.Zones[Zones.ByTier[i + 1].Id] = true
		end
		note(string.format("REBIRTH -> %d (%s)", data.Rebirths, Rebirths.RankName(data.Rebirths)))
		table.insert(events, { kind = "rebirth", n = data.Rebirths, t = t })
	end

	local checkpoints = { 60, 120, 180, 300, 420, 600, 900, 1200, 1800, 2700, 3600, 5400, 7200, 10800, 14400, 21600, 28800, 36000 }
	local cpIndex = 1
	local lastDb = nil
	while t < T_MAX do
		shop()
		tryRebirth()
		craftBest()
		local db = bestLiftable()
		if db ~= lastDb and db and verbose then
			note(string.format("equip %s size %d (%s/rep, needs %s)", db.stats.Name, db.stats.Size, Format.Short(db.stats.Power), Format.Short(db.stats.RequiredStrength)))
		end
		lastDb = db
		local target = chooseTarget()
		local current = bestLiftable()
		if target and target.need > 0 and (not current or target.power > current.stats.Power * 1.15) and target.time < 600 then
			gather(target)
			craftBest()
		end
		lift(25)
		while cpIndex <= #checkpoints and t >= checkpoints[cpIndex] do
			note(string.format("-- %s", Format.Time(checkpoints[cpIndex])))
			cpIndex += 1
		end
	end
	return log, events
end

if process.args[1] == "calibrate" then
	-- Targets in simulated minutes. Zones that need a rebirth are timed from that rebirth.
	local ZONE_TARGET = { Scrapyard = 3.5, Mine = 8, Factory = 14.5, Volcano = 23, FrozenCave = 33 }
	local AFTER_REBIRTH = { CrystalCavern = 18, Nuclear = 20, MeteorCrater = 22, Space = 25, Void = 28 }
	local REBIRTH_GAP = { 45, 38, 45, 55, 65, 75, 85, 95, 105, 115 }
	local iterations = tonumber(process.args[2]) or 12
	for iteration = 1, iterations do
		local _, events = run((tonumber(process.args[3]) or 420) * 60, false)
		local firstZone, rebirthAt = {}, {}
		for _, e in events do
			if e.kind == "zone" and not firstZone[e.id] then
				firstZone[e.id] = e.t / 60
			elseif e.kind == "rebirth" then
				rebirthAt[e.n] = e.t / 60
			end
		end
		local report = {}
		for _, z in Zones.List do
			local actual = firstZone[z.Id]
			local target = ZONE_TARGET[z.Id]
			if AFTER_REBIRTH[z.Id] and rebirthAt[z.RebirthReq] then
				target = rebirthAt[z.RebirthReq] + AFTER_REBIRTH[z.Id]
				if actual then
					actual -= 0 -- measured from game start like the target
				end
			end
			if target and actual then
				local factor = math.clamp((target / actual) ^ 1.0, 0.3, 3)
				z.Cost = Formulas.Nice(z.Cost * factor)
				table.insert(report, string.format("%s %.0f/%.0f", string.sub(z.Id, 1, 6), actual, target))
			end
		end
		local list = Rebirths.RequirementList
		local previous = 0
		for n = 1, #list do
			local at = rebirthAt[n]
			local target = previous + REBIRTH_GAP[n]
			if at then
				local gapActual = at - previous
				list[n] = Formulas.Nice(list[n] * math.clamp((REBIRTH_GAP[n] / gapActual) ^ 1.5, 0.2, 5))
				table.insert(report, string.format("R%d %.0f/%.0f", n, at, target))
				previous = at
			else
				break
			end
		end
		print(iteration, table.concat(report, " "))
	end
	print("\nSuggested zone costs:")
	for _, z in Zones.List do
		print(string.format("  %-14s %s  (%s)", z.Id, tostring(z.Cost), Format.Short(z.Cost)))
	end
	local parts = {}
	for _, v in Rebirths.RequirementList do
		table.insert(parts, string.format("%.3g", v))
	end
	print("RequirementList = { " .. table.concat(parts, ", ") .. " }")
else
	local minutes = tonumber(process.args[1]) or 240
	local log = run(minutes * 60, process.args[2] == "v")
	for _, line in log do
		print(line)
	end
end
