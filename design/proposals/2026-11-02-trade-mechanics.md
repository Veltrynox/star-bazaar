# Feature proposals: more interesting trade mechanics (T146), 2026-11-02

Status: proposals only. Nothing is approved or built. No numbers, no text, no code here. Does not repeat design/proposals/2026-11-02-first-pass.md (its #3 route upgrade is related to proposal 4 below; see the note there).

Inputs read: state.md; gdd.md routes, orders, events and trade sections; QA T139 report; first-pass proposals.

Shared problem: today a route is a fixed margin times cargo. After the first two routes, the best play is the same every run (QA: decent and always_expand play alike). Prices only move through rare events, so reading the market has no depth.

## Ranking

| # | Proposal | Owner agent | Size |
|---|---|---|---|
| 1 | Saturation: selling pushes the price down, then it recovers | economy-designer, gameplay-programmer | M |
| 2 | Delivery contracts: a one-off order with a deadline and a premium | gameplay-programmer | M |
| 3 | Sell floor: a Sell order waits for a price you set | gameplay-programmer, ui-programmer | S |
| 4 | Backhaul: two opposite routes on one pair share trip cost | gameplay-programmer | M |

---

### 1. Saturation: selling pushes the price down, then it recovers

Problem: A planet pays the same price however much you dump on it, so the best lane is the best lane forever and "one more ship" is a pure multiplier.
Idea: Each unit sold at a planet nudges that commodity's sell price down there. It recovers over the next cycles. Planet panels show the current price and a small "pressure" cue. Heavy flow into one planet earns less per unit than a spread across planets.
Player's new choice: Stack ships on the best lane and accept falling returns, or open a second destination for the same goods. This gives the lane cap a visible reason.
Risk: Can punish the early game and undo the T137 pacing; the first two routes must stay clearly profitable. Needs a full bot sweep. Two ships on one lane could look like a bug if the cue is weak.
Cost: economy-designer sets the pressure and recovery values (S). Gameplay-programmer (M) in the price and route engine. Ui-programmer (S) for the cue.
Open: UNKNOWN whether saturation should also apply to Buy (a buyer-side price rise).

### 2. Delivery contracts: a one-off order with a deadline and a premium

Problem: Every cycle is the same decision. Nothing asks the player to react to a specific demand.
Idea: Now and then a planet posts a contract: deliver a stated amount of one good by a cycle for a premium over the normal sell price. It is optional, uses the existing routes and storage, and appears as a notification with Accept or Skip. Missing it costs nothing but the missed premium.
Player's new choice: Redirect stock and a ship to a contract, or keep the steady lane. The contract competes with the lane for the same stock and ship.
Risk: Must not become a chore or a forced pause. A premium that is too big becomes the dominant strategy. Money never buys skill points still holds; contracts pay cash only.
Cost: gameplay-programmer (M). Economy-designer sets size, premium and frequency (S). Story-designer writes contract lines (S). Ui-programmer adds the notice (S).
Open: UNKNOWN whether contracts should replace some of the current events or sit alongside them.

### 3. Sell floor: a Sell order waits for a price you set

Problem: Idle stock now exists (T140, T139) but there is no reason to hold it, because the price never matters.
Idea: The GDD already reserves "a minimum margin below which the route idles" as a later order field. Add it to the Sell order as a floor. When events or saturation push the price below it, the order waits and the stock stays in storage; above it, it sells.
Player's new choice: Sell now at a poor price, or wait. Holding risks full storage and a stalled route.
Risk: Meaningful only if prices move (best with proposal 1 or events). Alone it is a small feature. A forgotten floor looks like a stuck route, so the route row must say "waiting for price".
Cost: gameplay-programmer (S), ui-programmer (S). No new numbers.
Open: UNKNOWN whether the floor is a per-order setting or one fixed choice (low, normal, high).

### 4. Backhaul: two opposite routes on one pair share trip cost

Problem: Routes are one-way and the return leg is empty. Pairing Voltara to Tillam and Tillam to Voltara is two full separate costs, so a real trade circuit never forms.
Idea: When two routes run in opposite directions on the same planet pair, the return leg of each carries the other's cargo, and the pair shows as one "circuit" with a lower combined trip cost. The reward is a visible loop, not a bigger flat bonus.
Player's new choice: Build a circuit (two goods, both directions) or two unrelated lanes. Rewards using both commodities of a system.
Risk: Changes the "ships on different routes earn the full margin" rule and the tuned economy. May overlap with the first-pass route upgrade. Needs economy sweep.
Cost: economy-designer (S) for the cost split; gameplay-programmer (M); ui-programmer (S) to draw the circuit.
Open: UNKNOWN whether a circuit needs one ship or two.

## Notes for the owner
- Cheapest: 3. Largest gain for the core loop: 1. Best variety against repetition: 2.
- 1 and 3 work well together. Pick 1 first if you only pick one.
