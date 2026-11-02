# Permit points: C1 plus system 2 permit (2026-11-03)

## Arithmetic (balance v20, game/main.gd _award_planet/_award_route)
Points: planet 1 (each once, home counts at start), new pair 2, system 3 (only in system 2). System 1 has 3 planets, so the cap from system 1 alone is 3 + 3 pairs x 2 = 9.
- First route (home + one planet): 1 + 1 + 2 = 4. Energy and food on the same pair give no extra points.
- Second route to the third planet: +1 +2 = 7. Third pair: +2 = 9.
- Need: C1 (skill_cost_C1) 1 + permit_points_2 3 = 4. Also 600 credits (permit_2_cost).
- C1 has no prerequisite. A1 costs 1 and unlocks after two routes.

## Where the player gets stuck
One route pair gives exactly 4, so there is zero spare. Any other point spent first (A1 = 1, B1 = 1, A2 = 1) leaves 3 - 1 = 2 < 3 and the permit says "points". A player who makes energy and food on one pair, then buys A1, is blocked until a third planet or pair is added (needs 2 more points). Second likely gate: 600 credits while the ship costs 900 (reason "credits"). I could not reproduce a case with only C1 bought; UNKNOWN which reason the owner saw (cash or points).

## Options (sim --set on scratch values; balance.json untouched)
A) permit_points_2 3 -> 2: C1 + permit = 3 of the first 4 points, 1 spare for A1. Keeps every other award. Trade-off: cheaper system 2 expansion; C2 survey discount (-1) then brings it to 1.
B) skill_points_route 2 -> 3: first route gives 5, second 9. Faster skills for everyone, so the whole tree comes sooner. Trade-off: wins move earlier.

## Sim, 60 seeds with events (win median; no-event win cycle)
| line | now | A | B |
| decent no skills | 25 (23) | 25 (23) | 25 (23) |
| decent logistics | 24 (23) | 24 (23) | 20 (20) |
| decent research | 23 (22) | 23 (22) | 22 (21) |
| decent permit only | 24 (22) | 24 (22) | 24 (22) |
| full tree ref | 21 | 23 | 18 |
| sloppy / always expand / never expand | loss | loss | loss |
| always expand + C1 | 24 (23) win | 24 (23) win | 24 (23) win |

## Flags
- Decent no-skill median is 25 and no-event win is 23, already below the 26-30 window the owner named; the sim is not yet matched to the current build (A1 gate, upgrade_cost 900). Neither option changes it. Real window needs a separate retune.
- "always expand + C1" wins in all three runs (pre-existing dominant-ish line, needs a fix separately).

## Recommendation
Option A. It touches only the permit gate, leaves the decent median untouched and fixes the zero-spare problem. Option B pulls decent logistics to cycle 20, under the early-win floor of 22. Needs owner approval to edit balance.json.
