extends PanelContainer
## T04 / T68: planet panel. Per commodity a row: name, prices, order status and Buy / Sell toggles
## (standing local orders, no ship needed). Company storage rows (once established) have a 5-line
## bar and "Send to..." (creates a one-way route to another planet's storage). Then connections.
## Content is rebuilt on demand (planet click, any route change, cycle end), never per frame.
## Reads everything from main (set via setup()). Unknown values are shown as text, never invented.

signal buy_ship_requested
signal order_requested(commodity: String, role: String)  # role: "buy" or "sell" (toggles the local order)
signal send_requested(commodity: String)  # "Send to..." on a storage row
signal remove_requested(route_id: int)

const COL_LIT := Color(1.0, 0.85, 0.35)
const COL_DIM := Color(0.25, 0.25, 0.3)
const COL_RED := Color(1.0, 0.35, 0.3)

var main: Control
var planet_index: int = -1
var selected_route: int = -1  # T65: connection picked by clicking its line
var box: VBoxContainer

func setup(m: Control) -> void:
	main = m

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	position = Vector2(12, 56)
	custom_minimum_size = Vector2(320, 0)
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	visible = false

func show_planet(index: int, route_id: int = -1) -> void:
	planet_index = index
	selected_route = route_id
	visible = true
	rebuild()

func rebuild() -> void:
	if main == null or planet_index < 0 or box == null:
		return
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()
	var p: Dictionary = main.map.planets[planet_index]
	var title := Label.new()
	title.text = str(p.get("name", p.get("id", "?")))
	title.add_theme_font_size_override("font_size", 18)
	box.add_child(title)
	box.add_child(_label("Abundant: %s.  Shortage: %s." % [_txt(p.get("abundant")), _txt(p.get("scarce"))]))
	var pend: Dictionary = main.pending
	if not pend.is_empty():
		var pl := _label("Sending %s from %s. Click the destination planet." % [
			pend["c"], main.planet_name(int(pend["planet"]))])
		pl.add_theme_color_override("font_color", COL_LIT)
		box.add_child(pl)
		var cancel := Button.new()
		cancel.text = "Cancel"
		cancel.pressed.connect(func(): main.cancel_pending())
		box.add_child(cancel)
	_selected_block()
	var prices = p.get("base_prices")
	for c in main.commodities:
		box.add_child(_row(str(c), prices if typeof(prices) == TYPE_DICTIONARY else {}, pend))
	_storage_section()
	_connections()
	_ship_button()
	size = Vector2.ZERO

func _row(c: String, prices: Dictionary, pend: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var n := Label.new()
	n.text = c.capitalize()
	info.add_child(n)
	var buy = prices.get(c + "_buy")
	var sell = prices.get(c + "_sell")
	var t := Label.new()
	t.text = "Buy price: %s   Sell price: %s" % [_price(buy), _price(sell)]
	t.add_theme_font_size_override("font_size", 12)
	info.add_child(t)
	for role in ["buy", "sell"]:
		if main.engine.local_on(planet_index, c, role):
			var st := Label.new()
			st.text = "%s order: %s" % [role.capitalize(), main.engine.local_state(planet_index, c, role)]
			st.add_theme_font_size_override("font_size", 12)
			st.add_theme_color_override("font_color", COL_LIT)
			info.add_child(st)
	row.add_child(info)
	for role in ["buy", "sell"]:
		var b := Button.new()
		var price = buy if role == "buy" else sell
		var on: bool = main.engine.local_on(planet_index, c, role)
		b.toggle_mode = true
		b.button_pressed = on
		b.text = role.capitalize() + (": on" if on else "")
		b.disabled = price == null
		b.tooltip_text = "Not traded here." if price == null else ("Standing %s order. Press to stop." % role if on else "Standing %s order each cycle." % role)
		b.pressed.connect(func(): order_requested.emit(c, role))
		row.add_child(b)
	return row

## A missing price is a data gap (planets.json), shown as text, never invented.
func _price(v) -> String:
	return "%s cr" % str(v) if v != null else "no data"

## T65: company storage, only once an order has established it at this planet.
func _storage_section() -> void:
	var key: String = main.storage.planet_key(planet_index)
	if not main.storage.established(key):
		return
	box.add_child(HSeparator.new())
	var cap: int = main.storage.capacity_of(key)
	var title := Label.new()
	title.text = "Company storage"
	title.add_theme_font_size_override("font_size", 15)
	box.add_child(title)
	box.add_child(_label("Capacity: %d per commodity" % cap))
	for c in main.commodities:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var bar := RatingBar.new()
		bar.level = main.storage.rating(key, str(c))
		row.add_child(bar)
		var l := Label.new()
		l.text = "%s  %d/%d" % [str(c).capitalize(), main.storage.amount(key, str(c)), cap]
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		var send := Button.new()
		var sending: bool = not main.pending.is_empty() and main.pending["planet"] == planet_index and main.pending["c"] == str(c)
		send.text = "Send to..." + ("*" if sending else "")
		send.tooltip_text = "Move this stock to another planet's storage with a ship."
		var cc: String = str(c)
		send.pressed.connect(func(): send_requested.emit(cc))
		row.add_child(send)
		box.add_child(row)

## T65: the connection picked by clicking its line, with Remove.
func _selected_block() -> void:
	if selected_route < 0:
		return
	for v in main.connections_at(planet_index):
		if int(v["id"]) != selected_route:
			continue
		var l := _label("Selected: %s %s > %s [%s]" % [str(v["c"]).capitalize(),
			main.planet_name(int(v["a"])), main.planet_name(int(v["b"])), v["status"]])
		l.add_theme_color_override("font_color", COL_LIT)
		box.add_child(l)
		var rm := Button.new()
		rm.text = "Remove this connection"
		var rid: int = selected_route
		rm.pressed.connect(func(): remove_requested.emit(rid))
		box.add_child(rm)
		return
	selected_route = -1

func _connections() -> void:
	var list: Array = main.connections_at(planet_index)
	if list.is_empty():
		return
	box.add_child(HSeparator.new())
	box.add_child(_label("Connections:"))
	for v in list:
		var row := HBoxContainer.new()
		var l := Label.new()
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(220, 0)
		var dirs: String = "%s > %s" % [main.planet_name(int(v["a"])), main.planet_name(int(v["b"]))]
		var st: String = v["status"]
		l.text = "%s: %s [%s]" % [str(v["c"]).capitalize(), dirs, st]
		if st != "running" and str(v["reason"]) != "":
			l.text += "\n" + str(v["reason"])
		elif st == "running":
			l.text += " %+d/cycle" % int(v["net"])
		if st == "blocked":
			l.add_theme_color_override("font_color", COL_RED)
		elif st == "stalled":
			l.add_theme_color_override("font_color", Color(0.8, 0.75, 0.5))
		row.add_child(l)
		var rm := Button.new()
		rm.text = "Remove"
		var rid: int = int(v["id"])
		rm.pressed.connect(func(): remove_requested.emit(rid))
		row.add_child(rm)
		box.add_child(row)

func _ship_button() -> void:
	var price := int(main.balance.get("ship_price", 0))
	var cap := int(main.balance.get("ship_cap", 0))
	box.add_child(HSeparator.new())
	var b := Button.new()
	b.text = "Buy a ship (%d cr)" % price
	var reason := ""
	if main.ships >= cap:
		reason = "Ship limit reached (%d)." % cap
	elif main.cash < price:
		reason = "Not enough credits."
	b.disabled = reason != ""
	b.tooltip_text = reason
	b.pressed.connect(func(): buy_ship_requested.emit())
	box.add_child(b)
	if reason != "":
		var n := _label(reason)
		n.add_theme_color_override("font_color", Color(1.0, 0.6, 0.5))
		box.add_child(n)
	box.add_child(_label("Ships: %d, free: %d" % [main.ships, main.free_ships()]))

func _label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(290, 0)
	return l

func _txt(v) -> String:
	if v == null:
		return "UNKNOWN"
	return str(v).capitalize() if str(v) != "UNKNOWN" else "UNKNOWN"

## Vertical rating bar: 5 stacked lines, bottom first lit, 5 lit = full storage.
class RatingBar extends Control:
	var level: int = 0
	func _init() -> void:
		custom_minimum_size = Vector2(16, 40)
	func _draw() -> void:
		for i in 5:
			var y := size.y - 4.0 - float(i) * 8.0
			var col := Color(1.0, 0.85, 0.35) if i < level else Color(0.25, 0.25, 0.3)
			draw_line(Vector2(1, y), Vector2(size.x - 1, y), col, 3.0)
