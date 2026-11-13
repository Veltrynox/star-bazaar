extends Button
## Button whose tooltip shows its first line in bold (the resource name, which the button itself no longer prints).
## Meta "tip_muted": a part of the tooltip text (the resource description) drawn smaller and grey.
## Meta "tip_tints": {line text: Colors theme token}, lines drawn in that colour (Currently being bought / sold).
const MUTED_SIZE := 13
func _make_custom_tooltip(for_text: String) -> Object:
	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rt.custom_minimum_size = Vector2(260, 0)
	var nl := for_text.find("\n")
	var head := for_text if nl < 0 else for_text.substr(0, nl)
	var rest := "" if nl < 0 else for_text.substr(nl)
	rest = rest.replace("[", "[lb]")
	var muted := str(get_meta("tip_muted", "")).replace("[", "[lb]")  # the resource description: smaller and grey
	if muted != "" and rest.contains(muted):
		rest = rest.replace(muted, "[font_size=%d][color=#%s]%s[/color][/font_size]" % [MUTED_SIZE, Ui.col("ink_muted").to_html(false), muted])
	var tints: Dictionary = get_meta("tip_tints", {})  # whole lines drawn in a theme colour: {line text: Colors token}
	for line in tints:
		var esc := str(line).replace("[", "[lb]")
		if esc != "" and rest.contains(esc):
			rest = rest.replace(esc, "[color=#%s]%s[/color]" % [Ui.col(str(tints[line])).to_html(false), esc])
	rt.text = "[b]" + head.replace("[", "[lb]") + "[/b]" + rest
	var pc := PanelContainer.new()
	var sb := pc.get_theme_stylebox("panel")
	if sb is StyleBoxFlat:  # owner 2026-11-13: the resource tooltip is not see-through
		var d := sb.duplicate() as StyleBoxFlat
		d.bg_color.a = 1.0
		pc.add_theme_stylebox_override("panel", d)
	pc.add_child(rt)
	# The tooltip popup draws its own TooltipPanel frame around this card: blank it so only the rounded card shows.
	pc.tree_entered.connect(func() -> void:
		var popup := pc.get_parent()
		if popup is Window:
			popup.add_theme_stylebox_override("panel", StyleBoxEmpty.new()))
	return pc
