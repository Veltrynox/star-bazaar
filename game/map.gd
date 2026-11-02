extends Node3D
## T21: placeholder 3D planet map + orbit camera (WASD pan, wheel zoom, right-drag / arrow keys orbit).
## Planets come from data/planets.json. No position data exists yet, so planets
## are laid out on a ring around the origin (in the XZ plane).

signal planet_clicked(index: int)  # -1 when the click hit empty space
signal empty_double_clicked          # double click on empty space: no planet, no route (opens the galaxy view)
signal route_clicked(id: int)      # T07b: click on a route line (no planet under the cursor)

const PlanetTypes := preload("res://game/planet_types.gd")
const Systems := preload("res://game/systems.gd")
const Shield := preload("res://game/shield.gd")
const PLANETS_PATH := "res://data/planets.json"

# Zoom bounds are not in gdd.md: defaults for owner decision.
# T33: the tunables below are vars (zoom_min ... planet_scale) so the debug menu can edit them live.
const ZOOM_STEP := 1.1
const START_ZOOM := 1.0
const PAN_SPEED := 10.0          # world units per second at zoom 1
const LAYOUT_RADIUS := 6.0       # ring radius for the simple layout (world units)
const MAP_UNIT_SCALE := 0.02     # world units per map unit in planets.json (old ring: 300 map units = 6 world units)
const PLANET_RADIUS := 0.8       # base radius (before planet_scale)
const PLANET_SIZE := 1.3         # planet size multiplier: planets are x1.3 the old size; the debug menu starts here
const BASE_DISTANCE := 16.0      # camera distance from focus point at zoom 1
const CAMERA_FOV := 45.0
const PLANET_SPHERE := preload("res://art/planet_fx/planet_sphere.tscn")  # unit-radius sphere; scaled to planet_radius()

# Orbit limits in degrees (owner-to-confirm defaults). Yaw 0 looks along -Z.
const START_YAW_DEG := 0.0
const START_PITCH_DEG := 45.0
const ORBIT_MOUSE_SENS := 0.3    # degrees per pixel of right-drag
const PAN_LIMIT_MIN := 6.0       # floor for the pan limit radius (world units)
const ORBIT_KEY_SPEED := 60.0    # degrees per second for arrow keys

# T33 tunables (live-editable, runtime only, never saved)
var zoom_min := 0.25
var zoom_max := 3.0
var pan_margin := 1.3             # camera focus may stray this many times the outermost planet's orbit radius from the system centre
var yaw_min_deg := -45.0
var yaw_max_deg := 45.0
var pitch_min_deg := 20.0        # angle above the plane; never goes below it
var pitch_max_deg := 80.0
var sun_radius := 0.75
var sun_node: Node3D  # T132: animated 3D sun
var suns := {}         # system id -> its sun node (art/sun/sun_flare.gd); every open system has its own sun
var sun_positions := {}  # system id -> world position of that sun
var orbit_rings := {}    # system id -> its orbit ring mesh
var orbit_centers := {}  # system id -> centre of its orbit rings (the sun's place), for rebuilding the dust
var hex_ring: Node3D  # T110: hexagon ring around the sun, shown during EV20
var key_light: DirectionalLight3D
var planet_scale := PLANET_SIZE  # multiplies PLANET_RADIUS (visual size, click radius, route start, names, halos, dust)
var keys_enabled := true         # T33: debug menu turns this off while typing in a field

var planets: Array = []
var view_system := 1  # each solar system is its own space: only this system's planets, routes and sun are shown
const BELT_INNER := 0.85  # in sphere units (planet radii; the visible body is about 0.5): halved from 1.7, clears the body, may overlap the glow shell
const BELT_OUTER := 1.45  # halved from 2.9: the belt is twice as close to the planet, same 0.6 width in these units
## Flat ring quad with a circular mask. The asteroid ring PNG is sampled by (radius, angle), static.
const BELT_SHADER := """shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;
uniform float inner = 0.74;      // inner edge as a fraction of the quad half-width
uniform vec3 key_dir = vec3(0.0, 0.5, 0.8);
uniform vec4 key_color : source_color = vec4(1.0, 0.76, 0.42, 1.0);
uniform sampler2D ring_tex : filter_linear_mipmap, repeat_disable;  // asteroid1/2.png: dusty ring on black
uniform float tex_in = 0.38;     // belt radius is remapped onto the part of the PNG that holds dust (set per file in _add_belt)
uniform float tex_out = 0.96;
uniform float brighten = 3.5;   // PNG dust is lum 0.1 to 0.3 (dark): at 1.2 with alpha 0.2 the grains were about 5% of the sky colour, invisible; 3.5 keeps them readable at alpha 0.5
varying vec3 wpos;
varying vec3 ctr;
void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	ctr = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
}
void fragment() {
	vec2 q = UV * 2.0 - 1.0;
	float r = length(q);
	float t = (r - inner) / (1.0 - inner);
	if (t < 0.0 || t > 1.0) discard;
	float ang = atan(q.y, q.x);   // fixed angle, no rotation; a circular image has no seam
	vec2 uv = 0.5 + 0.5 * mix(tex_in, tex_out, t) * vec2(cos(ang), sin(ang));
	vec3 tex = texture(ring_tex, uv).rgb;
	float edge = smoothstep(0.0, 0.08, t) * smoothstep(1.0, 0.92, t);
	float a = edge * smoothstep(0.02, 0.18, dot(tex, vec3(0.3, 0.59, 0.11)));   // black background and gaps are transparent
	if (a < 0.02) discard;
	vec3 n = vec3(0.0, 1.0, 0.0);
	float l = abs(dot(n, normalize(key_dir)));
	float lit = 0.25 + 0.75 * pow(l, 0.6);
	vec3 col = tex * brighten * (0.1 + key_color.rgb * lit * 1.3);
	ALBEDO = col;
	ALPHA = a * 0.5;   // 50% transparent at the brightest grains (a = 1 for lum >= 0.18), lower in the gaps: the planet and the sky show through
}
"""
var planet_spheres: Array[MeshInstance3D] = []
var belt_materials: Dictionary = {}  # planet index -> ShaderMaterial of its asteroid belt  # one planet_sphere.tscn per planet, at its 3D position
var planet_labels: Array[Label3D] = []
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

	key_light = DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-40, -30, 0)
	add_child(key_light)

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
	_add_orbit_rings(focus, 1)
	_update_camera()
	# Chromatic aberration over the 3D view (art/planet_fx/chromatic_aberration.gd): first, so the glare and grain sit on top of it.
	add_child(load("res://art/planet_fx/chromatic_aberration.gd").new())
	# Screen-space soft edge: blurs a 10 px ring outside each planet disc (art/planet_fx/edge_blur.gd); after the aberration, before the glare and grain.
	var edge_blur: CanvasLayer = load("res://art/planet_fx/edge_blur.gd").new()
	edge_blur.camera = camera
	edge_blur.spheres = planet_spheres
	add_child(edge_blur)
	# Camera lens glare around the current system's sun (art/planet_fx/lens_glare.gd); the quad draws under the UI.
	var glare: CanvasLayer = load("res://art/planet_fx/lens_glare.gd").new()
	glare.camera = camera
	glare.source_pos = func() -> Variant: return sun_positions.get(view_system) if suns.has(view_system) and suns[view_system].visible else null
	glare.source_brightness = func() -> float: return 0.75 + 0.5 * float(suns[view_system].flare) if suns.has(view_system) else 1.0
	add_child(glare)
	# Film grain over the 3D map view (art/planet_fx/film_grain.gd): same layer as the glare, added after it, under the UI.
	add_child(load("res://art/planet_fx/film_grain.gd").new())

## Orbit rings: thin circles on the ground plane through each planet, centred on the sun, plus one dashed
## outer ring. The camera pitch gives the tilt. Colours: theme tokens line_200 / line_100.
## Visual only: no collision, no shadows, never hit by the planet click test.
func _add_orbit_rings(center: Vector3, sys: int = 1) -> void:
	var inner := Ui.col("line_200")
	var outer := Ui.col("line_100")
	if sys != 1:  # the rings take the colour of their own sun
		var sc := Systems.sun_color_of(sys)
		inner = Color(inner.lerp(sc, 0.4), inner.a)
		outer = Color(outer.lerp(sc, 0.4), outer.a)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var im := ImmediateMesh.new()
	var max_r := 0.0
	var segs := 128
	for pi in positions.size():
		if int(planets[pi].get("system", 1)) != sys:
			continue
		var p: Vector3 = positions[pi]
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
	mi.name = "OrbitRings" if sys == 1 else "OrbitRings%d" % sys
	mi.mesh = im
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	orbit_rings[sys] = mi
	orbit_centers[sys] = center
	_add_orbit_dust(mi, center, sys)

## Thin dust rings of each system: DUST_LAYERS merged flat annulus meshes per system (one draw call each, 2 per system),
## with the asteroid ring PNGs mapped by radius in art/planet_fx/orbit_dust.gdshader. Layer 0 uses the system's texture
## (odd systems asteroid1, even asteroid2), the thin layer the other one. Static (no rotation). Children of the ring node.
## No band crosses a planet: the planets' spheres (planet_radius()) cover every radius from the innermost orbit - 1 radius to the
## outermost orbit + 1 radius (the gaps between orbits are under one diameter), so each ring sits outside the outermost orbit:
## its centre is "off" planet radii beyond it, and off - w/2 stays above 1.0 so the inner edge clears the outermost sphere.
## Flat (y = 0), no clearance mask. Opacity: ALPHA = texture alpha x layer alpha (0.5): the brightest grains reach 50%.
const DUST_SPEED := 0.0       # static ring: no rotation (uniform kept at 0)
const DUST_LAYERS := [        # y and off and w in planet radii; tint = lerp sun colour to white; "off"/"w" are the fallback for systems without DUST_SLOTS
	{"name": "OrbitDust",  "y": 0.0, "off": 1.10, "w": 0.35,  "a": 0.5, "tint": 0.10, "alt": false, "win": Vector2(0.2, 0.8), "ang": 2.1},
	{"name": "OrbitDust2", "y": 0.0, "off": 1.80, "w": 0.125, "a": 0.5, "tint": 0.55, "alt": true,  "win": Vector2(0.4, 0.7), "ang": 4.0},
]
## Per-system slots, one per layer: r = orbit radius in world units, y and w in planet radii. Chosen from the real orbit radii
## (system 1: 3, 5, 5; system 2: 2.81, 2.97, 3.82, 3.99; planet_radius() 1.04). Slot 0 sits between the sun and the innermost planet,
## slot 1 in the gap of system 1 (r 4, lifted 0.29 radii so it passes above the spheres) and just outside system 2 (its gaps are under 0.9).
const DUST_SLOTS := {
	1: [{"r": 1.70, "y": 0.0, "w": 0.30}, {"r": 4.00, "y": 0.29, "w": 0.15}],
	2: [{"r": 1.60, "y": 0.0, "w": 0.20}, {"r": 5.15, "y": 0.0, "w": 0.20}],
}
func _add_orbit_dust(parent: Node3D, center: Vector3, sys: int) -> void:
	for L in DUST_LAYERS:
		_add_dust_layer(parent, center, sys, L)

func _add_dust_layer(parent: Node3D, center: Vector3, sys: int, L: Dictionary) -> void:
	var rad := planet_radius()
	var slot: Dictionary = {}
	if DUST_SLOTS.has(sys):
		slot = DUST_SLOTS[sys][DUST_LAYERS.find(L)]
	var width: float = float(slot.get("w", L["w"])) * rad
	var y: float = float(slot.get("y", L["y"])) * rad
	var segs := 192
	var rseg := 1  # radial steps: only the two edges (no clearance mask)
	var r_max := 0.0  # orbit radius of the outermost planet of this system
	for pi in positions.size():
		if int(planets[pi].get("system", 1)) == sys:
			r_max = maxf(r_max, Vector2(positions[pi].x - center.x, positions[pi].z - center.z).length())
	var verts := PackedVector3Array()
	var uvs := PackedVector2Array()
	var idx := PackedInt32Array()
	if r_max >= 0.01:  # one annulus per system, outside every planet sphere
		var r: float = float(slot["r"]) if not slot.is_empty() else r_max + float(L["off"]) * rad
		var r0 := maxf(r - width * 0.5, 0.01)
		var r1 := maxf(r + width * 0.5, r0 + 0.001)
		var base := verts.size()
		for s in segs + 1:
			var u := float(s) / float(segs)
			var a := TAU * u
			var d := Vector3(cos(a), 0.0, sin(a))
			for k in rseg + 1:
				var v := float(k) / float(rseg)
				var pos := center + d * lerpf(r0, r1, v) + Vector3(0.0, y, 0.0)
				verts.append(pos)
				uvs.append(Vector2(u, v))
		for s in segs:
			for k in rseg:
				var i := base + s * (rseg + 1) + k
				var j := i + rseg + 1
				idx.append_array([i, i + 1, j, i + 1, j + 1, j])
	if verts.is_empty():
		return
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_INDEX] = idx
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var mat := ShaderMaterial.new()
	mat.shader = load("res://art/planet_fx/orbit_dust.gdshader")
	mat.set_shader_parameter("dust_color", Systems.sun_color_of(sys).lerp(Color.WHITE, float(L["tint"])))
	mat.set_shader_parameter("alpha", float(L["a"]))
	mat.set_shader_parameter("speed", DUST_SPEED)
	mat.set_shader_parameter("ang_offset", float(L["ang"]))
	mat.set_shader_parameter("ring_width", width)
	# Odd systems asteroid1.png, even asteroid2.png for the main layers; the thin layers take the other file. Dust extents as _add_belt.
	var ring_no := 1 if sys % 2 == 1 else 2
	if bool(L["alt"]):
		ring_no = 3 - ring_no
	var tin := 0.38 if ring_no == 1 else 0.62
	var tout := 0.96 if ring_no == 1 else 0.97
	var win: Vector2 = L["win"]  # the layer samples only this slice of the dust (different radial part per layer)
	mat.set_shader_parameter("ring_tex", load("res://art/textures/planets/asteroid%d.png" % ring_no))
	mat.set_shader_parameter("tex_in", lerpf(tin, tout, win.x))
	mat.set_shader_parameter("tex_out", lerpf(tin, tout, win.y))
	var dm := MeshInstance3D.new()
	dm.name = L["name"]
	dm.mesh = am
	dm.material_override = mat
	dm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(dm)

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
	# Design map-label: Jost 400 13 px, ink, text-shadow 0 1 6 black, in the 941 px frame. fixed_size puts the em at
	# font_size * pixel_size * (P11 / 2) of the frame height (P11 = 1 / tan(22.5 deg) at fov 45); 13 px -> 0.01144 em.
	l.pixel_size = 0.00022
	l.font = Ui.sans_font()
	l.font_size = 52
	l.outline_size = 12
	l.modulate = Ui.col("ink")
	l.outline_modulate = Ui.col("panel_100")
	l.position = pos + Vector3(0, -label_drop(), 0)
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
	clamp_focus()

## T85: a permitted system appears. Appends IN PLACE (trade, events and the engine share this array)
## so indexes of earlier planets never change. Returns the index of the first new planet.
func add_planets(list: Array) -> int:
	var first := planets.size()
	for p in list:
		planets.append(p)
		_make_planet(planets.size() - 1)
	for p in list:  # a new system gets its own sun and orbit rings, centred on its planets
		var sid := int(p.get("system", 1))
		if not suns.has(sid):
			var c := _system_center(sid)
			_add_sun(c, sid)
			_add_orbit_rings(c, sid)
			for i in planets.size():
				_aim_sphere(i)
	_apply_view()  # the new system stays out of sight until the player moves there
	return first

## Moves the map to one system: its planets, labels, routes (and its own sun and orbit rings) show; every other system hides.
func set_view_system(id: int) -> void:
	view_system = id
	focus_system(id)
	_apply_view()

func planet_in_view(i: int) -> bool:
	return i >= 0 and i < planets.size() and int(planets[i].get("system", 1)) == view_system

func _apply_view() -> void:
	for i in planet_spheres.size():
		var on := planet_in_view(i)
		planet_spheres[i].visible = on
		if i < planet_labels.size():
			planet_labels[i].visible = on
	for id in route_lines:
		var ln = route_lines[id]
		ln.visible = planet_in_view(int(ln.pair_a)) and planet_in_view(int(ln.pair_b))
	for id in orbit_rings:  # each system shows only its own sun and orbit rings
		orbit_rings[id].visible = int(id) == view_system
	for id in suns:
		suns[id].visible = int(id) == view_system

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
		if id == view_system:
			clamp_focus()

## Radius (XZ plane) the camera focus may stray from the view system's centre: furthest planet from the centre x pan_margin, with a floor.
func pan_limit() -> float:
	var c := _system_center(view_system)
	var far := 0.0
	for i in planets.size():
		if int(planets[i].get("system", 1)) == view_system and i < positions.size():
			far = maxf(far, Vector2(positions[i].x - c.x, positions[i].z - c.z).length())
	return maxf(far * pan_margin, PAN_LIMIT_MIN)

## Keeps the focus within pan_limit() of the view system's centre, on the ground plane.
func clamp_focus() -> void:
	var c := _system_center(view_system)
	var d := Vector3(focus.x - c.x, 0.0, focus.z - c.z)
	var lim := pan_limit()
	if d.length() > lim:
		d = d.normalized() * lim
		focus = Vector3(c.x + d.x, focus.y, c.z + d.z)

## Plain yellow sphere in the middle of the map (visual only, not clickable).
func _add_sun(pos: Vector3, sys: int = 1) -> void:
	# T132: the animated 3D sun (art/sun/sun_flare.gd). System 1's sun drives the planets' key light; each system's sun
	# has its own colour (Systems.sun_color_of: system 1 orange, system 2 blue).
	var sn: Node3D = load("res://art/sun/sun_flare.gd").new()
	sn.radius = sun_radius
	sn.sun_color = Systems.sun_color_of(sys)
	if sys == 1:
		sn.key_light = key_light
	else:
		sn.drives_light = false
	sn.position = pos
	sn.visible = sys == view_system
	add_child(sn)
	suns[sys] = sn
	sun_positions[sys] = pos
	if sys != 1:
		return
	sun_node = sn
	focus_sun_pos = pos
	hex_ring = load("res://art/sun/hex_ring.gd").new()
	hex_ring.radius = sun_radius
	hex_ring.position = pos
	add_child(hex_ring)  # hidden until show_ring(true)

## Middle of one system's planets on the ground plane (the sun's place).
func _system_center(sys: int) -> Vector3:
	var lo := Vector3.ZERO
	var hi := Vector3.ZERO
	var first := true
	for i in planets.size():
		if int(planets[i].get("system", 1)) != sys or i >= positions.size():
			continue
		var p := positions[i]
		lo = p if first else Vector3(minf(lo.x, p.x), 0.0, minf(lo.z, p.z))
		hi = p if first else Vector3(maxf(hi.x, p.x), 0.0, maxf(hi.z, p.z))
		first = false
	return (lo + hi) * 0.5

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
		line.set_style(str(r.get("status", "running")), int(r.get("ships", 1)), str(r.get("c", "")), int(r.get("net", 0)))
	for id in route_lines.keys():
		if not seen.has(id):
			route_lines[id].queue_free()
			route_lines.erase(id)
	_apply_view()

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
	for pl in parsed["planets"]:
		if typeof(pl) == TYPE_DICTIONARY:
			PlanetTypes.apply(pl)
	return parsed["planets"]

## Name label sits below the visible planet: the outer glow shell is 0.56 of the sphere scale (planet_sphere.tscn), plus a gap.
const PLANET_VISIBLE := 0.56
const LABEL_GAP := 0.15          # gap at the base size; scaled with the planet below
func label_drop() -> float:
	return planet_radius() * (PLANET_VISIBLE + LABEL_GAP / PLANET_RADIUS)

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
		planet_labels[i].position = positions[i] + Vector3(0, -label_drop(), 0)
	for id in suns:
		suns[id].set_radius(sun_radius)
	if hex_ring != null:
		hex_ring.radius = sun_radius
		hex_ring.rebuild()
	for h in [hint, pending_hint]:  # halos resize in place (same position)
		if h != null:
			h.setup(planet_radius())
	for id in orbit_rings:  # the dust rings are sized in planet radii: rebuild it at the new size
		var ring: Node3D = orbit_rings[id]
		for L in DUST_LAYERS:  # every dust layer
			var old := ring.get_node_or_null(String(L["name"]))
			if old != null:
				ring.remove_child(old)
				old.queue_free()
		_add_orbit_dust(ring, orbit_centers[id], int(id))
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
		clamp_focus()
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
		if hit < 0 and event.double_click:
			empty_double_clicked.emit()

## Returns index of nearest planet hit by the camera ray through screen_pos, or -1.
func pick_planet(screen_pos: Vector2) -> int:
	var origin := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	var best := -1
	var best_t := INF
	for i in positions.size():
		if not planet_in_view(i):
			continue
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

## Flat textured ring in the sphere's unit space (scales with the planet), almost flat (1 to 2.5 degrees). One quad, one shader.
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
	# Stable pick from the id hash: asteroid1.png (thick, dark centre) or asteroid2.png (thin grey), through the shared loader.
	# Dust extent as a fraction of the image half-width: asteroid1 0.38 to 0.96, asteroid2 0.62 to 0.97.
	var ring_no := ((_mix(h) >> 7) & 1) + 1
	mat.set_shader_parameter("ring_tex", sph.get_script().cached_tex("res://art/textures/planets/asteroid%d.png" % ring_no))
	mat.set_shader_parameter("tex_in", 0.38 if ring_no == 1 else 0.62)
	mat.set_shader_parameter("tex_out", 0.96 if ring_no == 1 else 0.97)
	mat.render_priority = 1  # after the planet body (-1) and glow shells
	quad.material = mat
	var mi := MeshInstance3D.new()
	mi.mesh = quad
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.rotation_degrees = Vector3(rng.randf_range(1.0, 2.5), 0.0, rng.randf_range(-1.0, 1.0))  # almost flat: tilt amplitude 10x smaller
	sph.add_child(mi)
	belt_materials[i] = mat

## Points the sphere's key light (object space, no rotation, so world space) from planet i towards the sun.
func _aim_sphere(i: int) -> void:
	if i >= planet_spheres.size() or i >= positions.size():
		return
	var d: Vector3 = sun_positions.get(int(planets[i].get("system", 1)), focus_sun_pos) - positions[i]
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
