extends Node3D
## Space station model for one system: slow spin around its vertical axis and a scale-in when built.
## The GLB is metres with Z up (about 1450 m radius); it is stood up and scaled down to MAP_RADIUS world units.

const SPIN_DEG_PER_SEC := 6.0       # tune the spin here (degrees per second)
const MAP_RADIUS := 0.0917          # world units, outer radius on the map
const MODEL_RADIUS_M := 1450.0
const BUILD_SECONDS := 1.5
const MODEL_PATH := "res://assets/space_station/star_bazaar_station.glb"

var system_id := 1
var pivot: Node3D

func _init() -> void:
	pivot = Node3D.new()
	add_child(pivot)

func _ready() -> void:
	var model: Node3D = null
	var res = load(MODEL_PATH) if ResourceLoader.exists(MODEL_PATH) else null
	if res is PackedScene:
		model = res.instantiate()
	if model == null:
		model = Node3D.new()  # asset not imported yet: an empty pivot keeps the logic working
	model.rotation_degrees.x = -90.0  # model Z up -> world Y up
	var k := MAP_RADIUS / MODEL_RADIUS_M
	model.scale = Vector3.ONE * k
	_apply_vertex_colors(model)
	pivot.add_child(model)

## Scale from 0 to full over BUILD_SECONDS.
func build_in(animate: bool = true) -> void:
	if not animate or not is_inside_tree():
		scale = Vector3.ONE
		return
	scale = Vector3.ONE * 0.001
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector3.ONE, BUILD_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	pivot.rotation.y += deg_to_rad(SPIN_DEG_PER_SEC) * delta

## The GLB keeps its colours in the mesh vertices; show them by giving every surface a material that uses them.
func _apply_vertex_colors(node: Node) -> void:
	if node is MeshInstance3D and node.mesh != null:
		for i in node.mesh.get_surface_count():
			var old = node.mesh.surface_get_material(i)
			var mat: StandardMaterial3D
			if old is StandardMaterial3D:
				mat = old.duplicate()
			else:
				mat = StandardMaterial3D.new()
			mat.albedo_color = Color(1, 1, 1)
			mat.vertex_color_use_as_albedo = true
			node.set_surface_override_material(i, mat)
	for c in node.get_children():
		_apply_vertex_colors(c)
