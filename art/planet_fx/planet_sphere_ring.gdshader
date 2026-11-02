shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;
// Textured ring for moon planets: one flat quad in the sphere's unit space. The ring PNG is RGB on black, so the alpha
// is a radial mask (inner and outer edge as a fraction of the quad half-width), and the colour is brightened and lit by key_dir.
uniform sampler2D ring_tex : filter_linear_mipmap, repeat_disable;
uniform vec3 key_dir = vec3(-0.5, 0.5, 0.7);
uniform vec4 key_color : source_color = vec4(1.0, 0.76, 0.42, 1.0);
uniform float inner = 0.32;
uniform float outer = 0.98;
uniform float brighten = 2.4;
uniform float spin = 0.005;
varying vec3 wpos;
varying vec3 ctr;
varying float rad;  // planet radius in world units (the quad is a child of the scaled sphere)
void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	ctr = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	rad = length(MODEL_MATRIX[1].xyz);
}
void fragment() {
	vec2 q = UV * 2.0 - 1.0;
	float r = length(q);
	float a = smoothstep(inner, inner + 0.02, r) * (1.0 - smoothstep(outer - 0.03, outer, r));
	if (a < 0.01) discard;
	// Slow spin: rotate the sample point around the centre.
	float s = sin(TIME * spin * TAU);
	float c = cos(TIME * spin * TAU);
	vec2 uv = vec2(q.x * c - q.y * s, q.x * s + q.y * c) * 0.5 + 0.5;
	vec3 col = texture(ring_tex, uv).rgb * brighten;
	// Planet shadow: the ring behind the planet (seen from the sun) is dark.
	vec3 k = normalize(key_dir);
	vec3 rel = wpos - ctr;
	float along = dot(rel, k);
	float dist = length(rel - k * along);
	float shadow = (along < 0.0) ? smoothstep(0.9, 1.1, dist / rad) : 1.0;
	ALBEDO = col * key_color.rgb * mix(0.25, 1.0, shadow);
	ALPHA = a * 0.475;
}
