extends SceneTree
## QA: screenshot of the first planet at game start; only energy and food may show (data/availability.json).
const OUT := "/private/tmp/claude-501/-Volumes-Work-Gamedev-Projects-AgentCourse-star-bazaar/b669418f-f5a0-441b-81fa-a8c4b153bcdb/scratchpad/"

func _initialize() -> void:
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	await process_frame
	m._on_planet_clicked(0)
	for i in 6:
		await process_frame
	print("visible goods: ", Availability.all_visible_goods())
	root.get_texture().get_image().save_png(OUT + "availability_start.png")
	quit(0)
