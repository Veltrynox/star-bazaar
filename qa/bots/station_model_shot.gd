extends SceneTree
## QA: new station model at default zoom, and a close shot at max zoom.
const OUT1 := "res://qa/reports/2026-11-04-station-model-default.png"
const OUT3 := "res://qa/reports/2026-11-04-station-model-closeup.png"
const OUT2 := "res://qa/reports/2026-11-04-station-model-maxzoom.png"

func _initialize() -> void:
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	m._tut_skip()
	m.cash = 5000
	m.learned_skills.append("FND_PROSPECT")
	m.learned_skills.append("FND_STORAGE")
	m._ensure_stations()
	m._ensure_posts()
	for i in 120:
		await process_frame
	var st: Node3D = m.map.stations[1]
	m.map.focus = st.position
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT1))
	m.map.zoom = m.map.zoom_max
	for i in 30:
		await process_frame
	var img := root.get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(OUT2))
	print("zoom ", m.map.zoom, " station scale ", st.scale, " pos ", st.position)
	# inspection only (closer than the game allows): camera 0.45 units from the station, slight downward angle
	m.map.set_process(false)
	m.map.camera.position = st.position + Vector3(0.3, 0.2, 0.3)
	m.map.camera.look_at(st.position, Vector3.UP)
	for i in 3:
		await process_frame
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT3))
	quit(0)
