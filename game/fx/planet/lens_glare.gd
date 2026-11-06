extends CanvasLayer
## Camera lens glare for the 3D map: one full-screen quad with lens_glare.gdshader, drawn above the 3D view and under the UI.
## Owner: set camera and source_pos (a Callable returning the bright source's world position, or null for none).
## Each frame it projects that position to the screen and sets 3 shader values; no allocation. Hidden when the source is behind the camera.

const SHADER := preload("res://game/fx/planet/lens_glare.gdshader")

var camera: Camera3D
var source_pos: Callable            # () -> Variant: Vector3 world position, or null when no source is shown
var source_color := Color(1.0, 0.75, 0.45)
var source_brightness: Callable     # () -> float 0..1, optional (for example the sun flare level); empty = 1.0

@export_range(0.0, 2.0, 0.05) var strength := 0.07:  # was 0.1 (muted 2026-11-02)
	set(v):
		strength = v
		_push("strength", v)
@export_range(0.05, 1.5, 0.05) var streak_len := 0.45:
	set(v):
		streak_len = v
		_push("streak_len", v)
@export_range(0, 6) var ghost_count := 5:
	set(v):
		ghost_count = v
		_push("ghost_count", v)
@export_range(0.0, 2.0, 0.05) var ghost_strength := 0.05:  # was 0.07 (muted 2026-11-02)
	set(v):
		ghost_strength = v
		_push("ghost_strength", v)

var _rect: ColorRect
var _mat: ShaderMaterial

func _ready() -> void:
	layer = -1
	_mat = ShaderMaterial.new()
	_mat.shader = SHADER
	_rect = ColorRect.new()
	_rect.material = _mat
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.visible = false
	add_child(_rect)
	for key in ["strength", "streak_len", "ghost_count", "ghost_strength"]:
		_mat.set_shader_parameter(key, get(key))

func _push(key: String, v: Variant) -> bool:
	if _mat:
		_mat.set_shader_parameter(key, v)
	return false

func _process(_delta: float) -> void:
	var on_screen := false
	if camera and source_pos.is_valid():
		var wp: Variant = source_pos.call()
		if wp is Vector3 and not camera.is_position_behind(wp):
			var size := get_viewport().get_visible_rect().size
			var uv := camera.unproject_position(wp) / size
			_mat.set_shader_parameter("src_uv", uv)
			_mat.set_shader_parameter("aspect", size.x / maxf(size.y, 1.0))
			_mat.set_shader_parameter("brightness", float(source_brightness.call()) if source_brightness.is_valid() else 1.0)
			_mat.set_shader_parameter("glare_col", source_color.lerp(Color.WHITE, 0.25))
			on_screen = uv.x > -0.6 and uv.x < 1.6 and uv.y > -0.6 and uv.y < 1.6
	_rect.visible = on_screen
