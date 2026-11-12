extends PanelContainer
## T263: the Bazaar panel (design/proposals/2026-11-06-empire-growth-v2.md sections 3.7 and 4). Replaces the share panel on the
## rail (key M): capital, stages, the bill of the stage being built (delivered / short), quorum, reach and term left.
## Reads Bazaar (game/bazaar.gd) only; computes no rule. Does not pause the game. Wing choice popup (T299): show_wing_choice() after each stage with wings, two cards, pick one; the chosen wings are listed in the panel.
## Texts by id from StoryText with plain fallbacks. Goods are named only when Availability shows them (bill_status does that).

const StoryText := preload("res://game/story_text.gd")

signal closed

var main: Control
var _root: VBoxContainer
var _body: VBoxContainer

func setup(main_node: Control) -> void:
	main = main_node
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
	title.text = StoryText.get_or("BAZ_PANEL_TITLE", "The Star Bazaar")
	title.theme_type_variation = "LabelTitle"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var close := Button.new()
	close.text = StoryText.get_or("SK_BTN_CLOSE", "Close")
	close.pressed.connect(close_screen)
	head.add_child(close)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 8)
	_root.add_child(_body)

var _wing_popup: PanelContainer = null

## T299: the wing choice popup: two cards, pick one (Bazaar.choose_wing). Does not pause the game. Re-opens from a save with wing_pending.
func show_wing_choice() -> void:
	var bz = main.bazaar
	var opts: Array = Bazaar.wing_options(bz.wing_pending)
	if bz.wing_pending <= 0 or opts.size() < 2:
		return
	close_wing_choice()
	var pop := PanelContainer.new()
	pop.mouse_filter = Control.MOUSE_FILTER_STOP
	pop.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pop.custom_minimum_size = Vector2(minf(560.0, get_viewport_rect().size.x - 24.0), 0)
	pop.grow_horizontal = Control.GROW_DIRECTION_BOTH
	pop.grow_vertical = Control.GROW_DIRECTION_BOTH
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	pop.add_child(col)
	var title := Label.new()
	title.text = StoryText.get_or("BAZ_WING_TITLE", "Choose a wing")
	title.theme_type_variation = "LabelTitle"
	col.add_child(title)
	var stage_name := StoryText.get_or("BAZ_STAGE_%d_NAME" % bz.wing_pending, "Stage %d" % bz.wing_pending)
	var prompt := Label.new()
	prompt.text = StoryText.get_or("BAZ_WING_PROMPT", "{stage} is done. Pick one wing to add. The other is not offered again.", {"stage": stage_name})
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(prompt)
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", 10)
	col.add_child(cards)
	for i in 2:
		var o: Dictionary = opts[i]
		var card := VBoxContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_constant_override("separation", 6)
		cards.add_child(card)
		var nm := Label.new()
		nm.text = StoryText.get_or("BAZ_%s_NAME" % o["id"], str(o["id"]))
		nm.theme_type_variation = "LabelCaption"
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(nm)
		var tx := Label.new()
		tx.text = StoryText.get_or("BAZ_%s_LINE" % o["id"], "")
		tx.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tx.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card.add_child(tx)
		var b := Button.new()
		b.text = StoryText.get_or("BAZ_WING_PICK", "Add this wing")
		b.pressed.connect(_pick_wing.bind(i))
		card.add_child(b)
	main.add_child(pop)
	_wing_popup = pop

func _pick_wing(idx: int) -> void:
	if main.bazaar.choose_wing(idx):
		close_wing_choice()
		refresh()

func close_wing_choice() -> void:
	if _wing_popup != null:
		_wing_popup.queue_free()
		_wing_popup = null

func open_screen() -> void:
	visible = true
	refresh()

func close_screen() -> void:
	if visible:
		visible = false
		closed.emit()

func _row(left: String, right: String = "", style: String = "") -> void:
	var line := HBoxContainer.new()
	var l := Label.new()
	l.text = left
	l.clip_text = true
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if style != "":
		l.theme_type_variation = style
	line.add_child(l)
	if right != "":
		var r := Label.new()
		r.theme_type_variation = "LabelNumber"
		r.text = right
		line.add_child(r)
	_body.add_child(line)

func _head(id: String, fallback: String) -> void:
	var l := Label.new()
	l.text = StoryText.get_or(id, fallback)
	l.theme_type_variation = "LabelCaption"
	_body.add_child(l)

func _tier_name(t: int) -> String:
	return StoryText.get_or("PROS_TIER_%d" % t, "Tier %d" % t)

func refresh() -> void:
	if main == null or not visible:
		return
	for c in _body.get_children():
		_body.remove_child(c)
		c.queue_free()
	var bz = main.bazaar
	if not bz.is_founded():
		_head("BAZ_LBL_CAPITAL", "Capital")
		var cand := -1
		for i in main.map.planets.size():
			if bz.can_found(i):
				cand = i
				break
		if cand >= 0:
			_row(StoryText.get_or("NEXTUP_BAZAAR_FOUND", "Found the Bazaar at {planet}", {"planet": main.planet_name(cand)}))
		else:
			_row(StoryText.get_or("NEXTUP_IDLE", "Keep trading. Check the planet cards."), "", "LabelMuted")
		_term()
		return
	_head("BAZ_LBL_CAPITAL", "Capital")
	_row(main.planet_name(bz.capital()))
	# stages: done ones marked, the one being built named
	var total: int = bz.stages_total()
	for n in range(1, total + 1):
		var nm := StoryText.get_or("BAZ_STAGE_%d_NAME" % n, "Stage %d" % n)
		var mark := "x" if n <= bz.stage() else (">" if n == bz.current_stage() else "-")
		_row("[%s] %s" % [mark, nm], "", "" if n <= bz.stage() or n == bz.current_stage() else "LabelMuted")
	if not bz.wings.is_empty():
		_head("BAZ_LBL_WINGS", "Wings")
		for w in bz.wings:
			_row(StoryText.get_or("BAZ_%s_NAME" % w, str(w)))
	if bz.complete():
		_row(StoryText.get_or("BAZ_NAME", "Star Bazaar"))
		_term()
		return
	_head("BAZ_LBL_BILL", "Goods needed")
	for r in bz.bill_status():
		var goods: Array = r["goods"]
		var names := []
		for g in goods:
			names.append(Ui.good_name(str(g)))
		var label := " / ".join(names) if not names.is_empty() else StoryText.get_or("PROS_NEED_LOCKED", "? Not known yet")
		var have: int = int(r["have"])
		var need: int = int(r["need"])
		_row(label, "%d / %d" % [mini(have, need), need])
		if not bool(r["ok"]):
			_row(StoryText.get_or("BAZ_BILL_ROW", "{amount} more {commodity}", {"amount": need - have, "commodity": label}), "", "LabelSmall")
		else:
			_row(StoryText.get_or("PROS_NEED_MET", "Met"), "", "LabelSmall")
	_head("BAZ_LBL_QUORUM", "Other worlds")
	var q: Dictionary = bz.quorum_status()
	_row(StoryText.get_or("BAZ_QUORUM_ROW", "{n} of {m} worlds at {tier}", {"n": int(q["have"]), "m": int(q["need"]), "tier": _tier_name(int(q["tier"]))}), "" if not bool(q["ok"]) else StoryText.get_or("PROS_NEED_MET", "Met"))
	if bz.reach_needed():
		_head("BAZ_LBL_REACH", "Reach")
		_row(StoryText.get_or("BAZ_REACH_ROW", "One world in another system"), StoryText.get_or("PROS_NEED_MET", "Met") if bz.reach_ok() else StoryText.get_or("PROS_NEED_SHORT", "Short"))
	_term()

func _term() -> void:
	if main.free_play:
		return
	var left: int = maxi(0, int(main.balance.get("win_cycle_markets", 0)) - int(main.cycle))
	_row(StoryText.get_or("BAZ_TERM_LEFT", "Term left: {cycles} cycles", {"cycles": left}), "", "LabelMuted")
