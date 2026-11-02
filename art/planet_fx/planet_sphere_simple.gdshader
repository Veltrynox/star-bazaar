shader_type spatial;
render_mode unshaded, blend_mix, cull_back, depth_draw_always;
// Stripped planet body: beauty map as albedo, plus the Fresnel crescent and the rim light, nothing else.
// Key-light shadow side (soft terminator, ambient floor) and height-gradient relief on the lit side (no geometry change).
// No clouds, no grain, no palette tint. Soft edge: alpha fades over edge_px screen pixels at the limb (same method as planet_sphere.gdshader). The lit colour is the PNG colour
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
uniform float shadow_ambient = 0.07; // LINEAR floor of the dark side (0 = black, 1 = no shadow). Output is sRGB-encoded, so 0.07 shows as 0.07^(1/2.2) = 0.3 on screen
uniform float term_soft = 0.30;      // terminator softness in dot(n, sun); wider = softer edge
uniform float edge_px = 10.0;        // soft limb edge width in screen pixels (0 = hard edge)
uniform float bump_gain = 1.5;       // how much the bumped normal changes the lit brightness

// Cloud layer (earth-like types: lush, agrarian, ocean): screen-style light mask, the same blend as the cloud shell
// (planet_sphere_clouds.gdshader): out = 1 - (1 - col) * (1 - mask * light); black texels add nothing. Drifts with TIME.
uniform bool use_clouds = false;
uniform sampler2D cloud_tex : filter_linear_mipmap, repeat_enable;  // white clouds on black, no alpha
uniform float cloud_speed = 0.003;   // uv per second (about 5.5 minutes per lap)
uniform float cloud_alpha = 0.9;
uniform vec4 cloud_col : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float cloud_ambient = 0.0;   // cloud brightness on the night side (0: clouds do not light the shadow side)
// Storm glow (the cloudy type only): the bright swirls of the same texture add soft light on top of the body.
uniform bool use_storm_glow = false;
uniform vec4 storm_col : source_color = vec4(0.66, 0.77, 1.0, 1.0);  // set from the palette glow colour
uniform float storm_strength = 0.6;  // modest; above 1.0 would go into the HDR glow

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

	// Clouds: screen blend of the lit cloud mask over the shaded body (sun-side gate like the cloud shell).
	if (use_clouds || use_storm_glow) {
		vec2 cuv = uv + vec2(TIME * cloud_speed, 0.0);
		float c = textureGrad(cloud_tex, cuv, dx, dy).r;
		if (use_clouds) {
			float a = smoothstep(0.05, 0.85, c) * cloud_alpha;
			vec3 light = cloud_col.rgb * mix(cloud_ambient, 1.0, lit);
			col = vec3(1.0) - (vec3(1.0) - col) * (vec3(1.0) - light * a);
		}
		if (use_storm_glow) {
			// Additive soft light on the bright swirls only, gated by the lit term so the shadow side stays dark.
			col += storm_col.rgb * smoothstep(0.55, 0.95, c) * storm_strength * lit;
		}
	}

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

	// Soft edge: distance from the limb in screen pixels (view-space radius minus distance from the centre, over the pixel size).
	float edge_a = 1.0;
	if (edge_px > 0.0) {
		float pix = (PROJECTION_MATRIX[3][3] > 0.5) ? 2.0 / (PROJECTION_MATRIX[1][1] * VIEWPORT_SIZE.y) : -VERTEX.z * 2.0 / (PROJECTION_MATRIX[1][1] * VIEWPORT_SIZE.y);
		vec3 centre = (VIEW_MATRIX * MODEL_MATRIX[3]).xyz;
		float radius = length(MODEL_MATRIX[0].xyz) * 0.5;  // mesh radius is 0.5
		float d_px = (radius - length(VERTEX.xy - centre.xy)) / pix;
		edge_a = smoothstep(0.0, 1.0, d_px / edge_px);
	}
	ALPHA = edge_a;
	ALBEDO = min(col, vec3(2.0));
}
