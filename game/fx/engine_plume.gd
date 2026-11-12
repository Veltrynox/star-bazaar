class_name EnginePlume
extends Node3D
## T356: six-layer additive exhaust at each engine point of a ship model (port of buildExhaust in tools/engine_tuner.html).
## Add as a child of the GLB model node so the fit scale and the yaw pivot apply; everything here is in model-local units.
## set_engines([{pos: Vector3, size: float}]) (rows from Ships.engine_points) and set_look({shape, palette, glow?, flicker?, params?, colors?}).
## Meshes are built once per set_engines/set_look; _process only feeds the clock to six shared materials.

const SHADER := preload("res://game/fx/engine_plume.gdshader")
const MAX_ENGINES := 4            # 4 x 6 layers = 24 MeshInstance3D at most
const RADIAL_SEGMENTS := 40
const SEED_PER_LAYER := 1.7
const SEED_PER_ENGINE := 0.9

## returns game seconds (stops while paused). Empty = own counter, which also stops while `running` returns false.
var clock := Callable()
var running := Callable()
var _clock := 0.0

var _engines: Array = []
var _look: Dictionary = {}
var _layers: Array = []           # MeshInstance3D, layer-major per engine
var _mats: Array = []             # one ShaderMaterial per layer index, shared by all engines

func _ready() -> void:
	set_process(not _layers.is_empty())

func set_engines(points: Array) -> void:
	_engines = points.slice(0, MAX_ENGINES)
	_build()

func set_look(look: Dictionary) -> void:
	_look = look
	_build()

func layer_meshes() -> Array:
	return _layers

## Resolved numbers for the current look: {shape, offset, spread, length, len_step, radius, glow, flicker, layers, alpha_step, colors}.
func resolved() -> Dictionary:
	var ex := ShipLook.exhaust()
	var defs: Dictionary = ex.get("defaults", {})
	var shapes: Dictionary = ex.get("shapes", {})
	var pals: Dictionary = ex.get("palettes", {})
	var sid := str(_look.get("shape", defs.get("shape", "torch")))
	var pid := str(_look.get("palette", defs.get("palette", "infrared")))
	var r := {"shape": "cone", "offset": 0.06, "spread": 0.18, "length": 1.4, "len_step": 0.08, "radius": 0.16}
	var sh = shapes.get(sid, shapes.get("torch", {}))
	for k in sh:
		r[k] = sh[k]
	var ov = _look.get("params", {})
	if typeof(ov) == TYPE_DICTIONARY:
		for k in ov:
			r[k] = ov[k]
	r["glow"] = float(_look.get("glow", defs.get("glow", 1.2)))
	r["flicker"] = float(_look.get("flicker", defs.get("flicker", 0.35)))
	r["layers"] = int(defs.get("layers", 6))
	r["alpha_step"] = float(defs.get("alpha_step", 0.12))
	var cols := []
	var src = _look.get("colors", null)
	if typeof(src) != TYPE_ARRAY or src.size() < r["layers"]:
		src = pals.get(pid, pals.get("infrared", []))
	for c in src:
		cols.append(c if c is Color else Color(str(c)))
	while cols.size() < r["layers"]:
		cols.append(cols[cols.size() - 1] if not cols.is_empty() else Color.WHITE)
	r["colors"] = cols
	return r

func _clear() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_layers.clear()
	_mats.clear()

func _build() -> void:
	_clear()
	if _engines.is_empty():
		set_process(false)
		return
	var r := resolved()
	var n := int(r["layers"])
	for i in n:
		var m := ShaderMaterial.new()
		m.shader = SHADER
		m.set_shader_parameter("col", r["colors"][i])
		m.set_shader_parameter("glow", float(r["glow"]))
		m.set_shader_parameter("flicker_k", float(r["flicker"]))
		m.set_shader_parameter("layer_alpha", 1.0 - i * float(r["alpha_step"]))
		_mats.append(m)
	var cyl: bool = str(r["shape"]) == "cylinder"
	var e_i := 0
	for e in _engines:
		var plume := Node3D.new()  # local -Y (the cylinder axis) -> model +X (the tail), as in the tuner
		plume.position = e["pos"]
		plume.rotation.z = PI * 0.5
		plume.scale = Vector3.ONE * float(e["size"])
		add_child(plume)
		for i in n:
			var radius := float(r["radius"]) * (1.0 + i * float(r["spread"]))
			var length := maxf(0.02, float(r["length"]) * (1.0 + i * float(r["len_step"])))
			var cm := CylinderMesh.new()
			cm.top_radius = radius                       # top = nozzle
			cm.bottom_radius = radius if cyl else radius * 0.02
			cm.height = length
			cm.radial_segments = RADIAL_SEGMENTS
			cm.rings = 1
			cm.cap_top = false
			cm.cap_bottom = false
			var mi := MeshInstance3D.new()
			mi.mesh = cm
			mi.material_override = _mats[i]
			mi.position.y = -length * 0.5 - i * float(r["offset"])   # nozzle at the engine point, shifted along +X per layer
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.custom_aabb = AABB(Vector3(-radius, -length * 0.5, -radius), Vector3(radius * 2.0, length, radius * 2.0))
			mi.set_instance_shader_parameter("seed", i * SEED_PER_LAYER + e_i * SEED_PER_ENGINE)
			plume.add_child(mi)
			_layers.append(mi)
		e_i += 1
	set_process(true)

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	var t := _clock
	if clock.is_valid():
		t = float(clock.call())
	else:
		if running.is_valid() and not bool(running.call()):
			return
		_clock += delta
		t = _clock
	for m in _mats:
		(m as ShaderMaterial).set_shader_parameter("time", t)
