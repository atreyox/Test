--[[
	Upgrades - bought with Coins at the Upgrade Machine on your plot.
	They reset when you Rebirth (the Rebirth Shop perks do not).

	Values[level + 1] is the upgrade's value at that level (level 0 = not bought).
	Cost of the next level = Cost.Base * Cost.Growth ^ level (rounded to a nice number).
	Format tells the UI how to show a value: Int, Percent, Mult, Seconds, Speed, PlusInt.
]]

export type Upgrade = {
	Id: string,
	Name: string,
	Emoji: string,
	Group: string,
	Desc: string,
	Cost: { Base: number, Growth: number },
	Values: { number },
	Format: string,
	Order: number,
}

local function series(count: number, start: number, step: number): { number }
	local t = {}
	for i = 0, count do
		t[i + 1] = start + step * i
	end
	return t
end

local function geometric(count: number, start: number, ratio: number, digits: number?): { number }
	local t = {}
	local d = 10 ^ (digits or 2)
	for i = 0, count do
		t[i + 1] = math.floor(start * ratio ^ i * d + 0.5) / d
	end
	return t
end

local list: { Upgrade } = {
	-- GATHERING --------------------------------------------------------------------------
	{
		Id = "Backpack", Name = "Backpack", Emoji = "🎒", Group = "Gather",
		Desc = "Carry more materials before heading home.",
		Cost = { Base = 30, Growth = 2.45 },
		Values = { 20, 30, 45, 65, 90, 120, 160, 210, 275, 350, 450, 600, 800, 1000, 1300, 1700 },
		Format = "Int",
	},
	{
		Id = "Hammer", Name = "Smash Power", Emoji = "🔨", Group = "Gather",
		Desc = "Hit material nodes harder. Tough ores need more power.",
		Cost = { Base = 40, Growth = 2.9 },
		Values = geometric(18, 1, 1.18, 2),
		Format = "Mult",
	},
	{
		Id = "SmashSpeed", Name = "Smash Speed", Emoji = "⚡", Group = "Gather",
		Desc = "Swing faster at material nodes.",
		Cost = { Base = 75, Growth = 2.6 },
		Values = geometric(10, 1, 0.94, 3),
		Format = "Speed",
	},
	{
		Id = "Yield", Name = "Double Drops", Emoji = "✨", Group = "Gather",
		Desc = "Chance to get an extra unit from every node you break.",
		Cost = { Base = 150, Growth = 2.5 },
		Values = series(15, 0, 0.05),
		Format = "Percent",
	},
	{
		Id = "MaterialLuck", Name = "Material Luck", Emoji = "🍀", Group = "Gather",
		Desc = "Find rare materials and mutations more often.",
		Cost = { Base = 250, Growth = 2.4 },
		Values = series(20, 0, 0.1),
		Format = "Percent",
	},
	{
		Id = "WalkSpeed", Name = "Walk Speed", Emoji = "👟", Group = "Gather",
		Desc = "Run between zones and your workshop faster.",
		Cost = { Base = 60, Growth = 2.3 },
		Values = series(10, 20, 1.5),
		Format = "Int",
	},
	{
		Id = "AutoDeposit", Name = "Material Teleporter", Emoji = "📦", Group = "Gather",
		Desc = "Automatically beams your backpack home every few seconds.",
		Cost = { Base = 25000, Growth = 12 },
		Values = { 0, 60, 40, 25, 15, 8 },
		Format = "Seconds",
	},

	-- FORGING ----------------------------------------------------------------------------
	{
		Id = "ForgeLevel", Name = "Forge Level", Emoji = "🔥", Group = "Forge",
		Desc = "Bigger plates! Raises the max plate size you can forge.",
		Cost = { Base = 60, Growth = 3 },
		Values = { 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 18, 20, 23, 26, 30, 35, 40, 45, 50 },
		Format = "PlusInt",
	},
	{
		Id = "ForgeSpeed", Name = "Forge Speed", Emoji = "⏩", Group = "Forge",
		Desc = "Forge dumbbells faster.",
		Cost = { Base = 200, Growth = 2.4 },
		Values = geometric(8, 1, 0.88, 3),
		Format = "Speed",
	},
	{
		Id = "CraftLuck", Name = "Forge Luck", Emoji = "🎲", Group = "Forge",
		Desc = "Better odds of Perfect, Shiny, Golden and Rainbow quality.",
		Cost = { Base = 400, Growth = 2.45 },
		Values = series(20, 0, 0.1),
		Format = "Percent",
	},
	{
		Id = "ProcessSpeed", Name = "Processing Speed", Emoji = "⚙️", Group = "Forge",
		Desc = "Your Material Processor works faster.",
		Cost = { Base = 1500, Growth = 2.5 },
		Values = geometric(10, 1, 0.88, 3),
		Format = "Speed",
	},
	{
		Id = "ProcessSlots", Name = "Processor Slots", Emoji = "🏗️", Group = "Forge",
		Desc = "Process more materials at the same time.",
		Cost = { Base = 5000, Growth = 9 },
		Values = { 1, 2, 3, 4, 5 },
		Format = "Int",
	},
	{
		Id = "MutationLuck", Name = "Mutation Luck", Emoji = "🧪", Group = "Forge",
		Desc = "Your drops come out mutated more often.",
		Cost = { Base = 800, Growth = 2.5 },
		Values = series(20, 0, 0.1),
		Format = "Percent",
	},

	-- TRAINING ---------------------------------------------------------------------------
	{
		Id = "LiftSpeed", Name = "Lift Speed", Emoji = "💨", Group = "Train",
		Desc = "Do reps faster.",
		Cost = { Base = 50, Growth = 2.35 },
		Values = geometric(15, 1, 0.955, 3),
		Format = "Speed",
	},
	{
		Id = "CritChance", Name = "Crit Chance", Emoji = "🎯", Group = "Train",
		Desc = "More CRITICAL LIFTS.",
		Cost = { Base = 120, Growth = 2.3 },
		Values = series(20, 0, 0.005),
		Format = "Percent",
	},
	{
		Id = "CritPower", Name = "Crit Power", Emoji = "💥", Group = "Train",
		Desc = "Critical lifts give even more.",
		Cost = { Base = 180, Growth = 2.35 },
		Values = series(20, 0, 0.5),
		Format = "PlusMult",
	},
	{
		Id = "ComboMastery", Name = "Combo Mastery", Emoji = "🔗", Group = "Train",
		Desc = "Longer combo window and bigger combo bonuses.",
		Cost = { Base = 300, Growth = 2.6 },
		Values = series(10, 0, 0.1),
		Format = "Percent",
	},
	{
		Id = "CoinBoost", Name = "Coin Boost", Emoji = "🪙", Group = "Train",
		Desc = "Earn more coins from every rep.",
		Cost = { Base = 100, Growth = 2.4 },
		Values = series(25, 0, 0.1),
		Format = "Percent",
	},
	{
		Id = "BossDamage", Name = "Boss Damage", Emoji = "⚔️", Group = "Train",
		Desc = "Hit world bosses harder.",
		Cost = { Base = 2000, Growth = 2.3 },
		Values = series(20, 0, 0.1),
		Format = "Percent",
	},
	{
		Id = "JumpPower", Name = "Jump Power", Emoji = "🦘", Group = "Train",
		Desc = "Jump higher. Useful for dodging boss slams.",
		Cost = { Base = 90, Growth = 2.2 },
		Values = series(8, 7.5, 1),
		Format = "Int",
	},
}

local byId: { [string]: Upgrade } = {}
for i, u in list do
	u.Order = i
	byId[u.Id] = u
end

local Upgrades = {
	List = list,
	ById = byId,
	Groups = { "Gather", "Forge", "Train" },
	GroupNames = { Gather = "Gathering", Forge = "Forging", Train = "Training" },
}

function Upgrades.Get(id: string)
	return byId[id]
end

function Upgrades.MaxLevel(u: Upgrade): number
	return #u.Values - 1
end

return Upgrades
