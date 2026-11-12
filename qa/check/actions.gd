extends RefCounted
## Economy check: the action library. One function per player action; every action returns {"ok": bool, "reason": String},
## never throws, and records an attempt (and a success) for its feature id in bot.feat (see qa/check/features.json).
##
## RULE: an action runs only through an entry point a player can reach: a signal a panel or the map emits, or the main.gd
## method that signal or button is connected to (the same handler a click runs). Reading state is free; no debug shortcuts,
## no cash injection, no debug_advance_cycle. A mechanic with engine code but no player entry point is NOT faked here
## (see features.json, entry "none": mining intensity).
##
## Styles hold `a` = this object (bot.act). Time is NOT advanced by any action: the bot clock does that (see bot.gd).
## The Flagship is slow: queue its tasks with fs_* and the bot pumps the queue between clock chunks.
##
## ---- API (feature id : function : UI entry point) ------------------------------------------------------------------
## SETUP    (done by bot.gd)   setup.ceo_pick (SaveGame.pending_ceo), setup.tutorial_skip (tut_skip_btn.pressed), setup.preface
## ORDERS   set_order(planet, good, "buy"|"sell", on)  order.buy_on/off, order.sell_on/off
##            buy: planet_panel.buy_send_requested (the Buy row), sell: planet_panel.order_requested(good, "sell")
##          salvage(planet, good)                      order.salvage       planet_panel.salvage_requested
##          accept_sell_offer()                        route.sell_offer    main.accept_sell_offer (the "Sell here too?" box)
## ROUTES   send(src, dst, good, via)                  route.send_card | route.send_buy | route.send_quick | route.to_station
##            | route.cluster | route.mine_dead | route.cross_system | route.second_ship | route.send_stop
##            via = "card" (planet_panel.send_requested + map.planet_clicked), "buy" (buy_send_requested + click),
##            "quick" (map.good_icon_right_clicked + click), "mine" (planet_panel.mine_requested + click),
##            dst = -system_id sends to that system's Space Storage (map.station_clicked), src = Clusters.node_id(i) = cluster ore
##          send_cluster(cluster_index, dst)           main._on_cluster_send + planet click
##          remove_route(id, via)                      route.remove_panel (planet_panel.remove_requested) |
##                                                     route.remove_right (map.route_right_clicked + menu)
##          upgrade_route(id)                          route.upgrade       main.upgrade_route (Upgrade route button)
##          move_ship(id)                              route.move          main.move_ship (Move ship button)
##          split_lane(src, good, pct) / clear_split   route.split / route.split_clear  main.set_split_percent / clear_split
##          fit_core(route_id)                         workshop.core_fit   main.fit_core (ship card button)
## SHIPS    buy_ship()                                 ship.buy_panel      ship_panel.buy_requested
##          hub_buy_ship(hub)                          ship.buy_hub        the hub panel "Buy a ship for the pool" button logic
## SKILLS   learn_skill(id)                            skill.learn_fnd | skill.learn_branch  main.learn_skill (skill screen Learn)
## WORKSHOP build_workshop(id, sid) / build_fabric() / build_core()   workshop.build_<id>, workshop.fabric, workshop.core_build
##                                                     main.build_workshop / build_fabric / build_null_core (Space Storage view)
## SYSTEMS  buy_permit(sid)                            system.permit       main.buy_permit (galaxy card button)
##          go_system(sid)                             system.go           galaxy_view.system_chosen
##          open_station(sid)                          storage.view        map.station_clicked
##          link_build(a, b) link_order(id, good, from_sys, amount) link_order_remove(id, i) link_remove(id)
##                                                     link.build / link.order / link.order_remove / link.remove  (station view dialogs call storage_link.*)
## FLAGSHIP fly_to(planet) (map.fly_requested)         flag.fly
##          fly_establish(planet) (map.fly_establish_requested, the right-click "Establish" menu)   flag.establish_post / flag.establish_platform
##          establish_here() (map.establish_requested)  flag.establish_post / flag.establish_platform
##          set_exploring(on)                          flag.explore       flagship_panel.explore_toggled
##          set_boost(on)                              flag.boost         flagship_panel.boost_toggled
##          request_dock(planet) / dock_do(kind, good, units) / dock_close()   flag.dock_open, flag.dock_buy/sell/load/unload  (dock sheet buttons)
##          fs_queue(step...) / fs_busy() / fs_pump()  queue of Flagship steps: {"op":"fly","planet":i} {"op":"establish"}
##                {"op":"fly_establish","planet":i} {"op":"dock","planet":i,"todo":[[kind,good,units],...]} {"op":"gig","uid":s}
## GIGS     accept_gig(uid)                            gig.accept          gig_board accept button (main.gig_panel._on_accept)
## HUBS     make_hub(planet) hub_pool(hub, n) hub_world(hub, world, on) hub_need(hub, world, good, on) release_hub(hub)
##                                                     hub.designate / hub.pool / hub.world / hub.need / hub.release  (planet panel + hub panel)
## BAZAAR   found_bazaar(planet)                       bazaar.found        planet_panel.found_bazaar_requested
##          pick_wing(idx)                             bazaar.wing         bazaar_panel wing card button
## EVENTS   answer_events(policy)                      event.*             event_notice.confirmed (a click on a choice or Continue)
## END      press_continue()                           end.continue        end_screen.continue_pressed
##
## ---- read-only helpers (free) ---------------------------------------------------------------------------------------
## close_overlays() (Close buttons)  goods_visible() open_worlds() world_name(i) known_lanes(min_margin) needs_of(i) unmet_needs(i) free_ships() ship_price()
## can_afford(n) cash() lanes_at(i) lane_count(a,b,c) route_list() workshop_lacks(id) bazaar_status() best_source(good, dst)
## worlds_by_tier() skill_ids_open() permit_status(sid) cluster_list() dead_worlds() hub_candidates() link_candidates()

# game scripts are loaded at run time (a preload here could hit a script-cycle while main is still compiling)
var Clusters = null
var DeadWorlds = null
var SkillTree = null

var bot: Object = null
var main: Node:
	get:
		return bot.main
var fs: Array = []  # Flagship step queue
var fs_note := ""   # last Flagship pump note (for the report)


func setup(b: Object) -> void:
	bot = b
	Clusters = load("res://game/clusters.gd")
	DeadWorlds = load("res://game/dead_worlds.gd")
	SkillTree = load("res://game/skill_tree.gd")


# ---- plumbing ---------------------------------------------------------------------------------------------------------

func _res(fid: String, ok: bool, reason: String = "", mutating: bool = true) -> Dictionary:
	if bot != null:
		bot.record_feature(fid, ok, reason, mutating)
	return {"ok": ok, "reason": reason}


## Text of the board notice the last click produced (a refusal posts its reason there).
func _notice() -> String:
	return str(main.shown_notice)


func _clear_pending() -> void:
	if main != null and not main.pending.is_empty():
		main.cancel_pending()


func cash() -> int:
	return int(main.cash)


func world_name(i: int) -> String:
	return str(main.planet_name(i)) if i >= 0 else "station"


func _spend(sink: String, cash_before: int) -> void:
	bot.add_flow(sink, cash_before - int(main.cash))


# ---- read-only helpers --------------------------------------------------------------------------------------------------

func goods_visible() -> Array:
	return Availability.visible_goods(main.commodities)


## Established worlds whose system trades (post stands, space storage there when not system 1).
func open_worlds() -> Array:
	var out: Array = []
	for i in main.map.planets.size():
		if main.planet_established(i) and main.system_trade_open(i):
			out.append(i)
	return out


func free_ships() -> int:
	return int(main.free_ships())


func ship_price() -> int:
	return int(main.ship_price())


func can_afford(n: int) -> bool:
	return int(main.cash) >= n


func lane_count(a: int, b: int, c: String) -> int:
	return int(main.engine.lane_count(a, b, c))


func route_list() -> Array:
	return main.engine.routes


func lanes_at(i: int) -> Array:
	var out: Array = []
	for r in main.engine.routes:
		if int(r["a"]) == i or int(r["b"]) == i:
			out.append(r)
	return out


func is_dead(i: int) -> bool:
	return DeadWorlds.is_dead(main.map.planets[i])


## Candidate lanes src -> dst for visible goods, best margin per cycle first.
## Each {src, dst, c, margin, buy, sell, ok, reason}. Only lanes the game accepts now unless include_blocked.
func known_lanes(min_margin: int = 1, include_blocked: bool = false) -> Array:
	var out: Array = []
	var worlds := open_worlds()
	var goods := goods_visible()
	for s in worlds:
		for d in worlds:
			if s == d:
				continue
			for c in goods:
				var buy: int = main.trade.price(s, str(c) + "_buy")
				var sell: int = main.engine.sold_price(d, str(c))
				if buy < 0 or sell < 0:
					continue
				var m: int = main.engine.route_margin(s, d, str(c))
				if m < min_margin:
					continue
				var chk: Dictionary = main.engine.check_connection(s, d, str(c))
				if not bool(chk["ok"]) and not include_blocked:
					continue
				out.append({"src": s, "dst": d, "c": str(c), "margin": m, "buy": buy, "sell": sell, "ok": bool(chk["ok"]), "reason": str(chk["reason"])})
	out.sort_custom(func(x, y): return int(x["margin"]) > int(y["margin"]))
	return out


## Needs of a world: [{good, demand, sold, met, locked}] (locked goods show as "?").
func needs_of(i: int) -> Array:
	return main.prosperity.needs(i)


func unmet_needs(i: int) -> Array:
	var out: Array = []
	for n in needs_of(i):
		if not bool(n["locked"]) and not bool(n["met"]):
			out.append(n)
	return out


## Cheapest open source of a good for a destination: {src, buy} or {src: -1}.
func best_source(c: String, dst: int) -> Dictionary:
	var best := {"src": -1, "buy": 1 << 30}
	for s in open_worlds():
		if s == dst:
			continue
		var b: int = main.trade.price(s, c + "_buy")
		if b >= 0 and b < int(best["buy"]) and bool(main.engine.check_connection(s, dst, c)["ok"]):
			best = {"src": s, "buy": b}
	if int(best["src"]) < 0:
		best["buy"] = -1
	return best


func worlds_by_tier() -> Dictionary:
	var per := {}
	for i in main.map.planets.size():
		var t: int = main.prosperity.tier(i)
		if t >= 1:
			per[t] = int(per.get(t, 0)) + 1
	return per


## What a built (or unbuilt) workshop lacks: {built, state, reason, missing: [goods]}.
func workshop_lacks(id: String) -> Dictionary:
	var ws = main.workshops
	return {"built": bool(ws.built.get(id, false)), "state": str(ws.state.get(id, "")), "reason": str(ws.reason.get(id, "")), "missing": ws.missing.get(id, []).duplicate()}


func bazaar_status() -> Dictionary:
	var b = main.bazaar
	return {"founded": b.is_founded(), "capital": b.capital(), "stage": b.stage(), "total": b.stages_total(), "bill": b.bill_status(),
		"quorum": b.quorum_status(), "reach_needed": b.reach_needed(), "reach_ok": b.reach_ok(), "wing_pending": b.wing_pending,
		"opening_pending": b.opening_pending, "opened": b.opened, "ready": b.stage_ready()}


func permit_status(sid: int) -> Dictionary:
	return main.can_buy_permit(sid)


func skill_ids_open() -> Array:
	var out: Array = []
	for id in SkillTree.all_ids():
		if bool(SkillTree.can_learn(main.learned_skills, main.skill_points, main.balance, str(id))["ok"]):
			out.append(str(id))
	return out


func cluster_list() -> Array:
	return main.clusters_in_system(0)


func dead_worlds() -> Array:
	var out: Array = []
	for i in main.map.planets.size():
		if is_dead(i):
			out.append(i)
	return out


func hub_candidates() -> Array:
	var out: Array = []
	for i in main.map.planets.size():
		if int(main.prosperity.tier(i)) >= int(main.balance.get("hub_tier", 3)) and not main.hubs.is_hub(i) and bool(main.hubs.can_designate(i)["ok"]):
			out.append(i)
	return out


func link_candidates() -> Array:
	var out: Array = []
	var sts: Array = main.station_systems
	for x in sts:
		for y in sts:
			if int(x) < int(y) and str(main.storage_link.can_build(int(x), int(y))) == "":
				out.append([int(x), int(y)])
	return out


# ---- orders -------------------------------------------------------------------------------------------------------------

## Closes every open window (what each Close button does), so map clicks reach the map again.
func close_overlays() -> void:
	for n in [main.skill_screen, main.bazaar_panel, main.hub_panel, main.gig_panel, main.flagship_panel, main.galaxy_view]:
		if n != null and is_instance_valid(n) and n.visible:
			if n.has_method("close_screen"):
				n.close_screen()
			elif n.has_method("close_view"):
				n.close_view()
	if main.space_storage_view != null and main.space_storage_view.visible:
		main.space_storage_view.close_view()


func select(i: int) -> void:
	_clear_pending()
	main.map.planet_clicked.emit(i)


## Standing Buy / Sell order. No-op ok when already in the wanted state.
func set_order(planet: int, c: String, role: String, on: bool) -> Dictionary:
	var fid := "order.%s_%s" % [role, "on" if on else "off"]
	if bool(main.engine.local_on(planet, c, role)) == on:
		return {"ok": true, "reason": "already"}
	if main.game_over:
		return _res(fid, false, "game over")
	if on:
		if not main.planet_established(planet):
			return _res(fid, false, str(main.closed_world_reason()))
		if not main.system_trade_open(planet):
			return _res(fid, false, str(main.trade_locked_reason()))
		var chk: Dictionary = main.engine.check_local(planet, c, role)
		if not bool(chk["ok"]):
			return _res(fid, false, str(chk["reason"]))
	select(planet)
	if role == "buy":
		main.planet_panel.buy_send_requested.emit(c)  # the Buy row: toggles the order; on = a send chain is pending
		_clear_pending()
	else:
		main.planet_panel.order_requested.emit(c, "sell")
	var now: bool = bool(main.engine.local_on(planet, c, role))
	if now == on:
		return _res(fid, true)
	return _res(fid, false, _notice())


func salvage(planet: int, c: String) -> Dictionary:
	if str(main.engine.salvage_reason(planet, c)) == "":
		return _res("order.salvage", false, "salvage not offered", false)
	var c0 := cash()
	select(planet)
	main.planet_panel.salvage_requested.emit(c)
	if cash() > c0:
		bot.add_flow("salvage", cash() - c0, true)
		return _res("order.salvage", true)
	return _res("order.salvage", false, _notice())


func accept_sell_offer() -> Dictionary:
	if main.sell_offer.is_empty():
		return {"ok": false, "reason": "no offer"}
	var p: int = int(main.sell_offer["planet"])
	var c: String = str(main.sell_offer["c"])
	main.accept_sell_offer()
	if bool(main.engine.local_on(p, c, "sell")):
		return _res("route.sell_offer", true)
	return _res("route.sell_offer", false, _notice())


# ---- routes -------------------------------------------------------------------------------------------------------------

func _send_feature(src: int, dst: int, c: String, via: String) -> String:
	if dst < 0:
		return "route.to_station"
	if src < 0 or Clusters.is_node(src):
		return "route.cluster"
	if via == "mine":
		return "route.mine_dead"
	return {"card": "route.send_card", "buy": "route.send_buy", "quick": "route.send_quick"}.get(via, "route.send_card")


## One lane ship from src to dst carrying c. Also counts the extra-ship, cross-system and stop features when they apply.
## Buys a ship when none is free (that is what the real Send does). Returns {ok, reason, id}.
func send(src: int, dst: int, c: String, via: String = "card") -> Dictionary:
	var fid := _send_feature(src, dst, c, via)
	if main.game_over:
		return _res(fid, false, "game over")
	var chk: Dictionary = main.can_connect(src, dst, c)
	if not bool(chk["ok"]) and int(main.free_ships()) <= 0 and str(chk["reason"]) == str(main.StoryText.get_text("NOT_SHIP_FREE")):
		chk = main.can_buy_ship()  # Send buys the ship itself
	if not bool(chk["ok"]):
		return _res(fid, false, str(chk["reason"]))
	if via == "quick" and int(main.storage.amount(main.storage.planet_key(src), c)) <= 0 and not bool(main.engine.local_on(src, c, "buy")):
		return _res(fid, false, "quick send needs stock or a Buy order")
	var n0: int = main.engine.routes.size()
	var lanes0: int = int(main.engine.lane_count(src, dst, c)) if src >= 0 and not Clusters.is_node(src) else 0
	var ships0: int = int(main.ships)
	var c0 := cash()
	_clear_pending()
	if Clusters.is_node(src):
		main._on_cluster_send(Clusters.index_of(src))
	else:
		match via:
			"quick":
				main.map.good_icon_right_clicked.emit(src, c)
			"buy":
				select(src)
				if bool(main.engine.local_on(src, c, "buy")):
					main.planet_panel.send_requested.emit(c)  # Buy already on: plain Send (a second Buy click would switch it off)
				else:
					main.planet_panel.buy_send_requested.emit(c)
			"mine":
				select(src)
				main.planet_panel.mine_requested.emit(c)
			_:
				select(src)
				main.planet_panel.send_requested.emit(c)
	if dst < 0:
		main.map.station_clicked.emit(-dst)
	else:
		main.map.planet_clicked.emit(dst)
		if not main.pending.is_empty() and main.pending.has("dest"):
			main.map.planet_clicked.emit(dst)  # a stop was offered on the way: click the destination again to send direct
	var pend_left: bool = not main.pending.is_empty()
	_clear_pending()
	if main.engine.routes.size() <= n0:
		return _res(fid, false, _notice() if not pend_left else "click did not make a route: " + _notice())
	var rid: int = int(main.engine.routes[main.engine.routes.size() - 1]["id"])
	_res(fid, true)
	if lanes0 >= 1:
		_res("route.second_ship", true)
	if dst >= 0 and not Clusters.is_node(src) and int(main.system_of(src)) != int(main.system_of(dst)):
		_res("route.cross_system", true)
	if int(main.ships) > ships0:
		bot.add_flow("ships", c0 - cash() if c0 > cash() else 0)
	return {"ok": true, "reason": "", "id": rid}


func send_cluster(cluster_index: int, dst: int) -> Dictionary:
	return send(Clusters.node_id(cluster_index), dst, str(main.clusters.good_of(cluster_index)))


func remove_route(id: int, via: String = "panel") -> Dictionary:
	var fid := "route.remove_panel" if via == "panel" else "route.remove_right"
	if int(main.engine.find_by_id(id)) < 0:
		return _res(fid, false, "no such route")
	_clear_pending()
	if via == "panel":
		main.planet_panel.remove_requested.emit(id)
	else:
		close_overlays()
		var old = main._route_menu
		main.map.route_right_clicked.emit(id, Vector2(200, 200))
		if main._route_menu == null or main._route_menu == old:
			return _res(fid, false, "right-click ignored (overlay open, pending send or lock: map_overlays_blocked=%s)" % str(main.map_overlays_blocked()))
		main._route_menu.id_pressed.emit(0)
	if int(main.engine.find_by_id(id)) < 0:
		return _res(fid, true)
	return _res(fid, false, _notice())


func upgrade_route(id: int) -> Dictionary:
	var c0 := cash()
	var r: Dictionary = main.upgrade_route(id)
	if bool(r["ok"]):
		_spend("upgrades", c0)
	return _res("route.upgrade", bool(r["ok"]), str(r["reason"]))


func move_ship(id: int) -> Dictionary:
	var r: Dictionary = main.move_ship(id)
	return _res("route.move", bool(r["ok"]), str(r["reason"]))


func split_lane(src: int, c: String, pct: int = 50) -> Dictionary:
	if main.split_pair(src, c).is_empty():
		return _res("route.split", false, "needs two lanes of one good from this world")
	main.set_split_percent(src, c, pct)
	var sp: Dictionary = main.engine.lane_split(src, int(main.split_pair(src, c)[0]), c)
	return _res("route.split", not sp.is_empty(), "" if not sp.is_empty() else "split not set")


func clear_split(src: int, c: String) -> Dictionary:
	main.clear_split(src, c)
	return _res("route.split_clear", true)


func fit_core(route_id: int) -> Dictionary:
	var r: Dictionary = main.fit_core(route_id)
	return _res("workshop.core_fit", bool(r["ok"]), str(r["reason"]))


# ---- ships --------------------------------------------------------------------------------------------------------------

func buy_ship() -> Dictionary:
	var chk: Dictionary = main.can_buy_ship()
	if not bool(chk["ok"]):
		return _res("ship.buy_panel", false, str(chk["reason"]))
	var n0: int = int(main.ships)
	var c0 := cash()
	main.ship_panel.buy_requested.emit(main.ship_type)
	if int(main.ships) > n0:
		_spend("ships", c0)
		return _res("ship.buy_panel", true)
	return _res("ship.buy_panel", false, _notice())


## Hub panel "Buy a ship for the pool": buys a ship (main.buy_ship) and puts it in the pool when the hub has room.
func hub_buy_ship(hub: int) -> Dictionary:
	var hs = main.hubs
	if not hs.is_hub(hub):
		return _res("ship.buy_hub", false, "not a hub")
	if hs.free_for_pool() > 0:
		return _res("ship.buy_hub", false, "panel offers the button only with no free ship")
	if hs.pool_of(hub) >= int(main.balance.get("hub_pool_max", 0)):
		return _res("ship.buy_hub", false, "pool full")
	var c0 := cash()
	var r: Dictionary = main.buy_ship()
	if not bool(r["ok"]):
		return _res("ship.buy_hub", false, str(r["reason"]))
	hs.set_pool(hub, hs.pool_of(hub) + 1)
	_spend("ships", c0)
	return _res("ship.buy_hub", true)


# ---- skills -------------------------------------------------------------------------------------------------------------

func learn_skill(id: String) -> Dictionary:
	var fid := "skill.learn_fnd" if id.begins_with("FND_") else "skill.learn_branch"
	var r: Dictionary = main.learn_skill(id)
	var why := str(r.get("reason", ""))
	if why == "earn":
		why = "earn: " + str(r.get("text", ""))
	return _res(fid, bool(r["ok"]), why)


# ---- workshops, fabric, core ------------------------------------------------------------------------------------------

func build_workshop(id: String, sid: int = 1) -> Dictionary:
	var fid := "workshop.build_" + id
	var chk: Dictionary = main.can_build_workshop(id, sid)
	if not bool(chk["ok"]):
		return _res(fid, false, str(chk["reason"]))
	var c0 := cash()
	main.build_workshop(id, sid)
	if bool(main.workshops.built.get(id, false)):
		_spend("workshops", c0)
		return _res(fid, true)
	return _res(fid, false, _notice())


func build_fabric() -> Dictionary:
	var chk: Dictionary = main.can_build_fabric()
	if not bool(chk["ok"]):
		return _res("workshop.fabric", false, str(chk["reason"]))
	var c0 := cash()
	main.build_fabric()
	_spend("workshops", c0)
	return _res("workshop.fabric", bool(main.fabric.built))


func build_core() -> Dictionary:
	var chk: Dictionary = main.can_build_core()
	if not bool(chk["ok"]):
		return _res("workshop.core_build", false, str(chk["reason"]))
	var c0 := cash()
	main.build_null_core()
	_spend("null_core", c0)
	answer_events("first")  # the build opens a one-button popup
	return _res("workshop.core_build", true)


# ---- systems and storage ----------------------------------------------------------------------------------------------

func buy_permit(sid: int) -> Dictionary:
	var c0 := cash()
	var r: Dictionary = main.buy_permit(sid)
	if bool(r["ok"]):
		_spend("permits", c0)
	return _res("system.permit", bool(r["ok"]), str(r["reason"]))


func go_system(sid: int) -> Dictionary:
	if not main.open_systems.has(sid):
		return _res("system.go", false, "system not open", false)
	main.galaxy_view.system_chosen.emit(sid)
	return _res("system.go", int(main.view_system) == sid, "", false)


func open_station(sid: int) -> Dictionary:
	_clear_pending()
	if not main.space_post_open(sid):
		return _res("storage.view", false, str(main.trade_locked_reason()), false)
	main.map.station_clicked.emit(sid)
	return _res("storage.view", main.space_storage_view.visible, "", false)


func link_build(a: int, b: int) -> Dictionary:
	var why := str(main.storage_link.can_build(a, b))
	if why != "":
		return _res("link.build", false, why)
	var id: int = int(main.storage_link.build_link(a, b))
	return _res("link.build", id >= 0, "" if id >= 0 else "build refused")


func link_order(id: int, good: String, from_sys: int, amount: int) -> Dictionary:
	var ok: bool = bool(main.storage_link.set_order(id, good, from_sys, amount))
	return _res("link.order", ok, "" if ok else "link refused the order")


func link_order_remove(id: int, index: int) -> Dictionary:
	var ok: bool = bool(main.storage_link.remove_order(id, index))
	return _res("link.order_remove", ok, "" if ok else "no such order")


func link_remove(id: int) -> Dictionary:
	var ok: bool = bool(main.storage_link.remove_link(id))
	return _res("link.remove", ok, "" if ok else "no such link")


# ---- Flagship -----------------------------------------------------------------------------------------------------------

func fly_to(planet: int) -> Dictionary:
	var f = main.flight
	if not f.is_enabled():
		return _res("flag.fly", false, "flagship off")
	if f.state() == "building":
		return _res("flag.fly", false, "building")
	var pid := str(main.map.planets[planet].get("id", ""))
	if f.docked_at() == pid and f.state() == "idle":
		return {"ok": true, "reason": "already there"}
	main.map.fly_requested.emit({"kind": "planet", "pos": main.map.positions[planet], "index": planet})
	var ok: bool = f.state() == "flying" or f.docked_at() == pid
	return _res("flag.fly", ok, "" if ok else _notice())


func _establish_feature(planet: int) -> String:
	return "flag.establish_platform" if is_dead(planet) else "flag.establish_post"


## Right-click "Establish" menu item: fly there and start the build on arrival.
func fly_establish(planet: int) -> Dictionary:
	var fid := _establish_feature(planet)
	var f = main.flight
	var pid := str(main.map.planets[planet].get("id", ""))
	if main.planet_established(planet):
		return {"ok": true, "reason": "already"}
	if f.state() == "building":
		return _res(fid, false, "building")
	var acts: Array = f.actions_for(pid)
	if acts.is_empty():
		return _res(fid, false, "no establish action offered here")
	main.map.fly_establish_requested.emit(pid)
	var ok: bool = f.state() == "flying" or f.state() == "building"
	return _res(fid, ok, "" if ok else _notice())


## Start the build at the world the Flagship is docked at (the planet card's Establish button).
func establish_here() -> Dictionary:
	var f = main.flight
	var pid: String = str(f.docked_at())
	if pid == "":
		return _res("flag.establish_post", false, "not docked")
	var planet: int = int(main.planet_index_of(pid))
	var fid := _establish_feature(planet)
	if f.state() != "idle":
		return _res(fid, false, "state " + str(f.state()))
	var c0 := cash()
	main.map.establish_requested.emit(pid)
	var ok: bool = f.state() == "building" or bool(main.planet_established(planet))
	if ok:
		_spend("posts", c0)
	return _res(fid, ok, "" if ok else _notice())


func set_exploring(on: bool) -> Dictionary:
	if bool(main.flight.exploring()) == on:
		return {"ok": true, "reason": "already"}
	main.flagship_panel.explore_toggled.emit()
	return _res("flag.explore", bool(main.flight.exploring()) == on, _notice())


func set_boost(on: bool) -> Dictionary:
	main.flagship_panel.boost_toggled.emit(on)
	return _res("flag.boost", bool(main.flight.boost_on()) == on or not on, _notice(), false)


func request_dock(planet: int) -> Dictionary:
	var pid := str(main.map.planets[planet].get("id", ""))
	if not bool(main.flight.established(pid)):
		return _res("flag.dock_open", false, "no post here", false)
	main.request_dock(pid)
	return _res("flag.dock_open", main.dock_sheet != null or main.flight.state() == "flying", _notice(), false)


## One hand trade on the open dock sheet: kind buy | sell | load | unload (the sheet buttons). units: lot count (buy max = hold cap).
func dock_do(kind: String, good: String, units: int) -> Dictionary:
	var fid := "flag.dock_" + kind
	if main.dock_sheet == null:
		return _res(fid, false, "dock sheet closed", false)
	var f = main.flight
	var h0: int = int(f.hold_total())
	var c0 := cash()
	var st0: int = int(main.storage.amount(main.storage.planet_key(int(main.dock_sheet.planet)), good))
	main.dock_sheet._do(kind, good, units)
	var moved: bool = int(f.hold_total()) != h0 or cash() != c0 or int(main.storage.amount(main.storage.planet_key(int(main.dock_sheet.planet)), good)) != st0
	if kind == "sell" and cash() > c0:
		bot.add_flow("hand_sales", cash() - c0, true)
	elif kind == "buy" and c0 > cash():
		bot.add_flow("hand_buys", c0 - cash())
	return _res(fid, moved, "" if moved else _notice())


func dock_close() -> void:
	if main.dock_sheet != null:
		main.dock_sheet.close_sheet()


func accept_gig(uid: String) -> Dictionary:
	if main.gigs.offer(uid).is_empty():
		return _res("gig.accept", false, "no such offer", false)
	var o: Dictionary = main.gigs.offer(uid)
	var kind := str(o.get("kind", ""))
	main.gig_panel._on_accept(uid)
	var ok: bool = bool(main.gigs.offer(uid).get("accepted", false)) or main.gigs.offer(uid).is_empty()
	_res("gig.accept_" + kind, ok, "" if ok else _notice())
	return _res("gig.accept", ok, "" if ok else _notice())


# ---- Flagship step queue ----------------------------------------------------------------------------------------------

func fs_queue(step: Dictionary) -> void:
	fs.append(step)


func fs_clear() -> void:
	fs.clear()


func fs_busy() -> bool:
	return not fs.is_empty() or main.flight.state() != "idle"


## Called by the bot between clock chunks. Runs the next queued step when the Flagship is idle.
func fs_pump() -> void:
	if fs.is_empty() or main.flight.state() != "idle" or main.dock_sheet != null or main.event_notice != null:
		return
	var step: Dictionary = fs[0]
	var op := str(step.get("op", ""))
	var r := {"ok": true, "reason": ""}
	match op:
		"fly":
			var i := int(step["planet"])
			var pid := str(main.map.planets[i].get("id", ""))
			if main.flight.docked_at() == pid:
				fs.pop_front()
				return
			r = fly_to(i)
			if bool(r["ok"]):
				step["op"] = "wait_arrive"
				step["armed"] = true
				return
		"wait_arrive":
			fs.pop_front()  # idle again: arrived
			return
		"establish":
			r = establish_here()
			if bool(r["ok"]):
				step["op"] = "wait_build"
				return
		"wait_build":
			fs.pop_front()
			return
		"fly_establish":
			var j := int(step["planet"])
			if main.planet_established(j):
				fs.pop_front()
				return
			var pid2 := str(main.map.planets[j].get("id", ""))
			if main.flight.docked_at() == pid2:
				r = establish_here()
			else:
				r = fly_establish(j)
			if bool(r["ok"]):
				step["op"] = "wait_est"
				step["planet"] = j
				return
		"wait_est":
			if main.planet_established(int(step["planet"])):
				fs.pop_front()
				return
			# idle but not built: arrive then build
			var k := int(step["planet"])
			if str(main.flight.docked_at()) == str(main.map.planets[k].get("id", "")):
				r = establish_here()
				if bool(r["ok"]):
					return
			fs_note = "establish did not start: " + str(r["reason"])
			fs.pop_front()
			return
		"dock":
			var p := int(step["planet"])
			var pid3 := str(main.map.planets[p].get("id", ""))
			if str(main.flight.docked_at()) == pid3:
				if main.open_dock_sheet():
					bot.dock_todo = step.get("todo", [])
					fs.pop_front()
					return
				r = {"ok": false, "reason": "sheet did not open"}
			else:
				r = request_dock(p)
				if bool(r["ok"]):
					step["armed"] = true
					bot.dock_todo = step.get("todo", [])
					fs.pop_front()  # the sheet opens by itself on arrival (main._on_flight_arrived)
					return
		"gig":
			r = accept_gig(str(step["uid"]))
			if bool(r["ok"]):
				step["op"] = "wait_arrive"
				return
		_:
			r = {"ok": false, "reason": "unknown op " + op}
	if not bool(r["ok"]):
		fs_note = "%s failed: %s" % [op, str(r["reason"])]
		fs.pop_front()


# ---- hubs ---------------------------------------------------------------------------------------------------------------

func make_hub(planet: int) -> Dictionary:
	var chk: Dictionary = main.hubs.can_designate(planet)
	if not bool(chk["ok"]):
		return _res("hub.designate", false, str(chk["reason"]))
	select(planet)
	main.planet_panel.make_hub_requested.emit(planet)
	return _res("hub.designate", bool(main.hubs.is_hub(planet)), _notice())


func hub_pool(hub: int, n: int) -> Dictionary:
	var got: int = int(main.hubs.set_pool(hub, n))
	main._on_hubs_changed()
	return _res("hub.pool", got == n, "pool is %d" % got)


func hub_world(hub: int, world: int, on: bool) -> Dictionary:
	main.hubs.set_world_off(hub, world, not on)
	return _res("hub.world", bool(main.hubs.is_world_off(hub, world)) == (not on))


func hub_need(hub: int, world: int, good: String, on: bool) -> Dictionary:
	main.hubs.set_need_off(hub, world, good, not on)
	return _res("hub.need", bool(main.hubs.is_need_off(hub, world, good)) == (not on))


func release_hub(hub: int) -> Dictionary:
	if not main.hubs.is_hub(hub):
		return _res("hub.release", false, "not a hub")
	main.hubs.release(hub)
	main._on_hubs_changed()
	return _res("hub.release", not bool(main.hubs.is_hub(hub)))


# ---- Star Bazaar --------------------------------------------------------------------------------------------------------

func found_bazaar(planet: int) -> Dictionary:
	if not bool(main.bazaar.can_found(planet)):
		return _res("bazaar.found", false, "world is tier %d, capital tier is %d" % [int(main.prosperity.tier(planet)), int(main.bazaar.capital_tier())])
	select(planet)
	main.planet_panel.found_bazaar_requested.emit(planet)
	return _res("bazaar.found", bool(main.bazaar.is_founded()), _notice())


func pick_wing(idx: int) -> Dictionary:
	if int(main.bazaar.wing_pending) <= 0:
		return _res("bazaar.wing", false, "no wing pending", false)
	if main.bazaar_panel._wing_popup == null:
		main.bazaar_panel.show_wing_choice()
	main.bazaar_panel._pick_wing(idx)
	return _res("bazaar.wing", int(main.bazaar.wing_pending) == 0, "wing not chosen")


# ---- events and notices -------------------------------------------------------------------------------------------------

## Answers every open notice. policy: "first" | "second" | "seeded" | "last". Returns the number answered.
## An important event waits as an icon: it is opened first (what clicking the icon does).
func answer_events(policy: String = "first") -> int:
	var answered := 0
	var guard := 0
	while guard < 12:
		guard += 1
		if main.event_notice == null and str(main.events.pending_id) != "":
			var pid := str(main.events.pending_id)
			bot.note_event_seen(pid)
			if not bool(main.open_event_icon(pid)):
				_res("event.open_icon", false, "icon would not open")
				break
			_res("event.open_icon", true, "", false)
		if main.event_notice == null:
			break
		var n = main.event_notice
		var enabled: Array = n.enabled_choices
		var pick := -1
		if not enabled.is_empty():
			match policy:
				"second":
					pick = int(enabled[1]) if enabled.size() > 1 else int(enabled[0])
				"last":
					pick = int(enabled[enabled.size() - 1])
				"seeded":
					pick = int(enabled[bot.rng.randi_range(0, enabled.size() - 1)])
				_:
					pick = int(enabled[0])
		var was_id := str(main.events.pending_id)
		var c0 := cash()
		n._confirm(pick)
		answered += 1
		var fid := "event.answer"
		if was_id != "" and bool(main.events.is_chain_step(was_id)):
			fid = "event.answer_chain"
		elif was_id != "" and bool(main.events.is_branch(was_id)):
			fid = "event.answer_branch"
		elif was_id == "":
			fid = "gig.signal_answer"
		_res(fid, true, "", false)
		if cash() > c0:
			bot.add_flow("events", cash() - c0, true)
		elif cash() < c0:
			bot.add_flow("event_fees", c0 - cash())
	return answered


func press_continue() -> Dictionary:
	if main.end_screen == null:
		return _res("end.continue", false, "no end screen", false)
	main.end_screen.continue_pressed.emit()
	return _res("end.continue", bool(main.free_play) and not bool(main.game_over), "", false)
