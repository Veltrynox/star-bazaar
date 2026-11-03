# Final passability verdict (2026-11-03)

Date: 2026-11-03. Clock: fast. Seeds 1 to 8 for every row (48 runs). Private TMPDIR. Build: working tree after 3ae7513 plus the bot change in section 1 (no game, data or tools/sim.py change by QA). Raw RESULT lines: qa/reports/2026-11-03-final-passability-runs.jsonl. Issues: qa/reports/2026-11-03-bug_report-final-passability.json (4 entries).

## Verdict

| # | Acceptance line | Result | Verdict |
|---|---|---|---|
| 1 | Decent default wins at least 6 of 8 by cycle 30 | 8 of 8, cycles 21, 21, 22, 22, 23, 23, 24, 25 (median 22.5) | PASS |
| 2 | Dead chain completes (plate, Null Core fitted) and does not block the win | Literal chain config (no permit): 0 of 8 plate, 0 of 8 Null Core fitted. With `--permit=2`: Null Core fitted in 7 of 8 (seed 7 not). Chain does not reduce wins: 2 of 8 with chain vs 1 of 8 without (dead_p2). | FAIL (completion as specified) |
| 3 | Any flat-cash stall left? | No run has cash unchanged for 3 or more cycles in a row. Longest repeat is 2 cycles (decent skip-B1 seed 2, always_expand seeds 1, 6, 7). Lowest cash is 63 (chain seed 1, cycle 10 onward), moving, not flat. The BR-01 stall at 144 to 146 is gone. | PASS |
| 4 | Any softlock with a repro? | 0 frozen, 0 crash, 0 bot issues across 48 runs. No SCRIPT ERROR or Parse Error. | PASS |

Overall: FAIL on line 2. Lines 1, 3 and 4 pass. Pacing flag (medium) on decent, always_expand dominance flag (medium) and one chain-incomplete item (medium) are in section 4.

## 1. Bot change (qa/bots/bot_run.gd)

- Decent default now buys the system 2 permit (C1 + 600 credits) as soon as it can afford it. This is a legitimate human player path: the permit is a normal game purchase, and a human with the same cash can buy it at the same point. Implemented as `permit_sid = 2` when `strategy == "decent"` and no `--permit` is given. Opt-out flag: `--no-permit`. Other strategies unchanged.
- Side effect: `_permit_reserve()` now also holds skill points for the permit in decent runs once C1 is learned. Decent skill timing shifts slightly (for example B1 at cycle 1, then C1, A1 at 6 to 9).
- Permit bought at cycle 6 to 9 in all 8 decent default seeds (`notes`: "permit 2 bought at cycle N").
- Not changed: other strategies, game code, data, tests, GDD.

## 2. Batch results (fast clock, seeds 1 to 8)

| Batch | Wins | Win cycles | Median win | End cash median (range) | Permits |
|---|---|---|---|---|---|
| decent, default (now buys permit) | 8/8 | 21, 21, 22, 22, 23, 23, 24, 25 | 22.5 | 15155 (14176 to 16147) | 1 each |
| decent, `--skip-skill=B1 --permit=2` | 8/8 | 21, 21, 21, 22, 23, 23, 23, 24 | 22.5 | 15016 (14401 to 16024) | 1 each |
| always_expand, default | 6/8 | 27, 28, 29, 30, 30, 30 | 28.5 | 14203 (11977 to 14789) | 0 |
| dead_run chain (literal: `--skill-order=B1,C1,A1,M1,M2,F1,C3 --inject=15:1500`) | 4/8 | 26, 28, 30, 30 | 29 | 13962 (11589 to 14844) | 0 |
| dead_run chain + `--permit=2` | 2/8 | 30, 30 | 30 | 10477 median (7753 to 14248) | 1 each |
| dead_run `--permit=2` (no chain) | 1/8 | 29 | 29 | 10413 median (7370 to 15032) | 1 each |

Errors: 0 SCRIPT ERROR and 0 Parse Error in the 48 logs. The only ERROR line is the macOS audio line `Condition "ret != noErr"` (48 lines, environment). Shell line "Error opening /private/var/select/sh" is sandbox noise, not a game error.

Win and loss trigger: every win has final cash at or above win_cash 14000 at the cycle the win choice fires (choice_cycle = expected_end_cycle in all decent runs). Every loss is at cycle 30 with cash below 14000. No win or loss fired at the wrong cycle.

Sim (`tools/sim.py --settle --mc 300`, win_cash 14000): decent 100%, median 24 (18 to 30); always_expand 92%, median 22; sloppy 0%; never_expand 0%; never_expand+permit 0%.

## 3. Dead-chain detail (per seed)

Literal chain (no permit): fabric built at cycle 16 in all 8 seeds, plate 0, Null Core refused at cycle 16 with reason "stock" in all 8 seeds. No dross or nullglass route runs because system 2 is never opened.

Chain with `--permit=2`:

| Seed | Outcome | Null Core fitted | Win cycle or end cash |
|---|---|---|---|
| 1 | loss | cycle 22 | 8329 |
| 2 | win | cycle 16 | 30 (14248) |
| 3 | loss | cycle 18 | 10727 |
| 4 | loss | cycle 22 | 7753 |
| 5 | loss | cycle 22 | 7753 |
| 6 | loss | cycle 18 | 13874 |
| 7 | win | not fitted (bug report item 2) | 30 (14016) |
| 8 | loss | cycle 18 | 10227 |

## 4. Flags

- Medium, pacing: decent default wins at cycle 21 in 2 of 8 (seeds 2 and 4). Rule is "before about 22". Borderline, one cycle.
- Medium, dominance check: always_expand wins 6 of 8 (rule flags any always-expand win). Judged NOT dominant: decent wins 8 of 8, faster, in the same batch.
- Medium, dead chain incomplete: literal config never completes (0 of 8). Chain with permit: seed 7 Null Core never fitted (nullglass route never runs). See bug report.
- Not run this batch: sloppy and never_expand (not in the brief's batch). Last known: 0% in the sim and in earlier bot batches.

## 5. Dead chain and the win

The chain does not block the win in the sense of lowering wins: with permit, 2 of 8 with chain vs 1 of 8 without (median end cash 10477 vs 10413). But the dead_run path as a whole wins 1 to 2 of 8, while decent (no dead chain) wins 8 of 8. The win does not depend on the chain. Whether the game should allow fabric to be built with no reachable input is UNKNOWN.

## 6. Release export

Static check only. `game/main.gd` creates the debug menu only when `debug_tools_allowed()` is true (`OS.is_debug_build()`), line 215. `game/debug_menu.gd` header says the same. `export_presets.cfg` preset 0 sets `custom_template/debug=""`, `custom_template/release=""` and `export/distribution_type=1`, so a release export uses the release template. No binary was exported in this run, so the export itself is not verified (UNKNOWN until an export is built).

## 7. Headless suite

`TMPDIR=<private> sh tools/tests/run.sh`: TOTAL pass=961 fail=0, exit 0.

## 8. Gap versus sim (one line)

Sim decent is 100%, median 24 (18 to 30); bot decent with the permit is 8 of 8, median 22.5 (21 to 25), about 1.5 cycles faster, and sim does not model dead worlds (the bot's dead_run results are not in the sim at all).

## Open questions

- UNKNOWN: whether the game should let fabric be built when no input route is reachable (system 2 closed).
- UNKNOWN: why chain_p2 now gives 2 of 8 wins where economy-designer's handoff reported 3 of 8 (same flags; bot code changed since their run, not isolated).
- UNKNOWN: binary-level release export check (needs an export build).
