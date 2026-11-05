extends SceneTree
## QA: skill screen with placeholder slots. Shots in qa/reports/: skill_screen_1080_top.png, _1080_bottom.png, _720_top.png.
const OUT := "res://qa/reports/"

func _shot(name: String) -> void:
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name))

func _initialize() -> void:
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	await process_frame
	m._tut_skip()
	m.skill_points = 5
	var s = m.skill_screen
	for size in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		DisplayServer.window_set_size(size)
		for i in 10:
			await process_frame
		s.open_screen()
		for i in 10:
			await process_frame
		print(size, " tree min ", s._tree.get_combined_minimum_size(), " scroll ", s.tree_scroll.size, " placeholders ", s.placeholders.size(), " win ", root.size)
		var tag := str(size.y)
		_shot("skill_screen_%s_top.png" % tag)
		var sb: ScrollBar = s.tree_scroll.get_v_scroll_bar()
		s.tree_scroll.scroll_vertical = int(sb.max_value)
		for i in 5:
			await process_frame
		_shot("skill_screen_%s_bottom.png" % tag)
		s.tree_scroll.scroll_vertical = 0
		s.close_screen()
	quit()
