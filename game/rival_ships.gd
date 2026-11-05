extends Node3D
## T187: rival ships flying around the map. A VISUAL ONLY: no cargo, no collision shape, no picking, no blocking, no combat, no
## effect on routes, prices, shares or the Pathfinder. Rivals stay numbers in the economy (Markets bots); these ships are scenery.
## T196: each ship picks a destination (a point over the planets of its system), speeds up from rest, turns at a limited yaw rate,
## flies a straight course and brakes to a stop there, waits (rival_ship_wait_s), then picks the next one. No random jitter.
## Each ship flies on the plane y = LIFT, like the
## Pathfinder. They move only while the game runs (main.paused false, speed follows main.time_speed), as the Pathfinder does.
## Number per system: balance key rival_ship_count (default COUNT_DEFAULT when the key is absent; the key belongs in
## data/balance.json, owner of that file to add it). Speed in map units per second: SPEED_DEFAULT (same note, rival_ship_speed).
## Look (model, tint, size, trail) is NOT decided here: it uses the ship models of data/ships.json other than the player's,
## fitted like the Pathfinder, and a small cone when no model loads.

const Ships := preload("res://game/ships.gd")
const Motion := preload("res://game/ship_motion.gd")  # T196

const COUNT_DEFAULT := 3
const SPEED_DEFAULT := 0.6      # world units per second at x1
const LIFT := 0.35
const ShipTrail := preload("res://game/ship_trail.gd")  # T198
const RIVAL_SHIP_SCALE := 0.5   # T198: ship size on the map; 1.0 is the old size (halved in T198). One constant for the rival ship kind.
const FIT_RADIUS := 0.35 * RIVAL_SHIP_SCALE
const TRAIL_TINT := Color(0.45, 0.7, 1.0)  # T198: rival trail, cool blue (the player's is gold)

var main: Node = null
var map: Node = null
var _rng := RandomNumberGenerator.new()
var _ships: Array = []          # {node, system, pos Vector2 (x, z), yaw, speed, to Vector2, wait (s left, > 0 = waiting)}
const MIN_LEG := 3.0            # a new destination is at least this far (world units)
const SUBSTEP := 0.05           # seconds per integration step
var _built_sys := {}            # system id -> true once its rivals exist (a system opened later gets its own)

func setup(m: Node, mp: Node) -> void:
	main = m
	map = mp
	_rng.seed = 20261105  # visual only, but the same every run
	name = "RivalShips"

func count() -> int:
	return int(_bal("rival_ship_count", COUNT_DEFAULT))

func _bal(key: String, dflt: float) -> float:
	return float(main.balance.get(key, dflt)) if main != null and "balance" in main else dflt

func _systems() -> Array:
	var out := {}
	if map == null:
		return []
	for p in map.planets:
		out[int(p.get("system", 1))] = true
	var ks := out.keys()
	ks.sort()
	return ks

## T202: a random spot in system `sys` parked at a random planet of it: Motion.SPAWN_GAP outside the planet's drawn edge, never
## inside any body (map.dock_point turns the spot away from the sun, station and asteroid fields).
func _random_point(sys: int) -> Vector3:
	var idx: Array = []
	for i in map.planets.size():
		if int(map.planets[i].get("system", 1)) == sys and i < map.positions.size():
			idx.append(i)
	if idx.is_empty():
		return Vector3.ZERO
	var i: int = idx[_rng.randi() % idx.size()]
	var c := Vector2(map.positions[i].x, map.positions[i].z)
	var ang := _rng.randf_range(0.0, TAU)
	var p: Vector2 = map.dock_point(c, map.planet_radius(i), c + Vector2(cos(ang), sin(ang)), sys)
	return Vector3(p.x, 0.0, p.y)

func _build() -> void:
	var kinds: Array = []
	for k in Ships.types():
		if str(k) != Ships.fleet:
			kinds.append(str(k))
	if kinds.is_empty():
		kinds = [Ships.DEFAULT]
	var n := _ships.size()
	for sys in _systems():
		if _built_sys.has(sys):
			continue
		_built_sys[sys] = true
		for i in maxi(0, count()):
			var node := _make_ship(str(kinds[n % kinds.size()]))
			add_child(node)
			var trail := ShipTrail.new()  # T198: world-space, a sibling of the ship so it ignores the ship's yaw
			trail.tint = TRAIL_TINT
			add_child(trail)
			var from := _random_point(sys)
			_ships.append({"node": node, "system": sys, "pos": Vector2(from.x, from.z), "yaw": _rng.randf_range(-PI, PI), "speed": 0.0,
				"to": Vector2(from.x, from.z), "wait": 0.0, "trail": trail})
			_new_leg(_ships[_ships.size() - 1])
			node.position = Vector3(from.x, LIFT, from.z)
			var last: Dictionary = _ships[_ships.size() - 1]
			last["yaw"] = Motion.yaw_to((last["to"] as Vector2) - (last["pos"] as Vector2))  # starts facing its first course
			node.rotation.y = float(last["yaw"])
			n += 1

func _new_leg(s: Dictionary) -> void:
	var from: Vector2 = s["pos"]
	var to := from
	for k in 8:
		var p := _random_point(int(s["system"]))
		to = Vector2(p.x, p.z)
		if from.distance_to(to) >= MIN_LEG:
			break
	s["to"] = to
	s["wait"] = 0.0

func _make_ship(kind: String) -> Node3D:
	var holder := Node3D.new()
	var model: Node3D = null
	var path := str(Ships.model(kind))
	if path != "" and ResourceLoader.exists(path):
		var res = load(path)
		if res is PackedScene:
			model = res.instantiate()
	if model == null:
		var cone := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.0
		cm.bottom_radius = 0.1
		cm.height = 0.35
		cone.mesh = cm
		cone.rotation_degrees = Vector3(-90, 0, 0)
		holder.scale = Vector3.ONE * RIVAL_SHIP_SCALE  # T198
		holder.add_child(cone)
	else:
		var box := _aabb(model, Transform3D.IDENTITY)
		if box.size.length() > 0.0:
			var rxz := 0.000001
			for i in 8:
				var c := box.get_endpoint(i) - box.get_center()
				rxz = maxf(rxz, Vector2(c.x, c.z).length())
			holder.scale = Vector3.ONE * (FIT_RADIUS / rxz)
			model.position = -box.get_center()
		var pivot := Node3D.new()  # T197: turns the model's own nose axis onto -Z
		pivot.rotation.y = Ships.model_yaw(kind)
		pivot.add_child(model)
		holder.add_child(pivot)
	return holder

func _aabb(node: Node, t: Transform3D) -> AABB:
	var box := AABB()
	var first := true
	var xf := t
	if node is Node3D:
		xf = t * node.transform
	if node is MeshInstance3D and node.mesh != null:
		box = xf * node.mesh.get_aabb()
		first = false
	for c in node.get_children():
		var cb := _aabb(c, xf)
		if cb.size == Vector3.ZERO:
			continue
		box = cb if first else box.merge(cb)
		first = false
	return box

## Moves every rival by dt seconds of game time (0 or less moves nothing). Public so tests can drive it.
func advance(dt: float) -> void:
	if map == null or map.positions.is_empty():
		return
	if _built_sys.size() < _systems().size():
		_build()
	var view: int = int(map.view_system) if map != null else 1
	var vmax := maxf(0.01, _bal("rival_ship_speed", SPEED_DEFAULT))
	var accel := vmax / maxf(0.05, _bal("rival_ship_accel_s", 2.0))
	var brake := vmax / maxf(0.05, _bal("rival_ship_brake_s", 2.0))
	var turn := deg_to_rad(maxf(1.0, _bal("rival_ship_turn_deg", 45.0)))
	for s in _ships:
		var node: Node3D = s["node"]
		node.visible = int(s["system"]) == view
		var left := maxf(0.0, dt)
		var n := 0
		while left > 0.0 and n < 4000:
			n += 1
			var h := minf(left, SUBSTEP)
			left -= h
			if float(s["wait"]) > 0.0:
				s["wait"] = float(s["wait"]) - h
				if float(s["wait"]) <= 0.0:
					_new_leg(s)
				continue
			var r := Motion.step(s, s["to"], vmax, accel, brake, turn, h)
			s["pos"] = r["pos"]
			s["yaw"] = r["yaw"]
			s["speed"] = r["speed"]
			if r["arrived"]:
				s["wait"] = maxf(0.01, _bal("rival_ship_wait_s", 3.0))
		var p: Vector2 = s["pos"]
		node.position = Vector3(p.x, LIFT, p.y)
		node.rotation.y = float(s["yaw"])
		var tr: Node = s.get("trail")  # T198: advance() only runs while the game runs, so the trail is idle when paused
		if tr != null:
			tr.visible = node.visible
			tr.push(node.position, dt, float(s["speed"]) > 0.02 and node.visible)

func ship_count() -> int:
	return _ships.size()

func _process(delta: float) -> void:
	if main == null or bool(main.paused) or bool(main.game_over):
		return
	advance(delta * float(main.time_speed))
