extends SceneTree
## Screenshot tool for unattended runs (owner-approved 2026-11-06). NOT a QA bot: it plays nothing,
## it only opens a scene or the running game, waits, saves one PNG and quits.
## Run windowed through: sh tools/screenshot.sh --out logs/screenshots/T251.png [options]
## Options (after `--`):
##   --out <png path>     required, res:// or a project-relative path
##   --scene <res://...>  default res://game/main.tscn
##   --frames <n>         frames to wait before the shot, default 60
##   --planet <id>        main.tscn only: open this planet's panel (e.g. dead_1)
## For main.tscn the preface and tutorial are skipped so the map is visible. Hard self-quit after 60 s.

func _arg(name: String, default: String = "") -> String:
	var a := OS.get_cmdline_user_args()
	var i := a.find(name)
	if i >= 0 and i + 1 < a.size():
		return a[i + 1]
	return default

func _initialize() -> void:
	create_timer(60.0).timeout.connect(func(): quit(1))
	var out := _arg("--out")
	if out == "":
		printerr("screenshot_scene: --out is required")
		quit(2)
		return
	var packed = load(_arg("--scene", "res://game/main.tscn"))
	if packed == null:
		printerr("screenshot_scene: cannot load scene")
		quit(2)
		return
	var m: Node = packed.instantiate()
	root.add_child(m)
	await process_frame
	if m.has_method("_dismiss_preface"):
		m._dismiss_preface()
		if "tut_step" in m and "TUT_GUIDE" in m:
			m.tut_step = m.TUT_GUIDE.size()
		await process_frame
		var pid := _arg("--planet")
		if pid != "" and "map" in m:
			for i in m.map.planets.size():
				if str(m.map.planets[i].get("id", "")) == pid:
					m._on_planet_clicked(i)
	for i in int(_arg("--frames", "60")):
		await process_frame
	var path := out if out.is_absolute_path() and not out.begins_with("res://") else ProjectSettings.globalize_path(out if out.begins_with("res://") else "res://" + out)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var err := root.get_texture().get_image().save_png(path)
	print("screenshot_scene: ", path, " ", "ok" if err == OK else "error %d" % err)
	quit(0 if err == OK else 1)
