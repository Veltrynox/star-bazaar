shader_type canvas_item;
render_mode blend_mix, unshaded;
// Film grain: neutral monochrome noise over the 3D view. One pass, no textures.
// Each pixel gets a hash noise value that changes ~24 times a second (TIME); it is drawn as white (lighter) or black (darker)
// with alpha = strength, so the grain brightens and darkens the picture evenly and adds no colour tint.

uniform float strength : hint_range(0.0, 0.5) = 0.06;
uniform float fps = 24.0;       // grain refresh rate; film-like, not per-frame flicker

// Cheap 2D hash (no sin), returns 0..1.
float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	vec2 px = floor(FRAGCOORD.xy);
	float f = floor(TIME * fps);
	// Offset the lattice per frame so the pattern is not a shifted copy of the last one.
	vec2 off = vec2(fract(f * 0.7548777), fract(f * 0.5698403)) * 512.0;
	// Two hashes averaged give a softer, bell-shaped distribution (fewer harsh outliers).
	float n = 0.5 * (hash12(px + off) + hash12(px.yx * 1.37 + off + 71.0));
	float d = n - 0.5;                                  // -0.5..0.5
	COLOR = vec4(vec3(d > 0.0 ? 1.0 : 0.0), abs(d) * 2.0 * strength);
}
