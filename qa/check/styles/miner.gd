extends "res://qa/check/styles/base.gd"
## Style "miner" (Minerals CEO): everything mining.
## Prospecting first, cluster lanes (send_cluster) until clusters run dry, the smelter (reusing the industrialist's workshop,
## feed and sale routines), then the dead worlds: Prospecting opens them (MIN_3 and MIN_5 stay in the order for yield and stock), the Flagship builds a platform on
## each, dross and nullglass are mined into the Space Storage, the Fabric makes plate, the Null Core is built and fitted, and
## at the end one dead world is RECLAIMED by delivering its need list. Records raids and salvage pods.

const FITTING := ["ceo_man_01"]
const GoodsRef := preload("res://game/goods.gd")
const Industrialist := preload("res://qa/check/styles/industrialist.gd")

var ind: RefCounted = null     # the industrialist routines, used for the smelter
var _est_fail := {}
var _visited := {}
var _perm_tried := {}
var _gig_cycle := -10
var _core_fit := false
var _reclaim_world := -1
var _reclaim_start := -1
var _salvage_seen := 0
var _salvage_taken := 0
var _last_state := ""
var _dry_noted := false


func fitting_ceos() -> Array:
	return FITTING


func event_policy() -> String:
	return "first"


func note(text: String) -> void:
	if notes.size() < 90:
		notes.append("c%d %s" % [int(main.cycle), text])


func setup(b: Object) -> void:
	super.setup(b)
	ind = Industrialist.new()
	ind.setup(b)
	ind.notes = notes          # one shared notes list
	ind._ws = "smelter"


func each_cycle(c: int) -> void:
	_skills()
	_explore()
	_permit()
	_clusters()
	ind._workshop(c)
	ind._feed()
	ind._sell_crafted()
	_dead_mining()
	_fabric()
	_reclaim(c)
	_upkeep()
	_gigs(c)
	_status(c)


func _reserve() -> int:
	return maxi(400, routes_cost() * 3)


func _can_pay_lane() -> bool:
	if a.free_ships() > 0:
		return true
	return int(main.ships) < int(main.ship_cap()) and main.cash - a.ship_price() >= _reserve()


func _lane_into(dst: int, c: String) -> bool:
	for r in main.engine.routes:
		if int(r["b"]) == dst and str(r["c"]) == c:
			return true
	return false


## The cluster (index) with the most ore left, kept back for the reclaim.
func _reserved_cluster() -> int:
	var best := -1
	var most := 0
	for cl in a.cluster_list():
		if int(cl.get("left", 0)) > most:
			most = int(cl["left"])
			best = int(cl["index"])
	return best


func _clusters_left() -> int:
	var n := 0
	for cl in a.cluster_list():
		n += int(cl.get("left", 0))
	return n


func _lane_from(src: int, c: String) -> bool:
	for r in main.engine.routes:
		if int(r["a"]) == src and str(r["c"]) == c:
			return true
	return false


# ---- skills ------------------------------------------------------------------------------------------------------------------

func _skills() -> void:
	var order: Array = ["FND_PROSPECT", "FND_STORAGE", "FND_PERMIT", "MIN_1", "MIN_3", "MIN_5"]
	# the system 2 permit costs skill points too (Greywake lies there): keep them until it is bought
	if main.open_systems.size() < 2 and main.learned_skills.has("MIN_5"):
		return
	order.append_array(["MIN_13", "MIN_8", "MIN_5B"])
	order.append_array(branch_order())
	for id in SkillTreeRef.ids_in("min"):
		if SkillTreeRef.is_tech(str(id)):
			order.append(str(id))
	order.append("FND_DOCKS")
	# strict order: a skill waiting for points or earned income holds the ones behind it
	for id in order:
		if main.learned_skills.has(id):
			continue
		var why := str(SkillTreeRef.can_learn(main.learned_skills, main.skill_points, main.balance, str(id))["reason"])
		if why == "":
			if bool(a.learn_skill(str(id))["ok"]):
				note("learned " + str(id))
			continue
		if why == "points" or why == "earn":
			return


# ---- Flagship ------------------------------------------------------------------------------------------------------------------

func _explore() -> void:
	if a.fs_busy():
		return
	# a dead world needs the Flagship's platform first (once the skill that opens it is learned)
	for d in a.dead_worlds():
		if main.planet_established(int(d)) or not main.open_systems.has(int(main.system_of(int(d)))):
			continue
		if int(main.cycle) - int(_visited.get(d, -99)) < 8 or int(_est_fail.get(d, 0)) >= 4:
			continue
		var cost := establish_cost(int(d))
		if cost < 0 or main.cash < cost + _reserve():
			continue
		_visited[d] = int(main.cycle)
		_est_fail[d] = int(_est_fail.get(d, 0)) + 1
		a.fs_queue({"op": "fly_establish", "planet": int(d)})
		note("fly to dead world %s (platform cost %d)" % [a.world_name(int(d)), cost])
		return
	for i in unexplored(0):
		if a.is_dead(i):
			continue
		var cost2 := establish_cost(i)
		if cost2 < 0 or int(_est_fail.get(i, 0)) >= 3:
			continue
		if main.cash < cost2 + _reserve() + 200 or (int(main.ships) < 2 and int(main.cycle) > 4):
			return
		_est_fail[i] = int(_est_fail.get(i, 0)) + 1
		a.fs_queue({"op": "fly_establish", "planet": i})
		note("explore " + a.world_name(i))
		return


func _permit() -> void:
	if not main.learned_skills.has("MIN_5"):
		return
	for sid in main.Systems.ids():
		if int(sid) != 2 or main.open_systems.has(sid) or _perm_tried.has(sid):
			continue
		var st: Dictionary = a.permit_status(int(sid))
		if int(main.cycle) % 10 == 0:
			note("permit system %d status '%s' (cost %d, points %d, have %d)" % [int(sid), str(st["reason"]), int(main.permit_cost(int(sid))), int(main.permit_points(int(sid))), int(main.skill_points)])
		if str(st["reason"]) == "credits" or str(st["reason"]) == "":
			if main.cash >= int(main.permit_cost(int(sid))) + 300:
				if bool(a.buy_permit(int(sid))["ok"]):
					note("permit system %d" % int(sid))
				else:
					_perm_tried[sid] = true
		return


# ---- cluster lanes -------------------------------------------------------------------------------------------------------------

func _cluster_lane_count() -> int:
	var n := 0
	for r in main.engine.routes:
		if a.Clusters.is_node(int(r["a"])):
			n += 1
	return n


func _clusters() -> void:
	if not main.can_mine():
		_plain_lane()
		return
	var open := 0
	for cl in a.cluster_list():
		if int(cl.get("left", 0)) > 0 and main.open_systems.has(int(cl["system"])):
			open += 1
	if open == 0 and not _dry_noted and not a.cluster_list().is_empty():
		_dry_noted = true
		note("clusters dry")
	var made := 0
	for cl in a.cluster_list():
		if made >= 1 or _cluster_lane_count() >= 4 or not _can_pay_lane():
			break
		if int(cl.get("left", 0)) <= 0 or not main.open_systems.has(int(cl["system"])):
			continue
		if int(cl["index"]) == _reserved_cluster():
			continue  # kept for the reclaim: its need list asks for ore and nobody sells ore
		var node: int = a.Clusters.node_id(int(cl["index"]))
		var g := str(cl.get("good", ""))
		if _lane_from(node, g):
			continue
		# the best paying world for the ore
		var dst := -1
		var best := 0
		for w in a.open_worlds():
			var p: int = int(main.engine.sold_price(w, g))
			if p > best and not _lane_from(w, g) and bool(main.engine.check_connection(node, w, g)["ok"]):
				best = p
				dst = w
		if dst < 0:
			continue
		var r: Dictionary = a.send_cluster(int(cl["index"]), dst)
		if bool(r["ok"]):
			a.set_order(dst, g, "sell", true)
			made += 1
			note("cluster lane %s -> %s at %d" % [g, a.world_name(dst), best])
		elif int(main.cycle) % 8 == 0:
			note("cluster lane refused: " + str(r["reason"]).left(80))
	_plain_lane()


## One or two plain cash lanes keep the money coming before and between the mining work.
func _plain_lane() -> void:
	var plain := 0
	for r in main.engine.routes:
		if int(r["b"]) >= 0 and not a.Clusters.is_node(int(r["a"])) and not a.is_dead(int(r["a"])):
			plain += 1
	if plain >= 3 or not _can_pay_lane():
		return
	for l in a.known_lanes(maxi(5, int(main.engine.fixed_cost()))):
		var s := int(l["src"])
		var d := int(l["dst"])
		var g := str(l["c"])
		if has_lane(s, d, g) or has_lane(d, s, g) or _lane_from(d, g) or GoodsRef.entry(g).get("kind", "") == "crafted":
			continue
		if make_lane(s, d, g, "buy") >= 0:
			note("cash lane %s %s->%s" % [g, a.world_name(s), a.world_name(d)])
			return


# ---- dead worlds: mine into the Space Storage ----------------------------------------------------------------------------------

func _dead_mining() -> void:
	if not main.can_mine() or _reclaim_world >= 0:
		return
	var sid := 1
	for d in a.dead_worlds():
		var di := int(d)
		if not main.planet_established(di) or not main.open_systems.has(int(main.system_of(di))):
			continue
		if a.is_dead(di) and bool(main.prosperity.mining_closed(di)):
			continue
		# which good does this world give? the run branch's mine good (DeadWorlds.mine_good; Minerals: dross, nullglass)
		for g in [str(main.DeadWorlds.mine_good(str(main.map.planets[di].get("id", ""))))]:
			if _lane_from(di, g) or _lane_into(-sid, g) or not _can_pay_lane() or int(main.trade.price(di, g + "_buy")) < 0:
				continue
			if str(main.engine.dead_mining_reason(di)) != "" or str(main.engine.dead_skill_reason(di)) != "":
				continue
			if not bool(main.engine.check_connection(di, -sid, g)["ok"]):
				continue
			var r: Dictionary = a.send(di, -sid, g, "mine")
			if bool(r["ok"]):
				note("mine %s at %s -> Space Storage" % [g, a.world_name(di)])
				return
			elif int(main.cycle) % 8 == 0:
				note("mine refused %s at %s: %s" % [g, a.world_name(di), str(r["reason"]).left(80)])


# ---- Fabric and Null Core --------------------------------------------------------------------------------------------------------

func _fabric() -> void:
	if not bool(main.fabric.built):
		var chk: Dictionary = main.can_build_fabric()
		if bool(chk["ok"]):
			if bool(a.build_fabric()["ok"]):
				note("Fabric built")
		elif int(main.cycle) % 10 == 0 and bool(main.learned_skills.has("MIN_1")):
			note("Fabric not buildable: " + str(chk["reason"]) + " unrouted " + str(main.fabric_inputs_unrouted()))
		return
	if int(main.fabric.core_made) < 1:
		var chk2: Dictionary = main.can_build_core()
		if bool(chk2["ok"]):
			if bool(a.build_core()["ok"]):
				note("Null Core built")
		elif int(main.cycle) % 10 == 0:
			note("Core not buildable: " + str(chk2["reason"]))
	elif not _core_fit and main.core_route_id() < 0 and not main.engine.routes.is_empty():
		var rid := -1
		for r in main.engine.routes:
			if int(r["b"]) >= 0:
				rid = int(r["id"])
				break
		if rid >= 0 and bool(a.fit_core(rid)["ok"]):
			_core_fit = true
			note("Null Core fitted to route %d" % rid)


# ---- reclaim one dead world ------------------------------------------------------------------------------------------------------

func _reclaim(c: int) -> void:
	if _reclaim_world < 0:
		# start once the Core is fitted, or late in the term when the Core is out of reach
		if not (_core_fit or c >= 70):
			return
		for d in a.dead_worlds():
			if main.planet_established(int(d)) and not bool(main.prosperity.is_reclaimed(int(d))):
				_reclaim_world = int(d)
				_reclaim_start = c
				break
		if _reclaim_world < 0:
			return
		# mining stops there: drop its lanes
		for r in main.engine.routes.duplicate():
			# the mining lanes of that world, and the nullglass lane to the Fabric (the Core is made; its Buy order is needed here)
			if int(r["a"]) == _reclaim_world or (int(r["b"]) < 0 and str(r["c"]) == "nullglass" and int(main.fabric.core_made) > 0):
				a.remove_route(int(r["id"]), "panel")
		note("reclaim started at %s" % a.world_name(_reclaim_world))
	var w := _reclaim_world
	if bool(main.prosperity.is_reclaimed(w)):
		return
	# the Buy order at a source (a dead world mines on it) must stay on while a lane into the reclaimed world uses it
	for r in main.engine.routes:
		if int(r["b"]) == w and not a.Clusters.is_node(int(r["a"])) and not bool(main.engine.local_on(int(r["a"]), str(r["c"]), "buy")):
			if bool(a.set_order(int(r["a"]), str(r["c"]), "buy", true)["ok"]):
				note("buy order back on: %s at %s" % [str(r["c"]), a.world_name(int(r["a"]))])
	for n in a.needs_of(w):
		if bool(n["locked"]) or bool(n["met"]):
			continue
		var g := str(n["good"])
		if _lane_into(w, g) or not _can_pay_lane():
			continue
		# source: a world that sells it, or the workshop system's storage for plate and nullglass
		var s: Dictionary = a.best_source(g, w)
		var src := int(s["src"])
		if src < 0:
			for x in a.open_worlds():
				if x != w and bool(main.engine.check_connection(x, w, g)["ok"]) and int(main.storage.amount(main.storage.system_key(int(main.system_of(x))), g)) > 0:
					src = x
					break
		if src < 0:
			# raw ore comes from a cluster that still holds some
			for cl in a.cluster_list():
				if str(cl.get("good", "")) == g and int(cl.get("left", 0)) > 0 and main.open_systems.has(int(cl["system"])):
					if bool(a.send_cluster(int(cl["index"]), w)["ok"]):
						a.set_order(w, g, "sell", true)
						note("reclaim lane %s from a cluster -> %s" % [g, a.world_name(w)])
						break
			if c % 6 == 0 and not _lane_into(w, g):
				note("reclaim need %s has no source (clusters left %d)" % [g, _clusters_left()])
			continue
		var r: Dictionary = a.send(src, w, g, "buy" if int(s["src"]) >= 0 else "card")
		if bool(r["ok"]):
			a.set_order(w, g, "sell", true)
			note("reclaim lane %s %s -> %s" % [g, a.world_name(src), a.world_name(w)])
		elif c % 6 == 0:
			note("reclaim lane refused %s: %s" % [g, str(r["reason"]).left(80)])


# ---- upkeep, gigs, status ----------------------------------------------------------------------------------------------------------

func _upkeep() -> void:
	for r in main.engine.routes.duplicate():
		var id := int(r["id"])
		if str(r["state"]) == "blocked" and not main.move_offer(id).is_empty():
			a.move_ship(id)
		# an emptied cluster stalls its lane for good: drop it so a fresh cluster can take over
		if a.Clusters.is_node(int(r["a"])) and str(r["state"]) == "stalled":
			a.remove_route(id, "right")
			continue
		var dst := int(r["b"])
		if dst >= 0 and bool(main.engine.lane_full(int(r["a"]), dst, str(r["c"]))) and int(main.engine.lane_level(int(r["a"]), dst, str(r["c"]))) < 2 and main.cash >= int(main.upgrade_cost()) + _reserve() + 400:
			a.upgrade_route(id)
	a.accept_sell_offer()


func _gigs(c: int) -> void:
	for o in main.gigs.offers:
		if str(o.get("kind", "")) == "salvage" and not bool(o.get("accepted", false)) and not bool(o.get("_seen", false)):
			o["_seen"] = true
			_salvage_seen += 1
	if a.fs_busy() or c - _gig_cycle < 2:
		return
	# salvage pods first (the miner records them), then the rest
	var pick := ""
	for kind in ["salvage", "opening", "signal"]:
		for o in main.gigs.offers:
			if str(o.get("kind", "")) == kind and not bool(o.get("accepted", false)):
				if bool(a.accept_gig(str(o["uid"]))["ok"]):
					_gig_cycle = c
					if kind == "salvage":
						_salvage_taken += 1
					note("gig " + kind)
					return


func _status(c: int) -> void:
	if c % 15 != 0:
		return
	var ws := "none"
	if bool(main.workshops.built["smelter"]):
		ws = "%s (%s)" % [str(main.workshops.state["smelter"]), str(main.workshops.reason["smelter"]).left(40)]
	note("status smelter %s fabric %s core %d raids %d salvage seen %d taken %d" % [ws, str(main.fabric.built), int(main.fabric.core_made), int(bot.raids_seen), _salvage_seen, _salvage_taken])
	for d in a.dead_worlds():
		var pid := str(main.map.planets[int(d)].get("id", ""))
		note("dead world %s stock left %d of %d, cycles left %d" % [a.world_name(int(d)), int(main.engine.dead_worlds.stock_left(pid)), int(main.engine.dead_worlds.stock_max()), int(main.engine.dead_worlds.cycles_left(pid))])
	var k: String = main.storage.system_key(1)
	note("storage sys1 dross %d nullglass %d plate %d (core needs plate %d nullglass %d, cash %d)" % [int(main.storage.amount(k, "dross")), int(main.storage.amount(k, "nullglass")), int(main.storage.amount(k, "plate")), int(main.fabric.core_in("plate")), int(main.fabric.core_in("nullglass")), int(main.fabric.core_cost())])
	if _reclaim_world >= 0:
		var nl := []
		for n in a.needs_of(_reclaim_world):
			nl.append("%s%s%s" % [str(n["good"]), "+" if bool(n["met"]) else "-", "L" if bool(n["locked"]) else ""])
		note("reclaim needs " + ",".join(nl))
		for r in main.engine.routes:
			if int(r["b"]) == _reclaim_world:
				note("  lane %s from %s: %s %s" % [str(r["c"]), a.world_name(int(r["a"])), str(r["state"]), str(r.get("reason", "")).left(50)])
		note("reclaim progress %s %.2f" % [a.world_name(_reclaim_world), float(main.prosperity.reclaim_progress(_reclaim_world))])
