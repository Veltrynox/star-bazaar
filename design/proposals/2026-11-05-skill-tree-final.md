# Skill tree FINAL (2026-11-05, economy-designer)

Applied to data/skills.json (data_version 2), data/balance.json (v48), data/availability.json. Verdicts: E = economy, F = feature-designer review, Q = QA review (all three read from the 2026-11-05 review files). F/Q column shows the review verdict and, where a CONCERN or CHANGE was raised, how this tree answers it. Q's CONCERN on most nodes is "untestable by the current bots" (no workshop-building bot), not a design objection; they stay open as QA checks, not blockers.

Binding owner decisions applied: MIL_3 debris only; BIO_3 raises the BIO_2 ceiling; Luxury order fix; MIL_5 and LUX_5 made felt. LUX_6 deviates: see its row.

| node | effect (final) | decision it creates | E | F | Q |
|---|---|---|---|---|---|
| FND_STORAGE | unlock Space Storage | when to spend point 1 | keep | AGREE | AGREE |
| FND_PERMIT | unlock system 2 routes | whether and when to go to system 2 | keep | AGREE | AGREE |
| FND_PROSPECT | unlock ore clusters | ore lanes vs plain trade | keep | AGREE | AGREE |
| MIL_1 | upkeep -20%, munitions, cells | cheap fleet pays from ship 4 | keep | AGREE | AGREE (check upkeep at 4-6 ships) |
| MIL_2 | munitions +1 batch per cycle | haul energy and chips for a doubled line | change | AGREE (needs batch counter in workshop UI) | CONCERN: untested, code live |
| MIL_3 | mil routes ignore debris route events | run risky debris lanes with mil cargo | replace, debris only | CHANGE answered (pirate dropped; only debris is live) | REJECT answered (no pirate target) |
| MIL_4 | unlock armour | rivets + cells + chips chain | change | AGREE | CONCERN: armour dominance vs cells, check |
| MIL_5 | Embargo: chosen rival -35% for 4 cycles, every 8 | which rival, when, before a share check | retune 0.18/3 to 0.35/4 | AGREE | CONCERN answered (0.18/3 had no effect; stronger and longer) |
| MIL_6 | mil price events -35% | hold big mil stock through events | retune 0.5 to 0.35 | AGREE | CONCERN: untestable |
| MIL_7 | all rivals' mil growth x0.5 | commit to mil share | keep | AGREE | CONCERN: timing, see below |
| LUX_1 | reveal next-cycle prices, atelier, cask | route to the best planet; food to cask in system 1 | change | AGREE | CONCERN answered (text must not name cask before it shows) |
| LUX_2 | price-up events pay +50% | chase events with stock | keep | AGREE | CONCERN: untested |
| LUX_3 | event forecast 1 cycle | plan stock moves | keep | AGREE | CONCERN low (information) |
| LUX_4 | unlock gems | ore + silk + musk chain, needs permit | change | AGREE | CONCERN answered (musk added to rule; text hides gems until shown) |
| LUX_5 | +30% sales volume at price-up planets AND price-up events pay +25% more | go to the event planet on purpose | felt: 0.15 to 0.30, plus 0.25 bonus | AGREE | CONCERN answered (was 0 outcome effect; doubled and now also pays cash) |
| LUX_6 | luxury batches +1 unit (cask 3 to 4, gems 2 to 3) | build the atelier up as a main engine | REPLACED (see note) | CHANGE answered (no relief) | CONCERN hold answered |
| LUX_7 | once per run, chosen rival -30% for 8 cycles | when to fire | retune 0.18/5 to 0.30/8 | AGREE | CONCERN: timing |
| MIN_1 | smelter, ingot (fabric after nullglass) | opens chain | keep | AGREE | CONCERN: text only |
| MIN_2 | ore orders ignore size cap | bulk ore routes | change | AGREE | CONCERN: cap binding untested |
| MIN_3 | cluster yield +25%, dross at Cinderrest | dead-world route | keep | AGREE | AGREE |
| MIN_4 | smelter and fabric +1 batch | doubled chain | change | AGREE | AGREE |
| MIN_5 | nullglass at Greywake | system 2 mining hub | keep | AGREE | CONCERN: reach |
| MIN_6 | +1 unit per batch, unlock alloy | capstone chain payoff | change | AGREE | CONCERN: alloy margin 155, check |
| MIN_7 | all rivals' min strength -20% | commit to min share | retune 0.1 to 0.2 | AGREE (check dominance) | CONCERN |
| BIO_1 | culture lab, gel | opens recipe | change | AGREE (thin) | CONCERN: text hides gel; lab visible only after permit |
| BIO_2 | stock grows 2% a cycle up to 20% | hold or sell | keep | AGREE | CONCERN: bots never hold stock |
| BIO_3 | storage +50% and BIO_2 ceiling 20% to 30% | hold longer | change | CHANGE answered | CONCERN low answered (ceiling gives a reason) |
| BIO_4 | unlock seed | end product | keep | AGREE | CONCERN |
| BIO_5 | bio window 12 cycles, bio stock safe from storage cut | stockpile identity | change | AGREE | CONCERN: rare stock_protect roll, accepted |
| BIO_6 | bio events -25%, closed planet reopens 1 cycle sooner | rescue | keep | AGREE | CONCERN |
| BIO_7 | all rivals' bio strength -15% | commit to bio share | retune 0.1 to 0.15 | AGREE | CONCERN |

LUX_6 note: the owner decision was saturation_recovery_mult, but the build has no saturation rule at all (game/route_engine.gd line 21: "There is no saturation rule"; debug_menu says the same). A recovery factor would multiply nothing. I applied a felt effect on existing code instead: batch_yield on luxury (Skills.batch_yield is generic by market). Cheap alternative: build a saturation rule first, then restore the owner's design. Owner to confirm.

## Capstone timing (tools/sim.py does not model skills; this is arithmetic from QA numbers)

Path to a capstone: 13 points (3 FND + 1 + 2 + 3 + 4 incl. tier-1 to 5 chain) plus permit_points_2 2 = 15 points. Decent earns 18 to 21 by c27, about 0.75 a cycle, so 15 points land near cycle 18 to 20 if nothing else is bought. Tech units 9 + 18 + 12 = 39. Workshop built c10 to 12 at 900 credits.
- MIL: cells 3 per batch, +1 batch after the first tech (9 units = 3 cycles), then 6 a cycle: 3 + 3 + 2 = 8 cycles. Capstone c19 to 22 at the earliest: the fastest tree. This is why MIL_6 went 0.5 to 0.35 and why MIL_3 shrank; win_earliest_cycle 23 still holds.
- LUX: cask 3 per batch, one batch: 13 cycles, c23 to 25. LUX_6 yield +1 speeds the last stage only.
- MIN: smelter, one batch until MIN_4 (27 units): about c25 to 27.
- BIO: needs system 2 first (lab visible after permit), gel 3 per batch: c24 to 27.
Result: capstones are reachable only by committing from about cycle 10 and ignoring the other trees (43 points total, 18 to 21 earned), and arrive near the win window. Not a free win. Dominance check on MIL stays a QA item (needs a munitions bot).

## Programmer list
New or changed effect types: event_immune {target mil, kinds [debris]} (route_engine.gd:639-640: skip debris route penalty for routes carrying that market's goods; pirate kind not used); stock_growth_cap {target bio, cap_key skill_BIO_3_stock_cap} (BIO_2 ceiling becomes 0.30 when learned; Skills.stock_growth cap = max of the two). batch_yield now with target lux (generic, check Workshops use). workshop_batches target mil (live). stock_protect target bio (already generic; test moved to BIO_5). Removed effects from nodes: sale_price_pct, route_capacity_pct, order_size_pct, volume_pct (MIL_2, MIN_2). The workshop UI needs a batch counter (F note on MIL_2).
Tests edited in tools/tests/run_tests.gd (minimal, lines about 1740 to 1770, 3319, 3370 to 3400): removed reads of skill_size_s, skill_size_m, skill_LUX_1_price, skill_LUX_6_price, skill_MIL_3_route_units, skill_MIL_4_price, skill_BIO_1_order_units; dropped the MIL_4 sale margin and route-lane block; LUX_4 stock_protect test now BIO_5. No test needs new code today: unknown types are ignored, so event_immune and stock_growth_cap are not tested yet; the programmer adds tests.

## Story-designer list (no hidden good names while a node shows)
Plain lines to rewrite: SK_MIL_2, SK_MIL_3 (debris only), SK_MIL_4 (armour only, no percent), SK_MIL_5 (numbers), SK_MIL_6, SK_LUX_1 (reveal, atelier; cask only once atelier is built), SK_LUX_4 (gems; name only when ore, silk, musk are visible), SK_LUX_5, SK_LUX_6, SK_LUX_7, SK_MIN_2, SK_MIN_4 (rename batches, no alloy), SK_MIN_6 (alloy only when plate is visible), SK_MIN_7, SK_BIO_1 (no gel name), SK_BIO_3 (ceiling), SK_BIO_5, SK_BIO_7. Existing offenders per QA: SK_MIL_1 (cells), SK_MIN_1 (ingot, fabric), SK_BIO_1 (gel).
