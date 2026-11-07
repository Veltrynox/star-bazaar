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

## 2026-11-07 10:52 run: T281
- Summary: Not merged: worker did not report done: None
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T281 on branch task/T281, merged by the serial merge queue.
- Agent prompts: /overnight-worker T281 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T281.log.
- Worked: worker finished.
- Failed / did not work: worker did not report done: None.
- Files and commits: see git log on branch new-features for commits starting with T281.
- Left to do: owner or a new run: see blocked_log in schedule.json.

## 2026-11-07 10:53 run: T283
- Summary: House ships now lead convoys that fly to their house's weather world (forecast lead plus warning-skill cycles), park there until it ends, then idle as before; the escorts are a traffic free group and the five new convoy_* keys are placeholders
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T283 on branch task/T283, merged by the serial merge queue.
- Agent prompts: /overnight-worker T283 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T283.log.
- Worked: rebase, full test suite and fast-forward merge passed.
- Failed / did not work: nothing.
- Files and commits: see git log on branch new-features for commits starting with T283.
- Left to do: nothing for this task.

## 2026-11-07 10:57 run: T282
- Summary: The eight rival-cutting skill nodes now act on house weather. Chain options that hit a rival delay or soften that house's next weather. Save version is 18.
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T282 on branch task/T282, merged by the serial merge queue.
- Agent prompts: /overnight-worker T282 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T282.log.
- Worked: rebase, full test suite and fast-forward merge passed.
- Failed / did not work: nothing.
- Files and commits: see git log on branch new-features for commits starting with T282.
- Left to do: nothing for this task.

## 2026-11-07 10:58 run: T245
- Summary: A left click on a ship drawn over a planet now selects only the ship, because `game/map.gd` no longer also emits the planet click; `map.gd` is outside the task's `touches`, so this is the one out-of-scope edit
- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.
- Approach: built by a worker in worktree ../wt/T245 on branch task/T245, merged by the serial merge queue.
- Agent prompts: /overnight-worker T245 (skill overnight-worker); worker log /Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar/logs/orchestrator/T245.log.
- Worked: rebase, full test suite and fast-forward merge passed.
- Failed / did not work: nothing.
- Files and commits: see git log on branch new-features for commits starting with T245.
- Left to do: nothing for this task.
