extends RefCounted
## Company setup: CEO portraits cut from one atlas (art/portraits/portrait_ceo_atlas.png).
## To add a portrait: put its full-size source in art_source/portrait_<id>_full.png, add the id to IDS,
## then run tools/make_portrait_atlas.gd (it reads IDS from this file and rewrites the atlas).

const ATLAS_PATH := "res://art/portraits/portrait_ceo_atlas.png"
## Size of one cell in the atlas. Cells sit in one row, in IDS order. Aspect 1122:1402.
const CELL := Vector2i(256, 320)
const IDS: Array[String] = ["ceo_man_01", "ceo_man_02", "ceo_woman_01", "ceo_woman_02"]

static func region(id: String) -> Rect2:
	var i := IDS.find(id)
	if i < 0:
		i = 0
	return Rect2(i * CELL.x, 0, CELL.x, CELL.y)

static func normalize(id: String) -> String:
	return id if IDS.has(id) else IDS[0]

static func texture(id: String) -> Texture2D:
	var atlas := load(ATLAS_PATH) as Texture2D
	if atlas == null:
		return null
	var t := AtlasTexture.new()
	t.atlas = atlas
	t.region = region(id)
	return t
