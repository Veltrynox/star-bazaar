## Banner that fills the card width, crops top and bottom (aspect kept), and fades into the card colour at its foot. Shared by event_notice.gd and bazaar_panel.gd (wing popup).
extends Control

const MAX_H := 190.0  # keeps buttons on screen at phone width; the crop takes the rest
const MIN_H := 64.0   # 3:1 at phone width is about 100px; the minimum must stay below that
const FADE := 0.6     # share of the height the gradient covers
var texture: Texture2D
var r_tl := 0.0
var r_tr := 0.0
var bg := Color.BLACK  # the card's own background colour, handed in so any theme blends

func _init() -> void:
	custom_minimum_size = Vector2(0, MIN_H)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resized.connect(_fit)

func _fit() -> void:
	var ratio := 3.0
	if texture != null and texture.get_height() > 0:
		ratio = float(texture.get_width()) / float(texture.get_height())
	var h := clampf(size.x / ratio, MIN_H, MAX_H)
	if absf(custom_minimum_size.y - h) > 0.5:
		custom_minimum_size.y = h

func _bg() -> Color:
	var c := bg
	c.a = 1.0
	return c

func _draw() -> void:
	if texture == null or size.x <= 0.0 or size.y <= 0.0:
		return
	var ts := texture.get_size()
	var k := maxf(size.x / ts.x, size.y / ts.y)
	var src_size := size / k
	var src := Rect2((ts - src_size) * 0.5, src_size)
	var pts := PackedVector2Array()  # top corners rounded, bottom square (the fade meets the text area)
	var rl := minf(r_tl, minf(size.x, size.y) * 0.5)
	var rr := minf(r_tr, minf(size.x, size.y) * 0.5)
	for i in range(0, 9):
		var a := PI + (PI * 0.5) * float(i) / 8.0
		pts.append(Vector2(rl, rl) + Vector2(cos(a), sin(a)) * rl)
	for i in range(0, 9):
		var a := PI * 1.5 + (PI * 0.5) * float(i) / 8.0
		pts.append(Vector2(size.x - rr, rr) + Vector2(cos(a), sin(a)) * rr)
	pts.append(Vector2(size.x, size.y))
	pts.append(Vector2(0, size.y))
	var uvs := PackedVector2Array()
	for q in pts:
		uvs.append((src.position + q / k) / ts)
	draw_colored_polygon(pts, Color.WHITE, uvs, texture)
	var c := _bg()
	var clear := Color(c.r, c.g, c.b, 0.0)
	var y0 := size.y * (1.0 - FADE)
	draw_polygon(PackedVector2Array([Vector2(0, y0), Vector2(size.x, y0), Vector2(size.x, size.y + 1), Vector2(0, size.y + 1)]), PackedColorArray([clear, clear, c, c]))
