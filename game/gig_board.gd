extends PanelContainer
## T273: the gig board (design/proposals/2026-11-06-empire-growth-v2.md section 3.2, Feedback). Opens from the rail button or key J.
## One row per open offer (Gigs.offers): kind icon, title, world, reward line, deadline bar and the Flagship ETA; Accept orders the
## Flagship there. Reads Gigs (game/gigs.gd) only; computes no rule. Does not pause the game. Bars and ETA update live while open.
## Texts by id from StoryText with plain fallbacks. No numbers of its own:
## the amber threshold is balance gig_marker_amber_cycles.

const StoryText := preload("res://game/story_text.gd")

signal closed

var main: Control
var _body: VBoxContainer
var _rows := {}    # uid -> {bar, eta, accept, span}
var _spans := {}   # uid -> longest remaining seen (the bar's full length)

func setup(main_node: Control) -> void:
	main = main_node
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	custom_minimum_size = Vector2(minf(560.0, get_viewport_rect().size.x - 24.0), 0)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	Ui.scroll_wrap(self, root, 24.0)
	var head := HBoxContainer.new()
	root.add_child(head)
	var title := Label.new()
	title.text = StoryText.get_or("GIG_BOARD_TITLE", "Gig board")
	title.theme_type_variation = "LabelTitle"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var close := Button.new()
	close.text = StoryText.get_or("SK_BTN_CLOSE", "Close")
	close.pressed.connect(close_screen)
	head.add_child(close)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 8)
	root.add_child(_body)
	main.gigs.changed.connect(refresh)

func open_screen() -> void:
	visible = true
	refresh()

func close_screen() -> void:
	if visible:
		visible = false
		closed.emit()

func _process(_delta: float) -> void:
	if visible:
		_live()

## Rebuilds the rows (offers changed or the panel opened).
func refresh() -> void:
	if _body == null or not visible:
		return
	for c in _body.get_children():
		c.queue_free()
	_rows = {}
	var gigs = main.gigs
	if gigs.offers.is_empty():
		var l := Label.new()
		l.text = StoryText.get_or("GIG_BOARD_EMPTY", "No offers right now. Signals appear as the run goes on.")
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_body.add_child(l)
		return
	for o in gigs.offers:
		_add_row(o)
	_live()

func kind_text(o: Dictionary) -> String:
	if str(o["kind"]) == "opening":
		return StoryText.get_or("GIG_KIND_OPENING", "The Opening")
	if str(o["kind"]) == "salvage":
		return StoryText.get_or("GIG_KIND_SALVAGE", "Salvage")
	return StoryText.get_or("GIG_KIND_SIGNAL", "Signal")

func _def(o: Dictionary) -> Dictionary:
	for d in main.gigs.defs:
		if str(d.get("id", "")) == str(o["id"]):
			return d
	return {}

func title_text(o: Dictionary) -> String:
	if str(o["kind"]) == "opening":
		return StoryText.get_or("GIG_ROW_OPENING", "Charter cargo for {planet}", {"planet": main.planet_name(int(o["target"]["index"]))})
	if str(o["kind"]) == "salvage":
		return StoryText.get_or("GIG_ROW_SALVAGE", "Cargo pods")
	return StoryText.get_or(str(_def(o).get("title", "")), StoryText.get_or("GIG_ROW_SIGNAL", "Unknown signal"))

func world_text(o: Dictionary) -> String:
	if str(o["kind"]) == "opening" and str(o["target"].get("kind", "planet")) == "planet":
		return main.planet_name(int(o["target"]["index"]))
	return StoryText.get_or("GIG_WHERE_SPACE", "Open space")

func reward_text(o: Dictionary) -> String:
	if str(o["kind"]) == "opening":
		return StoryText.get_or("GIG_REWARD_OPENING", "The Star Bazaar opens")
	if str(o["kind"]) == "salvage":
		return StoryText.get_or("GIG_REWARD_SALVAGE", "Stolen cargo, loaded into the Flagship hold")
	return StoryText.get_or(str(_def(o).get("hook", "")), StoryText.get_or("GIG_REWARD_SIGNAL", "Unknown reward"))

## Cycles left on the game clock.
func left(o: Dictionary) -> float:
	return maxf(0.0, float(o["due"]) - main.game_time())

## Flagship flight time in cycles to the offer's target; < 0 when it cannot go.
func eta(o: Dictionary) -> float:
	var f = main.flight
	if f == null or not f.is_enabled():
		return -1.0
	var t: Dictionary = o["target"]
	if str(t["kind"]) == "planet":
		return f.eta_cycles(str(main.map.planets[int(t["index"])].get("id", "")))
	if int(t["sys"]) != f.system_id():
		return -1.0
	return f._flight_cycles(f.ship_position(), main.gigs.target_pos(o), int(t["sys"]))

func _add_row(o: Dictionary) -> void:
	var uid := str(o["uid"])
	var card := PanelContainer.new()
	_body.add_child(card)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	card.add_child(col)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	col.add_child(top)
	var ic := TextureRect.new()
	ic.texture = Ui.icon("mark")
	ic.custom_minimum_size = Vector2(24, 24)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.tooltip_text = kind_text(o)
	top.add_child(ic)
	var name_l := Label.new()
	name_l.text = title_text(o)
	name_l.clip_text = true
	name_l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name_l)
	var accept := Button.new()
	accept.text = StoryText.get_or("GIG_BTN_ACCEPT", "Accept")
	accept.pressed.connect(_on_accept.bind(uid))
	top.add_child(accept)
	var sub := Label.new()
	sub.text = "%s · %s" % [world_text(o), reward_text(o)]
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(sub)
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 8)
	col.add_child(bottom)
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.custom_minimum_size = Vector2(0, 10)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bottom.add_child(bar)
	var eta_l := Label.new()
	bottom.add_child(eta_l)
	var why_l := Label.new()
	why_l.add_theme_color_override("font_color", Color(1.0, 0.55, 0.35))
	why_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	why_l.visible = false
	col.add_child(why_l)
	_rows[uid] = {"bar": bar, "eta": eta_l, "accept": accept, "why": why_l}

func _live() -> void:
	var amber := float(main.balance.get("gig_marker_amber_cycles", 2.0))
	for o in main.gigs.offers:
		var uid := str(o["uid"])
		if not _rows.has(uid):
			continue
		var r: Dictionary = _rows[uid]
		var lf := left(o)
		_spans[uid] = maxf(float(_spans.get(uid, 0.0)), lf)
		var bar: ProgressBar = r["bar"]
		bar.value = lf / maxf(0.001, float(_spans[uid]))
		bar.modulate = Color(1.0, 0.72, 0.25) if lf <= amber else Color(1, 1, 1)
		var e := eta(o)
		var eta_l: Label = r["eta"]
		var acc: Button = r["accept"]
		if e < 0.0:
			eta_l.text = StoryText.get_or("GIG_ETA_NONE", "Out of reach")
		else:
			eta_l.text = StoryText.get_or("GIG_ETA", "ETA {cycles} cycles, left {left}", {"cycles": snappedf(e, 0.1), "left": snappedf(lf, 0.1)})
		var held: bool = main.flight != null and main.flight.idle_left() > 0.0
		acc.disabled = e < 0.0 or held
		acc.tooltip_text = _refuse_text("busy") if held and e >= 0.0 else ""
		acc.text = StoryText.get_or("GIG_BTN_ORDERED", "Ordered") if bool(o["accepted"]) else StoryText.get_or("GIG_BTN_ACCEPT", "Accept")

func _on_accept(uid: String) -> void:
	var why: String = main.gigs.accept(uid)
	if why == "":
		close_screen()
		return
	var txt := _refuse_text(why)
	main.post_notice_now(txt)
	if _rows.has(uid):
		var r: Dictionary = _rows[uid]
		(r["accept"] as Button).tooltip_text = txt
		var wl: Label = r["why"]
		wl.text = txt
		wl.visible = true

func _refuse_text(why: String) -> String:
	return StoryText.get_or("GIG_REFUSE_" + why.to_upper(), StoryText.get_or("GIG_REFUSE_GENERIC", "The Flagship cannot take this order now ({why}).", {"why": why}))
