--[[
	Sandbox - runs the game's own ModuleScripts inside Lune (outside Roblox).

	The build uses it to run shared modules (Config, DumbbellModel, UI views...) so the
	place file, the economy simulation and the docs all use the exact same code as the
	live game. Only pure-logic / Instance-building modules work here: engine services
	(Players, RunService, DataStoreService...) do not exist outside Roblox.
]]

local roblox = require("@lune/roblox")
local luau = require("@lune/luau")

local Sandbox = {}

-- Minimal stand-in for Roblox's Random class (seeded, deterministic).
local SimRandom = {}
SimRandom.__index = SimRandom

function SimRandom.new(seed: number?)
	local self = setmetatable({}, SimRandom)
	self.state = math.floor((seed or os.clock() * 1000) % 2147483647)
	if self.state <= 0 then
		self.state += 2147483646
	end
	return self
end

function SimRandom:_next(): number
	self.state = (self.state * 48271) % 2147483647
	return self.state / 2147483647
end

function SimRandom:NextNumber(min: number?, max: number?): number
	local r = self:_next()
	if min and max then
		return min + (max - min) * r
	end
	return r
end

function SimRandom:NextInteger(min: number, max: number): number
	return math.floor(min + (max - min + 1) * self:_next())
end

Sandbox.Random = SimRandom

function Sandbox.new(game: any)
	local cache = {}
	local loading = {}

	local base = {
		Instance = roblox.Instance,
		Vector3 = roblox.Vector3,
		Vector2 = roblox.Vector2,
		CFrame = roblox.CFrame,
		Color3 = roblox.Color3,
		UDim = roblox.UDim,
		UDim2 = roblox.UDim2,
		Enum = roblox.Enum,
		BrickColor = roblox.BrickColor,
		NumberSequence = roblox.NumberSequence,
		NumberSequenceKeypoint = roblox.NumberSequenceKeypoint,
		ColorSequence = roblox.ColorSequence,
		ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
		NumberRange = roblox.NumberRange,
		Rect = roblox.Rect,
		Font = roblox.Font,
		PhysicalProperties = roblox.PhysicalProperties,
		Faces = roblox.Faces,
		Axes = roblox.Axes,
		Random = SimRandom,
		game = game,
		workspace = game:GetService("Workspace"),
		warn = function(...)
			print("[warn]", ...)
		end,
		tick = os.clock,
		time = os.clock,
		task = {
			wait = function()
				return 0
			end,
			spawn = function(f, ...)
				return f(...)
			end,
			defer = function(f, ...)
				return f(...)
			end,
			delay = function() end,
		},
	}
	-- Luau resolves globals like `Color3.fromRGB` as imports, which skip __index, so the
	-- environment must hold every global as a real key.
	local STDLIB = {
		"math", "string", "table", "os", "utf8", "bit32", "coroutine", "buffer", "debug",
		"print", "error", "assert", "pairs", "ipairs", "next", "select", "type", "typeof",
		"tostring", "tonumber", "pcall", "xpcall", "setmetatable", "getmetatable",
		"rawget", "rawset", "rawequal", "rawlen", "unpack",
	}
	local globals = {
		math = math, string = string, table = table, os = os, utf8 = utf8, bit32 = bit32,
		coroutine = coroutine, buffer = buffer, debug = debug, print = print, error = error,
		assert = assert, pairs = pairs, ipairs = ipairs, next = next, select = select,
		type = type, typeof = typeof, tostring = tostring, tonumber = tonumber, pcall = pcall,
		xpcall = xpcall, setmetatable = setmetatable, getmetatable = getmetatable,
		rawget = rawget, rawset = rawset, rawequal = rawequal, rawlen = rawlen,
	}
	for _, name in STDLIB do
		if base[name] == nil then
			base[name] = globals[name]
		end
	end

	local function requireModule(target: any)
		if type(target) ~= "userdata" then
			error("Sandbox require expects a ModuleScript, got " .. typeof(target))
		end
		if cache[target] ~= nil then
			return cache[target]
		end
		if loading[target] then
			error("circular require of " .. target:GetFullName())
		end
		loading[target] = true
		local env = {}
		for k, v in base do
			env[k] = v
		end
		env.script = target
		env.require = requireModule
		local fn = luau.load(target.Source, { debugName = target:GetFullName(), environment = env })
		local result = fn()
		loading[target] = nil
		cache[target] = result
		return result
	end

	return {
		require = requireModule,
		env = base,
	}
end

return Sandbox
