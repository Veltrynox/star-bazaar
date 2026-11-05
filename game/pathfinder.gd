extends RefCounted
## T179: the Pathfinder, the player's scout ship (design/proposals/2026-11-05-ship-flight-discovery.md). It is NOT one of the
## fleet ships (no cargo, no route, no ship_cap slot). It flies on the game clock, discovers planets by arriving, and builds
## a trading post (living world) or a mining platform (dead world). A planet is "established" when one of them stands; only
## established planets can be bought from, sold to, routed, ordered, sent to or stored on (Voltara is established at start).
##
## This object is the ACCESSOR the UI reads (see the interface doc at the top of game/pathfinder_view.gd). main.gd creates it,
## sets main.map.flight, feeds it the game clock (sync) and saves it under "pathfinder". Nothing here reads a number that has
## a key in data/balance.json: discovery_enabled, pathfinder_speed, pathfinder_jump_cycles, post_cost_ship_fraction,
## post_cost_system2_mult, platform_cost_post_mult, post_first_free, post_build_cycles, post_first_build_cycles,
## platform_build_cycles. While discovery_enabled is 0 (read live) every planet counts as established and nothing moves.
##
## UNVERIFIED BY EXECUTION when written (owner forbade runs).

const DeadWorlds := preload("res://game/dead_worlds.gd")
const Ships := preload("res://game/ships.gd")

signal arrived(planet_id: String)         # the ship reached a planet (it is discovered now)
signal build_started(planet_id: String)
signal build_done(planet_id: String)      # a post or a platform stands now
signal build_cancelled(planet_id: String) # the ship left during a build: credits are not refunded

const PLATFORM_SKILL := "MIN_3"  # skill that allows a mining platform (proposal 1.4)
const DEFAULT_HOME := "planet_1"
const EPS := 0.0001

var main: Node = null
var _pos := Vector3.ZERO
var _sys := 1
var _state := "idle"            # idle | flying | building
var _target := {}               # {kind, pos, index} while flying, else {}
var _from := Vector3.ZERO
var _to := Vector3.ZERO
var _to_sys := 1
var _dur := 0.0                 # flight length in cycles
var _t := 0.0                   # cycles flown
var _docked := ""               # planet id the ship is at, "" in flight or in open space
var _build := ""                # planet id being built, "" none
var _build_total := 0.0
var _build_left := 0.0
var _discovered := {}           # planet id -> true
var _posts := {}                # planet id -> true
var _platforms := {}            # planet id -> true
var _legacy := false            # a save from before discovery: every planet counts as established
var _last_now := -1.0           # game time (cycles) of the last sync

func setup(m: Node) -> void:
	main = m
	reset()

## A new run: only the home world is open, the ship sits there.
func reset() -> void:
	_discovered = {}
	_posts = {}
	_platforms = {}
	_legacy = false
	_state = "idle"
	_target = {}
	_dur = 0.0
	_t = 0.0
	_build = ""
	_build_total = 0.0
	_build_left = 0.0
	_last_now = -1.0
	_sys = 1
	_docked = home_id()
	_ensure_home()
	var i := _index_of(_docked)
	_pos = _planet_pos(i) if i >= 0 else Vector3.ZERO

func home_id() -> String:
	var st = Availability.data().get("start_state", {})
	return str(st.get("planet", DEFAULT_HOME)) if typeof(st) == TYPE_DICTIONARY else DEFAULT_HOME

func _ensure_home() -> void:
	var h := home_id()
	_posts[h] = true
	_discovered[h] = true

# ---- helpers --------------------------------------------------------------------------------------------------------

func _bal(key: String, dflt: float) -> float:
	return float(main.balance.get(key, dflt)) if main != null else dflt

func _planets() -> Array:
	return main.map.planets if main != null and main.map != null else []

func _index_of(pid: String) -> int:
	var ps := _planets()
	for i in ps.size():
		if str(ps[i].get("id", "")) == pid:
			return i
	return -1

func _planet_pos(i: int) -> Vector3:
	var v: Vector3 = main.map.positions[i] if i >= 0 and i < main.map.positions.size() else Vector3.ZERO
	return Vector3(v.x, 0.0, v.z)

func _is_dead(pid: String) -> bool:
	var i := _index_of(pid)
	return i >= 0 and DeadWorlds.is_dead(_planets()[i])

func _speed_mult() -> float:
	return maxf(0.1, Ships.speed(Ships.fleet))

## World units per map unit of the data files (MAP_UNIT_SCALE x ORBIT_SCALE): the proposal's distances are data units.
func _world_per_map_unit() -> float:
	return main.map.MAP_UNIT_SCALE * main.map.ORBIT_SCALE

func _flight_cycles(from: Vector3, to: Vector3, to_sys: int) -> float:
	var spd := _speed_mult()
	if to_sys != _sys:
		return maxf(0.05, _bal("pathfinder_jump_cycles", 2.0) / spd)
	var units := Vector2(to.x - from.x, to.z - from.z).length() / _world_per_map_unit()
	return units / maxf(1.0, _bal("pathfinder_speed", 400.0) * spd)

# ---- accessor read by the UI (game/pathfinder_view.gd) ---------------------------------------------------------------

func is_enabled() -> bool:
	return main != null and is_instance_valid(main) and _bal("discovery_enabled", 0.0) >= 0.5

func state() -> String:
	return _state

func ship_position() -> Vector3:
	return _pos

func system_id() -> int:
	return _sys

func target() -> Dictionary:
	return _target.duplicate()

func is_paused() -> bool:
	return main != null and bool(main.paused)

func model_path() -> String:
	return Ships.model(Ships.fleet)

func discovered(pid: String) -> bool:
	if not is_enabled() or _legacy:
		return true
	return _discovered.has(pid) or _posts.has(pid) or _platforms.has(pid)

func post_built(pid: String) -> bool:
	if not is_enabled():
		return true
	return _posts.has(pid) or (_legacy and not _is_dead(pid))

func platform_built(pid: String) -> bool:
	if not is_enabled():
		return true
	return _platforms.has(pid) or (_legacy and _is_dead(pid))

func established(pid: String) -> bool:
	return post_built(pid) or platform_built(pid)

func docked_at() -> String:
	return _docked

func build_target() -> String:
	return _build

func build_progress() -> float:
	return clampf(1.0 - _build_left / _build_total, 0.0, 1.0) if _build != "" and _build_total > 0.0 else 0.0

func build_cycles_left() -> float:
	return _build_left if _build != "" else 0.0

func can_platform(pid: String) -> bool:
	return _is_dead(pid) and Skills.is_learned(PLATFORM_SKILL)

## Number of living-world posts beyond the home world (the first one is free).
func extra_posts() -> int:
	var n := 0
	for k in _posts:
		if str(k) != home_id():
			n += 1
	return n

## {"cash": int, "cycles": float, "free": bool} of a post (living world) or platform (dead world) at that planet.
func cost(pid: String) -> Dictionary:
	var base := float(main.balance.get("ship_price", 900)) * _bal("post_cost_ship_fraction", 0.4)
	var i := _index_of(pid)
	if i >= 0 and main.system_of(i) > 1:
		base *= _bal("post_cost_system2_mult", 1.5)
	if _is_dead(pid):
		return {"cash": int(round(base * _bal("platform_cost_post_mult", 2.0))), "cycles": _bal("platform_build_cycles", 3.0), "free": false}
	var first := extra_posts() == 0
	var is_free := first and _bal("post_first_free", 1.0) >= 0.5
	var cycles := _bal("post_first_build_cycles", 1.0) if first else _bal("post_build_cycles", 2.0)
	return {"cash": 0 if is_free else int(round(base)), "cycles": cycles, "free": is_free}

## Flight time in cycles from where the ship is now to a planet; < 0 when it cannot go (no permit for that system).
func eta_cycles(pid: String) -> float:
	if not is_enabled():
		return -1.0
	var i := _index_of(pid)
	if i < 0:
		return -1.0
	var tsys: int = main.system_of(i)
	if tsys != _sys and not main.open_systems.has(tsys):
		return -1.0
	if _docked == pid:
		return 0.0
	return _flight_cycles(_pos, _planet_pos(i), tsys)

# ---- orders ----------------------------------------------------------------------------------------------------------

## Starts or redirects the flight. "" = accepted; "no_gate" = the other system has no permit; "bad_target" = unknown target.
## Leaving a planet during a build cancels it (build_cancelled), credits are not refunded.
func request_fly(t: Dictionary) -> String:
	if not is_enabled():
		return ""
	var kind := str(t.get("kind", "point"))
	var to := Vector3.ZERO
	var to_sys := _sys
	var idx := int(t.get("index", -1))
	var pid := ""
	match kind:
		"planet":
			if idx < 0 or idx >= _planets().size():
				return "bad_target"
			pid = str(_planets()[idx].get("id", ""))
			to = _planet_pos(idx)
			to_sys = main.system_of(idx)
		"storage":
			to_sys = idx if idx > 0 else _sys
			to = t.get("pos", _pos)
		"cluster":
			to = t.get("pos", _pos)
			if main.clusters != null and main.clusters.valid(idx):
				to_sys = main.clusters.system_of(idx)
		_:
			kind = "point"
			to = t.get("pos", _pos)
	to = Vector3(to.x, 0.0, to.z)
	if to_sys != _sys and not main.open_systems.has(to_sys):
		return "no_gate"
	if _state == "building" and kind == "planet" and pid == _build:
		return ""  # already there, building: nothing to do
	if _state == "idle" and kind == "planet" and pid == _docked:
		return ""
	if _state == "building":
		_cancel_build()
	_from = _pos
	_to = to
	_to_sys = to_sys
	_dur = _flight_cycles(_pos, to, to_sys)
	_t = 0.0
	_docked = ""
	_target = {"kind": kind, "pos": to, "index": idx if kind != "point" else -1}
	_state = "flying"
	if _dur <= EPS:
		_arrive()
	return ""

## Starts the build at the planet the ship is docked at. "" accepted; "fly_first" | "no_cash_post" | "no_cash_platform" | "busy";
## "no_skill" (platform without MIN_3, no notice defined) and "bad_target" otherwise.
func request_establish(pid: String) -> String:
	if not is_enabled():
		return ""
	if _index_of(pid) < 0:
		return "bad_target"
	if _state == "building":
		return "busy"
	if _docked != pid or _state != "idle":
		return "fly_first"
	if established(pid):
		return ""
	var dead := _is_dead(pid)
	if dead and not can_platform(pid):
		return "no_skill"
	var c := cost(pid)
	if int(main.cash) < int(c["cash"]):
		return "no_cash_platform" if dead else "no_cash_post"
	main.cash -= int(c["cash"])
	_build = pid
	_build_total = maxf(EPS, float(c["cycles"]))
	_build_left = _build_total
	_state = "building"
	_target = {}
	build_started.emit(pid)
	main.on_flight_changed()
	return ""

func _cancel_build() -> void:
	var pid := _build
	_build = ""
	_build_total = 0.0
	_build_left = 0.0
	_state = "idle"
	if pid != "":
		build_cancelled.emit(pid)

# ---- the clock -------------------------------------------------------------------------------------------------------

## Game time in cycles (main.game_time()). Moves the ship by the time passed since the last call. Time that does not pass
## (pause, event window) moves nothing. A jump backwards (reset) only re-bases.
func sync(now: float) -> void:
	if _last_now < 0.0:
		_last_now = now
		return
	var dt := now - _last_now
	_last_now = now
	if dt > 0.0 and is_enabled():
		advance(dt)

## Re-bases the clock (after a load or a reset of the cycle) without moving anything.
func resync(now: float) -> void:
	_last_now = now

func advance(cycles: float) -> void:
	var left := cycles
	var guard := 0
	while left > 0.0 and guard < 16:
		guard += 1
		if _state == "flying":
			var rem := _dur - _t
			if left >= rem:
				left -= rem
				_arrive()
			else:
				_t += left
				left = 0.0
				_pos = _from.lerp(_to, _t / maxf(_dur, EPS))
		elif _state == "building":
			if left >= _build_left:
				left -= _build_left
				_finish_build()
			else:
				_build_left -= left
				left = 0.0
		else:
			break

func _arrive() -> void:
	_pos = _to
	_sys = _to_sys
	_state = "idle"
	var tgt := _target
	_target = {}
	_t = 0.0
	_dur = 0.0
	_docked = ""
	if str(tgt.get("kind", "")) == "planet":
		var idx := int(tgt.get("index", -1))
		if idx >= 0 and idx < _planets().size():
			var pid := str(_planets()[idx].get("id", ""))
			_docked = pid
			var first := not _discovered.has(pid)
			_discovered[pid] = true
			arrived.emit(pid)
			if first:
				main.on_flight_changed()

func _finish_build() -> void:
	var pid := _build
	_build = ""
	_build_total = 0.0
	_build_left = 0.0
	_state = "idle"
	if pid == "":
		return
	if _is_dead(pid):
		_platforms[pid] = true
	else:
		_posts[pid] = true
	_discovered[pid] = true
	build_done.emit(pid)
	main.on_flight_changed()

# ---- debug and QA ----------------------------------------------------------------------------------------------------

## Finishes the flight at once (main.debug_* guards it by the debug flag).
func finish_flight() -> void:
	if _state == "flying":
		advance(maxf(0.0, _dur - _t) + EPS)

func finish_build() -> void:
	if _state == "building":
		advance(_build_left + EPS)

## Sets one flag: kind = "visited" | "post" | "platform". Used by tests and the debug flag (calls on_flight_changed).
func set_flag(kind: String, pid: String, on: bool) -> void:
	var d := _discovered if kind == "visited" else (_posts if kind == "post" else _platforms)
	if on:
		d[pid] = true
		if kind != "visited":
			_discovered[pid] = true
	else:
		d.erase(pid)
		if kind == "visited":
			_posts.erase(pid)
			_platforms.erase(pid)
	if main != null and main.has_method("on_flight_changed"):
		main.on_flight_changed()

func open_all() -> void:
	for p in _planets():
		var pid := str(p.get("id", ""))
		_discovered[pid] = true
		if DeadWorlds.is_dead(p):
			_platforms[pid] = true
		else:
			_posts[pid] = true
	main.on_flight_changed()

# ---- save ------------------------------------------------------------------------------------------------------------

static func _v(v: Vector3) -> Array:
	return [v.x, v.y, v.z]

static func _vec(a, dflt: Vector3 = Vector3.ZERO) -> Vector3:
	if typeof(a) == TYPE_ARRAY and a.size() >= 3:
		return Vector3(float(a[0]), float(a[1]), float(a[2]))
	return dflt

func to_dict() -> Dictionary:
	var tgt := {}
	if not _target.is_empty():
		tgt = {"kind": str(_target.get("kind", "point")), "pos": _v(_target.get("pos", Vector3.ZERO)), "index": int(_target.get("index", -1))}
	return {"pos": _v(_pos), "sys": _sys, "state": _state, "target": tgt, "from": _v(_from), "to": _v(_to), "to_sys": _to_sys,
		"dur": _dur, "t": _t, "docked": _docked, "build": _build, "build_total": _build_total, "build_left": _build_left,
		"discovered": _discovered.keys(), "posts": _posts.keys(), "platforms": _platforms.keys(), "legacy": _legacy}

## A missing or bad dictionary (a save from before discovery) opens every planet, so an old run keeps working.
func from_dict(d) -> void:
	reset()
	if typeof(d) != TYPE_DICTIONARY:
		_legacy = true
		return
	_legacy = bool(d.get("legacy", false))
	for k in d.get("discovered", []):
		_discovered[str(k)] = true
	for k in d.get("posts", []):
		_posts[str(k)] = true
	for k in d.get("platforms", []):
		_platforms[str(k)] = true
	_sys = maxi(1, int(d.get("sys", 1)))
	_pos = _vec(d.get("pos"), _pos)
	_docked = str(d.get("docked", ""))
	_state = "idle"
	_target = {}
	var st := str(d.get("state", "idle"))
	if st == "flying" and typeof(d.get("target")) == TYPE_DICTIONARY and not d["target"].is_empty() and float(d.get("dur", 0.0)) > 0.0:
		var t: Dictionary = d["target"]
		_target = {"kind": str(t.get("kind", "point")), "pos": _vec(t.get("pos")), "index": int(t.get("index", -1))}
		_from = _vec(d.get("from"), _pos)
		_to = _vec(d.get("to"), _target["pos"])
		_to_sys = maxi(1, int(d.get("to_sys", _sys)))
		_dur = float(d["dur"])
		_t = clampf(float(d.get("t", 0.0)), 0.0, _dur)
		_state = "flying"
	elif st == "building" and str(d.get("build", "")) != "" and _index_of(str(d["build"])) >= 0 and float(d.get("build_total", 0.0)) > 0.0:
		_build = str(d["build"])
		_build_total = float(d["build_total"])
		_build_left = clampf(float(d.get("build_left", _build_total)), 0.0, _build_total)
		_state = "building"
		_docked = _build
	_ensure_home()
