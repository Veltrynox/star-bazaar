# Main agent blackboard

## Do not repeat
- discovery_enabled in data/balance.json ships at 1 (owner decision 2026-11-05); tests that need it off set it themselves.

## Left to do
- Open build tasks from playtest: T199 (T196-T198, T200-T202 done). Owner: check T198 look windowed (trail line 1px, scale 0.5, pick 20px). T194 done; Competitors still reachable from share panel (L), owner to say if that goes too.
- Open: T185 (visual), T178/T182 (owner-only agents), T05 (only windowed frame time missing, see T193), T166 (superseded). Owner-decision tasks T189-T193 added 2026-11-05.

- Owner: ship cap 20 (T186): decide on economy retune (trip cost, maintenance tuned for 6) and look of the scrolled ship list; other panels not checked at 20 ships.
- Owner: asteroid-asteroid has no link and storage is never a route source (T188 treated as design); tools/project_workflow.html and other files were modified by something else, left uncommitted.

- Owner: T187 rival ships: look (tint, size, trail, galaxy view) and balance keys rival_ship_count / rival_ship_speed (code defaults 3 and 0.6); gdd.md rivals line edited but left uncommitted with other people's gdd.md changes (gdd-log.md is deleted in tree, so no log entry).

- Owner: T176 placeholder systems are ids 3-5 (not 6 total), off by default (data/systems_placeholder.json enabled:false); permit keys reuse permit_2_*; no Russian text; galaxy overview with them on not exercised windowed.

## 2026-11-05 23:00 run: T198
- Summary: Added game/ship_trail.gd (fading world-space line, gold for player, blue for rivals, paused/hidden handled); ship scale 0.5 via PLAYER_SHIP_SCALE and RIVAL_SHIP_SCALE; SHIP_PICK_PX 30 to 20.
- Why this task: owner-specified (trail, about half size), no QA; T199 leaves marker-vs-tint open (visual).
- Approach: one small trail script used by both ship kinds.
- Agent prompts: juice-programmer, brief = T198 text plus no-QA, no-commit. Produced ship_trail.gd, pathfinder_view.gd, rival_ships.gd, map.gd, handoffs/juice-programmer/2026-11-05-T198.json (verified; tests pass=4017 fail=0 re-run by me).
- Worked: build and tests.
- Failed / did not work: nothing; not seen windowed, no test for the trail.
- Files and commits: see git log "T198".
- Left to do: owner: trail width/tint, size, pick radius. T199 (decide marker vs tint per competitor).

## 2026-11-06 00:00 run: gap analysis (no task done)
- Summary: Reviewed all open tasks. None can be done unattended; no new tasks added (gap analysis of 2026-11-05 already produced T189-T193).
- Why this task: T199 needs a visual decision (marker vs tint, card look) the owner has not made; T189-T192 and T193 are marked "needs owner decision"; T178/T182 are owner-only agents; T185 is visual; T166 is superseded; T05 needs a windowed measurement.
- Approach: skipped rather than guessing visual or design choices.
- Agent prompts: none.
- Worked: nothing built; no code or data touched.
- Failed / did not work: nothing.
- Files and commits: blackboard.md only, no commit (other uncommitted files are not mine).
- Left to do: owner decides T199 look (marker or tint per competitor), then it can run; T189-T193 decisions.

## 2026-11-06 01:00 run: gap analysis (no task done)
- Summary: Re-checked open tasks (T05, T166, T178, T182, T189-T193, T199). State unchanged since the 00:00 run; nothing doable unattended and no new gaps found.
- Why this task: T199 needs a visual decision (marker vs tint, card look); T189-T193 need owner decisions; T178/T182 are owner-only agents; T166 superseded; T05 needs a windowed measurement.
- Approach: skipped rather than guess visual or design choices.
- Agent prompts: none.
- Worked: nothing built; no code or data touched.
- Failed / did not work: nothing.
- Files and commits: blackboard.md only, no commit.
- Left to do: owner decides T199 look, then T189-T193 decisions.

## 2026-11-06 02:00 run: gap analysis (no task done)
- Summary: Re-checked open tasks; state unchanged since the 01:00 run (no new commits, no owner decisions recorded). Nothing doable unattended, no new tasks added.
- Why this task: T199 look (marker vs tint) is a visual decision for the owner; T189-T193 need owner decisions; T178/T182 are owner-only agents; T166 superseded; T05 needs a windowed measurement.
- Approach: skipped rather than guess.
- Agent prompts: none.
- Worked: nothing built; no code touched.
- Failed / did not work: nothing.
- Files and commits: blackboard.md only, no commit.
- Left to do: owner decides T199 look, then T189-T193.

## 2026-11-06 03:00 run: T204
- Summary: Left click on empty space with the ship selected now only drops the selection; clicks on planets, storage and asteroid fields still fly at once; right click and Esc unchanged.
- Why this task: smallest clear, owner-specified, no visual or design decision, no dependencies.
- Approach: edited the open-space branch in game/map.gd myself (one small edit, an agent would cost more).
- Agent prompts: none.
- Worked: edit; sh tools/tests/run.sh pass=4017 fail=0.
- Failed / did not work: no new test for the click (map input is not headless-testable); the "point" kind stays in the flight API, unused by clicks. No story text needed changing.
- Files and commits: game/map.gd, schedule.json, blackboard.md; see git log "T204".
- Left to do: other queued tasks T203, T205-T208, T210-T218 remain open (T209 owner-only, T218 waits on T216/T217).
