# Overnight QA, 2026-11-05 (Four Markets, balance v45)

Build: HEAD fe674dc (worktree copy), data_version 45 (ship_cap 6, win_earliest_cycle 23, win_gate_cycle 38, bot_scale 0.22).
Harness: qa/bots/bot_run.gd plus one new option, `--skip-tutorial` (uncommitted, in the worktree only; patch in `2026-11-05-bot_run-skip-tutorial.patch`).
Runs: 183 headless runs in `2026-11-05-runs.jsonl` (5 seeds per strategy unless noted; timer clock 2 seeds). No crash, no frozen run, no SCRIPT ERROR or ERROR line in any log.

## 1. Blocker: the scripted economy never starts without `--skip-tutorial`

Without the flag (batch `fast`), every planner strategy makes zero decisions: decent, sloppy, always_expand, never_expand, spread, mining_focus, dead_run and passive all end with cash flat at 2100 (900 on one seed), 0 ships, 0 routes, and END_SWEPT at cycle 27 (the idle check fires from cycle 1). local_focus logged 2717 `order_failed` events: "Not yet. Follow the tutorial step, or skip the tutorial." The tutorial gate blocks the first ship buy and every order.

With `--skip-tutorial` (main._tut_skip() at cycle 1, same seeds) the economy runs normally. So every balance number below uses the skip flag. Whether a human player can be stuck the same way is UNKNOWN; if yes this is a high softlock in the game, not only a bot issue. Bug OV-01.

## 2. Results by strategy (base, all four markets, --skip-tutorial, fast clock, 5 seeds)

| strategy | wins (win cycles) | outcome | mean final cash (range) | ships | permits | notes |
|---|---|---|---|---|---|---|
| decent | 1/5 (27) | 4 soft END_OUTCOMPETED at 40 | 27.5k (14.5k-42.4k) | 6 | 1 | peak market share 0.41-0.57 |
| always_expand | 1/5 (38, bio gate) | 4 soft at 40 | 12.9k (6.3k-19.4k) | 6 | 0 | "Waiting for room" warnings on 2 of 5 seeds |
| spread | 1/5 (33) | 4 soft at 40 | 28.1k (15.3k-42.5k) | 6 | 1 | 4 repossessions |
| mining_focus | 0/5 | 5 soft at 40 | 17.4k | 6 | 0 | best share 0.52-0.53, never held |
| dead_run | 0/5 | 5 soft at 40 | 17.6k | 6 | 0 | |
| never_expand | 0/5 | 5 soft at 40 | 6.2k (5.7k-7.0k) | 1 | 0 | 4-6 lanes, one ship |
| sloppy | 0/5 | 5 soft at 40 | 6.9k (6.3k-7.5k) | 1 | 0 | one lane; share 0.17-0.31 never below sweep line |
| local_focus | 0/5 | 4 soft, 1 swept (31) | 0.16k (26-497) | 1 | 0 | share 0.64 at cycle 1 with no routes |
| bankrupt | 0/5 | 5 END_BANKRUPT (11-12) | -300 | 0 | 0 | designed loss, reached |
| passive | 0/5 | 5 END_SWEPT (27) | 1.2k | 1 | 0 | designed loss, reached |

Dominance: no non-decent strategy beats decent. Decent, always_expand (no permit) and spread each win once in base; the decent win is the only one at cycle 27.

## 3. Focused runs (--market, 5 seeds each)

| market | decent (permit bought at c10) | always_expand, no permit | always_expand, --permit=2 | local_focus |
|---|---|---|---|---|
| Military | 5/5, cycles 27,27,27,29,30 | 0/5 (1 swept at 31) | 5/5, cycles 27,30,30,33,38 | 0/5 (1 swept at 37) |
| Luxury | 2/5, cycles 32,40 (3 soft) | 0/5 | not run | 0/5 (4 swept, 27-38) |
| Minerals | 5/5, cycles 28,31,32,35,40 | 0/5 | not run | 0/5 |
| Biotech | 5/5, cycles 31,32,32,36,39 | 0/5 | not run | 0/5 |

No-permit decent: 0/5 base (`np_all`) and 0/5 Military (`np_mil`). Across the base and focus batches, every win but one (always_expand base seed 3, Biotech, cycle 38) came from a run that bought permit 2. Always_expand with no permit: 0/5 in all four focus markets.

Early wins: none before cycle 23. Late wins (after 30): 4 of 5 Minerals, 5 of 5 Biotech, 2 of 2 Luxury.

## 4. Timing and win logic

- Win logic checks out against the rules in markets.gd and chains.gd. No win was declared without a 5-cycle hold from cycle 23, and no run passed cycle 40 without its ending.
- The win also waits for the market's B4 chain step (or cycle 38). In the Biotech and Minerals runs the share hold is met by cycle 23-27 (win_streaks in RESULT), but the win fires at 31-39. Example: bio seed 1 holds 9 cycles from 23 and wins at 31. Military wins at 27-30, when its B4 fires earlier. Inference from the RESULT fields, not a traced chain state.
- END_SWEPT did not fire before cycle 25. Passive and local_focus Luxury sweep at 27.

## 5. Clock check

Same seed and strategy, fast vs timer (`skip` vs `timer`): decent seed 2 cash 28,960 vs 16,579; decent seed 1 42,379 vs 33,334; always_expand seed 2 19,436 vs 8,080; never_expand within 6%; sloppy identical. Outcomes depend on the clock. The fast clock numbers should not be treated as the player's numbers until this is explained. Bug OV-07.

## 6. Release export

Static check only (no release export was built): `debug_menu` is created only when `debug_tools_allowed()` (= `OS.is_debug_build()`) is true (game/main.gd). QA hooks have the same guard. export_presets.cfg excludes qa/, tools/, handoffs/ and *.md. No debug or game-control menu is reachable in a release build by this reading. A run of an actual release export is UNKNOWN (not done).

## 7. Balance numbers against data/balance.json

Targets (values.targets): no-skill win 26-30, skilled 22-26, full tree 19-23, early check 22.

- Decent with permit and about 10-12 skills wins at 27-30 in Military, and 31-40 in Minerals, Biotech and Luxury. Military is in range; the others are late. Minerals and Biotech are the pacing problem.
- Cash is idle. Ships reach the cap of 6 by cycle 12-16 on every buying strategy. Cash then climbs to 14k-40k with no sink, while the rivals keep growing and the share falls after cycle 20-25 (decent base seed 1: 0.46 at c19 to 0.33 at c40).
- Early shares are high relative to cash. One lane gives 0.28-0.30 share at cycle 1. Local orders with no route give 0.64-0.75 share at cycle 1 with cash under 1k.
- Cash is squeezed early in Minerals focus (cash 300-1,100 from cycle 3 to 25). Decent Minerals has 7 repossessions in 5 runs and buys 11 ships on one seed.

## 8. Proposed number changes (untested: none of these was run; one batch each to confirm)

1. ship_cap 6 to 8 (test). Evidence: cap binds at cycle 12-14; 14k-40k cash idle at end. Expected: faster focus wins and a higher base win rate. Risk: it also helps always_expand. Alternative if the owner wants to keep 6: add a cash sink.
2. chain_BIO_B4 and chain_MIN_B4 trigger or order (owner: economy and chains). Evidence: wins at 31-39 while the hold is met by 23-27. Mil and Lux B4 both fire earlier. Check the chain step gaps (chain_min_gap 3) and the B1-B3 triggers for Biotech and Minerals before touching rivals.
3. bot_2_lux_growth 98.8 to about 70 (test). Evidence: Luxury decent peaks 0.47-0.64 at cycles 22-25, then falls under 0.5 by cycle 38 (rival growth). Luxury is the only focus market with 3 of 5 losses.
4. sweep_share_pct 0.10 to 0.20 (test). Evidence: sloppy and never_expand (one lane) hold 0.17-0.31 and never sweep; they end soft at 40 instead of swept at 27 (as the 2026-11-03 batch showed). Passive still sweeps at 0.0 share.
5. maintenance 45 to 40 (test, only if the repossession rate holds at 8+ per batch after item 1). Evidence: Minerals decent cash under 1.1k from cycle 3-25; 7 repossessions.
6. win_earliest_cycle: balance says 23; state.md and targets say 22. Owner to decide which is meant; not a number change until then.

Not proposed: local-order share (OV-05). That is a measurement question (does share count volume or margin), owner decision.

## 9. Open items

- Tutorial gate (OV-01): a human-side check is needed before anything else.
- Clock divergence (OV-07): fix or explain before the retune.
- Files: 2026-11-05-runs.jsonl, 2026-11-05-metrics.md/.json (base runs with tutorial skipped, both clocks), 2026-11-05-metrics-tutorial-gate.md (no-skip batch), 2026-11-05-per-run-table.txt (every run), 2026-11-05-overnight-bug_report.json.
- Metrics tool note: metrics.py counts soft END_OUTCOMPETED as "failed" and does not split focused runs by market, so focused numbers are in this report and the per-run table, not in the metrics files.
