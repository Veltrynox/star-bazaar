class_name Raids
extends RefCounted
## T296 raids from dead-world nests (design/proposals/2026-11-06-empire-growth-v2.md section 3.4). No combat, nothing is destroyed.
## A dead world that is not reclaimed is a nest. At the start of a cycle (main, after the cycle counter moves) a seeded roll per nest
## may choose one lane of the player in that nest's system; the raid hits in the NEXT settle (one cycle ahead). With a forecast skill
## (Skills.warning_cycles() > 0) a warning notice names the lane when the raid is chosen; warning() is the getter for a chip.
## The hit: the route engine asks strike() while it settles that lane. It takes raid_take_share of the trip's carried units, puts a
## malus on the lane (raid_malus_pct per hit, capped at raid_malus_cap, raid_malus_cycles long, the timer resets) and drops cargo pods
## as a Salvage gig (kind "salvage" in game/gigs.gd): raid_pod_return of the stolen units, near the lane's source world; the Flagship
## reaches them before raid_pod_fade_cycles run out and the goods load into its hold (what does not fit stays in the pods).
## Chance per nest per cycle = (raid_chance_base + raid_chance_per_lane x the player's lanes in the system), capped at raid_chance_max. raid_first_cycle and raid_gap_cycles space them.
## The Null Core ship is immune: never chosen, never cut, no malus. Cluster ore lanes are never hit. All numbers: balance raid_* keys
## (PLACEHOLDERS). Saved by main under "raids" (save version 18; older saves load with nothing active); pods live in the gigs block.

const StoryText := preload("res://game/story_text.gd")
const RouteEngine := preload("res://game/route_engine.gd")
const DeadWorlds := preload("res://game/dead_worlds.gd")

signal hit(lane: int, nest: int, pods_at: Vector3)  # T300: a raid struck (lane route id, nest planet index, where pods dropped or Vector3.INF), for juice

var main: Node = null
var malus := {}          # lane (route) id -> {pct, left}
var last_raid_cycle := -100000
var pending := {}        # {rec, nest (planet id), hit} chosen, hits in the settle of cycle `hit`
var armed := {}          # the same, once its cycle began: the engine strikes this lane in this settle
var raids_done := 0
var _uid := 0

func setup(m: Node) -> void:
	main = m
	reset()

func reset() -> void:
	malus = {}
	last_raid_cycle = -100000
	pending = {}
	armed = {}
	raids_done = 0
	_uid = 0

func _bal(key: String, dflt: float = 0.0) -> float:
	return float(main.balance.get(key, dflt)) if main != null else dflt

# ---- queries ---------------------------------------------------------------------------------------------------------

## Multiplier on a lane's volume while its malus runs (1 = none). The Null Core ship is immune.
func lane_mult(rec) -> float:
	if typeof(rec) != TYPE_DICTIONARY or RouteEngine.has_core(rec) or not malus.has(int(rec.get("id", 0))):
		return 1.0
	return 1.0 - clampf(float(malus[int(rec["id"])]["pct"]), 0.0, 1.0)


## The raid chosen for the next settle, {planet (nest index), lane (route id), hit (cycle)}; {} when none or no forecast skill.
func warning() -> Dictionary:
	if pending.is_empty() or Skills.warning_cycles() <= 0:
		return {}
	return {"planet": main.planet_index_of(str(pending["nest"])), "lane": int(pending["rec"]), "hit": int(pending["hit"])}

## Nests: planet indexes of dead worlds that are not reclaimed.
func nests() -> Array:
	var out: Array = []
	for i in main.map.planets.size():
		if DeadWorlds.is_dead(main.map.planets[i]) and not main.prosperity.is_reclaimed(i):
			out.append(i)
	return out

func _touches(rec: Dictionary, sys: int) -> bool:
	var a := int(rec["a"])
	var b := int(rec["b"])
	return (a >= 0 and main.system_of(a) == sys) or (b >= 0 and main.system_of(b) == sys)

## Lanes of the player in a system that a raid may hit (not the Null Core ship, not an ore lane).
func lanes_in(sys: int) -> Array:
	var out: Array = []
	for rec in main.engine.routes:
		if not RouteEngine.has_core(rec) and not RouteEngine.from_cluster(rec) and not RouteEngine.from_station(rec) and _touches(rec, sys):
			out.append(rec)
	return out

func chance(nest: int) -> float:
	var n := lanes_in(main.system_of(nest)).size()
	if n <= 0:
		return 0.0
	var c: float = (_bal("raid_chance_base") + _bal("raid_chance_per_lane") * float(n))
	return clampf(c, 0.0, _bal("raid_chance_max"))

# ---- cycle -----------------------------------------------------------------------------------------------------------

## Start of a cycle (main): malus ages, a missed raid fizzles, a chosen raid arms, a new one may be chosen for the next settle.
func on_cycle(cycle: int) -> void:
	for k in malus.keys():
		malus[k]["left"] = int(malus[k]["left"]) - 1
		if int(malus[k]["left"]) <= 0:
			malus.erase(k)
	armed = {}
	if not pending.is_empty() and int(pending["hit"]) <= cycle:
		if _valid(pending):
			armed = pending
		pending = {}
	if not pending.is_empty() or main.flight == null or not main.flight.is_enabled():
		return
	if cycle < int(_bal("raid_first_cycle")) or cycle - last_raid_cycle < int(_bal("raid_gap_cycles")):
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = main.gigs.seed_value + cycle * 6151 + 29
	for nest in nests():
		if rng.randf() >= chance(nest):
			continue
		var lanes := lanes_in(main.system_of(nest))
		var rec: Dictionary = lanes[rng.randi() % lanes.size()]
		pending = {"rec": int(rec["id"]), "nest": str(main.map.planets[nest].get("id", "")), "hit": cycle + 1}
		if Skills.warning_cycles() > 0:
			main.post_notice(StoryText.get_or("NOT_RAID_WARNING", "Raiders are stirring at {planet}. Your lane to {lane} may be hit next cycle.",
				{"planet": main.planet_name(nest), "lane": main.planet_name(int(rec["b"]) if int(rec["b"]) >= 0 else int(rec["a"]))}))
		return

func _valid(p: Dictionary) -> bool:
	var i: int = main.planet_index_of(str(p["nest"]))
	if i < 0 or not DeadWorlds.is_dead(main.map.planets[i]) or main.prosperity.is_reclaimed(i):
		return false
	var idx: int = main.engine.find_by_id(int(p["rec"]))
	return idx >= 0 and not RouteEngine.has_core(main.engine.routes[idx])

## Route engine, while it settles a lane: the raid takes units out of `carried`. Returns the units taken (0 when this lane is not hit).
func strike(rec: Dictionary, carried: int) -> int:
	if armed.is_empty() or int(armed["rec"]) != int(rec["id"]) or RouteEngine.has_core(rec):
		return 0
	var nest := str(armed["nest"])
	armed = {}
	var take := clampi(floori(float(carried) * clampf(_bal("raid_take_share"), 0.0, 1.0)), 0, carried)
	var id := int(rec["id"])
	var old: float = float(malus[id]["pct"]) if malus.has(id) else 0.0
	malus[id] = {"pct": minf(old + _bal("raid_malus_pct"), _bal("raid_malus_cap")), "left": int(_bal("raid_malus_cycles"))}
	last_raid_cycle = main.cycle
	raids_done += 1
	var good := str(rec["c"])
	var back := floori(float(take) * clampf(_bal("raid_pod_return"), 0.0, 1.0))
	var ni: int = main.planet_index_of(nest)
	main.post_notice(StoryText.get_or("NOT_RAID_HIT", "Raiders from {planet} hit your lane to {lane}: {n} units lost, the lane runs weaker for {cycles} cycles.",
		{"planet": main.planet_name(ni), "lane": main.planet_name(int(rec["b"]) if int(rec["b"]) >= 0 else int(rec["a"])), "n": take, "cycles": int(_bal("raid_malus_cycles"))}))
	var pods_at := Vector3.INF
	if back > 0 and Availability.good(good):
		pods_at = _drop_pods(rec, good, back)
	hit.emit(id, ni, pods_at)
	return take

func _drop_pods(rec: Dictionary, good: String, units: int) -> Vector3:
	var a := int(rec["a"])
	var base: Vector3 = main.flight._planet_pos(a)
	var rng := RandomNumberGenerator.new()
	rng.seed = main.gigs.seed_value + main.cycle * 7507 + int(rec["id"])
	var ang := rng.randf() * TAU
	var pos := base + Vector3(cos(ang), 0.0, sin(ang)) * _bal("raid_pod_dist", 0.6)
	pos = main.gigs.nudge_clear(pos, main.system_of(a), ang)  # T340: never on a lane or a living world (a dead world is fine)
	_uid += 1
	var uid := "SALV%d_%d" % [main.cycle, _uid]
	main.gigs.post_salvage(uid, main.system_of(a), pos, good, units, int(_bal("raid_pod_count", 1.0)), _bal("raid_pod_fade_cycles"), int(rec["id"]))
	return pos

# ---- save ------------------------------------------------------------------------------------------------------------

func to_dict() -> Dictionary:
	return {"malus": malus.duplicate(true), "last": last_raid_cycle, "pending": pending.duplicate(), "armed": armed.duplicate(), "done": raids_done, "uid": _uid}

## A missing or bad dictionary (a save from before raids) means nothing active.
func from_dict(s) -> void:
	reset()
	if typeof(s) != TYPE_DICTIONARY:
		return
	if typeof(s.get("malus")) == TYPE_DICTIONARY:
		for k in s["malus"]:
			var m = s["malus"][k]
			if typeof(m) == TYPE_DICTIONARY and int(m.get("left", 0)) > 0:
				malus[int(k)] = {"pct": float(m.get("pct", 0.0)), "left": int(m["left"])}
	last_raid_cycle = int(s.get("last", -100000))
	for key in ["pending", "armed"]:
		var p = s.get(key)
		if typeof(p) == TYPE_DICTIONARY and p.has("rec") and p.has("nest") and p.has("hit"):
			var v := {"rec": int(p["rec"]), "nest": str(p["nest"]), "hit": int(p["hit"])}
			if key == "pending":
				pending = v
			else:
				armed = v
	raids_done = int(s.get("done", 0))
	_uid = int(s.get("uid", 0))
