# Star Bazaar asset naming

Status: APPLIED (2026-11-03, folder reorganisation). Folder map and where to find things: `art/README.md`. Renames after this follow the same rules.

## 1. The rule
- Base names use only `a-z`, `0-9` and `_`. No capitals, spaces, hyphens or commas. The dot appears only before the extension.
- Pattern: `<category>_<subject>[_<type>][_<variant>][_<size or state>].<ext>`
  - category: a fixed prefix from section 3. The file must sit in the folder for its category (section 5).
  - subject: what it shows, one or two words (`energy`, `chevron`, `horizon`).
  - variant: two-digit number (`01`, `02`) or a word from section 4.
  - size or state: a value from section 4.
- Version words (`v01`) appear only on source sheets (section 2), never on game-ready files.

## 2. Frames, sequences and sheets
- Sequence: many frames of one subject in a folder named after that subject. Frame file: `sun_<NN>.png`, `NN` two digits from `00`. Example: `art/sun/frames/flare/sun_00.png` to `sun_63.png`. The folder carries the subject (flare, storm, calm).
- Source sheet (never loaded by the game): `art/source/<category>_sheet_<subject>_<cols>x<rows>[_vNN].png`. Example: `art/source/sun_sheet_flare_8x8_v02.png`.
- Game-ready output is never versioned. The cut script writes `sun_NN.png`, not a versioned name.

## 3. Category prefixes (one example each)
| Prefix | Form | Example | Folder |
|---|---|---|---|
| `ui_` | `ui_<type>_<subject>[_<state>]`, type from {glyph, panel, header, thumb} | `ui_glyph_pause_grey.png` | `art/ui/` |
| `icon_` | `icon_<commodity key>_<size>` (key = data key) | `icon_energy_64.png` | `art/icons/` |
| `sun_` | frame sequence or source sheet | `sun_00.png`, `sun_sheet_flare_8x8_v02.png` | `art/sun/frames/<subject>/`, `art/source/` |
| `planet_` | planet surfaces and body maps | `planet_surface_01.jpg` | `art/planet/` |
| `route_` | route arrow pieces | `route_arrow_head.png` | `art/route/` |
| `model_` | 3D models (one folder per model) | `model_corvette.glb` | `assets/<model>/` |
| `doc_` | documents and archives | `doc_gdd.pdf` | `media/docs/` |
| `ref_` | reference images | `ref_volcanic_crust_01.jpg` | `media/refs/` |

Not in the table yet (see section 8): event banners (`art/event_banners/ev01.webp`) and the 3D station model (`assets/space_station/star_bazaar_station.glb`).

## 4. Fixed word lists
- Colour and state: `amber`, `grey`, `blue` (research accent), `on`, `off`.
- Sizes: `32`, `48`, `64`, `96`, `128`, `256`, `512` (square). Non-square as `WxH`, e.g. `320x96`.
- Grids: `COLSxROWS`, e.g. `8x8`.
- Variants: two-digit numbers only.
- Commodity keys: the keys used in the data files (today `energy`, `food`, and the placeholder goods `silk`, `chips`, `ore`). A new key needs a data entry first.

## 5. Folders
- A folder holds one category. Layout: `art/icons`, `art/ui`, `art/planet`, `art/sun` (frames per subject), `art/route`, `art/event_banners`, `art/source` (sheets and full-size or raw sources, never loaded), `assets/<model>/` (3D only), `media/docs`, `media/refs`.
- Code is not an asset. Scripts (`.gd`), shaders (`.gdshader`), scenes (`.tscn`) and resources (`.tres`) keep snake_case names and belong in `game/`, `art/sun/`, `art/planet_fx/` (planet shader code only) or `tools/`. Generator scripts belong in `tools/`.
- Docs about art sit in `design/art/` (`style.md`, this file).

## 6. Companions
- Godot writes `<file>.import` beside each imported image or model, and `<script>.uid` beside each `.gd` and `.gdshader`.
- Companions take the exact base name plus the added suffix (`sun_00.png.import`). They are renamed together with their file, never alone.
- Any rename: move the file and its companion together; update every reference (`.tscn`, `.tres`, `.gd`, `.gdshader`, `.py`, `.json` in tools, live docs, `export_presets.cfg`); reopen the project or run `Godot --headless --path . --import` so the import cache regenerates; run `sh tools/tests/run.sh`.
- Names built at runtime must change with their format string: `icon_%s_64.svg` (game/ui.gd, goods without a theme icon), `icon_%s_64.png` (tools/make_icons.py output), `ui_thumb_%s` (game/galaxy_view.gd, game/planet_panel.gd via Ui.ui_texture), `sun_%02d.png` in `frames/%s/` (art/sun/sun_flare.gd, tools/cut_sun.gd, tools/sun_center/center_frames.py), `arrow_%s.png` (game/route_line.gd).

## 7. Media rule
`media/` holds documents, archives and reference images only. Nothing in `media/` is game-ready: the game never loads from it, and `export_presets.cfg` already excludes `media/*` from builds. Godot imports `media/refs` images (their `.import` files exist); a `.gdignore` file in `media/refs` would stop that. Option only, not applied.

## 8. Exceptions until the owner decides
- Event banners (owner decision 2026-11-03): lowercase event ids, no prefix. `art/event_banners/ev01.webp` ... `ev37.webp`, `media/refs/event_banners/ev01.jpg` ... `ev37.jpg`, `art/source/event_banners_fullres/ev29.png` ... `ev37.png`. The event ids in `data/events.json` stay uppercase (`EV01`); the loader in `game/main.gd` lowercases the id to build the path.
- `assets/space_station/star_bazaar_station.glb`: the model_ prefix would put it under the export exclude (`assets/model_*`), so it would not ship. Kept until the export rule is changed.
- `assets/asteroid_asset/`: the folder name is the old name. The model is in its own folder, so the layout rule holds.
- `art/sun/frames/<subject>/sun_NN.png`: allowed by section 2. Raw cuts in `art/source/sun_frames_raw/` keep their original `sun_<subject>_NN.png` names.
- `art/planet_fx/`: planet shader and scene code. The planet textures were moved out to `art/planet/`.
- `icon.svg` at the project root: Godot's app icon (`project.godot`), not moved.
- Root-level docs (`gdd.md`, `gdd-log.md`, `gdd-process.md`, `gdd-skills.md`, `state.md`) and `story/reference/`: not moved; the owner decides.

## 9. Check for a name
A name passes if: it matches section 1; its prefix is in section 3; its folder matches that prefix; it has no capitals, spaces, hyphens or commas; frame and variant numbers have two digits. Section 8 names are the known exceptions.
