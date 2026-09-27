--[[
	Rarities - the rarity ladder shared by materials, dumbbells, titles and shop items.

	Order matters: `Rank` is used everywhere to compare rarities (higher = rarer).
	Colors are used for item cards, name text, popups and node labels.
]]

export type Rarity = {
	Id: string,
	Rank: number,
	Color: Color3,
	Glow: Color3,
	Announce: boolean, -- announce to the whole server when found/forged
}

local list: { Rarity } = {
	{ Id = "Common", Rank = 1, Color = Color3.fromRGB(176, 186, 199), Glow = Color3.fromRGB(120, 130, 145), Announce = false },
	{ Id = "Uncommon", Rank = 2, Color = Color3.fromRGB(96, 222, 116), Glow = Color3.fromRGB(40, 170, 70), Announce = false },
	{ Id = "Rare", Rank = 3, Color = Color3.fromRGB(70, 162, 255), Glow = Color3.fromRGB(30, 110, 230), Announce = false },
	{ Id = "Epic", Rank = 4, Color = Color3.fromRGB(184, 96, 255), Glow = Color3.fromRGB(130, 50, 220), Announce = false },
	{ Id = "Legendary", Rank = 5, Color = Color3.fromRGB(255, 184, 40), Glow = Color3.fromRGB(240, 140, 0), Announce = true },
	{ Id = "Mythic", Rank = 6, Color = Color3.fromRGB(255, 70, 120), Glow = Color3.fromRGB(220, 20, 80), Announce = true },
	{ Id = "Secret", Rank = 7, Color = Color3.fromRGB(255, 255, 255), Glow = Color3.fromRGB(20, 20, 30), Announce = true },
}

local byId: { [string]: Rarity } = {}
for _, r in list do
	byId[r.Id] = r
end

local Rarities = {
	List = list,
	ById = byId,
}

function Rarities.Get(id: string): Rarity
	return byId[id] or byId.Common
end

function Rarities.Rank(id: string): number
	return Rarities.Get(id).Rank
end

function Rarities.FromRank(rank: number): Rarity
	rank = math.clamp(math.floor(rank), 1, #list)
	return list[rank]
end

return Rarities
