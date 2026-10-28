extends RefCounted
## T68: local orders and one-way routes.
## Local order (per planet and commodity, toggles buy / sell): every cycle a Buy order buys up to
## local_amount() units at the planet's buy price into that planet's company storage (until full or
## cash runs out); a Sell order sells up to local_amount() units from storage at the sell price.
## No ship needed. A full or empty storage idles the order with a short status, not an error.
## Route (optional): only MOVES stock storage -> storage with one auto-assigned ship, no prices.
## Route record: {id, src, dst, a, b, c, ships (always 1), level (hook), orders (hook), fresh (0..1
## first-cycle factor), state (running|stalled|blocked), reason}. Endpoints are container keys
## ("planet:<i>", see storage.gd); "a"/"b" hold the planet index (-1 when not a planet).
## Per cycle (settle): 1 local buys, 2 routes move units (full destination -> BLOCKED, red, notification;
## empty source or no cash for the ship cost -> STALLED), 3 local sells.
## Route cost when it moves stock: floor(trip_cost / travel) + floor(maintenance / maintenance_interval).
## There is no saturation rule: storage fill is the only pressure. Stock changes only through orders and routes.

var balance: Dictionary = {}
var trade: RefCounted
var storage: RefCounted
var commodities: Array = []
var routes: Array = []        # Array of route records (Dictionary)
var local: Dictionary = {}    # "<planet>|<c>" -> {planet, c, buy, sell, buy_state, sell_state}
var next_id: int = 1
var closed_planets: Array = []  # planet indexes closed (permits/events hook); runtime only

func setup(bal: Dictionary, trade_logic: RefCounted, commodity_list: Array, storage_ref: RefCounted) -> void:
	balance = bal
	trade = trade_logic
	commodities = commodity_list
	storage = storage_ref

func reset() -> void:
	routes = []
	local = {}
	next_id = 1

func new_record(src_planet: int, dst_planet: int, c: String) -> Dictionary:
	return {"id": 0, "src": "planet:%d" % src_planet, "dst": "planet:%d" % dst_planet,
		"a": src_planet, "b": dst_planet, "c": c, "ships": 1, "level": 1, "orders": {},
		"fresh": 1.0, "state": "running", "reason": ""}

func find_by_id(id: int) -> int:
	for i in routes.size():
		if int(routes[i]["id"]) == id:
			return i
	return -1

func find_same(src_planet: int, dst_planet: int, c: String) -> int:
	for i in routes.size():
		var r: Dictionary = routes[i]
		if r["a"] == src_planet and r["b"] == dst_planet and r["c"] == c:
			return i
	return -1

func total_assigned() -> int:
	return routes.size()

func planet_open(i: int) -> bool:
	return i >= 0 and i < trade.planets.size() and not closed_planets.has(i)

## Units a ship moves per cycle.
func units_per_cycle() -> int:
	return floori(float(trade.capacity()) / (2.0 * maxf(0.0001, trade.travel_cycles())))

## Units a local Buy / Sell order handles per cycle. Abstract: the ship load size (economy-designer sets it later).
func local_amount() -> int:
	return trade.capacity()

## Fixed cost per cycle of a route that moves stock (trip + maintenance).
func fixed_cost() -> int:
	var t := maxf(0.0001, trade.travel_cycles())
	return floori(float(trade.trip_cost()) / t) \
		+ floori(float(balance.get("maintenance", 0)) / maxf(1.0, float(balance.get("maintenance_interval", 1))))

# ---- local orders ----

static func local_key(planet: int, c: String) -> String:
	return "%d|%s" % [planet, c]

## Order record for (planet, c); creates an empty one when `create`.
func local_of(planet: int, c: String, create: bool = false) -> Dictionary:
	var k := local_key(planet, c)
	if not local.has(k) and create:
		local[k] = {"planet": planet, "c": c, "buy": false, "sell": false, "buy_state": "", "sell_state": ""}
	return local.get(k, {})

func local_on(planet: int, c: String, role: String) -> bool:
	return bool(local_of(planet, c).get(role, false))

func local_state(planet: int, c: String, role: String) -> String:
	return str(local_of(planet, c).get(role + "_state", ""))

## Checks a local order toggle. {ok, reason}.
func check_local(planet: int, c: String, role: String) -> Dictionary:
	if planet < 0 or planet >= trade.planets.size() or not commodities.has(c) or not ["buy", "sell"].has(role):
		return {"ok": false, "reason": "Unknown order."}
	if trade.price(planet, c + "_" + role) < 0:
		return {"ok": false, "reason": "%s is not traded here." % c.capitalize()}
	return {"ok": true, "reason": ""}

func set_local(planet: int, c: String, role: String, on: bool) -> Dictionary:
	var r := check_local(planet, c, role)
	if not r["ok"]:
		return r
	var o := local_of(planet, c, true)
	o[role] = on
	o[role + "_state"] = "" if not on else "Waiting for cycle end."
	if not o["buy"] and not o["sell"]:
		local.erase(local_key(planet, c))
	return r

func local_price(planet: int, c: String, role: String) -> int:
	return trade.price(planet, c + "_" + role)

## Units and credits a local order would handle now with `cash`. {n, credits (signed), state}.
func _local_calc(planet: int, c: String, role: String, cash: int) -> Dictionary:
	var key: String = storage.planet_key(planet)
	var price := local_price(planet, c, role)
	if not planet_open(planet):
		return {"n": 0, "credits": 0, "state": "Planet closed."}
	if price < 0:
		return {"n": 0, "credits": 0, "state": "Not traded here."}
	if role == "buy":
		if storage.space(key, c) <= 0:
			return {"n": 0, "credits": 0, "state": "Storage full."}
		var n: int = mini(local_amount(), storage.space(key, c))
		if price > 0:
			n = mini(n, floori(float(maxi(cash, 0)) / price))
		if n <= 0:
			return {"n": 0, "credits": 0, "state": "Not enough cash."}
		return {"n": n, "credits": -n * price, "state": "Buying."}
	var have: int = storage.amount(key, c)
	if have <= 0:
		return {"n": 0, "credits": 0, "state": "Storage empty."}
	var m: int = mini(local_amount(), have)
	return {"n": m, "credits": m * price, "state": "Selling."}

# ---- routes ----

## Checks a new route (without the owned-ship pool; main adds that). {ok, reason}.
func check_connection(src: int, dst: int, c: String) -> Dictionary:
	if src == dst or src < 0 or dst < 0 or src >= trade.planets.size() or dst >= trade.planets.size():
		return {"ok": false, "reason": "Pick two different planets."}
	if not commodities.has(c):
		return {"ok": false, "reason": "Unknown commodity."}
	if not planet_open(src) or not planet_open(dst):
		return {"ok": false, "reason": "A planet on this route is closed."}
	if find_same(src, dst, c) >= 0:
		return {"ok": false, "reason": "This route already exists."}
	return {"ok": true, "reason": ""}

## Live state for display: stored state, except closed planets and a full destination always read blocked.
func status_of(rec: Dictionary) -> String:
	if not planet_open(int(rec["a"])) or not planet_open(int(rec["b"])) or storage.is_full(str(rec["dst"]), str(rec["c"])):
		return "blocked"
	return str(rec["state"])

func reason_of(rec: Dictionary) -> String:
	if not planet_open(int(rec["a"])) or not planet_open(int(rec["b"])):
		return "A planet on this route is closed."
	if storage.is_full(str(rec["dst"]), str(rec["c"])):
		return "Destination storage is full."
	return str(rec["reason"])

## Projected net credits of the next cycle (display and cash forecast): the ship cost while it can move stock.
func payout_of(rec: Dictionary) -> int:
	if status_of(rec) == "blocked" or storage.amount(str(rec["src"]), str(rec["c"])) <= 0:
		return 0
	return -fixed_cost()

## Projected local order lines for the cash forecast: Array of [label, signed credits], for active orders.
func local_preview(cash: int) -> Array:
	var out: Array = []
	var cur := cash
	for o in local.values():
		for role in ["buy", "sell"]:
			if not o[role]:
				continue
			var r := _local_calc(int(o["planet"]), str(o["c"]), role, cur)
			cur += int(r["credits"])
			out.append(["%s %s at %s" % [role.capitalize(), o["c"], _pname(int(o["planet"]))], int(r["credits"]), str(r["state"])])
	return out

func _pname(i: int) -> String:
	return str(trade.planets[i].get("name", trade.planets[i].get("id", "?"))) if i >= 0 and i < trade.planets.size() else "?"

## Runs one cycle. Returns {delta: credits to add to cash, results: Array of route results
## {id, a, b, c, ships, net, paid, status, reason}, local: Array of {planet, c, role, n, paid, state},
## newly_blocked: Array of records that just blocked}.
func settle(cash: int) -> Dictionary:
	var results: Array = []
	var loc: Array = []
	var newly: Array = []
	var delta := 0
	var orders: Array = local.values()
	for o in orders:  # 1 local buys
		if o["buy"]:
			delta += _run_local(o, "buy", cash + delta, loc)
	for rec in routes:  # 2 routes
		var was: String = str(rec["state"])
		var paid := _settle_one(rec, cash + delta)
		delta += paid
		if rec["state"] == "blocked" and was != "blocked":
			newly.append(rec)
		rec["fresh"] = 1.0
		results.append({"id": rec["id"], "a": rec["a"], "b": rec["b"], "c": rec["c"], "ships": 1,
			"net": paid, "paid": paid, "status": rec["state"], "reason": rec["reason"]})
	for o in orders:  # 3 local sells
		if o["sell"]:
			delta += _run_local(o, "sell", cash + delta, loc)
	return {"delta": delta, "results": results, "local": loc, "newly_blocked": newly}

func _run_local(o: Dictionary, role: String, cash: int, out: Array) -> int:
	var planet := int(o["planet"])
	var c := str(o["c"])
	var r := _local_calc(planet, c, role, cash)
	var n := int(r["n"])
	var key: String = storage.planet_key(planet)
	if n > 0:
		if role == "buy":
			n = storage.add(key, c, n)  # first trade establishes the storage
			r["credits"] = -n * local_price(planet, c, role)
		else:
			n = storage.remove(key, c, n)
			r["credits"] = n * local_price(planet, c, role)
	o[role + "_state"] = r["state"]
	out.append({"planet": planet, "c": c, "role": role, "n": n, "paid": int(r["credits"]), "state": r["state"]})
	return int(r["credits"])

func _settle_one(rec: Dictionary, cash: int) -> int:
	var c := str(rec["c"])
	var src := str(rec["src"])
	var dst := str(rec["dst"])
	if not planet_open(int(rec["a"])) or not planet_open(int(rec["b"])):
		rec["state"] = "blocked"
		rec["reason"] = "A planet on this route is closed."
		return 0
	if storage.is_full(dst, c):
		rec["state"] = "blocked"
		rec["reason"] = "Destination storage is full."
		return 0
	if storage.amount(src, c) <= 0:
		rec["state"] = "stalled"
		rec["reason"] = "Source storage is empty."
		return 0
	var fixed := fixed_cost()
	if cash < fixed:
		rec["state"] = "stalled"
		rec["reason"] = "Not enough cash."
		return 0
	var units := floori(units_per_cycle() * clampf(float(rec["fresh"]), 0.0, 1.0))
	var moved := mini(units, mini(storage.amount(src, c), storage.space(dst, c)))
	if moved <= 0:
		rec["state"] = "stalled"
		rec["reason"] = "Nothing to move."
		return 0
	storage.remove(src, c, moved)
	storage.add(dst, c, moved)
	rec["state"] = "running"
	rec["reason"] = ""
	return -fixed

## Saved form / restore. Restore validates against planet count and the owned ship count.
func to_array() -> Array:
	return routes.duplicate(true)

func local_to_array() -> Array:
	return local.values().duplicate(true)

func local_from_array(saved) -> void:
	local = {}
	if typeof(saved) != TYPE_ARRAY:
		return
	for s in saved:
		if typeof(s) != TYPE_DICTIONARY or not s.has("c"):
			continue
		var p := int(s.get("planet", -1))
		var c := str(s["c"])
		for role in ["buy", "sell"]:
			if bool(s.get(role, false)) and check_local(p, c, role)["ok"]:
				set_local(p, c, role, true)
				local_of(p, c)[role + "_state"] = str(s.get(role + "_state", ""))

func from_array(saved, owned_ships: int) -> void:
	reset()
	if typeof(saved) != TYPE_ARRAY:
		return
	var left := owned_ships
	for s in saved:
		if typeof(s) != TYPE_DICTIONARY or left <= 0 or not s.has("c"):
			continue
		var a := int(s.get("a", -1))
		var b := int(s.get("b", -1))
		var c := str(s["c"])
		if not check_connection(a, b, c)["ok"]:
			continue
		left -= 1
		var rec := new_record(a, b, c)
		rec["id"] = maxi(1, int(s.get("id", 0)))
		rec["level"] = maxi(1, int(s.get("level", 1)))
		rec["state"] = str(s.get("state", "running"))
		rec["reason"] = str(s.get("reason", ""))
		rec["fresh"] = clampf(float(s.get("fresh", 1.0)), 0.0, 1.0) if typeof(s.get("fresh")) != TYPE_ARRAY else 1.0
		routes.append(rec)
		next_id = maxi(next_id, int(rec["id"]) + 1)
