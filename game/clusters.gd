extends RefCounted
## T156: asteroid clusters. A cluster is a source of ore, not a market: a route may start at a cluster
## (like a planet node), the ship loads ore free, the cost is the lane. Richness is finite and never respawns.
## Definitions: data/asteroid_clusters.json. Numbers: balance.json (mining_cluster_richness, mining_yield_per_cycle,
## mining_clusters_s<N>, mining_event_cluster_richness). Cluster i is route node id node_id(i) = -(BASE + i).
## T157 reads list() / visible_count() for the map; the planet panel reads near_planet() / ore_line data.

const PATH := "res://data/asteroid_clusters.json"
const BASE := 1000  # node ids <= -BASE are clusters (-1 .. -999 are Space Storage stations: -system id)
## Skill that unlocks routing from a cluster. B1 is Prospecting since T158.
const MINING_SKILL := "B1"
const NEAR_PX := 260.0  # map units: a cluster within this distance of a planet is "near" it (panel line); display only

var balance: Dictionary = {}
## {id, system, x, y, radius, count, good, max, left, spawned}
var items: Array = []
var event_shape := {"radius": 30, "count": 12}
var default_good := "ore"

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
			"max": rich, "left": rich, "spawned": false})

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
func yield_per_cycle() -> int:
	return int(balance.get("mining_yield_per_cycle", 0))

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
		"radius": float(event_shape.get("radius", 30)), "count": int(event_shape.get("count", 12)), "good": default_good,
		"max": rich, "left": rich, "spawned": true})
	return items.size() - 1

## Saved form: ore left per base cluster id, and the full record of every spawned cluster. Positions and counts of base clusters come from the data file.
func to_dict() -> Dictionary:
	var left_map := {}
	var spawned: Array = []
	for it in items:
		if bool(it["spawned"]):
			spawned.append(it.duplicate())
		else:
			left_map[str(it["id"])] = int(it["left"])
	return {"left": left_map, "spawned": spawned}

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
	var sp = saved.get("spawned", [])
	if typeof(sp) == TYPE_ARRAY:
		for d in sp:
			if typeof(d) == TYPE_DICTIONARY and d.has("id"):
				var mx := int(d.get("max", balance.get("mining_event_cluster_richness", 0)))
				items.append({"id": str(d["id"]), "system": int(d.get("system", 1)), "x": float(d.get("x", 0)), "y": float(d.get("y", 0)),
					"radius": float(d.get("radius", 30)), "count": int(d.get("count", 12)), "good": str(d.get("good", default_good)),
					"max": mx, "left": clampi(int(d.get("left", 0)), 0, mx), "spawned": true})
