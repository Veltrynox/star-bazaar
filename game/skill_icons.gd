## One icon per skill, cut from one atlas (art/ui/ui_glyph_skill_atlas.png): 64 px cells, 8 columns, in IDS order.
## White thin glyphs; the node button tints them. To change: edit tools/make_skill_icons.py (python3), then run
## tools/make_skill_atlas.gd with Godot headless and Godot --headless --import. IDS must match ORDER in that script.

const ATLAS_PATH := "res://art/ui/ui_glyph_skill_atlas.png"
const CELL := 64
const COLS := 8
const IDS := ["FND_STORAGE", "FND_PERMIT", "FND_PROSPECT", "MIL_1", "MIL_2", "MIL_3", "MIL_4", "MIL_5", "MIL_6", "MIL_7", "LUX_1", "LUX_2", "LUX_3", "LUX_4", "LUX_5", "LUX_6", "LUX_7", "MIN_1", "MIN_2", "MIN_3", "MIN_4", "MIN_5", "MIN_6", "MIN_7", "BIO_1", "BIO_2", "BIO_3", "BIO_4", "BIO_5", "BIO_6", "BIO_7", "LUX_5B", "MIN_5B"]

static func region(id: String) -> Rect2:
	var i := IDS.find(id)
	if i < 0:
		return Rect2()
	return Rect2((i % COLS) * CELL, (i / COLS) * CELL, CELL, CELL)

static func texture(id: String) -> Texture2D:
	var atlas := load(ATLAS_PATH) as Texture2D
	if atlas == null or not IDS.has(id):
		return null
	var t := AtlasTexture.new()
	t.atlas = atlas
	t.region = region(id)
	return t
