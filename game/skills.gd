class_name Skills
extends RefCounted
## Four market skills at run time: the learned set (skills bought and techs finished), every effect type of the
## vocabulary in data/skills.json, the choose-a-bot skills and the share-point awards. Static state, one run at a time:
## call Skills.reset(balance) for a new run. Every number is a balance.json key named by the node (no number here).
## Pure queries: systems ask Skills.<effect>() where the hook lives (route_engine, markets, events, storage, main).
##
## UI API: Skills.is_learned(id), Skills.learn(id, points, balance), Skills.unlocked(what),
## Skills.bot_skill_ids(), Skills.bot_skill_ready(id), Skills.bot_skill_cooldown(id), Skills.activate_bot_skill(id, bot).

const Ceos := preload("res://game/ceos.gd")

static var bal: Dictionary = {}
static var learned: Array = []        # ids learned or finished, in order; never reassigned (callers keep the reference)
static var bot_used: Dictionary = {}  # bot skill id -> cycle it was last used
static var stock_grown: Dictionary = {}  # "<key>|<good>" -> {carry, grown}, for BIO_2
## T282 house weather: a chosen-house soften (weather_soften_pct, timed) and the next-weather marks set by chain options.
static var house_soft: Dictionary = {}  # house id (as text) -> Array of {amount, until}: timed soften from a skill
static var house_next: Dictionary = {}  # house id (as text) -> {soften: fraction, delay: cycles} for that house's NEXT weather (Events.start_timed uses it up)

const SHARED_KEY := "_shared"

static func reset(balance: Dictionary = {}) -> void:
	if not balance.is_empty():
		bal = balance
	learned.clear()
	bot_used = {}
	stock_grown = {}
	house_soft = {}
	house_next = {}

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
	out.append_array(_ceo_eff(type))
	return out

## Effects of the chosen CEO (stats and perk, game/ceos.gd) of this type, same format as a skill node's.
static func _ceo_eff(type: String) -> Array:
	var out := []
	for e in Ceos.effects():
		if str(e.get("type", "")) == type:
			out.append(e)
	return out

static func _hits(e: Dictionary, target: String) -> bool:
	var t := str(e.get("target", ""))
	return t == target or t == "all"

static func _key(e: Dictionary, field: String = "key") -> float:
	if field == "key" and e.has("value"):  # CEO effects carry the number itself
		return float(e["value"])
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

## need_fill_pct (T261, was volume_pct): extra fraction of units of market m's goods that count toward a world need.
static func need_fill_bonus(m: String) -> float:
	return maxf(0.0, _sum("need_fill_pct", m))

## progress_grace (T261, was share_window): fraction of the Prosperity progress loss of an unmet cycle that is spared (0..1).
static func progress_grace(m: String) -> float:
	return clampf(_sum("progress_grace", m), 0.0, 1.0)

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

## weather_soften_pct permanent (T282, was bot_strength_pct): share by which every house's weather is softer for the player.
static func weather_soften_perm() -> float:
	var f := 1.0
	for e in _eff("weather_soften_pct"):
		if bool(e.get("permanent", false)):
			f *= 1.0 - clampf(_key(e), 0.0, 1.0)
	return 1.0 - f

## Strength multiplier (0..1) of house h's weather right now: the permanent soften and the timed chosen-house softens.
static func weather_soft_factor(h: int) -> float:
	var f := 1.0 - weather_soften_perm()
	for t in house_soft.get(str(h), []):
		if current_cycle() <= int(t["until"]):
			f *= 1.0 - clampf(float(t["amount"]), 0.0, 1.0)
	return f

## weather_warning (T282, was bot_growth_mult): extra cycles of forecast, summed over the learned nodes.
static func weather_warning_extra() -> int:
	var n := 0
	for e in _eff("weather_warning"):
		n += int(_key(e))
	return n

## A chain option that hit a house: its next weather is softer by amount (fraction) and/or starts delay cycles later.
static func mark_house_next(h: int, soften: float, delay: int) -> void:
	var d: Dictionary = house_next.get(str(h), {"soften": 0.0, "delay": 0})
	d["soften"] = minf(1.0, float(d["soften"]) + soften)
	d["delay"] = int(d["delay"]) + delay
	house_next[str(h)] = d

## Takes the mark of house h (zeros when none) and clears it.
static func take_house_next(h: int) -> Dictionary:
	var d: Dictionary = house_next.get(str(h), {"soften": 0.0, "delay": 0})
	house_next.erase(str(h))
	return d

## reveal_prices: cycles of prices shown ahead (0 = none).
## at_home: false when the planet asked about is outside the home system (the CEO perk Quick Read shows prices only at
## home and only in the first cycle).
static func reveal_cycles(at_home: bool = true) -> int:
	var n := 0
	for e in _eff("reveal_prices"):
		if str(e.get("source", "")) == "ceo_perk":
			if (bool(e.get("only_first_cycle", false)) and current_cycle() > 1) or (str(e.get("target", "")) == "home_market" and not at_home):
				continue
		n = maxi(n, int(e.get("cycles", 1)))
	return n + weather_warning_extra()

## event_warning: cycles the next event is announced early (0 = none).
static func warning_cycles() -> int:
	var n := 0
	for e in _eff("event_warning"):
		n = maxi(n, int(e.get("cycles", 1)))
	return n

## Skill that opens mining at every dead world: Prospecting (FND_PROSPECT). "" for a place that is not a dead world.
static func mine_skill_for(place: String) -> String:
	return "FND_PROSPECT" if place.begins_with("dead_") else ""

static func mine_unlocked(place: String) -> bool:
	var id := mine_skill_for(place)
	return id == "" or learned.has(id)

## dead_stock_pct: dead worlds hold this much more stock for the company (MIN_5). Stock already taken is kept.
static func dead_stock_mult() -> float:
	return 1.0 + _sum("dead_stock_pct", "min")

## cluster_yield_pct: mining yield per cluster x this.
static func cluster_yield_mult() -> float:
	return 1.0 + _sum("cluster_yield_pct", "min")

## stock_growth_pct: {rate, cap} for stock of market m held in planet storage ({} when no skill).
## cap = the highest ceiling of the stock_growth_pct effects (BIO_2) and the stock_growth_cap effects (BIO_3 raises it).
static func stock_growth(m: String) -> Dictionary:
	var rate := 0.0
	var cap := 0.0
	for e in _eff("stock_growth_pct"):
		if _hits(e, m):
			rate += _key(e)
			cap = maxf(cap, _key(e, "cap_key"))
	for e in _eff("stock_growth_cap"):
		if _hits(e, m):
			cap = maxf(cap, _key(e, "cap_key"))
	return {} if rate <= 0.0 else {"rate": rate, "cap": cap}

## event_immune: true when a learned node makes market m immune to route events of this kind (MIL_3: "debris").
static func event_immune(m: String, kind: String) -> bool:
	for e in _eff("event_immune"):
		if _hits(e, m) and Array(e.get("kinds", [])).has(kind):
			return true
	return false

## stock_protect: stored stock of market m is not trimmed when an asteroid hit cuts a planet storage (Storage.cut_capacity).
static func stock_protect(m: String) -> bool:
	for e in _eff("stock_protect"):
		if _hits(e, m):
			return true
	return false

## ore_free_slots: ore Buy and Sell orders ignore the order-size cap (RouteEngine.local_amount("ore")).
static func ore_free_slots() -> bool:
	return not _eff("ore_free_slots").is_empty()

## reopen_sooner: cycles a closed planet reopens sooner.
static func reopen_sooner() -> int:
	var n := 0
	for e in _eff("reopen_sooner"):
		n += int(e.get("cycles", 1))
	return n

## ship_price_pct (T208): price of a new ship x this.
static func ship_price_mult() -> float:
	var m := 1.0
	for e in _eff("ship_price_pct"):
		m *= 1.0 - clampf(_key(e), 0.0, 1.0)
	return m

## upgrade_cost_pct (T208): cost of upgrading a lane to level 2 x this.
static func upgrade_cost_mult() -> float:
	var m := 1.0
	for e in _eff("upgrade_cost_pct"):
		m *= 1.0 - clampf(_key(e), 0.0, 1.0)
	return m

## recipe_input_cut (T208): units fewer of this input good per batch (a recipe never drops below 1 unit of it).
static func recipe_input_cut(good: String) -> int:
	var n := 0
	for e in _eff("recipe_input_cut"):
		if str(e.get("good", "")) == good:
			n += int(_key(e))
	return n

## null_core_trip_pct (T208): a Null Core ship's trip cost x this on top of null_core_trip_mult.
static func null_core_trip_mult() -> float:
	var m := 1.0
	for e in _eff("null_core_trip_pct"):
		m *= 1.0 - clampf(_key(e), 0.0, 1.0)
	return m

## bundle_bonus_pct (T208): the mixed-load bonus of goods of market m x this (the bundle_bonus_cap still binds).
static func bundle_bonus_mult(m: String) -> float:
	return 1.0 + maxf(0.0, _sum("bundle_bonus_pct", m))

## cooldown_cut (T208): cycles taken off the cooldown of the chosen-house skills of market m (never below 1 cycle).
static func cooldown_cut(m: String) -> int:
	return roundi(_sum("cooldown_cut", m))

## ---- choose-a-bot skills (MIL_5 Embargo Desk, LUX_7 Guild Seal) ----

static func _bot_effect(id: String) -> Dictionary:
	for e in SkillTree.effects(id):
		if str(e.get("type", "")) == "weather_soften_pct" and str(e.get("pick", "")) == "chosen_bot":
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
	if bot_used.has(id) and bool(e.get("once_per_run", false)):
		return -1
	if not bot_used.has(id):
		return shared_cooldown_left()
	var every := maxi(1, int(_key(e, "cooldown_key")) - cooldown_cut(str(e.get("target", ""))))
	return maxi(shared_cooldown_left(), maxi(0, int(bot_used[id]) + every - current_cycle()))

## Shared lock (BIO_6B): after any chosen-bot hit all chosen-bot skills wait balance[shared_cooldown_key] cycles.
## The longest shared key among learned chosen-bot skills counts; 0 when none carries one.
static func shared_cooldown_every() -> int:
	var n := 0
	for id in learned:
		var e := _bot_effect(str(id))
		if not e.is_empty() and str(e.get("shared_cooldown_key", "")) != "":
			n = maxi(n, int(_num(str(e["shared_cooldown_key"]))))
	return n

## Cycles left of the shared lock (0 = free).
static func shared_cooldown_left() -> int:
	if not bot_used.has(SHARED_KEY):
		return 0
	return maxi(0, int(bot_used[SHARED_KEY]) + shared_cooldown_every() - current_cycle())

static func bot_skill_ready(id: String) -> bool:
	return bot_skill_cooldown(id) == 0

## Uses the skill on house b (1..3, Bots.IDS): that house's weather is softer for the skill's cycles, then returns (T282).
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
	if not Bots.IDS.has(bot):
		return {"ok": false, "reason": "bot"}
	var lst: Array = house_soft.get(str(bot), [])
	lst.append({"amount": _key(e), "until": until})
	house_soft[str(bot)] = lst
	bot_used[id] = cycle
	bot_used[SHARED_KEY] = cycle
	return {"ok": true, "reason": "", "until": until}

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
	return {"bot_used": bot_used, "stock_grown": stock_grown, "house_soft": house_soft, "house_next": house_next}

static func from_dict(d) -> void:
	bot_used = {}
	stock_grown = {}
	house_soft = {}
	house_next = {}
	if typeof(d) != TYPE_DICTIONARY:
		return
	if typeof(d.get("house_soft")) == TYPE_DICTIONARY:  # T282; an older save has none
		for k in d["house_soft"].keys():
			var lst := []
			for t in d["house_soft"][k]:
				lst.append({"amount": float(t.get("amount", 0.0)), "until": int(t.get("until", 0))})
			house_soft[str(k)] = lst
	if typeof(d.get("house_next")) == TYPE_DICTIONARY:
		for k in d["house_next"].keys():
			var hn = d["house_next"][k]
			house_next[str(k)] = {"soften": float(hn.get("soften", 0.0)), "delay": int(hn.get("delay", 0))}
	if typeof(d.get("bot_used")) == TYPE_DICTIONARY:
		for k in d["bot_used"].keys():
			bot_used[str(k)] = int(d["bot_used"][k])
	if typeof(d.get("stock_grown")) == TYPE_DICTIONARY:
		for k in d["stock_grown"].keys():
			var v = d["stock_grown"][k]
			if typeof(v) == TYPE_DICTIONARY:
				stock_grown[str(k)] = {"carry": float(v.get("carry", 0.0)), "grown": int(v.get("grown", 0))}

## boost_charge (T371): production charters granted by learned nodes (MIN_16, BIO_16): one each. Boost adds the event and gig grants.
static func boost_charges() -> int:
	return _eff("boost_charge").size()
