// T277: shared motion for the traffic ships. Everything a ship needs comes from the instance (no per-frame CPU work):
//   INSTANCE_CUSTOM = (phase 0..1, palette index of the cargo tint, state 0 running / 1 stalled / 2 blocked, seed 0..1)
//   MODEL_MATRIX columns carry the group data (the MultiMesh buffer is written in game/traffic/traffic_layer.gd):
//     mode 0 path : c0 = p0, c1 = pc, c2 = p2 (quadratic Bezier), c3.x = scale multiplier, c3.y = speed multiplier
//     c3.z (modes 0, 3): packed q0 * 65536 + q1 * 256 + q2, q = round(radius / 8 * 255): planet radii at p0 / p2, and the radius the lane ends were offset by (0 = each end's own radius); 0 = no landing
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
uniform float size_jitter = 0.0;          // T307: per-ship size factor 1 +- this, modes 0 and 3 (seeded, fixed per ship)
uniform float speed_jitter = 0.0;         // T307: per-ship speed factor 1 +- this, modes 0 and 3 (own draw, not tied to the size draw)
uniform float land_fade = 0.0;            // T309: fraction of the lane over which a ship glides to / from its landing point (0 = off), modes 0 and 3
uniform float land_disc = 0.0;            // T309: landing points lie within this fraction of the planet radius from its centre
uniform float land_gap = 0.0;             // T309: lane end distance from the planet centre in planet radii (route_line GAP)
uniform float amb_streak = 1.0;           // T303: streak length multiplier of ambient ships
uniform vec4 col_warm : source_color = vec4(1.0, 0.72, 0.35, 1.0);   // laden, running lights
uniform vec4 col_dim : source_color = vec4(0.45, 0.5, 0.6, 1.0);     // empty, going back
uniform vec4 col_warn : source_color = vec4(0.886, 0.753, 0.369, 1.0);
uniform vec4 col_bad : source_color = vec4(0.9, 0.25, 0.2, 1.0);
uniform vec4 palette[16];                 // cargo tints, index 0 = plain

// T307: stable 0..1 draw from the ship seed; k picks an independent draw.
float traffic_draw(float seed, float k) {
	return fract(sin(seed * 12.9898 * k + k * 78.233) * 43758.5453);
}

// World position, heading, scale, state and laden flag of one instance.
void traffic_place(mat4 M, vec4 cu, out vec3 pos, out vec3 fwd, out float sc, out float st, out float laden) {
	st = cu.z;
	laden = 1.0;
	sc = ship_len;
	if (mode == 0 || mode == 3) {
		float c = fract(traffic_clock * traffic_leg_speed * M[3].y * (1.0 + speed_jitter * (traffic_draw(cu.w, 2.0) * 2.0 - 1.0)) + cu.x);
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
		float e = clamp((u - 0.04) / 0.92, 0.0, 1.0);
		float ends = sin(3.14159265 * e);
		pos += side * ((cu.w * 2.0 - 1.0) * lane_spread * length(lane) * ends);
		// T309: the lane ends glide to a seeded point on the visible planet disc (touch down / take off), shrinking into the surface
		float shrink = 1.0;
		float qp = M[3].z;
		if (land_fade > 0.0 && qp > 0.5 && st < 0.5) {
			float q0 = floor(qp / 65536.0);
			float q1 = floor((qp - q0 * 65536.0) / 256.0);
			float q2 = qp - q0 * 65536.0 - q1 * 256.0;
			vec3 ldir = normalize(lane + vec3(0.00001, 0.0, 0.0));
			float r0 = q0 / 255.0 * 8.0;
			float r1 = q1 / 255.0 * 8.0;
			float g0 = q2 > 0.5 ? q2 / 255.0 * 8.0 : r0;
			float g1 = q2 > 0.5 ? q2 / 255.0 * 8.0 : r1;
			vec3 c0 = M[0].xyz - ldir * g0 * land_gap;
			vec3 c1 = M[2].xyz + ldir * g1 * land_gap;
			float a0 = 6.2831853 * traffic_draw(cu.w, 3.0);
			float a1 = 6.2831853 * traffic_draw(cu.w, 5.0);
			vec2 o0 = vec2(cos(a0), sin(a0)) * sqrt(traffic_draw(cu.w, 4.0)) * land_disc * r0;
			vec2 o1 = vec2(cos(a1), sin(a1)) * sqrt(traffic_draw(cu.w, 6.0)) * land_disc * r1;
			vec3 l0 = c0 + vec3(o0.x, sqrt(max(r0 * r0 - dot(o0, o0), 0.0)), o0.y);
			vec3 l1 = c1 + vec3(o1.x, sqrt(max(r1 * r1 - dot(o1, o1), 0.0)), o1.y);
			float k0 = 1.0 - smoothstep(0.0, land_fade, e);
			float k1 = 1.0 - smoothstep(0.0, land_fade, 1.0 - e);
			pos += (l0 - M[0].xyz) * k0 + (l1 - M[2].xyz) * k1;
			shrink = (1.0 - k0 * k0) * (1.0 - k1 * k1);
		}
		vec3 d = 2.0 * w * (M[1].xyz - M[0].xyz) + 2.0 * u * (M[2].xyz - M[1].xyz);
		fwd = normalize(back ? -d : d);
		sc *= M[3].x * (1.0 + size_jitter * (traffic_draw(cu.w, 1.0) * 2.0 - 1.0)) * shrink;
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
