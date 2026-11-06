# art/ : shipping 2D art

Game-ready images the game loads live here, one category per folder. Naming rules: `design/art/NAMING.md`. Art style: `design/art/style.md`. Documents and reference images are in `media/`, 3D models in `assets/`. Fonts and the UI Theme (with its icons) are in `ui/fonts/` and `ui/theme/`.

| Folder | Holds | Loaded by |
|---|---|---|
| `art/icons/` | Commodity icons `icon_energy_64.png`, `icon_energy_128.png`, `icon_food_64/128.png`; placeholder goods `icon_silk_64.svg`, `icon_chips_64.svg`, `icon_ore_64.svg` | `game/ui.gd` (theme icons and the goods fallback) |
| `art/ui/` | UI pieces: `ui_glyph_*`, `ui_header_horizon.png`, `ui_panel_glass.png`, planet thumbnails `ui_thumb_<type>.png`, skill icon atlas `ui_glyph_skill_atlas.png` (31 cells, 64 px, 8 columns; source `art_source/ui_glyph_skill_atlas.svg`, rebuild `python3 tools/make_skill_icons.py` then `tools/make_skill_atlas.gd` headless) | `game/ui.gd` (`Ui.ui_texture`), `game/skill_icons.gd`, `game/planet_panel.gd`, `game/galaxy_view.gd` |
| `art/planet/` | Planet surface maps `planet_<type>_beauty.png` and `_displacement.png`, `planet_cloud.png`, `planet_lights_mask.png`, `planet_glowing_mask.png`, `planet_toxic_beauty.png` (dead worlds), `planet_asteroid_01/02.png`, `planet_surface_01.jpg` (fallback), `planet_sphere_tone.png` (baked by `tools/planet_texture_gen.gd`) | `game/fx/planet/planet_sphere.gd` and its materials |
| `art/sun/frames/<subject>/` | The 3D sun's 64 frames per sheet: `flare/`, `storm/`, `calm/`, files `sun_00.png` to `sun_63.png` | `game/fx/sun/sun_flare.gd` (cut by `tools/cut_sun.gd`, centred by `tools/sun_center/`) |
| `art/portraits/` | CEO portrait atlas `portrait_ceo_atlas.png` (one row, 256x320 cells, built by `tools/make_portrait_atlas.gd`; ids and cells in `game/company_portraits.gd`) | `game/company_portraits.gd`, `game/company_setup.gd`, `game/game_menu.gd` |
| `art/event_banners/` | Event banner images `ev01.webp` to `ev37.webp`, lowercase event id (the id in `data/events.json` is `EV01`; the loader lowercases it) | `game/main.gd`, `game/event_notice.gd` |
| `art_source/` (top level, not in `art/`) | Never loaded by the game, has a `.gdignore` so Godot does not import it: sun sheets `sun_sheet_<subject>_8x8_vNN.png`, raw sun frames `sun_frames_raw/`, full-size CEO portraits `portrait_<id>_full.png` (input of the atlas tool), full-size planet surface banners `planet_surface_<id>_<name>_full.png` (input of `tools/make_planet_banner_atlas.gd`), full-size dead-world banners `event_banners_fullres/` (`ev29.png` to `ev37.png`) | `tools/cut_sun.gd` (reads the sheets), `tools/sun_center/` (reads the raw frames) |

## Where the other pieces are
- Effect code (not art): `game/fx/planet/` (planet and map effect scripts, shaders, materials, scenes; used by `game/map.gd`) and `game/fx/sun/` (`sun_flare.gd`, `hex_ring.gd`, `sun.gdshader`).
- Never-loaded sources: `art_source/` (tools read it by file path, so `art_source/.gdignore` is set).
- 3D models: `assets/corvette/` (not shipped), `assets/space_station/`, `assets/asteroid_asset/`. Each model in its own folder.
- Documents, archives, reference images: `media/docs/` (PDFs, zips), `media/refs/event_banners/` (JPG versions of the banners). Nothing in `media/` is shipped.
- Art docs: `design/art/style.md` (palette, look, what each icon must show) and `design/art/NAMING.md` (naming rule and known exceptions).
- Generators (write into `art/`): `tools/make_icons.py` (icons), `tools/make_ui.py` (UI pieces), `tools/planet_texture_gen.gd` (planet tone map). Run from the project root, e.g. `python3 tools/make_icons.py`.

## Adding or renaming an image
1. Name it by `design/art/NAMING.md` section 1 and put it in the folder for its category.
2. Move a file with its `.import` (and `.uid`) file together. Update every path that names it (`game/`, `game/fx/planet/*.gd`, `*.tres`, `tools/`, docs).
3. Run `Godot --headless --path . --import` once, then `sh tools/tests/run.sh`.

## Open items (not changed in this reorganisation)
- `game/fx/planet/planet_sphere.gd` names `res://art/planet/asteroid_ring_1.png` for the moon ring. That file is not in the repo. `planet_asteroid_01.png` may be the intended ring; the owner decides.
- `art/planet/planet_glow_mask.jpg`, `planet_asteroid_02.png`, `planet_glowing_mask.png` and the two dead-world portraits (`planet_cinderrest_surface.png`, `planet_greywake_surface.png`) are not loaded by any script yet.
- `art/style.md` mentions an `art/planets/` folder for planet prototypes that is not in the repo.
