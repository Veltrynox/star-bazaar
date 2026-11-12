class_name Markets
extends RefCounted
const StoryText := preload("res://game/story_text.gd")
## Goods-to-market registry (data/markets.json): market ids, names, goods, base values, common raws. Empire growth v2 (T281):
## no share, bot volumes, win/sweep checks or spreading overhead. What stays besides the registry: the per-cycle record of the
## player's sales per market (vp_active, read by the first_sale_after_cycle chain trigger) and the cycle counter.
## Static state, one run at a time: call reset() for a new run.

const PATH := "res://data/markets.json"

static var ids: Array = []            # market ids in file order
static var names: Dictionary = {}     # id -> display name
static var goods_of: Dictionary = {}  # id -> Array of good ids
static var _market_of: Dictionary = {}  # good -> id
static var base_value: Dictionary = {}  # good -> int
static var common: Array = []         # common raws: not counted for the active-market rule or cross-load
static var _loaded := false

static var bal: Dictionary = {}
static var run_seed: int = 0
## Player sales per cycle (index = cycle - 1) per market, common raws left out. cur_active: this cycle so far.
static var vp_active: Dictionary = {}
static var cur_active: Dictionary = {}
static var cycles: int = 0              # cycles recorded

## Display name of a market: the skill tab name (SK_TAB_MIL ...), else the name in data/markets.json.
static func name_of(id: String) -> String:
	return StoryText.get_or("SK_TAB_" + id.to_upper(), str(names.get(id, id)))

static func load_data() -> void:
	_loaded = true
	ids = []
	names = {}
	goods_of = {}
	_market_of = {}
	base_value = {}
	common = []
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Markets: %s missing or bad." % PATH)
		return
	for m in parsed.get("markets", []):
		var id := str(m["id"])
		ids.append(id)
		names[id] = str(m.get("name", id))
		goods_of[id] = []
		for g in m.get("goods", []):
			goods_of[id].append(str(g))
			_market_of[str(g)] = id
	for g in parsed.get("base_value", {}).keys():
		base_value[str(g)] = int(parsed["base_value"][g])
	for g in parsed.get("common_raws", []):
		common.append(str(g))

static func _ensure() -> void:
	if not _loaded:
		load_data()

## Seed for a new run: --seed=<int> on the command line (QA, repeatable), else random.
static func default_seed() -> int:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--seed="):
			return int(a.trim_prefix("--seed="))
	return randi()

## New run: clears the sales record.
static func reset(balance: Dictionary, seed_value: int = 0) -> void:
	_ensure()
	bal = balance
	run_seed = seed_value
	vp_active = {}
	cur_active = {}
	cycles = 0
	for m in ids:
		vp_active[m] = []
		cur_active[m] = 0.0

static func market_of(good: String) -> String:
	_ensure()
	return str(_market_of.get(good, ""))

static func is_common(good: String) -> bool:
	_ensure()
	return common.has(good)

static func value_of(good: String) -> int:
	_ensure()
	return int(base_value.get(good, 0))

## Records a sale of `units` of `good` in the current cycle: units x base_value, per market, common raws left out.
## Sell orders and route-delivery sales only. Only the first_sale_after_cycle trigger reads it.
static func add_sale(good: String, units: int, _up_units: int = 0) -> void:
	_ensure()
	var m := market_of(good)
	if m == "" or units <= 0 or not cur_active.has(m) or is_common(good):
		return
	cur_active[m] = float(cur_active[m]) + float(units * value_of(good)) * Chains.volume_mult(m)

## Closes the cycle: stores the sales record.
static func end_cycle(_cycle: int) -> void:
	_ensure()
	for m in ids:
		vp_active[m].append(float(cur_active[m]))
		cur_active[m] = 0.0
	cycles += 1

## True once the run length is used up (the soft ending fires if nothing else did).
static func timed_out(cycle: int) -> bool:
	return cycle >= int(bal.get("win_cycle_markets", 80))

## Old saves carry share fields (vp, vb, gap, win_streak, sweep_streak, cur) and the old house hits (tier_off, mods): they are ignored on load and not written.
static func to_dict() -> Dictionary:
	return {"seed": run_seed, "vp_active": vp_active, "cur_active": cur_active, "cycles": cycles}

static func from_dict(d, balance: Dictionary) -> void:
	reset(balance, 0)
	if typeof(d) != TYPE_DICTIONARY:
		return
	run_seed = int(d.get("seed", 0))
	for m in ids:
		var src = d.get("vp_active", {})
		if typeof(src) == TYPE_DICTIONARY and typeof(src.get(m)) == TYPE_ARRAY:
			vp_active[m] = []
			for v in src[m]:
				vp_active[m].append(float(v))
		if typeof(d.get("cur_active")) == TYPE_DICTIONARY:
			cur_active[m] = float(d["cur_active"].get(m, 0.0))
	cycles = int(d.get("cycles", 0))
