extends "res://qa/check/styles/base.gd"
## Style "captain": the Flagship is the main tool. Two or three automated lanes for a base income; the Flagship explores and
## establishes every world (exploration mode once, then fly_establish), accepts every signal and salvage gig, unloads scooped pods
## at the nearest established world, boosts, and takes the Opening when posted. No hand trade (removed from the game).
## Notes carry the gig / lane income split, expired gigs and idle Flagship time (the owner's "is the Flagship loop thin" worry).

const FITTING := ["ceo_man_01", "ceo_man_02", "ceo_woman_01", "ceo_woman_02"]
const MAX_LANES := 3

var _est_fail := {}
var _explore_on_cycle := -1
var _explored_mode_done := false
var _perm_tried := {}
var _seen := {}            # gig uid -> {kind, id, accepted}
# totals
var _gig_in := 0
var _lane_in := 0
var _cycles_counted := 0
var _expired := {"signal": 0, "salvage": 0, "other": 0}
var _done := {"signal": 0, "salvage": 0, "other": 0}
var _idle_chunks := 0
var _all_chunks := 0
var _no_gig_cycles := 0
var _unloads := 0
var _sum_idx := -1
var _last_plan := ""


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
		var gig := _flow("income", "flight_gigs", p) + _flow("income", "salvage", p) + _flow("income", "events", p)
		var lane := _flow("income", "local_sales", p) + _flow("income", "routes_stop_sales", p) + _flow("income", "hubs", p) \
			- _flow("spend", "local_buys", p) - _flow("spend", "route_costs", p)
		_gig_in += gig
		_lane_in += lane
		_cycles_counted += 1
		if _cycles_counted <= 40 and (_cycles_counted % 4 == 1):
			note("cycle %d: gigs %d lanes %d" % [p, gig, lane])
	# gig bookkeeping: what left the board since last cycle
	var now_ids := {}
	for o in main.gigs.offers:
		var uid := str(o["uid"])
		now_ids[uid] = true
		if not _seen.has(uid):
			_seen[uid] = {"kind": str(o["kind"]), "id": str(o["id"])}
	for uid in _seen.keys():
		if now_ids.has(uid):
			continue
		var s: Dictionary = _seen[uid]
		var k := str(s["kind"])
		if not _expired.has(k):
			k = "other"
		if bool(main.gigs.done.get(str(s["id"]), false)):
			_done[k] += 1
		elif bool(main.gigs.skipped.get(str(s["id"]), false)):
			_expired[k] += 1
		else:
			_done[k] += 1  # salvage pods are scooped without a done mark
		_seen.erase(uid)


func _summary() -> void:
	var idle := 0.0 if _all_chunks == 0 else float(_idle_chunks) / float(_all_chunks)
	var s := "SUMMARY cycles %d gigs %d lanes %d | gigs done %s expired %s | flagship idle %d%% | no_gig_cycles %d unloads %d" % [
		_cycles_counted, _gig_in, _lane_in, str(_done), str(_expired), int(idle * 100.0), _no_gig_cycles, _unloads]
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
	# 0. unload what the hold carries (scooped pods) at the nearest established world
	if _unload_hold():
		return
	# 1. every gig on the board
	var had_gig := false
	for o in main.gigs.offers:
		if bool(o.get("accepted", false)):
			continue
		var k := str(o.get("kind", ""))
		if k == "opening":
			a.fs_queue({"op": "gig", "uid": str(o["uid"])})
			note("Opening: flying to the Star Bazaar station")
			return
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


## Dock at the nearest established world and unload every good in the hold.
func _unload_hold() -> bool:
	var f = main.flight
	if int(f.hold_total()) <= 0:
		return false
	var best := -1
	var best_eta := 1e9
	for w in a.open_worlds():
		var pid := str(main.map.planets[w].get("id", ""))
		if not bool(f.established(pid)):
			continue
		var e: float = 0.0 if str(f.docked_at()) == pid else float(f.eta_cycles(pid))
		if e >= 0.0 and e < best_eta:
			best_eta = e
			best = int(w)
	if best < 0:
		return false
	var todo: Array = []
	for g in a.goods_visible():
		var n: int = int(f.hold_units(str(g)))
		if n > 0:
			todo.append(["unload", str(g), n])
	if todo.is_empty():
		return false
	a.fs_queue({"op": "dock", "planet": best, "todo": todo})
	_unloads += 1
	note("unload hold at %s" % a.world_name(best))
	return true
