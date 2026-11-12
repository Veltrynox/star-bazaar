extends Control
## T126: short pop-up when expansion points are earned: "+1 skill point" and the reason, with a
## ring that opens and fades. Owner item 5. Never blocks clicks (mouse filter IGNORE) and fades by itself.
## Drawing only: no textures, no new art. Shown by main.gd through show_points().

const Juice := preload("res://game/juice.gd")
const HOLD_SECONDS := 5.0  # owner's hold time: unchanged (the pop-up was lengthened on purpose)
const FADE_SECONDS := 0.6
const CARD_PAD_X := 14  # compact card: smaller padding and fonts so it sits small under the system name
const CARD_PAD_Y := 6
const TITLE_FONT := 15
const REASON_FONT := 11
const COUNT_SECONDS := 0.5  # the points number counts up from 0
const IDLE_PULSE := 0.012  # gentle breathing scale while shown
const IDLE_PERIOD := 1.6
const SPARKS := 12
const RING_SECONDS := 0.9
var top_y := 108.0  # set by main.gd to just under the solar system name block (name and hint lines)

var _ring_t: float = 1.0  # 0 at the start of the splash, 1 when it has finished
var _card: PanelContainer
var _title: Label
var _reason: Label
var _tween: Tween
var _points := 0
var _title_text := ""
var _count := 1.0
var _t := 0.0
var _dismissing := false  # a click is fading it out now

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_card = PanelContainer.new()
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_card.position.y = top_y
	_card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(_card)
	var sb := StyleBoxFlat.new()  # compact panel; the default card padding made it read as a big button
	var base = _card.get_theme_stylebox("panel")
	if base is StyleBoxFlat:
		sb = base.duplicate()
	sb.content_margin_left = CARD_PAD_X
	sb.content_margin_right = CARD_PAD_X
	sb.content_margin_top = CARD_PAD_Y
	sb.content_margin_bottom = CARD_PAD_Y
	_card.add_theme_stylebox_override("panel", sb)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(box)
	_title = Label.new()
	_title.theme_type_variation = "LabelAccent"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title.add_theme_font_size_override("font_size", TITLE_FONT)
	box.add_child(_title)
	_reason = Label.new()
	_reason.theme_type_variation = "LabelSmall"
	_reason.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reason.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reason.add_theme_font_size_override("font_size", REASON_FONT)
	box.add_child(_reason)

## points: how many were earned; reason: one line of story text.
func show_points(points: int, reason: String, title: String) -> void:
	_card.position.y = top_y
	_points = points
	_title_text = title
	_title.text = title
	_reason.text = reason
	_t = 0.0
	_count = 0.0 if points > 1 and title.contains(str(points)) else 1.0
	_apply_count()
	_dismissing = false
	Juice.stop(self)  # a pop-up still leaving is settled first
	modulate.a = 1.0
	visible = true
	_ring_t = 0.0
	Juice.enter(_card, Juice.ENTER_SCALE, Juice.SLIDE_PX)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	if _count < 1.0 and Juice.motion > 0.0:
		var ct := create_tween()  # count-up runs beside the hold timer
		ct.tween_property(self, "_count", 1.0, COUNT_SECONDS * Juice.motion).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		ct.tween_callback(func(): Juice.pop(_title))
	else:
		_count = 1.0
		if Juice.motion > 0.0:
			Juice.pop(_title)
	_tween.tween_property(self, "_ring_t", 1.0, HOLD_SECONDS).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "modulate:a", 0.0, FADE_SECONDS)
	_tween.tween_callback(func(): visible = false)
	queue_redraw()

## Dismiss: any click or key fades it out (the input still reaches the game, so play is never blocked).
func _input(event: InputEvent) -> void:
	if visible and not _dismissing and _ring_t > 0.15 and ((event is InputEventMouseButton and event.pressed) or (event is InputEventKey and event.pressed and not event.echo)):
		_dismissing = true
		if _tween != null and _tween.is_valid():
			_tween.kill()
		Juice.leave(self)

func _apply_count() -> void:
	var shown := int(round(lerpf(0.0, float(_points), _count)))
	_title.text = _title_text if _count >= 1.0 else _title_text.replace(str(_points), str(shown))

func _process(delta: float) -> void:
	if visible:
		_t += delta
		if _count < 1.0:
			_apply_count()
		elif _title.text != _title_text:
			_title.text = _title_text
		if not _dismissing and _ring_t < 1.0 and Juice.motion > 0.0 and _t > 0.35:
			var s := 1.0 + IDLE_PULSE * Juice.motion * sin(_t * TAU / IDLE_PERIOD)
			_card.pivot_offset = _card.size * 0.5
			_card.scale = Vector2(s, s)
		queue_redraw()

func _draw() -> void:
	if not visible:
		return
	var centre := Vector2(size.x * 0.5, top_y + _card.size.y * 0.5)
	var col: Color = Ui.col("star_warm")
	# entrance shock ring with sparks, then a slow soft ring while it is held
	Juice.Rings.draw_shock(self, centre, 16.0, 220.0, clampf(_t / RING_SECONDS, 0.0, 1.0), col, 3.0, SPARKS)
	var glow := (1.0 - _ring_t) * (0.10 + 0.05 * sin(_t * TAU / IDLE_PERIOD))
	draw_rect(Rect2(_card.get_rect().position - Vector2(4, 4), _card.size + Vector2(8, 8)), Color(col, maxf(glow, 0.0)), false, 2.0)

## Bottom edge of the card while the pop-up is on screen, else 0: other top-middle cards (tutorial, tips) sit below it.
func bottom_y() -> float:
	return _card.get_global_rect().end.y if visible and not _dismissing else 0.0
