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

## 2026-11-06 11:00 run: T199
- Summary: Rival ships now belong to a competitor (ship i = Bots.IDS[i]) with a faint per-competitor tint; a click within 20px opens a small card with the competitor name and its strongest market. Planets behind stay clickable outside the radius.
- Why this task: concrete owner brief, dependency done; other open tasks are owner-decision, owner-only, or design proposals.
- Approach: ui-programmer agent reusing the DestHint card style; I verified diff and tests.
- Agent prompts: tint per competitor, click card with name and market, no planet blocking, English ids, test; handoffs/ui-programmer/2026-11-06-T199.json, done.
- Worked: sh tools/tests/run.sh no FAIL; _test_t199_rival_pick added.
- Failed / did not work: nothing; 3 "Parameter material is null" engine errors also appear without the change.
- Files and commits: game/rival_ships.gd, game/rival_card.gd, game/map.gd, game/main.gd, story/screens.md, data/story_text.json, tools/tests/run_tests.gd, gdd.md, handoff, schedule.json, blackboard.md; see git log "T199".
- Left to do: owner: tint colours (TINTS red/violet/green, alpha 0.3), pick radius 20px and card position not seen windowed; "its market" read as strongest-share market; competitor names have no story ids; click on a ship does not pass to a planet; no Russian ids.

## 2026-11-06 12:00 run: T205
- Summary: Ship trails are now tapered ribbons about 0.16 wide (was a 1px line) and start at an engine point behind the ship (per-model constant Ships.ENGINE_BACK), for the player and rival ships.
- Why this task: concrete owner brief, no dependencies, widths were specified; other open tasks are owner-only, visual decisions, or design proposals.
- Approach: small edit done by me (ships.gd, ship_trail.gd, pathfinder_view.gd, rival_ships.gd); ribbon lies flat in the map plane.
- Agent prompts: none.
- Worked: sh tools/tests/run.sh pass=11273 fail=0.
- Failed / did not work: nothing; not seen windowed, exhaust offset 0.9 is a guess for all models.
- Files and commits: game/ships.gd, game/ship_trail.gd, game/pathfinder_view.gd, game/rival_ships.gd, schedule.json, blackboard.md; see git log "T205".
- Left to do: owner: check width/offset windowed and set per-model ENGINE_BACK; no handoff file written (no agent used).

## 2026-11-06 13:00 run: T203
- Summary: Establishing a trading post or mining platform now plays a 1.1 s beat: closing ring, 10 sparkle spokes, planet label pop and a small camera nudge. The agent also queued juice tasks T219-T221.
- Why this task: owner brief with concrete effects, no dependencies, no decision needed; other open tasks are owner-only, need decisions, or depend on designs.
- Approach: juice-programmer agent, hook map.establish_beat from main._on_flight_build_done; I verified diff and tests.
- Agent prompts: build the beat (pause-safe, no text, cheap), then add 3 own juice tasks; handoffs/juice-programmer/2026-11-06-T203.json, done.
- Worked: sh tools/tests/run.sh pass=11276 fail=0; _test_juice checks curves.
- Failed / did not work: nothing; run output has a "Parse JSON failed" and 3 "material is null" errors, not checked whether older.
- Files and commits: game/main.gd, map.gd, pathfinder_view.gd, tools/tests/run_tests.gd, schedule.json, handoff, blackboard.md; see git log "T203".
- Left to do: owner: look windowed (colours signal_good/star_warm, tunables BURST_* in pathfinder_view.gd, ESTABLISH_NUDGE in map.gd); T219-T221 queued.

## 2026-11-06 14:00 run: T219
- Summary: Route lanes now draw in from the source end (0.25 s ease-out), fade on removal (0.15 s) and show one brighter band on dispatch (0.5 s). Effects snap to the end state while paused.
- Why this task: first of the juice follow-ups, no dependencies, no look decision; other open tasks are owner-only or need decisions.
- Approach: juice-programmer agent in route_line.gd with hooks in map.gd; I verified diff and tests.
- Agent prompts: draw-in, removal fade, dispatch pulse, game time only, constants, one headless curve test; handoffs/juice-programmer/2026-11-06-T219.json, done.
- Worked: sh tools/tests/run.sh pass=11277 fail=0.
- Failed / did not work: nothing; not seen windowed.
- Files and commits: game/route_line.gd, game/map.gd, tools/tests/run_tests.gd, handoff, schedule.json, blackboard.md; see git log "T219".
- Left to do: owner: look windowed (pulse readability, width growth); route made while paused (game starts paused) has no draw-in; lane tag not pinged.
