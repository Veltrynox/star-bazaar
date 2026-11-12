# Main agent blackboard

## Do not repeat
- discovery_enabled in data/balance.json ships at 1 (owner decision 2026-11-05); tests that need it off set it themselves.

## Left to do
- T242 done (text): story/skills.md committed; data/story_text.json and story/screens.md rebuilt but uncommitted (owner edits mixed). Owner: mechanic mismatches MIL_1, LUX_3, BIO_3, BIO_6 (ideas in handoffs/story-designer/2026-11-05-T242.json). 14 test FAILs come from owner's uncommitted goods work.
- T217 done: gig texts GIG01/02 in story/gigs.md; data/story_text.json regenerated but uncommitted (owner goods edits mixed in); 15 test FAILs come from owner's uncommitted goods work.
- T216 done: owner to approve design/proposals/2026-11-05-gigs.md and answer 3 questions (expired gig gone for run?, goods reward to storage or next load?, reward goods count for share?) before T217/T218.
- T224 done (text only): TH01-TH10 need a gameplay task: event rows + follow chain in data/events.json, cash-pay choice effect (TH10_A), balance key for thread start cycle; owner to answer who sets those.
- T238 done: owner to approve design/proposals/2026-11-05-branch-goods.md and answer 3 questions (can a company win other markets/learn other trees; new world Brannock vs retype Ashgate; energy in every tier-3 recipe) before T239/T240/T242.
- T234 done: owner to answer: EV52-55 rarely fire (cycles 5 and 9 in window, pool ~36); Luxury/Minerals often not visible by cycle 10; chain gains removed as options (one kept per step). Cash values first-pass.
- T230 done (English): all events rewritten, but story/events.md and data/story_text.json edits are UNCOMMITTED (mixed with owner goods edits); Russian out of date.
- T243 queued: make TH01-TH10 playable (gameplay); needs owner OK.
- T236 done: tags shown on CEO card. SETUP_NEXT still reads 'Next'. story/voice.md has uncommitted owner edits, left alone.
- Owner: T219 lane draw-in/fade/pulse not seen windowed (constants atop route_line.gd); route made while paused shows no draw-in.
- Owner: T203 establish beat not seen windowed (ring/spokes vs bright planets, nudge softness, dead worlds); follow-up juice tasks T219-T221 queued.
- Owner: T205 trail look windowed: ship_trail.gd WIDTH 0.16, ships.gd ENGINE_BACK 0.9 for all models (exact exhaust positions not measured from the GLBs).
- Open build tasks from playtest: none of T196-T202 left (T199 done 2026-11-06). Owner: check T198 look windowed (trail line 1px, scale 0.5, pick 20px). T194 done; Competitors still reachable from share panel (L), owner to say if that goes too.
- Open: T185 (visual), T178 (owner-only agent; T182 done 2026-11-08, partial), T05 (only windowed frame time missing, see T193), T166 (superseded). Owner-decision tasks T189-T193 added 2026-11-05.

- Owner: ship cap 20 (T186): decide on economy retune (trip cost, maintenance tuned for 6) and look of the scrolled ship list; other panels not checked at 20 ships.
- Owner: asteroid-asteroid has no link and storage is never a route source (T188 treated as design); tools/project_workflow.html and other files were modified by something else, left uncommitted.

- Owner: T187 rival ships: look (tint, size, trail, galaxy view) and balance keys rival_ship_count / rival_ship_speed (code defaults 3 and 0.6); gdd.md rivals line edited but left uncommitted with other people's gdd.md changes (gdd-log.md is deleted in tree, so no log entry).

- Owner: T176 placeholder systems are ids 3-5 (not 6 total), off by default (data/systems_placeholder.json enabled:false); permit keys reuse permit_2_*; no Russian text; galaxy overview with them on not exercised windowed.

## 2026-11-09 12:44 run: T347
- Summary: Not merged: worker did not report done: blocked T347 | task T347 does not exist in this worktree's schedule (`python3 tools/task.py T347` returns "not found", and neither schedule.json nor git history mentions it), so there is nothing to build
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T347 on branch task/T347, merged by the serial merge queue.
- Agent prompts: /overnight-worker T347 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T347.log.
- Worked: worker finished.
- Failed / did not work: worker did not report done: blocked T347 | task T347 does not exist in this worktree's schedule (`python3 tools/task.py T347` returns "not found", and neither schedule.json nor git history mentions it), so there is nothing to build.
- Files and commits: see git log on branch new-features for commits starting with T347.
- Left to do: owner or a new run: see blocked_log in schedule.json.

## 2026-11-09 12:51 run: T348
- Summary: Gig rail button now shows a star_warm dot badge while a gig is open (updated via gigs.changed and _refresh) and uses a new crate icon (art/icons/icon_gig_64.svg, outside touches); headless test added, screenshot at logs/screenshots/T348.png
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T348 on branch task/T348, merged by the serial merge queue.
- Agent prompts: /overnight-worker T348 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T348.log.
- Worked: rebase, full test suite and fast-forward merge passed.
- Failed / did not work: nothing.
- Files and commits: see git log on branch new-features for commits starting with T348.
- Left to do: nothing for this task.

## 2026-11-09 12:58 run: T347
- Summary: The one-time tip card now copies the theme panel style with background alpha 1.0, so border, radius and margins are unchanged; the guided tutorial card is untouched
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T347 on branch task/T347, merged by the serial merge queue.
- Agent prompts: /overnight-worker T347 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T347.log.
- Worked: rebase, full test suite and fast-forward merge passed.
- Failed / did not work: nothing.
- Files and commits: see git log on branch new-features for commits starting with T347.
- Left to do: nothing for this task.

## 2026-11-09 17:02 run: T349
- Summary: Voltara's need is now food (its only candidate was locked ore, so it was Restless forever), and a world with no needs is never Restless; headless tests added
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T349 on branch task/T349, merged by the serial merge queue.
- Agent prompts: /overnight-worker T349 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T349.log.
- Worked: rebase, full test suite and fast-forward merge passed.
- Failed / did not work: nothing.
- Files and commits: see git log on branch new-features for commits starting with T349.
- Left to do: nothing for this task.

## 2026-11-12 12:10 run: T355 T356 T357
- Summary: Ship look in the game: measured engine points per ship type (1-4, data/ships.json), a six-layer additive plume per engine with 5 shape and 10 colour presets (data/exhaust.json) on the Flagship, rivals and the company-screen preview, a hull hue shader, and the New company screen lets the player pick shape, palette and hue (per-CEO defaults in data/ceos.json, saved as ship_look, save version 23).
- Why this task: owner request 2026-11-12 after tuning positions in tools/engine_tuner.html (also published as a private artifact).
- Agent prompts: Agent tool, subagent_type gameplay-programmer (T355), juice-programmer (T356), ui-programmer (T357), each told to read its brief from schedule.json; handoffs in handoffs/<agent>/2026-11-12-T35x.json.
- Approach: T355 gameplay-programmer and T356 juice-programmer in parallel against a shared Ships.engine_points contract, then T357 ui-programmer; main session reviewed the diffs, fixed the plume shader (Godot CylinderMesh side UV.y is 0..0.5, the fade now doubles it) and the normal-map hint, wrote the gdd.md paragraph.
- Worked: three commits 0fad822, 644d93e, 9cf099c plus the tuner page 5210324; the commit hook (test gate) let each through.
- Failed / did not work: nothing seen headless; nothing looked at in a window (owner's job).
- Files and commits: see git log on main for T355, T356, T357.
- Left to do: owner to check by eye: nozzle placement and +X tail direction on all four ships, plume brightness vs the tuner page, hue on corvette 01 (two-sided material) and 04, flicker frozen while paused, and that the Ship look block fits the company screen at the default window size. Idea not built: brighten the plume glow on boost.
