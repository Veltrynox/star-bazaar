# Skills board, round 1: feature-designer

Author: feature-designer. Date: 2026-11-05. Replaces the seed (design/proposals/2026-11-05-skills-fill.md), which stays only as history.

## What changed from the seed
- Dropped the thin ones: every price tech (MIL_11, LUX_11, MIN_11, BIO_14 as written), every percent tech (MIL_14, LUX_14, MIN_14, BIO_11), and the capstones that copied MIL_7 (`bot_strength_pct`/`bot_growth_mult` all_bots in x_15). Also dropped Salon Circle, Press Room, Market Days (copies of LUX_3/LUX_5) and the plain route-capacity nodes.
- Every node below does one of: a new decision per cycle, a new place to put things, a trade of tempo against total, a hazard turned into an option, or a new use of a system that exists (route level, mixed load, salvage, Space Storage, Storage Link, Null Core, asteroid event, debris event, Pathfinder).
- 32 of 35 slots filled. Empty on purpose: MIL_13, BIO_11, BIO_13 (reasons at the end).
- Numbers: none. Every "key" is for economy-designer. Costs: S 1 point, M 2, L 3, T tech (crafting goal). Techs are free, so each tech here is a qualitative change, not a stat. "NEW" = needs a new effect type in game/skills.gd; the rest reuse existing types.
- Availability: no node names a hidden good. Anything touching gems, alloy, armour, seed, lattice plate, Null Core or Storage Link must carry an Availability rule (listed per node).

## Foundations (optional, outside the market gate)

**FND_LEDGER** Route Ledger. Cost S, no prereq. NEW (unlock feature). Each lane shows net profit per cycle after trip cost and upkeep, and a warning when it is negative. Impact: the first-cycle information gap; the player stops guessing which lane is good. Competes with: the point that opens a market. Risk: reads like a UI feature that should be free; QA/economy may argue to drop the slot. I think a point is fair: it is a tempo-versus-clarity choice, and good players already read the panels.

**FND_SURVEY** Survey Drive. Cost S, no prereq. NEW (pathfinder speed and post/platform build cost). The Pathfinder flies faster and trading posts and platforms cost less. Impact: discovery is the slow early stretch; a player who wants a wide map early pays one point for tempo. Competes with: first market node. Risk: dead after the map is open, so keep it S. Owner: gameplay-programmer, small.

**FND_REFIT** Lane Refit. Cost M, prereq FND_PERMIT (not part of the gate). NEW (route level 3). A level-2 lane may be refitted once more for a fee. Impact: tall versus wide: sink points and cash into your best lane or spread. Competes with: market nodes; a one-lane player gets it, a wide player does not. Risk: could make the best lane dominant; economy must make the fee steep and the margin gain smaller than level 2.

## Military (ships, fleet cost, rival pressure)

**MIL_8 Leased Hulls.** S, prereq MIL_1. NEW (ship_lease). A new ship may be taken on lease: no purchase price, higher upkeep per leased ship. Impact: a cash-starved early game can add lanes sooner; late it is a drag, so a real fork. Competes with: MIL_3. Risk: lease spam; cap leased ships (economy). Owner: gameplay-programmer, M.

**MIL_9 Convoy Escort.** M, prereq MIL_3. NEW (lane_convoy_cut). On a lane with two or more ships, each extra ship pays less trip cost. Impact: rewards stacking ships on one lane (owner rule: shared lane), the opposite of spreading. Competes with: MIL_10, MIL_5 line. Risk: pairs with MIL_3 capacity; economy caps the stack.

**MIL_10 Watch Posts.** M, prereq MIL_3. NEW (absent_bonus_cut, all). Rivals' extra growth for markets where you are absent is reduced. Impact: lets a focused player skip a market without it running away; it is the anti-tax on focus. Competes with: MIL_9; MIL_5 (hit one rival now versus ease the tax everywhere). Risk: weakens the "spreading is punished" pillar. UNKNOWN: owner must say if that tax is meant to bite.

**MIL_11 Yard Kits.** T, prereq MIL_4. NEW (ship_part_payment). Armour units can pay part of a new ship's price. Impact: the Military workshop output becomes a way to grow the fleet, not only a sale. Competes with: selling armour for cash. Availability: needs armour visible. Risk: loop gain; economy values armour-per-ship.

**MIL_12 Dragnet.** M, prereq MIL_5. NEW (embargo targets two rivals, each weaker; shares the existing shared cooldown). Impact: choose one hard hit or two soft ones; changes the share race, not a number. Competes with: MIL_7 path for points. Risk: must not out-hit one chosen rival in total.

**MIL_13** empty (see end).

**MIL_14 Salvage Yard.** T, prereq MIL_6. NEW (salvage_rate, target all). Salvage sales of stuck stock pay a better share of price. Impact: dumping a lane's leftover becomes a plan; Military fits "keep the fleet running". Competes with: nothing needed, it is a tech; its cost is crafting time. Risk: must stay worse than a Sell order (rule in GDD).

**MIL_15 Full Mobilisation.** L, prereqs MIL_7. NEW (surge, once per run). For a set number of cycles every lane pays no upkeep and ignores route events. Impact: a timed decision: when to spend the one surge (before a tier check, an ending push, a rival wave). Competes with: nothing, it is the capstone; the choice is timing. Risk: economy must keep the surge from being the win by itself.

## Luxury (information, events, atelier)

**LUX_8 Rival Whisper.** M, prereq LUX_1. NEW (unlock feature). Competitors screen shows each rival's next tier-up cycle and where it will lead in three cycles. Impact: pick which market to push before the seal or embargo. Competes with: LUX_3. Risk: strong with MIL_5; fine, it is an information tree.

**LUX_9 Pattern Books.** T, prereq LUX_2. NEW (recipe_alt). Atelier recipes may use either of two inputs. Impact: sourcing flexibility when a planet closes or a price spikes. Availability: only inputs already visible. Risk: low.

**LUX_10 Forward Contract.** M, prereq LUX_3. NEW (price_lock). When an event is announced, lock one good at one planet at today's price for that cycle's sell orders. Impact: converts a warning into a choice: protect against a drop or give up a rise. Competes with: LUX_5B. Risk: with LUX_5B (two cycles of warning) could be too safe; economy sets one lock per N cycles.

**LUX_11 Showcase.** T, prereq LUX_4. NEW (showcase). Pick one planet: for a few cycles it counts as price-up for Luxury sales' share (not cash), then a cooldown. Impact: you place it, so which planet to feature is a decision. Availability: gems visible. Competes with: LUX_5 timing. Risk: must not make LUX_5 permanent.

**LUX_12 Boutique Hold.** M, prereq LUX_5B. NEW (mixed-load penalty removed for Luxury). Luxury goods ride on lanes of other markets without the mixed-load trip surcharge. Impact: lets Luxury piggyback, changes lane design. Competes with: LUX_13 (both are about mixing). Risk: must not make Luxury the free-rider of every lane.

**LUX_13 Patron's Purse.** L, prereq LUX_5. NEW (bundle_bonus larger). Selling several Luxury goods at one planet in a cycle pays more. Impact: diversify the cargo versus focus on one good. Risk: the existing cap per planet must stay.

**LUX_14 Auction Floor.** T, prereq LUX_6. NEW (conditional sell). A Luxury Sell order can be set to wait for a price-up planet; stock held until then. Impact: automates timing, keeps events relevant after the first ten cycles. Risk: stock sitting idle; Space Storage room is the cost.

**LUX_15 Hand on the Scales.** L, prereq LUX_7 and LUX_14. NEW (event_redirect). Every N cycles, move one announced price-up event to a planet you choose (same good). Impact: events stop being luck at the end of the tree. Risk: the strongest skill in the set; economy must set a long cooldown. It is a capstone, not a must-take.

## Minerals (mining, dead worlds, ore)

**MIN_8 Strip Mining.** M, prereq MIN_1. NEW (cluster_rate). A cluster yields more per cycle but empties sooner. Impact: clusters are finite and never refill, so this is a tempo-against-total choice. Competes with: MIN_10 (the opposite). Risk: ends mining early for a careless player; that is the cost.

**MIN_9 Slag Reclaim.** T, prereq MIN_2. NEW (smelter byproduct). Smelter runs return some dross as byproduct. Impact: crafting feeds mining, a loop, not a %. Availability: dross visible. Risk: loop gain; economy sets a cap.

**MIN_10 Gleaning.** M, prereq MIN_3. NEW (cluster_trickle). A depleted cluster keeps a thin trickle. Impact: lanes at empty clusters are not dead; supports a patient miner. Competes with: MIN_8. Risk: must stay far below a live cluster.

**MIN_11 Pit-head Smelter.** T, prereq MIN_4. NEW (workshop site: mining platform). The Smelter can be built at a platform. Impact: where you put the workshop becomes a decision (ship ore or smelt at source). Availability: platform and smelter visible. Risk: gameplay-programmer cost M.

**MIN_12 Salvage Hands.** M, prereq MIN_5B. NEW (debris_reward). Clearing a debris event pays out in ore instead of costing only a fee. Impact: a hazard becomes an option; gives the safe side branch an upside. Risk: farming debris if events are frequent; one per event.

**MIN_13 Twin Cores.** L, prereq MIN_5. NEW (null_core_extra). A second Null Core may be fitted. Impact: raises the one-per-run Null Core to two for the dead-world specialist. Availability: Null Core visible. Risk: thin outside the dead-world line; economy may fold it into a smaller node.

**MIN_14 Dead-World Run.** M, prereq MIN_3. NEW (dead_ore_loss_cut plus trip cost). Dead-world lanes lose less ore and cost less. Impact: makes MIN_5 and dross lanes a business, not a gamble. Competes with: MIN_8 and MIN_10 for points. Risk: low.

**MIN_15 Catch and Claim.** L, prereq MIN_6. NEW (asteroid_claim). Deflecting an asteroid leaves a rich cluster. Impact: the asteroid event becomes a mining opportunity. Risk: depends on a random event; economy must check that the run does not wait on luck.

## Biotech (stock that grows, storage, patience)

**BIO_8 Cold Holds.** M, prereq BIO_3. NEW (stock_growth where space_storage). Biotech grows in Space Storage too. Impact: where you store becomes a decision; deep players use the big stations. Competes with: BIO_5. Risk: with BIO_3 capacity it could be too strong; economy sets the cap.

**BIO_9 Spore Bank.** T, prereq BIO_2. NEW (workshop_slow_mode). A Culture Lab batch can be set to slow: output arrives later but larger. Impact: patience as a choice, not a stat. Risk: low.

**BIO_10 Standing Stock.** M, prereq BIO_3. NEW (stock_share_credit). Held Biotech stock above a floor counts a little toward share without selling, up to a cap. Impact: patience pays between sales. Competes with: BIO_5. Risk: highest in Biotech: holding must not beat selling for share; QA must test. Fallback: drop it and leave this slot empty.

**BIO_11** empty (see end).

**BIO_12 Patient Orchard.** L, prereq BIO_5. NEW (stock_growth_rate, with a one-cycle pause after a sale from that storage). Impact: sell now or leave stock to grow. Risk: numbers.

**BIO_13** empty (see end).

**BIO_14 Standing Contract.** T, prereq BIO_6. NEW (price_contract). Pick one planet and one Biotech good: a fixed price, immune to events (no upside). Impact: stable income against event swings; one planet is a real choice. Risk: could be safe money; economy must set the price below the average.

**BIO_15 Living Link.** L, prereq BIO_7. NEW (link stock growth). Biotech stock moved by a Storage Link keeps growing in transit and its upkeep is cheaper. Availability: rule `storage_link`. Impact: gives the Storage Link a place in the tree. Risk: Storage Link has not been run in play yet; build after it does.

## Empty slots, with reasons
- MIL_13: the only candidates were a shorter Embargo cooldown (a number on MIL_5) and a second hit (already MIL_12). Nothing distinct.
- BIO_11: Graft Lines was a batch percent. No Biotech play change left that BIO_9 does not already cover.
- BIO_13: Market Days copies LUX_5. Leave it for a later idea.

## Cost
gameplay-programmer: L (about 28 new effect types; many are small hooks, a few are real: lease, surge, event_redirect, price_lock, conditional sell, workshop site; may split in two or three tasks). economy-designer (owner starts by hand): values and tech goals. story-designer: 32 names and lines. ui-programmer: ledger, rival panel, lock/redirect controls, contract picker. doc-manager: gdd-skills.md.

## Questions
1. Do Foundations stay outside the gate (yes, assumed)?
2. Is the "absent in a market" tax meant to bite (MIL_10)?
3. UNKNOWN: are 28 new types too many for one release? A cut list in priority: drop BIO_10, MIL_15, LUX_15 and MIN_13 first.
