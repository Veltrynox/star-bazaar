#!/usr/bin/env python3
"""Run the main Claude agent unattended, one scheduled task per run, until morning.

Each run is a fresh `claude -p` session in the project folder. Sessions share nothing
except files, so the prompt tells the agent to read and write blackboard.md.

Usage:
  python3 tools/overnight.py                 # up to 8 hours, up to 12 runs
  python3 tools/overnight.py --hours 6 --max-runs 8
  python3 tools/overnight.py --dry-run       # print the prompt and command, run nothing

Stop it early: create a file named STOP_OVERNIGHT in the project root (checked between
runs), or press Ctrl+C. Output of every run is saved in logs/overnight/.

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
LOGS = ROOT / "logs" / "overnight"
STOP_FILE = ROOT / "STOP_OVERNIGHT"
TOOLS = "Bash,Read,Edit,Write,Glob,Grep,Agent,Skill"
RESULT_PREFIX = "OVERNIGHT_RESULT:"

PROMPT = f"""You are the main Claude session for Star Bazaar, running unattended overnight. Nobody can answer questions, so never ask; decide within the rules below, and write down anything that needs the owner. This run covers exactly ONE task.

START
1. Read CLAUDE.md and blackboard.md (the whole file, especially "Do not repeat" and "Left to do"). Run `git status` and `git branch --show-current`; note uncommitted work that is not yours and leave it alone.
2. List the open tasks without reading the whole schedule.json: run `python3 -c "import json;[print(t['task_id'],t['status'],t['owner_agent'],t['title']) for t in json.load(open('schedule.json'))['tasks'] if t['status']!='done']"` (queued, partial and stopped are open). Read the ones you consider with `python3 tools/task.py <id>`. Respect depends_on.

CHOOSE ONE TASK
- Pick the open task with the best value for the game that you can finish in this run, whose dependencies are done, and that needs no owner decision. Prefer finishing a partial task over starting a new one.
- Skip a task, and say so on the blackboard, if it needs a visual decision (look, art, layout, colours) the owner has not made; never decide visual questions yourself, only record them for the owner. Or if it needs the qa-analyst or economy-designer agents, qa bots, tools/sim.py, ablations, retunes or sign-offs. Those run only when the owner starts them by hand; never start, schedule or wait on them. `sh tools/tests/run.sh` is not QA and is always allowed.
- If nothing open can be done, go to IF THE SCHEDULE IS CLEAR.

WORK ON IT UNTIL DONE
- You, the main session, start the role agents (gameplay-programmer, ui-programmer, story-designer, feature-designer, fx-programmer, galaxy-builder, juice-programmer, general-purpose for docs) through the Agent tool, with a self-contained brief each: goal, files to read, constraints, what done means. A build task is done when it is built; do not put tests, screenshots or QA in briefs. Do small edits yourself when an agent would cost more than it saves.
- After each agent finishes, verify its handoff file under handoffs/<agent>/ exists and that the files it lists really changed (`git status`, `git diff --stat`). A claim without file evidence is not done.
- Follow the project rules in CLAUDE.md: Availability rule for any UI listing goods, generated files only through their tools (data/story_text*.json and data/events.json via `python3 tools/build_story.py`), conditions through game/conditions.gd, Godot commands exactly as written there. Before handing off any UI, data or story change, `sh tools/tests/run.sh` must pass; if it fails, fix it or revert your change.
- If the change alters game mechanics, update gdd.md (short form, no balance numbers) in the same commit, because a hook blocks `git commit` when game/, data/ or story/ change without gdd.md. For a change with no design effect, put [no-gdd] in the commit command.
- Update the task in schedule.json (status, and a note of what changed).
- Commit your own work in several logical commits on the CURRENT branch, no Co-Authored-By line. Never push, never switch or create branches, never merge into main, never rewrite history, never delete work you did not make.
- If you get stuck after two honest attempts, stop that task: set it to partial or stopped in schedule.json, record exactly why on the blackboard, and end the run. Do not loop and do not silently drop requirements.

IF THE SCHEDULE IS CLEAR (no open task you may do)
- Read gdd.md, gdd-skills.md and the code and data they describe. Find what is missing, inconsistent or unfinished: planned items, open questions, features that data or code hint at but the game does not deliver, gaps in the player's first hour. Do not invent features the owner has not hinted at; propose them as tasks that say "needs owner decision".
- Create tasks in schedule.json for yourself, using the same fields as existing tasks (task_id continuing the numbering, title, owner_agent, depends_on, status queued, brief, and so on). Make each small enough for one run. Do not start them in this run. Record the analysis on the blackboard.

BLACKBOARD (always, even when the run fails, before you finish)
Append one entry to blackboard.md, newest at the bottom, in this shape:
## <YYYY-MM-DD HH:MM> run: <task id or "gap analysis">
- Summary: 1 to 5 sentences on what you did.
- Why this task: why you chose it over the other open tasks.
- Approach: why this approach over the alternatives you considered.
- Agent prompts: the brief you sent to each agent (shortened to the key instructions) and what each one produced (files, handoff path, result).
- Worked: what worked.
- Failed / did not work: what failed, with the exact error or reason, so nobody repeats it.
- Files and commits: files changed, commit hashes.
- Left to do: what remains for this task and anything that needs the owner.
Also keep two short sections at the top of the file up to date (create them if missing): "Do not repeat" (dead ends and rejected approaches, one line each) and "Left to do" (open items across runs, one line each). Keep the file readable: shorten old entries instead of letting it grow without limit.

FINISH
Your last line must be exactly one of these, with nothing after it:
{RESULT_PREFIX} done <task id>
{RESULT_PREFIX} partial <task id>
{RESULT_PREFIX} blocked <short reason>
{RESULT_PREFIX} idle
Use idle only when the schedule had no open task you may do AND the gap analysis found nothing new to add."""


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
    print(f"overnight: branch {branch()}, up to {args.max_runs} runs, {args.hours} h. Logs: {LOGS}")

    for n in range(1, args.max_runs + 1):
        if STOP_FILE.exists():
            print("STOP_OVERNIGHT found, stopping")
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
