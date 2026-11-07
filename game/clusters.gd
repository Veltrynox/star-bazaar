extends RefCounted
## T156: asteroid clusters. A cluster is a source of ore, not a market: a route may start at a cluster
## (like a planet node), the ship loads ore free, the cost is the lane. Richness is finite and never respawns.
## Definitions: data/asteroid_clusters.json. Numbers: balance.json (mining_cluster_richness, mining_yield_per_cycle,
## mining_clusters_s<N>, mining_event_cluster_richness). Cluster i is route node id node_id(i) = -(BASE + i).
## T295: each cluster has a mining intensity (gentle, normal, hard; DeadWorlds.STEPS; Minerals runs only) with balance keys
## mining_intensity_yield_<step> / mining_intensity_danger_<step>. UI getters: stock_left(i), cycles_left(i), intensity_of(i), set_intensity(i, step),
## yield_per_cycle(i), danger_mult(i). Saved inside to_dict() under "intensity" {cluster id: step}.
## T157 reads list() / visible_count() for the map; the planet panel reads near_planet() / ore_line data.

const DeadWorlds := preload("res://game/dead_worlds.gd")
const PATH := "res://data/asteroid_clusters.json"
const BASE := 1000  # node ids <= -BASE are clusters (-1 .. -999 are Space Storage stations: -system id)
const NEAR_PX := 260.0  # map units: a cluster within this distance of a planet is "near" it (panel line); display only

var balance: Dictionary = {}
## {id, system, x, y, radius, count, good, max, left, spawned}
var items: Array = []
var event_shape := {"radius": 30, "count": 50}
var default_good := "ore"
var stretch := 2.0  # cluster_stretch in the json: pack length along the orbit tangent vs across the radius

static func node_id(i: int) -> int:
	return -(BASE + i)

static func is_node(n: int) -> bool:
	return n <= -BASE

static func index_of(n: int) -> int:
	return -n - BASE

func setup(bal: Dictionary) -> void:
	balance = bal
	items = []
	if not FileAccess.file_exists(PATH):
		push_error("Clusters: %s is missing." % PATH)
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Clusters: %s is not an object." % PATH)
		return
	default_good = str(parsed.get("good", "ore"))
	stretch = maxf(1.0, float(parsed.get("cluster_stretch", 2.0)))
	if typeof(parsed.get("event_cluster")) == TYPE_DICTIONARY:
		event_shape = parsed["event_cluster"]
	var taken := {}  # system -> clusters taken so far
	for d in parsed.get("clusters", []):
		if typeof(d) != TYPE_DICTIONARY or not d.has("id"):
			continue
		var sid := int(d.get("system", 1))
		var key := "mining_clusters_s%d" % sid
		var cap: int = int(balance.get(key, 0)) if balance.has(key) else 1 << 20  # a system without a key: all listed
		if int(taken.get(sid, 0)) >= cap:
			continue
		taken[sid] = int(taken.get(sid, 0)) + 1
		var rich := int(balance.get("mining_cluster_richness", 0))
		items.append({"id": str(d["id"]), "system": sid, "x": float(d.get("x", 0)), "y": float(d.get("y", 0)),
			"radius": float(d.get("radius", 40)), "count": int(d.get("count", 1)), "good": str(d.get("good", default_good)),
			"max": rich, "left": rich, "spawned": false, "intensity": DeadWorlds.DEFAULT_STEP})

func find(id: String) -> int:
	for i in items.size():
		if str(items[i]["id"]) == id:
			return i
	return -1

func valid(i: int) -> bool:
	return i >= 0 and i < items.size()

func left(i: int) -> int:
	return int(items[i]["left"]) if valid(i) else 0

func good_of(i: int) -> String:
	return str(items[i]["good"]) if valid(i) else ""

func system_of(i: int) -> int:
	return int(items[i]["system"]) if valid(i) else 1

## Units one cluster gives per cycle, shared by every ship on it (mining_yield_per_cycle).
## With a cluster index the cluster's intensity multiplier applies (T295).
func yield_per_cycle(i: int = -1) -> int:
	var m := DeadWorlds.yield_mult_for(balance, intensity_of(i)) if valid(i) else 1.0
	return floori(float(balance.get("mining_yield_per_cycle", 0)) * Skills.cluster_yield_mult() * m)

func stock_left(i: int) -> int:
	return left(i)

func intensity_of(i: int) -> int:
	return clampi(int(items[i].get("intensity", DeadWorlds.DEFAULT_STEP)), 0, DeadWorlds.STEPS.size() - 1) if valid(i) else DeadWorlds.DEFAULT_STEP

## False when the lever is closed (not a Minerals run) or the cluster is unknown.
func set_intensity(i: int, step: int) -> bool:
	if not valid(i) or not DeadWorlds.intensity_open():
		return false
	items[i]["intensity"] = clampi(step, 0, DeadWorlds.STEPS.size() - 1)
	return true

func danger_mult(i: int) -> float:
	return DeadWorlds.danger_mult_for(balance, intensity_of(i))

## Cycles the ore lasts at the cluster's yield for one cycle (it never refills); 0 when empty.
func cycles_left(i: int) -> int:
	var y := yield_per_cycle(i)
	return 0 if left(i) <= 0 else (ceili(float(left(i)) / float(y)) if y > 0 else -1)

## Takes up to n units, never more than is left. Returns the units taken.
func take(i: int, n: int) -> int:
	if not valid(i) or n <= 0:
		return 0
	var got: int = mini(n, int(items[i]["left"]))
	items[i]["left"] = int(items[i]["left"]) - got
	return got

## Pack instances T157 draws now: full count at full richness, thinning with the ore, 0 when empty.
func visible_count(i: int) -> int:
	if not valid(i) or int(items[i]["left"]) <= 0 or int(items[i]["max"]) <= 0:
		return 0
	return maxi(1, ceili(float(items[i]["count"]) * float(items[i]["left"]) / float(items[i]["max"])))

## Copies for the map and panels: clusters of a system (0 = all systems). Empty ones are left out unless asked.
func list(system: int = 0, include_empty: bool = false) -> Array:
	var out: Array = []
	for i in items.size():
		if system != 0 and int(items[i]["system"]) != system:
			continue
		if not include_empty and int(items[i]["left"]) <= 0:
			continue
		var d: Dictionary = items[i].duplicate()
		d["index"] = i
		d["node"] = node_id(i)
		d["visible"] = visible_count(i)
		d["stretch"] = stretch
		out.append(d)
	return out

## Clusters within NEAR_PX map units of a planet position, nearest first (planet panel: "ore nearby").
func near(system: int, x: float, y: float) -> Array:
	var out: Array = []
	for d in list(system):
		var dist := Vector2(float(d["x"]) - x, float(d["y"]) - y).length()
		if dist <= NEAR_PX:
			d["dist"] = dist
			out.append(d)
	out.sort_custom(func(a, b): return float(a["dist"]) < float(b["dist"]))
	return out

## EV20 paid: a fresh small cluster of mining_event_cluster_richness beside the planet at (x, y). Returns its index.
func spawn_small(system: int, x: float, y: float) -> int:
	var n := 0
	for it in items:
		if bool(it["spawned"]):
			n += 1
	var ang := float(n) * 2.1  # a different side for each new one; deterministic
	var rich := int(balance.get("mining_event_cluster_richness", 0))
	items.append({"id": "ev_%d" % (n + 1), "system": system, "x": x + cos(ang) * 70.0, "y": y + sin(ang) * 70.0,
		"radius": float(event_shape.get("radius", 30)), "count": int(event_shape.get("count", 50)), "good": default_good,
		"max": rich, "left": rich, "spawned": true, "intensity": DeadWorlds.DEFAULT_STEP})
	return items.size() - 1

## Saved form: ore left per base cluster id, and the full record of every spawned cluster. Positions and counts of base clusters come from the data file.
func to_dict() -> Dictionary:
	var left_map := {}
	var inten := {}
	var spawned: Array = []
	for it in items:
		if bool(it["spawned"]):
			spawned.append(it.duplicate())
		else:
			left_map[str(it["id"])] = int(it["left"])
			inten[str(it["id"])] = int(it.get("intensity", DeadWorlds.DEFAULT_STEP))
	return {"left": left_map, "spawned": spawned, "intensity": inten}

func from_dict(saved) -> void:
	setup(balance)  # fresh base clusters, then the saved state on top (old saves: all full)
	if typeof(saved) != TYPE_DICTIONARY:
		return
	var lm = saved.get("left", {})
	if typeof(lm) == TYPE_DICTIONARY:
		for i in items.size():
			var k := str(items[i]["id"])
			if lm.has(k):
				items[i]["left"] = clampi(int(lm[k]), 0, int(items[i]["max"]))
	var im = saved.get("intensity", {})
	if typeof(im) == TYPE_DICTIONARY:
		for i in items.size():
			var k2 := str(items[i]["id"])
			if im.has(k2):
				items[i]["intensity"] = clampi(int(im[k2]), 0, DeadWorlds.STEPS.size() - 1)
	var sp = saved.get("spawned", [])
	if typeof(sp) == TYPE_ARRAY:
		for d in sp:
			if typeof(d) == TYPE_DICTIONARY and d.has("id"):
				var mx := int(d.get("max", balance.get("mining_event_cluster_richness", 0)))
				items.append({"id": str(d["id"]), "system": int(d.get("system", 1)), "x": float(d.get("x", 0)), "y": float(d.get("y", 0)),
					"radius": float(d.get("radius", 30)), "count": int(d.get("count", 50)), "good": str(d.get("good", default_good)),
					"max": mx, "left": clampi(int(d.get("left", 0)), 0, mx), "spawned": true,
					"intensity": clampi(int(d.get("intensity", DeadWorlds.DEFAULT_STEP)), 0, DeadWorlds.STEPS.size() - 1)})
