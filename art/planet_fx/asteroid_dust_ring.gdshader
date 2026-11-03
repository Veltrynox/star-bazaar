shader_type spatial;
// Asteroid dust ring: every grain is one camera-facing quad of a single MultiMesh (one draw call).
// All motion is here in the vertex stage, so the CPU does nothing per frame. Visual only.
// INSTANCE_CUSTOM per grain: x = orbit radius, y = start angle (rad), z = random 0..1, w = radius of its band's middle.
// Speed depends on the band, not the grain's own radius, so the gaps in a band keep their shape while it turns.
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

uniform float ref_radius = 4.0;       // radius that turns at orbit_speed
uniform float orbit_speed : hint_range(0.0, 1.0) = 0.002;  // rad/s at the middle radius
uniform float height = 0.12;          // total vertical spread (world units)
uniform float grain_min = 0.0072;      // grain size range (world units)
uniform float grain_max = 0.018;
uniform float alpha : hint_range(0.0, 1.0) = 0.35;
uniform vec4 tint : source_color = vec4(0.75, 0.68, 0.6, 1.0);

varying float v_fade;

void vertex() {
	vec4 cd = INSTANCE_CUSTOM;
	float r = cd.x;
	// Kepler-ish: inner bands go round faster; a little per-grain speed variation (3%).
	float w = orbit_speed * (0.97 + 0.06 * cd.z) * pow(ref_radius / cd.w, 1.5);
	float a = cd.y + TIME * w;
	float h = fract(cd.z * 57.3) - 0.5;                    // stable per-grain height
	float y = h * height + sin(TIME * 0.3 + cd.y * 3.0) * height * 0.1;
	vec3 world = (MODEL_MATRIX * vec4(cos(a) * r, y, sin(a) * r, 1.0)).xyz;
	vec4 vc = VIEW_MATRIX * vec4(world, 1.0);
	float size = mix(grain_min, grain_max, cd.z * cd.z);  // mostly small, a few bigger
	vc.xy += VERTEX.xy * size;                             // quad is 1x1, billboarded in view space
	POSITION = PROJECTION_MATRIX * vc;
	// Slow per-grain twinkle (the bands thin toward their edges through the grain placement).
	v_fade = 0.7 + 0.3 * sin(TIME * (0.5 + cd.z) + cd.y * 7.0);
}

void fragment() {
	float d = length(UV * 2.0 - 1.0);
	ALBEDO = tint.rgb;
	ALPHA = alpha * v_fade * smoothstep(1.0, 0.2, d);
}
