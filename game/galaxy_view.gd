extends Control
## T105: galaxy overview (2D overlay). Opens only after system 2 is open. Shows explored systems, links,
## resource icons by each planet and the player's routes. Click a system to focus the map on it.
## Layout: systems in a row by id (no galaxy coordinates in data); links join consecutive ids.

const StoryText := preload("res://game/story_text.gd")
const Systems := preload("res://game/systems.gd")
const ICON_PATH := "res://art/textures/icons/icon_%s_64.png"
const TUT_IDS := ["TUT_GALAXY_INTRO", "TUT_GALAXY_ICONS", "TUT_GALAXY_ROUTES"]

signal system_chosen(id: int)
signal closed

var main: Control
var tut_label: Label
var close_button: Button
var icons: Dictionary = {}
var _hit: Array = []  # [{id, pos, r}]
var _hover_id: int = -1
func setup(main_node: Control) -> void:
	main = main_node
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for c in ["energy", "food"]:
		if ResourceLoader.exists(ICON_PATH % c):
			icons[c] = load(ICON_PATH % c)
	tut_label = Label.new()
	tut_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tut_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	tut_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	tut_label.offset_top = -90
	tut_label.offset_left = 24
	tut_label.offset_right = -24
	tut_label.offset_bottom = -12
	add_child(tut_label)
	close_button = Button.new()
	close_button.text = StoryText.get_or("BTN_CLOSE", "Close")
	close_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	close_button.offset_left = -110
	close_button.offset_right = -16
	close_button.offset_top = 56
	close_button.pressed.connect(close_view)
	add_child(close_button)

## True once system 2 (any system past the first) is open.
func available() -> bool:
	return main.open_systems.size() > 1

func open_view() -> bool:
	if visible or not available():
		return false
	visible = true
	if not main.galaxy_seen:
		main.galaxy_seen = true
		var parts: Array = []
		for id in TUT_IDS:
			parts.append(StoryText.get_or(id, "", {}))
		tut_label.text = "\n".join(parts).strip_edges()
		main.save_now()
	else:
		tut_label.text = ""
	queue_redraw()
	return true

func close_view() -> void:
	if not visible:
		return
	visible = false
	closed.emit()

func toggle_view() -> void:
	if visible:
		close_view()
	else:
		open_view()

func refresh() -> void:
	if visible:
		queue_redraw()

func _sys_ids() -> Array:
	var out: Array = [1]
	out.append_array(Systems.ids())
	return out

## Screen position of the centre of the system cell number `k` of `n`.
func _cell_center(k: int, n: int) -> Vector2:
	var w := size.x
	return Vector2(w * (float(k) + 0.5) / float(maxi(n, 1)), size.y * 0.5)

func _planet_points() -> Dictionary:
	## planet index -> screen position, for open systems.
	var out := {}
	var ids := _sys_ids()
	var scale := minf(size.x / float(maxi(ids.size(), 1)), size.y) * 0.3
	for k in ids.size():
		var sid: int = ids[k]
		if not main.open_systems.has(sid):
			continue
		var idx: Array = []
		var lo := Vector2(INF, INF)
		var hi := Vector2(-INF, -INF)
		for i in main.map.planets.size():
			var p: Dictionary = main.map.planets[i]
			if int(p.get("system", 1)) != sid:
				continue
			idx.append(i)
			var v := Vector2(float(p.get("x", 0)), float(p.get("y", 0)))
			lo = Vector2(minf(lo.x, v.x), minf(lo.y, v.y))
			hi = Vector2(maxf(hi.x, v.x), maxf(hi.y, v.y))
		if idx.is_empty():
			continue
		var mid := (lo + hi) * 0.5
		var ext := maxf(maxf(hi.x - lo.x, hi.y - lo.y), 1.0)
		var c := _cell_center(k, ids.size())
		for i in idx:
			var p2: Dictionary = main.map.planets[i]
			var v2 := Vector2(float(p2.get("x", 0)), float(p2.get("y", 0)))
			out[i] = c + (v2 - mid) / ext * scale
	return out

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.03, 0.07, 0.94))
	_hit = []
	var font := get_theme_default_font()
	var ids := _sys_ids()
	var pts := _planet_points()
	var scale := minf(size.x / float(maxi(ids.size(), 1)), size.y) * 0.3
	# links between consecutive systems, drawn only between explored ones
	for k in ids.size() - 1:
		var a: int = ids[k]
		var b: int = ids[k + 1]
		var known: bool = main.open_systems.has(a) and main.open_systems.has(b)
		draw_line(_cell_center(k, ids.size()), _cell_center(k + 1, ids.size()),
			Color(0.35, 0.5, 0.7, 0.8) if known else Color(0.3, 0.3, 0.35, 0.3), 2.0)
	for k in ids.size():
		var sid: int = ids[k]
		var c := _cell_center(k, ids.size())
		var open: bool = main.open_systems.has(sid)
		var r := scale * 0.75
		draw_arc(c, r, 0.0, TAU, 48, Color(0.5, 0.7, 1.0, 0.5) if open else Color(0.4, 0.4, 0.45, 0.4), 2.0)
		if open and sid == _hover_id:  # the shared clickable cue: a warm outline
			draw_arc(c, r + 4.0, 0.0, TAU, 48, Ui.col("star_warm"), 3.0, true)
		var label := Systems.name_of(sid) if open else StoryText.get_or("LBL_UNKNOWN", "?")
		draw_string(font, c + Vector2(-r, -r - 10), label, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, 20,
			Color(0.9, 0.95, 1.0) if open else Color(0.6, 0.6, 0.65))
		if open:
			_hit.append({"id": sid, "pos": c, "r": r})
			_draw_count(c + Vector2(0, r + 8.0), sid)
	# player routes
	for rec in main.get_routes():
		if not pts.has(rec["a"]) or not pts.has(rec["b"]):
			continue
		var col := Color(0.4, 0.9, 0.5) if rec.get("status", "") == "running" else Color(0.9, 0.7, 0.3)
		draw_line(pts[rec["a"]], pts[rec["b"]], col, 3.0)
	# planets and resource icons
	for i in pts:
		var pos: Vector2 = pts[i]
		var p: Dictionary = main.map.planets[i]
		draw_circle(pos, 6.0, Color(0.85, 0.9, 1.0))
		var res: Array = []
		if str(p.get("abundant", "")) in ["energy", "food"]:
			res.append(str(p["abundant"]))
		var x := 10.0
		for c in res:
			if icons.has(c):
				draw_texture_rect(icons[c], Rect2(pos + Vector2(x, -10), Vector2(20, 20)), false)
				x += 22.0

## Small planet icon and planet count centred under a system node.
func _draw_count(at: Vector2, sid: int) -> void:
	var n := 0
	for p in main.map.planets:
		if int(p.get("system", 1)) == sid:
			n += 1
	var ic: Texture2D = Ui.icon("planet")
	var font := Ui.mono_font()
	var txt := str(n)
	var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	var x := at.x - (18.0 + 6.0 + w) * 0.5
	if ic != null:
		draw_texture_rect(ic, Rect2(Vector2(x, at.y), Vector2(18, 18)), false, Ui.col("ink_muted"))
	draw_string(font, Vector2(x + 24.0, at.y + 14.0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Ui.col("ink"))

func _hit_at(pos: Vector2) -> int:
	for h in _hit:
		if pos.distance_to(h["pos"]) <= float(h["r"]):
			return int(h["id"])
	return -1

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var hid := _hit_at(event.position)
		if hid != _hover_id:
			_hover_id = hid
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if hid >= 0 else Control.CURSOR_ARROW
			queue_redraw()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for h in _hit:
			if event.position.distance_to(h["pos"]) <= float(h["r"]):
				system_chosen.emit(int(h["id"]))
				accept_event()
				return
