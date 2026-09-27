--[[
	Balance - global tuning numbers. Change these to speed up / slow down the game.
	Everything that decides rewards reads from here (server side), so the client can
	show the same numbers the server uses.
]]

local Balance = {
	-- Character ---------------------------------------------------------------------
	BaseWalkSpeed = 20,
	BaseJumpHeight = 7.5,

	-- Smashing material nodes ---------------------------------------------------------
	SmashCooldown = 0.3, -- seconds between hits (Smash Speed upgrade lowers it)
	SmashRange = 17, -- studs from the character to the node
	NodeHealth = 100,
	SmashDamage = 34, -- damage per hit when your Smash Power equals the node toughness
	SmashMaxRatio = 3, -- more power than this does not help (1 hit)
	SmashMinRatio = 0.04, -- less power than this: "Too tough!"
	ContributorWindow = 12, -- seconds: everyone who hit a node in this window gets a drop
	NodeRespawnMin = 2.5,
	NodeRespawnMax = 6,
	NodeMutationChance = 0.035, -- chance a node spawns mutated
	PersonalMutationChance = 0.008, -- extra chance (per player, x luck) a drop comes out mutated
	MutatedNodeHealthMult = 2,

	-- Training -------------------------------------------------------------------------
	LiftCooldown = 0.42,
	LiftCooldownMin = 0.15,
	ComboWindow = 1.35, -- seconds you can wait between lifts before the combo breaks
	ComboTiers = { -- combo count -> bonus gains
		{ At = 10, Bonus = 0.1 },
		{ At = 25, Bonus = 0.25 },
		{ At = 50, Bonus = 0.5 },
		{ At = 100, Bonus = 0.8 },
		{ At = 250, Bonus = 1.2 },
		{ At = 500, Bonus = 1.6 },
	},
	CritChance = 0.05,
	CritMult = 5,
	SuperCritChance = 0.004,
	SuperCritMult = 25,
	CoinsPerStrength = 1, -- coins earned per strength gained
	FreeLiftWeight = 12, -- kg anyone can lift with 0 strength
	StrengthPerKg = 60, -- strength needed per kg above FreeLiftWeight
	UnarmedGains = 1, -- gains per lift with no dumbbell (fists!)

	-- Dumbbells -----------------------------------------------------------------------
	PlateSizeExponent = 0.85, -- gains grow a bit slower than plate size (weight grows fully)
	HandlePowerFactor = 0.5,
	HandleWeightFactor = 0.5,
	BalancedBonus = 1.25, -- both plates identical
	DumbbellMaxLevel = 100,
	DumbbellXpBase = 5,
	DumbbellXpExp = 1.3,
	DumbbellLevelBonus = 0.01, -- +1% gains per level
	MaxDumbbells = 60,
	MaxDumbbellsPass = 150,
	ForgeTime = 2.2,
	CoolingSeconds = 30, -- Rare+ dumbbells cool on the rack (heist window)
	CoolingMinRarity = 3,

	-- Economy ---------------------------------------------------------------------------
	MaterialSellPerPower = 2,
	DumbbellSellFactor = 0.6,
	FirstDiscoveryGems = 5,

	-- Offline -----------------------------------------------------------------------------
	OfflineMaxHours = 8,
	OfflineEfficiency = 0.05, -- fraction of your best active income per second

	-- Social ------------------------------------------------------------------------------
	TradeMinPlaySeconds = 20 * 60,
	RookieProtectionSeconds = 30 * 60,

	-- Boosts --------------------------------------------------------------------------------
	PotionMinutes = 15,
}

return Balance
