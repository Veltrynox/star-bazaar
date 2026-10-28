extends PanelContainer
## T40 / T40b: dropdown under the top-bar money text. Lists what each route pays when the current
## cycle ends (net income per route, from the T07 engine) and the cash after the cycle.
## Income green, outcome red. Trip cost and maintenance are netted inside each route (GDD), so no
## gross or cost line appears here; the per-route status lives on the planet panel.
## Outcome lines are the cash that really leaves at cycle end; nothing is charged directly any more.

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

## Income lines: one per route, the amount it pays when this cycle ends (engine payout, net).
func income_lines() -> Array:
	var out: Array = []  # [text, amount]
	for l in main.engine.local_preview(main.cash):  # T68 local orders (buys negative, sells positive)
		out.append([str(l[0]) + ("" if str(l[2]) in ["Buying.", "Selling."] else " (" + str(l[2]).trim_suffix(".").to_lower() + ")"), int(l[1])])
	for rec in main.engine.routes:
		var paid: int = main.engine.payout_of(rec)
		var status: String = main.engine.status_of(rec)
		var label := "%s > %s (%s)" % [main.planet_name(rec["a"]), main.planet_name(rec["b"]), rec["c"]]
		if status != "running":
			label += " " + status
		label += " ship cost"
		out.append([label, paid])
	return out

## Called by main.gd _refresh() every frame; rebuilds the lines while open.
func refresh() -> void:
	if not visible or main == null:
		return
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()
	var cash: int = main.cash
	var income := income_lines()
	var outcome: Array = []  # [text, amount], amount positive = cash leaving; none exist today
	var total_in := 0
	for l in income:
		total_in += int(l[1])
	var total_out := 0
	for l in outcome:
		total_out += int(l[1])
	var left: float = (main._cycle_seconds() - main.cycle_elapsed) / maxf(0.01, main.time_speed)
	var timing := "paused" if main.paused else "in %ds" % ceili(left)
	_line("Cycle %d ends %s. Now: %d" % [main.cycle, timing, cash])
	_line("Income (net per order and route):")
	if income.is_empty():
		_line("  none", GREEN)
	for l in income:
		_line("  %s: %+d" % [l[0], int(l[1])], GREEN if int(l[1]) >= 0 else RED)
	_line("Outcome:")
	if outcome.is_empty():
		_line("  none", RED)
	for l in outcome:
		_line("  %s: -%d" % [l[0], int(l[1])], RED)
	_line("After cycle: %d" % (cash + total_in - total_out))
