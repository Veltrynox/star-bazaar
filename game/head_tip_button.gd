extends Button
## Button whose tooltip shows its first line in bold (the resource name, which the button itself no longer prints).
func _make_custom_tooltip(for_text: String) -> Object:
	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rt.custom_minimum_size = Vector2(260, 0)
	var nl := for_text.find("\n")
	var head := for_text if nl < 0 else for_text.substr(0, nl)
	var rest := "" if nl < 0 else for_text.substr(nl)
	rt.text = "[b]" + head.replace("[", "[lb]") + "[/b]" + rest.replace("[", "[lb]")
	var pc := PanelContainer.new()
	pc.add_child(rt)
	return pc
