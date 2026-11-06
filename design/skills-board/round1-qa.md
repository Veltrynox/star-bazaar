# Round 1, qa-analyst: player-experience and exploit review of the empty skill slots

Date: 2026-11-05. Author: qa-analyst (owner-called, paper review only). No bots, no qa/bots/*, no tools/sim.py were run. Numbers are placeholders for the economy-designer; the "QA guard" values are limits this review needs, not tuning proposals.

Read for this round: data/skills.json (data_version 8), game/skills.gd, game/skill_tree.gd, data/balance.json (data_version 59), game/route_engine.gd (lines 197, 281, 650), game/markets.gd (share, win, lines 144 and 264), game/chains.gd (line 170), game/main.gd (permits, lines 689-720; points, 475-525), and design/proposals/2026-11-05-skills-fill.md, 2026-11-05-more-skills.md, 2026-11-05-more-skills-round2.md as seeds only.

## 1. What the code does that every slot must respect

These are facts from the code. Each one is a trap or a break risk for a new node.

- E1. "all" is a wildcard. `Skills._hits` matches a node whose target equals the market or is "all". A sum effect (volume, route capacity, sale price, event cut, storage, order size, workshop batches) with target "all" applies to every market at once. Only the existing reveal, warning and order-size nodes should use "all".
- E2. A "good" target is silently inert for sale price. `Skills.sale_price_mult(m)` matches market ids only. A node with target "good" and type sale_price_pct would never apply. The "good" target is safe only for unlock effects, which do not check it. Any new good-priced node must target its market.
- E3. Two bot queries ignore flags. `bot_strength_mult` checks `permanent` but not `pick`. `bot_growth_mult` checks neither. A future permanent chosen-bot effect, or a temporary growth effect, would apply to all bots for the rest of the run. Fix before any such node is added.
- E4. Event cut sums and clamps at 1.0 (`Skills.event_cut`). Two nodes of 0.5 in one market give full immunity to price events in that market. MIL_6 is 0.5, BIO_6 0.4, MIN_5B 0.3 today. A new node in one of these markets must keep the market total at or under 0.9 (QA guard).
- E5. Chosen-bot hits multiply. `hit_bot` multiplies the rival's strength by (1 + amount) and clamps at 0. MIL_5 (hit 0.5) and any second Military chosen-bot node both hit the same rival, so one rival can fall to a quarter of strength. The shared lock (`shared_cooldown_key`) no longer exists in data (removed in v55), so `Skills.shared_cooldown_every()` is dead code and MIL_5 and LUX_7 are fully independent.
- E6. Chosen-bot uptime is high. MIL_5: 5 of every 7 cycles at -50 percent on one rival (about 71 percent uptime). LUX_7: 8 of every 9 cycles at -40 percent (about 89 percent). These are close to permanent single-rival cuts, so a second chosen-bot node in the same market doubles the effect.
- E7. Several effects are max-based, so duplicates are dead purchases. `share_window` takes the max, `reveal_cycles` takes the max, `warning_cycles` takes the max, `stock_growth_cap` takes the max. A second node of the same type in a market adds nothing.
- E8. Several effects are boolean, so duplicates are dead: `event_immune` (per market and kind), `ore_free_slots`, `stock_protect`, `unlock`.
- E9. `reopen_sooner` sums every learned node with no market filter. Any new reopen node applies to all planets.
- E10. Upkeep is multiplicative and floored: `upkeep *= max(upkeep_floor 0.5, ship x skills x CEO thrift)`. MIL_1 (0.8) plus a second upkeep node (0.8) reach 0.64. A third reaches 0.51. Beyond that the floor binds and the node is dead. Upkeep nodes are therefore capped in effect at about three.
- E11. Stock growth (BIO_2) adds units from nothing (`grow_stock`, no input cost). Any node that raises the rate or the cap creates goods. Whether grown units count toward share, and at what price they sell, is UNKNOWN from the code read and must be checked before any stock node is added.
- E12. Points are one pool. Permits cost points too (`permit_points`, 2 each for systems 2 and 3, deducted in `buy_permit`). Every skill competes with a permit as well as with siblings. The Foundations gate (three points) is required before any market node.
- E13. Share points reward spreading. `award_share_points` pays once per market at 20 percent (1 point) and 35 percent (2 points). A player at 20 percent in all four markets collects up to 12 points; a focused player collects about 3. The "spreading is punished" pillar is only true if the share thresholds are hard to reach in several markets. UNKNOWN from paper; needs a run to check.
- E14. Pacing targets sit under the win gate. `win_earliest_cycle` is 23. `targets.win_full_tree_cycles` is 19 to 23, so its bottom three cycles cannot be reached by any build. Skilled target 22 to 26 is reachable. Owner to confirm the full-tree band is meant to be unreachable, or to be lowered.
- E15. Techs are free to finish, so they are never traps for points. A tech becomes a de facto must-take when it adds share (volume), a cap or a yield to a market with no other source. The count of free volume techs per market is the pacing risk.

## 2. Branch read: what a player feels, traps, must-takes, stack breaks

Foundations (3 new optional slots, outside the market gate). Felt: first-cycle tempo and clarity. Traps: a pure readout that changes no number. Must-takes: none, the gate stays at three points. Stack breaks: order size with ore free slots.

Military (8 slots). Felt: ship count and rival pressure (the strongest felt tree). Traps: duplicate max or boolean effects (E7, E8). Must-takes: none new. Stack breaks: two chosen-bot hits on one rival (E5), event cut reaching 1.0 (E4), and the upkeep floor (E10).

Luxury (8 slots). Felt: prices, events, atelier output. Traps: reveal and warning duplicates (E7), a cash-only tech that does nothing for share. Must-takes: a free volume tech stacks with LUX_2 (sum 0.16 free share). Stack breaks: capstone growth cut crushing the strongest lux rival (bot 2, growth 51.69), and "good" targets (E2).

Minerals (8 slots). Felt: mining income and ore. Traps: cluster yield stacking linearly across three nodes. Must-takes: a free workshop-batch tech (MIN_9) that feeds MIN_4. Stack breaks: ore free slots with bulk orders, batch yield and cluster yield together, which makes ore a runaway income.

Biotech (8 slots). Felt: stock, storage, the culture lab. Traps: boolean debris immunity with no bio route on debris. Must-takes: none new. Stack breaks: a stock rate rise (E11) makes free goods; with storage cap and BIO_3 they compound. Growth cut duplicates the Luxury capstone shape (E3, distinctness).

## 3. Slot proposals

Cost classes: S = 1 point, M = 2, L = 3, T = tech (0 points, crafting). "New type" means a code hook is needed. Every new node needs a story text id, an Availability rule if it names a feature, good or workshop, and a line in gdd-skills.md (doc-manager). Tests are written later by the gameplay-programmer; QA runs the bot ablations later, at the owner's request.

### Foundations (3)

FND_BULK "Bulk Orders" (M, no prereq). Effect: order_size_pct, target all, small. Felt: each Buy and Sell moves more in cycles 1 to 10. Trap: a first-hour loan, dead once cash binds. Stack break: global via "all" (E1); with ore free slots it lifts ore dumps (check stock never negative). Competes: the market gate. Test: order amount equals base times (1 + sum); cash never below zero after buys; owner cash curve for cycles 1 to 10 against baseline.

FND_LEDGER "Route Ledger" (S, no prereq). Effect: unlock feature route_ledger (new feature id, UI panel). Felt: each route shows net profit after trip cost and upkeep. Trap: changes no number; a player who reads the panels gets nothing. Must not gate anything. Test: readout equals RouteEngine net for every route; hidden until unlocked (Availability test).

FND_DEPOT "Spare Bays" (S, prereq FND_STORAGE). Effect: storage_cap_pct, target planet_storage, small. Felt: planet storage holds more, matters only with stock play and storage cuts. Trap: alone it is dead for a player who does not store. Stack: sums with BIO_3 (0.5). Test: planet storage capacity equals base times (1 + sum); Space Storage unaffected (UNKNOWN whether it shares the planet_storage target; check).

### Military (8)

MIL_8 "Quartermaster" (M, MIL_1). Effect: ship price down, new type ship_price_pct. Felt: second and third ship earlier. Trap: ship_cap 20 and the cash reserve bind, so the gain fades. Stack break: cheaper ships with always-expand feed fixed-cost starvation (balance history v24). Competes: MIL_3 capacity, MIL_1 upkeep. Test: cash after each buy stays at or above the reserve; ships by cycle 10 against baseline.

MIL_9 "Cell Press" (T, MIL_2). Effect: batch_yield, target mil, +1. Felt: more cells per batch. Trap: none (free). Must-take risk: low, but it is free crafting in the Military workshop. Test: units out equal batches times (base + yield); inputs consumed per batch unchanged.

MIL_10 "Hardened Stores" (M, MIL_3). Effect: stock_protect, target mil. Felt: only on asteroid storage cuts. Trap: dead unless the player stores Military stock. Test: a storage cut keeps mil stock and still trims other markets.

MIL_11 "Armoured Lanes" (M, MIL_4). Effect: event_cut_pct, target mil, small. Felt: fewer price-down hits on Military. Stack break: with MIL_6 (0.5) the total must stay at or under 0.9 (E4). Test: event_cut("mil") at or under 0.9 for every Military combination (tools/tests assertion).

MIL_12 "Open Arsenal" (M, MIL_4). Effect: share_window, target mil. Felt: Military share holds longer; the hold of five cycles is easier to keep. Trap: max-based (E7), a second share_window node in Military is dead. Test: share_window("mil", 8) returns the node's value and a duplicate changes nothing.

MIL_13 "Second Embargo" (L, MIL_5). Effect: bot_strength_pct, chosen_bot, its own duration and cooldown keys. Felt: two rival hits in a window, a real choice of rival. Stack break: two hits on one rival multiply (E5), and with MIL_15 or MIL_7 the rival nears zero. QA guard: rival strength_mult never below 0.2 of base for any learned Military set. Competes: MIL_5 uptime (E6). Test: learn MIL_5 and MIL_13, hit the same bot twice, assert strength_mult at or above the guard; both skills show "Use on".

MIL_14 "Escort Contracts" (T, MIL_6). Effect: volume_pct, target mil, small, unconditional. Felt: a small share lift for Military. Trap: free share (E15); it is a must-take only if it is cheap in crafting time. Test: share multiplier equals 1 + sum; the tech cannot be crafted before MIL_6 is learned.

MIL_15 "Armada Rates" (L, MIL_7 and MIL_14). Effect: upkeep_mult, target ships. Felt: trip and maintenance costs fall for a big fleet. Trap: the floor (E10) makes it dead once the ship type, CEO thrift and MIL_1 already sit at the floor. Test: upkeep never below upkeep_floor 0.5; the saving is visible only above the floor.

### Luxury (8)

LUX_8 "Salon Circle" (M, LUX_1). Effect: share_window, target lux. Felt: Luxury share holds longer. Trap: max-based (E7). Stack: a longer window dilutes a late surge, so check the lux win cycle does not move later. Test: share_window("lux") equals the node's value; win hold timing unchanged for a fixed share path.

LUX_9 "Second Loom" (T, LUX_2). Effect: workshop_batches, target lux, +1. Felt: atelier output doubles. Must-take risk: free output in the Luxury workshop. Test: batches per cycle equal base plus sum; inputs consumed per batch.

LUX_10 "Trend Desk" (M, LUX_3). Effect: event_cut_pct, target lux, small (0.25). Felt: after the forecast, the player softens price-down events. Pair with LUX_3 is the strongest pair in the tree; check against the LUX_5 path. Guard: lux total at or under 0.9. Test: event_cut("lux") and the event count with the forecast owned.

LUX_11 "Collector's Eye" (T, LUX_4). Effect: sale_price_pct, target lux, cash only (share_effect false). Felt: more cash from Luxury sales. Trap: pure cash, no share, so a player who needs share ignores it. Must target lux, not the good name (E2). Test: sale_price_mult("lux") rises; share unchanged.

LUX_12 "Press Room" (M, LUX_5B). Effect: route_capacity_pct, target lux, small. Felt: more units per Luxury lane. Competes: LUX_5 volume. Test: units per route for Luxury goods equal base times (1 + sum).

LUX_13 "Patron's Purse" (L, LUX_5). Effect: event_bonus_pct, target lux. Felt: price-up events pay more cash. Stack: sums with LUX_5 (0.25); total pays up to +50 percent of event pct, safe. Trap: event-chasing if the bonus outgrows sales. Test: event payout equals base times (1 + bonus) for Luxury price-up events; no share change.

LUX_14 "Auction House" (T, LUX_6). Effect: volume_pct, target lux, small, unconditional. Felt: small share lift. Stack: sums with LUX_2 (0.08) to 0.16 free share (E15). Owner or economy to decide whether two free volume techs in one market are wanted. Test: share multiplier; lux win cycle at or after 23 across the seed set (owner run).

LUX_15 "Grand Salon" (L, LUX_7 and LUX_14). Effect: bot_growth_mult, all_bots, permanent, mild (0.75). Felt: Luxury rivals grow more slowly for the run. Break: multiplicative with LUX_7 and the bot 2 growth (51.69); may crash the lux market before cycle 23. Trap: shape copy of BIO_15 (see there). Test: needs E3 fixed first; then owner ablation for lux win cycle.

### Minerals (8)

MIN_8 "Deep Drill" (M, MIN_1). Effect: cluster_yield_pct, target min, small. Felt: more ore per cluster, so more mining income. Stack: sums with MIN_3 (0.25) and MIN_15. Guard: min cluster total at or under 0.6. Trap: dead without a cluster route (FND_PROSPECT). Test: cluster yield equals base times (1 + sum); ore per cycle capped by route cargo as before.

MIN_9 "Slag Reclaim" (T, MIN_2). Effect: workshop_batches, target min, +1. Felt: smelter makes more ingot batches. Stack: sums with MIN_4 (+1), so three batches a cycle against a base of one. Must-take risk: free output in a market that is also a Minerals win route. Test: batches equal base plus sum; ore consumed per batch; net margin per batch above zero at the price table.

MIN_10 "Safe Passage" (M, MIN_3). Effect: event_cut_pct, target min, small (0.2). Felt: Minerals price events hit less. Stack: with MIN_5B (0.3) the total is 0.5; guard at or under 0.9. Test: event_cut("min") at or under 0.9 for every combination.

MIN_11 "Hot Foundry" (T, MIN_4). Effect: sale_price_pct, target min, cash only, small. Felt: more cash on ore and ingot sales. Trap: pure cash, free, harmless; not a share tool. Test: sale_price_mult("min") rises; share unchanged.

MIN_12 "Ore Brokers" (M, MIN_5B). Effect: event_bonus_pct, target min. Felt: the safe side gets an upside on price-up events. Test: payout equals base times (1 + bonus) on Minerals price-up events only.

MIN_13 "Long Haul" (L, MIN_5). Effect: route_capacity_pct, target min, small. Felt: Minerals lanes carry more per cycle. Stack: sums with MIN_5B (0.1). Competes: MIN_8 for points. Test: units per Minerals route equal base times (1 + sum).

MIN_14 "Mass Smelting" (T, MIN_6). Effect: volume_pct, target min, small, unconditional. Felt: small Minerals share lift. Trap: free share (E15). Test: share multiplier equals 1 + sum; cannot be crafted before MIN_6.

MIN_15 "Motherlode" (L, MIN_7 and MIN_14). Effect: cluster_yield_pct, target min, second step. Felt: a big mining income late in the run. Break: stacks with MIN_8 and MIN_3, so the same 0.6 guard on the min cluster total applies; and the ore flood must still hit the storage limit. Test: ore per cycle never exceeds storage room plus sales; Minerals win cycle at or after 23 (owner run).

### Biotech (8)

BIO_8 "Gel Cooperatives" (M, BIO_1). Effect: route_capacity_pct, target bio, small (0.1). Felt: Biotech lanes carry more per cycle; Biotech has no route buff today. Competes: BIO_3 for points. Test: units per Biotech route equal base times (1 + sum).

BIO_9 "Spore Bank" (T, BIO_2). Effect: workshop_batches, target bio, +1. Felt: the culture lab makes more batches. Trap: free output; grown stock (E11) is separate and must not be confused with batch output in the tests. Test: batches equal base plus sum; inputs consumed.

BIO_10 "Cold Chain" (M, BIO_3). Effect: event_immune, target bio, kinds debris. Felt: Biotech routes ignore debris events. Trap: boolean and only felt when a debris lane carries Biotech goods (E8). Test: debris event on a Biotech route does not fire; on other markets it fires as before.

BIO_11 "Graft Lines" (T, BIO_4). Effect: batch_yield, target bio, +1. Felt: more culture lab units per batch. Test: units out equal batches times (base + yield).

BIO_12 "Patient Orchard" (L, BIO_5). Effect: stock_growth_pct, target bio, small rate rise. Felt: stored Biotech stock grows faster. EXPLOIT RISK (E11): free units. QA guard: rate sum at or under 0.03; the cap stays as BIO_2 and BIO_3 set it. Test: grown units equal rate times stored amount, never above cap times stored amount; grown units do not add share until sold (UNKNOWN, must check). Do not ship before that check.

BIO_13 "Market Days" (M, BIO_5). Effect: volume_pct, target bio, condition sale_at_price_up_planet, small. Felt: timing Biotech sales to price-up events. Competes: BIO_5 window. Test: volume_bonus_price_up("bio") equals the node's value; unconditional volume unchanged.

BIO_14 "Living Contracts" (T, BIO_6). Effect: sale_price_pct, target bio, cash only. Felt: more cash from Biotech sales. Trap: pure cash, harmless, free. Test: sale_price_mult("bio") rises; share unchanged.

BIO_15 "Evergreen" (L, BIO_7 and BIO_14). Effect: bot_growth_mult, all_bots, permanent, mild. Felt: Biotech rivals grow more slowly. Break: stacks with BIO_7 (strength cut 0.25); may crash the bio market before cycle 23. Distinct role issue: this is the same shape as LUX_15 (growth cut on one market). Alternative if the owner wants a different role: a stock-growth cap raise with no rate change, which only matters with BIO_2 running. Test: needs E3 fixed; owner ablation for bio win cycle.

## 4. Tests to write later (for the gameplay-programmer and the owner; not run here)

Unit (tools/tests, always allowed to run):
- each new node: learnable only after its prereqs; points deducted by its balance cost; effect hook returns base times (1 + sum) or the boolean.
- E1 and E2: no new sum node uses target "all" unless listed; no new sale-price node uses a good name.
- E3: bot_strength_mult and bot_growth_mult honour pick and permanent (fix first).
- E4: event_cut per market stays at or under 0.9 with every combination of Military, Luxury, Minerals and Biotech nodes.
- E5: two chosen-bot hits on one rival keep strength_mult at or above 0.2.
- E10: upkeep never below upkeep_floor.
- E7 and E8: duplicates of max and boolean effects leave the value unchanged.
- E11: grown stock units never exceed cap times stored amount; growth adds no cash.
- Availability: any new feature (route_ledger), workshop or good has its rule.

Stack (tools/tests, deterministic): learn every node of a branch plus all three Foundations, then assert share in [0, 1], cash not negative after buys, no rival strength at zero, and the win is not declared before win_earliest_cycle.

Bot ablation (owner, later, by hand): decent bot with and without each node, four strategies, for win cycle and share. Flag any node that moves the win before cycle 23 or makes a must-take (win rate drops more than 20 points without it). This is the only place bots run; not in this round.

## 5. Weakest slots (for the merge discussion)

LUX_11, MIN_11 and BIO_14 are pure cash techs: harmless, but they change no share, so the owner may drop them. BIO_15 and LUX_15 are the same shape; one of them should change role. MIN_14, LUX_14 and MIL_14 add free share: the owner should decide how many free volume techs a market may carry before the pacing check fails.

## 6. Open questions (UNKNOWN from paper)

- Do grown stock units (BIO_2) count toward share, and at what price do they sell? Blocks BIO_12.
- Does FND_DEPOT's planet_storage target also cover Space Storage?
- How often do players reach 20 and 35 percent share in several markets (E13)? Needs a run.
