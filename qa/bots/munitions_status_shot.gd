extends SceneTree
## QA: Space Storage view of system 1 with a built Munitions Line that stalls (energy short, chips hidden).
const OUT := "res://qa/reports/munitions_status.png"

func _initialize() -> void:
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	m.tut_step = m.TUT_GUIDE.size()
	await process_frame
	m.cash = 5000
	m.learned_skills.append("MIL_1")
	m.learned_skills.append("FND_STORAGE")
	m._ensure_stations()
	print("build: ", m.build_workshop("munitions"))
	m.workshops.run(m.storage, Callable(m, "craft_units"))
	m.space_storage_view.open_for(1)
	for i in 6:
		await process_frame
	print("status: ", m.workshops.status_text("munitions"))
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT))
	quit(0)
