# Star Bazaar: working notes for Claude

## Running Godot
- Headless (tests, imports): `tools/godot/Godot.app/Contents/MacOS/Godot --headless --path . ...`
- Windowed (playthroughs, screenshots): `qa/run_game.sh res://qa/bots/<script>.gd`
- Never prefix these with `cd &&` or `HOME=`.
