shader_type canvas_item;
render_mode blend_add;
// Camera lens glare for one bright source (the sun) on a full-screen quad. Additive.
// Parts: a soft halo, a horizontal anamorphic streak with a faint cross streak, and ghosts: rings on the line from the
// source through the screen centre to the far side. Ghosts fade out when the source is in the middle of the screen and
// grow toward the edge, as a real lens does. Everything fades when the source leaves the screen.
const int MAX_GHOSTS = 6;
uniform vec2 src_uv = vec2(0.5, 0.5);        // source position on screen, 0..1 (set by lens_glare.gd)
uniform float aspect = 1.78;                 // viewport width / height (set by lens_glare.gd)
uniform float brightness = 1.0;              // how bright the source is now, 0..1.5 (sun flare level)
uniform float strength = 0.5;                // overall glare strength
uniform float streak_len = 0.45;             // streak half-length, in screen heights
uniform int ghost_count : hint_range(0, 6) = 4;
uniform float ghost_strength = 0.35;
uniform vec4 glare_col : source_color = vec4(1.0, 0.75, 0.45, 1.0);   // streak and halo tint (the sun colour)
uniform vec4 ghost_col : source_color = vec4(0.45, 0.70, 1.0, 1.0);   // ghosts drift from this toward glare_col

void fragment() {
	vec2 asp = vec2(aspect, 1.0);
	vec2 d = (UV - src_uv) * asp;
	vec2 c = (src_uv - vec2(0.5)) * 2.0;              // source offset from the centre, -1..1
	float off = length(c);                            // 0 centre, about 1 at the edge, above 1 off screen
	float edge = smoothstep(0.0, 0.8, off);           // ghosts and streak growth follow this
	float vis = 1.0 - smoothstep(1.0, 1.5, off);      // fade out as the source leaves the screen
	float k = strength * brightness * vis;

	// Halo and streaks: the streak is longer when the source is nearer the edge and when it is brighter.
	float r2 = dot(d, d);
	float halo = 0.02 / (r2 + 0.02);
	float len = streak_len * (0.7 + 0.5 * edge) * (0.6 + 0.4 * brightness);
	float h = exp(-abs(d.y) * 90.0) * exp(-abs(d.x) / len);
	float v = exp(-abs(d.x) * 120.0) * exp(-abs(d.y) / (len * 0.35)) * 0.35;
	vec3 col = glare_col.rgb * (halo * 0.35 + h + v) * k;

	// Ghosts: ring plus soft fill, mirrored through the centre at growing distance, hue drifting along the chain.
	vec2 axis = vec2(0.5) - src_uv;
	for (int i = 0; i < MAX_GHOSTS; i++) {
		if (i >= ghost_count) { break; }
		float fi = float(i);
		vec2 gp = vec2(0.5) + axis * (0.35 + 0.4 * fi);   // i = 0 sits just past the centre, the rest farther out
		float rad = 0.035 + 0.018 * fi;
		float gd = length((UV - gp) * asp);
		float ring = exp(-pow((gd - rad) / (rad * 0.3), 2.0));
		float fill = (1.0 - smoothstep(0.0, rad, gd)) * 0.25;
		vec3 tint = mix(ghost_col.rgb, glare_col.rgb, fi / 5.0);
		col += tint * (ring + fill) * ghost_strength * edge * k / (1.0 + 0.35 * fi);
	}
	COLOR = vec4(col, 1.0);
}
