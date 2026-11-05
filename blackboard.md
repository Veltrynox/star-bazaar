# Main agent blackboard

## Do not repeat
- discovery_enabled in data/balance.json ships at 1 (owner decision 2026-11-05); tests that need it off set it themselves.

## Left to do
- Open build tasks from playtest: T198-T201 (T196, T197, T201 done). T194 done; Competitors still reachable from share panel (L), owner to say if that goes too.
- Open: T185 (visual), T178/T182 (owner-only agents), T05 (only windowed frame time missing, see T193), T166 (superseded). Owner-decision tasks T189-T193 added 2026-11-05.

- Owner: ship cap 20 (T186): decide on economy retune (trip cost, maintenance tuned for 6) and look of the scrolled ship list; other panels not checked at 20 ships.
- Owner: asteroid-asteroid has no link and storage is never a route source (T188 treated as design); tools/project_workflow.html and other files were modified by something else, left uncommitted.

- Owner: T187 rival ships: look (tint, size, trail, galaxy view) and balance keys rival_ship_count / rival_ship_speed (code defaults 3 and 0.6); gdd.md rivals line edited but left uncommitted with other people's gdd.md changes (gdd-log.md is deleted in tree, so no log entry).

- Owner: T176 placeholder systems are ids 3-5 (not 6 total), off by default (data/systems_placeholder.json enabled:false); permit keys reuse permit_2_*; no Russian text; galaxy overview with them on not exercised windowed.

## 2026-11-05 17:00 run: T195
- Summary: Voice narration default volume lowered from 1.0 to 0.5 (const DEFAULT_VOLUME in game/voice.gd), used for new installs; a saved value is kept and the slider is unchanged.
- Why this task: smallest open build task with no dependency or visual question; T196 is large and gates T197-T201.
- Approach: direct edit by main session, three lines, cheaper than an agent.
- Agent prompts: none. No handoff file (no agent).
- Worked: sh tools/tests/run.sh pass=2856 fail=0.
- Failed / did not work: nothing. schedule.json already had uncommitted owner additions (T200 note, T201); they were committed along with my status change.
- Files and commits: game/voice.gd, schedule.json, blackboard.md; commit "T195 ... [no-gdd]".
- Left to do: owner may want a different level than 0.5. Next: T196.

## 2026-11-05 18:00 run: T196
- Summary: Pathfinder and rival ships now accelerate, brake to a stop and turn at a limited yaw rate via new game/ship_motion.gd; rivals fly to a destination, wait, pick the next. 7 placeholder balance keys (data_version 57), save VERSION 8 (v7 loads at rest).
- Why this task: gates T197-T201, no owner decision or QA needed.
- Approach: one shared motion step for both ship kinds rather than duplicated logic.
- Agent prompts: gameplay-programmer, brief = T196 text plus no-QA, no-commit. Produced ship_motion.gd, pathfinder.gd, pathfinder_view.gd, rival_ships.gd, save_game.gd, balance.json, run_tests.gd, handoffs/gameplay-programmer/2026-11-05-T196.json (verified).
- Worked: sh tools/tests/run.sh pass=2875 fail=0.
- Failed / did not work: nothing. Not seen windowed; debug menu listing of new keys unchecked. gdd.md not edited, so committed [no-gdd] (note: ships accelerate/turn is a small design line the owner may want in gdd).
- Files and commits: see git log "T196".
- Left to do: T197-T201; owner to tune the placeholder motion numbers.

## 2026-11-05 19:00 run: T197
- Summary: Ships now face their heading: per-model yaw offset MODEL_YAW_DEG in game/ships.gd (all four ship ids -90), applied via a pivot node in pathfinder_view.gd and rival_ships.gd.
- Why this task: clear bug fix, no owner decision; unblocks T201.
- Approach: code offset table keyed by ship id (readable by the T201 test), no model file edits.
- Agent prompts: ui-programmer, brief = T197 text plus no-QA, no-commit. Produced the three game files and handoffs/ui-programmer/2026-11-05-T197.json (verified).
- Worked: sh tools/tests/run.sh pass=2875 fail=0.
- Failed / did not work: nothing; not seen windowed. Nose end inferred from vertex widths; ship_corvette_01 least certain.
- Files and commits: game/ships.gd, game/pathfinder_view.gd, game/rival_ships.gd, schedule.json, blackboard.md, handoff; commit "T197 ... [no-gdd]".
- Left to do: owner checks windowed that no ship flies backwards (flip entry to 90). Models 05-08 are not in ships.json and have no offset. Next: T201, T200.

## 2026-11-05 20:00 run: T201
- Summary: Added headless `_test_ship_facing` in tools/tests/run_tests.gd: Pathfinder (4 models) and rivals (all systems) face 8 headings within 2 deg, up stays up, turns are gradual and end aligned, resting ships keep heading, every ship id has a MODEL_YAW_DEG entry. No code bugs found.
- Why this task: unblocked by T197, no owner decision, small; T200 is larger.
- Approach: test only, agent-built; assumes model nose is its own -X (documented in game/ships.gd).
- Agent prompts: gameplay-programmer, brief = T201 text plus no-QA, no-commit. Produced run_tests.gd change and handoffs/gameplay-programmer/2026-11-05-T201.json (verified).
- Worked: sh tools/tests/run.sh pass=3073 fail=0.
- Failed / did not work: nothing. Pathfinder not tested in a second solar system separately.
- Files and commits: tools/tests/run_tests.gd, schedule.json, blackboard.md, handoff; commit "T201 ... [no-gdd]".
- Left to do: T200, T198, T199. Unrelated uncommitted files (README.md, tools/build_readme.py, etc.) left alone.
