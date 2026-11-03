class_name Markets
extends RefCounted
## Four Markets: registry (data/markets.json), per-cycle volumes of the player and the three bots, rolling-window
## share, win / swept checks and the spreading overhead. Static state, one run at a time: call reset() for a new run.
## Rules: design/proposals/2026-11-03-four-markets.md sections 2 and 2.2. Every number is a balance.json key.
##
## UI API: Markets.names (id -> display name), Markets.ids, Markets.share(m), Markets.best() -> {market, share},
## Markets.bot_share(b, m), Markets.history(m), Markets.market_of(good), Markets.n_active(), Markets.overhead().

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
## Per cycle (index = cycle - 1): player volume per market, player volume without common raws, bot volumes [b1, b2, b3].
static var vp: Dictionary = {}
static var vp_active: Dictionary = {}
static var vb: Dictionary = {}
static var cur: Dictionary = {}         # this cycle so far: market -> volume
static var cur_active: Dictionary = {}
static var gap: Dictionary = {}         # "b|m" -> accumulated gap growth
static var tier_off: Dictionary = {}    # "b" -> persistent tier offset (events, later goal)
static var mods: Dictionary = {}        # "b|m" -> {strength_mult, growth_mult, growth_add, tier_offset} from event hits
static var win_streak: Dictionary = {}  # market -> consecutive cycle-ends over win_share_pct
static var sweep_streak: int = 0
static var cycles: int = 0              # cycles recorded

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

## New run: clears all volumes and bot state.
static func reset(balance: Dictionary, seed_value: int = 0) -> void:
	_ensure()
	bal = balance
	run_seed = seed_value
	vp = {}
	vp_active = {}
	vb = {}
	cur = {}
	cur_active = {}
	gap = {}
	tier_off = {}
	mods = {}
	win_streak = {}
	sweep_streak = 0
	cycles = 0
	for m in ids:
		vp[m] = []
		vp_active[m] = []
		vb[m] = []
		cur[m] = 0.0
		cur_active[m] = 0.0
		win_streak[m] = 0

static func market_of(good: String) -> String:
	_ensure()
	return str(_market_of.get(good, ""))

static func is_common(good: String) -> bool:
	_ensure()
	return common.has(good)

static func value_of(good: String) -> int:
	_ensure()
	return int(base_value.get(good, 0))

## Counts a sale of `units` of `good` into the current cycle: units x base_value. Sell orders and route-delivery sales only.
## up_units = how many of the units were sold at a planet with a price-up event (LUX_5 counts those extra).
## Volume skills raise share volume only; the sale price skills never reach here (share uses base_value).
static func add_sale(good: String, units: int, up_units: int = 0) -> void:
	_ensure()
	var m := market_of(good)
	if m == "" or units <= 0 or not cur.has(m):
		return
	var v := float(units * value_of(good)) * Skills.volume_mult(m)
	v += float(mini(up_units, units) * value_of(good)) * Skills.volume_bonus_price_up(m)
	cur[m] = float(cur[m]) + v
	if not is_common(good):
		cur_active[m] = float(cur_active[m]) + v

static func window_for(m: String) -> int:
	return Skills.share_window(m, int(bal.get("share_window", 8)))

static func _sum_window(arr: Array, w: int, idx: int = -1) -> float:
	var t := 0.0
	for i in range(maxi(0, arr.size() - w), arr.size()):
		t += float(arr[i]) if idx < 0 else float(arr[i][idx])
	return t

static func player_volume(m: String) -> float:
	return _sum_window(vp.get(m, []), window_for(m))

static func bot_volume(b: int, m: String) -> float:
	return _sum_window(vb.get(m, []), window_for(m), b - 1)

static func total_volume(m: String) -> float:
	var t := player_volume(m)
	for b in Bots.IDS:
		t += bot_volume(b, m)
	return t

## Player share of market m over the window, 0 when there is no volume.
static func share(m: String) -> float:
	var t := total_volume(m)
	return player_volume(m) / t if t > 0.0 else 0.0

## One bot's share of market m over the window.
static func bot_share(b: int, m: String) -> float:
	var t := total_volume(m)
	return bot_volume(b, m) / t if t > 0.0 else 0.0

## Highest player share: {market, share}. market is "" while the player has no volume anywhere. Ties go to file order.
static func best() -> Dictionary:
	_ensure()
	var out := {"market": "", "share": 0.0}
	for m in ids:
		var s := share(m)
		if s > float(out["share"]):
			out = {"market": m, "share": s}
	return out

## Strongest bot over the window across all markets (for the swept ending).
static func leading_bot() -> int:
	var best_b := 1
	var best_v := -1.0
	for b in Bots.IDS:
		var t := 0.0
		for m in ids:
			t += bot_volume(b, m)
		if t > best_v:
			best_v = t
			best_b = b
	return best_b

## Per-cycle player volumes of market m (index = cycle - 1), for the Standings graph.
static func history(m: String) -> Array:
	return vp.get(m, [])

static func bot_history(b: int, m: String) -> Array:
	var out := []
	for row in vb.get(m, []):
		out.append(float(row[b - 1]))
	return out

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
## here (Skills.bot_strength_mult / bot_growth_mult are applied in end_cycle).
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

## Closes the cycle: bot volumes (gap rule first), player volume from add_sale, win and sweep streaks.
static func end_cycle(cycle: int) -> void:
	_ensure()
	for m in ids:
		var prev := share(m)
		var row := []
		for b in Bots.IDS:
			var k := "%d|%s" % [b, m]
			if cycle > 3 and prev < float(bal.get("bot_gap_share_pct", 0.0)):
				gap[k] = float(gap.get(k, 0.0)) + float(bal.get("bot_gap_growth", 0.0))
			var md := bot_mods(b, m, cycle)
			row.append(Bots.volume(bal, run_seed, b, m, cycle, float(gap.get(k, 0.0)), int(tier_off.get(str(b), 0)) + int(md["tier_offset"]),
				float(md["strength_mult"]) * Skills.bot_strength_mult(m), float(md["growth_mult"]) * Skills.bot_growth_mult(m), float(md["growth_add"])))
		vb[m].append(row)
		vp[m].append(float(cur[m]))
		vp_active[m].append(float(cur_active[m]))
		cur[m] = 0.0
		cur_active[m] = 0.0
	for k in mods.keys():  # temporary hits that ran through this cycle are over
		var left := []
		for t in mods[k].get("temps", []):
			if int(t["until"]) > cycle:
				left.append(t)
		mods[k]["temps"] = left
	cycles += 1
	var win_pct := float(bal.get("win_share_pct", 0.5))
	var earliest := int(bal.get("win_earliest_cycle", 0))
	var swept_now := cycle >= int(bal.get("sweep_earliest_cycle", 0))
	for m in ids:
		var s := share(m)
		win_streak[m] = int(win_streak.get(m, 0)) + 1 if (cycle >= earliest and s > win_pct) else 0
		if s >= float(bal.get("sweep_share_pct", 0.1)):
			swept_now = false
	sweep_streak = sweep_streak + 1 if swept_now else 0

## Win or swept after end_cycle(cycle): {kind: "win", market} | {kind: "swept", bot} | {} (bankrupt and the soft ending are main's).
## Win: held win_hold_cycles in a row, or at the final cycle any market over win_share_pct (highest share wins).
static func verdict(cycle: int) -> Dictionary:
	var win_pct := float(bal.get("win_share_pct", 0.5))
	var best_m := ""
	var best_s := -1.0
	var hold := int(bal.get("win_hold_cycles", 5))
	var final := cycle >= int(bal.get("win_cycle_markets", 40))
	for m in ids:
		var s := share(m)
		if (int(win_streak.get(m, 0)) >= hold or (final and s > win_pct)) and s > best_s:
			best_m = m
			best_s = s
	if best_m != "":
		return {"kind": "win", "market": best_m, "share": best_s}
	if sweep_streak >= int(bal.get("sweep_hold_cycles", 3)):
		return {"kind": "swept", "bot": leading_bot()}
	return {}

## True once the run length is used up (the soft END_OUTCOMPETED fires if nothing else did).
static func timed_out(cycle: int) -> bool:
	return cycle >= int(bal.get("win_cycle_markets", 40))

## Markets where the player's share of the player's own window volume (common raws left out) is over market_active_pct.
static func active_markets() -> Array:
	var tot := 0.0
	var per := {}
	for m in ids:
		var v := _sum_window(vp_active.get(m, []), window_for(m))
		per[m] = v
		tot += v
	var out := []
	if tot <= 0.0:
		return out
	for m in ids:
		if float(per[m]) / tot > float(bal.get("market_active_pct", 0.05)):
			out.append(m)
	return out

static func n_active() -> int:
	return active_markets().size()

## Credits paid each cycle for spreading: market_overhead x (n_active - 1)^2.
static func overhead() -> int:
	var n := maxi(n_active() - 1, 0)
	return int(float(bal.get("market_overhead", 0)) * n * n)

static func to_dict() -> Dictionary:
	return {"seed": run_seed, "vp": vp, "vp_active": vp_active, "vb": vb, "cur": cur, "cur_active": cur_active, "gap": gap,
		"tier_off": tier_off, "mods": mods, "win_streak": win_streak, "sweep_streak": sweep_streak, "cycles": cycles}

static func from_dict(d, balance: Dictionary) -> void:
	reset(balance, 0)
	if typeof(d) != TYPE_DICTIONARY:
		return
	run_seed = int(d.get("seed", 0))
	for m in ids:
		for key in ["vp", "vp_active"]:
			var src = d.get(key, {})
			var dst: Dictionary = vp if key == "vp" else vp_active
			if typeof(src) == TYPE_DICTIONARY and typeof(src.get(m)) == TYPE_ARRAY:
				dst[m] = []
				for v in src[m]:
					dst[m].append(float(v))
		if typeof(d.get("vb")) == TYPE_DICTIONARY and typeof(d["vb"].get(m)) == TYPE_ARRAY:
			vb[m] = []
			for row in d["vb"][m]:
				vb[m].append([float(row[0]), float(row[1]), float(row[2])])
		if typeof(d.get("cur")) == TYPE_DICTIONARY:
			cur[m] = float(d["cur"].get(m, 0.0))
		if typeof(d.get("cur_active")) == TYPE_DICTIONARY:
			cur_active[m] = float(d["cur_active"].get(m, 0.0))
		if typeof(d.get("win_streak")) == TYPE_DICTIONARY:
			win_streak[m] = int(d["win_streak"].get(m, 0))
	if typeof(d.get("gap")) == TYPE_DICTIONARY:
		for k in d["gap"].keys():
			gap[str(k)] = float(d["gap"][k])
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
	sweep_streak = int(d.get("sweep_streak", 0))
	cycles = int(d.get("cycles", 0))
