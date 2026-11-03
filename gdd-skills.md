Star Bazaar: Skill Trees, Space Storage and Game Menu (design draft 2)
Date: 3 November 2026
Split out of gdd.md. Read only when your brief lists it. Owner: the project owner.

Status: DRAFT 2, rewritten for the Four Markets goal. It follows data/skills.json (data_version 1) and data/balance.json (data_version 39). Draft 1 (three branches Logistics, Research, Expansion with nodes A1 to C4, 20 points) is RETIRED; its old keys were removed from balance.json. Numbers are not in this file: they are [GCM:<key>] tokens that point to data/balance.json. Names are working names from story/skills.md; the owner judges them in play.

SECTION INDEX
  1. PRINCIPLES
  2. EXPANSION POINTS
  3. THE TREES (three Foundations, four market trees)
  4. SPACE STORAGE (FND_STORAGE)
  5. PERMITS (FND_PERMIT)
  6. SKILL TREE SCREEN
  7. GAME MENU
  8. DATA AND CODE HOOKS
  9. ENDINGS AND THE TREES
  10. OPEN QUESTIONS

========================================
1. PRINCIPLES
========================================
Money buys ships, workshops and fees, never skill points. Growth in ability comes from expansion and from share, so skills are bought with skill points ("expansion points" in data keys), never with credits.
Skills are finite and shared across markets, so the trees punish spreading: a focused run affords three Foundations and one market tree, two full markets are a stretch, four are out of reach.
Every node opens a way to play or says which number it changes. Respec is not planned.
Each market tree has four skills (cost points) and three tech nodes (cost no points, researched by crafting in that market's workshop).

========================================
2. EXPANSION POINTS
========================================
Points are earned once per event:
  - First visit to a planet: [GCM:skill_points_planet].
  - First route made between a new pair of planets, direction ignored: [GCM:skill_points_route].
  - First route or storage in a new system: [GCM:skill_points_system] (none in system 1).
  - First time the player's share in a market reaches 20%: [GCM:skill_points_share_20]; at 35%: [GCM:skill_points_share_35]. Once per market. This pays depth, not width.
Permits also cost points ([GCM:permit_points_2], [GCM:permit_points_3]; system 3 on hold).
The same planet, pair or system never pays twice. The player starts with 0 points; the home planet (Voltara) gives the first on cycle 1. On screen the name is "Skill points" (top bar and skill screen header). A notice appears when points are earned.
Supply: the design pack estimates about 21 points over a run against 13 needed for one market and 23 for two. This assumes 7 of 9 reachable planets and 5 route pairs and is UNKNOWN until the real game confirms it.

========================================
3. THE TREES
========================================
Three Foundations (not a market, not in endings), cost [GCM:skill_cost_FND_STORAGE], [GCM:skill_cost_FND_PERMIT] and [GCM:skill_cost_FND_PROSPECT] point each, learnable from cycle 1, order free:
  FND_STORAGE Space Storage: unlocks Space Storage (section 4).
  FND_PERMIT Permit Charter: permits for new systems and routes between systems (section 5).
  FND_PROSPECT Prospecting: routes may start at asteroid clusters.

Each market has seven nodes MKT_1 to MKT_7 (MIL, LUX, MIN, BIO) in five tiers. Skill nodes (1, 3, 5, 7) cost 1, 2, 3 and 4 points ([GCM:skill_cost_MIL_1] and so on, 10 in all). Tech nodes (2, 4, 6) cost 0 and complete by themselves after the player crafts the goal count of units in that market's workshop: [GCM:tech_goal_2], [GCM:tech_goal_4], [GCM:tech_goal_6] units, counted only from when the prerequisites are met. Prerequisites: 2 and 3 need 1; 4 needs 2; 5 needs 3; 6 needs 4 and 5; 7 needs 6. Sizes S, M, L map to [GCM:skill_size_s], [GCM:skill_size_m], [GCM:skill_size_l].

Military (workshop: Munitions Line)
  MIL_1 Drydock Deals (skill): ship upkeep lower ([GCM:skill_MIL_1_upkeep]); unlocks the Munitions Line and pulse cells.
  MIL_2 Cell Casting (tech): Military volume up (S).
  MIL_3 Quick Loading (skill): routes carrying Military goods move more per cycle ([GCM:skill_MIL_3_route_units]).
  MIL_4 Armour Plating (tech): unlocks hull armour; Military sale price up ([GCM:skill_MIL_4_price], cash only, no share effect).
  MIL_5 Embargo Desk (skill): every [GCM:skill_MIL_5_every] cycles pick one rival: its Military strength falls [GCM:skill_MIL_5_hit] for [GCM:skill_MIL_5_cycles] cycles.
  MIL_6 Contract Doctrine (tech): Military price events against the player cut by [GCM:skill_MIL_6_event_cut].
  MIL_7 Standing Fleet (capstone skill): all rivals' Military growth x[GCM:skill_MIL_7_growth_mult] for the rest of the run.
Luxury (workshop: Atelier)
  LUX_1 Price Whisper (skill): shows next cycle's prices; Luxury sale price up ([GCM:skill_LUX_1_price], cash only); unlocks the Atelier and cut glimmers.
  LUX_2 Fine Finishing (tech): Luxury price-up events pay [GCM:skill_LUX_2_event_bonus] more.
  LUX_3 Event Forecast (skill): the next event is announced one cycle early (all markets).
  LUX_4 Cask Cellar (tech): unlocks vintage cask; stored Luxury stock is not trimmed when an asteroid hit cuts a planet storage.
  LUX_5 Patron's List (skill): sales at a planet with a price-up event count extra volume (M).
  LUX_6 Hallmark (tech): Luxury sale price up ([GCM:skill_LUX_6_price], cash only).
  LUX_7 Guild Seal (capstone skill): once per run pick one rival: its Luxury strength falls [GCM:skill_LUX_7_hit] for [GCM:skill_LUX_7_cycles] cycles.
Minerals (workshops: Smelter, Fabric)
  MIN_1 Fabrication Licence (skill, needs FND_PROSPECT): unlocks the Smelter, the Fabric and ingots.
  MIN_2 Smelting (tech): Minerals volume up (S); ore Buy and Sell orders ignore the order-size cap.
  MIN_3 Cold Survey (skill): mine dross at Cinderrest; cluster yield up ([GCM:skill_MIN_3_yield]).
  MIN_4 Alloying (tech): unlocks seam alloy; Minerals workshop batches per cycle +[GCM:skill_MIN_4_batches].
  MIN_5 Deep Cut (skill): mine nullglass at Greywake.
  MIN_6 Lattice Works (tech): each Minerals batch yields +[GCM:skill_MIN_6_batch_bonus] unit.
  MIN_7 Cornered Seam (capstone skill): rivals' Minerals strength down [GCM:skill_MIN_7_strength_cut] for the rest of the run.
Biotech (workshop: Culture Lab)
  BIO_1 Standing Orders (skill): Buy and Sell orders move [GCM:skill_BIO_1_order_units] more; unlocks the Culture Lab and bio-gel.
  BIO_2 Culture Banks (tech): Biotech stock in planet storage grows [GCM:skill_BIO_2_stock_growth] a cycle, up to [GCM:skill_BIO_2_stock_cap] of the stored amount.
  BIO_3 Seed Bank (skill): planet storage capacity up ([GCM:skill_BIO_3_capacity]).
  BIO_4 Gene Splicing (tech): unlocks gene seed.
  BIO_5 Clinic Contracts (skill): the Biotech share window is [GCM:share_window_bio_bonus] cycles instead of [GCM:share_window].
  BIO_6 Hardy Strains (tech): Biotech events against the player cut by [GCM:skill_BIO_6_event_cut]; a closed planet reopens one cycle sooner.
  BIO_7 Patent Wall (capstone skill): rivals' Biotech strength down [GCM:skill_BIO_7_strength_cut] for the rest of the run.
Where the data and the proposal differ in size (for example LUX_5 and MIN_7), data/skills.json and balance.json win. Old skills A1 to C4, M1, M2 and F1 are mapped or dropped as in the design pack (core 3.5): Space Storage, Permit Charter and Prospecting became Foundations; Survey Beacon and Colonial Rights were dropped.

========================================
4. SPACE STORAGE (FND_STORAGE)
========================================
Space Storage is a Foundation skill, cost [GCM:skill_cost_FND_STORAGE] point. It is not free. Until it is learned the player has planet storage only.
Rules:
  - One space storage per system, much bigger than a planet storage. Capacity [GCM:space_storage_capacity].
  - It is company property and is set up on first use.
  - Planet storage transfers into it slowly (rate [GCM:planet_to_space_rate]).
  - Routes can run planet to space storage and space storage to space storage (between systems, with FND_PERMIT).
  - When a route breaks (no ship, blocked, a closed planet), the space storage keeps feeding the connection for a while.
  - Clicking a space storage shows its stock per commodity with the 5-line rating bar and its connections.
Owner answer 2026-11-01: sell orders draw from Space Storage stock (tasks T139, T64). Whether that is built is UNKNOWN to this file.
The old gate (A1 locked until all of system 1 was visited and one route made) belonged to draft 1; whether it still applies is UNKNOWN.

========================================
5. PERMITS (FND_PERMIT)
========================================
Permit Charter lets the player buy permits for other systems. Without it the permit button does not appear. Learning it does not open a system; each permit costs points ([GCM:permit_points_2], [GCM:permit_points_3]) and credits ([GCM:permit_2_cost], [GCM:permit_3_cost]). System 2 is in the Alpha; system 3 is on hold, so nothing exists to buy there.

========================================
6. SKILL TREE SCREEN
========================================
A "Skills" button in the top bar (hotkey K) opens the screen at any time; Esc or the button closes it; the game does not pause (owner decision). Layout is one block for the Foundations and one tree per market, each a chain from node 1. A header shows "Skill points: N". Node states: learned, available, locked (shows what it needs), and for tech nodes a crafting progress line (SK_<node>_CRAFT, "<workshop> crafts: n of goal"). Skills that act on a rival (Embargo Desk, Guild Seal) have a "Use on..." button and show "Ready in n cycles" or "Used this run". The screen shows no credits: "Skills cost skill points, never credits."

========================================
7. GAME MENU
========================================
A menu button in the top bar (hotkey Esc) opens a list built so entries can be added later. Entries: Resume, Skills, Competitors (the rival graphs and Recent moves log, see gdd.md Menu UI), Main menu (saves, confirms), Quit game (saves, confirms). Reserved for later, not built: Settings, Help, Statistics, Save and load slots. The menu pauses the game; the Skills screen opened from its own button does not.

========================================
8. DATA AND CODE HOOKS
========================================
  - data/skills.json holds id, market, kind, tier, prerequisites, cost, effect (type and key into balance.json) and tech_goal_key. The code reads it; nothing is hard-coded.
  - The game asks has_skill("<id>") wherever a skill changes a rule. Effect values are balance.json keys the Economy Designer can retune.
  - The save stores learned skills, tech progress, points and the hidden chain data; save version 2 (old saves dropped).

========================================
9. ENDINGS AND THE TREES
========================================
The old tier selection from learned skills (Bare, Partial, Full) is RETIRED with the Release and Corporation endings. The ending is picked by the market won and the hidden chain direction (gdd.md, "The endings"). The trees only add epilogue lines: the capstone of the win market (if learned), the techs done in the win market, and a rival that lost a tier.

========================================
10. OPEN QUESTIONS
========================================
  1. Are the tree names and sizes right in play? UNKNOWN until the owner plays.
  2. Do workshops matter enough for share, or only for tech and cash? UNKNOWN (see state.md).
  3. Is the point supply (about 21) right for one focused market? UNKNOWN until the real game confirms it.
  4. System 3 is on hold: does anything in the trees point at it? None of the nodes does.
