shader_type canvas_item;
// Chromatic aberration over the 3D map view: red and blue are sampled a little further out and in than green,
// growing from the screen centre. At the left or right edge the shift is `amount` of the screen width (0.09 percent
// by default); the centre is untouched.
uniform sampler2D screen_tex : hint_screen_texture, filter_linear, repeat_disable;
uniform float amount = 0.0009;   // shift at the horizontal edge, as a share of the screen width

void fragment() {
	vec2 off = (SCREEN_UV - vec2(0.5)) * amount * 2.0;
	float r = texture(screen_tex, SCREEN_UV + off).r;
	float g = texture(screen_tex, SCREEN_UV).g;
	float b = texture(screen_tex, SCREEN_UV - off).b;
	COLOR = vec4(r, g, b, 1.0);
}
