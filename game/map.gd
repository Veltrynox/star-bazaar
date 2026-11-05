extends Node3D
## T21: placeholder 3D planet map + orbit camera (WASD pan, wheel zoom, right-drag / arrow keys orbit).
## Planets come from data/planets.json. No position data exists yet, so planets
## are laid out on a ring around the origin (in the XZ plane).

signal planet_clicked(index: int)  # -1 when the click hit empty space
signal route_clicked(id: int)      # T07b: click on a route line (no planet under the cursor)

const PlanetTypes := preload("res://game/planet_types.gd")
const Systems := preload("res://game/systems.gd")
const Motion := preload("res://game/ship_motion.gd")  # T202: SPAWN_GAP, BODY_MARGIN
const StationScript := preload("res://game/station.gd")
const PLANETS_PATH := "res://data/planets.json"

# Zoom bounds are not in gdd.md: defaults for owner decision.
# T33: the tunables below are vars (zoom_min ... planet_scale) so the debug menu can edit them live.
const ZOOM_STEP := 1.1
const START_ZOOM := 0.65        # was 1.0: planet orbits are ORBIT_SCALE x wider, so the default view backs off to keep every system in frame
const PAN_SPEED := 10.0          # world units per second at zoom 1
const LAYOUT_RADIUS := 6.0       # ring radius for the simple layout (world units)
const MAP_UNIT_SCALE := 0.02     # world units per map unit in planets.json (old ring: 300 map units = 6 world units)
const PLANET_RADIUS := 0.8       # base radius (before planet_scale)
const ORBIT_SCALE := 2.0         # planets sit this many times further from their system centre than planets.json / systems.json x,y say (the data stays as is)
## Planet size variation: each planet is PLANET_SIZE_MIN..PLANET_SIZE_MAX (0.715 to 1.885) of the base radius. A planet's own "size" key in
## the data wins; otherwise the value comes from a hash of its id, so it is the same every run. Dead worlds use the same range.
const PLANET_SIZE_MIN := 0.715   # 0.55 x 1.3 (owner: planets 1.3x bigger again)
const PLANET_SIZE_MAX := 1.885   # 1.45 x 1.3
const PLANET_PICK_MIN := 0.75    # smallest click radius of a planet (world units), so the smallest planets stay easy to hit
const CLUSTER_PICK_MIN := 0.3     # smallest click radius of an asteroid pack (world units); under a planet's radius
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
var planet_belts := {}   # planet index -> its small decorative dust belt (Voltara)
var dust_rings := {}     # system id -> its decorative asteroid dust ring (art/planet_fx/asteroid_dust_ring.gd)
var hex_ring: Node3D  # T110: hexagon ring around the sun, shown during EV20
var key_light: DirectionalLight3D
var planet_scale := PLANET_SIZE  # multiplies PLANET_RADIUS (visual size, click radius, route start, names, halos)
var keys_enabled := true         # T33: debug menu turns this off while typing in a field

var planets: Array = []
var view_system := 1  # each solar system is its own space: only this system's planets, routes and sun are shown
var planet_spheres: Array[MeshInstance3D] = []  # one planet_sphere.tscn per planet, at its 3D position
var planet_labels: Array[Label3D] = []
var planet_label_2d: Array[Label] = []   # T167: drawn on a canvas layer above the edge blur, placed from planet_labels each frame
var _label_layer: CanvasLayer
var focus_sun_pos := Vector3.ZERO  # world position of the sun sphere (the screen-space light source for the FX)
var positions: Array[Vector3] = []
var camera: Camera3D
var focus := Vector3.ZERO
var zoom: float = START_ZOOM
var yaw_deg: float = START_YAW_DEG
var pitch_deg: float = START_PITCH_DEG
var pending_hint: MeshInstance3D  # T57 halo on the planet with a pending connection
var _hint_i := -1
var _pending_i := -1
var hint: MeshInstance3D  # T28 pulsing halo, null until first requested
var route_lines: Dictionary = {}  # T07b: route id -> route_line.gd node
var _route_list: Array = []       # last list given to set_routes (rebuilt after tunable changes)

signal station_clicked(system_id: int)
## T180: flight orders and establish orders; see the interface at the top of game/pathfinder_view.gd. Never emitted while flight is null or off.
signal fly_requested(target: Dictionary)   # {"kind": "planet"|"storage"|"cluster"|"point", "pos": Vector3, "index": int}
signal establish_requested(planet_id: String)
## T200: ship controls. Click the ship to select it; with it selected LEFT click flies at once, RIGHT click on a planet asks main for the
## action menu (only the allowed actions), Esc / right-click on open space deselects.
signal action_menu_requested(planet_id: String, screen_pos: Vector2)
signal fly_establish_requested(planet_id: String)
const SHIP_PICK_PX := 30.0
const RIGHT_CLICK_DRAG_PX := 6.0
var ship_selected := false
var _rc_down := false             # right button pressed on the map and not dragged yet (a drag orbits the camera)
var _rc_drag := 0.0
const PathfinderView := preload("res://game/pathfinder_view.gd")
const DeadWorlds := preload("res://game/dead_worlds.gd")
const StoryText := preload("res://game/story_text.gd")
const UNKNOWN_SHADE_ALPHA := 0.62
var flight = null                 # T180: accessor set by main.gd (T179); null = discovery off, nothing below changes
var pathfinder = null             # T180: the 3D scout (game/pathfinder_view.gd), created on first use
var _shades := {}                 # planet index -> dim overlay sphere of a closed planet
var _known_cache := {}            # planet index -> last "discovered" state, to rewrite names only on a change
signal cluster_clicked(index: int)  # T159: click on an asteroid pack (index in the cluster data)
var _cluster_list: Array = []  # T159: last list given to set_clusters, for picking
const STATION_OFFSET := Vector3(2.4, 0.0, -2.4)  # from the system's sun
const STATION_PICK_PX := 40.0
const STATION_MARKER_LIFT := 0.45
var stations := {}  # system id -> game/station.gd node
var asteroid_packs: Node3D  # T157: game/galaxy/asteroid_packs.gd, one MultiMesh per cluster

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
	asteroid_packs = load("res://game/galaxy/asteroid_packs.gd").new()
	asteroid_packs.map_unit_scale = MAP_UNIT_SCALE
	asteroid_packs.sun_positions = sun_positions
	add_child(asteroid_packs)
	_frame_planets()
	_add_sun(focus)
	_add_orbit_rings(focus, 1)
	_add_planet_belt("Voltara")
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
	# T167: the planet names go last on the same layer, so they draw above the blur, glare and grain (same layer: tree order).
	move_child(_label_layer_node(), -1)

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
	var radii: Array[float] = []
	var segs := 128
	for pi in positions.size():
		if int(planets[pi].get("system", 1)) != sys:
			continue
		var p: Vector3 = positions[pi]
		var r := Vector2(p.x - center.x, p.z - center.z).length()
		if r < 0.01:
			continue
		max_r = maxf(max_r, r)
		radii.append(r)
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
	_add_dust_ring(center, sys, radii)

## Decorative dust: up to 7 broken bands (art/planet_fx/asteroid_dust_ring.gd). The gaps between orbit lines (sun edge,
## planet orbits, dashed outer ring) are shared out between the rings, one slot per ring with a 10% margin to the lines,
## so no band touches an orbit line. Visual only: no collision, never picked.
const DUST_RING_COUNT := 7
## Owner 2026-11-03: Voltara's belt was too big, scaled to half (bands were 1.5-1.8 and 2.0-2.4 planet radii).
const BELT_SCALE := 0.5
## A light dust belt round one planet (Voltara: no event names a belt there; closest is EV28 'Voltara's foundry wants rock').
## Two thin broken bands at 1.5 to 1.8 and 2.0 to 2.4 planet radii, 1500 grains, centred on the planet, so it reads as
## a belt round Voltara and stays well clear of the other planets. Visual only: no collision, planet picking is maths.
func _add_planet_belt(planet_name: String) -> void:
	for i in planets.size():
		if str(planets[i].get("name", "")) != planet_name:
			continue
		var r := planet_radius(i)
		var belt: MultiMeshInstance3D = load("res://art/planet_fx/asteroid_dust_ring.gd").new()
		var bands: Array[Vector2] = [Vector2(r * 1.5, r * 1.8) * BELT_SCALE, Vector2(r * 2.0, r * 2.4) * BELT_SCALE]
		belt.slots = bands
		belt.count = 1500
		belt.seed_salt = 100 + i
		belt.name = "PlanetBelt" + planet_name
		belt.position = positions[i]
		belt.visible = planet_in_view(i)
		add_child(belt)
		planet_belts[i] = belt
		return
func _add_dust_ring(center: Vector3, sys: int, radii: Array[float]) -> void:
	if radii.is_empty():
		return
	var edges: Array[float] = [sun_radius * 1.5]
	var sorted := radii.duplicate()
	sorted.sort()
	edges.append_array(sorted)
	edges.append(sorted[-1] * 1.2)  # the dashed outer ring
	var per_gap: Array[int] = []
	per_gap.resize(edges.size() - 1)
	per_gap.fill(0)
	for n in DUST_RING_COUNT:  # next ring goes to the gap with the most room per ring
		var best := 0
		for i in per_gap.size():
			if (edges[i + 1] - edges[i]) / (per_gap[i] + 1) > (edges[best + 1] - edges[best]) / (per_gap[best] + 1):
				best = i
		per_gap[best] += 1
	var slots: Array[Vector2] = []
	for i in per_gap.size():
		var g: float = edges[i + 1] - edges[i]
		var lo: float = edges[i] + g * 0.1
		var step: float = g * 0.8 / maxi(per_gap[i], 1)
		for k in per_gap[i]:
			slots.append(Vector2(lo + step * k + step * 0.05, lo + step * (k + 1) - step * 0.05))
	var ring: MultiMeshInstance3D = load("res://art/planet_fx/asteroid_dust_ring.gd").new()
	ring.slots = slots
	ring.seed_salt = sys
	ring.tint = Color(0.75, 0.68, 0.6).lerp(Systems.sun_color_of(sys), 0.25)
	ring.name = "AsteroidDustRing" if sys == 1 else "AsteroidDustRing%d" % sys
	ring.position = center
	ring.visible = sys == view_system
	add_child(ring)
	dust_rings[sys] = ring

## T85: one planet node (mesh + label) for planets[i]; position from x,y or the old ring layout.
func _make_planet(i: int) -> void:
	var n := planets.size()
	var pos: Vector3
	if planets[i].has("x") and planets[i].has("y"):
		var raw := Vector3(float(planets[i]["x"]), 0.0, float(planets[i]["y"])) * MAP_UNIT_SCALE
		var mid := _raw_center(int(planets[i].get("system", 1)))  # orbits grow about the system centre, which stays put
		pos = mid + (raw - mid) * ORBIT_SCALE
	else:
		var a := TAU * float(i) / float(max(n, 1)) - PI / 2.0
		pos = Vector3(cos(a), 0.0, sin(a)) * LAYOUT_RADIUS
	positions.append(pos)
	var sph: MeshInstance3D = PLANET_SPHERE.instantiate()
	sph.planet_type = str(planets[i].get("type", "")).to_lower()
	sph.rarity = clampf(float(planets[i].get("rarity", 0.0)), 0.0, 1.0)
	sph.planet_id = str(planets[i].get("id", i))  # the sphere picks its own variant and rim light from this
	sph.position = pos
	sph.scale = Vector3.ONE * planet_radius(i)
	add_child(sph)
	planet_spheres.append(sph)
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
	l.position = pos + Vector3(0, -label_drop(i), 0)
	add_child(l)
	planet_labels.append(l)
	var t := Label.new()
	t.text = l.text
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.add_theme_font_override("font", l.font)
	t.add_theme_color_override("font_color", l.modulate)
	t.add_theme_color_override("font_outline_color", l.outline_modulate)
	# T167: the 3D label only carries the position and visibility; it is drawn fully transparent, the 2D twin shows the name above the blur.
	l.modulate.a = 0.0
	l.outline_modulate.a = 0.0
	_label_layer_node().add_child(t)
	planet_label_2d.append(t)

func _label_layer_node() -> CanvasLayer:
	if _label_layer == null:
		_label_layer = CanvasLayer.new()
		_label_layer.layer = -1   # same layer as the blur, glare and grain; added last, so on top of them, under the UI
		add_child(_label_layer)
	return _label_layer

## T167: place the 2D name labels over their hidden 3D twins (size: 13 px in the 941 px frame, scaled to the viewport).
func _place_labels() -> void:
	if camera == null or not camera.is_inside_tree():
		return
	var h := get_viewport().get_visible_rect().size.y
	var fs := maxi(8, roundi(13.0 * h / 941.0))
	var ol := maxi(2, roundi(3.0 * h / 941.0))
	for i in planet_label_2d.size():
		var t := planet_label_2d[i]
		var src := planet_labels[i]
		var wp := src.global_position
		var on := src.visible and not camera.is_position_behind(wp)
		t.visible = on
		if not on:
			continue
		t.add_theme_font_size_override("font_size", fs)
		t.add_theme_constant_override("outline_size", ol)
		var sz := t.get_minimum_size()
		t.position = (camera.unproject_position(wp) - sz * 0.5).round()
	_place_route_tags()

## T163: route tags, same approach as the planet names.
func _place_route_tags() -> void:
	var h := get_viewport().get_visible_rect().size.y
	var fs := maxi(8, roundi(11.0 * h / 941.0))
	var ol := maxi(2, roundi(3.0 * h / 941.0))
	for id in route_lines:
		var ln = route_lines[id]
		var t: Label = ln.tag2d
		if t == null:
			continue
		var wp: Vector3 = ln.tag.global_position
		var on: bool = ln.visible and not camera.is_position_behind(wp)
		t.visible = on
		if not on:
			continue
		t.add_theme_font_size_override("font_size", fs)
		t.add_theme_constant_override("outline_size", ol)
		t.position = (camera.unproject_position(wp) - t.get_minimum_size() * 0.5).round()

## Middle of one system's planets from the data x,y (before ORBIT_SCALE), on the ground plane.
func _raw_center(sys: int) -> Vector3:
	var lo := Vector3.ZERO
	var hi := Vector3.ZERO
	var first := true
	for p in planets:
		if int(p.get("system", 1)) != sys or not p.has("x") or not p.has("y"):
			continue
		var v := Vector3(float(p["x"]), 0.0, float(p["y"])) * MAP_UNIT_SCALE
		lo = v if first else Vector3(minf(lo.x, v.x), 0.0, minf(lo.z, v.z))
		hi = v if first else Vector3(maxf(hi.x, v.x), 0.0, maxf(hi.z, v.z))
		first = false
	return (lo + hi) * 0.5

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
	for k in list.size():  # all appended first: the system centre for ORBIT_SCALE needs every planet of the system
		_make_planet(first + k)
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

## T157: show the asteroid packs of the clusters given (main.clusters_in_system). Visual only.
func set_clusters(list: Array) -> void:
	_cluster_list = list
	asteroid_packs.sync(list)

## T159: index of the cluster of the viewed system whose pack is under the cursor (ray against an ellipsoid: radius across the orbit radius, radius x stretch along the tangent), or -1.
func pick_cluster(screen_pos: Vector2) -> int:
	var origin := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	var best := -1
	var best_t := INF
	for c in _cluster_list:
		if int(c["system"]) != view_system or int(c.get("visible", 1)) <= 0:
			continue
		var centre := Vector3(float(c["x"]), 0.0, float(c["y"])) * MAP_UNIT_SCALE
		var r := float(c["radius"]) * MAP_UNIT_SCALE
		# Ellipsoid test: the pack is stretched along its orbit tangent, so squash the ray back along that axis and test a sphere.
		var tn: Vector3 = asteroid_packs.tangent_of(c)
		var k := maxf(1.0, float(c.get("stretch", 1.0)))
		var o2 := _unstretch(origin - centre, tn, k)
		var d2 := _unstretch(dir, tn, k)
		var a2 := d2.dot(d2)
		var b := o2.dot(d2) / a2
		var disc := b * b - (o2.dot(o2) - r * r) / a2
		if disc < 0.0:
			continue
		var t := -b - sqrt(disc)
		if t > 0.0 and t < best_t:
			best_t = t
			best = int(c["index"])
	return best

## World position of the asteroid pack with this data index (same maths as pick_cluster), or null.
func _cluster_world_pos(index: int) -> Variant:
	for c in _cluster_list:
		if int(c["index"]) == index:
			return Vector3(float(c["x"]), 0.0, float(c["y"])) * MAP_UNIT_SCALE
	return null

## Divides the part of v along unit axis tn by k (ellipsoid to sphere space for pick_cluster).
func _unstretch(v: Vector3, tn: Vector3, k: float) -> Vector3:
	var along := v.dot(tn)
	return v - tn * along + tn * (along / k)

func _apply_view() -> void:
	asteroid_packs.set_view_system(view_system)
	for i in planet_spheres.size():
		var on := planet_in_view(i)
		planet_spheres[i].visible = on
		if i < planet_labels.size():
			planet_labels[i].visible = on
	for id in route_lines:
		var ln = route_lines[id]
		ln.visible = _node_system(int(ln.pair_a)) == view_system and (planet_in_view(int(ln.pair_b)) if int(ln.pair_b) >= 0 else -int(ln.pair_b) == view_system)
	for id in stations:
		stations[id].visible = int(id) == view_system
	for id in orbit_rings:  # each system shows only its own sun and orbit rings
		orbit_rings[id].visible = int(id) == view_system
	for i in planet_belts:
		planet_belts[i].visible = planet_in_view(int(i))
	for id in dust_rings:
		dust_rings[id].visible = int(id) == view_system
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
	hex_ring.color = Systems.sun_color_of(sys).lerp(Color.WHITE, 0.25)  # T110: ring takes the sun's colour, a little lighter
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
			_hint_i = -1
		return
	if hint == null:
		hint = load("res://game/planet_hint.gd").new()
		add_child(hint)
	if _hint_i != index:
		_hint_i = index
		hint.setup(planet_radius(index))
	hint.position = positions[index]

## Event icon click: halo on the planet the event names; -1 removes it.
var event_hint: MeshInstance3D
var _event_hint_i := -1
func set_event_hint(index: int) -> void:
	if index < 0 or index >= positions.size():
		if event_hint != null:
			event_hint.queue_free()
			event_hint = null
			_event_hint_i = -1
		return
	if event_hint == null:
		event_hint = load("res://game/planet_hint.gd").new()
		add_child(event_hint)
	if _event_hint_i != index:
		_event_hint_i = index
		event_hint.setup(planet_radius(index))
	event_hint.position = positions[index]

## T57: halo on the planet holding a pending Buy/Sell order; -1 removes it.
func set_pending(index: int) -> void:
	if index < 0 or index >= positions.size():
		if pending_hint != null:
			pending_hint.queue_free()
			pending_hint = null
			_pending_i = -1
		return
	if pending_hint == null:
		pending_hint = load("res://game/planet_hint.gd").new()
		add_child(pending_hint)
	if _pending_i != index:
		_pending_i = index
		pending_hint.setup(planet_radius(index))
	pending_hint.position = positions[index]

## Cluster entry of _cluster_list for a route node id (-1000 - index), {} when unknown.
func _cluster_by_node(node: int) -> Dictionary:
	for c in _cluster_list:
		if int(c["index"]) == -node - 1000:
			return c
	return {}

## System of a route end: a planet index or a cluster node id; -1 when unknown.
func _node_system(n: int) -> int:
	if n <= -1000:
		var c := _cluster_by_node(n)
		return int(c["system"]) if not c.is_empty() else -1
	return int(planets[n].get("system", 1)) if n >= 0 and n < planets.size() else -1

## Suns as route obstacles: [[world position, radius], ...] (route_offset.gd). One per open system.
func sun_list() -> Array:
	var out := []
	for sid in sun_positions:
		out.append([sun_positions[sid], sun_radius])
	return out

## T07b: show one glowing line per route. routes: Array of {id, a, b, ships, status}.
## Lines are created once per route and only restyled afterwards; removed when the route is gone.
func set_routes(routes: Array) -> void:
	_route_list = routes
	var seen := {}
	for r in routes:
		var id := int(r["id"])
		var a := int(r["a"])
		var b := int(r["b"])
		var end_pos := Vector3.ZERO
		var start_pos := Vector3.ZERO
		var start_r := 0.0
		if a <= -1000:  # a route from an asteroid cluster: the line starts at its pack
			var cc := _cluster_by_node(a)
			if cc.is_empty():
				continue
			start_pos = Vector3(float(cc["x"]), 0.0, float(cc["y"])) * MAP_UNIT_SCALE
			start_r = float(cc["radius"]) * MAP_UNIT_SCALE
		elif a < 0 or a >= positions.size():
			continue
		else:
			start_pos = positions[a]
			start_r = planet_radius(a)
		if b < 0:  # a send to a Space Storage station (b = -system id): a line from the source to its own system's station
			var st = stations.get(-b)
			if st == null or _node_system(a) != -b:
				continue
			end_pos = st.position
		elif b >= positions.size():
			continue
		else:
			end_pos = positions[b]
		seen[id] = true
		var half := false  # T68: the opposite direction exists on the same pair: each arrow covers half the line
		for o in routes:
			if int(o["a"]) == b and int(o["b"]) == a:
				half = true
		var line = route_lines.get(id)
		var lane := _lane_of(routes, id, a, b)
		if line != null and (line.pair_a != a or line.pair_b != b or line.half != half or not is_equal_approx(line.lane_slot, lane)):
			line.queue_free()
			route_lines.erase(id)
			line = null
		if line == null:
			line = load("res://game/route_line.gd").new()
			add_child(line)
			line.setup(id, a, b, start_pos, end_pos, start_r if b < 0 else maxf(start_r, planet_radius(b)), half, sun_list(), lane)
			route_lines[id] = line
			_label_layer_node().add_child(line.tag2d)
		line.set_style(str(r.get("status", "running")), int(r.get("ships", 1)), str(r.get("c", "")), int(r.get("net", 0)), str(r.get("reason", "")), bool(r.get("net_ok", false)), int(r.get("cost", 0)))
	for id in route_lines.keys():
		if not seen.has(id):
			route_lines[id].queue_free()
			route_lines.erase(id)
	_apply_view()

## T163: lane slot of a route among all routes on the same pair (either direction), in steps, centred on 0 and signed
## to the route's own left of travel. A lone route gets 0 (drawn as before).
func _lane_of(routes: Array, id: int, a: int, b: int) -> float:
	var ids: Array = []
	for o in routes:
		var oa := int(o["a"])
		var ob := int(o["b"])
		if (oa == a and ob == b) or (oa == b and ob == a):
			ids.append(int(o["id"]))
	if ids.size() < 2:
		return 0.0
	ids.sort()
	var k := ids.find(id)
	var slot := float(k) - float(ids.size() - 1) * 0.5
	return slot if a <= b else -slot

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
			Goods.merge_prices(pl)  # prices of the new goods (data/goods.json)
	return parsed["planets"]

## Name label sits below the visible planet: the outer glow shell is 0.56 of the sphere scale (planet_sphere.tscn), plus a gap.
const PLANET_VISIBLE := 0.56
const LABEL_GAP := 0.15          # gap at the base size; scaled with the planet below
func label_drop(i: int = -1) -> float:
	return planet_radius(i) * (PLANET_VISIBLE + LABEL_GAP / PLANET_RADIUS)

## Planet size factor of planet i (PLANET_SIZE_MIN..PLANET_SIZE_MAX); 1.0 for i < 0 (the plain base size).
func size_factor(i: int) -> float:
	if i < 0 or i >= planets.size():
		return 1.0
	var p: Dictionary = planets[i]
	var u: float
	if p.has("size"):
		return clampf(float(p["size"]), PLANET_SIZE_MIN, PLANET_SIZE_MAX)
	u = float(absi(str(p.get("id", i)).hash()) % 1000) / 999.0
	return lerpf(PLANET_SIZE_MIN, PLANET_SIZE_MAX, u)

## Radius of planet i (world units); without an index, the base radius.
func planet_radius(i: int = -1) -> float:
	return PLANET_RADIUS * planet_scale * size_factor(i)

## T202: radius of an asteroid field as drawn: the furthest rock of its pack from the centre in the plane (game/galaxy/asteroid_packs.gd
## keeps the rock positions). Before the pack exists: its bound, radius x map unit x pack_scale x stretch.
func cluster_draw_radius(c: Dictionary) -> float:
	var id := str(c.get("id", ""))
	if asteroid_packs != null and asteroid_packs.packs.has(id):
		var r := 0.0
		for q in asteroid_packs.packs[id]["points"]:
			r = maxf(r, Vector2(q.x, q.z).length())
		return r
	var ps: float = float(asteroid_packs.pack_scale) if asteroid_packs != null else 0.25
	return float(c["radius"]) * MAP_UNIT_SCALE * ps * maxf(1.0, float(c.get("stretch", 1.0)))

## T202: every body a ship must stay outside in one system: [{kind, id, pos: Vector2 (x, z), radius}]. Planets and dead worlds
## (planets[]), the sun, the space station (once built) and the asteroid fields. Each system is its own space.
func bodies(sys: int) -> Array:
	var out: Array = []
	for i in planets.size():
		if int(planets[i].get("system", 1)) == sys and i < positions.size():
			out.append({"kind": "planet", "id": str(planets[i].get("id", i)), "pos": Vector2(positions[i].x, positions[i].z), "radius": planet_radius(i)})
	if sun_positions.has(sys):
		var sp: Vector3 = sun_positions[sys]
		out.append({"kind": "sun", "id": "sun_%d" % sys, "pos": Vector2(sp.x, sp.z), "radius": sun_radius})
	if stations.has(sys):
		var tp: Vector3 = stations[sys].position
		out.append({"kind": "station", "id": "station_%d" % sys, "pos": Vector2(tp.x, tp.z), "radius": StationScript.MAP_RADIUS})
	for c in _cluster_list:
		if int(c.get("system", 1)) == sys:
			var cp := Vector2(float(c["x"]), float(c["y"])) * MAP_UNIT_SCALE
			out.append({"kind": "cluster", "id": str(c.get("id", c.get("index", ""))), "pos": cp, "radius": cluster_draw_radius(c)})
	return out

## T202: the asteroid field (cluster index, as in main.clusters) as a body {pos, radius}, or {} when it is not drawn.
func cluster_body(index: int) -> Dictionary:
	for c in _cluster_list:
		if int(c["index"]) == index:
			return {"pos": Vector2(float(c["x"]), float(c["y"])) * MAP_UNIT_SCALE, "radius": cluster_draw_radius(c)}
	return {}

## T202: where a ship parks at a body: Motion.SPAWN_GAP outside its edge, on the side of `from` (straight toward it; +Z when
## `from` is the centre). If that spot is inside another body of the system the angle turns until the spot is clear.
func dock_point(center: Vector2, radius: float, from: Vector2, sys: int) -> Vector2:
	var d := from - center
	var a := atan2(d.y, d.x) if d.length() > 0.0001 else PI * 0.5
	var all := bodies(sys)
	var first := Vector2.ZERO
	for k in 24:
		var ang: float = a + (0.0 if k == 0 else (1.0 if k % 2 == 1 else -1.0) * ceil(k / 2.0) * TAU / 24.0)
		var p := center + Vector2(cos(ang), sin(ang)) * (radius + Motion.SPAWN_GAP)
		if k == 0:
			first = p
		var clear := true
		for b in all:
			var bp: Vector2 = b["pos"]
			if bp.distance_to(center) < 0.0001:
				continue  # the parent itself
			if p.distance_to(bp) <= float(b["radius"]) + Motion.BODY_MARGIN:
				clear = false
				break
		if clear:
			return p
	return first

## T33: call after changing a tunable var. Re-applies sizes and re-clamps the camera.
func apply_tunables() -> void:
	zoom_max = maxf(zoom_max, zoom_min)
	yaw_max_deg = maxf(yaw_max_deg, yaw_min_deg)
	pitch_max_deg = maxf(pitch_max_deg, pitch_min_deg)
	zoom = clampf(zoom, zoom_min, zoom_max)
	yaw_deg = clampf(yaw_deg, yaw_min_deg, yaw_max_deg)
	pitch_deg = clampf(pitch_deg, pitch_min_deg, pitch_max_deg)
	for k in planet_spheres.size():
		planet_spheres[k].scale = Vector3.ONE * planet_radius(k)
	for i in planet_labels.size():
		planet_labels[i].position = positions[i] + Vector3(0, -label_drop(i), 0)
	for id in suns:
		suns[id].set_radius(sun_radius)
	if hex_ring != null:
		hex_ring.radius = sun_radius
		hex_ring.rebuild()
	if hint != null:  # halos resize in place (same position)
		hint.setup(planet_radius(_hint_i))
	if pending_hint != null:
		pending_hint.setup(planet_radius(_pending_i))
	for id in route_lines.keys():  # route lines start at the planet surface: rebuild at the new size
		route_lines[id].queue_free()
	route_lines.clear()
	set_routes(_route_list)
	_update_camera()

func _process(delta: float) -> void:
	_refresh_known()
	_place_labels()
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

## T180: closed planets are dim, unnamed spheres ("Unknown world" / "Unknown dark world"); the Pathfinder follows the accessor.
## With flight null or off, every planet is known and this only leaves the original names and spheres alone.
func _refresh_known() -> void:
	var on := PathfinderView.active(flight)
	if on and pathfinder == null:
		pathfinder = PathfinderView.new()
		add_child(pathfinder)
	if pathfinder != null:
		if not on:
			ship_selected = false
		pathfinder.update_from(flight if on else null, view_system, ship_selected)
	if not on and _shades.is_empty():
		return
	for i in planets.size():
		var pid := str(planets[i].get("id", i))
		var known := PathfinderView.discovered(flight if on else null, pid)
		if _known_cache.get(i, true) == known and (known or _shades.has(i)) and (not known or not _shades.has(i)):
			continue
		_known_cache[i] = known
		var dead: bool = DeadWorlds.is_dead(planets[i])
		var nm := str(planets[i].get("name", pid))
		if not known:
			nm = StoryText.get_or("LBL_UNKNOWN_DARK_WORLD" if dead else "LBL_UNKNOWN_WORLD", "Unknown dark world" if dead else "Unknown world")
		if i < planet_label_2d.size():
			planet_label_2d[i].text = nm
		if not known and not _shades.has(i):
			var sh := MeshInstance3D.new()
			var sm := SphereMesh.new()
			sm.radius = 1.02
			sm.height = 2.04
			sh.mesh = sm
			var mat := StandardMaterial3D.new()
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color = Color(0.02, 0.03, 0.05, UNKNOWN_SHADE_ALPHA)
			sh.material_override = mat
			planet_spheres[i].add_child(sh)
			_shades[i] = sh
		elif known and _shades.has(i):
			_shades[i].queue_free()
			_shades.erase(i)

## World point on the ground plane under the cursor, or null.
func _ground_point(screen_pos: Vector2) -> Variant:
	var o := camera.project_ray_origin(screen_pos)
	var d := camera.project_ray_normal(screen_pos)
	if absf(d.y) < 0.0001:
		return null
	var t := -o.y / d.y
	return o + d * t if t > 0.0 else null

func _axis(neg: Key, pos: Key) -> float:
	return float(Input.is_physical_key_pressed(pos)) - float(Input.is_physical_key_pressed(neg))

## T200: true when the cursor is over the Pathfinder (it is drawn only in the viewed system).
func pick_ship(screen_pos: Vector2) -> bool:
	if not PathfinderView.active(flight) or pathfinder == null or not pathfinder.visible or camera == null:
		return false
	var w: Vector3 = PathfinderView._call(flight, "ship_position", [], Vector3.ZERO) + Vector3(0, PathfinderView.LIFT, 0)
	if camera.is_position_behind(w):
		return false
	return camera.unproject_position(w).distance_to(screen_pos) <= SHIP_PICK_PX

func select_ship(on: bool) -> void:
	ship_selected = on and PathfinderView.active(flight)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _rc_down and (event.button_mask & MOUSE_BUTTON_MASK_RIGHT) != 0:
		_rc_drag += event.relative.length()
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_by(ZOOM_STEP)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_by(1.0 / ZOOM_STEP)
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_RIGHT) != 0:
		_orbit_by(event.relative.x * ORBIT_MOUSE_SENS, event.relative.y * ORBIT_MOUSE_SENS)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			_rc_down = true
			_rc_drag = 0.0
		elif _rc_down:
			_rc_down = false
			if _rc_drag < RIGHT_CLICK_DRAG_PX:
				_right_click(event.position)
		return
	# T04: left click picks a planet with a camera ray / sphere test.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var on := PathfinderView.active(flight)
		if on and pick_ship(event.position):  # T200: click the ship to select it (a planet under it is still picked for the panel)
			ship_selected = true
			planet_clicked.emit(pick_planet(event.position))
			return
		var fly: bool = on and ship_selected  # T200: only a selected ship takes orders; a left click sends it at once
		var hit := pick_planet(event.position)
		if hit < 0:
			var sid := pick_station(event.position)
			if sid >= 0:
				station_clicked.emit(sid)
				if fly:
					fly_requested.emit({"kind": "storage", "pos": stations[sid].position, "index": sid})
				return
			var cidx := pick_cluster(event.position)
			if cidx >= 0:
				cluster_clicked.emit(cidx)
				if fly:
					var cp: Variant = _cluster_world_pos(cidx)
					if cp != null:
						fly_requested.emit({"kind": "cluster", "pos": cp, "index": cidx})
				return
			var rid := pick_route(event.position)
			if rid >= 0:
				route_clicked.emit(rid)
				return
			if fly:  # open space: fly to that point
				var gp: Variant = _ground_point(event.position)
				if gp != null:
					fly_requested.emit({"kind": "point", "pos": gp, "index": -1})
					return
		elif fly:
			fly_requested.emit({"kind": "planet", "pos": positions[hit], "index": hit})
		planet_clicked.emit(hit)

## T200: right click (no drag). With the ship selected: a planet with allowed actions opens the menu; open space deselects.
func _right_click(pos: Vector2) -> void:
	if not (PathfinderView.active(flight) and ship_selected):
		return
	var hit := pick_planet(pos)
	if hit >= 0:
		var pid := str(planets[hit].get("id", hit))
		if not (PathfinderView._call(flight, "actions_for", [pid], []) as Array).is_empty():
			action_menu_requested.emit(pid, pos)
		return
	if pick_station(pos) < 0 and pick_cluster(pos) < 0 and not pick_ship(pos):
		ship_selected = false

## Space station of one system: built once, placed beside the sun. Returns false if it already exists.
func add_station(sid: int, animate: bool = true) -> bool:
	if stations.has(sid):
		return false
	var st: Node3D = load("res://game/station.gd").new()
	st.system_id = sid
	st.position = sun_positions.get(sid, Vector3.ZERO) + STATION_OFFSET
	st.visible = sid == view_system
	add_child(st)
	stations[sid] = st
	st.build_in(animate)
	if not _route_list.is_empty():
		set_routes(_route_list)  # a send to this station made before it was built (loaded game) gets its line now
	return true

func clear_stations() -> void:
	for sid in stations:
		stations[sid].queue_free()
	stations.clear()

## Screen position of the marker above a station, or null when it should be hidden.
func station_marker_pos(sid: int) -> Variant:
	if not stations.has(sid) or sid != view_system or camera == null:
		return null
	var w: Vector3 = stations[sid].position + Vector3(0, STATION_MARKER_LIFT, 0)
	if camera.is_position_behind(w):
		return null
	var p := camera.unproject_position(w)
	return p if get_viewport().get_visible_rect().grow(-4.0).has_point(p) else null

func pick_station(screen_pos: Vector2) -> int:
	for sid in stations:
		if sid != view_system or camera.is_position_behind(stations[sid].position):
			continue
		if camera.unproject_position(stations[sid].position).distance_to(screen_pos) <= STATION_PICK_PX:
			return int(sid)
	return -1

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
		var pr := maxf(planet_radius(i), PLANET_PICK_MIN)
		var c := oc.dot(oc) - pr * pr
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

## Aims planet i's sphere at its sun: pole into the shadow, key light towards the sun (only when the direction changes).
var sphere_sun := {}  # planet index -> last world sun direction
func _aim_sphere(i: int) -> void:
	if i >= planet_spheres.size() or i >= positions.size():
		return
	var d: Vector3 = sun_positions.get(int(planets[i].get("system", 1)), focus_sun_pos) - positions[i]
	if d.length() < 0.001:
		return
	d = d.normalized()
	if not d.is_equal_approx(sphere_sun.get(i, Vector3.ZERO)):
		sphere_sun[i] = d
		planet_spheres[i].aim_sun(d)  # turns the pole into the shadow and sets key_dir in object space

func _update_fx() -> void:
	for i in planet_spheres.size():
		_aim_sphere(i)
