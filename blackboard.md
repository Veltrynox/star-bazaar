# Main agent blackboard

## Do not repeat
- discovery_enabled in data/balance.json ships at 1 (owner decision 2026-11-05); tests that need it off set it themselves.

## Left to do
- T237 done: four TXT_CEO_*_BRANCH_TAG ids exist but are not shown yet (T236 must wire them); SETUP_NEXT still reads 'Next'. story/voice.md has uncommitted owner edits, left alone.
- Owner: T219 lane draw-in/fade/pulse not seen windowed (constants atop route_line.gd); route made while paused shows no draw-in.
- Owner: T203 establish beat not seen windowed (ring/spokes vs bright planets, nudge softness, dead worlds); follow-up juice tasks T219-T221 queued.
- Owner: T205 trail look windowed: ship_trail.gd WIDTH 0.16, ships.gd ENGINE_BACK 0.9 for all models (exact exhaust positions not measured from the GLBs).
- Open build tasks from playtest: none of T196-T202 left (T199 done 2026-11-06). Owner: check T198 look windowed (trail line 1px, scale 0.5, pick 20px). T194 done; Competitors still reachable from share panel (L), owner to say if that goes too.
- Open: T185 (visual), T178/T182 (owner-only agents), T05 (only windowed frame time missing, see T193), T166 (superseded). Owner-decision tasks T189-T193 added 2026-11-05.

- Owner: ship cap 20 (T186): decide on economy retune (trip cost, maintenance tuned for 6) and look of the scrolled ship list; other panels not checked at 20 ships.
- Owner: asteroid-asteroid has no link and storage is never a route source (T188 treated as design); tools/project_workflow.html and other files were modified by something else, left uncommitted.

- Owner: T187 rival ships: look (tint, size, trail, galaxy view) and balance keys rival_ship_count / rival_ship_speed (code defaults 3 and 0.6); gdd.md rivals line edited but left uncommitted with other people's gdd.md changes (gdd-log.md is deleted in tree, so no log entry).

- Owner: T176 placeholder systems are ids 3-5 (not 6 total), off by default (data/systems_placeholder.json enabled:false); permit keys reuse permit_2_*; no Russian text; galaxy overview with them on not exercised windowed.

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

## 2026-11-06 10:00 run: T237
- Summary: Added a branch tag per CEO (TXT_CEO_*_BRANCH_TAG, max 40 chars) and one sentence at the end of each CEO bio naming market and ship, English only, built with tools/build_story.py.
- Why this task: small, dependency T235 done, text only, no visual, economy or QA need.
- Approach: story-designer agent, source in story/screens.md; no UI wiring since that is T236.
- Agent prompts: write tags and bio sentences per the T237 brief, no commit; produced story/screens.md, data/story_text.json, handoffs/story-designer/2026-11-05-T237.json, done.
- Worked: sh tools/tests/run.sh pass=11318 fail=0.
- Failed / did not work: agent saw a JSON parse message from game/run_stats.gd in the test log (not a FAIL, unrelated, not investigated).
- Files and commits: story/screens.md, data/story_text.json, handoff, schedule.json, blackboard.md; see git log "T237".
- Left to do: T236 must show the tags on the pick card; owner: SETUP_NEXT label "Next" vs "Start".
