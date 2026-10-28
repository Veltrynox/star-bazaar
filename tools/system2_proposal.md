# System 2 proposal (economy designer, 2026-10-27). Roles only; story-designer names the planets.
Machine-readable copy: tools/system2.json (used by tools/sim.py). NOT written to data/planets.json: that file has no system field and the game assumes 3 planets.

Prices are the player's: *_buy = player pays, *_sell = player receives (same as planets.json). The permit's +50% margin is baked into the sell prices (margins 22 to 25 vs 14 to 17 in system 1); permit_margin_bonus is therefore not applied again.

| Planet | Role | food buy/sell | energy buy/sell |
|---|---|---|---|
| S2-P1 | food-rich hub | 11 / 9 | 32 / 31 |
| S2-P2 | energy-rich | 33 / 33 | 9 / 8 |
| S2-P3 | food-rich outpost | 12 / 10 | 34 / 33 |
| S2-P4 | consumer market, buys both, produces nothing | 35 / 34 | 35 / 34 |

Profitable one-way routes (7): food P1>P2, P1>P4, P3>P2, P3>P4; energy P2>P1, P2>P3, P2>P4.
Pools (order_amount 40 per planet and commodity): energy out of P2 40; food out of P1 and P3 80; sinks energy P1/P3/P4 120, food P2/P4 80. Natural limit 9 ships (marginal net 285, 285, 253, 253, 221, 221, 85, 69, 53, then 0), steady income about 1725/cycle.
Travel: travel_cycles_per_leg and trip_cost are global (1 cycle, 95), so no per-route distances; x,y are for the map only.
Permit: permit_2_cost 1000 credits, permit_points_2 3, needs skill C1 (1 point). Entry gives 3 system points + 4 planets + pairs.
