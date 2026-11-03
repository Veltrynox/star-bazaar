extends PanelContainer
const StoryText := preload("res://game/story_text.gd")
## T04 / T68: planet panel. Per commodity a row: name, prices, order status and Buy / Sell toggles
## (standing local orders, no ship needed). Company storage rows (once established) have a 5-line
## bar and "Send to..." (creates a one-way route to another planet's storage; it buys a ship first when none is
## free, so there is no separate Buy ship button). Then connections: a row per route, a row per ship.
## Content is rebuilt on demand (planet click, any route change, cycle end), never per frame.
## Reads everything from main (set via setup()). Unknown values are shown as text, never invented.

const RouteLineScript := preload("res://game/route_line.gd")
## Buy and Send share one size so they line up (Buy sits on the order row, Send on the storage row).
const ACTION_BTN_MIN := Vector2(104, 28)
signal salvage_requested(commodity: String)  # N5
signal order_requested(commodity: String, role: String)  # role: "buy" or "sell" (toggles the local order)
signal send_requested(commodity: String)  # "Send to..." on a storage row
signal buy_send_requested(commodity: String)  # Buy toggle on a resource row: standing buy order only
signal remove_requested(route_id: int)

var COL_LIT: Color = Ui.col("star_warm")
var COL_DIM: Color = Ui.col("panel_300")
var COL_RED: Color = Ui.col("signal_bad")

var main: Control
var planet_index: int = -1
var split_open: String = ""  # commodity whose split bar is open ("" = none)
var _split_bar: Control = null
var _split_tags: Dictionary = {}  # lane destination -> its "Split 60%" tag label
var selected_route: int = -1  # T65: connection picked by clicking its line
var box: VBoxContainer

func setup(m: Control) -> void:
	main = m

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	position = Vector2(76, 76)  # right of the icon rail, below the top bar
	custom_minimum_size = Vector2(320, 0)
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	Ui.scroll_wrap(self, box, 76.0 + 70.0)  # clear of the top bar and the key hints  # long panels scroll instead of leaving the window
	visible = false

func show_planet(index: int, route_id: int = -1) -> void:
	if index != planet_index:
		split_open = ""
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
	_split_bar = null
	_split_tags = {}
	var p: Dictionary = main.map.planets[planet_index]
	_header(p)
	if main.second_lane_planet == planet_index:  # N11: the first sale in system 2 happened here
		var sl := _label("%s: %s" % [StoryText.get_or("TITLE_SECOND_LANE", "Cross-system trader"), StoryText.get_or("NOTE_SECOND_LANE", "Your first sale here crossed the system line.")])
		sl.name = "SecondLaneNote"
		sl.theme_type_variation = "LabelAccent"
		box.add_child(sl)
	var unhappy: float = main.shield.unhappiness(planet_index)  # T101: only planets bought after the shield
	if unhappy > 0.0:
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
	var prices = p.get("base_prices")
	for c in main.commodities:
		var pd: Dictionary = prices if typeof(prices) == TYPE_DICTIONARY else {}
		if pd.get(str(c) + "_buy") == null and pd.get(str(c) + "_sell") == null:
			continue  # a good this planet does not trade has no row
		box.add_child(_row(str(c), prices if typeof(prices) == TYPE_DICTIONARY else {}, pend))
	_storage_section()
	_space_section()
	_connections()
	size = Vector2.ZERO

## Title, subtitle, description, planet thumbnails.
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
	if main.DeadWorlds.is_dead(p) and main.engine.dead_locked.has(planet_index):  # not open before dead_unlock_cycle
		var ll := _label(StoryText.get_or("PLANET_DEAD_LOCKED", "Opens at cycle {n}.", {"n": main.dead_unlock_cycle()}))
		ll.name = "DeadLockedLine"
		ll.theme_type_variation = "LabelAccent"
		box.add_child(ll)
	elif main.DeadWorlds.is_dead(p):  # dead world: one danger line
		var dl := _label(StoryText.get_or("PLANET_DANGER", "Danger: {value} of {max}", {"value": main.danger_of(planet_index), "max": main.dead.max_danger()}))
		dl.name = "DangerLine"
		dl.theme_type_variation = "LabelAccent"
		box.add_child(dl)
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

func _row(c: String, prices: Dictionary, pend: Dictionary) -> Control:
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 2)
	# Lane 1: icon, name, compact prices. Lane 2: Buy, Send, Sell (and Salvage when it applies).
	var row := HBoxContainer.new()
	wrap.add_child(row)
	row.add_theme_constant_override("separation", 6)
	row.add_child(Ui.good_icon(c, 18))
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 0)
	var n := Label.new()
	n.text = Ui.good_name(c)
	n.custom_minimum_size = Vector2(70, 0)  # the full good name always shows; the small prices give it room
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if Ui.commodity_col(str(c)) != Color.WHITE:
		n.add_theme_color_override("font_color", Ui.commodity_col(str(c)))  # Energy amber, Food green
	row.add_child(n)
	var buy = prices.get(c + "_buy")
	var sell = prices.get(c + "_sell")
	for a in main.events.active:  # P1: a price event on this row shows its direction and the cycles it has left
		if str(a["kind"]) in ["up", "down"] and int(a["planet"]) == planet_index and str(a["c"]) == str(c):
			var ev := Label.new()
			ev.name = "PriceEvent_" + str(c)
			var arrow := "↑" if str(a["kind"]) == "up" else "↓"
			ev.text = StoryText.get_or("LBL_PRICE_EVENT", "{arrow} Event, {cycles} cycles left", {"arrow": arrow, "cycles": int(a["left"])})
			ev.theme_type_variation = "LabelAccent"
			row.add_child(ev)
	if main.has_skill("B3"):  # Price Whisper: best partner and the prices the next cycle starts with
		var bpl: String = main.best_partner_line(planet_index, c)
		if bpl != "":
			var bl := Label.new()
			bl.text = bpl
			bl.theme_type_variation = "LabelSmall"
			info.add_child(bl)
		var nb: int = main.trade.price(planet_index, c + "_buy", true)
		var ns: int = main.trade.price(planet_index, c + "_sell", true)
		if nb >= 0 and ns >= 0:
			var nx := Label.new()
			nx.text = StoryText.get_text("LBL_NEXT_PRICE", {"buy": nb, "sell": ns})
			nx.theme_type_variation = "LabelSmall"
			info.add_child(nx)
	var salv: String = main.engine.salvage_reason(planet_index, c)
	if salv != "":  # N5: stuck stock can be sold off for a share of the Sell price
		var so: Dictionary = main.engine.salvage_offer(planet_index, c)
		var sl := Label.new()
		sl.name = "Salvage_" + str(c)
		if salv == "full":
			sl.text = StoryText.get_or("LBL_SALVAGE_STORAGE_FULL", "Salvage: {n} now (storage full). Sell order pays {m}.", {"n": so["n"], "m": so["m"]})
		else:
			sl.text = StoryText.get_or("LBL_SALVAGE_NO_BUYER", "Salvage: {n} now (no buyer on your lanes). Sell order pays {m}.", {"n": so["n"], "m": so["m"]})
		sl.theme_type_variation = "LabelAccent"
		info.add_child(sl)
	for role in ["buy", "sell"]:
		if main.engine.local_on(planet_index, c, role):
			var st := Label.new()
			st.text = "%s order: %s" % [role.capitalize(), main.engine.local_state(planet_index, c, role)]
			st.theme_type_variation = "LabelAccent"
			info.add_child(st)
	var mp: Dictionary = main.engine.mixed_preview(planet_index)
	if mp.has(c):
		var ml := Label.new()
		var pct: float = float(mp[c]["pct"])
		ml.text = StoryText.get_or("LBL_MIXED_LOAD", "Mixed load +{n}% (max {cap} credits)", {"n": str(int(pct)) if is_equal_approx(pct, floorf(pct)) else str(pct), "cap": int(main.balance.get("bundle_bonus_cap", 0))})
		ml.name = "MixedLoadLabel"
		ml.theme_type_variation = "LabelAccent"
		info.add_child(ml)
	wrap.add_child(info)
	var acts := HBoxContainer.new()
	acts.add_theme_constant_override("separation", 6)
	# One combined action replaces the separate Buy button: it buys here every cycle and sends the goods on a route.
	var sell_on: bool = main.engine.local_on(planet_index, c, "sell")
	var locked: bool = not main.system_trade_open(planet_index)
	var lock_tip: String = main.trade_locked_reason()
	var sell_price = sell
	var sb := Button.new()
	sb.name = "SellButton_" + str(c)
	sb.toggle_mode = true
	sb.button_pressed = sell_on
	sb.text = StoryText.get_text("BTN_SELL") + (" " + _price(sell_price) if sell_price != null else "") + (": on" if sell_on else "")
	sb.icon = Ui.icon("cash")  # the price is on the button
	sb.expand_icon = true
	sb.disabled = sell_price == null
	var sell_tip: String = StoryText.get_or("LBL_SELL_PRICE", "Sell price") + ": " + _price(sell_price)
	sb.tooltip_text = "Not traded here." if sell_price == null else (sell_tip + ". " + ("Standing sell order. Press to stop." if sell_on else "Standing sell order each cycle."))
	if locked:
		sb.disabled = true
		sb.tooltip_text = lock_tip
	sb.pressed.connect(func(): order_requested.emit(c, "sell"))
	sb.theme_type_variation = "ButtonSmall"
	var salvage_btn: Button = null
	if salv != "":
		var sv := Button.new()
		sv.name = "SalvageButton_" + str(c)
		sv.theme_type_variation = "ButtonSmall"
		sv.text = StoryText.get_or("BTN_SALVAGE", "Salvage")
		sv.pressed.connect(func(): salvage_requested.emit(c))
		salvage_btn = sv
	var buy_on: bool = main.engine.local_on(planet_index, c, "buy")
	var bs := Button.new()
	bs.theme_type_variation = "ButtonSmall"
	bs.custom_minimum_size = ACTION_BTN_MIN
	bs.toggle_mode = true
	bs.button_pressed = buy_on
	bs.text = StoryText.get_or("BTN_STOP_BUY", "Stop buying") if buy_on else (StoryText.get_text("BTN_BUY") + (" " + _price(buy) if buy != null else ""))
	bs.icon = Ui.icon("cash")  # the price is on the button
	bs.expand_icon = true
	bs.disabled = buy == null
	var buy_tip: String = StoryText.get_or("LBL_BUY_PRICE", "Buy price") + ": " + _price(buy)
	bs.tooltip_text = "Not traded here." if buy == null else (buy_tip + ". " + ("Standing buy order. Press to stop." if buy_on else "Standing buy order each cycle."))
	if locked:
		bs.disabled = true
		bs.tooltip_text = lock_tip
	bs.name = "BuyButton_" + str(c)
	bs.pressed.connect(func(): buy_send_requested.emit(c))
	acts.add_child(bs)
	acts.add_child(sb)
	if salvage_btn != null:
		acts.add_child(salvage_btn)
	wrap.add_child(acts)
	return wrap

## A missing price is a data gap (planets.json), shown as text, never invented.
func _price(v) -> String:
	return str(v) if v != null else "\u2013"  # compact: no unit, no data shown as a dash

## T65: company storage. T134: shown from the start (zero stock) so "Send to..." can plan a route at once.
func _storage_section() -> void:
	var key: String = main.storage.planet_key(planet_index)
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
		row.add_child(Ui.good_icon(str(c), 16))
		var l := Label.new()
		l.text = "%s  %d/%d" % [Ui.good_name(str(c)), main.storage.amount(key, str(c)), cap]
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		# Send sits beside the storage numbers of its good
		var pend: Dictionary = main.pending
		var sd := Button.new()
		sd.theme_type_variation = "ButtonSmall"
		sd.custom_minimum_size = ACTION_BTN_MIN
		var sending: bool = not pend.is_empty() and int(pend["planet"]) == planet_index and str(pend["c"]) == str(c)
		sd.text = StoryText.get_text("BTN_SEND") + ("*" if sending else "")
		sd.tooltip_text = "Move this stock to another planet's storage with a ship."
		if not main.system_trade_open(planet_index):
			sd.disabled = true
			sd.tooltip_text = main.trade_locked_reason()
		sd.name = "SendButton_" + str(c)
		var cc: String = str(c)
		sd.pressed.connect(func(): send_requested.emit(cc))
		row.add_child(sd)
		var nc := next_cycle_label(main, key, str(c))
		if nc != null:
			row.add_child(nc)  # right end of the same row
		box.add_child(row)
		if main.split_targets(planet_index, str(c)).size() >= 2:  # N2: two lanes with ships can be split
			box.add_child(_split_row(str(c)))
			if split_open == str(c):
				box.add_child(_split_bar_for(str(c)))
		elif split_open == str(c):
			split_open = ""

## Owner 2026-11-03: small label at the right end of a storage row, "Next cycle: +12 -5 = 47" (in green, out red).
## Null when nothing moves. Read-only: uses RouteEngine.project_storage.
static func next_cycle_label(main_node: Control, key: String, c: String) -> Control:
	var pr: Dictionary = main_node.engine.project_storage(key, c, int(main_node.cash))
	var n_in := int(pr["in"])
	var n_out := int(pr["out"])
	if n_in <= 0 and n_out <= 0:
		return null
	var rt := RichTextLabel.new()
	rt.name = "NextCycle_" + c
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.scroll_active = false
	rt.autowrap_mode = TextServer.AUTOWRAP_OFF
	rt.size_flags_horizontal = Control.SIZE_SHRINK_END
	rt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rt.add_theme_font_size_override("normal_font_size", 12)
	rt.add_theme_color_override("default_color", Ui.col("ink_muted"))
	var good := "[color=#%s]%d[/color]" % [Ui.col("signal_good").to_html(false), n_in]
	var bad := "[color=#%s]%d[/color]" % [Ui.col("signal_bad").to_html(false), n_out]
	var t: String = StoryText.get_or("LBL_NEXT_CYCLE", "Next cycle: +{in} -{out} = {after}")
	rt.text = t.replace("{in}", good).replace("{out}", bad).replace("{after}", str(int(pr["after"])))
	return rt

## Split bar: the colour of the first (0) or second (1) lane of a split.
func _lane_colour(i: int) -> Color:
	return Ui.col("commodity_energy" if i == 0 else "commodity_food")

## Split bar: the "Split" toggle on a storage row with two lanes with ships.
func _split_row(c: String) -> Control:
	var row := HBoxContainer.new()
	row.name = "SplitRow"
	var b := Button.new()
	b.name = "SplitButton"
	b.theme_type_variation = "ButtonSmall"
	b.text = StoryText.get_or("BTN_SPLIT_BAR", "Split")
	b.toggle_mode = true
	b.button_pressed = split_open == c
	b.pressed.connect(func():
		split_open = "" if split_open == c else c
		if split_open == c and main.engine.lane_split(planet_index, int(main.split_pair(planet_index, c)[0]), c).is_empty():
			main.set_split_percent(planet_index, c, 50)  # the bar starts at 50/50
		rebuild())
	row.add_child(b)
	return row

## Split bar: "Ore 12/40", the two lane names with their shares, a slider with [-] and [+], Done and Stop split.
func _split_bar_for(c: String) -> Control:
	var pair: Array = main.split_pair(planet_index, c)
	var vb := VBoxContainer.new()
	vb.name = "SplitBar"
	vb.add_theme_constant_override("separation", 4)
	_split_bar = vb
	var key: String = main.storage.planet_key(planet_index)
	var head := _label("%s  %d/%d" % [Ui.good_name(c), main.storage.amount(key, c), main.storage.capacity_of(key)])
	head.theme_type_variation = "LabelSmall"
	vb.add_child(head)
	var names := HBoxContainer.new()
	var l1 := Label.new()
	l1.name = "SplitFirstLabel"
	l1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l1.clip_text = true
	l1.add_theme_color_override("font_color", _lane_colour(0))
	names.add_child(l1)
	var l2 := Label.new()
	l2.name = "SplitSecondLabel"
	l2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l2.clip_text = true
	l2.add_theme_color_override("font_color", _lane_colour(1))
	names.add_child(l2)
	vb.add_child(names)
	var ctl := HBoxContainer.new()
	ctl.add_theme_constant_override("separation", 6)
	var minus := Button.new()
	minus.name = "SplitMinus"
	minus.theme_type_variation = "ButtonSmall"
	minus.text = "\u2212"
	ctl.add_child(minus)
	var sl := HSlider.new()
	sl.name = "SplitSlider"
	sl.min_value = 10
	sl.max_value = 90
	sl.step = 1
	sl.value = main.split_percent(planet_index, c)
	sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sl.custom_minimum_size = Vector2(120, 20)
	ctl.add_child(sl)
	var plus := Button.new()
	plus.name = "SplitPlus"
	plus.theme_type_variation = "ButtonSmall"
	plus.text = "+"
	ctl.add_child(plus)
	vb.add_child(ctl)
	var acts := HBoxContainer.new()
	acts.add_theme_constant_override("separation", 8)
	var stop := Button.new()
	stop.name = "SplitStop"
	stop.theme_type_variation = "ButtonSmall"
	stop.text = StoryText.get_or("LBL_SPLIT_BAR_STOP", "Stop split")
	acts.add_child(stop)
	var done := Button.new()
	done.name = "SplitDone"
	done.theme_type_variation = "ButtonSmall"
	done.text = StoryText.get_or("BTN_SPLIT_DONE", "Done")
	acts.add_child(done)
	vb.add_child(acts)
	var n1: String = main.planet_name(int(pair[0]))
	var n2: String = main.planet_name(int(pair[1]))
	var refresh := func(v: float):
		l1.text = "%s %d%%" % [n1, int(v)]
		l2.text = "%d%% %s" % [100 - int(v), n2]
		_update_split_tags(c)
	refresh.call(sl.value)
	sl.value_changed.connect(func(v: float):
		main.set_split_percent(planet_index, c, int(v))
		refresh.call(float(main.split_percent(planet_index, c))))
	minus.pressed.connect(func(): sl.value = maxf(10.0, sl.value - 10.0))
	plus.pressed.connect(func(): sl.value = minf(90.0, sl.value + 10.0))
	stop.pressed.connect(func():
		main.clear_split(planet_index, c)
		split_open = ""
		rebuild())
	done.pressed.connect(func():
		split_open = ""
		rebuild())
	return vb

## Split bar: re-text the lane tags in place (the slider must not be rebuilt while it is dragged).
func _update_split_tags(c: String) -> void:
	for d in _split_tags:
		var t: Label = _split_tags[d]
		var sp: Dictionary = main.engine.lane_split(planet_index, int(d), c)
		if not sp.is_empty():
			t.text = StoryText.get_or("LBL_SPLIT_TAG", "Split {share}%", {"share": roundi(float(sp["share"]) * 100.0)})

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
		row.add_child(Ui.good_icon(str(c), 16))
		var l := Label.new()
		l.text = "%s  %d/%d" % [Ui.good_name(str(c)), main.storage.amount(key, str(c)), cap]
		row.add_child(l)
		box.add_child(row)

## Real minus sign and a plus on positive numbers (design pack).
func _signed(n: int) -> String:
	if n > 0:
		return "+%d" % n
	if n < 0:
		return "\u2212%d" % -n
	return "0"

## Connections as in the design pack: one row per route (to / from planet, net, click to open its costs), then one
## row per ship ("Ship k of N", status, its own Remove). Records of the same lane (same source, destination, goods)
## are the ships of one route.
func _connections() -> void:
	var list: Array = main.connections_at(planet_index)
	var lanes: Array = []  # [{first: record view, ships: [views]}] in order of first appearance
	for v in list:
		var key := "%d|%d|%s" % [int(v["a"]), int(v["b"]), str(v["c"])]
		var found := false
		for ln in lanes:
			if ln["key"] == key:
				ln["ships"].append(v)
				found = true
				break
		if not found:
			lanes.append({"key": key, "ships": [v]})
	var cap := Label.new()
	cap.text = StoryText.get_or("LBL_CONNECTIONS", "Connections").to_upper()
	cap.theme_type_variation = "LabelCaption"
	box.add_child(HSeparator.new())
	box.add_child(cap)
	if lanes.is_empty():
		var none := _label(StoryText.get_or("LBL_NO_ROUTES", "No routes yet."))
		none.theme_type_variation = "LabelSmall"
		box.add_child(none)
		selected_route = -1
		return
	var selected_ok := false
	for ln in lanes:
		var ships: Array = ln["ships"]
		var first: Dictionary = ships[0]
		var out: bool = int(first["a"]) == planet_index
		var other: String = main.planet_name(int(first["b"]) if out else int(first["a"]))
		var net := 0
		for s in ships:
			net += int(s["net"])
		var row := RouteRow.new()
		row.tooltip_text = StoryText.get_or("LBL_ROUTE_ROW_TIP", "Show this route's costs.")
		var ic := TextureRect.new()
		ic.texture = Ui.icon(str(first["c"]))
		ic.custom_minimum_size = Vector2(18, 18)
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var cc := Ui.commodity_col(str(first["c"]))
		ic.modulate = cc if cc != Color.WHITE else Ui.col("ink")
		row.add_child(ic)
		var l := Label.new()
		l.text = StoryText.get_or("LBL_ROUTE_TO" if out else "LBL_ROUTE_FROM", "To {planet}" if out else "From {planet}", {"planet": other})
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.clip_text = true
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(l)
		if out:
			var sp: Dictionary = main.engine.lane_split(planet_index, int(first["b"]), str(first["c"]))
			if not sp.is_empty():
				var pair: Array = main.split_pair(planet_index, str(first["c"]))
				var tag := Label.new()
				tag.name = "SplitTag"
				tag.theme_type_variation = "LabelSmall"
				tag.text = StoryText.get_or("LBL_SPLIT_TAG", "Split {share}%", {"share": roundi(float(sp["share"]) * 100.0)})
				tag.add_theme_color_override("font_color", _lane_colour(0 if not pair.is_empty() and int(pair[0]) == int(first["b"]) else 1))
				tag.mouse_filter = Control.MOUSE_FILTER_PASS
				tag.mouse_entered.connect(func(): if _split_bar != null: _split_bar.modulate = Color(1.4, 1.4, 1.4))
				tag.mouse_exited.connect(func(): if _split_bar != null: _split_bar.modulate = Color.WHITE)
				row.add_child(tag)
				if str(first["c"]) == split_open:
					_split_tags[int(first["b"])] = tag
		var nl := Label.new()
		nl.text = _signed(net)
		nl.theme_type_variation = "LabelGood" if net > 0 else ("LabelBad" if net < 0 else "LabelNumberMuted")
		nl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(nl)
		var first_id: int = int(first["id"])
		row.pressed.connect(func():
			selected_route = -1 if selected_route == first_id else first_id
			rebuild())
		box.add_child(row)
		if int(first["b"]) >= 0:
			box.add_child(_pays_line(int(first["b"]), str(first["c"])))
		for k in ships.size():
			var v: Dictionary = ships[k]
			box.add_child(_ship_row(v, k + 1, ships.size()))
			var mv: Dictionary = main.move_offer(int(v["id"])) if str(v["status"]) == "blocked" else {}
			if not mv.is_empty():
				box.add_child(_move_line(int(v["id"]), mv))
			if int(v["id"]) == selected_route:
				selected_ok = true
		if main.engine.lane_full(int(first["a"]), int(first["b"]), str(first["c"])):
			box.add_child(_upgrade_line(first))
		if selected_route == first_id or _lane_has(ships, selected_route):
			_route_detail(first)
	if not selected_ok:
		selected_route = -1

## T143: where the route's money lands. A route pays only when its destination has a standing Sell order for the goods.
## One control turns that order on (the existing local-order toggle at the destination).
func _pays_line(dest: int, c: String) -> Control:
	var on: bool = main.engine.local_on(dest, c, "sell")
	var row := HBoxContainer.new()
	row.name = "PaysLine"
	var l := Label.new()
	var state: String = StoryText.get_or("LBL_ORDER_ON", "on") if on else StoryText.get_or("LBL_ORDER_OFF", "off")
	l.text = StoryText.get_or("LBL_ROUTE_PAYS", "Pays when {planet} has a standing Sell order: {state}", {"planet": main.planet_name(dest), "state": state})
	l.theme_type_variation = "LabelSmall" if on else "LabelBad"
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(150, 0)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	if not on:
		var b := Button.new()
		b.name = "PaysSellButton"
		b.text = StoryText.get_text("BTN_SELL")
		b.disabled = main.engine.check_local(dest, c, "sell")["ok"] == false
		b.tooltip_text = StoryText.get_or("LBL_ROUTE_PAYS_TIP", "Turn on the Sell order at {planet}.", {"planet": main.planet_name(dest)}) if not b.disabled else StoryText.get_or("LBL_ROUTE_PAYS_NO", "Not traded there.")
		b.pressed.connect(func():
			var r: Dictionary = main.toggle_local(dest, c, "sell")
			if not r["ok"]:
				main.post_notice(str(r["reason"])))
		row.add_child(b)
	return row

## T147: shown only on a full lane (the caller checks engine.lane_full). Enable and tooltip come from
## main.can_upgrade_route; once the lane is level 2 it reads as taken.
func _upgrade_line(first: Dictionary) -> Control:
	var cost := int(main.balance.get("upgrade_cost", 0))
	var bonus_pct := roundi(float(main.balance.get("upgrade_margin_bonus", 0.0)) * 100.0)
	var row := HBoxContainer.new()
	row.name = "UpgradeLine"
	row.add_theme_constant_override("separation", 8)
	var l := Label.new()
	l.theme_type_variation = "LabelSmall"
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(150, 0)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if main.engine.lane_level(int(first["a"]), int(first["b"]), str(first["c"])) >= 2:
		l.name = "UpgradeRouteTaken"
		l.text = StoryText.get_or("LBL_ROUTE_UPGRADED", "Route upgraded: +{pct}% margin.", {"pct": bonus_pct})
		row.add_child(l)
		return row
	l.text = StoryText.get_or("LBL_ROUTE_UPGRADE_INFO", "Full lane. Upgrade: {cost} credits for +{pct}% margin.", {"cost": cost, "pct": bonus_pct})
	row.add_child(l)
	var rid: int = int(first["id"])
	var chk: Dictionary = main.can_upgrade_route(rid)
	var b := Button.new()
	b.name = "UpgradeRouteButton"
	b.text = StoryText.get_or("BTN_UPGRADE_ROUTE", "Upgrade route")
	b.disabled = not chk["ok"]
	b.tooltip_text = StoryText.get_or("LBL_ROUTE_UPGRADE_TIP", "Raise this lane's margin for {cost} credits.", {"cost": cost}) if chk["ok"] else str(chk["reason"])
	b.pressed.connect(func():
		var r: Dictionary = main.upgrade_route(rid)
		if not r["ok"]:
			main.post_notice(str(r["reason"])))
	row.add_child(b)
	return row

## P2: under a ship stranded by a closed planet. The player may press Move ship; nothing moves by itself.
func _move_line(id: int, offer: Dictionary) -> Control:
	var box_m := VBoxContainer.new()
	box_m.name = "MoveLine"
	box_m.add_theme_constant_override("separation", 4)
	var l := Label.new()
	l.name = "MoveOffer"
	l.theme_type_variation = "LabelSmall"
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.text = StoryText.get_or("LBL_BEST_OPEN_ROUTE", "Best open route: +{net} per cycle", {"net": int(offer["net"])})
	box_m.add_child(l)
	if bool(offer["setup_lost"]):
		var lost := Label.new()
		lost.name = "MoveSetupLost"
		lost.theme_type_variation = "LabelWarn"
		lost.text = StoryText.get_or("LBL_SETUP_LOST", "Setup lost")
		box_m.add_child(lost)
	var b := Button.new()
	b.name = "MoveShipButton"
	b.theme_type_variation = "ButtonSmall"
	b.text = StoryText.get_or("BTN_MOVE_SHIP", "Move ship")
	b.pressed.connect(func():
		var r: Dictionary = main.move_ship(id)
		if not r["ok"]:
			main.post_notice(str(r["reason"])))
	box_m.add_child(b)
	return box_m

func _lane_has(ships: Array, id: int) -> bool:
	for v in ships:
		if int(v["id"]) == id:
			return true
	return false

## One ship of a route: icon, "Ship k of N", status, Remove.
func _ship_row(v: Dictionary, k: int, n: int) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(12, 0)
	row.add_child(pad)
	var ic := TextureRect.new()
	ic.texture = Ui.icon("ship")
	ic.custom_minimum_size = Vector2(16, 16)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ic.modulate = Ui.col("ink_muted")
	row.add_child(ic)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_l := Label.new()
	name_l.text = StoryText.get_or("LBL_SHIP_K_OF_N", "Ship {k} of {n}", {"k": k, "n": n})
	info.add_child(name_l)
	var st: String = v["status"]
	var sl := Label.new()
	sl.theme_type_variation = "LabelSmall"
	sl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sl.custom_minimum_size = Vector2(150, 0)
	if st == "running":
		sl.text = StoryText.get_or("LBL_SHIP_RUNNING", "Running.")
	elif st == "stalled" or st == "waiting":
		sl.text = RouteLineScript.reason_text(st, str(v["reason"]))  # the route's real reason; Waiting for room only when waiting
		sl.theme_type_variation = "LabelWarn"
	else:
		sl.text = str(v["reason"]) if str(v["reason"]) != "" else st.capitalize()
		sl.theme_type_variation = "LabelBad"
	info.add_child(sl)
	row.add_child(info)
	var rm := Button.new()
	rm.theme_type_variation = "ButtonSmall"
	rm.text = StoryText.get_text("BTN_REMOVE")
	var rid: int = int(v["id"])
	rm.pressed.connect(func(): remove_requested.emit(rid))
	row.add_child(rm)
	return row

## Costs of the route picked in the list (same figures the game already used per connection).
func _route_detail(v: Dictionary) -> void:
	var st: String = v["status"]
	var l := _label("")
	l.theme_type_variation = "LabelSmall"
	if st != "running" and str(v["reason"]) != "":
		l.text = str(v["reason"])
	elif st == "running":
		var ri: int = main.engine.find_by_id(int(v["id"]))
		var rec = main.engine.routes[ri] if ri >= 0 else null
		var up: int = main.engine.upkeep_part(rec)
		var trip: int = main.engine.trip_part()
		var paying: bool = int(v["net"]) < 0
		l.text = "%s: \u2212%d\n%s: \u2212%d\n%s: %s / cycle" % [
			StoryText.get_text("LBL_TRIP_COST"), trip if paying else 0,
			StoryText.get_text("LBL_SHIP_UPKEEP"), up if paying else 0,
			StoryText.get_text("LBL_NET"), _signed(int(v["net"]))]
		var off: float = main.engine.offset_of(rec)
		if off > 0.0:  # one line: the detour round other planets or routes and what it adds to the upkeep
			l.text += "\n" + StoryText.get_or("ROUTE_OFFSET_MAINT", "Route detour +{offset}%: upkeep +{maint}%", {"offset": roundi(off * 100.0), "maint": roundi(float(main.balance.get("route_offset_maint_pct", 0.0)) * off * 100.0)})
	if l.text != "":
		box.add_child(l)

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

## A clickable route row: hover highlights it, click emits pressed.
class RouteRow extends HBoxContainer:
	signal pressed
	var _hover := false
	func _init() -> void:
		add_theme_constant_override("separation", 8)
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		custom_minimum_size = Vector2(0, 28)
		mouse_entered.connect(func(): _hover = true; queue_redraw())
		mouse_exited.connect(func(): _hover = false; queue_redraw())
	func _draw() -> void:
		if _hover:
			draw_rect(Rect2(Vector2(-4, 0), size + Vector2(8, 0)), Ui.col("panel_200"), true)
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit()
			accept_event()

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

## Round planet thumbnail. Uses art/ui/ui_thumb_<type>.png when present, else a plain disc.
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
			var cc := Ui.commodity_col(str(planet.get("abundant", "")))
			draw_circle(c, r, (cc if cc != Color.WHITE else Ui.col("ink_muted")).darkened(0.35))
		draw_arc(c, r + 1.0, 0.0, TAU, 40, Ui.col("star_warm") if selected else Color(1, 1, 1, 0.22), 2.0 if selected else 1.0, true)
		if _hover:  # the shared clickable cue: a warm outline
			draw_arc(c, r + 2.0, 0.0, TAU, 40, Ui.col("star_warm"), 2.0, true)
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit()
			accept_event()
