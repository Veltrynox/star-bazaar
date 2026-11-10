extends PanelContainer
## T350: Flagship details, an inline section of the Ships menu that expands under the Pathfinder card when it is clicked (no 3D
## preview, no separate window). Holds the description, status, hold and goods, boost, speed, worlds found, destination. Reads the flight accessors only
## (PathfinderView, main.flight); no mechanics of its own. Explore on/off is the icon button next to the card; the section collapses on a second click or Esc.

const StoryText := preload("res://game/story_text.gd")
const PathfinderView := preload("res://game/pathfinder_view.gd")

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
var _box: VBoxContainer

func setup(main_node: Control) -> void:
	main = main_node
	visible = false  # expanded or not: the card in the Ships menu toggles it
	mouse_filter = Control.MOUSE_FILTER_PASS
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 6)
	add_child(_box)
	name_label = _label(false)  # the card above already names the ship; kept so the readers below stay simple
	name_label.visible = false
	desc_label = _label(true)
	status_label = _label(true)
	# Explore on/off is one icon button; ship_panel.attach_flagship puts it to the right of the Pathfinder card.
	explore_button = Button.new()
	explore_button.name = "ExploreButton"
	explore_button.toggle_mode = true
	explore_button.icon = Ui.icon("explore")
	explore_button.expand_icon = true
	explore_button.add_theme_constant_override("icon_max_width", 24)
	explore_button.custom_minimum_size = Vector2(38, 38)
	for sn in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:  # the theme's button padding left the icon a few pixels wide
		var sb: StyleBox = explore_button.get_theme_stylebox(sn)
		if sb != null:
			var d: StyleBox = sb.duplicate()
			d.set_content_margin_all(5.0)
			explore_button.add_theme_stylebox_override(sn, d)
	explore_button.mouse_filter = Control.MOUSE_FILTER_STOP
	explore_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	explore_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	explore_button.visible = false
	explore_button.pressed.connect(func(): explore_toggled.emit())
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
		closed.emit()

func _process(_delta: float) -> void:
	if visible:
		refresh()

## Called with the Ships panel refresh: keeps the texts current while the panel is shut (no preview, no closing).
func refresh_closed() -> void:
	if not visible and main != null and main.map != null and Availability.hero_ship(main.map.flight):
		refresh()
	elif not visible:
		explore_button.visible = false

## Re-reads the flight accessors; closes itself when the hero ship is gone (discovery off, new run).
func refresh() -> void:
	var f = main.map.flight if main.map != null else null
	if not Availability.hero_ship(f):
		explore_button.visible = false
		close_screen()
		return
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
	var exploring := bool(PathfinderView._call(f, "exploring", [], false))
	explore_button.set_pressed_no_signal(exploring)
	explore_button.tooltip_text = StoryText.get_text("BTN_EXPLORE_OFF" if exploring else "BTN_EXPLORE_ON")
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
