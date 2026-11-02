shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;
// Orbit dust: a faint band of fine grains on a flat annulus, made only in the fragment shader.
// Mesh inputs: UV.x = angle / TAU, UV.y = 0..1 across the band, COLOR.r = orbit radius / 10.
uniform vec4 dust_color : source_color = vec4(1.0, 0.8, 0.55, 1.0); // set to the sun colour
uniform float alpha = 0.12;        // overall faintness
uniform float grain_scale = 28.0;  // grains per world unit (higher = finer)
uniform float speed = 0.02;        // drift around the orbit, cells per second
uniform float ring_width = 0.5;    // world width of the band (same as the mesh)
uniform float patch_scale = 3.0;   // patches per world unit that brighten the dust

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}
float vnoise(vec2 p, float wrap) {  // value noise, x wraps every `wrap` cells so the ring has no seam
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float x0 = mod(i.x, wrap);
	float x1 = mod(i.x + 1.0, wrap);
	return mix(mix(hash(vec2(x0, i.y)), hash(vec2(x1, i.y)), f.x),
			mix(hash(vec2(x0, i.y + 1.0)), hash(vec2(x1, i.y + 1.0)), f.x), f.y);
}

void fragment() {
	float radius = COLOR.r * 10.0;
	float cells = max(1.0, floor(radius * TAU * grain_scale));  // whole cells around the ring
	vec2 p = vec2(UV.x * cells + TIME * speed, (UV.y - 0.5) * ring_width * grain_scale);
	float g = hash(floor(p));                       // fine grain
	g = smoothstep(0.55, 1.0, g);                   // sparse, so it reads as dust not fog
	float pc = max(1.0, floor(radius * TAU * patch_scale));
	vec2 q = vec2(UV.x * pc + TIME * speed * 0.1, UV.y * ring_width * patch_scale);
	float patches = 0.4 + 1.2 * vnoise(q, pc);      // slightly brighter in patches
	float edge = smoothstep(0.0, 0.5, UV.y) * smoothstep(1.0, 0.5, UV.y);  // soft inner and outer falloff
	ALBEDO = dust_color.rgb;
	ALPHA = clamp(g * patches * edge * alpha * 4.0, 0.0, 1.0);
}
