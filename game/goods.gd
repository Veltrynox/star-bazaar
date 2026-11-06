class_name Goods
extends RefCounted
## data/goods.json: the 19 goods, their recipes and workshops, and the prices of the new goods.
## Prices: merge_prices(planet) adds the goods.json planet_prices of that planet to its base_prices
## (a price already in planets.json / systems.json wins). Map and Systems call it for every planet they load.
## Recipes may use common raws (energy, food, ore) and goods of their own market only (checked by recipe_ok).

const PATH := "res://data/goods.json"

static var _loaded := false
static var _goods: Dictionary = {}     # id -> entry
static var _order: Array = []
static var workshops: Array = []       # [{id, market, cost_key, unlocked_by}] file order
static var _gated: Dictionary = {}     # good id -> true when some skill node unlocks it

static func load_data() -> void:
	_loaded = true
	_goods = {}
	_order = []
	workshops = []
	_gated = {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Goods: %s missing or bad." % PATH)
		return
	for g in parsed.get("goods", []):
		_goods[str(g["id"])] = g
		_order.append(str(g["id"]))
	for w in parsed.get("workshops", []):
		workshops.append(w)

static func _ensure() -> void:
	if not _loaded:
		load_data()

static func ids() -> Array:
	_ensure()
	return _order.duplicate()

static func has(id: String) -> bool:
	_ensure()
	return _goods.has(id)

static func entry(id: String) -> Dictionary:
	_ensure()
	return _goods.get(id, {})

## Adds the goods.json prices for this planet's id to its base_prices. Safe to call twice.
static func merge_prices(planet: Dictionary) -> void:
	_ensure()
	var pid := str(planet.get("id", ""))
	for gid in _order:
		var pp = _goods[gid].get("planet_prices", {})
		if typeof(pp) != TYPE_DICTIONARY or not pp.has(pid):
			continue
		if typeof(planet.get("base_prices")) != TYPE_DICTIONARY:
			planet["base_prices"] = {}
		for k in pp[pid].keys():
			if not planet["base_prices"].has(k):
				planet["base_prices"][k] = pp[pid][k]

static func recipe(id: String) -> Dictionary:
	var r = entry(id).get("recipe")
	return r if typeof(r) == TYPE_DICTIONARY else {}

static func batch_out(id: String, balance: Dictionary) -> int:
	return maxi(1, int(balance.get(id + "_batch_out", entry(id).get("batch_out", 1))))

## Crafted goods of one workshop, lowest tier first.
static func recipes_of(workshop: String) -> Array:
	_ensure()
	var out: Array = []
	for id in _order:
		if str(_goods[id].get("workshop", "")) == workshop and not recipe(id).is_empty():
			out.append(id)
	out.sort_custom(func(a, b): return int(_goods[a].get("tier", 0)) < int(_goods[b].get("tier", 0)))
	return out

static func workshop(id: String) -> Dictionary:
	_ensure()
	for w in workshops:
		if str(w["id"]) == id:
			return w
	return {}

## A good is gated when some skill node unlocks it; a gated good can be crafted once Skills.unlocked(id).
static func good_open(id: String) -> bool:
	_ensure()
	if _gated.is_empty():
		for n in SkillTree.all_ids():
			for e in SkillTree.effects(n):
				if str(e.get("type", "")) == "unlock" and str(e.get("target", "")) == "good":
					_gated[str(e.get("id", ""))] = true
	return not _gated.has(id) or Skills.unlocked(id)

## Branch rule (T239): a run's branch trades only its own market's goods; energy (market "") is shared. A run without a
## branch (old save, standalone tools) trades every good. `branch` defaults to the live run's.
static func branch_ok(id: String, branch: String = "<run>") -> bool:
	_ensure()
	var b := Conditions.run_branch() if branch == "<run>" else branch
	var m := str(entry(id).get("market", ""))
	return b == "" or m == "" or m == b

## Recipe input rule: only common raws and goods of the same market.
static func recipe_ok(id: String) -> bool:
	var m := str(entry(id).get("market", ""))
	for c in recipe(id).keys():
		if not Markets.is_common(str(c)) and Markets.market_of(str(c)) != m:
			return false
	return true

## "2 energy + 1 chips -> 3 cells" with display names.
static func recipe_text(id: String, balance: Dictionary) -> String:
	var parts: Array = []
	var r := recipe(id)
	for c in r.keys():
		parts.append("%d %s" % [int(r[c]), Ui.good_name(str(c)).to_lower()])
	return "%s -> %d %s" % [" + ".join(parts), batch_out(id, balance), Ui.good_name(id).to_lower()]
