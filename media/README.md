# media/ : documents and references (not game-ready)

Nothing in `media/` is loaded by the game. `export_presets.cfg` excludes `media/*` from builds.

## Layout (T131, 2026-10-31)

| Folder | Holds | Status |
|---|---|---|
| `media/docs/` | PDFs, zips and other documents (`doc_*`): GDD PDF, agent crew PDF, design system zip | Moved here on T131 |
| `media/refs/` | Reference images (`ref_*.jpg`) with their `.import` files | Already in place, unchanged |
| `media/README.md` | This note | New |

Game-ready files live elsewhere:

| Folder | Holds |
|---|---|
| `art/source/` | Source sheets, never loaded by the game (`sun_sheet_v01..03.png`, moved here on T131) |
| `art/route/` | Route arrow pieces (`route_arrow_head|mid|tail.png`, moved from `assets/route/` on T131) |
| `assets/` | 3D models only (`model_corvette.glb|obj`) |
| `art/sun/`, `art/planet_fx/`, `art/textures/` | Unchanged on T131 (code-coupled, see below) |

## Deferred (not moved on T131)

- `art/textures/*` to `art/ui`, `art/icons`, `art/planet`: format strings in `game/ui.gd`, `game/galaxy_view.gd` and `art/planet_fx/planet_sphere.gd` must change with them.
- `art/planet_fx/`: not moved (owner rule).
- `art/make_icons.py`, `art/make_ui.py` to `tools/`: they write relative to their own folder, so they need a path fix first.
- `art/style.md`, `art/NAMING.md` to `design/` or `media/docs/`: `.claude/agents/fx-programmer.md` names `art/style.md`.
- `icon.svg` at the root: `project.godot` loads it.
- `assets/route/.claude/` remains (harness folder, untracked).
- `dcc/` (planet_texture.hiplc, backup, out) unchanged.

## Rules

- Move files with `git mv`, with their `.import` (and `.uid`) companions, in one commit per folder.
- Before a move, grep the repo for the old path and fix every reference.
- After a move, reopen the project or run a headless import so the cache regenerates, then run `sh tools/tests/run.sh`.
