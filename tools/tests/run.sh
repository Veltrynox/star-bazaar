#!/bin/sh
# Runs all headless tests with a scratch HOME so user:// (stats.json, autosave) never touches the real user dir.
# Usage (from the project root):  sh tools/tests/run.sh
# Exit code 0 = all passed. Prints PASS/FAIL lines and a total.
cd "$(dirname "$0")/../.." || exit 1
python3 tools/build_story.py || exit 1
# STAR_TEST_SCRATCH lets parallel runs (tools/orchestrator.py worktrees) use separate scratch homes.
SCRATCH="${STAR_TEST_SCRATCH:-${TMPDIR:-/tmp}/star-bazaar-test-home}"
# No single file (the test log, user:// files) may grow past about 200 MB: a runaway print loop dies instead of filling the disk.
ulimit -f 204800
trap 'rm -rf "$SCRATCH"' EXIT
rm -rf "$SCRATCH"; mkdir -p "$SCRATCH"
LOG="$SCRATCH/run.log"
HOME="$SCRATCH" tools/godot/Godot.app/Contents/MacOS/Godot --headless --path . -s res://tools/tests/run_tests.gd > "$LOG" 2>&1
code=$?
if [ "$(wc -c < "$LOG")" -gt 400000 ]; then
  head -c 200000 "$LOG"; echo; echo "... LOG TRUNCATED (too long to print) ..."; tail -c 100000 "$LOG"
  echo "FAIL: test log is huge, a runaway error loop; read the first errors above"
  exit 1
fi
cat "$LOG"
# A script that fails to parse makes Godot exit 0 with no tests run; treat that as a failure too.
if grep -q "SCRIPT ERROR\|Failed to load script" "$LOG"; then
  echo "FAIL: script load or parse error (see above)"
  exit 1
fi
exit $code
