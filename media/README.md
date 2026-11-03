# media/ : documents, archives and reference images (not game-ready)

Nothing in `media/` is loaded by the game. `export_presets.cfg` excludes `media/*` from builds. Naming: `design/art/NAMING.md`.

| Folder | Holds |
|---|---|
| `media/docs/` | Documents and archives (`doc_*`): `doc_gdd.pdf`, `doc_agent_crew.pdf`, `doc_design_system.zip`, `doc_space_station_model.zip` (the station model source archive, moved from `assets/` on 2026-11-03) |
| `media/refs/event_banners/` | JPG reference versions of the event banners `ev01.jpg` to `ev37.jpg` (the shipping banners are the `.webp` files in `art/event_banners/`) |

Files in `media/refs/` keep their `.import` files. Their names are the event ids, not `ref_` names; see `design/art/NAMING.md` section 8.

Where the game-ready files live: `art/README.md`.

## Rules
- Move files with their `.import` (and `.uid`) companions. Before a move, grep the repo for the old path and update every reference.
- After a move, run `Godot --headless --path . --import`, then `sh tools/tests/run.sh`.
