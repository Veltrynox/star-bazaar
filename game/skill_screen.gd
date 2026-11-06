extends PanelContainer
## Skill screen for the four market trees: a Foundations row on top, then one column per market with its
## seven nodes in tier order, linked by prerequisite lines. Skills and techs look different (tint and tag).
## A detail strip shows the selected node with a Learn button that learns at once. Learned bot skills get a Use menu.
## Does not pause the game. Open/close is owned by main.gd (K, Esc, Skills button).

const StoryText := preload("res://game/story_text.gd")
const SkillTree := preload("res://game/skill_tree.gd")
const SkillIcons := preload("res://game/skill_icons.gd")
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
const NODE_BTN_H := 50.4  # 0.9 of the old 56
const CELL_W := 129.6  # 0.9 of the old 144
const CELL_W_MAX := 420.0  # the cells grow to fill the window width, up to this
const WINDOW_MARGIN := 24.0  # gap between the skill window and the screen edge
const FND_WIDE_CELLS := 2  # Foundations column width (cells) when only one market is shown
const ICON_PX := 24  # skill icon on the node button
const TREE_RESERVE := 360.0  # window height kept for header, help, detail strip and footer; the tree gets the rest
const STACKED_BRANCHES := ["fnd"]  # these branches put every node on its own row (one narrow column)
const MAX_ROW_CELLS := 2  # a tier with more nodes wraps onto a second line, so four columns of 3 do not overflow 1500 px
const NODE_GAP_H := 15  # between nodes in a row
const NODE_GAP_V := 21  # between rows of a branch
const BRANCH_GAP := 30  # between branches
const CELL_GAP := 7  # inside a node cell
## UI-only empty slots that show the planned final size of the tree (never in data, saves, totals or navigation).
const SHOW_PLACEHOLDERS := false  # the ONE switch: false removes every placeholder
const PLACEHOLDER_GROWTH := 2.0  # planned tree size as a multiple of today's nodes; extra slots are added as whole rows under each branch
const PLACEHOLDER_COL := Color(1, 1, 1, 0.16)

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
var highlight: Array = []  # skill ids to point at (the steps to a permit), cleared on close
var placeholders: Array = []  # empty slot Controls (UI only, inert)
var _root: VBoxContainer
var _built_branch: String = ""  # run branch the node grid was built for
var _cell_w: float = CELL_W
var tree_scroll: ScrollContainer  # holds the four trees; scrolls vertically when they do not fit
var _tree: VBoxContainer  # the scrolled content, the connector lines are drawn on it

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
static func depth_rows(branches: Array = SkillTree.BRANCHES) -> Array:
	var out := []
	for b in branches:
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
	# the window fills the screen: all the width and height the viewport has, less a margin
	custom_minimum_size = Vector2(get_viewport_rect().size.x - WINDOW_MARGIN, get_viewport_rect().size.y - WINDOW_MARGIN)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	_root = VBoxContainer.new()
	_root.add_theme_constant_override("separation", 8)
	Ui.scroll_wrap(self, _root, 24.0)  # taller than the window: the page scrolls, nothing nested
	_root.size_flags_vertical = Control.SIZE_EXPAND_FILL  # the tree area takes every spare pixel of height
	(_root.get_parent() as Control).size_flags_vertical = Control.SIZE_EXPAND_FILL
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
	_tree = rows
	_tree.draw.connect(_draw_links)
	_tree.sort_children.connect(_tree.queue_redraw)
	_tree.minimum_size_changed.connect(_fit_tree.call_deferred)
	tree_scroll = ScrollContainer.new()
	tree_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	tree_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	tree_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var tree_gutter := MarginContainer.new()  # keeps the last column clear of the scrollbar
	tree_gutter.add_theme_constant_override("margin_right", 10)
	tree_gutter.add_theme_constant_override("margin_bottom", 6)
	tree_gutter.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree_gutter.add_child(rows)
	tree_scroll.add_child(tree_gutter)
	_root.add_child(tree_scroll)
	_rebuild_tree()
	detail_box = VBoxContainer.new()
	detail_box.custom_minimum_size = Vector2(0, 110)
	detail_box.add_theme_constant_override("separation", 4)
	_root.add_child(detail_box)
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


## Branches drawn for this run: Foundations plus the run's market tree; every tree for an old save.
func _branches() -> Array:
	return SkillTree.visible_branches(main.run_branch() if main != null else "")

## (Re)builds the node grid for the run's branch. Other branches are never created, so nothing of them can show.
func _rebuild_tree() -> void:
	_built_branch = main.run_branch() if main != null else ""
	for c in _tree.get_children():
		_tree.remove_child(c)
		c.queue_free()
	node_buttons.clear()
	cells.clear()
	use_rows.clear()
	use_buttons.clear()
	bars.clear()
	placeholders.clear()
	if selected != "" and not SkillTree.in_run(selected, _built_branch):
		selected = ""
	if VERTICAL_LAYOUT:
		_build_vertical(_tree)
	else:
		_build_horizontal(_tree)
	_shrink(_tree)

## Cell width: the visible columns share the window width (capped), never narrower than the old CELL_W.
func _cell_width(branches: Array, widths: Dictionary) -> float:
	var units := 0
	for b in branches:
		units += int(widths[b])
	var avail := custom_minimum_size.x - 24.0 - 24.0 - 10.0 - BRANCH_GAP * (branches.size() - 1)
	for b in branches:
		avail -= NODE_GAP_H * (int(widths[b]) - 1)
	return clampf(avail / float(maxi(1, units)), CELL_W, CELL_W_MAX)

## One column per branch, all in a single row; inside a column one row per depth (row 0 = no prerequisites,
## at the top). Branches in STACKED_BRANCHES put each node on its own row so the column stays one cell wide.
func _build_vertical(rows: VBoxContainer) -> void:
	var branches := _branches()
	var d_rows := depth_rows(branches)
	var band := HBoxContainer.new()
	band.add_theme_constant_override("separation", BRANCH_GAP)
	band.alignment = BoxContainer.ALIGNMENT_CENTER
	band.size_flags_vertical = Control.SIZE_EXPAND_FILL  # columns run the full height of the tree area
	rows.add_child(band)
	var wide: bool = branches.size() <= 2  # Foundations + one market: spread the nodes over the whole width
	var widths := {}
	for b in branches:
		var wd := 1
		if wide or not STACKED_BRANCHES.has(b):
			for r in d_rows:
				if r.has(b):
					wd = maxi(wd, mini((r[b] as Array).size(), _row_cap(b, wide)))
		widths[b] = wd
	_cell_w = _cell_width(branches, widths)
	for b in branches:
		var stacked: bool = STACKED_BRANCHES.has(b) and not wide
		var widest: int = widths[b]
		var w := widest * _cell_w + (widest - 1) * NODE_GAP_H
		var sec := VBoxContainer.new()
		sec.size_flags_vertical = Control.SIZE_EXPAND_FILL  # rows share the column height
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
				var ids: Array = r[b]
				var at := 0
				while at < ids.size():  # a tier with more than MAX_ROW_CELLS nodes wraps onto the next line
					groups.append(ids.slice(at, at + _row_cap(b, wide)))
					at += _row_cap(b, wide)
			for g in groups:
				var row := HBoxContainer.new()
				row.add_theme_constant_override("separation", NODE_GAP_H)
				row.size_flags_vertical = Control.SIZE_EXPAND_FILL
				sec.add_child(row)
				for id in g:
					var cell := _node_cell(id)
					cell.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # fixed width, rows line up on the left
					cell.custom_minimum_size.x = _cell_w
					row.add_child(cell)
		if SHOW_PLACEHOLDERS:
			_add_placeholder_rows(sec, 1 if stacked else widest, SkillTree.ids_in(b).size())

## Nodes per line in a branch: one market beside Foundations uses every column the width allows.
func _row_cap(b: String, wide: bool) -> int:
	if not wide:
		return MAX_ROW_CELLS
	return FND_WIDE_CELLS if b == "fnd" else 6

## Extra empty rows under a branch: enough slots for (PLACEHOLDER_GROWTH - 1) x its real nodes, `width` slots per row.
func _add_placeholder_rows(sec: VBoxContainer, width: int, nodes: int) -> void:
	for r in placeholder_row_count(nodes, width):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", NODE_GAP_H)
		sec.add_child(row)
		for i in width:
			var slot := _placeholder_slot()
			row.add_child(slot)
			placeholders.append(slot)

## Rows of placeholders for a branch with `nodes` real nodes (pure; tested).
static func placeholder_row_count(nodes: int, width: int, enabled: bool = SHOW_PLACEHOLDERS) -> int:
	if not enabled or width < 1:
		return 0
	return ceili(float(nodes) * (PLACEHOLDER_GROWTH - 1.0) / float(width))

## A dashed empty frame: no text, no icon, no tooltip, ignores the mouse and cannot take focus.
func _placeholder_slot() -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(_cell_w, NODE_BTN_H)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.focus_mode = Control.FOCUS_NONE
	c.draw.connect(func() -> void:
		var r := Rect2(Vector2.ZERO, c.size).grow(-1.0)
		var corners := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
		for side in 4:
			var a: Vector2 = corners[side]
			var b: Vector2 = corners[(side + 1) % 4]
			var seg := a.distance_to(b)
			var dir := (b - a) / seg
			var t := 0.0
			while t < seg:
				c.draw_line(a + dir * t, a + dir * minf(t + 6.0, seg), PLACEHOLDER_COL, 1.0)
				t += 12.0)
	return c

func _build_horizontal(rows: VBoxContainer) -> void:
	var branches := _branches()
	for r in depth_rows(branches):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		rows.add_child(row)
		for b in branches:
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

## The tree area takes its own height when the window has room, else the window height left over (then it scrolls).
func _fit_tree() -> void:
	if tree_scroll == null or not is_instance_valid(tree_scroll) or not is_inside_tree():
		return
	var avail := get_viewport_rect().size.y - TREE_RESERVE
	tree_scroll.custom_minimum_size.y = maxf(160.0, minf(_tree.get_combined_minimum_size().y + 8.0, avail))

## Smaller type for the whole window (the theme sizes are too large for 30 nodes).
func _shrink(n: Node) -> void:
	if n is Label:
		var big: bool = (n as Label).theme_type_variation == "LabelTitle"
		var sz := FONT_SIZE_TITLE if big else (FONT_SIZE - 1 if n.has_meta("dim") else FONT_SIZE)
		(n as Label).add_theme_font_size_override("font_size", sz)
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
	cell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cell.size_flags_stretch_ratio = 1.0
	cell.add_theme_constant_override("separation", CELL_GAP)
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, NODE_BTN_H)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.clip_text = true
	btn.icon = SkillIcons.texture(id)
	btn.expand_icon = true
	btn.add_theme_constant_override("icon_max_width", ICON_PX)
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
	if main != null and main.run_branch() != _built_branch:
		_rebuild_tree()  # the run choice arrived after setup
	visible = true
	refresh()
	_fit_tree.call_deferred()

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
	if selected != "" and node_buttons.has(selected):
		tree_scroll.ensure_control_visible.call_deferred(node_buttons[selected])

func select(id: String) -> void:
	if not SkillTree.in_run(id, _built_branch):
		return
	selected = id
	refresh()

# ---- refresh ----

func refresh() -> void:
	if main == null:
		return
	var learned: Array = main.learned_skills
	points_label.text = StoryText.get_text("SK_POINTS_COUNTER", {"n": main.skill_points})
	for id in node_buttons:
		var st := node_state(learned, main.skill_points, main.balance, id)
		var tech := SkillTree.is_tech(id)
		var btn: Button = node_buttons[id]
		btn.text = SkillTree.skill_name(id)
		if st != "learned" and main.skill_lock_reason(id) != "":
			st = "locked"  # earn-locked (Space Storage): muted like any locked node until the income line is met
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
	_tree.queue_redraw()
	call_deferred("_redraw_links")
	_fit_tree.call_deferred()

func _redraw_links() -> void:
	if _tree != null and is_instance_valid(_tree):
		_tree.queue_redraw()

## Prerequisite lines under the buttons: down from the prerequisite, across, down into the node.
func _draw_links() -> void:
	if main == null:
		return
	var origin := _tree.get_global_rect().position
	var learned: Array = main.learned_skills
	var boxes: Array[Rect2] = []  # every visible node box, tree-local; lines stop at their edges
	for cid in cells:
		var cc: Control = cells[cid]
		if cc.is_visible_in_tree():
			var cr := cc.get_global_rect()
			boxes.append(Rect2(cr.position - origin, cr.size))
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
			var pts := [p0, Vector2(p0.x, my), Vector2(p1.x, my), p1]
			for i in 3:
				for seg in clip_segment(pts[i], pts[i + 1], boxes):
					_tree.draw_line(seg[0], seg[1], col, 2.0)

## Axis-aligned segment a-b minus the node boxes it crosses: the pieces to draw, each [from, to].
static func clip_segment(a: Vector2, b: Vector2, boxes: Array) -> Array:
	var horizontal := absf(a.y - b.y) < 0.01
	var lo := minf(a.x, b.x) if horizontal else minf(a.y, b.y)
	var hi := maxf(a.x, b.x) if horizontal else maxf(a.y, b.y)
	var cuts: Array = []  # [from, to] ranges covered by a box
	for r: Rect2 in boxes:
		var c0: float
		var c1: float
		if horizontal:
			if a.y <= r.position.y or a.y >= r.end.y:
				continue
			c0 = r.position.x
			c1 = r.end.x
		else:
			if a.x <= r.position.x or a.x >= r.end.x:
				continue
			c0 = r.position.y
			c1 = r.end.y
		if c1 > lo and c0 < hi:
			cuts.append([c0, c1])
	cuts.sort_custom(func(u, v): return u[0] < v[0])
	var out: Array = []
	var at := lo
	for c in cuts:
		if c[0] > at:
			out.append([at, minf(c[0], hi)])
		at = maxf(at, c[1])
	if at < hi:
		out.append([at, hi])
	var res: Array = []
	for o in out:
		if horizontal:
			res.append([Vector2(o[0], a.y), Vector2(o[1], a.y)])
		else:
			res.append([Vector2(a.x, o[0]), Vector2(a.x, o[1])])
	return res

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
	_label(StoryText.get_or("SK_%s_PLAIN" % id, "", plain_args(main.balance, id)))  # line 1: what it does
	var story := _label(SkillTree.flavour(id))  # line 2: the story line, quieter than line 1
	story.set_meta("dim", true)
	story.modulate = Color(1, 1, 1, 0.7)
	var st := node_state(learned, main.skill_points, main.balance, id)
	if tech:
		var p: Dictionary = Tech.progress(id)
		var craft := StoryText.get_or("SK_%s_CRAFT" % id, "", {"n": int(p.get("n", 0)), "goal": int(p.get("goal", 0))})
		_label(craft if craft != "" else StoryText.get_text("SK_CRAFTED", {"n": int(p.get("n", 0)), "goal": int(p.get("goal", 0))}))
		_label(StoryText.get_text("SK_TECH_NO_POINTS"))
	var earn_lock: String = "" if (tech or st == "learned" or st == "locked") else main.skill_lock_reason(id)
	if earn_lock != "":
		_label(earn_lock)  # the reason a live-looking skill cannot be learned yet
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
			learn_button.text = learn_text(SkillTree.cost(main.balance, id))
	learn_button.disabled = st != "learnable" or earn_lock != "" or main.tut_lock_active()
	if earn_lock != "":
		learn_button.tooltip_text = earn_lock
	elif st == "points":
		learn_button.tooltip_text = StoryText.get_text("SK_NOT_ENOUGH")
	elif st == "locked" and not names.is_empty():
		learn_button.tooltip_text = StoryText.get_text("SK_NEEDS", {"skill": ", ".join(names)})
	learn_button.pressed.connect(confirm_learn)  # one step: the Learn button learns at once
	detail_box.add_child(learn_button)

## Learn button text with the cost in points: "Learn  ·  1 point" (singular for 1). Keys SK_LEARN_COST_ONE / SK_LEARN_COST.
static func learn_text(amount: int) -> String:
	var verb := StoryText.get_or("BTN_LEARN", "Learn")
	if amount == 1:
		return StoryText.get_or("SK_LEARN_COST_ONE", verb + "  ·  {amount} point", {"amount": amount})
	return StoryText.get_or("SK_LEARN_COST", verb + "  ·  {amount} points", {"amount": amount})

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
