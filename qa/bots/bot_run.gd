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
## Win: a market share over the win line held long enough (Four Markets); loss: swept, bankrupt, or the soft ending at win_cycle_markets.
## Checks at every cycle end: a win, swept or the last cycle ends the run (force toggle: debug Force market share, mil);
## a win, swept or the last cycle ends the run; exactly one run_ended per run; the
## RunStats gets +1 run, +1 side, +1 ending; the autosave is
## cleared after the run; the end screen has content.
##
## Strategies (names fixed):
##   decent        up to 3 lanes; buys a ship when a planned lane needs one, from cycle 4, and only
##                 while 1000 cr stay in cash afterwards; learns skills. Permits: none in this build.
##   always_expand up to ship_cap lanes; buys a ship whenever cash allows, no reserve; learns skills.
##   sloppy        one lane, locked at cycle 1: never re-planned, never removed, even when blocked;
##                 buys no ship beyond the lane's one; learns no skills.
##   never_expand  one lane (best profit), the tutorial ship only, forever; learns skills.
##   spread        QA 2026-11-03: decent expansion, but lanes are taken round-robin over the four markets (no --market).
##   bankrupt      QA 2026-11-03: buys a ship whenever one is allowed and spreads over all four markets (the overhead bleeds cash) with no skills, until repossession ends the run (END_BANKRUPT).
##   passive       QA 2026-11-03: the tutorial ship only, no lanes (or --passive-lanes=n), no skills: the swept / outcompeted loss.
##                 bankrupt: from cycle 8 cash is debited to --bankrupt-floor (default -300) each turn (QA overspend, like --inject).
##   local_focus   QA 2026-11-03: no routes, no ships beyond the tutorial one. Buy and Sell orders on every open planet
##                 that trades a --market good (local orders move order_amount units a cycle without a ship). learns skills.
##
## Options (after --):
##   --strategy=decent|sloppy|always_expand|never_expand|mining_focus
##                           (mining_focus, T161: Prospecting first; cluster ore lanes first, then the trade ranking)
##   --seed=<int>            only drives timer chunks and the alt choice (the game has no RNG)
##   --event-policy=first|decline   how event notices are answered (see _event_pick)
##   --clock=fast|timer
##   --choice=alt|RELEASE|CORP   alt: odd seed RELEASE, even seed CORP (default alt)
##   --chains=first|good|bad|random  QA 2026-11-03: market chain choices. good/bad take, per step, the option whose hidden nudge
##                           (Chains.nudge_of) pushes toward that ending flag; random uses the seed; first = event-policy as before.
##   --local-orders          QA 2026-11-03: also Buy and Sell on every focus-market planet, whatever the strategy
##   --market=mil|lux|min|bio  market focus (QA 2026-11-03): only goods of that market are traded (lanes and clusters)
##   --force-goal=<cycle>    turns on the debug "Force market share" (mil) at that cycle
##                           (debug builds only; QA reaches the choice early)
##   --inject=<cycle>:<credits>  QA test input: credits added at the start of that cycle
##   --close-at=<cycle>      QA closure (T94): the first route's source planet is closed from that cycle (timed, like an event).
##   --keep-closed           T94: a route touching a closed planet is kept while its lane stays profitable (not dropped).
##                           The RESULT line gets a "closure" record: closed and bridged cycles, what each route paid.
##   --skills=<id,id,...>    only these skills may be learned (empty value or none: no skill). Default: all.
##   --skill-order=<id,...>  learn these first, in this order, then the rest in tree order.
##   --permit=<system id>    buy that system's permit as soon as the game allows it (needs FND_PERMIT).
##                           decent defaults to --permit=2 (QA 2026-11-03); --no-permit turns that off.
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
const STRATEGIES := ["decent", "sloppy", "always_expand", "never_expand", "mining_focus", "dead_run", "local_focus", "spread", "bankrupt", "passive"]
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
var skip_skills: Array = []  # QA option --skip-skill=MIN_2,... (never learn these ids)
var only_skills: Array = []  # QA option --skills=... (empty: every skill may be learned)
var skill_order: Array = []  # QA option --skill-order=... (learned first, in this order)
var permit_sid := -1  # QA option --permit=<system id>
var default_permit := true  # QA 2026-11-03: decent buys permit 2 when affordable unless --no-permit
var rng := RandomNumberGenerator.new()
var main: Node = null
var phase := 0
var steps := 0
var hung := false
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
var local_orders := false  # --local-orders: Buy and Sell on every focus-market planet, on top of any strategy
var bankrupt_worst := false  # --bankrupt-worst: bankrupt builds the least profitable lanes instead of the spread of normal ones
var chain_policy := "first"  # --chains=first|good|bad|random
var chain_picks: Array = []  # [cycle, step id, option id, nudge, dir after]
var market_focus := ""  # --market=<id>: trade only goods of this market (empty: all goods)
var share_rows: Array = []  # per cycle end: [cycle, [share per Markets.ids], cash] (market readout for QA)
var events_resolved := 0  # events answered by _resolve_events (0 while the hook is a stub)
var workshops_built: Array = []  # QA 2026-11-03: [cycle, workshop id] per workshop the bot built
var craft_totals: Dictionary = {}  # QA 2026-11-03: workshop id -> {good: units made} over the run (main.workshops.made)
var bot_skill_log: Array = []  # QA 2026-11-03: [cycle, skill id, bot, until, ok, reason] per activation attempt
var bot_skill_rows: Array = []  # QA 2026-11-03: [play cycle, skill id, bot, strength_mult in its market] while a bot skill is live
var feed_log: Array = []  # QA 2026-11-03: [cycle, source planet, good, ok, reason] feed routes to the station (logged on change)
var feed_why: Dictionary = {}  # QA 2026-11-03: good -> last refusal reason
var live_bot_skills: Dictionary = {}  # skill id -> {bot, market, until} for the bot skill in effect
const BANKRUPT_FROM := 8  # bankrupt: cash is spent down to 0 at every turn from this cycle
var bankrupt_floor := -300  # --bankrupt-floor=<n>: cash after the QA overspend (negative: positive floors never went bankrupt, cash was never short)
var passive_lanes := 0  # --passive-lanes=<n>: passive keeps the n best lanes (default 0) and no extra ship
var drained := 0  # bankrupt: credits debited by the QA overspend
const FEED_SHIPS := 2  # QA 2026-11-03: ships a workshop's feed routes may take (a lane ship earns more than a longer chain)
const WORKSHOP_CASH := 300  # QA 2026-11-03: cash the bot keeps after it builds a workshop


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
		elif arg.begins_with("--bankrupt-floor="):
			bankrupt_floor = int(arg.trim_prefix("--bankrupt-floor="))
		elif arg.begins_with("--passive-lanes="):
			passive_lanes = int(arg.trim_prefix("--passive-lanes="))
		elif arg == "--bankrupt-worst":
			bankrupt_worst = true
		elif arg.begins_with("--chains="):
			chain_policy = arg.trim_prefix("--chains=")
		elif arg == "--local-orders":
			local_orders = true
		elif arg.begins_with("--market="):
			market_focus = arg.trim_prefix("--market=")
		elif arg == "--no-permit":
			default_permit = false
		elif arg.begins_with("--permit="):
			permit_sid = int(arg.trim_prefix("--permit="))
		elif arg.begins_with("--inject="):
			var parts := arg.trim_prefix("--inject=").split(":")
			inject_cycle = int(parts[0])
			inject_cash = int(parts[1])
	# QA 2026-11-03: the decent default is a human path: it buys the system 2 permit (FND_PERMIT + 600) as soon as it can afford it.
	if (strategy == "decent" or strategy == "spread") and permit_sid < 0 and default_permit:
		permit_sid = 2
	if market_focus != "" and skill_order.is_empty() and ["decent", "spread"].has(strategy):
		skill_order = ["FND_STORAGE", "FND_PERMIT"] + (["FND_PROSPECT"] if market_focus == "min" else []) + (["LUX_1", "LUX_4"] if market_focus == "lux" else [])  # QA 2026-11-03: a focus run learns its own market tree first
		for sid in SkillTree.all_ids():
			if str(SkillTree.node(sid).get("market", "")) == market_focus:
				skill_order.append(sid)
	if strategy == "mining_focus" and skill_order.is_empty():
		skill_order = ["FND_PROSPECT", "MIN_1", "MIN_3", "MIN_5"]  # mining_focus: Prospecting first, then the Minerals tree in order
	if strategy == "dead_run" and skill_order.is_empty():
		skill_order = ["FND_PERMIT", "FND_STORAGE", "FND_PROSPECT", "MIN_1", "MIN_2", "MIN_3", "MIN_4", "MIN_5"]  # dead_run: Foundations, then the Minerals tree (MIN_1 fabric, MIN_3 and MIN_5 open the dead worlds)
	if strategy == "always_expand" and skill_order.is_empty():
		skill_order = ["FND_PERMIT", "FND_STORAGE", "BIO_1", "BIO_2", "BIO_3"]  # expansion first: permit, storage, then Biotech
	if not STRATEGIES.has(strategy) or not ["fast", "timer"].has(clock) or not ["alt", "RELEASE", "CORP"].has(choice_policy) \
			or not ["first", "good", "bad", "random"].has(chain_policy):
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
		win_cycle = int(main.balance.get("win_cycle_markets", 0))
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
		main.debug_force_market = "mil"
		notes.append("debug force market share (mil) on at cycle %d (QA; same as the debug menu)" % c)
	events_resolved += _resolve_events()
	if not main.pending.is_empty():
		main.cancel_pending()
	_tally_craft()  # the last cycle's workshop run (made is reset at each run)
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
	main.set_paused(true)


## Events: answer every open event notice. The first enabled choice is taken (choices are ordered
## so the first is the paid or accepting option; a disabled one is skipped); an event with no
## choices gets Continue. Uses the notice's own confirmed signal, the same one the OK button emits.
## Returns how many were answered.
## --event-policy=first (default): the first enabled choice (the paying one on EV17, EV18, EV20).
## --event-policy=decline: the last enabled choice (the leave / skip / decline one), so no fee is paid.
func _event_pick(notice) -> int:
	var cid := str(main.events.pending_id)
	if chain_policy != "first" and cid != "" and main.events.is_chain_step(cid) and notice.enabled_choices.size() > 1:
		return _chain_pick(cid)
	var idx := -1
	for i in notice.enabled_choices:
		if event_policy == "first":
			return i
		idx = i
	return idx

## Chain step: the option index (in the shown order) per --chains. The bot reads the hidden nudge, it is QA.
func _chain_pick(step_id: String) -> int:
	var order: Array = Chains.order(step_id)
	var best := 0
	if chain_policy == "random":
		best = rng.randi_range(0, order.size() - 1)
	else:
		var best_n := 0
		for i in order.size():
			var n: int = Chains.nudge_of(step_id, str(order[i]))
			if i == 0 or (chain_policy == "good" and n > best_n) or (chain_policy == "bad" and n < best_n):
				best = i
				best_n = n
	var mk: String = Chains.market_of(step_id)
	var nudge: int = Chains.nudge_of(step_id, str(order[best]))
	chain_picks.append([main.cycle, step_id, str(order[best]), nudge, Chains.dir_of(mk) + nudge])
	return best


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
	if expect_over and not main.game_over:  # a win, swept or the last cycle must end the run (bankrupt can end it too: not predicted here)
		_issue("win_loss_check", c, "game still running but expected over (cash %d, cycle %d, win_cycle %d, force %s)" % [
			main.cash, last_ended, win_cycle, main.debug_force_market])
		hung = true
		return
	if not main.game_over and main.cycle != last_ended + 1:
		_issue("cycle_count", c, "cycle counter %d after ending cycle %d, expected %d" % [main.cycle, last_ended, last_ended + 1])
		hung = true


## Player-style decisions while paused. One fixed order every cycle.
func _decide(c: int) -> void:
	if c == 20 and OS.get_environment("BOT_DIAG") != "":
		_diag_dump(c)
	if main.ships == 0:
		_buy_ship_at(_mission_planet(), c)  # tutorial: the first ship is bought at the mission planet
	if strategy == "always_expand":
		_buy_spare_ships(c)  # T161 follow-up: ships whenever cash allows, before skills and routes
	if strategy == "bankrupt":
		_buy_spare_ships(c)
	if strategy != "sloppy" and strategy != "passive" and strategy != "bankrupt":
		_learn_skills()
		_workshop_turn(c)  # QA 2026-11-03: build the workshops of the focus once their node is learned
	_bot_skill_turn(c)  # QA 2026-11-03: a ready bot skill is used on the leading bot
	_buy_wanted_permit()
	var plan := _plan()
	_expand(plan, c)
	if strategy != "sloppy":
		_workshop_feed(c)  # QA 2026-11-03: workshop input routes to the station, before the planned lanes sync
	var active := _sync_lanes(plan)
	_apply_orders(active)
	if strategy == "bankrupt" and c >= BANKRUPT_FROM and main.cash > bankrupt_floor:
		# Real purchases cannot take cash below 0, so the overspend is a QA debit (like --inject, opposite sign): all cash above the floor is
		# "spent" at the end of the bot's turn, the cycle's overhead and upkeep then push it negative, rescues and repossessions follow.
		drained += int(main.cash) - bankrupt_floor
		main.cash = bankrupt_floor


func _mission_planet() -> int:
	return int(main.mission_planet) if int(main.mission_planet) >= 0 else 0


## Profitable lanes: buy at a (Buy order at a, stock into a's storage), move to b ("Send to..."),
## sell at b. Profit per cycle = (sell_b - buy_a) * units - route fixed cost.
func _ranked_lanes(ignore_closed := false, worst := false) -> Array:
	var out := _ranked_lanes_for(market_focus, ignore_closed, worst)
	if out.is_empty() and market_focus != "" and not worst:
		# QA 2026-11-03: no lane of the focus market is open yet (silk and musk trade only in system 2, behind the permit).
		# Bootstrap on any lane: it earns the cash and the skill points the permit costs.
		out = _ranked_lanes_for("", ignore_closed, worst)
	return out


func _ranked_lanes_for(focus: String, ignore_closed: bool, worst: bool) -> Array:
	var out: Array = []
	var n: int = main.trade.planets.size()
	var ship_price: int = int(main.balance.get("ship_price", 0))
	# QA 2026-11-03: surplus cash lets any lane with a real profit take a ship (ships up to ship_cap); lanes already running stay.
	var surplus: bool = int(main.cash) >= 2 * ship_price + main.engine.routes.size() * int(main.engine.fixed_cost())
	var poor_out: Array = []
	var feed_goods: Array = _workshop_inputs()
	for c in main.engine.commodities:
		var cs := str(c)
		if focus != "" and Markets.market_of(cs) != focus:
			continue
		# Real volume: the units a ship of this good moves per cycle (skills included), capped by the order size.
		var units: int = mini(int(main.engine.local_amount(cs)), int(main.engine.units_per_cycle(null, cs)))
		for a in n:
			for b in n:
				if a == b or (not ignore_closed and (not main.engine.planet_open(a) or not main.engine.planet_open(b))):
					continue
				var bp: int = main.trade.price(a, cs + "_buy")
				var sp: int = int(main.engine.sold_price(b, cs))
				if bp <= 0 or sp < 0:
					continue
				if not worst and not _lane_usable(a, b, cs):
					continue
				if not worst and feed_goods.has(cs) and int(main.trade.planets[b].get("system", 1)) == 1:
					continue  # QA 2026-11-03: a Sell in system 1 draws the Space Storage empty; that stock is the workshop's input
				# Real fixed cost of this very lane (route offset raises the upkeep of long lanes).
				var fixed: int = int(main.engine.fixed_cost(main.engine.new_record(a, b, cs)))
				var poor: bool = not worst and bp * units > int(main.cash) and int(main.storage.amount(main.storage.planet_key(a), cs)) < units
				var profit: int = (sp - bp) * units - fixed
				# A lane is worth a ship if one cycle's profit pays the ship back within PAYBACK_CYCLES, or (surplus cash, or the lane runs) if it earns at all.
				var ok: bool = profit * PAYBACK_CYCLES >= ship_price
				if not ok and profit > 0 and (surplus or main.engine.find_same(a, b, cs) >= 0):
					ok = true
				if (worst or ok) and not _cross_system_blocked(a, b):  # cross-system routes need no skill now
					# QA 2026-11-03: a lane whose Buy of one shipment is beyond the cash idles for want of cash; it is used only when no other lane exists.
					(poor_out if poor else out).append({"a": a, "b": b, "c": cs, "profit": profit, "units": units})
	if out.is_empty():
		out = poor_out
	out.sort_custom(func(x, y): return x["profit"] < y["profit"] if worst else x["profit"] > y["profit"])
	return out


## QA 2026-11-03: a lane the game would let a player build (open systems, trade post, permit), ignoring the free-ship check.
func _lane_usable(a: int, b: int, cs: String) -> bool:
	if not bool(main.engine.check_connection(a, b, cs, main.engine.find_same(a, b, cs) < 0).get("ok", false)):
		return false
	return main.system_trade_open(a) and main.system_trade_open(b)


## Routes between systems need no skill any more (Long Haul is gone).
func _cross_system_blocked(_a: int, _b: int) -> bool:
	return false


func _spread_plan(ranked: Array) -> Array:
	var per := {}
	for lane in ranked:
		var m := Markets.market_of(str(lane["c"]))
		if not per.has(m):
			per[m] = []
		per[m].append(lane)
	var out: Array = []
	var i := 0
	while out.size() < DECENT_LANES:
		var any := false
		for m in Markets.ids:
			var arr: Array = per.get(m, [])
			if i < arr.size() and out.size() < DECENT_LANES:
				out.append(arr[i])
				any = true
		if not any:
			break
		i += 1
	return out


func _lane_key(lane: Dictionary) -> String:
	return "%d|%d|%s" % [int(lane["a"]), int(lane["b"]), str(lane["c"])]


## QA 2026-11-03: ships up to ship_cap. When the base plan has fewer lanes than ship_cap, the best lanes take a second and third ship
## (the game allows up to lane_full: ships x units per cycle against the order size); each extra ship counts its own extra units.
func _fill_extra(plan: Array) -> Array:
	var cap := maxi(1, int(main.balance.get("ship_cap", 1)))
	var out: Array = plan.duplicate()
	if out.size() >= cap:
		return out
	var order: int = int(main.engine.local_amount())
	var fixed: int = int(main.engine.fixed_cost())
	var extras: Array = []
	for lane in plan:
		if int(lane["a"]) <= -1000:
			continue
		var per_unit := 0
		var cs := str(lane["c"])
		var u1: int = maxi(1, int(main.engine.units_per_cycle(null, cs)))
		var margin: int = int(main.engine.sold_price(int(lane["b"]), cs)) - int(main.trade.price(int(lane["a"]), cs + "_buy"))
		for k in range(1, 3):  # ship k+1 on the lane
			var extra_units: int = mini(order, (k + 1) * u1) - mini(order, k * u1)
			if extra_units <= 0:
				break
			var e: Dictionary = lane.duplicate()
			e["k"] = k
			e["profit"] = extra_units * margin - fixed
			if int(e["profit"]) > 0:
				extras.append(e)
	extras.sort_custom(func(x, y): return int(x["profit"]) > int(y["profit"]) if int(x["k"]) == int(y["k"]) else int(x["k"]) < int(y["k"]))
	for e in extras:
		if out.size() >= cap:
			break
		out.append(e)
	return out


func _plan() -> Array:
	var base := _plan_base()
	if ["decent", "mining_focus", "spread", "dead_run", "always_expand"].has(strategy):
		return _fill_extra(base)
	return base


func _plan_base() -> Array:
	if strategy == "bankrupt":
		var worst := _ranked_lanes(false, bankrupt_worst)  # bankrupt_worst: the unprofitable lanes first (they rarely run: no cash for them)
		return _spread_plan(worst).slice(0, maxi(1, int(main.balance.get("ship_cap", 1))))  # all four markets: the overhead bleeds cash too
	var ranked := _ranked_lanes()
	match strategy:
		"passive":
			return ranked.slice(0, mini(passive_lanes, ranked.size()))  # default 0 lanes
		"spread":
			return _spread_plan(ranked)
		"sloppy":
			if locked_lane.is_empty() and not ranked.is_empty():
				locked_lane = ranked[0]
				notes.append("sloppy locked lane %s %d->%d at cycle %d" % [locked_lane["c"], locked_lane["a"], locked_lane["b"], main.cycle])
			return [] if locked_lane.is_empty() else [locked_lane]
		"mining_focus":
			return _mining_plan(ranked)
		"never_expand":
			return ranked.slice(0, mini(1, ranked.size()))
		"local_focus":
			return []  # no lanes: the orders are set in _apply_orders
		"decent":
			return ranked.slice(0, mini(DECENT_LANES, ranked.size()))
		_:  # always_expand
			var cap := maxi(1, int(main.balance.get("ship_cap", 1)))
			return ranked.slice(0, mini(cap, ranked.size()))


func _missing_lanes(plan: Array) -> int:
	var k := 0
	var counts := {}
	for lane in plan:
		var key := _lane_key(lane)
		counts[key] = int(counts.get(key, 0)) + 1
		if main.engine.lane_count(int(lane["a"]), int(lane["b"]), str(lane["c"])) < int(counts[key]):
			k += 1
	return k


## Ship purchases per strategy. Buys happen at the lane source (the ship button sits on the panel).
func _expand(plan: Array, c: int) -> void:
	if strategy == "dead_run" and permit_sid >= 0 and not main.open_systems.has(permit_sid) and main.learned_skills.has("FND_PERMIT") \
			and int(main.cash) < int(main.permit_cost(permit_sid)) + 150:
		return  # R2: dead_run saves cash for the system 2 permit before buying more ships
	var price: int = int(main.balance.get("ship_price", 0))
	var home: int = _lane_home(plan)
	match strategy:
		"always_expand", "bankrupt":
			while _missing_lanes(plan) > main.free_ships() and main.can_buy_ship()["ok"]:
				var before: int = main.ships
				_buy_ship_at(home, c)
				if main.ships == before:
					break
		"decent", "mining_focus", "dead_run", "spread":  # T161: mining_focus and dead_run expand like decent
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
		var planned := {}  # lane key -> ships the plan wants on it (QA 2026-11-03: a lane may carry up to three)
		for pl in keep_lanes:
			planned[_lane_key(pl)] = int(planned.get(_lane_key(pl), 0)) + 1
		var seen := {}
		for rec in main.engine.routes.duplicate(true):
			var a := int(rec["a"])
			var b := int(rec["b"])
			var c := str(rec["c"])
			var rkey := "%d|%d|%s" % [a, b, c]
			seen[rkey] = int(seen.get(rkey, 0)) + 1
			var keep: bool = int(planned.get(rkey, 0)) >= int(seen[rkey]) and not bool(main.storage.is_full(str(rec["dst"]), c))
			if strategy == "dead_run" and b < 0 and (c == "dross" or c == "nullglass") and (a == int(dead_ids.get("dead_1", -9)) or a == int(dead_ids.get("dead_2", -9))):
				keep = not bool(main.storage.is_full(str(rec["dst"]), c))  # R3: the scripted chain routes feed the fabric, the planner does not plan them
			if b < 0 and _workshop_inputs().has(c):
				keep = not bool(main.storage.is_full(str(rec["dst"]), c))  # QA 2026-11-03: workshop feed routes to the station
			if a <= -1000 and c == "ore" and b == _ore_dock() and _workshop_inputs().has("ore"):
				keep = true  # QA 2026-11-03: the cluster leg of the ore feed
			if not keep:
				_remove_route(int(rec["id"]))
	var active: Array = []
	var want_count := {}
	for lane in plan:
		var a2 := int(lane["a"])
		var b2 := int(lane["b"])
		var c2 := str(lane["c"])
		var want_n: int = int(want_count.get(_lane_key(lane), 0)) + 1
		want_count[_lane_key(lane)] = want_n
		if main.engine.lane_count(a2, b2, c2) < want_n:
			if main.free_ships() <= 0 or main.storage.is_full(main.storage.planet_key(b2), c2):
				continue
			if not _build_route(lane):
				continue
		if not _in_plan(a2, b2, c2, active):
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
	var n_before: int = main.engine.lane_count(a, b, c)
	_select(a)
	main.planet_panel.send_requested.emit(c)
	main.map.planet_clicked.emit(b)
	if main.engine.lane_count(a, b, c) <= n_before and not main.pending.is_empty() and main.pending.has("dest"):
		main.map.planet_clicked.emit(b)  # T161: a stop is on the way, so the first click only picked the destination; the second sends direct
	if main.engine.lane_count(a, b, c) > n_before:
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
	if strategy == "local_focus" or local_orders:
		_local_focus_want(want)
	_workshop_want(want)  # QA 2026-11-03: inputs bought and outputs sold at system 1 for built workshops
	for lane in active:
		if _buy_wanted(int(lane["a"]), str(lane["c"])):
			want["%d|%s|buy" % [int(lane["a"]), str(lane["c"])]] = true
		want["%d|%s|sell" % [int(lane["b"]), str(lane["c"])]] = true
	# QA fix 2026-11-03: plate sells at Voltara (planet_1, plate_sell in data/planets.json) so fabric payback is measurable.
	# The Sell draws from the system 1 station; on only while the station holds plate.
	var pl := _plate_seller()
	if pl >= 0 and int(main.storage.amount(main.storage.system_key(int(main.trade.planets[pl].get("system", 1))), "plate")) > 0 \
			and main.engine.planet_open(pl):
		want["%d|plate|sell" % pl] = true

	for o in main.engine.local.values().duplicate(true):
		for role in ["buy", "sell"]:
			var key := "%d|%s|%s" % [int(o["planet"]), str(o["c"]), role]
			if bool(o[role]) and not want.has(key):
				_set_order(int(o["planet"]), str(o["c"]), role, false)
	for key in want.keys():
		var parts: PackedStringArray = str(key).split("|")
		_set_order(int(parts[0]), parts[1], parts[2], true)


## local_focus: Buy and Sell on every open planet that trades a focus good (buy price > 0, sell price >= 0).
func _local_focus_want(want: Dictionary) -> void:
	for c in main.engine.commodities:
		var cs := str(c)
		if market_focus != "" and Markets.market_of(cs) != market_focus:
			continue
		for p in main.trade.planets.size():
			if not main.engine.planet_open(p):
				continue
			if DeadWorlds.is_dead(main.trade.planets[p]) and (main.cycle < main.dead_unlock_cycle() or not main.has_skill(DeadWorlds.skill_for(main.trade.planets[p]))):
				continue  # the game refuses orders at a dead world until it opens and its skill is learned (DeadWorlds.skill_for)
			if int(main.trade.price(p, cs + "_buy")) > 0:
				want["%d|%s|buy" % [p, cs]] = true
			if int(main.trade.price(p, cs + "_sell")) >= 0:
				want["%d|%s|sell" % [p, cs]] = true


## QA: the planet index that sells plate (Voltara, the one with a plate_sell price). Index 0 in data/planets.json.
func _plate_seller() -> int:
	for i in main.trade.planets.size():
		if int(main.trade.price(i, "plate_sell")) >= 0:
			return i
	return -1


## Buy side of a lane. The route moves units_per_cycle a turn, so a Buy order only refills what the route
## can move (stock below one shipment) and only while cash covers the trip and the purchase. Sloppy keeps
## its Buy order on at full size with no reserve, so its stock piles up and it runs dry.
func _buy_wanted(a: int, c: String) -> bool:
	if a <= -1000:  # T161: clusters are free ore, no buy order
		return false
	if strategy == "sloppy":
		return true
	var units: int = mini(int(main.engine.local_amount()), int(main.engine.units_per_cycle()))
	var stock: int = int(main.storage.amount(main.storage.planet_key(a), c))
	# QA fix 2026-11-03: the Buy order is on when cash covers one trip (fixed cost = trip + upkeep of one run).
	# No extra reserve on top: the engine's route_reserve already holds the fixed cost of every running route
	# before a Buy spends, so adding one more fixed cost here double-counted it and blocked the Buy at cash 114
	# (fixed 110), which left routes idle. A Buy order buys only what cash allows after that reserve.
	return stock < units and main.cash >= int(main.engine.fixed_cost())


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


## QA 2026-11-03: workshops. Builds each workshop of the focus (every workshop with no focus) once its node is learned and
## cash covers the build cost plus WORKSHOP_CASH. Built workshops craft from system 1 storage.
func _workshop_turn(c: int) -> void:
	for id in main.workshops.IDS:
		if market_focus != "" and str(main.workshops.market_of(id)) != market_focus:
			continue
		if market_focus == "" and not workshops_built.is_empty():
			continue  # no focus: one workshop only (each one's feed routes take ships)
		var v: Dictionary = main.can_build_workshop(id)
		if not bool(v["ok"]):
			continue
		var open_goods: Array = main.workshops.open_recipes(id)
		var feedable := false
		for g in open_goods:
			feedable = feedable or _feed_ships(str(g), open_goods) <= FEED_SHIPS
		if not feedable:
			continue  # nothing this workshop can make now is feedable with the ships it may take
		# QA 2026-11-03: ships first (they earn more per credit); the workshop is built at ship_cap, or when cash covers it plus two ships.
		var spare: int = WORKSHOP_CASH if int(main.ships) >= int(main.balance.get("ship_cap", 1)) else 2 * int(main.balance.get("ship_price", 0))
		if int(main.cash) < int(main.workshops.build_cost(id)) + spare:
			continue
		var r: Dictionary = main.build_workshop(id)
		if bool(r["ok"]):
			workshops_built.append([c, id])
			_count("workshop_build", c)


## QA 2026-11-03: workshop inputs reach system 1 storage only over a route into the station (send to Space Storage).
## Inputs: every open recipe input of a built workshop. Buy at the source of each feed route; Sell the outputs that no
## other open recipe uses as an input at system 1 planets (a Sell draws from the station too).
## Raw goods (not made by the recipe chain itself) a good needs, found through its in-house intermediates.
func _recipe_raws(g: String, open_goods: Array) -> Array:
	var out: Array = []
	for c in Goods.recipe(g).keys():
		var cs := str(c)
		if open_goods.has(cs):
			for r in _recipe_raws(cs, open_goods):
				if not out.has(r):
					out.append(r)
		elif not out.has(cs):
			out.append(cs)
	return out


## Ships the feed routes of a good need: one per raw input, two for ore (a cluster leg and a planet-to-station leg).
func _feed_ships(g: String, open_goods: Array) -> int:
	var n := 0
	for r in _recipe_raws(g, open_goods):
		n += 2 if str(r) == "ore" else 1
	return n


## The goods the bot makes: per built workshop the highest-tier open recipe whose feed fits FEED_SHIPS ships (the rest of the
## fleet keeps trading), with the in-house intermediates it consumes.
func _workshop_made() -> Array:
	var out: Array = []
	for id in main.workshops.IDS:
		if not bool(main.workshops.built.get(id, false)):
			continue
		var open_goods: Array = main.workshops.open_recipes(id)
		var picked := ""
		for i in range(open_goods.size() - 1, -1, -1):  # highest tier first
			if _feed_ships(str(open_goods[i]), open_goods) <= FEED_SHIPS:
				picked = str(open_goods[i])
				break
		if picked == "":
			continue
		for g in [picked] + _intermediates(picked, open_goods):
			if not out.has(str(g)):
				out.append(str(g))
	return out


func _intermediates(g: String, open_goods: Array) -> Array:
	var out: Array = []
	for c in Goods.recipe(g).keys():
		if open_goods.has(str(c)):
			out.append(str(c))
			out.append_array(_intermediates(str(c), open_goods))
	return out


## Raw inputs bought from planets: recipe inputs of open recipes that no built workshop makes itself (cells feed armour in house).
func _workshop_inputs() -> Array:
	var out: Array = []
	var made := _workshop_made()
	for g in made:
		for c in Goods.recipe(str(g)).keys():
			if not out.has(str(c)) and not made.has(str(c)):
				out.append(str(c))
	return out


## Goods sold: made goods that no open recipe uses as an input (the top of each chain).
func _workshop_outputs() -> Array:
	var out: Array = []
	var made := _workshop_made()
	var used: Array = []
	for g in made:
		used.append_array(Goods.recipe(str(g)).keys())
	for g in made:
		if not used.has(str(g)):
			out.append(str(g))
	return out


func _workshop_want(want: Dictionary) -> void:
	if int(main.cash) < int(main.engine.fixed_cost()):
		return
	for c in _workshop_inputs():
		for rec in main.engine.routes:
			if int(rec["b"]) < 0 and int(rec["a"]) >= 0 and str(rec["c"]) == c and int(main.trade.price(int(rec["a"]), c + "_buy")) > 0:
				want["%d|%s|buy" % [int(rec["a"]), c]] = true
	for g in _workshop_outputs():
		for p in main.trade.planets.size():
			if int(main.trade.planets[p].get("system", 1)) == 1 and main.engine.planet_open(p) and int(main.trade.price(p, g + "_sell")) > 0:
				want["%d|%s|sell" % [p, g]] = true


func _buyable(p: int, c: String) -> bool:
	if not main.engine.planet_open(p) or int(main.trade.price(p, c + "_buy")) <= 0:
		return false
	return not (DeadWorlds.is_dead(main.trade.planets[p]) and (main.cycle < main.dead_unlock_cycle() or not main.has_skill(DeadWorlds.skill_for(main.trade.planets[p]))))


## One feed route per workshop input good, from the first open planet that buys it. Refusals are logged once per reason.
func _workshop_feed(c_turn: int) -> void:
	for c in _workshop_inputs():
		var fed := false
		for rec in main.engine.routes:
			if int(rec["b"]) < 0 and str(rec["c"]) == c:
				fed = true
		if fed or not _feed_worthwhile(c):
			continue
		if c == "ore":
			_feed_ore(c_turn)
			continue
		var cands: Array = []  # source nodes: the planets that buy the good, cheapest first
		for p in main.trade.planets.size():
			if _buyable(p, c):
				cands.append(p)
		cands.sort_custom(func(x, y): return int(main.trade.price(x, c + "_buy")) < int(main.trade.price(y, c + "_buy")))
		for p in cands:
			var ok: Dictionary = main.can_connect(int(p), -1, c)
			if not bool(ok["ok"]) and str(ok["reason"]).begins_with("No ship"):
				if bool(main.can_buy_ship()["ok"]):
					_buy_ship_at(_mission_planet(), c_turn)  # QA 2026-11-03: a ship for the feed when cash allows
					ok = main.can_connect(int(p), -1, c)
				elif int(main.ships) >= int(main.balance.get("ship_cap", 1)) and _free_weakest_lane(c_turn, c):
					ok = main.can_connect(int(p), -1, c)  # at ship_cap a planned lane gives up its ship for the feed
			if bool(ok["ok"]):
				var rc: Dictionary = main._connect(int(p), -1, c)
				feed_log.append([c_turn, p, c, bool(rc.get("ok", false)), "route to station"])
				break
			var why := str(ok["reason"])
			if feed_why.get(c, "") != why:
				feed_why[c] = why
				feed_log.append([c_turn, p, c, false, why])


## QA 2026-11-03: ore for a workshop. No planet sells ore, so a player mines it: cluster -> system 1 planet that buys ore, then
## planet -> Space Storage. Opens the missing leg each turn (a ship is bought when cash allows).
func _feed_ore(c_turn: int) -> void:
	if not main.can_mine():
		return
	var x := _ore_dock()
	if x < 0:
		return
	var has_cluster_leg := false
	for rec in main.engine.routes:
		if int(rec["a"]) <= -1000 and int(rec["b"]) == x:
			has_cluster_leg = true
	if not has_cluster_leg:
		var best_node := 0
		for sid in [1, 2]:
			for cl in main.clusters_in_system(sid):
				if int(cl["left"]) > 0 and best_node == 0 and (sid == 1 or main.open_systems.has(sid)):
					best_node = int(cl["node"])  # cluster nodes are negative ids (Clusters.BASE)
		if best_node == 0:
			return
		if main.free_ships() <= 0 and bool(main.can_buy_ship()["ok"]):
			_buy_ship_at(x, c_turn)
		if main.free_ships() <= 0 and int(main.ships) >= int(main.balance.get("ship_cap", 1)):
			_free_weakest_lane(c_turn, "ore")
		if main.free_ships() > 0:
			var r: Dictionary = main.send_from_cluster(best_node, x)
			feed_log.append([c_turn, best_node, "ore", bool(r.get("ok", false)), "cluster leg to planet %d" % x])
		return
	if main.free_ships() <= 0 and bool(main.can_buy_ship()["ok"]):
		_buy_ship_at(x, c_turn)
	if main.free_ships() <= 0 and int(main.ships) >= int(main.balance.get("ship_cap", 1)):
		_free_weakest_lane(c_turn, "ore")
	var ok: Dictionary = main.can_connect(x, -1, "ore")
	if bool(ok["ok"]):
		var rc: Dictionary = main._connect(x, -1, "ore")
		feed_log.append([c_turn, x, "ore", bool(rc.get("ok", false)), "route to station"])


## A raw input is fed only when some open recipe that uses it has every other raw input sourced (a silk feed is waste with no ore).
func _feed_worthwhile(c: String) -> bool:
	var made := _workshop_made()
	for g in made:
		var rec: Dictionary = Goods.recipe(str(g))
		if not rec.has(c):
			continue
		var all_ok := true
		for r in rec.keys():
			var rs := str(r)
			if made.has(rs) or rs == c:
				continue
			if rs == "ore":
				var ore_in := false
				for r2 in main.engine.routes:
					ore_in = ore_in or (int(r2["b"]) < 0 and str(r2["c"]) == "ore")
				if not (main.can_mine() and _ore_dock() >= 0 and ore_in):  # the ore feed is built first
					all_ok = false
			else:
				var src := false
				for p in main.trade.planets.size():
					src = src or _buyable(p, rs)
				if not src:
					all_ok = false
		if all_ok:
			return true
	return false


## The planet an ore cluster route lands at, else the system 1 planet that buys ore (the dock of the ore feed), -1 when none.
func _ore_dock() -> int:
	for rec in main.engine.routes:  # a cluster route that already lands in system 1 is the dock
		if int(rec["a"]) <= -1000 and int(rec["b"]) >= 0 and str(rec["c"]) == "ore":
			return int(rec["b"])
	for p in main.trade.planets.size():
		if int(main.trade.planets[p].get("system", 1)) == 1 and main.engine.planet_open(p) and int(main.trade.price(p, "ore_sell")) > 0:
			return p
	return -1


## QA 2026-11-03: a feed route with no free ship closes the lowest-net planet route (once a cycle), as the Fabric chain does.
func _free_weakest_lane(c_turn: int, good: String) -> bool:
	var weakest := -1
	var weakest_net := 1 << 30
	for r in main.engine.routes:
		if int(r["b"]) < 0 or int(r["a"]) < 0:
			continue  # feed routes and cluster routes are not closed for a feed
		var net: int = main.route_net(int(r["id"]))
		if net < weakest_net:
			weakest_net = net
			weakest = int(r["id"])
	if weakest < 0:
		return false
	feed_log.append([c_turn, -1, good, true, "closed route %d (net %d) for a feed" % [weakest, weakest_net]])
	_remove_route(weakest)
	return true


## QA 2026-11-03: stores the craft units of the last workshop run (main.workshops.made) into craft_totals.
func _tally_craft() -> void:
	for id in main.workshops.IDS:
		var made: Dictionary = main.workshops.made.get(id, {})
		for g in made.keys():
			var per: Dictionary = craft_totals.get(id, {})
			per[g] = int(per.get(g, 0)) + int(made[g])
			craft_totals[id] = per


## QA 2026-11-03: a learned bot skill (bot_strength_pct: MIL_5, LUX_7, MIN_7, BIO_7) is used whenever it is ready, on the leading bot.
## Every attempt is logged. Activation goes through Skills.activate_bot_skill, the call the skill screen makes.
func _bot_skill_turn(c: int) -> void:
	for id in Skills.bot_skill_ids():
		if not Skills.bot_skill_ready(id):
			continue
		var bot := Markets.leading_bot()
		var r: Dictionary = Skills.activate_bot_skill(id, bot)
		bot_skill_log.append([c, id, bot, int(r.get("until", -1)), bool(r["ok"]), str(r.get("reason", ""))])
		if bool(r["ok"]):
			live_bot_skills[id] = {"bot": bot, "market": str(SkillTree.node(id).get("market", "")), "until": int(r["until"])}
			_count("bot_skill", c)


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
	if not main.learned_skills.has("FND_STORAGE") and not skip_skills.has("FND_STORAGE") and (only_skills.is_empty() or only_skills.has("FND_STORAGE")):
		return false  # Space Storage comes first; the permit points must not be spent before it is learned
	var keep := 0 if strategy == "dead_run" else PERMIT_WORKING_CASH  # R2: dead_run buys the system 2 permit as soon as affordable
	if int(main.cash) < int(main.permit_cost(permit_sid)) + keep:  # QA: keep cash to buy stock after the permit
		return false
	var r: Dictionary = main.buy_permit(permit_sid)
	if r.get("ok", false):
		notes.append("permit %d bought at cycle %d" % [permit_sid, main.cycle])
		_count("permit_buy", main.cycle)
	return bool(r.get("ok", false))


## QA: skill points held back for the --permit system (only once FND_PERMIT is learned, since it unlocks permits).
func _permit_reserve() -> int:
	if permit_sid < 0 or main.open_systems.has(permit_sid) or not main.learned_skills.has("FND_PERMIT"):
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
			if id != "FND_STORAGE" and _permit_reserve() > 0 and main.skill_points - SkillTree.cost(main.balance, id) < _permit_reserve():
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


## T161 mining_focus: the plan is cluster ore lanes first (only with FND_PROSPECT), then the commodity trade ranking.
func _mining_plan(ranked: Array) -> Array:
	var out: Array = []
	if main.can_mine():
		out.append_array(_cluster_lanes())
	if main.cycle == 5:  # T161 diagnostics
		notes.append("c5 mine=%s ore_in=%s cluster_lanes=%d ore_sell_prices=%s fixed=%d units=%d yield=%d" % [main.can_mine(), main.engine.commodities.has("ore"), out.size(), _ore_prices_text(), int(main.engine.fixed_cost()), int(main.engine.units_per_cycle()), int(main.clusters.yield_per_cycle())])
	out.append_array(ranked)
	var cap := maxi(1, int(main.balance.get("ship_cap", 1)))
	return out.slice(0, mini(cap, out.size()))


## T161: one ore lane per live cluster (best open destination, same system). Ore is free at the cluster.
func _cluster_lanes() -> Array:
	var out: Array = []
	if not main.engine.commodities.has("ore") or (market_focus != "" and Markets.market_of("ore") != market_focus):
		return out
	var units: int = mini(int(main.engine.units_per_cycle()), int(main.clusters.yield_per_cycle()))
	var fixed: int = int(main.engine.fixed_cost())
	var n: int = main.trade.planets.size()
	for sid in [1, 2]:
		if sid != 1 and not main.open_systems.has(sid):
			continue  # QA 2026-11-03: clusters of a system without a permit cannot be mined
		for cl in main.clusters_in_system(sid):
			if int(cl["left"]) <= 0:
				continue
			var node: int = int(cl["node"])
			var best := {}
			for b in n:
				if not main.engine.planet_open(b) or not main.system_trade_open(b) or not bool(main.engine.check_connection(node, b, "ore", true).get("ok", false)):
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
var core_log: Array = []  # R3
var plate_log: Array = []  # R3

## R3: lay one dead-chain route to the system 1 station (Space Storage). Frees a ship by closing the weakest route when none is free.
func _chain_route(c: int, pid: String, com: String, tag: String, free_ok: bool) -> void:
	if not dead_ids.has(pid) or dead_last.has(tag) or _has_route_from(int(dead_ids[pid])):
		return
	var src: int = int(dead_ids[pid])
	var ok: Dictionary = main.can_connect(src, -1, com)
	if not bool(ok["ok"]) and free_ok and str(ok["reason"]).begins_with("No ship") and dead_last.get("frees", 0) < 3 and not main.engine.routes.is_empty():
		var weakest := -1
		var weakest_net := 1 << 30
		for r in main.engine.routes:
			if int(r["a"]) == int(dead_ids.get("dead_1", -9)) or int(r["a"]) == int(dead_ids.get("dead_2", -9)):
				continue  # never close a dead-chain route to make room for another
			var net: int = main.route_net(int(r["id"]))
			if net < weakest_net:
				weakest_net = net
				weakest = int(r["id"])
		if weakest < 0:
			return
		dead_last["frees"] = int(dead_last.get("frees", 0)) + 1
		var rr: Dictionary = main.remove_connection(weakest)
		dead_log.append([c, "freed ship: closed route %d (net %d) for %s" % [weakest, weakest_net, pid], com, -1, bool(rr.get("ok", false)), str(rr.get("reason", ""))])
		ok = main.can_connect(src, -1, com)
	if bool(ok["ok"]):
		var rc: Dictionary = main._connect(src, -1, com)
		dead_last[tag] = "1"
		dead_log.append([c, "chain route " + pid + " to station", com, -1, bool(rc.get("ok", false)), "scripted route"])
	elif str(ok["reason"]) != str(dead_dict_get(tag)):
		dead_last[tag + "_why"] = str(ok["reason"])
		dead_log.append([c, "chain refused " + pid, com, -1, false, str(ok["reason"])])

func dead_dict_get(k: String) -> String:
	return str(dead_last.get(k + "_why", ""))

func _has_route_from(pid: int) -> bool:
	for r in main.engine.routes:
		if int(r["a"]) == pid:
			return true
	return false

func _dead_probe(c: int) -> void:
	if dead_ids.size() < 2:
		for i in main.trade.planets.size():
			var pid := str(main.trade.planets[i].get("id", ""))
			if pid == "dead_1" or pid == "dead_2":
				dead_ids[pid] = i
	if c == main.dead_unlock_cycle() - 1 or c == main.dead_unlock_cycle():
		dead_log.append([c, "notice", "", -1, true, "shown: " + str(main.shown_notice) + " | queue: " + str(main.notice_queue) + " | last: " + str(main.last_notice)])  # R3: the DEAD_UNLOCK notice is posted at the unlock cycle
	# R3 scripted player for the dead chain (dead_run only): from the unlock cycle, lay the two chain routes into the
	# system 1 Space Storage (Cinderrest dross, then Greywake nullglass once Long Haul is learned). With ship_cap
	# all standing routes take the ships, so the script closes its weakest route (a normal Remove) to free one, at most 3 times.
	if c >= main.dead_unlock_cycle():
		_chain_route(c, "dead_1", "dross", "chain_dross", true)
		if dead_ids.has("dead_2") and main.has_skill(DeadWorlds.skill_for(main.trade.planets[int(dead_ids["dead_2"])])):
			_chain_route(c, "dead_2", "nullglass", "chain_nullglass", true)
		# the chain source fills from a standing Buy order at the dead world (the mining), as a player sets it
		for pid_c in [["dead_1", "dross"], ["dead_2", "nullglass"]]:
			if dead_ids.has(pid_c[0]) and _has_route_from(int(dead_ids[pid_c[0]])) and not main.engine.local_on(int(dead_ids[pid_c[0]]), pid_c[1], "buy"):
				var ro: Dictionary = main.set_local_order(int(dead_ids[pid_c[0]]), pid_c[1], "buy", true)
				dead_log.append([c, "buy order " + pid_c[0], pid_c[1], -1, bool(ro.get("ok", false)), str(ro.get("reason", ""))])
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
	for sk in ["MIN_1", "MIN_3", "MIN_5"]:
		if not main.learned_skills.has(sk):
			var lv: Dictionary = SkillTree.can_learn(main.learned_skills, main.skill_points, main.balance, sk)
			var lk := "skill|%s|%s" % [sk, str(lv.get("reason", "")) + str(lv.get("why", ""))]
			if dead_last.get(sk, "") != lk:
				dead_last[sk] = lk
				dead_log.append([c, "skill " + sk, "", -1, bool(lv["ok"]), str(lv.get("reason", "")) + " " + str(lv.get("why", ""))])
	# R2: once the fabric is built, try the nullglass route from Greywake to the system 1 station once (accepted or refused, with reason)
	# R3: retry the Greywake nullglass route to the station every cycle until one is accepted; log each new refusal reason.
	if dead_ids.has("dead_2") and not dead_last.has("attempt_ok") and not _has_route_from(int(dead_ids["dead_2"])):
		var gsrc: int = int(dead_ids["dead_2"])
		var ra: Dictionary = main.can_connect(gsrc, -1, "nullglass")
		if bool(ra["ok"]):
			var sr: Dictionary = main.send_stock_buying(gsrc, -1, "nullglass")
			dead_last["attempt_ok"] = "1"
			dead_log.append([c, "attempt station", "nullglass", -1, bool(sr.get("ok", false)), "send: " + str(sr.get("reason", ""))])
		elif "attempt:" + str(ra["reason"]) != str(dead_last.get("attempt", "")):
			dead_last["attempt"] = "attempt:" + str(ra["reason"])
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
	# R3: plate and dead-chain stock per cycle: [cycle, plate, nullglass, dross] at the system 1 trading post
	var skey: String = main.storage.system_key(1)
	var chain_state := ""
	for r in main.engine.routes:
		if int(r["b"]) < 0:
			chain_state += "%s/%s/%s/src%d;" % [str(r["c"]), str(r["state"]), str(r["reason"]), main.storage.amount("planet:%d" % int(r["a"]), str(r["c"]))]
	plate_log.append([c, main.storage.amount(skey, "plate"), main.storage.amount(skey, "nullglass"), main.storage.amount(skey, "dross"), chain_state])
	# R3: Null Core: build once from the trading post stock (plate and nullglass), then fit it to the first route out of a dead world
	var cv: Dictionary = main.can_build_core()
	if bool(cv["ok"]):
		var r3: Dictionary = main.build_null_core()
		core_log.append([c, "built", bool(r3.get("ok", false))])
	elif str(cv["reason"]) != str(dead_last.get("core", "")):
		dead_last["core"] = str(cv["reason"])
		core_log.append([c, "refused", str(cv["reason"])])
	if main.fabric.core_made > 0 and main.core_route_id() < 0 and not dead_last.has("fit"):
		var fid := -1
		for r in main.engine.routes:
			var a: int = int(r["a"])
			if a >= 0 and a < main.trade.planets.size() and DeadWorlds.is_dead(main.trade.planets[a]) and fid < 0:
				fid = int(r["id"])
		if fid >= 0:
			dead_last["fit"] = "1"
			var rf: Dictionary = main.fit_core(fid)
			core_log.append([c, "fit route %d" % fid, bool(rf.get("ok", false)), str(rf.get("reason", ""))])

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
	share_rows.append([cycle, _shares_now(), main.cash])
	for id in live_bot_skills.keys():  # QA 2026-11-03: the bot's strength in the skill's market for the next cycle
		var d: Dictionary = live_bot_skills[id]
		var m: Dictionary = Markets.bot_mods(int(d["bot"]), str(d["market"]), cycle + 1)
		bot_skill_rows.append([cycle + 1, id, int(d["bot"]), snappedf(float(m["strength_mult"]), 0.0001)])
		if cycle + 1 > int(d["until"]) + 1:
			live_bot_skills.erase(id)
	expect_over = cycle >= win_cycle or not Markets.verdict(cycle).is_empty()  # win, swept or the last cycle
	if expect_over and first_over_cycle < 0:
		first_over_cycle = cycle
	if probe != "":
		probe_rows.append(_probe_row(cycle))


func _shares_by_market() -> Dictionary:
	var out := {}
	for m in Markets.ids:
		out[str(m)] = snappedf(Markets.share(m), 0.001)
	return out


func _game_picks() -> Dictionary:
	var out := {}
	for id in Chains.picks.keys():
		out[str(id)] = str(Chains.picks[id]["opt"])
	return out


func _dir_flags() -> Dictionary:
	var out := {}
	for m in Markets.ids:
		out[str(m)] = Chains.ending_flag(str(m))
	return out


## Effective rival strength at the end: balance strength x event strength_mult, per bot and market.
func _rival_strengths() -> Dictionary:
	var out := {}
	for b in [1, 2, 3]:
		var row := {}
		for m in Markets.ids:
			var base := float(main.balance.get("bot_%d_%s_strength" % [b, m], 0.0))
			var md: Dictionary = Markets.bot_mods(b, str(m), main.cycle)
			row[str(m)] = snappedf(base * float(md["strength_mult"]), 0.1)
		out["bot_%d" % b] = row
	return out


## Player share of every market now (order = Markets.ids), rounded to 0.1%.
func _shares_now() -> Array:
	var out: Array = []
	for m in Markets.ids:
		out.append(snappedf(Markets.share(m), 0.001))
	return out


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
	_tally_craft()  # the final cycle's workshop run
	if dead_from >= 0:
		_issue("softlock", dead_from, "idle from cycle %d: %d cycles with no cash or stock change until the end (cash %d, ships %d, routes %d, Buy/Sell orders on %d, closed planets %d)" % [
			dead_from, IDLE_AFTER, main.cash, main.ships, main.engine.routes.size(), _orders_on(), main.engine.closed_planets.size()])
	var end_cycle: int = main.cycle
	var final_cash: int = main.cash
	var outcome := "softlock"
	if main.game_over and run_end_count == 1:
		outcome = run_side.to_lower()  # win, loss or soft
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
		"core_log": core_log,
		"plate_log": plate_log,
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
		"market_focus": market_focus,
		"market_ids": Markets.ids,
		"share_rows": share_rows,
		"final_shares": _shares_now(),
		"final_shares_by_market": _shares_by_market(),
		"chains_policy": chain_policy,
		"bankrupt_drained": drained,
		"repossessions": main.repossessions,
		"rescues_paid": main.rescues_paid,
		"chain_picks": chain_picks,
		"chain_picks_game": _game_picks(),
		"dir_flags": _dir_flags(),
		"dir_values": Chains.dirv.duplicate(),
		"rival_strengths": _rival_strengths(),
		"skills_learned_count": skills_learned.size(),
		"tech_done_count": SkillTree.all_ids().filter(func(t): return SkillTree.is_tech(str(t)) and main.learned_skills.has(t)).size(),
		"final_best": Markets.best(),
		"win_streaks": Markets.win_streak,
		"close_at": close_at,
		"close_planet": close_planet,
		"closure": _closure_summary() if close_planet >= 0 else {},
		"workshops_built": workshops_built,
		"workshop_state": main.workshops.state,
		"workshop_reason": main.workshops.reason,
		"craft_totals": craft_totals,
		"tech_done": SkillTree.all_ids().filter(func(t): return SkillTree.is_tech(str(t)) and main.learned_skills.has(t)),
		"skills_owned": main.learned_skills,
		"bot_skill_log": bot_skill_log,
		"bot_skill_rows": bot_skill_rows,
		"feed_log": feed_log,
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
