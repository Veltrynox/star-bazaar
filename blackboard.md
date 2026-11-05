# Main agent blackboard

## Do not repeat
- Do not flip discovery_enabled in data/balance.json to fix tests: it ships at 0 on purpose (gdd.md); tests set it themselves.

## Left to do
- Open: T185, T186, T187, T176, T178/T182 (owner-only agents), T05, T166.

- Owner: asteroid-asteroid has no link and storage is never a route source (T188 treated as design); tools/project_workflow.html and other files were modified by something else, left uncommitted.

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
