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
- Open: T185 (visual), T178/T182 (owner-only agents), T05 (only windowed frame time missing, see T193), T166 (superseded). Owner-decision tasks T189-T193 added 2026-11-05.

- Owner: ship cap 20 (T186): decide on economy retune (trip cost, maintenance tuned for 6) and look of the scrolled ship list; other panels not checked at 20 ships.
- Owner: asteroid-asteroid has no link and storage is never a route source (T188 treated as design); tools/project_workflow.html and other files were modified by something else, left uncommitted.

- Owner: T187 rival ships: look (tint, size, trail, galaxy view) and balance keys rival_ship_count / rival_ship_speed (code defaults 3 and 0.6); gdd.md rivals line edited but left uncommitted with other people's gdd.md changes (gdd-log.md is deleted in tree, so no log entry).

- Owner: T176 placeholder systems are ids 3-5 (not 6 total), off by default (data/systems_placeholder.json enabled:false); permit keys reuse permit_2_*; no Russian text; galaxy overview with them on not exercised windowed.

## 2026-11-07 00:10 run: gap analysis
- Summary: Re-read the 16 open tasks; the picture is unchanged since the 23:50 analysis. No task can be done without an owner decision, visual decision, owner-only agent, or clean test base. No new tasks added.
- Why this task: no open task is eligible (T208/T218/T239/T240/T243 need approval, T189/T190/T193 need decisions, T178/T182/T209 owner-only, T220/T221/T223 visual, T166 superseded).
- Approach: did not repeat the gap analysis in depth; nothing in gdd or code changed since the last one, and inventing features is not allowed.
- Agent prompts: none sent.
- Worked: schedule and blackboard read.
- Failed / did not work: nothing run.
- Files and commits: blackboard.md only.
- Left to do: owner approves T243/T218/T239/T208 or answers the open questions; owner commits goods work so tests are green.

## 2026-11-06 17:14 run: T244
- Summary: Not merged: fast-forward merge refused
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T244 on branch task/T244, merged by the serial merge queue.
- Agent prompts: /overnight-worker T244 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T244.log.
- Worked: worker finished.
- Failed / did not work: fast-forward merge refused.
- Files and commits: see git log on branch new-features for commits starting with T244.
- Left to do: owner or a new run: see blocked_log in schedule.json.

## 2026-11-06 17:15 run: T267
- Summary: Wrote English text for prosperity tiers, planet-card needs, the Bazaar, Next Up, the soft ending (END_UNFINISHED) and 11 re-voiced skill nodes. The test suite has 13 failures that also fail on a clean base: goods, workshop, cells and availability for powder, blooms and food.
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T267 on branch task/T267, merged by the serial merge queue.
- Agent prompts: /overnight-worker T267 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T267.log.
- Worked: rebase, full test suite and fast-forward merge passed.
- Failed / did not work: nothing.
- Files and commits: see git log on branch new-features for commits starting with T267.
- Left to do: nothing for this task.

## 2026-11-06 17:16 run: T277
- Summary: Traffic layer in game/traffic/ with instanced path/orbit/free ship groups moving in shaders, code-built low-poly corvette and pirate proxies, far-zoom fade, 13 placeholder balance keys and a debug-menu instance/draw-call readout
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T277 on branch task/T277, merged by the serial merge queue.
- Agent prompts: /overnight-worker T277 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T277.log.
- Worked: rebase, full test suite and fast-forward merge passed.
- Failed / did not work: nothing.
- Files and commits: see git log on branch new-features for commits starting with T277.
- Left to do: nothing for this task.
