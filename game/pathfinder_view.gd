extends Node3D
## T180: the Pathfinder on the map (3D scout ship, heading, flight path line, target marker, paused look) and the one thin
## interface between the UI and the flight logic that T179 builds. UNVERIFIED BY EXECUTION when written.
##
## ---- INTERFACE FOR T179 (gameplay-programmer) -------------------------------------------------------------------
## Set `main.map.flight = <accessor>` (any object, e.g. a RefCounted in game/flight.gd) when the run uses discovery.
## While `map.flight` is null, or `flight.is_enabled()` is false (balance key discovery_enabled = 0), NOTHING here draws,
## changes or blocks anything: every planet is known, no ship, no Fly/Establish buttons, no new signals fire.
##
## Accessor methods (all optional; a missing method reads as the default in brackets). World units are the map's own
## (map.positions[i], MAP_UNIT_SCALE x ORBIT_SCALE applied); the ship moves on the plane y = 0.
##   is_enabled() -> bool                  [false]  discovery on for this run
##   state() -> String                     ["idle"] "idle" | "flying" | "building"
##   ship_position() -> Vector3            [ZERO]   world position of the ship
##   heading() -> float                    [toward target]  T196: yaw of the ship (atan2(-dx, -dz)); it turns at a limited rate
##   system_id() -> int                    [1]      solar system the ship is in (it is drawn only in the viewed system)
##   target() -> Dictionary                [{}]     {"kind": "planet"|"storage"|"cluster"|"point", "pos": Vector3, "index": int}
##                                                  current or planned destination; {} when none
##   is_paused() -> bool                   [false]  game paused (planned line, ship stands still)
##   model_path() -> String                [""]     GLB of the chosen ship (data/ships.json "model"); empty draws a small cone
##   discovered(planet_id: String) -> bool [true]   name and type are known (the ship has arrived once, or Voltara)
##   post_built(planet_id) -> bool         [true]   trading post (living world) done: goods, prices, routes allowed
##   platform_built(planet_id) -> bool     [false]  mining platform (dead world) done
##   docked_at() -> String                 [""]     planet id the ship is at now (idle or building there), "" otherwise
##   build_target() -> String              [""]     planet id being built, "" when no build
##   build_progress() -> float             [0.0]    0..1 of the running build
##   build_cycles_left() -> float          [0.0]    cycles left of the running build
##   cost(planet_id) -> Dictionary         [{}]     {"cash": int, "cycles": float, "free": bool}
##   eta_cycles(planet_id) -> float        [-1.0]   flight time from the ship now; < 0 hides the line
##   can_platform(planet_id) -> bool       [false]  dead world and the mining skill is learned (button is absent otherwise)
##   request_fly(target: Dictionary) -> String      [""]  start or redirect the flight (target as in target()). Returns ""
##                                                  when accepted, or a refusal reason (none are defined for flying yet)
##   request_establish(planet_id: String) -> String [""]  start the build. Returns "" when accepted, else one reason:
##                                                  "fly_first" | "no_cash_post" | "no_cash_platform" | "busy"
##                                                  main.gd turns the reason into NOT_FLY_FIRST / NOT_POST_NO_CASH /
##                                                  NOT_PLATFORM_NO_CASH / NOT_POST_BUSY (post_notice_now). Other strings: no notice.
## main.gd also reads, for the tutorial: state(), docked_at(), post_built()/platform_built() (card TUT_G0_FLY until the ship
## docks at a closed world, TUT_G0_BUILD there, TUT_G0_WAIT while state() is "building"; over once a second world stands).
## main.planet_name(i) returns LBL_UNKNOWN_WORLD / LBL_UNKNOWN_DARK_WORLD whenever discovered() is false.
## A planet is "established" when post_built or platform_built is true. Anything else shows the closed panel.
##
## Signals the UI emits (connect them in main.gd; both live on game/map.gd, one connection point):
##   map.fly_requested(target: Dictionary)   same shape as target(); sent by: click on an established planet, on the
##       space station, on an asteroid pack, Shift+click on open space, and the "Fly here" button. A click on a closed
##       planet only selects it (panel with Fly here). T179 starts/redirects the flight; it posts NOT_POST_LEAVE if a build is cancelled.
##   (T200) Controls: click the ship to select it (cyan ring); with it selected a LEFT click on a planet, storage, asteroid pack or open
##       space sends fly_requested at once (no confirm); a RIGHT click on a planet opens a menu of request_fly_establish actions
##       (actions_for(planet_id) -> Array: "establish_post" | "establish_platform", only the allowed ones); Esc or right-click on
##       open space deselects. Signals: map.fly_establish_requested(planet_id), map.action_menu_requested(planet_id, screen_pos).
##   (T270) The right-click menu also lists 'Dock and trade' on an established world (map._right_click, main.request_dock): fly there and open
##       the dock sheet (game/dock_sheet.gd, pauses like an event window). Hold key B boosts (main.set_flagship_boost); the ship panel shows the hold and the boost gauge.
##   map.establish_requested(planet_id: String)   the Establish button. T179 checks cash/dock/busy and posts NOT_FLY_FIRST,
##       NOT_POST_NO_CASH, NOT_PLATFORM_NO_CASH, NOT_POST_BUSY itself.
## When state changes (arrive, build done, flags change) the planet panel and map labels re-read the accessor on their own
## (the panel compares a signature each frame), so T179 needs no refresh call.
## Model forward axis is -Z after the per-model offset of Ships.MODEL_YAW_DEG (T197); the ship is turned with rotation.y = atan2(-dx, -dz).

const Ships := preload("res://game/ships.gd")  # T197: per-model yaw offset
const ShipTrail := preload("res://game/ship_trail.gd")  # T198
const Juice := preload("res://game/juice.gd")  # T203: motion scale
const PLAYER_SHIP_SCALE := 0.5  # T198: ship size on the map; 1.0 is the old size (T198 halved it). One constant for the player ship kind.
const FIT_RADIUS_BASE := 0.45 * PLAYER_SHIP_SCALE  # horizontal footprint radius of the model in world units (planets are about 0.9 to 2.4 across)
const FIT_HEIGHT_BASE := 0.3 * PLAYER_SHIP_SCALE

## T252: the sizes below times the global balance key ship_scale (Ships.ship_scale()).
static func fit_radius() -> float:
	return FIT_RADIUS_BASE * Ships.ship_scale()
static func fit_height() -> float:
	return FIT_HEIGHT_BASE * Ships.ship_scale()
static func sel_radius() -> float:
	return SEL_RADIUS_BASE * Ships.ship_scale()
const TRAIL_TINT := Color(1.0, 0.8, 0.4)  # T198: player trail, warm gold (rivals use a cool blue)
const LIFT := 0.35             # ship hovers above the map plane so it clears planet spheres' lower rim
const MARKER_RADIUS := 0.35
const COL_LINE_MOVING := Color(1.0, 0.85, 0.5, 0.3)  # owner: a plain, faded line (not dashes)
const COL_SELECTED := Color(0.55, 0.9, 1.0, 0.95)  # T200 selected look: cyan ring under the ship
const SEL_RADIUS_BASE := 0.5 * PLAYER_SHIP_SCALE
const COL_LINE_PAUSED := Color(1.0, 0.85, 0.5, 0.15)
# T203: post / platform established. A ring closes on the planet (build-up), then bursts open with spokes of sparkle.
# Runs on game time only: it does not advance while the game is paused (the ring and spokes freeze as they are).
const BURST_SECONDS := 1.1       # whole beat
const BURST_BUILD := 0.3         # share of the beat the ring spends closing in (0..1); the burst takes the rest
const BURST_SPOKES := 10         # sparkle lines radiating from the planet
const BURST_RING_FROM := 2.3     # ring starts at this many planet radii, closes to BURST_RING_MIN, then opens to BURST_RING_TO
const BURST_RING_MIN := 1.15
const BURST_RING_TO := 2.8

# T274 flight and dock juice. Every number is data/balance.json flight_juice_* (placeholders); FX_FALLBACK only mirrors them for a missing key.
# Effects run on game time (frozen while paused, off when Juice.motion <= 0) and reuse a fixed pool of meshes: nothing is allocated per frame.
const FX_FALLBACK := {"flight_juice_ring_pop_s": 0.3, "flight_juice_ring_pop_scale": 1.7, "flight_juice_swing_deg": 10.0, "flight_juice_swing_s": 0.45,
	"flight_juice_flare_s": 0.35, "flight_juice_flare_size": 0.45, "flight_juice_boost_burst_s": 0.55, "flight_juice_boost_stretch": 1.8,
	"flight_juice_boost_ease_s": 0.4, "flight_juice_dock_ring_s": 0.45, "flight_juice_clamp_s": 0.18, "flight_juice_puff_s": 0.6,
	"flight_juice_marker_hz": 0.8, "flight_juice_marker_amp": 0.2, "flight_juice_rush_s": 0.9, "flight_juice_sting_db": -14.0}
const FX_RINGS := 8              # pooled ring meshes
const FX_FLARES := 3             # pooled flare spheres
const COL_FLARE := Color(1.0, 0.85, 0.5, 1.0)
const COL_BOOST := Color(0.8, 0.95, 1.0, 1.0)
const COL_DOCK := Color(0.55, 0.9, 1.0, 1.0)
const COL_PUFF := Color(1.0, 0.9, 0.7, 1.0)
const DOCK_RING_FROM := 5.0      # docking ring starts at this many ship radii and closes to DOCK_RING_TO
const DOCK_RING_TO := 1.15
const CLAMP_FROM := 1.4          # the clamp pulse starts at this many ship radii and settles on DOCK_RING_TO
const PUFF_FROM := 0.5           # departure puff ring, in ship radii
const PUFF_TO := 2.6
const BURST_SHIP_TO := 6.0       # boost burst ring end radius, in ship radii
const SWING_MIN_TURN := 0.5      # a course change of this many radians (or more) gives the full nose swing
const MARKER_ALPHA_LOW := 0.55   # target marker pulse: alpha floor (ceiling 1.0)

class Fx:
	var mi: MeshInstance3D
	var mat: StandardMaterial3D
	var sphere := false
	var on := false
	var t := 0.0            # seconds into the beat; negative = still waiting (delay)
	var dur := 1.0
	var r0 := 1.0           # radius (world units) at start and end
	var r1 := 1.0
	var a0 := 1.0           # alpha at start and end
	var a1 := 0.0
	var col := Color.WHITE
	var pos := Vector3.ZERO
	var follow := 0         # 0 fixed at pos, 1 follows the ship, 2 follows the engines
	var then_clamp := false # on its end, the clamp pulse and tick play

var flight = null
var _fx: Array = []
var _fx_conn = null            # the flight object whose delivered signal is connected
var _ship_pos := Vector3.ZERO
var _eng_pos := Vector3.ZERO
var _prev_state := ""
var _prev_tkey := ""
var _prev_boost := false
var _prev_sel := false
var _seen := false
var _sel_t := -1.0             # selection ring pop
var _swing_t := -1.0           # nose swing
var _swing_amp := 0.0
var _boost_k := 0.0            # 0..1 boost look (trail stretch), eased on game time
var _clock := 0.0              # game seconds, drives the target marker pulse
var _marker_mat: StandardMaterial3D
var _deliv_planet := ""
var _rush_seen := -1
var _model_path := ""
var _holder: Node3D
var _line: MeshInstance3D
var _mesh: ImmediateMesh
var _marker: MeshInstance3D
var _gig_rings: Array = []  # T273: one ring per accepted gig target (pool, grows to the board size)
var _trail: MeshInstance3D     # T198: engine trail
var _last_pos := Vector3.INF
var _sel: MeshInstance3D       # T200: ring around the ship while it is selected
var _mat: StandardMaterial3D
var _burst_t := -1.0           # T203: seconds into the beat, -1 when idle
var _burst_pos := Vector3.ZERO
var _burst_r := 1.0
var _burst_col := Color.WHITE
var _burst_ring: MeshInstance3D
var _burst_ring_mat: StandardMaterial3D
var _burst_sparks: MeshInstance3D
var _burst_mesh: ImmediateMesh

# ---- safe accessor helpers (shared by map.gd and planet_panel.gd) ---------------------------------------------------

static func active(f) -> bool:
	return f != null and is_instance_valid(f) and f.has_method("is_enabled") and bool(f.is_enabled())

static func _call(f, m: String, args: Array, dflt):
	if f == null or not is_instance_valid(f) or not f.has_method(m):
		return dflt
	return f.callv(m, args)

static func state(f) -> String:
	return str(_call(f, "state", [], "idle")) if active(f) else "idle"

static func discovered(f, id: String) -> bool:
	return not active(f) or bool(_call(f, "discovered", [id], true))

static func post_built(f, id: String) -> bool:
	return not active(f) or bool(_call(f, "post_built", [id], true))

static func platform_built(f, id: String) -> bool:
	return active(f) and bool(_call(f, "platform_built", [id], false))

## True when the planet shows its normal panel and goods (always true with discovery off).
static func established(f, id: String) -> bool:
	return not active(f) or post_built(f, id) or platform_built(f, id)

static func docked_at(f) -> String:
	return str(_call(f, "docked_at", [], "")) if active(f) else ""

static func build_target(f) -> String:
	return str(_call(f, "build_target", [], "")) if active(f) else ""

static func build_progress(f) -> float:
	return float(_call(f, "build_progress", [], 0.0))

static func build_cycles_left(f) -> float:
	return float(_call(f, "build_cycles_left", [], 0.0))

static func cost(f, id: String) -> Dictionary:
	var c = _call(f, "cost", [id], {})
	return c if typeof(c) == TYPE_DICTIONARY else {}

static func eta_cycles(f, id: String) -> float:
	return float(_call(f, "eta_cycles", [id], -1.0))

static func can_platform(f, id: String) -> bool:
	return bool(_call(f, "can_platform", [id], false))

## One string that changes whenever something the panel or labels show changes (cheap polling instead of a refresh call).
static func signature(f, id: String) -> String:
	if not active(f):
		return ""
	return "%s|%s|%s|%s|%s|%s|%s" % [state(f), discovered(f, id), post_built(f, id), platform_built(f, id), docked_at(f), build_target(f), can_platform(f, id)]

## T203: ring state at t in 0..1 of the beat: x = radius in planet radii, y = alpha. Closes in (fading up), then opens (fading out).
static func burst_ring(t: float) -> Vector2:
	t = clampf(t, 0.0, 1.0)
	if t < BURST_BUILD:
		var k := t / BURST_BUILD
		k = 1.0 - pow(1.0 - k, 3.0)
		return Vector2(lerpf(BURST_RING_FROM, BURST_RING_MIN, k), 0.9 * k)
	var o := (t - BURST_BUILD) / (1.0 - BURST_BUILD)
	o = 1.0 - pow(1.0 - o, 3.0)
	return Vector2(lerpf(BURST_RING_MIN, BURST_RING_TO, o), 0.9 * (1.0 - o))

## T203: spokes at t: x = inner radius, y = outer radius (planet radii), z = alpha. Nothing before the burst starts.
static func burst_spokes(t: float) -> Vector3:
	t = clampf(t, 0.0, 1.0)
	if t < BURST_BUILD:
		return Vector3(0, 0, 0)
	var o := (t - BURST_BUILD) / (1.0 - BURST_BUILD)
	var e := 1.0 - pow(1.0 - o, 3.0)
	return Vector3(lerpf(1.05, 1.9, e), lerpf(1.2, 2.5, e), 1.0 - o)

## Starts the beat at a planet (world position of its centre, its radius). Restarting just begins it again.
func play_established(world_pos: Vector3, radius: float, col: Color) -> void:
	_burst_t = 0.0
	_burst_pos = world_pos
	_burst_r = maxf(radius, 0.1)
	_burst_col = col
	if _burst_ring == null:
		var tm := TorusMesh.new()
		tm.inner_radius = 0.96
		tm.outer_radius = 1.0
		tm.rings = 48
		tm.ring_segments = 6
		_burst_ring_mat = StandardMaterial3D.new()
		_burst_ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_burst_ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_burst_ring_mat.no_depth_test = true
		_burst_ring = MeshInstance3D.new()
		_burst_ring.mesh = tm
		_burst_ring.material_override = _burst_ring_mat
		_burst_ring.top_level = true
		add_child(_burst_ring)
		_burst_mesh = ImmediateMesh.new()
		_burst_sparks = MeshInstance3D.new()
		_burst_sparks.mesh = _burst_mesh
		_burst_sparks.material_override = _mat
		_burst_sparks.top_level = true
		add_child(_burst_sparks)

## Advances the beat by game time (called from update_from, which map.gd runs every frame). Costs nothing while idle.
func _tick_burst(delta: float, paused: bool) -> void:
	if _burst_t < 0.0:
		return
	if Juice.motion <= 0.0:
		_end_burst()
		return
	if not paused:
		_burst_t += delta
	var t := _burst_t / (BURST_SECONDS * Juice.motion)
	if t >= 1.0:
		_end_burst()
		return
	var ring := burst_ring(t)
	var c := _burst_col
	c.a = ring.y
	_burst_ring_mat.albedo_color = c
	_burst_ring.global_position = _burst_pos
	_burst_ring.scale = Vector3.ONE * (_burst_r * ring.x)
	_burst_ring.visible = true
	_burst_mesh.clear_surfaces()
	var sp := burst_spokes(t)
	if sp.z > 0.0:
		var sc := _burst_col.lightened(0.4)
		sc.a = sp.z
		_burst_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		for k in BURST_SPOKES:
			var a := TAU * float(k) / BURST_SPOKES + 0.3
			var dir := Vector3(cos(a), 0.0, sin(a))
			_burst_mesh.surface_set_color(sc)
			_burst_mesh.surface_add_vertex(_burst_pos + dir * _burst_r * sp.x)
			_burst_mesh.surface_set_color(sc)
			_burst_mesh.surface_add_vertex(_burst_pos + dir * _burst_r * sp.y)
		_burst_mesh.surface_end()

func _end_burst() -> void:
	_burst_t = -1.0
	if _burst_ring != null:
		_burst_ring.visible = false
		_burst_mesh.clear_surfaces()

# ---- T274 flight and dock juice ---------------------------------------------------------------------------------------

## Pure curves (the headless tests call these). p is 0..1 of a beat.
## Ring or flare state: x = radius, y = alpha. Ease out cubic on the radius, straight fade on alpha.
static func fx_state(p: float, r0: float, r1: float, a0: float, a1: float) -> Vector2:
	p = clampf(p, 0.0, 1.0)
	var e := 1.0 - pow(1.0 - p, 3.0)
	return Vector2(lerpf(r0, r1, e), lerpf(a0, a1, p))

## Nose swing: a damped sway about the heading, zero at both ends, peak near amp.
static func swing_value(p: float, amp: float) -> float:
	p = clampf(p, 0.0, 1.0)
	return amp * sin(p * TAU * 1.25) * (1.0 - p)

## Selection ring pop: scale at p (starts at peak, settles to 1 with a back-out ease).
static func pop_scale(p: float, peak: float) -> float:
	p = clampf(p, 0.0, 1.0)
	var c1 := 1.70158
	var x := p - 1.0
	var e := 1.0 + (c1 + 1.0) * x * x * x + c1 * x * x
	return lerpf(peak, 1.0, e)

func _main():
	var f = flight
	return f.main if f != null and is_instance_valid(f) and "main" in f else null

## A juice tuning value: balance key flight_juice_*, else the mirror in FX_FALLBACK.
func _k(key: String) -> float:
	var m = _main()
	if m != null and "balance" in m and m.balance.has(key):
		return float(m.balance[key])
	return float(FX_FALLBACK.get(key, 0.0))

func _fx_ensure() -> void:
	if not _fx.is_empty():
		return
	var tm := TorusMesh.new()
	tm.inner_radius = 0.94
	tm.outer_radius = 1.0
	tm.rings = 32
	tm.ring_segments = 6
	var sm := SphereMesh.new()
	sm.radius = 1.0
	sm.height = 2.0
	sm.radial_segments = 12
	sm.rings = 6
	for k in FX_RINGS + FX_FLARES:
		var fx := Fx.new()
		fx.sphere = k >= FX_RINGS
		fx.mat = StandardMaterial3D.new()
		fx.mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fx.mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fx.mat.no_depth_test = true
		if fx.sphere:
			fx.mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		fx.mi = MeshInstance3D.new()
		fx.mi.mesh = sm if fx.sphere else tm
		fx.mi.material_override = fx.mat
		fx.mi.top_level = true
		fx.mi.visible = false
		fx.mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(fx.mi)
		_fx.append(fx)

## Starts a ring (or a flare when sphere) from the pool: a free slot, else the first of its kind is reused.
func _fx_spawn(sphere: bool, r0: float, r1: float, a0: float, a1: float, dur: float, col: Color, follow: int, pos: Vector3 = Vector3.ZERO, delay: float = 0.0) -> Fx:
	if Juice.motion <= 0.0 or dur <= 0.0:
		return null
	_fx_ensure()
	var pick: Fx = null
	for fx in _fx:
		if fx.sphere != sphere:
			continue
		if pick == null:
			pick = fx
		if not fx.on:
			pick = fx
			break
	pick.on = true
	pick.t = -delay
	pick.dur = dur * Juice.motion
	pick.r0 = r0
	pick.r1 = r1
	pick.a0 = a0
	pick.a1 = a1
	pick.col = col
	pick.follow = follow
	pick.pos = pos
	pick.then_clamp = false
	pick.mi.visible = false
	return pick

func _fx_pos(fx: Fx) -> Vector3:
	match fx.follow:
		1:
			return _ship_pos + Vector3(0, LIFT, 0)
		2:
			return _eng_pos + Vector3(0, LIFT, 0)
	return fx.pos + Vector3(0, LIFT, 0)

## Advances every running effect by game time; costs nothing while none runs.
func _tick_fx(delta: float, paused: bool) -> void:
	if Juice.motion <= 0.0:
		_boost_k = 0.0
		if _fx_busy():
			_fx_stop()
		return
	if not paused:
		_clock += delta
		var want := 1.0 if bool(_call(flight, "boost_on", [], false)) else 0.0
		if _boost_k != want:
			_boost_k = move_toward(_boost_k, want, delta / maxf(0.05, _k("flight_juice_boost_ease_s") * Juice.motion))
		if _sel_t >= 0.0:
			_sel_t += delta
			var sd := _k("flight_juice_ring_pop_s") * Juice.motion
			if _sel_t >= sd:
				_sel_t = -1.0
				_sel.scale = Vector3.ONE
			else:
				_sel.scale = Vector3.ONE * pop_scale(_sel_t / sd, 1.0 + (_k("flight_juice_ring_pop_scale") - 1.0) * Juice.motion)
		if _swing_t >= 0.0:
			_swing_t += delta
			var wd := _k("flight_juice_swing_s") * Juice.motion
			if _swing_t >= wd:
				_swing_t = -1.0
				if _holder != null:
					_holder.rotation.y = 0.0
			elif _holder != null:
				_holder.rotation.y = swing_value(_swing_t / wd, _swing_amp)
	if _fx.is_empty():
		return
	for fx in _fx:
		if not fx.on:
			continue
		if not paused:
			fx.t += delta
		if fx.t < 0.0:
			continue
		var p: float = fx.t / fx.dur
		if p >= 1.0:
			fx.on = false
			fx.mi.visible = false
			if fx.then_clamp:
				_clamp()
			continue
		var st := fx_state(p, fx.r0, fx.r1, fx.a0, fx.a1)
		var c: Color = fx.col
		c.a = st.y
		fx.mat.albedo_color = c
		fx.mi.global_position = _fx_pos(fx)
		fx.mi.scale = Vector3.ONE * st.x
		fx.mi.visible = true

func _fx_busy() -> bool:
	for fx in _fx:
		if fx.on:
			return true
	return _sel_t >= 0.0 or _swing_t >= 0.0

## Motion switched off mid-effect: everything returns to rest.
func _fx_stop() -> void:
	for fx in _fx:
		fx.on = false
		fx.mi.visible = false
	_sel_t = -1.0
	_swing_t = -1.0
	_sel.scale = Vector3.ONE
	if _holder != null:
		_holder.rotation.y = 0.0

## The clamp: a short bright pulse settles on the ship and a tick sounds.
func _clamp() -> void:
	var r := fit_radius() * DOCK_RING_TO
	_fx_spawn(false, fit_radius() * CLAMP_FROM, r, 1.0, 0.0, _k("flight_juice_clamp_s"), COL_DOCK.lightened(0.5), 1)
	Juice.play_tone(self, "clamp", _k("flight_juice_sting_db"))

## Reads the Flagship's state each frame (cheap compares) and starts the beats: order accepted, departure, boost, dock, rush delivered.
func _fx_events(f, selected: bool) -> void:
	var st := state(f)
	var tg = _call(f, "target", [], {})
	var tkey := ""
	if typeof(tg) == TYPE_DICTIONARY and tg.has("pos"):
		var tp: Vector3 = tg["pos"]
		tkey = "%.2f,%.2f" % [tp.x, tp.z]
	var boost := bool(_call(f, "boost_on", [], false))
	var m = _main()
	if m != null and _fx_conn != f and f.has_signal("delivered"):  # connect once per Flagship object
		_fx_conn = f
		f.delivered.connect(_on_delivered)
	if not _seen:  # first look: take the state as it is, no beat
		_seen = true
		_prev_state = st
		_prev_tkey = tkey
		_prev_boost = boost
		_prev_sel = selected
		_rush_seen = int(m.gigs.rush_done) if m != null and "gigs" in m else 0
		return
	if Juice.motion > 0.0:
		if selected and not _prev_sel:
			_sel_t = 0.0
		if st == "flying" and tkey != "" and tkey != _prev_tkey:  # an order was accepted
			_sel_t = 0.0
			_order_swing(f, tg)
			_fx_spawn(true, fit_radius() * 0.4, fit_radius() * 0.4 + _k("flight_juice_flare_size"), 0.9, 0.0, _k("flight_juice_flare_s"), COL_FLARE, 2)
		if st == "flying" and _prev_state != "flying":  # departure puff where the ship leaves
			_fx_spawn(false, fit_radius() * PUFF_FROM, fit_radius() * PUFF_TO, 0.6, 0.0, _k("flight_juice_puff_s"), COL_PUFF, 0, _ship_pos)
		if boost and not _prev_boost:  # boost: bright burst
			_fx_spawn(false, fit_radius(), fit_radius() * BURST_SHIP_TO, 1.0, 0.0, _k("flight_juice_boost_burst_s"), COL_BOOST, 1)
			_fx_spawn(true, fit_radius() * 0.5, fit_radius() * 0.5 + _k("flight_juice_flare_size") * 1.6, 1.0, 0.0, _k("flight_juice_boost_burst_s"), COL_BOOST, 2)
		if _prev_state == "flying" and st != "flying" and str(_call(f, "docked_at", [], "")) != "":  # docking ring closes in, then clamps
			var fx := _fx_spawn(false, fit_radius() * DOCK_RING_FROM, fit_radius() * DOCK_RING_TO, 0.0, 0.9, _k("flight_juice_dock_ring_s"), COL_DOCK, 1)
			if fx != null:
				fx.then_clamp = true
	_prev_state = st
	_prev_tkey = tkey
	_prev_boost = boost
	_prev_sel = selected
	if _deliv_planet != "":  # a hand delivery was reported: did it finish a rush order?
		var pid := _deliv_planet
		_deliv_planet = ""
		var done := int(m.gigs.rush_done) if m != null and "gigs" in m else _rush_seen
		if done > _rush_seen:
			_rush_beat(f, pid)
		_rush_seen = done

func _on_delivered(planet_id: String, _good: String, _units: int) -> void:
	_deliv_planet = planet_id

## Nose swing toward the new course: a small sway in the direction of the turn, then it settles on the heading.
func _order_swing(f, tg) -> void:
	var tp: Vector3 = tg["pos"]
	var d := Vector2(tp.x - _ship_pos.x, tp.z - _ship_pos.z)
	if d.length() < 0.05:
		return
	var turn := wrapf(atan2(-d.x, -d.y) - rotation.y, -PI, PI)
	var k := clampf(absf(turn) / SWING_MIN_TURN, 0.3, 1.0)
	_swing_amp = deg_to_rad(_k("flight_juice_swing_deg")) * Juice.motion * k * signf(turn if turn != 0.0 else 1.0)
	_swing_t = 0.0

## A rush order was delivered at planet pid: a gold-green double ring on the world, a pop of its label and a sting.
func _rush_beat(f, pid: String) -> void:
	var m = _main()
	if m == null or Juice.motion <= 0.0:
		return
	var i: int = m.planet_index_of(pid)
	var map = get_parent()
	if i < 0 or map == null or not map.has_method("planet_radius"):
		return
	var r: float = map.planet_radius(i)
	var pos: Vector3 = f._planet_pos(i)
	var good := Ui.col("signal_good")
	var secs := _k("flight_juice_rush_s")
	_fx_spawn(false, r * 1.05, r * 2.6, 0.95, 0.0, secs, good, 0, pos)
	_fx_spawn(false, r * 1.05, r * 2.0, 0.8, 0.0, secs * 0.8, good.lightened(0.5), 0, pos, secs * 0.2)
	if "planet_label_2d" in map and i < map.planet_label_2d.size():
		Juice.pop(map.planet_label_2d[i])
	Juice.play_tone(self, "sting", _k("flight_juice_sting_db"))

# ---- the 3D ship --------------------------------------------------------------------------------------------------

func _ready() -> void:
	visible = false
	_mat = StandardMaterial3D.new()
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.vertex_color_use_as_albedo = true
	_mat.no_depth_test = true
	_mesh = ImmediateMesh.new()
	_line = MeshInstance3D.new()
	_line.mesh = _mesh
	_line.material_override = _mat
	_line.top_level = true  # drawn in world space whatever the parent does
	add_child(_line)
	var ring := TorusMesh.new()
	ring.inner_radius = MARKER_RADIUS * 0.8
	ring.outer_radius = MARKER_RADIUS
	_marker = MeshInstance3D.new()
	_marker.mesh = ring
	_marker_mat = StandardMaterial3D.new()  # T274: own material so the pulse can change alpha
	_marker_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_marker_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_marker_mat.no_depth_test = true
	_marker.material_override = _marker_mat
	_marker.top_level = true
	_marker.visible = false
	add_child(_marker)
	var sring := TorusMesh.new()
	sring.inner_radius = sel_radius() * 0.9
	sring.outer_radius = sel_radius()
	_sel = MeshInstance3D.new()
	_sel.mesh = sring
	var smat := StandardMaterial3D.new()
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smat.no_depth_test = true
	smat.albedo_color = COL_SELECTED
	_sel.material_override = smat
	_sel.top_level = true
	_sel.visible = false
	add_child(_sel)
	_trail = ShipTrail.new()
	_trail.tint = TRAIL_TINT
	add_child(_trail)

## Called by map.gd every frame. Does nothing visible while the accessor is missing or discovery is off.
func update_from(f, view_system: int, selected: bool = false) -> void:
	flight = f
	var is_paused := bool(_call(f, "is_paused", [], false))
	_tick_burst(get_process_delta_time(), is_paused)
	_tick_fx(get_process_delta_time(), is_paused)
	if not active(f):
		_seen = false
		visible = false
		_line.visible = false
		_marker.visible = false
		_sel.visible = false
		_trail.visible = false
		return
	var sys := int(_call(f, "system_id", [], 1))
	visible = sys == view_system
	_line.visible = visible
	if not visible:
		_marker.visible = false
		_sel.visible = false
		_trail.visible = false
		_trail.clear()
		return
	_ensure_model(str(_call(f, "model_path", [], "")))
	var pos: Vector3 = _call(f, "ship_position", [], Vector3.ZERO)
	global_position = pos + Vector3(0, LIFT, 0)
	_sel.visible = selected
	_sel.global_position = pos + Vector3(0, LIFT, 0)
	var has_heading: bool = f != null and is_instance_valid(f) and f.has_method("heading")
	if has_heading:
		rotation.y = float(f.heading())  # T196: the ship turns at a limited rate, the accessor owns the heading
	var paused := is_paused
	_trail.visible = true
	_ship_pos = pos
	var back0 := Ships.engine_back_for_path(str(_call(f, "model_path", [], ""))) * fit_radius()
	_eng_pos = pos + Vector3(sin(rotation.y), 0.0, cos(rotation.y)) * back0
	_trail.stretch = lerpf(1.0, _k("flight_juice_boost_stretch"), _boost_k)  # T274: stretched, brighter trail while boosting
	_trail.glow = _boost_k
	_fx_events(f, selected)
	if not paused:  # T198: nothing is sampled or redrawn while paused; the trail freezes as it is
		var moved: bool = _last_pos != Vector3.INF and _last_pos.distance_to(pos) > 0.0005
		var back := Ships.engine_back_for_path(str(_call(f, "model_path", [], ""))) * fit_radius()  # T205: trail starts at the engines
		var eng := pos + Vector3(sin(rotation.y), 0.0, cos(rotation.y)) * back
		_trail.push(eng + Vector3(0, LIFT, 0), get_process_delta_time(), moved and state(f) == "flying")
	_last_pos = pos
	var tgt = _call(f, "target", [], {})
	_mesh.clear_surfaces()
	_marker.visible = false
	_update_gig_rings(f, sys)
	if typeof(tgt) == TYPE_DICTIONARY and tgt.has("pos") and state(f) != "building":
		var tp: Vector3 = tgt["pos"]
		var d := Vector2(tp.x - pos.x, tp.z - pos.z)
		if d.length() > 0.05:
			if not has_heading:
				rotation.y = atan2(-d.x, -d.y)  # turn toward the heading (model forward is -Z)
			var col := COL_LINE_PAUSED if paused else COL_LINE_MOVING  # paused look: faint planned line, ship waits
			_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
			var a := pos + Vector3(0, LIFT, 0)
			var b := tp + Vector3(0, LIFT, 0)
			_mesh.surface_set_color(col)  # one solid segment from the ship to the target
			_mesh.surface_add_vertex(a)
			_mesh.surface_set_color(col)
			_mesh.surface_add_vertex(b)
			_mesh.surface_end()
			_marker.global_position = tp + Vector3(0, LIFT, 0)
			_marker.visible = true
			if Juice.motion > 0.0 and state(f) == "flying":  # T274: slow pulse on the target while the ship flies (game clock)
				var ph := 0.5 + 0.5 * sin(_clock * _k("flight_juice_marker_hz") * TAU)
				_marker.scale = Vector3.ONE * (1.0 + _k("flight_juice_marker_amp") * Juice.motion * ph)
				_marker_mat.albedo_color = Color(1, 1, 1, lerpf(MARKER_ALPHA_LOW, 1.0, ph))
			else:
				_marker.scale = Vector3.ONE
				_marker_mat.albedo_color = Color.WHITE

## T273: a ring at each accepted gig target in this system. When the gig starts, one big thin blue ring pulses out once (GIG_PULSE_S);
## then a thin blue ring stays at the target, not pulsing (amber once the offer is within balance gig_marker_amber_cycles of its deadline).
const GIG_PULSE_S := 1.1        # the one start pulse
const GIG_PULSE_SCALE := 3.2    # the pulse ring grows to this multiple of the resting ring
const GIG_RING_THICK := 0.04    # resting ring width as a fraction of its radius (the ship's selection ring is 0.10)
var _gig_t0 := {}  # offer uid -> real seconds when its ring first showed
func _gig_ring_mesh(radius: float, thick: float) -> TorusMesh:
	var ring := TorusMesh.new()
	ring.inner_radius = radius * (1.0 - thick)
	ring.outer_radius = radius
	return ring

func _gig_ring_mat() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = true
	return mat

func _update_gig_rings(f, sys: int) -> void:
	var main_node = f.main if f != null and is_instance_valid(f) and "main" in f else null
	var offers: Array = main_node.gigs.offers if main_node != null and "gigs" in main_node else []
	var now: float = main_node.game_time() if main_node != null else 0.0
	var amber := float(main_node.balance.get("gig_marker_amber_cycles", 2.0)) if main_node != null else 2.0
	var real := Time.get_ticks_msec() * 0.001
	var live := {}
	var used := 0
	for o in offers:
		if not bool(o["accepted"]) or int(o["target"]["sys"]) != sys:
			continue
		var uid := str(o["uid"])
		live[uid] = true
		if not _gig_t0.has(uid):
			_gig_t0[uid] = real
		var tp: Vector3 = main_node.gigs.target_pos(o) if str(o["kind"]) == "signal" else f._planet_pos(int(o["target"]["index"]))
		if used >= _gig_rings.size():
			var m := MeshInstance3D.new()
			m.mesh = _gig_ring_mesh(sel_radius(), GIG_RING_THICK)
			m.material_override = _gig_ring_mat()
			m.top_level = true
			var pr := MeshInstance3D.new()
			pr.name = "Pulse"
			pr.mesh = _gig_ring_mesh(sel_radius(), GIG_RING_THICK * 0.6)
			pr.material_override = _gig_ring_mat()
			pr.visible = false
			m.add_child(pr)
			add_child(m)
			_gig_rings.append(m)
		var urgent := float(o["due"]) - now <= amber
		var r: MeshInstance3D = _gig_rings[used]
		var col := Color(1.0, 0.72, 0.25) if urgent else Color(0.45, 0.85, 1.0)
		col.a = 0.85
		(r.material_override as StandardMaterial3D).albedo_color = col
		r.global_position = tp + Vector3(0, LIFT, 0)
		r.visible = true
		var pr2 := r.get_node("Pulse") as MeshInstance3D
		var u := (real - float(_gig_t0[uid])) / GIG_PULSE_S
		if u < 1.0 and Juice.motion > 0.0:
			var e := 1.0 - pow(1.0 - u, 3.0)
			pr2.scale = Vector3.ONE * lerpf(1.0, GIG_PULSE_SCALE, e)
			var pc := Color(0.45, 0.85, 1.0, 0.9 * (1.0 - u))
			(pr2.material_override as StandardMaterial3D).albedo_color = pc
			pr2.visible = true
		else:
			pr2.visible = false
		used += 1
	for k in range(used, _gig_rings.size()):
		_gig_rings[k].visible = false
	for uid in _gig_t0.keys():
		if not live.has(uid):
			_gig_t0.erase(uid)

func _ensure_model(path: String) -> void:
	if path == _model_path and _holder != null:
		return
	_model_path = path
	if _holder != null:
		remove_child(_holder)
		_holder.queue_free()
		_holder = null
	var model: Node3D = null
	if path != "" and ResourceLoader.exists(path):
		var res = load(path)
		if res is PackedScene:
			model = res.instantiate()
	_holder = Node3D.new()
	if model == null:  # no model: a small cone pointing along -Z so the heading still reads
		var cone := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.0
		cm.bottom_radius = 0.12
		cm.height = 0.4
		cone.mesh = cm
		cone.rotation_degrees = Vector3(-90, 0, 0)
		_holder.scale = Vector3.ONE * PLAYER_SHIP_SCALE * Ships.ship_scale()  # T198, T252
		_holder.add_child(cone)
	else:
		var box := _bounds(model, Transform3D.IDENTITY)  # same measured-bounds fit as game/ship_setup.gd
		if box.size.length() > 0.0:
			var rxz := 0.000001
			for i in 8:
				var c := box.get_endpoint(i) - box.get_center()
				rxz = maxf(rxz, Vector2(c.x, c.z).length())
			var ry := maxf(box.size.y * 0.5, 0.000001)
			_holder.scale = Vector3.ONE * minf(fit_radius() / rxz, fit_height() / ry)
			model.position = -box.get_center()
		var pivot := Node3D.new()  # T197: turns the model's own nose axis onto -Z
		pivot.rotation.y = Ships.model_yaw_for_path(path)
		pivot.add_child(model)
		_holder.add_child(pivot)
	add_child(_holder)

func _bounds(node: Node, t: Transform3D) -> AABB:
	var box := AABB()
	var first := true
	var xf := t
	if node is Node3D:
		xf = t * node.transform
	if node is MeshInstance3D and node.mesh != null:
		box = xf * node.mesh.get_aabb()
		first = false
	for c in node.get_children():
		var cb := _bounds(c, xf)
		if cb.size == Vector3.ZERO:
			continue
		box = cb if first else box.merge(cb)
		first = false
	return box
