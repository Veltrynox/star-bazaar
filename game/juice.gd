extends RefCounted
## Shared game-feel vocabulary (juice). Visual only: nothing here changes game state or blocks input.
## Use it as: const Juice := preload("res://game/juice.gd")
##
## Every effect runs on a named channel of one node ("panel", "press", "count", "flash", "nudge"). Starting a new
## effect on a channel first settles the old one to its rest state, so any effect can be interrupted at any time and
## still ends clean. Effects that find the node outside the tree, or motion switched off, apply the final state at once.
##
## Tunables are the constants below. `motion` scales every duration and strength together: 1.0 as designed, 0.0 off.

# ---- tunables (the owner can dial these down) ----
static var motion: float = 1.0
const ENTER_SECONDS := 0.22      # pop-ups, notices and panels fade and grow in
const EXIT_SECONDS := 0.16       # ... and fade out
const ENTER_SCALE := 0.92        # an entering pop-up starts at this scale and grows to 1.0 (back-out ease)
const EXIT_SCALE := 0.97         # a leaving pop-up shrinks to this scale while it fades
const SLIDE_PX := 10.0           # a free-placed pop-up drops in from this far above its rest spot
const PRESS_SCALE := 0.94        # button squash while held
const PRESS_IN_SECONDS := 0.06
const PRESS_OUT_SECONDS := 0.16
const COUNT_SECONDS := 0.45      # a number counts from its shown value to the new one
const FLASH_SECONDS := 0.3       # a colour flash on a changed value or a new item
const NUDGE_PX := 3.0            # a screen nudge: horizontal shake amplitude
const NUDGE_SECONDS := 0.24
const PING_SECONDS := 0.9        # a ring opens from a planet and fades
const PING_RADIUS := 56.0
const POP_SCALE := 1.18          # a value pop: the label swells to this scale and settles back
const POP_SECONDS := 0.22

const NO_TINT := Color(1.0, 1.0, 1.0, 0.0)  # alpha 0 means count_to does not flash

const CH_PANEL := "panel"
const CH_PRESS := "press"
const CH_COUNT := "count"
const CH_FLASH := "flash"
const CH_NUDGE := "nudge"
const CH_POP := "pop"

const _META_TW := "juice_tw_"
const _META_RESET := "juice_reset_"
const _META_BASE := "juice_base"
const _META_OFF := "juice_off_"
const _META_SHOWN := "juice_shown"
const _META_TARGET := "juice_target"
const _META_PRESS := "juice_press_on"

## Pure helpers (no node needed; the headless tests call these).

## Shake offset at t in 0..1: two and a half swings that die away, never more than px, zero at both ends.
static func shake_offset(t: float, px: float) -> Vector2:
	var fade := 1.0 - clampf(t, 0.0, 1.0)
	return Vector2(sin(clampf(t, 0.0, 1.0) * TAU * 2.5) * px * fade, 0.0)

## The value a count shows at t in 0..1 (ease out cubic), rounded to a whole number.
static func count_value(from: int, to: int, t: float) -> int:
	var e := 1.0 - pow(1.0 - clampf(t, 0.0, 1.0), 3.0)
	return roundi(lerpf(float(from), float(to), e))

## Screen point of a planet on the 3D map, or null when it is not in view. `map` is the map node (camera, positions).
static func planet_screen(map, index: int) -> Variant:
	if map == null or not is_instance_valid(map) or map.camera == null:
		return null
	if index < 0 or index >= map.positions.size():
		return null
	var w: Vector3 = map.positions[index]
	if map.camera.is_position_behind(w):
		return null
	return map.camera.unproject_position(w)

## ---- channel plumbing ----

static func _active(n: Node) -> bool:
	return motion > 0.0 and n != null and n.is_inside_tree()

static func _seconds(s: float) -> float:
	return s * motion

## Snaps a channel to rest: kills its tween and runs the reset that the last effect stored.
static func settle(n: Node, channel: String) -> void:
	var key := _META_TW + channel
	if n.has_meta(key):
		var old = n.get_meta(key)
		if old is Tween and old.is_valid():
			old.kill()
		n.remove_meta(key)
	var rk := _META_RESET + channel
	if n.has_meta(rk):
		var r: Callable = n.get_meta(rk)
		if r.is_valid():
			r.call()

## Settles the channel, stores the reset for the next settle, and returns a fresh tween bound to the node.
static func _begin(n: Node, channel: String, reset: Callable) -> Tween:
	settle(n, channel)
	n.set_meta(_META_RESET + channel, reset)
	var tw: Tween = n.create_tween()
	n.set_meta(_META_TW + channel, tw)
	return tw

## The colour a node returns to after a tint. Stored once, as RGB at full alpha (fades use alpha separately).
static func _base(c: CanvasItem) -> Color:
	if not c.has_meta(_META_BASE):
		var m := c.modulate
		c.set_meta(_META_BASE, Color(m.r, m.g, m.b, 1.0))
	return c.get_meta(_META_BASE)

## Moves a node by a transient offset: only the offset this module added is taken away again, so layout moves
## made by the game in the meantime are kept.
static func _offset(c: Control, key: String, nxt: Vector2) -> void:
	var cur: Vector2 = c.get_meta(key, Vector2.ZERO)
	c.position += nxt - cur
	c.set_meta(key, nxt)

## Scale about the centre. The pivot is set every frame, so it stays right while the control is laid out.
static func _set_scale(c: Control, s: float) -> void:
	c.pivot_offset = c.size * 0.5
	c.scale = Vector2(s, s)

static func _panel_reset(c: Control, base: Color, fade: bool) -> Callable:
	return func() -> void:
		if not is_instance_valid(c):
			return
		_offset(c, _META_OFF + CH_PANEL, Vector2.ZERO)
		c.scale = Vector2.ONE
		if fade:
			c.modulate = base

## ---- pop-ups, notices and panels ----

## Entry: fade in, grow from scale_from to 1 (back-out), and drop in from slide_px above the rest spot.
## Pass slide_px 0 for children of containers (the layout owns their position). fade false leaves alpha alone.
static func enter(c: Control, scale_from: float = ENTER_SCALE, slide_px: float = 0.0, fade: bool = true) -> void:
	var base := _base(c)
	if not _active(c):
		settle(c, CH_PANEL)
		c.visible = true
		return
	var tw := _begin(c, CH_PANEL, _panel_reset(c, base, fade))
	c.visible = true
	var s0 := 1.0 - (1.0 - scale_from) * motion
	_set_scale(c, s0)
	if fade:
		c.modulate = Color(base.r, base.g, base.b, 0.0)
	tw.set_parallel(true)
	tw.tween_method(func(v: float) -> void: _set_scale(c, v), s0, 1.0, _seconds(ENTER_SECONDS)) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if fade:
		tw.tween_property(c, "modulate:a", 1.0, _seconds(ENTER_SECONDS * 0.8)) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if slide_px != 0.0:
		var from_y := -slide_px * motion
		_offset(c, _META_OFF + CH_PANEL, Vector2(0.0, from_y))
		tw.tween_method(func(v: float) -> void: _offset(c, _META_OFF + CH_PANEL, Vector2(0.0, v)), from_y, 0.0,
			_seconds(ENTER_SECONDS)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## Exit: shrink to EXIT_SCALE and fade out, then hide (or free when then_free). on_done runs at the end
## unless the exit is interrupted by a new entry. Input is never blocked: a leaving control keeps its own
## mouse filter, so callers set MOUSE_FILTER_IGNORE on it first when it must not catch clicks.
static func leave(c: Control, then_free: bool = false, on_done: Callable = Callable()) -> void:
	var base := _base(c)
	if not _active(c):
		settle(c, CH_PANEL)
		_finish_leave(c, then_free, on_done)
		return
	var tw := _begin(c, CH_PANEL, _panel_reset(c, base, true))
	tw.set_parallel(true)
	var s1 := 1.0 - (1.0 - EXIT_SCALE) * motion
	tw.tween_method(func(v: float) -> void: _set_scale(c, v), 1.0, s1, _seconds(EXIT_SECONDS)) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(c, "modulate:a", 0.0, _seconds(EXIT_SECONDS)) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(func() -> void: _finish_leave(c, then_free, on_done))

static func _finish_leave(c: Control, then_free: bool, on_done: Callable) -> void:
	if then_free:
		c.queue_free()
	else:
		c.visible = false
	if on_done.is_valid():
		on_done.call()

## Settles a pop-up that is being replaced or stopped, without animating it (the caller sets its final state).
static func stop(c: Control) -> void:
	settle(c, CH_PANEL)

## ---- buttons ----

## Installs the press squash on every button in the tree, now and later (same pattern as Ui.install_cursors).
static func install_press(tree: SceneTree) -> void:
	if tree == null or tree.root.has_meta("juice_press"):
		return
	tree.root.set_meta("juice_press", true)
	tree.node_added.connect(_press_for)
	_press_walk(tree.root)

static func _press_walk(n: Node) -> void:
	_press_for(n)
	for ch in n.get_children():
		_press_walk(ch)

static func _press_for(n: Node) -> void:
	if n is BaseButton and not n.has_meta(_META_PRESS):
		n.set_meta(_META_PRESS, true)
		var b: BaseButton = n
		b.button_down.connect(func() -> void: press(b, true))
		b.button_up.connect(func() -> void: press(b, false))
		b.mouse_exited.connect(func() -> void: press(b, false))

## Squash on press, spring back on release. Interrupting it keeps the current scale, so it never jumps.
static func press(b: BaseButton, down: bool) -> void:
	if not _active(b):
		return
	var c := b as Control
	if c == null:
		return
	var tw := _begin(c, CH_PRESS, Callable())
	var target := (1.0 - (1.0 - PRESS_SCALE) * motion) if down else 1.0
	var secs := _seconds(PRESS_IN_SECONDS if down else PRESS_OUT_SECONDS)
	tw.tween_method(func(v: float) -> void: _set_scale(c, v), c.scale.x, target, secs) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

## ---- numbers ----

## Shows `value` in the label, formatted with fmt ("%d", "+%d", "%+d"). A change counts from the shown number to the
## new one. The first value shows at once. Safe to call every frame: the same value does nothing.
## up_tint flashes the label that colour when the number goes up (pass NO_TINT for none).
static func count_to(label: Label, value: int, fmt: String = "%d", up_tint: Color = NO_TINT) -> void:
	if not label.has_meta(_META_TARGET):
		count_from(label, value, value, fmt)
		return
	if int(label.get_meta(_META_TARGET)) == value:
		return
	var from := int(label.get_meta(_META_SHOWN, value))
	count_from(label, from, value, fmt, up_tint)

## Counts from `from` to `to`, and shows the label's text as it goes.
static func count_from(label: Label, from: int, to: int, fmt: String = "%d", up_tint: Color = NO_TINT) -> void:
	label.set_meta(_META_TARGET, to)
	if not _active(label) or from == to:
		label.set_meta(_META_SHOWN, to)
		label.text = fmt % to
		return
	var base := _base(label)
	var tw := _begin(label, CH_COUNT, func() -> void: label.modulate = base)
	tw.tween_method(func(v: float) -> void: _show_count(label, v, fmt), float(from), float(to), _seconds(COUNT_SECONDS)) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if to > from and up_tint.a > 0.0:
		label.modulate = up_tint
		tw.parallel().tween_property(label, "modulate", base, _seconds(FLASH_SECONDS)) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

static func _show_count(label: Label, v: float, fmt: String) -> void:
	var n := roundi(v)
	label.set_meta(_META_SHOWN, n)
	label.text = fmt % n

## ---- flashes, nudges and rings ----

## Colour flash: the node jumps to tint and settles back to its own colour. Used for a value that changed.
static func flash(c: CanvasItem, tint: Color, seconds: float = FLASH_SECONDS) -> void:
	var base := _base(c)
	if not _active(c):
		return
	var tw := _begin(c, CH_FLASH, func() -> void: c.modulate = base)
	c.modulate = tint
	tw.tween_property(c, "modulate", base, _seconds(seconds)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

## Value pop: a label or icon swells about its centre and settles back (out then back-out). Marks a number that
## just changed in a way the player earned or spent. Rests at scale 1.
static func pop(c: Control, strength: float = POP_SCALE) -> void:
	if not _active(c):
		return
	var tw := _begin(c, CH_POP, func() -> void: c.scale = Vector2.ONE)
	var peak := 1.0 + (strength - 1.0) * motion
	var up := _seconds(POP_SECONDS * 0.35)
	tw.tween_method(func(v: float) -> void: _set_scale(c, v), 1.0, peak, up) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_method(func(v: float) -> void: _set_scale(c, v), peak, 1.0, _seconds(POP_SECONDS * 0.65)) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## Small screen nudge: a few quick sideways shakes that die away and leave the control where it was.
static func nudge(c: Control, px: float = NUDGE_PX) -> void:
	var key := _META_OFF + CH_NUDGE
	if not _active(c):
		return
	var tw := _begin(c, CH_NUDGE, func() -> void: _offset(c, key, Vector2.ZERO))
	var amp := px * motion
	tw.tween_method(func(t: float) -> void: _offset(c, key, shake_offset(t, amp)), 0.0, 1.0, _seconds(NUDGE_SECONDS)) \
		.set_trans(Tween.TRANS_LINEAR)

## A ring opens from a screen point on `host` and fades, then frees itself. Visual only; never takes clicks.
static func ping(host: Control, at: Vector2, tint: Color) -> void:
	if not _active(host):
		return
	var ring := Ring.new()
	ring.tint = tint
	ring.position = at
	host.add_child(ring)
	var tw := ring.create_tween()
	tw.tween_method(func(t: float) -> void: ring.set_t(t), 0.0, 1.0, _seconds(PING_SECONDS)) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_callback(ring.queue_free)

class Ring extends Control:
	var t := 0.0
	var tint := Color.WHITE

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func set_t(v: float) -> void:
		t = v
		queue_redraw()

	func _draw() -> void:
		var col := tint
		col.a = (1.0 - t) * 0.85
		draw_arc(Vector2.ZERO, lerpf(6.0, PING_RADIUS, t), 0.0, TAU, 64, col, 2.5, true)
