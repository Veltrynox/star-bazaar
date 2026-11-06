extends PanelContainer
## Small turntable preview of a ship GLB (drag to turn), same camera, light and fit as the old ship screen (game/ship_setup.gd).
## Used by the company screen. Also holds the ship stat rows shared with it.

const TURN_DEG_PER_SEC := 18.0
const DRAG_RAD_PER_PX := 0.012
const FIT_HALF_WIDTH := 2.0
const FIT_HALF_HEIGHT := 1.15
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
	cam.position = Vector3(0, 0.5, 3.4)
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

func _on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
	elif event is InputEventMouseMotion and dragging and pivot != null:
		pivot.rotation.y += event.relative.x * DRAG_RAD_PER_PX

func _process(delta: float) -> void:
	if pivot != null and not dragging:
		pivot.rotation.y += deg_to_rad(TURN_DEG_PER_SEC) * delta

## Shows the model, centred and scaled by measured bounds. A missing or unimported GLB leaves the preview empty.
func show_model(path: String) -> void:
	model_path = path
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

func _exit_tree() -> void:
	if viewport != null and is_instance_valid(viewport):
		viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
