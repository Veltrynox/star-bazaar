class_name Ui
const StoryText := preload("res://game/story_text.gd")
## Reads colours and icons from the project Theme (ui/theme/star_bazaar.tres), so no screen hard-codes them.
## Colour names are the design-token names with "_" for "-" (e.g. "star_warm", "signal_bad", "ink_muted").

static func col(token: String) -> Color:
	var t := ThemeDB.get_project_theme()
	if t != null and t.has_color(token, "Colors"):
		return t.get_color(token, "Colors")
	return Color.WHITE

## Route/label colour of a good. Theme token commodity_<good> if present, else a fallback for the T155 goods.
const COMMODITY_FALLBACK := {
	"silk": Color(0.72, 0.55, 0.85), "chips": Color(0.35, 0.75, 0.85), "ore": Color(0.62, 0.58, 0.52),
	"dross": Color(0.45, 0.42, 0.40), "nullglass": Color(0.55, 0.60, 0.95), "plate": Color(0.60, 0.68, 0.75),
	"rivets": Color(0.78, 0.50, 0.38), "cells": Color(0.30, 0.85, 0.72), "armour": Color(0.48, 0.58, 0.70),
	"musk": Color(0.80, 0.42, 0.62), "cask": Color(0.62, 0.42, 0.28), "gems": Color(0.90, 0.38, 0.55),
	"ingot": Color(0.78, 0.74, 0.62), "alloy": Color(0.42, 0.68, 0.80), "spores": Color(0.62, 0.45, 0.80),
	"gel": Color(0.40, 0.80, 0.90), "seed": Color(0.78, 0.72, 0.40),
}
static func commodity_col(c: String) -> Color:
	var t := ThemeDB.get_project_theme()
	if t != null and t.has_color("commodity_" + c, "Colors"):
		return t.get_color("commodity_" + c, "Colors")
	return COMMODITY_FALLBACK.get(c, Color.WHITE)

## Display name of a good: GOOD_<ID>_NAME from story_text.json, else the capitalised id.
static func good_name(c: String) -> String:
	return StoryText.get_or("GOOD_" + c.to_upper() + "_NAME", c.capitalize())

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
	# Goods without a theme icon (all but energy and food): placeholder SVGs in art/icons/
	var p := "res://art/icons/icon_%s_64.svg" % token
	if ResourceLoader.exists(p):
		return load(p) as Texture2D
	return null

## Small tinted icon for a good (every good). Never takes mouse input.
static func good_icon(c: String, px: int = 18) -> TextureRect:
	var ic := TextureRect.new()
	ic.texture = icon(c)
	ic.custom_minimum_size = Vector2(px, px)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cc := commodity_col(c)
	ic.modulate = cc if cc != Color.WHITE else col("ink")
	ic.tooltip_text = good_name(c)
	return ic

## Mono face (JetBrains Mono) for numbers, from the theme's LabelReadout variation.
static func mono_font() -> Font:
	var t := ThemeDB.get_project_theme()
	if t != null and t.has_font("font", "LabelReadout"):
		return t.get_font("font", "LabelReadout")
	return ThemeDB.fallback_font

## Sans face (Jost) for map text, from the theme's Label font.
static func sans_font() -> Font:
	var t := ThemeDB.get_project_theme()
	if t != null and t.has_font("font", "Label"):
		return t.get_font("font", "Label")
	return ThemeDB.fallback_font

## Artist texture from art/ui/ (name without extension); null when the file is not there yet.
static func ui_texture(name: String) -> Texture2D:
	for ext in ["png", "webp", "jpg"]:
		var p := "res://art/ui/%s.%s" % [name, ext]
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
	# Weak refs: a deferred call can land after the panel is freed (scene reload, end screen replaced), and a
	# lambda that captured a freed node errors before its body runs.
	var w_panel: WeakRef = weakref(panel)
	var w_sc: WeakRef = weakref(sc)
	var w_content: WeakRef = weakref(content)
	var fit := func() -> void:
		var p: Container = w_panel.get_ref()
		var s: ScrollContainer = w_sc.get_ref()
		var c: Control = w_content.get_ref()
		if p == null or s == null or c == null or not p.is_inside_tree():
			return
		var frame := 0.0
		if p.has_theme_stylebox("panel"):
			frame = p.get_theme_stylebox("panel").get_minimum_size().y
		var avail := p.get_viewport_rect().size.y - reserved - frame
		s.custom_minimum_size.y = maxf(80.0, minf(c.get_combined_minimum_size().y, avail))
	var later := func() -> void: fit.call_deferred()
	content.minimum_size_changed.connect(later)
	panel.tree_entered.connect(later)
	panel.visibility_changed.connect(later)
	# The window's size_changed outlives the panel: hook it only while the panel is in the tree, and drop it
	# on exit, else a resize after the game is freed calls a lambda whose captures are gone.
	var hook := func() -> void:
		var p: Container = w_panel.get_ref()
		var vp: Viewport = p.get_viewport() if p != null else null
		if vp != null and not vp.size_changed.is_connected(later):
			vp.size_changed.connect(later)
	var unhook := func() -> void:
		var p: Container = w_panel.get_ref()
		var vp: Viewport = p.get_viewport() if p != null else null
		if vp != null and vp.size_changed.is_connected(later):
			vp.size_changed.disconnect(later)
	panel.tree_entered.connect(hook)
	panel.tree_exiting.connect(unhook)
	if panel.is_inside_tree():
		hook.call()
	later.call()
	return sc

## Key cap chip as in the design pack (.ds-kbd): small mono text in a bordered chip with a thicker bottom edge.
static func kbd(text: String) -> PanelContainer:
	var pc := PanelContainer.new()
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = col("panel_200")
	sb.border_color = col("line_200")
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 2
	sb.set_corner_radius_all(3)
	sb.content_margin_left = 5
	sb.content_margin_right = 5
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	pc.add_theme_stylebox_override("panel", sb)
	pc.custom_minimum_size = Vector2(20, 20)
	var l := Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", mono_font())
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", col("ink_muted"))
	pc.add_child(l)
	return pc
