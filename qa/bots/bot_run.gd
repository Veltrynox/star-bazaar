extends SceneTree
## QA bot harness (owned by qa-analyst). Not gameplay code: nothing under game/ or data/ is changed.
## Plays one full game of game/main.tscn headless.
##
## The bot acts only through the signals a player's clicks emit, plus main.learn_skill for skills:
##   map.planet_clicked (select a planet, or pick a "Send to..." destination)
##   planet_panel.order_requested (Buy / Sell standing local order toggle)
##   planet_panel.send_requested ("Send to..." on a storage row)
##   planet_panel.remove_requested (Remove on a route)
##   ship_panel.buy_requested (ship button; the planet panel Buy ship button was removed in cfd3ecc)
##   end_screen.chosen (Release / Stay as a Corporation buttons on the choice screen)
##
## Each cycle, while the game is paused:
##   0. events: _resolve_events answers any open event notice (first enabled choice, else Continue)
##   1. the first ship at the mission planet if the bot owns none (tutorial)
##   2. skills via main.learn_skill (every strategy except sloppy), in skill tree order
##   3. plan: profitable lanes "Buy at A, Send to... B, Sell at B", ranked by profit per cycle
##   4. ships per strategy policy, route removal and route building, orders on and off
## Then the cycle ends. --clock=fast runs main.debug_advance_cycle() once.
## --clock=timer runs main._process in 1 to 45 s chunks until the cycle counter moves.
##
## Win: at a cycle end with cash >= win_cash the choice screen waits. The bot picks a side by
## emitting end_screen.chosen. Loss: the window ends (win_cycle) below win_cash.
## Checks at every cycle end: game_over matches the expected end (cash, cycle, force toggle);
## the choice screen shows exactly when cash >= win_cash; exactly one run_ended per run; the
## unanswered choice is in the save; RunStats gets +1 run, +1 side, +1 ending; the autosave is
## cleared after the run; the end screen has content.
##
## Strategies (names fixed):
##   decent        up to 3 lanes; buys a ship when a planned lane needs one, from cycle 4, and only
##                 while 1000 cr stay in cash afterwards; learns skills. Permits: none in this build.
##   always_expand up to ship_cap lanes; buys a ship whenever cash allows, no reserve; learns skills.
##   sloppy        one lane, locked at cycle 1: never re-planned, never removed, even when blocked;
##                 buys no ship beyond the lane's one; learns no skills.
##   never_expand  one lane (best profit), the tutorial ship only, forever; learns skills.
##
## Options (after --):
##   --strategy=decent|sloppy|always_expand|never_expand|mining_focus
##                           (mining_focus, T161: Prospecting first; cluster ore lanes first, then the trade ranking)
##   --seed=<int>            only drives timer chunks and the alt choice (the game has no RNG)
##   --event-policy=first|decline   how event notices are answered (see _event_pick)
##   --clock=fast|timer
##   --choice=alt|RELEASE|CORP   alt: odd seed RELEASE, even seed CORP (default alt)
##   --force-goal=<cycle>    turns on the debug "Force goal at cycle end" toggle at that cycle
##                           (debug builds only; QA reaches the choice early)
##   --inject=<cycle>:<credits>  QA test input: credits added at the start of that cycle
##   --close-at=<cycle>      QA closure (T94): the first route's source planet is closed from that cycle (timed, like an event).
##   --keep-closed           T94: a route touching a closed planet is kept while its lane stays profitable (not dropped).
##                           The RESULT line gets a "closure" record: closed and bridged cycles, what each route paid.
##   --skills=<id,id,...>    only these skills may be learned (empty value or none: no skill). Default: all.
##   --skill-order=<id,...>  learn these first, in this order, then the rest in tree order.
##   --permit=<system id>    buy that system's permit as soon as the game allows it (needs C1).
##   --reload-choice         T80: at the win choice, free the game and start a new one from the save (Continue path),
##                           then answer. Checks the choice comes back unchanged.
##
## Run (from the repo root, or through qa/bots/run_batch.sh which also uses a scratch HOME):
##   HOME=<scratch dir> tools/godot/Godot.app/Contents/MacOS/Godot --headless --path . \
##     -s res://qa/bots/bot_run.gd -- --strategy=decent --seed=1
## Prints one line "RESULT {json}" and exits.
##
## T87 hook (several ships on one lane): not wired yet. When it lands, sloppy and decent should send
## a second ship down the top lane with the same Send to... (see _sync_lanes). Not a bug until then.

const MAIN_SCENE := "res://game/main.tscn"
const SaveGame := preload("res://game/save_game.gd")
const SkillTree := preload("res://game/skill_tree.gd")
const STRATEGIES := ["decent", "sloppy", "always_expand", "never_expand", "mining_focus", "dead_run"]
const DECENT_LANES := 24  # no lane cap, matching tools/sim.py decent (ship_cap is the only limit)
const DECENT_FROM_CYCLE := 1  # buy from the first cycle, matching tools/sim.py decent
const DECENT_RESERVE := 0  # no cash reserve, matching tools/sim.py decent
const PAYBACK_CYCLES := 10  # QA: a lane must pay a ship back within this many cycles
const PERMIT_WORKING_CASH := 400  # QA: cash the --permit buy keeps back for standing buy orders
const DeadWorlds := preload("res://game/dead_worlds.gd")
const IDLE_AFTER := 3  # cycles in a row with no cash or stock change before it counts as a softlock
const MAX_STEPS := 1000  # watchdog: bot cycles before a run is called a softlock
const MAX_CHUNKS := 100000  # watchdog: timer steps inside one cycle

var strategy := "decent"
var seed_value := 1
var clock := "fast"
var choice_policy := "alt"
var force_cycle := -1
var inject_cycle := -1
var inject_cash := 0
var bad_args := false
var reload_at_choice := false  # QA option --reload-choice: reload the game from the save at the unanswered win choice
var reloaded := false
var event_rows: Array = []  # T80: per cycle, the active event effects and closed planets (for the events check)
var reload_ok := true
var skip_skills: Array = []  # QA option --skip-skill=A3,... (never learn these ids)
var only_skills: Array = []  # QA option --skills=... (empty: every skill may be learned)
var skill_order: Array = []  # QA option --skill-order=... (learned first, in this order)
var permit_sid := -1  # QA option --permit=<system id>
var rng := RandomNumberGenerator.new()
var main: Node = null
var phase := 0
var steps := 0
var hung := false
var win_cash := 0
var win_cycle := 0
var ended_count := 0
var last_ended := -1
var expect_over := false
var first_over_cycle := -1
var choice_cycle := -1
var choice_side := ""
var run_end_count := 0
var run_side := ""
var run_ending := ""
var stats_before: Dictionary = {}
var stats_ok := true
var end_screen_ok := false
var locked_lane: Dictionary = {}  # sloppy's one lane
var idle_streak := 0
var dead_from := -1
var ship_buys: Array = []  # [cycle, planet, ships_after]
var skills_learned: Array = []  # [cycle, id]
var skill_log: Array = []  # [cycle, id, points_spent] per learned skill, in learn order
var lanes_built := 0
var lane_cycles := {}  # T161: per good, route-cycles open at the start of each cycle (after decisions)
var cluster_lane_cycles := 0  # T161: route-cycles that start at a cluster
var ore_taken := 0  # T161: ore units taken from clusters (sum of drops in cluster left, new clusters not counted when first seen)
var cluster_last_left := {}
var danger_rows: Array = []  # R2: [cycle, danger dead_1, danger dead_2, running dead routes]
var clusters_touched := {}  # T161 round 2: cluster indexes that gave ore
var streak_by_route := {}  # T161 v3: consecutive cycles per route id with a cash or room warning
var reason_warn_cycles := 0  # T161 v3: route-cycles that showed a cash or room warning
var reserve_short := []  # T161 v3: [cycle, cash, running routes, fixed cost] where cash < fixed cost x running routes (approximate)
var lanes_removed := 0
var orders_changed := 0
var notes: Array = []
var issues: Array = []  # [kind, cycle, detail]
var cycle_rows: Array = []  # [cycle, cash, ships, routes]
var decision_at: Dictionary = {}  # cycle -> real player actions taken in that cycle (metrics)
var decision_kinds: Dictionary = {}  # kind -> count (metrics)
var event_policy := "first"  # --event-policy=first|decline
var probe := ""  # --probe=s2: per cycle, Space Storage posts, system stock and closures (system 2 check)
var close_at := -1  # --close-at=<cycle>: QA injection, closes the first route's source planet from that cycle
var close_planet := -1
var keep_closed := false  # --keep-closed (T94): a route touching a closed planet is kept while its lane stays profitable
var play_cycle := -1  # the cycle being played; routes_settled results belong to it
var route_ids_before: Array = []  # ids of routes touching close_planet at the start of the cycle, before decisions
var closure_cycles: Array = []  # play cycles in which close_planet was closed at settle (no bridge)
var bridged_cycles: Array = []  # play cycles in which the closure timer ran but a skill bridged it (route should run)
var closure_routes: Dictionary = {}  # route id -> per-route record (see _on_routes_settled)
var closure_drops: Array = []  # [cycle, route id] routes touching close_planet that were gone at settle during a closure
var closure_start_ids: Array = []  # route ids touching close_planet when the closure first applied
var closed_order_units := 0  # units traded by Buy or Sell orders at close_planet while it was closed (must stay 0)
var closed_order_rows := 0  # order rows at close_planet with a non-zero trade while closed (must stay 0)
var probe_rows: Array = []
var events_resolved := 0  # events answered by _resolve_events (0 while the hook is a stub)


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--strategy="):
			strategy = arg.trim_prefix("--strategy=")
		elif arg.begins_with("--event-policy="):
			event_policy = arg.trim_prefix("--event-policy=")
		elif arg.begins_with("--seed="):
			seed_value = int(arg.trim_prefix("--seed="))
		elif arg.begins_with("--clock="):
			clock = arg.trim_prefix("--clock=")
		elif arg.begins_with("--choice="):
			choice_policy = arg.trim_prefix("--choice=")
		elif arg.begins_with("--force-goal="):
			force_cycle = int(arg.trim_prefix("--force-goal="))
		elif arg.begins_with("--skip-skill="):
			skip_skills = Array(arg.trim_prefix("--skip-skill=").split(","))
		elif arg == "--reload-choice":
			reload_at_choice = true
		elif arg.begins_with("--skills="):
			only_skills = _csv(arg.trim_prefix("--skills="))
			if only_skills.is_empty():  # --skills= or --skills=none: no skill may be learned (empty alone means all)
				only_skills = ["NONE"]
		elif arg.begins_with("--skill-order="):
			skill_order = _csv(arg.trim_prefix("--skill-order="))
		elif arg.begins_with("--probe="):
			probe = arg.trim_prefix("--probe=")
		elif arg.begins_with("--close-at="):
			close_at = int(arg.trim_prefix("--close-at="))
		elif arg == "--keep-closed":
			keep_closed = true
		elif arg.begins_with("--permit="):
			permit_sid = int(arg.trim_prefix("--permit="))
		elif arg.begins_with("--inject="):
			var parts := arg.trim_prefix("--inject=").split(":")
			inject_cycle = int(parts[0])
			inject_cash = int(parts[1])
	if strategy == "mining_focus" and skill_order.is_empty():
		skill_order = ["B1"]  # T161: mining_focus learns Prospecting (B1) first
	if strategy == "dead_run" and skill_order.is_empty():
		skill_order = ["B1", "C1", "A1", "M1", "M2", "C3", "F1"]  # M1 is second row: needs A1 and C1 (ROW_KEYS)  # R2 dead worlds: Cold Survey, Deep Cut, Fabrication Licence (+ prereq B1, Long Haul for system 2)
	if strategy == "always_expand" and skill_order.is_empty():
		skill_order = ["C1", "C3", "A1", "A2"]  # T161 follow-up: expansion (permit, long haul, storage, holds) first
	if not STRATEGIES.has(strategy) or not ["fast", "timer"].has(clock) or not ["alt", "RELEASE", "CORP"].has(choice_policy):
		printerr("bot_run: bad --strategy, --clock or --choice")
		bad_args = true
		return
	rng.seed = seed_value
	SaveGame.continue_requested = false
	SaveGame.clear()  # every run starts from a new game, never from an old autosave


func _process(_delta: float) -> bool:
	if bad_args:
		quit(2)
		return true
	steps += 1
	if steps > MAX_STEPS:
		_issue("softlock", -1, "watchdog: bot loop exceeded %d steps" % MAX_STEPS)
		return _finish()
	if hung:
		return _finish()
	if phase == 0:
		main = load(MAIN_SCENE).instantiate()
		get_root().add_child(main)
		# Game events draw from an RNG that main's setup randomizes (events.gd rng.randomize()). Seed it
		# from --seed after setup so the same seed gives the same run. The game itself is not changed.
		main.events.rng.seed = seed_value
		phase = 1
		return false
	if phase == 1:
		if main.preface != null:
			main._dismiss_preface()  # the player presses Start on the preface
		main.set_process(false)  # the bot owns the clock; engine frames must not add time
		main.cycle_ended.connect(_on_cycle_ended)
		main.run_ended.connect(_on_run_ended)
		main.routes_settled.connect(_on_routes_settled)
		win_cash = int(main.balance.get("win_cash", 0))
		win_cycle = int(main.balance.get("win_cycle", 0))
		stats_before = RunStats.load_stats()
		phase = 2
		return false
	if main.game_over:
		return _finish()
	_play_cycle()
	return false


func _play_cycle() -> void:
	if close_at == main.cycle and close_planet < 0 and not main.engine.routes.is_empty():
		# QA injection at the start of the cycle, like a real event: the same timed closure the events hook starts.
		close_planet = int(main.engine.routes[0]["a"])
		main.events.start_timed("QA_CLOSE", {"kind": "closed", "planet": close_planet, "c": "", "amount": 0})
		main._sync_closed()
		notes.append("QA closure of planet %d from cycle %d" % [close_planet, close_at])
	main.set_paused(true)
	var c: int = main.cycle
	play_cycle = c
	route_ids_before = _route_ids_at(close_planet)
	if c == inject_cycle:
		main.cash += inject_cash
		notes.append("injected %d credits at cycle %d (QA test input)" % [inject_cash, c])
	if c == force_cycle:
		main.debug_force_goal = true
		notes.append("debug force-goal toggle on at cycle %d (QA; same as the debug menu)" % c)
	events_resolved += _resolve_events()
	if not main.pending.is_empty():
		main.cancel_pending()
	_decide(c)
	if strategy == "dead_run":
		_dead_probe(c)  # R2: gate refusals, fabric build
	_tally_goods()  # T161
	cycle_rows.append([c, main.cash, main.ships, main.engine.routes.size()])
	var sig_before := _state_sig()
	var ended_before := ended_count
	if clock == "timer":
		_advance_timer()
	else:
		main.debug_advance_cycle()
	_check_cycle_result(c, ended_before)
	_log_events()
	if not hung:
		_check_idle(c, sig_before)
	if not hung and main.choice_pending:
		_resolve_choice()
	main.set_paused(true)


## Events: answer every open event notice. The first enabled choice is taken (choices are ordered
## so the first is the paid or accepting option; a disabled one is skipped); an event with no
## choices gets Continue. Uses the notice's own confirmed signal, the same one the OK button emits.
## Returns how many were answered.
## --event-policy=first (default): the first enabled choice (the paying one on EV17, EV18, EV20).
## --event-policy=decline: the last enabled choice (the leave / skip / decline one), so no fee is paid.
func _event_pick(notice) -> int:
	var idx := -1
	for i in notice.enabled_choices:
		if event_policy == "first":
			return i
		idx = i
	return idx

func _resolve_events() -> int:
	var answered := 0
	while main.event_notice != null and answered < 10:
		var notice = main.event_notice
		notice.confirmed.emit(_event_pick(notice))  # -1 (Continue) when the event has no choices
		answered += 1
	return answered


## Fast clock: one call runs the normal end-of-cycle path exactly once.
## Timer clock: real _process chunks until the cycle counter moves or the game ends.
func _advance_timer() -> void:
	main.set_paused(false)
	var start: int = main.cycle
	var chunks := 0
	while main.cycle == start and not main.game_over and chunks < MAX_CHUNKS:
		chunks += 1
		if main.paused:  # an event paused the game mid-cycle: answer it, then carry on
			var answered := _resolve_events()
			events_resolved += answered
			if answered == 0:
				break  # no answer: the check below reports the cycle as not ended
			main.set_paused(false)
			continue
		main._process(float(rng.randi_range(1, 45)))  # 1 to 45 s chunks; a cycle is 120 s
	if chunks >= MAX_CHUNKS:
		_issue("softlock", start, "timer clock: cycle never ended after %d chunks" % MAX_CHUNKS)
		hung = true
	main.set_paused(true)


func _check_cycle_result(c: int, ended_before: int) -> void:
	if hung:
		return
	if ended_count != ended_before + 1:
		_issue("softlock", c, "advance did not end exactly one cycle (cycle_ended fired %d times)" % (ended_count - ended_before))
		hung = true
		return
	if main.game_over != expect_over:
		_issue("win_loss_check", c, "game_over=%s but expected %s (cash %d, win_cash %d, cycle %d, win_cycle %d, force %s)" % [
			main.game_over, expect_over, main.cash, win_cash, last_ended, win_cycle, main.debug_force_goal])
		hung = true
		return
	if main.game_over and (main.cash >= win_cash) != main.choice_pending:
		_issue("win_loss_check", c, "choice screen %s but cash %d vs win_cash %d" % [
			"pending" if main.choice_pending else "absent", main.cash, win_cash])
		hung = true
		return
	if not main.game_over and main.cycle != last_ended + 1:
		_issue("cycle_count", c, "cycle counter %d after ending cycle %d, expected %d" % [main.cycle, last_ended, last_ended + 1])
		hung = true


## The win choice: the bot answers through the end screen's own signal, then checks the save.
func _resolve_choice() -> void:
	choice_cycle = main.cycle
	if main.end_screen == null:
		_issue("choice_missing", choice_cycle, "choice_pending is set but no end screen exists")
		hung = true
		return
	var saved := SaveGame.load_state()
	if not bool(saved.get("choice_pending", false)):
		_issue("save_mismatch", choice_cycle, "unanswered win choice is not in the save (a reload would skip it)")
	if reload_at_choice and not reloaded:
		_reload_game()
	choice_side = _pick_side()
	main.end_screen.chosen.emit(choice_side)
	_count("win_choice", choice_cycle)


func _pick_side() -> String:
	if choice_policy == "RELEASE" or choice_policy == "CORP":
		return choice_policy
	return "RELEASE" if seed_value % 2 == 1 else "CORP"


## Player-style decisions while paused. One fixed order every cycle.
func _decide(c: int) -> void:
	if main.ships == 0:
		_buy_ship_at(_mission_planet(), c)  # tutorial: the first ship is bought at the mission planet
	if strategy == "always_expand":
		_buy_spare_ships(c)  # T161 follow-up: ships whenever cash allows, before skills and routes
	if strategy != "sloppy":
		_learn_skills()
	_buy_wanted_permit()
	var plan := _plan()
	_expand(plan, c)
	var active := _sync_lanes(plan)
	_apply_orders(active)


func _mission_planet() -> int:
	return int(main.mission_planet) if int(main.mission_planet) >= 0 else 0


## Profitable lanes: buy at a (Buy order at a, stock into a's storage), move to b ("Send to..."),
## sell at b. Profit per cycle = (sell_b - buy_a) * units - route fixed cost.
func _ranked_lanes(ignore_closed := false) -> Array:
	var out: Array = []
	var units: int = mini(int(main.engine.local_amount()), int(main.engine.units_per_cycle()))
	var fixed: int = int(main.engine.fixed_cost())
	var n: int = main.trade.planets.size()
	for c in main.engine.commodities:
		var cs := str(c)
		for a in n:
			for b in n:
				if a == b or (not ignore_closed and (not main.engine.planet_open(a) or not main.engine.planet_open(b))):
					continue
				var bp: int = main.trade.price(a, cs + "_buy")
				var sp: int = main.trade.price(b, cs + "_sell")
				if bp <= 0 or sp < 0:
					continue
				var profit: int = (sp - bp) * units - fixed
				# A lane is worth a ship only if one cycle's profit pays the ship back within PAYBACK_CYCLES.
				var ship_price: int = int(main.balance.get("ship_price", 0))
				if profit * PAYBACK_CYCLES >= ship_price and not _cross_system_blocked(a, b):  # the game refuses cross-system routes without C3
					out.append({"a": a, "b": b, "c": cs, "profit": profit})
	out.sort_custom(func(x, y): return x["profit"] > y["profit"])
	return out


## QA: the game's own rule (route_engine.gd): a route between two systems needs Long Haul (C3).
func _cross_system_blocked(a: int, b: int) -> bool:
	var sa := int(main.trade.planets[a].get("system", 1))
	var sb := int(main.trade.planets[b].get("system", 1))
	return sa != sb and not main.learned_skills.has("C3")


func _plan() -> Array:
	var ranked := _ranked_lanes()
	match strategy:
		"sloppy":
			if locked_lane.is_empty() and not ranked.is_empty():
				locked_lane = ranked[0]
				notes.append("sloppy locked lane %s %d->%d at cycle %d" % [locked_lane["c"], locked_lane["a"], locked_lane["b"], main.cycle])
			return [] if locked_lane.is_empty() else [locked_lane]
		"mining_focus":
			return _mining_plan(ranked)
		"never_expand":
			return ranked.slice(0, mini(1, ranked.size()))
		"decent":
			return ranked.slice(0, mini(DECENT_LANES, ranked.size()))
		_:  # always_expand
			var cap := maxi(1, int(main.balance.get("ship_cap", 1)))
			return ranked.slice(0, mini(cap, ranked.size()))


func _missing_lanes(plan: Array) -> int:
	var k := 0
	for lane in plan:
		if main.engine.find_same(int(lane["a"]), int(lane["b"]), str(lane["c"])) < 0:
			k += 1
	return k


## Ship purchases per strategy. Buys happen at the lane source (the ship button sits on the panel).
func _expand(plan: Array, c: int) -> void:
	if strategy == "dead_run" and permit_sid >= 0 and not main.open_systems.has(permit_sid) and main.learned_skills.has("C1") \
			and int(main.cash) < int(main.permit_cost(permit_sid)) + 150:
		return  # R2: dead_run saves cash for the system 2 permit before buying more ships
	var price: int = int(main.balance.get("ship_price", 0))
	var home: int = _lane_home(plan)
	match strategy:
		"always_expand":
			while _missing_lanes(plan) > main.free_ships() and main.can_buy_ship()["ok"]:
				var before: int = main.ships
				_buy_ship_at(home, c)
				if main.ships == before:
					break
		"decent", "mining_focus", "dead_run":  # T161: mining_focus and dead_run expand like decent
			while _missing_lanes(plan) > main.free_ships() and c >= DECENT_FROM_CYCLE \
					and main.cash - price >= DECENT_RESERVE and main.can_buy_ship()["ok"]:
				var before_d: int = main.ships
				_buy_ship_at(home, c)
				if main.ships == before_d:
					break
		"sloppy":
			if _missing_lanes(plan) > main.free_ships() and main.can_buy_ship()["ok"]:
				_buy_ship_at(home, c)
		_:
			pass  # never_expand: the tutorial ship only


func _buy_ship_at(p: int, c: int) -> void:
	var before: int = main.ships
	_select(p)
	main.ship_panel.buy_requested.emit("small")
	if main.ships > before:
		ship_buys.append([c, p, main.ships])
		_count("ship_buy", c)


## Routes: remove routes no longer in the plan or whose destination is full (frees their ship),
## then build the missing planned lanes while a ship is free. Sloppy never removes its lane.
## Returns the lanes that have a route now.
func _sync_lanes(plan: Array) -> Array:
	if strategy != "sloppy":
		# T94 --keep-closed: a route is kept while its lane is profitable, closure or not (the game then blocks it and pays 0)
		var keep_lanes: Array = _ranked_lanes(true) if keep_closed else plan
		for rec in main.engine.routes.duplicate(true):
			var a := int(rec["a"])
			var b := int(rec["b"])
			var c := str(rec["c"])
			var keep: bool = _in_plan(a, b, c, keep_lanes) and not bool(main.storage.is_full(str(rec["dst"]), c))
			if not keep:
				_remove_route(int(rec["id"]))
	var active: Array = []
	for lane in plan:
		var a2 := int(lane["a"])
		var b2 := int(lane["b"])
		var c2 := str(lane["c"])
		if main.engine.find_same(a2, b2, c2) < 0:
			if main.free_ships() <= 0 or main.storage.is_full(main.storage.planet_key(b2), c2):
				continue
			if not _build_route(lane):
				continue
		active.append(lane)
	return active


func _in_plan(a: int, b: int, c: String, plan: Array) -> bool:
	for lane in plan:
		if int(lane["a"]) == a and int(lane["b"]) == b and str(lane["c"]) == c:
			return true
	return false


## "Send to..." as a player does it: select the source, press Send to... on its storage row for the
## commodity, then click the destination planet.
func _build_route(lane: Dictionary) -> bool:
	if int(lane["a"]) <= -1000:  # T161: a cluster node (Clusters.BASE)
		return _build_cluster_route(lane)
	var a := int(lane["a"])
	var b := int(lane["b"])
	var c := str(lane["c"])
	var check: Dictionary = main.can_connect(a, b, c)
	_select(a)
	main.planet_panel.send_requested.emit(c)
	main.map.planet_clicked.emit(b)
	if main.engine.find_same(a, b, c) < 0 and not main.pending.is_empty() and main.pending.has("dest"):
		main.map.planet_clicked.emit(b)  # T161: a stop is on the way, so the first click only picked the destination; the second sends direct
	if main.engine.find_same(a, b, c) >= 0:
		lanes_built += 1
		_count("route_open", main.cycle)
		return true
	if not main.pending.is_empty():
		main.cancel_pending()
	if check["ok"]:
		_issue("route_build_failed", main.cycle, "Send to... %s %d->%d did not create a route although can_connect was ok (notice: %s)" % [
			c, a, b, main.last_notice])
	return false


## Remove a route from the planet panel's Remove button (route_id from the route list).
func _remove_route(id: int) -> void:
	var routes_before: int = main.engine.routes.size()
	main.planet_panel.remove_requested.emit(id)
	lanes_removed += 1
	if main.engine.routes.size() < routes_before:
		_count("route_close", main.cycle)


## Buy / Sell toggles. Each role is on only at the lane's ends: buy at a, sell at b.
func _apply_orders(active: Array) -> void:
	var want := {}
	for lane in active:
		if _buy_wanted(int(lane["a"]), str(lane["c"])):
			want["%d|%s|buy" % [int(lane["a"]), str(lane["c"])]] = true
		want["%d|%s|sell" % [int(lane["b"]), str(lane["c"])]] = true
	for o in main.engine.local.values().duplicate(true):
		for role in ["buy", "sell"]:
			var key := "%d|%s|%s" % [int(o["planet"]), str(o["c"]), role]
			if bool(o[role]) and not want.has(key):
				_set_order(int(o["planet"]), str(o["c"]), role, false)
	for key in want.keys():
		var parts: PackedStringArray = str(key).split("|")
		_set_order(int(parts[0]), parts[1], parts[2], true)


## Buy side of a lane. The route moves units_per_cycle a turn, so a Buy order only refills what the route
## can move (stock below one shipment) and only while cash covers the trip and the purchase. Sloppy keeps
## its Buy order on at full size with no reserve, so its stock piles up and it runs dry.
func _buy_wanted(a: int, c: String) -> bool:
	if a <= -1000:  # T161: clusters are free ore, no buy order
		return false
	if strategy == "sloppy":
		return true
	var units: int = mini(int(main.engine.local_amount()), int(main.engine.units_per_cycle()))
	var bp: int = int(main.trade.price(a, c + "_buy"))
	var stock: int = int(main.storage.amount(main.storage.planet_key(a), c))
	# A Buy order buys what cash allows (engine), so one unit of cash-above-trip is enough to keep it on.
	# Requiring a full shipment here left cash stuck at the trip cost with no trade, a deadlock.
	return stock < units and main.cash >= int(main.engine.fixed_cost()) + maxi(bp, 1)


func _set_order(p: int, c: String, role: String, on: bool) -> void:
	if main.engine.local_on(p, c, role) == on:
		return
	_select(p)
	main.planet_panel.order_requested.emit(c, role)
	orders_changed += 1
	if main.engine.local_on(p, c, role) != on:
		_issue("order_failed", main.cycle, "%s %s order at planet %d did not switch to %s (notice: %s)" % [
			role, c, p, "on" if on else "off", main.last_notice])
	else:
		_count("order_change", main.cycle)


## Skills cost points only (no cash). Learns in tree order, restarting after each purchase so
## prerequisites unlock. Uses the same call as the skill screen.
func _csv(text: String) -> Array:
	var out: Array = []
	for part in text.split(","):
		if part.strip_edges() != "":
			out.append(part.strip_edges())
	return out


## QA: buy the --permit system as soon as the game allows it. Returns true when it bought.
func _buy_wanted_permit() -> bool:
	if permit_sid < 0 or main.open_systems.has(permit_sid):
		return false
	if not bool(main.can_buy_permit(permit_sid).get("ok", false)):
		return false
	var keep := 0 if strategy == "dead_run" else PERMIT_WORKING_CASH  # R2: dead_run buys the system 2 permit as soon as affordable
	if int(main.cash) < int(main.permit_cost(permit_sid)) + keep:  # QA: keep cash to buy stock after the permit
		return false
	var r: Dictionary = main.buy_permit(permit_sid)
	if r.get("ok", false):
		notes.append("permit %d bought at cycle %d" % [permit_sid, main.cycle])
		_count("permit_buy", main.cycle)
	return bool(r.get("ok", false))


## QA: skill points held back for the --permit system (only once C1 is learned, since C1 unlocks permits).
func _permit_reserve() -> int:
	if permit_sid < 0 or main.open_systems.has(permit_sid) or not main.learned_skills.has("C1"):
		return 0
	return _permit_points()


func _permit_points() -> int:
	return int(main.balance.get("permit_points_2", 0)) if permit_sid == 2 else int(main.balance.get("permit_points_3", 0))


func _learn_skills() -> void:
	var learned := true
	var order: Array = skill_order + SkillTree.all_ids()
	while learned:
		learned = false
		for id in order:
			if main.learned_skills.has(id) or skip_skills.has(id):
				continue
			if not only_skills.is_empty() and not only_skills.has(id):
				continue
			if _permit_reserve() > 0 and main.skill_points - SkillTree.cost(main.balance, id) < _permit_reserve():
				continue  # QA: keep the points the wanted permit needs
			var r: Dictionary = main.learn_skill(id)
			if r["ok"]:
				skills_learned.append([main.cycle, id])
				skill_log.append([main.cycle, id, SkillTree.cost(main.balance, id)])
				_count("skill_learn", main.cycle)
				learned = true
				break


## Idle: a cycle in which cash and total stock are unchanged moved nothing (no route ran, no order traded).
## IDLE_AFTER cycles in a row is a softlock: the run cannot make progress and only waits for the loss.
func _state_sig() -> Array:
	return [main.cash, _stock_total()]


func _stock_total() -> int:
	var t := 0
	for k in main.storage.stock.keys():
		for c in main.storage.stock[k].keys():
			t += int(main.storage.stock[k][c])
	return t


## A closed planet is not a dead end: while any planet is closed (events close planets for a few cycles, and
## routes touching them pay nothing) no idle cycle is counted. A cycle with cash or stock movement clears dead_from.
## The softlock issue is recorded only at run end, if dead_from is still set, so a recovered run is not flagged.
func _diag_dump(c: int) -> void:
	print("DIAG cycle %d cash %d fixed %d" % [c, main.cash, main.engine.fixed_cost()])
	for rec in main.engine.routes:
		print("DIAG route %s %s->%s state=%s reason=%s src=%s dst=%s" % [rec.get("c"), rec.get("a"), rec.get("b"), rec.get("state"), rec.get("reason"), rec.get("src"), rec.get("dst")])
	for o in main.engine.local.values():
		print("DIAG order planet=%s c=%s buy=%s sell=%s buy_state=%s sell_state=%s" % [o.get("planet"), o.get("c"), o.get("buy"), o.get("sell"), o.get("buy_state"), o.get("sell_state")])
		print("DIAG   stock=%s capacity=%s" % [main.storage.amount(str(o.get("planet")), str(o.get("c"))), main.storage.capacity_of(str(o.get("planet")))])


func _check_idle(c: int, before: Array) -> void:
	if main.game_over:
		return
	if not main.engine.closed_planets.is_empty():
		idle_streak = 0
		return
	if before == _state_sig():
		idle_streak += 1
		if idle_streak >= IDLE_AFTER and dead_from < 0:
			dead_from = c - IDLE_AFTER + 1
			_diag_dump(c)
	else:
		idle_streak = 0
		dead_from = -1


func _orders_on() -> int:
	var k := 0
	for o in main.engine.local.values():
		k += int(bool(o["buy"])) + int(bool(o["sell"]))
	return k


## Records one real player action (a no-op is never passed here) for the metrics report.
func _count(kind: String, c: int) -> void:
	decision_at[c] = int(decision_at.get(c, 0)) + 1
	decision_kinds[kind] = int(decision_kinds.get(kind, 0)) + 1


## T161 mining_focus: the plan is cluster ore lanes first (only with B1), then the commodity trade ranking.
func _mining_plan(ranked: Array) -> Array:
	var out: Array = []
	if main.can_mine():
		out.append_array(_cluster_lanes())
	if main.cycle == 5:  # T161 diagnostics
		notes.append("c5 mine=%s ore_in=%s cluster_lanes=%d ore_sell_prices=%s fixed=%d units=%d yield=%d" % [main.can_mine(), main.engine.commodities.has("ore"), out.size(), _ore_prices_text(), int(main.engine.fixed_cost()), int(main.engine.units_per_cycle()), int(main.clusters.yield_per_cycle())])
	out.append_array(ranked)
	var cap := maxi(1, int(main.balance.get("ship_cap", 1)))
	return out.slice(0, mini(cap, out.size()))


## T161: one ore lane per live cluster (best open destination, same system unless C3). Ore is free at the cluster.
func _cluster_lanes() -> Array:
	var out: Array = []
	if not main.engine.commodities.has("ore"):
		return out
	var units: int = mini(int(main.engine.units_per_cycle()), int(main.clusters.yield_per_cycle()))
	var fixed: int = int(main.engine.fixed_cost())
	var n: int = main.trade.planets.size()
	for sid in [1, 2]:
		for cl in main.clusters_in_system(sid):
			if int(cl["left"]) <= 0:
				continue
			var node: int = int(cl["node"])
			var best := {}
			for b in n:
				if not main.engine.planet_open(b):
					continue
				if int(main.trade.planets[b].get("system", 1)) != sid and not main.learned_skills.has("C3"):
					continue
				var sp: int = main.trade.price(b, "ore_sell")
				if sp <= 0:
					continue
				var profit: int = sp * units - fixed
				if profit > 0 and (best.is_empty() or profit > int(best["profit"])):  # T161: ore is free, so any profit beats the 10-cycle rule used for planet lanes
					best = {"a": node, "b": b, "c": "ore", "profit": profit}
			if not best.is_empty():
				out.append(best)
	out.sort_custom(func(x, y): return x["profit"] > y["profit"])
	return out


## T161: the bot cannot click a cluster, so the cluster route is opened with main.send_from_cluster (what the card's route button would call).
func _build_cluster_route(lane: Dictionary) -> bool:
	var a := int(lane["a"])
	var b := int(lane["b"])
	var c := str(lane["c"])
	main.send_from_cluster(a, b)
	if main.engine.find_same(a, b, c) >= 0:
		lanes_built += 1
		_count("route_open", main.cycle)
		return true
	notes.append("cluster lane %d->%d did not open at cycle %d (notice: %s)" % [a, b, main.cycle, main.last_notice])
	return false


## T161: ships for a cluster lane are bought at its destination planet (a cluster cannot be selected).
## T161 follow-up: always_expand buys a ship whenever cash covers the price (up to ship_cap), whether or not a lane needs it.
func _buy_spare_ships(c: int) -> void:
	var price: int = int(main.balance.get("ship_price", 0))
	var cap: int = maxi(1, int(main.balance.get("ship_cap", 1)))
	var ranked := _ranked_lanes()
	var home: int = int(ranked[0]["a"]) if not ranked.is_empty() and int(ranked[0]["a"]) > -1000 else _mission_planet()
	while main.ships < cap and int(main.cash) >= price and main.can_buy_ship()["ok"]:
		var before: int = main.ships
		_buy_ship_at(home, c)
		if main.ships == before:
			break
	if main.ships >= cap or int(main.cash) < price:
		return


func _lane_home(plan: Array) -> int:
	if plan.is_empty():
		return _mission_planet()
	var a := int(plan[0]["a"])
	return int(plan[0]["b"]) if a <= -1000 else a


## T161: per-good route-cycles, cluster lane-cycles and ore taken from clusters (for the mining report).
func _tally_goods() -> void:
	var running := 0
	var dr := [main.cycle, -1, -1, 0]
	for pid in dead_ids.keys():
		var idx := 1 if pid == "dead_1" else 2
		dr[idx] = int(main.dead.get_danger(str(pid)))
	for rec in main.engine.routes:
		if int(rec["a"]) >= 0 and int(rec["a"]) < main.trade.planets.size() and DeadWorlds.is_dead(main.trade.planets[int(rec["a"])]) and str(rec.get("reason", "")) == "":
			dr[3] += 1
	danger_rows.append(dr)
	for rec in main.engine.routes:
		var cc := str(rec["c"])
		lane_cycles[cc] = int(lane_cycles.get(cc, 0)) + 1
		if int(rec["a"]) <= -1000:
			cluster_lane_cycles += 1
		# T161 v3: warning streaks. reason is set by the last settle (route_engine.gd), so this reads last cycle.
		var rid := int(rec["id"])
		var rs := str(rec.get("reason", "")).to_lower()
		var warn := rs.find("cash") >= 0 or rs.find("room") >= 0
		if warn:
			streak_by_route[rid] = int(streak_by_route.get(rid, 0)) + 1
			reason_warn_cycles += 1
			if int(streak_by_route[rid]) == 3:
				_issue("warning_streak", main.cycle, "route %d shows '%s' for 3+ cycles in a row" % [rid, str(rec.get("reason", ""))])
		else:
			streak_by_route[rid] = 0
			if rs == "":
				running += 1
	# reserve check (approximate): a running route needs its trip and upkeep (fixed cost) out of cash when the next settle runs.
	if running > 0 and main.cash < int(main.engine.fixed_cost()) * running:
		reserve_short.append([main.cycle, main.cash, running, int(main.engine.fixed_cost())])
	if main.clusters == null:
		return
	for i in main.clusters.items.size():
		var now: int = main.clusters.left(i)
		if cluster_last_left.has(i):
			var drop: int = int(cluster_last_left[i]) - now
			if drop > 0:
				ore_taken += drop
				clusters_touched[i] = true
		cluster_last_left[i] = now


func _ore_prices_text() -> String:
	var parts: Array = []
	for b in main.trade.planets.size():
		parts.append(str(main.trade.price(b, "ore_sell")))
	return ",".join(parts)


func cash_rows_3_8() -> Array:
	var out: Array = []
	for row in cycle_rows:
		if int(row[0]) >= 3 and int(row[0]) <= 8:
			out.append(row)
	return out


func _clusters_left_total() -> int:
	var t := 0
	if main.clusters == null:
		return 0
	for i in main.clusters.items.size():
		t += main.clusters.left(i)
	return t


## R2 dead_run: finds the dead worlds, logs the route refusal reason when it changes, tries the fabric build.
var dead_ids := {}
var dead_last := {}
var dead_log: Array = []
var fabric_log: Array = []

func _dead_probe(c: int) -> void:
	if dead_ids.size() < 2:
		for i in main.trade.planets.size():
			var pid := str(main.trade.planets[i].get("id", ""))
			if pid == "dead_1" or pid == "dead_2":
				dead_ids[pid] = i
	if dead_ids.size() < 2 and c == 1:
		dead_log.append([c, "missing", str(dead_ids.keys()), main.trade.planets.size(), false, "dead world not found in trade.planets"])
	for pid in dead_ids.keys():
		var src: int = int(dead_ids[pid])
		var sys_id: int = int(main.trade.planets[src].get("system", 1))
		var com := "nullglass" if pid == "dead_2" else "dross"
		var dst := -1
		for j in main.trade.planets.size():
			if j != src and int(main.trade.planets[j].get("system", 1)) == sys_id and not DeadWorlds.is_dead(main.trade.planets[j]):
				dst = j
				break
		var r: Dictionary = main.can_connect(src, dst, com)
		var key := "%s|%s|%s" % [pid, dst, str(r["reason"])]
		if dead_last.get(pid, "") != key:
			dead_last[pid] = key
			dead_log.append([c, pid, com, dst, bool(r["ok"]), str(r["reason"])])
	# nullglass from Greywake to the system 1 station (Space Storage id -1)
	if dead_ids.has("dead_2"):
		var rs: Dictionary = main.can_connect(int(dead_ids["dead_2"]), -1, "nullglass")
		var k2 := "station|%s" % str(rs["reason"])
		if dead_last.get("station", "") != k2:
			dead_last["station"] = k2
			dead_log.append([c, "dead_2->station", "nullglass", -1, bool(rs["ok"]), str(rs["reason"])])
	if not main.open_systems.has(2) and permit_sid == 2:
		var pv: Dictionary = main.can_buy_permit(2)
		var pk := "permit|%s|%d|%d" % [str(pv.get("reason", "")), int(main.cash), int(main.permit_cost(2))]
		if dead_last.get("permit", "") != pk and (c <= 3 or c % 5 == 0):
			dead_last["permit"] = pk
			dead_log.append([c, "permit 2", "", -1, bool(pv.get("ok", false)), "%s cash %d cost %d" % [str(pv.get("reason", "")), int(main.cash), int(main.permit_cost(2))]])
	for sk in ["M1", "M2", "F1"]:
		if not main.learned_skills.has(sk):
			var lv: Dictionary = SkillTree.can_learn(main.learned_skills, main.skill_points, main.balance, sk, main.skill_ctx())
			var lk := "skill|%s|%s" % [sk, str(lv.get("reason", "")) + str(lv.get("why", ""))]
			if dead_last.get(sk, "") != lk:
				dead_last[sk] = lk
				dead_log.append([c, "skill " + sk, "", -1, bool(lv["ok"]), str(lv.get("reason", "")) + " " + str(lv.get("why", ""))])
	# R2: once the fabric is built, try the nullglass route from Greywake to the system 1 station once (accepted or refused, with reason)
	if main.fabric.built and dead_ids.has("dead_2") and not dead_last.has("attempt"):
		dead_last["attempt"] = "1"
		var gsrc: int = int(dead_ids["dead_2"])
		var ra: Dictionary = main.can_connect(gsrc, -1, "nullglass")
		if bool(ra["ok"]):
			var sr: Dictionary = main.send_stock_buying(gsrc, -1, "nullglass")
			dead_log.append([c, "attempt station", "nullglass", -1, bool(sr.get("ok", false)), "send: " + str(sr.get("reason", ""))])
		else:
			dead_log.append([c, "attempt station", "nullglass", -1, false, "refused: " + str(ra["reason"])])
	elif not main.fabric.built and dead_ids.has("dead_2") and c == 1:
		pass
	var fv: Dictionary = main.can_build_fabric()
	if bool(fv["ok"]):
		var r2: Dictionary = main.build_fabric()
		fabric_log.append([c, "built", bool(r2.get("ok", false))])
	elif str(fv["reason"]) != str(dead_last.get("fab", "")):
		dead_last["fab"] = str(fv["reason"])
		fabric_log.append([c, "refused", str(fv["reason"])])

func _select(p: int) -> void:
	main.map.planet_clicked.emit(p)


## QA reload: frees the running game and starts a new one from the save, as the main menu Continue does.
## Checks the choice comes back once, at the same cycle and cash, and still unanswered.
func _reload_game() -> void:
	reloaded = true
	var before_cycle: int = main.cycle
	var before_cash: int = main.cash
	var before_ships: int = main.ships
	get_root().remove_child(main)
	main.free()
	SaveGame.continue_requested = true
	main = load(MAIN_SCENE).instantiate()
	get_root().add_child(main)
	main.events.rng.seed = seed_value
	if main.preface != null:
		main._dismiss_preface()
	main.set_process(false)
	main.cycle_ended.connect(_on_cycle_ended)
	main.run_ended.connect(_on_run_ended)
	main.routes_settled.connect(_on_routes_settled)
	notes.append("reloaded from save at the win choice (cycle %d, cash %d)" % [before_cycle, before_cash])
	if main.cycle != before_cycle or main.cash != before_cash or main.ships != before_ships:
		reload_ok = false
		_issue("reload_state", before_cycle, "reload changed state: cycle %d -> %d, cash %d -> %d, ships %d -> %d" % [before_cycle, main.cycle, before_cash, main.cash, before_ships, main.ships])
	if not main.choice_pending or main.end_screen == null:
		reload_ok = false
		_issue("reload_choice", before_cycle, "choice did not come back after reload (choice_pending %s, end screen %s)" % [main.choice_pending, main.end_screen != null])
	choice_cycle = main.cycle


## T80 events check input: the active price and closure effects after this cycle's tick.
func _log_events() -> void:
	var rows: Array = []
	for a in main.events.active:
		rows.append([main.cycle, str(a["id"]), str(a["kind"]), int(a["planet"]), str(a["c"]), int(a["left"]), int(a["age"])])
	var closed: Array = main.engine.closed_planets.duplicate()
	if not rows.is_empty() or not closed.is_empty():
		event_rows.append({"cycle": main.cycle, "active": rows, "closed": closed})


## Records what the game is about to judge at the end of a cycle (signal fires before the check).
func _on_cycle_ended(cycle: int) -> void:
	ended_count += 1
	last_ended = cycle
	expect_over = main.debug_force_goal or main.cash >= win_cash or cycle >= win_cycle
	if expect_over and first_over_cycle < 0:
		first_over_cycle = cycle
	if probe != "":
		probe_rows.append(_probe_row(cycle))


## QA probe row: [cycle, cash, {sid: [open, post open]}, {sid: space stock}, {sid: planet stock}, closed planets, routes].
func _probe_row(cycle: int) -> Array:
	var posts := {}
	var space := {}
	var planet_stock := {}
	for sid in [1, 2, 3]:
		posts[str(sid)] = [main.open_systems.has(sid), main.space_post_open(sid)]
	for sid in main.open_systems:
		var key: String = main.storage.system_key(int(sid))
		var t := 0
		for c in main.commodities:
			t += int(main.storage.amount(key, str(c)))
		space[str(sid)] = t
	for i in main.map.planets.size():
		var sid: int = main.system_of(i)
		var pk: String = main.storage.planet_key(i)
		var t := 0
		for c in main.commodities:
			t += int(main.storage.amount(pk, str(c)))
		planet_stock[str(sid)] = int(planet_stock.get(str(sid), 0)) + t
	return [cycle, main.cash, posts, space, planet_stock, main.engine.closed_planets.duplicate(), main.engine.routes.size()]


## T94: runs at each settle (end of cycle, before the cycle counter moves). Classes for a route touching close_planet:
## closed (the planet is closed at settle: GDD says the route pays 0 and costs 0), bridged (the closure timer runs
## but a skill covers this cycle: the route still runs), otherwise open. Records what each route paid per class.
func _on_routes_settled(results: Array, _delta: int) -> void:
	if close_planet < 0 or play_cycle < 0:
		return
	var closed_now: bool = main.engine.closed_planets.has(close_planet)
	var bridged_now: bool = not closed_now and _timed_closure_active()
	if closed_now and closure_cycles.is_empty():
		closure_start_ids = route_ids_before.duplicate()
	if closed_now and not closure_cycles.has(play_cycle):
		closure_cycles.append(play_cycle)
	if bridged_now and not bridged_cycles.has(play_cycle):
		bridged_cycles.append(play_cycle)
	# Orders at the closed planet: the GDD says every order touching it idles (pays 0, moves 0 units).
	for row in main.last_local:
		if closed_now and int(row["planet"]) == close_planet:
			closed_order_units += int(row["n"])
			if int(row["n"]) != 0 or int(row["paid"]) != 0:
				closed_order_rows += 1
				_issue("closure_income", play_cycle, "%s order at closed planet %d moved %d units for %d cr (should be 0)" % [str(row["role"]), close_planet, int(row["n"]), int(row["paid"])])
	var seen := {}
	for v in results:
		var a := int(v["a"])
		var b := int(v["b"])
		if a != close_planet and b != close_planet:
			continue
		var id := int(v["id"])
		seen[id] = true
		var status := str(v["status"])
		var paid := int(v["paid"])
		var rec: Dictionary = closure_routes.get(id, {"id": id, "a": a, "b": b, "c": str(v["c"]),
			"closed_cycles": 0, "closed_paid": 0, "closed_statuses": [], "bridged_cycles": 0, "bridged_paid": 0,
			"pre_closure_paid": 0, "resumed_cycle": -1, "resumed_status": "", "resumed_paid": 0,
			"closed_dst_sell": 0, "bridged_dst_sell": 0, "open_dst_sell": 0})
		# Destination sells of this route's commodity at its far end: this is where route stock turns into cash.
		var dst_sell := 0
		var dst: int = b
		for row in main.last_local:
			if str(row["role"]) == "sell" and int(row["planet"]) == dst and str(row["c"]) == str(v["c"]):
				dst_sell += int(row["paid"])
		if closed_now:
			rec["closed_cycles"] = int(rec["closed_cycles"]) + 1
			rec["closed_paid"] = int(rec["closed_paid"]) + paid
			rec["closed_dst_sell"] = int(rec["closed_dst_sell"]) + dst_sell
			if not (rec["closed_statuses"] as Array).has(status):
				(rec["closed_statuses"] as Array).append(status)
			if paid != 0:
				_issue("closure_income", play_cycle, "route %d %s %d->%d paid %d while planet %d was closed (status %s)" % [id, str(v["c"]), a, b, paid, close_planet, status])
		elif bridged_now:
			rec["bridged_cycles"] = int(rec["bridged_cycles"]) + 1
			rec["bridged_paid"] = int(rec["bridged_paid"]) + paid
			rec["bridged_dst_sell"] = int(rec["bridged_dst_sell"]) + dst_sell
			# A block by another planet's closure (a separate event) is not this closure's business.
			if status == "blocked" and not _other_end_closed(a, b):
				_issue("income_stopped_bridged", play_cycle, "route %d %s %d->%d blocked in a bridged closure cycle (reason %s)" % [id, str(v["c"]), a, b, str(v["reason"])])
		else:
			if int(rec["closed_cycles"]) == 0:
				rec["pre_closure_paid"] = paid
				rec["open_dst_sell"] = int(rec["open_dst_sell"]) + dst_sell
			elif int(rec["resumed_cycle"]) < 0:
				rec["resumed_cycle"] = play_cycle
				rec["resumed_status"] = status
				rec["resumed_paid"] = paid
				if status == "blocked" and not _other_end_closed(a, b):
					_issue("income_not_resumed", play_cycle, "route %d %s %d->%d still blocked after planet %d reopened (reason %s)" % [id, str(v["c"]), a, b, close_planet, str(v["reason"])])
		closure_routes[id] = rec
	if closed_now or bridged_now:
		for id in route_ids_before:
			if not seen.has(int(id)):
				closure_drops.append([play_cycle, int(id)])
				if keep_closed:
					_issue("route_dropped_closed", play_cycle, "route %d touching closed planet %d was gone at settle (keep-closed run)" % [int(id), close_planet])


## True when an end of the route (a or b) is closed by any closure (another event may close the other planet).
func _other_end_closed(a: int, b: int) -> bool:
	return main.engine.closed_planets.has(a) or main.engine.closed_planets.has(b)


## Route ids touching planet p (empty for p < 0).
func _route_ids_at(p: int) -> Array:
	var out: Array = []
	if p < 0:
		return out
	for rec in main.engine.routes:
		if int(rec["a"]) == p or int(rec["b"]) == p:
			out.append(int(rec["id"]))
	return out


## True while the QA closure timer for close_planet is active (closed now, or bridged by a skill).
func _timed_closure_active() -> bool:
	for a in main.events.active:
		if str(a.get("kind", "")) == "closed" and int(a.get("planet", -1)) == close_planet:
			return true
	return false


## Closure summary for the RESULT line: how many routes earned during the closure and how many earned nothing.
func _closure_summary() -> Dictionary:
	var earned := 0
	var nothing := 0
	var kept := 0
	var own_paid_pos := 0
	var routes: Array = []
	for id in closure_start_ids:
		var rec: Dictionary = closure_routes.get(int(id), {})
		if rec.is_empty():
			continue
		kept += 1
	for id in closure_routes:
		var rec: Dictionary = closure_routes[id]
		if int(rec["closed_cycles"]) > 0:
			if int(rec["closed_dst_sell"]) > 0 or int(rec["closed_paid"]) > 0:
				earned += 1
			else:
				nothing += 1
			if int(rec["closed_paid"]) > 0:
				own_paid_pos += 1
		routes.append(rec)
	return {
		"keep_closed": keep_closed,
		"closed_cycle_list": closure_cycles,
		"bridged_cycle_list": bridged_cycles,
		"routes_at_closure": closure_start_ids,
		"routes_seen_in_closure": kept,
		"routes_earned_in_closure": earned,
		"routes_earned_nothing": nothing,
		"routes_own_paid_positive_in_closure": own_paid_pos,
		"closed_order_units": closed_order_units,
		"closed_order_rows": closed_order_rows,
		"closed_income_total": _sum_closed_paid(),
		"drops": closure_drops,
		"routes": routes,
	}


func _sum_closed_paid() -> int:
	var t := 0
	for id in closure_routes:
		t += int(closure_routes[id]["closed_paid"])
	return t


func _on_run_ended(side: String, ending_id: String) -> void:
	run_end_count += 1
	run_side = side
	run_ending = ending_id


func _issue(kind: String, cycle: int, detail: String) -> void:
	issues.append([kind, cycle, detail])


## Checks made once the run is over: stats, autosave and end screen; then the RESULT line.
func _finish() -> bool:
	if dead_from >= 0:
		_issue("softlock", dead_from, "idle from cycle %d: %d cycles with no cash or stock change until the end (cash %d, ships %d, routes %d, Buy/Sell orders on %d, closed planets %d)" % [
			dead_from, IDLE_AFTER, main.cash, main.ships, main.engine.routes.size(), _orders_on(), main.engine.closed_planets.size()])
	var end_cycle: int = main.cycle
	var final_cash: int = main.cash
	var outcome := "softlock"
	if main.game_over and run_end_count == 1:
		outcome = "loss" if run_side == "LOSS" else "win"
		_check_run_record()
	elif main.game_over:
		_issue("softlock", end_cycle, "game over but run_ended fired %d times (choice never answered?)" % run_end_count)
	if not main.game_over:
		_issue("softlock", end_cycle, "run did not finish: cycle %d, cash %d" % [end_cycle, final_cash])
	var pace := {}
	for r in cycle_rows:
		if r[0] in [10, 20, 25]:
			pace[str(r[0])] = r[1]
	var cycle_keys: Array = []
	for r in cycle_rows:
		cycle_keys.append(r[0])
	for k in decision_at.keys():
		if not cycle_keys.has(k):
			cycle_keys.append(k)
	cycle_keys.sort()
	var decisions_by_cycle: Array = []
	var decisions_total := 0
	for k in cycle_keys:
		var n: int = int(decision_at.get(k, 0))
		decisions_by_cycle.append([k, n])
		decisions_total += n
	var result := {
		"strategy": strategy,
		"seed": seed_value,
		"clock": clock,
		"choice_policy": choice_policy,
		"force_goal_cycle": force_cycle,
		"inject": "%d:%d" % [inject_cycle, inject_cash] if inject_cycle >= 0 else "",
		"outcome": outcome,
		"side": run_side,
		"ending_id": run_ending,
		"final_cash": final_cash,
		"cycle_reached": end_cycle,
		"choice_cycle": choice_cycle,
		"expected_end_cycle": first_over_cycle,
		"end_cycle_ok": end_cycle == first_over_cycle,
		"cycles_ended": ended_count,
		"ships_owned": main.ships,
		"lane_cycles": lane_cycles,
		"warn_route_cycles": reason_warn_cycles,
		"reserve_short": reserve_short,
		"cash_rows_3_8": cash_rows_3_8(),
		"cluster_lane_cycles": cluster_lane_cycles,
		"ore_taken": ore_taken,
		"dead_log": dead_log,
		"fabric_log": fabric_log,
		"danger_rows": danger_rows,
		"fabric_state": str(main.fabric.get("state")) + "/" + str(main.fabric.get("built")),
		"clusters_harvested": clusters_touched.size(),
		"clusters_left_end": _clusters_left_total(),
		"ship_buys": ship_buys,
		"routes_open": main.engine.routes.size(),
		"lanes_built": lanes_built,
		"lanes_removed": lanes_removed,
		"orders_changed": orders_changed,
		"skills_learned": skills_learned,
		"skill_log": skill_log,
		"skill_points_left": main.skill_points,
		"permits_bought": int(decision_kinds.get("permit_buy", 0)),
		"dead_from_cycle": dead_from,
		"stats_ok": stats_ok,
		"end_screen_ok": end_screen_ok,
		"event_rows": event_rows,
		"cash_at": pace,
		"cash_by_cycle": cycle_rows.map(func(r): return [r[0], r[1]]),
		"issues": issues,
		"notes": notes,
		"decisions_total": decisions_total,
		"decisions_by_cycle": decisions_by_cycle,
		"decisions_by_kind": decision_kinds,
		"skip_skills": skip_skills,
		"events_resolved": events_resolved,
		"probe": probe_rows,
		"close_at": close_at,
		"close_planet": close_planet,
		"closure": _closure_summary() if close_planet >= 0 else {},
	}
	print("RESULT " + JSON.stringify(result))
	quit(0)
	return true


func _check_run_record() -> void:
	var c: int = main.cycle
	var after := RunStats.load_stats()
	var runs_before := int(stats_before.get("runs", 0))
	if int(after.get("runs", 0)) != runs_before + 1:
		stats_ok = false
		_issue("run_stats", c, "runs %d -> %d, expected +1" % [runs_before, int(after.get("runs", 0))])
	var ch_b: Dictionary = stats_before.get("choices", {})
	var ch_a: Dictionary = after.get("choices", {})
	if int(ch_a.get(run_side, 0)) != int(ch_b.get(run_side, 0)) + 1:
		stats_ok = false
		_issue("run_stats", c, "choices[%s] did not gain exactly 1" % run_side)
	var en_b: Dictionary = stats_before.get("endings", {})
	var en_a: Dictionary = after.get("endings", {})
	if run_ending != "" and int(en_a.get(run_ending, 0)) != int(en_b.get(run_ending, 0)) + 1:
		stats_ok = false
		_issue("run_stats", c, "endings[%s] did not gain exactly 1" % run_ending)
	if SaveGame.exists():
		_issue("save_not_cleared", c, "autosave still present after the run ended")
	end_screen_ok = main.end_screen != null and main.end_screen.get_child_count() > 0
	if not end_screen_ok:
		_issue("end_screen_empty", c, "end screen has no content after run_ended")
