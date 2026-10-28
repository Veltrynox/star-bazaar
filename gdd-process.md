Star Bazaar: agent workflow, constraints and engine integration
Split out of gdd.md. Read only when your brief lists it. Sections keep their old numbers 3 to 5.

========================================
3. AI ARCHITECTURE
========================================
I (me the owner) works in a claude code session. Claude leads and writes the main code. and subagents take bounded pieces of work in parallel.
The only game is be playing the build. Every step ends with something I can play and a short list of questions for me.
Build only the current step of the plan, no additional polish steps.

Project brief (for every agent):
What it is: Star Bazaar is a single-player space trading game for macOS, built in Godot.

1. Producer - Claude Haiku
  Role: Plans the work. It turns the build plan into an ordered task queue, keeps schedule.json and state.md up to date, tracks the owner's meter and the 80% stop rule, advises which task runs next, and archives old handoffs. Finished tasks move to handoffs/archive/schedule-done.json to keep schedule.json small. The main session (the agent the owner talks to) is the owner's single point of contact and starts the work agents. The Producer may also start agents when the main session or the owner asks. A start only counts once the agent's handoff file exists, so the Producer must stay alive and check for the file before it ends. It never marks a task running or done without that evidence.
  Input: The GDD build steps, agent handoffs, the owner's meter report and requests from the main session.
  Output: A schedule.json file with the task, owner, dependencies and status for each item, a state.md file, and the archive of old handoffs.
  Effect: Work happens in the right order, the budget never runs out mid-task, and every status in the queue is backed by a handoff file and changed files.
  Weekly limits of the subscription: 2%
  Why it exists: Real studios have a producer, not a separate budget person. The budget controller is folded in here: the owner reads the meter and the Producer schedules around it. Status claims need file evidence because in two windows the Producer recorded agents as running when none were alive and no files had changed.

2. Systems & Economy Designer - Claude Sonnet
  Role: Owns every number in the game: prices, margins, maintenance, saturation, permits and event effects. It runs a headless paper simulation to test them.
  Input: The balance table, planet data and the QA reports.
  Output: A versioned balance.json file and a short note on what changed and why.
  Effect: Trading stays profitable but never trivial, and the win lands around cycles 25–28.
  Weekly limits of the subscription: 6%
  Why it exists: The whole game is an economy. If the numbers are wrong, no amount of code or art saves it.

3. Gameplay Programmer - Claude Sonnet
  Role: Writes all game code in GDScript: the core loop, routes, events, UI panels, the debug menu and the macOS export preset.
  Input: The task brief, the relevant GDD sections, balance.json and the Godot project files.
  Output: Complete Godot scripts and scenes, plus a playable build at the end of each step.
  Effect: Creates the backbone of the game, so every step ends with something the player can play.
  Weekly limits of the subscription: 40%
  Why it exists: Someone has to build the game. This agent also absorbs UI and platform work, because in Godot both are just scenes and project settings.

4. Technical Artist, Galaxy Builder - Claude Sonnet (essential)
  Role: Builds the galaxy background. It scatters a dense point cloud, bakes a low-res 3D density grid, picks the sun points and propagates their light through the volume once at scene generation.
  Input: The Godot project, the target look (map screenshot) and a performance budget for macOS.
  Output: A generator script, baked point and grid data, and the shader or material setup.
  Effect: Gives the game its signature look, where distant and hidden stars fall into darkness. The map reads as space, not a spreadsheet.
  Weekly limits of the subscription: 10%
  Why it exists: This is specialised tech-art work. It has no overlap with gameplay code, so it can run in parallel.

5. QA Analyst - Claude Haiku
  Role: Runs scripted bot playthroughs using several strategies: always expand, never expand, single route and optimal. It flags crashes, softlocks and dominant strategies.
  Input: The latest build, the bot scripts and the previous report.
  Output: A bug_report.json file with run_id, strategy, final cash, cycle reached, issue_type and severity.
  Effect: Broken or unwinnable runs never reach a human playtester, and balance claims are checked against real runs.
  Weekly limits of the subscription: 5%
  Why it exists: The agents that build and balance the game shouldn't grade their own work. Studios keep QA separate for exactly that reason.

The Producer keeps one rolling state.md file with only the last 5 handoffs.
The Producer moves older handoffs into an archive folder that no agent reads by default.
========================================
4. CONSTRAINTS
========================================
Agents together may use at most 68% of the weekly meter. The other 32% is reserved and never assigned to an agent.
The six agents' weekly limits in Section 3 add up to 68%: the four Sonnet agents hold 61% and the two Haiku agents hold 7%.

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

Pro limits come in 5-hour session windows plus the weekly meter, not
requests per minute. Plan around windows:

  - The Gameplay Programmer gets its own window. Nothing else runs
    in that window.
  - Agents are batched: up to 4 per window, run in this order:
    Economy Designer -> QA Analyst.
  - Stop starting new agent work when the owner reports a window has
    passed ~80%; finish the current task and write the handoff. No agent
    can read the meter, so the owner checks it. The Producer tracks this
    rule and advises; the main session starts the agents.
  - A task counts as running or done only when the agent's handoff file
    exists and its files_changed are real.
  - Max 2 agent windows per day, leaving room for my own use.
  - If a window limit is hit mid-task, the agent's handoff is the
    restart point. No re-running from scratch.

Rules:
  - Start every session fresh with a brief: max 300 words plus the
    files listed above.
  - Programmer: start a new session when the task changes or the
    conversation gets long; carry over only the handoff.
  - Agents do not read the whole GDD. Read only the gdd.md sections your brief lists, and take your task from the launch prompt (or `python3 tools/task.py <id>`), never the whole schedule.json.
  - Never read handoffs/archive/, gdd-log.md or gdd-process.md unless the brief says so.
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
