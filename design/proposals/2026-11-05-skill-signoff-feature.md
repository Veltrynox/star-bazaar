# Skill tree final sign-off (feature-designer, 2026-11-05)

Read: skills.json (data_version 3, 31 nodes), balance.json (skill_*, tech_goal_*), round 2 doc, resource-final doc, QA final review. No data or code edited. Numbers come from economy-designer; I set none.

## Verdict
SIGN OFF with 3 CHANGE notes (LUX_7, MIL_7, LUX_2) and no REJECT. Open item for the owner: the percent count (section 3).

## 1. All 31 nodes
Legend: AGREE / CHANGE (small, owner or economy decides) / REJECT. Reach is from QA; "unmeasured" is a test gap, not a design flaw.

| node | call | one line |
|---|---|---|
| FND_STORAGE | AGREE | Real choice: opens Space Storage; no number. |
| FND_PERMIT | AGREE | Opens permit routes; a rule, not a percent. |
| FND_PROSPECT | AGREE | Opens cluster routes; first step to mining. |
| MIL_1 | AGREE | Upkeep -20% plus munitions and cells: a market pick with a rule and a feel. |
| MIL_2 | AGREE | Tech: +1 munitions batch; goal 6 units made. Plain but earned by crafting, and the cells chain needs it. |
| MIL_3 | AGREE | +12.5% capacity is felt (QA: -29% cash if removed); debris immunity is a flavour extra, not the reason. Do not sell it as debris. |
| MIL_4 | AGREE | Armour unlock, 4 cells: new good, new route, and now feedable with 2 raws. |
| MIL_5 | AGREE | Pick a bot, -50% for 5 of every 7 cycles: the best active skill, a choice each use. |
| MIL_6 | AGREE | Event cut 50% plus +6% price: weak alone, fine as a tech payoff. Event half unseen (3 of 25 events). |
| MIL_7 | CHANGE | Bots grow x0.5 for the rest of the run is the strongest capstone. Ask economy to confirm it cannot make mil trivial late. |
| LUX_1 | AGREE | Price preview plus atelier and cask: information is a real choice. |
| LUX_2 | CHANGE | Three percents (volume +8%, price +6%, event bonus +50% on 2 of 25 events). The most "filler" tech. Suggest keep only volume and price; the event bonus is dead text. |
| LUX_3 | AGREE | Event warning 1 cycle, cost 2: pure information, lets the player react. |
| LUX_4 | AGREE | Gems from 2 silk + 1 musk: a luxury end product with a two-source route puzzle. |
| LUX_5 | AGREE | +30% volume when selling at a price-up planet: rewards chasing events (QA: +2.5 cycles when removed). |
| LUX_6 | AGREE | Batch +1 (gems 3 to 4) and +8% price; ok as a tech payoff once gems run. |
| LUX_7 | CHANGE | One-time -30% for 8 cycles is much weaker than MIL_5 (repeats, -50%) at the same cost 3. Ask economy to lift it or add a cooldown use. |
| MIN_1 | AGREE | Smelter, fabric, ingot: opens the whole market. |
| MIN_2 | AGREE | Ore orders ignore the size cap: a rule change that removes a chore. Not isolatable in tests. |
| MIN_3 | AGREE | +25% cluster yield plus dross at dead_1: strongly felt (subtree). |
| MIN_4 | AGREE | +1 smelter batch: the clearest output gain (-46% ingots if removed). A plain number, but the one that matters. |
| MIN_5 | AGREE | Nullglass at dead_2: a new place and good; strongly felt. |
| MIN_6 | AGREE | +1 ingot per batch, alloy, +8% price: alloy is the real reward; fabric must exist for it to show. |
| MIN_7 | AGREE | All bots -20% for good: clear, fits the min fantasy. |
| BIO_1 | AGREE | Culture lab and gel; faster wins in QA. |
| BIO_2 | AGREE | Stock grows 2% a cycle in planet storage plus +12% volume: a new reason to store; check the bot actually holds stock. |
| BIO_3 | AGREE | Storage +50% and raises the growth ceiling: pairs with BIO_2 as a build. Felt. |
| BIO_4 | AGREE | Seed unlock plus +10% price: new end good carries it. |
| BIO_5 | AGREE | Share window 12 plus stock protected from asteroid cuts: a rule and a safety net. |
| BIO_6 | AGREE | Event cut 40%, reopen 1 cycle sooner, +8% price: reopen is a real rule; fine. |
| BIO_7 | AGREE | Bots -15% permanent; smaller than MIN_7 on purpose since bio bots are already x0.92. |

Count: 29 AGREE, 3 CHANGE counted above are MIL_7, LUX_2, LUX_7 (so 28 AGREE, 3 CHANGE, 0 REJECT).

## 2. Rivets as a sale-only Military export
Acceptable. Reasons: it is the only mil good a new player can carry before chips and cells exist; it gives system 2 a first trade (buy 20, sell about 40, +100%); it is one of several "trade-only" goods (energy, food, chips already work this way). Conditions: (a) the UI must say where it sells, so it reads as a lane and not a dead item; the optional GOOD_RIVETS_DESC line does that; (b) it must stay profitable early but fall behind once cells and armour exist, so it is a stepping stone. A good with no craft use is fine if it is a trade lane; it would be a dead resource only if no planet bought it.

## 3. Too many percent-only nodes?
Mostly no, but on the edge. Nodes whose whole effect is a number with no new rule, good, place or information: MIL_2, MIL_3 (debris is near-dead), MIL_6, LUX_2, LUX_5, LUX_6, MIN_4 = 7 of 31 (23%). Five techs also stack a flat +6 to +10% sale price (MIL_6, LUX_2, LUX_6, MIN_6, BIO_4, BIO_6 = 6 nodes). Risk: price percents feel like a hidden tax cut and are not seen on a screen. Techs are earned by crafting, so a number payoff is acceptable there; the skill-point nodes (cost 2 to 3) are the ones that must have a rule, and all do except MIL_3 and LUX_5 (LUX_5 is conditional, so it still makes the player choose where to sell). Recommendation: ship as is; no new percent nodes; show the sale price bonus in the sale screen so it is seen (ui-programmer, S).

## Open questions
- UNKNOWN: does MIL_7 x0.5 growth stay fair late? Economy to test with a contested mil run.
- UNKNOWN: owner call on LUX_7 (once per run) vs a cooldown use.
- UNKNOWN: owner call on dropping the LUX_2 event bonus.
