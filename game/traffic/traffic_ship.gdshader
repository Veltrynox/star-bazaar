// T277: traffic ship hull (surface 0 of the proxy meshes). One draw call per MultiMesh. Motion: traffic_motion.gdshaderinc.
// Cheap fake light (one sun direction, shared with the map's key light), unshaded; lights and engines are HDR for the glow pass.
shader_type spatial;
render_mode unshaded, depth_draw_always, cull_back;
#include "res://game/traffic/traffic_motion.gdshaderinc"
uniform vec3 sun_dir = vec3(0.5, 0.7, 0.3);   // world direction towards the light
varying vec3 v_col;
void vertex() {
	vec3 pos;
	vec3 fwd;
	float sc;
	float st;
	float laden;
	traffic_place(MODEL_MATRIX, INSTANCE_CUSTOM, pos, fwd, sc, st, laden);
	mat3 B = traffic_frame(fwd);
	vec3 wp = pos + B * (VERTEX * sc);
	float lam = 0.3 + 0.7 * max(dot(B * NORMAL, normalize(sun_dir)), 0.0);
	vec3 col = COLOR.rgb * lam;
	float part = UV.x;  // 0 hull, 1 cargo pod, 2 engine, 4 nav light
	if (part > 0.5 && part < 1.5) {
		col = palette[int(INSTANCE_CUSTOM.y)].rgb * lam;
	} else if (part > 1.5 && part < 2.5) {
		col = col_warm.rgb * glow * (st < 0.5 ? 1.0 : 0.15);
	} else if (part > 3.5) {
		float on = step(0.5, fract(TIME * blink_hz + INSTANCE_CUSTOM.w));
		if (st < 0.5) {
			col = (laden > 0.5 ? col_warm.rgb : col_dim.rgb * 0.5) * glow;
		} else {
			col = (st < 1.5 ? col_warn.rgb : col_bad.rgb) * glow * on;
		}
	}
	v_col = mode == 3 ? col * amb_gain : col;
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(wp, 1.0);
	if (traffic_fade <= 0.001) {
		POSITION = vec4(2.0, 2.0, 2.0, 1.0);  // off: outside the clip volume
	}
}
void fragment() {
	ALBEDO = v_col;
	ALPHA = traffic_fade;
}
