extends StyleBox
## A button background: the `base` stylebox, then a horizontal tint inside its border that fades from `color`
## (alpha `strength`) at the left edge to nothing at the right. Keeps the base's rounded corners and margins.
## Planet resource buttons use it while the Buy order is on (owner 2026-11-13).

var base: StyleBox
var color := Color.WHITE
var strength := 1.0

static func make(from: StyleBox, tint: Color, alpha: float) -> StyleBox:
	var s = load("res://game/gradient_stylebox.gd").new()
	s.base = from
	s.color = tint
	s.strength = alpha
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		s.set_content_margin(side, from.get_margin(side))
	return s

func _draw(ci: RID, rect: Rect2) -> void:
	if base != null:
		base.draw(ci, rect)
	var bw := 0.0
	var r := 0.0
	if base is StyleBoxFlat:
		var f := base as StyleBoxFlat
		bw = float(f.border_width_left)
		r = float(f.corner_radius_top_left)
	var inner := rect.grow(-bw)
	if inner.size.x <= 0.0 or inner.size.y <= 0.0:
		return
	r = clampf(r - bw, 0.0, minf(inner.size.x, inner.size.y) * 0.5)
	var pts := PackedVector2Array()
	var cols := PackedColorArray()
	var centres := [inner.position + Vector2(inner.size.x - r, r), inner.end - Vector2(r, r),
		inner.position + Vector2(r, inner.size.y - r), inner.position + Vector2(r, r)]
	var starts := [-PI * 0.5, 0.0, PI * 0.5, PI]  # top-right, bottom-right, bottom-left, top-left (clockwise)
	const SEG := 6
	for i in 4:
		for k in SEG + 1:
			var a: float = starts[i] + (PI * 0.5) * float(k) / SEG
			var p: Vector2 = centres[i] + Vector2(cos(a), sin(a)) * r
			pts.append(p)
			var t := clampf((p.x - inner.position.x) / inner.size.x, 0.0, 1.0)
			cols.append(Color(color, strength * (1.0 - t)))
	RenderingServer.canvas_item_add_polygon(ci, pts, cols)
