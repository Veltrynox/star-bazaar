extends SceneTree
## QA screenshot: the skill screen with a few learned nodes, one tech partly crafted, a bot skill ready.
## Windowed: qa/run_game.sh res://qa/gui/skills_shot.gd -- <out_dir>

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
	main._tut_skip()
	main.skill_points = 3
	for id in ["FND_PERMIT", "MIL_1", "MIL_3", "MIL_5", "LUX_1", "BIO_1"]:
		Skills.add_learned(id)
	Tech.add_crafted("mil", 4)
	main.open_skills()
	main.skill_screen.select("MIL_2")
	await _frames(4)
	root.get_texture().get_image().save_png(out.path_join("skills.png"))
	main.skill_screen.select("LUX_3")
	await _frames(3)
	root.get_texture().get_image().save_png(out.path_join("skills2.png"))
	quit(0)

func _initialize() -> void:
	call_deferred("_run")
