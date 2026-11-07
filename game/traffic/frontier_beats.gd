extends Control
## T300: the frontier and finale beats (design/proposals/2026-11-06-empire-growth-v2.md 3.4 Juice and 4). Visual only, reads state, never changes it.
##   raid(a, b, nest)   raiders dart in from the nest side to the hit lane, a flash and ring on the hit point, pods tumble out, raiders leave.
##   scoop(at)          pods zip from around the Flagship into it.
##   opening(capital)   the system's ships converge on the capital, the ring round it lights segment by segment, then a short screen flash.
## Ships are free ships of the map's traffic layer (keys "fx_*", cleared when the beat ends); flashes and rings are drawn here in screen
## space. The node ignores the mouse, so it never blocks a click. Beats advance on the game clock (frozen while paused, scaled by the
## chosen speed) and all lengths and counts are balance beat_* keys (placeholders); Juice.motion scales them, 0 switches the beats off.
## The ship timeline is set up front (targets and a clear time), so the node does no per-frame work while no beat runs.

const Juice := preload("res://game/juice.gd")
const LIFT := 0.35

var map: Node = null   # game/map.gd
var _fx: Array = []    # {kind, t, dur, ...}
var _uid := 0

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_process(false)

func _k(key: String, fallback: float) -> float:
	var p = map.prosperity if map != null else null
	return float(p.balance.get(key, fallback)) if p != null else fallback

func _on() -> bool:
	return map != null and map.traffic != null and Juice.motion > 0.0

func _p2(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)

func _add(fx: Dictionary) -> void:
	_fx.append(fx)
	set_process(true)

## Pure: the 0..1 progress of segment `n` of `total` at overall progress u (segments light one after another over the first 70 percent).
static func segment_lit(u: float, n: int, total: int) -> float:
	var span := 0.7 / float(maxi(total, 1))
	return clampf((u - span * float(n)) / span, 0.0, 1.0)

# ---- raid ------------------------------------------------------------------------------------------------------------

## a, b: world positions of the lane's ends; nest: world position of the raiding world; pods: where the pods were dropped (INF = none).
func raid(a: Vector3, b: Vector3, nest: Vector3, pods: Vector3) -> void:
	if not _on():
		return
	_uid += 1
	var hit := a.lerp(b, 0.35)
	hit.y = LIFT
	var away := Vector3(nest.x - hit.x, 0.0, nest.z - hit.z)
	if away.length() < 0.1:
		away = Vector3(1, 0, 0)
	away = away.normalized() * _k("beat_raid_dist", 1.6)
	var n := clampi(roundi(_k("beat_raid_raiders", 3.0)), 1, 6)
	var dur := _k("beat_raid_seconds", 2.2) * Juice.motion
	var keys: Array = []
	for i in n:
		var side := Vector3(-away.z, 0.0, away.x).normalized() * (float(i) - float(n - 1) * 0.5) * 0.18
		var key := "fx_raid_%d_%d" % [_uid, i]
		keys.append(key)
		map.traffic.set_free_ship(key, _p2(hit + away + side), _p2(hit + side * 0.5), "pirate", Color.TRANSPARENT, LIFT, 1.0)
	_add({"kind": "raid", "t": 0.0, "dur": dur, "keys": keys, "hit": hit, "away": away, "side": 0.0, "fired": false, "pods": pods,
		"pod_keys": [], "uid": _uid, "n": n})

func _raid_step(f: Dictionary, u: float) -> void:
	if not bool(f["fired"]) and u >= 0.4:  # the raiders have arrived: flash, nudge, pods tumble out, raiders turn away
		f["fired"] = true
		Juice.play_tone(map, "raid")
		map.nudge_camera()
		var at: Vector3 = f["pods"] if (f["pods"] as Vector3).is_finite() else f["hit"]
		var pk: Array = []
		var pod_scale := _k("beat_pod_scale", 0.4)
		for i in 4:
			var ang := float(i) * 1.7 + float(f["uid"])
			var key := "fx_raidpod_%d_%d" % [int(f["uid"]), i]
			pk.append(key)
			var from: Vector3 = f["hit"]
			map.traffic.set_free_ship(key, _p2(from), _p2(from), "corvette", Ui.col("star_warm"), LIFT, pod_scale)
			map.traffic.set_free_ship(key, _p2(from), _p2(from) + Vector2(cos(ang), sin(ang)) * (0.35 + 0.1 * float(i % 2)) + _p2(at - from) * 0.25, "corvette", Ui.col("star_warm"), LIFT, pod_scale)
		f["pod_keys"] = pk
		var k := 0
		for key in f["keys"]:
			k += 1
			var tgt := _p2(f["hit"]) + _p2(f["away"]) * 1.2 + Vector2(0, float(k) * 0.1)
			map.traffic.set_free_ship(key, _p2(f["hit"]), tgt, "pirate", Color.TRANSPARENT, LIFT, 1.0)

# ---- salvage scoop ---------------------------------------------------------------------------------------------------

## at: world position of the Flagship. Pods start on a ring round it and fly in.
func scoop(at: Vector3) -> void:
	if not _on():
		return
	_uid += 1
	var n := clampi(roundi(_k("beat_scoop_pods", 4.0)), 1, 8)
	var keys: Array = []
	var pod_scale := _k("beat_pod_scale", 0.4)
	for i in n:
		var ang := TAU * float(i) / float(n) + float(_uid)
		var key := "fx_scoop_%d_%d" % [_uid, i]
		keys.append(key)
		var from := _p2(at) + Vector2(cos(ang), sin(ang)) * 0.6
		map.traffic.set_free_ship(key, from, _p2(at), "corvette", Ui.col("star_warm"), LIFT, pod_scale)
	Juice.play_tone(map, "scoop")
	_add({"kind": "scoop", "t": 0.0, "dur": _k("beat_scoop_seconds", 1.2) * Juice.motion, "keys": keys, "at": at})

# ---- opening ---------------------------------------------------------------------------------------------------------

## i: planet index of the capital. Every other world in view sends ships to it, then the ring lights and the screen flashes.
func opening(i: int) -> void:
	if not _on() or i < 0 or i >= map.positions.size():
		return
	_uid += 1
	var keys: Array = []
	if map.planet_in_view(i):
		var per := clampi(roundi(_k("beat_opening_ships", 2.0)), 1, 4)
		for j in map.positions.size():
			if j == i or not map.planet_in_view(j):
				continue
			for s in per:
				var key := "fx_open_%d_%d_%d" % [_uid, j, s]
				keys.append(key)
				var off := Vector2(float(s) * 0.12, float(s) * -0.08)
				map.traffic.set_free_ship(key, _p2(map.positions[j]) + off, _p2(map.positions[i]) + off * 0.3, "corvette", Ui.col("star_warm"), LIFT, 0.8)
	Juice.play_tone(map, "opening")
	_add({"kind": "opening", "t": 0.0, "dur": _k("beat_opening_seconds", 3.2) * Juice.motion, "keys": keys, "planet": i})

# ---- clock and drawing -----------------------------------------------------------------------------------------------

func _process(delta: float) -> void:
	if map == null or not map._game_running():
		return
	var g = map.traffic._find_game() if map.traffic != null else null
	var dt := delta * (float(g.time_speed) if g != null and "time_speed" in g else 1.0)
	var keep: Array = []
	for f in _fx:
		f["t"] = float(f["t"]) + dt
		var u := clampf(float(f["t"]) / maxf(0.001, float(f["dur"])), 0.0, 1.0)
		if f["kind"] == "raid":
			_raid_step(f, u)
		if u >= 1.0 or Juice.motion <= 0.0:
			_end(f)
		else:
			keep.append(f)
	_fx = keep
	queue_redraw()
	if _fx.is_empty():
		set_process(false)

func _end(f: Dictionary) -> void:
	if map == null or map.traffic == null:
		return
	for key in f["keys"]:
		map.traffic.clear_group(key)
	for key in f.get("pod_keys", []):
		map.traffic.clear_group(key)

func _draw() -> void:
	if map == null or map.camera == null:
		return
	var warm := Ui.col("star_warm")
	var scale_px := get_viewport_rect().size.y / 941.0
	for f in _fx:
		var u := clampf(float(f["t"]) / maxf(0.001, float(f["dur"])), 0.0, 1.0)
		match str(f["kind"]):
			"raid":
				if u >= 0.4 and not map.camera.is_position_behind(f["hit"]):
					var w := (u - 0.4) / 0.6
					var c: Vector2 = map.camera.unproject_position(f["hit"])
					var red := Ui.col("signal_bad")
					draw_circle(c, _k("beat_raid_flash_px", 70.0) * scale_px * 0.35, Color(1.0, 0.9, 0.85, clampf(1.0 - w * 5.0, 0.0, 1.0) * 0.8))
					draw_arc(c, lerpf(6.0, _k("beat_raid_flash_px", 70.0) * scale_px, 1.0 - pow(1.0 - w, 2.0)), 0.0, TAU, 48, Color(red, (1.0 - w) * 0.9), 3.0, true)
			"opening":
				_draw_opening(f, u, warm, scale_px)

func _draw_opening(f: Dictionary, u: float, warm: Color, scale_px: float) -> void:
	var i := int(f["planet"])
	var total := clampi(roundi(_k("beat_opening_segments", 12.0)), 3, 48)
	if map.planet_in_view(i) and not map.camera.is_position_behind(map.positions[i]):
		var c: Vector2 = map.camera.unproject_position(map.positions[i])
		var right: Vector3 = map.camera.global_transform.basis.x.normalized()
		var r_px := c.distance_to(map.camera.unproject_position(map.positions[i] + right * map.planet_radius(i) * map.PLANET_VISIBLE / map.PLANET_RADIUS))
		var rr := r_px + _k("beat_opening_ring_px", 34.0) * scale_px
		var gap := 0.06
		var fade := 1.0 - clampf((u - 0.9) / 0.1, 0.0, 1.0)
		for n in total:
			var a0 := -PI * 0.5 + TAU * float(n) / float(total) + gap
			var a1 := -PI * 0.5 + TAU * float(n + 1) / float(total) - gap
			var lit := segment_lit(u, n, total)
			var col := Color(0.5, 0.45, 0.35, 0.25 * fade)
			if lit > 0.0:
				col = Color(warm.lerp(Color.WHITE, 1.0 - lit), (0.5 + 0.5 * lit) * fade)
			draw_arc(c, rr, a0, a1, 8, col, (3.0 + 3.0 * lit) * scale_px, true)
	var flash_s := maxf(0.05, _k("beat_opening_flash_seconds", 0.5) * Juice.motion)
	var t_flash: float = float(f["t"]) - float(f["dur"]) * 0.7  # the flash fires as the last segment lights
	if t_flash >= 0.0 and t_flash < flash_s:
		draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 0.95, 0.8, (1.0 - t_flash / flash_s) * _k("beat_opening_flash_alpha", 0.55)))
