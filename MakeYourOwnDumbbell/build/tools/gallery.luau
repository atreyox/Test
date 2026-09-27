--[[
	Gallery - builds every material node and a set of sample dumbbells side by side and
	exports them for the preview renderer, to check how they look.

	lune run build/tools/gallery.luau <out.json> [nodes|dumbbells]
]]

local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Source = require("../lib/Source")
local Sandbox = require("../lib/Sandbox")
local Export = require("../lib/Export")
local Geo = require("../lib/Geo")

local CFrame = roblox.CFrame
local V3 = Geo.V3
local rgb = Geo.rgb

local game = roblox.Instance.new("DataModel")
Source.Load(game, "./src")
local sb = Sandbox.new(game)
local Shared = game:GetService("ReplicatedStorage").Shared
local Materials = sb.require(Shared.Config.Materials)
local Zones = sb.require(Shared.Config.Zones)
local NodeModel = sb.require(Shared.Visuals.NodeModel)
local DumbbellModel = sb.require(Shared.Visuals.DumbbellModel)

local ws = game:GetService("Workspace")
local root = Geo.folder(ws, "Gallery")
local mode = process.args[2] or "nodes"

if mode == "nodes" then
	Geo.box(root, "Floor", CFrame.new(20, -0.5, 60), V3(120, 1, 150), rgb(120, 170, 100), "Grass")
	for zi, zone in Zones.List do
		for mi, mat in Materials.ByZone[zone.Id] do
			local cf = CFrame.new((mi - 1) * 12, 0, (zi - 1) * 12)
			local node = NodeModel.Build(mat.Id, nil, cf, zi * 100 + mi)
			node.Parent = root
		end
	end
	-- a mutated row
	local muts = { "Shiny", "Golden", "Frozen", "Burning", "Radioactive", "Crystal", "Void", "Celestial" }
	for i, m in muts do
		local node = NodeModel.Build("Iron", m, CFrame.new(-16, 0, (i - 1) * 12), i)
		node.Parent = root
	end
else
	Geo.box(root, "Floor", CFrame.new(20, -0.5, 30), V3(140, 1, 90), rgb(90, 96, 110), "Concrete")
	local function rec(l, h, r, size, quality, mutL, mutR, id)
		return {
			Id = id,
			Parts = { { Material = l, Mutation = mutL }, { Material = h }, { Material = r, Mutation = mutR or mutL } },
			Size = size, Quality = quality or "Normal", Level = 1,
		}
	end
	local samples = {
		rec("Rubber", "Plastic", "Rubber", 1),
		rec("Wood", "Rubber", "Wood", 3),
		rec("Stone", "Wood", "Stone", 2),
		rec("Scrap", "Tin", "Scrap", 5),
		rec("Copper", "Brass", "Copper", 4),
		rec("Iron", "Steel", "Iron", 8),
		rec("Silver", "Iron", "Silver", 10),
		rec("Amethyst", "Titanium", "Amethyst", 6),
		rec("Titanium", "CarbonFiber", "Titanium", 16),
		rec("Gold", "Diamond", "Gold", 12, "Golden"),
		rec("Obsidian", "MagmaRock", "Obsidian", 12),
		rec("Ice", "Glacium", "Ice", 14),
		rec("Diamond", "Quartz", "Diamond", 18),
		rec("Uranium", "Plutonium", "Uranium", 20),
		rec("Meteorite", "Meteorite", "Meteorite", 25),
		rec("Moonstone", "DarkMatter", "Moonstone", 30),
		rec("VoidOre", "Uranium", "VoidOre", 40),
		rec("SolarCore", "FireOpal", "SolarCore", 35),
		rec("Iron", "Iron", "Iron", 6, "Normal", "Golden"),
		rec("Titanium", "Steel", "Titanium", 8, "Perfect", "Radioactive"),
		rec("Steel", "Chrome", "Steel", 10, "Shiny", "Void"),
		rec("Gold", "Gold", "Gold", 50, "Celestial"),
	}
	for i, r in samples do
		local col = (i - 1) % 6
		local row = math.floor((i - 1) / 6)
		local model = DumbbellModel.Build(r, {
			CFrame = CFrame.new(col * 16, 4, row * 18) * CFrame.Angles(0, math.rad(25), 0),
			Scale = 2.2,
			Anchored = true,
		})
		model.Parent = root
		print(i, r.Parts[1].Material, "->", model:GetAttribute("Length"))
	end
end

print("exported", Export.Write({ { root } }, process.args[1], game:GetService("Lighting")), "parts")
