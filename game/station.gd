extends Node3D
## The GLB (Y up, about 1 unit wide, base colour texture) is centred on its bounding box and scaled so its outer
## radius is MAP_RADIUS world units. Size and pivot are measured at runtime, so a new model needs no constants.

const SPIN_DEG_PER_SEC := 6.0       # tune the spin here (degrees per second)
const MAP_RADIUS := 0.1541          # world units, outer radius on the map (0.1284 x 1.2, owner 2026-11-13; both models)
const BUILD_SECONDS := 1.5
const MODEL_PATH := "res://assets/space_station/space station 3d model-2.glb"
const BAZAAR_MODEL_PATH := "res://assets/star_bazaar/star_bazaar.glb"  # the Space Storage once it is the Star Bazaar
const ROUGHNESS_MAX := 0.75         # the GLB is roughness 0.9, which reads dull in the map light

var system_id := 1
var pivot: Node3D
var bazaar := false         # true: shows the Star Bazaar model instead of the space station
var _holder: Node3D = null

func _init() -> void:
	pivot = Node3D.new()
	add_child(pivot)

func _ready() -> void:
	_build_model()

## Swaps to the Star Bazaar model (or back). animate: the build-in plays again (founding); a loaded save passes false.
func set_bazaar(on: bool, animate: bool = true) -> void:
	if bazaar == on:
		return
	bazaar = on
	if _holder != null:
		pivot.remove_child(_holder)
		_holder.queue_free()
		_holder = null
	if is_inside_tree():
		_build_model()
		build_in(animate)

func _build_model() -> void:
	var path := BAZAAR_MODEL_PATH if bazaar else MODEL_PATH
	var model: Node3D = null
	var res = load(path) if ResourceLoader.exists(path) else null
	if res is PackedScene:
		model = res.instantiate()
	if model == null:
		model = Node3D.new()  # asset not imported yet: an empty pivot keeps the logic working
	_apply_vertex_colors(model)
	_tune_materials(model)
	var box := _bounds(model, Transform3D.IDENTITY)
	var holder := Node3D.new()  # carries the centring and scale; the spin pivot stays on the model's centre
	if box.size.length() > 0.0:
		var radius := maxf(box.size.x, box.size.z) * 0.5
		var k := MAP_RADIUS / maxf(radius, 0.000001)
		holder.scale = Vector3.ONE * k
		model.position = -box.get_center()
	holder.add_child(model)
	pivot.add_child(holder)
	_holder = holder

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

## Bounding box of all meshes under node, in the space of the node's parent.
func _bounds(node: Node, t: Transform3D) -> AABB:
	var box := AABB()
	var first := true
	var xf := t
	if node is Node3D:
		xf = t * node.transform
	if node is MeshInstance3D and node.mesh != null:
		box = xf * node.mesh.get_aabb()
		first = false
	for c in node.get_children():
		var cb := _bounds(c, xf)
		if cb.size == Vector3.ZERO:
			continue
		box = cb if first else box.merge(cb)
		first = false
	return box

## Some GLBs keep colours in the mesh vertices; show them only when a surface really has them (this one uses a texture).
func _apply_vertex_colors(node: Node) -> void:
	if node is MeshInstance3D and node.mesh != null:
		for i in node.mesh.get_surface_count():
			if not (node.mesh.surface_get_format(i) & Mesh.ARRAY_FORMAT_COLOR):
				continue
			var old = node.mesh.surface_get_material(i)
			var mat: StandardMaterial3D
			if old is StandardMaterial3D:
				mat = old.duplicate()
			else:
				mat = StandardMaterial3D.new()
			mat.vertex_color_use_as_albedo = true
			node.set_surface_override_material(i, mat)
	for c in node.get_children():
		_apply_vertex_colors(c)

func _tune_materials(node: Node) -> void:
	if node is MeshInstance3D and node.mesh != null:
		for i in node.mesh.get_surface_count():
			var m = node.get_surface_override_material(i)
			if m == null:
				m = node.mesh.surface_get_material(i)
			if m is StandardMaterial3D and m.roughness > ROUGHNESS_MAX:
				var d: StandardMaterial3D = m.duplicate()
				d.roughness = ROUGHNESS_MAX
				node.set_surface_override_material(i, d)
	for c in node.get_children():
		_tune_materials(c)
