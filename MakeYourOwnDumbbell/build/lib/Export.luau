--[[
	Export - dumps BaseParts to JSON for the three.js preview renderer (build/preview).
]]

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")

local Export = {}

local SHAPES = { Block = "box", Cylinder = "cyl", Ball = "ball" }

local function partInfo(p: any, offset: any?)
	if p.Transparency >= 0.99 then
		return nil
	end
	local shape = "box"
	if p.ClassName == "WedgePart" then
		shape = "wedge"
	elseif p.ClassName == "CornerWedgePart" then
		shape = "corner"
	elseif p.ClassName == "Part" or p.ClassName == "SpawnLocation" then
		shape = SHAPES[p.Shape.Name] or "box"
	end
	local size = p.Size
	local mesh = p:FindFirstChildOfClass("SpecialMesh")
	if mesh then
		local mt = mesh.MeshType.Name
		if mt == "Head" then
			shape = "head"
		elseif mt == "Sphere" then
			shape = "ellipsoid"
		elseif mt == "Cylinder" then
			shape = "cylY"
		elseif mt == "Wedge" then
			shape = "wedge"
		end
		local sc = mesh.Scale
		size = roblox.Vector3.new(size.X * sc.X, size.Y * sc.Y, size.Z * sc.Z)
	end
	local cf = p.CFrame
	if offset then
		cf = offset * cf
	end
	local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
	local c = p.Color
	local light = p:FindFirstChildWhichIsA("Light", true)
	return {
		s = shape,
		z = { size.X, size.Y, size.Z },
		p = { x, y, z },
		r = { r00, r01, r02, r10, r11, r12, r20, r21, r22 },
		c = { math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5) },
		m = p.Material.Name,
		t = p.Transparency,
		f = p.Reflectance,
		l = light and { math.floor(light.Color.R * 255), math.floor(light.Color.G * 255), math.floor(light.Color.B * 255), light.Range, light.Brightness } or nil,
	}
end

-- roots: list of { inst, offsetCFrame? }
function Export.Write(roots: { any }, outPath: string, lighting: any?)
	local parts = {}
	for _, entry in roots do
		local inst, offset = entry[1], entry[2]
		local list = inst:GetDescendants()
		if inst:IsA("BasePart") then
			table.insert(list, inst)
		end
		for _, d in list do
			if d:IsA("BasePart") then
				local info = partInfo(d, offset)
				if info then
					table.insert(parts, info)
				end
			end
		end
	end
	local out = { parts = parts }
	if lighting then
		out.lighting = {
			clock = lighting.ClockTime,
			brightness = lighting.Brightness,
		}
	end
	fs.writeFile(outPath, serde.encode("json", out))
	return #parts
end

return Export
