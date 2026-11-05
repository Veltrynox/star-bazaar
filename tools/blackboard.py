#!/usr/bin/env python3
"""Blackboard structure check and archive. Agents never archive; this script does.

  python3 tools/blackboard.py --check     exit 1 and list problems if blackboard.md breaks the structure
  python3 tools/blackboard.py --archive   move run entries older than the last KEEP_RUNS to black_board.archive.md

tools/gdd_sync.py (the PreToolUse commit hook) calls archive() and then problems() on every
`git commit`, so the archive lands in the same commit and a malformed blackboard.md is blocked.

Structure of blackboard.md:
  # Main agent blackboard
  ## Do not repeat            (notes, kept forever, never archived)
  ## Left to do               (notes, kept forever, never archived)
  ...any other notes before the first run entry...
  ## <YYYY-MM-DD[ HH:MM]> run: <task id or "gap analysis"...>   one per run, newest at the bottom
  - Summary: / - Why this task: / - Approach: / - Agent prompts: / - Worked: /
  - Failed / did not work: / - Files and commits: / - Left to do:      (all eight, in this order)
"""
import os, re, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BOARD = "blackboard.md"
ARCHIVE = "black_board.archive.md"
KEEP_RUNS = 4
TITLE = "# Main agent blackboard"
NOTE_SECTIONS = ["Do not repeat", "Left to do"]
FIELDS = ["Summary", "Why this task", "Approach", "Agent prompts", "Worked",
          "Failed / did not work", "Files and commits", "Left to do"]
RUN_HEAD = re.compile(r"^## .*\brun:", re.M)
RUN_OK = re.compile(r"^## \d{4}-\d{2}-\d{2}( \d{2}:\d{2})? run: \S.*$")


def _runs(text):
    """Split into (notes_part, [run entry texts])."""
    starts = [m.start() for m in RUN_HEAD.finditer(text)]
    if not starts:
        return text, []
    return text[:starts[0]], [text[a:b] for a, b in zip(starts, starts[1:] + [len(text)])]


def problems(text=None):
    """List of structure problems in blackboard.md (empty list = ok)."""
    path = ROOT / BOARD
    if text is None:
        if not path.exists():
            return []
        text = path.read_text()
    out = []
    notes, runs = _runs(text)
    lines = notes.splitlines()
    if not lines or lines[0].strip() != TITLE:
        out.append('first line must be "%s"' % TITLE)
    heads = [l[3:].strip() for l in lines if l.startswith("## ")]
    pos = [heads.index(s) if s in heads else -1 for s in NOTE_SECTIONS]
    for s, p in zip(NOTE_SECTIONS, pos):
        if p < 0:
            out.append('missing section "## %s" above the run entries' % s)
    if all(p >= 0 for p in pos) and pos != sorted(pos):
        out.append('sections must be in this order: ' + ", ".join(NOTE_SECTIONS))
    for r in runs:
        head = r.splitlines()[0]
        name = head[:60]
        if not RUN_OK.match(head):
            out.append('bad run heading "%s": use "## YYYY-MM-DD[ HH:MM] run: <task id or gap analysis>"' % name)
        idx = []
        for f in FIELDS:
            m = re.search(r"(?m)^- %s:" % re.escape(f), r)
            idx.append(m.start() if m else -1)
        miss = [f for f, i in zip(FIELDS, idx) if i < 0]
        if miss:
            out.append('run "%s" is missing: %s' % (name, ", ".join(miss)))
        elif idx != sorted(idx):
            out.append('run "%s": fields must be in this order: %s' % (name, ", ".join(FIELDS)))
    return out


def _write(path, text):
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(text)
    os.replace(tmp, path)


def archive():
    """Move run entries older than the last KEEP_RUNS to the archive. True if files changed.
    Notes before the first run entry are never touched. Skips a malformed file (checked by the caller)."""
    board = ROOT / BOARD
    if not board.exists():
        return False
    text = board.read_text()
    notes, runs = _runs(text)
    if len(runs) <= KEEP_RUNS:
        return False
    old, keep = runs[:-KEEP_RUNS], runs[-KEEP_RUNS:]
    arch = ROOT / ARCHIVE
    head = arch.read_text() if arch.exists() else \
        "# Blackboard archive\n\nOlder run entries moved from blackboard.md by tools/blackboard.py, oldest first.\n\n"
    _write(arch, head.rstrip("\n") + "\n\n" + "".join(r.strip("\n") + "\n\n" for r in old).rstrip("\n") + "\n")
    _write(board, notes + "".join(keep))
    return True


def stage():
    subprocess.run(["git", "-C", str(ROOT), "add", "--", BOARD, ARCHIVE], capture_output=True, text=True)


if __name__ == "__main__":
    arg = sys.argv[1] if len(sys.argv) > 1 else "--check"
    if arg == "--archive":
        print("archived" if archive() else "nothing to archive")
    else:
        p = problems()
        print("\n".join(p) if p else "ok")
        sys.exit(1 if p else 0)
