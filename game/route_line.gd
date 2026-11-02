extends MeshInstance3D
## Route drawn as an arched curve like the design (SystemView.html): a thin commodity-coloured line at half opacity,
## a small chevron at the middle pointing to the destination, ship dots with trails along the curve.
## Waiting (stalled) routes are dashed signal-warn; blocked routes are solid red. The two directions of a pair
## bow to opposite sides on their own, since the bow is taken to the left of travel.

const GAP := 1.06             # line starts this far (x planet radius) from planet centres
const BOW := 0.2              # arch height as a share of the line length
const HALF_W := 0.022         # world units: half the line thickness (design: 1.5 px)
const LINE_ALPHA := 0.5
const DASH_LEN := 0.3         # world units for one dash step (design: 5 on, 5 off)
const STEPS := 28             # segments of the curve mesh
const SAMPLES := 16           # points used for click picking
const CHEV_LEN := 0.2         # chevron arm length, world units

const SHADER_CODE := """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform vec4 modulate : source_color = vec4(1.0);
uniform float half_width = 0.022;
uniform float dash = 0.0;
uniform float dash_len = 0.3;
varying float along;
void vertex() {
	vec3 vp = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 t = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vec3 side = normalize(cross(t, normalize(vp)));
	vp += side * UV.y * half_width;
	POSITION = PROJECTION_MATRIX * vec4(vp, 1.0);
	along = COLOR.r;
}
void fragment() {
	float on = 1.0;
	if (dash > 0.5) {
		on = step(fract(along / (dash_len * 2.0)), 0.5);
	}
	ALBEDO = modulate.rgb;
	ALPHA = modulate.a * on;
}
"""

## One dot per ship with a fading trail, leaving the source and arriving at the destination (visual only).
const DOT_RADIUS := 0.07      # world units
const DOT_TRAIL := 0.9        # trail length, world units
const DOT_PERIOD := 2.4       # seconds for one trip
const DOT_MAX := 12           # most dots drawn on one lane
const DOT_SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform vec3 p0;
uniform vec3 pc;
uniform vec3 p2;
uniform float len = 1.0;
uniform float radius = 0.07;
uniform float trail = 0.9;
uniform float period = 2.4;
uniform vec4 modulate : source_color = vec4(1.0);
varying float back;
varying float side_w;
varying float pos_along;
varying float head_fade;
void vertex() {
	float s = fract(TIME / period + COLOR.g);
	float head = s * len;
	back = mix(-radius, trail, COLOR.r);
	pos_along = head - back;
	side_w = UV.y * radius;
	head_fade = smoothstep(0.0, 0.08, s) * (1.0 - smoothstep(0.92, 1.0, s));
	float u = clamp(pos_along / len, 0.0, 1.0);
	vec3 pm = (1.0 - u) * (1.0 - u) * p0 + 2.0 * (1.0 - u) * u * pc + u * u * p2;
	vec3 dir = normalize(2.0 * (1.0 - u) * (pc - p0) + 2.0 * u * (p2 - pc));
	vec3 vp = (MODELVIEW_MATRIX * vec4(pm, 1.0)).xyz;
	vec3 t = normalize((MODELVIEW_MATRIX * vec4(dir, 0.0)).xyz);
	vp += normalize(cross(t, normalize(vp))) * side_w;
	POSITION = PROJECTION_MATRIX * vec4(vp, 1.0);
}
void fragment() {
	float a;
	if (back <= 0.0) {
		a = 1.0 - smoothstep(0.7 * radius, radius, length(vec2(back, side_w)));
	} else {
		float k = clamp(1.0 - back / trail, 0.0, 1.0);
		float w = radius * k + 0.0001;
		a = k * k * 0.7 * (1.0 - smoothstep(0.6 * w, w, abs(side_w)));
	}
	a *= head_fade * step(0.0, pos_along) * step(pos_along, len);
	ALBEDO = modulate.rgb;
	ALPHA = a * modulate.a;
}
"""

static var _dot_shader: Shader
static var _shader: Shader

var route_id: int = -1
var pair_a: int = -1
var pair_b: int = -1
var half: bool = false
var radius: float = 0.8
var _p0: Vector3
var _c: Vector3
var _p2: Vector3
var _color_key := ""
var mats: Array[ShaderMaterial] = []
var samples: PackedVector3Array = PackedVector3Array()
var _pts: PackedVector3Array = PackedVector3Array()
var _cum: PackedFloat32Array = PackedFloat32Array()
var _dots: MeshInstance3D
var _dot_mat: ShaderMaterial
var _dot_count: int = 0

func setup(id: int, a: int, b: int, pos_a: Vector3, pos_b: Vector3, planet_radius: float, is_half: bool = false) -> void:
	half = is_half
	route_id = id
	pair_a = a
	pair_b = b
	radius = planet_radius
	if _shader == null:
		_shader = Shader.new()
		_shader.code = SHADER_CODE
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	extra_cull_margin = 2.0
	var dir := (pos_b - pos_a).normalized()
	var p0 := pos_a + dir * planet_radius * GAP
	var p2 := pos_b - dir * planet_radius * GAP
	var chord := p0.distance_to(p2)
	var left := Vector3.UP.cross(dir).normalized()  # left of travel, in the map plane
	_c = (p0 + p2) * 0.5 + left * chord * BOW
	_p0 = p0
	_p2 = p2
	_pts = PackedVector3Array()
	_cum = PackedFloat32Array()
	var acc := 0.0
	for i in STEPS + 1:
		var q := _bez(float(i) / float(STEPS))
		if i > 0:
			acc += q.distance_to(_pts[i - 1])
		_pts.append(q)
		_cum.append(acc)
	var total := acc
	var am := ArrayMesh.new()
	_add_strip(am, 0.0, total, STEPS)
	# chevron at the middle, like the design's ">" mark
	var mid := _at(total * 0.5)
	var tan: Vector3 = mid[1]
	var sd := tan.cross(Vector3.UP).normalized()
	var tip: Vector3 = mid[0] + tan * (CHEV_LEN * 0.3)
	for sg in [-1.0, 1.0]:
		var tail: Vector3 = mid[0] - tan * (CHEV_LEN * 0.7) + sd * sg * CHEV_LEN * 0.6
		_add_seg(am, tail, tip)
	mats.clear()
	for s in am.get_surface_count():
		var m := ShaderMaterial.new()
		m.shader = _shader
		m.set_shader_parameter("half_width", HALF_W)
		m.set_shader_parameter("dash_len", DASH_LEN)
		am.surface_set_material(s, m)
		mats.append(m)
	mesh = am
	samples = PackedVector3Array()
	for i in SAMPLES + 1:
		samples.append(_bez(float(i) / float(SAMPLES)))
	_setup_dots(total)
	set_style("running", 1)

func _bez(t: float) -> Vector3:
	var u := 1.0 - t
	return _p0 * (u * u) + _c * (2.0 * u * t) + _p2 * (t * t)

func _setup_dots(total: float) -> void:
	if _dot_shader == null:
		_dot_shader = Shader.new()
		_dot_shader.code = DOT_SHADER
	if _dots == null:
		_dots = MeshInstance3D.new()
		_dots.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(_dots)
	_dots.extra_cull_margin = total + 4.0
	_dot_mat = ShaderMaterial.new()
	_dot_mat.shader = _dot_shader
	_dot_mat.set_shader_parameter("p0", _p0)
	_dot_mat.set_shader_parameter("pc", _c)
	_dot_mat.set_shader_parameter("p2", _p2)
	_dot_mat.set_shader_parameter("len", total)
	_dot_mat.set_shader_parameter("radius", DOT_RADIUS)
	_dot_mat.set_shader_parameter("trail", minf(DOT_TRAIL, total))
	_dot_mat.set_shader_parameter("period", DOT_PERIOD)
	_dots.material_override = _dot_mat
	_dot_count = -1

## One quad per ship, evenly spread in time so ships on a shared lane leave one after another.
func _build_dots(n: int) -> void:
	_dot_count = n
	if n <= 0:
		_dots.mesh = null
		return
	var verts := PackedVector3Array()
	var uvs := PackedVector2Array()
	var cols := PackedColorArray()
	var idx := PackedInt32Array()
	for i in n:
		var ph := float(i) / float(n)
		for tt in [0.0, 1.0]:
			for side in [-1.0, 1.0]:
				verts.append(Vector3.ZERO)
				uvs.append(Vector2(tt, side))
				cols.append(Color(tt, ph, 0, 1))
		var k := i * 4
		idx.append_array(PackedInt32Array([k, k + 1, k + 2, k + 1, k + 3, k + 2]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = cols
	arrays[Mesh.ARRAY_INDEX] = idx
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	_dots.mesh = am

## Point and tangent at distance s along the curve.
func _at(s: float) -> Array:
	var total := _cum[_cum.size() - 1]
	var d := clampf(s, 0.0, total)
	var i := 1
	while i < _cum.size() - 1 and _cum[i] < d:
		i += 1
	var seg := maxf(_cum[i] - _cum[i - 1], 0.00001)
	var f := clampf((d - _cum[i - 1]) / seg, 0.0, 1.0)
	return [_pts[i - 1].lerp(_pts[i], f), (_pts[i] - _pts[i - 1]).normalized()]

func _add_strip(am: ArrayMesh, s0: float, s1: float, steps: int) -> void:
	var verts := PackedVector3Array()
	var tans := PackedVector3Array()
	var uvs := PackedVector2Array()
	var cols := PackedColorArray()
	var idx := PackedInt32Array()
	for i in steps + 1:
		var f := float(i) / float(steps)
		var at := _at(lerpf(s0, s1, f))
		for side in [-1.0, 1.0]:
			verts.append(at[0])
			tans.append(at[1])
			uvs.append(Vector2(f, side))
			cols.append(Color(lerpf(s0, s1, f), 0, 0, 1))
		if i < steps:
			var k := i * 2
			idx.append_array(PackedInt32Array([k, k + 1, k + 2, k + 1, k + 3, k + 2]))
	_commit(am, verts, tans, uvs, cols, idx)

func _add_seg(am: ArrayMesh, pa: Vector3, pb: Vector3) -> void:
	var t := (pb - pa).normalized()
	var verts := PackedVector3Array()
	var tans := PackedVector3Array()
	var uvs := PackedVector2Array()
	var cols := PackedColorArray()
	for p in [pa, pb]:
		for side in [-1.0, 1.0]:
			verts.append(p)
			tans.append(t)
			uvs.append(Vector2(0, side))
			cols.append(Color(0, 0, 0, 1))
	_commit(am, verts, tans, uvs, cols, PackedInt32Array([0, 1, 2, 1, 3, 2]))

func _commit(am: ArrayMesh, verts: PackedVector3Array, tans: PackedVector3Array, uvs: PackedVector2Array, cols: PackedColorArray, idx: PackedInt32Array) -> void:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = tans
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = cols
	arrays[Mesh.ARRAY_INDEX] = idx
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

## Tint from route status: running = commodity colour, stalled (waiting) = dashed warn, blocked = solid red.
func set_style(status: String, ships: int, commodity: String = "") -> void:
	if _dots != null:  # dots only while ships actually run
		var n := mini(ships, DOT_MAX) if status == "running" else 0
		if n != _dot_count:
			_build_dots(n)
		_dot_mat.set_shader_parameter("modulate", Color(0.92, 0.91, 0.87, 0.95))
	var col := Ui.col("commodity_" + commodity) if commodity != "" else Color(1, 1, 1)
	if status == "blocked":
		col = Ui.col("signal_bad")
	elif status != "running":
		col = Ui.col("signal_warn")
	col.a = LINE_ALPHA
	for m in mats:
		m.set_shader_parameter("modulate", col)
		m.set_shader_parameter("dash", 1.0 if (status != "running" and status != "blocked") else 0.0)

## Smallest on-screen distance in pixels from `screen_pos` to the line (INF if it is behind the camera).
func screen_distance(cam: Camera3D, screen_pos: Vector2) -> float:
	var best := INF
	var prev := Vector2.ZERO
	var have_prev := false
	for p in samples:
		if cam.is_position_behind(p):
			have_prev = false
			continue
		var s := cam.unproject_position(p)
		if have_prev:
			var d := _seg_dist(screen_pos, prev, s)
			if d < best:
				best = d
		prev = s
		have_prev = true
	return best

static func _seg_dist(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var l2 := ab.length_squared()
	var t := 0.0 if l2 <= 0.0001 else clampf((p - a).dot(ab) / l2, 0.0, 1.0)
	return p.distance_to(a + ab * t)
