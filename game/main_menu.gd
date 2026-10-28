extends Control
## T26: main menu. New Game and Continue (shows a notice when no save), Quit.

const GAME_SCENE := "res://game/main.tscn"
const SaveGame := preload("res://game/save_game.gd")
const StoryText := preload("res://game/story_text.gd")

var _no_save_label: Label
var _cont_box: VBoxContainer

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
		cont.tooltip_text = StoryText.get_text("MENU_HINT_CONTINUE_OFF")
	cont.pressed.connect(_continue)
	box.add_child(cont)
	var new_game := Button.new()
	new_game.theme_type_variation = "ButtonPrimary"
	new_game.text = StoryText.get_text("MENU_NEW_GAME")
	new_game.pressed.connect(_new_game)
	box.add_child(new_game)
	var quit := Button.new()
	quit.theme_type_variation = "ButtonGhost"
	quit.text = StoryText.get_text("MENU_QUIT")
	quit.pressed.connect(func(): get_tree().quit())
	box.add_child(quit)
	(cont if SaveGame.exists() else new_game).grab_focus()

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

func _start_new() -> void:
	SaveGame.clear()
	SaveGame.continue_requested = false
	get_tree().change_scene_to_file(GAME_SCENE)

func _continue() -> void:
	if not SaveGame.exists():
		if _no_save_label == null:
			_no_save_label = Label.new()
			_no_save_label.theme_type_variation = "LabelWarn"
			_no_save_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_no_save_label.text = StoryText.get_text("NOT_NO_SAVE")
			_cont_box.add_child(_no_save_label)
		return
	SaveGame.continue_requested = true
	get_tree().change_scene_to_file(GAME_SCENE)
