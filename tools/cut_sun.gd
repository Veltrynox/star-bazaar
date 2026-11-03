extends SceneTree
## Cuts the solar sheets into 64 frames each for the 3D sun, using the crop saved by tools/sun_crop/index.html.
## Run from the project root:
##   Godot --headless --path . -s res://tools/cut_sun.gd
## Reads tools/sun_crop/crop.json (origin x/y, cell_w/cell_h, gap, cols, rows, in px of the sheet, per sheet).
## A sheet with no entry in crop.json is reported and skipped; nothing is guessed.
## If crop.json is missing, or any cut frame is not the cell size, no frame is written and the exit code is 1.
## Writes art/sun/frames/<subject>/sun_00.png .. sun_63.png, subject = flare, storm or calm (row by row, left to right):
##   v01 -> sun_storm (strongest flares), v02 -> sun_flare (a few flares, in use), v03 -> sun_calm.
## The sheets in art/source/ are only read, never changed.

const SHEETS := {
	"v01": ["res://art/source/sun_sheet_storm_8x8_v01.png", "sun_storm"],
	"v02": ["res://art/source/sun_sheet_flare_8x8_v02.png", "sun_flare"],
	"v03": ["res://art/source/sun_sheet_calm_8x8_v03.png", "sun_calm"],
}
const CROP := "res://tools/sun_crop/crop.json"
const OUT := "res://art/sun/frames"
const FIELDS := ["x", "y", "cell_w", "cell_h", "gap", "cols", "rows"]

func _init() -> void:
	var crop_path := ProjectSettings.globalize_path(CROP)
	if not FileAccess.file_exists(crop_path):
		printerr("cut_sun: %s does not exist. Open tools/sun_crop/index.html, confirm the crop, save crop.json. No frames written." % CROP)
		quit(1)
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(crop_path))
	if typeof(data) != TYPE_DICTIONARY or typeof(data.get("sheets")) != TYPE_DICTIONARY:
		printerr("cut_sun: %s is not valid (expected {\"sheets\": {...}}). No frames written." % CROP)
		quit(1)
		return
	# Pass 1: cut everything in memory and check sizes. Pass 2 writes, only if all is well.
	var jobs := []  # [file path, Image]
	var failed := false
	for key in SHEETS:
		var cfg = data["sheets"].get(key)
		if cfg == null:
			print("cut_sun: %s has no confirmed crop in crop.json, SKIPPED" % key)
			continue
		var ok := true
		for f in FIELDS:
			if not cfg.has(f) or typeof(cfg[f]) != TYPE_FLOAT:
				printerr("cut_sun: %s crop is missing number '%s'" % [key, f])
				ok = false
		if not ok:
			failed = true
			continue
		var sheet := Image.load_from_file(ProjectSettings.globalize_path(SHEETS[key][0]))
		if sheet == null or sheet.is_empty():
			printerr("cut_sun: cannot read %s" % SHEETS[key][0])
			failed = true
			continue
		var cw := int(cfg["cell_w"])
		var ch := int(cfg["cell_h"])
		var n := 0
		for row in int(cfg["rows"]):
			for col in int(cfg["cols"]):
				var rect := Rect2i(int(cfg["x"]) + col * (cw + int(cfg["gap"])), int(cfg["y"]) + row * (ch + int(cfg["gap"])), cw, ch)
				var frame := sheet.get_region(rect)
				var good := frame.get_size() == Vector2i(cw, ch)
				print("cut_sun: %s %s_%02d at %s -> %dx%d %s" % [key, SHEETS[key][1], n, rect.position, frame.get_width(), frame.get_height(), "ok" if good else "WRONG SIZE, expected %dx%d" % [cw, ch]])
				if not good:
					failed = true
				jobs.append(["%s/%s/sun_%02d.png" % [OUT, SHEETS[key][1].trim_prefix("sun_"), n], frame])
				n += 1
	if failed:
		printerr("cut_sun: check failed, no frames written.")
		quit(1)
		return
	for subj in ["flare", "storm", "calm"]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT + "/" + subj))
	for j in jobs:
		j[1].save_png(ProjectSettings.globalize_path(j[0]))
	print("cut_sun: wrote %d frames" % jobs.size())
	quit(0)
