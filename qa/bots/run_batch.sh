#!/bin/bash
# QA batch runner (owned by qa-analyst). Runs bot_run.gd headless for each strategy and seed.
# Usage: [STRATEGIES="decent sloppy"] [SEEDS="1 2 3"] [EXTRA="--clock=timer --choice=CORP --force-goal=12"] \
#          [TAG=name] [LIMIT=120] [GODOT=/path/to/Godot] qa/bots/run_batch.sh <out_dir>
# Writes <out_dir>/<TAG>_<strategy>_<seed>.log (full Godot output), <out_dir>/results_<TAG>.jsonl
# (one RESULT json per run) and <out_dir>/errors_<TAG>.log (Godot ERROR lines and run failures).
# A run with no RESULT line is classed as "crash" (non-zero exit) or "frozen" (killed at LIMIT s).
# Every run uses a scratch HOME (like tools/tests/run.sh), so user:// (autosave, stats.json) never
# touches the real user directory. Each run gets its own scratch HOME.
set -u
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
GODOT="${GODOT:-$REPO/tools/godot/Godot.app/Contents/MacOS/Godot}"
OUT="${1:?usage: run_batch.sh <out_dir>}"
STRATEGIES="${STRATEGIES:-decent sloppy always_expand never_expand}"
SEEDS="${SEEDS:-1 2 3 4 5}"
EXTRA="${EXTRA:-}"
TAG="${TAG:-fast}"
LIMIT="${LIMIT:-120}"
mkdir -p "$OUT"
# One scratch root per out dir: parallel batches with the same TAG, strategy and seed must not share a HOME
# (shared user:// made autosave and stats.json collide between runs).
OUT_ID="$(cd "$OUT" && pwd | cksum | cut -d" " -f1)"
SCRATCH_ROOT="${TMPDIR:-/tmp}/star-bazaar-qa-home/$OUT_ID"
RESULTS="$OUT/results_${TAG}.jsonl"
ERRORS="$OUT/errors_${TAG}.log"
: > "$RESULTS"
: > "$ERRORS"
for strategy in $STRATEGIES; do
  for seed in $SEEDS; do
    log="$OUT/${TAG}_${strategy}_${seed}.log"
    home="$SCRATCH_ROOT/${TAG}_${strategy}_${seed}"
    rm -rf "$home"; mkdir -p "$home"
    # perl alarm stands in for timeout, which macOS does not ship. Exit 142 means killed by alarm.
    # EXTRA is intentionally unquoted so that several bot flags can be passed.
    # shellcheck disable=SC2086
    HOME="$home" perl -e 'alarm shift; exec @ARGV' "$LIMIT" "$GODOT" --headless --path "$REPO" -s res://qa/bots/bot_run.gd -- \
      --strategy="$strategy" --seed="$seed" $EXTRA > "$log" 2>&1
    code=$?
    if grep -q '^RESULT ' "$log"; then
      grep '^RESULT ' "$log" | sed 's/^RESULT //' | sed "s/^{/{\"clock_tag\":\"$TAG\",/" >> "$RESULTS"
    elif [ "$code" -eq 142 ]; then
      echo "{\"clock_tag\":\"$TAG\",\"strategy\":\"$strategy\",\"seed\":$seed,\"outcome\":\"frozen\"}" >> "$RESULTS"
    else
      echo "{\"clock_tag\":\"$TAG\",\"strategy\":\"$strategy\",\"seed\":$seed,\"outcome\":\"crash\",\"exit\":$code}" >> "$RESULTS"
    fi
    grep -E 'SCRIPT ERROR|ERROR:|bot_run:' "$log" | sed "s/^/${TAG} ${strategy}_${seed}: /" >> "$ERRORS"
    echo "${TAG} ${strategy} seed=${seed} exit=${code}"
  done
done
