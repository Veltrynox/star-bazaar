# Star Bazaar: project state

Owner: the project owner. Agent workflow: gdd-process.md (read only if your brief says so).
Keep this file under 40 lines. Detail goes in handoffs; link to it here.

## Meter
- 2026-10-26 window start (owner report): session 67% (resets 1pm America/Toronto); weekly 9% (resets Nov 1, 4pm America/Toronto).
- Current reading: UNKNOWN. Owner reports before W1. Start nothing new at about 80% of a window.
- UNKNOWN: per-agent 24h figures (36%) do not match weekly 9%. Owner to say which to track against the 68% agent cap.

## Scope (owner, 2026-10-26)
- Systems 2 and 3 ON HOLD. Playable system 1 only (Voltara, Tillam, Ashgate).
- Automated routes are the core loop. Manual trading removed. Ship upgrades deferred (route level later). Planet stock removed.
- Prices: planets.json is the single source. win_cash 9000, 30-cycle window and ship_cap 8 kept.
- Saturation 5 credits off the sell price per extra ship; stranded = zero ships and cash below ship_price; rescue_stipend 1000.
- Game starts paused after the preface; P toggles pause. Debug key: backtick in code, owner not confirmed.

## Route redesign (owner, 2026-10-27)
- Routes are one-way, made by clicking a planet: resource row, Buy or Sell. No top-menu route screen. One ship per route, auto-assigned.
- Planet storage (shared capacity, 5-level rating). Full destination blocks the route (red, notification); empty source stalls it.
- Space storage per system, later (T64, on hold). Two ship types. Skill tree bought with expansion points (T59 owner brief, T60).
- Saturation rule removed (owner). Win goal unchanged (cash target). Route art: assets/route/ (tail, mid, head).
- Upkeep (ship maintenance) must be visible to the player: T69.
- Order: T55, T56, T57, T58, owner playtest T61, then GDD T62 and economy T63. Abstract numbers first. Producer to place windows.

## Queue (full detail: schedule.json, one task: `python3 tools/task.py <id>`)
- W1 T48 economy. W2 T44, T50. W3 T51, T52. W4 T07. W5 T07b, T40b. W6 T53 QA bot rewrite. W7 T47 QA re-run.
- W8 T15 tutorial. W9 T05 galaxy. W10 T12 events. W11 T13 Game Control. W12 T14 win/loss. W13 T17 QA.
- On hold: T11 permits, T54 economy retune for system 1.
- Done tasks: handoffs/archive/schedule-done-2026-10-26.json.

## Open questions
- OWNER: system-1 win path. Best no-permit line in T10 reaches 7120 at cycle 30, below win_cash 9000 (handoffs/economy-designer/2026-10-26-T10.json). Options: lift the hold, change win_cash or the window, change system-1 income (T54).
- OWNER: ship_cap 8 (kept) or 6.
- UNKNOWN: how many agent windows have run today (cap 2 per day).

## Layout note
Project is at repo root. Export excludes handoffs/, qa/, tools/, media/, assets/, output/, build/, .claude/, .git/, gdd.md and *.md, and includes data/*.json. Godot 4.7.2 at tools/godot/Godot.app/Contents/MacOS/Godot. Headless check: `--headless --path . --quit-after 300`. Cheap economy check: `python3 tools/sim.py --mc 50`.

## Latest handoff per agent (the Producer updates this list)
- economy-designer: handoffs/economy-designer/2026-10-26-T10.json
- gameplay-programmer: handoffs/gameplay-programmer/2026-10-26-T40b.json
- producer: handoffs/producer/2026-10-26-replan.json
- galaxy-builder, qa-analyst: none yet
- Archive: handoffs/archive/. Not read by default.
