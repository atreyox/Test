--[[
	Recipes - SECRET dumbbells.

	The game never lists these for players. The Index only shows "???" and a vague
	hint until someone forges one; the first person on a server gets a big announcement.

	Plates   : the two plate materials (order does not matter)
	Handle   : the handle material ("*" = anything)
	Mutation : optional - every part must carry this mutation
	MinSize  : optional - minimum plate size
	Mult     : extra gains multiplier on top of the normal stats
	Rarity   : the dumbbell is at least this rarity
	Ability  : special ability (see Abilities below)
	Look     : special visual used by DumbbellModel
]]

export type Ability = {
	Id: string,
	Name: string,
	Desc: string,
	Stats: { [string]: number },
	Special: string?,
}

export type Recipe = {
	Id: string,
	Name: string,
	Plates: { string },
	Handle: string,
	Mutation: string?,
	MinSize: number?,
	Mult: number,
	Rarity: string,
	Ability: string,
	Look: string,
	Hint: string,
	Order: number,
}

local abilities: { [string]: Ability } = {
	Bouncy = { Id = "Bouncy", Name = "Bouncy", Desc = "Your combo only halves when it breaks.", Stats = { Combo = 0.3 }, Special = "ComboSaver" },
	Unga = { Id = "Unga", Name = "UNGA!", Desc = "+100% crit power.", Stats = { CritPower = 1 } },
	JunkPunk = { Id = "JunkPunk", Name = "Junk Punk", Desc = "+35% coins.", Stats = { Coins = 0.35 } },
	Plunder = { Id = "Plunder", Name = "Plunder", Desc = "+40% coins and +10% luck.", Stats = { Coins = 0.4, Luck = 0.1 } },
	Conductor = { Id = "Conductor", Name = "Conductor", Desc = "+4% crit chance.", Stats = { Crit = 0.04 } },
	Craftsman = { Id = "Craftsman", Name = "Craftsman", Desc = "+25% gains.", Stats = { Gains = 0.25 } },
	Balance = { Id = "Balance", Name = "Perfect Balance", Desc = "+25% luck and +2% crit.", Stats = { Luck = 0.25, Crit = 0.02 } },
	CarbonCopy = { Id = "CarbonCopy", Name = "Carbon Copy", Desc = "-12% lift cooldown.", Stats = { Speed = 0.12 } },
	ChromeDome = { Id = "ChromeDome", Name = "Chrome Dome", Desc = "+60% coins.", Stats = { Coins = 0.6 } },
	SteamBurst = { Id = "SteamBurst", Name = "Steam Burst", Desc = "+50% crit power and +0.4s combo.", Stats = { CritPower = 0.5, Combo = 0.4 } },
	MountainHeart = { Id = "MountainHeart", Name = "Mountain Heart", Desc = "+3% crit, +50% crit power.", Stats = { Crit = 0.03, CritPower = 0.5 } },
	RoyalTax = { Id = "RoyalTax", Name = "Royal Tax", Desc = "+75% coins and +15% luck.", Stats = { Coins = 0.75, Luck = 0.15 } },
	Chandelier = { Id = "Chandelier", Name = "Chandelier", Desc = "+1% super crit chance.", Stats = { Super = 0.01 } },
	Meltdown = { Id = "Meltdown", Name = "Meltdown", Desc = "+1.5% super crit chance.", Stats = { Super = 0.015 } },
	MeteorStrike = { Id = "MeteorStrike", Name = "Meteor Strike", Desc = "Every 25th rep is a guaranteed SUPER CRIT.", Stats = {}, Special = "MeteorStrike" },
	Stargazer = { Id = "Stargazer", Name = "Stargazer", Desc = "+40% luck.", Stats = { Luck = 0.4 } },
	Eclipse = { Id = "Eclipse", Name = "Eclipse", Desc = "+75% gains at night.", Stats = {}, Special = "Night" },
	SolarFlare = { Id = "SolarFlare", Name = "Solar Flare", Desc = "+75% gains during the day.", Stats = {}, Special = "Day" },
	GalaxyBrain = { Id = "GalaxyBrain", Name = "Galaxy Brain", Desc = "+50% gains and +2% super crit.", Stats = { Gains = 0.5, Super = 0.02 } },
	AbyssPulse = { Id = "AbyssPulse", Name = "Abyss Pulse", Desc = "1% chance per rep of a x50 VOID LIFT.", Stats = {}, Special = "AbyssPulse" },
	GravityWell = { Id = "GravityWell", Name = "Gravity Well", Desc = "Weighs nothing. Anyone strong enough to hold air can lift it.", Stats = { Gains = 0.25 }, Special = "Weightless" },
	Glitch = { Id = "Glitch", Name = "G̷l̷i̷t̷c̷h̷", Desc = "Every rep gets a random x0.5 to x5 multiplier.", Stats = {}, Special = "Glitch" },
	TitanGrip = { Id = "TitanGrip", Name = "Titan Grip", Desc = "+40% gains.", Stats = { Gains = 0.4 } },
	GolemFist = { Id = "GolemFist", Name = "Golem Fist", Desc = "+30% gains and +30% coins.", Stats = { Gains = 0.3, Coins = 0.3 } },
	ToxicAvenger = { Id = "ToxicAvenger", Name = "Toxic Avenger", Desc = "+60% gains.", Stats = { Gains = 0.6 } },
	DuckSqueak = { Id = "DuckSqueak", Name = "SQUEAK", Desc = "+50% combo bonus. Squeaks every rep.", Stats = { ComboBonus = 0.5 } },
	Spooky = { Id = "Spooky", Name = "Spooky", Desc = "+30% luck.", Stats = { Luck = 0.3 } },
	CandyRush = { Id = "CandyRush", Name = "Sugar Rush", Desc = "-15% lift cooldown.", Stats = { Speed = 0.15 } },
	RainbowRoad = { Id = "RainbowRoad", Name = "Rainbow Road", Desc = "+100% luck.", Stats = { Luck = 1 } },
	Divine = { Id = "Divine", Name = "DIVINE", Desc = "+100% gains, coins and luck. +3% super crit.", Stats = { Gains = 1, Coins = 1, Luck = 1, Super = 0.03 } },
}

local list: { Recipe } = {
	{ Id = "BouncyBoi", Name = "Bouncy Boi", Plates = { "Rubber", "Rubber" }, Handle = "Rubber", MinSize = 3, Mult = 1.5, Rarity = "Uncommon", Ability = "Bouncy", Look = "Bouncy", Hint = "Nothing but the bounciest stuff... and a big size." },
	{ Id = "CavemanClub", Name = "Caveman Club", Plates = { "Stone", "Stone" }, Handle = "Wood", Mult = 1.6, Rarity = "Rare", Ability = "Unga", Look = "Caveman", Hint = "Rocks on a stick. Unga bunga." },
	{ Id = "JunkPunk", Name = "Junk Punk", Plates = { "Scrap", "Scrap" }, Handle = "Rubber", Mult = 1.5, Rarity = "Rare", Ability = "JunkPunk", Look = "Junk", Hint = "Scrap on both sides, grip from a tire." },
	{ Id = "PiratesBooty", Name = "Pirate's Booty", Plates = { "Wood", "Wood" }, Handle = "Brass", Mult = 1.6, Rarity = "Rare", Ability = "Plunder", Look = "Pirate", Hint = "Wooden like a ship, with a handle that looks like gold." },
	{ Id = "PennyPress", Name = "Penny Press", Plates = { "Copper", "Copper" }, Handle = "Copper", Mult = 1.5, Rarity = "Rare", Ability = "Conductor", Look = "Penny", Hint = "Make it out of pennies. All of it." },
	{ Id = "BlacksmithPride", Name = "Blacksmith's Pride", Plates = { "Iron", "Iron" }, Handle = "Steel", Mult = 1.7, Rarity = "Epic", Ability = "Craftsman", Look = "Smith", Hint = "Iron weights on a steel bar. A classic." },
	{ Id = "YinYang", Name = "Yin & Yang", Plates = { "Coal", "Silver" }, Handle = "Titanium", Mult = 1.8, Rarity = "Epic", Ability = "Balance", Look = "YinYang", Hint = "Darkest black, brightest white, one strong bar between." },
	{ Id = "CarbonCopy", Name = "Carbon Copy", Plates = { "CarbonFiber", "CarbonFiber" }, Handle = "CarbonFiber", Mult = 1.8, Rarity = "Epic", Ability = "CarbonCopy", Look = "Carbon", Hint = "Copy, paste, paste." },
	{ Id = "ChromeDome", Name = "Chrome Dome", Plates = { "Chrome", "Chrome" }, Handle = "Chrome", Mult = 2, Rarity = "Legendary", Ability = "ChromeDome", Look = "Chrome", Hint = "So shiny you can see your future." },
	{ Id = "Frostfire", Name = "Frostfire", Plates = { "Ice", "MagmaRock" }, Handle = "Obsidian", Mult = 2.2, Rarity = "Legendary", Ability = "SteamBurst", Look = "Frostfire", Hint = "Fire on one side, ice on the other. Volcanic glass between." },
	{ Id = "HeartOfTheMountain", Name = "Heart of the Mountain", Plates = { "Obsidian", "Obsidian" }, Handle = "MagmaRock", Mult = 2, Rarity = "Legendary", Ability = "MountainHeart", Look = "Mountain", Hint = "The volcano's darkest glass, held by its hottest rock." },
	{ Id = "RoyalDumbbell", Name = "Royal Dumbbell", Plates = { "Gold", "Gold" }, Handle = "Diamond", Mult = 1.9, Rarity = "Legendary", Ability = "RoyalTax", Look = "Royal", Hint = "Fit for a king: gold, gold... and the rarest gem." },
	{ Id = "CrystalChandelier", Name = "Crystal Chandelier", Plates = { "Diamond", "Diamond" }, Handle = "Quartz", Mult = 2.2, Rarity = "Mythic", Ability = "Chandelier", Look = "Chandelier", Hint = "Two diamonds hanging from pink crystal." },
	{ Id = "NuclearOption", Name = "The Nuclear Option", Plates = { "Uranium", "Uranium" }, Handle = "Plutonium", Mult = 2.5, Rarity = "Mythic", Ability = "Meltdown", Look = "Nuclear", Hint = "Two glowing weights, an even more glowing bar." },
	{ Id = "MeteorCrusher", Name = "Meteor Crusher", Plates = { "Meteorite", "Meteorite" }, Handle = "Meteorite", Mult = 2.5, Rarity = "Mythic", Ability = "MeteorStrike", Look = "Meteor", Hint = "Three rocks that fell from the sky." },
	{ Id = "Starfall", Name = "Starfall", Plates = { "Stardust", "Stardust" }, Handle = "Meteorite", Mult = 2.5, Rarity = "Mythic", Ability = "Stargazer", Look = "Starfall", Hint = "Stars on the ends, a meteor to hold." },
	{ Id = "LunarEclipse", Name = "Lunar Eclipse", Plates = { "Moonstone", "DarkMatter" }, Handle = "Moonstone", Mult = 3, Rarity = "Mythic", Ability = "Eclipse", Look = "Eclipse", Hint = "When the moon meets the dark." },
	{ Id = "SolarFlare", Name = "Solar Flare", Plates = { "SolarCore", "SolarCore" }, Handle = "FireOpal", Mult = 2.8, Rarity = "Mythic", Ability = "SolarFlare", Look = "Solar", Hint = "Two suns and a gem of fire." },
	{ Id = "GalaxyBrain", Name = "Galaxy Brain", Plates = { "NebulaGlass", "NebulaGlass" }, Handle = "QuasarShard", Mult = 3.5, Rarity = "Secret", Ability = "GalaxyBrain", Look = "Galaxy", Hint = "Nebulas on the ends, the brightest thing in space in the middle." },
	{ Id = "ReactorOfTheAbyss", Name = "Reactor of the Abyss", Plates = { "VoidOre", "VoidOre" }, Handle = "Uranium", Mult = 3.5, Rarity = "Secret", Ability = "AbyssPulse", Look = "Reactor", Hint = "Void on both sides, powered by uranium." },
	{ Id = "EventHorizon", Name = "Event Horizon", Plates = { "Singularity", "Singularity" }, Handle = "DarkMatter", Mult = 5, Rarity = "Secret", Ability = "GravityWell", Look = "Horizon", Hint = "Two points of infinite gravity, held by the dark." },
	{ Id = "GlitchInTheMatrix", Name = "Glitch in the Matrix", Plates = { "GlitchOre", "GlitchOre" }, Handle = "GlitchOre", Mult = 7.77, Rarity = "Secret", Ability = "Glitch", Look = "Glitch", Hint = "E̷r̷r̷o̷r̷ ×3" },
	{ Id = "TitansGrip", Name = "Titan's Grip", Plates = { "TitanAlloy", "TitanAlloy" }, Handle = "Iron", Mult = 2.2, Rarity = "Legendary", Ability = "TitanGrip", Look = "Titan", Hint = "Armor of a fallen titan on a plain iron bar." },
	{ Id = "GolemFist", Name = "Golem Fist", Plates = { "GolemHeart", "GolemHeart" }, Handle = "Scrap", Mult = 2, Rarity = "Legendary", Ability = "GolemFist", Look = "Golem", Hint = "Two golem hearts, wired together with junk." },
	{ Id = "ToxicAvenger", Name = "Toxic Avenger", Plates = { "MutantGoo", "MutantGoo" }, Handle = "Lead", Mutation = "Toxic", Mult = 3, Rarity = "Secret", Ability = "ToxicAvenger", Look = "Toxic", Hint = "Goo on goo on lead. And everything has to be toxic." },
	{ Id = "DuckDynasty", Name = "Duck Dynasty", Plates = { "SqueakyCore", "SqueakyCore" }, Handle = "Rubber", Mult = 2, Rarity = "Legendary", Ability = "DuckSqueak", Look = "Duck", Hint = "Two squeaks and a rubber handle." },
	{ Id = "RainbowRoad", Name = "Rainbow Road", Plates = { "Prismite", "Prismite" }, Handle = "*", Mutation = "Rainbow", Mult = 4, Rarity = "Secret", Ability = "RainbowRoad", Look = "Rainbow", Hint = "Every color crystal, every part RAINBOW." },
	{ Id = "SpookyScary", Name = "Spooky Scary", Plates = { "PumpkinIron", "PumpkinIron" }, Handle = "Coal", Mult = 2, Rarity = "Epic", Ability = "Spooky", Look = "Spooky", Hint = "Halloween only: pumpkins and coal." },
	{ Id = "CandyCrusher", Name = "Candy Crusher", Plates = { "CandySteel", "CandySteel" }, Handle = "CandySteel", Mult = 2, Rarity = "Epic", Ability = "CandyRush", Look = "Candy", Hint = "Winter only: nothing but candy canes." },
	{ Id = "DivineDumbbell", Name = "The Divine Dumbbell", Plates = { "CelestialOre", "CelestialOre" }, Handle = "CelestialOre", Mult = 10, Rarity = "Secret", Ability = "Divine", Look = "Divine", Hint = "Only a god could drop what this needs." },
}

local byId: { [string]: Recipe } = {}
for i, r in list do
	r.Order = i
	byId[r.Id] = r
	assert(abilities[r.Ability], "missing ability " .. r.Ability)
end

local Recipes = {
	List = list,
	ById = byId,
	Abilities = abilities,
}

-- Returns the recipe matching these parts, or nil.
-- parts = { {Material=..., Mutation=...} x3 } in the order Left plate, Handle, Right plate.
function Recipes.Match(parts: { any }, plateSize: number): Recipe?
	local left, handle, right = parts[1], parts[2], parts[3]
	if not (left and handle and right) then
		return nil
	end
	for _, r in list do
		local a, b = r.Plates[1], r.Plates[2]
		local platesOk = (left.Material == a and right.Material == b) or (left.Material == b and right.Material == a)
		local handleOk = r.Handle == "*" or handle.Material == r.Handle
		if platesOk and handleOk then
			local ok = true
			if r.MinSize and plateSize < r.MinSize then
				ok = false
			end
			if ok and r.Mutation then
				local needAll = r.Handle ~= "*"
				if left.Mutation ~= r.Mutation or right.Mutation ~= r.Mutation then
					ok = false
				elseif needAll and handle.Mutation ~= r.Mutation then
					ok = false
				end
			end
			if ok then
				return r
			end
		end
	end
	return nil
end

return Recipes
