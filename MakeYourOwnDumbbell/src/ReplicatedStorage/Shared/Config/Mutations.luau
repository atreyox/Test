--[[
	Mutations - special versions of materials.

	A node can spawn mutated (you can see it from far away: it glows, burns, sparkles...).
	Every unit smashed from it carries the mutation, and a plate or handle made from a
	mutated material is multiplied by Mult.

	Weight : spawn weight when a node rolls a mutation (see Balance.NodeMutationChance).
	Event  : event-only mutations never roll naturally; the matching event adds them.
	Fx     : visual style used by Shared.Visuals.MutationFx.
]]

export type Mutation = {
	Id: string,
	Name: string,
	Mult: number,
	Weight: number,
	Rarity: string,
	Color: Color3,
	Color2: Color3,
	Fx: string,
	Event: string?,
	Desc: string,
	Order: number,
}

local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

local list: { Mutation } = {
	{ Id = "Shiny", Name = "Shiny", Mult = 1.5, Weight = 400, Rarity = "Uncommon", Color = rgb(255, 255, 255), Color2 = rgb(200, 230, 255), Fx = "Sparkle", Desc = "Freshly polished. x1.5" },
	{ Id = "Golden", Name = "Golden", Mult = 2, Weight = 250, Rarity = "Uncommon", Color = rgb(255, 204, 48), Color2 = rgb(255, 240, 150), Fx = "Gold", Desc = "Dipped in pure gold. x2" },
	{ Id = "Frozen", Name = "Frozen", Mult = 2.5, Weight = 120, Rarity = "Rare", Color = rgb(150, 220, 255), Color2 = rgb(235, 250, 255), Fx = "Frost", Desc = "Frozen solid. x2.5" },
	{ Id = "Burning", Name = "Burning", Mult = 3, Weight = 100, Rarity = "Rare", Color = rgb(255, 110, 30), Color2 = rgb(255, 210, 60), Fx = "Fire", Desc = "It's on fire. Literally. x3" },
	{ Id = "Electric", Name = "Electric", Mult = 3.5, Weight = 80, Rarity = "Rare", Color = rgb(90, 200, 255), Color2 = rgb(255, 255, 140), Fx = "Electric", Desc = "Crackling with power. x3.5" },
	{ Id = "Toxic", Name = "Toxic", Mult = 4, Weight = 60, Rarity = "Epic", Color = rgb(150, 255, 40), Color2 = rgb(60, 140, 20), Fx = "Toxic", Desc = "Bubbling green goo. x4" },
	{ Id = "Magnetic", Name = "Magnetic", Mult = 5, Weight = 45, Rarity = "Epic", Color = rgb(255, 70, 70), Color2 = rgb(70, 110, 255), Fx = "Magnetic", Desc = "Pulls bolts from across the room. x5" },
	{ Id = "Radioactive", Name = "Radioactive", Mult = 6, Weight = 35, Rarity = "Epic", Color = rgb(90, 255, 70), Color2 = rgb(200, 255, 120), Fx = "Radioactive", Desc = "Glows in the dark. x6" },
	{ Id = "Crystal", Name = "Crystal", Mult = 7, Weight = 25, Rarity = "Legendary", Color = rgb(120, 240, 255), Color2 = rgb(255, 255, 255), Fx = "Crystal", Desc = "Turned to living crystal. x7" },
	{ Id = "Shadow", Name = "Shadow", Mult = 8.5, Weight = 15, Rarity = "Legendary", Color = rgb(40, 36, 52), Color2 = rgb(120, 100, 160), Fx = "Shadow", Desc = "Wrapped in living shadow. x8.5" },
	{ Id = "Corrupted", Name = "Corrupted", Mult = 10, Weight = 9, Rarity = "Legendary", Color = rgb(170, 20, 40), Color2 = rgb(255, 60, 60), Fx = "Corrupted", Desc = "Something went very wrong. x10" },
	{ Id = "Void", Name = "Void", Mult = 13, Weight = 5, Rarity = "Mythic", Color = rgb(120, 40, 220), Color2 = rgb(20, 6, 36), Fx = "Void", Desc = "Touched by the Void. x13" },
	{ Id = "Rainbow", Name = "Rainbow", Mult = 16, Weight = 2.5, Rarity = "Mythic", Color = rgb(255, 120, 200), Color2 = rgb(120, 220, 255), Fx = "Rainbow", Desc = "Every color, all the time. x16" },
	{ Id = "Glitched", Name = "Glitched", Mult = 22, Weight = 1.2, Rarity = "Mythic", Color = rgb(0, 255, 140), Color2 = rgb(255, 0, 200), Fx = "Glitched", Desc = "Th1s sh0uldn't ex1st. x22" },
	{ Id = "Cosmic", Name = "Cosmic", Mult = 30, Weight = 0.6, Rarity = "Secret", Color = rgb(60, 70, 200), Color2 = rgb(255, 255, 255), Fx = "Cosmic", Desc = "Full of tiny stars. x30" },
	{ Id = "Celestial", Name = "Celestial", Mult = 50, Weight = 0.15, Rarity = "Secret", Color = rgb(255, 246, 210), Color2 = rgb(255, 214, 110), Fx = "Celestial", Desc = "Blessed by the heavens. x50" },

	-- Event-only (only appear while their event is live)
	{ Id = "Spooky", Name = "Spooky", Mult = 6, Weight = 0, Rarity = "Epic", Event = "Halloween", Color = rgb(255, 130, 20), Color2 = rgb(130, 40, 200), Fx = "Spooky", Desc = "Halloween exclusive. Boo! x6" },
	{ Id = "Festive", Name = "Festive", Mult = 6, Weight = 0, Rarity = "Epic", Event = "Winter", Color = rgb(230, 40, 50), Color2 = rgb(40, 200, 90), Fx = "Festive", Desc = "Winter exclusive. Jingle gains. x6" },
	{ Id = "Sunkissed", Name = "Sunkissed", Mult = 6, Weight = 0, Rarity = "Epic", Event = "Summer", Color = rgb(255, 190, 70), Color2 = rgb(255, 120, 90), Fx = "Sparkle", Desc = "Summer exclusive. Warm glow. x6" },
	{ Id = "Confetti", Name = "Confetti", Mult = 6, Weight = 0, Rarity = "Epic", Event = "Anniversary", Color = rgb(255, 90, 220), Color2 = rgb(90, 220, 255), Fx = "Rainbow", Desc = "Anniversary exclusive. Party time! x6" },
	{ Id = "Lovestruck", Name = "Lovestruck", Mult = 6, Weight = 0, Rarity = "Epic", Event = "Valentine", Color = rgb(255, 80, 140), Color2 = rgb(255, 200, 220), Fx = "Sparkle", Desc = "Valentine exclusive. x6" },
}

local byId: { [string]: Mutation } = {}
for i, m in list do
	m.Order = i
	byId[m.Id] = m
end

local Mutations = {
	List = list,
	ById = byId,
}

function Mutations.Get(id: string?): Mutation?
	if id == nil or id == "" then
		return nil
	end
	return byId[id]
end

function Mutations.Mult(id: string?): number
	local m = Mutations.Get(id)
	return m and m.Mult or 1
end

return Mutations
