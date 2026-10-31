extends PanelContainer
## T71: skill tree screen (gdd-skills.md section 6). Three branch columns, detail panel, Learn with confirm.
## Does not pause the game. Open/close is owned by main.gd (K, Esc, Skills button).

const StoryText := preload("res://game/story_text.gd")
const SkillTree := preload("res://game/skill_tree.gd")
var COL_LEARNED: Color = Ui.col("star_warm")
var COL_AVAILABLE: Color = Color.WHITE
var COL_LOCKED: Color = Ui.col("ink_subtle") * 1.4

signal closed

var main: Control
var selected: String = ""
var node_buttons: Dictionary = {}
var points_label: Label
var detail_box: VBoxContainer
var learn_button: Button
var confirm_row: HBoxContainer
var confirm_label: Label
var _root: VBoxContainer
var permit_box: VBoxContainer  # T85: permits list under the tree
var highlight: Array = []  # T128: skill ids to point at (the steps to a permit), cleared on close

func setup(main_node: Control) -> void:
	main = main_node
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	custom_minimum_size = Vector2(minf(760.0, get_viewport_rect().size.x - 24.0), 0)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	_root = VBoxContainer.new()
	_root.add_theme_constant_override("separation", 10)
	Ui.scroll_wrap(self, _root, 24.0)  # taller than the window: the tree scrolls
	var head := HBoxContainer.new()
	_root.add_child(head)
	var title := Label.new()
	title.text = StoryText.get_text("SK_HEADER")
	title.theme_type_variation = "LabelTitle"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	points_label = Label.new()
	points_label.theme_type_variation = "LabelReadout"
	head.add_child(points_label)
	var close := Button.new()
	close.text = StoryText.get_text("SK_BTN_CLOSE")
	close.pressed.connect(close_screen)
	head.add_child(close)
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 16)
	_root.add_child(cols)
	for b in SkillTree.BRANCHES:
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_theme_constant_override("separation", 6)
		cols.add_child(col)
		var h := Label.new()
		h.text = StoryText.get_text("SK_BRANCH_" + b)
		h.theme_type_variation = "LabelCaption"
		h.text = h.text.to_upper()
		col.add_child(h)
		for id in SkillTree.ids_in(b):
			var btn := Button.new()
			btn.custom_minimum_size = Vector2(0, 48)
			btn.pressed.connect(select.bind(id))
			col.add_child(btn)
			node_buttons[id] = btn
	detail_box = VBoxContainer.new()
	detail_box.custom_minimum_size = Vector2(0, 190)
	detail_box.add_theme_constant_override("separation", 4)
	_root.add_child(detail_box)
	permit_box = VBoxContainer.new()
	permit_box.add_theme_constant_override("separation", 4)
	_root.add_child(permit_box)
	var foot := Label.new()
	foot.text = StoryText.get_text("SK_NO_CREDITS")
	_root.add_child(foot)

func open_screen() -> void:
	visible = true
	refresh()

func close_screen() -> void:
	if visible:
		visible = false
		selected = ""
		highlight = []
		closed.emit()

## T128: open the screen with the given steps lit; the first one not yet learned is selected.
func open_highlight(ids: Array) -> void:
	highlight = ids.duplicate()
	selected = str(ids[0]) if not ids.is_empty() else ""
	_hide_confirm()
	open_screen()

func select(id: String) -> void:
	selected = id
	_hide_confirm()
	refresh()


func refresh() -> void:
	if main == null:
		return
	var learned: Array = main.learned_skills
	points_label.text = "%s: %d" % [StoryText.get_text("SK_POINTS_LEFT"), main.skill_points]
	for id in node_buttons:
		var st := SkillTree.state(learned, id, main.skill_ctx())
		var btn: Button = node_buttons[id]
		btn.text = "%s\n%s" % [SkillTree.skill_name(id), StoryText.get_text("SK_STATE_" + st.to_upper())]
		btn.self_modulate = COL_LEARNED if st == "learned" else (COL_AVAILABLE if st == "available" else COL_LOCKED)
		if highlight.has(id) and st != "learned":
			btn.self_modulate = COL_LEARNED * 1.5  # T128: lit step on the way to a permit
	_build_detail()
	_build_permits()

## T85: one entry per system with a permit. Buying needs C1, credits and expansion points.
func _build_permits() -> void:
	for c in permit_box.get_children():
		permit_box.remove_child(c)
		c.queue_free()
	for sid in main.Systems.ids():
		var sys: Dictionary = main.Systems.get_system(int(sid))
		var cost: int = main.permit_cost(int(sid))
		var pts: int = main.Systems.permit_points(main.balance, int(sid))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		permit_box.add_child(row)
		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		var name_l := Label.new()
		name_l.text = StoryText.get_text(str(sys.get("permit_name_id", "")))
		name_l.theme_type_variation = "LabelStrong"
		info.add_child(name_l)
		var desc := Label.new()
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.theme_type_variation = "LabelSmall"
		desc.text = StoryText.get_text(str(sys.get("permit_desc_id", "")))
		info.add_child(desc)
		var v: Dictionary = main.can_buy_permit(int(sid))
		if main.has_skill("C2") and not main.open_systems.has(int(sid)):  # C2 Survey Beacon: planets seen before the permit
			var names := []
			for p in main.Systems.planets_of(int(sid)):
				names.append(str(p["name"]))
			var seen := Label.new()
			seen.theme_type_variation = "LabelSmall"
			seen.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			seen.text = StoryText.get_text("LBL_PERMIT_PLANETS", {"names": ", ".join(names)})
			info.add_child(seen)
		var cost_l := Label.new()
		cost_l.theme_type_variation = "LabelSmall"
		# FALLBACK: no story ids for the permit cost line or the reasons; plain text until the story designer adds them
		cost_l.text = StoryText.get_or("PERMIT_COST_LINE", "Cost: {credits} credits and {points} skill points.", {"credits": cost, "points": pts})
		match v["reason"]:
			"skill":
				cost_l.text += " " + StoryText.get_or("PERMIT_NEEDS_C1", "Needs Permit Charter (C1).")
			"credits":
				cost_l.text += " " + StoryText.get_or("PERMIT_NO_CREDITS", "Not enough credits.")
			"points":
				cost_l.text += " " + StoryText.get_text("NOT_SKILL_NO_POINTS")
		info.add_child(cost_l)
		var btn := Button.new()
		btn.text = StoryText.get_text(str(sys.get("permit_btn_id", ""))) if v["reason"] != "owned" else StoryText.get_text("SK_BTN_LEARNED")
		btn.disabled = not v["ok"]
		if v["reason"] != "owned":
			btn.tooltip_text = cost_l.text  # the cost line already carries the reason
		var id_i: int = int(sid)
		btn.pressed.connect(func(): main.buy_permit(id_i))
		row.add_child(btn)

func _label(text: String, size: int = 0) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if size > 0:
		l.theme_type_variation = "LabelTitle"
	detail_box.add_child(l)
	return l

func _build_detail() -> void:
	for c in detail_box.get_children():
		c.queue_free()
		detail_box.remove_child(c)
	learn_button = null
	confirm_row = null
	if selected == "":
		_label(StoryText.get_text("SK_NONE_SELECTED"))
		return
	var id := selected
	var learned: Array = main.learned_skills
	_label(SkillTree.skill_name(id), 20)
	_label(StoryText.get_text("SK_%s_FLAVOUR" % id))
	_label(StoryText.get_text("SK_LABEL_EFFECT") + ": " + StoryText.get_text("SK_%s_PLAIN" % id))
	_label(StoryText.get_text("SK_COST", {"amount": SkillTree.cost(main.balance, id)}))
	var need := SkillTree.missing_prereqs(learned, id)
	if not need.is_empty():
		var names := []
		for p in need:
			names.append(SkillTree.skill_name(p))
		_label(StoryText.get_text("SK_NEEDS", {"skill": ", ".join(names)}))
	if id == "A1" and not learned.has("A1") and not main.a1_gate_open():
		_label(StoryText.get_text("SK_A1_GATE"))
	var verdict := SkillTree.can_learn(learned, main.skill_points, main.balance, id, main.skill_ctx())
	if verdict["reason"] == "points":
		_label(StoryText.get_text("SK_LABEL_NEEDS_POINTS"))
	if id == "C1" and main.unowned_systems().is_empty():
		_label(StoryText.get_text("NOT_SKILL_NO_SYSTEMS"))
	learn_button = Button.new()
	learn_button.theme_type_variation = "ButtonPrimary"
	match verdict["reason"]:
		"known":
			learn_button.text = StoryText.get_text("SK_BTN_LEARNED")
		"locked":
			learn_button.text = StoryText.get_text("SK_BTN_LOCKED")
		_:
			learn_button.text = StoryText.get_text("BTN_LEARN")
	learn_button.disabled = not verdict["ok"]
	if learn_button.disabled:  # reason on hover, from ids that already exist
		match verdict["reason"]:
			"points":
				learn_button.tooltip_text = StoryText.get_text("SK_LABEL_NEEDS_POINTS")
			"locked":
				var names := []
				for p in need:
					names.append(SkillTree.skill_name(p))
				if not names.is_empty():
					learn_button.tooltip_text = StoryText.get_text("SK_NEEDS", {"skill": ", ".join(names)})
	learn_button.pressed.connect(_ask_confirm)
	detail_box.add_child(learn_button)
	confirm_row = HBoxContainer.new()
	confirm_row.visible = false
	detail_box.add_child(confirm_row)
	confirm_label = Label.new()
	confirm_label.text = StoryText.get_text("SK_CONFIRM", {"skill": SkillTree.skill_name(id)})
	confirm_row.add_child(confirm_label)
	var yes := Button.new()
	yes.theme_type_variation = "ButtonPrimary"
	yes.text = StoryText.get_text("BTN_YES")
	yes.pressed.connect(confirm_learn)
	confirm_row.add_child(yes)
	var no := Button.new()
	no.theme_type_variation = "ButtonGhost"
	no.text = StoryText.get_text("BTN_NO")
	no.pressed.connect(_hide_confirm)
	confirm_row.add_child(no)

func _ask_confirm() -> void:
	if confirm_row != null:
		confirm_row.visible = true

func _hide_confirm() -> void:
	if confirm_row != null and is_instance_valid(confirm_row):
		confirm_row.visible = false

## Called by the Yes button (tests call it directly).
func confirm_learn() -> void:
	if selected != "":
		main.learn_skill(selected)
