extends SceneTree
## QA: company screen with a CEO picked, then the ship screen (EN and RU). Shots in qa/reports/:
## ceo_info_<lang>.png, ship_setup_<lang>_empty.png, ship_setup_<lang>_<id>.png.
const OUT := "res://qa/reports/"

func _shot(name: String) -> void:
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name))

func _wait(n: int = 20) -> void:
	for i in n:
		await process_frame

func _initialize() -> void:
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	for lang in ["en", "ru"]:
		var L = root.get_node_or_null("Lang")
		if L != null:
			L.set_language(lang)
		var c: Control = load("res://game/company_setup.tscn").instantiate()
		root.add_child(c)
		await _wait()
		c.select("ceo_man_01")
		await _wait(5)
		_shot("ceo_info_%s.png" % lang)
		c.commit()
		c.queue_free()
		await _wait(3)
		var s: Control = load("res://game/ship_setup.tscn").instantiate()
		root.add_child(s)
		await _wait()
		_shot("ship_setup_%s_empty.png" % lang)
		for id in ["small", "bulk", "dart", "fleet"]:
			s.select(id)
			await _wait(30)
			_shot("ship_setup_%s_%s.png" % [lang, id])
		print(lang, " start disabled at open: checked in shot; model ", s.selected_model())
		s.queue_free()
		await _wait(3)
	var L2 = root.get_node_or_null("Lang")
	if L2 != null:
		L2.set_language("en")  # set_language saves to settings.cfg; leave it on the default
	quit()
