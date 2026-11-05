class_name Workshops
extends RefCounted
## Four Markets workshops (design/proposals/2026-11-03-four-markets.md 1.3): smelter (min), munitions (mil), atelier (lux),
## culture_lab (bio). The Fabric (fabric.gd) stays the plate station and shares the same batch and yield rules.
## Built once per run in a cell (the player picks the system; default 1) for balance workshop_build_cost, unlocked by Skills.unlocked(<workshop id>).
## Each cycle a workshop makes workshop_batches_per_cycle + Skills.workshop_batches(market) batches. A batch crafts the
## highest-tier recipe whose good is open and whose inputs are in company storage (Space Storage of the cell it stands in) and yields
## <good>_batch_out + Skills.batch_yield(market) units. Inputs leave storage, output goes to storage, no credits move.
## Every batch reports its units through the craft callback (main.craft_units) so tech completes.
## Saved by main under "workshops": {id: {built, system, state, reason, made}}.

const StoryText := preload("res://game/story_text.gd")
const SYSTEM := 1  # default cell (old saves, build_workshop without a system); each workshop saves its own system
const IDS := ["smelter", "munitions", "atelier", "culture_lab"]

var balance: Dictionary = {}
var built: Dictionary = {}    # id -> bool
var system: Dictionary = {}   # id -> system id of the cell it stands in (storage key system:<n>)
var state: Dictionary = {}    # id -> idle | running | stalled
var reason: Dictionary = {}   # id -> short stall text
var made: Dictionary = {}     # id -> {good: units} of the last cycle
var missing: Dictionary = {}  # id -> [good ids] every input the next batch lacked when the workshop stalled

func setup(bal: Dictionary) -> void:
	balance = bal
	built = {}
	system = {}
	state = {}
	reason = {}
	made = {}
	missing = {}
	for id in IDS:
		missing[id] = []
		built[id] = false
		system[id] = SYSTEM
		state[id] = "idle"
		reason[id] = ""
		made[id] = {}

func system_of(id: String) -> int:
	return int(system.get(id, SYSTEM))

## True when the workshop id is built and stands in the cell of system sid.
func stands_in(id: String, sid: int) -> bool:
	return bool(built.get(id, false)) and system_of(id) == sid

func market_of(id: String) -> String:
	return str(Goods.workshop(id).get("market", ""))

func build_cost(id: String) -> int:
	return maxi(0, int(balance.get(str(Goods.workshop(id).get("cost_key", "workshop_build_cost")), 0)))

func is_unlocked(id: String) -> bool:
	return Skills.unlocked(id)

func batches(id: String) -> int:
	if Chains.workshop_idle(market_of(id)):  # an event chain pauses the workshop for some cycles
		return 0
	return maxi(1, int(balance.get("workshop_batches_per_cycle", 1)) + Skills.workshop_batches(market_of(id)) + Chains.workshop_extra(market_of(id)))

## Units one batch of `good` yields now.
func out_units(good: String) -> int:
	return Goods.batch_out(good, balance) + Skills.batch_yield(str(Goods.entry(good).get("market", "")))

## Recipes this workshop can use now (good open), lowest tier first.
func open_recipes(id: String) -> Array:
	var out: Array = []
	for g in Goods.recipes_of(id):
		if Goods.good_open(g) and Goods.recipe_ok(g):
			out.append(g)
	return out

## Inputs of `good` the storage lacks, all of them (not only the first).
func missing_inputs(storage: RefCounted, key: String, good: String) -> Array:
	var out: Array = []
	var r := Goods.recipe(good)
	for c in r.keys():
		if storage.amount(key, str(c)) < int(r[c]):
			out.append(str(c))
	return out

func _can_make(storage: RefCounted, key: String, good: String) -> String:
	var m := missing_inputs(storage, key, good)
	if not m.is_empty():
		return "needs " + ",".join(m)
	if storage.space(key, good) < out_units(good):
		return "storage full"
	return ""

## One cycle for every built workshop. craft: Callable(market: String, units: int), may be invalid (tests).
func run(storage: RefCounted, craft: Callable = Callable()) -> void:
	for id in IDS:
		var key: String = storage.system_key(system_of(id))
		made[id] = {}
		missing[id] = []
		if not bool(built.get(id, false)):
			state[id] = "idle"
			reason[id] = ""
			continue
		var why := ""
		var total := 0
		var recipes := open_recipes(id)
		recipes.reverse()  # highest tier first
		if recipes.is_empty():
			why = "no recipe"
		if Chains.workshop_idle(market_of(id)):
			why = "paused"
		for b in batches(id):
			var pick := ""
			why = ""
			for g in recipes:
				var w := _can_make(storage, key, str(g))
				if w == "":
					pick = str(g)
					break
				if why == "":
					why = w
			if pick == "":
				break
			var r := Goods.recipe(pick)
			for c in r.keys():
				storage.remove(key, str(c), int(r[c]))
			var n: int = storage.add(key, pick, out_units(pick))
			made[id][pick] = int(made[id].get(pick, 0)) + n
			total += n
			if craft.is_valid() and n > 0:
				craft.call(market_of(id), n)
		if total > 0:
			state[id] = "running"
			reason[id] = ""
		else:
			state[id] = "stalled"
			reason[id] = why
			if why.begins_with("needs "):
				missing[id] = Array(why.substr(6).split(","))

## Recipe line for the screen: a hidden input shows as "another input" instead of its name (Availability).
func recipe_line(good: String) -> String:
	var parts: Array = []
	var r := Goods.recipe(good)
	for c in r.keys():
		if Availability.good(str(c)):
			parts.append("%d %s" % [int(r[c]), Ui.good_name(str(c)).to_lower()])
		else:
			parts.append(StoryText.get_or("LBL_WORKSHOP_NEEDS_OTHER", "another input"))
	return "%s -> %d %s" % [" + ".join(parts), out_units(good), Ui.good_name(good).to_lower()]  # yield includes batch_yield skills

## Status line of a built workshop. Stalled: "Stalled: needs Energy, Logic Cores" naming every missing input that is
## visible now (Availability), plus "another input" when a hidden good is missing. Not stalled: "Batches this cycle: n"
## (+ what the last cycle made). A stalled workshop never shows its batch count (nothing was made).
func status_text(id: String) -> String:
	if str(state.get(id, "")) == "stalled":
		var why: String = str(reason.get(id, ""))
		var names: Array = []
		var hidden := false
		for g in missing.get(id, []):
			if Availability.good(str(g)):
				names.append(Ui.good_name(str(g)))
			else:
				hidden = true
		if hidden:
			names.append(StoryText.get_or("LBL_WORKSHOP_NEEDS_OTHER", "another input"))
		if not names.is_empty():
			why = StoryText.get_or("LBL_WORKSHOP_NEEDS", "needs {items}", {"items": ", ".join(names)})
		return StoryText.get_or("LBL_WORKSHOP_STALLED", "Stalled: {why}", {"why": why})
	var line := StoryText.get_or("LBL_WORKSHOP_BATCHES", "Batches this cycle: {n}", {"n": batches(id)})
	var mt := made_text(id)
	if mt != "":
		line += "  " + StoryText.get_or("LBL_WORKSHOP_MADE", "Last cycle: {items}", {"items": mt})
	return line

## "made 3 cells" text of the last cycle, "" when nothing.
func made_text(id: String) -> String:
	var parts: Array = []
	for g in made.get(id, {}).keys():
		parts.append("%d %s" % [int(made[id][g]), Ui.good_name(str(g)).to_lower()])
	return ", ".join(parts)

func to_dict() -> Dictionary:
	var d := {}
	for id in IDS:
		d[id] = {"built": bool(built[id]), "system": system_of(id), "state": str(state[id]), "reason": str(reason[id]), "missing": missing[id].duplicate(), "made": made[id].duplicate()}
	return d

func from_dict(saved) -> void:
	setup(balance)
	if typeof(saved) != TYPE_DICTIONARY:
		return  # old saves: nothing built
	for id in IDS:
		var d = saved.get(id)
		if typeof(d) != TYPE_DICTIONARY:
			continue
		built[id] = bool(d.get("built", false))
		system[id] = int(d.get("system", SYSTEM))  # old saves: system 1
		state[id] = str(d.get("state", "idle"))
		reason[id] = str(d.get("reason", ""))
		if typeof(d.get("missing")) == TYPE_ARRAY:
			for g in d["missing"]:
				missing[id].append(str(g))
		if typeof(d.get("made")) == TYPE_DICTIONARY:
			for g in d["made"].keys():
				made[id][str(g)] = int(d["made"][g])
