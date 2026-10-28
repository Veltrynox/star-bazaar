# Art tooling only. Renders the three prototypes. Run (needs a window):
# Godot --path . --script res://art/planets/render.gd --resolution 512x512
extends SceneTree
const TYPES := ["volcanic", "temperate", "barren"]
var i := 0
var frames := 0
var planet: MeshInstance3D
var times: Array = []
func _init() -> void:
	var root_n := Node3D.new(); root.add_child(root_n)
	root.size = Vector2i(512, 512)
	var env := Environment.new(); env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.025, 0.04)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.25, 0.27, 0.35); env.ambient_light_energy = 0.5
	var we := WorldEnvironment.new(); we.environment = env; root_n.add_child(we)
	var l := DirectionalLight3D.new(); l.rotation_degrees = Vector3(-30, -50, 0); l.light_energy = 1.5; root_n.add_child(l)
	var cam := Camera3D.new(); cam.position = Vector3(0, 0, 3.0); root_n.add_child(cam)
	planet = (load("res://art/planets/planet.tscn") as PackedScene).instantiate(); root_n.add_child(planet)
	planet.rotation_degrees = Vector3(15, 20, 0)
	planet.material_override = load("res://art/planets/planet_%s.tres" % TYPES[0])
func _process(delta: float) -> bool:
	frames += 1
	planet.rotation.y += 0.0
	if frames >= 6:
		times.append(delta * 1000.0)
	if frames == 12:
		root.get_texture().get_image().save_png("res://art/planets/renders/planet_%s.png" % TYPES[i])
		i += 1
		if i >= TYPES.size():
			var s := 0.0
			for t in times: s += t
			print("avg_frame_ms ", s / times.size()); quit(); return true
		planet.material_override = load("res://art/planets/planet_%s.tres" % TYPES[i])
		frames = 0
	return false
