extends Control
## T133: green "+N" above a planet on the 3D map when it earned credits in a cycle. Rises and fades in
## about 1.8 s. Visual only: never takes clicks, nothing is shown when there is no income.

const Juice := preload("res://game/juice.gd")
const LIFE := 1.8
const RISE := 36.0  # pixels over the life

var map: Node3D
var items: Array = []  # {label, planet, age}

func setup(m: Node3D) -> void:
	map = m
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

## gains: planet index -> credits gained last cycle. Zero or negative entries are skipped.
func show_gains(gains: Dictionary) -> void:
	for p in gains:
		var n: int = int(gains[p])
		if n <= 0:
			continue
		var l := Label.new()
		l.text = "+%d" % n
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.add_theme_font_override("font", Ui.mono_font())
		l.add_theme_font_size_override("font_size", 20)
		var green: Color = Ui.col("signal_good")
		l.add_theme_color_override("font_color", green)
		var glow := green
		glow.a = 0.35  # soft glow: a wide, faint outline of the same green
		l.add_theme_color_override("font_outline_color", glow)
		l.add_theme_constant_override("outline_size", 8)
		l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
		l.add_theme_constant_override("shadow_offset_x", 0)
		l.add_theme_constant_override("shadow_offset_y", 1)
		add_child(l)
		Juice.count_from(l, 0, n, "+%d")  # the gain counts up from zero
		Juice.enter(l, 0.5, 0.0, false)  # and pops in: grows from half size, no fade (_process owns alpha)
		items.append({"label": l, "planet": int(p), "age": 0.0})
	set_process(not items.is_empty())

func _process(delta: float) -> void:
	if map == null or map.camera == null:
		return
	var keep: Array = []
	for it in items:
		it["age"] += delta
		var l: Label = it["label"]
		var t: float = it["age"] / LIFE
		if t >= 1.0:
			l.queue_free()
			continue
		keep.append(it)
		var pi: int = it["planet"]
		var world: Vector3 = map.positions[pi] + Vector3(0, map.planet_radius() * 1.3, 0)
		l.visible = map.visible and not map.camera.is_position_behind(world)
		var sp: Vector2 = map.camera.unproject_position(world)
		var ease_t := 1.0 - pow(1.0 - t, 2.0)
		l.position = sp - Vector2(l.size.x * 0.5, l.size.y) - Vector2(0, RISE * ease_t)
		l.modulate.a = 1.0 if t < 0.5 else 1.0 - (t - 0.5) * 2.0
	items = keep
	if items.is_empty():
		set_process(false)
