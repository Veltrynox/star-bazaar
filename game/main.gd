extends Control
## T03: cycle timer + top bar. Values come from data/balance.json at runtime.

signal cycle_ended(cycle: int)

const BALANCE_PATH := "res://data/balance.json"
const SaveGame := preload("res://game/save_game.gd")
const Trade := preload("res://game/trade.gd")

var balance: Dictionary = {}
var cash: int = 0
var cycle: int = 1          # current cycle, 1-based
var cycle_elapsed: float = 0.0  # seconds into current cycle
var time_speed: float = 1.0  # T34: debug-only clock multiplier, runtime only, never saved
var paused: bool = true  # T23: game starts paused after the preface
var game_over: bool = false

var map: Node3D
var planet_panel: PanelContainer
var goal_label: Label
var cycle_label: Label
var pause_button: Button
var progress: ProgressBar
var preface: Control  # T23 preface overlay; null once dismissed
var ships: int = 0  # T28 abstract ship count
var ship_panel: PanelContainer
var cash_forecast: PanelContainer  # T40
var mission_label: Label
var guide_label: Label  # T06 how-to-trade text on the board
var resource_label: Label  # T06 held goods in the top bar
var trade: RefCounted = Trade.new()  # T06 cargo, ship location, mission step
var commodities: Array = []
var debug_menu: PanelContainer  # T33: null in release builds; T34 adds its button via debug_menu.add_tool()
var selected_planet: int = -1
var mission_planet: int = -1  # planet that sells the first ship (abundant energy, scarce food)

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
	ship_panel = load("res://game/ship_panel.gd").new()
	add_child(ship_panel)
	planet_panel.buy_ship_requested.connect(_buy_ship)
	mission_planet = _find_mission_planet()
	commodities = _commodities(map.planets)
	trade.setup(balance, map.planets)
	cash_forecast = load("res://game/cash_forecast.gd").new()  # T40: money text dropdown
	add_child(cash_forecast)
	cash_forecast.setup(self, goal_label)
	planet_panel.trade_requested.connect(_on_trade)
	planet_panel.send_requested.connect(_on_send)
	var saved := SaveGame.load_state() if SaveGame.continue_requested else {}
	SaveGame.continue_requested = false
	if saved.is_empty():
		_build_preface()
	else:
		apply_state(saved)  # T26: resume paused, no preface
	if OS.is_debug_build():  # T33: debug menu is never created in release exports
		debug_menu = load("res://game/debug_menu.gd").new()
		add_child(debug_menu)
		debug_menu.setup(self)
		debug_menu.add_speed_button()
	_refresh()

## T26: state written to the autosave. Add new keys here (see save_game.gd).
## Tuning values from balance.json are never saved.
func collect_state() -> Dictionary:
	trade.now = _progress()  # T30: flight time left is saved relative to now
	return {"cycle": cycle, "cycle_elapsed": cycle_elapsed, "cash": cash, "paused": paused, "ships": ships}.merged(trade.collect())

func apply_state(s: Dictionary) -> void:
	cycle = maxi(1, int(s.get("cycle", 1)))
	cycle_elapsed = clampf(float(s.get("cycle_elapsed", 0.0)), 0.0, _cycle_seconds())
	cash = int(s.get("cash", cash))
	ships = clampi(int(s.get("ships", 0)), 0, int(balance.get("ship_cap", 0)))
	trade.now = _progress()
	trade.apply(s, ships, mission_planet)  # T06: cargo, ship location, mission step
	paused = true  # always resume paused

func save_now() -> void:
	if preface != null or game_over:
		return
	SaveGame.write_state(collect_state())

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_now()

func _to_menu() -> void:
	save_now()
	get_tree().change_scene_to_file("res://game/main_menu.tscn")

func _on_planet_clicked(index: int) -> void:
	if index < 0 or index >= map.planets.size():
		selected_planet = -1
		planet_panel.visible = false
		return
	selected_planet = index
	planet_panel.show_planet(map.planets[index], commodities)
	_refresh_panel()

## T28: first planet with abundant energy and scarce food, or -1.
func _find_mission_planet() -> int:
	for i in map.planets.size():
		var p = map.planets[i]
		if typeof(p) == TYPE_DICTIONARY and p.get("abundant") == "energy" and p.get("scarce") == "food":
			return i
	return -1

## Every planet sells ships (GDD section 2); also refreshes the T06 trade controls.
func _refresh_panel() -> void:
	if selected_planet < 0:
		return
	planet_panel.set_ship_offer(true,
		int(balance.get("ship_price", 0)), ships, int(balance.get("ship_cap", 0)), cash)
	var reason: String = trade.send_reason(selected_planet, cash, ships)
	planet_panel.set_trade(trade.rows(selected_planet, commodities, cash, ships), {
		"show": ships > 0 and not trade.docked_at(selected_planet),
		"reason": reason, "cost": trade.trip_cost()})

func _buy_ship() -> void:
	var price := int(balance.get("ship_price", 0))
	if cash < price or ships >= int(balance.get("ship_cap", 0)):
		return
	cash -= price
	ships += 1
	trade.on_ship_bought(selected_planet, ships)
	_after_action()

## T06: move the mission on, refresh everything that shows cash or cargo, autosave.
func _after_action() -> void:
	trade.tick(_progress())
	var done: bool = trade.advance(ships)
	_refresh()
	_refresh_panel()
	save_now()
	if done:
		_on_trade_mission_complete()

## T07 HOOK: the offer of an automated route belongs here (GDD: "asks if we want to
## establish an automated trade route"). Called once, when the first-trade mission ends.
func _on_trade_mission_complete() -> void:
	pass

func _on_trade(commodity: String, action: String) -> void:
	if selected_planet < 0:
		return
	match action:
		"buy1": cash -= trade.buy(selected_planet, commodity, 1, cash)
		"buymax": cash -= trade.buy(selected_planet, commodity, trade.max_buy(selected_planet, commodity, cash), cash)
		"sellall": cash += trade.sell_all(selected_planet, commodity)
	_after_action()

## T30: cycle progress (cycle number plus time within the cycle), unaffected by pausing.
func _progress() -> float:
	return float(cycle - 1) + cycle_elapsed / _cycle_seconds()

## T30: trip_cost is charged now; the ship flies for travel_cycles_per_leg cycles of running time.
func _on_send() -> void:
	var cost: int = trade.send(selected_planet, cash, ships)
	if cost < 0:
		return
	cash -= cost
	_after_action()

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
	cycle_elapsed += delta * time_speed
	var length := _cycle_seconds()
	if cycle_elapsed >= length:
		cycle_elapsed -= length
		_end_cycle()
	if trade.tick(_progress()):
		_after_action()  # T30: the ship has landed
	_refresh()

func _end_cycle() -> void:
	cycle_ended.emit(cycle)
	var win_cash := int(balance.get("win_cash", 0))
	var win_cycle := int(balance.get("win_cycle", 0))
	if cash >= win_cash or cycle >= win_cycle:
		game_over = true  # win/loss screens are a later task
		SaveGame.clear()
		return
	cycle += 1
	_refresh_panel()  # T30: 'arrives in N cycle(s)' changes at cycle end
	save_now()

func set_paused(value: bool) -> void:
	paused = value
	_refresh()
	save_now()

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
	resource_label = Label.new()
	box.add_child(resource_label)
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
	var menu_button := Button.new()
	menu_button.text = "Menu"
	menu_button.pressed.connect(_to_menu)
	box.add_child(menu_button)

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
	var waiting: bool = paused and trade.in_flight() and not game_over
	pause_button.modulate = Color(1.0, 0.85, 0.3) if waiting else Color.WHITE  # T30: highlight
	if cash_forecast != null:
		cash_forecast.refresh()  # T40: live while open
	if ship_panel != null:
		ship_panel.set_count(ships, int(balance.get("ship_cap", 0)), trade.status_text(), waiting)
		var target: int = trade.hint_planet(mission_planet)  # T28/T06: where to click or go next
		map.set_hint(target, target >= 0)
		map.set_dock_dot(trade.ship_planet, ships > 0 and trade.docked_at(trade.ship_planet))  # T35
		mission_label.text = trade.mission_text(paused)
		guide_label.visible = ships > 0 and trade.step < Trade.Step.DONE
		guide_label.text = trade.guide_text()
		var parts: PackedStringArray = []
		for c in commodities:
			parts.append("%s: %d" % [str(c).capitalize(), trade.held(str(c))])
		resource_label.text = "   ".join(parts) + "   Cargo: %d / %d" % [trade.used(), trade.capacity()]

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
	mission_label = Label.new()
	mission_label.text = "Mission: Buy a ship"
	mission_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(mission_label)
	guide_label = Label.new()
	guide_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide_label.visible = false
	box.add_child(guide_label)

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
