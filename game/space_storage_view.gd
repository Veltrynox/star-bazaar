extends PanelContainer
## Space Storage view for one system: capacity and one row per commodity (rating bar, name, amount/capacity).
## Opened by a click on the station (main.gd _on_station_clicked). Close button or Esc closes it.

const StoryText := preload("res://game/story_text.gd")
const PlanetPanel := preload("res://game/planet_panel.gd")
const RatingBar := PlanetPanel.RatingBar

signal closed

var main: Control
var system_id: int = -1
var box: VBoxContainer

func setup(main_node: Control) -> void:
	main = main_node
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Docked exactly where the planet panel sits (left of the map, right of the icon rail, below the top bar).
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	position = Vector2(76, 76)
	custom_minimum_size = Vector2(minf(320.0, get_viewport_rect().size.x - 76.0 - 12.0), 0)
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	Ui.scroll_wrap(self, box, 76.0 + 70.0)  # long views scroll instead of leaving the window, same reserve as the planet panel
	var sl = main.storage_link  # T171: the link block follows the engine's signals
	for sig in [sl.link_built, sl.link_removed, sl.link_state_changed, sl.link_collapsed, sl.link_orders_changed, sl.link_transferred]:
		sig.connect(_on_link_changed)

func open_for(sid: int) -> void:
	if sid != system_id:
		_dlg = ""  # a link dialog does not follow to another storage
	system_id = sid
	visible = true
	refresh()

func close_view() -> void:
	if visible:
		visible = false
		closed.emit()

func refresh() -> void:
	if not visible or main == null:
		return
	for ch in box.get_children():
		box.remove_child(ch)
		ch.queue_free()
	var head := HBoxContainer.new()
	box.add_child(head)
	var title := Label.new()
	title.text = StoryText.get_or("SS_POST_NAME", "Space Storage")
	title.theme_type_variation = "LabelTitle"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var close := Button.new()
	close.name = "CloseButton"
	close.text = StoryText.get_or("SS_BTN_CLOSE", "Close")
	close.pressed.connect(close_view)
	head.add_child(close)
	var sys := Label.new()
	sys.text = main.Systems.name_of(system_id)
	sys.theme_type_variation = "LabelCaption"
	box.add_child(sys)
	var key: String = main.storage.system_key(system_id)
	var cap: int = main.storage.capacity_of(key)
	var cl := Label.new()
	cl.text = StoryText.get_or("SS_LBL_CAPACITY", "Capacity: {cap} per commodity", {"cap": cap})
	box.add_child(cl)
	var rule := _wrapped(StoryText.get_or("SS_LBL_STOCK_RULE", "Goods stay until a recipe, link upkeep, Storage Link or a route you send from here takes them. Planet routes and Sells never draw on it."))
	rule.name = "StockRule"
	rule.add_theme_color_override("font_color", Ui.col("ink_muted"))
	box.add_child(rule)
	for c in main.commodities:
		if not Availability.feature("space_storage_stock_rows") or not Availability.good(str(c)):
			continue  # data/availability.json: only visible goods have a stock row
		var row := HBoxContainer.new()
		row.name = "Row_" + str(c)
		row.add_theme_constant_override("separation", 8)
		var bar := RatingBar.new()
		bar.level = main.storage.rating(key, str(c))
		row.add_child(bar)
		# T373 / owner rule 2026-11-12: the resource itself is the send button, as on planet cards (no separate Send to... button)
		var can_send: bool = main.engine.station_can_send(system_id, str(c))
		var sb := Button.new()
		sb.name = "Send_" + str(c)
		sb.theme_type_variation = "ButtonSmall"
		sb.icon = Ui.good_icon(str(c), 16).texture
		sb.expand_icon = false
		sb.add_theme_constant_override("icon_max_width", 16)
		var gc: Color = Ui.commodity_col(str(c)) if Ui.commodity_col(str(c)) != Color.WHITE else Ui.col("ink")  # the good keeps its own colour, as on planet tiles
		for st in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color", "icon_hover_pressed_color"]:
			sb.add_theme_color_override(st, gc)
		sb.add_theme_color_override("icon_disabled_color", Color(gc.r, gc.g, gc.b, 0.45))
		sb.alignment = HORIZONTAL_ALIGNMENT_LEFT
		sb.text = "%s  %d/%d" % [Ui.good_name(str(c)), main.storage.amount(key, str(c)), cap]
		sb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sb.disabled = not can_send
		sb.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if can_send else Control.CURSOR_ARROW
		sb.tooltip_text = (StoryText.get_or("SS_TIP_SEND", "Send this good from the Space Storage to a planet: click the planet on the map next.") if can_send else StoryText.get_or("SS_TIP_SEND_NONE", "Nothing to send: none in stock and none on its way.")) + "\n\n" + GoodInfo.block(str(c))
		sb.pressed.connect(_on_send.bind(str(c)))
		sb.gui_input.connect(func(ev: InputEvent) -> void:  # a right click sends too, the same gesture as on a planet tile
			if can_send and ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_RIGHT:
				_on_send(str(c)))
		row.add_child(sb)
		box.add_child(row)
	_routes_out()
	_fabric_rows()
	_build_blocks()
	size = Vector2.ZERO

## T373: Send to... pressed: the view gives way to the map and the next planet clicked becomes the destination (main.begin_station_send).
func _on_send(c: String) -> void:
	var r: Dictionary = main.begin_station_send(system_id, c)
	if not r["ok"]:
		main.post_notice_now(str(r["reason"]))
		return
	close_view()

## T373: the routes that start at this Space Storage, one row per ship with a Remove button (only shown when there are some).
func _routes_out() -> void:
	var mine: Array = []
	for rec in main.engine.routes:
		if main.engine.from_station(rec) and -int(rec["a"]) == system_id and Availability.good(str(rec["c"])):
			mine.append(rec)
	if mine.is_empty():
		return
	box.add_child(HSeparator.new())
	var t := Label.new()
	t.name = "RoutesOutTitle"
	t.text = StoryText.get_or("SS_LBL_ROUTES_OUT", "Sent out from here")
	t.theme_type_variation = "LabelStrong"
	box.add_child(t)
	for rec in mine:
		var id := int(rec["id"])
		var line := HBoxContainer.new()
		line.name = "RouteOut_%d" % id
		line.add_theme_constant_override("separation", 8)
		box.add_child(line)
		var ll := Label.new()
		ll.text = StoryText.get_or("SS_LBL_ROUTE_OUT_LINE", "{good} to {planet}, {n} / cycle", {"good": Ui.good_name(str(rec["c"])), "planet": main.planet_name(int(rec["b"])), "n": main.route_units(rec)})
		ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ll.custom_minimum_size = Vector2(190, 0)
		ll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(ll)
		var rb := Button.new()
		rb.name = "RouteOutRemove_%d" % id
		rb.theme_type_variation = "ButtonSmall"
		rb.text = StoryText.get_or("SS_BTN_ROUTE_REMOVE", "Remove")
		rb.pressed.connect(func(): main._remove_requested(id); refresh())
		line.add_child(rb)

## Fabric block, only in system 1 once MIN_1 is learned: build button with the cost, then the recipe and its status.
func _fabric_rows() -> void:
	if system_id != main.Fabric.SYSTEM or not Availability.workshop("fabric"):
		return
	var f = main.fabric
	var unrouted: Array = [] if f.built else main.fabric_inputs_unrouted()
	var head := Label.new()
	head.name = "FabricLine"
	head.theme_type_variation = "LabelCaption"
	head.text = StoryText.get_or("SS_FABRIC", "Fabric") + (": " + f.recipe_text() if Availability.good("plate") else "")  # the recipe names plate, dross, nullglass
	box.add_child(head)
	if not f.built:
		var b := Button.new()
		b.name = "FabricBuild"
		b.text = StoryText.get_or("SS_FABRIC_BUILD", "Build fabric ({cost} cr)", {"cost": f.build_cost()})
		b.disabled = not main.can_build_fabric()["ok"]
		b.pressed.connect(func(): main.build_fabric(); refresh())
		box.add_child(b)
	else:
		var st := Label.new()
		st.name = "FabricStatus"
		st.text = StoryText.get_or("FAB_MADE", "made {n} {good}", {"n": f.made, "good": Ui.good_name("plate").to_lower()}) if f.state == "running" else (Workshops.why_text(f.reason) if f.state == "stalled" else StoryText.get_or("FAB_READY", "ready"))
		box.add_child(st)
	var miss: Array = unrouted if not unrouted.is_empty() else _inputs_unreached(f)
	miss = Availability.visible_goods(miss)
	if not miss.is_empty():  # QA 2026-11-03: fabric can be built before its inputs have a route
		var ml := Label.new()
		ml.name = "FabricInputs"
		ml.theme_type_variation = "LabelCaption"
		ml.text = StoryText.get_or("SS_FABRIC_NO_INPUTS", "Missing inputs: {items}. Send them here from a dead world.", {"items": ", ".join(miss)})
		box.add_child(ml)
	if not Availability.feature("null_core"):
		return
	var cl := Label.new()  # Null Core: plate + nullglass, one per run
	cl.name = "CoreLine"
	cl.theme_type_variation = "LabelCaption"
	cl.text = StoryText.get_or("LBL_NULL_CORE", "Null Core") + ": " + f.core_recipe_text()
	box.add_child(cl)
	if f.core_made < f.core_max():
		var cb := Button.new()
		cb.name = "CoreBuild"
		cb.text = StoryText.get_or("SS_NULL_CORE_BUILD", "Build Null Core ({cost} cr)", {"cost": f.core_cost()})
		cb.disabled = not main.can_build_core()["ok"]
		cb.pressed.connect(func(): main.build_null_core(); refresh())
		box.add_child(cb)
	else:
		var cs := Label.new()
		cs.name = "CoreStatus"
		cs.text = StoryText.get_or("LBL_NULL_CORE_BUILT", "Null Core built (one per run).")
		box.add_child(cs)

## Build blocks of a cell, one function per block so a later one (portal between cells) sits beside the workshops.
func _build_blocks() -> void:
	_workshop_rows()
	_link_block()

## Workshops: the ones standing in THIS cell (recipe and status) and the visible, unbuilt ones as Build buttons.
## Each workshop is built once per run; once built it shows only in its own cell. Visibility is Availability.workshop.
func _workshop_rows() -> void:
	var ws: RefCounted = main.workshops
	var shown: Array = []
	for id in ws.IDS:
		if not Availability.workshop(str(id)):
			continue
		if ws.built[id] and not ws.stands_in(str(id), system_id):
			continue  # built in another cell
		shown.append(id)
	if shown.is_empty() or not main.station_systems.has(system_id):
		return
	box.add_child(HSeparator.new())
	var title := Label.new()
	title.name = "WorkshopTitle"
	title.text = StoryText.get_or("LBL_WORKSHOPS", "Workshops")
	title.theme_type_variation = "LabelStrong"
	box.add_child(title)
	for id in shown:
		var nm := StoryText.get_or("WS_" + str(id).to_upper() + "_NAME", str(id).capitalize())
		var head := _wrapped(nm)
		head.name = "Workshop_" + str(id)
		head.theme_type_variation = "LabelAccent"
		box.add_child(head)
		for g in ws.open_recipes(id):
			if not Availability.good(str(g)):
				continue  # a recipe row needs its crafted good visible
			var rl := _wrapped(ws.recipe_line(str(g)))
			rl.name = "WorkshopRecipe_" + str(g)
			rl.theme_type_variation = "LabelSmall"
			box.add_child(rl)
		if ws.built[id]:
			var line: String = ws.status_text(id)
			var bl := _wrapped(line)
			bl.name = "WorkshopStatus_" + str(id)
			box.add_child(bl)
			if str(ws.state.get(id, "")) == "stalled":  # the status line shows batches when running; keep the counter when stalled
				var cl := _wrapped(StoryText.get_or("LBL_WORKSHOP_BATCHES", "Batches this cycle: {n}", {"n": ws.batches(id)}))
				cl.name = "WorkshopBatches_" + str(id)
				cl.theme_type_variation = "LabelSmall"
				box.add_child(cl)
		else:
			var b := Button.new()
			b.name = "WorkshopBuild_" + str(id)
			b.text = StoryText.get_or("BTN_WORKSHOP_BUILD", "Build {workshop} ({cost} cr)", {"workshop": nm, "cost": ws.build_cost(id)})
			b.disabled = not main.can_build_workshop(str(id), system_id)["ok"]
			b.pressed.connect(func(): main.build_workshop(str(id), system_id); refresh())
			box.add_child(b)

func _wrapped(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(288, 0)
	return l


## Fabric inputs with too little stock here and no route sending them to this station: names for the panel line.
func _inputs_unreached(f) -> Array:
	var key: String = main.storage.system_key(system_id)
	var out: Array = []
	for c in f.INPUTS:
		if main.storage.amount(key, c) >= f.need_of(c):
			continue
		var fed := false
		for rec in main.engine.routes:
			if str(rec["dst"]) == key and str(rec["c"]) == c:
				fed = true
				break
		if not fed:
			out.append(c)
	return out

# ---------------------------------------------------------------- T171 Storage Link block

var _dlg: String = ""  # "" | "build" | "order": which small dialog the link block shows
var _dlg_partner: int = -1
var _dlg_link: int = -1
var _dlg_good: String = ""
var _dlg_from: int = -1
var _dlg_amount: int = 10

func _on_link_changed(_a = null, _b = null) -> void:
	if visible:
		refresh()

func _link_ids_here() -> Array:
	var out: Array = []
	for id in main.storage_link.links():
		var info: Dictionary = main.storage_link.link_info(int(id))
		if int(info["a"]) == system_id or int(info["b"]) == system_id:
			out.append(int(id))
	return out

## Other systems that could be a partner: open, with an established Space Storage.
func _partners() -> Array:
	var out: Array = []
	for sid in main.station_systems:
		if int(sid) != system_id and main.storage.established(main.storage.system_key(int(sid))):
			out.append(int(sid))
	out.sort()
	return out

func _link_block() -> void:
	if not Availability.feature("storage_link") or not main.station_systems.has(system_id):
		return  # hidden means not drawn at all
	var sl = main.storage_link
	box.add_child(HSeparator.new())
	var head := HBoxContainer.new()
	head.name = "LinkHead"
	box.add_child(head)
	var t := Label.new()
	t.text = StoryText.get_or("SS_LINK_TITLE", "Storage Link")
	t.theme_type_variation = "LabelStrong"
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(t)
	var bb := Button.new()
	bb.name = "LinkBuild"
	bb.text = StoryText.get_or("SS_LINK_BTN_BUILD", "Build link...")
	bb.disabled = _dlg == "build"
	bb.pressed.connect(_open_build)
	head.add_child(bb)
	var here := _link_ids_here()
	if here.is_empty() and _dlg == "":
		box.add_child(_wrapped(StoryText.get_or("SS_LINK_LBL_NO_LINK", "No link yet.")))
	if _dlg == "build":
		_build_dialog()
	for id in here:
		_link_rows(int(id))
	if _dlg == "order":
		_order_dialog()

func _sname(sid: int) -> String:
	return main.Systems.name_of(sid)

func _link_rows(id: int) -> void:
	var sl = main.storage_link
	var info: Dictionary = sl.link_info(id)
	if info.is_empty():
		return
	var line := HBoxContainer.new()
	line.name = "Link_%d" % id
	box.add_child(line)
	var ll := Label.new()
	ll.text = StoryText.get_or("SS_LINK_LBL_LINE", "{a} <-> {b}", {"a": _sname(int(info["a"])), "b": _sname(int(info["b"]))})
	ll.theme_type_variation = "LabelAccent"
	ll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(ll)
	var st := Label.new()
	var sk := str(info["state"])
	st.text = StoryText.get_or("SS_LINK_STATE_" + sk.to_upper(), sk.capitalize())
	if sk == "dormant":
		st.add_theme_color_override("font_color", Ui.col("signal_bad"))
	line.add_child(st)
	var up := _wrapped(StoryText.get_or("SS_LINK_LBL_UPKEEP", "Upkeep {n} energy per cycle", {"n": int(info["upkeep"])}))
	up.name = "LinkUpkeep_%d" % id
	up.theme_type_variation = "LabelSmall"
	up.tooltip_text = StoryText.get_or("SS_LINK_TIP_UPKEEP", "")
	up.mouse_filter = Control.MOUSE_FILTER_STOP
	box.add_child(up)
	if sk == "dormant":
		var dn := _wrapped(StoryText.get_or("SS_LINK_LBL_DORMANT_NEEDS", "Dormant: needs {n} energy", {"n": int(info["upkeep"])}))
		dn.add_theme_color_override("font_color", Ui.col("signal_bad"))
		box.add_child(dn)
		if int(info["cycles_left"]) >= 0:
			box.add_child(_wrapped(StoryText.get_or("SS_LINK_LBL_COLLAPSE_IN", "Collapses in {cycles} cycles", {"cycles": int(info["cycles_left"])})))
	var rl := _wrapped(StoryText.get_or("SS_LINK_LBL_RATE", "Rate used {n} / {m}", {"n": int(info["rate_used"]), "m": int(info["rate"])}))
	rl.name = "LinkRate_%d" % id
	box.add_child(rl)
	var orders: Array = info["orders"]
	var shown := 0
	for i in orders.size():
		var o: Dictionary = orders[i]
		if not Availability.good(str(o["good"])):
			continue  # never name a hidden good
		shown += 1
		var row := HBoxContainer.new()
		row.name = "LinkOrder_%d_%d" % [id, i]
		var eb := Button.new()
		eb.flat = true
		eb.alignment = HORIZONTAL_ALIGNMENT_LEFT
		eb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		eb.text = StoryText.get_or("SS_LINK_LBL_ORDER_ROW", "{good}  {a} -> {b}  {n} per cycle",
			{"good": Ui.good_name(str(o["good"])), "a": _sname(int(o["from"])), "b": _sname(int(o["to"])), "n": int(o["amount"])})
		eb.tooltip_text = StoryText.get_or("SS_LINK_UI_BTN_EDIT_ORDER", "Click to change the amount") + "\n" + GoodInfo.block(str(o["good"]))
		eb.pressed.connect(_open_order.bind(id, str(o["good"]), int(o["from"]), int(o["amount"])))
		row.add_child(eb)
		var xb := Button.new()
		xb.text = "x"
		xb.tooltip_text = StoryText.get_or("SS_LINK_BTN_REMOVE_ORDER", "Remove order")
		xb.pressed.connect(func(): sl.remove_order(id, i))
		row.add_child(xb)
		box.add_child(row)
	var ol := _wrapped(StoryText.get_or("SS_LINK_LBL_ORDERS", "Orders {n} / {m}", {"n": orders.size(), "m": int(sl.balance.get("link_orders_max", 4))}))
	ol.theme_type_variation = "LabelSmall"
	box.add_child(ol)
	var acts := HBoxContainer.new()
	box.add_child(acts)
	var ab := Button.new()
	ab.name = "LinkAddOrder_%d" % id
	ab.text = StoryText.get_or("SS_LINK_BTN_ADD_ORDER", "Add order")
	ab.disabled = orders.size() >= int(sl.balance.get("link_orders_max", 4))
	if ab.disabled:
		ab.tooltip_text = StoryText.get_or("SS_LINK_NOT_REFUSED_ORDERS", "This link has all the orders it can hold.")
	ab.pressed.connect(_open_order.bind(id, "", int(info["a"]), 10))
	acts.add_child(ab)
	var rb := Button.new()
	rb.name = "LinkRemove_%d" % id
	rb.text = StoryText.get_or("SS_LINK_UI_BTN_REMOVE_LINK", "Remove link")
	rb.pressed.connect(func(): sl.remove_link(id))
	acts.add_child(rb)

func _open_build() -> void:
	var ps := _partners()
	_dlg = "build"
	_dlg_partner = int(ps[0]) if not ps.is_empty() else -1
	refresh()

func _open_order(id: int, good: String, from: int, amount: int) -> void:
	var goods: Array = Availability.visible_goods(main.commodities)
	if goods.is_empty():
		return
	_dlg = "order"
	_dlg_link = id
	_dlg_good = good if good != "" else str(goods[0])
	_dlg_from = from
	_dlg_amount = maxi(1, amount)
	refresh()

func _close_dialog() -> void:
	_dlg = ""
	refresh()

func _build_dialog() -> void:
	var sl = main.storage_link
	var panel := VBoxContainer.new()
	panel.name = "LinkBuildDialog"
	panel.add_theme_constant_override("separation", 6)
	box.add_child(panel)
	var tl := Label.new()
	tl.text = StoryText.get_or("SS_LINK_DLG_TITLE", "Build a Storage Link")
	tl.theme_type_variation = "LabelAccent"
	panel.add_child(tl)
	panel.add_child(_wrapped(StoryText.get_or("SS_LINK_DLG_HINT", "The link is paid in goods from both storages. No credits are charged.")))
	var ps := _partners()
	if ps.is_empty():
		panel.add_child(_wrapped(StoryText.get_or("SS_LINK_UI_LBL_NO_PARTNER", "No other Space Storage to link to yet.")))
	else:
		if not ps.has(_dlg_partner):
			_dlg_partner = int(ps[0])
		panel.add_child(_caption(StoryText.get_or("SS_LINK_UI_LBL_PARTNER", "Partner storage")))
		var ob := OptionButton.new()
		ob.name = "LinkPartner"
		for p in ps:
			ob.add_item(_sname(int(p)), int(p))
		ob.select(ps.find(_dlg_partner))
		ob.item_selected.connect(func(i): _dlg_partner = int(ps[i]); refresh())
		panel.add_child(ob)
		panel.add_child(_wrapped(StoryText.get_or("SS_LINK_DLG_PARTNER", "Join {a} to {b}", {"a": _sname(system_id), "b": _sname(_dlg_partner)})))
		var c: Dictionary = sl.cost()
		var missing: Array = []
		for g in Availability.visible_goods(["rivets", "energy"]):  # visible goods only
			var have: int = sl.stock_of(system_id, str(g)) + sl.stock_of(_dlg_partner, str(g))
			var cl := _wrapped(StoryText.get_or("SS_LINK_DLG_COST", "{goods}: need {n}, have {m}", {"goods": Ui.good_name(str(g)), "n": int(c[g]), "m": have}))
			cl.name = "LinkCost_" + str(g)
			panel.add_child(cl)
			if have < int(c[g]):
				missing.append(Ui.good_name(str(g)))
				cl.add_theme_color_override("font_color", Ui.col("signal_bad"))
		var why: String = sl.can_build(system_id, _dlg_partner)
		if why == "LNK_NEED_GOODS" and not missing.is_empty():
			panel.add_child(_wrapped(StoryText.get_or("SS_LINK_DLG_SHORT", "The two storages together lack {goods}.", {"goods": ", ".join(missing)})))
		elif why != "":
			panel.add_child(_wrapped(StoryText.get_or(why, "")))
		var acts := HBoxContainer.new()
		panel.add_child(acts)
		var ok := Button.new()
		ok.name = "LinkConfirm"
		ok.text = StoryText.get_or("SS_LINK_BTN_CONFIRM", "Build link")
		ok.disabled = why != ""
		ok.pressed.connect(func():
			var id: int = sl.build_link(system_id, _dlg_partner)  # empty mix: paid automatically
			if id >= 0:
				_dlg = ""
			refresh())
		acts.add_child(ok)
	var cb := Button.new()
	cb.name = "LinkCancel"
	cb.text = StoryText.get_or("SS_LINK_BTN_CANCEL", "Cancel")
	cb.pressed.connect(_close_dialog)
	if ps.is_empty():
		panel.add_child(cb)
	else:
		(panel.get_child(panel.get_child_count() - 1) as HBoxContainer).add_child(cb)
	panel.add_child(_wrapped(StoryText.get_or("SS_LINK_FLAVOUR_BUILD", "")))

func _caption(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = "LabelCaption"
	return l

func _order_dialog() -> void:
	var sl = main.storage_link
	var info: Dictionary = sl.link_info(_dlg_link)
	if info.is_empty():
		_dlg = ""
		return
	var panel := VBoxContainer.new()
	panel.name = "LinkOrderDialog"
	panel.add_theme_constant_override("separation", 6)
	box.add_child(panel)
	var goods: Array = Availability.visible_goods(main.commodities)
	panel.add_child(_caption(StoryText.get_or("SS_LINK_LBL_GOOD", "Good")))
	var gb := OptionButton.new()
	gb.name = "LinkOrderGood"
	for g in goods:
		gb.add_item(Ui.good_name(str(g)))
	gb.select(maxi(0, goods.find(_dlg_good)))
	gb.item_selected.connect(func(i): _dlg_good = str(goods[i]))
	panel.add_child(gb)
	panel.add_child(_caption(StoryText.get_or("SS_LINK_LBL_FROM", "From")))
	var ends := [int(info["a"]), int(info["b"])]
	var fb := OptionButton.new()
	fb.name = "LinkOrderFrom"
	for e in ends:
		fb.add_item(_sname(int(e)))
	fb.select(maxi(0, ends.find(_dlg_from)))
	fb.item_selected.connect(func(i): _dlg_from = int(ends[i]))
	panel.add_child(fb)
	panel.add_child(_caption(StoryText.get_or("SS_LINK_LBL_AMOUNT", "Per cycle")))
	var sp := SpinBox.new()
	sp.name = "LinkOrderAmount"
	sp.min_value = 1
	sp.max_value = maxi(1, int(info["rate"]))
	sp.step = 1
	sp.value = clampi(_dlg_amount, 1, int(sp.max_value))
	sp.value_changed.connect(func(v): _dlg_amount = int(v))
	panel.add_child(sp)
	panel.add_child(_wrapped(StoryText.get_or("SS_LINK_LBL_ORDER_NOTE", "")))
	var acts := HBoxContainer.new()
	panel.add_child(acts)
	var ok := Button.new()
	ok.name = "LinkOrderSave"
	ok.text = StoryText.get_or("SS_LINK_BTN_SAVE_ORDER", "Save order")
	ok.pressed.connect(func():
		var done: bool = sl.set_order(_dlg_link, _dlg_good, _dlg_from, _dlg_amount)
		if done:
			_dlg = ""
		else:
			main.post_notice(StoryText.get_or("SS_LINK_NOT_REFUSED_ORDERS", "This link has all the orders it can hold."))
		refresh())
	acts.add_child(ok)
	var cb := Button.new()
	cb.text = StoryText.get_or("SS_LINK_BTN_CANCEL", "Cancel")
	cb.pressed.connect(_close_dialog)
	acts.add_child(cb)
