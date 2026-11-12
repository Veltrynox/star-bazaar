extends Node3D
const Clusters := preload("res://game/clusters.gd")
## T157: ellipsoid packs (long axis along the orbit tangent, cluster_stretch) of asteroids on the trade map. One MultiMeshInstance3D per cluster = one draw call per pack.
## Per-instance position, rotation and scale come from a seed (hash of the cluster id + seed_salt), so a pack looks the same
## every time. The pack thins from the end of the list as ore is taken (visible_instance_count), so the surviving rocks stay put.
## Motion: game/galaxy/asteroid_pack.gdshader moves every rock in the vertex stage (own tumble, small closed drift path round its home spot kept inside the
## pack ellipsoid, gentle bob); the pack no longer turns as one block, so the click ellipsoid in map.gd stays valid. No collision: the map's click tests are maths on planets, so packs never block them.
## Visual only; reads the list given to sync(), never gameplay state.

@export var map_unit_scale := 0.02        # world units per map unit (same as map.gd MAP_UNIT_SCALE)
@export var seed_salt := 1                # change for a different arrangement of every pack
@export var pack_scale := 0.25            # owner 2026-11-05 (T168): field radius 2x (was 0.125); rocks keep their size, count x4 in the data for the same density
@export var rock_min := 0.005            # small rock size range, world units (radius); owner 2026-11-04: 80% small, 20% big
@export var rock_max := 0.009
@export var big_min := 0.02              # big rocks, roughly 2.5-3x the small ones
@export var big_max := 0.026
@export var big_share := 0.2             # share of rocks drawn from the big range
@export var squash := 0.0                 # 0 = round rocks (owner 2026-11-04), 1 = very lumpy: per-axis scale varies by up to this share
@export var flatten := 0.5                # pack height as a share of its width (0.5 = a disc-ish sphere)
@export var cluster_stretch := 2.0       # fallback when the cluster dictionary has no "stretch" (data/asteroid_clusters.json cluster_stretch)
@export var rock_color := Color(1.0, 1.0, 1.0)  # tints the rock texture; white = texture colours as they are
@export var rock_roughness := 0.95
@export var spin_speed := 0.0             # degrees per second the whole pack turns; 0 = still (T306: map.gd sets it from balance asteroid_spin_deg_per_s)
@export var orbit_speed := 0.0            # T314: degrees per second of a pack round the whole orbit about the sun (balance asteroid_orbit_deg_per_s; Clusters.orbit_angle seeds direction and a speed factor per pack)
var clock := Callable()                   # T314: returns game seconds (stops while paused); the same clock Clusters.pos_of reads. Empty = _clock below
var running := Callable()                 # returns false while the game is paused; only used when clock is empty
var _clock := 0.0                         # fallback game-clock seconds when no clock callable is set

# Rock model: assets/asteroid_asset/asteroid_low.obj, from asteroid.obj decimated to 400 tris (was 20480) by tools in the asteroid_asset folder.
# Normalised so the furthest vertex sits at radius 1.0, the same radius the old SphereMesh had.
# Owner 2026-11-04: round rocks. The OBJ is lumpy, so the default is a low-poly SphereMesh (radius 1). Set ROCK_MESH_KIND to "obj" to use the OBJ again.
const LUMPY_MESH := preload("res://assets/asteroid_asset/asteroid_low.obj")
const ROCK_MESH_KIND := "sphere"  # "sphere" (round) or "obj" (assets/asteroid_asset/asteroid_low.obj)
const SPHERE_SEGMENTS := 12
const SPHERE_RINGS := 6

static func make_rock_mesh() -> Mesh:
	if ROCK_MESH_KIND == "obj":
		return LUMPY_MESH
	var sm := SphereMesh.new()
	sm.radius = 1.0
	sm.height = 2.0
	sm.radial_segments = SPHERE_SEGMENTS
	sm.rings = SPHERE_RINGS
	return sm
const ROCK_TEXTURE := preload("res://assets/asteroid_asset/material_512.png")

var packs := {}  # cluster id -> {mm: MultiMeshInstance3D, system: int, max: int}
var _mesh: Mesh
var _mat: ShaderMaterial  # template; each pack gets a duplicate (own tangent / size uniforms)
const PACK_SHADER := preload("res://game/galaxy/asteroid_pack.gdshader")
const DRIFT_MAX := 0.3     # biggest drift amplitude, share of the pack radius
const HOME_SHARE := 0.9   # rocks sit inside this share of the ellipsoid so even the outer ones have room to drift
var view_system := 1
var sun_positions := {}  # system id -> world position of its sun (map.gd fills it); the orbit centre. Missing = world origin

## World-plane unit vector along the orbit at a cluster (perpendicular to the radius from the system centre).
## Falls back to +X when the cluster sits on the centre.
func tangent_of(c: Dictionary) -> Vector3:
	var centre: Vector3 = sun_positions.get(int(c["system"]), Vector3.ZERO)
	var rad := Vector3(float(c["x"]), 0.0, float(c["y"])) * map_unit_scale - centre
	rad.y = 0.0
	if rad.length() < 0.0001:
		return Vector3.RIGHT
	rad = rad.normalized()
	return Vector3(-rad.z, 0.0, rad.x)

func _ready() -> void:
	_mesh = make_rock_mesh()
	_mat = ShaderMaterial.new()
	_mat.shader = PACK_SHADER
	_mat.set_shader_parameter("albedo_color", rock_color)
	_mat.set_shader_parameter("albedo_tex", ROCK_TEXTURE)
	_mat.set_shader_parameter("roughness", rock_roughness)

## clusters: dictionaries from main.clusters_in_system(sid) (id, system, x, y, radius, count, visible). Missing ones are removed.
func sync(clusters: Array) -> void:
	var seen := {}
	for c in clusters:
		var id := str(c["id"])
		seen[id] = true
		var n := maxi(1, int(c["count"]))
		# rebuilt too when the system centre moved (the sun is placed after the packs exist)
		if not packs.has(id) or int(packs[id]["max"]) != n or not (packs[id]["centre"] as Vector3).is_equal_approx(sun_positions.get(int(c["system"]), Vector3.ZERO)):
			_build(id, c, n)
		var mmi: MultiMeshInstance3D = packs[id]["mm"]
		mmi.multimesh.visible_instance_count = clampi(int(c.get("visible", n)), 0, n)
		mmi.visible = int(c["system"]) == view_system
	for id in packs.keys():
		if not seen.has(id):
			packs[id]["mm"].queue_free()
			packs.erase(id)

func set_view_system(sid: int) -> void:
	view_system = sid
	for id in packs:
		packs[id]["mm"].visible = int(packs[id]["system"]) == sid
		if packs[id]["mm"].visible:
			_place(id)

func _build(id: String, c: Dictionary, n: int) -> void:
	if packs.has(id):
		packs[id]["mm"].queue_free()
	if _mesh == null:
		_ready()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true  # per-rock phase / drift amplitude / speed / seed for the shader (set before instance_count)
	mm.mesh = _mesh
	mm.instance_count = n
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(id) ^ (seed_salt * 7919)
	var r := float(c["radius"]) * map_unit_scale * pack_scale
	var stretch := maxf(1.0, float(c.get("stretch", cluster_stretch)))
	var tdir := tangent_of(c)
	var points := PackedVector3Array()  # local rock positions, kept for tests (the MultiMesh cannot be read back headless)
	var rad_dir := Vector3(tdir.z, 0.0, -tdir.x)  # unit vector away from the centre
	for i in n:
		var p := Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1))
		while p.length_squared() > 1.0:  # uniform inside the unit sphere
			p = Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1))
		p *= HOME_SHARE
		var margin := 1.0 - p.length()  # room left to the ellipsoid surface (normalised); the drift amplitude must fit in it
		p.y *= flatten
		p.x *= stretch  # x = along the tangent, z = across the radius; rocks keep their own shape
		var big := rng.randf() < big_share
		var s := rng.randf_range(big_min, big_max) if big else rng.randf_range(rock_min, rock_max)
		var sc := Vector3(1.0 + rng.randf_range(-squash, squash), 1.0 + rng.randf_range(-squash, squash), 1.0 + rng.randf_range(-squash, squash)) * s
		rng.randf(); rng.randf(); rng.randf()  # (was the random start rotation; the shader tumbles the rock now, the draws stay so pack layouts do not change)
		var basis := Basis.from_scale(sc)
		# custom data: x phase, y drift amplitude (share of pack radius; drift ellipse + bob reach <= 1.08 x amp, so 0.83 x margin fits inside), z signed speed factor, w seed
		var drng_sign := 1.0 if rng.randf() < 0.5 else -1.0
		mm.set_instance_custom_data(i, Color(rng.randf() * TAU, minf(0.83 * margin, DRIFT_MAX), rng.randf_range(0.5, 1.5) * drng_sign, rng.randf()))
		var pos := (tdir * p.x + rad_dir * p.z + Vector3.UP * p.y) * r
		points.append(pos)
		mm.set_instance_transform(i, Transform3D(basis, pos))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	var pmat := _mat.duplicate() as ShaderMaterial  # shares shader and texture, own pack size / direction
	pmat.set_shader_parameter("pack_tangent", tdir)
	pmat.set_shader_parameter("pack_radius", r)
	pmat.set_shader_parameter("pack_stretch", stretch)
	pmat.set_shader_parameter("pack_flatten", flatten)
	pmat.set_shader_parameter("game_time", _now())
	mmi.material_override = pmat
	mmi.extra_cull_margin = r * stretch * 0.3  # drifting rocks may leave the AABB of their home spots a little
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mmi.position = Vector3(float(c["x"]), 0.0, float(c["y"])) * map_unit_scale
	add_child(mmi)
	var mrng := RandomNumberGenerator.new()
	mrng.seed = hash(id) ^ 104729
	var spin_mul := mrng.randf_range(0.5, 1.5) * (1.0 if mrng.randf() < 0.5 else -1.0)
	var t0 := float(c.get("t0", 0.0))
	packs[id] = {"mm": mmi, "system": int(c["system"]), "max": n, "tangent": tdir, "points": points, "stretch": stretch,
		"anchor": mmi.position, "spin_mul": spin_mul, "centre": sun_positions.get(int(c["system"]), Vector3.ZERO), "t0": t0}
	# the rocks are laid out on the tangent at the position the pack has now, so the turn counts from the angle it has now
	packs[id]["ang0"] = Clusters.orbit_angle(id, orbit_speed, _now() - t0)
	_place(id)

func _now() -> float:
	return float(clock.call()) if clock.is_valid() else _clock

## T314: the pack travels the whole circle about the sun at its own radius (angle from Clusters.orbit_angle, one function of the
## game clock, the same one Clusters.pos_of uses for picks, routes, platforms and labels). The long axis stays on the tangent (the
## rocks turn with the orbit), plus the pack's own slow spin about its centre.
func _place(id: String) -> void:
	var d: Dictionary = packs[id]
	var mm: MultiMeshInstance3D = d["mm"]
	var anchor: Vector3 = d["anchor"]
	var t := _now()
	var ang := Clusters.orbit_angle(id, orbit_speed, t - float(d["t0"])) - float(d["ang0"])
	var centre: Vector3 = d["centre"]
	mm.position = centre + (anchor - centre).rotated(Vector3.UP, ang)
	# no rigid spin of the whole pack any more: the rocks move on their own in the shader, and the click ellipsoid must stay put
	mm.rotation = Vector3(0.0, ang, 0.0)
	(mm.material_override as ShaderMaterial).set_shader_parameter("game_time", t)

func _process(delta: float) -> void:
	if not clock.is_valid():
		if running.is_valid() and not bool(running.call()):
			return
		_clock += delta
	for id in packs:
		if packs[id]["mm"].visible:
			_place(id)  # moves the pack along its orbit and feeds game_time to the shader (frozen while paused: the clock stops)
