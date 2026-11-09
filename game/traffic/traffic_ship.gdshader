// T310: traffic ship hull (surface 0 of the ship mesh): a flat double-sided hull (T318: five kinds, one per ship) with a per-ship colour and a faint grain.
// One draw call per MultiMesh. Motion: traffic_motion.gdshaderinc. Unshaded; the engine glow is HDR for the glow pass.
shader_type spatial;
render_mode unshaded, depth_draw_always, cull_disabled;
#include "res://game/traffic/traffic_motion.gdshaderinc"
uniform float grain = 0.22;           // strength of the noise grain (0 = flat fill)
uniform float grain_scale = 14.0;     // grain cells across the triangle
uniform float empty_gain = 0.6;       // brightness of a ship on its way back (empty)
uniform float hull_dark = 1.0;        // T318: hull colour multiplier (balance traffic_hull_dark; 1 = the old bright hulls)
uniform float cargo_mix = 0.3;        // share of the cargo tint mixed into the ship colour (path ships with cargo)
// Ship colours: a spread of hues that sit well on dark space; picked from the ship seed, so stable per ship.
const vec3 SHIP_COL[8] = vec3[8](
	vec3(0.95, 0.62, 0.35), vec3(0.95, 0.85, 0.40), vec3(0.55, 0.88, 0.50), vec3(0.40, 0.85, 0.80),
	vec3(0.45, 0.68, 0.98), vec3(0.72, 0.60, 0.98), vec3(0.95, 0.55, 0.78), vec3(0.88, 0.90, 0.95));
// T318: hull kinds live in one mesh (UV2.x = kind); a ship wears one kind picked from its seed, the rest collapse. Same table as traffic_meshes.gd KIND_TABLE.
const int KIND_TABLE[8] = int[8](0, 0, 1, 2, 3, 4, 0, 2);
varying vec3 v_col;
varying vec2 v_uv;
varying float v_seed;
varying float v_part;
void vertex() {
	vec3 pos;
	vec3 fwd;
	float sc;
	float st;
	float laden;
	traffic_place(MODEL_MATRIX, INSTANCE_CUSTOM, pos, fwd, sc, st, laden);
	mat3 B = traffic_frame(fwd);
	vec3 wp = pos + B * (VERTEX * sc);
	float seed = INSTANCE_CUSTOM.w;
	vec3 col = SHIP_COL[int(floor(traffic_draw(seed, 7.0) * 7.999))] * hull_dark;
	int kind = KIND_TABLE[int(floor(traffic_draw(seed, 11.0) * 7.999))];
	int pi = int(INSTANCE_CUSTOM.y);
	if (pi > 0) {
		vec3 tint = palette[pi].rgb;
		// free ships (convoys, raiders) wear their tint fully; lane ships only a share of the cargo tint
		col = mix(col, tint * mix(1.0, hull_dark, 0.5), mode == 2 ? 0.85 : cargo_mix);
	}
	col *= (st < 0.5 && laden < 0.5) ? empty_gain : 1.0;
	if (st > 0.5) {
		col *= 0.8;  // parked: a little dimmer
	}
	if (UV.x > 1.5) {
		col = col_warm.rgb * glow * (st < 0.5 ? 1.0 : 0.15);
	}
	v_part = UV.x;
	v_col = mode == 3 ? col * amb_gain : col;
	v_uv = VERTEX.xz + vec2(0.5);
	v_seed = seed;
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(wp, 1.0);
	if (traffic_fade <= 0.001 || int(UV2.x + 0.5) != kind) {
		POSITION = vec4(2.0, 2.0, 2.0, 1.0);  // off: outside the clip volume
	}
}
float grain_hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
void fragment() {
	vec3 c = v_col;
	if (v_part < 1.5) {
		// value noise on the hull, offset by the ship seed so no two ships share a grain pattern
		vec2 q = v_uv * grain_scale + vec2(v_seed * 91.0, v_seed * 37.0);
		vec2 f = fract(q);
		vec2 i0 = floor(q);
		f = f * f * (3.0 - 2.0 * f);
		float n = mix(mix(grain_hash(i0), grain_hash(i0 + vec2(1.0, 0.0)), f.x), mix(grain_hash(i0 + vec2(0.0, 1.0)), grain_hash(i0 + vec2(1.0, 1.0)), f.x), f.y);
		c *= 1.0 - grain + grain * 2.0 * n;
	}
	ALBEDO = c;
	ALPHA = traffic_fade;
}
