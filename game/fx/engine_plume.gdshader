shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;
// Engine plume layer (port of blastFrag in tools/engine_tuner.html). The mesh is a capless CylinderMesh: Godot maps its side
// UV.y 0 at the top (nozzle) to 0.5 at the bottom (far end), so t doubles it to 0..1. One material per layer; `seed` is a per-instance uniform so every engine flickers on its own.
uniform vec3 col : source_color = vec3(1.0);
uniform float time = 0.0;
uniform float glow = 1.2;
uniform float flicker_k = 0.35;
uniform float layer_alpha = 1.0;
instance uniform float seed = 0.0;

void fragment() {
	float t = clamp(UV.y * 2.0, 0.0, 1.0);
	float head = smoothstep(0.0, 0.08, t);
	float tail = pow(max(1.0 - t, 0.0), 1.6);
	float rim = abs(dot(normalize(NORMAL), normalize(VIEW)));
	float edge = mix(0.25, 1.0, rim);
	float f1 = sin(t * 26.0 - time * 9.0 + seed) * 0.5 + 0.5;
	float f2 = sin(t * 61.0 + time * 14.0 + seed * 3.1) * 0.5 + 0.5;
	float flick = mix(1.0, 0.55 + 0.45 * (f1 * 0.6 + f2 * 0.4), flicker_k);
	float a = head * tail * edge * flick * layer_alpha;
	ALBEDO = col * glow * a;
	ALPHA = a;
}
