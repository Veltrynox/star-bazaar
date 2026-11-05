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

## 2026-11-06 05:00 run: T215
- Summary: Removed the bottom-middle route legend strip (game/route_legend.gd, its block in main.gd, three text ids only it used). Pending-destination banner kept.
- Why this task: clear owner request, no dependencies, no visual or design decision (pure removal).
- Approach: ui-programmer agent for the removal; I verified the diff.
- Agent prompts: remove the route hint strip at the bottom, drop its state and own text ids, keep other hints; handoffs/ui-programmer/2026-11-06-T215.json, done.
- Worked: sh tools/tests/run.sh pass=4017 fail=0 (agent run).
- Failed / did not work: nothing. Not seen windowed.
- Files and commits: game/main.gd, game/route_legend.gd(+uid) deleted, story/screens.md, data/story_text.json, schedule.json, blackboard.md; see git log "T215".
- Left to do: owner confirms "route hint" meant the legend and not the pending banner ("Send X from Y: click the destination"); if the banner, remove it too.

## 2026-11-06 06:00 run: T213
- Summary: The "Not enough cash" rule is correct at 2k cash; the message was a stale snapshot from the last cycle end, shown next to the current balance. Route row, map tag and buy row now show the needed and available amounts.
- Why this task: real bug investigation with a clear brief, no visual or design decision, no dependencies.
- Approach: gameplay-programmer agent for the code trace and fix; I verified diff and tests.
- Agent prompts: find what is compared in route_engine.gd, fix or reword the text to show amounts, add a test, text via ids; handoffs/gameplay-programmer/2026-11-06-T213.json, done.
- Worked: sh tools/tests/run.sh pass=4022 fail=0. Test _test_no_cash_text added.
- Failed / did not work: nothing. Not seen windowed.
- Files and commits: game/route_engine.gd, story/screens.md, data/story_text.json, tools/tests/run_tests.gd, handoff, schedule.json, blackboard.md; see git log "T213".
- Left to do: owner decides whether a stalled state should clear mid-cycle when cash rises (now only the last-cycle snapshot, left unchanged). No Russian text for the two changed ids.

## 2026-11-06 07:00 run: T211
- Summary: Rival scenery ships are now one per competitor (3 total) instead of 3 per system; they live in system 1 and visit only permit-opened systems, shown only in their own system. Pathfinder was already a single ship.
- Why this task: clear owner brief, no dependencies, no visual decision; unblocks T214.
- Approach: gameplay-programmer agent; I verified diff and tests.
- Agent prompts: one ship per owner, none in closed systems, keep saves, test, gdd; handoffs/gameplay-programmer/2026-11-06-T211.json, done.
- Worked: tests pass (see run.sh output); new _test_t211_ship_traffic.
- Failed / did not work: one "Parse JSON failed" log line, also present without the change.
- Files and commits: game/rival_ships.gd, gdd.md, tools/tests/run_tests.gd, handoff, schedule.json, blackboard.md; see git log "T211".
- Left to do: rival_ship_count key retired (was absent from balance.json). T214 (idle after trip) now unblocked. Not seen windowed.

## 2026-11-06 08:00 run: T214
- Summary: Rival ships now idle on arrival instead of picking a new random course; they move one leg again only on wake(): a system newly opened by permit, or an event popup appearing.
- Why this task: clear owner brief, dependency T211 done, no visual decision; other open tasks are visual, owner-only or need decisions.
- Approach: small change in game/rival_ships.gd done by me (an agent would cost more); trigger set (permit open, event popup) was my reading of "a reason", kept minimal.
- Agent prompts: none.
- Worked: sh tools/tests/run.sh pass=11145 fail=0; new test for idling and wake; four older rival tests adapted to call wake().
- Failed / did not work: nothing. Not seen windowed.
- Files and commits: game/rival_ships.gd, tools/tests/run_tests.gd, gdd.md, schedule.json, blackboard.md; see git log "T214".
- Left to do: owner says if other reasons should wake rivals (competitor trades in a system); balance key rival_ship_wait_s is now unused (left in data/balance.json).
