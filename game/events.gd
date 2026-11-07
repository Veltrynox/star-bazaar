extends RefCounted
## T12: random events as price modifiers. Definitions (id, title, tag, text, choices) come from
## data/events.json (built from story/events.md); magnitudes and durations from data/balance.json
## (event_price_pct, event_price_cycles, event_close_cycles, event_interval). Runtime effects: tools/event_effects.md.
## Tags: [price up: Planet, commodity]  [price down: Planet, commodity]  [planet closed: Planet]
## plus one-off [cash: +N] and [stock: Planet, commodity, +N] (used only by choice effects, if the data has them).
## Market chains (game/chains.gd) take the chain steps and the bot effects; this file holds the shared one-time pool (24 kept
## rows of data/events.json plus EV40-EV51 from data/chains.json), the timed price effects and the scheduled Minerals A flavour popups.
## A choice has one "tag" in the data. Use choice_effects(ch) for all its effects.
## A choice is a Dictionary with "text" and optional "tag" (same tag format), or a plain String (no effect).

const StoryText := preload("res://game/story_text.gd")
const PATH := "res://data/events.json"

## One-off notice (not a pool event, not in defs, no effect): Space Storage can be learned. Shown as an important icon.
const NOTICE_STORAGE := "STORAGE_READY"
var balance: Dictionary = {}
var debug_off: Array = []  # T13: event ids the debug menu keeps out of the random pick; runtime only, never saved
var planets: Array = []
var defs: Array = []
var by_id: Dictionary = {}
## Active timed effects: {id, kind ("up" | "down" | "closed" | "shortage" | "congestion"), planet, c, left, age, house}
## T280 house weather: the three houses (Bots.IDS, game/bots.gd) are weather, never opponents. House 1 Harrow = flood (kind "down"),
## 2 Velvet = shortage (kind "shortage", and the price-up events), 3 Ostrel = congestion (kind "congestion", and closures).
## house_of(id) reads a "house" key of the event row (or its pool_effect) first, else the effect kind. Numbers (balance.json, placeholders):
## shortage_cycles, shortage_demand_mult (a need's demand x this at the world), shortage_hunger_steps (extra hunger steps on that need),
## congestion_cycles, congestion_trip_mult (trip cost x this on lanes touching the world). Tags: [shortage: Planet, good], [congestion: Planet].
var active: Array = []
## This run's events, oldest first: {id, cycle}
var feed: Array = []
var pending_id: String = ""  # fired, notice not yet confirmed (saved)
## T98: planets with debris in orbit (stays until paid), and the planet of a pending debris choice.
var debris: Array = []
var pending_planet: int = -1
## Scheduled follow-ups (R1): {id, due}. A choice with follow_id (+ follow_after cycles) puts the id here; it fires once
## at the start of cycle >= due and is removed. Saved under "scheduled"; an old save has none.
var scheduled: Array = []
var locked: Array = []  # planet indexes of dead worlds not open yet (set by main); no random event picks them
var need_fn: Callable = Callable()  # T280: (planet index, good) -> bool, true when the good is a need of that world (set by main); a shortage event waits for it
var established_fn: Callable = Callable()  # T179: planet index -> bool, false while the planet has no post or platform (set by main)

## T179: the planets an event may name or price: those with a post or platform (all of them while discovery is off).
func known_planets() -> Array:
	if not established_fn.is_valid():
		return planets
	var out: Array = []
	for i in planets.size():
		if bool(established_fn.call(i)):
			out.append(planets[i])
	return out
var rng := RandomNumberGenerator.new()

func setup(bal: Dictionary, plist: Array) -> void:
	balance = bal
	planets = plist
	rng.randomize()
	for a in OS.get_cmdline_user_args():  # a given --seed=<int> makes the event RNG repeatable (QA); normal play stays random
		if a.begins_with("--seed="):
			rng.seed = int(a.trim_prefix("--seed="))
	defs = []
	by_id = {}
	if not FileAccess.file_exists(PATH):
		push_error("Events: %s is missing. Run tools/build_story.py." % PATH)
		return
	var parsed: Array = StoryText.entries_of(JSON.parse_string(FileAccess.get_file_as_string(PATH)))
	if parsed.is_empty():
		push_error("Events: %s is not a list." % PATH)
		return
	for e in parsed:
		if typeof(e) == TYPE_DICTIONARY and e.has("id"):
			defs.append(e)
			by_id[str(e["id"])] = e
	_add_chain_defs()
	by_id[NOTICE_STORAGE] = {"id": NOTICE_STORAGE, "notice": true, "title": "STORAGE_READY_TITLE", "title_id": "STORAGE_READY_TITLE", "text_id": "STORAGE_READY"}

## Chain data adds rows without touching data/events.json: the 12 new pool events (price or closure, text by EV<nn>_TITLE / _BODY /
## _EFF ids) and one row per chain step (kind C, texts by EV_<step>_..., see chains.gd).
func _add_chain_defs() -> void:
	for id in Chains.pool_new.keys():
		if by_id.has(id):
			continue
		var n: Dictionary = Chains.pool_new[id]
		var d := {"id": id, "title": id, "title_id": id + "_TITLE", "text_id": id + "_BODY", "text": "", "tag": "", "kind": str(n.get("kind", "P")), "choices": [], "pool_effect": n.get("effect", {})}
		if n.has("branch"):  # EV52-EV55: one pattern, two cash options (A dark market, B public), window and goods gate by visible_when
			d.erase("pool_effect")
			d["branch"] = str(n.get("market", ""))
			d["choices"] = _branch_choices(id, n)
		if n.has("visible_when"):
			d["visible_when"] = n["visible_when"]
		defs.append(d)
		by_id[id] = d
	for sid in Chains.step_ids():
		by_id[sid] = {"id": sid, "title": sid, "text": "", "tag": "", "kind": "C", "choices": [], "chain_step": true, "market": Chains.market_of(sid)}

## The two options of a branch event (EV52-EV55) from its pool_new row: A (dark market, "dark": true) and B (public). The cash is
## read live from balance by "cash_key" (see choice_effect). Texts by EV<nn>_A_BTN / _A_EFF / _A_TITLE / _A and the same for B.
func _branch_choices(id: String, n: Dictionary) -> Array:
	var br: Dictionary = n.get("branch", {})
	var out: Array = []
	for side in ["A", "B"]:
		out.append({"text_id": "%s_%s_BTN" % [id, side], "eff_id": "%s_%s_EFF" % [id, side], "popup_title_id": "%s_%s_TITLE" % [id, side], "popup_id": "%s_%s" % [id, side],
			"cash_key": str(br.get("a_cash_key" if side == "A" else "b_cash_key", "")), "market": str(n.get("market", "")), "dark": side == "A"})
	return out

func is_branch(id: String) -> bool:
	return by_id.get(id, {}).has("branch")

## Text args of a branch choice: {cash_in} the credits it pays (number only) and {market} the display name. {} for other choices.
func choice_args(ch) -> Dictionary:
	if typeof(ch) != TYPE_DICTIONARY or not ch.has("cash_key"):
		return {}
	return {"cash_in": int(balance.get(str(ch["cash_key"]), 0)), "market": str(Markets.names.get(str(ch.get("market", "")), str(ch.get("market", ""))))}

## Hidden consequence of a dark-market choice (A of EV52-EV55): rolls once, balance spotted_chance. Spotted: Chains.spotted is set
## and suppressed_share of the profitable events (positive pool events not fired yet, chain options with a gain) are removed for the
## rest of the run, picked once with the run seed. Already spotted: no roll, nothing more removed. Never shown anywhere.
func dark_choice() -> void:
	if Chains.spotted:
		return
	if rng.randf() >= float(balance.get("spotted_chance", 0.0)):
		return
	Chains.suppress_profitable(profitable_pool_ids(), float(balance.get("suppressed_share", 0.0)))

## Pool events that give the player a gain and have not fired: a price-up effect, or a choice with a positive cash or stock effect.
## The branch events themselves are not counted.
func profitable_pool_ids() -> Array:
	var out: Array = []
	for d in defs:
		var pid := str(d["id"])
		if not Chains.in_pool(pid) or is_branch(pid) or _fired(pid):
			continue
		var gain := str(effect_of_event(pid).get("kind", "")) == "up"
		for ch in choices_of(pid):
			var e := choice_effect(ch)
			if (str(e.get("kind", "")) in ["cash", "stock"]) and int(e.get("amount", 0)) > 0:
				gain = true
		if gain:
			out.append(pid)
	return out

func is_chain_step(id: String) -> bool:
	return bool(by_id.get(id, {}).get("chain_step", false))

func planet_index(pname: String) -> int:
	for i in planets.size():
		if typeof(planets[i]) == TYPE_DICTIONARY and str(planets[i].get("name", "")).to_lower() == pname.strip_edges().to_lower():
			return i
	return -1

## Tag text to an effect {kind, planet, c, amount}; {} when it does not parse.
func parse_tag(tag: String) -> Dictionary:
	var re := RegEx.new()
	re.compile("\\[\\s*(price up|price down|planet closed|shortage|congestion|cash|stock|debris|asteroid)\\s*:\\s*([^\\]]*)\\]")
	var m := re.search(tag)
	if m == null:
		return {}
	var args: PackedStringArray = m.get_string(2).split(",")
	var what := m.get_string(1)
	match what:
		"price up", "price down":
			if args.size() < 2 or planet_index(args[0]) < 0:
				return {}
			return {"kind": "up" if what == "price up" else "down", "planet": planet_index(args[0]), "c": args[1].strip_edges().to_lower(), "amount": 0}
		"shortage":
			if args.size() < 2 or planet_index(args[0]) < 0:
				return {}
			return {"kind": "shortage", "planet": planet_index(args[0]), "c": args[1].strip_edges().to_lower(), "amount": 0}
		"congestion":
			if planet_index(args[0]) < 0:
				return {}
			return {"kind": "congestion", "planet": planet_index(args[0]), "c": "", "amount": 0}
		"planet closed":
			if planet_index(args[0]) < 0:
				return {}
			return {"kind": "closed", "planet": planet_index(args[0]), "c": "", "amount": 0}
		"debris":
			var d := args[0].strip_edges().to_lower()
			return {"kind": "debris_" + d, "planet": -1, "c": "", "amount": 0} if d in ["pay", "leave"] else {}
		"asteroid":
			var d2 := args[0].strip_edges().to_lower()
			return {"kind": what + "_" + d2, "planet": -1, "c": "", "amount": 0}
		"cash":
			return {"kind": "cash", "planet": -1, "c": "", "amount": int(args[0].strip_edges())}
		"stock":
			if args.size() < 3 or planet_index(args[0]) < 0:
				return {}
			return {"kind": "stock", "planet": planet_index(args[0]), "c": args[1].strip_edges().to_lower(), "amount": int(args[2].strip_edges())}
	return {}

## Event icons: a minor event is a pure price change (price up / down, no choices, not a chain step). Everything else is important
## (choices, chain steps, closed planets, flavour) and its icon stays until clicked.
func is_minor(id: String) -> bool:
	if not by_id.has(id) or is_chain_step(id) or not choices_of(id).is_empty():
		return false
	return str(effect_of_event(id).get("kind", "")) in ["up", "down", "shortage", "congestion"]

## Planet an event names (price or closure effect), -1 when it names none.
func named_planet(id: String) -> int:
	return int(effect_of_event(id).get("planet", -1))

func effect_of_event(id: String) -> Dictionary:
	var pe = by_id.get(id, {}).get("pool_effect")
	if typeof(pe) == TYPE_DICTIONARY and not pe.is_empty():  # new pool event from data/chains.json: planet by its id
		var pi := -1
		for i in planets.size():
			if typeof(planets[i]) == TYPE_DICTIONARY and str(planets[i].get("id", "")) == str(pe.get("planet", "")):
				pi = i
		if pi < 0:
			return {}
		return {"kind": str(pe.get("direction", "up")), "planet": pi, "c": str(pe.get("good", "")), "amount": 0}
	return parse_tag(str(by_id.get(id, {}).get("tag", "")))

func choices_of(id: String) -> Array:
	var c = by_id.get(id, {}).get("choices", [])
	return c if typeof(c) == TYPE_ARRAY else []

func choice_text(ch, args: Dictionary = {}) -> String:
	if typeof(ch) == TYPE_DICTIONARY and ch.has("text_id"):  # T98: text by story id
		return StoryText.get_text(str(ch["text_id"]), args)
	return str(ch.get("text", "")) if typeof(ch) == TYPE_DICTIONARY else str(ch)

## Title and body of an event: every event row carries title_id / text_id (StoryText); a plain title/text is only a fallback for test rows.
func title_of(id: String, args: Dictionary = {}) -> String:
	var ev: Dictionary = by_id.get(id, {})
	if is_chain_step(id):
		return Chains.title(id)
	return StoryText.get_or(str(ev["title_id"]), str(ev.get("title", id)), args) if ev.has("title_id") else str(ev.get("title", id))

func body_of(id: String, args: Dictionary = {}) -> String:
	var ev: Dictionary = by_id.get(id, {})
	if is_chain_step(id):
		return Chains.body(id)
	return StoryText.get_or(str(ev["text_id"]), str(ev.get("text", "")), args) if ev.has("text_id") else str(ev.get("text", ""))

## T98: debris. Picks the planet for a new debris event: one that already has debris first (the offer
## comes back), otherwise a random planet.
func pick_debris_planet() -> int:
	if planets.is_empty():
		return -1
	if not debris.is_empty():
		return int(debris[rng.randi_range(0, debris.size() - 1)])
	var opts: Array = []
	for i in planets.size():
		if not locked.has(i):
			opts.append(i)
	return int(opts[rng.randi_range(0, opts.size() - 1)]) if not opts.is_empty() else -1

## T109: seeded 50/50 roll for the asteroid decline (QA can set the seed and replay). True = bad outcome.
func seed_rng(s: int) -> void:
	rng.seed = s

func asteroid_roll() -> bool:
	return rng.randf() < float(balance.get("asteroid_decline_bad_odds", 0.5))

func asteroid_cost() -> int:
	return int(balance.get("asteroid_deflect_cost", 0))

func debris_fee() -> int:
	return int(balance.get("debris_clear_fee", 0))

func debris_penalty() -> float:
	return float(balance.get("debris_route_penalty", 0.0))

## All effects of a choice (the main tag). Each is {kind, planet, c, amount}; {} entries dropped.
func choice_effects(ch) -> Array:
	var first := choice_effect(ch)
	return [] if first.is_empty() else [first]

func choice_effect(ch) -> Dictionary:
	if typeof(ch) == TYPE_DICTIONARY and ch.has("cash_key"):  # branch option: cash from balance, live
		return {"kind": "cash", "planet": -1, "c": "", "amount": int(balance.get(str(ch["cash_key"]), 0))}
	return parse_tag(str(ch.get("tag", ch.get("effect", "")))) if typeof(ch) == TYPE_DICTIONARY else {}

func pct(c: String = "") -> float:
	## Per-good swing: balance key event_pct_<good> (silk, chips, ore); other goods use event_price_pct.
	if c != "" and balance.has("event_pct_" + c):
		return float(balance["event_pct_" + c])
	return float(balance.get("event_price_pct", 0.0))

func price_cycles() -> int:
	return int(balance.get("event_price_cycles", 0))

func close_cycles() -> int:
	return int(balance.get("event_close_cycles", 0))

func interval() -> int:
	return maxi(1, int(balance.get("event_interval", 4)))

## True when an event is due at the start of this cycle (not cycle 1: the tutorial runs first).
func due(cycle: int) -> bool:
	return cycle > 1 and (cycle - 1) % interval() == 0

## Event gate: an event with "min_cycle" in data/events.json is not picked before that cycle; an event with "visible_when"
## (a condition tree, game/conditions.gd) is not picked while it is false. No key = no gate. cycle <= 0 (not given) = no gate check.
func available(id: String, cycle: int) -> bool:
	var ev: Dictionary = by_id.get(id, {})
	if not good_available(id) or not Conditions.visible(ev, {"cycle": cycle, "planets": known_planets()}):
		return false
	var eff := effect_of_event(id)
	if str(eff.get("kind", "")) == "shortage" and need_fn.is_valid() and not bool(need_fn.call(int(eff["planet"]), str(eff["c"]))):
		return false  # T280: a shortage hits a need the world really has
	if cycle <= 0:
		return true
	return cycle >= int(ev.get("min_cycle", 0))

## Owner 2026-11-02: an event about a good (price up/down, stock) is not picked while no open planet trades
## that good. "Open" = the planets this run knows (permitted systems only). A good is traded when a planet's
## base_prices has <good>_buy or <good>_sell. Events without a good are always fine.
func good_available(id: String) -> bool:
	var eff := effect_of_event(id)
	if eff.is_empty() and by_id.get(id, {}).has("pool_effect"):
		return false  # its planet is not open in this run
	var c := str(eff.get("c", ""))
	if c == "":
		return true
	# never name a good the player cannot see yet (data/availability.json), and some open planet must price it
	return Conditions.eval({"all": ["good_visible:" + c, "good_traded:" + c]}, {"planets": known_planets()})

## True for events that never come from the random pick: part 2 events (the follow_id of any choice) and events
## marked "scheduled_only" or "random": false.
func scheduled_only(id: String) -> bool:
	var ev: Dictionary = by_id.get(id, {})
	if bool(ev.get("scheduled_only", false)) or (ev.has("random") and not bool(ev["random"])):
		return true
	for d in defs:
		for ch in choices_of(str(d["id"])):
			if typeof(ch) == TYPE_DICTIONARY and str(ch.get("follow_id", "")) == id:
				return true
	return false

## Puts the follow-up of a chosen choice on the schedule: due = cycle + follow_after (default balance dead_follow_cycles).
## Returns true when something was scheduled. An id not in the data is ignored.
func schedule_follow(ch, cycle: int) -> bool:
	if typeof(ch) != TYPE_DICTIONARY or not ch.has("follow_id") or not by_id.has(str(ch["follow_id"])):
		return false
	var after := int(ch.get("follow_after", balance.get("dead_follow_cycles", 4)))
	scheduled.append({"id": str(ch["follow_id"]), "due": cycle + maxi(1, after)})
	return true

## The first scheduled event due at this cycle (due <= cycle), removed from the list; "" when none.
func take_due(cycle: int) -> String:
	for i in scheduled.size():
		if int(scheduled[i]["due"]) <= cycle:
			var id := str(scheduled[i]["id"])
			scheduled.remove_at(i)
			return id
	return ""

## True when the event or chain step fired this run (feed is saved with the run; the event_fired atom reads it).
func has_fired(id: String) -> bool:
	return _fired(id)

func _fired(id: String) -> bool:
	for f in feed:
		if str(f["id"]) == id:
			return true
	return false

## The shared pool: the 24 kept events and EV40-EV51 (data/chains.json), each at most once per run (a fired id never comes again).
func random_id(skip: Array = [], cycle: int = 0) -> String:
	var pool: Array = []
	for d in defs:
		var pid := str(d["id"])
		if (Chains.in_pool(pid) or is_weather(pid)) and not skip.has(pid) and not scheduled_only(pid) and not debug_off.has(pid) and not _fired(pid) and not Chains.is_suppressed(pid) and available(pid, cycle):
			pool.append(d)
	if pool.is_empty():
		return ""
	return str(pool[rng.randi_range(0, pool.size() - 1)]["id"])

## True when a price-up event runs at planet for commodity c (LUX_5 counts sales there extra).
func price_up_at(planet: int, c: String) -> bool:
	for a in active:
		if a["kind"] == "up" and int(a["planet"]) == planet and str(a["c"]) == c:
			return true
	return false

## Factor on both buy and sell price of commodity c at a planet. next_cycle = the factor after one tick
## (only effects with cycles left after this one; LUX_1 Price Whisper shows it). Skills: event_bonus_pct makes price-up
## events pay more, event_cut_pct makes price-down events weaker, by the market of c.
func price_factor(planet: int, c: String, next_cycle: bool = false, ahead: int = 1) -> float:
	var f := 1.0
	for a in active:
		if next_cycle and int(a["left"]) < 1 + ahead:  # ahead cycles on (LUX_5B: 2)
			continue
		if (a["kind"] == "up" or a["kind"] == "down") and int(a["planet"]) == planet and str(a["c"]) == c:
			var m := Markets.market_of(c)
			if a["kind"] == "up":
				f *= 1.0 + pct(c) * (1.0 + Skills.event_bonus(m))
			else:
				f *= 1.0 - pct(c) * (1.0 - Skills.event_cut(m)) * soft_of(a)
	return f

## Start a timed effect (price or closed). One-off effects need main: see apply_oneoff.
func start_timed(id: String, eff: Dictionary) -> void:
	if eff.is_empty() or not (eff["kind"] in ["up", "down", "closed", "shortage", "congestion"]):
		return
	var cycles := weather_cycles(str(eff["kind"]))
	var house := house_of(id, str(eff["kind"]))
	var mark := Skills.take_house_next(house) if house > 0 else {"soften": 0.0, "delay": 0}  # T282: a chain option marked this house
	if int(mark["delay"]) > 0:
		held.append({"id": id, "eff": eff.duplicate(), "wait": int(mark["delay"]), "soft": float(mark["soften"])})
		return
	_start_now(id, eff, cycles, house, float(mark["soften"]))

## Starts a weather effect that was delayed by a chain option (T282); wait counts down in tick().
var held: Array = []  # {id, eff, wait, soft}

func _start_now(id: String, eff: Dictionary, cycles: int, house: int, soft: float) -> void:
	for a in active:  # same effect again only refreshes the duration
		if a["kind"] == eff["kind"] and int(a["planet"]) == int(eff["planet"]) and str(a["c"]) == str(eff["c"]):
			a["left"] = cycles
			a["age"] = 0
			a["soft"] = maxf(float(a.get("soft", 0.0)), soft)
			return
	active.append({"id": id, "kind": eff["kind"], "planet": int(eff["planet"]), "c": str(eff["c"]), "left": cycles, "age": 0, "house": house, "soft": soft})

## ---- house weather (T280) ----
## T282: strength of one live weather effect, 0..1: the house's skill soften (Skills.weather_soften_pct) and the chain soften stored on the row.
func soft_of(a: Dictionary) -> float:
	return clampf(Skills.weather_soft_factor(int(a.get("house", 0))) * (1.0 - float(a.get("soft", 0.0))), 0.0, 1.0)

func weather_cycles(kind: String) -> int:
	match kind:
		"closed":
			return close_cycles()
		"shortage":
			return int(balance.get("shortage_cycles", 0))
		"congestion":
			return int(balance.get("congestion_cycles", 0))
	return price_cycles()

## House id (1 Harrow, 2 Velvet, 3 Ostrel) of an event or timed effect; 0 for events that are not weather.
func house_of(id: String, kind: String = "") -> int:
	var ev: Dictionary = by_id.get(id, {})
	var pe = ev.get("pool_effect")
	if ev.has("house"):
		return int(ev["house"])
	if typeof(pe) == TYPE_DICTIONARY and pe.has("house"):
		return int(pe["house"])
	if kind == "":
		kind = str(effect_of_event(id).get("kind", ""))
	match kind:
		"down":
			return 1
		"up", "shortage":
			return 2
		"closed", "congestion":
			return 3
	return 0

## True for the weather rows of data/events.json (shortage and congestion tags), which are not listed in data/chains.json.
func is_weather(id: String) -> bool:
	return str(effect_of_event(id).get("kind", "")) in ["shortage", "congestion"]

## Demand multiplier on a need at a world from live shortages (1.0 when none).
func shortage_mult(planet: int, c: String) -> float:
	var m := 1.0
	for a in active:
		if a["kind"] == "shortage" and int(a["planet"]) == planet and str(a["c"]) == c:
			m *= 1.0 + (maxf(0.0, float(balance.get("shortage_demand_mult", 1.0))) - 1.0) * soft_of(a)
	return m

## Extra hunger steps on a need at a world from live shortages.
func shortage_hunger(planet: int, c: String) -> int:
	for a in active:
		if a["kind"] == "shortage" and int(a["planet"]) == planet and str(a["c"]) == c:
			return maxi(0, int(balance.get("shortage_hunger_steps", 0)))
	return 0

## The good a live shortage hits at a world, "" when none (the rush generator reads it).
func shortage_good_at(planet: int) -> String:
	for a in active:
		if a["kind"] == "shortage" and int(a["planet"]) == planet:
			return str(a["c"])
	return ""

## Trip cost multiplier for a lane with these ends from live congestion (1.0 when none; one hit per lane, not per end).
func congestion_mult(a_planet: int, b_planet: int) -> float:
	for a in active:
		if a["kind"] == "congestion" and (int(a["planet"]) == a_planet or int(a["planet"]) == b_planet):
			return 1.0 + (maxf(0.0, float(balance.get("congestion_trip_mult", 1.0))) - 1.0) * soft_of(a)
	return 1.0

## Active weather of a house, for the UI and the convoy telegraph later: [{planet, c, kind, left}].
func weather_of_house(h: int) -> Array:
	var out: Array = []
	for a in active:
		if int(a.get("house", 0)) == h:
			out.append({"planet": int(a["planet"]), "c": str(a["c"]), "kind": str(a["kind"]), "left": int(a["left"])})
	return out

## One cycle settled: effects age and expire.
func tick() -> void:
	var still: Array = []
	for hd in held:  # T282: delayed weather starts when its wait is over
		hd["wait"] = int(hd["wait"]) - 1
		if int(hd["wait"]) <= 0:
			_start_now(str(hd["id"]), hd["eff"], weather_cycles(str(hd["eff"]["kind"])), house_of(str(hd["id"]), str(hd["eff"]["kind"])), float(hd["soft"]))
		else:
			still.append(hd)
	held = still
	var keep: Array = []
	for a in active:
		a["left"] = int(a["left"]) - 1
		a["age"] = int(a["age"]) + 1
		if int(a["left"]) > 0:
			keep.append(a)
	active = keep

## Planets closed right now. bridged = closed cycles skipped (the reopen_sooner skills, BIO_6).
func closed_list(bridged: int) -> Array:
	var out: Array = []
	for a in active:
		if a["kind"] == "closed" and int(a["age"]) >= bridged and not out.has(int(a["planet"])):
			out.append(int(a["planet"]))
	return out

func record(id: String, cycle: int, planet: int = -1) -> void:
	feed.append({"id": id, "cycle": cycle, "planet": planet})

func to_dict() -> Dictionary:
	return {"active": active.duplicate(true), "feed": feed.duplicate(true), "pending": pending_id, "debris": debris.duplicate(), "pending_planet": pending_planet, "scheduled": scheduled.duplicate(true), "held": held.duplicate(true)}

func from_dict(d) -> void:
	active = []
	feed = []
	pending_id = ""
	debris = []
	pending_planet = -1
	scheduled = []
	held = []
	if typeof(d) != TYPE_DICTIONARY:
		return
	if typeof(d.get("held")) == TYPE_ARRAY:  # T282; an older save has none
		for hd in d["held"]:
			if typeof(hd) == TYPE_DICTIONARY and typeof(hd.get("eff")) == TYPE_DICTIONARY and hd["eff"].has("kind"):
				held.append({"id": str(hd.get("id", "")), "eff": hd["eff"], "wait": int(hd.get("wait", 1)), "soft": float(hd.get("soft", 0.0))})
	if typeof(d.get("scheduled")) == TYPE_ARRAY:  # old saves have none
		for sc in d["scheduled"]:
			if typeof(sc) == TYPE_DICTIONARY and by_id.has(str(sc.get("id", ""))):
				scheduled.append({"id": str(sc["id"]), "due": int(sc.get("due", 0))})
	if typeof(d.get("debris")) == TYPE_ARRAY:
		for p in d["debris"]:
			if int(p) >= 0 and int(p) < planets.size() and not debris.has(int(p)):
				debris.append(int(p))
	pending_planet = int(d.get("pending_planet", -1))
	if typeof(d.get("active")) == TYPE_ARRAY:
		for a in d["active"]:
			if typeof(a) == TYPE_DICTIONARY and ["up", "down", "closed", "shortage", "congestion"].has(str(a.get("kind", ""))):
				active.append({"id": str(a.get("id", "")), "kind": str(a["kind"]), "planet": int(a.get("planet", -1)),
					"c": str(a.get("c", "")), "left": int(a.get("left", 0)), "age": int(a.get("age", 0)), "house": int(a.get("house", house_of(str(a.get("id", "")), str(a["kind"])))), "soft": float(a.get("soft", 0.0))})
	if typeof(d.get("feed")) == TYPE_ARRAY:
		for f in d["feed"]:
			if typeof(f) == TYPE_DICTIONARY and by_id.has(str(f.get("id", ""))):
				feed.append({"id": str(f["id"]), "cycle": int(f.get("cycle", 0)), "planet": int(f.get("planet", -1))})
	var p := str(d.get("pending", ""))
	pending_id = p if by_id.has(p) else ""
