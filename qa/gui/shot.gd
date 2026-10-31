extends SceneTree
## QA screenshot harness (not gameplay). Runs the real windowed game, saves PNGs of the main menu and of the
## main game after the preface and a few cycles, then quits.
## Run (not headless, needs a display):
##   HOME=<scratch> Godot --path . -s res://qa/gui/shot.gd -- <out_dir>

func _initialize() -> void:
	call_deferred("_run")

func _frames(n: int) -> void:
	for i in n:
		await process_frame
		await RenderingServer.frame_post_draw

func _save(path: String) -> void:
	await _frames(2)
	var img := root.get_texture().get_image()
	img.save_png(path)
	print("SHOT ", path, " ", img.get_width(), "x", img.get_height())

func _run() -> void:
	var out := "user://"
	for a in OS.get_cmdline_user_args():
		out = a
	DirAccess.make_dir_recursive_absolute(out)
	var menu: Node = load("res://game/main_menu.tscn").instantiate()
	root.add_child(menu)
	await _save(out.path_join("01_menu.png"))
	root.remove_child(menu)
	menu.queue_free()
	var main: Control = load("res://game/main.tscn").instantiate()
	root.add_child(main)
	await _frames(3)
	main._dismiss_preface()
	main.set_paused(false)
	for i in 6:
		main.debug_advance_cycle()
		await _frames(1)
	main.set_paused(true)
	await _save(out.path_join("02_game.png"))
	main.open_skills()
	await _frames(2)
	await _save(out.path_join("03_game_skills.png"))
	quit(0)
