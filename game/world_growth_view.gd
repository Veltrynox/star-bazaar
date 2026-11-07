extends Control
## T264: growth on the map without opening a card (design/proposals/2026-11-06-empire-growth-v2.md section 3.1).
## Per established world: a thin ring of notches round the planet (progress in the tier), need icons under the name
## (met bright, a short amber pulse when a need becomes met, locked "?"), and a small marker at the Bazaar capital.
## Closed (undiscovered), barren and not-yet-established worlds show nothing. Drawn in screen space from the map's
## camera, so it follows zoom and planet size; the node ignores the mouse, so it never blocks a click.
## Numbers: balance.json growth_* keys (placeholders, economy-designer sets them); the fallbacks below only keep a
## missing key from breaking the draw. Needs and progress come from game/prosperity.gd.

const PathfinderView := preload("res://game/pathfinder_view.gd")
const REF_H := 941.0  # the design frame height the pixel keys are given in

var map: Node = null  # game/map.gd
var _met_before := {}  # "planet:slot" -> met at the last frame
var _pulse := {}       # "planet:slot" -> seconds left of the amber pulse

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _k(key: String, fallback: float) -> float:
	var p = map.prosperity if map != null else null
	return float(p.balance.get(key, fallback)) if p != null else fallback

func _process(delta: float) -> void:
	for k in _pulse.keys():
		_pulse[k] = float(_pulse[k]) - delta
		if _pulse[k] <= 0.0:
			_pulse.erase(k)
	queue_redraw()

func _shown(i: int) -> bool:
	if map == null or map.prosperity == null or map.camera == null or not map.camera.is_inside_tree():
		return false
	if i >= map.planet_labels.size() or not map.planet_labels[i].visible:
		return false
	var on: bool = PathfinderView.active(map.flight)
	if not PathfinderView.discovered(map.flight if on else null, str(map.planets[i].get("id", i))):
		return false
	return map.prosperity.tier(i) >= 1

func _draw() -> void:
	if map == null or map.prosperity == null or map.camera == null or not map.camera.is_inside_tree():
		return
	var cam: Camera3D = map.camera
	var scale_px := get_viewport().get_visible_rect().size.y / REF_H
	var font := Ui.mono_font()
	for i in map.planets.size():
		var capital: bool = map.capital_planet != "" and str(map.planets[i].get("id", "")) == map.capital_planet
		var visible_i: bool = _shown(i) or (capital and map.planet_labels[i].visible and map.prosperity.tier(i) >= 0)
		if not visible_i:
			continue
		var centre: Vector3 = map.positions[i]
		if cam.is_position_behind(centre):
			continue
		var c2: Vector2 = cam.unproject_position(centre)
		var right: Vector3 = cam.global_transform.basis.x.normalized()
		var r_px: float = c2.distance_to(cam.unproject_position(centre + right * map.planet_radius(i) * map.PLANET_VISIBLE / map.PLANET_RADIUS))
		if not _shown(i):
			_draw_beats(i, c2, r_px, scale_px)
			_draw_capital(c2, r_px, scale_px)
			continue
		_draw_ring(i, c2, r_px, scale_px)
		if capital:
			_draw_capital(c2, r_px, scale_px)
		_draw_beats(i, c2, r_px, scale_px)
		_draw_needs(i, scale_px, font, c2.y + r_px + (_k("growth_ring_gap_px", 6.0) + _k("growth_ring_width_px", 2.0)) * scale_px)

func _draw_ring(i: int, c: Vector2, r_px: float, scale_px: float) -> void:
	var p = map.prosperity
	var n: int = maxi(1, p.steps_needed(i))
	var lit: int = n if p.tier(i) >= p.max_tier() else p.steps(i)
	var radius := r_px + _k("growth_ring_gap_px", 6.0) * scale_px
	var w := maxf(1.0, _k("growth_ring_width_px", 2.0) * scale_px)
	var gap_frac := clampf(_k("growth_notch_gap", 0.18), 0.0, 0.9)
	var seg := TAU / float(n)
	var col_on := Ui.col("star_warm")
	var col_off := Color(Ui.col("ink_muted"), _k("growth_dim_alpha", 0.35))
	if p.restless(i):
		col_on = Color(Ui.col("signal_bad").lerp(col_on, 0.5), 0.7)  # progress is draining: the lit notches go amber-red
		col_on.a *= clampf(_k("beat_restless_dim", 0.5), 0.0, 1.0)  # T266: and the ring dims
		col_off.a *= clampf(_k("beat_restless_dim", 0.5), 0.0, 1.0)
	var tick: float = map.beat_progress("notch", i)  # T266: the newest notch swells and flashes
	for k in n:
		var a0 := -PI / 2.0 + seg * float(k) + seg * gap_frac * 0.5
		var a1 := -PI / 2.0 + seg * float(k + 1) - seg * gap_frac * 0.5
		var col_k: Color = col_on if k < lit else col_off
		var w_k := w
		if tick >= 0.0 and k == lit - 1:
			var pk := 1.0 - tick
			col_k = col_k.lerp(Color(1, 1, 1, 1), pk * 0.8)
			w_k = w * (1.0 + pk * _k("beat_notch_swell", 1.5))
		draw_arc(c, radius, a0, a1, 12, col_k, w_k, true)

func _draw_needs(i: int, scale_px: float, font: Font, ring_bottom: float) -> void:
	var needs: Array = map.prosperity.needs(i)
	if needs.is_empty():
		return
	var lab: Label = map.planet_label_2d[i] if i < map.planet_label_2d.size() else null
	var px := maxf(8.0, _k("growth_icon_px", 14.0) * scale_px)
	var gap := px * 0.35
	var total := float(needs.size()) * px + float(needs.size() - 1) * gap
	var anchor: Vector2 = map.camera.unproject_position(map.planet_labels[i].global_position)
	var label_h: float = lab.get_minimum_size().y if lab != null else 16.0 * scale_px
	var x: float = anchor.x - total * 0.5
	var y: float = maxf(anchor.y + label_h * 0.5, ring_bottom) + gap  # below the name and the ring, never over them
	var pulse_s := maxf(0.05, _k("growth_pulse_seconds", 1.2))
	var amber := Ui.col("star_warm")
	for s in needs.size():
		var nd: Dictionary = needs[s]
		var key := "%d:%d" % [i, s]
		var met: bool = bool(nd["met"])
		if met and _met_before.has(key) and not bool(_met_before[key]):
			_pulse[key] = pulse_s
		_met_before[key] = met
		var rect := Rect2(Vector2(x + float(s) * (px + gap), y), Vector2(px, px))
		var col: Color
		if bool(nd["locked"]):
			col = Color(Ui.col("ink_muted"), 0.8)
		elif met:
			col = Ui.commodity_col(str(nd["good"]))
			if col == Color.WHITE:
				col = Ui.col("ink")
		else:
			col = Color(Ui.col("ink_muted"), _k("growth_dim_alpha", 0.35) + 0.15)
		if _pulse.has(key):
			col = col.lerp(amber, clampf(float(_pulse[key]) / pulse_s, 0.0, 1.0))
		if bool(nd["locked"]):
			var fs := roundi(px * 0.95)
			draw_string(font, rect.position + Vector2(0, px * 0.85), "?", HORIZONTAL_ALIGNMENT_CENTER, px, fs, col)
		else:
			var tex := Ui.icon(str(nd["good"]))
			if tex != null:
				draw_texture_rect(tex, rect, false, col)

func _draw_capital(c: Vector2, r_px: float, scale_px: float) -> void:
	var m := maxf(3.0, _k("growth_marker_px", 5.0) * scale_px)
	var top := c + Vector2(0, -(r_px + (_k("growth_ring_gap_px", 6.0) + _k("growth_ring_width_px", 2.0) + 4.0) * scale_px + m))
	var col := Ui.col("star_warm")
	var pts := PackedVector2Array([top + Vector2(0, -m), top + Vector2(m, 0), top + Vector2(0, m), top + Vector2(-m, 0)])
	draw_colored_polygon(pts, col)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color(Ui.col("panel_100"), 0.9), 1.0, true)

## T266: the tier-up pulse ring (warm) and the stage-done flash plus wide ring (white-gold) at the world. Game-time progress from the map;
## only strokes and a soft disc, no clicks, no text, nothing over the numbers.
func _draw_beats(i: int, c: Vector2, r_px: float, scale_px: float) -> void:
	var warm := Ui.col("star_warm")
	var u: float = map.beat_progress("tier", i)
	if u >= 0.0:
		var rr := r_px + lerpf(0.0, _k("beat_ring_radius_px", 140.0) * scale_px, 1.0 - pow(1.0 - u, 2.0))
		draw_arc(c, rr, 0.0, TAU, 64, Color(warm, (1.0 - u) * 0.9), maxf(1.0, 3.0 * scale_px * (1.0 - u) + 1.0), true)
	u = map.beat_progress("stage", i)
	if u >= 0.0:
		var flash := clampf(1.0 - u * 4.0, 0.0, 1.0)  # the flash is the first quarter
		if flash > 0.0:
			draw_circle(c, r_px * 1.15, Color(1.0, 0.95, 0.8, flash * _k("beat_flash_alpha", 0.6)))
		var rr2 := r_px + lerpf(0.0, _k("beat_stage_radius_px", 260.0) * scale_px, 1.0 - pow(1.0 - u, 2.0))
		draw_arc(c, rr2, 0.0, TAU, 96, Color(warm.lerp(Color.WHITE, 0.5), (1.0 - u) * 0.9), maxf(1.0, 4.0 * scale_px * (1.0 - u) + 1.0), true)

## T285: an established, discovered world with its name on screen (the weather chips and the mood face show only there).
func _established(i: int) -> bool:
	if map == null or i < 0 or i >= map.planet_labels.size() or not map.planet_labels[i].visible:
		return false
	var fl = map.flight
	var pid := str(map.planets[i].get("id", i))
	return PathfinderView.discovered(fl, pid) and PathfinderView.established(fl, pid)

func _ring_edge(i: int, c2: Vector2, scale_px: float) -> float:
	var cam: Camera3D = map.camera
	var right: Vector3 = cam.global_transform.basis.x.normalized()
	var r_px: float = c2.distance_to(cam.unproject_position(map.positions[i] + right * map.planet_radius(i) * map.PLANET_VISIBLE / map.PLANET_RADIUS))
	return r_px + (_k("growth_ring_gap_px", 6.0) + _k("growth_ring_width_px", 2.0) + 4.0) * scale_px

## T285: weather chips. On the world: a stack right of the planet (the name sits below it, the capital marker above), one chip per
## live row of Events.active. On a lane that touches a congested world: one chip just above the lane tag. Pure drawing, no clicks.
## A shortage, flood or price-up names its good only when Availability shows it (Ui.weather_good).
func _draw_weather(cam: Camera3D, scale_px: float, font: Font) -> void:
	var ev = map.events
	if ev == null or ev.active.is_empty():
		return
	var h := maxf(10.0, _k("weather_chip_px", 15.0) * scale_px)
	var fs := maxi(8, roundi(_k("weather_chip_font_px", 11.0) * scale_px))
	var gap := maxf(1.0, _k("weather_chip_gap_px", 3.0) * scale_px)
	var alpha := clampf(_k("weather_chip_alpha", 0.88), 0.0, 1.0)
	for i in map.planets.size():
		var rows: Array = []
		for a in ev.active:
			if int(a["planet"]) == i:
				rows.append(a)
		if rows.is_empty() or not _established(i) or cam.is_position_behind(map.positions[i]):
			continue
		var c2: Vector2 = cam.unproject_position(map.positions[i])
		var x: float = c2.x + _ring_edge(i, c2, scale_px)
		var y: float = c2.y - (float(rows.size()) * h + float(rows.size() - 1) * gap) * 0.5
		for a in rows:
			var g := Ui.weather_good(a)
			Ui.draw_chip(self, Vector2(x, y), Ui.weather_text(a, false), Ui.house_col(int(a.get("house", 0))), font, fs, h, alpha, Ui.icon(g) if g != "" else null)
			y += h + gap
	var done := {}
	for a in ev.active:
		if str(a["kind"]) != "congestion":
			continue
		var p := int(a["planet"])
		for r in map._route_list:
			var id := int(r["id"])
			if done.has(id) or (int(r["a"]) != p and int(r["b"]) != p):
				continue
			var ln = map.route_lines.get(id)
			if ln == null or not ln.visible or ln.tag2d == null or not ln.tag2d.visible:
				continue
			done[id] = true
			Ui.draw_chip(self, ln.tag2d.position + Vector2(0, -h - gap), Ui.weather_text(a, false), Ui.house_col(int(a.get("house", 0))), font, fs, h, alpha)

## T285: the mood face of the hovered world, left of the planet. Established worlds only; a face and no number.
func _draw_hover_face(cam: Camera3D, scale_px: float) -> void:
	if map.prosperity == null or not map.prosperity.has_method("mood"):
		return
	var i: int = map.pick_planet(get_viewport().get_mouse_position())
	if i < 0 or not _established(i) or cam.is_position_behind(map.positions[i]):
		return
	var fr := maxf(6.0, _k("face_hover_px", 20.0) * scale_px) * 0.5
	var c2: Vector2 = cam.unproject_position(map.positions[i])
	Ui.draw_mood_face(self, Vector2(c2.x - _ring_edge(i, c2, scale_px) - fr, c2.y), fr, str(map.prosperity.mood(i)))
