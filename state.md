# Star Bazaar: project state

Owner: the project owner (see gdd.md, section 3).

## Meter
- 2026-10-25 window 1 start: session 11%, weekly 2%. Weekly resets Nov 1, 4pm America/Toronto.
- 2026-10-25 window 2 later: session 16%, weekly 3%.
- 2026-10-25 window 3 start: session 16%, weekly 3%.
- 2026-10-25 window 4 start: no figure from owner. Last known session 16%, weekly 3%.
- 2026-10-25 window 5 start: owner gave no current figure. Last known session 20%, weekly 3% (owner message). UNKNOWN current.
- Agents' share cap: 68% of weekly meter. Start nothing new at ~80% of a window.

## Queue summary (schedule.json, 25 tasks)
- Running: T04 (gameplay-programmer, planet panel). T22 (economy-designer, planet x/y fields in data/planets.json, owner-requested early start, data only).
- Done: T01, T02, T03, T20 (zoom 0.25 to 3.0 approved), T21 (owner accepted).
- Queued, in order: T23 (preface menu, start paused, P key) and T24 (right-side Buy a ship board), both after T04. T25 (map uses positions) after T22 and T24. Then T06 (buy ship), T07 (automated routes).
- Economy batch (T18, T19, T08, T09, T10) after T07, per owner.
- Then: T11, T12, T14, T15 (tutorial), T13, T05 (galaxy, after T15), T16, T17.

## Owner decisions
- tools/sim.py approved. data/balance.json changes from T01 KEPT.
- T21 accepted (3D spheres, orbit limits 45 yaw, 20 to 80 pitch).
- Zoom bounds ZOOM_MIN 0.25 / ZOOM_MAX 3.0 APPROVED (window 5).
- Planet position fields approved (T22). Position switch is T25.
- Game starts paused after the preface text menu; P toggles pause (window 5).
- Right-side mission board is text only, built before the full tutorial (T24, T15).
- Gameplay before galaxy background; T05 after T15. T13 after T15.
- assets/ stays excluded from the export until the ship model is used (T06).
- PENDING owner: planet_3 goods and T01 tuning (T19 first).
- PENDING owner: play-test T03, T20, T21 in the editor.
- PENDING owner: whether Space stays a pause key (T23 reports what it kept).

## Layout note
Project is at repo root. Export excludes handoffs/, qa/, tools/, media/, assets/, output/, build/, .claude/, .git/, gdd.md and *.md, and includes data/*.json. Godot 4.7.2 at tools/godot/Godot.app/Contents/MacOS/Godot. Headless check: `--headless --path . --quit-after 300`.

## Handoffs (latest 5)
- producer 2026-10-25 (window 6, diagnostic): handoffs/producer/2026-10-25-w6.json. Started T24 via Agent tool; marked T24 done.
- gameplay-programmer 2026-10-25 (T24): handoffs/gameplay-programmer/2026-10-25-T24.json. Right-side 'Buy a ship' board, text only. Not verified visually.
- gameplay-programmer 2026-10-25 (T21): handoffs/gameplay-programmer/2026-10-25-T21.json. Owner accepted.
- gameplay-programmer 2026-10-25 (T20): handoffs/gameplay-programmer/2026-10-25-T20.json.
- producer 2026-10-25 (window 5): handoffs/producer/2026-10-25-w5.json. Started T22, queued T23 to T25.
- Archive: handoffs/archive/ (T01 window 2, T01 window 3, producer window 4, T03; not read by default).

## Window 6 (diagnostic, 2026-10-25)
- Meter: owner gave no figure. UNKNOWN current; last known session 20%, weekly 3%.
- Agent tool: callable by Producer. Launch returns async; agent notifies on completion. No background flag in schema.
- Windows 4 and 5: T04 and T22 were marked running in schedule.json without a verified agent launch (guess: earlier Producer sessions lacked the Agent tool; commit 77309cc added it).
- Running: T04 (unchanged), T22 status still running in schedule.json (its handoff file exists, not verified by Producer).
