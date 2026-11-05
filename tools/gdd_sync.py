#!/usr/bin/env python3
"""Keep gdd.md in sync with gdd-log.md and the game version.

  python3 tools/gdd_sync.py --stamp   rewrite the sync line in gdd.md (line 2)
  python3 tools/gdd_sync.py --check   exit 1 if the line is stale
  python3 tools/gdd_sync.py --hook    Claude Code PreToolUse hook: reads the tool
                                      call on stdin, checks only on `git commit`,
                                      exit 2 (blocks, message goes to Claude) if stale

The stamp holds the game version (project.godot config/version), the log's entry
count, latest date and a hash of gdd-log.md. Any log change makes the stamp stale,
so the GDD body must be reviewed (short-form mechanics state), then re-stamped.
"""
import hashlib, json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GDD, LOG, PROJ = ROOT / "gdd.md", ROOT / "gdd-log.md", ROOT / "project.godot"
PREFIX = "Synced with change log: "


def stamp_line():
    m = re.search(r'^config/version="([^"]+)"', PROJ.read_text(), re.M)
    version = m.group(1) if m else "unversioned"
    text = LOG.read_text()
    dates = re.findall(r"^(\d{4}-\d{2}-\d{2})", text, re.M)
    digest = hashlib.sha1(text.encode()).hexdigest()[:8]
    return (f"{PREFIX}game version {version} | gdd-log.md {digest} "
            f"({len(dates)} entries, latest {max(dates)}) | change log: gdd-log.md")


def current():
    lines = GDD.read_text().split("\n")
    return lines, (lines[1] if len(lines) > 1 and lines[1].startswith(PREFIX) else None)


def stamp():
    lines, cur = current()
    new = stamp_line()
    if cur is None:
        lines.insert(1, new)
    else:
        lines[1] = new
    GDD.write_text("\n".join(lines))
    print(new)


def check():
    return current()[1] == stamp_line()


STALE = ("gdd.md is out of sync with gdd-log.md. Before committing: (1) read the newest "
         "gdd-log.md entries, (2) update the short-form mechanics in gdd.md to match "
         "(main design only, no balance numbers), (3) add a gdd-log.md entry if the "
         "change has none, (4) run `python3 tools/gdd_sync.py --stamp`, then commit again.")

if __name__ == "__main__":
    arg = sys.argv[1] if len(sys.argv) > 1 else "--check"
    if arg == "--stamp":
        stamp()
    elif arg == "--check":
        ok = check()
        print("in sync" if ok else STALE)
        sys.exit(0 if ok else 1)
    elif arg == "--hook":
        try:
            cmd = json.load(sys.stdin).get("tool_input", {}).get("command", "")
        except Exception:
            sys.exit(0)
        if re.search(r"\bgit\b[^|;&]*\bcommit\b", cmd) and not check():
            print(STALE, file=sys.stderr)
            sys.exit(2)
