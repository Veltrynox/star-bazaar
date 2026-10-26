extends PanelContainer
## T28: small Ships menu, right side under the notification board. Shows ship count / cap.

var label: Label
var status: Label  # T30: docked / in flight
var hint: Label    # T30: 'Space: resume' while paused with a ship in flight

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	custom_minimum_size = Vector2(240, 0)
	offset_left = -252
	offset_right = -12
	offset_top = 380  # T06: moved down, the board now holds the how-to-trade text
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)
	var title := Label.new()
	title.text = "Ships"
	title.add_theme_font_size_override("font_size", 18)
	box.add_child(title)
	label = Label.new()
	box.add_child(label)
	status = Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(status)
	hint = Label.new()
	hint.text = "Space: resume"
	hint.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	box.add_child(hint)

func set_count(ships: int, cap: int, state: String = "", waiting: bool = false) -> void:
	label.text = "Ships: %d / %d" % [ships, cap]
	status.text = state
	status.visible = state != ""
	hint.visible = waiting
