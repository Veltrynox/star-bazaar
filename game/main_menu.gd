extends Control
## T26: main menu. New Game and Continue (shows a notice when no save), Quit.

const GAME_SCENE := "res://game/main.tscn"
const SETUP_SCENE := "res://game/company_setup.tscn"
const SaveGame := preload("res://game/save_game.gd")
const StoryText := preload("res://game/story_text.gd")

var _no_save_label: Label
var _cont_box: VBoxContainer
var _main_box: VBoxContainer
var settings_box: VBoxContainer  # Settings screen; shown instead of the main column
var voice_check: CheckButton  # Settings: Voice on/off (Voice.enabled, saved)
var voice_slider: HSlider
var lang_buttons := {}  # language code -> toggle button (labels are hard-coded in their own language)
var _texts := {}  # Control -> story id, so the labels can be set again when the language changes

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
	box.custom_minimum_size = Vector2(260, 0)
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)
	_cont_box = box
	_main_box = box
	var title := Label.new()
	title.text = StoryText.get_text("SCR_TITLE_NAME")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.theme_type_variation = "LabelHero"
	box.add_child(title)
	var tagline := Label.new()
	tagline.text = StoryText.get_text("SCR_TITLE_TAGLINE")
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.theme_type_variation = "LabelMuted"
	tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(tagline)
	var cont := Button.new()
	cont.text = StoryText.get_text("MENU_CONTINUE")
	if not SaveGame.exists():
		cont.tooltip_text = SaveGame.old_save_message() if SaveGame.dropped_old else StoryText.get_text("MENU_HINT_CONTINUE_OFF")
	cont.pressed.connect(_continue)
	box.add_child(cont)
	var new_game := Button.new()
	new_game.theme_type_variation = "ButtonPrimary"
	new_game.text = StoryText.get_text("MENU_NEW_GAME")
	new_game.pressed.connect(_new_game)
	box.add_child(new_game)
	var settings := Button.new()
	settings.text = StoryText.get_or("BTN_SETTINGS", StoryText.get_or("MENU_SETTINGS", "Settings"))
	settings.pressed.connect(_show_settings.bind(true))
	box.add_child(settings)
	var quit := Button.new()
	quit.theme_type_variation = "ButtonGhost"
	quit.text = StoryText.get_text("MENU_QUIT")
	quit.pressed.connect(func(): get_tree().quit())
	box.add_child(quit)
	_build_settings(center)
	for pair in [[title, "SCR_TITLE_NAME"], [tagline, "SCR_TITLE_TAGLINE"], [cont, "MENU_CONTINUE"], [new_game, "MENU_NEW_GAME"], [quit, "MENU_QUIT"]]:
		_texts[pair[0]] = pair[1]
	_cont = cont
	Lang.changed.connect(_on_language_changed)
	(cont if SaveGame.exists() else new_game).grab_focus()

var _cont: Button

## The language was switched on the Settings screen: set the menu texts again (they were built before the switch).
func _on_language_changed(_code: String) -> void:
	for c in _texts:
		(c as Control).set("text", StoryText.get_text(_texts[c]))
	if not SaveGame.exists():
		_cont.tooltip_text = SaveGame.old_save_message() if SaveGame.dropped_old else StoryText.get_text("MENU_HINT_CONTINUE_OFF")
	if _no_save_label != null and not SaveGame.dropped_old:
		_no_save_label.text = StoryText.get_text("NOT_NO_SAVE")

## Settings screen: language (English / Russian) and the voice controls. Interface text stays English.
func _build_settings(center: Container) -> void:
	settings_box = VBoxContainer.new()
	settings_box.custom_minimum_size = Vector2(320, 0)
	settings_box.add_theme_constant_override("separation", 14)
	settings_box.visible = false
	center.add_child(settings_box)
	var head := Label.new()
	head.text = StoryText.get_or("BTN_SETTINGS", StoryText.get_or("MENU_SETTINGS", "Settings"))
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.theme_type_variation = "LabelTitle"
	settings_box.add_child(head)
	var lrow := HBoxContainer.new()
	lrow.add_theme_constant_override("separation", 8)
	var llabel := Label.new()
	llabel.text = StoryText.get_or("LBL_LANGUAGE", "Language")
	llabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lrow.add_child(llabel)
	var group := ButtonGroup.new()
	for pair in [["en", "English"], ["ru", "Русский"]]:
		var b := Button.new()
		b.text = pair[1]
		b.toggle_mode = true
		b.button_group = group
		b.button_pressed = Lang.current() == pair[0]
		b.pressed.connect(func():
			Lang.set_language(pair[0])
			_mark_language())
		lrow.add_child(b)
		lang_buttons[pair[0]] = b
	settings_box.add_child(lrow)
	_mark_language()
	var vrow := HBoxContainer.new()
	vrow.add_theme_constant_override("separation", 8)
	var vcheck := CheckButton.new()
	vcheck.text = StoryText.get_or("MENU_VOICE", "Voice")
	voice_check = vcheck
	voice_slider = null
	vcheck.button_pressed = Voice.enabled
	vcheck.toggled.connect(func(on: bool): Voice.set_enabled(on))
	vrow.add_child(vcheck)
	var vslide := HSlider.new()
	vslide.min_value = 0.0
	vslide.max_value = 1.0
	vslide.step = 0.05
	vslide.value = Voice.volume
	vslide.custom_minimum_size = Vector2(110, 0)
	vslide.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vslide.value_changed.connect(func(v: float): Voice.set_volume(v))
	vrow.add_child(vslide)
	voice_slider = vslide
	settings_box.add_child(vrow)
	var back := Button.new()
	back.theme_type_variation = "ButtonGhost"
	back.text = StoryText.get_or("BTN_BACK", "Back")
	back.pressed.connect(_show_settings.bind(false))
	settings_box.add_child(back)
	settings_box.set_meta("back", back)

## The chosen language button gets the primary (accent) look.
func _mark_language() -> void:
	for code in lang_buttons:
		var b: Button = lang_buttons[code]
		b.theme_type_variation = "ButtonPrimary" if code == Lang.current() else ""

func _show_settings(on: bool) -> void:
	settings_box.visible = on
	_main_box.visible = not on
	if on:
		voice_check.set_pressed_no_signal(Voice.enabled)
		voice_slider.set_value_no_signal(Voice.volume)
		lang_buttons[Lang.current()].button_pressed = true
		_mark_language()
		(settings_box.get_meta("back") as Button).grab_focus()

func _new_game() -> void:
	if not SaveGame.exists():
		_start_new()
		return
	var dlg := ConfirmationDialog.new()
	dlg.dialog_text = StoryText.get_text("MENU_CONFIRM_NEW")
	dlg.ok_button_text = StoryText.get_text("BTN_YES")
	dlg.cancel_button_text = StoryText.get_text("BTN_NO")
	dlg.confirmed.connect(_start_new)
	add_child(dlg)
	dlg.popup_centered()

## Opens the new company screen; it clears the old save and starts the game when the player presses Start.
func _start_new() -> void:
	get_tree().change_scene_to_file(SETUP_SCENE)

func _continue() -> void:
	if not SaveGame.exists():
		if _no_save_label == null:
			_no_save_label = Label.new()
			_no_save_label.theme_type_variation = "LabelWarn"
			_no_save_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_no_save_label.text = SaveGame.old_save_message() if SaveGame.dropped_old else StoryText.get_text("NOT_NO_SAVE")
			_cont_box.add_child(_no_save_label)
		return
	SaveGame.continue_requested = true
	get_tree().change_scene_to_file(GAME_SCENE)
