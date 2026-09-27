--[[
	MutationFx - makes mutated materials look special, on world nodes and on dumbbells.

	MutationFx.Apply(parts, mutationId, emitterPart, scale)
		parts       : the parts to recolor (plates / node chunks)
		emitterPart : where particles, fire and lights attach
		scale       : size of the effect (1 = dumbbell-sized, 3-4 = world node)

	Some looks animate on the client (tags read by Controllers/FxController):
		"Rainbow" - hue cycling, "Glitch" - flickering colors, "Flicker" - lights flicker
]]

local Mutations = require(script.Parent.Parent.Config.Mutations)

local MutationFx = {}

local SPARKLES = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"
local FIRE = "rbxasset://textures/particles/fire_main.dds"

local function seq(a: number, b: number): NumberSequence
	return NumberSequence.new(a, b)
end

function MutationFx.Emitter(parent: Instance, props: { [string]: any }): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.Texture = SPARKLES
	e.LightEmission = 0.8
	e.LightInfluence = 0
	e.Rate = 6
	e.Lifetime = NumberRange.new(0.6, 1.2)
	e.Speed = NumberRange.new(0.5, 1.5)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Size = seq(0.4, 0)
	e.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.7, 0.4),
		NumberSequenceKeypoint.new(1, 1),
	})
	for k, v in props do
		(e :: any)[k] = v
	end
	e.Parent = parent
	return e
end

local function light(parent: Instance, color: Color3, brightness: number, range: number)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Brightness = brightness
	l.Range = range
	l.Shadows = false
	l.Parent = parent
	return l
end

local function tint(parts: { BasePart }, color: Color3, amount: number, material: Enum.Material?)
	for _, p in parts do
		p.Color = p.Color:Lerp(color, amount)
		if material then
			p.Material = material
		end
	end
end

local function tag(inst: Instance, name: string)
	pcall(function()
		inst:AddTag(name)
	end)
end

function MutationFx.Apply(parts: { BasePart }, mutationId: string?, emitterPart: BasePart, scale: number?)
	local m = Mutations.Get(mutationId)
	if not m or #parts == 0 then
		return
	end
	local s = scale or 1
	local fx = m.Fx
	local c1, c2 = m.Color, m.Color2

	if fx == "Sparkle" then
		for _, p in parts do
			p.Reflectance = math.max(p.Reflectance, 0.25)
		end
		tint(parts, c1, 0.15)
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(c1, c2), Rate = 5, Size = seq(0.35 * s, 0) })
	elseif fx == "Gold" then
		tint(parts, c1, 0.75, Enum.Material.Foil)
		for _, p in parts do
			p.Reflectance = 0.25
		end
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(c1, c2), Rate = 7, Size = seq(0.4 * s, 0) })
		light(emitterPart, c1, 0.8, 5 * s)
	elseif fx == "Frost" then
		tint(parts, c1, 0.6, Enum.Material.Ice)
		MutationFx.Emitter(emitterPart, {
			Color = ColorSequence.new(Color3.new(1, 1, 1)), Rate = 8, Size = seq(0.25 * s, 0.1 * s),
			Speed = NumberRange.new(0.2, 0.6), Acceleration = Vector3.new(0, -1.5, 0), Lifetime = NumberRange.new(1, 2),
		})
	elseif fx == "Fire" then
		tint(parts, c1, 0.35)
		local f = Instance.new("Fire")
		f.Size = 2.5 * s
		f.Heat = 4 * s
		f.Color = c1
		f.SecondaryColor = c2
		f.Parent = emitterPart
		light(emitterPart, c1, 1.2, 7 * s)
	elseif fx == "Electric" then
		tint(parts, c1, 0.3)
		MutationFx.Emitter(emitterPart, {
			Color = ColorSequence.new(c1, c2), Rate = 14, Lifetime = NumberRange.new(0.08, 0.2),
			Speed = NumberRange.new(4 * s, 8 * s), Size = seq(0.3 * s, 0.05 * s), LightEmission = 1,
		})
		local l = light(emitterPart, c1, 1.2, 6 * s)
		tag(l, "Flicker")
	elseif fx == "Toxic" then
		tint(parts, c1, 0.5)
		MutationFx.Emitter(emitterPart, {
			Color = ColorSequence.new(c1, c2), Rate = 6, Size = seq(0.3 * s, 0.5 * s),
			Speed = NumberRange.new(0.5, 1.2), Acceleration = Vector3.new(0, 1.5, 0), Texture = SPARKLES,
		})
		light(emitterPart, c1, 0.6, 5 * s)
	elseif fx == "Magnetic" then
		for i, p in parts do
			p.Color = p.Color:Lerp(i % 2 == 0 and c2 or c1, 0.6)
			p.Material = Enum.Material.Metal
		end
		MutationFx.Emitter(emitterPart, {
			Color = ColorSequence.new(c1, c2), Rate = 10, Size = seq(0.2 * s, 0.2 * s),
			Speed = NumberRange.new(0, 0), RotSpeed = NumberRange.new(200, 400), Lifetime = NumberRange.new(0.5, 1),
			Shape = Enum.ParticleEmitterShape.Sphere, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		})
	elseif fx == "Radioactive" then
		for i, p in parts do
			p.Color = p.Color:Lerp(c1, 0.7)
			if i % 2 == 1 then
				p.Material = Enum.Material.Neon
			end
		end
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(c1, c2), Rate = 9, Size = seq(0.45 * s, 0) })
		light(emitterPart, c1, 1.4, 8 * s)
	elseif fx == "Crystal" then
		tint(parts, c1, 0.55, Enum.Material.Glass)
		for _, p in parts do
			p.Transparency = math.max(p.Transparency, 0.2)
			p.Reflectance = 0.3
		end
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(c1, c2), Rate = 8, Size = seq(0.4 * s, 0) })
		light(emitterPart, c1, 0.8, 6 * s)
	elseif fx == "Shadow" then
		tint(parts, c1, 0.8)
		MutationFx.Emitter(emitterPart, {
			Texture = SMOKE, Color = ColorSequence.new(c1, c2), Rate = 8, LightEmission = 0,
			Size = seq(0.6 * s, 1.4 * s), Speed = NumberRange.new(0.3, 0.8), Lifetime = NumberRange.new(1, 1.8),
			Transparency = NumberSequence.new(0.4, 1),
		})
	elseif fx == "Corrupted" then
		tint(parts, c1, 0.7)
		for i, p in parts do
			if i % 2 == 0 then
				p.Material = Enum.Material.Neon
				p.Color = c2
			end
			tag(p, "Glitch")
		end
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(c2, c1), Rate = 10, Size = seq(0.3 * s, 0), Lifetime = NumberRange.new(0.2, 0.5) })
		light(emitterPart, c2, 1, 6 * s)
	elseif fx == "Void" then
		tint(parts, c2, 0.8)
		for i, p in parts do
			if i % 2 == 0 then
				p.Material = Enum.Material.Neon
				p.Color = c1
			end
		end
		MutationFx.Emitter(emitterPart, {
			Color = ColorSequence.new(c1, c2), Rate = 12, Size = seq(0.5 * s, 0),
			Speed = NumberRange.new(-2 * s, -1 * s), Lifetime = NumberRange.new(0.8, 1.4),
			Shape = Enum.ParticleEmitterShape.Sphere, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		})
		light(emitterPart, c1, 1.6, 8 * s)
	elseif fx == "Rainbow" then
		for _, p in parts do
			tag(p, "Rainbow")
			p.Material = Enum.Material.SmoothPlastic
			p.Reflectance = 0.15
		end
		MutationFx.Emitter(emitterPart, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 240, 80)),
				ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80, 220, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 90, 255)),
			}),
			Rate = 10, Size = seq(0.45 * s, 0),
		})
		light(emitterPart, Color3.fromRGB(255, 200, 255), 1, 6 * s)
	elseif fx == "Glitched" then
		for i, p in parts do
			p.Material = Enum.Material.Neon
			p.Color = i % 2 == 0 and c1 or c2
			tag(p, "Glitch")
		end
		MutationFx.Emitter(emitterPart, {
			Color = ColorSequence.new(c1, c2), Rate = 16, Size = seq(0.35 * s, 0.35 * s),
			Lifetime = NumberRange.new(0.1, 0.3), Speed = NumberRange.new(2, 5), RotSpeed = NumberRange.new(0, 0),
		})
	elseif fx == "Cosmic" then
		tint(parts, c1, 0.75)
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(c2, Color3.fromRGB(140, 180, 255)), Rate = 14, Size = seq(0.3 * s, 0), Lifetime = NumberRange.new(1, 2), Speed = NumberRange.new(0.2, 0.6) })
		light(emitterPart, Color3.fromRGB(120, 140, 255), 1.4, 8 * s)
	elseif fx == "Celestial" then
		for i, p in parts do
			p.Color = p.Color:Lerp(c1, 0.8)
			p.Material = i % 2 == 0 and Enum.Material.Neon or Enum.Material.Foil
			p.Reflectance = 0.2
			tag(p, "Celestial")
		end
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(c1, c2), Rate = 16, Size = seq(0.55 * s, 0), Lifetime = NumberRange.new(1, 1.8), Speed = NumberRange.new(0.5, 2) })
		light(emitterPart, c2, 2, 10 * s)
	elseif fx == "Spooky" then
		tint(parts, c1, 0.6)
		MutationFx.Emitter(emitterPart, { Texture = SMOKE, Color = ColorSequence.new(c2, c1), Rate = 6, LightEmission = 0.3, Size = seq(0.5 * s, 1.2 * s), Transparency = NumberSequence.new(0.5, 1) })
		light(emitterPart, c1, 0.8, 6 * s)
	elseif fx == "Festive" then
		for i, p in parts do
			p.Color = p.Color:Lerp(i % 2 == 0 and c2 or c1, 0.6)
		end
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(Color3.new(1, 1, 1)), Rate = 8, Size = seq(0.3 * s, 0.1 * s), Acceleration = Vector3.new(0, -2, 0) })
	end
end

-- Quality effects for dumbbells (Great and up).
function MutationFx.ApplyQuality(parts: { BasePart }, quality: any, emitterPart: BasePart, scale: number?)
	local s = scale or 1
	local fx = quality.Fx
	if fx == "Sparkle" then
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(quality.Color, Color3.new(1, 1, 1)), Rate = 3, Size = seq(0.25 * s, 0) })
	elseif fx == "Shiny" then
		for _, p in parts do
			p.Reflectance = math.max(p.Reflectance, 0.35)
		end
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(Color3.new(1, 1, 1), quality.Color), Rate = 7, Size = seq(0.4 * s, 0) })
	elseif fx == "Gold" then
		tint(parts, quality.Color, 0.45)
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(quality.Color, quality.Color2), Rate = 9, Size = seq(0.45 * s, 0) })
		light(emitterPart, quality.Color, 1, 6 * s)
	elseif fx == "Rainbow" then
		for _, p in parts do
			tag(p, "Rainbow")
		end
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(quality.Color, quality.Color2), Rate = 10, Size = seq(0.45 * s, 0) })
	elseif fx == "Glitched" then
		for _, p in parts do
			tag(p, "Glitch")
		end
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(quality.Color, quality.Color2), Rate = 14, Size = seq(0.3 * s, 0.3 * s), Lifetime = NumberRange.new(0.1, 0.3) })
	elseif fx == "Celestial" then
		for _, p in parts do
			tag(p, "Celestial")
			p.Reflectance = math.max(p.Reflectance, 0.3)
		end
		MutationFx.Emitter(emitterPart, { Color = ColorSequence.new(quality.Color, quality.Color2), Rate = 18, Size = seq(0.6 * s, 0), Lifetime = NumberRange.new(1, 2) })
		light(emitterPart, quality.Color2, 2, 10 * s)
	end
end

return MutationFx
