--[[
	Qualities - rolled every time you forge a dumbbell.

	Weight     : base roll weight (see Formulas.RollQuality: luck boosts the rarer rows).
	LuckPower  : how strongly luck boosts this row (0 = not at all, 1 = fully).
	RebirthReq : the row is locked until you have this many rebirths.
	Mult       : multiplies the dumbbell's gains.
]]

export type Quality = {
	Id: string,
	Name: string,
	Mult: number,
	Weight: number,
	LuckPower: number,
	RebirthReq: number,
	Color: Color3,
	Color2: Color3,
	Rank: number,
	Announce: boolean,
	Fx: string,
}

local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

local list: { Quality } = {
	{ Id = "Normal", Name = "Normal", Mult = 1, Weight = 5200, LuckPower = 0, RebirthReq = 0, Color = rgb(200, 206, 214), Color2 = rgb(150, 156, 166), Rank = 1, Announce = false, Fx = "None" },
	{ Id = "Good", Name = "Good", Mult = 1.25, Weight = 2400, LuckPower = 0.3, RebirthReq = 0, Color = rgb(120, 230, 130), Color2 = rgb(60, 180, 90), Rank = 2, Announce = false, Fx = "None" },
	{ Id = "Great", Name = "Great", Mult = 1.6, Weight = 1400, LuckPower = 0.5, RebirthReq = 0, Color = rgb(90, 180, 255), Color2 = rgb(40, 120, 230), Rank = 3, Announce = false, Fx = "Sparkle" },
	{ Id = "Perfect", Name = "Perfect", Mult = 2.2, Weight = 650, LuckPower = 0.7, RebirthReq = 0, Color = rgb(200, 120, 255), Color2 = rgb(140, 60, 230), Rank = 4, Announce = false, Fx = "Sparkle" },
	{ Id = "Shiny", Name = "Shiny", Mult = 3.2, Weight = 230, LuckPower = 1, RebirthReq = 0, Color = rgb(170, 250, 255), Color2 = rgb(255, 255, 255), Rank = 5, Announce = false, Fx = "Shiny" },
	{ Id = "Golden", Name = "Golden", Mult = 4.5, Weight = 90, LuckPower = 1, RebirthReq = 0, Color = rgb(255, 204, 40), Color2 = rgb(255, 150, 20), Rank = 6, Announce = true, Fx = "Gold" },
	{ Id = "Rainbow", Name = "Rainbow", Mult = 7, Weight = 25, LuckPower = 1, RebirthReq = 0, Color = rgb(255, 120, 200), Color2 = rgb(120, 220, 255), Rank = 7, Announce = true, Fx = "Rainbow" },
	{ Id = "Glitched", Name = "Glitched", Mult = 12, Weight = 4, LuckPower = 1, RebirthReq = 1, Color = rgb(0, 255, 150), Color2 = rgb(255, 0, 200), Rank = 8, Announce = true, Fx = "Glitched" },
	{ Id = "Celestial", Name = "Celestial", Mult = 25, Weight = 0.8, LuckPower = 1, RebirthReq = 3, Color = rgb(255, 246, 210), Color2 = rgb(255, 210, 110), Rank = 9, Announce = true, Fx = "Celestial" },
}

local byId: { [string]: Quality } = {}
for _, q in list do
	byId[q.Id] = q
end

local Qualities = {
	List = list,
	ById = byId,
}

function Qualities.Get(id: string?): Quality
	return (id and byId[id]) or byId.Normal
end

return Qualities
