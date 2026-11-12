extends "res://qa/check/styles/base.gd"
## Style "sampler": exercises the rarely used actions once each (a smoke test of the action library and a coverage filler).
## Exploration mode, quick send, Buy off, boost, dock and hand trade, cluster ore, split clear, Storage Link. Plays little else.

const FITTING := ["ceo_man_01", "ceo_woman_02"]

var _done := {}


func fitting_ceos() -> Array:
	return FITTING


func event_policy() -> String:
	return "second"


func each_cycle(c: int) -> void:
	learn_in_order(["FND_PROSPECT", "FND_PERMIT", "FND_STORAGE", "FND_DOCKS"], 2)
	if c == 1:
		a.set_exploring(true)
		return
	var worlds: Array = a.open_worlds()
	if worlds.size() >= 2 and not _done.has("lane"):
		var l: Array = a.known_lanes(1)
		if not l.is_empty():
			var s := int(l[0]["src"])
			var d := int(l[0]["dst"])
			var g := str(l[0]["c"])
			a.set_order(s, g, "buy", true)
			var r: Dictionary = a.send(s, d, g, "quick")
			if bool(r["ok"]):
				_done["lane"] = true
				a.set_order(d, g, "sell", true)
				a.set_order(s, g, "buy", false)
				a.set_order(s, g, "buy", true)
				a.send(s, d, g, "card")
				var rid := int(r["id"])
				a.split_lane(s, g, 50)
				a.clear_split(s, g)
				a.upgrade_route(rid)
	if c == 5 and not a.fs_busy():
		a.set_boost(true)
		a.set_boost(false)
	if c >= 6 and not _done.has("dock") and not a.fs_busy() and worlds.size() >= 2:
		var w := int(worlds[worlds.size() - 1])
		for g in a.goods_visible():
			if int(main.trade.price(w, str(g) + "_buy")) > 0:
				a.fs_queue({"op": "dock", "planet": w, "todo": [["buy", str(g), 5], ["unload", str(g), 5], ["load", str(g), 5], ["sell", str(g), 5]]})
				_done["dock"] = true
				break
	if main.can_mine() and not _done.has("cluster") and not a.cluster_list().is_empty() and worlds.size() >= 1:
		var r2: Dictionary = a.send_cluster(int(a.cluster_list()[0]["index"]), int(worlds[0]))
		if bool(r2["ok"]):
			_done["cluster"] = true
	if main.engine.routes.size() > 0 and not _done.has("station") and main.space_post_open(1):
		var rr: Dictionary = a.send(int(worlds[0]), -1, str(a.goods_visible()[0]), "card")
		_done["station"] = bool(rr["ok"])
		a.open_station(1)
