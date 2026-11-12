extends ColorRect
## T12: paused event notification. Title and text come from data/events.json (passed in); the effect
## line is plain text with the NOT_EVENT_PREFIX story text. Continue, or one button per choice.

const StoryText := preload("res://game/story_text.gd")
const Juice := preload("res://game/juice.gd")
const BannerArt := preload("res://game/banner_art.gd")

signal confirmed(choice: int)  # -1 = Continue, otherwise the choice index

var first_enabled := -1  # index of the first choice button that is not disabled; -1 when none (or Continue only)
var enabled_choices: Array = []  # indexes of every choice button that is not disabled, in order (QA reads these)
var _dismissed := false  # set when the exit fade starts: a button still focused cannot confirm a second time

func show_event(title: String, text: String, effect_line: String, choices: Array, continue_text: String, disabled: Array = [], art: String = "", voice_id: String = "") -> void:
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
	var banner := _load_banner(art)
	var wrapped := false
	if banner != null:  # banner runs edge to edge: card frame margins off, the text area gets its own margins
		var sb := card.get_theme_stylebox("panel")
		if sb is StyleBoxFlat:
			var flat := (sb as StyleBoxFlat).duplicate() as StyleBoxFlat
			var ml := int(flat.content_margin_left)
			var mr := int(flat.content_margin_right)
			var mb := int(flat.content_margin_bottom)
			flat.set_content_margin_all(0.0)
			card.add_theme_stylebox_override("panel", flat)
			var outer := VBoxContainer.new()
			outer.add_theme_constant_override("separation", -28)  # the title sits on the foot of the fade
			card.add_child(outer)
			var pic := BannerArt.new()
			pic.texture = banner
			pic.bg = flat.bg_color
			pic.r_tl = float(flat.corner_radius_top_left)  # same radii as the card frame
			pic.r_tr = float(flat.corner_radius_top_right)
			outer.add_child(pic)
			var pad := MarginContainer.new()
			pad.add_theme_constant_override("margin_left", ml)
			pad.add_theme_constant_override("margin_right", mr)
			pad.add_theme_constant_override("margin_bottom", mb)
			outer.add_child(pad)
			Ui.scroll_wrap(pad, box, 48.0 + BannerArt.MAX_H + float(mb))
			wrapped = true
	if not wrapped:
		Ui.scroll_wrap(card, box, 48.0)  # many choices or long text scroll inside the window
		if art == "asteroid" or art == "res://art/event_banners/ev20.webp":  # T109: fallback when no banner file
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
		b.pressed.connect(func(): _confirm(-1))
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
			b.pressed.connect(func(): _confirm(idx))
			box.add_child(b)
			if not b.disabled:
				enabled_choices.append(idx)
			if first == null and not b.disabled:
				first = b
				first_enabled = idx
	if first != null:
		first.grab_focus()
	if voice_id != "":
		Voice.play(voice_id)
	# entry beat: the scrim fades in and the card grows into place
	Juice.enter(self, 1.0, 0.0, true)
	Juice.enter(card, Juice.ENTER_SCALE)

## art is a res:// banner path; returns null when it is not a banner or the file is missing.
func _load_banner(art: String) -> Texture2D:
	if not art.begins_with("res://") or not ResourceLoader.exists(art):
		return null
	var res = load(art)
	return res as Texture2D

## Closes the notice with a short fade and frees it. Input passes through at once, so the exit never holds play up.
func dismiss() -> void:
	_dismissed = true
	Voice.stop()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Juice.leave(self, true)

## A choice or Continue was pressed: emit once, and not at all once the notice is being dismissed.
func _confirm(choice: int) -> void:
	if not _dismissed:
		confirmed.emit(choice)

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
