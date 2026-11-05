# Skill tree FINAL: feature-designer re-review (2026-11-05)

Read: data/skills.json (data_version 2), balance values (v49), story/skills.md, route_engine.gd _route_cap. 31 nodes: 30 AGREE, 1 AGREE-WEAK (MIL_3, owner-binding, optional fix below), 0 CHANGE, 0 REJECT. No data replacement is required. Anything below marked "optional" is advice, not a blocker.

| node | verdict | why (decision or feel) |
|---|---|---|
| FND_STORAGE | AGREE | Point 1 timing: income now or the buffer first. |
| FND_PERMIT | AGREE | Whether and when to leave system 1; clear fork. |
| FND_PROSPECT | AGREE | Ore lanes vs plain trade; opens mining. |
| MIL_1 | AGREE | Cheap fleet; first reason to own 4+ ships. Opens munitions. |
| MIL_2 | AGREE | A second batch doubles the haul for energy and chips. Needs the batch counter in the workshop UI (ui-programmer, S). |
| MIL_3 | AGREE-WEAK | Binding owner decision. Debris cuts a lane 25 percent (debris_route_penalty 0.25) and can be paid off for 400, so 2 points buy a narrow edge. It is mostly a gate to MIL_5. Optional: also halve debris_clear_fee for Military lanes (needs code) or leave as is and watch the QA pick rate. |
| MIL_4 | AGREE | Armour chain (rivets + cells + chips) is a real new recipe. QA must check armour does not dominate cells. |
| MIL_5 | AGREE | Embargo 35 percent for 4 of every 8 cycles: which rival and when, before a share check. Clear active play. |
| MIL_6 | AGREE | Event cut 35 percent rewards holding big mil stock. Modest but honest. |
| MIL_7 | AGREE | Growth x0.5 on all rivals: the commit-to-Military capstone. |
| LUX_1 | AGREE | Price reveal changes route choice at once, and it opens the atelier. Text must not name cask until shown. |
| LUX_2 | AGREE | +50 percent on price-up events: chase events with stock. |
| LUX_3 | AGREE | Event forecast turns luck into planning. Pure information, cheap and good. |
| LUX_4 | AGREE | Gems chain (ore, silk, musk) needs the permit; a goal worth stocking for. |
| LUX_5 | AGREE | Go to the event planet on purpose (+30 percent volume, +25 percent pay). Felt now. |
| LUX_6 | AGREE | +1 per batch is cask 3 to 4 (+33 percent) and gems 2 to 3 (+50 percent). Strong but tier 4, tech-gated and arrives about cycle 23 to 25. Fine, and honest about no saturation rule. Watch gems at +50 percent in QA. |
| LUX_7 | AGREE | One shot, 30 percent for 8 cycles: when to fire. Strong timing choice. |
| MIN_1 | AGREE | Opens the smelter chain; plain but needed. |
| MIN_2 | AGREE | Bulk ore lanes, if the order cap actually binds. QA to confirm it does. |
| MIN_3 | AGREE | Dead-world route with dross: a real trip, a real risk. |
| MIN_4 | AGREE | Doubled chain; same shape as MIL_2, consistent. |
| MIN_5 | AGREE | Greywake nullglass: system 2 mining hub, a place to go. |
| MIN_6 | AGREE | Alloy plus +1 per batch: a true capstone payoff. Check alloy margin 155 in QA. |
| MIN_7 | AGREE | Strength -20 percent on all rivals: commit to Mining. |
| BIO_1 | AGREE | Thin (lab and gel only) but a normal tier-1 opener; the lab is visible only after the permit, so it is a system-2 decision. |
| BIO_2 | AGREE | Hold or sell: 2 percent a cycle up to 20 percent. The only node that rewards patience. |
| BIO_3 | AGREE | Raising the BIO_2 ceiling to 30 percent gives a reason to hold longer; storage +50 percent supports it. |
| BIO_4 | AGREE | Seed as the end product; a clear goal. |
| BIO_5 | AGREE | Window 12 and stock safe from cuts: stockpile identity. Rare roll, accepted. |
| BIO_6 | AGREE | Rescue: events -25 percent and reopen 1 cycle sooner. |
| BIO_7 | AGREE | Strength -15 percent on all rivals: commit to Bio. |

## Notes for the economy-designer
- Parity check on capstones: Military and Mining gain batches, Luxury gains yield, Bio gains time. Four different shapes. Good.
- The only unfelt risk is MIL_3. Everything else changes a choice the player can see.
- Open items stay with QA: MIL_4 vs cells, MIN_2 cap binding, LUX_6 gems, MIN_6 alloy margin.
