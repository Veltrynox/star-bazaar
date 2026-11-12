extends RefCounted
## Shared ring drawing for Juice (kept apart so inner classes of juice.gd can call it).
const Juice := preload("res://game/juice.gd")

## Layered shock ring at progress u (0..1): a bright leading ring, a thin trailing ring that lags behind it, a soft wide
## halo and a crown of short sparks thrown outward. Radii in px, `w` is the lead stroke width. Pure drawing, no state.
static func draw_shock(ci: CanvasItem, c: Vector2, r0: float, r1: float, u: float, col: Color, w: float = 3.0, sparks: int = 10) -> void:
	if u <= 0.0 or u >= 1.0:
		return
	var lead := 1.0 - pow(1.0 - u, 3.0)
	var rr := lerpf(r0, r1, lead)
	var fade := 1.0 - u
	var k := maxf(Juice.motion, 0.0)
	ci.draw_arc(c, rr, 0.0, TAU, 72, Color(col, col.a * 0.16 * fade), w * 3.5 * fade + 2.0, true)  # halo
	var lag := 1.0 - pow(1.0 - clampf(u * 0.78, 0.0, 1.0), 3.0)
	ci.draw_arc(c, lerpf(r0, r1, lag), 0.0, TAU, 72, Color(col, col.a * 0.45 * fade), 1.0, true)  # trailing thread
	ci.draw_arc(c, rr, 0.0, TAU, 72, Color(col, col.a * pow(fade, 1.2)), maxf(1.0, w * fade + 1.0), true)  # lead ring
	if sparks > 0 and k > 0.0:
		var sa := fade * fade
		var ln := 4.0 + 8.0 * fade
		for i in sparks:
			var a := TAU * float(i) / float(sparks) + 0.35
			var d := Vector2(cos(a), sin(a))
			ci.draw_line(c + d * (rr + 2.0), c + d * (rr + 2.0 + ln), Color(col, col.a * sa), 1.5, true)
