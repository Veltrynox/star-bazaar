extends CanvasLayer
## Film grain over the 3D map view: one full-screen quad with film_grain.gdshader, drawn above the 3D view and under the UI.
## The shader animates itself with TIME; this script only builds the quad and exposes strength.

const SHADER := preload("res://art/planet_fx/film_grain.gdshader")

@export_range(0.0, 0.5, 0.001) var strength := 0.016:
	set(v):
		strength = v
		if _mat:
			_mat.set_shader_parameter("strength", v)

var _mat: ShaderMaterial

func _ready() -> void:
	layer = -1                          # same layer as the lens glare (added after it, so on top); the UI layers are above
	_mat = ShaderMaterial.new()
	_mat.shader = SHADER
	_mat.set_shader_parameter("strength", strength)
	var rect := ColorRect.new()
	rect.material = _mat
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(rect)
