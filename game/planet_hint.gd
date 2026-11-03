extends MeshInstance3D
## T28: thin pulsing ring around a planet to show it can be clicked.
## An unshaded torus in the UI accent colour (theme token star_warm) around the planet's equator. No filled sphere.

const HINT_TOKEN := "star_warm"  # the UI accent colour, read from the project theme
const PULSE_SPEED := 3.0        # radians per second
const ALPHA_MIN := 0.55
const ALPHA_MAX := 1.0
const SCALE_MIN := 1.00
const SCALE_MAX := 1.08
const RING_FACTOR := 1.35       # ring radius relative to planet radius
const RING_WIDTH := 0.05        # ring thickness relative to planet radius

var mat: StandardMaterial3D
var t: float = 0.0

func setup(planet_radius: float) -> void:
	var ring := TorusMesh.new()
	var mid := planet_radius * RING_FACTOR
	var half := planet_radius * RING_WIDTH * 0.5
	ring.inner_radius = mid - half
	ring.outer_radius = mid + half
	ring.rings = 64
	ring.ring_segments = 6
	mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Ui.col(HINT_TOKEN)
	ring.material = mat
	mesh = ring
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _process(delta: float) -> void:
	t += delta * PULSE_SPEED
	var k := 0.5 + 0.5 * sin(t)
	var c := Ui.col(HINT_TOKEN)
	mat.albedo_color = Color(c, lerpf(ALPHA_MIN, ALPHA_MAX, k))
	scale = Vector3.ONE * lerpf(SCALE_MIN, SCALE_MAX, k)
