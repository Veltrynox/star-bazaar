extends SceneTree
## QA: destination hover card while a route is pending. Shots in qa/reports/: dest_hint_valid.png (planet that buys),
## dest_hint_dead.png (dead world), dest_hint_stacked.png (with the red ship warning), dest_hint_none.png (nothing pending).
const OUT := "res://qa/reports/"

func _shot(name: String) -> void:
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name))

func _hover(m: Control, i: int) -> void:
	var p: Vector2 = m.map.camera.unproject_position(m.map.positions[i])
	m.get_viewport().warp_mouse(p)
	Input.parse_input_event(_motion(p))

func _motion(p: Vector2) -> InputEventMouseMotion:
	var e := InputEventMouseMotion.new()
	e.position = p
	e.global_position = p
	return e

## First planet (not `skip`) whose screen spot is not covered by a panel.
func _free_planet(m: Control, skip: Array) -> int:
	for i in m.map.planets.size():
		if skip.has(i):
			continue
		_hover(m, i)
		await process_frame
		var h = m.get_viewport().gui_get_hovered_control()
		if (h == null or h == m) and m.map.pick_planet(m.get_viewport().get_mouse_position()) == i:
			return i
	return -1

func _initialize() -> void:
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	await process_frame
	m.tut_step = -1  # no tutorial lock
	m.cash = 6000
	m.ships = 2
	var d1 := -1
	for i in m.map.planets.size():
		if str(m.map.planets[i].get("id", "")) == "dead_1":
			d1 = i
	var v := await _free_planet(m, [0, d1])
	print("free planet ", v)
	m.pending = {"planet": 0, "c": "energy"}
	m._pending_changed()
	_hover(m, v)
	for i in 5:
		await process_frame
	print("hov: ", m.get_viewport().gui_get_hovered_control(), " mouse ", m.get_viewport().get_mouse_position(), " hit ", m.map.pick_planet(m.get_viewport().get_mouse_position()))
	print("valid: ", m.dest_hint.visible, " ", m.dest_hint._label.text)
	_shot("dest_hint_valid.png")
	_hover(m, d1)
	for i in 5:
		await process_frame
	print("dead: ", m.dest_hint.visible, " ", m.dest_hint._label.text)
	_shot("dest_hint_dead.png")
	m.ships = 0
	m.cash = 10
	_hover(m, v)
	for i in 5:
		await process_frame
	print("stacked: ", m.dest_hint.visible, " ", m.dest_hint._label.text, " warn ", m.route_warning.visible)
	_shot("dest_hint_stacked.png")
	m.cancel_pending()
	for i in 5:
		await process_frame
	print("none: ", m.dest_hint.visible)
	_shot("dest_hint_none.png")
	quit(0)
