extends SceneTree
## QA: hover tooltip of a resource button (description, facts, then the existing lines), at the start and after Munitions Line.
const OUT := "res://qa/reports/"

func _shot(m: Control, good: String, file: String) -> void:
	var bt := m.planet_panel.find_child("BuyButton_" + good, true, false) as Button
	if bt == null:
		print("no button for ", good)
		return
	var p := bt.get_global_rect().get_center()
	var ev := InputEventMouseMotion.new()
	ev.position = p
	ev.global_position = p
	root.push_input(ev)
	for i in 90:
		await process_frame
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + file))
	print("saved ", file, " tooltip text:\n", bt.tooltip_text)

func _initialize() -> void:
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	await process_frame
	m._on_planet_clicked(0)
	for i in 40:
		await process_frame
	await _shot(m, "energy", "good_info_start_energy.png")
	Skills.add_learned("MIL_1")
	m.workshops.built["munitions"] = true
	m._sync_skill_effects()
	m._on_planet_clicked(0)
	for i in 40:
		await process_frame
	await _shot(m, "cells", "good_info_later_cells.png")
	quit(0)
