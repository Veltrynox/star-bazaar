shader_type spatial;
render_mode unshaded, cull_back, depth_draw_opaque;
// Planet surface on a sphere mesh. UVs come from the surface normal (equirect), so the texture is fixed on the sphere
// and does not move with the camera. The surface texture is greyscale: its brightness is the tone, tinted with the
// palette (deep, mid, pale). The key light (sun side) and the rim light (far side, optional) are separate terms,
// and the Fresnel edge is on every planet.
// Looks (variant): 0 standard, 1 fresnel_only, 2 city (0% of planets, uses fine_tex), 3 pale (lighter palette).
// Unshaded, so the final colour is written to ALBEDO directly.

uniform sampler2D surface_tex : filter_linear_mipmap, repeat_enable;  // greyscale surface, set per planet from the texture list
uniform sampler2D fine_tex : filter_linear_mipmap, repeat_enable;     // old generated tone map: B = fine grain (city specks only)
uniform int variant : hint_range(0, 3) = 0;
uniform bool use_rim = true;
uniform vec4 deep_col : source_color = vec4(0.10, 0.07, 0.28, 1.0);
uniform vec4 mid_col : source_color = vec4(0.36, 0.22, 0.80, 1.0);
uniform vec4 pale_col : source_color = vec4(0.70, 0.62, 1.00, 1.0);
uniform vec3 key_dir = vec3(-0.5, 0.5, 0.7);      // object space, towards the sun
uniform vec4 key_color : source_color = vec4(1.00, 0.76, 0.42, 1.0);  // warm gold
uniform float key_strength = 1.4;
uniform vec3 rim_dir = vec3(0.5, -0.3, -0.8);     // object space, towards the rim light (far side)
uniform vec4 rim_color : source_color = vec4(0.37, 0.66, 1.00, 1.0);  // cool complement of the gold; also the Fresnel tint
uniform float rim_strength = 1.2;
uniform float rim_power = 2.5;
uniform float fres_strength = 0.68;               // Fresnel edge, every planet
uniform float fres_power = 3.0;
uniform float shadow_darkness = 0.95;             // 0 = dark side keeps ambient, 1 = dark side is black
uniform float shadow_soft = 0.06;
uniform float ambient = 0.03;
uniform vec4 city_col : source_color = vec4(1.00, 0.82, 0.48, 1.0);
uniform float city_strength = 1.6;
uniform float grain_amount = 0.10;                // 10 percent grain over the final colour

varying vec3 obj_n;

void vertex() {
	obj_n = normalize(VERTEX);
}

void fragment() {
	vec3 n = normalize(obj_n);
	// Equirect UV from the normal, with derivatives fixed at the atan wrap so there is no seam line.
	vec2 uv = vec2(atan(n.x, n.z) / TAU + 0.5, acos(clamp(n.y, -1.0, 1.0)) / PI);
	vec2 dx = dFdx(uv);
	vec2 dy = dFdy(uv);
	if (abs(dx.x) > 0.5) dx.x -= sign(dx.x);
	if (abs(dy.x) > 0.5) dy.x -= sign(dy.x);
	float tone = textureGrad(surface_tex, uv, dx, dy).r;

	float NdV = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float fres = pow(1.0 - NdV, fres_power) * fres_strength;  // Fresnel edge: always on

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
		float nk = dot(n, normalize(key_dir));
		float lit = smoothstep(-shadow_soft, shadow_soft, nk);
		vec3 key = key_color.rgb * key_strength * pow(max(nk, 0.0), 0.6) * lit;
		float amb = ambient * (1.0 - shadow_darkness);
		col = base * (amb + key);

		if (variant == 2) {
			// City lights on the dark side (not in the distribution: 0%).
			float fine = textureGrad(fine_tex, uv, dx, dy).b;
			col = mix(col, city_col.rgb * city_strength, smoothstep(0.80, 0.92, fine) * (1.0 - lit));
		}

		// Rim light: separate far-side light, added (not multiplied) so the dark side keeps a visible edge.
		if (use_rim) {
			float nr = dot(n, normalize(rim_dir));
			float far = 0.25 + 0.75 * clamp(nr * 0.5 + 0.5, 0.0, 1.0);
			col += rim_color.rgb * rim_strength * far * pow(1.0 - NdV, rim_power);
		}
	}

	// Fresnel edge: a separate term, on every planet, key-only ones included.
	col += rim_color.rgb * fres;

	// Grain: +/- grain_amount on the final colour, from a hash of the screen pixel.
	float g = fract(sin(dot(FRAGCOORD.xy, vec2(12.9898, 78.233))) * 43758.5453);
	col *= 1.0 + (g - 0.5) * 2.0 * grain_amount;
	ALBEDO = clamp(col, 0.0, 1.0);
}
