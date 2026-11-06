shader_type spatial;
render_mode unshaded, blend_premul_alpha, cull_back, depth_draw_never;
// Cloud shell: a sphere just above the surface (about 1.02 of the body radius). The texture has no alpha channel (white clouds
// on black), so it is a light mask and the shell is screen-blended: blend_premul_alpha gives out = src + dst * (1 - a) with
// src = lit colour * a, i.e. screen with a scalar mask. Black cloud texels add nothing, the planet texture shows through. The UV slides along the equator with TIME (speed), so the clouds drift over the body.
// Lit by key_dir with the same sun-side gate as the Fresnel crescent, so the night side is nearly dark and it does not look flat.
// The body shader (planet_sphere.gdshader) samples the same texture with the same speed and scale to cast the cloud shadows.
uniform sampler2D cloud_tex : filter_linear_mipmap, repeat_enable;
uniform vec3 key_dir = vec3(-0.5, 0.5, 0.7);
uniform vec4 key_color : source_color = vec4(1.00, 0.76, 0.42, 1.0);
uniform vec4 cloud_col : source_color = vec4(1.0, 1.0, 1.0, 1.0);  // cloud body tint
uniform float speed = 0.003;                   // uv per second (about 5.5 minutes per lap); negative drifts the other way
uniform float alpha = 0.9;                     // overall cloud opacity
uniform float cloud_scale = 1.0;               // texture repeats; keep whole numbers so the wrap seam stays closed
uniform float fres_side = 0.0;                 // same crescent gate as the body
uniform float ambient = 0.05;                  // night-side visibility

varying vec3 obj_n;

void vertex() {
	obj_n = normalize(VERTEX);
}

void fragment() {
	vec3 n = normalize(obj_n);
	vec2 uv = vec2(atan(n.x, n.z) / TAU + 0.5, acos(clamp(n.y, -1.0, 1.0)) / PI);
	vec2 dx = dFdx(uv);
	vec2 dy = dFdy(uv);
	if (abs(dx.x) > 0.5) dx.x -= sign(dx.x);
	if (abs(dy.x) > 0.5) dy.x -= sign(dy.x);
	vec2 cuv = (uv + vec2(TIME * speed, 0.0)) * cloud_scale;
	float c = textureGrad(cloud_tex, cuv, dx * cloud_scale, dy * cloud_scale).r;
	float a = smoothstep(0.05, 0.85, c) * alpha;
	// Sun-side gate: bright towards the sun, a soft wrap across the terminator, a little ambient on the night side.
	float nk = dot(n, normalize(key_dir));
	float side = smoothstep(fres_side - 0.25, fres_side + 0.6, nk);
	vec3 lit = cloud_col.rgb * mix(vec3(ambient), key_color.rgb * 1.1 + 0.25, side);
	ALBEDO = lit * a;  // premultiplied: screen-style, dark mask = no change to the surface below
	ALPHA = a;
}
