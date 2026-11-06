# Star Bazaar: mechanics review, strongest to weakest (2026-11-06)

Author: feature-designer. Analysis only. Nothing here is approved; every improvement waits for the owner. No numbers are invented; tuning questions are marked "needs economy-designer".

Scores: C = meaningful choice, L = loop fit, F = clarity and feedback, D = depth over time, X = distinctness. Each 1-5. Ties are broken by loop fit, then choice.
Sources: gdd.md, gdd-skills.md, game/*.gd, data/*.json (balance.json 579 keys, skills.json 68 nodes, 21 goods, 25 events, 10 planets in 2 systems).

## 1. Ranking table

| # | Mechanic | C | L | F | D | X | Total | Verdict |
|---|---|---|---|---|---|---|---|---|
| 1 | Market share and win condition | 5 | 5 | 4 | 4 | 5 | 23 | The spine of the game; rivals do not answer back |
| 2 | Routes and automated ships | 4 | 5 | 4 | 3 | 4 | 20 | The heart of the loop; few levers after the first routes |
| 3 | Skills and skill tree | 5 | 4 | 3 | 4 | 4 | 20 | Best long-term choice; tree is 2x what the GDD says |
| 4 | Events and event chains | 4 | 4 | 2 | 4 | 5 | 19 | Distinct and deep; the hidden lean is unreadable |
| 5 | Pathfinder exploration and discovery | 3 | 4 | 4 | 2 | 5 | 18 | Great early hook; auto-explore ends the choice |
| 6 | Workshops and fabric | 4 | 4 | 3 | 3 | 4 | 18 | Real second layer; unproven for share |
| 7 | Core trading (buy, send, sell, spread) | 3 | 5 | 4 | 2 | 3 | 17 | Clear, but prices are static and nothing saturates |
| 8 | Dead worlds | 4 | 3 | 3 | 3 | 4 | 17 | Only real risk/reward gamble; narrow in scope |
| 9 | Rivals and rival ships | 2 | 5 | 3 | 3 | 3 | 16 | Fair opponents on a schedule; no player interaction |
| 10 | Cycle timer and pacing | 3 | 4 | 4 | 2 | 3 | 16 | Pause is good; the stretches between choices are long |
| 11 | Mining and asteroid fields | 3 | 3 | 3 | 3 | 4 | 16 | Finite supply is a good idea; one good, few decisions |
| 12 | Goods availability (progressive disclosure) | 1 | 3 | 5 | 3 | 4 | 16 | Excellent teaching tool; not a choice by design |
| 13 | Permits and systems / lanes | 3 | 4 | 3 | 2 | 3 | 15 | One purchase; 8 of 10 systems are placeholders |
| 14 | Endings | 2 | 4 | 2 | 2 | 4 | 14 | Hidden lean means the player cannot aim at an ending |
| 15 | Storage and Space Storage / Link | 3 | 3 | 3 | 2 | 3 | 14 | Needed plumbing; the Link is unplayed |
| 16 | Loss conditions | 2 | 3 | 4 | 2 | 3 | 14 | Fair and gentle; almost never felt |
| 17 | CEO choice | 3 | 2 | 3 | 2 | 4 | 14 | Real fork at start; too small to matter later |
| 18 | Tutorial / first hour | 2 | 3 | 4 | 1 | 3 | 13 | Guided, ends by cycle 4; the first hour is then unguided |
| 19 | Trading posts / stations | 2 | 3 | 4 | 1 | 2 | 12 | A toll on exploration, not a decision |
| 20 | Ship types and upkeep | 2 | 3 | 3 | 1 | 2 | 11 | Picked once via the CEO, then invisible |

Not ranked (not built): Gigs (story/gigs.md only, no code), pirates (route_engine has a `pirates_active` flag that nothing sets; the Null Core "immunity" protects against nothing today).

---

## 2. Mechanics in rank order

### 1. Market share and win condition (23)
What it is: share = the player's sales of a market's goods over a rolling window (8 cycles, longer per skill) against three rival volume curves. Win at over 50% held 5 cycles (from cycle 23) or at cycle 40; a market's win waits for its chain or cycle 38.
Why here: every system in the game feeds it, and it forces focus (the overhead rises with the square of active markets). Sales-only counting makes the number honest and readable on the share graph.
What holds it back: the rivals' volumes are a fixed curve plus noise; they only react through a "gap" bonus when the player is absent (below 10% share). Once the player sees the curves, the optimal plan is known. The player also cannot see how far a sale pushes the share.
Improvements:
- A. "Share forecast" on the share panel: what next cycle's sales would do to the share. Choice: balance output across routes to reach a threshold. Risk: shows a solved path too early. Cost: ui-programmer + gameplay-programmer, S. Question: show it from the start or after a skill?
- B. Rivals counter-push in the market the player leads (bots gain growth when the player passes a share line). Choice: defend or move on. Risk: feels unfair; needs numbers. Cost: gameplay-programmer M, needs economy-designer. Question: should rivals ever "fight back" visibly?
- C. A rival-named share-loss message ("Harrow took 4 points of Minerals") each cycle. Cost: story-designer + ui-programmer, S.

### 2. Routes and automated ships (20)
What it is: Send orders move stock between storages with a free ship; several ships per lane, level 2 upgrade, route bending that raises upkeep, mixed-load trip cost, same-market bundle bonus, salvage at a loss.
Why here: it is the place where the "company, not trader" pillar becomes play. States (running/stalled/waiting/blocked) explain themselves.
What holds it back: after the first good lane, the choices are "add ship" or "upgrade once". Level 2 is the only level. Route offset and mixed load are penalty rules the player rarely steers.
Improvements:
- A. More route levels or a branch at level 2 (speed vs capacity). Choice: shape each lane. Risk: more UI per route. Cost: gameplay-programmer M, numbers by economy-designer.
- B. Route priority when two lanes share a source. Choice: who gets the stock first. Cost: gameplay-programmer S-M.
- C. A "why this lane earns" breakdown (margin, trip, upkeep, bundle) in the route panel. Cost: ui-programmer S.

### 3. Skills and skill tree (20)
What it is: points from visits, first routes, systems and share milestones (never credits). Three Foundations gate four market trees; the branch of the CEO hides the others. Tech nodes unlock by crafting. skills.json now holds 68 nodes (tiers 8-15 per market plus FND_LEDGER, FND_RIVAL_WATCH, FND_DOCKS); gdd-skills.md still says 33.
Why here: the best decision spend in the game: the points are finite and they carry the pillar "money never buys skill points". Tech-by-crafting ties the tree to workshops.
What holds it back: the player can see only the branch tree, so there is no choice between trees; many nodes are single-number tweaks ("upkeep lower", "price up"), which the 2026-11-05 rule meant to remove. Blackboard lists MIL_1, LUX_3, BIO_3 and BIO_6 as mismatches with their texts.
Improvements:
- A. Replace pure-percent nodes with unlocks (a rule change, not a number). Choice: a different way to play, not a bigger number. Cost: gameplay-programmer M plus story-designer S. Question: which nodes first?
- B. Let a second tree be bought at a clear price in points (the spreading penalty already limits it). Cost: S for gameplay-programmer. Question: does the owner want multi-market play?
- C. Show "points earned this cycle and from what" in the top bar. Cost: ui-programmer S.

### 4. Events and event chains (19)
What it is: a 7-step chain per market (two neutral choices each, each hits a rival), a shared pool, branch events EV52-55 (dark or public sale), debris and asteroid events. A hidden lean picks GOOD or BAD ending.
Why here: the only system that tells a story and asks a values question; no other system offers this.
What holds it back: the hidden lean cannot be read or aimed at, so choices feel arbitrary after the first one. The branch events rarely fire (blackboard T234: cycles 5 and 9 in a pool of ~36). Pure price events are minor icons that fade.
Improvements:
- A. Give the player one clear signal of the lean at the end of a chain (an epilogue line only, never a number). Choice: commit to a flavour. Risk: breaks the "never shown" rule. Cost: story-designer S. Question for owner: relax the rule?
- B. Force EV52-55 into a fixed cycle window. Cost: gameplay-programmer S.
- C. Finish the TH01-TH10 thread (T243) so chains have variety. Cost: gameplay-programmer M.

### 5. Pathfinder exploration and discovery (18)
What it is: one scout ship; only the home world starts open; flying to a planet reveals it, then a trading post or platform is built. Exploration mode flies and builds by itself. A jump changes system.
Why here: a distinct, readable early hook that gives pacing to the first 15 cycles and feeds skill points (first visits).
What holds it back: once every planet is open, it is done; exploration mode removes the one decision (order). Ten planets only.
Improvements:
- A. Survey results with a cost: scouting shows a planet's role before the post is built, so the player picks which to build first. Choice: invest where it matters. Cost: gameplay-programmer S; story-designer for text.
- B. Gigs (story/gigs.md) as signals in the scout's system, the long-awaited second use. Cost: gameplay-programmer M. Owner has 3 open questions.
- C. Scouting later systems (placeholder 3-10) once designed. Cost: L, depends on level design.

### 6. Workshops and fabric (18)
What it is: five workshops, one per market (plus Smelter/Fabric in Minerals), built once, craft batches from Space Storage stock; tech nodes complete from crafted units; Fabric makes lattice plate and the Null Core.
Why here: adds a production layer: choose which goods to feed and where. Stalled messages say what is missing.
What holds it back: gdd-skills.md itself lists as UNKNOWN whether workshops matter enough for share. One workshop per type means no scaling decision; the Null Core is one per run.
Improvements:
- A. Let a workshop be upgraded or duplicated in a second system. Choice: scale vs stay focused. Cost: M, needs economy-designer.
- B. Show output value vs raw-sale value per batch. Cost: ui-programmer S.
- C. Share credit for crafted goods sold (check it is true). Cost: S to verify.

### 7. Core trading: buy, send, sell, price spread (17)
What it is: each planet has fixed buy and sell prices; Buy and Sell are toggles with an order size; margin = sell minus buy. Prices move only by events and skill price bonuses.
Why here: very clear and tied to everything else.
What holds it back: code states "There is no saturation rule: storage fill is the only pressure" (route_engine.gd line 21). Prices come from base_prices. So the best lane is the best forever; the pillar "profitable but never trivial" rests on events and caps only.
Improvements:
- A. Price pressure: selling a lot lowers the local price for some cycles. Choice: spread the same good across planets. Risk: complexity; could break the share rule. Cost: gameplay-programmer M, needs economy-designer. Question: does the owner want price impact?
- B. Slow price drift (seeded) so margins move between visits. Cost: S-M, economy-designer.
- C. Show last-cycle realised margin per planet. Cost: ui-programmer S.

### 8. Dead worlds (17)
What it is: Cinderrest (dross, system 1) and Greywake (nullglass, system 2), unlocked from cycle 15 plus a skill; a danger meter rises per mined cycle and delayed events cut or boost income or lose cargo.
Why here: the only gamble where the player can choose risk; a good bridge into the Fabric.
What holds it back: two worlds, a fixed meter, one outcome set; no way to manage the danger.
Improvements:
- A. Let the player pay to lower the danger meter or pause mining. Choice: push or rest. Cost: gameplay-programmer S, economy-designer for price.
- B. Show the meter and next event odds on the route. Cost: ui-programmer S.
- C. A third dead world later in a new system (depends on content). Cost: L.

### 9. Rivals and rival ships (16)
What it is: three bots as numbers (strength, growth, tiers, noise, gap bonus); one scenery ship each; Competitors menu with graphs; events and skills cut them.
Why here: gives the win its meaning and pressure.
What holds it back: they never act on the map, never buy a planet, never block a route. The ships are decoration only (gdd says so). Embargo Desk / Guild Seal let the player pick a rival, but only as a number cut.
Improvements:
- A. Make rival moves visible as news ("Velvet opened a Luxury lane to Tillam") tied to the real tier jumps. Cost: story-designer S + gameplay-programmer S.
- B. A rival may contest a planet's price (lower sell price for a while). Cost: M, economy-designer.
- C. Rival ship arriving at a planet triggers a small event. Cost: juice-programmer / gameplay-programmer S.

### 10. Cycle timer and pacing (16)
What it is: a cycle runs on a timer (balance cycle_minutes = 1 here, code default 2); the player can pause at any time; 40 cycles; the game starts paused.
Why here: pause-and-plan is friendly; the "nothing earns while paused" rule is honest.
What holds it back: between investments the player waits. No speed control beyond pause; the middle cycles (about 15-30) have few decisions (blackboard shows many tasks waiting).
Improvements:
- A. 2x speed toggle. Choice: when to wait. Cost: gameplay-programmer S.
- B. "Next decision in N cycles" hint (next affordable item, next unlock). Cost: ui-programmer S.
- C. A mid-game beat (a new system or goal) at cycles 15-25. Cost: depends on systems 3+.

### 11. Mining and asteroid fields (16)
What it is: Prospecting lets a route start at a cluster; ore is free at the cluster; clusters hold a finite amount, never refill; the asteroid event leaves a small new cluster.
Why here: finite supply gives a real planning horizon.
What holds it back: one good (ore); nothing to decide beyond "which cluster first"; the refill and survey keys exist in balance (ore_refill_units, ore_survey_fee) but the GDD says clusters never refill.
Improvements:
- A. Show remaining stock and the time left at the current yield. Cost: ui-programmer S.
- B. Choose yield vs lifetime per cluster (fast and short, or slow and long). Cost: gameplay-programmer S-M, economy-designer.
- C. Merge with dead worlds into one "Raw sources" system (see closing).

### 12. Goods availability / progressive disclosure (16)
What it is: availability.json rules show a good only when it can be used; hidden means not drawn; a test scans the text.
Why here: the best clarity tool in the game; it keeps the first minutes simple and rewards learning skills with visible new goods.
What holds it back: it is a layer, not a decision (C = 1) and it does not deepen play after all goods are shown.
Improvements:
- A. A "new" marker on a good in its first cycle visible. Cost: ui-programmer S.
- B. Add a log of unlocks. Cost: S.
- C. None needed beyond content; keep it.

### 13. Permits and systems / lanes (15)
What it is: Permit Charter plus points and credits buys system 2; lanes between systems run through Space Storage. Systems 3-10 do not exist (hidden placeholders ids 3-5, off).
Why here: a clear mid-game goal and an expansion cost.
What holds it back: one purchase; after it the content is the same. The GDD plans ten systems but only two exist.
Improvements:
- A. Make system 2 trade differently (a different role mix) so lanes between systems matter. Cost: economy-designer M (data).
- B. Permit with terms (cheap and short vs dear and permanent). Cost: gameplay-programmer S.
- C. Design system 3 before adding more mechanics. Cost: L, owner decision.

### 14. Endings (14)
What it is: one ending by market won and the hidden lean: 8 win endings, bankrupt, swept, outcompeted; epilogue lines for capstone, techs, rival that lost ground.
Why here: gives the game a close and a reason to replay.
What holds it back: the player cannot tell why they got GOOD or BAD; the market held (which the CEO largely fixes) picks half of it.
Improvements:
- A. After the ending, a short "what you did" recap naming the three chain choices that decided it. Cost: story-designer S + ui-programmer S. Question: relax "never shows the lean"?
- B. Let a late chain step reverse the lean once (a real late choice). Cost: gameplay-programmer S.
- C. Add a second-market ending nod (partly exists). Cost: story-designer S.

### 15. Storage and Space Storage / Storage Link (14)
What it is: planet storage per good; one Space Storage per system (earned by trade income and a skill); transfer into it slowly; Sell orders and routes can draw on it; Storage Link joins two systems by goods only with energy upkeep, may collapse.
Why here: it gives routes a buffer and the Link is a real cross-system tool.
What holds it back: mostly plumbing; the Link is built but not yet played (gdd-skills.md); storage is never a route source (blackboard T188).
Improvements:
- A. Allow storage as a route source (decide first). Cost: gameplay-programmer S-M.
- B. Show fill and drain trend per storage. Cost: ui-programmer S.
- C. Fold Link into the permit flow so it is found, not hunted. Cost: S.

### 16. Loss conditions (14)
What it is: bankrupt (after repossession, stipends gone) and swept (under a low line in all markets); checked after win; stipend rescue up to a few times.
Why here: gentle, fair and readable; failure is never sudden.
What holds it back: the rescue stipend makes bankruptcy rare, and swept needs 25+ cycles; neither teaches a lesson mid-run.
Improvements:
- A. Early warning panel for swept ("share under the line in 3 of 4 markets"). Cost: ui-programmer S.
- B. A mid-run loss softener: sell a ship back. Cost: S.
- C. Tie rescue to a story beat. Cost: story-designer S.

### 17. CEO choice (14)
What it is: four CEOs, each with a branch (market), a ship type, three stats and a perk; chosen on the New company screen.
Why here: a real start fork and a way to replay.
What holds it back: it fixes the market and the ship type, so it removes choices later; stats are small cash tweaks; the branch hides other trees.
Improvements:
- A. Let the player pick the market first and the CEO second (decouple). Cost: gameplay-programmer S, owner question: do CEOs stay tied to markets?
- B. Show what the CEO changes in the end recap. Cost: S.
- C. Add one trait that matters mid-game, not only at the start. Cost: M, economy-designer.

### 18. Tutorial / first hour (13)
What it is: a guided card, shown cycles 1-4, with Skip and Next; Availability hides most goods; game starts paused.
Why here: clear, short and skippable.
What holds it back: it covers the first steps only; the first hour (cycles ~5-30) has no guidance for skills, Space Storage, permits or workshops except by notices.
Improvements:
- A. Contextual hints at first unlock (first skill point, first Space Storage, first workshop). Cost: story-designer S + ui-programmer S.
- B. A "next goal" line in the top bar. Cost: ui-programmer S.
- C. A short replay entry in the game menu (menu has locked Help). Cost: S.

### 19. Trading posts / stations (12)
What it is: after a scout visit, a post (living world) or platform (dead world) is built for a fee; the first is free; cost scales with ship price and system. Only established planets can trade.
Why here: it is clear, but it is a fee with a wait, not a choice. Every planet is eventually built.
What holds it back: no choice of what to build, no upgrade, no upkeep; exploration mode pays it for the player.
Improvements:
- A. Let posts differ (what they specialise in, one slot of two options). Cost: M.
- B. Merge into Pathfinder exploration (see closing).
- C. Add upkeep or a local benefit. Cost: economy-designer M.

### 20. Ship types and upkeep (11)
What it is: four types (Skerrit, Bulkhead, Dart, Tramp) differing by multipliers; fixed by the CEO for the run; ship cap with type bonus; maintenance every few cycles; Null Core as a one-off fit.
Why here (weakest): there is no choice at all after the CEO, no buy of different ships, no mixing. Speed matters only for the scout. Upkeep is a number the player cannot act on, apart from skills.
Improvements:
- A. Allow a second type in the fleet (buy a Dart for a short lane). Choice: fit the ship to the lane. Cost: gameplay-programmer M, economy-designer for numbers. Question: does the owner want mixed fleets?
- B. Let the player sell or retire ships. Cost: S.
- C. Show upkeep per ship and per lane. Cost: ui-programmer S.

---

## 3. Closing

### Best value for cost (top 3)
1. Price pressure or slow drift in core trading (7A/7B). One rule makes route choice a live decision from cycle 1 to the end. Fixes the largest gap against the pillar "never trivial". Cost: M, needs economy-designer.
2. Make rival moves visible and let them push back where the player leads (1B + 9A). Cost: M. It turns the win from a graph into a contest, and uses systems already built.
3. A "what is happening and why" layer: share forecast, route breakdown, next-decision hint (1A, 2C, 10B). Cost: S each, ui-programmer. Clarity gain for the cost of three small panels.

Runners-up: contextual hints at first unlock (18A), second ship type per fleet (20A), gigs via the Pathfinder (5B).

### Cut or merge
- Merge trading posts into Pathfinder exploration. Treat "survey, build" as one step; keep the fee, drop the separate mechanic and the second text set.
- Merge mining and dead worlds into one "Raw sources" mechanic (one meter, one yield choice, one panel); both are finite sources that feed the Fabric.
- Retire the old skill keys and shield keys left in balance.json (`shield_*`, unused tiers) once the owner confirms the 68-node tree; the GDD says the shield is retired.
- Do not build pirates until the owner decides: the Null Core currently protects against a rule that does not exist.

### Code versus GDD mismatches
- Skills: data/skills.json has 68 nodes (tiers 8-15 per market, FND_LEDGER, FND_RIVAL_WATCH, FND_DOCKS); gdd-skills.md says 33 and "three Foundations".
- Pirates: gdd.md refers to "section 7 for pirates"; gdd.md has no section 7, and route_engine.gd says there is no pirate system (`pirates_active` never set).
- Saturation: the GDD does not promise it, but the debug menu and route_engine say there is none; the pillar "never trivial" depends on it.
- Clusters: gdd says clusters never refill; balance.json has `ore_refill_units` and `ore_survey_fee`.
- Ship cap: blackboard says 20 (T186); balance ship_cap is 10 plus type bonus.
- Cycle length: balance cycle_minutes 1; code fallback 2 (`_cycle_seconds`).
- Systems: gdd.md says ten are planned; two exist (5 planets each); placeholders 3-5 are off.
- Gigs: designed and texted (story/gigs.md) but no code.
- Shield: marked "Retired" in gdd.md; `shield_*` keys remain in balance.json.
