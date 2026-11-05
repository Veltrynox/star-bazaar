extends SceneTree
## QA T167: planet names above the edge blur. Shot: qa/reports/planet_labels.png. Quits itself after 60 s at most.
func _initialize() -> void:
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	create_timer(60.0).timeout.connect(quit)
	await process_frame
	m._dismiss_preface()
	for i in 20:
		await process_frame
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://qa/reports/planet_labels.png"))
	quit()
