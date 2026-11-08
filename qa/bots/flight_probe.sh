#!/bin/bash
# QA 2026-11-08 (T182): flight, discovery, pause and save probe (owned by qa-analyst). Not gameplay code.
# Usage: flight_probe.sh <out_dir> <seed>
# Writes <out_dir>/probe_seed<seed>.log (every CHECK line and PROBE_END). Each run has its own scratch HOME.
set -u
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
GODOT="${GODOT:-$REPO/tools/godot/Godot.app/Contents/MacOS/Godot}"
OUT="$1"; SEED="$2"
HOME_DIR="$OUT/home/seed$SEED"
mkdir -p "$OUT"
rm -rf "$HOME_DIR"; mkdir -p "$HOME_DIR"
# perl alarm stands in for timeout (macOS has none). Exit 142 means the alarm killed the run.
HOME="$HOME_DIR" perl -e 'alarm shift; exec @ARGV' 900 "$GODOT" --headless --path "$REPO" -s res://qa/bots/flight_probe.gd -- --seed="$SEED" > "$OUT/probe_seed$SEED.log" 2>&1
code=$?
echo "seed $SEED exit=$code"
