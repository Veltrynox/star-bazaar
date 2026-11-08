// T277: shared motion for the traffic ships. Everything a ship needs comes from the instance (no per-frame CPU work):
//   INSTANCE_CUSTOM = (phase 0..1, palette index of the cargo tint, state 0 running / 1 stalled / 2 blocked, seed 0..1)
//   MODEL_MATRIX columns carry the group data (the MultiMesh buffer is written in game/traffic/traffic_layer.gd):
//     mode 0 path : c0 = p0, c1 = pc, c2 = p2 (quadratic Bezier), c3.x = scale multiplier, c3.y = speed multiplier
//     mode 3 ambient: as mode 0 (T303: between-planets flow, own MultiMesh, dimmer, shorter streak)
//     mode 1 orbit: c0 = centre, c1 = (radius in, radius out, revolutions per clock unit), c2 = (tilt rad, scale mult, 0)
//     mode 2 free : c3 = position, c0 = unit forward, c1.x = scale multiplier (CPU steps these with ShipMotion)
// Mesh forward is -Z (same as the ship models), so the heading yaw convention of ShipMotion applies.
global uniform float traffic_clock;       // game progress (cycles), the same clock as the lane dots
global uniform float traffic_fade;        // 1 close, 0 far (the dot shader stays the far view)
global uniform float traffic_leg_speed;   // path: loops per clock unit (0.5 / cycles per leg), as the dot shader
uniform int mode = 0;
uniform float ship_len = 0.0;             // world units, from balance (traffic_ship_length x traffic_ship_scale)
uniform float streak_len = 0.0;           // streak length in ship lengths
uniform float glow = 0.0;                 // HDR multiplier of lights and engines (above 1.0 feeds the glow)
uniform float blink_hz = 0.0;
uniform float amb_gain = 1.0;             // T303: brightness multiplier of ambient (mode 3) ships
uniform float lane_spread = 0.0;          // T304: sideways spread per ship, fraction of the lane length (+- this), modes 0 and 3
uniform float amb_streak = 1.0;           // T303: streak length multiplier of ambient ships
uniform vec4 col_warm : source_color = vec4(1.0, 0.72, 0.35, 1.0);   // laden, running lights
uniform vec4 col_dim : source_color = vec4(0.45, 0.5, 0.6, 1.0);     // empty, going back
uniform vec4 col_warn : source_color = vec4(0.886, 0.753, 0.369, 1.0);
uniform vec4 col_bad : source_color = vec4(0.9, 0.25, 0.2, 1.0);
uniform vec4 palette[16];                 // cargo tints, index 0 = plain

// World position, heading, scale, state and laden flag of one instance.
void traffic_place(mat4 M, vec4 cu, out vec3 pos, out vec3 fwd, out float sc, out float st, out float laden) {
	st = cu.z;
	laden = 1.0;
	sc = ship_len;
	if (mode == 0 || mode == 3) {
		float c = fract(traffic_clock * traffic_leg_speed * M[3].y + cu.x);
		bool back = c > 0.5;
		float u = back ? 2.0 - c * 2.0 : c * 2.0;
		u = 0.04 + u * 0.92;
		if (st > 0.5) {  // stalled or blocked: parked near the source
			u = 0.04 + cu.w * 0.06;
			back = false;
		}
		laden = back ? 0.0 : 1.0;
		float w = 1.0 - u;
		pos = w * w * M[0].xyz + 2.0 * w * u * M[1].xyz + u * u * M[2].xyz;
		// T304: fixed per-ship offset in the map plane, perpendicular to the lane, zero at both planets
		vec3 lane = M[2].xyz - M[0].xyz;
		vec3 side = normalize(vec3(-lane.z, 0.0, lane.x) + vec3(0.0, 0.0, 0.00001));
		float ends = sin(3.14159265 * clamp((u - 0.04) / 0.92, 0.0, 1.0));
		pos += side * ((cu.w * 2.0 - 1.0) * lane_spread * length(lane) * ends);
		vec3 d = 2.0 * w * (M[1].xyz - M[0].xyz) + 2.0 * u * (M[2].xyz - M[1].xyz);
		fwd = normalize(back ? -d : d);
		sc *= M[3].x;
	} else if (mode == 1) {
		float a = 6.2831853 * (cu.x + traffic_clock * M[1].z);
		float r = mix(M[1].x, M[1].y, cu.w);
		float tl = M[2].x;
		vec3 o = vec3(cos(a), 0.0, sin(a));
		vec3 tg = vec3(-sin(a), 0.0, cos(a)) * (M[1].z < 0.0 ? -1.0 : 1.0);
		o = vec3(o.x, o.z * sin(tl), o.z * cos(tl));      // tilt the ring about X
		tg = vec3(tg.x, tg.z * sin(tl), tg.z * cos(tl));
		pos = M[0].xyz + o * r;
		fwd = normalize(tg);
		sc *= M[2].y;
	} else {
		pos = M[3].xyz;
		fwd = normalize(M[0].xyz);
		sc *= M[1].x;
	}
}

// Ship frame: columns x, y, z with z = -fwd (mesh forward is -Z), y close to world up.
mat3 traffic_frame(vec3 fwd) {
	vec3 z = -fwd;
	vec3 x = cross(vec3(0.0, 1.0, 0.0), z);
	x = length(x) < 0.001 ? vec3(1.0, 0.0, 0.0) : normalize(x);
	return mat3(x, cross(z, x), z);
}
