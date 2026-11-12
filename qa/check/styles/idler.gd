extends "res://qa/check/styles/base.gd"
## Style "idler": does almost nothing. One ship, one lane set up in the first cycles, then only answers events with the LAST
## option and never invests again. Aim: END_UNFINISHED when the term runs out. Notes record cash growth, events seen,
## and what the never-fed worlds lost (Restless worlds, tiers).

const FITTING := ["ceo_man_01", "ceo_man_02", "ceo_woman_01", "ceo_woman_02"]

var _lane := false
var _tries := 0
var _tier_sum_prev := -1
var _max_restless := 0


func fitting_ceos() -> Array:
	return FITTING


func event_policy() -> String:
	return "last"


func each_cycle(c: int) -> void:
	if not _lane and c <= 8 and _tries < 8:
		_tries += 1
		_setup_lane(c)
	_watch(c)


func _setup_lane(_c: int) -> void:
	var l: Array = a.known_lanes(1)
	if l.is_empty():
		# one world open only: the Flagship opens the nearest neighbour (one trip, then it idles for good)
		if not a.fs_busy() and a.open_worlds().size() < 2:
			for i in unexplored(0):
				if establish_cost(i) >= 0 and not a.is_dead(i):
					a.fs_queue({"op": "fly_establish", "planet": i})
					note("flagship opens " + a.world_name(i))
					break
		return
	var s := int(l[0]["src"])
	var d := int(l[0]["dst"])
	var g := str(l[0]["c"])
	if make_lane(s, d, g, "buy") >= 0:
		_lane = true
		note("lane %s %s->%s margin %d (cash %d)" % [g, a.world_name(s), a.world_name(d), int(l[0]["margin"]), int(main.cash)])


func _watch(c: int) -> void:
	var tiers := 0
	for i in main.map.planets.size():
		if main.planet_established(i):
			tiers += int(main.prosperity.tier(i))
	var rest := int(main.prosperity.restless_count())
	_max_restless = maxi(_max_restless, rest)
	if tiers != _tier_sum_prev:
		note("tier sum %d restless %d cash %d ships %d routes %d" % [tiers, rest, int(main.cash), int(main.ships), main.engine.routes.size()])
		_tier_sum_prev = tiers
	elif c % 15 == 0:
		note("cash %d restless %d (max %d) events seen %d" % [int(main.cash), rest, _max_restless, bot.events_seen.size()])
	for o in main.gigs.offers:
		if not bool(o.get("accepted", false)) and c % 20 == 0:
			note("gig offered unanswered: " + str(o.get("kind", "")))
