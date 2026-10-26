extends Node3D
## T21: placeholder 3D planet map + orbit camera (WASD pan, wheel zoom, right-drag / arrow keys orbit).
## Planets come from data/planets.json. No position data exists yet, so planets
## are laid out on a ring around the origin (in the XZ plane).

signal planet_clicked(index: int)  # -1 when the click hit empty space

const PLANETS_PATH := "res://data/planets.json"

# Zoom bounds are not in gdd.md: defaults for owner decision.
const ZOOM_MIN := 0.25
const ZOOM_MAX := 3.0
const ZOOM_STEP := 1.1
const START_ZOOM := 1.0
const PAN_SPEED := 10.0          # world units per second at zoom 1
const LAYOUT_RADIUS := 6.0       # ring radius for the simple layout (world units)
const PLANET_RADIUS := 0.8
const BASE_DISTANCE := 16.0      # camera distance from focus point at zoom 1
const CAMERA_FOV := 45.0

# Orbit limits in degrees (owner-to-confirm defaults). Yaw 0 looks along -Z.
const YAW_MIN_DEG := -45.0
const YAW_MAX_DEG := 45.0
const PITCH_MIN_DEG := 20.0      # angle above the plane; never goes below it
const PITCH_MAX_DEG := 80.0
const START_YAW_DEG := 0.0
const START_PITCH_DEG := 45.0
const ORBIT_MOUSE_SENS := 0.3    # degrees per pixel of right-drag
const ORBIT_KEY_SPEED := 60.0    # degrees per second for arrow keys

var planets: Array = []
var positions: Array[Vector3] = []
var camera: Camera3D
var focus := Vector3.ZERO
var zoom: float = START_ZOOM
var yaw_deg: float = START_YAW_DEG
var pitch_deg: float = START_PITCH_DEG

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color.BLACK
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.25, 0.28, 0.35)
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40, -30, 0)
	add_child(sun)

	camera = Camera3D.new()
	camera.fov = CAMERA_FOV
	add_child(camera)
	camera.make_current()

	planets = _load_planets()
	var n := planets.size()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.55, 0.85)
	for i in n:
		var a := TAU * float(i) / float(max(n, 1)) - PI / 2.0
		var pos := Vector3(cos(a), 0.0, sin(a)) * LAYOUT_RADIUS
		positions.append(pos)
		var mi := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = PLANET_RADIUS
		sphere.height = PLANET_RADIUS * 2.0
		sphere.radial_segments = 48
		sphere.rings = 24
		sphere.material = mat
		mi.mesh = sphere
		mi.position = pos
		add_child(mi)
		var l := Label3D.new()
		l.text = str(planets[i].get("name", planets[i].get("id", "?")))
		l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		l.no_depth_test = true
		l.fixed_size = true
		l.pixel_size = 0.0008
		l.font_size = 40
		l.outline_size = 8
		l.position = pos + Vector3(0, -(PLANET_RADIUS + 0.5), 0)
		add_child(l)
	_update_camera()

func _load_planets() -> Array:
	var f := FileAccess.open(PLANETS_PATH, FileAccess.READ)
	if f == null:
		push_error("Cannot open " + PLANETS_PATH)
		return []
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("planets"):
		push_error("Bad planets.json")
		return []
	return parsed["planets"]

func _process(delta: float) -> void:
	var dir := Vector2(_axis(KEY_A, KEY_D), _axis(KEY_W, KEY_S))
	if dir != Vector2.ZERO:
		dir = dir.normalized()
		var yaw := deg_to_rad(yaw_deg)
		var right := Vector3(cos(yaw), 0, -sin(yaw))
		var fwd := Vector3(-sin(yaw), 0, -cos(yaw))
		focus += (right * dir.x - fwd * dir.y) * PAN_SPEED * delta / zoom
	var rot := Vector2(_axis(KEY_LEFT, KEY_RIGHT), _axis(KEY_DOWN, KEY_UP))
	if rot != Vector2.ZERO:
		_orbit_by(rot.x * ORBIT_KEY_SPEED * delta, rot.y * ORBIT_KEY_SPEED * delta)
	_update_camera()

func _axis(neg: Key, pos: Key) -> float:
	return float(Input.is_physical_key_pressed(pos)) - float(Input.is_physical_key_pressed(neg))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_by(ZOOM_STEP)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_by(1.0 / ZOOM_STEP)
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_RIGHT) != 0:
		_orbit_by(event.relative.x * ORBIT_MOUSE_SENS, event.relative.y * ORBIT_MOUSE_SENS)

func _unhandled_input(event: InputEvent) -> void:
	# T04: left click picks a planet with a camera ray / sphere test.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		planet_clicked.emit(pick_planet(event.position))

## Returns index of nearest planet hit by the camera ray through screen_pos, or -1.
func pick_planet(screen_pos: Vector2) -> int:
	var origin := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	var best := -1
	var best_t := INF
	for i in positions.size():
		var oc := origin - positions[i]
		var b := oc.dot(dir)
		var c := oc.dot(oc) - PLANET_RADIUS * PLANET_RADIUS
		var disc := b * b - c
		if disc < 0.0:
			continue
		var t := -b - sqrt(disc)
		if t > 0.0 and t < best_t:
			best_t = t
			best = i
	return best

func _orbit_by(d_yaw: float, d_pitch: float) -> void:
	yaw_deg = clampf(yaw_deg + d_yaw, YAW_MIN_DEG, YAW_MAX_DEG)
	pitch_deg = clampf(pitch_deg + d_pitch, PITCH_MIN_DEG, PITCH_MAX_DEG)

func _zoom_by(factor: float) -> void:
	zoom = clampf(zoom * factor, ZOOM_MIN, ZOOM_MAX)

func _update_camera() -> void:
	var yaw := deg_to_rad(yaw_deg)
	var pitch := deg_to_rad(pitch_deg)
	var dist := BASE_DISTANCE / zoom
	var offset := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * dist
	camera.position = focus + offset
	camera.look_at(focus, Vector3.UP)
