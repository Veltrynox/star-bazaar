# Skill tree redo: feature-designer review (2026-11-05)

Source: design/proposals/2026-11-05-skill-tree-redo.md (economy-designer draft). Test per node: decision, new play pattern, or feel; otherwise filler. Nothing here is approved; the owner decides.


| node | verdict | why |
|---|---|---|
| FND_STORAGE | AGREE | Real first-point decision. |
| FND_PERMIT | AGREE | Opens system 2, biggest play-pattern change. |
| FND_PROSPECT | AGREE | Opens ore lanes. |
| MIL_1 | AGREE | Cheap fleet plus first crafted good; clear early payoff. |
| MIL_2 | AGREE | Second batch forces a hauling decision (energy + chips). Note: it needs a visible batch counter in the workshop UI, or it is unfelt. |
| MIL_3 | CHANGE | Full immunity to pirate and debris removes the risk the player is meant to weigh. Replace with: mil routes immune to pirate only; debris still bites. Keeps a reason to read events. |
| MIL_4 | AGREE | Armour is the payoff; dropping 6% is right. |
| MIL_5 | AGREE | Active ability with timing; retune 0.25/4 needs sim. |
| MIL_6 | AGREE | Event answer that lets you hold stock; overlaps MIL_3 less once MIL_3 is pirate-only. |
| MIL_7 | AGREE | Clear capstone commitment. |
| LUX_1 | AGREE | Fixes inverted order; reveal is a real information tool. Cask on tier 1 is fine. |
| LUX_2 | AGREE | Gives the event chase a payoff. |
| LUX_3 | AGREE | Planning tool for every tree. |
| LUX_4 | AGREE | Gems at tier 3 fits the ore+silk+musk chain. |
| LUX_5 | AGREE | Event chasing rewarded with share. |
| LUX_6 | CHANGE | Halving saturation lets one planet absorb all crafted luxury, which kills the spread-your-lanes decision (core loop). Replace with: cask and gems saturation recovers twice as fast. Keeps spreading, rewards revisiting. Fallback: relief 0.25, not 0.5. Sim either way. |
| LUX_7 | AGREE | Once per run, 0.30 for 8 cycles: a real "when to fire" moment. |
| MIN_1 | AGREE | Opens the chain. |
| MIN_2 | AGREE | Ore size-cap bypass changes how bulk routes run. |
| MIN_3 | AGREE | New route plus yield. |
| MIN_4 | AGREE | Double batches is felt; removing dead alloy unlock is right. |
| MIN_5 | AGREE | System-2 route, completes plate. |
| MIN_6 | AGREE | Alloy appears when plate can exist; good capstone-ish reward. |
| MIN_7 | AGREE | -20% is felt. Check it does not make mining the dominant win path. |
| BIO_1 | AGREE | Lab and gel are the node. Slightly thin for a tier-1 node, but it opens a new recipe. |
| BIO_2 | AGREE | Best signature node: hold or sell. |
| BIO_3 | CHANGE | +50% capacity is passive unless the player is capped. Make it raise the BIO_2 growth ceiling 20% to 30% as well, so the choice to hold longer is real. |
| BIO_4 | AGREE | End product unlock. |
| BIO_5 | AGREE | Window plus stock protect fits the stockpile identity. |
| BIO_6 | AGREE | Event answer and rescue. |
| BIO_7 | AGREE | -15% is right for the weakest rivals. |

Correct totals: AGREE 28, CHANGE 3 (MIL_3, LUX_6, BIO_3), REJECT 0.

## Answers

1. Is military too safe (MIL_2 + MIL_3 + MIL_6)? Yes, somewhat. MIL_3 (immunity) plus MIL_6 (-50% event damage) cover both route events and price events, MIL_1 cuts upkeep, MIL_2 doubles output, and mil already won 4/5. There is no remaining risk, so no decision. Fix: MIL_3 pirate only. If sim still shows mil above the other trees, make MIL_6 -35% instead of -50%.
2. Is saturation_relief (LUX_6) too strong? Yes as drafted. It removes the need to spread sales, which is the core loop's main tension, and stacks with the atelier at 2 batches. Use faster saturation recovery or a smaller relief (0.25).
3. Does every good have a place? Yes, all 19 goods are covered (energy, food, chips, silk, ore, dross, nullglass, plate, rivets, cells, armour, musk, cask, gems, ingot, alloy, spores, gel, seed). Weak spots: chips, rivets, silk, musk and spores exist only as recipe inputs from system 2, which is fine, but dross has only plate as a use; QA should confirm dross is worth the MIN_3 mine route.

## Cost of the changes
- MIL_3 pirate-only: economy-designer (value), gameplay-programmer (kinds list already in the draft), size S.
- LUX_6 faster recovery: gameplay-programmer, new effect type instead of saturation_relief, size S-M; economy-designer sets the factor.
- BIO_3 ceiling: gameplay-programmer, one extra key, size S.
