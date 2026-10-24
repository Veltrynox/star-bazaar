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
Source of truth: The numbers in this GDD are a starting point only. Once production starts, data/balance.json is the single source of truth for every balance value, and the Game Control menu reads and writes that file. Where this GDD and balance.json disagree, balance.json wins. [GCM:<key>] tokens in this GDD point to the balance.json key with the same name. This GDD is not updated with new numbers after production starts; the Economy Designer changes balance.json.

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
A sloppy player stays on one route, overloads it, or skips permits. That player stays below the win threshold and loses. The loss condition matters without being punishing.
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
  Starting values (v0.1). Each key matches a key in data/balance.json, which is the source of truth once production starts. The rest of the GDD refers to these keys as [GCM:<key>].
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
    travel_cycles_per_leg      1 cycle
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
    pace_cycle_10_target       3,000
    pace_cycle_20_target       6,000
    pace_cycle_25_target       7,500
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

Project brief (for every agent):
What it is: Star Bazaar is a single-player space trading game for macOS, built in Godot.

1. Creative Director - Claude Sonnet
  Role: Owns the vision and the GDD. Approves or rejects every other agent's output against it.
  Input: The GDD and each agent's JSON handoff.
  Output: A keep / cut / change verdict with a one-line reason per item, plus GDD updates.
  Effect: Keeps scope small and makes sure each build stays true to the "escape to your own planet" fantasy.
  Weekly limits of the subscription: 5%
  Why it exists: A studio needs one person with final say on design, or features drift.

2. Producer - Claude Haiku
  Role: Turns the build plan into an ordered task queue. It pauses new work when the owner reports that a window has passed about 80% of the meter.
  Input: The GDD build steps, agent handoffs and the owner's meter report.
  Output: A schedule.json file with the task, owner, dependencies and status for each item.
  Effect: Work happens in the right order and the budget never runs out mid-task.
  Weekly limits of the subscription: 2%
  Why it exists: Real studios have a producer, not a separate budget person. The budget controller is folded in here: the owner reads the meter and the Producer schedules around it.

3. Systems & Economy Designer - Claude Sonnet
  Role: Owns every number in the game: prices, margins, maintenance, saturation, permits and event effects. It runs a headless paper simulation to test them.
  Input: The balance table, planet data and the QA reports.
  Output: A versioned balance.json file and a short note on what changed and why.
  Effect: Trading stays profitable but never trivial, and the win lands around cycles 25–28.
  Weekly limits of the subscription: 6%
  Why it exists: The whole game is an economy. If the numbers are wrong, no amount of code or art saves it.

4. Gameplay Programmer - Claude Sonnet
  Role: Writes all game code in GDScript: the core loop, routes, events, UI panels, the debug menu and the macOS export preset.
  Input: The task brief, the relevant GDD sections, balance.json and the Godot project files.
  Output: Complete Godot scripts and scenes, plus a playable build at the end of each step.
  Effect: Creates the backbone of the game, so every step ends with something the player can play.
  Weekly limits of the subscription: 40%
  Why it exists: Someone has to build the game. This agent also absorbs UI and platform work, because in Godot both are just scenes and project settings.

5. Technical Artist, Galaxy Builder - Claude Sonnet (essential)
  Role: Builds the galaxy background. It scatters a dense point cloud, bakes a low-res 3D density grid, picks the sun points and propagates their light through the volume once at scene generation.
  Input: The Godot project, the target look (map screenshot) and a performance budget for macOS.
  Output: A generator script, baked point and grid data, and the shader or material setup.
  Effect: Gives the game its signature look, where distant and hidden stars fall into darkness. The map reads as space, not a spreadsheet.
  Weekly limits of the subscription: 10%
  Why it exists: This is specialised tech-art work. It has no overlap with gameplay code, so it can run in parallel.

6. QA Analyst - Claude Haiku
  Role: Runs scripted bot playthroughs using several strategies: always expand, never expand, single route and optimal. It flags crashes, softlocks and dominant strategies.
  Input: The latest build, the bot scripts and the previous report.
  Output: A bug_report.json file with run_id, strategy, final cash, cycle reached, issue_type and severity.
  Effect: Broken or unwinnable runs never reach a human playtester, and balance claims are checked against real runs.
  Weekly limits of the subscription: 5%
  Why it exists: The agents that build and balance the game shouldn't grade their own work. Studios keep QA separate for exactly that reason.

Keep one rolling state.md file with only the last 5 handoffs.
Move older handoffs into an archive folder that no agent reads by default.
========================================
4. CONSTRAINTS
========================================
Agents together may use at most 68% of the weekly meter. The other 32% is reserved and never assigned to an agent.
Sonnet costs ~20x Haiku per token. The four Sonnet agents hold 61% of the weekly budget in Section 3, and the two Haiku agents hold 7%.

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
  - Creative Director reviews: keep / cut / change + one-line reason
    per item. Nothing else.

Pro limits come in 5-hour session windows plus the weekly meter, not
requests per minute. Plan around windows:

  - The Gameplay Programmer gets its own window. Nothing else runs
    in that window.
  - Agents are batched: up to 4 per window, run in this order:
    Economy Designer -> Creative Director -> QA Analyst.
  - Stop starting new agent work when the owner reports a window has
    passed ~80%; finish the current task and write the handoff. No agent
    can read the meter, so the owner checks it.
  - Max 2 agent windows per day, leaving room for my own use.
  - If a window limit is hit mid-task, the agent's handoff is the
    restart point. No re-running from scratch.

Rules:
  - Start every session fresh with a brief: max 300 words plus the
    files listed above.
  - Programmer: start a new session when the task changes or the
    conversation gets long; carry over only the handoff.
  - Agents read the whole GDD. The scope is small enough for that.
  - Agent instructions live in .claude/agents/<name>.md, one file per
    agent, written once and not retyped.

Also a constraint is my own available time outside the course, which caps how many build iterations a week can realistically absorb.

========================================
5. ENGINE INTEGRATION
========================================
The Gameplay Programmer and the Galaxy Builder write into the Godot project, using MCP. The Gameplay Programmer collects the other agents' JSON output and makes the necessary fixes.

Every agent's output is translated into a fixed, versioned JSON schema, and only that JSON
crosses into the engine.

Galaxy generation: scatter a dense point cloud, bake a low-res 3D density grid
from it, pick the sun points, and propagate light from the suns
through the volume, dimmed by density. This runs once at scene
generation, so distant and occluded stars darken.