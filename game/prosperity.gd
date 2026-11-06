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
## prosperity_demand_t<N> (units per need per cycle), prosperity_steps_t<N> (steps to leave tier N), prosperity_decay_steps.
## A need whose good is not visible (Availability) counts as unmet and is reported as locked with good "?".
## Saved by main under "prosperity". Old saves: established worlds start at tier 1 (nothing stored).

signal tier_up(planet: int, tier: int)

const PATH := "res://data/prosperity.json"
const DeadWorlds := preload("res://game/dead_worlds.gd")

var balance: Dictionary = {}
var planets: Array = []
var established_fn: Callable = Callable()  # (planet id: String) -> bool, the post stands
var data: Dictionary = {}
var _tier: Dictionary = {}      # planet id -> stored tier (only tiers above 1, or 1 for reclaimed worlds)
var _steps: Dictionary = {}     # planet id -> progress steps in the current tier
var _sold: Dictionary = {}      # planet id -> {good: units sold this cycle}
var _restless: Dictionary = {}  # planet id -> true when a need was short at the last cycle end
var _reclaimed: Dictionary = {} # planet id -> true (hook for the Barren reclaim task)

func setup(bal: Dictionary, planet_list: Array, established: Callable) -> void:
	balance = bal
	planets = planet_list
	established_fn = established
	_tier = {}
	_steps = {}
	_sold = {}
	_restless = {}
	_reclaimed = {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
	data = parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _pid(i: int) -> String:
	return str(planets[i].get("id", "")) if i >= 0 and i < planets.size() and typeof(planets[i]) == TYPE_DICTIONARY else ""

func _n(key: String, tier: int, fallback: float) -> float:
	return float(balance.get(key + "_t" + str(tier), fallback))

func max_tier() -> int:
	return maxi(1, int(balance.get("prosperity_max_tier", 3)))

func is_barren(i: int) -> bool:
	var pid := _pid(i)
	return pid != "" and DeadWorlds.is_dead(planets[i]) and not _reclaimed.has(pid)

## Hook for the later reclaim task: a Barren world becomes a living tier-1 world.
func reclaim(i: int) -> void:
	var pid := _pid(i)
	if pid != "":
		_reclaimed[pid] = true
		_tier[pid] = maxi(1, int(_tier.get(pid, 1)))

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
	var t := tier(i)
	if t < 1:
		return []
	var pid := _pid(i)
	var cap := maxi(0, int(_n("prosperity_needs", t, 2.0)))
	var out: Array = []
	var ov = data.get("overrides", {})
	if typeof(ov) == TYPE_DICTIONARY and ov.has(pid) and typeof(ov[pid]) == TYPE_ARRAY:
		for g in ov[pid]:
			if out.size() < cap and Goods.has(str(g)) and not out.has(str(g)):
				out.append(str(g))
		return out
	var cands: Array = []
	for g in Goods.ids():
		if g != "energy" and (int(Goods.entry(g).get("tier", 1)) > t or not Goods.branch_ok(g)):
			continue
		if _sells_to_player(i, g):
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
	return out

## The world already sells this good to the player (it has a <good>_buy price): its exports never become its needs.
func _sells_to_player(i: int, g: String) -> bool:
	var prices = planets[i].get("base_prices")
	return typeof(prices) == TYPE_DICTIONARY and prices.has(g + "_buy")

func demand(i: int) -> int:
	return maxi(0, roundi(_n("prosperity_demand", tier(i), 0.0)))

func sold(i: int, good: String) -> int:
	return int(_sold.get(_pid(i), {}).get(good, 0))

## Called where sales are noted (route_engine._note_sale) and by the Flagship and hubs for hand sales and deliveries.
func add_fill(i: int, good: String, units: int) -> void:
	var pid := _pid(i)
	if pid == "" or units <= 0 or tier(i) < 1:
		return
	var d: Dictionary = _sold.get(pid, {})
	d[good] = int(d.get(good, 0)) + units
	_sold[pid] = d

## UI API: [{good (or "?"), demand, sold, met, locked}] in need order.
func needs(i: int) -> Array:
	var out: Array = []
	var dem := demand(i)
	for g in _need_goods(i):
		var locked := not Availability.good(g)
		var s := sold(i, g)
		out.append({"good": "?" if locked else g, "demand": dem, "sold": s, "met": (not locked) and s >= dem, "locked": locked})
	return out

func all_met(i: int) -> bool:
	var ns := needs(i)
	if ns.is_empty():
		return false
	for n in ns:
		if not bool(n["met"]):
			return false
	return true

## Progress inside the current tier, 0..1 (1 at the top tier).
func progress(i: int) -> float:
	var t := tier(i)
	if t < 1:
		return 0.0
	if t >= max_tier():
		return 1.0
	return clampf(float(_steps.get(_pid(i), 0)) / float(maxi(1, int(_n("prosperity_steps", t, 3.0)))), 0.0, 1.0)

## True when a need was short at the last cycle end.
func restless(i: int) -> bool:
	return bool(_restless.get(_pid(i), false))

## Cycle end: every need met = a step; any short = minus decay (floor 0); full = tier up. Then the counters reset.
func end_cycle() -> void:
	for i in range(planets.size()):
		var t := tier(i)
		if t < 1:
			continue
		var pid := _pid(i)
		var ok := all_met(i)
		_restless[pid] = not ok
		if t < max_tier():
			if ok:
				_steps[pid] = int(_steps.get(pid, 0)) + 1
				if int(_steps[pid]) >= maxi(1, int(_n("prosperity_steps", t, 3.0))):
					_tier[pid] = t + 1
					_steps[pid] = 0
					_sold.erase(pid)
					tier_up.emit(i, t + 1)
			else:
				_steps[pid] = maxi(0, int(_steps.get(pid, 0)) - maxi(0, int(balance.get("prosperity_decay_steps", 1))))
	_sold = {}

func to_dict() -> Dictionary:
	return {"tier": _tier.duplicate(), "steps": _steps.duplicate(), "sold": _sold.duplicate(true), "restless": _restless.duplicate(), "reclaimed": _reclaimed.duplicate()}

func from_dict(s) -> void:
	_tier = {}
	_steps = {}
	_sold = {}
	_restless = {}
	_reclaimed = {}
	if typeof(s) != TYPE_DICTIONARY:
		return  # old saves: established worlds start at tier 1
	for k in s.get("tier", {}):
		_tier[str(k)] = clampi(int(s["tier"][k]), 1, max_tier())
	for k in s.get("steps", {}):
		_steps[str(k)] = maxi(0, int(s["steps"][k]))
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
