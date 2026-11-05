extends SceneTree
## QA: Space Storage view of system 2 with a Build button for the Munitions Line (workshops in cells, 2026-11-04).
const OUT := "res://qa/reports/workshop_cell.png"

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
	m.open_systems.append(2)
	m._ensure_stations()
	if not m.station_systems.has(2):
		m.station_systems.append(2)
	m.space_storage_view.open_for(2)
	for i in 6:
		await process_frame
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT))
	quit(0)
