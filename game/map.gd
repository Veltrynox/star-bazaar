extends Node3D
## T21: placeholder 3D planet map + orbit camera (WASD pan, wheel zoom, right-drag / arrow keys orbit).
## Planets come from data/planets.json. No position data exists yet, so planets
## are laid out on a ring around the origin (in the XZ plane).

signal planet_clicked(index: int)  # -1 when the click hit empty space
signal route_clicked(id: int)      # T07b: click on a route line (no planet under the cursor)

const PLANETS_PATH := "res://data/planets.json"

# Zoom bounds are not in gdd.md: defaults for owner decision.
# T33: the tunables below are vars (zoom_min ... planet_scale) so the debug menu can edit them live.
const ZOOM_STEP := 1.1
const START_ZOOM := 1.0
const PAN_SPEED := 10.0          # world units per second at zoom 1
const LAYOUT_RADIUS := 6.0       # ring radius for the simple layout (world units)
const MAP_UNIT_SCALE := 0.02     # world units per map unit in planets.json (old ring: 300 map units = 6 world units)
const PLANET_RADIUS := 0.8
const BASE_DISTANCE := 16.0      # camera distance from focus point at zoom 1
const CAMERA_FOV := 45.0
const PLANET_SPHERE := preload("res://art/planet_fx/planet_sphere.tscn")  # unit-radius sphere; scaled to planet_radius()

# Orbit limits in degrees (owner-to-confirm defaults). Yaw 0 looks along -Z.
const START_YAW_DEG := 0.0
const START_PITCH_DEG := 45.0
const ORBIT_MOUSE_SENS := 0.3    # degrees per pixel of right-drag
const ORBIT_KEY_SPEED := 60.0    # degrees per second for arrow keys

# T33 tunables (live-editable, runtime only, never saved)
var zoom_min := 0.25
var zoom_max := 3.0
var yaw_min_deg := -45.0
var yaw_max_deg := 45.0
var pitch_min_deg := 20.0        # angle above the plane; never goes below it
var pitch_max_deg := 80.0
var sun_radius := 0.75
var planet_scale := 1.0          # multiplies PLANET_RADIUS (visual size and click radius)
var keys_enabled := true         # T33: debug menu turns this off while typing in a field

var planets: Array = []
const BELT_INNER := 1.7   # clear of the glow shell (1.12) and the pick halo (up to 1.46), in planet radii
const BELT_OUTER := 2.3
const BELT_SPIN := 0.015  # turns per second about the planet's axis (shader time, no per-frame code)
## Flat ring quad with a circular mask. Noise is sampled by (radius, angle + TIME), so the belt turns on the GPU.
const BELT_SHADER := """shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;
uniform float inner = 0.74;      // inner edge as a fraction of the quad half-width
uniform float spin = 0.015;
uniform vec3 key_dir = vec3(0.0, 0.5, 0.8);
uniform vec4 key_color : source_color = vec4(1.0, 0.76, 0.42, 1.0);
uniform vec4 dust_col : source_color = vec4(0.45, 0.40, 0.34, 1.0);
uniform vec4 rock_col : source_color = vec4(0.72, 0.68, 0.62, 1.0);
varying vec3 wpos;
varying vec3 ctr;
float h21(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1, 0)), f.x), mix(h21(i + vec2(0, 1)), h21(i + vec2(1, 1)), f.x), f.y);
}
void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	ctr = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
}
void fragment() {
	vec2 q = UV * 2.0 - 1.0;
	float r = length(q);
	float t = (r - inner) / (1.0 - inner);
	if (t < 0.0 || t > 1.0) discard;
	float ang = atan(q.y, q.x) / TAU + TIME * spin;
	// Pattern wraps around the angle: sample on a circle of noise so there is no seam.
	vec2 c = vec2(cos(ang * TAU), sin(ang * TAU));
	float n1 = vnoise(c * 12.0 + vec2(t * 18.0, 0.0));
	float n2 = vnoise(c * 44.0 + vec2(t * 80.0, 7.0));
	float bands = 0.5 + 0.5 * sin(t * 40.0 + n1 * 5.0);
	float dens = n1 * 0.55 + n2 * 0.45;
	float edge = smoothstep(0.0, 0.12, t) * smoothstep(1.0, 0.8, t);
	float a = smoothstep(0.38, 0.62, dens * 0.7 + bands * 0.45) * edge;   // gaps where the mix is low
	if (a < 0.02) discard;
	vec3 n = vec3(0.0, 1.0, 0.0);
	float l = abs(dot(n, normalize(key_dir)));
	float lit = 0.25 + 0.75 * pow(l, 0.6);
	vec3 col = mix(dust_col.rgb, rock_col.rgb, n2) * (0.1 + key_color.rgb * lit * 1.3);
	ALBEDO = col;
	ALPHA = a * 0.9;
}
"""
var planet_spheres: Array[MeshInstance3D] = []
var belt_materials: Dictionary = {}  # planet index -> ShaderMaterial of its asteroid belt  # one planet_sphere.tscn per planet, at its 3D position
var planet_labels: Array[Label3D] = []
var sun_mesh: SphereMesh
var focus_sun_pos := Vector3.ZERO  # world position of the sun sphere (the screen-space light source for the FX)
var positions: Array[Vector3] = []
var camera: Camera3D
var focus := Vector3.ZERO
var zoom: float = START_ZOOM
var yaw_deg: float = START_YAW_DEG
var pitch_deg: float = START_PITCH_DEG
var pending_hint: MeshInstance3D  # T57 halo on the planet with a pending connection
var hint: MeshInstance3D  # T28 pulsing halo, null until first requested
var route_lines: Dictionary = {}  # T07b: route id -> route_line.gd node
var _route_list: Array = []       # last list given to set_routes (rebuilt after tunable changes)

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
	# Planet FX highlights are HDR (>1.0): glow on this environment (needs rendering/viewport/hdr_2d).
	env.glow_enabled = true
	env.glow_hdr_threshold = 1.0
	env.glow_intensity = 0.8
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE

	# T05: decorative star field background (visual only; see game/galaxy/star_field.gd)
	add_child(load("res://game/galaxy/star_field.gd").new())

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-40, -30, 0)
	add_child(light)

	camera = Camera3D.new()
	camera.fov = CAMERA_FOV
	add_child(camera)
	camera.make_current()

	planets = _load_planets()
	for p in planets:
		p["system"] = 1  # T85: planets.json is system 1
	for i in planets.size():
		_make_planet(i)
	_frame_planets()
	_add_sun(focus)
	_add_orbit_rings(focus)
	_update_camera()

## Orbit rings: thin circles on the ground plane through each planet, centred on the sun, plus one dashed
## outer ring. The camera pitch gives the tilt. Colours: theme tokens line_200 / line_100.
## Visual only: no collision, no shadows, never hit by the planet click test.
func _add_orbit_rings(center: Vector3) -> void:
	var inner := Ui.col("line_200")
	var outer := Ui.col("line_100")
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var im := ImmediateMesh.new()
	var max_r := 0.0
	var segs := 128
	for p in positions:
		var r := Vector2(p.x - center.x, p.z - center.z).length()
		if r < 0.01:
			continue
		max_r = maxf(max_r, r)
		im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, mat)
		im.surface_set_color(inner)
		for s in segs + 1:
			var a := TAU * float(s) / float(segs)
			im.surface_add_vertex(center + Vector3(cos(a), 0.0, sin(a)) * r)
		im.surface_end()
	if max_r > 0.0:
		var ro := max_r * 1.2
		var dashes := 90  # dash on 1 step, gap on 3 (preview: 2 6)
		im.surface_begin(Mesh.PRIMITIVE_LINES, mat)
		im.surface_set_color(outer)
		for d in dashes:
			var a0 := TAU * float(d) / float(dashes)
			var a1 := a0 + TAU / float(dashes) * 0.25
			im.surface_add_vertex(center + Vector3(cos(a0), 0.0, sin(a0)) * ro)
			im.surface_add_vertex(center + Vector3(cos(a1), 0.0, sin(a1)) * ro)
		im.surface_end()
	var mi := MeshInstance3D.new()
	mi.name = "OrbitRings"
	mi.mesh = im
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)

## T85: one planet node (mesh + label) for planets[i]; position from x,y or the old ring layout.
func _make_planet(i: int) -> void:
	var n := planets.size()
	var pos: Vector3
	if planets[i].has("x") and planets[i].has("y"):
		pos = Vector3(float(planets[i]["x"]), 0.0, float(planets[i]["y"])) * MAP_UNIT_SCALE
	else:
		var a := TAU * float(i) / float(max(n, 1)) - PI / 2.0
		pos = Vector3(cos(a), 0.0, sin(a)) * LAYOUT_RADIUS
	positions.append(pos)
	var sph: MeshInstance3D = PLANET_SPHERE.instantiate()
	sph.planet_type = str(planets[i].get("type", "")).to_lower()
	sph.rarity = clampf(float(planets[i].get("rarity", 0.0)), 0.0, 1.0)
	var h := absi(str(planets[i].get("id", i)).hash())
	sph.planet_id = str(planets[i].get("id", i))  # the sphere picks its own variant and rim light from this
	sph.position = pos
	sph.scale = Vector3.ONE * planet_radius()
	add_child(sph)
	planet_spheres.append(sph)
	if belt_slot(h) == 0:  # 10% of the planets carry an asteroid belt
		_add_belt(i, sph, h)
	_aim_sphere(i)
	var l := Label3D.new()
	l.text = str(planets[i].get("name", planets[i].get("id", "?")))
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.fixed_size = true
	l.pixel_size = 0.0008
	l.font_size = 40
	l.outline_size = 8
	l.position = pos + Vector3(0, -(planet_radius() + 0.5), 0)
	add_child(l)
	planet_labels.append(l)

## Focus on the centre of the planets' bounding box on the ground plane.
func _frame_planets() -> void:
	if positions.size() > 0:
		var lo := positions[0]
		var hi := positions[0]
		for p in positions:
			lo = Vector3(minf(lo.x, p.x), 0.0, minf(lo.z, p.z))
			hi = Vector3(maxf(hi.x, p.x), 0.0, maxf(hi.z, p.z))
		focus = (lo + hi) * 0.5

## T85: a permitted system appears. Appends IN PLACE (trade, events and the engine share this array)
## so indexes of earlier planets never change. Returns the index of the first new planet.
func add_planets(list: Array) -> int:
	var first := planets.size()
	for p in list:
		planets.append(p)
		_make_planet(planets.size() - 1)
	_frame_planets()
	return first

## T105: put the camera focus on the middle of one system's planets.
func focus_system(id: int) -> void:
	var lo := Vector3.ZERO
	var hi := Vector3.ZERO
	var first := true
	for i in planets.size():
		if int(planets[i].get("system", 1)) != id or i >= positions.size():
			continue
		var p := positions[i]
		lo = p if first else Vector3(minf(lo.x, p.x), 0.0, minf(lo.z, p.z))
		hi = p if first else Vector3(maxf(hi.x, p.x), 0.0, maxf(hi.z, p.z))
		first = false
	if not first:
		focus = (lo + hi) * 0.5

## Plain yellow sphere in the middle of the map (visual only, not clickable).
func _add_sun(pos: Vector3) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.85, 0.2)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var sphere := SphereMesh.new()
	sphere.radius = sun_radius
	sphere.height = sun_radius * 2.0
	sphere.radial_segments = 48
	sphere.rings = 24
	sphere.material = mat
	sun_mesh = sphere
	var mi := MeshInstance3D.new()
	mi.mesh = sphere
	mi.position = pos
	focus_sun_pos = pos
	add_child(mi)

## T28: show or hide the pulsing "click me" halo around planet `index`.
func set_hint(index: int, on: bool) -> void:
	if not on or index < 0 or index >= positions.size():
		if hint != null:
			hint.queue_free()
			hint = null
		return
	if hint == null:
		hint = load("res://game/planet_hint.gd").new()
		add_child(hint)
		hint.setup(planet_radius())
	hint.position = positions[index]

## T57: halo on the planet holding a pending Buy/Sell order; -1 removes it.
func set_pending(index: int) -> void:
	if index < 0 or index >= positions.size():
		if pending_hint != null:
			pending_hint.queue_free()
			pending_hint = null
		return
	if pending_hint == null:
		pending_hint = load("res://game/planet_hint.gd").new()
		add_child(pending_hint)
		pending_hint.setup(planet_radius())
	pending_hint.position = positions[index]

## T07b: show one glowing line per route. routes: Array of {id, a, b, ships, status}.
## Lines are created once per route and only restyled afterwards; removed when the route is gone.
func set_routes(routes: Array) -> void:
	_route_list = routes
	var seen := {}
	for r in routes:
		var id := int(r["id"])
		var a := int(r["a"])
		var b := int(r["b"])
		if a < 0 or b < 0 or a >= positions.size() or b >= positions.size():
			continue
		seen[id] = true
		var half := false  # T68: the opposite direction exists on the same pair: each arrow covers half the line
		for o in routes:
			if int(o["a"]) == b and int(o["b"]) == a:
				half = true
		var line = route_lines.get(id)
		if line != null and (line.pair_a != a or line.pair_b != b or line.half != half):
			line.queue_free()
			route_lines.erase(id)
			line = null
		if line == null:
			line = load("res://game/route_line.gd").new()
			add_child(line)
			line.setup(id, a, b, positions[a], positions[b], planet_radius(), half)
			route_lines[id] = line
		line.set_style(str(r.get("status", "running")), int(r.get("ships", 1)))
	for id in route_lines.keys():
		if not seen.has(id):
			route_lines[id].queue_free()
			route_lines.erase(id)

## Route id whose line is within a few pixels of screen_pos, or -1.
func pick_route(screen_pos: Vector2) -> int:
	var best := -1
	var best_d := 14.0
	for id in route_lines:
		var d: float = route_lines[id].screen_distance(camera, screen_pos)
		if d < best_d:
			best_d = d
			best = id
	return best

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

func planet_radius() -> float:
	return PLANET_RADIUS * planet_scale

## T33: call after changing a tunable var. Re-applies sizes and re-clamps the camera.
func apply_tunables() -> void:
	zoom_max = maxf(zoom_max, zoom_min)
	yaw_max_deg = maxf(yaw_max_deg, yaw_min_deg)
	pitch_max_deg = maxf(pitch_max_deg, pitch_min_deg)
	zoom = clampf(zoom, zoom_min, zoom_max)
	yaw_deg = clampf(yaw_deg, yaw_min_deg, yaw_max_deg)
	pitch_deg = clampf(pitch_deg, pitch_min_deg, pitch_max_deg)
	for sp in planet_spheres:
		sp.scale = Vector3.ONE * planet_radius()
	for i in planet_labels.size():
		planet_labels[i].position = positions[i] + Vector3(0, -(planet_radius() + 0.5), 0)
	if sun_mesh != null:
		sun_mesh.radius = sun_radius
		sun_mesh.height = sun_radius * 2.0
	if hint != null:  # rebuilt at the new size on the next set_hint call
		hint.queue_free()
		hint = null
	for id in route_lines.keys():  # route lines start at the planet surface: rebuild at the new size
		route_lines[id].queue_free()
	route_lines.clear()
	set_routes(_route_list)
	_update_camera()

func _process(delta: float) -> void:
	if not keys_enabled:
		_update_camera()
		return
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
		var hit := pick_planet(event.position)
		if hit < 0:
			var rid := pick_route(event.position)
			if rid >= 0:
				route_clicked.emit(rid)
				return
		planet_clicked.emit(hit)

## Returns index of nearest planet hit by the camera ray through screen_pos, or -1.
func pick_planet(screen_pos: Vector2) -> int:
	var origin := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	var best := -1
	var best_t := INF
	for i in positions.size():
		var oc := origin - positions[i]
		var b := oc.dot(dir)
		var c := oc.dot(oc) - planet_radius() * planet_radius()
		var disc := b * b - c
		if disc < 0.0:
			continue
		var t := -b - sqrt(disc)
		if t > 0.0 and t < best_t:
			best_t = t
			best = i
	return best

func _orbit_by(d_yaw: float, d_pitch: float) -> void:
	yaw_deg = clampf(yaw_deg + d_yaw, yaw_min_deg, yaw_max_deg)
	pitch_deg = clampf(pitch_deg + d_pitch, pitch_min_deg, pitch_max_deg)

func _zoom_by(factor: float) -> void:
	zoom = clampf(zoom * factor, zoom_min, zoom_max)

func _update_camera() -> void:
	var yaw := deg_to_rad(yaw_deg)
	var pitch := deg_to_rad(pitch_deg)
	var dist := BASE_DISTANCE / zoom
	var offset := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * dist
	camera.position = focus + offset
	camera.look_at(focus, Vector3.UP)
	_update_fx()

## Flat textured ring in the sphere's unit space (scales with the planet), tilted a little. One quad, one shader.
func _add_belt(i: int, sph: MeshInstance3D, h: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = h
	var quad := PlaneMesh.new()
	quad.size = Vector2.ONE * BELT_OUTER * 2.0
	var sh := Shader.new()
	sh.code = BELT_SHADER
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("inner", BELT_INNER / BELT_OUTER)
	mat.set_shader_parameter("spin", BELT_SPIN)
	quad.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = quad
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.rotation_degrees = Vector3(rng.randf_range(10.0, 25.0), 0.0, rng.randf_range(-10.0, 10.0))
	sph.add_child(mi)
	belt_materials[i] = mat

## Points the sphere's key light (object space, no rotation, so world space) from planet i towards the sun.
func _aim_sphere(i: int) -> void:
	if i >= planet_spheres.size() or i >= positions.size():
		return
	var d := focus_sun_pos - positions[i]
	if d.length() < 0.001:
		return
	d = d.normalized()
	if not d.is_equal_approx(planet_spheres[i].key_dir):
		planet_spheres[i].key_dir = d
		if belt_materials.has(i):
			belt_materials[i].set_shader_parameter("key_dir", d)

func _update_fx() -> void:
	for i in planet_spheres.size():
		_aim_sphere(i)

static func _mix(h: int) -> int:
	return (h ^ (h >> 15)) * 2246822519 & 0x7FFFFFFF

## 0..9 slot for belts from the id hash, independent of the sphere look.
static func belt_slot(h: int) -> int:
	var x := _mix(h)
	return ((x >> 3) ^ (x >> 11) ^ (x >> 21)) % 10
