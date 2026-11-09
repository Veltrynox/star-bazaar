extends Node3D
## T277: the traffic layer of one system view. Many small 3D ships at almost no CPU cost; a readout of the books, never a simulation.
## Four groups (T303 adds ambient), one MultiMesh per group (T310: one triangle mesh for all kinds) = a hull draw call and a streak draw call each (4 MultiMeshes at most, 8 draw calls):
##   path  : ships along a quadratic Bezier lane (p0, pc, p2, count, state, cargo tint). Shader motion, like the lane dots.
##   orbit : ships circling a centre inside a radius band (count). Shader motion.
##   ambient: between-planets flow, same Bezier motion as path, dimmer and thinner (set_ambient_group).
##   free  : few ships flown on the CPU with ShipMotion.step (convoys, raiders); the free buffer is rewritten only while one moves.
## Instance buffers are rewritten only when a group is set or cleared (dirty flag, once per frame at most), never per frame.
## Per frame: three global shader uniforms (clock, fade, leg speed) and the zoom fade; zero per-ship nodes.
## Far zoom: fade goes to 0 and the MultiMeshes hide (the dot shader of the lane stays the far view).
## Numbers: data/balance.json traffic_* keys (placeholders), read live from the game's balance dictionary.
## Callers (later tasks): set_path_group / set_orbit_group / set_free_ship / clear_group; the map owns the layer and calls set_view_system.

const Meshes := preload("res://game/traffic/traffic_meshes.gd")
const Ships := preload("res://game/ships.gd")  # T252: ship_scale
const ShipMotion := preload("res://game/ship_motion.gd")
const SHIP_SHADER := preload("res://game/traffic/traffic_ship.gdshader")
const STREAK_SHADER := preload("res://game/traffic/traffic_streak.gdshader")
const PALETTE_N := 16        # shader palette size
const FLOATS := 16           # per instance: 12 transform + 4 custom
const MODE_PATH := 0
const MODE_ORBIT := 1
const MODE_FREE := 2
const MODE_AMBIENT := 3       # T303: path motion, own MultiMesh so its 1000 ships never use up the lane cap
const BIG := 100000.0        # custom AABB half extent: the instance transforms carry data, not positions
const MAX_SUBSTEPS := 8
const SIZE_JITTER := 0.05    # T307: visual constant (not a balance key): per-ship size factor 1 +- this (path and ambient ships)
const SPEED_JITTER := 0.10   # T307: visual constant: per-ship speed factor 1 +- this
const LAND_FADE := 0.12      # T309: visual constant: share of the lane over which a ship glides in to / out of its landing point
const LAND_DISC := 0.9       # T309: landing points lie within this fraction of the planet radius from its centre (on the visible disc)
const LAND_GAP := 0.6        # T309: lane end distance from the planet centre in radii; must match RouteLine.GAP (game/route_line.gd)
const LAND_QMAX := 255.0     # T309: radius packing: q = round(radius / LAND_RMAX * LAND_QMAX), three of them in one float
const LAND_RMAX := 8.0
const PIRATE_COL := Color(0.85, 0.22, 0.18)  # T310: raider colour (visual constant)
const LANE_SPREAD := 0.04    # T304: visual constant (not a balance key): per-ship sideways spread, fraction of lane length

static var _globals_ready := false

var map: Node                # the map (has zoom); set by map.gd
var view_system := 1
var _game: Node              # the game screen (has balance and _progress), found once
var _groups: Dictionary = {}  # key -> {slot: String, buf: PackedFloat32Array, count: int}
var _free: Dictionary = {}    # key -> {s: Dictionary, target: Vector2, y: float, kind: String, tint: Color, scale: float}
var _slots: Dictionary = {}   # "mode|mesh" -> {mmi: MultiMeshInstance3D, mats: Array[ShaderMaterial], count: int}
var _dirty: Dictionary = {}   # slot -> true
var _free_dirty := false
var _palette: Array[Color] = [Color(0.8, 0.8, 0.82)]
var _sun_dir := Vector3(0.5, 0.7, 0.3)
var _fade := 0.0
var generation := 0          # T278: bumped when every group is dropped, so callers re-register
var fade: float:             # 0 far (dots), 1 close (ships); the lane dots crossfade with it
	get:
		return _fade
var _applied: Array = []      # balance values last pushed to the materials
var _gl_clock := NAN
var _gl_fade := NAN
var _gl_leg := NAN

func _ready() -> void:
	_ensure_globals()

static func _ensure_globals() -> void:
	if _globals_ready:
		return
	_globals_ready = true
	for n in ["traffic_clock", "traffic_fade", "traffic_leg_speed"]:
		RenderingServer.global_shader_parameter_add(n, RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 0.0)

## ---- API ----

## Direction towards the light (world), shared with the map's key light.
func set_sun_dir(d: Vector3) -> void:
	_sun_dir = d.normalized()
	for s in _slots.values():
		(s["mats"][0] as ShaderMaterial).set_shader_parameter("sun_dir", _sun_dir)

## The viewed system changed: ships are drawn only in the viewed system, so every group is dropped (callers set the new ones).
func set_view_system(id: int) -> void:
	if id == view_system:
		return
	view_system = id
	clear_all()

## A lane: `count` ships spread evenly in time along p0 > p2 (bowed through pc), out loaded and back empty.
## state: 0 running, 1 stalled (parked at source, amber blink), 2 blocked (parked, red blink). cargo tints the pod.
## r0 / r1: radii of the planets at p0 / p2 (> 0 turns on the landing glide, T309; 0 keeps the ends as they were); gap_r: the radius
## the lane ends were offset from the centres by, when it is not each planet's own (route lines use the larger of the two).
func set_path_group(key: String, p0: Vector3, pc: Vector3, p2: Vector3, count: int, state: int = 0, cargo: Color = Color.TRANSPARENT, mesh: String = "corvette", scale_mult: float = 1.0, speed_mult: float = 1.0, r0: float = 0.0, r1: float = 0.0, gap_r: float = 0.0) -> void:
	var slot := _slot_for(MODE_PATH, mesh)
	var buf := PackedFloat32Array()
	var pal := float(_palette_index(cargo))
	var n := mini(maxi(count, 0), _cap())
	for i in n:
		_push(buf, p0, pc, p2, Vector3(scale_mult, speed_mult, _pack_radii(r0, r1, gap_r)), Vector4(float(i) / float(maxi(n, 1)), pal, float(state), _seed(key, i)))
	_set_group(key, slot, buf, n)

## Ships circling `centre` with radii between r_in and r_out (spread by seed), ring tilted by `tilt` radians about X.
## dir +1 or -1 sets the turning direction; speed comes from balance traffic_orbit_revs_per_cycle.
func set_orbit_group(key: String, centre: Vector3, r_in: float, r_out: float, count: int, mesh: String = "corvette", tilt: float = 0.0, dir: float = 1.0, cargo: Color = Color.TRANSPARENT, scale_mult: float = 1.0) -> void:
	var slot := _slot_for(MODE_ORBIT, mesh)
	var buf := PackedFloat32Array()
	var pal := float(_palette_index(cargo))
	var rev := signf(dir) * _b("traffic_orbit_revs_per_cycle")
	var n := mini(maxi(count, 0), _cap())
	for i in n:
		_push(buf, centre, Vector3(r_in, r_out, rev), Vector3(tilt, scale_mult, 0.0), Vector3.ZERO, Vector4(float(i) / float(maxi(n, 1)), pal, 0.0, _seed(key, i)))
	_set_group(key, slot, buf, n)

## T303: ambient lane between two planets: `count` ships spread over the loop (both directions), p0 > p2 bowed through pc.
## Size, speed and look come from balance traffic_ambient_*. Plain tint, always running.
func set_ambient_group(key: String, p0: Vector3, pc: Vector3, p2: Vector3, count: int, mesh: String = "corvette", r0: float = 0.0, r1: float = 0.0) -> void:
	var slot := _slot_for(MODE_AMBIENT, mesh)
	var buf := PackedFloat32Array()
	var n := mini(maxi(count, 0), _cap())
	for i in n:
		_push(buf, p0, pc, p2, Vector3(_b("traffic_ambient_scale"), _b("traffic_ambient_speed"), _pack_radii(r0, r1)), Vector4(float(i) / float(maxi(n, 1)), 0.0, 0.0, _seed(key, i)))
	_set_group(key, slot, buf, n)

## One free-flying ship (plane x/z, height y) that flies to `target` with ShipMotion.step. Call again to retarget (keeps its motion).
func set_free_ship(key: String, pos: Vector2, target: Vector2, kind: String = "pirate", tint: Color = Color.TRANSPARENT, y: float = 0.0, scale_mult: float = 1.0) -> void:
	var f = _free.get(key)
	if f == null:
		f = {"s": {"pos": pos, "yaw": ShipMotion.yaw_to(target - pos) if target != pos else 0.0, "speed": 0.0}}
		_free[key] = f
		_slot_for(MODE_FREE, kind)
	f["target"] = target
	f["y"] = y
	f["kind"] = kind
	f["tint"] = tint
	f["scale"] = scale_mult
	_free_dirty = true

func clear_group(key: String) -> void:
	if _groups.has(key):
		_dirty[_groups[key]["slot"]] = true
		_groups.erase(key)
	if _free.erase(key):
		_free_dirty = true

func clear_all() -> void:
	generation += 1
	for s in _groups.values():
		_dirty[s["slot"]] = true
	_groups.clear()
	_free.clear()
	_free_dirty = true

## Instances per group and the draw calls (two per visible MultiMesh: hull and streak).
func stats() -> Dictionary:
	var by := {"path": 0, "orbit": 0, "free": 0, "ambient": 0}
	var calls := 0
	for k in _slots:
		var s: Dictionary = _slots[k]
		var mode := int(str(k).get_slice("|", 0))
		by[["path", "orbit", "free", "ambient"][mode]] += int(s["count"])
		if (s["mmi"] as MultiMeshInstance3D).visible:
			calls += 2
	by["total"] = int(by["path"]) + int(by["orbit"]) + int(by["free"]) + int(by["ambient"])
	by["draw_calls"] = calls
	by["fade"] = _fade
	return by

func stats_text() -> String:
	var s := stats()
	return "Traffic: path %d, orbit %d, free %d, ambient %d (total %d), draw calls %d, fade %.2f" % [s["path"], s["orbit"], s["free"], s["ambient"], s["total"], s["draw_calls"], s["fade"]]

## ---- frame ----

func _process(delta: float) -> void:
	var g := _find_game()
	var zoom := float(map.zoom) if map != null and "zoom" in map else 1.0
	_apply_balance()
	var lo := _b("traffic_fade_zoom_none")
	var hi := _b("traffic_fade_zoom_full")
	_fade = smoothstep(lo, maxf(hi, lo + 0.0001), zoom)
	var clock := float(g._progress()) if g != null else 0.0
	var legs := float(g.trade.travel_cycles()) if g != null and "trade" in g and g.trade != null else 1.0
	_set_global("traffic_clock", clock, "_gl_clock")
	_set_global("traffic_fade", _fade, "_gl_fade")
	_set_global("traffic_leg_speed", 0.5 / maxf(legs, 0.01), "_gl_leg")
	if not _free.is_empty():
		var dt := delta
		if g != null and "paused" in g and bool(g.paused):
			dt = 0.0
		elif g != null and "time_speed" in g:
			dt *= float(g.time_speed)
		_step_free(dt)
	_flush()
	for s in _slots.values():
		(s["mmi"] as MultiMeshInstance3D).visible = _fade > 0.001 and int(s["count"]) > 0

func _set_global(name: String, v: float, cache: String) -> void:
	if is_equal_approx(float(get(cache)), v):
		return
	set(cache, v)
	RenderingServer.global_shader_parameter_set(name, v)

func _find_game() -> Node:
	if _game != null and is_instance_valid(_game):
		return _game
	var m: Node = self
	while m != null and not (m.has_method("_progress") and "balance" in m):
		m = m.get_parent()
	_game = m
	return m

func _b(key: String) -> float:
	var g := _find_game()
	return float(g.balance.get(key, 0.0)) if g != null else 0.0

func _cap() -> int:
	return int(_b("traffic_max_instances"))

## Pushes balance numbers into the materials when one of them changed (the debug menu edits balance live).
func _apply_balance() -> void:
	var now := [_b("traffic_ship_length") * _b("traffic_ship_scale") * Ships.ship_scale(), _b("traffic_streak_len"), _b("traffic_light_glow"), _b("traffic_blink_hz"), _b("traffic_ambient_bright"), _b("traffic_ambient_streak"), _b("traffic_hull_dark")]
	if now == _applied:
		return
	_applied = now
	for s in _slots.values():
		_push_params(s["mats"])

func _push_params(mats: Array) -> void:
	if _applied.is_empty():
		return
	for m in mats:
		m.set_shader_parameter("ship_len", _applied[0])
		m.set_shader_parameter("streak_len", _applied[1])
		m.set_shader_parameter("glow", _applied[2])
		m.set_shader_parameter("blink_hz", _applied[3])
		m.set_shader_parameter("amb_gain", _applied[4])
		m.set_shader_parameter("amb_streak", _applied[5])
		m.set_shader_parameter("hull_dark", _applied[6])

## ---- buffers ----

static func _push(buf: PackedFloat32Array, c0: Vector3, c1: Vector3, c2: Vector3, c3: Vector3, cu: Vector4) -> void:
	# MultiMesh 3D transform is 3 rows of (basis x, basis y, basis z, origin): the shader reads the columns as data.
	buf.append_array(PackedFloat32Array([c0.x, c1.x, c2.x, c3.x, c0.y, c1.y, c2.y, c3.y, c0.z, c1.z, c2.z, c3.z, cu.x, cu.y, cu.z, cu.w]))

## T309: planet radii r0 / r1 and the radius the lane ends were offset by (gap_r, 0 = each end's own) in one float (the matrix has
## no free column): q0 * 65536 + q1 * 256 + q2; 0 when a planet radius is missing.
static func _pack_radii(r0: float, r1: float, gap_r: float = 0.0) -> float:
	if r0 <= 0.0 or r1 <= 0.0:
		return 0.0
	var q0 := clampi(roundi(r0 / LAND_RMAX * LAND_QMAX), 1, int(LAND_QMAX))
	var q1 := clampi(roundi(r1 / LAND_RMAX * LAND_QMAX), 1, int(LAND_QMAX))
	var q2 := 0 if gap_r <= 0.0 else clampi(roundi(gap_r / LAND_RMAX * LAND_QMAX), 1, int(LAND_QMAX))
	return float(q0 * 65536 + q1 * 256 + q2)

static func _seed(key: String, i: int) -> float:
	return fposmod(float(hash(key) % 9973) * 0.0137 + float(i) * 0.61803398875, 1.0)

func _palette_index(c: Color) -> int:
	if c.a <= 0.0:
		return 0
	for i in _palette.size():
		if _palette[i].is_equal_approx(c):
			return i
	if _palette.size() >= PALETTE_N:
		return 0
	_palette.append(c)
	var pk := PackedColorArray(_palette)
	pk.resize(PALETTE_N)
	for s in _slots.values():
		for m in s["mats"]:
			m.set_shader_parameter("palette", pk)
	return _palette.size() - 1

func _set_group(key: String, slot: String, buf: PackedFloat32Array, n: int) -> void:
	if _groups.has(key) and _groups[key]["slot"] != slot:
		_dirty[_groups[key]["slot"]] = true
	_groups[key] = {"slot": slot, "buf": buf, "count": n}
	_dirty[slot] = true

func _slot_for(mode: int, mesh: String) -> String:
	var slot := "%d|ship" % mode  # T310: one triangle mesh for every kind, so one MultiMesh per mode
	if _slots.has(slot):
		return slot
	var am: ArrayMesh = Meshes.make()
	var mats: Array = []
	for si in 2:
		var m := ShaderMaterial.new()
		m.shader = SHIP_SHADER if si == 0 else STREAK_SHADER
		m.set_shader_parameter("mode", mode)
		m.set_shader_parameter("lane_spread", LANE_SPREAD)
		m.set_shader_parameter("land_fade", LAND_FADE)
		m.set_shader_parameter("land_disc", LAND_DISC)
		m.set_shader_parameter("land_gap", LAND_GAP)
		m.set_shader_parameter("size_jitter", SIZE_JITTER)
		m.set_shader_parameter("speed_jitter", SPEED_JITTER)
		m.set_shader_parameter("palette", _palette_packed())
		if si == 0:
			m.set_shader_parameter("sun_dir", _sun_dir)
			m.set_shader_parameter("col_warn", Ui.col("signal_warn"))
			m.set_shader_parameter("col_bad", Ui.col("signal_bad"))
		am.surface_set_material(si, m)
		mats.append(m)
	_push_params(mats)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = am
	mm.custom_aabb = AABB(Vector3(-BIG, -BIG, -BIG), Vector3(BIG, BIG, BIG) * 2.0)
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mmi.visible = false
	add_child(mmi)
	_slots[slot] = {"mmi": mmi, "mats": mats, "count": 0}
	return slot

func _palette_packed() -> PackedColorArray:
	var pk := PackedColorArray(_palette)
	pk.resize(PALETTE_N)
	return pk

## Rewrites the buffer of every slot that changed (once per frame, only when dirty).
func _flush() -> void:
	if _free_dirty:
		_free_dirty = false
		for k in _slots:
			if str(k).begins_with("%d|" % MODE_FREE):
				_dirty[k] = true
	if _dirty.is_empty():
		return
	for slot in _dirty:
		var buf := PackedFloat32Array()
		var total := 0
		var cap := _cap()
		for g in _groups.values():
			if g["slot"] == slot and total < cap:
				var take := mini(int(g["count"]), cap - total)
				buf.append_array((g["buf"] as PackedFloat32Array).slice(0, take * FLOATS))
				total += take
		if slot.begins_with("%d|" % MODE_FREE):
			for f in _free.values():
				if total < cap:
					var p: Vector2 = f["s"]["pos"]
					var fw := ShipMotion.forward(float(f["s"]["yaw"]))
					_push(buf, Vector3(fw.x, 0.0, fw.y), Vector3(f["scale"], 0.0, 0.0), Vector3.ZERO, Vector3(p.x, f["y"], p.y), Vector4(0.0, float(_palette_index(_free_tint(f))), 0.0, _seed(str(slot), total)))
					total += 1
		var s: Dictionary = _slots[slot]
		var mm: MultiMesh = (s["mmi"] as MultiMeshInstance3D).multimesh
		mm.instance_count = total  # reallocates: only on a change
		if total > 0:
			mm.buffer = buf
		s["count"] = total
	_dirty.clear()

## T310: raiders are dark red (the one mesh has no kind); others wear their own tint.
func _free_tint(f: Dictionary) -> Color:
	var t: Color = f["tint"]
	if t.a <= 0.0 and f["kind"] == "pirate":
		return PIRATE_COL
	return t

## Free ships: ShipMotion.step on the CPU for the few that fly. Marks the free buffer for rewrite only while something moves.
func _step_free(dt: float) -> void:
	if dt <= 0.0:
		return
	var vmax := _b("traffic_free_speed")
	var accel := _b("traffic_free_accel")
	var brake := _b("traffic_free_brake")
	var turn := _b("traffic_free_turn")
	var n := clampi(ceili(dt / ShipMotion.MAX_SUBSTEP), 1, MAX_SUBSTEPS)
	var h := dt / float(n)
	for f in _free.values():
		var s: Dictionary = f["s"]
		if float(s["speed"]) <= 0.0 and (f["target"] as Vector2).distance_to(s["pos"]) <= ShipMotion.ARRIVE_EPS:
			continue
		for _i in n:
			s = ShipMotion.step(s, f["target"], vmax, accel, brake, turn, h)
		f["s"] = s
		_free_dirty = true
