# Proposal: pilotable ship, discovery by flying, trading posts, mining platforms (T177)

Author: feature-designer, 2026-11-05. Status: WAITS FOR OWNER. Nothing is approved. No numbers are final: every value marked (E) is set by economy-designer; figures here are starting points and unit ratios only.

Facts used: cycle = 2 min at x1 (`cycle_minutes` 2); speeds x1/2/6/12; pause stops `cycle_elapsed`; the game starts paused. System 1 map units: Voltara (-200,80), Tillam (200,80), Ashgate (0,-220), Cinderrest (-340,-120); distances 240 to 400. Ships are an abstract count (`ships`, `ship_cap` 6); `ships.json` already has `speed` (display only: 1.0 / 0.8 / 1.3 / 1.0). System 2 needs FND_PERMIT plus `permit_2_cost` 600. Dead worlds are locked until cycle 15 (`dead_unlock_cycle`) and need MIN_3. Win: over 50% of one market, cycles 22 to 40.

## 0. Summary
The ship chosen at New Game becomes the **Pathfinder**: one 3D ship on the map that the player flies. It is a scout, not a trader. Every planet except Voltara starts closed (unknown). Flying there and spending time and credits turns it into a **trading post** (living planet) or a **mining platform** (dead planet). Only established planets can be bought from, sold to, routed or stored on. Fleet ships, routes, market share and win rules do not change; only the order in which the map opens does.

## 1. Rules

### 1.1 Flagship: separate from the fleet (recommended)
- The Pathfinder is **not** one of the `ships` count, has no cargo, no route duty, and does not use a `ship_cap` slot. The fleet keeps trading while it flies. Reason: if it were fleet ship 1, every flight stops a lane and the player is punished for exploring; with 1 to 3 ships early, that is the whole income.
- Model and type come from the chosen ship (`ships.json` model). Fleet ships bought later are the same type (rule already: one type per fleet), so the flagship is the "face" of the fleet.
- Upkeep: none (no new drain). Alternative in question Q2.
- It cannot be lost or destroyed. Bad events cost time or credits, never the ship.

### 1.2 Flight: speed and time in cycles
- Flight runs on game time (the `cycle_elapsed` clock). Position = distance covered / speed per cycle. So pause, x2, x6, x12 and the event pause all work with no extra rule.
- Base speed: **400 map units per cycle** (E). Multiplied by the type `speed` (Dart 1.3, Bulk 0.8, others 1.0), so `ships.json` speed stops being display only. Examples at Skerrit speed: Voltara to Tillam 1.0 cycle, to Ashgate 0.85, to Cinderrest 0.6; Tillam to Ashgate 0.7. Bulkhead is 25 pct slower, Dart 23 pct faster. At x1 one cycle is 2 real minutes, so a one-cycle flight is long at x1; the player is expected to use x2 to x6 (that is a feature of the speed buttons, not a problem).
- Order: click a planet, cluster, space storage, a point on the map, or another system's gate. The ship turns and flies a straight line. A new click redirects it mid-flight (no cost). Flights are not routes and need no credits.
- Pause: while paused the ship does not move and no timer on a post runs. The player may still pick a destination while paused; the ship shows a planned line and leaves on resume. Camera and UI stay live (same as today).
- Arrival is checked in the same code path as `_end_cycle` plus per-frame, so headless `advance_cycle` jumps give the same result as real time (needed for bots).
- Points on the map: just move; nothing happens on arrival (free camera target, a look-around). Space storage: fly there to view stock; no gate (the station is built remotely as now). Asteroid field: a visit marks it **surveyed**; mining routes from a cluster need survey plus the existing FND_PROSPECT. Survey costs no credits and no wait.

### 1.3 Trading post (living planets)
- Establish: Pathfinder must be at the planet; player presses "Establish trading post" in the planet panel. It then stays docked for **build time** (E, start point 2 cycles, cannot move; leaving cancels with no refund of time, credits kept until done or refunded in full on cancel: owner Q).
- Cost (E): credits only (never skill points, pillar). Shape: first post free (opening gift, teaches the loop); later posts cost a fraction of `ship_price` (start point 1/3 to 1/2) so a post is a real decision against a new ship; posts in system 2 cost more (about x1.5), being a new market. No per-cycle upkeep.
- One build at a time, because there is one flagship. That is the pacing brake and the choice of order.
- A post unlocks, for that planet: seeing name, type and prices; buy and sell; being an end of a route, order or send; planet storage; workshops built there (the existing cell rule `post` already means "an established cell": reuse it, do not invent a second concept). Space storage does not need a post.
- A post is permanent. Temporary closure events (existing `closed_planets`) stay a separate state and still work on top.

### 1.4 Mining platform (dead worlds)
- Same loop at Cinderrest and Greywake, but button "Establish mining platform". Needs MIN_3 (mine_unlock) learned: before that the button is absent (availability rule), which replaces the fixed cycle-15 gate for the player. Keep `dead_unlock_cycle` only as a floor if the owner wants it (Q6).
- Cost (E): more than a post (start point 2x a post) because it has no trading yield on its own; build time 3 cycles (E).
- Unlocks: mining output, "send to" of mined goods, dross and nullglass buy and sell at that world, routes from it. Nothing else (no workshop, no storage). Existing danger events (`dead_danger`) apply only once the platform exists.
- System 2 dead world needs both the permit and its own platform.

### 1.5 What is known at start
- Open: Voltara (home, free post), the sun and orbit rings. Everything else in system 1 is on the map as a dim, unnamed silhouette (see 1.6). Recommended start: Tillam and Ashgate and Cinderrest closed. The tutorial's first task becomes "fly to the nearby world and establish a post" (first post free, build 1 cycle for the tutorial planet). Cost to the player: about 2 to 3 cycles of early income (E to confirm the win cycle stays 22 to 27). Lean alternative: Tillam also open at start (Q1).
- Goods: the existing availability rule now gains a planet gate (below), so food at Voltara still shows (it is priced there); Voltara is the only place energy and food are priced until Tillam opens. The first lane therefore starts after the first post.
- System 2: its gate is visible once FND_PERMIT is learned; closed before.

### 1.6 Closed planets on the map (availability rule)
- Drawn as a dim sphere at its real position, no label, no route tag, no price icons, no hint arrows. Name text id: a generic "Unknown world" (story-designer) and for dead ones "Unknown dark world"; the name is revealed on arrival (flight completes: name and type known; goods and prices only after the post).
- Planet panel of a closed planet: only a short flavour line, distance and ETA, and the Fly button. No goods list at all (hidden = not drawn).
- New atoms in `game/conditions.gd` and a rule in `data/availability.json`: `planet_visited:<id>`, `post_built:<id>`, `platform_built:<id>`. Per-planet goods list: show a good only if the planet is established AND the good's own rule is true (policy line extended). Any text that names Tillam, Ashgate, Cinderrest, Greywake or their goods before the post must be hidden: the availability text scan (`_test_availability`) must be extended to planet names. This hits tutorial text, event bodies and the Competitors/rival lines.
- Events: planet events and the `good_traded` filter must only choose established planets (the filter already uses open planets; add the post condition).

### 1.7 Other systems and permits
- Permit stays as is (FND_PERMIT, `permit_2_cost`): it opens the **gate** to system 2, not its planets. After the permit the Pathfinder can jump (a fixed 2-cycle hyperlane flight (E), scaled by speed) and each planet there still needs its own post. This keeps the permit worth buying and gives the second system its own exploration chapter.
- Fleet ships cannot route into system 2 until both route ends have a post (same rule as system 1). `system_open:2` stays true when permit is paid; routes also need `post_built`.
- Beachhead discount (E, optional): first post in a new system costs the same as a system 1 post, so the permit is not a double toll.
- System 3 stays on hold (no change).

### 1.8 Events and danger
- **Post events (owner request).** Each post, and each platform, has a chance (E; start point: always for the first three, then about 50 pct) to fire one event at completion. Pool of ~8 to 10 post events, ~4 platform events, written by story-designer, neutral options like the chain steps (no good or bad labels, hidden direction, a market lean allowed). Effects reuse existing kinds (price, cash, stock, closure) and one new kind, "post bonus" (cheaper post, shortened build). New condition atoms `post_built:<id>` let chain steps and rival lines hang on a post (e.g. a rival Ostrel agent already stands at Ashgate).
- **Flight events.** Only on flights over 1 cycle and outside home orbit: small chance per cycle in flight (E, low), pool of 3 to 4 events (drifting wreck, distress call, toll patrol, asteroid dust). Cost only time (delay up to +0.5 cycle) or a small credit sum; never the ship or fleet cargo. The event popup already pauses the game; flight resumes after it.
- Danger rises with distance only through event chance, not a new meter.

### 1.9 Win and market share
- No change to share maths, rivals, chains, endings or the win cycle window. A post adds a place to trade; trade volume still builds share.
- Effect: discovery delays the player by the time to open Tillam and Ashgate, and it delays dead-world mining and system 2. Rival bots follow the paper ramp and do not wait, so the human wins later. Economy-designer must re-baseline `win_earliest_cycle`, `bot_scale` and the early-win window (cycle 22 to 27 target) with the new bot.
- No credits buy share (pillar). Posts cost credits only for access, and no skill points are spent on them (pillar: money never buys skill points).
- Post count could become an ending flavour line ("Pathfinder opened n worlds"), story text only, no share effect.

## 2. QA bots and tests (they must still play)
- New balance key `discovery_enabled` (1 = this feature). With 0 every planet is established at start and the Pathfinder is hidden: this keeps all current tests, shots and bot benchmarks valid and is the first-cut default for regression. With 1 the new rules apply.
- Bot API (gameplay-programmer, in the main scene, headless): `fly_to(target)`, `establish(target)`, `flagship_state()`, plus a fast mode where the ship teleports and a post is built in its normal time via `advance_cycle`. No UI clicks needed.
- New bot opening "explorer" in `qa/bots/bot_run.gd`: cycle 1 fly to Tillam, establish; second flight to Ashgate when cash allows; platform when MIN_3 is learned; permit then jump. Bots with a profile (default, focus mil/lux/min/bio, mining_focus, spread) call it before building routes.
- Tests: `_test_availability` start state changes (only Voltara open): update expected lists, add per-post show and hide, text scan for planet names. Add tests: flight time equals distance / (400 x speed) and pauses; post blocks `route` until built; discovery off equals old behaviour (golden test); save and load mid-flight and mid-build; closed planet draws no label.
- Tutorial: steps that name Tillam or the first route change (story + ui).
- Shots (`qa/bots/*_shot.gd`) that assume open planets run with `discovery_enabled` 0 or a new `--all-open` flag.

## 3. Build plan by agent

| Phase | Agent | Work | Size |
|---|---|---|---|
| P0 | owner | answers questions below | - |
| P1 | economy-designer | speed, post and platform cost/time, event chance, win re-baseline plan; balance keys | M |
| P1 | gameplay-programmer | flagship state, flight on game clock, post/platform state machine, atoms, availability rules, save, route/order/send gates, `discovery_enabled`, bot API | L |
| P1 | story-designer | unknown world names, post and platform texts, tutorial rewrite | M |
| P2 | ui-programmer | click-to-fly on map, closed planet look, post/platform panel, ETA, build bar, tutorial highlight | L |
| P2 | juice-programmer | 3D Pathfinder model, engine trail, arrival, build animation, reveal of planet | M |
| P2 | story-designer | post, platform, flight events (~15 total) | M |
| P3 | gameplay-programmer | events hook (post_built atoms, post bonus effect), system 2 gate and jump | M |
| P3 | economy-designer | re-baseline with explorer bot, pace targets | M |
| P4 | qa-tester | explorer bot, new tests, regression with discovery 0 and 1, text scan | M |
| P4 | doc-manager | GDD section | S |

Order: P1 (rules and data, behind a flag) then P2 (UI and art) then P3 then P4. Each phase ends with `sh tools/tests/run.sh` passing. Big risk and cost: all of P1 and P2 touch `main.gd` (160 KB) and `map.gd`.

## 4. Risks
- Slow first cycles: new player must fly before the first lane. Mitigated by a free first post and a forced tutorial hop; if still slow, Q1 alternative.
- One flagship means long waits at x1; mitigated by x6 and x12 plus short builds.
- Text leaks of planet names (tests need to catch them).
- Bots could exploit a free scout: no, it carries nothing.
- Dominant strategy: always open every planet first. Counter: post cost, one build at a time, and the economy-designer should check that opening all four planets before cycle 8 is not best.

## 5. Questions for the owner
1. Start state: only Voltara open (recommended, first post free, tutorial flies to Tillam), or Voltara and Tillam open?
2. Is the Pathfinder separate from the fleet (recommended, no cargo, no upkeep), or should it be fleet ship 1 so its flights stop a lane?
3. Cancel rule for a post: refund in full if the player leaves, or lose the credits already paid?
4. First post free and system 2 beachhead discount: yes or no?
5. Do flight events and post events have bad outcomes (credit loss, delay) or only neutral choices?
6. Keep `dead_unlock_cycle` 15 as a floor on platforms, or replace it fully by MIN_3 plus a platform?
7. May the player build a post on a closed planet from far away for a higher price (no, recommended: flying is the point)?

## UNKNOWN
- Whether the first 2 to 3 cycles of delay keep the win window at 22 to 27: needs the explorer bot.
- Whether `main.gd` can take the flagship state cleanly or it needs a new `flagship.gd` (gameplay-programmer decides).
- How the 3D camera and `pick_planet` treat the ship as a pick target.
