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

## 2026-11-06 23:00 run: T230
- Summary: story-designer rewrote choice events EV17-20, BE01-03 and their popups, plus five pending post/flight events, in the draft-3 voice (English). Build ran clean.
- Why this task: the only open task doable without owner decision, visuals, QA or approval; partial tasks preferred.
- Approach: single story-designer agent, text only, ids/mechanics unchanged; kept owner goods renames in events.md.
- Agent prompts: rewrite remaining dry events per voice.md, English only, build, no commit; produced story/events.md, data/story_text.json, handoffs/story-designer/2026-11-06-T230b.json.
- Worked: handoff exists, events.md diff shows the rewrites.
- Failed / did not work: sh tools/tests/run.sh pass=11491 fail=15, same 15 as before (owner's uncommitted goods work), no story failure. Text files left uncommitted because they mix owner edits.
- Files and commits: handoff, schedule.json, blackboard.md committed; story/events.md, data/story_text.json uncommitted.
- Left to do: owner commits text with goods work; EV_PLT and remaining pending events; Russian only when asked.

## 2026-11-06 22:00 run: T242
- Summary: story-designer rewrote names and flavour of all 31 skill nodes in story/skills.md with a register per branch; plain lines kept except SK_LUX_4_PLAIN wording.
- Why this task: depends only on T238 (done), text only, no visual/economy/QA need; T239 would collide with the owner's uncommitted goods work.
- Approach: single story-designer agent; mechanics untouched, mismatches listed for the owner.
- Agent prompts: do the T242 brief, English only, edit source then build_story.py, do not touch owner edits, no commit; produced story/skills.md, story/screens.md (placeholder notes removed), data/story_text.json, handoffs/story-designer/2026-11-05-T242.json.
- Worked: build ok (1646 entries); skill text availability check passes.
- Failed / did not work: full test run has 14 FAILs in goods/workshop/availability tests from the owner's uncommitted goods work, not from texts. Agent's text naming hidden goods was rejected by the availability scan, so cargo wording used.
- Files and commits: story/skills.md, handoff, schedule.json, blackboard.md; see git log "T242" (committed with [no-gdd] [no-tests]).
- Left to do: owner to decide node mechanic ideas (MIL_1, LUX_3, BIO_3, BIO_6); commit data/story_text.json and screens.md with the goods work; Russian only on request.

## 2026-11-06 23:30 run: T230
- Summary: Checked the remaining pending events (PST04-05, PLT01-04, FLT02-04) against the draft-3 voice; they already match, so T230 is closed as done (English). Added T243 for the playable TH thread.
- Why this task: it was the only partial task; every other open task needs owner approval, a visual decision, or owner-only agents (QA, economy).
- Approach: no agent needed; a read-through was cheaper than a rewrite, and rewriting good text would risk churn.
- Agent prompts: none sent.
- Worked: schedule.json updated, T243 created.
- Failed / did not work: nothing run; tests not run (no code or data change by me). T218 gigs skipped: design awaits owner approval and 3 open questions.
- Files and commits: schedule.json, blackboard.md; see git log "T230".
- Left to do: owner commits story/events.md and data/story_text.json with the goods work; Russian only on request; T243 needs owner OK.

## 2026-11-06 23:50 run: gap analysis
- Summary: Reviewed all 16 open tasks; none can be done without an owner decision, a visual decision, owner-only agents, or a clean test base. No new tasks added.
- Why this task: T05/T193 windowed measure, T178/T182/T209 owner-only QA/economy, T189/T190 owner decisions, T208/T218/T239/T240/T243 await approval, T220/T221/T223 are look/layout, T166 superseded.
- Approach: did not start T243 even though its dependency is done: the brief itself says it needs owner OK, and the tree has 15 test FAILs from the owner's uncommitted goods work, so a data/events change could not be verified.
- Agent prompts: none sent.
- Worked: schedule read; no change to schedule.json.
- Failed / did not work: nothing run.
- Files and commits: blackboard.md only.
- Left to do: owner approves T243/T218/T239/T208 or answers the open questions; owner commits goods work so the test base is green.

## 2026-11-07 00:10 run: gap analysis
- Summary: Re-read the 16 open tasks; the picture is unchanged since the 23:50 analysis. No task can be done without an owner decision, visual decision, owner-only agent, or clean test base. No new tasks added.
- Why this task: no open task is eligible (T208/T218/T239/T240/T243 need approval, T189/T190/T193 need decisions, T178/T182/T209 owner-only, T220/T221/T223 visual, T166 superseded).
- Approach: did not repeat the gap analysis in depth; nothing in gdd or code changed since the last one, and inventing features is not allowed.
- Agent prompts: none sent.
- Worked: schedule and blackboard read.
- Failed / did not work: nothing run.
- Files and commits: blackboard.md only.
- Left to do: owner approves T243/T218/T239/T208 or answers the open questions; owner commits goods work so tests are green.
