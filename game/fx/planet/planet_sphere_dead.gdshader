shader_type spatial;
render_mode unshaded, blend_mix, cull_back, depth_draw_always;
// Dead planet body (Cinderrest, Greywake): beauty map as albedo with an INVERSE Fresnel.
// The limb does not glow like the atmosphere of the living planets: it absorbs light (dark, matte), with only a thin dim rim on the sun side.
// Same conventions as planet_sphere_simple.gdshader: unshaded, equirect UV from the object-space normal (no seam), key_dir towards the sun,
// soft terminator with an ambient floor. No atmosphere shell, no clouds, no glow. Sun direction key_dir is set by planet_sphere.gd (aim_sun).

uniform sampler2D surface_tex : source_color, filter_linear_mipmap, repeat_enable;  // planet_toxic_beauty.png
uniform vec3 key_dir = vec3(-0.5, 0.5, 0.7);   // object space, towards the sun
uniform float uv_shift = 0.0;                  // variant: turns the map around the pole (0..1) so two worlds show other terrain
uniform float hue_shift = 0.0;                 // variant: hue rotation in turns (0.5 = opposite hue)
uniform float saturation = 1.0;                // variant: 1 = the texture colour
uniform float brightness = 1.0;                // variant: overall lit brightness
uniform float shadow_ambient = 0.006;          // LINEAR floor of the night side (same meaning as the simple shader)
uniform float term_soft = 0.30;                // terminator softness in dot(n, sun)
uniform float limb_dark = 0.92;                // how much of the colour the limb absorbs at the very edge (0 = none, 1 = black)
uniform float limb_power = 2.2;                // falloff of the dark limb: higher keeps the dark band thin
uniform vec4 rim_color : source_color = vec4(0.55, 0.50, 0.46, 1.0);  // thin dim rim: warm grey, no atmosphere colour
uniform float rim_strength = 0.10;             // dim: well under 1.0, no HDR glow
uniform float rim_width = 0.08;                // rim thickness in (1 - N.V) units, taken from the very edge inwards

// T297 reclaim. All values are pushed by planet_sphere.gd from data/balance.json (reclaim_* keys, placeholders); the defaults here only keep the shader valid.
uniform sampler2D living_tex : source_color, filter_linear_mipmap, repeat_enable;  // the living look the green wave reveals (lush beauty map)
uniform float reclaim = 0.0;                   // 0..1 reclaim progress: green creeps over the surface as the ring fills
uniform float reclaim_tint = 0.0;              // largest share of green the creep reaches before the flip
uniform vec4 green_col : source_color = vec4(0.30, 0.62, 0.22, 1.0);
uniform float wave = 0.0;                      // flip: front position 0..1.2 across the surface (0 = no wave)
uniform vec3 wave_axis = vec3(0.35, 0.55, 0.75);  // object space, the front sweeps along it
uniform float wave_width = 0.12;               // softness of the front
uniform float haze = 0.0;                      // the nest's red haze at the limb (0 = none); fades as the ring fills
uniform vec4 haze_col : source_color = vec4(0.85, 0.15, 0.10, 1.0);

// Rotates the hue of a colour by t turns (YIQ rotation, cheap and hue-only).
vec3 hue_rot(vec3 c, float t) {
	float a = t * TAU;
	float cs = cos(a);
	float sn = sin(a);
	mat3 to_yiq = mat3(vec3(0.299, 0.596, 0.211), vec3(0.587, -0.274, -0.523), vec3(0.114, -0.322, 0.312));
	mat3 to_rgb = mat3(vec3(1.0, 1.0, 1.0), vec3(0.956, -0.272, -1.106), vec3(0.621, -0.647, 1.703));
	vec3 y = to_yiq * c;
	y.yz = vec2(y.y * cs - y.z * sn, y.y * sn + y.z * cs);
	return to_rgb * y;
}

void fragment() {
	// True sphere normal (the mesh is not inflated); N.V is 0 at the limb.
	vec3 vn = normalize(NORMAL);
	float NdV = clamp(dot(vn, VIEW), 0.0, 1.0);
	vec3 n = normalize(inverse(mat3(MODEL_MATRIX)) * (mat3(INV_VIEW_MATRIX) * vn));  // object space
	// Equirect UV, derivatives fixed at the atan wrap so there is no seam line.
	vec2 uv = vec2(atan(n.x, n.z) / TAU + 0.5, acos(clamp(n.y, -1.0, 1.0)) / PI);
	vec2 dx = dFdx(uv);
	vec2 dy = dFdy(uv);
	if (abs(dx.x) > 0.5) dx.x -= sign(dx.x);
	if (abs(dy.x) > 0.5) dy.x -= sign(dy.x);
	uv.x += uv_shift;  // repeat_enable wraps it
	vec3 col = textureGrad(surface_tex, uv, dx, dy).rgb;
	// Variant grade: hue turn, saturation, brightness.
	col = max(hue_rot(col, hue_shift), vec3(0.0));
	col = mix(vec3(dot(col, vec3(0.299, 0.587, 0.114))), col, saturation) * brightness;

	// Reclaim: green creeps in patches (dark ground last), then the wave front turns the surface into the living map.
	float lum0 = dot(col, vec3(0.299, 0.587, 0.114));
	float creep = smoothstep(0.0, 0.3, reclaim * 1.3 - (1.0 - clamp(lum0 * 2.0, 0.0, 1.0)) * 0.3) * reclaim_tint;
	col = mix(col, green_col.rgb * (0.35 + lum0 * 1.1), creep);
	float wd = dot(n, normalize(wave_axis)) * 0.5 + 0.5;
	float covered = wave > 0.0 ? 1.0 - smoothstep(wave - wave_width, wave, wd) : 0.0;
	vec3 live = textureGrad(living_tex, vec2(uv.x - uv_shift, uv.y), dx, dy).rgb;
	col = mix(col, live, covered);
	float front = wave > 0.0 && wave < 1.0 + wave_width ? exp(-pow((wd - wave) / (wave_width * 0.5), 2.0)) : 0.0;

	// Key light: soft terminator, never below the ambient floor.
	vec3 k = normalize(key_dir);
	float nk = dot(n, k);
	float lit = smoothstep(-term_soft * 0.5, term_soft, nk);
	col *= mix(shadow_ambient, 1.0, lit);

	// Inverse Fresnel: the edge absorbs light. 1 - N.V grows to 1 at the limb; the dark weight follows it by limb_power.
	float edge = 1.0 - NdV;
	float absorb = pow(edge, limb_power) * limb_dark * (1.0 - covered);
	col *= 1.0 - absorb;

	// Thin dim rim: a narrow band at the very edge, sun side only, so the disc still reads against space.
	float band = smoothstep(1.0 - rim_width, 1.0 - rim_width * 0.15, edge) * (1.0 - smoothstep(0.985, 1.0, edge));
	col += rim_color.rgb * rim_strength * band * lit;

	// The wave front glows; the nest's red haze sits at the limb and thins out with the reclaim.
	col += green_col.rgb * front * 0.9 * mix(0.5, 1.0, lit);
	col += haze_col.rgb * haze * pow(edge, 2.0) * 0.6;

	ALBEDO = min(col, vec3(1.0));  // nothing above 1.0: a dead world does not feed the HDR glow
}
