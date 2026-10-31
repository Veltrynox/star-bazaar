extends SceneTree
## Cuts the solar flare sprite sheet (8 by 8 grid, 1254 px square) into 64 frames for the 3D sun.
## Run from the project root:
##   Godot --headless --path . -s res://tools/cut_sun.gd
## Source: art/sun_sheet_v02.png, the master (v01 is kept for a different grid).
## Writes art/sun/frames/sun_flare_00.png .. sun_flare_63.png (row by row, left to right).

const SHEET := "res://art/sun_sheet_v02.png"
const OUT := "res://art/sun/frames"
const GRID := 8

func _init() -> void:
	var sheet := Image.load_from_file(ProjectSettings.globalize_path(SHEET))
	if sheet == null or sheet.is_empty():
		printerr("cut_sun: cannot read %s" % SHEET)
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var cell := sheet.get_width() / GRID
	var n := 0
	for row in GRID:
		for col in GRID:
			var frame := sheet.get_region(Rect2i(col * cell, row * cell, cell, cell))
			frame.save_png(ProjectSettings.globalize_path("%s/sun_flare_%02d.png" % [OUT, n]))
			n += 1
	print("cut_sun: wrote %d frames of %d px" % [n, cell])
	quit(0)
