extends MeshInstance3D
## T198/T246: short fading engine trail behind a map ship. World-space (top_level), so it never inherits the ship's yaw or the model's
## MODEL_YAW_DEG pivot. No collision, no picking. T246: two engine trails, each a thin bright core over a wide soft additive glow (4 ribbons, one mesh); taper and fade depend on sample age only, so adding or dropping samples never makes the width or brightness pop. Cost: ImmediateMesh ribbons of at most MAX_POINTS vertices, rebuilt
## only while it has points; the caller feeds it only while the game runs, so a paused game does no work at all.

# --- look constants (tune here) ---
const MAX_POINTS := 14      # longest trail in samples
const MIN_STEP := 0.06      # world units the ship must move before a new sample is added
const LIFE_S := 0.9         # seconds (game time) a sample lives before it has faded out
const START_ALPHA := 0.7    # glow alpha at the engine end
const ENGINE_SIDE := 0.12   # T246: each engine sits this far to the left and right of the centre point, world units
const GLOW_WIDTH := 0.14    # T246: outer glow ribbon width at the engine
const CORE_WIDTH := 0.04    # T246: bright core ribbon width at the engine
const GLOW_ALPHA := 0.45    # T246: outer glow strength (share of START_ALPHA)
const CORE_ALPHA := 1.0     # T246: core strength (share of START_ALPHA)
const CORE_WHITE := 0.65    # T246: how far the core colour is mixed toward white
const SIDE_SMOOTH := 14.0   # T246: per-second rate at which the head's sideways direction follows the heading (kills jitter)

var tint := Color(1.0, 0.8, 0.45)
var _pts: Array = []        # [centre Vector3, age, side Vector3 (unit, across the heading)]
var _side := Vector3.RIGHT  # smoothed side of the head
var _mesh := ImmediateMesh.new()

func _init() -> void:
	top_level = true
	mesh = _mesh
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.vertex_color_use_as_albedo = true
	m.no_depth_test = true
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	material_override = m

func point_count() -> int:
	return _pts.size()

## Call once per game-time step. `pos` is the engine centre in world space; `moving` false lets the trail fade out.
func push(pos: Vector3, dt: float, moving: bool) -> void:
	if dt > 0.0:
		for p in _pts:
			p[1] += dt
		while not _pts.is_empty() and float(_pts[0][1]) >= LIFE_S:
			_pts.pop_front()
	if moving and not _pts.is_empty():
		var d: Vector3 = pos - (_pts[_pts.size() - 1][0] as Vector3)
		d.y = 0.0
		if d.length() >= MIN_STEP * 0.5:  # heading from real movement, low-passed so tiny steps cannot flip it
			var target := Vector3(-d.z, 0.0, d.x).normalized()
			if target.dot(_side) < 0.0:
				target = -target
			_side = _side.lerp(target, clampf(SIDE_SMOOTH * maxf(dt, 0.0), 0.0, 1.0)).normalized()
	if moving and (_pts.is_empty() or (_pts[_pts.size() - 1][0] as Vector3).distance_to(pos) >= MIN_STEP):
		_pts.append([pos, 0.0, _side])
		if _pts.size() > MAX_POINTS:
			_pts.pop_front()
	_redraw(pos if moving else Vector3.INF)

func clear() -> void:
	_pts.clear()
	_mesh.clear_surfaces()

func _redraw(head: Vector3) -> void:
	_mesh.clear_surfaces()
	if _pts.is_empty() or (_pts.size() < 2 and head == Vector3.INF):
		return
	var pts: Array = []  # [centre, age 0..1 (share of life), side]
	for p in _pts:
		pts.append([p[0], clampf(float(p[1]) / LIFE_S, 0.0, 1.0), p[2]])
	if head != Vector3.INF:  # joins the newest sample to the engine so the trail has no gap
		pts.append([head, 0.0, _side])
	if pts.size() < 2:
		return
	var core_col := tint.lerp(Color.WHITE, CORE_WHITE)
	for e in [-1.0, 1.0]:
		_ribbon(pts, e, GLOW_WIDTH, GLOW_ALPHA, tint)
		_ribbon(pts, e, CORE_WIDTH, CORE_ALPHA, core_col)

func _ribbon(pts: Array, engine: float, width: float, strength: float, col: Color) -> void:
	_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for q in pts:
		var life := 1.0 - float(q[1])
		var side: Vector3 = q[2]
		var c: Vector3 = (q[0] as Vector3) + side * (engine * ENGINE_SIDE)
		var w := width * 0.5 * life  # taper by age, not by index
		var a := START_ALPHA * strength * life
		var cc := Color(col.r, col.g, col.b, a)
		_mesh.surface_set_color(cc)
		_mesh.surface_add_vertex(c + side * w)
		_mesh.surface_set_color(cc)
		_mesh.surface_add_vertex(c - side * w)
	_mesh.surface_end()
