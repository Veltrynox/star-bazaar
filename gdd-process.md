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
  Role: Plans the work. It turns the build plan into an ordered task queue, keeps schedule.json and state.md up to date, advises which task runs next, archives old handoffs, and writes each goal's log.md and report.md. Finished tasks move to handoffs/archive/schedule-done.json to keep schedule.json small. The main session (the agent the owner talks to) is the owner's single point of contact and starts the work agents. The Producer may also start agents when the main session or the owner asks. A start only counts once the agent's handoff file exists, so the Producer must stay alive and check for the file before it ends. It never marks a task running or done without that evidence.
  Input: The GDD build steps, agent handoffs, goal blackboards and requests from the main session.
  Output: A schedule.json file with the task, owner, dependencies and status for each item, a state.md file, and the archive of old handoffs.
  Effect: Work happens in the right order, and every status in the queue is backed by a handoff file and changed files.
  Why it exists: Real studios have a producer. Status claims need file evidence because in two windows the Producer recorded agents as running when none were alive and no files had changed.

2. Systems & Economy Designer - Claude Sonnet
  Role: Owns every number in the game: prices, margins, maintenance, permits and event effects. It runs a headless paper simulation to test them.
  Input: The balance table, planet data and the QA reports.
  Output: A versioned balance.json file and a short note on what changed and why.
  Effect: Trading stays profitable but never trivial, and the win lands around cycles 25–28.
  Why it exists: The whole game is an economy. If the numbers are wrong, no amount of code or art saves it.

3. Gameplay Programmer - Claude Sonnet
  Role: Writes all game code in GDScript: the core loop, routes, events, UI panels, the debug menu and the macOS export preset.
  Input: The task brief, the relevant GDD sections, balance.json and the Godot project files.
  Output: Complete Godot scripts and scenes, plus a playable build at the end of each step.
  Effect: Creates the backbone of the game, so every step ends with something the player can play.
  Why it exists: Someone has to build the game. This agent also absorbs UI and platform work, because in Godot both are just scenes and project settings.

4. Technical Artist, Galaxy Builder - Claude Sonnet (essential)
  Role: Builds the galaxy background. It scatters a dense point cloud, bakes a low-res 3D density grid, picks the sun points and propagates their light through the volume once at scene generation.
  Input: The Godot project, the target look (map screenshot) and a performance budget for macOS.
  Output: A generator script, baked point and grid data, and the shader or material setup.
  Effect: Gives the game its signature look, where distant and hidden stars fall into darkness. The map reads as space, not a spreadsheet.
  Why it exists: This is specialised tech-art work. It has no overlap with gameplay code, so it can run in parallel.

5. QA Analyst - Claude Haiku
  Role: Runs scripted bot playthroughs using several strategies: always expand, never expand, single route and optimal. It flags crashes, softlocks and dominant strategies.
  Input: The latest build, the bot scripts and the previous report.
  Output: A bug_report.json file with run_id, strategy, final cash, cycle reached, issue_type and severity.
  Effect: Broken or unwinnable runs never reach a human playtester, and balance claims are checked against real runs.
  Why it exists: The agents that build and balance the game shouldn't grade their own work. Studios keep QA separate for exactly that reason.

6. Story Designer - Claude Sonnet
  Role: Owns the story and voice: story/*.md (title and preface, event texts, win, loss and ending screens, skill names and descriptions) and keeps every text in one voice. It does not set mechanics or numbers.
  Input: The GDD story section, story/game-flow.md and the balance keys that a text refers to.
  Output: Edited story/*.md files; tools/build_story.py generates the data files from them.
  Effect: The player reads one consistent world, and the endings follow the skills learned.
  Why it exists: Story text is a separate craft from balance and code, and it needs its own owner.

7. Documentation (General-purpose agent)
  Role: Writes and reconciles the GDD (gdd.md, gdd-skills.md, gdd-process.md), the GDD change log and the task handoffs when a task asks for it. There is no doc-manager agent; the Creative Director and Documentation Manager roles were removed on 2026-10-26, and the doc-manager is replaced by a general-purpose agent (owner decision, 2026-10-27).
  Input: The task brief from tools/task.py and only the GDD sections the brief names.
  Output: Edited GDD files with one change-log entry per edit, and a handoff file under handoffs/general-purpose/.
  Effect: The GDD matches the built game, and planned items are marked as planned.
  Why it exists: The GDD must be kept current without a design agent of its own. Numbers stay in data/balance.json; the GDD only points to them.

The Producer keeps one rolling state.md file with only the last 5 handoffs.
The Producer moves older handoffs into an archive folder that no agent reads by default.
========================================
4. CONSTRAINTS
========================================
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
  open_questions: <max 3 bullets, or "none">
  handoff:        <max 150 words: what the next session needs>

Rules:
  - Data goes in JSON that matches the versioned schema
  - Prose summaries: max 200 words. No restating the GDD.
  - No invented fields, planets or values. Unknown -> write
    "UNKNOWN" and list it under open_questions.
  - Code (Programmer only): full files, no partial snippets,
    one file per change block.

  - A task counts as running or done only when the agent's handoff file
    exists and its files_changed are real.
  - If a session stops mid-task, the agent's handoff is the restart
    point. No re-running from scratch.

Goal log:
  - The goals/ folder is gone. What each /goal run did is kept in
    schedule.json under "goal_log" (goal, dates, report lines, step log).
  - The Producer, or the main session, adds an entry there when a goal
    finishes, then links it from state.md.

Rules:
  - Start every session fresh with a brief: max 300 words plus the
    files listed above.
  - Programmer: start a new session when the task changes or the
    conversation gets long; carry over only the handoff.
  - Agents do not read the whole GDD. Read only the gdd.md sections your brief lists, and take your task from the launch prompt (or `python3 tools/task.py <id>`), never the whole schedule.json.
  - Never read handoffs/archive/ or gdd-process.md unless the brief says so.
  - Agent instructions live in .claude/agents/<name>.md, one file per
    agent, written once and not retyped.

Also a constraint is my own available time outside the course, which caps how many build iterations a week can realistically absorb.

========================================
5. ENGINE INTEGRATION
========================================
The Gameplay Programmer and the Galaxy Builder write into the Godot project, using MCP. The Gameplay Programmer collects the other agents' JSON output and makes the necessary fixes.

Every agent's output is translated into a fixed, versioned JSON schema, and only that JSON
crosses into the engine.

Story texts: the story-designer owns story/*.md (voice, screens, events, skills, endings). tools/build_story.py generates data/story_text.json and data/events.json from them (the only writer of those two files; text-only exception to the data/ rule); the gameplay-programmer wires them through game/story_text.gd and does not edit story/*.md. Event effect values are not in events.json: they live in data/balance.json and are listed in tools/event_effects.md. Debug-only controls (debug menu, force goal) are stripped from the release export.

Galaxy generation: scatter a dense point cloud, bake a low-res 3D density grid
from it, pick the sun points, and propagate light from the suns
through the volume, dimmed by density. This runs once at scene
generation, so distant and occluded stars darken.
