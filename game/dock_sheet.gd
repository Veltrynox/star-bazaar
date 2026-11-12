extends ColorRect
## T270: the dock sheet (design/proposals/2026-11-06-empire-growth-v2.md section 3.2). A paused window, like the event window,
## opened by "Dock and trade" (right-click menu) or on docking after that order. No buying or selling by hand (owner, 2026-11-12):
## the sheet moves goods between the Flagship hold and this world's Company storage (unload_to_storage, load_from_storage of
## game/pathfinder.gd) and shows the boost state. Rows: every visible good the Flagship holds or Company storage here holds.
## Goods follow Availability; text is ids with fallbacks. No numbers live here.

const StoryText := preload("res://game/story_text.gd")
const Juice := preload("res://game/juice.gd")

signal closed

var main: Control
var planet := -1
var rows_box: VBoxContainer
var hold_label: Label
var fuel_label: Label
var title_label: Label
var _sig := ""
const CRATE_TINT := Color(0.95, 0.75, 0.4, 0.95)  # T274: crate sprites of the trade stream
# T274 tuning: balance flight_juice_crates / flight_juice_crate_s (placeholders); these mirror them for a missing key.
const JUICE_FALLBACK := {"flight_juice_crates": 5.0, "flight_juice_crate_s": 0.5}

func open(main_node: Control, planet_index: int) -> void:
	main = main_node
	planet = planet_index
	name = "DockSheet"
	color = Ui.col("scrim_soft")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var card := PanelContainer.new()
	center.add_child(card)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(760, 0)
	box.add_theme_constant_override("separation", 10)
	card.add_child(box)
	var title := Label.new()
	title.theme_type_variation = "LabelHero"
	title.text = StoryText.get_or("LBL_DOCK_TITLE", "Dock at {planet}", {"planet": main.planet_name(planet)})
	box.add_child(title)
	title_label = title
	hold_label = Label.new()
	box.add_child(hold_label)
	fuel_label = Label.new()
	fuel_label.theme_type_variation = "LabelSmall"
	box.add_child(fuel_label)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(0, 280)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	rows_box = VBoxContainer.new()
	rows_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows_box.add_theme_constant_override("separation", 6)
	scroll.add_child(rows_box)
	var note := Label.new()
	note.theme_type_variation = "LabelSmall"
	note.text = StoryText.get_or("LBL_DOCK_PAUSED", "Time is paused while you are docked.")
	box.add_child(note)
	var close := Button.new()
	close.name = "UndockButton"
	close.theme_type_variation = "ButtonPrimary"
	close.text = StoryText.get_or("BTN_DOCK_CLOSE", "Undock")
	close.pressed.connect(close_sheet)
	box.add_child(close)
	rebuild()
	Juice.enter(card, 0.96)  # T274: the sheet settles in (the scrim stays put)

func _process(_dt: float) -> void:
	if main == null:
		return
	if main.flight.dock_planet() != planet:  # the ship left or the post is gone
		close_sheet()
		return
	if _signature() != _sig:
		rebuild()

func close_sheet() -> void:
	closed.emit()
	queue_free()

## Goods shown: visible only (Availability); the hold, the world's prices and Company storage here decide which.
func _goods() -> Array:
	var out: Array = []
	var key: String = main.storage.planet_key(planet)
	for c in Availability.all_visible_goods():
		var g := str(c)
		if main.flight.hold_units(g) > 0 or main.storage.amount(key, g) > 0:
			out.append(g)
	return out

func _signature() -> String:
	var s := "%d|%d|%d|%s" % [main.flight.hold_total(), planet, main.flight.boost_charges(), str(main.flight.boost_on())]
	var key: String = main.storage.planet_key(planet)
	for g in _goods():
		s += ",%s:%d:%d" % [g, main.flight.hold_units(g), main.storage.amount(key, g)]
	return s

func rebuild() -> void:
	_sig = _signature()
	var f = main.flight
	hold_label.text = "%s\n%s" % [StoryText.get_or("LBL_HOLD_FILL", "Hold: {n} of {m}", {"n": f.hold_total(), "m": f.hold_cap()}),
		StoryText.get_or("LBL_DOCK_HOLD_FULL", "The hold is full. Unload some goods to storage.") if f.hold_space() <= 0 else ""]
	hold_label.text = hold_label.text.strip_edges()
	var boost := StoryText.get_or("LBL_BOOST_CHARGES", "Boost: {n} left", {"n": f.boost_charges()})
	fuel_label.text = "%s: %d    %s" % [Ui.good_name("energy"), f.hold_units("energy"), boost] if Availability.good("energy") else boost
	for ch in rows_box.get_children():
		ch.queue_free()
	var head := Label.new()
	head.theme_type_variation = "LabelCaption"
	head.text = "%s  /  %s" % [StoryText.get_or("LBL_DOCK_HOLD", "In the hold"), StoryText.get_or("LBL_DOCK_WORLD", "At this world")]
	rows_box.add_child(head)
	var key: String = main.storage.planet_key(planet)
	for g in _goods():
		_add_row(g, key)

func _add_row(g: String, key: String) -> void:
	var f = main.flight
	var held: int = f.hold_units(g)
	var stored: int = main.storage.amount(key, g)
	var line := VBoxContainer.new()
	line.name = "Row_" + g
	rows_box.add_child(line)
	var info := HBoxContainer.new()
	info.add_theme_constant_override("separation", 10)
	line.add_child(info)
	info.add_child(Ui.good_icon(g))
	var nm := Label.new()
	nm.text = Ui.good_name(g)
	nm.custom_minimum_size = Vector2(120, 0)
	info.add_child(nm)
	var hl := Label.new()
	hl.text = "%s: %s" % [StoryText.get_or("LBL_HOLD", "Hold"), str(held) if held > 0 else StoryText.get_or("LBL_HOLD_EMPTY", "Empty")]
	hl.custom_minimum_size = Vector2(110, 0)
	info.add_child(hl)
	var sl := Label.new()
	sl.theme_type_variation = "LabelSmall"
	sl.text = StoryText.get_or("LBL_DOCK_STORAGE_ROW", "Company storage: {n}", {"n": stored})
	info.add_child(sl)
	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 6)
	line.add_child(btns)
	_btn(btns, "BTN_UNLOAD_STORAGE", "Unload to storage", func(): _do("unload", g, held), held <= 0)
	_btn(btns, "BTN_LOAD_STORAGE", "Load from storage", func(): _do("load", g, stored), stored <= 0)

func _btn(parent: Control, id: String, fallback: String, cb: Callable, disabled: bool) -> void:
	var b := Button.new()
	b.text = StoryText.get_or(id, fallback)
	b.disabled = disabled
	b.pressed.connect(cb)
	parent.add_child(b)

## Runs one move through the Flagship API; a refusal (or a cut-short move) becomes a notice.
func _do(kind: String, g: String, units: int) -> void:
	var f = main.flight
	var before: int = f.hold_total()
	var good_before: int = f.hold_units(g)
	var r := ""
	match kind:
		"unload":
			r = f.unload_to_storage(planet, g, units)
		"load":
			r = f.load_from_storage(planet, g, units)
	if r == "" and kind == "load" and f.hold_space() <= 0 and f.hold_total() - before < units:
		r = "hold_full"  # cut short by the room left
	var msg := refusal_text(r)
	if msg != "":
		main.post_notice_now(msg)
	rebuild()
	if r == "":
		_trade_juice(kind, g, absi(f.hold_units(g) - good_before))

func _jk(key: String) -> float:
	return float(main.balance.get(key, JUICE_FALLBACK.get(key, 0.0)))

## T274: crates stream between the hold line and the world name (to the world for unload, to the ship for load).
## Real-time UI tweens (the sheet pauses the game); visual only.
func _trade_juice(kind: String, g: String, moved: int) -> void:
	var ship_at := hold_label.global_position - global_position + Vector2(8.0, hold_label.size.y * 0.5)
	var world_at := title_label.global_position - global_position + Vector2(title_label.size.x * 0.5, title_label.size.y * 0.5)
	if moved > 0:
		var to_world := kind == "unload"
		Juice.crates(self, ship_at if to_world else world_at, world_at if to_world else ship_at,
			clampi(moved, 1, maxi(1, int(_jk("flight_juice_crates")))), _jk("flight_juice_crate_s"), Ui.commodity_col(g).lerp(CRATE_TINT, 0.4))

static func refusal_text(r: String) -> String:
	match r:
		"hold_full":
			return StoryText.get_or("NOT_DOCK_HOLD_FULL", "The hold is full. Unload something to storage first.")
		"storage_full":
			return StoryText.get_or("NOT_DOCK_STORAGE_FULL", "Company storage here is full.")
		"no_stock":
			return StoryText.get_or("NOT_DOCK_NO_STOCK", "Company storage here has none of that.")
		"not_docked":
			return StoryText.get_or("NOT_DOCK_FAR", "Fly the Flagship here first.")
	return ""
