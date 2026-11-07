// T277: short additive engine streak (surface 1 of the proxy meshes), instead of ribbon trails. Two crossed quads per engine,
// stretched in the vertex shader. Fades along its length, off while parked, shorter and dimmer on the way back.
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;
#include "res://game/traffic/traffic_motion.gdshaderinc"
varying float v_k;
void vertex() {
	vec3 pos;
	vec3 fwd;
	float sc;
	float st;
	float laden;
	traffic_place(MODEL_MATRIX, INSTANCE_CUSTOM, pos, fwd, sc, st, laden);
	mat3 B = traffic_frame(fwd);
	vec3 v = VERTEX;
	v.z += UV.y * (streak_len * (mode == 3 ? amb_streak : 1.0) * (laden > 0.5 ? 1.0 : 0.5) - 1.0);  // mesh streak is one ship length, UV.y 0 at the engine to 1 at the tail
	vec3 wp = pos + B * (v * sc);
	float k = pow(1.0 - UV.y, 2.0) * (st < 0.5 ? 1.0 : 0.0) * (laden > 0.5 ? 1.0 : 0.4);
	v_k = mode == 3 ? k * amb_gain : k;
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(wp, 1.0);
	if (traffic_fade <= 0.001 || streak_len <= 0.0) {
		POSITION = vec4(2.0, 2.0, 2.0, 1.0);
	}
}
void fragment() {
	ALBEDO = col_warm.rgb * glow * v_k;
	ALPHA = traffic_fade;
}
