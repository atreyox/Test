--[[
	DumbbellStats - the single source of truth for what a dumbbell does.

	Used by the server (real rewards), the Forge preview (what you'll get) and the
	inventory cards, so every screen shows exactly what the server will use.

	A dumbbell record (saved in player data):
	{
		Id = "123-17",                 -- unique: userId-counter
		Parts = { {Material, Refine, Mutation}, {...}, {...} },  -- Left plate, Handle, Right plate
		Size = 3,                      -- plate size (units of material per plate)
		Quality = "Perfect",
		Level = 1, Xp = 0,
		Created = os.time(), ForgedBy = userId, ForgedByName = "name",
		Tempered = true?, Knockoff = true?, Locked = true?, Favorite = true?,
	}
]]

local Config = script.Parent.Config
local Materials = require(Config.Materials)
local Mutations = require(Config.Mutations)
local Qualities = require(Config.Qualities)
local Refine = require(Config.Refine)
local Rarities = require(Config.Rarities)
local Recipes = require(Config.Recipes)
local Balance = require(Config.Balance)

export type Part = { Material: string, Refine: number?, Mutation: string? }

export type Stats = {
	Name: string,
	Power: number,
	Weight: number,
	RequiredStrength: number,
	Crit: number,
	CritPower: number,
	Super: number,
	Luck: number,
	Coins: number,
	Speed: number,
	Combo: number,
	ComboBonus: number,
	RarityRank: number,
	Rarity: string,
	Value: number,
	Balanced: boolean,
	Recipe: any?,
	Ability: any?,
	Special: string?,
	Size: number,
}

local DumbbellStats = {}

local TEMPERED_BONUS = 1.15

local function partPower(p: Part): number
	local m = Materials.ById[p.Material]
	if not m then
		return 0
	end
	return m.Power * Refine.Get(p.Refine or 0).Mult * Mutations.Mult(p.Mutation)
end

local function samePart(a: Part, b: Part): boolean
	return a.Material == b.Material and (a.Refine or 0) == (b.Refine or 0) and (a.Mutation or "") == (b.Mutation or "")
end

local function words(list: { string }): string
	local out = {}
	for _, w in list do
		if w ~= "" and out[#out] ~= w then
			table.insert(out, w)
		end
	end
	return table.concat(out, " ")
end

function DumbbellStats.Name(parts: { Part }, quality: string?, recipe: any?, knockoff: boolean?): string
	local left, handle, right = parts[1], parts[2], parts[3]
	local ml, mh, mr = Materials.ById[left.Material], Materials.ById[handle.Material], Materials.ById[right.Material]
	if not (ml and mh and mr) then
		return "Mystery Dumbbell"
	end
	local q = Qualities.Get(quality)
	local prefix = {}
	if knockoff then
		table.insert(prefix, "Knockoff")
	end
	if q.Id ~= "Normal" then
		table.insert(prefix, q.Name)
	end
	local sharedMutation = left.Mutation and left.Mutation == right.Mutation and Mutations.Get(left.Mutation)

	if recipe then
		if sharedMutation and recipe.Mutation == nil then
			table.insert(prefix, sharedMutation.Name)
		end
		table.insert(prefix, recipe.Name)
		return words(prefix)
	end

	if sharedMutation then
		table.insert(prefix, sharedMutation.Name)
	end

	local body: string
	if left.Material == right.Material and right.Material == handle.Material then
		if ml.Pure then
			body = ml.Pure .. " Dumbbell"
		elseif #prefix == 0 then
			body = "Pure " .. ml.Short .. " Dumbbell"
		else
			body = ml.Short .. " Dumbbell"
		end
	elseif left.Material == right.Material then
		body = ml.Short .. "-" .. mh.Short .. " Dumbbell"
	else
		body = ml.Adj .. " " .. mr.Short .. " Dumbbell"
	end
	table.insert(prefix, body)
	local name = words(prefix)
	if #name > 42 and sharedMutation then
		-- drop the mutation word first when names get too long
		local trimmed = {}
		for _, w in prefix do
			if w ~= sharedMutation.Name then
				table.insert(trimmed, w)
			end
		end
		name = words(trimmed)
	end
	return name
end

function DumbbellStats.Compute(record: any): Stats
	local parts: { Part } = record.Parts
	local size: number = math.max(1, math.floor(record.Size or 1))
	local q = Qualities.Get(record.Quality)
	local level = math.max(1, record.Level or 1)
	local left, handle, right = parts[1], parts[2], parts[3]

	local recipe = Recipes.Match(parts, size)
	local ability = recipe and Recipes.Abilities[recipe.Ability] or nil
	local balanced = samePart(left, right)

	-- Power ------------------------------------------------------------------------------
	local platePower = (partPower(left) + partPower(right)) * size ^ Balance.PlateSizeExponent
	local handlePower = partPower(handle) * Balance.HandlePowerFactor
	local power = (platePower + handlePower) * q.Mult
	if balanced then
		power *= Balance.BalancedBonus
	end
	if recipe then
		power *= recipe.Mult
	end

	-- Traits (handles count double) ---------------------------------------------------------
	local t = { Gains = 0, Crit = 0, CritPower = 0, Super = 0, Luck = 0, Coins = 0, Speed = 0, Combo = 0, Light = 0, ComboBonus = 0 }
	for i, p in parts do
		local m = Materials.ById[p.Material]
		if m and m.Trait then
			local mult = (i == 2) and 2 or 1
			t[m.Trait.Kind] = (t[m.Trait.Kind] or 0) + m.Trait.Amount * mult
		end
	end
	if ability then
		for k, v in ability.Stats do
			t[k] = (t[k] or 0) + v
		end
	end

	power *= 1 + t.Gains
	power *= 1 + (level - 1) * Balance.DumbbellLevelBonus
	if record.Tempered then
		power *= TEMPERED_BONUS
	end

	-- Weight --------------------------------------------------------------------------------
	local wl = Materials.ById[left.Material] and Materials.ById[left.Material].Weight or 0
	local wr = Materials.ById[right.Material] and Materials.ById[right.Material].Weight or 0
	local wh = Materials.ById[handle.Material] and Materials.ById[handle.Material].Weight or 0
	local weight = ((wl + wr) * size + wh * Balance.HandleWeightFactor) * (1 - math.clamp(t.Light, 0, 0.8))
	if ability and ability.Special == "Weightless" then
		weight = 0
	end
	local required = math.max(0, (weight - Balance.FreeLiftWeight) * Balance.StrengthPerKg)

	-- Rarity --------------------------------------------------------------------------------
	local rankSum = 0
	local bestMutationRank = 0
	for _, p in parts do
		local m = Materials.ById[p.Material]
		rankSum += m and Rarities.Rank(m.Rarity) or 1
		local mut = Mutations.Get(p.Mutation)
		if mut then
			bestMutationRank = math.max(bestMutationRank, Rarities.Rank(mut.Rarity))
		end
	end
	local rank = math.floor(rankSum / 3 + 0.5)
	if q.Rank >= 6 then
		rank += 1
	end
	if q.Rank >= 8 then
		rank += 1
	end
	if bestMutationRank >= 5 then
		rank += 1
	end
	if recipe then
		rank = math.max(rank, Rarities.Rank(recipe.Rarity))
	end
	rank = math.clamp(rank, 1, #Rarities.List)

	-- Value -----------------------------------------------------------------------------------
	local value = (partPower(left) + partPower(right)) * size + partPower(handle) * 0.5
	value = value * Balance.MaterialSellPerPower * Balance.DumbbellSellFactor * q.Mult
	if record.Knockoff then
		value *= 0.25
	end

	return {
		Name = DumbbellStats.Name(parts, record.Quality, recipe, record.Knockoff),
		Power = power,
		Weight = weight,
		RequiredStrength = required,
		Crit = t.Crit,
		CritPower = t.CritPower,
		Super = t.Super,
		Luck = t.Luck,
		Coins = t.Coins,
		Speed = math.clamp(t.Speed, 0, 0.5),
		Combo = t.Combo,
		ComboBonus = t.ComboBonus,
		RarityRank = rank,
		Rarity = Rarities.FromRank(rank).Id,
		Value = math.floor(value),
		Balanced = balanced,
		Recipe = recipe,
		Ability = ability,
		Special = ability and ability.Special or nil,
		Size = size,
	}
end

-- Visual scale of the plates, used by the 3D model (big plate sizes look huge on purpose).
function DumbbellStats.PlateScale(size: number): number
	return 1 + (math.max(1, size) - 1) ^ 0.55 * 0.28
end

return DumbbellStats
