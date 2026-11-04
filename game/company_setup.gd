extends Control
## New company screen: shown by the main menu's New Game. Pick a company name (typed or random) and a CEO portrait,
## then Start goes on to the game. Back returns to the main menu. All labels come from the story loader with plain defaults.

const GAME_SCENE := "res://game/main.tscn"
const MENU_SCENE := "res://game/main_menu.tscn"
const SaveGame := preload("res://game/save_game.gd")
const StoryText := preload("res://game/story_text.gd")
const Names := preload("res://game/company_names.gd")
const Portraits := preload("res://game/company_portraits.gd")
const CARD_SIZE := Vector2(184, 232)

var name_edit: LineEdit
var random_button: Button
var start_button: Button
var back_button: Button
var cards: Dictionary = {}  # portrait id -> Button
var selected_id: String = ""

func _ready() -> void:
	Ui.install_cursors(get_tree())
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Ui.col("void_100")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(560, 0)
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)

	var title := Label.new()
	title.text = StoryText.get_or("SETUP_TITLE", "New company")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.theme_type_variation = "LabelHero"
	box.add_child(title)

	var name_label := Label.new()
	name_label.text = StoryText.get_or("SETUP_NAME_LABEL", "Company name")
	name_label.theme_type_variation = "LabelMuted"
	box.add_child(name_label)
	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 8)
	box.add_child(name_row)
	name_edit = LineEdit.new()
	name_edit.max_length = Names.MAX_LEN
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_edit.text = Names.generate()
	name_edit.text_changed.connect(func(_t): _refresh_start())
	name_edit.text_submitted.connect(func(_t): if not start_button.disabled: start())
	name_row.add_child(name_edit)
	random_button = Button.new()
	random_button.text = StoryText.get_or("SETUP_RANDOM", "Random")
	random_button.pressed.connect(randomize_name)
	name_row.add_child(random_button)

	var ceo_label := Label.new()
	ceo_label.text = StoryText.get_or("SETUP_CEO_LABEL", "Choose your CEO")
	ceo_label.theme_type_variation = "LabelMuted"
	box.add_child(ceo_label)
	var card_row := HBoxContainer.new()
	card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_row.add_theme_constant_override("separation", 12)
	box.add_child(card_row)
	var group := ButtonGroup.new()
	for id in Portraits.IDS:
		var card := _make_card(id, group)
		card_row.add_child(card)
		cards[id] = card
	select(Portraits.IDS[0])

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(buttons)
	back_button = Button.new()
	back_button.theme_type_variation = "ButtonGhost"
	back_button.text = StoryText.get_or("SETUP_BACK", "Back")
	back_button.pressed.connect(back)
	buttons.add_child(back_button)
	start_button = Button.new()
	start_button.theme_type_variation = "ButtonPrimary"
	start_button.text = StoryText.get_or("SETUP_START", "Start")
	start_button.pressed.connect(start)
	buttons.add_child(start_button)
	_refresh_start()
	start_button.grab_focus()

func _make_card(id: String, group: ButtonGroup) -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_group = group
	b.custom_minimum_size = CARD_SIZE
	b.focus_mode = Control.FOCUS_ALL
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_stylebox_override("normal", _card_style(Ui.col("line_200"), 1, 0.0))
	b.add_theme_stylebox_override("hover", _card_style(Ui.col("line_300"), 2, 0.0))
	b.add_theme_stylebox_override("focus", _card_style(Ui.col("ink_muted"), 2, 0.0))
	b.add_theme_stylebox_override("pressed", _card_style(Ui.col("star_warm"), 3, 0.12))
	b.add_theme_stylebox_override("hover_pressed", _card_style(Ui.col("star_warm"), 3, 0.18))
	var pic := TextureRect.new()
	pic.texture = Portraits.texture(id)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pic.offset_left = 8
	pic.offset_top = 8
	pic.offset_right = -8
	pic.offset_bottom = -8
	b.add_child(pic)
	b.pressed.connect(func(): selected_id = id)
	return b

func _card_style(border: Color, width: int, glow: float) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(Ui.col("star_warm"), glow) if glow > 0.0 else Ui.col("panel_100")
	s.border_color = border
	s.set_border_width_all(width)
	s.set_corner_radius_all(4)
	return s

func select(id: String) -> void:
	id = Portraits.normalize(id)
	selected_id = id
	(cards[id] as Button).button_pressed = true

func randomize_name() -> void:
	var old := name_edit.text
	var n := Names.generate()
	var tries := 0
	while n == old and tries < 8:  # always show a different name
		n = Names.generate()
		tries += 1
	name_edit.text = n
	_refresh_start()

func chosen_name() -> String:
	return name_edit.text.strip_edges()

func _refresh_start() -> void:
	start_button.disabled = chosen_name() == ""
	# FALLBACK: id SETUP_NEED_NAME not in the story files yet; plain text until the story designer adds it
	start_button.tooltip_text = StoryText.get_or("SETUP_NEED_NAME", "Enter a company name to start.") if start_button.disabled else ""

## Hands name and portrait to the next game start (read once by main.gd).
func commit() -> void:
	SaveGame.pending_company = chosen_name()
	SaveGame.pending_portrait = selected_id

func start() -> void:
	if chosen_name() == "":
		return
	commit()
	SaveGame.clear()  # same reset as New Game had before this screen
	SaveGame.continue_requested = false
	get_tree().change_scene_to_file(GAME_SCENE)

func back() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		back()
		get_viewport().set_input_as_handled()
