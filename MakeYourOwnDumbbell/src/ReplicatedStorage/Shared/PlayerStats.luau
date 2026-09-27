--[[
	PlayerStats - turns a player's saved data into the numbers the game runs on
	(luck, gains multiplier, lift speed, backpack size...).

	Shared: the server uses it for real rewards, the client uses it for the HUD and
	upgrade screens. Pass `ctx` with extras that aren't in the save:
		ctx.Passes = { VIP = true, ... }     -- owned gamepasses
		ctx.Event  = { Gains = 2, Luck = 1.5, Crit = 2, Speed = 1.2 }   -- live event modifiers
		ctx.Now    = os.time()              -- for potion timers
]]

local Config = script.Parent.Config
local Balance = require(Config.Balance)
local Upgrades = require(Config.Upgrades)
local Rebirths = require(Config.Rebirths)
local Formulas = require(script.Parent.Formulas)

local PlayerStats = {}

local function upgrade(data: any, id: string): number
	local u = Upgrades.ById[id]
	return Formulas.UpgradeValue(u, (data.Upgrades and data.Upgrades[id]) or 0)
end

local function perk(data: any, id: string): number
	local p = Rebirths.PerkById[id]
	local level = (data.Perks and data.Perks[id]) or 0
	return level * p.Per
end

local function boostActive(data: any, name: string, now: number): boolean
	local t = data.Boosts and data.Boosts[name]
	return t ~= nil and t > now
end

export type Stats = { [string]: number }

function PlayerStats.Compute(data: any, ctx: any?): Stats
	ctx = ctx or {}
	local passes = ctx.Passes or {}
	local event = ctx.Event or {}
	local now = ctx.Now or os.time()
	local rebirths = data.Rebirths or 0

	-- Luck ------------------------------------------------------------------------------------
	local luck = 1 + rebirths * Rebirths.LuckPerRebirth + perk(data, "LuckyGenes") + (data.BonusLuck or 0)
	if boostActive(data, "Luck", now) then
		luck *= 2
	end
	if boostActive(data, "MegaLuck", now) then
		luck *= 3
	end
	if passes.VIP then
		luck *= 1.1
	end
	luck *= event.Luck or 1

	-- Gains & coins -----------------------------------------------------------------------------
	local gains = Formulas.RebirthMult(rebirths) * (1 + perk(data, "MuscleMemory"))
	if boostActive(data, "Gains", now) then
		gains *= 2
	end
	if passes.VIP then
		gains *= 1.1
	end
	gains *= event.Gains or 1

	local coins = gains * (1 + upgrade(data, "CoinBoost"))
	if passes.VIP then
		coins *= 1.1
	end
	coins *= event.Coins or 1

	-- Training ---------------------------------------------------------------------------------
	local liftCooldown = Balance.LiftCooldown * upgrade(data, "LiftSpeed") * (1 - perk(data, "QuickHands"))
	liftCooldown /= event.Speed or 1

	local stats: Stats = {
		Luck = luck,
		MaterialLuck = luck * (1 + upgrade(data, "MaterialLuck")),
		CraftLuck = luck * (1 + upgrade(data, "CraftLuck")),
		MutationLuck = luck * (1 + upgrade(data, "MutationLuck")),
		Gains = gains,
		Coins = coins,
		LiftCooldown = liftCooldown,
		CritChance = Balance.CritChance + upgrade(data, "CritChance") + perk(data, "CritInstinct"),
		CritMult = (Balance.CritMult + upgrade(data, "CritPower")) * (event.Crit or 1),
		SuperChance = Balance.SuperCritChance,
		SuperMult = Balance.SuperCritMult,
		ComboWindow = Balance.ComboWindow + upgrade(data, "ComboMastery") * 1.5 + perk(data, "StickyCombo"),
		ComboMastery = upgrade(data, "ComboMastery"),
		Backpack = math.floor(upgrade(data, "Backpack") * (1 + perk(data, "PocketSpace")) * (passes.Backpack and 2 or 1)),
		WalkSpeed = upgrade(data, "WalkSpeed"),
		JumpHeight = upgrade(data, "JumpPower"),
		Hammer = upgrade(data, "Hammer"),
		SmashCooldown = Balance.SmashCooldown * upgrade(data, "SmashSpeed"),
		Yield = upgrade(data, "Yield"),
		ForgeTime = Balance.ForgeTime * upgrade(data, "ForgeSpeed") * (passes.FastForge and 0.5 or 1),
		MaxPlateSize = upgrade(data, "ForgeLevel") + perk(data, "BigForge"),
		ProcessSpeed = upgrade(data, "ProcessSpeed") * (passes.AutoProcess and 0.6 or 1),
		ProcessSlots = upgrade(data, "ProcessSlots") + (passes.AutoProcess and 2 or 0),
		BossDamage = 1 + upgrade(data, "BossDamage"),
		EquipSlots = Rebirths.EquipSlots(rebirths, passes.ExtraSlot == true),
		AutoDeposit = upgrade(data, "AutoDeposit"),
		Yield2 = boostActive(data, "Yield", now) and 1 or 0,
	}
	if stats.AutoDeposit == 0 and ((data.Perks and data.Perks.ForeverTeleporter) or 0) > 0 then
		stats.AutoDeposit = Upgrades.ById.AutoDeposit.Values[2]
	end
	return stats
end

-- Combine player stats with the equipped dumbbell's stats for one rep.
function PlayerStats.ForLift(stats: Stats, db: any?): { [string]: number }
	local crit = stats.CritChance + (db and db.Crit or 0)
	return {
		Power = db and db.Power or Balance.UnarmedGains,
		Gains = stats.Gains,
		Coins = stats.Coins * (1 + (db and db.Coins or 0)),
		Cooldown = math.max(Balance.LiftCooldownMin, stats.LiftCooldown * (1 - (db and db.Speed or 0))),
		CritChance = math.min(crit, 0.75),
		CritMult = stats.CritMult * (1 + (db and db.CritPower or 0)),
		SuperChance = stats.SuperChance + (db and db.Super or 0),
		SuperMult = stats.SuperMult,
		ComboWindow = stats.ComboWindow + (db and db.Combo or 0),
		ComboMastery = stats.ComboMastery + (db and db.ComboBonus or 0),
		Luck = stats.Luck * (1 + (db and db.Luck or 0)),
	}
end

return PlayerStats
