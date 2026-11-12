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

## 2026-11-12 19:10 run: T365 (main session)
- Summary: Skill screen prerequisite lines redone by the main session after the ui-programmer's attempt was stopped (its partial edit reverted): thin orthogonal routes (1 px locked, 1.5 px learned), down into the gap under the parent, across, down a clear lane beside any node in the way, across above the child, into it; two nodes on one line join side to side; routes cached per layout (cell rects fingerprinted at draw), the learn animation only recolours. Old mid-row horizontals and the clip-through-nodes code are gone.
- Why this task: owner report 2026-11-12 ('lines visibly not matching, many lines intersect'); owner asked the main session to do it after the agent's version could not open the window.
- Approach: rendered the screen from the owner's autosave at 1920x1080 and 1280x720 before and after (wt/_scratch/skills.png, skills_after.png, skills_720.png); cause was the horizontal run at the midpoint between parent and child (inside intermediate wrapped lines) and verticals through nodes under the parent; fixed in game/skill_screen.gd route_link; test _test_skill_link_clip replaced by _test_skill_link_route.
- Agent prompts: none (ui-programmer T365 killed before the handoff).
- Worked: both renders looked at: no line through a node, lanes shared, nothing clipped.
- Failed / did not work: lines still cross each other where a lane meets another parent's bus (circuit look, accepted); a link's short stub can overlap a sibling's lit stub in a different colour.
- Files and commits: see git log on main for T365.
- Left to do: owner to look at the skill screen windowed.

## 2026-11-12 19:40 run: T368
- Summary: The seven gig hooks (the line under a signal on the gig board) are short story paragraphs now, 239 to 342 characters, in the voice of the arrival texts: what the crew hears, where it comes from, one pulling detail, why nobody answered; the _HOOK limit in tools/build_story.py is 420 (was 140). English only; the Russian hooks are the old short ones until the owner asks for a translation.
- Why this task: owner request 2026-11-12 ('replace this haiku with something more storytelling, x3').
- Approach: story-designer; the main session read all seven hooks and the board code (the row label wraps and the board scrolls, so no UI change).
- Agent prompts: Agent tool, story-designer, brief read from schedule.json T368; handoff handoffs/story-designer/2026-11-12-T368.json (old and new text of every hook).
- Worked: build_story.py clean, no skipped ids.
- Failed / did not work: not seen on the board in a window.
- Files and commits: see git log on main for T368.
- Left to do: owner to say if 'eleven taps' should come back in the quota drum hook (the file rule forbids numbers, so the agent dropped it); the arrival texts still say 'the scout' for the Flagship (older word, a later pass); Russian hooks when translation resumes.

## 2026-11-12 20:30 run: T369
- Summary: Each lane says what it carries: map tags show units next cycle and 'nothing left: <planet> stock goes to other lanes' when earlier lanes take the shared stock; planet card connections show N / cycle per lane, a Stock / needed line when lanes compete, and an inline reason with a fix hint under every stopped lane on both its source and destination card. One cached projection per (storage, good) per refresh. Also today, separate commits: double click on the Flagship card switches to its system; the hub's Buy a ship for the pool is always offered while the pool has room.
- Why this task: owner requests 2026-11-12 ('show how much each lane carries', 'explain why the lane has stopped in the planet UI').
- Approach: one ui-programmer task, the stopped-lane reasons added mid-run by message.
- Agent prompts: Agent tool, ui-programmer, brief read from schedule.json T369 plus the owner's addition; handoff written by the main session.
- Worked: renders of the map tags and Voltara's card looked at (wt/_scratch/t369_map2.png, t369_card3.png); nothing clipped.
- Failed / did not work: raid, cluster and closed reasons not rendered; test not run.
- Files and commits: see git log on main for T369.
- Left to do: owner decision on dividing a planet's stock fairly between lanes before they run.
