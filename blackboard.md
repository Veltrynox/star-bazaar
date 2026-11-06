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

## 2026-11-06 14:00 run: T219
- Summary: Route lanes now draw in from the source end (0.25 s ease-out), fade on removal (0.15 s) and show one brighter band on dispatch (0.5 s). Effects snap to the end state while paused.
- Why this task: first of the juice follow-ups, no dependencies, no look decision; other open tasks are owner-only or need decisions.
- Approach: juice-programmer agent in route_line.gd with hooks in map.gd; I verified diff and tests.
- Agent prompts: draw-in, removal fade, dispatch pulse, game time only, constants, one headless curve test; handoffs/juice-programmer/2026-11-06-T219.json, done.
- Worked: sh tools/tests/run.sh pass=11277 fail=0.
- Failed / did not work: nothing; not seen windowed.
- Files and commits: game/route_line.gd, game/map.gd, tools/tests/run_tests.gd, handoff, schedule.json, blackboard.md; see git log "T219".
- Left to do: owner: look windowed (pulse readability, width growth); route made while paused (game starts paused) has no draw-in; lane tag not pinged.

## 2026-11-06 15:00 run: T232
- Summary: Ship cap set from 20 to 10 (data/balance.json ship_cap); saves with more ships clamp on load (existing clamp in main.gd). Comments in ship_panel.gd updated.
- Why this task: smallest concrete owner request, no dependencies, no visual or economy-agent need; other open tasks are larger, visual, or owner-only.
- Approach: one-value edit done by me; no agent needed. Cap-name text search found no story ids to change.
- Agent prompts: none.
- Worked: sh tools/tests/run.sh pass=11300 fail=0.
- Failed / did not work: first sed (BSD) errored on a stray line-number form; redone with sed -i ''. No handoff file (no agent used).
- Files and commits: data/balance.json, game/ship_panel.gd, schedule.json, blackboard.md; see git log "T232".
- Left to do: owner: economy was tuned for 6 ships; cap 10 not retuned (economy agents run only by owner).

## 2026-11-05 16:00 run: T222
- Summary: Every button now drops keyboard focus after a mouse click (hook in Juice._press_for), so Space after "Start exploring" only toggles pause and no longer presses the focused button.
- Why this task: concrete bug, no dependencies, no visual or economy-agent need; most other open tasks are larger, owner-only or need decisions.
- Approach: one global hook where all buttons are already wired, instead of editing each button's focus_mode.
- Agent prompts: none.
- Worked: sh tools/tests/run.sh pass=11300 fail=0.
- Failed / did not work: no headless test added; not tried windowed.
- Files and commits: game/juice.gd, schedule.json, blackboard.md; see git log "T222".
- Left to do: owner: confirm windowed that Space no longer flips the explore button; keyboard Enter on a focused button still works. T228 (stop while paused) still queued.

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
