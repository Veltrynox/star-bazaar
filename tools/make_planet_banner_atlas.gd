extends SceneTree
## Builds art/planet/planet_surface_banner_atlas.png from art/source/planet_surface_<id>_<name>_full.png.
## Cell size, columns, ids and names come from game/planet_banners.gd.
## Run: tools/godot/Godot.app/Contents/MacOS/Godot --headless --path . --script tools/make_planet_banner_atlas.gd
## Then run Godot --headless --path . --import once.

func _init() -> void:
	var P := load("res://game/planet_banners.gd")
	var cell: Vector2i = P.CELL
	var sz: Vector2i = P.atlas_size()
	var atlas := Image.create(sz.x, sz.y, false, Image.FORMAT_RGBA8)
	for i in P.IDS.size():
		var id: String = P.IDS[i]
		var path := "res://art/source/planet_surface_%s_%s_full.png" % [id, P.NAMES[id]]
		var img := Image.load_from_file(ProjectSettings.globalize_path(path))
		if img == null or img.is_empty():
			push_error("Missing " + path)
			quit(1)
			return
		img.convert(Image.FORMAT_RGBA8)
		img.resize(cell.x, cell.y, Image.INTERPOLATE_LANCZOS)
		atlas.blit_rect(img, Rect2i(0, 0, cell.x, cell.y), Vector2i((i % P.COLUMNS) * cell.x, (i / P.COLUMNS) * cell.y))
	var err := atlas.save_png(ProjectSettings.globalize_path(P.ATLAS_PATH))
	print("atlas saved ", P.ATLAS_PATH, " err=", err)
	quit(0 if err == OK else 1)
