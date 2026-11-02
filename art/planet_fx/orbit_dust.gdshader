shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;
// Orbit dust: the asteroid ring PNG (dusty ring on black) laid on a flat annulus, mapped by radius like the planet belt.
// Mesh inputs: UV.x = angle / TAU, UV.y = 0..1 across the band.
uniform vec4 dust_color : source_color = vec4(1.0, 0.8, 0.55, 1.0); // set to the sun colour
uniform sampler2D ring_tex : filter_linear_mipmap, repeat_disable;  // asteroid1/2.png
uniform float tex_in = 0.38;       // band edges mapped onto the part of the PNG that holds dust (set per file in map.gd)
uniform float tex_out = 0.96;
uniform float alpha = 0.5;         // overall faintness
uniform float ring_width = 0.5;    // world width of the band (same as the mesh; kept for tests and tuning)
uniform float speed = 0.005;       // drift: turns per second around the orbit

void fragment() {
	float ang = UV.x * TAU + TIME * speed * TAU;   // a circular image has no seam
	vec2 uv = 0.5 + 0.5 * mix(tex_in, tex_out, UV.y) * vec2(cos(ang), sin(ang));
	vec3 tex = texture(ring_tex, uv).rgb;
	float edge = smoothstep(0.0, 0.2, UV.y) * smoothstep(1.0, 0.8, UV.y);  // soft inner and outer falloff
	float a = edge * smoothstep(0.02, 0.12, dot(tex, vec3(0.3, 0.59, 0.11)));  // black background and gaps are transparent
	ALBEDO = dust_color.rgb * (0.4 + tex);
	ALPHA = clamp(a * alpha, 0.0, 1.0);
}
