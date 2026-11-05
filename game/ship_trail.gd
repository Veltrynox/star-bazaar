extends MeshInstance3D
## T198: short fading engine trail behind a map ship. World-space (top_level), so it never inherits the ship's yaw or the model's
## MODEL_YAW_DEG pivot. No collision, no picking. Cost: one ImmediateMesh line strip of at most MAX_POINTS vertices, rebuilt
## only while it has points; the caller feeds it only while the game runs, so a paused game does no work at all.

const MAX_POINTS := 14      # longest trail in samples
const MIN_STEP := 0.06      # world units the ship must move before a new sample is added
const LIFE_S := 0.9         # seconds (game time) a sample lives before it has faded out
const START_ALPHA := 0.7    # alpha at the ship end

var tint := Color(1.0, 0.8, 0.45)
var _pts: Array = []        # [Vector3, age]
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
	material_override = m

func point_count() -> int:
	return _pts.size()

## Call once per game-time step. `pos` is the engine point in world space; `moving` false lets the trail fade out.
func push(pos: Vector3, dt: float, moving: bool) -> void:
	if dt > 0.0:
		for p in _pts:
			p[1] += dt
		while not _pts.is_empty() and float(_pts[0][1]) >= LIFE_S:
			_pts.pop_front()
	if moving and (_pts.is_empty() or (_pts[_pts.size() - 1][0] as Vector3).distance_to(pos) >= MIN_STEP):
		_pts.append([pos, 0.0])
		if _pts.size() > MAX_POINTS:
			_pts.pop_front()
	_redraw(pos if moving else Vector3.INF)

func clear() -> void:
	_pts.clear()
	_mesh.clear_surfaces()

func _redraw(head: Vector3) -> void:
	_mesh.clear_surfaces()
	if _pts.size() < 2 and head == Vector3.INF:
		return
	if _pts.is_empty():
		return
	_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for p in _pts:
		var a := START_ALPHA * clampf(1.0 - float(p[1]) / LIFE_S, 0.0, 1.0)
		_mesh.surface_set_color(Color(tint.r, tint.g, tint.b, a))
		_mesh.surface_add_vertex(p[0])
	if head != Vector3.INF:  # joins the newest sample to the ship so the trail has no gap
		_mesh.surface_set_color(Color(tint.r, tint.g, tint.b, START_ALPHA))
		_mesh.surface_add_vertex(head)
	_mesh.surface_end()
