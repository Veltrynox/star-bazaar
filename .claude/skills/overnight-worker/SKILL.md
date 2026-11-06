---
name: overnight-worker
description: Build ONE given Star Bazaar task inside its own git worktree on branch task/<id>, for tools/orchestrator.py parallel runs. Not for interactive use.
---

You are a worker for Star Bazaar, running unattended inside a git worktree (your current folder) on branch task/<task id>. The argument is the task id. Nobody can answer questions, so never ask; decide within these rules. You cover exactly this ONE task. Other workers run at the same time in other worktrees; the orchestrator (tools/orchestrator.py) merges your branch afterwards.

START
1. Read CLAUDE.md. Run `python3 tools/task.py <task id>` and read the task. Read only what the task needs; do NOT read or edit schedule.json or blackboard.md (the orchestrator owns both, so parallel branches never collide).
2. Stay inside the task's `touches` globs. If you must change a file outside them, make the smallest possible edit and say so in your result line.

BUILD
- You, the main session of this worktree, start the role agent named in the task (owner_agent) through the Agent tool with a self-contained brief: goal, files to read, constraints, what done means. A build task is done when it is built; do not put tests, screenshots or QA in briefs. Do small edits yourself when an agent would cost more than it saves. After the agent finishes, verify its handoff file under handoffs/<agent>/ exists and that the files it lists really changed (`git status`, `git diff --stat`).
- Follow CLAUDE.md: Availability rule for any UI listing goods, generated files only through their tools (`python3 tools/build_story.py`), conditions through game/conditions.gd, Godot commands exactly as written there. Never start qa-analyst, economy-designer, qa bots, tools/sim.py. Skip nothing silently: if the task needs a visual decision, an owner decision or an owner-only agent, build nothing and end with `JOB_RESULT: blocked <reason>`.
- If the change alters game mechanics, update gdd.md (short form, no balance numbers) in the same commit; a hook blocks `git commit` otherwise. For a change with no design effect put [no-gdd] in the commit command.

TESTS (your job, up to 5 iterations)
- Run `sh tools/tests/run.sh`. It must end with `TOTAL pass=N fail=0`. On a FAIL read the failing lines, fix the cause, and run again. Stop after 5 runs in total. If still failing, end with `JOB_RESULT: blocked tests failing: <names>`. Tests that already fail on the base branch and are unrelated to your change: confirm that by name from the baseline given in the orchestrator's note, if any; never hide a failure.

QUICK LOOK (only if owner_agent is ui-programmer, juice-programmer, fx-programmer or galaxy-builder, or the task has "visual": true)
- Take ONE screenshot: `sh tools/screenshot.sh --out logs/screenshots/<task id>.png`, open it with Read, fix only objective breakage (blank screen, crash, clipped or overlapping text), at most two attempts. Never judge look or taste. If it cannot be taken, note one line and carry on; this never blocks the task. Not QA: no bots, playthroughs or sim.

COMMIT
- Commit your own work in one or several logical commits on this branch, each message starting with the task id (e.g. `T251: juice pass for trade payoffs`), no Co-Authored-By line. Stage every file the work created or changed, including text and data files (`git status` must be clean at the end, except ignored files). Never push, never switch or create branches, never rewrite history, never touch the main checkout.

FINISH
Your last line must be exactly one of these, with nothing after it:
JOB_RESULT: done <task id> | <one-sentence summary of what was built> | tests <N> pass
JOB_RESULT: blocked <task id> | <short reason>
