extends Control
## One-time tutorial window: title, image on the left (shown at 2x), short lines on the right, one close button.
## Generic: build it with TutWindow.make(title_id, image_path, line_ids, ok_id). All text is story ids.
## Emits `closed` on the button, Esc, Enter or Space; the owner decides about pausing.
class_name TutWindow

const StoryText := preload("res://game/story_text.gd")
signal closed

var _fallbacks: Dictionary = {}
var _vars: Dictionary = {}  # {name} variables of the texts

const IMAGE_SCALE := 2.0
const TEXT_W := 300.0

## image_path may be "" (text only); fallbacks maps a text id to its English fallback (used until the story entry exists).
static func make(title_id: String, image_path: String, line_ids: Array, ok_id: String = "BTN_TIP_OK", fallbacks: Dictionary = {}, vars: Dictionary = {}) -> TutWindow:
	var w := TutWindow.new()
	w._fallbacks = fallbacks
	w._vars = vars
	w._build(title_id, image_path, line_ids, ok_id)
	return w

func _build(title_id: String, image_path: String, line_ids: Array, ok_id: String) -> void:
	name = "TutWindow"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.45)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	var base := panel.get_theme_stylebox("panel", "PanelContainer")
	if base is StyleBoxFlat:
		var opaque := (base as StyleBoxFlat).duplicate() as StyleBoxFlat
		opaque.bg_color = Color(opaque.bg_color, 1.0)
		panel.add_theme_stylebox_override("panel", opaque)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	var title := Label.new()
	title.text = StoryText.get_or(title_id, str(_fallbacks.get(title_id, "")), _vars).to_upper()
	title.theme_type_variation = "LabelCaption"
	box.add_child(title)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	box.add_child(row)
	var tex: Texture2D = load(image_path) as Texture2D if image_path != "" else null
	if tex != null:
		var img := TextureRect.new()
		img.texture = tex
		img.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.custom_minimum_size = tex.get_size() * IMAGE_SCALE
		img.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		row.add_child(img)
	var lines := VBoxContainer.new()
	lines.add_theme_constant_override("separation", 10)
	lines.custom_minimum_size = Vector2(TEXT_W, 0)
	row.add_child(lines)
	for id in line_ids:
		var l := Label.new()
		l.text = StoryText.get_or(str(id), str(_fallbacks.get(str(id), "")), _vars)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(TEXT_W, 0)
		lines.add_child(l)
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	var ok := Button.new()
	ok.theme_type_variation = "ButtonGhost"
	ok.text = StoryText.get_or(ok_id, str(_fallbacks.get(ok_id, "Got it")), _vars)
	ok.pressed.connect(_close)
	btn_row.add_child(ok)
	box.add_child(btn_row)
	ok.grab_focus.call_deferred()

func _close() -> void:
	closed.emit()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		accept_event()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_ESCAPE or event.keycode == KEY_ENTER or event.keycode == KEY_SPACE):
		get_viewport().set_input_as_handled()
		_close()
