--[[
	Parts - tiny helpers for building models out of parts at runtime.

	Works both in Roblox and in the offline place builder (it only uses Instance.new
	and CFrames; never Position/Orientation, PivotTo or other engine-only calls).
]]

local Parts = {}

local rad = math.rad

function Parts.new(className: string, parent: Instance?, props: { [string]: any }?): any
	local inst = Instance.new(className)
	if props then
		for k, v in props do
			(inst :: any)[k] = v
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

-- A visual part: smooth, no collisions, ready to weld or anchor.
function Parts.part(parent: Instance, name: string, cf: CFrame, size: Vector3, color: Color3, material: Enum.Material?, anchored: boolean?): BasePart
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = anchored == true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.CastShadow = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Parent = parent
	return p
end

-- Cylinder along the CFrame's X axis
function Parts.cyl(parent: Instance, name: string, cf: CFrame, length: number, diameter: number, color: Color3, material: Enum.Material?, anchored: boolean?): BasePart
	local p = Parts.part(parent, name, cf, Vector3.new(length, diameter, diameter), color, material, anchored)
	p.Shape = Enum.PartType.Cylinder
	return p
end

-- Cylinder standing up (axis = the CFrame's Y axis)
function Parts.disc(parent: Instance, name: string, cf: CFrame, diameter: number, height: number, color: Color3, material: Enum.Material?, anchored: boolean?): BasePart
	return Parts.cyl(parent, name, cf * CFrame.Angles(0, 0, rad(90)), height, diameter, color, material, anchored)
end

function Parts.ball(parent: Instance, name: string, cf: CFrame, diameter: number, color: Color3, material: Enum.Material?, anchored: boolean?): BasePart
	local p = Parts.part(parent, name, cf, Vector3.new(diameter, diameter, diameter), color, material, anchored)
	p.Shape = Enum.PartType.Ball
	return p
end

function Parts.wedge(parent: Instance, name: string, cf: CFrame, size: Vector3, color: Color3, material: Enum.Material?, anchored: boolean?): BasePart
	local p = Instance.new("WedgePart")
	p.Name = name
	p.Anchored = anchored == true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Parent = parent
	return p
end

function Parts.material(name: string?): Enum.Material
	local ok, result = pcall(function()
		return (Enum.Material :: any)[name or "SmoothPlastic"]
	end)
	return (ok and result) or Enum.Material.SmoothPlastic
end

-- Weld every BasePart in `model` to `root` (for models that get carried around).
function Parts.weldAll(model: Instance, root: BasePart)
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") and d ~= root then
			local w = Instance.new("WeldConstraint")
			w.Part0 = root
			w.Part1 = d
			w.Parent = d
		end
	end
end

-- Simple 32-bit string hash so visuals can be "random" but stable per item.
function Parts.hash(s: string): number
	local h = 5381
	for i = 1, #s do
		h = (h * 33 + string.byte(s, i)) % 4294967296
	end
	return h
end

function Parts.rng(seed: number)
	local state = seed % 2147483647
	if state <= 0 then
		state += 2147483646
	end
	return function(a: number?, b: number?): number
		state = (state * 48271) % 2147483647
		local r = state / 2147483647
		if a and b then
			return a + (b - a) * r
		end
		return r
	end
end

return Parts
