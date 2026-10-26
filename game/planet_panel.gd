extends PanelContainer
## T04: read-only planet panel: abundance, shortage, prices per commodity.
## Reads a planet dictionary from data/planets.json defensively; unknown fields are ignored.
## UNKNOWN values are shown as text, never replaced with invented numbers.

var title: Label
var body: Label
var buy_button: Button
var buy_note: Label
var sells_ships: bool = false  # T28: this planet offers a ship
var ship_price: int = 0
var ship_cap: int = 0
var ships: int = 0
var cash: int = 0

var trade_box: VBoxContainer  # T06: buy/sell rows and the Send ship button, rebuilt on refresh

signal buy_ship_requested
signal trade_requested(commodity: String, action: String)  # action: buy1 | buymax | sellall
signal send_requested

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	position = Vector2(12, 56)
	custom_minimum_size = Vector2(260, 0)
	var box := VBoxContainer.new()
	add_child(box)
	title = Label.new()
	box.add_child(title)
	body = Label.new()
	box.add_child(body)
	buy_button = Button.new()
	buy_button.pressed.connect(func(): buy_ship_requested.emit())
	box.add_child(buy_button)
	buy_note = Label.new()
	buy_note.add_theme_color_override("font_color", Color(1.0, 0.6, 0.5))
	box.add_child(buy_note)
	trade_box = VBoxContainer.new()
	box.add_child(trade_box)
	visible = false
	_refresh_buy()

## T28: set whether the shown planet sells ships, plus the numbers for the button.
func set_ship_offer(sells: bool, price: int, count: int, cap: int, cash_now: int) -> void:
	sells_ships = sells
	ship_price = price
	ships = count
	ship_cap = cap
	cash = cash_now
	_refresh_buy()

func _refresh_buy() -> void:
	buy_button.visible = sells_ships
	buy_note.visible = false
	if not sells_ships:
		return
	buy_button.text = "Buy a ship (%d cr)" % ship_price
	var reason := ""
	if ships >= ship_cap:
		reason = "Ship limit reached (%d)." % ship_cap
	elif cash < ship_price:
		reason = "Not enough credits."
	buy_button.disabled = reason != ""
	buy_button.tooltip_text = reason
	buy_note.text = reason
	buy_note.visible = reason != ""
	size = Vector2.ZERO

## T06: rebuild trade controls. rows from trade.gd rows(); send = {show, reason, cost}.
func set_trade(rows: Array, send: Dictionary) -> void:
	for child in trade_box.get_children():
		trade_box.remove_child(child)
		child.queue_free()
	for r in rows:
		var c: String = r["commodity"]
		var line := Label.new()
		line.text = "%s (held %d)" % [c.capitalize(), r["held"]]
		trade_box.add_child(line)
		var btns := HBoxContainer.new()
		trade_box.add_child(btns)
		var reasons: PackedStringArray = []
		if r["buy"] >= 0:
			_trade_button(btns, "Buy 1 (%d cr)" % r["buy"], r["buy_reason"] != "" or r["max_buy"] < 1, r["buy_reason"], func(): trade_requested.emit(c, "buy1"))
			_trade_button(btns, "Buy max (%d)" % r["max_buy"], r["buy_reason"] != "" or r["max_buy"] < 1, r["buy_reason"], func(): trade_requested.emit(c, "buymax"))
			if r["buy_reason"] != "":
				reasons.append(r["buy_reason"])
		if r["sell"] >= 0:
			_trade_button(btns, "Sell all (%d cr each)" % r["sell"], r["sell_reason"] != "", r["sell_reason"], func(): trade_requested.emit(c, "sellall"))
			if r["sell_reason"] != "" and not reasons.has(r["sell_reason"]):
				reasons.append(r["sell_reason"])
		if not reasons.is_empty():
			var note := Label.new()
			note.text = " ".join(reasons)
			note.add_theme_color_override("font_color", Color(1.0, 0.6, 0.5))
			trade_box.add_child(note)
	if send.get("show", false):
		var b := Button.new()
		b.text = "Send ship here (%d cr)" % send.get("cost", 0)
		b.disabled = send.get("reason", "") != ""
		b.tooltip_text = send.get("reason", "")
		b.pressed.connect(func(): send_requested.emit())
		trade_box.add_child(b)
		if b.disabled:
			var n := Label.new()
			n.text = send["reason"]
			n.add_theme_color_override("font_color", Color(1.0, 0.6, 0.5))
			trade_box.add_child(n)
	size = Vector2.ZERO

func _trade_button(parent: Control, text: String, off: bool, reason: String, on_press: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.disabled = off
	b.tooltip_text = reason if off else ""
	b.pressed.connect(on_press)
	parent.add_child(b)

func show_planet(p: Dictionary, commodities: Array) -> void:
	title.text = str(p.get("name", p.get("id", "?")))
	var lines: PackedStringArray = []
	lines.append("Abundant: " + _txt(p.get("abundant")))
	lines.append("Shortage: " + _txt(p.get("scarce")))
	lines.append("")
	lines.append("Prices:")
	var prices = p.get("base_prices")
	if typeof(prices) != TYPE_DICTIONARY:
		lines.append("  " + _txt(prices))
	else:
		for c in commodities:
			var buy = prices.get(str(c) + "_buy")
			var sell = prices.get(str(c) + "_sell")
			var parts: PackedStringArray = []
			if buy != null:
				parts.append("buy " + str(buy))
			if sell != null:
				parts.append("sell " + str(sell))
			if parts.is_empty():
				continue
			lines.append("  %s: %s" % [str(c).capitalize(), ", ".join(parts)])
	body.text = "\n".join(lines)
	size = Vector2.ZERO
	visible = true

func _txt(v) -> String:
	if v == null:
		return "UNKNOWN"
	return str(v).capitalize() if str(v) != "UNKNOWN" else "UNKNOWN"
