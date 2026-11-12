class_name ShipLook
extends RefCounted
## T356: the look of a ship = engine plume (shape + palette, data/exhaust.json) and a hue turn of the hull texture.
## A look is a Dictionary {shape, palette, hue} (plume code also reads optional glow, flicker, params, colors).
## Static helpers only; nothing here changes game state.

const EXHAUST_PATH := "res://data/exhaust.json"
const HUE_SHADER := preload("res://game/fx/ship_hue.gdshader")
const META_ORIG := "_look_orig"   # per MeshInstance3D: Array of the original surface override materials
const META_HUE := "_look_hue"

static var _exhaust := {}
static var _mats := {}            # "<material id>:<hue>" -> ShaderMaterial
static var _cull_off_shader: Shader

static func exhaust() -> Dictionary:
	if _exhaust.is_empty():
		var f := FileAccess.open(EXHAUST_PATH, FileAccess.READ)
		if f != null:
			var d = JSON.parse_string(f.get_as_text())
			if typeof(d) == TYPE_DICTIONARY:
				_exhaust = d
	return _exhaust

static func default_look() -> Dictionary:
	var d: Dictionary = exhaust().get("defaults", {})
	return {"shape": str(d.get("shape", "torch")), "palette": str(d.get("palette", "infrared")), "hue": 0.0}

static func rival_look() -> Dictionary:
	var l := default_look()
	l["palette"] = str(exhaust().get("rival_palette", "plasma"))
	return l

## Optional "look" {shape, palette, hue} row on a CEO in data/ceos.json (T357 adds it); missing keys fall back to default_look().
static func look_of_ceo(ceo_id: String) -> Dictionary:
	var l := default_look()
	var f := FileAccess.open("res://data/ceos.json", FileAccess.READ)
	if f == null:
		return l
	var d = JSON.parse_string(f.get_as_text())
	var rows = []
	if typeof(d) == TYPE_ARRAY:
		rows = d
	elif typeof(d) == TYPE_DICTIONARY:
		var inner = d.get("ceos", d)
		if typeof(inner) == TYPE_ARRAY:
			rows = inner
		elif typeof(inner) == TYPE_DICTIONARY:
			for k in inner:
				if typeof(inner[k]) == TYPE_DICTIONARY and not inner[k].has("id"):
					inner[k]["id"] = k
				rows.append(inner[k])
	for r in rows:
		if typeof(r) == TYPE_DICTIONARY and str(r.get("id", "")) == ceo_id and typeof(r.get("look")) == TYPE_DICTIONARY:
			var lk: Dictionary = r["look"]
			for key in lk:
				l[key] = lk[key]
			break
	return l

## Rotates the hue of the model's textures by `hue` (0..1 = one turn). 0 restores the original materials. Cheap to repeat:
## one ShaderMaterial per (source material, hue), cached. Only plain opaque BaseMaterial3D surfaces are replaced.
static func apply_hue(model: Node, hue: float) -> void:
	hue = fposmod(hue, 1.0)
	if model is MeshInstance3D:
		_apply_mesh(model, hue)
	for c in model.get_children():
		apply_hue(c, hue)

static func _apply_mesh(mi: MeshInstance3D, hue: float) -> void:
	if mi.mesh == null:
		return
	if not mi.has_meta(META_ORIG):
		var orig := []
		for i in mi.mesh.get_surface_count():
			orig.append(mi.get_surface_override_material(i))
		mi.set_meta(META_ORIG, orig)
	var orig: Array = mi.get_meta(META_ORIG)
	for i in mi.mesh.get_surface_count():
		if hue <= 0.0001:
			mi.set_surface_override_material(i, orig[i])
			continue
		var src: Material = orig[i] if orig[i] != null else mi.mesh.surface_get_material(i)
		if not (src is BaseMaterial3D) or (src as BaseMaterial3D).transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
			continue
		mi.set_surface_override_material(i, _hue_material(src as BaseMaterial3D, hue))
	mi.set_meta(META_HUE, hue)

static func hue_of(model: Node) -> float:
	if model is MeshInstance3D and model.has_meta(META_HUE):
		return float(model.get_meta(META_HUE))
	for c in model.get_children():
		var h := hue_of(c)
		if h > 0.0:
			return h
	return 0.0

static func _hue_material(src: BaseMaterial3D, hue: float) -> ShaderMaterial:
	var key := "%d:%d" % [src.get_instance_id(), int(round(hue * 1000.0))]
	if _mats.has(key) and is_instance_valid(_mats[key]):
		return _mats[key]
	var m := ShaderMaterial.new()
	m.shader = HUE_SHADER if src.cull_mode != BaseMaterial3D.CULL_DISABLED else _two_sided_shader()
	if src.albedo_texture != null:
		m.set_shader_parameter("albedo_tex", src.albedo_texture)
	m.set_shader_parameter("albedo_color", src.albedo_color)
	if src.normal_enabled and src.normal_texture != null:
		m.set_shader_parameter("use_normal", true)
		m.set_shader_parameter("normal_tex", src.normal_texture)
		m.set_shader_parameter("normal_scale", src.normal_scale)
	m.set_shader_parameter("roughness", src.roughness)
	m.set_shader_parameter("metallic", src.metallic)
	m.set_shader_parameter("hue", hue)
	m.set_shader_parameter("uv_scale", src.uv1_scale)
	m.set_shader_parameter("uv_offset", src.uv1_offset)
	_mats[key] = m
	return m

static func _two_sided_shader() -> Shader:
	if _cull_off_shader == null:
		_cull_off_shader = Shader.new()
		_cull_off_shader.code = HUE_SHADER.code.replace("render_mode cull_back;", "render_mode cull_disabled;")
	return _cull_off_shader
