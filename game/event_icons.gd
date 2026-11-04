extends HBoxContainer
## Event icon strip: every event first shows as a small square icon, top centre under the system label.
## Minor (price change) icons fade out after `life` seconds of real time and are gone; important icons stay until clicked.
## No text on the icon; the tooltip is the event title. Clicking emits `clicked(id)`.

signal clicked(id: String)

const SIZE := 34.0
const FADE := 2.0  # seconds of fade at the end of a minor icon's life

## Entries, oldest first: {id, minor, left, planet, node}
var entries: Array = []

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", 6)
	alignment = BoxContainer.ALIGNMENT_CENTER

func add_icon(id: String, minor: bool, title: String, life: float, planet: int = -1) -> void:
	if has_id(id):
		return
	var node := Icon.new()
	node.minor = minor
	node.tooltip_text = title
	node.pressed.connect(func(): clicked.emit(id))
	add_child(node)
	entries.append({"id": id, "minor": minor, "left": life, "planet": planet, "node": node})

func has_id(id: String) -> bool:
	for e in entries:
		if str(e["id"]) == id:
			return true
	return false

func entry(id: String) -> Dictionary:
	for e in entries:
		if str(e["id"]) == id:
			return e
	return {}

func remove_icon(id: String) -> void:
	for i in entries.size():
		if str(entries[i]["id"]) == id:
			var n: Control = entries[i]["node"]
			entries.remove_at(i)
			if is_instance_valid(n):
				remove_child(n)
				n.queue_free()
			return

## Real-time tick: minor icons count down, fade and go; important ones never expire.
func tick(delta: float) -> void:
	for e in entries.duplicate():
		if not bool(e["minor"]):
			continue
		e["left"] = float(e["left"]) - delta
		var n: Control = e["node"]
		if float(e["left"]) <= 0.0:
			remove_icon(str(e["id"]))
		elif is_instance_valid(n):
			n.modulate.a = clampf(float(e["left"]) / FADE, 0.0, 1.0)

func count() -> int:
	return entries.size()

## One drawn square: quiet dark glass, thin glyph. Minor: a short trend line. Important: a warm frame with a bar and a dot.
class Icon extends Control:
	signal pressed
	var minor := true
	var _hover := false

	func _init() -> void:
		custom_minimum_size = Vector2(SIZE, SIZE)
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_entered.connect(func():
			_hover = true
			queue_redraw())
		mouse_exited.connect(func():
			_hover = false
			queue_redraw())

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit()
			accept_event()

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		var accent: Color = Ui.col("ink_muted") if minor else Ui.col("star_warm")
		var bg: Color = Ui.col("panel_300")
		bg.a = 0.85 if not _hover else 1.0
		var sb := StyleBoxFlat.new()
		sb.bg_color = bg
		sb.set_corner_radius_all(6)
		sb.set_border_width_all(1)
		sb.border_color = accent
		draw_style_box(sb, r)
		var c := size * 0.5
		if minor:
			var pts := PackedVector2Array([c + Vector2(-9, 4), c + Vector2(-3, -2), c + Vector2(2, 2), c + Vector2(9, -6)])
			draw_polyline(pts, accent, 1.5, true)
		else:
			draw_line(c + Vector2(0, -9), c + Vector2(0, 3), accent, 2.0, true)
			draw_circle(c + Vector2(0, 9), 1.8, accent)
