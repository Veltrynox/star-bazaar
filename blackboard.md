# Main agent blackboard

## Do not repeat
- discovery_enabled in data/balance.json ships at 1 (owner decision 2026-11-05); tests that need it off set it themselves.

## Left to do
- T224 done (text only): TH01-TH10 need a gameplay task: event rows + follow chain in data/events.json, cash-pay choice effect (TH10_A), balance key for thread start cycle; owner to answer who sets those.
- T238 done: owner to approve design/proposals/2026-11-05-branch-goods.md and answer 3 questions (can a company win other markets/learn other trees; new world Brannock vs retype Ashgate; energy in every tier-3 recipe) before T239/T240/T242.
- T234 done: owner to answer: EV52-55 rarely fire (cycles 5 and 9 in window, pool ~36); Luxury/Minerals often not visible by cycle 10; chain gains removed as options (one kept per step). Cash values first-pass.
- T230 partial: choice events EV17-20, BE01-03 and pending post/platform/flight events not rewritten (owner to say); Russian not touched.
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

## 2026-11-06 14:00 run: T230
- Summary: Rewrote the bodies of generic events EV01-16, EV21-28 and EV40-51 with more voice and concrete detail (English only). Mechanics, ids, titles, effect lines unchanged; data/story_text.json rebuilt via tools/build_story.py.
- Why this task: no dependencies, text only, no visual/economy/QA need; other open tasks were blocked by dependencies, owner-only agents or visual choices.
- Approach: story-designer agent editing story/events.md, leaving choice events with fixed effect lines alone to avoid contradicting mechanics.
- Agent prompts: rewrite event bodies less dry, keep limits/placeholders, English only, do not edit story/voice.md, run build and tests; produced story/events.md, data/story_text.json, handoffs/story-designer/2026-11-06-T230.json.
- Worked: sh tools/tests/run.sh pass=11320 fail=0 (agent's run).
- Failed / did not work: nothing.
- Files and commits: story/events.md, data/story_text.json, handoff, schedule.json, blackboard.md; see git log "T230". story/voice.md and .claude/agents/story-designer.md hold owner edits, left uncommitted.
- Left to do: EV17-20, BE01-03, pending post/platform/flight events; Russian only when owner asks.

## 2026-11-06 16:00 run: T233
- Summary: Wrote four early branch events EV52-EV55 (contract and dark market) as text in story/events.md and built them with tools/build_story.py. No mechanics added.
- Why this task: no dependencies, text only, no visual, economy or QA need; other open tasks need owner decisions, owner-only agents or visual work.
- Approach: story-designer agent; events avoid goods names because branch goods are hidden before system 2 and T238 is not built.
- Agent prompts: write EV52-55 per T233 brief, English only, no commit, no mechanics; produced story/events.md, data/story_text.json, handoffs/story-designer/2026-11-05-T233.json, done.
- Worked: sh tools/tests/run.sh pass=11320 fail=0.
- Failed / did not work: nothing.
- Files and commits: story/events.md, data/story_text.json, handoff, schedule.json, blackboard.md; see git log "T233".
- Left to do: T234 mechanics (rows in data/events.json via tags, {cash_in} A>B, {market}); EVnn_EFF rivals lines say no rival change. story/voice.md and .claude/agents edits are the owner's, left alone.

## 2026-11-06 16:00 run: T234
- Summary: Built the four branch events EV52-55 as data-driven one-time pool events (dark option A, public option B), cycle window via new atom cycle_at_most, and the hidden 20% spotted flag that removes half the profitable events for the run. Flag and removed set are saved; old saves load without them.
- Why this task: dependency T233 done, code only, no visual, economy or QA need; the other open tasks are owner-only, blocked or need decisions.
- Approach: gameplay-programmer agent; one pattern in chains.json pool_new and Events._branch_choices rather than four copies; chain gains removed as options so requires_prev_step chains stay intact.
- Agent prompts: build T234 per brief, no commit, tests, handoff; produced game/events.gd, chains.gd, conditions.gd, main.gd, data/balance.json, data/chains.json, tests, gdd.md line, handoffs/gameplay-programmer/2026-11-06-T234.json.
- Worked: sh tools/tests/run.sh pass=11330 fail=0 (my re-run).
- Failed / did not work: nothing; not played windowed.
- Files and commits: see git log "T234".
- Left to do: owner: events fire rarely (cycles 5 and 9 in window), Luxury and Minerals may be invisible by cycle 10, choose widen window / weight / event_interval; confirm chain-option reading; retune cash values.

## 2026-11-06 18:00 run: T238
- Summary: feature-designer wrote the branch-exclusive goods proposal (per-branch chains, starters sellable at Voltara from cycle 0, fate of current goods, energy as only shared good, icon briefs).
- Why this task: no dependencies, design only, no visual/economy/QA need; T242 and T239 wait on it.
- Approach: single feature-designer agent per the T238 brief; no numbers, proposal only.
- Agent prompts: do the T238 brief, no commit, no QA/sim; produced design/proposals/2026-11-05-branch-goods.md and handoffs/feature-designer/2026-11-05-T238.json.
- Worked: both files exist; scope covered.
- Failed / did not work: nothing. Tests not run (no code/data change).
- Files and commits: design/proposals/2026-11-05-branch-goods.md, handoff, schedule.json, blackboard.md; see git log "T238".
- Left to do: owner approval and the three open questions; then T239, T240, T242.

## 2026-11-06 18:00 run: T224
- Summary: Story-designer wrote ten connected events TH01-TH10 (Maren Oake's hunt for an unrepaid loan) in story/events.md, English only; build regenerated data/story_text.json.
- Why this task: no dependencies, text only, no visual/economy/QA need; others are blocked or owner-only.
- Approach: story-designer agent; text only, since code needs (cash-pay effect, event rows) belong to the gameplay-programmer.
- Agent prompts: write 10 connected generic stories in events format, English only, no commit, list code needs; produced story/events.md, data/story_text.json, handoffs/story-designer/2026-11-06-T224.json.
- Worked: sh tools/tests/run.sh pass=11330 fail=0.
- Failed / did not work: build writes no event rows for text-only blocks, so stories are not playable yet.
- Files and commits: story/events.md, data/story_text.json, handoff, schedule.json, blackboard.md; see git log "T224". story/voice.md and .claude/agents edits are the owner's, left alone.
- Left to do: gameplay task for TH01-TH10 rows, cash-pay effect, start-cycle key; Russian only when owner asks.
