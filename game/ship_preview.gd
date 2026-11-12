extends PanelContainer
## Small turntable preview of a ship GLB (drag to turn), same camera, light and fit as the old ship screen (game/ship_setup.gd).
## Used by the company screen. Also holds the ship stat rows shared with it.

const TURN_DEG_PER_SEC := 18.0
const DRAG_RAD_PER_PX := 0.012
const Ships := preload("res://game/ships.gd")  # T356: engine points for the plume
const StoryText := preload("res://game/story_text.gd")
const FIT_HALF_WIDTH := 2.0
const FIT_HALF_HEIGHT := 1.15
## T358: camera distance and the radius (world units, around the turntable axis) that ship plus the longest plume must stay inside.
## Measured cause of the cut-off plume: with the camera 3.4 away and only the hull fitted (radius 2.0), a needle plume reached 4.4..4.7
## from the axis, outside the frame and at some angles behind the camera. A sphere of radius r is fully in view when r <= d * sin(half fov).
const CAM_DIST := 4.6
const CAM_FOV_DEG := 75.0
const FRAME_FILL := 0.92
## Plume reach used for framing: the longest plume of any shape (so changing the look never rescales the ship).
const PLUME_LAYERS_MAX := 6
## Turntable button (top-right).
const BTN_SIZE := 26.0
const BTN_MARGIN := 6.0
## stat key -> [label id, fallback label, field in ships.json, higher_is_better]
const STATS := [
	["cargo", "LBL_STAT_CARGO", "Cargo", "cargo_mult", true],
	["upkeep", "LBL_STAT_UPKEEP", "Upkeep", "upkeep_mult", false],
	["trip", "LBL_STAT_TRIP", "Trip cost", "trip_mult", false],
	["price", "LBL_STAT_PRICE", "Price", "price_mult", false],
	["speed", "LBL_STAT_SPEED", "Speed", "speed", true],
	["cap", "LBL_STAT_CAP", "Fleet cap", "cap_add", true],
]

var viewport: SubViewport
var pivot: Node3D
var holder: Node3D
var dragging := false
var model_path := ""
var model_node: Node3D
var plume: EnginePlume
var _look: Dictionary = {}
var turning := true  # T358: auto-rotation on; kept across CEO changes (the preview is built once per screen)
var turn_button: Button

static func stat_text(field: String, value: float) -> String:
	if field == "cap_add":
		return "+%d" % int(value) if value > 0 else "0"
	return "x%s" % str(snappedf(value, 0.01))

func setup(size: Vector2) -> void:
	custom_minimum_size = size
	var s := StyleBoxFlat.new()
	s.bg_color = Ui.col("panel_100")
	s.border_color = Ui.col("line_200")
	s.set_border_width_all(1)
	s.set_corner_radius_all(4)
	add_theme_stylebox_override("panel", s)
	var svc := SubViewportContainer.new()
	svc.stretch = true
	svc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(svc)
	viewport = SubViewport.new()
	viewport.own_world_3d = true
	viewport.transparent_bg = true
	viewport.size = Vector2i(int(size.x), int(size.y))
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
	cam.fov = CAM_FOV_DEG
	cam.position = Vector3(0, 0.5, CAM_DIST)
	viewport.add_child(cam)
	cam.look_at_from_position(cam.position, Vector3.ZERO)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 35, 0)
	sun.light_energy = 1.3
	viewport.add_child(sun)
	pivot = Node3D.new()
	viewport.add_child(pivot)
	var catcher := Control.new()
	catcher.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	catcher.mouse_filter = Control.MOUSE_FILTER_STOP
	catcher.mouse_default_cursor_shape = Control.CURSOR_DRAG
	catcher.gui_input.connect(_on_input)
	add_child(catcher)
	_add_turn_button()

## T358: round pause / play button in the top-right corner, drawn in the Ui palette.
func _add_turn_button() -> void:
	turn_button = Button.new()
	turn_button.focus_mode = Control.FOCUS_NONE
	turn_button.custom_minimum_size = Vector2(BTN_SIZE, BTN_SIZE)
	turn_button.size = Vector2(BTN_SIZE, BTN_SIZE)
	turn_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	turn_button.anchor_left = 1.0
	turn_button.anchor_right = 1.0
	turn_button.offset_left = -BTN_SIZE - BTN_MARGIN
	turn_button.offset_right = -BTN_MARGIN
	turn_button.offset_top = BTN_MARGIN
	turn_button.offset_bottom = BTN_MARGIN + BTN_SIZE
	var r := int(BTN_SIZE * 0.5)
	for state in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Ui.col("panel_100") if state == "normal" else Ui.col("line_200")
		sb.border_color = Ui.col("line_300") if state != "normal" else Ui.col("line_200")
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(r)
		turn_button.add_theme_stylebox_override(state, sb)
	turn_button.draw.connect(_draw_turn_icon)
	turn_button.pressed.connect(toggle_turning)
	var holder_ctl := Control.new()  # a PanelContainer stretches its children; this plain Control lets the button keep its corner anchors
	holder_ctl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(holder_ctl)
	holder_ctl.add_child(turn_button)
	_refresh_turn_button()

func _draw_turn_icon() -> void:
	var c := Vector2(BTN_SIZE, BTN_SIZE) * 0.5
	var col := Ui.col("ink_muted") if not turn_button.is_hovered() else Ui.col("star_warm")
	if turning:  # pause: two bars
		turn_button.draw_rect(Rect2(c + Vector2(-5.0, -5.5), Vector2(3.5, 11.0)), col)
		turn_button.draw_rect(Rect2(c + Vector2(1.5, -5.5), Vector2(3.5, 11.0)), col)
	else:  # play: triangle
		turn_button.draw_colored_polygon(PackedVector2Array([c + Vector2(-3.5, -6.0), c + Vector2(-3.5, 6.0), c + Vector2(6.0, 0.0)]), col)

func toggle_turning() -> void:
	turning = not turning
	_refresh_turn_button()

func _refresh_turn_button() -> void:
	if turn_button == null:
		return
	turn_button.tooltip_text = StoryText.get_or("LBL_PREVIEW_PAUSE", "Stop rotation") if turning else StoryText.get_or("LBL_PREVIEW_PLAY", "Rotate")
	turn_button.queue_redraw()



func _on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
	elif event is InputEventMouseMotion and dragging and pivot != null:
		pivot.rotation.y += event.relative.x * DRAG_RAD_PER_PX

func _process(delta: float) -> void:
	if pivot != null and turning and not dragging:
		pivot.rotation.y += deg_to_rad(TURN_DEG_PER_SEC) * delta

## Shows the model, centred and scaled by measured bounds. A missing or unimported GLB leaves the preview empty.
func show_model(path: String, look: Dictionary = {}) -> void:
	model_path = path
	_look = look if not look.is_empty() else ShipLook.default_look()
	model_node = null
	plume = null
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
		var rxz := 0.000001
		for i in 8:
			var c := box.get_endpoint(i) - box.get_center()
			rxz = maxf(rxz, Vector2(c.x, c.z).length())
		var ry := maxf(box.size.y * 0.5, 0.000001)
		holder.scale = Vector3.ONE * minf(FIT_HALF_WIDTH / rxz, FIT_HALF_HEIGHT / ry)
		var reach := _plume_reach(path, box)  # T358: ship plus the longest plume must stay in frame at every angle
		if reach > 0.0:
			var limit := CAM_DIST * sin(deg_to_rad(CAM_FOV_DEG * 0.5)) * FRAME_FILL
			holder.scale = Vector3.ONE * minf(holder.scale.x, limit / reach)
		model.position = -box.get_center()
	holder.add_child(model)
	pivot.add_child(holder)
	model_node = model
	plume = EnginePlume.new()  # T356: child of the model, so the fit scale applies
	model.add_child(plume)
	plume.set_engines(Ships.engine_points_for_path(path, box))
	set_look(_look)

## T356: re-styles the shown ship (plume shape and palette, hull hue) without reloading the model.
func set_look(look: Dictionary) -> void:
	_look = look if not look.is_empty() else ShipLook.default_look()
	if model_node == null or not is_instance_valid(model_node):
		return
	ShipLook.apply_hue(model_node, float(_look.get("hue", 0.0)))
	if plume != null and is_instance_valid(plume):
		plume.set_look(_look)

## T358: farthest distance from the model centre (model units, turntable axis = Y) reached by the hull or by the longest plume of any shape.
func _plume_reach(path: String, box: AABB) -> float:
	var reach := 0.0
	for i in 8:
		var c := box.get_endpoint(i) - box.get_center()
		reach = maxf(reach, c.length())
	var ex := ShipLook.exhaust()
	var defs: Dictionary = ex.get("defaults", {})
	var n := int(defs.get("layers", PLUME_LAYERS_MAX))
	var longest := 0.0  # in engine size units, from the nozzle along +X
	for sid in ex.get("shapes", {}):
		var sh: Dictionary = ex["shapes"][sid]
		for i in n:
			var length := maxf(0.02, float(sh.get("length", 1.4)) * (1.0 + i * float(sh.get("len_step", 0.08))))
			longest = maxf(longest, length + i * float(sh.get("offset", 0.06)))
	for e in Ships.engine_points_for_path(path, box):
		var tip: Vector3 = (e["pos"] as Vector3) - box.get_center() + Vector3(float(e["size"]) * longest, 0.0, 0.0)
		reach = maxf(reach, tip.length())
	return reach

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

func _exit_tree() -> void:
	if viewport != null and is_instance_valid(viewport):
		viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
