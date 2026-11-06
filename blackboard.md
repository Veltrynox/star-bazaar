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

## 2026-11-05 17:00 run: T228
- Summary: Stop exploring and manual orders already changed the Pathfinder state while paused, but the ship panel was not refreshed, so the button looked dead. set_exploring and the map order handlers in main.gd now call on_flight_changed.
- Why this task: small concrete playtest bug, no dependencies, no visual or economy-agent need.
- Approach: small edit by me in main.gd; refresh at the call sites instead of ticking the panel while paused.
- Agent prompts: none.
- Worked: sh tools/tests/run.sh pass=11303 fail=0; test added (mode off while paused, label follows).
- Failed / did not work: nothing; not tried windowed. No handoff file (no agent used).
- Files and commits: game/main.gd, tools/tests/run_tests.gd, schedule.json, blackboard.md; see git log "T228".
- Left to do: owner: confirm windowed. A manual order given while paused sets the target but the ship moves only when unpaused.

## 2026-11-05 18:00 run: T229
- Summary: The end screen showed a raw "{workshop}" token (reported as "[workshop]") in the tech epilogue lines. epilogue_lines in end_screen.gd now fills it with the win market's workshop name (lower case). A headless test scans every market and tech count for raw tokens.
- Why this task: small concrete playtest bug, no dependencies, no visual or economy-agent need.
- Approach: code fix at the call site (the text already uses the documented {workshop} placeholder) instead of rewriting the story text.
- Agent prompts: none (small edit by me).
- Worked: sh tools/tests/run.sh pass=11304 fail=0; new test _test_epilogue_placeholders.
- Failed / did not work: nothing. No handoff file (no agent used). Not seen windowed.
- Files and commits: game/end_screen.gd, tools/tests/run_tests.gd, schedule.json, blackboard.md; see git log "T229".
- Left to do: owner: confirm windowed ("one tech came out of the smelter"). Ending body texts were not scanned beyond epilogue lines.

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
