extends "res://qa/check/styles/base.gd"
## Style "expander": goes wide as fast as possible. Permit skill and the system 2 permit at the first chance, then systems 3, 4, 5;
## the Flagship flies across systems and puts a post on every world; Space Storage per system, energy lanes into each station,
## lanes inside and between systems, a Storage Link, ships up to the cap, a hub in each system that qualifies.
## Notes: what each system cost (permit, posts) and earned afterwards, worlds that could not be used, and a Buy order for energy at a
## system 3 world (units and state text per cycle).

const FITTING := ["ceo_man_01", "ceo_man_02", "ceo_woman_01", "ceo_woman_02"]

var _est_fail := {}
var _perm_tried := {}
var _perm_log := {}       # sid -> cycle bought
var _sys_spend := {}      # sid -> credits spent on its permit and posts
var _sys_earn := {}       # sid -> sum of route nets of lanes ending there
var _hubs_done := {}      # sid -> true
var _station_lane := {}   # sid -> true when an energy lane into its station was sent
var _unusable := {}
var _link_log := 0
var _link_ok := false
var _buy_world := -1
var _buy_log := 0
var _buy_stock0 := -1
var _cycle_log := 0
var _goal := {}
var _unused := 0           # sid -> cycle first world established


func fitting_ceos() -> Array:
	return FITTING


func event_policy() -> String:
	return "first"


func note(text: String) -> void:
	if notes.size() < 140:
		notes.append("c%d %s" % [int(main.cycle), text])


func each_cycle(c: int) -> void:
	_skills()
	_permits(c)
	_posts(c)
	_lanes(c)
	_ships()
	_hubs()
	_station_energy()
	_link(c)
	_buy_probe(c)
	_accounting(c)


func _reserve() -> int:
	return 150 + routes_cost()


func _skills() -> void:
	var order: Array = ["FND_PERMIT", "FND_STORAGE", "FND_PROSPECT", "FND_DOCKS"]
	order.append_array(branch_order())
	learn_in_order(order, 3)


# ---- permits ---------------------------------------------------------------------------------------------------------------------

func _permits(c: int) -> void:
	for sid in main.Systems.ids():
		var s := int(sid)
		if main.open_systems.has(s) or _perm_tried.has(s):
			continue
		var st: Dictionary = a.permit_status(s)
		var why := str(st["reason"])
		if why == "credits" or why == "":
			# first chance, but with a base income running (the first try with one lane went broke: see notes)
			if int(main.cash) >= int(main.permit_cost(s)) + 150 + (0 if main.engine.routes.size() >= 2 else 600):
				var c0 := int(main.cash)
				var r: Dictionary = a.buy_permit(s)
				if bool(r["ok"]):
					_perm_log[s] = c
					_sys_spend[s] = int(_sys_spend.get(s, 0)) + (c0 - int(main.cash))
					note("PERMIT system %d bought for %d (points left %d)" % [s, c0 - int(main.cash), int(main.skill_points)])
					a.go_system(s)
				else:
					note("permit system %d refused: %s" % [s, str(r["reason"]).substr(0, 80)])
					_perm_tried[s] = true
		elif c % 15 == 1:
			note("permit system %d blocked: %s (need %d, cash %d, points %d)" % [s, why, int(main.permit_cost(s)), int(main.cash), int(main.skill_points)])
		return  # one system at a time, in order


# ---- posts on every world ------------------------------------------------------------------------------------------------------

func _posts(c: int) -> void:
	if a.fs_busy():
		return
	for i in unexplored(0):
		if a.is_dead(i) or int(_est_fail.get(i, 0)) >= 3:
			continue
		var cost := establish_cost(i)
		if cost < 0:
			_unusable[i] = "no cost offered"
			continue
		if int(main.cash) < cost + _reserve() + (a.ship_price() if main.engine.routes.size() < 3 else 0):
			return
		_est_fail[i] = int(_est_fail.get(i, 0)) + 1
		var sid := int(main.system_of(i))
		_sys_spend[sid] = int(_sys_spend.get(sid, 0)) + cost
		a.fs_queue({"op": "fly_establish", "planet": i})
		if not _goal.has(sid):
			_goal[sid] = c
		note("post %s (system %d) cost %d" % [a.world_name(i), sid, cost])
		return
	# worlds that failed three times
	for i in _est_fail.keys():
		if int(_est_fail[i]) >= 3 and not main.planet_established(int(i)) and not _unusable.has(i):
			_unusable[i] = "3 establish attempts failed (%s)" % str(a.fs_note).substr(0, 60)
			note("UNUSABLE %s: %s" % [a.world_name(int(i)), str(_unusable[i])])


# ---- lanes ---------------------------------------------------------------------------------------------------------------------------

func _can_pay_lane() -> bool:
	if a.free_ships() > 0:
		return true
	return int(main.ships) < int(main.ship_cap()) and int(main.cash) - a.ship_price() >= _reserve()


func _lanes(c: int) -> void:
	if a.open_worlds().size() < 2:
		return
	var made := 0
	for l in a.known_lanes(maxi(5, int(main.engine.fixed_cost()))):
		if made >= 2 or not _can_pay_lane():
			break
		var s := int(l["src"])
		var d := int(l["dst"])
		var g := str(l["c"])
		if has_lane(s, d, g) or has_lane(d, s, g):
			continue
		# spread: at most two lanes into the same world
		var into := 0
		for r in main.engine.routes:
			if int(r["b"]) == d:
				into += 1
		if into >= 2:
			continue
		if int(main.system_of(s)) != int(main.system_of(d)):
			a.go_system(int(main.system_of(s)))
		var id := make_lane(s, d, g, "buy")
		if id >= 0:
			made += 1
			note("lane %s %s(s%d)->%s(s%d) m%d" % [g, a.world_name(s), int(main.system_of(s)), a.world_name(d), int(main.system_of(d)), int(l["margin"])])
	# a lane that is blocked can move its ship; sell offers are accepted
	for r in main.engine.routes.duplicate():
		if str(r["state"]) == "blocked" and not main.move_offer(int(r["id"])).is_empty():
			a.move_ship(int(r["id"]))
	a.accept_sell_offer()


func _ships() -> void:
	if int(main.ships) >= int(main.ship_cap()):
		return
	if a.free_ships() > 0:
		return
	if int(main.cash) >= a.ship_price() * 2 + _reserve():
		a.buy_ship()


func _hubs() -> void:
	for h in a.hub_candidates():
		var sid := int(main.system_of(int(h)))
		if _hubs_done.has(sid):
			continue
		if bool(a.make_hub(int(h))["ok"]):
			_hubs_done[sid] = true
			note("hub at %s (system %d)" % [a.world_name(int(h)), sid])
			if a.free_ships() == 0:
				var r: Dictionary = a.hub_buy_ship(int(h))
				if not bool(r["ok"]):
					note("hub ship refused: %s" % str(r["reason"]).substr(0, 60))
			a.hub_pool(int(h), 1)
	for h in main.hubs.hub_planets():
		if main.hubs.pool_of(int(h)) == 0 and a.free_ships() > 0:
			a.hub_pool(int(h), 1)


## An energy lane into each system's Space Storage (feeds the Storage Link and the workshops).
func _station_energy() -> void:
	for sid in main.station_systems:
		var s := int(sid)
		if _station_lane.has(s) or not _can_pay_lane():
			continue
		var src := -1
		var best := 1 << 30
		for w in a.open_worlds():
			if int(main.system_of(w)) != s:
				continue
			var p: int = main.trade.price(w, "energy_buy")
			if p >= 0 and p < best:
				best = p
				src = int(w)
		if src < 0:
			continue
		_station_lane[s] = true
		var r: Dictionary = a.send(src, -s, "energy", "buy")
		if bool(r["ok"]):
			a.set_order(src, "energy", "buy", true)
			note("energy lane %s -> Space Storage system %d" % [a.world_name(src), s])
		else:
			note("station lane system %d refused: %s" % [s, str(r["reason"]).substr(0, 80)])


func _link(c: int) -> void:
	if _link_ok or c % 3 != 0 or main.station_systems.size() < 2:
		return
	var cand: Array = a.link_candidates()
	if cand.is_empty():
		if _link_log < 6:
			_link_log += 1
			var x := int(main.station_systems[0])
			var y := int(main.station_systems[1])
			note("link %d-%d not buildable: %s" % [x, y, str(main.storage_link.can_build(x, y))])
		return
	var r: Dictionary = a.link_build(int(cand[0][0]), int(cand[0][1]))
	note("link build %s: %s" % ["OK" if bool(r["ok"]) else "refused", str(r["reason"]).substr(0, 80)])
	if bool(r["ok"]):
		_link_ok = true
		var lid: int = int(main.storage_link.links()[0])  # links() is a list of link ids
		a.link_order(lid, "energy", int(cand[0][0]), 5)
		var orders: Array = main.storage_link.link_info(lid).get("orders", [])
		if not orders.is_empty():  # cover the remove paths once, then put the order back
			a.link_order_remove(lid, 0)
			a.link_order(lid, "energy", int(cand[0][0]), 5)


# ---- the known system 3 Buy order effect -----------------------------------------------------------------------------------

func _buy_probe(c: int) -> void:
	if _buy_world < 0:
		for w in a.open_worlds():
			if int(main.system_of(w)) == 3 and main.trade.price(w, "energy_buy") >= 0:
				_buy_world = int(w)
				var r: Dictionary = a.set_order(_buy_world, "energy", "buy", true)
				note("energy Buy order at %s (system 3): %s" % [a.world_name(_buy_world), "on" if bool(r["ok"]) else str(r["reason"]).substr(0, 60)])
				_buy_stock0 = int(main.storage.amount(main.storage.planet_key(_buy_world), "energy"))
				_buy_log = 0
				break
		return
	if _buy_log < 8:
		_buy_log += 1
		var stock := int(main.storage.amount(main.storage.planet_key(_buy_world), "energy"))
		note("buy probe %s: stored %d (was %d), bought-total %d, state '%s', cash %d" % [a.world_name(_buy_world), stock, _buy_stock0,
			int(bot.goods_bought.get("energy", 0)), str(main.engine.local_state(_buy_world, "energy", "buy")).substr(0, 70), int(main.cash)])
		_buy_stock0 = stock


# ---- accounting per system -------------------------------------------------------------------------------------------------------

func _accounting(c: int) -> void:
	for r in main.engine.routes:
		var d := int(r["b"])
		var sid := -d if d < 0 else int(main.system_of(d))
		_sys_earn[sid] = int(_sys_earn.get(sid, 0)) + int(main.route_net(int(r["id"])))
	if c % 30 == 0:
		for i in main.map.planets.size():
			if main.open_systems.has(int(main.system_of(i))) and not main.planet_established(i):
				note("left over: world %d '%s' system %d dead=%s cost=%s eta=%.1f fails=%d" % [i, a.world_name(i), int(main.system_of(i)), str(a.is_dead(i)),
					str(establish_cost(i)), float(main.flight.eta_cycles(str(main.map.planets[i].get("id", "")))), int(_est_fail.get(i, 0))])
	if c - _cycle_log >= 10:
		_cycle_log = c
		var parts: Array = []
		for sid in main.Systems.ids():
			var s := int(sid)
			var worlds := 0
			for i in main.map.planets.size():
				if int(main.system_of(i)) == s and main.planet_established(i):
					worlds += 1
			parts.append("s%d open=%s worlds=%d spent=%d lane_net=%d" % [s, str(main.open_systems.has(s)), worlds, int(_sys_spend.get(s, 0)), int(_sys_earn.get(s, 0))])
		note("STATE cash %d ships %d/%d routes %d | %s" % [int(main.cash), int(main.ships), int(main.ship_cap()), main.engine.routes.size(), " | ".join(parts)])
