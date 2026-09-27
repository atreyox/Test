--[[
	DumbbellModel - builds the 3D dumbbell for a dumbbell record, out of the exact
	materials the player chose (left plate, handle, right plate).

	local model = DumbbellModel.Build(record, {
		CFrame = CFrame.new(...),   -- handle center; the handle runs along the CFrame's X axis
		Scale = 1,                  -- overall size multiplier
		Anchored = true,            -- anchored (showcases) or welded to the Handle (held in hand)
		Detail = "High" | "Low",    -- Low skips small details (for trophy stands)
		Effects = true,             -- particles / lights / mutation looks
	})
	model.PrimaryPart is the Handle. Bigger plate sizes make the plates bigger on purpose.
]]

local Shared = script.Parent.Parent
local Materials = require(Shared.Config.Materials)
local Qualities = require(Shared.Config.Qualities)
local Rarities = require(Shared.Config.Rarities)
local DumbbellStats = require(Shared.DumbbellStats)
local Parts = require(script.Parent.Parts)
local MutationFx = require(script.Parent.MutationFx)

local DumbbellModel = {}

local rad = math.rad
local SQRT3_2 = 0.8660254

local function darker(c: Color3, t: number): Color3
	return c:Lerp(Color3.new(0, 0, 0), t)
end

local function lighter(c: Color3, t: number): Color3
	return c:Lerp(Color3.new(1, 1, 1), t)
end

type PlateCtx = {
	model: Model,
	cf: CFrame,
	D: number,
	T: number,
	mat: any,
	anchored: boolean,
	rng: (number?, number?) -> number,
	detail: string,
	outward: number,
}

local function styled(p: BasePart, mat: any)
	p.Material = Parts.material(mat.Material)
	if mat.Reflectance then
		p.Reflectance = mat.Reflectance
	end
	if mat.Transparency then
		p.Transparency = mat.Transparency
	end
	return p
end

local PLATE = {}

function PLATE.Disc(c: PlateCtx): { BasePart }
	local out = {}
	local col = c.mat.Color
	table.insert(out, styled(Parts.cyl(c.model, "Plate", c.cf, c.T, c.D, darker(col, 0.12), nil, c.anchored), c.mat))
	table.insert(out, styled(Parts.cyl(c.model, "PlateFace", c.cf, c.T * 1.12, c.D * 0.8, col, nil, c.anchored), c.mat))
	if c.detail == "High" then
		local hub = Parts.cyl(c.model, "Hub", c.cf, c.T * 1.24, c.D * 0.32, c.mat.Color2, Enum.Material.Metal, c.anchored)
		table.insert(out, hub)
	end
	return out
end

function PLATE.Tire(c: PlateCtx): { BasePart }
	local out = {}
	table.insert(out, styled(Parts.cyl(c.model, "Tire", c.cf, c.T * 1.1, c.D, c.mat.Color, nil, c.anchored), c.mat))
	table.insert(out, Parts.cyl(c.model, "Tread", c.cf, c.T * 0.7, c.D * 1.04, darker(c.mat.Color, 0.25), Enum.Material.Rubber, c.anchored))
	table.insert(out, Parts.cyl(c.model, "Rim", c.cf, c.T * 1.18, c.D * 0.5, c.mat.Color2, Enum.Material.Metal, c.anchored))
	return out
end

function PLATE.Hex(c: PlateCtx): { BasePart }
	local out = {}
	local col = c.mat.Color
	for i = 0, 2 do
		local cf = c.cf * CFrame.Angles(rad(60 * i), 0, 0)
		table.insert(out, styled(Parts.part(c.model, "Hex", cf, Vector3.new(c.T, c.D * SQRT3_2, c.D * 0.5), darker(col, 0.1), nil, c.anchored), c.mat))
	end
	if c.detail == "High" then
		for i = 0, 2 do
			local cf = c.cf * CFrame.Angles(rad(60 * i), 0, 0)
			table.insert(out, styled(Parts.part(c.model, "HexFace", cf, Vector3.new(c.T * 1.12, c.D * SQRT3_2 * 0.72, c.D * 0.5 * 0.72), lighter(col, 0.06), nil, c.anchored), c.mat))
		end
		table.insert(out, Parts.cyl(c.model, "Hub", c.cf, c.T * 1.24, c.D * 0.3, c.mat.Color2, Enum.Material.Metal, c.anchored))
	end
	return out
end

function PLATE.Rock(c: PlateCtx): { BasePart }
	local out = {}
	local col = c.mat.Color
	for i = 1, 3 do
		local size = Vector3.new(c.T * c.rng(1.4, 2.1), c.D * c.rng(0.55, 0.78), c.D * c.rng(0.55, 0.78))
		local rot = CFrame.Angles(rad(c.rng(0, 90)), rad(c.rng(-20, 20)), rad(c.rng(-20, 20)))
		local off = CFrame.new(0, c.D * c.rng(-0.08, 0.08), c.D * c.rng(-0.08, 0.08))
		table.insert(out, styled(Parts.part(c.model, "Rock", c.cf * off * rot, size, col:Lerp(c.mat.Color2, c.rng(0, 0.3)), nil, c.anchored), c.mat))
	end
	return out
end

function PLATE.Crystal(c: PlateCtx): { BasePart }
	local out = {}
	local col = c.mat.Color
	table.insert(out, styled(Parts.part(c.model, "Gem", c.cf * CFrame.Angles(rad(45), 0, 0), Vector3.new(c.T * 1.7, c.D * 0.66, c.D * 0.66), col, nil, c.anchored), c.mat))
	table.insert(out, styled(Parts.part(c.model, "Gem2", c.cf * CFrame.Angles(0, 0, 0), Vector3.new(c.T * 1.3, c.D * 0.62, c.D * 0.62), darker(col, 0.08), nil, c.anchored), c.mat))
	if c.mat.Glow then
		local core = Parts.part(c.model, "Core", c.cf * CFrame.Angles(rad(45), 0, 0), Vector3.new(c.T * 1.8, c.D * 0.28, c.D * 0.28), lighter(c.mat.Color2, 0.2), Enum.Material.Neon, c.anchored)
		table.insert(out, core)
	end
	return out
end

function PLATE.Orb(c: PlateCtx): { BasePart }
	local out = {}
	table.insert(out, styled(Parts.ball(c.model, "Orb", c.cf, c.D * 0.86, c.mat.Color, nil, c.anchored), c.mat))
	if c.detail == "High" then
		local ring = Parts.cyl(c.model, "Ring", c.cf * CFrame.Angles(0, 0, rad(90)) * CFrame.Angles(rad(20), 0, 0), 0.07, c.D * 1.12, c.mat.Color2, c.mat.Glow and Enum.Material.Neon or Enum.Material.Metal, c.anchored)
		table.insert(out, ring)
	end
	return out
end

function PLATE.Block(c: PlateCtx): { BasePart }
	local out = {}
	local col = c.mat.Color
	table.insert(out, styled(Parts.part(c.model, "Block", c.cf, Vector3.new(c.T * 1.7, c.D * 0.84, c.D * 0.84), col, nil, c.anchored), c.mat))
	if c.detail == "High" then
		table.insert(out, styled(Parts.part(c.model, "Edge", c.cf, Vector3.new(c.T * 1.5, c.D * 0.9, c.D * 0.72), darker(col, 0.12), nil, c.anchored), c.mat))
		table.insert(out, styled(Parts.part(c.model, "Edge", c.cf, Vector3.new(c.T * 1.5, c.D * 0.72, c.D * 0.9), darker(col, 0.12), nil, c.anchored), c.mat))
	end
	return out
end

function PLATE.Spiky(c: PlateCtx): { BasePart }
	local out = {}
	table.insert(out, styled(Parts.ball(c.model, "Core", c.cf, c.D * 0.78, c.mat.Color, nil, c.anchored), c.mat))
	local spikes = c.detail == "High" and 8 or 5
	for i = 1, spikes do
		local a = (i / spikes) * 360
		local cf = c.cf * CFrame.Angles(rad(a), 0, 0) * CFrame.new(0, c.D * 0.42, 0) * CFrame.Angles(0, rad(45), 0)
		table.insert(out, Parts.part(c.model, "Spike", cf, Vector3.new(c.D * 0.16, c.D * 0.34, c.D * 0.16), c.mat.Color2, Enum.Material.Neon, c.anchored))
	end
	return out
end

local function plateFor(style: string)
	return PLATE[style] or PLATE.Disc
end

-- Special looks for secret recipes
local function recipeLook(model: Model, look: string, handle: BasePart, plates: { { BasePart } }, anchored: boolean, s: number, platePos: { CFrame }, D: number)
	local gold = Color3.fromRGB(255, 206, 60)
	if look == "Meteor" or look == "Frostfire" or look == "Solar" then
		for i, list in plates do
			local f = Instance.new("Fire")
			f.Size = 1.6 * s * (D / 1.3)
			f.Heat = 3
			if look == "Frostfire" and i == 1 then
				f.Color = Color3.fromRGB(120, 200, 255)
				f.SecondaryColor = Color3.fromRGB(220, 250, 255)
			end
			f.Parent = list[1]
		end
	elseif look == "Royal" or look == "Divine" or look == "Chrome" then
		for _, cf in platePos do
			local ring = Parts.cyl(model, "Trim", cf, 0.08 * s, D * 1.08, gold, Enum.Material.Foil, anchored)
			ring.Reflectance = 0.3
		end
		if look ~= "Chrome" then
			local halo = Parts.cyl(model, "Halo", handle.CFrame * CFrame.new(0, 1.2 * s + D * 0.3, 0) * CFrame.Angles(0, 0, rad(90)), 0.06 * s, 1.2 * s, gold, Enum.Material.Neon, anchored)
			if look == "Divine" then
				halo.Color = Color3.fromRGB(255, 246, 214)
			end
		end
	elseif look == "Reactor" or look == "Nuclear" or look == "Toxic" then
		local col = look == "Reactor" and Color3.fromRGB(190, 80, 255) or Color3.fromRGB(110, 255, 70)
		local core = Parts.cyl(model, "ReactorCore", handle.CFrame, handle.Size.X * 0.5, handle.Size.Y * 1.25, col, Enum.Material.Neon, anchored)
		local l = Instance.new("PointLight")
		l.Color = col
		l.Range = 8 * s
		l.Brightness = 1.2
		l.Parent = core
	elseif look == "Rainbow" or look == "Galaxy" or look == "Glitch" then
		for _, list in plates do
			for _, p in list do
				pcall(function()
					p:AddTag(look == "Glitch" and "Glitch" or "Rainbow")
				end)
			end
		end
	else
		-- every other secret dumbbell gets golden trim so it stands out
		for _, cf in platePos do
			Parts.cyl(model, "Trim", cf, 0.07 * s, D * 1.06, gold, Enum.Material.Foil, anchored)
		end
	end
end

function DumbbellModel.Build(record: any, opts: { [string]: any }?): Model
	opts = opts or {}
	local anchored = opts.Anchored == true
	local detail = opts.Detail or "High"
	local effects = opts.Effects ~= false
	local s = opts.Scale or 1
	local root: CFrame = opts.CFrame or CFrame.new()

	local stats = DumbbellStats.Compute(record)
	local model = Instance.new("Model")
	model.Name = opts.Name or "Dumbbell"

	local parts = record.Parts
	local mats = {
		Materials.ById[parts[1].Material] or Materials.ById.Rubber,
		Materials.ById[parts[2].Material] or Materials.ById.Plastic,
		Materials.ById[parts[3].Material] or Materials.ById.Rubber,
	}
	local rng = Parts.rng(Parts.hash(tostring(record.Id or "preview")))

	local plateScale = DumbbellStats.PlateScale(stats.Size)
	local D = 1.3 * plateScale * s
	local T = 0.3 * (0.8 + 0.2 * plateScale) * s
	local stack = stats.Size >= 8 and 3 or (stats.Size >= 3 and 2 or 1)
	local handleD = 0.3 * s * (1 + 0.12 * (plateScale - 1))
	local grip = 1.5 * s * (1 + 0.1 * (plateScale - 1))
	local collarT = 0.16 * s
	local gap = T * 0.1

	-- how far the plate stack reaches from the collar
	local stackT = 0
	local thickness = {}
	for i = 1, stack do
		local t = T * (1 - (i - 1) * 0.12)
		thickness[i] = t
		stackT += t + gap
	end
	local halfLen = grip / 2 + collarT + stackT + 0.12 * s

	-- handle ---------------------------------------------------------------------------------
	local hm = mats[2]
	local handle = styled(Parts.cyl(model, "Handle", root, halfLen * 2, handleD, hm.Color, nil, anchored), hm)
	handle.Transparency = math.min(handle.Transparency, 0.1)
	model.PrimaryPart = handle
	local handleParts = { handle }
	if detail == "High" then
		for i = -1, 1 do
			local knurl = Parts.cyl(model, "Knurl", root * CFrame.new(i * grip * 0.28, 0, 0), 0.05 * s, handleD * 1.12, darker(hm.Color, 0.2), Parts.material(hm.Material), anchored)
			table.insert(handleParts, knurl)
		end
	end

	-- plates ----------------------------------------------------------------------------------
	local platesBySide = {}
	local platePos = {}
	for side = 1, 2 do
		local sign = side == 1 and -1 or 1
		local part = parts[side == 1 and 1 or 3]
		local mat = mats[side == 1 and 1 or 3]
		local collarCf = root * CFrame.new(sign * (grip / 2 + collarT / 2), 0, 0)
		Parts.cyl(model, "Collar", collarCf, collarT, handleD * 2, Color3.fromRGB(206, 212, 222), Enum.Material.Metal, anchored)
		local x = grip / 2 + collarT + gap
		local sideParts = {}
		for i = 1, stack do
			local t = thickness[i]
			local d = D * (1 - (i - 1) * 0.16)
			local cf = root * CFrame.new(sign * (x + t / 2), 0, 0)
			local list = plateFor(mat.Plate)({
				model = model, cf = cf, D = d, T = t, mat = mat, anchored = anchored,
				rng = rng, detail = detail, outward = sign,
			})
			for _, p in list do
				table.insert(sideParts, p)
			end
			if i == 1 then
				table.insert(platePos, cf)
			end
			x += t + gap
		end
		local cap = Parts.cyl(model, "Cap", root * CFrame.new(sign * (halfLen - 0.05 * s), 0, 0), 0.1 * s, handleD * 1.5, mat.Color2, Enum.Material.Metal, anchored)
		table.insert(sideParts, cap)
		platesBySide[side] = sideParts

		if effects then
			if mat.Glow and detail == "High" then
				local l = Instance.new("PointLight")
				l.Color = mat.Color
				l.Brightness = 0.7
				l.Range = 3 + D * 2
				l.Parent = sideParts[1]
			end
			if part.Mutation then
				MutationFx.Apply(sideParts, part.Mutation, sideParts[1], D / 1.3)
			end
		end
	end
	if effects and parts[2].Mutation then
		MutationFx.Apply(handleParts, parts[2].Mutation, handle, 0.6 * s)
	end

	-- quality, recipe, level --------------------------------------------------------------------
	if effects then
		local q = Qualities.Get(record.Quality)
		if q.Fx ~= "None" then
			local all = {}
			for _, list in platesBySide do
				for _, p in list do
					table.insert(all, p)
				end
			end
			MutationFx.ApplyQuality(all, q, handle, D / 1.3)
		end
		if stats.Recipe then
			recipeLook(model, stats.Recipe.Look, handle, platesBySide, anchored, s, platePos, D)
		end
		local level = record.Level or 1
		if level >= 25 then
			local rarity = Rarities.Get(stats.Rarity)
			MutationFx.Emitter(handle, {
				Color = ColorSequence.new(rarity.Color, Color3.new(1, 1, 1)),
				Rate = level >= 50 and 10 or 4,
				Size = NumberSequence.new(0.3 * s, 0),
			})
		end
		if level >= 100 then
			pcall(function()
				handle:AddTag("Evolved")
			end)
		end
	end

	if not anchored then
		Parts.weldAll(model, handle)
	end
	model:SetAttribute("DumbbellId", record.Id or "")
	model:SetAttribute("Length", halfLen * 2)
	model:SetAttribute("PlateDiameter", D)
	return model
end

return DumbbellModel
