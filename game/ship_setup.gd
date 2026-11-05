extends Control
## Ship screen, second step of New Game (after game/company_setup.gd): pick one of the ship types in data/ships.json.
## Left a small turntable preview of the type's GLB (drag to turn), right the list and a stat card. Start hands name,
## portrait, CEO and ship to the game start. Back returns to the company screen. All text comes from the story loader.

const GAME_SCENE := "res://game/main.tscn"
const SETUP_SCENE := "res://game/company_setup.tscn"
const PATH := "res://data/ships.json"
const SaveGame := preload("res://game/save_game.gd")
const StoryText := preload("res://game/story_text.gd")
const CompanySetup := preload("res://game/company_setup.gd")
const PREVIEW_SIZE := Vector2(620, 460)
const TURN_DEG_PER_SEC := 18.0
const DRAG_RAD_PER_PX := 0.012
const MODEL_RADIUS := 2.0
## stat key -> [label id, fallback label, field in ships.json, higher_is_better]
const STATS := [
	["cargo", "LBL_STAT_CARGO", "Cargo", "cargo_mult", true],
	["upkeep", "LBL_STAT_UPKEEP", "Upkeep", "upkeep_mult", false],
	["trip", "LBL_STAT_TRIP", "Trip cost", "trip_mult", false],
	["price", "LBL_STAT_PRICE", "Price", "price_mult", false],
	["speed", "LBL_STAT_SPEED", "Speed", "speed", true],
	["cap", "LBL_STAT_CAP", "Fleet cap", "cap_add", true],
]

var types: Array = []
var selected_id: String = ""
var buttons: Dictionary = {}  # ship id -> Button
var start_button: Button
var back_button: Button
var hint_label: Label
var role_label: Label
var desc_label: Label
var name_label: Label
var stat_grid: GridContainer
var viewport: SubViewport
var pivot: Node3D
var holder: Node3D
var dragging := false
var model_cache: Dictionary = {}  # model path -> Node3D (kept out of the tree until shown)

func _ready() -> void:
	Ui.install_cursors(get_tree())
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_load_types()
	var bg := ColorRect.new()
	bg.color = Ui.col("void_100")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)

	var title := Label.new()
	title.text = StoryText.get_or("LBL_SHIP_SCREEN_TITLE", "Choose your ship")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.theme_type_variation = "LabelHero"
	box.add_child(title)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	row.add_child(_build_preview())

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(520, 0)
	right.add_theme_constant_override("separation", 10)
	row.add_child(right)
	var group := ButtonGroup.new()
	for t in types:
		var b := Button.new()
		b.toggle_mode = true
		b.button_group = group
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(0, 44)
		b.text = _ship_name(t)
		var id := str(t.get("id", ""))
		b.pressed.connect(func(): select(id))
		right.add_child(b)
		buttons[id] = b
	right.add_child(_build_card())

	hint_label = Label.new()
	hint_label.text = StoryText.get_or("LBL_SHIP_PICK_HINT", "Pick a ship. Every ship you buy later is the same type.")
	hint_label.theme_type_variation = "LabelMuted"
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.custom_minimum_size = Vector2(900, 0)
	box.add_child(hint_label)

	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 12)
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(bottom)
	back_button = Button.new()
	back_button.theme_type_variation = "ButtonGhost"
	back_button.text = StoryText.get_or("SETUP_BACK", "Back")
	back_button.pressed.connect(back)
	bottom.add_child(back_button)
	start_button = Button.new()
	start_button.theme_type_variation = "ButtonPrimary"
	start_button.text = StoryText.get_or("LBL_SHIP_START", "Start")
	start_button.pressed.connect(start)
	bottom.add_child(start_button)
	_refresh()

func _load_types() -> void:
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		types = parsed.get("types", [])

func _type(id: String) -> Dictionary:
	for t in types:
		if str(t.get("id", "")) == id:
			return t
	return {}

func _ship_name(t: Dictionary) -> String:
	return StoryText.get_or(str(t.get("name_id", "")), str(t.get("name", t.get("id", ""))))

# --- preview ---------------------------------------------------------------

func _build_preview() -> Control:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = PREVIEW_SIZE
	frame.add_theme_stylebox_override("panel", _panel_style())
	var svc := SubViewportContainer.new()
	svc.stretch = true
	svc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(svc)
	viewport = SubViewport.new()
	viewport.own_world_3d = true
	viewport.transparent_bg = true
	viewport.size = Vector2i(int(PREVIEW_SIZE.x), int(PREVIEW_SIZE.y))
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	svc.add_child(viewport)
	var env := Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.6, 0.7)
	env.ambient_light_energy = 0.7
	var we := WorldEnvironment.new()
	we.environment = env
	viewport.add_child(we)
	var cam := Camera3D.new()
	cam.position = Vector3(0, 0.5, 3.4)
	viewport.add_child(cam)
	cam.look_at_from_position(cam.position, Vector3.ZERO)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 35, 0)
	sun.light_energy = 1.3
	viewport.add_child(sun)
	pivot = Node3D.new()
	viewport.add_child(pivot)
	# drag to turn: a transparent control over the preview takes the mouse
	var catcher := Control.new()
	catcher.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	catcher.mouse_filter = Control.MOUSE_FILTER_STOP
	catcher.mouse_default_cursor_shape = Control.CURSOR_DRAG
	catcher.gui_input.connect(_on_preview_input)
	frame.add_child(catcher)
	return frame

func _panel_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Ui.col("panel_100")
	s.border_color = Ui.col("line_200")
	s.set_border_width_all(1)
	s.set_corner_radius_all(4)
	return s

func _on_preview_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
	elif event is InputEventMouseMotion and dragging and pivot != null:
		pivot.rotation.y += event.relative.x * DRAG_RAD_PER_PX

func _process(delta: float) -> void:
	if pivot != null and not dragging:
		pivot.rotation.y += deg_to_rad(TURN_DEG_PER_SEC) * delta

## Shows the type's model, centred and scaled to MODEL_RADIUS. A missing or unimported GLB leaves the preview empty.
func _show_model(path: String) -> void:
	if holder != null:
		pivot.remove_child(holder)
		holder.queue_free()
		holder = null
	if path == "" or not ResourceLoader.exists(path):
		return
	var res = load(path)
	if not (res is PackedScene):
		return
	var model: Node3D = res.instantiate()
	holder = Node3D.new()
	var box := _bounds(model, Transform3D.IDENTITY)
	if box.size.length() > 0.0:
		var r := maxf(box.size.length() * 0.5, 0.000001)
		holder.scale = Vector3.ONE * (MODEL_RADIUS / r)
		model.position = -box.get_center()
	holder.add_child(model)
	pivot.add_child(holder)

func _bounds(node: Node, t: Transform3D) -> AABB:
	var box := AABB()
	var first := true
	var xf := t
	if node is Node3D:
		xf = t * node.transform
	if node is MeshInstance3D and node.mesh != null:
		box = xf * node.mesh.get_aabb()
		first = false
	for c in node.get_children():
		var cb := _bounds(c, xf)
		if cb.size == Vector3.ZERO:
			continue
		box = cb if first else box.merge(cb)
		first = false
	return box

# --- stat card ---------------------------------------------------------------

func _build_card() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 250)
	panel.add_theme_stylebox_override("panel", _panel_style())
	var pad := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, 12)
	panel.add_child(pad)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	pad.add_child(v)
	name_label = Label.new()
	name_label.add_theme_color_override("font_color", Ui.col("star_warm"))
	v.add_child(name_label)
	role_label = Label.new()
	role_label.theme_type_variation = "LabelMuted"
	role_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(role_label)
	desc_label = Label.new()
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(480, 0)
	v.add_child(desc_label)
	stat_grid = GridContainer.new()
	stat_grid.columns = 4
	stat_grid.add_theme_constant_override("h_separation", 12)
	stat_grid.add_theme_constant_override("v_separation", 4)
	v.add_child(stat_grid)
	return panel

func _stat_text(field: String, value: float) -> String:
	if field == "cap_add":
		return "+%d" % int(value) if value > 0 else "0"
	return "x%s" % str(snappedf(value, 0.01))

func _refresh_card() -> void:
	for c in stat_grid.get_children():
		stat_grid.remove_child(c)
		c.queue_free()
	var t := _type(selected_id)
	if t.is_empty():
		name_label.text = ""
		role_label.text = ""
		desc_label.text = ""
		return
	name_label.text = _ship_name(t)
	role_label.text = StoryText.get_or(str(t.get("role_id", "")), "")
	desc_label.text = StoryText.get_or(str(t.get("desc_id", "")), "")
	var i := 0
	for s in STATS:
		var l := Label.new()
		l.text = StoryText.get_or(s[1], s[2])
		l.theme_type_variation = "LabelMuted"
		l.custom_minimum_size = Vector2(110, 0)
		var field: String = s[3]
		var val := float(t.get(field, 0))
		var neutral: float = 0.0 if field == "cap_add" else 1.0
		var v := Label.new()
		v.text = _stat_text(field, val)
		if not is_equal_approx(val, neutral):
			var better: bool = (val > neutral) == bool(s[4])
			v.add_theme_color_override("font_color", Ui.col("signal_good") if better else Ui.col("signal_bad"))
		v.custom_minimum_size = Vector2(60, 0)
		stat_grid.add_child(l)
		stat_grid.add_child(v)
		i += 1

# --- flow --------------------------------------------------------------------

func select(id: String) -> void:
	if _type(id).is_empty():
		return
	selected_id = id
	if buttons.has(id):
		(buttons[id] as Button).button_pressed = true
	_show_model(str(_type(id).get("model", "")))
	_refresh()

func _refresh() -> void:
	if start_button != null:
		start_button.disabled = selected_id == ""
		start_button.tooltip_text = StoryText.get_or("LBL_SHIP_PICK_HINT", "Pick a ship.") if selected_id == "" else ""
	if hint_label != null:
		hint_label.visible = selected_id == ""
	if stat_grid != null:
		_refresh_card()

## Model path of the picked type, for the map ship later.
func selected_model() -> String:
	return str(_type(selected_id).get("model", ""))

func commit() -> void:
	SaveGame.pending_ship = selected_id
	SaveGame.pending_ceo = SaveGame.pending_portrait  # the CEO id is the portrait id

func start() -> void:
	if selected_id == "":
		return
	commit()
	SaveGame.clear()  # same reset as New Game had before the setup screens
	SaveGame.continue_requested = false
	get_tree().change_scene_to_file(GAME_SCENE)

func back() -> void:
	CompanySetup.restore = true
	get_tree().change_scene_to_file(SETUP_SCENE)

func _exit_tree() -> void:
	if holder != null and is_instance_valid(holder):
		holder.queue_free()
	if viewport != null and is_instance_valid(viewport):
		viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		back()
		get_viewport().set_input_as_handled()
