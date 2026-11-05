# Final check, 2026-11-05 (HEAD 6ec2943, balance v46, new Russian text)

- `sh tools/tests/run.sh` on a clean checkout of HEAD: 1792 PASS, 0 FAIL, exit 0. (Use a private TMPDIR: the script's scratch HOME is shared, so two parallel runs mix their logs.)
- Bot batch, 6 strategies x 3 seeds, `--skip-tutorial`, fast clock (`2026-11-05-final-runs.jsonl`, `2026-11-05-final-metrics.md`): no crash, no freeze, no script error.
  - decent: 2 wins, 1 bankrupt (seed 2, Military, cash negative from cycle 21, END_BANKRUPT at 24). New with v46? Not seen in the 5-seed retune batch; 3 seeds only, so UNKNOWN whether it is a pattern. Worth a 10-seed check.
  - always_expand, spread, sloppy, never_expand: all soft endings at 40 (no win); passive: swept (designed loss).
  - metrics.py counts soft endings as "failed"; the "12 failed" line is that, not crashes.
- The "Unable to open file ... .godot/imported/*.webp" errors in the logs are from a fresh checkout whose import cache lacked the new event banners; they are not game bugs.
- Open from the overnight report (owner decisions): tutorial gate vs bots (OV-01), permit 2 as a required step, win_earliest_cycle 22 vs 23, B4 chain timing, fast vs timer clock gap (OV-07).
