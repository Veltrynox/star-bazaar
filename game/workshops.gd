class_name Workshops
extends RefCounted
## Four Markets workshops (design/proposals/2026-11-03-four-markets.md 1.3): smelter (min), munitions (mil), atelier (lux),
## culture_lab (bio). The Fabric (fabric.gd) stays the plate station and shares the same batch and yield rules.
## Built once at the trading post (system 1) for balance workshop_build_cost, unlocked by Skills.unlocked(<workshop id>).
## Each cycle a workshop makes workshop_batches_per_cycle + Skills.workshop_batches(market) batches. A batch crafts the
## highest-tier recipe whose good is open and whose inputs are in company storage (system 1 Space Storage) and yields
## <good>_batch_out + Skills.batch_yield(market) units. Inputs leave storage, output goes to storage, no credits move.
## Every batch reports its units through the craft callback (main.craft_units) so tech completes.
## Saved by main under "workshops": {id: {built, state, reason, made}}.

const SYSTEM := 1
const IDS := ["smelter", "munitions", "atelier", "culture_lab"]

var balance: Dictionary = {}
var built: Dictionary = {}    # id -> bool
var state: Dictionary = {}    # id -> idle | running | stalled
var reason: Dictionary = {}   # id -> short stall text
var made: Dictionary = {}     # id -> {good: units} of the last cycle

func setup(bal: Dictionary) -> void:
	balance = bal
	built = {}
	state = {}
	reason = {}
	made = {}
	for id in IDS:
		built[id] = false
		state[id] = "idle"
		reason[id] = ""
		made[id] = {}

func market_of(id: String) -> String:
	return str(Goods.workshop(id).get("market", ""))

func build_cost(id: String) -> int:
	return maxi(0, int(balance.get(str(Goods.workshop(id).get("cost_key", "workshop_build_cost")), 0)))

func is_unlocked(id: String) -> bool:
	return Skills.unlocked(id)

func batches(id: String) -> int:
	return maxi(1, int(balance.get("workshop_batches_per_cycle", 1)) + Skills.workshop_batches(market_of(id)))

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

func _can_make(storage: RefCounted, key: String, good: String) -> String:
	var r := Goods.recipe(good)
	for c in r.keys():
		if storage.amount(key, str(c)) < int(r[c]):
			return "needs " + str(c)
	if storage.space(key, good) < out_units(good):
		return "storage full"
	return ""

## One cycle for every built workshop. craft: Callable(market: String, units: int), may be invalid (tests).
func run(storage: RefCounted, craft: Callable = Callable()) -> void:
	var key: String = storage.system_key(SYSTEM)
	for id in IDS:
		made[id] = {}
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

## "made 3 cells" text of the last cycle, "" when nothing.
func made_text(id: String) -> String:
	var parts: Array = []
	for g in made.get(id, {}).keys():
		parts.append("%d %s" % [int(made[id][g]), Ui.good_name(str(g)).to_lower()])
	return ", ".join(parts)

func to_dict() -> Dictionary:
	var d := {}
	for id in IDS:
		d[id] = {"built": bool(built[id]), "state": str(state[id]), "reason": str(reason[id]), "made": made[id].duplicate()}
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
		state[id] = str(d.get("state", "idle"))
		reason[id] = str(d.get("reason", ""))
		if typeof(d.get("made")) == TYPE_DICTIONARY:
			for g in d["made"].keys():
				made[id][str(g)] = int(d["made"][g])
