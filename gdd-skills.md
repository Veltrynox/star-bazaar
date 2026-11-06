Star Bazaar: Skill Trees, Space Storage and Game Menu (design draft 3)
Date: 5 November 2026
Split out of gdd.md. Read only when your brief lists it. Owner: the project owner.

Status: DRAFT 3, synced 2026-11-05 with data/skills.json (33 nodes: 3 Foundations, Military 7, Luxury 8, Minerals 8, Biotech 7) and data/balance.json. The tree was redone on 2026-11-05 (design/proposals/2026-11-05-skill-tree-final.md; rounds 2 and 3 in the same folder). Draft 1 (branches A, B, C) is RETIRED. Numbers are not in this file: they are [GCM:<key>] tokens that point to data/balance.json, and the plain effect lines are in story/skills.md. Names are working names from story/skills.md; the owner judges them in play.

SECTION INDEX
  1. PRINCIPLES
  2. EXPANSION POINTS
  3. THE TREES (three Foundations, four market trees)
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
Skills are finite and shared across markets, so the trees punish spreading: a focused run affords three Foundations and one market tree, two full markets are a stretch, four are out of reach.

A run has one branch (its CEO's market). The skill screen shows only the Foundations and that branch's tree; other trees are not drawn and their skills cannot be learned. Old saves without a branch show all trees.
Every node opens a way to play or says which number it changes. Respec is not planned. 2026-11-05 rule: filler percent nodes were removed; every node unlocks something, adds a mechanic or has a clear use.
Each market tree has four skills (cost points) and three tech nodes (cost no points, researched by crafting in that market's workshop). Luxury and Minerals also have one side skill each (LUX_5B, MIN_5B).

========================================
2. EXPANSION POINTS
========================================
Points are earned once per event:
  - First visit to a planet: [GCM:skill_points_planet].
  - First route made between a new pair of planets, direction ignored: [GCM:skill_points_route].
  - First route or storage in a new system: [GCM:skill_points_system] (none in system 1).
  - Paying to deflect the asteroid event (one point, a fixed value in game/main.gd).
  - First time the player's share in a market reaches 20%: [GCM:skill_points_share_20]; at 35%: [GCM:skill_points_share_35]. Once per market. This pays depth, not width.
Permits also cost points ([GCM:permit_points_2], [GCM:permit_points_3]; system 3 on hold).
The same planet, pair or system never pays twice. The player starts with 0 points; the home planet (Voltara) gives the first on cycle 1. On screen the name is "Skill points" (top bar and skill screen header). A notice appears when points are earned.
Supply: the design pack estimates about 21 points over a run against 12 needed for the Foundations plus one core market tree (core costs 1, 2, 3, 3 now, set 2026-11-05) and about 21 for two. The estimate dates from before the 2026-11-05 redo. This assumes 7 of 9 reachable planets and 5 route pairs and is UNKNOWN until the real game confirms it.

========================================
3. THE TREES
========================================
Three Foundations (not a market, not in endings), cost [GCM:skill_cost_FND_STORAGE], [GCM:skill_cost_FND_PERMIT] and [GCM:skill_cost_FND_PROSPECT] point each, learnable from cycle 1, order free (Space Storage also needs enough trade income, section 4): all three must be learned before any market-tree node can be learned (the first node of each tree needs them; until then every tree node shows muted and names the missing Foundations). Saves that already hold a tree skill keep it.
  FND_STORAGE Space Storage: unlocks Space Storage (section 4).
  FND_PERMIT Permit Charter: permits for new systems and routes between systems (section 5).
  FND_PROSPECT Prospecting: routes may start at asteroid clusters.

Each market has seven core nodes MKT_1 to MKT_7 (MIL, LUX, MIN, BIO) in five tiers, plus one side skill in Luxury and Minerals. Skill nodes (1, 3, 5, 7) cost points (core 1, 2, 3 and 3; side skills 2; see [GCM:skill_cost_MIL_1] and so on). Tech nodes (2, 4, 6) cost 0 and complete by themselves after the player crafts the goal count of units in that market's workshop: [GCM:tech_goal_2], [GCM:tech_goal_4], [GCM:tech_goal_6] units, counted only from when the prerequisites are met. Prerequisites: 2 and 3 need 1; 4 needs 2; 5 needs 3; 6 needs 4 and 5; 7 needs 6; side skills need 3. The L size is [GCM:skill_size_l]; other sizes are fixed in the effect code. A node can carry a second effect (a price bonus, a good unlocked); the lines below name the main ones. Exact lines for the player are in story/skills.md.

Sale price bonuses are cash only: they never raise share. Volume bonuses raise share but not cash.

Military (workshop: Munitions Line)
  MIL_1 Drydock Deals (skill): ship upkeep lower; unlocks the Munitions Line and cells (second system).
  MIL_2 Double Casting (tech): Military workshops make one more batch a cycle.
  MIL_3 Debris Pilots (skill): Military routes carry more per cycle and ignore debris events.
  MIL_4 Hull Works (tech): unlocks armour (second Military product).
  MIL_5 Embargo Desk (skill): every [GCM:skill_MIL_5_every] cycles pick one rival: its Military strength falls for a set time.
  MIL_6 Contract Doctrine (tech): Military events against the player cut; Military sale price up (cash only).
  MIL_7 Standing Fleet (capstone skill): all rivals' Military growth cut for the rest of the run.
Luxury (workshop: Atelier)
  LUX_1 Price Whisper (skill): shows next cycle's prices; unlocks the Atelier and cask.
  LUX_2 Fine Finishing (tech): Luxury sales count more toward share; Luxury sale price up (cash only).
  LUX_3 Event Forecast (skill): the next event is announced one cycle early (all markets).
  LUX_4 Cold Cellar (tech): unlocks gems (made only from second-system goods).
  LUX_5 Patron's List (skill): sales at a price-up planet count more toward share, and the event pays more.
  LUX_5B Long Ledger (side skill): prices and events are shown two cycles ahead.
  LUX_6 Hallmark (tech): each Luxury batch yields one more unit; Luxury sale price up (cash only).
  LUX_7 Guild Seal (capstone skill): every [GCM:skill_LUX_7_every] cycles pick one rival: its Luxury strength falls for a set time.
Minerals (workshops: Smelter, Fabric)
  MIN_1 Fabrication Licence (skill, needs Prospecting): unlocks the Smelter, the Fabric and ingots.
  MIN_2 Smelting (tech): orders for mined cargo ignore the order-size cap.
  MIN_3 Cold Survey (skill): routes may start at Cinderrest (dross); cluster yield up. Opens the platform for mining there.
  MIN_4 Twin Crucible (tech): Minerals workshops make one more batch a cycle.
  MIN_5 Deep Cut (skill): routes may start at Greywake (nullglass); needs MIN_3.
  MIN_5B Hard Hats (side skill): Minerals routes carry more and ignore debris; Minerals price events hit weaker.
  MIN_6 Lattice Works (tech): each Minerals batch yields one more unit; unlocks alloy; Minerals sale price up (cash only).
  MIN_7 Cornered Seam (capstone skill): rivals' Minerals strength down for the rest of the run.
Biotech (workshop: Culture Lab)
  BIO_1 Culture Charter (skill): unlocks the Culture Lab and gel (second system).
  BIO_2 Culture Banks (tech): Biotech stock in planet storage grows a little each cycle, up to a cap; Biotech sales count more toward share.
  BIO_3 Deep Shelves (skill): planet storage holds more; the Biotech growth cap rises.
  BIO_4 Gene Splicing (tech): unlocks seed; Biotech sale price up (cash only).
  BIO_5 Clinic Contracts (skill): the Biotech share window is longer; Biotech stock survives storage cuts.
  BIO_6 Hardy Strains (tech): Biotech events against the player cut; a closed planet reopens a cycle sooner; Biotech sale price up (cash only).
  BIO_7 Patent Wall (capstone skill): rivals' Biotech strength down for the rest of the run.
Where this list and data/skills.json differ, data/skills.json and balance.json win. The Foundations are Space Storage, Permit Charter and Prospecting; Survey Beacon and Colonial Rights were dropped. The tree redone on 2026-11-05 replaced earlier effects (for example Luxury and Biotech storage-cut protection moved to BIO_5; asteroid hits cut storage only for planets without that protection).

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
Permit Charter lets the player buy permits for other systems. Without it the permit button does not appear. Learning it does not open a system; each permit costs points ([GCM:permit_points_2], [GCM:permit_points_3]) and credits ([GCM:permit_2_cost], [GCM:permit_3_cost]). System 2 is in the Alpha; system 3 is on hold, so nothing exists to buy there.

========================================
6. SKILL TREE SCREEN
========================================
A "Skills" button in the top bar (hotkey K) opens the screen at any time; Esc or the button closes it; the game does not pause (owner decision). Layout is one block for the Foundations and one tree per market, each a chain from node 1. A header shows "Skill points: N". Node states: learned, available, locked (shows what it needs), and for tech nodes a crafting progress line (SK_<node>_CRAFT, "<workshop> crafts: n of goal"). Skills that act on a rival (Embargo Desk, Guild Seal) have a "Use on..." button and show "Ready in n cycles" or "Used this run". The screen shows no credits: "Skills cost skill points, never credits."

========================================
7. GAME MENU
========================================
A menu button in the top bar (hotkey Esc) opens a list built so entries can be added later. Entries: Resume, Skills, Competitors (the rival graphs and Recent moves log, see gdd.md section 5), Main menu (saves, confirms), Quit game (saves, confirms), and a Voice on/off toggle. Shown locked, not built: Settings, Help, Statistics, Save and load slots (language is set on the main-menu Settings screen, not here). Saving is an autosave only (user://autosave.json). The menu pauses the game; the Skills screen opened from its own button does not.

========================================
8. DATA AND CODE HOOKS
========================================
  - data/skills.json holds id, market, kind, tier, prerequisites, cost, effect (type and key into balance.json) and tech_goal_key. The code reads it; nothing is hard-coded.
  - The game asks has_skill("<id>") wherever a skill changes a rule. Effect values are balance.json keys the Economy Designer can retune.
  - The save stores learned skills, tech progress, points and the hidden chain data; save version 7 (older versions load; versions below the minimum are dropped). Version 5 added the chosen CEO and ship type, 6 the Pathfinder, 7 storage links. Missing keys load as the plain default.

========================================
9. ENDINGS AND THE TREES
========================================
The old tier selection from learned skills (Bare, Partial, Full) is RETIRED with the Release and Corporation endings. The ending is picked by the market won and the hidden chain direction (gdd.md, "The endings"). The trees only add epilogue lines: the capstone of the win market (if learned), the techs done in the win market, and a rival that lost a tier.

========================================
10. OPEN QUESTIONS
========================================
  1. Are the tree names and sizes right in play? UNKNOWN until the owner plays.
  2. Do workshops matter enough for share, or only for tech and cash? UNKNOWN until played.
  3. Is the point supply (about 21) right for one focused market? UNKNOWN until the real game confirms it.
  4. System 3 is on hold: does anything in the trees point at it? None of the nodes does.
  5. The 2026-11-05 tree redo and retune were signed off by economy, feature and QA reviews on paper; whether they feel right in play is UNKNOWN until the owner plays.
