#!/bin/sh
# Windowed screenshot: sh tools/screenshot.sh --out logs/screenshots/T251.png [--scene ..] [--planet ..] [--frames ..]
# Runs outside the sandbox. Not QA: see tools/screenshot_scene.gd.
cd "$(dirname "$0")/.." || exit 1
exec tools/godot/Godot.app/Contents/MacOS/Godot --path . -s tools/screenshot_scene.gd -- "$@"
