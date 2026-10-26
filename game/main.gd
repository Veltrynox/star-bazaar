extends Control
## T03: cycle timer + top bar. Values come from data/balance.json at runtime.

signal cycle_ended(cycle: int)

const BALANCE_PATH := "res://data/balance.json"

var balance: Dictionary = {}
var cash: int = 0
var cycle: int = 1          # current cycle, 1-based
var cycle_elapsed: float = 0.0  # seconds into current cycle
var paused: bool = true  # T23: game starts paused after the preface
var game_over: bool = false

var map: Node3D
var planet_panel: PanelContainer
var goal_label: Label
var cycle_label: Label
var pause_button: Button
var progress: ProgressBar
var preface: Control  # T23 preface overlay; null once dismissed

func _ready() -> void:
	balance = _load_balance()
	cash = int(balance.get("starting_credits", 0))
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # let clicks reach the 3D map (T04)
	map = load("res://game/map.gd").new()
	add_child(map)  # T20 map, added before UI so the bar draws on top
	_build_ui()
	planet_panel = load("res://game/planet_panel.gd").new()
	add_child(planet_panel)
	map.planet_clicked.connect(_on_planet_clicked)
	_build_board()
	_build_preface()
	_refresh()

func _on_planet_clicked(index: int) -> void:
	if index < 0 or index >= map.planets.size():
		planet_panel.visible = false
		return
	planet_panel.show_planet(map.planets[index], _commodities(map.planets))

## Commodity names found in the planet data (abundant/scarce and *_buy/*_sell keys).
func _commodities(planets: Array) -> Array:
	var out: Array = []
	for p in planets:
		if typeof(p) != TYPE_DICTIONARY:
			continue
		for k in ["abundant", "scarce"]:
			var v = p.get(k)
			if typeof(v) == TYPE_STRING and v != "UNKNOWN" and not out.has(v):
				out.append(v)
		var prices = p.get("base_prices")
		if typeof(prices) == TYPE_DICTIONARY:
			for key in prices.keys():
				var s := str(key)
				for suffix in ["_buy", "_sell"]:
					if s.ends_with(suffix):
						var c := s.trim_suffix(suffix)
						if not out.has(c):
							out.append(c)
	return out

func _load_balance()-> Dictionary:
	var f := FileAccess.open(BALANCE_PATH, FileAccess.READ)
	if f == null:
		push_error("Cannot open " + BALANCE_PATH)
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("values"):
		push_error("Bad balance.json")
		return {}
	return parsed["values"]

func _cycle_seconds() -> float:
	return float(balance.get("cycle_minutes", 2)) * 60.0

func _process(delta: float) -> void:
	if paused or game_over:
		return
	cycle_elapsed += delta
	var length := _cycle_seconds()
	if cycle_elapsed >= length:
		cycle_elapsed -= length
		_end_cycle()
	_refresh()

func _end_cycle() -> void:
	cycle_ended.emit(cycle)
	var win_cash := int(balance.get("win_cash", 0))
	var win_cycle := int(balance.get("win_cycle", 0))
	if cash >= win_cash or cycle >= win_cycle:
		game_over = true  # win/loss screens are a later task
		return
	cycle += 1

func set_paused(value: bool) -> void:
	paused = value
	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if preface != null:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		set_paused(not paused)

func _build_ui() -> void:
	var bar := PanelContainer.new()
	bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	add_child(bar)
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	bar.add_child(box)
	goal_label = Label.new()
	goal_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(goal_label)
	cycle_label = Label.new()
	box.add_child(cycle_label)
	progress = ProgressBar.new()
	progress.custom_minimum_size = Vector2(120, 0)
	progress.show_percentage = false
	progress.max_value = 1.0
	box.add_child(progress)
	pause_button = Button.new()
	pause_button.pressed.connect(func(): set_paused(not paused))
	box.add_child(pause_button)

func _refresh() -> void:
	if goal_label == null:
		return
	goal_label.text = "Goal: %d by cycle %d. Now: %d." % [
		int(balance.get("win_cash", 0)), int(balance.get("win_cycle", 0)), cash]
	var state := ""
	if game_over:
		state = "  (game over)"
	elif paused:
		state = "  (paused)"
	cycle_label.text = "Cycle %d / %d%s" % [cycle, int(balance.get("win_cycle", 0)), state]
	progress.value = cycle_elapsed / _cycle_seconds()
	pause_button.text = "Resume" if paused else "Pause"

## T24: notification board, right side, text only. GDD section 2 'First 4 cycles'.
func _build_board() -> void:
	var board := PanelContainer.new()
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	board.custom_minimum_size = Vector2(240, 0)
	board.offset_left = -252
	board.offset_right = -12
	board.offset_top = 56
	add_child(board)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	board.add_child(box)
	var title := Label.new()
	title.text = "Notifications"
	title.add_theme_font_size_override("font_size", 18)
	box.add_child(title)
	var mission := Label.new()
	mission.text = "Mission: Buy a ship"
	mission.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(mission)

## T23: preface text, from GDD section 1 (win condition) and section 2 (first 4 cycles).
func _preface_text() -> String:
	return ("You dream of escaping society and living on a planet of your own. "
		+ "But to do that, you need money.\n\n"
		+ "Earn at least %d credits by the end of a cycle, within %d cycles, and the dream comes true. "
		+ "If you are still short when cycle %d ends, it slips away.\n\n"
		+ "You start with %d credits. Buy a ship, buy cheap where a good is abundant, "
		+ "and sell where it is scarce.") % [
		int(balance.get("win_cash", 0)), int(balance.get("win_cycle", 0)),
		int(balance.get("win_cycle", 0)), int(balance.get("starting_credits", 0))]

func _build_preface() -> void:
	# Map must not react (camera/picking) while the preface is open.
	map.set_process(false)
	map.set_process_input(false)
	map.set_process_unhandled_input(false)
	var layer := ColorRect.new()
	layer.color = Color(0, 0, 0, 0.85)
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	preface = layer
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(560, 0)
	box.add_theme_constant_override("separation", 20)
	center.add_child(box)
	var title := Label.new()
	title.text = "Star Bazaar"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	box.add_child(title)
	var body := Label.new()
	body.text = _preface_text()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body)
	var start := Button.new()
	start.text = "Start"
	start.pressed.connect(_dismiss_preface)
	box.add_child(start)
	start.grab_focus()

func _dismiss_preface() -> void:
	if preface != null:
		preface.queue_free()
		preface = null
	map.set_process(true)
	map.set_process_input(true)
	map.set_process_unhandled_input(true)
	paused = true
	_refresh()
