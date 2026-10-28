extends PanelContainer
## T40 / T40b: dropdown under the top-bar money text. Lists what each route pays when the current
## cycle ends (net income per route, from the T07 engine) and the cash after the cycle.
## T69: income green, expenses red. Income lines are gross (sells); expenses list buys, each moving
## route's trip cost and each moving ship's Ship upkeep as its own line, so After cycle = income - expenses.
## The per-route status lives on the planet panel.

const StoryText := preload("res://game/story_text.gd")
var GREEN: Color = Ui.col("signal_good")
var RED: Color = Ui.col("signal_bad")

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
	Ui.scroll_wrap(self, box, 90.0)  # long forecasts scroll inside the window
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

func _line(text: String, color: Color = Color.TRANSPARENT) -> void:
	var l := Label.new()
	l.text = text
	if color.a > 0.0:
		l.add_theme_color_override("font_color", color)
	box.add_child(l)

## Order lines [text, signed credits]: local Buy (negative) and Sell (positive).
func order_lines() -> Array:
	var out: Array = []
	for l in main.engine.local_preview(main.cash):  # T68 local orders
		out.append([str(l[0]) + ("" if str(l[2]) in ["Buying.", "Selling."] else " (" + str(l[2]).trim_suffix(".").to_lower() + ")"), int(l[1])])
	return out

## Route expense lines [text, positive credits leaving]: trip cost and Ship upkeep per moving route.
## A waiting route shows what it really moves (0 when nothing fits).
func route_expense_lines() -> Array:
	var out: Array = []
	var trip: int = main.engine.trip_part()
	var up: int = main.engine.upkeep_part()
	for rec in main.engine.routes:
		var base := "%s > %s (%s)" % [main.planet_name(rec["a"]), main.planet_name(rec["b"]), rec["c"]]
		var status: String = main.engine.status_of(rec)
		if main.engine.payout_of(rec) < 0:
			out.append([base + " trip cost", trip])
			out.append([base + " " + StoryText.get_text("LBL_SHIP_UPKEEP"), up])
		elif status != "running":
			out.append([base + " " + status, 0])
	return out

## Expected cash change when the current cycle ends (income minus expenses), for the top-bar delta.
func net_forecast() -> int:
	if main == null:
		return 0
	var net := 0
	for l in order_lines():
		net += int(l[1])
	for l in route_expense_lines():
		net -= int(l[1])
	return net

## Called by main.gd _refresh() every frame; rebuilds the lines while open.
func refresh() -> void:
	if not visible or main == null:
		return
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()
	var cash: int = main.cash
	var income: Array = []
	var outcome: Array = []  # [text, amount], amount positive = cash leaving
	for l in order_lines():
		if int(l[1]) >= 0:
			income.append(l)
		else:
			outcome.append([l[0], -int(l[1])])
	outcome.append_array(route_expense_lines())
	var total_in := 0
	for l in income:
		total_in += int(l[1])
	var total_out := 0
	for l in outcome:
		total_out += int(l[1])
	var left: float = (main._cycle_seconds() - main.cycle_elapsed) / maxf(0.01, main.time_speed)
	var timing := "paused" if main.paused else "in %ds" % ceili(left)
	_line("Cycle %d ends %s. Now: %d" % [main.cycle, timing, cash])
	if main.last_summary != "":
		_line("Last cycle: " + main.last_summary)
	_line("Income:")
	if income.is_empty():
		_line("  none", GREEN)
	for l in income:
		_line("  %s: %+d" % [l[0], int(l[1])], GREEN if int(l[1]) >= 0 else RED)
	_line(StoryText.get_text("LBL_EXPENSES") + ":")
	if outcome.is_empty():
		_line("  none", RED)
	for l in outcome:
		_line("  %s: -%d" % [l[0], int(l[1])], RED)
	_line("After cycle: %d" % (cash + total_in - total_out))
