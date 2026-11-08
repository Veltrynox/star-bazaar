extends Node3D
## T157: ellipsoid packs (long axis along the orbit tangent, cluster_stretch) of asteroids on the trade map. One MultiMeshInstance3D per cluster = one draw call per pack.
## Per-instance position, rotation and scale come from a seed (hash of the cluster id + seed_salt), so a pack looks the same
## every time. The pack thins from the end of the list as ore is taken (visible_instance_count), so the surviving rocks stay put.
## Standard material, no shader, no collision: the map's click tests are maths on planets, so packs never block them.
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
@export var orbit_speed := 0.0            # T306: peak degrees per second of the pack along its orbit around the sun (balance asteroid_orbit_deg_per_s)
@export var orbit_arc := 0.0              # T306: half-width in degrees of the arc the pack swings through (balance asteroid_orbit_arc_deg)
var running := Callable()                 # T306: returns false while the game is paused; empty = always running
var _clock := 0.0                         # game-clock seconds of pack motion (not saved)

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
var _mat: StandardMaterial3D
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
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = rock_color
	_mat.albedo_texture = ROCK_TEXTURE
	_mat.roughness = rock_roughness

## clusters: dictionaries from main.clusters_in_system(sid) (id, system, x, y, radius, count, visible). Missing ones are removed.
func sync(clusters: Array) -> void:
	var seen := {}
	for c in clusters:
		var id := str(c["id"])
		seen[id] = true
		var n := maxi(1, int(c["count"]))
		# rebuilt too when the system centre moved (the sun is placed after the packs exist), since the tangent follows it
		if not packs.has(id) or int(packs[id]["max"]) != n or not (packs[id]["tangent"] as Vector3).is_equal_approx(tangent_of(c)):
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

func _build(id: String, c: Dictionary, n: int) -> void:
	if packs.has(id):
		packs[id]["mm"].queue_free()
	if _mesh == null:
		_ready()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
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
		p.y *= flatten
		p.x *= stretch  # x = along the tangent, z = across the radius; rocks keep their own shape
		var big := rng.randf() < big_share
		var s := rng.randf_range(big_min, big_max) if big else rng.randf_range(rock_min, rock_max)
		var sc := Vector3(1.0 + rng.randf_range(-squash, squash), 1.0 + rng.randf_range(-squash, squash), 1.0 + rng.randf_range(-squash, squash)) * s
		var basis := Basis.from_euler(Vector3(rng.randf() * TAU, rng.randf() * TAU, rng.randf() * TAU)) * Basis.from_scale(sc)
		var pos := (tdir * p.x + rad_dir * p.z + Vector3.UP * p.y) * r
		points.append(pos)
		mm.set_instance_transform(i, Transform3D(basis, pos))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = _mat
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mmi.position = Vector3(float(c["x"]), 0.0, float(c["y"])) * map_unit_scale
	add_child(mmi)
	var mrng := RandomNumberGenerator.new()
	mrng.seed = hash(id) ^ 104729
	var spin_mul := mrng.randf_range(0.5, 1.5) * (1.0 if mrng.randf() < 0.5 else -1.0)
	packs[id] = {"mm": mmi, "system": int(c["system"]), "max": n, "tangent": tdir, "points": points, "stretch": stretch,
		"anchor": mmi.position, "spin_mul": spin_mul, "phase": mrng.randf() * TAU}
	_place(id)

## T306: the visual pack swings along its orbit about the sun inside a small arc (sine, peak speed orbit_speed) and spins about
## its own centre. The logical anchor (cluster x, y) never moves, so picks, routes, platforms and labels stay valid.
func _place(id: String) -> void:
	var d: Dictionary = packs[id]
	var mm: MultiMeshInstance3D = d["mm"]
	var anchor: Vector3 = d["anchor"]
	var arc := deg_to_rad(orbit_arc)
	var ang := 0.0
	if arc > 0.0 and orbit_speed > 0.0:
		ang = arc * sin(deg_to_rad(orbit_speed) * _clock / arc + float(d["phase"]))
	var centre: Vector3 = sun_positions.get(int(d["system"]), Vector3.ZERO)
	# the anchor turns about the sun by ang; the rocks turn by ang too (long axis stays on the tangent) plus their own spin
	var rel := (anchor - centre).rotated(Vector3.UP, -ang)
	mm.position = centre + rel
	mm.rotation = Vector3(0.0, -ang + deg_to_rad(spin_speed) * float(d["spin_mul"]) * _clock, 0.0)

func _process(delta: float) -> void:
	if spin_speed == 0.0 and (orbit_speed == 0.0 or orbit_arc == 0.0):
		return
	if running.is_valid() and not bool(running.call()):
		return
	_clock += delta
	for id in packs:
		if packs[id]["mm"].visible:
			_place(id)
