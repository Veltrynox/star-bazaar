extends RefCounted
## Economy check: the style interface and shared helpers. A style extends this file and overrides what it needs.
##
##   fitting_ceos() -> Array   CEO ids this style is meant for (run.sh reads the literal line `const FITTING := [...]` of the style file; also override this function to return it)
##   setup(bot)                called once after boot (tutorial skipped, paused, cycle 1)
##   event_policy() -> String  "first" | "second" | "seeded" | "last": how open event notices are answered
##   wing_pick(stage) -> int   which wing card (0 or 1) of a Bazaar stage
##   each_cycle(cycle)         the style's decisions, at the start of every cycle, while the game is paused
##   on_chunk(k)               optional: after each 1/8 cycle clock chunk (Flagship work between decisions)
##
## A style acts ONLY through `a` (qa/check/actions.gd). Reading state through `main` is free.
## Helpers below cover what every style needs: skills in an order, one-shot work lists, the "lane" routine
## (Buy at the source + route + Sell at the destination), upgrades, and world exploration with the Flagship.

var bot: Object = null
var a: RefCounted = null
var main: Node:
	get:
		return bot.main  # the bot may reload the game (save/load check): never keep the old node
var notes: Array = []   # short strings the report shows under the style
var rng := RandomNumberGenerator.new()


func fitting_ceos() -> Array:
	return ["ceo_man_01", "ceo_man_02", "ceo_woman_01", "ceo_woman_02"]


func setup(b: Object) -> void:
	bot = b
	a = b.act
	rng.seed = int(b.seed_value) * 7919 + 13


func event_policy() -> String:
	return "first"


func wing_pick(_stage: int) -> int:
	return 0


func each_cycle(_cycle: int) -> void:
	pass


func on_chunk(_k: int) -> void:
	pass


func note(text: String) -> void:
	if notes.size() < 40:
		notes.append("c%d %s" % [int(main.cycle), text])


# ---- shared helpers -----------------------------------------------------------------------------------------------------

## Founding rule: a planet hub of the site system must have worked and moved units (hub_ready), and found_discount cash must be in hand.
## Cash to keep back (0 = none) once a hub is nearly ready (so ships are not bought below the founding bill).
func found_hold() -> int:
	if main.bazaar.is_founded():
		return 0
	var hold := 0
	for h in main.hubs.hub_planets():
		if int(h) < 0:
			continue
		var sid: int = int(main.system_of(int(h)))
		var hr: Dictionary = main.bazaar.hub_ready(sid)
		if int(hr["age"]) >= int(hr["need_age"]) - 2 and int(hr["moved"]) * 2 >= int(hr["need_moved"]):
			hold = maxi(hold, int(main.bazaar.found_discount(sid)["cash"]))
	return hold


## True while a planet hub still has to move units for the founding rule: the hub then feeds its ticked worlds' needs itself,
## so the bot leaves those needs to it (a manual lane would count as "covered" and the hub would carry nothing).
func hub_owns_need(w: int) -> bool:
	if main.bazaar.is_founded():
		return false
	for h in main.hubs.hub_planets():
		if int(h) < 0:
			continue
		var hr: Dictionary = main.bazaar.hub_ready(int(main.system_of(int(h))))
		if bool(hr["ok"]):
			continue
		if main.hubs.worlds_in_reach(int(h)).has(w) and not bool(main.hubs.is_world_off(int(h), w)):
			return true
	return false


## Drop the manual need lanes into worlds a hub owns (see hub_owns_need), so the hub has needs to carry.
func hub_clear_lanes() -> void:
	for r in main.engine.routes.duplicate():
		var w := int(r["b"])
		if w < 0 or a.Clusters.is_node(int(r["a"])) or not hub_owns_need(w):
			continue
		for n in main.prosperity.needs(w):
			if str(n["good"]) == str(r["c"]) and not bool(n["locked"]):
				a.remove_route(int(r["id"]), "panel")
				note("lane %s into %s left to the hub" % [str(r["c"]), a.world_name(w)])
				break


## Ore rule: a founded Bazaar's bill has an ore row (tier 0, kind "ore"; Minerals: merged into tier 1). Ore comes only from clusters
## (FND_PROSPECT), so learn it as soon as a bill row asks for ore that is not met (the row shows no goods while ore is hidden).
func bill_ore_unmet() -> bool:
	if not main.bazaar.is_founded() or main.bazaar.complete():
		return false
	for row in main.bazaar.bill_status():
		if bool(row["ok"]):
			continue
		if str(row.get("kind", "")) == "ore" or (row["goods"] as Array).has("ore") or (str(main.run_branch()) == "min" and int(row["tier"]) == 1):
			return true
	return false


func ensure_prospect() -> void:
	if main.can_mine() or not bill_ore_unmet():
		return
	learn_in_order(["FND_PROSPECT"], 1)


## One cluster lane carrying ore straight into the site's Space Storage (cap = -site system); true when one is made.
func mine_ore_into(cap: int) -> bool:
	if not main.can_mine() or cap >= 0:
		return false
	for r in main.engine.routes:
		if int(r["b"]) == cap and str(r["c"]) == "ore" and a.Clusters.is_node(int(r["a"])) and str(r["state"]) != "stalled":
			return false  # a live ore lane already feeds the bill
	for cl in a.cluster_list():
		if str(cl.get("good", "")) != "ore" or not main.open_systems.has(int(cl["system"])):
			continue
		var r2: Dictionary = a.send_cluster(int(cl["index"]), cap)
		if bool(r2["ok"]):
			note("ore lane cluster %d -> Star Bazaar" % int(cl["index"]))
			return true
	return false

## Learn the first affordable skill of `order` (ids not in the run's tree or already known are skipped). Returns ids learned.
func learn_in_order(order: Array, max_n: int = 3) -> Array:
	var got: Array = []
	for id in order:
		if got.size() >= max_n:
			break
		if main.learned_skills.has(id):
			continue
		var chk: Dictionary = SkillTreeRef.can_learn(main.learned_skills, main.skill_points, main.balance, str(id))
		if not bool(chk["ok"]):
			continue
		var r: Dictionary = a.learn_skill(str(id))
		if bool(r["ok"]):
			got.append(id)
			note("learned " + str(id))
	return got


const SkillTreeRef := preload("res://game/skill_tree.gd")


## Skill order for the run's branch: tiers ascending, cheapest first. Foundations are placed by the caller.
func branch_order() -> Array:
	var ids: Array = SkillTreeRef.ids_in(main.run_branch())
	var rows: Array = []
	for id in ids:
		if SkillTreeRef.is_tech(str(id)):
			continue
		rows.append([SkillTreeRef.tier(str(id)), SkillTreeRef.cost(main.balance, str(id)), str(id)])
	rows.sort()
	var out: Array = []
	for r in rows:
		out.append(r[2])
	return out


## World indexes not yet established, nearest to the Flagship first. system 0 = any open system.
func unexplored(sid: int = 1) -> Array:
	var out: Array = []
	var f = main.flight
	for i in main.map.planets.size():
		if main.planet_established(i):
			continue
		if sid > 0 and int(main.system_of(i)) != sid:
			continue
		if not main.open_systems.has(int(main.system_of(i))):
			continue
		var pid := str(main.map.planets[i].get("id", ""))
		var eta: float = float(f.eta_cycles(pid))
		if eta < 0.0:
			continue
		out.append([eta, i])
	out.sort()
	var idx: Array = []
	for r in out:
		idx.append(r[1])
	return idx


## Cost of the next post/platform at world i (0 when free), -1 when unknown.
func establish_cost(i: int) -> int:
	var c: Dictionary = main.flight.cost(str(main.map.planets[i].get("id", "")))
	if c.is_empty():
		return -1
	return 0 if bool(c.get("free", false)) else int(c.get("cash", 0))


## One full lane: Buy at src, route src -> dst, Sell at dst. Returns the route id or -1. Ships are bought by the Send.
func make_lane(src: int, dst: int, c: String, via: String = "buy") -> int:
	var r: Dictionary = a.send(src, dst, c, via)
	if not bool(r["ok"]):
		return -1
	a.set_order(src, c, "buy", true)
	a.set_order(dst, c, "sell", true)
	return int(r.get("id", -1))


## A lane exists (any ship) from src to dst for c.
func has_lane(src: int, dst: int, c: String) -> bool:
	return int(main.engine.lane_count(src, dst, c)) > 0


## Id of the first route record of a lane, or -1.
func lane_route_id(src: int, dst: int, c: String) -> int:
	for r in main.engine.routes:
		if int(r["a"]) == src and int(r["b"]) == dst and str(r["c"]) == c:
			return int(r["id"])
	return -1


## Fixed cost per cycle of all routes (what upkeep takes), used for cash reserves.
func routes_cost() -> int:
	return int(main.engine.routes.size()) * int(main.engine.fixed_cost())
