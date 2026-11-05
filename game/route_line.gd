extends MeshInstance3D
## Route drawn like the design (SystemView.html): a 1.5 px commodity-coloured arc at half opacity, a full-strength
## chevron at the middle pointing to the destination, ship dots with trails going out and back along the arc.
## Waiting (stalled) routes are dashed signal-warn; blocked routes are solid red. The two directions of a pair
## bow to opposite sides on their own, since the bow is taken to the left of travel.

const StoryText := preload("res://game/story_text.gd")
const Juice := preload("res://game/juice.gd")  # T219

const GAP := 0.6              # line starts this far (x sphere scale) from planet centres: just outside the 0.56 glow shell of the halved planet (was 1.06)
const LANE_STEP := 0.45       # sideways gap between routes on one pair, x planet radius
const BOW := 0.2              # arch height as a share of the line length
const LINE_PX := 1.5          # design: stroke-width 1.5 (px in the 1672x941 frame)
const LINE_ALPHA := 0.5       # design: opacity .5
const DASH_PX := 5.0          # design: stroke-dasharray 5 5 (waiting)
const STEPS := 28             # segments of the curve mesh
const RouteOffset := preload("res://game/route_offset.gd")
const SAMPLES := 16           # points used for click picking
const LUT_N := 16             # arc-length table so dots move at even speed along the curve
const REF_H := 941.0          # design frame height: sizes in px are scaled from it

## T219 juice (visual only, game time: a paused game snaps these to their end state). All scaled by Juice.motion.
const DRAW_SECONDS := 0.25    # a new lane grows from its source end (alpha and width), EASE_OUT
const DRAW_WIDTH_FROM := 0.35 # line width share at the start of the draw-in
const DRAW_SOFT := 0.12       # soft leading edge of the draw-in, as a share of the lane
const FADE_SECONDS := 0.15    # a removed lane fades out before it is freed
const PULSE_SECONDS := 0.5    # a dispatched ship sends one brightening band source -> destination
const PULSE_WIDTH := 0.18     # band half-width, as a share of the lane
const PULSE_BOOST := 0.5      # extra alpha at the band centre (on top of LINE_ALPHA)
const PULSE_WHITE := 0.45     # share the colour is mixed towards white at the band centre

## Lines, dashes and the chevron are sized in design pixels (1672x941 frame), not world units, so they keep
## the same thickness at any zoom, as the SVG does.
const SHADER_CODE := """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform vec4 modulate : source_color = vec4(1.0);
uniform float half_px = 0.75;
uniform float dash = 0.0;
uniform float dash_px = 5.0;
uniform float chev = 0.0;
uniform vec3 chev_t = vec3(1.0, 0.0, 0.0);
uniform vec3 chev_s = vec3(0.0, 0.0, 1.0);
uniform float draw = 1.0;          // T219: draw-in progress 0..1 (width and reach)
uniform float fade = 1.0;          // T219: removal fade multiplier
uniform float pulse_at = -1.0;     // T219: dispatch band centre along the lane (< -1 or > 2 = off)
uniform float pulse_w = 0.18;
uniform float pulse_gain = 0.0;
uniform float draw_w0 = 0.35;
uniform float draw_soft = 0.12;
uniform float pulse_boost = 0.5;
uniform float pulse_white = 0.45;
varying float along;
varying float fr;
varying float edge_px;
const float AA_PX = 0.5;
void vertex() {
	vec3 base = VERTEX;
	vec3 v0 = (MODELVIEW_MATRIX * vec4(base, 1.0)).xyz;
	float wpp = 2.0 * max(-v0.z, 0.01) / (PROJECTION_MATRIX[1][1] * 941.0);
	if (chev > 0.5) {
		base += (chev_t * COLOR.g + chev_s * COLOR.b) * wpp;
	}
	vec3 vp = (MODELVIEW_MATRIX * vec4(base, 1.0)).xyz;
	vec3 t = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	// Side of the strip. When the line is seen end-on (tangent along the view ray) the cross product
	// collapses to zero, normalize() gives NaN and the strip vanishes or flickers: use a fixed axis then.
	vec3 cr = cross(t, normalize(vp));
	float crl = length(cr);
	vec3 alt = cross(t, vec3(0.0, 1.0, 0.0));
	float altl = length(alt);
	if (altl < 0.001) { alt = vec3(1.0, 0.0, 0.0); altl = 1.0; }
	vec3 side = crl > 0.02 ? cr / crl : alt / altl;
	float hp = half_px * mix(draw_w0, 1.0, draw);
	vp += side * UV.y * (hp + AA_PX) * wpp;
	edge_px = UV.y * (hp + AA_PX);
	fr = chev > 0.5 ? 0.5 : UV.x;  // signed: abs() per vertex would interpolate to a constant
	POSITION = PROJECTION_MATRIX * vec4(vp, 1.0);
	along = COLOR.r / wpp;
}
void fragment() {
	float hp = half_px * mix(draw_w0, 1.0, draw);
	float on = clamp(hp + AA_PX - abs(edge_px), 0.0, 1.0);  // soft 1 px edge across the line
	on *= clamp((draw * (1.0 + draw_soft) - fr) / draw_soft, 0.0, 1.0);  // grows from the source end
	if (dash > 0.5) {
		float a = along / (dash_px * 2.0);
		float dd = abs(fract(a + 0.25) - 0.5);
		on *= clamp((0.25 - dd) / max(fwidth(a), 0.0001) + 0.5, 0.0, 1.0);  // soft dash ends
	}
	float band = pulse_gain * clamp(1.0 - abs(fr - pulse_at) / pulse_w, 0.0, 1.0);
	ALBEDO = mix(modulate.rgb, vec3(1.0), band * pulse_white);
	ALPHA = min(1.0, modulate.a + band * pulse_boost) * on * fade;
}
"""

## Ship dots as in the design: a head dot (2.6 px) with six trail dots (2 - 0.2j px), spaced 1.2% of the length
## apart, going out loaded (ink), coming back empty (ink-muted, shorter trail), a waiting ship parked at 90%
## in signal-warn with no trail. The trip is a ping-pong over 04%..96% at 0.07 of a round trip per second.
const DOT_SPEED := 0.07
const DOT_TRAIL_N := 7
const DOT_MAX := 12           # most ships drawn on one lane
const DOT_SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform vec3 p0;
uniform vec3 pc;
uniform vec3 p2;
uniform float lut[17];
uniform float clock = 0.0;
uniform float speed = 0.07;
uniform float waiting = 0.0;
uniform float fade = 1.0;          // T219: follows the lane's draw-in and removal fade
uniform vec4 col_out : source_color = vec4(0.92, 0.906, 0.875, 1.0);
uniform vec4 col_back : source_color = vec4(0.631, 0.62, 0.592, 1.0);
uniform vec4 col_wait : source_color = vec4(0.886, 0.753, 0.369, 1.0);
varying vec4 vcol;
varying vec2 corner;
void vertex() {
	float j = COLOR.r;
	float c = fract(clock * speed + COLOR.g);
	bool back = c > 0.5;
	float u = back ? 2.0 - c * 2.0 : c * 2.0;
	u = 0.04 + u * 0.92;
	if (waiting > 0.5) {
		u = 0.9;
	}
	float uu = clamp(u + (waiting > 0.5 ? 0.0 : (back ? 1.0 : -1.0) * j * 0.012), 0.0, 1.0);
	float x = uu * 16.0;
	float fi = min(floor(x), 15.0);
	int i = int(fi);
	float t = mix(lut[i], lut[i + 1], x - fi);
	vec3 pm = (1.0 - t) * (1.0 - t) * p0 + 2.0 * (1.0 - t) * t * pc + t * t * p2;
	float r = j < 0.5 ? 2.6 : 2.0 - j * 0.2;
	float a = 1.0;
	vec3 colr = col_out.rgb;
	if (j < 0.5) {
		colr = waiting > 0.5 ? col_wait.rgb : (back ? col_back.rgb : col_out.rgb);
	} else {
		a = waiting > 0.5 ? 0.0 : max((back ? 0.25 : 0.45) - j * 0.05, 0.0);
	}
	vcol = vec4(colr, a);
	corner = UV;
	vec3 vp = (MODELVIEW_MATRIX * vec4(pm, 1.0)).xyz;
	float wpp = 2.0 * max(-vp.z, 0.01) / (PROJECTION_MATRIX[1][1] * 941.0);
	vp.xy += UV * r * wpp;
	POSITION = PROJECTION_MATRIX * vec4(vp, 1.0);
}
void fragment() {
	float d = length(corner);
	ALBEDO = vcol.rgb;
	ALPHA = vcol.a * (1.0 - smoothstep(0.7, 1.0, d)) * fade;
}
"""

static var _dot_shader: Shader
static var _shader: Shader

var route_id: int = -1
var pair_a: int = -1
var pair_b: int = -1
var half: bool = false
var lane_slot: float = 0.0   # lane position in steps (0 = alone or middle)
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
var _chev_t := Vector3.RIGHT
var _chev_s := Vector3.BACK
var _clock: float = 0.0
var _draw_t := -1.0     # T219: seconds into the draw-in, -1 idle
var _fade_t := -1.0     # seconds into the removal fade, -1 idle
var _pulse_t := -1.0    # seconds into the dispatch pulse, -1 idle
var _ships_seen := -1   # ships on the lane at the last set_style (-1: not styled by the map yet)
var _game: Node         # the game screen (has _progress), found once

## ---- T219 pure curves (the headless test calls these) ----

## Draw-in progress at t in 0..1: ease out cubic, 0 at the start and exactly 1 at the end.
static func draw_curve(t: float) -> float:
	return 1.0 - pow(1.0 - clampf(t, 0.0, 1.0), 3.0)

## Dispatch band: x = centre along the lane (starts before the source, ends past the destination), y = gain
## (0 at both ends, 1 at the middle).
static func pulse_curve(t: float) -> Vector2:
	var u := clampf(t, 0.0, 1.0)
	return Vector2(lerpf(-PULSE_WIDTH, 1.0 + PULSE_WIDTH, 1.0 - pow(1.0 - u, 2.0)), sin(u * PI))

func setup(id: int, a: int, b: int, pos_a: Vector3, pos_b: Vector3, planet_radius: float, is_half: bool = false, suns: Array = [], lane: float = 0.0) -> void:
	half = is_half
	lane_slot = lane
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
	var sw = RouteOffset.sun_waypoint(pos_a, pos_b, suns)  # a sun in the way: the curve passes through the waypoint round it
	if sw != null:
		var wt: float = clampf(p0.distance_to(sw) / maxf(p0.distance_to(sw) + sw.distance_to(p2), 0.001), 0.15, 0.85)
		_c = (sw - p0 * ((1.0 - wt) * (1.0 - wt)) - p2 * (wt * wt)) / (2.0 * (1.0 - wt) * wt)
	if lane != 0.0:  # T163: routes sharing a pair or corridor sit side by side, each shifted to its own lane (left of travel)
		var sh := left * lane * LANE_STEP * planet_radius
		p0 += sh
		p2 += sh
		_c += sh
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
	# chevron at the middle: the design's path "M-4 -4 L2 0 L-4 4" (px, stroke 1.5), rotated to the line
	var mid := _at(total * 0.5)
	tag_pos = mid[0]
	var tan: Vector3 = mid[1]
	var sd := tan.cross(Vector3.UP).normalized()
	_chev_t = tan
	_chev_s = sd
	var tip := Vector2(2, 0)
	for tail in [Vector2(-4, -4), Vector2(-4, 4)]:
		_add_chev_arm(am, mid[0], tail, tip)
	mats.clear()
	for si in am.get_surface_count():
		var m := ShaderMaterial.new()
		m.shader = _shader
		m.set_shader_parameter("half_px", LINE_PX * 0.5)
		m.set_shader_parameter("dash_px", DASH_PX)
		if si > 0:
			m.set_shader_parameter("chev", 1.0)
			m.set_shader_parameter("chev_t", _chev_t)
			m.set_shader_parameter("chev_s", _chev_s)
		am.surface_set_material(si, m)
		mats.append(m)
	mesh = am
	samples = PackedVector3Array()
	for i in SAMPLES + 1:
		samples.append(_bez(float(i) / float(SAMPLES)))
	_setup_dots(total)
	set_style("running", 1)
	_ships_seen = -1  # the first style from the map sets the count without a pulse

var tag: Label3D            # the route tag at the middle of the arc (position and text carrier, drawn transparent)
var tag2d: Label            # T163: the visible 2D twin, placed by map.gd on the layer above the edge blur
var tag_pos := Vector3.ZERO

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
	var lut := PackedFloat32Array()
	for k in LUT_N + 1:
		var d := total * float(k) / float(LUT_N)
		var i := 1
		while i < _cum.size() - 1 and _cum[i] < d:
			i += 1
		var seg := maxf(_cum[i] - _cum[i - 1], 0.00001)
		lut.append((float(i - 1) + clampf((d - _cum[i - 1]) / seg, 0.0, 1.0)) / float(STEPS))
	_dot_mat.set_shader_parameter("lut", lut)
	_dot_mat.set_shader_parameter("speed", DOT_SPEED)
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
		for j in DOT_TRAIL_N:
			var k := (i * DOT_TRAIL_N + j) * 4
			for cy in [-1.0, 1.0]:
				for cx in [-1.0, 1.0]:
					verts.append(Vector3.ZERO)
					uvs.append(Vector2(cx, cy))
					cols.append(Color(float(j), ph, 0, 1))
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

## One chevron arm from local px offset `pa` to `pb` (x along the line, y to its side) around the point `at`.
func _add_chev_arm(am: ArrayMesh, at: Vector3, pa: Vector2, pb: Vector2) -> void:
	var d := pb - pa
	var t := (_chev_t * d.x + _chev_s * d.y).normalized()
	var verts := PackedVector3Array()
	var tans := PackedVector3Array()
	var uvs := PackedVector2Array()
	var cols := PackedColorArray()
	for p in [pa, pb]:
		for side in [-1.0, 1.0]:
			verts.append(at)
			tans.append(t)
			uvs.append(Vector2(0, side))
			cols.append(Color(0, p.x, p.y, 1))
	_commit(am, verts, tans, uvs, cols, PackedInt32Array([0, 1, 2, 1, 3, 2]))

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

## GDScript mirror of the shader's side vector (view space), so tests can check it never degenerates at any angle.
static func side_vector(t: Vector3, vp: Vector3) -> Vector3:
	var cr := t.cross(vp.normalized())
	if cr.length() > 0.02:
		return cr / cr.length()
	var alt := t.cross(Vector3.UP)
	if alt.length() < 0.001:
		return Vector3.RIGHT
	return alt / alt.length()

## Tint from route status: running = commodity colour, stalled (waiting) = dashed warn, blocked = solid red.
func set_style(status: String, ships: int, commodity: String = "", net: int = 0, reason: String = "", net_ok: bool = true, cost: int = 0) -> void:
	_set_tag(status, ships, net, reason, net_ok, cost)
	if _ships_seen >= 0 and ships > _ships_seen:
		pulse()  # T219: a ship was sent on this lane
	_ships_seen = ships
	var waiting := status != "running" and status != "blocked"
	if _dots != null:  # ship dots while running; a waiting lane keeps one parked warn-coloured ship
		var n := mini(ships, DOT_MAX) if (status == "running" or waiting) else 0
		if n != _dot_count:
			_build_dots(n)
		_dot_mat.set_shader_parameter("waiting", 1.0 if waiting else 0.0)
		_dot_mat.set_shader_parameter("col_wait", Ui.col("signal_warn"))
		_dot_mat.set_shader_parameter("col_out", Ui.col("ink"))
		_dot_mat.set_shader_parameter("col_back", Ui.col("ink_muted"))
	var col := Ui.commodity_col(commodity) if commodity != "" else Color(1, 1, 1)
	if status == "blocked":
		col = Ui.col("signal_bad")
	elif waiting:
		col = Ui.col("signal_warn")
	for si in mats.size():
		var c := col
		c.a = LINE_ALPHA if si == 0 else 1.0  # design: the line is at .5, the chevron at full strength
		mats[si].set_shader_parameter("modulate", c)
		mats[si].set_shader_parameter("dash", 1.0 if (si == 0 and waiting) else 0.0)

## Route tag text as in the design (SystemView route tag): "2 ships · +286", or the status when not running.
static func tag_text(status: String, ships: int, net: int, reason: String = "", net_ok: bool = true, cost: int = 0) -> String:
	if status == "blocked":
		return StoryText.get_or("LBL_ROUTE_BLOCKED", "Blocked")
	if status != "running":
		return reason_text(status, reason)
	var n := StoryText.get_or("LBL_ROUTE_SHIP_ONE", "{n} ship", {"n": ships}) if ships == 1 else StoryText.get_or("LBL_ROUTE_SHIP_MANY", "{n} ships", {"n": ships})
	if not net_ok:  # no projection for this lane: show its fixed running cost, marked as cost
		return "%s \u00b7 %s" % [n, StoryText.get_or("LBL_ROUTE_COST", "cost {n}", {"n": "\u2212%d" % cost})]
	var sg := "\u2212%d" % -net if net < 0 else ("+%d" % net if net > 0 else "0")
	return "%s \u00b7 %s" % [n, sg]

## Why a route that is not running is not moving: the route's own reason; "Waiting for room" only for the waiting state.
static func reason_text(status: String, reason: String) -> String:
	if reason == "Source storage is empty.":
		return StoryText.get_or("LBL_NO_STOCK_SOURCE", "No stock at source")
	if reason != "":
		return reason
	if status == "waiting":
		return StoryText.get_or("ST_WAITING_ROOM", "Waiting for room")
	return status.capitalize()

func _set_tag(status: String, ships: int, net: int, reason: String = "", net_ok: bool = true, cost: int = 0) -> void:
	if tag == null:
		tag = Label3D.new()
		tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		tag.no_depth_test = true
		tag.fixed_size = true
		# fixed_size: on-screen height = font_size * pixel_size * (P11 / 2) of the frame, P11 = 1 / tan(22.5 deg) at fov 45.
		# Design: 11 px mono in the 941 px frame -> 11 / 1135.9 = 0.00968 em; drawn at 4x font size for sharp glyphs.
		tag.pixel_size = 0.00022
		tag.font = Ui.mono_font()
		tag.font_size = 44
		tag.outline_size = 8
		tag.outline_modulate = Ui.col("panel_100")
		tag.position = tag_pos
		tag.render_priority = 2
		tag.outline_render_priority = 1
		tag.modulate.a = 0.0
		tag.outline_modulate.a = 0.0
		add_child(tag)
		tag2d = Label.new()
		tag2d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tag2d.add_theme_font_override("font", tag.font)
		tag2d.add_theme_color_override("font_outline_color", Ui.col("panel_100"))
	tag.text = tag_text(status, ships, net, reason, net_ok, cost)
	var ok := status == "running"
	var tint := Ui.col("ink")  # net result: green gain, red loss, plain at zero; a cost fallback stays plain
	if ok and net_ok:
		tint = Ui.col("signal_good") if net > 0 else (Ui.col("signal_bad") if net < 0 else tint)
	tint = tint if ok else (Ui.col("signal_bad") if status == "blocked" else Ui.col("signal_warn"))
	tag.modulate = Color(tint, 0.0)
	tag2d.text = tag.text
	tag2d.add_theme_color_override("font_color", tint)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and tag2d != null and is_instance_valid(tag2d):
		tag2d.free()

## T-ship-sync: dots follow the game's cycle clock (main._progress), so pause, fast forward and
## cycle end all match. One leg (half of the dot loop) takes travel_cycles_per_leg cycles.
func _process(delta: float) -> void:
	if _dot_mat == null:
		return
	var m = _game
	if m == null or not is_instance_valid(m):
		m = self
		while m != null and not m.has_method("_progress"):  # the game screen is an ancestor of the map
			m = m.get_parent()
		_game = m
	_tick_juice(delta, m)
	if m != null:
		_clock = float(m._progress())
		var legs := 1.0
		if "trade" in m and m.trade != null:
			legs = float(m.trade.travel_cycles())
		_dot_mat.set_shader_parameter("speed", 0.5 / maxf(legs, 0.01))
	_dot_mat.set_shader_parameter("clock", _clock)

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

## ---- T219 juice: draw-in, removal fade, dispatch pulse. Advance on game time; a paused game snaps to the end state. ----

func _motion() -> float:
	return Juice.motion

## A new lane grows from its source end.
func draw_in() -> void:
	if _motion() <= 0.0 or not is_inside_tree():
		return
	_draw_t = 0.0
	_apply_juice()

## One brightening band runs from the source to the destination.
func pulse() -> void:
	if _motion() <= 0.0 or not is_inside_tree() or _fade_t >= 0.0:
		return
	_pulse_t = 0.0
	_apply_juice()

## The lane fades, then frees itself (and its tag). Returns true when it took over the freeing.
func fade_out() -> bool:
	if _motion() <= 0.0 or not is_inside_tree() or _game_paused():
		return false
	if tag2d != null:
		tag2d.visible = false  # the map no longer places the tag of a leaving lane
	_draw_t = -1.0
	_pulse_t = -1.0
	_fade_t = 0.0
	_apply_juice()
	return true

func _game_paused() -> bool:
	return _game != null and is_instance_valid(_game) and "paused" in _game and bool(_game.paused)

func _tick_juice(delta: float, game: Node) -> void:
	if _draw_t < 0.0 and _pulse_t < 0.0 and _fade_t < 0.0:
		return
	var mo := _motion()
	if mo <= 0.0 or _game_paused():  # nothing animates while paused: end state
		if _fade_t >= 0.0:
			queue_free()
			return
		_draw_t = -1.0
		_pulse_t = -1.0
		_apply_juice()
		return
	var d := delta * (float(game.time_speed) if game != null and "time_speed" in game else 1.0)
	if _draw_t >= 0.0:
		_draw_t += d
		if _draw_t >= DRAW_SECONDS * mo:
			_draw_t = -1.0
	if _pulse_t >= 0.0:
		_pulse_t += d
		if _pulse_t >= PULSE_SECONDS * mo:
			_pulse_t = -1.0
	if _fade_t >= 0.0:
		_fade_t += d
		if _fade_t >= FADE_SECONDS * mo:
			queue_free()
			return
	_apply_juice()

## Pushes the current juice state into the shader (called only while something animates, and once at the end).
func _apply_juice() -> void:
	var mo := _motion()
	var draw := 1.0 if _draw_t < 0.0 else draw_curve(_draw_t / (DRAW_SECONDS * mo))
	var fade := 1.0
	if _fade_t >= 0.0:
		var f := clampf(_fade_t / (FADE_SECONDS * mo), 0.0, 1.0)
		fade = 1.0 - f * f  # ease in
	var pc := Vector2(-9.0, 0.0)
	if _pulse_t >= 0.0:
		pc = pulse_curve(_pulse_t / (PULSE_SECONDS * mo))
	for m in mats:
		m.set_shader_parameter("draw", draw)
		m.set_shader_parameter("fade", fade)
		m.set_shader_parameter("pulse_at", pc.x)
		m.set_shader_parameter("pulse_gain", pc.y)
		m.set_shader_parameter("pulse_w", PULSE_WIDTH)
		m.set_shader_parameter("draw_w0", DRAW_WIDTH_FROM)
		m.set_shader_parameter("draw_soft", DRAW_SOFT)
		m.set_shader_parameter("pulse_boost", PULSE_BOOST)
		m.set_shader_parameter("pulse_white", PULSE_WHITE)
	if _dot_mat != null:
		_dot_mat.set_shader_parameter("fade", minf(draw, fade))
