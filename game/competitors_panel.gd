extends PanelContainer
## Competitors menu: one tab per market with a share-over-cycles line graph (player and the three bots),
## and a table of current share and the change over the last 5 cycles. Opened from the game menu, the share
## panel or L. Pauses like the game menu and restores the earlier pause state on close. Esc closes.
## Texts come from StoryText by id with plain fallbacks (LBL_COMP_*).

const StoryText := preload("res://game/story_text.gd")
const ShareGraph := preload("res://game/share_graph.gd")
const TREND_CYCLES := 5

signal closed

## Line graph. series: list of {name, color, values, width}. Axes: cycles 1..x_max, share 0..100%, dashed 50% line.
class Graph extends Control:
	var series: Array = []
	var x_max := 40
	func _init() -> void:
		custom_minimum_size = Vector2(0, 220)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
	func _draw() -> void:
		var font := Ui.mono_font()
		var fs := 11
		var left := 38.0
		var bottom := 20.0
		var r := Rect2(left, 6.0, maxf(10.0, size.x - left - 8.0), maxf(10.0, size.y - bottom - 6.0))
		draw_rect(r, Ui.col("panel_200"))
		for p in [0, 25, 50, 75, 100]:
			var y: float = r.end.y - r.size.y * float(p) / 100.0
			if p == 50:
				var x := r.position.x
				while x < r.end.x:
					draw_line(Vector2(x, y), Vector2(minf(x + 6.0, r.end.x), y), Ui.col("ink_muted"), 1.5)
					x += 11.0
			else:
				draw_line(Vector2(r.position.x, y), Vector2(r.end.x, y), Ui.col("line_100"), 1.0)
			draw_string(font, Vector2(2, y + 4), "%d%%" % p, HORIZONTAL_ALIGNMENT_RIGHT, left - 6.0, fs, Ui.col("ink_muted"))
		var step := 5
		var c := 1
		while c <= x_max:
			var x := _x(r, c)
			draw_string(font, Vector2(x - 10, size.y - 4), str(c), HORIZONTAL_ALIGNMENT_CENTER, 20.0, fs, Ui.col("ink_muted"))
			c = step if c == 1 else c + step
		for s in series:
			var vals: Array = s["values"]
			var pts := PackedVector2Array()
			for i in vals.size():
				pts.append(Vector2(_x(r, i + 1), r.end.y - r.size.y * clampf(float(vals[i]), 0.0, 1.0)))
			if pts.size() >= 2:
				draw_polyline(pts, s["color"], float(s["width"]), true)
			elif pts.size() == 1:
				draw_circle(pts[0], 3.0, s["color"])
	func _x(r: Rect2, cycle: int) -> float:
		return r.position.x + r.size.x * float(cycle - 1) / maxf(1.0, float(x_max - 1))

var main: Control
var _was_paused := false
var _root: VBoxContainer
var _tab_buttons: Dictionary = {}  # market id -> Button
var _market: String = ""
var _graph: Graph
var _legend: HBoxContainer
var _table: GridContainer
var _hdr_share: Label
var _hdr_trend: Label

## Player first, then the bots. Colour-blind-safe set from the theme tokens, with different widths.
static func line_color(i: int) -> Color:
	return Ui.col(["star_core", "signal_info", "signal_good", "signal_bad"][clampi(i, 0, 3)])

## "up 5" style trend text: arrow and whole points. Zero shows a dash.
static func trend_text(delta: float) -> String:
	var pts := roundi(delta * 100.0)
	if pts > 0:
		return "▲ %d" % pts
	if pts < 0:
		return "▼ %d" % -pts
	return "-"

func setup(main_node: Control) -> void:
	main = main_node
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	custom_minimum_size = Vector2(minf(620.0, get_viewport_rect().size.x - 24.0), 0)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	_root = VBoxContainer.new()
	_root.add_theme_constant_override("separation", 10)
	Ui.scroll_wrap(self, _root, 24.0)
	var head := HBoxContainer.new()
	_root.add_child(head)
	var title := Label.new()
	title.text = StoryText.get_or("LBL_COMP_TITLE", "Competitors")
	title.theme_type_variation = "LabelTitle"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var close := Button.new()
	close.theme_type_variation = "ButtonGhost"
	close.text = StoryText.get_or("SK_BTN_CLOSE", "Close")
	close.pressed.connect(close_screen)
	head.add_child(close)
	Markets.best()  # makes sure the registry is loaded
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	_root.add_child(tabs)
	for m in Markets.ids:
		var b := Button.new()
		b.text = str(Markets.names.get(m, m))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(select_market.bind(m))
		tabs.add_child(b)
		_tab_buttons[m] = b
	_graph = Graph.new()
	_root.add_child(_graph)
	_legend = HBoxContainer.new()
	_legend.add_theme_constant_override("separation", 14)
	_root.add_child(_legend)
	_table = GridContainer.new()
	_table.columns = 3
	_table.add_theme_constant_override("h_separation", 18)
	_table.add_theme_constant_override("v_separation", 4)
	_root.add_child(_table)
	if not Markets.ids.is_empty():
		_market = str(Markets.ids[0])

func open_screen() -> void:
	if visible:
		return
	_was_paused = main.paused
	main.set_paused(true)
	visible = true
	refresh()

func close_screen() -> void:
	if not visible:
		return
	visible = false
	if not main.game_over:
		main.set_paused(_was_paused)
	closed.emit()

func select_market(m: String) -> void:
	_market = m
	refresh()

## Names and series of the player and the bots for market m: [{name, values, share}].
func rows_for(m: String) -> Array:
	var bots := []
	for b in Bots.IDS:
		bots.append(Markets.bot_history(b, m))
	var s: Dictionary = ShareGraph.series(Markets.history(m), bots, Markets.window_for(m))
	var rows := [{"name": StoryText.get_or("LBL_SHARE_YOU", "You"), "values": s["player"], "share": Markets.share(m)}]
	for k in Bots.IDS.size():
		rows.append({"name": Bots.bot_name(Bots.IDS[k]), "values": s["bots"][k], "share": Markets.bot_share(Bots.IDS[k], m)})
	return rows

func refresh() -> void:
	if main == null or not visible or _market == "":
		return
	for m in _tab_buttons:
		var b: Button = _tab_buttons[m]
		b.theme_type_variation = "ButtonPrimary" if m == _market else "ButtonGhost"
	var rows := rows_for(_market)
	_graph.x_max = int(main.balance.get("win_cycle_markets", 40))
	_graph.series = []
	for i in rows.size():
		_graph.series.append({"name": rows[i]["name"], "color": line_color(i), "values": rows[i]["values"], "width": 3.5 if i == 0 else 2.0})
	_graph.queue_redraw()
	for c in _legend.get_children():
		_legend.remove_child(c)
		c.queue_free()
	for i in rows.size():
		var sw := ColorRect.new()
		sw.color = line_color(i)
		sw.custom_minimum_size = Vector2(16, 4)
		sw.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_legend.add_child(sw)
		var l := Label.new()
		l.theme_type_variation = "LabelSmall"
		l.text = str(rows[i]["name"])
		_legend.add_child(l)
	for c in _table.get_children():
		_table.remove_child(c)
		c.queue_free()
	_table.add_child(Control.new())
	_cell(StoryText.get_or("LBL_COMP_SHARE", "Share"), "LabelMuted", true)
	_cell(StoryText.get_or("LBL_COMP_TREND", "Last 5 cycles"), "LabelMuted", true)
	for i in rows.size():
		var name_l := Label.new()
		name_l.text = str(rows[i]["name"])
		name_l.add_theme_color_override("font_color", line_color(i))
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_table.add_child(name_l)
		_cell("%d%%" % roundi(float(rows[i]["share"]) * 100.0), "LabelNumber", true)
		var d: float = ShareGraph.change(rows[i]["values"], TREND_CYCLES)
		var t := _cell(trend_text(d), "LabelNumber", true)
		if roundi(d * 100.0) != 0:
			t.add_theme_color_override("font_color", Ui.col("signal_good") if d > 0.0 else Ui.col("signal_bad"))

func _cell(text: String, variation: String, right: bool) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = variation
	if right:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_table.add_child(l)
	return l
