extends PanelContainer
## T28: small Ships menu, right side under the notification board. Shows ship count / cap.

const StoryText := preload("res://game/story_text.gd")
const Ships := preload("res://game/ships.gd")
const Juice := preload("res://game/juice.gd")
const PathfinderView := preload("res://game/pathfinder_view.gd")  # T180 accessor helpers

signal buy_requested(kind: String)
signal details_requested  # T350: a click on the hero card expands or collapses the Flagship details under it
var hero_row: HBoxContainer  # the card with the explore icon button to its right
var _hero_box: VBoxContainer
var _hero_inner: HBoxContainer  # the row inside the card: icon, texts, and the explore button at its right end
var buy_buttons: Dictionary = {}  # kind -> Button
var label: Label
var upkeep_label: Label
var upkeep_scroll: ScrollContainer
const UPKEEP_MAX_H := 220.0
var free_label: Label  # free ships, upkeep each, and what Send to... does when none is free
var core_scroll: ScrollContainer
var core_box: VBoxContainer  # Null Core: one Fit button per ship while a built core is not on it
var _core_sig := ""
var hero_card: PanelContainer  # T317: hero ship card, first in the menu; a click selects the flight ship like a viewport click
var hero_icon: TextureRect  # T351: static Flagship icon in the card
var hero_name: Label
var hero_state: Label
var _hero_main: Control
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
	_hero_box = box
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
		b.visible = false  # owner: the ship upkeep list, the free-ships lines and the buy button are gone from the menu (Send to... buys a ship)
		box.add_child(b)
		buy_buttons[kind] = b
	upkeep_scroll.visible = false
	free_label.visible = false

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
	_hero_inner = row
	hero_icon = TextureRect.new()
	hero_icon.texture = Ui.icon("ship_flagship")
	hero_icon.custom_minimum_size = Vector2(30, 30)  # half the earlier 60 px
	hero_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hero_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hero_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_icon.modulate = Ui.col("ink")
	row.add_child(hero_icon)
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
	hero_row = HBoxContainer.new()
	hero_row.name = "HeroRow"
	hero_row.add_theme_constant_override("separation", 6)
	hero_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_row.add_child(hero_card)
	box.add_child(hero_row)

## The Flagship details section goes right under the card; its explore icon button sits inside the card at its right end.
func attach_flagship(fp: Control) -> void:
	if not is_node_ready():
		await ready
	_hero_inner.add_child(fp.explore_button)  # inside the card but its own button: a click on it never reaches the card
	_hero_box.add_child(fp)
	_hero_box.move_child(fp, hero_row.get_index() + 1)

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
		if event.double_click:  # the second click of a double click: put the camera on the ship, no second toggle
			if _hero_main != null and _hero_main.map != null:
				_hero_main.map.focus_on_ship()
			return
		if _hero_main != null and _hero_main.map != null:
			_hero_main.map.select_ship(not _hero_main.map.ship_selected)
			if _hero_main.map.ship_selected:
				_hero_main.ship_pulse_on_select()
			_set_hero_card(_hero_main)
			details_requested.emit()  # T350

## Called every frame by main: the card's highlight must follow map.ship_selected however it changed (a click on the ship, empty
## space, Esc, an order), not only when the card itself or the panel refresh runs.
func sync_selection(selected: bool) -> void:
	if selected != _hero_selected and hero_card != null and hero_card.visible:
		_hero_selected = selected
		_style_hero(selected)

## T317: drawn only through Availability.hero_ship; follows map.ship_selected both ways.
func _set_hero_card(main: Control) -> void:
	_hero_main = main
	var f = main.map.flight if main.map != null else null
	var show: bool = Availability.hero_ship(f)
	hero_card.visible = show
	if not show:
		_hero_selected = false
		return
	var sel: bool = main.map.ship_selected
	if sel != _hero_selected:
		_hero_selected = sel
		_style_hero(sel)
	var st := PathfinderView.state(f)
	var key := "LBL_HERO_STATE_FLYING" if st == "flying" else ("LBL_HERO_STATE_BUILDING" if st == "building" else "LBL_HERO_STATE_IDLE")
	hero_name.text = StoryText.get_or("LBL_PATHFINDER_NAME", "Pathfinder")
	hero_state.text = StoryText.get_text(key)

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
		lines.append(StoryText.get_or("LBL_UPKEEP_LINE", "Ship {n}, {type} ({good}): {pay}{tag}", {"n": n, "type": Ships.display_name(Ships.fleet), "good": Ui.good_name(str(rec["c"])), "pay": pay, "tag": tag}))
	for kind in [Ships.fleet]:
		for i in maxi(0, main.free_of(kind)):
			n += 1
			lines.append(StoryText.get_or("LBL_UPKEEP_LINE_FREE", "Ship {n}, {type} (free): {pay}", {"n": n, "type": Ships.display_name(kind), "pay": 0}))
	lines.append(StoryText.get_or("LBL_UPKEEP_TOTAL", "{name}, total: {total} / cycle", {"name": upkeep_name, "total": total}))
	upkeep_label.text = "\n".join(lines)
	upkeep_scroll.custom_minimum_size.y = minf(UPKEEP_MAX_H, upkeep_label.get_combined_minimum_size().y)
	_set_hero_card(main)
	var core_on: bool = main.core_route_id() >= 0
	upkeep_label.mouse_filter = Control.MOUSE_FILTER_STOP if core_on else Control.MOUSE_FILTER_IGNORE
	upkeep_label.tooltip_text = StoryText.get_or("NULL_CORE_FIT", "Null Core fitted. Lower Trip cost, and pirates cannot touch this ship.") if core_on else ""
	_set_core_buttons(main)
	core_scroll.custom_minimum_size.y = minf(UPKEEP_MAX_H * 0.7, core_box.get_combined_minimum_size().y)
	var free: int = main.free_ships()
	var price: int = main.ship_price()
	var cap: int = main.ship_cap()
	var txt: String = StoryText.get_or("LBL_SHIPS_FREE_HINT", "Free ships: {free}. Ship upkeep {upkeep} / cycle each.", {"free": free, "upkeep": main.engine.upkeep_part()})
	if free <= 0:
		if main.ships >= cap:
			txt += "\n" + StoryText.get_or("LBL_SHIP_LIMIT", "Ship limit reached ({cap}).", {"cap": cap})
		elif main.cash >= price:
			txt += "\n" + StoryText.get_or("LBL_SEND_BUYS_SHIP", "No free ship. Send to... buys one for {price} credits.", {"price": price})
		else:
			txt += "\n" + StoryText.get_or("LBL_NO_CREDITS", "Not enough credits.")
	var fr: Dictionary = main.can_buy_ship()
	if fr.get("floor", false):
		txt += "\n" + str(fr["reason"])
	free_label.text = txt
	for kind in [Ships.fleet]:
		var b: Button = buy_buttons["fleet"]
		var r: Dictionary = main.can_buy_ship(kind)
		b.text = StoryText.get_or("BTN_BUY_SHIP", "Buy {ship} ({price} cr, upkeep {upkeep})", {"ship": Ships.display_name(kind), "price": main.ship_price(), "upkeep": main.engine.upkeep_part({"ship": kind})})
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
	label.text = StoryText.get_or("LBL_SHIP_COUNT", "Carrier ships: {n} / {cap}", {"n": ships, "cap": cap})
	if _last_count >= 0 and ships > _last_count:  # a purchase or a new lane: the count flashes warm
		Juice.flash(label, Ui.col("star_warm"))
	_last_count = ships
