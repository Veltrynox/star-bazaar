extends SceneTree
## QA screenshot: Competitors menu after some cycles with player sales. Windowed: qa/run_game.sh res://qa/gui/competitors_shot.gd -- <out_dir>

func _frames(n: int) -> void:
	for i in n:
		await process_frame
		await RenderingServer.frame_post_draw

func _run() -> void:
	var out := "user://"
	for a in OS.get_cmdline_user_args():
		out = a
	DirAccess.make_dir_recursive_absolute(out)
	var main: Control = load("res://game/main.tscn").instantiate()
	root.add_child(main)
	await _frames(3)
	main._dismiss_preface()
	main.set_paused(false)
	for i in 14:
		Markets.add_sale("food", 4 + i % 5)
		main.debug_advance_cycle()
		await _frames(1)
		if main.event_notice != null:
			main.event_notice.confirmed.emit(0)
			await _frames(2)
	while main.event_notice != null:
		main.event_notice.queue_free()
		main.event_notice = null
		await _frames(5)
	for n in main.get_children():
		var sc = n.get_script()
		if sc != null and str(sc.resource_path).ends_with("event_notice.gd"):
			n.queue_free()
	main.event_notice = null
	await _frames(3)
	main.open_competitors()
	await _frames(3)
	root.get_texture().get_image().save_png(out.path_join("competitors.png"))
	main.competitors_panel.select_market(Markets.ids[Markets.ids.size() - 1])
	await _frames(3)
	root.get_texture().get_image().save_png(out.path_join("competitors2.png"))
	quit(0)

func _initialize() -> void:
	call_deferred("_run")
