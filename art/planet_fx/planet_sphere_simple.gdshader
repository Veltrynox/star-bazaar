shader_type spatial;
render_mode unshaded, blend_mix, cull_back, depth_draw_always;
// Stripped planet body: beauty map as albedo, plus the Fresnel crescent and the rim light, nothing else.
// Key-light shadow side (soft terminator, ambient floor) and height-gradient relief on the lit side (no geometry change).
// No clouds, no grain, no palette tint. Soft edge OUTSIDE the limb: the body is solid out to its true limb, and a halo feather of edge_px screen pixels
// melts into the background beyond it. Method: the vertex stage inflates the sphere by edge_px pixels; the fragment stage rebuilds the TRUE sphere
// normal from the screen position (hull normal x inflation), so the body shading, texture, Fresnel and rim stay as before, and pixels beyond the true
// limb get the limb colour with alpha falling to 0 at the hull edge. Depth of the halo is the centre plane, so it never hides the atmosphere shell or belts.
// The lit colour is the PNG colour
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
uniform float edge_px = 10.0;        // halo feather width OUTSIDE the limb in screen pixels (0 = hard edge)
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

varying float hull;  // inflation of the mesh: (true radius + edge_px pixels) / true radius

void vertex() {
	hull = 1.0;
	if (edge_px > 0.0) {
		vec3 c = (VIEW_MATRIX * MODEL_MATRIX[3]).xyz;  // sphere centre in view space
		float pix = (PROJECTION_MATRIX[3][3] > 0.5) ? 2.0 / (PROJECTION_MATRIX[1][1] * VIEWPORT_SIZE.y) : abs(c.z) * 2.0 / (PROJECTION_MATRIX[1][1] * VIEWPORT_SIZE.y);  // world size of one pixel at the centre
		float radius = length(MODEL_MATRIX[0].xyz) * 0.5;  // mesh radius is 0.5
		hull = 1.0 + edge_px * pix / radius;
		VERTEX *= hull;  // uniform inflation about the centre (model space)
	}
}

void fragment() {
	// True sphere normal from the screen position: the hull normal's lateral part times the inflation (view space), z from the unit length.
	vec2 lat = normalize(NORMAL).xy * hull;
	float lat_len = length(lat);
	if (lat_len > 1.0) lat /= lat_len;  // beyond the true limb (halo): the limb normal
	float NdV = sqrt(max(1.0 - dot(lat, lat), 0.0));  // true N.V, 0 at and beyond the limb
	vec3 n = normalize(inverse(mat3(MODEL_MATRIX)) * (mat3(INV_VIEW_MATRIX) * vec3(lat, NdV)));  // object space
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

	// Fresnel crescent: limb glow on the sun side only (unchanged).
	float side = smoothstep(fres_side, fres_side + 0.6, dot(n, normalize(key_dir)));
	side *= side;
	float fres = pow(1.0 - NdV, fres_power * mix(1.8, 0.8, side)) * fres_strength * side;

	// Rim light: same crescent shape, added (unchanged).
	if (use_rim) {
		col += rim_color.rgb * rim_strength * pow(1.0 - NdV, fres_power * mix(1.8, 0.8, side)) * side;
	}
	col += pale_col.rgb * fres;

	// Halo: 0 inside the true limb, 1 at the hull edge (edge_px pixels out). Solid body, soft feather outside.
	float t = (hull > 1.0) ? clamp((lat_len - 1.0) / (hull - 1.0), 0.0, 1.0) : 0.0;
	float edge_a = 1.0 - smoothstep(0.0, 1.0, t);
	edge_a = max(edge_a, smoothstep(0.3, 0.5, NdV));  // guard: facing the camera (true NdV > 0.5) is always opaque
	ALPHA = edge_a;
	ALBEDO = min(col, vec3(2.0));
	// Halo depth = the sphere's centre plane (never nearer than the true limb), so the atmosphere shell, belts and dust still draw over it.
	vec4 cc = PROJECTION_MATRIX * (VIEW_MATRIX * MODEL_MATRIX[3]);
	DEPTH = (t > 0.0) ? cc.z / cc.w : FRAGCOORD.z;
}
