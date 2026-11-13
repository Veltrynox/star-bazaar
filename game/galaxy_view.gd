extends Control
## T105 / owner update: galaxy overview (2D overlay), laid out as in the design pack (screens/GalaxyView.html,
## components/GalaxyView). Open systems are soft territory outlines with their sun, faint orbits, planets (12 px),
## a commodity icon beside each planet that makes something, and the player's routes with ship dots.
## Systems not open yet show as small dim "Uncharted" stars on dashed links. A left panel describes the selected
## system; the one-time three-step tutorial is a floating card beside what each step is about. Everything is read from main; nothing is invented.
## There are no galaxy coordinates in the data: systems sit on a fixed layout by id (design-pack sample slots) and
## links join consecutive ids.

const StoryText := preload("res://game/story_text.gd")
const Systems := preload("res://game/systems.gd")
const TUT_IDS := ["TUT_GALAXY_INTRO", "TUT_GALAXY_ICONS", "TUT_GALAXY_ROUTES"]
## Design-pack sample positions (1672x941 frame), used by system index. Mapped into the free middle area.
## 2026-11-12: three systems in the game, so three slots.
const SLOTS := [Vector2(640, 500), Vector2(1062, 372), Vector2(470, 238)]
const FRAME_X0 := 340.0
const FRAME_W := 992.0
const FRAME_Y0 := 100.0
const FRAME_H := 780.0
const TILT := 0.5
const SIDE_W := 320.0

signal system_chosen(id: int)
signal closed

var main: Control
var close_button: Button
var side: PanelContainer
var side_box: VBoxContainer
var tut_panel: PanelContainer  # the floating tutorial card (placed beside the step's target)
var tut_box: VBoxContainer
var tut_hl: Panel  # pulsing outline over the target
var tut_arrow: Polygon2D  # pointer from the card to the target
var title_label: Label
var hint_label: Label
var _voiced_step := -1
var tut_step: int = -1  # -1 none this opening, 0..2 lines, 3 = done note
var selected_sys: int = -1
var permit_button: Button  # Buy permit button of the shown closed system (tests)
var _hit: Array = []  # [{id, pos, r, open}]
var _hover_id: int = -1
var _clock: float = 0.0
var _tex_cache: Dictionary = {}
var _stars: Array = []  # Vector3(x 0..1, y 0..1, brightness 0..1)

func setup(main_node: Control) -> void:
	main = main_node
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)  # a separate full screen: it covers the map, top bar and rail
	var rng := RandomNumberGenerator.new()
	rng.seed = 41
	for i in 360:  # starfield, seed and density as in the design pack (normalised positions)
		_stars.append(Vector3(rng.randf(), rng.randf(), rng.randf()))
	# heading
	var head := VBoxContainer.new()
	head.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	head.grow_horizontal = Control.GROW_DIRECTION_BOTH
	head.offset_top = 20
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label = Label.new()
	title_label.theme_type_variation = "LabelTitle"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(title_label)
	hint_label = Label.new()
	hint_label.theme_type_variation = "LabelSmall"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(hint_label)
	add_child(head)
	# left: selected system
	side = PanelContainer.new()
	side.position = Vector2(20, 76)
	side.custom_minimum_size = Vector2(SIDE_W, 0)
	side_box = VBoxContainer.new()
	side_box.add_theme_constant_override("separation", 10)
	Ui.scroll_wrap(side, side_box, 76.0 + 40.0)
	add_child(side)
	# tutorial: a floating card, outline and pointer, placed in _tut_place (only while it runs)
	tut_panel = PanelContainer.new()
	tut_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE  # the buttons inside still take clicks
	tut_panel.custom_minimum_size = Vector2(main.TUT_CARD_W, 0)
	tut_box = VBoxContainer.new()
	tut_box.add_theme_constant_override("separation", 8)
	tut_panel.add_child(tut_box)
	tut_panel.visible = false
	tut_hl = main.tut_make_hl()
	tut_arrow = main.tut_make_arrow()
	# Back, top left: returns to the screen that opened the galaxy view
	close_button = Button.new()
	close_button.text = StoryText.get_or("BTN_BACK", "Back")
	close_button.icon = Ui.icon("back")
	close_button.theme_type_variation = "ButtonGhost"
	close_button.position = Vector2(20, 16)
	close_button.custom_minimum_size = Vector2(110, 40)
	close_button.pressed.connect(close_view)
	add_child(close_button)
	_build_legend()
	add_child(tut_hl)  # last: above the panels and the legend
	add_child(tut_panel)
	add_child(tut_arrow)

func _build_legend() -> void:
	var legend := HBoxContainer.new()
	legend.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	legend.grow_horizontal = Control.GROW_DIRECTION_BOTH
	legend.grow_vertical = Control.GROW_DIRECTION_BEGIN
	legend.offset_bottom = -20
	legend.add_theme_constant_override("separation", 20)
	legend.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var items := [
		["LBL_LEGEND_ENERGY", "Energy route", Ui.col("commodity_energy"), false],
		["LBL_LEGEND_FOOD", "Food route", Ui.col("commodity_food"), false],
		["LBL_LEGEND_LINK", "Link", Ui.col("line_300"), false],
		["LBL_LEGEND_UNCHARTED", "Uncharted link", Ui.col("line_200"), true]]
	for it in items:
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 6)
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sw := Swatch.new()
		sw.color = it[2]
		sw.dashed = it[3]
		h.add_child(sw)
		var l := Label.new()
		l.text = StoryText.get_or(str(it[0]), str(it[1]))
		l.theme_type_variation = "LabelSmall"
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(l)
		legend.add_child(h)
	add_child(legend)

## The overview always opens (the left-rail galaxy icon is always shown); locked systems show as uncharted.
func available() -> bool:
	return true

## True once system 2 (any system past the first) is open.
func has_second_system() -> bool:
	return main.open_systems.size() > 1

func open_view() -> bool:
	if visible or not available():
		return false
	visible = true
	if get_parent() != null:
		get_parent().move_child(self, -1)  # on top of every panel of the map screen
	if "keys_enabled" in main.map:
		main.map.keys_enabled = false  # W A S D must not pan the hidden map
	tut_step = -1
	if not main.galaxy_seen and has_second_system():  # the tutorial waits until there is a second system
		main.galaxy_seen = true
		tut_step = 0
		main.save_now()
	if selected_sys < 0 or not _sys_ids().has(selected_sys):
		selected_sys = main.view_system
	_rebuild_all()
	return true

func close_view() -> void:
	if not visible:
		return
	visible = false
	if "keys_enabled" in main.map:
		main.map.keys_enabled = true
	closed.emit()

func toggle_view() -> void:
	if visible:
		close_view()
	else:
		open_view()

func refresh() -> void:
	if visible:
		_rebuild_all()

func _process(delta: float) -> void:
	if not visible:
		return
	if not main.paused:
		_clock += delta
	if tut_panel.visible:
		_tut_place()
	queue_redraw()

func _sys_ids() -> Array:
	var out: Array = [1]
	out.append_array(Systems.ids())
	return out

func _rebuild_all() -> void:
	var ids := _sys_ids()
	var open_n := 0
	for sid in ids:
		if main.open_systems.has(sid):
			open_n += 1
	title_label.text = StoryText.get_or("LBL_GALAXY_TITLE", "The galaxy")
	hint_label.text = StoryText.get_or("LBL_GALAXY_HINT", "{open} of {total} systems open. Click a system to see it.",
		{"open": open_n, "total": ids.size()})
	_build_side()
	_build_tutorial()
	queue_redraw()

# ---------------------------------------------------------------- data from main (no new values)

## Open system data: {planets: [index], lanes: [{a, b, c, ships, net, status}], ships, net}.
func _system_data(sid: int) -> Dictionary:
	var idx: Array = []
	for i in main.map.planets.size():
		if int(main.map.planets[i].get("system", 1)) == sid:
			idx.append(i)
	var lanes: Array = []
	var by_key := {}
	var ships := 0
	var net := 0
	for rec in main.get_routes():
		if not idx.has(int(rec["a"])) and not idx.has(int(rec["b"])):
			continue
		var key := "%d|%d|%s" % [int(rec["a"]), int(rec["b"]), str(rec["c"])]
		ships += 1
		net += int(rec["net"])
		if by_key.has(key):
			var ln: Dictionary = by_key[key]
			ln["ships"] = int(ln["ships"]) + 1
			ln["net"] = int(ln["net"]) + int(rec["net"])
			if str(rec["status"]) == "running":
				ln["status"] = "running"
			continue
		var ln2 := {"a": int(rec["a"]), "b": int(rec["b"]), "c": str(rec["c"]), "ships": 1,
			"net": int(rec["net"]), "status": str(rec["status"])}
		by_key[key] = ln2
		lanes.append(ln2)
	return {"planets": idx, "lanes": lanes, "ships": ships, "net": net}

func _signed(n: int) -> String:
	if n > 0:
		return "+%d" % n
	if n < 0:
		return "−%d" % -n
	return "0"

func _net_color(n: int) -> Color:
	return Ui.col("signal_good") if n > 0 else (Ui.col("signal_bad") if n < 0 else Ui.col("ink_muted"))

func _links_of(sid: int) -> int:
	var ids := _sys_ids()
	var k := ids.find(sid)
	var n := 0
	if k > 0:
		n += 1
	if k >= 0 and k < ids.size() - 1:
		n += 1
	return n

# ---------------------------------------------------------------- layout

func _map_area() -> Rect2:
	var left := SIDE_W + 36.0
	return Rect2(Vector2(left, 70.0), Vector2(maxf(size.x - left * 2.0, 200.0), maxf(size.y - 140.0, 200.0)))

func _scale() -> float:
	var a := _map_area()
	return minf(a.size.x / FRAME_W, a.size.y / FRAME_H)

func _sys_center(k: int) -> Vector2:
	var a := _map_area()
	var slot: Vector2 = SLOTS[k % SLOTS.size()]
	return a.position + Vector2((slot.x - FRAME_X0) / FRAME_W, (slot.y - FRAME_Y0) / FRAME_H) * a.size

func _sys_radius() -> float:
	return 150.0 * _scale()

## Planet index -> {pos, orbit} for open systems. The sun is the middle of the system's planets; each planet keeps
## its direction from it and sits on a tilted orbit ellipse scaled to fit the territory.
func _planet_layout() -> Dictionary:
	var out := {}
	var ids := _sys_ids()
	for k in ids.size():
		var sid: int = ids[k]
		if not main.open_systems.has(sid):
			continue
		var idx: Array = _system_data(sid)["planets"]
		if idx.is_empty():
			continue
		var lo := Vector2(INF, INF)
		var hi := Vector2(-INF, -INF)
		for i in idx:
			var p: Dictionary = main.map.planets[i]
			var v := Vector2(float(p.get("x", 0)), float(p.get("y", 0)))
			lo = Vector2(minf(lo.x, v.x), minf(lo.y, v.y))
			hi = Vector2(maxf(hi.x, v.x), maxf(hi.y, v.y))
		var mid := (lo + hi) * 0.5
		var maxd := 1.0
		for i in idx:
			var p2: Dictionary = main.map.planets[i]
			maxd = maxf(maxd, (Vector2(float(p2.get("x", 0)), float(p2.get("y", 0))) - mid).length())
		var c := _sys_center(k)
		for i in idx:
			var p3: Dictionary = main.map.planets[i]
			var d := Vector2(float(p3.get("x", 0)), float(p3.get("y", 0))) - mid
			var rr := clampf(d.length() / maxd, 0.3, 1.0) * 0.78 * _sys_radius()
			var ang := d.angle() if d.length() > 0.01 else 0.0
			out[i] = {"pos": c + Vector2(cos(ang) * rr, sin(ang) * rr * TILT), "orbit": rr, "sys": sid}
	return out

## Soft territory outline: a closed smooth curve with a little wobble, the same for a given system.
func _territory(c: Vector2, r: float, seed_n: int) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = 31 + seed_n * 17
	var n := 14
	var ctrl: Array = []
	for k in n:
		var a := float(k) / float(n) * TAU
		var rr := r * (0.82 + rng.randf() * 0.3)
		ctrl.append(c + Vector2(cos(a) * rr, sin(a) * rr * 0.8))
	var pts := PackedVector2Array()
	for k in n:
		var p0: Vector2 = ctrl[(k + n - 1) % n]
		var p1: Vector2 = ctrl[k]
		var p2: Vector2 = ctrl[(k + 1) % n]
		var a0: Vector2 = (p0 + p1) * 0.5
		var a1: Vector2 = (p1 + p2) * 0.5
		for s in 8:
			var t := float(s) / 8.0
			pts.append(a0 * (1.0 - t) * (1.0 - t) + p1 * 2.0 * (1.0 - t) * t + a1 * t * t)
	pts.append(pts[0])
	return pts

func _curve_ctrl(a: Vector2, b: Vector2, bow: float) -> Vector2:
	var m := (a + b) * 0.5
	var d := b - a
	var l := maxf(d.length(), 1.0)
	return m + Vector2(-d.y / l * bow, d.x / l * bow)

func _bez(a: Vector2, c: Vector2, b: Vector2, t: float) -> Vector2:
	return a * (1.0 - t) * (1.0 - t) + c * 2.0 * (1.0 - t) * t + b * t * t

func _draw_curve(a: Vector2, c: Vector2, b: Vector2, col: Color, w: float, dashed: bool) -> void:
	var pts := PackedVector2Array()
	for s in 25:
		pts.append(_bez(a, c, b, float(s) / 24.0))
	if not dashed:
		draw_polyline(pts, col, w, true)
		return
	# design: stroke-dasharray 4 4, measured along the curve
	var on := true
	var left := 4.0
	for k in pts.size() - 1:
		var p0: Vector2 = pts[k]
		var p1: Vector2 = pts[k + 1]
		var seg := p0.distance_to(p1)
		var at := 0.0
		while at < seg:
			var step := minf(left, seg - at)
			if on:
				draw_line(p0.lerp(p1, at / seg), p0.lerp(p1, (at + step) / seg), col, w, true)
			at += step
			left -= step
			if left <= 0.0001:
				on = not on
				left = 4.0

func _draw_dashed(a: Vector2, b: Vector2, col: Color, w: float) -> void:
	draw_dashed_line(a, b, col, w, 5.0, true)

# ---------------------------------------------------------------- drawing

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Ui.col("void_000"))  # opaque: nothing of the map shows through
	for st in _stars:
		var a: float = 0.2 + 0.6 * st.z
		draw_circle(Vector2(st.x * size.x, st.y * size.y), 0.6 + st.z * 0.9, Color(1.0, 0.96, 0.9, a))
	_hit = []
	var sans := get_theme_default_font()
	var mono := Ui.mono_font()
	var ids := _sys_ids()
	var s := _scale()
	var R := _sys_radius()
	var layout := _planet_layout()
	var pulse := 0.5 + 0.5 * sin(_clock * 4.0)
	# links between consecutive systems
	for k in ids.size() - 1:
		var a: int = ids[k]
		var b: int = ids[k + 1]
		var known: bool = main.open_systems.has(a) and main.open_systems.has(b)
		if known:
			draw_line(_sys_center(k), _sys_center(k + 1), Ui.col("line_300"), 1.2, true)
		else:
			_draw_dashed(_sys_center(k), _sys_center(k + 1), Ui.col("line_200"), 1.0)
	_draw_storage_links(ids)
	_draw_link_dots(ids)
	# territories and orbits
	for k in ids.size():
		var sid: int = ids[k]
		if not main.open_systems.has(sid):
			continue
		var c := _sys_center(k)
		var poly := _territory(c, R, k)
		draw_colored_polygon(poly.slice(0, poly.size() - 1), Color(1, 1, 1, 0.031))
		var on := sid == selected_sys
		var edge := Ui.col("line_300") if on else Ui.col("line_200")
		if sid == _hover_id:  # the shared clickable cue: a warm outline
			edge = Ui.col("star_warm")
		draw_polyline(poly, edge, 1.0, true)
		_hit.append({"id": sid, "pos": c, "r": R, "open": true})
	for i in layout:
		var info: Dictionary = layout[i]
		var c2 := _sys_center(ids.find(int(info["sys"])))
		_draw_ellipse(c2, float(info["orbit"]), Ui.col("line_100"))
	# routes
	var step_routes := tut_step == 2
	for sid in ids:
		if not main.open_systems.has(sid):
			continue
		var lanes: Array = _system_data(sid)["lanes"]
		for n in lanes.size():
			var ln: Dictionary = lanes[n]
			if not layout.has(ln["a"]) or not layout.has(ln["b"]):
				continue
			if int(ln["a"]) < 0 or int(main.map.planets[ln["a"]].get("system", 1)) != sid:
				continue  # a lane between systems is drawn once, from its source system
			_draw_lane(ln, layout, n, s, pulse if step_routes else -1.0)
	# suns, planets, icons, labels
	for k in ids.size():
		var sid2: int = ids[k]
		var c3 := _sys_center(k)
		var open: bool = main.open_systems.has(sid2)
		var on2 := sid2 == selected_sys
		if open:
			_draw_prosperity_glow(c3, _prosperity_sum(sid2), s)
			draw_circle(c3, 24.0 * s, Color(0.945, 0.83, 0.63, 0.07))
			draw_circle(c3, 15.0 * s, Color(0.945, 0.83, 0.63, 0.14))
			draw_circle(c3, 8.0 * s, Color(0.945, 0.83, 0.63, 0.6))
			draw_circle(c3, 4.5 * s, Ui.col("star_core"))
			if on2:
				draw_arc(c3, 20.0, 0.0, TAU, 40, Ui.col("star_warm"), 1.5, true)
		else:
			draw_circle(c3, 10.0, Color(1, 1, 1, 0.05))
			draw_circle(c3, 3.5, Color(0.945, 0.83, 0.63, 0.55))
			if on2:
				draw_arc(c3, 13.0, 0.0, TAU, 32, Ui.col("star_warm"), 1.5, true)
			_hit.append({"id": sid2, "pos": c3, "r": 20.0, "open": false})
		var label_y := c3.y + (R * 0.8 + 14.0 if open else 24.0)
		if open:
			var data := _system_data(sid2)
			_draw_tracked(sans, c3.x, label_y, Systems.name_of(sid2).to_upper(), 14, Ui.col("ink"), 3.0)
			_draw_summary(mono, c3.x, label_y + 18.0, data)
		else:
			_draw_tracked(sans, c3.x, label_y, StoryText.get_or("LBL_UNCHARTED", "Uncharted").to_upper(), 12, Ui.col("ink_subtle"), 3.0)
	for i in layout:
		var info2: Dictionary = layout[i]
		var pos: Vector2 = info2["pos"]
		var p: Dictionary = main.map.planets[i]
		_draw_planet(pos, p)
		var c4 := _sys_center(ids.find(int(info2["sys"])))
		var comm := str(p.get("abundant", ""))
		if comm != "" and Availability.good(comm):  # data/availability.json: no icon for a good not visible yet
			var ic: Texture2D = Ui.icon(comm)
			if ic != null:
				var tint := Ui.commodity_col(comm)
				if tut_step == 1:  # line 2 up: the resource icons pulse
					tint = tint.lerp(Ui.col("signal_info"), pulse)
				draw_texture_rect(ic, Rect2(pos + Vector2(5, -19), Vector2(13, 13)), false, tint)
		if int(info2["sys"]) == selected_sys:  # planet names only inside the selected system, away from the sun
			var left: bool = pos.x < c4.x
			var nm: String = main.planet_name(int(i))  # T180: hides closed names
			var w := sans.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
			draw_string(sans, pos + Vector2(-(w + 12.0) if left else 12.0, 4.0), nm, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Ui.col("ink_muted"))
	# ship dots on top
	for sid3 in ids:
		if not main.open_systems.has(sid3):
			continue
		var lanes2: Array = _system_data(sid3)["lanes"]
		for n2 in lanes2.size():
			var ln2: Dictionary = lanes2[n2]
			if not layout.has(ln2["a"]) or not layout.has(ln2["b"]):
				continue
			if int(main.map.planets[ln2["a"]].get("system", 1)) != sid3:
				continue
			_draw_ships(ln2, layout, n2, s)

## T171: a thin line per Storage Link between the two systems, shifted sideways so it never lies on the system link or a route lane.
## Dimmed when dormant. Drawn only while the storage_link feature is visible.
func _link_segments(ids: Array) -> Array:
	var out: Array = []
	if not Availability.feature("storage_link"):
		return out
	for id in main.storage_link.links():
		var info: Dictionary = main.storage_link.link_info(int(id))
		var ka: int = ids.find(int(info["a"]))
		var kb: int = ids.find(int(info["b"]))
		if ka < 0 or kb < 0:
			continue
		var pa := _sys_center(ka)
		var pb := _sys_center(kb)
		var nrm := (pb - pa).orthogonal().normalized() * 9.0
		out.append({"a": pa + nrm, "b": pb + nrm, "info": info})
	return out

func _draw_storage_links(ids: Array) -> void:
	for seg in _link_segments(ids):
		var dormant: bool = str(seg["info"]["state"]) == "dormant"
		var col := Ui.col("star_warm")
		col.a = 0.3 if dormant else 0.8
		draw_line(seg["a"], seg["b"], col, 1.0, true)

## T286: small dots drift along each link between two open systems (more on a Storage Link). Game time (_clock stops on pause).
func _draw_link_dots(ids: Array) -> void:
	var bal: Dictionary = main.balance
	var speed := float(bal.get("galaxy_dot_speed", 0.08))
	var px := float(bal.get("galaxy_dot_px", 1.8))
	var n_link := int(bal.get("galaxy_dots_link", 2))
	var n_store := int(bal.get("galaxy_dots_storage_link", 5))
	var ink := Ui.col("ink")
	for k in ids.size() - 1:
		if not (main.open_systems.has(ids[k]) and main.open_systems.has(ids[k + 1])):
			continue
		_dots_on(_sys_center(k), _sys_center(k + 1), n_link, speed, px, Color(ink.r, ink.g, ink.b, 0.55))
	var warm := Ui.col("star_warm")
	for seg in _link_segments(ids):
		if str(seg["info"]["state"]) == "dormant":
			continue
		_dots_on(seg["a"], seg["b"], n_store, speed, px, Color(warm.r, warm.g, warm.b, 0.9))

func _dots_on(a: Vector2, b: Vector2, count: int, speed: float, px: float, col: Color) -> void:
	for i in count:
		var u := fmod(_clock * speed + float(i) / float(maxi(count, 1)), 1.0)
		draw_circle(a.lerp(b, u), px, col)

## Sum of the tiers of the established worlds in a system (Prosperity.tier is 0 or below for the rest).
func _prosperity_sum(sid: int) -> int:
	var total := 0
	for i in main.map.planets.size():
		if int(main.map.planets[i].get("system", 1)) == sid:
			total += maxi(0, main.prosperity.tier(i))
	return total

func _draw_prosperity_glow(c: Vector2, tier_sum: int, s: float) -> void:
	if tier_sum <= 0:
		return
	var bal: Dictionary = main.balance
	var per_px := float(bal.get("galaxy_glow_px_per_tier", 5.0))
	var per_a := float(bal.get("galaxy_glow_alpha_per_tier", 0.02))
	var max_a := float(bal.get("galaxy_glow_alpha_max", 0.3))
	var r := 24.0 * s + per_px * float(tier_sum) * s
	var warm := Ui.col("star_warm")
	for j in 4:  # soft falloff: four stacked discs
		var f := 1.0 - float(j) * 0.25
		draw_circle(c, r * f, Color(warm.r, warm.g, warm.b, minf(per_a * float(tier_sum), max_a) * 0.4))

func _link_tooltip(pos: Vector2) -> String:
	for seg in _link_segments(_sys_ids()):
		var pa: Vector2 = seg["a"]
		var pb: Vector2 = seg["b"]
		var cp := Geometry2D.get_closest_point_to_segment(pos, pa, pb)
		if cp.distance_to(pos) > 6.0:
			continue
		var info: Dictionary = seg["info"]
		var a := Systems.name_of(int(info["a"]))
		var b := Systems.name_of(int(info["b"]))
		if str(info["state"]) == "dormant":
			return StoryText.get_or("SS_LINK_TIP_MAP_DORMANT", "Dormant link: {a} and {b}. No goods move until the storages hold {n} energy.", {"a": a, "b": b, "n": int(info["upkeep"])})
		return StoryText.get_or("SS_LINK_TIP_MAP", "Storage Link: {a} and {b}.", {"a": a, "b": b})
	return ""

func _draw_ellipse(c: Vector2, rx: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for k in 49:
		var a := float(k) / 48.0 * TAU
		pts.append(c + Vector2(cos(a) * rx, sin(a) * rx * TILT))
	draw_polyline(pts, col, 1.0, true)

func _lane_curve(ln: Dictionary, layout: Dictionary, n: int, s: float) -> Array:
	var a: Vector2 = layout[ln["a"]]["pos"]
	var b: Vector2 = layout[ln["b"]]["pos"]
	var bow := (-40.0 if n % 2 == 0 else 40.0) * s * (1.0 + 0.15 * float(n / 2))
	return [a, _curve_ctrl(a, b, bow), b]

func _draw_lane(ln: Dictionary, layout: Dictionary, n: int, s: float, pulse: float) -> void:
	var cv := _lane_curve(ln, layout, n, s)
	var running: bool = str(ln["status"]) == "running"
	var col := Ui.commodity_col(str(ln["c"])) if running else Ui.col("signal_warn")
	var w := 1.6
	if pulse >= 0.0:  # line 3 up: the routes pulse
		col = col.lerp(Ui.col("signal_info"), pulse)
		w = 2.6
	col.a = 0.8
	_draw_curve(cv[0], cv[1], cv[2], col, w, not running)

func _draw_ships(ln: Dictionary, layout: Dictionary, n: int, s: float) -> void:
	var cv := _lane_curve(ln, layout, n, s)
	var running: bool = str(ln["status"]) == "running"
	var cnt: int = int(ln["ships"])
	var ink := Ui.col("ink")
	for i in cnt:
		var phase := float(i) / float(cnt)
		var u := 0.88
		var back := false
		if running:
			var c := fmod(_clock * 0.08 + phase, 1.0)
			back = c > 0.5
			u = (2.0 - c * 2.0) if back else c * 2.0
			u = 0.06 + u * 0.88
		for j in 5:
			var uu := clampf(u + ((1.0 if back else -1.0) * float(j) * 0.025 if running else 0.0), 0.0, 1.0)
			var pos := _bez(cv[0], cv[1], cv[2], uu)
			if j == 0:
				var col := ink if running and not back else (Ui.col("ink_muted") if running else Ui.col("signal_warn"))
				draw_circle(pos, 2.0, col)
			elif running:
				var a := (0.22 if back else 0.4) - float(j) * 0.07
				draw_circle(pos, maxf(1.5 - float(j) * 0.2, 0.6), Color(ink.r, ink.g, ink.b, maxf(a, 0.05)))

func _thumb(type_name: String) -> Texture2D:
	if not _tex_cache.has(type_name):
		_tex_cache[type_name] = Ui.ui_texture("ui_thumb_%s" % type_name.to_lower())
	return _tex_cache[type_name]

func _draw_planet(pos: Vector2, p: Dictionary) -> void:
	var tex := _thumb(str(p.get("type", "")))
	if tex != null:
		draw_texture_rect(tex, Rect2(pos - Vector2(6, 6), Vector2(12, 12)), false)
	else:
		var cc := Ui.commodity_col(str(p.get("abundant", "")))
		draw_circle(pos, 6.0, (cc if cc != Color.WHITE else Ui.col("ink_muted")).darkened(0.35))
	draw_arc(pos, 6.5, 0.0, TAU, 20, Color(1, 1, 1, 0.22), 1.0, true)

## Text with extra letter spacing, centred on cx.
func _draw_tracked(font: Font, cx: float, y: float, text: String, fsize: int, col: Color, track: float) -> void:
	var total := 0.0
	for ch in text:
		total += font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x + track
	var x := cx - (total - track) * 0.5
	for ch in text:
		draw_string(font, Vector2(x, y), ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, col)
		x += font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x + track

## "3 planets · 3 routes · +348 / cycle", the net in its sign colour.
func _draw_summary(font: Font, cx: float, y: float, data: Dictionary) -> void:
	var nr: int = (data["lanes"] as Array).size()
	var np: int = (data["planets"] as Array).size()
	var net: int = int(data["net"])
	var head := "%s · %s · " % [
		StoryText.get_or("LBL_GALAXY_PLANETS", "{n} planets", {"n": np}),
		StoryText.get_or("LBL_GALAXY_ROUTE_ONE", "{n} route", {"n": nr}) if nr == 1 else StoryText.get_or("LBL_GALAXY_ROUTE_MANY", "{n} routes", {"n": nr})]
	var num := _signed(net)
	var tail := " " + StoryText.get_or("LBL_PER_CYCLE_UNIT", "/ cycle")
	var w1 := font.get_string_size(head, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
	var w2 := font.get_string_size(num, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
	var w3 := font.get_string_size(tail, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
	var x := cx - (w1 + w2 + w3) * 0.5
	draw_string(font, Vector2(x, y), head, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Ui.col("ink_muted"))
	draw_string(font, Vector2(x + w1, y), num, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, _net_color(net))
	draw_string(font, Vector2(x + w1 + w2, y), tail, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Ui.col("ink_muted"))

# ---------------------------------------------------------------- left panel (selected system)

func _caption(text: String) -> Label:
	var l := Label.new()
	l.text = text.to_upper()
	l.theme_type_variation = "LabelCaption"
	return l

func _icon_rect(token: String, size_px: float, tint: Color) -> TextureRect:
	var t := TextureRect.new()
	t.texture = Ui.icon(token)
	t.custom_minimum_size = Vector2(size_px, size_px)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	t.modulate = tint
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

func _wrapped(text: String, variation: String = "") -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(SIDE_W - 56.0, 0)
	if variation != "":
		l.theme_type_variation = variation
	return l

func _head_row(title: String, sub: String) -> Control:
	var row := HBoxContainer.new()
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var t := Label.new()
	t.text = title
	t.theme_type_variation = "LabelTitle"
	col.add_child(t)
	var sl := _wrapped(sub, "LabelSmall")
	col.add_child(sl)
	row.add_child(col)
	var x := Button.new()
	x.theme_type_variation = "ButtonSmall"
	x.icon = Ui.icon("close")
	x.tooltip_text = StoryText.get_or("BTN_CLOSE", "Close")
	x.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	x.pressed.connect(func():
		selected_sys = -1
		_build_side()
		queue_redraw())
	row.add_child(x)
	return row

func _build_side() -> void:
	for c in side_box.get_children():
		side_box.remove_child(c)
		c.queue_free()
	if selected_sys < 0 or not _sys_ids().has(selected_sys):
		side.visible = false
		return
	side.visible = true
	permit_button = null
	if main.open_systems.has(selected_sys):
		_build_open_side(selected_sys)
	else:
		_build_uncharted_side(selected_sys)
	side.size = Vector2.ZERO

func _build_uncharted_side(sid: int) -> void:
	side_box.add_child(_head_row(StoryText.get_or("LBL_UNCHARTED_SYSTEM", "Uncharted system"),
		StoryText.get_or("LBL_NOT_OPEN", "Not open yet")))
	side_box.add_child(_wrapped(StoryText.get_or("LBL_UNCHARTED_BODY", "Nobody you know has traded here. That may be the point."), "LabelSmall"))
	side_box.add_child(_caption(StoryText.get_or("LBL_KNOWN", "Known")))
	side_box.add_child(_info_row("planet", StoryText.get_or("LBL_GALAXY_PLANETS_WORD", "Planets"),
		StoryText.get_or("LBL_UNKNOWN", "?"), Ui.col("ink_muted")))
	side_box.add_child(_info_row("route", StoryText.get_or("LBL_LINKS", "Links"), str(_links_of(sid)), Ui.col("ink")))
	if Systems.ids().has(sid):
		_build_permit_card(sid)
		return
	var b := Button.new()
	b.text = StoryText.get_or("BTN_OPEN_SYSTEM", "Open system")
	b.disabled = true
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_box.add_child(b)
	side_box.add_child(_wrapped(StoryText.get_or("LBL_OPEN_REASON", "Systems open with a permit or a skill."), "LabelSmall"))

## The permit window part of a closed system's card: why, price, reason it cannot be bought yet, and the Buy permit button.
## This is the only place a permit is bought.
func _build_permit_card(sid: int) -> void:
	var v: Dictionary = main.can_buy_permit(sid)
	side_box.add_child(_caption(StoryText.get_or("PERMIT_WHY_TITLE", "Permit")))
	side_box.add_child(_wrapped(StoryText.get_or("PERMIT_WHY", "A permit is the right to route in a closed system. Without one the company cannot trade there."), "LabelSmall"))
	if v["reason"] == "skill":
		side_box.add_child(_wrapped(StoryText.get_or("PERMIT_WHY_LOCKED", "Learn Permit Charter in the Skills window first."), "LabelSmall"))
	var cost_l := _wrapped(StoryText.get_or("PERMIT_COST_LINE", "Cost: {credits} credits and {points} skill points.",
		{"credits": main.permit_cost(sid), "points": main.permit_points(sid)}), "LabelSmall")
	side_box.add_child(cost_l)
	var short: int = main.permit_points(sid) - main.permit_points_spent(sid)
	if short > 0:
		side_box.add_child(_wrapped(StoryText.get_or("PERMIT_POINTS_SHORT", "Short {short} skill points: pays {points} points and {credits} credits in all.",
			{"short": short, "points": main.permit_points_spent(sid), "credits": main.permit_total_cost(sid)}), "LabelSmall"))
	var reason := ""
	match v["reason"]:
		"skill":
			reason = StoryText.get_or("PERMIT_NEEDS_C1", "Needs Permit Charter.")
		"credits":
			reason = StoryText.get_or("PERMIT_NO_CREDITS", "Not enough credits.")
	if reason != "":
		side_box.add_child(_wrapped(reason, "LabelSmall"))
	var btn := Button.new()
	btn.theme_type_variation = "ButtonPrimary"
	btn.text = StoryText.get_text(str(Systems.get_system(sid).get("permit_btn_id", "")))
	btn.disabled = not v["ok"]
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if reason != "":
		btn.tooltip_text = reason
	btn.pressed.connect(func():
		main.buy_permit(sid)
		_rebuild_all())
	permit_button = btn
	side_box.add_child(btn)

## Selects a system and shows its card (the 3D view opens the card of a locked system this way).
func select_system(sid: int) -> void:
	selected_sys = sid
	_build_side()
	queue_redraw()

func _info_row(icon_token: String, label: String, value: String, value_col: Color) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(_icon_rect(icon_token, 16.0, Ui.col("ink_muted")))
	var l := Label.new()
	l.text = label
	l.theme_type_variation = "LabelSmall"
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	var v := Label.new()
	v.text = value
	v.theme_type_variation = "LabelNumber"
	v.add_theme_color_override("font_color", value_col)
	row.add_child(v)
	return row

func _tile(caption: String, value: String, col: Color) -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var k := Label.new()
	k.text = caption
	k.theme_type_variation = "LabelSmall"
	v.add_child(k)
	var n := Label.new()
	n.text = value
	n.theme_type_variation = "LabelNumber"
	n.add_theme_color_override("font_color", col)
	v.add_child(n)
	return v

func _build_open_side(sid: int) -> void:
	var data := _system_data(sid)
	var how := StoryText.get_or("LBL_SYS_FIRST", "Your first system.") if sid == 1 else StoryText.get_or("LBL_SYS_PERMIT", "Opened with a permit.")
	side_box.add_child(_head_row(Systems.name_of(sid), StoryText.get_or("LBL_SYSTEM_N", "System {n} · {how}", {"n": sid, "how": how})))
	if sid != 1 and Systems.ids().has(sid):
		side_box.add_child(_wrapped(StoryText.get_or("LBL_PERMIT_OPEN", "Permit held: open."), "LabelSmall"))
	var tiles := HBoxContainer.new()
	tiles.add_theme_constant_override("separation", 8)
	tiles.add_child(_tile(StoryText.get_or("LBL_GALAXY_ROUTES", "Routes"), str((data["lanes"] as Array).size()), Ui.col("ink")))
	tiles.add_child(_tile(StoryText.get_or("LBL_GALAXY_SHIPS", "Ships"), str(data["ships"]), Ui.col("ink")))
	tiles.add_child(_tile(StoryText.get_or("LBL_PER_CYCLE", "Per cycle"), _signed(int(data["net"])), _net_color(int(data["net"]))))
	side_box.add_child(tiles)
	# planets: what each makes. The game has no per-cycle output figure, so only the good is shown.
	side_box.add_child(_caption(StoryText.get_or("LBL_GALAXY_PLANETS_WORD", "Planets")))
	for i in data["planets"]:
		var p: Dictionary = main.map.planets[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var disc := Disc.new()
		var cc := Ui.commodity_col(str(p.get("abundant", "")))
		disc.color = (cc if cc != Color.WHITE else Ui.col("ink_muted")).darkened(0.35)
		disc.tex = _thumb(str(p.get("type", "")))
		row.add_child(disc)
		var nm := Label.new()
		nm.text = main.planet_name(int(i))  # T180
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(nm)
		var comm := str(p.get("abundant", ""))
		if comm != "" and not Availability.good(comm):
			pass  # hidden good: the row shows the planet name only
		elif comm != "":
			row.add_child(_icon_rect(comm, 16.0, Ui.commodity_col(comm)))
			var cl := Label.new()
			cl.text = Ui.good_name(comm)
			cl.theme_type_variation = "LabelSmall"
			row.add_child(cl)
		else:
			var bl := Label.new()
			bl.text = StoryText.get_or("LBL_BUYS_GOODS", "Buys goods")
			bl.theme_type_variation = "LabelSmall"
			row.add_child(bl)
		side_box.add_child(row)
	side_box.add_child(_caption(StoryText.get_or("LBL_YOUR_ROUTES_HERE", "Your routes here")))
	if (data["lanes"] as Array).is_empty():
		side_box.add_child(_wrapped(StoryText.get_or("LBL_NO_ROUTES", "No routes yet."), "LabelSmall"))
	for ln in data["lanes"]:
		var row2 := HBoxContainer.new()
		row2.add_theme_constant_override("separation", 8)
		var cc2 := Ui.commodity_col(str(ln["c"]))
		row2.add_child(_icon_rect(str(ln["c"]), 16.0, cc2 if cc2 != Color.WHITE else Ui.col("ink")))
		var rl := Label.new()
		rl.text = StoryText.get_or("LBL_A_TO_B", "{a} to {b}", {"a": main.planet_name(int(ln["a"])), "b": main.planet_name(int(ln["b"]))})
		rl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rl.clip_text = true
		row2.add_child(rl)
		var nl := Label.new()
		nl.theme_type_variation = "LabelNumber"
		var st := str(ln["status"])
		if st == "running":
			nl.text = _signed(int(ln["net"]))
			nl.add_theme_color_override("font_color", _net_color(int(ln["net"])))
		elif st == "stalled":
			nl.text = StoryText.get_or("LBL_WAITING_SHORT", "Waiting")
			nl.add_theme_color_override("font_color", Ui.col("signal_warn"))
		else:
			nl.text = StoryText.get_or("LBL_BLOCKED_SHORT", "Blocked")
			nl.add_theme_color_override("font_color", Ui.col("signal_bad"))
		row2.add_child(nl)
		side_box.add_child(row2)
	# Space Storage status
	var ss := HBoxContainer.new()
	ss.add_theme_constant_override("separation", 8)
	ss.add_child(_icon_rect("storage", 16.0, Ui.col("ink_subtle")))
	var ssl := Label.new()
	ssl.text = StoryText.get_or("SS_POST_NAME", "Space Storage")
	ssl.theme_type_variation = "LabelSmall"
	ssl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ss.add_child(ssl)
	var ssv := Label.new()
	ssv.theme_type_variation = "LabelSmall"
	ssv.text = StoryText.get_or("LBL_SS_OPEN", "Open") if main.space_post_open(sid) else StoryText.get_or("LBL_SS_LOCKED", "Locked · permit or skill")
	ss.add_child(ssv)
	side_box.add_child(ss)
	var b := Ui.primary_button(StoryText.get_or("BTN_OPEN_SYSTEM", "Open system"), "chevron")
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(func(): system_chosen.emit(sid))
	side_box.add_child(b)

# ---------------------------------------------------------------- tutorial card (shown once, beside its target)

func _tut_system_k() -> int:
	var ids := _sys_ids()
	for k in ids.size():
		if main.open_systems.has(ids[k]):
			return k
	return -1

## Screen rect the current step is about: INTRO the first open system, ICONS its resource icons, ROUTES a route line
## (the system again when there is none).
func _tut_target() -> Rect2:
	var k := _tut_system_k()
	if k < 0:
		return Rect2()
	var c := _sys_center(k)
	var R := _sys_radius() * 0.85
	var sys_rect := Rect2(c - Vector2(R, R * 0.8), Vector2(R, R * 0.8) * 2.0)
	var sid: int = _sys_ids()[k]
	var layout := _planet_layout()
	if tut_step == 1:
		var box := Rect2()
		var have := false
		for i in _system_data(sid)["planets"]:
			if not layout.has(i) or str(main.map.planets[i].get("abundant", "")) == "":
				continue
			var r := Rect2((layout[i]["pos"] as Vector2) + Vector2(5, -19), Vector2(13, 13))
			box = r if not have else box.merge(r)
			have = true
		if have:
			return box.grow(6.0)
	elif tut_step == 2:
		var s := _scale()
		for sid2 in _sys_ids():
			if not main.open_systems.has(sid2):
				continue
			var lanes: Array = _system_data(sid2)["lanes"]
			for n in lanes.size():
				var ln: Dictionary = lanes[n]
				if not layout.has(ln["a"]) or not layout.has(ln["b"]):
					continue
				if int(main.map.planets[ln["a"]].get("system", 1)) != sid2:
					continue
				var cv := _lane_curve(ln, layout, n, s)
				var lo: Vector2 = cv[0]
				var hi: Vector2 = cv[0]
				for u in 17:
					var p := _bez(cv[0], cv[1], cv[2], float(u) / 16.0)
					lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
					hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
				return Rect2(lo, hi - lo).grow(10.0)
	return sys_rect

## Called every frame while the card shows, so it follows a resized window: card beside the target, outline, pointer.
func _tut_place() -> void:
	var a := _tut_target()
	tut_hl.visible = a.size != Vector2.ZERO
	tut_arrow.visible = false
	tut_panel.size = Vector2(main.TUT_CARD_W, 0.0)  # height shrinks to what the text needs
	if a.size == Vector2.ZERO:
		tut_panel.position = Vector2((size.x - tut_panel.size.x) * 0.5, 84.0)
		return
	var k := 0.5 + 0.5 * sin(_clock * 4.0)
	tut_hl.position = a.position
	tut_hl.size = a.size
	tut_hl.modulate.a = lerpf(0.55, 1.0, k)
	var avoid: Array = [a]
	if side.visible:
		avoid.append(Rect2(side.position, side.size).grow(4.0))
	avoid.append(Rect2(close_button.position, close_button.size).grow(4.0))
	main.tut_place_beside(tut_panel, tut_arrow, a, avoid, a.get_center(), ["right", "left", "below", "above"])

func _build_tutorial() -> void:
	for c in tut_box.get_children():
		tut_box.remove_child(c)
		c.queue_free()
	tut_panel.visible = tut_step >= 0 and tut_step < TUT_IDS.size()  # the finished state shows nothing
	if tut_panel.visible:
		if _voiced_step != tut_step:  # the panel rebuilds often; speak a step once
			_voiced_step = tut_step
			Voice.play(TUT_IDS[tut_step] + "_WHY")  # the heading is on screen; only the why line is spoken
	else:
		_voiced_step = -1
		Voice.stop_prefix("TUT_")
	if not tut_panel.visible:
		tut_hl.visible = false
		tut_arrow.visible = false
		return
	var head := HBoxContainer.new()
	var cap := _caption(StoryText.get_or("TUT_HEADER", "Tutorial"))
	cap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(cap)
	var cnt := Label.new()
	cnt.theme_type_variation = "LabelNumberMuted"
	cnt.text = StoryText.get_or("TUT_STEP_COUNT", "{n} of {total}", {"n": tut_step + 1, "total": TUT_IDS.size()})
	head.add_child(cnt)
	tut_box.add_child(head)
	var t := Label.new()
	t.text = StoryText.get_or(TUT_IDS[tut_step], "", {})
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tut_box.add_child(t)
	var why := StoryText.get_or(TUT_IDS[tut_step] + "_WHY", "", {})
	if why != "":
		var w := Label.new()
		w.text = why
		w.theme_type_variation = "LabelMuted"
		w.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tut_box.add_child(w)
	var acts := HBoxContainer.new()
	acts.alignment = BoxContainer.ALIGNMENT_END
	acts.add_theme_constant_override("separation", 8)
	var skip := Button.new()
	skip.theme_type_variation = "ButtonGhost"
	skip.text = StoryText.get_or("BTN_SKIP_TUTORIAL", "Skip tutorial")
	skip.pressed.connect(func():
		tut_step = TUT_IDS.size()
		main._tut_skip()  # Skip ends the whole guided tutorial too
		_build_tutorial()
		queue_redraw())
	acts.add_child(skip)
	tut_box.add_child(acts)
	_tut_place()

# ---------------------------------------------------------------- input

func _hit_at(pos: Vector2) -> int:
	for h in _hit:
		var d: Vector2 = pos - (h["pos"] as Vector2)
		var r: float = float(h["r"])
		if bool(h["open"]):
			if (d.x / r) * (d.x / r) + (d.y / (r * 0.8)) * (d.y / (r * 0.8)) <= 1.05:
				return int(h["id"])
		elif d.length() <= r:
			return int(h["id"])
	return -1

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		tooltip_text = _link_tooltip(event.position)
		var hid := _hit_at(event.position)
		if hid != _hover_id:
			_hover_id = hid
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if hid >= 0 else Control.CURSOR_ARROW
			queue_redraw()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var id := _hit_at(event.position)
		if id >= 0:
			selected_sys = id
			if tut_step >= 0 and tut_step < TUT_IDS.size():  # each tutorial line moves on when a system is clicked
				tut_step += 1
				_build_tutorial()
			_build_side()
			queue_redraw()
			accept_event()

## Legend line sample: a short solid or dashed line.
class Swatch extends Control:
	var color: Color = Color.WHITE
	var dashed := false
	func _init() -> void:
		custom_minimum_size = Vector2(22, 8)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		var y := size.y * 0.5
		if dashed:
			draw_dashed_line(Vector2(0, y), Vector2(size.x, y), color, 1.5, 4.0)
		else:
			draw_line(Vector2(0, y), Vector2(size.x, y), color, 1.5)

## Round planet marker in the left panel.
class Disc extends Control:
	var color: Color = Color.WHITE
	var tex: Texture2D
	func _init() -> void:
		custom_minimum_size = Vector2(18, 18)
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		var c := size * 0.5
		if tex != null:
			draw_texture_rect(tex, Rect2(c - Vector2(8, 8), Vector2(16, 16)), false)
		else:
			draw_circle(c, 8.0, color)
		draw_arc(c, 8.5, 0.0, TAU, 24, Color(1, 1, 1, 0.22), 1.0, true)
