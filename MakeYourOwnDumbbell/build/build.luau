--[[
	Place builder for MAKE YOUR OWN DUMBBELL.

	lune run build/build.luau            (run from the MakeYourOwnDumbbell folder)

	1. Loads every script from src/ (Rojo naming rules) and compiles each one.
	2. Builds the map (world, hub, zones, plots, NPCs) as real parts, so it is visible
	   and editable in Studio.
	3. Creates the RemoteEvents / RemoteFunctions listed in Shared.Net.
	4. Writes MakeYourOwnDumbbell.rbxlx.
]]

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local process = require("@lune/process")

local Source = require("./lib/Source")
local Sandbox = require("./lib/Sandbox")
local Geo = require("./lib/Geo")

local Instance = roblox.Instance
local Enum = roblox.Enum

local OUT = "MakeYourOwnDumbbell.rbxlx"
local game = Instance.new("DataModel")

-- 1. scripts ---------------------------------------------------------------------------
local count, errors = Source.Load(game, "./src")
if #errors > 0 then
	print("COMPILE ERRORS:")
	for _, e in errors do
		print("  " .. e)
	end
	process.exit(1)
end
print(string.format("loaded %d scripts", count))

local sb = Sandbox.new(game)

-- 2. services / settings -------------------------------------------------------------------
local workspace = game:GetService("Workspace")
workspace.StreamingEnabled = false
workspace.Gravity = 196.2
workspace.FallenPartsDestroyHeight = -600

local players = game:GetService("Players")
players.CharacterAutoLoads = true
players.RespawnTime = 3

local starterPlayer = game:GetService("StarterPlayer")
starterPlayer.CharacterWalkSpeed = 20
starterPlayer.CharacterUseJumpPower = false
starterPlayer.CharacterJumpHeight = 7.5
starterPlayer.CameraMaxZoomDistance = 110
starterPlayer.CameraMinZoomDistance = 0.5
starterPlayer.LoadCharacterAppearance = true
starterPlayer.EnableMouseLockOption = true

local starterGui = game:GetService("StarterGui")
starterGui.ResetPlayerGuiOnSpawn = false
starterGui.ShowDevelopmentGui = true

game:GetService("SoundService").RespectFilteringEnabled = true

-- 3. map ------------------------------------------------------------------------------------
local map = Geo.folder(workspace, "Map")
local World = require("./map/World")
World.Build(game, map)

local extra = {
	"./map/Hub",
	"./map/Zones",
	"./map/Plots",
}
for _, path in extra do
	if fs.isFile(path .. ".luau") then
		require(path).Build(game, map, sb)
	end
end

-- runtime folders the server fills in
Geo.folder(workspace, "Nodes")
Geo.folder(workspace, "Drops")
Geo.folder(workspace, "Effects")

-- 4. remotes ------------------------------------------------------------------------------
local shared = game:GetService("ReplicatedStorage"):FindFirstChild("Shared")
local netModule = shared and shared:FindFirstChild("Net")
if netModule then
	local Net = sb.require(netModule)
	local remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = game:GetService("ReplicatedStorage")
	local n = 0
	for _, name in Net.EventNames do
		local r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = remotes
		n += 1
	end
	for _, name in Net.FunctionNames do
		local r = Instance.new("RemoteFunction")
		r.Name = name
		r.Parent = remotes
		n += 1
	end
	for _, name in Net.UnreliableNames or {} do
		local r = Instance.new("UnreliableRemoteEvent")
		r.Name = name
		r.Parent = remotes
		n += 1
	end
	print(string.format("created %d remotes", n))
end

-- 5. write ------------------------------------------------------------------------------------
local partCount = 0
for _, d in workspace:GetDescendants() do
	if d:IsA("BasePart") then
		partCount += 1
	end
end
fs.writeFile(OUT, roblox.serializePlace(game, true))
print(string.format("wrote %s (%d parts in Workspace)", OUT, partCount))
