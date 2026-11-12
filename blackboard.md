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

## 2026-11-12 13:05 run: T358
- Summary: Old two-ribbon ship trail removed (Flagship, rivals, Ships.engine_back, ship_trail.gd deleted); the company-screen ship preview has a round pause/play button in its corner and is 325x250 (1.3x wider); the cut-off plume was a framing bug, so the camera is now 4.6 away and the ship is scaled so hull plus the longest plume of any shape stays in frame (ship about 45% smaller, knob FRAME_FILL in ship_preview.gd).
- Why this task: owner request 2026-11-12.
- Approach: one ui-programmer task; cause measured headless on all four ships every 10 degrees of turntable angle (needle plume tips reached 4.4 to 4.7 units, outside the frame and sometimes behind the camera); depth test and additive blend were not the cause.
- Agent prompts: Agent tool, ui-programmer, brief read from schedule.json T358; handoff handoffs/ui-programmer/2026-11-12-T358.json.
- Worked: build and grep for leftovers; headless parse of the screen.
- Failed / did not work: screenshot logs/screenshots/T358.png shows no preview because the tool cannot pick a CEO; the button, plume at every angle and Ship look block width (info column about 435 px) not seen by eye.
- Files and commits: see git log on main for T358.
- Left to do: owner to look at the preview size (FRAME_FILL 0.92, CAM_DIST 4.6) and the pause button; the boost stretch of the old trail is not rebuilt for the plume (idea: raise plume glow on boost).

## 2026-11-12 13:50 run: T359
- Summary: The cut-off plume in the company-screen preview was the transparent viewport (additive light over alpha 0 vanishes outside the hull outline); the viewport is now opaque in the panel colour. The ship is framed by the current look's plume reach (hull floor 70% of the pre-T358 size) and a crosshair button focuses the camera on the engines from behind; ship_scale 0.8 -> 1.04 (1.3x) was set by the owner request in a separate commit.
- Why this task: owner feedback 2026-11-12 ('still clipped like with alpha, preview is small, camera needs a toggle to focus on the engines').
- Approach: cause found by the main session with a scratch render of game/company_setup.gd; one ui-programmer task.
- Agent prompts: Agent tool, ui-programmer, brief read from schedule.json T359; handoff handoffs/ui-programmer/2026-11-12-T359.json.
- Worked: scratch renders of whole ship and engine view for all CEOs looked at (PNGs in ../wt/_scratch/t359_*.png); background opaque, plume continues past the hull, engines in frame.
- Failed / did not work: man_01 torch plume at 180 degrees may touch the left edge at the hull floor size; engine view looks small in the portrait panel; not seen in a real window.
- Files and commits: see git log on main for T359.
- Left to do: owner to look at the engine view distance and the whole-ship size in the real window.

## 2026-11-12 14:40 run: T360
- Summary: The hub is now explained in the game: an always-visible muted paragraph under the hub panel title (ST_HUB_EXPLAIN) and a fuller hover tooltip on Make hub (ST_HUB_MAKE_TIP extended, also on the disabled reason line). English only. Separate commit: the Flagship line and droplet on a cross-system flight now point at the exit point during the out leg (Pathfinder.leg_goal).
- Why this task: owner request 2026-11-12 (hub panel screenshot) and 'the UI target points to a wrong place' on inter-system flights.
- Approach: one ui-programmer task for the text; the target fix by the main session (target().pos belongs to the destination system, the view drew to it from the old system).
- Agent prompts: Agent tool, ui-programmer, brief read from schedule.json T360; handoff handoffs/ui-programmer/2026-11-12-T360.json (written by the main session).
- Worked: scratch render of the hub panel at 1920x1080 looked at; text wraps to four lines, nothing clipped.
- Failed / did not work: tooltips and the cross-system line not seen in a window.
- Files and commits: see git log on main for T360 and the leg_goal commit.
- Left to do: Russian for ST_HUB_EXPLAIN and ST_HUB_MAKE_TIP (Haiku agents) when the owner asks; owner to fly the Flagship to another system and check the line and droplet at the exit point, then at the real target after the jump.

## 2026-11-12 15:20 run: bazaar-guidance proposal
- Summary: design/proposals/2026-11-12-bazaar-guidance.md: why the Star Bazaar stage reads as a dead end (the bill is shown as a number in three places, never as an instruction; powder must be HELD in the capital's planet storage, sold at Flintmoor 12 cr / Voltara 30 cr) and a proposal: one Bazaar.next_step() record rendered in five voices (Bazaar panel how-line and Buy/Send buttons, capital card block, Bazaar card and Next Up clicks, a gentle cycle-end reminder only while nothing feeds the bill, stage-done next line) plus an optional persistent Main line card.
- Why this task: owner question 2026-11-12 ('not clear how to proceed at the Town stage').
- Approach: main session read bazaar.gd, next_up.gd, bazaar_panel/card, planet_panel, story ids and the Bazaar test; no agent, no code change.
- Agent prompts: none.
- Worked: analysis; the test in run_tests.gd already proves storage.add at the capital fills the bill.
- Failed / did not work: nothing run in a window.
- Files and commits: the proposal file only.
- Left to do: owner to answer the 4 questions in section 6, then tasks T361-T363 are scheduled.

## 2026-11-12 16:10 run: T361 T362 T363
- Summary: Star Bazaar guidance, must set only: Bazaar.next_step / bill_lines / step_line / is_fed, a cycle-end reminder notice (every bazaar_remind_cycles = 4 cycles, only while a bill item is short and unfed) and TIP_BILL (save version 24); texts for the how-to lines and a long description per wing; Bazaar panel with a how line, a step line per short row and Buy at / Send to buttons; a Star Bazaar block on the capital's planet card with a lit Buy button; the top Next Up strip lost its Bazaar slot; the wing popup shows a picture, the effect line and a description; six wing images generated with codex in assets/wings. Not built: Main line card, Bazaar card and Next Up clicks, stage-done next line.
- Why this task: owner request 2026-11-12 ('implement the must ones only', remove the top reminder, wing descriptions, wing pictures via codex).
- Approach: gameplay-programmer (data) and story-designer (texts) in parallel, then ui-programmer; main session made the 2B, 3A, 3B one-line effects truthful and generated the images with codex exec (generic art prompts only), shrunk to 960 px.
- Agent prompts: Agent tool, gameplay-programmer T361, story-designer T363, ui-programmer T362, briefs read from schedule.json; handoffs in handoffs/<agent>/2026-11-12-T36x.json.
- Worked: scratch renders of the panel, capital card and wing popup looked at; no objective breakage.
- Failed / did not work: Buy at highlight uses a new planet_panel.show_lit instead of the tutorial helper; Send to may ask one more click for a stop; a small window scroll not tested; run_tests.gd line ~7336 asserts SaveGame.VERSION == 22 and was already stale.
- Files and commits: see git log on main for T361, T362, T363.
- Left to do: owner decision on stage 3 wings (data gives 3A hold units and 3B tax, names say weather and gig premium); owner decision on the Space Storage draw rule (see chat); Russian for all new ids by the Haiku agents when asked.
