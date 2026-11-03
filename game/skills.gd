class_name Skills
extends RefCounted
## Four market skills at run time: the learned set (skills bought and techs finished), every effect type of the
## vocabulary in data/skills.json, the choose-a-bot skills and the share-point awards. Static state, one run at a time:
## call Skills.reset(balance) for a new run. Every number is a balance.json key named by the node (no number here).
## Pure queries: systems ask Skills.<effect>() where the hook lives (route_engine, markets, events, storage, main).
##
## UI API: Skills.is_learned(id), Skills.learn(id, points, balance), Skills.unlocked(what),
## Skills.bot_skill_ids(), Skills.bot_skill_ready(id), Skills.bot_skill_cooldown(id), Skills.activate_bot_skill(id, bot).

const SHARE_STEPS := [20, 35]  # balance keys skill_points_share_20 / _35, a share of that many percent

static var bal: Dictionary = {}
static var learned: Array = []        # ids learned or finished, in order; never reassigned (callers keep the reference)
static var bot_used: Dictionary = {}  # bot skill id -> cycle it was last used
static var share_paid: Dictionary = {}  # market -> Array of steps (20, 35) already paid
static var stock_grown: Dictionary = {}  # "<key>|<good>" -> {carry, grown}, for BIO_2

static func reset(balance: Dictionary = {}) -> void:
	if not balance.is_empty():
		bal = balance
	learned.clear()
	bot_used = {}
	share_paid = {}
	stock_grown = {}

static func _bal() -> Dictionary:
	if bal.is_empty():
		var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance.json"))
		if typeof(parsed) == TYPE_DICTIONARY and typeof(parsed.get("values")) == TYPE_DICTIONARY:
			bal = parsed["values"]
	return bal

static func _num(key: String, def: float = 0.0) -> float:
	return float(_bal().get(key, def))

## ---- the learned set ----

static func is_learned(id: String) -> bool:
	return learned.has(id)

## Replaces the learned set in place (unknown ids dropped, no duplicates).
static func set_learned(ids: Array) -> void:
	var keep := []
	for id in ids:
		if SkillTree.has(str(id)) and not keep.has(str(id)):
			keep.append(str(id))
	learned.clear()
	learned.append_array(keep)

## Adds an id to the learned set without cost (a finished tech, tests, saves).
static func add_learned(id: String) -> void:
	if SkillTree.has(id) and not learned.has(id):
		learned.append(id)

## Buys a skill: checks prerequisites and points, adds it. Returns {ok, reason, cost}; the caller takes the points.
static func learn(id: String, points: int, balance: Dictionary) -> Dictionary:
	var v := SkillTree.can_learn(learned, points, balance, id)
	if v["ok"]:
		learned.append(id)
		v["cost"] = SkillTree.cost(balance, id)
	return v

static func _eff(type: String) -> Array:
	var out := []
	for id in learned:
		for e in SkillTree.effects(str(id)):
			if str(e.get("type", "")) == type:
				out.append(e)
	return out

static func _hits(e: Dictionary, target: String) -> bool:
	var t := str(e.get("target", ""))
	return t == target or t == "all"

static func _key(e: Dictionary, field: String = "key") -> float:
	return _num(str(e.get(field, "")))

## Sum of the balance values of every learned effect of this type aimed at target (or "all"), skipping conditional ones
## unless want_condition matches.
static func _sum(type: String, target: String, want_condition: String = "") -> float:
	var t := 0.0
	for e in _eff(type):
		if _hits(e, target) and str(e.get("condition", "")) == want_condition:
			t += _key(e)
	return t

## ---- effect types ----

## upkeep_mult: ship upkeep x this.
static func upkeep_mult() -> float:
	var m := 1.0
	for e in _eff("upkeep_mult"):
		m *= 1.0 - _key(e)
	return m

## volume_pct: share volume of market m x this (unconditional effects).
static func volume_mult(m: String) -> float:
	return 1.0 + _sum("volume_pct", m)

## volume_pct with condition sale_at_price_up_planet: extra volume fraction for sales at a planet with a price-up event.
static func volume_bonus_price_up(m: String) -> float:
	return _sum("volume_pct", m, "sale_at_price_up_planet")

## route_capacity_pct: units per cycle of a route carrying a good of market m x this.
static func route_capacity_mult(m: String) -> float:
	return 1.0 + _sum("route_capacity_pct", m)

## sale_price_pct: sale price of goods of market m x this. Cash only: share volume never reads it.
static func sale_price_mult(m: String) -> float:
	return 1.0 + _sum("sale_price_pct", m)

## event_cut_pct: price events against the player in market m are cut by this fraction.
static func event_cut(m: String) -> float:
	return clampf(_sum("event_cut_pct", m), 0.0, 1.0)

## event_bonus_pct: price-up events in market m pay this much more of their pct.
static func event_bonus(m: String) -> float:
	return maxf(0.0, _sum("event_bonus_pct", m))

## storage_cap_pct: planet storage capacity x this.
static func storage_cap_mult() -> float:
	return 1.0 + _sum("storage_cap_pct", "planet_storage")

## order_size_pct: Buy and Sell order amount x this.
static func order_size_mult() -> float:
	return 1.0 + _sum("order_size_pct", "all")

## workshop_batches: extra batches per cycle in market m (flag until the workshops exist).
static func workshop_batches(m: String) -> int:
	return roundi(_sum("workshop_batches", m))

## batch_yield: extra units out of each batch in market m (flag until the workshops exist).
static func batch_yield(m: String) -> int:
	return roundi(_sum("batch_yield", m))

## unlock: true when a learned node unlocks this workshop, good or feature id (smelter, cells, space_storage ...).
static func unlocked(what: String) -> bool:
	for e in _eff("unlock"):
		if str(e.get("id", "")) == what:
			return true
	return false

## bot_strength_pct permanent (all bots): strength multiplier on every bot of market m.
static func bot_strength_mult(m: String) -> float:
	var f := 1.0
	for e in _eff("bot_strength_pct"):
		if bool(e.get("permanent", false)) and _hits(e, m):
			f *= 1.0 - _key(e)
	return f

## bot_growth_mult (all bots, permanent): growth multiplier on every bot of market m.
static func bot_growth_mult(m: String) -> float:
	var f := 1.0
	for e in _eff("bot_growth_mult"):
		if _hits(e, m):
			f *= _key(e)
	return f

## share_window: cycles of the share window of market m, `def` when no skill changes it.
static func share_window(m: String, def: int) -> int:
	var w := def
	for e in _eff("share_window"):
		if _hits(e, m):
			w = maxi(w, int(_key(e)))
	return w

## reveal_prices: cycles of prices shown ahead (0 = none).
static func reveal_cycles() -> int:
	var n := 0
	for e in _eff("reveal_prices"):
		n = maxi(n, int(e.get("cycles", 1)))
	return n

## event_warning: cycles the next event is announced early (0 = none).
static func warning_cycles() -> int:
	var n := 0
	for e in _eff("event_warning"):
		n = maxi(n, int(e.get("cycles", 1)))
	return n

## mine_unlock: id of the skill that lets a player mine at place (planet id), "" when no skill covers it.
static func mine_skill_for(place: String) -> String:
	for id in SkillTree.all_ids():
		for e in SkillTree.effects(id):
			if str(e.get("type", "")) == "mine_unlock" and str(e.get("place", "")) == place:
				return id
	return ""

static func mine_unlocked(place: String) -> bool:
	var id := mine_skill_for(place)
	return id == "" or learned.has(id)

## cluster_yield_pct: mining yield per cluster x this.
static func cluster_yield_mult() -> float:
	return 1.0 + _sum("cluster_yield_pct", "min")

## stock_growth_pct: {rate, cap} for stock of market m held in planet storage ({} when no skill).
static func stock_growth(m: String) -> Dictionary:
	var rate := 0.0
	var cap := 0.0
	for e in _eff("stock_growth_pct"):
		if _hits(e, m):
			rate += _key(e)
			cap += _key(e, "cap_key")
	return {} if rate <= 0.0 else {"rate": rate, "cap": cap}

## stock_protect: stored stock of market m keeps its value when a planet closes (flag; nothing in the game loses it yet).
static func stock_protect(m: String) -> bool:
	for e in _eff("stock_protect"):
		if _hits(e, m):
			return true
	return false

## ore_free_slots: ore loads take no cargo or order space (flag; the game has no shared slots yet).
static func ore_free_slots() -> bool:
	return not _eff("ore_free_slots").is_empty()

## reopen_sooner: cycles a closed planet reopens sooner.
static func reopen_sooner() -> int:
	var n := 0
	for e in _eff("reopen_sooner"):
		n += int(e.get("cycles", 1))
	return n

## ---- choose-a-bot skills (MIL_5 Embargo Desk, LUX_7 Guild Seal) ----

static func _bot_effect(id: String) -> Dictionary:
	for e in SkillTree.effects(id):
		if str(e.get("type", "")) == "bot_strength_pct" and str(e.get("pick", "")) == "chosen_bot":
			return e
	return {}

static func current_cycle() -> int:
	return Markets.cycles + 1

## Learned skills that ask the player to pick a bot.
static func bot_skill_ids() -> Array:
	var out := []
	for id in learned:
		if not _bot_effect(str(id)).is_empty():
			out.append(str(id))
	return out

## Cycles until the skill can be used again: 0 = ready now, -1 = a once-per-run skill already used, -2 = not learned.
static func bot_skill_cooldown(id: String) -> int:
	var e := _bot_effect(id)
	if e.is_empty() or not learned.has(id):
		return -2
	if not bot_used.has(id):
		return 0
	if bool(e.get("once_per_run", false)):
		return -1
	var every := int(_key(e, "cooldown_key"))
	return maxi(0, int(bot_used[id]) + every - current_cycle())

static func bot_skill_ready(id: String) -> bool:
	return bot_skill_cooldown(id) == 0

## Uses the skill on bot b (1..3): that bot's strength in the skill's market drops for the skill's cycles, then returns.
## Returns {ok, reason}: reason is "", "locked", "used" (once per run) or "cooldown", "bot".
static func activate_bot_skill(id: String, bot: int) -> Dictionary:
	var left := bot_skill_cooldown(id)
	if left == -2:
		return {"ok": false, "reason": "locked"}
	if left == -1:
		return {"ok": false, "reason": "used"}
	if left > 0:
		return {"ok": false, "reason": "cooldown", "left": left}
	var e := _bot_effect(id)
	var cycle := current_cycle()
	var until := cycle + maxi(1, int(_key(e, "duration_key"))) - 1
	if not Markets.hit_bot(bot, str(e.get("target", "")), "strength", -_key(e), until):
		return {"ok": false, "reason": "bot"}
	bot_used[id] = cycle
	return {"ok": true, "reason": "", "until": until}

## ---- skill points for share (once per market per step) ----

## Pays each share step (skill_points_share_20 / _35) a market has now reached and not been paid before.
## Returns [{market, step, points}]; the caller adds the points.
static func award_share_points() -> Array:
	var out := []
	for m in Markets.ids:
		var s := Markets.share(m)
		for step in SHARE_STEPS:
			var paid: Array = share_paid.get(m, [])
			if s >= float(step) / 100.0 and not paid.has(step):
				paid.append(step)
				share_paid[m] = paid
				var p := int(_num("skill_points_share_%d" % step))
				if p > 0:
					out.append({"market": m, "step": step, "points": p})
	return out

## ---- planet storage growth (BIO_2) ----

## One cycle of stock growth in planet storage. stock_grown carries the fractions and the units grown so far:
## {"<key>|<good>": {"carry": float, "grown": int}}. Growth is rate of the stored amount a cycle, and the grown total
## never passes cap of the amount held. Returns the units added.
static func grow_stock(storage: RefCounted) -> int:
	var grown := stock_grown
	var total := 0
	for key in storage.stock.keys():
		if not str(key).begins_with("planet:"):
			continue
		for c in storage.commodities:
			var g := stock_growth(Markets.market_of(str(c)))
			var have: int = storage.amount(str(key), str(c))
			var k := "%s|%s" % [key, c]
			if g.is_empty() or have <= 0:
				grown.erase(k)
				continue
			var st: Dictionary = grown.get(k, {"carry": 0.0, "grown": 0})
			st["carry"] = float(st["carry"]) + float(have) * float(g["rate"])
			var room := floori(float(have) * float(g["cap"])) - int(st["grown"])
			var n := mini(floori(float(st["carry"])), maxi(0, room))
			if n > 0:
				n = storage.add(str(key), str(c), n)
				st["carry"] = float(st["carry"]) - n
				st["grown"] = int(st["grown"]) + n
				total += n
			elif room <= 0:
				st["carry"] = 0.0
			grown[k] = st
	return total

## ---- saves ----

static func to_dict() -> Dictionary:
	return {"bot_used": bot_used, "share_paid": share_paid, "stock_grown": stock_grown}

static func from_dict(d) -> void:
	bot_used = {}
	share_paid = {}
	stock_grown = {}
	if typeof(d) != TYPE_DICTIONARY:
		return
	if typeof(d.get("bot_used")) == TYPE_DICTIONARY:
		for k in d["bot_used"].keys():
			bot_used[str(k)] = int(d["bot_used"][k])
	if typeof(d.get("share_paid")) == TYPE_DICTIONARY:
		for k in d["share_paid"].keys():
			var arr := []
			for v in d["share_paid"][k]:
				arr.append(int(v))
			share_paid[str(k)] = arr
	if typeof(d.get("stock_grown")) == TYPE_DICTIONARY:
		for k in d["stock_grown"].keys():
			var v = d["stock_grown"][k]
			if typeof(v) == TYPE_DICTIONARY:
				stock_grown[str(k)] = {"carry": float(v.get("carry", 0.0)), "grown": int(v.get("grown", 0))}
