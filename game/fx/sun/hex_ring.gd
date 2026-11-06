extends Node3D
## T110: a hexagon structure around the sun, shown during the asteroid event (owner idea 5).
## Line draw only: one ImmediateMesh, one draw call, unshaded, no texture, no shader file. Six hexagons form a honeycomb ring
## around a central hexagon that holds the sun, plus one large outline hexagon and six spokes. It lies on the orbit plane and
## turns slowly. Colour is above 1.0 so the engine glow path lights it. Visual only: no collision, no shadows, no text.
## Use: add as a child of the sun position, set radius, then call show_ring(true/false). Fades in and out.

const SIDE_PER_RADIUS := 1.6   # hexagon side in sun radii (the central hexagon clears the flares)
const OUTER_SCALE := 2.6       # large outline hexagon, in sides
const SPIN := 0.08             # radians per second
const FADE := 1.5              # fade speed per second
const HDR := 1.6               # colour multiplier, above 1.0 feeds the glow
const COLOR := Color(1.0, 0.72, 0.35)  # warm amber warning light (the default; `color` can be set per sun)
const ALPHA := 0.7

var radius := 0.75
var color := COLOR
var _on := false
var _fade := 0.0
var _mat: StandardMaterial3D
var _mi: MeshInstance3D

func _ready() -> void:
	_mat = StandardMaterial3D.new()
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.vertex_color_use_as_albedo = true
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_mat.no_depth_test = false
	_mat.albedo_color = Color(HDR, HDR, HDR, 0.0)
	_mi = MeshInstance3D.new()
	_mi.name = "HexRing"
	_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_mi)
	rebuild()
	visible = false

## Rebuilds the lines (call again after radius changes).
func rebuild() -> void:
	var s := radius * SIDE_PER_RADIUS
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINES, _mat)
	im.surface_set_color(color)
	_hexagon(im, Vector3.ZERO, s)
	for k in 6:
		var a := deg_to_rad(30.0 + 60.0 * float(k))  # neighbour centres of a honeycomb
		var c := Vector3(cos(a), 0.0, sin(a)) * s * sqrt(3.0)
		_hexagon(im, c, s)
		# Spoke from the central hexagon corner out to the large outline corner.
		var b := deg_to_rad(60.0 * float(k))
		var d := Vector3(cos(b), 0.0, sin(b))
		im.surface_add_vertex(d * s * 2.0)
		im.surface_add_vertex(d * s * OUTER_SCALE)
	_hexagon(im, Vector3.ZERO, s * OUTER_SCALE)
	im.surface_end()
	_mi.mesh = im

func _hexagon(im: ImmediateMesh, c: Vector3, s: float) -> void:
	for k in 6:
		var a0 := deg_to_rad(60.0 * float(k))
		var a1 := deg_to_rad(60.0 * float(k + 1))
		im.surface_add_vertex(c + Vector3(cos(a0), 0.0, sin(a0)) * s)
		im.surface_add_vertex(c + Vector3(cos(a1), 0.0, sin(a1)) * s)

func show_ring(on: bool) -> void:
	_on = on
	if on:
		visible = true

func _process(delta: float) -> void:
	_fade = move_toward(_fade, 1.0 if _on else 0.0, FADE * delta)
	_mat.albedo_color.a = _fade * ALPHA
	if _fade <= 0.0:
		visible = false
		return
	_mi.rotation.y += SPIN * delta
