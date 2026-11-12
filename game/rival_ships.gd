extends Node3D
## T187: rival ships flying around the map. A VISUAL ONLY: no cargo, no collision shape, no blocking, no combat, no
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
## Look (model, size, trail) is NOT decided here: it uses the ship models of data/ships.json other than the player's,
## fitted like the Pathfinder, and a small cone when no model loads.
## T199: ship i belongs to competitor Bots.IDS[i] (bot_of). Each wears a faint tint (TINTS, a see-through overlay on the meshes).
## Clicking a ship shows a card (game/rival_card.gd): pick_bot(screen_pos) is a screen-space test (PICK_PX) on the closest visible
## ship. It is only a hint test: the map still handles the click as before (a planet behind the ship stays clickable).

## T283 house convoys: the ship of house h is a convoy lead. When h has weather coming (main.forecast_id within convoy_lead_cycles + warning
## cycles of firing) or running (events.weather_of_house), the lead flies to that world and parks there with convoy_escorts escorts (a
## traffic free group, game/traffic) until the weather ends, then idles as before. The state is derived from saved data, nothing new is saved.

const Ships := preload("res://game/ships.gd")
const Motion := preload("res://game/ship_motion.gd")  # T196

const Bots := preload("res://game/bots.gd")
const VISIT_CHANCE := 0.3       # T211: chance per new course that a ship at home visits an opened system
const VISIT_LEGS_MIN := 2
const VISIT_LEGS_MAX := 3
const SPEED_DEFAULT := 0.6      # world units per second at x1
const LIFT := 0.35
const RIVAL_SHIP_SCALE := 0.5   # T198: ship size on the map; 1.0 is the old size (halved in T198). One constant for the rival ship kind.
const FIT_RADIUS_BASE := 0.35 * RIVAL_SHIP_SCALE

## T252: footprint radius times the global balance key ship_scale.
static func fit_radius() -> float:
	return FIT_RADIUS_BASE * Ships.ship_scale()
const PICK_PX := 20.0           # T199: click radius around a ship's projected position
const TINT_ALPHA := 0.3         # T199: strength of the competitor tint over the model (0 = none)
const TINTS := {1: Color(1.0, 0.45, 0.35), 2: Color(0.75, 0.45, 1.0), 3: Color(0.4, 0.95, 0.55)}  # T199: Harrow red, Velvet violet, Ostrel green

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
		var from := _random_point(sys)
		_ships.append({"node": node, "system": sys, "pos": Vector2(from.x, from.z), "yaw": _rng.randf_range(-PI, PI), "speed": 0.0,
			"to": Vector2(from.x, from.z), "wait": 0.0, "kind": str(kinds[n % kinds.size()]), "visit": 0})
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

## T214: a reason to move: every idle ship picks one new course (it may visit an opened system or head home).
func wake() -> void:
	for s in _ships:
		if bool(s.get("parked", false)) and int(s.get("wx", -1)) < 0:  # T283: a convoy parked at its world stays
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
	if int(s.get("wx", -1)) >= 0:  # T283: on convoy duty, no random course
		return
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
		holder.scale = Vector3.ONE * RIVAL_SHIP_SCALE * Ships.ship_scale()  # T198, T252
		holder.add_child(cone)
	else:
		var box := _aabb(model, Transform3D.IDENTITY)
		if box.size.length() > 0.0:
			var rxz := 0.000001
			for i in 8:
				var c := box.get_endpoint(i) - box.get_center()
				rxz = maxf(rxz, Vector2(c.x, c.z).length())
			holder.scale = Vector3.ONE * (fit_radius() / rxz)
			model.position = -box.get_center()
		var plume := EnginePlume.new()  # T356: default shape, rival palette; child of the model so the fit scale and the yaw pivot apply
		plume.running = func() -> bool: return main != null and not bool(main.paused) and not bool(main.game_over)  # own counter, frozen while paused
		model.add_child(plume)
		plume.set_engines(Ships.engine_points(kind, box))
		plume.set_look(ShipLook.rival_look())
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
	for i in _ships.size():
		var s: Dictionary = _ships[i]
		_update_convoy(s, bot_of(i))
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
		_sync_escorts(s, bot_of(i), node.visible)

## T283: the planet index house `h` has weather for now (running) or soon (forecast within the lead), -1 when none.
func weather_target(h: int) -> int:
	if main == null or not ("events" in main) or main.events == null:
		return -1
	var ev = main.events
	for w in ev.weather_of_house(h):
		if int(w["left"]) > 0:
			return int(w["planet"])
	var fid := str(main.forecast_id) if "forecast_id" in main else ""
	if fid == "" or not ev.by_id.has(fid) or int(ev.house_of(fid)) != h:
		return -1
	var ahead := int(main.forecast_slot) - int(main.cycle)
	var lead := int(_bal("convoy_lead_cycles", 1.0)) + Skills.warning_cycles()
	if ahead < 1 or ahead > lead:
		return -1
	var e: Dictionary = ev.effect_of_event(fid)
	return int(e["planet"]) if e.has("planet") else -1

## T283: sends the lead to its weather world, or lets it go when the weather is over.
func _update_convoy(s: Dictionary, h: int) -> void:
	var t := weather_target(h)
	if t == int(s.get("wx", -1)):
		return
	s["wx"] = t
	if t < 0 or t >= map.positions.size():
		s["wx"] = -1
		s["parked"] = false  # leaves: one new course, then idles as before (T214)
		_new_leg(s)
		return
	var sys := int(map.planets[t].get("system", 1))
	if not open_ids().has(sys):
		s["wx"] = -1
		return
	if int(s["system"]) != sys:
		_move_to_system(s, sys)
	s["visit"] = 0
	var c := Vector2(map.positions[t].x, map.positions[t].z)
	var gap := _bal("convoy_park_gap", 0.6)
	var from: Vector2 = s["pos"]
	var p: Vector2 = map.dock_point(c, map.planet_radius(t) + gap, from if from.distance_to(c) > 0.01 else c + Vector2(1, 0), sys)
	s["to"] = p
	s["wait"] = 0.0
	s["parked"] = false

func _escort_key(h: int, k: int) -> String:
	return "convoy_%d_%d" % [h, k]

## T283: escorts form up behind the lead (traffic free ships), only while the convoy is on duty and in the viewed system.
func _sync_escorts(s: Dictionary, h: int, shown: bool) -> void:
	var layer: Node = map.traffic if map != null and "traffic" in map else null
	if layer == null:
		return
	var n := int(_bal("convoy_escorts", 2.0))
	var duty := int(s.get("wx", -1)) >= 0 and shown
	var yaw := float(s["yaw"])
	var back := Vector2(sin(yaw), cos(yaw))
	var side := Vector2(-back.y, back.x)
	var gap := _bal("convoy_escort_gap", 0.35)
	var lead: Vector2 = s["pos"]
	for k in maxi(n, int(s.get("escorts", 0))):
		var key := _escort_key(h, k)
		if not duty or k >= n:
			layer.clear_group(key)
			continue
		var row := float(k / 2 + 1)
		var off := back * gap * row + side * gap * 0.6 * row * (1.0 if k % 2 == 0 else -1.0)
		layer.set_free_ship(key, lead + off, lead + off, "corvette", TINTS.get(h, Color.WHITE), LIFT, _bal("convoy_escort_scale", 0.8))
	s["escorts"] = n if duty else 0

## T199: the competitor (id of Bots.IDS) that owns ship i, 0 when i is out of range.
static func bot_of(i: int) -> int:
	return int(Bots.IDS[i]) if i >= 0 and i < Bots.IDS.size() else 0


func _overlay(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		node.material_overlay = mat
	for ch in node.get_children():
		_overlay(ch, mat)

## T199: index of the closest point within `radius` of `pos`, -1 if none. A point of INF (hidden or behind the camera) never hits.
static func pick_index(points: Array, pos: Vector2, radius: float) -> int:
	var best := -1
	var bd := radius
	for i in points.size():
		var d := (points[i] as Vector2).distance_to(pos)
		if d <= bd:
			bd = d
			best = i
	return best

## T199: the competitor whose ship is under the cursor (closest one), 0 when none. Visible ships only.
func pick_bot(screen_pos: Vector2) -> int:
	var cam: Camera3D = map.camera if map != null and "camera" in map else null
	if cam == null:
		return 0
	var pts: Array = []
	for s in _ships:
		var n: Node3D = s["node"]
		if not n.visible or not n.is_inside_tree() or cam.is_position_behind(n.global_position):
			pts.append(Vector2(INF, INF))
		else:
			pts.append(cam.unproject_position(n.global_position))
	var i := pick_index(pts, screen_pos, PICK_PX)
	return bot_of(i) if i >= 0 else 0

## T199: screen position of competitor `bot`'s ship, or null when it is not drawn.
func screen_pos_of(bot: int) -> Variant:
	var cam: Camera3D = map.camera if map != null and "camera" in map else null
	if cam == null:
		return null
	for i in _ships.size():
		if bot_of(i) == bot:
			var n: Node3D = _ships[i]["node"]
			if n.visible and n.is_inside_tree() and not cam.is_position_behind(n.global_position):
				return cam.unproject_position(n.global_position)
	return null

func ship_count() -> int:
	return _ships.size()

func _process(delta: float) -> void:
	if main == null or bool(main.paused) or bool(main.game_over):
		return
	advance(delta * float(main.time_speed))
