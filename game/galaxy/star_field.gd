extends MultiMeshInstance3D
## T05 (basic): decorative 3D star field. One MultiMesh = one draw call, no per-star nodes.
## Visual only: no collision, no input, no lights, no gameplay state. Static after _ready();
## all motion comes from the camera moving in the 3D scene (parallax).
## Bake (once, in _ready): points -> low-res density grid -> sun points -> light marched through the grid -> per-star light attribute
## (multiplies the star colour). Deterministic from SEED. Dust = point density.

# --- Tuning (all constants; the shader gets them as uniforms) ---
const STAR_COUNT := 3000
const SEED := 20261025
const MAX_RADIUS := 220.0       # stars fill the whole disc from the centre (r = 0) out to this
const RADIAL_POWER := 0.6       # r = MAX_RADIUS * rand^power. 0.5 = even per area, lower = emptier core, higher = denser core
const THICKNESS := 0.06         # disc half-thickness (gaussian sigma) as a fraction of the star's radius
const THICKNESS_MIN := 4.0      # floor on that sigma in world units, so the centre is a lens, not a flat sheet
const ARM_COUNT := 2
const ARM_TWIST := 2.5          # radians of spiral winding from the centre to MAX_RADIUS
const ARM_SPREAD := 0.5         # angular spread of an arm in radians (sigma)
const ARM_FRACTION := 0.6       # share of stars placed on arms; the rest are a uniform disc
const BRIGHTNESS_MIN := 0.08
const BRIGHTNESS_MAX := 1.0
const BRIGHTNESS_POWER := 5.0   # higher = more dim stars, fewer bright ones
const SIZE_MIN := 0.7           # per-star size multiplier
const SIZE_MAX := 1.8
const STAR_ANGULAR_SIZE := 0.0035  # quad size per unit of camera distance (about 2.5 px at 1080p, FOV 45)
const FADE_NEAR := 50.0         # camera distance where fading starts (world units)
const FADE_FAR := 260.0         # camera distance where a star is fully dark
const FADE_POWER := 1.5
const NEAR_CLEAR := 1.5         # camera distance where a star is fully hidden (avoids stars in the lens)
const NEAR_FULL := 8.0          # camera distance where a star reaches full brightness
const PLANET_AREA_RADIUS := 25.0 # stars inside this radius get the brightness cap below
const NEAR_MAX_BRIGHT := 0.6    # brightness cap for stars inside the planet area, keeps planets/labels the focus
const MASTER_INTENSITY := 1.1   # global brightness multiplier
const TINT_COOL := Color(0.65, 0.78, 1.0)
const TINT_WHITE := Color(1.0, 1.0, 1.0)
const TINT_WARM := Color(1.0, 0.82, 0.62)
const TINT_WARM_CHANCE := 0.25
const TINT_COOL_CHANCE := 0.25

# --- Bake tuning ---
const GRID_XZ := 32             # density grid cells across the disc diameter
const GRID_Y := 8               # density grid cells across the height
const GRID_HALF_HEIGHT := 30.0  # grid covers y in [-this, +this]
const SUN_COUNT := 24
const SUN_INTENSITY := 1.0
const LIGHT_FALLOFF := 40.0     # distance where a sun's light has dropped to a quarter (inverse square, softened)
const DUST_ABSORPTION := 0.06    # optical depth per unit of normalised cell density per world unit
const MARCH_STEPS := 12         # samples along each sun-to-star ray
const LIGHT_GAIN := 6.0         # scales summed light before the clamp
const LIGHT_MIN := 0.12         # brightness floor for a star no sun reaches (hidden in dust)
const LIGHT_MAX := 1.0
const DENSITY_NORM_PERCENTILE := 0.97  # density at this rank maps to 1.0

# --- Halo (soft glow on the brightest few stars; same fade as the points, one extra draw call) ---
const HALO_COUNT := 40          # how many of the brightest (post-dust) stars get a halo
const HALO_SIZE := 4.5          # halo quad size as a multiple of the star's point size
const HALO_INTENSITY := 0.35    # halo peak brightness (below the map glow threshold of 1.0, so it never double-blooms)
const HALO_FALLOFF := 3.0       # higher = tighter, softer core-to-edge falloff

# --- Spikes (four-arm cross flare on a seeded ~10% of stars) ---
const SPIKE_CHANCE := 0.10      # share of stars that get spikes
const SPIKE_SEED_OFFSET := 7919 # separate RNG (SEED + this) so star positions/colours and the bake are unchanged
const SPIKE_SIZE := 8.0         # spike quad size as a multiple of the star's point size
const SPIKE_INTENSITY := 0.9
const SPIKE_LENGTH_FALLOFF := 2.0  # along-arm fade (higher = shorter arms)
const SPIKE_WIDTH := 28.0       # across-arm sharpness (higher = thinner arms)
const SPIKE_COLOR_BLUE := Color(0.6, 0.75, 1.0)  # each spiked star gets a colour between this and white
const SPIKE_COLOR_WHITE := Color(1.0, 1.0, 1.0)

const SPIKE_SHADER_CODE := """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled;
uniform float angular_size;
uniform float fade_near;
uniform float fade_far;
uniform float fade_power;
uniform float near_clear;
uniform float near_full;
uniform float spike_size;
uniform float spike_intensity;
uniform float spike_length_falloff;
uniform float spike_width;
varying float fade;
void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	float dist = length(MODEL_MATRIX[3].xyz - CAMERA_POSITION_WORLD);
	VERTEX.xy *= angular_size * dist * COLOR.a * spike_size;
	fade = pow(1.0 - smoothstep(fade_near, fade_far, dist), fade_power) * smoothstep(near_clear, near_full, dist);
}
void fragment() {
	vec2 p = (UV - vec2(0.5)) * 2.0;
	vec2 a = abs(p);
	float edge = clamp(1.0 - max(a.x, a.y), 0.0, 1.0);
	float arm_x = exp(-a.y * spike_width) * pow(clamp(1.0 - a.x, 0.0, 1.0), spike_length_falloff);
	float arm_y = exp(-a.x * spike_width) * pow(clamp(1.0 - a.y, 0.0, 1.0), spike_length_falloff);
	float g = max(arm_x, arm_y) * smoothstep(0.0, 0.1, edge);
	ALBEDO = COLOR.rgb * g * fade * spike_intensity;
}
"""

const HALO_SHADER_CODE := """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled;
uniform float angular_size;
uniform float fade_near;
uniform float fade_far;
uniform float fade_power;
uniform float near_clear;
uniform float near_full;
uniform float halo_size;
uniform float halo_intensity;
uniform float halo_falloff;
varying float fade;
void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	float dist = length(MODEL_MATRIX[3].xyz - CAMERA_POSITION_WORLD);
	VERTEX.xy *= angular_size * dist * COLOR.a * halo_size;
	fade = pow(1.0 - smoothstep(fade_near, fade_far, dist), fade_power) * smoothstep(near_clear, near_full, dist);
}
void fragment() {
	float d = clamp(length(UV - vec2(0.5)) * 2.0, 0.0, 1.0);
	float g = pow(1.0 - d, halo_falloff) * (1.0 - d);
	ALBEDO = COLOR.rgb * g * fade * halo_intensity;
}
"""

const SHADER_CODE := """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled;
uniform float angular_size;
uniform float fade_near;
uniform float fade_far;
uniform float fade_power;
uniform float near_clear;
uniform float near_full;
uniform float intensity;
varying float fade;
void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	float dist = length(MODEL_MATRIX[3].xyz - CAMERA_POSITION_WORLD);
	VERTEX.xy *= angular_size * dist * COLOR.a;
	fade = pow(1.0 - smoothstep(fade_near, fade_far, dist), fade_power) * smoothstep(near_clear, near_full, dist);
}
void fragment() {
	float d = length(UV - vec2(0.5)) * 2.0;
	float dot_a = pow(clamp(1.0 - d, 0.0, 1.0), 1.5);
	ALBEDO = COLOR.rgb * dot_a * fade * intensity;
}
"""

func _ready() -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	var mat := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = SHADER_CODE
	mat.shader = sh
	mat.set_shader_parameter("angular_size", STAR_ANGULAR_SIZE)
	mat.set_shader_parameter("fade_near", FADE_NEAR)
	mat.set_shader_parameter("fade_far", FADE_FAR)
	mat.set_shader_parameter("fade_power", FADE_POWER)
	mat.set_shader_parameter("near_clear", NEAR_CLEAR)
	mat.set_shader_parameter("near_full", NEAR_FULL)
	mat.set_shader_parameter("intensity", MASTER_INTENSITY)
	quad.material = mat

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = quad
	mm.instance_count = STAR_COUNT

	var rng := RandomNumberGenerator.new()
	rng.seed = SEED
	var pos := PackedVector3Array()
	pos.resize(STAR_COUNT)
	var cols := PackedColorArray()
	cols.resize(STAR_COUNT)
	for i in STAR_COUNT:
		var u := pow(rng.randf(), RADIAL_POWER)
		var r := MAX_RADIUS * u
		var ang := rng.randf() * TAU
		if rng.randf() < ARM_FRACTION:
			var arm := rng.randi() % ARM_COUNT
			ang = TAU * float(arm) / float(ARM_COUNT) + ARM_TWIST * u + rng.randfn(0.0, ARM_SPREAD)
		var y := rng.randfn(0.0, maxf(THICKNESS * r, THICKNESS_MIN))
		pos[i] = Vector3(cos(ang) * r, y, sin(ang) * r)

		var b := lerpf(BRIGHTNESS_MIN, BRIGHTNESS_MAX, pow(rng.randf(), BRIGHTNESS_POWER))
		if r < PLANET_AREA_RADIUS:
			b = minf(b, NEAR_MAX_BRIGHT)
		var t := rng.randf()
		var tint := TINT_WHITE
		if t < TINT_WARM_CHANCE:
			tint = TINT_WHITE.lerp(TINT_WARM, rng.randf())
		elif t < TINT_WARM_CHANCE + TINT_COOL_CHANCE:
			tint = TINT_WHITE.lerp(TINT_COOL, rng.randf())
		var s := lerpf(SIZE_MIN, SIZE_MAX, b)  # brighter stars are a bit larger
		cols[i] = Color(tint.r * b, tint.g * b, tint.b * b, s)

	var t0 := Time.get_ticks_usec()
	var grid := _bake_density(pos)
	var suns := _pick_suns(pos, rng)
	var light := _propagate(pos, suns, grid)
	light_values = light
	bake_time_ms = (Time.get_ticks_usec() - t0) / 1000.0
	for i in STAR_COUNT:
		var c := cols[i]
		var l := lerpf(LIGHT_MIN, LIGHT_MAX, light[i])
		mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, pos[i]))
		mm.set_instance_color(i, Color(c.r * l, c.g * l, c.b * l, c.a))
	multimesh = mm
	_build_halos(pos, cols, light)
	_build_spikes(pos, cols, light)

	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	extra_cull_margin = MAX_RADIUS * 2.0  # quads are scaled in the shader; keep the AABB from culling them
	custom_aabb = AABB(Vector3.ONE * -MAX_RADIUS, Vector3.ONE * MAX_RADIUS * 2.0)

func _build_halos(pos: PackedVector3Array, cols: PackedColorArray, light: PackedFloat32Array) -> void:
	# Pick the brightest stars after dust (colour * light), so hidden stars never glow.
	var order: Array = []
	for i in STAR_COUNT:
		var c := cols[i]
		var l := lerpf(LIGHT_MIN, LIGHT_MAX, light[i])
		order.append([maxf(c.r, maxf(c.g, c.b)) * l, i])
	order.sort_custom(func(a, b): return a[0] > b[0])
	var n := mini(HALO_COUNT, STAR_COUNT)
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	var mat := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = HALO_SHADER_CODE
	mat.shader = sh
	mat.set_shader_parameter("angular_size", STAR_ANGULAR_SIZE)
	mat.set_shader_parameter("fade_near", FADE_NEAR)
	mat.set_shader_parameter("fade_far", FADE_FAR)
	mat.set_shader_parameter("fade_power", FADE_POWER)
	mat.set_shader_parameter("near_clear", NEAR_CLEAR)
	mat.set_shader_parameter("near_full", NEAR_FULL)
	mat.set_shader_parameter("halo_size", HALO_SIZE)
	mat.set_shader_parameter("halo_intensity", HALO_INTENSITY)
	mat.set_shader_parameter("halo_falloff", HALO_FALLOFF)
	quad.material = mat
	var hm := MultiMesh.new()
	hm.transform_format = MultiMesh.TRANSFORM_3D
	hm.use_colors = true
	hm.mesh = quad
	hm.instance_count = n
	for k in n:
		var i: int = order[k][1]
		var c := cols[i]
		var l := lerpf(LIGHT_MIN, LIGHT_MAX, light[i])
		hm.set_instance_transform(k, Transform3D(Basis.IDENTITY, pos[i]))
		hm.set_instance_color(k, Color(c.r * l, c.g * l, c.b * l, c.a))
	var h := MultiMeshInstance3D.new()
	h.multimesh = hm
	h.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	h.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	h.extra_cull_margin = MAX_RADIUS * 2.0
	h.custom_aabb = AABB(Vector3.ONE * -MAX_RADIUS, Vector3.ONE * MAX_RADIUS * 2.0)
	add_child(h)

func _build_spikes(pos: PackedVector3Array, cols: PackedColorArray, light: PackedFloat32Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = SEED + SPIKE_SEED_OFFSET
	var idx := PackedInt32Array()
	var tints := PackedColorArray()
	for i in STAR_COUNT:  # fixed draw count per star keeps the set stable
		var pick := rng.randf()
		var t := rng.randf()
		if pick < SPIKE_CHANCE:
			idx.append(i)
			tints.append(SPIKE_COLOR_BLUE.lerp(SPIKE_COLOR_WHITE, t))
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	var mat := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = SPIKE_SHADER_CODE
	mat.shader = sh
	mat.set_shader_parameter("angular_size", STAR_ANGULAR_SIZE)
	mat.set_shader_parameter("fade_near", FADE_NEAR)
	mat.set_shader_parameter("fade_far", FADE_FAR)
	mat.set_shader_parameter("fade_power", FADE_POWER)
	mat.set_shader_parameter("near_clear", NEAR_CLEAR)
	mat.set_shader_parameter("near_full", NEAR_FULL)
	mat.set_shader_parameter("spike_size", SPIKE_SIZE)
	mat.set_shader_parameter("spike_intensity", SPIKE_INTENSITY)
	mat.set_shader_parameter("spike_length_falloff", SPIKE_LENGTH_FALLOFF)
	mat.set_shader_parameter("spike_width", SPIKE_WIDTH)
	quad.material = mat
	var sm := MultiMesh.new()
	sm.transform_format = MultiMesh.TRANSFORM_3D
	sm.use_colors = true
	sm.mesh = quad
	sm.instance_count = idx.size()
	for k in idx.size():
		var i := idx[k]
		var c := cols[i]
		var b := maxf(c.r, maxf(c.g, c.b))  # star brightness (tint-independent) so the spike colour is the spiked star's own
		var l := lerpf(LIGHT_MIN, LIGHT_MAX, light[i])
		var tc := tints[k]
		sm.set_instance_transform(k, Transform3D(Basis.IDENTITY, pos[i]))
		sm.set_instance_color(k, Color(tc.r * b * l, tc.g * b * l, tc.b * b * l, c.a))
	var h := MultiMeshInstance3D.new()
	h.multimesh = sm
	h.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	h.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	h.extra_cull_margin = MAX_RADIUS * 2.0
	h.custom_aabb = AABB(Vector3.ONE * -MAX_RADIUS, Vector3.ONE * MAX_RADIUS * 2.0)
	add_child(h)

var bake_time_ms := 0.0
var light_values := PackedFloat32Array()  # per-star light 0..1 after the bake (for tools and tests)

func _cell(p: Vector3) -> int:
	var fx := clampf((p.x / MAX_RADIUS * 0.5 + 0.5) * GRID_XZ, 0.0, GRID_XZ - 0.001)
	var fz := clampf((p.z / MAX_RADIUS * 0.5 + 0.5) * GRID_XZ, 0.0, GRID_XZ - 0.001)
	var fy := clampf((p.y / GRID_HALF_HEIGHT * 0.5 + 0.5) * GRID_Y, 0.0, GRID_Y - 0.001)
	return (int(fy) * GRID_XZ + int(fz)) * GRID_XZ + int(fx)

func _bake_density(pos: PackedVector3Array) -> PackedFloat32Array:
	var g := PackedFloat32Array()
	g.resize(GRID_XZ * GRID_XZ * GRID_Y)
	for p in pos:
		g[_cell(p)] += 1.0
	var sorted := g.duplicate()
	sorted.sort()
	var ref := maxf(sorted[int(DENSITY_NORM_PERCENTILE * (sorted.size() - 1))], 1.0)
	for i in g.size():
		g[i] = minf(g[i] / ref, 2.0)
	return g

func _pick_suns(pos: PackedVector3Array, rng: RandomNumberGenerator) -> PackedVector3Array:
	var suns := PackedVector3Array()
	for i in SUN_COUNT:
		suns.append(pos[rng.randi() % pos.size()])
	return suns

func _propagate(pos: PackedVector3Array, suns: PackedVector3Array, grid: PackedFloat32Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(pos.size())
	var f2 := LIGHT_FALLOFF * LIGHT_FALLOFF
	for i in pos.size():
		var p := pos[i]
		var sum := 0.0
		for sun in suns:
			var d := p.distance_to(sun)
			var tau := 0.0
			var step := d / MARCH_STEPS
			for k in MARCH_STEPS:
				tau += grid[_cell(sun.lerp(p, (k + 0.5) / MARCH_STEPS))] * DUST_ABSORPTION * step
			sum += SUN_INTENSITY / (1.0 + d * d / f2) * exp(-tau)
		out[i] = clampf(sum * LIGHT_GAIN / SUN_COUNT * 4.0, 0.0, 1.0)
	return out
