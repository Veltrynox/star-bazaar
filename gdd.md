Game Design Document - Forth Draft
Date: 21 October 2026

GIT: https://github.com/Veltrynox/star-bazaar/blob/main/gdd.md

========================================
1. EXECUTIVE SUMMARY / GAME SPECIFICITY
========================================

Oneliner: Star Bazaar is a single-player space trading game

Name: Star Bazaar
Genre: Space trading game
Engine: Godot 4 (GDScript)
Platforms: macOS

Core loop: Check prices, buy where a commodity is cheap, fly, sell where it is in
demand, and reinvest in ships and permits. Each new ship runs the same
loop as an automated route.

Win: the first time the cash balance is at least 9,000 credits at the end of any cycle, the game ends and the success story shows.

Loss: if the cash balance is still below 9,000 credits at the end of cycle 30, the game ends and the end screen shows the cash reached and the target.
========================================
2. GAME MECHANICS / PLAYER EXPERIENCE
========================================
The numbers come from a rough paper model built on the GDD’s fixed facts: [GCM:win_cycle] cycles of about [GCM:cycle_minutes] minutes each. They’re meant to give a working first pass for tuning in the debug menu, not final balance.

The game takes about an hour to complete. In game cycle lasts around [GCM:cycle_minutes] minutes. There are [GCM:win_cycle] cycles.
The player can pause the gave at any time.

Credits Inflow:
Trades
Events

Credits Outflow:
Ship maintenance - [GCM:maintenance] per ship, every [GCM:maintenance_interval] cycles
Trip cost - Every trade trip cost (we combine fuel price, crew price here just to keep less variables). [GCM:trip_cost]cr per leg.
Permits - One time purchase to open a new solar system.
Events

Mechanics:
Trades - Trade buy and sell resources
Permits - Solar systems access
Events - To bring some randomness and fun to the game.

Top bar:
Goal line: "Goal: [GCM:win_cash] by cycle [GCM:win_cycle]. Now: [cash balance]."

The game is mostly event and text driven, for now.

First 4 cycles (about 8 minutes) of the game:
The player reads the preface story. The game starts. We sees 3 Planets, a notification board on the right side with a mission hint.
"Buy a ship" mission text. The UI on top with some information: [GCM:starting_credits] starting credits. The planet highlights, the players clicks on it, a menu pop ups. This planet has an abundance of evergy abundance but not enough food. Under it there is a menu with a ship we can buy. The Player clicks on it and buys a ship. Mission complete. We see another menu that explains how to trade. The Player clicks on another Planet and sees that that the planet has abundnce of food but low energy supply. The Player buys energy cheaply at [GCM:energy_buy] per unit, on one planet and clicks on the second Planet and sells the energy for [GCM:energy_sell]cr. But the player can't simply sell and fly back, it would be a low cash flow that ship maitanance and trip cost will eat soon. The Player buys food cheaply for [GCM:food_buy]cr and flies back to sell it on Planet 1 where food sells for [GCM:food_sell]cr. The automated menu automatically asks if we want to establish an automated trade route. We hit yes. 

That's a profit of 8 per unit. With 20 units of cargo, 160 per leg, 320 per round trip. A round trip takes 2 cycles, so it costs 80 trip cost and 100 maintenance (50 per cycle), leaving about 140 per round trip.

After several cycles we have enough money to get a second ship. The Player can choose if it adds the ship to the existing route or create a new one. Too many ships eat the resources on the planet and increase the price of the resource. Too few give low cache flow. There is a cap of possible ships amount which is [GCM:ship_cap] ships max.

Automated routes:
−[GCM:saturation] sell price per extra ship on the same route

That's the code loop pretty much. I imagine the game to be a slow pased and builds up interest over time with more updates. I dont worry that the first prototype is just that. The working core loop.

Balance targets:
A decent player buys their 4th ship around cycle [GCM:target_4th_ship_cycle], gets the first permit around cycle [GCM:target_first_permit_cycle], and has [GCM:target_ships_range] ships by about cycle [GCM:target_8_ships_cycle]. That player's cash balance reaches [GCM:win_cash] around cycles [GCM:target_win_cycle_range].
A sloppy player stays on one route, overloads it, or skips permits. That player ends somewhere around [GCM:target_sloppy_cash_low]–[GCM:target_sloppy_cash_high] and loses. The loss condition matters without being punishing.
Selling and flying back empty still earns, but only half as much. One leg earns 160 and costs [GCM:trip_cost] to fly, so the ship makes 120 before maintenance. Carrying cargo both ways makes 240 per round trip before maintenance.
If players win before about cycle [GCM:check_early_win_cycle], raise the win threshold or the maintenance cost first.
f the second ship comes later than about cycle [GCM:check_second_ship_cycle], the tutorial pacing drags. Raise the margins slightly.
Expose all of these values in the debug menu. The QA bot runs can then check whether “always expand” and “never expand” strategies both lose. If one of them wins, it’s a dominant strategy.

Events:
Events can change the resource amount on the planet by [GCM:event_effect] and open and close some Planets temporarily. Events happen every [GCM:event_interval] cycles (about 7 events per game, roughly one every 8 minutes)

Menu UI:
Debug menu: "Debug and Game Control menus are removed from the release build"
Event control:
  How often events happen
  A list of events availaible
  Trigger an event
  Effect multiplier for events
Game Control menu:
  Balance values (v0.1): Change here to test. Each value is defined once in this section; the rest of the GDD refers to it as [GCM:key].
    cycle_minutes              2 minutes
    starting_credits           1,500
    ship_price                 1,000
    cargo                      20 units
    ship_cap                   8 ships
    energy_buy                 10
    energy_sell                18
    food_buy                   12
    food_sell                  20
    trip_cost                  40 per leg
    maintenance                150 per ship
    maintenance_interval       3 cycles
    saturation                 10%
    permit_2_cost              2,000
    permit_3_cost              4,000
    permit_margin_bonus        50%
    event_interval             4 cycles
    event_effect               ±10–25% or ±300–800 cr
    win_cycle                  30
    win_cash                   9,000
    pace_cycle_10_target       4,000
    pace_cycle_20_target       8,000
    pace_cycle_25_target       10,000
    upgrade_cost               1,000
    upgrade_margin_bonus       10%
  Balance targets (checks):
    target_4th_ship_cycle      9
    target_first_permit_cycle  13
    target_8_ships_cycle       18
    target_win_cycle_range     25–28
    permit_1_affordable_cycles 12–14
    check_early_win_cycle      22
    check_second_ship_cycle    6
    target_ships_range         7–8
    target_sloppy_cash_low     7,000
    target_sloppy_cash_high    10,000
    One cycle lasts:           2 minutes
    Travel time:               every leg takes 1 cycle

A Player makes money mostly from trades.

Planned features after we create the working core loop game.
Ship Upgrades (part of the core loop, the late-game spending option):
Once a ship is bought, the player can pay [GCM:upgrade_cost] credits to upgrade it. The upgrade adds +[GCM:upgrade_margin_bonus] margin per unit on that ship's route. Each ship can be upgraded once. Upgrades are optional.

Planned later: Space buildings trade posts.

The win condition:
Told in the beginnig of the game over a text menu. The Player has a dream to escape from society on its own planet. But in order to do that, the player needs money. The first time the cash balance (the credit figure in the top UI bar) is at least 9,000 credits at the end of a cycle, the game ends and the success story shows. If cash is still below 9,000 at the end of cycle 30 (about 1 hour in), the game ends with a loss.

Ship stats:
Ship price: [GCM:ship_price]cr
Cargo per ship: [GCM:cargo] units

Trade:
About 8 credits margin per unit. A round trip earns a margin of about 320 per ship (sales minus buying cost), before trip cost and maintenance.

Permits:
The first permit becomes affordable around cycle [GCM:permit_1_affordable_cycles]. New systems have about [GCM:permit_margin_bonus] better margins than the starter system, to reward expansion.
System 2: [GCM:permit_2_cost]cr. System 3: [GCM:permit_3_cost]cr
System 3 can only be bought after System 2.

========================================
3. AI ARCHITECTURE
========================================
I (me the owner) works in a claude code session. Claude leads and writes the main code. and subagents take bounded pieces of work in parallel.
The only game is be playing the build. Every step ends with something I can play and a short list of questions for me.
Build only the current step of the plan, no additional polish steps.

Agents:
Lead Designer - Claude Sonnet
  Role: The main overseer of the project that coordinates everyone else and reviews their work.
  Input: The JSON output of any other agent work's in md fortam. Will decide later on in more details.
  Output: JSON file for every other agent.
  Effect: Keeps and shapes the game to features that create stories players based on the GDD document.
  Weekly limits of the subscription: 1%
 
Producer - Claude Haiku
  Role: turns the GDD’s unlock schedule into an ordered, owned task queue so the second ship and first permit land on the days promised.
  Input: Schedule it creates and reviews.
  Output: Schedule every other agent has access to.
  Effect: Coordinates other agents to do their work on time and budget.
  Weekly limits of the subscription: 1.5%
 
Economy Designer - Claude Sonnet
  Role: tunes prices, so every trade stays profitable but never trivial from day 1.
  Input: Generated planet's data tables.
  Output: An updated data table with prices and stocks.
  Effect: Keeps planet's data up to date.
  Weekly limits of the subscription: 1.5%
 
UI Designer - Claude Sonnet
  Role: Creates UI panels for the game.
  Input: Game's GDD. Engine Files to write a code and work with UI.
  Output: UI spec - panel_id -> field bindings, status_icon map
  Effect: Makes game UI friendly and shape player's interaction experience.
  Weekly limits of the subscription: 4%
 
Galaxy Artist - Claude Sonnet
  Role: Background ART artist. For one specific effect in the game.
  Input: Game engine files.
  Output: Point cloud of galaxies with attributes for Godot.
  Weekly limits of the subscription: One time use basically. Not relevant.
 
Gameplay Programmer - Claude Sonnet
  Role: Programs all of the interaction of the player with the game and UI and internal logic of the game.
  Input: Task brief, relevant GDD sections, godot files, JSON data from other agents.
  Output: Godot files.
  Effect: ?? Creates the game backbone.
  Weekly limits of the subscription: 55%
 
Platform Engineer - Claude Haiku
  Role: configures the build and input mapping so the same game runs smoothly on macOS.
  Input: build_target macOS, frame_time_budget
  Output: platform build config, controller input map
  Effect: keeps the game smooth on macOS
  Weekly limits of the subscription: 2%
 
QA Tester - Claude Sonnet
  Role: runs nightly bot playthroughs and flags broken or unwinnable runs before they reach a human playtester.
  Input: nightly build, bot script, build log, bot script, last report
  Output: bug_report.json - run_id, issue_type, severity
  Effect: keeps unwinnable or broken runs out of what the player ever
  sees
  Weekly limits of the subscription: 2%

Budget controlling agent - Claude Haiku
  Role: Controls the weekly Claude pro limits
  Input: nothing, just claude pro acess to account's limints.
  Output: nothing
  Effects: It can block the work of agents if we are over the budget.
  Weekly limits of the subscription: 1%

========================================
4. CONSTRAINTS
========================================
Agents spend at most 70% of the weekly meter. The other 30% is reserved and never assigned to an agent.
Sonnet costs ~20x Haiku per token, so its 1.8M tokens are ~99% of the weekly cost in Section 3.
The Haiku agents together are small on the meter.

Hard stops (written into every agent prompt):
  - Stop when the task is done, not when time runs out.
  - Stop at the turn cap even if unfinished; write a handoff
  - Never re-read a file already read this session.
  - No exploratory work outside the task brief.
  - If a task looks bigger than its cap, stop and report the
    estimate to the Producer instead of starting.

Every agent ends its session with this envelope, in a JSON file:

  agent:          <agent name>
  date:           <YYYY-MM-DD>
  task:           <one line from the Producer's queue>
  status:         done | partial | blocked
  files_changed:  <list of paths>
  schema_version: <version of any JSON written>
  usage_note:     <rough % of meter used this session>
  open_questions: <max 3 bullets, or "none">
  handoff:        <max 150 words: what the next session needs>

Rules:
  - Data goes in JSON that matches the versioned schema
  - Prose summaries: max 200 words. No restating the GDD.
  - No invented fields, planets or values. Unknown -> write
    "UNKNOWN" and list it under open_questions.
  - Code (Programmer only): full files, no partial snippets,
    one file per change block.
  - Lead Designer reviews: keep / cut / change + one-line reason
    per item. Nothing else.

Pro limits come in 5-hour session windows plus the weekly meter, not
requests per minute. Plan around windows:

  - The Gameplay Programmer gets its own window. Nothing else runs
    in that window.
  - Haiku agents are batched: up to 4 per window, run in dependency
    order (Economy -> Producer -> UI -> QA).
  - Stop starting new agent work when a window passes ~80%; finish
    the current task and write the handoff.
  - Max 2 agent windows per day, leaving room for my own use.
  - If a window limit is hit mid-task, the agent's handoff is the
    restart point. No re-running from scratch.

Rules:
  - Start every session fresh with a brief: max 300 words plus the
    files listed above.
  - Programmer: start a new session when the task changes or the
    conversation gets long; carry over only the handoff.
  - GDD is sent in sections, never whole, except for the Lead
    Designer's Section 1-2.
  - Custom instructions per agent: max 150 words, kept in one file
    (agent_rules.md) so they are written once, not retyped.

Also a constraint is my own available time outside the course, which caps how many build iterations a week can realistically absorb.

========================================
5. ENGINE INTEGRATION
========================================
I'll use MCP and an agent that writes code directly to the game engine. That agent collects the output json file and makes necessary fixes.

Every agent's output is translated into a fixed, versioned JSON schema, and only that JSON
crosses into the engine. Gameplay programmer translates it to GODOT.

Galaxy generation: scatter a dense point cloud, bake a low-res 3D density grid
from it, pick the sun points, and propagate light from the suns
through the volume, dimmed by density. This runs once at scene
generation, so distant and occluded stars darken.