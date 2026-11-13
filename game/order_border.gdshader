shader_type canvas_item;
// Owner 2026-11-13: the border of a planet resource button while an order runs (game/planet_panel.gd _order_border).
// A rounded-rect outline in col_a (and col_b when both orders run: the two colours share the outline and drift round it),
// with value noise travelling along the perimeter. rect_size is the control size in pixels, set by the panel.

uniform vec2 rect_size = vec2(100.0, 40.0);
uniform float radius = 6.0;
uniform float width = 1.6;
uniform vec4 col_a : source_color = vec4(0.3, 0.9, 0.5, 1.0);
uniform vec4 col_b : source_color = vec4(0.95, 0.35, 0.35, 1.0);
uniform float two_colours = 0.0;
uniform float speed = 0.35;     // perimeter turns per second... in noise cells: cells per second / cell count
uniform float cell_px = 16.0;   // noise feature length along the outline, in pixels

float hash(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

float vnoise(float x) {
	float i = floor(x);
	float f = fract(x);
	float u = f * f * (3.0 - 2.0 * f);
	return mix(hash(i), hash(i + 1.0), u);
}

float sd_round_box(vec2 p, vec2 b, float r) {
	vec2 q = abs(p) - b + r;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
	vec2 px = UV * rect_size;
	vec2 half_size = rect_size * 0.5;
	vec2 p = px - half_size;
	float r = min(radius, min(half_size.x, half_size.y));
	float d = sd_round_box(p, half_size - 0.5, r);
	// outline band: from -width to 0 inside the edge, soft by a pixel
	float band = smoothstep(-width - 1.0, -width, d) * (1.0 - smoothstep(-0.5, 0.5, d));
	// position along the perimeter (0..1), from the angle on a box squashed to a square
	float t = atan(p.y / max(half_size.y, 1.0), p.x / max(half_size.x, 1.0)) / 6.28318 + 0.5;
	float perim = 2.0 * (rect_size.x + rect_size.y);
	float cells = max(4.0, floor(perim / cell_px));
	float x = t * cells - TIME * speed * cells * 0.25;
	// wrap the noise so the seam at t = 0 / 1 does not jump
	float n = mix(vnoise(x), vnoise(x - cells), t);
	float n2 = vnoise(x * 2.7 + 13.0);
	float glow = 0.35 + 0.9 * pow(n, 2.0) + 0.25 * n2;
	vec3 c = col_a.rgb;
	if (two_colours > 0.5) {
		float k = 0.5 + 0.5 * sin((t + TIME * 0.08) * 6.28318 * 2.0);
		c = mix(col_a.rgb, col_b.rgb, smoothstep(0.35, 0.65, k));
	}
	COLOR = vec4(c * (0.8 + 0.4 * n), band * clamp(glow, 0.0, 1.0));
}
