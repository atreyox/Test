--[[
	Materials - every material in the game.

	Power   : strength a single unit adds to a dumbbell (per plate unit; handles count half).
	Weight  : kg per unit. A dumbbell's weight decides how much Strength you need to lift it.
	Rarity  : see Config.Rarities.
	Zone    : where it spawns as a node (nil for boss / event / merchant / secret materials).
	Source  : how to get non-zone materials ("Boss", "Event", "Merchant", "Glitch").
	Spawn   : spawn weight inside its zone (higher = more common).
	Node    : the look of the node in the world (see Shared.Visuals.NodeModel).
	Plate   : the look of a dumbbell plate made from it (see Shared.Visuals.DumbbellModel).
	Trait   : bonus the material gives the dumbbell. Handles count double.
	          Gains (+% strength)  Crit (+crit chance)  CritPower (+% crit multiplier)
	          Super (+super crit chance)  Luck (+% luck)  Coins (+% coins)
	          Speed (-% lift cooldown)  Combo (+seconds of combo window)  Light (-% weight)
]]

export type Trait = { Kind: string, Amount: number }

export type Material = {
	Id: string,
	Name: string,
	Short: string,
	Adj: string,
	Pure: string?,
	Rarity: string,
	Power: number,
	Weight: number,
	Zone: string?,
	Source: string?,
	SourceId: string?,
	Spawn: number,
	Color: Color3,
	Color2: Color3,
	Material: string,
	Reflectance: number?,
	Transparency: number?,
	Glow: boolean?,
	Node: string,
	Plate: string,
	Trait: Trait,
	Desc: string,
	Order: number,
}

local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

local list: { Material } = {
	-- STARTER YARD --------------------------------------------------------------------
	{
		Id = "Rubber", Name = "Rubber", Short = "Rubber", Adj = "Rubber", Pure = "Rubber", Rarity = "Common",
		Power = 2, Weight = 2, Zone = "StarterYard", Spawn = 50,
		Color = rgb(44, 46, 52), Color2 = rgb(86, 90, 98), Material = "Rubber",
		Node = "Tire", Plate = "Tire", Trait = { Kind = "Combo", Amount = 0.1 },
		Desc = "Bouncy, grippy and smells like a bike shop.",
	},
	{
		Id = "Plastic", Name = "Plastic", Short = "Plastic", Adj = "Plastic", Rarity = "Common",
		Power = 2, Weight = 1, Zone = "StarterYard", Spawn = 50,
		Color = rgb(255, 92, 76), Color2 = rgb(255, 214, 64), Material = "SmoothPlastic",
		Node = "Crate", Plate = "Disc", Trait = { Kind = "Light", Amount = 0.05 },
		Desc = "Light as a feather. Also about as strong as one.",
	},
	{
		Id = "Wood", Name = "Wood", Short = "Wood", Adj = "Wooden", Pure = "Wooden", Rarity = "Uncommon",
		Power = 3, Weight = 3, Zone = "StarterYard", Spawn = 24,
		Color = rgb(164, 112, 66), Color2 = rgb(222, 180, 118), Material = "Wood",
		Node = "Logs", Plate = "Block", Trait = { Kind = "Gains", Amount = 0.03 },
		Desc = "Knock on it for good luck. Lift it for good gains.",
	},
	{
		Id = "Stone", Name = "Stone", Short = "Stone", Adj = "Stone", Pure = "Stone Age", Rarity = "Rare",
		Power = 5, Weight = 6, Zone = "StarterYard", Spawn = 9,
		Color = rgb(132, 134, 142), Color2 = rgb(96, 98, 106), Material = "Slate",
		Node = "Rock", Plate = "Rock", Trait = { Kind = "CritPower", Amount = 0.1 },
		Desc = "The original dumbbell. Cavemen swear by it.",
	},

	-- SCRAPYARD ------------------------------------------------------------------------
	{
		Id = "Scrap", Name = "Scrap Metal", Short = "Scrap", Adj = "Scrappy", Rarity = "Common",
		Power = 8, Weight = 8, Zone = "Scrapyard", Spawn = 50,
		Color = rgb(158, 90, 54), Color2 = rgb(112, 112, 120), Material = "CorrodedMetal",
		Node = "Scrap", Plate = "Hex", Trait = { Kind = "Coins", Amount = 0.05 },
		Desc = "One kid's trash is another kid's dumbbell.",
	},
	{
		Id = "Tin", Name = "Tin", Short = "Tin", Adj = "Tin", Rarity = "Common",
		Power = 9, Weight = 6, Zone = "Scrapyard", Spawn = 40,
		Color = rgb(196, 202, 210), Color2 = rgb(112, 108, 104), Material = "Metal",
		Node = "Ore", Plate = "Disc", Trait = { Kind = "Speed", Amount = 0.02 },
		Desc = "Makes a great clank when you drop it. Don't drop it.",
	},
	{
		Id = "Copper", Name = "Copper", Short = "Copper", Adj = "Copper", Rarity = "Uncommon",
		Power = 13, Weight = 11, Zone = "Scrapyard", Spawn = 22,
		Color = rgb(222, 126, 74), Color2 = rgb(96, 84, 76), Material = "Metal",
		Node = "Ore", Plate = "Disc", Trait = { Kind = "Crit", Amount = 0.01 },
		Desc = "Conductive! Your crits get a little zap.",
	},
	{
		Id = "Brass", Name = "Brass", Short = "Brass", Adj = "Brassy", Rarity = "Rare",
		Power = 21, Weight = 16, Zone = "Scrapyard", Spawn = 8,
		Color = rgb(226, 182, 80), Color2 = rgb(98, 88, 72), Material = "Metal", Reflectance = 0.15,
		Node = "Ore", Plate = "Hex", Trait = { Kind = "Coins", Amount = 0.12 },
		Desc = "Looks like gold if you squint. Merchants squint a lot.",
	},

	-- THE MINE -------------------------------------------------------------------------
	{
		Id = "Coal", Name = "Coal", Short = "Coal", Adj = "Coal", Rarity = "Common",
		Power = 32, Weight = 30, Zone = "Mine", Spawn = 45,
		Color = rgb(38, 38, 42), Color2 = rgb(76, 74, 78), Material = "Basalt",
		Node = "Ore", Plate = "Rock", Trait = { Kind = "CritPower", Amount = 0.1 },
		Desc = "Dusty, crumbly, surprisingly heavy.",
	},
	{
		Id = "Iron", Name = "Iron", Short = "Iron", Adj = "Iron", Rarity = "Uncommon",
		Power = 50, Weight = 45, Zone = "Mine", Spawn = 30,
		Color = rgb(122, 124, 134), Color2 = rgb(88, 76, 70), Material = "Metal",
		Node = "Ore", Plate = "Hex", Trait = { Kind = "Gains", Amount = 0.05 },
		Desc = "The backbone of every real gym.",
	},
	{
		Id = "Silver", Name = "Silver", Short = "Silver", Adj = "Silver", Rarity = "Rare",
		Power = 84, Weight = 60, Zone = "Mine", Spawn = 12,
		Color = rgb(222, 228, 238), Color2 = rgb(92, 90, 98), Material = "Metal", Reflectance = 0.3,
		Node = "Ore", Plate = "Disc", Trait = { Kind = "Luck", Amount = 0.06 },
		Desc = "Shiny enough to see your gains in it.",
	},
	{
		Id = "Amethyst", Name = "Amethyst", Short = "Amethyst", Adj = "Amethyst", Rarity = "Epic",
		Power = 134, Weight = 70, Zone = "Mine", Spawn = 4,
		Color = rgb(174, 94, 244), Color2 = rgb(80, 66, 92), Material = "Glass", Transparency = 0.15, Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Super", Amount = 0.002 },
		Desc = "Purple crystals that hum when you get close.",
	},

	-- INDUSTRIAL FACTORY ---------------------------------------------------------------
	{
		Id = "Steel", Name = "Steel", Short = "Steel", Adj = "Steel", Rarity = "Uncommon",
		Power = 128, Weight = 120, Zone = "Factory", Spawn = 45,
		Color = rgb(156, 166, 178), Color2 = rgb(70, 76, 86), Material = "DiamondPlate",
		Node = "Beam", Plate = "Hex", Trait = { Kind = "Gains", Amount = 0.06 },
		Desc = "Iron that went to the gym.",
	},
	{
		Id = "Titanium", Name = "Titanium", Short = "Titanium", Adj = "Titanium", Rarity = "Rare",
		Power = 205, Weight = 110, Zone = "Factory", Spawn = 20,
		Color = rgb(152, 178, 200), Color2 = rgb(70, 80, 96), Material = "Metal", Reflectance = 0.15,
		Node = "Ore", Plate = "Disc", Trait = { Kind = "Light", Amount = 0.12 },
		Desc = "Strong, light, and used in rockets. And now dumbbells.",
	},
	{
		Id = "CarbonFiber", Name = "Carbon Fiber", Short = "Carbon", Adj = "Carbon", Rarity = "Epic",
		Power = 330, Weight = 120, Zone = "Factory", Spawn = 7,
		Color = rgb(36, 38, 44), Color2 = rgb(96, 102, 116), Material = "Fabric",
		Node = "Spool", Plate = "Disc", Trait = { Kind = "Speed", Amount = 0.06 },
		Desc = "Woven from tiny threads of pure speed.",
	},
	{
		Id = "Chrome", Name = "Chrome", Short = "Chrome", Adj = "Chrome", Rarity = "Legendary",
		Power = 540, Weight = 300, Zone = "Factory", Spawn = 1.5,
		Color = rgb(232, 238, 246), Color2 = rgb(120, 130, 150), Material = "Foil", Reflectance = 0.5,
		Node = "Beam", Plate = "Disc", Trait = { Kind = "Coins", Amount = 0.25 },
		Desc = "So shiny it has its own reflection problems.",
	},

	-- VOLCANO --------------------------------------------------------------------------
	{
		Id = "MagmaRock", Name = "Magma Rock", Short = "Magma", Adj = "Magma", Rarity = "Uncommon",
		Power = 512, Weight = 500, Zone = "Volcano", Spawn = 45,
		Color = rgb(66, 44, 40), Color2 = rgb(255, 112, 32), Material = "CrackedLava",
		Node = "Rock", Plate = "Rock", Trait = { Kind = "CritPower", Amount = 0.15 },
		Desc = "Still hot. Wear oven mitts.",
	},
	{
		Id = "Gold", Name = "Gold", Short = "Gold", Adj = "Golden", Pure = "Golden", Rarity = "Rare",
		Power = 830, Weight = 800, Zone = "Volcano", Spawn = 20,
		Color = rgb(255, 196, 44), Color2 = rgb(126, 92, 40), Material = "Foil", Reflectance = 0.2,
		Node = "Nugget", Plate = "Disc", Trait = { Kind = "Luck", Amount = 0.1 },
		Desc = "Heavy, shiny and very, very lucky.",
	},
	{
		Id = "Obsidian", Name = "Obsidian", Short = "Obsidian", Adj = "Obsidian", Rarity = "Epic",
		Power = 1340, Weight = 900, Zone = "Volcano", Spawn = 7,
		Color = rgb(28, 22, 38), Color2 = rgb(110, 70, 170), Material = "Glass", Reflectance = 0.3, Transparency = 0.05,
		Node = "Shard", Plate = "Crystal", Trait = { Kind = "Crit", Amount = 0.02 },
		Desc = "Volcanic glass, sharp enough to cut excuses.",
	},
	{
		Id = "FireOpal", Name = "Fire Opal", Short = "Fire Opal", Adj = "Blazing", Rarity = "Legendary",
		Power = 2150, Weight = 1000, Zone = "Volcano", Spawn = 1.5,
		Color = rgb(255, 122, 40), Color2 = rgb(255, 214, 96), Material = "Glass", Transparency = 0.1, Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "CritPower", Amount = 0.3 },
		Desc = "A gem with a tiny volcano inside.",
	},

	-- FROZEN CAVE ----------------------------------------------------------------------
	{
		Id = "Ice", Name = "Ice", Short = "Ice", Adj = "Icy", Rarity = "Uncommon",
		Power = 2048, Weight = 1600, Zone = "FrozenCave", Spawn = 45,
		Color = rgb(170, 222, 255), Color2 = rgb(232, 246, 255), Material = "Ice", Transparency = 0.15,
		Node = "Ice", Plate = "Disc", Trait = { Kind = "Combo", Amount = 0.2 },
		Desc = "Cool under pressure. Literally.",
	},
	{
		Id = "Permafrost", Name = "Permafrost", Short = "Permafrost", Adj = "Frosted", Rarity = "Rare",
		Power = 3300, Weight = 2800, Zone = "FrozenCave", Spawn = 20,
		Color = rgb(214, 234, 246), Color2 = rgb(120, 150, 182), Material = "Glacier",
		Node = "Rock", Plate = "Rock", Trait = { Kind = "Gains", Amount = 0.08 },
		Desc = "Frozen for ten thousand years, ready for one more rep.",
	},
	{
		Id = "Sapphire", Name = "Sapphire", Short = "Sapphire", Adj = "Sapphire", Rarity = "Epic",
		Power = 5300, Weight = 3000, Zone = "FrozenCave", Spawn = 7,
		Color = rgb(44, 96, 236), Color2 = rgb(146, 186, 255), Material = "Glass", Transparency = 0.15, Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Luck", Amount = 0.12 },
		Desc = "Deep blue and very lucky.",
	},
	{
		Id = "Glacium", Name = "Glacium", Short = "Glacium", Adj = "Glacial", Rarity = "Legendary",
		Power = 8600, Weight = 3500, Zone = "FrozenCave", Spawn = 1.5,
		Color = rgb(120, 255, 255), Color2 = rgb(224, 255, 255), Material = "Glass", Transparency = 0.1, Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Combo", Amount = 0.35 },
		Desc = "The heart of a glacier. Keeps your combo frozen in time.",
	},

	-- CRYSTAL CAVERN -------------------------------------------------------------------
	{
		Id = "Quartz", Name = "Quartz", Short = "Quartz", Adj = "Quartz", Rarity = "Rare",
		Power = 8200, Weight = 7000, Zone = "CrystalCavern", Spawn = 45,
		Color = rgb(255, 222, 238), Color2 = rgb(250, 250, 255), Material = "Glass", Transparency = 0.2,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Speed", Amount = 0.05 },
		Desc = "Pretty, pink and pumped.",
	},
	{
		Id = "Emerald", Name = "Emerald", Short = "Emerald", Adj = "Emerald", Rarity = "Epic",
		Power = 13000, Weight = 9000, Zone = "CrystalCavern", Spawn = 20,
		Color = rgb(40, 206, 112), Color2 = rgb(164, 255, 204), Material = "Glass", Transparency = 0.15, Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Luck", Amount = 0.15 },
		Desc = "Green with envy? Green with GAINS.",
	},
	{
		Id = "Diamond", Name = "Diamond", Short = "Diamond", Adj = "Diamond", Rarity = "Legendary",
		Power = 21000, Weight = 11000, Zone = "CrystalCavern", Spawn = 6,
		Color = rgb(206, 246, 255), Color2 = rgb(255, 255, 255), Material = "Glass", Transparency = 0.3, Reflectance = 0.4, Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Crit", Amount = 0.03 },
		Desc = "Unbreakable. Unless you smash it. Which you did.",
	},
	{
		Id = "Prismite", Name = "Prismite", Short = "Prismite", Adj = "Prismatic", Rarity = "Mythic",
		Power = 34000, Weight = 12000, Zone = "CrystalCavern", Spawn = 1,
		Color = rgb(255, 140, 255), Color2 = rgb(140, 255, 255), Material = "Glass", Transparency = 0.1, Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Super", Amount = 0.005 },
		Desc = "A crystal that holds every color at once.",
	},

	-- NUCLEAR FACILITY -----------------------------------------------------------------
	{
		Id = "Lead", Name = "Lead", Short = "Lead", Adj = "Leaden", Rarity = "Rare",
		Power = 33000, Weight = 45000, Zone = "Nuclear", Spawn = 45,
		Color = rgb(86, 90, 100), Color2 = rgb(62, 64, 72), Material = "Metal",
		Node = "Ore", Plate = "Block", Trait = { Kind = "CritPower", Amount = 0.25 },
		Desc = "Ridiculously heavy. Blocks radiation and weak excuses.",
	},
	{
		Id = "Uranium", Name = "Uranium", Short = "Uranium", Adj = "Radiant", Rarity = "Epic",
		Power = 53000, Weight = 40000, Zone = "Nuclear", Spawn = 20,
		Color = rgb(112, 255, 64), Color2 = rgb(42, 62, 42), Material = "Neon", Glow = true,
		Node = "Barrel", Plate = "Orb", Trait = { Kind = "Super", Amount = 0.004 },
		Desc = "Glows in the dark. Do not lick.",
	},
	{
		Id = "Plutonium", Name = "Plutonium", Short = "Plutonium", Adj = "Plutonic", Rarity = "Legendary",
		Power = 86000, Weight = 45000, Zone = "Nuclear", Spawn = 6,
		Color = rgb(60, 255, 214), Color2 = rgb(32, 62, 62), Material = "Neon", Glow = true,
		Node = "Barrel", Plate = "Orb", Trait = { Kind = "Gains", Amount = 0.12 },
		Desc = "Powers cities. Now powers biceps.",
	},
	{
		Id = "Radium", Name = "Radium", Short = "Radium", Adj = "Radium", Rarity = "Mythic",
		Power = 140000, Weight = 50000, Zone = "Nuclear", Spawn = 1,
		Color = rgb(204, 255, 124), Color2 = rgb(62, 82, 42), Material = "Neon", Glow = true,
		Node = "Crystal", Plate = "Orb", Trait = { Kind = "Luck", Amount = 0.2 },
		Desc = "The scientist says it's fine. The scientist glows too.",
	},

	-- METEOR CRATER --------------------------------------------------------------------
	{
		Id = "SpaceRock", Name = "Space Rock", Short = "Space Rock", Adj = "Cosmic", Rarity = "Epic",
		Power = 131000, Weight = 110000, Zone = "MeteorCrater", Spawn = 45,
		Color = rgb(78, 72, 86), Color2 = rgb(164, 112, 255), Material = "Basalt",
		Node = "Meteor", Plate = "Rock", Trait = { Kind = "CritPower", Amount = 0.2 },
		Desc = "Fell from the sky. Probably on purpose.",
	},
	{
		Id = "Meteorite", Name = "Meteorite", Short = "Meteor", Adj = "Meteoric", Rarity = "Legendary",
		Power = 210000, Weight = 150000, Zone = "MeteorCrater", Spawn = 18,
		Color = rgb(96, 62, 52), Color2 = rgb(255, 116, 40), Material = "CrackedLava",
		Node = "Meteor", Plate = "Spiky", Trait = { Kind = "Crit", Amount = 0.03 },
		Desc = "A rock that crossed the galaxy just to be lifted by you.",
	},
	{
		Id = "Stardust", Name = "Stardust", Short = "Stardust", Adj = "Starry", Rarity = "Mythic",
		Power = 340000, Weight = 100000, Zone = "MeteorCrater", Spawn = 5,
		Color = rgb(255, 238, 164), Color2 = rgb(255, 255, 255), Material = "Glass", Transparency = 0.1, Glow = true,
		Node = "Orb", Plate = "Orb", Trait = { Kind = "Luck", Amount = 0.2 },
		Desc = "Sparkles that fell off a shooting star.",
	},
	{
		Id = "Starmetal", Name = "Starmetal", Short = "Starmetal", Adj = "Starforged", Pure = "Starforged", Rarity = "Mythic",
		Power = 550000, Weight = 200000, Zone = "MeteorCrater", Spawn = 1,
		Color = rgb(144, 164, 255), Color2 = rgb(232, 236, 255), Material = "Foil", Reflectance = 0.3,
		Node = "Ore", Plate = "Hex", Trait = { Kind = "Gains", Amount = 0.15 },
		Desc = "Metal forged in the core of a dying star.",
	},

	-- SPACE ZONE -----------------------------------------------------------------------
	{
		Id = "Moonstone", Name = "Moonstone", Short = "Moon", Adj = "Lunar", Rarity = "Legendary",
		Power = 524000, Weight = 380000, Zone = "Space", Spawn = 45,
		Color = rgb(218, 228, 255), Color2 = rgb(160, 172, 206), Material = "Marble", Glow = true,
		Node = "Rock", Plate = "Disc", Trait = { Kind = "Light", Amount = 0.2 },
		Desc = "Weighs less up here. Weighs a TON down there.",
	},
	{
		Id = "NebulaGlass", Name = "Nebula Glass", Short = "Nebula", Adj = "Nebula", Rarity = "Mythic",
		Power = 840000, Weight = 420000, Zone = "Space", Spawn = 20,
		Color = rgb(255, 112, 204), Color2 = rgb(112, 84, 255), Material = "Glass", Transparency = 0.2, Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Super", Amount = 0.006 },
		Desc = "A whole galaxy, squished into a crystal.",
	},
	{
		Id = "SolarCore", Name = "Solar Core", Short = "Solar", Adj = "Solar", Rarity = "Mythic",
		Power = 1350000, Weight = 500000, Zone = "Space", Spawn = 6,
		Color = rgb(255, 192, 44), Color2 = rgb(255, 92, 24), Material = "Neon", Glow = true,
		Node = "Orb", Plate = "Orb", Trait = { Kind = "Coins", Amount = 0.4 },
		Desc = "A piece of the sun. Bring sunglasses.",
	},
	{
		Id = "QuasarShard", Name = "Quasar Shard", Short = "Quasar", Adj = "Quasar", Rarity = "Mythic",
		Power = 2200000, Weight = 600000, Zone = "Space", Spawn = 1,
		Color = rgb(124, 204, 255), Color2 = rgb(255, 255, 255), Material = "Neon", Glow = true,
		Node = "Shard", Plate = "Crystal", Trait = { Kind = "CritPower", Amount = 0.5 },
		Desc = "Brighter than a trillion suns. Handle with gloves.",
	},

	-- VOID ZONE ------------------------------------------------------------------------
	{
		Id = "VoidOre", Name = "Void Ore", Short = "Void", Adj = "Voidforged", Pure = "Voidforged", Rarity = "Mythic",
		Power = 2100000, Weight = 1500000, Zone = "Void", Spawn = 45,
		Color = rgb(34, 12, 56), Color2 = rgb(194, 84, 255), Material = "Basalt", Glow = true,
		Node = "Shard", Plate = "Crystal", Trait = { Kind = "Super", Amount = 0.008 },
		Desc = "Ore from nowhere. It stares back.",
	},
	{
		Id = "DarkMatter", Name = "Dark Matter", Short = "Dark Matter", Adj = "Dark", Rarity = "Mythic",
		Power = 3400000, Weight = 1800000, Zone = "Void", Spawn = 20,
		Color = rgb(14, 10, 22), Color2 = rgb(134, 44, 255), Material = "SmoothPlastic", Glow = true,
		Node = "Orb", Plate = "Orb", Trait = { Kind = "Gains", Amount = 0.2 },
		Desc = "Scientists say it's everywhere. You found it first.",
	},
	{
		Id = "NullCrystal", Name = "Null Crystal", Short = "Null", Adj = "Null", Rarity = "Mythic",
		Power = 5400000, Weight = 2000000, Zone = "Void", Spawn = 6,
		Color = rgb(62, 32, 94), Color2 = rgb(232, 156, 255), Material = "Glass", Transparency = 0.1, Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Luck", Amount = 0.25 },
		Desc = "A crystal made of nothing. Somehow it's heavy.",
	},
	{
		Id = "Singularity", Name = "Singularity", Short = "Singularity", Adj = "Singular", Rarity = "Secret",
		Power = 14000000, Weight = 1, Zone = "Void", Spawn = 0.3,
		Color = rgb(4, 4, 8), Color2 = rgb(255, 255, 255), Material = "Glass", Glow = true,
		Node = "Orb", Plate = "Orb", Trait = { Kind = "Super", Amount = 0.015 },
		Desc = "Infinitely heavy. Weighs nothing. Don't think about it.",
	},

	-- BOSS DROPS -----------------------------------------------------------------------
	{
		Id = "SqueakyCore", Name = "Squeaky Core", Short = "Squeaky", Adj = "Squeaky", Rarity = "Legendary",
		Power = 14, Weight = 4, Source = "Boss", SourceId = "RubberDucky", Spawn = 0,
		Color = rgb(255, 222, 50), Color2 = rgb(255, 140, 30), Material = "SmoothPlastic",
		Node = "Orb", Plate = "Orb", Trait = { Kind = "Combo", Amount = 0.3 },
		Desc = "Squeaks every rep. Drives your neighbors crazy.",
	},
	{
		Id = "GolemHeart", Name = "Golem Heart", Short = "Golem", Adj = "Golem", Rarity = "Legendary",
		Power = 56, Weight = 40, Source = "Boss", SourceId = "ScrapGolem", Spawn = 0,
		Color = rgb(196, 102, 50), Color2 = rgb(255, 170, 60), Material = "CorrodedMetal", Glow = true,
		Node = "Orb", Plate = "Orb", Trait = { Kind = "Gains", Amount = 0.1 },
		Desc = "Still ticking. Still grumpy.",
	},
	{
		Id = "TitanAlloy", Name = "Titan Alloy", Short = "Titan", Adj = "Titanic", Rarity = "Legendary",
		Power = 224, Weight = 200, Source = "Boss", SourceId = "IronTitan", Spawn = 0,
		Color = rgb(70, 72, 84), Color2 = rgb(255, 60, 60), Material = "DiamondPlate", Glow = true,
		Node = "Ore", Plate = "Hex", Trait = { Kind = "CritPower", Amount = 0.25 },
		Desc = "Peeled off the chest of a defeated titan.",
	},
	{
		Id = "ForgeCore", Name = "Forge Core", Short = "Forge", Adj = "Overclocked", Rarity = "Legendary",
		Power = 900, Weight = 700, Source = "Boss", SourceId = "Forgebot", Spawn = 0,
		Color = rgb(255, 206, 20), Color2 = rgb(30, 30, 34), Material = "Metal", Glow = true,
		Node = "Orb", Plate = "Hex", Trait = { Kind = "Speed", Amount = 0.08 },
		Desc = "Beep boop. Gains detected.",
	},
	{
		Id = "LavaHeart", Name = "Lava Heart", Short = "Lava", Adj = "Molten", Rarity = "Legendary",
		Power = 3600, Weight = 3000, Source = "Boss", SourceId = "LavaGiant", Spawn = 0,
		Color = rgb(255, 92, 20), Color2 = rgb(80, 30, 20), Material = "Neon", Glow = true,
		Node = "Orb", Plate = "Orb", Trait = { Kind = "CritPower", Amount = 0.35 },
		Desc = "Beats like a drum. Burns like a stove.",
	},
	{
		Id = "EternalIce", Name = "Eternal Ice", Short = "Eternal", Adj = "Eternal", Rarity = "Legendary",
		Power = 14300, Weight = 11000, Source = "Boss", SourceId = "FrostColossus", Spawn = 0,
		Color = rgb(190, 240, 255), Color2 = rgb(90, 180, 255), Material = "Glass", Transparency = 0.1, Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Combo", Amount = 0.4 },
		Desc = "It will never melt. Your combo won't either.",
	},
	{
		Id = "GuardianGem", Name = "Guardian Gem", Short = "Guardian", Adj = "Guardian", Rarity = "Legendary",
		Power = 57000, Weight = 40000, Source = "Boss", SourceId = "CrystalGuardian", Spawn = 0,
		Color = rgb(214, 90, 255), Color2 = rgb(255, 200, 255), Material = "Glass", Transparency = 0.1, Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Luck", Amount = 0.2 },
		Desc = "The guardian's eye. It still watches over you.",
	},
	{
		Id = "MutantGoo", Name = "Mutant Goo", Short = "Goo", Adj = "Gooey", Rarity = "Legendary",
		Power = 230000, Weight = 160000, Source = "Boss", SourceId = "NuclearMutant", Spawn = 0,
		Color = rgb(140, 255, 40), Color2 = rgb(40, 110, 20), Material = "Neon", Glow = true,
		Node = "Orb", Plate = "Orb", Trait = { Kind = "Gains", Amount = 0.15 },
		Desc = "Wiggles. Glows. Somehow makes you stronger.",
	},
	{
		Id = "MeteorFang", Name = "Meteor Fang", Short = "Fang", Adj = "Fanged", Rarity = "Legendary",
		Power = 920000, Weight = 650000, Source = "Boss", SourceId = "MeteorBeast", Spawn = 0,
		Color = rgb(255, 150, 70), Color2 = rgb(70, 40, 36), Material = "CrackedLava", Glow = true,
		Node = "Meteor", Plate = "Spiky", Trait = { Kind = "Crit", Amount = 0.04 },
		Desc = "A tooth the size of a car. Pointy side out.",
	},
	{
		Id = "AstroPlating", Name = "Astro Plating", Short = "Astro", Adj = "Astro", Rarity = "Legendary",
		Power = 3700000, Weight = 2500000, Source = "Boss", SourceId = "AstroBrute", Spawn = 0,
		Color = rgb(236, 240, 250), Color2 = rgb(60, 140, 255), Material = "Metal", Reflectance = 0.2, Glow = true,
		Node = "Ore", Plate = "Hex", Trait = { Kind = "Light", Amount = 0.25 },
		Desc = "Space armor. Zero-gravity rated.",
	},
	{
		Id = "VoidHeart", Name = "Void Heart", Short = "Void Heart", Adj = "Abyssal", Rarity = "Mythic",
		Power = 15000000, Weight = 9000000, Source = "Boss", SourceId = "VoidLifter", Spawn = 0,
		Color = rgb(24, 8, 40), Color2 = rgb(210, 90, 255), Material = "Neon", Glow = true,
		Node = "Orb", Plate = "Orb", Trait = { Kind = "Super", Amount = 0.01 },
		Desc = "The Void Lifter's heart. It keeps doing reps without you.",
	},
	{
		Id = "CelestialOre", Name = "Celestial Ore", Short = "Celestial", Adj = "Celestial", Rarity = "Secret",
		Power = 60000000, Weight = 20000000, Source = "Boss", SourceId = "DumbbellGod", Spawn = 0,
		Color = rgb(255, 246, 214), Color2 = rgb(255, 206, 90), Material = "Neon", Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Luck", Amount = 0.5 },
		Desc = "Dropped by a god. You're not supposed to have this.",
	},

	-- EVENTS & SPECIALS -----------------------------------------------------------------
	{
		Id = "GlitchOre", Name = "Glitch Ore", Short = "Gl1tch", Adj = "Glitched", Rarity = "Secret",
		Power = 777777, Weight = 1, Source = "Glitch", Spawn = 0,
		Color = rgb(0, 255, 140), Color2 = rgb(255, 0, 200), Material = "Neon", Glow = true,
		Node = "Shard", Plate = "Crystal", Trait = { Kind = "Super", Amount = 0.007 },
		Desc = "E̷r̷r̷o̷r̷: material not found. Found it anyway.",
	},
	{
		Id = "AncientBronze", Name = "Ancient Bronze", Short = "Bronze", Adj = "Ancient", Rarity = "Legendary",
		Power = 60, Weight = 30, Source = "Merchant", Spawn = 0,
		Color = rgb(176, 124, 66), Color2 = rgb(80, 150, 120), Material = "CorrodedMetal",
		Node = "Ore", Plate = "Hex", Trait = { Kind = "Luck", Amount = 0.15 },
		Desc = "Dug up by the Traveling Merchant. Smells like history.",
	},
	{
		Id = "PumpkinIron", Name = "Pumpkin Iron", Short = "Pumpkin", Adj = "Spooky", Rarity = "Epic",
		Power = 1500, Weight = 900, Source = "Event", SourceId = "Halloween", Spawn = 0,
		Color = rgb(255, 128, 20), Color2 = rgb(40, 30, 30), Material = "SmoothPlastic", Glow = true,
		Node = "Orb", Plate = "Orb", Trait = { Kind = "Luck", Amount = 0.1 },
		Desc = "Halloween exclusive. Carved with a spooky face.",
	},
	{
		Id = "CandySteel", Name = "Candy Cane Steel", Short = "Candy", Adj = "Candy", Rarity = "Epic",
		Power = 1500, Weight = 900, Source = "Event", SourceId = "Winter", Spawn = 0,
		Color = rgb(255, 60, 70), Color2 = rgb(255, 255, 255), Material = "SmoothPlastic",
		Node = "Beam", Plate = "Disc", Trait = { Kind = "Combo", Amount = 0.25 },
		Desc = "Winter exclusive. Minty fresh gains.",
	},
	{
		Id = "Sunstone", Name = "Sunstone", Short = "Sunstone", Adj = "Sunny", Rarity = "Epic",
		Power = 1500, Weight = 900, Source = "Event", SourceId = "Summer", Spawn = 0,
		Color = rgb(255, 170, 60), Color2 = rgb(255, 240, 150), Material = "Glass", Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Coins", Amount = 0.2 },
		Desc = "Summer exclusive. Warm to the touch.",
	},
	{
		Id = "PartyChrome", Name = "Party Chrome", Short = "Party", Adj = "Party", Rarity = "Epic",
		Power = 1500, Weight = 900, Source = "Event", SourceId = "Anniversary", Spawn = 0,
		Color = rgb(255, 90, 220), Color2 = rgb(90, 220, 255), Material = "Foil", Reflectance = 0.3,
		Node = "Orb", Plate = "Disc", Trait = { Kind = "Speed", Amount = 0.06 },
		Desc = "Anniversary exclusive. Comes with free confetti.",
	},
	{
		Id = "Heartstone", Name = "Heartstone", Short = "Heart", Adj = "Lovely", Rarity = "Epic",
		Power = 1500, Weight = 900, Source = "Event", SourceId = "Valentine", Spawn = 0,
		Color = rgb(255, 80, 130), Color2 = rgb(255, 200, 220), Material = "Glass", Glow = true,
		Node = "Crystal", Plate = "Crystal", Trait = { Kind = "Crit", Amount = 0.02 },
		Desc = "Valentine exclusive. Lift it with love.",
	},
}

local byId: { [string]: Material } = {}
local byZone: { [string]: { Material } } = {}
local Rarities = require(script.Parent.Rarities)

for i, m in list do
	m.Order = i
	assert(byId[m.Id] == nil, "duplicate material " .. m.Id)
	byId[m.Id] = m
	if m.Zone then
		byZone[m.Zone] = byZone[m.Zone] or {}
		table.insert(byZone[m.Zone], m)
	end
end

for _, mats in byZone do
	table.sort(mats, function(a, b)
		return Rarities.Rank(a.Rarity) < Rarities.Rank(b.Rarity)
	end)
end

local Materials = {
	List = list,
	ById = byId,
	ByZone = byZone,
}

function Materials.Get(id: string): Material?
	return byId[id]
end

return Materials
