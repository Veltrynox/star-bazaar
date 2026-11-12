#!/bin/sh
# Economy check matrix runner (headless).
#   sh qa/check/run.sh                      all styles x fitting CEOs x seeds 1 2
#   sh qa/check/run.sh --quick              one CEO and one seed per style
#   options: --style=<name> --ceo=<id> --seeds="1 2 3" --jobs=N (default 4) --cycles=N --limit=<seconds per run, default 240>
# Each run: own scratch HOME (user:// never touches your files) under ${STAR_TEST_SCRATCH:-<repo>/../wt/_scratch}/economy-check/,
# deleted on exit; log capped at 20 MB; perl alarm timeout (frozen) ; a run without RESULT is "crash" or "frozen".
# Results: qa/check/out/results.jsonl, errors.log, report.md (qa/check/report.py).
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
GODOT="${GODOT:-$REPO/tools/godot/Godot.app/Contents/MacOS/Godot}"
OUT="${CHECK_OUT:-$REPO/qa/check/out}"   # CHECK_OUT=<dir>: a private output folder, so two runs at once do not overwrite each other
SCRATCH="${STAR_TEST_SCRATCH:-$REPO/../wt/_scratch}/economy-check"

if [ "$1" = "--one" ]; then   # internal: --one <style> <ceo> <seed> <cycles> <limit>
  style="$2"; ceo="$3"; seed="$4"; cycles="$5"; limit="$6"; [ "$cycles" = "-" ] && cycles=""
  tag="${style}_${ceo}_${seed}"
  home="$SCRATCH/$tag"; rm -rf "$home"; mkdir -p "$home"
  log="$home/run.log"; res="$home/result.json"
  ( ulimit -f 40960; HOME="$home" perl -e 'alarm shift; exec @ARGV' "$limit" "$GODOT" --headless --path "$REPO" -s res://qa/check/bot.gd -- \
      --style="$style" --ceo="$ceo" --seed="$seed" $cycles --out="$res" > "$log" 2>&1 )
  code=$?
  if [ -s "$res" ]; then cat "$res"; echo
  elif [ "$code" -eq 142 ]; then echo "{\"style\":\"$style\",\"ceo\":\"$ceo\",\"seed\":$seed,\"outcome\":\"frozen\"}"
  else echo "{\"style\":\"$style\",\"ceo\":\"$ceo\",\"seed\":$seed,\"outcome\":\"crash\",\"exit\":$code}"; fi > "$home/line.json"
  cp "$home/line.json" "$OUT/parts/$tag.json"
  grep -E 'SCRIPT ERROR|^ERROR:|^WARNING: [A-Za-z]' "$log" | grep -v 'were leaked\|RIDs of type' | sed "s|^|$tag: |" | sort -u | head -40 > "$OUT/parts/$tag.err"
  rm -rf "$home"
  echo "done $tag exit=$code"
  exit 0
fi

QUICK=0; STYLES=""; CEOS=""; SEEDS=""; JOBS=4; CYCLES=""; LIMIT=240
for a in "$@"; do
  case "$a" in
    --quick) QUICK=1;;
    --style=*) STYLES="${a#--style=}";;
    --ceo=*) CEOS="${a#--ceo=}";;
    --seeds=*) SEEDS="${a#--seeds=}";;
    --jobs=*) JOBS="${a#--jobs=}";;
    --cycles=*) CYCLES="--cycles=${a#--cycles=}";;
    --limit=*) LIMIT="${a#--limit=}";;
  esac
done
[ -z "$STYLES" ] && STYLES="$(ls "$REPO/qa/check/styles" | sed -n 's/\.gd$//p' | grep -v '^base$')"
[ -z "$SEEDS" ] && { [ "$QUICK" = 1 ] && SEEDS="1" || SEEDS="1 2"; }
mkdir -p "$OUT/parts" "$SCRATCH"; rm -f "$OUT"/parts/* "$OUT/results.jsonl" "$OUT/errors.log"
JOBLIST="$OUT/parts/jobs.txt"; : > "$JOBLIST"
for st in $STYLES; do
  fit="$CEOS"
  [ -z "$fit" ] && fit="$(grep '^const FITTING' "$REPO/qa/check/styles/$st.gd" | grep -o 'ceo_[a-z_0-9]*' | tr '\n' ' ')"
  [ -z "$fit" ] && fit="ceo_woman_01"
  [ "$QUICK" = 1 ] && fit="$(echo $fit | cut -d' ' -f1)"
  for ceo in $fit; do for seed in $SEEDS; do echo "$st $ceo $seed" >> "$JOBLIST"; done; done
done
echo "runs: $(wc -l < "$JOBLIST") jobs=$JOBS"
[ -z "$CYCLES" ] && CYCLES="-"
awk -v c="$CYCLES" -v l="$LIMIT" '{print $0, c, l}' "$JOBLIST" | xargs -P "$JOBS" -L 1 sh -c 'sh "$0" --one "$1" "$2" "$3" "$4" "$5" "$6"' "$REPO/qa/check/run.sh"
cat "$OUT"/parts/*.json > "$OUT/results.jsonl" 2>/dev/null
cat "$OUT"/parts/*.err > "$OUT/errors.log" 2>/dev/null
rm -f "$OUT"/parts/*.json "$OUT"/parts/*.err
CHECK_OUT="$OUT" python3 "$REPO/qa/check/report.py" && echo "report: $OUT/report.md"
