shader_type spatial;
render_mode unshaded, cull_back, depth_draw_opaque;
// Planet surface on a sphere mesh. UVs come from the surface normal (equirect), so the texture is fixed on the sphere
// and does not move with the camera. The surface texture is greyscale: its brightness is the tone, tinted with the
// palette (deep, mid, pale). The key light (sun side) and the rim light (side opposite the sun) are separate terms,
// and the Fresnel edge is a soft crescent on the sun side only.
// Looks (variant): 0 standard, 1 fresnel_only, 2 city (0% of planets, uses fine_tex), 3 pale (lighter palette).
// Beauty path (use_beauty): the texture is a colour map, used as albedo with no palette tint. The displacement map moves the
// vertices (silhouette), bends the normal (bump) and shifts the terminator (high ground keeps the sun longer). Optional glow mask (emission on both sides, soft pulse)
// and lights mask (dark side only, small warm twinkle). Emission stays under about 2.0 (bloom-safe).
// Unshaded, so the final colour is written to ALBEDO directly.

uniform sampler2D surface_tex : filter_linear_mipmap, repeat_enable;  // greyscale surface, set per planet from the texture list
uniform sampler2D fine_tex : filter_linear_mipmap, repeat_enable;     // old generated tone map: B = fine grain (city specks only)
uniform bool use_beauty = false;                  // true: surface_tex is a colour map (per-type table in planet_sphere.gd)
uniform sampler2D disp_tex : filter_linear_mipmap, repeat_enable;     // greyscale height, relief on the key light
uniform sampler2D glow_tex : filter_linear_mipmap, repeat_enable;     // white streaks on black, emission
uniform sampler2D lights_tex : filter_linear_mipmap, repeat_enable;   // white city lights on black, dark side only
uniform bool use_disp = false;
uniform bool use_glow_mask = false;
uniform bool use_lights_mask = false;
uniform float relief = 20.0;                      // relief strength: how far the height gradient bends the key-light normal
uniform float disp_amount = 0.03;               // vertex displacement along the normal, in planet radii (total range, centred on 0)
uniform float term_shift = 0.45;                  // height moves the terminator: high ground keeps the sun longer (0 = off)
uniform float relief_shade = 0.75;                 // cavity shading: low ground is darkened by this much (0 = off)
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
// T132: solar flare level from the 3D sun (0 calm, 1 peak). Set globally by art/sun/sun_flare.gd.
global uniform float sun_flare;
uniform vec4 rim_color : source_color = vec4(0.37, 0.66, 1.00, 1.0);  // set from the planet colour (complementary hue) by planet_sphere.gd
uniform float rim_strength = 0.050625;
uniform float rim_power = 2.5;
uniform float fres_strength = 0.2;                // Fresnel crescent brightness, every planet (the rim light does the far-side edge work)
uniform float fres_side = 0.0;                    // crescent start: sun-side dot where it begins to fade in (0 = half the limb, 0.6 = narrow sliver)
uniform float fres_power = 3.0;
uniform float shadow_darkness = 0.95;             // 0 = dark side keeps ambient, 1 = dark side is black
uniform float shadow_soft = 0.06;
uniform float ambient = 0.03;
uniform vec4 city_col : source_color = vec4(1.00, 0.82, 0.48, 1.0);
uniform float city_strength = 1.6;
uniform float grain_amount = 0.10;                // 10 percent grain over the final colour

varying vec3 obj_n;

void vertex() {
	vec3 n0 = normalize(VERTEX);
	obj_n = n0;  // the fragment stage works from the true sphere normal
	if (use_disp) {
		// Vertex displacement: the height map (centred on mid grey) pushes the vertex along the normal, so the
		// silhouette and the terminator edge get bumps. Lod 1 keeps it smooth on the 128 x 64 mesh.
		vec2 uv = vec2(atan(n0.x, n0.z) / TAU + 0.5, acos(clamp(n0.y, -1.0, 1.0)) / PI);
		float h = textureLod(disp_tex, uv, 1.0).r;
		VERTEX = n0 * (1.0 + (h - 0.5) * disp_amount);
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
		hshift = (h0 - 0.5) * term_shift;
		cavity = 1.0 - relief_shade * (1.0 - smoothstep(0.1, 0.8, h0));
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
		if (variant == 3) {
			base = pale_col.rgb * (0.80 + 0.20 * tone);
		} else {
			base = mix(deep_col.rgb, mid_col.rgb, tone);
			base = mix(base, pale_col.rgb, smoothstep(0.7, 1.0, tone) * 0.35);
		}

		// Key light: sun side only, with a crisp shadow contour on the terminator.
		float nk = dot(nb, normalize(key_dir)) + hshift;
		float lit = smoothstep(-shadow_soft, shadow_soft, nk);
		vec3 key = key_color.rgb * key_strength * (1.0 + 0.6 * sun_flare) * pow(max(nk, 0.0), 0.6) * lit;
		float amb = ambient * (1.0 - shadow_darkness);
		col = base * (amb + key) * cavity;

		if (variant == 2) {
			// City lights on the dark side (not in the distribution: 0%).
			float fine = textureGrad(fine_tex, uv, dx, dy).b;
			col = mix(col, city_col.rgb * city_strength, smoothstep(0.80, 0.92, fine) * (1.0 - lit));
		}

		// Rim light: separate far-side light, added (not multiplied) so the dark side keeps a visible edge.
		if (use_rim) {
			float nr = dot(n, -normalize(key_dir));  // the rim sits opposite the sun
			float far = smoothstep(-0.2, 0.8, nr);
			col += rim_color.rgb * rim_strength * far * pow(1.0 - NdV, rim_power);
		}
	}

	// Fresnel crescent: a separate term, on every planet, key-only ones included.
	col += pale_col.rgb * fres;

	// Grain: +/- grain_amount on the final colour, from a hash of the screen pixel.
	float g = fract(sin(dot(FRAGCOORD.xy, vec2(12.9898, 78.233))) * 43758.5453);
	col *= 1.0 + (g - 0.5) * 2.0 * grain_amount;
	ALBEDO = use_beauty ? min(col, vec3(2.0)) : clamp(col, 0.0, 1.0);  // beauty path may carry HDR emission
}
