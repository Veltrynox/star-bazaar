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
	var how := Label.new()  # T362: always visible, what the Bazaar asks of the player
	how.text = StoryText.get_or("BAZ_HOW", "The Bazaar is raised in stages. Each stage needs goods held in the capital's own storage, other worlds grown to a tier, and must finish before the term ends.")
	how.theme_type_variation = "LabelMuted"
	how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_root.add_child(how)
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
	pop.custom_minimum_size = Vector2(minf(760.0, get_viewport_rect().size.x - 24.0), 0)
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
		var tex_path := "res://assets/wings/%s.png" % str(o["id"]).to_lower()
		if ResourceLoader.exists(tex_path):  # a missing image shows nothing and leaves no gap
			var img := TextureRect.new()
			img.texture = load(tex_path)
			img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			img.custom_minimum_size = Vector2(0, 140)
			img.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			card.add_child(img)
		var nm := Label.new()
		nm.text = StoryText.get_or("BAZ_%s_NAME" % o["id"], str(o["id"]))
		nm.theme_type_variation = "LabelCaption"
		nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(nm)
		var tx := Label.new()
		tx.text = StoryText.get_or("BAZ_%s_LINE" % o["id"], "")
		tx.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(tx)
		var ds := Label.new()
		ds.text = wing_desc(str(o["id"]))
		ds.theme_type_variation = "LabelMuted"
		ds.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ds.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card.add_child(ds)
		var b := Button.new()
		b.text = StoryText.get_or("BAZ_WING_PICK", "Add this wing")
		b.pressed.connect(_pick_wing.bind(i))
		card.add_child(b)
	main.add_child(pop)
	_wing_popup = pop

## T362: the long description of a wing with {n} filled from its balance key (absolute value; the unit is in the text).
func wing_desc(id: String) -> String:
	var v: float = absf(float(main.balance.get("bazaar_wing_" + id.to_lower(), 0)))
	var n := str(int(v)) if is_equal_approx(v, floorf(v)) else str(v)
	return StoryText.get_or("BAZ_%s_DESC" % id, "", {"n": n})

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

func _row(left: String, right: String = "", style: String = "", tip: String = "") -> void:
	var line := HBoxContainer.new()
	var l := Label.new()
	l.text = left
	l.clip_text = true
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if style != "":
		l.theme_type_variation = style
	if tip != "":
		l.tooltip_text = tip
		l.mouse_filter = Control.MOUSE_FILTER_STOP
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
			_row(StoryText.get_or("BAZ_%s_NAME" % w, str(w)), "", "", wing_desc(str(w)))
	if bz.complete():
		_row(StoryText.get_or("BAZ_NAME", "Star Bazaar"))
		_term()
		return
	_head("BAZ_LBL_BILL", "Goods needed")
	var lines: Array = bz.bill_lines()
	var li := 0
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
			if not goods.is_empty() and li < lines.size():
				_step(lines[li], true)
				li += 1
		else:
			_row(StoryText.get_or("PROS_NEED_MET", "Met"), "", "LabelSmall")
	_head("BAZ_LBL_QUORUM", "Other worlds")
	var q: Dictionary = bz.quorum_status()
	_row(StoryText.get_or("BAZ_QUORUM_ROW", "{n} of {m} worlds at {tier}", {"n": int(q["have"]), "m": int(q["need"]), "tier": _tier_name(int(q["tier"]))}), "" if not bool(q["ok"]) else StoryText.get_or("PROS_NEED_MET", "Met"))
	if not bool(q["ok"]):
		_step({"kind": "quorum", "stage": bz.current_stage(), "n": maxi(0, int(q["need"]) - int(q["have"])), "tier": int(q["tier"])}, false)
	if bz.reach_needed():
		_head("BAZ_LBL_REACH", "Reach")
		_row(StoryText.get_or("BAZ_REACH_ROW", "One world in another system"), StoryText.get_or("PROS_NEED_MET", "Met") if bz.reach_ok() else StoryText.get_or("PROS_NEED_SHORT", "Short"))
		if not bz.reach_ok():
			_step({"kind": "reach", "stage": bz.current_stage()}, false)
	_term()

## T362: the instruction line of a record (muted, wrapped) and, for a short bill row nothing feeds yet, Buy at / Send to buttons.
func _step(rec: Dictionary, buttons: bool) -> void:
	var bz = main.bazaar
	var t := Label.new()
	t.name = "StepLine"
	t.text = bz.step_line(rec)
	t.theme_type_variation = "LabelMuted"
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_child(t)
	if not buttons or bool(rec.get("fed", false)) or int(rec.get("source", -1)) < 0:
		return  # fed: the line says so; no source: the line says Buy it at the capital (its card block has that button)
	var src := int(rec["source"])
	var good := str(rec["good"])
	var row := HBoxContainer.new()
	row.name = "StepButtons"
	row.add_theme_constant_override("separation", 8)
	var b1 := Button.new()
	b1.name = "BuyAtButton"
	b1.text = StoryText.get_or("BAZ_BTN_BUY_AT", "Buy at {planet}", {"planet": main.planet_name(src)})
	b1.pressed.connect(_buy_at.bind(src, good))
	row.add_child(b1)
	var b2 := Button.new()
	b2.name = "SendToButton"
	b2.text = StoryText.get_or("BAZ_BTN_SEND_TO", "Send to {planet}", {"planet": main.planet_name(bz.capital())})
	b2.pressed.connect(_send_to.bind(src, good))
	row.add_child(b2)
	_body.add_child(row)

## Buy at: leave the panel, open the source world's card with the good's Buy button lit.
func _buy_at(src: int, good: String) -> void:
	close_screen()
	main.cancel_pending()
	main.focus_next_up(src)
	main.selected_planet = src
	main.planet_panel.show_lit(src, good)

## Send to: the existing Buy and send flow (begin_buy_and_send) from the source, the capital already clicked as the destination.
func _send_to(src: int, good: String) -> void:
	close_screen()
	main.cancel_pending()
	main.focus_next_up(src)
	main.selected_planet = src
	main.begin_buy_and_send(good)
	main._on_planet_clicked(main.bazaar.capital())

func _term() -> void:
	if main.free_play:
		return
	var left: int = maxi(0, int(main.balance.get("win_cycle_markets", 0)) - int(main.cycle))
	_row(StoryText.get_or("BAZ_TERM_LEFT", "Term left: {cycles} cycles", {"cycles": left}), "", "LabelMuted")
