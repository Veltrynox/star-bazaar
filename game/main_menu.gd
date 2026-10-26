extends Control
## T26: main menu. New Game and Continue (disabled when no save), Quit.

const GAME_SCENE := "res://game/main.tscn"
const SaveGame := preload("res://game/save_game.gd")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.04, 0.08)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(260, 0)
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)
	var title := Label.new()
	title.text = "Star Bazaar"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	box.add_child(title)
	var cont := Button.new()
	cont.text = "Continue"
	cont.disabled = not SaveGame.exists()
	cont.pressed.connect(_continue)
	box.add_child(cont)
	var new_game := Button.new()
	new_game.text = "New Game"
	new_game.pressed.connect(_new_game)
	box.add_child(new_game)
	var quit := Button.new()
	quit.text = "Quit"
	quit.pressed.connect(func(): get_tree().quit())
	box.add_child(quit)
	(new_game if cont.disabled else cont).grab_focus()

func _new_game() -> void:
	SaveGame.continue_requested = false
	get_tree().change_scene_to_file(GAME_SCENE)

func _continue() -> void:
	SaveGame.continue_requested = true
	get_tree().change_scene_to_file(GAME_SCENE)
