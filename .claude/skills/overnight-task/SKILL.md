---
name: overnight-task
description: Run one scheduled Star Bazaar task unattended (pick from schedule.json, delegate to role agents, commit, write the blackboard entry). Used by tools/job_runner.py; only for unattended runs.
---

You are the main Claude session for Star Bazaar, running unattended. Nobody can answer questions, so never ask; decide within the rules below, and write down anything that needs the owner. This run covers exactly ONE task.

START
1. Read CLAUDE.md and blackboard.md (the whole file, especially "Do not repeat" and "Left to do"). Run `git status` and `git branch --show-current`; note uncommitted work that is not yours and leave it alone.
2. List the open tasks without reading the whole schedule.json: run `python3 -c "import json;[print(t['task_id'],t['status'],t['owner_agent'],t['title']) for t in json.load(open('schedule.json'))['tasks'] if t['status']!='done']"` (queued, partial and stopped are open). Read the ones you consider with `python3 tools/task.py <id>`. Respect depends_on.

CHOOSE ONE TASK
- Tasks with "priority": 1 come first (owner's current direction, empire growth v2); pick among them before any other task.
- Pick the open task with the best value for the game that you can finish in this run, whose dependencies are done, and that needs no owner decision. Prefer finishing a partial task over starting a new one.
- Skip a task, and say so on the blackboard, if it needs a visual decision (look, art, layout, colours) the owner has not made; never decide visual questions yourself, only record them for the owner. Or if it needs the qa-analyst or economy-designer agents, qa bots, tools/sim.py, ablations, retunes or sign-offs. Those run only when the owner starts them by hand; never start, schedule or wait on them. `sh tools/tests/run.sh` is not QA and is always allowed.
- If nothing open can be done, go to IF THE SCHEDULE IS CLEAR.

WORK ON IT UNTIL DONE
- You, the main session, start the role agents (gameplay-programmer, ui-programmer, story-designer, feature-designer, fx-programmer, galaxy-builder, juice-programmer, general-purpose for docs) through the Agent tool, with a self-contained brief each: goal, files to read, constraints, what done means. A build task is done when it is built; do not put tests, screenshots or QA in briefs or in a task's done criteria (the Quick look below is done by you, the main session, never by a role agent, and never blocks the task). Do small edits yourself when an agent would cost more than it saves.
- After each agent finishes, verify its handoff file under handoffs/<agent>/ exists and that the files it lists really changed (`git status`, `git diff --stat`). A claim without file evidence is not done.
- Follow the project rules in CLAUDE.md: Availability rule for any UI listing goods, generated files only through their tools (data/story_text*.json and data/events.json via `python3 tools/build_story.py`), conditions through game/conditions.gd, Godot commands exactly as written there. Before handing off any UI, data or story change, `sh tools/tests/run.sh` must pass; if it fails, fix it or revert your change.
- If the change alters game mechanics, update gdd.md (short form, no balance numbers) in the same commit, because a hook blocks `git commit` when game/, data/ or story/ change without gdd.md. For a change with no design effect, put [no-gdd] in the commit command. The same hook runs sh tools/tests/run.sh on any commit that changes game/, data/, story/ or tools/tests/ and blocks it on a FAIL: fix the failure; put [no-tests] in the command only for a commit with no code effect.
- Quick look (only for a task whose owner_agent is ui-programmer, juice-programmer, fx-programmer or galaxy-builder, or that has "visual": true): after the build and before the final commit, take ONE screenshot with `sh tools/screenshot.sh --out logs/screenshots/<task id>.png` (options: `--planet <id>` opens a planet panel, `--scene res://...` for another scene, `--frames <n>`). This is not QA: no bots, no playthroughs, no sim. Open the PNG with Read. Fix only objective breakage you can see: a blank or black screen, a crash or error in the output, missing or clipped or overlapping text or panels, an element that is plainly not where the task put it. Do not judge or change look, colours, layout taste or effect strength; those are the owner's. At most two fix attempts, then leave it and note it. Write the PNG path under "Files and commits" on the blackboard. If the shot cannot be taken (no display, tool error), note it in one line and carry on; that never blocks the task. The owner reviews the screenshot later.
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
- Files and commits: files changed, commit hashes, screenshot path if one was taken.
- Left to do: what remains for this task and anything that needs the owner.
Also keep two short sections at the top of the file up to date (create them if missing): "Do not repeat" (dead ends and rejected approaches, one line each) and "Left to do" (open items across runs, one line each). Do not shorten, move or delete old entries: tools/blackboard.py archives them at commit time (only the last 4 runs stay), and a commit with a malformed blackboard.md is blocked, so keep the exact heading and the eight fields above in that order.

FINISH
Your last line must be exactly one of these, with nothing after it:
JOB_RESULT: done <task id>
JOB_RESULT: partial <task id>
JOB_RESULT: blocked <short reason>
JOB_RESULT: idle
Use idle only when the schedule had no open task you may do AND the gap analysis found nothing new to add.
