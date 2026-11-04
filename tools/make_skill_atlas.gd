extends SceneTree
## Rasterises art/source/ui_glyph_skill_atlas.svg (made by tools/make_skill_icons.py) to art/ui/ui_glyph_skill_atlas.png.
## Run: tools/godot/Godot.app/Contents/MacOS/Godot --headless --path . --script tools/make_skill_atlas.gd
## Then once: Godot --headless --path . --import

func _init() -> void:
	var svg := FileAccess.get_file_as_string("res://art/source/ui_glyph_skill_atlas.svg")
	var img := Image.new()
	var err := img.load_svg_from_string(svg, 1.0)
	if err != OK:
		push_error("svg load failed %d" % err)
		quit(1)
		return
	img.convert(Image.FORMAT_RGBA8)
	err = img.save_png(ProjectSettings.globalize_path("res://art/ui/ui_glyph_skill_atlas.png"))
	print("atlas ", img.get_size(), " err=", err)
	quit(0 if err == OK else 1)
