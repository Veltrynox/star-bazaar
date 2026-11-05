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

Blackboard (same hook, every `git commit`, also with [no-gdd]): tools/blackboard.py archives run
entries older than the last 4 into black_board.archive.md (a script, never the agent) and stages both
files; a commit that includes a blackboard.md breaking the structure is blocked with the problem list.

README (same hook, on `git push` instead of commit): tools/build_readme.py rebuilds README.md from its
sources; if it changed, the hook commits only README.md ("Rebuild README") before the push goes out.

Tests (same hook, last and slowest): a commit that changes game/, data/, story/ or tools/tests/ runs
`sh tools/tests/run.sh` and is blocked (exit 2, failing lines go to Claude) on any FAIL or a non-zero
exit. Escape hatch for commits with no code effect: put [no-tests] in the command. Set STAR_TEST_CMD
to replace the test command (used to test this hook).
"""
import json, os, re, subprocess, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import blackboard

ROOT = Path(__file__).resolve().parent.parent
WATCHED = ("game/", "data/", "story/")
GDD = "gdd.md"
SKIP = "[no-gdd]"
SKIP_TESTS = "[no-tests]"
TEST_WATCHED = ("game/", "data/", "story/", "tools/tests/")
TEST_TIMEOUT = 580

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


def tests_gate(all_tracked):
    """Run the test suite when the commit touches code or data; return a block message on failure."""
    files = [f for f in changed(all_tracked) if f.startswith(TEST_WATCHED)]
    if not files:
        return None
    cmd = os.environ.get("STAR_TEST_CMD") or "sh tools/tests/run.sh"
    try:
        r = subprocess.run(cmd, shell=True, cwd=str(ROOT), capture_output=True, text=True, timeout=TEST_TIMEOUT)
    except subprocess.TimeoutExpired:
        return "Tests did not finish in %d s; commit blocked. Run `sh tools/tests/run.sh` by hand." % TEST_TIMEOUT
    out = (r.stdout or "") + (r.stderr or "")
    fails = [l for l in out.splitlines() if l.startswith("FAIL")]
    if r.returncode != 0 or fails:
        total = [l for l in out.splitlines() if l.startswith("TOTAL")]
        shown = "\n".join(fails[:15]) + ("\n... %d more" % (len(fails) - 15) if len(fails) > 15 else "")
        return ("Tests failed, commit blocked (%d file(s) under game/, data/, story/ or tools/tests/ changed, e.g. %s). "
                "Fix the failures or revert the change, then commit again. If the commit has no code effect, add [no-tests].\n%s\n%s"
                % (len(files), ", ".join(files[:3]), shown or "(exit code %d, no FAIL line: see `sh tools/tests/run.sh`)" % r.returncode, " ".join(total)))
    return None


def readme_on_push():
    """Rebuild README.md; commit it alone (pathspec commit, other staged files stay out) if it changed."""
    r = subprocess.run([sys.executable, str(ROOT / "tools" / "build_readme.py"), "--check"], capture_output=True, text=True)
    if r.returncode == 0:
        return
    if subprocess.run([sys.executable, str(ROOT / "tools" / "build_readme.py")], capture_output=True, text=True).returncode != 0:
        print("README rebuild failed; push continues", file=sys.stderr)
        return
    subprocess.run(["git", "-C", str(ROOT), "add", "--", "README.md"], capture_output=True, text=True)
    subprocess.run(["git", "-C", str(ROOT), "commit", "-q", "-m", "Rebuild README from workflow page and agent briefs", "--", "README.md"],
                   capture_output=True, text=True)


def board_gate(all_tracked):
    """Archive old blackboard runs; return a block message if the commit carries a malformed blackboard.md."""
    probs = blackboard.problems()
    if probs:
        if blackboard.BOARD in changed(all_tracked):
            return "blackboard.md breaks its structure (tools/blackboard.py --check): " + "; ".join(probs[:6]) + \
                   ". Fix the entry (shape: see tools/blackboard.py header) and commit again."
        return None
    if blackboard.archive():
        blackboard.stage()
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
        if re.search(r"\bgit\b[^|;&]*\bpush\b", cmd):
            try:
                readme_on_push()
            except Exception as e:  # never block a push over the README
                print("README rebuild skipped: %s" % e, file=sys.stderr)
        is_commit = re.search(r"\bgit\b[^|;&]*\bcommit\b", cmd)
        if is_commit:
            all_tracked = bool(re.search(r"\bcommit\b[^|;&]*\s(-[a-zA-Z]*a[a-zA-Z]*|--all)\b", cmd))
            try:
                m = board_gate(all_tracked)
            except Exception as e:  # an archive error must never block a commit
                print("blackboard archive skipped: %s" % e, file=sys.stderr)
                m = None
            if m:
                print(m, file=sys.stderr)
                sys.exit(2)
        if is_commit and SKIP not in cmd:
            all_tracked = bool(re.search(r"\bcommit\b[^|;&]*\s(-[a-zA-Z]*a[a-zA-Z]*|--all)\b", cmd))
            m = missing(all_tracked)
            if m:
                print(m, file=sys.stderr)
                sys.exit(2)
        if is_commit and SKIP_TESTS not in cmd:
            all_tracked = bool(re.search(r"\bcommit\b[^|;&]*\s(-[a-zA-Z]*a[a-zA-Z]*|--all)\b", cmd))
            m = tests_gate(all_tracked)
            if m:
                print(m, file=sys.stderr)
                sys.exit(2)
