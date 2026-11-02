shader_type spatial;
render_mode unshaded, cull_back, depth_draw_always;
// Stripped planet body: beauty map as albedo, plus the Fresnel crescent and the rim light, nothing else.
// Key-light shadow side (soft terminator, ambient floor) and height-gradient relief on the lit side (no geometry change).
// No clouds, no grain, no palette tint, no soft edge. The lit colour is the PNG colour
// (source_color: the sampler converts sRGB to linear, the unshaded output converts it back, so it shows as in the file).
// The Fresnel and rim code is copied unchanged from planet_sphere.gdshader (same uniforms, same defaults).
// The sun direction key_dir is used only to place the crescent and the rim (object space, towards the sun).

uniform sampler2D surface_tex : source_color, filter_linear_mipmap, repeat_enable;  // beauty colour map
uniform vec4 pale_col : source_color = vec4(0.70, 0.62, 1.00, 1.0);  // Fresnel colour (set from the palette by planet_sphere.gd)
uniform vec3 key_dir = vec3(-0.5, 0.5, 0.7);      // object space, towards the sun
uniform bool use_rim = true;
uniform vec4 rim_color : source_color = vec4(0.37, 0.66, 1.00, 1.0);
uniform float rim_strength = 0.0658125;  // 1.3x the earlier 0.050625
uniform float fres_strength = 0.2;
uniform float fres_side = 0.0;
uniform float fres_power = 3.0;
uniform sampler2D disp_tex : filter_linear_mipmap, repeat_enable;  // greyscale height map, for the relief
uniform bool use_disp = false;
uniform float relief = 0.6;          // normal-map scale: how far the height gradient bends the normal (0 = flat)
uniform float shadow_ambient = 0.3;  // brightness floor of the dark side (0 = black, 1 = no shadow)
uniform float term_soft = 0.30;      // terminator softness in dot(n, sun); wider = softer edge
uniform float bump_gain = 1.5;       // how much the bumped normal changes the lit brightness

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

	// Shadow side: lit weight from the true sphere normal against the sun, soft terminator, never below the ambient floor.
	vec3 k = normalize(key_dir);
	float nk = dot(n, k);
	float lit = smoothstep(-term_soft * 0.5, term_soft, nk);
	float shade = mix(shadow_ambient, 1.0, lit);
	// Relief: height gradient (east/south) bends the normal; the change in dot with the sun brightens or darkens the lit side.
	if (use_disp) {
		const float EPS = 0.0025;
		float hu = textureGrad(disp_tex, uv + vec2(EPS, 0.0), dx, dy).r - textureGrad(disp_tex, uv - vec2(EPS, 0.0), dx, dy).r;
		float hv = textureGrad(disp_tex, uv + vec2(0.0, EPS), dx, dy).r - textureGrad(disp_tex, uv - vec2(0.0, EPS), dx, dy).r;
		vec3 east = normalize(cross(vec3(0.0, 1.0, 0.0), n) + vec3(1e-4, 0.0, 0.0));
		vec3 south = cross(n, east);  // v grows towards the south pole
		vec3 nb = normalize(n - relief * (hu * east + hv * south));
		shade *= clamp(1.0 + bump_gain * (dot(nb, k) - nk) * lit, 0.3, 1.7);
	}
	col *= shade;

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
