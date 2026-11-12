shader_type canvas_item;
// Flagship jump: a screen-space ripple (lens warp) around one point, a soft flash and a bright streak along the
// ship's bearing. progress 0..1 runs the whole beat. direction +1 = departure (ring expands, pulls outward),
// -1 = arrival (ring contracts onto the point). One full-screen quad, three texture reads, no per-frame allocation.
uniform sampler2D screen_tex : hint_screen_texture, filter_linear, repeat_disable;
uniform vec2 center_uv = vec2(0.5);      // effect centre in screen UV
uniform vec2 bearing = vec2(0.0, -1.0);  // unit vector of the streak on screen (pixels, y down)
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float direction = 1.0;           // +1 expand, -1 contract
uniform float strength_px = 28.0;        // peak displacement of the ripple, in pixels
uniform float max_radius_px = 520.0;     // ring radius at the end of the beat
uniform float ring_width_px = 90.0;      // soft width of the ring
uniform float flash = 1.0;               // flash and streak brightness (0 = off)
uniform float streak_px = 420.0;         // streak half length
uniform float streak_thick_px = 7.0;     // streak half width
uniform vec3 tint : source_color = vec3(0.75, 0.9, 1.0);

void fragment() {
	vec2 res = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 d = (SCREEN_UV - center_uv) * res;
	float r = length(d);
	float p = direction > 0.0 ? progress : 1.0 - progress;
	float e = 1.0 - pow(1.0 - p, 3.0);
	float ring_r = max_radius_px * e;
	float fade = (1.0 - progress) * min(1.0, progress * 10.0 + 0.25);
	float w = exp(-pow((r - ring_r) / ring_width_px, 2.0));
	vec2 dir = r > 0.001 ? d / r : vec2(0.0);
	vec2 off = dir * w * strength_px * fade * -direction / res;
	// small chromatic split on the wave
	float cr = texture(screen_tex, SCREEN_UV + off * 1.25).r;
	float cg = texture(screen_tex, SCREEN_UV + off).g;
	float cb = texture(screen_tex, SCREEN_UV + off * 0.75).b;
	vec3 col = vec3(cr, cg, cb);
	// flash: bright core that dies fast
	float k = 1.0 - progress;
	float core = exp(-r / (70.0 + 120.0 * e)) * k * k * k;
	// streak along the bearing, both ways from the point, thinning with time
	float along = dot(d, bearing);
	float perp = dot(d, vec2(-bearing.y, bearing.x));
	float len = streak_px * (0.4 + 0.6 * e);
	float sk = exp(-pow(perp / (streak_thick_px * (0.5 + k)), 2.0)) * (1.0 - smoothstep(0.0, len, abs(along))) * k * k;
	col += tint * (core * 0.9 + sk * 1.2) * flash;
	COLOR = vec4(col, 1.0);
}
