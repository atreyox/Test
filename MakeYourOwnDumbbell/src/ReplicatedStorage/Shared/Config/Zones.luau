--[[
	Zones - the gathering areas, in unlock order.

	Tier       : 1..11, used to scale materials, quests, bosses and event loot.
	Cost       : coins to unlock (paid once per rebirth cycle).
	RebirthReq : rebirths needed before the zone can be bought at all.
	Toughness  : how hard the zone's material nodes are to smash (see Formulas.SmashDamage).
	MaxNodes   : how many material nodes the server keeps alive in the zone.
	MutationBias : multipliers applied to the mutation table for nodes spawned here.

	The physical island for each zone lives in Workspace.Map.Zones.<Id> (built by the
	place builder) and contains Spawn, Bounds and NodeSpawns.
]]

export type Zone = {
	Id: string,
	Name: string,
	Tier: number,
	Cost: number,
	RebirthReq: number,
	Toughness: number,
	MaxNodes: number,
	Color: Color3,
	Accent: Color3,
	Emoji: string,
	Blurb: string,
	MutationBias: { [string]: number },
}

local list: { Zone } = {
	{
		Id = "StarterYard", Name = "Starter Yard", Tier = 1, Cost = 0, RebirthReq = 0,
		Toughness = 6, MaxNodes = 34,
		Color = Color3.fromRGB(98, 196, 92), Accent = Color3.fromRGB(255, 214, 64), Emoji = "🌳",
		Blurb = "Old tires, plastic crates and firewood. Everyone starts somewhere!",
		MutationBias = {},
	},
	{
		Id = "Scrapyard", Name = "Scrapyard", Tier = 2, Cost = 3500, RebirthReq = 0,
		Toughness = 10000, MaxNodes = 22,
		Color = Color3.fromRGB(196, 110, 58), Accent = Color3.fromRGB(255, 196, 80), Emoji = "🚗",
		Blurb = "Crushed cars and rusty treasure. Watch out for loose bolts.",
		MutationBias = { Magnetic = 3, Electric = 1.5 },
	},
	{
		Id = "Mine", Name = "The Mine", Tier = 3, Cost = 31000, RebirthReq = 0,
		Toughness = 70000, MaxNodes = 22,
		Color = Color3.fromRGB(124, 98, 78), Accent = Color3.fromRGB(255, 176, 72), Emoji = "⛏️",
		Blurb = "Deep tunnels full of iron, silver and glittering amethyst.",
		MutationBias = { Golden = 2, Crystal = 2 },
	},
	{
		Id = "Factory", Name = "Industrial Factory", Tier = 4, Cost = 1400000, RebirthReq = 0,
		Toughness = 9000000, MaxNodes = 22,
		Color = Color3.fromRGB(88, 120, 158), Accent = Color3.fromRGB(255, 204, 0), Emoji = "🏭",
		Blurb = "Steel beams, titanium sheets and humming machines.",
		MutationBias = { Electric = 4, Magnetic = 3 },
	},
	{
		Id = "Volcano", Name = "Volcano", Tier = 5, Cost = 29000000, RebirthReq = 0,
		Toughness = 150000000, MaxNodes = 22,
		Color = Color3.fromRGB(70, 56, 56), Accent = Color3.fromRGB(255, 104, 24), Emoji = "🌋",
		Blurb = "Molten gold and razor obsidian. Don't touch the orange stuff.",
		MutationBias = { Burning = 6, Golden = 1.5 },
	},
	{
		Id = "FrozenCave", Name = "Frozen Cave", Tier = 6, Cost = 250000000, RebirthReq = 0,
		Toughness = 1800000000, MaxNodes = 22,
		Color = Color3.fromRGB(150, 206, 240), Accent = Color3.fromRGB(230, 250, 255), Emoji = "❄️",
		Blurb = "Ancient ice that never melts, hiding sapphires in the dark.",
		MutationBias = { Frozen = 6, Crystal = 2 },
	},
	{
		Id = "CrystalCavern", Name = "Crystal Cavern", Tier = 7, Cost = 7600000000, RebirthReq = 1,
		Toughness = 40000000000, MaxNodes = 22,
		Color = Color3.fromRGB(150, 84, 214), Accent = Color3.fromRGB(255, 120, 230), Emoji = "💎",
		Blurb = "A glowing cave of gems. Diamonds are a lifter's best friend.",
		MutationBias = { Crystal = 6, Rainbow = 2 },
	},
	{
		Id = "Nuclear", Name = "Nuclear Facility", Tier = 8, Cost = 140000000000, RebirthReq = 2,
		Toughness = 600000000000, MaxNodes = 22,
		Color = Color3.fromRGB(96, 110, 96), Accent = Color3.fromRGB(120, 255, 60), Emoji = "☢️",
		Blurb = "Hazard pay not included. Uranium glows for a reason.",
		MutationBias = { Radioactive = 6, Toxic = 5 },
	},
	{
		Id = "MeteorCrater", Name = "Meteor Crater", Tier = 9, Cost = 1900000000000, RebirthReq = 3,
		Toughness = 5500000000000, MaxNodes = 22,
		Color = Color3.fromRGB(92, 64, 58), Accent = Color3.fromRGB(255, 120, 60), Emoji = "☄️",
		Blurb = "Rocks from outer space, still warm from the fall.",
		MutationBias = { Burning = 2, Cosmic = 4 },
	},
	{
		Id = "Space", Name = "Space Zone", Tier = 10, Cost = 23000000000000, RebirthReq = 4,
		Toughness = 55000000000000, MaxNodes = 22,
		Color = Color3.fromRGB(64, 72, 120), Accent = Color3.fromRGB(140, 200, 255), Emoji = "🪐",
		Blurb = "Low gravity, high gains. Moonstone and nebula glass drift here.",
		MutationBias = { Cosmic = 6, Celestial = 2 },
	},
	{
		Id = "Void", Name = "Void Zone", Tier = 11, Cost = 30000000000000, RebirthReq = 5,
		Toughness = 200000000000000, MaxNodes = 22,
		Color = Color3.fromRGB(40, 20, 64), Accent = Color3.fromRGB(190, 80, 255), Emoji = "🌀",
		Blurb = "The edge of reality. Nobody knows who left the dumbbells here.",
		MutationBias = { Void = 6, Shadow = 4, Corrupted = 3 },
	},
}

local byId: { [string]: Zone } = {}
local byTier: { [number]: Zone } = {}
for _, z in list do
	byId[z.Id] = z
	byTier[z.Tier] = z
end

local Zones = {
	List = list,
	ById = byId,
	ByTier = byTier,
	Count = #list,
}

function Zones.Get(id: string): Zone?
	return byId[id]
end

return Zones
