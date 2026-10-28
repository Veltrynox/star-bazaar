extends Control
## T03: cycle timer + top bar. Values come from data/balance.json at runtime.

signal cycle_ended(cycle: int)
## T07: emitted at every cycle end after routes paid. results: Array of
## {id, a, b, ships, net, paid, status}; total: credits paid by all routes.
signal routes_settled(results: Array, total: int)
## T56: a route just became blocked (destination storage full or planet closed).
signal route_blocked(id: int, text: String)
signal notice_posted(text: String)

const BALANCE_PATH := "res://data/balance.json"
const SaveGame := preload("res://game/save_game.gd")
const Trade := preload("res://game/trade.gd")
const RouteEngine := preload("res://game/route_engine.gd")
const Storage := preload("res://game/storage.gd")

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
var trade: RefCounted = Trade.new()  # price/margin logic for T07
var commodities: Array = []
var storage: RefCounted = Storage.new()  # T55 planet stock
var engine: RefCounted = RouteEngine.new()  # T07 route records and math
var notice_label: Label
var last_notice: String = ""
var notice_ends_left: int = 0  # cycle ends until the board notice is cleared
var debug_menu: PanelContainer  # T33: null in release builds; T34 adds its button via debug_menu.add_tool()
var selected_planet: int = -1
var pending: Dictionary = {}  # T68: "Send to..." waiting for a destination {planet, c}; empty when none
var pending_label: Label
var last_local: Array = []  # T68: local order results of the last cycle end
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
	planet_panel.setup(self)
	planet_panel.order_requested.connect(_on_order)
	planet_panel.send_requested.connect(_on_send)
	planet_panel.remove_requested.connect(func(id: int): remove_connection(id))
	map.planet_clicked.connect(_on_planet_clicked)
	map.route_clicked.connect(_on_route_clicked)
	_build_board()
	_build_pending_label()
	ship_panel = load("res://game/ship_panel.gd").new()
	add_child(ship_panel)
	planet_panel.buy_ship_requested.connect(_buy_ship)
	mission_planet = _find_mission_planet()
	commodities = _commodities(map.planets)
	trade.setup(balance, map.planets)
	storage.setup(balance, map.planets.size(), commodities)
	engine.setup(balance, trade, commodities, storage)
	cash_forecast = load("res://game/cash_forecast.gd").new()  # T40: money text dropdown
	add_child(cash_forecast)
	cash_forecast.setup(self, goal_label)
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
		debug_menu.add_next_cycle_button()
		debug_menu.add_routes_dump()
	_push_routes_to_map()
	_refresh()

## T26: state written to the autosave. Add new keys here (see save_game.gd).
## Tuning values from balance.json are never saved.
func collect_state() -> Dictionary:
	return {"cycle": cycle, "cycle_elapsed": cycle_elapsed, "cash": cash, "paused": paused, "ships": ships,
		"routes": engine.to_array(), "storage": storage.to_dict(), "orders": engine.local_to_array()}

func apply_state(s: Dictionary) -> void:
	cycle = maxi(1, int(s.get("cycle", 1)))
	cycle_elapsed = clampf(float(s.get("cycle_elapsed", 0.0)), 0.0, _cycle_seconds())
	cash = int(s.get("cash", cash))
	ships = clampi(int(s.get("ships", 0)), 0, int(balance.get("ship_cap", 0)))
	engine.from_array(s.get("routes", []), ships)  # old saves: no key = zero routes
	storage.from_dict(s.get("storage"), map.planets.size())  # old saves: fresh stock
	engine.local_from_array(s.get("orders"))  # old saves: no local orders
	# T51: old saves may hold cargo, ship_planet, dest, flight_left, mission_step; ignored.
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
	if not pending.is_empty():
		if index < 0 or index >= map.planets.size():
			cancel_pending()
		elif index == int(pending["planet"]):
			post_notice("Pick a different planet as the destination.")
			return
		else:
			var r := send_stock(int(pending["planet"]), index, str(pending["c"]))
			if not r["ok"]:
				post_notice(str(r["reason"]))  # pending stays so the player can pick another planet
				return
			cancel_pending()
			post_notice("Route created: %s to %s." % [r["c"], planet_name(index)])
			selected_planet = index
			planet_panel.show_planet(index)
			return
	if index < 0 or index >= map.planets.size():
		selected_planet = -1
		planet_panel.visible = false
		return
	selected_planet = index
	planet_panel.show_planet(index)

## T65: clicking a route line selects that connection in the panel (with Remove).
func _on_route_clicked(id: int) -> void:
	var i: int = engine.find_by_id(id)
	if i < 0:
		return
	selected_planet = int(engine.routes[i]["a"])
	planet_panel.show_planet(selected_planet, id)

## T28: first planet with abundant energy and scarce food, or -1.
func _find_mission_planet() -> int:
	for i in map.planets.size():
		var p = map.planets[i]
		if typeof(p) == TYPE_DICTIONARY and p.get("abundant") == "energy" and p.get("scarce") == "food":
			return i
	return -1

## Rebuilds the planet panel (rows, connections, ship button) for the selected planet.
func _refresh_panel() -> void:
	if selected_planet >= 0:
		planet_panel.rebuild()

## T68: Buy / Sell toggled on a resource row of the selected planet (standing local order, no ship).
func _on_order(c: String, role: String) -> void:
	if selected_planet < 0 or game_over:
		return
	var r := toggle_local(selected_planet, c, role)
	if not r["ok"]:
		post_notice(str(r["reason"]))

## T68: "Send to..." pressed on a storage row: the next planet clicked becomes the destination.
func _on_send(c: String) -> void:
	if selected_planet < 0 or game_over:
		return
	if not pending.is_empty() and pending["planet"] == selected_planet and pending["c"] == c:
		cancel_pending()
		return
	pending = {"planet": selected_planet, "c": c}
	_pending_changed()

func cancel_pending() -> void:
	pending = {}
	_pending_changed()

func _pending_changed() -> void:
	map.set_pending(int(pending["planet"]) if not pending.is_empty() else -1)
	if pending_label != null:
		pending_label.visible = not pending.is_empty()
		if not pending.is_empty():
			pending_label.text = "Send %s from %s: click the destination planet. (Esc to cancel)" % [
				pending["c"], planet_name(int(pending["planet"]))]
	_refresh_panel()

func _build_pending_label() -> void:
	pending_label = Label.new()
	pending_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	pending_label.position.y = 64
	pending_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	pending_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	pending_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pending_label.visible = false
	add_child(pending_label)

func _buy_ship() -> void:
	buy_ship()

## ---- T07 engine API (UI and bots). Ships are owned (ships) and either free or assigned. ----

func free_ships() -> int:
	return ships - engine.total_assigned()

## Buys one free ship at ship_price. Returns {ok, reason}.
func buy_ship() -> Dictionary:
	var r := can_buy_ship()
	if not r["ok"]:
		return r
	cash -= int(balance.get("ship_price", 0))
	ships += 1
	_after_change()
	return r

func can_buy_ship() -> Dictionary:
	if game_over:
		return {"ok": false, "reason": "The game is over."}
	if ships >= int(balance.get("ship_cap", 0)):
		return {"ok": false, "reason": "Ship cap reached."}
	if cash < int(balance.get("ship_price", 0)):
		return {"ok": false, "reason": "Not enough cash for a ship."}
	return {"ok": true, "reason": ""}

## ---- T56 one-way route API (T57 UI and bots). One ship per route, auto-assigned from the free pool. ----

## Setup check for a connection src -> dst carrying c. One reason when refused.
func can_connect(src: int, dst: int, c: String) -> Dictionary:
	if game_over:
		return {"ok": false, "reason": "The game is over."}
	var r: Dictionary = engine.check_connection(src, dst, c)
	if not r["ok"]:
		return r
	if free_ships() <= 0:
		return {"ok": false, "reason": "No free ship. Buy a ship first."}
	return {"ok": true, "reason": ""}

## One-way route that moves commodity c from the storage at `src` to the storage at `dst` (one auto-assigned ship).
## Returns {ok, reason, id, c}.
func send_stock(src: int, dst: int, c: String) -> Dictionary:
	var r := _connect(src, dst, c)
	r["c"] = c
	return r

## T68: standing local order at a planet (no ship). role "buy" or "sell". Returns {ok, reason}.
func set_local_order(planet: int, c: String, role: String, on: bool) -> Dictionary:
	if game_over:
		return {"ok": false, "reason": "The game is over."}
	var r: Dictionary = engine.set_local(planet, c, role, on)
	if r["ok"]:
		_after_change()
	return r

func toggle_local(planet: int, c: String, role: String) -> Dictionary:
	return set_local_order(planet, c, role, not engine.local_on(planet, c, role))

func _connect(src: int, dst: int, c: String) -> Dictionary:
	var r := can_connect(src, dst, c)
	if not r["ok"]:
		return r
	var rec: Dictionary = engine.new_record(src, dst, c)
	rec["id"] = engine.next_id
	engine.next_id += 1
	rec["fresh"] = clampf(1.0 - cycle_elapsed / _cycle_seconds(), 0.0, 1.0)
	engine.routes.append(rec)
	storage.ensure(str(rec["src"]))  # T65: first order at a planet establishes its company storage
	storage.ensure(str(rec["dst"]))
	_after_change()
	return {"ok": true, "reason": "", "id": rec["id"]}

## Removes the connection; its ship becomes free.
func remove_connection(id: int) -> Dictionary:
	var i: int = engine.find_by_id(id)
	if i < 0:
		return {"ok": false, "reason": "No such route."}
	engine.routes.remove_at(i)
	_after_change()
	return {"ok": true, "reason": ""}

## Copy of one route: record fields plus status (running | stalled | blocked), reason, net (projected per cycle),
## role ("buy" if `planet` is the source, "sell" if the destination, "" without a planet argument).
func _view(rec: Dictionary, planet: int = -1) -> Dictionary:
	var d: Dictionary = rec.duplicate(true)
	d["status"] = engine.status_of(rec)
	d["reason"] = engine.reason_of(rec)
	d["net"] = engine.payout_of(rec)
	d["role"] = "buy" if rec["a"] == planet else ("sell" if rec["b"] == planet else "")
	return d

## Connections that touch a planet (as buy or sell side), optionally for one commodity.
func connections_at(planet: int, c: String = "") -> Array:
	var out: Array = []
	for rec in engine.routes:
		if (rec["a"] == planet or rec["b"] == planet) and (c == "" or rec["c"] == c):
			out.append(_view(rec, planet))
	return out

func get_routes() -> Array:
	var out: Array = []
	for rec in engine.routes:
		out.append(_view(rec))
	return out

func route_net(id: int) -> int:
	var i: int = engine.find_by_id(id)
	return engine.payout_of(engine.routes[i]) if i >= 0 else 0

func planet_name(i: int) -> String:
	if i < 0 or i >= map.planets.size():
		return "?"
	return str(map.planets[i].get("name", map.planets[i].get("id", "?")))

## T07b: tell the map which route lines to draw (cheap: restyles existing lines, adds/removes changed ones).
func _push_routes_to_map() -> void:
	var list: Array = []
	for rec in engine.routes:
		list.append({"id": rec["id"], "a": rec["a"], "b": rec["b"], "ships": 1, "status": engine.status_of(rec)})
	map.set_routes(list)

func _after_change() -> void:
	_push_routes_to_map()
	_refresh()
	_refresh_panel()
	save_now()

func post_notice(text: String) -> void:
	last_notice = text
	notice_ends_left = 1  # cleared at the next cycle end
	if notice_label != null:
		notice_label.text = text
		notice_label.visible = true
	notice_posted.emit(text)

## Settles every route once (called from _end_cycle). Returns the results array.
func _settle_routes() -> Array:
	var r: Dictionary = engine.settle(cash)
	last_local = r["local"]
	cash += int(r["delta"])
	for rec in r["newly_blocked"]:
		var text := "Route blocked: %s to %s (%s). %s" % [planet_name(rec["a"]), planet_name(rec["b"]), rec["c"], rec["reason"]]
		post_notice(text)
		route_blocked.emit(int(rec["id"]), text)
	routes_settled.emit(r["results"], int(r["delta"]))
	return r["results"]

## T46: stranded = zero owned ships and cash below ship_price. Pays rescue_stipend, never a loss.
func _check_stranded() -> void:
	if ships == 0 and cash < int(balance.get("ship_price", 0)):
		var amount := int(balance.get("rescue_stipend", 0))
		cash += amount
		post_notice("Odd jobs at the dock: you earned %d credits. Enough for a ship." % amount)

## T07 HOOK: the offer of an automated route belongs here (GDD: "asks if we want to
## establish an automated trade route"). Nothing calls it since T51 removed the manual
## first-trade mission; T07 decides the trigger.
func _on_trade_mission_complete() -> void:
	pass

## Cycle progress (cycle number plus time within the cycle), unaffected by pausing.
func _progress() -> float:
	return float(cycle - 1) + cycle_elapsed / _cycle_seconds()

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
	while cycle_elapsed >= length and not game_over:
		cycle_elapsed -= length
		_end_cycle()
	_refresh()

## Debug only (no-op in release): jump to the end of the current cycle and run the normal
## _process path once, so end-of-cycle processing happens as on the timer.
## Works while paused. Returns the cycle number after the call.
func debug_advance_cycle() -> int:
	if not OS.is_debug_build() or game_over:
		return cycle
	var was_paused := paused
	paused = false
	cycle_elapsed = _cycle_seconds()
	_process(0.0)
	paused = was_paused
	return cycle

func _end_cycle() -> void:
	if notice_ends_left > 0:  # board notice lives for one cycle
		notice_ends_left -= 1
		if notice_ends_left == 0:
			last_notice = ""
			if notice_label != null:
				notice_label.text = ""
				notice_label.visible = false
	_settle_routes()
	_check_stranded()
	_push_routes_to_map()
	_refresh_panel()
	cycle_ended.emit(cycle)
	var win_cash := int(balance.get("win_cash", 0))
	var win_cycle := int(balance.get("win_cycle", 0))
	if cash >= win_cash or cycle >= win_cycle:
		game_over = true  # win/loss screens are a later task
		SaveGame.clear()
		return
	cycle += 1
	save_now()

func set_paused(value: bool) -> void:
	paused = value
	_refresh()
	save_now()

func _unhandled_input(event: InputEvent) -> void:
	if preface != null:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE and not pending.is_empty():
		cancel_pending()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
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
	if cash_forecast != null:
		cash_forecast.refresh()  # T40: live while open
	if ship_panel != null:
		ship_panel.set_count(ships, int(balance.get("ship_cap", 0)))
		var target: int = mission_planet if ships == 0 else -1  # halo on the planet that sells the first ship
		map.set_hint(target, target >= 0)
		mission_label.visible = ships == 0
		mission_label.text = "Mission: Buy a ship"

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
	notice_label = Label.new()
	notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice_label.visible = false
	box.add_child(notice_label)

## T23: preface text, from GDD section 1 (win condition) and section 2 (first 4 cycles).
func _preface_text() -> String:
	return ("You dream of escaping society and living on a planet of your own. "
		+ "But to do that, you need money.\n\n"
		+ "Earn at least %d credits by the end of a cycle, within %d cycles, and the dream comes true. "
		+ "If you are still short when cycle %d ends, it slips away.\n\n"
		+ "You start with %d credits. Buy a ship and put it on an automated trade route.") % [
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
