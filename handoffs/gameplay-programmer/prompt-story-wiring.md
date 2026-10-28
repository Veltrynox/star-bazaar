# Launch prompt: story wiring, win choice, recording (Star Bazaar)

Producer, 2026-10-27. Launch with ONE section below, matching the task_id that is `running` in schedule.json (the Producer copies the section and the common rules into the launch prompt). Sections: T76, T77, T78, T79. Each is its own window. Never start the next section in the same run.

## Common rules (all sections)
- You are the Gameplay Programmer of Star Bazaar (Godot 4, GDScript). Build only your section. No features, polish or balance changes.
- Texts: never hard-code a story text. Every story text comes from the generated data (data/story_text.json, data/events.json) through game/story_text.gd. The story files in story/ are the source; do not edit them.
- Generated text data is the only exception to the data/ rule: tools/build_story.py is the only writer of data/story_text.json and data/events.json. Say so in your handoff.
- Balance values only from data/balance.json and data/planets.json. Do not change any number.
- Read only: the files named in your section, the game/ files they touch, and the handoffs your task depends on (latest per agent is in state.md). Do not open schedule.json, handoffs/archive/, gdd-log.md or gdd-process.md. Never re-read a file you already read.
- Headless check before you hand back: `tools/godot/Godot.app/Contents/MacOS/Godot --headless --path . --quit-after 300` loads with no errors.
- Stop at your turn cap with a handoff. If the task is bigger, say so with an estimate.
- Handoff: handoffs/gameplay-programmer/<YYYY-MM-DD>-<task_id>.json from handoffs/_template.json. Include what is playable, how to try it in under a minute, up to 3 open_questions (UNKNOWN if unsure), and the envelope. Prose max 200 words. Max 150 words in "handoff".

## Context already settled
- Story texts: story/screens.md (title, preface, menus, notices, tutorial lines, CHOICE_* after T75), story/events.md (events; choice events after T74 writes them), story/skills.md (skill names and text), story/endings.md (Release endings, END_LOSS, END_CORP_* after T75), story/voice.md, story/game-flow.md (route flow; it wins over the GDD for routes).
- Routes are one-way and made with standing Buy and Sell orders and optional "Send to..." routes (T68, done). Old route screen and win screen are gone or superseded.
- The win goal is cash at the end of a cycle (win_cash in data/balance.json). The loss is the window end without the goal.
- The system-1 economy does not reach the goal in a normal run yet (T10: 7120 at cycle 30 against 9000; T54 on hold). Do not fix this; use the force-goal control in T78 for tests.

---

## Section T76: story text loader and wiring

Goal: the game shows the written story texts from data, not hard-coded strings.

1. Write tools/build_story.py. It reads story/screens.md, story/skills.md, story/endings.md and story/events.md and writes:
   - data/story_text.json: one entry per block (id, text, max, place).
   - data/events.json: one entry per event (id, title, tag, kind, text, choices).
   The script fails if a text is over its max, an id repeats, or a block cannot be read unambiguously. If a block is ambiguous, stop and list it in open_questions for the story-designer. Do not guess.
2. Run the script and commit its output. Add game/story_text.gd: get(id, args) returns the text with {placeholders} filled. A missing id logs an error and returns the id.
3. Wire: title screen, preface, main menu entries (game/main_menu.gd), and the notices the engine already emits: route blocked, route stalled, storage full (order idle), dead-state rescue (NOT_DEAD_RESCUE), ship bought, skill point if it exists. Do not add triggers. List every notice that has no trigger in the handoff.
4. Skills: load names and text into data only. The skill tree screen is T71 (stopped).
5. Not in this section: tutorial lines (T15), events (T12), win choice and endings (T77).

Done when: the build passes, the title, preface and menus show the story text, and the headless check is clean.

---

## Section T77: win choice screen and end screens

Goal: at the cash goal the player makes a final choice, then sees the ending for that choice. Replaces the old T14 win and loss screens.

1. At the cash goal (the existing end-of-cycle check) pause and show the choice screen: CHOICE_TITLE, CHOICE_TEXT, two buttons (CHOICE_RELEASE: "Release", CHOICE_CORP: "Stay as a Corporation"), each with its effect line from story/screens.md. No close button. The game stays paused until one is picked.
2. Release: choose the ending with the Release table in story/endings.md (first match wins; default END_ENOUGH). Corporation: choose with the table that T75 adds to story/endings.md (its default ending must be used when nothing else matches).
   Inputs the game knows: learned skill ids, learned count per branch (L, R, E), dominant branch (strictly largest count; none if tied), cycle the goal was reached, final cash, whether this is the last cycle of the window. A1 counts as a normal learned skill in L.
3. Ending screen: ending name, text, END_STAT_LINE (cycle and cash), buttons END_BTN_NEW, END_BTN_MENU, END_BTN_QUIT.
4. Loss (window ends without the goal): END_LOSS and END_LOSS_STAT with cash and goal, same buttons.
5. The dead-state rescue stays a notice (NOT_DEAD_RESCUE), not an ending.
6. When a choice is answered, call the recorder with the side and the ending id. Do not write any file in this section (T78 does that). Use a plain signal or function call; the recorder is added in T78.
7. Save/load: an unanswered choice comes back after a reload. An answered choice does not.

Done when: each branch reaches an ending screen at the goal, the loss screen appears at window end, and the headless check is clean.

---

## Section T78: choice and outcome recording (local only) and the force-goal control

Goal: the game records which side the player chose and which ending they reached, locally, so the owner can count the two choices.

1. On each answered win, add one record to user://stats.json:
   {"schema_version": 1, "wins": N, "choices": {"release": N, "corporation": N}, "endings": {"<ending id>": N}}
   Record when the choice is answered, not when the screen opens.
2. Each run carries a "recorded" flag, saved with the run, so a reload never counts a run twice.
3. Losses are not recorded (owner decision OQ3 may change this).
4. Write atomically: write user://stats.json.tmp, then rename it over user://stats.json. If the file is missing, create it. If it cannot be read, move it to user://stats.bad.json and start fresh.
5. No network, no analytics SDK, no name, no device id. Nothing leaves the machine.
6. No in-game stats screen (owner decides; OQ2).
7. Debug only (stripped from the release export, the same way debug_menu is): a force-goal control that sets cash to win_cash at the end of the current cycle, so QA can reach both branches now. Show the stats file path in the debug menu.

Done when: a forced win answered once adds exactly one count; the file survives a restart; the release export does not include the debug control.

---

## Section T79: tests (headless)

Scripts go under tools/tests/ (not exported). Run them headless with the project.

1. tools/build_story.py runs; every id the game asks for exists in the data; every text is within its max.
2. Ending selection: every Release ending and every END_CORP_* ending is reached by a synthetic input; first match wins; the default is reached when nothing else matches.
3. Recording: one answered win adds one count; a reload does not double count; a corrupt file is moved aside and recreated; a loss adds nothing.
4. Choice screen: exactly two choices, Release and Stay as a Corporation.

Run: the headless check and the test script. Fix only bugs the tests find in the feature code. Report pass and fail counts in the handoff.

---

## Open questions the owner must answer (the Producer will ask in state.md)
1. After "Stay as a Corporation", does the run end on the corporate ending (plan default), or does play continue?
2. Is the recorded count shown in the game (for example the reserved Statistics slot), or only in the file (plan default)?
3. Should runs that end in a loss also be recorded, so the win rate can be compared with the choices (plan default: no)?
