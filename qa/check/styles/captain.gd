extends "res://qa/check/styles/base.gd"
## Style "captain": the Flagship is the main tool. Two or three automated lanes for a base income; everything else by hand:
## explore and establish every world (once in exploration mode), dock and trade by hand (cheap world -> hungry world), boost with
## energy carried in the hold, and take every gig (signals, rush orders, salvage pods, anything on the board).
## Notes carry the hand-trade / gig / lane income split, expired gigs and idle Flagship time (the owner's "is the Flagship loop thin" worry).

const FITTING := ["ceo_man_01", "ceo_man_02", "ceo_woman_01", "ceo_woman_02"]
const MAX_LANES := 3

var _est_fail := {}
var _explore_on_cycle := -1
var _explored_mode_done := false
var _perm_tried := {}
var _seen := {}            # gig uid -> {kind, id, accepted}
var _rush_done0 := 0
# totals
var _hand_net := 0
var _gig_in := 0
var _lane_in := 0
var _cycles_counted := 0
var _expired := {"signal": 0, "rush": 0, "salvage": 0, "other": 0}
var _done := {"signal": 0, "rush": 0, "salvage": 0, "other": 0}
var _idle_chunks := 0
var _all_chunks := 0
var _plans := 0
var _no_trade_cycles := 0
var _no_gig_cycles := 0
var _sum_idx := -1
var _last_plan := ""
var _hand_by_cycle: Array = []


func fitting_ceos() -> Array:
	return FITTING


func event_policy() -> String:
	return "seeded"  # signal arrival windows: options alternate with the seed


func note(text: String) -> void:
	if notes.size() < 120:
		notes.append("c%d %s" % [int(main.cycle), text])


func each_cycle(c: int) -> void:
	_account(c)
	_skills()
	_lanes(c)
	_permit()
	_flagship(c)
	_summary()


func on_chunk(_k: int) -> void:
	_all_chunks += 1
	if not a.fs_busy():
		_idle_chunks += 1
	# boost whenever flying with energy in the hold
	var f = main.flight
	if f.state() == "flying" and not bool(f.boost_on()) and f.hold_units("energy") > 0 and int(f.boost_charges()) > 0:
		a.set_boost(true)


func _skills() -> void:
	var br: String = main.run_branch().to_upper()
	var order: Array = ["FND_STORAGE", "FND_PERMIT", "FND_PROSPECT", br + "_1", "FND_DOCKS"]
	order.append_array(branch_order())
	learn_in_order(order, 3)


func _reserve() -> int:
	return maxi(300, routes_cost() * 2)


# ---- accounting of the previous cycle ----------------------------------------------------------------------------------------

func _flow(kind: String, key: String, c: int) -> int:
	var d: Dictionary = bot.cyc.get(kind, {})
	return int(d.get(key, {}).get(str(c), 0))


func _account(c: int) -> void:
	var p := c - 1
	if p >= 1:
		var hand := _flow("income", "hand_sales", p) - _flow("spend", "hand_buys", p)
		var gig := _flow("income", "flight_gigs", p) + _flow("income", "salvage", p) + _flow("income", "events", p)
		var lane := _flow("income", "local_sales", p) + _flow("income", "routes_stop_sales", p) + _flow("income", "hubs", p) \
			- _flow("spend", "local_buys", p) - _flow("spend", "route_costs", p)
		_hand_net += hand
		_gig_in += gig
		_lane_in += lane
		_cycles_counted += 1
		if _cycles_counted <= 40 and (_cycles_counted % 4 == 1):
			note("cycle %d: hand %d gigs %d lanes %d" % [p, hand, gig, lane])
	# gig bookkeeping: what left the board since last cycle
	var now_ids := {}
	for o in main.gigs.offers:
		var uid := str(o["uid"])
		now_ids[uid] = true
		if not _seen.has(uid):
			_seen[uid] = {"kind": str(o["kind"]), "id": str(o["id"])}
			if str(o["kind"]) == "rush":
				var rg := str(o["req"]["good"])
				_rush_goods[rg] = int(_rush_goods.get(rg, 0)) + 1
	var rush_delta: int = int(main.gigs.rush_done) - _rush_done0
	_rush_done0 = int(main.gigs.rush_done)
	for uid in _seen.keys():
		if now_ids.has(uid):
			continue
		var s: Dictionary = _seen[uid]
		var k := str(s["kind"])
		if not _expired.has(k):
			k = "other"
		if k == "rush":
			if rush_delta > 0:
				rush_delta -= 1
				_done["rush"] += 1
			else:
				_expired["rush"] += 1
		elif bool(main.gigs.done.get(str(s["id"]), false)):
			_done[k] += 1
		elif bool(main.gigs.skipped.get(str(s["id"]), false)):
			_expired[k] += 1
		else:
			_done[k] += 1  # salvage pods are scooped without a done mark
		_seen.erase(uid)


func _summary() -> void:
	var idle := 0.0 if _all_chunks == 0 else float(_idle_chunks) / float(_all_chunks)
	var s := "SUMMARY cycles %d hand_net %d gigs %d lanes %d | gigs done %s expired %s | flagship idle %d%% | no_trade_cycles %d no_gig_cycles %d plans %d rush goods %s" % [
		_cycles_counted, _hand_net, _gig_in, _lane_in, str(_done), str(_expired), int(idle * 100.0), _no_trade_cycles, _no_gig_cycles, _plans, str(_rush_goods)]
	if _sum_idx < 0:
		notes.append(s)
		_sum_idx = notes.size() - 1
	else:
		notes[_sum_idx] = s


# ---- lanes: two or three for a base income -----------------------------------------------------------------------------------

func _can_pay_lane() -> bool:
	if a.free_ships() > 0:
		return true
	return int(main.ships) < int(main.ship_cap()) and main.cash - a.ship_price() >= _reserve()


func _lanes(c: int) -> void:
	if main.engine.routes.size() >= MAX_LANES or c < 2:
		return
	var worlds: Array = a.open_worlds()
	if worlds.size() < 2:
		return
	for l in a.known_lanes(maxi(5, int(main.engine.fixed_cost()))):
		if not _can_pay_lane():
			break
		var s := int(l["src"])
		var d := int(l["dst"])
		var g := str(l["c"])
		if has_lane(s, d, g) or has_lane(d, s, g):
			continue
		if make_lane(s, d, g, "buy") >= 0:
			note("lane %s %s->%s m%d" % [g, a.world_name(s), a.world_name(d), int(l["margin"])])
			return
	for r in main.engine.routes.duplicate():
		if str(r["state"]) == "blocked" and not main.move_offer(int(r["id"])).is_empty():
			a.move_ship(int(r["id"]))
	a.accept_sell_offer()


func _permit() -> void:
	for sid in main.Systems.ids():
		if main.open_systems.has(sid) or _perm_tried.has(sid):
			continue
		var st: Dictionary = a.permit_status(int(sid))
		if str(st["reason"]) == "credits" or str(st["reason"]) == "":
			if main.cash >= int(main.permit_cost(int(sid))) + 1500:
				if not bool(a.buy_permit(int(sid))["ok"]):
					_perm_tried[sid] = true
				else:
					note("permit system %d" % int(sid))
		return


# ---- the Flagship ----------------------------------------------------------------------------------------------------------------

func _flagship(c: int) -> void:
	if main.flight.state() == "flying" and a.fs.is_empty() and bool(main.flight.exploring()):
		# exploration mode: let it run a few cycles, then take control again
		if c - _explore_on_cycle >= 4:
			a.set_exploring(false)
		return
	if a.fs_busy():
		return
	if bool(main.flight.exploring()):
		a.set_exploring(false)
	var f = main.flight
	# energy: top up for the boost whenever a dock is planned (see _energy_todo)
	# 1. every gig on the board
	var had_gig := false
	for o in main.gigs.offers:
		if bool(o.get("accepted", false)):
			continue
		var k := str(o.get("kind", ""))
		if k == "opening":
			continue  # the Bazaar's charter run belongs to the founder style
		if k == "rush":
			if _plan_rush(o):
				had_gig = true
				return
			continue
		var r: Dictionary = a.accept_gig(str(o["uid"]))
		if bool(r["ok"]):
			had_gig = true
			note("gig %s accepted" % k)
			a.fs_clear()
			return
		else:
			note("gig %s refused: %s" % [k, str(r["reason"]).substr(0, 60)])
	if not had_gig:
		_no_gig_cycles += 1
	# 2. worlds to open: first once in exploration mode, then a post on each by hand
	if not _explored_mode_done and c >= 2:
		_explored_mode_done = true
		_explore_on_cycle = c
		var r2: Dictionary = a.set_exploring(true)
		note("exploration mode %s %s" % ["on" if bool(r2["ok"]) else "refused", str(r2["reason"]).substr(0, 60)])
		if bool(r2["ok"]):
			return
	for i in unexplored(0):
		if a.is_dead(i):
			continue
		var cost := establish_cost(i)
		if cost < 0 or int(_est_fail.get(i, 0)) >= 3:
			continue
		if main.cash < cost + _reserve() + 150:
			break
		_est_fail[i] = int(_est_fail.get(i, 0)) + 1
		a.fs_queue({"op": "fly_establish", "planet": i})
		note("establish " + a.world_name(i))
		return
	# 3. hand trade
	if not _plan_trade(c):
		_no_trade_cycles += 1


func _energy_todo() -> Array:
	var t: Array = []
	if main.flight.hold_units("energy") < 3 and main.flight.hold_space() > 3:
		t.append(["buy", "energy", 3])
	return t


var _skips := 0
var _rush_goods := {}


func _skip(t: String) -> void:
	_skips += 1
	if _skips <= 12:
		note("skip " + t)


## Rush order: buy the good at the cheapest world, deliver by hand sale before the deadline.
func _plan_rush(o: Dictionary) -> bool:
	var dst := int(o["target"].get("index", -1))
	var g := str(o["req"]["good"])
	var need := int(o["req"]["units"]) - int(o["req"].get("got", 0))
	if dst < 0 or need <= 0:
		return false
	var left: float = float(o["due"]) - float(main.gigs._now())
	var f = main.flight
	var dpid := str(main.map.planets[dst].get("id", ""))
	var have: int = f.hold_units(g)
	if have >= need:
		var eta: float = float(f.eta_cycles(dpid))
		if eta < 0.0 or eta * 1.2 > left:
			_skip("rush %s: eta %.2f left %.2f" % [g, eta, left])
			return false
		a.fs_queue({"op": "dock", "planet": dst, "todo": [["sell", g, need]]})
		note("rush %s x%d to %s (in hold)" % [g, need, a.world_name(dst)])
		_plans += 1
		return true
	var s: Dictionary = a.best_source(g, dst)
	var src := int(s["src"])
	var kind := "buy"
	if src < 0:
		# no world sells it: take it out of Company storage (load), when some world holds enough
		for w in a.open_worlds():
			if int(main.storage.amount(main.storage.planet_key(int(w)), g)) >= need - have:
				src = int(w)
				kind = "load"
				break
	if src < 0:
		_skip("rush %s at %s: no source" % [g, a.world_name(dst)])
		return false
	var spid := str(main.map.planets[src].get("id", ""))
	var e1: float = float(f.eta_cycles(spid))
	var e2: float = float(f.eta_cycles(dpid))
	if e1 < 0.0 or e2 < 0.0 or (e1 + e2) * 1.3 > left or int(f.hold_space()) < need - have:
		_skip("rush %s x%d: e1 %.2f e2 %.2f left %.2f space %d" % [g, need, e1, e2, left, int(f.hold_space())])
		return false
	a.fs_queue({"op": "dock", "planet": src, "todo": [[kind, g, need - have]]})
	a.fs_queue({"op": "dock", "planet": dst, "todo": [["sell", g, need]]})
	note("rush %s x%d %s -> %s" % [g, need, a.world_name(src), a.world_name(dst)])
	_plans += 1
	return true


## Best hand trade: cheap world -> world that pays most (hungry worlds get a bonus), per cycle of flying.
func _plan_trade(c: int) -> bool:
	var f = main.flight
	var worlds: Array = a.open_worlds()
	var sys: int = int(f.system_id())
	var cap: int = int(f.hold_cap())
	if cap <= 0 or worlds.size() < 2:
		return false
	var best := 0.0
	var plan: Array = []
	for s in worlds:
		if int(main.system_of(s)) != sys:
			continue
		var spid := str(main.map.planets[s].get("id", ""))
		var e1: float = float(f.eta_cycles(spid)) if str(f.docked_at()) != spid else 0.0
		if e1 < 0.0:
			continue
		for d in worlds:
			if d == s or int(main.system_of(d)) != sys:
				continue
			var dpid := str(main.map.planets[d].get("id", ""))
			var e2: float = float(f.eta_cycles(dpid))
			if e2 < 0.0:
				continue
			var hungry := {}
			for n in a.unmet_needs(d):
				hungry[str(n["good"])] = true
			for g in a.goods_visible():
				var gs := str(g)
				var buy: int = main.trade.price(s, gs + "_buy")
				var sell: int = main.engine.sold_price(d, gs)
				if buy <= 0 or sell <= 0 or sell <= buy:
					continue
				var units := mini(cap - 3, maxi(1, int(main.cash * 0.8) / buy))
				var gain: float = float(sell - buy) * float(units) * (1.3 if hungry.has(gs) else 1.0)
				var score: float = gain / (e1 + e2 + 0.2)
				if score > best:
					best = score
					plan = [s, d, gs, units]
	if plan.is_empty():
		return false
	var src := int(plan[0])
	var dst := int(plan[1])
	var good := str(plan[2])
	var todo: Array = _energy_todo()
	todo.append(["buy", good, int(plan[3])])
	a.fs_queue({"op": "dock", "planet": src, "todo": todo})
	a.fs_queue({"op": "dock", "planet": dst, "todo": [["sell", good, 999]]})
	_plans += 1
	if _plans <= 25 or _plans % 10 == 0:
		note("trade %s x%d %s -> %s score %d" % [good, int(plan[3]), a.world_name(src), a.world_name(dst), int(best)])
	return true
