extends "res://qa/check/styles/base.gd"
## Style "trader": a sensible route trader.
## Opens the neighbouring worlds with the Flagship, builds Buy -> route -> Sell lanes by margin and by world needs, buys ships
## when a lane needs one and cash stays safe, upgrades and splits full lanes, learns skills in a sound order, buys the system 2
## permit and keeps expanding, founds the Bazaar at the first capital-tier world and feeds its bill. Event notices: first choice.
## It plays to reach high prosperity tiers; it does not try to win on purpose.

const FITTING := ["ceo_woman_01", "ceo_man_02"]

var _neg := {}            # route id -> cycles in a row with a negative net
var _blocked := {}        # route id -> cycles in a row blocked
var _split_done := {}     # "src|good" -> true
var _est_fail := {}       # planet -> failed attempts
var _hub_done := false
var _gig_cycle := -10
var _perm_tried := {}
var _link_tried := false
var _ws_done := {}


func fitting_ceos() -> Array:
	return FITTING


func event_policy() -> String:
	return "first"


func each_cycle(c: int) -> void:
	_skills()
	_explore()
	_lanes()
	_maintain(c)
	_permit()
	_workshops()
	_bazaar()
	_hubs()
	_gigs(c)
	_storage_links()


func _reserve() -> int:
	return maxi(300, routes_cost() * 2)


func _skills() -> void:
	var br: String = main.run_branch().to_upper()
	var order: Array = ["FND_STORAGE", "FND_PERMIT", "FND_PROSPECT", br + "_1", "FND_DOCKS"]
	order.append_array(branch_order())
	order.append_array(["FND_LEDGER", "FND_RIVAL_WATCH"])
	learn_in_order(order, 3)


# ---- Flagship: open the worlds --------------------------------------------------------------------------------------------

func _explore() -> void:
	if a.fs_busy():
		return
	for i in unexplored(0):
		if a.is_dead(i):
			continue  # platforms are for the miner style
		var cost := establish_cost(i)
		if cost < 0:
			continue
		if int(_est_fail.get(i, 0)) >= 3:
			continue
		if main.cash < cost + _reserve() + 200:
			return
		_est_fail[i] = int(_est_fail.get(i, 0)) + 1
		a.fs_queue({"op": "fly_establish", "planet": i})
		note("explore " + a.world_name(i))
		return


# ---- lanes ---------------------------------------------------------------------------------------------------------------

func _lane_into(dst: int, c: String) -> bool:
	for r in main.engine.routes:
		if int(r["b"]) == dst and str(r["c"]) == c:
			return true
	return false


func _can_pay_lane() -> bool:
	if a.free_ships() > 0:
		return true
	return int(main.ships) < int(main.ship_cap()) and main.cash - a.ship_price() >= _reserve()


func _lanes() -> void:
	var worlds: Array = a.open_worlds()
	if worlds.size() < 2:
		return
	var made := 0
	var fixed: int = int(main.engine.fixed_cost())
	# 1. best margin lanes, a few at a time
	for l in a.known_lanes(maxi(5, fixed)):
		if made >= 2 or not _can_pay_lane():
			break
		if main.engine.routes.size() >= 3 + int(main.cycle) / 3:
			break
		var s2 := int(l["src"])
		var d2 := int(l["dst"])
		var c2 := str(l["c"])
		if has_lane(s2, d2, c2) or has_lane(d2, s2, c2):
			continue
		if make_lane(s2, d2, c2, "card" if int(main.cycle) % 5 == 0 else "buy") >= 0:
			made += 1
			note("margin lane %s %s->%s m%d" % [c2, a.world_name(s2), a.world_name(d2), int(l["margin"])])
	# 2. unmet needs grow the worlds: fed when the unit does not lose money, or when cash is plentiful
	for w in worlds:
		for n in a.unmet_needs(w):
			if made >= 2 or not _can_pay_lane():
				break
			var g := str(n["good"])
			if _lane_into(w, g):
				continue
			var s: Dictionary = a.best_source(g, w)
			if int(s["src"]) < 0:
				continue
			var sell: int = int(main.engine.sold_price(w, g))
			if sell < int(s["buy"]) and main.cash < 3000:
				continue
			if make_lane(int(s["src"]), w, g, "buy") >= 0:
				made += 1
				note("need lane %s %s->%s buy %d sell %d" % [g, a.world_name(int(s["src"])), a.world_name(w), int(s["buy"]), sell])


# ---- upkeep of the network -------------------------------------------------------------------------------------------------

func _maintain(c: int) -> void:
	var recs: Array = main.engine.routes.duplicate()
	for r in recs:
		var id := int(r["id"])
		var src := int(r["a"])
		var dst := int(r["b"])
		var g := str(r["c"])
		# ship moves: a closed world blocks a lane; the game offers a move
		if str(r["state"]) == "blocked":
			_blocked[id] = int(_blocked.get(id, 0)) + 1
			if not main.move_offer(id).is_empty() and a.move_ship(id)["ok"]:
				continue
			if int(_blocked[id]) == 3 and dst >= 0 and str(main.engine.salvage_reason(src, g)) != "":
				a.salvage(src, g)
		else:
			_blocked[id] = 0
		# a lane that loses money for 4 cycles is dropped (alternating the two remove paths)
		if int(main.route_net(id)) < 0 and int(r.get("fresh", 1.0)) <= 1.0 and c > 3:
			_neg[id] = int(_neg.get(id, 0)) + 1
			if int(_neg[id]) >= 4:
				a.remove_route(id, "panel" if id % 2 == 0 else "right")
				continue
		else:
			_neg[id] = 0
		if dst < 0:
			continue
		# full lane: upgrade it; not full and the margin is good: a second ship
		if bool(main.engine.lane_full(src, dst, g)):
			if int(main.engine.lane_level(src, dst, g)) < 2 and main.cash >= int(main.upgrade_cost()) + _reserve():
				a.upgrade_route(id)
		elif int(main.engine.lane_count(src, dst, g)) < 2 and int(main.route_net(id)) > int(main.engine.fixed_cost()) and _can_pay_lane() and c > 4:
			a.send(src, dst, g, "quick" if c % 2 == 0 else "card")
		# split a source that feeds two destinations
		var key := "%d|%s" % [src, g]
		if not _split_done.has(key) and main.split_targets(src, g).size() >= 2:
			if bool(a.split_lane(src, g, 50)["ok"]):
				_split_done[key] = true
	# a spare ship is bought ahead when a lane is waiting for one and cash is plentiful
	if a.free_ships() == 0 and main.cash > a.ship_price() * 3 + _reserve() and int(main.ships) < int(main.ship_cap()) and not main.engine.routes.is_empty() and c % 3 == 0:
		a.buy_ship()
	a.accept_sell_offer()


# ---- systems --------------------------------------------------------------------------------------------------------------

func _permit() -> void:
	for sid in main.Systems.ids():
		if main.open_systems.has(sid) or _perm_tried.has(sid):
			continue
		var st: Dictionary = a.permit_status(int(sid))
		if str(st["reason"]) == "credits" or str(st["reason"]) == "":
			if main.cash >= int(main.permit_cost(int(sid))) + 900:
				var r: Dictionary = a.buy_permit(int(sid))
				if bool(r["ok"]):
					note("permit system %d" % int(sid))
				else:
					_perm_tried[sid] = true
		return


func _workshops() -> void:
	for id in main.workshops.IDS:
		if _ws_done.has(id) or bool(main.workshops.built[id]):
			continue
		var chk: Dictionary = main.can_build_workshop(str(id), 1)
		if bool(chk["ok"]) and main.cash >= main.workshops.build_cost(id) + 1200:
			if bool(a.build_workshop(str(id), 1)["ok"]):
				_ws_done[id] = true
				note("built " + str(id))
	# feed built workshops: inputs go to the Space Storage
	for id in main.workshops.IDS:
		if not bool(main.workshops.built[id]):
			continue
		var sid: int = main.workshops.system_of(id)
		for g in main.workshops.missing.get(id, []):
			for w in a.open_worlds():
				if int(main.system_of(w)) != sid:
					continue
				var key := "feed|%s|%s" % [id, str(g)]
				if _ws_done.has(key):
					continue
				var s: Dictionary = a.best_source(str(g), w)
				if int(s["src"]) < 0 or not _can_pay_lane():
					continue
				var r: Dictionary = a.send(int(s["src"]), -sid, str(g), "buy")
				if bool(r["ok"]):
					_ws_done[key] = true
					note("feed %s %s" % [str(id), str(g)])
				break
	if bool(main.fabric.built) == false and bool(main.can_build_fabric()["ok"]) and main.cash > 3000:
		a.build_fabric()
	if int(main.fabric.core_made) < 1 and bool(main.can_build_core()["ok"]):
		a.build_core()
	if int(main.fabric.core_made) > 0 and main.core_route_id() < 0 and not main.engine.routes.is_empty():
		a.fit_core(int(main.engine.routes[0]["id"]))


func _storage_links() -> void:
	if _link_tried:
		return
	var cand: Array = a.link_candidates()
	if cand.is_empty():
		return
	_link_tried = true
	var r: Dictionary = a.link_build(int(cand[0][0]), int(cand[0][1]))
	if bool(r["ok"]):
		var lid: int = int(main.storage_link.links()[0]["id"])
		a.link_order(lid, "energy", int(cand[0][0]), 5)
		a.link_order_remove(lid, 0)
		a.link_remove(lid)


# ---- Bazaar and hubs ------------------------------------------------------------------------------------------------------

func _bazaar() -> void:
	var b = main.bazaar
	if not b.is_founded():
		var best := -1
		var best_t := 0
		for sid in main.station_systems:  # the system whose Space Storage has the highest world tier
			if not b.can_found(int(sid)):
				continue
			var top := 0
			for w in b.founding_worlds(int(sid)):
				top = maxi(top, int(main.prosperity.tier(int(w))))
			if top > best_t:
				best = int(sid)
				best_t = top
		if best >= 0:
			if bool(a.found_bazaar(best)["ok"]):
				note("Bazaar founded in system %d" % best)
		return
	var cap: int = -int(b.site_system())  # destination value of the Star Bazaar's Space Storage
	for row in b.bill_status():
		if bool(row["ok"]):
			continue
		for g in row["goods"]:
			if not _can_pay_lane():
				return
			if _lane_into(cap, str(g)):
				# the bill is short: more ships on that lane, then an upgrade
				for r in main.engine.routes:
					if int(r["b"]) == cap and str(r["c"]) == str(g):
						var ra := int(r["a"])
						if bool(main.engine.lane_full(ra, cap, str(g))):
							if int(main.engine.lane_level(ra, cap, str(g))) < 2 and main.cash >= int(main.upgrade_cost()) + _reserve():
								a.upgrade_route(int(r["id"]))
						elif int(main.engine.lane_count(ra, cap, str(g))) < 3:
							a.send(ra, cap, str(g), "card")
						break
				continue
			var s: Dictionary = a.best_source(str(g), cap)
			if int(s["src"]) < 0:
				continue
			if bool(a.send(int(s["src"]), cap, str(g), "buy")["ok"]):
				note("bill lane %s -> Star Bazaar" % str(g))
				return


func wing_pick(_stage: int) -> int:
	return 0


func _hubs() -> void:
	var cand: Array = a.hub_candidates()
	if not cand.is_empty() and not _hub_done:
		var h := int(cand[0])
		if bool(a.make_hub(h)["ok"]):
			_hub_done = true
			if a.free_ships() == 0:
				a.hub_buy_ship(h)
			a.hub_pool(h, 1)
			note("hub at " + a.world_name(h))
	for h in main.hubs.hub_planets():
		if main.hubs.pool_of(int(h)) == 0 and a.free_ships() > 0:
			a.hub_pool(int(h), 1)


# ---- gigs and the Flagship's idle time -----------------------------------------------------------------------------------

func _gigs(c: int) -> void:
	if a.fs_busy() or c - _gig_cycle < 2:
		return
	for o in main.gigs.offers:
		if bool(o.get("accepted", false)):
			continue
		var k := str(o.get("kind", ""))
		if k == "opening" or k == "signal" or k == "salvage":
			var r: Dictionary = a.accept_gig(str(o["uid"]))
			if bool(r["ok"]):
				_gig_cycle = c
				note("gig " + k)
				return
