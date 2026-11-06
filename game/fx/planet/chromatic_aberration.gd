extends CanvasLayer
## Chromatic aberration over the 3D map view: one full-screen quad with chromatic_aberration.gdshader.
## Added before the lens glare and the grain, so those draw on top of it; the UI layers are above all of them.

const SHADER := preload("res://game/fx/planet/chromatic_aberration.gdshader")

## Shift at the screen edge, as a share of the screen width (0.0009 = 0.09 percent).
@export_range(0.0, 0.01, 0.0001) var amount := 0.0009:
	set(v):
		amount = v
		if _mat:
			_mat.set_shader_parameter("amount", v)

var _mat: ShaderMaterial

func _ready() -> void:
	layer = -1
	_mat = ShaderMaterial.new()
	_mat.shader = SHADER
	_mat.set_shader_parameter("amount", amount)
	var rect := ColorRect.new()
	rect.material = _mat
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(rect)
