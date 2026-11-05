# Blackboard archive

Older run entries moved from blackboard.md, oldest first.

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

## 2026-11-05 run: T176
- Summary: Added three placeholder solar systems (ids 3-5) in data/systems_placeholder.json, off by default, flagged placeholder:true, with never-true availability rules and English text ids.
- Why this task: only open task doable without owner decision, QA or visual choice (T185 visual, T178/T182 owner-only, T05/T166 not pressing).
- Approach: separate file loaded only when enabled, so win condition, permits and economy ignore them.
- Agent prompts: gameplay-programmer, brief = T176 text plus CLAUDE.md rules and no QA. Produced data/systems_placeholder.json, game/systems.gd, availability.json, story/screens.md, story_text.json, run_tests.gd, handoffs/gameplay-programmer/2026-11-05-T176.json (verified).
- Worked: sh tools/tests/run.sh pass=2856 fail=0.
- Failed / did not work: nothing. Committed with [no-gdd] since features are off and gdd.md holds others' edits.
- Files and commits: see git log "Placeholder solar systems (T176)".
- Left to do: owner decides count (3-5 vs 6), real permit keys (economy-designer), Russian text.

## 2026-11-05 run: gap analysis
- Summary: No open task could be done: T185 is visual, T178/T182 owner-only, T166 superseded by T171, T05 already has density grid and sun propagation (only windowed frame_time_ms missing). Added owner-decision tasks T189-T193 from existing blackboard and GDD open items.
- Why this task: nothing else was doable under the rules.
- Approach: reused already-recorded open items instead of inventing features.
- Agent prompts: none.
- Worked: schedule.json updated with five queued tasks.
- Failed / did not work: nothing. Did not run the game or any agent.
- Files and commits: schedule.json, blackboard.md (committed).
- Left to do: owner works through T189-T193.

## 2026-11-05 run: gap analysis (repeat)
- Summary: Re-checked the open tasks. T185 is visual, T178/T182 are owner-only agents, T166 is superseded, and T189-T193 all say "needs owner decision". Nothing new to add.
- Why this task: no open task is doable under the rules.
- Approach: did not invent tasks; the earlier gap analysis already covers the open items.
- Agent prompts: none.
- Worked: confirmed the schedule is unchanged.
- Failed / did not work: nothing.
- Files and commits: blackboard.md only.
- Left to do: owner works through T189-T193.

## 2026-11-05 16:00 run: T194
- Summary: Removed the Competitors entry from the in-game main menu (game/game_menu.gd). The Competitors panel stays reachable from the share panel button (L).
- Why this task: smallest clear playtest task, no dependencies, no visual decision; T196 is large and gates T197-T200.
- Approach: direct edit by main session, cheaper than an agent for a two-line change.
- Agent prompts: none.
- Worked: sh tools/tests/run.sh pass=2856 fail=0. Committed [no-gdd]; gdd line still true (menu reachable via share panel).
- Failed / did not work: a sed on gdd.md failed (macOS syntax), so gdd.md was not touched. No handoff file (no agent).
- Files and commits: game/game_menu.gd, schedule.json, blackboard.md; see git log "T194".
- Left to do: owner decides whether the share panel Competitors button also goes. Next runs: T195, then T196.

## 2026-11-05 17:00 run: T195
- Summary: Voice narration default volume lowered from 1.0 to 0.5 (const DEFAULT_VOLUME in game/voice.gd), used for new installs; a saved value is kept and the slider is unchanged.
- Why this task: smallest open build task with no dependency or visual question; T196 is large and gates T197-T201.
- Approach: direct edit by main session, three lines, cheaper than an agent.
- Agent prompts: none. No handoff file (no agent).
- Worked: sh tools/tests/run.sh pass=2856 fail=0.
- Failed / did not work: nothing. schedule.json already had uncommitted owner additions (T200 note, T201); they were committed along with my status change.
- Files and commits: game/voice.gd, schedule.json, blackboard.md; commit "T195 ... [no-gdd]".
- Left to do: owner may want a different level than 0.5. Next: T196.

## 2026-11-05 18:00 run: T196
- Summary: Pathfinder and rival ships now accelerate, brake to a stop and turn at a limited yaw rate via new game/ship_motion.gd; rivals fly to a destination, wait, pick the next. 7 placeholder balance keys (data_version 57), save VERSION 8 (v7 loads at rest).
- Why this task: gates T197-T201, no owner decision or QA needed.
- Approach: one shared motion step for both ship kinds rather than duplicated logic.
- Agent prompts: gameplay-programmer, brief = T196 text plus no-QA, no-commit. Produced ship_motion.gd, pathfinder.gd, pathfinder_view.gd, rival_ships.gd, save_game.gd, balance.json, run_tests.gd, handoffs/gameplay-programmer/2026-11-05-T196.json (verified).
- Worked: sh tools/tests/run.sh pass=2875 fail=0.
- Failed / did not work: nothing. Not seen windowed; debug menu listing of new keys unchecked. gdd.md not edited, so committed [no-gdd] (note: ships accelerate/turn is a small design line the owner may want in gdd).
- Files and commits: see git log "T196".
- Left to do: T197-T201; owner to tune the placeholder motion numbers.

## 2026-11-05 19:00 run: T197
- Summary: Ships now face their heading: per-model yaw offset MODEL_YAW_DEG in game/ships.gd (all four ship ids -90), applied via a pivot node in pathfinder_view.gd and rival_ships.gd.
- Why this task: clear bug fix, no owner decision; unblocks T201.
- Approach: code offset table keyed by ship id (readable by the T201 test), no model file edits.
- Agent prompts: ui-programmer, brief = T197 text plus no-QA, no-commit. Produced the three game files and handoffs/ui-programmer/2026-11-05-T197.json (verified).
- Worked: sh tools/tests/run.sh pass=2875 fail=0.
- Failed / did not work: nothing; not seen windowed. Nose end inferred from vertex widths; ship_corvette_01 least certain.
- Files and commits: game/ships.gd, game/pathfinder_view.gd, game/rival_ships.gd, schedule.json, blackboard.md, handoff; commit "T197 ... [no-gdd]".
- Left to do: owner checks windowed that no ship flies backwards (flip entry to 90). Models 05-08 are not in ships.json and have no offset. Next: T201, T200.
