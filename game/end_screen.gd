extends ColorRect
## T77: full-screen overlay for the win choice and the end screens. Texts from StoryText only.
## No close button; the game below stays stopped (main.game_over is true while this is shown).

const StoryText := preload("res://game/story_text.gd")

signal chosen(side: String)       # choice screen: "RELEASE" or "CORP"
signal new_game_pressed
signal menu_pressed
signal quit_pressed

func _init() -> void:
	color = Ui.col("scrim")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

func _box() -> VBoxContainer:
	for c in get_children():
		c.queue_free()
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 40
	scroll.offset_right = -40
	scroll.offset_top = 20
	scroll.offset_bottom = -20
	add_child(scroll)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(620, 0)
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)
	return box

func _label(box: Control, text: String, size: int = 0, center: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if size > 0:
		l.theme_type_variation = "LabelHero" if size >= 30 else "LabelTitle"
	if center:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(l)
	return l

func show_choice() -> void:
	var box := _box()
	_label(box, StoryText.get_text("CHOICE_TITLE"), 30, true)
	_label(box, StoryText.get_text("CHOICE_TEXT"))
	var first: Button = null
	for pair in [["CHOICE_RELEASE", "RELEASE"], ["CHOICE_CORP", "CORP"]]:
		var b := Button.new()
		b.theme_type_variation = "ButtonPrimary"
		b.text = StoryText.get_text(pair[0])
		var side: String = pair[1]
		b.pressed.connect(func(): chosen.emit(side))
		box.add_child(b)
		_label(box, StoryText.get_text(pair[0] + "_EFFECT"))
		if first == null:
			first = b
	first.grab_focus()

## Win: side "RELEASE" or "CORP"; stats has cycle, cash, branches, systems.
## Loss: side "LOSS"; stat is the filled END_LOSS_STAT text. Layout per story/endings.md.
func show_ending(ending_id: String, side: String, stats: Dictionary, stat: String = "") -> void:
	var box := _box()
	if side == "LOSS":
		_label(box, StoryText.get_text(ending_id))
		_label(box, stat)
	else:
		var key := "REL" if side == "RELEASE" else "CORP"
		_label(box, StoryText.get_text("END_TITLE_" + key), 30, true)
		_label(box, StoryText.get_text(ending_id))
		if StoryText.has_text(ending_id + "_EPI"):
			_label(box, StoryText.get_text(ending_id + "_EPI"))
		_label(box, StoryText.get_text("END_SIGN_" + key))
		for pair in [["END_STAT_CYCLES", "cycle"], ["END_STAT_CASH", "cash"], ["END_STAT_BRANCHES", "branches"], ["END_STAT_SYSTEMS", "systems"]]:
			_label(box, "%s: %s" % [StoryText.get_text(pair[0]), str(stats.get(pair[1], 0))])
	_label(box, StoryText.get_text("END_RUN_OVER"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	var first: Button = null
	for pair in [["END_BTN_NEW", new_game_pressed], ["END_BTN_MENU", menu_pressed], ["END_BTN_QUIT", quit_pressed]]:
		var b := Button.new()
		if first == null:
			b.theme_type_variation = "ButtonPrimary"
		b.text = StoryText.get_text(pair[0])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sig: Signal = pair[1]
		b.pressed.connect(func(): sig.emit())
		row.add_child(b)
		if first == null:
			first = b
	first.grab_focus()
