extends PanelContainer
## T28: small Ships menu, right side under the notification board. Shows ship count / cap.

const StoryText := preload("res://game/story_text.gd")
const Ships := preload("res://game/ships.gd")
const Juice := preload("res://game/juice.gd")

signal buy_requested(kind: String)
var buy_buttons: Dictionary = {}  # kind -> Button
var label: Label
var upkeep_label: Label
var free_label: Label  # free ships, upkeep each, and what Send to... does when none is free
var core_box: VBoxContainer  # Null Core: one Fit button per ship while a built core is not on it
var _core_sig := ""
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
	label = Label.new()
	box.add_child(label)
	upkeep_label = Label.new()
	upkeep_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(upkeep_label)
	free_label = Label.new()
	free_label.name = "FreeShips"
	free_label.theme_type_variation = "LabelSmall"
	free_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(free_label)
	core_box = VBoxContainer.new()
	core_box.name = "CoreBox"
	box.add_child(core_box)
	for kind in Ships.KINDS:  # T58: one buy button per ship type
		var b := Button.new()
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART  # a long label wraps instead of widening the right column
		b.pressed.connect(func(): buy_requested.emit(kind))
		box.add_child(b)
		buy_buttons[kind] = b

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
		lines.append("Ship %d, %s (%s): %d%s" % [n, Ships.display_name(str(rec.get("ship", "small"))), Ui.good_name(str(rec["c"])), pay, tag])
	for kind in Ships.KINDS:
		for i in maxi(0, main.free_of(kind)):
			n += 1
			lines.append("Ship %d, %s (free): 0" % [n, Ships.display_name(kind)])
	lines.append("%s, total: %d / cycle" % [upkeep_name, total])
	upkeep_label.text = "\n".join(lines)
	var core_on: bool = main.core_route_id() >= 0
	upkeep_label.mouse_filter = Control.MOUSE_FILTER_STOP if core_on else Control.MOUSE_FILTER_IGNORE
	upkeep_label.tooltip_text = StoryText.get_or("NULL_CORE_FIT", "Null Core fitted. Lower Trip cost, and pirates cannot touch this ship.") if core_on else ""
	_set_core_buttons(main)
	var free: int = main.free_ships()
	var price := int(main.balance.get("ship_price", 0))
	var cap := int(main.balance.get("ship_cap", 0))
	var txt: String = StoryText.get_or("LBL_SHIPS_FREE_HINT", "Free ships: {free}. Ship upkeep {upkeep} / cycle each.", {"free": free, "upkeep": main.engine.upkeep_part()})
	if free <= 0:
		if main.ships >= cap:
			txt += "\n" + "Ship limit reached (%d)." % cap
		elif main.cash >= price:
			txt += "\n" + StoryText.get_or("LBL_SEND_BUYS_SHIP", "No free ship. Send to... buys one for {price} credits.", {"price": price})
		else:
			txt += "\nNot enough credits."
	var fr: Dictionary = main.can_buy_ship("small")
	if fr.get("floor", false):
		txt += "\n" + str(fr["reason"])
	free_label.text = txt
	for kind in Ships.KINDS:
		var b: Button = buy_buttons[kind]
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
