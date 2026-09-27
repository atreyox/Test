--[[
	Rebirths - the prestige system (the Rebirth Machine on your plot).

	Rebirthing RESETS: Strength, Coins, zone unlocks (except Starter Yard) and coin Upgrades.
	Rebirthing KEEPS : dumbbells, materials, gems, index, achievements, titles, security,
	                   Rebirth Shop perks and your plot's look.
	You get         : a new rank name, a permanent gains/coins/luck multiplier,
	                   Rebirth Tokens and the unlocks listed in Unlocks.

	Requirement for the next rebirth (Strength): RequirementList[rebirths + 1], and after
	the list runs out it keeps multiplying by RequirementGrowth.
]]

export type Perk = {
	Id: string,
	Name: string,
	Emoji: string,
	Desc: string,
	Max: number,
	CostBase: number,
	CostStep: number,
	Per: number,
	Format: string,
	Order: number,
}

local Rebirths = {}

Rebirths.RequirementList = {
	1.9e9, 4e10, 3.7e11, 3.6e12, 2e13, 1.5e14, 1.2e15, 1e16, 9e16, 8e17,
}
Rebirths.RequirementGrowth = 9
Rebirths.GainsPerRebirth = 1.0 -- +100% gains and coins per rebirth (additive)
Rebirths.LuckPerRebirth = 0.1 -- +10% luck per rebirth
Rebirths.TokensBase = 2
Rebirths.TokensPerRebirth = 1

Rebirths.Ranks = {
	[0] = { Name = "Rookie", Color = Color3.fromRGB(190, 196, 206) },
	[1] = { Name = "Gym Rat", Color = Color3.fromRGB(120, 220, 120) },
	[2] = { Name = "Iron Pumper", Color = Color3.fromRGB(150, 160, 175) },
	[3] = { Name = "Powerlifter", Color = Color3.fromRGB(80, 170, 255) },
	[4] = { Name = "Bodybuilder", Color = Color3.fromRGB(255, 150, 60) },
	[5] = { Name = "Champion", Color = Color3.fromRGB(255, 205, 50) },
	[6] = { Name = "Titan", Color = Color3.fromRGB(255, 90, 60) },
	[7] = { Name = "Colossus", Color = Color3.fromRGB(200, 90, 255) },
	[8] = { Name = "Superhuman", Color = Color3.fromRGB(60, 140, 255) },
	[9] = { Name = "Demigod", Color = Color3.fromRGB(255, 230, 150) },
	[10] = { Name = "Cosmic Lifter", Color = Color3.fromRGB(120, 120, 255) },
	[11] = { Name = "Star Crusher", Color = Color3.fromRGB(255, 180, 90) },
	[12] = { Name = "Galaxy Bender", Color = Color3.fromRGB(255, 110, 220) },
	[13] = { Name = "Void Titan", Color = Color3.fromRGB(170, 70, 255) },
	[14] = { Name = "Omnilifter", Color = Color3.fromRGB(90, 255, 220) },
	[15] = { Name = "Reality Bender", Color = Color3.fromRGB(255, 80, 120) },
	[16] = { Name = "Time Lifter", Color = Color3.fromRGB(120, 255, 150) },
	[17] = { Name = "Universe Hauler", Color = Color3.fromRGB(150, 200, 255) },
	[18] = { Name = "Infinity Pumper", Color = Color3.fromRGB(255, 140, 255) },
	[19] = { Name = "The Absolute", Color = Color3.fromRGB(255, 255, 255) },
	[20] = { Name = "Dumbbell Deity", Color = Color3.fromRGB(255, 220, 90) },
}

local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X" }

function Rebirths.RankName(rebirths: number): string
	if rebirths <= 20 then
		return Rebirths.Ranks[rebirths].Name
	end
	local extra = rebirths - 20
	local suffix = ROMAN[((extra - 1) % 10) + 1]
	if extra > 10 then
		suffix = tostring(extra + 1)
	end
	return "Dumbbell Deity " .. suffix
end

function Rebirths.RankColor(rebirths: number): Color3
	return Rebirths.Ranks[math.min(rebirths, 20)].Color
end

-- Plot looks: your workshop grows as you rebirth.
Rebirths.PlotTiers = {
	{ At = 0, Name = "Garage" },
	{ At = 1, Name = "Small Gym" },
	{ At = 3, Name = "Pro Gym" },
	{ At = 6, Name = "Future Lab" },
	{ At = 10, Name = "Titan Facility" },
}

function Rebirths.PlotTier(rebirths: number): number
	local tier = 1
	for i, t in Rebirths.PlotTiers do
		if rebirths >= t.At then
			tier = i
		end
	end
	return tier
end

-- Unlocks shown on the Rebirth screen (the systems themselves check the numbers).
Rebirths.Unlocks = {
	{ At = 1, Text = "Crystal Cavern zone" },
	{ At = 1, Text = "GLITCHED forge quality" },
	{ At = 1, Text = "Workshop becomes a Small Gym" },
	{ At = 2, Text = "Nuclear Facility zone" },
	{ At = 2, Text = "+1 trophy display stand" },
	{ At = 3, Text = "Meteor Crater zone" },
	{ At = 3, Text = "CELESTIAL forge quality" },
	{ At = 3, Text = "Workshop becomes a Pro Gym" },
	{ At = 4, Text = "Space Zone" },
	{ At = 5, Text = "Void Zone" },
	{ At = 5, Text = "Second dumbbell slot (dual wield!)" },
	{ At = 6, Text = "Workshop becomes a Future Lab" },
	{ At = 10, Text = "Workshop becomes a Titan Facility" },
	{ At = 10, Text = "Third dumbbell slot" },
}

function Rebirths.EquipSlots(rebirths: number, hasPass: boolean): number
	local slots = 1
	if rebirths >= 5 then
		slots += 1
	end
	if rebirths >= 10 then
		slots += 1
	end
	if hasPass then
		slots += 1
	end
	return math.min(slots, 3)
end

-- Rebirth Shop: permanent perks bought with Rebirth Tokens.
local perks: { Perk } = {
	{ Id = "MuscleMemory", Name = "Muscle Memory", Emoji = "💪", Desc = "+10% gains forever.", Max = 50, CostBase = 1, CostStep = 1, Per = 0.1, Format = "Percent" },
	{ Id = "LuckyGenes", Name = "Lucky Genes", Emoji = "🍀", Desc = "+5% luck forever.", Max = 30, CostBase = 2, CostStep = 1, Per = 0.05, Format = "Percent" },
	{ Id = "PocketSpace", Name = "Pocket Space", Emoji = "🎒", Desc = "+20% backpack capacity.", Max = 10, CostBase = 2, CostStep = 1, Per = 0.2, Format = "Percent" },
	{ Id = "BigForge", Name = "Big Forge", Emoji = "🔥", Desc = "+2 max plate size.", Max = 25, CostBase = 3, CostStep = 1, Per = 2, Format = "PlusInt" },
	{ Id = "HeadStart", Name = "Head Start", Emoji = "🚀", Desc = "Start every rebirth with the next zone already unlocked.", Max = 3, CostBase = 5, CostStep = 5, Per = 1, Format = "Zones" },
	{ Id = "PiggyBank", Name = "Piggy Bank", Emoji = "🐷", Desc = "Keep 5% of your coins when you rebirth.", Max = 10, CostBase = 3, CostStep = 1, Per = 0.05, Format = "Percent" },
	{ Id = "QuickHands", Name = "Quick Hands", Emoji = "✋", Desc = "-3% lift cooldown.", Max = 10, CostBase = 3, CostStep = 2, Per = 0.03, Format = "Percent" },
	{ Id = "CritInstinct", Name = "Crit Instinct", Emoji = "🎯", Desc = "+1% crit chance.", Max = 10, CostBase = 3, CostStep = 2, Per = 0.01, Format = "Percent" },
	{ Id = "StickyCombo", Name = "Sticky Combo", Emoji = "🔗", Desc = "+0.1s combo window.", Max = 10, CostBase = 2, CostStep = 1, Per = 0.1, Format = "Seconds" },
	{ Id = "ForeverTeleporter", Name = "Forever Teleporter", Emoji = "📦", Desc = "Keep Material Teleporter level 1 through rebirths.", Max = 1, CostBase = 8, CostStep = 0, Per = 1, Format = "Unlock" },
}

local perkById: { [string]: Perk } = {}
for i, p in perks do
	p.Order = i
	perkById[p.Id] = p
end

Rebirths.Perks = perks
Rebirths.PerkById = perkById

function Rebirths.PerkCost(perk: Perk, level: number): number
	return perk.CostBase + perk.CostStep * level
end

return Rebirths
