Star Bazaar: Skill Trees, Space Storage and Game Menu (design draft 3)
Date: 5 November 2026
Split out of gdd.md. Read only when your brief lists it. Owner: the project owner.

Status: DRAFT 3, synced 2026-11-06 with data/skills.json (68 nodes: 6 Foundations, Military 15, Luxury 16, Minerals 16, Biotech 15) and data/balance.json. The tree was redone on 2026-11-05 (design/proposals/2026-11-05-skill-tree-final.md; rounds 2 and 3 in the same folder) and filled on 2026-11-06 (T207: three more Foundations and nodes 8 to 15 per market; design/proposals/2026-11-05-skills-fill.md). Draft 1 (branches A, B, C) is RETIRED. Numbers are not in this file: they are [GCM:<key>] tokens that point to data/balance.json, and the plain effect lines are in story/skills.md. Names are working names from story/skills.md; the owner judges them in play.

SECTION INDEX
  1. PRINCIPLES
  2. EXPANSION POINTS
  3. THE TREES (six Foundations, four market trees)
  4. SPACE STORAGE (FND_STORAGE) AND STORAGE LINK
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
Skills are finite and shared across markets, so the trees punish spreading: a focused run affords the three required Foundations and the core of one market tree; a full tree, let alone two markets, is a stretch, and four are out of reach.

A run has one branch (its CEO's market). The skill screen shows only the Foundations and that branch's tree; other trees are not drawn and their skills cannot be learned. Old saves without a branch show all trees.
Every node opens a way to play or says which number it changes. Respec is not planned. 2026-11-05 rule: filler percent nodes were removed; every node unlocks something, adds a mechanic or has a clear use.
Each market tree has a core of four skills (cost points) and three tech nodes (cost no points, researched by crafting in that market's workshop), plus eight fill nodes (five skills, three techs). Luxury and Minerals also have one side skill each (LUX_5B, MIN_5B).

========================================
2. EXPANSION POINTS
========================================
Points are earned once per event:
  - First visit to a planet: [GCM:skill_points_planet].
  - First route made between a new pair of planets, direction ignored: [GCM:skill_points_route].
  - First route or storage in a new system: [GCM:skill_points_system] (none in system 1).
  - Paying to deflect the asteroid event (one point, a fixed value in game/main.gd).
Permits also cost points ([GCM:permit_points_2]; the temporary placeholder system 3 reuses the system 2 keys as stand-ins).
The same planet, pair or system never pays twice. The player starts with 0 points; the home planet (Voltara) gives the first on cycle 1. On screen the name is "Skill points" (top bar and skill screen header). A notice appears when points are earned.
Supply: the design pack estimates about 21 points over a run against 12 needed for the Foundations plus one core market tree (core costs 1, 2, 3, 3 now, set 2026-11-05) and about 21 for two. The estimate dates from before the 2026-11-05 redo. This assumes 7 of 9 reachable planets and 5 route pairs and is UNKNOWN until the real game confirms it.

========================================
3. THE TREES
========================================
Six Foundations (not a market, not in endings, shown in every run), cost [GCM:skill_cost_FND_STORAGE] and so on. Three are required, listed in learning order: Permit Charter, Prospecting and Space Storage, learnable from cycle 1, order free (Space Storage also needs enough trade income, section 4); all three must be learned before any market-tree node can be learned (the first node of each tree needs them; until then every tree node shows muted and names the missing Foundations). Saves that already hold a tree skill keep it. The other three are optional and no tree node needs them.
  FND_PERMIT Permit Charter: permits for new systems and routes between systems (section 5).
  FND_PROSPECT Prospecting: routes may start at asteroid clusters.
  FND_STORAGE Space Storage: unlocks Space Storage (section 4).
  FND_LEDGER Route Ledger (no prerequisite): Buy and Sell orders move more per cycle (all goods). The proposed route-profit readout is not gated: route net per cycle is already shown to every player.
  FND_RIVAL_WATCH Market Watch (needs Route Ledger): price events against the player hit weaker in every market (the proposed rival-share readout is dropped: skills no longer read share or rivals).
  FND_DOCKS Dock Contracts (needs Prospecting): a lane upgrade costs less (effect upgrade_cost_pct).

Each market has seven core nodes MKT_1 to MKT_7 (MIL, LUX, MIN, BIO) in tiers 1 to 5, eight fill nodes MKT_8 to MKT_15 in tiers 2 to 6, and one side skill in Luxury and Minerals. Skill nodes (core 1, 3, 5, 7; fill 8, 10, 12, 13, 15; side skills) cost points, set per node in balance.json ([GCM:skill_cost_MIL_1] and so on). Tech nodes (core 2, 4, 6; fill 9, 11, 14) cost 0 and complete by themselves after the player crafts the goal count of units in that market's workshop: [GCM:tech_goal_2] for node 2, [GCM:tech_goal_4] for nodes 4 and 9, [GCM:tech_goal_6] for nodes 6, 11 and 14, counted only from when the prerequisites are met. Core prerequisites: 2 and 3 need 1; 4 needs 2; 5 needs 3; 6 needs 4 and 5; 7 needs 6; side skills need 3. Fill prerequisites: 8 needs 1; 9 needs 2; 10 needs 3; 11 needs 4; 12 needs 4 in Military, the side skill in Luxury and Minerals, and 5 in Biotech; 13 needs 5; 14 needs 6; 15 (tier 6, the last node) needs 7 and 14. The L size is [GCM:skill_size_l]; other sizes are balance keys named per node in data/skills.json. A node can carry a second effect (a price bonus, a good unlocked); the lines below name the main ones. Exact lines for the player are in story/skills.md.

Sale price bonuses are cash only: they never raise share. Need-fill skills make goods of their market count extra toward a world's needs (they no longer raise share); grace skills soften the progress lost when a world's needs go unmet.

Military (workshop: Munitions Line)
  MIL_1 Drydock Deals (skill): ship upkeep lower; unlocks the Munitions Line and rounds.
  MIL_2 Double Casting (tech): Military workshops make one more batch a cycle.
  MIL_3 Debris Pilots (skill): Military routes carry more per cycle and ignore debris events.
  MIL_4 Hull Works (tech): unlocks arms (second Military product).
  MIL_5 Embargo Desk (skill): every [GCM:skill_MIL_5_every] cycles pick one rival: its Military strength falls for a set time.
  MIL_6 Contract Doctrine (tech): Military events against the player cut; Military sale price up (cash only).
  MIL_7 Standing Fleet (capstone skill): all rivals' Military growth cut for the rest of the run.
  MIL_8 Yard Account (skill): a new ship costs less to buy (ship_price_pct).
  MIL_9 Cell Press (tech): Military units sold into a world's need count a little more toward it.
  MIL_10 Hardened Stores (skill): stored Military goods survive storage cuts.
  MIL_11 Proof Range (tech): Military sale price up (cash only).
  MIL_12 Open Arsenal (skill): worlds lose less progress on an unmet cycle (Military needs).
  MIL_13 Pressure Doctrine (skill): the Embargo Desk (MIL_5) recharges sooner (cooldown_cut, at least 1 cycle).
  MIL_14 War Economy (tech): each Military batch yields more units.
  MIL_15 Last Line (final skill, needs MIL_7 and MIL_14): rivals' Military strength down for the rest of the run.
Luxury (workshop: Atelier)
  LUX_1 Price Whisper (skill): shows next cycle's prices; unlocks the Atelier and attar.
  LUX_2 Fine Finishing (tech): Luxury units sold into a world's need count a little more toward it; Luxury sale price up (cash only).
  LUX_3 Event Forecast (skill): the next event is announced one cycle early (all markets).
  LUX_4 Cold Cellar (tech): unlocks gems (made only from second-system goods).
  LUX_5 Patron's List (skill): sales at a price-up planet count clearly more toward a world's need, and the event pays more.
  LUX_5B Long Ledger (side skill): prices and events are shown two cycles ahead.
  LUX_6 Hallmark (tech): each Luxury batch yields one more unit; Luxury sale price up (cash only).
  LUX_7 Guild Seal (capstone skill): every [GCM:skill_LUX_7_every] cycles pick one rival: its Luxury strength falls for a set time.
  LUX_8 Salon Circle (skill): worlds lose less progress on an unmet cycle (Luxury needs).
  LUX_9 Second Loom (tech): Luxury workshops make one more batch a cycle.
  LUX_10 Trend Desk (skill): Luxury price events against the player hit weaker.
  LUX_11 Collector's Eye (tech): Luxury sale price up (cash only).
  LUX_12 Press Room (skill, needs LUX_5B): Luxury routes carry more per cycle.
  LUX_13 Patron's Purse (skill): Luxury sales count more toward a world's need; the mixed-load bonus on Luxury is larger (bundle_bonus_pct, the cap still binds).
  LUX_14 Auction House (tech): Luxury units sold into a world's need count clearly more toward it.
  LUX_15 Grand Salon (final skill, needs LUX_7 and LUX_14): all rivals' Luxury growth cut for the rest of the run.
Minerals (workshops: Smelter, Fabric)
  MIN_1 Fabrication Licence (skill, needs Prospecting): unlocks the Smelter, the Fabric and ingots.
  MIN_2 Smelting (tech): orders for mined cargo ignore the order-size cap.
  MIN_3 Cold Survey (skill): routes may start at Cinderrest (dross); cluster yield up. Opens the platform for mining there.
  MIN_4 Twin Crucible (tech): Minerals workshops make one more batch a cycle.
  MIN_5 Deep Cut (skill): routes may start at Greywake (nullglass); needs MIN_3.
  MIN_5B Hard Hats (side skill): Minerals routes carry more and ignore debris; Minerals price events hit weaker.
  MIN_6 Lattice Works (tech): each Minerals batch yields one more unit; unlocks alloy; Minerals sale price up (cash only).
  MIN_7 Cornered Seam (capstone skill): rivals' Minerals strength down for the rest of the run.
  MIN_8 Deep Hold (skill): planet storage holds more (all goods; the proposed ore-only room needs per-good capacity and is not built).
  MIN_9 Slag Reclaim (tech): Minerals sales count more toward a world's need; workshop recipes take 1 less ore per batch (recipe_input_cut, never below 1).
  MIN_10 Safe Passage (skill): Minerals price events against the player hit weaker (the proposed dead-world ore loss has no mechanic in the game yet).
  MIN_11 Hot Foundry (tech): Minerals sale price up (cash only).
  MIN_12 Seam Brokers (skill, needs MIN_5B): Minerals price-up events pay more.
  MIN_13 Core Tuning (skill): trips of a ship with a Null Core cost less (null_core_trip_pct).
  MIN_14 Mass Melt (tech): Minerals units sold into a world's need count clearly more toward it.
  MIN_15 Motherlode (final skill, needs MIN_7 and MIN_14): cluster yield up again.
Biotech (workshop: Culture Lab)
  BIO_1 Culture Charter (skill): unlocks the Culture Lab and medicine.
  BIO_2 Culture Banks (tech): Biotech stock in planet storage grows a little each cycle, up to a cap; Biotech units sold into a world's need count more toward it.
  BIO_3 Deep Shelves (skill): planet storage holds more; the Biotech growth cap rises.
  BIO_4 Gene Splicing (tech): unlocks seed; Biotech sale price up (cash only).
  BIO_5 Clinic Contracts (skill): worlds lose less progress on an unmet cycle (Biotech needs); Biotech stock survives storage cuts.
  BIO_6 Hardy Strains (tech): Biotech events against the player cut; a closed planet reopens a cycle sooner; Biotech sale price up (cash only).
  BIO_7 Patent Wall (capstone skill): rivals' Biotech strength down for the rest of the run.
  BIO_8 Gel Cooperatives (skill): Biotech routes carry more per cycle.
  BIO_9 Spore Bank (tech): Biotech workshops make one more batch a cycle.
  BIO_10 Cold Chain (skill): Biotech routes ignore debris events.
  BIO_11 Graft Lines (tech): each Biotech batch yields more units.
  BIO_12 Patient Orchard (skill): stored Biotech stock grows faster each cycle, with its own higher cap.
  BIO_13 Market Days (skill): Biotech sales at a price-up planet count more toward that world's need.
  BIO_14 Living Contracts (tech): Biotech sale price up (cash only).
  BIO_15 Evergreen (final skill, needs BIO_7 and BIO_14): all rivals' Biotech growth cut for the rest of the run.
Where this list and data/skills.json differ, data/skills.json and balance.json win. The Foundations are Space Storage, Permit Charter and Prospecting; Survey Beacon and Colonial Rights were dropped. The tree redone on 2026-11-05 replaced earlier effects (for example Luxury and Biotech storage-cut protection moved to BIO_5; asteroid hits cut storage only for planets without that protection). The epilogue still treats node 7 as the capstone (section 9); node 15 is the last node of the tree. Known gap (2026-11-06): several fill-node player lines in story/skills.md (for example FND_LEDGER, FND_RIVAL_WATCH, FND_DOCKS, MIL_8, MIL_13, LUX_13, MIN_8, MIN_9, MIN_10, MIN_13) still describe the proposal effects, not the effects built in data/skills.json; the list above follows the data.

========================================
4. SPACE STORAGE (FND_STORAGE)
========================================
Space Storage is a Foundation skill, cost [GCM:skill_cost_FND_STORAGE] point. It is not free and it is earned: it can be learned once the company has earned enough credits from trade (no cycle condition; the amount is a balance value, [GCM:earn_storage_income]). Until it is learned the player has planet storage only.
The Space Storage node is muted like a locked node until the trade-income line is met. The first time the line is met in a run (and the skill is not yet learned), a warm event icon appears and stays until clicked; its window says Space Storage is available. It is a one-off notice with no effect on the game.
Rules:
  - One space storage per system, much bigger than a planet storage. Capacity [GCM:space_storage_capacity].
  - It is company property and is set up on first use.
  - Planet storage transfers into it slowly (rate [GCM:planet_to_space_rate]).
  - Routes can run planet to space storage and space storage to space storage (between systems, with FND_PERMIT).
  - When a route breaks (no ship, blocked, a closed planet), the space storage keeps feeding the connection for a while.
  - Clicking a space storage shows its stock per commodity with the 5-line rating bar and its connections.
Sell orders and routes at a planet draw on its system's Space Storage stock when planet storage is short (owner answer 2026-11-01; built, game/route_engine.gd sell_available). The old gate of draft 1 (visit all of system 1) is gone.
Storage Link: a goods-only bridge between the Space Storages of two systems (game/storage_link.gd, design/proposals/2026-11-05-storage-link.md). It needs Space Storage, an open system 2 and the goods it costs to be visible (rule storage_link in data/availability.json). Standing orders move stock each cycle without a ship; upkeep is paid in goods; a link goes dormant when upkeep fails and can collapse. Built in the working tree on 2026-11-05 and not yet run in play. Numbers: balance.json link_* keys.

========================================
5. PERMITS (FND_PERMIT)
========================================
Permit Charter lets the player buy permits for other systems. Without it the permit button does not appear. Learning it does not open a system; each permit costs points ([GCM:permit_points_2], [GCM:permit_points_3]) and credits ([GCM:permit_2_cost]). System 2 is in the Alpha. System 3 is a live temporary placeholder (names, prices and suns not designed yet) whose permits also need Permit Charter and reuse the system 2 cost keys; there are no further systems.

========================================
6. SKILL TREE SCREEN
========================================
A "Skills" button in the top bar (hotkey K) opens the screen at any time; Esc or the button closes it; the game does not pause (owner decision). Layout is one block for the Foundations and one tree per market, each drawn as tier rows from node 1 (a crowded tier wraps to a second line). The window fills the whole screen: with one market beside Foundations, every skill is drawn and the cells share all the width and height, so nothing needs a scroll. A header shows "Skill points: N". Node states: learned, available, locked (shows what it needs), and for tech nodes a crafting progress line (SK_<node>_CRAFT, "<workshop> crafts: n of goal"). Skills that act on a rival (Embargo Desk, Guild Seal) have a "Use on..." button and show "Ready in n cycles" or "Used this run". The screen shows no credits: "Skills cost skill points, never credits."

========================================
7. GAME MENU
========================================
A menu button in the top bar (hotkey Esc) opens a list built so entries can be added later. Entries: Resume, Skills, Competitors (the rival graphs and Recent moves log, see gdd.md section 3, Rivals), Main menu (saves, confirms), Quit game (saves, confirms), and a Voice on/off toggle. Shown locked, not built: Settings, Help, Statistics, Save and load slots (language is set on the main-menu Settings screen, not here). Saving is an autosave only (user://autosave.json). The menu pauses the game; the Skills screen opened from its own button does not.

========================================
8. DATA AND CODE HOOKS
========================================
  - data/skills.json holds id, market, kind, tier, prerequisites, cost, effect (type and key into balance.json) and tech_goal_key. The code reads it; nothing is hard-coded.
  - The game asks has_skill("<id>") wherever a skill changes a rule. Effect values are balance.json keys the Economy Designer can retune.
  - The save stores learned skills, tech progress, points and the hidden chain data; save version 8 (older versions load; versions below the minimum are dropped). Version 5 added the chosen CEO and ship type, 6 the Pathfinder, 7 storage links, 8 Pathfinder motion. Missing keys load as the plain default.

========================================
9. ENDINGS AND THE TREES
========================================
The old tier selection from learned skills (Bare, Partial, Full) is RETIRED with the Release and Corporation endings. The ending is picked by the market won and the hidden chain direction (gdd.md section 4, Endings). The trees only add epilogue lines: the capstone of the win market (if learned), the techs done in the win market, and a rival that lost a tier.

========================================
10. OPEN QUESTIONS
========================================
  1. Are the tree names and sizes right in play? UNKNOWN until the owner plays.
  2. Do workshops matter enough for share, or only for tech and cash? UNKNOWN until played.
  3. Is the point supply (about 21) right for one focused market? UNKNOWN until the real game confirms it.
  4. System 3 is a temporary placeholder: does anything in the trees point at it? None of the nodes does.
  5. The 2026-11-05 tree redo and retune were signed off by economy, feature and QA reviews on paper; whether they feel right in play is UNKNOWN until the owner plays.
