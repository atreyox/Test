--[[
	Layout - where everything goes on the map (studs, degrees).

	Top view: the Hub is at the origin. Around it is the Starter Yard, then the ring
	road, then the 8 player plots facing inward. The other zones are floating islands
	spiralling up around the hub; the Void Zone floats highest, above the Boss Arena.
]]

local Layout = {}

Layout.IslandRadius = 384
Layout.HubRadius = 82
Layout.RoadRadius = 214
Layout.RoadWidth = 18
Layout.PlotRadius = 298
Layout.PlotSize = 84
Layout.PadRadius = 50

Layout.PlotAngles = {}
for k = 0, 7 do
	Layout.PlotAngles[k + 1] = 22.5 + 45 * k
end

-- Floating zone islands: angle around the hub, distance from center, height, radius
Layout.ZoneIslands = {
	Scrapyard = { Angle = 0, Radius = 172, Height = 56, Size = 46 },
	Mine = { Angle = 36, Radius = 172, Height = 82, Size = 46 },
	Factory = { Angle = 72, Radius = 172, Height = 108, Size = 46 },
	Volcano = { Angle = 108, Radius = 172, Height = 134, Size = 46 },
	FrozenCave = { Angle = 144, Radius = 172, Height = 160, Size = 46 },
	CrystalCavern = { Angle = 180, Radius = 172, Height = 186, Size = 46 },
	Nuclear = { Angle = 216, Radius = 172, Height = 212, Size = 46 },
	MeteorCrater = { Angle = 252, Radius = 172, Height = 238, Size = 46 },
	Space = { Angle = 288, Radius = 172, Height = 268, Size = 48 },
	Void = { Angle = 0, Radius = 0, Height = 336, Size = 56 },
}

-- Hub launch pads (zone id -> angle on the pad ring)
Layout.PadAngles = {
	Scrapyard = 0, Mine = 36, Factory = 72, Volcano = 108, FrozenCave = 144,
	CrystalCavern = 180, Nuclear = 216, MeteorCrater = 252, Space = 288, Void = 324,
}

Layout.BossArena = { Height = 150, Size = 62 }

-- Hub ring slots (angle) for NPC stalls and boards
Layout.HubSlots = {
	ScrapDealer = 0,
	Blacksmith = 45,
	Scientist = 90,
	Merchant = 135,
	Coach = 180,
	BoardStrength = 225,
	BoardRebirths = 270,
	BoardRichest = 315,
}

return Layout
