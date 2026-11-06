extends SceneTree
## Builds art/portraits/portrait_ceo_atlas.png from art_source/portrait_<id>_full.png, one row, cell size and ids from
## game/company_portraits.gd. Run: tools/godot/Godot.app/Contents/MacOS/Godot --headless --path . --script tools/make_portrait_atlas.gd
## Then run Godot --headless --path . --import once.

func _init() -> void:
	var P := load("res://game/company_portraits.gd")
	var cell: Vector2i = P.CELL
	var atlas := Image.create(cell.x * P.IDS.size(), cell.y, false, Image.FORMAT_RGBA8)
	for i in P.IDS.size():
		var path := "res://art_source/portrait_%s_full.png" % P.IDS[i]
		var img := Image.load_from_file(ProjectSettings.globalize_path(path))
		if img == null or img.is_empty():
			push_error("Missing " + path)
			quit(1)
			return
		img.convert(Image.FORMAT_RGBA8)
		img.resize(cell.x, cell.y, Image.INTERPOLATE_LANCZOS)
		atlas.blit_rect(img, Rect2i(0, 0, cell.x, cell.y), Vector2i(i * cell.x, 0))
	var err := atlas.save_png(ProjectSettings.globalize_path(P.ATLAS_PATH))
	print("atlas saved ", P.ATLAS_PATH, " err=", err)
	quit(0 if err == OK else 1)
