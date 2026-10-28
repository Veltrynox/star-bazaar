extends SceneTree
## QA bot harness (owned by qa-analyst). Not gameplay code: nothing under game/ or data/ is changed.
## Plays one full game of game/main.tscn headless.
##
## The bot acts only through the signals a player's clicks emit, plus main.learn_skill for skills:
##   map.planet_clicked (select a planet, or pick a "Send to..." destination)
##   planet_panel.order_requested (Buy / Sell standing local order toggle)
##   planet_panel.send_requested ("Send to..." on a storage row)
##   planet_panel.remove_requested (Remove on a route)
##   planet_panel.buy_ship_requested (ship button)
##   end_screen.chosen (Release / Stay as a Corporation buttons on the choice screen)
##
## Each cycle, while the game is paused:
##   0. events (T12 hook _resolve_events; none in this build)
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
##   --strategy=decent|sloppy|always_expand|never_expand
##   --seed=<int>            only drives timer chunks and the alt choice (the game has no RNG)
##   --clock=fast|timer
##   --choice=alt|RELEASE|CORP   alt: odd seed RELEASE, even seed CORP (default alt)
##   --force-goal=<cycle>    turns on the debug "Force goal at cycle end" toggle at that cycle
##                           (debug builds only; QA reaches the choice early)
##   --inject=<cycle>:<credits>  QA test input: credits added at the start of that cycle
##
## Run (from the repo root, or through qa/bots/run_batch.sh which also uses a scratch HOME):
##   HOME=<scratch dir> tools/godot/Godot.app/Contents/MacOS/Godot --headless --path . \
##     -s res://qa/bots/bot_run.gd -- --strategy=decent --seed=1
## Prints one line "RESULT {json}" and exits.
##
## T87 hook (several ships on one lane): not wired yet. When it lands, sloppy and decent should send
## a second ship down the top lane with the same Send to... (see _sync_lanes). Not a bug until then.
## T12 hook (events): _resolve_events() must answer each pending event; see _advance_timer.

const MAIN_SCENE := "res://game/main.tscn"
const SaveGame := preload("res://game/save_game.gd")
const SkillTree := preload("res://game/skill_tree.gd")
const STRATEGIES := ["decent", "sloppy", "always_expand", "never_expand"]
const DECENT_LANES := 24  # no lane cap, matching tools/sim.py decent (ship_cap is the only limit)
const DECENT_FROM_CYCLE := 1  # buy from the first cycle, matching tools/sim.py decent
const DECENT_RESERVE := 0  # no cash reserve, matching tools/sim.py decent
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
var skip_skills: Array = []  # QA option --skip-skill=A3,... (never learn these ids)
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
var lanes_built := 0
var lanes_removed := 0
var orders_changed := 0
var notes: Array = []
var issues: Array = []  # [kind, cycle, detail]
var cycle_rows: Array = []  # [cycle, cash, ships, routes]


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--strategy="):
			strategy = arg.trim_prefix("--strategy=")
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
		elif arg.begins_with("--inject="):
			var parts := arg.trim_prefix("--inject=").split(":")
			inject_cycle = int(parts[0])
			inject_cash = int(parts[1])
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
		phase = 1
		return false
	if phase == 1:
		if main.preface != null:
			main._dismiss_preface()  # the player presses Start on the preface
		main.set_process(false)  # the bot owns the clock; engine frames must not add time
		main.cycle_ended.connect(_on_cycle_ended)
		main.run_ended.connect(_on_run_ended)
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
	main.set_paused(true)
	var c: int = main.cycle
	if c == inject_cycle:
		main.cash += inject_cash
		notes.append("injected %d credits at cycle %d (QA test input)" % [inject_cash, c])
	if c == force_cycle:
		main.debug_force_goal = true
		notes.append("debug force-goal toggle on at cycle %d (QA; same as the debug menu)" % c)
	_resolve_events()
	if not main.pending.is_empty():
		main.cancel_pending()
	_decide(c)
	cycle_rows.append([c, main.cash, main.ships, main.engine.routes.size()])
	var sig_before := _state_sig()
	var ended_before := ended_count
	if clock == "timer":
		_advance_timer()
	else:
		main.debug_advance_cycle()
	_check_cycle_result(c, ended_before)
	if not hung:
		_check_idle(c, sig_before)
	if not hung and main.choice_pending:
		_resolve_choice()
	main.set_paused(true)


## T12 HOOK: events are not in the build. When they land, answer every pending event here (a choice
## picked by strategy, or Continue) and return how many were answered. Called before each cycle's
## decisions and inside the timer loop when the game pauses mid-cycle.
func _resolve_events() -> int:
	return 0


## Fast clock: one call runs the normal end-of-cycle path exactly once.
## Timer clock: real _process chunks until the cycle counter moves or the game ends.
func _advance_timer() -> void:
	main.set_paused(false)
	var start: int = main.cycle
	var chunks := 0
	while main.cycle == start and not main.game_over and chunks < MAX_CHUNKS:
		chunks += 1
		if main.paused:  # an event paused the game mid-cycle: answer it, then carry on
			if _resolve_events() == 0:
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
	choice_side = _pick_side()
	main.end_screen.chosen.emit(choice_side)


func _pick_side() -> String:
	if choice_policy == "RELEASE" or choice_policy == "CORP":
		return choice_policy
	return "RELEASE" if seed_value % 2 == 1 else "CORP"


## Player-style decisions while paused. One fixed order every cycle.
func _decide(c: int) -> void:
	if main.ships == 0:
		_buy_ship_at(_mission_planet(), c)  # tutorial: the first ship is bought at the mission planet
	if strategy != "sloppy":
		_learn_skills()
	var plan := _plan()
	_expand(plan, c)
	var active := _sync_lanes(plan)
	_apply_orders(active)


func _mission_planet() -> int:
	return int(main.mission_planet) if int(main.mission_planet) >= 0 else 0


## Profitable lanes: buy at a (Buy order at a, stock into a's storage), move to b ("Send to..."),
## sell at b. Profit per cycle = (sell_b - buy_a) * units - route fixed cost.
func _ranked_lanes() -> Array:
	var out: Array = []
	var units: int = mini(int(main.engine.local_amount()), int(main.engine.units_per_cycle()))
	var fixed: int = int(main.engine.fixed_cost())
	var n: int = main.trade.planets.size()
	for c in main.engine.commodities:
		var cs := str(c)
		for a in n:
			for b in n:
				if a == b or not main.engine.planet_open(a) or not main.engine.planet_open(b):
					continue
				var bp: int = main.trade.price(a, cs + "_buy")
				var sp: int = main.trade.price(b, cs + "_sell")
				if bp <= 0 or sp < 0:
					continue
				var profit: int = (sp - bp) * units - fixed
				if profit > 0:
					out.append({"a": a, "b": b, "c": cs, "profit": profit})
	out.sort_custom(func(x, y): return x["profit"] > y["profit"])
	return out


func _plan() -> Array:
	var ranked := _ranked_lanes()
	match strategy:
		"sloppy":
			if locked_lane.is_empty() and not ranked.is_empty():
				locked_lane = ranked[0]
				notes.append("sloppy locked lane %s %d->%d at cycle %d" % [locked_lane["c"], locked_lane["a"], locked_lane["b"], main.cycle])
			return [] if locked_lane.is_empty() else [locked_lane]
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
	var price: int = int(main.balance.get("ship_price", 0))
	var home: int = int(plan[0]["a"]) if not plan.is_empty() else _mission_planet()
	match strategy:
		"always_expand":
			while _missing_lanes(plan) > main.free_ships() and main.can_buy_ship()["ok"]:
				var before: int = main.ships
				_buy_ship_at(home, c)
				if main.ships == before:
					break
		"decent":
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
	main.planet_panel.buy_ship_requested.emit()
	if main.ships > before:
		ship_buys.append([c, p, main.ships])


## Routes: remove routes no longer in the plan or whose destination is full (frees their ship),
## then build the missing planned lanes while a ship is free. Sloppy never removes its lane.
## Returns the lanes that have a route now.
func _sync_lanes(plan: Array) -> Array:
	if strategy != "sloppy":
		for rec in main.engine.routes.duplicate(true):
			var a := int(rec["a"])
			var b := int(rec["b"])
			var c := str(rec["c"])
			var keep: bool = _in_plan(a, b, c, plan) and not bool(main.storage.is_full(str(rec["dst"]), c))
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
	var a := int(lane["a"])
	var b := int(lane["b"])
	var c := str(lane["c"])
	var check: Dictionary = main.can_connect(a, b, c)
	_select(a)
	main.planet_panel.send_requested.emit(c)
	main.map.planet_clicked.emit(b)
	if main.engine.find_same(a, b, c) >= 0:
		lanes_built += 1
		return true
	if not main.pending.is_empty():
		main.cancel_pending()
	if check["ok"]:
		_issue("route_build_failed", main.cycle, "Send to... %s %d->%d did not create a route although can_connect was ok (notice: %s)" % [
			c, a, b, main.last_notice])
	return false


## Remove a route from the planet panel's Remove button (route_id from the route list).
func _remove_route(id: int) -> void:
	main.planet_panel.remove_requested.emit(id)
	lanes_removed += 1


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
	if strategy == "sloppy":
		return true
	var units: int = mini(int(main.engine.local_amount()), int(main.engine.units_per_cycle()))
	var bp: int = int(main.trade.price(a, c + "_buy"))
	var stock: int = int(main.storage.amount(main.storage.planet_key(a), c))
	return stock < units and main.cash >= int(main.engine.fixed_cost()) + units * bp


func _set_order(p: int, c: String, role: String, on: bool) -> void:
	if main.engine.local_on(p, c, role) == on:
		return
	_select(p)
	main.planet_panel.order_requested.emit(c, role)
	orders_changed += 1
	if main.engine.local_on(p, c, role) != on:
		_issue("order_failed", main.cycle, "%s %s order at planet %d did not switch to %s (notice: %s)" % [
			role, c, p, "on" if on else "off", main.last_notice])


## Skills cost points only (no cash). Learns in tree order, restarting after each purchase so
## prerequisites unlock. Uses the same call as the skill screen.
func _learn_skills() -> void:
	var learned := true
	while learned:
		learned = false
		for id in SkillTree.all_ids():
			if main.learned_skills.has(id) or skip_skills.has(id):
				continue
			var r: Dictionary = main.learn_skill(id)
			if r["ok"]:
				skills_learned.append([main.cycle, id])
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


func _check_idle(c: int, before: Array) -> void:
	if main.game_over or dead_from >= 0:
		return
	if before == _state_sig():
		idle_streak += 1
		if idle_streak == IDLE_AFTER:
			dead_from = c - IDLE_AFTER + 1
			_issue("softlock", c, "idle from cycle %d: %d cycles with no cash or stock change (cash %d, ships %d, routes %d, Buy/Sell orders on %d)" % [
				dead_from, IDLE_AFTER, main.cash, main.ships, main.engine.routes.size(), _orders_on()])
	else:
		idle_streak = 0


func _orders_on() -> int:
	var k := 0
	for o in main.engine.local.values():
		k += int(bool(o["buy"])) + int(bool(o["sell"]))
	return k


func _select(p: int) -> void:
	main.map.planet_clicked.emit(p)


## Records what the game is about to judge at the end of a cycle (signal fires before the check).
func _on_cycle_ended(cycle: int) -> void:
	ended_count += 1
	last_ended = cycle
	expect_over = main.debug_force_goal or main.cash >= win_cash or cycle >= win_cycle
	if expect_over and first_over_cycle < 0:
		first_over_cycle = cycle


func _on_run_ended(side: String, ending_id: String) -> void:
	run_end_count += 1
	run_side = side
	run_ending = ending_id


func _issue(kind: String, cycle: int, detail: String) -> void:
	issues.append([kind, cycle, detail])


## Checks made once the run is over: stats, autosave and end screen; then the RESULT line.
func _finish() -> bool:
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
		"ship_buys": ship_buys,
		"routes_open": main.engine.routes.size(),
		"lanes_built": lanes_built,
		"lanes_removed": lanes_removed,
		"orders_changed": orders_changed,
		"skills_learned": skills_learned,
		"skill_points_left": main.skill_points,
		"permits_bought": null,  # no permit feature in this build; null, not 0, so it is not read as a result
		"dead_from_cycle": dead_from,
		"stats_ok": stats_ok,
		"end_screen_ok": end_screen_ok,
		"cash_at": pace,
		"cash_by_cycle": cycle_rows.map(func(r): return [r[0], r[1]]),
		"issues": issues,
		"notes": notes,
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
