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
			main.tut_note("expenses")
		anchor.accept_event()

## Click anywhere else closes it (the click is not consumed).
func _input(event: InputEvent) -> void:
	if not visible or not (event is InputEventMouseButton) or not event.pressed:
		return
	var p: Vector2 = event.position
	if not get_global_rect().has_point(p) and not anchor.get_global_rect().has_point(p):
		visible = false

## A forecast row where every good's name is drawn as its icon (owner 2026-11-12); "(energy)" becomes just the icon.
## The line texts themselves keep the names (tests and the no-earn warning read them).
func _icon_line(text: String, color: Color, credit: bool = false) -> RichTextLabel:
	var rt := RichTextLabel.new()
	rt.fit_content = true
	rt.scroll_active = false
	rt.autowrap_mode = TextServer.AUTOWRAP_OFF
	rt.mouse_filter = Control.MOUSE_FILTER_PASS
	rt.add_theme_color_override("default_color", color)
	var fs: int = get_theme_font_size("font_size", "Label")  # same size and face as the plain rows
	rt.add_theme_font_size_override("normal_font_size", fs)
	rt.add_theme_font_override("normal_font", get_theme_font("font", "Label"))
	var px := fs
	var names: Array = []  # [name as written, good id], longest first so "dross" never eats part of a longer name
	for c in main.commodities:
		var nm := Ui.good_name(str(c))
		names.append([nm.to_lower(), str(c)])
		names.append([nm, str(c)])
	names.sort_custom(func(x, y): return str(x[0]).length() > str(y[0]).length())
	var at := 0
	var low := text
	while at < low.length():
		var hit := -1
		var hit_len := 0
		var hit_good := ""
		for e in names:
			var i := low.find(str(e[0]), at)
			if i >= 0 and (hit < 0 or i < hit):
				hit = i
				hit_len = str(e[0]).length()
				hit_good = str(e[1])
		if hit < 0:
			rt.add_text(low.substr(at))
			break
		var start := hit
		var end := hit + hit_len
		if start > 0 and low[start - 1] == "(" and end < low.length() and low[end] == ")":  # "(energy)" -> icon alone
			start -= 1
			end += 1
		rt.add_text(low.substr(at, start - at))
		var tex: Texture2D = Ui.icon(hit_good)
		if tex != null:
			var gc := Ui.commodity_col(hit_good)
			rt.add_image(tex, px, px, gc if gc != Color.WHITE else Ui.col("ink"), INLINE_ALIGNMENT_CENTER)
		else:
			rt.add_text(low.substr(hit, hit_len))
		at = end
	if credit and Ui.icon("credit") != null:
		rt.add_text(" ")
		rt.add_image(Ui.icon("credit"), px, px, color, INLINE_ALIGNMENT_CENTER)
	box.add_child(rt)
	return rt

func _line(text: String, color: Color = Color.TRANSPARENT) -> Label:
	var l := Label.new()
	l.text = text
	if color.a > 0.0:
		l.add_theme_color_override("font_color", color)
	box.add_child(l)
	return l

## Order lines [text, signed credits]: local Buy (negative) and Sell (positive). Comes from the engine's
## read-only forecast, so a Sell order counts the goods the routes deliver this same cycle.
func order_lines() -> Array:
	var out: Array = []
	for l in main.engine.forecast(main.cash)["local"]:
		var st := str(l["state"])
		out.append([str(l["label"]) + ("" if st in [StoryText.get_or("RT_STATE_BUYING", "Buying."), StoryText.get_or("RT_STATE_SELLING", "Selling.")] else " (" + st.trim_suffix(".").to_lower() + ")"), int(l["credits"]), st])
	return out

## Route income lines [text, credits]: what each moving route earns itself (upgrade bonus, stop sale).
## The goods it delivers are paid by the Sell orders above.
func route_income_lines() -> Array:
	var out: Array = []
	for r in main.engine.forecast(main.cash)["routes"]:
		if int(r["gross"]) > 0:
			out.append(["%s > %s (%s)" % [main.planet_name(r["a"]), main.planet_name(r["b"]), Ui.good_name(str(r["c"])).to_lower()], int(r["gross"])])
	return out

## Route expense lines [text, positive credits leaving]: trip cost and Ship upkeep per moving route.
## A waiting route shows what it really moves (0 when nothing fits).
func route_expense_lines() -> Array:
	var out: Array = []
	var upkeep := 0  # every ship's upkeep this cycle (moving, idle lanes, ships on no route), shown as one line
	for r in main.engine.forecast(main.cash)["routes"]:
		var base := "%s > %s (%s)" % [main.planet_name(r["a"]), main.planet_name(r["b"]), Ui.good_name(str(r["c"])).to_lower()]
		if bool(r["moves"]):
			out.append([StoryText.get_or("FC_TRIP_COST", "{route} trip cost", {"route": base}), int(r["trip"])])
			upkeep += int(r["upkeep"])
		else:
			upkeep += int(r.get("idle_upkeep", 0))  # the ship is paid even when the lane idles
		if not bool(r["moves"]) and str(r["status"]) != "running":
			out.append([StoryText.get_or("FC_ROUTE_STATUS", "{route} {status}", {"route": base, "status": StoryText.get_or("FC_STATUS_" + str(r["status"]).to_upper(), str(r["status"]))}), 0])
	upkeep += int(main.engine.forecast(main.cash).get("idle_ships_cost", 0))
	if upkeep > 0:  # owner 2026-11-12: one Ship upkeep line for the whole fleet, not one per route
		out.append([StoryText.get_text("LBL_SHIP_UPKEEP"), upkeep])
	return out

## Names of moving routes that earn nothing and cost money: no sale at the destination, no route bonus, and
## nothing uses the stock on: no Sell order or onward route there, and in Space Storage no route out and no built
## workshop in that system that takes the good as an input.
func no_earn_routes() -> Array:
	var out: Array = []
	var e = main.engine
	for r in e.forecast(main.cash)["routes"]:
		if not bool(r["moves"]) or int(r["sale"]) > 0 or int(r["gross"]) > 0 or int(r["paid"]) <= 0:
			continue
		if _stock_used_onward(int(r["b"]), str(r["c"])):
			continue
		out.append("%s > %s (%s)" % [main.planet_name(r["a"]), main.planet_name(r["b"]), Ui.good_name(str(r["c"])).to_lower()])
	return out

func _stock_used_onward(dst: int, c: String) -> bool:
	var e = main.engine
	if dst >= 0:
		return e.has_outflow(dst, c)
	for rec in e.routes:
		if int(rec["a"]) == dst and str(rec["c"]) == c:
			return true
	for ws in main.workshops.IDS:
		if main.workshops.stands_in(ws, -dst):
			for g in Goods.recipes_of(ws):
				if Goods.recipe(g).has(c):
					return true
	return false

## Expected cash change when the current cycle ends (income minus expenses), for the top-bar delta.
func net_forecast() -> int:
	if main == null:
		return 0
	return int(main.engine.forecast(main.cash)["delta"])


## Only lines worth something are listed; a 0 line is not an income or an expense. Totals are unaffected.
func nonzero_lines(lines: Array) -> Array:
	var out: Array = []
	for l in lines:
		if int(l[1]) != 0:
			out.append(l)
	return out

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
		if int(l[1]) > 0 or (int(l[1]) == 0 and str(l[2]) not in [StoryText.get_or("RT_STATE_STORAGE_EMPTY", "Storage empty."), StoryText.get_or("RT_STATE_SELLING", "Selling.")]):
			income.append(l)
		else:
			outcome.append([l[0], -int(l[1])])
	income.append_array(route_income_lines())
	outcome.append_array(route_expense_lines())
	var total_in := 0
	for l in income:
		total_in += int(l[1])
	var total_out := 0
	for l in outcome:
		total_out += int(l[1])
	income = nonzero_lines(income)
	outcome = nonzero_lines(outcome)
	var left: float = (main._cycle_seconds() - main.cycle_elapsed) / maxf(0.01, main.time_speed)
	var timing := StoryText.get_or("FC_PAUSED", "paused") if main.paused else StoryText.get_or("FC_IN_SECONDS", "in {n}s", {"n": ceili(left)})
	_line(StoryText.get_or("FC_HEAD", "Cycle {cycle} ends {timing}. Now: {cash}", {"cycle": main.cycle, "timing": timing, "cash": cash}))
	if main.last_summary != "":
		_line(StoryText.get_or("FC_LAST_CYCLE", "Last cycle: {summary}", {"summary": main.last_summary}))
	_line(StoryText.get_or("FC_INCOME", "Income:"))
	if income.is_empty():
		_line("  " + StoryText.get_or("FC_NONE", "none"), GREEN)
	for l in income:
		_icon_line("  %s: %+d" % [l[0], int(l[1])], GREEN if int(l[1]) >= 0 else RED)
	_line(StoryText.get_text("LBL_EXPENSES") + ":")
	if outcome.is_empty():
		_line("  " + StoryText.get_or("FC_NONE", "none"), RED)
	for l in outcome:
		_icon_line("  %s: -%d" % [l[0], int(l[1])], RED, str(l[0]) == StoryText.get_text("LBL_SHIP_UPKEEP"))
	for nm in no_earn_routes():
		var w := _line(StoryText.get_or("LBL_FC_NO_EARN", "{route} earns nothing: it only moves stock to storage.", {"route": nm}), Ui.col("signal_warn"))
		w.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		w.custom_minimum_size = Vector2(280, 0)
	_line(StoryText.get_or("FC_AFTER", "After cycle: {cash}", {"cash": cash + total_in - total_out}))
