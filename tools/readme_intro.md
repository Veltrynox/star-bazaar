# Star Bazaar

A single-player space trading game for macOS, made in Godot 4 (GDScript). You run a trading company, not a freighter: ships fly automated routes and you decide where to invest. The goal is to hold more than half of one of four markets (Military, Luxury, Minerals, Biotech) against three rival companies. Design truth: [gdd.md](gdd.md). Working rules: [CLAUDE.md](CLAUDE.md).

## Run and test

- Tests (headless): `sh tools/tests/run.sh`
- Windowed playthrough or screenshots: `qa/run_game.sh res://qa/bots/<script>.gd`
- Godot lives in `tools/godot/Godot.app` (not in git). Never prefix these commands with `cd &&` or `HOME=`.
