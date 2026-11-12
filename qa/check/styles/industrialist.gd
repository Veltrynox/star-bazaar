extends "res://qa/check/styles/base.gd"
## Style "industrialist": a maker, not a hauler.
## A few cash lanes first, then the branch workshop as early as possible: learn the unlocking skills, build the workshop, feed
## its inputs to the Space Storage (Buy -> route -> station), sell crafted goods where they pay or where a world needs them,
## climb to the tier 4 good. Builds one Storage Link (order, order remove, link remove). Measures craft cost versus buy price.

const FITTING := ["ceo_man_01", "ceo_man_02", "ceo_woman_01", "ceo_woman_02"]
const GoodsRef := preload("res://game/goods.gd")

var _est_fail := {}
var _perm_tried := {}
var _ws := ""                 # the branch workshop id
var _ws_tried := {}           # system -> true
var _ws_cycle := -1
var _made_total := {}         # good -> units crafted so far
var _build_paid := 0
var _link_id := -1
var _link_cycle := -1
var _link_state := 0          # 0 none, 1 built, 2 order set, 3 order removed, 4 link removed
var _last_note := -10
var _gig_cycle := -10


func note(text: String) -> void:
	if notes.size() < 90:
		notes.append("c%d %s" % [int(main.cycle), text])


func fitting_ceos() -> Array:
	return FITTING


func event_policy() -> String:
	return "first"


func setup(b: Object) -> void:
	super.setup(b)
	var br: String = main.run_branch()
	for id in main.workshops.IDS:
		if main.workshops.market_of(str(id)) == br:
			_ws = str(id)
	note("branch %s workshop %s" % [br, _ws])


func each_cycle(c: int) -> void:
	_skills()
	_explore()
	_permit()
	_workshop(c)
	_feed()
	_cash_lanes()
	_sell_crafted()
	_link(c)
	_upkeep()
	_measure(c)
	_gigs(c)


func _reserve() -> int:
	return maxi(400, routes_cost() * 3)


func _can_pay_lane() -> bool:
	if a.free_ships() > 0:
		return true
	return int(main.ships) < int(main.ship_cap()) and main.cash - a.ship_price() >= _reserve()


## Inputs of the workshop come first: a ship is bought when the cash covers it and a little more.
func _can_pay_feed() -> bool:
	if a.free_ships() > 0:
		return true
	return int(main.ships) < int(main.ship_cap()) and main.cash - a.ship_price() >= 500


func _plain_routes() -> int:
	var n := 0
	for r in main.engine.routes:
		if int(r["b"]) >= 0:
			n += 1
	return n


## The world is the source of a lane carrying g (its Buy order must stay on).
func _is_source(w: int, g: String) -> bool:
	for r in main.engine.routes:
		if int(r["a"]) == w and str(r["c"]) == g:
			return true
	return false


func _lane_into(dst: int, c: String) -> bool:
	for r in main.engine.routes:
		if int(r["b"]) == dst and str(r["c"]) == c:
			return true
	return false


# ---- skills ------------------------------------------------------------------------------------------------------------------

func _skills() -> void:
	var br: String = main.run_branch().to_upper()
	var order: Array = ["FND_STORAGE", "FND_PERMIT", "FND_PROSPECT", br + "_1"]
	order.append_array(branch_order())
	# tech nodes (completed by crafting) are learned when they open
	for id in SkillTreeRef.ids_in(main.run_branch()):
		if SkillTreeRef.is_tech(str(id)):
			order.append(str(id))
	order.append_array(["FND_DOCKS", "FND_LEDGER"])
	# strict order: a skill that waits for points or earned income holds the ones behind it
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
# ---- Flagship, permit --------------------------------------------------------------------------------------------------------

func _explore() -> void:
	if a.fs_busy():
		return
	for i in unexplored(0):
		if a.is_dead(i):
			continue
		var cost := establish_cost(i)
		if cost < 0 or int(_est_fail.get(i, 0)) >= 3:
			continue
		if main.cash < cost + _reserve() + 200 or (int(main.ships) < 2 and int(main.cycle) > 4):
			return
		_est_fail[i] = int(_est_fail.get(i, 0)) + 1
		a.fs_queue({"op": "fly_establish", "planet": i})
		note("explore " + a.world_name(i))
		return


func _permit() -> void:
	# the workshop needs its own cash first; the permit comes after it (unless the workshop needs system 2)
	if _ws != "" and not bool(main.workshops.built[_ws]) and str(main.can_build_workshop(_ws, 1)["reason"]) != "closed":
		return
	for sid in main.Systems.ids():
		if main.open_systems.has(sid) or _perm_tried.has(sid):
			continue
		var st: Dictionary = a.permit_status(int(sid))
		if str(st["reason"]) == "credits" or str(st["reason"]) == "":
			if main.cash >= int(main.permit_cost(int(sid))) + 900:
				if bool(a.buy_permit(int(sid))["ok"]):
					note("permit system %d" % int(sid))
				else:
					_perm_tried[sid] = true
		return


# ---- a few cash lanes --------------------------------------------------------------------------------------------------------

func _cash_lanes() -> void:
	if false:
		note("DBG lanes %d worlds %d free_ships %d cash %d routes %d price %d" % [a.known_lanes(1).size(), a.open_worlds().size(), a.free_ships(), main.cash, main.engine.routes.size(), a.ship_price()])
	var want := 6 if (_ws == "" or not bool(main.workshops.built[_ws])) else 8
	var made := 0
	for l in a.known_lanes(maxi(5, int(main.engine.fixed_cost()))):
		if made >= 2 or not _can_pay_lane():
			break
		# only lanes between worlds: station feeds are counted apart
		var plain := 0
		for r in main.engine.routes:
			if int(r["b"]) >= 0:
				plain += 1
		if plain >= want:
			break
		var s := int(l["src"])
		var d := int(l["dst"])
		var g := str(l["c"])
		if has_lane(s, d, g) or has_lane(d, s, g) or _is_source(d, g):
			continue
		if GoodsRef.entry(g).get("kind", "") == "crafted" and _ws != "" and bool(main.workshops.built[_ws]):
			continue  # crafted goods are sold from the workshop, not bought for a lane
		if make_lane(s, d, g, "buy") >= 0:
			made += 1
			note("cash lane %s %s->%s m%d" % [g, a.world_name(s), a.world_name(d), int(l["margin"])])
	# unmet needs of a world also pay (and grow the world), while the lane count is low
	for w in a.open_worlds():
		for n in a.unmet_needs(w):
			if made >= 2 or _plain_routes() >= want + 2 or not _can_pay_lane():
				return
			var g3 := str(n["good"])
			if _lane_into(w, g3) or _is_source(w, g3) or GoodsRef.entry(g3).get("kind", "") == "crafted":
				continue
			var sc: Dictionary = a.best_source(g3, w)
			if int(sc["src"]) < 0 or _lane_into(int(sc["src"]), g3) or int(main.engine.sold_price(w, g3)) < int(sc["buy"]):
				continue
			if make_lane(int(sc["src"]), w, g3, "buy") >= 0:
				made += 1
				note("need lane %s %s->%s" % [g3, a.world_name(int(sc["src"])), a.world_name(w)])


# ---- the workshop ------------------------------------------------------------------------------------------------------------

func _station_world(sid: int) -> int:
	for w in a.open_worlds():
		if int(main.system_of(w)) == sid:
			return w
	return -1


func _workshop(c: int) -> void:
	if _ws == "" or bool(main.workshops.built[_ws]):
		return
	for sid in [1, 2]:
		var chk: Dictionary = main.can_build_workshop(_ws, int(sid))
		if not bool(chk["ok"]):
			if int(main.cycle) % 30 == 0 and int(sid) == 1:
				note("workshop %s not buildable: %s" % [_ws, str(chk["reason"])])
			continue
		var cost: int = main.workshops.build_cost(_ws)
		if main.cash < cost + 1200:
			return
		var r: Dictionary = a.build_workshop(_ws, int(sid))
		if bool(r["ok"]):
			_build_paid = cost
			_ws_cycle = c
			note("built %s in system %d for %d" % [_ws, int(sid), cost])
		else:
			note("build refused: " + str(r["reason"]).left(80))
		return


## Every good the workshop crafts (open now or later), as ids.
func _recipes() -> Array:
	return GoodsRef.recipes_of(_ws)


## Inputs the workshop does not make itself.
func _outside_inputs() -> Array:
	var made_here: Array = _recipes()
	var out: Array = []
	for g in main.workshops.open_recipes(_ws):
		for inp in GoodsRef.recipe(str(g)).keys():
			if not made_here.has(str(inp)) and not out.has(str(inp)):
				out.append(str(inp))
	return out


func _feed() -> void:
	if _ws == "" or not bool(main.workshops.built[_ws]):
		return
	var sid: int = main.workshops.system_of(_ws)
	var key: String = main.storage.system_key(sid)
	var inputs: Array = _outside_inputs()
	# inputs the workshop reported missing are fed first
	for g in main.workshops.missing.get(_ws, []):
		if not inputs.has(str(g)):
			inputs.insert(0, str(g))
	for g in inputs:
		var g2 := str(g)
		if not a.goods_visible().has(g2):
			if int(main.cycle) % 6 == 0:
				note("feed %s hidden" % g2)
			continue
		if int(main.storage.amount(key, g2)) > 40:
			continue
		var dst := -sid
		var have := false
		for r in main.engine.routes:
			if int(r["b"]) == dst and str(r["c"]) == g2:
				have = true
		if have:
			continue
		if not _can_pay_feed():
			if int(main.cycle) % 6 == 0:
				note("feed %s waits: no ship (ships %d/%d, cash %d)" % [g2, int(main.ships), int(main.ship_cap()), int(main.cash)])
			return
		var w0 := _station_world(sid)
		if w0 < 0:
			continue
		var s := {"src": -1, "buy": 1 << 30}
		for w in a.open_worlds():
			var bp: int = main.trade.price(w, g2 + "_buy")
			# a world that takes this good by a Sell order cannot also Buy it: skip those sources
			if bp >= 0 and bp < int(s["buy"]) and not _lane_into(w, g2) and not _is_source(w, g2) and bool(main.engine.check_connection(w, dst, g2)["ok"]):
				s = {"src": w, "buy": bp}
		if int(s["src"]) < 0:
			# a source with no other lane taking its stock is best; else take the cheapest shared one
			for w in a.open_worlds():
				var bp2: int = main.trade.price(w, g2 + "_buy")
				if bp2 >= 0 and bp2 < int(s["buy"]) and not _lane_into(w, g2) and bool(main.engine.check_connection(w, dst, g2)["ok"]):
					s = {"src": w, "buy": bp2}
		if int(s["src"]) < 0 or int(s["buy"]) >= (1 << 30):
			# raw ore may come from a cluster of the system (ship carries it to the station)
			for cl in a.cluster_list():
				if str(cl.get("good", "")) == g2 and main.open_systems.has(int(cl["system"])):
					if bool(a.send(a.Clusters.node_id(int(cl["index"])), dst, g2, "buy")["ok"]):
						note("feed %s from cluster" % g2)
						return
			if int(main.cycle) % 6 == 0:
				note("feed %s: no source" % g2)
			continue
		var r2: Dictionary = a.send(int(s["src"]), dst, g2, "buy")
		if bool(r2["ok"]):
			note("feed %s %s -> station %d (buy %d)" % [g2, a.world_name(int(s["src"])), sid, int(s["buy"])])
		elif int(main.cycle) - _last_note >= 6:
			_last_note = int(main.cycle)
			note("feed refused %s: %s" % [g2, str(r2["reason"]).left(70)])


func _sell_crafted() -> void:
	if _ws == "" or not bool(main.workshops.built[_ws]):
		return
	var sid: int = main.workshops.system_of(_ws)
	var key: String = main.storage.system_key(sid)
	var src := _station_world(sid)
	if src < 0:
		return
	var recs: Array = _recipes()
	for g in recs:
		var g2 := str(g)
		var stock := int(main.storage.amount(key, g2))
		for k in ["made"]:
			var mm: Dictionary = main.workshops.made.get(_ws, {})
			_made_total[g2] = int(_made_total.get(g2, 0)) + int(mm.get(g2, 0)) if k == "made" else 0
		# an intermediate good stays as input until a surplus builds up
		var is_input := false
		for h in recs:
			if GoodsRef.recipe(str(h)).has(g2) and main.workshops.open_recipes(_ws).has(str(h)):
				is_input = true
		if stock < (14 if is_input else 3) or not a.goods_visible().has(g2):
			if stock > 0 and int(main.cycle) % 10 == 0:
				note("hold %s stock %d input %s visible %s" % [g2, stock, str(is_input), str(a.goods_visible().has(g2))])
			continue
		var dst := -1
		var best := 0
		for w in a.open_worlds():
			var need := false
			for n in a.unmet_needs(w):
				if str(n["good"]) == g2:
					need = true
			var p: int = int(main.engine.sold_price(w, g2))
			var score: int = p + (1000 if need else 0)
			if p <= 0 or score <= best:
				continue
			# the source is any world of the workshop's system other than the buyer (the lane draws the Space Storage)
			for s0 in a.open_worlds():
				if s0 != w and int(main.system_of(s0)) == sid and main.engine.check_connection(s0, w, g2)["ok"]:
					best = score
					dst = w
					src = s0
					break
		if dst < 0:
			if int(main.cycle) % 10 == 0:
				note("no buyer for %s (stock %d)" % [g2, stock])
			continue
		if _lane_into(dst, g2) or not _can_pay_lane():
			continue
		var r: Dictionary = a.send(src, dst, g2, "card")
		if bool(r["ok"]):
			a.set_order(dst, g2, "sell", true)
			note("sell crafted %s -> %s at %d" % [g2, a.world_name(dst), int(main.engine.sold_price(dst, g2))])
		elif int(main.cycle) - _last_note >= 6:
			_last_note = int(main.cycle)
			note("crafted sale refused %s: %s" % [g2, str(r["reason"]).left(70)])


# ---- Storage Link ------------------------------------------------------------------------------------------------------------

func _link(c: int) -> void:
	if _link_state == 0:
		if _ws == "" or not bool(main.workshops.built[_ws]) or main.cash < 600:
			return
		var cand: Array = a.link_candidates()
		if cand.is_empty():
			return
		var r: Dictionary = a.link_build(int(cand[0][0]), int(cand[0][1]))
		if bool(r["ok"]):
			var ls: Array = main.storage_link.links()
			_link_id = int(ls[ls.size() - 1]["id"])
			_link_state = 1
			_link_cycle = c
			note("storage link built %d-%d" % [int(cand[0][0]), int(cand[0][1])])
		elif c % 6 == 0:
			note("link refused: " + str(r["reason"]).left(70))
	elif _link_state == 1:
		# use it: carry an input of the workshop (or its output) from the other system to the workshop system
		var sid: int = main.workshops.system_of(_ws)
		var ls: Array = main.storage_link.links()
		var other := -1
		for l in ls:
			if int(l["id"]) == _link_id:
				other = int(l["b"]) if int(l["a"]) == sid else int(l["a"])
		var good := ""
		var ins: Array = _outside_inputs()
		if not ins.is_empty():
			good = str(ins[0])
		if other >= 0 and good != "" and bool(a.link_order(_link_id, good, other, 5)["ok"]):
			_link_state = 2
			note("link order %s from system %d" % [good, other])
		elif c - _link_cycle > 6:
			_link_state = 2
			note("link order not possible")
	elif _link_state == 2 and c - _link_cycle >= 10:
		a.link_order_remove(_link_id, 0)
		_link_state = 3
	elif _link_state == 3:
		if bool(a.link_remove(_link_id)["ok"]):
			note("storage link removed")
		_link_state = 4


# ---- upkeep and measure -------------------------------------------------------------------------------------------------------

func _upkeep() -> void:
	for r in main.engine.routes.duplicate():
		var id := int(r["id"])
		if str(r["state"]) == "blocked" and not main.move_offer(id).is_empty():
			a.move_ship(id)
		var dst := int(r["b"])
		if dst >= 0 and bool(main.engine.lane_full(int(r["a"]), dst, str(r["c"]))) and int(main.engine.lane_level(int(r["a"]), dst, str(r["c"]))) < 2 and main.cash >= int(main.upgrade_cost()) + _reserve() + 400:
			a.upgrade_route(id)
	a.accept_sell_offer()


## Per unit: inputs at the best Buy price plus the workshop fee spread over units made, against the Buy price of the good.
func _measure(c: int) -> void:
	if _ws == "" or not bool(main.workshops.built[_ws]) or c % 12 != 0:
		return
	var sid: int = main.workshops.system_of(_ws)
	var w0 := _station_world(sid)
	var stk := []
	for g in _outside_inputs():
		stk.append("%s=%d" % [str(g), int(main.storage.amount(main.storage.system_key(sid), str(g)))])
	for r in main.engine.routes:
		if int(r["b"]) < 0:
			note("station lane %s from %s state %s %s" % [str(r["c"]), a.world_name(int(r["a"])), str(r["state"]), str(r.get("reason", "")).left(60)])
	note("workshop %s state %s (%s) stock %s" % [_ws, str(main.workshops.state[_ws]), str(main.workshops.reason[_ws]).left(50), ",".join(stk)])
	var units := 0
	for g in _made_total:
		units += int(_made_total[g])
	for g in _recipes():
		var g2 := str(g)
		if not a.goods_visible().has(g2) or not main.workshops.open_recipes(_ws).has(g2) or w0 < 0:
			continue
		var inputs := 0.0
		var ok := true
		for inp in GoodsRef.recipe(g2).keys():
			var best := 1 << 30
			for w in a.open_worlds():
				var p: int = main.trade.price(w, str(inp) + "_buy")
				if p >= 0 and p < best:
					best = p
			if best == (1 << 30):
				ok = true  # no world sells it: mined or crafted here, counted as free
			else:
				inputs += float(best) * float(GoodsRef.recipe(g2)[inp])
		var out := float(main.workshops.out_units(g2))
		var buy := 1 << 30
		for w in a.open_worlds():
			var p2: int = main.trade.price(w, g2 + "_buy")
			if p2 >= 0 and p2 < buy:
				buy = p2
		var fee := float(_build_paid) / float(maxi(1, units))
		var craft := (inputs / out + fee) if ok else -1.0
		note("craft %s: inputs %.0f + fee %.0f = %.0f/unit vs buy %s; made %d total" % [g2, inputs / out, fee, craft, str(buy) if buy < (1 << 30) else "n/a", int(_made_total.get(g2, 0))])
	var sold_val := 0
	for g in _made_total:
		var sp: int = int(GoodsRef.entry(str(g)).get("sell_price", 0))
		sold_val += int(_made_total[g]) * sp
	note("workshop paid back? crafted value %d vs fee %d (units %d)" % [sold_val, _build_paid, units])


func _gigs(c: int) -> void:
	if a.fs_busy() or c - _gig_cycle < 3:
		return
	for o in main.gigs.offers:
		if bool(o.get("accepted", false)):
			continue
		var k := str(o.get("kind", ""))
		if k == "opening" or k == "signal" or k == "salvage":
			if bool(a.accept_gig(str(o["uid"]))["ok"]):
				_gig_cycle = c
				note("gig " + k)
				return
