extends MeshInstance3D
## T28: soft pulsing halo around a planet to show it can be clicked.
## Translucent unshaded sphere slightly larger than the planet; alpha and scale pulse.

const HINT_COLOR := Color(1.0, 0.85, 0.35)  # warm gold
const PULSE_SPEED := 3.0        # radians per second
const ALPHA_MIN := 0.10
const ALPHA_MAX := 0.40
const SCALE_MIN := 1.00
const SCALE_MAX := 1.12
const HALO_FACTOR := 1.3        # halo radius relative to planet radius

var mat: StandardMaterial3D
var t: float = 0.0

func setup(planet_radius: float) -> void:
	var sphere := SphereMesh.new()
	sphere.radius = planet_radius * HALO_FACTOR
	sphere.height = sphere.radius * 2.0
	sphere.radial_segments = 32
	sphere.rings = 16
	mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = HINT_COLOR
	sphere.material = mat
	mesh = sphere
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _process(delta: float) -> void:
	t += delta * PULSE_SPEED
	var k := 0.5 + 0.5 * sin(t)
	mat.albedo_color = Color(HINT_COLOR, lerpf(ALPHA_MIN, ALPHA_MAX, k))
	scale = Vector3.ONE * lerpf(SCALE_MIN, SCALE_MAX, k)
