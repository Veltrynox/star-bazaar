#!/bin/sh
# Run the voice generator with its own venv. Usage: tools/voice/run.sh [args], see gen_voice.py.
# English uses .venv (Kokoro); "--lang ru" uses .venv_ru (Chatterbox Multilingual):
#   /opt/homebrew/bin/python3.11 -m venv tools/voice/.venv_ru && tools/voice/.venv_ru/bin/pip install chatterbox-tts soundfile "setuptools<81"
DIR="$(cd "$(dirname "$0")" && pwd)"
VENV="$DIR/.venv"
case " $* " in *" --lang ru "*) VENV="$DIR/.venv_ru";; esac
if [ ! -x "$VENV/bin/python" ]; then
  echo "Missing venv $VENV. Run: /opt/homebrew/bin/python3.11 -m venv $VENV && $VENV/bin/pip install kokoro soundfile \"setuptools<81\" (Russian: chatterbox-tts instead of kokoro)" >&2
  exit 1
fi
export TQDM_DISABLE=1 PYTHONWARNINGS=ignore
exec "$VENV/bin/python" "$DIR/gen_voice.py" "$@"
