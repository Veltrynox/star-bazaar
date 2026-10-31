class_name Ui
## Reads colours and icons from the project Theme (design/theme/star_bazaar.tres), so no screen hard-codes them.
## Colour names are the design-token names with "_" for "-" (e.g. "star_warm", "signal_bad", "ink_muted").

static func col(token: String) -> Color:
	var t := ThemeDB.get_project_theme()
	if t != null and t.has_color(token, "Colors"):
		return t.get_color(token, "Colors")
	return Color.WHITE

## System map orbit rings: planet orbits use line-200 (#ffffff2e), the dashed outer orbit uses line-100 (#ffffff14).
const LINE_ORBIT := "orbit_line"
const LINE_ORBIT_OUTER := "orbit_line_outer"

static func orbit_line() -> Color:
	return col(LINE_ORBIT)

static func orbit_line_outer() -> Color:
	return col(LINE_ORBIT_OUTER)

static func icon(token: String) -> Texture2D:
	var t := ThemeDB.get_project_theme()
	if t != null and t.has_icon(token, "Icons"):
		return t.get_icon(token, "Icons")
	return null

## Mono face (JetBrains Mono) for numbers, from the theme's LabelReadout variation.
static func mono_font() -> Font:
	var t := ThemeDB.get_project_theme()
	if t != null and t.has_font("font", "LabelReadout"):
		return t.get_font("font", "LabelReadout")
	return ThemeDB.fallback_font

## Artist texture from art/textures/ui/ (name without extension); null when the file is not there yet.
static func ui_texture(name: String) -> Texture2D:
	for ext in ["png", "webp", "jpg"]:
		var p := "res://art/textures/ui/%s.%s" % [name, ext]
		if ResourceLoader.exists(p):
			return load(p) as Texture2D
	return null

## The one main action of a screen: large amber button with a left icon and a chevron on the right.
static func primary_button(text: String, icon_token: String = "") -> Button:
	var b := Button.new()
	b.theme_type_variation = "ButtonPrimaryLarge"
	b.text = text
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	if icon_token != "":
		b.icon = icon(icon_token)
	var ch := TextureRect.new()
	ch.texture = icon("chevron")
	ch.modulate = col("star_warm")
	ch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ch.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ch.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ch.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	ch.offset_left = -34
	ch.offset_right = -14
	ch.offset_top = -10
	ch.offset_bottom = 10
	b.add_child(ch)
	return b

## The one clickable cue. Every enabled button (any screen, also ones built later) gets a pointing-hand cursor; a disabled
## button keeps the default arrow. The hover look (lit fill) and the dimmed disabled look come from the theme's button styles.
## Clickable rows that are not buttons (planet thumbnails, galaxy nodes) draw the same star_warm hover outline themselves.
static func install_cursors(tree: SceneTree) -> void:
	if tree == null or tree.root.has_meta("ui_cursors"):
		return
	tree.root.set_meta("ui_cursors", true)
	tree.node_added.connect(_cursor_for)
	_cursor_walk(tree.root)

static func _cursor_walk(n: Node) -> void:
	_cursor_for(n)
	for c in n.get_children():
		_cursor_walk(c)

static func _cursor_for(n: Node) -> void:
	if n is BaseButton and not n.has_meta("ui_cursor"):
		n.set_meta("ui_cursor", true)
		var b: BaseButton = n
		var upd := func() -> void:
			b.mouse_default_cursor_shape = Control.CURSOR_ARROW if b.disabled else Control.CURSOR_POINTING_HAND
		upd.call()
		b.mouse_entered.connect(upd)
		b.draw.connect(upd)  # a button enabled or disabled while the mouse rests on it

## Puts `content` (already a child of `panel`, or not yet parented) inside a ScrollContainer that is a child of `panel`,
## and keeps the scroll area no taller than the window minus `reserved` pixels (space above and below the panel plus
## the panel's own frame). Short content shows in full with no scrollbar; long content scrolls.
static func scroll_wrap(panel: Container, content: Control, reserved: float) -> ScrollContainer:
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if content.get_parent() != null:
		content.get_parent().remove_child(content)
	# owner item 8: a gutter keeps the content clear of the scrollbar
	var gutter := MarginContainer.new()
	gutter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gutter.add_theme_constant_override("margin_right", 14)
	gutter.add_child(content)
	sc.add_child(gutter)
	panel.add_child(sc)
	var fit := func() -> void:
		if not is_instance_valid(panel) or not panel.is_inside_tree():
			return
		var frame := 0.0
		if panel.has_theme_stylebox("panel"):
			frame = panel.get_theme_stylebox("panel").get_minimum_size().y
		var avail := panel.get_viewport_rect().size.y - reserved - frame
		sc.custom_minimum_size.y = maxf(80.0, minf(content.get_combined_minimum_size().y, avail))
	var later := func() -> void: fit.call_deferred()
	content.minimum_size_changed.connect(later)
	panel.tree_entered.connect(later)
	panel.visibility_changed.connect(later)
	if panel.is_inside_tree():
		panel.get_viewport().size_changed.connect(later)
	else:
		panel.tree_entered.connect(func(): panel.get_viewport().size_changed.connect(later), CONNECT_ONE_SHOT)
	later.call()
	return sc
