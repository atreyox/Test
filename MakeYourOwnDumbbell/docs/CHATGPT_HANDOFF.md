You are continuing development of a Roblox game called MAKE YOUR OWN DUMBBELL. Act as an expert Roblox game designer, UI/UX designer and Luau programmer. I have the place file MakeYourOwnDumbbell.rbxlx open in Roblox Studio. Another AI started it. Build on top of it: do NOT start over, and do NOT rename, move or rewrite the existing modules. Use their functions. If one of them truly needs a change, show me the exact lines to edit.

=== THE GAME (the design is decided, so follow it) ===
Core loop: smash material nodes -> the materials go into your backpack -> walk onto your own plot and they deposit automatically -> forge a dumbbell at your plot (Left plate + Handle + Right plate, each chosen from your materials, plus a plate size) -> equip it -> click/tap to lift -> gain Strength and Coins -> buy upgrades, unlock zones -> rebirth for permanent multipliers.
- Exactly 8 players per server and 8 plots in a ring around a central hub. Zones 2-11 are floating islands spiralling up around the hub, reached by launch pads in the hub.
- Strength is also your maximum lift: a dumbbell's RequiredStrength (from its weight) must be <= your Strength before you can equip it.
- Smash power = (10 + Strength) x the Smash Power upgrade. Each node has a toughness, and better materials are tougher.
- When a node breaks, everyone who hit it in the last 12 seconds gets a drop. This is co-op, so there is no kill-stealing.
- Nodes can spawn mutated (Shiny ... Golden, Radioactive, Void, Celestial) and are visible from far away. A mutation multiplies that material's power.
- Forging rolls a quality (Normal, Good, Great, Perfect, Shiny, Golden, Rainbow, Glitched, Celestial). Identical left and right plates give a "Balanced" bonus. There are 30 secret recipes that are never listed in-game; the Index shows ??? until you find them.
- Crits: 5% chance for x5, super crit 0.4% for x25. A combo counter gives bonus tiers at 10/25/50/100/250/500 reps.
- Rebirth resets Strength, Coins, zone unlocks and coin upgrades. It keeps dumbbells, materials, gems, the index and achievements.
- Currencies:
  - Coins: 1 coin per strength gained.
  - Gems: from quests, achievements, index milestones, bosses, events and first discoveries.
  - Rebirth Tokens: spent in the rebirth shop.
- Heist mechanic:
  - Rare+ dumbbells cool on the plot's Cooling Rack for 30 seconds. During that time another player can hold a prompt at the rack to snatch the "heat".
  - The thief must carry it to their own plot before the timer ends. If they make it, they get an untradeable Knockoff copy one quality lower.
  - The owner NEVER loses their dumbbell. It just misses the Tempered bonus (+15%) it would have earned by cooling undisturbed. The owner can tag the thief to cancel the snatch.
  - Security upgrades slow thieves down, new players get rookie protection for their first 30 minutes, and Robux items are never at risk.
- Art direction:
  - Bright, chunky, stylized, "toybox industrial". Build everything from Parts: NO free models and NO uploaded assets.
  - Neon accents, the FredokaOne font, and emoji as icons.
  - Rounded UI with thick dark outlines and big mobile-friendly buttons.
  - Mobile support is very important.

=== WHAT IS ALREADY IN THE PLACE ===
Workspace.Map (built from Parts, visible in edit mode):
- Island: the floating grass island over a cloud sea.
- Clouds, MiniIslands.
- Roads: a ring road plus paths to the 8 plot spots.
- EdgeFence: includes invisible safety walls.
- RoadLamps, OuterDecor.
- StarterYard: a Model with attribute ZoneId="StarterYard". It contains a Decor folder (trees, bushes), a NodeSpawns folder (52 invisible Parts named "Spawn"; spawn Starter Yard nodes at their CFrames) and an invisible Bounds part.

Other setup:
- Workspace.Nodes, Workspace.Drops and Workspace.Effects are empty folders for runtime objects.
- Lighting is set up: Future, Atmosphere, Sky, Bloom, ColorCorrection, SunRays.
- StarterPlayer: CharacterWalkSpeed 20, CharacterJumpHeight 7.5, CameraMaxZoomDistance 110. Players.CharacterAutoLoads is true. StarterGui.ResetPlayerGuiOnSpawn is false. Workspace.StreamingEnabled is false.

Not built yet:
- No SpawnLocation, no Remotes folder, no Scripts or LocalScripts (only ModuleScripts). Pressing Play right now just lets you walk around the island.
- No hub, no plots, no zone islands, no gameplay, no UI.

=== EXISTING MODULES (ReplicatedStorage > Shared) ===
Config (folder of ModuleScripts; the numbers were tuned with an economy simulation, so don't rebalance unless I ask):
- Rarities: Common..Secret with Rank, Color, Glow, Announce. Get(id), Rank(id), FromRank(n).
- Materials: 63 materials (44 spawn in zones, plus boss, event and special ones). Fields: Id, Name, Short, Adj, Pure?, Rarity, Power, Weight, Zone?, Source?, SourceId?, Spawn (weight), Color, Color2, Material (Enum name string), Reflectance?, Transparency?, Glow?, Node (node style), Plate (plate style), Trait {Kind, Amount}, Desc. Materials.List, .ById, .ByZone[zoneId] (sorted by rarity), .Get(id).
- Mutations: 21 (16 natural + 5 event-only). Fields: Id, Name, Mult, Weight, Rarity, Color, Color2, Fx, Event?, Desc. Get(id), Mult(id).
- Qualities: Normal..Celestial. Fields: Mult, Weight, LuckPower, RebirthReq (Glitched needs 1 rebirth, Celestial needs 3), Color, Color2, Rank, Announce, Fx. Get(id).
- Refine: processing levels 0-4 (Raw, Ingot, Refined, Reinforced, Perfect). Each level takes 3 units of the previous one. Fields: Mult, Input, Seconds, FeePerPower, Pattern. Get(level), Max.
- Zones: 11 zones. Fields: Id, Name, Tier, Cost, RebirthReq, Toughness, MaxNodes, Color, Accent, Emoji, Blurb, MutationBias. Ids: StarterYard, Scrapyard, Mine, Factory, Volcano, FrozenCave, CrystalCavern (1 rebirth), Nuclear (2), MeteorCrater (3), Space (4), Void (5). Zones.List, .ById, .ByTier, .Count.
- Upgrades: 20 coin upgrades in groups Gather/Forge/Train. Fields: Id, Name, Emoji, Group, Desc, Cost {Base, Growth}, Values[level+1], Format. List, ById, Groups, GroupNames, MaxLevel(u).
- Rebirths: RequirementList (strength needed for each rebirth), RequirementGrowth, GainsPerRebirth, LuckPerRebirth, Ranks (names), RankName(n), RankColor(n), PlotTiers {Garage, Small Gym, Pro Gym, Future Lab, Titan Facility} with PlotTier(n), Unlocks (display text), EquipSlots(rebirths, hasPass), Perks (the rebirth shop) with PerkById, PerkCost(perk, level).
- Recipes: 30 secret recipes (Plates pair, Handle or "*", Mutation?, MinSize?, Mult, Rarity, Ability, Look, Hint), Abilities (stat bonuses + Special: ComboSaver, MeteorStrike, AbyssPulse, Glitch, Night, Day, Weightless). Recipes.Match(parts, plateSize) -> recipe or nil.
- Balance: global tunables, including SmashCooldown, SmashRange, NodeHealth, SmashDamage, ContributorWindow, NodeRespawnMin/Max, NodeMutationChance, PersonalMutationChance, LiftCooldown, LiftCooldownMin, ComboWindow, ComboTiers, CritChance/CritMult, SuperCritChance/SuperCritMult, CoinsPerStrength, FreeLiftWeight, StrengthPerKg, UnarmedGains, PlateSizeExponent, BalancedBonus, DumbbellMaxLevel, DumbbellXpBase/Exp, DumbbellLevelBonus, MaxDumbbells, ForgeTime, CoolingSeconds, CoolingMinRarity, MaterialSellPerPower, DumbbellSellFactor, FirstDiscoveryGems, OfflineMaxHours, OfflineEfficiency, TradeMinPlaySeconds, RookieProtectionSeconds, PotionMinutes.

Logic modules:
- ItemKey: material stacks are stored as string keys "Material|Refine|Mutation", e.g. "Iron|0|" or "Iron|2|Golden". Make(material, refine, mutation), Parse(key) -> {Material, Refine, Mutation} or nil (also validates), IsValid, UnitPower, UnitWeight, UnitValue, RarityRank, DisplayName.
- DumbbellStats: Compute(record) returns Name, Power (base gains per rep), Weight, RequiredStrength, Crit, CritPower, Super, Luck, Coins, Speed, Combo, ComboBonus, RarityRank, Rarity, Value, Balanced, Recipe, Ability, Special and Size. Also Name(parts, quality, recipe, knockoff) and PlateScale(size).
  A dumbbell record looks like: { Id = "userId-counter", Parts = { {Material, Refine, Mutation}, {handle...}, {right plate...} }, Size = plateSize, Quality = "Perfect", Level = 1, Xp = 0, Created, ForgedBy, ForgedByName, Tempered?, Knockoff?, Locked?, Favorite? }
- Formulas: Nice(n), UpgradeCost(upgrade, level), UpgradeValue(upgrade, level), RebirthRequirement(rebirths), RebirthMult(rebirths), RebirthTokens(rebirths), XpToNext(level), ComboBonus(combo, mastery), NextComboTier(combo), RequiredStrength(weight), SmashPower(strength, hammerMult), NodeToughness(zoneId, materialId, mutated), SmashDamage(power, toughness) (0 means too tough), HitsToBreak, MinSmashStrength, WeightedPick(rng, {{id, weight}}), QualityOdds / RollQuality(rng, luck, rebirths), RollMutation(rng, luck, bias, extra), MaterialWeights / RollMaterial(rng, zoneId, luck, boost), SellCap(highestTier). rng is a Random object.
- PlayerStats:
  - Compute(data, ctx) -> Luck, MaterialLuck, CraftLuck, MutationLuck, Gains, Coins, LiftCooldown, CritChance, CritMult, SuperChance, SuperMult, ComboWindow, ComboMastery, Backpack, WalkSpeed, JumpHeight, Hammer, SmashCooldown, Yield, ForgeTime, MaxPlateSize, ProcessSpeed, ProcessSlots, BossDamage, EquipSlots, AutoDeposit.
  - It reads data.Rebirths, data.Upgrades{id=level}, data.Perks{id=level}, data.Boosts{Luck/MegaLuck/Gains/Yield = expiry os.time()} and data.BonusLuck.
  - ctx = { Passes = {VIP, Backpack, FastForge, AutoProcess, ExtraSlot}, Event = {Gains, Luck, Coins, Crit, Speed}, Now }.
  - ForLift(stats, dumbbellStats) -> per-rep Power, Gains, Coins, Cooldown, CritChance, CritMult, SuperChance, SuperMult, ComboWindow, ComboMastery, Luck.
  - Strength per rep = Power * Gains * (1 + Formulas.ComboBonus(combo, ComboMastery)) * (crit multiplier). Coins per rep = the same with Coins in place of Gains, times Balance.CoinsPerStrength.
- Util.Format: Short(n) (1.23K, 4.5M ... Qa, Qi), Commas, Time, Clock, Percent, Mult, Chance, Weight.

Visuals (runtime model builders; all anchored or welded, using only Instance.new and CFrames):
- Visuals.DumbbellModel.Build(record, {CFrame, Scale, Anchored, Detail="High"/"Low", Effects, Name}) -> Model.
  - PrimaryPart = "Handle", which runs along the CFrame's X axis. If Anchored=false, every part is welded to the Handle, so weld the Handle to the character's RightHand.
  - It uses the real materials, plate styles, mutation and quality effects and recipe looks.
  - Model attributes: Length, PlateDiameter.
- Visuals.NodeModel.Build(materialId, mutationId, groundCFrame, seed) -> Model. PrimaryPart = "Hitbox" (invisible, CanQuery=true; raycast against it). The visible parts are anchored and collide.
- Visuals.MutationFx.Apply(parts, mutationId, emitterPart, scale), ApplyQuality(parts, quality, emitterPart, scale), Emitter(parent, props). They add CollectionService tags that the CLIENT must animate: "Rainbow" (hue cycle), "Glitch" (color flicker), "Flicker" (lights), "Celestial" and "Evolved" (glow pulse).
- Visuals.Parts: part/cyl/disc/ball/wedge helpers, weldAll, hash, rng.

=== MAP LAYOUT (for the parts still to build) ===
Polar convention: position(r, angleDeg, y) = Vector3.new(math.cos(a)*r, y, -math.sin(a)*r), where a = math.rad(angleDeg). The hub is centered at (0,0,0) and the ground top is at y = 0.

Hub:
- A plaza of radius 82.
- Launch pads on a ring of radius 50, one per zone at the same angle as its island: Scrapyard 0, Mine 36, Factory 72, Volcano 108, FrozenCave 144, CrystalCavern 180, Nuclear 216, MeteorCrater 252, Space 288, Void 324.
- NPC stalls / boards on a ring of radius ~74: ScrapDealer 0, Blacksmith 45, Scientist 90, Merchant 135, Coach 180, Strength board 225, Rebirths board 270, Richest board 315.
- The 8 plot paths enter the plaza at angles 22.5 + 45k, so keep those clear.
- The center holds a giant dumbbell monument with a fountain.

Starter Yard is the grass ring between the hub and the road. Ring road: radius 214, width 18.

Plots:
- Plot k (k = 0..7) is centered at position(298, 22.5 + 45k, 0). Its CFrame = CFrame.lookAt(center, Vector3.zero), so its local -Z points at the hub.
- Floor is 84 x 84, top at about y = 1. The entrance is at local z = -42, with a security gate about 20 studs wide.
- Local positions (x, z):
  - Forge: (0, 32), back center (anvil plus a furnace with a glowing mouth).
  - Cooling Rack: (16, 32).
  - Display stands: along the back wall at x = -34, -27, -20, 22, 29, 36 (z = 36), plus side spots (±38, 20) and (±38, 12). Up to 10 stands.
  - Material Storage: (-30, -26). Material Processor: (-30, 0).
  - Rebirth Machine: (28, -24). Upgrade Machine: (32, 2).
  - Best-dumbbell showcase: (12, -30), a glass dome.
  - Training mat: (0, -4), size 24 x 24.
  - Spawn: (0, -30), facing the hub.
  - Just outside the front: the player sign at (-30, -47) (avatar headshot via rbxthumb, name, Strength, rebirth rank, best dumbbell) and the owner's avatar statue at (32, -47).
- Plot looks by rebirth tier (Rebirths.PlotTier): Garage, Small Gym, Pro Gym, Future Lab, Titan Facility. Keep walls low so people can see in.

Zone islands (center = position(172, angle, height), top disc radius = Size):
- Scrapyard: angle 0, height 56. Mine: 36, 82. Factory: 72, 108. Volcano: 108, 134. FrozenCave: 144, 160. CrystalCavern: 180, 186. Nuclear: 216, 212. MeteorCrater: 252, 238. All size 46.
- Space: angle 288, height 268, size 48.
- Void: at the center, (0, 336, 0), size 56.
- Boss Arena: at the center, (0, 150, 0), size 62.
- Build each island like the main island: a themed top disc, stacked tapering rock cylinders underneath, irregular rock chunks and themed decor (car wrecks and a crane; mine carts and lanterns; pipes, conveyors and chimneys; a lava cone; ice spikes and snowy pines; glowing crystal clusters; a cooling tower and green pools; a glowing crater; moon craters and a satellite dish; void rift and floating shards).
- Each island gets a NodeSpawns folder of about 22 invisible "Spawn" parts, a Bounds part, a return pad to the hub, and a big floating name label.

=== ARCHITECTURE RULES ===
- ReplicatedStorage.Shared.Net (ModuleScript): the single list of every RemoteEvent / RemoteFunction name. The server creates them in ReplicatedStorage.Remotes at startup. Every OnServerEvent handler checks argument types and ranges and is rate-limited per player.
- ServerScriptService.Main (Script) requires ServerScriptService.Services.* (one ModuleScript per system with Init/Start): DataService, PlotService, NodeService, InventoryService, CraftingService, TrainingService, ZoneService, UpgradeService, RebirthService, IndexService, QuestService, AchievementService, EventService, BossService, MerchantService, TradeService, LeaderboardService, AnnounceService, HeistService, MonetizationService.
- StarterPlayer.StarterPlayerScripts.ClientMain (LocalScript) requires Controllers.* and a UI library (Theme + reusable components). Build the UI in code with one theme so everything looks consistent.
- DataService:
  - ProfileService-style session locking with UpdateAsync, autosave every 60s, save on leave and in BindToClose.
  - Schema version plus defaults reconcile, an in-memory fallback when Studio API access is off, and idempotent ProcessReceipt (store receipt ids).
  - Suggested data fields: Strength, Coins, Gems, RebirthTokens, Rebirths, Materials{key=count}, Backpack{key=count}, Dumbbells{id=record}, NextDumbbellId, Equipped{ids}, Displayed{ids}, Zones{id=true}, Upgrades, Perks, BonusLuck, Boosts, Index{Materials,Mutations,Qualities,Recipes,Events,Bosses}, IndexClaimed, Quests, Achievements, Stats (lifetime counters), Titles, Settings, Tutorial, Processing, Daily, Purchases, Security, LastOnline.
- Replication: send a full snapshot on join (DataInit), then small patches after each change (DataPatch). The client keeps a replica with change signals for the UI.
- Server-authoritative, always. Never trust the client for money, strength, materials, craft results, inventory, trades, rebirth or rewards. Validate distances (smash range, plot bounds), ownership and cooldowns on the server.
- Lifting animation: there are no animation assets, so pose the arms in code. Write Motor6D.Transform every frame in RunService.PreSimulation, which runs after the Animator (tweening Transform does not work because the Animator overwrites it). The server increments a "LiftSeq" attribute on the character each rep so every client animates every player.
- Sounds: keep all ids in Shared.Config.Sounds. Use built-in sounds that ship with every client (rbxasset://sounds/electronicpingshort.wav, button.wav, victory.wav, bass.wav, snap.mp3, clickfast.wav, action_get_up.mp3) until I swap in Creator Store sounds.
- Map geometry must be saved in the place, not built at runtime. For anything built from parts (hub, plots, islands, NPCs), write a builder ModuleScript in ServerStorage.Builders and give me the exact one-line command to paste into Studio's Command Bar (e.g. require(game.ServerStorage.Builders.PlotBuilder).Build()). Builders must delete and rebuild their own folder so they can be re-run safely. Runtime objects (nodes, held dumbbells, effects) use the Shared.Visuals modules.

=== BUILD ORDER ===
Phase 1:
- Net + remotes, DataService, player data.
- The 8 plots (builder) + PlotService: claim a free plot on join, spawn and respawn at your plot, the sign, releasing the plot on leave.
- HUD: Strength, Coins, Gems, Luck, backpack meter and menu buttons (Craft, Inventory, Upgrades, Index, Quests, Rebirth, Trade, Settings, Home).
- leaderstats.

Phase 2:
- Hub + zone islands (builders).
- NodeService: spawn nodes at NodeSpawns, click/tap raycast smashing validated on the server, contributors, drops with popups, backpack capacity, auto-deposit on your plot.
- Launch pads + zone unlock/access checks, and the inventory UI.

Phase 3:
- Forge UI: 3 slots + plate size, a live ViewportFrame preview built with DumbbellModel, stats from DumbbellStats, and a "Quick fill best" button.
- CraftingService: validate materials, roll quality, create the record, cooling rack.
- Dumbbell inventory (lock, favorite, sell), and equipping with the RequiredStrength check, welded to the hand.

Phase 4: training — lift input (click or a big LIFT button on mobile), the pose driver, gain popups, crit/super crit effects, combo meter, dumbbell XP and levels.

Phase 5: upgrades UI, rebirth + rebirth shop, collection index with rewards, daily/weekly quests, achievements and titles.

Phase 6: random events (15+), world bosses (10+), traveling merchant, processing, fusion, mutation lab.

Phase 7: trading (double confirm, atomic swap), leaderboards (OrderedDataStore), server announcements, heist + security.

Phase 8-10: tutorial (arrows, no text walls), polish (sounds, particles, UI animation), mobile layout, gamepasses and dev products, release checklist.

=== RULES FOR EVERY REPLY ===
1. Give complete, working Luau. Never write "add your code here" and never skip parts of a script.
2. For every script, give its exact name, its class (Script / LocalScript / ModuleScript) and its exact location in the Explorer.
3. List the RemoteEvents/RemoteFunctions and Instances the step needs.
4. Tell me exactly how to test it in Studio (Play, or Test > Start with 2+ players).
5. Mention likely bugs and exploits, and how the code prevents them.
6. Make sure every require path and every function you call from the existing modules matches the API above. If you need the full source of an existing module, ask me and I will paste it.
7. Keep the visual quality high: consistent colors, rounded shapes, Neon accents, no flat grey boxes, no free models.
8. Finish one phase per reply, then stop and wait for me to say "next".

Start now with Phase 1.
