extends Control
## Next solar system, drawn over the system map as in the design pack (screens/SystemView.html, "locked exit"):
## a lock icon with the system's name and how it opens, and a thin dotted line that fades out toward the current
## system. The marker sits where the next system lies in the world; when that is off screen, the marker and the line
## are both hidden (nothing is pinned to the edge). An open system shows an amber arrow and a click moves the player
## there; a locked one shows the grey lock and a click only says why it is locked. Clicks are read in _input.

const StoryText := preload("res://game/story_text.gd")
const Systems := preload("res://game/systems.gd")
const MAP_UNIT_SCALE := 0.02  # same as map.gd
const AREA_LEFT := 430.0  # clear of the planet panel and the rail
const AREA_RIGHT := 520.0  # clear of the board (the label runs right of the marker)
const AREA_TOP := 110.0
const AREA_BOTTOM := 150.0  # clear of the legend and key hints
const EDGE_MARGIN := 24.0  # the lock icon must fit inside the view
const LINE_LEN := 190.0
const LINE_ALPHA := 0.3
const DOT_STEP := 5.0

var main: Control
var target_sid: int = -1
const HIT_RADIUS := 26.0

func setup(main_node: Control) -> void:
	main = main_node
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

## System 1 (planets.json, always open) and every system of systems.json.
func all_ids() -> Array:
	return [1] + Systems.ids()

## First system that is not open yet (-1 when every system is open).
func next_locked() -> int:
	for sid in Systems.ids():
		if not main.open_systems.has(int(sid)):
			return int(sid)
	return -1

## Middle of a system on the ground plane: live planets when it is open, else its data (x, y in map units).
func _center(sid: int) -> Variant:
	var pts: Array = []
	for i in main.map.planets.size():
		if int(main.map.planets[i].get("system", 1)) == sid and i < main.map.positions.size():
			pts.append(main.map.positions[i])
	if pts.is_empty():
		for p in Systems.get_system(sid).get("planets", []):
			if p.has("x") and p.has("y"):
				pts.append(Vector3(float(p["x"]), 0.0, float(p["y"])) * MAP_UNIT_SCALE)
	if pts.is_empty():
		return null
	var lo: Vector3 = pts[0]
	var hi: Vector3 = pts[0]
	for p in pts:
		lo = Vector3(minf(lo.x, p.x), 0.0, minf(lo.z, p.z))
		hi = Vector3(maxf(hi.x, p.x), 0.0, maxf(hi.z, p.z))
	return (lo + hi) * 0.5

func _screen(world: Vector3) -> Vector2:
	return main.map.camera.unproject_position(world)

## Every other system as {sid, marker, from, locked} in screen pixels; those off screen are left out.
func markers() -> Array:
	var out := []
	if main == null or main.map == null or main.map.camera == null:
		return out
	var c_from = _center(int(main.view_system))
	if c_from == null:
		return out
	var rect := Rect2(Vector2(AREA_LEFT, AREA_TOP), get_viewport_rect().size - Vector2(AREA_LEFT + AREA_RIGHT, AREA_TOP + AREA_BOTTOM))
	if rect.size.x < 50.0 or rect.size.y < 50.0:
		return out
	var a: Vector2 = _screen(c_from).clamp(rect.position, rect.end)
	for sid in all_ids():
		if int(sid) == int(main.view_system):
			continue
		var c_to = _center(int(sid))
		if c_to == null:
			continue
		var b: Vector2 = _screen(c_to)
		if not on_screen(b, main.map.camera.is_position_behind(c_to), get_viewport_rect().size):
			continue
		out.append({"sid": int(sid), "marker": b, "from": a, "locked": not main.open_systems.has(int(sid))})
	return out

## The first marker as {sid, marker, from, locked}, or {} when nothing is shown.
func layout() -> Dictionary:
	var m := markers()
	return {} if m.is_empty() else m[0]

## Marker of system `sid` under a screen point, or -1.
func hit_test(point: Vector2) -> int:
	for m in markers():
		if (m["marker"] as Vector2).distance_to(point) <= HIT_RADIUS:
			return int(m["sid"])
	return -1

func _input(event: InputEvent) -> void:
	if not visible or not (event is InputEventMouseButton) or not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
		return
	var sid := hit_test(event.position)
	if sid < 0:
		return
	get_viewport().set_input_as_handled()  # the map must not read this click as an empty-space click
	main.enter_system_from_view(sid)

## True when the target's screen point is inside the camera view (and in front of the camera).
## Off screen means no marker and no line at all: nothing is pinned to the edge.
static func on_screen(point: Vector2, behind: bool, view: Vector2) -> bool:
	return not behind and Rect2(Vector2(EDGE_MARGIN, EDGE_MARGIN), view - Vector2(EDGE_MARGIN, EDGE_MARGIN) * 2.0).has_point(point)

func _process(_delta: float) -> void:
	var on: bool = main != null and main.map != null and main.map.visible and Systems.ids().size() > 0
	if on != visible:
		visible = on
	if visible:
		queue_redraw()

func _draw() -> void:
	for info in markers():
		_draw_marker(info)

func _draw_marker(info: Dictionary) -> void:
	var sid := int(info["sid"])
	var locked: bool = info["locked"]
	target_sid = sid
	var m: Vector2 = info["marker"]
	var from: Vector2 = info["from"]
	var dir := (from - m)
	var span := minf(dir.length(), LINE_LEN)
	if span > 1.0:
		dir = dir.normalized()
		var warm := Ui.col("ink") if locked else Ui.col("star_warm")
		var d := 14.0  # start just clear of the icon
		while d < span:
			var col := Color(warm.r, warm.g, warm.b, LINE_ALPHA * (1.0 - d / span))
			draw_line(m + dir * d, m + dir * (d + 2.0), col, 1.0, true)
			d += DOT_STEP
	var tint := Ui.col("ink_subtle") if locked else Ui.col("star_warm")
	if locked:
		var icon := Ui.icon("lock")
		if icon != null:
			draw_texture_rect(icon, Rect2(m - Vector2(8, 8), Vector2(16, 16)), false, tint)
	else:
		_draw_arrow(m, (m - info["from"]).normalized() if (m - info["from"]).length() > 1.0 else Vector2.RIGHT, tint)
	var font := get_theme_default_font()
	var how := StoryText.get_or("LBL_SYSTEM_N", "System {n} · {how}", {"n": sid,
		"how": StoryText.get_or("LBL_LOCKED_HOW", "permit or skill") if locked else StoryText.get_or("LBL_OPEN_HOW", "click to travel")})
	draw_string(font, m + Vector2(18, -1), Systems.name_of(sid), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, tint)
	draw_string(font, m + Vector2(18, 14), how, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, tint)

## Filled arrowhead pointing along `dir` (away from the current system).
func _draw_arrow(at: Vector2, dir: Vector2, col: Color) -> void:
	var side := Vector2(-dir.y, dir.x)
	draw_colored_polygon(PackedVector2Array([at + dir * 10.0, at - dir * 7.0 + side * 8.0, at - dir * 3.0, at - dir * 7.0 - side * 8.0]), col)
