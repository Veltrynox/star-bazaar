extends SceneTree
## QA: lane net labels on the map (a selling lane and a Space Storage lane) and the cash forecast popup with the no-earn flag.
## Shots in qa/reports/: lane_net_map.png, lane_net_forecast.png.
const OUT := "res://qa/reports/"

func _shot(name: String) -> void:
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name))

func _initialize() -> void:
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	await process_frame
	m.tut_step = -1
	m.cash = 100000
	m.ships = 4
	m.learned_skills.append("FND_STORAGE")
	m.storage.ensure("system:1")
	m._ensure_stations()
	await process_frame
	var c := "energy"
	m.set_local_order(1, c, "sell", true)
	m.set_local_order(0, c, "buy", true)
	print("sell lane: ", m.send_stock(0, 1, c))
	print("storage lane: ", m.send_stock(0, m.station_dst(1), c))
	for rec in m.engine.routes:
		rec["fresh"] = 1.0
	m.storage.add("planet:0", c, 200)
	m._after_change()
	for i in 10:
		await process_frame
	for r in m.map.route_lines.keys():
		print("lane ", r, ": ", m.map.route_lines[r].tag.text)
	_shot("lane_net_map.png")
	m.cash_forecast.position = Vector2(300, 60)
	m.cash_forecast.visible = true
	m.cash_forecast.refresh()
	for i in 5:
		await process_frame
	for ch in m.cash_forecast.box.get_children():
		if ch is Label:
			print("fc: ", ch.text)
	_shot("lane_net_forecast.png")
	quit(0)
