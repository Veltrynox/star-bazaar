shader_type canvas_item;
// Screen-space soft edge for the planets: a blur applied ONLY in a ring of ring_px pixels outside each planet's disc.
// The disc itself and everything farther out stay sharp. Samples the finished 3D view (hint_screen_texture) with 13 taps
// (centre, 6 at half radius, 6 at full radius, rings rotated by 30 degrees; bilinear, so about a Gaussian of radius blur_px).
// Discs come from edge_blur.gd: vec4(centre x px, centre y px, radius px, 1 = shown), in viewport pixels.
const int MAX_DISCS = 16;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear, repeat_disable;
uniform vec4 discs[MAX_DISCS];
uniform int disc_count = 0;
uniform vec2 vp_size = vec2(1920.0, 1080.0);  // viewport size in pixels
uniform float ring_px = 10.0;                 // ring width outside the disc
uniform float blur_px = 10.0;                 // blur radius

void fragment() {
	vec2 p = SCREEN_UV * vp_size;
	float w = 0.0;
	for (int i = 0; i < MAX_DISCS; i++) {
		if (i >= disc_count) break;
		vec4 d = discs[i];
		if (d.w < 0.5) continue;
		float dist = distance(p, d.xy);
		// 0 inside the disc, 1 just outside it, back to 0 at the outer edge of the ring (smooth on both sides)
		float m = smoothstep(d.z, d.z + 1.5, dist) * (1.0 - smoothstep(d.z + ring_px - 4.0, d.z + ring_px, dist));
		w = max(w, m);
	}
	vec4 base = texture(screen_tex, SCREEN_UV);
	if (w <= 0.001) {
		COLOR = vec4(base.rgb, 1.0);
	} else {
		vec2 px = 1.0 / vp_size;
		vec3 sum = base.rgb;
		for (int k = 0; k < 6; k++) {
			float a = float(k) * 1.0471976;  // 60 degrees
			vec2 dir = vec2(cos(a), sin(a));
			vec2 dir2 = vec2(cos(a + 0.5235988), sin(a + 0.5235988));
			sum += texture(screen_tex, SCREEN_UV + dir * blur_px * 0.5 * px).rgb;
			sum += texture(screen_tex, SCREEN_UV + dir2 * blur_px * px).rgb;
		}
		COLOR = vec4(mix(base.rgb, sum / 13.0, w), 1.0);
	}
}
