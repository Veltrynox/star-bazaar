extends MeshInstance3D
## T68: route drawn as a straight camera-facing arrow (art/route/route_arrow_tail|mid|head.png, 198 px tall, one whole
## arrow pointing right: tail at the source, tiled mid, head at the destination). A one-way route draws one arrow
## over the full line; when the opposite direction also exists (`half`), each arrow covers only its half of the line
## (source end to the middle) and they meet in the middle. A brightness/alpha wave travels source to destination;
## white = running, grey and slow = stalled, red = blocked.

const GAP := 1.06             # line starts this far (x planet radius) from planet centres
const ART_WIDTH := 0.18       # world units per ART_REF px of art height (same thickness as the earlier art)
const ART_REF := 172.0
const ART_H := 198.0          # arrow art height in px
const TAIL_W := 72.0
const MID_W := 81.0
const HEAD_W := 367.0
const SAMPLES := 12           # points used for click picking

const COL_RUNNING := Color(1, 1, 1, 0.9)
const COL_STALLED := Color(0.65, 0.65, 0.65, 0.7)
const COL_BLOCKED := Color(1.0, 0.25, 0.2, 0.9)
const SPEED_RUNNING := 0.7    # pulse cycles per second
const SPEED_STALLED := 0.15
const PULSE_LEN := 0.9        # world units per pulse wavelength

const SHADER_CODE := """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform sampler2D tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 modulate : source_color = vec4(1.0);
uniform float half_width = 0.1;
uniform float speed = 0.7;
uniform float pulse_len = 0.9;
varying vec2 uvv;
varying float along;
void vertex() {
	vec3 vp = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 t = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vec3 side = normalize(cross(t, normalize(vp)));  // left of travel direction
	vp += side * UV.y * half_width;  // UV.y: -1 right edge .. +1 left edge
	POSITION = PROJECTION_MATRIX * vec4(vp, 1.0);
	uvv = vec2(UV.x, 0.5 - 0.5 * UV.y);  // art top = left of travel
	along = COLOR.r;
}
void fragment() {
	vec4 c = texture(tex, uvv);
	float w = 0.5 + 0.5 * sin(6.2831853 * (along / pulse_len - TIME * speed));
	ALBEDO = c.rgb * modulate.rgb * mix(0.7, 1.45, w);
	ALPHA = c.a * modulate.a * mix(0.4, 1.0, w);
}
"""

## T114: one dot per ship with a fading trail, leaving the source and arriving at the destination (visual only).
const DOT_RADIUS := 0.07      # world units
const DOT_TRAIL := 0.9        # trail length, world units
const DOT_PERIOD := 2.4       # seconds for one trip
const DOT_MAX := 12           # most dots drawn on one lane
const DOT_SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform vec3 p0;
uniform vec3 dir;
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
	vec3 pm = p0 + dir * pos_along;
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
static var _textures: Array = []

var route_id: int = -1
var pair_a: int = -1
var pair_b: int = -1
var half: bool = false
var radius: float = 0.8
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
		for n in ["tail", "mid", "head"]:
			_textures.append(load("res://art/route/route_arrow_%s.png" % n))
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	extra_cull_margin = 2.0
	var dir := (pos_b - pos_a).normalized()
	var p0 := pos_a + dir * planet_radius * GAP
	var p2 := pos_b - dir * planet_radius * GAP
	if half:
		p2 = p0.lerp(p2, 0.5)  # this direction's arrow ends in the middle of the line
	_pts = PackedVector3Array([p0, p2])
	var total := p0.distance_to(p2)
	_cum = PackedFloat32Array([0.0, total])
	var unit := ART_WIDTH / ART_REF  # world units per art pixel
	var tail_l := TAIL_W * unit
	var head_l := HEAD_W * unit
	var mid_l := MID_W * unit
	var k := 1.0
	if tail_l + head_l > total * 0.9:  # short line: shrink the whole arrow
		k = total * 0.9 / (tail_l + head_l)
	tail_l *= k
	head_l *= k
	var mid_span := maxf(total - tail_l - head_l, 0.0)
	var tiles := maxf(1.0, roundf(mid_span / (mid_l * k)))
	var am := ArrayMesh.new()
	_add_strip(am, 0.0, tail_l, 1, 1.0)
	_add_strip(am, tail_l, tail_l + mid_span, 1, tiles)
	_add_strip(am, tail_l + mid_span, total, 1, 1.0)
	mats.clear()
	for s in 3:
		var m := ShaderMaterial.new()
		m.shader = _shader
		m.set_shader_parameter("tex", _textures[s])
		m.set_shader_parameter("half_width", ART_H * unit * 0.5 * k)
		m.set_shader_parameter("pulse_len", PULSE_LEN)
		am.surface_set_material(s, m)
		mats.append(m)
	mesh = am
	samples = PackedVector3Array()
	for i in SAMPLES + 1:
		samples.append(p0.lerp(p2, float(i) / float(SAMPLES)))
	_setup_dots(p0, (p2 - p0).normalized(), total)
	set_style("running", 1)

func _setup_dots(p0: Vector3, dir: Vector3, total: float) -> void:
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
	_dot_mat.set_shader_parameter("p0", p0)
	_dot_mat.set_shader_parameter("dir", dir)
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

## Point and tangent at distance s along the line.
func _at(s: float) -> Array:
	var total := _cum[_cum.size() - 1]
	var t := clampf(s / maxf(total, 0.00001), 0.0, 1.0)
	return [_pts[0].lerp(_pts[1], t), (_pts[1] - _pts[0]).normalized()]

func _add_strip(am: ArrayMesh, s0: float, s1: float, steps: int, u_max: float) -> void:
	var verts := PackedVector3Array()
	var tans := PackedVector3Array()
	var uvs := PackedVector2Array()
	var cols := PackedColorArray()
	var idx := PackedInt32Array()
	for i in steps + 1:
		var f := float(i) / float(steps)
		var at := _at(lerpf(s0, s1, f))
		for side in [-1.0, 1.0]:  # right edge, left edge of travel
			verts.append(at[0])
			tans.append(at[1])
			uvs.append(Vector2(f * u_max, side))
			cols.append(Color(lerpf(s0, s1, f), 0, 0, 1))
		if i < steps:
			var k := i * 2
			idx.append_array(PackedInt32Array([k, k + 1, k + 2, k + 1, k + 3, k + 2]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = tans
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = cols
	arrays[Mesh.ARRAY_INDEX] = idx
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

## Tint from route status: running = art colours, stalled = dim, blocked = red.
func set_style(status: String, ships: int) -> void:
	if _dots != null:  # T114: dots only while ships actually run
		var n := mini(ships, DOT_MAX) if status == "running" else 0
		if n != _dot_count:
			_build_dots(n)
		_dot_mat.set_shader_parameter("modulate", Color(1, 1, 1, 0.95))
	var col := COL_RUNNING
	if status == "blocked":
		col = COL_BLOCKED
	elif status != "running":
		col = COL_STALLED
	var spd := SPEED_STALLED if (status != "running" and status != "blocked") else SPEED_RUNNING
	for m in mats:
		m.set_shader_parameter("modulate", col)
		m.set_shader_parameter("speed", spd)

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
