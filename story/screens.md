# Screens, menus, notices and tutorial lines (draft 2, tone rework)

Format: ID | max chars | where it appears, then the text. Placeholders are filled by the game.
Flow follows story/game-flow.md: Buy and Sell on a row are standing local orders (on or off); a route is optional, made with "Send to..." on a storage row; the first goal is to read prices and fill Company storage.
Menus, buttons, labels, notices and tutorial lines are plain. Flavour lives in the preface, mission board intro and story screens only.

## STORY ARC (10 lines)
1. Title: a small company in a shared, indifferent sky.
2. Preface: everything is shared and counted. You want a Release: a planet nobody has counted. It costs credits.
3. First cycles: three planets, two goods. Read prices, set standing orders.
4. Early growth: Company storage and the first expansion points. The company looks like a company, which the Commons finds suspicious.
5. First event: the market moves without asking you.
6. Skills: you choose what kind of company you are, Logistics, Research or Expansion.
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
Everything under this sky is shared. The air, the ducts, the hulls that creak like something asleep, and every credit anyone earns, which goes into the Common Ledger and comes back in portions. The Plan is generous. The Plan is also five cycles long, and then another five.

There is one form for leaving: a Release. It takes you off the ledger and sells you a planet nobody has counted. It is sold in credits, to fellow hands who have them.

So you have a small company, one ship's worth of cash, three planets and two goods. Buy where it is cheap. Sell where it is not. Serving the common good is encouraged. Profit, officially, is a typing error.

The sky will not notice either way.
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
BTN_SELL | 24 | Planet panel resource row | Sell
BTN_SEND | 24 | Storage row | Send to...
BTN_LEARN | 24 | Skill screen | Learn
BTN_REMOVE | 24 | Route and storage panels | Remove
LBL_BUY_PRICE | 24 | Planet panel | Buy price
LBL_SELL_PRICE | 24 | Planet panel | Sell price
LBL_COMPANY_STORAGE | 24 | Planet panel | Company storage
LBL_SHIP_UPKEEP | 24 | Top bar and route panel | Ship upkeep
LBL_EXPENSES | 24 | Top bar | Expenses
LBL_SKILL_POINTS | 24 | Top bar, skill screen header | Skill points
LBL_GOAL_MARKETS | 60 | Top bar goal line | Goal: more than {pct}% of one market
LBL_GROSS | 24 | Route panel and statistics, income before costs | Income before costs
LBL_NET | 24 | Route panel and statistics, income after costs | Income after costs
LBL_TRIP_COST | 24 | Route panel, cost of one trip on a route | Trip cost
ST_WAITING_ROOM | 24 | Route panel, status of a route that waits because the destination is full | Waiting for room

## Skill screen extras
SK_POINTS_LEFT | 24 | Skill screen header, label before the number | Skill points left
SK_CONFIRM | 110 | Skill screen, confirm dialog before Learn | Learn {skill}?
SK_BTN_CLOSE | 24 | Skill screen, close button | Close
SK_NONE_SELECTED | 110 | Skill screen, detail panel before a click | Click a skill to see what it does.
SK_BTN_LEARNED | 24 | Learn button, disabled on a learned skill | Learned
SK_BTN_LOCKED | 24 | Learn button, disabled on a locked skill | Locked
SK_LABEL_EFFECT | 24 | Detail panel label above the plain line | What it changes
SK_LABEL_NEEDS_POINTS | 60 | Detail panel, available but too costly | Not enough skill points.
SK_A1_GATE | 110 | Skill screen, detail panel of Space Storage (A1) while locked | Space Storage opens once you have made two routes, on any planets.

## Mission board hints (right side board)
MB_01 | 110 | Mission board, cycle 1
Click a planet to see what it sells and what it lacks.
MB_02 | 110 | Mission board, after the first planet panel is opened
Compare planets. Buy where a good is cheap, sell where it is dear.
MB_03 | 110 | Mission board, route mission
Move stock with a route: press Send to... and click the destination planet.
MB_04 | 110 | Mission board, route done
First route running. A ship carries stock between the two Company storages.
MB_05 | 110 | Mission board, later
Build a second route, or learn a skill. Skills cost skill points.

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
TUT_PERMIT_C1 | 110 | Any cycle after the first, once a skill point is held and Permit Charter (C1) is not learned
Permit Charter (C1) lets you buy permits. A permit opens a new system. It costs credits and skill points.
TUT_C4_FREE | 110 | Cycle 4, end of tutorial
That is all the guidance there is. The Plan has nothing to add.

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
PERMIT_S2_DESC | 110 | Permit list, system 2 description | Opens Dunmere Reach for routes. Needs Permit Charter (C1). Costs credits and skill points.
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
PERMIT_NEEDS_C1 | 110 | Skill screen, permit line when Permit Charter (C1) is missing | Needs Permit Charter (C1) to buy permits.
PERMIT_NO_CREDITS | 110 | Skill screen, permit line when credits are short | Not enough credits.

## Skill effects made real (2026-10-31, Alpha): Long Haul, Event Forecast, Price Whisper, base-game price history
NOT_ROUTE_NEEDS_C3 | 110 | Route between two systems without Long Haul (C3) | Routes between systems need Long Haul (C3).
EVT_NEXT_DUE | 110 | Notice, Event Forecast (B4), posted one cycle before an event | An event is due next cycle.
EVT_NEXT_DUE_PRICE | 110 | Notice, Event Forecast (B4), price event due next cycle; direction is "rise" or "fall" | Next cycle: {commodity} will {direction} at {planet}.
EVT_NEXT_DUE_CLOSED | 110 | Notice, Event Forecast (B4), closure due next cycle | Next cycle: {planet} will close.
LBL_BEST_PARTNER | 110 | Planet panel, Price Whisper (B3), best route partner | Best partner: {planet} ({margin} cr per unit).
NOT_ROUTE_BELOW_UPKEEP | 110 | Notice, base game, new route margin is below its upkeep | This route earns {margin} cr a cycle and costs {cost}. It will run at a loss.
LBL_SURVEY_PRICES | 110 | Skill screen permit info, base prices after a survey; f = food, e = energy, b = buy, s = sell | {planet}: Food {fb}/{fs} cr, Energy {eb}/{es} cr (buy/sell).
BTN_SURVEY | 24 | Skill screen permit info, Survey button (Survey Beacon C2) | Survey (1 point cheaper)
LBL_PRICE_HISTORY | 110 | Planet panel, base game, under the prices; {prices} is a list of sell prices | Recent sell prices: {prices}.
LBL_PRICE_HISTORY_NONE | 110 | Planet panel, base game, before the first cycle closes | Recent sell prices: none yet.
LBL_NEXT_PRICE | 110 | Planet panel, Price Whisper (B3), prices for the next cycle; {buy} and {sell} are credits | Next cycle: {buy} cr to buy, {sell} cr to sell.
LBL_PERMIT_PLANETS | 110 | Skill screen, permit entry, shown once Survey Beacon (C2) is learned and before the permit is bought; {names} is a list of planet names | Planets in this system: {names}.

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
TUT_G3_SEND | 60 | Guided step 3, until a route exists | Press Send to... and pick a planet.
TUT_G3_SEND_WHY | 110 | Guided step, why it matters (second line of the card) | Pick a planet that wants the good. A route carries your goods there by ship.
TUT_G4_ROUTE_PAY | 60 | Guided step 4, until a route has sold goods | Let the route sell at the destination.
TUT_G4_ROUTE_PAY_WHY | 110 | Guided step, why it matters (second line of the card) | The route earns when it sells there. That is where your money comes from.
TUT_G5_UPKEEP | 60 | Guided step 5, after a ship is working | Find Ship upkeep under Expenses.
TUT_G5_UPKEEP_WHY | 110 | Guided step, why it matters (second line of the card) | A ship costs money every cycle, so a route must earn more than it costs.
TUT_G6_SELL | 60 | Guided step 6, until the first Sell order | Press Sell at the destination.
TUT_G6_SELL_WHY | 110 | Guided step, why it matters (second line of the card) | A Sell order turns your stock into credits.
TUT_G7_STORAGE | 60 | Guided step 7, storage | Watch the Company storage bar.
TUT_G7_STORAGE_WHY | 110 | Guided step, why it matters (second line of the card) | Company storage holds your goods on a planet. When it is full, Buy waits.
TUT_G8_SKILLS | 60 | Guided step 8, until a skill is learned | Open Skills and learn one.
TUT_G8_SKILLS_WHY | 110 | Guided step, why it matters (second line of the card) | Spend an expansion point. Skills unlock bigger storage, longer routes and the permit.
TUT_G9_PERMIT | 60 | Guided step 9, permits | Learn Permit Charter (C1).
TUT_G9_PERMIT_WHY | 110 | Guided step, why it matters (second line of the card) | It lets you open a new system, and a new system has more planets to trade with.
TUT_G10_DONE | 60 | Guided step 10, the last | The tutorial is done. The rest is yours.
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
LBL_LOCKED_PERMIT_FIRST | 60 | Skill screen, a skill locked until Permit Charter (C1) is learned | Learn Permit Charter (C1) first.
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
LBL_SKILLS_ROW_FIRST | 48 | Skill screen, caption of the first row | Start here
LBL_SKILLS_ROW_SECOND | 60 | Skill screen, caption of the second row | Opens after Space Storage and Permit Charter
LBL_LOCKED_FIRST_ROW | 60 | Skill screen, reason line on a locked skill | Learn Space Storage (A1) and Permit Charter (C1) first.
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
DEAD_UNLOCK | 110 | Notice, posted when the dead worlds open | Dead worlds are open. Cinderrest needs Cold Survey (M1), Greywake needs Deep Cut (M2).
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
LBL_TRADE_NEEDS_A1 | 60 | Stalled system 2 lane when Space Storage (A1) is not learned | Learn Space Storage (A1) first.
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
