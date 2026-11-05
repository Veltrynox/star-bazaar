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

## 2026-11-05 23:00 run: T198
- Summary: Added game/ship_trail.gd (fading world-space line, gold for player, blue for rivals, paused/hidden handled); ship scale 0.5 via PLAYER_SHIP_SCALE and RIVAL_SHIP_SCALE; SHIP_PICK_PX 30 to 20.
- Why this task: owner-specified (trail, about half size), no QA; T199 leaves marker-vs-tint open (visual).
- Approach: one small trail script used by both ship kinds.
- Agent prompts: juice-programmer, brief = T198 text plus no-QA, no-commit. Produced ship_trail.gd, pathfinder_view.gd, rival_ships.gd, map.gd, handoffs/juice-programmer/2026-11-05-T198.json (verified; tests pass=4017 fail=0 re-run by me).
- Worked: build and tests.
- Failed / did not work: nothing; not seen windowed, no test for the trail.
- Files and commits: see git log "T198".
- Left to do: owner: trail width/tint, size, pick radius. T199 (decide marker vs tint per competitor).

## 2026-11-06 00:00 run: gap analysis (no task done)
- Summary: Reviewed all open tasks. None can be done unattended; no new tasks added (gap analysis of 2026-11-05 already produced T189-T193).
- Why this task: T199 needs a visual decision (marker vs tint, card look) the owner has not made; T189-T192 and T193 are marked "needs owner decision"; T178/T182 are owner-only agents; T185 is visual; T166 is superseded; T05 needs a windowed measurement.
- Approach: skipped rather than guessing visual or design choices.
- Agent prompts: none.
- Worked: nothing built; no code or data touched.
- Failed / did not work: nothing.
- Files and commits: blackboard.md only, no commit (other uncommitted files are not mine).
- Left to do: owner decides T199 look (marker or tint per competitor), then it can run; T189-T193 decisions.

## 2026-11-06 01:00 run: gap analysis (no task done)
- Summary: Re-checked open tasks (T05, T166, T178, T182, T189-T193, T199). State unchanged since the 00:00 run; nothing doable unattended and no new gaps found.
- Why this task: T199 needs a visual decision (marker vs tint, card look); T189-T193 need owner decisions; T178/T182 are owner-only agents; T166 superseded; T05 needs a windowed measurement.
- Approach: skipped rather than guess visual or design choices.
- Agent prompts: none.
- Worked: nothing built; no code or data touched.
- Failed / did not work: nothing.
- Files and commits: blackboard.md only, no commit.
- Left to do: owner decides T199 look, then T189-T193 decisions.

## 2026-11-06 02:00 run: gap analysis (no task done)
- Summary: Re-checked open tasks; state unchanged since the 01:00 run (no new commits, no owner decisions recorded). Nothing doable unattended, no new tasks added.
- Why this task: T199 look (marker vs tint) is a visual decision for the owner; T189-T193 need owner decisions; T178/T182 are owner-only agents; T166 superseded; T05 needs a windowed measurement.
- Approach: skipped rather than guess.
- Agent prompts: none.
- Worked: nothing built; no code touched.
- Failed / did not work: nothing.
- Files and commits: blackboard.md only, no commit.
- Left to do: owner decides T199 look, then T189-T193.

## 2026-11-06 03:00 run: T204
- Summary: Left click on empty space with the ship selected now only drops the selection; clicks on planets, storage and asteroid fields still fly at once; right click and Esc unchanged.
- Why this task: smallest clear, owner-specified, no visual or design decision, no dependencies.
- Approach: edited the open-space branch in game/map.gd myself (one small edit, an agent would cost more).
- Agent prompts: none.
- Worked: edit; sh tools/tests/run.sh pass=4017 fail=0.
- Failed / did not work: no new test for the click (map input is not headless-testable); the "point" kind stays in the flight API, unused by clicks. No story text needed changing.
- Files and commits: game/map.gd, schedule.json, blackboard.md; see git log "T204".
- Left to do: other queued tasks T203, T205-T208, T210-T218 remain open (T209 owner-only, T218 waits on T216/T217).

## 2026-11-06 04:00 run: T212
- Summary: Storage link upkeep was already energy only; set link_upkeep_energy from 20 to 5 per cycle (temporary), data_version 59, and reworded the gdd.md line.
- Why this task: tiny, owner-specified, no dependencies, no visual or design decision.
- Approach: data-only edit by me; an agent would cost more.
- Agent prompts: none.
- Worked: sh tools/tests/run.sh pass=4017 fail=0. Link row and forecasts read upkeep() so they follow the value.
- Failed / did not work: nothing.
- Files and commits: data/balance.json, gdd.md, schedule.json, blackboard.md; see git log "T212".
- Left to do: owner or economy designer retunes the 5 later.

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

## 2026-11-06 09:00 run: T206
- Summary: Added exploration mode: an Explore button in the Ships panel makes the Pathfinder fly to each unestablished planet of its system, establish the post or platform, wait for cash, and post one notice when done. Any manual order or the button ends it; state is saved.
- Why this task: clear owner brief, no dependencies, no visual decision; other open tasks are visual, owner-only or need decisions.
- Approach: gameplay-programmer agent in game/pathfinder.gd; I verified diff and tests.
- Agent prompts: build the mode on existing flight/discovery/post rules, save state, notice once, test, gdd line; handoffs/gameplay-programmer/2026-11-06-T206.json, done.
- Worked: sh tools/tests/run.sh fail=0; test _test_t206_explore added.
- Failed / did not work: my first schedule.json write used indent 1 and reformatted the file; redone with indent 2.
- Files and commits: game/pathfinder.gd, main.gd, ship_panel.gd, story/screens.md, data/story_text.json, tools/tests/run_tests.gd, gdd.md, handoff, schedule.json, blackboard.md; see git log "T206".
- Left to do: owner: button placement/look in Ships panel not seen windowed; a dead world without the mining skill is skipped and the mode idles until learned; no Russian ids for the 2 new texts.
