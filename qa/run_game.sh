#!/bin/bash
# Windowed Godot run for playthroughs/screenshots. Runs OUTSIDE the sandbox.
cd "$(dirname "$0")/.." || exit 1
pkill -f "MacOS/Godot" 2>/dev/null   # clear stray instances first
exec tools/godot/Godot.app/Contents/MacOS/Godot --path . -s "${1:?usage: run_game.sh res://path/to/script.gd}"