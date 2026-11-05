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

## 2026-11-05 20:00 run: T201
- Summary: Added headless `_test_ship_facing` in tools/tests/run_tests.gd: Pathfinder (4 models) and rivals (all systems) face 8 headings within 2 deg, up stays up, turns are gradual and end aligned, resting ships keep heading, every ship id has a MODEL_YAW_DEG entry. No code bugs found.
- Why this task: unblocked by T197, no owner decision, small; T200 is larger.
- Approach: test only, agent-built; assumes model nose is its own -X (documented in game/ships.gd).
- Agent prompts: gameplay-programmer, brief = T201 text plus no-QA, no-commit. Produced run_tests.gd change and handoffs/gameplay-programmer/2026-11-05-T201.json (verified).
- Worked: sh tools/tests/run.sh pass=3073 fail=0.
- Failed / did not work: nothing. Pathfinder not tested in a second solar system separately.
- Files and commits: tools/tests/run_tests.gd, schedule.json, blackboard.md, handoff; commit "T201 ... [no-gdd]".
- Left to do: T200, T198, T199. Unrelated uncommitted files (README.md, tools/build_readme.py, etc.) left alone.

## 2026-11-05 21:00 run: T200
- Summary: Ship controls built: click selects the Pathfinder (cyan ring), left click flies at once, right click on a planet opens a menu of allowed outpost actions (flies then builds on arrival), Esc or right click on open space deselects. Outposts now build in 0.025 cycles (data_version 58); tutorial texts TUT_G0_FLY/TUT_G0_BUILD updated (EN and RU).
- Why this task: largest-value open build task with dependency done and no owner decision; T198/T199 are visual.
- Approach: gameplay-programmer built it in one pass; no separate ui-programmer, menu is a plain PopupMenu.
- Agent prompts: gameplay-programmer, brief = T200 text plus no-QA, no-commit. Produced pathfinder.gd, pathfinder_view.gd, map.gd, main.gd, balance.json, story sources and generated files, handoffs/gameplay-programmer/2026-11-05-T200.json (verified, tests re-run by me: pass=3073 fail=0).
- Worked: build and tests.
- Failed / did not work: no confirm dialog existed in code to remove (old flow was click-to-fly, Shift+click, panel button). No new test for the flow; not seen windowed. Committed [no-gdd] (gdd has no controls text).
- Files and commits: see git log "T200".
- Left to do: owner: deselect by left click on empty space conflicts with fly-there; no menu on storage/asteroids (add Fly here?); selected look and menu style. Add a test for the flow if wanted.

## 2026-11-05 22:00 run: T202
- Summary: Added headless test _test_ships_spawn_near_bodies (944 checks, systems 1-5, two zooms): ships never inside a body, and within radius+SPAWN_GAP at spawn. Fixed bugs it found: Pathfinder docked at planet centre (new Map.dock_point), rivals spawned inside planets/sun, old saves with ship at centre, later systems got no rivals.
- Why this task: only open build task with no visual or owner decision; T198/T199 are visual.
- Approach: gameplay-programmer, constants Motion.BODY_MARGIN/SPAWN_GAP in game/ship_motion.gd reused by game code.
- Agent prompts: gameplay-programmer, brief = T202 text plus no-QA, no-commit. Produced map.gd, pathfinder.gd, rival_ships.gd, ship_motion.gd, run_tests.gd, handoffs/gameplay-programmer/2026-11-05-T202.json (verified).
- Worked: sh tools/tests/run.sh pass=4017 fail=0 (re-run by me).
- Failed / did not work: nothing. Only spawn/course-end points checked; ships can still fly through bodies in transit. Not seen windowed. Committed [no-gdd].
- Files and commits: see git log "T202".
- Left to do: owner to check dock position look windowed; path-through-body avoidance not done.

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
