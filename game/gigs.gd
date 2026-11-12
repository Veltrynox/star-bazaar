class_name Gigs
extends RefCounted
## T271 the gig engine: one board for every Flagship job (design/proposals/2026-11-06-empire-growth-v2.md section 3.2).
## Data: data/gigs.json (signals); numbers: data/balance.json gig_* keys (all PLACEHOLDERS). Never skill points, never share.
## Kinds (open field "kind"): "signal" (a marker in open space; fly there, a window opens with two neutral options; one-time, expires for
## free, an expired signal is gone for the run) and "salvage" (T296: cargo pods a raid dropped, posted by
## Gigs.post_salvage from game/raids.gd; fly there before they fade, the goods load into the Flagship hold; no window, no board-size limit) and "opening" (T298: after the last Bazaar stage; the Flagship flies the charter cargo to the capital, no window, no expiry to speak of; docking there calls Bazaar.open() and the run is won; post_opening, ensure_opening).
## Board: up to gig_board_max open offers (any kind); one open signal at a time, gig_gap_cycles between signals, gig_cap_signals per run,
## none before gig_first_cycle. The draw is seeded (saved seed + cycle), so a save's list is stable. Deadlines are on the game clock.
## An offer: {uid, id, kind, target {kind "point"|"planet", sys, pos [x,y,z] | index}, due (game time), accepted, req, rewards}.
## Rewards land through apply(): goods in the nearest established world's storage (no share), cash, a story line.
## Run notes for the CEO endings: gigs_done (signals answered, salvage pods scooped) and gigs_expired (signals that ran out).
## Condition atoms (game/conditions.gd): gig_done:<id>, gig_open. Saved under "gigs" (save version 15; older saves load empty).

const StoryText := preload("res://game/story_text.gd")
const PATH := "res://data/gigs.json"
const DeadWorlds := preload("res://game/dead_worlds.gd")
const RouteLineScript := preload("res://game/route_line.gd")
const RouteOffset := preload("res://game/route_offset.gd")
const BRANCH_SUFFIX := {"mil": "MIL", "lux": "LUX", "min": "MIN", "bio": "BIO"}

signal scooped                 # T300: the Flagship scooped salvage pods (juice)
signal changed                 # the board changed (offer opened, done, expired)
signal arrival(uid: String)    # the Flagship reached a signal marker: main opens the window

var main: Node = null
var defs: Array = []
var offers: Array = []         # open offers, oldest first
var done := {}                 # data id -> true (finished)
var skipped := {}              # data id -> true (expired, gone for the run)
var signals_seen := 0
var gigs_done := 0             # signals answered plus salvage offers scooped empty (run note gigs_done)
var gigs_expired := 0          # signals that ran out of time (run note gigs_expired)
var last_signal_cycle := -100000
var seed_value := 0
var pending := ""              # uid of a reached signal waiting for a free window
var _uid := 0
var _by_id := {}

static func read_data() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

## Ids of every gig of data/gigs.json (for the gig_done lint).
static func ids() -> Array:
	var out: Array = []
	for g in read_data().get("gigs", []):
		out.append(str(g.get("id", "")))
	return out

func setup(m: Node) -> void:
	main = m
	var d := read_data()
	defs = d.get("gigs", [])
	_by_id = {}
	for g in defs:
		_by_id[str(g.get("id", ""))] = g
	reset()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for a in OS.get_cmdline_user_args():  # --seed=<int> makes the draw repeatable (QA)
		if a.begins_with("--seed="):
			rng.seed = int(a.trim_prefix("--seed="))
	seed_value = int(rng.randi() & 0x7fffffff)
	if main.flight != null:
		main.flight.arrived_point.connect(on_arrived_point)
		main.flight.arrived.connect(on_arrived_planet)

func reset() -> void:
	offers = []
	done = {}
	skipped = {}
	signals_seen = 0
	gigs_done = 0
	gigs_expired = 0
	last_signal_cycle = -100000
	pending = ""
	_uid = 0

func _bal(key: String, dflt: float = 0.0) -> float:
	return float(main.balance.get(key, dflt)) if main != null else dflt

func _now() -> float:
	return main.game_time()

func enabled() -> bool:
	return main != null and main.flight != null and main.flight.is_enabled()

func is_done(id: String) -> bool:
	return done.has(id)

func is_open() -> bool:
	return not offers.is_empty()

func offer(uid: String) -> Dictionary:
	for o in offers:
		if str(o["uid"]) == uid:
			return o
	return {}

func board_room() -> bool:
	return offers.size() < maxi(0, int(_bal("gig_board_max")))

func open_signal() -> Dictionary:
	for o in offers:
		if str(o["kind"]) == "signal":
			return o
	return {}

## T296: cargo pods at `pos` in system `sys`: `units` of `good`, fading after `life` cycles. Not limited by the board size (a raid made them).
## `lane` is the id of the route the pods came from (-1 when none).
func post_salvage(uid: String, sys: int, pos: Vector3, good: String, units: int, count: int, life: float, lane: int = -1) -> void:
	offers.append({"uid": uid, "id": uid, "kind": "salvage", "target": {"kind": "point", "sys": sys, "pos": [pos.x, 0.0, pos.z]},
		"due": _now() + life, "accepted": false, "req": {}, "rewards": [], "pods": [{"good": good, "units": units}], "count": maxi(1, count), "lane": lane})
	changed.emit()

## T298: the Opening offer at the capital (one at a time). Not limited by the board size.
func post_opening(planet: int) -> void:
	if has_opening():
		return
	_uid += 1
	var uid := "opening_%d" % _uid
	offers.append({"uid": uid, "id": "opening", "kind": "opening", "target": {"kind": "planet", "sys": main.system_of(planet), "index": planet}, "due": _now() + _bal("gig_opening_life", 100000.0),
		"accepted": false, "req": {}, "rewards": []})
	changed.emit()

func has_opening() -> bool:
	for o in offers:
		if str(o["kind"]) == "opening":
			return true
	return false

## After a load: an Opening still to fly has its offer on the board.
func ensure_opening() -> void:
	if main.bazaar.opening_pending and main.bazaar.capital() >= 0:
		post_opening(main.bazaar.capital())

## The Flagship docked at a world: at the capital with an open Opening, the Bazaar opens and the run is won.
func on_arrived_planet(planet_id: String) -> void:
	var o := opening_offer()
	if o.is_empty() or str(o["target"].get("kind", "planet")) != "planet" or main.planet_index_of(planet_id) != int(o["target"]["index"]):
		return
	offers.erase(o)
	changed.emit()
	main.on_opening_flown()

func opening_offer() -> Dictionary:
	for o in offers:
		if str(o["kind"]) == "opening":
			return o
	return {}

## The Flagship reached a salvage marker: the pods load into the hold; what does not fit stays (the offer ends when empty).
func _scoop(o: Dictionary) -> void:
	var left_pods: Array = []
	var lines: Array = []
	for p in o.get("pods", []):
		var put: int = main.flight._put(str(p["good"]), int(p["units"]))
		if put > 0 and Availability.good(str(p["good"])):
			lines.append("%d %s" % [put, Ui.good_name(str(p["good"])).to_lower()])
		if int(p["units"]) - put > 0:
			left_pods.append({"good": str(p["good"]), "units": int(p["units"]) - put})
	o["pods"] = left_pods
	o["accepted"] = false
	if not lines.is_empty():
		scooped.emit()
	if left_pods.is_empty():
		offers.erase(o)
		gigs_done += 1
		main.note("gigs_done")
		main.post_notice(StoryText.get_or("NOT_SALVAGE_DONE", "Pods scooped into the Flagship hold: {lines}.", {"lines": ", ".join(lines)}))
	else:
		main.post_notice(StoryText.get_or("NOT_SALVAGE_FULL", "The Flagship hold is full. Some pods stay adrift.", {}))
	changed.emit()

# ---- spawn -----------------------------------------------------------------------------------------------------------

## Start of every cycle (main): at most one new signal may open.
func on_cycle(cycle: int) -> void:
	if not enabled() or not board_room() or not open_signal().is_empty():
		return
	if cycle < int(_bal("gig_first_cycle")) or cycle - last_signal_cycle < int(_bal("gig_gap_cycles")) or signals_seen >= maxi(int(_bal("gig_cap_signals")), int(_bal("gig_cap_signals_hard"))):
		return  # no signal is open here, so past the soft cap the board still draws one, up to the hard cap (2026-11-12)
	var elig: Array = []
	for g in defs:
		if eligible(g):
			elig.append(g)
	if elig.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + cycle * 7919
	var total := 0.0
	for g in elig:
		total += maxf(0.0, float(g.get("weight", 1)))
	var pick: Dictionary = elig[0]
	if total > 0.0:
		var r := rng.randf() * total
		for g in elig:
			r -= maxf(0.0, float(g.get("weight", 1)))
			if r <= 0.0:
				pick = g
				break
	_open_signal(pick, cycle, rng)

## A signal def may open now: right kind, never done, skipped or open, its tree holds, the Flagship is in its system, every good it
## names passes Availability.
func eligible(g: Dictionary) -> bool:
	var id := str(g.get("id", ""))
	if str(g.get("kind", "")) != "signal" or done.has(id) or skipped.has(id) or not offer(id).is_empty():
		return false
	var sys := int(g.get("system", 0))
	if sys > 0 and sys != main.flight.system_id():
		return false
	if g.has("when") and not Conditions.eval(g["when"]):
		return false
	for o in g.get("options", []):
		for e in o.get("gives", []):
			var gd := _good_of(e)
			if gd != "" and not Availability.good(gd):
				return false
	return true

## T340: pure check. `planets`: [{"pos": Vector3, "dead": bool}]; `lanes`: [[p0, ctrl, p2]] quadratic Beziers (route_line.gd maths), x/z plane.
## A point is clear when it is at least `min_planet_dist` (plus the planet's own radius `r`, when given) from every living planet and `min_lane_dist` from every lane curve.
## A point within `min_planet_dist` of a dead planet is at that world and is allowed (a marker may sit at a dead planet).
static func clear_of_map(pos: Vector3, planets: Array, lanes: Array, min_planet_dist: float, min_lane_dist: float) -> bool:
	var p := Vector2(pos.x, pos.z)
	var at_dead := false
	for w in planets:
		var c: Vector3 = w["pos"]
		if p.distance_to(Vector2(c.x, c.z)) < min_planet_dist + float(w.get("r", 0.0)):  # the gap is measured from the planet surface (r = drawn radius)
			if not bool(w.get("dead", false)):
				return false
			at_dead = true
	if at_dead:
		return true
	for ln in lanes:
		if _lane_dist(p, ln) < min_lane_dist:
			return false
	return true

## Distance from a plane point to a sampled quadratic Bezier (24 segments).
static func _lane_dist(p: Vector2, ln: Array) -> float:
	var best := INF
	var prev := Vector2.ZERO
	for i in 25:
		var t := float(i) / 24.0
		var u := 1.0 - t
		var v: Vector3 = (ln[0] as Vector3) * (u * u) + (ln[1] as Vector3) * (2.0 * u * t) + (ln[2] as Vector3) * (t * t)
		var q := Vector2(v.x, v.z)
		if i > 0:
			var ab := q - prev
			var l2 := ab.length_squared()
			var k := clampf((p - prev).dot(ab) / l2, 0.0, 1.0) if l2 > 0.0 else 0.0
			best = minf(best, p.distance_to(prev + ab * k))
		prev = q
	return best

## Planets of the current system and the lane curves of the established routes, for clear_of_map.
func map_obstacles(sys: int) -> Dictionary:
	var planets: Array = []
	var mp = main.map
	for i in mp.planets.size():
		if i < mp.positions.size() and int(mp.planets[i].get("system", 1)) == sys:
			planets.append({"pos": mp.positions[i], "dead": DeadWorlds.is_dead(mp.planets[i]), "r": mp.planet_radius(i)})
	var lanes: Array = []
	for rec in main.engine.routes:
		var a := int(rec["a"])
		var b := int(rec["b"])
		var pa := Vector3.INF
		var pb := Vector3.INF
		if a <= -1000:
			var cc: Dictionary = mp._cluster_by_node(a)
			if not cc.is_empty() and int(cc["system"]) == sys:
				pa = Vector3(float(cc["x"]), 0.0, float(cc["y"])) * mp.MAP_UNIT_SCALE
		elif a >= 0 and a < mp.positions.size() and int(mp.planets[a].get("system", 1)) == sys:
			pa = mp.positions[a]
		if b < 0:
			var st = mp.stations.get(-b)
			if st != null and -b == sys:
				pb = st.position
		elif b < mp.positions.size() and int(mp.planets[b].get("system", 1)) == sys:
			pb = mp.positions[b]
		if pa == Vector3.INF or pb == Vector3.INF:
			continue
		var dir: Vector3 = (pb - pa).normalized()
		var p0: Vector3 = pa + dir * mp.planet_radius(maxi(a, 0)) * RouteLineScript.GAP
		var p2: Vector3 = pb - dir * mp.planet_radius(maxi(b, 0)) * RouteLineScript.GAP
		var chord := p0.distance_to(p2)
		var c: Vector3 = (p0 + p2) * 0.5 + Vector3.UP.cross(dir).normalized() * chord * RouteLineScript.BOW
		var sw = RouteOffset.sun_waypoint(pa, pb, mp.sun_list())
		if sw != null:
			var wt: float = clampf(p0.distance_to(sw) / maxf(p0.distance_to(sw) + sw.distance_to(p2), 0.001), 0.15, 0.85)
			c = (sw - p0 * ((1.0 - wt) * (1.0 - wt)) - p2 * (wt * wt)) / (2.0 * (1.0 - wt) * wt)
		lanes.append([p0, c, p2])
	return {"planets": planets, "lanes": lanes}

## Moves `pos` off every lane and living planet by the least step: rings of growing radius round it, 16 fixed directions from `ang0`.
## A point at a dead planet stays. Returns `pos` when nothing clear is found within the search.
func nudge_clear(pos: Vector3, sys: int, ang0: float) -> Vector3:
	var ob := map_obstacles(sys)
	var mpd := _bal("gig_min_planet_dist")
	var mld := _bal("gig_min_lane_dist")
	if clear_of_map(pos, ob["planets"], ob["lanes"], mpd, mld):
		return pos
	var step := maxf(0.1, minf(mpd, mld) * 0.5)
	for ring in range(1, 41):
		for k in 16:
			var a := ang0 + TAU * float(k) / 16.0
			var q := pos + Vector3(cos(a), 0.0, sin(a)) * step * float(ring)
			if clear_of_map(q, ob["planets"], ob["lanes"], mpd, mld):
				return q
	return pos

const SIGNAL_RINGS := 4
const SIGNAL_DIRS := 8

func _open_signal(g: Dictionary, cycle: int, rng: RandomNumberGenerator) -> void:
	var base: Vector3 = main.flight.ship_position()
	var sys: int = main.flight.system_id()
	var ob := map_obstacles(sys)
	var mpd := _bal("gig_min_planet_dist")
	var mld := _bal("gig_min_lane_dist")
	var pos := Vector3.INF
	var ang0 := rng.randf() * TAU  # first candidate is the plain draw; the rest follow in a fixed order
	for ring in SIGNAL_RINGS:
		var dist := _bal("gig_marker_dist", 1.0) + float(ring) * maxf(mpd, mld) * 0.5
		for k in SIGNAL_DIRS:
			var ang := ang0 if (ring == 0 and k == 0) else rng.randf() * TAU
			var q := base + Vector3(cos(ang), 0.0, sin(ang)) * dist
			if clear_of_map(q, ob["planets"], ob["lanes"], mpd, mld):
				pos = q
				break
		if pos != Vector3.INF:
			break
	if pos == Vector3.INF:
		return  # no clear point this cycle: no signal (the next cycle draws again)
	var life := Conditions.balance_value(str(g.get("expires", "balance.gig_expire_cycles")))
	offers.append({"uid": str(g["id"]), "id": str(g["id"]), "kind": "signal", "target": {"kind": "point", "sys": main.flight.system_id(), "pos": [pos.x, 0.0, pos.z]},
		"due": _now() + life, "accepted": false, "req": {}, "rewards": []})
	signals_seen += 1
	last_signal_cycle = cycle
	changed.emit()

# ---- the player's side -----------------------------------------------------------------------------------------------

## Marks the offer accepted and orders the Flagship to its target. "" = ordered; else request_fly's reason ("busy", "no_gate", ...) or "no_offer".
func accept(uid: String) -> String:
	var o := offer(uid)
	if o.is_empty():
		return "no_offer"
	var t: Dictionary = o["target"]
	var r := ""
	if str(o["kind"]) == "opening" and main.flight.docked_at() == str(main.map.planets[int(t["index"])].get("id", "")):
		on_arrived_planet(main.flight.docked_at())  # already at the capital: the charter cargo is delivered at once
		return ""
	if str(t["kind"]) == "planet":
		r = main.flight.request_fly({"kind": "planet", "index": int(t["index"])})
	else:
		var p: Array = t["pos"]
		r = main.flight.request_fly({"kind": "point", "pos": Vector3(float(p[0]), 0.0, float(p[2]))})
	if r == "":
		o["accepted"] = true
	return r

func target_pos(o: Dictionary) -> Vector3:
	var p: Array = o["target"].get("pos", [0, 0, 0])
	return Vector3(float(p[0]), 0.0, float(p[2]))

## Game clock tick (main._process): expiry, a signal left behind in another system, a reached signal waiting for a free window.
func tick(now: float) -> void:
	if offers.is_empty() and pending == "":
		return
	var gone := false
	for i in range(offers.size() - 1, -1, -1):
		var o: Dictionary = offers[i]
		var left_sys: bool = str(o["kind"]) == "signal" and main.flight.state() != "flying" and int(o["target"]["sys"]) != main.flight.system_id()
		if now >= float(o["due"]) or left_sys:
			if str(o["kind"]) == "signal":
				skipped[str(o["id"])] = true  # free expiry: no penalty, no log; the gig is gone for the run
				if now >= float(o["due"]):
					gigs_expired += 1
					main.note("gigs_expired")  # CEO endings: an open signal ran out of time
			if pending == str(o["uid"]):
				pending = ""
			offers.remove_at(i)
			gone = true
	if gone:
		changed.emit()
	if pending != "" and not offer(pending).is_empty() and main.gig_window_free():
		var uid := pending
		pending = ""
		arrival.emit(uid)

func on_arrived_point(sys: int, pos: Vector3) -> void:
	for o in offers.duplicate():
		if int(o["target"]["sys"]) == sys and target_pos(o).distance_to(pos) <= _bal("gig_arrive_radius", 0.3):
			if str(o["kind"]) == "salvage":
				_scoop(o)
				return
			if str(o["kind"]) == "signal":
				pending = str(o["uid"])
				return

## The player picked option `opt` (index; -1 for a gig with no options) of a reached signal. Applies gives and costs, closes the offer,
## marks it done. Returns {outcome (story id), epilogue (story id), lines (effect lines)}; {} when there is no such offer.
func choose(uid: String, opt: int) -> Dictionary:
	var o := offer(uid)
	if o.is_empty() or str(o["kind"]) != "signal":
		return {}
	var g: Dictionary = _by_id.get(str(o["id"]), {})
	var options: Array = g.get("options", [])
	var lines: Array = []
	var outcome := ""
	if opt >= 0 and opt < options.size():
		var op: Dictionary = options[opt]
		lines.append_array(apply(op.get("gives", []), {}))
		lines.append_array(apply(op.get("costs", []), {}))
		var sfx: String = BRANCH_SUFFIX.get(Conditions.run_branch(), "")
		outcome = str(op.get("outcome", ""))
		if outcome != "" and sfx != "":
			outcome += "_" + sfx
	offers.erase(o)
	done[str(o["id"])] = true
	gigs_done += 1
	main.note("gigs_done")
	changed.emit()
	return {"outcome": outcome, "epilogue": str(g.get("epilogue", "")), "lines": lines}

# ---- effects ---------------------------------------------------------------------------------------------------------

func _num(e: Dictionary, prefix: String) -> float:
	var key := str(e.get("key", prefix + str(e.get("size", ""))))
	return _bal(key)

func _good_of(e: Dictionary) -> String:
	if e.has("by_branch"):
		var m: Dictionary = e["by_branch"]
		var b := Conditions.run_branch()
		return str(m.get(b, m.get("other", ""))) if b != "" or m.has("other") else ""
	return str(e.get("good", ""))

## Applies effects (rewards and costs) and returns their lines for the result window. ctx: unused today.
func apply(effects: Array, ctx: Dictionary) -> Array:
	var lines: Array = []
	for e in effects:
		var kind := str(e.get("kind", ""))
		match kind:
			"cash":
				var n := roundi(_num(e, "gig_cash_"))
				main.cash += n
				lines.append(StoryText.get_or("GIG_EFF_CASH", "+{n} credits.", {"n": n}))
			"cash_fee":
				var n3 := mini(int(main.cash), roundi(_num(e, "gig_fee_")))
				main.cash -= n3
				lines.append(StoryText.get_or("GIG_EFF_FEE", "-{n} credits.", {"n": n3}))
			"goods":
				var gd := _good_of(e)
				var put := _store_lot(gd, roundi(_num(e, "gig_lot_")))
				if put > 0:
					lines.append(StoryText.get_or("GIG_EFF_GOODS", "{n} {good} in storage.", {"n": put, "good": Ui.good_name(gd).to_lower()}))
			"story":
				var sid := str(e.get("id", ""))
				if StoryText.has_text(sid):
					lines.append(StoryText.get_text(sid))
			"scout_idle":
				var c := _num(e, "gig_idle_")
				main.flight.hold_for(main.flight.idle_left() + c)
				lines.append(StoryText.get_or("GIG_EFF_IDLE", "The Flagship is held for {n} cycles.", {"n": snappedf(c, 0.1)}))
			_:
				push_error("Gigs: unknown effect kind '%s'" % kind)
	return lines

## Puts a goods lot into the storage of the nearest established world (by flight time from the Flagship; the next nearest takes what does not fit).
## Returns units stored. No sale is noted: nothing touches share.
func _store_lot(good: String, units: int) -> int:
	if good == "" or units <= 0:
		return 0
	var order: Array = []
	for i in main.map.planets.size():
		var pid := str(main.map.planets[i].get("id", ""))
		if main.flight.established(pid):
			var eta: float = main.flight.eta_cycles(pid)
			if eta >= 0.0:
				order.append([eta, i])
	order.sort()
	var left := units
	for pair in order:
		left -= main.storage.add(main.storage.planet_key(int(pair[1])), good, left)
		if left <= 0:
			break
	return units - left

# ---- lint and save ---------------------------------------------------------------------------------------------------

## Problems of data/gigs.json against the other data files (balance keys, text ids, goods, atoms). Empty = clean.
static func lint() -> Array:
	var errs: Array = []
	var d := read_data()
	var bal := Conditions.read_balance()
	var seen := {}
	for g in d.get("gigs", []):
		var id := str(g.get("id", ""))
		if id == "" or seen.has(id):
			errs.append("gigs: missing or duplicate id '%s'" % id)
		seen[id] = true
		if not g.has("kind"):
			errs.append("%s: no kind" % id)
		if g.has("when"):
			Conditions.lint(g["when"], "gig " + id, errs)
		if g.has("expires") and not bal.has(str(g["expires"]).trim_prefix("balance.")):
			errs.append("%s: unknown balance key '%s'" % [id, g["expires"]])
		for k in ["title", "hook", "body", "epilogue"]:
			if g.has(k) and not StoryText.has_text(str(g[k])):
				errs.append("%s: missing text id '%s'" % [id, g[k]])
		for o in g.get("options", []):
			if not StoryText.has_text(str(o.get("text", ""))):
				errs.append("%s: missing text id '%s'" % [id, o.get("text", "")])
			for e in o.get("gives", []) + o.get("costs", []):
				_lint_effect(e, id, errs, bal)
	return errs

static func _lint_effect(e: Dictionary, where: String, errs: Array, bal: Dictionary) -> void:
	var kind := str(e.get("kind", ""))
	if not ["cash", "cash_fee", "goods", "story", "scout_idle"].has(kind):
		errs.append("%s: unknown effect kind '%s'" % [where, kind])
	var prefix := {"cash": "gig_cash_", "cash_fee": "gig_fee_", "goods": "gig_lot_", "scout_idle": "gig_idle_"}
	var key := str(e.get("key", str(prefix.get(kind, "")) + str(e.get("size", ""))))
	if prefix.has(kind) and not bal.has(key):
		errs.append("%s: unknown balance key '%s'" % [where, key])
	if kind == "goods":
		var goods: Array = e.get("by_branch", {}).values() if e.has("by_branch") else [str(e.get("good", ""))]
		for gd in goods:
			if not Goods.has(str(gd)):
				errs.append("%s: unknown good '%s'" % [where, gd])

func to_dict() -> Dictionary:
	return {"seed": seed_value, "offers": offers.duplicate(true), "done": done.keys(), "skipped": skipped.keys(),
		"signals_seen": signals_seen, "gigs_done": gigs_done, "gigs_expired": gigs_expired,
		"last_signal_cycle": last_signal_cycle, "uid": _uid}

## A missing or bad dictionary (a save from before gigs) means an empty board, nothing done.
func from_dict(s) -> void:
	var keep_seed := seed_value
	reset()
	if typeof(s) != TYPE_DICTIONARY:
		return
	seed_value = int(s.get("seed", keep_seed))
	for o in s.get("offers", []):
		if typeof(o) == TYPE_DICTIONARY and o.has("uid") and o.has("target") and o.has("due") and str(o.get("kind", "")) != "rush":  # an old save's rush offers are dropped
			offers.append(o)
	for k in s.get("done", []):
		done[str(k)] = true
	for k in s.get("skipped", []):
		skipped[str(k)] = true
	signals_seen = int(s.get("signals_seen", 0))
	gigs_done = int(s.get("gigs_done", 0))
	gigs_expired = int(s.get("gigs_expired", 0))
	last_signal_cycle = int(s.get("last_signal_cycle", -100000))
	_uid = int(s.get("uid", 0))
	changed.emit()
