# Screens, menus, notices and tutorial lines (draft 2, tone rework)

Format: ID | max chars | where it appears, then the text. Placeholders are filled by the game.
Flow follows story/game-flow.md: Buy and Sell on a row are standing local orders (on or off); a route is optional, made with "Send to..." on a storage row; the first goal is to read prices and fill Company storage.
Menus, buttons, labels, notices and tutorial lines are plain. Flavour lives in the preface, mission board intro and story screens only.

## STORY ARC (10 lines)
1. Title: a small company in a shared, indifferent sky.
2. Preface: everything is shared and counted. You run a trading company with one home world and a scout, and you aim to build the Star Bazaar on one grown world.
3. First cycles: three planets, two goods. Read prices, set standing orders.
4. Early growth: Company storage and the first expansion points. The company looks like a company, which the Commons finds suspicious.
5. First event: the market moves without asking you.
6. Skills: you choose what kind of company you are: Military, Luxury, Minerals or Biotech.
7. Midgame: debts, upkeep and the question of what is enough.
8. Pressure: events test routes; the rescue notice shows the Bureau will carry you once, politely.
9. The goal: raise the Star Bazaar on one grown world, stage by stage, and open it with a final delivery before the term ends. That ends the run with a market ending.
10. Ending: one of the market endings, or a loss (bankrupt, swept), or the soft ending when the term ends first.

## Title
SCR_TITLE_NAME | 24 | Title screen, big text
Star Bazaar
SCR_TITLE_TAGLINE | 70 | Title screen, under the name
A small company in a shared, indifferent sky.

## Preface (one block, shown before the game starts)
SCR_PREFACE | 1200 | Preface screen, the text when the CEO has none of their own; {company} is the player's company name
Welcome to the control post of the trading station {company}. Money has always been your dream, and nothing will stop you from earning even more of it.

You know how markets work, and now a chance has opened to make your name. You have enough capital to start your own company and grow it into something greater. You can see how to unite the worlds under your strong hand, and how to build structures and political branches so that not one cent slips past your watchful eye. So, show what you can do.

Ahead lie unprincipled trade, sudden market crashes, random events and intrigue. Your final goal is to build your own point of control over the arteries of this system: the Star Bazaar.
SCR_PREFACE_MAN_01 | 1200 | Preface screen, CEO Marek Voss; {company} is the company name
Welcome to the control post of the trading station {company}. Money has always been your dream, and nothing will stop you from earning even more of it.

You know the price of every bolt, and you have never trusted luck. You know how markets work, and now a chance has opened to make your name. You have enough capital to start your own company and grow it into something greater. You can see how to unite the worlds under your strong hand, and how to build structures and political branches so that not one cent slips past your watchful eye. So, show what you can do.

Ahead lie unprincipled trade, sudden market crashes, random events and intrigue. Your final goal is to build your own point of control over the arteries of this system: the Star Bazaar. You will count every bolt of it.
SCR_PREFACE_MAN_02 | 1200 | Preface screen, CEO Idris Kane; {company} is the company name
Welcome to the control post of the trading station {company}. Money has always been your dream, and nothing will stop you from earning even more of it.

You read a price board the way others read faces, and a smile has never cost you a sale. You know how markets work, and now a chance has opened to make your name. You have enough capital to start your own company and grow it into something greater. You can see how to unite the worlds under your strong hand, and how to build structures and political branches so that not one cent slips past your watchful eye. So, show what you can do.

Ahead lie unprincipled trade, sudden market crashes, random events and intrigue. Your final goal is to build your own point of control over the arteries of this system: the Star Bazaar. Keep smiling.
SCR_PREFACE_WOMAN_01 | 1200 | Preface screen, CEO Sela Oru; {company} is the company name
Welcome to the control post of the trading station {company}. Money has always been your dream, and nothing will stop you from earning even more of it.

You have flown the worst lanes of the rim and still come home. You know how markets work, and now a chance has opened to make your name. You have enough capital to start your own company and grow it into something greater. You can see how to unite the worlds under your strong hand, and how to build structures and political branches so that not one cent slips past your watchful eye. So, show what you can do.

Ahead lie unprincipled trade, sudden market crashes, random events and intrigue. Your final goal is to build your own point of control over the arteries of this system: the Star Bazaar. Deliver it on time.
SCR_PREFACE_WOMAN_02 | 1200 | Preface screen, CEO Tamsin Hale; {company} is the company name
Welcome to the control post of the trading station {company}. Money has always been your dream, and nothing will stop you from earning even more of it.

You grew up in the docking rings and know every clerk by name. You know how markets work, and now a chance has opened to make your name. You have enough capital to start your own company and grow it into something greater. You can see how to unite the worlds under your strong hand, and how to build structures and political branches so that not one cent slips past your watchful eye. So, show what you can do.

Ahead lie unprincipled trade, sudden market crashes, random events and intrigue. Your final goal is to build your own point of control over the arteries of this system: the Star Bazaar. Let every dock remember your name.
SCR_PREFACE_BTN | 24 | Preface screen, continue button
Sign here, and here

## Main menu (title screen buttons)
MENU_CONTINUE | 24 | Main menu, loads the saved game | Continue
MENU_NEW_GAME | 24 | Main menu, starts a new run | New game
MENU_CONFIRM_NEW | 110 | Confirmation dialog, new game while a saved game exists | Start a new game?
NOT_NO_SAVE | 110 | Main menu, Continue with no saved game | No saved game yet.
MENU_HINT_CONTINUE_OFF | 110 | Main menu, hint on a disabled Continue | Continue needs a saved game.
MENU_HINT_SKIP_TUTORIAL | 110 | Main menu, hint on the Skip tutorial toggle | New games start with the tutorial already done.

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
Build a second route, or learn a skill. Skills cost skill points. The goal: raise the Star Bazaar.

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
The figure is your Company storage here. The menu has Send to and Sell. When full, Buy waits.
TUT_C3_ONEWAY | 110 | Cycle 3
Routes are one way. To send stock both ways, make a second route back.
TUT_C4_SKILLS | 110 | Cycle 4, if a skill point is held
You have skill points. Open Skills and learn something.
TUT_C4_FREE | 110 | Cycle 4, end of tutorial
That is the basics. The goal is the Star Bazaar. Watch for house convoys.

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
TUT_G1_SELECT | 60 | Guided step 1, until a planet is clicked | Click Voltara, your home world, to start trading.
TUT_G1_SELECT_WHY | 110 | Guided step, why it matters (second line of the card) | Its panel shows what Voltara sells, what it buys and what you can trade there.
TUT_G1B_SHIPS | 60 | Guided step 2 (T319), until the Pathfinder card in the Ships menu is clicked | In the Ships menu, right, click the Pathfinder card.
TUT_G1B_SHIPS_WHY | 110 | Guided step, why it matters (second line of the card) | The card selects your ship. Then click a world on the map to send it there.
TUT_G2_BUY | 60 | Guided step 2, until a Buy order is on for a good | Press the lit Energy button.
TUT_G2_BUY_WHY | 110 | Guided step, why it matters (second line of the card) | This buys Energy: each cycle it fills Company storage here. A standing order; press again to stop.
TUT_G3_SEND | 60 | Guided step 3, until a route exists | Right-click Energy, choose Send to.
TUT_G3_PICK | 60 | Guided step 3, after Send to is chosen, until a destination is clicked | Click a world with a post to send Energy there.
TUT_G3_SEND_WHY | 110 | Guided step, why it matters (second line of the card) | Pick a world that wants the good. A route carries your goods there by ship.
TUT_G4_ROUTE_PAY | 60 | Guided step 4, until a route has sold goods | Press the lit time button, top right, to run the cycle.
TUT_G4_ROUTE_PAY_WHY | 110 | Guided step, why it matters (second line of the card) | The route earns when it sells there. That is where your money comes from.
TUT_G5_UPKEEP | 60 | Guided step 5, after a ship is working | Find Ship upkeep under Expenses.
TUT_G5_UPKEEP_WHY | 110 | Guided step, why it matters (second line of the card) | A ship costs money every cycle, so a route must earn more than it costs.
TUT_G6_SELL | 60 | Guided step 6, until the first Sell order | Open your route's end world. Turn Sell on for Energy.
TUT_G6_SELL_WHY | 110 | Guided step, why it matters (second line of the card) | A Sell order turns stock into credits when the cycle ends. Let one finish.
TUT_G7_STORAGE | 60 | Guided step 7, storage | The lit text shows the stock in Company storage.
TUT_G7_STORAGE_WHY | 110 | Guided step, why it matters (second line of the card) | When it is full, Buy waits. Press Next.
TUT_G7_NEEDS | 60 | Guided step 8 (T315), until a world card with a Needs list has been opened | Open a world and read its Needs.
TUT_G7_NEEDS_WHY | 110 | Guided step, why it matters (second line of the card) | A world grows when your sales meet its needs. Grown worlds pay tax.
TUT_G7_GROW | 60 | Guided step 9 (T315), until the first world reaches tier 1 | Sell a world the goods it needs, until it grows.
TUT_G7_GROW_WHY | 110 | Guided step, why it matters (second line of the card) | Turn Sell on there, or send goods in. Your first tier also earns a skill point.
TUT_G8_SKILLS | 60 | Guided step 10, until a skill is learned | Open Skills and learn a Foundation.
TUT_G8_SKILLS_WHY | 110 | Guided step, why it matters (second line of the card) | Skill points come from firsts, like your first tier. Three Foundations come before any market skill.
TUT_G9_PERMIT | 60 | Guided step 11, permits | Learn Permit Charter.
TUT_G9_PERMIT_WHY | 110 | Guided step, why it matters (second line of the card) | It lets you buy a permit for a new system. A new system has more worlds to grow and trade with.
TUT_G10_DONE | 60 | Guided step 12, the last, until the Star Bazaar panel is opened | The Star Bazaar is one market hall all worlds trade in.
TUT_G10_DONE_WHY | 110 | Guided step, why it matters (second line of the card) | You build it, stage by stage, on one world grown into a capital. Finishing it wins the game.
TUT_HEADER | 24 | Header of the guided tutorial card | Tutorial
TUT_STEP_COUNT | 24 | Tutorial card, step counter; {n} is the step, {total} the number of steps | {n} of {total}

## Contextual tips (T315, 2026-11-07; one-time cards for later mechanics)
Rules for T316 (notes, not blocks): each tip is two ids, TIP_<NAME> (what it is, card line) and TIP_<NAME>_WHY (why it matters and what to do next, second line). Show each tip once per run, the first time its trigger is true, never blocking and never over a guided step card: queue it until the card is gone. If two tips fire at once, show them in the order listed below. No placeholders. No text names a hidden good, a number or a price. The trigger of every tip is also in the place field of its first block.

Trigger table (tip id: trigger in plain words):
- TIP_TIER1: the first world reaches tier 1.
- TIP_TAX: the first cycle in which worlds pay tax.
- TIP_RESTLESS: the first world turns Restless.
- TIP_HUNGRY: the first Hungry chip appears on a need row.
- TIP_UPGRADE: the first time a route card shows the Upgrade route button on a full lane, or an add-ship click is refused because the lane is full (after TIP_HUNGRY).
- TIP_CAPITAL: the first world reaches the capital tier.
- TIP_HUB: the first world can be made a hub (same moment as TIP_CAPITAL today; show TIP_CAPITAL first).
- TIP_FOUNDED: the Bazaar is founded.
- TIP_OPENING: the last Bazaar stage is done and the Opening gig appears.
- TIP_PLATFORM: the Flagship first arrives at a dead world.
- TIP_EXPLORE: the Ships panel is opened for the first time while an unknown world is left in the system.
- TIP_DOCK: the dock sheet opens for the first time.
- TIP_BOOST: the Flagship first flies with energy in its hold.
- TIP_GIG: the first gig appears on the board.
- TIP_WEATHER: the first house convoy appears.
- TIP_WEATHER_KINDS: the first house weather lands on a world.
- TIP_PROSPECT: Prospecting is learned.
- TIP_DEAD: the first dead world is open for mining (its skill is learned and dead worlds have opened).
- TIP_RECLAIM: the first dead world card is opened (show TIP_DEAD first if both are due).
- TIP_RAID: the first raid warning appears.
- TIP_SALVAGE: the first salvage payout.
- TIP_WORKSHOP: the first workshop becomes available to build.
- TIP_FABRIC: the Fabric becomes available to build.
- TIP_NULLCORE: the Fabric is built.
- TIP_SPACE_STORAGE: Space Storage is learned.
- TIP_LINK: the Storage Link becomes available.
- TIP_PERMIT: Permit Charter is learned.
- TIP_NEWSYSTEM: the first new system is opened by a permit.
- TIP_POINTS: the first skill point is earned (skip if the guided step for skills is showing).
- TIP_FOUNDATIONS: the third required Foundation is learned.

### Goal and Bazaar
TIP_CAPITAL | 110 | Tip card line; trigger: the first world reaches the capital tier | A world has reached the capital tier. You can found the Star Bazaar there. It is final.
TIP_CAPITAL_WHY | 110 | Tip card, why line | A run has one capital. Choose with care, then press Found the Bazaar here on the world's panel.
TIP_FOUNDED | 110 | Tip card line; trigger: the Bazaar is founded | The Bazaar is built in stages. Each needs goods in the capital's storage and other worlds at a tier.
TIP_FOUNDED_WHY | 110 | Tip card, why line | Goods are held in the capital's storage. Set Buy there, or send them from a cheaper world.
TIP_BILL | 110 | Tip card line; trigger: the first time a Bazaar bill item is short | A stage needs goods in the capital's own storage. Goods held elsewhere do not count.
TIP_BILL_WHY | 110 | Tip card, why line | Turn Buy on at the capital, or send the goods from a cheaper world. The Bazaar panel shows the steps.
TIP_OPENING | 110 | Tip card line; trigger: the last Bazaar stage is done and the Opening gig appears | The last stage posts the Opening: a gig to fly the charter cargo to the capital.
TIP_OPENING_WHY | 110 | Tip card, why line | Accept it on the gig board (J), then dock at the capital. That opens the Star Bazaar and wins the run.

### Prosperity
TIP_TIER1 | 110 | Tip card line; trigger: the first world reaches tier 1 | Your first world has grown a tier. Worlds grow when your sales meet their needs.
TIP_TIER1_WHY | 110 | Tip card, why line | Each tier opens more and leads to a capital. Open a world card to see what it needs next.
TIP_TAX | 110 | Tip card line; trigger: the first cycle in which worlds pay tax | Grown worlds pay tax at the end of each cycle. The credits are added to your cash.
TIP_TAX_WHY | 110 | Tip card, why line | More tiers mean more tax. Keep worlds supplied so they keep growing.
TIP_RESTLESS | 110 | Tip card line; trigger: the first world turns Restless | A Restless world is losing growth progress because one of its needs is short.
TIP_RESTLESS_WHY | 110 | Tip card, why line | Sell it the short good, or send stock there. Meeting every need stops the loss.
TIP_HUNGRY | 110 | Tip card line; trigger: the first Hungry chip appears on a need row | A world is Hungry: last cycle it did not get enough of a good it needs, so it now pays extra for it.
TIP_HUNGRY_WHY | 110 | Tip card, why line | Find the Hungry tag in a world's Needs list. Deliver that good there first: it pays more and fills the need.
TIP_UPGRADE | 110 | Tip card line; trigger: the first full lane shows the Upgrade route button, or an add-ship click is refused as full | A full lane cannot take another ship. It can be upgraded instead.
TIP_UPGRADE_WHY | 110 | Tip card, why line | Open the world the route starts from and press Upgrade route. One fee, a better margin on every trip.
TIP_HUB | 110 | Tip card line; trigger: the first world can be made a hub (right after TIP_CAPITAL) | A hub keeps the worlds near it fed, using ships from its own pool.
TIP_HUB_WHY | 110 | Tip card, why line | One hub per system. Press Make this a hub, then add ships. Each delivery adds a hub fee.

### Discovery and the Flagship
TIP_PLATFORM | 110 | Tip card line; trigger: the Flagship first arrives at a dead world | A dead world takes a mining platform, not a trading post.
TIP_PLATFORM_WHY | 110 | Tip card, why line | Once it stands you can mine there and route what it gives. Mining needs Prospecting.
TIP_EXPLORE | 110 | Tip card line; trigger: the Ships panel is opened first while an unknown world is left in the system | Exploration mode flies the Flagship to each unknown world here and builds its post.
TIP_EXPLORE_WHY | 110 | Tip card, why line | Each post costs credits, so it waits at a world while cash is short. Press the button again to stop.
TIP_DOCK | 110 | Tip card line; trigger: the dock sheet opens for the first time | Dock lets the Flagship load goods from this world's storage and unload them there. The hold has limited room.
TIP_DOCK_WHY | 110 | Tip card, why line | Unload to storage moves goods into Company storage here. Time is paused while you are docked.
TIP_BOOST | 110 | Tip card line; trigger: the Flagship first flies with energy in its hold | Boost burns energy from the hold for a short burst of speed. Hold B to use it.
TIP_BOOST_WHY | 110 | Tip card, why line | Use it on straight legs to beat a deadline. Turning stays slow, and charges refill slowly.

### Gigs
TIP_GIG | 110 | Tip card line; trigger: the first gig appears on the board | The gig board (J) lists offers for the Flagship. Accept one to get a map marker.
TIP_GIG_WHY | 110 | Tip card, why line | Compare ETA with the deadline before you accept. You can take one gig at a time.

### House weather
TIP_WEATHER | 110 | Tip card line; trigger: the first house convoy appears | A tinted ship is a house convoy. It flies to a world before that house's weather lands.
TIP_WEATHER_WHY | 110 | Tip card, why line | The houses send weather, not rivals. Click a convoy to see what is due and where.
TIP_WEATHER_KINDS | 110 | Tip card line; trigger: the first house weather lands on a world | Flood: a sell price dips. Shortage: a world needs more and pays more. Congestion: trip cost rises.
TIP_WEATHER_KINDS_WHY | 110 | Tip card, why line | Move goods to ride it out, or wait. Forecast skills give more cycles of warning.

### Mining
TIP_PROSPECT | 110 | Tip card line; trigger: Prospecting is learned | Prospecting lets a route start at an asteroid cluster. Clusters move round the sun.
TIP_PROSPECT_WHY | 110 | Tip card, why line | Goods at a cluster are free, you pay only the lane. A cluster runs empty and never refills.
TIP_DEAD | 110 | Tip card line; trigger: the first dead world is open for mining | A dead world has no market. You mine it for goods no living world makes.
TIP_DEAD_WHY | 110 | Tip card, why line | Hard mining gives more and draws more raids. Set Mining intensity on its card.
TIP_RECLAIM | 110 | Tip card line; trigger: the first dead world card is opened | Start reclaiming turns a dead world into a living one. Mining there stops for good.
TIP_RECLAIM_WHY | 110 | Tip card, why line | Meet its needs to fill the bar. Raids from it stop, and it can grow like any world.
TIP_RAID | 110 | Tip card line; trigger: the first raid warning appears | Raiders gather at a dead world you have not reclaimed. They may hit a lane in its system.
TIP_RAID_WHY | 110 | Tip card, why line | A raid costs part of a trip. Cargo pods may drift near: fly the Flagship to pick them up.
TIP_SALVAGE | 110 | Tip card line; trigger: the first salvage payout | Salvage is a one-time payout for goods that could not be kept or sold on your lanes.
TIP_SALVAGE_WHY | 110 | Tip card, why line | It pays less than a Sell order. Add a Sell order, or make room, to keep more.

### Workshops
TIP_WORKSHOP | 110 | Tip card line; trigger: the first workshop becomes available to build | A workshop turns stock in Space Storage into new goods each cycle. Build it once.
TIP_WORKSHOP_WHY | 110 | Tip card, why line | With an input missing it stalls and says what it needs. Send the inputs to Space Storage.
TIP_FABRIC | 110 | Tip card line; trigger: the Fabric becomes available to build | The Fabric turns mined goods into a new good at the trading post.
TIP_FABRIC_WHY | 110 | Tip card, why line | It crafts from stock in Space Storage. Mine what it needs and send it there.
TIP_NULLCORE | 110 | Tip card line; trigger: the Fabric is built | The Fabric can build a Null Core. It is built once and fitted to one ship.
TIP_NULLCORE_WHY | 110 | Tip card, why line | That ship has a lower trip cost and is safe from raids. Fit it to the ship on your busiest lane.

### Storage and systems
TIP_SPACE_STORAGE | 110 | Tip card line; trigger: Space Storage is learned | Space Storage is one big store for each system. Planet storage feeds it slowly.
TIP_SPACE_STORAGE_WHY | 120 | Tip card, why line | Workshops, link upkeep, Storage Links and routes you send from it take stock out. Click its station to see stock.
TIP_LINK | 110 | Tip card line; trigger: the Storage Link becomes available | A Storage Link joins the Space Storages of two systems. It moves goods only, never credits.
TIP_LINK_WHY | 110 | Tip card, why line | It costs goods to build and energy each cycle. With no energy it goes dormant, and may collapse.
TIP_PERMIT | 110 | Tip card line; trigger: Permit Charter is learned | Buy the permit in the galaxy view. Click a closed system to see its price.
TIP_PERMIT_WHY | 110 | Tip card, why line | The window also says why you cannot buy it yet. Then fly the Flagship in to open its worlds.
TIP_NEWSYSTEM | 110 | Tip card line; trigger: the first new system is opened by a permit | A new system starts unknown, like the first. Fly the Flagship in and build posts.
TIP_NEWSYSTEM_WHY | 110 | Tip card, why line | Each system has its own Space Storage. A later Bazaar stage needs a world in another system.

### Skills
TIP_POINTS | 110 | Tip card line; trigger: the first skill point is earned | Skill points come from firsts: a new world, route, system or tier. Spend them in Skills (K).
TIP_POINTS_WHY | 110 | Tip card, why line | Six Foundations come before your market tree. Three of them must be learned first.
TIP_FOUNDATIONS | 110 | Tip card line; trigger: the third required Foundation is learned | The three required Foundations are done. Your market tree is open now.
TIP_FOUNDATIONS_WHY | 110 | Tip card, why line | Points are limited, so choose the skills your lanes use. Learn the ones you will use.

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
SS_LBL_STOCK_RULE | 140 | Space Storage view, under the capacity line: the rule for delivered goods | Goods stay until a recipe, link upkeep, Storage Link or a route you send from here takes them. Planet routes and Sells never draw on it.
SS_TIP_SEND | 90 | Space Storage view, tooltip on Send to... | Send this good from the Space Storage to a planet: click the planet on the map next.
SS_TIP_SEND_NONE | 70 | Space Storage view, tooltip on a disabled Send to... | Nothing to send: none in stock and none on its way.
SS_LBL_ROUTES_OUT | 24 | Space Storage view, title of the list of routes sent out of this storage | Sent out from here
SS_LBL_ROUTE_OUT_LINE | 40 | Space Storage view, one outgoing route; {good}, {planet}, {n} units per cycle | {good} to {planet}, {n} / cycle
SS_BTN_ROUTE_REMOVE | 16 | Space Storage view, button that removes an outgoing route | Remove
RT_ERR_STATION_TO_STATION | 60 | Refusal when a Space Storage route is aimed at a Space Storage | A Space Storage cannot send to a Space Storage.
RT_ERR_STATION_NONE | 80 | Refusal when a Space Storage route is made for a good it does not hold and none is coming | This Space Storage has none of this good and none is on its way.
LBL_CONN_WHY_STATION_NO_STOCK | 110 | Planet card, Connections, muted line under a lane from a Space Storage that has none of the good; {good} | The Space Storage has no {good}. Send some into it, or remove this route.
LBL_CONN_WHY_STATION_SHARED | 110 | Planet card, Connections, muted line under a lane from a Space Storage whose stock other lanes take first; {good} | Other lanes take the Space Storage's {good} first. Send more into it.
TIP_NC_UPKEEP | 40 | Next cycle tooltip, entry, storage link upkeep takes from this stock; {n} | Link upkeep -{n}
LBL_NEXT_CYCLE | 48 | Storage view, projected stock after the next cycle | Next cycle: +{in} -{out} = {after}

## New goods and asteroid clusters (T154, 2026-11-02; names are working names, owner decides)
GOOD_SILK_NAME | 24 | Commodity name, silk | Starsilk
GOOD_SILK_DESC | 110 | Commodity tooltip, silk | Light cloth with a faint glow. A luxury trade good: little to carry, much to admire.
GOOD_SPYWARE_NAME | 24 | Commodity name, spyware | Spy Software
GOOD_SPYWARE_DESC | 110 | Commodity tooltip, spyware | Listening code sold to those who like to know. A trade good.
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
DEAD_UNLOCK | 110 | Notice, posted when the dead worlds open | Dead worlds are open. Prospecting lets you mine them.
PLANET_DEAD_LOCKED | 60 | Planet panel, dead world before it opens; {n} is the cycle | Opens at cycle {n}.
NOT_DEAD_NEEDS_SKILL | 110 | Notice, route from a dead world without its skill; {skill} is the skill name | Mining here needs {skill}.
LBL_MINE_ROW_TIP | 80 | Planet panel, dead world, tooltip of a mined good | Mine here every cycle. Press to stop.
SCR_MINE_HINT | 100 | Planet panel, dead world, muted line under the mined goods | Press the resource to mine it each cycle. Right-click it to send it to another world.
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
GOOD_POWDER_NAME | 24 | Commodity name, powder | Blast Powder
GOOD_POWDER_DESC | 110 | Commodity tooltip, powder | Grey grit in sacks; every fleet starts here. A trade good.
GOOD_BLOOMS_NAME | 24 | Commodity name, blooms | Hothouse Blooms
GOOD_BLOOMS_DESC | 110 | Commodity tooltip, blooms | Petals picked at dawn; scent is the cheapest status. A trade good.
GOOD_ENERGY_NAME | 24 | Commodity name, energy | Energy
GOOD_ENERGY_DESC | 110 | Commodity tooltip, energy | Bulk power for any world with a lamp to light. A raw good that every trade leans on.
GOOD_FOOD_NAME | 24 | Commodity name, food | Food
GOOD_FOOD_DESC | 110 | Commodity tooltip, food | Plain staple rations. A raw good that everyone needs and nobody boasts about.
GOOD_RIVETS_NAME | 24 | Commodity name, rivets | Rivets
GOOD_RIVETS_DESC | 110 | Commodity tooltip, rivets | Metal pins for ships. Bought at Voltara, sold at the system 2 yards. A trade good.
GOOD_ROUNDS_NAME | 24 | Commodity name, rounds | Munitions
GOOD_ROUNDS_DESC | 110 | Commodity tooltip, rounds | Loaded and counted; the Plan wants them. A crafted good.
GOOD_ARMS_NAME | 24 | Commodity name, arms | Weapons
GOOD_ARMS_DESC | 110 | Commodity tooltip, arms | Rail carbines and gun racks in crates. A crafted good.
GOOD_MUSK_NAME | 24 | Commodity name, musk | Musk
GOOD_MUSK_DESC | 110 | Commodity tooltip, musk | A strong scent, sold by the drop. A luxury trade good.
GOOD_ATTAR_NAME | 24 | Commodity name, attar | Attar
GOOD_ATTAR_DESC | 110 | Commodity tooltip, attar | Bottled scent, pressed from blooms. A crafted luxury good.
GOOD_GEMS_NAME | 24 | Commodity name, gems | Cold Gems
GOOD_GEMS_DESC | 110 | Commodity tooltip, gems | Cut stones with a cold inner light. A crafted luxury, valued for being looked at.
GOOD_INGOT_NAME | 24 | Commodity name, ingot | Metal Ingots
GOOD_INGOT_DESC | 110 | Commodity tooltip, ingot | Metal bars, stacked and stamped. A crafted good.
GOOD_ALLOY_NAME | 24 | Commodity name, alloy | Furnace Alloy
GOOD_ALLOY_DESC | 110 | Commodity tooltip, alloy | Hard metal blended to a strict recipe. The finest crafted good of its kind.
GOOD_SPORES_NAME | 24 | Commodity name, spores | Jar Spores
GOOD_SPORES_DESC | 110 | Commodity tooltip, spores | Dry spores in sealed jars, handled with gloves. A trade good.
GOOD_MEDICINE_NAME | 24 | Commodity name, medicine | Medicine
GOOD_MEDICINE_DESC | 110 | Commodity tooltip, medicine | Clinic stock in cold boxes. A crafted good.
GOOD_SEED_NAME | 24 | Commodity name, seed | Seed Stock
GOOD_SEED_DESC | 110 | Commodity tooltip, seed | Seed stock that grows to order. The finest crafted good of its kind.
NULL_CORE_BUILD_TITLE | 32 | Popup title, first Null Core built (one per run) | The core is built
NULL_CORE_BUILD | 280 | Popup text, first Null Core built (one per run) | The Null Core sat in its cradle and gave off no heat at all. Fitted, it makes one hull quiet in a way hulls are not. Nobody can say what it listens to. The Bureau has filed it under spare parts.
NULL_CORE_FIT | 110 | Ships window, label or tooltip of the fitted ship | Null Core fitted. Lower Trip cost, and raiders cannot touch this ship.


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
BTN_TUT_FINISH | 24 | Tutorial card, last card only, replaces Skip tutorial; ends the tutorial, tips go on | Finish
TIP_BOARD_1 | 110 | Tips board, rotates one per cycle | A route should earn more than its ship costs in upkeep. Check Expenses.
TIP_BOARD_2 | 110 | Tips board | Routes are one way. To send stock both ways, make a second route back.
TIP_BOARD_3 | 110 | Tips board | When Company storage is full, Buy waits. Sell or send stock on to make room.
TIP_BOARD_4 | 110 | Tips board | Prices change each cycle. Open a planet to see today's Buy and Sell prices.
TIP_BOARD_5 | 110 | Tips board | Space pauses the game. Pause to plan, then press Space again.
TIP_BOARD_6 | 110 | Tips board | Skill points come from planets, routes and systems. Spend them in Skills (K).

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
MKT_MIL_ID | 110 | Market identity line, tab tooltip or Competitors panel | Steady buyers and big volume. Some of its skills soften house weather.
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

## Market chains (28 steps; added 2026-11-03, from design/proposals/2026-11-03-four-markets-story.md)
Chain text for Military, Luxury, Minerals and Biotech, steps A1 to A3 and B1 to B4. Ids: EV_<step>_<field>, for example EV_MIL_A1_TITLE. Fields: TITLE, BODY (A1 and B1) or BODY_A and BODY_B (steps 2 and later, keyed to the option picked in the previous step of the same chain), OPA_BTN, OPA_EFF, OPA_RES_TITLE, OPA_RES, OPA_STD, OPA_STD2 (second house line, only where the option has two), and the same for OPB. The placeholders are documented at the top of story/events.md, section "Chain placeholders". Option ids opt_a and opt_b are internal; the game may shuffle the button order. No text states a direction, a count or a stance.

### MIL_A1 (Military, chain A, step 1)
EV_MIL_A1_TITLE | 40 | MIL_A1 choice screen title | A garrison has a war to feed
EV_MIL_A1_BODY | 280 | MIL_A1 choice screen body (one body) | The Admiralty wills Ashgate's high-ring garrison to keep fighting, and Quartermaster Hanno Sulo wills the invoices to match. He bought your first cargo. {bot1} once sent him painted ballast marked as shells. He offers a standing contract with a deposit, or cash by the lot.
EV_MIL_A1_OPA_BTN | 28 | MIL_A1 button, opt_a | Sign the contract
EV_MIL_A1_OPA_EFF | 200 | MIL_A1 effect line, opt_a | Get: Military volume up a little for a while. Cost: {cash_out} credits as the deposit to the garrison. Weather: {bot1}'s next weather comes a little later.
EV_MIL_A1_OPA_RES_TITLE | 32 | MIL_A1 result popup title, opt_a | The contract is signed
EV_MIL_A1_OPA_RES | 280 | MIL_A1 result popup, opt_a; {bot} is bot_1 | Sulo signed with a seal and kept {bot} as a second source, on probation. Orders now come on a schedule and the deposit cost you credits, so Military volume rises for a while. {bot}'s next weather comes a little later. Each crate is read a litany on the dock, and one rattled.
EV_MIL_A1_OPA_STD | 90 | MIL_A1 house line 1, opt_a | {bot1}: next weather comes a little later.
EV_MIL_A1_OPB_BTN | 28 | MIL_A1 button, opt_b | Sell by the lot
EV_MIL_A1_OPB_EFF | 200 | MIL_A1 effect line, opt_b | Get: {cash_in} credits now. Cost: Military volume down a little for a few cycles; {bot3}'s next weather lands a little harder. Weather: {bot1}'s next weather lands a little softer.
EV_MIL_A1_OPB_RES_TITLE | 32 | MIL_A1 result popup title, opt_b | Sold by the lot
EV_MIL_A1_OPB_RES | 280 | MIL_A1 result popup, opt_b; {bot} is bot_1 | Sulo counted the cargo against the estimate and paid cash at the dock. Your own orders dip for a few cycles while the berth stands empty. {bot3}'s next weather lands a little harder. {bot}, found with its painted ballast, sees its next weather land a little softer.
EV_MIL_A1_OPB_STD | 90 | MIL_A1 house line 1, opt_b | {bot1}: next weather lands a little softer.
EV_MIL_A1_OPB_STD2 | 90 | MIL_A1 house line 2, opt_b | {bot3}: next weather lands a little harder.

### MIL_A2 (Military, chain A, step 2)
EV_MIL_A2_TITLE | 40 | MIL_A2 choice screen title | Two fleets claim the same stock
EV_MIL_A2_BODY_A | 280 | MIL_A2 choice screen body after opt_a of MIL_A1 | Your contract holds. Two fleets, each sworn to a different estimate, order the same stock in one cycle, and the Admiralty wills both served first. {bot3} brokers between them and bills both. {bot1} serves one fleet. Fill orders in dock order, or by contract term.
EV_MIL_A2_BODY_B | 280 | MIL_A2 choice screen body after opt_b of MIL_A1 | The garrison has its cargo. Two fleets, each sworn to a different estimate, order the same stock in one cycle, and the Admiralty wills both served first. {bot3} brokers between them and bills both. {bot1} serves one fleet. Fill orders in dock order, or by contract term.
EV_MIL_A2_OPA_BTN | 28 | MIL_A2 button, opt_a | Fill orders by dock
EV_MIL_A2_OPA_EFF | 200 | MIL_A2 effect line, opt_a | Get: Military price up a little for a while. Cost: Ship upkeep rises a little for a while. Weather: {bot3}'s next weather comes a little later.
EV_MIL_A2_OPA_RES_TITLE | 32 | MIL_A2 result popup title, opt_a | Orders filled by dock
EV_MIL_A2_OPA_RES | 280 | MIL_A2 result popup, opt_a; {bot} is bot_3 | Orders went out in dock order, and each fleet was told the other had waited longer. The bidding lifts Military prices a little for a while, and two sets of berths raise Ship upkeep a little. {bot}, the go-between, is one messenger too many: its next weather comes a little later.
EV_MIL_A2_OPA_STD | 90 | MIL_A2 house line 1, opt_a | {bot3}: next weather comes a little later.
EV_MIL_A2_OPB_BTN | 28 | MIL_A2 button, opt_b | Fill orders by term
EV_MIL_A2_OPB_EFF | 200 | MIL_A2 effect line, opt_b | Get: {n} units of tech progress at the Munitions Line. Cost: {cash_out} credits for the stock. Weather: {bot1} {cut}.
EV_MIL_A2_OPB_RES_TITLE | 32 | MIL_A2 result popup title, opt_b | Orders filled by term
EV_MIL_A2_OPB_RES | 280 | MIL_A2 result popup, opt_b; {bot} is bot_1 | Orders went out by term. The fleet {bot1} does not serve held better terms. Its engineers left notes, and your engineer Tavi Brask read them to the press. Tech progress came in. {bot}'s client fell behind, so {bot}'s next weather is held back. The stock cost credits.
EV_MIL_A2_OPB_STD | 90 | MIL_A2 house line 1, opt_b | {bot1}: {cut_std}.

### MIL_A3 (Military, chain A, step 3)
EV_MIL_A3_TITLE | 40 | MIL_A3 choice screen title | Sulo sells a stolen ledger
EV_MIL_A3_BODY_A | 280 | MIL_A3 choice screen body after opt_a of MIL_A2 | Your orders went out in dock order. Sulo, who changed posts and not habits, waits on the dock with a case: {bot1}'s ledger of clients and berths, copied by hand at night, sealed with the Quartermaster-Saint's thumb. He names a price. A ledger is only a list until it is read.
EV_MIL_A3_BODY_B | 280 | MIL_A3 choice screen body after opt_b of MIL_A2 | Your orders went out by contract term. Sulo, who changed posts and not habits, waits on the dock with a case: {bot1}'s ledger of clients and berths, copied by hand at night, sealed with the Quartermaster-Saint's thumb. He names a price. A ledger is only a list until it is read.
EV_MIL_A3_OPA_BTN | 28 | MIL_A3 button, opt_a | Hand it to your buyers
EV_MIL_A3_OPA_EFF | 200 | MIL_A3 effect line, opt_a | Get: {cash_in} credits; Military volume up a little for a while. Cost: Ship upkeep up a little for a while; {bot3}'s weather lands a little harder. Weather: {bot1}'s next weather lands clearly softer.
EV_MIL_A3_OPA_RES_TITLE | 32 | MIL_A3 result popup title, opt_a | The ledger goes to buyers
EV_MIL_A3_OPA_RES | 280 | MIL_A3 result popup, opt_a; {bot} is bot_1 | Your buyers read the ledger aloud and called on every client it listed. Cash came in and orders rose, and the extra hulls raise Ship upkeep a little for a while. {bot}'s next weather lands clearly softer. Sulo sold a second copy to {bot3}, whose weather lands a little harder.
EV_MIL_A3_OPA_STD | 90 | MIL_A3 house line 1, opt_a | {bot1}: next weather lands clearly softer.
EV_MIL_A3_OPA_STD2 | 90 | MIL_A3 house line 2, opt_a | {bot3}: next weather lands a little harder.
EV_MIL_A3_OPB_BTN | 28 | MIL_A3 button, opt_b | Hand it to your workshop
EV_MIL_A3_OPB_EFF | 200 | MIL_A3 effect line, opt_b | Get: {n} units of tech progress at the Munitions Line. Cost: {cash_out} credits to the quartermaster. Weather: {bot1}'s next weather lands a little softer, and {bot3}'s comes a little later.
EV_MIL_A3_OPB_RES_TITLE | 32 | MIL_A3 result popup title, opt_b | The ledger goes to the shop
EV_MIL_A3_OPB_RES | 280 | MIL_A3 result popup, opt_b; {bot} is bot_1 | Your workshop set the ledger's parts and casting notes beside your own. Tech progress came in at the Munitions Line, and Sulo's price cost credits. {bot}'s next weather lands a little softer, and {bot3}, listed too, sends its next weather a little later. Brask thanked the book.
EV_MIL_A3_OPB_STD | 90 | MIL_A3 house line 1, opt_b | {bot1}: next weather lands a little softer.
EV_MIL_A3_OPB_STD2 | 90 | MIL_A3 house line 2, opt_b | {bot3}: next weather comes a little later.

### MIL_B1 (Military, chain B, step 1)
EV_MIL_B1_TITLE | 40 | MIL_B1 choice screen title | A new admiral orders new sensors
EV_MIL_B1_BODY | 280 | MIL_B1 choice screen body (one body) | New Admiral Gabe Nuer took the high ring, and the next day came an order: fit his tracking sensors or pay a heavy port fee. Only his cousin's firm sells them, through {bot1}'s berths, in blessed crates. {bot3} had its own sensors ready. Someone wants the whole market.
EV_MIL_B1_OPA_BTN | 28 | MIL_B1 button, opt_a | Report the scheme
EV_MIL_B1_OPA_EFF | 200 | MIL_B1 effect line, opt_a | Get: {cash_in} credits now. Cost: Ship upkeep rises clearly for a while. Weather: {bot1}'s next weather lands sharply softer.
EV_MIL_B1_OPA_RES_TITLE | 32 | MIL_B1 result popup title, opt_a | The scheme is reported
EV_MIL_B1_OPA_RES | 280 | MIL_B1 result popup, opt_a; {bot} is bot_1 | You sent the order, the price list and the cousin's name to the Bureau. It paid an informant's fee and froze half the refit berths for audit. Your ships stand in queues, so Ship upkeep rises for a while. {bot}'s next weather lands sharply softer: the scheme ran on its berths.
EV_MIL_B1_OPA_STD | 90 | MIL_B1 house line 1, opt_a | {bot1}: next weather lands sharply softer.
EV_MIL_B1_OPB_BTN | 28 | MIL_B1 button, opt_b | Fit the sensors
EV_MIL_B1_OPB_EFF | 200 | MIL_B1 effect line, opt_b | Get: Military volume up a little for the rest of the run. Cost: {cash_out} credits for the slips. Weather: {bot3}'s next weather comes a little later.
EV_MIL_B1_OPB_RES_TITLE | 32 | MIL_B1 result popup title, opt_b | The sensors are fitted
EV_MIL_B1_OPB_RES | 280 | MIL_B1 result popup, opt_b; {bot} is bot_3 | You paid for the sensors and fitted every ship. The admiral's lanes now list you as trusted, so your Military volume rises for the rest of the run. {bot}'s own sensors were turned away, and its next weather comes a little later. The new sensors hum a canticle no list names.
EV_MIL_B1_OPB_STD | 90 | MIL_B1 house line 1, opt_b | {bot3}: next weather comes a little later.

### MIL_B2 (Military, chain B, step 2)
EV_MIL_B2_TITLE | 40 | MIL_B2 choice screen title | Inspector Voss queries a relay
EV_MIL_B2_BODY_A | 280 | MIL_B2 choice screen body after opt_a of MIL_B1 | Since your report, Inspector Kethra Voss audits every refit, her stamp worn like a sidearm. One relay in your batch bears the serial of a ship scrapped before your time. {bot2}'s parade squadrons carry it too, and {bot1}'s older fleets. Send it for review, or swap it and refile.
EV_MIL_B2_BODY_B | 280 | MIL_B2 choice screen body after opt_b of MIL_B1 | Your fleet wears the admiral's sensors. Inspector Kethra Voss, her stamp worn like a sidearm, queries one relay: it bears the serial of a ship scrapped before your time. {bot2}'s parade squadrons carry it too, and {bot1}'s older fleets. Send it for review, or swap it and refile.
EV_MIL_B2_OPA_BTN | 28 | MIL_B2 button, opt_a | Send the part for review
EV_MIL_B2_OPA_EFF | 200 | MIL_B2 effect line, opt_a | Get: Military price up a little for a while. Cost: one route's trip cost rises a little for a while. Weather: {bot2}'s next weather lands a little softer.
EV_MIL_B2_OPA_RES_TITLE | 32 | MIL_B2 result popup title, opt_a | The office reviews the part
EV_MIL_B2_OPA_RES | 280 | MIL_B2 result popup, opt_a; {bot} is bot_2 | The relay went for review. Voss read your forms, then everyone's. {bot}, whose squadrons carry that relay, lost contracts, and its next weather lands a little softer. The cleared stamp lifts Military prices for a while. One route sat in customs, and its trip cost rises a little.
EV_MIL_B2_OPA_STD | 90 | MIL_B2 house line 1, opt_a | {bot2}: next weather lands a little softer.
EV_MIL_B2_OPB_BTN | 28 | MIL_B2 button, opt_b | Swap the part and refile
EV_MIL_B2_OPB_EFF | 200 | MIL_B2 effect line, opt_b | Get: {cash_in} credits for the old part. Cost: Military volume down a little for a few cycles. Weather: {bot1}'s next weather lands a little softer.
EV_MIL_B2_OPB_RES_TITLE | 32 | MIL_B2 result popup title, opt_b | The part is swapped
EV_MIL_B2_OPB_RES | 280 | MIL_B2 result popup, opt_b; {bot} is bot_1 | You swapped the relay and refiled. The old part sold for credits, still humming its dead ship's litany. Voss applied the same clause to {bot1}'s older fleets, which stood idle, so {bot}'s next weather lands a little softer. Ships waited, and Military volume dips for a few cycles.
EV_MIL_B2_OPB_STD | 90 | MIL_B2 house line 1, opt_b | {bot1}: next weather lands a little softer.

### MIL_B3 (Military, chain B, step 3)
EV_MIL_B3_TITLE | 40 | MIL_B3 choice screen title | The Feast of Arms offers a stall
EV_MIL_B3_BODY_A | 280 | MIL_B3 choice screen body after opt_a of MIL_B2 | The relay review is done. Madame Orlenne Vaux, who runs the high-ring Feast of Arms, offers you a place. {bot3} keeps a stand there every year, always crowded. {bot2} holds a gala next door. Buy the main hall for the week, or take the east stand beside {bot3}'s.
EV_MIL_B3_BODY_B | 280 | MIL_B3 choice screen body after opt_b of MIL_B2 | The inspector has ruled on the new relay. Madame Orlenne Vaux, who runs the high-ring Feast of Arms, offers you a place. {bot3} keeps a stand there every year, always crowded. {bot2} holds a gala next door. Buy the main hall for the week, or take the east stand beside {bot3}'s.
EV_MIL_B3_OPA_BTN | 28 | MIL_B3 button, opt_a | Buy the main hall
EV_MIL_B3_OPA_EFF | 200 | MIL_B3 effect line, opt_a | Get: Military volume up a little for a while. Cost: {cash_out} credits for the main hall. Weather: {bot3}'s next weather lands clearly softer.
EV_MIL_B3_OPA_RES_TITLE | 32 | MIL_B3 result popup title, opt_a | The main hall is yours
EV_MIL_B3_OPA_RES | 280 | MIL_B3 result popup, opt_a; {bot} is bot_3 | You bought the hall for the week, and it cost credits. Buyers walked past empty stands to reach yours, so your Military volume rises for a while. {bot} sold from the corridor, and its next weather lands clearly softer. The relic cannon, which fires blanks only, saluted you.
EV_MIL_B3_OPA_STD | 90 | MIL_B3 house line 1, opt_a | {bot3}: next weather lands clearly softer.
EV_MIL_B3_OPB_BTN | 28 | MIL_B3 button, opt_b | Take the east stand
EV_MIL_B3_OPB_EFF | 200 | MIL_B3 effect line, opt_b | Get: {n} units of tech progress. Cost: {cash_out} credits for the stand. Weather: {bot2}'s next weather lands a little softer, and all three houses' next weather comes a little later.
EV_MIL_B3_OPB_RES_TITLE | 32 | MIL_B3 result popup title, opt_b | The east stand
EV_MIL_B3_OPB_RES | 280 | MIL_B3 result popup, opt_b; {bot} is bot_1 | You took the east stand beside {bot3}'s and paid on the day. Two engineers from the next stand talked shop, and tech progress came in. {bot2}, whose gala crowd walked past, gets a little softer weather, and all three houses, {bot} among them, send theirs a little later.
EV_MIL_B3_OPB_STD | 90 | MIL_B3 house line 1, opt_b | All three houses: next weather comes a little later.
EV_MIL_B3_OPB_STD2 | 90 | MIL_B3 house line 2, opt_b | {bot2}: next weather lands a little softer.

### MIL_B4 (Military, chain B, step 4)
EV_MIL_B4_TITLE | 40 | MIL_B4 choice screen title | A Fleet Office clerk asks for terms
EV_MIL_B4_BODY_A | 280 | MIL_B4 choice screen body after opt_a of MIL_B3 | Your week in the main hall brought the fleets to you. A Fleet Office clerk asks you to set the terms of a supply agreement for many cycles, under an estimate that renews itself with the words until victory. Roster deliveries by garrison, or by week. {bot} watches from the door.
EV_MIL_B4_BODY_B | 280 | MIL_B4 choice screen body after opt_b of MIL_B3 | Your days at the east stand brought the fleets to you. A Fleet Office clerk asks you to set the terms of a supply agreement for many cycles, under an estimate that renews itself with the words until victory. Roster deliveries by garrison, or by week. {bot} watches from the door.
EV_MIL_B4_OPA_BTN | 28 | MIL_B4 button, opt_a | Roster by garrison
EV_MIL_B4_OPA_EFF | 200 | MIL_B4 effect line, opt_a | Get: Military price up a little for a while. Cost: Military volume down a little for a while. Weather: {bot1}'s next weather lands clearly softer.
EV_MIL_B4_OPA_RES_TITLE | 32 | MIL_B4 result popup title, opt_a | Rostered by garrison
EV_MIL_B4_OPA_RES | 280 | MIL_B4 result popup, opt_a; {bot} is bot_1 | Deliveries are rostered by garrison, each with its own price sheet and blessing. Military orders thinned for a while as the rosters were written, and the price of standing orders rose. {bot} had counted on the fleets as its client, and its next weather lands clearly softer.
EV_MIL_B4_OPA_STD | 90 | MIL_B4 house line 1, opt_a | {bot1}: next weather lands clearly softer.
EV_MIL_B4_OPB_BTN | 28 | MIL_B4 button, opt_b | Roster by week
EV_MIL_B4_OPB_EFF | 200 | MIL_B4 effect line, opt_b | Get: {cash_in} credits. Cost: Ship upkeep rises clearly for a while. Weather: {bot1}'s next weather lands clearly softer; {bot3}'s lands a little softer.
EV_MIL_B4_OPB_RES_TITLE | 32 | MIL_B4 result popup title, opt_b | Rostered by week
EV_MIL_B4_OPB_RES | 280 | MIL_B4 result popup, opt_b; {bot} is bot_1 | Deliveries are rostered by week from your desk, and the fleets are held ready. A large payment arrived, and the clerk stamped the roster. Ships kept ready cost more, so Ship upkeep rises for a while. {bot}'s next weather lands clearly softer, and {bot3}'s lands a little softer.
EV_MIL_B4_OPB_STD | 90 | MIL_B4 house line 1, opt_b | {bot1}: next weather lands clearly softer.
EV_MIL_B4_OPB_STD2 | 90 | MIL_B4 house line 2, opt_b | {bot3}: next weather lands a little softer.

### MIL_C1 (Military, chain C, step 1; added 2026-11-11)
EV_MIL_C1_TITLE | 40 | MIL_C1 choice screen title | A depot for Dunmere Reach
EV_MIL_C1_BODY | 280 | MIL_C1 choice screen body (one body) | The Fleet Office has an estimate for Dunmere Reach, and a clerk at Cindrel needs a supplier before the next muster. {bot3} runs convoys on the same lane and bills by the hull. Keep a standing depot there, or ship to each muster as it is called.
EV_MIL_C1_OPA_BTN | 28 | MIL_C1 button, opt_a | Keep a standing depot
EV_MIL_C1_OPA_EFF | 200 | MIL_C1 effect line, opt_a | Get: Military volume up a little for a while. Cost: Ship upkeep rises a little for a while. Weather: {bot3}'s next weather comes a little later.
EV_MIL_C1_OPA_RES_TITLE | 32 | MIL_C1 result popup title, opt_a | The depot is stocked
EV_MIL_C1_OPA_RES | 280 | MIL_C1 result popup, opt_a; {bot} is bot_3 | You leased a shed on Cindrel's dock and hired a night watch. Orders now come on a schedule, so Military volume rises for a while, and the watch raises Ship upkeep a little. {bot}'s convoys wait for slots at your door, and its next weather comes a little later.
EV_MIL_C1_OPA_STD | 90 | MIL_C1 house line 1, opt_a | {bot3}: next weather comes a little later.
EV_MIL_C1_OPB_BTN | 28 | MIL_C1 button, opt_b | Ship to each muster
EV_MIL_C1_OPB_EFF | 200 | MIL_C1 effect line, opt_b | Get: {cash_in} credits now. Cost: Military volume down a little for a few cycles. Weather: {bot2}'s next weather lands a little softer.
EV_MIL_C1_OPB_RES_TITLE | 32 | MIL_C1 result popup title, opt_b | Mustered, one at a time
EV_MIL_C1_OPB_RES | 280 | MIL_C1 result popup, opt_b; {bot} is bot_2 | You shipped to each muster as it was called, and the clerk paid on the day. Your own orders dipped for a few cycles while the berth stood empty. {bot} had counted on the Fleet Office's steady custom, and its next weather lands a little softer.
EV_MIL_C1_OPB_STD | 90 | MIL_C1 house line 1, opt_b | {bot2}: next weather lands a little softer.

### MIL_C2 (Military, chain C, step 2; added 2026-11-11)
EV_MIL_C2_TITLE | 40 | MIL_C2 choice screen title | The inspector counts the halls
EV_MIL_C2_BODY_A | 280 | MIL_C2 choice screen body after opt_a of MIL_C1 | Your depot at Cindrel is stocked, and word of it reached the Bazaar. Inspector Kethra Voss comes to the new halls with her stamp worn like a sidearm. She will pass every door in one visit for a charge, or one by one on her own time. {bot1} has already paid.
EV_MIL_C2_BODY_B | 280 | MIL_C2 choice screen body after opt_b of MIL_C1 | Your musters were paid, and word of it reached the Bazaar. Inspector Kethra Voss comes to the new halls with her stamp worn like a sidearm. She will pass every door in one visit for a charge, or one by one on her own time. {bot1} has already paid.
EV_MIL_C2_OPA_BTN | 28 | MIL_C2 button, opt_a | Pay for one visit
EV_MIL_C2_OPA_EFF | 200 | MIL_C2 effect line, opt_a | Get: Military price up a little for a while. Cost: {cash_out} credits for the visit. Weather: {bot1}'s next weather lands clearly softer.
EV_MIL_C2_OPA_RES_TITLE | 32 | MIL_C2 result popup title, opt_a | Every door, one stamp
EV_MIL_C2_OPA_RES | 280 | MIL_C2 result popup, opt_a; {bot} is bot_1 | Voss passed every door in one visit and stamped the last as if it were a ruling. The visit cost credits, and Military price rises a little for a while. {bot} had paid first, and its next weather lands clearly softer.
EV_MIL_C2_OPA_STD | 90 | MIL_C2 house line 1, opt_a | {bot1}: next weather lands clearly softer.
EV_MIL_C2_OPB_BTN | 28 | MIL_C2 button, opt_b | Wait door by door
EV_MIL_C2_OPB_EFF | 200 | MIL_C2 effect line, opt_b | Get: one route's trip cost down a little for a while. Cost: Military volume down a little for a while. Weather: {bot2}'s next weather comes a little later.
EV_MIL_C2_OPB_RES_TITLE | 32 | MIL_C2 result popup title, opt_b | A door at a time
EV_MIL_C2_OPB_RES | 280 | MIL_C2 result popup, opt_b; {bot} is bot_2 | Voss passed the doors one by one on her own time, and your crew stood by each. The busiest route's trip cost falls a little for a while, and Military volume dips as berths wait. {bot}'s next weather comes a little later.
EV_MIL_C2_OPB_STD | 90 | MIL_C2 house line 1, opt_b | {bot2}: next weather comes a little later.

### MIL_C3 (Military, chain C, step 3; added 2026-11-11)
EV_MIL_C3_TITLE | 40 | MIL_C3 choice screen title | The estimate renews itself
EV_MIL_C3_BODY_A | 280 | MIL_C3 choice screen body after opt_a of MIL_C2 | Your stamp is on every hall, and the Fleet Office has noticed. Admiral Gabe Nuer renews the estimate with the words until victory, again. Take a standing order for the Bazaar's stores, or sell the Fleet Office your slack in one lot. {bot1} is already counting.
EV_MIL_C3_BODY_B | 280 | MIL_C3 choice screen body after opt_b of MIL_C2 | Your halls were passed one door at a time, and the Fleet Office has noticed. Admiral Gabe Nuer renews the estimate with the words until victory, again. Take a standing order for the Bazaar's stores, or sell the Fleet Office your slack in one lot. {bot1} is already counting.
EV_MIL_C3_OPA_BTN | 28 | MIL_C3 button, opt_a | Take the standing order
EV_MIL_C3_OPA_EFF | 200 | MIL_C3 effect line, opt_a | Get: Military volume up clearly for a while. Cost: Military price down a little for a while. Weather: {bot3}'s next weather comes a little later.
EV_MIL_C3_OPA_RES_TITLE | 32 | MIL_C3 result popup title, opt_a | Until victory, in writing
EV_MIL_C3_OPA_RES | 280 | MIL_C3 result popup, opt_a; {bot} is bot_3 | The Fleet Office stamped your standing order with the words until victory. Military volume rises clearly for a while, and the standing price pulls Military price down a little. {bot}'s convoys wait on your berths, and its next weather comes a little later.
EV_MIL_C3_OPA_STD | 90 | MIL_C3 house line 1, opt_a | {bot3}: next weather comes a little later.
EV_MIL_C3_OPB_BTN | 28 | MIL_C3 button, opt_b | Sell the slack at once
EV_MIL_C3_OPB_EFF | 200 | MIL_C3 effect line, opt_b | Get: {cash_in} credits now. Cost: Military volume down clearly for a few cycles while berths empty. Weather: {bot1} {cut}.
EV_MIL_C3_OPB_RES_TITLE | 32 | MIL_C3 result popup title, opt_b | The slack is sold
EV_MIL_C3_OPB_RES | 280 | MIL_C3 result popup, opt_b; {bot} is bot_1 | You sold the slack in one lot, and the Admiral's clerk paid at the dock. Military volume falls clearly for a few cycles while the berths empty. {bot} had meant to carry the estimate, and its next weather is held back.
EV_MIL_C3_OPB_STD | 90 | MIL_C3 house line 1, opt_b | {bot1}: {cut_std}.

### LUX_A1 (Luxury, chain A, step 1)
EV_LUX_A1_TITLE | 40 | LUX_A1 choice screen title | Madame Marr demands the first pick
EV_LUX_A1_BODY | 280 | LUX_A1 choice screen body (one body) | Madame Ysolde Marr, queen of Quillon's gallery ring, wants the first luxury lot of every cycle, before any other buyer sees it. She sniffs every lid and swears each lot picks its owner. {bot2} feeds her now, and {bot3} keeps a stall on her ring. Name a price, or sell her one lot.
EV_LUX_A1_OPA_BTN | 28 | LUX_A1 button, opt_a | Name the first-pick price
EV_LUX_A1_OPA_EFF | 200 | LUX_A1 effect line, opt_a | Get: Luxury prices rise a little for a while. Cost: Luxury volume falls a little for a while. Weather: {bot2}'s next weather lands a little softer.
EV_LUX_A1_OPA_RES_TITLE | 32 | LUX_A1 result popup title, opt_a | Madame Marr gets her way
EV_LUX_A1_OPA_RES | 280 | LUX_A1 result popup, opt_a; {bot} is bot_2 | Madame Marr accepts the price and the best lots now go to her ring first. Fewer reach the shelves, so volume dips and prices climb a little. {bot} has lost her favour, and its next weather lands a little softer. She sniffed every lid, and she was pleased.
EV_LUX_A1_OPA_STD | 90 | LUX_A1 house line 1, opt_a | {bot2}: next weather lands a little softer.
EV_LUX_A1_OPB_BTN | 28 | LUX_A1 button, opt_b | Sell her one first lot
EV_LUX_A1_OPB_EFF | 200 | LUX_A1 effect line, opt_b | Get: {cash_in} credits now. Cost: Luxury volume falls a little for a few cycles, and {bot2}'s next weather comes a little sooner. Weather: {bot3}'s next weather lands a little softer.
EV_LUX_A1_OPB_RES_TITLE | 32 | LUX_A1 result popup title, opt_b | One lot, paid in full
EV_LUX_A1_OPB_RES | 280 | LUX_A1 result popup, opt_b; {bot} is bot_3 | Madame Marr paid for one first lot on the dock, and the credits reached you within the hour. The shelves stood bare for a few cycles. {bot2} fed her next lot, so its weather comes a little sooner. {bot} found its stall on her ring empty, and its weather lands a little softer.
EV_LUX_A1_OPB_STD | 90 | LUX_A1 house line 1, opt_b | {bot3}: next weather lands a little softer.
EV_LUX_A1_OPB_STD2 | 90 | LUX_A1 house line 2, opt_b | {bot2}: next weather comes a little sooner.

### LUX_A2 (Luxury, chain A, step 2)
EV_LUX_A2_TITLE | 40 | LUX_A2 choice screen title | A master finisher takes offers
EV_LUX_A2_BODY_A | 280 | LUX_A2 choice screen body after opt_a of LUX_A1 | The first pick is priced and the crates go out. Master finisher Oren Vask has left his guild atelier, which called his signature a smudge, and takes offers for a season. {bot2} wants his hands for its own gem room. Hire him, or take his finished pieces on contract.
EV_LUX_A2_BODY_B | 280 | LUX_A2 choice screen body after opt_b of LUX_A1 | The patron has bought her first lot. Master finisher Oren Vask has left his guild atelier, which called his signature a smudge, and takes offers for a season. {bot2} wants his hands for its own gem room. Hire him, or take his finished pieces on contract.
EV_LUX_A2_OPA_BTN | 28 | LUX_A2 button, opt_a | Hire the finisher
EV_LUX_A2_OPA_EFF | 200 | LUX_A2 effect line, opt_a | Get: {n} units of tech progress at the Atelier. Cost: {cash_out} credits in fees. Weather: {bot2}'s next weather comes sharply later.
EV_LUX_A2_OPA_RES_TITLE | 32 | LUX_A2 result popup title, opt_a | The finisher joins the atelier
EV_LUX_A2_OPA_RES | 280 | LUX_A2 result popup, opt_a; {bot} is bot_2 | Vask took a bench in your atelier and showed the crew a cut they had not seen. Tech progress came in, and the fees were paid. {bot} had planned his hands for its gem room, and its next weather comes sharply later. His chalk marks are still on the old bench.
EV_LUX_A2_OPA_STD | 90 | LUX_A2 house line 1, opt_a | {bot2}: next weather comes sharply later.
EV_LUX_A2_OPB_BTN | 28 | LUX_A2 button, opt_b | Take the pieces
EV_LUX_A2_OPB_EFF | 200 | LUX_A2 effect line, opt_b | Get: Luxury volume up a little for the rest of the run. Cost: Luxury price down a little for a few cycles. Weather: {bot2} {cut}.
EV_LUX_A2_OPB_RES_TITLE | 32 | LUX_A2 result popup title, opt_b | Pieces on contract
EV_LUX_A2_OPB_RES | 280 | LUX_A2 result popup, opt_b; {bot} is bot_2 | Vask's pieces came to you on contract and fill your counters, priced a little low for a few cycles, so Luxury volume rises for the rest of the run. {bot} lost his work and has its next weather held back. The gems carry a hallmark in a hand nobody knows.
EV_LUX_A2_OPB_STD | 90 | LUX_A2 house line 1, opt_b | {bot2}: {cut_std}.

### LUX_A3 (Luxury, chain A, step 3)
EV_LUX_A3_TITLE | 40 | LUX_A3 choice screen title | A buyer returns a house's batch
EV_LUX_A3_BODY_A | 280 | LUX_A3 choice screen body after opt_a of LUX_A2 | Vask is at your atelier. Lord Ferrin Gale has sent back a whole batch of {bot2}'s work, calling it loud, and asks you to fill the order. He pays a premium for a name, or gives a place on his list for a price a little low. {bot3} keeps a table at his door.
EV_LUX_A3_BODY_B | 280 | LUX_A3 choice screen body after opt_b of LUX_A2 | Vask's pieces are on your counters. Lord Ferrin Gale has sent back a whole batch of {bot2}'s work, calling it loud, and asks you to fill the order. He pays a premium for a name, or gives a place on his list for a price a little low. {bot3} keeps a table at his door.
EV_LUX_A3_OPA_BTN | 28 | LUX_A3 button, opt_a | Fill the order by name
EV_LUX_A3_OPA_EFF | 200 | LUX_A3 effect line, opt_a | Get: Luxury price up clearly for a while. Cost: {cash_out} credits for the hallmarks. Weather: {bot2}'s next weather lands sharply softer for a few cycles.
EV_LUX_A3_OPA_RES_TITLE | 32 | LUX_A3 result popup title, opt_a | Filled by name
EV_LUX_A3_OPA_RES | 280 | LUX_A3 result popup, opt_a; {bot} is bot_2 | You filled the order under your own mark, and Lord Gale paid the premium. The hallmarks cost credits. {bot}, whose batch was sent back, sees its next weather land sharply softer for a few cycles. The returned crates sit in his cellar, unopened, and he has not asked for a receipt.
EV_LUX_A3_OPA_STD | 90 | LUX_A3 house line 1, opt_a | {bot2}: next weather lands sharply softer for a few cycles.
EV_LUX_A3_OPB_BTN | 28 | LUX_A3 button, opt_b | Fill the order by list
EV_LUX_A3_OPB_EFF | 200 | LUX_A3 effect line, opt_b | Get: Luxury volume up a little for a while. Cost: Luxury price down a little for a few cycles. Weather: {bot3}'s next weather lands a little softer.
EV_LUX_A3_OPB_RES_TITLE | 32 | LUX_A3 result popup title, opt_b | Filled by list
EV_LUX_A3_OPB_RES | 280 | LUX_A3 result popup, opt_b; {bot} is bot_3 | You filled the order for a place on Lord Gale's list, at a price a little low for a few cycles. His list sends its friends, so your orders rose for a while. {bot}, whose table stood by the door, sees its next weather land a little softer. The list is written in green ink.
EV_LUX_A3_OPB_STD | 90 | LUX_A3 house line 1, opt_b | {bot3}: next weather lands a little softer.

### LUX_B1 (Luxury, chain B, step 1)
EV_LUX_B1_TITLE | 40 | LUX_B1 choice screen title | A pavilion books a masked evening
EV_LUX_B1_BODY | 280 | LUX_B1 choice screen body (one body) | The pavilion on the Quillon ring has booked an Evening of Many Faces, where every guest arrives as someone else, and wants stock: silk, sunmusk, cut glimmers. {bot2} supplies its cellar, and {bot3} waits with samples. Sell the venue its stock, or stock the stalls yourself.
EV_LUX_B1_OPA_BTN | 28 | LUX_B1 button, opt_a | Sell the venue its stock
EV_LUX_B1_OPA_EFF | 200 | LUX_B1 effect line, opt_a | Get: {cash_in} credits now. Cost: Luxury volume down a little for a while. Weather: {bot2}'s next weather comes a little later.
EV_LUX_B1_OPA_RES_TITLE | 32 | LUX_B1 result popup title, opt_a | The venue buys its stock
EV_LUX_B1_OPA_RES | 280 | LUX_B1 result popup, opt_a; {bot} is bot_2 | The venue bought its stock outright and paid on the night. Your own counters ran thin while the crates were gone, so Luxury volume dips for a while. {bot}'s cellar supply lost the date, and its next weather comes a little later. Every mask in the pavilion faced the door.
EV_LUX_B1_OPA_STD | 90 | LUX_B1 house line 1, opt_a | {bot2}: next weather comes a little later.
EV_LUX_B1_OPB_BTN | 28 | LUX_B1 button, opt_b | Stock the stalls yourself
EV_LUX_B1_OPB_EFF | 200 | LUX_B1 effect line, opt_b | Get: Luxury volume up clearly for a while. Cost: {cash_out} credits for the stalls. Weather: {bot2}'s next weather lands clearly softer.
EV_LUX_B1_OPB_RES_TITLE | 32 | LUX_B1 result popup title, opt_b | Your stalls fill the evening
EV_LUX_B1_OPB_RES | 280 | LUX_B1 result popup, opt_b; {bot} is bot_2 | Your stalls stood in the pavilion all evening, and buyers came to them first. Your orders rose for a while, and the stalls cost credits. {bot} found its crates unwanted, and its next weather lands clearly softer. A mask with nothing behind it hung on every pillar.
EV_LUX_B1_OPB_STD | 90 | LUX_B1 house line 1, opt_b | {bot2}: next weather lands clearly softer.

### LUX_B2 (Luxury, chain B, step 2)
EV_LUX_B2_TITLE | 40 | LUX_B2 choice screen title | The guest list is posted on a wall
EV_LUX_B2_BODY_A | 280 | LUX_B2 choice screen body after opt_a of LUX_B1 | You sold the venue its stock. The next morning the pavilion's guest list, every name and every order, hung on a wall for a day. {bot3} copied it by the hour, and {bot2} denied there was a list. Study the list at your atelier, or sell your copy.
EV_LUX_B2_BODY_B | 280 | LUX_B2 choice screen body after opt_b of LUX_B1 | You stocked the venue's stalls. The next morning the pavilion's guest list, every name and every order, hung on a wall for a day. {bot3} copied it by the hour, and {bot2} denied there was a list. Study the list at your atelier, or sell your copy.
EV_LUX_B2_OPA_BTN | 28 | LUX_B2 button, opt_a | Study the list
EV_LUX_B2_OPA_EFF | 200 | LUX_B2 effect line, opt_a | Get: {n} units of tech progress at the Atelier. Cost: Luxury price down a little for a few cycles. Weather: {bot2}'s next weather lands a little softer; {bot3}'s comes sharply later.
EV_LUX_B2_OPA_RES_TITLE | 32 | LUX_B2 result popup title, opt_a | The list is studied
EV_LUX_B2_OPA_RES | 280 | LUX_B2 result popup, opt_a; {bot} is bot_3 | Your atelier read the names against the orders and learned which cuts the buyers asked for. Tech progress came in, and prices dipped a little for a few cycles as buyers saw your hand. {bot2}'s next weather lands a little softer, and {bot}'s next weather comes sharply later.
EV_LUX_B2_OPA_STD | 90 | LUX_B2 house line 1, opt_a | {bot3}: next weather comes sharply later.
EV_LUX_B2_OPA_STD2 | 90 | LUX_B2 house line 2, opt_a | {bot2}: next weather lands a little softer.
EV_LUX_B2_OPB_BTN | 28 | LUX_B2 button, opt_b | Sell your copy
EV_LUX_B2_OPB_EFF | 200 | LUX_B2 effect line, opt_b | Get: {cash_in} credits. Cost: Luxury price down a little for a few cycles; {bot2}'s next weather lands clearly harder. Weather: {bot2} {cut}.
EV_LUX_B2_OPB_RES_TITLE | 32 | LUX_B2 result popup title, opt_b | The copy is sold
EV_LUX_B2_OPB_RES | 280 | LUX_B2 result popup, opt_b; {bot} is bot_2 | You sold your copy to the table that offered most, and the cash came in. {bot} was the buyer, so its next weather lands clearly harder, though its own name stood on the list, so it is held back too. Prices dipped a little for a few cycles. A pale square marks the wall.
EV_LUX_B2_OPB_STD | 90 | LUX_B2 house line 1, opt_b | {bot2}: {cut_std}.
EV_LUX_B2_OPB_STD2 | 90 | LUX_B2 house line 2, opt_b | {bot2}: next weather lands clearly harder.

### LUX_B3 (Luxury, chain B, step 3)
EV_LUX_B3_TITLE | 40 | LUX_B3 choice screen title | A buyer asks for a fixed price
EV_LUX_B3_BODY_A | 280 | LUX_B3 choice screen body after opt_a of LUX_B2 | You studied the list. A buyer of masks and glimmers asks you to name one price and hold it for a set period. {bot2} would sell to the buyer at floating rates, and {bot1} would take any contract that moves stock. Fix the price, or sell the lot at today's rate.
EV_LUX_B3_BODY_B | 280 | LUX_B3 choice screen body after opt_b of LUX_B2 | You sold your copy of the list. A buyer of masks and glimmers asks you to name one price and hold it for a set period. {bot2} would sell to the buyer at floating rates, and {bot1} would take any contract that moves stock. Fix the price, or sell the lot at today's rate.
EV_LUX_B3_OPA_BTN | 28 | LUX_B3 button, opt_a | Fix the price for a term
EV_LUX_B3_OPA_EFF | 200 | LUX_B3 effect line, opt_a | Get: Luxury price up clearly for a while. Cost: Luxury volume down a little for a while. Weather: {bot2}'s next weather comes sharply later.
EV_LUX_B3_OPA_RES_TITLE | 32 | LUX_B3 result popup title, opt_a | The price is fixed
EV_LUX_B3_OPA_RES | 280 | LUX_B3 result popup, opt_a; {bot} is bot_2 | The buyer signed one price for the whole term, and your counters held it. Luxury prices rose clearly for a while, and your volume eased as casual buyers stayed away. {bot}'s floating rates could not follow, and its weather comes sharply later. The stamp is shaped like a mask.
EV_LUX_B3_OPA_STD | 90 | LUX_B3 house line 1, opt_a | {bot2}: next weather comes sharply later.
EV_LUX_B3_OPB_BTN | 28 | LUX_B3 button, opt_b | Sell the lot at today's rate
EV_LUX_B3_OPB_EFF | 200 | LUX_B3 effect line, opt_b | Get: {cash_in} credits now. Cost: Luxury volume down a little for a while; {bot3}'s next weather lands a little harder. Weather: {bot1}'s and {bot2}'s next weather lands a little softer.
EV_LUX_B3_OPB_RES_TITLE | 32 | LUX_B3 result popup title, opt_b | The lot is sold
EV_LUX_B3_OPB_RES | 280 | LUX_B3 result popup, opt_b; {bot} is bot_1 | You sold the lot at the day's rate and cash came in. Your shelves ran lean for a while. {bot3} picked up what the buyer still wanted, so its weather lands a little harder, while {bot} and {bot2} each see theirs land a little softer. The buyer left with the crates and no receipt.
EV_LUX_B3_OPB_STD | 90 | LUX_B3 house line 1, opt_b | {bot1} and {bot2}: next weather lands a little softer.
EV_LUX_B3_OPB_STD2 | 90 | LUX_B3 house line 2, opt_b | {bot3}: next weather lands a little harder.

### LUX_B4 (Luxury, chain B, step 4)
EV_LUX_B4_TITLE | 40 | LUX_B4 choice screen title | The Guild of Masks offers a seat
EV_LUX_B4_BODY_A | 280 | LUX_B4 choice screen body after opt_a of LUX_B3 | Your fixed price held through the term, and the guild noticed. The Guild of Masks offers you a seat on its board. {bot2} holds the chair, and {bot3} sits by the door. Take the pricing desk or the stock desk. Both meet weekly behind a gilt screen.
EV_LUX_B4_BODY_B | 280 | LUX_B4 choice screen body after opt_b of LUX_B3 | You sold the lot at the day's rate, and the guild noticed. The Guild of Masks offers you a seat on its board. {bot2} holds the chair, and {bot3} sits by the door. Take the pricing desk or the stock desk. Both meet weekly behind a gilt screen.
EV_LUX_B4_OPA_BTN | 28 | LUX_B4 button, opt_a | Take the pricing desk
EV_LUX_B4_OPA_EFF | 200 | LUX_B4 effect line, opt_a | Get: Luxury price up a little for a while. Cost: {cash_out} credits in dues for the pricing seat. Weather: {bot2}'s next weather lands sharply softer.
EV_LUX_B4_OPA_RES_TITLE | 32 | LUX_B4 result popup title, opt_a | The pricing desk is yours
EV_LUX_B4_OPA_RES | 280 | LUX_B4 result popup, opt_a; {bot} is bot_2 | You took the pricing desk and paid the dues on the day. The guild's price sheets now carry your marks, and prices rose a little for a while. {bot} sat in the chair and watched its next weather land sharply softer. The sheets are printed on gilt-edged paper.
EV_LUX_B4_OPA_STD | 90 | LUX_B4 house line 1, opt_a | {bot2}: next weather lands sharply softer.
EV_LUX_B4_OPB_BTN | 28 | LUX_B4 button, opt_b | Take the stock desk
EV_LUX_B4_OPB_EFF | 200 | LUX_B4 effect line, opt_b | Get: Luxury volume up a little for the rest of the run. Cost: Luxury price down a little for a while. Weather: {bot2}'s next weather lands clearly softer; {bot3}'s lands a little softer.
EV_LUX_B4_OPB_RES_TITLE | 32 | LUX_B4 result popup title, opt_b | The stock desk is yours
EV_LUX_B4_OPB_RES | 280 | LUX_B4 result popup, opt_b; {bot} is bot_2 | You took the stock desk and the schedules came to your hand. Luxury volume rose for the rest of the run, and prices eased a little for a while. {bot}'s next weather lands clearly softer, and {bot3}'s lands a little softer. The desk has a bell that no one rings.
EV_LUX_B4_OPB_STD | 90 | LUX_B4 house line 1, opt_b | {bot2}: next weather lands clearly softer.
EV_LUX_B4_OPB_STD2 | 90 | LUX_B4 house line 2, opt_b | {bot3}: next weather lands a little softer.

### LUX_C1 (Luxury, chain C, step 1; added 2026-11-11)
EV_LUX_C1_TITLE | 40 | LUX_C1 choice screen title | Madame Marr wants a standing order
EV_LUX_C1_BODY | 280 | LUX_C1 choice screen body (one body) | Madame Marr of Quillon's gallery ring wants a season of luxuries sent to her door unseen. She says a thing seen first is a thing spoiled. {bot2} would fill it at floating rates, and {bot3} keeps a stall by her door. Fill the standing order, or sell her one sealed lot.
EV_LUX_C1_OPA_BTN | 28 | LUX_C1 button, opt_a | Fill the standing order
EV_LUX_C1_OPA_EFF | 200 | LUX_C1 effect line, opt_a | Get: Luxury price up a little for a while. Cost: Luxury volume down a little for a while. Weather: {bot2}'s next weather comes a little later.
EV_LUX_C1_OPA_RES_TITLE | 32 | LUX_C1 result popup title, opt_a | The order goes unseen
EV_LUX_C1_OPA_RES | 280 | LUX_C1 result popup, opt_a; {bot} is bot_2 | Madame Marr took the standing order unseen and sent word round her ring. Luxury price rises a little for a while, and fewer lots reach the shelves, so volume dips. {bot} fed her the first season, and its next weather comes a little later.
EV_LUX_C1_OPA_STD | 90 | LUX_C1 house line 1, opt_a | {bot2}: next weather comes a little later.
EV_LUX_C1_OPB_BTN | 28 | LUX_C1 button, opt_b | Sell one sealed lot
EV_LUX_C1_OPB_EFF | 200 | LUX_C1 effect line, opt_b | Get: {cash_in} credits now. Cost: Ship upkeep rises a little for a while. Weather: {bot3}'s next weather lands a little softer.
EV_LUX_C1_OPB_RES_TITLE | 32 | LUX_C1 result popup title, opt_b | One lot under seal
EV_LUX_C1_OPB_RES | 280 | LUX_C1 result popup, opt_b; {bot} is bot_3 | Madame Marr paid for one sealed lot, and the lot went out under a courier's seal. Credits reached you within the hour, and the sealed hull raised Ship upkeep a little. {bot} found its stall at her door empty, and its next weather lands a little softer.
EV_LUX_C1_OPB_STD | 90 | LUX_C1 house line 1, opt_b | {bot3}: next weather lands a little softer.

### LUX_C2 (Luxury, chain C, step 2; added 2026-11-11)
EV_LUX_C2_TITLE | 40 | LUX_C2 choice screen title | The Guild hangs masks in the halls
EV_LUX_C2_BODY_A | 280 | LUX_C2 choice screen body after opt_a of LUX_C1 | Your standing order pleased the gallery ring, and the Guild of Masks has noticed. It hangs its masks in the Bazaar's new halls and wants luxuries on every stand. Lend a masked display for the season, or sell masks by the case. {bot2} holds the chair, and {bot3} sits by the door.
EV_LUX_C2_BODY_B | 280 | LUX_C2 choice screen body after opt_b of LUX_C1 | Your sealed lot pleased the gallery ring, and the Guild of Masks has noticed. It hangs its masks in the Bazaar's new halls and wants luxuries on every stand. Lend a masked display for the season, or sell masks by the case. {bot2} holds the chair, and {bot3} sits by the door.
EV_LUX_C2_OPA_BTN | 28 | LUX_C2 button, opt_a | Lend a masked display
EV_LUX_C2_OPA_EFF | 200 | LUX_C2 effect line, opt_a | Get: Luxury volume up a little for a while. Cost: {cash_out} credits for the display. Weather: {bot2}'s next weather lands a little softer.
EV_LUX_C2_OPA_RES_TITLE | 32 | LUX_C2 result popup title, opt_a | A mask on every stand
EV_LUX_C2_OPA_RES | 280 | LUX_C2 result popup, opt_a; {bot} is bot_2 | The Guild hung your masked display in the east hall, and every guest passed it. The display cost credits, and Luxury volume rises a little for a while. {bot} held the chair and gave up a stand, and its next weather lands a little softer.
EV_LUX_C2_OPA_STD | 90 | LUX_C2 house line 1, opt_a | {bot2}: next weather lands a little softer.
EV_LUX_C2_OPB_BTN | 28 | LUX_C2 button, opt_b | Sell masks by the case
EV_LUX_C2_OPB_EFF | 200 | LUX_C2 effect line, opt_b | Get: {cash_in} credits now. Cost: Luxury price down a little for a while. Weather: {bot3}'s next weather comes a little later.
EV_LUX_C2_OPB_RES_TITLE | 32 | LUX_C2 result popup title, opt_b | Masks by the case
EV_LUX_C2_OPB_RES | 280 | LUX_C2 result popup, opt_b; {bot} is bot_3 | You sold masks by the case at the hall door, and the Guild's clerk paid on the spot. Luxury price falls a little for a while as the cases crowd the doors. {bot} sat by the door and watched them go, and its next weather comes a little later.
EV_LUX_C2_OPB_STD | 90 | LUX_C2 house line 1, opt_b | {bot3}: next weather comes a little later.

### LUX_C3 (Luxury, chain C, step 3; added 2026-11-11)
EV_LUX_C3_TITLE | 40 | LUX_C3 choice screen title | The Orrel House returns to the hall
EV_LUX_C3_BODY_A | 280 | LUX_C3 choice screen body after opt_a of LUX_C2 | Your masked display hangs in the Great Hall, and the Orrel House holds its gala beneath it. The house offers you the head table, where every glass turns, or the cloakroom, where every guest passes your crates twice. {bot2} watches the guest list.
EV_LUX_C3_BODY_B | 280 | LUX_C3 choice screen body after opt_b of LUX_C2 | Your masks sold out at the hall door, and the Orrel House holds its gala beneath the empty hooks. The house offers you the head table, where every glass turns, or the cloakroom, where every guest passes your crates twice. {bot2} watches the guest list.
EV_LUX_C3_OPA_BTN | 28 | LUX_C3 button, opt_a | Take the head table
EV_LUX_C3_OPA_EFF | 200 | LUX_C3 effect line, opt_a | Get: Luxury price up clearly for a while. Cost: {cash_out} credits for the table. Weather: {bot2}'s next weather lands clearly softer.
EV_LUX_C3_OPA_RES_TITLE | 32 | LUX_C3 result popup title, opt_a | The head table
EV_LUX_C3_OPA_RES | 280 | LUX_C3 result popup, opt_a; {bot} is bot_2 | You took the head table, and every glass in the hall turned toward it. The table cost credits, and Luxury price rises clearly for a while. {bot} kept the guest list and found your name above its own, so its next weather lands clearly softer.
EV_LUX_C3_OPA_STD | 90 | LUX_C3 house line 1, opt_a | {bot2}: next weather lands clearly softer.
EV_LUX_C3_OPB_BTN | 28 | LUX_C3 button, opt_b | Take the cloakroom
EV_LUX_C3_OPB_EFF | 200 | LUX_C3 effect line, opt_b | Get: Luxury volume up clearly for a while. Cost: Luxury price down a little for a while. Weather: {bot1}'s next weather comes a little later.
EV_LUX_C3_OPB_RES_TITLE | 32 | LUX_C3 result popup title, opt_b | The cloakroom
EV_LUX_C3_OPB_RES | 280 | LUX_C3 result popup, opt_b; {bot} is bot_1 | You took the cloakroom, and every guest passed your crates twice. Luxury volume rises clearly for a while, and Luxury price falls a little as the tags pile up. {bot} was told the cloakroom was full, and its next weather comes a little later.
EV_LUX_C3_OPB_STD | 90 | LUX_C3 house line 1, opt_b | {bot1}: next weather comes a little later.

### MIN_A1 (Minerals, chain A, step 1)
EV_MIN_A1_TITLE | 40 | MIN_A1 choice screen title | Cinderrest's cable frays on schedule
EV_MIN_A1_BODY | 280 | MIN_A1 choice screen body (one body) | Shift chief Brakka Dun reports that Cinderrest's lift cable frayed at exactly the length of its warranty, and the lamps drop out on the lower level. {bot1} runs the next shaft, sells cable, and offers to lend crew and rope, for a price. Sell the lower level, or replace the cable.
EV_MIN_A1_OPA_BTN | 28 | MIN_A1 button, opt_a | Sell the lower level
EV_MIN_A1_OPA_EFF | 200 | MIN_A1 effect line, opt_a | Get: {cash_in} credits now. Cost: Minerals volume down a little for a while. Weather: {bot1}'s next weather comes a little later.
EV_MIN_A1_OPA_RES_TITLE | 32 | MIN_A1 result popup title, opt_a | The lower level is sold
EV_MIN_A1_OPA_RES | 280 | MIN_A1 result popup, opt_a; {bot} is bot_1 | A buyer took the lower level and paid on the lift. Your crew works the upper cuts, so Minerals volume dipped for a while. {bot} wanted the level and cut elsewhere, and its next weather comes a little later. The lamps below still burn, for no one.
EV_MIN_A1_OPA_STD | 90 | MIN_A1 house line 1, opt_a | {bot1}: next weather comes a little later.
EV_MIN_A1_OPB_BTN | 28 | MIN_A1 button, opt_b | Replace the cable
EV_MIN_A1_OPB_EFF | 200 | MIN_A1 effect line, opt_b | Get: Minerals volume up a little for a while. Cost: {cash_out} credits for the cable. Weather: {bot1}'s next weather lands a little softer.
EV_MIN_A1_OPB_RES_TITLE | 32 | MIN_A1 result popup title, opt_b | The cable is replaced
EV_MIN_A1_OPB_RES | 280 | MIN_A1 result popup, opt_b; {bot} is bot_1 | A new cable went down and the lamps held. It cost credits, and the crew cut more for a while, so Minerals volume rises. {bot} had counted on lending you its crew, and its next weather lands a little softer. Brakka coiled the old cable at the shaft head. It was still warm.
EV_MIN_A1_OPB_STD | 90 | MIN_A1 house line 1, opt_b | {bot1}: next weather lands a little softer.

### MIN_A2 (Minerals, chain A, step 2)
EV_MIN_A2_TITLE | 40 | MIN_A2 choice screen title | Greywake's beam is cracked
EV_MIN_A2_BODY_A | 280 | MIN_A2 choice screen body after opt_a of MIN_A1 | You sold the lower level at Cinderrest. Now a roof beam in Greywake's main cut has cracked, and the glass beneath rings in the crew's teeth. {bot3} works the next cut and wants the same beams. Brace the beam, or sell the cut.
EV_MIN_A2_BODY_B | 280 | MIN_A2 choice screen body after opt_b of MIN_A1 | You replaced the cable at Cinderrest. Now a roof beam in Greywake's main cut has cracked, and the glass beneath rings in the crew's teeth. {bot3} works the next cut and wants the same beams. Brace the beam, or sell the cut.
EV_MIN_A2_OPA_BTN | 28 | MIN_A2 button, opt_a | Brace the beam
EV_MIN_A2_OPA_EFF | 200 | MIN_A2 effect line, opt_a | Get: Minerals volume up a little for a while. Cost: {cash_out} credits for the bracing. Weather: {bot3}'s next weather comes clearly later.
EV_MIN_A2_OPA_RES_TITLE | 32 | MIN_A2 result popup title, opt_a | The beam is braced
EV_MIN_A2_OPA_RES | 280 | MIN_A2 result popup, opt_a; {bot} is bot_3 | Braces went in row by row and the cut kept working for your crews. It cost credits, and Minerals volume rose for a while. {bot} had waited for the beams, and its next weather comes clearly later. The crack stopped, and the glass went on ringing.
EV_MIN_A2_OPA_STD | 90 | MIN_A2 house line 1, opt_a | {bot3}: next weather comes clearly later.
EV_MIN_A2_OPB_BTN | 28 | MIN_A2 button, opt_b | Sell the cut
EV_MIN_A2_OPB_EFF | 200 | MIN_A2 effect line, opt_b | Get: {cash_in} credits now. Cost: Minerals volume down a little for a few cycles. Weather: {bot1}'s next weather lands clearly softer.
EV_MIN_A2_OPB_RES_TITLE | 32 | MIN_A2 result popup title, opt_b | The cut is sold
EV_MIN_A2_OPB_RES | 280 | MIN_A2 result popup, opt_b; {bot} is bot_1 | A buyer took the cut with the crack in it and paid on the day. Your crews moved to other work, so Minerals volume dipped for a few cycles. {bot} had bid on the same cut, and its next weather lands clearly softer. The buyer looked at the crack. Briefly.
EV_MIN_A2_OPB_STD | 90 | MIN_A2 house line 1, opt_b | {bot1}: next weather lands clearly softer.

### MIN_A3 (Minerals, chain A, step 3)
EV_MIN_A3_TITLE | 40 | MIN_A3 choice screen title | A house pilot sells a route
EV_MIN_A3_BODY_A | 280 | MIN_A3 choice screen body after opt_a of MIN_A2 | The beam at Greywake is braced. A pilot of {bot3}'s fleet, owed wages, offers his chart of a route to an unclaimed ore cluster. {bot1} runs the same lane in force. Buy the chart, or add extra hulls to the lane.
EV_MIN_A3_BODY_B | 280 | MIN_A3 choice screen body after opt_b of MIN_A2 | The cut at Greywake is sold. A pilot of {bot3}'s fleet, owed wages, offers his chart of a route to an unclaimed ore cluster. {bot1} runs the same lane in force. Buy the chart, or add extra hulls to the lane.
EV_MIN_A3_OPA_BTN | 28 | MIN_A3 button, opt_a | Buy the chart
EV_MIN_A3_OPA_EFF | 200 | MIN_A3 effect line, opt_a | Get: one route's trip cost falls a little for a while. Cost: {cash_out} credits for the chart; {bot3}'s next weather lands a little harder. Weather: {bot1}'s next weather lands a little softer.
EV_MIN_A3_OPA_RES_TITLE | 32 | MIN_A3 result popup title, opt_a | The chart is bought
EV_MIN_A3_OPA_RES | 280 | MIN_A3 result popup, opt_a; {bot} is bot_1 | You bought the chart and ran one route by it. Trip cost fell a little for a while, and the chart cost credits. The pilot sold the same chart to his own fleet, so {bot3}'s weather lands a little harder. {bot} lost its lead on the lane, and its next weather lands a little softer.
EV_MIN_A3_OPA_STD | 90 | MIN_A3 house line 1, opt_a | {bot1}: next weather lands a little softer.
EV_MIN_A3_OPA_STD2 | 90 | MIN_A3 house line 2, opt_a | {bot3}: next weather lands a little harder.
EV_MIN_A3_OPB_BTN | 28 | MIN_A3 button, opt_b | Add extra hulls
EV_MIN_A3_OPB_EFF | 200 | MIN_A3 effect line, opt_b | Get: Minerals volume up clearly for a while. Cost: {cash_out} credits and Ship upkeep up a little for a while. Weather: {bot1} {cut}.
EV_MIN_A3_OPB_RES_TITLE | 32 | MIN_A3 result popup title, opt_b | Extra hulls on the lane
EV_MIN_A3_OPB_RES | 280 | MIN_A3 result popup, opt_b; {bot} is bot_1 | You sent extra hulls down the lane and the crews cut harder for a while. The hulls cost credits and raise Ship upkeep a little for a while. {bot} has its next weather held back, its lane crews pushed to the edge of the chart. The wakes behind your hulls crossed and recrossed.
EV_MIN_A3_OPB_STD | 90 | MIN_A3 house line 1, opt_b | {bot1}: {cut_std}.

### MIN_B1 (Minerals, chain B, step 1)
EV_MIN_B1_TITLE | 40 | MIN_B1 choice screen title | Two claims on one seam
EV_MIN_B1_BODY | 280 | MIN_B1 choice screen body (one body) | Your crew and a crew of {bot1} filed a claim on the same seam in the same hour, and the Bureau stamped both. Arbiter Judi Drell asks for a sale or a survey and says she is the law only until lunch. Sell your claim, or pay for a survey that proves the cut.
EV_MIN_B1_OPA_BTN | 28 | MIN_B1 button, opt_a | Sell your claim
EV_MIN_B1_OPA_EFF | 200 | MIN_B1 effect line, opt_a | Get: {cash_in} credits now. Cost: Minerals volume down a little for a while. Weather: {bot1}'s next weather comes a little later.
EV_MIN_B1_OPA_RES_TITLE | 32 | MIN_B1 result popup title, opt_a | Your claim is sold
EV_MIN_B1_OPA_RES | 280 | MIN_B1 result popup, opt_a; {bot} is bot_1 | The arbiter's buyer took your claim and paid on the spot. Your crews moved to other cuts, so Minerals volume dipped for a while. {bot} kept the seam, and its next weather comes a little later as the buyer set terms. The stamp on your copy was still wet.
EV_MIN_B1_OPA_STD | 90 | MIN_B1 house line 1, opt_a | {bot1}: next weather comes a little later.
EV_MIN_B1_OPB_BTN | 28 | MIN_B1 button, opt_b | Pay for a survey
EV_MIN_B1_OPB_EFF | 200 | MIN_B1 effect line, opt_b | Get: {n} units of tech progress at the Smelter. Cost: {cash_out} credits for the survey. Weather: {bot1}'s next weather lands clearly softer.
EV_MIN_B1_OPB_RES_TITLE | 32 | MIN_B1 result popup title, opt_b | The survey proves the cut
EV_MIN_B1_OPB_RES | 280 | MIN_B1 result popup, opt_b; {bot} is bot_1 | The survey cut a test core through the seam and your smelter ran it. Tech progress came in, and the survey was paid. {bot}'s claim failed the core, and its next weather lands clearly softer. The core was warm and had a thread of glass in it.
EV_MIN_B1_OPB_STD | 90 | MIN_B1 house line 1, opt_b | {bot1}: next weather lands clearly softer.

### MIN_B2 (Minerals, chain B, step 2)
EV_MIN_B2_TITLE | 40 | MIN_B2 choice screen title | The smelter crew downs tools
EV_MIN_B2_BODY_A | 280 | MIN_B2 choice screen body after opt_a of MIN_B1 | You sold your claim, and now the crew at your smelter, led by Norma Ray, has stopped work and wants new terms. {bot3} has offered the crew a place. Hold the terms and let the furnace cool, or pay for a double shift to keep it lit.
EV_MIN_B2_BODY_B | 280 | MIN_B2 choice screen body after opt_b of MIN_B1 | You paid for the survey, and now the crew at your smelter, led by Norma Ray, has stopped work and wants new terms. {bot3} has offered the crew a place. Hold the terms and let the furnace cool, or pay for a double shift to keep it lit.
EV_MIN_B2_OPA_BTN | 28 | MIN_B2 button, opt_a | Hold the terms
EV_MIN_B2_OPA_EFF | 200 | MIN_B2 effect line, opt_a | Get: Minerals price up a little for a while. Cost: the Smelter stands idle for a few cycles. Weather: {bot3}'s next weather comes a little later.
EV_MIN_B2_OPA_RES_TITLE | 32 | MIN_B2 result popup title, opt_a | The terms hold
EV_MIN_B2_OPA_RES | 280 | MIN_B2 result popup, opt_a; {bot} is bot_3 | You held the terms and the crew left the furnace to cool. Ingots grew scarce, so Minerals prices rose a little for a while, and the Smelter stood idle for a few cycles. {bot} had offered the crew a place, and its next weather comes a little later. The slag ticked as it shrank.
EV_MIN_B2_OPA_STD | 90 | MIN_B2 house line 1, opt_a | {bot3}: next weather comes a little later.
EV_MIN_B2_OPB_BTN | 28 | MIN_B2 button, opt_b | Pay a double shift
EV_MIN_B2_OPB_EFF | 200 | MIN_B2 effect line, opt_b | Get: one more batch a cycle at the Smelter for a while. Cost: {cash_out} credits in shift pay. Weather: {bot1}'s next weather lands a little softer.
EV_MIN_B2_OPB_RES_TITLE | 32 | MIN_B2 result popup title, opt_b | A double shift runs
EV_MIN_B2_OPB_RES | 280 | MIN_B2 result popup, opt_b; {bot} is bot_1 | You paid for a double shift and the furnace stayed lit. The Smelter makes one more batch a cycle for a while, and the pay cost credits. {bot} counted on a cooled furnace, and its next weather lands a little softer. The night crew did not look at the day crew.
EV_MIN_B2_OPB_STD | 90 | MIN_B2 house line 1, opt_b | {bot1}: next weather lands a little softer.

### MIN_B3 (Minerals, chain B, step 3)
EV_MIN_B3_TITLE | 40 | MIN_B3 choice screen title | A bidder prices your stock
EV_MIN_B3_BODY_A | 280 | MIN_B3 choice screen body after opt_a of MIN_B2 | You held the terms at the smelter. Bidder Gordo Gekk, who says wanting more is only tidiness, offers a price for all your ingot in storage, hauled today. {bot1} is his usual supplier, and {bot3} has asked for the leftovers. Sell the whole stock, or take a standing buyer.
EV_MIN_B3_BODY_B | 280 | MIN_B3 choice screen body after opt_b of MIN_B2 | You paid for a double shift at the smelter. Bidder Gordo Gekk, who says wanting more is only tidiness, offers a price for all your ingot in storage, hauled today. {bot1} is his usual supplier, and {bot3} has asked for the leftovers. Sell the whole stock, or take a standing buyer.
EV_MIN_B3_OPA_BTN | 28 | MIN_B3 button, opt_a | Sell the whole stock
EV_MIN_B3_OPA_EFF | 200 | MIN_B3 effect line, opt_a | Get: {cash_in} credits now. Cost: Minerals volume down clearly for a few cycles. Weather: {bot1}'s next weather lands sharply softer; {bot3}'s lands a little softer.
EV_MIN_B3_OPA_RES_TITLE | 32 | MIN_B3 result popup title, opt_a | The stock is sold
EV_MIN_B3_OPA_RES | 280 | MIN_B3 result popup, opt_a; {bot} is bot_1 | Gekk hauled the whole stock away and paid on the dock. Your storage stood empty, and Minerals volume fell clearly for a few cycles. {bot}'s usual contract went with it, so its next weather lands sharply softer, and {bot3}'s lands a little softer. The racks rang as they emptied.
EV_MIN_B3_OPA_STD | 90 | MIN_B3 house line 1, opt_a | {bot1}: next weather lands sharply softer.
EV_MIN_B3_OPA_STD2 | 90 | MIN_B3 house line 2, opt_a | {bot3}: next weather lands a little softer.
EV_MIN_B3_OPB_BTN | 28 | MIN_B3 button, opt_b | Take a standing buyer
EV_MIN_B3_OPB_EFF | 200 | MIN_B3 effect line, opt_b | Get: Minerals volume up a little for a while. Cost: {cash_out} credits to the buyer's broker. Weather: {bot1}'s next weather lands clearly softer.
EV_MIN_B3_OPB_RES_TITLE | 32 | MIN_B3 result popup title, opt_b | A standing buyer signs
EV_MIN_B3_OPB_RES | 280 | MIN_B3 result popup, opt_b; {bot} is bot_1 | The standing buyer signed and sends a ship each cycle. Minerals volume rose for a while, and the buyer's broker was paid in credits. {bot} lost the buyer's custom, and its next weather lands clearly softer. The buyer's ship has no name on its hull.
EV_MIN_B3_OPB_STD | 90 | MIN_B3 house line 1, opt_b | {bot1}: next weather lands clearly softer.

### MIN_B4 (Minerals, chain B, step 4)
EV_MIN_B4_TITLE | 40 | MIN_B4 choice screen title | A new deposit is in range
EV_MIN_B4_BODY_A | 280 | MIN_B4 choice screen body after opt_a of MIN_B3 | You sold your whole ingot stock. Now a survey lists another deposit within reach of your ships, and {bot1} has already sent a charter crew. File the claim and pay the survey office, or lease the claim to a crew on terms.
EV_MIN_B4_BODY_B | 280 | MIN_B4 choice screen body after opt_b of MIN_B3 | You took a standing buyer. Now a survey lists another deposit within reach of your ships, and {bot1} has already sent a charter crew. File the claim and pay the survey office, or lease the claim to a crew on terms.
EV_MIN_B4_OPA_BTN | 28 | MIN_B4 button, opt_a | File the claim
EV_MIN_B4_OPA_EFF | 200 | MIN_B4 effect line, opt_a | Get: Minerals price up a little for a while. Cost: {cash_out} credits to the survey office for the filing. Weather: {bot1}'s next weather lands sharply softer.
EV_MIN_B4_OPA_RES_TITLE | 32 | MIN_B4 result popup title, opt_a | The claim is filed
EV_MIN_B4_OPA_RES | 280 | MIN_B4 result popup, opt_a; {bot} is bot_1 | You filed the claim and the office stamped it. The filing cost credits, and Minerals prices rose a little for a while as your ore came to market. {bot}'s charter crew found your marker at the site, and its weather lands sharply softer. The deposit lay under the rock, unmoved.
EV_MIN_B4_OPA_STD | 90 | MIN_B4 house line 1, opt_a | {bot1}: next weather lands sharply softer.
EV_MIN_B4_OPB_BTN | 28 | MIN_B4 button, opt_b | Lease the claim
EV_MIN_B4_OPB_EFF | 200 | MIN_B4 effect line, opt_b | Get: {cash_in} credits; Minerals volume up a little for the rest of the run. Cost: Ship upkeep up a little for a while. Weather: {bot1}'s next weather lands clearly softer; {bot3}'s a little softer.
EV_MIN_B4_OPB_RES_TITLE | 32 | MIN_B4 result popup title, opt_b | The claim is leased
EV_MIN_B4_OPB_RES | 280 | MIN_B4 result popup, opt_b; {bot} is bot_1 | You leased the claim to a crew and the first payment arrived. Your ships carry its ore, so Minerals volume rose, and Ship upkeep rises a little for a while. {bot}'s weather lands clearly softer, and {bot3}'s a little softer: both lost the lease. It has a clause about weather.
EV_MIN_B4_OPB_STD | 90 | MIN_B4 house line 1, opt_b | {bot1}: next weather lands clearly softer.
EV_MIN_B4_OPB_STD2 | 90 | MIN_B4 house line 2, opt_b | {bot3}: next weather lands a little softer.

### MIN_C1 (Minerals, chain C, step 1; added 2026-11-11)
EV_MIN_C1_TITLE | 40 | MIN_C1 choice screen title | Deepline Works wants a second shaft
EV_MIN_C1_BODY | 280 | MIN_C1 choice screen body (one body) | The Deepline Works wants a second shaft sunk beside your claim at Cindrel, and needs a pump that only you can feed. {bot1} offers its own pump on lease, and {bot3} has asked for the spoil. Share your pump, or sell the Works the pump.
EV_MIN_C1_OPA_BTN | 28 | MIN_C1 button, opt_a | Share the pump
EV_MIN_C1_OPA_EFF | 200 | MIN_C1 effect line, opt_a | Get: Minerals volume up a little for a while. Cost: Minerals price down a little for a while. Weather: {bot1}'s next weather comes a little later.
EV_MIN_C1_OPA_RES_TITLE | 32 | MIN_C1 result popup title, opt_a | Two shafts, one pump
EV_MIN_C1_OPA_RES | 280 | MIN_C1 result popup, opt_a; {bot} is bot_1 | You shared the pump, and the Works sank its shaft beside yours. Minerals volume rises a little for a while, and more rock on the market pulls price down a little. {bot} had offered its own pump on lease, and its next weather comes a little later.
EV_MIN_C1_OPA_STD | 90 | MIN_C1 house line 1, opt_a | {bot1}: next weather comes a little later.
EV_MIN_C1_OPB_BTN | 28 | MIN_C1 button, opt_b | Sell the pump
EV_MIN_C1_OPB_EFF | 200 | MIN_C1 effect line, opt_b | Get: {cash_in} credits now. Cost: Minerals volume down a little for a few cycles. Weather: {bot3}'s next weather lands a little softer.
EV_MIN_C1_OPB_RES_TITLE | 32 | MIN_C1 result popup title, opt_b | The pump changes hands
EV_MIN_C1_OPB_RES | 280 | MIN_C1 result popup, opt_b; {bot} is bot_3 | You sold the pump, and the Works paid on the dock. Your own volume dipped for a few cycles while the shaft waited for a new crew. {bot} asked for the spoil and was told it was sold, and its next weather lands a little softer.
EV_MIN_C1_OPB_STD | 90 | MIN_C1 house line 1, opt_b | {bot3}: next weather lands a little softer.

### MIN_C2 (Minerals, chain C, step 2; added 2026-11-11)
EV_MIN_C2_TITLE | 40 | MIN_C2 choice screen title | Gordo Gekk prices the hall stone
EV_MIN_C2_BODY_A | 280 | MIN_C2 choice screen body after opt_a of MIN_C1 | Bidder Gordo Gekk, who says wanting more is only tidiness, has priced every slab in the Bazaar's new halls and wants yours. You shared your pump, so he calls you a friend. Fix one price for the run, or weigh each load as it comes. {bot1} supplies the rest.
EV_MIN_C2_BODY_B | 280 | MIN_C2 choice screen body after opt_b of MIN_C1 | Bidder Gordo Gekk, who says wanting more is only tidiness, has priced every slab in the Bazaar's new halls and wants yours. You sold your pump, so he calls you a seller. Fix one price for the run, or weigh each load as it comes. {bot1} supplies the rest.
EV_MIN_C2_OPA_BTN | 28 | MIN_C2 button, opt_a | Fix the slab price
EV_MIN_C2_OPA_EFF | 200 | MIN_C2 effect line, opt_a | Get: Minerals price up a little for a while. Cost: {cash_out} credits for the weighing seals. Weather: {bot1}'s next weather lands a little softer.
EV_MIN_C2_OPA_RES_TITLE | 32 | MIN_C2 result popup title, opt_a | One price, tied with a bow
EV_MIN_C2_OPA_RES | 280 | MIN_C2 result popup, opt_a; {bot} is bot_1 | You fixed one price for every slab, and Gekk sealed it with a tidy bow. The weighing seals cost credits, and Minerals price rises a little for a while. {bot} supplies the rest of the halls, and its next weather lands a little softer.
EV_MIN_C2_OPA_STD | 90 | MIN_C2 house line 1, opt_a | {bot1}: next weather lands a little softer.
EV_MIN_C2_OPB_BTN | 28 | MIN_C2 button, opt_b | Weigh each load
EV_MIN_C2_OPB_EFF | 200 | MIN_C2 effect line, opt_b | Get: one route's trip cost down a little for a while. Cost: Minerals volume down a little for a while. Weather: {bot3}'s next weather comes a little later.
EV_MIN_C2_OPB_RES_TITLE | 32 | MIN_C2 result popup title, opt_b | Every load on the scale
EV_MIN_C2_OPB_RES | 280 | MIN_C2 result popup, opt_b; {bot} is bot_3 | You weighed each load as it came, and Gekk wrote down every figure and sighed at none. The busiest route's trip cost falls a little for a while, and Minerals volume dips as loads wait for the scale. {bot}'s next weather comes a little later.
EV_MIN_C2_OPB_STD | 90 | MIN_C2 house line 1, opt_b | {bot3}: next weather comes a little later.

### MIN_C3 (Minerals, chain C, step 3; added 2026-11-11)
EV_MIN_C3_TITLE | 40 | MIN_C3 choice screen title | Tamsk Reddock offers the last rail
EV_MIN_C3_BODY_A | 280 | MIN_C3 choice screen body after opt_a of MIN_C2 | The Great Hall wants rail for its roof. Tamsk Reddock, who runs the slag yard, offers you the whole of the last rail, and says heavy, as he does of everything. {bot1} wants the rest, and {bot3} wants the leftovers. Take the whole rail, or a share of it.
EV_MIN_C3_BODY_B | 280 | MIN_C3 choice screen body after opt_b of MIN_C2 | The Great Hall wants rail for its roof. Tamsk Reddock, who runs the slag yard, saw your figures on the scale and offers you the whole of the last rail. He says heavy. {bot1} wants the rest, and {bot3} wants the leftovers. Take the whole rail, or a share of it.
EV_MIN_C3_OPA_BTN | 28 | MIN_C3 button, opt_a | Take the whole rail
EV_MIN_C3_OPA_EFF | 200 | MIN_C3 effect line, opt_a | Get: Minerals volume up clearly for a while. Cost: Ship upkeep rises a little for a while. Weather: {bot1}'s next weather lands clearly softer.
EV_MIN_C3_OPA_RES_TITLE | 32 | MIN_C3 result popup title, opt_a | The whole rail
EV_MIN_C3_OPA_RES | 280 | MIN_C3 result popup, opt_a; {bot} is bot_1 | You took the whole last rail, and Reddock said heavy and meant it. Minerals volume rises clearly for a while, and the rail yard raises Ship upkeep a little. {bot} wanted the rest, and its next weather lands clearly softer.
EV_MIN_C3_OPA_STD | 90 | MIN_C3 house line 1, opt_a | {bot1}: next weather lands clearly softer.
EV_MIN_C3_OPB_BTN | 28 | MIN_C3 button, opt_b | Take a share of it
EV_MIN_C3_OPB_EFF | 200 | MIN_C3 effect line, opt_b | Get: {cash_in} credits now. Cost: Minerals volume down a little for a while. Weather: {bot3}'s next weather comes clearly later.
EV_MIN_C3_OPB_RES_TITLE | 32 | MIN_C3 result popup title, opt_b | A share of the rail
EV_MIN_C3_OPB_RES | 280 | MIN_C3 result popup, opt_b; {bot} is bot_3 | You took a share of the rail and the rest went to the yard. Credits came in at the dock, and Minerals volume dips for a while. {bot} wanted the leftovers and got them, and its next weather comes clearly later.
EV_MIN_C3_OPB_STD | 90 | MIN_C3 house line 1, opt_b | {bot3}: next weather comes clearly later.

### BIO_A1 (Biotech, chain A, step 1)
EV_BIO_A1_TITLE | 40 | BIO_A1 choice screen title | A canister arrives unlabelled
EV_BIO_A1_BODY | 280 | BIO_A1 choice screen body (one body) | A sealed canister reached your depot on Tillam from no named source. It is cold and damp, and the lid is warm. The label says: keep sealed, do not feed after dark. Director Hesk says the sample is fine. {bot2} asks to buy it unseen. Study it at your lab, or sell it as it came.
EV_BIO_A1_OPA_BTN | 28 | BIO_A1 button, opt_a | Study the sample
EV_BIO_A1_OPA_EFF | 200 | BIO_A1 effect line, opt_a | Get: {n} units of tech progress at the Culture Lab. Cost: {cash_out} credits for the tests. Weather: {bot2}'s next weather comes a little later.
EV_BIO_A1_OPA_RES_TITLE | 32 | BIO_A1 result popup title, opt_a | The sample is studied
EV_BIO_A1_OPA_RES | 280 | BIO_A1 result popup, opt_a; {bot} is bot_2 | The lab worked behind two doors and logged every reading after dark. Tech progress came in, and the tests cost credits. {bot} had asked to buy the sample unseen, and its next weather comes a little later. Fitter Imre Fenn checked both doors twice. The vat took on a faint green.
EV_BIO_A1_OPA_STD | 90 | BIO_A1 house line 1, opt_a | {bot2}: next weather comes a little later.
EV_BIO_A1_OPB_BTN | 28 | BIO_A1 button, opt_b | Sell the sample
EV_BIO_A1_OPB_EFF | 200 | BIO_A1 effect line, opt_b | Get: {cash_in} credits now. Cost: Biotech price down a little for a few cycles. Weather: {bot2}'s next weather lands a little softer.
EV_BIO_A1_OPB_RES_TITLE | 32 | BIO_A1 result popup title, opt_b | The sample is sold
EV_BIO_A1_OPB_RES | 280 | BIO_A1 result popup, opt_b; {bot} is bot_2 | A broker took the canister the same day and paid cash. Buyers read the odd colour on the lid as a warning, so Biotech prices dip a little for a few cycles. {bot} was passed over, and its weather lands a little softer. Fenn asked where it went. The sample is fine, he was told.
EV_BIO_A1_OPB_STD | 90 | BIO_A1 house line 1, opt_b | {bot2}: next weather lands a little softer.

### BIO_A2 (Biotech, chain A, step 2)
EV_BIO_A2_TITLE | 40 | BIO_A2 choice screen title | A clinic asks to test a batch
EV_BIO_A2_BODY_A | 280 | BIO_A2 choice screen body after opt_a of BIO_A1 | Your lab studied the sample. Now Doctor Marrow of the clinic ring asks to draw a batch from your stock for testing on her ward, where volunteers are volunteers by rota. {bot2} supplies the other wards, and {bot3} wants the data. Fund the clinic's tests, or run them at your lab.
EV_BIO_A2_BODY_B | 280 | BIO_A2 choice screen body after opt_b of BIO_A1 | You sold the sample. Now Doctor Marrow of the clinic ring asks to draw a batch from your stock for testing on her ward, where volunteers are volunteers by rota. {bot2} supplies the other wards, and {bot3} wants the data. Fund the clinic's tests, or run them at your lab.
EV_BIO_A2_OPA_BTN | 28 | BIO_A2 button, opt_a | Fund the clinic's tests
EV_BIO_A2_OPA_EFF | 200 | BIO_A2 effect line, opt_a | Get: Biotech volume up a little for the rest of the run. Cost: {cash_out} credits toward the tests. Weather: {bot3}'s next weather comes a little later.
EV_BIO_A2_OPA_RES_TITLE | 32 | BIO_A2 result popup title, opt_a | The clinic runs the tests
EV_BIO_A2_OPA_RES | 280 | BIO_A2 result popup, opt_a; {bot} is bot_3 | The clinic ran the tests behind its own doors. Your funding cost credits, and the clinic keeps ordering, so Biotech volume rises for the rest of the run. {bot} wanted the data and got a summary, so its weather comes a little later. The report came in triplicate, every copy damp.
EV_BIO_A2_OPA_STD | 90 | BIO_A2 house line 1, opt_a | {bot3}: next weather comes a little later.
EV_BIO_A2_OPB_BTN | 28 | BIO_A2 button, opt_b | Run the tests at your lab
EV_BIO_A2_OPB_EFF | 200 | BIO_A2 effect line, opt_b | Get: {n} units of tech progress at the Culture Lab. Cost: Biotech volume down a little for a while. Weather: {bot2} {cut}.
EV_BIO_A2_OPB_RES_TITLE | 32 | BIO_A2 result popup title, opt_b | The tests run at your lab
EV_BIO_A2_OPB_RES | 280 | BIO_A2 result popup, opt_b; {bot} is bot_2 | Your lab ran the tests on the held batch, and the vats gave tech progress. The batch left the shelves, so Biotech volume dips for a while. {bot} has its next weather held back as the clinic's wards moved to your results. Fenn walked the vat row each shift and wrote nothing down.
EV_BIO_A2_OPB_STD | 90 | BIO_A2 house line 1, opt_b | {bot2}: {cut_std}.

### BIO_A3 (Biotech, chain A, step 3)
EV_BIO_A3_TITLE | 40 | BIO_A3 choice screen title | A seal begins to weep
EV_BIO_A3_BODY_A | 280 | BIO_A3 choice screen body after opt_a of BIO_A2 | The clinic ran your tests. A vat seal at an Ashgate dock lab weeps. Director Hesk says the sample is fine. Fenn says the drop was clear at dawn and green by noon. {bot2} sources strains there, and {bot3} would buy the stock. Pause your lab for a check, or sell the stock.
EV_BIO_A3_BODY_B | 280 | BIO_A3 choice screen body after opt_b of BIO_A2 | Your lab ran the tests. A vat seal at an Ashgate dock lab weeps. Director Hesk says the sample is fine. Fenn says the drop was clear at dawn and green by noon. {bot2} sources strains there, and {bot3} would buy the stock. Pause your lab for a check, or sell the stock.
EV_BIO_A3_OPA_BTN | 28 | BIO_A3 button, opt_a | Pause the lab for a check
EV_BIO_A3_OPA_EFF | 200 | BIO_A3 effect line, opt_a | Get: Biotech price up a little for a while. Cost: the Culture Lab stands idle for a few cycles. Weather: {bot2}'s next weather lands a little softer.
EV_BIO_A3_OPA_RES_TITLE | 32 | BIO_A3 result popup title, opt_a | The lab is paused
EV_BIO_A3_OPA_RES | 280 | BIO_A3 result popup, opt_a; {bot} is bot_2 | You paused your lab and had every seal checked. Stock grew scarce, so Biotech prices rise a little for a while, and the lab stands idle for a few cycles. {bot}'s strains came from the weeping vat, and its weather lands a little softer. Fenn taped a note to the seal: told you.
EV_BIO_A3_OPA_STD | 90 | BIO_A3 house line 1, opt_a | {bot2}: next weather lands a little softer.
EV_BIO_A3_OPB_BTN | 28 | BIO_A3 button, opt_b | Sell the stock in that line
EV_BIO_A3_OPB_EFF | 200 | BIO_A3 effect line, opt_b | Get: {cash_in} credits now. Cost: Biotech volume down a little for a few cycles; {bot3}'s next weather lands a little harder. Weather: {bot2}'s next weather lands clearly softer.
EV_BIO_A3_OPB_RES_TITLE | 32 | BIO_A3 result popup title, opt_b | The stock is sold
EV_BIO_A3_OPB_RES | 280 | BIO_A3 result popup, opt_b; {bot} is bot_2 | You sold the stock in that line and cash arrived. The shelves stood bare for a few cycles, so Biotech volume dips. {bot3} bought the surplus, so its weather lands a little harder, while {bot}'s lands clearly softer: its supply line came under notice. The vat moved at night.
EV_BIO_A3_OPB_STD | 90 | BIO_A3 house line 1, opt_b | {bot2}: next weather lands clearly softer.
EV_BIO_A3_OPB_STD2 | 90 | BIO_A3 house line 2, opt_b | {bot3}: next weather lands a little harder.

### BIO_B1 (Biotech, chain B, step 1)
EV_BIO_B1_TITLE | 40 | BIO_B1 choice screen title | A hospital needs a rare strain
EV_BIO_B1_BODY | 280 | BIO_B1 choice screen body (one body) | A hospital ring on Tillam needs a rare strain by cycle's end, and the cold chain is tight: warm crates mean lost cargo. {bot2} holds the stock, and {bot3} offers to carry it. The grower's manager says it is fine. Buy the stock, or culture it at your lab and send extra hulls.
EV_BIO_B1_OPA_BTN | 28 | BIO_B1 button, opt_a | Buy the grower's stock
EV_BIO_B1_OPA_EFF | 200 | BIO_B1 effect line, opt_a | Get: Biotech volume up clearly for a while. Cost: {cash_out} credits for the grower's stock. Weather: {bot2}'s next weather lands clearly softer.
EV_BIO_B1_OPA_RES_TITLE | 32 | BIO_B1 result popup title, opt_a | The stock is bought
EV_BIO_B1_OPA_RES | 280 | BIO_B1 result popup, opt_a; {bot} is bot_2 | You bought the grower's stock and shipped it as it was. It cost credits, and the hospital's order keeps your Biotech volume up for a while. {bot} held the only other stock, and its next weather lands clearly softer. One crate was warm at the dock. The manager said it was fine.
EV_BIO_B1_OPA_STD | 90 | BIO_B1 house line 1, opt_a | {bot2}: next weather lands clearly softer.
EV_BIO_B1_OPB_BTN | 28 | BIO_B1 button, opt_b | Culture it at your lab
EV_BIO_B1_OPB_EFF | 200 | BIO_B1 effect line, opt_b | Get: {n} units of tech progress at the Culture Lab. Cost: Ship upkeep rises a little for a while. Weather: {bot3}'s next weather lands a little softer.
EV_BIO_B1_OPB_RES_TITLE | 32 | BIO_B1 result popup title, opt_b | The lab cultures the strain
EV_BIO_B1_OPB_RES | 280 | BIO_B1 result popup, opt_b; {bot} is bot_3 | Your lab grew the strain from a culture and the extra hulls carried it. Tech progress came in, and Ship upkeep rises a little for a while. {bot} offered to carry the order and was passed over, so its next weather lands a little softer. The strain came up a green nobody ordered.
EV_BIO_B1_OPB_STD | 90 | BIO_B1 house line 1, opt_b | {bot3}: next weather lands a little softer.

### BIO_B2 (Biotech, chain B, step 2)
EV_BIO_B2_TITLE | 40 | BIO_B2 choice screen title | A strain changes in storage
EV_BIO_B2_BODY_A | 280 | BIO_B2 choice screen body after opt_a of BIO_B1 | You bought the grower's stock. One strain in storage has darkened, grows faster, and answers to the name on its crate. Cold-chain hand Ottoline Ryke says the lid was moved. {bot2} wants a sample, and {bot3} asks what it is worth. Relabel the batch, or sell it as a new line.
EV_BIO_B2_BODY_B | 280 | BIO_B2 choice screen body after opt_b of BIO_B1 | You cultured the strain at your lab. One strain in storage has darkened, grows faster, and answers to the name on its crate. Cold-chain hand Ottoline Ryke says the lid was moved. {bot2} wants a sample, and {bot3} asks what it is worth. Relabel the batch, or sell it as a new line.
EV_BIO_B2_OPA_BTN | 28 | BIO_B2 button, opt_a | Relabel the batch
EV_BIO_B2_OPA_EFF | 200 | BIO_B2 effect line, opt_a | Get: Biotech price up a little for a while. Cost: Biotech volume down a little for a while. Weather: {bot2}'s next weather comes clearly later.
EV_BIO_B2_OPA_RES_TITLE | 32 | BIO_B2 result popup title, opt_a | The batch is relabelled
EV_BIO_B2_OPA_RES | 280 | BIO_B2 result popup, opt_a; {bot} is bot_2 | You relabelled the batch and held it for study. The new line fetches a little more for a while, and your own volume dips a little as stock stays back. {bot}'s sample requests were refused, so its weather comes clearly later. The storage manager moved his desk out of the room.
EV_BIO_B2_OPA_STD | 90 | BIO_B2 house line 1, opt_a | {bot2}: next weather comes clearly later.
EV_BIO_B2_OPB_BTN | 28 | BIO_B2 button, opt_b | Sell it as a new line
EV_BIO_B2_OPB_EFF | 200 | BIO_B2 effect line, opt_b | Get: {cash_in} credits now. Cost: Ship upkeep rises a little for a while; {bot2}'s next weather lands a little harder. Weather: {bot3} {cut}.
EV_BIO_B2_OPB_RES_TITLE | 32 | BIO_B2 result popup title, opt_b | Sold as a new line
EV_BIO_B2_OPB_RES | 280 | BIO_B2 result popup, opt_b; {bot} is bot_3 | You sold the batch as a new line for cash. Extra hulls raise Ship upkeep a little for a while. {bot2} bought a sample, so its weather lands a little harder, while {bot} has its weather held back, its old line undercut. The buyer asked for a second batch. Ryke asked for a lock.
EV_BIO_B2_OPB_STD | 90 | BIO_B2 house line 1, opt_b | {bot3}: {cut_std}.
EV_BIO_B2_OPB_STD2 | 90 | BIO_B2 house line 2, opt_b | {bot2}: next weather lands a little harder.

### BIO_B3 (Biotech, chain B, step 3)
EV_BIO_B3_TITLE | 40 | BIO_B3 choice screen title | An exchange offers a slot
EV_BIO_B3_BODY_A | 280 | BIO_B3 choice screen body after opt_a of BIO_B2 | You relabelled the batch. A culture exchange offers you a numbered slot for your output, with a seat at the call each cycle. Lots and porters are numbered alike. {bot2} holds the first slot, and {bot3} the second. List your output now, or buy a slot outright.
EV_BIO_B3_BODY_B | 280 | BIO_B3 choice screen body after opt_b of BIO_B2 | You sold the batch as a new line. A culture exchange offers you a numbered slot for your output, with a seat at the call each cycle. Lots and porters are numbered alike. {bot2} holds the first slot, and {bot3} the second. List your output now, or buy a slot outright.
EV_BIO_B3_OPA_BTN | 28 | BIO_B3 button, opt_a | List your output now
EV_BIO_B3_OPA_EFF | 200 | BIO_B3 effect line, opt_a | Get: {cash_in} credits now. Cost: Biotech volume down a little for a while. Weather: {bot2}'s next weather lands sharply softer; {bot3}'s comes clearly later.
EV_BIO_B3_OPA_RES_TITLE | 32 | BIO_B3 result popup title, opt_a | The output is listed
EV_BIO_B3_OPA_RES | 280 | BIO_B3 result popup, opt_a; {bot} is bot_2 | Your output went on the exchange list and the first payment cleared. Fewer lots stayed for buyers, so volume dips for a while. {bot} lost its first slot's edge, and its next weather lands sharply softer, while {bot3}'s comes clearly later. Crates and porters bear slot numbers.
EV_BIO_B3_OPA_STD | 90 | BIO_B3 house line 1, opt_a | {bot2}: next weather lands sharply softer.
EV_BIO_B3_OPA_STD2 | 90 | BIO_B3 house line 2, opt_a | {bot3}: next weather comes clearly later.
EV_BIO_B3_OPB_BTN | 28 | BIO_B3 button, opt_b | Buy a slot outright
EV_BIO_B3_OPB_EFF | 200 | BIO_B3 effect line, opt_b | Get: Biotech volume up a little for a while. Cost: {cash_out} credits for the slot. Weather: {bot2}'s next weather lands a little softer, and {bot3}'s comes a little later.
EV_BIO_B3_OPB_RES_TITLE | 32 | BIO_B3 result popup title, opt_b | A slot is bought
EV_BIO_B3_OPB_RES | 280 | BIO_B3 result popup, opt_b; {bot} is bot_2 | You bought a slot at the call and paid in credits. Your lots now sell on schedule, so Biotech volume rises for a while. {bot}'s next weather lands a little softer and {bot3}'s comes a little later, as the call split their buyers. The bell at the call is struck by hand, by number.
EV_BIO_B3_OPB_STD | 90 | BIO_B3 house line 1, opt_b | {bot2}: next weather lands a little softer.
EV_BIO_B3_OPB_STD2 | 90 | BIO_B3 house line 2, opt_b | {bot3}: next weather comes a little later.

### BIO_B4 (Biotech, chain B, step 4)
EV_BIO_B4_TITLE | 40 | BIO_B4 choice screen title | A storage firm offers cold racks
EV_BIO_B4_BODY_A | 280 | BIO_B4 choice screen body after opt_a of BIO_B3 | Your output is listed on the exchange. A storage firm offers cold racks in a derelict hull moored to the dock, resealed and renamed Aisle. {bot2} keeps its stock there, and {bot3} rents beside it. Rent racks by the cycle, or sell the firm your first claim to the aisle.
EV_BIO_B4_BODY_B | 280 | BIO_B4 choice screen body after opt_b of BIO_B3 | You hold a slot at the exchange call. A storage firm offers cold racks in a derelict hull moored to the dock, resealed and renamed Aisle. {bot2} keeps its stock there, and {bot3} rents beside it. Rent racks by the cycle, or sell the firm your first claim to the aisle.
EV_BIO_B4_OPA_BTN | 28 | BIO_B4 button, opt_a | Rent racks by the cycle
EV_BIO_B4_OPA_EFF | 200 | BIO_B4 effect line, opt_a | Get: Biotech price up a little for a while. Cost: Biotech volume down a little for a while. Weather: {bot2}'s next weather lands sharply softer.
EV_BIO_B4_OPA_RES_TITLE | 32 | BIO_B4 result popup title, opt_a | The racks are rented
EV_BIO_B4_OPA_RES | 280 | BIO_B4 result popup, opt_a; {bot} is bot_2 | You rented racks by the cycle, and your stock stayed cold in the old hull. Held stock lifts prices a little for a while, and volume dips as it waits. {bot} lost its place at the front, and its next weather lands sharply softer. The hull ticks as it cools. Ryke counts the doors.
EV_BIO_B4_OPA_STD | 90 | BIO_B4 house line 1, opt_a | {bot2}: next weather lands sharply softer.
EV_BIO_B4_OPB_BTN | 28 | BIO_B4 button, opt_b | Sell the first claim
EV_BIO_B4_OPB_EFF | 200 | BIO_B4 effect line, opt_b | Get: {cash_in} credits now. Cost: Ship upkeep rises a little for a while. Weather: {bot2}'s and {bot3}'s next weather lands clearly softer.
EV_BIO_B4_OPB_RES_TITLE | 32 | BIO_B4 result popup title, opt_b | The first claim is sold
EV_BIO_B4_OPB_RES | 280 | BIO_B4 result popup, opt_b; {bot} is bot_2 | You sold the firm your first claim to the aisle, and a large payment cleared. Your ships work new routes, so Ship upkeep rises a little for a while. {bot} and {bot3} both lost the aisle, and each sees its weather land clearly softer. One lamp lights the hull and does not flicker.
EV_BIO_B4_OPB_STD | 90 | BIO_B4 house line 1, opt_b | {bot2} and {bot3}: next weather lands clearly softer.

### BIO_C1 (Biotech, chain C, step 1; added 2026-11-11)
EV_BIO_C1_TITLE | 40 | BIO_C1 choice screen title | A chiller fails at Brannock
EV_BIO_C1_BODY | 280 | BIO_C1 choice screen body (one body) | Ottoline Ryke calls from Brannock's grain dock. A chiller has failed and the racks are warming. Director Hesk says the samples are fine. Move your stock to the cold racks across the dock, or share her spare chiller. {bot2} stores there, and {bot3} rents beside it.
EV_BIO_C1_OPA_BTN | 28 | BIO_C1 button, opt_a | Move stock to cold racks
EV_BIO_C1_OPA_EFF | 200 | BIO_C1 effect line, opt_a | Get: Biotech price up a little for a while. Cost: {cash_out} credits for the racks. Weather: {bot2}'s next weather lands a little softer.
EV_BIO_C1_OPA_RES_TITLE | 32 | BIO_C1 result popup title, opt_a | The trays cross the dock
EV_BIO_C1_OPA_RES | 280 | BIO_C1 result popup, opt_a; {bot} is bot_2 | Ryke moved your trays to the racks across the dock and the warm alarm stopped. The racks cost credits, and Biotech price rises a little for a while. {bot} stores there too, and its next weather lands a little softer. Hesk said the samples were fine.
EV_BIO_C1_OPA_STD | 90 | BIO_C1 house line 1, opt_a | {bot2}: next weather lands a little softer.
EV_BIO_C1_OPB_BTN | 28 | BIO_C1 button, opt_b | Share her spare chiller
EV_BIO_C1_OPB_EFF | 200 | BIO_C1 effect line, opt_b | Get: Biotech volume up a little for a while. Cost: Ship upkeep rises a little for a while. Weather: {bot3}'s next weather comes a little later.
EV_BIO_C1_OPB_RES_TITLE | 32 | BIO_C1 result popup title, opt_b | Two crews, one chiller
EV_BIO_C1_OPB_RES | 280 | BIO_C1 result popup, opt_b; {bot} is bot_3 | Ryke wheeled her spare chiller to your racks and the two crews shared the cold. Biotech volume rises a little for a while, and the extra crew raises Ship upkeep a little. {bot} rents beside the dock, and its next weather comes a little later.
EV_BIO_C1_OPB_STD | 90 | BIO_C1 house line 1, opt_b | {bot3}: next weather comes a little later.

### BIO_C2 (Biotech, chain C, step 2; added 2026-11-11)
EV_BIO_C2_TITLE | 40 | BIO_C2 choice screen title | Doctor Marrow volunteers again
EV_BIO_C2_BODY_A | 280 | BIO_C2 choice screen body after opt_a of BIO_C1 | Your racks held, and the Bazaar noticed. The new halls need a test rota, and Doctor Marrow, who volunteers by rota, has put his name on every line. Fund the whole rota, or count the samples yourself. {bot2} supplies strains, and {bot3} buys the stock.
EV_BIO_C2_BODY_B | 280 | BIO_C2 choice screen body after opt_b of BIO_C1 | Your shared chiller hums, and the Bazaar noticed. The new halls need a test rota, and Doctor Marrow, who volunteers by rota, has put his name on every line. Fund the whole rota, or count the samples yourself. {bot2} supplies strains, and {bot3} buys the stock.
EV_BIO_C2_OPA_BTN | 28 | BIO_C2 button, opt_a | Fund the whole rota
EV_BIO_C2_OPA_EFF | 200 | BIO_C2 effect line, opt_a | Get: one route's trip cost down a little for a while. Cost: {cash_out} credits for the rota. Weather: {bot2}'s next weather comes a little later.
EV_BIO_C2_OPA_RES_TITLE | 32 | BIO_C2 result popup title, opt_a | Marrow signs every line
EV_BIO_C2_OPA_RES | 280 | BIO_C2 result popup, opt_a; {bot} is bot_2 | You funded the rota, and Marrow signed up for every line of it. The rota cost credits, and the busiest route's trip cost falls a little for a while. {bot} supplies strains to the halls, and its next weather comes a little later.
EV_BIO_C2_OPA_STD | 90 | BIO_C2 house line 1, opt_a | {bot2}: next weather comes a little later.
EV_BIO_C2_OPB_BTN | 28 | BIO_C2 button, opt_b | Count the samples
EV_BIO_C2_OPB_EFF | 200 | BIO_C2 effect line, opt_b | Get: {cash_in} credits now. Cost: Biotech volume down a little for a while. Weather: {bot3}'s next weather lands a little softer.
EV_BIO_C2_OPB_RES_TITLE | 32 | BIO_C2 result popup title, opt_b | Counted twice
EV_BIO_C2_OPB_RES | 280 | BIO_C2 result popup, opt_b; {bot} is bot_3 | You counted the samples yourself, twice, and Marrow stood by with a pen. Credits came in at the dock, and Biotech volume dips for a while as lots wait for the count. {bot} buys the stock, and its next weather lands a little softer.
EV_BIO_C2_OPB_STD | 90 | BIO_C2 house line 1, opt_b | {bot3}: next weather lands a little softer.

### BIO_C3 (Biotech, chain C, step 3; added 2026-11-11)
EV_BIO_C3_TITLE | 40 | BIO_C3 choice screen title | Director Hesk says it is fine
EV_BIO_C3_BODY_A | 280 | BIO_C3 choice screen body after opt_a of BIO_C2 | The last hall is roofed, and Director Hesk says again that the sample is fine. Imre Fenn, who fitted the seals, asks to read each one aloud before the cold rooms are sealed. {bot2} wants the rooms filled today, and {bot3} wants them listed.
EV_BIO_C3_BODY_B | 280 | BIO_C3 choice screen body after opt_b of BIO_C2 | The last hall is roofed, and Director Hesk says again that the sample is fine. Imre Fenn, who fitted the seals, asks to read each one aloud before the cold rooms are sealed. {bot2} wants the rooms filled today, and {bot3} wants them listed. Your count is in the file.
EV_BIO_C3_OPA_BTN | 28 | BIO_C3 button, opt_a | Seal the rooms today
EV_BIO_C3_OPA_EFF | 200 | BIO_C3 effect line, opt_a | Get: Biotech price up clearly for a while. Cost: Biotech volume down a little for a while. Weather: {bot2}'s next weather lands clearly softer.
EV_BIO_C3_OPA_RES_TITLE | 32 | BIO_C3 result popup title, opt_a | The rooms are sealed
EV_BIO_C3_OPA_RES | 280 | BIO_C3 result popup, opt_a; {bot} is bot_2 | You sealed the rooms that day, and Hesk said the sample was fine, again. Biotech price rises clearly for a while, and the sealed rooms hold stock back, so volume dips a little. {bot} wanted the rooms filled, and its next weather lands clearly softer.
EV_BIO_C3_OPA_STD | 90 | BIO_C3 house line 1, opt_a | {bot2}: next weather lands clearly softer.
EV_BIO_C3_OPB_BTN | 28 | BIO_C3 button, opt_b | Read the seals aloud
EV_BIO_C3_OPB_EFF | 200 | BIO_C3 effect line, opt_b | Get: Biotech volume up clearly for a while. Cost: {cash_out} credits for the extra shifts. Weather: {bot3}'s next weather comes a little later.
EV_BIO_C3_OPB_RES_TITLE | 32 | BIO_C3 result popup title, opt_b | Every seal, aloud
EV_BIO_C3_OPB_RES | 280 | BIO_C3 result popup, opt_b; {bot} is bot_3 | The crew read the seals aloud, one by one, with Fenn at the door. The extra shifts cost credits, and Biotech volume rises clearly for a while. {bot} wanted the rooms listed, and its next weather comes a little later.
EV_BIO_C3_OPB_STD | 90 | BIO_C3 house line 1, opt_b | {bot3}: next weather comes a little later.

## Chain effect line template and rival log (added 2026-11-03)
CH_EFFECT_LINE | 200 | Effect line template for any option the game builds itself (the id game/chains.gd reads); {get}, {cost} and {rivals} are phrases without a final full stop | Get: {get}. Cost: {cost}. Weather: {rivals}.
CH_CUT | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | is held back
CH_CUT_LOW | 32 | Chain fill-in: used inside event sentences (see game/chains.gd) | gets clearly softer weather
CH_CUT_STD | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | next weather held back
CH_CUT_STD_LOW | 32 | Chain fill-in: used inside event sentences (see game/chains.gd) | next weather clearly softer
CH_SIZE_S | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | a little
CH_SIZE_M | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | clearly
CH_SIZE_L | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | sharply
CH_RIVALS_LABEL | 24 | Chain fill-in: used inside event sentences (see game/chains.gd) | Weather:
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
EV_EFF_NO_RIVALS | 90 | Effect line, Weather part of an event that changes no house weather | Weather: no house changes its next weather.

## Rival changes: Competitors menu event log (added 2026-11-03)
LBL_COMP_MOVE_STR_DOWN | 60 | House weather log line, a house sends softer weather; also used for a held-back cut at the lowest step | {bot}: next weather lands softer
LBL_COMP_MOVE_STR_UP | 60 | House weather log line, a house sends harder weather | {bot}: next weather lands harder
LBL_COMP_MOVE_GRO_DOWN | 60 | House weather log line, a house sends its weather later | {bot}: next weather comes later
LBL_COMP_MOVE_GRO_UP | 60 | House weather log line, a house sends its weather sooner | {bot}: next weather comes sooner
LBL_COMP_MOVE_TIER_DOWN | 60 | House weather log line, a house has its next weather held back | {bot}: next weather held back

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
HINT_PLANET_WANTS | 110 | Map hover card on a planet with a short need; {planet}, {goods} (comma list of the short goods) | {planet} wants {goods}.
HINT_PLANET_FED | 110 | Map hover card on a planet with no short need; {planet}, {tier} (its tier name) | {planet}: {tier}. Every need is met.
HINT_DEST_SOURCE | 60 | Card at the cursor while a route waits for a destination, the planet the route starts from | The route starts here. Pick another planet.

## Lane net label and no-earn flag (2026-11-04)
LBL_ROUTE_COST | 20 | Lane label on the map when no result can be projected for the lane; {n} is the signed running cost, shown after the ship count | cost {n}
LBL_ROUTE_NO_STOCK | 30 | Lane label on the map after the ship count when a running lane loads nothing this cycle because the source has no stock | nothing to load
LBL_ROUTE_NO_CASH | 40 | Lane label on the map after the ship count when a running lane cannot pay the trip fare this cycle | not enough cash for the trip
LBL_ROUTE_NO_ROOM | 40 | Lane label on the map after the ship count when a running lane has no room at the destination this cycle | no room at the destination
LBL_ROUTE_UNITS | 20 | Lane label on the map after the ship count: units the lane carries next cycle; {n} is the number (shown with '1 unit' for one) | {n} units
LBL_ROUTE_UNIT_ONE | 20 | Lane label on the map, same as LBL_ROUTE_UNITS for exactly one unit | {n} unit
LBL_ROUTE_NO_STOCK_SHARED | 60 | Lane label on the map after the ship count when a running lane loads nothing because earlier lanes or Sell orders of the same good take the source planet's stock; {planet} is the source | nothing left: {planet} stock goes to other lanes
LBL_CONN_UNITS | 20 | Planet card, Connections row of a lane: units the lane carries next cycle; {n} is the number | {n} / cycle
LBL_CONN_SHARED | 60 | Planet card, muted line under the goods grid when the lanes and orders of one good want more than the planet has; {stock} is the stock plus this cycle's Buy, {want} the units they ask | Stock {stock} / needed {want} per cycle
LBL_CONN_WHY_NO_STOCK | 110 | Planet card, Connections, muted line under a lane that carries nothing because the source storage has none; {planet} source, {good} | {planet} has no {good} in storage. Turn Buy on for {good} at {planet}, or send it there.
LBL_CONN_WHY_SHARED | 110 | Planet card, Connections, muted line under a lane that carries nothing because other lanes and Sell orders take the source stock first; {planet}, {good} | Other lanes and Sell orders take {planet}'s {good} first. Send more there or turn Buy on.
LBL_CONN_WHY_DEST_FULL | 110 | Planet card, Connections, muted line under a blocked lane whose destination storage is full with no outflow; {planet} destination, {good} | {planet}'s storage for {good} is full and nothing takes it out. Turn Sell on there.
LBL_CONN_WHY_WAITING | 110 | Planet card, Connections, muted line under a lane waiting because the destination is full but has outflow; {planet}, {good} | {planet}'s storage for {good} is full. The ship waits for room.
LBL_CONN_WHY_NO_CASH | 110 | Planet card, Connections, muted line under a lane that cannot pay its trip fare | Not enough cash for the trip. It runs again when you can pay.
LBL_CONN_WHY_CLOSED | 110 | Planet card, Connections, muted line under a lane with a closed planet at one end | A planet on this route is closed. The ship waits, or use Move ship if offered.
LBL_CONN_WHY_RAID | 110 | Planet card, Connections, muted line under a lane whose load a raid cut to nothing | A raid cut this lane's load to nothing. It recovers on its own.
LBL_CONN_WHY_CLUSTER_EMPTY | 110 | Planet card, Connections, muted line under an ore lane whose asteroid cluster is empty | The asteroid cluster is empty. Remove this route.
LBL_CONN_WHY_CLUSTER_SHARED | 110 | Planet card, Connections, muted line under an ore lane whose cycle yield another ship took | Another ship took this cycle's ore. It loads again next cycle.
LBL_CONN_WHY_NOTHING | 110 | Planet card, Connections, muted line under a lane that carries nothing for a reason not listed | Nothing can be loaded this cycle.
LBL_FC_NO_EARN | 80 | Cash forecast, warning line under Expenses; {route} is "Source > Destination (good)" | {route} earns nothing: it only moves stock to storage.

## Next cycle tooltip, sources and uses (2026-11-04)
TIP_NC_IN | 40 | Storage view, tooltip on the Next cycle line, line listing what arrives; {list} is comma separated entries | In: {list}.
TIP_NC_OUT | 40 | Storage view, tooltip on the Next cycle line, line listing what leaves; {list} is comma separated entries | Out: {list}.
TIP_NC_BUY | 46 | Next cycle tooltip, entry, a Buy order fills this stock; {planet}, {n} | Buy order at {planet} +{n}
TIP_NC_ROUTE_IN | 40 | Next cycle tooltip, entry, a route delivers; {route} is Source > Destination; {n} | {route} +{n}
TIP_NC_ROUTE_OUT | 40 | Next cycle tooltip, entry, a route takes from this stock; {route}, {n} | {route} -{n}
TIP_NC_SELL | 47 | Next cycle tooltip, entry, a Sell order takes from this stock; {planet}, {n} | Sell order at {planet} -{n}

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
TXT_CEO_MAN_01_BIO | 260 | CEO bio, Marek Voss | Marek kept ten ships flying on a shoestring and counts every bolt. He distrusts luck. He started his own company because nobody would let him order spare parts in bulk. He runs Minerals on a Tramp: one more lane beats one big hull.
TXT_CEO_MAN_02_BIO | 260 | CEO bio, Idris Kane | Idris was a broker with a famous smile and a habit of buying lunch for rivals. He reads a price board the way others read faces. He spends freely and sells hard. He sells Luxury from a Dart: quick hops, a light hold, and the buyer still smiling.
TXT_CEO_WOMAN_01_BIO | 260 | CEO bio, Sela Oru | Sela flew supply runs through the worst lanes of the rim and still came home. Bad news does not scare her, only an idle ship does. Her plans have a backup, and a backup for the backup. She runs Military on a Bulkhead. The rim taught her to fill the hold.
TXT_CEO_WOMAN_02_BIO | 260 | CEO bio, Tamsin Hale | Tamsin grew up in the docking rings of the Bazaar and knows every clerk by name. Her contracts arrive with friendly paperwork and larger quantities. She is calm, and a little proud of the old place. She trades Biotech from a Skerrit, a hull she knows.
LBL_CEO_MAN_01_PERK | 24 | CEO perk name, Marek Voss | Old Contacts
LBL_CEO_MAN_02_PERK | 24 | CEO perk name, Idris Kane | Quick Read
LBL_CEO_WOMAN_01_PERK | 24 | CEO perk name, Sela Oru | Hard Lanes
LBL_CEO_WOMAN_02_PERK | 24 | CEO perk name, Tamsin Hale | Station Born
TXT_CEO_MAN_01_PERK_DESC | 90 | CEO perk line, Marek Voss | Bad events are announced one cycle early.
TXT_CEO_MAN_02_PERK_DESC | 90 | CEO perk line, Idris Kane | In the first cycle you see price tips on your home market.
TXT_CEO_WOMAN_01_PERK_DESC | 90 | CEO perk line, Sela Oru | Your first lane carries one step more cargo.
TXT_CEO_WOMAN_02_PERK_DESC | 90 | CEO perk line, Tamsin Hale | Contract orders ask for more units, so a filled order pays more.

TXT_CEO_MAN_01_BRANCH_TAG | 40 | Pick card, one-line branch tag, Marek Voss | Minerals: rock, every bolt counted
TXT_CEO_MAN_02_BRANCH_TAG | 40 | Pick card, one-line branch tag, Idris Kane | Luxury: a price is a face to read
TXT_CEO_WOMAN_01_BRANCH_TAG | 40 | Pick card, one-line branch tag, Sela Oru | Military: supply for the rim, on time
TXT_CEO_WOMAN_02_BRANCH_TAG | 40 | Pick card, one-line branch tag, Tamsin Hale | Biotech: living goods, friendly forms

## Company screen (2026-11-05)
SETUP_NEXT | 24 | Company screen, button that starts the game | Start the game

## Pathfinder, trading posts and mining platforms (T181, 2026-11-05; PENDING until T179 is built)
Design: design/proposals/2026-11-05-ship-flight-discovery.md, recommended defaults (owner questions open): Pathfinder is separate from the fleet, only Voltara is known at the start, the first post is free, leaving a build cancels it. Interface texts stay English (ru/GLOSSARY.md); only the tutorial lines have a Russian version (story/ru/discovery.json). No text here names a planet or a good: closed worlds stay unnamed until the Pathfinder arrives.

LBL_UNKNOWN_WORLD | 24 | Map and planet panel, name of a closed living world | Unknown world
LBL_UNKNOWN_DARK_WORLD | 24 | Map and planet panel, name of a closed dead world | Unknown dark world
LBL_UNKNOWN_WORLD_LINE | 110 | Planet panel of a closed living world, one flavour line, no goods list | Something lives here. Fly closer to learn what it trades.
LBL_UNKNOWN_DARK_LINE | 110 | Planet panel of a closed dead world, one flavour line, no goods list | A dark world. Fly closer to see what is left.
BTN_FLY_HERE | 24 | Planet panel, button that sends the Pathfinder to this world | Explore
LBL_FLIGHT_TIME | 60 | Planet panel of a closed world, flight time from the Pathfinder; {cycles} is a number | Flight time: {cycles} cycles
LBL_PATHFINDER_NAME | 24 | Ship panel and map tooltip, name of the scout | Pathfinder
LBL_PATHFINDER_DESC | 110 | Ship panel, scout line | A scout. It carries no cargo and costs no upkeep. It flies to new worlds and builds posts.
LBL_PATHFINDER_FLYING | 60 | Top bar or ship panel, while flying to a known planet; {planet} is a name | Pathfinder flying to {planet}
LBL_PATHFINDER_FLYING_UNKNOWN | 60 | Same, while flying to a closed world | Pathfinder flying to an unknown world
LBL_PATHFINDER_IDLE | 60 | Ship panel, not flying and not building | Pathfinder waiting
LBL_HERO_STATE_IDLE | 24 | Ships menu hero card, state line, ship waiting | Idle
LBL_HERO_STATE_FLYING | 24 | Ships menu hero card, state line, ship flying | Flying
LBL_HERO_STATE_BUILDING | 24 | Ships menu hero card, state line, ship building a post | Building
LBL_HERO_HINT | 60 | Ships menu hero card, tooltip: click selects the ship, then click the map to send it | Click to select. Then click the map to fly.
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
LBL_FLAGSHIP_TITLE | 24 | Flagship details panel, title | Flagship
LBL_FLAGSHIP_SPEED | 40 | Flagship details panel, current speed line; {n} is a number | Speed: {n}
LBL_FLAGSHIP_HOLD_CAP | 40 | Flagship details panel, hold size line; {m} is the room in total | Hold capacity: {m}
LBL_FLAGSHIP_FOUND | 40 | Flagship details panel, worlds found so far; {n} found of {m} | Worlds found: {n} of {m}
LBL_FLAGSHIP_TARGET | 60 | Flagship details panel, current destination line; {planet} is a name | Heading for: {planet}
LBL_FLAGSHIP_NO_TARGET | 40 | Flagship details panel, no destination | Heading for: nowhere
NOT_EXPLORE_DONE | 110 | Notice, exploration mode finished: every world of every open system is surveyed and established | Exploration complete. Every world in your open systems is surveyed and established.
NOT_FIELD_SURVEYED | 110 | Notice, the Pathfinder reached an asteroid field | Asteroid field surveyed.
NOT_FLIGHT_EVENT | 110 | Notice before a flight event, optional | The Pathfinder reports something on the lane.

## Tutorial: first flight (T181; replaces the old guided step 1 when discovery is on; Russian in story/ru/discovery.json)
TUT_G0_FLY | 60 | Guided step 0, until the Pathfinder has reached the nearby world | Right-click {planet}, choose Establish a trading post.
TUT_G0_FLY_WHY | 110 | Guided step, why it matters (second line of the card) | The Pathfinder flies there by itself and builds the post. Your first one is free.
TUT_G0_TRAVEL | 60 | Guided step 0, after the order and the speed card, while the Pathfinder is still flying | Wait for the Pathfinder to reach {planet}.
TUT_G0_TRAVEL_WHY | 110 | Guided step 0, travel card, second line: a tip to read during the flight | Tip: every world makes some goods and lacks others. Carry goods from where they are cheap to where they sell.
TUT_G0_BUILD | 60 | Guided step 0, after arrival, until the post is built | Right-click this world, choose Establish trading post.
TUT_G0_BUILD_WHY | 110 | Guided step, why it matters (second line of the card) | A post lets you buy, sell and route there. Your first one is free.
TUT_G0_WAIT | 60 | Guided step 0, while the post is building | Press the lit time button, top right, and wait for the post.
TUT_G0_WAIT_WHY | 110 | Guided step, why it matters (second line of the card) | The post is built over cycles. Time stands still while the game is paused.
TUT_G0_DONE | 60 | Guided step 0, celebration card once the post stands | Yay! We established a trading post on {planet}!
TUT_G0_DONE_WHY | 110 | Guided step, why it matters (second line of the card) | A post lets you buy, sell and route there. Voltara is next.
TUT_G0_DONE_NEXT | 24 | Guided step 0, button on the celebration card | Next
TUT_G1C_SPEED | 60 | Guided card after slide 1, information plus one try-it action; Next button reuses TUT_G0_DONE_NEXT | Top right: 2x, 6x and 12x run the game faster.
TUT_G1C_SPEED_WHY | 110 | Guided card after slide 1, second line (why); the speed buttons are 1x 2x 6x 12x, the icon beside them is pause/play | Trips and posts take cycles, so waiting is quicker at speed. The pause button stops time.

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
WORLD_SYS3_NAME | 24 | System 3 name (placeholder) | TEMPORARY A
WORLD_SYS3_DESC | 110 | System 3 description (placeholder, off) | Temporary text for a far system. It is not open yet.
PERMIT_S3_NAME | 24 | Permit list, system 3 entry (placeholder) | Permit: TEMPORARY A
PERMIT_S3_DESC | 110 | Permit list, system 3 description (placeholder) | Temporary text. Opens TEMPORARY A for routes.
PERMIT_S3_BTN | 24 | Permit list, buy button, system 3 (placeholder) | Buy permit
NOT_PERMIT_S3 | 110 | Notice, permit for system 3 bought (placeholder) | Permit bought. TEMPORARY A is open: three new planets.
WORLD_S3P1_NAME | 24 | System 3 planet 1 (placeholder) | Temp A1
WORLD_S3P1_DESC | 110 | Planet 1 of system 3, tooltip (placeholder) | Temporary planet text.
WORLD_S3P2_NAME | 24 | System 3 planet 2 (placeholder) | Temp A2
WORLD_S3P2_DESC | 110 | Planet 2 of system 3, tooltip (placeholder) | Temporary planet text.
WORLD_S3P3_NAME | 24 | System 3 planet 3 (placeholder) | Temp A3
WORLD_S3P3_DESC | 110 | Planet 3 of system 3, tooltip (placeholder) | Temporary planet text.

## House convoy card (2026-11-06; re-voiced T287, houses are weather)
HINT_RIVAL_MARKET | 60 | Card on a clicked house convoy, second line, the kind of weather it brings; {weather} is Flood, Shortage or Congestion | Weather: {weather}
HINT_RIVAL_NO_MARKET | 60 | Card on a clicked house convoy, second line, when no weather is due | No weather on its way

## Prosperity, Bazaar and Next Up (2026-11-06, T267)
Ids and placeholders (notes, not blocks):
- PROS_TIER_BARREN, PROS_TIER_1 to PROS_TIER_5: tier names on the planet card and in notices. Five tiers plus Barren is a placeholder; tier 1 is Outpost, tier 3 is Town (capital tier placeholder). No placeholders.
- PROS_NOTICE_TIER_UP: notice, {planet}, {tier}. PROS_NOTICE_TAX: notice, {cash}. NOT_SKILL_REASON_TIER: fills {reason}, {planet}, {tier}.
- PROS_LBL_NEEDS, PROS_LBL_PROGRESS, PROS_LBL_DEMAND, PROS_LBL_SOLD: planet card labels. PROS_NEED_MET, PROS_NEED_SHORT, PROS_NEED_LOCKED: need row status, no placeholders. PROS_CHIP_HUNGRY, PROS_CHIP_SURPLUS: chips on a need row. PROS_RESTLESS: card line. PROS_FED_BY: empty hub column label.
- BAZ_NAME, BAZ_PANEL_TITLE, BAZ_LBL_BILL, BAZ_LBL_QUORUM, BAZ_LBL_REACH, BAZ_LBL_CAPITAL, BAZ_LBL_WINGS: Bazaar panel, no placeholders.
- BAZ_FOUND_BTN, BAZ_FOUND_CONFIRM, BAZ_FOUND_CANCEL: buttons. BAZ_FOUND_PROMPT: confirm text, {planet}. BAZ_FOUNDED: notice, {planet}.
- BAZ_STAGE_1_NAME to BAZ_STAGE_4_NAME: stage names (four is a placeholder). BAZ_STAGE_DONE: notice, {stage}.
- BAZ_BILL_ROW: {amount}, {commodity}. BAZ_QUORUM_ROW: {n}, {m}, {tier}. BAZ_REACH_ROW: no placeholders. BAZ_TERM_LEFT: {cycles}.
- BAZ_BTN_CONTINUE: button on the end screen. BAZ_FREEPLAY_NOTE: line under it.
- NEXTUP_LBL_GROWTH, NEXTUP_LBL_BAZAAR, NEXTUP_LBL_BEST: slot labels. NEXTUP_GROWTH: {planet}, {need}. NEXTUP_GROWTH_LOCKED: {planet}, {skill}. NEXTUP_BAZAAR_BILL: {amount}, {commodity}. NEXTUP_BAZAAR_QUORUM: {n}. NEXTUP_BAZAAR_FOUND: {planet}. NEXTUP_BEST_LANE: {planet_a}, {planet_b}. NEXTUP_BEST_CASH: {cash}, {cycles}. NEXTUP_BEST_GIG: {title}, {cycles}. NEXTUP_IDLE: none.
- Placeholder values: {tier} and {stage} are the names below. {need} is the name of a shown need only. {skill} is a skill or workshop name. Never fill any of them with a hidden good.

### Prosperity tiers
PROS_TIER_BARREN | 24 | Planet card, tier of a dead world | Barren
PROS_TIER_1 | 24 | Planet card, tier 1 | Outpost
PROS_TIER_2 | 24 | Planet card, tier 2 | Village
PROS_TIER_3 | 24 | Planet card, tier 3 (capital tier placeholder) | Town
PROS_TIER_4 | 24 | Planet card, tier 4 | City
PROS_TIER_5 | 24 | Planet card, tier 5 | Metropolis
PROS_NOTICE_TIER_UP | 110 | Notice, a world reached a new tier; {planet}, {tier} | {planet} is now a {tier}.
PROS_NOTICE_TAX | 110 | Notice, tax paid at cycle end; {cash} credits | Worlds paid {cash} credits in tax this cycle.
NOT_SKILL_REASON_TIER | 60 | Fills {reason}, first world to reach a tier; {planet}, {tier} | first {tier} reached, at {planet}

### Planet card
PROS_LBL_NEEDS | 24 | Planet card, header of the need list | Needs
PROS_LBL_PROGRESS | 24 | Planet card, growth bar label | Growth progress
PROS_NEEDS_NOTE | 110 | Planet card, small line under the Needs header: the numbers are per cycle, not a one-time total | Delivered / wanted, per cycle.
PROS_LBL_DEMAND | 24 | Planet card, need row, units wanted each cycle | Demand per cycle
PROS_LBL_SOLD | 24 | Planet card, need row, units sold here this cycle | Sold this cycle
PROS_NEED_MET | 24 | Planet card, need row status | Met
PROS_NEED_SHORT | 24 | Planet card, need row status | Short
PROS_NEED_LOCKED | 24 | Planet card, need row of a good not shown yet | ? Not known yet
PROS_CHIP_HUNGRY | 24 | Planet card, chip on a short need, price is up | Hungry
PROS_CHIP_SURPLUS | 24 | Planet card, chip when sales passed demand | Surplus
PROS_RESTLESS | 110 | Planet card, line while growth progress drops | Restless. A short need is costing it progress. Meet every need to stop it.
PROS_FED_BY | 24 | Hub panel, label of the empty column | Fed by

### Bazaar
BAZ_NAME | 24 | Name of the win goal, panel and end screen | Star Bazaar
BAZ_PANEL_TITLE | 24 | Bazaar panel title | The Star Bazaar
BAZ_FOUND_BTN | 24 | Planet panel, button on a world at the capital tier | Found the Bazaar here
BAZ_FOUND_PROMPT | 110 | Confirm text before founding; {planet} | Found the Star Bazaar at {planet}? This is final. A run has one capital.
BAZ_FOUND_CONFIRM | 24 | Confirm button | Found it
BAZ_FOUND_CANCEL | 24 | Cancel button | Not yet
BAZ_FOUNDED | 110 | Notice, the Bazaar is founded; {planet} | The Star Bazaar is founded at {planet}.
BAZ_STAGE_1_NAME | 24 | Bazaar stage 1 (placeholder) | Foundations
BAZ_STAGE_2_NAME | 24 | Bazaar stage 2 (placeholder) | Halls
BAZ_STAGE_3_NAME | 24 | Bazaar stage 3 (placeholder) | Towers
BAZ_STAGE_4_NAME | 24 | Bazaar stage 4 (placeholder) | Great Hall
BAZ_STAGE_DONE | 110 | Notice, a stage is complete; {stage} is the stage name | Bazaar stage done: {stage}.
BAZ_LBL_BILL | 24 | Bazaar panel, goods the stage needs | Goods needed
BAZ_LBL_QUORUM | 24 | Bazaar panel, other worlds the stage needs | Other worlds
BAZ_LBL_REACH | 24 | Bazaar panel, a world in another system | Reach
BAZ_LBL_CAPITAL | 24 | Bazaar panel, the capital world | Capital
BAZ_LBL_WINGS | 24 | Bazaar panel, chosen wings | Wings
BAZ_TERM_LEFT | 60 | Bazaar panel, time left in the run; {cycles} | Term left: {cycles} cycles
BAZ_BILL_ROW | 60 | Bazaar panel, one row of the stage bill; {amount} units still short, {commodity} | {amount} more {commodity}
BAZ_QUORUM_ROW | 60 | Bazaar panel, other worlds row; {n} worlds there, {m} needed, {tier} the tier | {n} of {m} worlds at {tier}
BAZ_REACH_ROW | 60 | Bazaar panel, reach row | One world in another system
BAZ_BTN_CONTINUE | 24 | End screen, button after the win or the soft ending | Continue (free play)
BAZ_FREEPLAY_NOTE | 110 | End screen, line under the continue button | Free play has no further ending. The Bazaar panel keeps counting.

### Next Up strip
NEXTUP_LBL_GROWTH | 24 | Next Up strip, slot 1 label | Closest growth
NEXTUP_LBL_BAZAAR | 24 | Next Up strip, slot 2 label | Bazaar
NEXTUP_LBL_BEST | 24 | Next Up strip, slot 3 label | Best move
NEXTUP_GROWTH | 60 | Slot 1, a world near its next tier; {planet}, {need} a shown need | {planet}: needs {need}
NEXTUP_GROWTH_LOCKED | 60 | Slot 1, a need not shown yet; {skill} the skill or workshop that would show it | {planet}: learn {skill} to see more
NEXTUP_BAZAAR_BILL | 60 | Slot 2, shortest bill item; {amount}, {commodity} | Bazaar: {amount} more {commodity}
NEXTUP_BAZAAR_QUORUM | 60 | Slot 2, the world gap; {n} worlds still needed | Bazaar: {n} more worlds to grow
NEXTUP_BAZAAR_FOUND | 60 | Slot 2, a world can host the Bazaar; {planet} | Found the Bazaar at {planet}
NEXTUP_BEST_LANE | 60 | Slot 3, a hungry lane | Send goods from {planet_a} to {planet_b}
NEXTUP_BEST_CASH | 60 | Slot 3, cash gap to the next buy; {cash} credits, {cycles} | Save {cash} credits, about {cycles} cycles
NEXTUP_BEST_GIG | 60 | Slot 3, a gig is urgent or nothing better is open; {title}, {cycles} | Gig: {title}, {cycles} cycles left
NEXTUP_IDLE | 60 | Any slot with nothing to show | Keep trading. Check the planet cards.

## Flagship, dock sheet and gig board (T275, 2026-11-06; Phase 2)
The Pathfinder becomes the Flagship: same scout, now with a small hold. The old LBL_PATHFINDER_* and NOT_PATHFINDER_* ids stay until the programmer swaps them for the FLAGSHIP ids below; the notices in the Pathfinder block that say "Pathfinder" should then use {ship} (the game fills the Flagship name) or the FLAGSHIP_NAME text. Goods in gig texts come only through {commodity}, a visible good; the game never fills a hidden one. Boost burns energy, which is visible from the start. Placeholders: {planet}, {commodity}, {amount}, {cash}, {cycles}, {n}, {m}.

FLAGSHIP_NAME | 24 | Ship panel, map tooltip, dock sheet title: name of the player's own ship (replaces LBL_PATHFINDER_NAME) | Tessarine
FLAGSHIP_DESC | 110 | Ship panel, one line under the name | Your own ship. It scouts, builds posts, carries a small hold and takes gigs.
FLAGSHIP_FLYING | 60 | Top bar or ship panel, flying to a known planet; {planet} (replaces LBL_PATHFINDER_FLYING) | Tessarine flying to {planet}
FLAGSHIP_IDLE | 60 | Ship panel, not flying and not building (replaces LBL_PATHFINDER_IDLE) | Tessarine waiting
FLAGSHIP_DOCKED | 60 | Ship panel, docked at a world; {planet} | Tessarine docked at {planet}
LBL_HOLD | 24 | Ship panel and dock sheet, the Flagship's hold | Hold
LBL_HOLD_FILL | 40 | Ship panel readout; {n} units held, {m} room in total | Hold: {n} of {m}
LBL_HOLD_EMPTY | 24 | Dock sheet, a hold row with nothing in it | Empty
BTN_DOCK | 24 | Planet panel and right-click menu, opens the dock sheet (the Flagship must be at an established world) | Dock
LBL_DOCK_TITLE | 40 | Dock sheet heading; {planet} | Dock at {planet}
LBL_DOCK_HOLD | 24 | Dock sheet, column or block heading for the hold | In the hold
LBL_DOCK_WORLD | 24 | Dock sheet, column or block heading for the world's market | At this world
BTN_UNLOAD_STORAGE | 24 | Dock sheet, moves the row from the hold to Company storage here | Unload to storage
BTN_LOAD_STORAGE | 24 | Dock sheet, moves goods from Company storage here into the hold | Load from storage
BTN_DOCK_CLOSE | 24 | Dock sheet, closes it and lets the clock run | Undock
LBL_DOCK_PAUSED | 60 | Dock sheet, small line: time stands still while it is open | Time is paused while you are docked.
LBL_DOCK_STORAGE_ROW | 40 | Dock sheet, the Company storage line of a good; {n} units | Company storage: {n}
NOT_DOCK_HOLD_FULL | 110 | Notice, Buy refused or cut short because the hold is full | The hold is full. Unload first.
NOT_DOCK_STORAGE_FULL | 110 | Notice, Unload refused or cut short because Company storage here is full | Company storage here is full.
NOT_DOCK_NO_STOCK | 110 | Notice, Load refused because Company storage here has none of that good | Company storage here has none of that.
NOT_DOCK_NO_POST | 110 | Notice, dock pressed at a world with no trading post | Establish a trading post here to dock and trade.
NOT_DOCK_FAR | 110 | Notice, dock pressed while the Flagship is away from the world | Fly the Flagship here first.
LBL_DOCK_HOLD_FULL | 60 | Dock sheet, line under the hold when it is full | The hold is full. Loading is limited to the room left.
BTN_BOOST | 24 | Ship panel and flight hud, boost button (also a held key) | Boost
LBL_BOOST_HINT | 110 | Tooltip of the boost button | Faster on straight legs. Burns energy from the hold. Turning stays slow.
LBL_BOOST_CHARGES | 40 | Flight hud, boost gauge; {n} charges left | Boost: {n} left
NOT_BOOST_NO_ENERGY | 110 | Notice, boost pressed with no energy in the hold | No energy in the hold to boost.
NOT_BOOST_EMPTY | 110 | Notice, boost pressed with no charge left | Boost is recharging.
LBL_GIG_BOARD_TITLE | 24 | Gig board heading | Gig board
LBL_GIG_BOARD_EMPTY | 60 | Gig board with no open offers | No open gigs. New ones come with the cycles.
LBL_GIG_SIGNAL | 24 | Gig board, tag on a signal offer | Signal
LBL_GIG_ETA | 40 | Gig board row; {cycles} flight time from the Flagship | ETA: {cycles} cycles
LBL_GIG_DEADLINE | 40 | Gig board row; {cycles} cycles left to deliver | Deadline: {cycles} cycles
LBL_GIG_TOO_FAR | 60 | Gig board row when the ETA is longer than the deadline | The Flagship cannot make it in time.
BTN_GIG_ACCEPT | 24 | Gig board row, takes the offer and drops a map marker | Accept
BTN_GIG_ABANDON | 24 | Gig board row of the taken gig, gives it up | Give up
BTN_GIG_FLY | 24 | Gig board row of the taken gig, sends the Flagship at once | Fly there
NOT_GIG_ACCEPTED | 110 | Notice, a gig was accepted | Gig accepted. A marker shows the way.
NOT_GIG_ONE_AT_A_TIME | 110 | Notice, accept pressed while a gig is already taken | One gig at a time. Finish or give up the one you have.
NOT_GIG_ABANDONED | 110 | Notice, a gig was given up | Gig given up.
NOT_GIG_NEW | 60 | Notice, a new offer reached the board | A new gig is on the board.
NOT_GIG_EXPIRED_EN_ROUTE | 110 | Notice, the offer the Flagship was flying to ran out; the Flagship stops | The signal went quiet before we got there. The Flagship holds position.

## House weather, forecasts and moods (T287, 2026-11-06; houses are weather, not rivals)
Houses: {bot1} Harrow Combine floods a world, {bot2} Velvet Concord makes shortages, {bot3} Ostrel Syndicate causes congestion. Placeholders (new, the game fills them): {house} is the house name (STD_BOT1_NAME to STD_BOT3_NAME), {weather} is WX_NAME_FLOOD, WX_NAME_SHORTAGE or WX_NAME_CONGESTION, {planet}, {commodity} (a visible good only), {cycles}, {n}, {system}. Notices are plain, no flavour. Weather never names a hidden good.

WX_NAME_FLOOD | 24 | Weather kind name, Harrow Combine | Flood
WX_NAME_SHORTAGE | 24 | Weather kind name, Velvet Concord | Shortage
WX_NAME_CONGESTION | 24 | Weather kind name, Ostrel Syndicate | Congestion
HOUSE_BOT1_TEMPER | 90 | House card, temperament line of {bot1} | Heavy and blunt. Floods a world, so a sell price dips for a few cycles.
HOUSE_BOT2_TEMPER | 90 | House card, temperament line of {bot2} | Soft spoken, buys deep. Makes a shortage, so a world needs more and pays more.
HOUSE_BOT3_TEMPER | 90 | House card, temperament line of {bot3} | Slow and orderly. Causes congestion, so trip cost rises on lanes at one place.
HINT_HOUSE_HEADING | 60 | House convoy card, third line, convoy due next cycle | Heading to {planet}, lands next cycle
HINT_HOUSE_HEADING_N | 60 | House convoy card, third line, convoy due later; {n} cycles | Heading to {planet}, lands in {n} cycles
HINT_HOUSE_ACTIVE | 60 | House convoy card, third line, weather in force; {n} cycles left | Weather at {planet} for {n} more cycles
HINT_HOUSE_ACTIVE_KIND | 80 | House convoy card, weather chip tooltip, with the weather kind named; {house}, {weather}, {planet}, {n} cycles left | {house}: {weather} at {planet} for {n} more cycles
HINT_WEATHER_ACTIVE | 70 | Weather chip tooltip when no house is behind it; {weather}, {planet}, {n} cycles left | {weather} at {planet} for {n} more cycles
NOT_WX_FLOOD | 110 | Notice, flood starts; {house}, {planet}, {commodity}, {cycles} | {house} flood at {planet}: {commodity} sell price is down for {cycles} cycles.
NOT_WX_SHORTAGE | 110 | Notice, shortage starts | {house} shortage at {planet}: it needs more {commodity} and pays more for {cycles} cycles.
NOT_WX_CONGEST_WORLD | 110 | Notice, congestion at one world starts | {house} congestion at {planet}: trip cost is up on its lanes for {cycles} cycles.
NOT_WX_CONGEST_EXIT | 110 | Notice, congestion at a system exit starts; {system} is the system name | {house} congestion at the {system} exit: trip cost is up on lanes through it.
NOT_WX_CONVOY | 110 | Notice, a convoy docks and its weather starts | A {house} convoy docks at {planet}. Its weather starts now.
NOT_WX_FORECAST_1 | 110 | Notice and convoy label, weather due next cycle | A {house} convoy is heading to {planet}. Its weather lands next cycle.
NOT_WX_FORECAST_N | 110 | Notice and convoy label, weather due in {n} cycles (forecast skills) | A {house} convoy is heading to {planet}. Its weather lands in {n} cycles.
NOT_WX_ENDING | 110 | Notice, weather ends next cycle | {house} weather at {planet} ends next cycle.
NOT_WX_END | 110 | Notice, weather has ended | {house} weather at {planet} has passed.
WX_FORECAST_FLOOD | 110 | Convoy tooltip, flood due | Flood ahead at {planet}: a sell price will dip. Sell elsewhere, or wait it out.
WX_FORECAST_SHORTAGE | 110 | Convoy tooltip, shortage due | Shortage ahead at {planet}: it will need more and pay more. Send stock there.
WX_FORECAST_CONGEST | 110 | Convoy tooltip, congestion due at a world | Congestion ahead at {planet}: trip cost will rise on its lanes. Move a lane, or pay it.
WX_FORECAST_CONGEST_EXIT | 110 | Convoy tooltip, congestion due at a system exit | Congestion ahead at the {system} exit: trip cost will rise on lanes through it.
MOOD_WARM | 24 | World card, label of a warm face | Warm face
MOOD_PLAIN | 24 | World card, label of a plain face | Plain face
MOOD_COLD | 24 | World card, label of a cold face | Cold face
MOOD_WARM_TIP | 110 | World card, tooltip on a warm face | This world thinks well of you. It changes no price, tax or growth.
MOOD_PLAIN_TIP | 110 | World card, tooltip on a plain face | This world has no view of you yet. It changes no price, tax or growth.
MOOD_COLD_TIP | 110 | World card, tooltip on a cold face | This world thinks less of you. It changes no price, tax or growth.

## Hubs (2026-11-06, T293)
Ids and placeholders (notes, not blocks):
- HUB_NAME, HUB_LBL_REACH, HUB_LBL_POOL, HUB_LBL_SERVED, HUB_LBL_GAPS, HUB_LBL_FEE, HUB_PANEL_TITLE: hub panel, no placeholders.
- HUB_MAKE_BTN, HUB_MAKE_CONFIRM, HUB_MAKE_CANCEL: buttons. HUB_MAKE_PROMPT: confirm text, {planet}. HUB_MADE: notice, {planet}.
- HUB_FIRST: notice, the first hub, {planet}. HUB_RELEASE_BTN, HUB_RELEASE_CONFIRM, HUB_RELEASE_CANCEL: buttons. HUB_RELEASE_PROMPT: confirm text, {planet}. HUB_RELEASED: notice, {planet}.
- HUB_ROW_ROUTE, HUB_ROW_HUB: need row status. HUB_SHORT_NO_SOURCE, HUB_SHORT_NO_SHIP, HUB_SHORT_NO_CASH: need row status, short reasons. HUB_ROW_MANUAL: need row of a world left off the hub.
- HUB_ASSIGN_SHIP, HUB_FREE_SHIP: ship pool buttons. HUB_NO_SLOT: tip when the system has its hub.

### Hub panel and buttons
HUB_NAME | 24 | Name of the hub role | Hub
HUB_PANEL_TITLE | 24 | Hub panel title | Hub
HUB_LBL_REACH | 24 | Hub panel, worlds it can serve | In reach
HUB_LBL_POOL | 24 | Hub panel, ships it uses | Ship pool
HUB_LBL_SERVED | 24 | Hub panel, worlds it feeds | Fed worlds
HUB_LBL_GAPS | 24 | Hub panel, needs it cannot meet | Gaps
HUB_LBL_FEE | 24 | Hub panel, what a delivery costs on top | Hub fee
HUB_MAKE_BTN | 24 | Planet panel, button on a Town that can be a hub | Make this a hub
HUB_MAKE_PROMPT | 110 | Confirm text before making a hub; {planet} | Make {planet} a hub? It keeps the worlds near it fed, with ships from its pool.
HUB_MAKE_CONFIRM | 24 | Confirm button | Make hub
HUB_MAKE_CANCEL | 24 | Cancel button | Not yet
HUB_MADE | 110 | Notice, a hub is made; {planet} | {planet} is now a hub. Give it ships to start.
HUB_FIRST | 110 | Notice, the first hub; {planet} | {planet} keeps its neighbours fed now. Your hands are free for other work.
HUB_RELEASE_BTN | 24 | Hub panel, release button | Release hub
HUB_RELEASE_PROMPT | 110 | Confirm text before release; {planet} | Release the hub at {planet}? Its ships go back to your fleet and its worlds go back to you.
HUB_RELEASE_CONFIRM | 24 | Confirm button | Release
HUB_RELEASE_CANCEL | 24 | Cancel button | Keep hub
HUB_RELEASED | 110 | Notice, a hub is released; {planet} | The hub at {planet} is released. Its worlds need your routes again.
HUB_ASSIGN_SHIP | 24 | Hub panel, button to add a free ship | Add a ship
HUB_FREE_SHIP | 24 | Hub panel, button to return a ship | Return ship
HUB_NO_SLOT | 110 | Tip on the make button when the system has a hub | This system already has a hub. Release it to move the work here.
HUB_ROW_MANUAL | 24 | Need row, world left off the hub | Yours by hand

### Need status
HUB_ROW_ROUTE | 24 | Need row, filled by a manual route | Fed by your route
HUB_ROW_HUB | 24 | Need row, filled by a hub | Fed by hub
HUB_SHORT_NO_SOURCE | 60 | Need row, short, nothing to buy in reach | Short: no source in reach
HUB_SHORT_NO_SHIP | 60 | Need row, short, every pool ship is busy | Short: no free ship in pool
HUB_SHORT_NO_CASH | 60 | Need row, short, hub stopped buying | Short: not enough cash

## Frontier, wings and recap (2026-11-06, T301; Phase 5)
Ids and placeholders (notes, not blocks):
- Reclaim: RECLAIM_BTN, RECLAIM_CONFIRM, RECLAIM_CANCEL buttons. RECLAIM_PROMPT: {planet}. RECLAIM_STARTED, RECLAIM_DONE: notices, {planet}. RECLAIM_LBL_PROGRESS, RECLAIM_TIP: card texts. PROS_TYPE_RECLAIMED: the world type name.
- Raids: RAID_WARN {planet}, {system}. RAID_HIT {planet_a}, {planet_b}, {cycles}. RAID_LANE_TIP {cycles}.
- Pods: POD_SPOTTED {planet}, {cycles}. POD_SCOOPED, POD_SCOOPED_PART, POD_FADED: none. LBL_GIG_PODS: gig board tag.
- Mining intensity: MINE_INTENSITY_LBL, MINE_INT_GENTLE, MINE_INT_NORMAL, MINE_INT_HARD and a _HINT for each. No placeholders.
- Wings: BAZ_WING_TITLE, BAZ_WING_PROMPT {stage}, BAZ_WING_PICK, BAZ_WING_<stage><A or B>_NAME and _LINE. Wing lines are neutral placeholders: the economy-designer sets the real effect, and the line must be checked against it.
- Recap: RECAP_TITLE, RECAP_LBL_*, RECAP_NONE. The game fills the values, no placeholders here.
- No text here names a hidden good. Reclaim needs are listed by the card from shown goods only.

### Reclaim
RECLAIM_BTN | 24 | Dead world card, starts the reclaim | Start reclaiming
RECLAIM_PROMPT | 110 | Confirm text before reclaim; {planet} | Reclaim {planet}? It cannot be mined while the work runs.
RECLAIM_CONFIRM | 24 | Confirm button | Reclaim
RECLAIM_CANCEL | 24 | Cancel button | Not yet
RECLAIM_LBL_PROGRESS | 24 | Dead world card, reclaim bar label | Reclaim progress
RECLAIM_TIP | 110 | Dead world card, line under the reclaim bar | Meet every need to fill the bar. Mining here stops until it is done.
RECLAIM_STARTED | 110 | Notice, reclaim started; {planet} | Reclaim started at {planet}. Mining there is paused.
RECLAIM_DONE | 110 | Notice, reclaim finished; {planet} | {planet} is reclaimed. It is a living world now, and raids from it have stopped.
PROS_TYPE_RECLAIMED | 24 | Planet card, type of a reclaimed world | Reclaimed world

### Raids and pods
RAID_WARN | 110 | Notice and chip, raid due next cycle; {planet} the nest, {system} | Raiders are gathering at {planet}. A raid on {system} lanes may come next cycle.
RAID_HIT | 110 | Notice, a lane was raided; {planet_a}, {planet_b}, {cycles} | Raiders hit {planet_a} to {planet_b}. Part of the trip is lost. The lane runs worse for {cycles} cycles.
RAID_LANE_TIP | 60 | Lane marker tooltip; {cycles} cycles left | Raided lane. It runs worse for {cycles} more cycles.
POD_SPOTTED | 110 | Notice, cargo pods drift after a raid; {planet} the nearest world, {cycles} | Cargo pods are drifting near {planet}. They fade in {cycles} cycles.
POD_SCOOPED | 110 | Notice, the Flagship picked up all the pods | Pods picked up. The goods are in the hold.
POD_SCOOPED_PART | 110 | Notice, the hold was too full for all of it | Pods picked up. The hold took what it could.
POD_FADED | 110 | Notice, pods faded unreached | The pods faded before anyone reached them.
LBL_GIG_PODS | 24 | Gig board, tag on a pod pickup | Cargo pods

### Mining intensity
MINE_INTENSITY_LBL | 24 | Dead world and cluster card, label of the three-step lever | Mining intensity
MINE_INT_GENTLE | 24 | Lever step | Gentle
MINE_INT_GENTLE_HINT | 110 | Lever step hint | Less yield. Fewer raids.
MINE_INT_NORMAL | 24 | Lever step | Normal
MINE_INT_NORMAL_HINT | 110 | Lever step hint | Usual yield. Usual raids.
MINE_INT_HARD | 24 | Lever step | Hard
MINE_INT_HARD_HINT | 110 | Lever step hint | More yield. More raids.

### Wings
BAZ_WING_TITLE | 32 | Wing popup title | Choose a wing
BAZ_WING_PROMPT | 110 | Wing popup, line under the title; {stage} the stage just done | {stage} is done. Pick one wing to add. The other is not offered again.
BAZ_WING_PICK | 24 | Wing popup, button under each wing | Add this wing
BAZ_WING_1A_NAME | 24 | Wing popup and Bazaar panel, stage 1, choice A | Wing of Holds
BAZ_WING_1A_LINE | 110 | Same, one plain line | The Flagship carries a bigger hold.
BAZ_WING_1B_NAME | 24 | Stage 1, choice B | Wing of Reach
BAZ_WING_1B_LINE | 110 | Same | Hubs reach farther.
BAZ_WING_2A_NAME | 24 | Stage 2, choice A | Wing of Tolls
BAZ_WING_2A_LINE | 110 | Same | Worlds pay more tax.
BAZ_WING_2B_NAME | 24 | Stage 2, choice B | Wing of Benches
BAZ_WING_2B_LINE | 110 | Same | Workshops cost less to build.
BAZ_WING_3A_NAME | 24 | Stage 3, choice A | Wing of Lamps
BAZ_WING_3A_LINE | 110 | Same | The Flagship carries a bigger hold.
BAZ_WING_3B_NAME | 24 | Stage 3, choice B | Wing of Couriers
BAZ_WING_3B_LINE | 110 | Same | Your worlds pay more tax.
BAZ_WING_1A_DESC | 260 | Wing popup and Bazaar panel, stage 1 A; {n} is units of hold | A long dock where crates wait for the Flagship. The racks are wide and the doors tall. The Flagship carries {n} more units in its hold.
BAZ_WING_1B_DESC | 260 | Same, stage 1 B; no {n} | A gallery of signal masts above the Bazaar roof. Each hub hears farther and serves farther. Hubs reach farther.
BAZ_WING_2A_DESC | 260 | Same, stage 2 A; {n} is percent | The hall where clerks sit and count what each world sends up. Your worlds pay {n}% more tax each cycle.
BAZ_WING_2B_DESC | 260 | Same, stage 2 B; {n} is percent, build cost only | A long room of vises and lathes, open to any crew. New workshops cost {n}% less to build. Crafting costs do not change.
BAZ_WING_3A_DESC | 260 | Same, stage 3 A; {n} is units of hold (what the code does today) | A loading dock under the Bazaar lamps, lit through the night shift. The Flagship carries {n} more units in its hold.
BAZ_WING_3B_DESC | 260 | Same, stage 3 B; {n} is percent (what the code does today) | The couriers' stair, where each day's count goes up to the Bureau. Your worlds pay {n}% more tax each cycle.


### Bazaar guidance (2026-11-12, T363)
Placeholders: {stage} stage name, {amount} units still short, {good} good name (shown goods only), {capital} the capital world, {source} the cheaper world, {price} and {local} credits per unit, {n} count, {tier} tier name, {planet} world name, {line} the step line. Wing descriptions: {n} is the absolute effect amount from data/balance.json (unit named in each row).
BAZ_HOW | 200 | Bazaar panel, paragraph under the title | The Bazaar is raised in stages. Each needs goods held in the capital's own storage and other worlds grown to a tier. Each must be done before the term ends.
BAZ_STEP_BILL | 220 | Bazaar panel and capital card, under a short bill row | {stage} needs {amount} more {good} held in {capital}'s storage. Buy it at {source} ({price} cr) and send it to {capital}, or turn Buy on at {capital} ({local} cr).
BAZ_STEP_BILL_LOCAL | 160 | Same, when only the capital sells the good | {stage} needs {amount} more {good} held in {capital}'s storage. Turn Buy on for it at {capital} ({local} cr).
BAZ_STEP_BILL_FED | 160 | Same, when a Buy order or route already feeds it | {stage}: {amount} more {good} still to reach {capital}. Your Buy or route is on. Give it a few cycles.
BAZ_STEP_QUORUM | 120 | Same, quorum step | {stage} needs {n} more worlds at {tier}. Meet their needs every cycle.
BAZ_STEP_REACH | 120 | Same, reach step | {stage} needs a world in another system. Buy a permit in Skills, then establish a post there.
BAZ_BTN_BUY_AT | 24 | Bazaar panel, button under a bill row | Buy at {planet}
BAZ_BTN_SEND_TO | 24 | Bazaar panel, button under a bill row | Send to {planet}
BAZ_CARD_TITLE | 40 | Capital card block and Bazaar card, title | Star Bazaar: {stage}
NOT_BAZAAR_REMIND | 110 | Cycle-end notice while a bill item is short and not fed | Star Bazaar: {line}

### Recap
RECAP_TITLE | 40 | End screen, heading of the recap | The run in brief
RECAP_LBL_CAPITAL | 24 | Recap label | Capital
RECAP_LBL_STAGES | 24 | Recap label | Stages built
RECAP_LBL_WINGS | 24 | Recap label | Wings
RECAP_LBL_WORLDS | 24 | Recap label | Worlds grown
RECAP_LBL_RECLAIMED | 24 | Recap label | Reclaimed worlds
RECAP_LBL_MOMENTS | 24 | Recap label, heading of the list of the choices that decided the run | Decisive moments
RECAP_NONE | 24 | Recap value when there is nothing to list | None

## Hard-coded texts moved to ids (2026-11-09, UI programmer; Russian localisation, code side)

Texts that were literals in the game scripts or fallbacks of ids missing here. English is the former literal; placeholders are filled by the code. Place = file and spot in the code.
BAZ_OPENING_BANNER | 50 | main.gd:2458
The Star Bazaar is open.
BOT_NAME_1 | 30 | bots.gd bot_name (house name 1)
Harrow Combine
BOT_NAME_2 | 30 | bots.gd bot_name (house name 2)
Velvet Concord
BOT_NAME_3 | 30 | bots.gd bot_name (house name 3)
Ostrel Syndicate
BTN_BUY_SHIP | 80 | ship_panel.gd set_upkeep (buy button)
Buy {ship} ({price} cr, upkeep {upkeep})
BTN_CANCEL_PENDING | 24 | planet_panel.gd build (pending send card, cancel button)
Cancel
BTN_MENU | 24 | main.gd:3400
Menu
BTN_NAV_HIDE | 30 | main.gd:3571
Hide navigation
BTN_NAV_SHOW | 30 | main.gd:3571
Show navigation
BTN_OPEN_SYSTEM | 24 | galaxy_view.gd:736
Open system
BTN_SPLIT_BAR | 24 | planet_panel.gd:874
Split
BTN_SPLIT_DONE | 24 | planet_panel.gd:944
Done
BTN_TIP_OK | 24 | main.gd:5120
Got it
BTN_UPGRADE_ROUTE | 30 | planet_panel.gd:1135
Upgrade route
END_BTN_CONTINUE | 24 | end_screen.gd button row
Continue
END_RECAP_CAPITAL | 40 | end_screen.gd:73
Capital: {planet}
END_RECAP_MOMENT | 50 | end_screen.gd:88
Cycle {cycle}: {moment}
END_RECAP_RECLAIMED | 40 | end_screen.gd:83
Reclaimed worlds: {n}
END_RECAP_STAGES | 50 | end_screen.gd:74
Stages raised: {n} of {m}
END_RECAP_WING | 30 | end_screen.gd:76
Wing: {wing}
END_RECAP_WORLDS | 40 | end_screen.gd:82
{n} worlds at {tier}
END_STAT_STAGES | 30 | main.gd:2674
Bazaar stages
EVFEED_LINE | 40 | main.gd _refresh_event_feed
Cycle {cycle}: {title}
EVT_DIR_FALL | 24 | main.gd forecast_text (fills {direction} of EVT_NEXT_DUE_PRICE*)
fall
EVT_DIR_RISE | 24 | main.gd forecast_text (fills {direction} of EVT_NEXT_DUE_PRICE*)
rise
FAB_MADE | 30 | space_storage_view.gd fabric status line
made {n} {good}
FAB_READY | 24 | space_storage_view.gd fabric status line
ready
FC_AFTER | 40 | cash_forecast.gd last line
After cycle: {cash}
FC_HEAD | 80 | cash_forecast.gd first line
Cycle {cycle} ends {timing}. Now: {cash}
FC_INCOME | 24 | cash_forecast.gd Income heading
Income:
FC_IN_SECONDS | 24 | cash_forecast.gd _rebuild timing
in {n}s
FC_LAST_CYCLE | 40 | cash_forecast.gd second line
Last cycle: {summary}
FC_NONE | 24 | cash_forecast.gd empty income
none
FC_PAUSED | 24 | cash_forecast.gd _rebuild timing
paused
FC_ROUTE_STATUS | 30 | cash_forecast.gd route_expense_lines
{route} {status}
FC_STATUS_BLOCKED | 24 | cash_forecast.gd route_expense_lines (status word after a route name)
blocked
FC_STATUS_STALLED | 24 | cash_forecast.gd route_expense_lines (status word after a route name)
stalled
FC_STATUS_WAITING | 24 | cash_forecast.gd route_expense_lines (status word after a route name)
waiting
FC_TRIP_COST | 40 | cash_forecast.gd route_expense_lines
{route} trip cost
FC_IDLE_UPKEEP | 40 | cash_forecast.gd route_expense_lines (ships on no route or in a hub pool)
Idle ships upkeep
GIG_BOARD_EMPTY | 130 | gig_board.gd:67
No offers right now. Signals appear as the run goes on.
GIG_BOARD_TITLE | 24 | gig_board.gd:31
Gig board
GIG_BTN_ACCEPT | 24 | gig_board.gd:155
Accept
GIG_BTN_ORDERED | 24 | gig_board.gd:197
Ordered
GIG_DONE_TITLE | 24 | main.gd:2953
Signal
GIG_EFF_CASH | 30 | gigs.gd:603
+{n} credits.
GIG_EFF_FEE | 30 | gigs.gd:611
-{n} credits.
GIG_EFF_GOODS | 40 | gigs.gd:616
{n} {good} in storage.
GIG_EFF_IDLE | 70 | gigs.gd:638
The Flagship is held for {n} cycles.
GIG_ETA | 60 | gig_board.gd:195
ETA {cycles} cycles, left {left}
GIG_ETA_NONE | 30 | gig_board.gd:193
Out of reach
GIG_KIND_OPENING | 24 | gig_board.gd:77
The Opening
GIG_KIND_SALVAGE | 24 | gig_board.gd:79
Salvage
GIG_KIND_SIGNAL | 24 | gig_board.gd:82
Signal
GIG_REFUSE_BAD_TARGET | 60 | gig_board.gd _on_accept (refusal reason "bad_target")
The Flagship cannot fly there.
GIG_REFUSE_BUSY | 100 | gig_board.gd _on_accept (refusal reason "busy")
The Flagship is held after its last gig and cannot take orders yet.
GIG_REFUSE_GENERIC | 90 | gig_board.gd _on_accept
The Flagship cannot take this order now ({why}).
GIG_REFUSE_NO_GATE | 60 | gig_board.gd _on_accept (refusal reason "no_gate")
That system is not open yet.
GIG_REFUSE_NO_OFFER | 40 | gig_board.gd _on_accept (refusal reason "no_offer")
That order is gone.
GIG_REWARD_OPENING | 40 | gig_board.gd:108
The Star Bazaar opens
GIG_REWARD_SALVAGE | 80 | gig_board.gd:110
Stolen cargo, loaded into the Flagship hold
GIG_REWARD_SIGNAL | 30 | gig_board.gd:113
Unknown reward
GIG_ROW_OPENING | 50 | gig_board.gd:92
Charter cargo for {planet}
GIG_ROW_SALVAGE | 24 | gig_board.gd:94
Cargo pods
GIG_ROW_SIGNAL | 30 | gig_board.gd:99
Unknown signal
GIG_WHERE_SPACE | 24 | gig_board.gd:104
Open space
GOAL_SECOND_LANE | 120 | main.gd:821
Optional: open system {sys} (permit {n}), then sell a lot there.
HINT_HOUSE_CONGESTION | 70 | rival_card.gd TEMPERAMENT table
Brings congestion: lanes cost more
HINT_HOUSE_FLOOD | 50 | rival_card.gd TEMPERAMENT table
Brings floods: prices fall
HINT_HOUSE_NONE | 30 | rival_card.gd describe (house without temperament)
Weather unknown
HINT_HOUSE_SHORTAGE | 70 | rival_card.gd TEMPERAMENT table
Brings shortages: needs run hungry
KEY_MENU | 24 | main.gd key hints (hints table)
Menu
KEY_ORBIT | 30 | main.gd key hints (hints table)
Right-drag Orbit
KEY_PAN | 24 | main.gd key hints (hints table)
Pan
KEY_ZOOM | 24 | main.gd key hints (hints table)
Wheel Zoom
LBL_A_TO_B | 24 | galaxy_view.gd:863
{a} to {b}
LBL_BLOCKED_SHORT | 24 | galaxy_view.gd:877
Blocked
LBL_BUYS_GOODS | 24 | galaxy_view.gd:850
Buys goods
LBL_BUY_ORDER_STATE | 40 | planet_panel.gd resource row (buy button tooltip)
Buy order: {state}
LBL_BUY_TIP_ON | 80 | planet_panel.gd resource row (buy button tooltip)
{tip}. Standing buy order. Press to stop.
LBL_CONNECTIONS | 24 | planet_panel.gd:1001
Connections
LBL_COST_LINE | 30 | planet_panel.gd route row (running route costs)
{label}: −{n}
LBL_CYCLE_TIP | 24 | main.gd _refresh_hud
Cycle
LBL_GALAXY_HINT | 110 | galaxy_view.gd:200
{open} of {total} systems open. Click a system to see it.
LBL_GALAXY_PLANETS | 24 | galaxy_view.gd:646
{n} planets
LBL_GALAXY_PLANETS_WORD | 24 | galaxy_view.gd:729
Planets
LBL_GALAXY_ROUTES | 24 | galaxy_view.gd:820
Routes
LBL_GALAXY_ROUTE_MANY | 24 | galaxy_view.gd:647
{n} routes
LBL_GALAXY_ROUTE_ONE | 24 | galaxy_view.gd:647
{n} route
LBL_GALAXY_SHIPS | 24 | galaxy_view.gd:821
Ships
LBL_GALAXY_TITLE | 24 | galaxy_view.gd:199
The galaxy
LBL_KNOWN | 24 | galaxy_view.gd:728
Known
LBL_LEGEND_ENERGY | 30 | galaxy_view.gd legend (items table)
Energy route
LBL_LEGEND_FOOD | 24 | galaxy_view.gd legend (items table)
Food route
LBL_LEGEND_LINK | 24 | galaxy_view.gd legend (items table)
Link
LBL_LEGEND_UNCHARTED | 30 | galaxy_view.gd legend (items table)
Uncharted link
LBL_LINKS | 24 | galaxy_view.gd:731
Links
LBL_LOCKED_HOW | 30 | main.gd:1025
permit or skill
LBL_MISSION_FIRST | 70 | main.gd:3696
Mission: Send stock to another planet
LBL_NET_LINE | 40 | planet_panel.gd route row (running route costs)
{label}: {n} / cycle
LBL_NOT_OPEN | 30 | galaxy_view.gd:726
Not open yet
LBL_NO_CREDITS | 40 | ship_panel.gd set_upkeep (free-ships hint)
Not enough credits.
LBL_NO_ROUTES | 30 | galaxy_view.gd:856
No routes yet.
LBL_NO_STOCK_SOURCE | 40 | route_line.gd:501
No stock at source
LBL_OPEN_HOW | 30 | system_exit.gd:174
click to travel
LBL_OPEN_REASON | 70 | galaxy_view.gd:740
Systems open with a permit or a skill.
LBL_ORDER_OFF | 24 | planet_panel.gd:1088
off
LBL_ORDER_ON | 24 | planet_panel.gd:744
on
LBL_PANEL_SENDING | 120 | planet_panel.gd build (pending send card)
Sending {good} from {planet}. Click the destination planet.{hint}
LBL_PENDING_SEND | 130 | main.gd _refresh_pending
Send {good} from {planet}: click the destination planet. (Esc to cancel)
LBL_PENDING_STOP | 150 | main.gd _refresh_pending
Click the stop in the picker, or {planet} again for a direct send. (Esc to cancel)
LBL_PERMIT_OPEN | 40 | galaxy_view.gd:817
Permit held: open.
LBL_PER_CYCLE | 24 | galaxy_view.gd:822
Per cycle
LBL_PER_CYCLE_UNIT | 24 | galaxy_view.gd:649
/ cycle
LBL_PRICE_TIP | 24 | planet_panel.gd resource row (buy button tooltip)
{tip}.
LBL_ROUTE_BLOCKED | 24 | route_line.gd:489
Blocked
LBL_ROUTE_FROM | 30 | planet_panel.gd Connections rows
From {planet}
LBL_ROUTE_PAYS | 100 | planet_panel.gd:1089
Pays when {planet} has a standing Sell order: {state}
LBL_ROUTE_PAYS_NO | 40 | planet_panel.gd:1102
Not traded there.
LBL_ROUTE_PAYS_TIP | 70 | planet_panel.gd:1102
Turn on the Sell order at {planet}.
LBL_ROUTE_ROW_TIP | 50 | planet_panel.gd:1022
Show this route's costs.
LBL_ROUTE_SHIP_MANY | 24 | route_line.gd:492
{n} ships
LBL_ROUTE_SHIP_ONE | 24 | route_line.gd:492
{n} ship
LBL_ROUTE_TO | 24 | planet_panel.gd Connections rows
To {planet}
LBL_ROUTE_UPGRADED | 60 | planet_panel.gd:1125
Route upgraded: +{pct}% margin.
LBL_ROUTE_UPGRADE_INFO | 100 | planet_panel.gd:1128
Full lane. Upgrade: {cost} credits for +{pct}% margin.
LBL_ROUTE_UPGRADE_TIP | 80 | planet_panel.gd:1137
Raise this lane's margin for {cost} credits.
LBL_SELL_OFFER | 50 | main.gd:1398
Sell {commodity} here too?
LBL_SELL_ORDER_STATE | 40 | planet_panel.gd resource row (sell order status)
Sell order: {state}
LBL_SELL_TIP_OFF | 70 | planet_panel.gd resource menu (Sell tooltip)
{tip}. Standing sell order each cycle.
LBL_SELL_TIP_ON | 80 | planet_panel.gd resource menu (Sell tooltip)
{tip}. Standing sell order. Press to stop.
LBL_SEND_BUYS_SHIP | 100 | ship_panel.gd:179
No free ship. Send to... buys one for {price} credits.
LBL_SEND_TIP | 110 | planet_panel.gd resource menu (Send to tooltip)
Move this stock to another planet's storage with a ship.
LBL_SHIPS | 24 | ship_panel.gd:35
Ships
LBL_SHIPS_FREE_HINT | 100 | ship_panel.gd:174
Free ships: {free}. Ship upkeep {upkeep} / cycle each.
LBL_SHIP_COUNT | 40 | ship_panel.gd set_count, the line under the Pathfinder card
Carrier ships: {n} / {cap}
LBL_SHIP_K_OF_N | 30 | planet_panel.gd:1197
Ship {k} of {n}
LBL_SHIP_LIMIT | 50 | ship_panel.gd set_upkeep (free-ships hint)
Ship limit reached ({cap}).
LBL_SHIP_RUNNING | 24 | planet_panel.gd:1205
Running.
LBL_SKILL_POINTS_HELP | 270 | skill_screen.gd build (help line under the title)
Skill points: {planet} for each planet you first trade with, {route} for each new route between two planets, {system} for each new system you reach.
LBL_SPEED_TIP | 30 | main.gd _build_speed_buttons
Game speed {n}x
LBL_SPLIT_BAR_STOP | 24 | planet_panel.gd:939
Stop split
LBL_SPLIT_TAG | 30 | planet_panel.gd:974
Split {share}%
LBL_SS_LOCKED | 50 | galaxy_view.gd:892
Locked · permit or skill
LBL_SS_OPEN | 24 | galaxy_view.gd:892
Open
LBL_STOP_AT_LINE | 120 | main.gd:1499
Stop at {stop}: sell up to {n} here, carry the rest to {planet}.
LBL_SYSTEM_HINT | 60 | main.gd:3684
System {n} · {count} planets
LBL_SYSTEM_N | 40 | galaxy_view.gd:815
System {n} · {how}
LBL_SYS_FIRST | 40 | galaxy_view.gd:814
Your first system.
LBL_SYS_PERMIT | 40 | galaxy_view.gd:814
Opened with a permit.
LBL_THE_PLANET | 24 | trade.gd _name (fallback for an unknown planet index)
the planet
LBL_UNCHARTED | 24 | galaxy_view.gd:451
Uncharted
LBL_UNCHARTED_BODY | 100 | galaxy_view.gd:727
Nobody you know has traded here. That may be the point.
LBL_UNCHARTED_SYSTEM | 30 | galaxy_view.gd:725
Uncharted system
LBL_UPKEEP_LINE | 70 | ship_panel.gd set_upkeep
Ship {n}, {type} ({good}): {pay}{tag}
LBL_UPKEEP_LINE_FREE | 60 | ship_panel.gd set_upkeep
Ship {n}, {type} (free): {pay}
LBL_UPKEEP_TOTAL | 60 | ship_panel.gd set_upkeep
{name}, total: {total} / cycle
LBL_WAITING_SHORT | 24 | galaxy_view.gd:874
Waiting
LBL_YOUR_ROUTES_HERE | 30 | galaxy_view.gd:854
Your routes here
MENU_PAUSE | 24 | main.gd:3666
Pause
MENU_VOICE | 24 | game_menu.gd:60
Voice
NOTE_SECOND_LANE | 90 | planet_panel.gd:125
Your first sale here crossed the system line.
NOT_BAZAAR_OPENING | 130 | main.gd:2425
The charter cargo is ready. Fly it to {planet} to open the Star Bazaar.
NOT_FABRIC_BUILT | 60 | main.gd:2074
Fabric built at the trading post.
NOT_MINE_RECLAIMED | 90 | prosperity.gd:162
This world is alive again and is no longer mined.
NOT_MINE_RECLAIMING | 80 | prosperity.gd:163
Being reclaimed: mining is closed here.
NOT_OLD_SAVE | 150 | save_game.gd:82
Your old save is from before Four Markets and cannot continue. Start a new game.
NOT_PICK_OTHER_DEST | 80 | main.gd
Pick a different planet as the destination.
NOT_PROSPERITY_TAX | 70 | main.gd:2513
Your worlds paid {n} credits in tax.
NOT_PROSPERITY_TIER_UP | 70 | main.gd:2420
{planet} has grown to tier {tier}.
NOT_RAID_HIT | 190 | raids.gd:146
Raiders from {planet} hit your lane to {lane}: {n} units lost, the lane runs weaker for {cycles} cycles.
NOT_RAID_WARNING | 140 | raids.gd:120
Raiders are stirring at {planet}. Your lane to {lane} may be hit next cycle.
NOT_REPOSSESSED | 110 | main.gd:2656
Cash ran out. The newest ship was repossessed: +{n} credits.
NOT_SALVAGE_DONE | 90 | gigs.gd:192
Pods scooped into the Flagship hold: {lines}.
NOT_SALVAGE_FULL | 90 | gigs.gd:194
The Flagship hold is full. Some pods stay adrift.
NOT_STOP_PICK_AGAIN | 100 | main.gd:1162
Click a stop from the picker, or the destination again.
NOT_SYSTEM_LOCKED | 50 | main.gd:1026
{name} is locked: {how}.
ROUTE_OFFSET_MAINT | 80 | planet_panel.gd:1240
Route detour +{offset}%: upkeep +{maint}%
RSN_ALREADY_UPGRADED | 40 | main.gd
Already upgraded.
RSN_GAME_OVER | 40 | main.gd can_buy_ship, can_connect, set_local_order, salvage_stock, move_ship...
The game is over.
RSN_LANE_FULL | 120 | main.gd
This lane is full. Upgrade the route instead of adding a ship.
RSN_NO_CASH_SHIP | 200 | main.gd can_buy_ship
Not enough cash for a new ship ({price} cr). Each route needs its own ship; wait for income or remove a route.
RSN_NO_CASH_UPGRADE | 90 | main.gd can_upgrade_route
Not enough cash to upgrade the route ({cost} cr).
RSN_NO_PAYING_ROUTE | 60 | main.gd
No open route pays for this ship.
RSN_NO_ROUTE | 30 | main.gd
No such route.
RSN_SHIP_CAP | 40 | main.gd
Ship cap reached.
RSN_UPGRADE_NEEDS_FULL | 60 | main.gd
Only a full lane can be upgraded.
RT_ERR_NOT_TRADED_GOOD | 50 | route_engine.gd check_local
{good} is not traded here.
RT_ERR_SRC_NO_GOOD | 40 | route_engine.gd check_connection
The source world has none of this good.
RT_ERR_NO_CLUSTER | 30 | route_engine.gd
No such cluster.
RT_ERR_NO_SYSTEM | 30 | route_engine.gd
No such system.
RT_ERR_PICK_DEST | 60 | route_engine.gd
Pick a planet to deliver to.
RT_ERR_PICK_SOURCE | 50 | route_engine.gd
Pick a planet to send from.
RT_ERR_SAME_PLANET | 50 | route_engine.gd
Pick two different planets.
RT_ERR_UNKNOWN_GOOD | 40 | route_engine.gd
Unknown commodity.
RT_ERR_UNKNOWN_ORDER | 30 | route_engine.gd
Unknown order.
RT_LINE_BUY | 40 | route_engine.gd forecast lines
Buy {good} at {planet}
RT_LINE_SELL | 50 | route_engine.gd forecast lines
Sell {good} at {planet}
RT_REASON_CLOSED | 60 | route_engine.gd
A planet on this route is closed.
RT_REASON_DEST_FULL | 60 | route_engine.gd
Destination storage is full.
RT_REASON_NOTHING | 30 | route_engine.gd
Nothing to move.
RT_REASON_SRC_EMPTY | 50 | route_engine.gd
Source storage is empty.
RT_STATE_BUYING | 24 | route_engine.gd
Buying.
RT_STATE_CLOSED | 30 | route_engine.gd
Planet closed.
RT_STATE_NOT_TRADED | 30 | route_engine.gd
Not traded here.
RT_STATE_SELLING | 24 | route_engine.gd
Selling.
RT_STATE_STORAGE_EMPTY | 30 | route_engine.gd
Storage empty.
RT_STATE_WAITING | 40 | route_engine.gd
Waiting for cycle end.
SETUP_BACK | 24 | company_setup.gd:114
Back
SETUP_CEO_LABEL | 30 | company_setup.gd:75
Choose your CEO
SETUP_NAME_LABEL | 30 | company_setup.gd:56
Company name
SETUP_NEED_CEO | 40 | company_setup.gd:212
Choose a CEO to start.
LBL_LOOK_TITLE | 16 | company_setup.gd Ship look block
Ship look
LBL_LOOK_HUE | 16 | company_setup.gd Ship look block
Hull hue
LBL_LOOK_SHAPE_TORCH | 12 | company_setup.gd Ship look block
Torch
LBL_LOOK_SHAPE_NEEDLE | 12 | company_setup.gd Ship look block
Needle
LBL_LOOK_SHAPE_PILLAR | 12 | company_setup.gd Ship look block
Pillar
LBL_LOOK_SHAPE_BLOOM | 12 | company_setup.gd Ship look block
Bloom
LBL_LOOK_SHAPE_RINGS | 12 | company_setup.gd Ship look block
Rings
LBL_LOOK_PALETTE_INFRARED | 16 | company_setup.gd Ship look block
Infrared
LBL_LOOK_PALETTE_IRONBOW | 16 | company_setup.gd Ship look block
Ironbow
LBL_LOOK_PALETTE_PLASMA | 16 | company_setup.gd Ship look block
Plasma
LBL_LOOK_PALETTE_ION | 16 | company_setup.gd Ship look block
Ion
LBL_LOOK_PALETTE_FUSION | 16 | company_setup.gd Ship look block
Fusion
LBL_LOOK_PALETTE_EMBER | 16 | company_setup.gd Ship look block
Ember
LBL_LOOK_PALETTE_ANTIMATTER | 16 | company_setup.gd Ship look block
Antimatter
LBL_LOOK_PALETTE_SUNFIRE | 16 | company_setup.gd Ship look block
Sunfire
LBL_LOOK_PALETTE_ARCTIC | 16 | company_setup.gd Ship look block
Arctic
LBL_LOOK_PALETTE_VOID | 16 | company_setup.gd Ship look block
Void
LBL_PREVIEW_PAUSE | 24 | ship_preview.gd turntable button
Stop rotation
LBL_PREVIEW_PLAY | 24 | ship_preview.gd turntable button
Rotate
LBL_PREVIEW_VIEW_ENGINES | 24 | ship_preview.gd camera button
Focus engines
LBL_PREVIEW_VIEW_SHIP | 24 | ship_preview.gd camera button
Whole ship
SETUP_NEED_NAME | 60 | company_setup.gd:210
Enter a company name to start.
SETUP_RANDOM | 24 | company_setup.gd:70
Random
SETUP_TITLE | 24 | company_setup.gd:50
New company
SK_EARN_LOCK | 90 | skill_tree.gd:141
Earn {need} credits from trade ({have}/{need}).
SK_LEARN_COST | 50 | skill_screen.gd learn_text
{verb}  ·  {amount} points
SK_LEARN_COST_ONE | 50 | skill_screen.gd learn_text
{verb}  ·  {amount} point
SS_FABRIC | 24 | good_info.gd:24
Fabric
SS_FABRIC_BUILD | 50 | space_storage_view.gd:111
Build fabric ({cost} cr)
ST_DEAD_EMPTY | 50 | route_engine.gd:175
This world is mined out.
ST_HUB_ALREADY | 60 | hubs.gd:91
This world is already a hub.
ST_HUB_EXPLAIN | 320 | hub_panel.gd, block under the title, always shown
A hub feeds the worlds around it for you. Give it ships from your free fleet. Each cycle it buys whatever those worlds are short of from the cheapest source in reach and delivers it, for the usual trip cost plus a small hub fee. Untick a world or a good to keep it in your own hands.
ST_HUB_FED_HUB | 24 | hubs.gd:205
Fed by hub
ST_HUB_FED_ROUTE | 40 | hubs.gd:203
Fed by your route
ST_HUB_FIRST_NOTICE | 40 | main.gd:2387
{planet} is now a hub.
ST_HUB_MAKE | 24 | planet_panel.gd:233
Make hub
ST_HUB_MAKE_TIP | 340 | planet_panel.gd:234, hub make button tooltip (also on the reason line)
Makes this world a hub: it keeps nearby worlds fed on its own. You add ships from your free fleet; each cycle the hub buys what those worlds lack and delivers it, never more than they need. Each delivery costs the trip plus a hub fee. One hub per system; it never draws on Space Storage.
ST_HUB_MANUAL | 24 | hub_panel.gd:163
Kept manual
ST_HUB_NONE_IN_REACH | 50 | hub_panel.gd:131
No worlds in reach yet.
ST_HUB_NO_WORLD | 30 | hubs.gd
No such world.
ST_HUB_OPEN | 24 | planet_panel.gd:223
Hub panel
ST_HUB_PANEL_TITLE | 30 | hub_panel.gd:87
Hub: {planet}
ST_HUB_POOL | 24 | hub_panel.gd _head call
Pool
ST_HUB_POOL_FREE | 30 | hub_panel.gd:118
Free ships: {n}
ST_HUB_POOL_SHIPS | 40 | hub_panel.gd:95
Ships in pool: {n}
ST_HUB_RELEASE | 24 | hub_panel.gd:136
Release hub
ST_HUB_RELEASE_PROMPT | 120 | hub_panel.gd:171
Release the hub at {planet}? Its ships return to your free fleet.
ST_HUB_SERVED | 30 | hub_panel.gd _head call
Worlds in reach
ST_HUB_SHORT_CASH | 30 | hubs.gd:211
Short: no cash
ST_HUB_SHORT_SHIP | 50 | hubs.gd:209
Short: no free ship in pool
ST_HUB_SHORT_SOURCE | 50 | hubs.gd:207
Short: no source in reach
ST_HUB_SYSTEM_FULL | 60 | hubs.gd:95
This system already has its hub.
ST_HUB_TIER | 80 | hubs.gd:93
The world must reach tier {tier} first.
TIP_HEADER | 24 | main.gd:5106
Tip
TITLE_SECOND_LANE | 40 | planet_panel.gd:125
Cross-system trader
WS_WHY_FULL | 30 | workshops.gd why_text
storage full
WS_WHY_NO_RECIPE | 24 | workshops.gd why_text (stalled reason)
no recipe
WS_WHY_PAUSED | 24 | workshops.gd why_text (stalled reason)
paused
WX_LEFT_SHORT | 24 | ui.gd:256
{n}c
WX_NAME_CLOSED | 24 | ui.gd:245
Closed
WX_NAME_PRICE_UP | 24 | ui.gd:243
Price up

## Production charter (T370, 2026-11-12; plain UI strings, no flavour; the _STACK and _SECOND notices are short stories, max 200)
Term: production charter. One charter boosts one world, for good. Not the Flagship boost (BTN_BOOST), a different thing.
PB_BTN | 24 | Planet card, under the goods grid, when a charter is held | Boost production
PB_TIP | 140 | Tooltip of PB_BTN | Spend your production charter here. Buy orders and storage room at {planet} grow for the rest of the run. One charter, one world.
PB_CONFIRM_TITLE | 32 | Confirm window title | Boost {planet}?
PB_CONFIRM_BODY | 110 | Confirm window body | This cannot be moved or undone.
PB_CONFIRM_OK | 24 | Confirm window, accept button | Boost
PB_TAG | 24 | Small tag by the name of a boosted world | Boosted
PB_TAG_TIP | 110 | Tooltip of PB_TAG | Buy orders and storage room here are larger, for the rest of the run.
PB_NOTICE_GAINED | 110 | Notice, a production charter is gained | You hold a production charter. Open a world's card to spend it.
PB_NOTICE_USED | 110 | Notice, a world is boosted | {planet} is boosted. Its Buy orders and storage room are larger for the rest of the run.
PB_NOTICE_STACK | 200 | Notice, a second charter is gained while one is still unspent | A second charter, and the first still unspent. The Bureau filed both under one number, to be tidy. Now two worlds must be named.
PB_NOTICE_SECOND_MIL | 200 | Notice, a second world is boosted, Military | A second yard, at {planet}. The depot clerk stamped it twice, once for the form and once for luck. The stamps are logged. The luck is not.
PB_NOTICE_SECOND_LUX | 200 | Notice, a second world is boosted, Luxury | {planet} now stocks for a second patron. Each believes she came first. The broker has seated them at opposite ends of one long ledger.
PB_NOTICE_SECOND_MIN | 200 | Notice, a second world is boosted, Minerals | {planet} gets a quota too. The crews at the first world want to know where the second was hiding. It was in a drawer.
PB_NOTICE_SECOND_BIO | 200 | Notice, a second world is boosted, Biotech | The vines at {planet} heard the news from the first world. They are not impressed. They are growing anyway.
