# Star Bazaar: working notes for Claude

## Commits 
- Never add a 'Co-Authored-By: Claude' trailer or any Claude attribution to commit messages.
- Before committing delegated work, run `git status` and stage every file the subagent created or changed, including content and text files, not only schedule.json and blackboard.md.

## Scope discipline
- Do only what the task asks. Do not add QA passes, balance passes, screenshot steps or extra testing unless the task explicitly requests them (the one exception is the Quick look screenshot in the overnight-task skill, see "Visual review" below).
- Design and proposal tasks (skills, events, markets) produce a proposal only. Do not implement anything until the owner has reviewed and approved it.
- When asked to stop or change one task (e.g. T207), touch only that task id.

## Unattended runs (job_runner)
- 'Run the job runner' means `/tools/job_runner.py`
- If the full test suite has failures, check whether they also fail on a clean tree (`git stash && run tests && git stash pop`) before calling them unrelated. Record the result on the blackboard.
- Read every proposal or text file a subagent writes before committing it, and summarise its content in the blackboard entry.
- Never delete branches with unmerged commits.
- Edit schedule.json and other JSON files in place and keep the existing 2-space indent. Never reformat a whole file.

## Communication
- Always reply in English, even when the content being edited (e.g. Russian localisation) is in another language.
- If a request is ambiguous (e.g. 'brighter notes'), ask whether it means text color or background before changing anything.

## QA and economy gate (hard rule, owner approval required)
- The QA and balance agents (qa-analyst, economy-designer) and everything they run (`qa/bots/*`, `tools/sim.py`, ablations, retunes, sign-offs) are called only by the owner, by hand; they take no part in production, so never start them, schedule them or make a task depend on them (`sh tools/tests/run.sh` is not QA and is always allowed).

## Visual review is the owner's job (by design, not a gap)
- The owner looks at every visual result in the running game. Passing headless tests is the finished state for a build task, so an unattended run that did not look at a window is complete, not partial, and a missing window check is not a defect or a warning.
- One cheap exception, owner-approved 2026-11-06: for ui/juice/fx/galaxy tasks the overnight run takes one screenshot with `sh tools/screenshot.sh --out logs/screenshots/<task>.png` (`tools/screenshot_scene.gd`), looks at it, fixes only objective breakage (blank, crash, clipped or overlapping text), and records the path on the blackboard for the owner. It is not QA: no bots, sim or playthroughs, and agents never judge look or taste.

## Running Godot
- Headless (tests, imports): `tools/godot/Godot.app/Contents/MacOS/Godot --headless --path . ...`
- Windowed (playthroughs, screenshots): `qa/run_game.sh res://qa/bots/<script>.gd` (owner-run QA only)
- Windowed single screenshot for the overnight Quick look: `sh tools/screenshot.sh --out logs/screenshots/<task>.png` (not QA; main session only)
- Never prefix these with `cd &&` or `HOME=`.

## Availability rule (progressive disclosure)
- A new good, workshop or storage feature needs a rule in that file first. Use `Availability` (`game/availability.gd`) in any UI that lists goods; hidden means not drawn at all.
- Check: `sh tools/tests/run.sh` runs `_test_availability` (start state, per-rule show/hide, text scan, data lint). It must pass before any UI, data or story change is handed off.

## GDD sync (commit gate)
- `gdd.md` is the short-form design truth (no balance numbers; numbers live in `data/`). A hook (`tools/gdd_sync.py`, set in `.claude/settings.json`) blocks `git commit` when the commit changes `game/`, `data/` or `story/` and does not include `gdd.md`.
- Fix: have doc-manager update `gdd.md` (or `gdd-skills.md`) from the diff, stage it in the same commit, commit again. For a change with no design effect (refactor, fix that already matches the GDD), put `[no-gdd]` in the commit command.
- Test gate: the same hook runs `sh tools/tests/run.sh` on a commit that changes `game/`, `data/`, `story/` or `tools/tests/` and blocks it on any FAIL. For a commit with no code effect put `[no-tests]` in the command. Blackboard: `tools/blackboard.py` archives old run entries and the hook blocks a malformed `blackboard.md`; agents never archive it.

## Generated files: never edit by hand
- `data/story_text.json`, `data/story_text_ru.json` and `data/events.json` are written only by `python3 tools/build_story.py` from `story/*.md` (English) and `story/ru/*.json` (Russian). Each carries a `generated` marker (file, source, generator, command). Edit the source, then run the command; `sh tools/tests/run.sh` also runs it first.
- The test `generated files` in `tools/tests/run_tests.gd` rebuilds them to a temp folder and fails, naming the file and the command, if a checked-in file differs.
- `README.md` is generated by `python3 tools/build_readme.py` from `tools/readme_intro.md`, `tools/project_workflow.html` and `.claude/agents/*.md`; the hook rebuilds and commits it on `git push` (not on commit). Edit the sources, never the README.
- Other tool output (art atlases from `tools/make_*atlas.gd`, narration audio and its `manifest.json` from `tools/voice/gen_voice.py`) is also generated: change the tool or its input, not the output.
- Text ids: events keep only mechanics and text ids in `data/events.json`; every title, body, button, effect line and popup is an id in `story_text.json` (rule: header of `tools/build_story.py`).
- Conditions (chain triggers, availability, workshop unlocks, event filters, `visible_when` on steps, options and events) all use `game/conditions.gd`; its header is the atom vocabulary.

