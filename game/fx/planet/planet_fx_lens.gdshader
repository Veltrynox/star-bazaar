shader_type canvas_item;
render_mode blend_add;
// Sun lens: a soft glint at the sun, ghosts on the far side of the planet from the sun,
// and a thin flare along the sun axis on that far side. Additive, so values above 1.0 bloom.
// Ghost and flare sit opposite the sun, as the owner asked. Drawn last, over every other layer.
uniform vec2 sun_dir = vec2(-0.6, -0.8);   // keep equal to the body's sun_dir
uniform float ext = 3.5;                   // quad half-size in planet radii
uniform float sun_dist = 2.2;              // sun glint distance from the planet centre, in planet radii
uniform float sun_glint = 1.2;             // brightness of the sun glint
uniform vec4 lens_col : source_color = vec4(0.60, 0.50, 1.00, 1.0);
uniform vec4 ghost_col : source_color = vec4(0.45, 0.75, 1.00, 1.0);
uniform float ghost_strength = 0.35;
uniform float flare_strength = 0.6;
uniform float rarity = 0.0;                 // 0 common, 1 rarest: more glint, ghost and flare (set by planet_fx.gd)

float soft_disc(vec2 p, vec2 c, float r) {
	return 1.0 - smoothstep(r * 0.5, r, length(p - c));
}

void fragment() {
	float gs = ghost_strength * (1.0 + 1.5 * rarity);
	vec2 p = (UV - 0.5) * 2.0 * ext;
	vec2 n_s = normalize(sun_dir);
	vec2 perp = vec2(-n_s.y, n_s.x);
	vec3 col = vec3(0.0);

	// Sun glint: a soft core and a cross-shaped starburst.
	vec2 dp = p - n_s * sun_dist;
	float core = 0.015 / (dot(dp, dp) + 0.015);
	float star = exp(-abs(dp.x) * 6.0) * exp(-abs(dp.y) * 60.0) + exp(-abs(dp.y) * 6.0) * exp(-abs(dp.x) * 60.0);
	col += lens_col.rgb * (core + star * 0.4) * sun_glint * (1.0 + rarity);

	// Ghosts: soft discs on the far side, mirrored through the planet centre.
	col += ghost_col.rgb * soft_disc(p, -n_s * sun_dist * 0.35, 0.10) * gs;
	col += lens_col.rgb * soft_disc(p, -n_s * sun_dist * 0.60, 0.18) * gs * 0.7;
	col += ghost_col.rgb * soft_disc(p, -n_s * sun_dist * 0.85, 0.30) * gs * 0.5;

	// Flare: a thin line along the sun axis, only on the far side, fading with distance.
	float along = dot(p, n_s);
	float across = abs(dot(p, perp));
	float far = clamp(-along, 0.0, 1.0) * exp(along * 0.7);
	col += lens_col.rgb * exp(-across * 35.0) * far * flare_strength * (1.0 + rarity);

	COLOR = vec4(col, 1.0);
}
