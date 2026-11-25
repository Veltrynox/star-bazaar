class_name Hubs
extends RefCounted
## T289 Hubs: a world at the hub tier keeps the needs of worlds in its reach fed (design 3.3).
## A hub owns a pool of ships taken from the free fleet. Each cycle, before the route engine settles, plan() makes one
## delivery record per short need (owner "hub:<planet>"): the cheapest established source in reach, up to the demand only,
## never surplus. The records live in `records` and are put into engine.routes only for the settle (begin_settle /
## end_settle), so they are never saved and never shown in route lists. They settle with the normal route engine.
## A delivery pays the buy price of the goods less hub_discount_pct (stock already owned in the source world's planet storage is free; Space Storage is never a hub source),
## the trip cost (the engine's fixed cost) and hub_fee_pct of the buy value (0 now, the path is kept). Manual routes into a world count first.
## Making a world a hub costs hub_build_cost once (main charges it; the Star Bazaar's takeover is free).
## The Star Bazaar hub: once the Bazaar is founded, its station IS the hub of its whole system. Its key in `hubs` is -system id (like a station
## destination); its reach is every world of that system (no distance check, no hub-tier check), it never draws on Space Storage, and no planet of
## that system can be made a hub any more. A planet hub standing there at founding moves into it (pool, ticked worlds, skipped needs).
## The Star Bazaar hub also feeds its own Space Storage ("system:<site>") from the worlds of its system, after the world needs: (1) the inputs
## the built workshops (and the Fabric) standing in that system need for this cycle's batches, minus what the storage holds, then (2) the short
## rows of the Bazaar's current stage bill (cheapest visible branch good of the tier that a world of the system sells), minus the units a
## workshop will consume. Exactly as much as needed, same sources, discount, pool ships and cash floor as the world deliveries; a good that
## serves both is one delivery of the sum. Priority when the pool or cash runs short: world needs, production inputs, bill. The goods land in the
## Space Storage (end_settle keeps them there) before workshops.run and bazaar.end_cycle, so the bill counts the same cycle.
## Pool caps: hub_pool_max (planet hub, 3) and hub_pool_max_bazaar (Star Bazaar hub, 10); pool_max(hub) picks one.
## All numbers: data/balance.json hub_* keys (placeholders). Text ids: ST_HUB_* via StoryText.get_or fallbacks.

const StoryText := preload("res://game/story_text.gd")
const Availability := preload("res://game/availability.gd")

var balance: Dictionary = {}
var engine: RefCounted = null        # RouteEngine
var prosperity: RefCounted = null    # Prosperity
var trade: RefCounted = null
var storage: RefCounted = null
var owned_ships_fn: Callable = Callable()  # () -> int, ships owned (set by main)
var bazaar_site_fn: Callable = Callable()  # () -> int, system id of the founded Star Bazaar or -1 (set by main)
var workshops: RefCounted = null     # Workshops (set by main): production inputs of the Bazaar hub
var fabric: RefCounted = null        # Fabric (set by main)
var bazaar: RefCounted = null        # Bazaar (set by main): the stage bill
var site_lines: Array = []           # last plan(): Space Storage deliveries [{kind "prod"|"bill", good, qty, status}] of the Bazaar hub
var _plan_left := 0
var _reserved := {}  # "planet:key|good" -> units this plan already earmarked out of that planet storage (one stock cannot feed two records)
var station_pos_fn: Callable = Callable()  # (system id) -> Vector3 of that system's station, Vector3.INF when none (set by main)
var hubs: Dictionary = {}            # planet index (or -system id for the Star Bazaar hub) -> {pool: int, on: Array of planet indexes the player added, skip_needs: Array of "planet|good"}
var records: Array = []              # this cycle's hub delivery records
var status: Dictionary = {}          # "planet|good" -> status code of the last plan(), see STATUS_*
var spent_last := 0                  # credits the last plan() paid for goods
var fee_last := 0                    # credits of fee the last end_settle() charged
var margin_last := {"value": 0, "cost": 0, "net": 0}  # Star Bazaar hub, last cycle, world deliveries only: value delivered, cost, net after the margin top-up
var commission_last := 0              # credits of hub commission the last end_settle() earned (all hubs); main adds it to cash
var delivered_last: Dictionary = {}  # hub planet -> units delivered at the last end_settle()

const STATUS_MET := "met"
const STATUS_ROUTE := "route"                # fed by your route
const STATUS_HUB := "hub"                    # fed by hub
const STATUS_NO_SOURCE := "short_source"     # no source in reach
const STATUS_NO_SHIP := "short_ship"         # no free ship in the pool
const STATUS_NO_CASH := "short_cash"
const STATUS_MANUAL := "manual"              # left off the hub

func setup(bal: Dictionary, eng: RefCounted, pros: RefCounted, trade_logic: RefCounted, storage_ref: RefCounted) -> void:
	balance = bal
	engine = eng
	prosperity = pros
	trade = trade_logic
	storage = storage_ref
	reset()

func reset() -> void:
	hubs = {}
	records = []
	status = {}
	site_lines = []
	spent_last = 0
	fee_last = 0
	commission_last = 0
	delivered_last = {}

func _bal(key: String, fallback: float) -> float:
	return float(balance.get(key, fallback))

func _pid(i: int) -> String:
	if i < 0:
		return "station:%d" % -i
	return str(trade.planets[i].get("id", "")) if i < trade.planets.size() else ""

func _system(i: int) -> int:
	if i < 0:
		return -i
	return int(trade.planets[i].get("system", 1)) if i < trade.planets.size() else -1

## True for the Star Bazaar hub (key -system id).
static func is_station_hub(h: int) -> bool:
	return h < 0

## Pool cap of hub key h: hub_pool_max_bazaar for the Star Bazaar hub, hub_pool_max for a planet hub.
func pool_max(h: int) -> int:
	return int(_bal("hub_pool_max_bazaar", 0)) if is_station_hub(h) else int(_bal("hub_pool_max", 0))

func bazaar_site() -> int:
	return int(bazaar_site_fn.call()) if bazaar_site_fn.is_valid() else -1

## Hub key of the Star Bazaar of system sys, or 0 when that system's hub is not the Bazaar (0 is never a station key).
func bazaar_hub_of_system(sys: int) -> int:
	return -sys if hubs.has(-sys) else 0

## Name of the hub for the panels: the planet's, or "Star Bazaar".
func hub_name(h: int, planet_name_fn: Callable) -> String:
	return StoryText.get_or("LBL_BAZAAR_STATION_NAME", "Star Bazaar") if h < 0 else str(planet_name_fn.call(h))

## ---- Designate, pool, release ----
func is_hub(planet: int) -> bool:
	return hubs.has(planet)

func hub_planets() -> Array:
	var out: Array = hubs.keys()
	out.sort()
	return out

func pool_of(planet: int) -> int:
	return int(hubs[planet]["pool"]) if hubs.has(planet) else 0

## Worlds the hub is switched on for (the hub world itself always counts); the hub panel alert and the map mark read this.
func ticked_count(h: int) -> int:
	var n := 0
	for w in worlds_in_reach(h):
		if not is_world_off(h, w):
			n += 1
	return n

## True when the hub should deliver (a ticked world) but its ship pool is empty.
func needs_ship(h: int) -> bool:
	return hubs.has(h) and pool_of(h) <= 0 and ticked_count(h) > 0

func hubs_needing_ship() -> Array:
	var out: Array = []
	for h in hub_planets():
		if needs_ship(h):
			out.append(h)
	return out

func pool_total() -> int:
	var n := 0
	for p in hubs:
		n += int(hubs[p]["pool"])
	return n

## True when the Star Bazaar stands in system sys (founded there): that system's hub is the Bazaar.
func bazaar_covers(sys: int) -> bool:
	return bazaar_site() >= 0 and bazaar_site() == sys

func hub_in_system(sys: int) -> int:
	var n := 0
	for p in hubs:
		if _system(int(p)) == sys:
			n += 1
	return n

## {ok, reason}: the world stands at hub_tier or above and its system has room for one more hub.
func can_designate(planet: int) -> Dictionary:
	if planet < 0 or planet >= trade.planets.size():
		return {"ok": false, "reason": StoryText.get_or("ST_HUB_NO_WORLD", "No such world.")}
	if hubs.has(planet):
		return {"ok": false, "reason": StoryText.get_or("ST_HUB_ALREADY", "This world is already a hub.")}
	if bazaar_covers(_system(planet)):
		return {"ok": false, "reason": StoryText.get_or("ST_HUB_BAZAAR_SYSTEM", "The Star Bazaar is the hub of this system.")}
	if prosperity.tier(planet) < int(_bal("hub_tier", 3)):
		return {"ok": false, "reason": StoryText.get_or("ST_HUB_TIER", "The world must reach tier {tier} first.", {"tier": int(_bal("hub_tier", 3))})}
	if hub_in_system(_system(planet)) >= int(_bal("hub_max_per_system", 1)):
		return {"ok": false, "reason": StoryText.get_or("ST_HUB_SYSTEM_FULL", "This system already has its hub.")}
	return {"ok": true, "reason": ""}

## Credits Make hub costs (hub_build_cost), once per world made a hub; releasing gives nothing back. Main takes the cash.
func build_cost() -> int:
	return maxi(0, int(_bal("hub_build_cost", 0)))

func designate(planet: int) -> Dictionary:
	var r := can_designate(planet)
	if bool(r["ok"]):
		hubs[planet] = {"pool": 0, "on": [], "skip_needs": [], "age": 0, "moved": 0}  # no world is served until the player ticks it (owner 2026-11-13)
	return r

## The Star Bazaar takes over the hub of its system (free). A planet hub standing in that system moves in: its pool ships, its ticked worlds
## (plus the old hub world itself, which was served implicitly) and its skipped needs; the planet hub is removed. Worlds start unticked for a fresh Bazaar hub.
## Returns true when the Bazaar hub now exists.
func take_over_system(sys: int) -> bool:
	if sys < 0 or hubs.has(-sys):
		return hubs.has(-sys)
	var entry := {"pool": 0, "on": [], "skip_needs": []}
	for p in hub_planets():
		if p >= 0 and _system(p) == sys:
			var old: Dictionary = hubs[p]
			entry["pool"] = int(old["pool"])
			for w in old["on"]:
				if not entry["on"].has(w):
					entry["on"].append(w)
			if not entry["on"].has(p):
				entry["on"].append(p)  # the old hub world was served implicitly
			for k in old["skip_needs"]:
				entry["skip_needs"].append(str(k))
			hubs.erase(p)
	hubs[-sys] = entry
	return true

## Ships the player could still put into pools (owned - on routes - already pooled).
func free_for_pool() -> int:
	var owned: int = int(owned_ships_fn.call()) if owned_ships_fn.is_valid() else 0
	return maxi(0, owned - engine.total_assigned() - pool_total())

## Sets the pool of a hub; more ships come from the free fleet (never more than free), fewer go back to it.
## Returns the pool size after the change.
func set_pool(planet: int, n: int) -> int:
	if not hubs.has(planet):
		return 0
	var cur := pool_of(planet)
	var want := clampi(n, 0, pool_max(planet))
	want = mini(want, cur + free_for_pool())
	hubs[planet]["pool"] = want
	return want

## Releases a hub; its pool ships return to the free fleet.
func release(planet: int) -> void:
	hubs.erase(planet)  # T290: the pool is part of the entry, so free_for_pool() counts those ships as free again

## Tier of a hub no longer standing (post lost) keeps the hub; only a release removes it.
## Worlds in reach start off: the hub serves only the worlds the player ticked (owner 2026-11-13), plus its own world.
func set_world_off(hub: int, world: int, off: bool) -> void:
	if not hubs.has(hub):
		return
	var arr: Array = hubs[hub]["on"]
	if not off and not arr.has(world):
		arr.append(world)
	elif off:
		arr.erase(world)

func set_need_off(hub: int, world: int, good: String, off: bool) -> void:
	if not hubs.has(hub):
		return
	var key := "%d|%s" % [world, good]
	var arr: Array = hubs[hub]["skip_needs"]
	if off and not arr.has(key):
		arr.append(key)
	elif not off:
		arr.erase(key)

func is_world_off(hub: int, world: int) -> bool:
	return hubs.has(hub) and world != hub and not hubs[hub]["on"].has(world)  # a Star Bazaar hub (negative key) never equals a world: its own system's worlds all need a tick

func is_need_off(hub: int, world: int, good: String) -> bool:
	return hubs.has(hub) and hubs[hub]["skip_needs"].has("%d|%s" % [world, good])

## ---- Reach ----
func reach_of(planet: int) -> float:
	if planet < 0:  # Star Bazaar hub: the distance to the farthest world of its system (ripples and shuttles scale to it); no ring is drawn
		var far := 0.0
		for i in trade.planets.size():
			if _system(i) == -planet:
				var d := distance(planet, i)
				if d < INF:
					far = maxf(far, d)
		return far
	var base := _bal("hub_reach_t%d" % prosperity.tier(planet), 0.0)
	return base + Bazaar.wing_bonus("hub_reach") if base > 0.0 else base  # T298 wings: only worlds that have a reach

func _pos(i: int) -> Variant:
	if i < 0:
		if not station_pos_fn.is_valid():
			return null
		var sp: Vector3 = station_pos_fn.call(-i)
		return null if sp == Vector3.INF else sp
	if not engine.positions_fn.is_valid():
		return null
	var pts: Array = engine.positions_fn.call()
	return pts[i] if i >= 0 and i < pts.size() else null

func distance(a: int, b: int) -> float:
	var pa = _pos(a)
	var pb = _pos(b)
	if pa == null or pb == null:
		return INF
	return (pa as Vector3).distance_to(pb as Vector3)

func in_reach(hub: int, world: int) -> bool:
	if hub < 0:  # Star Bazaar: every world of its system, no distance check
		return _system(world) == -hub
	return _system(hub) == _system(world) and distance(hub, world) <= reach_of(hub)

func worlds_in_reach(hub: int) -> Array:
	var out: Array = []
	for i in trade.planets.size():
		if prosperity.tier(i) >= 1 and in_reach(hub, i):
			out.append(i)
	return out

## Worlds that name this hub as their feeder (a need status of "hub" last plan).
func fed_by(world: int) -> int:
	for h in hubs:
		for g in _need_goods(world):
			if str(status.get("%d|%s|by" % [world, g], "")) == str(h):
				return int(h)
	return -1

func hub_fed(world: int) -> bool:
	return fed_by(world) >= 0

func _need_goods(world: int) -> Array:
	var out: Array = []
	for n in prosperity.needs(world):
		if not bool(n["locked"]):
			out.append(str(n["good"]))
	return out

## Status code of one need of a world ("" when never planned).
func status_of(world: int, good: String) -> String:
	return str(status.get("%d|%s" % [world, good], ""))

func status_text(code: String) -> String:
	match code:
		STATUS_ROUTE:
			return StoryText.get_or("ST_HUB_FED_ROUTE", "Fed by your route")
		STATUS_HUB:
			return StoryText.get_or("ST_HUB_FED_HUB", "Fed by hub")
		STATUS_NO_SOURCE:
			return StoryText.get_or("ST_HUB_SHORT_SOURCE", "Short: no source in reach")
		STATUS_NO_SHIP:
			return StoryText.get_or("ST_HUB_SHORT_SHIP", "Short: no free ship in pool")
		STATUS_NO_CASH:
			return StoryText.get_or("ST_HUB_SHORT_CASH", "Short: no cash")
		STATUS_MANUAL:
			return StoryText.get_or("ST_HUB_MANUAL", "Kept manual")
	return ""

## ---- Planning ----
func _manual_cover(world: int, good: String) -> int:
	var n := 0
	for rec in engine.routes:
		if str(rec.get("owner", "")) != "" or int(rec["b"]) != world or str(rec["c"]) != good:
			continue
		n += engine.planned_units(rec)
	return n

## Your own lanes and Sell orders that take goods from planet hub `hub`: [{kind "out"|"in"|"sell", good, from, to}] (planet indexes).
## out: a manual lane takes good G out of the world the hub buys G at. in: a manual lane carries G into a world the hub serves for G.
## sell: a Sell order for G at a world the hub serves. Lanes from clusters or Space Storages and into a Space Storage are not counted.
func competing_lanes(hub: int) -> Array:
	var out: Array = []
	if hub < 0 or not hubs.has(hub) or prosperity.tier(hub) < int(_bal("hub_tier", 3)):
		return out
	var seen := {}
	for w in worlds_in_reach(hub):
		if is_world_off(hub, w):
			continue
		for g in _need_goods(w):
			if is_need_off(hub, w, g):
				continue
			var src := _best_source(hub, w, g, 1)
			for rec in engine.routes:
				if str(rec.get("owner", "")) != "" or int(rec["a"]) < 0 or int(rec["b"]) < 0 or str(rec["c"]) != g:
					continue
				var kind := ""
				if int(rec["b"]) == w:
					kind = "in"
				elif not src.is_empty() and int(rec["a"]) == int(src["planet"]):
					kind = "out"
				if kind == "":
					continue
				var key := "%s|%d|%d|%s" % [kind, int(rec["a"]), int(rec["b"]), g]
				if not seen.has(key):
					seen[key] = true
					out.append({"kind": kind, "good": g, "from": int(rec["a"]), "to": int(rec["b"])})
			if engine.local_on(w, g, "sell"):
				var skey := "sell|%d|%s" % [w, g]
				if not seen.has(skey):
					seen[skey] = true
					out.append({"kind": "sell", "good": g, "from": w, "to": w})
	return out

## What a hub pays for a unit that costs `price` at the planet: hub_discount_pct below it (never below 1 credit).
func hub_price(price: int) -> int:
	if price <= 0:
		return price
	return maxi(1, roundi(float(price) * (100.0 - clampf(_bal("hub_discount_pct", 0.0), 0.0, 100.0)) / 100.0))

## Cheapest source for `qty` units of good for world, inside the hub's reach: {planet, price, stock} or {}.
## Stock already in the source's own planet storage costs nothing (Space Storage is never used); otherwise the planet's buy price.
func _best_source(hub: int, world: int, good: String, qty: int) -> Dictionary:
	var best := {}
	for p in worlds_in_reach(hub):
		if p == world or not engine.planet_open(p):
			continue
		if engine.dead_lock_reason(p) != "":
			continue
		var stock: int = _stock_at(p, good)
		var price: int = engine.local_price(p, good, "buy")
		var free_stock := stock >= qty
		if not free_stock and (price <= 0 or (engine.trade_gate.is_valid() and not bool(engine.trade_gate.call(p)))):
			continue
		price = hub_price(price)
		var cost := 0 if free_stock else price
		if best.is_empty() or cost < int(best["cost"]) or (cost == int(best["cost"]) and distance(p, world) < distance(int(best["planet"]), world)):
			best = {"planet": p, "price": price, "cost": cost, "free": free_stock}
	return best

## Plans this cycle's deliveries and buys their goods. Call once before engine.settle(); returns the credits spent
## (cash must be reduced by it). Needs of worlds in reach are filled up to their demand only.
## cash_floor is the ship cash floor (the fixed costs of the manual routes): a hub never buys below it, so it never runs debt.
func plan(cash: int, cash_floor: int = 0) -> int:
	records = []
	status = {}
	site_lines = []
	spent_last = 0
	_reserved = {}
	var left := cash - maxi(0, cash_floor)
	for h in hub_planets():
		if h >= 0 and prosperity.tier(h) < int(_bal("hub_tier", 3)):
			continue  # the world fell below the hub tier: it keeps its pool but runs nothing
		var ships := pool_of(h)
		var hold := 0  # Star Bazaar: a share of the budget is kept for its bill/workshop rows while the bill has short rows
		if h < 0 and h == -bazaar_site() and _bill_short():
			hold = clampi(floori(float(maxi(0, left)) * _bal("bazaar_bill_share_pct", 40.0) / 100.0), 0, maxi(0, left))
			left -= hold
		for w in worlds_in_reach(h):
			if is_world_off(h, w):
				for g in _need_goods(w):
					status["%d|%s" % [w, g]] = STATUS_MANUAL
				continue
			for n in prosperity.needs(w):
				if bool(n["locked"]):
					continue
				var g := str(n["good"])
				var key := "%d|%s" % [w, g]
				if is_need_off(h, w, g):
					status[key] = STATUS_MANUAL
					continue
				var short := int(n["demand"]) - int(n["sold"])
				if short <= 0:
					status[key] = STATUS_MET
					continue
				short -= _manual_cover(w, g)
				if short <= 0:
					status[key] = STATUS_ROUTE
					continue
				if status.has(key) and str(status[key]) == STATUS_HUB:
					continue  # another hub already feeds it
				var rec := _make_record(h, w, g, short)
				var src := _best_source(h, w, g, mini(short, engine.route_cap(rec)))
				if src.is_empty():
					status[key] = STATUS_NO_SOURCE
					continue
				if ships <= 0:
					status[key] = STATUS_NO_SHIP
					continue
				rec = _make_record(h, w, g, short, int(src["planet"]))
				var qty := mini(short, engine.route_cap(rec))
				if qty <= 0:
					status[key] = STATUS_NO_SOURCE
					continue
				var buy := 0
				if not bool(src["free"]):
					var have_stock := _stock_at(int(src["planet"]), g)
					buy = maxi(0, qty - have_stock) * int(src["price"])
				var fixed_w: int = int(engine.fixed_cost(rec))
				if buy + fixed_w > left and not bool(src["free"]) and int(src["price"]) > 0:
					var have_w := _stock_at(int(src["planet"]), g)
					qty = mini(qty, maxi(0, floori(float(left - fixed_w) / float(src["price"])) + have_w))  # buy what the budget allows
					buy = maxi(0, qty - have_w) * int(src["price"])
				if qty <= 0 or buy + fixed_w > left:
					status[key] = STATUS_NO_CASH
					continue
				ships -= 1
				left -= buy
				spent_last += buy
				rec["cap"] = qty
				rec["bought"] = maxi(0, qty - _stock_at(int(src["planet"]), g)) if buy > 0 else 0
				rec["unit_price"] = int(src["price"])
				if int(rec["bought"]) > 0:
					storage.add(str(rec["src"]), g, int(rec["bought"]))
				records.append(rec)
				_reserve(rec)
				status[key] = STATUS_HUB
				status[key + "|by"] = str(h)
		left += hold
		if h < 0 and h == -bazaar_site():  # the Star Bazaar also feeds its own Space Storage
			_plan_left = left
			ships = _plan_site(h, ships)
			left = _plan_left
	return spent_last

## True while the Star Bazaar's current stage bill has a short row the hub would buy for (Vault Cask rows are carried by Storage Links only).
func _bill_short() -> bool:
	if bazaar == null or not bazaar.is_founded() or bazaar.complete():
		return false
	for r in bazaar.bill_status():
		if str(r.get("kind", "")) != "cask" and int(r["have"]) < int(r["need"]):
			return true
	return false

## Space Storage deliveries of the Star Bazaar hub h (key -site): production inputs first, then the stage bill. Returns the pool ships left.
func _plan_site(h: int, ships: int) -> int:
	var key: String = storage.system_key(-h)
	var prod := _production_needs(-h, key)  # good -> units to deliver
	var held_used := {}                      # good -> units production consumes out of what the storage holds
	for g in prod["use"]:
		held_used[g] = int(prod["use"][g]) - int(prod["buy"].get(g, 0))
	var reqs: Array = []                     # [{good, qty, kinds: [..]}] in priority order
	for g in prod["buy"]:
		if int(prod["buy"][g]) > 0 and Availability.good(str(g)):
			reqs.append({"good": str(g), "prod": int(prod["buy"][g]), "bill": 0})
	if bazaar != null and bazaar.is_founded() and not bazaar.complete():
		for r in bazaar.bill_status():
			var have := int(r["have"])
			for g in r["goods"]:  # stock the workshops eat this cycle does not count as bill stock
				have -= maxi(0, mini(int(held_used.get(str(g), 0)), storage.amount(key, str(g))))
			var short := int(r["need"]) - have
			if short <= 0:
				continue
			if str(r.get("kind", "")) == "cask":
				continue  # Vault Cask rule: only a Storage Link brings it, the hub never buys or carries it
			var pick := _bill_good(h, r["goods"]) if r["goods"] != ["ore"] else "ore"  # ore row (own row, or Minerals' tier-1 row): held ore only, never bought
			if pick == "":
				continue
			var done := false
			for q in reqs:
				if str(q["good"]) == pick:
					q["bill"] = int(q["bill"]) + short
					done = true
			if not done:
				reqs.append({"good": pick, "prod": 0, "bill": short})
	for q in reqs:
		var g := str(q["good"])
		var want := int(q["prod"]) + int(q["bill"])
		var code := STATUS_HUB
		var qty := 0
		var rec := _make_record(h, h, g, want)
		var src := _best_source(h, h, g, mini(want, engine.route_cap(rec))) if g != "ore" else _ore_source(h)  # ore: held stock only, never bought
		if src.is_empty():
			code = STATUS_NO_SOURCE
		elif ships <= 0:
			code = STATUS_NO_SHIP
		else:
			rec = _make_record(h, h, g, want, int(src["planet"]))
			qty = mini(want, mini(engine.route_cap(rec), storage.space(key, g)))
			if g == "ore":
				qty = mini(qty, int(src["stock"]))
			if qty <= 0:
				code = STATUS_NO_SOURCE
			else:
				var buy := 0
				if not bool(src["free"]):
					buy = maxi(0, qty - _stock_at(int(src["planet"]), g)) * int(src["price"])
				var fixed_c: int = int(engine.fixed_cost(rec))
				if buy + fixed_c > _plan_left and not bool(src["free"]) and int(src["price"]) > 0:
					var afford := floori(float(_plan_left - fixed_c) / float(src["price"]))  # buy what the budget allows instead of nothing
					qty = mini(qty, maxi(0, afford + _stock_at(int(src["planet"]), g)))
					buy = maxi(0, qty - _stock_at(int(src["planet"]), g)) * int(src["price"])
				if qty <= 0 or buy + fixed_c > _plan_left:
					code = STATUS_NO_CASH
					qty = 0
				else:
					ships -= 1
					_plan_left -= buy
					spent_last += buy
					rec["cap"] = qty
					rec["bought"] = maxi(0, qty - _stock_at(int(src["planet"]), g)) if buy > 0 else 0
					rec["unit_price"] = int(src["price"])
					rec["site"] = true
					if int(rec["bought"]) > 0:
						storage.add(str(rec["src"]), g, int(rec["bought"]))
					records.append(rec)
					_reserve(rec)
		for kind in ["prod", "bill"]:
			if int(q[kind]) > 0:
				site_lines.append({"kind": kind, "good": g, "qty": int(q[kind]), "status": code})
	return ships

## Ore rule: the world of the Star Bazaar hub's system holding the most ore in its own planet storage: {planet, price 0, cost 0, free, stock} or {}.
func _ore_source(hub: int) -> Dictionary:
	var best := {}
	for p in worlds_in_reach(hub):
		if not engine.planet_open(p) or engine.dead_lock_reason(p) != "":
			continue
		var stock := _stock_at(p, "ore")
		if stock > 0 and (best.is_empty() or stock > int(best["stock"])):
			best = {"planet": p, "price": 0, "cost": 0, "free": true, "stock": stock}
	return best

## Cheapest visible good of a bill row sold by a world of the hub's system (as Bazaar._bill_record picks), "" when none is sold.
func _bill_good(h: int, goods: Array) -> String:
	var best := ""
	var best_cost := 1 << 30
	for g in goods:
		if not Availability.good(str(g)):
			continue
		var cost := 1 << 29
		for p in worlds_in_reach(h):
			if not engine.planet_open(p) or engine.dead_lock_reason(p) != "":
				continue
			var pr: int = engine.local_price(p, str(g), "buy")
			if pr > 0 and pr < cost:
				cost = pr
		if cost < best_cost:
			best_cost = cost
			best = str(g)
	return best

## Inputs this cycle's batches of the workshops (and Fabric) standing in system sys need: {use: good -> units used, buy: good -> units
## to deliver (use minus the stock held)}. Mirrors Workshops.run / Fabric.run: per batch the highest-tier recipe that is switched on.
func _production_needs(sys: int, key: String) -> Dictionary:
	var use := {}
	var buy := {}
	var have := {}
	var take := func(r: Dictionary) -> void:
		for c in r.keys():
			var c_s := str(c)
			if not have.has(c_s):
				have[c_s] = storage.amount(key, c_s)
			var n := int(r[c])
			use[c_s] = int(use.get(c_s, 0)) + n
			if int(have[c_s]) < n:
				buy[c_s] = int(buy.get(c_s, 0)) + n - int(have[c_s])
				have[c_s] = n
			have[c_s] = int(have[c_s]) - n
	if fabric != null and bool(fabric.built) and bool(fabric.on) and int(fabric.SYSTEM) == sys:
		var r := {}
		for c in fabric.INPUTS:
			r[c] = fabric.need_of(c)
		for b in int(fabric.batches()):
			take.call(r)
	if workshops != null:
		for id in workshops.IDS:
			if not workshops.stands_in(id, sys):
				continue
			var recipes: Array = workshops.open_recipes(id).filter(func(g) -> bool: return workshops.is_on(str(g)))
			if recipes.is_empty():
				continue
			recipes.reverse()  # highest tier first
			for b in int(workshops.batches(id)):
				var pick: Dictionary = Goods.recipe(str(recipes[0]))
				for g in recipes:  # a recipe the storage (plus planned deliveries) already covers wins, as in run()
					var r2: Dictionary = Goods.recipe(str(g))
					var ok := true
					for c in r2.keys():
						if int(have.get(str(c), storage.amount(key, str(c)))) < int(r2[c]):
							ok = false
					if ok:
						pick = r2
						break
				take.call(pick)
	return {"use": use, "buy": buy}

## Lines for the hub panel: one per Space Storage delivery planned at the last plan().
func site_delivery_lines() -> Array:
	return site_lines

func _stock_at(p: int, good: String) -> int:
	return maxi(0, storage.amount(storage.planet_key(p), good) - int(_reserved.get("%s|%s" % [storage.planet_key(p), good], 0)))

## Earmarks the units a record carries out of its source storage, so the next record does not count them as free stock.
func _reserve(rec: Dictionary) -> void:
	var k := "%s|%s" % [str(rec["src"]), str(rec["c"])]
	_reserved[k] = int(_reserved.get(k, 0)) + int(rec["cap"])

func _make_record(hub: int, world: int, good: String, short: int, src: int = -1) -> Dictionary:
	var probe := src
	if probe < 0:  # no source chosen yet: a size probe (hub planet itself, or any other world of the Bazaar's system)
		probe = hub
		if hub < 0:
			probe = world
			for w in worlds_in_reach(hub):
				if w != world:
					probe = w
					break
	var rec: Dictionary = engine.new_record(probe, world, good)
	rec["owner"] = "hub:%s" % _pid(hub)
	rec["hub"] = hub
	rec["cap"] = short
	return rec

## Puts the hub records into the engine's routes (call just before engine.settle()).
func begin_settle() -> void:
	engine.hub_hold = _reserved.duplicate()  # the worlds' own need-fill must not eat the stock the records are about to carry
	for rec in records:
		rec["id"] = engine.next_id
		engine.next_id += 1
		engine.routes.append(rec)

## Takes the records out again after the settle, lets the worlds consume what arrived (their needs are filled),
## refunds goods bought but not moved, and returns the credits to add to cash (refund minus the hub fee).
func end_settle() -> int:
	fee_last = 0
	commission_last = 0
	delivered_last = {}
	var value_by_hub := {}  # hub -> value of what it delivered (commission base)
	var world_value := {}   # hub -> value of its world (non-site) deliveries
	var world_cost := {}    # hub -> goods bought and trips paid for them
	engine.hub_hold = {}
	engine.sell_hold = {}
	var kept: Array = []
	for rec in engine.routes:
		if str(rec.get("owner", "")) == "":
			kept.append(rec)
	engine.routes = kept
	var refund := 0
	margin_last = {"value": 0, "cost": 0, "net": 0}  # no world delivery this cycle: nothing to show
	for rec in records:
		var moved := int(rec.get("moved", 0)) if str(rec["state"]) == "running" else 0
		var w := int(rec["b"])
		var g := str(rec["c"])
		if moved > 0 and bool(rec.get("site", false)):  # Space Storage delivery: the goods stay in the storage
			delivered_last[int(rec["hub"])] = int(delivered_last.get(int(rec["hub"]), 0)) + moved
			value_by_hub[int(rec["hub"])] = int(value_by_hub.get(int(rec["hub"]), 0)) + moved * int(rec.get("unit_price", 0))
			fee_last += roundi(float(moved * int(rec.get("unit_price", 0))) * _bal("hub_fee_pct", 0.0) / 100.0)
		elif moved > 0:
			var took: int = storage.remove(str(rec["dst"]), g, moved)
			prosperity.add_fill(w, g, took)
			delivered_last[int(rec["hub"])] = int(delivered_last.get(int(rec["hub"]), 0)) + took
			value_by_hub[int(rec["hub"])] = int(value_by_hub.get(int(rec["hub"]), 0)) + took * _delivery_price(w, g, rec)
			world_value[int(rec["hub"])] = int(world_value.get(int(rec["hub"]), 0)) + took * _delivery_price(w, g, rec)
			world_cost[int(rec["hub"])] = int(world_cost.get(int(rec["hub"]), 0)) + moved * int(rec.get("unit_price", 0)) + int(engine.fixed_cost(rec))
			fee_last += roundi(float(took * int(rec.get("unit_price", 0))) * _bal("hub_fee_pct", 0.0) / 100.0)
		var unmoved := maxi(0, int(rec.get("bought", 0)) - moved)
		if unmoved > 0:  # bought but not carried: take it back out of the source and return the price
			var back: int = storage.remove(str(rec["src"]), g, unmoved)
			refund += back * int(rec.get("unit_price", 0))
	for h in hubs:  # Star Bazaar founding asks a planet hub to have worked some cycles and moved some units
		hubs[h]["age"] = int(hubs[h].get("age", 0)) + 1
		hubs[h]["moved"] = int(hubs[h].get("moved", 0)) + int(delivered_last.get(int(h), 0))
		var earn := roundi(float(int(value_by_hub.get(int(h), 0))) * _bal("hub_commission_pct", 0.0) / 100.0)
		if int(h) < 0 and int(world_value.get(int(h), 0)) > 0:  # the Star Bazaar never loses on its world deliveries: net >= bazaar_hub_margin_pct of their value
			var wv := int(world_value[int(h)])
			var base := roundi(float(wv) * _bal("hub_commission_pct", 0.0) / 100.0)
			var cost := int(world_cost.get(int(h), 0)) + pool_of(int(h)) * maxi(0, roundi(_bal("ship_idle_upkeep", 0.0)))
			var want := cost + ceili(float(wv) * _bal("bazaar_hub_margin_pct", 10.0) / 100.0)
			if want > base:
				earn += want - base
			margin_last = {"value": wv, "cost": cost, "net": maxi(base, want) - cost}
		hubs[h]["earned_last"] = earn
		hubs[h]["earned_total"] = int(hubs[h].get("earned_total", 0)) + earn
		commission_last += earn
	records = []
	return refund - fee_last

## Price per unit the receiving world pays for a good (its sell price, a need's price included); else the source buy price.
func _delivery_price(world: int, good: String, rec: Dictionary) -> int:
	var p: int = engine.sold_price(world, good)
	return p if p > 0 else int(rec.get("unit_price", 0))

## Commission a hub earned last cycle / in the run (Hub earned line).
func earned_last(h: int) -> int:
	return int(hubs[h].get("earned_last", 0)) if hubs.has(h) else 0

func earned_total(h: int) -> int:
	return int(hubs[h].get("earned_total", 0)) if hubs.has(h) else 0

## ---- Save ----
func to_array() -> Array:
	var out: Array = []
	for h in hub_planets():
		var on: Array = []
		for w in hubs[h]["on"]:
			on.append(_pid(int(w)))
		out.append({"planet": _pid(h), "pool": int(hubs[h]["pool"]), "on": on, "skip_needs": hubs[h]["skip_needs"].duplicate(), "age": int(hubs[h].get("age", 0)), "moved": int(hubs[h].get("moved", 0)), "earned_last": int(hubs[h].get("earned_last", 0)), "earned_total": int(hubs[h].get("earned_total", 0))})
	return out

func from_array(saved) -> void:
	reset()
	if typeof(saved) != TYPE_ARRAY:
		return  # old saves: no hubs
	var by_id := {}
	for i in trade.planets.size():
		by_id[_pid(i)] = i
	for e in saved:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var h := 0
		if str(e.get("planet", "")).begins_with("station:"):  # the Star Bazaar hub: key -system id (old saves have none)
			h = -int(str(e["planet"]).substr(8))
			if h >= 0:
				continue
		elif by_id.has(str(e.get("planet", ""))):
			h = by_id[str(e["planet"])]
		else:
			continue
		hubs[h] = {"pool": clampi(int(e.get("pool", 0)), 0, pool_max(h)), "on": [], "skip_needs": [], "age": int(e.get("age", 0)), "moved": int(e.get("moved", 0)), "earned_last": int(e.get("earned_last", 0)), "earned_total": int(e.get("earned_total", 0))}
		for pid in e.get("on", []):  # an older save (key "skip") loads with no world ticked, like a new hub
			if by_id.has(str(pid)):
				hubs[h]["on"].append(by_id[str(pid)])
		for k in e.get("skip_needs", []):
			hubs[h]["skip_needs"].append(str(k))
