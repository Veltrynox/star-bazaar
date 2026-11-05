extends SceneTree
## QA: Cinderrest panel in three states (locked, needs skill, minable) plus the pending Mine send.
const OUT := "res://qa/reports/"

func _snap(name: String) -> void:
	for i in 5:
		await process_frame
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name))

func _initialize() -> void:
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
	m.cycle = 1
	m._sync_dead_lock()
	m._on_planet_clicked(d1)
	await _snap("dead_world_1_locked.png")
	m.cycle = int(m.balance["dead_unlock_cycle"])
	m._sync_dead_lock()
	m.planet_panel.rebuild()
	await _snap("dead_world_2_needs_skill.png")
	Skills.add_learned("MIN_3")
	m.learned_skills.append("MIN_3")
	m.planet_panel.rebuild()
	await _snap("dead_world_3_minable.png")
	m.planet_panel.mine_requested.emit("dross")
	m.cash = 10
	m.ships = 0
	m._pending_changed()
	m.planet_panel.rebuild()
	await _snap("dead_world_4_pending_unaffordable.png")
	quit(0)
