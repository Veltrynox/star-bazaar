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
SCR_PREFACE | 700 | Preface screen
Everything under this sky is shared, and counted. Every credit goes into the Common Ledger and comes back in portions. The Plan is generous. It is also five cycles long, and then another five.

You run a small trading company. You start with one home world, one ship's worth of cash and a scout that finds other worlds. Ships fly your routes by themselves. You choose where to invest.

Worlds grow when their needs are met. Raise one into a capital and build the Star Bazaar there, stage by stage. Open it with a final delivery before your term ends. Pick one market to lean on: Military, Luxury, Minerals or Biotech. Three houses send weather, not war.

What it costs the sky, the sky does not say.
SCR_PREFACE_BTN | 24 | Preface screen, continue button
Sign here, and here

## Main menu (title screen buttons)
MENU_CONTINUE | 24 | Main menu, loads the saved game | Continue
MENU_NEW_GAME | 24 | Main menu, starts a new run | New game
MENU_CONFIRM_NEW | 110 | Confirmation dialog, new game while a saved game exists | Start a new game?
NOT_NO_SAVE | 110 | Main menu, Continue with no saved game | No saved game yet.
MENU_HINT_CONTINUE_OFF | 110 | Main menu, hint on a disabled Continue | Continue needs a saved game.
BTN_SKIP_TUTORIAL_ON | 24 | Main menu, same toggle once pressed | Tutorial: skipped
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
TUT_G7_STORAGE | 60 | Guided step 7, storage | The lit colour is stock in Company storage.
TUT_G7_STORAGE_WHY | 110 | Guided step, why it matters (second line of the card) | Stored/capacity shows how much it holds. When it is full, Buy waits. Press Next.
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
- TIP_GOAL: the guided tutorial ends or is skipped.
- TIP_TIER1: the first world reaches tier 1.
- TIP_TAX: the first cycle in which worlds pay tax.
- TIP_RESTLESS: the first world turns Restless.
- TIP_HUNGRY: the first Hungry chip appears on a need row.
- TIP_CAPITAL: the first world reaches the capital tier.
- TIP_HUB: the first world can be made a hub (same moment as TIP_CAPITAL today; show TIP_CAPITAL first).
- TIP_FOUNDED: the Bazaar is founded.
- TIP_OPENING: the last Bazaar stage is done and the Opening gig appears.
- TIP_PLATFORM: the Flagship first arrives at a dead world.
- TIP_EXPLORE: the Ships panel is opened for the first time while an unknown world is left in the system.
- TIP_DOCK: the dock sheet opens for the first time.
- TIP_BOOST: the Flagship first flies with energy in its hold.
- TIP_GIG: the first gig appears on the board.
- TIP_RUSH: the first rush order appears.
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
TIP_GOAL | 110 | Tip card line; trigger: the guided tutorial ends or is skipped | Holding a market does not win. Only a finished Star Bazaar does.
TIP_GOAL_WHY | 110 | Tip card, why line | Open the Bazaar panel: it founds the Bazaar on a capital world, then shows each stage and what is short.
TIP_CAPITAL | 110 | Tip card line; trigger: the first world reaches the capital tier | A world has reached the capital tier. You can found the Star Bazaar there. It is final.
TIP_CAPITAL_WHY | 110 | Tip card, why line | A run has one capital. Choose with care, then press Found the Bazaar here on the world's panel.
TIP_FOUNDED | 110 | Tip card line; trigger: the Bazaar is founded | The Bazaar is built in stages. Each needs goods in the capital's storage and other worlds at a tier.
TIP_FOUNDED_WHY | 110 | Tip card, why line | The Bazaar panel shows what is short. A later stage needs a world in another system.
TIP_OPENING | 110 | Tip card line; trigger: the last Bazaar stage is done and the Opening gig appears | The last stage posts the Opening: a gig to fly the charter cargo to the capital.
TIP_OPENING_WHY | 110 | Tip card, why line | Accept it on the gig board (J), then dock at the capital. That opens the Star Bazaar and wins the run.

### Prosperity
TIP_TIER1 | 110 | Tip card line; trigger: the first world reaches tier 1 | Your first world has grown a tier. Worlds grow when your sales meet their needs.
TIP_TIER1_WHY | 110 | Tip card, why line | Each tier opens more and leads to a capital. Open a world card to see what it needs next.
TIP_TAX | 110 | Tip card line; trigger: the first cycle in which worlds pay tax | Grown worlds pay tax at the end of each cycle. The credits are added to your cash.
TIP_TAX_WHY | 110 | Tip card, why line | More tiers mean more tax. Keep worlds supplied so they keep growing.
TIP_RESTLESS | 110 | Tip card line; trigger: the first world turns Restless | A Restless world is losing growth progress because one of its needs is short.
TIP_RESTLESS_WHY | 110 | Tip card, why line | Sell it the short good, or send stock there. Meeting every need stops the loss.
TIP_HUNGRY | 110 | Tip card line; trigger: the first Hungry chip appears on a need row | Hungry means a need is short and its price is up. Surplus means sales passed demand.
TIP_HUNGRY_WHY | 110 | Tip card, why line | Send goods to a Hungry world first. It pays more and your sale fills the need.
TIP_HUB | 110 | Tip card line; trigger: the first world can be made a hub (right after TIP_CAPITAL) | A hub keeps the worlds near it fed, using ships from its own pool.
TIP_HUB_WHY | 110 | Tip card, why line | One hub per system. Press Make this a hub, then add ships. Each delivery adds a hub fee.

### Discovery and the Flagship
TIP_PLATFORM | 110 | Tip card line; trigger: the Flagship first arrives at a dead world | A dead world takes a mining platform, not a trading post.
TIP_PLATFORM_WHY | 110 | Tip card, why line | Once it stands you can mine there and route what it gives. Mining needs the right skill.
TIP_EXPLORE | 110 | Tip card line; trigger: the Ships panel is opened first while an unknown world is left in the system | Exploration mode flies the Flagship to each unknown world here and builds its post.
TIP_EXPLORE_WHY | 110 | Tip card, why line | Each post costs credits, so it waits at a world while cash is short. Press the button again to stop.
TIP_DOCK | 110 | Tip card line; trigger: the dock sheet opens for the first time | Dock and trade lets the Flagship buy and sell by hand. Its hold has limited room.
TIP_DOCK_WHY | 110 | Tip card, why line | Unload to storage moves goods into Company storage here. Time is paused while you are docked.
TIP_BOOST | 110 | Tip card line; trigger: the Flagship first flies with energy in its hold | Boost burns energy from the hold for a short burst of speed. Hold B to use it.
TIP_BOOST_WHY | 110 | Tip card, why line | Use it on straight legs to beat a deadline. Turning stays slow, and charges refill slowly.

### Gigs
TIP_GIG | 110 | Tip card line; trigger: the first gig appears on the board | The gig board (J) lists offers for the Flagship. Accept one to get a map marker.
TIP_GIG_WHY | 110 | Tip card, why line | Compare ETA with the deadline before you accept. You can take one gig at a time.
TIP_RUSH | 110 | Tip card line; trigger: the first rush order appears | A rush order: a world wants a good before a deadline. Deliver it by hand to be paid.
TIP_RUSH_WHY | 110 | Tip card, why line | Dock there and sell it, or unload it. You get a premium and the world's need is filled.

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
TIP_SPACE_STORAGE_WHY | 110 | Tip card, why line | Sell orders and routes draw on it when planet storage is empty. Click its station to see stock.
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
SS_LBL_STOCK_RULE | 110 | Space Storage view, under the capacity line: the rule for delivered goods | Everything delivered here stays in stock until a Sell order in this system, a recipe or upkeep uses it.
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
BTN_TUT_FINISH | 24 | Tutorial card, last card only, replaces Skip tutorial; ends the tutorial, tips go on | Finish
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
LBL_COMP_TITLE | 24 | House weather menu heading, game menu entry and panel button (was Competitors) | House weather
LBL_COMP_SHARE | 24 | House weather table column, what the house sends next | Next weather
LBL_COMP_TREND | 24 | House weather table column, the last weather the house sent | Recent weather

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
NOT_SKILL_REASON_SHARE | 110 | Notice, a skill point earned when a market share passes a step; {market} is the market, {pct} the step | Your {market} share passed {pct}%.

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

### LUX_A1 (Luxury, chain A, step 1)
EV_LUX_A1_TITLE | 40 | LUX_A1 choice screen title | A patron wants every first crate
EV_LUX_A1_BODY | 280 | LUX_A1 choice screen body (one body) | Madame Ysolde Marr, a patron on Quillon's gallery ring, wants the first crate of each cycle before any other buyer. She says a crate picks its owner by smell. {bot2} supplies her now, and {bot3} keeps a counter on the same ring. Set a first-pick price, or sell one first lot.
EV_LUX_A1_OPA_BTN | 28 | LUX_A1 button, opt_a | Set a first-pick price
EV_LUX_A1_OPA_EFF | 200 | LUX_A1 effect line, opt_a | Get: Luxury price up a little for a while. Cost: Luxury volume down a little for a while. Weather: {bot2}'s next weather lands a little softer.
EV_LUX_A1_OPA_RES_TITLE | 32 | LUX_A1 result popup title, opt_a | The first pick is priced
EV_LUX_A1_OPA_RES | 280 | LUX_A1 result popup, opt_a; {bot} is bot_2 | Madame Marr agreed a first-pick price, and crates now go to the gallery ring before the shelves. Fewer reach the counters, so Luxury volume dips for a while, and prices rise a little. {bot} lost her first look, and its next weather lands a little softer. She sniffed every lid.
EV_LUX_A1_OPA_STD | 90 | LUX_A1 house line 1, opt_a | {bot2}: next weather lands a little softer.
EV_LUX_A1_OPB_BTN | 28 | LUX_A1 button, opt_b | Sell one first lot
EV_LUX_A1_OPB_EFF | 200 | LUX_A1 effect line, opt_b | Get: {cash_in} credits now. Cost: Luxury volume down a little for a few cycles; {bot2}'s next weather comes a little sooner. Weather: {bot3}'s next weather lands a little softer.
EV_LUX_A1_OPB_RES_TITLE | 32 | LUX_A1 result popup title, opt_b | The first lot is sold
EV_LUX_A1_OPB_RES | 280 | LUX_A1 result popup, opt_b; {bot} is bot_3 | Madame Marr paid for one first lot at the dock, and the cash arrived the same hour. Shelves stood bare for a few cycles. {bot2} supplied her next lot, so its weather comes a little sooner, while {bot} finds its counter on the ring emptier and its weather lands a little softer.
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
LBL_COMP_EVENTS | 24 | House weather menu, heading of the log of changes your choices made | Weather changes
LBL_COMP_NONE | 40 | House weather menu, log is empty | No weather changes yet.
LBL_COMP_MOVE_STR_DOWN | 60 | House weather log line, a house sends softer weather; also used for a held-back cut at the lowest step | {bot}: next weather lands softer
LBL_COMP_MOVE_STR_UP | 60 | House weather log line, a house sends harder weather | {bot}: next weather lands harder
LBL_COMP_MOVE_GRO_DOWN | 60 | House weather log line, a house sends its weather later | {bot}: next weather comes later
LBL_COMP_MOVE_GRO_UP | 60 | House weather log line, a house sends its weather sooner | {bot}: next weather comes sooner
LBL_COMP_MOVE_TIER_DOWN | 60 | House weather log line, a house has its next weather held back | {bot}: next weather held back
LBL_COMP_CYCLE | 16 | House weather log line, prefix with the cycle of the move | Cycle {n}:

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
LBL_HERO_STATE_IDLE | 24 | Ships menu hero card, state line, ship waiting | Idle
LBL_HERO_STATE_FLYING | 24 | Ships menu hero card, state line, ship flying | Flying
LBL_HERO_STATE_BUILDING | 24 | Ships menu hero card, state line, ship building a post | Building
LBL_HERO_HINT | 60 | Ships menu hero card, tooltip: click selects the ship, then click the map to send it | Click to select. Then click the map to fly.
LBL_HERO_SELECTED | 24 | Ships menu hero card, extra word on the state line while selected | Selected
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
TUT_G0_FLY | 60 | Guided step 0, until the Pathfinder has reached the nearby world | Right-click {planet}, choose Establish a trading post.
TUT_G0_FLY_WHY | 110 | Guided step, why it matters (second line of the card) | The Pathfinder flies there by itself and builds the post. Your first one is free.
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
WORLD_SYS4_NAME | 24 | System 4 name (placeholder) | TEMPORARY B
WORLD_SYS4_DESC | 110 | System 4 description (placeholder, off) | Temporary text for a far system. It is not open yet.
PERMIT_S4_NAME | 24 | Permit list, system 4 entry (placeholder) | Permit: TEMPORARY B
PERMIT_S4_DESC | 110 | Permit list, system 4 description (placeholder) | Temporary text. Opens TEMPORARY B for routes.
PERMIT_S4_BTN | 24 | Permit list, buy button, system 4 (placeholder) | Buy permit
NOT_PERMIT_S4 | 110 | Notice, permit for system 4 bought (placeholder) | Permit bought. TEMPORARY B is open: three new planets.
WORLD_S4P1_NAME | 24 | System 4 planet 1 (placeholder) | Temp B1
WORLD_S4P1_DESC | 110 | Planet 1 of system 4, tooltip (placeholder) | Temporary planet text.
WORLD_S4P2_NAME | 24 | System 4 planet 2 (placeholder) | Temp B2
WORLD_S4P2_DESC | 110 | Planet 2 of system 4, tooltip (placeholder) | Temporary planet text.
WORLD_S4P3_NAME | 24 | System 4 planet 3 (placeholder) | Temp B3
WORLD_S4P3_DESC | 110 | Planet 3 of system 4, tooltip (placeholder) | Temporary planet text.
WORLD_SYS5_NAME | 24 | System 5 name (placeholder) | TEMPORARY C
WORLD_SYS5_DESC | 110 | System 5 description (placeholder, off) | Temporary text for a far system. It is not open yet.
PERMIT_S5_NAME | 24 | Permit list, system 5 entry (placeholder) | Permit: TEMPORARY C
PERMIT_S5_DESC | 110 | Permit list, system 5 description (placeholder) | Temporary text. Opens TEMPORARY C for routes.
PERMIT_S5_BTN | 24 | Permit list, buy button, system 5 (placeholder) | Buy permit
NOT_PERMIT_S5 | 110 | Notice, permit for system 5 bought (placeholder) | Permit bought. TEMPORARY C is open: three new planets.
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
- NEXTUP_LBL_GROWTH, NEXTUP_LBL_BAZAAR, NEXTUP_LBL_BEST: slot labels. NEXTUP_GROWTH: {planet}, {need}. NEXTUP_GROWTH_LOCKED: {planet}, {skill}. NEXTUP_BAZAAR_BILL: {amount}, {commodity}. NEXTUP_BAZAAR_QUORUM: {n}. NEXTUP_BAZAAR_FOUND: {planet}. NEXTUP_BEST_LANE: {planet_a}, {planet_b}. NEXTUP_BEST_CASH: {cash}, {cycles}. NEXTUP_BEST_GIG, NEXTUP_IDLE: none.
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
NEXTUP_BEST_GIG | 60 | Slot 3, a flight job is open | Take a flight job
NEXTUP_IDLE | 60 | Any slot with nothing to show | Keep trading. Check the planet cards.

## Flagship, dock sheet, gig board and rush orders (T275, 2026-11-06; Phase 2)
The Pathfinder becomes the Flagship: same scout, now with a small hold. The old LBL_PATHFINDER_* and NOT_PATHFINDER_* ids stay until the programmer swaps them for the FLAGSHIP ids below; the notices in the Pathfinder block that say "Pathfinder" should then use {ship} (the game fills the Flagship name) or the FLAGSHIP_NAME text. Goods in rush texts come only through {commodity}, a visible good; the game never fills a hidden one. Boost burns energy, which is visible from the start. Placeholders: {planet}, {commodity}, {amount}, {cash}, {cycles}, {n}, {m}.

FLAGSHIP_NAME | 24 | Ship panel, map tooltip, dock sheet title: name of the player's own ship (replaces LBL_PATHFINDER_NAME) | Tessarine
FLAGSHIP_DESC | 110 | Ship panel, one line under the name | Your own ship. It scouts, builds posts, carries a small hold and takes gigs.
FLAGSHIP_FLYING | 60 | Top bar or ship panel, flying to a known planet; {planet} (replaces LBL_PATHFINDER_FLYING) | Tessarine flying to {planet}
FLAGSHIP_IDLE | 60 | Ship panel, not flying and not building (replaces LBL_PATHFINDER_IDLE) | Tessarine waiting
FLAGSHIP_DOCKED | 60 | Ship panel, docked at a world; {planet} | Tessarine docked at {planet}
LBL_HOLD | 24 | Ship panel and dock sheet, the Flagship's hold | Hold
LBL_HOLD_FILL | 40 | Ship panel readout; {n} units held, {m} room in total | Hold: {n} of {m}
LBL_HOLD_EMPTY | 24 | Dock sheet, a hold row with nothing in it | Empty
BTN_DOCK | 24 | Planet panel and right-click menu, opens the dock sheet (the Flagship must be at an established world) | Dock and trade
LBL_DOCK_TITLE | 40 | Dock sheet heading; {planet} | Dock at {planet}
LBL_DOCK_HOLD | 24 | Dock sheet, column or block heading for the hold | In the hold
LBL_DOCK_WORLD | 24 | Dock sheet, column or block heading for the world's market | At this world
BTN_DOCK_BUY | 24 | Dock sheet, buys one lot of the row's good into the hold | Buy
BTN_DOCK_SELL | 24 | Dock sheet, sells one lot of the row's good from the hold | Sell
BTN_DOCK_BUY_MAX | 24 | Dock sheet, buys as much as cash and room allow | Buy max
BTN_DOCK_SELL_ALL | 24 | Dock sheet, sells the whole row | Sell all
BTN_UNLOAD_STORAGE | 24 | Dock sheet, moves the row from the hold to Company storage here | Unload to storage
BTN_LOAD_STORAGE | 24 | Dock sheet, moves goods from Company storage here into the hold | Load from storage
BTN_DOCK_CLOSE | 24 | Dock sheet, closes it and lets the clock run | Undock
LBL_DOCK_PAUSED | 60 | Dock sheet, small line: time stands still while it is open | Time is paused while you are docked.
LBL_DOCK_CASH | 24 | Dock sheet, label before the player's credits count | Credits
LBL_DOCK_STORAGE_ROW | 40 | Dock sheet, the Company storage line of a good; {n} units | Company storage: {n}
NOT_DOCK_NO_CASH | 110 | Notice, Buy refused for lack of credits | Not enough credits to buy that.
NOT_DOCK_HOLD_FULL | 110 | Notice, Buy refused or cut short because the hold is full | The hold is full. Sell or unload first.
NOT_DOCK_STORAGE_FULL | 110 | Notice, Unload refused or cut short because Company storage here is full | Company storage here is full.
NOT_DOCK_NO_STOCK | 110 | Notice, Load refused because Company storage here has none of that good | Company storage here has none of that.
NOT_DOCK_NO_POST | 110 | Notice, dock pressed at a world with no trading post | Establish a trading post here to dock and trade.
NOT_DOCK_FAR | 110 | Notice, dock pressed while the Flagship is away from the world | Fly the Flagship here first.
NOT_DOCK_NO_BUYER | 110 | Notice, Sell pressed on a good the world does not buy | This world does not buy that.
LBL_DOCK_HOLD_FULL | 60 | Dock sheet, line under the hold when it is full | The hold is full. Buy is limited to the room left.
BTN_BOOST | 24 | Ship panel and flight hud, boost button (also a held key) | Boost
LBL_BOOST_HINT | 110 | Tooltip of the boost button | Faster on straight legs. Burns energy from the hold. Turning stays slow.
LBL_BOOST_CHARGES | 40 | Flight hud, boost gauge; {n} charges left | Boost: {n} left
NOT_BOOST_NO_ENERGY | 110 | Notice, boost pressed with no energy in the hold | No energy in the hold to boost.
NOT_BOOST_EMPTY | 110 | Notice, boost pressed with no charge left | Boost is recharging.
LBL_GIG_BOARD_TITLE | 24 | Gig board heading | Gig board
LBL_GIG_BOARD_EMPTY | 60 | Gig board with no open offers | No open gigs. New ones come with the cycles.
LBL_GIG_SIGNAL | 24 | Gig board, tag on a signal offer | Signal
LBL_GIG_RUSH | 24 | Gig board, tag on a rush order | Rush order
LBL_GIG_ETA | 40 | Gig board row; {cycles} flight time from the Flagship | ETA: {cycles} cycles
LBL_GIG_DEADLINE | 40 | Gig board row; {cycles} cycles left to deliver | Deadline: {cycles} cycles
LBL_GIG_PREMIUM | 40 | Gig board row of a rush order; {cash} credits paid on delivery | Premium: {cash} credits
LBL_GIG_TOO_FAR | 60 | Gig board row when the ETA is longer than the deadline | The Flagship cannot make it in time.
BTN_GIG_ACCEPT | 24 | Gig board row, takes the offer and drops a map marker | Accept
BTN_GIG_ABANDON | 24 | Gig board row of the taken gig, gives it up | Give up
BTN_GIG_FLY | 24 | Gig board row of the taken gig, sends the Flagship at once | Fly there
NOT_GIG_ACCEPTED | 110 | Notice, a gig was accepted | Gig accepted. A marker shows the way.
NOT_GIG_ONE_AT_A_TIME | 110 | Notice, accept pressed while a gig is already taken | One gig at a time. Finish or give up the one you have.
NOT_GIG_ABANDONED | 110 | Notice, a gig was given up | Gig given up.
NOT_GIG_NEW | 60 | Notice, a new offer reached the board | A new gig is on the board.
GIG_RUSH_TITLE | 32 | Gig board row and marker tooltip of a rush order; {planet} | Rush to {planet}
GIG_RUSH_HOOK | 110 | Gig board row of a rush order, one line; {planet}, {commodity}, {cycles} | {planet} needs {commodity}. Deliver within {cycles} cycles.
GIG_RUSH_HOOK_RESTLESS | 110 | Same, when the world is Restless | {planet} is Restless and short of {commodity}. Deliver within {cycles} cycles.
GIG_RUSH_HOOK_TIER | 110 | Same, when the world is close to its next tier | {planet} is close to growing. It needs {commodity} within {cycles} cycles.
GIG_RUSH_HOOK_SHORT | 110 | Same, when a shortage hit the world | A shortage hit {planet}. It needs {commodity} within {cycles} cycles.
GIG_RUSH_ARRIVE | 110 | Dock sheet banner when the Flagship is docked at the rush world; {commodity} | This world has a rush order for {commodity}. Sell it here to deliver.
NOT_RUSH_DELIVERED | 110 | Notice, rush delivered; {planet}, {commodity} | Delivered. {planet} has its {commodity}. The premium is paid.
NOT_RUSH_PARTIAL | 110 | Notice, part of a rush lot delivered; {planet}, {commodity} | Part delivered. {planet} still needs more {commodity}.
NOT_RUSH_EXPIRED | 110 | Notice, the deadline passed; {planet} | The rush order for {planet} has expired.
NOT_RUSH_GONE | 110 | Notice, the world no longer needs the good before the deadline | {planet} no longer needs that. The rush order is closed.
LBL_RUSH_DELIVERED_STAMP | 24 | Stamp on the world's need row after a delivery | Delivered

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
BAZ_WING_2B_LINE | 110 | Same | Workshops craft for less.
BAZ_WING_3A_NAME | 24 | Stage 3, choice A | Wing of Lamps
BAZ_WING_3A_LINE | 110 | Same | House weather lands softer on your worlds.
BAZ_WING_3B_NAME | 24 | Stage 3, choice B | Wing of Couriers
BAZ_WING_3B_LINE | 110 | Same | Gigs pay a bigger premium.

### Recap
RECAP_TITLE | 40 | End screen, heading of the recap | The run in brief
RECAP_LBL_CAPITAL | 24 | Recap label | Capital
RECAP_LBL_STAGES | 24 | Recap label | Stages built
RECAP_LBL_WINGS | 24 | Recap label | Wings
RECAP_LBL_WORLDS | 24 | Recap label | Worlds grown
RECAP_LBL_RECLAIMED | 24 | Recap label | Reclaimed worlds
RECAP_LBL_MOMENTS | 24 | Recap label, heading of the list of the choices that decided the run | Decisive moments
RECAP_NONE | 24 | Recap value when there is nothing to list | None
