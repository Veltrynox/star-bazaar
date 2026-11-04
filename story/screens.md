# Screens, menus, notices and tutorial lines (draft 2, tone rework)

Format: ID | max chars | where it appears, then the text. Placeholders are filled by the game.
Flow follows story/game-flow.md: Buy and Sell on a row are standing local orders (on or off); a route is optional, made with "Send to..." on a storage row; the first goal is to read prices and fill Company storage.
Menus, buttons, labels, notices and tutorial lines are plain. Flavour lives in the preface, mission board intro and story screens only.

## STORY ARC (10 lines)
1. Title: a small company in a shared, indifferent sky.
2. Preface: everything is shared and counted. A company that holds over half of one market is hard to count as shared.
3. First cycles: three planets, two goods. Read prices, set standing orders.
4. Early growth: Company storage and the first expansion points. The company looks like a company, which the Commons finds suspicious.
5. First event: the market moves without asking you.
6. Skills: you choose what kind of company you are: Military, Luxury, Minerals or Biotech.
7. Midgame: debts, upkeep and the question of what is enough.
8. Pressure: events test routes; the rescue notice shows the Bureau will carry you once, politely.
9. The goal: more than half of one market. Holding it ends the run with a market ending.
10. Ending: one of the market endings, or a loss (bankrupt, swept), or the soft ending when the window closes.

## Title
SCR_TITLE_NAME | 24 | Title screen, big text
Star Bazaar
SCR_TITLE_TAGLINE | 70 | Title screen, under the name
A small company in a shared, indifferent sky.

## Preface (one block, shown before the game starts)
SCR_PREFACE | 700 | Preface screen
Everything under this sky is shared. The air, the ducts, the hulls that creak like something asleep, and every credit anyone earns, which goes into the Common Ledger and comes back in portions. The Plan is generous. It is also five cycles long, and then another five.

Four markets: Military, Luxury, Minerals, Biotech. Each has rivals, and the Plan counts every share each cycle. Hold over half of one market and the count stops being a rumour.

So you have a small company, one ship's worth of cash, three planets and two goods. Buy where it is cheap. Sell where it is not. Serving the common good is encouraged. Profit, officially, is a typing error.

What it costs the sky, the sky does not say.
SCR_PREFACE_BTN | 24 | Preface screen, continue button
Begin
SCR_PREFACE_SKIP | 24 | Preface screen, skip button
Skip

## Main menu (title screen buttons)
MENU_CONTINUE | 24 | Main menu, loads the saved game | Continue
MENU_NEW_GAME | 24 | Main menu, starts a new run | New game
MENU_CONFIRM_NEW | 110 | Confirmation dialog, new game while a saved game exists | Start a new game?
NOT_NO_SAVE | 110 | Main menu, Continue with no saved game | No saved game yet.
MENU_HINT_CONTINUE_OFF | 110 | Main menu, hint on a disabled Continue | Continue needs a saved game.

## Menu entries
MENU_RESUME | 24 | Game menu | Resume
MENU_SKILLS | 24 | Game menu and top bar | Skills
MENU_SETTINGS | 24 | Game menu (reserved slot) | Settings
MENU_STATISTICS | 24 | Game menu | Statistics
MENU_STATISTICS_DESC | 110 | Game menu, hint on the entry | Shows the figures for this run.
MENU_HELP | 24 | Game menu | Help
MENU_HELP_DESC | 110 | Game menu, hint on the entry | Shows how to read prices, set orders and make routes.
MENU_SAVE_LOAD | 24 | Game menu | Save and load
MENU_SAVE_LOAD_DESC | 110 | Game menu, hint on the entry | Save the game, or load the saved game.
NOT_LOADED | 110 | Notice, saved game loaded | Game loaded.
MENU_MAIN | 24 | Game menu | Main menu
MENU_QUIT | 24 | Game menu | Quit game
MENU_CONFIRM_MAIN | 110 | Confirmation dialog | Save and return to the main menu?
MENU_CONFIRM_QUIT | 110 | Confirmation dialog | Save and quit the game?
BTN_YES | 24 | Dialogs | Yes
BTN_NO | 24 | Dialogs | No
BTN_OK | 24 | Event popup | OK
BTN_BUY | 24 | Planet panel resource row | Buy
BTN_SELL | 24 | Right-click menu on resource button | Sell
BTN_SEND | 24 | Right-click menu on resource button | Send to...
BTN_LEARN | 24 | Skill screen | Learn
BTN_REMOVE | 24 | Route and storage panels | Remove
LBL_BUY_PRICE | 24 | Planet panel | Buy price
LBL_SELL_PRICE | 24 | Planet panel | Sell price
LBL_COMPANY_STORAGE | 24 | Planet panel (unused in panel now) | Company storage
LBL_RMB_MORE | 60 | Resource button tooltip, planet panel | Right-click for Send to, Sell and more.
LBL_SHIP_UPKEEP | 24 | Top bar and route panel | Ship upkeep
LBL_EXPENSES | 24 | Top bar | Expenses
LBL_SKILL_POINTS | 24 | Top bar, skill screen header | Skill points
LBL_GOAL_MARKETS | 60 | Top bar goal line | Goal: more than {pct}% of one market
LBL_GROSS | 24 | Route panel and statistics, income before costs | Income before costs
LBL_NET | 24 | Route panel and statistics, income after costs | Income after costs
LBL_TRIP_COST | 24 | Route panel, cost of one trip on a route | Trip cost
ST_WAITING_ROOM | 24 | Route panel, status of a route that waits because the destination is full | Waiting for room

## Skill screen extras
SK_BTN_CLOSE | 24 | Skill screen, close button | Close
SK_NONE_SELECTED | 110 | Skill screen, detail panel before a click | Click a skill to see what it does.
SK_BTN_LEARNED | 24 | Learn button, disabled on a learned skill | Learned
SK_BTN_LOCKED | 24 | Learn button, disabled on a locked skill | Locked
SK_LABEL_EFFECT | 24 | Detail panel label, unused after 2026-11-04 (plain line now shown first, no label) | What it changes

## Mission board hints (right side board)
MB_01 | 110 | Mission board, cycle 1
Click a planet to see what it sells and what it lacks.
MB_02 | 110 | Mission board, after the first planet panel is opened
Compare planets. Buy where a good is cheap, sell where it is dear.
MB_03 | 110 | Mission board, route mission
Move stock with a route: right-click a resource, choose Send to, then pick the destination planet.
MB_04 | 110 | Mission board, route done
First route running. A ship carries stock between the two Company storages.
MB_05 | 110 | Mission board, later
Build a second route, or learn a skill. Skills cost skill points. The goal: over half of one market.

## Tutorial lines (first 4 cycles)
TUT_C1_PLANET | 110 | Cycle 1, planet highlighted
Click a planet. The panel shows what it makes, what it lacks and its prices.
TUT_C1_ROW | 110 | Cycle 1, panel open
Each good has a row with a Buy price, a Sell price and a bar for Company storage.
TUT_C1_BUY | 110 | Cycle 1, after the first Buy click
Buy is a standing order. Each cycle it buys goods into Company storage here.
TUT_C1_SELL | 110 | Cycle 1, after the first Sell click
Sell is a standing order too. Each cycle it sells stock from Company storage.
TUT_C2_ROUTE_DONE | 110 | Cycle 2, first route confirmed
The ship is assigned. It moves stock between storages when the cycle runs.
TUT_C2_UPKEEP | 110 | Cycle 2, first upkeep line shown
Each ship costs Ship upkeep. It appears in the top bar as part of Expenses.
TUT_C3_STORAGE | 110 | Cycle 3, first company storage view
Company storage holds your goods on a planet. When it is full, Buy waits.
TUT_C3_ONEWAY | 110 | Cycle 3
Routes are one way. To send stock both ways, make a second route back.
TUT_C4_SKILLS | 110 | Cycle 4, if a skill point is held
You have skill points. Open Skills and learn something.
TUT_C4_FREE | 110 | Cycle 4, end of tutorial
That is the basics. Now take over half of one market. Watch Competitors.

## Key notices
NOT_ROUTE_BLOCKED_CLOSED | 110 | Notice, route touches a closed planet
Route blocked: {planet} is closed. It resumes when the port reopens.
NOT_ROUTE_BLOCKED_FULL | 110 | Notice, destination storage full
Route blocked: Company storage at {planet} is full.
NOT_ROUTE_STALLED | 110 | Notice, source storage empty
Route waiting: no {commodity} in Company storage at {planet}.
NOT_STORAGE_FULL | 110 | Row status, Buy order idle
Storage full. Buy is idle until there is room.
NOT_SKILL_POINT | 110 | Notice, expansion points earned
Skill point earned: {reason}.
NOT_SKILL_REASON_PLANET | 60 | Fills {reason} | first visit to {planet}
NOT_SKILL_REASON_ROUTE | 60 | Fills {reason} | first route from {planet_a} to {planet_b}
NOT_SKILL_REASON_SYSTEM | 60 | Fills {reason} | first route in a new system
NOT_SKILL_LEARNED | 110 | Notice, skill learned
Learned: {skill}.
NOT_SKILL_NO_POINTS | 110 | Skill screen, not enough points
Not enough skill points.
NOT_SKILL_NO_SYSTEMS | 110 | Skill screen, permit skill, no systems open
No systems available yet.
NOT_SHIP_BOUGHT | 110 | Notice, ship bought
Ship bought. It is free for a route.
NOT_SHIP_FREE | 110 | Notice, no free ship
No ship available. Buying one needs more cash.
NOT_DEAD_RESCUE | 110 | Notice, rescue notice
Rescue notice: the Bureau grants {amount} credits, enough for a ship. Start again.
NOT_EVENT_PREFIX | 24 | Event popup heading | News from the sky
NOT_SAVED | 110 | Notice | Game saved.
NOT_ROUTE_MADE | 110 | Notice, route made | Route made: {planet_a} to {planet_b}.
NOT_ROUTE_REMOVED | 110 | Notice, route removed | Route removed: {planet_a} to {planet_b}.
LBL_LANE_SHIP | 24 | Connections list, a ship's place on a shared route; the game adds "k of N" | Ship
NOT_LANE_SHIP_ADDED | 110 | Notice, a ship added to an existing route | Ship added to the route.
NOT_RESUMED | 110 | Notice, game unpaused | Running.
NOT_PAUSED | 110 | Notice | Paused. Nothing earns while paused.

## Systems and system 2 (T86; names are proposals, owner decides)
WORLD_SYS1_NAME | 24 | System 1 name, map and system labels | Hollin Reach
WORLD_SYS1_DESC | 110 | System 1, map tooltip | Three planets, two goods. Voltara burns, Tillam and Ashgate eat.
WORLD_SYS2_NAME | 24 | System 2 name, map and system labels | Dunmere Reach
WORLD_SYS2_DESC | 110 | System 2, permit screen and map tooltip | Four planets, farther out. Fields and reactors on one side, a hungry market on the other.
WORLD_S2P1_NAME | 24 | System 2 planet 1 (S2-P1, food-rich hub) | Brannock
WORLD_S2P1_DESC | 110 | Planet 1 of system 2, planet tooltip | Grain terraces and a busy dock. Brannock has food to spare and a permanent shortage of power.
WORLD_S2P2_NAME | 24 | System 2 planet 2 (S2-P2, energy-rich) | Cindrel
WORLD_S2P2_DESC | 110 | Planet 2 of system 2, planet tooltip | A planet of reactors that hum all night. Cindrel has energy to spare and kitchens that want filling.
WORLD_S2P3_NAME | 24 | System 2 planet 3 (S2-P3, food-rich outpost) | Mossfell
WORLD_S2P3_DESC | 110 | Planet 3 of system 2, planet tooltip | A damp outpost of vats and sheds. Mossfell grows food and counts its power in candles.
WORLD_S2P4_NAME | 24 | System 2 planet 4 (S2-P4, consumer market) | Quillon
WORLD_S2P4_DESC | 110 | Planet 4 of system 2, planet tooltip | A market world that makes nothing and wants both goods. Quillon pays on time, in forms.
PERMIT_S2_NAME | 24 | Permit list, system 2 entry | Permit: Dunmere Reach
PERMIT_S2_DESC | 110 | Permit list, system 2 description | Opens Dunmere Reach for routes. Needs Permit Charter. Costs credits and skill points.
PERMIT_S2_BTN | 24 | Permit list, buy button | Buy permit
NOT_PERMIT_S2 | 110 | Notice, permit for system 2 bought | Permit bought. Dunmere Reach is open: four new planets.
SS_POST_NAME | 24 | Space Storage post, name | Space Storage
SS_POST_DESC | 110 | Space Storage post, one-line description | A buffer for the whole system. Company storage feeds it slowly. It holds goods and adds no flow.

## Tutorial: galaxy view (T119; shown once, the first time the galaxy view opens after system 2 is open)
TUT_GALAXY_INTRO | 110 | Galaxy view, first open
This is the galaxy view. It shows the systems you have explored and the links between them.
TUT_GALAXY_INTRO_WHY | 110 | Galaxy view, why line
Each system is its own market. Seeing them side by side shows where to grow next.
TUT_GALAXY_ICONS | 110 | Galaxy view, after intro
The icons beside each system show the resources found there.
TUT_GALAXY_ICONS_WHY | 110 | Galaxy view, why line
A system that has what another lacks is where a route pays best.
TUT_GALAXY_ROUTES | 110 | Galaxy view, after icons
Your own trade routes are drawn on the map. Click a system to open it.
TUT_GALAXY_ROUTES_WHY | 110 | Galaxy view, why line
Open a system to set up buy, send and sell orders there.

## Labels 2 (2026-10-28; fallback texts replaced)
LBL_SHIP_SMALL | 24 | Ship type name, small ship (working name, owner to confirm) | Skerrit
NOT_EVENT_EFFECT_UP | 90 | Event popup, effect line, price up | Prices for {commodity} at {planet} rise {pct} percent for {cycles} cycles.
NOT_EVENT_EFFECT_DOWN | 90 | Event popup, effect line, price down | Prices for {commodity} at {planet} fall {pct} percent for {cycles} cycles.
NOT_EVENT_EFFECT_CLOSED | 90 | Event popup, effect line, closed planet | {planet} is closed for {cycles} cycles. Routes and orders touching it stop.
NOT_EVENT_EFFECT_CASH | 90 | Event popup, effect line, one-off cash change | Your cash changes once by {amount}.
NOT_EVENT_EFFECT_STOCK | 90 | Event popup, effect line, one-off stock change | {commodity} stock at {planet} changes once by {amount}.
LBL_EVENT_FEED | 24 | Notification board, event feed heading | Recent events
LBL_PAUSED | 24 | Top bar state label, game paused | Paused
LBL_RUNNING | 24 | Top bar state label, game running | Running
LBL_GAME_OVER | 24 | End screen header area, run lost | Game over
LBL_MAIN_RESOURCES | 24 | System panel, heading above the resource row (stock sell prices of main commodities) | Main resources

## Fallback texts closed (2026-10-31, Alpha)
These ids were read with a plain English fallback in game/. Now they come from story text, so the voice matches the rest.
MENU_GALAXY | 24 | Game rail button tooltip, galaxy view (shown once system 2 is open) | Galaxy
MENU_HINT_LOCKED | 110 | Game menu, tooltip on a locked entry | Not available yet.
BTN_CLOSE | 24 | Galaxy view, close button | Close
EVT_HINT_CHOICE_OFF | 110 | Event popup, tooltip on a choice that cannot be taken now | Not available now.
PERMIT_COST_LINE | 110 | Skill screen, permit cost line; {credits} and {points} are filled in | Cost: {credits} credits and {points} skill points.
PERMIT_NEEDS_C1 | 110 | Skill screen, permit line when the Permit Charter foundation is missing | Needs Permit Charter to buy permits.
PERMIT_NO_CREDITS | 110 | Skill screen, permit line when credits are short | Not enough credits.

## Skill effects made real (2026-10-31, Alpha): Event Forecast, Price Whisper, base-game price history
NOT_ROUTE_NEEDS_C3 | 110 | Route between two systems without the Permit Charter foundation | Routes between systems need Permit Charter.
EVT_NEXT_DUE | 110 | Notice, Event Forecast, posted one cycle before an event | An event is due next cycle.
EVT_NEXT_DUE_PRICE | 110 | Notice, Event Forecast, price event due next cycle; direction is "rise" or "fall" | Next cycle: {commodity} will {direction} at {planet}.
EVT_NEXT_DUE_CLOSED | 110 | Notice, Event Forecast, closure due next cycle | Next cycle: {planet} will close.
LBL_BEST_PARTNER | 110 | Planet panel, Price Whisper, best route partner | Best partner: {planet} ({margin} cr per unit).
NOT_ROUTE_BELOW_UPKEEP | 110 | Notice, base game, new route margin is below its upkeep | This route earns {margin} cr a cycle and costs {cost}. It will run at a loss.
LBL_PRICE_HISTORY | 110 | Planet panel, base game, under the prices; {prices} is a list of sell prices | Recent sell prices: {prices}.
LBL_PRICE_HISTORY_NONE | 110 | Planet panel, base game, before the first cycle closes | Recent sell prices: none yet.
LBL_NEXT_PRICE | 110 | Planet panel, Price Whisper, prices for the next cycle; {buy} and {sell} are credits | Next cycle: {buy} cr to buy, {sell} cr to sell.

## Last fallbacks (2026-10-31, Alpha)
LBL_UNKNOWN | 24 | Galaxy view, label for a system not yet permitted | ?
PLANET_UNHAPPY | 110 | Planet panel, resident unhappiness line when above zero; {value} is a percent | Resident unhappiness: {value}

## Skill point pop-up (2026-10-31, owner item 5)
NOT_SKILL_POP_TITLE | 32 | Pop-up title when expansion points are earned; {points} is the number earned | Skill point earned: +{points}

## Guided first steps (T124, 2026-10-31, owner item 3; shown one at a time, each moves on when done)
TUT_G1_SELECT | 60 | Guided step 1, until a planet is clicked | Click the ringed planet.
TUT_G1_SELECT_WHY | 110 | Guided step, why it matters (second line of the card) | Its panel shows what it sells, what it buys and what the company can trade there.
TUT_G2_BUY | 60 | Guided step 2, until Buy is on for a good | Press Buy on a good you want to trade.
TUT_G2_BUY_WHY | 110 | Guided step, why it matters (second line of the card) | A Buy order fills your storage on this planet each cycle.
TUT_G3_SEND | 60 | Guided step 3, until a route exists | Right-click the resource, choose Send to.
TUT_G3_SEND_WHY | 110 | Guided step, why it matters (second line of the card) | Pick a planet that wants the good. A route carries your goods there by ship.
TUT_G4_ROUTE_PAY | 60 | Guided step 4, until a route has sold goods | Let the route sell at the destination.
TUT_G4_ROUTE_PAY_WHY | 110 | Guided step, why it matters (second line of the card) | The route earns when it sells there. That is where your money comes from.
TUT_G5_UPKEEP | 60 | Guided step 5, after a ship is working | Find Ship upkeep under Expenses.
TUT_G5_UPKEEP_WHY | 110 | Guided step, why it matters (second line of the card) | A ship costs money every cycle, so a route must earn more than it costs.
TUT_G6_SELL | 60 | Guided step 6, until the first Sell order | Right-click the resource there, choose Sell.
TUT_G6_SELL_WHY | 110 | Guided step, why it matters (second line of the card) | A Sell order turns your stock into credits.
TUT_G7_STORAGE | 60 | Guided step 7, storage | Watch stored/capacity on the resource button.
TUT_G7_STORAGE_WHY | 110 | Guided step, why it matters (second line of the card) | Company storage holds your goods on a planet. When it is full, Buy waits.
TUT_G8_SKILLS | 60 | Guided step 8, until a skill is learned | Open Skills and learn one.
TUT_G8_SKILLS_WHY | 110 | Guided step, why it matters (second line of the card) | Spend an expansion point. Skills unlock bigger storage, longer routes and the permit.
TUT_G9_PERMIT | 60 | Guided step 9, permits | Learn Permit Charter.
TUT_G9_PERMIT_WHY | 110 | Guided step, why it matters (second line of the card) | It lets you open a new system, and a new system has more planets to trade with.
TUT_G10_DONE | 60 | Guided step 10, the last | Goal: hold over half of one market.
TUT_G10_DONE_WHY | 110 | Guided step, why it matters (second line of the card) | Open Competitors to see shares. Market chain choices change your rivals.
TUT_HEADER | 24 | Header of the guided tutorial card | Tutorial
TUT_STEP_COUNT | 24 | Tutorial card, step counter; {n} is the step, {total} the number of steps | {n} of {total}

## Map edge arrow (T128, owner item 7)
MAP_ARROW_PERMIT | 50 | Tooltip of the arrow at the edge of the 3D map when a permit or system can be opened; click opens Skills with the steps lit | A new system is within reach. Open Skills.
MAP_ARROW_SYSTEM | 50 | Tooltip of the same arrow once the permit is held; click moves the view to the other system | Go to the other system.

## Market, route and salvage labels (added 2026-11-02)
LBL_PRICE_EVENT | 40 | Planet market row, during a price event; {arrow} is the price direction | {arrow} Event, {cycles} cycles left
LBL_BEST_OPEN_ROUTE | 50 | Blocked route row, when an event closes a planet; {n} is net profit per cycle | Best open route: +{n} per cycle
LBL_SETUP_LOST | 60 | Move ship warning, only when a setup is really lost by moving | Moving loses this setup.
BTN_MOVE_SHIP | 24 | Blocked route row, moves the ship to the best open route | Move to best route
LBL_STORAGE_EMPTY | 110 | Commodity row warning, when company storage there is empty | Storage empty. Send to... will wait for stock.
LBL_SALVAGE_NO_BUYER | 110 | Sell row, salvage line, no buyer | Salvage: {n} now (no buyer on your lanes). Sell order pays {m}.
LBL_SALVAGE_STORAGE_FULL | 110 | Sell row, salvage line, storage full | Salvage: {n} now (storage full). Sell order pays {m}.
BTN_SALVAGE | 24 | Sell row, salvage button | Salvage
LBL_SALVAGE_NA | 110 | Notice, when salvage is not available | Salvage is not offered now.
LBL_MIXED_LOAD | 70 | Route row, mixed load bonus | Mixed load +{n}% (max {cap} credits)
LBL_MARGIN_NOW | 70 | Planet market row, current margin | {planet}: margin {now} per unit
LBL_MARGIN_AFTER_EVENT | 90 | Planet market row, margin during an event | {planet}: margin {now} per unit now, {after} after the event

## Space Storage station (added 2026-11-02)
LBL_STATION_BUILT | 80 | Notice, after a Space Storage station is built | Space station built. Click it to open Space Storage.
LBL_STATION_MARKER | 32 | Map marker label above a station | Space Storage
TIP_STATION_MARKER | 32 | Map marker tooltip | Space Storage
LBL_TRADE_NEEDS_STATION | 60 | Buy, Sell or Send to button in a system without its station | Needs a Space Storage in this system.

## Locked skills and Space Storage view (added 2026-11-02)
SS_BTN_CLOSE | 16 | Space Storage view, close button | Close
SS_LBL_CAPACITY | 48 | Space Storage view, capacity line | Capacity: {cap} per commodity

## Route end names (added 2026-11-02)
LBL_SPACE_STORAGE_NAME | 32 | Route row, name of the station end of a route | Space Storage

## Storage projection (added 2026-11-03)
LBL_NEXT_CYCLE | 48 | Storage view, projected stock after the next cycle | Next cycle: +{in} -{out} = {after}

## New goods and asteroid clusters (T154, 2026-11-02; names are working names, owner decides)
GOOD_SILK_NAME | 24 | Commodity name, silk | Starsilk
GOOD_SILK_DESC | 110 | Commodity tooltip, silk | Light, costly cloth. Made at Tillam. Voltara pays the most for it.
GOOD_CHIPS_NAME | 24 | Commodity name, chips | Logic Cores
GOOD_CHIPS_DESC | 110 | Commodity tooltip, chips | Small machine minds. Made at Voltara. Ashgate pays the most for them.
GOOD_ORE_NAME | 24 | Commodity name, ore | Rock Ore
GOOD_ORE_DESC | 110 | Commodity tooltip, ore | Raw rock from asteroid clusters. Free to take. Voltara pays the most for it.
WORLD_CL_S1A_NAME | 24 | Asteroid cluster 1 of system 1, map label | Cinder Shoal
WORLD_CL_S1A_DESC | 110 | Cluster 1 of system 1, tooltip | A dark drift of rock between the planets. It holds only so much, and then it is gone.
WORLD_CL_S1B_NAME | 24 | Asteroid cluster 2 of system 1, map label | Pale Drift
WORLD_CL_S1B_DESC | 110 | Cluster 2 of system 1, tooltip | A loose pack of pale rock. The Bureau has not counted it. It will not be counted twice.
WORLD_CL_S2A_NAME | 24 | Asteroid cluster 1 of system 2, map label | Gantry Scatter
WORLD_CL_S2A_DESC | 110 | Cluster 1 of system 2, tooltip | Rock around an old gantry no one claims. Ore is free here for as long as it lasts.
WORLD_CL_S2B_NAME | 24 | Asteroid cluster 2 of system 2, map label | Old Tally
WORLD_CL_S2B_DESC | 110 | Cluster 2 of system 2, tooltip | A pack of rock marked with old counting stripes. The counting stopped. The ore did not.
WORLD_CL_S2C_NAME | 24 | Asteroid cluster 3 of system 2, map label | Low Teeth
WORLD_CL_S2C_DESC | 110 | Cluster 3 of system 2, tooltip | Jagged rock low in the sky of Dunmere Reach. Take the ore before the cluster runs dry.

## Owner labels: skill rows, cluster card, route legend (added 2026-11-02)
LBL_CLUSTER_NAME | 32 | Cluster card title and route end, cluster without its own name; fills {id} | Asteroid cluster {id}
LBL_CLUSTER_LEFT | 60 | Planet panel, cluster line; fills {id}, {left}, {max} | Ore cluster {id}: {left} of {max} left
LBL_CLUSTER_INFO | 80 | Cluster card, info line; fills {good}, {yield}, {left}, {max} | {good}: {yield} per cycle, {left} of {max} left.
LBL_CLUSTER_INFO_YIELD | 60 | Cluster card, info line when mining is locked; fills {good}, {yield} | {good}: {yield} per cycle.
NOT_MINING_NEEDS_SKILL | 110 | Notice and cluster card, mining is locked | Mining needs the Prospecting skill.
NOT_CLUSTER_ONLY_ORE | 110 | Notice, route from a cluster with a good other than ore | A cluster gives ore only.
NOT_CLUSTER_EMPTY | 110 | Notice, route from an empty cluster | This cluster is empty.
ST_CLUSTER_EMPTY | 60 | Route panel, status when the cluster has run dry | Cluster empty
ST_CLUSTER_SHARED | 60 | Route panel, status when another ship took the cycle's ore | Ore taken by another ship
LBL_LEGEND_SILK | 24 | Route legend, silk line | Starsilk route
LBL_LEGEND_CHIPS | 24 | Route legend, chips line | Logic Cores route
LBL_LEGEND_ORE | 24 | Route legend, ore line | Rock Ore route

## Dead worlds: unlock, goods, Null Core (added 2026-11-03; names are working names, owner decides)
DEAD_UNLOCK | 110 | Notice, posted when the dead worlds open | Dead worlds are open. Cinderrest needs Cold Survey, Greywake needs Deep Cut.
PLANET_DEAD_LOCKED | 60 | Planet panel, dead world before it opens; {n} is the cycle | Opens at cycle {n}.
NOT_DEAD_NEEDS_SKILL | 110 | Notice, route from a dead world without its skill; {skill} is the skill name | Mining here needs {skill}.
GOOD_DROSS_NAME | 24 | Commodity name, dross | Dross Salt
GOOD_DROSS_DESC | 110 | Commodity tooltip, dross | Grey salt cut on Cinderrest. Sold at the trading post, and fed to the fabric.
GOOD_NULLGLASS_NAME | 24 | Commodity name, nullglass | Nullglass
GOOD_NULLGLASS_DESC | 110 | Commodity tooltip, nullglass | Dark glass cut on Greywake. Sold at the trading post, and fed to the fabric.
GOOD_PLATE_NAME | 24 | Commodity name, plate | Lattice Plate
GOOD_PLATE_DESC | 110 | Commodity tooltip, plate | Pressed at the fabric from dross and nullglass. Needed for a Null Core.
NULL_CORE_BUILD_TITLE | 32 | Popup title, first Null Core built (one per run) | The core is built
NULL_CORE_BUILD | 280 | Popup text, first Null Core built (one per run) | The Null Core sat in its cradle and gave off no heat at all. Fitted, it makes one hull quiet in a way hulls are not. Nobody can say what it listens to. The Bureau has filed it under spare parts.
NULL_CORE_FIT | 110 | Ships window, label or tooltip of the fitted ship | Null Core fitted. Lower Trip cost, and pirates cannot touch this ship.


## Null Core buttons and labels (added 2026-11-03)
BTN_FIT_NULL_CORE | 24 | Ships window, fit button on a route; {n} is the route or ship number | Fit Null Core, ship {n}
LBL_NULL_CORE | 24 | Ships window, label of the fitted ship | Null Core
LBL_NULL_CORE_BUILT | 24 | Space Storage window, state once the core exists | Null Core built
SS_NULL_CORE_BUILD | 24 | Space Storage window, build button; {cost} is the credit cost (fits the 24 limit) | Build Null Core: {cost}

## Lane and fabric notices (added 2026-11-03)
LBL_TRADE_NEEDS_A1 | 60 | Stalled system 2 lane when Space Storage is not learned | Learn Space Storage first.
SS_FABRIC_NO_INPUTS | 110 | Space Storage panel, fabric lacks inputs; {items} lists the missing goods | Missing inputs: {items}. Send them here from a dead world.

## Ship purchase refusal (added 2026-11-03)
NOT_SHIP_KEEP_CASH | 110 | Ships panel and Buy ship tooltip, purchase refused to keep cash for open routes; {floor} is the cash that must stay | Not enough spare cash. Keep {floor} credits to run your routes.

## Tutorial panels and game tips (2026-11-03, owner: tutorial beside its button, right board for tips only)
LBL_TIPS | 24 | Right board title, game tips | Tips
BTN_SKIP_TUTORIAL | 24 | Tutorial card and galaxy view tutorial, ends the whole tutorial | Skip tutorial
TIP_BOARD_1 | 110 | Tips board, rotates one per cycle | A route should earn more than its ship costs in upkeep. Check Expenses.
TIP_BOARD_2 | 110 | Tips board | Routes are one way. To send stock both ways, make a second route back.
TIP_BOARD_3 | 110 | Tips board | When Company storage is full, Buy waits. Sell or send stock on to make room.
TIP_BOARD_4 | 110 | Tips board | Prices change each cycle. Open a planet to see today's Buy and Sell prices.
TIP_BOARD_5 | 110 | Tips board | Space pauses the game. Pause to plan, then press Space again.
TIP_BOARD_6 | 110 | Tips board | Skill points come from planets, routes and systems. Spend them in Skills (K).

## Market share readout (UI fallback ids, added 2026-11-03)
LBL_SHARE_TITLE | 24 | Market share panel heading | Market share
LBL_SHARE_HOLD | 40 | Market share panel, cycles the player has held the lead | Held {n} of {total} cycles
LBL_SPREAD_COST | 40 | Market panel, cost of holding several markets | Spreading cost per cycle: {n}
LBL_SHARE_YOU | 24 | Market share rows and end screen readout, the player's row | You

## Competitors menu (added 2026-11-03)
LBL_COMP_TITLE | 24 | Competitors menu heading, game menu entry and share panel button | Competitors
LBL_COMP_SHARE | 24 | Competitors table column, current market share | Share
LBL_COMP_TREND | 24 | Competitors table column, change over the last 5 cycles | Last 5 cycles

## Four-market skill screen (added 2026-11-03; labels plain, no flavour)
SK_TAB_FND | 24 | Skill screen, tab or column title | Foundations
SK_TAB_MIL | 24 | Skill screen, tab or column title | Military
SK_TAB_LUX | 24 | Skill screen, tab or column title | Luxury
SK_TAB_MIN | 24 | Skill screen, tab or column title | Minerals
SK_TAB_BIO | 24 | Skill screen, tab or column title | Biotech
SK_KIND_SKILL | 24 | Skill screen, node kind tag for a skill | Skill
SK_KIND_TECH | 24 | Skill screen, node kind tag for a tech | Tech
SK_CRAFTED | 40 | Skill screen, tech progress, {n} units made, {goal} units needed | Crafted {n} of {goal}
SK_LOCKED_NEEDS | 60 | Skill screen, detail panel of a locked node | Locked: needs {name}
SK_NOT_ENOUGH | 40 | Skill screen, Learn button or detail panel when points are short | Not enough points
SK_POINTS_COUNTER | 40 | Skill screen and top bar, points counter | Skill points: {n}
SK_TECH_DONE | 110 | Notice when a tech completes | Tech finished: {name}.
SK_TECH_NO_POINTS | 110 | Detail panel of a tech node | A tech costs no points. It finishes by crafting.
MKT_MIL_ID | 110 | Market identity line, tab tooltip or Competitors panel | Steady buyers and big volume. The only market where you can hit a rival directly.
MKT_LUX_ID | 110 | Market identity line | Few units and huge price swings. Timing and events win it.
MKT_MIN_ID | 110 | Market identity line | Bulk, mining and smelting. Slow to build and hard to dislodge.
MKT_BIO_ID | 110 | Market identity line | Slow compounding. Labs and stored stock grow over time, and events can hurt.

## Workshops (added 2026-11-03)
WS_SMELTER_NAME | 30 | Workshop name, planet panel and notices | Smelter
WS_MUNITIONS_NAME | 30 | Workshop name, planet panel and notices | Munitions Line
WS_ATELIER_NAME | 30 | Workshop name, planet panel and notices | Atelier
WS_CULTURE_LAB_NAME | 30 | Workshop name, planet panel and notices | Culture Lab
LBL_WORKSHOPS | 30 | Planet panel, title of the workshop section | Workshops
BTN_WORKSHOP_BUILD | 50 | Planet panel, build button; {workshop} name, {cost} credits | Build {workshop} ({cost} cr)
LBL_WORKSHOP_BATCHES | 50 | Planet panel, built workshop; {n} batches each cycle | Batches this cycle: {n}
LBL_WORKSHOP_MADE | 60 | Planet panel, built workshop; {items} is what the last cycle made | Last cycle: {items}
LBL_WORKSHOP_STALLED | 60 | Planet panel, built workshop that made nothing; {why} is the missing input | Stalled: {why}
NOT_WORKSHOP_BUILT | 80 | Board notice after building; {workshop} is the workshop name | {workshop} built at the trading post.

## Skill points from share (added 2026-11-03)
NOT_SKILL_REASON_SHARE | 110 | Notice, a skill point earned when a market share passes a step; {market} is the market, {pct} the step | Your {market} share passed {pct}%.

## Market chains (28 steps; added 2026-11-03, from design/proposals/2026-11-03-four-markets-story.md)
Chain text for Military, Luxury, Minerals and Biotech, steps A1 to A3 and B1 to B4. Ids: EV_<step>_<field>, for example EV_MIL_A1_TITLE. Fields: TITLE, BODY (A1 and B1) or BODY_A and BODY_B (steps 2 and later, keyed to the option picked in the previous step of the same chain), OPA_BTN, OPA_EFF, OPA_RES_TITLE, OPA_RES, OPA_STD, OPA_STD2 (second rival line, only where the option has two), and the same for OPB. The placeholders are documented at the top of story/events.md, section "Chain placeholders". Option ids opt_a and opt_b are internal; the game may shuffle the button order. No text states a direction, a count or a stance.

### MIL_A1 (Military, chain A, step 1)
EV_MIL_A1_TITLE | 40 | MIL_A1 choice screen title | A garrison offers a standing contract
EV_MIL_A1_BODY | 280 | MIL_A1 choice screen body (one body) | A garrison on Ashgate's high ring has bought your first Military cargo and wants more. The quartermaster offers a standing contract, or a sale by the lot. {bot1} supplies the garrison today and stands to lose ground either way. The ink on the form is still wet.
EV_MIL_A1_OPA_BTN | 28 | MIL_A1 button, opt_a | Sign the contract
EV_MIL_A1_OPA_EFF | 200 | MIL_A1 effect line, opt_a | Get: Military volume up a little for a while. Cost: {cash_out} credits as the deposit to the garrison. Rivals: {bot1}'s Military growth falls a little.
EV_MIL_A1_OPA_RES_TITLE | 32 | MIL_A1 result popup title, opt_a | The contract is signed
EV_MIL_A1_OPA_RES | 280 | MIL_A1 result popup, opt_a; {bot} is bot_1 | The garrison signed and kept its old supplier as a second source. Your orders now arrive on a schedule, and the deposit is paid. {bot}'s Military growth falls a little. The quartermaster filed the page twice. The ink dried the colour of rust.
EV_MIL_A1_OPA_STD | 90 | MIL_A1 rival line 1, opt_a | {bot1}, Military: growth down a little.
EV_MIL_A1_OPB_BTN | 28 | MIL_A1 button, opt_b | Sell by the lot
EV_MIL_A1_OPB_EFF | 200 | MIL_A1 effect line, opt_b | Get: {cash_in} credits now. Cost: Military volume down a little for a few cycles; {bot3} gains a little Military strength. Rivals: {bot1}'s Military strength falls a little.
EV_MIL_A1_OPB_RES_TITLE | 32 | MIL_A1 result popup title, opt_b | Sold by the lot
EV_MIL_A1_OPB_RES | 280 | MIL_A1 result popup, opt_b; {bot} is bot_1 | The garrison bought the whole cargo and paid at the dock. Your own orders dipped for a few cycles while the berth stood empty, and {bot3} filled the berth and gains a little Military strength. {bot}'s Military strength falls a little.
EV_MIL_A1_OPB_STD | 90 | MIL_A1 rival line 1, opt_b | {bot1}, Military: strength down a little.
EV_MIL_A1_OPB_STD2 | 90 | MIL_A1 rival line 2, opt_b | {bot3}, Military: strength up a little.

### MIL_A2 (Military, chain A, step 2)
EV_MIL_A2_TITLE | 40 | MIL_A2 choice screen title | Two fleets ask for the same stock
EV_MIL_A2_BODY_A | 280 | MIL_A2 choice screen body after opt_a of MIL_A1 | Your standing contract with the garrison is in force. Two fleets at a border post, which do not speak, ask for the same stock in the same cycle. {bot1} serves one of them. {bot3} carries the messages. Orders can be filled in dock order, or by contract term.
EV_MIL_A2_BODY_B | 280 | MIL_A2 choice screen body after opt_b of MIL_A1 | You sold the garrison its cargo by the lot. Two fleets at a border post, which do not speak, ask for the same stock in the same cycle. {bot1} serves one of them. {bot3} carries the messages. Orders can be filled in dock order, or by contract term.
EV_MIL_A2_OPA_BTN | 28 | MIL_A2 button, opt_a | Fill orders by dock
EV_MIL_A2_OPA_EFF | 200 | MIL_A2 effect line, opt_a | Get: Military price up a little for a while. Cost: Ship upkeep rises a little for a while. Rivals: {bot3}'s Military growth falls a little.
EV_MIL_A2_OPA_RES_TITLE | 32 | MIL_A2 result popup title, opt_a | Orders filled by dock
EV_MIL_A2_OPA_RES | 280 | MIL_A2 result popup, opt_a; {bot} is bot_3 | Orders went out in dock order, and both fleets were supplied, each told the other had been too. Your hulls keep two sets of berths, so Ship upkeep rises for a while. {bot}, the go-between, finds the post needs one less, and its Military growth falls a little.
EV_MIL_A2_OPA_STD | 90 | MIL_A2 rival line 1, opt_a | {bot3}, Military: growth down a little.
EV_MIL_A2_OPB_BTN | 28 | MIL_A2 button, opt_b | Fill orders by term
EV_MIL_A2_OPB_EFF | 200 | MIL_A2 effect line, opt_b | Get: {n} units of tech progress at the Munitions Line. Cost: {cash_out} credits for the stock. Rivals: {bot1} {cut} in Military.
EV_MIL_A2_OPB_RES_TITLE | 32 | MIL_A2 result popup title, opt_b | Orders filled by term
EV_MIL_A2_OPB_RES | 280 | MIL_A2 result popup, opt_b; {bot} is bot_1 | Orders went out by contract term, and the fleet that {bot1} does not serve held the better terms. Its engineers left their notes on your bench. {bot}'s client fell behind its own line, and {bot} was cut back in Military. The stock cost you.
EV_MIL_A2_OPB_STD | 90 | MIL_A2 rival line 1, opt_b | {bot1}, Military: {cut_std}.

### MIL_A3 (Military, chain A, step 3)
EV_MIL_A3_TITLE | 40 | MIL_A3 choice screen title | A quartermaster sells a ledger
EV_MIL_A3_BODY_A | 280 | MIL_A3 choice screen body after opt_a of MIL_A2 | Your orders went out in dock order. The post's quartermaster waits at the dock with a case. In it is {bot1}'s ledger of clients, prices and berths, copied by hand. He names a price, and says a ledger is only a list until someone reads it.
EV_MIL_A3_BODY_B | 280 | MIL_A3 choice screen body after opt_b of MIL_A2 | Your orders went out by contract term. The post's quartermaster waits at the dock with a case. In it is {bot1}'s ledger of clients, prices and berths, copied by hand. He names a price, and says a ledger is only a list until someone reads it.
EV_MIL_A3_OPA_BTN | 28 | MIL_A3 button, opt_a | Hand it to your buyers
EV_MIL_A3_OPA_EFF | 200 | MIL_A3 effect line, opt_a | Get: {cash_in} credits; Military volume up a little for a while. Cost: Ship upkeep up a little for a while; {bot3} gains a little Military strength. Rivals: {bot1}'s Military strength falls clearly.
EV_MIL_A3_OPA_RES_TITLE | 32 | MIL_A3 result popup title, opt_a | The ledger goes to buyers
EV_MIL_A3_OPA_RES | 280 | MIL_A3 result popup, opt_a; {bot} is bot_1 | Your buyers read the ledger and called on the clients it listed. Cash came in and orders rose, and the extra hulls raise Ship upkeep a little for a while. {bot}'s Military strength falls clearly. The case was copied twice, and one copy reached {bot3}.
EV_MIL_A3_OPA_STD | 90 | MIL_A3 rival line 1, opt_a | {bot1}, Military: strength down clearly.
EV_MIL_A3_OPA_STD2 | 90 | MIL_A3 rival line 2, opt_a | {bot3}, Military: strength up a little.
EV_MIL_A3_OPB_BTN | 28 | MIL_A3 button, opt_b | Hand it to your workshop
EV_MIL_A3_OPB_EFF | 200 | MIL_A3 effect line, opt_b | Get: {n} units of tech progress at the Munitions Line. Cost: {cash_out} credits to the quartermaster. Rivals: {bot1}'s Military strength and {bot3}'s Military growth fall a little.
EV_MIL_A3_OPB_RES_TITLE | 32 | MIL_A3 result popup title, opt_b | The ledger goes to the shop
EV_MIL_A3_OPB_RES | 280 | MIL_A3 result popup, opt_b; {bot} is bot_1 | Your workshop read the ledger and compared its parts and casting notes with your own. Tech progress came in. {bot}'s Military strength falls a little, and {bot3}, whose orders were listed too, grows more slowly. You paid the quartermaster.
EV_MIL_A3_OPB_STD | 90 | MIL_A3 rival line 1, opt_b | {bot1}, Military: strength down a little.
EV_MIL_A3_OPB_STD2 | 90 | MIL_A3 rival line 2, opt_b | {bot3}, Military: growth down a little.

### MIL_B1 (Military, chain B, step 1)
EV_MIL_B1_TITLE | 40 | MIL_B1 choice screen title | A fleet needs a refit fast
EV_MIL_B1_BODY | 280 | MIL_B1 choice screen body (one body) | A fleet on the high ring must be refitted before the next treaty review, and every drydock is booked. The admiral will pay for berths. {bot1} holds most of them, and {bot3} counts on the spare slips. Hull plates wait in the dark.
EV_MIL_B1_OPA_BTN | 28 | MIL_B1 button, opt_a | Take the main berths
EV_MIL_B1_OPA_EFF | 200 | MIL_B1 effect line, opt_a | Get: {cash_in} credits now. Cost: Ship upkeep rises clearly for a while. Rivals: {bot1}'s Military strength falls sharply.
EV_MIL_B1_OPA_RES_TITLE | 32 | MIL_B1 result popup title, opt_a | The berths are taken
EV_MIL_B1_OPA_RES | 280 | MIL_B1 result popup, opt_a; {bot} is bot_1 | You took the berths that {bot1} held and refitted the fleet there. The admiral paid at once. Your ships ran extra shifts, and Ship upkeep rises for a while. {bot}'s slips stand empty and its Military strength falls sharply. The plates were still warm when signed for.
EV_MIL_B1_OPA_STD | 90 | MIL_B1 rival line 1, opt_a | {bot1}, Military: strength down sharply.
EV_MIL_B1_OPB_BTN | 28 | MIL_B1 button, opt_b | Take the spare slips
EV_MIL_B1_OPB_EFF | 200 | MIL_B1 effect line, opt_b | Get: Military volume up a little for the rest of the run. Cost: {cash_out} credits for the slips. Rivals: {bot3}'s Military growth falls a little.
EV_MIL_B1_OPB_RES_TITLE | 32 | MIL_B1 result popup title, opt_b | The spare slips are taken
EV_MIL_B1_OPB_RES | 280 | MIL_B1 result popup, opt_b; {bot} is bot_3 | You paid for the spare slips that {bot3} had counted on and refitted the fleet there. The slips are yours to keep, so your Military volume rises. {bot}'s Military growth falls a little. The plates came back with a faint ring in them.
EV_MIL_B1_OPB_STD | 90 | MIL_B1 rival line 1, opt_b | {bot3}, Military: growth down a little.

### MIL_B2 (Military, chain B, step 2)
EV_MIL_B2_TITLE | 40 | MIL_B2 choice screen title | A treaty office queries a part
EV_MIL_B2_BODY_A | 280 | MIL_B2 choice screen body after opt_a of MIL_B1 | You refitted at the berths {bot1} held, and a treaty office queries one fitting in the batch. It will review every fleet that carries the part. You may send the part for review, or swap it and refile. {bot2}'s parade squadrons carry it. So do {bot1}'s older fleets.
EV_MIL_B2_BODY_B | 280 | MIL_B2 choice screen body after opt_b of MIL_B1 | You refitted at the spare slips, and a treaty office queries one fitting in the batch. It will review every fleet that carries the part. You may send the part for review, or swap it and refile. {bot2}'s parade squadrons carry it. So do {bot1}'s older fleets.
EV_MIL_B2_OPA_BTN | 28 | MIL_B2 button, opt_a | Send the part for review
EV_MIL_B2_OPA_EFF | 200 | MIL_B2 effect line, opt_a | Get: Military price up a little for a while. Cost: one route's trip cost rises a little for a while. Rivals: {bot2}'s Military strength falls a little.
EV_MIL_B2_OPA_RES_TITLE | 32 | MIL_B2 result popup title, opt_a | The office reviews the part
EV_MIL_B2_OPA_RES | 280 | MIL_B2 result popup, opt_a; {bot} is bot_2 | You sent the part for review. The office read your forms, then everyone else's. {bot}, whose parade squadrons carry the same part, lost contracts, and its Military strength falls a little. The cleared stamp lifts prices for a while. One route sat in a queue.
EV_MIL_B2_OPA_STD | 90 | MIL_B2 rival line 1, opt_a | {bot2}, Military: strength down a little.
EV_MIL_B2_OPB_BTN | 28 | MIL_B2 button, opt_b | Swap the part and refile
EV_MIL_B2_OPB_EFF | 200 | MIL_B2 effect line, opt_b | Get: {cash_in} credits for the old part. Cost: Military volume down a little for a few cycles. Rivals: {bot1}'s Military strength falls a little.
EV_MIL_B2_OPB_RES_TITLE | 32 | MIL_B2 result popup title, opt_b | The part is swapped
EV_MIL_B2_OPB_RES | 280 | MIL_B2 result popup, opt_b; {bot} is bot_1 | You swapped the part, sold the old one and refiled. The office read {bot1}'s older fleets under the same clause. {bot}'s Military strength falls a little, and its fleets stood idle for the review. Your ships waited for new fittings.
EV_MIL_B2_OPB_STD | 90 | MIL_B2 rival line 1, opt_b | {bot1}, Military: strength down a little.

### MIL_B3 (Military, chain B, step 3)
EV_MIL_B3_TITLE | 40 | MIL_B3 choice screen title | A trade show offers a stall
EV_MIL_B3_BODY_A | 280 | MIL_B3 choice screen body after opt_a of MIL_B2 | The office has finished its review of the part, and a trade show offers you a stall. {bot3} keeps a stand there every year, always full. {bot2} holds a gala next door. You may buy the main hall for the week, or take the east stand beside {bot3}'s.
EV_MIL_B3_BODY_B | 280 | MIL_B3 choice screen body after opt_b of MIL_B2 | The office has filed its ruling on the refiled part, and a trade show offers you a stall. {bot3} keeps a stand there every year, always full. {bot2} holds a gala next door. You may buy the main hall for the week, or take the east stand beside {bot3}'s.
EV_MIL_B3_OPA_BTN | 28 | MIL_B3 button, opt_a | Buy the main hall
EV_MIL_B3_OPA_EFF | 200 | MIL_B3 effect line, opt_a | Get: Military volume up a little for a while. Cost: {cash_out} credits for the main hall. Rivals: {bot3}'s Military strength falls clearly.
EV_MIL_B3_OPA_RES_TITLE | 32 | MIL_B3 result popup title, opt_a | The main hall is yours
EV_MIL_B3_OPA_RES | 280 | MIL_B3 result popup, opt_a; {bot} is bot_3 | You bought the hall for the week. Buyers walked past empty stands to reach yours, and your orders rose for a while. {bot} sold from the corridor, and its Military strength falls clearly. The fee was paid on the day. The hall echoed after the last buyer left.
EV_MIL_B3_OPA_STD | 90 | MIL_B3 rival line 1, opt_a | {bot3}, Military: strength down clearly.
EV_MIL_B3_OPB_BTN | 28 | MIL_B3 button, opt_b | Take the east stand
EV_MIL_B3_OPB_EFF | 200 | MIL_B3 effect line, opt_b | Get: {n} units of tech progress. Cost: {cash_out} credits for the stand. Rivals: {bot2}'s strength and all three rivals' growth fall a little in Military.
EV_MIL_B3_OPB_RES_TITLE | 32 | MIL_B3 result popup title, opt_b | The east stand
EV_MIL_B3_OPB_RES | 280 | MIL_B3 result popup, opt_b; {bot} is bot_1 | You took the east stand beside {bot3}'s. The stand fee was paid on the day. Two engineers from the next stand talked shop for an hour. {bot2}, whose gala crowd walked past, loses a little Military strength, and all three rivals, {bot} among them, grow more slowly.
EV_MIL_B3_OPB_STD | 90 | MIL_B3 rival line 1, opt_b | All three rivals, Military: growth down a little.
EV_MIL_B3_OPB_STD2 | 90 | MIL_B3 rival line 2, opt_b | {bot2}, Military: strength down a little.

### MIL_B4 (Military, chain B, step 4)
EV_MIL_B4_TITLE | 40 | MIL_B4 choice screen title | A buyer asks you to set terms
EV_MIL_B4_BODY_A | 280 | MIL_B4 choice screen body after opt_a of MIL_B3 | Your week in the main hall brought the fleets to you. A large buyer asks you to set the terms of a supply agreement for many cycles: deliveries can be rostered by garrison, or by week. {bot} has lost ground to you and watches from the door.
EV_MIL_B4_BODY_B | 280 | MIL_B4 choice screen body after opt_b of MIL_B3 | Your days at the east stand brought the fleets to you. A large buyer asks you to set the terms of a supply agreement for many cycles: deliveries can be rostered by garrison, or by week. {bot} has lost ground to you and watches from the door.
EV_MIL_B4_OPA_BTN | 28 | MIL_B4 button, opt_a | Roster by garrison
EV_MIL_B4_OPA_EFF | 200 | MIL_B4 effect line, opt_a | Get: Military price up a little for a while. Cost: Military volume down a little for a while. Rivals: {bot1}'s Military strength falls clearly.
EV_MIL_B4_OPA_RES_TITLE | 32 | MIL_B4 result popup title, opt_a | Rostered by garrison
EV_MIL_B4_OPA_RES | 280 | MIL_B4 result popup, opt_a; {bot} is bot_1 | Deliveries are now rostered by garrison. Orders thinned for a while as the rosters were written, and the price of standing orders rose. {bot} had counted on the fleets as its client, and its Military strength falls clearly.
EV_MIL_B4_OPA_STD | 90 | MIL_B4 rival line 1, opt_a | {bot1}, Military: strength down clearly.
EV_MIL_B4_OPB_BTN | 28 | MIL_B4 button, opt_b | Roster by week
EV_MIL_B4_OPB_EFF | 200 | MIL_B4 effect line, opt_b | Get: {cash_in} credits. Cost: Ship upkeep rises clearly for a while. Rivals: {bot1}'s Military strength falls clearly; {bot3}'s falls a little.
EV_MIL_B4_OPB_RES_TITLE | 32 | MIL_B4 result popup title, opt_b | Rostered by week
EV_MIL_B4_OPB_RES | 280 | MIL_B4 result popup, opt_b; {bot} is bot_1 | Deliveries are now rostered by week from your desk, and the fleets are held ready. A large payment arrived. Hulls kept ready cost more to keep, and Ship upkeep rises for a while. {bot}'s Military strength falls clearly, and {bot3}'s a little.
EV_MIL_B4_OPB_STD | 90 | MIL_B4 rival line 1, opt_b | {bot1}, Military: strength down clearly.
EV_MIL_B4_OPB_STD2 | 90 | MIL_B4 rival line 2, opt_b | {bot3}, Military: strength down a little.

### LUX_A1 (Luxury, chain A, step 1)
EV_LUX_A1_TITLE | 40 | LUX_A1 choice screen title | A patron asks for first pick
EV_LUX_A1_BODY | 280 | LUX_A1 choice screen body (one body) | A patron on Quillon's gallery ring wants the first batch of every cycle, before any other buyer sees the crate. {bot2} supplies the patron today, and {bot3} keeps a counter on the same ring. You may set a first-pick price, or sell one first lot outright.
EV_LUX_A1_OPA_BTN | 28 | LUX_A1 button, opt_a | Set a first-pick price
EV_LUX_A1_OPA_EFF | 200 | LUX_A1 effect line, opt_a | Get: Luxury price up a little for a while. Cost: Luxury volume down a little for a while. Rivals: {bot2}'s Luxury strength falls a little.
EV_LUX_A1_OPA_RES_TITLE | 32 | LUX_A1 result popup title, opt_a | The first pick is priced
EV_LUX_A1_OPA_RES | 280 | LUX_A1 result popup, opt_a; {bot} is bot_2 | The patron agreed a first-pick price, and the crates now go to the gallery ring before the shelves. Fewer reach the general counters, so volume dips for a while. {bot} lost the patron's first look, and its Luxury strength falls a little. The patron sniffed every lid.
EV_LUX_A1_OPA_STD | 90 | LUX_A1 rival line 1, opt_a | {bot2}, Luxury: strength down a little.
EV_LUX_A1_OPB_BTN | 28 | LUX_A1 button, opt_b | Sell one first lot
EV_LUX_A1_OPB_EFF | 200 | LUX_A1 effect line, opt_b | Get: {cash_in} credits now. Cost: Luxury volume down a little for a few cycles; {bot2} grows a little faster in Luxury. Rivals: {bot3}'s Luxury strength falls a little.
EV_LUX_A1_OPB_RES_TITLE | 32 | LUX_A1 result popup title, opt_b | The first lot is sold
EV_LUX_A1_OPB_RES | 280 | LUX_A1 result popup, opt_b; {bot} is bot_3 | The patron paid for one first lot at the dock and the cash arrived the same hour. Shelves stood bare for a few cycles. {bot2} supplied the patron's next lot and grows a little faster in Luxury, while {bot} finds its counter on the ring emptier and its strength falls a little.
EV_LUX_A1_OPB_STD | 90 | LUX_A1 rival line 1, opt_b | {bot3}, Luxury: strength down a little.
EV_LUX_A1_OPB_STD2 | 90 | LUX_A1 rival line 2, opt_b | {bot2}, Luxury: growth up a little.

### LUX_A2 (Luxury, chain A, step 2)
EV_LUX_A2_TITLE | 40 | LUX_A2 choice screen title | A master finisher takes offers
EV_LUX_A2_BODY_A | 280 | LUX_A2 choice screen body after opt_a of LUX_A1 | The patron's first pick is priced and the crates go out. A master finisher has left a guild atelier and takes offers for a season's work. {bot2} wants the hands for its own gem room. You may hire the finisher, or take the finisher's pieces on contract.
EV_LUX_A2_BODY_B | 280 | LUX_A2 choice screen body after opt_b of LUX_A1 | The patron has bought its first lot. A master finisher has left a guild atelier and takes offers for a season's work. {bot2} wants the hands for its own gem room. You may hire the finisher, or take the finisher's pieces on contract.
EV_LUX_A2_OPA_BTN | 28 | LUX_A2 button, opt_a | Hire the finisher
EV_LUX_A2_OPA_EFF | 200 | LUX_A2 effect line, opt_a | Get: {n} units of tech progress at the Atelier. Cost: {cash_out} credits in fees. Rivals: {bot2}'s Luxury growth falls sharply.
EV_LUX_A2_OPA_RES_TITLE | 32 | LUX_A2 result popup title, opt_a | The finisher joins the atelier
EV_LUX_A2_OPA_RES | 280 | LUX_A2 result popup, opt_a; {bot} is bot_2 | The finisher took a bench in your atelier and showed the crew a cut they had not seen. Tech progress came in, and the fees were paid. {bot} had planned the hands for its gem room, and its Luxury growth falls sharply. The old bench still bears chalk marks.
EV_LUX_A2_OPA_STD | 90 | LUX_A2 rival line 1, opt_a | {bot2}, Luxury: growth down sharply.
EV_LUX_A2_OPB_BTN | 28 | LUX_A2 button, opt_b | Take the pieces
EV_LUX_A2_OPB_EFF | 200 | LUX_A2 effect line, opt_b | Get: Luxury volume up a little for the rest of the run. Cost: Luxury price down a little for a few cycles. Rivals: {bot2} {cut} in Luxury.
EV_LUX_A2_OPB_RES_TITLE | 32 | LUX_A2 result popup title, opt_b | Pieces on contract
EV_LUX_A2_OPB_RES | 280 | LUX_A2 result popup, opt_b; {bot} is bot_2 | The finisher's pieces came to you on contract and fill your counters, priced a little low for a few cycles. {bot} lost the finisher's work and was cut back in Luxury: fewer crates, fewer buyers. The gems came with a hallmark in an unknown hand.
EV_LUX_A2_OPB_STD | 90 | LUX_A2 rival line 1, opt_b | {bot2}, Luxury: {cut_std}.

### LUX_A3 (Luxury, chain A, step 3)
EV_LUX_A3_TITLE | 40 | LUX_A3 choice screen title | A buyer returns a rival's batch
EV_LUX_A3_BODY_A | 280 | LUX_A3 choice screen body after opt_a of LUX_A2 | The finisher is at your atelier. A buyer has sent back a whole batch of {bot2}'s work and asks you to fill the order. The buyer will pay a premium for a name, or give a place on its list for a price a little low. {bot3} keeps a table at the buyer's door.
EV_LUX_A3_BODY_B | 280 | LUX_A3 choice screen body after opt_b of LUX_A2 | The finisher's pieces are on your counters. A buyer has sent back a whole batch of {bot2}'s work and asks you to fill the order. The buyer will pay a premium for a name, or give a place on its list for a price a little low. {bot3} keeps a table at the buyer's door.
EV_LUX_A3_OPA_BTN | 28 | LUX_A3 button, opt_a | Fill the order by name
EV_LUX_A3_OPA_EFF | 200 | LUX_A3 effect line, opt_a | Get: Luxury price up clearly for a while. Cost: {cash_out} credits for the hallmarks. Rivals: {bot2}'s Luxury strength falls sharply for a few cycles.
EV_LUX_A3_OPA_RES_TITLE | 32 | LUX_A3 result popup title, opt_a | Filled by name
EV_LUX_A3_OPA_RES | 280 | LUX_A3 result popup, opt_a; {bot} is bot_2 | You filled the order under your own mark and the buyer paid the premium. The hallmarks cost credits. {bot}, whose batch was sent back, loses Luxury strength sharply for a few cycles. The returned crates sit in the buyer's cellar, unopened.
EV_LUX_A3_OPA_STD | 90 | LUX_A3 rival line 1, opt_a | {bot2}, Luxury: strength down sharply for a few cycles.
EV_LUX_A3_OPB_BTN | 28 | LUX_A3 button, opt_b | Fill the order by list
EV_LUX_A3_OPB_EFF | 200 | LUX_A3 effect line, opt_b | Get: Luxury volume up a little for a while. Cost: Luxury price down a little for a few cycles. Rivals: {bot3}'s Luxury strength falls a little.
EV_LUX_A3_OPB_RES_TITLE | 32 | LUX_A3 result popup title, opt_b | Filled by list
EV_LUX_A3_OPB_RES | 280 | LUX_A3 result popup, opt_b; {bot} is bot_3 | You filled the order for a place on the buyer's list, at a price a little low for a few cycles. The list sends its friends, so your orders rose for a while. {bot}, whose table stood by the door, loses a little Luxury strength.
EV_LUX_A3_OPB_STD | 90 | LUX_A3 rival line 1, opt_b | {bot3}, Luxury: strength down a little.

### LUX_B1 (Luxury, chain B, step 1)
EV_LUX_B1_TITLE | 40 | LUX_B1 choice screen title | A venue books a date
EV_LUX_B1_BODY | 280 | LUX_B1 choice screen body (one body) | A pavilion on the Quillon ring has booked a date for a masked evening and wants stock for it: silk, sunmusk, cut glimmers. {bot2} supplies the pavilion's cellar, and {bot3} stands ready with samples. You may sell the venue its stock, or stock the stalls yourself.
EV_LUX_B1_OPA_BTN | 28 | LUX_B1 button, opt_a | Sell the venue its stock
EV_LUX_B1_OPA_EFF | 200 | LUX_B1 effect line, opt_a | Get: {cash_in} credits now. Cost: Luxury volume down a little for a while. Rivals: {bot2}'s Luxury growth falls a little.
EV_LUX_B1_OPA_RES_TITLE | 32 | LUX_B1 result popup title, opt_a | The venue buys its stock
EV_LUX_B1_OPA_RES | 280 | LUX_B1 result popup, opt_a; {bot} is bot_2 | The venue bought its stock outright and paid on the night. Your own counters ran thin while the crates were gone. {bot}'s cellar supply lost the date, and its Luxury growth falls a little. The masks in the pavilion all faced the door.
EV_LUX_B1_OPA_STD | 90 | LUX_B1 rival line 1, opt_a | {bot2}, Luxury: growth down a little.
EV_LUX_B1_OPB_BTN | 28 | LUX_B1 button, opt_b | Stock the stalls yourself
EV_LUX_B1_OPB_EFF | 200 | LUX_B1 effect line, opt_b | Get: Luxury volume up clearly for a while. Cost: {cash_out} credits for the stalls. Rivals: {bot2}'s Luxury strength falls clearly.
EV_LUX_B1_OPB_RES_TITLE | 32 | LUX_B1 result popup title, opt_b | Your stalls fill the evening
EV_LUX_B1_OPB_RES | 280 | LUX_B1 result popup, opt_b; {bot} is bot_2 | Your stalls stood in the pavilion all evening, and buyers came to them first. The stalls cost credits, and your orders rose for a while. {bot} found its crates unwanted, and its Luxury strength falls clearly. A mask with nothing behind it hung on every pillar.
EV_LUX_B1_OPB_STD | 90 | LUX_B1 rival line 1, opt_b | {bot2}, Luxury: strength down clearly.

### LUX_B2 (Luxury, chain B, step 2)
EV_LUX_B2_TITLE | 40 | LUX_B2 choice screen title | The venue's list goes public
EV_LUX_B2_BODY_A | 280 | LUX_B2 choice screen body after opt_a of LUX_B1 | You sold the venue its stock. Now the pavilion's list of buyers has been posted on a wall for a day, every name and every order. {bot3} copied it by the hour, and {bot2} denied there was a list. You may study the list at your atelier, or sell your copy.
EV_LUX_B2_BODY_B | 280 | LUX_B2 choice screen body after opt_b of LUX_B1 | You stocked the venue's stalls. Now the pavilion's list of buyers has been posted on a wall for a day, every name and every order. {bot3} copied it by the hour, and {bot2} denied there was a list. You may study the list at your atelier, or sell your copy.
EV_LUX_B2_OPA_BTN | 28 | LUX_B2 button, opt_a | Study the list
EV_LUX_B2_OPA_EFF | 200 | LUX_B2 effect line, opt_a | Get: {n} units of tech progress at the Atelier. Cost: Luxury price down a little for a few cycles. Rivals: {bot2}'s Luxury strength falls a little; {bot3}'s growth falls sharply.
EV_LUX_B2_OPA_RES_TITLE | 32 | LUX_B2 result popup title, opt_a | The list is studied
EV_LUX_B2_OPA_RES | 280 | LUX_B2 result popup, opt_a; {bot} is bot_3 | Your atelier read the names against the orders and learned which cuts the buyers asked for. Tech progress came in, and prices dipped a little for a few cycles as buyers saw your hand. {bot2}'s Luxury strength falls a little, and {bot}'s Luxury growth falls sharply.
EV_LUX_B2_OPA_STD | 90 | LUX_B2 rival line 1, opt_a | {bot3}, Luxury: growth down sharply.
EV_LUX_B2_OPA_STD2 | 90 | LUX_B2 rival line 2, opt_a | {bot2}, Luxury: strength down a little.
EV_LUX_B2_OPB_BTN | 28 | LUX_B2 button, opt_b | Sell your copy
EV_LUX_B2_OPB_EFF | 200 | LUX_B2 effect line, opt_b | Get: {cash_in} credits. Cost: Luxury price down a little for a few cycles; {bot2} gains Luxury strength clearly. Rivals: {bot2} {cut} in Luxury.
EV_LUX_B2_OPB_RES_TITLE | 32 | LUX_B2 result popup title, opt_b | The copy is sold
EV_LUX_B2_OPB_RES | 280 | LUX_B2 result popup, opt_b; {bot} is bot_2 | You sold your copy to the table that offered most, and the cash came in. {bot} was the buyer and gains Luxury strength clearly, though its own name stood on the list, so it is cut back too. Prices dipped a little for a few cycles. A pale square marks the wall.
EV_LUX_B2_OPB_STD | 90 | LUX_B2 rival line 1, opt_b | {bot2}, Luxury: {cut_std}.
EV_LUX_B2_OPB_STD2 | 90 | LUX_B2 rival line 2, opt_b | {bot2}, Luxury: strength up clearly.

### LUX_B3 (Luxury, chain B, step 3)
EV_LUX_B3_TITLE | 40 | LUX_B3 choice screen title | A buyer asks for a fixed price
EV_LUX_B3_BODY_A | 280 | LUX_B3 choice screen body after opt_a of LUX_B2 | You studied the list. A buyer of masks and glimmers asks you to name one price and hold it for a set period. {bot2} would sell to the buyer at floating rates, and {bot1} would take any contract that moves stock. You may fix the price, or sell the lot at today's rate.
EV_LUX_B3_BODY_B | 280 | LUX_B3 choice screen body after opt_b of LUX_B2 | You sold your copy of the list. A buyer of masks and glimmers asks you to name one price and hold it for a set period. {bot2} would sell to the buyer at floating rates, and {bot1} would take any contract that moves stock. You may fix the price, or sell the lot at today's rate.
EV_LUX_B3_OPA_BTN | 28 | LUX_B3 button, opt_a | Fix the price for a term
EV_LUX_B3_OPA_EFF | 200 | LUX_B3 effect line, opt_a | Get: Luxury price up clearly for a while. Cost: Luxury volume down a little for a while. Rivals: {bot2}'s Luxury growth falls sharply.
EV_LUX_B3_OPA_RES_TITLE | 32 | LUX_B3 result popup title, opt_a | The price is fixed
EV_LUX_B3_OPA_RES | 280 | LUX_B3 result popup, opt_a; {bot} is bot_2 | The buyer signed one price for the whole term, and your counters held it. Your own volume eased for a while, since casual buyers stayed away. {bot}'s floating rates could not follow, and its Luxury growth falls sharply. The contract carries a stamp shaped like a mask.
EV_LUX_B3_OPA_STD | 90 | LUX_B3 rival line 1, opt_a | {bot2}, Luxury: growth down sharply.
EV_LUX_B3_OPB_BTN | 28 | LUX_B3 button, opt_b | Sell the lot at today's rate
EV_LUX_B3_OPB_EFF | 200 | LUX_B3 effect line, opt_b | Get: {cash_in} credits now. Cost: Luxury volume down a little for a while; {bot3} gains a little Luxury strength. Rivals: {bot1}'s and {bot2}'s Luxury strength falls a little.
EV_LUX_B3_OPB_RES_TITLE | 32 | LUX_B3 result popup title, opt_b | The lot is sold
EV_LUX_B3_OPB_RES | 280 | LUX_B3 result popup, opt_b; {bot} is bot_1 | You sold the lot at the day's rate and the cash came in. Your shelves ran lean for a while. {bot3} picked up what the buyer still wanted and gains a little Luxury strength, while {bot} and {bot2} each lose a little. The buyer left with the crates and no receipt.
EV_LUX_B3_OPB_STD | 90 | LUX_B3 rival line 1, opt_b | {bot1} and {bot2}, Luxury: strength down a little.
EV_LUX_B3_OPB_STD2 | 90 | LUX_B3 rival line 2, opt_b | {bot3}, Luxury: strength up a little.

### LUX_B4 (Luxury, chain B, step 4)
EV_LUX_B4_TITLE | 40 | LUX_B4 choice screen title | A trade body offers a seat
EV_LUX_B4_BODY_A | 280 | LUX_B4 choice screen body after opt_a of LUX_B3 | Your fixed price held through the term, and the guild noticed. The Guild of Masks, a trade body, offers you a seat on its board. {bot2} holds the chair, and {bot3} sits by the door. You may take the pricing desk, or the stock desk. Both meet weekly behind a gilt screen.
EV_LUX_B4_BODY_B | 280 | LUX_B4 choice screen body after opt_b of LUX_B3 | You sold the lot at the day's rate, and the guild noticed. The Guild of Masks, a trade body, offers you a seat on its board. {bot2} holds the chair, and {bot3} sits by the door. You may take the pricing desk, or the stock desk. Both meet weekly behind a gilt screen.
EV_LUX_B4_OPA_BTN | 28 | LUX_B4 button, opt_a | Take the pricing desk
EV_LUX_B4_OPA_EFF | 200 | LUX_B4 effect line, opt_a | Get: Luxury price up a little for a while. Cost: {cash_out} credits in dues for the pricing seat. Rivals: {bot2}'s Luxury strength falls sharply.
EV_LUX_B4_OPA_RES_TITLE | 32 | LUX_B4 result popup title, opt_a | The pricing desk is yours
EV_LUX_B4_OPA_RES | 280 | LUX_B4 result popup, opt_a; {bot} is bot_2 | You took the pricing desk and the dues were paid on the day. The guild's price sheets now carry your marks, and prices rose a little for a while. {bot} sat in the chair and watched its Luxury strength fall sharply. The sheets are printed on gilt-edged paper.
EV_LUX_B4_OPA_STD | 90 | LUX_B4 rival line 1, opt_a | {bot2}, Luxury: strength down sharply.
EV_LUX_B4_OPB_BTN | 28 | LUX_B4 button, opt_b | Take the stock desk
EV_LUX_B4_OPB_EFF | 200 | LUX_B4 effect line, opt_b | Get: Luxury volume up a little for the rest of the run. Cost: Luxury price down a little for a while. Rivals: {bot2}'s strength falls clearly; {bot3}'s a little.
EV_LUX_B4_OPB_RES_TITLE | 32 | LUX_B4 result popup title, opt_b | The stock desk is yours
EV_LUX_B4_OPB_RES | 280 | LUX_B4 result popup, opt_b; {bot} is bot_2 | You took the stock desk and the schedules came to your hand. Volume rose for the rest of the run, and prices eased a little for a while. {bot}'s Luxury strength falls clearly, and {bot3}'s a little. The desk has a bell that no one rings.
EV_LUX_B4_OPB_STD | 90 | LUX_B4 rival line 1, opt_b | {bot2}, Luxury: strength down clearly.
EV_LUX_B4_OPB_STD2 | 90 | LUX_B4 rival line 2, opt_b | {bot3}, Luxury: strength down a little.

### MIN_A1 (Minerals, chain A, step 1)
EV_MIN_A1_TITLE | 40 | MIN_A1 choice screen title | Cinderrest reports a fault
EV_MIN_A1_BODY | 280 | MIN_A1 choice screen body (one body) | The Cinderrest crew reports that the lift cable has frayed and the lamps drop out on the lower level. {bot1} runs the next shaft and has offered to lend its crew and cable, for a price. You may sell the lower level, or replace the cable.
EV_MIN_A1_OPA_BTN | 28 | MIN_A1 button, opt_a | Sell the lower level
EV_MIN_A1_OPA_EFF | 200 | MIN_A1 effect line, opt_a | Get: {cash_in} credits now. Cost: Minerals volume down a little for a while. Rivals: {bot1}'s Minerals growth falls a little.
EV_MIN_A1_OPA_RES_TITLE | 32 | MIN_A1 result popup title, opt_a | The lower level is sold
EV_MIN_A1_OPA_RES | 280 | MIN_A1 result popup, opt_a; {bot} is bot_1 | A buyer took the lower level and paid on the lift. Your crew works the upper cuts, so volume dipped for a while. {bot} wanted the level and cut elsewhere, and its Minerals growth falls a little. The lamps below still burn, for no one.
EV_MIN_A1_OPA_STD | 90 | MIN_A1 rival line 1, opt_a | {bot1}, Minerals: growth down a little.
EV_MIN_A1_OPB_BTN | 28 | MIN_A1 button, opt_b | Replace the cable
EV_MIN_A1_OPB_EFF | 200 | MIN_A1 effect line, opt_b | Get: Minerals volume up a little for a while. Cost: {cash_out} credits for the cable. Rivals: {bot1}'s Minerals strength falls a little.
EV_MIN_A1_OPB_RES_TITLE | 32 | MIN_A1 result popup title, opt_b | The cable is replaced
EV_MIN_A1_OPB_RES | 280 | MIN_A1 result popup, opt_b; {bot} is bot_1 | A new cable went down and the lamps held. The cable cost credits, and the crew cut more for a while. {bot} had counted on a lent crew, and its Minerals strength falls a little. The old cable lies coiled at the shaft head, still warm.
EV_MIN_A1_OPB_STD | 90 | MIN_A1 rival line 1, opt_b | {bot1}, Minerals: strength down a little.

### MIN_A2 (Minerals, chain A, step 2)
EV_MIN_A2_TITLE | 40 | MIN_A2 choice screen title | Greywake reports a fault
EV_MIN_A2_BODY_A | 280 | MIN_A2 choice screen body after opt_a of MIN_A1 | You sold the lower level at Cinderrest. Now the Greywake crew reports that a roof beam in the main cut has cracked, and the glass beneath rings in the teeth. {bot3} works the next cut and wants the same beams. You may brace the beam, or sell the cut.
EV_MIN_A2_BODY_B | 280 | MIN_A2 choice screen body after opt_b of MIN_A1 | You replaced the lift cable at Cinderrest. Now the Greywake crew reports that a roof beam in the main cut has cracked, and the glass beneath rings in the teeth. {bot3} works the next cut and wants the same beams. You may brace the beam, or sell the cut.
EV_MIN_A2_OPA_BTN | 28 | MIN_A2 button, opt_a | Brace the beam
EV_MIN_A2_OPA_EFF | 200 | MIN_A2 effect line, opt_a | Get: Minerals volume up a little for a while. Cost: {cash_out} credits for the bracing. Rivals: {bot3}'s Minerals growth falls clearly.
EV_MIN_A2_OPA_RES_TITLE | 32 | MIN_A2 result popup title, opt_a | The beam is braced
EV_MIN_A2_OPA_RES | 280 | MIN_A2 result popup, opt_a; {bot} is bot_3 | Braces went in row by row and the cut kept working for your crews. It cost credits, and volume rose for a while. {bot} had waited for the beams, and its Minerals growth falls clearly. The crack stopped, and the glass went on ringing.
EV_MIN_A2_OPA_STD | 90 | MIN_A2 rival line 1, opt_a | {bot3}, Minerals: growth down clearly.
EV_MIN_A2_OPB_BTN | 28 | MIN_A2 button, opt_b | Sell the cut
EV_MIN_A2_OPB_EFF | 200 | MIN_A2 effect line, opt_b | Get: {cash_in} credits now. Cost: Minerals volume down a little for a few cycles. Rivals: {bot1}'s Minerals strength falls clearly.
EV_MIN_A2_OPB_RES_TITLE | 32 | MIN_A2 result popup title, opt_b | The cut is sold
EV_MIN_A2_OPB_RES | 280 | MIN_A2 result popup, opt_b; {bot} is bot_1 | A buyer took the cut with the crack in it and paid on the day. Your crews moved to other work, so volume dipped for a few cycles. {bot} had bid on the same cut, and its Minerals strength falls clearly. The buyer inspected the crack, briefly.
EV_MIN_A2_OPB_STD | 90 | MIN_A2 rival line 1, opt_b | {bot1}, Minerals: strength down clearly.

### MIN_A3 (Minerals, chain A, step 3)
EV_MIN_A3_TITLE | 40 | MIN_A3 choice screen title | A rival sends word of a route
EV_MIN_A3_BODY_A | 280 | MIN_A3 choice screen body after opt_a of MIN_A2 | The beam at Greywake is braced. A hauler of {bot3}'s fleet sends word of a route to an unclaimed ore cluster: its chart, for a price. {bot1} runs the same lane in force. You may buy the chart, or add extra hulls to the lane.
EV_MIN_A3_BODY_B | 280 | MIN_A3 choice screen body after opt_b of MIN_A2 | The cut at Greywake is sold. A hauler of {bot3}'s fleet sends word of a route to an unclaimed ore cluster: its chart, for a price. {bot1} runs the same lane in force. You may buy the chart, or add extra hulls to the lane.
EV_MIN_A3_OPA_BTN | 28 | MIN_A3 button, opt_a | Buy the chart
EV_MIN_A3_OPA_EFF | 200 | MIN_A3 effect line, opt_a | Get: one route's trip cost falls a little for a while. Cost: {cash_out} credits for the chart; {bot3} gains a little Minerals strength. Rivals: {bot1}'s Minerals strength falls a little.
EV_MIN_A3_OPA_RES_TITLE | 32 | MIN_A3 result popup title, opt_a | The chart is bought
EV_MIN_A3_OPA_RES | 280 | MIN_A3 result popup, opt_a; {bot} is bot_1 | You bought the chart and ran one route by it. Trip cost fell a little for a while, and the chart cost credits. The hauler sold the same chart to its own fleet, so {bot3} gains a little Minerals strength. {bot} lost its lead on the lane, and its strength falls a little.
EV_MIN_A3_OPA_STD | 90 | MIN_A3 rival line 1, opt_a | {bot1}, Minerals: strength down a little.
EV_MIN_A3_OPA_STD2 | 90 | MIN_A3 rival line 2, opt_a | {bot3}, Minerals: strength up a little.
EV_MIN_A3_OPB_BTN | 28 | MIN_A3 button, opt_b | Add extra hulls
EV_MIN_A3_OPB_EFF | 200 | MIN_A3 effect line, opt_b | Get: Minerals volume up clearly for a while. Cost: {cash_out} credits and Ship upkeep up a little for a while. Rivals: {bot1} {cut} in Minerals.
EV_MIN_A3_OPB_RES_TITLE | 32 | MIN_A3 result popup title, opt_b | Extra hulls on the lane
EV_MIN_A3_OPB_RES | 280 | MIN_A3 result popup, opt_b; {bot} is bot_1 | You sent extra hulls down the lane and the crews cut harder for a while. The hulls cost credits and raise Ship upkeep a little for a while. {bot} was cut back in Minerals, its lane crews pushed to the edge of the chart. The wakes behind your hulls crossed and recrossed.
EV_MIN_A3_OPB_STD | 90 | MIN_A3 rival line 1, opt_b | {bot1}, Minerals: {cut_std}.

### MIN_B1 (Minerals, chain B, step 1)
EV_MIN_B1_TITLE | 40 | MIN_B1 choice screen title | Two claims on one seam
EV_MIN_B1_BODY | 280 | MIN_B1 choice screen body (one body) | Your crew and a crew of {bot1} filed a claim on the same seam in the same hour, and the Bureau stamped both. The arbiter asks for a sale or a survey. You may sell your claim, or pay for a survey that proves the cut.
EV_MIN_B1_OPA_BTN | 28 | MIN_B1 button, opt_a | Sell your claim
EV_MIN_B1_OPA_EFF | 200 | MIN_B1 effect line, opt_a | Get: {cash_in} credits now. Cost: Minerals volume down a little for a while. Rivals: {bot1}'s Minerals growth falls a little.
EV_MIN_B1_OPA_RES_TITLE | 32 | MIN_B1 result popup title, opt_a | Your claim is sold
EV_MIN_B1_OPA_RES | 280 | MIN_B1 result popup, opt_a; {bot} is bot_1 | The arbiter's buyer took your claim and paid on the spot. Your crews moved to other cuts, so volume dipped for a while. {bot} kept the seam, and its Minerals growth falls a little as the buyer set terms. The stamp on your copy was still wet.
EV_MIN_B1_OPA_STD | 90 | MIN_B1 rival line 1, opt_a | {bot1}, Minerals: growth down a little.
EV_MIN_B1_OPB_BTN | 28 | MIN_B1 button, opt_b | Pay for a survey
EV_MIN_B1_OPB_EFF | 200 | MIN_B1 effect line, opt_b | Get: {n} units of tech progress at the Smelter. Cost: {cash_out} credits for the survey. Rivals: {bot1}'s Minerals strength falls clearly.
EV_MIN_B1_OPB_RES_TITLE | 32 | MIN_B1 result popup title, opt_b | The survey proves the cut
EV_MIN_B1_OPB_RES | 280 | MIN_B1 result popup, opt_b; {bot} is bot_1 | The survey cut a test core through the seam and your smelter ran it. Tech progress came in, and the survey was paid. {bot}'s claim failed the core, and its Minerals strength falls clearly. The core was warm and had a thread of glass in it.
EV_MIN_B1_OPB_STD | 90 | MIN_B1 rival line 1, opt_b | {bot1}, Minerals: strength down clearly.

### MIN_B2 (Minerals, chain B, step 2)
EV_MIN_B2_TITLE | 40 | MIN_B2 choice screen title | The smelter crew stops work
EV_MIN_B2_BODY_A | 280 | MIN_B2 choice screen body after opt_a of MIN_B1 | You sold your claim, and now the crew at your smelter has stopped work and wants new terms. {bot3} has offered the crew a place. You may hold the terms and let the furnace cool, or pay for a double shift to keep it lit.
EV_MIN_B2_BODY_B | 280 | MIN_B2 choice screen body after opt_b of MIN_B1 | You paid for the survey, and now the crew at your smelter has stopped work and wants new terms. {bot3} has offered the crew a place. You may hold the terms and let the furnace cool, or pay for a double shift to keep it lit.
EV_MIN_B2_OPA_BTN | 28 | MIN_B2 button, opt_a | Hold the terms
EV_MIN_B2_OPA_EFF | 200 | MIN_B2 effect line, opt_a | Get: Minerals price up a little for a while. Cost: the Smelter stands idle for a few cycles. Rivals: {bot3}'s Minerals growth falls a little.
EV_MIN_B2_OPA_RES_TITLE | 32 | MIN_B2 result popup title, opt_a | The terms hold
EV_MIN_B2_OPA_RES | 280 | MIN_B2 result popup, opt_a; {bot} is bot_3 | You held the terms and the crew left the furnace to cool. Ingots grew scarce, so prices rose a little for a while, and the Smelter stood idle for a few cycles. {bot} had offered the crew a place, and its Minerals growth falls a little. The slag ticked as it shrank.
EV_MIN_B2_OPA_STD | 90 | MIN_B2 rival line 1, opt_a | {bot3}, Minerals: growth down a little.
EV_MIN_B2_OPB_BTN | 28 | MIN_B2 button, opt_b | Pay a double shift
EV_MIN_B2_OPB_EFF | 200 | MIN_B2 effect line, opt_b | Get: one more batch a cycle at the Smelter for a while. Cost: {cash_out} credits in shift pay. Rivals: {bot1}'s Minerals strength falls a little.
EV_MIN_B2_OPB_RES_TITLE | 32 | MIN_B2 result popup title, opt_b | A double shift runs
EV_MIN_B2_OPB_RES | 280 | MIN_B2 result popup, opt_b; {bot} is bot_1 | You paid for a double shift and the furnace stayed lit. The Smelter makes one more batch a cycle for a while, and the pay cost credits. {bot} counted on a cooled furnace, and its Minerals strength falls a little. The night crew did not look at the day crew.
EV_MIN_B2_OPB_STD | 90 | MIN_B2 rival line 1, opt_b | {bot1}, Minerals: strength down a little.

### MIN_B3 (Minerals, chain B, step 3)
EV_MIN_B3_TITLE | 40 | MIN_B3 choice screen title | A bidder prices your stock
EV_MIN_B3_BODY_A | 280 | MIN_B3 choice screen body after opt_a of MIN_B2 | You held the terms at the smelter. A bidder offers a price for all your ingot in storage, to be hauled today. {bot1} is the bidder's usual supplier, and {bot3} has asked for the leftovers. You may sell the whole stock, or take a standing buyer.
EV_MIN_B3_BODY_B | 280 | MIN_B3 choice screen body after opt_b of MIN_B2 | You paid for a double shift at the smelter. A bidder offers a price for all your ingot in storage, to be hauled today. {bot1} is the bidder's usual supplier, and {bot3} has asked for the leftovers. You may sell the whole stock, or take a standing buyer.
EV_MIN_B3_OPA_BTN | 28 | MIN_B3 button, opt_a | Sell the whole stock
EV_MIN_B3_OPA_EFF | 200 | MIN_B3 effect line, opt_a | Get: {cash_in} credits now. Cost: Minerals volume down clearly for a few cycles. Rivals: {bot1}'s Minerals strength falls sharply; {bot3}'s falls a little.
EV_MIN_B3_OPA_RES_TITLE | 32 | MIN_B3 result popup title, opt_a | The stock is sold
EV_MIN_B3_OPA_RES | 280 | MIN_B3 result popup, opt_a; {bot} is bot_1 | The bidder hauled the whole stock away and paid on the dock. Your storage stood empty, and volume fell clearly for a few cycles. {bot}'s usual contract went with it, so its Minerals strength falls sharply, and {bot3}'s a little. The racks rang as they emptied.
EV_MIN_B3_OPA_STD | 90 | MIN_B3 rival line 1, opt_a | {bot1}, Minerals: strength down sharply.
EV_MIN_B3_OPA_STD2 | 90 | MIN_B3 rival line 2, opt_a | {bot3}, Minerals: strength down a little.
EV_MIN_B3_OPB_BTN | 28 | MIN_B3 button, opt_b | Take a standing buyer
EV_MIN_B3_OPB_EFF | 200 | MIN_B3 effect line, opt_b | Get: Minerals volume up a little for a while. Cost: {cash_out} credits to the buyer's broker. Rivals: {bot1}'s Minerals strength falls clearly.
EV_MIN_B3_OPB_RES_TITLE | 32 | MIN_B3 result popup title, opt_b | A standing buyer signs
EV_MIN_B3_OPB_RES | 280 | MIN_B3 result popup, opt_b; {bot} is bot_1 | The standing buyer signed and sends a ship each cycle. Volume rose for a while, and the broker was paid in credits. {bot} lost the buyer's custom, and its Minerals strength falls clearly. The buyer's ship has no name on its hull.
EV_MIN_B3_OPB_STD | 90 | MIN_B3 rival line 1, opt_b | {bot1}, Minerals: strength down clearly.

### MIN_B4 (Minerals, chain B, step 4)
EV_MIN_B4_TITLE | 40 | MIN_B4 choice screen title | A new deposit is in range
EV_MIN_B4_BODY_A | 280 | MIN_B4 choice screen body after opt_a of MIN_B3 | You sold your whole ingot stock. Now a survey lists another deposit within reach of your ships, and {bot1} has already sent a charter crew. You may file the claim and pay the survey office, or lease the claim to a crew on terms.
EV_MIN_B4_BODY_B | 280 | MIN_B4 choice screen body after opt_b of MIN_B3 | You took a standing buyer. Now a survey lists another deposit within reach of your ships, and {bot1} has already sent a charter crew. You may file the claim and pay the survey office, or lease the claim to a crew on terms.
EV_MIN_B4_OPA_BTN | 28 | MIN_B4 button, opt_a | File the claim
EV_MIN_B4_OPA_EFF | 200 | MIN_B4 effect line, opt_a | Get: Minerals price up a little for a while. Cost: {cash_out} credits to the survey office for the filing. Rivals: {bot1}'s Minerals strength falls sharply.
EV_MIN_B4_OPA_RES_TITLE | 32 | MIN_B4 result popup title, opt_a | The claim is filed
EV_MIN_B4_OPA_RES | 280 | MIN_B4 result popup, opt_a; {bot} is bot_1 | You filed the claim and the office stamped it. The filing cost credits, and prices rose a little for a while as your ore came to market. {bot}'s charter crew found your marker at the site, and its Minerals strength falls sharply. The deposit lay under the rock, unmoved.
EV_MIN_B4_OPA_STD | 90 | MIN_B4 rival line 1, opt_a | {bot1}, Minerals: strength down sharply.
EV_MIN_B4_OPB_BTN | 28 | MIN_B4 button, opt_b | Lease the claim
EV_MIN_B4_OPB_EFF | 200 | MIN_B4 effect line, opt_b | Get: {cash_in} credits and Minerals volume up a little for the rest of the run. Cost: Ship upkeep up a little for a while. Rivals: {bot1}'s strength falls clearly; {bot3}'s a little.
EV_MIN_B4_OPB_RES_TITLE | 32 | MIN_B4 result popup title, opt_b | The claim is leased
EV_MIN_B4_OPB_RES | 280 | MIN_B4 result popup, opt_b; {bot} is bot_1 | You leased the claim to a crew and the first payment arrived. Your ships carry its ore, so volume rose, and Ship upkeep rises a little for a while. {bot}'s Minerals strength falls clearly, and {bot3}'s a little, as both lost the lease. The lease has a clause about the weather.
EV_MIN_B4_OPB_STD | 90 | MIN_B4 rival line 1, opt_b | {bot1}, Minerals: strength down clearly.
EV_MIN_B4_OPB_STD2 | 90 | MIN_B4 rival line 2, opt_b | {bot3}, Minerals: strength down a little.

### BIO_A1 (Biotech, chain A, step 1)
EV_BIO_A1_TITLE | 40 | BIO_A1 choice screen title | An unlabelled sample arrives
EV_BIO_A1_BODY | 280 | BIO_A1 choice screen body (one body) | A sealed sample reached your depot at Mossfell from a source no form names. It is damp and cold, and a colour no one has a name for. {bot2} has asked to buy it unseen. You may study the sample at your culture lab, or sell it as it came.
EV_BIO_A1_OPA_BTN | 28 | BIO_A1 button, opt_a | Study the sample
EV_BIO_A1_OPA_EFF | 200 | BIO_A1 effect line, opt_a | Get: {n} units of tech progress at the Culture Lab. Cost: {cash_out} credits for the tests. Rivals: {bot2}'s Biotech growth falls a little.
EV_BIO_A1_OPA_RES_TITLE | 32 | BIO_A1 result popup title, opt_a | The sample is studied
EV_BIO_A1_OPA_RES | 280 | BIO_A1 result popup, opt_a; {bot} is bot_2 | The lab ran the sample through its vats and logged every reading. Tech progress came in, and the tests cost credits. {bot} had hoped to buy the sample unseen, and its Biotech growth falls a little. The vat took on a faint green and kept it.
EV_BIO_A1_OPA_STD | 90 | BIO_A1 rival line 1, opt_a | {bot2}, Biotech: growth down a little.
EV_BIO_A1_OPB_BTN | 28 | BIO_A1 button, opt_b | Sell the sample
EV_BIO_A1_OPB_EFF | 200 | BIO_A1 effect line, opt_b | Get: {cash_in} credits now. Cost: Biotech price down a little for a few cycles. Rivals: {bot2}'s Biotech strength falls a little.
EV_BIO_A1_OPB_RES_TITLE | 32 | BIO_A1 result popup title, opt_b | The sample is sold
EV_BIO_A1_OPB_RES | 280 | BIO_A1 result popup, opt_b; {bot} is bot_2 | The sample was sold as it came, and the cash arrived the same day. Buyers read the odd colour as a warning, so prices dipped a little for a few cycles. {bot} bought nothing, and its Biotech strength falls a little. Nobody asked what it was.
EV_BIO_A1_OPB_STD | 90 | BIO_A1 rival line 1, opt_b | {bot2}, Biotech: strength down a little.

### BIO_A2 (Biotech, chain A, step 2)
EV_BIO_A2_TITLE | 40 | BIO_A2 choice screen title | A buyer asks to test a batch
EV_BIO_A2_BODY_A | 280 | BIO_A2 choice screen body after opt_a of BIO_A1 | Your lab studied the sample. Now a clinic buyer asks to draw a batch from your stock for testing, and will report what it finds. {bot2} supplies the clinic's other wards, and {bot3} wants the test data. You may fund the clinic's tests, or run them at your lab.
EV_BIO_A2_BODY_B | 280 | BIO_A2 choice screen body after opt_b of BIO_A1 | You sold the sample. Now a clinic buyer asks to draw a batch from your stock for testing, and will report what it finds. {bot2} supplies the clinic's other wards, and {bot3} wants the test data. You may fund the clinic's tests, or run them at your lab.
EV_BIO_A2_OPA_BTN | 28 | BIO_A2 button, opt_a | Fund the clinic's tests
EV_BIO_A2_OPA_EFF | 200 | BIO_A2 effect line, opt_a | Get: Biotech volume up a little for the rest of the run. Cost: {cash_out} credits toward the tests. Rivals: {bot3}'s Biotech growth falls a little.
EV_BIO_A2_OPA_RES_TITLE | 32 | BIO_A2 result popup title, opt_a | The clinic runs the tests
EV_BIO_A2_OPA_RES | 280 | BIO_A2 result popup, opt_a; {bot} is bot_3 | The clinic drew its batch and ran the tests in its own lab. Your funding cost credits, and the clinic keeps ordering, so volume rose for the rest of the run. {bot} wanted the test data, and its Biotech growth falls a little. The report came back in triplicate, all copies damp.
EV_BIO_A2_OPA_STD | 90 | BIO_A2 rival line 1, opt_a | {bot3}, Biotech: growth down a little.
EV_BIO_A2_OPB_BTN | 28 | BIO_A2 button, opt_b | Run the tests at your lab
EV_BIO_A2_OPB_EFF | 200 | BIO_A2 effect line, opt_b | Get: {n} units of tech progress at the Culture Lab. Cost: Biotech volume down a little for a while. Rivals: {bot2} {cut} in Biotech.
EV_BIO_A2_OPB_RES_TITLE | 32 | BIO_A2 result popup title, opt_b | The tests run at your lab
EV_BIO_A2_OPB_RES | 280 | BIO_A2 result popup, opt_b; {bot} is bot_2 | Your lab ran the tests on the held batch, and the vats gave tech progress. The batch left the shelves, so volume dipped for a while. {bot} was cut back in Biotech as the clinic's wards moved to your results. The cultures grew slowly, on schedule.
EV_BIO_A2_OPB_STD | 90 | BIO_A2 rival line 1, opt_b | {bot2}, Biotech: {cut_std}.

### BIO_A3 (Biotech, chain A, step 3)
EV_BIO_A3_TITLE | 40 | BIO_A3 choice screen title | A lab reports a fault
EV_BIO_A3_BODY_A | 280 | BIO_A3 choice screen body after opt_a of BIO_A2 | The clinic's tests ran on your funding. A lab on Brannock reports a containment fault: a vat seal has begun to weep. {bot2} sources strains from that lab, and {bot3} offers to buy its stock. You may pause your culture lab for a check, or sell the stock in that line.
EV_BIO_A3_BODY_B | 280 | BIO_A3 choice screen body after opt_b of BIO_A2 | The tests ran at your lab. A lab on Brannock reports a containment fault: a vat seal has begun to weep. {bot2} sources strains from that lab, and {bot3} offers to buy its stock. You may pause your culture lab for a check, or sell the stock in that line.
EV_BIO_A3_OPA_BTN | 28 | BIO_A3 button, opt_a | Pause the lab for a check
EV_BIO_A3_OPA_EFF | 200 | BIO_A3 effect line, opt_a | Get: Biotech price up a little for a while. Cost: the Culture Lab stands idle for a few cycles. Rivals: {bot2}'s Biotech strength falls a little.
EV_BIO_A3_OPA_RES_TITLE | 32 | BIO_A3 result popup title, opt_a | The lab is paused
EV_BIO_A3_OPA_RES | 280 | BIO_A3 result popup, opt_a; {bot} is bot_2 | You paused your culture lab and had every seal checked. Stock grew scarce, so prices rose a little for a while, and the lab stood idle for a few cycles. {bot}'s strains came from the weeping vat, and its Biotech strength falls a little. A drop gathered on a seal and held.
EV_BIO_A3_OPA_STD | 90 | BIO_A3 rival line 1, opt_a | {bot2}, Biotech: strength down a little.
EV_BIO_A3_OPB_BTN | 28 | BIO_A3 button, opt_b | Sell the stock in that line
EV_BIO_A3_OPB_EFF | 200 | BIO_A3 effect line, opt_b | Get: {cash_in} credits now. Cost: Biotech volume down a little for a few cycles; {bot3} gains a little Biotech strength. Rivals: {bot2}'s Biotech strength falls clearly.
EV_BIO_A3_OPB_RES_TITLE | 32 | BIO_A3 result popup title, opt_b | The stock is sold
EV_BIO_A3_OPB_RES | 280 | BIO_A3 result popup, opt_b; {bot} is bot_2 | You sold the stock in the affected line and the cash arrived at once. The shelves stood bare for a few cycles. {bot3} bought the surplus and gains a little Biotech strength, while {bot}'s strength falls clearly as its supply line came under the notice.
EV_BIO_A3_OPB_STD | 90 | BIO_A3 rival line 1, opt_b | {bot2}, Biotech: strength down clearly.
EV_BIO_A3_OPB_STD2 | 90 | BIO_A3 rival line 2, opt_b | {bot3}, Biotech: strength up a little.

### BIO_B1 (Biotech, chain B, step 1)
EV_BIO_B1_TITLE | 40 | BIO_B1 choice screen title | A buyer needs a rare strain
EV_BIO_B1_BODY | 280 | BIO_B1 choice screen body (one body) | A hospital ring on Tillam needs a rare strain by the end of the cycle, and the cold chain is tight. {bot2} holds the stock, and {bot3} offers to carry it. You may buy the grower's stock, or culture the strain at your lab and send extra hulls.
EV_BIO_B1_OPA_BTN | 28 | BIO_B1 button, opt_a | Buy the grower's stock
EV_BIO_B1_OPA_EFF | 200 | BIO_B1 effect line, opt_a | Get: Biotech volume up clearly for a while. Cost: {cash_out} credits for the grower's stock. Rivals: {bot2}'s Biotech strength falls clearly.
EV_BIO_B1_OPA_RES_TITLE | 32 | BIO_B1 result popup title, opt_a | The stock is bought
EV_BIO_B1_OPA_RES | 280 | BIO_B1 result popup, opt_a; {bot} is bot_2 | You bought the grower's stock and shipped it as it was. The purchase cost credits, and the hospital's order kept your volume up for a while. {bot} held the only other stock, and its Biotech strength falls clearly. The crates sweated in the hold the whole way.
EV_BIO_B1_OPA_STD | 90 | BIO_B1 rival line 1, opt_a | {bot2}, Biotech: strength down clearly.
EV_BIO_B1_OPB_BTN | 28 | BIO_B1 button, opt_b | Culture it at your lab
EV_BIO_B1_OPB_EFF | 200 | BIO_B1 effect line, opt_b | Get: {n} units of tech progress at the Culture Lab. Cost: Ship upkeep rises a little for a while. Rivals: {bot3}'s Biotech strength falls a little.
EV_BIO_B1_OPB_RES_TITLE | 32 | BIO_B1 result popup title, opt_b | The lab cultures the strain
EV_BIO_B1_OPB_RES | 280 | BIO_B1 result popup, opt_b; {bot} is bot_3 | Your lab grew the strain from a seed and the extra hulls carried it. Tech progress came in, and Ship upkeep rises a little for a while. {bot} offered to carry the order and was passed over, so its Biotech strength falls a little. The strain came up a green nobody ordered.
EV_BIO_B1_OPB_STD | 90 | BIO_B1 rival line 1, opt_b | {bot3}, Biotech: strength down a little.

### BIO_B2 (Biotech, chain B, step 2)
EV_BIO_B2_TITLE | 40 | BIO_B2 choice screen title | A strain changes in storage
EV_BIO_B2_BODY_A | 280 | BIO_B2 choice screen body after opt_a of BIO_B1 | You bought the grower's stock. Now one strain in your storage has changed during testing: it grows faster and has taken a darker shade. {bot2} would like a sample, and {bot3} asks what the change is worth. You may relabel the batch, or sell it as a new line.
EV_BIO_B2_BODY_B | 280 | BIO_B2 choice screen body after opt_b of BIO_B1 | You cultured the strain at your lab. Now one strain in your storage has changed during testing: it grows faster and has taken a darker shade. {bot2} would like a sample, and {bot3} asks what the change is worth. You may relabel the batch, or sell it as a new line.
EV_BIO_B2_OPA_BTN | 28 | BIO_B2 button, opt_a | Relabel the batch
EV_BIO_B2_OPA_EFF | 200 | BIO_B2 effect line, opt_a | Get: Biotech price up a little for a while. Cost: Biotech volume down a little for a while. Rivals: {bot2}'s Biotech growth falls clearly.
EV_BIO_B2_OPA_RES_TITLE | 32 | BIO_B2 result popup title, opt_a | The batch is relabelled
EV_BIO_B2_OPA_RES | 280 | BIO_B2 result popup, opt_a; {bot} is bot_2 | You relabelled the batch and held it for study. The new line fetched a little more for a while, and your own volume dipped as stock stayed back. {bot}'s sample requests were refused, so its Biotech growth falls clearly. In the vat the darker shade has not faded.
EV_BIO_B2_OPA_STD | 90 | BIO_B2 rival line 1, opt_a | {bot2}, Biotech: growth down clearly.
EV_BIO_B2_OPB_BTN | 28 | BIO_B2 button, opt_b | Sell it as a new line
EV_BIO_B2_OPB_EFF | 200 | BIO_B2 effect line, opt_b | Get: {cash_in} credits now. Cost: Ship upkeep rises a little for a while; {bot2} gains a little Biotech strength. Rivals: {bot3} {cut} in Biotech.
EV_BIO_B2_OPB_RES_TITLE | 32 | BIO_B2 result popup title, opt_b | Sold as a new line
EV_BIO_B2_OPB_RES | 280 | BIO_B2 result popup, opt_b; {bot} is bot_3 | You sold the batch as a new line, and the cash came in. Extra hulls carried it, so Ship upkeep rises a little for a while. {bot2} bought a sample and gains a little Biotech strength, while {bot} is cut back, its old line undercut. The buyer asked for a second batch.
EV_BIO_B2_OPB_STD | 90 | BIO_B2 rival line 1, opt_b | {bot3}, Biotech: {cut_std}.
EV_BIO_B2_OPB_STD2 | 90 | BIO_B2 rival line 2, opt_b | {bot2}, Biotech: strength up a little.

### BIO_B3 (Biotech, chain B, step 3)
EV_BIO_B3_TITLE | 40 | BIO_B3 choice screen title | An exchange offers a slot
EV_BIO_B3_BODY_A | 280 | BIO_B3 choice screen body after opt_a of BIO_B2 | You relabelled the batch. A culture exchange offers you a numbered slot for your output, with a seat at the call each cycle. {bot2} holds the first slot, and {bot3} the second. You may list your output now, or buy a slot outright.
EV_BIO_B3_BODY_B | 280 | BIO_B3 choice screen body after opt_b of BIO_B2 | You sold the batch as a new line. A culture exchange offers you a numbered slot for your output, with a seat at the call each cycle. {bot2} holds the first slot, and {bot3} the second. You may list your output now, or buy a slot outright.
EV_BIO_B3_OPA_BTN | 28 | BIO_B3 button, opt_a | List your output now
EV_BIO_B3_OPA_EFF | 200 | BIO_B3 effect line, opt_a | Get: {cash_in} credits now. Cost: Biotech volume down a little for a while. Rivals: {bot2}'s Biotech strength falls sharply; {bot3}'s growth falls clearly.
EV_BIO_B3_OPA_RES_TITLE | 32 | BIO_B3 result popup title, opt_a | The output is listed
EV_BIO_B3_OPA_RES | 280 | BIO_B3 result popup, opt_a; {bot} is bot_2 | Your output went on the exchange list and the first payment cleared. Fewer lots stayed for private buyers, so volume dipped for a while. {bot} lost its first slot's edge, and its Biotech strength falls sharply, while {bot3}'s growth falls clearly. Every crate bears a slot number.
EV_BIO_B3_OPA_STD | 90 | BIO_B3 rival line 1, opt_a | {bot2}, Biotech: strength down sharply.
EV_BIO_B3_OPA_STD2 | 90 | BIO_B3 rival line 2, opt_a | {bot3}, Biotech: growth down clearly.
EV_BIO_B3_OPB_BTN | 28 | BIO_B3 button, opt_b | Buy a slot outright
EV_BIO_B3_OPB_EFF | 200 | BIO_B3 effect line, opt_b | Get: Biotech volume up a little for a while. Cost: {cash_out} credits for the slot. Rivals: {bot2}'s Biotech strength and {bot3}'s Biotech growth fall a little.
EV_BIO_B3_OPB_RES_TITLE | 32 | BIO_B3 result popup title, opt_b | A slot is bought
EV_BIO_B3_OPB_RES | 280 | BIO_B3 result popup, opt_b; {bot} is bot_2 | You bought a slot at the call and the price was paid in credits. Your lots now sell on schedule, and volume rose for a while. {bot} loses a little Biotech strength and {bot3} a little growth, as the call split their buyers. The bell at the call is struck by hand.
EV_BIO_B3_OPB_STD | 90 | BIO_B3 rival line 1, opt_b | {bot2}, Biotech: strength down a little.
EV_BIO_B3_OPB_STD2 | 90 | BIO_B3 rival line 2, opt_b | {bot3}, Biotech: growth down a little.

### BIO_B4 (Biotech, chain B, step 4)
EV_BIO_B4_TITLE | 40 | BIO_B4 choice screen title | A storage firm offers space
EV_BIO_B4_BODY_A | 280 | BIO_B4 choice screen body after opt_a of BIO_B3 | Your output is listed on the exchange. A storage firm offers cold racks for your stock at set terms. {bot2} keeps its seed in the firm's racks, and {bot3} rents the aisle beside it. You may rent racks by the cycle, or sell the firm your first claim to the aisle.
EV_BIO_B4_BODY_B | 280 | BIO_B4 choice screen body after opt_b of BIO_B3 | You hold a slot at the exchange call. A storage firm offers cold racks for your stock at set terms. {bot2} keeps its seed in the firm's racks, and {bot3} rents the aisle beside it. You may rent racks by the cycle, or sell the firm your first claim to the aisle.
EV_BIO_B4_OPA_BTN | 28 | BIO_B4 button, opt_a | Rent racks by the cycle
EV_BIO_B4_OPA_EFF | 200 | BIO_B4 effect line, opt_a | Get: Biotech price up a little for a while. Cost: Biotech volume down a little for a while. Rivals: {bot2}'s Biotech strength falls sharply.
EV_BIO_B4_OPA_RES_TITLE | 32 | BIO_B4 result popup title, opt_a | The racks are rented
EV_BIO_B4_OPA_RES | 280 | BIO_B4 result popup, opt_a; {bot} is bot_2 | You rented racks by the cycle, and your seed stayed cold on the firm's shelves. Held stock lifted prices a little for a while, and volume dipped as it waited. {bot} lost its place at the front, and its Biotech strength falls sharply. The racks hum at a pace that suits them.
EV_BIO_B4_OPA_STD | 90 | BIO_B4 rival line 1, opt_a | {bot2}, Biotech: strength down sharply.
EV_BIO_B4_OPB_BTN | 28 | BIO_B4 button, opt_b | Sell the first claim
EV_BIO_B4_OPB_EFF | 200 | BIO_B4 effect line, opt_b | Get: {cash_in} credits now. Cost: Ship upkeep rises a little for a while. Rivals: {bot2}'s and {bot3}'s Biotech strength falls clearly.
EV_BIO_B4_OPB_RES_TITLE | 32 | BIO_B4 result popup title, opt_b | The first claim is sold
EV_BIO_B4_OPB_RES | 280 | BIO_B4 result popup, opt_b; {bot} is bot_2 | You sold the firm your first claim to the aisle, and a large payment cleared. Your ships work the new routes, so Ship upkeep rises a little for a while. {bot} and {bot3} both lost the aisle, and each loses Biotech strength clearly. One lamp lights it, and does not flicker.
EV_BIO_B4_OPB_STD | 90 | BIO_B4 rival line 1, opt_b | {bot2} and {bot3}, Biotech: strength down clearly.

## Chain effect line template and rival log (added 2026-11-03)
CH_EFFECT_LINE | 200 | Effect line template for any option the game builds itself (the id game/chains.gd reads); {get}, {cost} and {rivals} are phrases without a final full stop | Get: {get}. Cost: {cost}. Rivals: {rivals}.
EV_EFF_NO_RIVALS | 90 | Effect line, Rivals part of an event that changes no rival | Rivals: no change in {market} strength or growth.

## Rival changes: Competitors menu event log (added 2026-11-03)
LBL_COMP_EVENTS | 24 | Competitors menu, heading of the log of rival changes | Recent moves
LBL_COMP_NONE | 40 | Competitors menu, log is empty | No rival moves yet.
LBL_COMP_MOVE_STR_DOWN | 60 | Competitors log line, a rival's strength fell; also used when a tier cut lands on a rival at the lowest tier | {bot}: {market} strength down
LBL_COMP_MOVE_STR_UP | 60 | Competitors log line, a rival's strength rose | {bot}: {market} strength up
LBL_COMP_MOVE_GRO_DOWN | 60 | Competitors log line, a rival's growth fell | {bot}: {market} growth down
LBL_COMP_MOVE_GRO_UP | 60 | Competitors log line, a rival's growth rose | {bot}: {market} growth up
LBL_COMP_MOVE_TIER_DOWN | 60 | Competitors log line, a rival really dropped a tier | {bot}: {market} tier down
LBL_COMP_CYCLE | 16 | Competitors log line, prefix with the cycle of the move | Cycle {n}:

## Space Storage available (2026-11-04)
STORAGE_READY_TITLE | 32 | Event window title, one-time notice when trade income unlocks the Space Storage skill (FND_STORAGE) | Space Storage is available
STORAGE_READY | 280 | Event window body, same notice, OK button below | The Bureau has stamped your form: the company has traded enough to be allowed storage in space. Learn Space Storage in the Skills window to keep stock in each open system. The stamp was still warm, and the ink moved a little.

## Permit explanation (2026-11-04)
PERMIT_WHY_TITLE | 32 | System window (galaxy view, click a system), heading of the permit explanation | Why a permit
PERMIT_WHY | 240 | System window, permit explanation under the heading; numbers are shown separately | The Bureau keeps other systems closed until a company is licensed. A permit gives you the right to run routes there, with new planets and new prices. The stamp is cold, and it hums.
PERMIT_WHY_LOCKED | 140 | System window, shown while the system is locked and Permit Charter is not learned | The Bureau will not stamp a permit yet. Learn Permit Charter in the Skills window first.
