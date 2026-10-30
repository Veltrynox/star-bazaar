shader_type spatial;
render_mode unshaded, blend_mix, cull_back, depth_draw_never;
// Thin atmosphere: a shell 3.5 percent above the surface, front faces only.
// The alpha uses the same Fresnel falloff as the body edge (fres_strength, fres_power): inside the planet's limb it
// follows the body's Fresnel curve, so the two join with no step. Outside the limb it fades smoothly to zero at the
// shell's outer radius, so there is no hard edge.
// rho is the screen radius in planet radii: a front point on a shell of radius R has rho = R * sqrt(1 - nv^2).
varying vec3 obj_n;
uniform vec4 scatter_col : source_color = vec4(0.50, 0.60, 1.00, 1.0);
uniform vec3 key_dir = vec3(-0.5, 0.5, 0.7);
uniform float density = 0.9;                      // overall haze, scales the whole falloff
uniform float fres_strength = 0.68;               // must match planet_sphere.gdshader
uniform float fres_power = 3.0;                   // must match planet_sphere.gdshader
uniform float shell_radius = 1.035;               // must match the Atmosphere mesh radius
uniform float sun_bias = 0.5;

void vertex() {
	obj_n = normalize(VERTEX);
}

void fragment() {
	float nv = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float rho = shell_radius * sqrt(1.0 - nv * nv);
	// Inside the limb (rho <= 1): the body's Fresnel, evaluated at the body's own normal sqrt(1 - rho^2).
	float body_nv = sqrt(max(1.0 - min(rho, 1.0) * min(rho, 1.0), 0.0));
	float inside = pow(1.0 - body_nv, fres_power) * fres_strength;
	// Outside the limb (1 < rho < shell_radius): equal to fres_strength at the limb, then a smooth fade to zero.
	float outside = fres_strength * (1.0 - smoothstep(1.0, shell_radius, rho));
	float falloff = mix(inside, outside, step(1.0, rho));
	float sun = 0.5 + 0.5 * dot(normalize(obj_n), normalize(key_dir));
	ALBEDO = scatter_col.rgb;
	ALPHA = clamp(falloff * density * mix(1.0, sun, sun_bias), 0.0, 1.0);
}
