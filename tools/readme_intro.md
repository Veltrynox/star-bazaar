# Star Bazaar

## ▶ Play now: https://star-bazaar-beta.vercel.app

No install and no account needed.

1. Open the link in a desktop browser (Chrome, Edge, Firefox or Safari with WebGL 2). The first load downloads about 90 MB and takes 10 to 30 seconds.
2. On the main menu click **New Game**. Type a company name (or press **Random**), pick one of the four CEO portraits and press **Start**.
3. Read the short preface. The game then starts paused and a guided tutorial walks you through the first steps: pick a world, place a **Buy** order, **Send to...** another world, run a cycle.
4. Controls are mouse only. **P** pauses. The speed buttons (1x, 2x, 6x, 12x) set how fast cycles run.

Saves are kept in your browser. Assignment write-up (pipeline, integration, cost analysis): [ASSIGNMENT_7.md](ASSIGNMENT_7.md).

## About

A single-player space trading game made in Godot 4 (GDScript), for macOS and the browser. You run a trading company, not a freighter: ships fly automated routes and you decide where to invest. The goal is to grow your worlds, found the Star Bazaar in a system's Space Storage, raise it stage by stage and open it with a final charter delivery before the term ends. Design truth: [gdd.md](gdd.md). Working rules: [CLAUDE.md](CLAUDE.md).

## Run and test

- Tests (headless): `sh tools/tests/run.sh`
- Economy check (bots in several play styles, headless): `sh qa/check/run.sh`
- Windowed screenshots: `qa/run_game.sh res://qa/gui/<script>.gd`
- Godot lives in `tools/godot/Godot.app` (not in git). Never prefix these commands with `cd &&` or `HOME=`.
