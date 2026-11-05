#!/bin/sh
# Leave running in a terminal. When story/*.md changes, rebuild data/story_text.json,
# then generate voice only for new or changed lines. Stop with Ctrl+C.
# Usage: tools/voice/watch.sh
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$DIR/../.." && pwd)"
cd "$ROOT" || exit 1
stamp() { ls -l -T story/*.md | md5; }
last=""
echo "Watching story/*.md (every 5 s). Ctrl+C to stop."
while true; do
  now="$(stamp)"
  if [ "$now" != "$last" ]; then
    last="$now"
    echo "$(date +%H:%M:%S) text changed, rebuilding"
    python3 tools/build_story.py --allow-skip >/dev/null 2>&1
    "$DIR/run.sh"
  fi
  sleep 5
done
