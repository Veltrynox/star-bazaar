extends SceneTree
## QA: income popups of system 1 must not float over system 2. Shows a popup in system 1, then in system 2 after switching.
const OUT := "res://qa/reports/"

func _snap(name: String) -> void:
	for i in 8:
		await process_frame
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name))

func _initialize() -> void:
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	m.tut_step = m.TUT_GUIDE.size()
	m.open_systems.append(2)
	await process_frame
	m.income_popup.show_gains({0: 120, 1: 80})
	await create_timer(0.8).timeout
	await _snap("popups_system1_view_system1.png")
	m.go_to_system(2)
	m.income_popup.show_gains({0: 120, 1: 80})  # a system 1 settle while viewing system 2: skipped
	await create_timer(0.3).timeout
	print("popups items in system 2: ", m.income_popup.items.size())
	await _snap("popups_system1_view_system2.png")
	quit(0)
