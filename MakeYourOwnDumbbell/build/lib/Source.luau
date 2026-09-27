--[[
	Source - loads the src/ folder into a DataModel using Rojo's naming rules:

		Folder/                 -> Folder
		Name.luau               -> ModuleScript
		Name.server.luau        -> Script
		Name.client.luau        -> LocalScript
		Folder/init.luau        -> the folder itself becomes a ModuleScript
		Folder/init.server.luau -> the folder becomes a Script (etc.)

	Every script is compiled with the Luau compiler so syntax errors fail the build.
]]

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local roblox = require("@lune/roblox")

local Instance = roblox.Instance

local Source = {}

local function scriptClass(fileName: string): (string?, string?)
	local name = string.match(fileName, "^(.+)%.server%.luau$")
	if name then
		return "Script", name
	end
	name = string.match(fileName, "^(.+)%.client%.luau$")
	if name then
		return "LocalScript", name
	end
	name = string.match(fileName, "^(.+)%.luau$")
	if name then
		return "ModuleScript", name
	end
	return nil, nil
end

local function sorted(list: { string }): { string }
	table.sort(list)
	return list
end

local errors = {}
local count = 0

local function compileCheck(path: string, source: string)
	count += 1
	local ok, err = pcall(luau.compile, source)
	if not ok then
		table.insert(errors, path .. ": " .. tostring(err))
	end
end

local function loadDir(dirPath: string, parent: any)
	for _, entry in sorted(fs.readDir(dirPath)) do
		local full = dirPath .. "/" .. entry
		if fs.isDir(full) then
			local container
			-- init scripts turn the folder into that script
			for _, initName in { "init.luau", "init.server.luau", "init.client.luau" } do
				local initPath = full .. "/" .. initName
				if fs.isFile(initPath) then
					local class = scriptClass(initName)
					container = Instance.new(class)
					container.Name = entry
					local src = fs.readFile(initPath)
					container.Source = src
					compileCheck(initPath, src)
					break
				end
			end
			if not container then
				container = Instance.new("Folder")
				container.Name = entry
			end
			container.Parent = parent
			loadDir(full, container)
		elseif not string.match(entry, "^init%.") then
			local class, name = scriptClass(entry)
			if class then
				local inst = Instance.new(class)
				inst.Name = name
				local src = fs.readFile(full)
				inst.Source = src
				compileCheck(full, src)
				inst.Parent = parent
			end
		end
	end
end

-- Loads src/<Service>/... into game:GetService(<Service>)
function Source.Load(game: any, srcPath: string)
	for _, serviceName in sorted(fs.readDir(srcPath)) do
		local full = srcPath .. "/" .. serviceName
		if fs.isDir(full) then
			local service = game:GetService(serviceName)
			if serviceName == "StarterPlayer" then
				-- StarterPlayerScripts / StarterCharacterScripts are special containers
				for _, sub in sorted(fs.readDir(full)) do
					local subPath = full .. "/" .. sub
					if fs.isDir(subPath) then
						local container = service:FindFirstChild(sub) or Instance.new(sub)
						container.Parent = service
						loadDir(subPath, container)
					end
				end
			else
				loadDir(full, service)
			end
		end
	end
	return count, errors
end

return Source
