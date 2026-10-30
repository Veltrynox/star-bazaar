Game Design Document - Fourth Draft
Date: 21 October 2026

GIT: https://github.com/Veltrynox/star-bazaar/blob/main/gdd.md

SECTION INDEX
Each section starts with a banner line of "=" signs, then its heading. Find a section by grepping its heading (for example: grep -n "^2\. GAME MECHANICS" gdd.md). Line numbers are not listed because they change with every edit.
  1. EXECUTIVE SUMMARY / GAME SPECIFICITY: one-liner, name, engine, platform, core loop, win and loss conditions
  2. GAME MECHANICS / PLAYER EXPERIENCE: credit inflow and outflow, mechanics, first 4 cycles, automated routes (core), balance targets, events, menu UI (debug menu, force-goal), planned upgrades, story and tone, the win choice and endings, economy v5 (expansion points, event rules, sim table)
The skill tree, space storage and game menu are in gdd-skills.md (draft 1).
Agent workflow, constraints and engine integration (old sections 3 to 5) are in gdd-process.md. The dated change log is in gdd-log.md. Agents do not read either unless their brief says so. Add new change-log lines to gdd-log.md, not here.
Numbers are not in this GDD. They are [GCM:<key>] tokens that point to data/balance.json.

========================================
1. EXECUTIVE SUMMARY / GAME SPECIFICITY
========================================

Oneliner: Star Bazaar is a single-player space trading game

Name: Star Bazaar
Genre: Space trading game
Engine: Godot 4 (GDScript)
Platforms: macOS

Core loop: The player runs a trading company, not a freighter. Each cycle: read the route income, pick the next investment (a new route, one more ship on a route, a permit), and let the routes earn. Routes are automated from the first minute; the game works out whether the player can afford one, and every route pays out net of its own trip cost and maintenance. Cash grows, the player reinvests, and the own-planet fantasy gets closer.

Win: the first time the cash balance is at least [GCM:win_cash] credits at the end of any cycle, the game pauses and the player makes the final choice (Release or Stay as a corporation, see "The win choice and endings" in section 2). The run then ends with one ending.

Loss: if the cash balance is still below [GCM:win_cash] credits at the end of cycle [GCM:win_cycle], the game ends and the end screen shows the cash reached and the target.
========================================
2. GAME MECHANICS / PLAYER EXPERIENCE
========================================
Source of truth: The numbers in this GDD are a starting point only. Once production starts, data/balance.json is the single source of truth for every balance value, and the Game Control menu reads and writes that file. Where this GDD and balance.json disagree, balance.json wins. [GCM:<key>] tokens in this GDD point to the balance.json key with the same name. This GDD is not updated with new numbers after production starts; the Economy Designer changes balance.json.

The numbers come from a rough paper model built on the GDD’s fixed facts: [GCM:win_cycle] cycles of about [GCM:cycle_minutes] minutes each. They’re meant to give a working first pass for tuning in the debug menu, not final balance.

The game takes about [GCM:win_cycle] × [GCM:cycle_minutes] minutes to complete. In game cycle lasts around [GCM:cycle_minutes] minutes. There are [GCM:win_cycle] cycles.
The player can pause the game at any time.
While paused the player can look, plan, buy ships, set up, change or close routes, and buy permits. Nothing earns while paused: routes pay only when a cycle ends, so pausing gives no advantage beyond thinking time. (This replaces the old one-leg-per-pause rule, which existed for manual trading.)

Credits Inflow:
Routes - net income, paid at the end of every cycle
Events

Credits Outflow:
Trip cost and ship maintenance - never paid from the player's cash directly. They are subtracted inside each route before it pays out (see Automated routes), so the route income shown is always net. The base amounts are [GCM:trip_cost]cr per leg (fuel and crew combined, to keep fewer variables) and [GCM:maintenance] per ship every [GCM:maintenance_interval] cycles.
Ships - [GCM:ship_price], bought by the player.
Permits - One time purchase to open a new solar system.
Events

Mechanics:
Routes - The core. Set up a planet pair, put ships on it, collect net income.
Permits - Solar systems access
Events - To bring some randomness and fun to the game.

Manual trading (ruling): removed from regular play. The player never buys and sells cargo by hand. Reason: the owner's vision is a company manager, and a hand-run trade loop is the micro-management that routes replace; keeping it as a side action would make the optimal play a chore. The planet panel still shows each commodity's buy and sell price, because that is what the player reads to choose a route. The tutorial no longer has a manual trade; its trade lesson is the route preview (see First 4 cycles). The existing trade code (game/trade.gd) is reused as the route engine, not as a player action.

Top bar:
Goal line: "Goal: [GCM:win_cash] by cycle [GCM:win_cycle]. Now: [cash balance]."

The game is mostly event and text driven, for now.

First 4 cycles of the game:
The player reads the preface story. The game starts. We sees 3 Planets, a notification board on the right side with a mission hint.
"Set up your first route" mission text. The UI on top with some information: [GCM:starting_credits] starting credits. The planet highlights, the player clicks on it, a menu pops up. This planet has an abundance of energy but not enough food. The player clicks another planet and sees it has an abundance of food but low energy supply. The planet panels show the buy and sell prices, so the player can see the margin: energy is cheap here ([GCM:energy_buy] per unit) and sells for [GCM:energy_sell]cr there; food is cheap there ([GCM:food_buy]cr) and sells for [GCM:food_sell]cr here.
The mission board explains that a route is a ship that flies between two planets by itself. The player opens the route screen, picks the two planets and sees the preview: net income per cycle, with the trip cost and maintenance already taken out. The game says whether the route can be set up now; if not, it says why (not enough cash for the ship, ship cap reached, planet closed). The player confirms, the ship is bought and assigned in one step, and the first route is running. Mission complete. From then on the player only decides; the ship does the flying and trading.

How a route earns (formulas; numbers are in balance.json): the margin is the sell price minus the buy price. With [GCM:cargo] units of cargo, one loaded leg earns margin × cargo, so a round trip with cargo both ways earns 2 × margin × cargo. A round trip takes 2 × [GCM:travel_cycles_per_leg] cycles, costs 2 × [GCM:trip_cost] in trip cost, and carries maintenance of [GCM:maintenance] per ship every [GCM:maintenance_interval] cycles. What is left is the route's net income, spread as a per-cycle figure. The route pays that net figure at the end of every cycle; the player never sees the gross numbers unless they open the breakdown.

After several cycles we have enough money for a second ship. The player chooses whether it joins the existing route or opens a new one. Too many ships on one route saturate it (their sell price falls), too few leave cash flow low; this choice is the core decision of the game. There is a cap of possible ships which is [GCM:ship_cap] ships max.

Automated routes:
DOC NOTE (2026-10-27): this part still describes the round-trip route model of 2026-10-26. The current flow is standing local Buy and Sell orders on a planet row plus optional one-way "Send to..." routes between company storages (story/game-flow.md wins over this section where they differ; see state.md). Not rewritten here; the owner decides when it is.
A route is one pair of planets (A and B, direction does not matter) that its ships fly back and forth, buying and selling on each leg, with no player input. Routes have no per-system limit; the only limit is [GCM:ship_cap] ships in total. Adding a ship to a pair that already has a route puts it on that route. Both planets must be open (permit held, not closed by an event).
Setting up: the game, not the player, checks whether a route can be set up. It needs a ship (a free one, or enough cash to buy one in the same step, at [GCM:ship_price]), room under the ship cap, and two open planets that trade with each other. There is no separate setup fee and no cash buffer for trip cost, because trip cost is never paid from cash (see below). The route screen shows the verdict and, when it is "no", the one reason.
Net income, fool-proofing: each route pays at the end of every cycle, and what it pays is already net of its trip cost and its maintenance. The player cannot run out of money mid-trip and cannot be charged for a leg they cannot afford. A route never charges: if its net income would be zero or less (an event, a price drop), the route idles, pays nothing, costs nothing and shows "not profitable". Setup of a route whose net would be zero or less is refused with that reason. A ship that is not on any route costs nothing. The only cash the player ever spends is on purchases they choose (ships, permits, upgrades), and each is checked against cash before it happens.
Every ship earns on its own: each ship flies its own legs, carries its own [GCM:cargo] units and pays its own trip cost and maintenance (inside the route). Ships add income; they do not add capacity to another ship. Ships on different routes earn the full margin.
Route level (hook, no numbers): every route has a level, and all routes start at the base level, which is fully automatic with no player input. A later upgrade raises a route's level and gives it more automation. What a level does is not defined in this build. The only requirement now is structural: a route is one record (planet pair, ship count, level, orders) and its net income comes from one function of that record, so a level can change the result without touching the rest of the loop.
Finer control (hook, later): the "orders" part of the route record is the abstraction layer. In this build it is empty, which means "trade everything on the pair, both ways". Later features (choose commodities, a minimum margin below which the route idles, priority) become fields in the orders and a higher level may unlock them. Nothing in the core loop reads anything else, so adding fields changes no existing rule.
What the player decides each cycle: which pair to link (read the prices, compare planets); whether the next credits go to one more ship on a route (its lane is limited by the shared order pools), a new route (full margin, costs a ship too), or saving for a permit (opens better margins); when to close or move a route after an event closes a planet or a price moves; and, later, whether to raise a route's level. There is always a purchase worth weighing, and no chore.
Route UI (must show, per route): the two planets, ship count against ship cap, net income per cycle for the whole route and per ship, what adding one more ship would do to net income, status (running, idle, blocked by a closed planet), and the level. A one-click breakdown shows gross, trip cost and maintenance. The top bar forecast dropdown lists net income per route, not gross and costs separately.
Saturation: removed (owner decision, 2026-10-28). Extra ships on the same route do not reduce its sell price. How many ships a lane can carry is set by the shared order pools instead. A ship's first cycle on a route still pays pro rata to the fraction of the cycle it was assigned, so buying at the last second earns nothing extra (anti-exploit rule from the Economy Designer).
Planets only run on prices and these rules. The starter system has two commodities, energy and food. The third planet, Ashgate, is a second food planet that wants energy, like Tillam, with a slightly better margin; that makes the two routes from Voltara a real choice. Tillam and Ashgate do not trade with each other.

Dead state (rescue, not loss; still needed, narrower):
With trip cost netted inside routes, cash can no longer drain on its own, so the old trigger (cash below trip cost, no cargo) is gone. The rule stays as a safety net because a player can close every route, or events can close planets and idle every route, while cash is too low to start another. Stranded now means, at the end of a cycle: the player owns zero ships and cash is below [GCM:ship_price]. With a free ship the player is never stranded, on purpose, because a free ship can always start a route; so an event that closes a planet cannot trigger the payout while a ship is owned. The game does not end. A rescue pays [GCM:rescue_stipend] credits ("odd jobs at the dock", equal to one ship) and a notice says so. This is a setback, never a loss and never a way to win: it fires only in the stranded state, and the amount is just enough to buy a ship and restart one route. A player who keeps getting stranded stays below the win threshold and loses at the end of cycle [GCM:win_cycle] as usual. The starting credits must always cover the first ship, so a new game can never begin stranded.

That's the code loop pretty much. I imagine the game to be a slow pased and builds up interest over time with more updates. I dont worry that the first prototype is just that. The working core loop.

Balance targets:
Pace targets live in data/balance.json. Current targets ("targets" section, v5) are win windows by build: [GCM:win_no_skills_cycles] with no skills, [GCM:win_skilled_cycles] with a short branch learned, [GCM:win_full_tree_cycles] with the full tree, and an early-win check at [GCM:check_early_win_cycle]. The older target_* keys are removed. The keys pace_cycle_10_target, pace_cycle_20_target and pace_cycle_25_target are stale (the game is unchanged by them and the sim pace disagrees); remove or reset is an open owner question (see state.md). The old pacing text (4th ship, first permit, 7-8 ships, win at cycles 25-28) no longer applies and is not restated here.
A sloppy player stays on one route or overloads it. That player stays below the win threshold and loses. The loss condition matters without being punishing.
One loaded leg earns margin × cargo and costs [GCM:trip_cost] to fly, so a ship makes margin × cargo − [GCM:trip_cost] before maintenance. Carrying cargo both ways makes 2 × (margin × cargo − [GCM:trip_cost]) per round trip before maintenance. Routes always carry cargo both ways, so there is no empty-leg case. All of this is netted inside the route; the player sees only the net.
If players win before about cycle [GCM:check_early_win_cycle], raise the win threshold or the maintenance cost first.
f the second ship comes later than about cycle [GCM:check_second_ship_cycle], the tutorial pacing drags. Raise the margins slightly.
Expose all of these values in the debug menu. The QA bot runs can then check whether “always expand” and “never expand” strategies both lose. If one of them wins, it’s a dominant strategy.

Events:
Events can change a planet's prices (and so the margin of routes touching it) and close some planets temporarily. A route touching a closed planet is blocked, pays nothing and costs nothing until the planet reopens or the player moves its ships. Events happen every [GCM:event_interval] cycles (about [GCM:win_cycle] ÷ [GCM:event_interval] events per game).
Event effect rules (tools/event_effects.md, economy designer, proposal 2026-10-27; the old key event_effect is removed): price up or price down changes both the buy price and the sell price of one commodity at one planet by [GCM:event_price_pct] (up: x (1 + pct); down: x (1 - pct)) for [GCM:event_price_cycles] cycles. A planet-closed event idles every order and route touching that planet (pays 0, costs 0) for [GCM:event_close_cycles] cycles. Space Storage (A1), Deep Holds (A2) and Event Forecast (B4) each bridge one closed cycle (sim model; in code, a route or order touching a closed planet still runs for N cycles of the closure, N = number of those skills learned).
Event texts and effect tags are generated from story/ (data/events.json). Every event pauses the game and shows a notification with its text: a single Continue button, or two to three choices, each with a short label and a plain effect line (story/game-flow.md; planned in T12). Effects use only this vocabulary: price up or down for one planet's commodity for a while; one planet closed for a while; a one-off cash gain or loss; a one-off change to storage stock of one good at one planet. Magnitudes of the last two are not set yet.

Menu UI:
Debug menu: "Debug and Game Control menus are removed from the release build"
  Force goal (DEBUG ONLY, task T78, never in release builds, stripped from the export like the debug menu): sets cash to [GCM:win_cash] at the end of the current cycle, so QA can reach the win choice and both branches without a natural win. Normal play does not reach the goal in system 1 yet (see Permits section).
  Stats file path: the debug menu shows the path of user://stats.json (T78).
Event control:
  How often events happen
  A list of events availaible
  Trigger an event
  Effect multiplier for events
Game Control menu:
  Values and targets: every number is in data/balance.json ("values" and "targets" sections), not in this GDD. The Game Control menu reads and writes that file. Keys match the [GCM:<key>] tokens used in this GDD. The v0.1 values in that file are the starting point for the paper model and for tuning.

A Player makes money from automated routes.

Planned features after we create the working core loop game.
Ship Upgrades (the late-game spending option, not in the current step):
Once a ship is bought, the player can pay [GCM:upgrade_cost] credits to upgrade it. The upgrade adds +[GCM:upgrade_margin_bonus] margin per unit on that ship's route. Each ship can be upgraded once. Upgrades are optional. Flag: with routes as the core, this is the natural first use of route level (an upgrade raises the route, not a single ship). When it is built, it must be one system, not two; the Economy Designer then restates its numbers against route level.

Planned later: Space buildings trade posts.

The win condition:
Told in the beginnig of the game over a text menu. The Player has a dream to escape from society on its own planet. But in order to do that, the player needs money. The first time the cash balance (the credit figure in the top UI bar) is at least [GCM:win_cash] credits at the end of a cycle, the game ends and the success story shows. If cash is still below [GCM:win_cash] at the end of cycle [GCM:win_cycle] (about [GCM:win_cycle] × [GCM:cycle_minutes] minutes in), the game ends with a loss.

Ship stats:
Ship price: [GCM:ship_price]cr
Cargo per ship: [GCM:cargo] units

Trade (done by routes only, never by hand):
The margin per unit is the sell price minus the buy price, see section 2. A round trip earns 2 × [GCM:cargo] × margin per ship, before trip cost and maintenance; the route pays the net.

Permits, systems 2 and 3 (DEFERRED, ON HOLD by the owner; not deleted):
The playable scope is a fully working System 1 only. Permits, systems 2 and 3 and all their content are deferred and are not built, tuned or tested in the current steps. Design intent kept for later: a permit opens a new system with better margins ([GCM:permit_margin_bonus], [GCM:permit_2_cost], [GCM:permit_3_cost]); System 3 only after System 2.
Open OWNER decision: System 1 alone currently has no modelled win path. The best no-permit line reaches about 7120 at cycle 30 against win_cash 9000. win_cash and the 30-cycle window are unchanged; how System 1 can be won is for the owner to decide.

Price source of truth: prices live in data/planets.json (base_prices per planet). data/balance.json holds no prices; its price-like keys (energy_buy and so on) are not authoritative where planets.json disagrees. Planet and price numbers: see data/planets.json; everything else: data/balance.json.

Story and tone (owner direction, 2026-10-27; texts in story/, voice rules in story/voice.md):
Alien-industrial dread (cold hulls, humming ducts, dark outside the glass; hint, never a monster) mixed lightly with collectivist bureaucracy as flavour only: a society that shares everything and counts all of it, with gentle humour about the commercial grind. The player wants to escape that society, and the cash goal buys the way out. The joke is the player: a trader chasing a cash goal inside a society that preaches sharing. No real-world figures, parties or slogans.
Story-only terms (never shown as a mechanic, never change a number): the Commons (the shared society), the Plan (its five-cycle plans), the Bureau (the polite, slow office), the Common Ledger (the Commons' record of who has what), the Release (the form that takes a company off the ledger; this is what the cash goal buys), fellow hand (how people address each other), Corporation (the company that stays on the ledger). In UI text the player sees "cash goal"; "Release" appears only in story texts and on the choice screen. Menus, buttons, labels, notices and tutorial lines stay plain.
Where the texts live: story/*.md is the source. tools/build_story.py (T76) generates data/story_text.json and data/events.json from it; the build is their only writer and it fails on a text over its limit, a repeated id or an unreadable block. game/story_text.gd reads them. Do not edit the two generated files by hand.
No achievements, trophies or badges. The reward for good play is ending quality only: richer, longer, more specific text.

The win choice and endings (story/endings.md, story/screens.md; wiring T77 to T80):
At the cash goal the game pauses and shows the choice screen once (CHOICE_* texts, no close button): Release (the company leaves the Common Ledger and escapes) or Stay as a corporation (the company stays on the ledger). The player chooses once and the run ends with exactly one ending. Loss is separate (END_LOSS). Open owner question: after Stay as a corporation, does the run end (plan default) or continue?
Each side has three tiers, same logic on both sides:
  Bare: only system 1 reached and no skill learned other than A1 (or none). Short, plain, generic.
  Partial: anything between Bare and Full. Names the dominant branch's mood.
  Full: every open system reached (a first route or storage in each) and at least one branch fully learned; longer, names Voltara, Tillam and Ashgate, and has an epilogue line (_EPI). Two or more fully learned branches give the "whole" variant.
Selection inputs the game already knows: learned skill ids, learned count per branch, dominant branch (strictly largest count, none if tied), systems reached, branches fully learned, the cycle the goal was reached, and final cash (shown only, not used for selection). Release side uses the last-cycle flag; the corporation side does not.
Ending ids (END_*): Release side: END_BARE_HANDS, END_LAST_LIGHT, END_COLD_LEDGER, END_OWN_HORIZON, END_SLOW_HARBOR, END_ENOUGH (default), END_REL_FULL_L, _R, _E, _X. Corporation side: END_CORP_BARE, END_CORP_LOGI, END_CORP_RES, END_CORP_EXP, END_CORP_MIX (default), END_CORP_FULL_L, _R, _E, _X. Full endings also have an _EPI text. The selection tables (first match wins) are in story/endings.md and are not copied here.
Full is unreachable in the current build: it needs every open system reached, and systems 2 and 3 are on hold. It becomes reachable when they are unblocked.
Recording (T78): when the choice is answered, the game records the side chosen and the ending id locally in user://stats.json (schema_version 1, wins, choices {release, corporation}, endings {id: count}). Once per run, atomic write, an unreadable file is moved to user://stats.bad.json and started fresh. No network, no analytics, no name or id; nothing leaves the machine. Losses are not recorded (open owner question). No in-game stats screen (open owner question).

Economy v5 (balance.json data_version 5, sim v3, 2026-10-27):
New and changed values (all in data/balance.json): cargo [GCM:cargo], trip_cost [GCM:trip_cost], maintenance [GCM:maintenance], upgrade_cost [GCM:upgrade_cost], upgrade_margin_bonus [GCM:upgrade_margin_bonus]; standing local orders move [GCM:order_amount] per cycle (separate from cargo); a route moves cargo ÷ (2 × travel_cycles_per_leg) per cycle. Unchanged: starting_credits, ship_price, ship_cap, win_cash, win_cycle, event_interval, rescue_stipend, permit costs and margin bonus. The Hauler and skill A3 were cut on 2026-10-28. Skill effects: [GCM:skill_A4_route_units], [GCM:skill_B2_order_units], [GCM:skill_B3_margin], [GCM:skill_A5_upkeep]. Storage: [GCM:space_storage_capacity], [GCM:planet_to_space_rate]; planet storage capacity stays 100.
Expansion points model: called "expansion points" in data keys and in this GDD; the one on-screen name is "Skill points" (top bar, per the glossary in story/voice.md). Sources, each paid once: first visit to a planet [GCM:skill_points_planet] (the home planet counts, so Voltara gives 1 on cycle 1); first route on a new planet pair, direction ignored, [GCM:skill_points_route]; first entry to a new system [GCM:skill_points_system] (none in system 1). The player starts with 0. System 1 total: 3 planets plus 2 profitable pairs x 2 = 7 points; 9 if the loss-making Tillam-Ashgate pair is counted. The whole tree costs 20 (twelve skills, skill_cost_<id> keys). System 1 therefore buys one short branch (about 4 nodes), never the tree. Permits cost [GCM:permit_points_2] and [GCM:permit_points_3] points (on hold).
Targets and sim win cycles (snapshot, sim v3, 80 event seeds, min / median / max; sim results, not balance values): no skills 24 / 28 / 30, 75% win (target [GCM:win_no_skills_cycles]); 7-point Logistics 21 / 24 / 26, 100%; 7-point Research 22 / 25 / 30, 100% (both inside the skilled target [GCM:win_skilled_cycles]); mixed 22 / 25 / 29, 100%; full tree reference (0.7 points per cycle) 19 / 21 / 23, 100% (target [GCM:win_full_tree_cycles]). Sloppy one-route, always expand and never expand all win 0%, so none is a dominant strategy. No-event runs: decent no skills wins at cycle 26; sloppy 1 route ends at 5488, always expand 6824, never expand 6792. Caveats: Logistics is about one cycle faster than Research; a rare lucky Logistics seed wins at 21, one below the early-win check. The Expansion branch has no income effect while systems 2 and 3 are on hold, so it is a pure ending-tier branch; "no dominant branch" holds only because it is cosmetic (open owner question). Sim assumptions not yet confirmed in code: a new route's first cycle earns 0; the system-1 start counts as a visited planet.
