extends SceneTree
## QA: company screen with a CEO picked, then the ship screen (EN and RU). Shots in qa/reports/:
## ceo_info_<lang>.png, ship_setup_<lang>_empty.png, ship_setup_<lang>_<id>.png.
const OUT := "res://qa/reports/"

func _shot(name: String) -> void:
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name))

func _wait(n: int = 20) -> void:
	for i in n:
		await process_frame

const HARD_TIMEOUT_SEC := 90.0

func _initialize() -> void:
	# Safeguard: whatever hangs below, the process ends by itself.
	create_timer(HARD_TIMEOUT_SEC).timeout.connect(func():
		push_error("ship_setup_shot: hard timeout, quitting")
		quit(1))
	_run()

func _drag_test(s: Control) -> void:
	var before: float = s.pivot.rotation.y
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	s._on_preview_input(down)
	var mv := InputEventMouseMotion.new()
	mv.relative = Vector2(100, 0)
	s._on_preview_input(mv)
	var after: float = s.pivot.rotation.y
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	s._on_preview_input(up)
	print("drag test: yaw ", before, " -> ", after, " delta ", after - before, " (expected ", 100.0 * s.DRAG_RAD_PER_PX, ")")

## Fraction of the preview box (width, height) covered by non-background pixels, over yaw steps; prints the max.
func _fill_test(s: Control, id: String) -> void:
	var rect: Rect2 = s.viewport.get_parent().get_global_rect()
	var mx := Vector2.ZERO
	for k in 8:
		s.pivot.rotation.y = k * PI / 8.0
		await _wait(3)
		var img: Image = root.get_texture().get_image()
		var x0 := 99999; var x1 := -1; var y0 := 99999; var y1 := -1
		var bg := img.get_pixel(int(rect.position.x) + 4, int(rect.position.y) + 4)
		for y in range(int(rect.position.y) + 3, int(rect.end.y) - 3, 2):
			for x in range(int(rect.position.x) + 3, int(rect.end.x) - 3, 2):
				var c := img.get_pixel(x, y)
				if absf(c.r - bg.r) + absf(c.g - bg.g) + absf(c.b - bg.b) > 0.06:
					x0 = mini(x0, x); x1 = maxi(x1, x); y0 = mini(y0, y); y1 = maxi(y1, y)
		if x1 >= 0:
			mx = Vector2(maxf(mx.x, (x1 - x0) / rect.size.x), maxf(mx.y, (y1 - y0) / rect.size.y))
			if x0 <= rect.position.x + 6 or x1 >= rect.end.x - 6 or y0 <= rect.position.y + 6 or y1 >= rect.end.y - 6:
				print("CLIPPED ", id, " yaw step ", k)
	print("fill ", id, " max width frac ", snapped(mx.x, 0.01), " max height frac ", snapped(mx.y, 0.01))

func _run() -> void:
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
		if lang == "en":
			s.select("small")
			await _wait(5)
			_drag_test(s)
		for id in ["small", "bulk", "dart", "fleet"]:
			s.select(id)
			await _wait(30)
			_shot("ship_setup_%s_%s.png" % [lang, id])
			if lang == "en":
				await _fill_test(s, id)
		print(lang, " start disabled at open: checked in shot; model ", s.selected_model())
		s.queue_free()
		await _wait(3)
	var L2 = root.get_node_or_null("Lang")
	if L2 != null:
		L2.set_language("en")  # set_language saves to settings.cfg; leave it on the default
	quit()
