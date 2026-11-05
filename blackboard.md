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

## 2026-11-06 10:00 run: T210
- Summary: Added placeholder solar systems 6-10 (off by default, same shape as 3-5), grew the galaxy overview SLOTS from 7 to 10, added never-true availability rules and English text ids.
- Why this task: clear owner brief, no dependencies, data only; other open tasks are visual, owner-only or need decisions.
- Approach: gameplay-programmer agent following the T176 pattern; I verified diff and tests.
- Agent prompts: add systems 6-10 like T176, enough SLOTS, unique ids and keys, test, gdd line; handoffs/gameplay-programmer/2026-11-06-T210.json, done.
- Worked: sh tools/tests/run.sh no FAIL lines; placeholder test now checks 10 systems.
- Failed / did not work: nothing. Not seen windowed.
- Files and commits: data/systems_placeholder.json, data/availability.json, story/screens.md, data/story_text.json, game/galaxy_view.gd, tools/tests/run_tests.gd, gdd.md, handoff, schedule.json, blackboard.md; see git log "T210".
- Left to do: owner: galaxy slots 8-10 positions are temporary and unseen windowed with placeholders on; no Russian text for the new ids.
