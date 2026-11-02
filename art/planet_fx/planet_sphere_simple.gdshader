shader_type spatial;
render_mode unshaded, cull_back, depth_draw_always;
// Stripped planet body: beauty map as albedo, plus the Fresnel crescent and the rim light, nothing else.
// No key-light shading, no relief, no clouds, no grain, no palette tint, no soft edge. The colour is the PNG colour
// (source_color: the sampler converts sRGB to linear, the unshaded output converts it back, so it shows as in the file).
// The Fresnel and rim code is copied unchanged from planet_sphere.gdshader (same uniforms, same defaults).
// The sun direction key_dir is used only to place the crescent and the rim (object space, towards the sun).

uniform sampler2D surface_tex : source_color, filter_linear_mipmap, repeat_enable;  // beauty colour map
uniform vec4 pale_col : source_color = vec4(0.70, 0.62, 1.00, 1.0);  // Fresnel colour (set from the palette by planet_sphere.gd)
uniform vec3 key_dir = vec3(-0.5, 0.5, 0.7);      // object space, towards the sun
uniform bool use_rim = true;
uniform vec4 rim_color : source_color = vec4(0.37, 0.66, 1.00, 1.0);
uniform float rim_strength = 0.050625;
uniform float fres_strength = 0.2;
uniform float fres_side = 0.0;
uniform float fres_power = 3.0;

varying vec3 obj_n;

void vertex() {
	obj_n = normalize(VERTEX);  // true sphere normal for the fragment stage
}

void fragment() {
	vec3 n = normalize(obj_n);
	// Equirect UV from the normal, derivatives fixed at the atan wrap so there is no seam line.
	vec2 uv = vec2(atan(n.x, n.z) / TAU + 0.5, acos(clamp(n.y, -1.0, 1.0)) / PI);
	vec2 dx = dFdx(uv);
	vec2 dy = dFdy(uv);
	if (abs(dx.x) > 0.5) dx.x -= sign(dx.x);
	if (abs(dy.x) > 0.5) dy.x -= sign(dy.x);
	vec3 col = textureGrad(surface_tex, uv, dx, dy).rgb;

	float NdV = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	// Fresnel crescent: limb glow on the sun side only (unchanged).
	float side = smoothstep(fres_side, fres_side + 0.6, dot(n, normalize(key_dir)));
	side *= side;
	float fres = pow(1.0 - NdV, fres_power * mix(1.8, 0.8, side)) * fres_strength * side;

	// Rim light: same crescent shape, added (unchanged).
	if (use_rim) {
		col += rim_color.rgb * rim_strength * pow(1.0 - NdV, fres_power * mix(1.8, 0.8, side)) * side;
	}
	col += pale_col.rgb * fres;

	ALBEDO = min(col, vec3(2.0));
}
