extends MultiMeshInstance3D
## T05 (basic): decorative 3D star field. One MultiMesh = one draw call, no per-star nodes.
## Visual only: no collision, no input, no lights, no gameplay state. Static after _ready();
## all motion comes from the camera moving in the 3D scene (parallax).
## Later work (not done): density grid bake, sun light propagation, per-star light attribute.

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
const MASTER_INTENSITY := 0.9   # global brightness multiplier
const TINT_COOL := Color(0.65, 0.78, 1.0)
const TINT_WHITE := Color(1.0, 1.0, 1.0)
const TINT_WARM := Color(1.0, 0.82, 0.62)
const TINT_WARM_CHANCE := 0.25
const TINT_COOL_CHANCE := 0.25

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
	for i in STAR_COUNT:
		var u := pow(rng.randf(), RADIAL_POWER)
		var r := MAX_RADIUS * u
		var ang := rng.randf() * TAU
		if rng.randf() < ARM_FRACTION:
			var arm := rng.randi() % ARM_COUNT
			ang = TAU * float(arm) / float(ARM_COUNT) + ARM_TWIST * u + rng.randfn(0.0, ARM_SPREAD)
		var y := rng.randfn(0.0, maxf(THICKNESS * r, THICKNESS_MIN))
		mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3(cos(ang) * r, y, sin(ang) * r)))

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
		mm.set_instance_color(i, Color(tint.r * b, tint.g * b, tint.b * b, s))
	multimesh = mm

	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	extra_cull_margin = MAX_RADIUS * 2.0  # quads are scaled in the shader; keep the AABB from culling them
	custom_aabb = AABB(Vector3.ONE * -MAX_RADIUS, Vector3.ONE * MAX_RADIUS * 2.0)
