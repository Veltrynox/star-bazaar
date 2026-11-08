# T182 QA report: flight, discovery and posts with bots

Run 2026-11-08 by qa-analyst (owner-started, QA gate lifted for this run). Task brief: `python3 tools/task.py T182`. Nothing under `game/`, `data/` or `story/` was changed; no commits.

## What ran

| Part | Size | Where |
|---|---|---|
| Bot batch, `qa/bots/bot_run.gd` via `qa/bots/skill_signoff_one.sh` | 480 runs: 5 CEO states (none, ceo_man_01, ceo_man_02, ceo_woman_01, ceo_woman_02) x 4 ships (small, bulk, dart, fleet) x 4 strategies (decent, sloppy, always_expand, never_expand) x 6 seeds (1 to 6) | rows in `logs/qa-t182/batch/rows`, per-run summary `qa/reports/2026-11-05-T182-runs.jsonl` |
| Flight and discovery probe (new): `qa/bots/flight_probe.gd` + `qa/bots/flight_probe.sh` | 6 seeds x 26 checks (plus 1 skipped check per seed) | logs in `logs/qa-t182/probe/probe_seed<n>.log` |

The probe uses probe-only inputs (extra cash, skill points, trade income) so money does not block the checks. The bot runs use the existing `bot_run.gd` as it is (its T281 changes are uncommitted in the tree).

## Pass / fail summary

| Check asked for in the brief | Result |
|---|---|
| Game can still be won | Not judgeable. 0 of 480 runs record a win (the Bazaar-win detection is a stub, T281). Logged as HIGH (bug 1). |
| Discovery and posts do not soft-lock (no open planet reachable) | Pass. With systems 1, 3, 4, 5 opened (system 2 by permit), all 19 planets become established in every seed (cycle 16, mining skills learned). No unreachable planet. |
| Pause stops the ship | Pass. Paused 200 frames: drift 0.000000, state and game clock unchanged. Ship moves again after unpause, then completes. |
| Flights to every target type | Pass. Planet (discovers and docks), open-space point (arrives within 0.000 of target, one arrived_point signal), storage station, asteroid cluster, jump to system 2 (refused with `no_gate` before the permit, works after it), jump back. |
| Saves round-trip mid-flight | Pass. Save at half of the eta: file matches the live Pathfinder state on every field; after a full game reload the course, target and position are kept and the ship arrives. |
| Saves round-trip mid-build | Pass. Build at 0.025 cycles left survives reload and finishes. |
| CEO and ship combos | Run in the batch (all 20 combos, 6 seeds, 4 strategies). No crash, freeze or script error in 480 runs. |
| No dominant strategy (fast-expand vs stay home) | Pass with one medium candidate. No global dominant strategy. Decent (fast expand) has the higher mean cash than never_expand in 16 of 20 combos. One combo (ceo_woman_02 + dart) favours always_expand in 5 of 6 seeds (bug 2). |
| Pacing (win between cycle 22 and 30) | Not judgeable, no win recorded. |
| Share, best market, win streak fields | Not judgeable, stubbed (T281). |
| Release export has no debug menu | Static check only, no export built. `game/main.gd` loads `debug_menu.gd` only when `debug_tools_allowed()` (`OS.is_debug_build()`), and `export_presets.cfg` excludes `game/debug_menu.gd`. Pass on static evidence. |

## Strategy results (all combos and seeds, n = 120 each)

| Strategy | Final cash mean | Median | Min | Max | Ships mean | Lanes mean | Permits mean | Outcomes |
|---|---|---|---|---|---|---|---|---|
| decent | 12241 | 11286 | 30 | 33571 | 8.1 | 15.9 | 0.9 | 120 soft |
| never_expand | 9470 | 9657 | 4005 | 12765 | 1.3 | 5.0 | 0 | 120 soft |
| always_expand | 6874 | 4617 | 14 | 27919 | 9.4 | 13.0 | 0 | 106 soft, 14 loss (bankrupt) |
| sloppy | 8619 | 8652 | 5791 | 10957 | 1.0 | 1.0 | 0 | 120 soft |

"soft" is END_UNFINISHED at cycle 40 (the bot's last cycle). Top final cash per cell (combo x seed, 120 cells): decent 65, never_expand 30, always_expand 19, sloppy 6, no ties.

By CEO (mean over all): none 9658, ceo_man_01 6551, ceo_man_02 10250, ceo_woman_01 8915, ceo_woman_02 11130. By ship: small 9597, bulk 8360, dart 10213, fleet 9033.

## Bugs (full list: `qa/reports/2026-11-05-T182-bug_report.json`)

1. **win_not_detected, HIGH, qa-analyst.** No win in 480 runs. Cannot tell if the game or the bot is at fault. The bot's win detection needs a fix before the win check can be judged.
2. **dominance_candidate, MEDIUM, economy-designer.** ceo_woman_02 + dart: always_expand top in 5 of 6 seeds (mean 19365 vs decent 9733). Decent collapses there to 503 and 165 (seeds 4 and 5).
3. **low_cash_spread, MEDIUM, economy-designer.** 15 of 120 decent runs end under 1000 cash at cycle 40 (lowest 30). The same seed reaches 18000 or more under other combos.
4. **route_waiting_for_room, MEDIUM, producer.** Route 12 "Waiting for room for 3+ cycles" fires in 26 runs (40 warnings), decent and always_expand. No run error. Cause not found.
5. **early_bankruptcy, LOW, economy-designer.** 14 of 120 always_expand runs end bankrupt, cycles 6 to 32; 5 of them at cycle 6 with the fleet ship. Whether intended is UNKNOWN.
6. **exploration_waits_on_locked_dead_world, LOW, producer.** Exploration mode stays on (ship idle) while a dead world waits for MIN_3. It completes in about 2 cycles once MIN_3 is learned. Design question, no permanent soft-lock.

## Notes

- Batch runner: the first batch used a job file with trailing spaces that made `xargs -L 1` merge lines (96 jobs lost). The file was cleaned and all 480 jobs were rerun; the rows in this report are from the clean run.
- Bot pass: the probe found the mining chain needs FND_PERMIT, FND_STORAGE (earned skill, needs trade income), FND_PROSPECT, MIN_1 and MIN_3. MIN_2 is a tech and cannot be learned as a skill.
- Not run: the 40-cycle bot runs were not played with a window; visual checks are the owner's job.
- Analysis script (scratch): `logs/qa-t182/analyse_t182.py`. Probe runner: `qa/bots/flight_probe.sh`, probe script: `qa/bots/flight_probe.gd`.

## Open questions

- UNKNOWN: whether the Bazaar win is reachable at all (win detection is stubbed, T281).
- UNKNOWN: whether always_expand bankruptcy at cycle 6 is intended.
- UNKNOWN: whether exploration should switch off by itself while a dead world waits for MIN_3.
