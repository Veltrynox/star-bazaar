# False "Not enough cash" on a route (2026-11-02)

## 1. Why it appears and why it misleads
The check is in `route_engine.gd` `_settle_one` (line ~750): `cash < fixed_cost(rec)` gives stalled, reason "Not enough cash.", and the ship does not move that cycle.
`settle()` runs in a fixed order: (1) local Buy orders, (2) routes in list order, (3) local Sell orders. The cash passed to each route is the cash left after all Buys and after earlier routes paid their fixed cost.
Income from Sell orders (step 3) arrives after the check. So with two routes and Buy orders of up to `order_amount` units, cash is lowest exactly when route 2 is tested, and money comes back a moment later in the same cycle.
Duration: one cycle, then the next cycle starts with the sales in hand. The tag and planet panel show the stored reason until the next settle, so the player reads "Not enough cash" while the cash is already fine.
The stall is real (that ship did not move, so one trip of income is lost), but the message is wrong: the player is not broke, the order of steps starved the route. The fixed cost is only trip + upkeep, small next to Buys.

## 2. Options
| | A. Reserve the fixed cost | B. Warn after N cycles in a row | C. "Low cash" soft state |
|---|---|---|---|
| Rule | Buys may not spend the fixed cost of routes that will move this cycle | A stall shows a warning only on the 2nd cycle in a row | Neutral tag when cash is under the forecast cost |
| Player decision | None new; routes first, Buys second | None new; reads a calmer screen | Sees a hint, can cut a Buy |
| Cost | M (gameplay-programmer; changes step 1) | S-M (counter on route, saved; ui-programmer tag) | S (ui-programmer) |
| Pacing | Small: Buys shrink a little in tight cycles; route income kept. Sim needed | None; engine unchanged | None |
| Dominant risk | None seen; removes a trap | Hides one real lost trip; a stuck route warns one cycle later | Another label to learn |
| Fixes the cause | Yes | No, only the display | No |

Reserve-at-build (taking the cost when the route is built) is rejected: it locks cash for a whole run and is a hidden cost.

## 3. One rule for all warnings
Apply B to every "not moving" state: Not enough cash, No stock at source, Waiting for room. Each is a state where the next cycle may fix itself.
- Cash and Waiting: recover alone, so the delay is right.
- No stock at source: recovers only if a Buy order exists. Delaying its tag by one cycle is fine, but the first-cycle notice (NOT_ROUTE_STALLED) should keep firing, since it teaches the Buy order.
- Blocked (closed planet, full with no outflow) stays instant and red: it will not recover alone.

## 4. Recommendation: A plus B
Rule in plain words: "Buys never spend the trip and upkeep money of a route that will run this cycle. A route shows a warning only after 2 cycles in a row of not moving; the first cycle shows its normal neutral line. Blocked routes warn at once."
A removes the cause for the common case. B catches what remains (real cash shortage, cleared source) without flicker.
Text names (story-designer writes final): existing LBL_NO_STOCK_SOURCE, ST_WAITING_ROOM, the cash reason as a new key such as LBL_NO_CASH; no new text for the neutral first cycle (the tag shows the normal "ships + net" line).
Pacing: expected neutral, since the fixed cost is small and the ship moves more often. Decent baseline 22-26 must be re-run (economy-designer, tools/sim.py).

## 5. Not checked
- UNKNOWN: whether the owner's case was Buy-driven (my reading) or true low cash after a ship purchase; no save was read.
- `tools/sim.py` has no step-order model, so pacing effect of A is a guess until run.
- Where `main.gd` shows the stored reason; I read `route_line.gd` `reason_text` only.
- UNKNOWN: whether route list order matters to the player (A removes the order effect on cash).
