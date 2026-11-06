extends RefCounted
const StoryText := preload("res://game/story_text.gd")
const Ships := preload("res://game/ships.gd")
const Ceos := preload("res://game/ceos.gd")
const Clusters := preload("res://game/clusters.gd")
const DeadWorlds := preload("res://game/dead_worlds.gd")
const SkillTree := preload("res://game/skill_tree.gd")
const RouteOffset := preload("res://game/route_offset.gd")
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
var mix: Dictionary = {}      # N3: planet -> {goods, bonus, mk} sold so far this cycle (mk: markets seen, common raws left out)
var sales_up_units: Dictionary = {}  # good -> units of sales_units sold at a planet with a price-up event this settle
var sales_units: Dictionary = {}  # Four Markets: good -> units sold this settle (Sell orders and stop sales); main feeds Markets
var local: Dictionary = {}    # "<planet>|<c>" -> {planet, c, buy, sell, buy_state, sell_state}
var next_id: int = 1
var closed_planets: Array = []  # planet indexes closed (permits/events hook); runtime only
var debris_planets: Array = []  # T98: planets with debris; routes from them carry less (runtime, set by main)
var dead_locked: Array = []  # planet indexes of dead worlds that are not open yet (before balance dead_unlock_cycle); runtime, set by main
var pirates_active := false  # runtime: true while a pirate volume cut is on (no pirate system yet; the Null Core is immune to it)
var upkeep_out: Callable = Callable()  # T227: (key, good, stock) -> units storage upkeep takes from this stock next cycle (set by main)
var trade_gate: Callable = Callable()  # owner 2026-11-03: planet -> bool, false when its system has no Space Storage post (set by main)
var suns_fn: Callable = Callable()  # route offset: () -> Array of [Vector3 position, float radius] per sun, set by main from the map
var positions_fn: Callable = Callable()  # route offset: () -> Array of world positions (Vector3) per planet index, set by main from the map
var clusters: RefCounted = null  # T156: asteroid clusters (clusters.gd), set by main; null = no mining
var cluster_budget: Dictionary = {}  # T156: runtime, set at the start of each settle: cluster index -> units it may still give this cycle
var fare_paid := false  # runtime, per settle: true once a route has run this cycle (see fare_for)
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
	# Manual Space Storage: a negative dst_planet is a station, -system id; dst is then that system's Space Storage key.
	var dkey: String = storage.system_key(-dst_planet) if dst_planet < 0 else "planet:%d" % dst_planet
	var skey := "planet:%d" % src_planet
	if Clusters.is_node(src_planet):  # T156: a cluster is the source; "a" holds its node id
		skey = "cluster:%s" % (str(clusters.items[Clusters.index_of(src_planet)]["id"]) if clusters != null and clusters.valid(Clusters.index_of(src_planet)) else "?")
	return {"id": 0, "src": skey, "dst": dkey,
		"a": src_planet, "b": dst_planet, "c": c, "ships": 1, "ship": Ships.fleet, "level": 1, "orders": {},
		"fresh": 1.0, "state": "running", "reason": "", "split_to": -1, "split_share": 0.0, "stop": -1}

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
	var feed: int = clusters.yield_per_cycle() if (Clusters.is_node(src_planet) and clusters != null) else local_amount()  # T156: a cluster feeds mining_yield_per_cycle
	return n > 0 and n * units_per_cycle() >= feed

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
	if int(rec["b"]) < 0:  # a send to Space Storage sells nothing
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
		if kind_of(r) == kind:  # one fleet type per run
			n += 1
	return n

## One fleet type per run: every ship is the type chosen at the start (Ships.fleet), whatever the record says.
static func kind_of(_rec) -> String:
	return Ships.fleet

## Refusal text when planet i is a dead world that has not opened yet ("" when it is open or not a dead world).
func dead_lock_reason(i: int) -> String:
	if not dead_locked.has(i):
		return ""
	return StoryText.get_or("PLANET_DEAD_LOCKED", "Opens at cycle {n}.", {"n": int(balance.get("dead_unlock_cycle", 0))})

## Skill refusal for mining at planet src ("" when allowed). Applies to every way of taking goods out of a dead world.
func dead_skill_reason(src: int) -> String:
	if src < 0 or src >= trade.planets.size():
		return ""
	var need := DeadWorlds.skill_for(trade.planets[src])
	if need != "" and not Skills.is_learned(need):
		if not SkillTree.in_run(need):  # a skill of another branch is never named
			return StoryText.get_or("NOT_DEAD_OTHER_BRANCH", "Mining here is closed to your company.")
		return StoryText.get_or("NOT_DEAD_NEEDS_SKILL", "Needs {skill}.", {"skill": SkillTree.skill_name(need)})
	return ""

## Null Core: true when this route's ship carries it.
static func has_core(rec) -> bool:
	return typeof(rec) == TYPE_DICTIONARY and bool(rec.get("core", false))

func planet_open(i: int) -> bool:
	return i >= 0 and i < trade.planets.size() and not closed_planets.has(i)

## Units a ship moves per cycle. A route record (or a good id) lets route_capacity_pct skills apply to that market.
func units_per_cycle(rec = null, good: String = "") -> int:
	var legs := 2.0 if has_stop(rec) else 1.0  # N9: a stop adds one more leg of travel
	var base := float(trade.capacity()) / (2.0 * maxf(0.0001, trade.travel_cycles()) * legs)
	base *= Ships.cargo_mult(kind_of(rec), balance)  # T58
	var carried := good if good != "" else (str(rec.get("c", "")) if typeof(rec) == TYPE_DICTIONARY else "")
	if carried != "":
		base *= Skills.route_capacity_mult(Markets.market_of(carried))
	base *= ceo_lane_mult(rec)
	return floori(base)

## CEO perk route_capacity_pct (target first_lane): the lane of the first route runs this much more units per cycle.
func ceo_lane_mult(rec) -> float:
	var pct := Ceos.first_lane_pct()
	if pct <= 0.0 or typeof(rec) != TYPE_DICTIONARY or not rec.has("a") or routes.is_empty():
		return 1.0
	var first = routes[0]
	if typeof(first) == TYPE_DICTIONARY and int(first.get("a", -1)) == int(rec["a"]) and int(first.get("b", -2)) == int(rec["b"]):
		return 1.0 + pct
	return 1.0

## MIN_2: an ore order is limited by storage room, cash and stock only, not by the order-size cap.
const ORE_UNCAPPED := 1000000

## Units a local Buy / Sell order handles per cycle (T82: order_amount, own key; order_size_pct skills raise it).
## Shared pool: one order record per planet + commodity and role, so routes touching that storage share it.
func local_amount(good: String = "") -> int:
	var base := floori(float(balance.get("order_amount", 0)) * Skills.order_size_mult())
	if good == "ore" and Skills.ore_free_slots():  # MIN_2: ore does not count against the order-size cap
		return ORE_UNCAPPED
	return base

## Fixed cost per cycle of a route that moves stock (trip + ship upkeep).
func fixed_cost(rec = null) -> int:
	var tp := trip_part(rec)
	if has_core(rec):  # Null Core: the fitted ship's trips cost null_core_trip_mult of normal
		tp = floori(float(tp) * float(balance.get("null_core_trip_mult", 1.0)))
	if is_cross_load(rec):  # Four Markets: a load of 2+ markets on one lane pays cross_load_trip_mult on trip cost
		tp = floori(float(tp) * float(balance.get("cross_load_trip_mult", 1.0)))
	return tp * (2 if has_stop(rec) else 1) + upkeep_part(rec)  # N9: a stop pays one more trip cost

## Four Markets: markets (common raws left out) carried by the routes on rec's lane (same a and b, any good).
func lane_markets(rec) -> Array:
	var out: Array = []
	if rec == null or not (rec is Dictionary) or not rec.has("a"):
		return out
	for r in routes:
		if int(r["a"]) == int(rec["a"]) and int(r["b"]) == int(rec["b"]):
			var m := _mk(str(r["c"]))
			if m != "" and not out.has(m):
				out.append(m)
	return out

## Four Markets: true when the lane of rec carries goods of two or more markets.
func is_cross_load(rec) -> bool:
	return lane_markets(rec).size() >= 2

## Four Markets: market of a good for the cross-load and bundle rules; "" for common raws and unknown goods.
func _mk(c: String) -> String:
	return "" if Markets.is_common(c) else Markets.market_of(c)

## Four Markets: would adding good c to the markets already seen at a planet make the load mixed (2+ markets)?
func _cross_with(seen: Array, c: String) -> bool:
	var m := _mk(c)
	return (seen.size() + (1 if (m != "" and not seen.has(m)) else 0)) >= 2

func _add_mk(seen: Array, c: String) -> Array:
	var m := _mk(c)
	var out := seen.duplicate()
	if m != "" and not out.has(m):
		out.append(m)
	return out

func _note_sale(c: String, n: int, planet: int = -1) -> void:
	if n > 0:
		sales_units[c] = int(sales_units.get(c, 0)) + n
		if planet >= 0 and trade.events != null and trade.events.price_up_at(planet, c):  # LUX_5 counts these extra
			sales_up_units[c] = int(sales_up_units.get(c, 0)) + n

## T69: trip cost part of the fixed cost.
func trip_part(rec = null) -> int:
	var tp := float(trade.trip_cost()) * Ships.trip_mult(kind_of(rec)) * (Chains.trip_cost_mult(int(rec.get("id", -1))) if rec is Dictionary else 1.0)  # event chain: one route's trip cost
	return floori(tp / maxf(0.0001, trade.travel_cycles()))

## Route offset of a route record: extra path length round other planets and crossing routes, as a share of the
## straight length (see route_offset.gd). 0.0 when the route is below route_offset_min_pct, has no positions, or
## rec is null. Positions come from positions_fn (the map); route income never looks at this.
func offset_of(rec = null) -> float:
	if rec == null or not positions_fn.is_valid() or not (rec is Dictionary) or not rec.has("a") or not rec.has("b") or from_cluster(rec):
		return 0.0
	var pos: Array = positions_fn.call()
	var others: Array = []
	for r in routes:
		if r is Dictionary and int(r.get("id", -1)) != int(rec.get("id", -2)) and not from_cluster(r):
			others.append([int(r["a"]), int(r["b"])])
	var skip: Array = [int(rec.get("stop", -1))]
	var o: float = RouteOffset.offset(int(rec["a"]), int(rec["b"]), pos, others, float(balance.get("route_offset_clearance", 0.0)), skip, (suns_fn.call() if suns_fn.is_valid() else []))
	if o < float(balance.get("route_offset_min_pct", 0.0)) or o <= 0.0:
		return 0.0
	return minf(o, float(balance.get("route_offset_max", 1.0)))

## Upkeep multiplier from the route offset: 1 + route_offset_maint_pct * offset (offset clamped to route_offset_max).
func offset_maint_mult(rec = null) -> float:
	return 1.0 + float(balance.get("route_offset_maint_pct", 0.0)) * offset_of(rec)

## T69: ship upkeep part of the fixed cost (one ship per route, paid only while it moves stock).
func upkeep_part(rec = null) -> int:
	var upkeep := float(balance.get("maintenance", 0))
	upkeep *= maxf(float(balance.get("upkeep_floor", 0.0)), Ships.upkeep_mult(kind_of(rec), balance) * Skills.upkeep_mult())  # ship type x skills x CEO thrift, floored
	upkeep *= offset_maint_mult(rec) * Chains.upkeep_mult()
	return floori(upkeep / maxf(1.0, float(balance.get("maintenance_interval", 1))))

## T70: outflow at a destination = an enabled local Sell order for the commodity there, or an
## outgoing route from that storage for the commodity. Only then a full storage will drain.
func has_outflow(dst_planet: int, c: String) -> bool:
	if dst_planet < 0:  # Space Storage: nothing drains it by itself
		return false
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
	if dead_lock_reason(planet) != "":
		return {"ok": false, "reason": dead_lock_reason(planet)}
	if role == "buy" and dead_skill_reason(planet) != "":  # buying at a dead world is mining it
		return {"ok": false, "reason": dead_skill_reason(planet)}
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

## Credits per unit a Sell order or a route's delivery earns. sale_price_pct skills raise it (cash only: share volume
## uses base values, Markets.add_sale); no skill = the plain price.
func sold_price(planet: int, c: String) -> int:
	var p := local_price(planet, c, "sell")
	var f := Skills.sale_price_mult(Markets.market_of(c)) * Chains.price_mult(Markets.market_of(c))
	if p > 0 and f != 1.0:
		return roundi(float(p) * f)
	return p

## Credits per cycle a route earns on this lane: units a ship moves times (sell price at the far end, with the sell-price skills, minus buy price here).
func route_margin(src: int, dst: int, c: String, level: int = 1) -> int:
	var b: int = trade.price(src, c + "_buy")
	var s: int = sold_price(dst, c)
	if b < 0 or s < 0:
		return 0
	var m: int = units_per_cycle(null, c) * (s - b)
	if level >= 2 and m > 0:  # T145: route upgrade
		m = roundi(float(m) * (1.0 + float(balance.get("upgrade_margin_bonus", 0.0)) * float(level - 1)))
	return m

## Low-margin warning (base game since T158): true when the lane earns less per cycle than it costs (trip and upkeep).
func margin_below_upkeep(src: int, dst: int, c: String) -> bool:
	return route_margin(src, dst, c) < fixed_cost()

## LUX_1 Price Whisper: the open planet where carrying c from here earns most per unit, {planet, margin}; planet -1 when none pays.
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
	if trade_gate.is_valid() and not bool(trade_gate.call(planet)):
		return {"n": 0, "credits": 0, "state": StoryText.get_or("LBL_TRADE_NEEDS_STATION", "Needs a Space Storage in this system.")}
	if role == "buy":
		if storage.space(key, c) <= 0:
			return {"n": 0, "credits": 0, "state": StoryText.get_text("NOT_STORAGE_FULL")}
		var n: int = mini(local_amount(c), storage.space(key, c))
		if price > 0:
			n = mini(n, floori(float(maxi(cash, 0)) / price))
		if n <= 0:
			return {"n": 0, "credits": 0, "state": no_cash_buy_text(price, cash)}
		return {"n": n, "credits": -n * price, "state": "Buying."}
	var have: int = sell_available(planet, c)  # owner 2026-11-01: a Sell also draws from Space Storage
	if have <= 0:
		return {"n": 0, "credits": 0, "state": "Storage empty."}
	var m: int = mini(local_amount(c), have)
	return {"n": m, "credits": m * sold_price(planet, c), "state": "Selling."}

# ---- routes ----

## Checks a new route (without the owned-ship pool; main adds that). {ok, reason}.
func check_connection(src: int, dst: int, c: String, new_route: bool = true) -> Dictionary:
	if Clusters.is_node(src):
		return check_cluster(src, dst, c, new_route)
	if dst < 0:  # manual Space Storage: dst = -system id
		return _check_station(src, -dst, c)
	if src == dst or src < 0 or dst < 0 or src >= trade.planets.size() or dst >= trade.planets.size():
		return {"ok": false, "reason": "Pick two different planets."}
	if not commodities.has(c):
		return {"ok": false, "reason": "Unknown commodity."}
	if not planet_open(src) or not planet_open(dst):
		return {"ok": false, "reason": "A planet on this route is closed."}
	if dead_lock_reason(src) != "":  # dead worlds open at balance dead_unlock_cycle: no route from or to one before it (saved routes too)
		return {"ok": false, "reason": dead_lock_reason(src)}
	if dead_lock_reason(dst) != "":
		return {"ok": false, "reason": dead_lock_reason(dst)}
	if new_route and dead_skill_reason(src) != "":  # dead world: mining needs its skill (see DeadWorlds.skill_for); saved routes stay
		return {"ok": false, "reason": dead_skill_reason(src)}
	if int(trade.planets[src].get("system", 1)) != int(trade.planets[dst].get("system", 1)) and not Skills.unlocked("permit_routes"):
		return {"ok": false, "reason": StoryText.get_text("NOT_ROUTE_NEEDS_C3")}
	return {"ok": true, "reason": ""}  # T87: a second ship on the same lane is allowed

## T156: a route that starts at a cluster. Needs the mining skill, a known cluster that still has ore (new routes only),
## a planet destination that is open, and FND_PERMIT for another system. Ore is free to load; the cost is the lane (fixed_cost).
func check_cluster(node: int, dst: int, c: String, new_route: bool = true) -> Dictionary:
	var i := Clusters.index_of(node)
	if clusters == null or not clusters.valid(i):
		return {"ok": false, "reason": "No such cluster."}
	if new_route and not Skills.unlocked("cluster_routes"):  # a saved route loads before the skills do and stays
		return {"ok": false, "reason": StoryText.get_or("NOT_MINING_NEEDS_SKILL", "Mining needs the Prospecting skill.")}
	if c != clusters.good_of(i) or not commodities.has(c):
		return {"ok": false, "reason": StoryText.get_or("NOT_CLUSTER_ONLY_ORE", "This cluster gives ore only.")}
	if new_route and clusters.left(i) <= 0:
		return {"ok": false, "reason": StoryText.get_or("NOT_CLUSTER_EMPTY", "This cluster is empty.")}
	var dst_system := 0
	if dst < 0:  # Space Storage station of system -dst (same rule as a planet: another system needs the permit routes skill)
		dst_system = -dst
		if not Availability.storage("space_storage"):
			return {"ok": false, "reason": "Pick a planet to deliver to."}
		var known := false
		for p in trade.planets:
			if int(p.get("system", 1)) == dst_system:
				known = true
		if not known:
			return {"ok": false, "reason": "No such system."}
	else:
		if dst >= trade.planets.size():
			return {"ok": false, "reason": "Pick a planet to deliver to."}
		if not planet_open(dst):
			return {"ok": false, "reason": "A planet on this route is closed."}
		if dead_lock_reason(dst) != "":
			return {"ok": false, "reason": dead_lock_reason(dst)}
		dst_system = int(trade.planets[dst].get("system", 1))
	if clusters.system_of(i) != dst_system and not Skills.unlocked("permit_routes"):
		return {"ok": false, "reason": StoryText.get_text("NOT_ROUTE_NEEDS_C3")}
	return {"ok": true, "reason": ""}

## T156: true when the route starts at a cluster.
static func from_cluster(rec) -> bool:
	return typeof(rec) == TYPE_DICTIONARY and Clusters.is_node(int(rec.get("a", -1)))

## T156: the source end is open: a planet that is not closed, or a cluster (clusters are never closed).
func src_open(rec: Dictionary) -> bool:
	return true if from_cluster(rec) else planet_open(int(rec["a"]))

## T156: units a cluster may still give this cycle: its yield cap shared by every ship, never more than is left.
func cluster_available(node: int) -> int:
	var i := Clusters.index_of(node)
	if clusters == null or not clusters.valid(i):
		return 0
	return mini(clusters.left(i), int(cluster_budget[i]) if cluster_budget.has(i) else clusters.yield_per_cycle())

## A send to the Space Storage of system sid. Open post is checked by main (space_post_open).
func _check_station(src: int, sid: int, c: String) -> Dictionary:
	if src < 0 or src >= trade.planets.size():
		return {"ok": false, "reason": "Pick a planet to send from."}
	if not commodities.has(c):
		return {"ok": false, "reason": "Unknown commodity."}
	if not planet_open(src):
		return {"ok": false, "reason": "A planet on this route is closed."}
	if dead_lock_reason(src) != "":
		return {"ok": false, "reason": dead_lock_reason(src)}
	if dead_skill_reason(src) != "":  # a send to Space Storage mines the world too (was a gate bypass)
		return {"ok": false, "reason": dead_skill_reason(src)}
	var known := false
	for p in trade.planets:
		if int(p.get("system", 1)) == sid:
			known = true
	if not known:
		return {"ok": false, "reason": "No such system."}
	if int(trade.planets[src].get("system", 1)) != sid and not Skills.unlocked("permit_routes"):
		return {"ok": false, "reason": StoryText.get_text("NOT_ROUTE_NEEDS_C3")}
	return {"ok": true, "reason": ""}

## True when the route's destination is a Space Storage.
static func to_station(rec: Dictionary) -> bool:
	return int(rec["b"]) < 0

## A planet end is open; a station end has no planet to close.
func dst_open(rec: Dictionary) -> bool:
	return int(rec["b"]) < 0 or planet_open(int(rec["b"]))

## N9 Stop-over sale: a route may name one stop on its path (rec["stop"], -1 when none).
## A planet counts as on the path when it lies strictly between src and dst and within STOP_PATH_PX map px of their line.
const STOP_PATH_PX := 40.0  # N9: tuning constant for the path test, not a balance key (owner to confirm)

static func has_stop(rec) -> bool:
	return typeof(rec) == TYPE_DICTIONARY and int(rec.get("stop", -1)) >= 0

## N9: true when planet `stop` lies on the path from src to dst (map position, see STOP_PATH_PX).
func stop_on_path(src: int, stop: int, dst: int) -> bool:
	var n: int = trade.planets.size()
	if src < 0 or dst < 0 or stop < 0 or src >= n or dst >= n or stop >= n or src == dst or stop == src or stop == dst:
		return false
	var a := _map_pos(src)
	var ab := _map_pos(dst) - a
	var len2 := ab.length_squared()
	if len2 <= 0.0:
		return false
	var p := _map_pos(stop)
	var t := (p - a).dot(ab) / len2
	if t <= 0.0 or t >= 1.0:
		return false
	return p.distance_to(a + ab * t) <= STOP_PATH_PX

func _map_pos(i: int) -> Vector2:
	var p = trade.planets[i]
	if typeof(p) != TYPE_DICTIONARY:
		return Vector2.ZERO
	return Vector2(float(p.get("x", 0)), float(p.get("y", 0)))

## N9: stops offered for a send src -> dst of commodity c: on the path, open, trading, with an enabled Sell order for c.
func stop_candidates(src: int, dst: int, c: String) -> Array:
	var out: Array = []
	for i in trade.planets.size():
		if not stop_on_path(src, i, dst) or not planet_open(i) or not local_on(i, c, "sell"):
			continue
		if sold_price(i, c) <= 0 or (trade_gate.is_valid() and not bool(trade_gate.call(i))):
			continue
		if check_connection(src, i, c)["ok"] and check_connection(i, dst, c)["ok"]:
			out.append(i)
	return out

## N9: a route's stop still buys: open, trading, and its Sell order for the commodity is on. Otherwise the load goes on whole.
func stop_open(rec: Dictionary) -> bool:
	var k := int(rec.get("stop", -1))
	if k < 0:
		return false
	var c := str(rec["c"])
	return planet_open(k) and local_on(k, c, "sell") and sold_price(k, c) > 0 and (not trade_gate.is_valid() or bool(trade_gate.call(k)))

## T70: full destination, no source stock check: true when the route cannot add a unit now.
## T85: Space Storage of the source planet's system, "" when there is none (needs FND_STORAGE and an established post).
func space_key_for(planet: int) -> String:
	if not Availability.storage("space_storage") or planet < 0 or planet >= trade.planets.size():
		return ""
	var k: String = storage.system_key(int(trade.planets[planet].get("system", 1)))
	return k if storage.established(k) else ""

## T85: stock a route can draw at its source: planet storage plus the Space Storage backup of that system.
func src_available(rec: Dictionary) -> int:
	if from_cluster(rec):  # T156
		return cluster_available(int(rec["a"]))
	var c := str(rec["c"])
	var n: int = storage.amount(str(rec["src"]), c)
	var sk := space_key_for(int(rec["a"]))
	if sk == str(rec["dst"]):  # a send to the station never draws from it
		sk = ""
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
	if not src_open(rec) or not dst_open(rec):
		return "blocked"
	if _dest_full(rec):
		if not has_outflow(int(rec["b"]), str(rec["c"])):
			return "blocked"
		if src_available(rec) > 0:
			return "waiting"
	return str(rec["state"])

func reason_of(rec: Dictionary) -> String:
	if not src_open(rec) or not dst_open(rec):
		return "A planet on this route is closed."
	if _dest_full(rec):
		if not has_outflow(int(rec["b"]), str(rec["c"])):
			return "Destination storage is full."
		if src_available(rec) > 0:
			return waiting_text()
	return str(rec["reason"])

## Row and map text of a route that could not pay its trip at the cycle end: the cost and the cash it was compared with.
## The route state is stored at settle, so "had" is the cash at that moment (start balance plus what earlier lines paid).
static func no_cash_route_text(need: int, have: int) -> String:
	return StoryText.get_or("ST_NO_CASH_ROUTE", "Not enough cash: needs {need} cr, had {have} cr.", {"need": need, "have": maxi(have, 0)})

## Text of a Buy order that could not buy one unit: the unit price and the cash left after the trip reserve.
static func no_cash_buy_text(price: int, free: int) -> String:
	return StoryText.get_or("ST_NO_CASH_BUY", "Not enough cash: one unit costs {price} cr, {free} cr free after trips.", {"price": price, "free": maxi(free, 0)})

static func waiting_text() -> String:
	return StoryText.get_text("ST_WAITING_ROOM")

## T70: units the route would really move now (partial loads allowed).
func planned_units(rec: Dictionary) -> int:
	var c := str(rec["c"])
	return maxi(0, mini(_route_cap(rec), mini(src_available(rec), storage.space(str(rec["dst"]), c))))

## Units a route may move per cycle before stock and room limits (efficiency, freshness, split share).
func _route_cap(rec: Dictionary) -> int:
	var c := str(rec["c"])
	var eff := 1.0
	var lane_end := int(rec["b"]) if from_cluster(rec) else int(rec["a"])  # T156: an ore lane has no source planet; debris at the delivery planet counts
	if debris_planets.has(lane_end) and not Skills.event_immune(Markets.market_of(c), "debris"):  # T98: debris at the source planet; MIL_3 makes Military goods immune
		eff = 1.0 - float(balance.get("debris_route_penalty", 0.0))
	if pirates_active and not has_core(rec):  # pirates cut trade volume; the Null Core ship is immune
		eff *= 1.0 - float(balance.get("pirate_volume_penalty", 0.0))
	var units := floori(units_per_cycle(rec) * clampf(float(rec["fresh"]), 0.0, 1.0) * eff)
	var lim := _split_limit(rec)  # N2: a split lane takes no more than its share of the stock
	if lim >= 0:
		units = mini(units, lim)
	return units

## Read-only projection of one storage key and commodity over the next cycle. Runs the cycle order
## (local buys, routes, local sells) on a scratch copy of the stock; nothing in the game changes.
## {in, out, after, capacity, parts}. `parts` lists every flow of `key`: {dir "in"|"out", kind "buy"|"route"|"sell", route id or -1,
## planet, backup (true when a source or Sell draws the Space Storage because the planet's own stock is short), n}; the in
## parts sum to `in`, the out parts to `out`. `cash` bounds buys and route costs (default: unlimited). Approximations:
## the cash of other commodities' orders is not tracked, split budgets use the live stock, and Mixed load
## and level bonuses (credits only) are ignored.
func project_storage(key: String, c: String, cash: int = 1 << 40) -> Dictionary:
	var cap: int = storage.capacity_of(key)
	var shadow := {}
	var tally := {"in": 0, "out": 0}
	var parts: Array = []
	var cur := cash
	var get_amt := func(k: String) -> int:
		return int(shadow[k]) if shadow.has(k) else storage.amount(k, c)
	var note := func(dir: String, kind: String, rid: int, planet: int, backup: bool, n: int) -> void:
		for p in parts:
			if p["dir"] == dir and p["kind"] == kind and int(p["route"]) == rid and int(p["planet"]) == planet and bool(p["backup"]) == backup:
				p["n"] = int(p["n"]) + n
				return
		parts.append({"dir": dir, "kind": kind, "route": rid, "planet": planet, "backup": backup, "n": n})
	var put := func(k: String, n: int, kind: String, rid: int, planet: int) -> void:
		shadow[k] = int(get_amt.call(k)) + n
		if k == key:
			tally["in"] += n
			note.call("in", kind, rid, planet, false, n)
	var take := func(k: String, n: int, kind: String, rid: int, planet: int, backup: bool) -> void:
		shadow[k] = int(get_amt.call(k)) - n
		if k == key:
			tally["out"] += n
			note.call("out", kind, rid, planet, backup, n)
	var orders: Array = local.values()
	for o in orders:  # 1 local buys
		if str(o["c"]) != c or not o["buy"]:
			continue
		var p := int(o["planet"])
		var price := local_price(p, c, "buy")
		if not planet_open(p) or price < 0 or (trade_gate.is_valid() and not bool(trade_gate.call(p))):
			continue
		var pk: String = storage.planet_key(p)
		var n: int = mini(local_amount(c), maxi(0, storage.capacity_of(pk) - int(get_amt.call(pk))))
		if price > 0:
			n = mini(n, floori(float(maxi(cur, 0)) / price))
		if n > 0:
			put.call(pk, n, "buy", -1, p)
			cur -= n * price
	var budget := {}  # split lanes: the live share, spent as lanes move
	for rec in routes:
		if str(rec["c"]) != c:
			continue
		var lk := _lane_key(int(rec["a"]), int(rec["b"]), c)
		if not budget.has(lk):
			var lim := _split_limit(rec)
			if lim >= 0:
				budget[lk] = lim
	for rec in routes:  # 2 routes
		if str(rec["c"]) != c or not src_open(rec) or not dst_open(rec):
			continue
		var src := str(rec["src"])
		var dst := str(rec["dst"])
		var sk := space_key_for(int(rec["a"]))
		if sk == dst:
			sk = ""
		var have: int = int(get_amt.call(src)) + (int(get_amt.call(sk)) if sk != "" else 0)
		if from_cluster(rec):
			have = src_available(rec)
		var room: int = maxi(0, storage.capacity_of(dst) - int(get_amt.call(dst)))
		if have <= 0 or room <= 0 or cur < fixed_cost(rec):
			continue
		var lk := _lane_key(int(rec["a"]), int(rec["b"]), c)
		var units := _route_cap(rec)
		if budget.has(lk):
			units = mini(units, int(budget[lk]))
		var moved: int = maxi(0, mini(units, mini(have, room)))
		if moved <= 0:
			continue
		cur -= fixed_cost(rec)
		if budget.has(lk):
			budget[lk] = maxi(0, int(budget[lk]) - moved)
		var from_planet: int = mini(moved, int(get_amt.call(src)))
		if from_planet > 0:
			take.call(src, from_planet, "route", int(rec["id"]), int(rec["a"]), false)
		if sk != "" and from_planet < moved:
			take.call(sk, moved - from_planet, "route", int(rec["id"]), int(rec["a"]), true)
		put.call(dst, moved, "route", int(rec["id"]), int(rec["a"]))
	for o in orders:  # 3 local sells
		if str(o["c"]) != c or not o["sell"]:
			continue
		var p := int(o["planet"])
		if not planet_open(p) or local_price(p, c, "sell") < 0 or (trade_gate.is_valid() and not bool(trade_gate.call(p))):
			continue
		var pk: String = storage.planet_key(p)
		var sk := space_key_for(p)
		var have: int = int(get_amt.call(pk)) + (int(get_amt.call(sk)) if sk != "" else 0)
		var n: int = mini(local_amount(c), have)
		if n <= 0:
			continue
		var from_planet: int = mini(n, int(get_amt.call(pk)))
		if from_planet > 0:
			take.call(pk, from_planet, "sell", -1, p, false)
		if sk != "" and from_planet < n:
			take.call(sk, n - from_planet, "sell", -1, p, true)
	if upkeep_out.is_valid():  # T227: declared upkeep (link) is the only other fixed drain; show it so the stock line adds up
		var un: int = mini(int(upkeep_out.call(key, c, int(get_amt.call(key)))), maxi(0, int(get_amt.call(key))))
		if un > 0:
			take.call(key, un, "upkeep", -1, -1, false)
	return {"in": int(tally["in"]), "out": int(tally["out"]), "after": clampi(int(get_amt.call(key)), 0, cap), "capacity": cap, "parts": parts}

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

## Fare a route pays this cycle. Normally the fixed cost. Stall rescue: when cash is below the fixed cost and no route has
## run yet this cycle, the ship flies for what cash is left (it can be 0), so a broke player is never stuck for good
## with no way to buy, run or earn. `paid_yet` is true once an earlier route ran this cycle. Returns -1 when the route stalls.
static func fare_for(fixed: int, cash: int, paid_yet: bool) -> int:
	if cash >= fixed:
		return fixed
	return -1 if paid_yet else maxi(cash, 0)

## Cash a Buy order must leave alone: the fixed cost (trip + upkeep) of every route that will run this cycle, in list
## order while `cash` still covers it. A route reserves only when its planets are open, its destination has room, and
## its source holds stock (`amt` reads stock) or an active Buy order feeds that source. Routes that cannot run reserve 0.
func route_reserve(cash: int, amt: Callable) -> int:
	var left := cash
	var total := 0
	for rec in routes:
		if not src_open(rec) or not dst_open(rec):
			continue
		var c := str(rec["c"])
		var dst := str(rec["dst"])
		if storage.capacity_of(dst) - int(amt.call(dst, c)) <= 0:
			continue
		var have := 0
		if from_cluster(rec):
			have = src_available(rec)
		else:
			var sk := space_key_for(int(rec["a"]))
			if sk == dst:
				sk = ""
			have = int(amt.call(str(rec["src"]), c)) + (int(amt.call(sk, c)) if sk != "" else 0)
		var fixed := fixed_cost(rec)
		if not from_cluster(rec) and have <= 0 and _buy_feeds(int(rec["a"]), c, left - fixed):
			have = 1  # fed only by a Buy that can still buy one unit after this reserve
		if have <= 0:
			continue
		if left < fixed:
			if total == 0 and left > 0:  # nothing else reserves: this route will run at a part fare (fare_for), keep that cash too
				total = left
				left = 0
			continue
		left -= fixed
		total += fixed
	return total

## True when an active Buy order at `planet` for `c` could put stock into storage this cycle and can pay for at least
## one unit out of `afford` (cash left after the reserve). A Buy that would buy nothing feeds nothing, so reserves nothing.
func _buy_feeds(planet: int, c: String, afford: int) -> bool:
	var o: Dictionary = local_of(planet, c)
	if o.is_empty() or not o["buy"] or not planet_open(planet) or local_price(planet, c, "buy") < 0:
		return false
	if afford < local_price(planet, c, "buy"):
		return false
	if trade_gate.is_valid() and not bool(trade_gate.call(planet)):
		return false
	return storage.space(storage.planet_key(planet), c) > 0

## Read-only forecast of the next settle() (cash forecast popup and top-bar delta). Runs the same order as
## settle (local buys, routes, local sells) on a scratch copy of the stock, so a Sell order sees the goods the
## routes deliver this cycle. Nothing in the game changes. Returns
## {local: Array of {label, role, planet, c, credits (signed), state}, routes: Array of {a, b, c, status,
## trip, upkeep (what a moving ship costs), gross (route bonus + stop sale, 0 when it moves nothing)},
## delta: net credits, as settle() would add}. Approximation: a cluster shared by ships is not split between them.
func forecast(cash: int) -> Dictionary:
	var shadow := {}
	var amt := func(k: String, c: String) -> int:
		var sk: String = k + "|" + c
		return int(shadow[sk]) if shadow.has(sk) else storage.amount(k, c)
	var delta := 0
	var loc: Array = []
	var res: Array = []
	var orders: Array = local.values()
	for o in orders:  # 1 local buys
		if not o["buy"]:
			continue
		var p := int(o["planet"])
		var c := str(o["c"])
		var price := local_price(p, c, "buy")
		var pk: String = storage.planet_key(p)
		var credits := 0
		var bought := 0
		var state := "Buying."
		if not planet_open(p):
			state = "Planet closed."
		elif price < 0:
			state = "Not traded here."
		elif trade_gate.is_valid() and not bool(trade_gate.call(p)):
			state = StoryText.get_or("LBL_TRADE_NEEDS_STATION", "Needs a Space Storage in this system.")
		else:
			var room: int = maxi(0, storage.capacity_of(pk) - int(amt.call(pk, c)))
			var n: int = mini(local_amount(c), room)
			if room <= 0:
				state = StoryText.get_text("NOT_STORAGE_FULL")
			else:
				if price > 0:
					n = mini(n, floori(float(maxi(cash + delta - route_reserve(cash + delta, amt), 0)) / price))
				if n <= 0:
					state = no_cash_buy_text(price, cash + delta - route_reserve(cash + delta, amt))
				else:
					shadow[pk + "|" + c] = int(amt.call(pk, c)) + n
					credits = -n * price
					bought = n
		delta += credits
		loc.append({"label": "Buy %s at %s" % [c, _pname(p)], "role": "buy", "planet": p, "c": c, "credits": credits, "state": state, "n": bought, "unit": maxi(price, 0)})
	var budget := {}
	for rec in routes:
		var lk := _lane_key(int(rec["a"]), int(rec["b"]), str(rec["c"]))
		if not budget.has(lk):
			var lim := _split_limit(rec)
			if lim >= 0:
				budget[lk] = lim
	var mixed := {}  # planet -> {goods, bonus}, as settle() keeps it
	var fare_seen := false  # as fare_paid in settle()
	for rec in routes:  # 2 routes
		var c := str(rec["c"])
		var src := str(rec["src"])
		var dst := str(rec["dst"])
		var line := {"id": int(rec.get("id", -1)), "a": int(rec["a"]), "b": int(rec["b"]), "c": c, "status": "running", "trip": trip_part(rec) * (2 if has_stop(rec) else 1), "upkeep": upkeep_part(rec), "gross": 0, "moves": false, "units": 0, "paid": 0}
		res.append(line)
		if not src_open(rec) or not dst_open(rec):
			line["status"] = "blocked"
			continue
		var room: int = maxi(0, storage.capacity_of(dst) - int(amt.call(dst, c)))
		if room <= 0:
			line["status"] = "blocked" if not has_outflow(int(rec["b"]), c) else "waiting"
			continue
		var sk := space_key_for(int(rec["a"]))
		if sk == dst:
			sk = ""
		var have: int = src_available(rec) if from_cluster(rec) else int(amt.call(src, c)) + (int(amt.call(sk, c)) if sk != "" else 0)
		if have <= 0:
			line["status"] = "stalled"
			continue
		var fixed := fare_for(fixed_cost(rec), cash + delta, fare_seen)
		if fixed < 0:
			line["status"] = "stalled"
			continue
		var lk := _lane_key(int(rec["a"]), int(rec["b"]), c)
		var units := _route_cap(rec)
		if budget.has(lk):
			units = mini(units, int(budget[lk]))
		var moved: int = maxi(0, mini(units, mini(have, room)))
		if moved <= 0:
			line["status"] = "stalled"
			continue
		if budget.has(lk):
			budget[lk] = maxi(0, int(budget[lk]) - moved)
		var carried := moved
		var sale := 0
		if not from_cluster(rec):
			var from_planet: int = mini(moved, int(amt.call(src, c)))
			shadow[src + "|" + c] = int(amt.call(src, c)) - from_planet
			if sk != "" and from_planet < moved:
				shadow[sk + "|" + c] = int(amt.call(sk, c)) - (moved - from_planet)
			if stop_open(rec):
				var sold := mini(moved, local_amount(c))
				sale = sold * sold_price(int(rec["stop"]), c)
				carried = moved - sold
		shadow[dst + "|" + c] = int(amt.call(dst, c)) + carried
		var gross := level_bonus(rec, carried) + sale
		line["gross"] = gross
		line["moves"] = true
		line["units"] = moved
		line["paid"] = fixed
		delta += gross - fixed
		fare_seen = true
	for o in orders:  # 3 local sells
		if not o["sell"]:
			continue
		var p := int(o["planet"])
		var c := str(o["c"])
		var pk: String = storage.planet_key(p)
		var credits := 0
		var sold_n := 0
		var state := "Selling."
		var price := local_price(p, c, "sell")
		if not planet_open(p):
			state = "Planet closed."
		elif price < 0:
			state = "Not traded here."
		elif trade_gate.is_valid() and not bool(trade_gate.call(p)):
			state = StoryText.get_or("LBL_TRADE_NEEDS_STATION", "Needs a Space Storage in this system.")
		else:
			var sk := space_key_for(p)
			var have: int = int(amt.call(pk, c)) + (int(amt.call(sk, c)) if sk != "" else 0)
			if have <= 0:
				state = "Storage empty."
			else:
				var n: int = mini(local_amount(c), have)
				var from_planet: int = mini(n, int(amt.call(pk, c)))
				shadow[pk + "|" + c] = int(amt.call(pk, c)) - from_planet
				if sk != "" and from_planet < n:
					shadow[sk + "|" + c] = int(amt.call(sk, c)) - (n - from_planet)
				credits = n * sold_price(p, c)
				sold_n = n
				var m: Dictionary = mixed.get(p, {"goods": 0, "bonus": 0, "mk": []})
				var b := mixed_bonus(credits, int(m["goods"]), int(m["bonus"]), _cross_with(m["mk"], c))
				credits += b
				mixed[p] = {"goods": int(m["goods"]) + 1, "bonus": int(m["bonus"]) + b, "mk": _add_mk(m["mk"], c)}
		delta += credits
		loc.append({"label": "Sell %s at %s" % [c, _pname(p)], "role": "sell", "planet": p, "c": c, "credits": credits, "state": state, "n": sold_n, "unit": sold_price(p, c)})
	_attribute_lanes(loc, res)
	return {"local": loc, "routes": res, "delta": delta}

## Lane result per cycle, added to each route line of forecast(): sale (what the units it carries fetch at the
## destination Sell order), cost (what those units cost at the source Buy order), net = sale + gross - cost - paid.
## Several lanes feeding one order share it by the units each carries: a lane's share of the units the order
## really buys or sells is units * min(1, order units / units all lanes carry there). Stock that was already
## there, mixed-load bonus and orders no lane feeds stay outside every lane (see lane_rest in the test).
func _attribute_lanes(loc: Array, res: Array) -> void:
	var into := {}  # "b|c" -> units all lanes carry to that destination
	var outof := {}  # "a|c" -> units all lanes take from that source
	for l in res:
		l["sale"] = 0
		l["cost"] = 0
		l["net"] = 0
		if not bool(l["moves"]):
			continue
		var kb := "%d|%s" % [int(l["b"]), str(l["c"])]
		var ka := "%d|%s" % [int(l["a"]), str(l["c"])]
		into[kb] = int(into.get(kb, 0)) + int(l["units"])
		outof[ka] = int(outof.get(ka, 0)) + int(l["units"])
	for l in res:
		if not bool(l["moves"]):
			continue
		var c := str(l["c"])
		var sale := 0
		var cost := 0
		for o in loc:
			if str(o["c"]) != c:
				continue
			if str(o["role"]) == "sell" and int(o["planet"]) == int(l["b"]) and int(o["n"]) > 0:
				var d := int(into["%d|%s" % [int(l["b"]), c]])
				sale = roundi(float(int(l["units"])) * minf(1.0, float(int(o["n"])) / d) * int(o["unit"]))
			elif str(o["role"]) == "buy" and int(o["planet"]) == int(l["a"]) and int(o["n"]) > 0:
				var d2 := int(outof["%d|%s" % [int(l["a"]), c]])
				cost = roundi(float(int(l["units"])) * minf(1.0, float(int(o["n"])) / d2) * int(o["unit"]))
		l["sale"] = sale
		l["cost"] = cost
		l["net"] = sale + int(l["gross"]) - cost - int(l["paid"])

## N3 Mixed load (code name: bundle bonus). Bonus credits for a sale of `revenue` at a planet that already sold
## `goods_before` distinct goods this cycle with `bonus_before` bonus paid. First good gets none; per-planet cap.
func mixed_bonus(revenue: int, goods_before: int, bonus_before: int, cross: bool = false) -> int:
	if goods_before < 1 or revenue <= 0 or cross:  # Four Markets: the bonus is for single-market loads only
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
	var seen: Array = []
	for o in local.values():
		if int(o["planet"]) != planet or not o["sell"]:
			continue
		var r := _local_calc(planet, str(o["c"]), "sell", 0)
		if int(r["n"]) <= 0:
			continue
		var rev := int(r["credits"])
		var b := mixed_bonus(rev, goods, paid, _cross_with(seen, str(o["c"])))
		if b > 0:
			out[str(o["c"])] = {"bonus": b, "revenue": rev, "pct": mixed_pct(b, rev)}
		goods += 1
		paid += b
		seen = _add_mk(seen, str(o["c"]))
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
	sales_units = {}
	sales_up_units = {}
	var amt_now := func(k: String, c: String) -> int: return storage.amount(k, c)
	for o in orders:  # 1 local buys; they may not spend the fixed cost of a route that runs this cycle
		if o["buy"]:
			delta += _run_local(o, "buy", cash + delta - route_reserve(cash + delta, amt_now), loc)
	_begin_split_budget()
	_begin_cluster_budget()
	fare_paid = false
	for rec in routes:  # 2 routes
		var was: String = str(rec["state"])
		var paid := _settle_one(rec, cash + delta)
		var bonus := int(rec.get("bonus", 0))
		delta += paid + bonus
		if paid < 0:
			upkeep_paid += upkeep_part(rec)
		if rec["state"] == "running":
			fare_paid = true
		if rec["state"] == "blocked" and was != "blocked":
			newly.append(rec)
		if rec["state"] == "stalled" and was != "stalled" and str(rec["reason"]) == "Source storage is empty.":
			newly_stalled.append(rec)
		rec["fresh"] = 1.0
		results.append({"id": rec["id"], "a": rec["a"], "b": rec["b"], "c": rec["c"], "ships": 1,
			"net": paid + bonus, "paid": paid + bonus, "stop": int(rec.get("stop", -1)), "stop_sale": int(rec.get("stop_sale", 0)), "status": rec["state"], "reason": rec["reason"]})
	for o in orders:  # 3 local sells
		if o["sell"]:
			delta += _run_local(o, "sell", cash + delta, loc)
	split_budget = {}
	cluster_budget = {}
	return {"delta": delta, "results": results, "local": loc, "newly_blocked": newly, "newly_stalled": newly_stalled,
		"upkeep": upkeep_paid, "gross": delta + upkeep_paid}

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
			var m: Dictionary = mix.get(planet, {"goods": 0, "bonus": 0, "mk": []})
			if n > 0:
				var b := mixed_bonus(int(r["credits"]), int(m["goods"]), int(m["bonus"]), _cross_with(m["mk"], c))
				r["credits"] = int(r["credits"]) + b
				mix[planet] = {"goods": int(m["goods"]) + 1, "bonus": int(m["bonus"]) + b, "mk": _add_mk(m["mk"], c)}
				_note_sale(c, n, planet)
	o[role + "_state"] = r["state"]
	out.append({"planet": planet, "c": c, "role": role, "n": n, "paid": int(r["credits"]), "state": r["state"]})
	return int(r["credits"])

func _settle_one(rec: Dictionary, cash: int) -> int:
	rec["bonus"] = 0
	rec["stop_sale"] = 0
	var c := str(rec["c"])
	var src := str(rec["src"])
	var dst := str(rec["dst"])
	if not src_open(rec) or not dst_open(rec):
		rec["state"] = "blocked"
		rec["reason"] = "A planet on this route is closed."
		return 0
	var full: bool = storage.is_full(dst, c)
	if full and not has_outflow(int(rec["b"]), c):
		rec["state"] = "blocked"
		rec["reason"] = "Destination storage is full."
		return 0
	if src_available(rec) <= 0:
		if from_cluster(rec):  # T156: empty cluster stalls the lane; the player removes it. A cluster shared by ships may only be out of its cycle yield.
			var empty: bool = clusters == null or clusters.left(Clusters.index_of(int(rec["a"]))) <= 0
			rec["state"] = "stalled" if empty else "waiting"
			rec["reason"] = StoryText.get_or("ST_CLUSTER_EMPTY", "The cluster is empty.") if empty else StoryText.get_or("ST_CLUSTER_SHARED", "Another ship took this cycle's ore.")
			return 0
		rec["state"] = "stalled"
		rec["reason"] = "Source storage is empty."
		return 0
	if full:  # T70: outflow exists, so wait for room (neutral, no notification)
		rec["state"] = "waiting"
		rec["reason"] = waiting_text()
		return 0
	var fixed := fare_for(fixed_cost(rec), cash, fare_paid)
	if fixed < 0:
		rec["state"] = "stalled"
		rec["reason"] = no_cash_route_text(fixed_cost(rec), cash)
		return 0
	var moved := planned_units(rec)
	if moved <= 0:
		rec["state"] = "stalled"
		rec["reason"] = "Nothing to move."
		return 0
	if from_cluster(rec):  # T156: the ship loads ore free at the cluster; it thins and never refills
		var got: int = clusters.take(Clusters.index_of(int(rec["a"])), moved)
		var bi := Clusters.index_of(int(rec["a"]))
		cluster_budget[bi] = maxi(0, (int(cluster_budget[bi]) if cluster_budget.has(bi) else clusters.yield_per_cycle()) - got)
		storage.add(dst, c, got)
		rec["stop_sale"] = 0
		rec["bonus"] = level_bonus(rec, got)
		rec["state"] = "running"
		rec["reason"] = ""
		return -fixed
	var from_planet: int = storage.remove(src, c, moved)  # T85: the planet storage first, Space Storage covers the rest
	var sk := space_key_for(int(rec["a"]))
	if sk == dst:  # a send to the station never draws from it
		sk = ""
	if from_planet < moved and sk != "":
		from_planet += storage.remove(sk, c, moved - from_planet)
	var carried := from_planet
	var sale := 0
	if stop_open(rec):  # N9: the stop buys up to its Sell order amount; the rest is carried on
		var sold := mini(from_planet, local_amount(c))
		sale = sold * sold_price(int(rec["stop"]), c)
		carried = from_planet - sold
		_note_sale(c, sold, int(rec["stop"]))
	storage.add(dst, c, carried)
	_spend_split(rec, moved)  # N2
	rec["stop_sale"] = sale  # N11: read by main to spot a first sale in system 2
	rec["bonus"] = level_bonus(rec, carried) + sale  # T145: credited by settle() on top of the ship cost; N9: stop sale
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
## The split ends when the partner lane has lost its ship: the stale share is cleared, so all remaining stock goes to this lane.
func lane_split(src_planet: int, dst_planet: int, c: String) -> Dictionary:
	for r in routes:
		if r["a"] == src_planet and r["b"] == dst_planet and r["c"] == c and float(r["split_share"]) > 0.0:
			var to := int(r["split_to"])
			if lane_count(src_planet, to, c) <= 0:
				clear_split(src_planet, c)
				return {}
			return {"to": to, "share": float(r["split_share"])}
	return {}

## Split bar: "Stop split" - every lane of this source and commodity goes back to normal sends.
func clear_split(src_planet: int, c: String) -> void:
	for r in routes:
		if r["a"] == src_planet and r["c"] == c:
			r["split_to"] = -1
			r["split_share"] = 0.0

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

## T156: each cluster gives at most mining_yield_per_cycle per cycle, shared by its ships.
func _begin_cluster_budget() -> void:
	cluster_budget = {}
	if clusters == null:
		return
	for i in clusters.items.size():
		cluster_budget[i] = clusters.yield_per_cycle()

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

var _core_loaded := false

func from_array(saved, owned_ships: int) -> void:
	reset()
	if typeof(saved) != TYPE_ARRAY:
		return
	var left := owned_ships
	_core_loaded = false
	for s in saved:
		if typeof(s) != TYPE_DICTIONARY or left <= 0 or not s.has("c"):
			continue
		var a := int(s.get("a", -1))
		var b := int(s.get("b", -1))
		var c := str(s["c"])
		if not check_connection(a, b, c, false)["ok"]:  # T156: a saved route from an emptied cluster stays (stalled)
			continue
		left -= 1
		var rec := new_record(a, b, c)  # old saves with a "large" ship type load as small
		rec["id"] = maxi(1, int(s.get("id", 0)))
		rec["level"] = maxi(1, int(s.get("level", 1)))
		rec["state"] = str(s.get("state", "running"))
		rec["reason"] = str(s.get("reason", ""))
		rec["core"] = bool(s.get("core", false)) and not _core_loaded  # Null Core: at most one fitted ship
		_core_loaded = _core_loaded or bool(rec["core"])
		rec["split_to"] = int(s.get("split_to", -1))  # N2
		rec["split_share"] = clampf(float(s.get("split_share", 0.0)), 0.0, 1.0)
		var stop := int(s.get("stop", -1))  # N9
		rec["stop"] = stop if stop_on_path(a, stop, b) else -1
		rec["fresh"] =clampf(float(s.get("fresh", 1.0)), 0.0, 1.0) if typeof(s.get("fresh")) != TYPE_ARRAY else 1.0
		routes.append(rec)
		next_id = maxi(next_id, int(rec["id"]) + 1)
