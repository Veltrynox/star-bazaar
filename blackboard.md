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

## 2026-11-12 17:05 run: T364
- Summary: The Space Storage relay is removed: a route or Sell order at a planet now uses only that planet's own storage (the owner's save showed Voltara -> Space Storage +19 and Voltara -> Flintmoor drawing the same 19 back out in one cycle, storage ended at 0). Routes into a Space Storage, Storage Links, workshops, link upkeep and the Bazaar bill are untouched; space_key_for and the backup parts of project_storage are gone; the two backup tooltip texts are deleted and the station panel text rewritten.
- Why this task: owner request 2026-11-12 ('Remove the space storage relay functionality').
- Approach: reproduced on the owner's autosave with a headless script (wt/_scratch/sim_save.gd, before364.txt / after364.txt: system:1 energy in 19 out 19 after 0 -> in 19 out 0 after 19); one gameplay-programmer task.
- Agent prompts: Agent tool, gameplay-programmer, brief read from schedule.json T364; handoff handoffs/gameplay-programmer/2026-11-12-T364.json.
- Worked: reproduction after the change; run_tests.gd parses; tests updated to the new rule (not run).
- Failed / did not work: nothing run in a window.
- Files and commits: see git log on main for T364.
- Left to do: stock delivered to a Space Storage can now only leave through workshops, link upkeep and Storage Links; owner to decide on Space Storage as a route source. Russian for TIP_SPACE_STORAGE_WHY and SS_LBL_STOCK_RULE needs a Haiku re-translation when the owner asks.

## 2026-11-12 18:30 run: T365 T366 T367
- Summary: T366 (wing popup as framed banner cards, BannerArt moved to game/banner_art.gd) and T367 (dead world card: no Mine and send button, the tile toggles mining, right click opens the goods popup, one hint line) are done and committed; the start skill points drop by one (new key skill_points_home 1) and the Space Storage panel lost its next-cycle line (separate commits); the six wing pictures were redone as simple 480x160 banners. T365 (skill screen connector lines) was STOPPED by the owner before it finished.
- Why this task: owner reports and requests 2026-11-12.
- Approach: ui-programmer agents; T365 killed mid-run by the main session at the owner's request, only T365 touched.
- Agent prompts: Agent tool, ui-programmer, briefs read from schedule.json T365, T366, T367.
- Worked: T366 and T367 renders looked at; no objective breakage.
- Failed / did not work: T365 not finished: game/skill_screen.gd holds its partial, uncommitted edits (about 220 added lines), no test, no handoff, never rendered by the main session.
- Files and commits: see git log on main for T366 and T367.
- Left to do: owner to decide on T365: restart it, keep the partial edits, or revert game/skill_screen.gd (git checkout game/skill_screen.gd); the skill screen lines still cross until then.
