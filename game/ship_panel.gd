extends PanelContainer
## T28: small Ships menu, right side under the notification board. Shows ship count / cap.

const StoryText := preload("res://game/story_text.gd")
const Ships := preload("res://game/ships.gd")

signal buy_requested(kind: String)
var buy_buttons: Dictionary = {}  # kind -> Button
var label: Label
var upkeep_label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS  # T58: buy buttons live here
	custom_minimum_size = Vector2(240, 0)  # sits in main.gd right_col under the board
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)
	var title := Label.new()
	title.text = "Ships"
	title.theme_type_variation = "LabelTitle"
	box.add_child(title)
	label = Label.new()
	box.add_child(label)
	upkeep_label = Label.new()
	upkeep_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(upkeep_label)
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
		lines.append("Ship %d, %s (%s): %d" % [n, Ships.display_name(str(rec.get("ship", "small"))), str(rec["c"]).capitalize(), pay])
	for kind in Ships.KINDS:
		for i in maxi(0, main.free_of(kind)):
			n += 1
			lines.append("Ship %d, %s (free): 0" % [n, Ships.display_name(kind)])
	lines.append("%s, total: %d / cycle" % [upkeep_name, total])
	upkeep_label.text = "\n".join(lines)
	for kind in Ships.KINDS:
		var b: Button = buy_buttons[kind]
		var r: Dictionary = main.can_buy_ship(kind)
		b.text = "Buy %s (%d cr, upkeep %d)" % [Ships.display_name(kind), Ships.price(kind, main.balance), main.engine.upkeep_part({"ship": kind})]
		b.disabled = not r["ok"]
		b.tooltip_text = str(r["reason"])

func set_count(ships: int, cap: int) -> void:
	label.text = "Ships: %d / %d" % [ships, cap]
