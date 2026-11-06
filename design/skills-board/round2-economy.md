# Round 2: economy-designer verdicts (paper only; no sim, no bots, data/ untouched)

Date 2026-11-05. All numbers are placeholders for data/balance.json (`skill_<ID>_*`, `skill_cost_<ID>`, `tech_goal_<ID>`). Costs: S 1 point, M 2, L 3, T 0 (crafting goal in units). Tech goals serial after the existing 6 / 11 / 8: tier 2 = 8 to 10, tier 3 = 12, tier 4 and deep = 14.
I read all four round1 files. Moves I made toward others: dropped Rival Watch, Hardened Stores, Deep Hold, Open Arsenal, all line-only price techs (E2 makes them need new filter code) and the Evergreen shape; took Yard Kits, Showcase, Pit-head Smelter, Strip Mining, Rival Whisper, Deep Shelf, Convoy Escort and Full Mobilisation from the feature set.

## Foundations
- **FND_1** Backs: all four (economy, feature, QA, story). AGREE. Route Ledger, no prereq, S, each route row shows net per cycle after trip cost and upkeep; warns when negative. No number.
- **FND_2** Backs: feature (Survey Drive) + story (Pathfinder Tuning). CHANGE from my Rival Watch (dead: graphs already show it; Rival Whisper takes the info role in LUX_8). Pathfinder Tuning, prereq FND_PROSPECT, S, Pathfinder flight time x0.7. No build-cost cut (would help always-expand).
- **FND_3** Backs: economy (Docks), nobody else. CHANGE: Lane Yard Credit (story to name), prereq FND_PERMIT, M, route upgrade cost x0.75 (900 to 675). REJECT feature's Lane Refit (level 3: tall play dominant) and QA's Bulk Orders (E1 global, a first-hour loan). Spare Bays: REJECT (dead without storage play). Cut candidate.

## Military
- **MIL_8** Backs: economy, QA, story (Quartermaster / Surplus Hulls). REJECT feature's lease (spam, new loop). AGREE. Surplus Hulls, MIL_1, M, ship price x0.85 (900 to 765). Floor at the cash reserve; always-expand must be re-simmed.
- **MIL_9** Backs: economy, story (volume); QA wanted +1 yield. AGREE. Cell Press, MIL_2, T goal 8, mil volume +0.05.
- **MIL_10** Backs: economy (Scrap Rights) + feature's Salvage Yard idea merged. REJECT Hardened Stores (dead: storage cuts are rare). CHANGE to: Scrap Rights, MIL_3, M, salvage share 0.40 to 0.65 (stays below a Sell order, no buy-sell loop). Fallback: leave empty.
- **MIL_11** Backs: feature (Yard Kits). CHANGE from Proof Range (needs a good filter, E2). Yard Kits, MIL_4, T goal 12: armour units pay part of a new ship price at 0.9 x base armour price, max 40 percent of the ship price per ship. Needs armour visible (Availability). Below sale value, and the payment gives no share, so no loop.
- **MIL_12** Backs: feature (Convoy Escort, moved from its MIL_9). REJECT Open Arsenal (climber trap, 3 of 4 wanted it; I will not sign without a code proof it helps a leader) and Dragnet (E5 multiplies hits). Convoy Escort, prereq MIL_4 (CHANGE from MIL_3), M: on a lane with 2+ ships, the 2nd and 3rd ship trip cost x0.8 (max 2 discounted ships per lane).
- **MIL_13** Backs: economy; feature wants empty; story wants recharge (REJECT, permanent embargo). CHANGE: Pressure Doctrine, MIL_5, L, embargo hit 0.5 to 0.6, timing unchanged. Weak on its own: first cut if the set is too big.
- **MIL_14** Backs: economy, story (+1 yield). AGREE. War Economy, MIL_6, T goal 14, mil batch yield +1. Feature's Salvage Yard is folded into MIL_10.
- **MIL_15** Backs: feature (Full Mobilisation). CHANGE from my Last Line (stack with MIL_5, MIL_7, MIL_13 left rivals near zero) and REJECT QA's Armada Rates (dead at the 0.5 floor). Full Mobilisation, MIL_7, L, once per run: 5 cycles of upkeep x0, trip cost x0.5, route events ignored. Sim before build (it must not make the win land before cycle 23).

## Luxury
- **LUX_8** Backs: feature (Rival Whisper). CHANGE from my Salon Circle (QA/story share window = climber trap). Rival Whisper, LUX_1, S (feature said M: 2 points for info is a skip), Competitors screen shows each rival's next tier-up cycle and its 3 cycle lead.
- **LUX_9** Backs: economy, QA, story. AGREE. Second Loom, LUX_2, T goal 10, atelier +1 batch a cycle. REJECT Pattern Books.
- **LUX_10** Backs: economy, QA, story. REJECT feature's Forward Contract (price lock, with LUX_5B too safe). CHANGE number to a mid value: Trend Desk, LUX_3, M, lux price-event damage -0.30 (QA 0.25, me 0.35). Lux total event cut at most 0.9.
- **LUX_11** Backs: feature (Showcase). CHANGE from Collector's Eye (E2: inert). Showcase, LUX_4, T goal 12: pick a planet, it counts as price-up for lux share (not cash) for 3 cycles, then 8 cycle cooldown (about 37 percent uptime, so LUX_5 does not become permanent). Needs gems visible.
- **LUX_12** Backs: economy, QA, story. REJECT Boutique Hold (a surcharge is not in my data; cash route risk). AGREE. Courier Pool (story's alt name), LUX_5B, M, lux route capacity +0.10.
- **LUX_13** Backs: economy, feature, story. CHANGE: Patron's Purse, LUX_5, **M** (I keep M: it already sits behind a 3 point node; owner may raise to L), mixed-load bonus 0.05 to 0.15, cap 150 to 300, lux loads only. REJECT QA's event bonus version.
- **LUX_14** Backs: economy, QA, story (volume). REJECT Auction Floor (idle stock). AGREE. Auction House, LUX_6, T goal 14, lux volume +0.06 (with LUX_2 0.08 total 0.14).
- **LUX_15** Backs: economy, QA, story. REJECT feature's Hand on the Scales (strongest skill, redirect needs a long cooldown and is luck removal). CHANGE number: Grand Salon, LUX_7 + LUX_14, L, all rivals lux growth x0.85 permanent (I proposed 0.75; QA warns bot_2 growth 51.69 crashes the market). Needs E3 fixed first. This is the only rival-cut capstone I back.

## Minerals
- **MIN_8** Backs: feature (Strip Mining). CHANGE from Deep Hold (dead risk) and QA's Deep Drill (more ore, runaway). Strip Mining, MIN_1, M: cluster yield per cycle +40 percent, richness unchanged (empties sooner, tempo for total). Min cluster rate total at most +0.6 with MIN_3.
- **MIN_9** Backs: economy, story. AGREE. Slag Reclaim, MIN_2, T goal 10, smelter ore per batch -1 (min 1). REJECT QA's +1 batch (stacks to 3 batches with MIN_4) and dross byproduct (loop).
- **MIN_10** Backs: economy, story. REJECT QA's event cut and Gleaning (trickle needs a new tail). AGREE. Safe Passage (story: Steady Hands), MIN_3, M, dead_ore_loss_chance 0.5 to 0.25.
- **MIN_11** Backs: feature (Pit-head Smelter). CHANGE from Hot Foundry (E2, thin). Pit-head Smelter, MIN_4, T goal 12, the Smelter may be built at a mining platform. Needs platform and smelter visible. No number; cost M for code.
- **MIN_12** Backs: economy, QA, story. REJECT Salvage Hands (debris farming). AGREE. Ore Brokers, MIN_5B, M, min price-up event bonus +0.25.
- **MIN_13** Backs: economy, feature (Twin Cores merged). CHANGE from my max 3 and mult 0.3: Null Core Tuning, MIN_5, M, null_core_max 1 to 2, null_core_trip_mult 0.5 to 0.4. Needs Null Core visible.
- **MIN_14** Backs: economy, QA, story. REJECT Dead-World Run (copy of MIN_10). AGREE. Mass Smelting, MIN_6, T goal 14, min volume +0.06.
- **MIN_15** Backs: economy. REJECT QA/story yield step (finite clusters, runaway) and Catch and Claim (rides a random event). CHANGE cost L to **M**: Motherlode, MIN_7 + MIN_14, M, cluster richness +0.5 (120 to 180), survey fee x0.5. Cut candidate.

## Biotech
- **BIO_8** Backs: economy, QA, story. AGREE with QA's number. Gel Cooperatives (story: Common Vats), BIO_1, M, bio route capacity +0.10.
- **BIO_9** Backs: economy, QA, story. REJECT slow mode. AGREE. Spore Bank, BIO_2, T goal 10, culture lab +1 batch a cycle.
- **BIO_10** Backs: feature (Cold Holds) + story (Deep Shelf). CHANGE from my Cold Chain. Deep Shelf, BIO_3, M: bio stock in Space Storage grows at 0.01 a cycle (half the BIO_2 rate), same cap. Blocked until QA E11 is answered (do grown units count toward share, at what price).
- **BIO_11** Backs: economy, QA, story; feature wants empty. CHANGE: Graft Lines, BIO_4, T goal 14, bio batch yield +1, but only if feature signs; with BIO_9 it is roughly x3 culture output, so goal stays 14. Else leave empty.
- **BIO_12** Backs: economy, feature, story. AGREE with feature's guard added. Patient Orchard, BIO_5, L, stock growth rate 0.02 to 0.03 and cap 0.30 to 0.45; no growth the cycle after a sale from that storage (anti farm). Blocked on E11.
- **BIO_13** Backs: economy (conditional), QA, story; feature wants empty. CHANGE: Market Days, BIO_5, M, bio volume +0.10 at price-up planets, units from stock only (its own place beside LUX_5). Leave empty if code cannot filter stock-fed units.
- **BIO_14** Backs: economy, QA, story. REJECT feature's Standing Contract (safe money). CHANGE: Living Contracts, BIO_6, T goal 14, bio sale price +0.06, cash only (market target, E2).
- **BIO_15** Backs: nobody fully. REJECT, leave empty: Evergreen copies Grand Salon (QA, story, me agree), and Living Link needs a Storage Link not yet played (feature said so). Revisit after play.

## (a) QA findings each backed skill must respect
E1: only existing nodes use target "all"; none of mine do. E2: no sale-price or good-targeted node on a good name; BIO_14 and MIL_11 use market or unlock paths. E3 (bot_strength_mult and bot_growth_mult ignore flags): fix before LUX_15 and MIL_13. E4: event cut per market at most 0.9 (LUX_10, existing MIL_6, BIO_6). E5: strength_mult floor 0.2 (MIL_13 at 0.6 is fine alone). E7 and E8: no duplicate max or boolean types added (none of mine). E10: upkeep floor 0.5 holds; I add no upkeep multiplier, MIL_15 surge is timed. E11: BIO_10 and BIO_12 blocked until answered. E12: points are one pool with permits. E13 and E14: owner decides, not me. E15: volume per market capped (below).

## (b) Stacks I accept or cap
- Unconditional volume per market at most +0.20 (lux 0.14, min about 0.12 with MIN_4, mil 0.05 plus existing).
- Sale price per market at most +0.30.
- Stored event_cut sum at most 0.6, rival-cut skills at most one capstone per run effectively (only LUX_15).
- Workshop output: batch +1 and yield +1 tech goals must not shrink below 8 to 14.
- Re-sim always-expand after MIL_8, FND_3, MIL_12 (must still lose) and the military pressure path (MIL_5, MIL_13, MIL_7, MIL_15): no win before cycle 23.

## (c) Cut list if the set is too big (first to last)
BIO_13, BIO_11, MIL_13, MIN_15, FND_3, MIL_10, MIN_11, LUX_8, MIL_15, LUX_15. Skip BIO_10, BIO_12 for now if E11 stays open. Leaves about 27 of 35 slots filled (empty: BIO_15; three or four others if cuts apply).
