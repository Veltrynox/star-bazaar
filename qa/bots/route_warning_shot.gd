extends SceneTree
## QA: starts a route with too little cash for a ship, saves a screenshot, then checks the warning clears.
const OUT := "/private/tmp/claude-501/-Volumes-Work-Gamedev-Projects-AgentCourse-star-bazaar/b669418f-f5a0-441b-81fa-a8c4b153bcdb/scratchpad/"

func _initialize() -> void:
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	await process_frame
	m.ships = 0
	m.cash = 10
	m.pending = {"planet": 0, "c": "ore"}
	m._pending_changed()
	m.get_viewport().warp_mouse(Vector2(700, 400))
	for i in 4:
		await process_frame
	print("unaffordable: ", m.route_unaffordable(), " visible ", m.route_warning.visible)
	root.get_texture().get_image().save_png(OUT + "warn_on.png")
	m.cash = 100000
	for i in 3:
		await process_frame
	print("after cash: ", m.route_unaffordable(), " visible ", m.route_warning.visible)
	quit(0)
