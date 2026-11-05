extends Control
## Route start with no money for a ship: a red line from the pending planet to the cursor (or the planet under it)
## and a warning label at the cursor. Shown only while main.route_unaffordable() says so; hidden otherwise.

const StoryText := preload("res://game/story_text.gd")
const Clusters := preload("res://game/clusters.gd")
const LINE_WIDTH := 3.0
const LABEL_OFFSET := Vector2(18, 20)

var main: Node
var _label: Label
var _need := -1
var _have := -1

func setup(m: Node) -> void:
	main = m
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 20
	_label = Label.new()
	_label.theme_type_variation = "LabelSmall"
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_color_override("font_color", Ui.col("signal_bad"))
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_label.add_theme_constant_override("outline_size", 4)
	_label.visible = false
	add_child(_label)
	visible = false

func _process(_delta: float) -> void:
	var w: Dictionary = main.route_unaffordable() if main != null else {}
	if w.is_empty():
		if visible:
			visible = false
			_label.visible = false
		return
	var mouse := get_viewport().get_mouse_position()
	if int(w["need"]) != _need or int(w["have"]) != _have or _label.text == "":
		_need = int(w["need"])
		_have = int(w["have"])
		_label.text = StoryText.get_or("WARN_SHIP_UNAFFORDABLE", "Not enough credits for a ship: need {need}, have {have}", {"need": _need, "have": _have})
	var size_now := get_viewport_rect().size
	var p := mouse + LABEL_OFFSET
	var ls := _label.get_minimum_size()
	p.x = clampf(p.x, 4.0, maxf(4.0, size_now.x - ls.x - 4.0))
	p.y = clampf(p.y, 4.0, maxf(4.0, size_now.y - ls.y - 4.0))
	_label.position = p
	visible = true
	_label.visible = true
	queue_redraw()

func _draw() -> void:
	if main == null or not visible:
		return
	var w: Dictionary = main.route_unaffordable()
	if w.is_empty():
		return
	var map: Node3D = main.map
	var src := int(w["planet"])
	var src_pos := Vector3.ZERO
	if Clusters.is_node(src):  # route from an asteroid pack: its centre on the map
		var found := false
		for cl in main.clusters_in_system(0):
			if int(cl.get("node", 0)) == src:
				src_pos = Vector3(float(cl["x"]), 0.0, float(cl["y"])) * map.MAP_UNIT_SCALE
				found = true
		if not found:
			return
	elif src >= 0 and src < map.positions.size():
		src_pos = map.positions[src]
	else:
		return
	if map == null or map.camera == null or map.camera.is_position_behind(src_pos):
		return
	var a: Vector2 = map.camera.unproject_position(src_pos)
	var b := get_viewport().get_mouse_position()
	var hit: int = map.pick_planet(b)
	if hit >= 0 and hit != src and not map.camera.is_position_behind(map.positions[hit]):
		b = map.camera.unproject_position(map.positions[hit])
	elif hit < 0:
		var sid: int = map.pick_station(b)
		if sid >= 0 and map.stations.has(sid) and not map.camera.is_position_behind(map.stations[sid].position):
			b = map.camera.unproject_position(map.stations[sid].position)
	draw_line(a, b, Ui.col("signal_bad"), LINE_WIDTH, true)
