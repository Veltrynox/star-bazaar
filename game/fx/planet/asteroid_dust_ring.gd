extends MultiMeshInstance3D
## Decorative asteroid dust: up to MAX_RINGS broken bands, all grains in ONE MultiMesh (one draw call), moved in the
## vertex shader (asteroid_dust_ring.gdshader). Position this node at the system's sun; the bands lie in its XZ plane.
## Visual only: no collision, no picking, no shadows, reads and writes no game state.

const SHADER := preload("res://game/fx/planet/asteroid_dust_ring.gdshader")
const MAX_RINGS := 7

@export var count := 8000           # grains in total; 2 triangles each = 16000 triangles
@export var slots: Array[Vector2] = [Vector2(3.5, 4.5)]  # radius ranges (inner, outer) clear of orbit lines; one ring per slot, max 7
@export var seed_salt := 1          # same seed = same rings and gaps every run
@export var tint := Color(0.75, 0.68, 0.6)
@export var alpha := 0.3
@export var orbit_speed := 0.002    # rad per second at ref_radius (a lap takes about 52 minutes; was 0.001, 105 min; 0.01, 10.5 min; first 0.05, 2 min)

## Result of _ready: one dictionary per ring {inner, outer, gaps: Array[Vector2](start angle, length)}.
var rings: Array = []

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7919 * seed_salt
	var n := mini(slots.size(), MAX_RINGS)
	var far := 1.0
	var weights: Array[float] = []
	var total := 0.0
	for i in n:
		# Each ring takes a random 25..90% of its slot, off-centre by a seeded amount, so widths differ from thin to wide.
		var s: Vector2 = slots[i]
		var w := (s.y - s.x) * rng.randf_range(0.25, 0.9)
		var lo := s.x + rng.randf() * ((s.y - s.x) - w)
		var gaps: Array[Vector2] = []
		var open := TAU
		for g in rng.randi_range(1, 3):  # 1..3 gaps, 0.4..1.6 rad long, anywhere on the circle
			var gl := rng.randf_range(0.4, 1.6)
			gaps.append(Vector2(rng.randf() * TAU, gl))
			open -= gl
		rings.append({"inner": lo, "outer": lo + w, "gaps": gaps})
		far = maxf(far, lo + w)
		var wt := w * (lo + w * 0.5) * maxf(open, 0.5) + 0.02  # area-ish share, so wide rings hold more grains
		weights.append(wt)
		total += wt
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter("tint", tint)
	mat.set_shader_parameter("alpha", alpha)
	mat.set_shader_parameter("orbit_speed", orbit_speed)
	quad.material = mat
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = quad
	mm.instance_count = count if n > 0 else 0
	var idx := 0
	for i in n:
		var r: Dictionary = rings[i]
		var share := int(round(count * weights[i] / total)) if i < n - 1 else count - idx
		var mid: float = 0.5 * (r["inner"] + r["outer"])
		for k in share:
			if idx >= count:
				break
			var ang := 0.0
			for t in 60:  # reject angles in a gap; thin the grains in the 0.3 rad next to a gap so the gap stays readable
				ang = rng.randf() * TAU
				var keep := 1.0
				for g in r["gaps"]:
					var d := fposmod(ang - g.x, TAU)
					if d < g.y:
						keep = 0.0
					else:
						keep = minf(keep, minf((d - g.y) / 0.3, (TAU - d) / 0.3))
				if rng.randf() < keep:
					break
			var u := (rng.randf() + rng.randf()) * 0.5  # bell-shaped: the ring thins toward both edges
			var rad: float = lerpf(r["inner"], r["outer"], u)
			mm.set_instance_transform(idx, Transform3D.IDENTITY)
			mm.set_instance_custom_data(idx, Color(rad, ang, rng.randf(), mid))
			idx += 1
	mm.visible_instance_count = idx
	multimesh = mm
	# The quads are moved in the shader, so the mesh's own box is wrong: give the whole ring box.
	var o := far + 0.2
	custom_aabb = AABB(Vector3(-o, -0.5, -o), Vector3(o, 1.0, o) * 2.0)
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
