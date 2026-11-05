extends Node3D
## T180: the Pathfinder on the map (3D scout ship, heading, flight path line, target marker, paused look) and the one thin
## interface between the UI and the flight logic that T179 builds. UNVERIFIED BY EXECUTION when written.
##
## ---- INTERFACE FOR T179 (gameplay-programmer) -------------------------------------------------------------------
## Set `main.map.flight = <accessor>` (any object, e.g. a RefCounted in game/flight.gd) when the run uses discovery.
## While `map.flight` is null, or `flight.is_enabled()` is false (balance key discovery_enabled = 0), NOTHING here draws,
## changes or blocks anything: every planet is known, no ship, no Fly/Establish buttons, no new signals fire.
##
## Accessor methods (all optional; a missing method reads as the default in brackets). World units are the map's own
## (map.positions[i], MAP_UNIT_SCALE x ORBIT_SCALE applied); the ship moves on the plane y = 0.
##   is_enabled() -> bool                  [false]  discovery on for this run
##   state() -> String                     ["idle"] "idle" | "flying" | "building"
##   ship_position() -> Vector3            [ZERO]   world position of the ship
##   system_id() -> int                    [1]      solar system the ship is in (it is drawn only in the viewed system)
##   target() -> Dictionary                [{}]     {"kind": "planet"|"storage"|"cluster"|"point", "pos": Vector3, "index": int}
##                                                  current or planned destination; {} when none
##   is_paused() -> bool                   [false]  game paused (planned line, ship stands still)
##   model_path() -> String                [""]     GLB of the chosen ship (data/ships.json "model"); empty draws a small cone
##   discovered(planet_id: String) -> bool [true]   name and type are known (the ship has arrived once, or Voltara)
##   post_built(planet_id) -> bool         [true]   trading post (living world) done: goods, prices, routes allowed
##   platform_built(planet_id) -> bool     [false]  mining platform (dead world) done
##   docked_at() -> String                 [""]     planet id the ship is at now (idle or building there), "" otherwise
##   build_target() -> String              [""]     planet id being built, "" when no build
##   build_progress() -> float             [0.0]    0..1 of the running build
##   build_cycles_left() -> float          [0.0]    cycles left of the running build
##   cost(planet_id) -> Dictionary         [{}]     {"cash": int, "cycles": float, "free": bool}
##   eta_cycles(planet_id) -> float        [-1.0]   flight time from the ship now; < 0 hides the line
##   can_platform(planet_id) -> bool       [false]  dead world and the mining skill is learned (button is absent otherwise)
##   request_fly(target: Dictionary) -> String      [""]  start or redirect the flight (target as in target()). Returns ""
##                                                  when accepted, or a refusal reason (none are defined for flying yet)
##   request_establish(planet_id: String) -> String [""]  start the build. Returns "" when accepted, else one reason:
##                                                  "fly_first" | "no_cash_post" | "no_cash_platform" | "busy"
##                                                  main.gd turns the reason into NOT_FLY_FIRST / NOT_POST_NO_CASH /
##                                                  NOT_PLATFORM_NO_CASH / NOT_POST_BUSY (post_notice_now). Other strings: no notice.
## main.gd also reads, for the tutorial: state(), docked_at(), post_built()/platform_built() (card TUT_G0_FLY until the ship
## docks at a closed world, TUT_G0_BUILD there, TUT_G0_WAIT while state() is "building"; over once a second world stands).
## main.planet_name(i) returns LBL_UNKNOWN_WORLD / LBL_UNKNOWN_DARK_WORLD whenever discovered() is false.
## A planet is "established" when post_built or platform_built is true. Anything else shows the closed panel.
##
## Signals the UI emits (connect them in main.gd; both live on game/map.gd, one connection point):
##   map.fly_requested(target: Dictionary)   same shape as target(); sent by: click on an established planet, on the
##       space station, on an asteroid pack, Shift+click on open space, and the "Fly here" button. A click on a closed
##       planet only selects it (panel with Fly here). T179 starts/redirects the flight; it posts NOT_POST_LEAVE if a build is cancelled.
##   map.establish_requested(planet_id: String)   the Establish button. T179 checks cash/dock/busy and posts NOT_FLY_FIRST,
##       NOT_POST_NO_CASH, NOT_PLATFORM_NO_CASH, NOT_POST_BUSY itself.
## When state changes (arrive, build done, flags change) the planet panel and map labels re-read the accessor on their own
## (the panel compares a signature each frame), so T179 needs no refresh call.
## Model forward axis is assumed -Z (Godot default); the ship is turned with rotation.y = atan2(-dx, -dz).

const FIT_RADIUS := 0.45       # horizontal footprint radius of the model in world units (planets are about 0.9 to 2.4 across)
const FIT_HEIGHT := 0.3
const LIFT := 0.35             # ship hovers above the map plane so it clears planet spheres' lower rim
const MARKER_RADIUS := 0.35
const COL_LINE_MOVING := Color(1.0, 0.85, 0.5, 0.9)
const COL_LINE_PAUSED := Color(1.0, 0.85, 0.5, 0.35)

var flight = null
var _model_path := ""
var _holder: Node3D
var _line: MeshInstance3D
var _mesh: ImmediateMesh
var _marker: MeshInstance3D
var _mat: StandardMaterial3D

# ---- safe accessor helpers (shared by map.gd and planet_panel.gd) ---------------------------------------------------

static func active(f) -> bool:
	return f != null and is_instance_valid(f) and f.has_method("is_enabled") and bool(f.is_enabled())

static func _call(f, m: String, args: Array, dflt):
	if f == null or not is_instance_valid(f) or not f.has_method(m):
		return dflt
	return f.callv(m, args)

static func state(f) -> String:
	return str(_call(f, "state", [], "idle")) if active(f) else "idle"

static func discovered(f, id: String) -> bool:
	return not active(f) or bool(_call(f, "discovered", [id], true))

static func post_built(f, id: String) -> bool:
	return not active(f) or bool(_call(f, "post_built", [id], true))

static func platform_built(f, id: String) -> bool:
	return active(f) and bool(_call(f, "platform_built", [id], false))

## True when the planet shows its normal panel and goods (always true with discovery off).
static func established(f, id: String) -> bool:
	return not active(f) or post_built(f, id) or platform_built(f, id)

static func docked_at(f) -> String:
	return str(_call(f, "docked_at", [], "")) if active(f) else ""

static func build_target(f) -> String:
	return str(_call(f, "build_target", [], "")) if active(f) else ""

static func build_progress(f) -> float:
	return float(_call(f, "build_progress", [], 0.0))

static func build_cycles_left(f) -> float:
	return float(_call(f, "build_cycles_left", [], 0.0))

static func cost(f, id: String) -> Dictionary:
	var c = _call(f, "cost", [id], {})
	return c if typeof(c) == TYPE_DICTIONARY else {}

static func eta_cycles(f, id: String) -> float:
	return float(_call(f, "eta_cycles", [id], -1.0))

static func can_platform(f, id: String) -> bool:
	return bool(_call(f, "can_platform", [id], false))

## One string that changes whenever something the panel or labels show changes (cheap polling instead of a refresh call).
static func signature(f, id: String) -> String:
	if not active(f):
		return ""
	return "%s|%s|%s|%s|%s|%s|%s" % [state(f), discovered(f, id), post_built(f, id), platform_built(f, id), docked_at(f), build_target(f), can_platform(f, id)]

# ---- the 3D ship --------------------------------------------------------------------------------------------------

func _ready() -> void:
	visible = false
	_mat = StandardMaterial3D.new()
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.vertex_color_use_as_albedo = true
	_mat.no_depth_test = true
	_mesh = ImmediateMesh.new()
	_line = MeshInstance3D.new()
	_line.mesh = _mesh
	_line.material_override = _mat
	_line.top_level = true  # drawn in world space whatever the parent does
	add_child(_line)
	var ring := TorusMesh.new()
	ring.inner_radius = MARKER_RADIUS * 0.8
	ring.outer_radius = MARKER_RADIUS
	_marker = MeshInstance3D.new()
	_marker.mesh = ring
	_marker.material_override = _mat
	_marker.top_level = true
	_marker.visible = false
	add_child(_marker)

## Called by map.gd every frame. Does nothing visible while the accessor is missing or discovery is off.
func update_from(f, view_system: int) -> void:
	flight = f
	if not active(f):
		visible = false
		_line.visible = false
		_marker.visible = false
		return
	var sys := int(_call(f, "system_id", [], 1))
	visible = sys == view_system
	_line.visible = visible
	if not visible:
		_marker.visible = false
		return
	_ensure_model(str(_call(f, "model_path", [], "")))
	var pos: Vector3 = _call(f, "ship_position", [], Vector3.ZERO)
	global_position = pos + Vector3(0, LIFT, 0)
	var paused := bool(_call(f, "is_paused", [], false))
	var tgt = _call(f, "target", [], {})
	_mesh.clear_surfaces()
	_marker.visible = false
	if typeof(tgt) == TYPE_DICTIONARY and tgt.has("pos") and state(f) != "building":
		var tp: Vector3 = tgt["pos"]
		var d := Vector2(tp.x - pos.x, tp.z - pos.z)
		if d.length() > 0.05:
			rotation.y = atan2(-d.x, -d.y)  # turn toward the heading (model forward is -Z)
			var col := COL_LINE_PAUSED if paused else COL_LINE_MOVING  # paused look: faint planned line, ship waits
			_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
			var a := pos + Vector3(0, LIFT, 0)
			var b := tp + Vector3(0, LIFT, 0)
			var n := maxi(2, int(a.distance_to(b) / 0.4))
			for k in range(0, n, 2):  # dashes
				_mesh.surface_set_color(col)
				_mesh.surface_add_vertex(a.lerp(b, float(k) / n))
				_mesh.surface_set_color(col)
				_mesh.surface_add_vertex(a.lerp(b, minf(float(k + 1) / n, 1.0)))
			_mesh.surface_end()
			_marker.global_position = tp + Vector3(0, LIFT, 0)
			_marker.visible = true

func _ensure_model(path: String) -> void:
	if path == _model_path and _holder != null:
		return
	_model_path = path
	if _holder != null:
		remove_child(_holder)
		_holder.queue_free()
		_holder = null
	var model: Node3D = null
	if path != "" and ResourceLoader.exists(path):
		var res = load(path)
		if res is PackedScene:
			model = res.instantiate()
	_holder = Node3D.new()
	if model == null:  # no model: a small cone pointing along -Z so the heading still reads
		var cone := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.0
		cm.bottom_radius = 0.12
		cm.height = 0.4
		cone.mesh = cm
		cone.rotation_degrees = Vector3(-90, 0, 0)
		_holder.add_child(cone)
	else:
		var box := _bounds(model, Transform3D.IDENTITY)  # same measured-bounds fit as game/ship_setup.gd
		if box.size.length() > 0.0:
			var rxz := 0.000001
			for i in 8:
				var c := box.get_endpoint(i) - box.get_center()
				rxz = maxf(rxz, Vector2(c.x, c.z).length())
			var ry := maxf(box.size.y * 0.5, 0.000001)
			_holder.scale = Vector3.ONE * minf(FIT_RADIUS / rxz, FIT_HEIGHT / ry)
			model.position = -box.get_center()
		_holder.add_child(model)
	add_child(_holder)

func _bounds(node: Node, t: Transform3D) -> AABB:
	var box := AABB()
	var first := true
	var xf := t
	if node is Node3D:
		xf = t * node.transform
	if node is MeshInstance3D and node.mesh != null:
		box = xf * node.mesh.get_aabb()
		first = false
	for c in node.get_children():
		var cb := _bounds(c, xf)
		if cb.size == Vector3.ZERO:
			continue
		box = cb if first else box.merge(cb)
		first = false
	return box
