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

## 2026-11-12 20:30 run: T369
- Summary: Each lane says what it carries: map tags show units next cycle and 'nothing left: <planet> stock goes to other lanes' when earlier lanes take the shared stock; planet card connections show N / cycle per lane, a Stock / needed line when lanes compete, and an inline reason with a fix hint under every stopped lane on both its source and destination card. One cached projection per (storage, good) per refresh. Also today, separate commits: double click on the Flagship card switches to its system; the hub's Buy a ship for the pool is always offered while the pool has room.
- Why this task: owner requests 2026-11-12 ('show how much each lane carries', 'explain why the lane has stopped in the planet UI').
- Approach: one ui-programmer task, the stopped-lane reasons added mid-run by message.
- Agent prompts: Agent tool, ui-programmer, brief read from schedule.json T369 plus the owner's addition; handoff written by the main session.
- Worked: renders of the map tags and Voltara's card looked at (wt/_scratch/t369_map2.png, t369_card3.png); nothing clipped.
- Failed / did not work: raid, cluster and closed reasons not rendered; test not run.
- Files and commits: see git log on main for T369.
- Left to do: owner decision on dividing a planet's stock fairly between lanes before they run.

## 2026-11-12 21:40 run: T370 T371 T372
- Summary: Production boost: a charge boosts one world for the run (Buy orders +boost_order_pct, storage +boost_storage_pct, placeholders 0.5); charges stack; Boost production button with confirm on the planet card, Boosted tag after; sources: new mid-tree skills MIN_16 Quota Charter and BIO_16 Greenhouse Writ (MIN_13 / BIO_12 kept), events EV97 (Military) and EV98 (Luxury) forced after boost_event_force_cycles, GIG03 option A for everyone with its own draw weight; stacking and second-world notices; save key run.boost (no VERSION bump: new optional key).
- Why this task: owner request and answers 2026-11-12 ('run it now').
- Approach: feature-designer proposal (design/proposals/2026-11-12-production-boost.md), then story-designer T370 and gameplay-programmer T371 in parallel, ui-programmer T372.
- Agent prompts: Agent tool, briefs read from schedule.json T370-T372; handoffs in handoffs/<agent>/2026-11-12-T37x.json.
- Worked: renders of the card with a charge, the confirm, the boosted card and the Minerals tree looked at; skill screen opens in about 157 ms with 70 nodes.
- Failed / did not work: BIO tree not viewed; MIN_16 sits on the wrapped second line of its tier (two per line), so it looks lower than the middle.
- Files and commits: see git log on main for T370-T372.
- Left to do: owner to tune the placeholders (economy-designer only on request); Russian for every new id when translation resumes; EV98 penalty uses attar at Voltara.

## 2026-11-12 22:30 run: T373
- Summary: A Space Storage can be the source of a normal route (negative source = the station of that system, from_station mirrors to_station): Send to... on each good row of the storage panel, then click a planet; it takes only that storage's stock, travels from the station marker, pays trip and upkeep only, no level bonus, no skill points; hubs count it as manual cover, raids skip it; the panel lists 'Sent out from here' with Remove; the planet card shows 'From Space Storage' with units and reasons. Planet routes still never draw the storage.
- Why this task: owner decision 2026-11-12 ('Space Storage as a route source: yes').
- Approach: one gameplay-programmer task including the UI.
- Agent prompts: Agent tool, gameplay-programmer, brief read from schedule.json T373; handoff handoffs/gameplay-programmer/2026-11-12-T373.json.
- Worked: renders of the panel, the map line and the planet card looked at; the settle moved 20 energy from the station as projected.
- Failed / did not work: the Russian SS_LBL_STOCK_RULE still shows the old wording (translation paused).
- Files and commits: see git log on main for T373.
- Left to do: route upgrade on a station lane does nothing (no level bonus): owner to say if it should be refused; Russian for the new ids.

## 2026-11-12 23:40 run: T374 T375 T376 and small owner fixes
- Summary: An accepted gig that runs out while the Flagship flies to it stops the ship (T374, signals flight_aborted / offer_expired), plays a 0.8 s signal-lost beat over it (T375: shudder, collapsing amber rings, flickering dashed course, gig ring fades; placeholders flight_juice_lost_s / _size), greys the board row as Gone quiet then fades it and shows Holding position on the Flagship (T376). Same session, main session: exploration mode continues into the next open system and unpresses its button when done; compact skill Learn button; route tags show the good icon instead of 'units' and a credit icon by every amount; GIG02 rewritten (unpaid keeper, debris short cut) and GIG03 hook (crashed Belo Industries hauler); hub pool buy button always offered; double click on the Flagship card switches system; Space Storage panel goods are their own Send buttons (owner rule now in CLAUDE.md).
- Why this task: owner requests 2026-11-12.
- Approach: gameplay-programmer, then juice-programmer and ui-programmer in parallel; small fixes by the main session.
- Agent prompts: Agent tool, briefs read from schedule.json T374-T376; handoffs in handoffs/<agent>/2026-11-12-T37x.json.
- Worked: renders looked at (wt/_scratch/t375_*.png, /Volumes/Work/scratch/t376/*.png, t369_map3.png for the tag icons); commits went through the test gate.
- Failed / did not work: a mislabelled commit f86b355 holds only the T374 notice line in story_text.json (the GIG02 rewrite came in a967cad); the shudder, the gig-ring fade and a real in-game expiry not seen.
- Files and commits: see git log on main.
- Left to do: owner to say if the whole GIG03 gig should follow its new Belo wreck hook (the arrival still describes the quota drum); Russian for every new id when translation resumes.
