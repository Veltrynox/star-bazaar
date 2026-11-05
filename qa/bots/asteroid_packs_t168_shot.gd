extends SceneTree
## T168: asteroid field 2x, same rock size. Hard self-quit after 60 s.
func _initialize() -> void:
	create_timer(60.0).timeout.connect(func(): quit(1))
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	m._tut_skip()
	m.learned_skills.append("FND_PROSPECT")
	var c: Dictionary = m.clusters.list(1)[1]
	m.map.focus = Vector3(float(c["x"]), 0.0, float(c["y"])) * 0.02
	m.map.zoom = 3.0
	m.map.pitch_deg = 70.0
	m.map._update_camera()
	for i in 8:
		await process_frame
	root.get_texture().get_image().save_png("res://qa/reports/2026-11-05-T168-asteroids.png")
	print("FPS ", Engine.get_frames_per_second())
	quit(0)
