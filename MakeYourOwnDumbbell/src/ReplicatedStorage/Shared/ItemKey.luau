--[[
	ItemKey - materials are stored as stacks keyed by "Material|Refine|Mutation".

	"Iron|0|"         = raw Iron
	"Iron|2|Golden"   = Refined Golden Iron

	Keeping stacks as one string key keeps saves small and makes trading/selling simple.
]]

local Config = script.Parent.Config
local Materials = require(Config.Materials)
local Mutations = require(Config.Mutations)
local Refine = require(Config.Refine)
local Rarities = require(Config.Rarities)
local Balance = require(Config.Balance)

export type Parsed = { Material: string, Refine: number, Mutation: string? }

local ItemKey = {}

local cache: { [string]: Parsed } = {}

function ItemKey.Make(material: string, refine: number?, mutation: string?): string
	return material .. "|" .. tostring(refine or 0) .. "|" .. (mutation or "")
end

function ItemKey.Parse(key: string): Parsed?
	local hit = cache[key]
	if hit then
		return hit
	end
	if type(key) ~= "string" or #key > 64 then
		return nil
	end
	local material, refine, mutation = string.match(key, "^([%w]+)|(%d)|([%w]*)$")
	if not material then
		return nil
	end
	if not Materials.ById[material] then
		return nil
	end
	local r = tonumber(refine) :: number
	if r < 0 or r > Refine.Max then
		return nil
	end
	if mutation ~= "" and not Mutations.ById[mutation] then
		return nil
	end
	local parsed = { Material = material, Refine = r, Mutation = mutation ~= "" and mutation or nil }
	cache[key] = parsed
	return parsed
end

function ItemKey.IsValid(key: any): boolean
	return type(key) == "string" and ItemKey.Parse(key) ~= nil
end

function ItemKey.Material(key: string)
	local p = ItemKey.Parse(key)
	return p and Materials.ById[p.Material]
end

-- Power of one unit (material power x refine x mutation)
function ItemKey.UnitPower(key: string): number
	local p = ItemKey.Parse(key)
	if not p then
		return 0
	end
	local m = Materials.ById[p.Material]
	return m.Power * Refine.Get(p.Refine).Mult * Mutations.Mult(p.Mutation)
end

function ItemKey.UnitWeight(key: string): number
	local p = ItemKey.Parse(key)
	if not p then
		return 0
	end
	return Materials.ById[p.Material].Weight
end

function ItemKey.UnitValue(key: string): number
	return math.floor(ItemKey.UnitPower(key) * Balance.MaterialSellPerPower + 0.5)
end

-- Rarity of the stack: the material's rarity, bumped by a strong mutation.
function ItemKey.RarityRank(key: string): number
	local p = ItemKey.Parse(key)
	if not p then
		return 1
	end
	local rank = Rarities.Rank(Materials.ById[p.Material].Rarity)
	local mut = Mutations.Get(p.Mutation)
	if mut then
		rank = math.max(rank, math.min(Rarities.Rank(mut.Rarity), rank + 2))
	end
	return math.clamp(rank, 1, #Rarities.List)
end

function ItemKey.DisplayName(key: string): string
	local p = ItemKey.Parse(key)
	if not p then
		return "???"
	end
	local m = Materials.ById[p.Material]
	local base = m.Name
	local mut = Mutations.Get(p.Mutation)
	if mut then
		base = mut.Name .. " " .. base
	end
	return string.format(Refine.Get(p.Refine).Pattern, base)
end

return ItemKey
