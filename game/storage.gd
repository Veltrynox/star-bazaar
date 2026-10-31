extends RefCounted
## T55: stock held per container and commodity, all up to ONE shared capacity.
## Planet resources are infinite; storage is not. A container is addressed by a string
## key, so a later per-system space storage is just another container ("system:<n>") with
## its own capacity via capacity_of(); T55 only creates "planet:<i>" containers.
## Balance keys (data/balance.json, abstract numbers; code defaults apply until present):
##   storage_capacity (100), storage_start (fraction of capacity when established, 0).
## Route code (T56) calls add() for buy orders, remove() for sell orders. Stock changes only through orders.

const DEFAULT_CAPACITY := 100
const DEFAULT_START := 0.0  # T65: a new company starts with nothing stored

var balance: Dictionary = {}
var commodities: Array = []
var stock: Dictionary = {}  # container key -> {commodity: int}
var cuts: Dictionary = {}  # T109: container key -> capacity factor left (1.0 = untouched); asteroid hits

func setup(bal: Dictionary, planet_count: int, commodity_list: Array) -> void:
	balance = bal
	commodities = commodity_list
	cuts = {}
	reset(planet_count)

## T65: no container exists until the first order touching a planet creates it (ensure()).
func reset(_planet_count: int) -> void:
	stock = {}

func established(key: String) -> bool:
	return stock.has(key)

static func planet_key(i: int) -> String:
	return "planet:%d" % i

var capacity_mult := 1.0  # A2 Deep Holds: planet containers only; main sets it from the learned skills

## Seam for space storage: override per container kind here (e.g. "system:" bigger).
func capacity_of(key: String) -> int:
	if key.begins_with("system:"):  # T85: Space Storage, one per system
		return maxi(1, int(balance.get("space_storage_capacity", 500)))
	return maxi(1, int(round(int(balance.get("storage_capacity", DEFAULT_CAPACITY)) * float(cuts.get(key, 1.0)) * capacity_mult)))

## T109: cut the capacity of one container by pct (0.5 = half). Stock above the new capacity is lost.
func cut_capacity(key: String, pct: float) -> void:
	cuts[key] = clampf(float(cuts.get(key, 1.0)) * (1.0 - clampf(pct, 0.0, 1.0)), 0.0, 1.0)
	if not stock.has(key):
		return
	for c in commodities:
		stock[key][c] = mini(amount(key, c), capacity_of(key))

func cuts_to_dict() -> Dictionary:
	return cuts.duplicate()

func cuts_from_dict(saved) -> void:
	cuts = {}
	if typeof(saved) == TYPE_DICTIONARY:
		for k in saved.keys():
			cuts[str(k)] = clampf(float(saved[k]), 0.0, 1.0)

func ensure(key: String) -> void:
	if stock.has(key):
		return
	var start := int(round(capacity_of(key) * clampf(float(balance.get("storage_start", DEFAULT_START)), 0.0, 1.0)))
	var d := {}
	for c in commodities:
		d[c] = start
	stock[key] = d

func amount(key: String, c: String) -> int:
	if not stock.has(key):
		return 0
	return int(stock[key].get(c, 0))

func space(key: String, c: String) -> int:
	return capacity_of(key) - amount(key, c)

## Adds up to n units (buy order filling the storage). Returns units actually stored.
func add(key: String, c: String, n: int) -> int:
	ensure(key)
	var put := clampi(n, 0, space(key, c))
	stock[key][c] = amount(key, c) + put
	return put

## Removes up to n units (sell order draining it). Returns units actually taken.
func remove(key: String, c: String, n: int) -> int:
	var got := clampi(n, 0, amount(key, c))
	if got <= 0:
		return 0
	stock[key][c] = amount(key, c) - got
	return got

func is_full(key: String, c: String) -> bool:
	return amount(key, c) >= capacity_of(key)

func is_empty(key: String, c: String) -> bool:
	return amount(key, c) <= 0

## Rating 0-5 (5 = full, 0 = empty). Any stock above zero rates at least 1.
func rating(key: String, c: String) -> int:
	var a := amount(key, c)
	if a <= 0:
		return 0
	return clampi(ceili(5.0 * a / capacity_of(key)), 1, 5)

static func system_key(sys: int) -> String:
	return "system:%d" % sys

func planet_rating(i: int, c: String) -> int:
	return rating(planet_key(i), c)

func to_dict() -> Dictionary:
	return stock.duplicate(true)

## Old saves: no key = fresh stock. Unknown containers/commodities are kept only if known.
func from_dict(saved, planet_count: int) -> void:
	reset(planet_count)
	if typeof(saved) != TYPE_DICTIONARY:
		return
	for key in saved.keys():
		var d = saved[key]
		if typeof(d) != TYPE_DICTIONARY:
			continue
		ensure(str(key))
		for c in commodities:
			if d.has(c):
				stock[str(key)][c] = clampi(int(d[c]), 0, capacity_of(str(key)))
