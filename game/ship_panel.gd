extends PanelContainer
## T28: small Ships menu, right side under the notification board. Shows ship count / cap.

const StoryText := preload("res://game/story_text.gd")
const Ships := preload("res://game/ships.gd")
const Juice := preload("res://game/juice.gd")
const PathfinderView := preload("res://game/pathfinder_view.gd")  # T180 accessor helpers
const ShipPreview := preload("res://game/ship_preview.gd")  # T317 hero card preview

signal buy_requested(kind: String)
signal explore_toggled  # T206
signal boost_toggled(on: bool)  # T270
var explore_button: Button  # T206: exploration mode on/off; hidden unless discovery is on
var hold_label: Label  # T270: "Hold: n of m", goods held, boost charges
var boost_button: Button  # T270: boost on/off; hotkey B (hold)
var buy_buttons: Dictionary = {}  # kind -> Button
var label: Label
var upkeep_label: Label
var pathfinder_label: Label  # T180: Pathfinder name, description, status; hidden unless discovery is on
var upkeep_scroll: ScrollContainer
const UPKEEP_MAX_H := 220.0
var free_label: Label  # free ships, upkeep each, and what Send to... does when none is free
var core_scroll: ScrollContainer
var core_box: VBoxContainer  # Null Core: one Fit button per ship while a built core is not on it
var _core_sig := ""
var hero_card: PanelContainer  # T317: hero ship card, first in the menu; a click selects the flight ship like a viewport click
var hero_preview: PanelContainer
var hero_name: Label
var hero_state: Label
var _hero_main: Control
var _hero_model := ""
var _hero_selected := false
var _last_count := -1  # -1 until the first count, so a loaded save does not flash

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS  # T58: buy buttons live here
	custom_minimum_size = Vector2(320, 0)  # sits in main.gd right_col under the board
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)
	var title := Label.new()
	title.text = StoryText.get_or("LBL_SHIPS", "Ships").to_upper()
	title.theme_type_variation = "LabelCaption"
	box.add_child(title)
	_build_hero_card(box)
	label = Label.new()
	box.add_child(label)
	upkeep_scroll = ScrollContainer.new()  # T186: up to 10 ships, so the per-ship list scrolls past UPKEEP_MAX_H
	upkeep_scroll.name = "UpkeepScroll"
	upkeep_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(upkeep_scroll)
	upkeep_label = Label.new()
	upkeep_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	upkeep_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upkeep_scroll.add_child(upkeep_label)
	pathfinder_label = Label.new()
	pathfinder_label.name = "Pathfinder"
	pathfinder_label.theme_type_variation = "LabelSmall"
	pathfinder_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pathfinder_label.visible = false
	box.add_child(pathfinder_label)
	explore_button = Button.new()
	explore_button.name = "ExploreButton"
	explore_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explore_button.visible = false
	explore_button.pressed.connect(func(): explore_toggled.emit())
	box.add_child(explore_button)
	hold_label = Label.new()  # T270: hold readout and boost gauge
	hold_label.name = "HoldReadout"
	hold_label.theme_type_variation = "LabelSmall"
	hold_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hold_label.visible = false
	box.add_child(hold_label)
	boost_button = Button.new()
	boost_button.name = "BoostButton"
	boost_button.visible = false
	boost_button.toggle_mode = true
	boost_button.toggled.connect(func(on: bool): boost_toggled.emit(on))
	box.add_child(boost_button)
	free_label = Label.new()
	free_label.name = "FreeShips"
	free_label.theme_type_variation = "LabelSmall"
	free_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(free_label)
	core_box = VBoxContainer.new()
	core_box.name = "CoreBox"
	core_scroll = ScrollContainer.new()  # T186: one Fit button per ship, up to 10
	core_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	core_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	core_scroll.add_child(core_box)
	box.add_child(core_scroll)
	for kind in ["fleet"]:  # one buy button: every ship of the run is the chosen type (Ships.fleet)
		var b := Button.new()
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART  # a long label wraps instead of widening the right column
		b.pressed.connect(func(): buy_requested.emit(Ships.fleet))
		box.add_child(b)
		buy_buttons[kind] = b

## T317: the card is a stop-filter PanelContainer, so a click on it never reaches the map and touches no other panel.
func _build_hero_card(box: VBoxContainer) -> void:
	hero_card = PanelContainer.new()
	hero_card.name = "HeroCard"
	hero_card.mouse_filter = Control.MOUSE_FILTER_STOP
	hero_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hero_card.visible = false
	hero_card.tooltip_text = StoryText.get_or("LBL_HERO_HINT", "")
	hero_card.gui_input.connect(_on_hero_input)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_card.add_child(row)
	hero_preview = ShipPreview.new()
	hero_preview.setup(Vector2(96, 64))
	hero_preview.make_passive()
	hero_preview.set_active(false)
	row.add_child(hero_preview)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(col)
	hero_name = Label.new()
	hero_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(hero_name)
	hero_state = Label.new()
	hero_state.theme_type_variation = "LabelSmall"
	hero_state.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(hero_state)
	_style_hero(false)
	box.add_child(hero_card)

func _style_hero(selected: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Ui.col("panel_100")
	sb.border_color = Ui.col("star_warm") if selected else Ui.col("line_200")
	sb.set_border_width_all(2 if selected else 1)
	sb.set_corner_radius_all(4)
	sb.set_content_margin_all(6)
	hero_card.add_theme_stylebox_override("panel", sb)

func _on_hero_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hero_card.accept_event()
		if _hero_main != null and _hero_main.map != null:
			_hero_main.map.select_ship(not _hero_main.map.ship_selected)
			if _hero_main.map.ship_selected:
				_hero_main.ship_pulse_on_select()
			_set_hero_card(_hero_main)

## T317: drawn only through Availability.hero_ship; follows map.ship_selected both ways; the preview renders only while the card shows.
func _set_hero_card(main: Control) -> void:
	_hero_main = main
	var f = main.map.flight if main.map != null else null
	var show: bool = Availability.hero_ship(f)
	hero_card.visible = show
	hero_preview.set_active(show and is_visible_in_tree())
	if not show:
		_hero_selected = false
		return
	var path := str(PathfinderView._call(f, "model_path", [], ""))
	if path != _hero_model:
		_hero_model = path
		hero_preview.show_model(path)
	var sel: bool = main.map.ship_selected
	if sel != _hero_selected:
		_hero_selected = sel
		_style_hero(sel)
	var st := PathfinderView.state(f)
	var key := "LBL_HERO_STATE_FLYING" if st == "flying" else ("LBL_HERO_STATE_BUILDING" if st == "building" else "LBL_HERO_STATE_IDLE")
	hero_name.text = StoryText.get_or("LBL_PATHFINDER_NAME", "Pathfinder")
	hero_state.text = StoryText.get_text(key) + ((", " + StoryText.get_text("LBL_HERO_SELECTED")) if sel else "")

## T69: each ship's upkeep per cycle (paid while its route moves stock; an idle ship pays 0) and the total.
## T58: lines carry the ship type name; buy buttons show price and upkeep per type.
func set_upkeep(main: Control) -> void:
	var upkeep_name := StoryText.get_text("LBL_SHIP_UPKEEP")
	var lines: Array = []
	var total := 0
	var n := 0
	for rec in main.engine.routes:
		n += 1
		var up: int = main.engine.upkeep_part(rec)
		var pay: int = up if main.engine.payout_of(rec) < 0 else 0
		total += pay
		var tag := ("  [" + StoryText.get_or("LBL_NULL_CORE", "Null Core") + "]") if main.engine.has_core(rec) else ""
		lines.append("Ship %d, %s (%s): %d%s" % [n, Ships.display_name(Ships.fleet), Ui.good_name(str(rec["c"])), pay, tag])
	for kind in [Ships.fleet]:
		for i in maxi(0, main.free_of(kind)):
			n += 1
			lines.append("Ship %d, %s (free): 0" % [n, Ships.display_name(kind)])
	lines.append("%s, total: %d / cycle" % [upkeep_name, total])
	upkeep_label.text = "\n".join(lines)
	upkeep_scroll.custom_minimum_size.y = minf(UPKEEP_MAX_H, upkeep_label.get_combined_minimum_size().y)
	_set_pathfinder(main)
	_set_hero_card(main)
	var core_on: bool = main.core_route_id() >= 0
	upkeep_label.mouse_filter = Control.MOUSE_FILTER_STOP if core_on else Control.MOUSE_FILTER_IGNORE
	upkeep_label.tooltip_text = StoryText.get_or("NULL_CORE_FIT", "Null Core fitted. Lower Trip cost, and pirates cannot touch this ship.") if core_on else ""
	_set_core_buttons(main)
	core_scroll.custom_minimum_size.y = minf(UPKEEP_MAX_H * 0.7, core_box.get_combined_minimum_size().y)
	var free: int = main.free_ships()
	var price := Ships.price(Ships.fleet, main.balance)
	var cap: int = main.ship_cap()
	var txt: String = StoryText.get_or("LBL_SHIPS_FREE_HINT", "Free ships: {free}. Ship upkeep {upkeep} / cycle each.", {"free": free, "upkeep": main.engine.upkeep_part()})
	if free <= 0:
		if main.ships >= cap:
			txt += "\n" + "Ship limit reached (%d)." % cap
		elif main.cash >= price:
			txt += "\n" + StoryText.get_or("LBL_SEND_BUYS_SHIP", "No free ship. Send to... buys one for {price} credits.", {"price": price})
		else:
			txt += "\nNot enough credits."
	var fr: Dictionary = main.can_buy_ship()
	if fr.get("floor", false):
		txt += "\n" + str(fr["reason"])
	free_label.text = txt
	for kind in [Ships.fleet]:
		var b: Button = buy_buttons["fleet"]
		var r: Dictionary = main.can_buy_ship(kind)
		b.text = "Buy %s (%d cr, upkeep %d)" % [Ships.display_name(kind), Ships.price(kind, main.balance), main.engine.upkeep_part({"ship": kind})]
		b.disabled = not r["ok"] or main.tut_lock_active()
		b.tooltip_text = str(r["reason"])

## Fit buttons, rebuilt only when the ships or the core change (set_upkeep runs every frame).
func _set_core_buttons(main: Control) -> void:
	var sig := "%d" % main.fabric.core_made
	for r in main.engine.routes:
		sig += ",%d%s" % [int(r["id"]), "c" if main.engine.has_core(r) else ""]
	if sig == _core_sig:
		return
	_core_sig = sig
	for ch in core_box.get_children():
		ch.queue_free()
	if main.fabric.core_made <= 0:
		return
	var n := 0
	for r in main.engine.routes:
		n += 1
		if main.engine.has_core(r):
			continue
		var b := Button.new()
		b.text = StoryText.get_or("BTN_FIT_NULL_CORE", "Fit Null Core to Ship {n}", {"n": n})
		var rid: int = int(r["id"])
		b.pressed.connect(func(): main.fit_core(rid))
		core_box.add_child(b)

func set_count(ships: int, cap: int) -> void:
	label.text = "Ships: %d / %d" % [ships, cap]
	if _last_count >= 0 and ships > _last_count:  # a purchase or a new lane: the count flashes warm
		Juice.flash(label, Ui.col("star_warm"))
	_last_count = ships

## T180: three lines (name, description, status) from the flight accessor; nothing shows while discovery is off.
func _set_pathfinder(main: Control) -> void:
	if pathfinder_label == null:
		return
	var f = main.map.flight if main.map != null else null
	if not PathfinderView.active(f):
		pathfinder_label.visible = false
		if explore_button != null:
			explore_button.visible = false
		if hold_label != null:
			hold_label.visible = false
			boost_button.visible = false
		return
	var status := StoryText.get_or("LBL_PATHFINDER_IDLE", "Pathfinder waiting")
	if PathfinderView.state(f) == "flying":
		var tg = PathfinderView._call(f, "target", [], {})
		var idx := int(tg.get("index", -1)) if typeof(tg) == TYPE_DICTIONARY and str(tg.get("kind", "")) == "planet" else -1
		if idx >= 0 and idx < main.map.planets.size() and PathfinderView.discovered(f, str(main.map.planets[idx].get("id", idx))):
			status = StoryText.get_or("LBL_PATHFINDER_FLYING", "Pathfinder flying to {planet}", {"planet": main.planet_name(idx)})
		else:
			status = StoryText.get_or("LBL_PATHFINDER_FLYING_UNKNOWN", "Pathfinder flying to an unknown world")
	pathfinder_label.text = "%s\n%s\n%s" % [StoryText.get_or("LBL_PATHFINDER_NAME", "Pathfinder"), StoryText.get_or("LBL_PATHFINDER_DESC", ""), status]
	pathfinder_label.visible = true
	_set_hold(main, f)
	if explore_button != null:
		explore_button.visible = true
		explore_button.text = StoryText.get_text("BTN_EXPLORE_OFF" if bool(PathfinderView._call(f, "exploring", [], false)) else "BTN_EXPLORE_ON")

## T270: hold readout (units, goods) and boost gauge from the Flagship API; hidden while the hold has no room (key 0) or discovery is off.
func _set_hold(main: Control, f) -> void:
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
