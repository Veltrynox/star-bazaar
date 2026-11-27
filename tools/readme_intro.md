# Star Bazaar

## ▶ Play now: https://star-bazaar-beta.vercel.app

No install and no account needed.

1. Open the link in a desktop browser (Chrome, Edge, Firefox or Safari with WebGL 2). The first load downloads about 90 MB and takes 10 to 30 seconds.
2. On the main menu click **New Game**. Type a company name (or press **Random**), pick one of the four CEO portraits and press **Start**.
3. Read the short preface. The game then starts paused and a guided tutorial walks you through the first steps: pick a world, place a **Buy** order, **Send to...** another world, run a cycle.
4. Controls are mouse only. **P** pauses. The speed buttons (1x, 2x, 6x, 12x) set how fast cycles run.

Saves are kept in your browser. Assignment write-up (pipeline, integration, cost analysis): [ASSIGNMENT_7.md](ASSIGNMENT_7.md).

## Pipeline audit

Short form of the audit. Full version with tables: [ASSIGNMENT_7.md](ASSIGNMENT_7.md), Deliverable 3.

**What the pipeline produced** (all in the playable build): 3,172 English and 2,961 Russian text ids (events, choices, gigs, endings, skills, tutorial, tips, UI labels). 25 base events, 63 chain events and 40 chain steps, 7 gigs and a 70-node skill tree. 22 goods, 5 workshops and the balance tables. 89 GDScript files (about 32,000 lines). Generated atlases, icons and the ambience track. 264 scheduled tasks (261 done) and 1,014 commits. 84 tasks ran through the unattended orchestrator: 73 merged automatically, 11 were blocked for a human.

**Engine integration:** between agent output and the engine there is **no manual reformatting at all**. Agents write fixed formats (`story/*.md`, `story/ru/*.json`, `data/*.json`, `game/*.gd`). `tools/build_story.py` turns the story files into the JSON the game loads at runtime, and headless Godot imports the generated art. Example, traced end to end: skill *Quartermaster's Terms* went from task T242 to a story-designer run, `story/skills.md`, commit [`a6199564`](https://github.com/Veltrynox/star-bazaar/commit/a6199564b51133c6358de645527f2a742e33a40e), `data/story_text.json` and the skill screen ([screenshot](media/docs/trace_SK_MIL_1_in_game.png)).

**Manual steps that remain.** These are control and release steps, not format steps:
1. The owner approves designs before anything is built.
2. The owner does the visual review in the running game.
3. The owner starts QA and balance runs by hand.
4. The owner settles blocked merges (11 of 84 orchestrator tasks).
5. The owner starts the release (push, web export, Vercel deploy).

They could be removed with a rubric-scored evaluator agent plus screenshot diffs, `qa/check` in CI with fixed thresholds, smaller non-overlapping tasks with an automatic rebuild-and-retry, and a CI export-and-deploy job.

**One architectural change:** most work ran from one long-lived interactive main session on a large model, whose growing context was cached again and again. That session and the agents it started cost $776.77 of $818.54 (95%). The orchestrator's fresh headless workers cost $41.77 for all their tasks, about $0.50 per task. The change: make `schedule.json` plus `tools/orchestrator.py` the only build path, with one short-lived Sonnet or Haiku worker per task that gets only its brief and the files it touches. The interactive session would only talk to the owner and write briefs.

**Cost, before and after.** All figures come from `tools/cost_report.py`, which prices every Claude Code session log at API list rates. Its output is in [`reports/cost_2026-11-25.json`](reports/cost_2026-11-25.json), and [`reports/cost_2026-11-25.csv`](reports/cost_2026-11-25.csv) lists every priced call.

| | Before | After |
|---|---|---|
| Translating the four market event chains to Russian (rule of 2026-11-09) | Sonnet 5.5 story-designer, 4 runs, 71,431 output tokens: **$1.206** | Haiku 5.5 agents, 2 runs, 72,089 output tokens: **$0.074** (−94%) |
| Whole project, API-equivalent (2026-10-28 to 11-25) | | **$818.54** (26,192 calls). Out of pocket: $200 subscription |

The first count, on 2026-11-25, gave $841.07. It still included 2026-10-24 to 10-27, whose logs Claude Code has since deleted under its 30-day retention.

## About

A single-player space trading game made in Godot 4 (GDScript), for macOS and the browser. You run a trading company, not a freighter: ships fly automated routes and you decide where to invest. The goal is to grow your worlds, found the Star Bazaar in a system's Space Storage, raise it stage by stage and open it with a final charter delivery before the term ends. Design truth: [gdd.md](gdd.md). Working rules: [CLAUDE.md](CLAUDE.md).

## Run and test

- Tests (headless): `sh tools/tests/run.sh`
- Economy check (bots in several play styles, headless): `sh qa/check/run.sh`
- Windowed screenshots: `qa/run_game.sh res://qa/gui/<script>.gd`
- Godot lives in `tools/godot/Godot.app` (not in git). Never prefix these commands with `cd &&` or `HOME=`.
