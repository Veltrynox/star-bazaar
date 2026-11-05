# Main agent blackboard

## Do not repeat
- discovery_enabled in data/balance.json ships at 1 (owner decision 2026-11-05); tests that need it off set it themselves.

## Left to do
- Open build tasks from playtest: T199 (T196-T198, T200-T202 done). Owner: check T198 look windowed (trail line 1px, scale 0.5, pick 20px). T194 done; Competitors still reachable from share panel (L), owner to say if that goes too.
- Open: T185 (visual), T178/T182 (owner-only agents), T05 (only windowed frame time missing, see T193), T166 (superseded). Owner-decision tasks T189-T193 added 2026-11-05.

- Owner: ship cap 20 (T186): decide on economy retune (trip cost, maintenance tuned for 6) and look of the scrolled ship list; other panels not checked at 20 ships.
- Owner: asteroid-asteroid has no link and storage is never a route source (T188 treated as design); tools/project_workflow.html and other files were modified by something else, left uncommitted.

- Owner: T187 rival ships: look (tint, size, trail, galaxy view) and balance keys rival_ship_count / rival_ship_speed (code defaults 3 and 0.6); gdd.md rivals line edited but left uncommitted with other people's gdd.md changes (gdd-log.md is deleted in tree, so no log entry).

- Owner: T176 placeholder systems are ids 3-5 (not 6 total), off by default (data/systems_placeholder.json enabled:false); permit keys reuse permit_2_*; no Russian text; galaxy overview with them on not exercised windowed.

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
