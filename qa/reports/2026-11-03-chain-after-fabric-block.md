# Chain after fabric block (2026-11-03)

Date: 2026-11-03. Clock: fast (default). Seeds 1 to 8 for every row (24 runs). Private TMPDIR per batch. Build: working tree with the fabric-block change (gameplay-programmer handoff 2026-11-03-fabric-block). QA changed no game, data, tools/sim.py or bot code. Raw RESULT lines: `<scratch>/chain1/decent/results_d1.jsonl`, `<scratch>/chain2/chain_permit/results_cp.jsonl`, `<scratch>/chain3/nochain/results_np.jsonl`. Issues: `qa/reports/2026-11-03-bug_report-chain-after-fabric-block.json` (3 entries).

## Verdict

| # | Acceptance line | Result | Verdict |
|---|---|---|---|
| 1 | Decent default wins at least 6 of 8 | 8 of 8, cycles 21, 21, 22, 22, 23, 23, 24, 25, median 22.5 | PASS |
| 2 | Chain with permit: plate made and Null Core fitted in at least 6 of 8 seeds | Plate made 8 of 8. Null Core fitted 8 of 8. | PASS |
| 3 | No softlock, crash or freeze | 0 frozen, 0 crash, 0 SCRIPT ERROR, 0 Parse Error in 24 logs | PASS |
| 4 | Headless suite fail=0 | TOTAL pass=965 fail=0, exit 0 | PASS |

Overall: PASS on all four lines.

## Results per strategy

| Batch | Wins | Win cycles | Median win | Notes |
|---|---|---|---|---|
| decent, default | 8/8 | 21, 21, 22, 22, 23, 23, 24, 25 | 22.5 | Permit 2 bought at cycles 6 to 9 in all 8 |
| dead_run chain + `--permit=2` (`--skill-order=B1,C1,A1,M1,M2,F1,C3 --inject=15:1500`) | 3/8 | 26, 28, 28 (seeds 3, 2, 8) | 28 | Fabric built cycle 15 (seeds 1 to 6, 8) and 16 (seed 7). Losses seeds 1, 4, 5, 6, 7 at cycle 30 |
| dead_run `--permit=2` (no chain flags) | 4/8 | 27, 29, 30, 30 (seeds 3, 7, 2, 4) | 29.5 | Fabric built cycle 15 in 7 seeds. Seed 7 never built (see section 3) |

Errors: 0 SCRIPT ERROR and 0 Parse Error. The only ERROR line in all logs is the macOS audio line `Condition "ret != noErr"` (environment, once per run). The "Error opening /private/var/select/sh" line is sandbox noise.

Win and loss trigger: every win fired at `choice_cycle` = `expected_end_cycle`. Every loss is at cycle 30 with final cash below 14000. No win or loss at a wrong cycle.

## 1. Chain with permit, per seed

| Seed | Fabric built | Plate first | Null Core fitted | Outcome |
|---|---|---|---|---|
| 1 | 15 | 16 | 16 | loss (cash 13009) |
| 2 | 15 | 16 | 16 | win at 28 |
| 3 | 15 | 16 | 16 | win at 26 |
| 4 | 15 | 16 | 16 | loss (cash 12987) |
| 5 | 15 | 17 | 17 | loss (cash 12624) |
| 6 | 15 | 17 | 17 | loss (cash 11121) |
| 7 | 16 | 20 | 20 | loss (cash 9342) |
| 8 | 15 | 16 | 16 | win at 28 |

Route dead_1 (dross) and dead_2 (nullglass) to the system 1 station open at cycle 15 (Opens at cycle 15 message). The fabric build was refused with reason `inputs` at cycles 7 to 10 (before the routes exist) and built the same cycle the chain routes went in. The block works as specified.

## 2. Wins

Chain with permit: 3 of 8 (seeds 2, 3, 8). Earlier verdict (before the fabric block) recorded 2 of 8 for this config. Permit only (no chain): 4 of 8. Earlier verdict recorded 1 of 8. The change came with the fabric-block build. Cause not isolated (UNKNOWN).

## 3. Where the fabric block stopped the chain

Only one seed. Permit-only batch, seed 7: the nullglass route was refused at cycle 15 with "Routes between systems need Long Haul (C3)". C3 was not in the bot's default skill order and was never learned, so nullglass never reached the station. The fabric stayed unrouted and was never built. This is the fabric block working as specified, and the cause is the bot's skill order. The player can learn C3 later, so this is not a softlock. Logged as bot_gap, low.

## 4. Flags

- Medium, unclear rule: after the first Null Core, plate stays at 1 from cycle 16 to 30 in all 8 chain seeds, while nullglass and dross pile up at the source cap. Whether the fabric should keep making plate is UNKNOWN; owner to confirm. Entry in the bug report.
- Medium, pacing (owner decision: unchanged): decent default wins at 21 in 2 of 8 seeds (2 and 4). Recorded only.
- Low, bot gap: seed 7 in the permit-only batch (section 3).

## 5. Softlock and stall check

No run froze, crashed or ended without a RESULT line. Chain runs keep re-issuing dross and nullglass buy orders each cycle after the fabric is built. The dead_1 route showed "No ship available" at cycle 15 in some seeds. A flat-cash stall check was not run in this batch (UNKNOWN for this batch; the 2026-11-03 final passability run covers it). No softlock found.

## 6. Not run

Release export (binary check) not run in this batch. Sloppy and never_expand not in this brief. Release debug menu check not repeated; last static check (2026-11-03 final passability) still applies.

## Open questions

- UNKNOWN: intended plate output after the first Null Core (section 4).
- UNKNOWN: why the win counts for both chain configs rose after the fabric block (1 to 4 for permit-only, 2 to 3 for chain).
