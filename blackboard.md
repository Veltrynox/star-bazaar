# Main agent blackboard

## Do not repeat
- discovery_enabled in data/balance.json ships at 1 (owner decision 2026-11-05); tests that need it off set it themselves.

## Left to do
- Open build tasks from playtest: T198, T199 (T196, T197, T200, T201, T202 done). T194 done; Competitors still reachable from share panel (L), owner to say if that goes too.
- Open: T185 (visual), T178/T182 (owner-only agents), T05 (only windowed frame time missing, see T193), T166 (superseded). Owner-decision tasks T189-T193 added 2026-11-05.

- Owner: ship cap 20 (T186): decide on economy retune (trip cost, maintenance tuned for 6) and look of the scrolled ship list; other panels not checked at 20 ships.
- Owner: asteroid-asteroid has no link and storage is never a route source (T188 treated as design); tools/project_workflow.html and other files were modified by something else, left uncommitted.

- Owner: T187 rival ships: look (tint, size, trail, galaxy view) and balance keys rival_ship_count / rival_ship_speed (code defaults 3 and 0.6); gdd.md rivals line edited but left uncommitted with other people's gdd.md changes (gdd-log.md is deleted in tree, so no log entry).

- Owner: T176 placeholder systems are ids 3-5 (not 6 total), off by default (data/systems_placeholder.json enabled:false); permit keys reuse permit_2_*; no Russian text; galaxy overview with them on not exercised windowed.

## 2026-11-05 19:00 run: T197
- Summary: Ships now face their heading: per-model yaw offset MODEL_YAW_DEG in game/ships.gd (all four ship ids -90), applied via a pivot node in pathfinder_view.gd and rival_ships.gd.
- Why this task: clear bug fix, no owner decision; unblocks T201.
- Approach: code offset table keyed by ship id (readable by the T201 test), no model file edits.
- Agent prompts: ui-programmer, brief = T197 text plus no-QA, no-commit. Produced the three game files and handoffs/ui-programmer/2026-11-05-T197.json (verified).
- Worked: sh tools/tests/run.sh pass=2875 fail=0.
- Failed / did not work: nothing; not seen windowed. Nose end inferred from vertex widths; ship_corvette_01 least certain.
- Files and commits: game/ships.gd, game/pathfinder_view.gd, game/rival_ships.gd, schedule.json, blackboard.md, handoff; commit "T197 ... [no-gdd]".
- Left to do: owner checks windowed that no ship flies backwards (flip entry to 90). Models 05-08 are not in ships.json and have no offset. Next: T201, T200.

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
