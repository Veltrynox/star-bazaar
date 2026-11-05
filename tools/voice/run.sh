#!/bin/sh
# Run the voice generator with its own venv. Usage: tools/voice/run.sh [args], see gen_voice.py.
DIR="$(cd "$(dirname "$0")" && pwd)"
if [ ! -x "$DIR/.venv/bin/python" ]; then
  echo "Missing venv. Run: /opt/homebrew/bin/python3.11 -m venv $DIR/.venv && $DIR/.venv/bin/pip install kokoro soundfile \"setuptools<81\"" >&2
  exit 1
fi
export TQDM_DISABLE=1 PYTHONWARNINGS=ignore
exec "$DIR/.venv/bin/python" "$DIR/gen_voice.py" "$@"
