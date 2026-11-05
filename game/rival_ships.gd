extends Node3D
## T187: rival ships flying around the map. A VISUAL ONLY: no cargo, no collision shape, no picking, no blocking, no combat, no
## effect on routes, prices, shares or the Pathfinder. Rivals stay numbers in the economy (Markets bots); these ships are scenery.
## Each ship wanders between random points over the planets of the system being viewed, on the plane y = LIFT, like the
## Pathfinder. They move only while the game runs (main.paused false, speed follows main.time_speed), as the Pathfinder does.
## Number per system: balance key rival_ship_count (default COUNT_DEFAULT when the key is absent; the key belongs in
## data/balance.json, owner of that file to add it). Speed in map units per second: SPEED_DEFAULT (same note, rival_ship_speed).
## Look (model, tint, size, trail) is NOT decided here: it uses the ship models of data/ships.json other than the player's,
## fitted like the Pathfinder, and a small cone when no model loads.

const Ships := preload("res://game/ships.gd")

const COUNT_DEFAULT := 3
const SPEED_DEFAULT := 0.6      # world units per second at x1
const LIFT := 0.35
const FIT_RADIUS := 0.35
const MARGIN := 3.0             # world units around the planets that a rival may wander to

var main: Node = null
var map: Node = null
var _rng := RandomNumberGenerator.new()
var _ships: Array = []          # {node, system, from, to, t, dur}
var _built := false

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

func _bounds(sys: int) -> Rect2:
	var r := Rect2()
	var first := true
	for i in map.planets.size():
		if int(map.planets[i].get("system", 1)) != sys or i >= map.positions.size():
			continue
		var v: Vector3 = map.positions[i]
		if first:
			r = Rect2(Vector2(v.x, v.z), Vector2.ZERO)
			first = false
		else:
			r = r.expand(Vector2(v.x, v.z))
	return r.grow(MARGIN) if not first else Rect2()

func _random_point(sys: int) -> Vector3:
	var r := _bounds(sys)
	return Vector3(_rng.randf_range(r.position.x, r.end.x), 0.0, _rng.randf_range(r.position.y, r.end.y))

func _build() -> void:
	_built = true
	var kinds: Array = []
	for k in Ships.types():
		if str(k) != Ships.fleet:
			kinds.append(str(k))
	if kinds.is_empty():
		kinds = [Ships.DEFAULT]
	var n := 0
	for sys in _systems():
		for i in maxi(0, count()):
			var node := _make_ship(str(kinds[n % kinds.size()]))
			add_child(node)
			var from := _random_point(sys)
			_ships.append({"node": node, "system": sys, "from": from, "to": from, "t": 0.0, "dur": 0.0})
			_new_leg(_ships[_ships.size() - 1])
			n += 1

func _new_leg(s: Dictionary) -> void:
	s["from"] = s["to"]
	s["to"] = _random_point(int(s["system"]))
	var d: float = (s["to"] - s["from"]).length()
	s["dur"] = maxf(0.5, d / maxf(0.01, _bal("rival_ship_speed", SPEED_DEFAULT)))
	s["t"] = 0.0

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
		holder.add_child(model)
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

## Moves every rival by dt seconds of game time. Public so tests can drive it.
func advance(dt: float) -> void:
	if not _built:
		if map == null or map.positions.is_empty():
			return
		_build()
	var view: int = int(map.view_system) if map != null else 1
	for s in _ships:
		var node: Node3D = s["node"]
		node.visible = int(s["system"]) == view
		s["t"] = float(s["t"]) + dt
		if float(s["t"]) >= float(s["dur"]):
			_new_leg(s)
		var k := clampf(float(s["t"]) / maxf(0.001, float(s["dur"])), 0.0, 1.0)
		var d: Vector3 = s["to"] - s["from"]
		node.position = Vector3(0, LIFT, 0) + (s["from"] as Vector3).lerp(s["to"], k)
		if d.length() > 0.001:
			node.rotation.y = atan2(-d.x, -d.z)

func ship_count() -> int:
	return _ships.size()

func _process(delta: float) -> void:
	if main == null or bool(main.paused) or bool(main.game_over):
		return
	advance(delta * float(main.time_speed))
