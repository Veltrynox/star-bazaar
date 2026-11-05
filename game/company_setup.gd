extends Control
## New company screen: shown by the main menu's New Game. Pick a company name (typed or random) and a CEO portrait,
## then Next goes on to the ship screen (game/ship_setup.gd), which starts the game. Back returns to the main menu. All labels come from the story loader with plain defaults.

const SHIP_SCENE := "res://game/ship_setup.tscn"
const CEOS_PATH := "res://data/ceos.json"
const MENU_SCENE := "res://game/main_menu.tscn"
const SaveGame := preload("res://game/save_game.gd")
const StoryText := preload("res://game/story_text.gd")
const Names := preload("res://game/company_names.gd")
const Portraits := preload("res://game/company_portraits.gd")
const CARD_SIZE := Vector2(184, 232)
const STAT_KEYS := ["haggling", "thrift", "nerve"]

## Set by the ship screen's Back so this screen reopens with the name and CEO already chosen.
static var restore: bool = false

var name_edit: LineEdit
var random_button: Button
var start_button: Button
var back_button: Button
var cards: Dictionary = {}  # portrait id -> Button
var selected_id: String = ""
var ceo_defs: Dictionary = {}  # portrait id -> row of data/ceos.json
var info_box: VBoxContainer

func _ready() -> void:
	Ui.install_cursors(get_tree())
	_load_ceos()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Ui.col("void_100")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(800, 0)
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
	# no default CEO: the player must pick one
	var info := PanelContainer.new()
	info.custom_minimum_size = Vector2(0, 176)
	info.add_theme_stylebox_override("panel", _card_style(Ui.col("line_200"), 1, 0.0))
	var pad := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, 12)
	info.add_child(pad)
	info_box = VBoxContainer.new()
	info_box.add_theme_constant_override("separation", 6)
	pad.add_child(info_box)
	box.add_child(info)

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
	start_button.text = StoryText.get_or("SETUP_NEXT", "Next")
	start_button.pressed.connect(start)
	buttons.add_child(start_button)
	if restore:
		restore = false
		if SaveGame.pending_company != "":
			name_edit.text = SaveGame.pending_company
		if SaveGame.pending_portrait != "" and cards.has(SaveGame.pending_portrait):
			select(SaveGame.pending_portrait)
	_refresh_start()
	_refresh_info()
	name_edit.grab_focus()  # focus the name field, so no card draws a focus highlight at open

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
	b.pressed.connect(func():
		selected_id = id
		_refresh_info()
		_refresh_start())
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
	if start_button != null:
		_refresh_start()
		_refresh_info()

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
	var no_name := chosen_name() == ""
	var no_ceo := selected_id == ""
	start_button.disabled = no_name or no_ceo
	# FALLBACK: ids SETUP_NEED_NAME / SETUP_NEED_CEO not in the story files yet; plain text until the story designer adds them
	var tip := ""
	if no_name:
		tip = StoryText.get_or("SETUP_NEED_NAME", "Enter a company name to start.")
	if no_ceo:
		var t2 := StoryText.get_or("SETUP_NEED_CEO", "Choose a CEO to start.")
		tip = t2 if tip == "" else tip + "\n" + t2
	start_button.tooltip_text = tip

func _load_ceos() -> void:
	var f := FileAccess.open(CEOS_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		for row in parsed.get("ceos", []):
			ceo_defs[str(row.get("id", ""))] = row

## Info panel for the selected CEO: name, bio, three stats as pips, perk name and description.
func _refresh_info() -> void:
	for c in info_box.get_children():
		info_box.remove_child(c)
		c.queue_free()
	var d: Dictionary = ceo_defs.get(selected_id, {})
	if d.is_empty():
		var hint := Label.new()
		hint.text = StoryText.get_or("SETUP_NEED_CEO", "Choose a CEO to start.")
		hint.theme_type_variation = "LabelMuted"
		info_box.add_child(hint)
		return
	var nm := Label.new()
	nm.text = StoryText.get_or(str(d.get("name_id", "")), selected_id)
	nm.add_theme_color_override("font_color", Ui.col("star_warm"))
	info_box.add_child(nm)
	var bio := Label.new()
	bio.text = StoryText.get_or(str(d.get("bio_id", "")), "")
	bio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bio.custom_minimum_size = Vector2(700, 0)
	info_box.add_child(bio)
	var stats_row := HBoxContainer.new()
	stats_row.add_theme_constant_override("separation", 28)
	info_box.add_child(stats_row)
	var stats: Dictionary = d.get("stats", {})
	for k in STAT_KEYS:
		var cell := HBoxContainer.new()
		cell.add_theme_constant_override("separation", 6)
		var l := Label.new()
		l.text = StoryText.get_or("LBL_CEO_STAT_" + k.to_upper(), k.capitalize())
		l.theme_type_variation = "LabelMuted"
		cell.add_child(l)
		var v := int(stats.get(k, 0))
		for i in 3:
			var pip := Panel.new()
			pip.custom_minimum_size = Vector2(14, 14)
			pip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			var on := i < v
			pip.add_theme_stylebox_override("panel", _card_style(Ui.col("star_warm") if on else Ui.col("line_300"), 1, 1.0 if on else 0.0))
			cell.add_child(pip)
		stats_row.add_child(cell)
	var perk := Label.new()
	perk.text = "%s: %s" % [StoryText.get_or("LBL_CEO_PERK", "Perk"), StoryText.get_or(str(d.get("perk_name_id", "")), "")]
	perk.add_theme_color_override("font_color", Ui.col("star_warm"))
	info_box.add_child(perk)
	var pd := Label.new()
	pd.text = StoryText.get_or(str(d.get("perk_desc_id", "")), "")
	pd.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pd.custom_minimum_size = Vector2(700, 0)
	info_box.add_child(pd)

## Hands name and portrait (= CEO id) on to the ship screen, which commits the rest and starts the game.
func commit() -> void:
	SaveGame.pending_company = chosen_name()
	SaveGame.pending_portrait = selected_id
	SaveGame.pending_ceo = selected_id

func start() -> void:
	if chosen_name() == "" or selected_id == "":
		return
	commit()
	get_tree().change_scene_to_file(SHIP_SCENE)

func back() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		back()
		get_viewport().set_input_as_handled()
