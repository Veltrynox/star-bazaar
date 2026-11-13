shader_type spatial;
// Asteroid pack rock: one draw call per pack (MultiMesh). Every rock tumbles on its own axis and drifts on a small closed
// path round its home spot, all in the vertex stage (like game/fx/planet/asteroid_dust_ring.gdshader), so the CPU does nothing per frame.
// The drift amplitude is capped per rock (script) so the rock stays inside the pack's ellipsoid: the click shape in map.gd stays valid.
// Instance transform = home position + scale only (no rotation). The surface look is the old StandardMaterial3D: albedo texture x colour, roughness, no metal.
// INSTANCE_CUSTOM per rock: x = start phase (rad), y = drift amplitude as a share of pack_radius (0..0.3),
// z = signed speed factor (0.5..1.5, sign = direction), w = random 0..1 (tumble axis, tumble rate).
// game_time = game seconds from the same clock as the pack orbit, so it freezes on pause.

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.95;
uniform float game_time = 0.0;          // game seconds (stops on pause)
uniform vec3 pack_tangent = vec3(1.0, 0.0, 0.0);  // pack-local unit vector of the long axis (the orbit tangent)
uniform float pack_radius = 0.2;        // across-radius of the pack, world units
uniform float pack_stretch = 3.0;       // length along the tangent vs across
uniform float pack_flatten = 0.5;       // pack height as a share of its width
uniform float drift_speed = 0.06;       // rad/s of the drift path
uniform float tumble_speed = 0.25;       // rad/s of a rock's own turn
uniform float bob_speed = 0.175;         // rad/s of the gentle up-down

vec3 rot(vec3 v, vec3 k, float ang) {  // Rodrigues: turn v about unit axis k
	float c = cos(ang);
	return v * c + cross(k, v) * sin(ang) + k * dot(k, v) * (1.0 - c);
}

void vertex() {
	vec4 cd = INSTANCE_CUSTOM;
	float a = cd.x + game_time * drift_speed * cd.z;
	vec3 radial = vec3(pack_tangent.z, 0.0, -pack_tangent.x);
	float amp = cd.y * pack_radius;
	// ellipse of the drift stretched like the pack, plus a small bob (same normalised share as the script's margin maths)
	vec3 off = pack_tangent * (cos(a) * amp * pack_stretch) + radial * (sin(a) * amp)
		+ vec3(0.0, sin(game_time * bob_speed + cd.x * 3.0) * amp * pack_flatten * 0.4, 0.0);
	float h1 = fract(cd.w * 91.7) * 3.14159;
	float h2 = fract(cd.w * 47.3) * 6.28318;
	vec3 axis = vec3(sin(h1) * cos(h2), cos(h1), sin(h1) * sin(h2));
	float ang = cd.x + game_time * tumble_speed * cd.z * (0.5 + fract(cd.w * 13.1));
	float s = max(length(MODEL_MATRIX[0].xyz), 0.0001);  // rock scale (instance basis is a pure scale, the node only turns)
	VERTEX = rot(VERTEX, axis, ang) + off / s;
	NORMAL = rot(NORMAL, axis, ang);
}

void fragment() {
	ALBEDO = texture(albedo_tex, UV).rgb * albedo_color.rgb;
	ROUGHNESS = roughness;
	METALLIC = 0.0;
	SPECULAR = 0.5;
}
