--[[
	Geo - small helpers for building anchored geometry in the place builder.

	All parts are anchored, smooth-surfaced and get sensible defaults, so map code can
	stay short:  Geo.box(parent, "Name", cframe, size, color, "Concrete")
]]

local roblox = require("@lune/roblox")

local Instance = roblox.Instance
local Vector3 = roblox.Vector3
local CFrame = roblox.CFrame
local Color3 = roblox.Color3
local Enum = roblox.Enum

local Geo = {}

Geo.V3 = Vector3.new
Geo.CF = CFrame.new
Geo.rgb = Color3.fromRGB

local rad = math.rad
Geo.rad = rad

-- Deterministic random numbers so the map is identical on every build.
local seed = 1337
function Geo.seed(s: number)
	seed = s
end
function Geo.rand(a: number?, b: number?): number
	seed = (seed * 1103515245 + 12345) % 2147483648
	local r = seed / 2147483648
	if a and b then
		return a + (b - a) * r
	end
	return r
end
function Geo.pick(list: { any }): any
	return list[math.floor(Geo.rand() * #list) + 1]
end

local function material(name: string?)
	return Enum.Material[name or "SmoothPlastic"]
end

function Geo.folder(parent: any, name: string): any
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

function Geo.model(parent: any, name: string): any
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end

-- Generic part. opts: Transparency, Reflectance, CanCollide, CanQuery, CanTouch, CastShadow, Shape
function Geo.part(parent: any, name: string, cf: any, size: any, color: any, mat: string?, opts: { [string]: any }?): any
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material(mat)
	if opts then
		for k, v in opts do
			p[k] = v
		end
	end
	p.Parent = parent
	return p
end

function Geo.box(parent: any, name: string, cf: any, size: any, color: any, mat: string?, opts: { [string]: any }?): any
	return Geo.part(parent, name, cf, size, color, mat, opts)
end

-- Cylinder standing upright (Roblox cylinders run along X, so rotate onto Y).
-- height along Y, diameter across X/Z.
function Geo.disc(parent: any, name: string, cf: any, diameter: number, height: number, color: any, mat: string?, opts: { [string]: any }?): any
	local p = Geo.part(parent, name, cf * CFrame.Angles(0, 0, rad(90)), Vector3.new(height, diameter, diameter), color, mat, opts)
	p.Shape = Enum.PartType.Cylinder
	return p
end

-- Cylinder lying along the given CFrame's X axis.
function Geo.cyl(parent: any, name: string, cf: any, length: number, diameter: number, color: any, mat: string?, opts: { [string]: any }?): any
	local p = Geo.part(parent, name, cf, Vector3.new(length, diameter, diameter), color, mat, opts)
	p.Shape = Enum.PartType.Cylinder
	return p
end

function Geo.ball(parent: any, name: string, cf: any, diameter: number, color: any, mat: string?, opts: { [string]: any }?): any
	local p = Geo.part(parent, name, cf, Vector3.new(diameter, diameter, diameter), color, mat, opts)
	p.Shape = Enum.PartType.Ball
	return p
end

function Geo.wedge(parent: any, name: string, cf: any, size: any, color: any, mat: string?, opts: { [string]: any }?): any
	local p = Instance.new("WedgePart")
	p.Name = name
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material(mat)
	if opts then
		for k, v in opts do
			p[k] = v
		end
	end
	p.Parent = parent
	return p
end

-- Invisible marker part (spawn points, bounds...)
function Geo.marker(parent: any, name: string, cf: any, size: any?): any
	return Geo.part(parent, name, cf, size or Vector3.new(1, 1, 1), Color3.fromRGB(255, 0, 255), "SmoothPlastic", {
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
	})
end

function Geo.light(parent: any, kind: string, color: any, brightness: number, range: number, shadows: boolean?): any
	local l = Instance.new(kind)
	l.Color = color
	l.Brightness = brightness
	l.Range = range
	l.Shadows = shadows == true
	l.Parent = parent
	return l
end

-- Text on a part face. Returns the TextLabel.
function Geo.surfaceText(part: any, face: string, text: string, textColor: any, opts: { [string]: any }?): any
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId[face]
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = (opts and opts.PixelsPerStud) or 40
	gui.LightInfluence = (opts and opts.LightInfluence) or 0
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundTransparency = 1
	label.Size = roblox.UDim2.fromScale(1, 1)
	label.Text = text
	label.TextColor3 = textColor
	label.TextScaled = true
	label.FontFace = roblox.Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Bold)
	label.Parent = gui
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = (opts and opts.Stroke) or 3
	stroke.Color = (opts and opts.StrokeColor) or Color3.fromRGB(20, 20, 30)
	stroke.Parent = label
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = roblox.UDim.new(0.04, 0)
	pad.PaddingRight = roblox.UDim.new(0.04, 0)
	pad.PaddingTop = roblox.UDim.new(0.06, 0)
	pad.PaddingBottom = roblox.UDim.new(0.06, 0)
	pad.Parent = label
	return label
end

-- Floating name above something (visible from far away).
function Geo.billboard(parent: any, text: string, color: any, size: any, offset: any, maxDistance: number?): any
	local bb = Instance.new("BillboardGui")
	bb.Name = "Label"
	bb.Size = size
	bb.StudsOffsetWorldSpace = offset
	bb.MaxDistance = maxDistance or 300
	bb.LightInfluence = 0
	bb.AlwaysOnTop = false
	bb.Parent = parent
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundTransparency = 1
	label.Size = roblox.UDim2.fromScale(1, 1)
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.FontFace = roblox.Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Bold)
	label.Parent = bb
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(20, 20, 30)
	stroke.Parent = label
	return bb
end

function Geo.attr(inst: any, attrs: { [string]: any }): any
	for k, v in attrs do
		inst:SetAttribute(k, v)
	end
	return inst
end

function Geo.lerpColor(a: any, b: any, t: number): any
	return a:Lerp(b, t)
end

function Geo.darken(c: any, amount: number): any
	return c:Lerp(Color3.new(0, 0, 0), amount)
end

function Geo.lighten(c: any, amount: number): any
	return c:Lerp(Color3.new(1, 1, 1), amount)
end

-- Position on a circle around the origin (angle in degrees, 0 = +X, counter-clockwise from above)
function Geo.polar(radius: number, degrees: number, y: number?): any
	local a = rad(degrees)
	return Vector3.new(math.cos(a) * radius, y or 0, -math.sin(a) * radius)
end

-- CFrame at a position, facing a target point (level, no tilt)
function Geo.facing(pos: any, target: any): any
	local flatTarget = Vector3.new(target.X, pos.Y, target.Z)
	return CFrame.lookAt(pos, flatTarget)
end

return Geo
