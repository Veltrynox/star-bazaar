extends RefCounted
## T12: random events as price modifiers. Definitions (id, title, tag, text, choices) come from
## data/events.json (built from story/events.md); magnitudes and durations from data/balance.json
## (event_price_pct, event_price_cycles, event_close_cycles, event_interval). Runtime effects: tools/event_effects.md.
## Tags: [price up: Planet, commodity]  [price down: Planet, commodity]  [planet closed: Planet]
## plus one-off [cash: +N] and [stock: Planet, commodity, +N] (used only by choice effects, if the data has them).
## A choice is a Dictionary with "text" and optional "tag" (same tag format), or a plain String (no effect).

const StoryText := preload("res://game/story_text.gd")
const PATH := "res://data/events.json"

var balance: Dictionary = {}
var planets: Array = []
var defs: Array = []
var by_id: Dictionary = {}
## Active timed effects: {id, kind ("up" | "down" | "closed"), planet, c, left, age}
var active: Array = []
## This run's events, oldest first: {id, cycle}
var feed: Array = []
var pending_id: String = ""  # fired, notice not yet confirmed (saved)
## T98: planets with debris in orbit (stays until paid), and the planet of a pending debris choice.
var debris: Array = []
var pending_planet: int = -1
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
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if typeof(parsed) != TYPE_ARRAY:
		push_error("Events: %s is not a list." % PATH)
		return
	for e in parsed:
		if typeof(e) == TYPE_DICTIONARY and e.has("id"):
			defs.append(e)
			by_id[str(e["id"])] = e

func planet_index(pname: String) -> int:
	for i in planets.size():
		if typeof(planets[i]) == TYPE_DICTIONARY and str(planets[i].get("name", "")).to_lower() == pname.strip_edges().to_lower():
			return i
	return -1

## Tag text to an effect {kind, planet, c, amount}; {} when it does not parse.
func parse_tag(tag: String) -> Dictionary:
	var re := RegEx.new()
	re.compile("\\[\\s*(price up|price down|planet closed|cash|stock|debris|shield|asteroid)\\s*:\\s*([^\\]]*)\\]")
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
		"planet closed":
			if planet_index(args[0]) < 0:
				return {}
			return {"kind": "closed", "planet": planet_index(args[0]), "c": "", "amount": 0}
		"debris":
			var d := args[0].strip_edges().to_lower()
			return {"kind": "debris_" + d, "planet": -1, "c": "", "amount": 0} if d in ["pay", "leave"] else {}
		"shield", "asteroid":
			var d2 := args[0].strip_edges().to_lower()
			return {"kind": what + "_" + d2, "planet": -1, "c": "", "amount": 0}
		"cash":
			return {"kind": "cash", "planet": -1, "c": "", "amount": int(args[0].strip_edges())}
		"stock":
			if args.size() < 3 or planet_index(args[0]) < 0:
				return {}
			return {"kind": "stock", "planet": planet_index(args[0]), "c": args[1].strip_edges().to_lower(), "amount": int(args[2].strip_edges())}
	return {}

func effect_of_event(id: String) -> Dictionary:
	return parse_tag(str(by_id.get(id, {}).get("tag", "")))

func choices_of(id: String) -> Array:
	var c = by_id.get(id, {}).get("choices", [])
	return c if typeof(c) == TYPE_ARRAY else []

func choice_text(ch, args: Dictionary = {}) -> String:
	if typeof(ch) == TYPE_DICTIONARY and ch.has("text_id"):  # T98: text by story id
		return StoryText.get_text(str(ch["text_id"]), args)
	return str(ch.get("text", "")) if typeof(ch) == TYPE_DICTIONARY else str(ch)

## T98: title and body of an event; choice events with title_id/text_id load them by id.
func title_of(id: String, args: Dictionary = {}) -> String:
	var ev: Dictionary = by_id.get(id, {})
	return StoryText.get_text(str(ev["title_id"]), args) if ev.has("title_id") else str(ev.get("title", id))

func body_of(id: String, args: Dictionary = {}) -> String:
	var ev: Dictionary = by_id.get(id, {})
	return StoryText.get_text(str(ev["text_id"]), args) if ev.has("text_id") else str(ev.get("text", ""))

## T98: debris. Picks the planet for a new debris event: one that already has debris first (the offer
## comes back), otherwise a random planet.
func pick_debris_planet() -> int:
	if planets.is_empty():
		return -1
	if not debris.is_empty():
		return int(debris[rng.randi_range(0, debris.size() - 1)])
	return rng.randi_range(0, planets.size() - 1)

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

func choice_effect(ch) -> Dictionary:
	return parse_tag(str(ch.get("tag", ch.get("effect", "")))) if typeof(ch) == TYPE_DICTIONARY else {}

func pct() -> float:
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

## Event gate: an event with "min_cycle" in data/events.json is not picked before that cycle.
## No key = no gate. cycle <= 0 (not given) = no gate check.
func available(id: String, cycle: int) -> bool:
	var ev: Dictionary = by_id.get(id, {})
	return cycle <= 0 or not ev.has("min_cycle") or cycle >= int(ev["min_cycle"])

func random_id(skip: Array = [], cycle: int = 0) -> String:
	var pool: Array = []
	for d in defs:
		if not skip.has(str(d["id"])) and available(str(d["id"]), cycle):
			pool.append(d)
	if pool.is_empty():
		return ""
	return str(pool[rng.randi_range(0, pool.size() - 1)]["id"])

## Factor on both buy and sell price of commodity c at a planet.
func price_factor(planet: int, c: String) -> float:
	var f := 1.0
	for a in active:
		if a["kind"] != "closed" and int(a["planet"]) == planet and str(a["c"]) == c:
			f *= 1.0 + pct() * (1.0 if a["kind"] == "up" else -1.0)
	return f

## Start a timed effect (price or closed). One-off effects need main: see apply_oneoff.
func start_timed(id: String, eff: Dictionary) -> void:
	if eff.is_empty() or not (eff["kind"] in ["up", "down", "closed"]):
		return
	var cycles := close_cycles() if eff["kind"] == "closed" else price_cycles()
	for a in active:  # same effect again only refreshes the duration
		if a["kind"] == eff["kind"] and int(a["planet"]) == int(eff["planet"]) and str(a["c"]) == str(eff["c"]):
			a["left"] = cycles
			a["age"] = 0
			return
	active.append({"id": id, "kind": eff["kind"], "planet": int(eff["planet"]), "c": str(eff["c"]), "left": cycles, "age": 0})

## One cycle settled: effects age and expire.
func tick() -> void:
	var keep: Array = []
	for a in active:
		a["left"] = int(a["left"]) - 1
		a["age"] = int(a["age"]) + 1
		if int(a["left"]) > 0:
			keep.append(a)
	active = keep

## Planets closed right now. bridged = number of closed cycles covered by skills (A1, A2, B4).
func closed_list(bridged: int) -> Array:
	var out: Array = []
	for a in active:
		if a["kind"] == "closed" and int(a["age"]) >= bridged and not out.has(int(a["planet"])):
			out.append(int(a["planet"]))
	return out

func record(id: String, cycle: int, planet: int = -1) -> void:
	feed.append({"id": id, "cycle": cycle, "planet": planet})

func to_dict() -> Dictionary:
	return {"active": active.duplicate(true), "feed": feed.duplicate(true), "pending": pending_id, "debris": debris.duplicate(), "pending_planet": pending_planet}

func from_dict(d) -> void:
	active = []
	feed = []
	pending_id = ""
	debris = []
	pending_planet = -1
	if typeof(d) != TYPE_DICTIONARY:
		return
	if typeof(d.get("debris")) == TYPE_ARRAY:
		for p in d["debris"]:
			if int(p) >= 0 and int(p) < planets.size() and not debris.has(int(p)):
				debris.append(int(p))
	pending_planet = int(d.get("pending_planet", -1))
	if typeof(d.get("active")) == TYPE_ARRAY:
		for a in d["active"]:
			if typeof(a) == TYPE_DICTIONARY and ["up", "down", "closed"].has(str(a.get("kind", ""))):
				active.append({"id": str(a.get("id", "")), "kind": str(a["kind"]), "planet": int(a.get("planet", -1)),
					"c": str(a.get("c", "")), "left": int(a.get("left", 0)), "age": int(a.get("age", 0))})
	if typeof(d.get("feed")) == TYPE_ARRAY:
		for f in d["feed"]:
			if typeof(f) == TYPE_DICTIONARY and by_id.has(str(f.get("id", ""))):
				feed.append({"id": str(f["id"]), "cycle": int(f.get("cycle", 0)), "planet": int(f.get("planet", -1))})
	var p := str(d.get("pending", ""))
	pending_id = p if by_id.has(p) else ""
