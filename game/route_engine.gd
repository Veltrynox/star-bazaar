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
var mix: Dictionary = {}      # N3: planet -> {goods, bonus} sold so far this cycle
var local: Dictionary = {}    # "<planet>|<c>" -> {planet, c, buy, sell, buy_state, sell_state}
var next_id: int = 1
var closed_planets: Array = []  # planet indexes closed (permits/events hook); runtime only
var debris_planets: Array = []  # T98: planets with debris; routes from them carry less (runtime, set by main)
var shield: RefCounted = null  # T101: solar shield (shield.gd), set by main
var learned: Array = []  # T82: learned skill ids, set by main; effects come from balance.json keys
var split_budget: Dictionary = {}  # N2: runtime, set at the start of each settle: lane key -> units its split share may take

func setup(bal: Dictionary, trade_logic: RefCounted, commodity_list: Array, storage_ref: RefCounted) -> void:
	balance = bal
	trade = trade_logic
	commodities = commodity_list
	storage = storage_ref

func reset() -> void:
	routes = []
	local = {}
	next_id = 1
	split_budget = {}

func new_record(src_planet: int, dst_planet: int, c: String) -> Dictionary:
	return {"id": 0, "src": "planet:%d" % src_planet, "dst": "planet:%d" % dst_planet,
		"a": src_planet, "b": dst_planet, "c": c, "ships": 1, "ship": "small", "level": 1, "orders": {},
		"fresh": 1.0, "state": "running", "reason": "", "split_to": -1, "split_share": 0.0}

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

## T145: a lane is full when its ships already move all that the source's standing Buy order can feed
## per cycle (ships x units per cycle >= local_amount). Another ship would add nothing; the route is upgraded instead.
func lane_full(src_planet: int, dst_planet: int, c: String) -> bool:
	var n := lane_count(src_planet, dst_planet, c)
	return n > 0 and n * units_per_cycle() >= local_amount()

## T145: route level of a lane (all ships of a lane share one level).
func lane_level(src_planet: int, dst_planet: int, c: String) -> int:
	var lv := 1
	for r in routes:
		if r["a"] == src_planet and r["b"] == dst_planet and r["c"] == c:
			lv = maxi(lv, int(r.get("level", 1)))
	return lv

## T145: true when the lane is full and still below the top tuned level (2): the route offers "Upgrade route".
func lane_upgrade_offered(src_planet: int, dst_planet: int, c: String) -> bool:
	return lane_full(src_planet, dst_planet, c) and lane_level(src_planet, dst_planet, c) < 2

## T145: sets every ship of the lane to the level.
func set_lane_level(src_planet: int, dst_planet: int, c: String, level: int) -> void:
	for r in routes:
		if r["a"] == src_planet and r["b"] == dst_planet and r["c"] == c:
			r["level"] = level

## T145: extra credits a delivery of `units` earns from the route level: per-unit margin x upgrade_margin_bonus x (level - 1).
func level_bonus(rec: Dictionary, units: int) -> int:
	var lv := int(rec.get("level", 1))
	if lv < 2 or units <= 0:
		return 0
	var per: int = sold_price(int(rec["b"]), str(rec["c"])) - local_price(int(rec["a"]), str(rec["c"]), "buy")
	if per <= 0 or local_price(int(rec["a"]), str(rec["c"]), "buy") < 0:
		return 0
	return roundi(float(units * per) * float(balance.get("upgrade_margin_bonus", 0.0)) * float(lv - 1))

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
	base *= Ships.cargo_mult(kind_of(rec), balance)  # T58
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

## N5: why Salvage is offered for c in this planet's storage: "" (not offered), "no_buyer" or "full". Needs stock and a sell price here.
func salvage_reason(planet: int, c: String) -> String:
	var key: String = storage.planet_key(planet)
	if storage.amount(key, c) <= 0 or sold_price(planet, c) <= 0:
		return ""
	var buyer: bool = local_on(planet, c, "sell")  # a standing Sell order here already moves the stock
	for rec in routes:
		if buyer:
			break
		if str(rec["src"]) == key and str(rec["c"]) == c and planet_open(int(rec["b"])) and local_on(int(rec["b"]), c, "sell"):
			buyer = true
	if not buyer:
		return "no_buyer"
	return "full" if storage.is_full(key, c) else ""

## N5: credits for what the Sell order would pay on this planet's stock (m) and for the salvage sale (n = salvage_share of it).
func salvage_offer(planet: int, c: String) -> Dictionary:
	var units: int = storage.amount(storage.planet_key(planet), c)
	var m: int = units * sold_price(planet, c)
	var share: float = minf(float(balance.get("salvage_share", 0.4)), 0.99)  # always below a Sell order
	return {"units": units, "n": mini(roundi(float(m) * share), maxi(m - 1, 0)), "m": m}

## Credits per unit a Sell order or a route's delivery earns. B3 Price Whisper adds skill_B3_margin; unlearned = the plain price.
func sold_price(planet: int, c: String) -> int:
	var p := local_price(planet, c, "sell")
	if p > 0 and learned.has("B3"):
		return roundi(float(p) * (1.0 + float(balance.get("skill_B3_margin", 0.0))))
	return p

## Credits per cycle a route earns on this lane: units a ship moves times (sell price at the far end, with B3, minus buy price here).
func route_margin(src: int, dst: int, c: String, level: int = 1) -> int:
	var b: int = trade.price(src, c + "_buy")
	var s: int = sold_price(dst, c)
	if b < 0 or s < 0:
		return 0
	var m: int = units_per_cycle() * (s - b)
	if level >= 2 and m > 0:  # T145: route upgrade
		m = roundi(float(m) * (1.0 + float(balance.get("upgrade_margin_bonus", 0.0)) * float(level - 1)))
	return m

## B1 Market Ledger: true when the lane earns less per cycle than it costs (trip and upkeep).
func margin_below_upkeep(src: int, dst: int, c: String) -> bool:
	return route_margin(src, dst, c) < fixed_cost()

## B1 Market Ledger: the open planet where carrying c from here earns most per unit, {planet, margin}; planet -1 when none pays.
func best_partner(src: int, c: String) -> Dictionary:
	var best := {"planet": -1, "margin": 0}
	for i in trade.planets.size():
		if i == src or not check_connection(src, i, c)["ok"]:
			continue
		var buy: int = trade.price(src, c + "_buy")
		var sell: int = sold_price(i, c)
		var m: int = sell - buy
		if buy >= 0 and sell >= 0 and m > int(best["margin"]):
			best = {"planet": i, "margin": m}
	return best

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
	var have: int = sell_available(planet, c)  # owner 2026-11-01: a Sell also draws from Space Storage
	if have <= 0:
		return {"n": 0, "credits": 0, "state": "Storage empty."}
	var m: int = mini(local_amount(), have)
	return {"n": m, "credits": m * sold_price(planet, c), "state": "Selling."}

# ---- routes ----

## Checks a new route (without the owned-ship pool; main adds that). {ok, reason}.
func check_connection(src: int, dst: int, c: String) -> Dictionary:
	if src == dst or src < 0 or dst < 0 or src >= trade.planets.size() or dst >= trade.planets.size():
		return {"ok": false, "reason": "Pick two different planets."}
	if not commodities.has(c):
		return {"ok": false, "reason": "Unknown commodity."}
	if not planet_open(src) or not planet_open(dst):
		return {"ok": false, "reason": "A planet on this route is closed."}
	if int(trade.planets[src].get("system", 1)) != int(trade.planets[dst].get("system", 1)) and not learned.has("C3"):
		return {"ok": false, "reason": StoryText.get_text("NOT_ROUTE_NEEDS_C3")}  # C3 Long Haul
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

## Stock a local Sell order can take at a planet: its storage plus the Space Storage of its system.
func sell_available(planet: int, c: String) -> int:
	var n: int = storage.amount(storage.planet_key(planet), c)
	var sk := space_key_for(planet)
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
	var lim := _split_limit(rec)  # N2: a split lane takes no more than its share of the stock
	if lim >= 0:
		units = mini(units, lim)
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

## N3 Mixed load (code name: bundle bonus). Bonus credits for a sale of `revenue` at a planet that already sold
## `goods_before` distinct goods this cycle with `bonus_before` bonus paid. First good gets none; per-planet cap.
func mixed_bonus(revenue: int, goods_before: int, bonus_before: int) -> int:
	if goods_before < 1 or revenue <= 0:
		return 0
	var cap := int(balance.get("bundle_bonus_cap", 0))
	return clampi(floori(revenue * float(balance.get("bundle_bonus_pct", 0.0))), 0, maxi(cap - bonus_before, 0))

## Applied percent of a mixed load bonus for a sale (after the cap), 0 when none.
static func mixed_pct(bonus: int, revenue: int) -> float:
	return snappedf(100.0 * bonus / revenue, 0.1) if revenue > 0 and bonus > 0 else 0.0

## Per good at this planet: {c: {bonus, revenue, pct}} for the Sell orders that would earn a bonus this cycle.
func mixed_preview(planet: int) -> Dictionary:
	var out := {}
	var goods := 0
	var paid := 0
	for o in local.values():
		if int(o["planet"]) != planet or not o["sell"]:
			continue
		var r := _local_calc(planet, str(o["c"]), "sell", 0)
		if int(r["n"]) <= 0:
			continue
		var rev := int(r["credits"])
		var b := mixed_bonus(rev, goods, paid)
		if b > 0:
			out[str(o["c"])] = {"bonus": b, "revenue": rev, "pct": mixed_pct(b, rev)}
		goods += 1
		paid += b
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
	mix = {}
	for o in orders:  # 1 local buys
		if o["buy"]:
			delta += _run_local(o, "buy", cash + delta, loc)
	_begin_split_budget()
	for rec in routes:  # 2 routes
		var was: String = str(rec["state"])
		var paid := _settle_one(rec, cash + delta)
		var bonus := int(rec.get("bonus", 0))
		delta += paid + bonus
		if paid < 0:
			upkeep_paid += upkeep_part(rec)
		if rec["state"] == "blocked" and was != "blocked":
			newly.append(rec)
		if rec["state"] == "stalled" and was != "stalled" and str(rec["reason"]) == "Source storage is empty.":
			newly_stalled.append(rec)
		rec["fresh"] = 1.0
		results.append({"id": rec["id"], "a": rec["a"], "b": rec["b"], "c": rec["c"], "ships": 1,
			"net": paid + bonus, "paid": paid + bonus, "status": rec["state"], "reason": rec["reason"]})
	for o in orders:  # 3 local sells
		if o["sell"]:
			delta += _run_local(o, "sell", cash + delta, loc)
	split_budget = {}
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
			var took: int = storage.remove(key, c, n)  # planet storage first, Space Storage covers the rest
			var sk := space_key_for(planet)
			if sk != "" and took < n:
				took += storage.remove(sk, c, n - took)
			n = took
			r["credits"] = n * sold_price(planet, c)
			var m: Dictionary = mix.get(planet, {"goods": 0, "bonus": 0})
			if n > 0:
				var b := mixed_bonus(int(r["credits"]), int(m["goods"]), int(m["bonus"]))
				r["credits"] = int(r["credits"]) + b
				mix[planet] = {"goods": int(m["goods"]) + 1, "bonus": int(m["bonus"]) + b}
	o[role + "_state"] = r["state"]
	out.append({"planet": planet, "c": c, "role": role, "n": n, "paid": int(r["credits"]), "state": r["state"]})
	return int(r["credits"])

func _settle_one(rec: Dictionary, cash: int) -> int:
	rec["bonus"] = 0
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
	_spend_split(rec, moved)  # N2
	rec["bonus"] = level_bonus(rec, from_planet)  # T145: credited by settle() on top of the ship cost
	rec["state"] = "running"
	rec["reason"] = ""
	return -fixed

## P2: the best open lane a closed-planet route's ship could move to, {a, b, net, setup_lost}; {} when none pays.
## window = closure cycles left on the closed planet. net = the new lane's per-cycle net (route_margin at level 1
## minus fixed_cost), scaled by (window - travel_cycles) / window: the idle transit cycles are taken out of the
## closure window. setup_lost is true when the route carries an upgrade, which a moved ship loses.
func best_open_lane(rec: Dictionary, window: int) -> Dictionary:
	var c := str(rec["c"])
	var idle: float = trade.travel_cycles()
	if window <= 0 or float(window) <= idle:
		return {}
	var fixed := fixed_cost(rec)
	var best := {}
	var best_net := 0
	for i in trade.planets.size():
		for j in trade.planets.size():
			if i == j or not planet_open(i) or not planet_open(j):
				continue
			if not check_connection(i, j, c)["ok"] or lane_full(i, j, c):
				continue
			var cand := new_record(i, j, c)
			if src_available(cand) <= 0 or (_dest_full(cand) and not has_outflow(j, c)):
				continue
			var gross := route_margin(i, j, c)
			var net := floori(float(gross - fixed) * (float(window) - idle) / float(window))
			if gross - fixed > 0 and net > best_net:
				best_net = net
				best = {"a": i, "b": j, "net": net, "setup_lost": int(rec.get("level", 1)) >= 2}
	return best

## P2: moves the stranded route record at index i onto lane a -> b. Keeps its id and its ship; the upgrade is lost.
func move_route(i: int, a: int, b: int) -> void:
	var rec: Dictionary = routes[i]
	var n := new_record(a, b, str(rec["c"]))
	rec["a"] = a
	rec["b"] = b
	rec["src"] = n["src"]
	rec["dst"] = n["dst"]
	rec["level"] = 1
	rec["state"] = "running"
	rec["reason"] = ""

## N2: a split Send divides the stock of one source and commodity between two lanes that already have ships.
## Every ship record of a split lane holds split_to (the partner lane's destination) and split_share (its fixed share).
## The first destination takes the share, the second takes the rest. Each leg still pays its own fixed cost.

## N2: the lane's split {to, share}, {} when the lane is not split.
func lane_split(src_planet: int, dst_planet: int, c: String) -> Dictionary:
	for r in routes:
		if r["a"] == src_planet and r["b"] == dst_planet and r["c"] == c and float(r["split_share"]) > 0.0:
			return {"to": int(r["split_to"]), "share": float(r["split_share"])}
	return {}

## N2: splits the source stock of c: first takes share, second takes 1 - share. Both lanes must already have ships.
func set_split(src_planet: int, first: int, second: int, c: String, share: float) -> void:
	_set_lane_split(src_planet, first, c, second, share)
	_set_lane_split(src_planet, second, c, first, 1.0 - share)

func _set_lane_split(src_planet: int, dst_planet: int, c: String, to: int, share: float) -> void:
	for r in routes:
		if r["a"] == src_planet and r["b"] == dst_planet and r["c"] == c:
			r["split_to"] = to
			r["split_share"] = share

## N2: a share as a fraction for the Send line: "1/4", "1/2" or "3/4".
static func share_label(share: float) -> String:
	return {0.25: "1/4", 0.5: "1/2", 0.75: "3/4"}.get(snappedf(share, 0.01), "%d%%" % roundi(share * 100.0))

static func _lane_key(src_planet: int, dst_planet: int, c: String) -> String:
	return "%d>%d|%s" % [src_planet, dst_planet, c]

## N2: once per cycle, before routes move: each valid split lane may take its share of the stock its source holds now.
func _begin_split_budget() -> void:
	split_budget = {}
	for rec in routes:
		var key := _lane_key(int(rec["a"]), int(rec["b"]), str(rec["c"]))
		if not split_budget.has(key):
			var lim := _split_limit(rec)
			if lim >= 0:
				split_budget[key] = lim

## N2: the most units this lane may take from its source this cycle; -1 when the lane is not a valid split.
## A valid split has a partner lane that points back at it. When the partner cannot take stock, all of the source stock is open.
func _split_limit(rec: Dictionary) -> int:
	var a := int(rec["a"])
	var b := int(rec["b"])
	var c := str(rec["c"])
	var key := _lane_key(a, b, c)
	if split_budget.has(key):
		return int(split_budget[key])
	var sp := lane_split(a, b, c)
	if sp.is_empty():
		return -1
	var to := int(sp["to"])
	var back := lane_split(a, to, c)
	if back.is_empty() or int(back["to"]) != b or lane_count(a, to, c) <= 0:
		return -1
	if _split_partner_blocked(a, to, c):
		return src_available(rec)
	return floori(float(src_available(rec)) * float(sp["share"]))

## N2: true when the partner lane cannot take stock this cycle: a closed planet, or a full destination with no outflow.
func _split_partner_blocked(a: int, to: int, c: String) -> bool:
	if not planet_open(a) or not planet_open(to):
		return true
	return storage.is_full(storage.planet_key(to), c) and not has_outflow(to, c)

## N2: the units a moved split lane has used of its budget.
func _spend_split(rec: Dictionary, units: int) -> void:
	var key := _lane_key(int(rec["a"]), int(rec["b"]), str(rec["c"]))
	if split_budget.has(key):
		split_budget[key] = maxi(0, int(split_budget[key]) - units)

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
		var rec := new_record(a, b, c)  # old saves with a "large" ship type load as small
		rec["id"] = maxi(1, int(s.get("id", 0)))
		rec["level"] = maxi(1, int(s.get("level", 1)))
		rec["state"] = str(s.get("state", "running"))
		rec["reason"] = str(s.get("reason", ""))
		rec["split_to"] = int(s.get("split_to", -1))  # N2
		rec["split_share"] = clampf(float(s.get("split_share", 0.0)), 0.0, 1.0)
		rec["fresh"] =clampf(float(s.get("fresh", 1.0)), 0.0, 1.0) if typeof(s.get("fresh")) != TYPE_ARRAY else 1.0
		routes.append(rec)
		next_id = maxi(next_id, int(rec["id"]) + 1)
