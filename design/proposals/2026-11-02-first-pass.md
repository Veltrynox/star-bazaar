# Feature proposals, first pass (T142), 2026-11-02

Status: proposals only. Nothing here is approved or built. The owner answers each one (approve, change or drop). Ranked by player value against build cost.

Inputs read: state.md; qa/reports/2026-11-01-summary.json, 2026-11-01-critic.md, 2026-11-01-pacing-retune.md, 2026-11-01-T139-space-sell.md; handoffs gameplay-programmer 2026-11-01-T139 and economy-designer 2026-10-31-skill-tree-r2; gdd.md sections on routes, orders and endings; data/balance.json values. T140 is read from its test names in tools/tests/run_tests.gd (Buy alone sets a standing buy order with no route and no destination), since the T140 brief is not in the repo.

## Ranking

| # | Proposal | Owner agent | Size |
|---|---|---|---|
| 1 | Route row says where its money lands | ui-programmer | S |
| 2 | Idle stock shows its next step (after the buy/send split) | ui-programmer | S |
| 3 | A full lane offers a route upgrade instead of one more ship | gameplay-programmer | M |
| 4 | The Expansion branch changes something before system 3 | gameplay-programmer | M |
| 5 | Stranded rule matches the new economy | gameplay-programmer | S |

---

### 1. Route row says where its money lands

Problem: The route screen shows net income per cycle. A route earns only when its destination has an enabled Sell order (route_engine.gd, outflow at destination). A route with no destination Sell order looks paid and pays nothing.

Idea: One extra line on each route row: "Pays when [planet] has a standing Sell order", with the on or off state. If off, a single control turns on that Sell order, using the existing order toggle.

Player's new choice: Set the destination sell now, or leave the stock in storage for later.

Risk: The planet and route panels are already dense. The line must fit at the macOS window size. Stock drains once a Sell order is on, which may surprise a player who wanted to hold it.

Cost: ui-programmer (S). Story-designer writes the line.

Open: UNKNOWN whether the route row already says this. ui-programmer to confirm before building.

### 2. Idle stock shows its next step (after the buy/send split)

Problem: With T140, a Buy order alone fills storage with no route and no destination (test at run_tests.gd lines 1058 and 1061). Stock can sit with no visible way to earn, and the planet row shows only "storage full" at the top.

Idea: Each storage row shows the units not yet sent or sold, and the one action that would move them: "Send to..." if a route can take them, or "Sell" if a local Sell order is on. Space Storage stock (T139) is counted in the same line.

Player's new choice: Sell here, send on a route, or hold for a better price.

Risk: One more label on each storage row. If the wording is wrong, it reads as a warning when it is only a choice.

Cost: ui-programmer (S). Gameplay-programmer provides the idle count (S). Story-designer writes the labels.

Open: UNKNOWN whether idle stock should ever decay or cap. That is an economy question for economy-designer, not proposed here.

### 3. A full lane offers a route upgrade instead of one more ship

Problem: decent and always_expand play identically (QA: 55 of 55 paired seeds; the lane cap binds both). Past the cap, another ship on the same lane does nothing, so "one more ship" is not a real choice late in the game. The GDD already names "raise a route's level" as later work. balance.json has upgrade_cost (600) and upgrade_margin_bonus (0.25), but no game code reads them, and the route record already has a "level" field.

Idea: When a lane is full, the route offers "Upgrade route" (level 2, a margin bonus) in place of an extra ship. Ships and upgrades then compete for the same cash.

Player's new choice: More ships on a lane, or a better margin on the same lane.

Risk: The margin bonus stacks with B3 and permits, and can shift the pacing that T137 just fixed. Ship price is at 900 and the permit path is near a cliff, so the numbers need a full sweep, not a guess.

Cost: economy-designer sets the numbers (balance.json values stay as they are until then). Gameplay-programmer (M). Ui-programmer adds the button.

Open: UNKNOWN whether the owner wants upgrades as a late-game cash sink or as an early choice.

### 4. The Expansion branch changes something before system 3

Problem: GDD says the Expansion branch has no income effect while systems 2 and 3 are on hold. It is a pure ending-tier branch, so one of the three branches is cosmetic in play. Decent sees no difference from a run that skips it.

Idea: Give one Expansion skill an effect that works in systems 1 and 2 (the planets and routes the player already has). The effect is a type, not a number here. For example: a route-setup effect, or an event-warning effect. C4 already covers permit cost, so it is not reused.

Player's new choice: Expansion against Logistics or Research for the same skill points.

Risk: Overlaps with Logistics. If system 3 is cut (owner question c), the effect must still make sense alone.

Cost: economy-designer sets numbers, story-designer names the skill, gameplay-programmer (M) builds it.

Open: Does the owner want Expansion to matter before system 3 is decided? This is blocked by owner question c in state.md.

### 5. Stranded rule matches the new economy

Problem: gdd.md says the rescue stipend is "equal to one ship". After the pacing retune, balance.json has ship_price 900 and rescue_stipend 1000, so the text and the number drift apart. The stranded check (main.gd, _any_sellable) still reads planet storage only. A player whose only stock is in Space Storage can be stranded even though T139 made Space stock sellable. QA found that counting Space stock made all 20 bot runs lose, so the check is a real design question.

Idea: The owner picks one rule. (a) The stipend equals the ship price, and economy-designer sets the value. (b) The stranded check counts Space stock too, and the bot is retuned to match.

Player's new choice: None directly. This is a fairness and clarity fix.

Risk: Option (b) changes when the safety net fires and may lose more runs than the bot shows.

Cost: economy-designer (S) for the value. Gameplay-programmer (S) for the check. General-purpose or economy-designer updates the GDD line once the owner chooses.

Open: Which rule does the owner choose?

---

## Notes for the owner

- Nothing here changes a number, story text, gdd.md or schedule.json. The producer turns approved items into tasks.
- Proposals 1 and 2 are the cheapest and fit the buy/send split now in progress (T140). Proposal 3 is the largest player-facing gain but needs economy numbers first.
- Open from state.md still applies: system 3 scope (question c), and whether money buys skill points for all spending.
