extends PanelContainer
## T40: dropdown under the top-bar money text. Shows what happens to cash when the current
## cycle ends: income lines (green), outcome lines (red), cash after the cycle.
## Only mechanics that exist: _end_cycle() in main.gd charges nothing yet, so the only line
## is maintenance from balance.json (maintenance every maintenance_interval cycles), which is
## shown but NOT counted until T07 charges it. Flip MAINTENANCE_CHARGED to true then.

const MAINTENANCE_CHARGED := false
const GREEN := Color(0.45, 0.9, 0.45)
const RED := Color(1.0, 0.45, 0.4)

var main: Control
var anchor: Control  # the clickable money label
var box: VBoxContainer

func setup(main_node: Control, anchor_label: Control) -> void:
	main = main_node
	anchor = anchor_label
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP  # clicks on the dropdown never reach the 3D map
	custom_minimum_size = Vector2(300, 0)
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	add_child(box)
	anchor.mouse_filter = Control.MOUSE_FILTER_STOP
	anchor.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	anchor.gui_input.connect(_on_anchor_input)

func _on_anchor_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if visible:
			visible = false
		else:
			var r := anchor.get_global_rect()
			position = Vector2(r.position.x, r.end.y + 4)
			visible = true
			refresh()
		anchor.accept_event()

## Click anywhere else closes it (the click is not consumed).
func _input(event: InputEvent) -> void:
	if not visible or not (event is InputEventMouseButton) or not event.pressed:
		return
	var p: Vector2 = event.position
	if not get_global_rect().has_point(p) and not anchor.get_global_rect().has_point(p):
		visible = false

func _line(text: String, color: Color = Color.WHITE) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	box.add_child(l)

## Called by main.gd _refresh() every frame; rebuilds the lines while open.
func refresh() -> void:
	if not visible or main == null:
		return
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()
	var bal: Dictionary = main.balance
	var cash: int = main.cash
	var income: Array = []   # [text, amount]
	var outcome: Array = []  # [text, amount], amount positive = cash leaving
	var interval := int(bal.get("maintenance_interval", 0))
	var upkeep := int(bal.get("maintenance", 0))
	var counted := 0
	if interval > 0 and upkeep > 0 and main.cycle % interval == 0:
		var note := "" if MAINTENANCE_CHARGED else " (not charged yet)"
		outcome.append(["Maintenance%s" % note, upkeep])
		if MAINTENANCE_CHARGED:
			counted = upkeep
	var total_in := 0
	for l in income:
		total_in += int(l[1])
	var total_out := counted
	var left: float = (main._cycle_seconds() - main.cycle_elapsed) / maxf(0.01, main.time_speed)
	var timing := "paused" if main.paused else "in %ds" % ceili(left)
	_line("Cycle %d ends %s. Now: %d" % [main.cycle, timing, cash])
	_line("Income:")
	if income.is_empty():
		_line("  none", GREEN)
	for l in income:
		_line("  %s: +%d" % [l[0], int(l[1])], GREEN)
	_line("Outcome:")
	if outcome.is_empty():
		_line("  none", RED)
	for l in outcome:
		_line("  %s: -%d" % [l[0], int(l[1])], RED)
	_line("After cycle: %d" % (cash + total_in - total_out))
