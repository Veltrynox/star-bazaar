# QA run report: trade goods and asteroid mining (T161, follow-up v2)

Date: 2026-11-02. Goal: trade-goods-asteroid-mining. Build: working tree after T159, T160, T158. Clock: fast (debug_advance_cycle per cycle, full game logic); one timer-clock run for comparison.

## Follow-up: always_expand is now a separate policy

The v1 always_expand bot used decent's buy rule, so its results matched decent on every seed. v2 changes the bot only (qa/bots/bot_run.gd):
- always_expand buys a ship whenever cash covers the price (up to ship_cap), before skill learning and route building.
- always_expand learns expansion first: C1 (Permit Charter), C3 (Long Haul), A1 (Space Storage), A2 (Deep Holds).
- decent and mining_focus are unchanged.

Decision log, seed 1 (fast):
- decent ship buys at cycles 1, 1, 3, 4, 7, 8, 10, 10; skills C1 (c1), A1/A2/C2 (c4); permit 2 at cycle 2; cash at cycles 1 to 6: 0, 400, 100, 200, 602, 539.
- always_expand ship buys at cycles 1, 1, 2, 3, 4, 6, 7, 10; skills C1 (c1), A1/A2/C2 (c3); no permit bought; cash at cycles 1 to 6: 0, 100, 200, 100, 700, 108.

Result: always_expand differs from decent on every seed (cash, ships and ending). It does not match decent. It is the weaker policy: 0 of 8 wins, which matches the T160 sim (always_expand 0%).

## The three required runs (seed 1, fast clock)

| Run | Flags | Ending | Cycle | Final cash | Ships | Permits | Silk / chips / ore / energy / food route-cycles | Ore taken |
|---|---|---|---|---|---|---|---|---|
| decent, no mining | `--skip-skill=B1 --permit=2` | WIN, END_REL_FULL_X | 29 | 8517 | 23 | 1 (cycle 2) | 4 / 0 / 0 / 185 / 168 | 0 |
| always_expand, no mining | `--skip-skill=B1 --skill-order=C1,C3,A1,A2 --permit=2` | LOSS, END_LOSS | 30 | 526 | 24 | 0 | 5 / 0 / 0 / 56 / 49 | 0 |
| mining_focus | `--permit=2` (B1 first) | LOSS, END_LOSS | 30 | 1007 | 24 | 1 | 4 / 0 / 110 / 155 / 126 | 88 (of 600) |

## Seeds 1 to 8 (fast clock), v2 runs

- decent: wins seeds 1, 2, 5, 6, 8 (cycles 27 to 29); losses at 30 on seeds 3, 4, 7 (cash 5978, 1016, 1033). 5 of 8.
- always_expand: 0 of 8 wins; every run ends LOSS at cycle 30 with cash 435 to 6856 (median about 1005). Permit never bought in seeds 1, 5, 7.
- mining_focus: wins seeds 2, 3, 5, 7, 8 (cycles 29 to 30); losses at 30 on seeds 1, 4, 6. Ore taken 88 to 234, mean about 173 of 600. 5 of 8.
- decent and mining_focus v2 numbers are the same as v1 (the change touches only always_expand).
- Timer clock, decent seed 1: win at 30, cash 10948 (fast clock gave win at 29, cash 8517). Outcome depends on the clock.

Raw RESULT lines: qa/reports/2026-11-02-trade-goods-asteroid-mining-runs.jsonl (31 runs: 24 v2 fast seeds 1-8 for three strategies, 6 earlier fast seed 1-2 runs from the first pass, 1 timer run; the always_expand rows in the earlier pass are superseded by v2).

## Per-goal findings

- Crashes: none. Softlocks: none. Frozen: none. Every run reached a game-over ending; the save matched the choice.
- Script errors: one engine line per run, `Condition "ret != noErr"` (macOS audio, headless). Environment, not game code.
- Goods: silk 2 to 5 route-cycles per run. Chips: 0 route-cycles in the decent and mining runs; 3 in one always_expand run. Ore: mining_focus only.
- Mining yield: ore taken 88 to 234 per run. Clusters still hold 312 to 512 ore at cycle 30.
- Events hit (ids seen): EV01, 02, 03, 04, 06, 07, 09, 10, 11, 12, 14, 15, 16, 21, 22, 24, 25, 28. EV26 (ore down) and EV20 (asteroid pay-out) never fired.
- Dead choice: UNKNOWN. The bot takes the first enabled choice and does not record untaken choices.
- Release export: not verified (export to scratch failed in sandbox). Static check: the debug menu is created only when debug_tools_allowed() is true (game/main.gd around line 208) and debug_menu.gd gates on OS.is_debug_build(). export_presets.cfg excludes tools, qa and handoffs, not game/, so debug_menu.gd ships as code but is never instantiated in release.

## Comparison with the T160 sim

- decent: sim 98% win, median 24. Bot 5 of 8, wins at 27 to 29.
- always_expand: sim 0%. Bot 0 of 8. Matches.
- mining_focus: sim 52%, median 29. Bot 5 of 8, wins at 29 to 30.

## Dominant strategy

No dominant strategy. decent and mining_focus both win 5 of 8. always_expand is weaker (0 of 8). No strategy wins earlier than cycle 27.

## Bot changes (qa/bots/bot_run.gd, QA tooling only; no game code or balance changed)

1. mining_focus: learns B1 first, cluster ore lanes before the trade ranking, cluster routes opened with main.send_from_cluster.
2. Destination click sent a second time when a stop picker is open (v1 logged 21 false route_build_failed).
3. always_expand: spare-ship buying and expansion-first skill order (v2).
4. Per-run tallies in RESULT: lane_cycles, cluster_lane_cycles, ore_taken, clusters_left_end.

## Could not check (UNKNOWN)

- Cluster card, pack look, legend width, planet panel at window size, skill screen B1 row: the bot does not capture screens.
- Real exported release binary: export failed in sandbox.
- Dead choices: not tracked.
- Cluster risk line: not implemented (T159).

## Issues

See qa/reports/2026-11-02-bug_report.json (9 entries). "always_expand not distinct" is FIXED in the bot (evidence above). Still open medium: decent losses at 30 (seeds 3, 4, 7), sim mismatch for decent, chips barely traded, EV20/EV26 never fire, always_expand permit starvation.


## Follow-up v3: cash reserve and route warnings (owner re-run, same day)

Changes under test (game code, not changed by QA): Buy orders keep the trip and upkeep of routes that will run this cycle (route_engine.gd, handoff gameplay-programmer cash-reserve); route warnings show after two cycles; cash popup drops zero lines (ui-programmer handoffs). The sim has no settle model, so these runs are the only check. Bot flags (qa/bots/bot_run.gd, QA only): a warning_streak issue when a route shows "Not enough cash." or "Waiting for room" for a third cycle in a row; reserve_short diagnostic when cash at cycle start is below fixed cost x running routes (approximate; the exact reserve is internal to the engine, so UNKNOWN whether any Buy spent below reserve).

Flags as before: fast clock, seeds 1 to 8, same flags as v2.

| Strategy | v2 (before reserve) | v3 (with reserve) | Idle deadlocks (softlock) | Warning streaks (3+ cycles) |
|---|---|---|---|---|
| decent | 5 of 8 wins (cycles 27-29) | 0 of 8 wins, all END_LOSS at 30 | seeds 1, 4, 6, 7 (from cycles 11 to 22) | seeds 3, 4 |
| always_expand | 0 of 8 wins | 0 of 8 wins, all END_LOSS at 30 | seeds 3, 5, 6, 7, 8 (from cycles 18 to 25) | seed 2 |
| mining_focus | 5 of 8 wins (cycles 29-30) | 0 of 8 wins, all END_LOSS at 30 | none | seeds 1 to 8 (2 to 6 streaks each) |

Cash cycles 3 to 8, seed 1 (fast):
- decent: 547, 554, 853, 851, 169, 438. Cash fell by 682 at cycle 7 with 3 routes running.
- always_expand: 200, 221, 276, 229, 301, 305.
- mining_focus: same as decent for cycles 3 to 8 (same first buys).

reserve_short diagnostic (cash below fixed cost x running routes at cycle start): 2 to 11 cycles per run. Example, decent seed 1 cycle 7: cash 169, 3 running routes, fixed cost 115 each. Approximate, so this is a flag for the owner, not a confirmed overspend.

Read of the results:
- The reserve rule makes all three strategies lose at cycle 30 in every seed. The v2 wins (decent, mining) are gone. The rule starves Buys in cash-tight cycles early, and the economy does not recover by cycle 30.
- Idle deadlocks: the bot's idle rule (no cash or stock change for 3 cycles) fires on 9 of 24 runs. Cash sits near 110 to 250 with routes on and Buy orders set, so nothing trades. Owner question for the producer: is a route stuck at Not enough cash with no income a dead end the player can leave? The game keeps running to cycle 30 and then loses.
- Warnings: "Not enough cash." shows for 3 or more cycles in a row on 14 runs (mostly mining). This breaks the two-cycle rule the owner asked for, or the rule counts differently; UNKNOWN which.
- Dead choice: UNKNOWN (not tracked).
- Crashes: none. Script errors: only the engine audio line.

Note for owner: the always_expand and mining results moved with the reserve rule as expected (mining from 5 of 8 to 0 of 8; always_expand unchanged at 0 of 8 but now with idle deadlocks).

Report data: qa/reports/2026-11-02-trade-goods-asteroid-mining-runs.jsonl (v3 rows included).


## Follow-up v4: after the reserve deadlock fix (owner, same day)

Game code changed by gameplay-programmer (route_engine.gd route_reserve and _buy_feeds; handoff cash-reserve). QA did not change code or balance. Bot flags unchanged from v3. Fast clock, seeds 1 to 8, same flags as v2 and v3. Raw RESULT lines: qa/reports/2026-11-02-trade-goods-asteroid-mining-v4-runs.jsonl (24 runs).

Before/after table (endings are END_LOSS at cycle 30 unless marked):

| Strategy | v1 (no reserve) | v3 (reserve, before fix) | v4 (reserve, after fix) |
|---|---|---|---|
| decent | 5 of 8 wins, cycles 27-29 | 0 of 8 wins; idle deadlocks 4 runs | 0 of 8 wins; idle deadlocks 2 runs (seeds 2, 5) |
| always_expand | 0 of 8 wins | 0 of 8 wins; idle deadlocks 5 runs | 0 of 8 wins; idle deadlock 1 run (seed 5) |
| mining_focus | 5 of 8 wins, cycles 29-30 | 0 of 8 wins; warning streaks all seeds | 0 of 8 wins; no idle deadlock; warning streaks in all 8 seeds (2 to 8 each) |

v4 per run:
- decent: seed 1 END_LOSS at 30 with cash 999; seed 2 idle from cycle 23 (cash 112); seed 5 idle from cycle 15 (cash 115); others END_LOSS at 30 with cash 277 to 912.
- always_expand: END_LOSS at 30 in all 8 seeds; cash 115 to 1081; idle only seed 5.
- mining_focus: END_LOSS at 30 in all 8 seeds; cash 221 to 947; ore taken 240 to 534.

Cash cycles 3 to 8, seed 1: decent 437, 699, 591, 857, 175, 437 (v3 was 547, 554, 853, 851, 169, 438); always_expand 200, 221, 276, 208, 246, 319 (v3: 200, 221, 276, 229, 301, 305).

Warning streaks: "Not enough cash." or "Waiting for room" for a third cycle in a row: 46 flags across 24 runs (decent 0 to 2 per run; always_expand 0 to 2; mining 2 to 8). Still open. UNKNOWN whether the UI two-cycle rule and the engine reason count differ, since the bot reads the engine reason, not the popup.

Answer to the owner question: decent and mining are not back toward 5 of 8. Both are 0 of 8 at cycle 30. The fix removed most of the idle deadlocks (9 of 24 in v3 to 3 of 24 in v4, and none in mining) but the economy still ends in a loss at cycle 30 for all three strategies. The reserve rule (or something else changed since v1) cuts early growth too far. Owner decision needed on pacing; QA does not change balance.

Reserve breach check: still approximate, UNKNOWN.
Crashes: none. Script errors: only the engine audio line. Dead choice: UNKNOWN.


## Follow-up v5: starting_credits 1800 to 2100 (economy designer, data_version 22)

Only change: data/balance.json starting_credits 1800 to 2100 (handoff economy-designer reserve-rebalance). Bot flags as v4. Fast clock, seeds 1 to 8. Raw RESULT lines: qa/reports/2026-11-02-trade-goods-asteroid-mining-v5-runs.jsonl (24 runs).

Before/after table (endings END_LOSS at cycle 30 unless marked):

| Strategy | v1 (no reserve, 1800) | v4 (reserve, 1800) | v5 (reserve, 2100) |
|---|---|---|---|
| decent | 5 of 8 wins, cycles 27-29 | 0 of 8 wins; idle 2 runs | 0 of 8 wins; idle 1 run (seed 4, from cycle 22) |
| always_expand | 0 of 8 wins | 0 of 8 wins; idle 1 run | 0 of 8 wins; idle 0 runs |
| mining_focus | 5 of 8 wins, cycles 29-30 | 0 of 8 wins; 39 streak flags; 313 warn route-cycles | 0 of 8 wins; 19 streak flags; 189 warn route-cycles |

Ship 3 timing and cash at cycle 3 (decent):
- v4: ship 3 at cycles 7, 7, 8, 7, 7, 9, 7, 10; cash at cycle 3 = 437 in all seeds.
- v5: ship 3 at cycles 13, 14, 13, 10, 13, 15, 12, 16; cash at cycle 3 = 198 in all seeds.
- Cash at cycle 1 end: 300 (v5) vs 0 (v4). Two ships are bought at cycle 1 in both builds.

Cash cycles 3 to 8, seed 1 (decent, v5): cash at cycle 3 is 198 and the run ends with 656. The mining and always_expand cash paths are in the results file.

Criteria (economy designer):
1. Decent ship 3 by cycle 5, or cash above 900 at cycle 3, in at least 6 of 8 seeds: FAIL. 0 of 8 (ship 3 at cycles 10 to 16; cash at cycle 3 is 198 in all seeds).
2. Decent wins at least 5 of 8, at cycles 24 to 29: FAIL. 0 of 8.
3. Mining_focus wins fewer than decent: FAIL (not met). Both 0 of 8, so not fewer.
4. Always_expand wins 0 of 8: PASS (0 of 8).
5. Fewer mining warning streaks than v4: PASS. Streak flags 19 vs 39; warn route-cycles 189 vs 313 (per seed, 5 of 8 seeds are lower; the other 3 are higher).

Read of the result: the float did not restore early tempo. Ship 3 came later, not earlier, and cash at cycle 3 fell from 437 to 198. The designer's expectation (float restores tempo) is not seen in this bot. Cause UNKNOWN; a likely candidate is that the extra cash lets the bot buy and route earlier in a way the reserve then holds back. Per the contingency: ship 3 was not on time, so the test does not isolate the float. Recommended next step: a reserve-aware sim (tools/sim.py has no settle model); the owner should not treat the float as the fix.

Idle deadlocks: 1 of 24 runs (decent seed 4, idle from cycle 22, cash 117). Down from 3 of 24 in v4 and 9 of 24 in v3.
Warning streaks: 19 flags across mining runs (decent and always_expand: 0 to 2 per run). Still open.
Crashes: none. Script errors: only the engine audio line. Dead choice: UNKNOWN. Reserve breach: UNKNOWN (diagnostic approximate).


## Alpha round 1 (data_version 24: ship_cap 6, win_cash 11500, trip_cost 90, Voltara ore_sell 12)

Flags: fast clock, seeds 1 to 8. decent --skip-skill=B1 --permit=2; mining_focus --permit=2; always_expand --skip-skill=B1 --skill-order=C1,C3,A1,A2 --permit=2; never_expand and sloppy with no permit. Raw RESULT lines: qa/reports/2026-11-02-alpha-round1-runs.jsonl (40 runs).

Results (END_LOSS at cycle 30 unless marked):
- decent: 1 of 8 wins (seed 4, WIN at 27). Losses at 30 on the other seven. Idle deadlock seed 6 (cycle 15, cash 109).
- mining_focus: 1 of 8 wins (seed 2, WIN at 28). Idle deadlocks in 7 of 8 seeds (1, 3, 4, 5, 6, 7, 8), from cycles 6 to 22. Ships 2 in 5 of them.
- always_expand: 3 of 8 wins (seeds 3 at 30, 5 at 29, 7 at 26). Idle deadlock seed 1 (cycle 14, cash 110).
- never_expand: 0 of 8 wins, 8 of 8 END_LOSS at 30.
- sloppy: 0 of 8 wins, 8 of 8 END_LOSS at 30.

Mining deadlock cause (checked in skill_log): mining_focus learns C1 at cycle 1 and then has 0 skill points, so B1 (Prospecting, the mining gate) is never learned. With no B1, no cluster lane is planned (cluster_lanes=0) and no planet lane passes the payback rule, so routes stay at 0 and nothing moves. Cause in the bot versus the economy (skill point income) is UNKNOWN; the bot learns B1 first only if it can afford it.

Criteria:
1. Decent wins at least 6 of 8, at cycles 22 to 29: FAIL. 1 of 8.
2. Cash at cycle 3 is 276 in every seed (permit strategies), and decent ship 3 by cycle 13 in at least 6 of 8: PASS. Cash at cycle 3 = 276 in all 8 decent seeds (and all always_expand seeds). Decent ship 3 at cycles 11, 12, 11, 10, 10, 10, 12, 14: 7 of 8 by cycle 13. (never_expand and sloppy have no ship buys, so their cash at cycle 3 is 1444 and 1044; not applicable.)
3. mining_focus wins at least 4 of 8 and is no more than 3 cycles faster than decent: FAIL. 1 of 8 (cycle 28 vs decent 27; not faster, but the win count fails).
4. always_expand wins at most 5 of 8: PASS. 3 of 8.
5. never_expand and sloppy both end in a loss at cycle 30: PASS. 16 of 16 END_LOSS at 30.
6. No crash, no softlock, warning streaks only in a minority of cycles: FAIL on softlock. No crash (PASS). Idle deadlocks in 9 of 40 runs (decent 1, always_expand 1, mining_focus 7) (FAIL). Warning streak flags: 8 across all permit runs, 0 in mining (PASS).

Blockers and owners:
- Mining gate (criteria 3 and 6): mining_focus cannot reach B1 after C1 under the alpha economy. Owner decision: skill point income or whether C1 should be bought before B1 in this path. Fix: gameplay-programmer (skill point or buy gate), economy-designer (point budget).
- Decent pacing (criterion 1): 1 of 8 wins. With ship_cap 6 the cap is the limiter (the economy designer's open question). Owner decision: keep cap 6 and accept, or add a working-capital buy gate and raise the cap. Fix: economy-designer (win_cash, cap) and gameplay-programmer (buy gate if chosen).
- Idle deadlocks in decent and always_expand (seeds 6, 1): cash 109 and 110 with routes running. Same family as the v4 reserve deadlock. Fix: gameplay-programmer.
- Mining_focus idle path in the bot (no cluster lanes without B1) is the cause of most mining deadlocks; not a game bug by itself.

UNKNOWN: whether mining_focus can ever learn B1 in the real game (points at start and income).
Crashes: none. Script errors: only the engine audio line. Dead choice: UNKNOWN.


## Alpha round 2 (data_version 25: ship_cap 5, win_cash 12500; B1 exempt from locks; first-route fare; reserve kept)

Flags: as round 1, fast clock, seeds 1 to 8. Raw RESULT lines: qa/reports/2026-11-02-alpha-round2-runs.jsonl (40 runs). Bot change for this round: RESULT now has clusters_harvested (clusters that gave ore).

Results (END_LOSS at cycle 30 unless marked):
- decent: 2 of 8 wins (seed 2 at 28, seed 3 at 29). Seed 7 idle deadlock (see below).
- mining_focus: 7 of 8 wins (seeds 1 at 24, 2 at 25, 3 at 30, 4 at 23, 5 at 26, 6 at 23, 7 at 29); seed 8 loss at 30. Win cycles 23 to 30, median 25.
- always_expand: 5 of 8 wins (seed 1 at 25, 3 at 30, 4 at 27, 5 at 27, 7 at 27). Losses seeds 2, 6, 8.
- never_expand: 0 of 8 wins, 8 of 8 END_LOSS at 30.
- sloppy: 0 of 8 wins, 8 of 8 END_LOSS at 30.

Mining checks (requested):
- B1 learned at cycle 1 in all 8 mining seeds (skill_log). Yes.
- Clusters harvested: 5 of 5 in every seed (clusters_harvested 5); ore taken 600 per seed (all clusters emptied by the end).

Decent seed 7 (separate note, as requested): idle from cycle 15, cash 104, 4 ships, 4 routes, "Buy/Sell orders on 4". The issue text does not split Buy from Sell, so whether it had only Sell orders is UNKNOWN from this output. Other decent seeds: no idle.

Criteria:
1. Decent wins at least 6 of 8, at cycles 22 to 29: FAIL. 2 of 8 (cycles 28, 29).
2. Cash at cycle 3 is 276 in every seed, and decent ship 3 by cycle 13 in at least 6 of 8: PASS for decent and always_expand (cash 276 in all 16 seeds); decent ship 3 at cycles 11, 12, 11, 10, 10, 12, 12, 14, so 7 of 8 by cycle 13. Mining cash at cycle 3 is 628 in every seed, not 276, because B1 is learned at cycle 1 (it spends points early). Strictly the 276 clause does not apply to mining; flagged for the owner.
3. Mining_focus wins at least 4 of 8 and is no more than 3 cycles faster than decent: FAIL on the speed clause. Wins: 7 of 8 (PASS on count). Mining median win 25 vs decent median 28.5 (about 3.5 cycles faster); earliest mining win 23 vs earliest decent 28 (5 cycles). Decent has only 2 wins, so the comparison is thin.
4. Always_expand wins at most 5 of 8: PASS, exactly 5 of 8 (at the limit).
5. Never_expand and sloppy both end in a loss at cycle 30: PASS (16 of 16 END_LOSS at 30).
6. No crash, no idle softlock (decent seed 7 separate), warning streaks only a minority of cycles:
   - Crash: PASS (none).
   - Idle: PASS for 39 of 40 runs; decent seed 7 is an idle run (FAIL on that case).
   - Warning streaks: 20 flags in total (mining 17, always_expand 3, decent 0). Warning route-cycles: decent 39, always_expand 66, mining 113 over 8 runs each. Counted per route, not per cycle, so a strict cycle fraction is UNKNOWN; streaks are short (2 to 4 per run). Call: PASS with caveat.

Blockers and owners:
- Decent pacing (criterion 1): 2 of 8. Economy-designer and owner (ship_cap 5 is an owner decision, per the r2 handoff). Gameplay-programmer if the real late game earns less than the mirror (the r2 open question).
- Mining speed clause (criterion 3): mining is now faster than decent by about 3.5 cycles at median. Economy-designer (Voltara ore_sell, cluster yield) if the owner wants parity; the 3-cycle bound is a designer call.
- Decent seed 7 idle (criterion 6): gameplay-programmer; check whether the route with only Sell orders can recover cash (UNKNOWN whether Buy orders existed).
- Mining cash at cycle 3 (criterion 2 wording): owner to confirm the 276 clause excludes mining.

Crashes: none. Script errors: only the engine audio line. Dead choice: UNKNOWN.


## Dead worlds (Cinderrest dead_1 in system 1, Greywake dead_2 in system 2; dross, nullglass, M1/M2/F1, fabric, danger)

Flags: fast clock, seeds 1 to 8. decent --skip-skill=B1 --permit=2 (regression, as round 2); mining_focus --permit=2; always_expand --skip-skill=B1 --skill-order=C1,C3,A1,A2 --permit=2; dead_run --permit=2 --skills=B1,C1,A1,M1,M2,F1,C3 (skill order B1, C1, A1, M1, M2, F1, C3; no permit point reserve, so M1 is bought as soon as affordable). Raw RESULT lines: qa/reports/2026-11-02-dead-worlds-runs.jsonl (32 runs). New bot tallies: dead_log (gate refusals and skill locks when they change), fabric_log, danger_rows, fabric_state.

Results (END_LOSS at cycle 30 unless marked):
- decent: 3 of 8 wins (seed 6 at 30, seed 7 at 25, seed 8 at 28). Round 2: 2 of 8 (cycles 28, 29). No regression. Idle: none.
- mining_focus: 6 of 8 wins (cycles 23 to 28). Round 2: 7 of 8. M1 is now learned at cycles 12 to 29 and takes points from the early path. Idle: none.
- always_expand: 4 of 8 wins (cycles 23 to 25). Round 2: 5 of 8. Idle: seed 4 from cycle 16 (cash 115).
- dead_run: 0 of 8 wins, all END_LOSS at 30, cash 366 to 8978. M1 learned at cycles 8 to 10, M2 at 12 to 22, F1 only in seed 6 (cycle 21). Dross lane-cycles 10 to 20 per run. No nullglass route in any run.

Checks:
1. Decent still wins at least 2 of 8, win rate not down: PASS. 3 of 8 (round 2: 2 of 8).
2. Dead-world gate: PARTIAL.
   - Cinderrest (dead_1, dross): refused at cycle 1 with "Needs Cold Survey." (dead_log, seeds 1 to 8). Allowed once M1 is learned: no gate refusal after cycle 8 in any dead_run seed; seed 6 at cycle 30 shows ok=true for dead_1 dross; seeds 1 to 8 show "No ship available" (gate passed) at cycles 8 and 10. PASS.
   - Greywake (dead_2, nullglass, M2): NOT TESTED. dead_2 does not exist in trade.planets until system 2 opens, and dead_run never bought the permit (permits_bought 0 in all 8 dead_run runs; cash never reached cost + 400). The probe is in place; no output. UNKNOWN.
   - Skill locks seen: M1 "locked permit_first" at cycle 1, "locked first_row" at cycles 2 to 7 (second row needs A1 and C1), then learnable. M2 needs M1; F1 needs M1 and M2.
3. Danger: PASS for rise and cap. Seed 6: 1, 2, 3, 4, 5 at cycles 14 to 18, then holds at 5 (cap). Max 5 in all 8 dead_run runs. Stalled routes do not raise it: UNKNOWN (no clean stalled-route cycle in the logs; the code only ticks routes whose state is "running").
4. Six danger events in order, part two 4 cycles after part one: FAIL. Part-one events EV29, EV32 and EV35 are not in data/events.json (their texts exist only in data/story_text.json), so they can never fire. Part-two events fire anyway, without part one: EV31 at cycles 5 to 11 (seed 5, before any dead route), EV37 at cycles 13 to 19 (seed 6) and 9 to 11 (seed 7), EV30 at cycles 25 to 27 (seed 3). Nothing crashed. Owner and story-designer: the follow-up schedule cannot be checked until part one exists in events.json.
5. Fabric: PARTIAL.
   - Refused before F1: PASS ("skill" at cycle 1).
   - Builds once for 1000 credits: PASS in seed 6 (built at cycle 21, the cycle F1 was learned; refused "built" at cycle 22). Build cost is 1000 in balance.json (fabric_build_cost, v28); the fabric handoff text still says 1500.
   - Runs with inputs: FAIL (not reached). No nullglass ever reached the station, so 0 plates in all runs. Seed 6 shows state "stalled" from cycle 21. The stall reason text is not captured (UNKNOWN).
6. Nullglass route from Greywake (system 2) to the system 1 station: NOT REACHED. Probe exists (can_connect from dead_2 to station -1 for nullglass), but dead_run never opened system 2. Found: the fabric in system 1 cannot run in these runs; whether the route is allowed is UNKNOWN. Owner question: does the permit come early enough (cash) for system 2 to open?
7. No crash, no softlock: PASS for the batch (0 SCRIPT ERROR lines in 32 runs). One earlier smoke run (dw2, seed 1) logged Parse Error for res://assets/asteroid_asset/asteroid_low.obj and material_512.png, and ROCK_MESH; not seen in the batch, so transient or import-state related (UNKNOWN). Idle: always_expand seed 4 only (cycle 16). Known gaps not retested: banners for the six new events (missing in story text per the gameplay handoff); silk/chips failure.

Blockers and owners:
- Part-one events missing from events.json (check 4): story-designer and gameplay-programmer (data load).
- Greywake and nullglass route (checks 2 and 6): owner decision on the system 2 permit timing; economy-designer if cash is the limit.
- Fabric inputs (check 5): depends on 6. Fabric cost text (1000 vs 1500): economy-designer to confirm.
- Dead_run economy: 0 of 8 wins. Only dross routes ran (10 to 20 lane-cycles per run). Economy-designer to confirm whether dross alone is enough, once checks 4 and 6 are fixed.
