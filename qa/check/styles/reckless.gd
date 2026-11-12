extends "res://qa/check/styles/base.gd"
## Style "reckless": a bad player on purpose, to exercise the loss path.
## Buys a ship whenever allowed, puts ships on losing or empty lanes, turns on Buy orders nobody buys, pays every event fee,
## never learns a skill, sometimes removes a paying route, dumps stuck stock with the salvage sale.
## Notes record the cycle of the first negative cash, each repossession, each stipend and the ending.

const FITTING := ["ceo_man_01", "ceo_man_02", "ceo_woman_01", "ceo_woman_02"]

var _neg_seen := false
var _repo := 0
var _resc := 0
var _free_dead := 0   # cycles in a row alive with no ship, no stipend left and cash below a ship price (stuck check)
var _stuck_noted := false
var _min_cash := 1 << 30


func fitting_ceos() -> Array:
	return FITTING


func event_policy() -> String:
	return "first"


func each_cycle(c: int) -> void:
	_track(c)
	if bool(main.game_over):
		return
	_expand()
	_waste()
	_remove_paying(c)
	_dump_stock()
	a.accept_sell_offer()


func _track(c: int) -> void:
	_min_cash = mini(_min_cash, int(main.cash))
	if not _neg_seen and int(main.cash) < 0:
		_neg_seen = true
		note("FIRST NEGATIVE CASH %d" % int(main.cash))
	if int(main.repossessions) > _repo:
		note("repossession #%d (ships %d cash %d)" % [int(main.repossessions), int(main.ships), int(main.cash)])
		_repo = int(main.repossessions)
	if int(main.rescues_paid) > _resc:
		note("stipend #%d (cash %d)" % [int(main.rescues_paid), int(main.cash)])
		_resc = int(main.rescues_paid)
	# alive with nothing: no ship, stipends spent, cannot afford a ship
	if int(main.ships) == 0 and int(main.rescues_paid) >= int(main.balance.get("rescue_max", 2)) and int(main.cash) < a.ship_price():
		_free_dead += 1
		if _free_dead >= 2 and not _stuck_noted:
			_stuck_noted = true
			note("STUCK ALIVE: no ship, no stipend, cash %d, cycle continues %d cycles" % [int(main.cash), _free_dead])
	else:
		_free_dead = 0


## Buy ships as often as the game allows, then put each free ship on the worst lane found.
func _expand() -> void:
	var guard := 0
	while guard < 6:
		guard += 1
		if not bool(a.buy_ship()["ok"]):
			break
	var worlds: Array = a.open_worlds()
	if worlds.size() < 2:
		# nothing open: still nothing to do; the Flagship may open a neighbour (costs cash: reckless pays)
		if not a.fs_busy():
			for i in unexplored(0):
				if establish_cost(i) >= 0 and not a.is_dead(i):
					a.fs_queue({"op": "fly_establish", "planet": i})
					break
		return
	# worst lanes first: lowest margin, any visible good
	var cand: Array = a.known_lanes(-100000)
	cand.sort_custom(func(x, y): return int(x["margin"]) < int(y["margin"]))
	var made := 0
	for l in cand:
		if made >= 6 or a.free_ships() <= 0:
			break
		var s := int(l["src"])
		var d := int(l["dst"])
		var g := str(l["c"])
		if has_lane(s, d, g) or int(l["margin"]) > 0:
			continue  # only losing lanes: a lane that pays is never built
		if make_lane(s, d, g, "card") >= 0:
			made += 1
			note("lane %s %s->%s m%d" % [g, a.world_name(s), a.world_name(d), int(l["margin"])])


## Buy orders with no buyer: a Buy order at a world on a good it does not sell cheaply, or any good with no route using it.
func _waste() -> void:
	for w in a.open_worlds():
		for g in a.goods_visible():
			if rng.randf() < 0.5:
				continue
			if bool(main.engine.local_on(w, str(g), "buy")):
				continue
			var r: Dictionary = a.set_order(w, str(g), "buy", true)
			if bool(r["ok"]):
				note("buy order %s at %s with no buyer" % [str(g), a.world_name(w)])
				return


func _remove_paying(c: int) -> void:
	if c % 4 != 0:
		return
	for r in main.engine.routes.duplicate():
		if int(main.route_net(int(r["id"]))) > 0:
			if bool(a.remove_route(int(r["id"]), "panel" if c % 8 == 0 else "right")["ok"]):
				note("removed paying route %d" % int(r["id"]))
			return


func _dump_stock() -> void:
	for w in a.open_worlds():
		for g in a.goods_visible():
			if str(main.engine.salvage_reason(w, str(g))) != "":
				if bool(a.salvage(w, str(g))["ok"]):
					note("salvage %s at %s" % [str(g), a.world_name(w)])
