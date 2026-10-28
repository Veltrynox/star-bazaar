extends PanelContainer
## T33: debug menu. Live editor for every value and target in data/balance.json plus
## map/camera tunables. Toggle with the backtick key. Debug builds only (main.gd creates
## it only when OS.is_debug_build()), so release exports never show it.
##
## Edits are runtime only: balance values are changed in place in main.balance (the same
## Dictionary trade.gd reads), targets in a private copy, map tunables on the map node.
## Nothing here writes data/balance.json and nothing is added to the autosave.
## Values that are only read once at start (starting_credits) change nothing mid-game.

const BALANCE_PATH := "res://data/balance.json"
const TOGGLE_KEY := KEY_QUOTELEFT

## [property on map.gd, label, min, max, step]
const MAP_TUNABLES := [
	["zoom_min", "ZOOM_MIN", 0.05, 10.0, 0.05],
	["zoom_max", "ZOOM_MAX", 0.1, 20.0, 0.05],
	["yaw_min_deg", "Orbit yaw min (deg)", -180.0, 180.0, 1.0],
	["yaw_max_deg", "Orbit yaw max (deg)", -180.0, 180.0, 1.0],
	["pitch_min_deg", "Orbit pitch min (deg)", 1.0, 89.0, 1.0],
	["pitch_max_deg", "Orbit pitch max (deg)", 1.0, 89.0, 1.0],
	["sun_radius", "SUN_RADIUS", 0.1, 10.0, 0.1],
	["planet_scale", "Planet scale", 0.2, 5.0, 0.05],
]

var main: Control        # game/main.gd; owns balance and map
var targets: Dictionary = {}
var tools_box: VBoxContainer  # T34 HOOK: add_tool() puts controls here, always visible at the top
var _body: VBoxContainer      # rebuilt on reset

func setup(main_node: Control) -> void:
	main = main_node
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	offset_left = 12
	offset_right = 372
	offset_top = 56
	offset_bottom = -12
	var outer := VBoxContainer.new()
	add_child(outer)
	var title := Label.new()
	title.text = "Debug menu  (` to close)  - runtime only, not saved"
	outer.add_child(title)
	# T34 HOOK: the time speed button goes in this box via add_tool(button).
	tools_box = VBoxContainer.new()
	outer.add_child(tools_box)
	var reset := Button.new()
	reset.text = "Reset all to balance.json"
	reset.pressed.connect(_reset)
	tools_box.add_child(reset)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	_body = VBoxContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_body)
	targets = _read_file().get("targets", {})
	_build()

## T34 HOOK: add a control (e.g. the speed button) to the top of the menu.
func add_tool(control: Control) -> void:
	tools_box.add_child(control)

## T34: button that cycles the clock speed x1, x2, x4, x8, x12, x1. Runtime only, not saved.
func add_speed_button() -> void:
	const SPEEDS := [1.0, 2.0, 4.0, 8.0, 12.0]
	var b := Button.new()
	b.text = "Time speed: x%d" % int(main.time_speed)
	b.pressed.connect(func():
		var i := SPEEDS.find(main.time_speed)
		main.time_speed = SPEEDS[(i + 1) % SPEEDS.size()]
		b.text = "Time speed: x%d" % int(main.time_speed))
	add_tool(b)

## Button that fast-forwards to the next cycle via main.debug_advance_cycle().
func add_next_cycle_button() -> void:
	var b := Button.new()
	b.text = "Advance to next cycle"
	b.pressed.connect(main.debug_advance_cycle)
	add_tool(b)

## T07: read-only dump of routes (planets, ships, level, net, status) in a label.
func add_routes_dump() -> void:
	var l := Label.new()
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var b := Button.new()
	b.text = "Dump routes"
	b.pressed.connect(func():
		var lines: Array = []
		for r in main.get_routes():
			lines.append("#%d %s > %s %s lvl %d net %d (%s) %s" % [r["id"],
				main.map.planets[r["a"]].get("name", "?"), main.map.planets[r["b"]].get("name", "?"),
				r["c"], r["level"], r["net"], r["status"], r["reason"]])
		l.text = "\n".join(lines) if not lines.is_empty() else "No routes.")
	add_tool(b)
	add_tool(l)

func _read_file() -> Dictionary:
	var f := FileAccess.open(BALANCE_PATH, FileAccess.READ)
	if f == null:
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == TOGGLE_KEY:
		visible = not visible
		if not visible:
			_release_focus()
		get_viewport().set_input_as_handled()

func _release_focus() -> void:
	var f := get_viewport().gui_get_focus_owner()
	if f != null:
		f.release_focus()

func _process(_delta: float) -> void:
	# Typing digits in a field must not pan the camera (map polls WASD/arrows).
	var f := get_viewport().gui_get_focus_owner()
	main.map.keys_enabled = not (visible and f is LineEdit)

func _reset() -> void:
	var file := _read_file()
	for k in file.get("values", {}):
		main.balance[k] = file["values"][k]
	targets = file.get("targets", {})
	_build()

func _build() -> void:
	for c in _body.get_children():
		c.queue_free()
	_section("Balance values")
	_add_dict(main.balance, 0)
	_section("Balance targets")
	_add_dict(targets, 0)
	_section("Map and camera")
	for t in MAP_TUNABLES:
		var prop: String = t[0]
		_add_row(str(t[1]), [_spin(main.map.get(prop), t[2], t[3], t[4], func(v):
			main.map.set(prop, v)
			main.map.apply_tunables())])

func _section(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 18)
	l.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	_body.add_child(l)

func _add_dict(d: Dictionary, depth: int) -> void:
	for key in d.keys():
		var v = d[key]
		match typeof(v):
			TYPE_DICTIONARY:
				var l := Label.new()
				l.text = " ".repeat(depth * 2) + str(key)
				_body.add_child(l)
				_add_dict(v, depth + 1)
			TYPE_ARRAY:
				var spins: Array = []
				for i in v.size():
					spins.append(_container_spin(v, i))
				_add_row(" ".repeat(depth * 2) + str(key), spins)
			_:
				_add_row(" ".repeat(depth * 2) + str(key), [_container_spin(d, key)])

## SpinBox bound to container[key]. JSON numbers load as floats, so a whole number
## gets step 1 (and is stored whole); fractional values get step 0.01.
func _container_spin(container, key) -> SpinBox:
	var cur = container[key]
	var whole: bool = float(cur) == round(float(cur))
	return _spin(float(cur), -1000000.0, 1000000.0, 1.0 if whole else 0.01, func(v):
		container[key] = (int(round(v)) if typeof(cur) == TYPE_INT else v))

func _spin(value: float, lo: float, hi: float, step: float, on_change: Callable) -> SpinBox:
	var s := SpinBox.new()
	s.min_value = lo
	s.max_value = hi
	s.step = step
	s.allow_greater = true
	s.allow_lesser = true
	s.value = value
	s.custom_minimum_size = Vector2(90, 0)
	s.value_changed.connect(on_change)
	return s

func _add_row(label: String, controls: Array) -> void:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = label
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.clip_text = true
	row.add_child(l)
	for c in controls:
		row.add_child(c)
	_body.add_child(row)
