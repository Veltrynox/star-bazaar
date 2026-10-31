shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;
// T132 (layers): one flat grid plane of the sun. The sun is a shell of these planes, each turned to its own
// yaw and pitch. Each plane crops its own part of the animated frame (uv_center, uv_scale, uv_rot) and plays
// the frames of its own sheet (layer_base) at its own phase, so no two planes show the same picture. Additive blend: the black of the frame
// adds nothing, the flares add light. A round fade hides the square edge of the plane.
// The same shader draws the white core (core_on = 1): one camera-facing quad at the centre, brighter than 1.0 so
// the scene glow picks it up; it fades out radially and covers the plane grid near the centre.

const float CORE_RADIUS = 0.663; // (was 0.442, x1.5: wider glow, same peak)   // where the core reaches zero, 0..1 of the quad half-size (the sun disc edge is about 0.7)
const float SHEET_CONTRAST = 1.1; // sheet contrast around mid-grey 0.5: (c - 0.5) * k + 0.5, clamped at 0 (black stays black)
const float PLANE_FADE_START = 0.605; // (was 0.55, x1.1) plane stays full strength out to here; the fade ends at the quad edge, 1.0
const float CORE_FALLOFF = 1.8;   // fade curve: 1 = linear, higher = tighter bright centre

uniform sampler2DArray frames : filter_linear, repeat_disable;
uniform float frame_pos = 0.0;   // current frame, 0..64 (fractional)
uniform float layer_base = 0.0;  // first layer of this plane's sheet (sheet index * 64)
uniform float phase = 0.0;       // frame offset of this plane
uniform vec2 uv_center = vec2(0.5);
uniform float uv_scale = 0.6;    // part of the frame this plane shows (1 = whole frame)
uniform float uv_rot = 0.0;      // turn of the crop, radians
uniform float core_on = 0.0;     // 1 = this quad is the white core, not a plane
uniform float core_value = 3.0;  // core brightness at the centre (white, above 1.0 = HDR glow)
uniform float glow = 0.4;        // per-plane brightness; planes add up, so keep it low (set from sun_flare.gd)

void vertex() {
	if (core_on > 0.5) {  // face the camera
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	}
}

// One plane's colour at plane position p (-0.5..0.5), r = 0..1 from the centre.
vec3 plane_color(vec2 p, float r) {
	float fade = 1.0 - smoothstep(PLANE_FADE_START, 1.0, r);        // round soft edge
	float c = cos(uv_rot);
	float s = sin(uv_rot);
	vec2 q = vec2(p.x * c - p.y * s, p.x * s + p.y * c);
	vec2 uv = uv_center + q * uv_scale;
	float f = mod(frame_pos + phase, 64.0);
	float f0 = floor(f);
	float f1 = mod(f0 + 1.0, 64.0);
	float t = f - f0;                                  // linear blend: even speed at the slow rate
	vec3 a = texture(frames, vec3(uv, layer_base + f0)).rgb;
	vec3 b = texture(frames, vec3(uv, layer_base + f1)).rgb;
	a = max((a - 0.5) * SHEET_CONTRAST + 0.5, 0.0);
	b = max((b - 0.5) * SHEET_CONTRAST + 0.5, 0.0);
	return mix(a, b, t) * glow * fade;   // planes add up, so overlaps go above 1.0 into the HDR glow
}

void fragment() {
	vec2 p = UV - 0.5;
	float r = length(p) * 2.0;
	if (core_on > 0.5) {
		float k = pow(1.0 - smoothstep(0.0, CORE_RADIUS, r), CORE_FALLOFF);
		ALBEDO = vec3(core_value * k);
	} else {
		ALBEDO = plane_color(p, r);
	}
}
