--[[
	Refine - material processing levels (the Material Processor on your plot).

	Iron -> Iron Ingot -> Refined Iron -> Reinforced Iron -> Perfect Iron

	Input   : units of the previous level needed for one unit of this level
	Seconds : base processing time per output unit (upgrades make it faster)
	Mult    : power multiplier of a unit at this level
	Pattern : display name, %s is the (mutation +) material name
]]

export type RefineLevel = {
	Level: number,
	Name: string,
	Mult: number,
	Input: number,
	Seconds: number,
	FeePerPower: number,
	Pattern: string,
	Color: Color3,
}

local list: { RefineLevel } = {
	{ Level = 0, Name = "Raw", Mult = 1, Input = 0, Seconds = 0, FeePerPower = 0, Pattern = "%s", Color = Color3.fromRGB(200, 200, 200) },
	{ Level = 1, Name = "Ingot", Mult = 1.5, Input = 3, Seconds = 5, FeePerPower = 1, Pattern = "%s Ingot", Color = Color3.fromRGB(120, 220, 255) },
	{ Level = 2, Name = "Refined", Mult = 2.25, Input = 3, Seconds = 10, FeePerPower = 2, Pattern = "Refined %s", Color = Color3.fromRGB(120, 255, 160) },
	{ Level = 3, Name = "Reinforced", Mult = 3.4, Input = 3, Seconds = 18, FeePerPower = 4, Pattern = "Reinforced %s", Color = Color3.fromRGB(255, 200, 80) },
	{ Level = 4, Name = "Perfect", Mult = 5, Input = 3, Seconds = 30, FeePerPower = 8, Pattern = "Perfect %s", Color = Color3.fromRGB(255, 110, 220) },
}

local Refine = {
	List = list,
	Max = #list - 1,
}

function Refine.Get(level: number): RefineLevel
	return list[math.clamp(math.floor(level), 0, #list - 1) + 1]
end

return Refine
