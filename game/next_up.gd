extends HBoxContainer
## T263: the Next Up strip in the top bar (design/proposals/2026-11-06-empire-growth-v2.md section 3.7).
## Three live slots, never empty, each one click focuses the map on the world it names:
##   Closest growth: the world nearest its tier-up and its short need (a hidden good shows as "not known yet").
##   Bazaar: the shortest bill item, the quorum gap or the reach gap; "found it" when a world may host the Bazaar.
##   Best move: a newly hungry lane, else the cash gap to the next ship and the ETA from the cash forecast.
## Reads game state only (Prosperity, Bazaar, cash_forecast); computes no rule. Text by id (StoryText.get_or fallbacks).
## Goods are named only when Availability shows them. No numbers of its own: the ETA comes from cash_forecast.net_forecast().

const StoryText := preload("res://game/story_text.gd")

var main: Control
var _slots: Array = []   # [{button, caption, text, planet}]
var _last: Array = []

func setup(main_node: Control) -> void:
	main = main_node
	add_theme_constant_override("separation", 12)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ids := [["NEXTUP_LBL_GROWTH", "Closest growth"], ["NEXTUP_LBL_BAZAAR", "Bazaar"], ["NEXTUP_LBL_BEST", "Best move"]]
	for k in ids.size():
		var b := Button.new()
		b.theme_type_variation = "ButtonGhost"
		b.flat = true
		b.focus_mode = Control.FOCUS_NONE
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.clip_text = true
		b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(60, 0)
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.pressed.connect(_on_slot.bind(k))
		add_child(b)
		_slots.append({"button": b, "caption": StoryText.get_or(str(ids[k][0]), str(ids[k][1])), "planet": -1})

func _on_slot(k: int) -> void:
	var p := int(_slots[k]["planet"])
	if p >= 0 and main != null and main.has_method("focus_next_up"):
		main.focus_next_up(p)

func refresh() -> void:
	if main == null or main.planet_panel == null or main.engine == null:  # the UI is built before the game state
		return
	var rows := compute()
	if rows == _last:
		return
	_last = rows
	for k in _slots.size():
		var s: Dictionary = _slots[k]
		var r: Dictionary = rows[k]
		var b: Button = s["button"]
		b.text = "%s: %s" % [s["caption"], r["text"]]
		b.tooltip_text = b.text
		s["planet"] = int(r["planet"])
		b.disabled = false  # a slot with no world still shows its line; the click does nothing then

## The three slots as [{text, planet}], planet -1 when there is nothing to focus. Never an empty text.
func compute() -> Array:
	return [_growth(), _bazaar(), _best()]

func _idle() -> Dictionary:
	return {"text": StoryText.get_or("NEXTUP_IDLE", "Keep trading. Check the planet cards."), "planet": -1}

func _growth() -> Dictionary:
	var pr = main.prosperity
	var best := -1
	var best_left := 2.0
	for i in main.map.planets.size():
		var t: int = pr.tier(i)
		if t < 1 or t >= pr.max_tier():
			continue
		var left: float = 1.0 - float(pr.progress(i))
		if left < best_left:
			best_left = left
			best = i
	if best < 0:
		return _idle()
	var need := ""
	for n in pr.needs(best):
		if not bool(n["met"]):
			need = StoryText.get_or("PROS_NEED_LOCKED", "? Not known yet") if bool(n["locked"]) else Ui.good_name(str(n["good"]))
			break
	var pname: String = main.planet_name(best)
	if need == "":
		return {"text": "%s %d%%" % [pname, roundi(float(pr.progress(best)) * 100.0)], "planet": best}
	return {"text": StoryText.get_or("NEXTUP_GROWTH", "{planet}: needs {need}", {"planet": pname, "need": need}), "planet": best}

func _first_good(goods: Array) -> String:
	return Ui.good_name(str(goods[0])) if not goods.is_empty() else StoryText.get_or("PROS_NEED_LOCKED", "? Not known yet")

func _bazaar() -> Dictionary:
	var bz = main.bazaar
	if not bz.is_founded():
		for i in main.map.planets.size():
			if bz.can_found(i):
				return {"text": StoryText.get_or("NEXTUP_BAZAAR_FOUND", "Found the Bazaar at {planet}", {"planet": main.planet_name(i)}), "planet": i}
		return _idle()
	if bz.complete():
		return {"text": StoryText.get_or("BAZ_NAME", "Star Bazaar"), "planet": bz.capital()}
	var short_row := {}
	var short_amt := 0
	for r in bz.bill_status():
		if not bool(r["ok"]):
			var amt := int(r["need"]) - int(r["have"])
			if short_row.is_empty() or amt < short_amt:
				short_row = r
				short_amt = amt
	if not short_row.is_empty():
		return {"text": StoryText.get_or("NEXTUP_BAZAAR_BILL", "Bazaar: {amount} more {commodity}", {"amount": short_amt, "commodity": _first_good(short_row["goods"])}), "planet": bz.capital()}
	var q: Dictionary = bz.quorum_status()
	if not bool(q["ok"]):
		return {"text": StoryText.get_or("NEXTUP_BAZAAR_QUORUM", "Bazaar: {n} more worlds to grow", {"n": int(q["need"]) - int(q["have"])}), "planet": bz.capital()}
	if not bz.reach_ok():
		return {"text": StoryText.get_or("BAZ_REACH_ROW", "One world in another system"), "planet": bz.capital()}
	return {"text": StoryText.get_or("BAZ_NAME", "Star Bazaar"), "planet": bz.capital()}

## T273: the open gig with the nearest deadline, as a Best move line.
func _gig() -> Dictionary:
	var best := {}
	for o in main.gigs.offers:
		if best.is_empty() or float(o["due"]) < float(best["due"]):
			best = o
	if best.is_empty() or main.gig_panel == null:
		return {}
	var board = main.gig_panel
	var lf := snappedf(board.left(best), 0.1)
	var t: Dictionary = best["target"]
	var amber := float(main.balance.get("gig_marker_amber_cycles", 2.0))
	var urgent: bool = board.left(best) <= amber or str(best["kind"]) == "opening"
	var pl := int(t["index"]) if str(t.get("kind", "")) == "planet" else -1
	return {"text": StoryText.get_or("NEXTUP_BEST_GIG", "Gig: {title}, {cycles} cycles left", {"title": board.title_text(best), "cycles": lf}), "planet": pl, "urgent": urgent}

func _best() -> Dictionary:
	var pr = main.prosperity
	var gig := _gig()
	if not gig.is_empty() and bool(gig["urgent"]):
		return gig
	# a newly hungry lane: a need short for a cycle or more, and a world that sells the good
	for i in main.map.planets.size():
		if pr.tier(i) < 1:
			continue
		for n in pr.needs(i):
			if bool(n["met"]) or bool(n["locked"]):
				continue
			var g := str(n["good"])
			if pr.hunger_steps(i, g) <= 0:
				continue
			for a in main.map.planets.size():
				if a != i and pr.tier(a) >= 1 and pr._sells_to_player(a, g):
					return {"text": StoryText.get_or("NEXTUP_BEST_LANE", "Send goods from {planet_a} to {planet_b}", {"planet_a": main.planet_name(a), "planet_b": main.planet_name(i)}), "planet": a}
	# the cash gap to the next ship, with the forecast ETA
	if main.ships < main.ship_cap():
		var need_cash: int = main.ship_price() + main.ship_cash_floor()
		var gap: int = need_cash - main.cash
		var net: int = main.cash_forecast.net_forecast() if main.cash_forecast != null else 0
		if gap > 0 and net > 0:
			return {"text": StoryText.get_or("NEXTUP_BEST_CASH", "Save {cash} credits, about {cycles} cycles", {"cash": gap, "cycles": ceili(float(gap) / float(net))}), "planet": -1}
	return _idle()
