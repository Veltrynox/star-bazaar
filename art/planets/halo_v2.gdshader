shader_type spatial;
render_mode unshaded, blend_add, cull_front, depth_draw_never;
// Outer halo: a larger low-poly sphere (radius 1.2), back faces only, so the planet hides its centre. Brightest at its centre line,
// fades to nothing at its own silhouette, so the planet edge gets a soft glow outside the rim.
uniform vec4 halo_col : source_color = vec4(1.0, 0.4, 0.1, 1.0);
uniform float strength = 0.5;
void fragment() {
	float nv = clamp(abs(dot(NORMAL, VIEW)), 0.0, 1.0);
	ALBEDO = halo_col.rgb * pow(nv, 2.2) * strength;
}
