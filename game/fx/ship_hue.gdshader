shader_type spatial;
render_mode cull_back;
// Ship hue (T356): reproduces the GLB's StandardMaterial3D (albedo texture x albedo colour, normal map, roughness, metallic) and turns
// the hue of the albedo by `hue` (0..1 = one full turn) before lighting. game/ship_look.gd builds one ShaderMaterial per
// (source material, hue) and fills these uniforms from the original; a cull_disabled twin is made from this source when the original was two-sided.
uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform sampler2D normal_tex : hint_normal, filter_linear_mipmap, repeat_enable;
uniform bool use_normal = false;
uniform float normal_scale = 1.0;
uniform float roughness = 1.0;
uniform float metallic = 0.0;
uniform float hue : hint_range(0.0, 1.0) = 0.0;
uniform vec3 uv_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv_offset = vec3(0.0);

vec3 hue_turn(vec3 c, float h) {
	// rotation about the grey axis (keeps luminance roughly), h in turns
	float a = h * 6.28318530718;
	float ca = cos(a);
	float sa = sin(a);
	const vec3 k = vec3(0.57735026919);
	return c * ca + cross(k, c) * sa + k * dot(k, c) * (1.0 - ca);
}

void fragment() {
	vec2 uv = UV * uv_scale.xy + uv_offset.xy;
	vec4 tex = texture(albedo_tex, uv) * albedo_color;
	ALBEDO = clamp(hue_turn(tex.rgb, hue), 0.0, 1.0);
	ROUGHNESS = roughness;
	METALLIC = metallic;
	if (use_normal) {
		NORMAL_MAP = texture(normal_tex, uv).rgb;
		NORMAL_MAP_DEPTH = normal_scale;
	}
}
