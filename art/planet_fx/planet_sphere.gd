@tool
extends MeshInstance3D
## One sphere planet for the 3D map.
## Look and lighting are picked from planet_id (deterministic: the same id always gets the same look and lighting).
## Look: 40% streaks (glowing layer), 20% fresnel_only, 10% pale, 30% standard; city is 0% (kept in the code).
## Lighting is a separate setting: 70% key light plus rim light, 30% key light only. The Fresnel edge is a soft sun-side crescent on every planet.
## Set use_id = false to force variant and rim_light by hand.

## Owner: stripped planet body (beauty map + Fresnel + rim only). false brings back clouds, streaks and ring (also set the full material in the tscn and show Glow). The Fresnel Atmosphere shell is visible in both modes.
const SIMPLE := true

## Owner: cloud layer in the simple body for the earth-like types, storm glow for the stormy type (cloudy). Both read planet_cloud.png.
const CLOUD_TYPES := ["lush", "agrarian", "ocean"]
const STORM_TYPE := "cloudy"
const CLOUD_TEX := "res://art/textures/planets/planet_cloud.png"

const FX := preload("res://art/planet_fx/planet_fx.gd")

## Per-type surface table: beauty (colour), disp (height, relief), optional glow mask and lights mask.
## Optional "clouds" key: a drifting cloud shell above the surface plus cloud shadows on the body. Add one line to give it to a type.
## Types not in the table fall back to the old greyscale SURFACE_TEXTURES entry with the palette tint.
const TP := "res://art/textures/planets/"
const TYPE_TEXTURES := {
	"volcanic": {"beauty": TP + "planet_volcanic_beauty.png", "disp": TP + "planet_volcanic_displacement_1.png"},
	"cloudy": {"beauty": TP + "planet_cloudy_beauty.png", "disp": TP + "planet_cloudy_displacement.png", "clouds": TP + "planet_cloud.png"},
	"desert": {"beauty": TP + "planet_desert_beauty.png", "disp": TP + "planet_desert_displacement.png"},
	"lush": {"beauty": TP + "planet_lush_beauty.png", "disp": TP + "planet_lush_displacement.png"},
	"agrarian": {"beauty": TP + "planet_agrarian_beauty.png", "disp": TP + "planet_agrarian_displacement.png"},
	"ocean": {"beauty": TP + "planet_ocean_beauty.png", "disp": TP + "planet_ocean_displacement.png"},
	"moon": {"beauty": TP + "planet_moon_beauty.png", "disp": TP + "planet_moon_displacement.png", "ring": TP + "asteroid_ring_1.png"},
	"urban": {"beauty": TP + "planet_with_lights_beauty.png", "disp": TP + "planet_with_lights_displacement.png", "lights": TP + "planet_lights_mask.png"},
}
## Old fallback (greyscale equirectangular) for types without a table entry.
const SURFACE_TEXTURES := ["res://art/planet_fx/planet_surface_01.jpg"]
## Loaded textures by path: each file is loaded once for all planets.
static var _tex_cache: Dictionary = {}

static func cached_tex(path: String) -> Texture2D:
	if not _tex_cache.has(path):
		_tex_cache[path] = load(path)
	return _tex_cache[path]

## Fine grain map for the city specks and the streak layer.
const FINE_TEXTURE := "res://art/planet_fx/planet_sphere_tone.png"

## Half-width of the ring quad in planet radii (the PNG ring spans 0.32 to 0.98 of it: about 1.2 to 3.7 radii).
const RING_HALF := 3.8

enum Variant { STANDARD, FRESNEL_ONLY, CITY, PALE, STREAKS }

## Share of planets per look (sums to 1.0 with the city share at 0).
const LOOK_STREAKS := 0.40
const LOOK_FRESNEL := 0.20
## Owner: the spinning streak shell shows only on this planet type (cloudy); hidden on every other type.
const STREAKS_TYPE := "cloudy"
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
## true: rim colour = hue of the planet colour rotated by rim_hue_offset (colour wheel). false: use rim_color.
@export var rim_auto: bool = true:
	set(v):
		rim_auto = v
		_apply()
## 0.5 complementary; 0.4167 or 0.5833 split-complementary (150 degrees either side).
@export_range(0.0, 1.0) var rim_hue_offset: float = 0.5:
	set(v):
		rim_hue_offset = v
		_apply()
@export var rim_color: Color = Color("FFA05E"):
	set(v):
		rim_color = v
		_apply()
@export_range(0.0, 3.0) var rim_strength: float = 0.0658125:
	set(v):
		rim_strength = v
		_apply()
@export_range(0.0, 3.0) var fresnel_strength: float = 0.2:
	set(v):
		fresnel_strength = v
		_apply()
## Where the crescent starts on the sun side (shader: fres_side). 0 = about half the limb, 0.6 = narrow sliver.
@export_range(-0.5, 0.9) var fresnel_side: float = 0.0:
	set(v):
		fresnel_side = v
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
@export_group("Displacement")
## How strongly the height map bends the light on the surface (shader: relief).
@export_range(0.0, 80.0) var relief: float = 0.6:
	set(v):
		relief = v
		_apply()
## Vertex displacement in planet radii, total range (shader: disp_amount). 0 = off (default); 0.015 = plus/minus 0.75 percent of the radius.
@export_range(0.0, 0.2) var disp_amount: float = 0.0:
	set(v):
		disp_amount = v
		_apply()
## How far height moves the terminator (shader: term_shift).
@export_range(0.0, 1.0) var term_shift: float = 0.45:
	set(v):
		term_shift = v
		_apply()
## Darkening of low ground (shader: relief_shade).
@export_range(0.0, 1.0) var relief_shade: float = 0.75:
	set(v):
		relief_shade = v
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
@export_group("Clouds (types with a clouds entry)")
## Drift in uv per second (0.003 is about one lap in 5.5 minutes). Negative drifts the other way.
@export_range(-0.05, 0.05, 0.0005) var cloud_speed: float = 0.003:
	set(v):
		cloud_speed = v
		_apply()
@export_range(0.0, 1.0) var cloud_alpha: float = 0.9:
	set(v):
		cloud_alpha = v
		_apply()
## Texture repeats around the planet (whole numbers keep the seam closed).
@export_range(1, 4) var cloud_scale: int = 1:
	set(v):
		cloud_scale = v
		_apply()
## Darkening of the surface under the clouds (key light only).
@export_range(0.0, 1.0) var cloud_shadow: float = 0.55:
	set(v):
		cloud_shadow = v
		_apply()
## Shadow slide towards the sun (cloud height, in sphere radii).
@export_range(0.0, 0.2) var cloud_shadow_offset: float = 0.04:
	set(v):
		cloud_shadow_offset = v
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

## Pole tilt away from the anti-sun axis, degrees. The pole (local Y) sits this far from the point opposite the sun.
const POLE_TILT_DEG := 25.0

## World-space unit vector from the pole axis: opposite the sun, tilted POLE_TILT_DEG towards a per-planet azimuth (from planet_id).
static func pole_dir(sun_w: Vector3, id: String) -> Vector3:
	var s := sun_w.normalized()
	var ref := Vector3.UP if absf(s.dot(Vector3.UP)) < 0.95 else Vector3.RIGHT
	var u := s.cross(ref).normalized()
	var w := s.cross(u)
	var a := id_unit(id, 5) * TAU
	var t := deg_to_rad(POLE_TILT_DEG)
	return (-s * cos(t) + (u * cos(a) + w * sin(a)) * sin(t)).normalized()

## Aims the sun at the sphere: turns the sphere so its pole lies in the shadow (dot(pole, sun) = -cos(tilt) < 0, far from the lit side),
## then sets key_dir in object space. Rotation only (scale is kept); the spin around the pole is unchanged.
func aim_sun(sun_w: Vector3) -> void:
	var s := sun_w.normalized()
	var y := pole_dir(s, planet_id)
	var x := y.cross(s).normalized()  # pole x sun: perpendicular to both, stable for a given sun and pole
	var z := x.cross(y)
	quaternion = Basis(x, y, z).get_rotation_quaternion()
	var local := Vector3(s.dot(x), s.dot(y), s.dot(z))
	if not local.is_equal_approx(key_dir):
		key_dir = local

func _ready() -> void:
	if not Engine.is_editor_hint():
		for node in [self, get_node_or_null("Glow"), get_node_or_null("Atmosphere"), get_node_or_null("Streaks"), get_node_or_null("Clouds")]:
			var mi := node as MeshInstance3D
			if mi and mi.get_surface_override_material_count() > 0:
				mi.set_surface_override_material(0, mi.get_surface_override_material(0).duplicate())
	_apply()

## Colour wheel rim: rotate the hue of the base colour by offset (0.5 = complement), keep it saturated and bright.
static func rim_complement(base: Color, offset: float) -> Color:
	return Color.from_hsv(fposmod(base.h + offset, 1.0), maxf(base.s, 0.55), maxf(base.v, 0.95))

func _apply() -> void:
	if not is_inside_tree():
		return
	var p: Dictionary = FX.PRESETS[FX.palette_name(planet_type, rarity)]
	var look: Variant = look_for_id(planet_id) if use_id else variant
	var rim_on := true  # rim light on every planet; it sits opposite the sun (shader uses -key_dir)
	var rim_col: Color = rim_complement(p.mid, rim_hue_offset) if rim_auto else rim_color
	# Shader variant: streaks use the standard surface plus the streak shell.
	var shader_variant := 0
	match look:
		Variant.FRESNEL_ONLY: shader_variant = 1
		Variant.CITY: shader_variant = 2
		Variant.PALE: shader_variant = 3
	# Surface texture: from the list by id (or texture_index when use_id is false).
	var tt: Dictionary = TYPE_TEXTURES.get(planet_type, {})
	var beauty: bool = not tt.is_empty()
	if beauty:
		shader_variant = 0  # beauty maps always show their surface (no fresnel-only or pale look)
	var tex_i: int = texture_index_for_id(planet_id) if use_id else clampi(texture_index, 0, SURFACE_TEXTURES.size() - 1)
	var m := get_surface_override_material(0) as ShaderMaterial
	if m:
		m.set_shader_parameter("use_beauty", beauty)
		m.set_shader_parameter("surface_tex", cached_tex(tt["beauty"] if beauty else SURFACE_TEXTURES[tex_i]))
		m.set_shader_parameter("fine_tex", cached_tex(FINE_TEXTURE))
		m.set_shader_parameter("use_disp", beauty and tt.has("disp"))
		var has_clouds: bool = beauty and tt.has("clouds")
		m.set_shader_parameter("use_cloud_shadow", has_clouds)
		if has_clouds:
			m.set_shader_parameter("cloud_tex", cached_tex(tt["clouds"]))
			m.set_shader_parameter("cloud_shadow", cloud_shadow)
			m.set_shader_parameter("cloud_shadow_offset", cloud_shadow_offset)
			m.set_shader_parameter("cloud_speed", cloud_speed)
			m.set_shader_parameter("cloud_scale", float(cloud_scale))
			m.set_shader_parameter("cloud_alpha", cloud_alpha)
		if SIMPLE:
			var cl: bool = beauty and planet_type in CLOUD_TYPES
			var st: bool = beauty and planet_type == STORM_TYPE
			m.set_shader_parameter("use_clouds", cl)
			m.set_shader_parameter("use_storm_glow", st)
			if cl or st:
				m.set_shader_parameter("cloud_tex", cached_tex(CLOUD_TEX))
				m.set_shader_parameter("cloud_speed", cloud_speed)
				m.set_shader_parameter("cloud_alpha", cloud_alpha)
				m.set_shader_parameter("storm_col", p.glow)
		m.set_shader_parameter("use_glow_mask", beauty and tt.has("glow"))
		m.set_shader_parameter("use_lights_mask", beauty and tt.has("lights"))
		if beauty and tt.has("disp"):
			m.set_shader_parameter("disp_tex", cached_tex(tt["disp"]))
		if beauty and tt.has("glow"):
			m.set_shader_parameter("glow_tex", cached_tex(tt["glow"]))
		if beauty and tt.has("lights"):
			m.set_shader_parameter("lights_tex", cached_tex(tt["lights"]))
		m.set_shader_parameter("glow_col", p.glow)
		m.set_shader_parameter("variant", shader_variant)
		m.set_shader_parameter("use_rim", rim_on)
		m.set_shader_parameter("deep_col", p.deep)
		m.set_shader_parameter("mid_col", p.mid)
		m.set_shader_parameter("pale_col", p.pale)
		m.set_shader_parameter("key_color", key_color)
		m.set_shader_parameter("key_strength", key_strength)
		m.set_shader_parameter("rim_color", rim_col)
		m.set_shader_parameter("rim_strength", rim_strength)
		m.set_shader_parameter("fres_strength", fresnel_strength)
		m.set_shader_parameter("fres_power", fresnel_power)
		m.set_shader_parameter("fres_side", fresnel_side)
		m.set_shader_parameter("key_dir", key_dir)
		m.set_shader_parameter("relief", relief)
		m.set_shader_parameter("relief_shade", relief_shade)
		m.set_shader_parameter("disp_amount", disp_amount)
		m.set_shader_parameter("term_shift", term_shift)
		m.set_shader_parameter("shadow_darkness", shadow_darkness)
		m.set_shader_parameter("city_col", city_color)
		m.set_shader_parameter("grain_amount", grain_amount)
	_apply_ring(tt)
	var glow := get_node_or_null("Glow") as MeshInstance3D
	var gm := glow.get_surface_override_material(0) as ShaderMaterial if glow else null
	if gm:
		gm.set_shader_parameter("glow_col", p.glow)
		gm.set_shader_parameter("strength", glow_strength)
		gm.set_shader_parameter("key_dir", key_dir)
		gm.set_shader_parameter("fres_side", fresnel_side)
	var atmo := get_node_or_null("Atmosphere") as MeshInstance3D
	var am := atmo.get_surface_override_material(0) as ShaderMaterial if atmo else null
	if am:
		am.set_shader_parameter("scatter_col", p.pale)
		am.set_shader_parameter("density", atmosphere_density)
		am.set_shader_parameter("fres_strength", fresnel_strength)
		am.set_shader_parameter("fres_power", fresnel_power)
		am.set_shader_parameter("fres_side", fresnel_side)
		am.set_shader_parameter("key_dir", key_dir)
	var clouds := get_node_or_null("Clouds") as MeshInstance3D
	if clouds:
		clouds.visible = beauty and tt.has("clouds") and not SIMPLE
		var cm := clouds.get_surface_override_material(0) as ShaderMaterial
		if cm and clouds.visible:
			cm.set_shader_parameter("cloud_tex", cached_tex(tt["clouds"]))
			cm.set_shader_parameter("key_dir", key_dir)
			cm.set_shader_parameter("key_color", key_color)
			cm.set_shader_parameter("speed", cloud_speed)
			cm.set_shader_parameter("alpha", cloud_alpha)
			cm.set_shader_parameter("cloud_scale", float(cloud_scale))
			cm.set_shader_parameter("fres_side", fresnel_side)
	var streaks := get_node_or_null("Streaks") as MeshInstance3D
	if streaks:
		# Streak shell: cloudy planets only (no glow mask on cloudy any more).
		streaks.visible = planet_type == STREAKS_TYPE and not SIMPLE
		var sm := streaks.get_surface_override_material(0) as ShaderMaterial
		if sm:
			sm.set_shader_parameter("streak_col", p.pale)
			sm.set_shader_parameter("strength", streak_strength)
			sm.set_shader_parameter("key_dir", key_dir)

## Ring for types with a "ring" entry (moon): one quad child, built once, shares the cached ring texture.
func _apply_ring(tt: Dictionary) -> void:
	var ring := get_node_or_null("Ring") as MeshInstance3D
	if SIMPLE or not tt.has("ring"):
		if ring:
			ring.visible = false
		return
	if ring == null:
		ring = MeshInstance3D.new()
		ring.name = "Ring"
		var quad := PlaneMesh.new()
		quad.size = Vector2.ONE * RING_HALF * 2.0
		ring.mesh = quad
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var rng := RandomNumberGenerator.new()
		rng.seed = hash(planet_id)
		ring.rotation_degrees = Vector3(rng.randf_range(12.0, 24.0), 0.0, rng.randf_range(-12.0, 12.0))
		var mat := ShaderMaterial.new()
		mat.shader = load("res://art/planet_fx/planet_sphere_ring.gdshader")
		ring.material_override = mat
		add_child(ring)
	ring.visible = true
	var rm := ring.material_override as ShaderMaterial
	rm.set_shader_parameter("ring_tex", cached_tex(tt["ring"]))
	rm.set_shader_parameter("key_dir", key_dir)
	rm.set_shader_parameter("key_color", key_color)
