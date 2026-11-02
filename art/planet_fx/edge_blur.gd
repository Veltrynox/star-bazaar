extends CanvasLayer
## Screen-space soft edge for the planets: one full-screen quad with edge_blur.gdshader that blurs the 3D view only in a ring
## just outside each planet's disc (the disc stays sharp). Added after the chromatic aberration and before the glare and grain.
## Owner: set camera and spheres (the map's planet_spheres) and radius_scale (body radius = mesh radius 0.5 x sphere scale).
## Each frame it projects every shown sphere to the screen into a fixed uniform array; the array is preallocated and reused (no
## per-frame new arrays; Godot copies the 16 vec4 on write). Up to MAX_DISCS planets (the extra ones are not blurred).

const SHADER := preload("res://art/planet_fx/edge_blur.gdshader")
const MAX_DISCS := 16

var camera: Camera3D
var spheres: Array[MeshInstance3D]
var radius_scale := 0.5   # body radius = sphere scale x this (SphereMesh radius 0.5)

@export_range(0.0, 40.0, 0.5) var ring_px := 10.0:   ## ring width outside the disc
	set(v):
		ring_px = v
		if _mat:
			_mat.set_shader_parameter("ring_px", v)
@export_range(0.0, 40.0, 0.5) var blur_px := 10.0:   ## blur radius
	set(v):
		blur_px = v
		if _mat:
			_mat.set_shader_parameter("blur_px", v)

var _mat: ShaderMaterial
var _rect: ColorRect
var _discs := PackedVector4Array()

func _ready() -> void:
	layer = -1
	_discs.resize(MAX_DISCS)
	_mat = ShaderMaterial.new()
	_mat.shader = SHADER
	_mat.set_shader_parameter("ring_px", ring_px)
	_mat.set_shader_parameter("blur_px", blur_px)
	_mat.set_shader_parameter("discs", _discs)
	_rect = ColorRect.new()
	_rect.material = _mat
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.visible = false
	add_child(_rect)

func _process(_delta: float) -> void:
	var n := 0
	if camera and camera.is_inside_tree():
		var size := get_viewport().get_visible_rect().size
		var right := camera.global_transform.basis.x
		for sp in spheres:
			if n >= MAX_DISCS:
				break
			if not is_instance_valid(sp) or not sp.is_visible_in_tree():
				continue
			var wp := sp.global_position
			if camera.is_position_behind(wp):
				continue
			var r := sp.scale.x * radius_scale
			var c := camera.unproject_position(wp)
			var rpx := c.distance_to(camera.unproject_position(wp + right * r))  # world radius to screen pixels
			var reach := rpx + ring_px
			if c.x < -reach or c.x > size.x + reach or c.y < -reach or c.y > size.y + reach:
				continue
			_discs[n] = Vector4(c.x, c.y, rpx, 1.0)
			n += 1
		_mat.set_shader_parameter("vp_size", size)
	_mat.set_shader_parameter("discs", _discs)
	_mat.set_shader_parameter("disc_count", n)
	_rect.visible = n > 0
