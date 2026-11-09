extends PanelContainer
## T350: Flagship details. Opens when the hero card in the Ships menu is clicked. Holds everything the Flagship has: name, preview,
## description, status, explore on/off, hold and goods, boost, speed, worlds found, destination. Reads the flight accessors only
## (PathfinderView, main.flight); no mechanics of its own. Opaque like the tip card; closes with its button or Esc.

const StoryText := preload("res://game/story_text.gd")
const PathfinderView := preload("res://game/pathfinder_view.gd")
const ShipPreview := preload("res://game/ship_preview.gd")

signal explore_toggled
signal boost_toggled(on: bool)
signal closed

var main: Control
var name_label: Label
var desc_label: Label
var status_label: Label
var explore_button: Button  # hidden while discovery is off
var hold_label: Label
var boost_button: Button
var stats_label: Label
var preview: PanelContainer
var _model := ""
var _box: VBoxContainer

func setup(main_node: Control) -> void:
	main = main_node
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	custom_minimum_size = Vector2(minf(420.0, get_viewport_rect().size.x - 24.0), 0)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	var base := get_theme_stylebox("panel", "PanelContainer")  # the theme panel is see-through: copy it with alpha 1
	if base is StyleBoxFlat:
		var opaque := (base as StyleBoxFlat).duplicate() as StyleBoxFlat
		opaque.bg_color = Color(opaque.bg_color, 1.0)
		add_theme_stylebox_override("panel", opaque)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 8)
	Ui.scroll_wrap(self, _box, 24.0)
	var head := HBoxContainer.new()
	_box.add_child(head)
	var title := Label.new()
	title.text = StoryText.get_or("LBL_FLAGSHIP_TITLE", "Flagship")
	title.theme_type_variation = "LabelTitle"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var close := Button.new()
	close.name = "CloseButton"
	close.text = StoryText.get_or("SK_BTN_CLOSE", "Close")
	close.pressed.connect(close_screen)
	head.add_child(close)
	preview = ShipPreview.new()
	preview.setup(Vector2(160, 100))
	preview.make_passive()
	preview.set_active(false)
	_box.add_child(preview)
	name_label = _label(false)
	desc_label = _label(true)
	status_label = _label(true)
	explore_button = Button.new()
	explore_button.name = "ExploreButton"
	explore_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explore_button.pressed.connect(func(): explore_toggled.emit())
	_box.add_child(explore_button)
	hold_label = _label(true)
	hold_label.name = "HoldReadout"
	boost_button = Button.new()
	boost_button.name = "BoostButton"
	boost_button.toggle_mode = true
	boost_button.toggled.connect(func(on: bool): boost_toggled.emit(on))
	_box.add_child(boost_button)
	stats_label = _label(true)

func _label(small: bool) -> Label:
	var l := Label.new()
	if small:
		l.theme_type_variation = "LabelSmall"
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_box.add_child(l)
	return l

func open_screen() -> void:
	if main == null or not Availability.hero_ship(main.map.flight if main.map != null else null):
		return
	visible = true
	refresh()

func close_screen() -> void:
	if visible:
		visible = false
		preview.set_active(false)
		closed.emit()

func _process(_delta: float) -> void:
	if visible:
		refresh()

## Called with the Ships panel refresh: keeps the texts current while the panel is shut (no preview, no closing).
func refresh_closed() -> void:
	if not visible and main != null and main.map != null and Availability.hero_ship(main.map.flight):
		refresh()
		preview.set_active(false)

## Re-reads the flight accessors; closes itself when the hero ship is gone (discovery off, new run).
func refresh() -> void:
	var f = main.map.flight if main.map != null else null
	if not Availability.hero_ship(f):
		close_screen()
		return
	preview.set_active(true)
	var path := str(PathfinderView._call(f, "model_path", [], ""))
	if path != _model:
		_model = path
		preview.show_model(path)
	name_label.text = StoryText.get_or("LBL_PATHFINDER_NAME", "Pathfinder")
	desc_label.text = StoryText.get_or("LBL_PATHFINDER_DESC", "")
	var status := StoryText.get_or("LBL_PATHFINDER_IDLE", "Pathfinder waiting")
	var target_text := StoryText.get_text("LBL_FLAGSHIP_NO_TARGET")
	if PathfinderView.state(f) == "flying":
		var tg = PathfinderView._call(f, "target", [], {})
		var idx := int(tg.get("index", -1)) if typeof(tg) == TYPE_DICTIONARY and str(tg.get("kind", "")) == "planet" else -1
		if idx >= 0 and idx < main.map.planets.size() and PathfinderView.discovered(f, str(main.map.planets[idx].get("id", idx))):
			status = StoryText.get_or("LBL_PATHFINDER_FLYING", "Pathfinder flying to {planet}", {"planet": main.planet_name(idx)})
			target_text = StoryText.get_text("LBL_FLAGSHIP_TARGET").replace("{planet}", main.planet_name(idx))
		else:
			status = StoryText.get_or("LBL_PATHFINDER_FLYING_UNKNOWN", "Pathfinder flying to an unknown world")
			target_text = StoryText.get_text("LBL_FLAGSHIP_TARGET").replace("{planet}", StoryText.get_or("LBL_UNKNOWN_WORLD", "unknown"))
	status_label.text = status
	explore_button.visible = true
	explore_button.text = StoryText.get_text("BTN_EXPLORE_OFF" if bool(PathfinderView._call(f, "exploring", [], false)) else "BTN_EXPLORE_ON")
	_set_hold()
	var found := 0
	for p in main.map.planets:
		if PathfinderView.discovered(f, str(p.get("id", ""))):
			found += 1
	var cap: int = main.flight.hold_cap()
	var lines: Array = [
		StoryText.get_text("LBL_FLAGSHIP_SPEED").replace("{n}", str(snappedf(float(PathfinderView._call(f, "speed", [], 0.0)), 0.1))),
		StoryText.get_text("LBL_FLAGSHIP_HOLD_CAP").replace("{m}", str(cap)),
		StoryText.get_text("LBL_FLAGSHIP_FOUND").replace("{n}", str(found)).replace("{m}", str(main.map.planets.size())),
		target_text]
	stats_label.text = "\n".join(lines)

## Hold fill, goods held and boost charges; the hold and boost rows are hidden while the hold has no room.
func _set_hold() -> void:
	var cap: int = main.flight.hold_cap()
	hold_label.visible = cap > 0
	boost_button.visible = cap > 0
	if cap <= 0:
		return
	var goods: Dictionary = main.flight.hold_goods()
	var lines: Array = [StoryText.get_or("LBL_HOLD_FILL", "Hold: {n} of {m}", {"n": main.flight.hold_total(), "m": cap})]
	for g in goods:
		lines.append("%s: %d" % [Ui.good_name(str(g)), int(goods[g])])
	lines.append(StoryText.get_or("LBL_BOOST_CHARGES", "Boost: {n} left", {"n": main.flight.boost_charges()}))
	hold_label.text = "\n".join(lines)
	boost_button.text = "%s (B)" % StoryText.get_or("BTN_BOOST", "Boost")
	boost_button.tooltip_text = StoryText.get_or("LBL_BOOST_HINT", "Faster on straight legs. Burns energy from the hold. Turning stays slow.")
	if boost_button.button_pressed != main.flight.boost_on():
		boost_button.set_pressed_no_signal(main.flight.boost_on())
