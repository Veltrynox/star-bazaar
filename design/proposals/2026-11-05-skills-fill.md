# Skills fill (T207): every empty slot gets a skill

Author: feature-designer. Date: 2026-11-05. Approval waived by the owner (asked three times); T208 builds it.

## How many slots
The Skill screen draws UI-only dashed slots (`PLACEHOLDER_GROWTH` 2.0 in `game/skill_screen.gd`): a branch gets (nodes x 1) slots, in rows of its width. Today that is 3 (Foundations, one per row) + 8 each for Military, Luxury, Minerals, Biotech (rows of 2) = 35. This proposal adds 35 nodes: 3 Foundations and 8 per market (5 skills, 3 techs). Skill points are scarce (about 21 per run), so the new nodes are width and depth, not obligation: nobody takes them all.

Cost classes: S = 1 point, M = 2, L = 3, T = tech (0 points, researched by crafting in that market's workshop, goal set by economy-designer). Effect sizes: economy-designer sets all numbers; none here. "New type" = needs a new effect type in `game/skills.gd`; others reuse a type in the data vocabulary with another target. Position = prereqs; the tier follows from them.

Rules kept: money never buys points; choices are neutral; no node is a must-take (each competes with a sibling for points); a tech is free, so it cannot be a trap, and its price is crafting time.

## Foundations (optional, do NOT join the gate: market trees still need only STORAGE, PERMIT, PROSPECT)
- FND_LEDGER (S, no prereq). New type: unlock feature, Route Ledger: each route shows net profit per cycle after trip cost and upkeep. Fills the missing-information gap in the first cycles. A reader's tool, no stat: choice is 1 point of tempo for clarity.
- FND_RIVAL_WATCH (S, FND_LEDGER). New type: unlock feature. The Competitors screen shows each rival's projected share in 3 cycles. Lets you pick the market to push before the embargo or seal. Not a must: a good player already reads the graphs.
- FND_DOCKS (M, FND_PROSPECT). New type: route upgrade cost down. For wide route builders; useless to a one-lane focus, so a real fork.

## Military (identity: ships, fleet cost, rival pressure)
- MIL_8 Quartermaster (M, MIL_1). New type: ship price down. MIL_1 only cuts running cost; this cuts buying. Early fleet versus MIL_3 capacity.
- MIL_9 Cell Press (T, MIL_2). Share volume of Military up. Craft cells instead of shipping them.
- MIL_10 Hardened Stores (M, MIL_3). Reuse stock_protect, target mil: asteroid storage cuts do not trim Military stock. Pays only to players who store; the storage-heavy player's choice against MIL_5.
- MIL_11 Proof Range (T, MIL_4). Armour sale price up, cash only. Rewards finishing the armour line.
- MIL_12 Open Arsenal (M, MIL_4). Reuse share_window, target mil: Military share lasts longer. Defends a lead against rivals recovering.
- MIL_13 Pressure Doctrine (L, MIL_5). New type: Embargo Desk cooldown shorter. Deepens a pressure build; useless without MIL_5, which is its prereq, so no trap.
- MIL_14 War Economy (T, MIL_6). Reuse batch_yield, target mil.
- MIL_15 Last Line (L, MIL_7 and MIL_14). Reuse bot_strength_pct permanent all_bots (as MIN_7/BIO_7). Capstone extension; economy-designer must check it does not stack MIL_7 into an auto-win.

## Luxury (identity: information, events, atelier)
- LUX_8 Salon Circle (M, LUX_1). Reuse share_window, target lux. Early hold on share; competes with LUX_3 warning.
- LUX_9 Second Loom (T, LUX_2). Reuse workshop_batches, target lux. Atelier output up.
- LUX_10 Trend Desk (M, LUX_3). Reuse event_cut_pct, target lux: price events against you cut. Pairs with warning: see it coming, then soften it.
- LUX_11 Collector's Eye (T, LUX_4). Gems sale price up, cash only. Rewards the gems line.
- LUX_12 Press Room (M, LUX_5B). Reuse route_capacity_pct, target lux. Gives the information side branch a body.
- LUX_13 Patron's Purse (L, LUX_5). New type: mixed-load bonus larger (bundle_bonus exists). Choice: diversify cargo versus focus.
- LUX_14 Auction House (T, LUX_6). Reuse volume_pct, target lux.
- LUX_15 Grand Salon (L, LUX_7 and LUX_14). Reuse bot_growth_mult permanent all_bots, target lux. Lux capstone only hits one chosen rival; this is the long game.

## Minerals (identity: mining, dead worlds, ore)
- MIN_8 Deep Hold (M, MIN_1). New type: ore storage room up (target ore). Pairs with free ore slots.
- MIN_9 Slag Reclaim (T, MIN_2). New type: smelter inputs cost fewer ore. Crafting pays back in ore.
- MIN_10 Safe Passage (M, MIN_3). New type: dead-world ore loss chance cut (balance dead_ore_loss_*). Makes MIN_5 worth the risk.
- MIN_11 Hot Foundry (T, MIN_4). Reuse sale_price_pct, target min, cash only.
- MIN_12 Ore Brokers (M, MIN_5B). Reuse event_bonus_pct, target min. Gives the safe side branch an upside.
- MIN_13 Null Core Tuning (L, MIN_5). New type: Null Core trip cost lower. Only for the dead-world line (MIN_5 prereq).
- MIN_14 Mass Smelting (T, MIN_6). Reuse volume_pct, target min.
- MIN_15 Motherlode (L, MIN_7 and MIN_14). Reuse cluster_yield_pct, second step (stacks with MIN_3, economy-designer to cap).

## Biotech (identity: stock that grows, storage, patience)
- BIO_8 Gel Cooperatives (M, BIO_1). Reuse route_capacity_pct, target bio. Early lane size versus BIO_3 storage.
- BIO_9 Spore Bank (T, BIO_2). Reuse workshop_batches, target bio.
- BIO_10 Cold Chain (M, BIO_3). Reuse event_immune, target bio, kind debris.
- BIO_11 Graft Lines (T, BIO_4). Reuse batch_yield, target bio.
- BIO_12 Patient Orchard (L, BIO_5). New type: stock growth rate up. Choice: leave stock to grow or sell it now.
- BIO_13 Market Days (M, BIO_5). Reuse volume_pct with condition sale_at_price_up_planet, target bio. Parallels LUX_5; timing sales to events.
- BIO_14 Living Contracts (T, BIO_6). Reuse sale_price_pct, target bio, cash only.
- BIO_15 Evergreen (L, BIO_7 and BIO_14). Reuse bot_growth_mult permanent all_bots, target bio.

## Cost and owners
- gameplay-programmer (T208), L: 35 nodes in `data/skills.json`; 11 nodes with new effect types (FND_LEDGER, FND_RIVAL_WATCH, FND_DOCKS, MIL_8, MIL_13, MIN_8, MIN_9, MIN_10, MIN_13, LUX_13, BIO_12; they share some code); extend Availability, tests, set `SHOW_PLACEHOLDERS` false once full (the growth rule would add 50% empty slots again).
- economy-designer (owner starts by hand): `skill_cost_*`, effect sizes, tech goals. Not run here.
- story-designer: names and plain lines (English, Russian).
- ui-programmer: Route Ledger readout, Rival Watch panel, skill screen rows.
- doc-manager: `gdd-skills.md` sync.

## Weakest nodes (owner may merge or drop)
MIL_11, LUX_11, MIN_11, BIO_14 (price techs) and MIL_14, LUX_14, MIN_14 (percent techs) are the thinnest: free, small, little decision beyond crafting time. Kept because the owner asked for every slot filled.

## Questions
1. Do the three optional Foundations stay outside the market gate (assumed yes)?
2. Capstone extensions (x_15): keep two capstones per market?
3. UNKNOWN: do 11 new effect types fit one build task? gameplay-programmer may split T208.
