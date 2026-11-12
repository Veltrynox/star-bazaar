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
## T359: framing uses the CURRENT look's plume; the hull never drops below this share of its fitted size (70% of the pre-T358 size
## = hull radius 1.4 at camera 3.4, i.e. 1.89 at CAM_DIST 4.6, against the fitted 2.0).
const HULL_MIN_RADIUS := 1.4 * CAM_DIST / 3.4
const FIT_TWEEN_SEC := 0.25
const CAM_EASE := 12.0  # per second; about 0.3 s to settle
const CAM_HOME := Vector3(0, 0.5, CAM_DIST)
const ENGINE_DIR := Vector3(0.8, 0.35, 0.0)  # in (tail, up, side) weights: rear three-quarter, slightly above and to the side
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
var view_button: Button
var view_engines := false  # T359: camera focus on the engines; kept across CEO changes
var _turn_before := true
var cam: Camera3D
var _cam_pos := CAM_HOME
var _cam_look := Vector3.ZERO
var _box := AABB()
var _hull_scale := 1.0
var _fit_tween: Tween

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
	viewport.transparent_bg = false  # T359: additive plume light needs an opaque buffer (alpha 0 hid it outside the hull outline)
	viewport.size = Vector2i(int(size.x), int(size.y))
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	svc.add_child(viewport)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Ui.col("panel_100")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.6, 0.7)
	env.ambient_light_energy = 0.7
	var we := WorldEnvironment.new()
	we.environment = env
	viewport.add_child(we)
	cam = Camera3D.new()
	cam.fov = CAM_FOV_DEG
	cam.position = CAM_HOME
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
	_add_view_button()

## T358: round pause / play button in the top-right corner, drawn in the Ui palette.
func _add_turn_button() -> void:
	turn_button = _make_round_button(0)
	turn_button.draw.connect(_draw_turn_icon)
	turn_button.pressed.connect(toggle_turning)
	_refresh_turn_button()

## T359: second round button, left of the first, toggles the engine close-up.
func _add_view_button() -> void:
	view_button = _make_round_button(1)
	view_button.draw.connect(_draw_view_icon)
	view_button.pressed.connect(toggle_view)
	_refresh_view_button()

func _make_round_button(slot: int) -> Button:
	var b := Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(BTN_SIZE, BTN_SIZE)
	b.size = Vector2(BTN_SIZE, BTN_SIZE)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.anchor_left = 1.0
	b.anchor_right = 1.0
	var right := BTN_MARGIN + slot * (BTN_SIZE + BTN_MARGIN)
	b.offset_left = -BTN_SIZE - right
	b.offset_right = -right
	b.offset_top = BTN_MARGIN
	b.offset_bottom = BTN_MARGIN + BTN_SIZE
	var r := int(BTN_SIZE * 0.5)
	for state in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Ui.col("panel_100") if state == "normal" else Ui.col("line_200")
		sb.border_color = Ui.col("line_300") if state != "normal" else Ui.col("line_200")
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(r)
		b.add_theme_stylebox_override(state, sb)
	var holder_ctl := Control.new()  # a PanelContainer stretches its children; this plain Control lets the button keep its corner anchors
	holder_ctl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(holder_ctl)
	holder_ctl.add_child(b)
	return b

## Crosshair: ring, four ticks and a dot. Filled dot while the engine view is on.
func _draw_view_icon() -> void:
	var c := Vector2(BTN_SIZE, BTN_SIZE) * 0.5
	var col := Ui.col("star_warm") if (view_engines or view_button.is_hovered()) else Ui.col("ink_muted")
	view_button.draw_arc(c, 5.0, 0.0, TAU, 20, col, 1.5)
	for d in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		view_button.draw_line(c + d * 3.0, c + d * 8.0, col, 1.5)
	view_button.draw_circle(c, 1.6, col)

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

## T359: engine close-up on/off. Entering stops the turntable; leaving restores the turning state from before.
func toggle_view() -> void:
	set_view_engines(not view_engines)

func set_view_engines(on: bool) -> void:
	if on == view_engines:
		return
	view_engines = on
	if on:
		_turn_before = turning
		turning = false
	else:
		turning = _turn_before
	_refresh_turn_button()
	_refresh_view_button()

func _refresh_view_button() -> void:
	if view_button == null:
		return
	view_button.tooltip_text = StoryText.get_or("LBL_PREVIEW_VIEW_SHIP", "Whole ship") if view_engines else StoryText.get_or("LBL_PREVIEW_VIEW_ENGINES", "Focus engines")
	view_button.queue_redraw()

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
	_update_camera(delta)

## T359: goal pose for the current view; the camera eases to it. Engine view aims at the centroid of the engine points as they are
## now (pivot turn included); the offset direction is fixed in the ship's rest frame, so turning the ship swings the engines past.
func _update_camera(delta: float) -> void:
	if cam == null:
		return
	var goal_pos := CAM_HOME
	var goal_look := Vector3.ZERO
	var eng := _engine_goal()
	if view_engines and not eng.is_empty():
		goal_pos = eng["pos"]
		goal_look = eng["look"]
	var k := 1.0 - exp(-CAM_EASE * delta)
	_cam_pos = _cam_pos.lerp(goal_pos, k)
	_cam_look = _cam_look.lerp(goal_look, k)
	cam.look_at_from_position(_cam_pos, _cam_look, Vector3.UP)

func _engine_goal() -> Dictionary:
	if model_node == null or not is_instance_valid(model_node) or plume == null or holder == null:
		return {}
	var pts := Ships.engine_points_for_path(model_path, _box)
	if pts.is_empty():
		return {}
	var wp: Array = []
	var centroid := Vector3.ZERO
	var size := 0.0
	for e in pts:
		var w: Vector3 = model_node.to_global(e["pos"] as Vector3)
		wp.append(w)
		centroid += w
		size = maxf(size, float(e["size"]) * holder.scale.x)
	centroid /= float(pts.size())
	var spread := 0.0
	for w in wp:
		spread = maxf(spread, (w - centroid).length())
	var res := plume.resolved()
	var first_part := size * minf(float(res.get("length", 1.4)), 2.0)  # first part of the plume, not all of it
	var radius := spread + size * 1.0 + first_part * 0.4
	var dist := maxf(radius / _half_fov_sin() * 1.05, size * 3.0)
	# Ship rest frame (no pivot turn): tail = model +X, up = world up.
	var rest: Basis = holder.transform.basis * model_node.transform.basis
	var tail := (rest * Vector3.RIGHT).normalized()
	var side := Vector3.UP.cross(tail).normalized()
	var dir := (tail * ENGINE_DIR.x + Vector3.UP * ENGINE_DIR.y + side * 0.45).normalized()
	return {"pos": centroid + dir * dist, "look": centroid}

## Shows the model, centred and scaled by measured bounds. A missing or unimported GLB leaves the preview empty.
func show_model(path: String, look: Dictionary = {}) -> void:
	model_path = path
	_look = look if not look.is_empty() else ShipLook.default_look()
	model_node = null
	plume = null
	if _fit_tween != null:
		_fit_tween.kill()
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
		_hull_scale = minf(FIT_HALF_WIDTH / rxz, FIT_HALF_HEIGHT / ry)
		holder.scale = Vector3.ONE * _hull_scale
		model.position = -box.get_center()
	holder.add_child(model)
	pivot.add_child(holder)
	model_node = model
	plume = EnginePlume.new()  # T356: child of the model, so the fit scale applies
	model.add_child(plume)
	_box = box
	plume.set_engines(Ships.engine_points_for_path(path, box))
	set_look(_look)
	holder.scale = Vector3.ONE * _target_scale()  # no tween on a new model

## T356: re-styles the shown ship (plume shape and palette, hull hue) without reloading the model.
func set_look(look: Dictionary) -> void:
	_look = look if not look.is_empty() else ShipLook.default_look()
	if model_node == null or not is_instance_valid(model_node):
		return
	ShipLook.apply_hue(model_node, float(_look.get("hue", 0.0)))
	if plume != null and is_instance_valid(plume):
		plume.set_look(_look)
		if holder != null:
			var to := _target_scale()
			if _fit_tween != null:
				_fit_tween.kill()
			if absf(to - holder.scale.x) > 0.0001:
				_fit_tween = create_tween()
				_fit_tween.tween_property(holder, "scale", Vector3.ONE * to, FIT_TWEEN_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

## T359: holder scale that keeps hull plus the CURRENT plume inside the view sphere at every turntable angle, but never makes the
## hull smaller than HULL_MIN_RADIUS (the hull is fitted to radius 2.0 or less).
func _target_scale() -> float:
	if _box.size.length() <= 0.0:
		return 1.0
	var reach := _plume_reach()
	var s := _hull_scale
	if reach > 0.0:
		var limit := CAM_DIST * _half_fov_sin() * FRAME_FILL
		s = minf(s, limit / reach)
	return maxf(s, _hull_scale * minf(1.0, HULL_MIN_RADIUS / FIT_HALF_WIDTH))

## Sine of the narrower half field of view (the fov is vertical; a portrait view is narrower sideways).
func _half_fov_sin() -> float:
	var half := deg_to_rad(CAM_FOV_DEG * 0.5)
	var asp := 1.0
	if viewport != null and viewport.size.y > 0:
		asp = float(viewport.size.x) / float(viewport.size.y)
	return sin(atan(tan(half) * minf(1.0, asp)))

## Farthest distance from the model centre (model units, turntable axis = Y) reached by the hull or the current plume.
func _plume_reach() -> float:
	var reach := 0.0
	for i in 8:
		var c := _box.get_endpoint(i) - _box.get_center()
		reach = maxf(reach, c.length())
	if plume == null or not is_instance_valid(plume):
		return reach
	var res := plume.resolved()
	var n := int(res.get("layers", 6))
	var longest := 0.0  # in engine size units, from the nozzle along +X
	for i in n:
		var length := maxf(0.02, float(res.get("length", 1.4)) * (1.0 + i * float(res.get("len_step", 0.08))))
		longest = maxf(longest, length + i * float(res.get("offset", 0.06)))
	for e in Ships.engine_points_for_path(model_path, _box):
		var tip: Vector3 = (e["pos"] as Vector3) - _box.get_center() + Vector3(float(e["size"]) * longest, 0.0, 0.0)
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
