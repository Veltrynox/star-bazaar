class_name JumpWarp
extends CanvasLayer
## Flagship jump distortion: one full-screen quad (jump_warp.gdshader) with a ripple, a flash and a streak, plus one
## PulseRing at the point. Driven from outside: begin() starts a beat, advance(delta) moves it on GAME time (the caller
## freezes it while paused), stop() hides it. Hidden (and the quad not drawn) while idle; nothing is allocated per frame.

const SHADER := preload("res://game/fx/jump_warp.gdshader")
const RING_SCENE := preload("res://game/fx/pulse_ring.tscn")

var _mat: ShaderMaterial
var _rect: ColorRect
var _ring: PulseRing
var _t := -1.0
var _dur := 0.8
var _center := Vector2(-1, -1)  # window pixels, read by the ring

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
	_ring = RING_SCENE.instantiate()
	_ring.pulses = 1
	_ring.follow = func() -> Vector2: return _center
	add_child(_ring)

func is_playing() -> bool:
	return _t >= 0.0

## screen_pos in window pixels; bearing is a screen direction; arrive = contracting beat. `p` carries the tuning:
## seconds, strength_px, flash, streak_px, ring_px.
func begin(screen_pos: Vector2, bearing: Vector2, arrive: bool, p: Dictionary) -> void:
	if _mat == null:
		_ready()
	var vs := get_viewport().get_visible_rect().size
	_center = screen_pos
	_dur = maxf(0.05, float(p.get("seconds", 0.8)))
	_t = 0.0
	var b := bearing.normalized() if bearing.length() > 0.001 else Vector2(0, -1)
	_mat.set_shader_parameter("center_uv", screen_pos / vs)
	_mat.set_shader_parameter("bearing", b)
	_mat.set_shader_parameter("direction", -1.0 if arrive else 1.0)
	_mat.set_shader_parameter("strength_px", float(p.get("strength_px", 28.0)))
	_mat.set_shader_parameter("flash", float(p.get("flash", 1.0)))
	_mat.set_shader_parameter("streak_px", float(p.get("streak_px", 420.0)))
	_mat.set_shader_parameter("progress", 0.0)
	_rect.visible = true
	_ring.radius_start = 6.0
	_ring.radius_end = float(p.get("ring_px", 140.0))
	_ring.seconds_per_pulse = _dur * 0.7
	_ring.alpha = 0.6
	_ring.line_width = 2.0
	_ring.color = Color(0.8, 0.93, 1.0)
	_ring.play()

## Moves the beat on; returns progress 0..1, or -1.0 when idle. Ends itself at 1.
func advance(delta: float) -> float:
	if _t < 0.0:
		return -1.0
	_t += delta
	var k := _t / _dur
	if k >= 1.0:
		stop()
		return 1.0
	_mat.set_shader_parameter("progress", k)
	return k

func stop() -> void:
	_t = -1.0
	if _rect != null:
		_rect.visible = false
	if _ring != null:
		_ring.stop()
