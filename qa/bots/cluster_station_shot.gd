extends SceneTree
## QA: click path cluster card -> "Send ore to..." -> click the Space Storage station; screenshot with the route line.
const OUT := "res://qa/reports/2026-11-04-cluster-to-station.png"

func _initialize() -> void:
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	m._tut_skip()
	m.cash = 5000
	m.ships = 2
	m.learned_skills.append("FND_PROSPECT")
	m.learned_skills.append("FND_STORAGE")
	m._ensure_stations()
	m._ensure_posts()
	await process_frame
	var c0: Dictionary = m.clusters.list(1)[0]
	m._on_cluster_clicked(int(c0["index"]))
	m.cluster_info.find_child("ClusterSendButton", true, false).pressed.emit()
	await process_frame
	var p: Vector2 = m.map.camera.unproject_position(m.map.stations[1].position)
	for down in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = down
		e.position = p
		e.global_position = p
		m.map._unhandled_input(e)
	for i in 8:
		await process_frame
	print("routes: ", m.engine.routes.size(), " notice: ", m.notice_label.text)
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT))
	quit(0)
