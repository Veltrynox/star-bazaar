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
## FLIGHT TO ANOTHER SYSTEM runs in three legs, so the ship leaves along the line that points at that system:
##   "out"  : a normal in-system flight (_fly) to SystemGeometry.exit_point(_sys, to_sys), the same point the exit marker draws;
##   "jump" : a timed phase of pathfinder_jump_cycles (not divided by the fleet speed) in neither system. jumping() is true,
##            state() stays "flying", system_id() is the OLD system and ship_position() stays at the old system's exit point
##            for the whole jump (the juice listens to jump_started / jump_ended for the visual). Boost burns no energy here;
##   "in"   : on jump end the ship appears at exit_point(to_sys, old_sys) in the new system (_sys = to_sys) and flies on to the
##            final target (dock point, storage, cluster or point). The arrival (_arrive) is the one of any flight.
## "direct" is an ordinary flight inside one system. leg() returns the name.
## Signals for the juice (connect on main.flight):
##   jump_started(from_sys: int, to_sys: int, pos: Vector3)  # the jump phase begins; pos = exit point in from_sys
##   jump_ended(sys: int, pos: Vector3)                      # the ship appears in sys at pos = entry point
## ETA (_flight_cycles for another system) = in-system leg 1 + pathfinder_jump_cycles + in-system leg 2 (entry point to target).
##
## UNVERIFIED BY EXECUTION when written (owner forbade runs).

const DeadWorlds := preload("res://game/dead_worlds.gd")
const Ships := preload("res://game/ships.gd")
const Motion := preload("res://game/ship_motion.gd")  # T196
const Geometry := preload("res://game/system_geometry.gd")  # exit points between systems (shared with system_exit.gd)
const Station := preload("res://game/station.gd")  # T202: MAP_RADIUS of the storage station

signal arrived(planet_id: String)         # the ship reached a planet (it is discovered now)
signal build_started(planet_id: String)
signal build_done(planet_id: String)      # a post or a platform stands now
signal build_cancelled(planet_id: String) # the ship left during a build: credits are not refunded
signal establish_failed(planet_id: String, reason: String) # T200: an order "fly there and establish" could not start on arrival
signal arrived_point(sys: int, pos: Vector3)  # T271: a flight to a point of open space ended (gig signal markers listen)
signal jump_started(from_sys: int, to_sys: int, pos: Vector3)  # leg "jump" begins at the exit point of from_sys
signal jump_ended(sys: int, pos: Vector3)  # the ship appears in sys at the entry point; the last leg starts
signal flight_aborted(reason: String, pos: Vector3)  # T374: the flight was ended on the spot (its target is gone); the ship holds position
signal exploration_done                   # T206: exploration mode finished: every planet of the system stands established; the mode is off

const PLATFORM_SKILL := "FND_PROSPECT"  # skill that allows a mining platform (Prospecting opens every dead world)
const DEFAULT_HOME := "planet_1"
const EPS := 0.0001
const SUBSTEP := 0.005          # cycles per integration step of a flight (0.3 s of game time)

var main: Node = null
var _pos := Vector3.ZERO
var _sys := 1
var _state := "idle"            # idle | flying | building
var _target := {}               # {kind, pos, index} while flying, else {}
var _from := Vector3.ZERO
var _to := Vector3.ZERO         # where the current leg ends (the exit point on leg "out", else the final target)
var _to_sys := 1                # system of the final target
var _leg := "direct"            # direct | out | jump | in (see the header)
var _final_to := Vector3.ZERO   # final target position while a cross-system flight is on its way
var _jump_from := 1             # system left by the jump
var _jump_t := 0.0              # cycles of the jump done
var _jump_dur := 0.0            # cycles the jump takes
var _dur := 0.0                 # flight length in cycles (estimate for an in-system flight, the jump time for a jump)
var _t := 0.0                   # cycles flown (a jump moves by it; an in-system flight is physics: speed, heading)
var _speed := 0.0               # T196: world units per cycle, ramps up from rest and brakes before the target
var _yaw := 0.0                 # T196: heading (atan2(-dx, -dz)), turns at pathfinder_turn_deg per cycle toward the course
var _docked := ""               # planet id the ship is at, "" in flight or in open space
var _build := ""                # planet id being built, "" none
var _auto := ""                 # T200: planet id to establish as soon as the ship arrives there, "" none
var _build_total := 0.0
var _build_left := 0.0
var _discovered := {}           # planet id -> true
var _posts := {}                # planet id -> true
var _platforms := {}            # planet id -> true
var _legacy := false            # a save from before discovery: every planet counts as established
var _last_now := -1.0           # game time (cycles) of the last sync
var _explore := false           # T206: exploration mode: the ship scouts and establishes every planet of its system by itself
var _hold := {}                 # T269 Flagship hold: good -> units (cap flagship_hold_units)
var _boost := false             # T269 boost on
var _charges := -1              # T269 boost charges left; -1 = full (read live from flagship_boost_charges)
var _refill_left := 0.0         # T269 cycles until the next charge comes back
var _burn_owed := 0.0           # T269 fraction of an energy unit burned but not yet taken from the hold
var _idle_left := 0.0           # T271: cycles the ship cannot take orders (a gig cost); runs on the game clock
var _self_order := false        # T206: true while the mode itself gives an order (a manual order ends the mode)

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
	_leg = "direct"
	_jump_t = 0.0
	_jump_dur = 0.0
	_speed = 0.0
	_yaw = 0.0
	_build = ""
	_auto = ""
	_explore = false
	_build_total = 0.0
	_build_left = 0.0
	_last_now = -1.0
	_hold = {}
	_boost = false
	_charges = -1
	_refill_left = 0.0
	_burn_owed = 0.0
	_idle_left = 0.0
	_sys = 1
	_docked = home_id()
	_ensure_home()
	var i := _index_of(_docked)
	_pos = _dock_pos(i, Vector3.ZERO) if i >= 0 else Vector3.ZERO

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

## T202: where the ship parks at planet i: Motion.SPAWN_GAP outside its drawn edge on the side of `from` (never the centre).
## `from` at the centre (new game, other system) gives the +Z side.
func _dock_pos(i: int, from: Vector3) -> Vector3:
	var c := _planet_pos(i)
	var f := c if from == Vector3.ZERO else from
	var sys: int = main.system_of(i)
	var p: Vector2 = main.map.dock_point(Vector2(c.x, c.z), main.map.planet_radius(i), Vector2(f.x, f.z), sys)
	return Vector3(p.x, 0.0, p.y)

## T202: the parking spot at a map body (station or asteroid field) at `centre`, `radius` big, as seen from the ship.
func _dock_body(centre: Vector3, radius: float, from: Vector3, sys: int) -> Vector3:
	var p: Vector2 = main.map.dock_point(Vector2(centre.x, centre.z), radius, Vector2(from.x, from.z), sys)
	return Vector3(p.x, 0.0, p.y)

func _is_dead(pid: String) -> bool:
	var i := _index_of(pid)
	return i >= 0 and DeadWorlds.is_dead(_planets()[i])

func _speed_mult() -> float:
	return maxf(0.1, Ships.speed(Ships.fleet))

## World units per map unit of the data files (MAP_UNIT_SCALE x ORBIT_SCALE): the proposal's distances are data units.
func _world_per_map_unit() -> float:
	return main.map.MAP_UNIT_SCALE * main.map.ORBIT_SCALE

## Estimate in cycles of a flight from `from` to `to` in system `to_sys` (the gig board calls it). Another system: leg 1 to the
## exit point + the jump + leg 2 from the entry point to `to`.
func _flight_cycles(from: Vector3, to: Vector3, to_sys: int) -> float:
	if to_sys != _sys:
		var ex := Geometry.exit_point(main, _sys, to_sys)
		var en := Geometry.exit_point(main, to_sys, _sys)
		return _leg_cycles(from, ex, _yaw) + _jump_cycles() + _leg_cycles(en, to, Motion.yaw_to(Vector2(to.x - en.x, to.z - en.z)))
	return _leg_cycles(from, to, _yaw)

func _jump_cycles() -> float:
	return maxf(0.05, _bal("pathfinder_jump_cycles", 2.0))

## In-system flight time (accelerate, cruise, brake) plus the turn from heading `yaw`.
func _leg_cycles(from: Vector3, to: Vector3, yaw: float) -> float:
	var dist := Vector2(to.x - from.x, to.z - from.z).length()
	var v := _vmax()
	var a := v / maxf(0.001, _bal("pathfinder_accel_cycles", 0.05))
	var b := v / maxf(0.001, _bal("pathfinder_brake_cycles", 0.05))
	var d_acc := v * v / (2.0 * a)
	var d_brk := v * v / (2.0 * b)
	var t := 0.0
	if dist >= d_acc + d_brk:
		t = v / a + v / b + (dist - d_acc - d_brk) / v
	else:
		var vp := sqrt(2.0 * dist / (1.0 / a + 1.0 / b))
		t = vp / a + vp / b
	var turn := deg_to_rad(maxf(1.0, _bal("pathfinder_turn_deg", 2400.0)))
	if dist > Motion.ARRIVE_EPS:
		t += absf(wrapf(Motion.yaw_to(Vector2(to.x - from.x, to.z - from.z)) - yaw, -PI, PI)) / turn
	return t

## Top speed in world units per cycle.
func _vmax() -> float:
	var boost := _bal("flagship_boost_mult", 1.0) if _boost else 1.0  # T269
	return maxf(1.0, _bal("pathfinder_speed", 400.0) * _speed_mult() * maxf(1.0, boost)) * _world_per_map_unit()

## Current heading (yaw, model forward is -Z) and speed in world units per cycle, for the view.
func heading() -> float:
	return _yaw

func speed() -> float:
	return _speed

# ---- accessor read by the UI (game/pathfinder_view.gd) ---------------------------------------------------------------

func is_enabled() -> bool:
	return main != null and is_instance_valid(main) and _bal("discovery_enabled", 0.0) >= 0.5

func state() -> String:
	return _state

## True during the jump leg: the ship is in neither system (state() is still "flying").
func jumping() -> bool:
	return _state == "flying" and _leg == "jump"

## "direct" | "out" | "jump" | "in" (see the header).
func leg() -> String:
	return _leg

func ship_position() -> Vector3:
	return _pos

func system_id() -> int:
	return _sys

func target() -> Dictionary:
	return _target.duplicate()

## Where the current leg ends, in the system the ship is in: the exit point on leg "out" of a cross-system flight (target() then holds the
## final target, which lies in ANOTHER system), else the final target. The view draws its line and marker to this.
func leg_goal() -> Vector3:
	return _to

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

## T200: the actions the ship may do at a planet, for the right-click menu: "establish_post" (living world), "establish_platform"
## (dead world, mining skill learned). Empty when the world already stands, the system has no permit or discovery is off.
## Hidden means not drawn: the menu shows exactly these.
func actions_for(pid: String) -> Array:
	var out: Array = []
	if not is_enabled() or _index_of(pid) < 0 or established(pid):
		return out
	if eta_cycles(pid) < 0.0:
		return out
	if _is_dead(pid):
		if can_platform(pid):
			out.append("establish_platform")
	else:
		out.append("establish_post")
	return out

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
	return _flight_cycles(_pos, _dock_pos(i, _pos if tsys == _sys else Geometry.exit_point(main, tsys, _sys)), tsys)

# ---- orders ----------------------------------------------------------------------------------------------------------

## Starts or redirects the flight. "" = accepted; "no_gate" = the other system has no permit; "bad_target" = unknown target.
## Leaving a planet during a build cancels it (build_cancelled), credits are not refunded.
func request_fly(t: Dictionary) -> String:
	if not is_enabled():
		return ""
	if _idle_left > 0.0:
		return "busy"  # T271: a gig cost holds the ship
	if not _self_order:
		_explore = false  # T206: a manual order ends exploration mode
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
			to_sys = main.system_of(idx)
			to = _dock_pos(idx, _pos if to_sys == _sys else Geometry.exit_point(main, to_sys, _sys))  # T202: beside the planet, never in it
		"storage":
			to_sys = idx if idx > 0 else _sys
			to = _dock_body(t.get("pos", _pos), Station.MAP_RADIUS, _pos if to_sys == _sys else Geometry.exit_point(main, to_sys, _sys), to_sys)
		"cluster":
			to = t.get("pos", _pos)
			if main.clusters != null and main.clusters.valid(idx):
				to_sys = main.clusters.system_of(idx)
			var cb: Dictionary = main.map.cluster_body(idx)
			if not cb.is_empty():
				var cc: Vector2 = cb["pos"]
				to = _dock_body(Vector3(cc.x, 0.0, cc.y), float(cb["radius"]), _pos if to_sys == _sys else Geometry.exit_point(main, to_sys, _sys), to_sys)
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
	_auto = ""
	var in_jump := _state == "flying" and _leg == "jump"
	if in_jump and to_sys == _to_sys:
		# redirected inside the same jump: it goes on, only the final target changes
		_final_to = to
		_dur = _t + (_jump_dur - _jump_t) + _leg_cycles(Geometry.exit_point(main, to_sys, _sys), to, 0.0)
		_docked = ""
		_target = {"kind": kind, "pos": to, "index": idx if kind != "point" else -1}
		return ""
	_from = _pos
	_to_sys = to_sys
	_t = 0.0
	if in_jump:
		_speed = 0.0
	if to_sys != _sys:
		_leg = "out"
		_final_to = to
		_to = Geometry.exit_point(main, _sys, to_sys)
	else:
		_leg = "direct"
		_to = to
	_dur = _flight_cycles(_pos, to, to_sys)
	_docked = ""
	_target = {"kind": kind, "pos": to, "index": idx if kind != "point" else -1}
	_state = "flying"
	if _dur <= EPS:
		_arrive()
	return ""

## T200: "fly there and establish on arrival" (right-click menu). "" accepted, else the reason of request_fly / request_establish.
## The build starts the moment the ship docks; if it cannot (no credits) establish_failed is emitted.
func request_fly_establish(pid: String) -> String:
	if not is_enabled():
		return ""
	if not _self_order:
		_explore = false  # T206
	var i := _index_of(pid)
	if i < 0:
		return "bad_target"
	if _state == "building" and _build == pid:
		return ""
	if _state == "idle" and _docked == pid:
		return request_establish(pid)
	var r := request_fly({"kind": "planet", "pos": _planet_pos(i), "index": i})
	if r != "":
		return r
	if _state == "flying":
		_auto = pid
	elif _docked == pid:
		return request_establish(pid)
	return ""

## Starts the build at the planet the ship is docked at. "" accepted; "fly_first" | "no_cash_post" | "no_cash_platform" | "busy";
## "no_skill" (platform without Prospecting, no notice defined) and "bad_target" otherwise.
func request_establish(pid: String) -> String:
	if not is_enabled():
		return ""
	if _idle_left > 0.0:
		return "busy"  # T271
	if not _self_order:
		_explore = false  # T206
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
	_tick_charges(cycles)
	_coast(cycles)
	_idle_left = maxf(0.0, _idle_left - cycles)
	if _boost and _leg != "jump":  # the jump burns no energy
		var rate := _bal("flagship_boost_energy", 0.0)
		var run := cycles
		if rate > 0.0:
			run = minf(cycles, maxf(0.0, float(hold_units("energy")) - _burn_owed) / rate)
			_burn_owed += run * rate
			var whole := floori(_burn_owed)
			if whole > 0:
				_take("energy", whole)
				_burn_owed -= float(whole)
		if run < cycles:
			_advance_flight(run)
			_boost = false  # out of fuel
			_burn_owed = 0.0
			_advance_flight(cycles - run)
			return
	_advance_flight(cycles)

## T374: after an abort the idle ship eases its speed to 0 over the usual brake, drifting on along its heading.
func _coast(cycles: float) -> void:
	if _state != "idle" or _speed <= 0.0:
		return
	var brake := _vmax() / maxf(0.001, _bal("pathfinder_brake_cycles", 0.05))
	var t := minf(cycles, _speed / brake)
	var dist := _speed * t - 0.5 * brake * t * t
	_pos += Vector3(-sin(_yaw), 0.0, -cos(_yaw)) * maxf(0.0, dist)
	_speed = maxf(0.0, _speed - brake * t)
	if t >= cycles - 0.000001 and _speed < 0.0001:
		_speed = 0.0

## T374: ends a flight on the spot, like an arrival without a dock: idle, no build, target cleared, exploration mode as it was.
## Mid-jump the jump is finished first (the ship comes out at the entry point, never stranded between systems). Emits flight_aborted.
## Returns false when the ship was not flying.
func abort_flight(reason: String) -> bool:
	if _state != "flying":
		return false
	if _leg == "jump":
		_end_jump()
	_leg = "direct"
	_state = "idle"
	_target = {}
	_auto = ""
	_t = 0.0
	_dur = 0.0
	_to = _pos
	_from = _pos
	_final_to = _pos
	_to_sys = _sys
	_docked = ""
	flight_aborted.emit(reason, _pos)
	return true

func _advance_flight(cycles: float) -> void:
	var left := cycles
	var guard := 0
	while left > 0.0 and guard < 16:
		guard += 1
		if _explore and _state == "idle" and not _explore_tick():
			break
		if _state == "flying" and _leg == "jump":
			# in neither system: timed, the ship stays at the old system's exit point (_pos) until the jump ends
			var rem := _jump_dur - _jump_t
			if left >= rem:
				left -= rem
				_t += rem
				_end_jump()
			else:
				_jump_t += left
				_t += left
				left = 0.0
		elif _state == "flying":
			left = _fly(left)
		elif _state == "building":
			if left >= _build_left:
				left -= _build_left
				_finish_build()
			else:
				_build_left -= left
				left = 0.0
		else:
			break

## ---- T206: exploration mode ---------------------------------------------------------------------------------------

func exploring() -> bool:
	return _explore

## Switches the mode. On needs discovery on; turning it on while flying or building lets that finish first.
## Turning it off stops the ship on the spot when it is on an exploration flight (any manual order already ended the mode).
func set_exploring(on: bool) -> void:
	var was := _explore
	_explore = on and is_enabled()
	if was and not _explore:
		abort_flight("explore_off")

## Planets of the ship's current system, by index, that still need the ship (not established).
func _explore_open() -> Array:
	var out: Array = []
	var ps := _planets()
	for i in ps.size():
		if main.system_of(i) == _sys and not established(str(ps[i].get("id", ""))):
			out.append(i)
	return out

## True when one of `open` can still be acted on now: not a surveyed dead world whose platform skill is missing.
func _explore_workable(open: Array) -> bool:
	for i in open:
		var pid := str(_planets()[i].get("id", ""))
		if not (_is_dead(pid) and discovered(pid) and not can_platform(pid)):
			return true
	return false

## Next stop in another open system: {index} of the workable planet nearest that system's entry point, systems in
## open_systems order; {} when no other open system has work. The flight crosses through the exit points as any order does.
func _explore_next_system() -> Dictionary:
	var ps := _planets()
	for sid in main.open_systems:
		if int(sid) == _sys:
			continue
		var entry := Geometry.exit_point(main, int(sid), _sys)
		var best := -1
		var best_d := INF
		for i in ps.size():
			if main.system_of(i) != int(sid):
				continue
			var pid := str(ps[i].get("id", ""))
			if established(pid) or (_is_dead(pid) and discovered(pid) and not can_platform(pid)):
				continue
			var d := Vector2(_planet_pos(i).x - entry.x, _planet_pos(i).z - entry.z).length()
			if d < best_d:
				best_d = d
				best = i
		if best >= 0:
			return {"index": best}
	return {}

## One decision of the mode while the ship is idle. Returns true when the ship got something to do (flight or build), false to
## wait (no cash, no skill) or when the mode ended (everything stands: exploration_done is emitted once).
func _explore_tick() -> bool:
	var open := _explore_open()
	if not _explore_workable(open):  # nothing left to do here: go on to the next open system that still has work (owner 2026-11-12)
		var nxt := _explore_next_system()
		if nxt.is_empty():
			_explore = false
			exploration_done.emit()
			return false
		_self_order = true
		var ok := request_fly({"kind": "planet", "pos": _planet_pos(int(nxt["index"])), "index": int(nxt["index"])}) == ""
		_self_order = false
		return ok
	_self_order = true
	var started := false
	var best := -1
	var best_d := INF
	for i in open:
		var pid := str(_planets()[i].get("id", ""))
		if _docked == pid:
			if _is_dead(pid) and not can_platform(pid):
				continue
			started = request_establish(pid) == ""  # "no_cash_*": wait here and try again as time passes
			best = -2
			break
		if _is_dead(pid) and discovered(pid) and not can_platform(pid):
			continue  # surveyed but cannot be built yet (skill missing): leave it for later
		var d := Vector2(_planet_pos(i).x - _pos.x, _planet_pos(i).z - _pos.z).length()
		if d < best_d:
			best_d = d
			best = i
	if best >= 0:
		var t := {"kind": "planet", "pos": _planet_pos(best), "index": best}
		started = request_fly(t) == ""  # the build starts in the next round, when the ship is docked there
	_self_order = false
	return started

func _turn_toward(cycles: float) -> void:
	var d := Vector2(_to.x - _pos.x, _to.z - _pos.z)
	if d.length() <= Motion.ARRIVE_EPS:
		return
	var lim := deg_to_rad(maxf(1.0, _bal("pathfinder_turn_deg", 2400.0))) * cycles
	_yaw = wrapf(_yaw + clampf(wrapf(Motion.yaw_to(d) - _yaw, -PI, PI), -lim, lim), -PI, PI)

## In-system flight: integrates speed, heading and position for up to `cycles` of game time; returns the time left over
## (> 0 only when the ship arrived, so the loop goes on with a build or idle).
func _fly(cycles: float) -> float:
	var v := _vmax()
	var accel := v / maxf(0.001, _bal("pathfinder_accel_cycles", 0.05))
	var brake := v / maxf(0.001, _bal("pathfinder_brake_cycles", 0.05))
	var turn := deg_to_rad(maxf(1.0, _bal("pathfinder_turn_deg", 2400.0)))
	var left := cycles
	var target := Vector2(_to.x, _to.z)
	var n := 0
	while left > 0.0 and n < 20000:
		n += 1
		var h := minf(left, SUBSTEP)
		var s := Motion.step({"pos": Vector2(_pos.x, _pos.z), "yaw": _yaw, "speed": _speed}, target, v, accel, brake, turn, h)
		_yaw = s["yaw"]
		_speed = s["speed"]
		var p: Vector2 = s["pos"]
		_pos = Vector3(p.x, 0.0, p.y)
		_t += h
		left -= h
		if s["arrived"]:
			_arrive()
			return left
	return 0.0

func _begin_jump() -> void:
	_leg = "jump"
	_jump_from = _sys
	_jump_t = 0.0
	_jump_dur = _jump_cycles()
	_speed = 0.0
	_pos = Geometry.exit_point(main, _sys, _to_sys)
	jump_started.emit(_sys, _to_sys, _pos)

func _end_jump() -> void:
	_sys = _to_sys
	_leg = "in"
	_pos = Geometry.exit_point(main, _sys, _jump_from)
	_to = _final_to
	_jump_t = 0.0
	_speed = 0.0
	var d := Vector2(_to.x - _pos.x, _to.z - _pos.z)
	if d.length() > Motion.ARRIVE_EPS:
		_yaw = Motion.yaw_to(d)  # the ship comes out already facing its target
	jump_ended.emit(_sys, _pos)

func _arrive() -> void:
	if _state == "flying" and _leg == "out":
		_begin_jump()  # leg 1 done: the exit point is reached, the jump starts (no arrival yet)
		return
	_leg = "direct"
	_pos = _to
	_speed = 0.0
	_sys = _to_sys
	_state = "idle"
	var tgt := _target
	_target = {}
	_t = 0.0
	_dur = 0.0
	_docked = ""
	if str(tgt.get("kind", "")) == "point":
		arrived_point.emit(_sys, _pos)
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
			if _auto == pid:
				_auto = ""
				var r := request_establish(pid)
				if r != "":
					establish_failed.emit(pid, r)
	_auto = ""

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

# ---- T269 Flagship: hold, storage moves, boost -----------------------------------------------------------
## Refusal reasons for the UI: "not_docked" | "hold_full" | "no_fuel" (also "no_stock", "storage_full", "no_charges").

func hold_cap() -> int:
	return maxi(0, int(_bal("flagship_hold_units", 0.0)) + roundi(Bazaar.wing_bonus("hold_units")))  # T298 wings

func hold_units(good: String) -> int:
	return int(_hold.get(good, 0))

func hold_total() -> int:
	var n := 0
	for k in _hold:
		n += int(_hold[k])
	return n

func hold_space() -> int:
	return maxi(0, hold_cap() - hold_total())

## Goods in the hold with units > 0 (hidden goods stay out: Availability).
func hold_goods() -> Dictionary:
	var out := {}
	for k in _hold:
		if int(_hold[k]) > 0 and Availability.good(str(k)):
			out[str(k)] = int(_hold[k])
	return out

func _put(good: String, n: int) -> int:
	var put := clampi(n, 0, hold_space())
	if put > 0:
		_hold[good] = hold_units(good) + put
	return put

func _take(good: String, n: int) -> int:
	var got := clampi(n, 0, hold_units(good))
	if got > 0:
		_hold[good] = hold_units(good) - got
		if int(_hold[good]) <= 0:
			_hold.erase(good)
	return got

## Planet index of the world the ship is docked at and may trade at; -1 when it cannot (flying, building, open space, not established).
func dock_planet() -> int:
	if _state != "idle" or _docked == "" or not established(_docked):
		return -1
	return _index_of(_docked)


## Free move hold -> that world's company storage. Returns "" or a reason ("not_docked", "no_stock", "storage_full").
func unload_to_storage(planet: int, good: String, units: int) -> String:
	if dock_planet() < 0 or dock_planet() != planet:
		return "not_docked"
	if units <= 0 or hold_units(good) <= 0:
		return "no_stock"
	var put: int = main.storage.add(main.storage.planet_key(planet), good, mini(units, hold_units(good)))
	if put <= 0:
		return "storage_full"
	_take(good, put)
	return ""

## Free move that world's company storage -> hold.
func load_from_storage(planet: int, good: String, units: int) -> String:
	if dock_planet() < 0 or dock_planet() != planet:
		return "not_docked"
	var key: String = main.storage.planet_key(planet)
	if units <= 0 or main.storage.amount(key, good) <= 0:
		return "no_stock"
	if hold_space() <= 0:
		return "hold_full"
	var n := mini(mini(units, main.storage.amount(key, good)), hold_space())
	main.storage.remove(key, good, n)
	_put(good, n)
	return ""

## T271 gig cost: the ship takes no order for this many cycles (game clock). 0 clears it.
func hold_for(cycles: float) -> void:
	_idle_left = maxf(0.0, cycles)

func idle_left() -> float:
	return _idle_left

func boost_on() -> bool:
	return _boost

func boost_max_charges() -> int:
	return maxi(0, int(_bal("flagship_boost_charges", 0.0)))

func boost_charges() -> int:
	return boost_max_charges() if _charges < 0 else mini(_charges, boost_max_charges())


## Switches the boost. Turning on spends one charge and needs energy in the hold. "" ok, else "no_fuel" | "no_charges".
func set_boost(on: bool) -> String:
	if not on:
		_boost = false
		_burn_owed = 0.0
		return ""
	if _boost:
		return ""
	if _bal("flagship_boost_energy", 0.0) > 0.0 and hold_units("energy") <= 0:
		return "no_fuel"
	if boost_charges() <= 0:
		return "no_charges"
	if _charges < 0:
		_charges = boost_max_charges()
	if boost_charges() >= boost_max_charges():
		_refill_left = _bal("flagship_boost_refill_cycles", 1.0)
	_charges = boost_charges() - 1
	_boost = true
	return ""

func _tick_charges(cycles: float) -> void:
	if _charges < 0 or _charges >= boost_max_charges():
		return
	var left := cycles
	var guard := 0
	while left > 0.0 and _charges < boost_max_charges() and guard < 64:
		guard += 1
		if left >= _refill_left:
			left -= _refill_left
			_charges += 1
			_refill_left = maxf(0.01, _bal("flagship_boost_refill_cycles", 1.0))
		else:
			_refill_left -= left
			left = 0.0

# ---- debug and QA ----------------------------------------------------------------------------------------------------

## Finishes the flight at once (main.debug_* guards it by the debug flag).
func finish_flight() -> void:
	if _state == "flying":
		var guard := 0
		while _state == "flying" and guard < 64:
			guard += 1
			advance(maxf(1.0, _dur) + EPS)

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
		"leg": _leg, "final_to": _v(_final_to), "jump_from": _jump_from, "jump_t": _jump_t, "jump_dur": _jump_dur,
		"dur": _dur, "t": _t, "speed": _speed, "yaw": _yaw, "docked": _docked, "build": _build, "build_total": _build_total, "build_left": _build_left, "auto": _auto, "explore": _explore,
		"hold": _hold.duplicate(), "idle": _idle_left, "boost_charges": _charges, "boost_refill": _refill_left,
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
	_yaw = float(d.get("yaw", 0.0))
	_speed = maxf(0.0, float(d.get("speed", 0.0)))
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
		_final_to = _vec(d.get("final_to"), _to)
		_jump_from = maxi(1, int(d.get("jump_from", _sys)))
		_jump_dur = maxf(0.0, float(d.get("jump_dur", 0.0)))
		_jump_t = clampf(float(d.get("jump_t", 0.0)), 0.0, _jump_dur)
		_leg = str(d.get("leg", ""))
		if not ["direct", "out", "jump", "in"].has(_leg):
			# an old save (no legs): another system means the jump phase from the old system's exit, else an ordinary flight
			if _to_sys != _sys:
				_leg = "jump"
				_final_to = _to
				_jump_from = _sys
				_jump_dur = _jump_cycles()
				_jump_t = clampf(_t / maxf(_dur, EPS), 0.0, 1.0) * _jump_dur
				_pos = Geometry.exit_point(main, _sys, _to_sys)
			else:
				_leg = "direct"
		elif _leg == "out" and _to_sys == _sys:
			_leg = "direct"
		_state = "flying"
		_auto = str(d.get("auto", ""))
	elif st == "building" and str(d.get("build", "")) != "" and _index_of(str(d["build"])) >= 0 and float(d.get("build_total", 0.0)) > 0.0:
		_build = str(d["build"])
		_build_total = float(d["build_total"])
		_build_left = clampf(float(d.get("build_left", _build_total)), 0.0, _build_total)
		_state = "building"
		_docked = _build
	if typeof(d.get("hold")) == TYPE_DICTIONARY:  # T269: an older save has no hold: empty, charges full
		for k in d["hold"]:
			if int(d["hold"][k]) > 0:
				_hold[str(k)] = int(d["hold"][k])
		_charges = int(d.get("boost_charges", -1))
		_refill_left = maxf(0.0, float(d.get("boost_refill", 0.0)))
	_idle_left = maxf(0.0, float(d.get("idle", 0.0)))  # T271; an older save has none
	_ensure_home()
	_explore = bool(d.get("explore", false)) and is_enabled()
	# T202: a save from before the parking spot has the ship at the planet's centre: move it to the edge
	var di := _index_of(_docked) if _docked != "" and _state != "flying" else -1
	if di >= 0 and Vector2(_pos.x, _pos.z).distance_to(Vector2(_planet_pos(di).x, _planet_pos(di).z)) < main.map.planet_radius(di) + Motion.BODY_MARGIN:
		_pos = _dock_pos(di, Vector3.ZERO)
