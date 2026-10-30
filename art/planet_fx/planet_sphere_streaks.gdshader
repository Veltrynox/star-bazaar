shader_type spatial;
render_mode unshaded, blend_add, cull_back, depth_draw_never;
// Glowing streak layer: a shell just above the surface (radius 1.01), additive. Fine streaks come from the fine channel
// of the tone map at a higher density (integer repeats keep the seam closed). The shell spins on its own (spin), so it
// parallaxes against the body. Used only by the streaks variant.
uniform sampler2D tone_tex : filter_linear_mipmap, repeat_enable;
uniform vec4 streak_col : source_color = vec4(0.75, 0.60, 1.00, 1.0);
uniform vec3 key_dir = vec3(-0.5, 0.5, 0.7);
uniform float strength = 1.6;                  // above 1.0 blooms
uniform float spin = 0.004;                    // uv per second, a little faster or slower than the body
uniform vec2 density = vec2(6.0, 24.0);        // whole numbers keep the repeat seamless
uniform float streak_cut = 0.78;               // higher = fewer, finer streaks

varying vec3 obj_n;

void vertex() {
	obj_n = normalize(VERTEX);
}

void fragment() {
	vec3 n = normalize(obj_n);
	vec2 uv = vec2(atan(n.x, n.z) / TAU + 0.5, acos(clamp(n.y, -1.0, 1.0)) / PI);
	vec2 dx = dFdx(uv);
	vec2 dy = dFdy(uv);
	if (abs(dx.x) > 0.5) dx.x -= sign(dx.x);
	if (abs(dy.x) > 0.5) dy.x -= sign(dy.x);
	float band = textureGrad(tone_tex, uv + vec2(TIME * spin, 0.0), dx, dy).r;
	vec2 suv = (uv + vec2(TIME * spin, 0.0)) * density;
	float fine = textureGrad(tone_tex, suv, dx * density.x, dy * density.y).b;
	float streak = smoothstep(streak_cut - 0.12, streak_cut + 0.08, fine) * smoothstep(0.45, 0.75, band);
	float weight = 0.5 + 0.5 * dot(n, normalize(key_dir));
	ALBEDO = streak_col.rgb * streak * weight * strength;
}
