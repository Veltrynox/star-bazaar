extends Control
## T126: short pop-up when expansion points are earned: "+1 skill point" and the reason, with a
## ring that opens and fades. Owner item 5. Never blocks clicks (mouse filter IGNORE) and fades by itself.
## Drawing only: no textures, no new art. Shown by main.gd through show_points().

const HOLD_SECONDS := 2.2
const FADE_SECONDS := 0.6

var _ring_t: float = 1.0  # 0 at the start of the splash, 1 when it has finished
var _card: PanelContainer
var _title: Label
var _reason: Label
var _tween: Tween

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_card = PanelContainer.new()
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_card.position.y = 72
	_card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(_card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(box)
	_title = Label.new()
	_title.theme_type_variation = "LabelAccent"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_title)
	_reason = Label.new()
	_reason.theme_type_variation = "LabelSmall"
	_reason.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reason.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_reason)

## points: how many were earned; reason: one line of story text.
func show_points(points: int, reason: String, title: String) -> void:
	_title.text = title
	_reason.text = reason
	modulate.a = 1.0
	visible = true
	_ring_t = 0.0
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "_ring_t", 1.0, HOLD_SECONDS).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "modulate:a", 0.0, FADE_SECONDS)
	_tween.tween_callback(func(): visible = false)
	queue_redraw()

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func _draw() -> void:
	if not visible:
		return
	# one ring that opens from the card and fades: a splash without new art
	var centre := Vector2(size.x * 0.5, 72.0 + 24.0)
	var radius := lerpf(20.0, 260.0, _ring_t)
	var col: Color = Ui.col("star_warm")
	col.a = (1.0 - _ring_t) * 0.8
	draw_arc(centre, radius, 0.0, TAU, 96, col, 3.0, true)
	col.a *= 0.4
	draw_arc(centre, radius * 0.6, 0.0, TAU, 72, col, 2.0, true)
