extends PanelContainer
## Compact, always-visible Star Bazaar card in the right column (once the Bazaar is founded): the Star Bazaar's system, the stage being built,
## each goods bill row as have / need, the other-worlds quorum and the term left. Reads main.bazaar only, never writes. It replaces
## nothing: the full Bazaar panel (key / rail button) still opens for the detail. Refreshed about twice a second, not every frame.

const StoryText := preload("res://game/story_text.gd")

var main: Control
var _box: VBoxContainer
var _t := 0.0
var _sig := ""

func setup(main_node: Control) -> void:
	main = main_node
	name = "BazaarCard"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(320, 0)
	visible = false
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 3)
	add_child(_box)

func _process(delta: float) -> void:
	_t += delta
	if _t < 0.5:
		return
	_t = 0.0
	refresh()

func _line(left: String, right: String = "", style: String = "") -> void:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = left
	l.clip_text = true
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.theme_type_variation = style if style != "" else "LabelSmall"
	row.add_child(l)
	if right != "":
		var r := Label.new()
		r.theme_type_variation = "LabelNumber"
		r.text = right
		row.add_child(r)
	_box.add_child(row)

func refresh() -> void:
	if main == null or main.bazaar == null or main.game_over or main.preface != null or not main.bazaar.is_founded():
		visible = false
		return
	var bz = main.bazaar
	var lines: Array = []  # [left, right, style]
	lines.append([StoryText.get_or("BAZ_PANEL_TITLE", "The Star Bazaar").to_upper(), main.Systems.name_of(bz.site_system()), "LabelCaption"])
	var total: int = bz.stages_total()
	if bz.complete():
		lines.append([StoryText.get_or("BAZ_NAME", "Star Bazaar"), "", ""])
	else:
		var cur: int = bz.current_stage()
		lines.append([StoryText.get_or("BAZ_STAGE_%d_NAME" % cur, "Stage %d" % cur), "%d / %d" % [bz.stage(), total], ""])
		for r in bz.bill_status():
			var names := []
			for g in r["goods"]:
				names.append(Ui.good_name(str(g)))
			var label := " / ".join(names) if not names.is_empty() else StoryText.get_or("PROS_NEED_LOCKED", "? Not known yet")
			var need: int = int(r["need"])
			lines.append([label, "%d / %d" % [mini(int(r["have"]), need), need], "" if bool(r["ok"]) else "LabelMuted"])
		var q: Dictionary = bz.quorum_status()
		lines.append([StoryText.get_or("BAZ_QUORUM_ROW", "{n} of {m} worlds at {tier}", {"n": mini(int(q["have"]), int(q["need"])), "m": int(q["need"]), "tier": StoryText.get_or("PROS_TIER_%d" % int(q["tier"]), "Tier %d" % int(q["tier"]))}), "" if not bool(q["ok"]) else StoryText.get_or("PROS_NEED_MET", "Met"), ""])
	if not main.free_play:
		var left: int = maxi(0, int(main.balance.get("win_cycle_markets", 0)) - int(main.cycle))
		lines.append([StoryText.get_or("BAZ_TERM_LEFT", "Term left: {cycles} cycles", {"cycles": left}), "", "LabelMuted"])
	var sig := str(lines)
	if sig != _sig:  # rebuild only when something changed
		_sig = sig
		for c in _box.get_children():
			_box.remove_child(c)
			c.queue_free()
		for ln in lines:
			_line(str(ln[0]), str(ln[1]), str(ln[2]))
	visible = true
