#!/usr/bin/env python3
"""Job runner: run the main Claude agent unattended, one scheduled task per run, for hours.

Each run is a fresh `claude -p` session in the project folder. Sessions share nothing
except files, so the overnight-task skill (.claude/skills/overnight-task/SKILL.md, the real prompt) tells the agent to read and write blackboard.md.

Usage:
  python3 tools/job_runner.py                 # up to 8 hours, up to 12 runs
  python3 tools/job_runner.py --hours 6 --max-runs 8
  python3 tools/job_runner.py --dry-run       # print the prompt and command, run nothing

Stop it early: create a file named STOP_JOB_RUNNER in the project root (checked between
runs), or press Ctrl+C. Output of every run is saved in logs/job_runner/.

The script stops by itself when the agent reports idle twice in a row, after three
failed runs in a row, when the time is up, or when the run limit is reached.

Permissions: headless runs cannot ask, so the default is acceptEdits plus an allowlist
of tools (see TOOLS). Bash is allowed in full. Use --skip-permissions only if you
accept that the agent can do anything the shell can.
"""
import argparse
import datetime as dt
import shutil
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LOGS = ROOT / "logs" / "job_runner"
STOP_FILE = ROOT / "STOP_JOB_RUNNER"
TOOLS = "Bash,Read,Edit,Write,Glob,Grep,Agent,Skill"
RESULT_PREFIX = "JOB_RESULT:"

PROMPT = """/overnight-task"""


def branch():
    out = subprocess.run(["git", "branch", "--show-current"], cwd=ROOT, capture_output=True, text=True)
    return out.stdout.strip()


def build_cmd(args):
    cmd = ["claude", "-p", PROMPT]
    if args.skip_permissions:
        cmd.append("--dangerously-skip-permissions")
    else:
        cmd += ["--permission-mode", "acceptEdits", "--allowedTools", TOOLS]
    if args.model:
        cmd += ["--model", args.model]
    if shutil.which("caffeinate"):
        cmd = ["caffeinate", "-i"] + cmd  # keep the Mac awake while a run is going
    return cmd


def last_result(text):
    for line in reversed(text.strip().splitlines()):
        line = line.strip()
        if line.startswith(RESULT_PREFIX):
            return line[len(RESULT_PREFIX):].strip()
    return None


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--hours", type=float, default=8.0, help="stop starting new runs after this many hours")
    ap.add_argument("--max-runs", type=int, default=12)
    ap.add_argument("--run-timeout", type=float, default=90.0, help="minutes before one run is killed")
    ap.add_argument("--model", default=None)
    ap.add_argument("--skip-permissions", action="store_true", help="pass --dangerously-skip-permissions")
    ap.add_argument("--allow-main", action="store_true", help="allow running on the main branch")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    cmd = build_cmd(args)
    if args.dry_run:
        print("cwd:", ROOT)
        print("branch:", branch())
        print("command:", " ".join(c if len(c) < 80 else c[:60] + "...<prompt>" for c in cmd))
        print("\n--- prompt ---\n" + PROMPT)
        return 0
    if shutil.which("claude") is None:
        sys.exit("claude CLI not found on PATH")
    if branch() in ("main", "") and not args.allow_main:
        sys.exit(f"refusing to run on branch '{branch()}'; switch to a work branch or pass --allow-main")

    LOGS.mkdir(parents=True, exist_ok=True)
    start = time.time()
    deadline = start + args.hours * 3600
    idle_streak = fail_streak = 0
    print(f"job_runner: branch {branch()}, up to {args.max_runs} runs, {args.hours} h. Logs: {LOGS}")

    for n in range(1, args.max_runs + 1):
        if STOP_FILE.exists():
            print("STOP_JOB_RUNNER found, stopping")
            break
        if time.time() >= deadline:
            print("time is up, stopping")
            break
        stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
        log = LOGS / f"{stamp}-run{n}.log"
        print(f"[{dt.datetime.now():%H:%M:%S}] run {n} -> {log.name}", flush=True)
        try:
            proc = subprocess.run(cmd, cwd=ROOT, stdin=subprocess.DEVNULL, capture_output=True,
                                  text=True, timeout=args.run_timeout * 60)
            out, code = proc.stdout, proc.returncode
            log.write_text(out + ("\n--- stderr ---\n" + proc.stderr if proc.stderr else ""))
        except subprocess.TimeoutExpired as e:
            out, code = (e.stdout or b"").decode() if isinstance(e.stdout, bytes) else (e.stdout or ""), -1
            log.write_text(out + "\n--- killed: run timeout ---\n")
        except KeyboardInterrupt:
            print("interrupted")
            break

        result = last_result(out)
        print(f"  exit {code}, result: {result or 'none'}", flush=True)
        if code != 0 or result is None:
            fail_streak += 1
            if fail_streak >= 3:
                print("three failed runs in a row, stopping")
                break
        else:
            fail_streak = 0
        idle_streak = idle_streak + 1 if result == "idle" else 0
        if idle_streak >= 2:
            print("agent is idle twice in a row, stopping")
            break
        time.sleep(20)

    print(f"done after {(time.time() - start) / 60:.0f} min. Read blackboard.md and {LOGS}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
