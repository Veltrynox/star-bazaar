extends SceneTree
## QA (T175): the dead-world planet panel as a mining panel, minable state; hard self-quit after 60 s.
const OUT := "res://qa/reports/"

func _snap(name: String) -> void:
	for i in 5:
		await process_frame
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name))

func _initialize() -> void:
	create_timer(60.0).timeout.connect(func(): quit(1))
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	m.tut_step = m.TUT_GUIDE.size()
	await process_frame
	var d1 := -1
	for i in m.map.planets.size():
		if str(m.map.planets[i].get("id", "")) == "dead_1":
			d1 = i
	m.cycle = int(m.balance["dead_unlock_cycle"])
	m._sync_dead_lock()
	Skills.add_learned("MIN_3")
	m.learned_skills.append("MIN_3")
	m._on_planet_clicked(d1)
	await _snap("mine_panel_1.png")
	quit(0)
