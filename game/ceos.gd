extends RefCounted
## CEOs from data/ceos.json: 3 stats (haggling, thrift, nerve; stat value x a balance step key) and one perk.
## The CEO id is the portrait id. Static state, one run at a time: main.gd calls Ceos.set_current(id) on a new game and on load.
## "" = no CEO (old saves, bots without --ceo): no stat, no perk.
##
## The effects are the same dictionaries Skills reads for skill nodes: Skills._eff() appends Ceos.effects(), so the
## existing queries (sale_price_mult, upkeep_mult, event_cut, warning_cycles, order_size_mult, reveal_cycles) include them.
## Stat effects carry "value" (steps x step key) instead of a "key"; perks carry "cycles" or a "key".
##
## UI API: Ceos.ids(), Ceos.all(), Ceos.has(id), Ceos.card(id) -> {id, name_id, bio_id, perk_name_id, perk_desc_id,
## stats {haggling,thrift,nerve} (1-3 steps), effects {haggling_pct, thrift_pct, nerve_pct} (what the steps are worth), perk_type, perk_pct, perk_cycles}.

const PATH := "res://data/ceos.json"
const STATS := ["haggling", "thrift", "nerve"]
## Effect type of each stat.
const STAT_EFFECT := {"haggling": "sale_price_pct", "thrift": "upkeep_mult", "nerve": "event_cut_pct"}

static var current: String = ""
static var _defs: Dictionary = {}
static var _order: Array = []
static var _steps: Dictionary = {}

static func _load() -> void:
	_defs = {}
	_order = []
	_steps = {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
	if typeof(parsed) == TYPE_DICTIONARY and typeof(parsed.get("ceos")) == TYPE_ARRAY:
		for c in parsed["ceos"]:
			if typeof(c) == TYPE_DICTIONARY and c.has("id"):
				_defs[str(c["id"])] = c
				_order.append(str(c["id"]))
		if typeof(parsed.get("step_keys")) == TYPE_DICTIONARY:
			_steps = parsed["step_keys"]
	if _defs.is_empty():
		push_error("Ceos: %s missing or bad." % PATH)

static func ids() -> Array:
	if _defs.is_empty():
		_load()
	return _order.duplicate()

static func all() -> Array:
	if _defs.is_empty():
		_load()
	var out := []
	for id in _order:
		out.append(_defs[id])
	return out

static func has(id: String) -> bool:
	if _defs.is_empty():
		_load()
	return _defs.has(id)

static func def(id: String) -> Dictionary:
	if _defs.is_empty():
		_load()
	return _defs.get(id, {})

## Branch (market id: mil, lux, min, bio) and ship type id fixed to a CEO. "" for an unknown CEO.
static func branch(id: String) -> String:
	return str(def(id).get("branch", ""))

static func ship(id: String) -> String:
	return str(def(id).get("ship", ""))

static func set_current(id: String) -> void:
	current = id if has(id) else ""

static func _bal() -> Dictionary:
	return Skills._bal()

static func _step(stat: String) -> float:
	if _defs.is_empty():
		_load()
	return float(_bal().get(str(_steps.get(stat, "ceo_step_" + stat)), 0.0))

## Value of the stat of a CEO as a fraction (steps x step key). 0 for no CEO.
static func stat_value(id: String, stat: String) -> float:
	return float(def(id).get("stats", {}).get(stat, 0)) * _step(stat)

## Perk number: balance value of the perk's key (fraction), 0 when it has none.
static func perk_pct(id: String) -> float:
	var p: Dictionary = def(id).get("perk", {})
	return float(_bal().get(str(p.get("key", "")), 0.0)) if p.has("key") else 0.0

static func perk_cycles(id: String) -> int:
	var p: Dictionary = def(id).get("perk", {})
	return int(_bal().get(str(p.get("cycles_key", "")), 0)) if p.has("cycles_key") else 0

## Everything a stat card can show.
static func card(id: String) -> Dictionary:
	var d := def(id)
	if d.is_empty():
		return {}
	var p: Dictionary = d.get("perk", {})
	return {"id": id, "name_id": str(d.get("name_id", "")), "bio_id": str(d.get("bio_id", "")), "perk_name_id": str(d.get("perk_name_id", "")),
		"perk_desc_id": str(d.get("perk_desc_id", "")), "stats": d.get("stats", {}).duplicate(),
		"effects": {"haggling_pct": stat_value(id, "haggling"), "thrift_pct": stat_value(id, "thrift"), "nerve_pct": stat_value(id, "nerve")},
		"perk_type": str(p.get("type", "")), "perk_pct": perk_pct(id), "perk_cycles": perk_cycles(id)}

## Effects of the current CEO in the skill effect format (empty for no CEO). Read by Skills._eff().
static func effects() -> Array:
	var out := []
	if current == "":
		return out
	var d := def(current)
	for stat in STATS:
		var v := stat_value(current, stat)
		if v > 0.0:
			out.append({"type": STAT_EFFECT[stat], "target": "all", "value": v, "source": "ceo_" + stat})
	var p: Dictionary = d.get("perk", {})
	if not p.is_empty():
		var e := {"type": str(p.get("type", "")), "target": str(p.get("target", "all")), "source": "ceo_perk"}
		if p.has("cycles_key"):
			e["cycles"] = perk_cycles(current)
		if p.has("key"):
			e["value"] = perk_pct(current)
		if bool(p.get("only_first_cycle", false)):
			e["only_first_cycle"] = true
		out.append(e)
	return out

## Flagship Boost uses per run this CEO gets (balance value of its boost_charges_key); 0 when it has none (owner 2026-11-13).
static func boost_charges(id: String) -> int:
	var k := str(def(id).get("boost_charges_key", ""))
	return maxi(0, int(_bal().get(k, 0))) if k != "" else 0

## Perk route_capacity_pct aimed at the first lane: the fraction, 0 when the current CEO has no such perk.
static func first_lane_pct() -> float:
	for e in effects():
		if str(e["type"]) == "route_capacity_pct" and str(e["target"]) == "first_lane":
			return float(e["value"])
	return 0.0
