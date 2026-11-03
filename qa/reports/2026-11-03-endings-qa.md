# QA report: market endings, full QA (2026-11-03)

Build: branch next, data_version 40 (commit 557ba6f). Headless bot runs (`qa/bots/bot_run.gd` via `run_batch.sh`, fast clock, ship_cap 5), 160 runs in total, seeds 1-8 for every setup. Raw results: `qa/reports/2026-11-03-endings-qa-runs.jsonl`. Bugs: `qa/reports/2026-11-03-endings-qa-bug_report.json`.

## Summary

- 160 of 160 runs ended with a RESULT line. 0 crashes, 0 frozen runs, 0 Godot ERROR or SCRIPT ERROR lines. Pool events EV40-EV51 fired and no popup blocked a run.
- All 8 market win endings appear, good and bad (counts below). END_BANKRUPT, END_SWEPT and END_OUTCOMPETED all appear.
- The 11 endings all have a title and body in `data/story_text.json`. No TODO or empty text.
- Tests: `tools/tests/run.sh` pass=1165 fail=0 (log in `qa/reports/2026-11-03-endings-tests.log`).
- No high-severity issues. 6 medium (economy and sweep balance, one death-spiral rule, one reachable bankruptcy), 2 low.

## Endings seen (160 runs)

| Ending | Side | Runs | Notes |
|---|---|---|---|
| END_MIL_GOOD | win | 17 | mostly c27 |
| END_MIL_BAD | win | 13 | c27-31 |
| END_LUX_GOOD | win | 8 | c27-28 |
| END_LUX_BAD | win | 4 | c30-31 (2 with 1 repossession), 4 OUTCOMPETED |
| END_MIN_GOOD | win | 8 | c27-40 (c40 win in seed 4) |
| END_MIN_BAD | win | 8 | c28 |
| END_BIO_GOOD | win | 13 | c27-40 |
| END_BIO_BAD | win | 13 | c27-33 |
| END_SWEPT | loss | 16 | at c27-40, mil or bio share about 7 pct, decent mil bad seeds 3 and 8 |
| END_BANKRUPT | loss | 9 | 8 with the bankrupt strategy (QA debit, c11-14); 1 by real play (spread seed 8, c25) |
| END_OUTCOMPETED | soft | 51 | c40, cash 4-43k |

Good and bad win counts for each market: MIL 17 good / 13 bad, LUX 8 / 4, MIN 8 / 8, BIO 13 / 13. Every win ending appears at least once.

## Win rate per strategy (8 seeds each)

| Strategy and setup | Wins | Endings | Notes |
|---|---|---|---|
| decent, mil focus, good chains | 8/8 | MIL_GOOD | c27 |
| decent, mil focus, bad chains | 6/8 | MIL_BAD x6, SWEPT x2 | SWEPT seeds 3 and 8 |
| decent, lux focus, good chains | 8/8 | LUX_GOOD | c27-28 |
| decent, lux focus, bad chains | 4/8 | LUX_BAD x4, OUTCOMPETED x4 | |
| decent, min focus, good chains | 8/8 | MIN_GOOD | c27-40 |
| decent, min focus, bad chains | 8/8 | MIN_BAD | c28 |
| decent, bio focus, good chains | 7/8 | BIO_GOOD x7, OUTCOMPETED x1 | |
| decent, bio focus, bad chains | 8/8 | BIO_BAD | c27-29 |
| decent, mil focus, random chains | 7/8 | MIL_GOOD 4, MIL_BAD 3, OUTCOMPETED 1 | |
| decent, mil focus, random, local orders | 7/8 | MIL_GOOD 3, MIL_BAD 4, SWEPT 1 | local orders add nothing over focus |
| decent focus, all setups above | 64/72 | | 89 pct |
| decent default, random chains, permit 2 (default) | 2/8 | MIL_GOOD 2, OUTCOMPETED 6 | |
| decent default, random chains, no permit | 4/8 | BIO_GOOD 1, BIO_BAD 3, OUTCOMPETED 3, SWEPT 1 | |
| always_expand (no focus), random chains | 7/8 | BIO_GOOD 5, BIO_BAD 2, OUTCOMPETED 1 | see bug 4 |
| spread (4 markets round-robin), random | 0/8 | OUTCOMPETED 7, BANKRUPT 1 | |
| mining_focus, random | 0/8 | OUTCOMPETED 8 | cash 12-25k |
| never_expand, random | 0/8 | OUTCOMPETED 8 | cash 5-8k |
| sloppy, random | 0/8 | OUTCOMPETED 8 | cash 6-8k |
| local_focus (no routes), mil | 0/8 | SWEPT 4, OUTCOMPETED 4 | |
| bankrupt (QA debit) | 0/8 | BANKRUPT 8 | c11-14 |
| passive (tutorial ship only) | 0/8 | SWEPT 8 | c27 |

Dominance answer: a non-focused strategy wins more than the focused one only as a tie. always_expand (7/8) matches the focused decent aggregate (64/72) and beats focused mil bad and lux bad. No other non-focused strategy wins. Decent default (no focus) wins 2/8 or 4/8, depending on permit.

## Checks

1. Win endings with good and bad chains: all 8 seen (table above). Win cycles are c27-31 for most runs. 7 decent focus wins are after c30 (see bug 3). No win before c23.
2. END_BANKRUPT: the bankrupt strategy reaches it at c11-14 with the QA debit (`bankrupt_drained` 2.4-3.5k). Real play reaches it in 1 of 8 spread runs (seed 8, no debit): cash goes from 1,411 at c13 to -238 at c22, then 5 repossessions and END_BANKRUPT at c25 (bugs 1 and 2). The decent focus runs never went below zero.
3. Bot domination and loss endings: END_SWEPT appears in decent mil bad (seeds 3 and 8), decent default (seed 7, c29) and local_focus or local-orders runs. A rival above 50 pct is not an ending in itself. The swept rule (player under 10 pct for 3 cycles) fires, and the end screen names the leading rival. The rival share is not in the RESULT line, so the 50 pct figure is a proxy from rival_strengths: bot_1 holds about 56-60 pct of the rival volume in mil (2366 vs 585-926), so with the player at 7 pct it is above 50 pct. Exact share: UNKNOWN.
4. Softlocks and crashes: none. Every run has `end_cycle_ok`, `end_screen_ok` and `stats_ok` true, except the bankrupt runs where `end_cycle_ok` is false because no end cycle is expected (bot check, bug 8). Popups never blocked a run (no frozen runs). Event pool EV40-EV51 fired 53-174 times each across the batch.
5. Dominant strategies: see the strategy table. Spread, mining_focus, sloppy, never_expand, local_focus, passive and bankrupt win 0/8. always_expand wins 7/8 (bug 4).
6. Windowed end screens (`qa/run_game.sh` with a scratch harness that calls `end_screen.gd` `show_ending` directly; the bot runs headless only): END_MIL_GOOD "The Quiet Fleets" and END_MIL_BAD "The Full Racks" both lay out correctly, title, body, stat line, cycles, cash, buttons. Screenshots: `qa/reports/2026-11-03-endings-end-screen-END_MIL_GOOD.png` and `qa/reports/2026-11-03-endings-end-screen-END_MIL_BAD.png`. The market readout shows 0 pct because the harness has no game state. This is a harness limit, not a bug. The full played-to-end screen was not captured.

Release export: `export_presets.cfg` excludes `qa/*`, `tools/*` and `*.md`. `main.gd` creates the debug menu only when `debug_tools_allowed()` (OS.is_debug_build()) is true, so release builds have no debug or game-control menu. No release build was run (UNKNOWN for a built binary).

## Bugs

| # | Severity | Owner | Summary |
|---|---|---|---|
| 1 | medium | economy-designer | Normal spread play reaches END_BANKRUPT (seed 8, no debit) |
| 2 | medium | gameplay-programmer | Stipend is skipped on repossession cycles, so a negative-cash spiral cannot be rescued |
| 3 | medium | economy-designer | 7 decent focus wins after c30, 2 of them at c40 (final-cycle rule) |
| 4 | medium | economy-designer | always_expand wins 7/8 through BIO, equal to focused decent |
| 5 | medium | gameplay-programmer | Bad mil chain swept at c27 in 2 of 8 seeds (player share 7 pct) |
| 6 | medium | economy-designer | Default decent wins 2/8 with the permit, 4/8 without; 24-31k cash unspent in 6 losses |
| 7 | low | gameplay-programmer | Routes stuck on "Waiting for room" for 19-26 cycles; "Not enough cash" streaks |
| 8 | low | qa-analyst | Bot checks fire on expected endings (passive idle, localord s4 after win, bankrupt end_cycle) |

Full steps, seed and expected/actual are in the bug JSON.

## Limits and open items

- Seeds 1-8 are near-identical for fixed chains (lux good seeds 1 and 2 have the same cash, 30595). Coverage of the chain and event choices is thin. Noise would need a bot change.
- The rival share over 50 pct is a proxy (see check 3).
- The mil bad seeds 3 and 8 sweep was not traced to a single cause in the run data. The share falls over c8-c22 and the bot buys a second ship at c14 after a repossession.
- The bankrupt and swept runs use the strategies as specified. No run was played by a human.
