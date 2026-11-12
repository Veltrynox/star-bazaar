extends "res://qa/check/styles/base.gd"
## Style "founder": plays to WIN the run like a good player.
## Early: profitable lanes, ships when they pay, the Flagship opens and establishes worlds, skills Foundations -> permit -> branch.
## Growth: every established world's needs are fed (need lanes at thin margins once cash allows), hubs at the hub tier with a ship pool.
## Capital: found the Star Bazaar at the first capital-tier world, feed each stage bill into the capital's storage (over-deliver),
## keep the quorum, open system 2 and grow a world there for the reach stage, pick a wing after each stage, accept the Opening
## gig and dock the Flagship at the capital: the win. Event notices: first choice.

const FITTING := ["ceo_man_01", "ceo_man_02", "ceo_woman_01", "ceo_woman_02"]

var _neg := {}            # route id -> cycles in a row with a negative net
var _blocked := {}        # route id -> cycles in a row blocked
var _ws_done := {}
var _stall := {}
var _visited := {}
var _split_done := {}
var _est_fail := {}       # planet -> failed attempts
var _perm_tried := {}
var _gig_cycle := -10
var _hub_ship_tries := {}
var _last_stage := 0


func note(text: String) -> void:
	if notes.size() < 150:
		notes.append("c%d %s" % [int(main.cycle), text])


func fitting_ceos() -> Array:
	return FITTING


func event_policy() -> String:
	return "first"


func wing_pick(stage: int) -> int:
	# stage 1: hub reach helps hubs; later stages: tax (more cash) is the first card of 2, bigger hold for the last
	return 1 if stage == 1 else 0


func each_cycle(c: int) -> void:
	_skills()
	_explore()
	_lanes()
	_maintain(c)
	_permit()
	_workshops()
	_hubs()
	_bazaar()
	_opening()
	_gigs(c)
	if c % 10 == 0 and c >= 20:
		_diag()


func _reserve() -> int:
	return maxi(250, routes_cost() * 2)


func _can_pay_lane() -> bool:
	if a.free_ships() > 0:
		return true
	return int(main.ships) < int(main.ship_cap()) and main.cash - a.ship_price() >= _reserve()


# ---- skills -------------------------------------------------------------------------------------------------------------

func _skills() -> void:
	var br: String = main.run_branch().to_upper()
	var order: Array = ["FND_STORAGE", "FND_PERMIT", "FND_PROSPECT", br + "_1", "FND_DOCKS"]
	order.append_array(branch_order())
	order.append_array(["FND_LEDGER", "FND_RIVAL_WATCH"])
	learn_in_order(order, 3)


# ---- Flagship: open worlds -----------------------------------------------------------------------------------------------

func _explore() -> void:
	if a.fs_busy():
		return
	# once the Bazaar stage needs reach, worlds in system 2 come first
	var order: Array = unexplored(0)
	if main.bazaar.is_founded() and main.can_mine():
		# the bill needs mined goods: dead worlds (platforms) first, then the rest
		var dead: Array = order.filter(func(x): return a.is_dead(int(x)))
		var rest: Array = order.filter(func(x): return not a.is_dead(int(x)))
		dead.append_array(rest)
		order = dead
	for i in order:
		if a.is_dead(i) and not main.can_mine():
			continue  # platforms on dead worlds need the mining skill
		var cost := establish_cost(i)
		if cost < 0 or int(_est_fail.get(i, 0)) >= 3:
			continue
		if main.cash < cost + _reserve() + 150:
			return
		_est_fail[i] = int(_est_fail.get(i, 0)) + 1
		a.fs_queue({"op": "fly_establish", "planet": i})
		note("explore " + a.world_name(i))
		return


# ---- lanes -----------------------------------------------------------------------------------------------------------------

func _lane_into(dst: int, c: String) -> bool:
	for r in main.engine.routes:
		if int(r["b"]) == dst and str(r["c"]) == c:
			return true
	return false


func _lanes() -> void:
	var worlds: Array = a.open_worlds()
	if worlds.size() < 2:
		return
	var made := 0
	var fixed: int = int(main.engine.fixed_cost())
	var cap: int = main.bazaar.capital()
	# 1. margin lanes
	for l in a.known_lanes(maxi(5, fixed)):
		if made >= 2 or not _can_pay_lane():
			break
		if main.engine.routes.size() >= 4 + int(main.cycle) / 2:
			break
		var s2 := int(l["src"])
		var d2 := int(l["dst"])
		var c2 := str(l["c"])
		if has_lane(s2, d2, c2) or has_lane(d2, s2, c2):
			continue
		if make_lane(s2, d2, c2, "card" if int(main.cycle) % 5 == 0 else "buy") >= 0:
			made += 1
			note("margin lane %s %s->%s m%d" % [c2, a.world_name(s2), a.world_name(d2), int(l["margin"])])
	# 2. needs: capital last (its needs come from storage), thin margins fine once cash allows
	for w in worlds:
		for n in a.unmet_needs(w):
			if made >= 3 or not _can_pay_lane():
				break
			var g := str(n["good"])
			if _lane_into(w, g):
				continue
			var s: Dictionary = a.best_source(g, w)
			if int(s["src"]) < 0:
				# no world sells it: mine it from a cluster of the same system (needs the cluster skill)
				if main.can_mine() and _mine_need(w, g):
					made += 1
				continue
			var sell: int = int(main.engine.sold_price(w, g))
			if sell < int(s["buy"]) and main.cash < 1500:
				continue
			if make_lane(int(s["src"]), w, g, "buy") >= 0:
				made += 1
				note("need lane %s %s->%s buy %d sell %d" % [g, a.world_name(int(s["src"])), a.world_name(w), int(s["buy"]), sell])


## Cluster lanes in use (ore is finite: the Bazaar bill needs some, so other worlds get at most 2 cluster lanes).
func _cluster_lanes() -> int:
	var n := 0
	for r in main.engine.routes:
		if a.Clusters.is_node(int(r["a"])):
			n += 1
	return n


func _mine_need(w: int, g: String) -> bool:
	var cap: int = main.bazaar.capital()
	if w != cap and _cluster_lanes() >= 2 and not (main.bazaar.is_founded() and main.bazaar.complete()):
		return false
	for cl in a.cluster_list():
		if str(cl.get("good", "")) != g or not main.open_systems.has(int(cl["system"])):
			continue
		if not _can_pay_lane():
			return false
		var r: Dictionary = a.send_cluster(int(cl["index"]), w)
		if not bool(r["ok"]) and int(main.cycle) % 8 == 0:
			note("mine refused: " + str(r["reason"]).left(90))
		if bool(r["ok"]):
			note("mine %s -> %s" % [g, a.world_name(w)])
			return true
	# clusters used up: mine a dead world (the Mine row of its panel)
	for d in a.dead_worlds():
		if not _can_pay_lane():
			return false
		if not main.open_systems.has(int(main.system_of(int(d)))) or has_lane(int(d), w, g):
			continue
		var r2: Dictionary = a.send(int(d), w, g, "mine")
		if bool(r2["ok"]):
			note("dead-world mine %s %s -> %s" % [g, a.world_name(int(d)), a.world_name(w)])
			return true
		elif str(r2["reason"]).contains("Pathfinder"):
			# the Flagship has not been there yet: fly it over (a retry every 6 cycles per world)
			if not a.fs_busy() and int(main.cycle) - int(_visited.get(d, -99)) >= 6:
				_visited[d] = int(main.cycle)
				a.fs_queue({"op": "fly_establish", "planet": int(d)})
				note("platform on dead world " + a.world_name(int(d)))
		elif int(main.cycle) % 10 == 0:
			note("dead mine refused: " + str(r2["reason"]).left(80))
	return false


func _maintain(c: int) -> void:
	var recs: Array = main.engine.routes.duplicate()
	var cap: int = main.bazaar.capital()
	for r in recs:
		var id := int(r["id"])
		var src := int(r["a"])
		var dst := int(r["b"])
		var g := str(r["c"])
		if str(r["state"]) == "blocked":
			_blocked[id] = int(_blocked.get(id, 0)) + 1
			if not main.move_offer(id).is_empty() and a.move_ship(id)["ok"]:
				continue
			if int(_blocked[id]) == 3 and dst >= 0 and str(main.engine.salvage_reason(src, g)) != "":
				a.salvage(src, g)
		else:
			_blocked[id] = 0
		# an emptied cluster stalls its lane for good: drop it so a fresh cluster can take over
		if (a.Clusters.is_node(src) or a.is_dead(src)) and str(r["state"]) == "stalled":
			_stall[id] = int(_stall.get(id, 0)) + 1
			if int(_stall[id]) >= 2:
				a.remove_route(id, "panel")
				continue
		# bill lanes into the capital are never dropped
		var keep: bool = dst == cap and cap >= 0
		if not keep and int(main.route_net(id)) < 0 and int(r.get("fresh", 1.0)) <= 1.0 and c > 3:
			_neg[id] = int(_neg.get(id, 0)) + 1
			if int(_neg[id]) >= 5 and not _lane_feeds_need(dst, g):
				a.remove_route(id, "panel" if id % 2 == 0 else "right")
				continue
		else:
			_neg[id] = 0
		if dst < 0:
			continue
		if bool(main.engine.lane_full(src, dst, g)):
			if int(main.engine.lane_level(src, dst, g)) < 2 and main.cash >= int(main.upgrade_cost()) + _reserve():
				a.upgrade_route(id)
		elif int(main.engine.lane_count(src, dst, g)) < 2 and int(main.route_net(id)) > int(main.engine.fixed_cost()) and _can_pay_lane() and c > 4:
			a.send(src, dst, g, "quick" if c % 2 == 0 else "card")
		var key := "%d|%s" % [src, g]
		if not _split_done.has(key) and main.split_targets(src, g).size() >= 2:
			if bool(a.split_lane(src, g, 50)["ok"]):
				_split_done[key] = true
	if a.free_ships() == 0 and main.cash > a.ship_price() * 3 + _reserve() and int(main.ships) < int(main.ship_cap()) and not main.engine.routes.is_empty() and c % 3 == 0:
		a.buy_ship()
	a.accept_sell_offer()


## A lane that feeds an unmet need of its destination is kept even at a loss (it grows the world).
func _lane_feeds_need(dst: int, g: String) -> bool:
	for n in a.unmet_needs(dst):
		if str(n["good"]) == g:
			return true
	return false


# ---- systems ---------------------------------------------------------------------------------------------------------------

func _permit() -> void:
	for sid in main.Systems.ids():
		if main.open_systems.has(sid) or _perm_tried.has(sid):
			continue
		var st: Dictionary = a.permit_status(int(sid))
		if str(st["reason"]) == "credits" or str(st["reason"]) == "":
			# earlier when the Bazaar is founded: the reach stage needs a world there
			var margin := 500 if main.bazaar.is_founded() else 1200
			if main.cash >= int(main.permit_cost(int(sid))) + margin:
				var r: Dictionary = a.buy_permit(int(sid))
				if bool(r["ok"]):
					note("permit system %d" % int(sid))
				else:
					_perm_tried[sid] = true
		return


# ---- workshops (the tier 3 and 4 goods of a bill are made there) ---------------------------------------------------------

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
	# the fabric needs dross and nullglass routed to the system 1 Space Storage first
	if not bool(main.fabric.built) and main.has_skill("MIN_1"):
		for g in main.fabric_inputs_unrouted():
			for w in a.open_worlds():
				if int(main.system_of(w)) == 1 and not _ws_done.has("fab|" + str(g)) and _can_pay_lane():
					var sc: Dictionary = a.best_source(str(g), w)
					if int(sc["src"]) >= 0 and bool(a.send(int(sc["src"]), -1, str(g), "buy")["ok"]):
						_ws_done["fab|" + str(g)] = true
						note("fabric input " + str(g))
					break
	if bool(main.fabric.built) == false and bool(main.can_build_fabric()["ok"]) and main.cash > 3000:
		a.build_fabric()
	if int(main.fabric.core_made) < 1 and bool(main.can_build_core()["ok"]):
		a.build_core()
	if int(main.fabric.core_made) > 0 and main.core_route_id() < 0 and not main.engine.routes.is_empty():
		a.fit_core(int(main.engine.routes[0]["id"]))


# ---- hubs --------------------------------------------------------------------------------------------------------------------

func _hubs() -> void:
	for h in a.hub_candidates():
		if bool(a.make_hub(int(h))["ok"]):
			note("hub at " + a.world_name(int(h)))
	for h in main.hubs.hub_planets():
		var hp := int(h)
		var want: int = int(main.balance.get("hub_pool_max", 4))
		if main.hubs.pool_of(hp) < want:
			# a ship for the pool: free ships first, else buy one when cash is plentiful
			if a.free_ships() == 0 and main.cash > a.ship_price() * 2 + _reserve() and int(_hub_ship_tries.get(hp, 0)) < 8:
				_hub_ship_tries[hp] = int(_hub_ship_tries.get(hp, 0)) + 1
				a.hub_buy_ship(hp)
			if a.free_ships() > 0:
				a.hub_pool(hp, mini(want, main.hubs.pool_of(hp) + 1))
		# a hub spends cash on goods: with cash low, its worlds are left off, back on when cash recovers
		var low: bool = main.cash < 300
		for w in a.open_worlds():
			if int(w) == hp:
				continue
			if bool(main.hubs.is_world_off(hp, int(w))) != low:
				a.hub_world(hp, int(w), not low)


# ---- the Star Bazaar --------------------------------------------------------------------------------------------------------

func _bazaar() -> void:
	var b = main.bazaar
	if not b.is_founded():
		var best := -1
		var best_t := 0
		for i in main.map.planets.size():
			if b.can_found(i) and int(main.prosperity.tier(i)) > best_t:
				best = i
				best_t = int(main.prosperity.tier(i))
		if best >= 0 and bool(a.found_bazaar(best)["ok"]):
			note("Bazaar founded at " + a.world_name(best))
		return
	if b.complete():
		return
	var cap: int = b.capital()
	if b.stage() != _last_stage:
		_last_stage = b.stage()
		note("stage %d done" % _last_stage)
	# the bill: lanes into the capital with its sell order off, so goods stay in the planet storage
	var made := 0
	for row in b.bill_status():
		if bool(row["ok"]):
			continue
		for g in row["goods"]:
			if made >= 2:
				break
			if _lane_into(cap, str(g)):
				for r in main.engine.routes:
					if int(r["b"]) == cap and str(r["c"]) == str(g):
						var ra := int(r["a"])
						a.set_order(cap, str(g), "sell", false)
						if bool(main.engine.lane_full(ra, cap, str(g))):
							if int(main.engine.lane_level(ra, cap, str(g))) < 2 and main.cash >= int(main.upgrade_cost()) + 150:
								a.upgrade_route(int(r["id"]))
						elif int(main.engine.lane_count(ra, cap, str(g))) < 4 and _can_pay_lane():
							a.send(ra, cap, str(g), "card")
						break
				continue
			var s: Dictionary = a.best_source(str(g), cap)
			if int(s["src"]) < 0:
				if main.can_mine() and _mine_need(cap, str(g)):
					a.set_order(cap, str(g), "sell", false)
					made += 1
					note("bill mine %s -> capital" % str(g))
				continue
			if not _can_pay_lane():
				continue
			if bool(a.send(int(s["src"]), cap, str(g), "buy")["ok"]):
				a.set_order(cap, str(g), "sell", false)
				made += 1
				note("bill lane %s -> capital" % str(g))
	# the quorum: worlds below the needed tier get their needs first (lanes above do that); the reach world is in system 2
	if b.reach_needed() and not b.reach_ok():
		_open_other_system(cap)


func _open_other_system(cap: int) -> void:
	# make sure the other system's permit is bought and a world there is established
	for sid in main.Systems.ids():
		if int(sid) == int(main.system_of(cap)) or main.open_systems.has(sid):
			continue
		var st: Dictionary = a.permit_status(int(sid))
		if (str(st["reason"]) == "credits" or str(st["reason"]) == "") and main.cash >= int(main.permit_cost(int(sid))):
			if bool(a.buy_permit(int(sid))["ok"]):
				note("permit system %d (reach)" % int(sid))


func _opening() -> void:
	if not bool(main.bazaar.opening_pending) or a.fs_busy():
		return
	for o in main.gigs.offers:
		if str(o.get("kind", "")) == "opening":
			if bool(o.get("accepted", false)):
				return
			a.fs_queue({"op": "gig", "uid": str(o["uid"])})
			note("Opening: flying to the capital")
			return


func _gigs(c: int) -> void:
	if a.fs_busy() or c - _gig_cycle < 2 or bool(main.bazaar.opening_pending):
		return
	for o in main.gigs.offers:
		if bool(o.get("accepted", false)):
			continue
		var k := str(o.get("kind", ""))
		if k == "signal" or k == "salvage":
			if bool(a.accept_gig(str(o["uid"]))["ok"]):
				_gig_cycle = c
				note("gig " + k)
				return


## Short status line for the report: per world tier and unmet needs.
func _diag() -> void:
	var parts: Array = []
	for w in a.open_worlds():
		var u: Array = []
		for n in a.unmet_needs(w):
			u.append(str(n["good"]))
		parts.append("%s t%d [%s]" % [a.world_name(w), int(main.prosperity.tier(w)), ",".join(u)])
	if main.bazaar.is_founded():
		var q: Dictionary = main.bazaar.quorum_status()
		var bl: Array = []
		for row in main.bazaar.bill_status():
			bl.append("t%d %d/%d %s" % [int(row["tier"]), int(row["have"]), int(row["need"]), ",".join(row["goods"])])
		parts.append("BAZ s%d bill %s quorum t%d %d/%d" % [int(main.bazaar.stage()), "; ".join(bl), int(q["tier"]), int(q["have"]), int(q["need"])])
	if main.bazaar.is_founded():
		var cp: int = main.bazaar.capital()
		var rs: Array = []
		for r in main.engine.routes:
			if int(r["b"]) == cp:
				rs.append("%s %s st=%s" % [str(r["a"]), str(r["c"]), str(r["state"])])
		note("capital %s routes in: %s | sell_on ore %s" % [a.world_name(cp), "; ".join(rs), str(main.engine.local_on(cp, "ore", "sell"))])
	note("cash %d ships %d routes %d | %s" % [int(main.cash), int(main.ships), main.engine.routes.size(), "; ".join(parts)])
