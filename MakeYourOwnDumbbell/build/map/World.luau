--[[
	World - lighting, the main floating island, the cloud sea, the ring road, paths,
	the island fence, trees and the Starter Yard (with its material spawn points).
]]

local roblox = require("@lune/roblox")
local Geo = require("../lib/Geo")
local Props = require("./Props")
local Layout = require("./Layout")

local Instance = roblox.Instance
local CFrame = roblox.CFrame
local Color3 = roblox.Color3
local Enum = roblox.Enum
local V3 = Geo.V3
local rgb = Geo.rgb
local rad = math.rad

local World = {}

local function setupLighting(game: any)
	local L = game:GetService("Lighting")
	L.Technology = Enum.Technology.Future
	L.ClockTime = 14.2
	L.GeographicLatitude = 28
	L.Brightness = 2.6
	L.Ambient = rgb(92, 96, 112)
	L.OutdoorAmbient = rgb(136, 142, 160)
	L.ColorShift_Top = rgb(255, 244, 226)
	L.EnvironmentDiffuseScale = 1
	L.EnvironmentSpecularScale = 1
	L.ShadowSoftness = 0.3
	L.ExposureCompensation = 0.05
	L.GlobalShadows = true

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.26
	atmosphere.Offset = 0.12
	atmosphere.Color = rgb(206, 226, 255)
	atmosphere.Decay = rgb(128, 142, 176)
	atmosphere.Glare = 0.25
	atmosphere.Haze = 1.1
	atmosphere.Parent = L

	local sky = Instance.new("Sky")
	sky.SunAngularSize = 14
	sky.MoonAngularSize = 11
	sky.StarCount = 3000
	sky.Parent = L

	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.65
	bloom.Size = 28
	bloom.Threshold = 1.35
	bloom.Parent = L

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Saturation = 0.14
	cc.Contrast = 0.07
	cc.Brightness = 0.02
	cc.TintColor = rgb(255, 252, 246)
	cc.Parent = L

	local rays = Instance.new("SunRaysEffect")
	rays.Intensity = 0.05
	rays.Spread = 0.8
	rays.Parent = L
end

local function ground(map: any)
	local island = Geo.model(map, "Island")
	local R = Layout.IslandRadius
	Geo.disc(island, "Grass", CFrame.new(0, -4, 0), R * 2, 8, rgb(104, 182, 84), "Grass")
	Geo.disc(island, "Cliff", CFrame.new(0, -12, 0), R * 2 + 6, 16, rgb(142, 104, 70), "Ground")
	local layers = {
		{ 0.99, 18, rgb(128, 108, 92) },
		{ 0.9, 20, rgb(118, 100, 88) },
		{ 0.78, 22, rgb(108, 94, 84) },
		{ 0.62, 24, rgb(98, 86, 80) },
		{ 0.46, 26, rgb(90, 80, 76) },
		{ 0.3, 28, rgb(82, 74, 72) },
		{ 0.15, 28, rgb(74, 68, 68) },
	}
	local y = -20
	for i, layer in layers do
		local h = layer[2]
		Geo.disc(island, "Rock" .. i, CFrame.new(0, y - h / 2, 0), R * 2 * layer[1], h, layer[3], "Rock")
		-- irregular chunks around the edge of each layer
		local ringR = R * layer[1]
		local count = math.max(6, math.floor(ringR / 14))
		for j = 1, count do
			local a = (j / count) * 360 + Geo.rand(-6, 6)
			local size = V3(Geo.rand(26, 48), h * Geo.rand(1.1, 1.7), Geo.rand(26, 48))
			local pos = Geo.polar(ringR - size.X * 0.3, a, y - h / 2 - Geo.rand(0, h * 0.4))
			Geo.box(island, "Chunk", CFrame.new(pos) * CFrame.Angles(rad(Geo.rand(-10, 10)), rad(-a + Geo.rand(-20, 20)), rad(Geo.rand(-10, 10))), size, Geo.lerpColor(layer[3], rgb(70, 64, 62), Geo.rand(0, 0.3)), "Rock")
		end
		y -= h
	end
	-- stalactite tip
	Geo.disc(island, "Tip", CFrame.new(0, y - 14, 0), 40, 28, rgb(70, 64, 64), "Rock")
end

local function clouds(map: any)
	local folder = Geo.folder(map, "Clouds")
	local white = rgb(248, 250, 255)
	for i = 1, 70 do
		local a = Geo.rand(0, 360)
		local r = Geo.rand(420, 1500)
		local base = Geo.polar(r, a, Geo.rand(-300, -220))
		local puffs = 3 + math.floor(Geo.rand() * 4)
		for j = 1, puffs do
			local d = Geo.rand(60, 150)
			local off = V3(Geo.rand(-90, 90), Geo.rand(-15, 20), Geo.rand(-90, 90))
			Geo.ball(folder, "Cloud", CFrame.new(base + off), d, Geo.lerpColor(white, rgb(220, 230, 245), Geo.rand(0, 0.5)), "SmoothPlastic", { CastShadow = false, CanCollide = false, CanQuery = false, CanTouch = false })
		end
	end
	-- a few high wispy clouds
	for i = 1, 14 do
		local a = Geo.rand(0, 360)
		local pos = Geo.polar(Geo.rand(600, 1300), a, Geo.rand(260, 420))
		for j = 1, 3 do
			Geo.ball(folder, "HighCloud", CFrame.new(pos + V3(Geo.rand(-60, 60), Geo.rand(-8, 8), Geo.rand(-60, 60))), Geo.rand(40, 80), white, "SmoothPlastic", { Transparency = 0.25, CastShadow = false, CanCollide = false, CanQuery = false, CanTouch = false })
		end
	end
end

local function miniIslands(map: any)
	local folder = Geo.folder(map, "MiniIslands")
	for i = 1, 9 do
		local a = i * 40 + Geo.rand(-10, 10)
		local r = Geo.rand(520, 760)
		local pos = Geo.polar(r, a, Geo.rand(-60, 90))
		local d = Geo.rand(40, 80)
		local m = Geo.model(folder, "MiniIsland")
		Geo.disc(m, "Top", CFrame.new(pos), d, 4, rgb(108, 184, 86), "Grass")
		Geo.disc(m, "Dirt", CFrame.new(pos - V3(0, 4, 0)), d + 2, 6, rgb(140, 104, 72), "Ground")
		local y = pos.Y - 7
		local dd = d
		for k = 1, 4 do
			dd *= 0.7
			local h = 8
			Geo.disc(m, "Rock", CFrame.new(pos.X, y - h / 2, pos.Z), dd, h, rgb(112 - k * 8, 98 - k * 6, 88 - k * 5), "Rock")
			y -= h
		end
		local trees = 1 + math.floor(Geo.rand() * 3)
		for t = 1, trees do
			Props.tree(m, CFrame.new(pos + V3(Geo.rand(-d / 4, d / 4), 2, Geo.rand(-d / 4, d / 4))), Geo.rand(0.7, 1.1))
		end
	end
end

local function ring(parent: any, name: string, radius: number, width: number, height: number, y: number, color: any, mat: string, segments: number)
	local folder = Geo.model(parent, name)
	local seg = segments
	local len = 2 * math.pi * radius / seg + 0.6
	for i = 0, seg - 1 do
		local a = (i + 0.5) / seg * 360
		local pos = Geo.polar(radius, a, y)
		local cf = CFrame.new(pos) * CFrame.Angles(0, rad(a), 0)
		Geo.box(folder, "Seg", cf, V3(width, height, len), color, mat)
	end
	return folder
end

local function roads(map: any)
	local folder = Geo.folder(map, "Roads")
	local R = Layout.RoadRadius
	local W = Layout.RoadWidth
	ring(folder, "Road", R, W, 0.5, 0.2, rgb(214, 198, 168), "Pavement", 96)
	ring(folder, "CurbIn", R - W / 2 - 0.6, 1.2, 0.8, 0.35, rgb(238, 232, 220), "Concrete", 96)
	ring(folder, "CurbOut", R + W / 2 + 0.6, 1.2, 0.8, 0.35, rgb(238, 232, 220), "Concrete", 96)
	-- dashed center line
	local dashes = Geo.model(folder, "Dashes")
	for i = 0, 71 do
		local a = i / 72 * 360
		local pos = Geo.polar(R, a, 0.48)
		Geo.box(dashes, "Dash", CFrame.new(pos) * CFrame.Angles(0, rad(a), 0), V3(0.6, 0.06, 7), rgb(255, 214, 96), "SmoothPlastic")
	end
	-- radial paths: hub -> road, road -> plot
	for _, a in Layout.PlotAngles do
		local inner0, inner1 = Layout.HubRadius - 2, R - W / 2
		local mid = (inner0 + inner1) / 2
		local cf = CFrame.new(Geo.polar(mid, a, 0.18)) * CFrame.Angles(0, rad(a + 90), 0)
		Geo.box(folder, "PathIn", cf, V3(12, 0.44, inner1 - inner0), rgb(222, 208, 180), "Pavement")
		Geo.box(folder, "PathInEdgeL", cf * CFrame.new(-6.4, 0.08, 0), V3(0.8, 0.6, inner1 - inner0), rgb(238, 232, 220), "Concrete")
		Geo.box(folder, "PathInEdgeR", cf * CFrame.new(6.4, 0.08, 0), V3(0.8, 0.6, inner1 - inner0), rgb(238, 232, 220), "Concrete")
		local outer0, outer1 = R + W / 2, Layout.PlotRadius - Layout.PlotSize / 2
		local mid2 = (outer0 + outer1) / 2
		local cf2 = CFrame.new(Geo.polar(mid2, a, 0.18)) * CFrame.Angles(0, rad(a + 90), 0)
		Geo.box(folder, "PathOut", cf2, V3(16, 0.44, outer1 - outer0 + 1), rgb(222, 208, 180), "Pavement")
	end
end

local function edgeFence(map: any)
	local folder = Geo.folder(map, "EdgeFence")
	local r = Layout.IslandRadius - 5
	local seg = 64
	for i = 0, seg - 1 do
		local a0 = i / seg * 360
		local a1 = (i + 1) / seg * 360
		Props.fence(folder, Geo.polar(r, a0, 0), Geo.polar(r, a1, 0), rgb(246, 242, 234), 3.4)
		-- invisible safety wall so nobody walks off the island by accident
		local mid = Geo.polar(r + 1.5, (a0 + a1) / 2, 14)
		local len = 2 * math.pi * r / seg + 1
		Geo.part(folder, "Wall", CFrame.new(mid) * CFrame.Angles(0, rad((a0 + a1) / 2), 0), V3(1, 28, len), rgb(255, 255, 255), "SmoothPlastic", {
			Transparency = 1, CanQuery = false, CastShadow = false,
		})
	end
end

local function nearPath(angle: number, tolerance: number): boolean
	for _, a in Layout.PlotAngles do
		local d = math.abs(((angle - a + 180) % 360) - 180)
		if d < tolerance then
			return true
		end
	end
	return false
end

local function farFrom(pos: any, list: { any }, dist: number): boolean
	for _, p in list do
		if (V3(p.X, 0, p.Z) - V3(pos.X, 0, pos.Z)).Magnitude < dist then
			return false
		end
	end
	return true
end

local function starterYard(map: any)
	local yard = Geo.model(map, "StarterYard")
	local decor = Geo.folder(yard, "Decor")
	local spawns = Geo.folder(yard, "NodeSpawns")
	local taken = {}

	-- trees and bushes first (they claim space)
	local trees = {}
	for i = 1, 44 do
		for attempt = 1, 30 do
			local a = Geo.rand(0, 360)
			local r = Geo.rand(Layout.HubRadius + 18, Layout.RoadRadius - 22)
			local pos = Geo.polar(r, a, 0)
			if not nearPath(a, 9) and farFrom(pos, trees, 26) then
				table.insert(trees, pos)
				table.insert(taken, pos)
				Props.tree(decor, CFrame.new(pos) * CFrame.Angles(0, rad(Geo.rand(0, 360)), 0), Geo.rand(0.85, 1.25))
				break
			end
		end
	end
	for i = 1, 40 do
		local a = Geo.rand(0, 360)
		local r = Geo.rand(Layout.HubRadius + 10, Layout.RoadRadius - 14)
		local pos = Geo.polar(r, a, 0)
		if not nearPath(a, 7) and farFrom(pos, taken, 9) then
			Props.bush(decor, CFrame.new(pos) * CFrame.Angles(0, rad(Geo.rand(0, 360)), 0), Geo.rand(0.8, 1.3))
		end
	end

	-- node spawn points
	local points = {}
	for i = 1, 400 do
		if #points >= 52 then
			break
		end
		local a = Geo.rand(0, 360)
		local r = Geo.rand(Layout.HubRadius + 14, Layout.RoadRadius - 18)
		local pos = Geo.polar(r, a, 0.5)
		if not nearPath(a, 6) and farFrom(pos, taken, 11) and farFrom(pos, points, 13) then
			table.insert(points, pos)
			Geo.marker(spawns, "Spawn", CFrame.new(pos) * CFrame.Angles(0, rad(Geo.rand(0, 360)), 0), V3(4, 1, 4))
		end
	end

	-- bounds (used by the server to know who is in the zone)
	local bounds = Geo.marker(yard, "Bounds", CFrame.new(0, 20, 0), V3(Layout.IslandRadius * 2, 60, Layout.IslandRadius * 2))
	Geo.attr(bounds, { Shape = "Cylinder" })
	Geo.attr(yard, { ZoneId = "StarterYard" })

	-- a little junk corner and some benches for character
	for i, a in { 12, 102, 192, 282 } do
		local pos = Geo.polar(Layout.RoadRadius - 20, a, 0)
		local cf = CFrame.new(pos) * CFrame.Angles(0, rad(a + 90), 0)
		Props.bench(decor, cf * CFrame.new(0, 0, 0))
		Props.lamp(decor, CFrame.new(Geo.polar(Layout.RoadRadius - 13, a + 4, 0)) * CFrame.Angles(0, rad(a - 90), 0))
	end
	return yard
end

local function roadLamps(map: any)
	local folder = Geo.folder(map, "RoadLamps")
	for i = 0, 31 do
		local a = i / 32 * 360 + 5.625
		if not nearPath(a, 6) then
			local pos = Geo.polar(Layout.RoadRadius + Layout.RoadWidth / 2 + 3, a, 0)
			Props.lamp(folder, CFrame.new(pos) * CFrame.Angles(0, rad(a + 90), 0))
		end
	end
end

local function outerDecor(map: any)
	local folder = Geo.folder(map, "OuterDecor")
	-- trees between plots and near the edge
	for k = 0, 7 do
		local between = 45 * k
		for j = 1, 4 do
			local a = between + Geo.rand(-5, 5)
			local r = Geo.rand(252, 370)
			Props.tree(folder, CFrame.new(Geo.polar(r, a, 0)) * CFrame.Angles(0, rad(Geo.rand(0, 360)), 0), Geo.rand(0.9, 1.4))
		end
		for j = 1, 3 do
			local a = between + Geo.rand(-7, 7)
			Props.bush(folder, CFrame.new(Geo.polar(Geo.rand(240, 372), a, 0)), Geo.rand(0.9, 1.4))
		end
		Props.rock(folder, CFrame.new(Geo.polar(Geo.rand(300, 368), between + Geo.rand(-4, 4), 0)), Geo.rand(1, 1.8))
	end
end

function World.Build(game: any, map: any)
	setupLighting(game)
	ground(map)
	clouds(map)
	miniIslands(map)
	roads(map)
	edgeFence(map)
	roadLamps(map)
	outerDecor(map)
	return starterYard(map)
end

return World
