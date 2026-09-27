--[[
	Formulas - all the math of the game in one place (shared by server and client).

	The server uses these to decide rewards; the client uses the same functions to show
	costs, odds and previews, so what you see is exactly what you get.

	`rng` arguments are Random objects (anything with :NextNumber()).
]]

local Config = script.Parent.Config
local Balance = require(Config.Balance)
local Qualities = require(Config.Qualities)
local Mutations = require(Config.Mutations)
local Materials = require(Config.Materials)
local Rarities = require(Config.Rarities)
local Rebirths = require(Config.Rebirths)
local Zones = require(Config.Zones)

local Formulas = {}

-- Round to 2 significant digits so prices look clean (1234 -> 1200, 56789 -> 57000)
function Formulas.Nice(n: number): number
	if n < 100 then
		return math.floor(n + 0.5)
	end
	local magnitude = 10 ^ (math.floor(math.log10(n)) - 1)
	return math.floor(n / magnitude + 0.5) * magnitude
end

-- Upgrades -------------------------------------------------------------------------------

function Formulas.UpgradeCost(upgrade: any, level: number): number
	return Formulas.Nice(upgrade.Cost.Base * upgrade.Cost.Growth ^ level)
end

function Formulas.UpgradeValue(upgrade: any, level: number): number
	local values = upgrade.Values
	return values[math.clamp(level, 0, #values - 1) + 1]
end

-- Rebirth ----------------------------------------------------------------------------------

function Formulas.RebirthRequirement(rebirths: number): number
	local list = Rebirths.RequirementList
	if rebirths < #list then
		return list[rebirths + 1]
	end
	return Formulas.Nice(list[#list] * Rebirths.RequirementGrowth ^ (rebirths - #list + 1))
end

function Formulas.RebirthMult(rebirths: number): number
	return 1 + rebirths * Rebirths.GainsPerRebirth
end

function Formulas.RebirthTokens(rebirths: number): number
	-- tokens earned when going from `rebirths` to `rebirths + 1`
	return Rebirths.TokensBase + Rebirths.TokensPerRebirth * rebirths
end

-- Dumbbell leveling ---------------------------------------------------------------------------

function Formulas.XpToNext(level: number): number
	return math.floor(Balance.DumbbellXpBase * level ^ Balance.DumbbellXpExp + 0.5)
end

-- Training -----------------------------------------------------------------------------------

function Formulas.ComboBonus(combo: number, mastery: number?): number
	local bonus = 0
	for _, tier in Balance.ComboTiers do
		if combo >= tier.At then
			bonus = tier.Bonus
		end
	end
	return bonus * (1 + (mastery or 0))
end

function Formulas.NextComboTier(combo: number): number?
	for _, tier in Balance.ComboTiers do
		if combo < tier.At then
			return tier.At
		end
	end
	return nil
end

function Formulas.RequiredStrength(weight: number): number
	return math.max(0, (weight - Balance.FreeLiftWeight) * Balance.StrengthPerKg)
end

-- Smashing -----------------------------------------------------------------------------------

local RARITY_TOUGHNESS = { 1, 1.35, 1.8, 2.4, 3.2, 4.2, 6 }

function Formulas.SmashPower(strength: number, hammerMult: number): number
	return (10 + strength) * hammerMult
end

function Formulas.NodeToughness(zoneId: string, materialId: string, mutated: boolean?): number
	local zone = Zones.ById[zoneId]
	local material = Materials.ById[materialId]
	local base = zone and zone.Toughness or 10
	local rank = material and Rarities.Rank(material.Rarity) or 1
	local t = base * RARITY_TOUGHNESS[rank]
	if mutated then
		t *= Balance.MutatedNodeHealthMult
	end
	return t
end

-- Damage (out of Balance.NodeHealth) one hit does. 0 means "too tough".
function Formulas.SmashDamage(power: number, toughness: number): number
	local ratio = power / math.max(toughness, 1e-9)
	if ratio < Balance.SmashMinRatio then
		return 0
	end
	return Balance.SmashDamage * math.min(ratio, Balance.SmashMaxRatio)
end

function Formulas.HitsToBreak(power: number, toughness: number): number
	local dmg = Formulas.SmashDamage(power, toughness)
	if dmg <= 0 then
		return math.huge
	end
	return math.ceil(Balance.NodeHealth / dmg - 1e-9)
end

-- Strength needed to smash a node at all
function Formulas.MinSmashStrength(toughness: number, hammerMult: number): number
	return math.max(0, toughness * Balance.SmashMinRatio / hammerMult - 10)
end

-- Weighted rolls -------------------------------------------------------------------------------

local function weightedPick(rng: any, entries: { { any } }): any
	local total = 0
	for _, e in entries do
		total += e[2]
	end
	if total <= 0 then
		return nil
	end
	local roll = rng:NextNumber() * total
	for _, e in entries do
		roll -= e[2]
		if roll <= 0 then
			return e[1]
		end
	end
	return entries[#entries][1]
end
Formulas.WeightedPick = weightedPick

function Formulas.QualityWeights(luck: number, rebirths: number): { { any } }
	local entries = {}
	for _, q in Qualities.List do
		if rebirths >= q.RebirthReq then
			table.insert(entries, { q.Id, q.Weight * math.max(luck, 1) ^ q.LuckPower })
		end
	end
	return entries
end

function Formulas.QualityOdds(luck: number, rebirths: number): { [string]: number }
	local entries = Formulas.QualityWeights(luck, rebirths)
	local total = 0
	for _, e in entries do
		total += e[2]
	end
	local odds = {}
	for _, e in entries do
		odds[e[1]] = e[2] / total
	end
	return odds
end

function Formulas.RollQuality(rng: any, luck: number, rebirths: number): string
	return weightedPick(rng, Formulas.QualityWeights(luck, rebirths)) or "Normal"
end

-- Mutation roll. bias = zone/event multipliers, extra = extra weights for event mutations.
function Formulas.RollMutation(rng: any, luck: number, bias: { [string]: number }?, extra: { [string]: number }?): string
	local entries = {}
	for _, m in Mutations.List do
		local w = m.Weight
		if bias and bias[m.Id] then
			w *= bias[m.Id]
		end
		if extra and extra[m.Id] then
			w += extra[m.Id]
		end
		if w > 0 then
			-- luck helps the rarer mutations more than the common ones
			local rank = Rarities.Rank(m.Rarity)
			if rank >= 3 then
				w *= math.max(luck, 1) ^ math.min(1, (rank - 2) * 0.35)
			end
			table.insert(entries, { m.Id, w })
		end
	end
	return weightedPick(rng, entries) or "Shiny"
end

-- Which material a node in this zone spawns as. boost = per-material multipliers (events).
function Formulas.MaterialWeights(zoneId: string, luck: number, boost: { [string]: number }?): { { any } }
	local entries = {}
	for _, m in Materials.ByZone[zoneId] or {} do
		local w = m.Spawn
		local rank = Rarities.Rank(m.Rarity)
		local zoneRankOffset = rank - Rarities.Rank((Materials.ByZone[zoneId][1]).Rarity)
		if zoneRankOffset >= 1 then
			w *= math.max(luck, 1) ^ math.min(1, zoneRankOffset * 0.4)
		end
		if boost and boost[m.Id] then
			w *= boost[m.Id]
		end
		table.insert(entries, { m.Id, w })
	end
	return entries
end

function Formulas.RollMaterial(rng: any, zoneId: string, luck: number, boost: { [string]: number }?): string?
	return weightedPick(rng, Formulas.MaterialWeights(zoneId, luck, boost))
end

-- Selling ---------------------------------------------------------------------------------------

-- The dealer will not pay full price for materials from zones you haven't reached:
-- anything above your best zone sells as if it came from your best zone.
function Formulas.SellCap(highestTier: number): number
	local zone = Zones.ByTier[math.clamp(highestTier + 1, 1, Zones.Count)]
	local best = 0
	for _, m in Materials.ByZone[zone.Id] or {} do
		best = math.max(best, m.Power)
	end
	return best * Balance.MaterialSellPerPower * 50
end

return Formulas
