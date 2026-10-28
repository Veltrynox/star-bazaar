extends RefCounted
## Price and margin logic. T51 removed manual trading (cargo, flights, mission steps, buy/sell/send);
## what remains is the price lookup the T07 route engine builds on.
## Prices come from planets.json base_prices ("<commodity>_buy" is what the player pays,
## "<commodity>_sell" is what the player receives). Capacity and trip cost from balance.json.

var balance: Dictionary = {}
var planets: Array = []

func setup(bal: Dictionary, plist: Array) -> void:
	balance = bal
	planets = plist

## Price of a key such as "energy_buy" at planet i, or -1 if missing/UNKNOWN.
func price(i: int, key: String) -> int:
	if i < 0 or i >= planets.size() or typeof(planets[i]) != TYPE_DICTIONARY:
		return -1
	var prices = planets[i].get("base_prices")
	if typeof(prices) != TYPE_DICTIONARY:
		return -1
	var v = prices.get(key)
	return int(v) if (typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT) else -1

## Per-unit margin of carrying commodity c from planet `from` to planet `to`
## (sell price at `to` minus buy price at `from`), or 0 if either price is missing.
func margin(from: int, to: int, c: String) -> int:
	var b := price(from, c + "_buy")
	var s := price(to, c + "_sell")
	if b < 0 or s < 0:
		return 0
	return s - b

func capacity() -> int:
	return int(balance.get("cargo", 0))

func trip_cost() -> int:
	return int(balance.get("trip_cost", 0))

func travel_cycles() -> float:
	return maxf(0.0, float(balance.get("travel_cycles_per_leg", 1)))

func _name(i: int) -> String:
	if i < 0 or i >= planets.size():
		return "the planet"
	return str(planets[i].get("name", planets[i].get("id", "?")))
