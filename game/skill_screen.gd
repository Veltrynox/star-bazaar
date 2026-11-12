extends PanelContainer
## Skill screen for the four market trees: a full-width Foundations block on top, then one column per market with its
## seven nodes in tier order, linked by prerequisite lines. Skills and techs look different (tint and tag).
## A detail strip shows the selected node with a Learn button that learns at once. Learned bot skills get a Use menu.
## Does not pause the game. Open/close is owned by main.gd (K, Esc, Skills button).

const StoryText := preload("res://game/story_text.gd")
const SkillTree := preload("res://game/skill_tree.gd")
const SkillIcons := preload("res://game/skill_icons.gd")
const Juice := preload("res://game/juice.gd")
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
const NODE_BTN_H := 60.0  # room for two label lines plus padding
const CELL_W := 136.0  # node button width
const CELL_W_MAX := 146.0  # a little give when the window has room; buttons are not stretched to the window
const WINDOW_MAX := Vector2(1400.0, 920.0)  # the skill window never grows past this
const WINDOW_MARGIN := 48.0  # gap between the skill window and the screen edge
const ICON_PX := 24  # skill icon on the node button
const TREE_RESERVE := 190.0  # window height kept for header, help and footer; the tree gets the rest
const DETAIL_SCALE := 1.5  # right info panel type, a step above the tree (title 22, body 15)
const DETAIL_W := 400.0  # width of the skill info panel on the right of the tree
const MAX_ROW_CELLS := 2  # a tier with more nodes wraps onto a second line, so four columns of 3 do not overflow 1500 px
const NODE_GAP_H := 24  # between nodes in a row
const NODE_GAP_V := 26  # between rows of a branch
const BRANCH_GAP := 30  # between branches
const CELL_GAP := 7  # inside a node cell
## UI-only empty slots that show the planned final size of the tree (never in data, saves, totals or navigation).
const SHOW_PLACEHOLDERS := false  # the ONE switch: false removes every placeholder
const PLACEHOLDER_GROWTH := 2.0  # planned tree size as a multiple of today's nodes; extra slots are added as whole rows under each branch
const PLACEHOLDER_COL := Color(1, 1, 1, 0.16)

signal closed

# ---- juice (visual only; durations in seconds, scaled by Juice.motion) ----
const JUICE_INTRO_STAGGER := 0.025   # delay per depth row when the nodes pop in on open
const JUICE_INTRO_SECONDS := 0.2
const JUICE_INTRO_MAX_DELAY := 0.35  # cap so a deep tree still finishes quickly
const JUICE_HOVER_SCALE := 1.05      # node and button hover lift
const JUICE_HOVER_SECONDS := 0.12
const JUICE_PULSE_SECONDS := 1.8     # learnable border breathing
const JUICE_LINK_SECONDS := 0.55     # a new learned path lights up
const JUICE_DETAIL_SECONDS := 0.18   # detail panel crossfade on selection
const JUICE_DETAIL_FROM := 0.25

const RING_GAP := 4.0       # clear gap between a node button and its ring: the ring always encloses the button
const RING_RADIUS := 8.0    # corner radius of the node ring
const JUICE_BURST_SECONDS := 0.95  # learn burst: sweep, shock rings, sparks

## Border and glow drawn over a node button; reads state, never takes the mouse. The ring sits RING_GAP outside the
## button on every side, so it is never smaller than the button it belongs to.
class NodeFx extends Control:
	var state := "locked"
	var selected := false
	var hover := 0.0
	var pulse := 0.0   # 0..1, set by the screen's single loop
	var spin := 0.0    # 0..TAU, the same loop: a bright dash travels round a learnable ring
	var warm := Color.WHITE
	var soft := Color.WHITE
	var _ring := PackedVector2Array()
	var _ring_size := Vector2.ZERO

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func set_hover(v: float) -> void:
		hover = v
		queue_redraw()

	func _ring_pts() -> PackedVector2Array:
		if _ring_size != size or _ring.is_empty():
			_ring_size = size
			_ring = Juice.rr_points(Rect2(Vector2.ZERO, size).grow(RING_GAP), RING_RADIUS + RING_GAP)
		return _ring

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size).grow(RING_GAP)
		var pts := _ring_pts()
		match state:
			"learned":
				var a := 0.7 + 0.25 * hover
				draw_polyline(Juice.rr_points(r.grow(3.0), RING_RADIUS + RING_GAP + 3.0), Color(warm.r, warm.g, warm.b, 0.10 + 0.06 * hover), 3.0, true)  # outer glow
				draw_polyline(Juice.rr_points(r.grow(1.5), RING_RADIUS + RING_GAP + 1.5), Color(warm.r, warm.g, warm.b, 0.20 + 0.06 * hover), 1.0, true)  # thread
				draw_polyline(pts, Color(warm.r, warm.g, warm.b, a), 2.0, true)
				for c in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:  # corner studs
					draw_circle(c, 2.0, Color(warm.r, warm.g, warm.b, 0.9))
			"learnable", "researching":
				draw_polyline(pts, Color(soft.r, soft.g, soft.b, 0.22 + 0.35 * pulse + 0.25 * hover), 1.5, true)
				draw_polyline(Juice.rr_points(r.grow(2.5), RING_RADIUS + RING_GAP + 2.5), Color(soft.r, soft.g, soft.b, 0.14 * pulse), 1.0, true)
				var f := spin / TAU
				var dash := Juice.sub_polyline(pts, f, f + 0.16)
				if dash.size() > 1:
					draw_polyline(dash, Color(soft.r, soft.g, soft.b, 0.55 + 0.4 * pulse), 2.5, true)
			_:
				if hover > 0.0:
					draw_polyline(pts, Color(1, 1, 1, 0.25 * hover), 1.0, true)
		if selected:
			draw_polyline(Juice.rr_points(r.grow(2.0), RING_RADIUS + RING_GAP + 2.0), Color(warm.r, warm.g, warm.b, 0.95), 2.0, true)

## One-shot learn burst over a node: a progress sweep round a circle that encloses the button, then expanding shock
## rings, a crown of sparks and a core flash. Frees itself. Visual only.
class LearnBurst extends Control:
	var t := 0.0
	var tint := Color.WHITE
	var half := Vector2(60, 25)  # half size of the button

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func set_t(v: float) -> void:
		t = v
		queue_redraw()

	func _draw() -> void:
		var c := half  # drawn about the button centre (this control sits at the button's top-left)
		var r_in := half.length() + RING_GAP + 4.0  # a circle that encloses the whole button, with a gap
		var sweep := clampf(t / 0.4, 0.0, 1.0)
		var se := 1.0 - pow(1.0 - sweep, 3.0)
		var fade := 1.0 - clampf((t - 0.55) / 0.45, 0.0, 1.0)
		if fade > 0.0:
			draw_arc(c, r_in, 0.0, TAU, 72, Color(tint, 0.14 * fade), 1.0, true)  # track
			if se > 0.0:
				draw_arc(c, r_in, -PI * 0.5, -PI * 0.5 + TAU * se, 72, Color(tint, 0.95 * fade), 3.0, true)  # progress sweep
				draw_arc(c, r_in + 4.0, -PI * 0.5, -PI * 0.5 + TAU * se, 72, Color(tint, 0.30 * fade), 1.0, true)
				var ha := -PI * 0.5 + TAU * se  # bright head
				draw_circle(c + Vector2(cos(ha), sin(ha)) * r_in, 3.5 * fade, Color(1, 1, 1, 0.9 * fade))
			for i in 24:  # tick marks light up as the sweep passes them
				var a := -PI * 0.5 + TAU * float(i) / 24.0
				if float(i) / 24.0 <= se:
					var d := Vector2(cos(a), sin(a))
					draw_line(c + d * (r_in + 6.0), c + d * (r_in + 6.0 + (4.0 if i % 6 == 0 else 2.0)), Color(tint, 0.7 * fade), 1.0, true)
		var u := clampf((t - 0.3) / 0.7, 0.0, 1.0)  # shock rings start as the sweep closes
		Juice.draw_shock(self, c, r_in, r_in + 46.0, u, Color(tint.lerp(Color.WHITE, 0.25), 0.95), 3.0, 14)
		Juice.draw_shock(self, c, r_in, r_in + 30.0, clampf((t - 0.42) / 0.58, 0.0, 1.0), Color(tint, 0.6), 1.5, 0)
		if t < 0.3:  # core flash over the button
			var fa := 1.0 - t / 0.3
			draw_rect(Rect2(Vector2.ZERO, half * 2.0).grow(RING_GAP), Color(1, 0.95, 0.8, 0.22 * fa), true)

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
var node_fx: Dictionary = {}  # node id -> NodeFx
var _prev_learned: Variant = null  # learned set at the last refresh (null = fresh open, no burst)
var _intro_tw: Tween
var _pulse_tw: Tween
var _link_tw: Tween
var _link_id: String = ""  # node whose incoming links are lighting up
var _link_t: float = 1.0
var _last_detail_id: String = ""
var _last_points: int = -1
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
	custom_minimum_size = Vector2(minf(get_viewport_rect().size.x - WINDOW_MARGIN, WINDOW_MAX.x), minf(get_viewport_rect().size.y - WINDOW_MARGIN, WINDOW_MAX.y))
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
	_hover_lift(close)
	head.add_child(close)
	var help := Label.new()
	help.theme_type_variation = "LabelSmall"
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.text = StoryText.get_or("LBL_SKILL_POINTS_HELP", "Skill points: {planet} for each planet you first trade with, {route} for each new route between two planets, {system} for each new system you reach.", {"planet": int(main.balance.get("skill_points_planet", 0)), "route": int(main.balance.get("skill_points_route", 0)), "system": int(main.balance.get("skill_points_system", 0))})
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
	tree_gutter.add_theme_constant_override("margin_left", 14)  # room for the node rings (they sit outside the buttons) inside the scroll clip
	tree_gutter.add_theme_constant_override("margin_top", 14)
	tree_gutter.add_theme_constant_override("margin_right", 16)
	tree_gutter.add_theme_constant_override("margin_bottom", 14)
	tree_gutter.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree_gutter.add_child(rows)
	tree_scroll.add_child(tree_gutter)
	tree_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body := HBoxContainer.new()  # tree on the left, skill info panel on the right
	body.add_theme_constant_override("separation", 12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_root.add_child(body)
	body.add_child(tree_scroll)
	_rebuild_tree()
	var detail_scroll := ScrollContainer.new()
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_scroll.custom_minimum_size.x = DETAIL_W
	detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(detail_scroll)
	detail_box = VBoxContainer.new()
	detail_box.custom_minimum_size = Vector2(DETAIL_W - 12.0, 0)
	detail_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_box.add_theme_constant_override("separation", 4)
	detail_scroll.add_child(detail_box)
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
	node_fx.clear()  # the old NodeFx nodes are freed with the grid
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
	var avail := custom_minimum_size.x - 24.0 - 24.0 - 10.0 - DETAIL_W - 12.0 - BRANCH_GAP * (branches.size() - 1)
	for b in branches:
		avail -= NODE_GAP_H * (int(widths[b]) - 1)
	return clampf(avail / float(maxi(1, units)), CELL_W, CELL_W_MAX)

## Two blocks: Foundations across the full width on top (nodes in learning order, several cells per row), then one
## block below with the market columns side by side (one column for a run's tree). Inside a market column one row per
## depth (row 0 = no prerequisites, at the top).
func _build_vertical(rows: VBoxContainer) -> void:
	var branches := _branches()
	var markets: Array = branches.filter(func(x): return x != "fnd")
	var d_rows := depth_rows(branches)
	var wide: bool = markets.size() <= 1  # one market: spread its nodes over the whole width
	var widths := {}
	for b in markets:
		var wd := 1
		for r in d_rows:
			if r.has(b):
				wd = maxi(wd, mini((r[b] as Array).size(), _row_cap(wide)))
		widths[b] = wd
	_cell_w = _cell_width(markets, widths)
	rows.add_theme_constant_override("separation", BRANCH_GAP)
	if branches.has("fnd"):
		var fnd_ids: Array = []  # learning order: by depth, then as the tree lists them
		for r in d_rows:
			if r.has("fnd"):
				fnd_ids.append_array(r["fnd"])
		var tree_w := custom_minimum_size.x - 24.0 - 24.0 - 10.0 - DETAIL_W - 12.0
		var per_row := clampi(int(floor((tree_w + NODE_GAP_H) / (_cell_w + NODE_GAP_H))), 1, maxi(1, fnd_ids.size()))
		var fsec := VBoxContainer.new()
		fsec.add_theme_constant_override("separation", NODE_GAP_V)
		rows.add_child(fsec)
		fsec.add_child(_caption(StoryText.get_text("SK_TAB_FND")))
		fsec.add_child(HSeparator.new())
		var at := 0
		while at < fnd_ids.size():
			fsec.add_child(_node_row(fnd_ids.slice(at, at + per_row)))
			at += per_row
		if SHOW_PLACEHOLDERS:
			_add_placeholder_rows(fsec, per_row, fnd_ids.size())
	var band := HBoxContainer.new()
	band.add_theme_constant_override("separation", BRANCH_GAP)
	band.alignment = BoxContainer.ALIGNMENT_CENTER
	band.size_flags_vertical = Control.SIZE_EXPAND_FILL  # columns run the full height of the tree area
	rows.add_child(band)
	for b in markets:
		var widest: int = widths[b]
		var w := widest * _cell_w + (widest - 1) * NODE_GAP_H
		var sec := VBoxContainer.new()
		sec.size_flags_vertical = Control.SIZE_EXPAND_FILL  # rows share the column height
		sec.custom_minimum_size.x = w
		sec.add_theme_constant_override("separation", NODE_GAP_V)
		band.add_child(sec)
		var cap := _caption(StoryText.get_text("SK_TAB_" + b.to_upper()))
		cap.tooltip_text = StoryText.get_text("MKT_%s_ID" % b.to_upper())
		cap.mouse_filter = Control.MOUSE_FILTER_STOP
		sec.add_child(cap)
		sec.add_child(HSeparator.new())
		for r in d_rows:
			if not r.has(b):
				continue
			var ids: Array = r[b]
			var at := 0
			while at < ids.size():  # a tier with more nodes than a line holds wraps onto the next line
				var row := _node_row(ids.slice(at, at + _row_cap(wide)))
				row.size_flags_vertical = Control.SIZE_EXPAND_FILL
				sec.add_child(row)
				at += _row_cap(wide)
		if SHOW_PLACEHOLDERS:
			_add_placeholder_rows(sec, widest, SkillTree.ids_in(b).size())

## One line of node cells, fixed width, lined up on the left.
func _node_row(ids: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", NODE_GAP_H)
	for id in ids:
		var cell := _node_cell(id)
		cell.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		cell.custom_minimum_size.x = _cell_w
		row.add_child(cell)
	return row

## Nodes per line in a market column: a lone market uses every column the width allows.
func _row_cap(wide: bool) -> int:
	if not wide:
		return MAX_ROW_CELLS
	var tree_w := custom_minimum_size.x - 24.0 - 24.0 - 10.0 - DETAIL_W - 12.0  # as many cells as fit the tree area, 2..6
	return clampi(int(floor((tree_w + NODE_GAP_H) / (_cell_w + NODE_GAP_H))), 2, 6)

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
	var avail := custom_minimum_size.y - TREE_RESERVE
	tree_scroll.custom_minimum_size.y = maxf(160.0, minf(_tree.get_combined_minimum_size().y + 8.0, avail))

## Smaller type for the whole window (the theme sizes are too large for 30 nodes).
func _shrink(n: Node, k: float = 1.0) -> void:
	if n is Label:
		var big: bool = (n as Label).theme_type_variation == "LabelTitle"
		var sz := FONT_SIZE_TITLE if big else (FONT_SIZE - 1 if n.has_meta("dim") else FONT_SIZE)
		(n as Label).add_theme_font_size_override("font_size", int(sz * k))
	elif n is Button or n is MenuButton:
		n.add_theme_font_size_override("font_size", int(FONT_SIZE * (1.0 if n.has_meta("compact") else k)))
	for c in n.get_children():
		_shrink(c, k)

func _caption(text: String) -> Label:
	var l := Label.new()
	l.text = text.to_upper()
	l.theme_type_variation = "LabelCaption"
	return l

func _node_cell(id: String) -> Control:
	var cell := VBoxContainer.new()
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.size_flags_vertical = Control.SIZE_SHRINK_BEGIN  # the button keeps its own height, rows are not stretched
	cell.size_flags_stretch_ratio = 1.0
	cell.add_theme_constant_override("separation", CELL_GAP)
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, NODE_BTN_H)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_FILL
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.clip_text = true
	btn.icon = SkillIcons.texture(id)
	btn.expand_icon = true
	btn.add_theme_constant_override("icon_max_width", ICON_PX)
	btn.pressed.connect(select.bind(id))
	var fx := NodeFx.new()
	fx.warm = Ui.col("star_warm")
	fx.soft = COL_AVAILABLE
	btn.add_child(fx)
	node_fx[id] = fx
	_hover_lift(btn, fx)
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
	var was_open := visible
	_prev_learned = null
	_last_detail_id = ""
	_last_points = -1
	visible = true
	refresh()
	_fit_tree.call_deferred()
	if not was_open:
		Juice.enter(self, 0.97)
		_intro_nodes.call_deferred()
		_start_pulse()

func close_screen() -> void:
	if visible:
		_stop_juice()
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

# ---- juice ----

## Hover lift: scale about the centre, plus the border brightening on a node's fx layer.
func _hover_lift(btn: Button, fx: NodeFx = null) -> void:
	btn.mouse_entered.connect(_hover_to.bind(btn, fx, true))
	btn.mouse_exited.connect(_hover_to.bind(btn, fx, false))

func _hover_to(btn: Button, fx: NodeFx, on: bool) -> void:
	if Juice.motion <= 0.0 or not btn.is_inside_tree() or btn.disabled and fx == null:
		return
	btn.pivot_offset = btn.size * 0.5
	var k := 1.0 + (JUICE_HOVER_SCALE - 1.0) * Juice.motion
	var tw := btn.create_tween().set_parallel(true)
	tw.tween_property(btn, "scale", Vector2(k, k) if on else Vector2.ONE, JUICE_HOVER_SECONDS * Juice.motion) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if fx != null:
		tw.tween_method(fx.set_hover, fx.hover, 1.0 if on else 0.0, JUICE_HOVER_SECONDS * Juice.motion)
	if btn.has_meta("sk_hover_tw"):
		var old = btn.get_meta("sk_hover_tw")
		if old is Tween and old.is_valid():
			old.kill()
	btn.set_meta("sk_hover_tw", tw)

## Nodes fade and scale in, staggered by depth row.
func _intro_nodes() -> void:
	if Juice.motion <= 0.0 or not visible:
		return
	if _intro_tw != null and _intro_tw.is_valid():
		_intro_tw.kill()
	_intro_tw = create_tween().set_parallel(true)
	for id in cells:
		var c: Control = cells[id]
		if not c.is_visible_in_tree():
			continue
		var delay := minf(depth(id) * JUICE_INTRO_STAGGER, JUICE_INTRO_MAX_DELAY) * Juice.motion
		c.pivot_offset = c.size * 0.5
		c.modulate.a = 0.0
		c.scale = Vector2(0.9, 0.9)
		_intro_tw.tween_property(c, "modulate:a", 1.0, JUICE_INTRO_SECONDS * Juice.motion).set_delay(delay) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_intro_tw.tween_property(c, "scale", Vector2.ONE, JUICE_INTRO_SECONDS * Juice.motion).set_delay(delay) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_intro_tw.chain().tween_callback(_intro_rest)

func _intro_rest() -> void:
	for id in cells:
		var c: Control = cells[id]
		c.modulate.a = 1.0
		c.scale = Vector2.ONE

## One loop drives the breathing border of every learnable node (a handful of small redraws, nothing else).
func _start_pulse() -> void:
	if Juice.motion <= 0.0:
		return
	if _pulse_tw != null and _pulse_tw.is_valid():
		_pulse_tw.kill()
	_pulse_tw = create_tween().set_loops()
	_pulse_tw.tween_method(_set_pulse, 0.0, TAU, JUICE_PULSE_SECONDS)

func _set_pulse(a: float) -> void:
	var p := 0.5 - 0.5 * cos(a)
	for id in node_fx:
		var fx: NodeFx = node_fx[id]
		if not is_instance_valid(fx):
			continue
		if fx.state == "learnable" or fx.state == "researching":
			fx.pulse = p
			fx.queue_redraw()

func _stop_juice() -> void:
	for t in [_intro_tw, _pulse_tw, _link_tw]:
		if t != null and t.is_valid():
			t.kill()
	_link_id = ""
	_link_t = 1.0
	if not cells.is_empty():
		_intro_rest()

## A skill was just learned: ring, pop, warm flash, points readout pop, and its incoming links light up.
func _celebrate(id: String) -> void:
	var btn: Button = node_buttons.get(id)
	if btn == null or Juice.motion <= 0.0:
		return
	var warm := Ui.col("star_warm")
	var burst := LearnBurst.new()
	burst.tint = warm
	burst.half = btn.size * 0.5
	btn.add_child(burst)
	var btw := burst.create_tween()
	btw.tween_method(burst.set_t, 0.0, 1.0, JUICE_BURST_SECONDS * Juice.motion) \
		.set_trans(Tween.TRANS_LINEAR)
	btw.tween_callback(burst.queue_free)
	Juice.pop(btn, 1.12)
	Juice.flash(btn, warm * 1.6)
	_link_id = id
	_link_t = 0.0
	if _link_tw != null and _link_tw.is_valid():
		_link_tw.kill()
	_link_tw = create_tween()
	_link_tw.tween_method(_set_link_t, 0.0, 1.0, JUICE_LINK_SECONDS * Juice.motion) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _set_link_t(t: float) -> void:
	_link_t = t
	if t >= 1.0:
		_link_id = ""
	_tree.queue_redraw()

## Detail panel: a quick fade-up when another skill is selected.
func _detail_swap() -> void:
	if selected == _last_detail_id:
		return
	_last_detail_id = selected
	if Juice.motion <= 0.0 or not detail_box.is_inside_tree():
		return
	Juice.settle(detail_box, "detail")
	var tw := Juice._begin(detail_box, "detail", func() -> void: detail_box.modulate.a = 1.0)
	detail_box.modulate.a = JUICE_DETAIL_FROM
	tw.tween_property(detail_box, "modulate:a", 1.0, JUICE_DETAIL_SECONDS * Juice.motion) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

# ---- refresh ----

func refresh() -> void:
	if main == null:
		return
	var learned: Array = main.learned_skills
	points_label.text = StoryText.get_text("SK_POINTS_COUNTER", {"n": main.skill_points})
	if _last_points >= 0 and _last_points != main.skill_points:
		Juice.pop(points_label)
	_last_points = main.skill_points
	var fresh: Array = []
	if _prev_learned != null:
		for lid in learned:
			if not (_prev_learned as Array).has(lid):
				fresh.append(lid)
	_prev_learned = learned.duplicate()
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
		if node_fx.has(id):
			var fx: NodeFx = node_fx[id]
			fx.state = st
			fx.selected = id == selected
			fx.queue_redraw()
		btn.tooltip_text = "%s\n%s" % [SkillTree.skill_name(id), StoryText.get_or("SK_%s_PLAIN" % id, "", plain_args(main.balance, id))]
		if bars.has(id):
			var bar: ProgressBar = bars[id]
			var p: Dictionary = Tech.progress(id)
			bar.visible = st == "researching"
			bar.max_value = maxf(1.0, float(p.get("goal", 1)))
			bar.value = float(p.get("n", 0))
		_build_use_row(id, st)
	_build_detail()
	_shrink(detail_box, DETAIL_SCALE)
	_detail_swap()
	for lid in fresh:
		_celebrate(str(lid))
	_tree.queue_redraw()
	call_deferred("_redraw_links")
	_fit_tree.call_deferred()

func _redraw_links() -> void:
	if _tree != null and is_instance_valid(_tree):
		_tree.queue_redraw()

## Prerequisite lines under the buttons (owner 2026-11-12: thin, and never through a node). Each link is an orthogonal route:
## down out of the prerequisite into the gap under its line, across, down a clear lane (the nearest box edge whose vertical
## run meets no node), across in the gap above the node, down into it. Routes are computed once per layout (the cell rects
## are fingerprinted at draw time) and only redrawn afterwards; the learn animation changes colour and width, not geometry.
const LINK_W := 1.0          # locked link
const LINK_W_LIT := 1.5      # link out of a learned node
const LANE_PAD := 8.0        # a lane runs this far outside a node box
const BUS_IN := 12.0         # the horizontal run sits this far into the gap below a parent / above a node
const BOX_GROW := RING_GAP + 3.0  # routing clearance around a node: its ring plus a little air
var _routes: Array = []      # [{p: String, id: String, pts: PackedVector2Array}]
var _routes_key := 0         # fingerprint of the cell rects the routes were made for

func _draw_links() -> void:
	if main == null:
		return
	var origin := _tree.get_global_rect().position
	var rects := {}  # id -> tree-local Rect2 of every visible node
	var key := 0
	for cid in cells:
		var cc: Control = cells[cid]
		if cc.is_visible_in_tree():
			var cr := cc.get_global_rect()
			var r := Rect2(cr.position - origin, cr.size)
			rects[cid] = r
			key = hash([key, cid, r.position.x, r.position.y, r.size.x, r.size.y])
	if key != _routes_key:
		_routes_key = key
		_route_links(rects)
	var learned: Array = main.learned_skills
	for layer in 2:  # locked lines first, lit ones on top where they share a run
		for rt in _routes:
			var lit: bool = learned.has(rt["p"])
			if lit != (layer == 1):
				continue
			var col := COL_LEARNED if lit else COL_LOCKED
			var w := LINK_W_LIT if lit else LINK_W
			if rt["id"] == _link_id and lit:
				col = COL_LOCKED.lerp(COL_LEARNED, _link_t)  # a new path warms up
				w = LINK_W_LIT + 1.5 * (1.0 - _link_t)
			_tree.draw_polyline(rt["pts"], col, w, true)

func _route_links(rects: Dictionary) -> void:
	_routes.clear()
	var boxes: Array = []
	for cid in rects:
		boxes.append((rects[cid] as Rect2).grow(BOX_GROW))
	for id in rects:
		for p in SkillTree.prereqs(id):
			if rects.has(p):
				_routes.append({"p": p, "id": id, "pts": route_link(rects[p], rects[id], boxes)})

## Route from the bottom centre of `a` to the top centre of `b` (tree-local rects) that passes through no box of `boxes`
## (grown node rects). Two nodes on one line get a straight side-to-side link. Pure; tested.
static func route_link(a: Rect2, b: Rect2, boxes: Array) -> PackedVector2Array:
	var p0 := Vector2(a.position.x + a.size.x * 0.5, a.end.y)
	var p1 := Vector2(b.position.x + b.size.x * 0.5, b.position.y)
	if p1.y < p0.y + 1.0:  # same line: side to side at the shared middle height
		var left := a if a.position.x < b.position.x else b
		var right := b if left == a else a
		var y := (a.get_center().y + b.get_center().y) * 0.5
		return PackedVector2Array([Vector2(left.end.x, y), Vector2(right.position.x, y)])
	var bus_a := p0.y + BUS_IN
	var bus_b := p1.y - BUS_IN
	if bus_b < bus_a:  # neighbouring lines: one horizontal run in the middle of the gap
		bus_a = (p0.y + p1.y) * 0.5
		bus_b = bus_a
	var lane := p1.x
	if not _clear_v(lane, bus_a, bus_b, boxes):  # something sits between: take the nearest clear lane beside a box
		var best := INF
		for r: Rect2 in boxes:
			for x in [r.position.x - LANE_PAD, r.end.x + LANE_PAD]:
				var d := absf(x - p1.x)
				if d < best and _clear_v(x, bus_a, bus_b, boxes):
					best = d
					lane = x
	var raw := [p0, Vector2(p0.x, bus_a), Vector2(lane, bus_a), Vector2(lane, bus_b), Vector2(p1.x, bus_b), p1]
	var pts := PackedVector2Array()
	for q in raw:  # drop repeats and points on a straight run
		if pts.size() > 0 and pts[pts.size() - 1].is_equal_approx(q):
			continue
		if pts.size() > 1:
			var u: Vector2 = pts[pts.size() - 1] - pts[pts.size() - 2]
			var v: Vector2 = q - pts[pts.size() - 1]
			if absf(u.x * v.y - u.y * v.x) < 0.01 and u.dot(v) > 0.0:
				pts.remove_at(pts.size() - 1)
		pts.append(q)
	return pts

## True when a vertical run at `x` between y0 and y1 meets no box.
static func _clear_v(x: float, y0: float, y1: float, boxes: Array) -> bool:
	var lo := minf(y0, y1)
	var hi := maxf(y0, y1)
	for r: Rect2 in boxes:
		if r.position.x < x and x < r.end.x and r.end.y > lo and r.position.y < hi:
			return false
	return true

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
	_shrink(row, DETAIL_SCALE if row.get_parent() == detail_box else 1.0)

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
	_hover_lift(learn_button)
	learn_button.pressed.connect(confirm_learn)  # one step: the Learn button learns at once
	learn_button.set_meta("compact", true)  # owner 2026-11-12: a smaller Learn button, its frame glow no longer runs over the text above
	var learn_pad := MarginContainer.new()
	learn_pad.add_theme_constant_override("margin_top", 10)
	learn_pad.add_theme_constant_override("margin_bottom", 6)
	learn_pad.add_theme_constant_override("margin_left", 6)
	learn_pad.add_theme_constant_override("margin_right", 6)
	learn_pad.add_child(learn_button)
	detail_box.add_child(learn_pad)

## Learn button text with the cost in points: "Learn  ·  1 point" (singular for 1). Keys SK_LEARN_COST_ONE / SK_LEARN_COST.
static func learn_text(amount: int) -> String:
	var verb := StoryText.get_or("BTN_LEARN", "Learn")
	if amount == 1:
		return StoryText.get_or("SK_LEARN_COST_ONE", "{verb}  ·  {amount} point", {"verb": verb, "amount": amount})
	return StoryText.get_or("SK_LEARN_COST", "{verb}  ·  {amount} points", {"verb": verb, "amount": amount})

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
