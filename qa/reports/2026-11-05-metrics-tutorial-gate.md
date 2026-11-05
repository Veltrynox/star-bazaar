# QA metrics report

Inputs: results_fast.jsonl

Runs: 50 total, 50 default-config (base), 4 failed (crash, frozen or softlock).

Warnings:
- 50 runs carry bot issues (see the RESULT issues field)

## Clock: fast (base runs 50)

### a. Decision density

| strategy | runs | cycles | decisions | mean per cycle | zero-decision cycles | mean per run |
|---|---|---|---|---|---|---|
| decent | 5 | 135 | 0 | 0.00 | 100% | 0.0 |
| sloppy | 5 | 135 | 0 | 0.00 | 100% | 0.0 |
| always_expand | 5 | 135 | 0 | 0.00 | 100% | 0.0 |
| never_expand | 5 | 135 | 0 | 0.00 | 100% | 0.0 |
| bankrupt | 5 | 40 | 0 | 0.00 | 100% | 0.0 |
| dead_run | 5 | 135 | 0 | 0.00 | 100% | 0.0 |
| local_focus | 5 | 189 | 223 | 1.18 | 90% | 44.6 |
| mining_focus | 5 | 135 | 0 | 0.00 | 100% | 0.0 |
| passive | 5 | 135 | 0 | 0.00 | 100% | 0.0 |
| spread | 5 | 135 | 0 | 0.00 | 100% | 0.0 |

Decisions by kind: decent: none; sloppy: none; always_expand: none; never_expand: none; bankrupt: none; dead_run: none; local_focus: order_change 209, ship_buy 4, skill_learn 10; mining_focus: none; passive: none; spread: none

### b. Dominant strategy and win share

Seeds present in all strategies: 5 (ties: 5).

| strategy | top-cash share of seeds | sole top seeds | wins | runs | win share |
|---|---|---|---|---|---|
| decent | 12% | 0 | 0 | 5 | 0% |
| sloppy | 12% | 0 | 0 | 5 | 0% |
| always_expand | 12% | 0 | 0 | 5 | 0% |
| never_expand | 12% | 0 | 0 | 5 | 0% |
| bankrupt | 0% | 0 | 0 | 5 | 0% |
| dead_run | 12% | 0 | 0 | 5 | 0% |
| local_focus | 0% | 0 | 0 | 5 | 0% |
| mining_focus | 12% | 0 | 0 | 5 | 0% |
| passive | 12% | 0 | 0 | 5 | 0% |
| spread | 12% | 0 | 0 | 5 | 0% |

### c. Outcome spread

| strategy | cash runs | mean cash | stdev | min | max | range | win cycles | loss cycles | end cycle not ok | failed |
|---|---|---|---|---|---|---|---|---|---|---|
| decent | 5 | 1,860 | 537 | 900 | 2,100 | 1,200 | none | 27 | 0 | 0 |
| sloppy | 5 | 1,860 | 537 | 900 | 2,100 | 1,200 | none | 27 | 0 | 0 |
| always_expand | 5 | 1,860 | 537 | 900 | 2,100 | 1,200 | none | 27 | 0 | 0 |
| never_expand | 5 | 1,860 | 537 | 900 | 2,100 | 1,200 | none | 27 | 0 | 0 |
| bankrupt | 5 | -300 | 0 | -300 | -300 | 0 | none | 8 | 5 | 0 |
| dead_run | 5 | 1,860 | 537 | 900 | 2,100 | 1,200 | none | 27 | 0 | 0 |
| local_focus | 5 | 377 | 370 | 37 | 896 | 859 | none | 29 | 0 | 4 |
| mining_focus | 5 | 1,860 | 537 | 900 | 2,100 | 1,200 | none | 27 | 0 | 0 |
| passive | 5 | 1,860 | 537 | 900 | 2,100 | 1,200 | none | 27 | 0 | 0 |
| spread | 5 | 1,860 | 537 | 900 | 2,100 | 1,200 | none | 27 | 0 | 0 |

### d. Skill impact (decent)

No decent --skip-skill runs in the input; skill impact not measured.

### d2. Skill log (decent learn runs)

Runs with skill_log: 5 of 5 learn runs.

| skill | learned in | mean cycle | mean points |
|---|---|---|---|
| FND_STORAGE | 0% | n/a | n/a |
| FND_PERMIT | 0% | n/a | n/a |
| FND_PROSPECT | 0% | n/a | n/a |
| MIL_1 | 0% | n/a | n/a |
| MIL_2 | 0% | n/a | n/a |
| MIL_3 | 0% | n/a | n/a |
| MIL_4 | 0% | n/a | n/a |
| MIL_5 | 0% | n/a | n/a |
| MIL_6 | 0% | n/a | n/a |
| MIL_7 | 0% | n/a | n/a |
| LUX_1 | 0% | n/a | n/a |
| LUX_2 | 0% | n/a | n/a |
| LUX_3 | 0% | n/a | n/a |
| LUX_4 | 0% | n/a | n/a |
| LUX_5 | 0% | n/a | n/a |
| LUX_6 | 0% | n/a | n/a |
| LUX_7 | 0% | n/a | n/a |
| MIN_1 | 0% | n/a | n/a |
| MIN_2 | 0% | n/a | n/a |
| MIN_3 | 0% | n/a | n/a |
| MIN_4 | 0% | n/a | n/a |
| MIN_5 | 0% | n/a | n/a |
| MIN_6 | 0% | n/a | n/a |
| MIN_7 | 0% | n/a | n/a |
| BIO_1 | 0% | n/a | n/a |
| BIO_2 | 0% | n/a | n/a |
| BIO_3 | 0% | n/a | n/a |
| BIO_4 | 0% | n/a | n/a |
| BIO_5 | 0% | n/a | n/a |
| BIO_6 | 0% | n/a | n/a |
| BIO_7 | 0% | n/a | n/a |

### d3. Per-skill impact (single skip vs all skills, matched by seed and choice)

No single-skill skip runs in the input.

### e. Event impact

Events on: 48 runs, off: 2 runs. Matched pairs: 0. Cash diff (on minus off) n/a; win rate diff n/a.
