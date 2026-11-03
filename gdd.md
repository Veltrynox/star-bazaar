Game Design Document - Fourth Draft
Date: 3 November 2026 (revised for the Four Markets goal; see gdd-log.md)

GIT: https://github.com/Veltrynox/star-bazaar/blob/main/gdd.md

SECTION INDEX
Each section starts with a banner line of "=" signs, then its heading. Find a section by grepping its heading (for example: grep -n "^2\. GAME MECHANICS" gdd.md). Line numbers are not listed because they change with every edit.
  1. EXECUTIVE SUMMARY / GAME SPECIFICITY: one-liner, name, engine, platform, core loop, win and loss conditions
  2. GAME MECHANICS / PLAYER EXPERIENCE: credit inflow and outflow, mechanics, first 4 cycles, automated routes (core), the market goal (markets, share, win, loss, rivals, spreading penalty), balance targets, events (market chains and the shared pool), menu UI (Competitors menu, debug menu), planned upgrades, story and tone, the endings, expansion points
The skill trees (four markets plus three Foundations), space storage and game menu are in gdd-skills.md (draft 2).
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

Core loop: The player runs a trading company, not a freighter. Each cycle: read the route income, pick the next investment (a new route, one more ship on a route, a workshop, a permit, a skill), and let the routes earn. Routes are automated from the first minute; the game works out whether the player can afford one, and every route pays out net of its own trip cost and maintenance. Cash is fuel, not the goal: it buys ships, workshops and fees. The goal is to take over one market.

Win: hold more than [GCM:win_share_pct] of the share of ONE of four markets (Military, Luxury, Minerals, Biotech) against three rival companies. The early win needs that share at the end of [GCM:win_hold_cycles] cycles in a row, counted from cycle [GCM:win_earliest_cycle]; at the end of cycle [GCM:win_cycle_markets] any market still over the line wins (the highest share if two). A market's win is also not declared before its last chain step (B4) has fired or cycle [GCM:win_gate_cycle] is reached. The game then ends with the ending of that market (see "The endings" in section 2).

Loss and soft ending: END_BANKRUPT (no ship left and cash still negative, after ship repossession), END_SWEPT (player share under [GCM:sweep_share_pct] in all four markets for [GCM:sweep_hold_cycles] cycles in a row, checked from cycle [GCM:sweep_earliest_cycle]) and the soft END_OUTCOMPETED (cycle [GCM:win_cycle_markets] reached with no market held; the player did not lose). Check order at the end of a cycle: win, then swept, then bankrupt.

RETIRED (3 November 2026): the old cash goal (win_cash, win_cycle), the final Release or Stay-as-corporation choice and the Release and Corporation endings. They are gone from the design, the data and the endings.
========================================
2. GAME MECHANICS / PLAYER EXPERIENCE
========================================
Source of truth: The numbers in this GDD are a starting point only. Once production starts, data/balance.json is the single source of truth for every balance value, and the Game Control menu reads and writes that file. Where this GDD and balance.json disagree, balance.json wins. [GCM:<key>] tokens in this GDD point to the balance.json key with the same name. This GDD is not updated with new numbers after production starts; the Economy Designer changes balance.json. Number status: the market numbers (bots, share, overhead, win keys) are a paper-model first pass retuned once on 2026-11-03 (data_version 39). They are not tuned against a human playtest. Anything the data does not fix is UNKNOWN here.

The numbers come from a rough paper model, not final balance, built on the fixed facts: [GCM:win_cycle_markets] cycles of about [GCM:cycle_minutes] minutes each.

The game takes at most [GCM:win_cycle_markets] × [GCM:cycle_minutes] minutes to complete (earlier if a market is won from cycle [GCM:win_earliest_cycle]). A game cycle lasts around [GCM:cycle_minutes] minutes. There are [GCM:win_cycle_markets] cycles.
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
Routes - The core. Send stock one way from a company storage to another planet, put a ship on it, collect net income.
Permits - Solar systems access
Events - To bring some randomness and fun to the game.

Manual trading (ruling): removed from regular play. The player never buys and sells cargo by hand. Reason: the owner's vision is a company manager, and a hand-run trade loop is the micro-management that routes replace; keeping it as a side action would make the optimal play a chore. The planet panel still shows each commodity's buy and sell price, because that is what the player reads to choose a route. The tutorial no longer has a manual trade; its trade lesson is the route preview (see First 4 cycles). The existing trade code (game/trade.gd) is reused as the route engine, not as a player action.

Top bar:
Goal line: "Goal: more than {pct}% of one market" (LBL_GOAL_MARKETS, pct from win_share_pct). A share panel shows the share of each market; the Competitors menu shows the rivals (see Menu UI).

The game is mostly event and text driven, for now.

First 4 cycles of the game:
The player reads the preface story. The game starts. We sees 3 Planets, a notification board on the right side with a mission hint.
"Set up your first route" mission text. The UI on top with some information: [GCM:starting_credits] starting credits. The planet highlights, the player clicks on it, a menu pops up. This planet has an abundance of energy but not enough food. The player clicks another planet and sees it has an abundance of food but low energy supply. The planet panels show the buy and sell prices, so the player can see the margin: energy is cheap here ([GCM:energy_buy] per unit) and sells for [GCM:energy_sell]cr there; food is cheap there ([GCM:food_buy]cr) and sells for [GCM:food_sell]cr here.
The mission board explains standing orders and routes as they work now (story/game-flow.md): a Buy order brings stock into a planet's storage, a Sell order sells it, and "Send to..." moves stock one way to another planet with a ship that flies by itself. The planned T15 rewrite brings the tutorial text in line; the lines below still describe the older route screen and are not yet rewritten. The tutorial lines still describe the older route screen (pick two planets, confirm, buy and assign a ship in one step). They are planned to be rewritten to the current flow under T15. The current flow (story/game-flow.md): the player sets standing Buy and Sell orders on the planet rows, or presses "Send to..." on a storage row to make a one-way route. The route takes a free ship the company already owns; if none is free, the screen says so. The route screen shows the net income per cycle, with trip cost and maintenance already taken out, and whether the route can be set up now, with the one reason if not. Once the first route runs, the player only decides; the ship does the flying.

How a route earns (formulas; numbers are in balance.json): the margin is the sell price minus the buy price. Routes are one-way. With [GCM:cargo] units of cargo, one loaded leg earns margin × cargo. The leg costs [GCM:trip_cost] in trip cost, and each ship carries maintenance of [GCM:maintenance] every [GCM:maintenance_interval] cycles. What is left is the route's net income, spread as a per-cycle figure. The route pays that net figure at the end of every cycle; the player never sees the gross numbers unless they open the breakdown. Open for the Economy Designer: the sim still writes per-cycle throughput as cargo ÷ (2 × travel_cycles_per_leg), a round-trip form, so the one-way figure needs confirming.

After several cycles we have enough money for a second ship. The player chooses whether the next credits go to one more ship on an existing lane or to a new route. The shared order pools of a lane limit how many ships it can carry. There is a cap of possible ships which is [GCM:ship_cap] ships max; it is a backstop, not the main limit. This choice is the core decision of the game.

Automated routes:
The current flow is described in story/game-flow.md, which wins over this section where they differ. The text below follows it (updated 2026-10-31).
Standing local orders (built): each planet row has a Buy and a Sell order, each toggled on or off. No ship is needed. Each cycle a Buy order buys [GCM:order_amount] units at the planet's buy price into that planet's company storage, and a Sell order sells stock from that storage at the sell price. Orders read only planet storage.
Planet storage (built): each planet keeps a company storage per commodity. The storage row shows a 5-line rating bar (5 = full). A full storage makes a Buy idle with the status "storage full", which is not an error.
One-way routes (built): a route only moves stock between company storages. On a storage row the player presses "Send to..." and clicks the destination planet. The route gets one ship, assigned automatically from the company's free ships. If no ship is free, the screen says so. Routes are never made by clicking Buy in one place and Sell in another. A lane can carry more than one ship; the shared order pool of its planet and commodity is the natural limit, and [GCM:ship_cap] ships in total is the backstop (owner decision, 2026-10-27).
Route status: an empty source stalls the route and it waits. A full destination that still has a Sell order or an onward route waits for room (neutral). A full destination that nothing will ever empty is blocked (red line, one notification) until the player acts. A route touching a closed planet is blocked (see Events).
Space Storage (skill FND_STORAGE, formerly A1; see gdd-skills.md section 4): one per system, earned with the skill, not free. In the build, stock moves from planet storage into Space Storage after the sells each cycle (the rate is a balance key). Open design call for the owner: local Sell orders read planet storage only, so Space Storage stock is not sold until the code lets Sell orders draw from it.
Setting up: the game, not the player, checks whether a route can be set up. It needs a free ship, room under the ship cap, and open planets. There is no separate setup fee and no cash buffer for trip cost, because trip cost is never paid from cash (see below). The route screen shows the verdict and, when it is "no", the one reason.
Net income, fool-proofing: each route pays at the end of every cycle, and what it pays is already net of its trip cost and its maintenance. The player cannot run out of money mid-trip and cannot be charged for a leg they cannot afford. A route never charges: if its net income would be zero or less (an event, a price drop), the route idles, pays nothing, costs nothing and shows "not profitable". Setup of a route whose net would be zero or less is refused with that reason. A ship that is not on any route costs nothing. The only cash the player ever spends is on purchases they choose (ships, permits, upgrades), and each is checked against cash before it happens.
Every ship earns on its own: each ship flies its own legs, carries its own [GCM:cargo] units and pays its own trip cost and maintenance (inside the route). Ships add income; they do not add capacity to another ship. Ships on different routes earn the full margin.
Route level (hook, no numbers): every route has a level, and all routes start at the base level, which is fully automatic with no player input. A later upgrade raises a route's level and gives it more automation. What a level does is not defined in this build. The only requirement now is structural: a route is one record (source, destination, ship count, level, orders) and its net income comes from one function of that record, so a level can change the result without touching the rest of the loop.
Finer control (hook, later): the "orders" part of the route record is the abstraction layer. In this build the standing Buy and Sell orders sit on the planet rows, and the route record carries no extra orders. Later features (choose commodities, a minimum margin below which the route idles, priority) become fields in the orders and a higher level may unlock them. Nothing in the core loop reads anything else, so adding fields changes no existing rule.
What the player decides each cycle: where to send stock (read the prices, compare planets); whether the next credits go to one more ship on a route (its lane is limited by the shared order pools), a new route (full margin, costs a ship too), or saving for a permit (opens better margins); when to close or move a route after an event closes a planet or a price moves; and, later, whether to raise a route's level. There is always a purchase worth weighing, and no chore.
Route UI (must show, per route): the source and destination, ship count against ship cap, net income per cycle for the whole route and per ship, what adding one more ship would do to net income, status (running, stalled, waiting for room, blocked), and the level. A one-click breakdown shows gross, trip cost and maintenance. The top bar forecast dropdown lists net income per route, not gross and costs separately.
A ship's first cycle on a route pays pro rata to the fraction of the cycle it was assigned, so buying at the last second earns nothing extra (anti-exploit rule from the Economy Designer).
Planets only run on prices and these rules. The starter system has two commodities, energy and food. The third planet, Ashgate, is a second food planet that wants energy, like Tillam, with a slightly better margin; that makes the two routes from Voltara a real choice. Tillam and Ashgate do not trade with each other.

Dead state (rescue, not loss; still needed, narrower):
Dead state (rescue, not loss; still needed, narrower):
With trip cost netted inside routes, cash can no longer drain on its own, so the old trigger (cash below trip cost, no cargo) is gone. Stranded means, at the end of a cycle: the player owns zero ships and cash is below [GCM:ship_price]. With a free ship the player is never stranded, on purpose. The game does not end. A rescue pays [GCM:rescue_stipend] credits ("odd jobs at the dock", equal to one ship) and a notice says so. Only the first [GCM:rescue_max] stipends of a run are paid; no stipend is paid in a cycle where a ship was repossessed, and a stipend never ends the run. It is a setback, never a loss and never a way to win. The starting credits must always cover the first ship, so a new game can never begin stranded. Bankruptcy is separate and is a loss: see "Loss rules" in the market goal below.

That's the code loop pretty much. I imagine the game to be a slow pased and builds up interest over time with more updates. I dont worry that the first prototype is just that. The working core loop.

The market goal (Four Markets, 3 November 2026; design pack design/proposals/2026-11-03-four-markets*.md, whose summary file decides where the pack disagrees):
Markets: four abstract categories, never map objects: Military (mil), Luxury (lux), Minerals (min), Biotech (bio). Every good belongs to one market (data/markets.json; 19 goods: 8 old plus 11 new). Military: energy, chips, rivets, cells, armour. Luxury: silk, musk, cask, gems. Minerals: ore, dross, nullglass, plate, ingot, alloy. Biotech: food, spores, gel, seed. Energy, food and ore are common raws: usable as recipe inputs for any market, and not counted toward the active-market rule, cross-load or chain triggers. Prices live in data/goods.json and data/planets.json.
Workshops: one per market (Munitions Line, Atelier, Smelter, Culture Lab; the Fabric stays as the plate station). Each is built once for credits ([GCM:workshop_build_cost], Fabric [GCM:fabric_build_cost]) and unlocked by the first node of that market's tree; it makes [GCM:workshop_batches_per_cycle] batch a cycle. Crafted goods go to company storage and are sold by normal Sell orders and routes. Tech nodes advance only by crafting in that market's workshop.
Share: a sale adds units sold x the good's base value (a fixed value per good in data/markets.json, so price events and price skills never move share) to the player's volume in that market. Only a sale at a planet counts, not a move to storage. Share = player volume over the last [GCM:share_window] cycles divided by player plus the three rivals' volume (Biotech's window is [GCM:share_window_bio_bonus] cycles with BIO_5). Before the window fills it uses the cycles played. Zero total volume gives zero share.
Rivals: three computer companies, numbers only (working names Harrow Combine, Velvet Concord, Ostrel Syndicate; the names are judged in play). Each has a strength, a growth and a tier per market (bot_<n>_<mkt>_strength and _growth keys), scaled by bot_scale ([GCM:bot_scale]) and the tier multipliers bot_tier_mult_1 to 4; tiers rise at fixed cycles per rival (bot_<n>_tier_cycle_1 and _2). Volume has about [GCM:bot_noise_pct] noise. Gap rule: in a market where the player's share is under [GCM:bot_gap_share_pct], every rival gains [GCM:bot_gap_growth] extra growth, so ignored markets fill up. Rivals are hit by chain options, pool events and the capstone skills.
Spreading penalty (by numbers): market_overhead [GCM:market_overhead] x (n_active - 1)^2 credits a cycle, where n_active counts markets with more than [GCM:market_active_pct] of the player's window volume; a route load that mixes markets pays [GCM:cross_load_trip_mult] x trip cost and loses the bundle bonus; skill points are finite and shared; workshops cost credits per market. The paper model: a focused run wins, three or four markets never do.
Loss rules (approved 2026-11-03): Bankrupt: when cash is negative after upkeep and overhead, the newest ship is repossessed each cycle and [GCM:salvage_share] x ship price is credited; the run ends in END_BANKRUPT when no ship is left and cash is still negative. Swept: share under [GCM:sweep_share_pct] in all four markets at the end of [GCM:sweep_hold_cycles] cycles in a row, from cycle [GCM:sweep_earliest_cycle]. Outcompeted (soft): the last cycle passes with no market over the line. Order: win, swept, bankrupt.
Skill points from share: the first time share in a market reaches 20% pays [GCM:skill_points_share_20] point, at 35% [GCM:skill_points_share_35] points, once per market, so depth pays more than width. Money never buys skill points.

Balance targets:
Pace targets live in data/balance.json ("targets" section). The windows there ([GCM:win_no_skills_cycles] with no skills, [GCM:win_skilled_cycles] skilled, [GCM:win_full_tree_cycles] full tree, early-win check [GCM:check_early_win_cycle]) were set for the retired cash goal. Whether they are re-based for the market goal is UNKNOWN (owner and economy designer to confirm). The paper model aims at a focused player's median win near cycles 27 to 28 (floor set by the hold rule), a player split over two markets almost never winning and a player over four never; the data_version 39 note records that with the current bot numbers a decent bot wins Military and Biotech at cycle 26 and Minerals at cycles 26 to 28, while the default permit-2 bot and the spread bot still collapse (code gaps in the QA handoff). Win rates against humans are UNKNOWN.
One loaded leg earns margin × cargo and costs [GCM:trip_cost] to fly, so a ship makes margin × cargo − [GCM:trip_cost] before maintenance. Routes are one-way: the return leg is empty and earns nothing. All of this is netted inside the route; the player sees only the net.
Dominant-strategy check: QA bots (focused, spread, bankrupt, passive, always expand, never expand) must not all win. A spread over many markets, sloppy play and never expanding must not win. Expose all of these values in the debug menu.

Events:
Events:
Events can change a planet's prices (and so the margin of routes touching it), close some planets temporarily, and now also hit the rival companies. A route touching a closed planet is blocked, pays nothing and costs nothing until the planet reopens or the player moves its ships. One event fires every [GCM:event_interval] cycles; a market chain step takes the slot before any pool event, and at most one event happens per cycle.
Two kinds of event:
  1. Market chains (new). Each market has 7 steps, 28 in all: A1 to A3 and B1 to B4 per market (data/chains.json, one record per step). A step fires by its trigger (a first sale in the market after cycle [GCM:chain_MIL_A1_trig_first_sale_cycle], a share level, or cycles since the previous step) and at least [GCM:chain_min_gap] cycles after the last chain step of that market. Every step offers two neutral in-fiction options, shown in a shuffled order. Each option gives the player something, costs something, and changes at least one rival stat (strength, growth or tier). The effect line tells the player the plain cash, volume, price or rival effect; it never says good or bad. Hidden direction: each market keeps one hidden value (dir_MIN to dir_MAX, about -100 to 100), nudged by every option picked in either chain of that market (base nudge from the step, a repeat in the same direction counts x[GCM:dir_echo_mult], a late swing x[GCM:dir_swing_mult] when the lean is at least [GCM:dir_swing_min_abs] and the nudge opposes it, each nudge capped at [GCM:dir_nudge_cap]). At the win, a direction of [GCM:dir_good_min] or more gives the GOOD ending of that market, below it the BAD ending; no step fired counts as good. The end screen never shows the value, the choices or a label. The steps' numbers are the chain_<STEP>_<a|b>_* keys in data/balance.json.
  2. The shared pool (one-time events, each fires at most once per run): 24 kept events (EV01 to EV16, EV17, EV20, EV21, EV22, EV24, EV25, EV26, EV28) plus 12 new events EV40 to EV51 (three per market: Military EV40 to EV42, Luxury EV43 to EV45, Minerals EV46 to EV48, Biotech EV49 to EV51), 36 in all. Some pool events lift or slow a rival (a shortage slows the market's lead rival, a glut lifts bot_3). Only the new events' rows in data/chains.json (pool_new) and the story texts exist at the time of writing; whether data/events.json and the game already draw EV40 to EV51 is UNKNOWN to this GDD.
Retired 2026-11-03: the Minerals events EV29 to EV37 and the shield event EV18 (data/chains.json pool_retired). Their data, banners, follow-up code and tests were removed (EV18 still has a row in data/events.json and text in story/events.md at the time of writing; the draw is not confirmed to be gone, UNKNOWN). The old event stances (an Open or Hard choice per event) are retired too: choices are two neutral options with no virtue labels.
Event effect rules (tools/event_effects.md, economy designer): price up or price down changes both the buy price and the sell price of one commodity at one planet by [GCM:event_price_pct] (or the event's own event_pct_<good>) for [GCM:event_price_cycles] cycles. A planet-closed event idles every order and route touching that planet for [GCM:event_close_cycles] cycles. Rival hits come in sizes S, M and L ([GCM:event_hit_strength_S], [GCM:event_hit_strength_M], [GCM:event_hit_strength_L] of strength; growth sizes [GCM:event_hit_growth_S], [GCM:event_hit_growth_M], [GCM:event_hit_growth_L]); tier is only ever cut.
Every event pauses the game and shows a notification with its text: a single Continue button, or two to three choices (story/game-flow.md). Texts and effect tags are generated from story/ (data/events.json, data/story_text.json).

Owner ideas of 2026-10-28 (state of each after the market goal change):
  Debris (idea 1): a debris field lowers its planet's route efficiency until the clearing fee is paid. Keys exist (debris_route_penalty, debris_clear_fee). Whether it still has an event after the EV29 to EV37 retirement is UNKNOWN.
  Solar shield (idea 2): RETIRED 2026-11-03. The shield event EV18 is retired, the buyable shield, its hidden flag and every shield mention in endings are gone from the design. The shield_* keys may still sit in data/balance.json and are not read by the design.
  Nomads and pirates (idea 3): planned, none built; pirates reduce trade volume; keys pirate_* exist. Open as before (nomad link, "ships are for hauling only").
  Asteroid approach (idea 5): the 50/50 warning event exists as EV20 in the kept pool (asteroid keys in balance.json); it also hits bot_1 Minerals growth (S).
  Asteroid fields (idea 6): planned. Open: what a field blocks or yields and whether money may clear fields.

Menu UI:
Debug menu: "Debug and Game Control menus are removed from the release build"
  Force market share (DEBUG ONLY, never in release builds, stripped from the export like the debug menu): picks a market and adds a huge player sale in it at every cycle end, so its share goes over the win line and the win fires after [GCM:win_hold_cycles] cycles counted from cycle [GCM:win_earliest_cycle]. Replaces the old Force goal (cash). QA uses it to reach each market ending without a natural win.
  Stats file path: the debug menu shows the path of user://stats.json (T78).
Event control:
  How often events happen
  A list of events availaible
  Trigger an event
  Effect multiplier for events
Game Control menu:
  Values and targets: every number is in data/balance.json ("values" and "targets" sections), not in this GDD. The Game Control menu reads and writes that file. Keys match the [GCM:<key>] tokens used in this GDD.
Competitors menu (built, game/competitors_panel.gd; opened from the game menu, the share panel or L; pauses like the game menu and Esc closes): one tab per market with a line graph of share over cycles (the player and the three rivals, a dashed 50% line), a table of each company's current share and its change over the last 5 cycles, and a Recent moves log. Recent moves lists the changes to rivals caused by market chain options (and by pool events and skills that hit rivals), one line each, for example "<rival>: <market> strength down". Rivals are numbers on a graph only; they never appear on the map.
A Player makes money from automated routes.

Planned features after we create the working core loop game.
Ship Upgrades (planned, not built; the late-game spending option):
Once a ship is bought, the player can pay [GCM:upgrade_cost] credits to upgrade it. The upgrade adds +[GCM:upgrade_margin_bonus] margin per unit on that ship's route. Each ship can be upgraded once. Upgrades are optional. Flag: with routes as the core, this is the natural first use of route level (an upgrade raises the route, not a single ship). When it is built, it must be one system, not two; the Economy Designer then restates its numbers against route level.

Planned later: Space buildings trade posts.

Owner ideas of 2026-10-28: map, visuals and money (all PLANNED, none built):
  Galaxy view (idea 4, tasks T119, T106, T118, T105): the zoomed galaxy view opens only after the player has opened solar system 2, introduced through the tutorial (T119, with T15). This is a design change, not a bug fix. The zoom work (T105) stays blocked by T85. Open: what the per-system summary shows.
  Ship dots (idea 7, task T114): one dot for each ship leaving its source and one for each ship arriving at its destination, with a fading trail along the lane. One dot per ship on a shared lane (T87). No text on the dots.
  Planet textures (idea 7, task T115, blocked): one texture per planet type. The planet types and which planet has which type are not yet set by the owner. A commit titled "Planets: per-type textures" exists in the repository history; this GDD still counts per-type textures as planned until the type list is set.
  Money rules: money never buys skill points (standing rule, 2026-10-28). Open: whether that rule covers every kind of spending (debris fee, pirate clearing, field clearing, workshops), and whether the T59 rule (money only reaches the final goal) still stands now the final goal is a market share. The shield part of the old question is retired.

The win condition:
Told at the start of the game over the preface text. The player runs a small trading company in a society that shares everything and counts all of it, and wants to be more than one name on a ledger. To do that the company must own more than half of one market. The goal line reads "Goal: more than {pct}% of one market". The win rules, loss rules and the soft ending are in "The market goal" above and in the Executive Summary. There is no cash goal any more.

Ship stats:
Ship price: [GCM:ship_price]cr
Cargo per ship: [GCM:cargo] units
Ship types (built, data/ships.json, T58): one type in the build, the small ship (named Skerrit in the file; owner to confirm the names). It uses the ship price, cargo and upkeep values with multipliers of 1. The Hauler (large ship) and its keys were cut by the owner on 2026-10-28, so no other ship type is in this GDD.

Trade (done by routes only, never by hand):
The margin per unit is the sell price minus the buy price, see section 2. A one-way loaded leg earns [GCM:cargo] × margin per ship, before trip cost and maintenance; the route pays the net.

Permits and systems 2 and 3:
System 1 (Hollin Reach) is the playable core. System 2 (Dunmere Reach) is in scope for the Alpha and is opened with a permit, which needs the Permit Charter (FND_PERMIT). System 3 stays on hold by the owner and is not built, tuned or tested. A permit opens a new system with better margins ([GCM:permit_margin_bonus], [GCM:permit_2_cost], [GCM:permit_3_cost]); System 3 only after System 2. Open: tools/system2_proposal.md says the system 2 margin is already in the prices, so permit_margin_bonus may do nothing (Economy Designer to confirm).
System 1 win path: the old statement (base play with no permit reaches the cash goal in 15 of 16 seeds) belonged to the cash goal and is RETIRED. Whether a focused market win is reachable in system 1 alone on the real game is UNKNOWN; the 2026-11-03 data_version 39 note says a decent bot without a permit wins Military and Biotech at cycle 26 and Minerals at 26 to 28. Human playtest wanted.

Price source of truth: prices live in data/planets.json (base_prices per planet). data/balance.json holds no prices; its price-like keys (energy_buy and so on) are not authoritative where planets.json disagrees. Planet and price numbers: see data/planets.json; everything else: data/balance.json.

Story and tone (owner direction, 2026-10-27; texts in story/, voice rules in story/voice.md):
Alien-industrial dread (cold hulls, humming ducts, dark outside the glass; hint, never a monster) mixed lightly with collectivist bureaucracy as flavour only: a society that shares everything and counts all of it, with gentle humour about the commercial grind. The player wants a market of their own inside that society, and the three rival companies are what stands in the way. No real-world figures, parties or slogans.
Story-only terms (never shown as a mechanic, never change a number): the Commons (the shared society), the Plan (its five-cycle plans), the Bureau (the polite, slow office), the Common Ledger (the Commons' record of who has what), fellow hand (how people address each other). RETIRED: the Release (the old cash-goal form) and Corporation; they appear in no text. Story terms appear only in story texts. Menus, buttons, labels, notices and tutorial lines stay plain.
Where the texts live: story/*.md is the source. tools/build_story.py (T76) generates data/story_text.json and data/events.json from it; the build is their only writer and it fails on a text over its limit, a repeated id or an unreadable block. game/story_text.gd reads them. Do not edit the two generated files by hand.
No achievements, trophies or badges. The reward for good play is ending quality only: richer, longer, more specific text.

The endings (story/endings.md, story/screens.md; the end screen reads <id>_TITLE and <id>):
The run ends with exactly one ending, with no choice screen. RETIRED: the Release and Stay-as-corporation choice, the Bare, Partial and Full tiers, all END_BARE_HANDS, END_LAST_LIGHT, END_COLD_LEDGER, END_OWN_HORIZON, END_SLOW_HARBOR, END_ENOUGH, END_REL_FULL_* and END_CORP_* ids, END_LOSS, and the shield wording. The ending ids are:
  Win endings (8): END_MIL_GOOD, END_MIL_BAD, END_LUX_GOOD, END_LUX_BAD, END_MIN_GOOD, END_MIN_BAD, END_BIO_GOOD, END_BIO_BAD. The market held picks the pair; the hidden chain direction of that market picks GOOD or BAD. The BAD texts describe what the world shows after the same win; they never say the player chose anything and never judge the player.
  Loss (2): END_BANKRUPT (ship repossession) and END_SWEPT (under [GCM:sweep_share_pct] in all four markets).
  Soft (1): END_OUTCOMPETED ("No Market Held"; the player did not lose).
Epilogue lines (EPI_*) appear under a win ending, up to four in this order: the capstone of the win market if learned, techs done in the win market, a rival that really lost a tier, and one line per second market over [GCM:ending_second_market_pct] share. They say what the company did, never a count, direction or stance.
The end screen shows no counts, labels, direction or record of choices. Bot, good and ending names are working names, judged in play (owner, 2026-11-03).
Recording: user://stats.json records the ending locally (once per run, atomic write, nothing leaves the machine). The old side field (release, corporation, LOSS) is retired; the exact new schema is UNKNOWN here. No in-game stats screen (open owner question).
Saved data (local only): the autosave is user://autosave.json (game/save_game.gd, save version 2 for the market goal; old saves are dropped, owner decision 2026-11-03). Nothing leaves the machine.

Economy, current (balance.json data_version 39, 2026-11-03):
Route and order values: cargo [GCM:cargo], trip_cost [GCM:trip_cost], maintenance [GCM:maintenance], upgrade_cost [GCM:upgrade_cost], upgrade_margin_bonus [GCM:upgrade_margin_bonus]; standing local orders move [GCM:order_amount] per cycle; ship_price [GCM:ship_price], ship_cap [GCM:ship_cap], starting_credits [GCM:starting_credits]. Storage: [GCM:space_storage_capacity], [GCM:planet_to_space_rate]; planet storage capacity stays 100. RETIRED keys: win_cash and win_cycle (removed in data_version 34) and the old skill keys skill_A4_route_units, skill_B2_order_units, skill_B3_margin, skill_A5_upkeep (removed in data_version 37). The Hauler was cut on 2026-10-28.
Expansion points model: called "expansion points" in data keys and in this GDD; the one on-screen name is "Skill points". Sources, each paid once: first visit to a planet [GCM:skill_points_planet] (the home planet counts); first route on a new planet pair, direction ignored, [GCM:skill_points_route]; first entry to a new system [GCM:skill_points_system] (none in system 1); share milestones in a market, [GCM:skill_points_share_20] at 20% and [GCM:skill_points_share_35] at 35%. Permits cost [GCM:permit_points_2] and [GCM:permit_points_3] points (system 3 on hold). The player starts with 0. Costs: each Foundation 1; each market tree 1 + 2 + 3 + 4 = 10 points for its four skill nodes (the three tech nodes cost no points). A focused run needs 13 (3 Foundations plus one tree). The design pack estimates about 21 points of supply against 13 for one market and 23 for two; that assumes 7 of 9 reachable planets and 5 route pairs and is UNKNOWN until the real game confirms it.
The old sim snapshot (cash goal, 80 event seeds, win cycles 19 to 30) is retired and removed; gdd-log.md keeps the history. Targets for the market goal: see Balance targets above.
