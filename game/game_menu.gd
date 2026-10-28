extends PanelContainer
## T71: game menu (gdd-skills.md section 7). Built from an entries list so more can be added later.
## Opened with Esc. Pauses the game while open and restores the earlier pause state on close.

const StoryText := preload("res://game/story_text.gd")

signal closed
signal skills_requested
signal main_menu_requested
signal quit_requested

var main: Control
var confirm_row: HBoxContainer
var confirm_label: Label
var confirm_action: String = ""
var _was_paused := false
var _box: VBoxContainer

func setup(main_node: Control) -> void:
	main = main_node
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	custom_minimum_size = Vector2(300, 0)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 8)
	add_child(_box)
	## [label id, action]. Later slots (Settings, Help, ...) are added here.
	var entries := [["MENU_RESUME", "resume"], ["MENU_SKILLS", "skills"], ["MENU_MAIN", "main"], ["MENU_QUIT", "quit"]]
	for e in entries:
		var b := Button.new()
		if e[1] == "resume":
			b.theme_type_variation = "ButtonPrimary"
		b.text = StoryText.get_text(e[0])
		b.pressed.connect(_on_entry.bind(e[1]))
		_box.add_child(b)
	## Reserved slots (gdd-skills.md section 7): shown disabled until built. Slots whose story id does not exist yet are skipped.
	for id in ["MENU_SETTINGS", "MENU_STATISTICS", "MENU_HELP", "MENU_SAVE_LOAD"]:
		if not StoryText.has_text(id):
			continue
		var r := Button.new()
		r.text = StoryText.get_text(id)
		r.disabled = true
		# FALLBACK: no story id for this hint yet (MENU_HINT_LOCKED); plain text until the story designer adds it
		r.tooltip_text = StoryText.get_or("MENU_HINT_LOCKED", "Not available yet.")
		_box.add_child(r)
	confirm_row = HBoxContainer.new()
	confirm_row.visible = false
	_box.add_child(confirm_row)
	confirm_label = Label.new()
	confirm_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	confirm_label.custom_minimum_size = Vector2(160, 0)
	confirm_row.add_child(confirm_label)
	var yes := Button.new()
	yes.theme_type_variation = "ButtonPrimary"
	yes.text = StoryText.get_text("BTN_YES")
	yes.pressed.connect(confirm_yes)
	confirm_row.add_child(yes)
	var no := Button.new()
	no.theme_type_variation = "ButtonGhost"
	no.text = StoryText.get_text("BTN_NO")
	no.pressed.connect(func(): confirm_row.visible = false; confirm_action = "")
	confirm_row.add_child(no)

func open_menu() -> void:
	if visible:
		return
	_was_paused = main.paused
	main.set_paused(true)  # also writes the autosave
	main.post_notice(StoryText.get_text("NOT_SAVED"))
	confirm_row.visible = false
	confirm_action = ""
	visible = true

func close_menu(restore: bool = true) -> void:
	if not visible:
		return
	visible = false
	if restore and not main.game_over:
		main.set_paused(_was_paused)
	closed.emit()

func _on_entry(action: String) -> void:
	match action:
		"resume":
			close_menu()
		"skills":
			close_menu()
			skills_requested.emit()
		"main":
			_ask("MENU_CONFIRM_MAIN", action)
		"quit":
			_ask("MENU_CONFIRM_QUIT", action)

func _ask(id: String, action: String) -> void:
	confirm_action = action
	confirm_label.text = StoryText.get_text(id)
	confirm_row.visible = true

func confirm_yes() -> void:
	var a := confirm_action
	confirm_row.visible = false
	confirm_action = ""
	if a == "main":
		main_menu_requested.emit()
	elif a == "quit":
		quit_requested.emit()
