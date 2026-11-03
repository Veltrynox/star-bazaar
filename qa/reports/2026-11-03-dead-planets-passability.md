# QA run report: dead-planets passability (2026-11-03)

Date: 2026-11-03. Build: working tree after 3ae7513 (dead worlds, economy rebalance v31, audit fixes). Clock: fast (debug_advance_cycle per cycle, full game logic). Seeds 1 to 8 per strategy. Private TMPDIR for every run. Raw RESULT lines: qa/reports/2026-11-03-dead-planets-passability-runs.jsonl (80 runs). Issues: qa/reports/2026-11-03-bug_report.json (11 entries).

## Summary

- Headless suite: pass=952 fail=0, exit 0. No SCRIPT ERROR, Invalid or null-reference line in any run log (about 400 runs of logs checked).
- Decent with no dead worlds: 4 of 8 wins with the permit flag (cycles 28, 29, 29, 30); 0 of 8 without it. Sim says 98%, median 23. The win band (about 90% or more at cycle 20 to 30) is NOT met in the bot. Medium.
- Dead-world chain: the mechanics run end to end in some seeds (Cinderrest route, Null Core built and fitted in 2 of 8 seeds), but plate is short in most seeds, and cash starvation stops the chain in others. No crash.
- Softlocks: 4 idle softlocks in decent or dead_run without the chain (high), 1 with the scripted chain (high). Cash sits flat for 10 to 20 cycles with routes open.
- Cycle-15 gate: PASS. No dead route accepted before cycle 15; "Opens at cycle 15." shown; accepted at 15.
- Release export: static check only; no export built. No debug menu path in the release config (see section 6).

## 1. Results per strategy (fast clock, seeds 1 to 8)

| Strategy and flags | Wins | Win cycles | End cash median (range) | Notes |
|---|---|---|---|---|
| decent, default (no permit) | 0/8 | none | 3081 (114 to 9824) | seed 7 softlock from cycle 12 |
| decent, `--skip-skill=B1 --permit=2` | 4/8 | 28, 29, 29, 30 | 11069 (332 to 14161) | losses at 30 on seeds 5 to 8 |
| always_expand, default | 0/8 | none | 3491 (114 to 9824) | seed 7 softlock from cycle 12 |
| always_expand, `--skip-skill=B1 --permit=2` | 1/8 | 30 | 5928 (172 to 12682) | not dominant |
| sloppy, default | 0/8 | none | 4190 (2064 to 4536) | expected |
| never_expand, default | 0/8 | none | 5230 (2880 to 6326) | expected |
| dead_run, `--permit=2` (bot's own chain only) | 2/8 | 28, 29 | low (108 to 8031) | softlock seeds 1, 2, 4, 7 |
| dead_run, scripted chain, `--inject=15:1500`, event policy first | 2/8 | 29, 29 (seeds 2, 8) | 7000 to 13000 in wins | softlock seed 4 |
| dead_run, scripted chain, `--event-policy=decline` | 3/8 | 28, 28, 28 (seeds 2, 3, 8) | similar | softlock none |
| sim `tools/sim.py --settle --mc 300` (no dead worlds) | decent 98%, always 75%, sloppy 0%, never 0% | decent median 23 (20 to 30) | | sim ignores dead worlds |

Decent win-band check: target about 90% or more, cycles 20 to 30. Bot: 50% (permit flag), 0% (default). FAIL. Wins land at 28 to 30 (late edge, no win before 22 and none after 30). The gap to the sim is already logged (2026-11-02 trade-goods report).

Ship count: every bot run ends with 4 or 5 ships (ship_cap 5). The sim median is also 5.

## 2. Dead-world route (scripted chain, seeds 1 to 8)

The bot's own dead_run plan does not lay dead routes (the planner never ranks them), so the chain was driven by a script (method in section 5). Steps:

| Step | Result | Evidence |
|---|---|---|
| 1. No route from a dead world before cycle 15 | PASS | `dead_1 dross: Opens at cycle 15.` at cycles 1 and 12 (seeds 1, 3). `dead_2 nullglass: Opens at cycle 15.` at cycles 6 to 14 |
| 2. M1 learned (Cold Survey) | PASS | learned at cycles 6 to 13 (learning before 15 is allowed by design) |
| 3. Cinderrest (dead_1) dross route runs | PASS | accepted at cycle 15 (seeds 1, 3). `dross/running` in plate_log; dross reaches Space Storage (seed 3: up to 150 to 196 dross) |
| 4. Fabric build (F1 + 600 credits) | PASS in 6 of 8 | built at cycles 13 to 17 (seeds 2, 3, 5, 6, 7, 8). Seeds 1 and 4 never afford it in the scripted run |
| 5. Plate made | FAIL in 6 of 8 | plate max 11 (seed 5), 7 (seed 7), 0 in seeds 1, 2, 3, 4, 6, 8. Cause: no nullglass in Space Storage (route not accepted or source empty, see bug P3-dead-chain-plate) |
| 6. Null Core built (plate 1, nullglass 2, 250 credits) | PASS in 2 of 8 | built at cycle 19 (seed 5) and 23 (seed 7) |
| 7. Null Core fitted to a route | PASS | `fit route 10` (seed 5), `fit route 9` (seed 7); `core_route_id` set |
| 8. Greywake (M2) nullglass route to Space Storage | PARTIAL | M2 learned at 12 to 15. Route refused before C3 (`Routes between systems need Long Haul (C3).`), then accepted at 15 or 16 in some seeds. Source empty in most seeds from the next cycle (cash starvation, see bug P3-dead-chain-scripted-seed1). Greywake storage was filled once in seed 5 and 7 (up to 202 nullglass) |
| 9. Dead chain does not block a win | PARTIAL | wins in seeds 2 and 8 with the chain (29). Seed 1 LOSS at 30 with cash 144 with the chain (the same seed wins with decent). The chain can cost a win in the bot |

Fabric built before any input route existed (cycle 13 in seeds 3, 6, 8): allowed by the game, no warning. Owner question.

## 3. Cycle-15 gate and DEAD_UNLOCK

- Gate refusals before 15: PASS (see step 1). Panel text `Opens at cycle 15.` is covered by the suite.
- At 15: refusal changes to a ship or cash reason, and the route is accepted when a ship is free. PASS.
- DEAD_UNLOCK notice: the post is at main.gd lines 1803 to 1804 (end of cycle 14). The suite checks it (tools/tests/run_tests.gd, dead gate block, around line 3645). In bot runs the notice queue is long, so visibility at cycle 15 was not confirmed in the bot: UNKNOWN (low).
- Dead chain and win: no dead route blocks the decent win (decent wins without it). The scripted chain can lower cash to about 100 for 10 or more cycles (see section 4).

## 4. Errors, softlocks, freezes

Log scan: `SCRIPT ERROR`, `Invalid`, `null instance`, `Parse Error`: 0 lines in all logs. The only engine line is `Condition "ret != noErr" is true. Returning: ""` (macOS audio, headless). Environment, not game code. No crash, no frozen run, no watchdog.

Softlocks (bot flag: 3 cycles or more with no cash or stock change until the end):

| Run | Reproduce | Idle from | State |
|---|---|---|---|
| decent seed 7 (default) | `STRATEGIES=decent SEEDS="7" EXTRA="" sh qa/bots/run_batch.sh <out>` | cycle 12 | cash 114, 4 routes, 3 orders, to 30 |
| always_expand seed 7 (default) | `STRATEGIES=always_expand SEEDS="7" EXTRA="" ...` | cycle 12 | same state |
| dead_run seed 1 | `STRATEGIES=dead_run SEEDS="1" EXTRA="--permit=2" ...` | cycle 19 | cash 108, 5 routes |
| dead_run seed 2 | `... SEEDS="2" EXTRA="--permit=2"` | cycle 10 | cash 110, 3 routes |
| dead_run seed 4 | `... SEEDS="4" EXTRA="--permit=2"` | cycle 20 | cash 216, 0 routes, 4 ships |
| dead_run seed 7 | `... SEEDS="7" EXTRA="--permit=2"` | cycle 24 | cash 110, 5 routes |
| dead_run seed 4 (scripted chain) | `... SEEDS="4" EXTRA="--permit=2 --skill-order=B1,C1,A1,M1,M2,F1,C3 --inject=15:1500"` | cycle 20 | cash 216, 0 routes |

Cash flat at 110 or 216 (about trip plus upkeep) suggests cash starvation stops the routes. Whether a human could lay a route at 216 cash with 4 idle ships was not probed (UNKNOWN). Logged as high.

## 5. Method and bot changes (qa/bots/bot_run.gd, dead_run only)

Changed (guarded to `strategy == "dead_run"`; decent, always_expand, sloppy and never_expand paths are unchanged; the batch for those was run before the change):
- Null Core: build once when `can_build_core` is ok, then fit to the first route out of a dead world. Logged in `core_log`.
- Greywake retry: the nullglass route to the station is retried each cycle until accepted; each new refusal reason is logged.
- Scripted chain: from cycle 15, lays dead_1 dross and (once C3 is known) dead_2 nullglass to the station. If no ship is free, closes the weakest non-dead route (max 3, normal Remove). Keeps the two chain routes out of the planner's close rule. Sets a Buy order at each dead world (the mining order) every cycle. Logged in `dead_log`.
- Per-cycle `plate_log`: [cycle, plate, nullglass, dross at the station, chain route states and source stock].
- Notice probe at cycles 14 and 15 (shown, queue, last).

Not changed: game code, data, balance numbers, GDD. Suite run once, before the bot edits (the suite does not use bot_run.gd). No game code changed by QA.

## 6. Release export (static, not built)

- export_presets.cfg excludes `tools/*`, `qa/*`, `handoffs/*`, `*.md`, `schedule.json` from the export.
- Debug tools: `debug_tools_allowed()` returns `OS.is_debug_build()` (game/main.gd around lines 2171 to 2176), and debug hooks are gated by `OS.is_debug_build()`.
- The release binary was not exported in this run (UNKNOWN for the built zip).

## 7. Balance observations (for the economy designer; not changed here)

1. Fabric payback (cycle 23, 600 credits): NOT MEASURED. The bot sets no plate sell order, so plate earns nothing in the run. Plate made: 7 to 11 by cycle 30 in the two seeds that got there. Paper math (100 per batch from cycle 16) assumes full input supply the chain did not reach in these runs.
2. Null Core saves the trip: code path confirmed (game/route_engine.gd lines 190 to 191, `tp * null_core_trip_mult`), and the suite checks it (run_tests.gd around line 3693). Saving per cycle (45 on a 90 trip) not measured in the bot.
3. Dead routes into Space Storage earn nothing (T138: income comes from destination sell orders). Dead dross to station: net 0 in the bot, nullglass route net -104 per cycle (ship cost, no income). The chain is paid by credits until plate sells. This drains cash in a scripted run (seed 1 loss at 144). Suggest: check the chain cash path against the 2026-11-03 rebalance math (which assumed dross sold at Voltara, not stored).
4. dead_shore_cost 250 vs carry on: EV32 fired in seeds 1 and 7 only. The bot picks the first enabled choice (shore up, 250). With `--event-policy=decline` (last choice = carry on, but EV29 also changes to planet closed): seed 1 cash 144 to 2607, seed 7 cash 6956 to 7811. The spread is real but confounded by EV29. A per-event choice policy is needed to isolate EV32. UNKNOWN: which side wins in paper terms with the chain running.
5. ship_cap 5: no free ship at cycle 15 in 7 of 8 seeds (seed 4 had no M1 yet). A dead route can only start by closing a standing route. Owner decision whether dead routes should take a slot ahead of standing routes.
6. Decent win band: 4/8 with permit (sim 98%). Likely the same mismatch as before; re-check before any new tuning.

## 8. Open questions

- UNKNOWN: softlock cause at cash 110 to 216 (cash starvation or planner refusal). A `can_connect` probe in the stuck state would answer it.
- UNKNOWN: DEAD_UNLOCK visibility in a long notice queue.
- UNKNOWN: release zip not exported.
- Not tested: the nullglass Greywake to station route with a permit bought after cycle 15 (C3 timing); the EV20/EV26 gap from 2026-11-02 still open.

Bugs: qa/reports/2026-11-03-bug_report.json (11 entries; high: 4 softlocks and the chain plate gap; medium: decent win band, chain cash drain, fabric timing, ship cap; low: notice visibility, bot plate sell gap, always_expand win).
