extends Node3D
## T187: rival ships flying around the map. A VISUAL ONLY: no cargo, no collision shape, no picking, no blocking, no combat, no
## effect on routes, prices, shares or the Pathfinder. Rivals stay numbers in the economy (Markets bots); these ships are scenery.
## T196: each ship picks a destination (a point over the planets of its system), speeds up from rest, turns at a limited yaw rate,
## flies a straight course and brakes to a stop there. T214: it then IDLES (no new random course); it moves again only when the game
## gives a reason: wake() (a system opened by permit, an event popup), then it flies one new leg and idles again. No random jitter.
## Each ship flies on the plane y = LIFT, like the
## Pathfinder. They move only while the game runs (main.paused false, speed follows main.time_speed), as the Pathfinder does.
## T211: ONE ship per competitor for the whole game (count() = number of rival bots, Bots.IDS), not one per system. It starts in
## system 1 and may fly over to a system the player opened by permit (main.open_systems) for a few legs, then comes back. It exists
## on the map only in its current system (hidden elsewhere); a closed system never has a ship in it. The old balance key
## rival_ship_count is retired (it was ships per system; it is not in data/balance.json). Speed in map units per second: SPEED_DEFAULT (same note, rival_ship_speed).
## Look (model, tint, size, trail) is NOT decided here: it uses the ship models of data/ships.json other than the player's,
## fitted like the Pathfinder, and a small cone when no model loads.

const Ships := preload("res://game/ships.gd")
const Motion := preload("res://game/ship_motion.gd")  # T196

const Bots := preload("res://game/bots.gd")
const VISIT_CHANCE := 0.3       # T211: chance per new course that a ship at home visits an opened system
const VISIT_LEGS_MIN := 2
const VISIT_LEGS_MAX := 3
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
var _seen_open: Array = [1]      # T214: open systems last seen; a new one is a reason to move
var _event_was := false         # T214: an event popup was pending last frame (rising edge = a reason to move)
var _built := false             # T211: the one ship per competitor exists

func setup(m: Node, mp: Node) -> void:
	main = m
	map = mp
	_rng.seed = 20261105  # visual only, but the same every run
	name = "RivalShips"

func count() -> int:
	return Bots.IDS.size()

## T211: systems where ship traffic may exist: system 1 and the ones opened by a permit.
func open_ids() -> Array:
	var out: Array = [1]
	if main != null and "open_systems" in main:
		for v in main.open_systems:
			if not out.has(int(v)):
				out.append(int(v))
	return out

func _bal(key: String, dflt: float) -> float:
	return float(main.balance.get(key, dflt)) if main != null and "balance" in main else dflt

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
	_built = true
	var sys := 1
	for n in count():
		var node := _make_ship(str(kinds[n % kinds.size()]))
		add_child(node)
		var trail := ShipTrail.new()  # T198: world-space, a sibling of the ship so it ignores the ship's yaw
		trail.tint = TRAIL_TINT
		add_child(trail)
		var from := _random_point(sys)
		_ships.append({"node": node, "system": sys, "pos": Vector2(from.x, from.z), "yaw": _rng.randf_range(-PI, PI), "speed": 0.0,
			"to": Vector2(from.x, from.z), "wait": 0.0, "trail": trail, "visit": 0})
		var last: Dictionary = _ships[_ships.size() - 1]
		_new_leg(last)
		node.position = Vector3(from.x, LIFT, from.z)
		last["yaw"] = Motion.yaw_to((last["to"] as Vector2) - (last["pos"] as Vector2))  # starts facing its first course
		node.rotation.y = float(last["yaw"])

## T211: puts a ship into system `sys` at a random spot (a visit begins or ends); its trail restarts.
func _move_to_system(s: Dictionary, sys: int) -> void:
	s["system"] = sys
	var p := _random_point(sys)
	s["pos"] = Vector2(p.x, p.z)
	s["speed"] = 0.0
	var tr: Node = s.get("trail")
	if tr != null:
		tr.clear()

## T214: a reason to move: every idle ship picks one new course (it may visit an opened system or head home).
func wake() -> void:
	for s in _ships:
		if bool(s.get("parked", false)):
			s["parked"] = false
			_new_leg(s)

func _check_reasons() -> void:
	var open := open_ids()
	var changed := open.size() != _seen_open.size()
	for v in open:
		if not _seen_open.has(v):
			changed = true
	_seen_open = open
	var ev: bool = main != null and "events" in main and main.events != null and str(main.events.pending_id) != ""
	if ev and not _event_was:
		changed = true
	_event_was = ev
	if changed:
		wake()

func _new_leg(s: Dictionary) -> void:
	var open := open_ids()
	if not open.has(int(s["system"])):
		_move_to_system(s, 1)  # its system is closed: back home
		s["visit"] = 0
	elif int(s["visit"]) > 0:
		s["visit"] = int(s["visit"]) - 1
		if int(s["visit"]) == 0:
			_move_to_system(s, 1)  # the visit is over
	elif int(s["system"]) == 1 and open.size() > 1 and _rng.randf() < VISIT_CHANCE:
		var others := open.duplicate()
		others.erase(1)
		_move_to_system(s, int(others[_rng.randi() % others.size()]))
		s["visit"] = _rng.randi_range(VISIT_LEGS_MIN, VISIT_LEGS_MAX)
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
	if not _built:
		_build()
	_check_reasons()
	var view: int = int(map.view_system) if map != null else 1
	var vmax := maxf(0.01, _bal("rival_ship_speed", SPEED_DEFAULT))
	var accel := vmax / maxf(0.05, _bal("rival_ship_accel_s", 2.0))
	var brake := vmax / maxf(0.05, _bal("rival_ship_brake_s", 2.0))
	var turn := deg_to_rad(maxf(1.0, _bal("rival_ship_turn_deg", 45.0)))
	for s in _ships:
		var node: Node3D = s["node"]
		if not open_ids().has(int(s["system"])):
			_move_to_system(s, 1)
			s["visit"] = 0
			s["wait"] = 0.0
			_new_leg(s)
		var left := maxf(0.0, dt)
		var n := 0
		while left > 0.0 and n < 4000:
			n += 1
			var h := minf(left, SUBSTEP)
			left -= h
			if bool(s.get("parked", false)):
				break
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
				s["parked"] = true  # T214: idles here until wake()
				s["wait"] = 0.0
		node.visible = int(s["system"]) == view
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
