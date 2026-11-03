extends PanelContainer
## Skill screen for the four market trees: a Foundations row on top, then one column per market with its
## seven nodes in tier order, linked by prerequisite lines. Skills and techs look different (tint and tag).
## A detail strip shows the selected node with a Learn button that learns at once. Learned bot skills get a Use menu.
## Does not pause the game. Open/close is owned by main.gd (K, Esc, Skills button).

const StoryText := preload("res://game/story_text.gd")
const SkillTree := preload("res://game/skill_tree.gd")
var COL_LEARNED: Color = Ui.col("star_warm")
var COL_AVAILABLE: Color = Color.WHITE
var COL_SHORT: Color = Color(0.82, 0.82, 0.82)
var COL_LOCKED: Color = Ui.col("ink_subtle") * 1.4
const TECH_TINT := Color(0.72, 0.88, 1.0)

## true: one column per branch side by side (all in one row), depth rows downward inside each (page scrolls vertically only).
## false: the old layout, one row per depth with the branches side by side.
const VERTICAL_LAYOUT := true  # true: branch columns in a vertical scroll; false: old wide layout
const FONT_SIZE := 10
const FONT_SIZE_TITLE := 15
const NODE_BTN_H := 56.0
const CELL_W := 144.0
const STACKED_BRANCHES := ["fnd"]  # these branches put every node on its own row (one narrow column)
const NODE_GAP_H := 10  # between nodes in a row
const NODE_GAP_V := 14  # between rows of a branch
const BRANCH_GAP := 20  # between branches
const CELL_GAP := 5  # inside a node cell

signal closed

var main: Control
var selected: String = ""
var node_buttons: Dictionary = {}  # node id -> Button (the tutorial highlight reads ["FND_PERMIT"])
var cells: Dictionary = {}  # node id -> the VBox holding the button (and its Use row)
var use_rows: Dictionary = {}  # node id -> HBox for bot skills
var bars: Dictionary = {}  # tech id -> ProgressBar
var points_label: Label
var detail_box: VBoxContainer
var learn_button: Button
var permit_box: VBoxContainer
var highlight: Array = []  # skill ids to point at (the steps to a permit), cleared on close
var _root: VBoxContainer

# ---- pure helpers (tested headless) ----

## Tier rows of one branch: [[ids of tier 1], [ids of tier 2], ...]; inside a row techs come first (left slot).
static func tier_rows(branch: String) -> Array:
	var by_tier := {}
	for id in SkillTree.ids_in(branch):
		var t := SkillTree.tier(id)
		if not by_tier.has(t):
			by_tier[t] = []
		if SkillTree.is_tech(id):
			by_tier[t].push_front(id)
		else:
			by_tier[t].append(id)
	var keys := by_tier.keys()
	keys.sort()
	var out := []
	for k in keys:
		out.append(by_tier[k])
	return out

## Depth of a node: 0 when it has no prerequisites (learnable right away), else 1 + the deepest prerequisite.
static func depth(id: String) -> int:
	var d := 0
	for p in SkillTree.prereqs(id):
		if SkillTree.has(p):
			d = maxi(d, depth(p) + 1)
	return d

## Rows by depth across all branches: [{branch: [ids]}, ...]; row 0 holds everything with no prerequisites.
static func depth_rows() -> Array:
	var out := []
	for b in SkillTree.BRANCHES:
		for id in SkillTree.ids_in(b):
			var d := depth(id)
			while out.size() <= d:
				out.append({})
			if not out[d].has(b):
				out[d][b] = []
			if SkillTree.is_tech(id):
				out[d][b].push_front(id)
			else:
				out[d][b].append(id)
	return out

## "learned", "locked", "researching" (a tech with prerequisites met), "points" (skill, too few points) or "learnable".
static func node_state(learned: Array, points: int, balance: Dictionary, id: String) -> String:
	match SkillTree.state(learned, id):
		"learned":
			return "learned"
		"locked":
			return "locked"
	if SkillTree.is_tech(id):
		return "researching"
	return "learnable" if points >= SkillTree.cost(balance, id) else "points"

## Numbers for the {m} (cooldown) and {n} (cycles) placeholders of a bot skill's plain line, plus {goal}.
static func plain_args(balance: Dictionary, id: String) -> Dictionary:
	var args := {"goal": SkillTree.tech_goal(balance, id), "m": 0, "n": 0}
	for e in SkillTree.effects(id):
		if e.has("cooldown_key"):
			args["m"] = int(balance.get(str(e["cooldown_key"]), 0))
		if e.has("duration_key"):
			args["n"] = int(balance.get(str(e["duration_key"]), 0))
	return args

# ---- build ----

func setup(main_node: Control) -> void:
	main = main_node
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	custom_minimum_size = Vector2(minf(1500.0, get_viewport_rect().size.x - 24.0), 0)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	_root = VBoxContainer.new()
	_root.add_theme_constant_override("separation", 8)
	Ui.scroll_wrap(self, _root, 24.0)  # taller than the window: the page scrolls, nothing nested
	_root.draw.connect(_draw_links)
	_root.sort_children.connect(_root.queue_redraw)
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
	var help := Label.new()
	help.theme_type_variation = "LabelSmall"
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.text = StoryText.get_or("LBL_SKILL_POINTS_HELP", "Skill points: 1 for each planet you first trade with, 2 for each new route between two planets, 3 for each new system you reach.")
	_root.add_child(help)
	# Tree area: row 0 = everything with no prerequisites, lower rows = locked behind prerequisites
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 6)
	_root.add_child(rows)
	if VERTICAL_LAYOUT:
		_build_vertical(rows)
	else:
		_build_horizontal(rows)
	detail_box = VBoxContainer.new()
	detail_box.custom_minimum_size = Vector2(0, 110)
	detail_box.add_theme_constant_override("separation", 4)
	_root.add_child(detail_box)
	permit_box = VBoxContainer.new()
	permit_box.add_theme_constant_override("separation", 4)
	_root.add_child(permit_box)
	var foot := Label.new()
	foot.text = StoryText.get_text("SK_NO_CREDITS")
	_root.add_child(foot)
	# fully opaque background (the theme panel is translucent)
	var sb: StyleBox = get_theme_stylebox("panel").duplicate()
	if sb is StyleBoxFlat:
		var c: Color = (sb as StyleBoxFlat).bg_color
		(sb as StyleBoxFlat).bg_color = Color(c.r, c.g, c.b, 1.0)
	else:
		var f := StyleBoxFlat.new()
		f.bg_color = Ui.col("panel_200")
		f.set_content_margin_all(12)
		sb = f
	add_theme_stylebox_override("panel", sb)
	_shrink(self)


## One column per branch, all in a single row; inside a column one row per depth (row 0 = no prerequisites,
## at the top). Branches in STACKED_BRANCHES put each node on its own row so the column stays one cell wide.
func _build_vertical(rows: VBoxContainer) -> void:
	var d_rows := depth_rows()
	var band := HBoxContainer.new()
	band.add_theme_constant_override("separation", BRANCH_GAP)
	rows.add_child(band)
	for b in SkillTree.BRANCHES:
		var stacked: bool = STACKED_BRANCHES.has(b)
		var widest := 1
		if not stacked:
			for r in d_rows:
				if r.has(b):
					widest = maxi(widest, (r[b] as Array).size())
		var w := widest * CELL_W + (widest - 1) * NODE_GAP_H
		var sec := VBoxContainer.new()
		sec.size_flags_vertical = Control.SIZE_SHRINK_BEGIN  # columns start at the top
		sec.custom_minimum_size.x = w
		sec.add_theme_constant_override("separation", NODE_GAP_V)
		band.add_child(sec)
		var cap := _caption(StoryText.get_text("SK_TAB_" + b.to_upper()))
		if b != "fnd":
			cap.tooltip_text = StoryText.get_text("MKT_%s_ID" % b.to_upper())
			cap.mouse_filter = Control.MOUSE_FILTER_STOP
		sec.add_child(cap)
		sec.add_child(HSeparator.new())
		for r in d_rows:
			if not r.has(b):
				continue
			var groups: Array = []
			if stacked:
				for id in r[b]:
					groups.append([id])
			else:
				groups.append(r[b])
			for g in groups:
				var row := HBoxContainer.new()
				row.add_theme_constant_override("separation", NODE_GAP_H)
				sec.add_child(row)
				for id in g:
					var cell := _node_cell(id)
					cell.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # fixed width, rows line up on the left
					cell.custom_minimum_size.x = CELL_W
					row.add_child(cell)

func _build_horizontal(rows: VBoxContainer) -> void:
	for r in depth_rows():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		rows.add_child(row)
		for b in SkillTree.BRANCHES:
			if not r.has(b):
				continue
			var ids: Array = r[b]
			var grp := VBoxContainer.new()
			grp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			grp.size_flags_stretch_ratio = float(ids.size())
			grp.add_theme_constant_override("separation", 2)
			row.add_child(grp)
			var cap := _caption(StoryText.get_text("SK_TAB_" + b.to_upper()))
			if b != "fnd":
				cap.tooltip_text = StoryText.get_text("MKT_%s_ID" % b.to_upper())
				cap.mouse_filter = Control.MOUSE_FILTER_STOP
			grp.add_child(cap)
			var cells_row := HBoxContainer.new()
			cells_row.add_theme_constant_override("separation", NODE_GAP_H)
			grp.add_child(cells_row)
			for id in ids:
				cells_row.add_child(_node_cell(id))

## Smaller type for the whole window (the theme sizes are too large for 30 nodes).
func _shrink(n: Node) -> void:
	if n is Label:
		var big: bool = (n as Label).theme_type_variation == "LabelTitle"
		(n as Label).add_theme_font_size_override("font_size", FONT_SIZE_TITLE if big else FONT_SIZE)
	elif n is Button or n is MenuButton:
		n.add_theme_font_size_override("font_size", FONT_SIZE)
	for c in n.get_children():
		_shrink(c)

func _caption(text: String) -> Label:
	var l := Label.new()
	l.text = text.to_upper()
	l.theme_type_variation = "LabelCaption"
	return l

func _node_cell(id: String) -> Control:
	var cell := VBoxContainer.new()
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.size_flags_stretch_ratio = 1.0
	cell.add_theme_constant_override("separation", CELL_GAP)
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, NODE_BTN_H)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.clip_text = true
	btn.pressed.connect(select.bind(id))
	cell.add_child(btn)
	node_buttons[id] = btn
	cells[id] = cell
	if SkillTree.is_tech(id):
		var bar := ProgressBar.new()
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 8)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		bar.offset_top = -12.0
		bar.offset_left = 6.0
		bar.offset_right = -6.0
		bar.offset_bottom = -4.0
		btn.add_child(bar)
		bars[id] = bar
	var use := HBoxContainer.new()
	use.visible = false
	cell.add_child(use)
	use_rows[id] = use
	return cell

# ---- open / close ----

func open_screen() -> void:
	visible = true
	refresh()

func close_screen() -> void:
	if visible:
		visible = false
		selected = ""
		highlight = []
		closed.emit()

## Open the screen with the given steps lit; the first one is selected.
func open_highlight(ids: Array) -> void:
	highlight = ids.duplicate()
	selected = str(ids[0]) if not ids.is_empty() else ""
	open_screen()

func select(id: String) -> void:
	selected = id
	refresh()

# ---- refresh ----

func _status_line(id: String, st: String) -> String:
	match st:
		"learned":
			return StoryText.get_text("SK_BTN_LEARNED")
		"locked":
			var need := SkillTree.missing_prereqs(main.learned_skills, id)
			return StoryText.get_text("SK_LOCKED_NEEDS", {"name": SkillTree.skill_name(str(need[0]))}) if not need.is_empty() else StoryText.get_text("SK_BTN_LOCKED")
		"researching":
			var p: Dictionary = Tech.progress(id)
			return StoryText.get_text("SK_CRAFTED", {"n": int(p.get("n", 0)), "goal": int(p.get("goal", 0))})
		"points":
			return StoryText.get_text("SK_NOT_ENOUGH")
	var lock: String = main.skill_lock_reason(id)
	if lock != "":
		return lock
	return StoryText.get_text("SK_COST", {"amount": SkillTree.cost(main.balance, id)})

func refresh() -> void:
	if main == null:
		return
	var learned: Array = main.learned_skills
	points_label.text = StoryText.get_text("SK_POINTS_COUNTER", {"n": main.skill_points})
	for id in node_buttons:
		var st := node_state(learned, main.skill_points, main.balance, id)
		var tech := SkillTree.is_tech(id)
		var btn: Button = node_buttons[id]
		var kind := StoryText.get_text("SK_KIND_TECH" if tech else "SK_KIND_SKILL")
		btn.text = "%s\n%s\n%s" % [SkillTree.skill_name(id), kind, _status_line(id, st)]
		var col := COL_LEARNED if st == "learned" else (COL_AVAILABLE if st in ["learnable", "researching"] else (COL_SHORT if st == "points" else COL_LOCKED))
		if tech and st != "locked" and st != "learned":
			col = col * TECH_TINT
		btn.self_modulate = col
		if highlight.has(id) and st != "learned":
			btn.self_modulate = COL_LEARNED * 1.5  # lit step on the way to a permit
		btn.tooltip_text = "%s\n%s" % [SkillTree.skill_name(id), StoryText.get_or("SK_%s_PLAIN" % id, "", plain_args(main.balance, id))]
		if bars.has(id):
			var bar: ProgressBar = bars[id]
			var p: Dictionary = Tech.progress(id)
			bar.visible = st == "researching"
			bar.max_value = maxf(1.0, float(p.get("goal", 1)))
			bar.value = float(p.get("n", 0))
		_build_use_row(id, st)
	_build_detail()
	_shrink(detail_box)
	_build_permits()
	_root.queue_redraw()
	call_deferred("_redraw_links")

func _redraw_links() -> void:
	if _root != null and is_instance_valid(_root):
		_root.queue_redraw()

## Prerequisite lines under the buttons: down from the prerequisite, across, down into the node.
func _draw_links() -> void:
	if main == null:
		return
	var origin := _root.get_global_rect().position
	var learned: Array = main.learned_skills
	for id in cells:
		for p in SkillTree.prereqs(id):
			if not cells.has(p):
				continue
			var a: Control = cells[p]
			var b: Control = cells[id]
			if not a.is_visible_in_tree() or not b.is_visible_in_tree():
				continue
			var ra := a.get_global_rect()
			var rb := b.get_global_rect()
			var p0 := Vector2(ra.position.x + ra.size.x * 0.5, ra.end.y) - origin
			var p1 := Vector2(rb.position.x + rb.size.x * 0.5, rb.position.y) - origin
			var my := (p0.y + p1.y) * 0.5
			var col := COL_LEARNED if learned.has(p) else COL_LOCKED
			_root.draw_polyline(PackedVector2Array([p0, Vector2(p0.x, my), Vector2(p1.x, my), p1]), col, 2.0)

## Bot skills (Embargo Desk, Guild Seal): a Use menu when ready, else the cooldown or used note.
func _build_use_row(id: String, st: String) -> void:
	var row: HBoxContainer = use_rows[id]
	for c in row.get_children():
		row.remove_child(c)
		c.queue_free()
	row.visible = false
	use_buttons.erase(id)
	if st != "learned" or not Skills.bot_skill_ids().has(id):
		return
	row.visible = true
	var left := Skills.bot_skill_cooldown(id)
	if left == 0:
		var mb := MenuButton.new()
		mb.text = StoryText.get_or("SK_BOT_USE", "Use on...")
		mb.flat = false
		mb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var pop := mb.get_popup()
		for b in Bots.IDS:
			pop.add_item(Bots.bot_name(b), b)
		pop.id_pressed.connect(func(bot: int) -> void: _use_bot(id, bot))
		row.add_child(mb)
		use_buttons[id] = mb
	else:
		var l := Label.new()
		l.theme_type_variation = "LabelSmall"
		l.text = StoryText.get_or("SK_BOT_USED", "Used this run.") if left == -1 else StoryText.get_or("SK_BOT_COOLDOWN", "Ready in {n} cycles.", {"n": left})
		row.add_child(l)
	_shrink(row)

var use_buttons: Dictionary = {}  # bot skill id -> MenuButton while ready

## Called by the Use menu (tests call it directly).
func _use_bot(id: String, bot: int) -> Dictionary:
	var r: Dictionary = Skills.activate_bot_skill(id, bot)
	refresh()
	return r

# ---- permits (the only place a system permit is bought) ----

func _build_permits() -> void:
	for c in permit_box.get_children():
		permit_box.remove_child(c)
		c.queue_free()
	for sid in main.Systems.ids():
		var sys: Dictionary = main.Systems.get_system(int(sid))
		var cost: int = main.permit_cost(int(sid))
		var pts: int = main.permit_points(int(sid))
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
		var cost_l := Label.new()
		cost_l.theme_type_variation = "LabelSmall"
		# FALLBACK: no story ids for the permit cost line or the reasons; plain text until the story designer adds them
		cost_l.text = StoryText.get_or("PERMIT_COST_LINE", "Cost: {credits} credits and {points} skill points.", {"credits": cost, "points": pts})
		match v["reason"]:
			"skill":
				cost_l.text += " " + StoryText.get_or("PERMIT_NEEDS_C1", "Needs Permit Charter.")
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
	_shrink(permit_box)

# ---- detail strip ----

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
	if selected == "" or not SkillTree.has(selected):
		_label(StoryText.get_text("SK_NONE_SELECTED"))
		return
	var id := selected
	var learned: Array = main.learned_skills
	var tech := SkillTree.is_tech(id)
	_label("%s  (%s)" % [SkillTree.skill_name(id), StoryText.get_text("SK_KIND_TECH" if tech else "SK_KIND_SKILL")], 20)
	_label(SkillTree.flavour(id))
	_label(StoryText.get_text("SK_LABEL_EFFECT") + ": " + StoryText.get_or("SK_%s_PLAIN" % id, "", plain_args(main.balance, id)))
	var st := node_state(learned, main.skill_points, main.balance, id)
	if tech:
		var p: Dictionary = Tech.progress(id)
		var craft := StoryText.get_or("SK_%s_CRAFT" % id, "", {"n": int(p.get("n", 0)), "goal": int(p.get("goal", 0))})
		_label(craft if craft != "" else StoryText.get_text("SK_CRAFTED", {"n": int(p.get("n", 0)), "goal": int(p.get("goal", 0))}))
		_label(StoryText.get_text("SK_TECH_NO_POINTS"))
	else:
		_label(StoryText.get_text("SK_COST", {"amount": SkillTree.cost(main.balance, id)}))
	var need := SkillTree.missing_prereqs(learned, id)
	var names := []
	for p in need:
		names.append(SkillTree.skill_name(p))
	if not names.is_empty():
		_label(StoryText.get_text("SK_NEEDS", {"skill": ", ".join(names)}))
	if st == "points":
		_label(StoryText.get_text("SK_NOT_ENOUGH"))
	if tech:
		return  # a tech is finished by crafting, nothing to click
	learn_button = Button.new()
	learn_button.theme_type_variation = "ButtonPrimary"
	match st:
		"learned":
			learn_button.text = StoryText.get_text("SK_BTN_LEARNED")
		"locked":
			learn_button.text = StoryText.get_text("SK_BTN_LOCKED")
		_:
			learn_button.text = StoryText.get_text("BTN_LEARN")
	learn_button.disabled = st != "learnable"
	if st == "points":
		learn_button.tooltip_text = StoryText.get_text("SK_NOT_ENOUGH")
	elif st == "locked" and not names.is_empty():
		learn_button.tooltip_text = StoryText.get_text("SK_NEEDS", {"skill": ", ".join(names)})
	learn_button.pressed.connect(confirm_learn)  # one step: the Learn button learns at once
	detail_box.add_child(learn_button)

## Called by the Learn button (tests call it directly).
func confirm_learn() -> void:
	if selected != "":
		main.learn_skill(selected)

## True: the detail strip holds no Yes/No confirm row (tests).
func confirm_row_absent() -> bool:
	for c in detail_box.get_children():
		if c is HBoxContainer:
			return false
	return true
