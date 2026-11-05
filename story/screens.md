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
BTN_BACK | 24 | Settings screen and galaxy view, back button | Back
LBL_LANGUAGE | 24 | Settings screen, label of the language row (the UI adds the colon) | Language
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
ST_NO_CASH_ROUTE | 70 | Route row and map tag, a route that could not pay its trip at the last cycle end | Not enough cash: needs {need} cr, had {have} cr.
ST_NO_CASH_BUY | 80 | Buy order row, an order that could not buy one unit | Not enough cash: one unit costs {price} cr, {free} cr free after trips.

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
NOT_TUT_LOCKED | 110 | Notice, player clicks something the tutorial has muted | Not yet. Follow the tutorial step, or skip the tutorial.

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
EVT_NEXT_DUE_2 | 110 | Notice, Event Forecast 2 cycles ahead (LUX_5B), plain | An event is due in 2 cycles.
EVT_NEXT_DUE_PRICE_2 | 110 | Notice, Event Forecast 2 cycles ahead, price event; direction is "rise" or "fall" | In 2 cycles: {commodity} will {direction} at {planet}.
EVT_NEXT_DUE_CLOSED_2 | 110 | Notice, Event Forecast 2 cycles ahead, closure | In 2 cycles: {planet} will close.
LBL_BEST_PARTNER | 110 | Planet panel, Price Whisper, best route partner | Best partner: {planet} ({margin} cr per unit).
NOT_ROUTE_BELOW_UPKEEP | 110 | Notice, base game, new route margin is below its upkeep | This route earns {margin} cr a cycle and costs {cost}. It will run at a loss.
LBL_PRICE_HISTORY | 110 | Planet panel, base game, under the prices; {prices} is a list of sell prices | Recent sell prices: {prices}.
LBL_PRICE_HISTORY_NONE | 110 | Planet panel, base game, before the first cycle closes | Recent sell prices: none yet.
LBL_NEXT_PRICE | 110 | Planet panel, Price Whisper, prices for the next cycle; {buy} and {sell} are credits | Next cycle: {buy} cr to buy, {sell} cr to sell.
LBL_NEXT_PRICE_2 | 110 | Planet panel, LUX_5B, prices two cycles ahead; {buy} and {sell} are credits | In 2 cycles: {buy} cr to buy, {sell} cr to sell.

## Last fallbacks (2026-10-31, Alpha)
LBL_UNKNOWN | 24 | Galaxy view, label for a system not yet permitted | ?
PLANET_UNHAPPY | 110 | Planet panel, resident unhappiness line when above zero; {value} is a percent | Resident unhappiness: {value}

## Skill point pop-up (2026-10-31, owner item 5)
NOT_SKILL_POP_TITLE | 32 | Pop-up title when expansion points are earned; {points} is the number earned | Skill point earned: +{points}

## Guided first steps (T124, 2026-10-31, owner item 3; shown one at a time, each moves on when done)
TUT_G1_SELECT | 60 | Guided step 1, until a planet is clicked | Click Voltara, the ringed planet.
TUT_G1_SELECT_WHY | 110 | Guided step, why it matters (second line of the card) | Its panel shows what it sells, what it buys and what the company can trade there.
TUT_G2_BUY | 60 | Guided step 2, until Buy is on for a good | Press Buy on Energy.
TUT_G2_BUY_WHY | 110 | Guided step, why it matters (second line of the card) | A Buy order fills your storage on this planet each cycle.
TUT_G3_SEND | 60 | Guided step 3, until a route exists | Right-click Energy, choose Send to.
TUT_G3_PICK | 60 | Guided step 3, after Send to is chosen, until a destination is clicked | Click Ashgate to send Energy there.
TUT_G3_SEND_WHY | 110 | Guided step, why it matters (second line of the card) | Pick a planet that wants the good. A route carries your goods there by ship.
TUT_G4_ROUTE_PAY | 60 | Guided step 4, until a route has sold goods | Press the lit time button, top right, to run the cycle.
TUT_G4_ROUTE_PAY_WHY | 110 | Guided step, why it matters (second line of the card) | The route earns when it sells there. That is where your money comes from.
TUT_G5_UPKEEP | 60 | Guided step 5, after a ship is working | Find Ship upkeep under Expenses.
TUT_G5_UPKEEP_WHY | 110 | Guided step, why it matters (second line of the card) | A ship costs money every cycle, so a route must earn more than it costs.
TUT_G6_SELL | 60 | Guided step 6, until the first Sell order | Select Ashgate, right-click Energy, choose Sell.
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
LBL_PENDING_OR_STATION | 60 | Planet panel, appended to the pending-send line when the system has a Space Storage station | Or click the Space Storage station.
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
GOOD_SILK_DESC | 110 | Commodity tooltip, silk | Light cloth with a faint glow. A luxury trade good: little to carry, much to admire.
GOOD_CHIPS_NAME | 24 | Commodity name, chips | Logic Cores
GOOD_CHIPS_DESC | 110 | Commodity tooltip, chips | Small machine minds, etched by hand and counted twice. A trade good.
GOOD_ORE_NAME | 24 | Commodity name, ore | Rock Ore
GOOD_ORE_DESC | 110 | Commodity tooltip, ore | Raw rock from asteroid clusters. Free to take. A raw input for anything that needs metal.
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
BTN_CLUSTER_SEND | 20 | Cluster card, button that starts an ore route from the pack | Send ore to...
NOT_MINING_NEEDS_SKILL | 110 | Notice and cluster card, mining is locked | Mining needs the Prospecting skill.
NOT_CLUSTER_ONLY_ORE | 110 | Notice, route from a cluster with a good other than ore | A cluster gives ore only.
NOT_CLUSTER_EMPTY | 110 | Notice, route from an empty cluster | This cluster is empty.
ST_CLUSTER_EMPTY | 60 | Route panel, status when the cluster has run dry | Cluster empty
ST_CLUSTER_SHARED | 60 | Route panel, status when another ship took the cycle's ore | Ore taken by another ship

## Dead worlds: unlock, goods, Null Core (added 2026-11-03; names are working names, owner decides)
DEAD_UNLOCK | 110 | Notice, posted when the dead worlds open | Dead worlds are open. Cinderrest needs Cold Survey, Greywake needs Deep Cut.
PLANET_DEAD_LOCKED | 60 | Planet panel, dead world before it opens; {n} is the cycle | Opens at cycle {n}.
NOT_DEAD_NEEDS_SKILL | 110 | Notice, route from a dead world without its skill; {skill} is the skill name | Mining here needs {skill}.
PLANET_DANGER | 60 | Planet panel, dead world danger line; {value} and {max} are numbers | Danger: {value} of {max}
BTN_MINE_SEND | 40 | Planet panel, dead world, button under the mined goods; {good} is the good name | Mine {good} and send to...
LBL_MINE_ROW_TIP | 80 | Planet panel, dead world, tooltip of a mined good | Mine here every cycle. Press to stop.
SCR_MINE_HEADER | 30 | Planet panel, dead world, caption above the mined goods | Mining
SCR_MINE_YIELD | 40 | Planet panel, dead world, under the mined good; {n} is units per trip | {n} per trip
SCR_MINE_COST | 60 | Planet panel, dead world, line under the mined good; {price} is credits per unit | Mining cost: {price} per unit
NOT_DEAD_NO_DELIVERY | 90 | Notice, a dead world clicked as the destination of a route | Nothing is delivered to a dead world. Pick another planet.
GOOD_DROSS_NAME | 24 | Commodity name, dross | Dross Salt
GOOD_DROSS_DESC | 110 | Commodity tooltip, dross | Grey salt cut from a dead world. A raw mined good that nobody tastes twice.
GOOD_NULLGLASS_NAME | 24 | Commodity name, nullglass | Nullglass
GOOD_NULLGLASS_DESC | 110 | Commodity tooltip, nullglass | Dark glass cut from a dead world. A raw mined good that hums faintly in the hold.
GOOD_PLATE_NAME | 24 | Commodity name, plate | Lattice Plate
GOOD_PLATE_DESC | 110 | Commodity tooltip, plate | Dense plate, built rather than dug. A crafted good, heavy with the work in it.
GOOD_ENERGY_NAME | 24 | Commodity name, energy | Energy
GOOD_ENERGY_DESC | 110 | Commodity tooltip, energy | Bulk power for any world with a lamp to light. A raw good that every trade leans on.
GOOD_FOOD_NAME | 24 | Commodity name, food | Food
GOOD_FOOD_DESC | 110 | Commodity tooltip, food | Plain staple rations. A raw good that everyone needs and nobody boasts about.
GOOD_RIVETS_NAME | 24 | Commodity name, rivets | Rivets
GOOD_RIVETS_DESC | 110 | Commodity tooltip, rivets | Metal pins for ships. Bought at Voltara, sold at the system 2 yards. A trade good.
GOOD_CELLS_NAME | 24 | Commodity name, cells | Power Cells
GOOD_CELLS_DESC | 110 | Commodity tooltip, cells | Sealed power cells that keep their charge. A crafted good.
GOOD_ARMOUR_NAME | 24 | Commodity name, armour | Hull Armour
GOOD_ARMOUR_DESC | 110 | Commodity tooltip, armour | Layered hull plating for those who expect to be shot at. A crafted good.
GOOD_MUSK_NAME | 24 | Commodity name, musk | Musk
GOOD_MUSK_DESC | 110 | Commodity tooltip, musk | A strong scent, sold by the drop. A luxury trade good.
GOOD_CASK_NAME | 24 | Commodity name, cask | Festival Casks
GOOD_CASK_DESC | 110 | Commodity tooltip, cask | Sealed casks of stores kept for special days. A crafted luxury good.
GOOD_GEMS_NAME | 24 | Commodity name, gems | Cold Gems
GOOD_GEMS_DESC | 110 | Commodity tooltip, gems | Cut stones with a cold inner light. A crafted luxury, valued for being looked at.
GOOD_INGOT_NAME | 24 | Commodity name, ingot | Metal Ingots
GOOD_INGOT_DESC | 110 | Commodity tooltip, ingot | Metal bars, stacked and stamped. A crafted good.
GOOD_ALLOY_NAME | 24 | Commodity name, alloy | Furnace Alloy
GOOD_ALLOY_DESC | 110 | Commodity tooltip, alloy | Hard metal blended to a strict recipe. The finest crafted good of its kind.
GOOD_SPORES_NAME | 24 | Commodity name, spores | Jar Spores
GOOD_SPORES_DESC | 110 | Commodity tooltip, spores | Dry spores in sealed jars, handled with gloves. A trade good.
GOOD_GEL_NAME | 24 | Commodity name, gel | Living Gel
GOOD_GEL_DESC | 110 | Commodity tooltip, gel | Thick living gel that sets as it cools. A crafted good.
GOOD_SEED_NAME | 24 | Commodity name, seed | Seed Stock
GOOD_SEED_DESC | 110 | Commodity tooltip, seed | Seed stock that grows to order. The finest crafted good of its kind.
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
LBL_WORKSHOP_NEEDS | 60 | Workshop status, {items} are the visible missing inputs | needs {items}
LBL_WORKSHOP_NEEDS_OTHER | 60 | Workshop status, a missing input the player cannot see yet | another input
NOT_WORKSHOP_BUILT | 80 | Board notice after building; {workshop} is the workshop name, {system} the system whose cell it stands in | {workshop} built in {system}.

## Skill points from share (added 2026-11-03)
NOT_SKILL_REASON_SHARE | 110 | Notice, a skill point earned when a market share passes a step; {market} is the market, {pct} the step | Your {market} share passed {pct}%.

## Market chains (28 steps; added 2026-11-03, from design/proposals/2026-11-03-four-markets-story.md)
Chain text for Military, Luxury, Minerals and Biotech, steps A1 to A3 and B1 to B4. Ids: EV_<step>_<field>, for example EV_MIL_A1_TITLE. Fields: TITLE, BODY (A1 and B1) or BODY_A and BODY_B (steps 2 and later, keyed to the option picked in the previous step of the same chain), OPA_BTN, OPA_EFF, OPA_RES_TITLE, OPA_RES, OPA_STD, OPA_STD2 (second rival line, only where the option has two), and the same for OPB. The placeholders are documented at the top of story/events.md, section "Chain placeholders". Option ids opt_a and opt_b are internal; the game may shuffle the button order. No text states a direction, a count or a stance.

### MIL_A1 (Military, chain A, step 1)
EV_MIL_A1_TITLE | 40 | MIL_A1 choice screen title | A garrison has a war to feed
EV_MIL_A1_BODY | 280 | MIL_A1 choice screen body (one body) | The Admiralty wills Ashgate's high-ring garrison to keep fighting, and Quartermaster Hanno Sulo wills the invoices to match. He bought your first cargo. {bot1} once sent him painted ballast marked as shells. He offers a standing contract with a deposit, or cash by the lot.
EV_MIL_A1_OPA_BTN | 28 | MIL_A1 button, opt_a | Sign the contract
EV_MIL_A1_OPA_EFF | 200 | MIL_A1 effect line, opt_a | Get: Military volume up a little for a while. Cost: {cash_out} credits as the deposit to the garrison. Rivals: {bot1}'s Military growth falls a little.
EV_MIL_A1_OPA_RES_TITLE | 32 | MIL_A1 result popup title, opt_a | The contract is signed
EV_MIL_A1_OPA_RES | 280 | MIL_A1 result popup, opt_a; {bot} is bot_1 | Sulo signed with a seal and kept {bot} as a second source, on probation. Orders now come on a schedule and the deposit cost you credits, so Military volume rises for a while. {bot}'s Military growth falls a little. Each crate is read a litany on the dock, and one rattled.
EV_MIL_A1_OPA_STD | 90 | MIL_A1 rival line 1, opt_a | {bot1}, Military: growth down a little.
EV_MIL_A1_OPB_BTN | 28 | MIL_A1 button, opt_b | Sell by the lot
EV_MIL_A1_OPB_EFF | 200 | MIL_A1 effect line, opt_b | Get: {cash_in} credits now. Cost: Military volume down a little for a few cycles; {bot3} gains a little Military strength. Rivals: {bot1}'s Military strength falls a little.
EV_MIL_A1_OPB_RES_TITLE | 32 | MIL_A1 result popup title, opt_b | Sold by the lot
EV_MIL_A1_OPB_RES | 280 | MIL_A1 result popup, opt_b; {bot} is bot_1 | Sulo counted the cargo against the estimate and paid cash at the dock. Your own orders dip for a few cycles while the berth stands empty. {bot3} takes the berth and gains a little Military strength. {bot}, found with its painted ballast, sees its Military strength fall a little.
EV_MIL_A1_OPB_STD | 90 | MIL_A1 rival line 1, opt_b | {bot1}, Military: strength down a little.
EV_MIL_A1_OPB_STD2 | 90 | MIL_A1 rival line 2, opt_b | {bot3}, Military: strength up a little.

### MIL_A2 (Military, chain A, step 2)
EV_MIL_A2_TITLE | 40 | MIL_A2 choice screen title | Two fleets claim the same stock
EV_MIL_A2_BODY_A | 280 | MIL_A2 choice screen body after opt_a of MIL_A1 | Your contract holds. Two fleets, each sworn to a different estimate, order the same stock in one cycle, and the Admiralty wills both served first. {bot3} brokers between them and bills both. {bot1} serves one fleet. Fill orders in dock order, or by contract term.
EV_MIL_A2_BODY_B | 280 | MIL_A2 choice screen body after opt_b of MIL_A1 | The garrison has its cargo. Two fleets, each sworn to a different estimate, order the same stock in one cycle, and the Admiralty wills both served first. {bot3} brokers between them and bills both. {bot1} serves one fleet. Fill orders in dock order, or by contract term.
EV_MIL_A2_OPA_BTN | 28 | MIL_A2 button, opt_a | Fill orders by dock
EV_MIL_A2_OPA_EFF | 200 | MIL_A2 effect line, opt_a | Get: Military price up a little for a while. Cost: Ship upkeep rises a little for a while. Rivals: {bot3}'s Military growth falls a little.
EV_MIL_A2_OPA_RES_TITLE | 32 | MIL_A2 result popup title, opt_a | Orders filled by dock
EV_MIL_A2_OPA_RES | 280 | MIL_A2 result popup, opt_a; {bot} is bot_3 | Orders went out in dock order, and each fleet was told the other had waited longer. The bidding lifts Military prices a little for a while, and two sets of berths raise Ship upkeep a little. {bot}, the go-between, is one messenger too many: its Military growth falls a little.
EV_MIL_A2_OPA_STD | 90 | MIL_A2 rival line 1, opt_a | {bot3}, Military: growth down a little.
EV_MIL_A2_OPB_BTN | 28 | MIL_A2 button, opt_b | Fill orders by term
EV_MIL_A2_OPB_EFF | 200 | MIL_A2 effect line, opt_b | Get: {n} units of tech progress at the Munitions Line. Cost: {cash_out} credits for the stock. Rivals: {bot1} {cut} in Military.
EV_MIL_A2_OPB_RES_TITLE | 32 | MIL_A2 result popup title, opt_b | Orders filled by term
EV_MIL_A2_OPB_RES | 280 | MIL_A2 result popup, opt_b; {bot} is bot_1 | Orders went out by term. The fleet {bot1} does not serve held better terms. Its engineers left notes, and your engineer Tavi Brask read them to the press. Tech progress came in at the Munitions Line. {bot}'s client fell behind, so {bot} was cut back. The stock cost credits.
EV_MIL_A2_OPB_STD | 90 | MIL_A2 rival line 1, opt_b | {bot1}, Military: {cut_std}.

### MIL_A3 (Military, chain A, step 3)
EV_MIL_A3_TITLE | 40 | MIL_A3 choice screen title | Sulo sells a stolen ledger
EV_MIL_A3_BODY_A | 280 | MIL_A3 choice screen body after opt_a of MIL_A2 | Your orders went out in dock order. Sulo, who changed posts and not habits, waits on the dock with a case: {bot1}'s ledger of clients and berths, copied by hand at night, sealed with the Quartermaster-Saint's thumb. He names a price. A ledger is only a list until it is read.
EV_MIL_A3_BODY_B | 280 | MIL_A3 choice screen body after opt_b of MIL_A2 | Your orders went out by contract term. Sulo, who changed posts and not habits, waits on the dock with a case: {bot1}'s ledger of clients and berths, copied by hand at night, sealed with the Quartermaster-Saint's thumb. He names a price. A ledger is only a list until it is read.
EV_MIL_A3_OPA_BTN | 28 | MIL_A3 button, opt_a | Hand it to your buyers
EV_MIL_A3_OPA_EFF | 200 | MIL_A3 effect line, opt_a | Get: {cash_in} credits; Military volume up a little for a while. Cost: Ship upkeep up a little for a while; {bot3} gains a little Military strength. Rivals: {bot1}'s Military strength falls clearly.
EV_MIL_A3_OPA_RES_TITLE | 32 | MIL_A3 result popup title, opt_a | The ledger goes to buyers
EV_MIL_A3_OPA_RES | 280 | MIL_A3 result popup, opt_a; {bot} is bot_1 | Your buyers read the ledger aloud and called on every client it listed. Cash came in and orders rose, and the extra hulls raise Ship upkeep a little for a while. {bot}'s Military strength falls clearly. Sulo sold a second copy to {bot3}, whose Military strength rises a little.
EV_MIL_A3_OPA_STD | 90 | MIL_A3 rival line 1, opt_a | {bot1}, Military: strength down clearly.
EV_MIL_A3_OPA_STD2 | 90 | MIL_A3 rival line 2, opt_a | {bot3}, Military: strength up a little.
EV_MIL_A3_OPB_BTN | 28 | MIL_A3 button, opt_b | Hand it to your workshop
EV_MIL_A3_OPB_EFF | 200 | MIL_A3 effect line, opt_b | Get: {n} units of tech progress at the Munitions Line. Cost: {cash_out} credits to the quartermaster. Rivals: {bot1}'s Military strength and {bot3}'s Military growth fall a little.
EV_MIL_A3_OPB_RES_TITLE | 32 | MIL_A3 result popup title, opt_b | The ledger goes to the shop
EV_MIL_A3_OPB_RES | 280 | MIL_A3 result popup, opt_b; {bot} is bot_1 | Your workshop set the ledger's parts and casting notes beside your own. Tech progress came in at the Munitions Line, and Sulo's price cost credits. {bot}'s Military strength falls a little, and {bot3}, whose orders were listed too, grows more slowly. Brask thanked the book.
EV_MIL_A3_OPB_STD | 90 | MIL_A3 rival line 1, opt_b | {bot1}, Military: strength down a little.
EV_MIL_A3_OPB_STD2 | 90 | MIL_A3 rival line 2, opt_b | {bot3}, Military: growth down a little.

### MIL_B1 (Military, chain B, step 1)
EV_MIL_B1_TITLE | 40 | MIL_B1 choice screen title | A new admiral orders new sensors
EV_MIL_B1_BODY | 280 | MIL_B1 choice screen body (one body) | New Admiral Gabe Nuer took the high ring, and the next day came an order: fit his tracking sensors or pay a heavy port fee. Only his cousin's firm sells them, through {bot1}'s berths, in blessed crates. {bot3} had its own sensors ready. Someone wants the whole market.
EV_MIL_B1_OPA_BTN | 28 | MIL_B1 button, opt_a | Report the scheme
EV_MIL_B1_OPA_EFF | 200 | MIL_B1 effect line, opt_a | Get: {cash_in} credits now. Cost: Ship upkeep rises clearly for a while. Rivals: {bot1}'s Military strength falls sharply.
EV_MIL_B1_OPA_RES_TITLE | 32 | MIL_B1 result popup title, opt_a | The scheme is reported
EV_MIL_B1_OPA_RES | 280 | MIL_B1 result popup, opt_a; {bot} is bot_1 | You sent the order, the price list and the cousin's name to the Bureau. It paid an informant's fee and froze half the refit berths for audit. Your ships stand in queues, so Ship upkeep rises for a while. {bot}'s Military strength falls sharply: the scheme ran on its berths.
EV_MIL_B1_OPA_STD | 90 | MIL_B1 rival line 1, opt_a | {bot1}, Military: strength down sharply.
EV_MIL_B1_OPB_BTN | 28 | MIL_B1 button, opt_b | Fit the sensors
EV_MIL_B1_OPB_EFF | 200 | MIL_B1 effect line, opt_b | Get: Military volume up a little for the rest of the run. Cost: {cash_out} credits for the slips. Rivals: {bot3}'s Military growth falls a little.
EV_MIL_B1_OPB_RES_TITLE | 32 | MIL_B1 result popup title, opt_b | The sensors are fitted
EV_MIL_B1_OPB_RES | 280 | MIL_B1 result popup, opt_b; {bot} is bot_3 | You paid for the sensors and fitted every ship. The admiral's lanes now list you as trusted, so your Military volume rises for the rest of the run. {bot}'s own sensors were turned away, and its Military growth falls a little. The new sensors hum a canticle no list names.
EV_MIL_B1_OPB_STD | 90 | MIL_B1 rival line 1, opt_b | {bot3}, Military: growth down a little.

### MIL_B2 (Military, chain B, step 2)
EV_MIL_B2_TITLE | 40 | MIL_B2 choice screen title | Inspector Voss queries a relay
EV_MIL_B2_BODY_A | 280 | MIL_B2 choice screen body after opt_a of MIL_B1 | Since your report, Inspector Kethra Voss audits every refit, her stamp worn like a sidearm. One relay in your batch bears the serial of a ship scrapped before your time. {bot2}'s parade squadrons carry it too, and {bot1}'s older fleets. Send it for review, or swap it and refile.
EV_MIL_B2_BODY_B | 280 | MIL_B2 choice screen body after opt_b of MIL_B1 | Your fleet wears the admiral's sensors. Inspector Kethra Voss, her stamp worn like a sidearm, queries one relay: it bears the serial of a ship scrapped before your time. {bot2}'s parade squadrons carry it too, and {bot1}'s older fleets. Send it for review, or swap it and refile.
EV_MIL_B2_OPA_BTN | 28 | MIL_B2 button, opt_a | Send the part for review
EV_MIL_B2_OPA_EFF | 200 | MIL_B2 effect line, opt_a | Get: Military price up a little for a while. Cost: one route's trip cost rises a little for a while. Rivals: {bot2}'s Military strength falls a little.
EV_MIL_B2_OPA_RES_TITLE | 32 | MIL_B2 result popup title, opt_a | The office reviews the part
EV_MIL_B2_OPA_RES | 280 | MIL_B2 result popup, opt_a; {bot} is bot_2 | The relay went for review. Voss read your forms, then everyone's. {bot}, whose squadrons carry that relay, lost contracts, and its Military strength falls a little. The cleared stamp lifts Military prices for a while. One route sat in customs, and its trip cost rises a little.
EV_MIL_B2_OPA_STD | 90 | MIL_B2 rival line 1, opt_a | {bot2}, Military: strength down a little.
EV_MIL_B2_OPB_BTN | 28 | MIL_B2 button, opt_b | Swap the part and refile
EV_MIL_B2_OPB_EFF | 200 | MIL_B2 effect line, opt_b | Get: {cash_in} credits for the old part. Cost: Military volume down a little for a few cycles. Rivals: {bot1}'s Military strength falls a little.
EV_MIL_B2_OPB_RES_TITLE | 32 | MIL_B2 result popup title, opt_b | The part is swapped
EV_MIL_B2_OPB_RES | 280 | MIL_B2 result popup, opt_b; {bot} is bot_1 | You swapped the relay and refiled. The old part sold for credits, still humming its dead ship's litany. Voss applied the same clause to {bot1}'s older fleets, which stood idle, so {bot}'s Military strength falls a little. Ships waited, and Military volume dips for a few cycles.
EV_MIL_B2_OPB_STD | 90 | MIL_B2 rival line 1, opt_b | {bot1}, Military: strength down a little.

### MIL_B3 (Military, chain B, step 3)
EV_MIL_B3_TITLE | 40 | MIL_B3 choice screen title | The Feast of Arms offers a stall
EV_MIL_B3_BODY_A | 280 | MIL_B3 choice screen body after opt_a of MIL_B2 | The relay review is done. Madame Orlenne Vaux, who runs the high-ring Feast of Arms, offers you a place. {bot3} keeps a stand there every year, always crowded. {bot2} holds a gala next door. Buy the main hall for the week, or take the east stand beside {bot3}'s.
EV_MIL_B3_BODY_B | 280 | MIL_B3 choice screen body after opt_b of MIL_B2 | The inspector has ruled on the new relay. Madame Orlenne Vaux, who runs the high-ring Feast of Arms, offers you a place. {bot3} keeps a stand there every year, always crowded. {bot2} holds a gala next door. Buy the main hall for the week, or take the east stand beside {bot3}'s.
EV_MIL_B3_OPA_BTN | 28 | MIL_B3 button, opt_a | Buy the main hall
EV_MIL_B3_OPA_EFF | 200 | MIL_B3 effect line, opt_a | Get: Military volume up a little for a while. Cost: {cash_out} credits for the main hall. Rivals: {bot3}'s Military strength falls clearly.
EV_MIL_B3_OPA_RES_TITLE | 32 | MIL_B3 result popup title, opt_a | The main hall is yours
EV_MIL_B3_OPA_RES | 280 | MIL_B3 result popup, opt_a; {bot} is bot_3 | You bought the hall for the week, and it cost credits. Buyers walked past empty stands to reach yours, so your Military volume rises for a while. {bot} sold from the corridor, and its Military strength falls clearly. The relic cannon, which fires blanks only, saluted you.
EV_MIL_B3_OPA_STD | 90 | MIL_B3 rival line 1, opt_a | {bot3}, Military: strength down clearly.
EV_MIL_B3_OPB_BTN | 28 | MIL_B3 button, opt_b | Take the east stand
EV_MIL_B3_OPB_EFF | 200 | MIL_B3 effect line, opt_b | Get: {n} units of tech progress. Cost: {cash_out} credits for the stand. Rivals: {bot2}'s strength and all three rivals' growth fall a little in Military.
EV_MIL_B3_OPB_RES_TITLE | 32 | MIL_B3 result popup title, opt_b | The east stand
EV_MIL_B3_OPB_RES | 280 | MIL_B3 result popup, opt_b; {bot} is bot_1 | You took the east stand beside {bot3}'s and paid on the day. Two engineers from the next stand talked shop for an hour, and tech progress came in. {bot2}, whose gala crowd walked past, loses a little Military strength, and all three rivals, {bot} among them, grow more slowly.
EV_MIL_B3_OPB_STD | 90 | MIL_B3 rival line 1, opt_b | All three rivals, Military: growth down a little.
EV_MIL_B3_OPB_STD2 | 90 | MIL_B3 rival line 2, opt_b | {bot2}, Military: strength down a little.

### MIL_B4 (Military, chain B, step 4)
EV_MIL_B4_TITLE | 40 | MIL_B4 choice screen title | A Fleet Office clerk asks for terms
EV_MIL_B4_BODY_A | 280 | MIL_B4 choice screen body after opt_a of MIL_B3 | Your week in the main hall brought the fleets to you. A Fleet Office clerk asks you to set the terms of a supply agreement for many cycles, under an estimate that renews itself with the words until victory. Roster deliveries by garrison, or by week. {bot} watches from the door.
EV_MIL_B4_BODY_B | 280 | MIL_B4 choice screen body after opt_b of MIL_B3 | Your days at the east stand brought the fleets to you. A Fleet Office clerk asks you to set the terms of a supply agreement for many cycles, under an estimate that renews itself with the words until victory. Roster deliveries by garrison, or by week. {bot} watches from the door.
EV_MIL_B4_OPA_BTN | 28 | MIL_B4 button, opt_a | Roster by garrison
EV_MIL_B4_OPA_EFF | 200 | MIL_B4 effect line, opt_a | Get: Military price up a little for a while. Cost: Military volume down a little for a while. Rivals: {bot1}'s Military strength falls clearly.
EV_MIL_B4_OPA_RES_TITLE | 32 | MIL_B4 result popup title, opt_a | Rostered by garrison
EV_MIL_B4_OPA_RES | 280 | MIL_B4 result popup, opt_a; {bot} is bot_1 | Deliveries are rostered by garrison, each with its own price sheet and blessing. Military orders thinned for a while as the rosters were written, and the price of standing orders rose. {bot} had counted on the fleets as its client, and its Military strength falls clearly.
EV_MIL_B4_OPA_STD | 90 | MIL_B4 rival line 1, opt_a | {bot1}, Military: strength down clearly.
EV_MIL_B4_OPB_BTN | 28 | MIL_B4 button, opt_b | Roster by week
EV_MIL_B4_OPB_EFF | 200 | MIL_B4 effect line, opt_b | Get: {cash_in} credits. Cost: Ship upkeep rises clearly for a while. Rivals: {bot1}'s Military strength falls clearly; {bot3}'s falls a little.
EV_MIL_B4_OPB_RES_TITLE | 32 | MIL_B4 result popup title, opt_b | Rostered by week
EV_MIL_B4_OPB_RES | 280 | MIL_B4 result popup, opt_b; {bot} is bot_1 | Deliveries are rostered by week from your desk, and the fleets are held ready. A large payment arrived, and the clerk blessed the roster with a stamp. Ships kept ready cost more, so Ship upkeep rises for a while. {bot}'s Military strength falls clearly, and {bot3}'s a little.
EV_MIL_B4_OPB_STD | 90 | MIL_B4 rival line 1, opt_b | {bot1}, Military: strength down clearly.
EV_MIL_B4_OPB_STD2 | 90 | MIL_B4 rival line 2, opt_b | {bot3}, Military: strength down a little.

### LUX_A1 (Luxury, chain A, step 1)
EV_LUX_A1_TITLE | 40 | LUX_A1 choice screen title | A patron wants every first crate
EV_LUX_A1_BODY | 280 | LUX_A1 choice screen body (one body) | Madame Ysolde Marr, a patron on Quillon's gallery ring, wants the first crate of each cycle before any other buyer. She says a crate picks its owner by smell. {bot2} supplies her now, and {bot3} keeps a counter on the same ring. Set a first-pick price, or sell one first lot.
EV_LUX_A1_OPA_BTN | 28 | LUX_A1 button, opt_a | Set a first-pick price
EV_LUX_A1_OPA_EFF | 200 | LUX_A1 effect line, opt_a | Get: Luxury price up a little for a while. Cost: Luxury volume down a little for a while. Rivals: {bot2}'s Luxury strength falls a little.
EV_LUX_A1_OPA_RES_TITLE | 32 | LUX_A1 result popup title, opt_a | The first pick is priced
EV_LUX_A1_OPA_RES | 280 | LUX_A1 result popup, opt_a; {bot} is bot_2 | Madame Marr agreed a first-pick price, and crates now go to the gallery ring before the shelves. Fewer reach the counters, so Luxury volume dips for a while, and prices rise a little. {bot} lost her first look, and its Luxury strength falls a little. She sniffed every lid.
EV_LUX_A1_OPA_STD | 90 | LUX_A1 rival line 1, opt_a | {bot2}, Luxury: strength down a little.
EV_LUX_A1_OPB_BTN | 28 | LUX_A1 button, opt_b | Sell one first lot
EV_LUX_A1_OPB_EFF | 200 | LUX_A1 effect line, opt_b | Get: {cash_in} credits now. Cost: Luxury volume down a little for a few cycles; {bot2} grows a little faster in Luxury. Rivals: {bot3}'s Luxury strength falls a little.
EV_LUX_A1_OPB_RES_TITLE | 32 | LUX_A1 result popup title, opt_b | The first lot is sold
EV_LUX_A1_OPB_RES | 280 | LUX_A1 result popup, opt_b; {bot} is bot_3 | Madame Marr paid for one first lot at the dock, and the cash arrived the same hour. Shelves stood bare for a few cycles. {bot2} supplied her next lot and grows a little faster in Luxury, while {bot} finds its counter on the ring emptier and its strength falls a little.
EV_LUX_A1_OPB_STD | 90 | LUX_A1 rival line 1, opt_b | {bot3}, Luxury: strength down a little.
EV_LUX_A1_OPB_STD2 | 90 | LUX_A1 rival line 2, opt_b | {bot2}, Luxury: growth up a little.

### LUX_A2 (Luxury, chain A, step 2)
EV_LUX_A2_TITLE | 40 | LUX_A2 choice screen title | A master finisher takes offers
EV_LUX_A2_BODY_A | 280 | LUX_A2 choice screen body after opt_a of LUX_A1 | The first pick is priced and the crates go out. Master finisher Oren Vask has left his guild atelier, which called his signature a smudge, and takes offers for a season. {bot2} wants his hands for its own gem room. Hire him, or take his finished pieces on contract.
EV_LUX_A2_BODY_B | 280 | LUX_A2 choice screen body after opt_b of LUX_A1 | The patron has bought her first lot. Master finisher Oren Vask has left his guild atelier, which called his signature a smudge, and takes offers for a season. {bot2} wants his hands for its own gem room. Hire him, or take his finished pieces on contract.
EV_LUX_A2_OPA_BTN | 28 | LUX_A2 button, opt_a | Hire the finisher
EV_LUX_A2_OPA_EFF | 200 | LUX_A2 effect line, opt_a | Get: {n} units of tech progress at the Atelier. Cost: {cash_out} credits in fees. Rivals: {bot2}'s Luxury growth falls sharply.
EV_LUX_A2_OPA_RES_TITLE | 32 | LUX_A2 result popup title, opt_a | The finisher joins the atelier
EV_LUX_A2_OPA_RES | 280 | LUX_A2 result popup, opt_a; {bot} is bot_2 | Vask took a bench in your atelier and showed the crew a cut they had not seen. Tech progress came in, and the fees were paid. {bot} had planned his hands for its gem room, and its Luxury growth falls sharply. His chalk marks are still on the old bench.
EV_LUX_A2_OPA_STD | 90 | LUX_A2 rival line 1, opt_a | {bot2}, Luxury: growth down sharply.
EV_LUX_A2_OPB_BTN | 28 | LUX_A2 button, opt_b | Take the pieces
EV_LUX_A2_OPB_EFF | 200 | LUX_A2 effect line, opt_b | Get: Luxury volume up a little for the rest of the run. Cost: Luxury price down a little for a few cycles. Rivals: {bot2} {cut} in Luxury.
EV_LUX_A2_OPB_RES_TITLE | 32 | LUX_A2 result popup title, opt_b | Pieces on contract
EV_LUX_A2_OPB_RES | 280 | LUX_A2 result popup, opt_b; {bot} is bot_2 | Vask's pieces came to you on contract and fill your counters, priced a little low for a few cycles, so Luxury volume rises for the rest of the run. {bot} lost his work and was cut back in Luxury. The gems carry a hallmark in a hand nobody knows.
EV_LUX_A2_OPB_STD | 90 | LUX_A2 rival line 1, opt_b | {bot2}, Luxury: {cut_std}.

### LUX_A3 (Luxury, chain A, step 3)
EV_LUX_A3_TITLE | 40 | LUX_A3 choice screen title | A buyer returns a rival's batch
EV_LUX_A3_BODY_A | 280 | LUX_A3 choice screen body after opt_a of LUX_A2 | Vask is at your atelier. Lord Ferrin Gale has sent back a whole batch of {bot2}'s work, calling it loud, and asks you to fill the order. He pays a premium for a name, or gives a place on his list for a price a little low. {bot3} keeps a table at his door.
EV_LUX_A3_BODY_B | 280 | LUX_A3 choice screen body after opt_b of LUX_A2 | Vask's pieces are on your counters. Lord Ferrin Gale has sent back a whole batch of {bot2}'s work, calling it loud, and asks you to fill the order. He pays a premium for a name, or gives a place on his list for a price a little low. {bot3} keeps a table at his door.
EV_LUX_A3_OPA_BTN | 28 | LUX_A3 button, opt_a | Fill the order by name
EV_LUX_A3_OPA_EFF | 200 | LUX_A3 effect line, opt_a | Get: Luxury price up clearly for a while. Cost: {cash_out} credits for the hallmarks. Rivals: {bot2}'s Luxury strength falls sharply for a few cycles.
EV_LUX_A3_OPA_RES_TITLE | 32 | LUX_A3 result popup title, opt_a | Filled by name
EV_LUX_A3_OPA_RES | 280 | LUX_A3 result popup, opt_a; {bot} is bot_2 | You filled the order under your own mark, and Lord Gale paid the premium. The hallmarks cost credits. {bot}, whose batch was sent back, loses Luxury strength sharply for a few cycles. The returned crates sit in his cellar, unopened, and he has not asked for a receipt.
EV_LUX_A3_OPA_STD | 90 | LUX_A3 rival line 1, opt_a | {bot2}, Luxury: strength down sharply for a few cycles.
EV_LUX_A3_OPB_BTN | 28 | LUX_A3 button, opt_b | Fill the order by list
EV_LUX_A3_OPB_EFF | 200 | LUX_A3 effect line, opt_b | Get: Luxury volume up a little for a while. Cost: Luxury price down a little for a few cycles. Rivals: {bot3}'s Luxury strength falls a little.
EV_LUX_A3_OPB_RES_TITLE | 32 | LUX_A3 result popup title, opt_b | Filled by list
EV_LUX_A3_OPB_RES | 280 | LUX_A3 result popup, opt_b; {bot} is bot_3 | You filled the order for a place on Lord Gale's list, at a price a little low for a few cycles. His list sends its friends, so your orders rose for a while. {bot}, whose table stood by the door, loses a little Luxury strength. The list is written in green ink.
EV_LUX_A3_OPB_STD | 90 | LUX_A3 rival line 1, opt_b | {bot3}, Luxury: strength down a little.

### LUX_B1 (Luxury, chain B, step 1)
EV_LUX_B1_TITLE | 40 | LUX_B1 choice screen title | A pavilion books a masked evening
EV_LUX_B1_BODY | 280 | LUX_B1 choice screen body (one body) | The pavilion on the Quillon ring has booked an Evening of Many Faces, where every guest arrives as someone else, and wants stock: silk, sunmusk, cut glimmers. {bot2} supplies its cellar, and {bot3} waits with samples. Sell the venue its stock, or stock the stalls yourself.
EV_LUX_B1_OPA_BTN | 28 | LUX_B1 button, opt_a | Sell the venue its stock
EV_LUX_B1_OPA_EFF | 200 | LUX_B1 effect line, opt_a | Get: {cash_in} credits now. Cost: Luxury volume down a little for a while. Rivals: {bot2}'s Luxury growth falls a little.
EV_LUX_B1_OPA_RES_TITLE | 32 | LUX_B1 result popup title, opt_a | The venue buys its stock
EV_LUX_B1_OPA_RES | 280 | LUX_B1 result popup, opt_a; {bot} is bot_2 | The venue bought its stock outright and paid on the night. Your own counters ran thin while the crates were gone, so Luxury volume dips for a while. {bot}'s cellar supply lost the date, and its Luxury growth falls a little. Every mask in the pavilion faced the door.
EV_LUX_B1_OPA_STD | 90 | LUX_B1 rival line 1, opt_a | {bot2}, Luxury: growth down a little.
EV_LUX_B1_OPB_BTN | 28 | LUX_B1 button, opt_b | Stock the stalls yourself
EV_LUX_B1_OPB_EFF | 200 | LUX_B1 effect line, opt_b | Get: Luxury volume up clearly for a while. Cost: {cash_out} credits for the stalls. Rivals: {bot2}'s Luxury strength falls clearly.
EV_LUX_B1_OPB_RES_TITLE | 32 | LUX_B1 result popup title, opt_b | Your stalls fill the evening
EV_LUX_B1_OPB_RES | 280 | LUX_B1 result popup, opt_b; {bot} is bot_2 | Your stalls stood in the pavilion all evening, and buyers came to them first. Your orders rose for a while, and the stalls cost credits. {bot} found its crates unwanted, and its Luxury strength falls clearly. A mask with nothing behind it hung on every pillar.
EV_LUX_B1_OPB_STD | 90 | LUX_B1 rival line 1, opt_b | {bot2}, Luxury: strength down clearly.

### LUX_B2 (Luxury, chain B, step 2)
EV_LUX_B2_TITLE | 40 | LUX_B2 choice screen title | The guest list is posted on a wall
EV_LUX_B2_BODY_A | 280 | LUX_B2 choice screen body after opt_a of LUX_B1 | You sold the venue its stock. The next morning the pavilion's guest list, every name and every order, hung on a wall for a day. {bot3} copied it by the hour, and {bot2} denied there was a list. Study the list at your atelier, or sell your copy.
EV_LUX_B2_BODY_B | 280 | LUX_B2 choice screen body after opt_b of LUX_B1 | You stocked the venue's stalls. The next morning the pavilion's guest list, every name and every order, hung on a wall for a day. {bot3} copied it by the hour, and {bot2} denied there was a list. Study the list at your atelier, or sell your copy.
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
EV_LUX_B3_BODY_A | 280 | LUX_B3 choice screen body after opt_a of LUX_B2 | You studied the list. A buyer of masks and glimmers asks you to name one price and hold it for a set period. {bot2} would sell to the buyer at floating rates, and {bot1} would take any contract that moves stock. Fix the price, or sell the lot at today's rate.
EV_LUX_B3_BODY_B | 280 | LUX_B3 choice screen body after opt_b of LUX_B2 | You sold your copy of the list. A buyer of masks and glimmers asks you to name one price and hold it for a set period. {bot2} would sell to the buyer at floating rates, and {bot1} would take any contract that moves stock. Fix the price, or sell the lot at today's rate.
EV_LUX_B3_OPA_BTN | 28 | LUX_B3 button, opt_a | Fix the price for a term
EV_LUX_B3_OPA_EFF | 200 | LUX_B3 effect line, opt_a | Get: Luxury price up clearly for a while. Cost: Luxury volume down a little for a while. Rivals: {bot2}'s Luxury growth falls sharply.
EV_LUX_B3_OPA_RES_TITLE | 32 | LUX_B3 result popup title, opt_a | The price is fixed
EV_LUX_B3_OPA_RES | 280 | LUX_B3 result popup, opt_a; {bot} is bot_2 | The buyer signed one price for the whole term, and your counters held it. Luxury prices rose clearly for a while, and your volume eased as casual buyers stayed away. {bot}'s floating rates could not follow, and its Luxury growth falls sharply. The stamp is shaped like a mask.
EV_LUX_B3_OPA_STD | 90 | LUX_B3 rival line 1, opt_a | {bot2}, Luxury: growth down sharply.
EV_LUX_B3_OPB_BTN | 28 | LUX_B3 button, opt_b | Sell the lot at today's rate
EV_LUX_B3_OPB_EFF | 200 | LUX_B3 effect line, opt_b | Get: {cash_in} credits now. Cost: Luxury volume down a little for a while; {bot3} gains a little Luxury strength. Rivals: {bot1}'s and {bot2}'s Luxury strength falls a little.
EV_LUX_B3_OPB_RES_TITLE | 32 | LUX_B3 result popup title, opt_b | The lot is sold
EV_LUX_B3_OPB_RES | 280 | LUX_B3 result popup, opt_b; {bot} is bot_1 | You sold the lot at the day's rate and the cash came in. Your shelves ran lean for a while. {bot3} picked up what the buyer still wanted and gains a little Luxury strength, while {bot} and {bot2} each lose a little. The buyer left with the crates and no receipt.
EV_LUX_B3_OPB_STD | 90 | LUX_B3 rival line 1, opt_b | {bot1} and {bot2}, Luxury: strength down a little.
EV_LUX_B3_OPB_STD2 | 90 | LUX_B3 rival line 2, opt_b | {bot3}, Luxury: strength up a little.

### LUX_B4 (Luxury, chain B, step 4)
EV_LUX_B4_TITLE | 40 | LUX_B4 choice screen title | The Guild of Masks offers a seat
EV_LUX_B4_BODY_A | 280 | LUX_B4 choice screen body after opt_a of LUX_B3 | Your fixed price held through the term, and the guild noticed. The Guild of Masks offers you a seat on its board. {bot2} holds the chair, and {bot3} sits by the door. Take the pricing desk or the stock desk. Both meet weekly behind a gilt screen.
EV_LUX_B4_BODY_B | 280 | LUX_B4 choice screen body after opt_b of LUX_B3 | You sold the lot at the day's rate, and the guild noticed. The Guild of Masks offers you a seat on its board. {bot2} holds the chair, and {bot3} sits by the door. Take the pricing desk or the stock desk. Both meet weekly behind a gilt screen.
EV_LUX_B4_OPA_BTN | 28 | LUX_B4 button, opt_a | Take the pricing desk
EV_LUX_B4_OPA_EFF | 200 | LUX_B4 effect line, opt_a | Get: Luxury price up a little for a while. Cost: {cash_out} credits in dues for the pricing seat. Rivals: {bot2}'s Luxury strength falls sharply.
EV_LUX_B4_OPA_RES_TITLE | 32 | LUX_B4 result popup title, opt_a | The pricing desk is yours
EV_LUX_B4_OPA_RES | 280 | LUX_B4 result popup, opt_a; {bot} is bot_2 | You took the pricing desk and paid the dues on the day. The guild's price sheets now carry your marks, and prices rose a little for a while. {bot} sat in the chair and watched its Luxury strength fall sharply. The sheets are printed on gilt-edged paper.
EV_LUX_B4_OPA_STD | 90 | LUX_B4 rival line 1, opt_a | {bot2}, Luxury: strength down sharply.
EV_LUX_B4_OPB_BTN | 28 | LUX_B4 button, opt_b | Take the stock desk
EV_LUX_B4_OPB_EFF | 200 | LUX_B4 effect line, opt_b | Get: Luxury volume up a little for the rest of the run. Cost: Luxury price down a little for a while. Rivals: {bot2}'s strength falls clearly; {bot3}'s a little.
EV_LUX_B4_OPB_RES_TITLE | 32 | LUX_B4 result popup title, opt_b | The stock desk is yours
EV_LUX_B4_OPB_RES | 280 | LUX_B4 result popup, opt_b; {bot} is bot_2 | You took the stock desk and the schedules came to your hand. Luxury volume rose for the rest of the run, and prices eased a little for a while. {bot}'s Luxury strength falls clearly, and {bot3}'s a little. The desk has a bell that no one rings.
EV_LUX_B4_OPB_STD | 90 | LUX_B4 rival line 1, opt_b | {bot2}, Luxury: strength down clearly.
EV_LUX_B4_OPB_STD2 | 90 | LUX_B4 rival line 2, opt_b | {bot3}, Luxury: strength down a little.

### MIN_A1 (Minerals, chain A, step 1)
EV_MIN_A1_TITLE | 40 | MIN_A1 choice screen title | Cinderrest's cable frays on schedule
EV_MIN_A1_BODY | 280 | MIN_A1 choice screen body (one body) | Shift chief Brakka Dun reports that Cinderrest's lift cable frayed at exactly the length of its warranty, and the lamps drop out on the lower level. {bot1} runs the next shaft, sells cable, and offers to lend crew and rope, for a price. Sell the lower level, or replace the cable.
EV_MIN_A1_OPA_BTN | 28 | MIN_A1 button, opt_a | Sell the lower level
EV_MIN_A1_OPA_EFF | 200 | MIN_A1 effect line, opt_a | Get: {cash_in} credits now. Cost: Minerals volume down a little for a while. Rivals: {bot1}'s Minerals growth falls a little.
EV_MIN_A1_OPA_RES_TITLE | 32 | MIN_A1 result popup title, opt_a | The lower level is sold
EV_MIN_A1_OPA_RES | 280 | MIN_A1 result popup, opt_a; {bot} is bot_1 | A buyer took the lower level and paid on the lift. Your crew works the upper cuts, so Minerals volume dipped for a while. {bot} wanted the level and cut elsewhere, and its Minerals growth falls a little. The lamps below still burn, for no one.
EV_MIN_A1_OPA_STD | 90 | MIN_A1 rival line 1, opt_a | {bot1}, Minerals: growth down a little.
EV_MIN_A1_OPB_BTN | 28 | MIN_A1 button, opt_b | Replace the cable
EV_MIN_A1_OPB_EFF | 200 | MIN_A1 effect line, opt_b | Get: Minerals volume up a little for a while. Cost: {cash_out} credits for the cable. Rivals: {bot1}'s Minerals strength falls a little.
EV_MIN_A1_OPB_RES_TITLE | 32 | MIN_A1 result popup title, opt_b | The cable is replaced
EV_MIN_A1_OPB_RES | 280 | MIN_A1 result popup, opt_b; {bot} is bot_1 | A new cable went down and the lamps held. It cost credits, and the crew cut more for a while, so Minerals volume rises. {bot} had counted on lending you its crew, and its Minerals strength falls a little. Brakka coiled the old cable at the shaft head. It was still warm.
EV_MIN_A1_OPB_STD | 90 | MIN_A1 rival line 1, opt_b | {bot1}, Minerals: strength down a little.

### MIN_A2 (Minerals, chain A, step 2)
EV_MIN_A2_TITLE | 40 | MIN_A2 choice screen title | Greywake's beam is cracked
EV_MIN_A2_BODY_A | 280 | MIN_A2 choice screen body after opt_a of MIN_A1 | You sold the lower level at Cinderrest. Now a roof beam in Greywake's main cut has cracked, and the glass beneath rings in the crew's teeth. {bot3} works the next cut and wants the same beams. Brace the beam, or sell the cut.
EV_MIN_A2_BODY_B | 280 | MIN_A2 choice screen body after opt_b of MIN_A1 | You replaced the cable at Cinderrest. Now a roof beam in Greywake's main cut has cracked, and the glass beneath rings in the crew's teeth. {bot3} works the next cut and wants the same beams. Brace the beam, or sell the cut.
EV_MIN_A2_OPA_BTN | 28 | MIN_A2 button, opt_a | Brace the beam
EV_MIN_A2_OPA_EFF | 200 | MIN_A2 effect line, opt_a | Get: Minerals volume up a little for a while. Cost: {cash_out} credits for the bracing. Rivals: {bot3}'s Minerals growth falls clearly.
EV_MIN_A2_OPA_RES_TITLE | 32 | MIN_A2 result popup title, opt_a | The beam is braced
EV_MIN_A2_OPA_RES | 280 | MIN_A2 result popup, opt_a; {bot} is bot_3 | Braces went in row by row and the cut kept working for your crews. It cost credits, and Minerals volume rose for a while. {bot} had waited for the beams, and its Minerals growth falls clearly. The crack stopped, and the glass went on ringing.
EV_MIN_A2_OPA_STD | 90 | MIN_A2 rival line 1, opt_a | {bot3}, Minerals: growth down clearly.
EV_MIN_A2_OPB_BTN | 28 | MIN_A2 button, opt_b | Sell the cut
EV_MIN_A2_OPB_EFF | 200 | MIN_A2 effect line, opt_b | Get: {cash_in} credits now. Cost: Minerals volume down a little for a few cycles. Rivals: {bot1}'s Minerals strength falls clearly.
EV_MIN_A2_OPB_RES_TITLE | 32 | MIN_A2 result popup title, opt_b | The cut is sold
EV_MIN_A2_OPB_RES | 280 | MIN_A2 result popup, opt_b; {bot} is bot_1 | A buyer took the cut with the crack in it and paid on the day. Your crews moved to other work, so Minerals volume dipped for a few cycles. {bot} had bid on the same cut, and its Minerals strength falls clearly. The buyer looked at the crack. Briefly.
EV_MIN_A2_OPB_STD | 90 | MIN_A2 rival line 1, opt_b | {bot1}, Minerals: strength down clearly.

### MIN_A3 (Minerals, chain A, step 3)
EV_MIN_A3_TITLE | 40 | MIN_A3 choice screen title | A rival hauler sells a route
EV_MIN_A3_BODY_A | 280 | MIN_A3 choice screen body after opt_a of MIN_A2 | The beam at Greywake is braced. A pilot of {bot3}'s fleet, owed wages, offers his chart of a route to an unclaimed ore cluster. {bot1} runs the same lane in force. Buy the chart, or add extra hulls to the lane.
EV_MIN_A3_BODY_B | 280 | MIN_A3 choice screen body after opt_b of MIN_A2 | The cut at Greywake is sold. A pilot of {bot3}'s fleet, owed wages, offers his chart of a route to an unclaimed ore cluster. {bot1} runs the same lane in force. Buy the chart, or add extra hulls to the lane.
EV_MIN_A3_OPA_BTN | 28 | MIN_A3 button, opt_a | Buy the chart
EV_MIN_A3_OPA_EFF | 200 | MIN_A3 effect line, opt_a | Get: one route's trip cost falls a little for a while. Cost: {cash_out} credits for the chart; {bot3} gains a little Minerals strength. Rivals: {bot1}'s Minerals strength falls a little.
EV_MIN_A3_OPA_RES_TITLE | 32 | MIN_A3 result popup title, opt_a | The chart is bought
EV_MIN_A3_OPA_RES | 280 | MIN_A3 result popup, opt_a; {bot} is bot_1 | You bought the chart and ran one route by it. Trip cost fell a little for a while, and the chart cost credits. The pilot sold the same chart to his own fleet, so {bot3} gains a little Minerals strength. {bot} lost its lead on the lane, and its strength falls a little.
EV_MIN_A3_OPA_STD | 90 | MIN_A3 rival line 1, opt_a | {bot1}, Minerals: strength down a little.
EV_MIN_A3_OPA_STD2 | 90 | MIN_A3 rival line 2, opt_a | {bot3}, Minerals: strength up a little.
EV_MIN_A3_OPB_BTN | 28 | MIN_A3 button, opt_b | Add extra hulls
EV_MIN_A3_OPB_EFF | 200 | MIN_A3 effect line, opt_b | Get: Minerals volume up clearly for a while. Cost: {cash_out} credits and Ship upkeep up a little for a while. Rivals: {bot1} {cut} in Minerals.
EV_MIN_A3_OPB_RES_TITLE | 32 | MIN_A3 result popup title, opt_b | Extra hulls on the lane
EV_MIN_A3_OPB_RES | 280 | MIN_A3 result popup, opt_b; {bot} is bot_1 | You sent extra hulls down the lane and the crews cut harder for a while. The hulls cost credits and raise Ship upkeep a little for a while. {bot} was cut back in Minerals, its lane crews pushed to the edge of the chart. The wakes behind your hulls crossed and recrossed.
EV_MIN_A3_OPB_STD | 90 | MIN_A3 rival line 1, opt_b | {bot1}, Minerals: {cut_std}.

### MIN_B1 (Minerals, chain B, step 1)
EV_MIN_B1_TITLE | 40 | MIN_B1 choice screen title | Two claims on one seam
EV_MIN_B1_BODY | 280 | MIN_B1 choice screen body (one body) | Your crew and a crew of {bot1} filed a claim on the same seam in the same hour, and the Bureau stamped both. Arbiter Judi Drell asks for a sale or a survey and says she is the law only until lunch. Sell your claim, or pay for a survey that proves the cut.
EV_MIN_B1_OPA_BTN | 28 | MIN_B1 button, opt_a | Sell your claim
EV_MIN_B1_OPA_EFF | 200 | MIN_B1 effect line, opt_a | Get: {cash_in} credits now. Cost: Minerals volume down a little for a while. Rivals: {bot1}'s Minerals growth falls a little.
EV_MIN_B1_OPA_RES_TITLE | 32 | MIN_B1 result popup title, opt_a | Your claim is sold
EV_MIN_B1_OPA_RES | 280 | MIN_B1 result popup, opt_a; {bot} is bot_1 | The arbiter's buyer took your claim and paid on the spot. Your crews moved to other cuts, so Minerals volume dipped for a while. {bot} kept the seam, and its Minerals growth falls a little as the buyer set terms. The stamp on your copy was still wet.
EV_MIN_B1_OPA_STD | 90 | MIN_B1 rival line 1, opt_a | {bot1}, Minerals: growth down a little.
EV_MIN_B1_OPB_BTN | 28 | MIN_B1 button, opt_b | Pay for a survey
EV_MIN_B1_OPB_EFF | 200 | MIN_B1 effect line, opt_b | Get: {n} units of tech progress at the Smelter. Cost: {cash_out} credits for the survey. Rivals: {bot1}'s Minerals strength falls clearly.
EV_MIN_B1_OPB_RES_TITLE | 32 | MIN_B1 result popup title, opt_b | The survey proves the cut
EV_MIN_B1_OPB_RES | 280 | MIN_B1 result popup, opt_b; {bot} is bot_1 | The survey cut a test core through the seam and your smelter ran it. Tech progress came in, and the survey was paid. {bot}'s claim failed the core, and its Minerals strength falls clearly. The core was warm and had a thread of glass in it.
EV_MIN_B1_OPB_STD | 90 | MIN_B1 rival line 1, opt_b | {bot1}, Minerals: strength down clearly.

### MIN_B2 (Minerals, chain B, step 2)
EV_MIN_B2_TITLE | 40 | MIN_B2 choice screen title | The smelter crew downs tools
EV_MIN_B2_BODY_A | 280 | MIN_B2 choice screen body after opt_a of MIN_B1 | You sold your claim, and now the crew at your smelter, led by Norma Ray, has stopped work and wants new terms. {bot3} has offered the crew a place. Hold the terms and let the furnace cool, or pay for a double shift to keep it lit.
EV_MIN_B2_BODY_B | 280 | MIN_B2 choice screen body after opt_b of MIN_B1 | You paid for the survey, and now the crew at your smelter, led by Norma Ray, has stopped work and wants new terms. {bot3} has offered the crew a place. Hold the terms and let the furnace cool, or pay for a double shift to keep it lit.
EV_MIN_B2_OPA_BTN | 28 | MIN_B2 button, opt_a | Hold the terms
EV_MIN_B2_OPA_EFF | 200 | MIN_B2 effect line, opt_a | Get: Minerals price up a little for a while. Cost: the Smelter stands idle for a few cycles. Rivals: {bot3}'s Minerals growth falls a little.
EV_MIN_B2_OPA_RES_TITLE | 32 | MIN_B2 result popup title, opt_a | The terms hold
EV_MIN_B2_OPA_RES | 280 | MIN_B2 result popup, opt_a; {bot} is bot_3 | You held the terms and the crew left the furnace to cool. Ingots grew scarce, so Minerals prices rose a little for a while, and the Smelter stood idle for a few cycles. {bot} had offered the crew a place, and its Minerals growth falls a little. The slag ticked as it shrank.
EV_MIN_B2_OPA_STD | 90 | MIN_B2 rival line 1, opt_a | {bot3}, Minerals: growth down a little.
EV_MIN_B2_OPB_BTN | 28 | MIN_B2 button, opt_b | Pay a double shift
EV_MIN_B2_OPB_EFF | 200 | MIN_B2 effect line, opt_b | Get: one more batch a cycle at the Smelter for a while. Cost: {cash_out} credits in shift pay. Rivals: {bot1}'s Minerals strength falls a little.
EV_MIN_B2_OPB_RES_TITLE | 32 | MIN_B2 result popup title, opt_b | A double shift runs
EV_MIN_B2_OPB_RES | 280 | MIN_B2 result popup, opt_b; {bot} is bot_1 | You paid for a double shift and the furnace stayed lit. The Smelter makes one more batch a cycle for a while, and the pay cost credits. {bot} counted on a cooled furnace, and its Minerals strength falls a little. The night crew did not look at the day crew.
EV_MIN_B2_OPB_STD | 90 | MIN_B2 rival line 1, opt_b | {bot1}, Minerals: strength down a little.

### MIN_B3 (Minerals, chain B, step 3)
EV_MIN_B3_TITLE | 40 | MIN_B3 choice screen title | A bidder prices your stock
EV_MIN_B3_BODY_A | 280 | MIN_B3 choice screen body after opt_a of MIN_B2 | You held the terms at the smelter. Bidder Gordo Gekk, who says wanting more is only tidiness, offers a price for all your ingot in storage, hauled today. {bot1} is his usual supplier, and {bot3} has asked for the leftovers. Sell the whole stock, or take a standing buyer.
EV_MIN_B3_BODY_B | 280 | MIN_B3 choice screen body after opt_b of MIN_B2 | You paid for a double shift at the smelter. Bidder Gordo Gekk, who says wanting more is only tidiness, offers a price for all your ingot in storage, hauled today. {bot1} is his usual supplier, and {bot3} has asked for the leftovers. Sell the whole stock, or take a standing buyer.
EV_MIN_B3_OPA_BTN | 28 | MIN_B3 button, opt_a | Sell the whole stock
EV_MIN_B3_OPA_EFF | 200 | MIN_B3 effect line, opt_a | Get: {cash_in} credits now. Cost: Minerals volume down clearly for a few cycles. Rivals: {bot1}'s Minerals strength falls sharply; {bot3}'s falls a little.
EV_MIN_B3_OPA_RES_TITLE | 32 | MIN_B3 result popup title, opt_a | The stock is sold
EV_MIN_B3_OPA_RES | 280 | MIN_B3 result popup, opt_a; {bot} is bot_1 | Gekk hauled the whole stock away and paid on the dock. Your storage stood empty, and Minerals volume fell clearly for a few cycles. {bot}'s usual contract went with it, so its Minerals strength falls sharply, and {bot3}'s a little. The racks rang as they emptied.
EV_MIN_B3_OPA_STD | 90 | MIN_B3 rival line 1, opt_a | {bot1}, Minerals: strength down sharply.
EV_MIN_B3_OPA_STD2 | 90 | MIN_B3 rival line 2, opt_a | {bot3}, Minerals: strength down a little.
EV_MIN_B3_OPB_BTN | 28 | MIN_B3 button, opt_b | Take a standing buyer
EV_MIN_B3_OPB_EFF | 200 | MIN_B3 effect line, opt_b | Get: Minerals volume up a little for a while. Cost: {cash_out} credits to the buyer's broker. Rivals: {bot1}'s Minerals strength falls clearly.
EV_MIN_B3_OPB_RES_TITLE | 32 | MIN_B3 result popup title, opt_b | A standing buyer signs
EV_MIN_B3_OPB_RES | 280 | MIN_B3 result popup, opt_b; {bot} is bot_1 | The standing buyer signed and sends a ship each cycle. Minerals volume rose for a while, and the buyer's broker was paid in credits. {bot} lost the buyer's custom, and its Minerals strength falls clearly. The buyer's ship has no name on its hull.
EV_MIN_B3_OPB_STD | 90 | MIN_B3 rival line 1, opt_b | {bot1}, Minerals: strength down clearly.

### MIN_B4 (Minerals, chain B, step 4)
EV_MIN_B4_TITLE | 40 | MIN_B4 choice screen title | A new deposit is in range
EV_MIN_B4_BODY_A | 280 | MIN_B4 choice screen body after opt_a of MIN_B3 | You sold your whole ingot stock. Now a survey lists another deposit within reach of your ships, and {bot1} has already sent a charter crew. File the claim and pay the survey office, or lease the claim to a crew on terms.
EV_MIN_B4_BODY_B | 280 | MIN_B4 choice screen body after opt_b of MIN_B3 | You took a standing buyer. Now a survey lists another deposit within reach of your ships, and {bot1} has already sent a charter crew. File the claim and pay the survey office, or lease the claim to a crew on terms.
EV_MIN_B4_OPA_BTN | 28 | MIN_B4 button, opt_a | File the claim
EV_MIN_B4_OPA_EFF | 200 | MIN_B4 effect line, opt_a | Get: Minerals price up a little for a while. Cost: {cash_out} credits to the survey office for the filing. Rivals: {bot1}'s Minerals strength falls sharply.
EV_MIN_B4_OPA_RES_TITLE | 32 | MIN_B4 result popup title, opt_a | The claim is filed
EV_MIN_B4_OPA_RES | 280 | MIN_B4 result popup, opt_a; {bot} is bot_1 | You filed the claim and the office stamped it. The filing cost credits, and Minerals prices rose a little for a while as your ore came to market. {bot}'s charter crew found your marker at the site, and its Minerals strength falls sharply. The deposit lay under the rock, unmoved.
EV_MIN_B4_OPA_STD | 90 | MIN_B4 rival line 1, opt_a | {bot1}, Minerals: strength down sharply.
EV_MIN_B4_OPB_BTN | 28 | MIN_B4 button, opt_b | Lease the claim
EV_MIN_B4_OPB_EFF | 200 | MIN_B4 effect line, opt_b | Get: {cash_in} credits and Minerals volume up a little for the rest of the run. Cost: Ship upkeep up a little for a while. Rivals: {bot1}'s strength falls clearly; {bot3}'s a little.
EV_MIN_B4_OPB_RES_TITLE | 32 | MIN_B4 result popup title, opt_b | The claim is leased
EV_MIN_B4_OPB_RES | 280 | MIN_B4 result popup, opt_b; {bot} is bot_1 | You leased the claim to a crew and the first payment arrived. Your ships carry its ore, so Minerals volume rose, and Ship upkeep rises a little for a while. {bot}'s Minerals strength falls clearly, and {bot3}'s a little: both lost the lease. It has a clause about weather.
EV_MIN_B4_OPB_STD | 90 | MIN_B4 rival line 1, opt_b | {bot1}, Minerals: strength down clearly.
EV_MIN_B4_OPB_STD2 | 90 | MIN_B4 rival line 2, opt_b | {bot3}, Minerals: strength down a little.

### BIO_A1 (Biotech, chain A, step 1)
EV_BIO_A1_TITLE | 40 | BIO_A1 choice screen title | A canister arrives unlabelled
EV_BIO_A1_BODY | 280 | BIO_A1 choice screen body (one body) | A sealed canister reached your depot on Tillam from no named source. It is cold and damp, and the lid is warm. The label says: keep sealed, do not feed after dark. Director Hesk says the sample is fine. {bot2} asks to buy it unseen. Study it at your lab, or sell it as it came.
EV_BIO_A1_OPA_BTN | 28 | BIO_A1 button, opt_a | Study the sample
EV_BIO_A1_OPA_EFF | 200 | BIO_A1 effect line, opt_a | Get: {n} units of tech progress at the Culture Lab. Cost: {cash_out} credits for the tests. Rivals: {bot2}'s Biotech growth falls a little.
EV_BIO_A1_OPA_RES_TITLE | 32 | BIO_A1 result popup title, opt_a | The sample is studied
EV_BIO_A1_OPA_RES | 280 | BIO_A1 result popup, opt_a; {bot} is bot_2 | The lab worked behind two doors and logged every reading after dark. Tech progress came in, and the tests cost credits. {bot} had asked to buy the sample unseen, and its Biotech growth falls a little. Fitter Imre Fenn checked both doors twice. The vat took on a faint green.
EV_BIO_A1_OPA_STD | 90 | BIO_A1 rival line 1, opt_a | {bot2}, Biotech: growth down a little.
EV_BIO_A1_OPB_BTN | 28 | BIO_A1 button, opt_b | Sell the sample
EV_BIO_A1_OPB_EFF | 200 | BIO_A1 effect line, opt_b | Get: {cash_in} credits now. Cost: Biotech price down a little for a few cycles. Rivals: {bot2}'s Biotech strength falls a little.
EV_BIO_A1_OPB_RES_TITLE | 32 | BIO_A1 result popup title, opt_b | The sample is sold
EV_BIO_A1_OPB_RES | 280 | BIO_A1 result popup, opt_b; {bot} is bot_2 | A broker took the canister the same day and paid cash. Buyers read the odd colour on the lid as a warning, so Biotech prices dip a little for a few cycles. {bot} was passed over, and its Biotech strength falls a little. Fenn asked where it went. The sample is fine, he was told.
EV_BIO_A1_OPB_STD | 90 | BIO_A1 rival line 1, opt_b | {bot2}, Biotech: strength down a little.

### BIO_A2 (Biotech, chain A, step 2)
EV_BIO_A2_TITLE | 40 | BIO_A2 choice screen title | A clinic asks to test a batch
EV_BIO_A2_BODY_A | 280 | BIO_A2 choice screen body after opt_a of BIO_A1 | Your lab studied the sample. Now Doctor Marrow of the clinic ring asks to draw a batch from your stock for testing on her ward, where volunteers are volunteers by rota. {bot2} supplies the other wards, and {bot3} wants the data. Fund the clinic's tests, or run them at your lab.
EV_BIO_A2_BODY_B | 280 | BIO_A2 choice screen body after opt_b of BIO_A1 | You sold the sample. Now Doctor Marrow of the clinic ring asks to draw a batch from your stock for testing on her ward, where volunteers are volunteers by rota. {bot2} supplies the other wards, and {bot3} wants the data. Fund the clinic's tests, or run them at your lab.
EV_BIO_A2_OPA_BTN | 28 | BIO_A2 button, opt_a | Fund the clinic's tests
EV_BIO_A2_OPA_EFF | 200 | BIO_A2 effect line, opt_a | Get: Biotech volume up a little for the rest of the run. Cost: {cash_out} credits toward the tests. Rivals: {bot3}'s Biotech growth falls a little.
EV_BIO_A2_OPA_RES_TITLE | 32 | BIO_A2 result popup title, opt_a | The clinic runs the tests
EV_BIO_A2_OPA_RES | 280 | BIO_A2 result popup, opt_a; {bot} is bot_3 | The clinic ran the tests behind its own doors. Your funding cost credits, and the clinic keeps ordering, so Biotech volume rises for the rest of the run. {bot} wanted the data and got a summary, so its Biotech growth falls a little. The report came in triplicate, every copy damp.
EV_BIO_A2_OPA_STD | 90 | BIO_A2 rival line 1, opt_a | {bot3}, Biotech: growth down a little.
EV_BIO_A2_OPB_BTN | 28 | BIO_A2 button, opt_b | Run the tests at your lab
EV_BIO_A2_OPB_EFF | 200 | BIO_A2 effect line, opt_b | Get: {n} units of tech progress at the Culture Lab. Cost: Biotech volume down a little for a while. Rivals: {bot2} {cut} in Biotech.
EV_BIO_A2_OPB_RES_TITLE | 32 | BIO_A2 result popup title, opt_b | The tests run at your lab
EV_BIO_A2_OPB_RES | 280 | BIO_A2 result popup, opt_b; {bot} is bot_2 | Your lab ran the tests on the held batch, and the vats gave tech progress. The batch left the shelves, so Biotech volume dips for a while. {bot} was cut back in Biotech as the clinic's wards moved to your results. Fenn walked the vat row each shift and wrote nothing down.
EV_BIO_A2_OPB_STD | 90 | BIO_A2 rival line 1, opt_b | {bot2}, Biotech: {cut_std}.

### BIO_A3 (Biotech, chain A, step 3)
EV_BIO_A3_TITLE | 40 | BIO_A3 choice screen title | A seal begins to weep
EV_BIO_A3_BODY_A | 280 | BIO_A3 choice screen body after opt_a of BIO_A2 | The clinic ran your tests. A vat seal at an Ashgate dock lab weeps. Director Hesk says the sample is fine. Fenn says the drop was clear at dawn and green by noon. {bot2} sources strains there, and {bot3} would buy the stock. Pause your lab for a check, or sell the stock.
EV_BIO_A3_BODY_B | 280 | BIO_A3 choice screen body after opt_b of BIO_A2 | Your lab ran the tests. A vat seal at an Ashgate dock lab weeps. Director Hesk says the sample is fine. Fenn says the drop was clear at dawn and green by noon. {bot2} sources strains there, and {bot3} would buy the stock. Pause your lab for a check, or sell the stock.
EV_BIO_A3_OPA_BTN | 28 | BIO_A3 button, opt_a | Pause the lab for a check
EV_BIO_A3_OPA_EFF | 200 | BIO_A3 effect line, opt_a | Get: Biotech price up a little for a while. Cost: the Culture Lab stands idle for a few cycles. Rivals: {bot2}'s Biotech strength falls a little.
EV_BIO_A3_OPA_RES_TITLE | 32 | BIO_A3 result popup title, opt_a | The lab is paused
EV_BIO_A3_OPA_RES | 280 | BIO_A3 result popup, opt_a; {bot} is bot_2 | You paused your lab and had every seal checked. Stock grew scarce, so Biotech prices rise a little for a while, and the lab stands idle for a few cycles. {bot}'s strains came from the weeping vat, and its Biotech strength falls a little. Fenn taped a note to the seal: told you.
EV_BIO_A3_OPA_STD | 90 | BIO_A3 rival line 1, opt_a | {bot2}, Biotech: strength down a little.
EV_BIO_A3_OPB_BTN | 28 | BIO_A3 button, opt_b | Sell the stock in that line
EV_BIO_A3_OPB_EFF | 200 | BIO_A3 effect line, opt_b | Get: {cash_in} credits now. Cost: Biotech volume down a little for a few cycles; {bot3} gains a little Biotech strength. Rivals: {bot2}'s Biotech strength falls clearly.
EV_BIO_A3_OPB_RES_TITLE | 32 | BIO_A3 result popup title, opt_b | The stock is sold
EV_BIO_A3_OPB_RES | 280 | BIO_A3 result popup, opt_b; {bot} is bot_2 | You sold the stock in that line and cash arrived. The shelves stood bare for a few cycles, so Biotech volume dips. {bot3} bought the surplus and gains a little Biotech strength, while {bot}'s strength falls clearly: its supply line came under notice. The vat moved at night.
EV_BIO_A3_OPB_STD | 90 | BIO_A3 rival line 1, opt_b | {bot2}, Biotech: strength down clearly.
EV_BIO_A3_OPB_STD2 | 90 | BIO_A3 rival line 2, opt_b | {bot3}, Biotech: strength up a little.

### BIO_B1 (Biotech, chain B, step 1)
EV_BIO_B1_TITLE | 40 | BIO_B1 choice screen title | A hospital needs a rare strain
EV_BIO_B1_BODY | 280 | BIO_B1 choice screen body (one body) | A hospital ring on Tillam needs a rare strain by cycle's end, and the cold chain is tight: warm crates mean lost cargo. {bot2} holds the stock, and {bot3} offers to carry it. The grower's manager says it is fine. Buy the stock, or culture it at your lab and send extra hulls.
EV_BIO_B1_OPA_BTN | 28 | BIO_B1 button, opt_a | Buy the grower's stock
EV_BIO_B1_OPA_EFF | 200 | BIO_B1 effect line, opt_a | Get: Biotech volume up clearly for a while. Cost: {cash_out} credits for the grower's stock. Rivals: {bot2}'s Biotech strength falls clearly.
EV_BIO_B1_OPA_RES_TITLE | 32 | BIO_B1 result popup title, opt_a | The stock is bought
EV_BIO_B1_OPA_RES | 280 | BIO_B1 result popup, opt_a; {bot} is bot_2 | You bought the grower's stock and shipped it as it was. It cost credits, and the hospital's order keeps your Biotech volume up for a while. {bot} held the only other stock, and its Biotech strength falls clearly. One crate was warm at the dock. The manager said it was fine.
EV_BIO_B1_OPA_STD | 90 | BIO_B1 rival line 1, opt_a | {bot2}, Biotech: strength down clearly.
EV_BIO_B1_OPB_BTN | 28 | BIO_B1 button, opt_b | Culture it at your lab
EV_BIO_B1_OPB_EFF | 200 | BIO_B1 effect line, opt_b | Get: {n} units of tech progress at the Culture Lab. Cost: Ship upkeep rises a little for a while. Rivals: {bot3}'s Biotech strength falls a little.
EV_BIO_B1_OPB_RES_TITLE | 32 | BIO_B1 result popup title, opt_b | The lab cultures the strain
EV_BIO_B1_OPB_RES | 280 | BIO_B1 result popup, opt_b; {bot} is bot_3 | Your lab grew the strain from a culture and the extra hulls carried it. Tech progress came in, and Ship upkeep rises a little for a while. {bot} offered to carry the order and was passed over, so its Biotech strength falls a little. The strain came up a green nobody ordered.
EV_BIO_B1_OPB_STD | 90 | BIO_B1 rival line 1, opt_b | {bot3}, Biotech: strength down a little.

### BIO_B2 (Biotech, chain B, step 2)
EV_BIO_B2_TITLE | 40 | BIO_B2 choice screen title | A strain changes in storage
EV_BIO_B2_BODY_A | 280 | BIO_B2 choice screen body after opt_a of BIO_B1 | You bought the grower's stock. One strain in storage has darkened, grows faster, and answers to the name on its crate. Cold-chain hand Ottoline Ryke says the lid was moved. {bot2} wants a sample, and {bot3} asks what it is worth. Relabel the batch, or sell it as a new line.
EV_BIO_B2_BODY_B | 280 | BIO_B2 choice screen body after opt_b of BIO_B1 | You cultured the strain at your lab. One strain in storage has darkened, grows faster, and answers to the name on its crate. Cold-chain hand Ottoline Ryke says the lid was moved. {bot2} wants a sample, and {bot3} asks what it is worth. Relabel the batch, or sell it as a new line.
EV_BIO_B2_OPA_BTN | 28 | BIO_B2 button, opt_a | Relabel the batch
EV_BIO_B2_OPA_EFF | 200 | BIO_B2 effect line, opt_a | Get: Biotech price up a little for a while. Cost: Biotech volume down a little for a while. Rivals: {bot2}'s Biotech growth falls clearly.
EV_BIO_B2_OPA_RES_TITLE | 32 | BIO_B2 result popup title, opt_a | The batch is relabelled
EV_BIO_B2_OPA_RES | 280 | BIO_B2 result popup, opt_a; {bot} is bot_2 | You relabelled the batch and held it for study. The new line fetches a little more for a while, and your own volume dips a little as stock stays back. {bot}'s sample requests were refused, so its Biotech growth falls clearly. The storage manager moved his desk out of the room.
EV_BIO_B2_OPA_STD | 90 | BIO_B2 rival line 1, opt_a | {bot2}, Biotech: growth down clearly.
EV_BIO_B2_OPB_BTN | 28 | BIO_B2 button, opt_b | Sell it as a new line
EV_BIO_B2_OPB_EFF | 200 | BIO_B2 effect line, opt_b | Get: {cash_in} credits now. Cost: Ship upkeep rises a little for a while; {bot2} gains a little Biotech strength. Rivals: {bot3} {cut} in Biotech.
EV_BIO_B2_OPB_RES_TITLE | 32 | BIO_B2 result popup title, opt_b | Sold as a new line
EV_BIO_B2_OPB_RES | 280 | BIO_B2 result popup, opt_b; {bot} is bot_3 | You sold the batch as a new line, and cash came in. Extra hulls raise Ship upkeep a little for a while. {bot2} bought a sample and gains a little Biotech strength, while {bot} is cut back, its old line undercut. The buyer asked for a second batch. Ryke asked for a lock.
EV_BIO_B2_OPB_STD | 90 | BIO_B2 rival line 1, opt_b | {bot3}, Biotech: {cut_std}.
EV_BIO_B2_OPB_STD2 | 90 | BIO_B2 rival line 2, opt_b | {bot2}, Biotech: strength up a little.

### BIO_B3 (Biotech, chain B, step 3)
EV_BIO_B3_TITLE | 40 | BIO_B3 choice screen title | An exchange offers a slot
EV_BIO_B3_BODY_A | 280 | BIO_B3 choice screen body after opt_a of BIO_B2 | You relabelled the batch. A culture exchange offers you a numbered slot for your output, with a seat at the call each cycle. Lots and porters are numbered alike. {bot2} holds the first slot, and {bot3} the second. List your output now, or buy a slot outright.
EV_BIO_B3_BODY_B | 280 | BIO_B3 choice screen body after opt_b of BIO_B2 | You sold the batch as a new line. A culture exchange offers you a numbered slot for your output, with a seat at the call each cycle. Lots and porters are numbered alike. {bot2} holds the first slot, and {bot3} the second. List your output now, or buy a slot outright.
EV_BIO_B3_OPA_BTN | 28 | BIO_B3 button, opt_a | List your output now
EV_BIO_B3_OPA_EFF | 200 | BIO_B3 effect line, opt_a | Get: {cash_in} credits now. Cost: Biotech volume down a little for a while. Rivals: {bot2}'s Biotech strength falls sharply; {bot3}'s growth falls clearly.
EV_BIO_B3_OPA_RES_TITLE | 32 | BIO_B3 result popup title, opt_a | The output is listed
EV_BIO_B3_OPA_RES | 280 | BIO_B3 result popup, opt_a; {bot} is bot_2 | Your output went on the exchange list and the first payment cleared. Fewer lots stayed for buyers, so volume dips for a while. {bot} lost its first slot's edge, and its Biotech strength falls sharply, while {bot3}'s growth falls clearly. Crates and porters bear slot numbers.
EV_BIO_B3_OPA_STD | 90 | BIO_B3 rival line 1, opt_a | {bot2}, Biotech: strength down sharply.
EV_BIO_B3_OPA_STD2 | 90 | BIO_B3 rival line 2, opt_a | {bot3}, Biotech: growth down clearly.
EV_BIO_B3_OPB_BTN | 28 | BIO_B3 button, opt_b | Buy a slot outright
EV_BIO_B3_OPB_EFF | 200 | BIO_B3 effect line, opt_b | Get: Biotech volume up a little for a while. Cost: {cash_out} credits for the slot. Rivals: {bot2}'s Biotech strength and {bot3}'s Biotech growth fall a little.
EV_BIO_B3_OPB_RES_TITLE | 32 | BIO_B3 result popup title, opt_b | A slot is bought
EV_BIO_B3_OPB_RES | 280 | BIO_B3 result popup, opt_b; {bot} is bot_2 | You bought a slot at the call and paid in credits. Your lots now sell on schedule, so Biotech volume rises for a while. {bot} loses a little Biotech strength and {bot3} a little growth, as the call split their buyers. The bell at the call is struck by hand, by number.
EV_BIO_B3_OPB_STD | 90 | BIO_B3 rival line 1, opt_b | {bot2}, Biotech: strength down a little.
EV_BIO_B3_OPB_STD2 | 90 | BIO_B3 rival line 2, opt_b | {bot3}, Biotech: growth down a little.

### BIO_B4 (Biotech, chain B, step 4)
EV_BIO_B4_TITLE | 40 | BIO_B4 choice screen title | A storage firm offers cold racks
EV_BIO_B4_BODY_A | 280 | BIO_B4 choice screen body after opt_a of BIO_B3 | Your output is listed on the exchange. A storage firm offers cold racks in a derelict hull moored to the dock, resealed and renamed Aisle. {bot2} keeps its stock there, and {bot3} rents beside it. Rent racks by the cycle, or sell the firm your first claim to the aisle.
EV_BIO_B4_BODY_B | 280 | BIO_B4 choice screen body after opt_b of BIO_B3 | You hold a slot at the exchange call. A storage firm offers cold racks in a derelict hull moored to the dock, resealed and renamed Aisle. {bot2} keeps its stock there, and {bot3} rents beside it. Rent racks by the cycle, or sell the firm your first claim to the aisle.
EV_BIO_B4_OPA_BTN | 28 | BIO_B4 button, opt_a | Rent racks by the cycle
EV_BIO_B4_OPA_EFF | 200 | BIO_B4 effect line, opt_a | Get: Biotech price up a little for a while. Cost: Biotech volume down a little for a while. Rivals: {bot2}'s Biotech strength falls sharply.
EV_BIO_B4_OPA_RES_TITLE | 32 | BIO_B4 result popup title, opt_a | The racks are rented
EV_BIO_B4_OPA_RES | 280 | BIO_B4 result popup, opt_a; {bot} is bot_2 | You rented racks by the cycle, and your stock stayed cold in the old hull. Held stock lifts prices a little for a while, and volume dips as it waits. {bot} lost its place at the front, and its Biotech strength falls sharply. The hull ticks as it cools. Ryke counts the doors.
EV_BIO_B4_OPA_STD | 90 | BIO_B4 rival line 1, opt_a | {bot2}, Biotech: strength down sharply.
EV_BIO_B4_OPB_BTN | 28 | BIO_B4 button, opt_b | Sell the first claim
EV_BIO_B4_OPB_EFF | 200 | BIO_B4 effect line, opt_b | Get: {cash_in} credits now. Cost: Ship upkeep rises a little for a while. Rivals: {bot2}'s and {bot3}'s Biotech strength falls clearly.
EV_BIO_B4_OPB_RES_TITLE | 32 | BIO_B4 result popup title, opt_b | The first claim is sold
EV_BIO_B4_OPB_RES | 280 | BIO_B4 result popup, opt_b; {bot} is bot_2 | You sold the firm your first claim to the aisle, and a large payment cleared. Your ships work the new routes, so Ship upkeep rises a little for a while. {bot} and {bot3} both lost the aisle, and each loses Biotech strength clearly. One lamp lights the hull and does not flicker.
EV_BIO_B4_OPB_STD | 90 | BIO_B4 rival line 1, opt_b | {bot2} and {bot3}, Biotech: strength down clearly.

## Chain effect line template and rival log (added 2026-11-03)
CH_EFFECT_LINE | 200 | Effect line template for any option the game builds itself (the id game/chains.gd reads); {get}, {cost} and {rivals} are phrases without a final full stop | Get: {get}. Cost: {cost}. Rivals: {rivals}.
CH_CUT | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | drops a tier
CH_CUT_LOW | 32 | Chain fill-in: used inside event sentences (see game/chains.gd) | loses strength clearly
CH_CUT_STD | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | moved down a tier
CH_CUT_STD_LOW | 32 | Chain fill-in: used inside event sentences (see game/chains.gd) | strength down clearly
CH_SIZE_S | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | a little
CH_SIZE_M | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | clearly
CH_SIZE_L | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | sharply
CH_RIVALS_LABEL | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | Rivals:
CH_FX_REST | 32 | Chain fill-in: used inside event sentences (see game/chains.gd) | for the rest of the run
CH_FX_CYCLES | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | for {n} cycles
CH_FX_CASH_IN | 32 | Chain fill-in: used inside event sentences (see game/chains.gd) | +{cash_in} credits
CH_FX_CASH_OUT | 32 | Chain fill-in: used inside event sentences (see game/chains.gd) | -{cash_out} credits
CH_FX_VOLUME | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | Volume
CH_FX_PRICE | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | Sell prices
CH_FX_UPKEEP | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | Ship upkeep
CH_FX_TRIP | 32 | Chain fill-in: used inside event sentences (see game/chains.gd) | One route's trip cost
CH_FX_BATCHES | 32 | Chain fill-in: used inside event sentences (see game/chains.gd) | +{n} batch per cycle
CH_FX_TECH | 32 | Chain fill-in: used inside event sentences (see game/chains.gd) | +{n} tech progress
CH_FX_IDLE | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | Workshop idle
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

## Route start warning (2026-11-04)
WARN_SHIP_UNAFFORDABLE | 70 | Warning at the cursor while a route is being started and no ship can be bought | Not enough credits for a ship: need {need}, have {have}

## Resource info on right-click (2026-11-04)
LBL_GOOD_MARKET | 30 | Resource info card (right-click a resource), market the good belongs to; {market} is Military, Luxury, Minerals or Biotech | {market} market.
LBL_GOOD_MADE_AT | 40 | Resource info card, workshop that makes this good; {workshop} is the workshop name | Made at: {workshop}.
LBL_GOOD_USED_IN | 90 | Resource info card, goods this one is an ingredient of; {goods} is a comma list of names | Used in: {goods}.
LBL_GOOD_STORED | 60 | Resource info card, shown once Space Storage stock rows are visible | Can be kept in Space Storage and sent on routes.

## Destination hover card (2026-11-04)
HINT_DEST_BUYS | 60 | Card at the cursor while a route waits for a destination, planet that takes the good; {planet}, {good}, {price} in credits | {planet} buys {good} at {price} cr each.
HINT_DEST_NO_BUYER | 60 | Card at the cursor while a route waits for a destination, planet that does not price the good; {planet}, {good} | {planet} does not buy {good}.
HINT_DEST_STATION | 60 | Card at the cursor while a route waits for a destination, Space Storage station that can take the good; {good} | Space Storage keeps {good} for later.
HINT_DEST_SOURCE | 60 | Card at the cursor while a route waits for a destination, the planet the route starts from | The route starts here. Pick another planet.

## Lane net label and no-earn flag (2026-11-04)
LBL_ROUTE_COST | 20 | Lane label on the map when no result can be projected for the lane; {n} is the signed running cost, shown after the ship count | cost {n}
LBL_FC_NO_EARN | 80 | Cash forecast, warning line under Expenses; {route} is "Source > Destination (good)" | {route} earns nothing: it only moves stock to storage.

## Next cycle tooltip, sources and uses (2026-11-04)
TIP_NC_IN | 40 | Storage view, tooltip on the Next cycle line, line listing what arrives; {list} is comma separated entries | In: {list}.
TIP_NC_OUT | 40 | Storage view, tooltip on the Next cycle line, line listing what leaves; {list} is comma separated entries | Out: {list}.
TIP_NC_BUY | 46 | Next cycle tooltip, entry, a Buy order fills this stock; {planet}, {n} | Buy order at {planet} +{n}
TIP_NC_ROUTE_IN | 40 | Next cycle tooltip, entry, a route delivers; {route} is Source > Destination; {n} | {route} +{n}
TIP_NC_ROUTE_OUT | 40 | Next cycle tooltip, entry, a route takes from this stock; {route}, {n} | {route} -{n}
TIP_NC_ROUTE_BACKUP | 83 | Next cycle tooltip, entry, a route takes from Space Storage because its source planet is short; {route}, {planet}, {n} | {route} (draws Space Storage when {planet} has too little) -{n}
TIP_NC_SELL | 47 | Next cycle tooltip, entry, a Sell order takes from this stock; {planet}, {n} | Sell order at {planet} -{n}
TIP_NC_SELL_BACKUP | 98 | Next cycle tooltip, entry, a Sell order takes from Space Storage because the planet is short; {planet}, {n} | Sell order at {planet} (draws Space Storage when {planet} has too little) -{n}

## Ship screen and CEO (2026-11-05, proposal ship-select-ceo; no goods named; ids per CEO use the portrait id without the ceo_ prefix)
LBL_SHIP_SCREEN_TITLE | 32 | Ship screen, title | Choose your ship
LBL_SHIP_PICK_HINT | 60 | Ship screen, hint while no ship is picked | Pick a ship. Every ship you buy later is the same type.
LBL_SHIP_START | 24 | Ship screen, start button | Start
LBL_STAT_CARGO | 16 | Ship stat label, hold size | Cargo
LBL_STAT_UPKEEP | 16 | Ship stat label, ship upkeep modifier | Upkeep
LBL_STAT_TRIP | 16 | Ship stat label, trip cost modifier | Trip cost
LBL_STAT_PRICE | 16 | Ship stat label, price to buy another ship | Ship price
LBL_STAT_SPEED | 16 | Ship stat label, speed (display only) | Speed
LBL_STAT_CAP | 16 | Ship stat label, extra ships allowed | Ship limit
LBL_SHIP_BULK | 24 | Ship type name, large hold | Bulkhead
LBL_SHIP_DART | 24 | Ship type name, cheap short hops | Dart
LBL_SHIP_FLEET | 24 | Ship type name, many hulls | Tramp
TXT_SHIP_SMALL_ROLE | 40 | Ship screen, role line, Skerrit | All-rounder
TXT_SHIP_BULK_ROLE | 40 | Ship screen, role line, Bulkhead | Big hold, costly to run
TXT_SHIP_DART_ROLE | 40 | Ship screen, role line, Dart | Cheap short hops, small hold
TXT_SHIP_FLEET_ROLE | 40 | Ship screen, role line, Tramp | Many hulls, each one weak
TXT_SHIP_SMALL_DESC | 120 | Ship screen, description, Skerrit | The plain choice. Nothing special, nothing to regret. No bonus, no penalty.
TXT_SHIP_BULK_DESC | 120 | Ship screen, description, Bulkhead | Carries more per trip and costs more to run. Pays off on full lanes, hurts when cash is tight.
TXT_SHIP_DART_DESC | 120 | Ship screen, description, Dart | Cheap to run, quick, but the hold is small. A safe start that falls behind later.
TXT_SHIP_FLEET_DESC | 120 | Ship screen, description, Tramp | One more ship allowed, so one more route. Each ship holds less and costs more to buy.
LBL_CEO_STAT_HAGGLING | 16 | CEO stat label, better sell prices | Haggling
LBL_CEO_STAT_THRIFT | 16 | CEO stat label, lower ship upkeep | Thrift
LBL_CEO_STAT_NERVE | 16 | CEO stat label, smaller hit from bad events | Nerve
LBL_CEO_PERK | 16 | CEO panel, perk heading | Perk
LBL_CEO_MAN_01_NAME | 24 | CEO name, portrait ceo_man_01 | Marek Voss
LBL_CEO_MAN_02_NAME | 24 | CEO name, portrait ceo_man_02 | Idris Kane
LBL_CEO_WOMAN_01_NAME | 24 | CEO name, portrait ceo_woman_01 | Sela Oru
LBL_CEO_WOMAN_02_NAME | 24 | CEO name, portrait ceo_woman_02 | Tamsin Hale
TXT_CEO_MAN_01_BIO | 260 | CEO bio, Marek Voss | Marek kept ten ships flying on a shoestring and counts every bolt. He distrusts luck. He started his own company because nobody would let him order spare parts in bulk.
TXT_CEO_MAN_02_BIO | 260 | CEO bio, Idris Kane | Idris was a broker with a famous smile and a habit of buying lunch for rivals. He reads a price board the way others read faces. He spends freely and sells hard.
TXT_CEO_WOMAN_01_BIO | 260 | CEO bio, Sela Oru | Sela flew supply runs through the worst lanes of the rim and still came home. Bad news does not scare her, only an idle ship does. Her plans have a backup, and a backup for the backup.
TXT_CEO_WOMAN_02_BIO | 260 | CEO bio, Tamsin Hale | Tamsin grew up in the docking rings of the Bazaar and knows every clerk by name. Her contracts arrive with friendly paperwork and larger quantities. She is calm, and a little proud of the old place.
LBL_CEO_MAN_01_PERK | 24 | CEO perk name, Marek Voss | Old Contacts
LBL_CEO_MAN_02_PERK | 24 | CEO perk name, Idris Kane | Quick Read
LBL_CEO_WOMAN_01_PERK | 24 | CEO perk name, Sela Oru | Hard Lanes
LBL_CEO_WOMAN_02_PERK | 24 | CEO perk name, Tamsin Hale | Station Born
TXT_CEO_MAN_01_PERK_DESC | 90 | CEO perk line, Marek Voss | Bad events are announced one cycle early.
TXT_CEO_MAN_02_PERK_DESC | 90 | CEO perk line, Idris Kane | In the first cycle you see price tips on your home market.
TXT_CEO_WOMAN_01_PERK_DESC | 90 | CEO perk line, Sela Oru | Your first lane carries one step more cargo.
TXT_CEO_WOMAN_02_PERK_DESC | 90 | CEO perk line, Tamsin Hale | Contract orders ask for more units, so a filled order pays more.

## Company screen (2026-11-05)
SETUP_NEXT | 24 | Company screen, button that moves on to the ship screen | Next

## Pathfinder, trading posts and mining platforms (T181, 2026-11-05; PENDING until T179 is built)
Design: design/proposals/2026-11-05-ship-flight-discovery.md, recommended defaults (owner questions open): Pathfinder is separate from the fleet, only Voltara is known at the start, the first post is free, leaving a build cancels it. Interface texts stay English (ru/GLOSSARY.md); only the tutorial lines have a Russian version (story/ru/discovery.json). No text here names a planet or a good: closed worlds stay unnamed until the Pathfinder arrives.

LBL_UNKNOWN_WORLD | 24 | Map and planet panel, name of a closed living world | Unknown world
LBL_UNKNOWN_DARK_WORLD | 24 | Map and planet panel, name of a closed dead world | Unknown dark world
LBL_UNKNOWN_WORLD_LINE | 110 | Planet panel of a closed living world, one flavour line, no goods list | Something lives here. Fly closer to learn what it trades.
LBL_UNKNOWN_DARK_LINE | 110 | Planet panel of a closed dead world, one flavour line, no goods list | A dark world. Fly closer to see what is left.
BTN_FLY_HERE | 24 | Planet panel, button that sends the Pathfinder to this world | Fly here
LBL_FLIGHT_TIME | 60 | Planet panel of a closed world, flight time from the Pathfinder; {cycles} is a number | Flight time: {cycles} cycles
LBL_PATHFINDER_NAME | 24 | Ship panel and map tooltip, name of the scout | Pathfinder
LBL_PATHFINDER_DESC | 110 | Ship panel, scout line | A scout. It carries no cargo and costs no upkeep. It flies to new worlds and builds posts.
LBL_PATHFINDER_FLYING | 60 | Top bar or ship panel, while flying to a known planet; {planet} is a name | Pathfinder flying to {planet}
LBL_PATHFINDER_FLYING_UNKNOWN | 60 | Same, while flying to a closed world | Pathfinder flying to an unknown world
LBL_PATHFINDER_IDLE | 60 | Ship panel, not flying and not building | Pathfinder waiting
BTN_ESTABLISH_POST | 24 | Planet panel of a living world the Pathfinder has reached | Establish trading post
BTN_ESTABLISH_PLATFORM | 28 | Planet panel of a dead world the Pathfinder has reached, only after Prospecting-level mining is learned (long button: exception to the 24 limit) | Establish mining platform
LBL_POST_COST | 60 | Under the establish button, a post that costs credits; {cash} and {cycles} are numbers | Cost: {cash} cr. Build time: {cycles} cycles.
LBL_POST_COST_FREE | 60 | Under the establish button, the first post | First post is free. Build time: {cycles} cycles.
LBL_POST_UNLOCKS | 110 | Under the cost line, living world | A post lets you buy, sell, route and store here.
LBL_PLATFORM_UNLOCKS | 110 | Under the cost line, dead world | A platform lets you mine here and send what you mine on routes.
LBL_POST_PROGRESS | 60 | Planet panel and top bar while the post is being built; {cycles} is a number | Building trading post: {cycles} cycles left
LBL_PLATFORM_PROGRESS | 60 | Planet panel and top bar while the platform is being built | Building mining platform: {cycles} cycles left
LBL_POST_BUILT | 24 | Planet panel, replaces the establish button once done | Trading post
LBL_PLATFORM_BUILT | 24 | Planet panel, replaces the establish button once done | Mining platform
NOT_FLY_FIRST | 110 | Notice, player presses establish while the Pathfinder is elsewhere | Fly the Pathfinder here first.
NOT_POST_NO_CASH | 110 | Notice, not enough credits to establish a post | Not enough credits to establish a trading post here.
NOT_PLATFORM_NO_CASH | 110 | Notice, not enough credits to establish a platform | Not enough credits to establish a mining platform here.
NOT_POST_BUSY | 110 | Notice, the Pathfinder is already building | The Pathfinder is already building. One build at a time.
NOT_POST_LEAVE | 110 | Notice, player orders the Pathfinder away during a build | Leaving cancels the build.
NOT_PATHFINDER_ARRIVED | 110 | Notice, arrival at a world; {planet} is the now-known name | The Pathfinder arrived at {planet}.
NOT_POST_DONE | 110 | Notice, post finished; {planet} is a name | Trading post established at {planet}. You can now buy, sell, route and store there.
NOT_PLATFORM_DONE | 110 | Notice, platform finished | Mining platform established at {planet}. You can now mine there and route what you mine.
BTN_EXPLORE_ON | 28 | Ship panel, button that starts exploration mode (the Pathfinder scouts and establishes this system by itself) | Explore this system
BTN_EXPLORE_OFF | 28 | Ship panel, same button while the mode runs; pressing it stops the mode | Stop exploring
NOT_EXPLORE_DONE | 110 | Notice, exploration mode finished: every world of the system is surveyed and established | Exploration complete. Every world in this system is surveyed and established.
NOT_FIELD_SURVEYED | 110 | Notice, the Pathfinder reached an asteroid field | Asteroid field surveyed.
NOT_FLIGHT_EVENT | 110 | Notice before a flight event, optional | The Pathfinder reports something on the lane.

## Tutorial: first flight (T181; replaces the old guided step 1 when discovery is on; Russian in story/ru/discovery.json)
TUT_G0_FLY | 60 | Guided step 0, until the Pathfinder has reached the nearby world | Click your ship, then right-click the dim world.
TUT_G0_FLY_WHY | 110 | Guided step, why it matters (second line of the card) | Only your home world is known. Other worlds open when you fly there and build a post.
TUT_G0_BUILD | 60 | Guided step 0, after arrival, until the post is built | Right-click the world, choose Establish trading post.
TUT_G0_BUILD_WHY | 110 | Guided step, why it matters (second line of the card) | A post lets you buy, sell and route there. Your first one is free.
TUT_G0_WAIT | 60 | Guided step 0, while the post is building | Press the lit time button, top right, to build.
TUT_G0_WAIT_WHY | 110 | Guided step, why it matters (second line of the card) | Flights and builds run on cycles. Time stands still while the game is paused.

## STORAGE LINK (T171, 2026-11-05; from design/proposals/2026-11-05-storage-link.md)
Unlocks with the storage_link feature (Space Storage learned, system 2 open, rivets visible). No text names a good literally except energy (visible from the start); cost goods come through {goods}, a list of visible goods only. Interface texts stay English (ru/GLOSSARY.md); story/ru/storage_link.json is empty on purpose. States: Active, Dormant, Collapsed. Placeholders: {a} and {b} system names, {good} one good name, {goods} list of goods, {n} {m} numbers, {cycles} number of cycles.

SS_LINK_TITLE | 24 | Space Storage view, heading of the link block | Storage Link
SS_LINK_BTN_BUILD | 24 | Space Storage view, opens the build dialog | Build link...
SS_LINK_BTN_ADD_ORDER | 24 | Link block, adds a standing order | Add order
SS_LINK_BTN_REMOVE_ORDER | 24 | Link block, [x] on an order row (tooltip) | Remove order
SS_LINK_BTN_CONFIRM | 24 | Build dialog, confirm | Build link
SS_LINK_BTN_CANCEL | 24 | Build dialog and order dialog, cancel | Cancel
SS_LINK_BTN_SAVE_ORDER | 24 | Order dialog, confirm | Save order
SS_LINK_DLG_TITLE | 40 | Build dialog, title | Build a Storage Link
SS_LINK_DLG_PARTNER | 48 | Build dialog, partner line; {a} and {b} are the two systems | Join {a} to {b}
SS_LINK_DLG_HINT | 110 | Build dialog, under the title | The link is paid in goods from both storages, in any mix you pick. No credits are charged.
SS_LINK_DLG_COST | 60 | Build dialog, one cost line; {goods} is one good, {n} needed, {m} held by both storages | {goods}: need {n}, have {m}
SS_LINK_DLG_FROM | 40 | Build dialog, amount taken from one storage; {a} is the system | Take from {a}
SS_LINK_DLG_SHORT | 110 | Build dialog, shown when the stock is too small; {goods} lists what is missing | The two storages together lack {goods}.
SS_LINK_LBL_LINE | 60 | Link block, one link; {a} and {b} are the systems | {a} <-> {b}
SS_LINK_STATE_ACTIVE | 24 | Link block, state | Active
SS_LINK_STATE_DORMANT | 24 | Link block, state | Dormant
SS_LINK_STATE_COLLAPSED | 24 | Link block, state | Collapsed
SS_LINK_LBL_UPKEEP | 60 | Link block, upkeep; {n} is energy per cycle | Upkeep {n} energy per cycle
SS_LINK_LBL_RATE | 48 | Link block, transfer rate; {n} used, {m} the limit | Rate used {n} / {m}
SS_LINK_LBL_ORDERS | 48 | Link block, order count; {n} used, {m} the limit | Orders {n} / {m}
SS_LINK_LBL_ORDER_ROW | 80 | Link block, one standing order; {good}, {a} source, {b} target, {n} per cycle | {good}  {a} -> {b}  {n} per cycle
SS_LINK_LBL_DORMANT_NEEDS | 60 | Link block, red line on a dormant link; {n} is energy | Dormant: needs {n} energy
SS_LINK_LBL_COLLAPSE_IN | 60 | Link block, under the dormant line; {cycles} is a number | Collapses in {cycles} cycles
SS_LINK_LBL_COLLAPSED | 110 | Link block, a collapsed link | Collapsed. Orders are lost. Build the link again to use it.
SS_LINK_LBL_NO_LINK | 110 | Link block, when no link exists yet | No link yet. A link moves goods between two Space Storages without a ship.
SS_LINK_LBL_GOOD | 24 | Order dialog, label | Good
SS_LINK_LBL_FROM | 24 | Order dialog, label of the source | From
SS_LINK_LBL_AMOUNT | 24 | Order dialog, label of the amount per cycle | Per cycle
SS_LINK_LBL_ORDER_NOTE | 110 | Order dialog, one line | Orders run in the order listed. Each cycle moves what the rate, the stock and the free room allow.
SS_LINK_NOT_BUILT | 110 | Notice, link built; {a} and {b} are the systems | Storage Link built between {a} and {b}.
SS_LINK_NOT_MOVED | 110 | Notice, one cycle of transfers; {n} is units, {a} source, {b} target | Storage Link moved {n} units from {a} to {b}.
SS_LINK_NOT_DORMANT | 110 | Notice, first dormant cycle; {a} {b} systems, {n} energy needed, {cycles} cycles to collapse | Link {a} <-> {b} is dormant. It needs {n} energy. It collapses in {cycles} cycles.
SS_LINK_NOT_COLLAPSE_WARN | 110 | Notice, one cycle before collapse | Link {a} <-> {b} collapses next cycle unless the storages hold {n} energy.
SS_LINK_NOT_WOKE | 110 | Notice, a dormant link wakes | Link {a} <-> {b} is active again.
SS_LINK_NOT_COLLAPSED | 110 | Notice, the link collapsed | Link {a} <-> {b} collapsed. Its orders are lost. Build it again to restore it.
SS_LINK_NOT_NO_GOODS | 110 | Notice, cannot afford to build; {goods} lists what is missing | Cannot build the link. The storages lack {goods}.
SS_LINK_NOT_REFUSED_PAIR | 110 | Notice, refused, a link already joins these two | These two systems already have a link.
SS_LINK_NOT_REFUSED_MAX | 110 | Notice, refused, a storage holds the most links it can | This Space Storage has as many links as it can hold.
SS_LINK_NOT_REFUSED_ORDERS | 110 | Notice, refused, the order list is full | This link has all the orders it can hold. Remove one first.
SS_LINK_NOT_REFUSED_NO_STORAGE | 110 | Notice, refused, one end has no Space Storage yet | Both systems need a Space Storage with goods in it before they can be linked.
SS_LINK_TIP_MAP | 110 | Map tooltip on the link line; {a} and {b} are the systems | Storage Link: {a} and {b}. It moves goods between the two Space Storages each cycle.
SS_LINK_TIP_MAP_DORMANT | 110 | Map tooltip on a dim link line; {a} {b} systems, {n} energy | Dormant link: {a} and {b}. No goods move until the storages hold {n} energy.
SS_LINK_TIP_UPKEEP | 110 | Tooltip on the upkeep line | Taken each cycle from the storage with more energy. Without it the link goes dormant.
SS_LINK_FLAVOUR_BUILD | 110 | Build dialog footer, one flavour line | The Bureau files it as a shared corridor. The goods go in at one door and wait at the other.
SS_LINK_FLAVOUR_EMPTY | 110 | Link block, under the no-link line, flavour | Between the systems the dark is long. The Plan has found a way to cross it without anyone going.

## STORAGE LINK (CODE IDS) (T171; only the ids the code needs, shown only once the storage_link rule is true; English only; story-designer owns the final texts)
LNK_NEED_STORAGE | 80 | Build refusal reason, a storage end is missing or not reachable | Both systems need a Space Storage.
LNK_ALREADY | 80 | Build refusal reason, the pair is already linked | These two storages are already linked.
LNK_MAX_AT_STORAGE | 80 | Build refusal reason, a storage has its maximum of links | A storage can hold only so many links.
LNK_NEED_GOODS | 80 | Build refusal reason, the two storages together lack rivets or energy | Not enough rivets or energy in the two storages.
LNK_NOT_DORMANT | 110 | Notice, first cycle a link lacks its upkeep; {n} energy needed, {cycles} cycles left | The storage link is dormant: it needs {n} energy. It collapses in {cycles} cycles.
LNK_NOT_LAST | 110 | Notice, one cycle before collapse; {n} energy needed | The storage link collapses next cycle unless it gets {n} energy.
LNK_NOT_COLLAPSED | 110 | Notice, the link collapsed | The storage link collapsed. Build it again to restore it.

## STORAGE LINK UI (T171, ui-programmer; interface labels only, English only; shown only once the storage_link rule is true)
SS_LINK_UI_BTN_REMOVE_LINK | 24 | Link block, scraps the link | Remove link
SS_LINK_UI_BTN_EDIT_ORDER | 60 | Link block, tooltip on an order row; click edits it | Click to change the amount
SS_LINK_UI_LBL_PARTNER | 24 | Build dialog, label of the partner picker | Partner storage
SS_LINK_UI_LBL_NO_PARTNER | 110 | Build dialog, no other Space Storage can be picked yet | No other Space Storage to link to yet.
SS_LINK_UI_LBL_TAKEN | 60 | Build dialog, under the cost lines; {n} {goods} what each storage gives | {goods}: {n}

## Placeholder systems 3 to 10 (T176, T210; temporary names and texts, story-designer replaces them; the systems are off, see data/systems_placeholder.json)
WORLD_SYS3_NAME | 24 | System 3 name (placeholder, off) | Placeholder A
WORLD_SYS3_DESC | 110 | System 3 description (placeholder, off) | Temporary text for a far system. It is not open yet.
PERMIT_S3_NAME | 24 | Permit list, system 3 entry (placeholder) | Permit: Placeholder A
PERMIT_S3_DESC | 110 | Permit list, system 3 description (placeholder) | Temporary text. Opens Placeholder A for routes.
PERMIT_S3_BTN | 24 | Permit list, buy button, system 3 (placeholder) | Buy permit
NOT_PERMIT_S3 | 110 | Notice, permit for system 3 bought (placeholder) | Permit bought. Placeholder A is open: three new planets.
WORLD_S3P1_NAME | 24 | System 3 planet 1 (placeholder) | Temp A1
WORLD_S3P1_DESC | 110 | Planet 1 of system 3, tooltip (placeholder) | Temporary planet text.
WORLD_S3P2_NAME | 24 | System 3 planet 2 (placeholder) | Temp A2
WORLD_S3P2_DESC | 110 | Planet 2 of system 3, tooltip (placeholder) | Temporary planet text.
WORLD_S3P3_NAME | 24 | System 3 planet 3 (placeholder) | Temp A3
WORLD_S3P3_DESC | 110 | Planet 3 of system 3, tooltip (placeholder) | Temporary planet text.
WORLD_SYS4_NAME | 24 | System 4 name (placeholder, off) | Placeholder B
WORLD_SYS4_DESC | 110 | System 4 description (placeholder, off) | Temporary text for a far system. It is not open yet.
PERMIT_S4_NAME | 24 | Permit list, system 4 entry (placeholder) | Permit: Placeholder B
PERMIT_S4_DESC | 110 | Permit list, system 4 description (placeholder) | Temporary text. Opens Placeholder B for routes.
PERMIT_S4_BTN | 24 | Permit list, buy button, system 4 (placeholder) | Buy permit
NOT_PERMIT_S4 | 110 | Notice, permit for system 4 bought (placeholder) | Permit bought. Placeholder B is open: three new planets.
WORLD_S4P1_NAME | 24 | System 4 planet 1 (placeholder) | Temp B1
WORLD_S4P1_DESC | 110 | Planet 1 of system 4, tooltip (placeholder) | Temporary planet text.
WORLD_S4P2_NAME | 24 | System 4 planet 2 (placeholder) | Temp B2
WORLD_S4P2_DESC | 110 | Planet 2 of system 4, tooltip (placeholder) | Temporary planet text.
WORLD_S4P3_NAME | 24 | System 4 planet 3 (placeholder) | Temp B3
WORLD_S4P3_DESC | 110 | Planet 3 of system 4, tooltip (placeholder) | Temporary planet text.
WORLD_SYS5_NAME | 24 | System 5 name (placeholder, off) | Placeholder C
WORLD_SYS5_DESC | 110 | System 5 description (placeholder, off) | Temporary text for a far system. It is not open yet.
PERMIT_S5_NAME | 24 | Permit list, system 5 entry (placeholder) | Permit: Placeholder C
PERMIT_S5_DESC | 110 | Permit list, system 5 description (placeholder) | Temporary text. Opens Placeholder C for routes.
PERMIT_S5_BTN | 24 | Permit list, buy button, system 5 (placeholder) | Buy permit
NOT_PERMIT_S5 | 110 | Notice, permit for system 5 bought (placeholder) | Permit bought. Placeholder C is open: three new planets.
WORLD_S5P1_NAME | 24 | System 5 planet 1 (placeholder) | Temp C1
WORLD_S5P1_DESC | 110 | Planet 1 of system 5, tooltip (placeholder) | Temporary planet text.
WORLD_S5P2_NAME | 24 | System 5 planet 2 (placeholder) | Temp C2
WORLD_S5P2_DESC | 110 | Planet 2 of system 5, tooltip (placeholder) | Temporary planet text.
WORLD_S5P3_NAME | 24 | System 5 planet 3 (placeholder) | Temp C3
WORLD_S5P3_DESC | 110 | Planet 3 of system 5, tooltip (placeholder) | Temporary planet text.
WORLD_SYS6_NAME | 24 | System 6 name (placeholder, off) | Placeholder D
WORLD_SYS6_DESC | 110 | System 6 description (placeholder, off) | Temporary text for a far system. It is not open yet.
PERMIT_S6_NAME | 24 | Permit list, system 6 entry (placeholder) | Permit: Placeholder D
PERMIT_S6_DESC | 110 | Permit list, system 6 description (placeholder) | Temporary text. Opens Placeholder D for routes.
PERMIT_S6_BTN | 24 | Permit list, buy button, system 6 (placeholder) | Buy permit
NOT_PERMIT_S6 | 110 | Notice, permit for system 6 bought (placeholder) | Permit bought. Placeholder D is open: three new planets.
WORLD_S6P1_NAME | 24 | System 6 planet 1 (placeholder) | Temp D1
WORLD_S6P1_DESC | 110 | Planet 1 of system 6, tooltip (placeholder) | Temporary planet text.
WORLD_S6P2_NAME | 24 | System 6 planet 2 (placeholder) | Temp D2
WORLD_S6P2_DESC | 110 | Planet 2 of system 6, tooltip (placeholder) | Temporary planet text.
WORLD_S6P3_NAME | 24 | System 6 planet 3 (placeholder) | Temp D3
WORLD_S6P3_DESC | 110 | Planet 3 of system 6, tooltip (placeholder) | Temporary planet text.
WORLD_SYS7_NAME | 24 | System 7 name (placeholder, off) | Placeholder E
WORLD_SYS7_DESC | 110 | System 7 description (placeholder, off) | Temporary text for a far system. It is not open yet.
PERMIT_S7_NAME | 24 | Permit list, system 7 entry (placeholder) | Permit: Placeholder E
PERMIT_S7_DESC | 110 | Permit list, system 7 description (placeholder) | Temporary text. Opens Placeholder E for routes.
PERMIT_S7_BTN | 24 | Permit list, buy button, system 7 (placeholder) | Buy permit
NOT_PERMIT_S7 | 110 | Notice, permit for system 7 bought (placeholder) | Permit bought. Placeholder E is open: three new planets.
WORLD_S7P1_NAME | 24 | System 7 planet 1 (placeholder) | Temp E1
WORLD_S7P1_DESC | 110 | Planet 1 of system 7, tooltip (placeholder) | Temporary planet text.
WORLD_S7P2_NAME | 24 | System 7 planet 2 (placeholder) | Temp E2
WORLD_S7P2_DESC | 110 | Planet 2 of system 7, tooltip (placeholder) | Temporary planet text.
WORLD_S7P3_NAME | 24 | System 7 planet 3 (placeholder) | Temp E3
WORLD_S7P3_DESC | 110 | Planet 3 of system 7, tooltip (placeholder) | Temporary planet text.
WORLD_SYS8_NAME | 24 | System 8 name (placeholder, off) | Placeholder F
WORLD_SYS8_DESC | 110 | System 8 description (placeholder, off) | Temporary text for a far system. It is not open yet.
PERMIT_S8_NAME | 24 | Permit list, system 8 entry (placeholder) | Permit: Placeholder F
PERMIT_S8_DESC | 110 | Permit list, system 8 description (placeholder) | Temporary text. Opens Placeholder F for routes.
PERMIT_S8_BTN | 24 | Permit list, buy button, system 8 (placeholder) | Buy permit
NOT_PERMIT_S8 | 110 | Notice, permit for system 8 bought (placeholder) | Permit bought. Placeholder F is open: three new planets.
WORLD_S8P1_NAME | 24 | System 8 planet 1 (placeholder) | Temp F1
WORLD_S8P1_DESC | 110 | Planet 1 of system 8, tooltip (placeholder) | Temporary planet text.
WORLD_S8P2_NAME | 24 | System 8 planet 2 (placeholder) | Temp F2
WORLD_S8P2_DESC | 110 | Planet 2 of system 8, tooltip (placeholder) | Temporary planet text.
WORLD_S8P3_NAME | 24 | System 8 planet 3 (placeholder) | Temp F3
WORLD_S8P3_DESC | 110 | Planet 3 of system 8, tooltip (placeholder) | Temporary planet text.
WORLD_SYS9_NAME | 24 | System 9 name (placeholder, off) | Placeholder G
WORLD_SYS9_DESC | 110 | System 9 description (placeholder, off) | Temporary text for a far system. It is not open yet.
PERMIT_S9_NAME | 24 | Permit list, system 9 entry (placeholder) | Permit: Placeholder G
PERMIT_S9_DESC | 110 | Permit list, system 9 description (placeholder) | Temporary text. Opens Placeholder G for routes.
PERMIT_S9_BTN | 24 | Permit list, buy button, system 9 (placeholder) | Buy permit
NOT_PERMIT_S9 | 110 | Notice, permit for system 9 bought (placeholder) | Permit bought. Placeholder G is open: three new planets.
WORLD_S9P1_NAME | 24 | System 9 planet 1 (placeholder) | Temp G1
WORLD_S9P1_DESC | 110 | Planet 1 of system 9, tooltip (placeholder) | Temporary planet text.
WORLD_S9P2_NAME | 24 | System 9 planet 2 (placeholder) | Temp G2
WORLD_S9P2_DESC | 110 | Planet 2 of system 9, tooltip (placeholder) | Temporary planet text.
WORLD_S9P3_NAME | 24 | System 9 planet 3 (placeholder) | Temp G3
WORLD_S9P3_DESC | 110 | Planet 3 of system 9, tooltip (placeholder) | Temporary planet text.
WORLD_SYS10_NAME | 24 | System 10 name (placeholder, off) | Placeholder H
WORLD_SYS10_DESC | 110 | System 10 description (placeholder, off) | Temporary text for a far system. It is not open yet.
PERMIT_S10_NAME | 24 | Permit list, system 10 entry (placeholder) | Permit: Placeholder H
PERMIT_S10_DESC | 110 | Permit list, system 10 description (placeholder) | Temporary text. Opens Placeholder H for routes.
PERMIT_S10_BTN | 24 | Permit list, buy button, system 10 (placeholder) | Buy permit
NOT_PERMIT_S10 | 110 | Notice, permit for system 10 bought (placeholder) | Permit bought. Placeholder H is open: three new planets.
WORLD_S10P1_NAME | 24 | System 10 planet 1 (placeholder) | Temp H1
WORLD_S10P1_DESC | 110 | Planet 1 of system 10, tooltip (placeholder) | Temporary planet text.
WORLD_S10P2_NAME | 24 | System 10 planet 2 (placeholder) | Temp H2
WORLD_S10P2_DESC | 110 | Planet 2 of system 10, tooltip (placeholder) | Temporary planet text.
WORLD_S10P3_NAME | 24 | System 10 planet 3 (placeholder) | Temp H3
WORLD_S10P3_DESC | 110 | Planet 3 of system 10, tooltip (placeholder) | Temporary planet text.

## Rival ship card (2026-11-06)
HINT_RIVAL_MARKET | 60 | Card on a clicked rival ship, second line, the market where the competitor is strongest; {market} | Strongest in {market}
HINT_RIVAL_NO_MARKET | 60 | Card on a clicked rival ship, second line, when the competitor has no volume yet | No market lead yet
