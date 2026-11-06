shader_type spatial;
render_mode unshaded, blend_mix, cull_back, depth_draw_always;
// Planet surface on a sphere mesh. UVs come from the surface normal (equirect), so the texture is fixed on the sphere
// and does not move with the camera. The surface texture is greyscale: its brightness is the tone, tinted with the
// palette (deep, mid, pale). The key light (sun side) and the rim light (side opposite the sun) are separate terms,
// and the Fresnel edge is a soft crescent on the sun side only.
// Looks (variant): 0 standard, 1 fresnel_only, 2 city (0% of planets, uses fine_tex), 3 pale (lighter palette).
// Beauty path (use_beauty): the texture is a colour map, used as albedo with no palette tint. The displacement map moves the
// vertices (silhouette), bends the normal (bump) and shifts the terminator (high ground keeps the sun longer). Optional glow mask (emission on both sides, soft pulse)
// and lights mask (dark side only, small warm twinkle). Emission stays under about 2.0 (bloom-safe).
// Unshaded, so the final colour is written to ALBEDO directly.
// Soft edge: the body fades to transparent over edge_px screen pixels at the limb (a gradient into the background).
// The body is in the blend pass but still writes depth; its material has render_priority -1 so it draws before the shells.

uniform sampler2D surface_tex : filter_linear_mipmap, repeat_enable;  // greyscale surface, set per planet from the texture list
uniform sampler2D fine_tex : filter_linear_mipmap, repeat_enable;     // old generated tone map: B = fine grain (city specks only)
uniform bool use_beauty = false;                  // true: surface_tex is a colour map (per-type table in planet_sphere.gd)
uniform sampler2D disp_tex : filter_linear_mipmap, repeat_enable;     // greyscale height, relief on the key light
uniform sampler2D glow_tex : filter_linear_mipmap, repeat_enable;     // white streaks on black, emission
uniform sampler2D lights_tex : filter_linear_mipmap, repeat_enable;   // white city lights on black, dark side only
uniform sampler2D cloud_tex : filter_linear_mipmap, repeat_enable;    // white clouds on black: casts the cloud shadow (same drift as the cloud shell)
uniform bool use_cloud_shadow = false;
uniform float cloud_shadow = 0.55;                // shadow strength on the key light (0 = off)
uniform float cloud_shadow_offset = 0.04;         // how far the shadow slides away from the cloud, towards the sun (cloud height)
uniform float cloud_speed = 0.003;                // keep equal to the cloud shell speed
uniform float cloud_scale = 1.0;
uniform float cloud_alpha = 0.9;
uniform bool use_disp = false;
uniform bool use_glow_mask = false;
uniform bool use_lights_mask = false;
uniform float relief = 0.6;                           // relief strength: how far the height gradient bends the key-light normal
uniform float disp_amount = 0.0;                 // vertex displacement along the normal, in planet radii (total range, centred on 0)
uniform float term_shift = 0.45;                  // height moves the terminator: high ground keeps the sun longer (0 = off)
uniform float relief_shade = 0.75;                 // cavity shading: low ground is darkened by this much (0 = off)
uniform float disp_mid = 0.3;                      // typical height of the shipped maps (mean grey is 0.27 to 0.32, not 0.5): the zero point of cavity and terminator shift
uniform vec4 glow_col : source_color = vec4(0.60, 0.75, 1.00, 1.0);
uniform float glow_mask_strength = 1.1;
uniform float lights_strength = 1.5;
uniform int variant : hint_range(0, 3) = 0;
uniform bool use_rim = true;
uniform vec4 deep_col : source_color = vec4(0.10, 0.07, 0.28, 1.0);
uniform vec4 mid_col : source_color = vec4(0.36, 0.22, 0.80, 1.0);
uniform vec4 pale_col : source_color = vec4(0.70, 0.62, 1.00, 1.0);
uniform vec3 key_dir = vec3(-0.5, 0.5, 0.7);      // object space, towards the sun
uniform vec4 key_color : source_color = vec4(1.00, 0.76, 0.42, 1.0);  // warm gold
uniform float key_strength = 1.4;
// T132: solar flare level from the 3D sun (0 calm, 1 peak). Set globally by game/fx/sun/sun_flare.gd.
global uniform float sun_flare;
uniform vec4 rim_color : source_color = vec4(0.37, 0.66, 1.00, 1.0);  // set from the planet colour (complementary hue) by planet_sphere.gd
uniform float rim_strength = 0.050625;
uniform float rim_power = 2.5;
uniform vec4 shadow_rim_color : source_color = vec4(0.37, 0.66, 1.00, 1.0);  // complement of the base colour (hue + 0.5), set by planet_sphere.gd
uniform float shadow_rim_strength = 0.05;  // weak rim on the side away from the sun (0 = off)
uniform float fres_strength = 0.2;                // Fresnel crescent brightness, every planet (the rim light does the far-side edge work)
uniform float fres_side = 0.0;                    // crescent start: sun-side dot where it begins to fade in (0 = half the limb, 0.6 = narrow sliver)
uniform float fres_power = 3.0;
uniform float shadow_darkness = 0.95;             // 0 = dark side keeps ambient, 1 = dark side is black
uniform float shadow_soft = 0.06;
uniform float ambient = 0.03;
uniform vec4 city_col : source_color = vec4(1.00, 0.82, 0.48, 1.0);
uniform float city_strength = 1.6;
uniform float tier_lights = 0.0;                  // T265: night-side city lights, density 0 (none) to 1; set per planet from the prosperity tier
uniform float tier_lights_gain = 1.0;             // brightness of those lights (bloom-safe, from data/balance.json)
uniform float grain_amount = 0.10;                // 10 percent grain over the final colour

uniform float edge_px = 10.0;                     // soft edge width in screen pixels (0 = hard edge)

varying vec3 obj_n;

// T265: procedural city lights. Hash grid on the sphere: a cell holds a light when its hash is under the density, and
// density is also modulated by a low-frequency cluster noise so lights gather into regions instead of a uniform dust.
float hash13(vec3 p) {
	p = fract(p * 0.1031);
	p += dot(p, p.zyx + 31.32);
	return fract((p.x + p.y) * p.z);
}
float cluster_noise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix(hash13(i), hash13(i + vec3(1, 0, 0)), f.x), mix(hash13(i + vec3(0, 1, 0)), hash13(i + vec3(1, 1, 0)), f.x), f.y),
		mix(mix(hash13(i + vec3(0, 0, 1)), hash13(i + vec3(1, 0, 1)), f.x), mix(hash13(i + vec3(0, 1, 1)), hash13(i + vec3(1, 1, 1)), f.x), f.y), f.z);
}
float city_light_field(vec3 n, float density) {
	const float GRID = 46.0;
	vec3 p = n * GRID;
	vec3 id = floor(p);
	vec3 f = fract(p) - 0.5;
	float h = hash13(id);
	vec3 jitter = vec3(hash13(id + 7.1), hash13(id + 13.7), hash13(id + 19.3)) - 0.5;
	float region = mix(1.0, smoothstep(0.25, 0.75, cluster_noise(n * 4.0 + 3.0)) * 1.8, min(density * 4.0, 1.0));
	float on = step(h, density * region);
	float d = length(f - jitter * 0.5);
	return on * smoothstep(0.34, 0.05, d);
}

void vertex() {
	vec3 n0 = normalize(VERTEX);
	obj_n = n0;  // the fragment stage works from the true sphere normal
	if (use_disp && disp_amount > 0.0) {  // off by default (disp_amount = 0): the mesh stays a true sphere
		// Vertex displacement: the height map (centred on mid grey) pushes the vertex along the normal, so the
		// silhouette and the terminator edge get bumps. Lod 1 keeps it smooth on the 128 x 64 mesh.
		vec2 uv = vec2(atan(n0.x, n0.z) / TAU + 0.5, acos(clamp(n0.y, -1.0, 1.0)) / PI);
		float h = textureLod(disp_tex, uv, 1.0).r;
		VERTEX = n0 * length(VERTEX) * (1.0 + (h - 0.5) * disp_amount);  // keep the mesh radius (the planet is halved in the scene)
	}
}

void fragment() {
	vec3 n = normalize(obj_n);
	// Equirect UV from the normal, with derivatives fixed at the atan wrap so there is no seam line.
	vec2 uv = vec2(atan(n.x, n.z) / TAU + 0.5, acos(clamp(n.y, -1.0, 1.0)) / PI);
	vec2 dx = dFdx(uv);
	vec2 dy = dFdy(uv);
	if (abs(dx.x) > 0.5) dx.x -= sign(dx.x);
	if (abs(dy.x) > 0.5) dy.x -= sign(dy.x);
	vec4 tex = textureGrad(surface_tex, uv, dx, dy);
	float tone = tex.r;

	// Displacement: the height map bends the normal (bumps catch the sun, slopes away from it fall dark) and
	// darkens the low ground. Two offset samples give the gradient in the east and north directions.
	vec3 nb = n;
	float cavity = 1.0;
	float hshift = 0.0;  // height-driven terminator shift
	if (use_disp) {
		const float EPS = 0.0025;
		float h0 = textureGrad(disp_tex, uv, dx, dy).r;
		float hu = textureGrad(disp_tex, uv + vec2(EPS, 0.0), dx, dy).r - textureGrad(disp_tex, uv - vec2(EPS, 0.0), dx, dy).r;
		float hv = textureGrad(disp_tex, uv + vec2(0.0, EPS), dx, dy).r - textureGrad(disp_tex, uv - vec2(0.0, EPS), dx, dy).r;
		vec3 east = normalize(cross(vec3(0.0, 1.0, 0.0), n) + vec3(1e-4, 0.0, 0.0));
		vec3 south = cross(n, east);  // v grows towards the south pole
		nb = normalize(n - relief * (hu * east + hv * south));
		hshift = (h0 - disp_mid) * term_shift;  // centred on the map's own mean, so an average texel does not shift or darken
		cavity = 1.0 - relief_shade * (1.0 - smoothstep(0.0, disp_mid, h0));  // 1.0 at an average texel, darker only in real pits
	}

	float NdV = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	// Fresnel crescent: the limb glow only on the sun side, fading to nothing across the rest of the planet (like a moon edge).
	// side = sun-facing weight from the terminator (dot(normal, sun)); squared so the horns taper to nothing, 0 on the far side.
	// The edge is also thicker where side is high (lower power) and thins towards the horns.
	float side = smoothstep(fres_side, fres_side + 0.6, dot(n, normalize(key_dir)));
	side *= side;
	float fres = pow(1.0 - NdV, fres_power * mix(1.8, 0.8, side)) * fres_strength * side;

	vec3 col;
	if (variant == 1) {
		// Fresnel only: no surface detail, just the edge (added below).
		col = deep_col.rgb * 0.04;
	} else {
		vec3 base;
		if (use_beauty) {
			base = pow(tex.rgb, vec3(2.2));  // beauty colour map as albedo, no palette tint (png is sRGB, the sampler is not)
		} else if (variant == 3) {
			base = pale_col.rgb * (0.80 + 0.20 * tone);
		} else {
			base = mix(deep_col.rgb, mid_col.rgb, tone);
			base = mix(base, pale_col.rgb, smoothstep(0.7, 1.0, tone) * 0.35);
		}

		// Key light: sun side only, with a crisp shadow contour on the terminator.
		float nk = dot(nb, normalize(key_dir)) + hshift;
		float lit = smoothstep(-shadow_soft, shadow_soft, nk);
		// Cloud shadow: a cloud at height h throws its shadow away from the sun, so the shadow at this point is the
		// cloud found a step towards the sun (tangent part of key_dir). One texture sample, lod 1 (no wrap seam).
		float cshade = 1.0;
		if (use_cloud_shadow) {
			vec3 kd = normalize(key_dir);
			vec3 sn = normalize(n + (kd - n * dot(kd, n)) * cloud_shadow_offset);
			vec2 suv = vec2(atan(sn.x, sn.z) / TAU + 0.5 + TIME * cloud_speed, acos(clamp(sn.y, -1.0, 1.0)) / PI);
			float cc = smoothstep(0.05, 0.85, textureLod(cloud_tex, suv * cloud_scale, 1.0).r) * cloud_alpha;
			cshade = 1.0 - cloud_shadow * cc;
		}
		vec3 key = key_color.rgb * key_strength * (1.0 + 0.6 * sun_flare) * pow(max(nk, 0.0), 0.6) * lit * cshade;
		float amb = ambient * (1.0 - shadow_darkness);
		col = base * (amb + key) * cavity;

		if (variant == 2) {
			// City lights on the dark side (not in the distribution: 0%).
			float fine = textureGrad(fine_tex, uv, dx, dy).b;
			col = mix(col, city_col.rgb * city_strength, smoothstep(0.80, 0.92, fine) * (1.0 - lit));
		}

		// T265: tier city lights on the dark side only (none while tier_lights is 0).
		if (tier_lights > 0.0005) {
			float night = 1.0 - smoothstep(-0.04, 0.14, nk);
			col += city_col.rgb * city_light_field(n, tier_lights) * night * tier_lights_gain;
		}

		// Rim light: same moon-like crescent shape as the Fresnel (same side weight, falloff and thickness), added
		// (not multiplied) so the edge stays visible. Uses fres_side and fres_power so the two always match.
		if (use_rim) {
			col += rim_color.rgb * rim_strength * pow(1.0 - NdV, fres_power * mix(1.8, 0.8, side)) * side;
		}
	}

	// Fresnel crescent: a separate term, on every planet, key-only ones included.
	col += pale_col.rgb * fres;

	// Shadow-side rim: weak Fresnel edge in the complementary colour, only where the sun dot is below about zero.
	float dark = 1.0 - smoothstep(-0.3, 0.1, dot(n, normalize(key_dir)));
	col += shadow_rim_color.rgb * shadow_rim_strength * pow(1.0 - NdV, 3.0) * dark;

	// Grain: +/- grain_amount on the final colour, from a hash of the screen pixel.
	float g = fract(sin(dot(FRAGCOORD.xy, vec2(12.9898, 78.233))) * 43758.5453);
	col *= 1.0 + (g - 0.5) * 2.0 * grain_amount;
	// Soft edge. Distance from the limb in screen pixels: planet radius minus the fragment's distance from the centre
	// (view space), divided by the size of one pixel at this depth (perspective or orthographic camera).
	float edge_a = 1.0;
	if (edge_px > 0.0) {
		float pix = (PROJECTION_MATRIX[3][3] > 0.5) ? 2.0 / (PROJECTION_MATRIX[1][1] * VIEWPORT_SIZE.y) : -VERTEX.z * 2.0 / (PROJECTION_MATRIX[1][1] * VIEWPORT_SIZE.y);
		vec3 centre = (VIEW_MATRIX * MODEL_MATRIX[3]).xyz;
		float radius = length(MODEL_MATRIX[0].xyz) * 0.5;  // mesh radius is 0.5
		float d_px = (radius - length(VERTEX.xy - centre.xy)) / pix;
		edge_a = smoothstep(0.0, 1.0, d_px / edge_px);
	}
	ALPHA = edge_a;
	ALBEDO = use_beauty ? min(col, vec3(2.0)) : clamp(col, 0.0, 1.0);  // beauty path may carry HDR emission
}
