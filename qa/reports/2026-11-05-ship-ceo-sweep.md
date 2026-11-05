# Ship and CEO sweep, regression, skill reachability (2026-11-05)

Reviewer: qa-analyst. Inputs: `handoffs/gameplay-programmer/2026-11-05-ship-ceo-logic.json`, `handoffs/economy-designer/2026-11-05-skill-tree-final.json`, `qa/reports/2026-11-05-skill-redo-review.md`. Build: current working tree (not committed). Nothing edited. All runs headless, `--skip-tutorial`.

Batch: 117 runs (cap 120). 96 sweep (16 CEO x ship combos, decent, seeds 1-6), 16 regression (4 strategies, seeds 1-4, default config), 4 diagnostics (market focus, seed 1, plus one probe). Raw records: `qa/reports/2026-11-05-ship-ceo-sweep-runs.jsonl`. Bugs: `qa/reports/2026-11-05-bug_report-ship-ceo-sweep.json` (9 entries).

## Headline

- No crash and no freeze in 117 runs.
- One softlock: ceo_man_01 + bulk, seed 2 (cash 0 from cycle 21, ends swept at 27). High.
- Decent is weaker than the earlier baseline. Regression: 1 of 4 wins (earlier review: 3 of 4). Sweep: 34 of 96 wins (35 percent).
- Pass rule (part 1): 4 of 16 combos pass both halves. Median win cycle is 27 for the combo median. 11 of 16 combos are within 1 of it.
- No dominant strategy: only decent wins in the regression.
- Nine changed nodes: 3 of 9 are learned by the default bot in every run (MIL_3, MIL_5, LUX_1). LUX_4, LUX_6 and BIO_5 are not reached by the default bot. Market-focused runs reach all of them, so the gap is in the bot, not necessarily the nodes.

## 1. Regression, four strategies, seeds 1-4, default config

| strategy | wins | non-win endings | cash at end | ships | permits |
|---|---|---|---|---|---|
| decent | 1 (seed 1, c27) | 1 bankrupt c28 (seed 2), 2 END_OUTCOMPETED c40 | win 19.7k; others -1.3k, 28.9k to 29.4k | 6 | 1 |
| sloppy | 0 | 4 END_OUTCOMPETED c40 | 6.3k to 7.5k | 1 | 0 |
| always_expand | 0 | 4 END_OUTCOMPETED c40 | 14.9k to 18.5k | 6 | 0 |
| never_expand | 0 | 4 END_OUTCOMPETED c40 | 4.5k to 9.8k | 1 to 2 | 0 |

No crash, no softlock. Not dominant: only decent wins, inside the 22-30 band (c27). Decent's win rate drops from 3 of 4 (earlier review, 2026-11-05 skill-redo) to 1 of 4 on this build. Cause UNKNOWN. Candidates are the final skill tree (removed price and size keys, MIL_5 retune) and the ship/CEO logic change to upkeep and route_engine. A same-seed A/B on HEAD versus the working tree would settle it. Bug B3.

## 2. Sweep, decent, 16 CEO x ship combos, seeds 1-6

Pass rule: combo median win cycle within 1 of the median combo (median of combo medians = 27), and win rate at least 60 percent of the best combo (best = 4/6, threshold 2.4/6, so 3 wins or more).

| CEO | ship | wins /6 | median win cycle | median rule | win rule | notes |
|---|---|---|---|---|---|---|
| ceo_man_01 | small | 1 | 29 | no | no | |
| ceo_man_01 | bulk | 4 | 27 | yes | yes | |
| ceo_man_01 | dart | 2 | 27 | yes | no | |
| ceo_man_01 | fleet | 3 | 27 | yes | yes | |
| ceo_man_02 | small | 1 | 27 | yes | no | |
| ceo_man_02 | bulk | 2 | 27 | yes | no | |
| ceo_man_02 | dart | 0 | none | no | no | the only sweep bankruptcy (seed 2, c23) |
| ceo_man_02 | fleet | 2 | 31 | no | no | wins at c30 and c32 |
| ceo_woman_01 | small | 2 | 28 | yes | no | |
| ceo_woman_01 | bulk | 2 | 27 | yes | no | |
| ceo_woman_01 | dart | 4 | 27 | yes | yes | |
| ceo_woman_01 | fleet | 2 | 29.5 | no | no | |
| ceo_woman_02 | small | 2 | 28.5 | no | no | |
| ceo_woman_02 | bulk | 2 | 27.5 | yes | no | |
| ceo_woman_02 | dart | 1 | 27 | yes | no | |
| ceo_woman_02 | fleet | 4 | 27 | yes | yes | |

Passing both: ceo_man_01 bulk, ceo_man_01 fleet, ceo_woman_01 dart, ceo_woman_02 fleet. 34 of 96 decent wins (35 percent). 60 of 96 END_OUTCOMPETED, all at cycle 40 (the gate fires on time). Win cycles: 27 in most runs, 27-32 overall.

Roll-up: by ship, small 6/24 (25 percent), bulk 10/24 (42), dart 7/24 (29), fleet 11/24 (46). By CEO, man_01 10/24 (42), man_02 5/24 (21), woman_01 10/24 (42), woman_02 9/24 (38).

Outliers and likely cause (UNKNOWN until an ablation):
- ceo_man_02 is the weakest CEO. Haggling (cash-only sale price) does not help the market-share win, thrift 1 leaves the highest upkeep, and the perk reveals prices on cycle 1 only, which the bot never uses. The two volume-related CEOs (woman_01 perk on first-lane capacity, woman_02 order size) do best.
- small is the weakest ship. Bulk (cargo x1.125) and fleet (+1 capacity) move more volume toward the share line. Dart's cheap trips do not compensate for its lower cargo.

Bug B6 (outliers) and B4 (overall win rate).

## 3. Reachability of the nine changed nodes

Default decent bot (sweep, 96 runs): MIL_3 96, MIL_5 96, LUX_1 96, BIO_3 57, MIN_6 15, MIL_2 14, BIO_5 1, LUX_4 0, LUX_6 0. Regression (4 runs): MIL_3 and MIL_5 and LUX_1 only.

Workshops built by the default decent bot: smelter only, in all 96 sweep runs and 4 regression runs. The atelier, munitions and culture lab are never built, so their chains never run.

Market-focus diagnostics (seed 1, one run each):
- `--market=mil` builds munitions at c12 and learns MIL_2 (plus MIL_4, MIL_6); MIL_5 learned at c9. Win at c27.
- `--market=lux` builds atelier at c16 and learns LUX_4 and LUX_6 (plus LUX_2). END_OUTCOMPETED at c40.
- `--market=bio` builds culture lab at c14 and learns BIO_5 at c10 (plus BIO_3, BIO_2, BIO_4, BIO_6). Win at c31.
- `--market=min` learns MIN_5 and MIN_6 with the smelter. Win at c32.

Verdict: LUX_4, LUX_6 and BIO_5 are not reachable by the default bot; they need the atelier or culture lab, which the bot never builds (B7). MIL_2 needs munitions and is reached in 14 of 96 default runs. MIN_6 is reached in 15 of 96 (needs MIN_5). Point costs: LUX_1 1, MIL_3 2, BIO_3 2, MIL_5 3, BIO_5 3; the four tech nodes cost 0 points but need tech goal units from a workshop. Timing of learn cycles for tech nodes is not in the RESULT fields (UNKNOWN).

## 4. Bugs

| id | severity | type | summary |
|---|---|---|---|
| B1 | high | softlock | ceo_man_01 + bulk, seed 2: cash 0 from c21, 5 ships and 5 routes idle to swept at c27 |
| B2 | medium | balance | ceo_man_02 + dart, seed 2: bankrupt c23. Default config seed 2 also bankrupt (c28) |
| B3 | medium | balance | Regression: decent 1 of 4 wins (earlier 3 of 4). Cause UNKNOWN |
| B4 | medium | balance | Sweep: decent 34 of 96 wins; only 4 of 16 combos pass the win-rate rule |
| B5 | medium | pacing | ceo_man_02 + fleet, seed 3: win at c32 (only decent win after c30) |
| B6 | medium | balance | CEO and ship outliers: ceo_man_02 5/24; small ship 6/24; median-rule misses in 5 combos |
| B7 | medium | coverage | Default decent bot never builds atelier, munitions, culture lab; LUX_4, LUX_6, BIO_5 unreached (harness gap, qa-analyst) |
| B8 | low | UI warning | "Not enough cash" warning for 3+ cycles in a row (3 runs) |
| B9 | low | release | debug_menu.gd is packed in the release PCK; the menu is gated by debug_tools_allowed (OS.is_debug_build). Not verified by a real export |

Owners in the JSON: gameplay-programmer (B1, B8, B9), economy-designer (B2, B3, B4, B5, B6), qa-analyst (B7).

## 5. Limits

- Seeds barely vary the outcome: most combos win at c27 in every run. Pass-rule results have n=6 per combo; single-run changes move a combo across the win-rate line.
- Ablations were not run (budget): CEO and ship causes are hypotheses.
- Market-focus runs are single seeds.
- tools/sim.py does not model skills or CEO; timing is from headless runs only.
- Release export not built; B9 is from config reading.
- Earlier review baseline was a different build (before the final tree and CEO logic). The regression drop is observed, not attributed.
