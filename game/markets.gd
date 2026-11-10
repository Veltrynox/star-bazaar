class_name Markets
extends RefCounted
const StoryText := preload("res://game/story_text.gd")
## Goods-to-market registry (data/markets.json): market ids, names, goods, base values, common raws. Empire growth v2 (T281):
## no share, bot volumes, win/sweep checks or spreading overhead. What stays besides the registry: the per-cycle record of the
## player's sales per market (vp_active, read by the first_sale_after_cycle chain trigger), the cycle counter, and house hits
## (hit_bot, bot_mods) that chains and skills still write until the weather tasks take them over.
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
static var tier_off: Dictionary = {}    # "b" -> persistent tier offset (chains)
static var mods: Dictionary = {}        # "b|m" -> {strength_mult, growth_mult, growth_add, tier_offset} from event hits
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

## New run: clears the sales record and house hits.
static func reset(balance: Dictionary, seed_value: int = 0) -> void:
	_ensure()
	bal = balance
	run_seed = seed_value
	vp_active = {}
	cur_active = {}
	tier_off = {}
	mods = {}
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

## Event hit size word to a fraction: "S" / "M" / "L" read balance event_hit_s / _m / _l (0 for anything else).
static func size_pct(size: String) -> float:
	return float(bal.get("event_hit_%s" % size.to_lower(), 0.0)) if ["S", "M", "L"].has(size.to_upper()) else 0.0

## Stored modifiers of bot b in market m (a copy, neutral when never hit), with the list of temporary hits.
static func _raw_mods(b: int, m: String) -> Dictionary:
	var out := {"strength_mult": 1.0, "growth_mult": 1.0, "growth_add": 0.0, "tier_offset": 0, "temps": []}
	var d = mods.get("%d|%s" % [b, m])
	if typeof(d) == TYPE_DICTIONARY:
		for k in out.keys():
			if d.has(k):
				out[k] = d[k].duplicate() if k == "temps" else d[k]
	return out

## Modifiers of bot b in market m (a copy; neutral values when never hit). Temporary hits (hit_bot with until) count
## while cycle <= until; cycle -1 means the cycle now under way. Skill effects that last the whole run are not stored
## here (skill effects no longer touch bots since T282: they act on house weather).
static func bot_mods(b: int, m: String, cycle: int = -1) -> Dictionary:
	var out := _raw_mods(b, m)
	var now := cycles + 1 if cycle < 0 else cycle
	for t in out["temps"]:
		if now <= int(t["until"]):
			var k := "strength_mult" if str(t["stat"]) == "strength" else "growth_mult"
			out[k] = maxf(0.0, float(out[k]) * (1.0 + float(t["amount"])))
	out.erase("temps")
	return out

## Event hit on bot b in market m. stat "strength" or "growth": amount is a signed fraction (-0.15 = -15%), multiplies
## (stacking). stat "tier": amount is an int step (-1), offset clamped to -3..3 (effective tier is clamped to 1..4 in Bots.tier).
## Applies from the next end_cycle on; recorded history is never rewritten. Returns false for a bad bot, market or stat.
## until >= 0 makes a strength or growth hit temporary: it counts through that cycle number, then expires (saved).
static func hit_bot(b: int, m: String, stat: String, amount: float, until: int = -1) -> bool:
	_ensure()
	if not Bots.IDS.has(b) or not ids.has(m):
		return false
	var d := _raw_mods(b, m)
	if until >= 0 and (stat == "strength" or stat == "growth"):
		d["temps"].append({"stat": stat, "amount": amount, "until": until})
		mods["%d|%s" % [b, m]] = d
		return true
	match stat:
		"strength":
			d["strength_mult"] = maxf(0.0, float(d["strength_mult"]) * (1.0 + amount))
		"growth":
			d["growth_mult"] = maxf(0.0, float(d["growth_mult"]) * (1.0 + amount))
		"tier":
			d["tier_offset"] = clampi(int(d["tier_offset"]) + int(roundf(amount)), -3, 3)
		_:
			return false
	mods["%d|%s" % [b, m]] = d
	return true

## Closes the cycle: stores the sales record, ages the temporary house hits.
static func end_cycle(cycle: int) -> void:
	_ensure()
	for m in ids:
		vp_active[m].append(float(cur_active[m]))
		cur_active[m] = 0.0
	for k in mods.keys():  # temporary hits that ran through this cycle are over
		var left := []
		for t in mods[k].get("temps", []):
			if int(t["until"]) > cycle:
				left.append(t)
		mods[k]["temps"] = left
	cycles += 1

## True once the run length is used up (the soft ending fires if nothing else did).
static func timed_out(cycle: int) -> bool:
	return cycle >= int(bal.get("win_cycle_markets", 80))

## Old saves carry share fields (vp, vb, gap, win_streak, sweep_streak, cur): they are ignored on load and not written.
static func to_dict() -> Dictionary:
	return {"seed": run_seed, "vp_active": vp_active, "cur_active": cur_active, "tier_off": tier_off, "mods": mods, "cycles": cycles}

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
	if typeof(d.get("tier_off")) == TYPE_DICTIONARY:
		for k in d["tier_off"].keys():
			tier_off[str(k)] = int(d["tier_off"][k])
	if typeof(d.get("mods")) == TYPE_DICTIONARY:
		for k in d["mods"].keys():
			var src = d["mods"][k]
			if typeof(src) == TYPE_DICTIONARY:
				var temps := []
				for t in src.get("temps", []):
					temps.append({"stat": str(t["stat"]), "amount": float(t["amount"]), "until": int(t["until"])})
				mods[str(k)] = {"strength_mult": float(src.get("strength_mult", 1.0)), "growth_mult": float(src.get("growth_mult", 1.0)),
					"growth_add": float(src.get("growth_add", 0.0)), "tier_offset": int(src.get("tier_offset", 0)), "temps": temps}
	cycles = int(d.get("cycles", 0))
