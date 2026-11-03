# Early route stall: "Waiting for room" in cycle 2 (2026-11-02)

## Verdict: the diagnosis is not supported by the numbers
Capacity is not the cause. Balance has no `storage_capacity` or `storage_start` key, so code defaults apply: capacity 100, start 0.
One ship moves `cargo 32 / (2 x travel 1)` = 16 units per cycle (`units_per_cycle`). `ship_cap 24` limits fleet size, not load.
The route cap (16 x ship count) is the only flow limit. The game starts with 1 ship and 900 cash left after a second (`ship_price 900`), so each route has 1 ship.

Destination stock with no sell order (units, end of cycle):

| Cycle | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| 1 ship per route (energy or food) | 16 | 32 | 48 | 64 | 80 | 96 | 100 (full) |
| 2 ships on one lane | 32 | 64 | 96 | 100 | | | |
| 4 ships on one lane | 64 | 100 | | | | | |

Full at cycle 2 needs 4+ ships on one lane. Two routes of different goods never share a bucket (stock is per planet and per good).
Also, in `route_engine.gd` a full destination with no outflow reads "blocked" (red, a notice). It reads "waiting" only if a sell order or onward route exists, and a sell order (40/cycle) outdrains 16 inflow.
So the engine's "waiting for room" state cannot occur in cycle 2.

## Most likely real cause: a label bug in the UI
`game/route_line.gd` `tag_text()` returns `ST_WAITING_ROOM` ("Waiting for room") for every status except running and blocked.
`game/planet_panel.gd` ~745 does the same for "stalled".
The engine also sets "stalled" for: "Source storage is empty", "Not enough cash", "Nothing to move".
A route built in cycle 1 without a Buy order at its source has empty source storage (`storage_start` 0): it is stalled, and shown as "Waiting for room".
The first-cycle notice NOT_ROUTE_STALLED exists, but the tag still says the wrong thing.
The Space Storage skill is not involved (500 capacity, only for dst < 0).

## Keys that matter (and do not)
- `storage_capacity` (default 100): fills at cycle 7 with 1 ship. Raising it only delays a real "full" state. Not the early stall.
- `storage_start` (default 0): the real lever. 0 means a new route has nothing to haul until a Buy order has run once.
- `cargo` 32, `ship_cap` 24, route cap: set the 16 per ship per cycle. Not the cause.
- `order_amount` 40: Buy fills the source in one cycle. Not the cause.

## Fixes
1. **Honest label (code, zero balance cost).** Show the engine reason on the tag: "No stock at source", "Not enough cash", "Full". Pacing: none (sim 23). Dominant risk: none. Fixes the confusion directly.
2. **Auto Buy order at the source when a route is made** (code, design call). Removes the empty-source trap. Pacing: decent unchanged (23). Sloppy and never-expand already lose. Risk: takes away one tutorial decision; the cash is spent from cycle 1.
3. **`storage_start` 0.25** (new key in balance, needs owner approval). Both ends hold 25 units, worth about 250 credits (margin ~10). Sim proxy `--inject=1:300`: decent 22, sloppy 322 loss, always-expand 772 loss, never-expand 4361 loss. At `--inject=1:600` decent wins at 21, below the 22 floor. Risk: touches the whole run and the cash-ending tuning. Not recommended.

## Recommendation
Fix 1 now, with Fix 2 as an optional small step. Keep balance unchanged. Both are Gameplay Programmer and Story Designer work; I change no values.

## Not checked
- The owner's actual save or screen: whether the status was "stalled" with "Source storage is empty" or "Not enough cash". UNKNOWN. `autosave.json` on disk is a fresh game.
- `tools/sim.py` has no storage model: it assumes steady flow, so capacity or start-stock effects are only approximated by cash injection.
- Real buy prices for the owner's chosen planets (margin ~10 assumed).
