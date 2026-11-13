class_name Prosperity
extends RefCounted
## Prosperity (design/proposals/2026-11-06-empire-growth-v2.md section 3.1). Every established world has a tier and a
## need list; sales AT the world fill the needs; progress and tier-ups happen at cycle end (main._end_cycle).
##
## Tier: -1 Barren (dead world, no ladder yet; reclaim hook: reclaim(pid) makes it a living tier-1 world), 0 discovered
## (no post), 1 once the post stands, up to max_tier(). A world never loses a tier.
## Needs by rule: energy plus the run's branch goods whose goods.json tier <= world tier, minus goods the world already
## sells to the player (it has a <good>_buy price), ordered by data/prosperity.json weights, capped by balance
## prosperity_needs_t<N>. data/prosperity.json "overrides" {planet id: [good ids]} replaces the rule for one world.
## Numbers (all balance.json, placeholders until economy-designer sets them): prosperity_max_tier, prosperity_needs_t<N>,
## prosperity_demand_t<N> (units per need per cycle), prosperity_steps_t<N> (steps to leave tier N), prosperity_decay_steps. T258 rewards (placeholders): prosperity_tax_t<N> (credits per world per cycle), prosperity_points_t<N> (skill points the first time any world reaches tier N).
## A need whose good is not visible (Availability) counts as unmet and is reported as locked with good "?".
## Need pricing (T257, balance keys, all placeholders): need_price_t<N> (multiplier of the good's base_value for a sell price a
## need opens where the world had none), need_hunger_step_pct / need_hunger_cap_pct (the sell price rises a step per cycle a
## need stays short, up to the cap, and steps back down once met), need_surplus_pct (share of the price paid for units sold
## above the demand in a cycle), need_surplus_all (0/1: surplus applies to every sale, not only need goods).
## T261 skills: need_fill_pct (Skills.need_fill_bonus) adds units to add_fill; progress_grace (Skills.progress_grace) spares part of the unmet-cycle progress loss.
## T295 reclaim (design section 3.4): a Barren world has a reclamation need list (data/prosperity.json "reclaim": goods_tier = highest goods tier
## of the branch goods listed, extra = one extra good (first of the list the branch trades and Availability shows, else the first the branch trades);
## balance prosperity_reclaim_needs, prosperity_reclaim_steps; demand and prices use the tier 1 keys). Sales AT the world fill it; each met cycle
## adds a step, a short one decays as for living worlds. Full = reclaim(i): type "reclaimed", tier 1, signal reclaimed (main counts its post as built),
## its mined goods stop for good. mining_closed(i) is true while reclaim progress > 0 and after it. Saved with the rest ("reclaimed" ids; the planet look is re-applied on load).
## Saved by main under "prosperity". Old saves: established worlds start at tier 1 (nothing stored).

signal tier_up(planet: int, tier: int)
signal first_need_filled(planet: int, good: String)  # first units that fill any need this run (main posts a congratulation)
signal reclaimed(planet: int)  # T295: a Barren world filled its reclamation ring and turned living (main marks its post as built)

const PATH := "res://data/prosperity.json"
const DeadWorlds := preload("res://game/dead_worlds.gd")
const PlanetTypes := preload("res://game/planet_types.gd")
const StoryText := preload("res://game/story_text.gd")
const RECLAIMED_TYPE := "reclaimed"

var balance: Dictionary = {}
var planets: Array = []
var established_fn: Callable = Callable()  # (planet id: String) -> bool, the post stands
var data: Dictionary = {}
var _tier: Dictionary = {}      # planet id -> stored tier (only tiers above 1, or 1 for reclaimed worlds)
var _steps: Dictionary = {}     # planet id -> progress steps in the current tier (float since T261: progress_grace spares part of a loss)
var _sold: Dictionary = {}      # planet id -> {good: units sold this cycle}
var _last_sold: Dictionary = {} # same, for the cycle that just ended (shown on the Needs list)
var _warned_empty: Dictionary = {}
var _restless: Dictionary = {}  # planet id -> true when a need was short at the last cycle end
var _reclaimed: Dictionary = {} # planet id -> true (hook for the Barren reclaim task)
var _carry: Dictionary = {}     # T261: fractional need-fill bonus units not yet counted (not saved)
var _first_fill_done := false
var _reached := 0               # T258: highest tier any world has reached this run (skill points paid up to it)
var branch_fn: Callable = Callable()  # () -> String: the run's branch (CEO market id, "" when none), set by main; picks overrides_by_branch
var weather = null              # T280: Events (shortage_mult, shortage_hunger), set by main; null in tests that do not need it
var _hunger: Dictionary = {}    # T257: planet id -> {good: cycles the need was short in a row (capped by need_hunger_cap_pct)}

func setup(bal: Dictionary, planet_list: Array, established: Callable) -> void:
	balance = bal
	planets = planet_list
	established_fn = established
	_tier = {}
	_steps = {}
	_sold = {}
	_last_sold = {}
	_restless = {}
	_reclaimed = {}
	_hunger = {}
	_carry = {}
	_reached = 0
	_first_fill_done = false
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
	data = parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _pid(i: int) -> String:
	return str(planets[i].get("id", "")) if i >= 0 and i < planets.size() and typeof(planets[i]) == TYPE_DICTIONARY else ""

func _n(key: String, tier: int, fallback: float) -> float:
	return float(balance.get(key + "_t" + str(tier), fallback))

func max_tier() -> int:
	return maxi(1, int(balance.get("prosperity_max_tier", 3)))

## T258: highest tier any world stands at now.
func top_tier() -> int:
	var top := 0
	for i in range(planets.size()):
		top = maxi(top, tier(i))
	return top

## T258 atom any_tier:<n>: some world has reached tier n (a world never loses a tier).
func any_tier_reached(n: int) -> bool:
	return maxi(_reached, top_tier()) >= n

## T258: tax income of every world for one cycle, by tier (balance prosperity_tax_t<N>).
func tax_total() -> int:
	var sum := 0
	for i in range(planets.size()):
		var t := tier(i)
		if t >= 1:
			sum += maxi(0, roundi(_n("prosperity_tax", t, 0.0)))
	return sum

## T258: tiers reached for the first time by any world since the last call, as [{tier, points}] (points may be 0).
func claim_new_tiers() -> Array:
	var out := []
	var top := top_tier()
	while _reached < top:
		_reached += 1
		out.append({"tier": _reached, "points": maxi(0, int(_n("prosperity_points", _reached, 0.0)))})
	return out

func is_barren(i: int) -> bool:
	var pid := _pid(i)
	return pid != "" and DeadWorlds.is_dead(planets[i]) and not _reclaimed.has(pid)

## Ladder tier used for needs, demand, fill and progress: a Barren world works like tier 1 for its reclamation list.
func _lt(i: int) -> int:
	var t := tier(i)
	return 1 if t == -1 else t

func _post_stands(pid: String) -> bool:
	return established_fn.is_valid() and bool(established_fn.call(pid))

## T295: a Barren world becomes a living tier-1 world (a new planet type), its mined goods stop for good.
func reclaim(i: int) -> void:
	var pid := _pid(i)
	if pid == "":
		return
	var was_barren := is_barren(i)
	_reclaimed[pid] = true
	_tier[pid] = maxi(1, int(_tier.get(pid, 1)))
	_steps[pid] = 0
	_sold.erase(pid)
	_hunger.erase(pid)
	_restless.erase(pid)
	_apply_reclaimed_look(i)
	if was_barren:
		reclaimed.emit(i)

## The planet row turns into a living world: type "reclaimed", no more mined (_buy) goods. Idempotent.
func _apply_reclaimed_look(i: int) -> void:
	if i < 0 or i >= planets.size() or typeof(planets[i]) != TYPE_DICTIONARY:
		return
	var p: Dictionary = planets[i]
	p["type"] = RECLAIMED_TYPE
	PlanetTypes.apply(p)
	var prices = p.get("base_prices")
	if typeof(prices) == TYPE_DICTIONARY:
		for k in prices.keys():
			if str(k).ends_with("_buy"):
				prices.erase(k)

func is_reclaimed(i: int) -> bool:
	return _reclaimed.has(_pid(i))

## Reclaim progress of a Barren world, 0..1 (0 for any other world).
func reclaim_progress(i: int) -> float:
	return progress(i) if is_barren(i) else 0.0

## Mining a world stops while it is being reclaimed (progress above 0) and for good once it is reclaimed.
func mining_closed(i: int) -> bool:
	var pid := _pid(i)
	if pid == "":
		return false
	return _reclaimed.has(pid) or (is_barren(i) and float(_steps.get(pid, 0)) > 0.0)

func mining_closed_reason(i: int) -> String:
	if not mining_closed(i):
		return ""
	if _reclaimed.has(_pid(i)):
		return StoryText.get_or("NOT_MINE_RECLAIMED", "This world is alive again and is no longer mined.")
	return StoryText.get_or("NOT_MINE_RECLAIMING", "Being reclaimed: mining is closed here.")

## T284: the lean on a world, 'warm' | 'plain' | 'cold' (Chains.mood_of). A face only: nothing here reads it for prices, growth or tax.
func mood(i: int) -> String:
	return Chains.mood_of(_pid(i))

func tier(i: int) -> int:
	var pid := _pid(i)
	if pid == "":
		return 0
	if is_barren(i):
		return -1
	if not _reclaimed.has(pid) and not (established_fn.is_valid() and bool(established_fn.call(pid))):
		return 0
	return clampi(maxi(1, int(_tier.get(pid, 1))), 1, max_tier())

## Planet ids are written to _tier only above tier 1, so a world with the post stands at 1 whatever the save says.
func _need_goods(i: int) -> Array:
	var t := _lt(i)
	if t < 1:
		return []
	var pid := _pid(i)
	if is_barren(i):
		return _reclaim_goods(i)
	var cap := maxi(0, int(_n("prosperity_needs", t, 2.0)))
	var out: Array = []
	var ov = data.get("overrides", {})
	var by_branch = data.get("overrides_by_branch", {})  # a world's need that depends on the CEO: the starter good the CEO can see and supply
	var br: String = str(branch_fn.call()) if branch_fn.is_valid() else ""
	if br != "" and typeof(by_branch) == TYPE_DICTIONARY and typeof(by_branch.get(br)) == TYPE_DICTIONARY and (by_branch[br] as Dictionary).has(pid):
		ov = by_branch[br]
	if typeof(ov) == TYPE_DICTIONARY and ov.has(pid) and typeof(ov[pid]) == TYPE_ARRAY:
		for g in ov[pid]:
			if out.size() < cap and Goods.has(str(g)) and not out.has(str(g)):
				out.append(str(g))
		return out
	var cands: Array = []
	for g in Goods.ids():
		if g != "energy" and (int(Goods.entry(g).get("tier", 1)) > t or not Goods.branch_ok(g)):
			continue
		if g == "ore" or _sells_to_player(i, g):  # ore is an industrial input, never a world need (2026-11-12)
			continue
		cands.append(g)
	var weights: Dictionary = {}
	var tw = data.get("type_weights", {})
	if typeof(tw) == TYPE_DICTIONARY and typeof(tw.get(str(planets[i].get("type", "")))) == TYPE_DICTIONARY:
		weights = tw[str(planets[i].get("type", ""))]
	var order: Dictionary = {}
	for k in range(cands.size()):
		order[cands[k]] = k
	var def_w := float(data.get("default_weight", 1))
	var en_w := float(data.get("energy_weight", 2))
	cands.sort_custom(func(a, b) -> bool:
		var wa := float(weights.get(a, en_w if a == "energy" else def_w))
		var wb := float(weights.get(b, en_w if b == "energy" else def_w))
		if wa != wb:
			return wa > wb
		return int(order[a]) < int(order[b]))
	for g in cands:
		if out.size() < cap:
			out.append(g)
	if out.is_empty() and cap > 0 and Goods.has("energy"):
		out.append("energy")  # ore is never a need; a world with nothing else to want asks for energy rather than nothing
	return out

## T295: reclamation list of a Barren world: energy and the branch goods up to goods_tier (ordered like a living world), capped by
## prosperity_reclaim_needs, plus one extra good where the branch trades it (data/prosperity.json "reclaim").
func _reclaim_goods(i: int) -> Array:
	var rc = data.get("reclaim", {})
	if typeof(rc) != TYPE_DICTIONARY:
		rc = {}
	var gt := int(rc.get("goods_tier", 1))
	var cap := maxi(0, int(balance.get("prosperity_reclaim_needs", 3)))
	var cands: Array = []
	for g in Goods.ids():
		if g != "energy" and (int(Goods.entry(g).get("tier", 1)) > gt or not Goods.branch_ok(g)):
			continue
		if g == "ore" or _sells_to_player(i, g):  # ore is an industrial input, never a world need (2026-11-12)
			continue
		cands.append(g)
	var order: Dictionary = {}
	for k in range(cands.size()):
		order[cands[k]] = k
	var def_w := float(data.get("default_weight", 1))
	var en_w := float(data.get("energy_weight", 2))
	cands.sort_custom(func(a, b) -> bool:
		var wa := en_w if a == "energy" else def_w
		var wb := en_w if b == "energy" else def_w
		if wa != wb:
			return wa > wb
		return int(order[a]) < int(order[b]))
	var out: Array = []
	for g in cands:
		if out.size() < cap:
			out.append(g)
	var extra := ""
	var extras = rc.get("extra", [])
	if typeof(extras) == TYPE_ARRAY:
		for g in extras:
			if Goods.has(str(g)) and Goods.branch_ok(str(g)) and not out.has(str(g)):
				if extra == "":
					extra = str(g)
				if Availability.good(str(g)):
					extra = str(g)
					break
	if extra != "":
		out.append(extra)
	return out

## The world already sells this good to the player (it has a <good>_buy price): its exports never become its needs.
func _sells_to_player(i: int, g: String) -> bool:
	var prices = planets[i].get("base_prices")
	return typeof(prices) == TYPE_DICTIONARY and prices.has(g + "_buy")

func demand(i: int) -> int:
	return maxi(0, roundi(_n("prosperity_demand", _lt(i), 0.0)))

## T280: demand of one need good at a world: the tier demand x a live shortage on that good.
func demand_for(i: int, good: String) -> int:
	var d := demand(i)
	if weather == null:
		return d
	return maxi(0, roundi(float(d) * float(weather.shortage_mult(i, good))))

## Units of `good` sold at world i in the cycle that just ended (what the Needs list shows; the live count above resets at every cycle end).
func sold_last(i: int, good: String) -> int:
	return int(_last_sold.get(_pid(i), {}).get(good, 0))

func sold(i: int, good: String) -> int:
	return int(_sold.get(_pid(i), {}).get(good, 0))

## Called where sales are noted (route_engine._note_sale) and by the Flagship and hubs for hand sales and deliveries.
func add_fill(i: int, good: String, units: int) -> void:
	var pid := _pid(i)
	if pid == "" or units <= 0 or _lt(i) < 1:
		return
	var d: Dictionary = _sold.get(pid, {})
	var bonus := Skills.need_fill_bonus(Markets.market_of(good))  # T261: need_fill_pct skills
	if bonus > 0.0:
		var carry := float(_carry.get(pid + "|" + good, 0.0)) + float(units) * bonus
		var extra := floori(carry)
		_carry[pid + "|" + good] = carry - float(extra)
		units += extra
	d[good] = int(d.get(good, 0)) + units
	_sold[pid] = d
	if not _first_fill_done and is_need(i, good):
		_first_fill_done = true
		first_need_filled.emit(i, good)

## ---- Need pricing (T257) ----
func is_need(i: int, good: String) -> bool:
	return _need_goods(i).has(good)

## Sell price a need opens at a world with no sell price for the good (base_value x need_price_t<tier>); 0 when not a need or not visible.
func need_price(i: int, good: String) -> int:
	if not is_need(i, good) or not Availability.good(good):
		return 0
	return maxi(0, roundi(float(Markets.value_of(good)) * _n("need_price", _lt(i), 1.0)))

func hunger_steps(i: int, good: String) -> int:
	var h := int(_hunger.get(_pid(i), {}).get(good, 0))
	if weather != null and is_need(i, good):
		h += int(weather.shortage_hunger(i, good))  # T280: a shortage adds hunger steps while it runs
	return h

## Multiplier on the sell price for a need that has been short: 1 + steps x step pct, capped. 1.0 for anything else.
func hunger_factor(i: int, good: String) -> float:
	var h := hunger_steps(i, good)
	if h <= 0 or not is_need(i, good):
		return 1.0
	var cap := maxf(0.0, float(balance.get("need_hunger_cap_pct", 0.0)))
	return 1.0 + minf(float(h) * maxf(0.0, float(balance.get("need_hunger_step_pct", 0.0))), cap) / 100.0

func _surplus_applies(i: int, good: String) -> bool:
	return _lt(i) >= 1 and (int(balance.get("need_surplus_all", 0)) != 0 or is_need(i, good))

## Of n units about to be sold at this world, how many fall above the cycle's demand (`extra` = units already counted by a forecast).
func surplus_units(i: int, good: String, n: int, extra: int = 0) -> int:
	if n <= 0 or not _surplus_applies(i, good):
		return 0
	var room := maxi(0, demand_for(i, good) - sold(i, good) - extra)
	return maxi(0, n - room)

func surplus_factor() -> float:
	return clampf(float(balance.get("need_surplus_pct", 100.0)) / 100.0, 0.0, 1.0)

## 'hungry' (need short and the price raised), 'surplus' (sold above the demand this cycle) or ''.
func price_reason(i: int, good: String) -> String:
	if _lt(i) < 1:
		return ""
	if _surplus_applies(i, good) and surplus_factor() < 1.0 and sold(i, good) > demand_for(i, good):
		return "surplus"
	if is_need(i, good) and hunger_steps(i, good) > 0 and sold(i, good) < demand_for(i, good) and hunger_factor(i, good) > 1.0:
		return "hungry"
	return ""

## UI API: [{good (or "?"), demand, sold, met, locked}] in need order.
func needs(i: int) -> Array:
	var out: Array = []
	for g in _need_goods(i):
		var dem := demand_for(i, g)
		var locked := not Availability.good(g)
		var s := sold(i, g)
		var shown := maxi(s, sold_last(i, g))  # sales happen at the cycle end: show the last settled cycle, not the empty new one
		out.append({"good": "?" if locked else g, "demand": dem, "sold": shown, "met": (not locked) and shown >= dem, "locked": locked})
	return out

func all_met(i: int) -> bool:
	var ns := needs(i)
	if ns.is_empty():
		return false
	for n in ns:
		if not bool(n["met"]):
			return false
	return true

## Steps to leave the current tier; a Barren world needs prosperity_reclaim_steps to turn living.
func _steps_for(i: int) -> int:
	if is_barren(i):
		return maxi(1, int(balance.get("prosperity_reclaim_steps", 4)))
	return maxi(1, int(_n("prosperity_steps", tier(i), 3.0)))

## Progress inside the current tier, 0..1 (1 at the top tier). A Barren world: the reclamation ring.
func progress(i: int) -> float:
	var t := _lt(i)
	if t < 1:
		return 0.0
	if t >= max_tier() and not is_barren(i):
		return 1.0
	return clampf(float(_steps.get(_pid(i), 0)) / float(_steps_for(i)), 0.0, 1.0)

## Notches of the progress ring: steps to leave the current tier, and the steps gathered so far (T264 map ring).
func steps_needed(i: int) -> int:
	return _steps_for(i) if _lt(i) >= 1 else 0

func steps(i: int) -> int:
	return maxi(0, floori(float(_steps.get(_pid(i), 0)) + 0.0001)) if _lt(i) >= 1 else 0

## True when a need was short at the last cycle end.
func restless(i: int) -> bool:
	return bool(_restless.get(_pid(i), false))

## Cycle end: every need met = a step; any short = minus decay (floor 0); full = tier up. Then the counters reset.
## CEO endings: worlds Restless at the last cycle end.
func restless_count() -> int:
	var n := 0
	for k in _restless:
		if bool(_restless[k]):
			n += 1
	return n

func end_cycle() -> void:
	_last_sold = _sold.duplicate(true)  # sales settle at the cycle end, so the live count is 0 on screen: the panel shows this one
	for i in range(planets.size()):
		var t := _lt(i)
		if t < 1:
			continue
		var pid := _pid(i)
		var barren := is_barren(i)
		if barren and not _post_stands(pid):
			continue  # no platform yet: nothing can be sold there
		var ok := all_met(i)
		_update_hunger(i, pid)
		# T349: a world with nothing to need is neither met nor Restless: it gains and loses no progress (and warns once).
		if _need_goods(i).is_empty():
			_restless[pid] = false
			if not _warned_empty.has(pid):
				_warned_empty[pid] = true
				push_warning("Prosperity: world %s has no need goods (check data/prosperity.json)" % pid)
			continue
		_restless[pid] = not ok
		if barren or t < max_tier():
			if ok:
				_steps[pid] = float(_steps.get(pid, 0)) + 1.0
				if float(_steps[pid]) >= _steps_for(i):
					if barren:
						reclaim(i)  # the ring is full: the world turns living
					else:
						_tier[pid] = t + 1
						_steps[pid] = 0
						_sold.erase(pid)
						tier_up.emit(i, t + 1)
			else:
				# T261: progress_grace skills (best of the world's need markets: the sum over every market it feeds, capped at 1) spare part of the loss
				var loss := float(maxi(0, int(balance.get("prosperity_decay_steps", 1)))) * (1.0 - _grace(i))
				_steps[pid] = maxf(0.0, float(_steps.get(pid, 0)) - loss)
	_sold = {}

## T261: share of an unmet cycle's progress loss spared at world i: progress_grace of the markets of its need goods, summed over
## distinct markets and capped at 1.
func _grace(i: int) -> float:
	var seen := {}
	var g := 0.0
	for n in _need_goods(i):
		var m := Markets.market_of(n)
		if m != "" and not seen.has(m):
			seen[m] = true
			g += Skills.progress_grace(m)
	return clampf(g, 0.0, 1.0)

## Cycle end: each need short (or locked) adds a hunger step, each met need steps back down one.
func _update_hunger(i: int, pid: String) -> void:
	var d: Dictionary = _hunger.get(pid, {})
	var next := {}
	var step := float(balance.get("need_hunger_step_pct", 0.0))
	var max_steps := ceili(float(balance.get("need_hunger_cap_pct", 0.0)) / step) if step > 0.0 else 0
	for g in _need_goods(i):
		var h := int(d.get(g, 0))
		var met := Availability.good(g) and sold(i, g) >= demand_for(i, g)
		h = maxi(0, h - 1) if met else mini(h + 1, max_steps)
		if h > 0:
			next[g] = h
	if next.is_empty():
		_hunger.erase(pid)
	else:
		_hunger[pid] = next

func to_dict() -> Dictionary:
	return {"tier": _tier.duplicate(), "steps": _steps.duplicate(), "sold": _sold.duplicate(true), "last_sold": _last_sold.duplicate(true), "restless": _restless.duplicate(), "reclaimed": _reclaimed.duplicate(), "hunger": _hunger.duplicate(true), "reached": _reached, "first_fill": _first_fill_done}

func from_dict(s) -> void:
	_tier = {}
	_steps = {}
	_sold = {}
	_restless = {}
	_reclaimed = {}
	_hunger = {}
	_carry = {}
	_reached = 0
	_first_fill_done = false
	if typeof(s) != TYPE_DICTIONARY:
		return  # old saves: established worlds start at tier 1
	for k in s.get("tier", {}):
		_tier[str(k)] = clampi(int(s["tier"][k]), 1, max_tier())
	for k in s.get("steps", {}):
		_steps[str(k)] = maxf(0.0, float(s["steps"][k]))
	var ls = s.get("last_sold", {})
	if typeof(ls) == TYPE_DICTIONARY:
		for k in ls:
			if typeof(ls[k]) == TYPE_DICTIONARY:
				var d2 := {}
				for g in ls[k]:
					d2[str(g)] = maxi(0, int(ls[k][g]))
				_last_sold[str(k)] = d2
	var sd = s.get("sold", {})
	if typeof(sd) == TYPE_DICTIONARY:
		for k in sd:
			if typeof(sd[k]) == TYPE_DICTIONARY:
				var d := {}
				for g in sd[k]:
					d[str(g)] = maxi(0, int(sd[k][g]))
				_sold[str(k)] = d
	for k in s.get("restless", {}):
		_restless[str(k)] = bool(s["restless"][k])
	for k in s.get("reclaimed", {}):
		_reclaimed[str(k)] = true
		for i in range(planets.size()):
			if _pid(i) == str(k):
				_apply_reclaimed_look(i)
	_reached = maxi(0, int(s.get("reached", 0)))  # old saves: no back pay, claim_new_tiers() starts from the saved top below
	var any_progress := _reached > 0 or top_tier() > 1
	for k in _sold:
		for g in _sold[k]:
			if int(_sold[k][g]) > 0:
				any_progress = true
	_first_fill_done = bool(s["first_fill"]) if s.has("first_fill") else any_progress
	var hg = s.get("hunger", {})
	if typeof(hg) == TYPE_DICTIONARY:
		for k in hg:
			if typeof(hg[k]) == TYPE_DICTIONARY:
				var d := {}
				for g in hg[k]:
					d[str(g)] = maxi(0, int(hg[k][g]))
				_hunger[str(k)] = d
