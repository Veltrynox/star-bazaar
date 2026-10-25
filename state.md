# Star Bazaar: project state

Owner: the project owner (see gdd.md, section 3).

## Meter
- 2026-10-25 window 1 start (owner /usage report): current session 11% used, weekly (all models) 2% used. Weekly resets Nov 1, 4pm America/Toronto.
- Agents' share cap: 68% of weekly meter. Stop starting new work at ~80% of a window.

## Queue summary (schedule.json, 17 tasks)
- Running: T01 economy baseline check of balance.json and planets.json (economy batch, W1).
- T02 layout and macOS export preset: partial. Owner created export_presets.cfg in the Godot editor. Bundle id com.example.starbazaar (confirmed). Signing is ad-hoc (owner's choice); no Developer ID or notarization planned. Export test is owner-run and not yet reported. T02 stays partial until the owner reports. T03 is not blocked on it.
- Next in dependency order: T03 cycle timer and goal line, then T04 planets, T06 buy ship and manual trade, T07 routes and saturation.
- Order after the core loop: T08 and T09 (CD and QA batch), T10 economy retune, T11 permits, T12 events, T14 win and loss, T15 tutorial, T13 debug and Game Control menus, T05 galaxy background (own window, queued after T15), T16 and T17 (CD and QA batch on full build).

## Decisions recorded
- T13 (debug and Game Control menus) is after the tutorial (T15), per owner.
- T05 (galaxy background) is a visual element, not gameplay. Queued after T15; owner has not fixed the position.
- assets/ stays excluded from the export for now. It returns when the ship model is used (task note on T06).

## Layout note
Project is at repo root. res:// covers the whole repo. The export excludes handoffs/, qa/, tools/, media/, assets/, output/, build/, .claude/, .git/, gdd.md and *.md, and includes data/*.json.

## Handoffs (latest 5)
- producer 2026-10-25: queue created, T01 started, T02 partial. Schedule and meter recorded. No archive moves needed (no earlier handoffs).
