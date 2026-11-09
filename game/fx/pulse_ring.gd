class_name PulseRing
extends Panel
## T323: a very faint, thin circle that grows from radius_start to radius_end while it fades, repeated.
## Reusable: instance game/fx/pulse_ring.tscn, set the exported values, call play(); stop() hides it at once.
## One Panel, one StyleBoxFlat and one Tween per play; the per-frame step only sets size, position and alpha.
## `follow` returns the screen position of the centre (Vector2(-1, -1) = nothing to point at, ring hidden);
## `allowed` (optional) returns false to hide it for now (for example while a window covers the spot).

signal finished  # the last pulse ended (never in loop mode)

@export var pulses := 3  ## number of pulses; 0 = loop until stop()
@export var seconds_per_pulse := 0.9
@export var radius_start := 14.0
@export var radius_end := 54.0
@export var line_width := 1.0
@export_range(0.0, 1.0) var alpha := 0.35
@export var color := Color(1.0, 0.85, 0.5)
@export var free_when_done := false  ## queue_free() after the last pulse (finite mode)

var follow: Callable
var allowed: Callable
var _tween: Tween
var _style: StyleBoxFlat

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_style = StyleBoxFlat.new()
	_style.bg_color = Color(0, 0, 0, 0)
	_style.set_corner_radius_all(512)
	_style.anti_aliasing = true
	_style.anti_aliasing_size = 1.5
	add_theme_stylebox_override("panel", _style)

func is_playing() -> bool:
	return _tween != null and _tween.is_valid()

## Starts (or restarts) the pulse from the first frame.
func play() -> void:
	if _style == null:
		_ready()
	stop()
	_style.border_color = color
	_style.set_border_width_all(maxi(1, int(round(line_width))))
	var n := maxi(pulses, 0)
	_tween = create_tween()  # bound to this node: freed with it
	if n == 0:
		_tween.set_loops()
		_tween.tween_method(_step, 0.0, 1.0, seconds_per_pulse)
	else:
		_tween.tween_method(_step, 0.0, float(n), seconds_per_pulse * n)
		_tween.tween_callback(_done)

## Stops at once and hides; safe when not playing.
func stop() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null
	visible = false

func _done() -> void:
	_tween = null
	visible = false
	finished.emit()
	if free_when_done:
		queue_free()

func _step(t: float) -> void:
	var c := Vector2(-1, -1)
	if follow.is_valid():
		c = follow.call()
	var on: bool = c.x >= 0.0 and (not allowed.is_valid() or allowed.call())
	if on and pulses > 0 and t >= float(pulses):
		on = false
	visible = on
	if not on:
		return
	var k := fmod(t, 1.0)
	var r := lerpf(radius_start, radius_end, k)
	size = Vector2(r, r) * 2.0
	global_position = c - Vector2(r, r)
	modulate.a = alpha * (1.0 - k)
