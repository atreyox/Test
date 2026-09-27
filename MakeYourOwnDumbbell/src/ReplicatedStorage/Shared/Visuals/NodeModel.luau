--[[
	NodeModel - builds the smashable material node you see in the world
	(a stack of tires, a plastic crate, an iron ore rock, a glowing crystal...).

	local model = NodeModel.Build(materialId, mutationId, cframe, seed)
	The model's PrimaryPart is "Hitbox" (invisible, used for clicks/taps and distance).
	Visible parts are anchored and collide, so players bump into nodes like real objects.
]]

local Shared = script.Parent.Parent
local Materials = require(Shared.Config.Materials)
local Rarities = require(Shared.Config.Rarities)
local Parts = require(script.Parent.Parts)
local MutationFx = require(script.Parent.MutationFx)

local NodeModel = {}

local rad = math.rad

local function darker(c: Color3, t: number): Color3
	return c:Lerp(Color3.new(0, 0, 0), t)
end

local function lighter(c: Color3, t: number): Color3
	return c:Lerp(Color3.new(1, 1, 1), t)
end

type Ctx = {
	model: Model,
	cf: CFrame,
	mat: any,
	rng: (number?, number?) -> number,
	s: number,
	main: { BasePart },
}

local function solid(p: BasePart): BasePart
	p.Anchored = true
	p.CanCollide = true
	p.Massless = false
	return p
end

local function add(ctx: Ctx, p: BasePart, isMain: boolean?): BasePart
	solid(p)
	if isMain ~= false then
		table.insert(ctx.main, p)
	end
	return p
end

local function styled(p: BasePart, mat: any): BasePart
	p.Material = Parts.material(mat.Material)
	if mat.Reflectance then
		p.Reflectance = mat.Reflectance
	end
	if mat.Transparency then
		p.Transparency = mat.Transparency
	end
	return p
end

local STYLE = {}

function STYLE.Tire(c: Ctx)
	local n = 2 + math.floor(c.rng() * 2)
	for i = 1, n do
		local off = CFrame.new(c.rng(-0.4, 0.4) * c.s, (0.65 + (i - 1) * 1.3) * c.s, c.rng(-0.4, 0.4) * c.s) * CFrame.Angles(0, rad(c.rng(0, 360)), 0)
		add(c, styled(Parts.disc(c.model, "Tire", c.cf * off, 4.2 * c.s, 1.3 * c.s, c.mat.Color, nil, true), c.mat))
		add(c, Parts.disc(c.model, "Hole", c.cf * off, 2.1 * c.s, 1.36 * c.s, Color3.fromRGB(18, 18, 22), Enum.Material.SmoothPlastic, true), false)
	end
end

local CRATE_COLORS = {
	Color3.fromRGB(255, 92, 76), Color3.fromRGB(70, 150, 255), Color3.fromRGB(255, 208, 60), Color3.fromRGB(90, 210, 110),
}

function STYLE.Crate(c: Ctx)
	local col = CRATE_COLORS[math.floor(c.rng() * #CRATE_COLORS) + 1]
	local stack = c.rng() < 0.4 and 2 or 1
	for i = 1, stack do
		local cf = c.cf * CFrame.new(0, (1.3 + (i - 1) * 2.6) * c.s, 0) * CFrame.Angles(0, rad(c.rng(-20, 20)), 0)
		add(c, Parts.part(c.model, "Crate", cf, Vector3.new(3.6, 2.6, 3.6) * c.s, col, Enum.Material.SmoothPlastic, true))
		local rim = darker(col, 0.25)
		for _, z in { -1.75, 1.75 } do
			add(c, Parts.part(c.model, "Rim", cf * CFrame.new(0, 1.2 * c.s, z * c.s), Vector3.new(3.7, 0.3, 0.25) * c.s, rim, Enum.Material.SmoothPlastic, true), false)
			add(c, Parts.part(c.model, "Rim", cf * CFrame.new(z * c.s, 1.2 * c.s, 0), Vector3.new(0.25, 0.3, 3.7) * c.s, rim, Enum.Material.SmoothPlastic, true), false)
		end
		add(c, Parts.part(c.model, "Slot", cf * CFrame.new(0, 0.5 * c.s, -1.81 * c.s), Vector3.new(1.4, 0.45, 0.05) * c.s, darker(col, 0.5), Enum.Material.SmoothPlastic, true), false)
	end
end

function STYLE.Logs(c: Ctx)
	local wood = c.mat.Color
	local ends = c.mat.Color2
	local positions = { { -0.8, 0.8 }, { 0.8, 0.8 }, { 0, 2.1 } }
	local yaw = CFrame.Angles(0, rad(c.rng(0, 180)), 0)
	for _, p in positions do
		local cf = c.cf * yaw * CFrame.new(0, p[2] * c.s, p[1] * c.s)
		add(c, styled(Parts.cyl(c.model, "Log", cf, 5 * c.s, 1.6 * c.s, wood, nil, true), c.mat))
		for _, x in { -2.52, 2.52 } do
			add(c, Parts.cyl(c.model, "End", cf * CFrame.new(x * c.s, 0, 0), 0.06 * c.s, 1.4 * c.s, ends, Enum.Material.Wood, true), false)
		end
	end
end

local function rockCluster(c: Ctx, color: Color3, material: Enum.Material, count: number, scale: number)
	local list = {}
	for i = 1, count do
		local size = Vector3.new(c.rng(2.2, 3.6), c.rng(1.8, 3), c.rng(2.2, 3.6)) * c.s * scale
		local off = CFrame.new(c.rng(-1, 1) * c.s, size.Y * 0.38, c.rng(-1, 1) * c.s)
		local rot = CFrame.Angles(rad(c.rng(-20, 20)), rad(c.rng(0, 360)), rad(c.rng(-20, 20)))
		local p = Parts.part(c.model, "Stone", c.cf * off * rot, size, color:Lerp(darker(color, 0.3), c.rng(0, 0.6)), material, true)
		table.insert(list, p)
	end
	return list
end

function STYLE.Rock(c: Ctx)
	for _, p in rockCluster(c, c.mat.Color, Parts.material(c.mat.Material), 4, 1.05) do
		add(c, p)
	end
end

function STYLE.Ore(c: Ctx)
	local stone = c.mat.Color2
	for _, p in rockCluster(c, stone, Enum.Material.Slate, 3, 1) do
		add(c, p, false)
	end
	local chunks = 5 + math.floor(c.rng() * 3)
	for i = 1, chunks do
		local a = (i / chunks) * 360 + c.rng(-20, 20)
		local r = c.rng(1, 1.9) * c.s
		local cf = c.cf * CFrame.Angles(0, rad(a), 0) * CFrame.new(r, c.rng(1.4, 3) * c.s, 0) * CFrame.Angles(rad(c.rng(0, 90)), rad(c.rng(0, 90)), rad(c.rng(0, 90)))
		local size = Vector3.new(c.rng(0.9, 1.5), c.rng(0.9, 1.5), c.rng(0.9, 1.5)) * c.s
		add(c, styled(Parts.part(c.model, "Ore", cf, size, c.mat.Color, nil, true), c.mat))
	end
end

function STYLE.Scrap(c: Ctx)
	local rust = c.mat.Color
	local steel = c.mat.Color2
	for i = 1, 6 do
		local size = Vector3.new(c.rng(1.2, 3), c.rng(0.4, 1.4), c.rng(1.2, 3)) * c.s
		local cf = c.cf * CFrame.new(c.rng(-1.4, 1.4) * c.s, (0.4 + i * 0.35) * c.s, c.rng(-1.4, 1.4) * c.s) * CFrame.Angles(rad(c.rng(-35, 35)), rad(c.rng(0, 360)), rad(c.rng(-35, 35)))
		local p = Parts.part(c.model, "Scrap", cf, size, i % 2 == 0 and rust or steel, i % 2 == 0 and Enum.Material.CorrodedMetal or Enum.Material.Metal, true)
		add(c, p, i % 2 == 0)
	end
	add(c, Parts.cyl(c.model, "Pipe", c.cf * CFrame.new(0, 1.2 * c.s, 0) * CFrame.Angles(0, rad(c.rng(0, 180)), rad(25)), 4 * c.s, 0.6 * c.s, steel, Enum.Material.Metal, true), false)
end

function STYLE.Beam(c: Ctx)
	local col = c.mat.Color
	local yaw = CFrame.Angles(0, rad(c.rng(0, 180)), 0)
	for i = 0, 2 do
		local cf = c.cf * yaw * CFrame.new((i - 1) * 1.3 * c.s, (0.5 + (i % 2) * 1.05) * c.s, c.rng(-0.4, 0.4) * c.s)
		if i == 2 then
			cf = c.cf * yaw * CFrame.new(0, 1.6 * c.s, 0) * CFrame.Angles(0, rad(90), 0)
		end
		add(c, styled(Parts.part(c.model, "Web", cf, Vector3.new(0.3, 1, 5.2) * c.s, col, nil, true), c.mat))
		add(c, styled(Parts.part(c.model, "Flange", cf * CFrame.new(0, 0.5 * c.s, 0), Vector3.new(1.1, 0.22, 5.2) * c.s, darker(col, 0.08), nil, true), c.mat))
		add(c, styled(Parts.part(c.model, "Flange", cf * CFrame.new(0, -0.5 * c.s, 0), Vector3.new(1.1, 0.22, 5.2) * c.s, darker(col, 0.08), nil, true), c.mat))
	end
end

function STYLE.Spool(c: Ctx)
	local cf = c.cf * CFrame.new(0, 1.9 * c.s, 0) * CFrame.Angles(0, rad(c.rng(0, 180)), 0)
	add(c, styled(Parts.cyl(c.model, "Wrap", cf, 3 * c.s, 3 * c.s, c.mat.Color, nil, true), c.mat))
	for _, x in { -1.6, 1.6 } do
		add(c, Parts.cyl(c.model, "Flange", cf * CFrame.new(x * c.s, 0, 0), 0.3 * c.s, 3.8 * c.s, c.mat.Color2, Enum.Material.Metal, true), false)
	end
	add(c, Parts.cyl(c.model, "Axle", cf, 3.8 * c.s, 0.6 * c.s, Color3.fromRGB(200, 200, 210), Enum.Material.Metal, true), false)
end

function STYLE.Nugget(c: Ctx)
	for _, p in rockCluster(c, c.mat.Color2, Enum.Material.Slate, 3, 0.9) do
		add(c, p, false)
	end
	for i = 1, 7 do
		local a = (i / 7) * 360
		local cf = c.cf * CFrame.Angles(0, rad(a), 0) * CFrame.new(c.rng(0.5, 1.8) * c.s, c.rng(1.6, 3) * c.s, 0)
		add(c, styled(Parts.ball(c.model, "Nugget", cf, c.rng(0.8, 1.5) * c.s, c.mat.Color, nil, true), c.mat))
	end
end

function STYLE.Shard(c: Ctx)
	add(c, Parts.part(c.model, "Base", c.cf * CFrame.new(0, 0.4 * c.s, 0) * CFrame.Angles(0, rad(c.rng(0, 90)), 0), Vector3.new(3.4, 0.8, 3.4) * c.s, darker(c.mat.Color, 0.4), Enum.Material.Slate, true), false)
	for i = 1, 3 do
		local a = i * 120 + c.rng(-20, 20)
		local h = c.rng(3.5, 5.5) * c.s
		local cf = c.cf * CFrame.Angles(0, rad(a), 0) * CFrame.new(0.9 * c.s, 0.8 * c.s + h / 2, 0) * CFrame.Angles(rad(c.rng(-12, 12)), 0, rad(c.rng(-15, 5)))
		add(c, styled(Parts.part(c.model, "Shard", cf * CFrame.Angles(0, rad(45), 0), Vector3.new(1.2 * c.s, h, 1.2 * c.s), c.mat.Color, nil, true), c.mat))
		if c.mat.Glow then
			add(c, Parts.part(c.model, "Core", cf * CFrame.Angles(0, rad(45), 0), Vector3.new(0.45 * c.s, h * 0.8, 0.45 * c.s), c.mat.Color2, Enum.Material.Neon, true), false)
		end
	end
end

function STYLE.Crystal(c: Ctx)
	add(c, Parts.part(c.model, "Base", c.cf * CFrame.new(0, 0.5 * c.s, 0) * CFrame.Angles(0, rad(c.rng(0, 90)), 0), Vector3.new(3.6, 1, 3.6) * c.s, darker(c.mat.Color, 0.55), Enum.Material.Slate, true), false)
	local count = 4 + math.floor(c.rng() * 2)
	for i = 1, count do
		local h = c.rng(2.6, 5) * c.s
		local w = c.rng(0.9, 1.4) * c.s
		local lean = CFrame.Angles(rad(c.rng(-28, 28)), rad(c.rng(0, 360)), rad(c.rng(-28, 28)))
		local base = c.cf * CFrame.new(c.rng(-0.9, 0.9) * c.s, 0.8 * c.s, c.rng(-0.9, 0.9) * c.s) * lean
		add(c, styled(Parts.part(c.model, "Crystal", base * CFrame.new(0, h / 2, 0) * CFrame.Angles(0, rad(45), 0), Vector3.new(w, h, w), c.mat.Color, nil, true), c.mat))
		add(c, styled(Parts.part(c.model, "Tip", base * CFrame.new(0, h + w * 0.25, 0) * CFrame.Angles(rad(45), rad(45), 0), Vector3.new(w * 0.7, w * 0.7, w * 0.7), lighter(c.mat.Color, 0.1), nil, true), c.mat))
		if c.mat.Glow then
			add(c, Parts.part(c.model, "Core", base * CFrame.new(0, h / 2, 0) * CFrame.Angles(0, rad(45), 0), Vector3.new(w * 0.4, h * 0.85, w * 0.4), lighter(c.mat.Color2, 0.2), Enum.Material.Neon, true), false)
		end
	end
end

function STYLE.Ice(c: Ctx)
	for i = 1, 4 do
		local size = Vector3.new(c.rng(1.8, 3), c.rng(1.8, 3.4), c.rng(1.8, 3)) * c.s
		local cf = c.cf * CFrame.new(c.rng(-1, 1) * c.s, size.Y * 0.45 + (i > 2 and 1.2 * c.s or 0), c.rng(-1, 1) * c.s) * CFrame.Angles(rad(c.rng(-15, 15)), rad(c.rng(0, 360)), rad(c.rng(-15, 15)))
		add(c, styled(Parts.part(c.model, "Ice", cf, size, c.mat.Color:Lerp(c.mat.Color2, c.rng(0, 0.5)), nil, true), c.mat))
	end
end

function STYLE.Barrel(c: Ctx)
	local n = 2 + math.floor(c.rng() * 2)
	for i = 1, n do
		local a = (i / n) * 360
		local cf = c.cf * CFrame.Angles(0, rad(a), 0) * CFrame.new(n > 1 and 1.2 * c.s or 0, 1.7 * c.s, 0)
		add(c, Parts.disc(c.model, "Barrel", cf, 2.4 * c.s, 3.4 * c.s, c.mat.Color2, Enum.Material.Metal, true), false)
		for _, y in { -1.1, 1.1 } do
			add(c, Parts.disc(c.model, "Band", cf * CFrame.new(0, y * c.s, 0), 2.5 * c.s, 0.25 * c.s, Color3.fromRGB(255, 208, 40), Enum.Material.SmoothPlastic, true), false)
		end
		add(c, styled(Parts.disc(c.model, "Goo", cf * CFrame.new(0, 1.72 * c.s, 0), 2 * c.s, 0.12 * c.s, c.mat.Color, nil, true), c.mat))
	end
end

function STYLE.Meteor(c: Ctx)
	local core = Parts.ball(c.model, "Meteor", c.cf * CFrame.new(0, 2 * c.s, 0), 4.2 * c.s, c.mat.Color, Parts.material(c.mat.Material), true)
	add(c, core)
	for i = 1, 5 do
		local cf = core.CFrame * CFrame.Angles(rad(c.rng(0, 360)), rad(c.rng(0, 360)), 0) * CFrame.new(0, 2.02 * c.s, 0)
		add(c, Parts.part(c.model, "Crack", cf, Vector3.new(0.25, 0.1, 2.2) * c.s, c.mat.Color2, Enum.Material.Neon, true), false)
	end
	for i = 1, 6 do
		local a = (i / 6) * 360
		add(c, Parts.part(c.model, "Debris", c.cf * CFrame.Angles(0, rad(a), 0) * CFrame.new(2.6 * c.s, 0.3 * c.s, 0) * CFrame.Angles(rad(c.rng(0, 60)), rad(c.rng(0, 90)), 0), Vector3.new(0.8, 0.6, 0.9) * c.s, darker(c.mat.Color, 0.3), Enum.Material.Basalt, true), false)
	end
	MutationFx.Emitter(core, {
		Texture = "rbxasset://textures/particles/smoke_main.dds",
		Color = ColorSequence.new(Color3.fromRGB(90, 80, 80)), LightEmission = 0, Rate = 3,
		Size = NumberSequence.new(1.2 * c.s, 2.5 * c.s), Speed = NumberRange.new(1, 2),
		Transparency = NumberSequence.new(0.5, 1), Lifetime = NumberRange.new(1.5, 2.5),
	})
end

function STYLE.Orb(c: Ctx)
	add(c, Parts.part(c.model, "Pedestal", c.cf * CFrame.new(0, 0.5 * c.s, 0) * CFrame.Angles(0, rad(c.rng(0, 90)), 0), Vector3.new(2.6, 1, 2.6) * c.s, darker(c.mat.Color2, 0.5), Enum.Material.Slate, true), false)
	local orb = add(c, styled(Parts.ball(c.model, "Orb", c.cf * CFrame.new(0, 3 * c.s, 0), 3 * c.s, c.mat.Color, nil, true), c.mat))
	add(c, Parts.cyl(c.model, "Ring", orb.CFrame * CFrame.Angles(0, 0, rad(90)) * CFrame.Angles(rad(25), 0, 0), 0.12 * c.s, 4.4 * c.s, c.mat.Color2, Enum.Material.Neon, true), false)
end

function NodeModel.Build(materialId: string, mutationId: string?, cf: CFrame, seed: number?): Model
	local mat = Materials.ById[materialId] or Materials.ById.Rubber
	local rank = Rarities.Rank(mat.Rarity)
	local model = Instance.new("Model")
	model.Name = materialId
	local ctx: Ctx = {
		model = model,
		cf = cf,
		mat = mat,
		rng = Parts.rng(seed or 12345),
		s = 1 + (rank - 1) * 0.07,
		main = {},
	}
	local build = STYLE[mat.Node] or STYLE.Rock
	build(ctx)

	local hitbox = Parts.part(model, "Hitbox", cf * CFrame.new(0, 2.4 * ctx.s, 0), Vector3.new(5.5, 5, 5.5) * ctx.s, Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, true)
	hitbox.Transparency = 1
	hitbox.CanQuery = true
	hitbox.CastShadow = false
	model.PrimaryPart = hitbox

	if mat.Glow then
		local l = Instance.new("PointLight")
		l.Color = mat.Color
		l.Brightness = 1
		l.Range = 12
		l.Parent = hitbox
	end
	if mutationId then
		MutationFx.Apply(ctx.main, mutationId, hitbox, 2.6)
	end
	return model
end

return NodeModel
