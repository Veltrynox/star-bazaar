class_name Chains
extends RefCounted
## Market event chains (design/proposals/2026-11-03-four-markets.md section 4, data/chains.json). Static state, one run at a time:
## call reset(balance, seed) for a new run. Every number is a balance.json key named by the data.
##
## Engine API (main.gd and the UI use these):
##   Chains.next_step(cycle) -> step id that fires now ("" when none). Min gap, trigger, previous step and one-step-per-cycle rules.
##   Chains.order(step_id) -> ["opt_a","opt_b"] in this run's (seeded, stable) button order.
##   Chains.apply_option(step_id, opt_id, cycle, busiest_route) -> {cash, tech [[market, units]], rivals [log entries], step, opt}
##   Chains.effect_parts(step_id, opt_id) -> {get [..], cost [..], rivals [..]}  plain phrases (story ids with fallbacks)
##   Chains.effect_line(step_id, opt_id) -> "Get / Cost / Rivals" for the choice popup
##   Chains.prev_option(step_id) -> option id picked in the previous step of the same chain ("" for A1, B1)
##   Chains.ending_flag(market) -> "good" | "bad"  (hidden direction, never shown)
##   Chains.rival_log() -> Array of {cycle, source_id, bot, market, stat, direction, size_word, tier_changed}
##   Chains.win_open(market, cycle) -> false while the win gate holds
##   Chains.volume_mult(m), price_mult(m), upkeep_mult(), trip_cost_mult(route_id), workshop_idle(m), workshop_extra(m): timed effects
## Direction values (dir) are kept here and saved, but no screen reads them.

const StoryText := preload("res://game/story_text.gd")
const PATH := "res://data/chains.json"
const MARKETS := ["mil", "lux", "min", "bio"]

static var steps: Array = []          # step dictionaries, file order
static var step_by_id: Dictionary = {}
static var pool_new: Dictionary = {}  # id -> pool_new entry
static var pool_kept: Dictionary = {} # id -> {market, bot_effect}
static var retired: Array = []
static var _loaded := false

static var bal: Dictionary = {}
static var run_seed: int = 0          # shuffle seed of the button order
static var now: int = 1               # the cycle under way, set by main
static var picks: Dictionary = {}     # step id -> {opt, cycle, nudge}
static var dirv: Dictionary = {}      # market -> int (hidden)
static var timed: Array = []          # {k, m, v, until, route, src}
static var rlog: Array = []           # rival log
static var broken: Dictionary = {}    # market -> bot id whose tier was cut through a chain option
static var marked: Dictionary = {}    # market -> bot id with the biggest cut of the last option (0 = none)
## Hidden (never shown in any text, log, popup, stat or ending): set once when a dark-market choice of the four branch events
## (EV52-EV55) is spotted. `suppressed` holds the removed half of the profitable events: pool event ids and "<step>|<opt>" keys.
static var spotted: bool = false
static var suppressed: Array = []
## T284 moods: every lean-moving choice leaves a mark {id, opt, cycle, w (signed lean weight), world (planet id, "" none)}. Chain options weigh their
## lean nudge (x mood_chain_pct / 100); a branch event (EV52-EV55) weighs mood_branch_dark (dark market) or mood_branch_public. A world's mood is the
## sum of the marks naming it: warm at >= mood_warm_min, cold at <= mood_cold_max, else plain. Reads only; never touches prices, growth or tax.
static var marks: Array = []

static func load_data() -> void:
	_loaded = true
	steps = []
	step_by_id = {}
	pool_new = {}
	pool_kept = {}
	retired = []
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Chains: %s missing or bad." % PATH)
		return
	for s in parsed.get("steps", []):
		steps.append(s)
		step_by_id[str(s["id"])] = s
	for e in parsed.get("pool_new", []):
		pool_new[str(e["id"])] = e
	var pk = parsed.get("pool_kept", {})
	if typeof(pk) == TYPE_DICTIONARY:
		pool_kept = pk
	retired = parsed.get("pool_retired", [])

static func _ensure() -> void:
	if not _loaded:
		load_data()

## New run (or a load that needs a clean slate).
static func reset(balance: Dictionary, seed_value: int = 0) -> void:
	_ensure()
	bal = balance
	run_seed = seed_value
	now = 1
	picks = {}
	dirv = {}
	timed = []
	rlog = []
	broken = {}
	marked = {}
	spotted = false
	suppressed = []
	marks = []
	for m in MARKETS:
		dirv[m] = 0
		marked[m] = 0

static func _num(key: String, def: float = 0.0) -> float:
	return float(bal.get(key, def))

static func step_ids() -> Array:
	_ensure()
	var out := []
	for s in steps:
		out.append(str(s["id"]))
	return out

static func has_step(id: String) -> bool:
	_ensure()
	return step_by_id.has(id)

static func market_of(step_id: String) -> String:
	return str(step_by_id.get(step_id, {}).get("market", ""))

static func chain_of(step_id: String) -> String:
	return "%s_%s" % [market_of(step_id), str(step_by_id.get(step_id, {}).get("chain", ""))]

static func prev_id(step_id: String) -> String:
	var s: Dictionary = step_by_id.get(step_id, {})
	if int(s.get("step", 1)) <= 1:
		return ""
	return "%s_%s%d" % [str(s["market"]).to_upper(), str(s["chain"]), int(s["step"]) - 1]

static func fired(step_id: String) -> bool:
	return picks.has(step_id)

## Option id picked in the previous step of the same chain ("" for the first step of a chain and when it has not fired).
static func prev_option(step_id: String) -> String:
	var p := prev_id(step_id)
	return str(picks[p]["opt"]) if p != "" and picks.has(p) else ""

# ---- triggers ----

static func _last_fired_cycle(market: String) -> int:
	var last := -9999
	for id in picks.keys():
		if market_of(str(id)) == market:
			last = maxi(last, int(picks[id]["cycle"]))
	return last

## Trigger and visible_when of the step, both condition trees of game/conditions.gd (atoms that read the step: share_pct (legacy),
## first_sale_after_cycle, cycles_after_prev_step). A step without visible_when is always visible.
static func trigger_ok(step_id: String, cycle: int) -> bool:
	_ensure()
	var ctx := cond_ctx(step_id, cycle)
	var st: Dictionary = step_by_id.get(step_id, {})
	return Conditions.eval(st.get("trigger", {}), ctx) and Conditions.visible(st, ctx)

static func cond_ctx(step_id: String, cycle: int) -> Dictionary:
	return {"step": step_id, "cycle": cycle, "balance": bal}

## The options of a step that may be offered (their optional visible_when holds), in this run's button order.
static func visible_options(step_id: String) -> Array:
	_ensure()
	var out: Array = []
	var ctx := cond_ctx(step_id, now)
	for o in order(step_id):
		if Conditions.visible(step_by_id.get(step_id, {}).get(str(o), {}), ctx) and not suppressed.has("%s|%s" % [step_id, o]):
			out.append(o)
	return out

## True when the pool event id is among the removed profitable events (never drawn again).
static func is_suppressed(id: String) -> bool:
	return suppressed.has(id)

## Picks the removed share of the profitable events ONCE (a second call removes nothing more), seeded by the run seed.
## `pool_ids` = the profitable pool events not fired yet (the caller knows the effects); chain candidates are the options that
## give a gain (a non-empty gets list) of steps not fired yet. A step always keeps one option. Saved in to_dict.
static func suppress_profitable(pool_ids: Array, share: float) -> void:
	_ensure()
	if spotted:
		return
	spotted = true
	var cand: Array = pool_ids.duplicate()
	for s in steps:
		if fired(str(s["id"])):
			continue
		for o in ["opt_a", "opt_b"]:
			if not (s.get(o, {}).get("gets", []) as Array).is_empty():
				cand.append("%s|%s" % [s["id"], o])
	cand.sort()
	var r := RandomNumberGenerator.new()
	r.seed = hash([run_seed, "branch_spotted"])
	for i in range(cand.size() - 1, 0, -1):  # seeded Fisher-Yates
		var j := r.randi_range(0, i)
		var t = cand[i]
		cand[i] = cand[j]
		cand[j] = t
	var n := int(round(cand.size() * clampf(share, 0.0, 1.0)))
	suppressed = []
	for k in n:
		var key := str(cand[k])
		var bar := key.find("|")
		if bar >= 0:
			var other := "%s|%s" % [key.substr(0, bar), "opt_b" if key.ends_with("opt_a") else "opt_a"]
			if suppressed.has(other):
				continue  # keep one option of the step
		suppressed.append(key)

## True when the step may fire this cycle: not fired, previous step fired (when required), min gap since the last step of the
## market, trigger true. Cycle 1 never fires (the tutorial runs first), and no step fires before balance chain_min_cycle.
static func eligible(step_id: String, cycle: int) -> bool:
	_ensure()
	if not step_by_id.has(step_id) or fired(step_id) or cycle <= 1 or cycle < int(_num("chain_min_cycle", 6.0)):
		return false
	var s: Dictionary = step_by_id[step_id]
	var rb := Conditions.run_branch()
	if rb != "" and str(s.get("market", "")) != rb:  # T239: a chain of another branch's market never fires
		return false
	if bool(s.get("requires_prev_step", false)) and not fired(prev_id(step_id)):
		return false
	if cycle - _last_fired_cycle(str(s["market"])) < int(_num(str(s.get("min_gap_key", "chain_min_gap")), 3.0)):
		return false
	return trigger_ok(step_id, cycle)

## The one chain step that fires at the start of this cycle, "" when none. A step takes the event slot before a pool event;
## when several markets are ready the first in data order goes and the others wait.
static func next_step(cycle: int) -> String:
	_ensure()
	for s in steps:
		if eligible(str(s["id"]), cycle):
			return str(s["id"])
	return ""

## A market's win is not declared before its B4 fired, or cycle win_gate_cycle.
static func win_open(market: String, cycle: int) -> bool:
	_ensure()
	return fired("%s_B4" % market.to_upper()) or cycle >= int(_num("win_gate_cycle", 38.0))

# ---- option order and direction ----

## Button order of a step in this run: seeded, same after a load, no meaning attached to the position.
static func order(step_id: String) -> Array:
	return ["opt_a", "opt_b"] if hash([run_seed, step_id]) % 2 == 0 else ["opt_b", "opt_a"]

static func dir_of(market: String) -> int:
	return int(dirv.get(market, 0))

## Nudge arithmetic. base signed; prev_sign sign of the previous step's nudge in the same chain (0 none); late = B3 or B4.
## Order: echo (x dir_echo_mult, floor of the size), late swing (x dir_swing_mult, floor), cap dir_nudge_cap.
static func compute_nudge(base: int, prev_sign: int, late: bool, dir_before: int) -> int:
	var sg := signi(base)
	if sg == 0:
		return 0
	var mag := absi(base)
	if prev_sign == sg:
		mag = floori(float(mag) * _num("dir_echo_mult", 1.0))
	if late and absi(dir_before) >= int(_num("dir_swing_min_abs", 25.0)) and signi(dir_before) == -sg:
		mag = floori(float(mag) * _num("dir_swing_mult", 1.0))
	mag = mini(mag, int(_num("dir_nudge_cap", 14.0)))
	return sg * mag

static func nudge_of(step_id: String, opt_id: String) -> int:
	var s: Dictionary = step_by_id.get(step_id, {})
	if s.is_empty() or not s.has(opt_id):
		return 0
	var p := prev_id(step_id)
	var prev_sign := signi(int(picks[p]["nudge"])) if p != "" and picks.has(p) else 0
	return compute_nudge(int(s[opt_id].get("dir", 0)), prev_sign, int(s["step"]) >= 3 and str(s["chain"]) == "B", dir_of(str(s["market"])))

## Hidden: true when the market's direction reads good (>= dir_good_min). No step fired = 0 = good.
static func ending_flag(market: String) -> String:
	return "good" if dir_of(market.to_lower()) >= int(_num("dir_good_min", 0.0)) else "bad"

static func rival_broken(market: String) -> bool:
	return broken.has(market.to_lower())

static func rival_broken_bot(market: String) -> int:
	return int(broken.get(market.to_lower(), 0))

## R7: the bot with the biggest cut from the last option chosen in the market (0 when no cut).
static func marked_bot(market: String) -> int:
	return int(marked.get(market, 0))

# ---- bot effects ----

static func bot_id(e: Dictionary) -> int:
	return int(str(e.get("bot", "bot_0")).trim_prefix("bot_"))

## Tier of bot b in market m at cycle now with every offset applied (1..4).
static func effective_tier(b: int, m: String, cycle: int) -> int:
	var md := Markets.bot_mods(b, m, cycle)
	return Bots.tier(bal, b, cycle, int(Markets.tier_off.get(str(b), 0)) + int(md["tier_offset"]))

static func _size_of(e: Dictionary) -> String:
	return str(e.get("size", "")) if e.get("size") != null else ""

## Applies one bot effect entry and logs it. Returns the log entry. Tier -1 on a bot at its lowest tier becomes strength down
## M with size_word "lowest" (R8); tier_changed is true only when a tier really dropped.
static func apply_bot(src: String, e: Dictionary, cycle: int) -> Dictionary:
	var b := bot_id(e)
	var m := str(e.get("market", ""))
	var stat := str(e.get("stat", ""))
	var dir := str(e.get("direction", "down"))
	var entry := {"cycle": cycle, "source_id": src, "bot": b, "market": m, "stat": stat, "direction": dir, "size_word": _size_of(e), "tier_changed": false}
	# T282: rivals are gone; a hit on house b now delays (growth cut) or softens (strength or tier cut) that house's NEXT weather.
	# A boost to a rival does nothing. The log keeps its old shape. Numbers: balance weather_next_soften_pct, weather_next_delay_cycles (placeholders).
	if stat == "tier":
		if effective_tier(b, m, cycle) > 1:
			entry["size_word"] = "tier"
			entry["tier_changed"] = true
		else:
			entry["size_word"] = "lowest"
	if dir == "down":
		if stat == "growth":
			Skills.mark_house_next(b, 0.0, int(_num("weather_next_delay_cycles")))
		else:
			Skills.mark_house_next(b, _num("weather_next_soften_pct"), 0)
	rlog.append(entry)
	return entry

## Weight of a cut for the marked-bot rule: S 1, M 2, L 3, a tier cut counts as medium. Boosts count 0.
static func _cut_weight(entry: Dictionary) -> int:
	if str(entry["direction"]) != "down":
		return 0
	match str(entry["size_word"]):
		"S":
			return 1
		"M", "tier", "lowest":
			return 2
		"L":
			return 3
	return 0

## Pool event bot effects (optional, small). Same logging; returns the entries.
static func apply_pool(id: String, cycle: int) -> Array:
	_ensure()
	var out := []
	for e in pool_bot_effects(id):
		out.append(apply_bot(id, e, cycle))
	return out

static func pool_bot_effects(id: String) -> Array:
	_ensure()
	if pool_new.has(id):
		return pool_new[id].get("bot_effect", [])
	if pool_kept.has(id):
		return pool_kept[id].get("bot_effect", [])
	return []

static func in_pool(id: String) -> bool:
	_ensure()
	return pool_new.has(id) or pool_kept.has(id)

static func rival_log() -> Array:
	return rlog.duplicate(true)

# ---- player effects ----

## Busiest route: Callable(market: String) -> route id (-1 none). Returns the result dictionary; main applies cash and tech.
static func apply_option(step_id: String, opt_id: String, cycle: int, busiest_route: Callable = Callable(), world: String = "") -> Dictionary:
	_ensure()
	var res := {"step": step_id, "opt": opt_id, "cash": 0, "tech": [], "rivals": []}
	var s: Dictionary = step_by_id.get(step_id, {})
	if s.is_empty() or not s.has(opt_id) or fired(step_id):
		return res
	var m := str(s["market"])
	var o: Dictionary = s[opt_id]
	var nudge := nudge_of(step_id, opt_id)
	picks[step_id] = {"opt": opt_id, "cycle": cycle, "nudge": nudge}
	marks.append({"id": step_id, "opt": opt_id, "cycle": cycle, "w": int(round(float(nudge) * _num("mood_chain_pct", 0.0) / 100.0)), "world": world})
	dirv[m] = clampi(dir_of(m) + nudge, int(_num("dir_min", -100.0)), int(_num("dir_max", 100.0)))
	for lst in ["gets", "costs"]:
		for e in o.get(lst, []):
			_player_effect(step_id, m, e, cycle, res, busiest_route)
	var best_w := 0
	var best_b := 0
	for e in o.get("bot", []):
		var entry := apply_bot(step_id, e, cycle)
		res["rivals"].append(entry)
		var w := _cut_weight(entry)
		if w > best_w or (w == best_w and w > 0 and int(entry["bot"]) < best_b):
			best_w = w
			best_b = int(entry["bot"])
		if bool(entry["tier_changed"]):
			broken[m] = int(entry["bot"])
	marked[m] = best_b
	return res

## T284: a branch event choice (EV52-EV55): dark market weighs mood_branch_dark (negative), public mood_branch_public, on the named world.
static func note_branch(event_id: String, dark: bool, cycle: int, world: String) -> void:
	_ensure()
	marks.append({"id": event_id, "opt": "dark" if dark else "public", "cycle": cycle, "w": int(_num("mood_branch_dark" if dark else "mood_branch_public", 0.0)), "world": world})

## 'warm' | 'plain' | 'cold' for a planet id. No thresholds in balance = plain.
static func mood_of(world: String) -> String:
	if world == "" or not bal.has("mood_warm_min") or not bal.has("mood_cold_max"):
		return "plain"
	var sum := 0
	for mk in marks:
		if str(mk["world"]) == world:
			sum += int(mk["w"])
	if sum >= int(_num("mood_warm_min")):
		return "warm"
	if sum <= int(_num("mood_cold_max")):
		return "cold"
	return "plain"

## The (up to) three marks that moved the lean most, biggest |w| first, earlier first on a tie: [{id, opt, cycle, w, world}]. For the end recap.
static func decisive_moments() -> Array:
	var all: Array = []
	for mk in marks:
		if int(mk["w"]) != 0:
			all.append(mk.duplicate())
	all.sort_custom(func(a, b):
		if absi(int(a["w"])) != absi(int(b["w"])):
			return absi(int(a["w"])) > absi(int(b["w"]))
		if int(a["cycle"]) != int(b["cycle"]):
			return int(a["cycle"]) < int(b["cycle"])
		return str(a["id"]) < str(b["id"]))
	return all.slice(0, 3)

static func _player_effect(step_id: String, m: String, e: Dictionary, cycle: int, res: Dictionary, busiest_route: Callable) -> void:
	var t := str(e.get("type", ""))
	var v := _num(str(e.get("key", "")))
	var until := cycle + int(_num(str(e.get("cycles_key", "")), 1.0)) - 1
	match t:
		"cash":
			res["cash"] = int(res["cash"]) + int(v)
		"tech_units":
			res["tech"].append([m, int(v)])
		"volume_pct", "price_pct":
			timed.append({"k": t, "m": m, "v": v, "until": until, "route": -1, "src": step_id})
		"upkeep_pct":
			timed.append({"k": t, "m": "", "v": v, "until": until, "route": -1, "src": step_id})
		"trip_cost_pct":
			var r := int(busiest_route.call(m)) if busiest_route.is_valid() else -1
			if r >= 0:
				timed.append({"k": t, "m": m, "v": v, "until": until, "route": r, "src": step_id})
		"workshop_idle":
			timed.append({"k": t, "m": m, "v": 1.0, "until": until, "route": -1, "src": step_id})
		"workshop_batches":
			timed.append({"k": t, "m": m, "v": v, "until": until, "route": -1, "src": step_id})

static func _live(k: String, m: String = "") -> Array:
	var out := []
	for t in timed:
		if str(t["k"]) == k and now <= int(t["until"]) and (m == "" or str(t["m"]) == m):
			out.append(t)
	return out

## Drops expired timed effects (queries already ignore them).
static func tick(cycle: int) -> void:
	now = cycle
	var keep := []
	for t in timed:
		if cycle <= int(t["until"]):
			keep.append(t)
	timed = keep

static func volume_mult(m: String) -> float:
	var f := 1.0
	for t in _live("volume_pct", m):
		f *= maxf(0.0, 1.0 + float(t["v"]))
	return f

static func price_mult(m: String) -> float:
	var f := 1.0
	for t in _live("price_pct", m):
		f *= maxf(0.0, 1.0 + float(t["v"]))
	return f

static func upkeep_mult() -> float:
	var f := 1.0
	for t in _live("upkeep_pct"):
		f *= maxf(0.0, 1.0 + float(t["v"]))
	return f

static func trip_cost_mult(route_id: int) -> float:
	var f := 1.0
	for t in _live("trip_cost_pct"):
		if int(t["route"]) == route_id:
			f *= maxf(0.0, 1.0 + float(t["v"]))
	return f

static func workshop_idle(m: String) -> bool:
	return not _live("workshop_idle", m).is_empty()

static func workshop_extra(m: String) -> int:
	var n := 0
	for t in _live("workshop_batches", m):
		n += roundi(float(t["v"]))
	return n

# ---- effect line (Get / Cost / Rivals) ----

static func _cycles_text(n: int) -> String:
	if n >= 99:
		return StoryText.get_or("CH_FX_REST", "for the rest of the run")
	return StoryText.get_or("CH_FX_CYCLES", "for {n} cycles", {"n": n})

static func _pct(v: float) -> String:
	return "%+d%%" % roundi(v * 100.0)

## One player effect as a plain phrase.
static func phrase(e: Dictionary) -> String:
	var t := str(e.get("type", ""))
	var v := _num(str(e.get("key", "")))
	var n := int(_num(str(e.get("cycles_key", "")), 0.0))
	match t:
		"cash":
			return StoryText.get_or("CH_FX_CASH_IN" if v >= 0 else "CH_FX_CASH_OUT", "{sign}{n} credits", {"sign": "+" if v >= 0 else "-", "n": absi(int(v)), "cash_in": absi(int(v)), "cash_out": absi(int(v))})
		"volume_pct":
			return "%s %s %s" % [StoryText.get_or("CH_FX_VOLUME", "Volume"), _pct(v), _cycles_text(n)]
		"price_pct":
			return "%s %s %s" % [StoryText.get_or("CH_FX_PRICE", "Sell prices"), _pct(v), _cycles_text(n)]
		"upkeep_pct":
			return "%s %s %s" % [StoryText.get_or("CH_FX_UPKEEP", "Ship upkeep"), _pct(v), _cycles_text(n)]
		"trip_cost_pct":
			return "%s %s %s" % [StoryText.get_or("CH_FX_TRIP", "One route's trip cost"), _pct(v), _cycles_text(n)]
		"tech_units":
			return StoryText.get_or("CH_FX_TECH", "+{n} tech progress", {"n": int(v)})
		"workshop_idle":
			return "%s %s" % [StoryText.get_or("CH_FX_IDLE", "Workshop idle"), _cycles_text(n)]
		"workshop_batches":
			return "%s %s" % [StoryText.get_or("CH_FX_BATCHES", "+{n} batch per cycle", {"n": int(v)}), _cycles_text(n)]
	return ""

static func size_word(size: String) -> String:
	match size:
		"S":
			return StoryText.get_or("CH_SIZE_S", "a little")
		"M":
			return StoryText.get_or("CH_SIZE_M", "clearly")
		"L":
			return StoryText.get_or("CH_SIZE_L", "sharply")
	return ""

## Plain line for one logged or planned bot change, from the Competitors log labels (LBL_COMP_MOVE_*): "Harrow Combine: Military strength down".
## A tier cut that landed on a bot at its lowest tier reads as strength down (size_word "lowest"). Size words are not in these labels.
static func rival_phrase(entry: Dictionary) -> String:
	var up := str(entry["direction"]) == "up"
	var sw := str(entry["size_word"])
	var id := "LBL_COMP_MOVE_TIER_DOWN"
	if sw != "tier":
		var st := "STR" if (str(entry["stat"]) == "strength" or sw == "lowest" or str(entry["stat"]) == "tier") else "GRO"
		id = "LBL_COMP_MOVE_%s_%s" % [st, "UP" if up else "DOWN"]
	var m := str(entry.get("market", ""))
	return StoryText.get_or(id, "{bot}: {market}", {"bot": Bots.bot_name(int(entry["bot"])), "market": str(Markets.names.get(m, m))})

## Planned bot changes of an option as log-shaped entries (the lowest-tier case resolved against the bots as they are now).
static func planned_rivals(step_id: String, opt_id: String, cycle: int = -1) -> Array:
	var out := []
	var c := now if cycle < 0 else cycle
	for e in step_by_id.get(step_id, {}).get(opt_id, {}).get("bot", []):
		var entry := {"bot": bot_id(e), "market": str(e.get("market", "")), "stat": str(e.get("stat", "")), "direction": str(e.get("direction", "down")), "size_word": _size_of(e)}
		if entry["stat"] == "tier":
			entry["size_word"] = "tier" if effective_tier(int(entry["bot"]), str(entry["market"]), c) > 1 else "lowest"
		out.append(entry)
	return out

static func effect_parts(step_id: String, opt_id: String) -> Dictionary:
	_ensure()
	var o: Dictionary = step_by_id.get(step_id, {}).get(opt_id, {})
	var g := []
	var c := []
	for e in o.get("gets", []):
		g.append(phrase(e))
	for e in o.get("costs", []):
		c.append(phrase(e))
	var r := []
	for entry in planned_rivals(step_id, opt_id):
		r.append(rival_phrase(entry))
	return {"get": g, "cost": c, "rivals": r}

## Effect line of an option (written line when the story has one, else the template). Alias of eff_text.
static func effect_line(step_id: String, opt_id: String) -> String:
	return eff_text(step_id, opt_id)

## What the rivals did, for the result popup: entries of a result or the log, one phrase each.
static func rivals_text(entries: Array) -> String:
	var out := []
	for e in entries:
		out.append(rival_phrase(e))
	return "; ".join(out)

# ---- chain text (ids from story/screens.md "Market chains": EV_<step>_<field>) ----

static func _opx(opt_id: String) -> String:
	return "OPA" if opt_id == "opt_a" else "OPB"

static func _bot_names() -> Dictionary:
	return {"bot1": Bots.bot_name(1), "bot2": Bots.bot_name(2), "bot3": Bots.bot_name(3)}

## Bot that would be marked by the option (planned, before it is applied); 0 when it cuts nobody.
static func planned_marked(step_id: String, opt_id: String) -> int:
	var best_w := 0
	var best_b := 0
	for entry in planned_rivals(step_id, opt_id):
		var w := _cut_weight(entry)
		if w > best_w or (w == best_w and w > 0 and int(entry["bot"]) < best_b):
			best_w = w
			best_b = int(entry["bot"])
	return best_b

## Placeholders of a chain text: {bot1..3}, {bot} (marked bot), {market}, {cash_in}, {cash_out}, {n}, {cut}, {cut_std}, {get}, {cost}, {rivals}.
## With an option id the numbers come from that option. applied = the option was chosen: {bot} reads the stored mark.
static func args_for(step_id: String, opt_id: String = "", applied: bool = false) -> Dictionary:
	_ensure()
	var m := market_of(step_id)
	var args := _bot_names()
	args["market"] = str(Markets.names.get(m, m))
	var mb := marked_bot(m)
	if opt_id != "" and not applied:
		mb = planned_marked(step_id, opt_id)
	args["bot"] = Bots.bot_name(mb) if mb > 0 else ""
	if opt_id != "":
		var cin := 0
		var cout := 0
		var n := 0
		for e in step_by_id.get(step_id, {}).get(opt_id, {}).get("gets", []) + step_by_id.get(step_id, {}).get(opt_id, {}).get("costs", []):
			var v := int(_num(str(e.get("key", ""))))
			match str(e.get("type", "")):
				"cash":
					if v >= 0:
						cin += v
					else:
						cout += -v
				"tech_units":
					n += v
		args["cash_in"] = cin
		args["cash_out"] = cout
		args["n"] = n
		var cut := StoryText.get_or("CH_CUT", "drops a tier")
		var cut_std := StoryText.get_or("CH_CUT_STD", "moved down a tier")
		for entry in planned_rivals(step_id, opt_id):
			if str(entry["stat"]) == "tier" and str(entry["size_word"]) == "lowest":
				cut = StoryText.get_or("CH_CUT_LOW", "loses strength clearly")
				cut_std = StoryText.get_or("CH_CUT_STD_LOW", "strength down clearly")
		args["cut"] = cut
		args["cut_std"] = cut_std
		var p := effect_parts(step_id, opt_id)
		args["get"] = ", ".join(p["get"])
		args["cost"] = ", ".join(p["cost"])
		args["rivals"] = ", ".join(p["rivals"])
	return args

static func title(step_id: String) -> String:
	return StoryText.get_or("EV_%s_TITLE" % step_id, step_id, args_for(step_id))

## One body for A1 and B1, else the variant keyed to the option picked in the previous step of the same chain.
static func body(step_id: String) -> String:
	var args := args_for(step_id)
	if StoryText.has_text("EV_%s_BODY" % step_id):
		return StoryText.get_text("EV_%s_BODY" % step_id, args)
	var suffix := "_A" if prev_option(step_id) != "opt_b" else "_B"
	return StoryText.get_or("EV_%s_BODY%s" % [step_id, suffix], "", args)

## Text id of the body shown by body(), for the voice line.
static func body_id(step_id: String) -> String:
	if StoryText.has_text("EV_%s_BODY" % step_id):
		return "EV_%s_BODY" % step_id
	return "EV_%s_BODY%s" % [step_id, "_A" if prev_option(step_id) != "opt_b" else "_B"]

static func result_id(step_id: String, opt_id: String) -> String:
	return "EV_%s_%s_RES" % [step_id, _opx(opt_id)]

static func button(step_id: String, opt_id: String) -> String:
	return StoryText.get_or("EV_%s_%s_BTN" % [step_id, _opx(opt_id)], opt_id, args_for(step_id, opt_id))

## The effect line of the choice: the written EV_<step>_OP?_EFF line, else the template line the game builds.
static func eff_text(step_id: String, opt_id: String) -> String:
	var id := "EV_%s_%s_EFF" % [step_id, _opx(opt_id)]
	if StoryText.has_text(id):
		return StoryText.get_text(id, args_for(step_id, opt_id))
	var p := effect_parts(step_id, opt_id)
	return StoryText.get_or("CH_EFFECT_LINE", "Get: {get}. Cost: {cost}. Rivals: {rivals}.", {"get": ", ".join(p["get"]), "cost": ", ".join(p["cost"]), "rivals": ", ".join(p["rivals"])})

static func result_title(step_id: String, opt_id: String) -> String:
	return StoryText.get_or("EV_%s_%s_RES_TITLE" % [step_id, _opx(opt_id)], title(step_id), args_for(step_id, opt_id, true))

## Result popup text: the written result, then what the rivals did (the _STD lines, else generated phrases).
static func result_text(step_id: String, opt_id: String, rivals: Array) -> String:
	var args := args_for(step_id, opt_id, true)
	var out := StoryText.get_or("EV_%s_%s_RES" % [step_id, _opx(opt_id)], "", args)
	var lines := []
	for suffix in ["STD", "STD2"]:
		var id := "EV_%s_%s_%s" % [step_id, _opx(opt_id), suffix]
		if StoryText.has_text(id):
			lines.append(StoryText.get_text(id, args))
	if lines.is_empty() and not rivals.is_empty():
		lines.append(rivals_text(rivals))
	return (out + "\n\n" + "\n".join(lines)).strip_edges()

## Rivals line of a shared pool event for its popup: what its bot effect does, "" for an event without one.
## Planned entries, so a tier cut at the lowest tier reads as strength down.
static func pool_rivals_line(id: String) -> String:
	var effs := pool_bot_effects(id)
	if effs.is_empty():
		return ""
	var entries := []
	for e in effs:
		entries.append({"bot": bot_id(e), "market": str(e.get("market", "")), "stat": str(e.get("stat", "")), "direction": str(e.get("direction", "down")), "size_word": _size_of(e)})
	return "%s %s" % [StoryText.get_or("CH_RIVALS_LABEL", "Rivals:"), rivals_text(entries)]

# ---- save ----

static func to_dict() -> Dictionary:
	return {"seed": run_seed, "picks": picks.duplicate(true), "dir": dirv.duplicate(), "timed": timed.duplicate(true), "log": rlog.duplicate(true),
		"broken": broken.duplicate(), "marked": marked.duplicate(), "spotted": spotted, "suppressed": suppressed.duplicate(), "marks": marks.duplicate(true)}

## Missing or old data = a fresh chain state (v3 saves).
static func from_dict(d, balance: Dictionary = {}) -> void:
	reset(balance if not balance.is_empty() else bal, Markets.run_seed)
	if typeof(d) != TYPE_DICTIONARY:
		return
	run_seed = int(d.get("seed", Markets.run_seed))
	if typeof(d.get("picks")) == TYPE_DICTIONARY:
		for k in d["picks"].keys():
			var p = d["picks"][k]
			if step_by_id.has(str(k)) and typeof(p) == TYPE_DICTIONARY:
				picks[str(k)] = {"opt": str(p.get("opt", "opt_a")), "cycle": int(p.get("cycle", 0)), "nudge": int(p.get("nudge", 0))}
	if typeof(d.get("dir")) == TYPE_DICTIONARY:
		for m in MARKETS:
			dirv[m] = int(d["dir"].get(m, 0))
	if typeof(d.get("timed")) == TYPE_ARRAY:
		for t in d["timed"]:
			if typeof(t) == TYPE_DICTIONARY:
				timed.append({"k": str(t.get("k", "")), "m": str(t.get("m", "")), "v": float(t.get("v", 0.0)), "until": int(t.get("until", 0)),
					"route": int(t.get("route", -1)), "src": str(t.get("src", ""))})
	if typeof(d.get("log")) == TYPE_ARRAY:
		for e in d["log"]:
			if typeof(e) == TYPE_DICTIONARY:
				rlog.append({"cycle": int(e.get("cycle", 0)), "source_id": str(e.get("source_id", "")), "bot": int(e.get("bot", 0)), "market": str(e.get("market", "")),
					"stat": str(e.get("stat", "")), "direction": str(e.get("direction", "")), "size_word": str(e.get("size_word", "")), "tier_changed": bool(e.get("tier_changed", false))})
	if typeof(d.get("broken")) == TYPE_DICTIONARY:
		for m in d["broken"].keys():
			broken[str(m)] = int(d["broken"][m])
	if typeof(d.get("marked")) == TYPE_DICTIONARY:
		for m in MARKETS:
			marked[m] = int(d["marked"].get(m, 0))
	spotted = bool(d.get("spotted", false))  # old saves have neither key
	if typeof(d.get("suppressed")) == TYPE_ARRAY:
		for k in d["suppressed"]:
			suppressed.append(str(k))
	if typeof(d.get("marks")) == TYPE_ARRAY:  # T284; old saves have none: every world plain
		for mk in d["marks"]:
			if typeof(mk) == TYPE_DICTIONARY:
				marks.append({"id": str(mk.get("id", "")), "opt": str(mk.get("opt", "")), "cycle": int(mk.get("cycle", 0)), "w": int(mk.get("w", 0)), "world": str(mk.get("world", ""))})
