class_name Gigs
extends RefCounted
## T271 the gig engine: one board for every Flagship job (design/proposals/2026-11-06-empire-growth-v2.md section 3.2).
## Data: data/gigs.json (signals, rush rewards); numbers: data/balance.json gig_* keys (all PLACEHOLDERS). Never skill points, never share.
## Kinds (open field "kind"): "signal" (a marker in open space; fly there, a window opens with two neutral options; one-time, expires for
## free, an expired signal is gone for the run) and "rush" (a world wants units of a good by a deadline; hand sale or unload at that world
## counts; posted by Gigs.post_rush; T272 generator _gen_rush: one a cycle by seeded weighted draw) and "salvage" (T296: cargo pods a raid dropped, posted by
## Gigs.post_salvage from game/raids.gd; fly there before they fade, the goods load into the Flagship hold; no window, no board-size limit) and "opening" (T298: after the last Bazaar stage; the Flagship flies the charter cargo to the capital, no window, no expiry to speak of; docking there calls Bazaar.open() and the run is won; post_opening, ensure_opening).
## Board: up to gig_board_max open offers (any kind); one open signal at a time, gig_gap_cycles between signals, gig_cap_signals per run,
## none before gig_first_cycle. The draw is seeded (saved seed + cycle), so a save's list is stable. Deadlines are on the game clock.
## An offer: {uid, id, kind, target {kind "point"|"planet", sys, pos [x,y,z] | index}, due (game time), accepted, req {good, units, got}, rewards}.
## Rewards land through apply(): goods in the nearest established world's storage (no share), cash, need credit (the delivery counts
## as that need met for some cycles: prosperity.add_fill before the cycle's progress), a one-off perk, knowledge, a story line.
## Condition atoms (game/conditions.gd): gig_done:<id>, gig_open. Saved under "gigs" (save version 15; older saves load empty).

const StoryText := preload("res://game/story_text.gd")
const PATH := "res://data/gigs.json"
const BRANCH_SUFFIX := {"mil": "MIL", "lux": "LUX", "min": "MIN", "bio": "BIO"}

signal changed                 # the board changed (offer opened, done, expired)
signal arrival(uid: String)    # the Flagship reached a signal marker: main opens the window

var main: Node = null
var defs: Array = []
var rush_rewards: Array = []
var offers: Array = []         # open offers, oldest first
var done := {}                 # data id -> true (finished)
var skipped := {}              # data id -> true (expired, gone for the run)
var credits: Array = []        # {planet: int, good, units, left}: need credits still running
var perks := {}                # perk id -> cycles left
var knowledge: Array = []      # knowledge ids held
var signals_seen := 0
var rush_done := 0
var last_signal_cycle := -100000
var rush_last := {}            # T272: planet index -> cycle a rush was last posted there (cooldown)
var rush_posted := 0
var last_rush_cycle := -100000
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
	rush_rewards = d.get("rush", {}).get("rewards", [])
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
		main.flight.delivered.connect(on_delivered)

func reset() -> void:
	offers = []
	done = {}
	skipped = {}
	credits = []
	perks = {}
	knowledge = []
	signals_seen = 0
	rush_done = 0
	last_signal_cycle = -100000
	rush_last = {}
	rush_posted = 0
	last_rush_cycle = -100000
	pending = ""
	_uid = 0

func _bal(key: String, dflt: float = 0.0) -> float:
	return float(main.balance.get(key, dflt)) if main != null else dflt

func _now() -> float:
	return main.game_time()

func enabled() -> bool:
	return main != null and main.flight != null and main.flight.is_enabled()

func has_def(id: String) -> bool:
	return _by_id.has(id)

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

func perk_active(id: String) -> bool:
	return float(perks.get(id, 0.0)) > 0.0

func has_knowledge(id: String) -> bool:
	return knowledge.has(id)

## T296: cargo pods at `pos` in system `sys`: `units` of `good`, fading after `life` cycles. Not limited by the board size (a raid made them).
func post_salvage(uid: String, sys: int, pos: Vector3, good: String, units: int, count: int, life: float) -> void:
	offers.append({"uid": uid, "id": uid, "kind": "salvage", "target": {"kind": "point", "sys": sys, "pos": [pos.x, 0.0, pos.z]},
		"due": _now() + life, "accepted": false, "req": {}, "rewards": [], "pods": [{"good": good, "units": units}], "count": maxi(1, count)})
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
	if o.is_empty() or main.planet_index_of(planet_id) != int(o["target"]["index"]):
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
	if left_pods.is_empty():
		offers.erase(o)
		main.post_notice(StoryText.get_or("NOT_SALVAGE_DONE", "Pods scooped into the Flagship hold: {lines}.", {"lines": ", ".join(lines)}))
	else:
		main.post_notice(StoryText.get_or("NOT_SALVAGE_FULL", "The Flagship hold is full. Some pods stay adrift.", {}))
	changed.emit()

# ---- spawn -----------------------------------------------------------------------------------------------------------

## Start of every cycle (main): perks age, then at most one new signal may open.
func on_cycle(cycle: int) -> void:
	for k in perks.keys():
		perks[k] = float(perks[k]) - 1.0
		if float(perks[k]) <= 0.0:
			perks.erase(k)
	_gen_rush(cycle)
	if not enabled() or not board_room() or not open_signal().is_empty():
		return
	if cycle < int(_bal("gig_first_cycle")) or cycle - last_signal_cycle < int(_bal("gig_gap_cycles")) or signals_seen >= int(_bal("gig_cap_signals")):
		return
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

func _open_signal(g: Dictionary, cycle: int, rng: RandomNumberGenerator) -> void:
	var ang := rng.randf() * TAU
	var base: Vector3 = main.flight.ship_position()
	var pos := base + Vector3(cos(ang), 0.0, sin(ang)) * _bal("gig_marker_dist", 1.0)
	var life := Conditions.balance_value(str(g.get("expires", "balance.gig_expire_cycles")))
	offers.append({"uid": str(g["id"]), "id": str(g["id"]), "kind": "signal", "target": {"kind": "point", "sys": main.flight.system_id(), "pos": [pos.x, 0.0, pos.z]},
		"due": _now() + life, "accepted": false, "req": {}, "rewards": []})
	signals_seen += 1
	last_signal_cycle = cycle
	changed.emit()

## A rush order (generator in a later task): `planet` index of an established world, `units` of `good` by `deadline_cycles` of game time.
## Returns the uid, "" when it cannot be posted (board full, good hidden, world not established or already asking).
func post_rush(planet: int, good: String, units: int, deadline_cycles: float) -> String:
	if not enabled() or not board_room() or units <= 0 or not Availability.good(good) or not main.planet_established(planet):
		return ""
	for o in offers:
		if str(o["kind"]) == "rush" and int(o["target"].get("index", -1)) == planet:
			return ""
	_uid += 1
	var uid := "RUSH%d" % _uid
	offers.append({"uid": uid, "id": uid, "kind": "rush", "target": {"kind": "planet", "sys": main.system_of(planet), "index": planet},
		"due": _now() + deadline_cycles, "accepted": false, "req": {"good": good, "units": units, "got": 0}, "rewards": rush_rewards.duplicate(true)})
	changed.emit()
	return uid

## ---- rush generator (T272) ----------------------------------------------------------------------------------------
## Hooks for later tasks: a shortage weather hit on a world (the good it lacks, "" = none) and a hub that feeds a world (posts fewer).
func shortage_good(planet: int) -> String:
	return main.events.shortage_good_at(planet)  # T280: the live house shortage

func hub_fed(_planet: int) -> bool:
	return false

## The goods a world's unmet needs still want (visible goods only).
func _unmet_goods(i: int) -> Array:
	var out: Array = []
	for n in main.prosperity.needs(i):
		if not bool(n["locked"]) and not bool(n["met"]) and str(n["good"]) != "?" and Availability.good(str(n["good"])):
			out.append(str(n["good"]))
	return out

## One candidate per world: {planet, good, weight, why}. Reasons: "shortage" (weather hook), "tier" (one step from a tier-up with a short need),
## "restless". A world with a reason but no unmet visible need is skipped, except a shortage (it names its own good).
func rush_candidates(cycle: int) -> Array:
	var out: Array = []
	var cool := int(_bal("rush_cooldown_cycles"))
	var pr = main.prosperity
	for i in main.map.planets.size():
		if not main.planet_established(i) or pr.tier(i) < 1 or pr.is_barren(i):
			continue
		if rush_last.has(i) and cycle - int(rush_last[i]) < cool:
			continue
		var pid := str(main.map.planets[i].get("id", ""))
		if not main.flight.established(pid) or main.flight.eta_cycles(pid) < 0.0:
			continue
		var unmet := _unmet_goods(i)
		var weight := 0.0
		var why := ""
		var good := ""
		var sg := shortage_good(i)
		if sg != "" and Availability.good(sg):
			weight += _bal("rush_weight_shortage")
			why = "shortage"
			good = sg
		if not unmet.is_empty():
			if pr.tier(i) < pr.max_tier() and pr.steps(i) + 1 >= pr.steps_needed(i):
				weight += _bal("rush_weight_tier")
				why = why if why != "" else "tier"
			if pr.restless(i):
				weight += _bal("rush_weight_restless")
				why = why if why != "" else "restless"
			if good == "":
				good = str(unmet[0])
		if weight <= 0.0 or good == "":
			continue
		if hub_fed(i):
			weight *= maxf(0.0, _bal("rush_hub_mult", 1.0))
		out.append({"planet": i, "good": good, "weight": weight, "why": why, "unmet": unmet})
	return out

## Start of a cycle: at most one new rush order, by a seeded weighted draw. Board room, first cycle, gap and per-world cooldown apply.
func _gen_rush(cycle: int) -> void:
	if not enabled() or not board_room() or cycle < int(_bal("rush_first_cycle")) or cycle - last_rush_cycle < int(_bal("rush_gap_cycles")):
		return
	var cands := rush_candidates(cycle)
	var total := 0.0
	for c in cands:
		total += float(c["weight"])
	if total <= 0.0:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + cycle * 104729 + 17
	var r := rng.randf() * total
	var pick: Dictionary = cands[0]
	for c in cands:
		r -= float(c["weight"])
		if r <= 0.0:
			pick = c
			break
	var i := int(pick["planet"])
	var good := str(pick["good"])
	if pick["unmet"].size() > 1 and str(pick["why"]) != "shortage":
		good = str(pick["unmet"][rng.randi() % pick["unmet"].size()])
	var units := maxi(1, roundi(float(main.prosperity.demand(i)) * _bal("rush_lot_mult", 1.0)))
	var eta: float = main.flight.eta_cycles(str(main.map.planets[i].get("id", "")))
	var uid := post_rush(i, good, units, eta * _bal("rush_deadline_mult", 1.0) + _bal("rush_deadline_add"))
	if uid == "":
		return
	var o := offer(uid)
	o["why"] = str(pick["why"])
	rush_last[i] = cycle
	rush_posted += 1
	last_rush_cycle = cycle
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

## Units sold by hand or unloaded at a world: counts for a rush order there; complete = rewards.
func on_delivered(planet_id: String, good: String, units: int) -> void:
	var pi: int = main.planet_index_of(planet_id)
	for o in offers:
		if str(o["kind"]) != "rush" or int(o["target"].get("index", -1)) != pi or str(o["req"]["good"]) != good:
			continue
		o["req"]["got"] = int(o["req"]["got"]) + units
		if int(o["req"]["got"]) >= int(o["req"]["units"]):
			_finish_rush(o)
		else:
			changed.emit()
		return

func _finish_rush(o: Dictionary) -> void:
	offers.erase(o)
	rush_done += 1
	var ctx := {"good": str(o["req"]["good"]), "units": int(o["req"]["units"]), "planet": int(o["target"]["index"])}
	var lines := apply(o["rewards"], ctx)
	main.post_notice(StoryText.get_or("NOT_GIG_RUSH_DONE", "Rush order delivered at {planet}. {lines}", {"planet": main.planet_name(int(ctx["planet"])), "lines": " ".join(lines)}))
	changed.emit()

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

## Applies effects (rewards and costs) and returns their lines for the result window. ctx: good, units, planet (rush).
func apply(effects: Array, ctx: Dictionary) -> Array:
	var lines: Array = []
	for e in effects:
		var kind := str(e.get("kind", ""))
		match kind:
			"cash":
				var n := roundi(_num(e, "gig_cash_"))
				main.cash += n
				lines.append(StoryText.get_or("GIG_EFF_CASH", "+{n} credits.", {"n": n}))
			"cash_pct":
				var n2 := roundi(float(int(ctx.get("units", 0)) * Markets.value_of(str(ctx.get("good", "")))) * _bal(str(e.get("key", ""))))
				main.cash += n2
				lines.append(StoryText.get_or("GIG_EFF_CASH", "+{n} credits.", {"n": n2}))
			"cash_fee":
				var n3 := mini(int(main.cash), roundi(_num(e, "gig_fee_")))
				main.cash -= n3
				lines.append(StoryText.get_or("GIG_EFF_FEE", "-{n} credits.", {"n": n3}))
			"goods":
				var gd := _good_of(e)
				var put := _store_lot(gd, roundi(_num(e, "gig_lot_")))
				if put > 0:
					lines.append(StoryText.get_or("GIG_EFF_GOODS", "{n} {good} in storage.", {"n": put, "good": Ui.good_name(gd).to_lower()}))
			"need_credit":
				var pl := int(ctx.get("planet", -1))
				var cycles := int(_bal(str(e.get("cycles_key", ""))))
				if pl >= 0 and cycles > 0:
					credits.append({"planet": pl, "good": str(ctx.get("good", "")), "units": main.prosperity.demand(pl), "left": cycles})
					lines.append(StoryText.get_or("GIG_EFF_CREDIT", "The need counts as met for {n} cycles.", {"n": cycles}))
			"perk":
				perks[str(e.get("id", ""))] = _bal("gig_perk_cycles")
				lines.append(StoryText.get_or("GIG_EFF_PERK", "A small edge for {n} cycles.", {"n": int(_bal("gig_perk_cycles"))}))
			"knowledge":
				var kid := str(e.get("id", ""))
				if not knowledge.has(kid):
					knowledge.append(kid)
				lines.append(StoryText.get_or("GIG_EFF_KNOWLEDGE", "You learned something.", {}))
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

## Before prosperity.end_cycle (main): every running need credit fills its world's need for this cycle.
func credit_tick() -> void:
	for i in range(credits.size() - 1, -1, -1):
		var c: Dictionary = credits[i]
		main.prosperity.add_fill(int(c["planet"]), str(c["good"]), int(c["units"]))
		c["left"] = int(c["left"]) - 1
		if int(c["left"]) <= 0:
			credits.remove_at(i)

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
	for e in d.get("rush", {}).get("rewards", []):
		_lint_effect(e, "rush", errs, bal)
	return errs

static func _lint_effect(e: Dictionary, where: String, errs: Array, bal: Dictionary) -> void:
	var kind := str(e.get("kind", ""))
	if not ["cash", "cash_pct", "cash_fee", "goods", "need_credit", "perk", "knowledge", "story", "scout_idle"].has(kind):
		errs.append("%s: unknown effect kind '%s'" % [where, kind])
	var prefix := {"cash": "gig_cash_", "cash_fee": "gig_fee_", "goods": "gig_lot_", "scout_idle": "gig_idle_"}
	var key := str(e.get("key", str(prefix.get(kind, "")) + str(e.get("size", "")))) if kind != "need_credit" else str(e.get("cycles_key", ""))
	if (prefix.has(kind) or kind == "cash_pct" or kind == "need_credit") and not bal.has(key):
		errs.append("%s: unknown balance key '%s'" % [where, key])
	if kind == "goods":
		var goods: Array = e.get("by_branch", {}).values() if e.has("by_branch") else [str(e.get("good", ""))]
		for gd in goods:
			if not Goods.has(str(gd)):
				errs.append("%s: unknown good '%s'" % [where, gd])

func to_dict() -> Dictionary:
	return {"seed": seed_value, "offers": offers.duplicate(true), "done": done.keys(), "skipped": skipped.keys(), "credits": credits.duplicate(true),
		"perks": perks.duplicate(), "knowledge": knowledge.duplicate(), "signals_seen": signals_seen, "rush_done": rush_done,
		"last_signal_cycle": last_signal_cycle, "uid": _uid, "rush_last": rush_last.duplicate(), "rush_posted": rush_posted, "last_rush_cycle": last_rush_cycle}

## A missing or bad dictionary (a save from before gigs) means an empty board, nothing done.
func from_dict(s) -> void:
	var keep_seed := seed_value
	reset()
	if typeof(s) != TYPE_DICTIONARY:
		return
	seed_value = int(s.get("seed", keep_seed))
	for o in s.get("offers", []):
		if typeof(o) == TYPE_DICTIONARY and o.has("uid") and o.has("target") and o.has("due"):
			offers.append(o)
	for k in s.get("done", []):
		done[str(k)] = true
	for k in s.get("skipped", []):
		skipped[str(k)] = true
	for c in s.get("credits", []):
		if typeof(c) == TYPE_DICTIONARY:
			credits.append({"planet": int(c.get("planet", -1)), "good": str(c.get("good", "")), "units": int(c.get("units", 0)), "left": int(c.get("left", 0))})
	if typeof(s.get("perks")) == TYPE_DICTIONARY:
		for k in s["perks"]:
			perks[str(k)] = float(s["perks"][k])
	for k in s.get("knowledge", []):
		knowledge.append(str(k))
	signals_seen = int(s.get("signals_seen", 0))
	rush_done = int(s.get("rush_done", 0))
	last_signal_cycle = int(s.get("last_signal_cycle", -100000))
	_uid = int(s.get("uid", 0))
	if typeof(s.get("rush_last")) == TYPE_DICTIONARY:
		for k in s["rush_last"]:
			rush_last[int(k)] = int(s["rush_last"][k])
	rush_posted = int(s.get("rush_posted", 0))
	last_rush_cycle = int(s.get("last_rush_cycle", -100000))
