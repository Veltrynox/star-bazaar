#!/bin/bash
# QA 2026-11-05 sign-off: one bot run (owned by qa-analyst). Called by skill_signoff.sh through xargs, once per job line.
# Usage: skill_signoff_one.sh <out_dir> <tag> <strategy> <seed> [bot flags...]
# Writes <out_dir>/logs/<tag>_<strategy>_<seed>.log (full Godot output) and <out_dir>/rows/<tag>_<strategy>_<seed>.json
# (one RESULT record, or a crash / frozen record when the run printed none). Each run has its own scratch HOME.
set -u
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
GODOT="${GODOT:-$REPO/tools/godot/Godot.app/Contents/MacOS/Godot}"
OUT="$1"; TAG="$2"; STRATEGY="$3"; SEED="$4"; shift 4
mkdir -p "$OUT/logs" "$OUT/rows" "$OUT/home"
NAME="${TAG}_${STRATEGY}_${SEED}"
LOG="$OUT/logs/$NAME.log"
ROW="$OUT/rows/$NAME.json"
HOME_DIR="$OUT/home/$NAME"
rm -rf "$HOME_DIR"; mkdir -p "$HOME_DIR"
# perl alarm stands in for timeout (macOS has none). Exit 142 means the alarm killed the run.
HOME="$HOME_DIR" perl -e 'alarm shift; exec @ARGV' "${LIMIT:-900}" "$GODOT" --headless --path "$REPO" -s res://qa/bots/bot_run.gd -- \
  --strategy="$STRATEGY" --seed="$SEED" "$@" > "$LOG" 2>&1
code=$?
if grep -q '^RESULT ' "$LOG"; then
  grep '^RESULT ' "$LOG" | sed 's/^RESULT //' | sed "s/^{/{\"clock_tag\":\"$TAG\",/" > "$ROW"
elif [ "$code" -eq 142 ]; then
  echo "{\"clock_tag\":\"$TAG\",\"strategy\":\"$STRATEGY\",\"seed\":$SEED,\"outcome\":\"frozen\"}" > "$ROW"
else
  echo "{\"clock_tag\":\"$TAG\",\"strategy\":\"$STRATEGY\",\"seed\":$SEED,\"outcome\":\"crash\",\"exit\":$code}" > "$ROW"
fi
echo "$NAME exit=$code"
