shader_type spatial;
render_mode cull_back;
// Planet v2. One shader for all types. Height map (R height, G crack, B cell tone) displaces a sphere
// a little (silhouette) and gives per-pixel normals (sharp plate edges, crater rims). Layer colours come
// from height thresholds: col_a low, col_b plate, col_c raised, col_d top. col_e = accent patches.
uniform sampler2D height_tex : filter_linear, repeat_enable;
uniform vec4 col_a : source_color;
uniform vec4 col_b : source_color;
uniform vec4 col_c : source_color;
uniform vec4 col_d : source_color;
uniform vec4 col_e : source_color;
uniform vec4 crack_col : source_color;
uniform vec4 crack_hot : source_color;
uniform vec4 rim_col : source_color;
uniform vec3 thr = vec3(0.31, 0.49, 0.64);
uniform vec2 acc_range = vec2(0.0, 0.31);
uniform float acc_amt = 0.8;
uniform float pole_frost = 0.0;
uniform float glow = 0.0;
uniform float crack_dark = 0.0;
uniform float bump = 1.0;
uniform float disp = 0.06;
varying vec3 v_dir;

vec2 dir_uv(vec3 n) { return vec2(atan(n.x, n.z) / TAU + 0.5, acos(clamp(n.y, -1.0, 1.0)) / PI); }
float hgt(vec3 n) { return texture(height_tex, dir_uv(normalize(n))).r; }

void vertex() {
	vec3 n = normalize(VERTEX);
	v_dir = n;
	float h = textureLod(height_tex, dir_uv(n), 0.0).r;
	VERTEX = n * (1.0 + (h - 0.3) * disp * 2.0);
}

void fragment() {
	vec3 n = normalize(v_dir);
	vec4 t = texture(height_tex, dir_uv(n));
	float h = t.r;
	vec3 up = abs(n.y) > 0.95 ? vec3(1, 0, 0) : vec3(0, 1, 0);
	vec3 tg = normalize(cross(up, n)); vec3 bt = cross(n, tg);
	float e = 0.012;
	float h1 = hgt(n + tg * e); float h0 = hgt(n - tg * e);
	float v1 = hgt(n + bt * e); float v0 = hgt(n - bt * e);
	float amp = disp * 2.0 * bump * 2.2;
	vec3 nl = normalize(n - tg * (h1 - h0) * amp / (2.0 * e) - bt * (v1 - v0) * amp / (2.0 * e));
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(nl, 0.0)).xyz);

	float w1 = smoothstep(thr.x - 0.018, thr.x + 0.018, h);
	float w2 = smoothstep(thr.y - 0.018, thr.y + 0.018, h);
	float w3 = smoothstep(thr.z - 0.018, thr.z + 0.018, h);
	vec3 col = mix(mix(mix(col_a.rgb, col_b.rgb, w1), col_c.rgb, w2), col_d.rgb, w3);
	float am = smoothstep(acc_range.x - 0.02, acc_range.x + 0.02, h) * (1.0 - smoothstep(acc_range.y - 0.02, acc_range.y + 0.02, h));
	am *= smoothstep(0.70, 0.74, t.b) * acc_amt;
	col = mix(col, col_e.rgb, am);
	float pole = smoothstep(0.80, 0.84, abs(n.y) + (t.b - 0.5) * 0.12 + (h - 0.4) * 0.3) * pole_frost;
	col = mix(col, col_d.rgb, pole);
	col *= 0.84 + 0.32 * t.b;
	float avg = (h1 + h0 + v1 + v0) * 0.25;
	col *= (1.0 - min(0.45, max(avg - h, 0.0) * 8.0)) * (1.0 + min(0.5, max(h - avg, 0.0) * 10.0));
	col = mix(col, crack_col.rgb, t.g * crack_dark);
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.2);
	col = mix(col, rim_col.rgb, clamp(fres, 0.0, 1.0));
	ALBEDO = col;
	ROUGHNESS = 0.9;
	vec3 ec = mix(crack_col.rgb, crack_hot.rgb, t.g * t.g * t.g);
	EMISSION = (ec * t.g * glow + col_d.rgb * w3 * 0.10 * step(0.001, glow)) * (1.0 - fres);
}
