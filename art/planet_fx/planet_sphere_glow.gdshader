shader_type spatial;
render_mode unshaded, blend_add, cull_front, depth_draw_never;
// Outer glow shell (radius 1.12). Back faces only, so the planet hides its centre. A clean 0-1-0 ramp in screen radius:
// at the planet's limb (rho = 1) the glow equals the body's Fresnel edge value (edge_value = fres_strength), it peaks
// there, and it fades smoothly to zero at the shell's outer radius. No hard ring. Brighter on the sun side. Additive.
// rho is the screen radius in planet radii: a back point on a shell of radius R has rho = R * sqrt(1 - nv^2).
varying vec3 obj_n;
uniform vec4 glow_col : source_color = vec4(0.45, 0.35, 1.00, 1.0);
uniform vec3 key_dir = vec3(-0.5, 0.5, 0.7);
uniform float strength = 1.6;
uniform float power = 1.2;                       // fade shape: higher = tighter glow
uniform float edge_value = 0.68;                  // must match fres_strength in planet_sphere.gdshader
uniform float shell_radius = 1.12;                // must match the Glow mesh radius
uniform float sun_bias = 0.5;

void vertex() {
	obj_n = normalize(VERTEX);
}

void fragment() {
	float nv = clamp(abs(dot(NORMAL, VIEW)), 0.0, 1.0);
	float rho = shell_radius * sqrt(1.0 - nv * nv);
	// 1 at the limb, 0 at the shell edge; rho < 1 is hidden by the planet, so clamp keeps it flat there.
	float ramp = pow(1.0 - smoothstep(1.0, shell_radius, max(rho, 1.0)), power);
	float sun = 0.5 + 0.5 * dot(normalize(obj_n), normalize(key_dir));
	// strength / 1.6 keeps the old strength slider as a multiplier around the matched edge value.
	ALBEDO = glow_col.rgb * edge_value * ramp * mix(1.0, sun, sun_bias) * (strength / 1.6);
}
