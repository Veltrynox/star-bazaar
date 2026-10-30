shader_type spatial;
render_mode unshaded, blend_add, cull_front, depth_draw_never;
// Outer glow shell (radius 1.12). Back faces only, so the planet hides its centre. Stronger Fresnel-like falloff:
// bright just outside the limb, gone at the shell edge. Brighter on the sun side. Additive, so values above 1.0 bloom.
varying vec3 obj_n;
uniform vec4 glow_col : source_color = vec4(0.45, 0.35, 1.00, 1.0);
uniform vec3 key_dir = vec3(-0.5, 0.5, 0.7);
uniform float strength = 1.6;
uniform float power = 1.2;
uniform float sun_bias = 0.5;

void vertex() {
	obj_n = normalize(VERTEX);
}

void fragment() {
	float nv = clamp(abs(dot(NORMAL, VIEW)), 0.0, 1.0);
	float sun = 0.5 + 0.5 * dot(normalize(obj_n), normalize(key_dir));
	ALBEDO = glow_col.rgb * pow(nv, power) * mix(1.0, sun, sun_bias) * strength;
}
