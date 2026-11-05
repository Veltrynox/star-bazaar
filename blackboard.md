# Main agent blackboard

## Do not repeat
- Do not flip discovery_enabled in data/balance.json to fix tests: it ships at 0 on purpose (gdd.md); tests set it themselves.

## Left to do
- Open: T185, T176, T178/T182 (owner-only agents), T05, T166.

- Owner: ship cap 20 (T186): decide on economy retune (trip cost, maintenance tuned for 6) and look of the scrolled ship list; other panels not checked at 20 ships.
- Owner: asteroid-asteroid has no link and storage is never a route source (T188 treated as design); tools/project_workflow.html and other files were modified by something else, left uncommitted.

- Owner: T187 rival ships: look (tint, size, trail, galaxy view) and balance keys rival_ship_count / rival_ship_speed (code defaults 3 and 0.6); gdd.md rivals line edited but left uncommitted with other people's gdd.md changes (gdd-log.md is deleted in tree, so no log entry).

## 2026-11-05 run: T183
- Summary: The 15 test failures were stale test expectations, not game bugs. Discovery ships off (balance discovery_enabled 0), but the tests' discovery-on helper only switched it off, never on; and the save VERSION tests still said 6 (now 7). Fixed in tools/tests/run_tests.gd.
- Why this task: first in queue, unblocks T188, small and certain.
- Approach: fix tests, not code or balance, since the off default is documented in gdd.md.
- Agent prompts: none, edit done directly (two small changes).
- Worked: sh tools/tests/run.sh pass=1915 fail=0.
- Failed / did not work: the "Parse JSON failed" log line is a deliberate bad-file test, not a failure. No handoff file written (no agent used).
- Files and commits: tools/tests/run_tests.gd, schedule.json, blackboard.md.
- Left to do: nothing for T183.

## 2026-11-05 run: T184
- Summary: Fixed planet panel closing when another planet's icon is clicked inside it. Cause: Thumb and RouteRow in game/planet_panel.gd emitted pressed before accept_event(); the rebuild removed the icon, so the click leaked to the map, which sent planet_clicked(-1) and hid the panel. Swapped the order; added _test_panel_thumb_switch.
- Why this task: first open task that is fully doable and needs no owner decision (T184 bug, no visual choice); T186/T187 also possible later.
- Approach: root-cause fix of event order, not a map-side workaround.
- Agent prompts: ui-programmer, brief = T184 text (fix, headless regression test, no visual change). Produced game/planet_panel.gd, tools/tests/run_tests.gd, handoffs/ui-programmer/2026-11-05-T184.json (verified via git status).
- Worked: sh tools/tests/run.sh pass=1922 fail=0.
- Failed / did not work: panel has no storage icon (storage is a map marker); storage case tested as storage view open then thumbnail click. Not seen in a windowed run.
- Files and commits: game/planet_panel.gd, tools/tests/run_tests.gd, schedule.json, blackboard.md, handoff.
- Left to do: nothing for T184.

## 2026-11-05 run: T188
- Summary: Added headless test _test_links_everywhere (tools/tests/run_tests.gd): every node-type pair, same and cross system, route/storage link built with the game's own functions, saved and reloaded, plus reachability of all nodes. Run with discovery off and on. No game bugs found.
- Why this task: unblocked by T183, clear spec, no owner decision or visual question.
- Approach: test only, via real purchase paths for unlocks rather than forcing state.
- Agent prompts: gameplay-programmer, brief = T188 text. Produced run_tests.gd changes and handoffs/gameplay-programmer/2026-11-05-T188.json (verified).
- Worked: sh tools/tests/run.sh pass=2810 fail=0.
- Failed / did not work: nothing. Many unrelated modified files in the tree (agents, gdd.md, gdd_sync.py, overnight.py, project_workflow.html, gdd-log.md deleted) are not mine; left alone.
- Files and commits: tools/tests/run_tests.gd, schedule.json, blackboard.md, handoff.
- Left to do: owner to decide on asteroid-asteroid links and storage as route source.

## 2026-11-05 15:00 run: T186
- Summary: ship_cap raised 6 to 20 (data_version 55). No hard-coded old caps found; Ships panel upkeep list and Null Core Fit buttons now scroll with capped height.
- Why this task: clear spec, no dependencies, no owner decision needed (T187 larger, T185 visual).
- Approach: data change plus minimal functional scroll containers; look decisions left to owner.
- Agent prompts: gameplay-programmer, brief = T186 text plus no-QA rule. Produced data/balance.json, game/ship_panel.gd, handoffs/gameplay-programmer/2026-11-05-T186.json (verified).
- Worked: sh tools/tests/run.sh pass=2810 fail=0.
- Failed / did not work: nothing; not seen windowed.
- Files and commits: data/balance.json, game/ship_panel.gd, schedule.json, blackboard.md, handoff.
- Left to do: owner decides economy retune and scroll vs compact rows.

## 2026-11-05 run: T187
- Summary: Checked the six flight rules. Five already worked; added game/rival_ships.gd (scenery rival ships, visual only) and test _test_t187_ship_flight.
- Why this task: only open task that is doable with no owner decision or QA; T185 is visual, T176 larger placeholder data.
- Approach: audit first, then fill only the gap.
- Agent prompts: gameplay-programmer, brief = T187 text plus CLAUDE.md rules. Produced rival_ships.gd, main.gd, run_tests.gd, handoffs/gameplay-programmer/2026-11-05-T187.json (verified).
- Worked: sh tools/tests/run.sh pass=2849 fail=0.
- Failed / did not work: commits made with [no-gdd] because gdd.md has others' uncommitted edits; I edited the Rivals line in gdd.md but did not commit it. CLAUDE.md also has an uncommitted change not mine.
- Files and commits: ada9682, afd61a7; schedule.json, blackboard.md, gdd.md (uncommitted).
- Left to do: owner decisions listed above; mining on a platform is manual (Buy order then Send), note for gdd.
