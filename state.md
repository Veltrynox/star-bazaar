# Star Bazaar: project state

Owner: the project owner (see gdd.md, section 3).

## Meter
- 2026-10-25 window 1 start: session 11%, weekly 2%.
- 2026-10-26 window (owner report, producer session): session 67% used (resets 1pm America/Toronto); weekly 9% (resets Nov 1, 4pm America/Toronto).
- Last 24h by subagent: gameplay-programmer 25%, producer 11%, economy-designer 4%, galaxy-builder 4%, creative-director 3%.
- Gameplay-programmer model: the owner decides whether to change it. Producer note: it is the largest share and runs solo.
- Agents' share cap: 68% of weekly meter. Start nothing new at ~80% of a window.

## Queue summary (schedule.json)
- Running: T32 (gameplay, sun review), T37 (economy, planets with no resources), T38 (creative director, planet names). T37, T38 and T32 were started by the main session; Producer recorded them.
- Queued, in order: T39 (apply renames, gameplay, after T37, T38, T32), T07 (automated routes, prototype), T18 and T19 (economy batch with CD), T08, T09, T10, T11, T12, T14, T15, T13, T16, T17. T05 is partial and waits for T15.
- Done: T01 to T04, T06, T20 to T31, T33 to T36, T05b.

## Owner decisions
- Debug menu: live editor for balance.json values and map/camera tunables. Toggle key: backtick (KEY_QUOTELEFT) in code, owner has not confirmed. Stripped from release. Speed button x1, x2, x4, x8, x12; runtime only, not in autosave.
- Game starts paused after the preface text menu; P toggles pause.
- Right-side mission board is text only.
- Gameplay before galaxy background; T05 after T15.
- PENDING owner: planet_3 goods and T01 tuning (T19 first).
- PENDING owner: play-test T03, T20, T21, T25, T28, T30, T33 to T36 in the editor. Godot was not run by agents.
- PENDING owner: debug toggle key; whether Space stays a pause key.

## Layout note
Project is at repo root. Export excludes handoffs/, qa/, tools/, media/, assets/, output/, build/, .claude/, .git/, gdd.md and *.md, and includes data/*.json. Godot 4.7.2 at tools/godot/Godot.app/Contents/MacOS/Godot. Headless check: `--headless --path . --quit-after 300`.

## Handoffs (latest 5 by modification time)
- producer 2026-10-26-w7: handoffs/producer/2026-10-26-w7.json (T37, T38, T39 scheduled).
- gameplay-programmer 2026-10-26 (T36, T35, T34, T33): handoffs/gameplay-programmer/.
- Archive: handoffs/archive/ (older handoffs, including sun review and galaxy-builder T05, T05b, T31, moved 2026-10-26; not read by default). Schedule owner_notes point to archive paths for these.
