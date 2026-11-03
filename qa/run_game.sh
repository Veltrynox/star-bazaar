#!/bin/bash
# Windowed Godot run for playthroughs/screenshots. Runs OUTSIDE the sandbox.
# Usage: qa/run_game.sh res://path/to/script.gd [-- script args]
# Args after the script path are forwarded to the script (OS.get_cmdline_user_args), e.g. bot_run.gd options.
cd "$(dirname "$0")/.." || exit 1
pkill -f "MacOS/Godot" 2>/dev/null   # clear stray instances first
script="${1:?usage: run_game.sh res://path/to/script.gd [-- args]}"
shift
[ "$1" = "--" ] && shift
exec tools/godot/Godot.app/Contents/MacOS/Godot --path . -s "$script" -- "$@"
