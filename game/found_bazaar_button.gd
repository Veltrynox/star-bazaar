class_name FoundBazaarButton
extends Button
## The "Found the Bazaar here" button: an optional artist picture (zoomed and cropped to fill, rounded corners, dark scrim under the text)
## and a wrapped tooltip card. Without the picture it is a plain button. Children never take the mouse, so the tooltip shows when disabled too.
const HEIGHT := 68.0
const CORNER := 6.0
const SHADER := """
shader_type canvas_item;
uniform float corner = 6.0;
uniform vec2 rect_size = vec2(300.0, 68.0);
void fragment() {
	vec2 p = UV * rect_size;
	vec2 q = min(p, rect_size - p);
	if (q.x < corner && q.y < corner) {
		float d = length(q - vec2(corner)) - corner;
		COLOR.a *= clamp(0.5 - d, 0.0, 1.0);
	}
}
"""

func _make_custom_tooltip(for_text: String) -> Object:
	var rt := RichTextLabel.new()
	rt.fit_content = true
	rt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rt.custom_minimum_size = Vector2(320, 0)
	rt.text = for_text
	var pc := PanelContainer.new()
	var sb := pc.get_theme_stylebox("panel")
	if sb is StyleBoxFlat:
		var d := sb.duplicate() as StyleBoxFlat
		d.bg_color.a = 1.0
		pc.add_theme_stylebox_override("panel", d)
	pc.add_child(rt)
	pc.tree_entered.connect(func() -> void:
		var popup := pc.get_parent()
		if popup is Window:
			popup.add_theme_stylebox_override("panel", StyleBoxEmpty.new()))
	return pc

## Call after text and disabled are set. tex may be null (then only the height changes nothing: plain button).
func add_picture(tex: Texture2D) -> void:
	if tex == null:
		return
	custom_minimum_size.y = HEIGHT
	clip_contents = true
	var sh := Shader.new()
	sh.code = SHADER
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("corner", CORNER)
	var shown := Color(1, 1, 1, 1) if not disabled else Color(0.45, 0.45, 0.45, 1)
	var img := TextureRect.new()
	img.name = "FoundPicture"
	img.texture = tex
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	img.modulate = shown
	img.material = mat
	img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(img)
	var grad := Gradient.new()
	grad.set_color(0, Color(0, 0, 0, 0.15))
	grad.set_color(1, Color(0, 0, 0, 0.78))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	var scrim := TextureRect.new()
	scrim.name = "FoundScrim"
	scrim.texture = gt
	scrim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scrim.stretch_mode = TextureRect.STRETCH_SCALE
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrim.material = mat
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scrim)
	resized.connect(func() -> void: mat.set_shader_parameter("rect_size", size))
	# The button's own text is drawn under its children, so it is hidden and a label above the picture shows it.
	for st in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color", "font_disabled_color"]:
		add_theme_color_override(st, Color(0, 0, 0, 0))
	var lb := Label.new()
	lb.name = "FoundLabel"
	lb.text = text
	lb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lb.add_theme_color_override("font_color", Ui.col("ink") if not disabled else Ui.col("ink_muted"))
	lb.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	lb.add_theme_constant_override("outline_size", 4)
	lb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lb.offset_left = 10
	lb.offset_right = -10
	add_child(lb)
