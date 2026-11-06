# Round 1: economy-designer proposal (paper only, no sim, no bots)

Author: economy-designer, 2026-11-05. All numbers are PLACEHOLDERS for data/balance.json (new keys `skill_<ID>_*`, `skill_cost_<ID>`, `tech_goal_<ID>`); none written. I started from the feature seed (design/proposals/2026-11-05-skills-fill.md) and changed what failed the bar. Ids and slots kept: 35 of 35.

## Budget (from balance.json and gdd-skills.md)
- About 21 points per run. Fixed spend of a focused player: 3 FND (3) + FND_PERMIT already counted + permit_points_2 (2, system 2 holds gems and cells) + MKT_1 (1) + existing chain MKT_3 (2), MKT_5 (3), MKT_7 (3) = 14. **Spare is about 7 points** for new nodes in the focus market, about 0 for a second market.
- Yardstick: 1 point is worth about 8 to 10 percent of one line's income. S = 1 point (convenience, info, narrow), M = 2 (one clear edge, like MIL_3), L = 3 (like MIL_5 or LUX_5: changes a plan). T = 0 points, price is crafting time.
- Tech goals (units crafted in the market's workshop, counted from prereqs met; one workshop makes about 3 units a cycle, 6 with a second batch): existing 6 / 11 / 8 (2, 4, 6). New techs go serial after them: goal **8** (tier 2 techs), **12** (tier 3), **14** (tier 4 and deep). A market's seven techs-and-skills then need about 59 units of crafting if all taken: no run does all, so each tech costs real workshop time.
- Caps I want enforced in code or data: sum of unconditional `volume_pct` per market at most +0.20; sum of `sale_price_pct` per market at most +0.30 (price is potent: food margin is above 100 percent, so +10 percent revenue is more than +10 percent profit); `upkeep_floor` 0.5 already caps upkeep stacks; stored `event_cut_pct` sum at most 0.6.

## Foundations (outside the market gate, as the seed asks)
| id | cost | effect and number | note |
|---|---|---|---|
| FND_LEDGER | S | route net per cycle shown (info, no number) | weakest node: info only, 1 point. Keep only because it is cheap. Not a trap, a tempo choice. |
| FND_RIVAL_WATCH | S, needs LEDGER | rival 3 cycle projection (info) | DEAD RISK: a decent player reads the graphs. Fallback: merge into LEDGER, leave the slot empty. |
| FND_DOCKS | M, prereq FND_PERMIT (not PROSPECT: wide builders are permit people) | route upgrade cost x0.7 (900 to 630) | saves 270 a lane, about 3 lanes: roughly one ship for 2 points. Dead for a one-lane focus: a real fork. |

## Military (ships, fleet, pressure)
| id | cost | prereq | effect and number | why / competes / risk |
|---|---|---|---|---|
| MIL_8 Quartermaster | M | MIL_1 | ship price x0.85 (900 to 765) | saves 135 a ship, about 1 cycle of early tempo. Competes with MIL_3. Risk: helps always-expand; 0.15 is the ceiling, sim it before building. |
| MIL_9 Cell Press | T goal 8 | MIL_2 | mil volume +0.05 | small, free; crafts cells you need anyway. |
| MIL_10 Scrap Rights | M | MIL_3 | ship salvage_share 0.40 to 0.65 | REPLACES Hardened Stores: asteroid storage cuts are a rare event, so stock_protect on mil is DEAD. Scrap Rights makes restructuring cheap (still below price: no buy-sell loop). Thin; fallback is a second upkeep step 0.10 (floor 0.5 holds), but that copies MIL_1. |
| MIL_11 Proof Range | T goal 12 | MIL_4 | armour only sale price +0.12 (cash only) | line-specific, so it cannot stack into the general price cap. |
| MIL_12 Open Arsenal | M | MIL_4 | mil share window +4 (8 to 12) | RISK (trap for a climber): a longer window averages in your weak early cycles. Only valid if the code makes it help a leader. QA must check; BIO_5 (+12) has the same problem. |
| MIL_13 Pressure Doctrine | L | MIL_5 | embargo hit 0.5 to 0.6, timing unchanged (every 7, 5 cycles) | no cooldown cut: with every 5 and 5 cycles it would be a permanent 50 percent on the top rival. |
| MIL_14 War Economy | T goal 14 | MIL_6 | mil batch yield +1 (cells and armour 3 to 4) | strong output, free, late. |
| MIL_15 Last Line | L | MIL_7 + MIL_14 | all rivals mil strength -0.10 permanent | see stacks below. |

## Luxury (information, events, atelier)
| id | cost | prereq | effect and number | note |
|---|---|---|---|---|
| LUX_8 Salon Circle | M | LUX_1 | lux Buy and Sell order size x1.25 (40 to 50) | CHANGED from share_window (climber trap, see MIL_12). Throughput, needs a per-market filter on order_size_pct. Competes with LUX_3. |
| LUX_9 Second Loom | T goal 10 | LUX_2 | atelier +1 batch a cycle | doubles a lux workshop's output; tech so it is time-gated. |
| LUX_10 Trend Desk | M | LUX_3 | lux price-event damage -0.35 | pairs with warning; below MIL_6 (0.5). |
| LUX_11 Collector's Eye | T goal 12 | LUX_4 | gems only sale price +0.12 | line-specific. |
| LUX_12 Press Room | M | LUX_5B | lux route capacity +0.10 | equals MIN_5B size; gives the info branch a body. |
| LUX_13 Patron's Purse | **M** (seed said L) | LUX_5 | mixed-load bonus 0.05 to 0.15, cap 150 to 300, lux loads | already gated behind a 3 point node, so M is enough; a diversify-versus-focus fork. |
| LUX_14 Auction House | T goal 14 | LUX_6 | lux volume +0.06 | lux unconditional volume total 0.14, under the cap. |
| LUX_15 Grand Salon | L | LUX_7 + LUX_14 | all rivals lux growth x0.75 permanent | bot_2 lux growth 51.69 is the whole threat, so this bites; weaker than MIL_7 (x0.5) on purpose. |

## Minerals (mining, dead worlds, ore)
| id | cost | prereq | effect and number | note |
|---|---|---|---|---|
| MIN_8 Deep Hold | M | MIN_1 | ore planet-storage room +0.5 | pairs with MIN_2. DEAD RISK if ore never fills storage; QA to confirm. |
| MIN_9 Slag Reclaim | T goal 10 | MIN_2 | smelter ore per batch -1 (min 1) | crafting pays back in ore. |
| MIN_10 Safe Passage | M | MIN_3 | dead_ore_loss_chance 0.5 to 0.25 | makes MIN_5 pay; niche by design (dead-world line). |
| MIN_11 Hot Foundry | T goal 12 | MIN_4 | ingot only sale price +0.10 | line-specific. |
| MIN_12 Ore Brokers | M | MIN_5B | min price-event bonus +0.25 | upside for the safe side branch. |
| MIN_13 Null Core Tuning | **M** (seed said L) | MIN_5 | null_core_max 1 to 3, null_core_trip_mult 0.5 to 0.3 | seed version (mult only) saves about 15 a trip: a 3 point TRAP. With max 3 each fitted ship saves 42 a trip, about 1200 over a dead-world run. |
| MIN_14 Mass Smelting | T goal 14 | MIN_6 | min volume +0.06 | fine. |
| MIN_15 Motherlode | L | MIN_7 + MIN_14 | cluster richness +0.5 (120 to 180), survey fee x0.5 | CHANGED from a second yield step: richness is finite (120), so more yield per cycle only drains clusters sooner (a trap) and min rivals are already weak. Thin for L; fallback M. |

## Biotech (growing stock, storage, patience)
| id | cost | prereq | effect and number | note |
|---|---|---|---|---|
| BIO_8 Gel Cooperatives | M | BIO_1 | bio route capacity +0.125 | MIL_3 size, without immunity. Competes with BIO_3. |
| BIO_9 Spore Bank | T goal 10 | BIO_2 | culture lab +1 batch a cycle | |
| BIO_10 Cold Chain | M | BIO_3 | debris immunity on bio routes + bio event cut +0.2 | seed (immunity alone) was DEAD for 2 points; the cut makes it count (sum with BIO_6 0.6 max). |
| BIO_11 Graft Lines | T goal 14 | BIO_4 | bio batch yield +1 (seed 2 to 3 is +50 percent) | strong, late, tech. |
| BIO_12 Patient Orchard | L | BIO_5 | stock growth 0.02 to 0.03 a cycle AND cap 0.30 to 0.45 | seed (rate only) is DEAD: the cap bounds free stock, a faster rate only reaches it sooner. QA: check that sell and restock does not farm growth. |
| BIO_13 Market Days | M | BIO_5 | bio volume +0.15 at price-up planets, stock-fed sales only | near copy of LUX_5, so I require the stock-fed limit to give it its own place; REJECT if code cannot. |
| BIO_14 Living Contracts | T goal 14 | BIO_6 | seed only sale price +0.10 | line-specific. |
| BIO_15 Evergreen | L | BIO_7 + BIO_14 | all rivals bio growth x0.75 permanent | see stacks. |

## Auto-win and stack flags
1. **Military pressure stack** (highest risk): MIL_5 + MIL_13 + MIL_7 + MIL_15 costs 3+3+3+3, plus MIL_1, MIL_3, MIL_6 path and FND: 20 of 21 points, leaves nothing for a second tool. Rival mil total falls to about 0.57 of base inside an embargo window (top bot 61 percent of rival strength at -60 percent, growth halved, -10 percent). The 5 cycle hold fits exactly inside a 5 cycle embargo. Sim must show no win before cycle 23 (win_earliest_cycle) and win rate not above the focused-bot baseline.
2. **Biotech full stack**: bio has the weakest rivals (strength sum 1570), and BIO_5 window, stock growth, BIO_7, BIO_15 and two price techs all add. Cap bio rival cuts: BIO_7 and BIO_15 together at most about 0.4 effective.
3. **Workshop output stack** (MIL_2 + MIL_14, MIN_4 + MIN_6, LUX_9 + LUX_6, BIO_9 + BIO_11): +1 batch and +1 yield together roughly double a line. Free techs, but the goals (8 to 14 units) must not shrink or they become mandatory.
4. **Price stacks**: general plus line-specific sale price in one market stay under +0.30.
5. Always-expand: MIL_8 and FND_DOCKS both make wide play cheaper; re-sim always-expand after them (balance rule: it must still lose).

## Dead or weak (decision wanted in round 2)
FND_RIVAL_WATCH, MIL_10, MIN_8, MIN_15, BIO_13 (copy risk); MIL_12 (climber trap, needs a code check). Price techs MIL_11, LUX_11, MIN_11, BIO_14 are line-only on purpose, so thin but harmless.

## New keys needed (names only)
`skill_cost_<id>` for the 35 ids (S 1, M 2, L 3, T 0 as above); `tech_goal_<id>` 8/10/12/14 as listed; one effect key per row, e.g. `skill_MIL_8_ship_price` 0.15, `skill_MIL_13_hit` 0.6.
