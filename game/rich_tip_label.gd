extends Label
## Label whose tooltip_text is BBCode (built by code, never player text), drawn on a solid panel.
## Planet card tier name: the growth ladder with the current tier highlighted and what each tier gives (owner 2026-11-13).
const TIP_FONT_PX := 12  # smaller than body text: the ladder lists every tier with its rewards
func _make_custom_tooltip(for_text: String) -> Object:
	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rt.custom_minimum_size = Vector2(340, 0)
	for f in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]:
		rt.add_theme_font_size_override(f, TIP_FONT_PX)
	rt.text = for_text
	var pc := PanelContainer.new()
	var sb := pc.get_theme_stylebox("panel")
	if sb is StyleBoxFlat:
		var d := sb.duplicate() as StyleBoxFlat
		d.bg_color.a = 1.0
		pc.add_theme_stylebox_override("panel", d)
	pc.add_child(rt)
	return pc
