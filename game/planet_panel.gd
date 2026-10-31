extends PanelContainer
const StoryText := preload("res://game/story_text.gd")
## T04 / T68: planet panel. Per commodity a row: name, prices, order status and Buy / Sell toggles
## (standing local orders, no ship needed). Company storage rows (once established) have a 5-line
## bar and "Send to..." (creates a one-way route to another planet's storage). Then connections.
## Content is rebuilt on demand (planet click, any route change, cycle end), never per frame.
## Reads everything from main (set via setup()). Unknown values are shown as text, never invented.

signal buy_ship_requested
signal order_requested(commodity: String, role: String)  # role: "buy" or "sell" (toggles the local order)
signal send_requested(commodity: String)  # "Send to..." on a storage row
signal remove_requested(route_id: int)

var COL_LIT: Color = Ui.col("star_warm")
var COL_DIM: Color = Ui.col("panel_300")
var COL_RED: Color = Ui.col("signal_bad")

var main: Control
var planet_index: int = -1
var selected_route: int = -1  # T65: connection picked by clicking its line
var box: VBoxContainer

func setup(m: Control) -> void:
	main = m

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	position = Vector2(76, 56)  # right of the icon rail
	custom_minimum_size = Vector2(320, 0)
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	Ui.scroll_wrap(self, box, 56.0 + 12.0)  # long panels scroll instead of leaving the window
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
	_header(p)
	box.add_child(_label("Abundant: %s.  Shortage: %s." % [_txt(p.get("abundant")), _txt(p.get("scarce"))]))
	var unhappy: float = main.shield.unhappiness(planet_index)  # T101: only planets bought after the shield
	if unhappy > 0.0:  # FALLBACK: no story id yet (PLANET_UNHAPPY); plain text until the story designer adds it
		box.add_child(_label(StoryText.get_or("PLANET_UNHAPPY", "Resident unhappiness: {value}", {"value": "%d%%" % roundi(unhappy * 100.0)})))
	var pend: Dictionary = main.pending
	if not pend.is_empty():
		var pl := _label("Sending %s from %s. Click the destination planet." % [
			pend["c"], main.planet_name(int(pend["planet"]))])
		pl.theme_type_variation = "LabelAccent"
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
	_space_section()
	_connections()
	_ship_button()
	size = Vector2.ZERO

## Title, subtitle, planet thumbnails, Main resources row.
func _header(p: Dictionary) -> void:
	var title := Label.new()
	title.text = str(p.get("name", p.get("id", "?")))
	title.theme_type_variation = "LabelTitle"
	box.add_child(title)
	if main.systems_in_game() > 1:  # T85: system name once more than one system exists
		var sys_l := _label(main.Systems.name_of(int(p.get("system", 1))))
		sys_l.theme_type_variation = "LabelCaption"
		sys_l.text = sys_l.text.to_upper()
		box.add_child(sys_l)
	if str(p.get("desc", "")) != "":
		var d := _label(str(p["desc"]))
		d.theme_type_variation = "LabelSmall"
		box.add_child(d)
	var thumbs := HBoxContainer.new()
	thumbs.add_theme_constant_override("separation", 8)
	var sid: int = int(p.get("system", 1))
	for i in main.map.planets.size():
		var q: Dictionary = main.map.planets[i]
		if int(q.get("system", 1)) != sid:
			continue
		var t := Thumb.new()
		t.planet = q
		t.selected = i == planet_index
		t.tooltip_text = str(q.get("name", q.get("id", "?")))
		var idx: int = i
		t.pressed.connect(func(): main._on_planet_clicked(idx))
		thumbs.add_child(t)
	box.add_child(thumbs)
	var prices = p.get("base_prices")
	if typeof(prices) == TYPE_DICTIONARY:
		var cap := Label.new()
		cap.text = StoryText.get_or("LBL_MAIN_RESOURCES", "Main resources").to_upper()
		cap.theme_type_variation = "LabelCaption"
		box.add_child(cap)
		var res := HBoxContainer.new()
		res.add_theme_constant_override("separation", 16)
		for c in main.commodities:
			var v = prices.get(str(c) + "_sell")
			if v == null:
				continue
			var item := HBoxContainer.new()
			item.add_theme_constant_override("separation", 6)
			var ic := TextureRect.new()
			ic.texture = Ui.icon(str(c))
			ic.custom_minimum_size = Vector2(18, 18)
			ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			var cc := Ui.col("commodity_" + str(c))
			ic.modulate = cc if cc != Color.WHITE else Ui.col("ink")
			item.add_child(ic)
			var n := Label.new()
			n.text = str(v)
			n.theme_type_variation = "LabelNumber"
			item.add_child(n)
			res.add_child(item)
		box.add_child(res)

func _row(c: String, prices: Dictionary, pend: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var n := Label.new()
	n.text = c.capitalize()
	if Ui.col("commodity_" + str(c)) != Color.WHITE:
		n.add_theme_color_override("font_color", Ui.col("commodity_" + str(c)))  # Energy amber, Food green
	info.add_child(n)
	var buy = prices.get(c + "_buy")
	var sell = prices.get(c + "_sell")
	var t := Label.new()
	t.text = "%s: %s   %s: %s" % [StoryText.get_text("LBL_BUY_PRICE"), _price(buy), StoryText.get_text("LBL_SELL_PRICE"), _price(sell)]
	t.theme_type_variation = "LabelSmall"
	info.add_child(t)
	if main.has_skill("B1"):  # Market Ledger: recent sell prices
		var h := Label.new()
		h.text = main.price_history_line(planet_index, c)
		h.theme_type_variation = "LabelSmall"
		info.add_child(h)
	if main.has_skill("B3"):  # Price Whisper: the prices the next cycle starts with
		var nb: int = main.trade.price(planet_index, c + "_buy", true)
		var ns: int = main.trade.price(planet_index, c + "_sell", true)
		if nb >= 0 and ns >= 0:
			var nx := Label.new()
			nx.text = StoryText.get_text("LBL_NEXT_PRICE", {"buy": nb, "sell": ns})
			nx.theme_type_variation = "LabelSmall"
			info.add_child(nx)
	for role in ["buy", "sell"]:
		if main.engine.local_on(planet_index, c, role):
			var st := Label.new()
			st.text = "%s order: %s" % [role.capitalize(), main.engine.local_state(planet_index, c, role)]
			st.theme_type_variation = "LabelAccent"
			info.add_child(st)
	row.add_child(info)
	for role in ["buy", "sell"]:
		var b := Button.new()
		var price = buy if role == "buy" else sell
		var on: bool = main.engine.local_on(planet_index, c, role)
		b.toggle_mode = true
		b.button_pressed = on
		b.text = StoryText.get_text("BTN_BUY" if role == "buy" else "BTN_SELL") + (": on" if on else "")
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
	title.text = StoryText.get_text("LBL_COMPANY_STORAGE")
	title.theme_type_variation = "LabelStrong"
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
		send.theme_type_variation = "ButtonSmall"
		var sending: bool = not main.pending.is_empty() and main.pending["planet"] == planet_index and main.pending["c"] == str(c)
		send.text = StoryText.get_text("BTN_SEND") + ("*" if sending else "")
		send.tooltip_text = "Move this stock to another planet's storage with a ship."
		var cc: String = str(c)
		send.pressed.connect(func(): send_requested.emit(cc))
		row.add_child(send)
		box.add_child(row)

## T85: Space Storage of this planet's system (skill A1): stock per commodity, no orders on it.
func _space_section() -> void:
	var sid: int = int(main.map.planets[planet_index].get("system", 1))
	if not main.space_post_open(sid):
		return
	var key: String = main.storage.system_key(sid)
	box.add_child(HSeparator.new())
	var title := Label.new()
	title.text = StoryText.get_text("SS_POST_NAME")
	title.theme_type_variation = "LabelStrong"
	box.add_child(title)
	var d := _label(StoryText.get_text("SS_POST_DESC"))
	d.theme_type_variation = "LabelSmall"
	box.add_child(d)
	var cap: int = main.storage.capacity_of(key)
	for c in main.commodities:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var bar := RatingBar.new()
		bar.level = main.storage.rating(key, str(c))
		row.add_child(bar)
		var l := Label.new()
		l.text = "%s  %d/%d" % [str(c).capitalize(), main.storage.amount(key, str(c)), cap]
		row.add_child(l)
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
		l.theme_type_variation = "LabelAccent"
		box.add_child(l)
		var rm := Button.new()
		rm.theme_type_variation = "ButtonDanger"
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
		var lane_n: int = main.engine.lane_count(int(v["a"]), int(v["b"]), str(v["c"]))
		if lane_n > 1:  # T87
			l.text += " " + "%s %d/%d" % [StoryText.get_text("LBL_LANE_SHIP"), main.engine.lane_index(v), lane_n]
		if st != "running" and str(v["reason"]) != "":
			l.text += "\n" + str(v["reason"])
		elif st == "running":
			var up: int = main.engine.upkeep_part()
			var trip: int = main.engine.trip_part()
			var paying: bool = int(v["net"]) < 0
			l.text += "\n  %s: -%d\n  %s: -%d\n  %s: %+d/cycle" % [
				StoryText.get_text("LBL_TRIP_COST"), trip if paying else 0,
				StoryText.get_text("LBL_SHIP_UPKEEP"), up if paying else 0,
				StoryText.get_text("LBL_NET"), int(v["net"])]
		if st == "blocked":
			l.theme_type_variation = "LabelBad"
		elif st == "stalled":
			l.theme_type_variation = "LabelWarn"
		row.add_child(l)
		var rm := Button.new()
		rm.theme_type_variation = "ButtonDanger"
		rm.text = StoryText.get_text("BTN_REMOVE")
		var rid: int = int(v["id"])
		rm.pressed.connect(func(): remove_requested.emit(rid))
		row.add_child(rm)
		box.add_child(row)

func _ship_button() -> void:
	var price := int(main.balance.get("ship_price", 0))
	var cap := int(main.balance.get("ship_cap", 0))
	box.add_child(HSeparator.new())
	var b := Ui.primary_button("Buy a ship (%d cr)" % price, "ship")
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
		n.theme_type_variation = "LabelBad"
		box.add_child(n)
	box.add_child(_label("Ships: %d, free: %d" % [main.ships, main.free_ships()]))

func _label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(288, 0)
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
			var col: Color = Ui.col("star_warm") if i < level else Ui.col("panel_300")
			draw_line(Vector2(1, y), Vector2(size.x - 1, y), col, 3.0)

## Round planet thumbnail. Uses art/textures/ui/ui_thumb_<type>.png when present, else a plain disc.
class Thumb extends Control:
	signal pressed
	var planet: Dictionary = {}
	var selected := false
	var tex: Texture2D
	func _ready() -> void:
		custom_minimum_size = Vector2(40, 40)
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tex = Ui.ui_texture("ui_thumb_%s" % str(planet.get("type", "")).to_lower())
		mouse_entered.connect(func(): _hover = true; queue_redraw())
		mouse_exited.connect(func(): _hover = false; queue_redraw())
	var _hover := false
	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.5 - 3.0
		if tex != null:
			draw_texture_rect(tex, Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0), false)
		else:
			var cc := Ui.col("commodity_" + str(planet.get("abundant", "")))
			draw_circle(c, r, (cc if cc != Color.WHITE else Ui.col("ink_muted")).darkened(0.35))
		draw_arc(c, r + 1.0, 0.0, TAU, 40, Ui.col("star_warm") if selected else Color(1, 1, 1, 0.22), 2.0 if selected else 1.0, true)
		if _hover:  # the shared clickable cue: a warm outline
			draw_arc(c, r + 2.0, 0.0, TAU, 40, Ui.col("star_warm"), 2.0, true)
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit()
			accept_event()
