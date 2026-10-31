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
9. The cash goal: the first time cash meets it at a cycle end, the Release is filed and the game ends.
10. Ending: escaped, or half absorbed, depending on what the company leaned on. Or the Plan closes and the loss ending shows.

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
LBL_GOAL | 110 | Top bar goal line | Goal: {goal} by cycle {cycle}. Now: {cash}.
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
SK_A1_GATE | 110 | Skill screen, detail panel of Space Storage (A1) while locked | Space Storage opens once you have visited every planet in the first system and made a first route.

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

## Choice screen (shown once when the cash goal is met; no close button)
CHOICE_TITLE | 40 | Choice screen heading
The goal is met

CHOICE_TEXT | 280 | Choice screen body
The cash goal is met. The Bureau offers two forms. The Release takes the company off the Common Ledger. Staying keeps the company on it, as a corporation. Choose once. The run ends either way.

CHOICE_RELEASE | 28 | Button
Take the Release

CHOICE_RELEASE_EFFECT | 90 | Line under the button
The run ends here, with a Release ending.

CHOICE_CORP | 28 | Button
Stay as a corporation

CHOICE_CORP_EFFECT | 90 | Line under the button
The run ends here, with a corporate ending.

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
PERMIT_S2_DESC | 110 | Permit list, system 2 description | Opens Dunmere Reach to the company. Needs Permit Charter (C1). Costs credits and skill points.
PERMIT_S2_BTN | 24 | Permit list, buy button | Buy permit
NOT_PERMIT_S2 | 110 | Notice, permit for system 2 bought | Permit bought. Dunmere Reach is open: four new planets.
SS_POST_NAME | 24 | Space Storage post, name | Space Storage
SS_POST_DESC | 110 | Space Storage post, one-line description | A buffer for the whole system. Company storage feeds it slowly. It holds goods and adds no flow.

## Tutorial: galaxy view (T119; shown once, the first time the galaxy view opens after system 2 is open)
TUT_GALAXY_INTRO | 110 | Galaxy view, first open
This is the galaxy view. It shows the systems you have explored and the links between them.
TUT_GALAXY_ICONS | 110 | Galaxy view, after intro
The icons beside each system show the resources found there.
TUT_GALAXY_ROUTES | 110 | Galaxy view, after icons
Your own trade routes are drawn on the map. Click a system to open it.

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
PERMIT_NEEDS_C1 | 110 | Skill screen, permit line when Permit Charter (C1) is missing | Needs Permit Charter (C1).
PERMIT_NO_CREDITS | 110 | Skill screen, permit line when credits are short | Not enough credits.
