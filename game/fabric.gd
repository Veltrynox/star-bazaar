extends RefCounted
## The fabric (design/proposals/2026-11-02-dead-planets.md sections 3 and 4): a standing order at the trading post
## (the system 1 space station) that turns dross and nullglass into Lattice Plate (id "plate", placeholder name).
## Needs skill MIN_1, then a one-time build cost. Every number is in balance.json: fabric_build_cost, fabric_in_dross,
## fabric_in_nullglass, fabric_out_plate, fabric_batches_per_cycle. The fabric moves goods only inside the company
## storage (system 1 Space Storage); it never moves credits during a cycle, so forecast and settle agree.
## Saved by main under "fabric": {built, state, reason}. Old saves: not built.

const SYSTEM := 1
const OUTPUT := "plate"
const INPUTS := ["dross", "nullglass"]  # check order for the stall reason

var balance: Dictionary = {}
var built := false
var state := "idle"     # idle | running | stalled
var reason := ""        # short stall text ("needs dross")
var made := 0           # plates made by the last cycle
var core_made := 0      # Null Cores built this run (at most null_core_max; rare)

func setup(bal: Dictionary) -> void:
	balance = bal
	built = false
	state = "idle"
	reason = ""
	made = 0
	core_made = 0

func build_cost() -> int:
	return maxi(0, int(balance.get("fabric_build_cost", 1500)))

func need_of(c: String) -> int:
	return maxi(0, int(balance.get("fabric_in_" + c, 0)))

func batches() -> int:
	if Chains.workshop_idle(Markets.market_of(OUTPUT)):  # event chain: the market's workshop is paused
		return 0
	return maxi(1, int(balance.get("fabric_batches_per_cycle", 1)) + Skills.workshop_batches(Markets.market_of(OUTPUT)) + Chains.workshop_extra(Markets.market_of(OUTPUT)))  # MIN_4

## Null Core (placeholder numbers in balance.json: null_core_in_plate, null_core_in_nullglass, null_core_build_cost, null_core_max).
func core_cost() -> int:
	return maxi(0, int(balance.get("null_core_build_cost", 0)))

func core_in(c: String) -> int:
	return maxi(0, int(balance.get("null_core_in_" + c, 0)))

func core_max() -> int:
	return maxi(0, int(balance.get("null_core_max", 1)))

func core_recipe_text() -> String:
	return "%d plate + %d nullglass -> 1 Null Core" % [core_in("plate"), core_in("nullglass")]

## Recipe as text, e.g. "2 dross + 1 nullglass -> 1 plate".
func recipe_text() -> String:
	return "%d dross + %d nullglass -> %d plate" % [need_of("dross"), need_of("nullglass"), maxi(1, int(balance.get("fabric_out_plate", 1)))]

## One cycle on the company storage. Makes up to fabric_batches_per_cycle batches while the inputs last.
func run(storage: RefCounted) -> void:
	made = 0
	if not built:
		state = "idle"
		reason = ""
		return
	var key: String = storage.system_key(SYSTEM)
	var out_n := maxi(1, int(balance.get("fabric_out_plate", 1)) + Skills.batch_yield(Markets.market_of(OUTPUT)))  # MIN_6
	var why := ""
	for b in batches():
		why = ""
		for c in INPUTS:
			if storage.amount(key, c) < need_of(c):
				why = "needs " + c
				break
		if why == "" and storage.space(key, OUTPUT) < out_n:
			why = "storage full"
		if why != "":
			break
		for c in INPUTS:
			storage.remove(key, c, need_of(c))
		made += storage.add(key, OUTPUT, out_n)
	if made > 0:
		Tech.add_crafted(Markets.market_of(OUTPUT), made)  # plate is a Minerals good: counts toward the Minerals techs
		state = "running"
		reason = ""
	else:
		state = "stalled"
		reason = why

func to_dict() -> Dictionary:
	return {"built": built, "state": state, "reason": reason, "core_made": core_made}

func from_dict(d) -> void:
	built = false
	state = "idle"
	reason = ""
	core_made = 0
	if typeof(d) != TYPE_DICTIONARY:
		return  # old saves: not built
	built = bool(d.get("built", false))
	state = str(d.get("state", "idle"))
	reason = str(d.get("reason", ""))
	core_made = clampi(int(d.get("core_made", 0)), 0, core_max())
