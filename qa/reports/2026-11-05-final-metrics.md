# QA metrics report

Inputs: results_final.jsonl

Runs: 18 total, 18 default-config (base), 12 failed (crash, frozen or softlock).

Warnings:
- 3 runs carry bot issues (see the RESULT issues field)

## Clock: fast (base runs 18)

### a. Decision density

| strategy | runs | cycles | decisions | mean per cycle | zero-decision cycles | mean per run |
|---|---|---|---|---|---|---|
| decent | 3 | 78 | 268 | 3.44 | 19% | 89.3 |
| sloppy | 3 | 120 | 12 | 0.10 | 98% | 4.0 |
| always_expand | 3 | 120 | 336 | 2.80 | 12% | 112.0 |
| never_expand | 3 | 120 | 166 | 1.38 | 16% | 55.3 |
| passive | 3 | 81 | 3 | 0.04 | 96% | 1.0 |
| spread | 3 | 120 | 380 | 3.17 | 8% | 126.7 |

Decisions by kind: decent: bot_skill 8, order_change 145, permit_buy 3, route_close 22, route_open 34, ship_buy 18, skill_learn 35, workshop_build 3; sloppy: order_change 6, route_open 3, ship_buy 3; always_expand: order_change 208, route_close 34, route_open 46, ship_buy 18, skill_learn 27, workshop_build 3; never_expand: order_change 119, route_close 10, route_open 13, ship_buy 3, skill_learn 18, workshop_build 3; passive: ship_buy 3; spread: bot_skill 12, order_change 254, permit_buy 3, route_close 20, route_open 33, ship_buy 19, skill_learn 36, workshop_build 3

### b. Dominant strategy and win share

Seeds present in all strategies: 3 (ties: 0).

| strategy | top-cash share of seeds | sole top seeds | wins | runs | win share |
|---|---|---|---|---|---|
| decent | 0% | 0 | 2 | 3 | 67% |
| sloppy | 0% | 0 | 0 | 3 | 0% |
| always_expand | 0% | 0 | 0 | 3 | 0% |
| never_expand | 0% | 0 | 0 | 3 | 0% |
| passive | 0% | 0 | 0 | 3 | 0% |
| spread | 100% | 3 | 0 | 3 | 0% |

### c. Outcome spread

| strategy | cash runs | mean cash | stdev | min | max | range | win cycles | loss cycles | end cycle not ok | failed |
|---|---|---|---|---|---|---|---|---|---|---|
| decent | 3 | 12,027 | 12,508 | -1,659 | 22,866 | 24,525 | 27 | 24 | 1 | 0 |
| sloppy | 3 | 6,827 | 474 | 6,331 | 7,275 | 944 | none | none | 0 | 3 |
| always_expand | 3 | 18,370 | 3,648 | 14,505 | 21,754 | 7,249 | none | none | 0 | 3 |
| never_expand | 3 | 6,673 | 413 | 6,322 | 7,128 | 806 | none | none | 0 | 3 |
| passive | 3 | 1,200 | 0 | 1,200 | 1,200 | 0 | none | 27 | 0 | 0 |
| spread | 3 | 27,880 | 3,653 | 24,872 | 31,945 | 7,073 | none | none | 0 | 3 |

### d. Skill impact (decent)

No decent --skip-skill runs in the input; skill impact not measured.

### d2. Skill log (decent learn runs)

Runs with skill_log: 3 of 3 learn runs.

| skill | learned in | mean cycle | mean points |
|---|---|---|---|
| FND_STORAGE | 100% | 8.0 | 1.0 |
| FND_PERMIT | 100% | 1.0 | 1.0 |
| FND_PROSPECT | 100% | 2.0 | 1.0 |
| MIL_1 | 100% | 8.3 | 1.0 |
| MIL_2 | 0% | n/a | n/a |
| MIL_3 | 100% | 8.3 | 2.0 |
| MIL_4 | 0% | n/a | n/a |
| MIL_5 | 100% | 9.0 | 3.0 |
| MIL_6 | 0% | n/a | n/a |
| MIL_7 | 0% | n/a | n/a |
| LUX_1 | 100% | 8.3 | 1.0 |
| LUX_2 | 0% | n/a | n/a |
| LUX_3 | 100% | 9.0 | 2.0 |
| LUX_4 | 0% | n/a | n/a |
| LUX_5 | 100% | 9.0 | 3.0 |
| LUX_6 | 0% | n/a | n/a |
| LUX_7 | 0% | n/a | n/a |
| MIN_1 | 100% | 10.0 | 1.0 |
| MIN_2 | 0% | n/a | n/a |
| MIN_3 | 67% | 23.0 | 2.0 |
| MIN_4 | 0% | n/a | n/a |
| MIN_5 | 0% | n/a | n/a |
| MIN_6 | 0% | n/a | n/a |
| MIN_7 | 0% | n/a | n/a |
| BIO_1 | 100% | 10.0 | 1.0 |
| BIO_2 | 0% | n/a | n/a |
| BIO_3 | 0% | n/a | n/a |
| BIO_4 | 0% | n/a | n/a |
| BIO_5 | 0% | n/a | n/a |
| BIO_6 | 0% | n/a | n/a |
| BIO_7 | 0% | n/a | n/a |

### d3. Per-skill impact (single skip vs all skills, matched by seed and choice)

No single-skill skip runs in the input.

### e. Event impact

Events on: 18 runs, off: 0 runs. Matched pairs: 0. Cash diff (on minus off) n/a; win rate diff n/a.
