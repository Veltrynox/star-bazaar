extends PanelContainer
## T291: the hub panel (design/proposals/2026-11-06-empire-growth-v2.md section 3.3, Feedback). One hub at a time: worlds in
## reach with a tick each (untick = kept manual), the needs of each with their status (fed by route / hub / short and why)
## with a tick each, the pool with add/remove ship, and Release. Reads and changes Hubs (game/hubs.gd) only; computes no rule.
## Goods are named only for needs Prosperity lists (it hides locked ones). Texts by id from StoryText with plain fallbacks.

const StoryText := preload("res://game/story_text.gd")

signal closed
signal changed  # the hub or its pool changed: main redraws the reach ring and the card

var main: Control
var hub := -1
var _root: VBoxContainer
var _body: VBoxContainer

func setup(main_node: Control) -> void:
	main = main_node
	name = "HubPanel"
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	custom_minimum_size = Vector2(minf(520.0, get_viewport_rect().size.x - 24.0), 0)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	_root = VBoxContainer.new()
	_root.add_theme_constant_override("separation", 10)
	Ui.scroll_wrap(self, _root, 24.0)
	var head := HBoxContainer.new()
	_root.add_child(head)
	var title := Label.new()
	title.name = "HubTitle"
	title.theme_type_variation = "LabelTitle"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.clip_text = true
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	head.add_child(title)
	var close := Button.new()
	close.text = StoryText.get_or("SK_BTN_CLOSE", "Close")
	close.pressed.connect(close_screen)
	head.add_child(close)
	var explain := Label.new()
	explain.name = "HubExplain"
	explain.theme_type_variation = "LabelMuted"
	explain.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explain.custom_minimum_size.x = 100.0
	explain.text = StoryText.get_or("ST_HUB_EXPLAIN", "A hub feeds the worlds around it for you.")
	_root.add_child(explain)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 6)
	_root.add_child(_body)

func open_for(planet: int) -> void:
	hub = planet
	visible = true
	refresh()

func close_screen() -> void:
	if visible:
		visible = false
		hub = -1
		closed.emit()

func _head(id: String, fallback: String) -> void:
	var l := Label.new()
	l.text = StoryText.get_or(id, fallback).to_upper()
	l.theme_type_variation = "LabelCaption"
	_body.add_child(l)

func _check(text: String, on: bool, cb: Callable, small := false) -> CheckBox:
	var c := CheckBox.new()
	c.text = text
	c.button_pressed = on
	c.clip_text = true
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if small:
		c.theme_type_variation = "LabelSmall"
	c.toggled.connect(func(v: bool) -> void:
		cb.call(v)
		refresh()
		changed.emit())
	return c

func refresh() -> void:
	if main == null or not visible:
		return
	for c in _body.get_children():
		_body.remove_child(c)
		c.queue_free()
	var hs = main.hubs
	if hub < 0 or not hs.is_hub(hub):
		close_screen()
		return
	(_root.get_child(0).get_node("HubTitle") as Label).text = StoryText.get_or("ST_HUB_PANEL_TITLE", "Hub: {planet}", {"planet": main.planet_name(hub)})
	# pool
	_head("ST_HUB_POOL", "Pool")
	var pool_row := HBoxContainer.new()
	pool_row.name = "PoolRow"
	pool_row.add_theme_constant_override("separation", 8)
	var pl := Label.new()
	pl.name = "PoolLabel"
	pl.text = StoryText.get_or("ST_HUB_POOL_SHIPS", "Ships in pool: {n}", {"n": hs.pool_of(hub)})
	pl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pool_row.add_child(pl)
	var minus := Button.new()
	minus.name = "PoolMinus"
	minus.text = "-"
	minus.disabled = hs.pool_of(hub) <= 0
	minus.pressed.connect(func() -> void:
		hs.set_pool(hub, hs.pool_of(hub) - 1)
		refresh()
		changed.emit())
	pool_row.add_child(minus)
	var plus := Button.new()
	plus.name = "PoolPlus"
	plus.text = "+"
	plus.disabled = hs.free_for_pool() <= 0 or hs.pool_of(hub) >= int(main.balance.get("hub_pool_max", 0))
	plus.pressed.connect(func() -> void:
		hs.set_pool(hub, hs.pool_of(hub) + 1)
		refresh()
		changed.emit())
	pool_row.add_child(plus)
	_body.add_child(pool_row)
	var fl := Label.new()
	fl.text = StoryText.get_or("ST_HUB_POOL_FREE", "Free ships: {n}", {"n": hs.free_for_pool()})
	fl.theme_type_variation = "LabelMuted"
	_body.add_child(fl)
	if hs.pool_of(hub) < int(main.balance.get("hub_pool_max", 0)):  # always offered (owner 2026-11-12): buy one straight into the pool, whether or not a ship is free
		var can: Dictionary = main.can_buy_ship()
		var buy := Button.new()
		buy.name = "PoolBuyShip"
		buy.text = StoryText.get_or("ST_HUB_BUY_SHIP", "Buy a ship for the pool ({price} cr)", {"price": main.ship_price()})
		buy.disabled = not bool(can["ok"])
		buy.tooltip_text = "" if bool(can["ok"]) else str(can["reason"])
		buy.pressed.connect(func() -> void:
			if bool(main.buy_ship()["ok"]):
				hs.set_pool(hub, hs.pool_of(hub) + 1)
			refresh()
			changed.emit())
		_body.add_child(buy)
	# served worlds and their gaps
	_head("ST_HUB_SERVED", "Worlds in reach")
	var any := false
	for w in hs.worlds_in_reach(hub):
		if w == hub:
			continue
		any = true
		_world_block(w)
	if not any:
		var none := Label.new()
		none.text = StoryText.get_or("ST_HUB_NONE_IN_REACH", "No worlds in reach yet.")
		none.theme_type_variation = "LabelMuted"
		_body.add_child(none)
	var rel := Button.new()
	rel.name = "ReleaseHub"
	rel.text = StoryText.get_or("ST_HUB_RELEASE", "Release hub")
	rel.pressed.connect(_ask_release)
	_body.add_child(rel)
	size = Vector2.ZERO

func _world_block(w: int) -> void:
	var hs = main.hubs
	var off: bool = hs.is_world_off(hub, w)
	var box := VBoxContainer.new()
	box.name = "HubWorld_%d" % w
	box.add_theme_constant_override("separation", 2)
	box.add_child(_check(main.planet_name(w), not off, func(v: bool) -> void: hs.set_world_off(hub, w, not v)))
	if not off:
		for n in main.prosperity.needs(w):
			if bool(n["locked"]):
				continue
			var g := str(n["good"])
			var row := HBoxContainer.new()
			row.name = "HubNeed_%d_%s" % [w, g]
			var margin := Control.new()
			margin.custom_minimum_size = Vector2(22, 0)
			row.add_child(margin)
			var need_off: bool = hs.is_need_off(hub, w, g)
			var ck := _check(Ui.good_name(g), not need_off, func(v: bool) -> void: hs.set_need_off(hub, w, g, not v), true)
			row.add_child(ck)
			var st := Label.new()
			st.theme_type_variation = "LabelSmall"
			st.text = StoryText.get_or("ST_HUB_MANUAL", "Kept manual") if need_off else hs.status_text(hs.status_of(w, g))
			row.add_child(st)
			box.add_child(row)
	_body.add_child(box)

func _ask_release() -> void:
	var dlg := ConfirmationDialog.new()
	dlg.name = "ReleaseHubDialog"
	dlg.dialog_text = StoryText.get_or("ST_HUB_RELEASE_PROMPT", "Release the hub at {planet}? Its ships return to your free fleet.", {"planet": main.planet_name(hub)})
	dlg.ok_button_text = StoryText.get_or("ST_HUB_RELEASE", "Release hub")
	dlg.cancel_button_text = StoryText.get_or("BAZ_FOUND_CANCEL", "Not yet")
	var idx := hub
	dlg.confirmed.connect(func() -> void:
		main.hubs.release(idx)
		close_screen()
		changed.emit()
		dlg.queue_free())
	dlg.canceled.connect(dlg.queue_free)
	add_child(dlg)
	dlg.popup_centered()
