--[[
	Exports a built place to JSON for the three.js preview renderer.
	lune run build/tools/export_parts.luau <place.rbxlx> <out.json> [Service.Path.To.Model ...]
	Extra models are drawn at their "PreviewAt" attribute offset (Vector3) if they have one.
]]

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Export = require("../lib/Export")

local game = roblox.deserializePlace(fs.readFile(process.args[1]))
local roots = { { game:GetService("Workspace") } }
for i = 3, #process.args do
	local node = game
	for name in string.gmatch(process.args[i], "[^%.]+") do
		node = (node == game) and game:GetService(name) or node:FindFirstChild(name)
		if not node then
			break
		end
	end
	if node then
		local at = node:GetAttribute("PreviewAt")
		table.insert(roots, { node, at and roblox.CFrame.new(at) or nil })
	end
end
print("exported", Export.Write(roots, process.args[2], game:GetService("Lighting")), "parts")
