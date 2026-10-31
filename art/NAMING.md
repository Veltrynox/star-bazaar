# Star Bazaar asset naming

Status: PROPOSAL (2026-10-31). Not applied. No file is renamed until the owner approves; renames are a later step.

## 1. The rule
- Base names use only `a-z`, `0-9` and `_`. No capitals, spaces, hyphens or commas. The dot appears only before the extension.
- Pattern: `<category>_<subject>[_<type>][_<variant>][_<size or state>].<ext>`
  - category: a fixed prefix from section 3. The file must sit in the folder for its category (section 5).
  - subject: what it shows, one or two words (`energy`, `chevron`, `horizon`).
  - variant: two-digit number (`01`, `02`) or a word from section 4.
  - size or state: a value from section 4.
- Version words (`v01`) appear only on source sheets (section 2), never on game-ready files.

## 2. Frames, sequences and sheets
- Sequence: many frames of one subject in a folder named after that subject. Frame file: `<category>_<NN>.png`, `NN` two digits from `00`. Example: `art/sun/frames/sun_00.png` to `sun_63.png`. The folder carries the subject, so the frame name may omit it.
- Source sheet (never loaded by the game): `art/source/<category>_sheet_<subject>_<cols>x<rows>[_vNN].png`. Example: `art/source/sun_sheet_flare_8x8_v02.png`.
- Game-ready output is never versioned. The cut script writes `sun_NN.png`, not a versioned name.

## 3. Category prefixes (one example each)
| Prefix | Form | Example | Folder |
|---|---|---|---|
| `ui_` | `ui_<type>_<subject>[_<state>]`, type from {glyph, panel, header, thumb} | `ui_glyph_pause_grey.png` | `art/ui/` |
| `icon_` | `icon_<commodity key>_<size>` (key = data key) | `icon_energy_64.png` | `art/icons/` |
| `sun_` | frame sequence or source sheet | `sun_00.png`, `sun_sheet_flare_8x8_v02.png` | `art/sun/`, `art/source/` |
| `planet_` | planet surfaces and body maps | `planet_surface_01.jpg` | `art/planet/` |
| `route_` | route arrow pieces | `route_arrow_head.png` | `art/route/` |
| `fx_` | effect-only textures | `fx_streak_mask.png` | `art/fx/` |
| `tex_` | textures with no home above (avoid) | `tex_grain_256.png` | `art/tex/` |
| `model_` | 3D models | `model_corvette.glb` | `assets/` |
| `doc_` | documents and archives | `doc_gdd.pdf` | `media/docs/` |
| `ref_` | reference images | `ref_volcanic_crust_01.jpg` | `media/refs/` |

## 4. Fixed word lists
- Colour and state: `amber`, `grey`, `blue` (research accent), `on`, `off`.
- Sizes: `32`, `48`, `64`, `96`, `128`, `256`, `512` (square). Non-square as `WxH`, e.g. `320x96`.
- Grids: `COLSxROWS`, e.g. `8x8`.
- Variants: two-digit numbers only.
- Commodity keys: the keys used in the data files (today `energy`, `food`). A new key needs a data entry first.

## 5. Folders
- A folder holds one category. Target layout: `art/ui`, `art/icons`, `art/sun`, `art/planet`, `art/route`, `art/fx`, `art/source` (sheets only), `assets/` (3D only), `media/docs`, `media/refs`.
- Current folders that differ from this are listed in the audit (handoff details). They are not moved now.
- Code is not an asset. Scripts (`.gd`), shaders (`.gdshader`), scenes (`.tscn`) and resources (`.tres`) keep snake_case names and belong in `game/` or `tools/`. Generator scripts belong in `tools/`.

## 6. Companions
- Godot writes `<file>.import` beside each imported image or model, and `<script>.uid` beside each `.gd` and `.gdshader`.
- Companions take the exact base name plus the added suffix (`sun_00.png.import`). They are renamed together with their file, never alone.
- Any rename, in one commit per folder: `git mv` the file and its companion; update every reference (`.tscn`, `.tres`, `.gd`, `.gdshader`, live docs); reopen the project so the import cache regenerates; run the headless load check.
- Names built at runtime must change with their format string: `icon_%s_64.png` (game/galaxy_view.gd), `ui_thumb_%s` (art/planet_fx and game/planet_panel.gd via Ui.ui_texture), `sun_%02d.png` (art/sun/sun_flare.gd, tools/cut_sun.gd), `arrow_%s.png` (game/route_line.gd).

## 7. Media rule
`media/` holds documents, archives and reference images only. Nothing in `media/` is game-ready: the game never loads from it, and `export_presets.cfg` already excludes `media/*` from builds. Godot imports `media/refs` images (their `.import` files exist); a `.gdignore` file in `media/refs` would stop that. Option only, not applied.

## 8. Exceptions until the owner decides
- `sun_NN` frame names: allowed by the sequence rule (section 2).
- `art/style.md` and this file are docs inside `art/`. Target: `design/` or `media/docs/`.
- `art/make_icons.py`, `art/make_ui.py`, `art/planet_fx/planet_texture_gen.gd`: generators, target `tools/`.

## 9. Check for a name
A name passes if: it matches section 1; its prefix is in section 3; its folder matches that prefix; it has no capitals, spaces, hyphens or commas; frame and variant numbers have two digits.
