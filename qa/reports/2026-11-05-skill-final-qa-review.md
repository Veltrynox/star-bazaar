# Skill final tree: QA review (2026-11-05)

Reviewer: qa-analyst. Input: committed `data/skills.json` (skills data_version 2, 31 nodes) and `data/balance.json` (data_version 49). Build: current working tree. Nothing in game code or data was edited; nothing committed. Prior reviews read: `2026-11-05-skill-redo-review.md` (draft) and `2026-11-05-ship-ceo-sweep.md`.

Raw records: `qa/reports/2026-11-05-skill-final-runs.jsonl`. Bugs: `qa/reports/2026-11-05-bug_report-skill-final-review.json`. Batch driver: `qa/bots/skill_final_review.sh`. Tables: `qa/bots/skill_final_analyse.py`.

## Headline

- No crash, softlock or freeze in the 136 scored and re-run records. One diagnostic run returned no RESULT once and did not reproduce (BUG-7). All 116 batch runs end at the expected cycle (`end_cycle_ok` true in every run).
- Verdicts on the 18 changed nodes: 3 AGREE (MIN_4, BIO_1, BIO_3), 14 CONCERN, 1 REJECT (MIL_3, debris only, never fired). LUX_7, MIN_7 and BIO_7 were never reached in 16 focus runs. MIL_2, MIL_4 and MIL_6 were reached only in the one seed where munitions ran.
- The bot's munitions chain stalls in 3 of 4 mil-focus seeds (energy and chips never reach the station). MIL_2, MIL_4 and MIL_6 cannot be measured until that is fixed (BUG-1).
- Armour (MIL_4) and gems (LUX_4) can never be fed under the bot's 2-ship feed limit, so their payoffs are unmeasured (BUG-2).
- Lux focus wins only through the bio share built by its food feed. Removing LUX_1 (which unlocks the atelier) drops lux-focus wins from 2 of 4 to 0 of 4 (BUG-6).
- Dominance candidate: mil focus wins 4 of 4 at cycle 27 without a working munitions chain (BUG-3, medium).

## 1. Bot changes (qa/bots, owned by qa-analyst)

1. Focus runs now feed their own workshops. `_ranked_lanes_for` lets the inputs of built focus workshops through the market filter (food for the atelier, spores for the culture lab). Before this, a `--market` run never fed them. Earlier focus results (2026-11-03 and 2026-11-05 batches) are not comparable to these.
2. `--skip-tech=ID`: bot-side ablation. Each cycle start removes the tech from the learned set and clears its unit count, so a tech can never finish (one cycle's units are always below the goal of 9, 18 or 12). Dependants stay locked. `--skip-skill=ID` (existing) covers the skill nodes.
3. RESULT adds `skip_techs`, `storage_end` (end stock per storage key) and `tech_log` ([cycle, id] for each tech finished by crafting). Skill learn cycles were already in RESULT as `skill_log` and are read by `metrics.py`.
4. Determinism check: a re-run of the 20 base and focus runs with `tech_log` matched the batch in 20 of 20 (outcome, win cycle, final cash). The seeds are not independent samples; the only randomness is the asteroid roll and the alt choice.

Cap: the batch is 116 runs (cap ~120). 20 re-runs (tech_log) and 11 diagnostic runs (munitions stall, harness check) push the total to 147. This is over the brief's cap; the extra runs are listed here so the Producer can weigh them.

## 2. Market focus vs default, decent, seeds 1-4 (dominance check)

| focus | wins | win cycles | focus-market share at end (mean of 4) | final cash (mean of 4) | workshop output | notes |
|---|---|---|---|---|---|---|
| none (default decent) | 3 of 4 | 27, 27, 27 (seed 3 SOFT c40) | not applicable | 33.1k | smelter ingots 91 | default build |
| mil | 4 of 4 | 27, 27, 27, 27 | mil 0.63 | 17.0k | munitions cells 81 (seed 1 only; stalled seeds 2-4) | win without the MIL chain |
| lux | 2 of 4 | 30, 35 (seeds 1, 4 SOFT c40) | lux 0.25, bio 0.53-0.59 in the wins | 32.8k | cask 57 | the win is a bio-share win |
| min | 4 of 4 | 29, 31, 28, 30 | min 0.68 | 18.2k | ingots 112 | smelter path works |
| bio | 4 of 4 | 34, 32, 34, 27 | bio 0.59 | 7.1k | gel 27, seed 6 | slowest pace, lowest cash |

Reading: no focus dominates on all three of reliability, pace and cash. Mil is the most reliable at the target pace (4 of 4 at cycle 27), but its win does not depend on the MIL tree (munitions stalled in 3 of 4 seeds). Lux and bio are late. Dominance flag (medium, BUG-3): mil focus. Pacing flags (medium, BUG-4, BUG-5): bio wins at 32-34 in 3 of 4 seeds; lux seed 3 wins at 35. The default decent wins at 27, inside the 22-30 band.

## 3. Method for node verdicts

- Learned arm: the focus baseline run (same market, same seed). Removed arm: `--skip-skill` or `--skip-tech` on the node, 4 seeds. 24 nodes: 18 changed (MIL_2-6, LUX_1,4,5,6,7, MIN_2,4,6,7, BIO_1,3,5,7) and 6 others (LUX_2, MIN_3, MIN_5, BIO_2, BIO_4, BIO_6).
- Removing a node also removes the tech or skill below it (prerequisites), and points freed by it can go to other nodes. The "subtree" column lists everything lost in seed 1.
- A measured effect means a change in win count, win cycle, focus-market share, cash or workshop output, consistent across seeds. Changes under about one win cycle or 0.02 share are treated as noise.
- Tech completion cycles (new `tech_log`), focus baselines: MIL_2 c15, MIL_4 c18, MIL_6 c19 (seed 1 only); LUX_2 c17-22, LUX_4 c23-28, LUX_6 c27-32; MIN_2 c12-15, MIN_4 c15-21, MIN_6 c17-23; BIO_2 c19-23, BIO_4 c24-28, BIO_6 c31-33.

## 4. Changed nodes: evidence and verdict

Base means are the focus baseline; "removed" is the ablation (4 seeds). Reach is how many of the 16 focus baseline runs learned the node.

| node | reach (of 16) | removed: measured effect | verdict |
|---|---|---|---|
| MIL_2 tech, munitions batch +1 | 1 (seed 1, c15) | cells 81 to 45 in seed 1 only; cash -0.7k; share -0.004; wins 4 of 4 both | CONCERN: untestable in 3 of 4 seeds (BUG-1) |
| MIL_3 skill, debris immunity | 16 (learned c7-16) | removed with MIL_5, MIL_6: mil share -0.027, cash -1.2k, wins unchanged; debris events fired 0 times in 116 runs | REJECT: carried over from the draft review (debris only); the final tree did not retarget it, and it is never felt |
| MIL_4 tech, armour unlock | 1 (seed 1, c18) | no output change; armour never crafted even with MIL_4 learned (3 raw feed inputs, limit is 2) | CONCERN: payoff unreachable under the bot's feed limit (BUG-2) |
| MIL_5 skill, bot -35% every 8 cycles for 4 | 4 of 4 mil (c8-9) | removed with MIL_6: mil share -0.008, cash -0.0k, wins unchanged. NOT FELT in mil focus: the share sits about 10 points above the line | CONCERN: not felt; needs a contested run |
| MIL_6 tech, event cut 35% | 1 (seed 1, c19) | identical in all 4 seeds | CONCERN: not felt, and rarely reached |
| LUX_1 skill, reveal prices, atelier, cask | 15 of 16 (c6-14) | removed with the LUX tree: lux-focus wins 2 of 4 to 0 of 4; cash +5.5k; lux share 0.25 to 0.36 but no win. The win needs the bio share from food feed | CONCERN: the reveal-prices half is not measured; the win runs through the atelier's food feed (BUG-6) |
| LUX_4 tech, gems unlock | 3 (c23-28) | wins 2 to 1; lux share +0.03; cash +3.0k; gems never crafted (needs 4 feed ships) | CONCERN: payoff unreachable (BUG-2) |
| LUX_5 skill, +30% volume at price-up sales | 4 of 4 lux (c6-8) | removed with LUX_6: cash -5.3k (-16%); lux share -0.007; wins 2 of 4 both (different seeds) | CONCERN: the cash effect is real, the share is flat; the price-up condition is not counted by the bot |
| LUX_6 tech, batch +1 | 3 (c27-32) | cask 57 to 51 (-11%); cash -0.4k; wins identical | CONCERN: small output effect, no win effect |
| LUX_7 skill, bot -30% for 8, once | 0 of 16 | none (not reached) | CONCERN: untestable (13-point path plus 39 lux units) |
| MIN_2 tech, ore cap bypass | 4 (c12-15) | removing MIN_2 also removes MIN_4 and MIN_6: the row is identical to the MIN_4 removal | CONCERN: the ore bypass cannot be isolated; no ore order sizes were logged |
| MIN_4 tech, +1 smelter batch | 4 (c15-21) | ingots 112 to 61 (-46%); cash -1.4k; share -0.026; wins 4 of 4 (seed 2 +2 cycles) | AGREE: output effect is clear and consistent |
| MIN_6 tech, +1 ingot per batch, alloy | 4 (c17-23) | ingots 112 to 95 (-15%); cash -0.3k; share -0.009; wins 4 of 4 (seed 2 +1 cycle). Alloy never made: its plate needs the fabric workshop, which the bot does not build | CONCERN: small; alloy half untestable |
| MIN_7 skill, -20% bot, permanent | 0 of 16 | none (not reached) | CONCERN: untestable |
| BIO_1 skill, culture lab and gel | 16 of 16 (c7-14) | removed with the BIO tree: wins 4 of 4 both, but the win cycle moves from 31.8 to 38.0 (+6); cash +20.6k without the culture lab; bio share unchanged | AGREE: felt as faster wins against a cash cost; check the pace against the bio focus (BUG-4) |
| BIO_3 skill, planet storage +50% | 10 of 16 (c9-30) | removed with BIO_5, BIO_6: bio-focus cash -2.8k (-40%); bio share -0.019; wins 4 of 4 both. Storage pressure is real: "Waiting for room" warnings in 65 runs | AGREE: felt through cash and share |
| BIO_5 skill, share window 12 | 8 of 16 (c11-17) | removed with BIO_6 (and MIL_5 via points): bio share -0.031; cash -3.3k; win cycles mixed (37, 30, 31, 32 vs 34, 32, 34, 27) | CONCERN: small share effect, mixed cycles; stock_protect not measured |
| BIO_7 skill, -15% bot, permanent | 0 of 16 | none (not reached) | CONCERN: untestable |

Changed nodes: AGREE 3 (MIN_4, BIO_1, BIO_3), REJECT 1 (MIL_3), CONCERN 14.

## 5. Other nodes (not in the changed list)

| node | reach | removed: measured effect | verdict |
|---|---|---|---|
| LUX_2 tech, event bonus +50% | 4 of 16 | wins 2 of 4 both, seeds differ; share +0.04; cash -1.1k | CONCERN: noise-level |
| MIN_3 skill, cluster yield +25%, dross | 7 of 16 | removed with MIN_5, MIN_6, BIO_5: min share 0.68 to 0.20; wins 4 to 2; cash +17.3k (cause UNKNOWN; likely ships move off the dross and cluster lanes) | AGREE: strongly felt (subtree effect) |
| MIN_5 skill, nullglass | 6 of 16 | removed with MIN_6: min share 0.68 to 0.49; wins 4 to 2 | AGREE: felt |
| BIO_2 tech, stock growth | 3 of 16 | outcomes identical; cash -0.4k | CONCERN: NOT FELT (the bot holds little bio stock in planet storage, unverified) |
| BIO_4 tech, seed unlock | 3 of 16 | outcomes identical; cash +0.1k | CONCERN: NOT FELT |
| BIO_6 tech, event cut 25% and reopen sooner | 3 of 16 | identical in all 4 seeds | CONCERN: NOT FELT |

## 6. Cross-cutting findings

- The munitions chain (MIL_2, MIL_4, MIL_6, and the armour path) is not testable with this bot: energy and chips do not reach the station in seeds 2-4 (BUG-1).
- The feed limit of 2 ships (`FEED_SHIPS`) blocks armour (3 raw inputs) and gems (4 ships), so the payoffs of MIL_4 and LUX_4 are never seen by the bot (BUG-2).
- Lux focus wins from the bio share built by the atelier's food route. The lux tree is a cash and timing lever, not the win driver (BUG-6).
- Tech pacing: MIN_4 lands c15-21 and BIO_6 c31-33. LUX_7, MIN_7 and BIO_7 (the capstones checked) were never reached in 16 focus runs. MIL_7 was not checked.
- MIN_2 and MIN_4 cannot be ablated separately (MIN_4 needs MIN_2), so MIN_2's own effect is unmeasured.

## 7. Bugs (full entries in the bug report JSON)

| id | severity | summary | owner |
|---|---|---|---|
| BUG-1 | medium | mil focus: energy never reaches station, munitions stalls in 3 of 4 seeds | gameplay-programmer (cause UNKNOWN: route or bot buy source) |
| BUG-2 | medium | armour and gems unreachable under the 2-ship feed limit | economy-designer (bot limit) |
| BUG-3 | medium | mil focus dominance candidate: 4 of 4 wins at c27 without the MIL chain | economy-designer |
| BUG-4 | medium | bio focus wins at 32-34 in 3 of 4 seeds (pacing) | economy-designer |
| BUG-5 | medium | lux focus seed 3 wins at c35 (pacing) | economy-designer |
| BUG-6 | medium | lux focus wins through the bio share from the atelier's food feed | economy-designer |
| BUG-7 | low | run_batch first run gave an empty result once (default TMPDIR); not reproduced in 2 runs | qa-analyst |
| BUG-8 | low | "Waiting for room" route warnings in 65 runs | gameplay-programmer (UNKNOWN if intended) |

## 8. Checks

- Crash, softlock, freeze: none in the 136 scored and re-run records. One diagnostic run returned no RESULT once (BUG-7). Two Godot "resources still in use at exit" messages (abl_MIL_5 seed 3, focus_bio seed 1) are engine shutdown notices, not game errors.
- Win and loss at the expected cycle: 116 of 116.
- Release export (static): `export_presets.cfg` excludes `game/debug_menu.gd` and `qa/*`, and `Main.debug_tools_allowed` is `OS.is_debug_build()`. No export build was run.
- Not run: sloppy, always_expand and never_expand under the final tree (not in this brief). Regression from the ship-CEO sweep: decent default wins 3 of 4 here, against 1 of 4 there, with the same committed data. Cause UNKNOWN.

## 9. Limits

Seeds are near-deterministic (20 of 20 re-runs identical), so the 4-seed results are a small sample. Treat changes under about 1 win cycle or 0.02 share as noise. Tech learn cycles are now logged, but only for the 20 baseline re-runs. Ablation rows include the points freed for other nodes.
