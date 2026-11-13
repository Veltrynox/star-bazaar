class_name Hubs
extends RefCounted
## T289 Hubs: a world at the hub tier keeps the needs of worlds in its reach fed (design 3.3).
## A hub owns a pool of ships taken from the free fleet. Each cycle, before the route engine settles, plan() makes one
## delivery record per short need (owner "hub:<planet>"): the cheapest established source in reach, up to the demand only,
## never surplus. The records live in `records` and are put into engine.routes only for the settle (begin_settle /
## end_settle), so they are never saved and never shown in route lists. They settle with the normal route engine.
## A delivery pays the buy price of the goods (stock already owned in the source world's planet storage is free; Space Storage is never a hub source),
## the trip cost (the engine's fixed cost) and hub_fee_pct of the buy value. Manual routes into a world count first.
## All numbers: data/balance.json hub_* keys (placeholders). Text ids: ST_HUB_* via StoryText.get_or fallbacks.

const StoryText := preload("res://game/story_text.gd")
const Availability := preload("res://game/availability.gd")

var balance: Dictionary = {}
var engine: RefCounted = null        # RouteEngine
var prosperity: RefCounted = null    # Prosperity
var trade: RefCounted = null
var storage: RefCounted = null
var owned_ships_fn: Callable = Callable()  # () -> int, ships owned (set by main)
var hubs: Dictionary = {}            # planet index -> {pool: int, on: Array of planet indexes the player added, skip_needs: Array of "planet|good"}
var records: Array = []              # this cycle's hub delivery records
var status: Dictionary = {}          # "planet|good" -> status code of the last plan(), see STATUS_*
var spent_last := 0                  # credits the last plan() paid for goods
var fee_last := 0                    # credits of fee the last end_settle() charged
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
	spent_last = 0
	fee_last = 0
	delivered_last = {}

func _bal(key: String, fallback: float) -> float:
	return float(balance.get(key, fallback))

func _pid(i: int) -> String:
	return str(trade.planets[i].get("id", "")) if i >= 0 and i < trade.planets.size() else ""

func _system(i: int) -> int:
	return int(trade.planets[i].get("system", 1)) if i >= 0 and i < trade.planets.size() else -1

## ---- Designate, pool, release ----
func is_hub(planet: int) -> bool:
	return hubs.has(planet)

func hub_planets() -> Array:
	var out: Array = hubs.keys()
	out.sort()
	return out

func pool_of(planet: int) -> int:
	return int(hubs[planet]["pool"]) if hubs.has(planet) else 0

func pool_total() -> int:
	var n := 0
	for p in hubs:
		n += int(hubs[p]["pool"])
	return n

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
	if prosperity.tier(planet) < int(_bal("hub_tier", 3)):
		return {"ok": false, "reason": StoryText.get_or("ST_HUB_TIER", "The world must reach tier {tier} first.", {"tier": int(_bal("hub_tier", 3))})}
	if hub_in_system(_system(planet)) >= int(_bal("hub_max_per_system", 1)):
		return {"ok": false, "reason": StoryText.get_or("ST_HUB_SYSTEM_FULL", "This system already has its hub.")}
	return {"ok": true, "reason": ""}

func designate(planet: int) -> Dictionary:
	var r := can_designate(planet)
	if bool(r["ok"]):
		hubs[planet] = {"pool": 0, "on": [], "skip_needs": []}  # no world is served until the player ticks it (owner 2026-11-13)
	return r

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
	var want := clampi(n, 0, int(_bal("hub_pool_max", 0)))
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
	return hubs.has(hub) and world != hub and not hubs[hub]["on"].has(world)

func is_need_off(hub: int, world: int, good: String) -> bool:
	return hubs.has(hub) and hubs[hub]["skip_needs"].has("%d|%s" % [world, good])

## ---- Reach ----
func reach_of(planet: int) -> float:
	var base := _bal("hub_reach_t%d" % prosperity.tier(planet), 0.0)
	return base + Bazaar.wing_bonus("hub_reach") if base > 0.0 else base  # T298 wings: only worlds that have a reach

func _pos(i: int) -> Variant:
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
	return distance(hub, world) <= reach_of(hub)

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

## Cheapest source for `qty` units of good for world, inside the hub's reach: {planet, price, stock} or {}.
## Stock already in the source's own planet storage costs nothing (Space Storage is never used); otherwise the planet's buy price.
func _best_source(hub: int, world: int, good: String, qty: int) -> Dictionary:
	var best := {}
	for p in worlds_in_reach(hub):
		if p == world or not engine.planet_open(p):
			continue
		if engine.dead_lock_reason(p) != "":
			continue
		var stock: int = storage.amount(storage.planet_key(p), good)
		var price: int = engine.local_price(p, good, "buy")
		var free_stock := stock >= qty
		if not free_stock and (price <= 0 or (engine.trade_gate.is_valid() and not bool(engine.trade_gate.call(p)))):
			continue
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
	spent_last = 0
	var left := cash - maxi(0, cash_floor)
	for h in hub_planets():
		if prosperity.tier(h) < int(_bal("hub_tier", 3)):
			continue  # the world fell below the hub tier: it keeps its pool but runs nothing
		var ships := pool_of(h)
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
				var need_cash: int = buy + int(engine.fixed_cost(rec))
				if need_cash > left:
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
				status[key] = STATUS_HUB
				status[key + "|by"] = str(h)
	return spent_last

func _stock_at(p: int, good: String) -> int:
	return storage.amount(storage.planet_key(p), good)

func _make_record(hub: int, world: int, good: String, short: int, src: int = -1) -> Dictionary:
	var rec: Dictionary = engine.new_record(src if src >= 0 else hub, world, good)
	rec["owner"] = "hub:%s" % _pid(hub)
	rec["hub"] = hub
	rec["cap"] = short
	return rec

## Puts the hub records into the engine's routes (call just before engine.settle()).
func begin_settle() -> void:
	for rec in records:
		rec["id"] = engine.next_id
		engine.next_id += 1
		engine.routes.append(rec)

## Takes the records out again after the settle, lets the worlds consume what arrived (their needs are filled),
## refunds goods bought but not moved, and returns the credits to add to cash (refund minus the hub fee).
func end_settle() -> int:
	fee_last = 0
	delivered_last = {}
	var kept: Array = []
	for rec in engine.routes:
		if str(rec.get("owner", "")) == "":
			kept.append(rec)
	engine.routes = kept
	var refund := 0
	for rec in records:
		var moved := int(rec.get("moved", 0)) if str(rec["state"]) == "running" else 0
		var w := int(rec["b"])
		var g := str(rec["c"])
		if moved > 0:
			var took: int = storage.remove(str(rec["dst"]), g, moved)
			prosperity.add_fill(w, g, took)
			delivered_last[int(rec["hub"])] = int(delivered_last.get(int(rec["hub"]), 0)) + took
			fee_last += roundi(float(took * int(rec.get("unit_price", 0))) * _bal("hub_fee_pct", 0.0) / 100.0)
		var unmoved := maxi(0, int(rec.get("bought", 0)) - moved)
		if unmoved > 0:  # bought but not carried: take it back out of the source and return the price
			var back: int = storage.remove(str(rec["src"]), g, unmoved)
			refund += back * int(rec.get("unit_price", 0))
	records = []
	return refund - fee_last

## ---- Save ----
func to_array() -> Array:
	var out: Array = []
	for h in hub_planets():
		var on: Array = []
		for w in hubs[h]["on"]:
			on.append(_pid(int(w)))
		out.append({"planet": _pid(h), "pool": int(hubs[h]["pool"]), "on": on, "skip_needs": hubs[h]["skip_needs"].duplicate()})
	return out

func from_array(saved) -> void:
	reset()
	if typeof(saved) != TYPE_ARRAY:
		return  # old saves: no hubs
	var by_id := {}
	for i in trade.planets.size():
		by_id[_pid(i)] = i
	for e in saved:
		if typeof(e) != TYPE_DICTIONARY or not by_id.has(str(e.get("planet", ""))):
			continue
		var h: int = by_id[str(e["planet"])]
		hubs[h] = {"pool": clampi(int(e.get("pool", 0)), 0, int(_bal("hub_pool_max", 0))), "on": [], "skip_needs": []}
		for pid in e.get("on", []):  # an older save (key "skip") loads with no world ticked, like a new hub
			if by_id.has(str(pid)):
				hubs[h]["on"].append(by_id[str(pid)])
		for k in e.get("skip_needs", []):
			hubs[h]["skip_needs"].append(str(k))
