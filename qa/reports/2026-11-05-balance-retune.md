# Balance retune, 2026-11-05 (v45 to v46)

Method: qa_tree scratch checkout, `--skip-tutorial`, fast clock, 5 seeds per cell, decent unless noted. Baseline = the overnight QA batches (same code and seeds). Wins = count, win cycles in brackets. One change at a time.

## Kept
**maintenance 45 to 40.**

| batch | before (45) | after (40) |
|---|---|---|
| Luxury decent | 2/5 (32, 40) | 4/5 (27, 27, 29, 33) |
| Military decent | 5/5 (27,27,27,29,30) | 5/5 (27,27,27,27,34) |
| Minerals decent | 5/5 (28-40) | 4/5 (29,29,31,32) |
| Biotech decent | 5/5 (31-39) | 5/5 (27,28,30,31,32) |
| base decent | 1/5 (27) | 3/5 (27,27,28) |
| always_expand base / lux / bio | 1/5 (38) / 0 / 0 | 0 / 0 / 0 |
| sloppy, never_expand, passive, spread, bankrupt | all lose | all lose (bankrupt 14 repossessions, END_BANKRUPT c12-13) |

Earliest win cycle 27 (win_earliest_cycle 23 untouched). Focus wins 16/20 vs 14/20. No dominant strategy; loss paths intact. Caveat: 5 seeds, small samples; Minerals lost one win.

## Rejected
- **bot_2_lux_growth 98.8 to 70** (also tried 45, 25): Luxury decent 2/5 at every value (wins 31-32, 40); peak share at c30 0.41 to 0.45. Bot 2 growth is not the limiter. Not kept (reverted to 98.8).
- **sweep_share_pct 0.10 to 0.20** (and 0.15): sloppy 5/5 swept at c30-32 (was soft), never_expand 1/5 swept. But decent Luxury seed 4 is swept at c27 (was a win at 40), so Luxury 1/5. 0.15: sloppy 1/5 swept, same decent seed swept. Loss paths already work (soft), so no benefit. Not kept.
- **ship_cap 6 to 8** (experiment): Luxury 3/5 (up), base decent 4/5 (up), Military 5/5 but slower (27,27,29,37,38), Minerals 4/5 (from 5/5), more repossessions in base (7 vs 0), cash at c20 lower. Mixed. Not kept.

## Owner questions
1. win_earliest_cycle: balance 23, targets 22. Wins start at 27 in all batches, so either works; pick one.
2. chain_BIO_B4 / chain_MIN_B4 order: wins still lag the share hold; mechanic, not a number. Luxury (and losses) are limited by rival strength level and B4 timing, not growth.
3. Clock divergence OV-07 (fast vs timer) still open: these numbers are fast-clock.

Tests: `sh tools/tests/run.sh` in qa_tree, pass=1792 fail=0.
