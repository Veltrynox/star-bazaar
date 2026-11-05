#!/usr/bin/env python3
"""Commit gate: design-relevant code changes must come with a GDD update.

  python3 tools/gdd_sync.py --check   exit 1 if the staged change touches game/, data/
                                      or story/ and gdd.md is not part of it
  python3 tools/gdd_sync.py --hook    Claude Code PreToolUse hook: reads the tool call
                                      on stdin, checks only on `git commit`, exit 2
                                      (blocks, message goes to Claude) if the GDD is missing

`git commit -a` is checked against all tracked changes instead of the index.
Escape hatch for a change with no design effect (refactor, bug fix that matches the GDD):
put the marker [no-gdd] in the command, e.g. in the commit message.
"""
import json, re, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WATCHED = ("game/", "data/", "story/")
GDD = "gdd.md"
SKIP = "[no-gdd]"

MSG = ("This commit changes {n} file(s) under game/, data/ or story/ (e.g. {ex}) but not gdd.md. "
       "Start doc-manager (the docs agent) with the diff (`git diff --cached`, or `git diff HEAD` "
       "for commit -a): it updates the short-form mechanics in gdd.md (or gdd-skills.md for skills) "
       "to match, main design only, no balance numbers. Stage gdd.md and commit again. If the "
       "change has no design effect, commit again with the marker [no-gdd] in the command.")


def changed(all_tracked):
    args = ["git", "-C", str(ROOT), "diff", "--name-only"] + (["HEAD"] if all_tracked else ["--cached"])
    out = subprocess.run(args, capture_output=True, text=True).stdout
    return [f for f in out.splitlines() if f]


def missing(all_tracked=False):
    files = changed(all_tracked)
    code = [f for f in files if f.startswith(WATCHED)]
    if code and GDD not in files:
        return MSG.format(n=len(code), ex=", ".join(code[:3]))
    return None


if __name__ == "__main__":
    arg = sys.argv[1] if len(sys.argv) > 1 else "--check"
    if arg == "--check":
        m = missing()
        print(m or "ok")
        sys.exit(1 if m else 0)
    elif arg == "--hook":
        try:
            cmd = json.load(sys.stdin).get("tool_input", {}).get("command", "")
        except Exception:
            sys.exit(0)
        if re.search(r"\bgit\b[^|;&]*\bcommit\b", cmd) and SKIP not in cmd:
            all_tracked = bool(re.search(r"\bcommit\b[^|;&]*\s(-[a-zA-Z]*a[a-zA-Z]*|--all)\b", cmd))
            m = missing(all_tracked)
            if m:
                print(m, file=sys.stderr)
                sys.exit(2)
