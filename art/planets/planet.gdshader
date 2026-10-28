shader_type spatial;
render_mode cull_back;
// One shader for all planet types. Height map displaces a sphere mesh; palette via uniforms.
uniform sampler2D height_tex : filter_linear, repeat_enable;
uniform vec4 base_col : source_color;
uniform vec4 plate_col : source_color;
uniform vec4 crack_col : source_color;
uniform vec4 rim_col : source_color;
uniform float plate_thr = 0.5;
uniform float glow = 0.0;
uniform float disp = 0.07;
uniform float rim_pow = 2.2;
varying float v_h;
varying float v_crack;

vec2 dir_uv(vec3 n) { return vec2(atan(n.x, n.z) / TAU + 0.5, acos(clamp(n.y, -1.0, 1.0)) / PI); }
float hgt(vec3 n) { return texture(height_tex, dir_uv(n)).r; }

void vertex() {
	vec3 n = normalize(VERTEX);
	vec4 t = textureLod(height_tex, dir_uv(n), 0.0);
	v_h = t.r; v_crack = t.g;
	float r = 1.0 + (t.r - 0.3) * disp * 2.0;
	vec3 up = abs(n.y) > 0.95 ? vec3(1, 0, 0) : vec3(0, 1, 0);
	vec3 tg = normalize(cross(up, n)); vec3 bt = cross(n, tg);
	float e = 0.02;
	float hx1 = (textureLod(height_tex, dir_uv(normalize(n + tg * e)), 0.0).r - 0.3) * disp * 2.0;
	float hx0 = (textureLod(height_tex, dir_uv(normalize(n - tg * e)), 0.0).r - 0.3) * disp * 2.0;
	float hy1 = (textureLod(height_tex, dir_uv(normalize(n + bt * e)), 0.0).r - 0.3) * disp * 2.0;
	float hy0 = (textureLod(height_tex, dir_uv(normalize(n - bt * e)), 0.0).r - 0.3) * disp * 2.0;
	NORMAL = normalize(n - tg * (hx1 - hx0) / (2.0 * e) - bt * (hy1 - hy0) / (2.0 * e));
	VERTEX = n * r;
}

void fragment() {
	float pm = smoothstep(plate_thr - 0.03, plate_thr + 0.03, v_h);
	vec3 col = mix(base_col.rgb, plate_col.rgb, pm);
	// shade slightly darker in low ground
	col *= 0.8 + 0.4 * v_h;
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_pow);
	col = mix(col, rim_col.rgb, clamp(fres * 1.1, 0.0, 1.0));
	ALBEDO = col;
	ROUGHNESS = 0.9;
	float c = v_crack * (1.0 - pm) * glow;
	EMISSION = crack_col.rgb * c * (1.0 - fres) + plate_col.rgb * pm * glow * 0.25 * (1.0 - fres);
}
