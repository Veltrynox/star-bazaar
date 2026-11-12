extends SceneTree
## Economy check bot: plays ONE full run of game/main.tscn headless with one style and one CEO, then plays free play.
##
## Args (after --):  --saveload=mid|end|off (save/load round trip: mid-run default, after the run, or never)  --style=<name> --ceo=<ceo id> --seed=<int> --cycles=<max, default the game's term> --out=<result json file>
##                   --policy=first|second|seeded (event policy override; default: the style's)
## Writes ONE JSON object to --out and prints "RESULT <json>".
##
## The bot acts only through qa/check/actions.gd (player entry points). Time runs through main._process in chunks with the
## game unpaused, the same path the timer takes. Per cycle: answer open notices, style.each_cycle(cycle), advance one cycle,
## health checks, metrics. After the first ending: press Continue and play FREE_CYCLES more cycles in free play.
## Game RNG: events (seeded here), gigs / raids / markets (seeded by the --seed user arg the game reads itself).

const MAIN_SCENE := "res://game/main.tscn"
const SaveGame := preload("res://game/save_game.gd")
const Ceos := preload("res://game/ceos.gd")
const Actions := preload("res://qa/check/actions.gd")
const SkillTree := preload("res://game/skill_tree.gd")
const FREE_CYCLES := 3
const CHUNKS_PER_CYCLE := 8
const MAX_CHUNKS := 400  # per cycle: more than this is a softlock

var style_name := "trader"
var ceo_id := "ceo_woman_01"
var seed_value := 1
var max_cycles := 0
var out_path := ""
var policy_override := ""
var saveload_mode := "mid"  # mid | end | off

var main: Node = null
var act: RefCounted = null
var style: RefCounted = null
var rng := RandomNumberGenerator.new()

var phase := 0
var steps := 0
var bad_args := false
var finished := false

# run state
var feat := {}            # feature id -> {tried, ok, reasons {text: n}}
var mut_actions := 0      # successful mutating actions in the current cycle
var cur_flow := {"in": {}, "out": {}}
var cyc := {}             # metric arrays
var milestones: Array = []
var _ms_seen := {}
var issues: Array = []
var events_seen: Array = []
var goods_sold := {}      # good -> units sold by local orders
var goods_bought := {}
var dock_todo: Array = []
var ended_count := 0
var first_end := {}       # {side, ending, cycle, cash}
var end_screen_ok := true
var continue_ok := false
var free_played := 0
var in_free := false
var saveload := {"done": false, "ok": false, "diff": []}
var gigs_done := 0
var raids_seen := 0
var idle_cycles := 0
var idle_streak := 0
var idle_streak_max := 0
var peak_ships := 0
var skills_learned: Array = []
var _snap_cash_pre := 0
var _cash_at_settle := -1
var _settle_total := 0
var _rescues0 := 0
var _repo0 := 0
var _last_cycle_seen := 0
var _state_sig_prev := ""
var _local_notes: Array = []
var _prev_skill_n := 0
var _gig_seen := {}
var _pts_gained := 0
var _prev_pts := 0
var _pts_spent := 0
var _wall0 := 0


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--style="):
			style_name = arg.trim_prefix("--style=")
		elif arg.begins_with("--ceo="):
			ceo_id = arg.trim_prefix("--ceo=")
		elif arg.begins_with("--seed="):
			seed_value = int(arg.trim_prefix("--seed="))
		elif arg.begins_with("--cycles="):
			max_cycles = int(arg.trim_prefix("--cycles="))
		elif arg.begins_with("--out="):
			out_path = arg.trim_prefix("--out=")
		elif arg.begins_with("--saveload="):
			saveload_mode = arg.trim_prefix("--saveload=")
		elif arg.begins_with("--policy="):
			policy_override = arg.trim_prefix("--policy=")
	if not ResourceLoader.exists("res://qa/check/styles/%s.gd" % style_name) or not Ceos.has(ceo_id):
		printerr("bot: bad --style or --ceo")
		bad_args = true
		return
	rng.seed = seed_value
	SaveGame.continue_requested = false
	SaveGame.clear()
	# Company setup screen "Start": company, portrait, CEO, branch and ship of the chosen CEO.
	SaveGame.pending_company = "Check Co"
	SaveGame.pending_portrait = ceo_id
	SaveGame.pending_ceo = ceo_id
	SaveGame.pending_branch = Ceos.branch(ceo_id)
	SaveGame.pending_ship = Ceos.ship(ceo_id)
	_wall0 = Time.get_ticks_msec()


func _process(_delta: float) -> bool:
	if bad_args:
		quit(2)
		return true
	if finished:
		return true
	steps += 1
	if phase == 0:
		_boot()
		phase = 1
		return main == null
	if phase == 1:
		_after_boot()
		phase = 2
		return false
	_play_one()
	if finished:
		_finish()
		return true
	return false


# ---- boot ---------------------------------------------------------------------------------------------------------------

func _boot() -> void:
	var scene = load(MAIN_SCENE)
	main = scene.instantiate() if scene != null else null
	if main == null:
		printerr("bot: main scene did not load")
		quit(3)
		return
	get_root().add_child(main)
	main.events.rng.seed = seed_value


func _wire() -> void:
	main.set_process(false)  # the bot owns the clock; engine frames must not add time
	main.cycle_ended.connect(_on_cycle_ended)
	main.run_ended.connect(_on_run_ended)
	main.routes_settled.connect(_on_routes_settled)
	main.route_blocked.connect(func(_id: int, _t: String): _inc("blocked_signals"))
	main.notice_posted.connect(_on_notice)
	main.events.rng.seed = seed_value


var counters := {}

func _inc(k: String, n: int = 1) -> void:
	counters[k] = int(counters.get(k, 0)) + n


func _after_boot() -> void:
	act = Actions.new()
	act.setup(self)
	_wire()
	record_feature("setup.ceo_pick", true, "", false)
	if main.preface != null:
		main._dismiss_preface()
		record_feature("setup.preface", true, "", false)
	if main.tut_skip_btn != null:
		main.tut_skip_btn.pressed.emit()  # Skip tutorial on the guided card
		record_feature("setup.tutorial_skip", not bool(main.tut_lock_active()), "tutorial still locked", false)
	if max_cycles <= 0:
		max_cycles = int(main.balance.get("win_cycle_markets", 80))
	style = load("res://qa/check/styles/%s.gd" % style_name).new()
	style.setup(self)
	_prev_pts = int(main.skill_points)
	_rescues0 = int(main.rescues_paid)
	_repo0 = int(main.repossessions)
	cyc = {"cash": [], "ships": [], "idle_ships": [], "routes_running": [], "routes_stalled": [], "routes_blocked": [], "routes_waiting": [],
		"t1": [], "t2": [], "t3": [], "pts_gained": [], "pts_spent": [], "mut": [], "worlds_open": [], "baz_have": [], "baz_need": [], "baz_quorum": [], "skills": [], "income": {}, "spend": {}}


# ---- feature and flow records (called by actions.gd) -----------------------------------------------------------------------

func record_feature(fid: String, ok: bool, reason: String, mutating: bool = true) -> void:
	var e: Dictionary = feat.get(fid, {"tried": 0, "ok": 0, "reasons": {}})
	e["tried"] = int(e["tried"]) + 1
	if ok:
		e["ok"] = int(e["ok"]) + 1
		if mutating:
			mut_actions += 1
	elif reason != "":
		var r: Dictionary = e["reasons"]
		var key := reason.left(110)
		r[key] = int(r.get(key, 0)) + 1
	feat[fid] = e


## spend: add_flow("ships", 900) = outflow of 900; income: add_flow("events", 120, true).
func add_flow(sink: String, amount: int, income: bool = false) -> void:
	if amount <= 0:
		return
	var d: Dictionary = cur_flow["in"] if income else cur_flow["out"]
	d[sink] = int(d.get(sink, 0)) + amount


func note_event_seen(id: String) -> void:
	if id != "" and not events_seen.has(id):
		events_seen.append(id)


func milestone(id: String) -> void:
	if _ms_seen.has(id):
		return
	_ms_seen[id] = true
	milestones.append({"id": id, "cycle": int(main.cycle), "cash": int(main.cash)})


func issue(kind: String, detail: String) -> void:
	if issues.size() < 60:
		issues.append({"kind": kind, "cycle": int(main.cycle) if main != null else -1, "detail": detail.left(220)})


func event_policy() -> String:
	if policy_override != "":
		return policy_override
	return str(style.event_policy())


# ---- signals ------------------------------------------------------------------------------------------------------------

func _on_notice(text: String) -> void:
	if text.find("raid") >= 0 or text.find("Raid") >= 0:
		raids_seen += 1


func _on_routes_settled(results: Array, total: int) -> void:
	_settle_total = total
	_cash_at_settle = int(main.cash)
	if not main.hubs.hub_planets().is_empty():
		var hub_net: int = int(main.cash) - _snap_cash_pre - total
		if hub_net > 0:
			add_flow("hubs", hub_net, true)
		elif hub_net < 0:
			add_flow("hub_buys", -hub_net)
	for v in results:
		var p := int(v.get("paid", 0))
		if p > 0:
			add_flow("routes_stop_sales", p, true)
		elif p < 0:
			add_flow("route_costs", -p)
	for v in main.last_local:
		var cr := int(v.get("paid", 0))
		var g := str(v.get("c", ""))
		var n := int(v.get("n", 0))
		if str(v.get("role", "")) == "sell":
			if cr > 0:
				add_flow("local_sales", cr, true)
			goods_sold[g] = int(goods_sold.get(g, 0)) + n
		else:
			if cr < 0:
				add_flow("local_buys", -cr)
			goods_bought[g] = int(goods_bought.get(g, 0)) + n


func _on_cycle_ended(_c: int) -> void:
	if _cash_at_settle < 0:
		return
	var rest: int = int(main.cash) - _cash_at_settle
	var stipend: int = (int(main.rescues_paid) - _rescues0) * int(main.balance.get("rescue_stipend", 0))
	if stipend > 0:
		add_flow("stipend", stipend, true)
		rest -= stipend
		_rescues0 = int(main.rescues_paid)
		record_feature("ship.stipend", true, "", false)
	var repo: int = (int(main.repossessions) - _repo0)
	if repo > 0:
		var credit := repo * floori(float(main.balance.get("salvage_share", 0.4)) * float(main.ship_price()))
		add_flow("salvage", credit, true)
		rest -= credit
		_repo0 = int(main.repossessions)
		record_feature("ship.repossession", true, "", false)
	if rest > 0:
		add_flow("tax", rest, true)
	elif rest < 0:
		add_flow("other_costs", -rest)
	_cash_at_settle = -1


func _on_run_ended(side: String, ending: String) -> void:
	ended_count += 1
	if ended_count == 1:
		first_end = {"side": side, "ending": ending, "cycle": int(main.cycle), "cash": int(main.cash)}
		milestone("end_" + side.to_lower())
		record_feature("end." + side.to_lower(), true, "", false)
		if ending.find("_GOOD") < 0 and ending.find("_BAD") < 0 and ending != "END_UNFINISHED" and ending != "END_BANKRUPT":
			record_feature("end.ceo_ending", true, "", false)
	else:
		issue("run_ended_twice", "run_ended fired %d times" % ended_count)


# ---- one bot cycle --------------------------------------------------------------------------------------------------------

func _play_one() -> void:
	if main.game_over:
		_handle_end()
		return
	var c: int = int(main.cycle)
	if in_free and free_played >= FREE_CYCLES:
		finished = true
		return
	if c > max_cycles and ended_count == 0:
		if max_cycles >= int(main.balance.get("win_cycle_markets", 80)):
			issue("term_overrun", "cycle %d past the cycle limit %d without an ending" % [c, max_cycles])
		finished = true
		return
	mut_actions = 0
	cur_flow = {"in": {}, "out": {}}
	if steps > 2400:
		issue("softlock", "bot step watchdog")
		finished = true
		return
	_check_save_load(c)
	act.close_overlays()
	act.answer_events(event_policy())
	if main.event_notice == null and str(main.events.pending_id) != "" and not main.game_over:
		issue("event_pending_after_answer", str(main.events.pending_id))  # nothing could open or answer it: unanswerable
	_wing_policy()
	style.each_cycle(c)
	act.answer_events(event_policy())  # notices the style's own actions opened
	_pre_snapshot(c)
	var start_cycle: int = int(main.cycle)
	_advance_cycle()
	_post_checks(c, start_cycle)
	if in_free and not finished:
		free_played += 1


func _wing_policy() -> void:
	if int(main.bazaar.wing_pending) > 0:
		act.pick_wing(int(style.wing_pick(int(main.bazaar.wing_pending))))
		record_feature("bazaar.wing_seen", true, "", false)


func _handle_end() -> void:
	if end_screen_ok and main.end_screen != null:
		end_screen_ok = main.end_screen.get_child_count() > 0
		if not end_screen_ok:
			issue("end_screen_empty", "end screen has no content")
		else:
			record_feature("end.screen_content", true, "", false)
	elif main.end_screen == null:
		issue("end_screen_missing", "game over without an end screen")
		end_screen_ok = false
	if first_end.is_empty():
		issue("ended_without_signal", "game_over without run_ended")
	var r: Dictionary = act.press_continue()
	continue_ok = bool(r["ok"])
	if not continue_ok:
		issue("continue_failed", str(r["reason"]))
		finished = true
		return
	free_played = 0
	in_free = true
	# free play: the cycle counter did not move at the ending (the ending returns before cycle += 1): the next settle repeats it
	_last_cycle_seen = int(main.cycle) - 1


func _pre_snapshot(_c: int) -> void:
	_snap_cash_pre = int(main.cash)


func _chunk_game_seconds() -> float:
	return float(main.balance.get("cycle_minutes", 2)) * 60.0 / float(CHUNKS_PER_CYCLE)


## Run the real clock until the cycle counter moves (or the game ends). Notices and dock sheets that open on the way are answered.
func _advance_cycle() -> void:
	var start: int = int(main.cycle)
	main.set_paused(false)
	var chunks := 0
	while int(main.cycle) == start and not main.game_over and chunks < MAX_CHUNKS:
		chunks += 1
		if bool(main.paused):
			if not _unpause():
				break
		var c0: int = int(main.cash)
		var building: bool = str(main.flight.build_target()) != ""
		_snap_cash_pre = c0
		var delta: float = _chunk_game_seconds() / maxf(0.01, float(main.time_speed))
		main._process(delta)
		if int(main.cycle) == start and not main.game_over:
			var dc: int = int(main.cash) - c0
			if dc > 0:
				add_flow("flight_gigs", dc, true)
			elif dc < 0:
				add_flow("posts" if building or str(main.flight.build_target()) != "" else "flight_costs", -dc)
		act.fs_pump()
		_serve_dock()
		style.on_chunk(chunks)
	if chunks >= MAX_CHUNKS:
		issue("softlock", "cycle %d did not end in %d chunks (paused %s, notice %s, dock %s)" % [start, MAX_CHUNKS, str(main.paused), str(main.event_notice != null), str(main.dock_sheet != null)])
		finished = true
	main.set_paused(true)


## The game was paused by something inside the cycle: answer it, then press play again.
func _unpause() -> bool:
	for _i in 4:
		if main.event_notice != null:
			act.answer_events(event_policy())
		if main.dock_sheet != null:
			_serve_dock(true)
		if not bool(main.paused) and main.event_notice == null and main.dock_sheet == null:
			return true
		main.set_paused(false)
		if not bool(main.paused):
			return true
	issue("stuck_pause", "game stays paused: notice %s dock %s" % [str(main.event_notice != null), str(main.dock_sheet != null)])
	return false


## A dock sheet is open (the Flagship arrived with a dock order): run the style's hand-trade list, then close it.
func _serve_dock(force: bool = false) -> void:
	if main.dock_sheet == null:
		return
	if dock_todo.is_empty() and not force:
		pass
	for t in dock_todo:
		act.dock_do(str(t[0]), str(t[1]), int(t[2]))
	dock_todo = []
	act.dock_close()
	if bool(main.paused):
		main.set_paused(false)


# ---- checks and metrics ---------------------------------------------------------------------------------------------------

func _post_checks(c: int, start_cycle: int) -> void:
	if finished:
		return
	var played: int = int(main.cycle)
	if not main.game_over and played != start_cycle + 1 and ended_count == 0:
		issue("softlock", "cycle counter %d -> %d" % [start_cycle, played])
	_health(c)
	_record(c)
	# an event notice left open or an important event nobody can answer
	if main.event_notice != null and ended_count == 0 and not main.game_over:
		pass


func _health(c: int) -> void:
	var cash_v = main.cash
	if typeof(cash_v) != TYPE_INT:
		issue("cash_not_int", str(cash_v))
	if int(main.ships) > int(main.ship_cap()):
		issue("ships_over_cap", "%d > %d" % [int(main.ships), int(main.ship_cap())])
	var assigned: int = int(main.engine.total_assigned()) + int(main.hubs.pool_total())
	if assigned > int(main.ships):
		issue("ships_overassigned", "assigned %d > owned %d" % [assigned, int(main.ships)])
	for r in main.engine.routes:
		var a := int(r["a"])
		var b := int(r["b"])
		var np: int = main.map.planets.size()
		var a_ok: bool = (a >= 0 and a < np) or SkillTree != null and a < 0
		var b_ok: bool = (b >= 0 and b < np) or b < 0
		if not (a_ok and b_ok):
			issue("route_bad_world", "route %d a=%d b=%d" % [int(r["id"]), a, b])
	for key in main.storage.stock.keys():
		for g in main.storage.stock[key]:
			if int(main.storage.stock[key][g]) < 0:
				issue("negative_stock", "%s %s %d" % [str(key), str(g), int(main.storage.stock[key][g])])
	for g in main.flight.hold_goods():
		if int(main.flight.hold_goods()[g]) < 0:
			issue("negative_hold", str(g))


func _record(c: int) -> void:
	cyc["cash"].append(int(main.cash))
	cyc["ships"].append(int(main.ships))
	peak_ships = maxi(peak_ships, int(main.ships))
	cyc["idle_ships"].append(int(main.free_ships()))
	var run_n := 0
	var st_n := 0
	var bl_n := 0
	var wt_n := 0
	for r in main.engine.routes:
		match str(main.display_status(r)):
			"running":
				run_n += 1
			"stalled":
				st_n += 1
			"blocked":
				bl_n += 1
			_:
				wt_n += 1
	cyc["routes_running"].append(run_n)
	cyc["routes_stalled"].append(st_n)
	cyc["routes_blocked"].append(bl_n)
	cyc["routes_waiting"].append(wt_n)
	var per: Dictionary = act.worlds_by_tier()
	cyc["t1"].append(int(per.get(1, 0)))
	cyc["t2"].append(int(per.get(2, 0)))
	cyc["t3"].append(int(per.get(3, 0)))
	var pts: int = int(main.skill_points)
	var learned: int = main.learned_skills.size()
	var spent := 0
	if learned > _prev_skill_n:
		for id in main.learned_skills:
			if not skills_learned.has(id):
				skills_learned.append(id)
				spent += SkillTree.cost(main.balance, str(id))
	_prev_skill_n = learned
	var gained: int = maxi(0, pts - _prev_pts + spent)
	_prev_pts = pts
	cyc["pts_gained"].append(gained)
	cyc["pts_spent"].append(spent)
	cyc["skills"].append(learned)
	cyc["mut"].append(mut_actions)
	cyc["worlds_open"].append(act.open_worlds().size())
	var bs: Dictionary = act.bazaar_status()
	var hv := 0
	var nd := 0
	for row in bs["bill"]:
		hv += mini(int(row["have"]), int(row["need"]))
		nd += int(row["need"])
	cyc["baz_have"].append(hv)
	cyc["baz_need"].append(nd)
	cyc["baz_quorum"].append(1 if bool(bs["quorum"]["ok"]) else 0)
	for k in cur_flow["in"]:
		_push_flow("income", str(k), int(cur_flow["in"][k]), c)
	for k in cur_flow["out"]:
		_push_flow("spend", str(k), int(cur_flow["out"][k]), c)
	# idle decision: nothing changed by the style this cycle
	if mut_actions == 0:
		idle_cycles += 1
		idle_streak += 1
		idle_streak_max = maxi(idle_streak_max, idle_streak)
	else:
		idle_streak = 0
	_milestones()
	_observe_features()


func _push_flow(kind: String, key: String, amount: int, c: int) -> void:
	var d: Dictionary = cyc[kind]
	if not d.has(key):
		d[key] = {}
	d[key][str(c)] = amount


func _milestones() -> void:
	if int(main.ships) >= 1:
		milestone("first_ship")
	if int(main.ships) >= 2:
		milestone("second_ship")
	if int(main.ships) >= 5:
		milestone("fifth_ship")
	var per: Dictionary = act.worlds_by_tier()
	if int(per.get(2, 0)) > 0:
		milestone("first_tier2")
	if int(per.get(3, 0)) > 0:
		milestone("first_tier3")
	if main.open_systems.size() > 1:
		milestone("first_permit")
	for id in main.workshops.built:
		if bool(main.workshops.built[id]):
			milestone("first_workshop")
	if bool(main.fabric.built):
		milestone("fabric_built")
	if main.bazaar.is_founded():
		milestone("bazaar_founded")
	for n in range(1, int(main.bazaar.stage()) + 1):
		milestone("bazaar_stage_%d" % n)
	if bool(main.bazaar.opening_pending):
		milestone("opening_ready")
	if bool(main.flight.exploring()):
		milestone("exploring")
	var est := 0
	for i in main.map.planets.size():
		if main.planet_established(i):
			est += 1
	if est >= 2:
		milestone("second_world")


## Features that happen by themselves: record them when the state shows they happened.
func _observe_features() -> void:
	if int(main.ships) >= int(main.ship_cap()):
		record_feature("ship.cap", true, "", false)
	var per: Dictionary = act.worlds_by_tier()
	if int(per.get(2, 0)) > 0:
		record_feature("pros.tier2", true, "", false)
	if int(per.get(3, 0)) > 0:
		record_feature("pros.tier3", true, "", false)
	if int(cur_flow["in"].get("tax", 0)) > 0:
		record_feature("pros.tax", true, "", false)
	for i in main.map.planets.size():
		if not main.planet_established(i):
			continue
		for n in main.prosperity.needs(i):
			if bool(n["locked"]):
				continue
			var why: String = str(main.prosperity.price_reason(i, str(n["good"])))
			if why == "hungry":
				record_feature("pros.hungry", true, "", false)
			elif why == "surplus":
				record_feature("pros.surplus", true, "", false)
		if main.prosperity.is_reclaimed(i):
			record_feature("mining.reclaim", true, "", false)
		if main.prosperity.restless(i):
			record_feature("pros.restless", true, "", false)
	if str(main.fabric.state) == "running" or int(main.fabric.made) > 0:
		record_feature("workshop.fabric_run", true, "", false)
	for id in main.workshops.IDS:
		if str(main.workshops.state[id]) == "running":
			record_feature("workshop.feed_run", true, "", false)
	if int(main.bazaar.stage()) >= 1:
		record_feature("bazaar.stage_done", true, "", false)
	if bool(main.bazaar.opened):
		record_feature("bazaar.opening", true, "", false)
	if int(main.gigs.rush_done) > 0:
		record_feature("gig.rush_deliver", true, "", false)
	for k in main.gigs.done:
		record_feature("gig.signal_done", true, "", false)
	if main.engine.routes.any(func(r): return int(r.get("level", 1)) >= 2):
		record_feature("route.upgrade_seen", true, "", false)
	if main.engine.routes.any(func(r): return bool(r.get("core", false))):
		record_feature("workshop.core_fitted", true, "", false)
	for sid in main.station_systems:
		record_feature("storage.station_built", true, "", false)
	for l in main.storage_link.links():
		record_feature("link.exists", true, "", false)
	if int(main.flight.boost_charges()) < int(main.flight.boost_max_charges()):
		record_feature("flag.boost_used", true, "", false)
	for pid in ["planet_2", "planet_3", "planet_4"]:
		if bool(main.flight.post_built(pid)):
			record_feature("flag.post_seen", true, "", false)
	if main.flight.post_built("dead_1") or main.flight.platform_built("dead_1"):
		record_feature("flag.platform_seen", true, "", false)
	for sid in main.open_systems:
		if int(sid) > 1:
			record_feature("system.open_seen", true, "", false)
	if int(main.run_notes.get("platforms", 0)) > 0:
		record_feature("mining.platform_note", true, "", false)
	if raids_seen > 0:
		record_feature("gig.raid_seen", true, "", false)
	for o in main.gigs.offers:
		var k := str(o.get("kind", ""))
		if not _gig_seen.has(str(o["uid"])):
			_gig_seen[str(o["uid"])] = k
			record_feature("gig.offer_" + k, true, "", false)
	if int(main.engine.local.size()) > 0:
		pass
	for e in main.events.feed:
		note_event_seen(str(e.get("id", "")))
	for a in main.events.active:
		var kind := str(a.get("kind", ""))
		if kind in ["shortage", "congestion", "up", "down", "closed"]:
			record_feature("event.weather_" + kind, true, "", false)
	if not main.events.debris.is_empty():
		record_feature("event.debris", true, "", false)


# ---- save / load round trip -----------------------------------------------------------------------------------------------

func _state_sig() -> Dictionary:
	var stor := 0
	for key in main.storage.stock.keys():
		for g in main.storage.stock[key]:
			stor += int(main.storage.stock[key][g])
	var routes: Array = []
	for r in main.engine.routes:
		routes.append("%d:%d:%d:%s:%d" % [int(r["id"]), int(r["a"]), int(r["b"]), str(r["c"]), int(r.get("level", 1))])
	var tiers: Array = []
	for i in main.map.planets.size():
		tiers.append(int(main.prosperity.tier(i)))
	var sk: Array = main.learned_skills.duplicate()
	sk.sort()
	return {"cash": int(main.cash), "cycle": int(main.cycle), "ships": int(main.ships), "routes": routes, "skills": sk, "storage_total": stor,
		"tiers": tiers, "bazaar_stage": int(main.bazaar.stage()), "capital": int(main.bazaar.capital()), "open_systems": main.open_systems.duplicate(),
		"points": int(main.skill_points), "workshops": main.workshops.built.duplicate(), "orders": main.engine.local.size()}


func _check_save_load(c: int) -> void:
	if saveload_mode != "mid" or bool(saveload["done"]) or c < maxi(8, max_cycles / 3) or main.game_over:
		return
	_do_save_load()


func _do_save_load() -> void:
	if main.event_notice != null or main.dock_sheet != null or main.game_over:
		return
	saveload["done"] = true
	saveload["cycle"] = int(main.cycle)
	main.save_now()
	var before := _state_sig()
	var old = main
	get_root().remove_child(old)
	old.free()
	SaveGame.continue_requested = true
	main = load(MAIN_SCENE).instantiate()
	get_root().add_child(main)
	if main.preface != null:
		main._dismiss_preface()
	_wire()
	var after := _state_sig()
	var diff: Array = []
	for k in before:
		if str(before[k]) != str(after[k]):
			diff.append("%s: %s -> %s" % [k, str(before[k]).left(60), str(after[k]).left(60)])
	saveload["diff"] = diff
	saveload["ok"] = diff.is_empty()
	record_feature("save.roundtrip", diff.is_empty(), "; ".join(diff).left(110), false)
	if not diff.is_empty():
		issue("save_load_diff", "; ".join(diff))


# ---- result -------------------------------------------------------------------------------------------------------------

func _finish() -> void:
	if saveload_mode == "end" and not bool(saveload["done"]):
		_do_save_load()
	var wall := float(Time.get_ticks_msec() - _wall0) / 1000.0
	var per: Dictionary = act.worlds_by_tier()
	var res := {
		"style": style_name, "ceo": ceo_id, "seed": seed_value, "branch": str(main.branch), "ship": str(main.ship_type),
		"outcome": str(first_end.get("side", "none")), "ending": str(first_end.get("ending", "")), "end_cycle": int(first_end.get("cycle", int(main.cycle))),
		"cycle": int(main.cycle), "cash": int(main.cash), "cash_at_end": int(first_end.get("cash", int(main.cash))), "peak_ships": peak_ships, "ships": int(main.ships),
		"worlds_per_tier": per, "bazaar_stage": int(main.bazaar.stage()), "bazaar_founded": bool(main.bazaar.is_founded()),
		"skills_learned": skills_learned, "skill_points_left": int(main.skill_points),
		"features": feat, "issues": issues, "events_seen": events_seen, "milestones": milestones, "cyc": cyc,
		"goods_sold": goods_sold, "goods_bought": goods_bought, "idle_cycles": idle_cycles, "idle_streak_max": idle_streak_max,
		"ended_count": ended_count, "end_screen_ok": end_screen_ok, "continue_ok": continue_ok, "free_played": free_played,
		"saveload": saveload, "counters": counters, "wall_s": wall, "style_notes": style.notes if "notes" in style else [],
		"open_systems": main.open_systems, "repossessions": int(main.repossessions), "rescues": int(main.rescues_paid),
	}
	var js := JSON.stringify(res)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(js)
			f.close()
	print("RESULT " + js)
	quit(0)
