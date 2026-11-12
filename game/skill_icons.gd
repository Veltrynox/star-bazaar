## One icon per skill, cut from one atlas (art/ui/ui_glyph_skill_atlas.png): 64 px cells, 8 columns, in IDS order.
## White thin glyphs; the node button tints them. To change: edit tools/make_skill_icons.py (python3), then run
## tools/make_skill_atlas.gd with Godot headless and Godot --headless --import. IDS must match ORDER in that script.

const ATLAS_PATH := "res://art/ui/ui_glyph_skill_atlas.png"
const CELL := 64
const COLS := 8
const IDS := ["FND_STORAGE", "FND_PERMIT", "FND_PROSPECT", "MIL_1", "MIL_2", "MIL_3", "MIL_4", "MIL_5", "MIL_6", "MIL_7", "LUX_1", "LUX_2", "LUX_3", "LUX_4", "LUX_5", "LUX_6", "LUX_7", "MIN_1", "MIN_2", "MIN_3", "MIN_4", "MIN_5", "MIN_6", "MIN_7", "BIO_1", "BIO_2", "BIO_3", "BIO_4", "BIO_5", "BIO_6", "BIO_7", "LUX_5B", "MIN_5B", "FND_LEDGER", "FND_RIVAL_WATCH", "FND_DOCKS", "MIL_8", "MIL_9", "MIL_10", "MIL_11", "MIL_12", "MIL_13", "MIL_14", "MIL_15", "LUX_8", "LUX_9", "LUX_10", "LUX_11", "LUX_12", "LUX_13", "LUX_14", "LUX_15", "MIN_8", "MIN_9", "MIN_10", "MIN_11", "MIN_12", "MIN_13", "MIN_14", "MIN_15", "BIO_8", "BIO_9", "BIO_10", "BIO_11", "BIO_12", "BIO_13", "BIO_14", "BIO_15"]

## T372: nodes that reuse another node's glyph (no new art): MIN_16 the factory, BIO_16 the culture flask.
const ALIAS := {"MIN_16": "MIN_1", "BIO_16": "BIO_2"}

static func region(id: String) -> Rect2:
	id = ALIAS.get(id, id)
	var i := IDS.find(id)
	if i < 0:
		return Rect2()
	return Rect2((i % COLS) * CELL, (i / COLS) * CELL, CELL, CELL)

static func texture(id: String) -> Texture2D:
	id = ALIAS.get(id, id)
	var atlas := load(ATLAS_PATH) as Texture2D
	if atlas == null or not IDS.has(id):
		return null
	var t := AtlasTexture.new()
	t.atlas = atlas
	t.region = region(id)
	return t
