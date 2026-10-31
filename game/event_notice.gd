extends ColorRect
## T12: paused event notification. Title and text come from data/events.json (passed in); the effect
## line is plain text with the NOT_EVENT_PREFIX story text. Continue, or one button per choice.

const StoryText := preload("res://game/story_text.gd")

signal confirmed(choice: int)  # -1 = Continue, otherwise the choice index

var first_enabled := -1  # index of the first choice button that is not disabled; -1 when none (or Continue only)
var enabled_choices: Array = []  # indexes of every choice button that is not disabled, in order (QA reads these)

func show_event(title: String, text: String, effect_line: String, choices: Array, continue_text: String, disabled: Array = [], art: String = "") -> void:
	color = Ui.col("scrim_soft")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var card := PanelContainer.new()  # design system EventPopup: one glass card
	center.add_child(card)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(560, 0)
	box.add_theme_constant_override("separation", 16)
	Ui.scroll_wrap(card, box, 48.0)  # many choices or long text scroll inside the window
	if art == "asteroid":  # T109: simple polygon on an approach path
		box.add_child(AsteroidArt.new())
	var t := Label.new()
	t.text = title
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.theme_type_variation = "LabelTitle"
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(t)
	var body := Label.new()
	body.text = text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body)
	if effect_line != "":
		var e := Label.new()
		e.text = effect_line
		e.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		e.theme_type_variation = "LabelAccent"
		box.add_child(e)
	var first: Button = null
	if choices.is_empty():
		var b := Button.new()
		b.theme_type_variation = "ButtonPrimary"
		b.text = continue_text
		b.pressed.connect(func(): confirmed.emit(-1))
		box.add_child(b)
		first = b
	else:
		for i in choices.size():
			var b := Button.new()
			b.text = str(choices[i])
			b.disabled = i < disabled.size() and bool(disabled[i])
			if b.disabled:  # FALLBACK: no story id yet (EVT_HINT_CHOICE_OFF); plain text until the story designer adds it
				b.tooltip_text = StoryText.get_or("EVT_HINT_CHOICE_OFF", "Not available now.")
			b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			var idx := i
			b.pressed.connect(func(): confirmed.emit(idx))
			box.add_child(b)
			if not b.disabled:
				enabled_choices.append(idx)
			if first == null and not b.disabled:
				first = b
				first_enabled = idx
	if first != null:
		first.grab_focus()

## T109: a dashed approach path and an irregular polygon rock on it. Drawn, no texture.
class AsteroidArt extends Control:
	const ROCK := [Vector2(-14, -6), Vector2(-6, -15), Vector2(7, -13), Vector2(15, -3), Vector2(11, 10), Vector2(-2, 14), Vector2(-13, 8)]

	func _init() -> void:
		custom_minimum_size = Vector2(0, 64)

	func _draw() -> void:
		var a := Vector2(24, size.y - 12)
		var b := Vector2(size.x - 24, 14)
		draw_dashed_line(a, b, Ui.col("panel_300"), 2.0, 8.0)
		var pos := a.lerp(b, 0.7)
		var pts := PackedVector2Array()
		for v in ROCK:
			pts.append(pos + v)
		draw_colored_polygon(pts, Ui.col("signal_bad"))
		draw_polyline(pts + PackedVector2Array([pts[0]]), Ui.col("star_warm"), 1.5)
