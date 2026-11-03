extends RefCounted
## The fabric (design/proposals/2026-11-02-dead-planets.md sections 3 and 4): a standing order at the trading post
## (the system 1 space station) that turns dross and nullglass into Lattice Plate (id "plate", placeholder name).
## Needs skill F1, then a one-time build cost. Every number is in balance.json: fabric_build_cost, fabric_in_dross,
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

func setup(bal: Dictionary) -> void:
	balance = bal
	built = false
	state = "idle"
	reason = ""
	made = 0

func build_cost() -> int:
	return maxi(0, int(balance.get("fabric_build_cost", 1500)))

func need_of(c: String) -> int:
	return maxi(0, int(balance.get("fabric_in_" + c, 0)))

func batches() -> int:
	return maxi(1, int(balance.get("fabric_batches_per_cycle", 1)))

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
	var out_n := maxi(1, int(balance.get("fabric_out_plate", 1)))
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
		state = "running"
		reason = ""
	else:
		state = "stalled"
		reason = why

func to_dict() -> Dictionary:
	return {"built": built, "state": state, "reason": reason}

func from_dict(d) -> void:
	built = false
	state = "idle"
	reason = ""
	if typeof(d) != TYPE_DICTIONARY:
		return  # old saves: not built
	built = bool(d.get("built", false))
	state = str(d.get("state", "idle"))
	reason = str(d.get("reason", ""))
