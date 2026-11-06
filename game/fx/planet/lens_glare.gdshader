shader_type canvas_item;
render_mode blend_add;
// Camera lens glare for one bright source (the sun) on a full-screen quad. Additive.
// Layers, inside out:
//   1 core and two halo falloffs (soft, wide haze)
//   2 chromatic halo ring around the source (red outside, blue inside)
//   3 starburst: six fine spikes and six wide rays from the source
//   4 anamorphic streaks: a horizontal streak, a faint vertical cross and a thin diagonal
//   5 ghosts: rings on the line from the source through the screen centre to the far side, with a colour fringe;
//     every second ghost is a hexagonal iris instead of a round ring
//   6 second starburst: eight dim, wide spikes turned off the first set, and a faint outer halo ring
//   7 rainbow arc: a wide soft spectrum arc around the source, only on the side facing the screen centre
// Layer weights are uniforms; the defaults keep the total close to the earlier look.
// Ghosts grow toward the screen edge and fade near the centre, as a real lens does. Everything fades when the source leaves the screen.
const int MAX_GHOSTS = 6;
uniform vec2 src_uv = vec2(0.5, 0.5);        // source position on screen, 0..1 (set by lens_glare.gd)
uniform float aspect = 1.78;                 // viewport width / height (set by lens_glare.gd)
uniform float brightness = 1.0;              // how bright the source is now, 0..1.5 (sun flare level)
uniform float strength = 0.1;                // overall glare strength
uniform float streak_len = 0.45;             // streak half-length, in screen heights
uniform int ghost_count : hint_range(0, 6) = 5;
uniform float ghost_strength = 0.07;
uniform float ring_strength = 0.5;           // chromatic halo ring
uniform float spike_strength = 0.4;          // starburst
uniform float burst2_strength = 0.35;        // second starburst (8 spikes)
uniform float halo2_strength = 0.3;          // faint outer halo ring
uniform float arc_strength = 0.3;            // rainbow arc
uniform float hex_strength = 1.0;            // 0 = all ghosts round, 1 = every second ghost is a hexagon
uniform vec4 glare_col : source_color = vec4(1.0, 0.75, 0.45, 1.0);   // streak and halo tint (the sun colour)
uniform vec4 ghost_col : source_color = vec4(0.45, 0.70, 1.0, 1.0);   // ghosts drift from this toward glare_col

void fragment() {
	vec2 asp = vec2(aspect, 1.0);
	vec2 d = (UV - src_uv) * asp;
	vec2 c = (src_uv - vec2(0.5)) * 2.0;              // source offset from the centre, -1..1
	float off = length(c);                            // 0 centre, about 1 at the edge, above 1 off screen
	float edge = smoothstep(0.0, 0.8, off);           // ghosts, ring and streak growth follow this
	float vis = 1.0 - smoothstep(1.0, 1.5, off);      // fade out as the source leaves the screen
	float k = strength * brightness * vis;

	float dist = length(d);
	float r2 = dot(d, d);
	float ang = atan(d.y, d.x);
	vec3 col = vec3(0.0);

	// 1 core and halo falloffs
	float core = 0.006 / (r2 + 0.006);
	float halo = 0.02 / (r2 + 0.02);
	float haze = 0.08 / (r2 + 0.08);
	col += glare_col.rgb * (core * 0.6 + halo * 0.25 + haze * 0.05);

	// 2 chromatic halo ring: each channel at a slightly different radius
	float ring_r = (0.14 + 0.04 * edge) * (0.5 + 0.5 * brightness);
	vec3 ring = vec3(
		exp(-pow((dist - ring_r * 1.04) / (ring_r * 0.07), 2.0)),
		exp(-pow((dist - ring_r) / (ring_r * 0.07), 2.0)),
		exp(-pow((dist - ring_r * 0.96) / (ring_r * 0.07), 2.0)));
	col += ring * ring_strength * 0.3 * (0.6 + 0.4 * edge);

	// 3 starburst: six spikes (abs(cos 3a) peaks six times a turn), a fine long one and a wide short one
	float spike_fine = pow(abs(cos(ang * 3.0)), 80.0) * exp(-dist * 7.0);
	float spike_wide = pow(abs(cos(ang * 3.0)), 6.0) * exp(-dist * 2.5);
	col += glare_col.rgb * (spike_fine * 0.7 + spike_wide * 0.12) * spike_strength * (0.5 + 0.5 * brightness);

	// 6 second starburst: eight spikes turned by 22.5 degrees, dimmer and shorter; plus a faint outer halo ring
	float spike2 = pow(abs(cos(ang * 4.0 + 0.3927)), 40.0) * exp(-dist * 4.5);
	col += mix(glare_col.rgb, vec3(1.0), 0.4) * spike2 * 0.35 * burst2_strength * (0.5 + 0.5 * brightness);
	float r2o = 0.3 * (0.8 + 0.2 * brightness);
	col += glare_col.rgb * exp(-pow((dist - r2o) / 0.05, 2.0)) * 0.08 * halo2_strength;

	// 7 rainbow arc: spectrum across the arc width, limited to the side that faces the screen centre
	vec2 to_c = (vec2(0.5) - src_uv) * asp;
	float facing = dot(d, to_c) / (max(dist, 0.0001) * max(length(to_c), 0.0001));
	float arc_mask = smoothstep(0.55, 0.95, facing) * edge;
	float arc_r = 0.62;
	float t = clamp((dist - arc_r) / 0.05 * 0.5 + 0.5, 0.0, 1.0);   // 0 inner (blue) to 1 outer (red)
	vec3 spec = clamp(vec3(t * 2.0 - 0.4, 1.0 - abs(t - 0.5) * 2.2, 1.6 - t * 2.0), 0.0, 1.0);
	col += spec * exp(-pow((dist - arc_r) / 0.05, 2.0)) * arc_mask * 0.1 * arc_strength;

	// 4 anamorphic streaks: the streak is longer toward the edge and when brighter
	float len = streak_len * (0.7 + 0.5 * edge) * (0.6 + 0.4 * brightness);
	float h = exp(-abs(d.y) * 90.0) * exp(-abs(d.x) / len);
	float v = exp(-abs(d.x) * 120.0) * exp(-abs(d.y) / (len * 0.35)) * 0.35;
	vec2 dr = vec2(d.x * 0.7071 + d.y * 0.7071, -d.x * 0.7071 + d.y * 0.7071);  // rotated 45 degrees
	float diag = exp(-abs(dr.y) * 160.0) * exp(-abs(dr.x) / (len * 0.5)) * 0.18;
	col += glare_col.rgb * (h + v + diag);

	// 5 ghosts: ring plus soft fill, mirrored through the centre at growing distance, with a colour fringe
	vec2 axis = vec2(0.5) - src_uv;
	vec3 ghosts = vec3(0.0);
	for (int i = 0; i < MAX_GHOSTS; i++) {
		if (i >= ghost_count) { break; }
		float fi = float(i);
		vec2 gp = vec2(0.5) + axis * (0.35 + 0.4 * fi);   // i = 0 sits just past the centre, the rest farther out
		float rad = 0.035 + 0.018 * fi;
		vec2 gq = (UV - gp) * asp;
		float gd = length(gq);
		if (i % 2 == 1) {   // hexagonal iris: hexagon distance, flat sides up
			vec2 hp = abs(gq);
			gd = mix(gd, max(hp.x * 0.866 + hp.y * 0.5, hp.y) * 1.1, hex_strength);
		}
		vec3 rings = vec3(
			exp(-pow((gd - rad * 0.95) / (rad * 0.3), 2.0)),
			exp(-pow((gd - rad) / (rad * 0.3), 2.0)),
			exp(-pow((gd - rad * 1.05) / (rad * 0.3), 2.0)));
		float fill = (1.0 - smoothstep(0.0, rad, gd)) * 0.25;
		vec3 tint = mix(ghost_col.rgb, glare_col.rgb, fi / 5.0);
		ghosts += tint * (rings + fill) / (1.0 + 0.35 * fi);
	}
	col += ghosts * ghost_strength * edge;

	COLOR = vec4(col * k, 1.0);
}
