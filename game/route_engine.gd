extends RefCounted
const StoryText := preload("res://game/story_text.gd")
const Ships := preload("res://game/ships.gd")
## T68: local orders and one-way routes.
## Local order (per planet and commodity, toggles buy / sell): every cycle a Buy order buys up to
## local_amount() units at the planet's buy price into that planet's company storage (until full or
## cash runs out); a Sell order sells up to local_amount() units from storage at the sell price.
## No ship needed. A full or empty storage idles the order with a short status, not an error.
## Route (optional): only MOVES stock storage -> storage with one auto-assigned ship, no prices.
## Route record: {id, src, dst, a, b, c, ships (always 1), level (hook), orders (hook), fresh (0..1
## first-cycle factor), state (running|stalled|blocked), reason}. Endpoints are container keys
## ("planet:<i>", see storage.gd); "a"/"b" hold the planet index (-1 when not a planet).
## Per cycle (settle): 1 local buys, 2 routes move units (full destination without outflow -> BLOCKED, red, notification (with outflow -> WAITING, neutral);
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
var debris_planets: Array = []  # T98: planets with debris; routes from them carry less (runtime, set by main)
var shield: RefCounted = null  # T101: solar shield (shield.gd), set by main
var learned: Array = []  # T82: learned skill ids, set by main; effects come from balance.json keys

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
		"a": src_planet, "b": dst_planet, "c": c, "ships": 1, "ship": "small", "level": 1, "orders": {},
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

## T87: ships on one identical lane (same source, destination, commodity).
func lane_count(src_planet: int, dst_planet: int, c: String) -> int:
	var n := 0
	for r in routes:
		if r["a"] == src_planet and r["b"] == dst_planet and r["c"] == c:
			n += 1
	return n

## T87: 1-based position of this record among the ships of its lane.
func lane_index(rec: Dictionary) -> int:
	var n := 0
	for r in routes:
		if r["a"] == rec["a"] and r["b"] == rec["b"] and r["c"] == rec["c"]:
			n += 1
			if int(r["id"]) == int(rec["id"]):
				return n
	return 1

func total_assigned() -> int:
	return routes.size()

## T58: routes served by a ship of this type.
func assigned_of(kind: String) -> int:
	var n := 0
	for r in routes:
		if str(r.get("ship", "small")) == kind:
			n += 1
	return n

static func kind_of(rec) -> String:
	return str(rec.get("ship", "small")) if typeof(rec) == TYPE_DICTIONARY else "small"

func planet_open(i: int) -> bool:
	return i >= 0 and i < trade.planets.size() and not closed_planets.has(i)

## Units a ship moves per cycle.
func units_per_cycle(rec = null) -> int:
	var base := float(trade.capacity()) / (2.0 * maxf(0.0001, trade.travel_cycles()))
	base *= Ships.cargo_mult(kind_of(rec), balance)  # T58: large ship carries more
	if learned.has("A4"):
		base *= 1.0 + float(balance.get("skill_A4_route_units", 0))
	return floori(base)

## Units a local Buy / Sell order handles per cycle (T82: order_amount, own key; B2 raises it).
## Shared pool: one order record per planet + commodity and role, so routes touching that storage share it.
func local_amount() -> int:
	var base := float(balance.get("order_amount", 0))
	if learned.has("B2"):
		base *= 1.0 + float(balance.get("skill_B2_order_units", 0))
	return floori(base)

## Fixed cost per cycle of a route that moves stock (trip + ship upkeep).
func fixed_cost(rec = null) -> int:
	return trip_part() + upkeep_part(rec)

## T69: trip cost part of the fixed cost.
func trip_part() -> int:
	return floori(float(trade.trip_cost()) / maxf(0.0001, trade.travel_cycles()))

## T69: ship upkeep part of the fixed cost (one ship per route, paid only while it moves stock).
func upkeep_part(rec = null) -> int:
	var upkeep := float(balance.get("maintenance", 0)) * Ships.upkeep_mult(kind_of(rec), balance)  # T58
	if learned.has("A5"):
		upkeep *= 1.0 - float(balance.get("skill_A5_upkeep", 0))
	return floori(upkeep / maxf(1.0, float(balance.get("maintenance_interval", 1))))

## T70: outflow at a destination = an enabled local Sell order for the commodity there, or an
## outgoing route from that storage for the commodity. Only then a full storage will drain.
func has_outflow(dst_planet: int, c: String) -> bool:
	if local_on(dst_planet, c, "sell"):
		return true
	for r in routes:
		if int(r["a"]) == dst_planet and str(r["c"]) == c:
			return true
	return false

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
			return {"n": 0, "credits": 0, "state": StoryText.get_text("NOT_STORAGE_FULL")}
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
	return {"ok": true, "reason": ""}  # T87: a second ship on the same lane is allowed

## T70: full destination, no source stock check: true when the route cannot add a unit now.
## T85: Space Storage of the source planet's system, "" when there is none (needs skill A1 and an established post).
func space_key_for(planet: int) -> String:
	if not learned.has("A1") or planet < 0 or planet >= trade.planets.size():
		return ""
	var k: String = storage.system_key(int(trade.planets[planet].get("system", 1)))
	return k if storage.established(k) else ""

## T85: stock a route can draw at its source: planet storage plus the Space Storage backup of that system.
func src_available(rec: Dictionary) -> int:
	var c := str(rec["c"])
	var n: int = storage.amount(str(rec["src"]), c)
	var sk := space_key_for(int(rec["a"]))
	return n + (storage.amount(sk, c) if sk != "" else 0)

func _dest_full(rec: Dictionary) -> bool:
	return storage.is_full(str(rec["dst"]), str(rec["c"]))

## Live state for display: closed planets and a full destination without outflow read blocked;
## a full destination with outflow reads waiting (neutral); otherwise the stored state.
func status_of(rec: Dictionary) -> String:
	if not planet_open(int(rec["a"])) or not planet_open(int(rec["b"])):
		return "blocked"
	if _dest_full(rec):
		if not has_outflow(int(rec["b"]), str(rec["c"])):
			return "blocked"
		if src_available(rec) > 0:
			return "waiting"
	return str(rec["state"])

func reason_of(rec: Dictionary) -> String:
	if not planet_open(int(rec["a"])) or not planet_open(int(rec["b"])):
		return "A planet on this route is closed."
	if _dest_full(rec):
		if not has_outflow(int(rec["b"]), str(rec["c"])):
			return "Destination storage is full."
		if src_available(rec) > 0:
			return waiting_text()
	return str(rec["reason"])

static func waiting_text() -> String:
	return StoryText.get_text("ST_WAITING_ROOM")

## T70: units the route would really move now (partial loads allowed).
func planned_units(rec: Dictionary) -> int:
	var c := str(rec["c"])
	var eff := 1.0
	if debris_planets.has(int(rec["a"])):  # T98: debris at the source planet
		eff = 1.0 - float(balance.get("debris_route_penalty", 0.0))
	if shield != null:  # T101: energy gain at planets bought after the shield
		eff *= float(shield.unit_factor(int(rec["a"]), c))
	var units := floori(units_per_cycle(rec) * clampf(float(rec["fresh"]), 0.0, 1.0) * eff)
	return maxi(0, mini(units, mini(src_available(rec), storage.space(str(rec["dst"]), c))))

## Projected net credits of the next cycle (display and cash forecast): the ship cost while it can move stock.
func payout_of(rec: Dictionary) -> int:
	if status_of(rec) == "blocked" or planned_units(rec) <= 0:
		return 0
	return -fixed_cost(rec)

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
	var newly_stalled: Array = []
	var delta := 0
	var upkeep_paid := 0
	var orders: Array = local.values()
	for o in orders:  # 1 local buys
		if o["buy"]:
			delta += _run_local(o, "buy", cash + delta, loc)
	for rec in routes:  # 2 routes
		var was: String = str(rec["state"])
		var paid := _settle_one(rec, cash + delta)
		delta += paid
		if paid < 0:
			upkeep_paid += upkeep_part(rec)
		if rec["state"] == "blocked" and was != "blocked":
			newly.append(rec)
		if rec["state"] == "stalled" and was != "stalled" and str(rec["reason"]) == "Source storage is empty.":
			newly_stalled.append(rec)
		rec["fresh"] = 1.0
		results.append({"id": rec["id"], "a": rec["a"], "b": rec["b"], "c": rec["c"], "ships": 1,
			"net": paid, "paid": paid, "status": rec["state"], "reason": rec["reason"]})
	for o in orders:  # 3 local sells
		if o["sell"]:
			delta += _run_local(o, "sell", cash + delta, loc)
	return {"delta": delta, "results": results, "local": loc, "newly_blocked": newly, "newly_stalled": newly_stalled,
		"upkeep": upkeep_paid, "gross": delta + upkeep_paid}

## T85: after the cycle's orders and routes, each planet storage of a system with a Space Storage passes up to
## planet_to_space_rate units per commodity into it (what is left over, never before the sells).
func feed_space() -> void:
	if not learned.has("A1"):
		return
	var rate := int(balance.get("planet_to_space_rate", 0))
	for i in trade.planets.size():
		var sk := space_key_for(i)
		var pk: String = storage.planet_key(i)
		if sk == "" or not storage.established(pk):
			continue
		for c in commodities:
			var n := mini(rate, mini(storage.amount(pk, c), storage.space(sk, c)))
			if n > 0:
				storage.remove(pk, c, n)
				storage.add(sk, c, n)

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
	var full: bool = storage.is_full(dst, c)
	if full and not has_outflow(int(rec["b"]), c):
		rec["state"] = "blocked"
		rec["reason"] = "Destination storage is full."
		return 0
	if src_available(rec) <= 0:
		rec["state"] = "stalled"
		rec["reason"] = "Source storage is empty."
		return 0
	if full:  # T70: outflow exists, so wait for room (neutral, no notification)
		rec["state"] = "waiting"
		rec["reason"] = waiting_text()
		return 0
	var fixed := fixed_cost(rec)
	if cash < fixed:
		rec["state"] = "stalled"
		rec["reason"] = "Not enough cash."
		return 0
	var moved := planned_units(rec)
	if moved <= 0:
		rec["state"] = "stalled"
		rec["reason"] = "Nothing to move."
		return 0
	var from_planet: int = storage.remove(src, c, moved)  # T85: the planet storage first, Space Storage covers the rest
	var sk := space_key_for(int(rec["a"]))
	if from_planet < moved and sk != "":
		from_planet += storage.remove(sk, c, moved - from_planet)
	storage.add(dst, c, from_planet)
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

func from_array(saved, owned_ships: int, owned_large: int = 0) -> void:
	reset()
	if typeof(saved) != TYPE_ARRAY:
		return
	var left := owned_ships
	var left_large := clampi(owned_large, 0, owned_ships)
	for s in saved:
		if typeof(s) != TYPE_DICTIONARY or left <= 0 or not s.has("c"):
			continue
		var a := int(s.get("a", -1))
		var b := int(s.get("b", -1))
		var c := str(s["c"])
		if not check_connection(a, b, c)["ok"]:
			continue
		left -= 1
		var kind := str(s.get("ship", "small"))  # T58: old saves hold small ships only
		if kind == "large" and left_large > 0:
			left_large -= 1
		else:
			kind = "small"
			if owned_ships - owned_large - assigned_of("small") <= 0:
				kind = "large"  # all small ships are taken; a free large one serves
		var rec := new_record(a, b, c)
		rec["ship"] = kind
		rec["id"] = maxi(1, int(s.get("id", 0)))
		rec["level"] = maxi(1, int(s.get("level", 1)))
		rec["state"] = str(s.get("state", "running"))
		rec["reason"] = str(s.get("reason", ""))
		rec["fresh"] = clampf(float(s.get("fresh", 1.0)), 0.0, 1.0) if typeof(s.get("fresh")) != TYPE_ARRAY else 1.0
		routes.append(rec)
		next_id = maxi(next_id, int(rec["id"]) + 1)
