# Main agent blackboard

## Do not repeat
- discovery_enabled in data/balance.json ships at 1 (owner decision 2026-11-05); tests that need it off set it themselves.

## Left to do
- Owner: T219 lane draw-in/fade/pulse not seen windowed (constants atop route_line.gd); route made while paused shows no draw-in.
- Owner: T203 establish beat not seen windowed (ring/spokes vs bright planets, nudge softness, dead worlds); follow-up juice tasks T219-T221 queued.
- Owner: T205 trail look windowed: ship_trail.gd WIDTH 0.16, ships.gd ENGINE_BACK 0.9 for all models (exact exhaust positions not measured from the GLBs).
- Open build tasks from playtest: none of T196-T202 left (T199 done 2026-11-06). Owner: check T198 look windowed (trail line 1px, scale 0.5, pick 20px). T194 done; Competitors still reachable from share panel (L), owner to say if that goes too.
- Open: T185 (visual), T178/T182 (owner-only agents), T05 (only windowed frame time missing, see T193), T166 (superseded). Owner-decision tasks T189-T193 added 2026-11-05.

- Owner: ship cap 20 (T186): decide on economy retune (trip cost, maintenance tuned for 6) and look of the scrolled ship list; other panels not checked at 20 ships.
- Owner: asteroid-asteroid has no link and storage is never a route source (T188 treated as design); tools/project_workflow.html and other files were modified by something else, left uncommitted.

- Owner: T187 rival ships: look (tint, size, trail, galaxy view) and balance keys rival_ship_count / rival_ship_speed (code defaults 3 and 0.6); gdd.md rivals line edited but left uncommitted with other people's gdd.md changes (gdd-log.md is deleted in tree, so no log entry).

- Owner: T176 placeholder systems are ids 3-5 (not 6 total), off by default (data/systems_placeholder.json enabled:false); permit keys reuse permit_2_*; no Russian text; galaxy overview with them on not exercised windowed.

## 2026-11-05 19:00 run: T231
- Summary: Map scaled 1.4x (MAP_SCALE_UP, folded into MAP_UNIT_SCALE; clusters, routes, exits, zoom and pan follow) and planets 1.3x on top of the earlier 1.3x (PLANET_SCALE_UP; PLANET_SIZE now 1.69, pick minimum scaled).
- Why this task: concrete owner request with given numbers, no dependencies, no look decision beyond the factors given.
- Approach: gameplay-programmer agent with named constants in one place; pathfinder speed is in data units times MAP_UNIT_SCALE so flight time stays the same.
- Agent prompts: scale map and planets, one place for factors, consistent clusters/exits, report travel time; handoffs/gameplay-programmer/2026-11-05-T231.json (files_changed list omits run_tests.gd), done.
- Worked: sh tools/tests/run.sh fail=0 (pass=11286); three tests updated to the 1.69 default.
- Failed / did not work: nothing; not seen windowed.
- Files and commits: game/map.gd, game/system_exit.gd, tools/tests/run_tests.gd, handoff, schedule.json, blackboard.md; see git log "T231".
- Left to do: owner: look windowed (framing, START_ZOOM, planet size vs sun and asteroid packs, labels).

## 2026-11-05 20:00 run: T225
- Summary: Skill-screen prerequisite lines no longer cross node boxes. _draw_links in skill_screen.gd cuts each axis-aligned segment at every visible node box (new static clip_segment), so lines stop at edges and resume after.
- Why this task: concrete bug, no dependencies, no visual decision (a draw-order/clipping fix), no QA or economy agent needed.
- Approach: clip segments in code instead of making node backgrounds opaque (that would change the look, an owner decision).
- Agent prompts: none (small edit by me).
- Worked: sh tools/tests/run.sh pass=11289 fail=0; test _test_skill_link_clip added.
- Failed / did not work: nothing. Not seen windowed. No handoff file (no agent used).
- Files and commits: game/skill_screen.gd, tools/tests/run_tests.gd, schedule.json, blackboard.md; see git log "T225".
- Left to do: owner: confirm windowed on all three branches (e.g. Price Whisper); a line can still run in the gap between rows, which is intended.

## 2026-11-05 21:00 run: T235
- Summary: The CEO now fixes the branch (min, lux, mil, bio) and the ship type; New Game goes from the company screen straight into the game. Branch stored as run.branch; Ceos.branch/ship and main.run_branch() added.
- Why this task: concrete owner request, no dependencies, no visual or economy-agent need.
- Approach: gameplay-programmer agent; no later branch choice existed in code, so win and ending rules are untouched; ship_setup files kept out of the path.
- Agent prompts: implement T235 brief, English only, no commit; handoffs/gameplay-programmer/2026-11-05-T235.json (CEO table: Marek min/fleet, Idris lux/dart, Sela mil/bulk, Tamsin bio/small), done.
- Worked: sh tools/tests/run.sh pass=11292 fail=0; three tests added.
- Failed / did not work: nothing; not seen windowed.
- Files and commits: data/ceos.json, game/ceos.gd, game/company_setup.gd, game/main.gd, game/save_game.gd, gdd.md, tools/tests/run_tests.gd, handoff, schedule.json, blackboard.md; see git log "T235".
- Left to do: story-designer: SETUP_NEXT text still says "Next" (code default now "Start"). ship_setup.gd/.tscn kept because qa/bots/ship_setup_shot.gd loads them. Owner: check the CEO-to-branch mapping. T236, T237 next.

## 2026-11-06 12:00 run: T241
- Summary: Skill screen now shows only Foundations and the run's branch tree; other-branch skills cannot be learned or selected (SkillTree.run_branch). Old saves show all trees. Dead-world refusal no longer names another branch's skill.
- Why this task: owner request, dependency T235 done, no economy/QA agent, layout rule given by owner (fill the screen).
- Approach: ui-programmer agent; filter at tree build and at can_learn so every learn path is covered.
- Agent prompts: build branch-filtered skill screen, block other-branch learning, tests; produced handoffs/ui-programmer/2026-11-06-T241.json, done.
- Worked: sh tools/tests/run.sh fail=0 per agent (pass=11318); my re-run output tail showed only leak warnings.
- Failed / did not work: nothing; layout not seen windowed.
- Files and commits: game/skill_tree.gd, skill_screen.gd, main.gd, route_engine.gd, tools/tests/run_tests.gd, gdd-skills.md, handoff, schedule.json, blackboard.md; see git log "T241".
- Left to do: owner: open skill screen (K) per CEO branch and judge layout (CELL_W_MAX 250). Story-designer: add text id NOT_DEAD_OTHER_BRANCH (fallback "Mining here is closed to your company." in use).
