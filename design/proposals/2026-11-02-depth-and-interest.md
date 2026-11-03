# Depth and interest: proposals (2026-11-02)

Status: proposals only. Nothing approved. No numbers, text or code here.
Builds on, and does not repeat, 2026-11-02-trade-mechanics.md (saturation, contracts, sell floor, backhaul) and 2026-11-02-first-pass.md (route upgrade). Those stay open; where one is the right base it is named.

## Diagnosis
- Prices are static: only events move them (gdd.md Events; route_engine.gd says "There is no saturation rule"). A route is margin x cargo forever, so reading the market has no depth.
- Decent and always_expand play the same (first-pass #3; gdd.md "core decision"). Ships on a lane are a flat multiplier.
- Expansion branch is cosmetic in play (gdd.md economy v5); B3 is display-only. Skills mostly raise numbers, few change what you do.
- Only 3 planets, 2 goods in system 1; system 2 is a copy with better margins. One goal (cash) and one pace.
- Events are rare, pause-and-continue, with little follow-up. Endings differ only by what was learned, not by how the player played.
- Pressure is low: the stranded safety net, no risk on any decision.

## Proposals (ranked)
1. Living prices: saturation plus slow drift (from trade-mechanics #1). Decision: spread flow over destinations, time sales. Touches routes, orders, events, B1/B3 (these become useful). Cost M-L. Risk: breaks T137 pacing; weak cue looks like a bug. Test: bot sweep (decent must still win; always_expand must now differ from decent) and a human check of the cue.
2. Contracts and standing demand (trade-mechanics #2, extended): planets post optional delivery jobs with a deadline; a few recur and build "regular customer" standing at that planet. Decision: divert stock and a ship, or hold the lane. Touches storage, routes, events, notifications. Cost M. Risk: chore or dominant premium. Test: bot with and without contracts; win-cycle spread.
3. Commodity chains: add one refined good (system 1 or 2) made from two raw goods at a planet with a processing order. Decision: sell raw or process it. Touches orders, storage, routes. Cost L (data, engine, UI, story). Risk: UI load, new dead choices. Test: sim that processing beats raw only with a second lane.
4. Route specialisation (from first-pass #3): at a full lane choose one upgrade: speed, margin, or storm-proofing against closures. Decision: which weakness to fix. Touches route level hook, events, skills. Cost M. Risk: stacks with B3 and permits. Test: sweep upgrade orders for a dominant pick.
5. Planet character and rival traders: each planet gets one trait (hungry for X, port fee, quiet) and a rival trader occasionally undercuts one lane until the player moves. Decision: where to commit stock and ships. Touches prices, events, pirates keys already in balance.json. Cost M. Risk: random-feeling losses. Test: seed variance of win cycle.
6. Make Expansion matter in system 1: one skill that changes play (e.g. an extra order slot or event preview with a choice). Decision: Expansion vs Logistics for the same points. Cost S-M. Risk: overlaps B4/C4. Test: branch win-cycle comparison.
7. Run variety: a choice at start (company charter with one bonus and one drawback) and ending text that reads the player's style (lanes, contracts kept). Decision: replay with a different plan. Cost M (story heavy). Risk: balance across charters. Test: bot per charter.

## Recommended first step
Prototype 1 (living prices) with 3 (sell floor from trade-mechanics) as a thin pair: this alone creates every decision the others need and makes existing skills useful. Then 2 (contracts) as the cheapest source of variety. Do not start 3 (chains) before prices move.

## Owner decisions needed
- Is a stricter economy acceptable (saturation can shift the T137 pacing and the win rate)?
- System 3 on hold (open q.c): should depth be added inside systems 1-2 instead?
- Should Expansion matter before system 3? Do contracts replace some events?
- Do rivals/pirates count under "money never buys skill points" for clearing costs?
