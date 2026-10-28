# Star Bazaar art style

Flat colours, dark outline, transparent background. No gradients, no text in images.

## Palette
- Outline / ink: #12182B
- Energy: #FFC933 (amber)
- Food: #6BCB5B (green)
- Reserve for later commodities: pick a hue not close to amber or green.

## Map icons (art/textures/icons/)
- Name: icon_<commodity key>_<size>.png, sizes 64 and 128. Key matches data (energy, food).
- One simple silhouette per commodity: energy = bolt, food = leaf.
- Outline about 5% of icon width; must read at 24 px on screen.
- Rebuild: python3 art/make_icons.py

## UI look (art/textures/ui/, rebuild: python3 art/make_ui.py)
Quiet, dark glass. Trading UI, not a 4X map.
- Palette: new tokens only. Glass fill #0E121C at 82% alpha. Panel border #AAB6CC at about 35%. Grey text/icons #8A94A6. Pale blue (research) #8FC3FF. Amber #FFC933 is unchanged: accents and the Paused state only. Ink #12182B is unchanged.
- Panels: 8 px corners, 1 px light border, faint top-light gradient. Use ui_panel_glass.png as 9-slice (48 px, margin 10). No drop shadows, no thick borders.
- Icons: thin, one stroke weight (2 px at 32 px), grey by default, amber when active. Map commodity icons keep their flat filled style.
- Labels: light geometric sans. Spaced capitals for section titles only. Numbers and date in monospace.
- Header strip: ui_header_horizon.png, 320x96, dark horizon with a soft warm light. Generic, never a named planet. Crop or stretch width only.
- Planet thumbnail: round, 96 px, 1 px pale ring (#C8D2E1), light from top-left. One per planet type: ui_thumb_volcanic.png (dark crust, glowing amber-red cracks), ui_thumb_temperate.png (blue-green, soft white clouds), ui_thumb_barren.png (grey-brown, cratered, no atmosphere).

## Planet models (prototype, art/planets/, rebuild: python3 art/planets/make_planets_v2.py)
Not wired into the map yet. v1 (make_planets.py, renders planet_<type>.png) is kept for comparison; v2 is the revision after owner notes.
v2 method (same idea, one shader, one draw call for the planet): a 384x192 equirect map (R = height, G = crack, B = cell tone) displaces a 128x64 sphere a little and gives per-pixel normals in planet_v2.gdshader. Changes against the notes:
- Sharper: plates are Voronoi polygons with straight cliffs (about 1 texel wide), craters have a flat deep floor, a steep wall and a raised sharp rim, cracks are cut into the height. Normals are computed per pixel, not per vertex.
- Layers: 3 to 4 height levels per type (base, raised plate, stacked inset top, with 1 to 2 shrunken copies of the polygon as steps) plus a top detail layer (cracks, frost, craters). Cavity darkening in low ground and highlight on convex edges.
- Tones: height picks the layer colour, per-cell tone shifts brightness, accent patches add one more tone.
- Cracks: continuous, from a fine warped Voronoi border mask (no threshold beads), some edges dropped by hash so they break naturally.
- Halo: a second 32x16 shell (radius 1.2, back faces, additive, halo_v2.gdshader). This is a second draw call per planet.
- volcanic (4 tones + ash): crust #2A0A09, rust plates #6E2112, ember #D1570F, amber tops #FFA833, ash patches #2B2624, cracks #FF6100 to hot #FFCC4D, halo #FF590F.
- temperate (4 tones + sand): deep sea #0D4057, shelf #1F7585, land #6B9E6B, frost tops and poles #E0F2F7, sand patches #BDAD75, halo #59BFFF.
- barren (3 tones + dust): basalt #382B24, mid #66523F, light dust #9E8566, ejecta patches #A89475.
- Cost per type: height map 16 to 25 KB PNG (import as Lossless, no mipmaps: VRAM compression breaks the height steps), shader about 3 KB, planet sphere 16,640 tris plus halo 960 tris, 2 draw calls. Dial the sphere to 64x32 for small map sizes.
- Renders planet_<type>_v2.png in art/planets/renders/ are software previews (no GPU window in the sandbox); silhouette displacement and halo blending are not in the preview exactly.

