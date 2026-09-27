--[[
	Props - reusable decorative models (trees, rocks, lamps, crates, cars...).
	Every function builds at a CFrame (the prop's ground point) and returns the Model.
]]

local roblox = require("@lune/roblox")
local Geo = require("../lib/Geo")

local CFrame = roblox.CFrame
local V3 = Geo.V3
local rgb = Geo.rgb
local rad = math.rad

local Props = {}

local LEAF = { rgb(92, 178, 76), rgb(76, 162, 70), rgb(118, 192, 84), rgb(64, 146, 72) }

function Props.tree(parent: any, cf: any, scale: number?, palette: { any }?)
	local s = scale or 1
	local m = Geo.model(parent, "Tree")
	local trunkH = 9 * s
	Geo.cyl(m, "Trunk", cf * CFrame.new(0, trunkH / 2, 0) * CFrame.Angles(0, 0, rad(90)), trunkH, 1.8 * s, rgb(120, 84, 56), "Wood")
	local leaves = palette or LEAF
	local c = Geo.pick(leaves)
	Geo.ball(m, "Leaves", cf * CFrame.new(0, trunkH + 3 * s, 0), 11 * s, c, "Grass", { CastShadow = true })
	Geo.ball(m, "Leaves", cf * CFrame.new(2.8 * s, trunkH + 0.5 * s, 1.5 * s), 7.5 * s, Geo.darken(c, 0.08), "Grass")
	Geo.ball(m, "Leaves", cf * CFrame.new(-2.6 * s, trunkH + 1 * s, -1.8 * s), 7 * s, Geo.lighten(c, 0.06), "Grass")
	Geo.ball(m, "Leaves", cf * CFrame.new(0.4 * s, trunkH + 7 * s, 0.2 * s), 6 * s, Geo.lighten(c, 0.1), "Grass")
	return m
end

function Props.pine(parent: any, cf: any, scale: number?, snowy: boolean?)
	local s = scale or 1
	local m = Geo.model(parent, "Pine")
	Geo.cyl(m, "Trunk", cf * CFrame.new(0, 3 * s, 0) * CFrame.Angles(0, 0, rad(90)), 6 * s, 1.4 * s, rgb(104, 72, 50), "Wood")
	local green = rgb(46, 110, 74)
	for i = 0, 3 do
		local d = (12 - i * 2.6) * s
		local y = (5 + i * 3.4) * s
		Geo.disc(m, "Layer", cf * CFrame.new(0, y, 0), d, 3.2 * s, snowy and (i % 2 == 0 and rgb(236, 244, 250) or green) or Geo.lighten(green, i * 0.05), snowy and "Snow" or "Grass")
	end
	Geo.ball(m, "Top", cf * CFrame.new(0, 18.5 * s, 0), 2.6 * s, snowy and rgb(240, 248, 255) or rgb(70, 140, 90), snowy and "Snow" or "Grass")
	return m
end

function Props.bush(parent: any, cf: any, scale: number?)
	local s = scale or 1
	local m = Geo.model(parent, "Bush")
	local c = Geo.pick(LEAF)
	Geo.ball(m, "Leaf", cf * CFrame.new(0, 1.6 * s, 0), 4.4 * s, c, "Grass")
	Geo.ball(m, "Leaf", cf * CFrame.new(1.8 * s, 1.2 * s, 0.6 * s), 3.4 * s, Geo.lighten(c, 0.06), "Grass")
	Geo.ball(m, "Leaf", cf * CFrame.new(-1.6 * s, 1.1 * s, -0.4 * s), 3.2 * s, Geo.darken(c, 0.06), "Grass")
	if Geo.rand() < 0.5 then
		local flower = Geo.pick({ rgb(255, 120, 150), rgb(255, 220, 90), rgb(255, 255, 255), rgb(190, 140, 255) })
		for i = 1, 4 do
			Geo.ball(m, "Flower", cf * CFrame.new(Geo.rand(-2, 2) * s, (2.6 + Geo.rand(0, 1)) * s, Geo.rand(-1.5, 1.5) * s), 0.7 * s, flower, "SmoothPlastic")
		end
	end
	return m
end

function Props.rock(parent: any, cf: any, scale: number?, color: any?, mat: string?)
	local s = scale or 1
	local m = Geo.model(parent, "Rock")
	local c = color or rgb(138, 138, 146)
	local count = 2 + math.floor(Geo.rand() * 3)
	for i = 1, count do
		local size = V3(Geo.rand(3, 6) * s, Geo.rand(2, 4.5) * s, Geo.rand(3, 6) * s)
		local off = CFrame.new(Geo.rand(-2, 2) * s, size.Y * 0.35, Geo.rand(-2, 2) * s)
		local rot = CFrame.Angles(rad(Geo.rand(-18, 18)), rad(Geo.rand(0, 360)), rad(Geo.rand(-18, 18)))
		Geo.box(m, "Stone", cf * off * rot, size, Geo.lerpColor(c, rgb(90, 90, 96), Geo.rand(0, 0.3)), mat or "Slate")
	end
	return m
end

function Props.lamp(parent: any, cf: any, color: any?)
	local m = Geo.model(parent, "Lamp")
	local pole = rgb(52, 56, 66)
	Geo.disc(m, "Base", cf * CFrame.new(0, 0.5, 0), 2.4, 1, pole, "Metal")
	Geo.cyl(m, "Pole", cf * CFrame.new(0, 6.5, 0) * CFrame.Angles(0, 0, rad(90)), 12, 0.6, pole, "Metal")
	Geo.box(m, "Arm", cf * CFrame.new(0, 12.6, -1.2), V3(0.5, 0.5, 2.8), pole, "Metal")
	Geo.box(m, "Cap", cf * CFrame.new(0, 12.9, -2.6), V3(2.2, 0.6, 2.2), pole, "Metal")
	local bulb = Geo.box(m, "Bulb", cf * CFrame.new(0, 12.2, -2.6), V3(1.6, 0.8, 1.6), color or rgb(255, 226, 160), "Neon")
	Geo.light(bulb, "PointLight", color or rgb(255, 214, 150), 1.4, 22)
	return m
end

function Props.bench(parent: any, cf: any)
	local m = Geo.model(parent, "Bench")
	local wood = rgb(176, 124, 78)
	local iron = rgb(58, 60, 68)
	Geo.box(m, "Seat", cf * CFrame.new(0, 1.9, 0), V3(7, 0.4, 2.2), wood, "WoodPlanks")
	Geo.box(m, "Back", cf * CFrame.new(0, 3.2, 1.0) * CFrame.Angles(rad(-12), 0, 0), V3(7, 1.6, 0.35), wood, "WoodPlanks")
	for _, x in { -3, 3 } do
		Geo.box(m, "Leg", cf * CFrame.new(x, 0.95, 0), V3(0.4, 1.9, 2), iron, "Metal")
	end
	return m
end

function Props.fence(parent: any, a: any, b: any, color: any?, height: number?)
	local m = Geo.model(parent, "Fence")
	local c = color or rgb(244, 240, 232)
	local h = height or 3.2
	local delta = b - a
	local len = delta.Magnitude
	local mid = a + delta / 2
	local cf = CFrame.lookAt(mid, b)
	Geo.box(m, "RailTop", cf * CFrame.new(0, h - 0.6, 0), V3(0.35, 0.4, len), c, "WoodPlanks")
	Geo.box(m, "RailLow", cf * CFrame.new(0, h * 0.45, 0), V3(0.35, 0.4, len), c, "WoodPlanks")
	local posts = math.max(1, math.floor(len / 6))
	for i = 0, posts do
		local p = a + delta * (i / posts)
		Geo.box(m, "Post", CFrame.lookAt(p, p + delta) * CFrame.new(0, h / 2, 0), V3(0.7, h, 0.7), c, "WoodPlanks")
	end
	return m
end

function Props.crate(parent: any, cf: any, size: number?, color: any?)
	local s = size or 3
	local m = Geo.model(parent, "Crate")
	local c = color or rgb(196, 146, 88)
	Geo.box(m, "Box", cf * CFrame.new(0, s / 2, 0), V3(s, s, s), c, "WoodPlanks")
	local edge = Geo.darken(c, 0.3)
	for _, y in { 0.08, s - 0.08 } do
		Geo.box(m, "Band", cf * CFrame.new(0, y, 0), V3(s + 0.1, 0.25, s + 0.1), edge, "Wood")
	end
	return m
end

function Props.barrel(parent: any, cf: any, color: any?, glow: any?)
	local m = Geo.model(parent, "Barrel")
	local c = color or rgb(70, 110, 170)
	Geo.disc(m, "Body", cf * CFrame.new(0, 2, 0), 2.8, 4, c, "Metal")
	for _, y in { 0.7, 3.3 } do
		Geo.disc(m, "Ring", cf * CFrame.new(0, y, 0), 2.95, 0.3, Geo.darken(c, 0.35), "Metal")
	end
	if glow then
		local top = Geo.disc(m, "Goo", cf * CFrame.new(0, 4.02, 0), 2.3, 0.08, glow, "Neon")
		Geo.light(top, "PointLight", glow, 1, 10)
	end
	return m
end

function Props.tire(parent: any, cf: any, scale: number?)
	local s = scale or 1
	local m = Geo.model(parent, "Tire")
	Geo.disc(m, "Rubber", cf * CFrame.new(0, 0.7 * s, 0), 4 * s, 1.4 * s, rgb(40, 42, 48), "Rubber")
	Geo.disc(m, "Hole", cf * CFrame.new(0, 0.72 * s, 0), 2 * s, 1.46 * s, rgb(20, 20, 24), "SmoothPlastic")
	return m
end

function Props.car(parent: any, cf: any, color: any?, wrecked: boolean?)
	local m = Geo.model(parent, "Car")
	local c = color or rgb(200, 70, 60)
	local body = wrecked and Geo.lerpColor(c, rgb(120, 80, 60), 0.45) or c
	local mat = wrecked and "CorrodedMetal" or "SmoothPlastic"
	Geo.box(m, "Body", cf * CFrame.new(0, 2.1, 0), V3(6.4, 2.2, 13), body, mat)
	Geo.box(m, "Cabin", cf * CFrame.new(0, 4, 0.8), V3(5.8, 1.9, 6.6), Geo.darken(body, 0.05), mat)
	Geo.box(m, "Window", cf * CFrame.new(0, 4.05, 0.8), V3(5.9, 1.3, 5.4), rgb(120, 170, 200), "Glass", { Transparency = 0.3 })
	for _, x in { -3, 3 } do
		for _, z in { -4.2, 4.2 } do
			Geo.cyl(m, "Wheel", cf * CFrame.new(x, 1.2, z), 1, 2.6, rgb(30, 30, 34), "Rubber")
		end
	end
	Geo.box(m, "LightL", cf * CFrame.new(-2.2, 2.3, -6.55), V3(1.2, 0.6, 0.2), rgb(255, 240, 200), "Neon")
	Geo.box(m, "LightR", cf * CFrame.new(2.2, 2.3, -6.55), V3(1.2, 0.6, 0.2), rgb(255, 240, 200), "Neon")
	return m
end

-- Crystal cluster: a few tall glowing crystals leaning out of a rock base
function Props.crystals(parent: any, cf: any, color: any, scale: number?, withLight: boolean?)
	local s = scale or 1
	local m = Geo.model(parent, "Crystals")
	Geo.box(m, "Base", cf * CFrame.new(0, 0.6 * s, 0) * CFrame.Angles(0, rad(Geo.rand(0, 90)), 0), V3(4 * s, 1.2 * s, 4 * s), Geo.darken(color, 0.6), "Slate")
	local count = 3 + math.floor(Geo.rand() * 3)
	for i = 1, count do
		local h = Geo.rand(4, 9) * s
		local w = Geo.rand(1, 1.8) * s
		local lean = CFrame.Angles(rad(Geo.rand(-25, 25)), rad(Geo.rand(0, 360)), rad(Geo.rand(-25, 25)))
		local base = cf * CFrame.new(Geo.rand(-1.2, 1.2) * s, 0.6 * s, Geo.rand(-1.2, 1.2) * s) * lean
		Geo.box(m, "Crystal", base * CFrame.new(0, h / 2, 0) * CFrame.Angles(0, rad(45), 0), V3(w, h, w), color, "Glass", { Transparency = 0.15, Reflectance = 0.2 })
		Geo.box(m, "Core", base * CFrame.new(0, h / 2, 0) * CFrame.Angles(0, rad(45), 0), V3(w * 0.45, h * 0.85, w * 0.45), Geo.lighten(color, 0.35), "Neon")
		Geo.box(m, "Tip", base * CFrame.new(0, h + w * 0.28, 0) * CFrame.Angles(rad(45), rad(45), 0), V3(w * 0.72, w * 0.72, w * 0.72), color, "Glass", { Transparency = 0.1 })
	end
	if withLight ~= false then
		local anchor = Geo.marker(m, "Glow", cf * CFrame.new(0, 4 * s, 0))
		Geo.light(anchor, "PointLight", color, 1.2, 16 * s)
	end
	return m
end

function Props.pipe(parent: any, a: any, b: any, diameter: number, color: any)
	local delta = b - a
	local cf = CFrame.lookAt(a + delta / 2, b) * CFrame.Angles(0, rad(90), 0)
	return Geo.cyl(parent, "Pipe", cf, delta.Magnitude, diameter, color, "Metal")
end

function Props.sign(parent: any, cf: any, text: string, bg: any, fg: any, width: number?, height: number?)
	local w = width or 10
	local h = height or 3
	local m = Geo.model(parent, "Sign")
	local post = rgb(70, 60, 54)
	Geo.box(m, "PostL", cf * CFrame.new(-w / 2 + 0.6, h / 2 + 1.5, 0), V3(0.5, h + 3, 0.5), post, "Wood")
	Geo.box(m, "PostR", cf * CFrame.new(w / 2 - 0.6, h / 2 + 1.5, 0), V3(0.5, h + 3, 0.5), post, "Wood")
	local board = Geo.box(m, "Board", cf * CFrame.new(0, h / 2 + 3, 0), V3(w, h, 0.4), bg, "SmoothPlastic")
	Geo.surfaceText(board, "Front", text, fg)
	Geo.surfaceText(board, "Back", text, fg)
	return m
end

return Props
