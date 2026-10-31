@tool
extends MeshInstance3D
## One sphere planet for the 3D map.
## Look and lighting are picked from planet_id (deterministic: the same id always gets the same look and lighting).
## Look: 40% streaks (glowing layer), 20% fresnel_only, 10% pale, 30% standard; city is 0% (kept in the code).
## Lighting is a separate setting: 70% key light plus rim light, 30% key light only. The Fresnel edge is on every planet.
## Set use_id = false to force variant and rim_light by hand.

const FX := preload("res://art/planet_fx/planet_fx.gd")

## Surface textures, one entry each (greyscale equirectangular). The first entry is the default.
## Index rule: texture_index_for_id(planet_id) = FNV hash of the id (seed 3) times the list size, so the same id always gets the same texture.
const SURFACE_TEXTURES := ["res://art/planet_fx/planet_surface_01.jpg"]
## Fine grain map for the city specks and the streak layer.
const FINE_TEXTURE := "res://art/planet_fx/planet_sphere_tone.png"

enum Variant { STANDARD, FRESNEL_ONLY, CITY, PALE, STREAKS }

## Share of planets per look (sums to 1.0 with the city share at 0).
const LOOK_STREAKS := 0.40
const LOOK_FRESNEL := 0.20
const LOOK_PALE := 0.10
const LOOK_CITY := 0.0
const KEY_ONLY_SHARE := 0.30

@export var planet_id: String = "":
	set(v):
		planet_id = v
		_apply()
## true: variant and rim_light come from planet_id. false: use the two exports below.
@export var use_id: bool = true:
	set(v):
		use_id = v
		_apply()
@export var variant: Variant = Variant.STANDARD:
	set(v):
		variant = v
		_apply()
@export var rim_light: bool = true:
	set(v):
		rim_light = v
		_apply()
@export var texture_index: int = 0:
	set(v):
		texture_index = v
		_apply()
@export var planet_type: String = "temperate":
	set(v):
		planet_type = v
		_apply()
## 0 common, 1 rarest. Top tier (0.9 and up) uses the violet palette.
@export_range(0.0, 1.0) var rarity: float = 0.0:
	set(v):
		rarity = v
		_apply()

@export_group("Key light")
@export var key_color: Color = Color("FFC36B"):
	set(v):
		key_color = v
		_apply()
@export_range(0.0, 3.0) var key_strength: float = 1.4:
	set(v):
		key_strength = v
		_apply()
@export_group("Rim light and Fresnel")
@export var rim_color: Color = Color("5EA8FF"):
	set(v):
		rim_color = v
		_apply()
@export_range(0.0, 3.0) var rim_strength: float = 1.2:
	set(v):
		rim_strength = v
		_apply()
@export_range(0.0, 3.0) var fresnel_strength: float = 0.68:
	set(v):
		fresnel_strength = v
		_apply()
@export_range(0.5, 8.0) var fresnel_power: float = 3.0:
	set(v):
		fresnel_power = v
		_apply()
@export_group("Directions (object space)")
@export var key_dir: Vector3 = Vector3(-0.5, 0.5, 0.7):
	set(v):
		key_dir = v
		_apply()
@export var rim_dir: Vector3 = Vector3(0.5, -0.3, -0.8):
	set(v):
		rim_dir = v
		_apply()
@export_group("Shadow, city and grain")
@export_range(0.0, 1.0) var shadow_darkness: float = 0.95:
	set(v):
		shadow_darkness = v
		_apply()
@export var city_color: Color = Color("FFD27A"):
	set(v):
		city_color = v
		_apply()
@export_range(0.0, 0.3) var grain_amount: float = 0.10:
	set(v):
		grain_amount = v
		_apply()
@export_group("Glow, atmosphere and streaks")
@export_range(0.0, 3.0) var glow_strength: float = 1.6:
	set(v):
		glow_strength = v
		_apply()
@export_range(0.0, 3.0) var atmosphere_density: float = 0.9:
	set(v):
		atmosphere_density = v
		_apply()
@export_range(0.0, 3.0) var streak_strength: float = 1.6:
	set(v):
		streak_strength = v
		_apply()

## FNV-1a style hash of the id with a seed: stable across runs and machines. Returns 0..1.
static func id_unit(id: String, seed_v: int) -> float:
	var h: int = 2166136261 ^ seed_v
	for b in id.to_utf8_buffer():
		h = ((h ^ b) * 16777619) & 0xFFFFFFFF
	return float(h % 10000) / 10000.0

## The look for an id: streaks 40%, fresnel_only 20%, pale 10%, standard 30%, city 0%.
static func look_for_id(id: String) -> Variant:
	var u := id_unit(id, 1)
	if u < LOOK_STREAKS:
		return Variant.STREAKS
	if u < LOOK_STREAKS + LOOK_FRESNEL:
		return Variant.FRESNEL_ONLY
	if u < LOOK_STREAKS + LOOK_FRESNEL + LOOK_PALE:
		return Variant.PALE
	if u < LOOK_STREAKS + LOOK_FRESNEL + LOOK_PALE + LOOK_CITY:
		return Variant.CITY
	return Variant.STANDARD

## Index into SURFACE_TEXTURES for an id. Its own seed (3), so it is independent of the look and rim picks.
static func texture_index_for_id(id: String) -> int:
	return int(id_unit(id, 3) * SURFACE_TEXTURES.size()) % SURFACE_TEXTURES.size()

## Rim light for an id: on for 70%, key light only for 30%.
static func rim_for_id(id: String) -> bool:
	return id_unit(id, 2) >= KEY_ONLY_SHARE

func _ready() -> void:
	if not Engine.is_editor_hint():
		for node in [self, get_node_or_null("Glow"), get_node_or_null("Atmosphere"), get_node_or_null("Streaks")]:
			var mi := node as MeshInstance3D
			if mi and mi.get_surface_override_material_count() > 0:
				mi.set_surface_override_material(0, mi.get_surface_override_material(0).duplicate())
	_apply()

func _apply() -> void:
	if not is_inside_tree():
		return
	var p: Dictionary = FX.PRESETS[FX.palette_name(planet_type, rarity)]
	var look: Variant = look_for_id(planet_id) if use_id else variant
	var rim_on: bool = rim_for_id(planet_id) if use_id else rim_light
	# Shader variant: streaks use the standard surface plus the streak shell.
	var shader_variant := 0
	match look:
		Variant.FRESNEL_ONLY: shader_variant = 1
		Variant.CITY: shader_variant = 2
		Variant.PALE: shader_variant = 3
	# Surface texture: from the list by id (or texture_index when use_id is false).
	var tex_i: int = texture_index_for_id(planet_id) if use_id else clampi(texture_index, 0, SURFACE_TEXTURES.size() - 1)
	var m := get_surface_override_material(0) as ShaderMaterial
	if m:
		m.set_shader_parameter("surface_tex", load(SURFACE_TEXTURES[tex_i]))
		m.set_shader_parameter("fine_tex", load(FINE_TEXTURE))
		m.set_shader_parameter("variant", shader_variant)
		m.set_shader_parameter("use_rim", rim_on)
		m.set_shader_parameter("deep_col", p.deep)
		m.set_shader_parameter("mid_col", p.mid)
		m.set_shader_parameter("pale_col", p.pale)
		m.set_shader_parameter("key_color", key_color)
		m.set_shader_parameter("key_strength", key_strength)
		m.set_shader_parameter("rim_color", rim_color)
		m.set_shader_parameter("rim_strength", rim_strength)
		m.set_shader_parameter("fres_strength", fresnel_strength)
		m.set_shader_parameter("fres_power", fresnel_power)
		m.set_shader_parameter("key_dir", key_dir)
		m.set_shader_parameter("rim_dir", rim_dir)
		m.set_shader_parameter("shadow_darkness", shadow_darkness)
		m.set_shader_parameter("city_col", city_color)
		m.set_shader_parameter("grain_amount", grain_amount)
	var glow := get_node_or_null("Glow") as MeshInstance3D
	var gm := glow.get_surface_override_material(0) as ShaderMaterial if glow else null
	if gm:
		gm.set_shader_parameter("glow_col", p.glow)
		gm.set_shader_parameter("strength", glow_strength)
		gm.set_shader_parameter("key_dir", key_dir)
	var atmo := get_node_or_null("Atmosphere") as MeshInstance3D
	var am := atmo.get_surface_override_material(0) as ShaderMaterial if atmo else null
	if am:
		am.set_shader_parameter("scatter_col", p.pale)
		am.set_shader_parameter("density", atmosphere_density)
		am.set_shader_parameter("fres_strength", fresnel_strength)
		am.set_shader_parameter("fres_power", fresnel_power)
		am.set_shader_parameter("key_dir", key_dir)
	var streaks := get_node_or_null("Streaks") as MeshInstance3D
	if streaks:
		streaks.visible = look == Variant.STREAKS
		var sm := streaks.get_surface_override_material(0) as ShaderMaterial
		if sm:
			sm.set_shader_parameter("streak_col", p.pale)
			sm.set_shader_parameter("strength", streak_strength)
			sm.set_shader_parameter("key_dir", key_dir)
