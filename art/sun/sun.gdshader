shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;
// T132 (layers): one flat grid plane of the sun. The sun is a shell of these planes, each turned to its own
// yaw and pitch. Each plane crops its own part of the animated frame (uv_center, uv_scale, uv_rot) and plays
// the frames at its own phase, so no two planes show the same picture. Additive blend: the black of the frame
// adds nothing, the flares add light. A round fade hides the square edge of the plane.

uniform sampler2DArray frames : filter_linear, repeat_disable;
uniform float frame_pos = 0.0;   // current frame, 0..64 (fractional)
uniform float phase = 0.0;       // frame offset of this plane
uniform vec2 uv_center = vec2(0.5);
uniform float uv_scale = 0.6;    // part of the frame this plane shows (1 = whole frame)
uniform float uv_rot = 0.0;      // turn of the crop, radians
uniform float glow = 0.55;       // per-plane brightness; planes add up, so keep it low

void fragment() {
	vec2 p = UV - 0.5;
	float r = length(p) * 2.0;
	float fade = 1.0 - smoothstep(0.55, 1.0, r);        // round soft edge
	float c = cos(uv_rot);
	float s = sin(uv_rot);
	vec2 q = vec2(p.x * c - p.y * s, p.x * s + p.y * c);
	vec2 uv = uv_center + q * uv_scale;
	float f = mod(frame_pos + phase, 64.0);
	float f0 = floor(f);
	float f1 = mod(f0 + 1.0, 64.0);
	float t = f - f0;
	vec3 a = texture(frames, vec3(uv, f0)).rgb;
	vec3 b = texture(frames, vec3(uv, f1)).rgb;
	ALBEDO = mix(a, b, t) * glow * fade;   // above 1.0 in the bright core goes to the HDR glow
}
