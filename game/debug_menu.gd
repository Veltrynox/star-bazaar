extends PanelContainer
## T33: debug menu. Live editor for every value and target in data/balance.json plus
## map/camera tunables. Toggle with the backtick key. Debug builds only (main.gd creates
## it only when OS.is_debug_build()), so release exports never show it.
##
## T13 QA section (add_qa_tools): events, debris, permits, A1 gate, ships, cash and points, notices,
## tutorial, galaxy view, save. Every balance key stays editable below (ship_cap, saturation, orders...).
## Edits are runtime only: balance values are changed in place in main.balance (the same
## Dictionary trade.gd reads), targets in a private copy, map tunables on the map node.
## Nothing here writes data/balance.json and nothing is added to the autosave.
## Values that are only read once at start (starting_credits) change nothing mid-game.

const BALANCE_PATH := "res://data/balance.json"
const TOGGLE_KEY := KEY_QUOTELEFT
const StoryText := preload("res://game/story_text.gd")

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
var _qa: VBoxContainer        # T13: QA controls, built once by add_qa_tools()
var qa: Dictionary = {}       # T13: control name -> Control (read by tests)
var _notice_ids: Array = []
var _notice_next := 0

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
	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(root)
	_qa = VBoxContainer.new()
	root.add_child(_qa)
	_body = VBoxContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_body)
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

## T78: force the win goal at the end of the current cycle; shows the stats file path.
func add_force_goal() -> void:
	var b := CheckButton.new()
	b.text = "Force goal at cycle end"
	b.toggled.connect(func(on: bool): main.debug_force_goal = on)
	add_tool(b)
	var l := Label.new()
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.text = "Stats: " + RunStats.global_path()
	add_tool(l)

## T12: fire any event by id (debug builds only; the menu is never created in release).
func add_event_trigger() -> void:
	var o := OptionButton.new()
	for id in main.events.by_id.keys():
		o.add_item("%s  %s" % [id, main.events.title_of(str(id))])
		o.set_item_metadata(o.item_count - 1, id)
	var b := Button.new()
	b.text = "Fire event"
	b.pressed.connect(func():
		if o.item_count > 0:
			main.debug_fire_event(str(o.get_item_metadata(o.selected))))
	add_tool(o)
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

## ---- T13 QA controls ----

func _qa_section(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", Color(0.5, 0.9, 1.0))
	_qa.add_child(l)

func _qa_button(name: String, text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.pressed.connect(cb)
	_qa.add_child(b)
	qa[name] = b
	return b

func _qa_label(name: String) -> Label:
	var l := Label.new()
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_qa.add_child(l)
	qa[name] = l
	return l

func _planet_option(name: String) -> OptionButton:
	var o := OptionButton.new()
	for i in main.map.planets.size():
		o.add_item("%d %s" % [i, main.planet_name(i)])
		o.set_item_metadata(o.item_count - 1, i)
	_qa.add_child(o)
	qa[name] = o
	return o

func _sel(o: OptionButton) -> int:
	return int(o.get_item_metadata(o.selected)) if o.item_count > 0 and o.selected >= 0 else -1

func event_state_text() -> String:
	var ev = main.events
	var lines: Array = []
	for a in ev.active:
		lines.append("%s %s %s %s, %d cycles left" % [a["id"], a["kind"], main.planet_name(int(a["planet"])), a["c"], int(a["left"])])
	var closed: Array = ev.closed_list(main._closed_bridge())
	lines.append("Closed now: " + (", ".join(closed.map(func(i): return main.planet_name(int(i)))) if not closed.is_empty() else "none"))
	lines.append("Debris: " + (", ".join(ev.debris.map(func(i): return main.planet_name(int(i)))) if not ev.debris.is_empty() else "none"))
	lines.append("Pending: %s  Force next: %s" % [ev.pending_id if ev.pending_id != "" else "none", str(main.debug_force_event)])
	return "\n".join(lines)

func gate_text() -> String:
	return "A1 gate %s. Planets visited %s, routes made %d. Space Storage posts: %s" % ["OPEN" if main.a1_gate_open() else "closed",
		str(main.pts_planets), main.pts_pairs.size(), str(main.open_systems.filter(func(s): return main.space_post_open(int(s))))]

func ships_text() -> String:
	var lines: Array = ["Ships %d/%d (small %d, large %d), free %d" % [main.ships, int(main.balance.get("ship_cap", 0)),
		main.owned_of("small"), main.owned_of("large"), main.free_ships()]]
	for r in main.engine.routes:
		lines.append("route #%d: %s ship, level %d" % [int(r["id"]), str(r.get("ship", "small")), int(r.get("level", 1))])
	return "\n".join(lines)

func tutorial_text() -> String:
	if main.cycle > 4:
		return "Tutorial over (cycle %d)." % main.cycle
	var todo: Array = []
	for k in ["row", "order_buy", "order_sell", "route"]:
		if not main.tut_first.has(k):
			todo.append(k)
	var cycle_ids := {1: "TUT_C1_PLANET", 2: "TUT_C2_UPKEEP", 3: "TUT_C3_STORAGE", 4: "TUT_C4_SKILLS"}
	return "Cycle %d line: %s. Cycle 1 triggers not yet used: %s" % [main.cycle, cycle_ids[main.cycle], ", ".join(todo) if not todo.is_empty() else "none"]

func _notice_id_list() -> Array:
	if _notice_ids.is_empty():
		var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/story_text.json"))
		if typeof(parsed) == TYPE_ARRAY:
			for e in parsed:
				if str(e.get("id", "")).begins_with("NOT_"):
					_notice_ids.append(str(e["id"]))
	return _notice_ids

func add_qa_tools() -> void:
	_qa_section("QA: events")
	_qa_button("force_event", "Force an event at next cycle start", func(): main.debug_force_event = true; _refresh_qa())
	_qa_button("show_events", "Refresh event state", _refresh_qa)
	_qa_label("event_state")
	_qa_section("QA: debris")
	var dp := _planet_option("debris_planet")
	_qa_button("debris_set", "Set debris on planet", func(): main.debug_set_debris(_sel(dp), true); _refresh_qa())
	_qa_button("debris_clear", "Clear debris on planet", func(): main.debug_set_debris(_sel(dp), false); _refresh_qa())
	_qa_section("QA: permits and systems")
	_qa_button("unlock_s2", "Unlock system 2 now", func(): main.debug_grant_permit(2); _refresh_qa())
	var po := OptionButton.new()
	for sid in main.Systems.ids():
		po.add_item(main.Systems.name_of(int(sid)))
		po.set_item_metadata(po.item_count - 1, int(sid))
	_qa.add_child(po)
	qa["permit_system"] = po
	_qa_button("grant_permit", "Grant permit (free)", func(): main.debug_grant_permit(_sel(po)); _refresh_qa())
	_qa_label("open_systems")
	_qa_section("QA: Space Storage")
	_qa_button("gate_open", "Set A1 gate: visited + route made", func(): main.debug_set_a1_gate(true); _refresh_qa())
	_qa_button("gate_reset", "Clear A1 gate inputs", func(): main.debug_set_a1_gate(false); _refresh_qa())
	_qa_label("gate_state")
	_qa_section("QA: ships and routes")
	_qa_button("ship_small", "Add small ship (free)", func(): main.debug_add_ship("small"); _refresh_qa())
	_qa_button("ship_large", "Add large ship (free)", func(): main.debug_add_ship("large"); _refresh_qa())
	var rid := _spin(1, 1, 9999, 1, func(_v): pass)
	var lvl := _spin(1, 1, 99, 1, func(_v): pass)
	_add_qa_row("Route id / level", [rid, lvl])
	qa["route_id"] = rid
	qa["route_level"] = lvl
	_qa_button("route_set_level", "Set route level", func(): main.debug_set_route_level(int(rid.value), int(lvl.value)); _refresh_qa())
	_qa_label("ship_state")
	_qa_section("QA: cash and points")
	_qa_button("cash_add", "Add 1000 cash", func(): main.debug_add_cash(1000))
	_qa_button("points_add", "Add 5 expansion points", func(): main.debug_add_points(5))
	_qa_button("reset_run", "Reset run (new game)", main.debug_reset_run)
	_qa_section("QA: notices")
	_qa_button("notice_next", "Post next notice id", func():
		var ids := _notice_id_list()
		if ids.is_empty():
			return
		var id: String = ids[_notice_next % ids.size()]
		_notice_next += 1
		main.post_notice(StoryText.get_or(id, id, {}))
		(qa["notice_state"] as Label).text = "Posted %s (%d of %d). Queue: %d" % [id, ((_notice_next - 1) % ids.size()) + 1, ids.size(), main.notice_queue.size()])
	_qa_label("notice_state")
	_qa_section("QA: tutorial")
	_qa_button("tut_restart", "Restart tutorial (cycle 1)", func(): main.debug_restart_tutorial(); _refresh_qa())
	_qa_label("tutorial_state")
	_qa_section("QA: galaxy view and save")
	_qa_button("galaxy_open", "Open galaxy view (no gate)", main.debug_open_galaxy)
	_qa_button("save_now", "Force save", func(): main.save_now(); _refresh_qa())
	_qa_label("save_state")
	_qa_section("Not built yet, skipped: solar shield, pirates, nomads, asteroid approach, asteroid fields")
	_refresh_qa()

func _add_qa_row(label: String, controls: Array) -> void:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = label
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	for c in controls:
		row.add_child(c)
	_qa.add_child(row)

func _refresh_qa() -> void:
	if not qa.has("event_state"):
		return
	(qa["event_state"] as Label).text = event_state_text()
	(qa["open_systems"] as Label).text = "Open systems: " + str(main.open_systems)
	(qa["gate_state"] as Label).text = gate_text()
	(qa["ship_state"] as Label).text = ships_text()
	(qa["tutorial_state"] as Label).text = tutorial_text()
	(qa["save_state"] as Label).text = "Save file: " + ProjectSettings.globalize_path(main.SaveGame.PATH)

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
