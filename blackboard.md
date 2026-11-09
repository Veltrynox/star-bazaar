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

## 2026-11-07 22:47 run: T315
- Summary: Tutorial guided steps rewritten (two new steps, Star Bazaar goal as the last step), 31 one-time tips with plain-word triggers added, stale goal lines fixed in story/*.md and story_text.json regenerated
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T315 on branch task/T315, merged by the serial merge queue.
- Agent prompts: /overnight-worker T315 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T315.log.
- Worked: rebase, full test suite and fast-forward merge passed.
- Failed / did not work: nothing.
- Files and commits: see git log on branch new-features for commits starting with T315.
- Left to do: nothing for this task.

## 2026-11-07 22:59 run: T316
- Summary: 12-step guided tutorial with the new Needs and Grow steps, v3 save mapping, and a one-time tip system (31 tips on a queued tip card, saved, silenced by Skip)
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T316 on branch task/T316, merged by the serial merge queue.
- Agent prompts: /overnight-worker T316 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T316.log.
- Worked: rebase, full test suite and fast-forward merge passed.
- Failed / did not work: nothing.
- Files and commits: see git log on branch new-features for commits starting with T316.
- Left to do: nothing for this task.

## 2026-11-08 run: T208
- Summary: skill tree build from the T207 proposal, reconciled against the current 68-node tree. 6 new effect types (lane upgrade cost, new ship price, Embargo Desk cooldown, workshop ore input, Null Core trip cost, Luxury bundle bonus) with placeholder numbers in data/balance.json. FND_LEDGER, FND_RIVAL_WATCH, MIN_8, MIN_10 and BIO_12 were dropped or merged and keep reworded stand-in effects. English only.
- Why this task: owner said "run T208" on 2026-11-08 (approval waived 2026-11-05).
- Approach: gameplay-programmer started by the main session; story/skills.md edited, tools/build_story.py run, gdd-skills.md updated.
- Agent prompts: gameplay-programmer, brief from tools/task.py T208 plus reconcile-with-current-tree instruction.
- Worked: build finished, handoffs/gameplay-programmer/2026-11-08-T208.json written.
- Failed / did not work: sh tools/tests/run.sh shows 13 FAIL (powder, blooms, workshop, goods, availability); agent reports the same 13 fail on a clean tree, not re-checked by the main session. No window check.
- Files and commits: uncommitted: game/skills.gd, ships.gd, goods.gd, route_engine.gd, main.gd, planet_panel.gd, data/skills.json, balance.json, story_text.json, story/skills.md, gdd-skills.md, the handoff.
- Left to do: owner decides whether to keep the 4 stand-in nodes and whether to build a dead-world ore-loss mechanic (MIN_10). T209 review stays owner by hand.

## 2026-11-09 10:29 run: T327
- Summary: Not merged: worker did not report done: blocked T327 | This worktree's base commit (01a78b1) lacks the code the task builds on: no T322 zoomed start and no T323 `planet_ring` PulseRing. TUT_G0_FLY here still reads "Click your ship, then right-click the dim world." `schedule.json` in the worktree has no T327 entry either, so I read the task from the main checkout. Rebase the branch onto a base that includes T322 and T323, then rerun. Nothing was built or changed.
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T327 on branch task/T327, merged by the serial merge queue.
- Agent prompts: /overnight-worker T327 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T327.log.
- Worked: worker finished.
- Failed / did not work: worker did not report done: blocked T327 | This worktree's base commit (01a78b1) lacks the code the task builds on: no T322 zoomed start and no T323 `planet_ring` PulseRing. TUT_G0_FLY here still reads "Click your ship, then right-click the dim world." `schedule.json` in the worktree has no T327 entry either, so I read the task from the main checkout. Rebase the branch onto a base that includes T322 and T323, then rerun. Nothing was built or changed..
- Files and commits: see git log on branch new-features for commits starting with T327.
- Left to do: owner or a new run: see blocked_log in schedule.json.
