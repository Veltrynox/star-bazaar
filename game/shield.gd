extends RefCounted
## T101: partial solar shield. Built once (event EV18). It changes only planets that are not in the game yet
## when it is built (planets of systems opened by a permit later); planets present at build time (exempt_ids)
## never change. All numbers are balance.json keys: shield_build_cost, shield_energy_share_shift,
## shield_food_share_shift, shield_energy_gain, shield_profit_gain, shield_unhappiness.
## Reading of the keys (abstract, see handoff): share shifts scale that commodity's prices at an affected planet
## by (1 - shift) (more share = cheaper, less share = dearer); profit gain scales sell prices by (1 + gain);
## energy gain scales the units routes move from an affected planet; unhappiness is shown per affected planet.

var balance: Dictionary = {}
var built := false
var decided := false  # offer answered (built or skipped): EV18 is not offered again
var exempt_ids: Array = []  # planet ids present at build time
var planets: Array = []  # shared with map.planets (grows when a system opens)

func setup(bal: Dictionary, plist: Array) -> void:
	balance = bal
	planets = plist

func cost() -> int:
	return int(balance.get("shield_build_cost", 0))

func build(current_planets: Array) -> void:
	built = true
	decided = true
	exempt_ids = []
	for p in current_planets:
		exempt_ids.append(str(p.get("id", "")))

func skip() -> void:
	decided = true

func reset() -> void:
	built = false
	decided = false
	exempt_ids = []

func affects(i: int) -> bool:
	if not built or i < 0 or i >= planets.size():
		return false
	return not exempt_ids.has(str(planets[i].get("id", "")))

## Factor on the buy or sell price of key such as "energy_sell" at planet i (1.0 when unaffected).
func price_factor(i: int, key: String) -> float:
	if not affects(i):
		return 1.0
	var f := 1.0
	if key.begins_with("energy"):
		f *= 1.0 - float(balance.get("shield_energy_share_shift", 0.0))
	elif key.begins_with("food"):
		f *= 1.0 - float(balance.get("shield_food_share_shift", 0.0))
	if key.ends_with("_sell"):
		f *= 1.0 + float(balance.get("shield_profit_gain", 0.0))
	return f

## Factor on units moved from planet i of commodity c.
func unit_factor(i: int, c: String) -> float:
	if affects(i) and c == "energy":
		return 1.0 + float(balance.get("shield_energy_gain", 0.0))
	return 1.0

func unhappiness(i: int) -> float:
	return float(balance.get("shield_unhappiness", 0.0)) if affects(i) else 0.0

## Habitability flag per planet (data key "habitable", default true). Only used to decide which
## buyable planets the player may choose; the ending picker and ending structure do not read it.
static func habitable(p: Dictionary) -> bool:
	return bool(p.get("habitable", true))

func to_dict() -> Dictionary:
	return {"built": built, "decided": decided, "exempt": exempt_ids.duplicate()}

func from_dict(d) -> void:
	reset()
	if typeof(d) != TYPE_DICTIONARY:
		return
	built = bool(d.get("built", false))
	decided = bool(d.get("decided", false)) or built
	if typeof(d.get("exempt")) == TYPE_ARRAY:
		for x in d["exempt"]:
			exempt_ids.append(str(x))
