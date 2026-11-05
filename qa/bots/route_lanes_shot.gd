extends SceneTree
## QA T163: two routes on the same pair (A-B and B-A) and a second good A-B drawn side by side. Shot: qa/reports/route_lanes.png. Quits itself after 60 s at most.
func _initialize() -> void:
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	create_timer(60.0).timeout.connect(quit)
	await process_frame
	m._dismiss_preface()
	await process_frame
	m.tut_step = -1
	m.cash = 100000
	m.ships = 6
	for c in ["energy", "ore"]:
		print("send ", c, " 0-1: ", m.send_stock(0, 1, c))
	print("send back 1-0: ", m.send_stock(1, 0, "energy"))
	m._after_change()
	for i in 20:
		await process_frame
	for r in m.map.route_lines.keys():
		print("lane ", r, ": ", m.map.route_lines[r].lane_slot, " ", m.map.route_lines[r].tag.text)
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://qa/reports/route_lanes.png"))
	quit()
