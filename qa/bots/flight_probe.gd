extends SceneTree
## QA 2026-11-08 (T182): flight, discovery, post, pause and save checks for the Pathfinder (owned by qa-analyst).
## Drives the real game scene headless through the calls the UI and the bots use (main.set_paused, main.fly_to,
## main.buy_permit, main.learn_skill, main.save_now, SaveGame, the Pathfinder API). Nothing under game/ or data/ is changed.
## Probe-only inputs: cash and skill points are added so the checks are not blocked by money.
## Output: one "CHECK <name> <ok|FAIL|SKIP> <detail>" line per check, then "PROBE_END fails=<n> checks=<n>".
## Run through qa/bots/flight_probe.sh (sets HOME to a scratch folder). Option: --seed=<int>.

const MAIN_SCENE := "res://game/main.tscn"
const SaveGame := preload("res://game/save_game.gd")
const DeadWorlds := preload("res://game/dead_worlds.gd")
const Systems := preload("res://game/systems.gd")
const SETTLE_LIMIT := 4000.0  # cycles: longest a flight or build may take before it counts as stuck

var main: Node = null
var seed_value := 1
var phase := 0
var checks := 0
var fails := 0

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--seed="):
			seed_value = int(arg.trim_prefix("--seed="))
	SaveGame.continue_requested = false
	SaveGame.clear()
	SaveGame.pending_ceo = ""
	SaveGame.pending_ship = ""

func _process(_delta: float) -> bool:
	if phase == 0:
		phase = 1
		_new_game()
		_run()
	return true

func _new_game() -> void:
	main = load(MAIN_SCENE).instantiate()
	get_root().add_child(main)
	main.events.rng.seed = seed_value
	if main.preface != null:
		main._dismiss_preface()
	main._tut_skip()
	main.set_process(false)  # the probe calls main._process itself where the clock matters
	main.set_paused(true)

func _reload() -> void:
	get_root().remove_child(main)
	main.free()
	SaveGame.continue_requested = true
	main = load(MAIN_SCENE).instantiate()
	get_root().add_child(main)
	if main.preface != null:
		main._dismiss_preface()
	main.set_process(false)
	SaveGame.continue_requested = false

func _check(check_name: String, ok: bool, detail: String) -> void:
	checks += 1
	if not ok:
		fails += 1
	print("CHECK %s %s %s" % [check_name, "ok" if ok else "FAIL", detail])

func _skip(check_name: String, detail: String) -> void:
	print("CHECK %s SKIP %s" % [check_name, detail])

func _same_arr(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for k in a.size():
		if absf(float(a[k]) - float(b[k])) > 0.001:
			return false
	return true

## Advances the Pathfinder on the game clock until it is idle (flight and build both finished).
## Returns the cycles used, or -1.0 when it is still busy at the limit.
func _settle(limit: float = SETTLE_LIMIT) -> float:
	var fl = main.flight
	var used := 0.0
	while fl.state() != "idle" and used < limit:
		fl.advance(0.05)
		used += 0.05
	return used if fl.state() == "idle" else -1.0

## Index of a planet of want_system, not yet established (and not discovered when undiscovered), nearest or farthest from the ship.
func _pick_planet(want_system: int, undiscovered: bool, living_only: bool, farthest: bool) -> int:
	var fl = main.flight
	var best := -1
	var best_d := -1.0
	for i in main.map.planets.size():
		var pid := str(main.map.planets[i].get("id", ""))
		if main.system_of(i) != want_system or fl.established(pid):
			continue
		if undiscovered and fl.discovered(pid):
			continue
		if living_only and DeadWorlds.is_dead(main.map.planets[i]):
			continue
		var d: float = fl.ship_position().distance_to(main.map.positions[i])
		if best < 0 or (farthest and d > best_d) or (not farthest and d < best_d):
			best = i
			best_d = d
	return best

func _run() -> void:
	var fl = main.flight
	_check("discovery.enabled", fl.is_enabled(), "balance discovery_enabled = %s" % str(main.balance.get("discovery_enabled", null)))
	if fl.is_enabled():
		_test_pause()
		_test_targets()
		_test_establish()
		_test_sweep()
		_new_game()
		_test_save_flight()
		_test_save_build()
		_new_game()
		_test_exploration()
	else:
		_skip("pause", "discovery disabled: every planet counts as established")
	print("PROBE_END fails=%d checks=%d" % [fails, checks])
	quit(1 if fails > 0 else 0)

func _test_pause() -> void:
	var fl = main.flight
	var i := _pick_planet(1, true, false, true)
	var r: String = fl.request_fly({"kind": "planet", "index": i})
	_check("pause.setup_fly", r == "" and fl.state() == "flying", "fly to planet index %d -> '%s', state %s" % [i, r, fl.state()])
	var start: Vector3 = fl.ship_position()
	main.time_speed = 1.0
	main.set_paused(false)
	for k in 10:
		main._process(0.5)
	var moved: float = fl.ship_position().distance_to(start)
	_check("pause.moves_when_running", moved > 0.0 or fl.state() != "flying", "moved %.3f in 5 s of game clock, state %s" % [moved, fl.state()])
	main.set_paused(true)
	var p0: Vector3 = fl.ship_position()
	var s0: String = fl.state()
	var t0: float = main.game_time()
	var tg0: Dictionary = fl.target()
	for k in 200:
		main._process(1.0)
	var drift: float = fl.ship_position().distance_to(p0)
	var still: bool = drift < 0.0001 and fl.state() == s0 and is_equal_approx(main.game_time(), t0) and fl.target() == tg0
	_check("pause.ship_still_while_paused", still, "200 paused frames: drift %.6f, state %s -> %s, clock %.4f -> %.4f, in_flight_at_pause %s" % [drift, s0, fl.state(), t0, main.game_time(), str(s0 == "flying")])
	main.set_paused(false)
	for k in 20:
		main._process(0.5)
	var resumed: float = fl.ship_position().distance_to(p0)
	_check("pause.resumes_after_unpause", resumed > 0.0 or fl.state() != s0, "moved %.3f after unpause, state %s" % [resumed, fl.state()])
	main.set_paused(true)
	var used := _settle()
	_check("pause.flight_completes", used >= 0.0, "settled after %.2f cycles, state %s" % [used, fl.state()])

func _test_targets() -> void:
	var fl = main.flight
	var got: Array = []
	fl.arrived_point.connect(func(sys, p): got.append([sys, p]))
	# planet
	var i := _pick_planet(1, true, false, false)
	var pid := str(main.map.planets[i].get("id", ""))
	var r: String = fl.request_fly({"kind": "planet", "index": i})
	var used := _settle()
	_check("target.planet", r == "" and used >= 0.0 and fl.docked_at() == pid and fl.discovered(pid), "%s: refused '%s', settled %.2f cycles, docked '%s', discovered %s" % [pid, r, used, fl.docked_at(), str(fl.discovered(pid))])
	# open space
	var tgt: Vector3 = fl.ship_position() + Vector3(2.0, 0.0, 2.0)
	r = fl.request_fly({"kind": "point", "pos": tgt})
	used = _settle()
	var miss: float = fl.ship_position().distance_to(tgt)
	_check("target.point", r == "" and used >= 0.0 and got.size() == 1, "refused '%s', settled %.2f, arrived_point signals %d, miss %.3f" % [r, used, got.size(), miss])
	# storage station (system 1)
	r = fl.request_fly({"kind": "storage", "index": 1, "pos": Vector3.ZERO})
	used = _settle()
	_check("target.storage", r == "" and used >= 0.0 and fl.system_id() == 1, "refused '%s', settled %.2f, state %s" % [r, used, fl.state()])
	# asteroid cluster with ore (system 1)
	var ci := -1
	for c in 400:
		if main.clusters.valid(c) and main.clusters.system_of(c) == 1 and main.clusters.left(c) > 0:
			ci = c
			break
	if ci < 0:
		_skip("target.cluster", "no cluster with ore in system 1")
	else:
		r = fl.request_fly({"kind": "cluster", "index": ci})
		used = _settle()
		_check("target.cluster", r == "" and used >= 0.0 and fl.state() == "idle", "cluster %d refused '%s', settled %.2f" % [ci, r, used])
	# system jump: refused while closed, then permit, then jump there and back
	r = fl.request_fly({"kind": "storage", "index": 2, "pos": Vector3.ZERO})
	_check("target.jump_closed_refused", r == "no_gate", "request to system 2 before its permit -> '%s'" % r)
	main.cash += 50000
	main.skill_points += 50
	var pr: Dictionary = main.buy_permit(2)
	var lr: Dictionary = {}
	if not bool(pr.get("ok", false)):
		lr = main.learn_skill(str(main.required_skill(2)))
		pr = main.buy_permit(2)
	_check("target.permit_system2", bool(pr.get("ok", false)), "learn %s -> %s; buy permit 2 -> %s" % [str(main.required_skill(2)), str(lr), str(pr)])
	if bool(pr.get("ok", false)):
		r = fl.request_fly({"kind": "storage", "index": 2, "pos": Vector3.ZERO})
		used = _settle()
		_check("target.jump_open_system", r == "" and used >= 0.0 and fl.system_id() == 2, "refused '%s', settled %.2f cycles, system now %d" % [r, used, fl.system_id()])
		r = fl.request_fly({"kind": "storage", "index": 1, "pos": Vector3.ZERO})
		used = _settle()
		_check("target.jump_back", r == "" and used >= 0.0 and fl.system_id() == 1, "refused '%s', settled %.2f cycles, system now %d" % [r, used, fl.system_id()])

func _test_establish() -> void:
	var fl = main.flight
	var i := _pick_planet(1, true, true, false)
	if i < 0:
		_skip("establish.living_post", "no living planet left in system 1")
		return
	var pid := str(main.map.planets[i].get("id", ""))
	var cash0: int = main.cash
	var r: String = fl.request_fly_establish(pid)
	var used := _settle()
	_check("establish.living_post", r == "" and used >= 0.0 and fl.established(pid) and fl.post_built(pid), "%s: refused '%s', settled %.2f cycles, established %s, cash %d -> %d" % [pid, r, used, str(fl.established(pid)), cash0, main.cash])
	var d := _pick_planet(1, true, false, false)
	if d >= 0 and DeadWorlds.is_dead(main.map.planets[d]):
		var dpid := str(main.map.planets[d].get("id", ""))
		r = fl.request_fly_establish(dpid)
		used = _settle()
		_skip("establish.dead_world_needs_skill", "%s (dead world): refused '%s', settled %.2f, established %s (a platform needs MIN_3; no_skill is the expected refusal)" % [dpid, r, used, str(fl.established(dpid))])

## Save in the middle of a flight, then leave and reload the game: the ship must keep its course and arrive.
func _test_save_flight() -> void:
	var fl = main.flight
	var i := _pick_planet(1, false, false, true)
	if i < 0:
		_skip("save.midflight", "no undiscovered planet left in system 1")
		return
	var pid := str(main.map.planets[i].get("id", ""))
	var r: String = fl.request_fly({"kind": "planet", "index": i})
	var eta: float = fl.eta_cycles(pid)
	fl.advance(eta * 0.5)
	_check("save.setup_midflight", r == "" and fl.state() == "flying", "eta %.2f cycles, state half way %s" % [eta, fl.state()])
	if fl.state() != "flying":
		return
	main.save_now()
	var pre: Dictionary = fl.to_dict()
	var saved: Dictionary = SaveGame.load_state()
	var sp: Dictionary = saved.get("pathfinder", {})
	var same: bool = not sp.is_empty()
	var diffs: Array = []
	if same:
		for k in ["pos", "from", "to"]:
			if not _same_arr(pre[k], sp.get(k, [])):
				diffs.append(k)
		for k in ["t", "dur", "speed", "yaw"]:
			if absf(float(pre[k]) - float(sp.get(k, -999.0))) > 0.001:
				diffs.append(k)
		for k in ["state", "docked", "build"]:
			if str(pre[k]) != str(sp.get(k, "")):
				diffs.append("%s pre=%s saved=%s" % [k, str(pre[k]), str(sp.get(k, "MISSING"))])
		for k in ["to_sys", "sys"]:
			if float(pre[k]) != float(sp.get(k, -1)):
				diffs.append("%s pre=%s saved=%s" % [k, str(pre[k]), str(sp.get(k, "MISSING"))])
		if float(pre["target"].get("index", -2)) != float(sp.get("target", {}).get("index", -3)):
			diffs.append("target.index pre=%s saved=%s" % [str(pre["target"].get("index", -2)), str(sp.get("target", {}).get("index", -3))])
		if pre["discovered"].size() != sp.get("discovered", []).size():
			diffs.append("discovered")
	_check("save.midflight_file_matches", same and diffs.is_empty(), "save file pathfinder present %s, fields that differ: %s" % [str(same), str(diffs)])
	var pos_before: Vector3 = fl.ship_position()
	var idx_before = fl.target().get("index", -1)
	_reload()
	fl = main.flight
	_check("save.reload_keeps_course", fl.state() == "flying" and fl.target().get("index", -1) == idx_before and fl.ship_position().distance_to(pos_before) < 0.001, "after reload: state %s, target index %s (was %s), position moved %.5f" % [fl.state(), str(fl.target().get("index", -1)), str(idx_before), fl.ship_position().distance_to(pos_before)])
	used_arrive(pid)

func used_arrive(pid: String) -> void:
	var fl = main.flight
	var used := _settle()
	_check("save.arrives_after_reload", used >= 0.0 and fl.docked_at() == pid and fl.discovered(pid), "%s: settled %.2f cycles, docked '%s'" % [pid, used, fl.docked_at()])

## Save while a post is being built, reload: the build must still finish at the same remaining time.
func _test_save_build() -> void:
	var fl = main.flight
	var i := _pick_planet(1, false, true, false)
	if i < 0:
		_skip("save.midbuild", "no living planet left in system 1")
		return
	var pid := str(main.map.planets[i].get("id", ""))
	var r: String = fl.request_fly_establish(pid)
	var guard := 0
	while fl.state() == "flying" and guard < 200000:
		fl.advance(0.05)
		guard += 1
	_check("save.setup_building", r == "" and fl.state() == "building", "%s: refused '%s', state %s" % [pid, r, fl.state()])
	if fl.state() != "building":
		return
	var left: float = fl.build_cycles_left()
	main.save_now()
	_reload()
	fl = main.flight
	var left2: float = fl.build_cycles_left()
	_check("save.reload_keeps_build", fl.state() == "building" and fl.build_target() == pid and absf(left - left2) < 0.01, "after reload: state %s, build %s, cycles left %.3f (was %.3f)" % [fl.state(), fl.build_target(), left2, left])
	var used := _settle()
	_check("save.build_finishes_after_reload", used >= 0.0 and fl.established(pid), "%s: settled %.2f cycles, established %s" % [pid, used, str(fl.established(pid))])

## Probe-only: open every system a permit tree allows, then fly and establish every planet that can be reached.
## A planet that stays unestablished is a soft-lock candidate.
func _test_sweep() -> void:
	var fl = main.flight
	main.cash += 1000000
	main.skill_points += 200
	_advance_to_cycle(16)  # dead worlds open at cycle 15 (availability.json note)
	main.trade_income_total += 100000  # probe-only: the earned skills (FND_STORAGE) need trade income
	var mine := _learn(["FND_PERMIT", "FND_STORAGE", "FND_PROSPECT", "MIN_1", "MIN_3"])
	var fail_reasons: Array = []
	fl.establish_failed.connect(func(p2, reason): fail_reasons.append([p2, reason]))
	var opened: Array = []
	var refused := {}
	for sid in Systems.ids():
		if int(sid) == 1:
			continue
		var lr: Dictionary = main.learn_skill(str(main.required_skill(int(sid))))
		var pr: Dictionary = main.buy_permit(int(sid))
		if bool(pr.get("ok", false)):
			opened.append(int(sid))
		else:
			refused[str(sid)] = str(pr.get("reason", "?")) + " (skill learn: " + str(lr.get("reason", "ok")) + ")"
	var stuck: Array = []
	var tried := 0
	for i in main.map.planets.size():
		var pid := str(main.map.planets[i].get("id", ""))
		if fl.established(pid):
			continue
		tried += 1
		var rr: String = fl.request_fly_establish(pid)
		var used := _settle()
		if rr != "" or used < 0.0 or not fl.established(pid):
			stuck.append([pid, rr, fl.state(), DeadWorlds.is_dead(main.map.planets[i])])
	var total: int = main.map.planets.size()
	var est := 0
	for p in main.map.planets:
		if fl.established(str(p.get("id", ""))):
			est += 1
	_check("sweep.open_planets_all_reachable", stuck.is_empty(), "cycle %d; mining skills %s; opened systems %s; refused %s; planets %d, established %d, tried %d, stuck %s; establish refusals %s" % [main.cycle, mine, str(opened), str(refused), total, est, tried, str(stuck), str(fail_reasons)])
	_check("sweep.ship_idle_at_end", fl.state() == "idle", "state %s, docked '%s'" % [fl.state(), fl.docked_at()])

func _advance_to_cycle(c: int) -> void:
	while main.cycle < c:
		main.debug_advance_cycle()

func _learn(ids: Array) -> String:
	var out: Array = []
	for sk in ids:
		var lr: Dictionary = main.learn_skill(sk)
		out.append("%s:%s" % [sk, "ok" if bool(lr.get("ok", false)) else str(lr.get("reason", "?"))])
	return str(out)

## Probe-only: exploration mode (T206) in a fresh game must scout and establish every planet of system 1 and switch itself off.
func _test_exploration() -> void:
	var fl = main.flight
	main.cash += 1000000
	main.skill_points += 200
	main.trade_income_total += 100000  # probe-only: the earned skills (FND_STORAGE) need trade income
	var done := [false]
	fl.exploration_done.connect(func(): done[0] = true)
	fl.set_exploring(true)
	var started: bool = fl.exploring()
	# first: no dead world can be built before cycle 15 / MIN_3, so the mode must wait without ending or breaking the ship
	var waited := 0.0
	while waited < 50.0:
		fl.advance(0.05)
		waited += 0.05
	var unest_mid := 0
	for i in main.map.planets.size():
		if main.system_of(i) == 1 and not fl.established(str(main.map.planets[i].get("id", ""))):
			unest_mid += 1
	_check("explore.waits_while_dead_world_locked", fl.exploring() and fl.state() == "idle" and unest_mid == 1, "after 50 cycles at cycle %d: exploring %s, ship %s, unestablished system-1 planets %d" % [main.cycle, str(fl.exploring()), fl.state(), unest_mid])
	_advance_to_cycle(16)
	var mine := _learn(["FND_PERMIT", "FND_STORAGE", "FND_PROSPECT", "MIN_1", "MIN_3"])
	var used := 0.0
	while fl.exploring() and used < SETTLE_LIMIT:
		fl.advance(0.05)
		used += 0.05
	var left1 := 0
	for i in main.map.planets.size():
		if main.system_of(i) == 1 and not fl.established(str(main.map.planets[i].get("id", ""))):
			left1 += 1
	_check("explore.scouts_system1", started and done[0] and not fl.exploring() and left1 == 0, "cycle %d, mining skills %s; started %s, done signal %s, still exploring %s after %.1f cycles, unestablished system-1 planets %d" % [main.cycle, mine, str(started), str(done[0]), str(fl.exploring()), used, left1])
