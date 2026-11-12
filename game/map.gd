extends Node3D
## T21: placeholder 3D planet map + orbit camera (WASD pan, wheel zoom, right-drag / arrow keys orbit).
## Planets come from data/planets.json. No position data exists yet, so planets
## are laid out on a ring around the origin (in the XZ plane).

signal planet_clicked(index: int)  # -1 when the click hit empty space
signal route_clicked(id: int)      # T07b: click on a route line (no planet under the cursor)
signal route_right_clicked(id: int, screen_pos: Vector2)  # right click on a route line (no planet, station or cluster under the cursor): main offers Remove

const PlanetTypes := preload("res://game/planet_types.gd")
const Systems := preload("res://game/systems.gd")
const Ships := preload("res://game/ships.gd")  # T252: ship_scale
const Motion := preload("res://game/ship_motion.gd")  # T202: SPAWN_GAP, BODY_MARGIN
const StationScript := preload("res://game/station.gd")
const RouteLineScript := preload("res://game/route_line.gd")  # T303: GAP and BOW of the lane arc
const RouteOffset := preload("res://game/route_offset.gd")
const PLANETS_PATH := "res://data/planets.json"

# Zoom bounds are not in gdd.md: defaults for owner decision.
# T33: the tunables below are vars (zoom_min ... planet_scale) so the debug menu can edit them live.
const ZOOM_STEP := 1.1
const MAP_SCALE_UP := 1.4       # T231: whole solar system map x1.4 (orbits, clusters, exits, routes); data-unit distances and flight times unchanged
const PLANET_SCALE_UP := 1.3     # T231: planets x1.3 bigger again (visual, pick radius, labels, icons)
const START_ZOOM := 0.65 / MAP_SCALE_UP        # was 1.0: planet orbits are ORBIT_SCALE x wider, so the default view backs off to keep every system in frame
const PAN_SPEED := 10.0 * MAP_SCALE_UP          # world units per second at zoom 1
const LAYOUT_RADIUS := 6.0 * MAP_SCALE_UP       # ring radius for the simple layout (world units)
const MAP_UNIT_SCALE := 0.02 * MAP_SCALE_UP     # world units per map unit in planets.json (old ring: 300 map units = 6 world units)
const PLANET_RADIUS := 0.8       # base radius (before planet_scale)
const ORBIT_SCALE := 2.0         # planets sit this many times further from their system centre than planets.json / systems.json x,y say (the data stays as is)
## Planet size variation: each planet is PLANET_SIZE_MIN..PLANET_SIZE_MAX (0.715 to 1.885) of the base radius. A planet's own "size" key in
## the data wins; otherwise the value comes from a hash of its id, so it is the same every run. Dead worlds use the same range.
const PLANET_SIZE_MIN := 0.715   # 0.55 x 1.3 (owner: planets 1.3x bigger again)
const PLANET_SIZE_MAX := 1.885   # 1.45 x 1.3
const PLANET_PICK_MIN := 0.75 * PLANET_SCALE_UP    # smallest click radius of a planet (world units), so the smallest planets stay easy to hit
const CLUSTER_PICK_MIN := 0.3     # smallest click radius of an asteroid pack (world units); under a planet's radius
const PLANET_SIZE := 1.3 * PLANET_SCALE_UP         # planet size multiplier: planets are x1.3 the old size; the debug menu starts here
const BASE_DISTANCE := 16.0      # camera distance from focus point at zoom 1
const CAMERA_FOV := 45.0
const PLANET_SPHERE := preload("res://game/fx/planet/planet_sphere.tscn")  # unit-radius sphere; scaled to planet_radius()

# Orbit limits in degrees (owner-to-confirm defaults). Yaw 0 looks along -Z.
const START_YAW_DEG := 0.0
const START_PITCH_DEG := 45.0
const ORBIT_MOUSE_SENS := 0.3    # degrees per pixel of right-drag
const PAN_LIMIT_MIN := 6.0 * MAP_SCALE_UP       # floor for the pan limit radius (world units)
const ORBIT_KEY_SPEED := 60.0    # degrees per second for arrow keys

# T33 tunables (live-editable, runtime only, never saved)
var zoom_min := 0.25 / MAP_SCALE_UP
var zoom_max := 3.0
var pan_margin := 1.3             # camera focus may stray this many times the outermost planet's orbit radius from the system centre
var yaw_min_deg := -45.0
var yaw_max_deg := 45.0
var pitch_min_deg := 20.0        # angle above the plane; never goes below it
var pitch_max_deg := 80.0
var sun_radius := 0.75
var sun_node: Node3D  # T132: animated 3D sun
var suns := {}         # system id -> its sun node (game/fx/sun/sun_flare.gd); every open system has its own sun
var sun_positions := {}  # system id -> world position of that sun
var orbit_rings := {}    # system id -> its orbit ring mesh
var planet_belts := {}   # planet index -> its small decorative dust belt (Voltara)
var dust_rings := {}     # system id -> its decorative asteroid dust ring (game/fx/planet/asteroid_dust_ring.gd)
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
var _routes_seen := false   # T219: the first set_routes (load) draws no lane in
var _max_route_id := -1     # T219: ids above it are new routes
var traffic: Node3D               # T277: instanced traffic layer (traffic_layer.gd)
var route_lines: Dictionary = {}  # T07b: route id -> route_line.gd node
var _route_list: Array = []       # last list given to set_routes (rebuilt after tunable changes)

signal station_clicked(system_id: int)
signal rival_clicked(bot: int)  # T199: competitor id of the rival ship under a left click, 0 = none (closes the card)
var prosperity = null  # T264: game/prosperity.gd, set by main; the growth ring and need icons read it
var events = null  # T285: game/events.gd, set by main; weather chips on worlds and congested lanes read events.active
var capital_planet := ""  # T264: planet id of the Bazaar capital (marker); set by main once the Bazaar exists
var _growth: Control = null
var rivals: Node = null  # T199: game/rival_ships.gd, set by main
## T180: flight orders and establish orders; see the interface at the top of game/pathfinder_view.gd. Never emitted while flight is null or off.
var free_ship_menu := false  # T329: set by main during the first tutorial card: the planet menu opens without selecting the ship
signal fly_requested(target: Dictionary)   # {"kind": "planet"|"storage"|"cluster"|"point", "pos": Vector3, "index": int}
signal establish_requested(planet_id: String)
## T200: ship controls. Click the ship to select it; with it selected LEFT click flies at once, RIGHT click on a planet asks main for the
## action menu (only the allowed actions), Esc / right-click on open space deselects.
signal action_menu_requested(planet_id: String, screen_pos: Vector2)
signal good_icon_right_clicked(planet: int, good: String)  # right click on a goods icon above a planet: main starts a Send to for it
signal planet_right_clicked(index: int, screen_pos: Vector2)  # right click on a planet with no ship order mode: main decides (resource popup, or the Establish menu)
signal fly_establish_requested(planet_id: String)
const SHIP_PICK_PX := 20.0  # T198: was 30 at the old ship size; the ship is half as big, the pick area shrinks less so it stays easy to hit
const RIGHT_CLICK_DRAG_PX := 6.0
var ship_selected := false
var _rc_down := false             # right button pressed on the map and not dragged yet (a drag orbits the camera)
var _rc_drag := 0.0
const PathfinderView := preload("res://game/pathfinder_view.gd")
const Juice := preload("res://game/juice.gd")  # T203
const ESTABLISH_NUDGE := 0.05          # T203: soft camera nudge when a post stands, world units sideways (scaled by Juice.motion)
const ESTABLISH_NUDGE_SECONDS := 0.35
const DeadWorlds := preload("res://game/dead_worlds.gd")
const StoryText := preload("res://game/story_text.gd")
const UNKNOWN_SHADE_ALPHA := 0.62
var flight = null                 # T180: accessor set by main.gd (T179); null = discovery off, nothing below changes
var pathfinder = null             # T180: the 3D scout (game/pathfinder_view.gd), created on first use
var _shades := {}                 # planet index -> dim overlay sphere of a closed planet
var _known_cache := {}            # planet index -> last "discovered" state, to rewrite names only on a change
signal cluster_clicked(index: int)  # T159: click on an asteroid pack (index in the cluster data)
var _cluster_list: Array = []  # T159: last list given to set_clusters, for picking
var game_seconds_fn := Callable()  # T314: main sets it: game seconds (stops while paused); drives the pack orbits
var clusters_fn := Callable()      # T314: main sets it: returns main.clusters_in_system(0) with the current pack positions
var _cluster_refresh := 0.0
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
	asteroid_packs.running = _game_running
	add_child(asteroid_packs)
	# T277: instanced traffic ships (game/traffic/traffic_layer.gd); drives itself, fades out at far zoom. Groups are fed by the traffic tasks.
	traffic = load("res://game/traffic/traffic_layer.gd").new()
	traffic.map = self
	add_child(traffic)
	traffic.set_sun_dir(-key_light.basis.z)
	_frame_planets()
	_add_sun(focus)
	_add_orbit_rings(focus, 1)
	_add_planet_belt("Voltara")
	_update_camera()
	# Chromatic aberration over the 3D view (game/fx/planet/chromatic_aberration.gd): first, so the glare and grain sit on top of it.
	add_child(load("res://game/fx/planet/chromatic_aberration.gd").new())
	# Screen-space soft edge: blurs a 10 px ring outside each planet disc (game/fx/planet/edge_blur.gd); after the aberration, before the glare and grain.
	var edge_blur: CanvasLayer = load("res://game/fx/planet/edge_blur.gd").new()
	edge_blur.camera = camera
	edge_blur.spheres = planet_spheres
	add_child(edge_blur)
	# Camera lens glare around the current system's sun (game/fx/planet/lens_glare.gd); the quad draws under the UI.
	var glare: CanvasLayer = load("res://game/fx/planet/lens_glare.gd").new()
	glare.camera = camera
	glare.source_pos = func() -> Variant: return sun_positions.get(view_system) if suns.has(view_system) and suns[view_system].visible else null
	glare.source_brightness = func() -> float: return 0.75 + 0.5 * float(suns[view_system].flare) if suns.has(view_system) else 1.0
	add_child(glare)
	# Film grain over the 3D map view (game/fx/planet/film_grain.gd): same layer as the glare, added after it, under the UI.
	add_child(load("res://game/fx/planet/film_grain.gd").new())
	# T167: the planet names go last on the same layer, so they draw above the blur, glare and grain (same layer: tree order).
	move_child(_label_layer_node(), -1)

## Orbit rings: thin circles on the ground plane through each planet, centred on the sun, plus one dashed
## outer ring. The camera pitch gives the tilt. Colours: theme tokens line_200 / line_100.
## Visual only: no collision, no shadows, never hit by the planet click test.
const ORBIT_LINE_ALPHA := 0.55  # owner: orbit rings looked too thick
func _add_orbit_rings(center: Vector3, sys: int = 1) -> void:
	var inner := Ui.col("line_200")
	var outer := Ui.col("line_100")
	inner.a *= ORBIT_LINE_ALPHA  # the rings are 1 px lines (the minimum); a lower alpha makes them read thinner
	outer.a *= ORBIT_LINE_ALPHA
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

## Decorative dust: up to 7 broken bands (game/fx/planet/asteroid_dust_ring.gd). The gaps between orbit lines (sun edge,
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
		var belt: MultiMeshInstance3D = load("res://game/fx/planet/asteroid_dust_ring.gd").new()
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
	var ring: MultiMeshInstance3D = load("res://game/fx/planet/asteroid_dust_ring.gd").new()
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
	if _growth == null and _label_layer != null:
		_growth = preload("res://game/world_growth_view.gd").new()
		_growth.map = self
		_label_layer.add_child(_growth)
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
	if traffic != null:
		traffic.set_view_system(id)  # T277: ships are drawn only in the viewed system
	focus_system(id)
	_refresh_hub_ring_visibility()  # T291
	_apply_view()

func planet_in_view(i: int) -> bool:
	return i >= 0 and i < planets.size() and int(planets[i].get("system", 1)) == view_system

## T157: show the asteroid packs of the clusters given (main.clusters_in_system). Visual only.
func set_clusters(list: Array) -> void:
	_cluster_list = list
	if prosperity != null:  # T306: slow spin and orbit swing of the packs (balance keys, placeholders)
		asteroid_packs.spin_speed = _bk("asteroid_spin_deg_per_s", 0.0)
		asteroid_packs.orbit_speed = _bk("asteroid_orbit_deg_per_s", 0.0)
		asteroid_packs.clock = game_seconds_fn  # T314: packs and cluster positions read the same game clock
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
	# T132: the animated 3D sun (game/fx/sun/sun_flare.gd). System 1's sun drives the planets' key light; each system's sun
	# has its own colour (Systems.sun_color_of: system 1 orange, system 2 blue).
	var sn: Node3D = load("res://game/fx/sun/sun_flare.gd").new()
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
	hex_ring = load("res://game/fx/sun/hex_ring.gd").new()
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

## T291: reach rings of hubs: [{planet: int, radius: float}] in map units; a thin flat ring around each hub world, only in
## the viewed system. An empty list removes them all. Main calls this when a hub is made, released or changes tier.
var hub_rings := {}  # planet index -> MeshInstance3D
func set_hub_rings(list: Array) -> void:
	var keep := {}
	for e in list:
		var i := int(e["planet"])
		if i < 0 or i >= positions.size() or float(e["radius"]) <= 0.0:
			continue
		keep[i] = float(e["radius"])
	for i in hub_rings.keys():
		if not keep.has(i):
			(hub_rings[i] as Node).queue_free()
			hub_rings.erase(i)
	for i in keep:
		var r: float = keep[i]
		var m: MeshInstance3D = hub_rings.get(i)
		if m == null:
			m = MeshInstance3D.new()
			m.name = "HubReach_%d" % i
			m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(m)
			hub_rings[i] = m
		var ring := TorusMesh.new()
		var half := maxf(0.02, r * 0.004)
		ring.inner_radius = r - half
		ring.outer_radius = r + half
		ring.rings = 96
		ring.ring_segments = 4
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		var c := Ui.col("star_warm")
		mat.albedo_color = Color(c, 0.45)
		ring.material = mat
		m.mesh = ring
		m.position = positions[i]
		m.visible = planet_in_view(i)

## Hub rings follow the viewed system (called with the system change).
func _refresh_hub_ring_visibility() -> void:
	for i in hub_rings:
		(hub_rings[i] as MeshInstance3D).visible = planet_in_view(int(i))

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
		var rad: float = start_r if b < 0 else maxf(start_r, planet_radius(b))
		if line != null and line.pair_a == a and line.pair_b == b:  # T248: same pair, new shape: the line eases there
			line.retarget(start_pos, end_pos, rad, half, sun_list(), lane)
		elif line != null:
			line.queue_free()
			route_lines.erase(id)
			line = null
		if line == null:
			line = load("res://game/route_line.gd").new()
			add_child(line)
			line.setup(id, a, b, start_pos, end_pos, start_r if b < 0 else maxf(start_r, planet_radius(b)), half, sun_list(), lane)
			route_lines[id] = line
			_label_layer_node().add_child(line.tag2d)
			if _routes_seen and int(id) > _max_route_id:
				line.draw_in()  # T219: a route made now grows from its source end (a load or a rebuild does not)
		line.set_style(str(r.get("status", "running")), int(r.get("ships", 1)), str(r.get("c", "")), int(r.get("net", 0)), str(r.get("reason", "")), bool(r.get("net_ok", false)), int(r.get("cost", 0)), str(r.get("why", "")))
	for id in route_lines.keys():
		if not seen.has(id):
			if not route_lines[id].fade_out():  # T219: fades, then frees itself (paused or no motion: freed at once)
				route_lines[id].queue_free()
			route_lines.erase(id)
	for id in seen:
		_max_route_id = maxi(_max_route_id, int(id))
	_routes_seen = true
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
	set_routes(_route_list)
	_update_camera()

## T265: night-side city lights and halo follow prosperity.tier(i). Targets come from data/balance.json (tier_lights_t0..,
## tier_halo_t0..); the sphere eases a change over tier_look_ease_seconds. The first sight of a planet snaps.
var _tier_look_seen := {}  # planet index -> tier last pushed
func _update_tier_looks() -> void:
	if prosperity == null:
		return
	var bal: Dictionary = prosperity.balance
	for i in planet_spheres.size():
		var t: int = maxi(0, int(prosperity.tier(i)))
		var first := not _tier_look_seen.has(i)
		if not first and int(_tier_look_seen[i]) == t:
			continue
		_tier_look_seen[i] = t
		if _bloom_left.has(i):
			continue  # T266: a tier-up bloom is showing; it pushes the settled look itself when it ends
		var k := clampi(t, 0, 3)
		planet_spheres[i].set_tier_look(float(bal.get("tier_lights_t%d" % k, 0.0)), float(bal.get("tier_halo_t%d" % k, 0.0)),
			float(bal.get("tier_lights_gain", 1.0)), float(bal.get("tier_look_ease_seconds", 1.0)), first)

## T297: dead worlds show their reclaim ring as green creeping over the surface; the flip (green wave, then clouds and atmosphere fading in, the first
## lights) runs in game time when prosperity reports the world reclaimed. A world met already reclaimed (load) snaps to the living look.
## Numbers: data/balance.json reclaim_* (placeholders).
var _reclaim_seen := {}   # planet index -> true once looked at
var _reclaim_flip := {}   # planet index -> game seconds into the flip
func _update_reclaim_looks(delta: float) -> void:
	if prosperity == null:
		return
	var running := _game_running()
	var wave_s := _bk("reclaim_wave_seconds", 2.5) * Juice.motion
	var fade_s := _bk("reclaim_fade_seconds", 2.0) * Juice.motion
	var green := Color(_bk("reclaim_green_r", 0.3), _bk("reclaim_green_g", 0.62), _bk("reclaim_green_b", 0.22))
	for i in planet_spheres.size():
		var sph = planet_spheres[i]
		if not sph.looks_dead() and not _reclaim_flip.has(i):
			_reclaim_seen[i] = true
			continue
		var done: bool = prosperity.is_reclaimed(i)
		if done and not _reclaim_flip.has(i):
			if _reclaim_seen.has(i) and wave_s > 0.0:
				_reclaim_flip[i] = 0.0
				beat_reclaim(i)
			else:
				sph.become_living()
				_push_first_lights(i, 0.0)
		elif not done:
			sph.set_reclaim(prosperity.reclaim_progress(i), _bk("reclaim_tint_max", 0.6), _bk("reclaim_haze", 0.5), green)
		_reclaim_seen[i] = true
		if _reclaim_flip.has(i):
			var t: float = float(_reclaim_flip[i]) + (delta if running else 0.0)
			_reclaim_flip[i] = t
			if sph.set_reclaim_flip(clampf(t / wave_s, 0.0, 1.0), clampf((t - wave_s) / maxf(fade_s, 0.001), 0.0, 1.0) if fade_s > 0.0 else 1.0, _bk("reclaim_wave_width", 0.12)):
				_push_first_lights(i, fade_s)
			if t >= wave_s + fade_s:
				_reclaim_flip.erase(i)

## The first night-side lights of a reclaimed world ease in over `seconds` (0 = at once).
func _push_first_lights(i: int, seconds: float) -> void:
	var bal: Dictionary = prosperity.balance
	var k := clampi(maxi(1, int(prosperity.tier(i))), 0, 3)
	_tier_look_seen[i] = maxi(1, int(prosperity.tier(i)))
	planet_spheres[i].set_tier_look(float(bal.get("tier_lights_t%d" % k, 0.0)), float(bal.get("tier_halo_t%d" % k, 0.0)),
		float(bal.get("tier_lights_gain", 1.0)), seconds, seconds <= 0.0)

## T279: orbital traffic. Each established world in the viewed system gets a close ring of tiny shuttles: count from its tier
## (balance traffic_orbit_t<N>), thinned by traffic_orbit_restless_keep (0..1 kept) while Restless. A tier-up fills the new ships
## in over traffic_orbit_burst_seconds. Readout only: derived from prosperity, nothing is saved.
var _orbit_shown := {}   # planet index -> float count currently drawn
var _orbit_gen := -1     # traffic.generation the groups were set for
func _update_orbit_traffic(delta: float) -> void:
	if traffic == null or prosperity == null:
		return
	var bal: Dictionary = prosperity.balance
	if _orbit_gen != traffic.generation:
		_orbit_gen = traffic.generation
		_orbit_shown.clear()
	var burst := maxf(float(bal.get("traffic_orbit_burst_seconds", 1.0)), 0.01)
	for i in planets.size():
		var key := "orbit_%d" % i
		var t: int = int(prosperity.tier(i)) if planet_in_view(i) else 0
		var want := 0.0
		if t >= 1:
			want = float(bal.get("traffic_orbit_t%d" % t, 0.0))
			if prosperity.restless(i):
				want *= clampf(float(bal.get("traffic_orbit_restless_keep", 1.0)), 0.0, 1.0)
		var have: float = _orbit_shown.get(i, -1.0)
		if is_equal_approx(have, want):
			continue
		var next := want
		if have >= 0.0 and want > have:
			next = minf(want, have + want * delta / burst + 0.0001)  # burst in: new ships appear over a short time
		_orbit_shown[i] = next
		var n := roundi(next)
		if have >= 0.0 and n == roundi(have):
			continue
		if n <= 0:
			traffic.clear_group(key)
			continue
		var r := planet_radius(i)
		var r_in := r * float(bal.get("traffic_orbit_ring_in", 1.2))
		var r_out := r * float(bal.get("traffic_orbit_ring_out", 1.5))
		var tilt := deg_to_rad(float(bal.get("traffic_orbit_tilt_deg", 20.0))) * (1.0 if i % 2 == 0 else -1.0)
		traffic.set_orbit_group(key, positions[i], r_in, r_out, n, "corvette", tilt, 1.0 if i % 2 == 0 else -1.0, Color.TRANSPARENT, float(bal.get("traffic_orbit_ship_scale", 0.5)) * Ships.ship_scale())

## T303: ambient lanes. Every pair of planets in the viewed system carries a stream of small ships from the start of a run, no
## condition (a lane exists whether or not the player trades there). balance traffic_ambient_ships is shared over the pairs
## (shorter lanes get more, every lane at least traffic_ambient_min). The arc is the route line's (same GAP and BOW). Buffers are
## rewritten only when the planet set, positions, sizes or numbers change, never per frame. Readout only, nothing is saved.
var _ambient_sig := ""
var _ambient_keys: Array = []
var _ambient_gen := -1
func _update_ambient_traffic() -> void:
	if traffic == null or prosperity == null:
		return
	var bal: Dictionary = prosperity.balance
	var ids: Array = []
	for i in planets.size():
		if planet_in_view(i) and i < positions.size():
			ids.append(i)
	var total := int(bal.get("traffic_ambient_ships", 0))
	var min_n := int(bal.get("traffic_ambient_min", 1))
	var sig := "%d|%d|%d|%d|%s" % [view_system, total, min_n, int(bal.get("traffic_max_instances", 0)), "%s" % [float(bal.get("traffic_ambient_scale", 1.0)) + float(bal.get("traffic_ambient_speed", 1.0))]]
	for i in ids:
		sig += "|%d:%s:%.3f" % [i, positions[i], planet_radius(i)]
	if _ambient_gen == traffic.generation and sig == _ambient_sig:
		return
	_ambient_gen = traffic.generation
	_ambient_sig = sig
	for k in _ambient_keys:
		traffic.clear_group(k)
	_ambient_keys.clear()
	var lanes: Array = []   # [key, p0, pc, p2, weight]
	var wsum := 0.0
	for ai in ids.size():
		for bi in range(ai + 1, ids.size()):
			var a: int = ids[ai]
			var b: int = ids[bi]
			var cv := _lane_curve(a, b)  # a sun in the way: through the same waypoint as the route line
			var p0: Vector3 = cv[0]
			var c: Vector3 = cv[1]
			var p2: Vector3 = cv[2]
			var chord := p0.distance_to(p2)
			var w := 1.0 / maxf(chord, 0.1)
			wsum += w
			lanes.append(["ambient_%d_%d" % [a, b], p0, c, p2, w, planet_radius(a), planet_radius(b)])
	var spare := maxi(total - min_n * lanes.size(), 0)
	for l in lanes:
		var n := min_n + int(floor(float(spare) * float(l[4]) / maxf(wsum, 0.0001)))
		if total <= 0:
			continue
		traffic.set_ambient_group(l[0], l[1], l[2], l[3], n, "corvette", l[5], l[6])
		_ambient_keys.append(l[0])

## T292: hub shuttles. A hub keeps its worlds fed; every need it fills (Hubs status "hub") draws as small shuttles on the lane hub >
## world (path groups, same arc as the route line), hub_shuttles_per_need each. Designating a hub starts a ripple to its reach edge
## (beat "hub", drawn by world_growth_view) and each world's shuttles launch as the ripple reaches it, so they leave in a fan.
## A need filled later ramps its shuttles in the same way (a shuttle peels off toward the world). A released hub's shuttles turn
## round, fly home and fade out. Game time only (frozen while paused); a readout of Hubs, nothing is saved.
var hubs: RefCounted = null   # Hubs, set by main
var _hub_prim := false         # the first look after a load only records the hubs, no ripple
var _hub_seen := {}            # hub planet -> true, hubs standing at the last look
var _hub_lanes := {}           # key "hub_<h>_<w>" -> {h, w, have: float, want: int, delay: float, back: bool, sig: String}
var _hub_gen := -1
func _lane_curve(a: int, b: int) -> Array:
	var dir := (positions[b] - positions[a]).normalized()
	var p0 := positions[a] + dir * planet_radius(a) * RouteLineScript.GAP
	var p2 := positions[b] - dir * planet_radius(b) * RouteLineScript.GAP
	var chord := p0.distance_to(p2)
	var c := (p0 + p2) * 0.5 + Vector3.UP.cross(dir).normalized() * chord * RouteLineScript.BOW
	var sw = RouteOffset.sun_waypoint(positions[a], positions[b], sun_list())
	if sw != null:
		var wt: float = clampf(p0.distance_to(sw) / maxf(p0.distance_to(sw) + sw.distance_to(p2), 0.001), 0.15, 0.85)
		c = (sw - p0 * ((1.0 - wt) * (1.0 - wt)) - p2 * (wt * wt)) / (2.0 * (1.0 - wt) * wt)
	return [p0, c, p2]

func _update_hub_traffic(delta: float) -> void:
	if traffic == null or prosperity == null or hubs == null:
		return
	var running := _game_running()
	if _hub_gen != traffic.generation:
		_hub_gen = traffic.generation
		_hub_lanes.clear()  # the layer dropped every group: lanes are set again below
	var motion: float = Juice.motion
	var ripple_s := _bk("hub_ripple_seconds", 1.6) * motion
	var now: Array = hubs.hub_planets()
	# a hub just designated: ripple out to the reach edge
	for h in now:
		if not _hub_seen.has(h):
			_hub_seen[h] = true
			if _hub_prim and motion > 0.0 and h < positions.size():
				beats.append({"kind": "hub", "planet": h, "t": 0.0, "dur": ripple_s})
				beat_chime.emit("hub", h)
				for k in _hub_lanes:
					if int(_hub_lanes[k]["h"]) == h:
						_hub_lanes[k]["have"] = 0.0
						_hub_lanes[k]["delay"] = 0.0
	_hub_prim = true
	# a hub released: its lanes turn round and fly home
	for h in _hub_seen.keys():
		if not now.has(h):
			_hub_seen.erase(h)
			for k in _hub_lanes:
				if int(_hub_lanes[k]["h"]) == h:
					_hub_lanes[k]["want"] = 0
					_hub_lanes[k]["back"] = true
	# wanted shuttles per lane of the standing hubs
	var per_need := int(_bk("hub_shuttles_per_need", 2.0))
	for h in now:
		if not planet_in_view(h) or h >= positions.size():
			continue
		var reach: float = maxf(hubs.reach_of(h), 0.001)
		for w in hubs.worlds_in_reach(h):
			if w == h or not planet_in_view(w) or w >= positions.size():
				continue
			var needs := 0
			for g in hubs._need_goods(w):
				if hubs.status_of(w, str(g)) == hubs.STATUS_HUB:
					needs += 1
			var key := "hub_%d_%d" % [h, w]
			var lane = _hub_lanes.get(key)
			if lane == null:
				if needs <= 0:
					continue
				var fan := ripple_s * clampf(hubs.distance(h, w) / reach, 0.0, 1.0) if _hub_ripple_running(h) else 0.0
				lane = {"h": h, "w": w, "have": 0.0, "want": 0, "delay": fan, "back": false, "sig": ""}
				_hub_lanes[key] = lane
			lane["want"] = needs * per_need
			lane["back"] = false
	# advance the ramps and write the groups when a drawn count or the geometry changes
	var launch := maxf(_bk("hub_launch_seconds", 1.5), 0.05) * (motion if motion > 0.0 else 0.0)
	var scale_m := _bk("hub_shuttle_scale", 0.6)
	for k in _hub_lanes.keys():
		var lane: Dictionary = _hub_lanes[k]
		var h: int = int(lane["h"])
		var w: int = int(lane["w"])
		if running:
			if float(lane["delay"]) > 0.0:
				lane["delay"] = float(lane["delay"]) - delta
			else:
				var want := float(lane["want"])
				var have: float = lane["have"]
				if launch <= 0.0:
					have = want
				elif want > have:
					have = minf(want, have + want * delta / launch + 0.0001)
				elif want < have:
					have = maxf(want, have - maxf(have, 1.0) * delta / launch)
				lane["have"] = have
		var n := roundi(float(lane["have"])) if float(lane["delay"]) <= 0.0 else 0
		if h >= positions.size() or w >= positions.size() or not planet_in_view(h) or not planet_in_view(w):
			traffic.clear_group(k)
			_hub_lanes.erase(k)
			continue
		var back: bool = lane["back"]
		var sig := "%d|%s|%s|%s|%.3f|%.3f" % [n, back, positions[h], positions[w], planet_radius(h), planet_radius(w)]
		if sig != str(lane["sig"]):
			lane["sig"] = sig
			if n <= 0:
				traffic.clear_group(k)
			else:
				var cv := _lane_curve(w, h) if back else _lane_curve(h, w)
				traffic.set_path_group(k, cv[0], cv[1], cv[2], n, 0, Color.TRANSPARENT, "corvette", scale_m, 1.0, planet_radius(w if back else h), planet_radius(h if back else w))
		if n <= 0 and int(lane["want"]) <= 0 and float(lane["delay"]) <= 0.0:
			_hub_lanes.erase(k)  # fully gone (released, or the need was met)

func _hub_ripple_running(h: int) -> bool:
	return beat_progress("hub", h) >= 0.0

## T314: packs move round their sun, so the list picks, route ends, bodies and labels read is refreshed from Clusters.list (its x, y
## are the current position). Route lines that start at a pack are re-aimed about once a second (they ease to the new ends).
func _refresh_clusters(delta: float) -> void:
	if _cluster_list.is_empty() or not clusters_fn.is_valid() or asteroid_packs.orbit_speed == 0.0:
		return
	if game_seconds_fn.is_valid() and not bool(_game_running()):
		return
	var fresh: Array = clusters_fn.call()
	var byid := {}
	for c in fresh:
		byid[int(c["index"])] = c
	for c in _cluster_list:
		var f: Dictionary = byid.get(int(c["index"]), {})
		if not f.is_empty():
			c["x"] = f["x"]
			c["y"] = f["y"]
	_cluster_refresh += delta
	if _cluster_refresh >= 1.0:
		_cluster_refresh = 0.0
		for r in _route_list:
			if int(r["a"]) <= -1000:
				set_routes(_route_list)
				break

func _process(delta: float) -> void:
	_refresh_clusters(delta)
	_update_beats(delta)
	_update_reclaim_looks(delta)
	_update_tier_looks()
	_update_orbit_traffic(delta)
	_update_ambient_traffic()
	_update_hub_traffic(delta)
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

## T323: window position of planet `i`, or (-1, -1) when it is behind the camera or unknown.
func planet_screen_pos(i: int) -> Vector2:
	if camera == null or i < 0 or i >= positions.size() or camera.is_position_behind(positions[i]):
		return Vector2(-1, -1)
	return camera.unproject_position(positions[i])

## T322: window position of the Pathfinder, or (-1, -1) when it is not drawn or behind the camera.
func ship_screen_pos() -> Vector2:
	if not PathfinderView.active(flight) or pathfinder == null or not pathfinder.visible or camera == null:
		return Vector2(-1, -1)
	var w: Vector3 = PathfinderView._call(flight, "ship_position", [], Vector3.ZERO) + Vector3(0, PathfinderView.LIFT, 0)
	if camera.is_position_behind(w):
		return Vector2(-1, -1)
	return camera.unproject_position(w)

## System the Pathfinder is in (the one it is drawn in), 0 when there is none. During a jump it is still the old system.
func ship_system() -> int:
	if not PathfinderView.active(flight):
		return 0
	return int(PathfinderView._call(flight, "system_id", [], 0))

## Puts the camera on the Pathfinder (double click on its card in the Ships menu).
func focus_on_ship() -> void:
	if not PathfinderView.active(flight):
		return
	var w: Vector3 = PathfinderView._call(flight, "ship_position", [], Vector3.ZERO)
	focus = Vector3(w.x, focus.y, w.z)
	clamp_focus()

func select_ship(on: bool) -> void:
	ship_selected = on and PathfinderView.active(flight)

## T322: a new run starts zoomed in on `world` (the Pathfinder at its home dock); a loaded save never calls this.
## Placeholders for the owner: NEW_RUN_ZOOM_MULT times the default zoom, so the ship and its home world fill the window.
const NEW_RUN_ZOOM_MULT := 2.0
func start_view_on(world: Vector3) -> void:
	focus = Vector3(world.x, focus.y, world.z)
	zoom = clampf(START_ZOOM * NEW_RUN_ZOOM_MULT, zoom_min, zoom_max)
	clamp_focus()
	_update_camera()

## T327: centres the camera on the middle of the world points `pts` and zooms out (never in) until every one lies inside the
## window rect `region`. Stops at zoom_min.
func fit_points(pts: Array, region: Rect2) -> void:
	if pts.is_empty() or camera == null:
		return
	var mid := Vector3.ZERO
	for q in pts:
		mid += q
	mid /= float(pts.size())
	focus = Vector3(mid.x, focus.y, mid.z)
	clamp_focus()
	for _k in 80:
		_update_camera()
		var ok := true
		for q in pts:
			if camera.is_position_behind(q) or not region.has_point(camera.unproject_position(q)):
				ok = false
				break
		if ok or zoom <= zoom_min:
			return
		zoom = maxf(zoom_min, zoom * 0.93)

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
		if on and pick_ship(event.position):  # T200: click the ship to select it (T245: the ship wins, the planet behind it is not picked)
			ship_selected = true
			return
		var rb: int = int(rivals.pick_bot(event.position)) if rivals != null else 0  # T199: a rival ship under the cursor shows its card
		rival_clicked.emit(rb)  # 0 closes the card
		if rb > 0:
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
			if fly:  # T204: open space only drops the selection, the ship stays
				ship_selected = false
		elif fly:
			fly_requested.emit({"kind": "planet", "pos": positions[hit], "index": hit})
		planet_clicked.emit(hit)

## T200: right click (no drag). With the ship selected: a planet with allowed actions opens the menu; open space deselects.
func _right_click(pos: Vector2) -> void:
	var hit := pick_planet(pos)
	var flight_on := PathfinderView.active(flight)
	var ship_mode: bool = flight_on and (ship_selected or free_ship_menu)
	if not ship_mode and _growth != null:
		var gi: Dictionary = _growth.good_icon_at(pos)
		if not gi.is_empty():
			good_icon_right_clicked.emit(int(gi["planet"]), str(gi["good"]))
			return
	if hit >= 0 and not ship_mode:
		planet_right_clicked.emit(hit, pos)
		return
	if hit < 0 and pick_station(pos) < 0 and pick_cluster(pos) < 0:
		var rid := pick_route(pos)
		if rid >= 0:
			route_right_clicked.emit(rid, pos)
			return
	if not flight_on:
		return
	if hit >= 0:  # ship selected: the ship's action menu (Establish trading post, Dock and trade)
		var pid := str(planets[hit].get("id", hit))
		if not (PathfinderView._call(flight, "actions_for", [pid], []) as Array).is_empty() or PathfinderView.established(flight, pid):  # T270: Dock and trade
			action_menu_requested.emit(pid, pos)
		return
	if not ship_mode:
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

## T203: a post or platform was established at planet i: ring + sparkle on the planet, a pop of its name label and a soft camera
## nudge. Visual only. The ring and the nudge advance on game time, so they freeze while paused.
func establish_beat(i: int, col: Color) -> void:
	if i < 0 or i >= positions.size() or pathfinder == null:
		return
	pathfinder.play_established(positions[i], planet_radius(i), col)
	if i < planet_label_2d.size():
		Juice.pop(planet_label_2d[i])
	_nudge_t = 0.0

## ---- T266: growth beats (design/proposals/2026-11-06-empire-growth-v2.md 3.1 Juice and 4) ----
## A beat is {kind, planet, t, dur}: "notch" (a need step landed), "tier" (a world grew), "stage" (a Bazaar stage done). They advance
## on game time only (frozen while paused), world_growth_view.gd draws them in screen space (never takes a click), the camera pull
## yields at once to the player's own pan / orbit, and every length is a balance beat_* key (placeholders). beat_chime is the
## hook for a sound: nothing is connected yet.
signal beat_chime(kind: String, planet: int)
var beats: Array = []
var _steps_seen := {}    # planet index -> [tier, steps] at the last look
var _bloom_left := {}    # planet index -> game seconds of tier-up bloom left
var _pull_secs := 1.2   # T300: length of the running pull
var _pull_t := -1.0      # seconds into the camera pull, -1 when idle
var _pull_from := Vector3.ZERO
var _pull_to := Vector3.ZERO
var _pull_last := Vector3.ZERO

func _bk(key: String, fallback: float) -> float:
	return float(prosperity.balance.get(key, fallback)) if prosperity != null else fallback

func _game_running() -> bool:
	return not PathfinderView._call(flight, "is_paused", [], false)

## A world grew to `tier`: ring from the world, a light bloom, and a gentle pull of the camera toward it. The 0.4 s time slow
## is main's (it owns the clock).
func beat_tier_up(i: int, _tier: int) -> void:
	if i < 0 or i >= positions.size() or Juice.motion <= 0.0:
		return
	beats.append({"kind": "tier", "planet": i, "t": 0.0, "dur": _bk("beat_ring_seconds", 1.4) * Juice.motion})
	beat_chime.emit("tier", i)
	_bloom_left[i] = _bk("beat_bloom_seconds", 1.2) * Juice.motion
	_push_bloom(i, true)
	_start_pull(i, _bk("beat_camera_pull", 0.5), _bk("beat_camera_seconds", 1.2))

## T300: ease the camera focus toward planet i by `frac` over `secs` (game time). Yields at once to the player's own pan and orbit.
func _start_pull(i: int, frac: float, secs: float) -> void:
	if planet_in_view(i) and not _player_steering():
		_pull_from = focus
		_pull_to = focus + (Vector3(positions[i].x, focus.y, positions[i].z) - focus) * clampf(frac, 0.0, 1.0)
		_pull_last = focus
		_pull_secs = secs
		_pull_t = 0.0

## A Bazaar stage finished at the capital: flash and an expanding ring there.
func beat_stage(i: int) -> void:
	if i < 0 or i >= positions.size() or Juice.motion <= 0.0:
		return
	beats.append({"kind": "stage", "planet": i, "t": 0.0, "dur": _bk("beat_stage_seconds", 1.8) * Juice.motion})
	beat_chime.emit("stage", i)

## T300: a dead world turned living: the camera eases to it while the flip plays (it stays there; the player can take it back at any
## time) and a chime plays. Called when the flip starts, never for a world met already living (a load).
func beat_reclaim(i: int) -> void:
	if i < 0 or i >= positions.size() or Juice.motion <= 0.0:
		return
	beat_chime.emit("reclaim", i)
	Juice.play_tone(self, "chime")
	_start_pull(i, _bk("beat_reclaim_camera_pull", 1.0), _bk("beat_reclaim_camera_seconds", 2.0))

func _frontier() -> Control:
	if _frontier_fx == null:
		_frontier_fx = preload("res://game/traffic/frontier_beats.gd").new()
		_frontier_fx.map = self
		_label_layer_node().add_child(_frontier_fx)
	return _frontier_fx
var _frontier_fx: Control = null

## T300: a raid hit lane route `lane` (planets a and b) from the nest planet; pods dropped at `pods_at` (Vector3.INF = none).
func beat_raid(a: int, b: int, nest: int, pods_at: Vector3) -> void:
	if a < 0 or a >= positions.size() or not planet_in_view(a) or _frontier() == null:
		return
	var pb: Vector3 = positions[b] if b >= 0 and b < positions.size() else positions[a]
	_frontier_fx.raid(positions[a], pb, positions[nest] if nest >= 0 and nest < positions.size() else positions[a] + Vector3(1, 0, 0), pods_at)

## T300: the Flagship scooped salvage pods at world position `at`.
func beat_scoop(at: Vector3) -> void:
	if _frontier() != null:
		_frontier_fx.scoop(at)

## T300: the Bazaar opened at planet i: ships converge, the ring lights, a flash (the banner is main's). The camera eases to the capital.
func beat_opening(i: int) -> void:
	if i < 0 or i >= positions.size() or Juice.motion <= 0.0:
		return
	beat_chime.emit("opening", i)
	_start_pull(i, 1.0, _bk("beat_camera_seconds", 1.2))
	if _frontier() != null:
		_frontier_fx.opening(i)

## A short sideways camera nudge (the raid hit), the same one a new post gives.
func nudge_camera() -> void:
	_nudge_t = 0.0

## 0..1 progress of the newest running beat of this kind at planet i, or -1 when none.
func beat_progress(kind: String, i: int) -> float:
	var best := -1.0
	for b in beats:
		if b["kind"] == kind and int(b["planet"]) == i:
			best = maxf(best, float(b["t"]) / maxf(0.001, float(b["dur"])))
	return best

func _player_steering() -> bool:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		return true
	return keys_enabled and (_axis(KEY_A, KEY_D) != 0.0 or _axis(KEY_W, KEY_S) != 0.0 or _axis(KEY_LEFT, KEY_RIGHT) != 0.0 or _axis(KEY_DOWN, KEY_UP) != 0.0)

func _push_bloom(i: int, on: bool) -> void:
	if i >= planet_spheres.size() or prosperity == null:
		return
	var bal: Dictionary = prosperity.balance
	var k := clampi(maxi(0, int(prosperity.tier(i))), 0, 3)
	var g := _bk("beat_bloom_gain", 2.0) if on else 1.0
	planet_spheres[i].set_tier_look(minf(1.0, float(bal.get("tier_lights_t%d" % k, 0.0)) * g), minf(1.0, float(bal.get("tier_halo_t%d" % k, 0.0)) * g + (0.2 if on else 0.0)),
		float(bal.get("tier_lights_gain", 1.0)), float(bal.get("tier_look_ease_seconds", 1.0)) * (0.3 if on else 1.0), false)

func _update_beats(delta: float) -> void:
	if prosperity == null:
		return
	# need notches: a step gained inside the same tier ticks the ring (the first look only records)
	for i in planets.size():
		var t: int = int(prosperity.tier(i))
		var st: int = int(prosperity.steps(i))
		var seen = _steps_seen.get(i)
		_steps_seen[i] = [t, st]
		if seen != null and int(seen[0]) == t and st > int(seen[1]) and t >= 1 and Juice.motion > 0.0:
			beats.append({"kind": "notch", "planet": i, "t": 0.0, "dur": _bk("beat_notch_seconds", 0.5) * Juice.motion})
			beat_chime.emit("notch", i)
	if not _game_running():
		return
	for b in beats:
		b["t"] = float(b["t"]) + delta
	beats = beats.filter(func(b) -> bool: return float(b["t"]) < float(b["dur"]))
	for i in _bloom_left.keys():
		_bloom_left[i] = float(_bloom_left[i]) - delta
		if float(_bloom_left[i]) <= 0.0:
			_bloom_left.erase(i)
			_push_bloom(int(i), false)
	if _pull_t >= 0.0:
		if _player_steering() or focus.distance_to(_pull_last) > 0.0005 or Juice.motion <= 0.0:
			_pull_t = -1.0  # the player took the camera: never fight them
		else:
			_pull_t += delta
			var u := clampf(_pull_t / (maxf(0.05, _pull_secs) * Juice.motion), 0.0, 1.0)
			focus = _pull_from.lerp(_pull_to, smoothstep(0.0, 1.0, u))
			clamp_focus()
			_pull_last = focus
			if u >= 1.0:
				_pull_t = -1.0

var _nudge_t := -1.0   # T203: seconds into the camera nudge, -1 when idle

## Sideways camera offset for the running nudge (zero when idle). Advances only while the game runs.
func _nudge_offset() -> Vector3:
	if _nudge_t < 0.0:
		return Vector3.ZERO
	if Juice.motion <= 0.0:
		_nudge_t = -1.0
		return Vector3.ZERO
	if not PathfinderView._call(flight, "is_paused", [], false):
		_nudge_t += get_process_delta_time()
	var t := _nudge_t / (ESTABLISH_NUDGE_SECONDS * Juice.motion)
	if t >= 1.0:
		_nudge_t = -1.0
		return Vector3.ZERO
	var right := camera.global_transform.basis.x
	return right * Juice.shake_offset(t, ESTABLISH_NUDGE * Juice.motion).x

func _update_camera() -> void:
	var yaw := deg_to_rad(yaw_deg)
	var pitch := deg_to_rad(pitch_deg)
	var dist := BASE_DISTANCE / zoom
	var offset := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * dist
	camera.position = focus + offset
	camera.look_at(focus, Vector3.UP)
	if _nudge_t >= 0.0:
		camera.position += _nudge_offset()  # T203: sideways only, look direction kept, so it ends exactly at rest
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
