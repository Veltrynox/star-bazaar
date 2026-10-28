#!/bin/sh
# Runs all headless tests with a scratch HOME so user:// (stats.json, autosave) never touches the real user dir.
# Usage (from the project root):  sh tools/tests/run.sh
# Exit code 0 = all passed. Prints PASS/FAIL lines and a total.
cd "$(dirname "$0")/../.." || exit 1
python3 tools/build_story.py || exit 1
SCRATCH="${TMPDIR:-/tmp}/star-bazaar-test-home"
rm -rf "$SCRATCH"; mkdir -p "$SCRATCH"
HOME="$SCRATCH" tools/godot/Godot.app/Contents/MacOS/Godot --headless --path . -s res://tools/tests/run_tests.gd
