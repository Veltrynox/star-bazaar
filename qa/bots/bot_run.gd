extends SceneTree
## QA bot harness (owned by qa-analyst). Not gameplay code: nothing under game/ or data/ is changed.
## Plays one full game of game/main.tscn headless.
##
## Each cycle the bot pauses, acts at the docked planet through the same functions the UI calls
## (_on_trade, _on_send, _buy_ship), then ends the cycle:
##   --clock=fast (default): main.debug_advance_cycle() runs the normal end-of-cycle path at once.
##   --clock=timer:          main._process() is called in random 1 to 45 s chunks until the cycle
##                           ends (smoke test of the real cycle timer; slow, use for a few runs).
##
## Independent win/loss check: on every cycle_ended signal the bot records the cash and cycle the
## game is about to judge, and expects game_over to be set exactly when
## cash >= win_cash or cycle >= win_cycle. Any mismatch is reported as an issue.
##
## Run (from repo root):
##   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . -s res://qa/bots/bot_run.gd -- --strategy=decent --seed=1
## Strategies: decent | sloppy | always_expand | never_expand
## Optional: --clock=fast|timer   --inject=<cycle>:<credits>
##   --inject adds credits at the start of that cycle. QA input to test the win and end checks only;
##   it is not a player action and not a balance change.
## Prints one line "RESULT {json}" and exits.
##
## Note: the game has no RNG and no events or permits in this build, so --seed does not change any
## outcome. It is recorded so that repeated seeds can prove determinism.

const MAIN_SCENE := "res://game/main.tscn"
const SaveGame := preload("res://game/save_game.gd")
const COMMODITIES := ["energy", "food"]
const PLANET_COUNT := 3
const MAX_STEPS := 1000  # watchdog: bot cycles before a run is called a softlock
const MAX_CHUNKS := 100000  # watchdog: timer steps inside one cycle

var strategy := "decent"
var seed_value := 1
var clock := "fast"
var inject_cycle := -1
var inject_cash := 0
var rng := RandomNumberGenerator.new()
var main: Node = null
var phase := 0
var steps := 0
var hung := false
var win_cash := 0
var win_cycle := 0
var first_win_cycle := -1
var ended_count := 0
var last_ended := -1
var expect_over := false
var stuck_from := -1
var stuck_cycles := 0
var ship_buys: Array = []  # [cycle, planet, ships_after]
var legs_sent := 0
var notes: Array = []
var issues: Array = []  # [kind, cycle, detail]
var cycle_rows: Array = []  # [cycle, cash, ships, docked_planet, in_flight]


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--strategy="):
			strategy = arg.trim_prefix("--strategy=")
		elif arg.begins_with("--seed="):
			seed_value = int(arg.trim_prefix("--seed="))
		elif arg.begins_with("--clock="):
			clock = arg.trim_prefix("--clock=")
		elif arg.begins_with("--inject="):
			var parts := arg.trim_prefix("--inject=").split(":")
			inject_cycle = int(parts[0])
			inject_cash = int(parts[1])
	rng.seed = seed_value
	SaveGame.continue_requested = false
	SaveGame.clear()  # every run starts from a new game, never from an old autosave


func _process(_delta: float) -> bool:
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
		win_cash = int(main.balance.get("win_cash", 0))
		win_cycle = int(main.balance.get("win_cycle", 0))
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
	_decide(c)
	_check_stuck(c)
	cycle_rows.append([c, main.cash, main.ships, main.trade.ship_planet if main.ships > 0 else -1, main.trade.in_flight()])
	var ended_before := ended_count
	if clock == "timer":
		_advance_timer()
	else:
		main.debug_advance_cycle()
	_check_cycle_result(c, ended_before)
	main.set_paused(true)


## Fast clock: one call runs the normal end-of-cycle path exactly once.
## Timer clock: real _process chunks until the cycle counter moves or the game ends.
func _advance_timer() -> void:
	main.set_paused(false)
	var start: int = main.cycle
	var chunks := 0
	while main.cycle == start and not main.game_over and chunks < MAX_CHUNKS:
		chunks += 1
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
		_issue("win_loss_check", c, "game_over=%s but expected %s (cash %d, win_cash %d, cycle %d, win_cycle %d)" % [
			main.game_over, expect_over, main.cash, win_cash, last_ended, win_cycle])
		hung = true
		return
	if not main.game_over and main.cycle != last_ended + 1:
		_issue("cycle_count", c, "cycle counter %d after ending cycle %d, expected %d" % [main.cycle, last_ended, last_ended + 1])
		hung = true


## Player-style decisions while paused. Only the docked planet is ever acted on.
func _decide(c: int) -> void:
	if main.ships == 0:
		_buy_ship_at(0, c)  # tutorial: the first ship is bought at Voltara (mission planet)
	if main.trade.in_flight():
		return  # a ship in flight cannot be traded or sent again
	var p: int = main.trade.ship_planet
	if p < 0:
		return
	if strategy == "sloppy":
		_sloppy_trade(p, c)
	else:
		_greedy_trade(p, c)


func _maybe_buy_ship(c: int, p: int) -> void:
	var price := int(main.balance.get("ship_price", 0))
	var cap := int(main.balance.get("ship_cap", 0))
	if main.ships >= cap or main.cash < price:
		return
	match strategy:
		"decent":
			# expands on time: from cycle 4 on, buys only if 1000 cr stay in cash afterwards
			if c >= 4 and main.cash - price >= 1000:
				_buy_ship_at(p, c)
		"always_expand", "sloppy":
			_buy_ship_at(p, c)  # no reserve at all
		"never_expand":
			pass


func _buy_ship_at(p: int, c: int) -> void:
	var before: int = main.ships
	main.selected_planet = p
	main._buy_ship()
	if main.ships > before:
		ship_buys.append([c, p, main.ships])


## Decent, always_expand and never_expand: sell all sellable cargo, maybe buy a ship, then buy the
## most profitable commodity for any destination and send the ship there. Keeps trip cost in cash.
func _greedy_trade(p: int, c: int) -> void:
	var t = main.trade
	main.selected_planet = p
	_sell_here(p)
	_maybe_buy_ship(c, p)
	if t.used() > 0:
		# cargo this planet does not buy: carry it to the best buyer
		for k in COMMODITIES:
			if t.held(k) > 0:
				var q := _best_buyer(k, p)
				if q >= 0:
					_send(q)
				return
		return
	var best_c := ""
	var best_q := -1
	var best_profit := 0
	var best_buy := 1
	for k in COMMODITIES:
		var bp: int = t.price(p, k + "_buy")
		if bp <= 0:
			continue
		for q in PLANET_COUNT:
			if q == p:
				continue
			var sp: int = t.price(q, k + "_sell")
			if sp < 0:
				continue
			var profit: int = (sp - bp) * t.capacity() - t.trip_cost()
			if profit > best_profit:
				best_profit = profit
				best_c = k
				best_q = q
				best_buy = bp
	if best_q < 0:
		return  # nothing profitable from here
	var budget: int = main.cash - t.trip_cost()
	var n: int = mini(t.capacity(), budget / best_buy)
	for i in n:
		main._on_trade(best_c, "buy1")
	if t.held(best_c) > 0:
		_send(best_q)


## Sloppy: one fixed route Voltara <-> Tillam, buys the maximum with all cash, no trip reserve.
func _sloppy_trade(p: int, c: int) -> void:
	var t = main.trade
	main.selected_planet = p
	_sell_here(p)
	_maybe_buy_ship(c, p)  # sloppy spends down to zero
	var k := "energy" if p == 0 else "food"
	var q := 1 if p == 0 else 0
	if t.used() == 0 and t.price(p, k + "_buy") > 0:
		main._on_trade(k, "buymax")
	if t.used() > 0 and main.cash >= t.trip_cost():
		_send(q)


func _sell_here(p: int) -> void:
	main.selected_planet = p
	for k in COMMODITIES:
		if main.trade.held(k) > 0 and main.trade.price(p, k + "_sell") >= 0:
			main._on_trade(k, "sellall")


func _best_buyer(k: String, from: int) -> int:
	var best := -1
	var best_price := -1
	for q in PLANET_COUNT:
		if q == from:
			continue
		var sp: int = main.trade.price(q, k + "_sell")
		if sp > best_price:
			best_price = sp
			best = q
	return best


func _send(q: int) -> void:
	main.selected_planet = q
	main._on_send()
	if main.trade.in_flight():
		legs_sent += 1


## A stuck run: ship docked, no cash for the trip, and nothing held that this planet buys.
func _check_stuck(c: int) -> void:
	var t = main.trade
	if main.ships == 0 or t.in_flight():
		return
	var p: int = t.ship_planet
	if main.cash >= t.trip_cost():
		return
	for k in COMMODITIES:
		if t.held(k) > 0 and t.price(p, k + "_sell") >= 0:
			return
	if stuck_from < 0:
		stuck_from = c
	stuck_cycles += 1


## Records what the game is about to judge at the end of a cycle (signal fires before the check).
func _on_cycle_ended(cycle: int) -> void:
	ended_count += 1
	last_ended = cycle
	expect_over = main.cash >= win_cash or cycle >= win_cycle
	if first_win_cycle < 0 and main.cash >= win_cash:
		first_win_cycle = cycle


func _issue(kind: String, cycle: int, detail: String) -> void:
	issues.append([kind, cycle, detail])


func _finish() -> bool:
	var end_cycle: int = main.cycle
	var final_cash: int = main.cash
	var outcome := "softlock"
	if main.game_over:
		outcome = "win" if final_cash >= win_cash else "loss"
	var expected_end: int = first_win_cycle if first_win_cycle >= 0 else win_cycle
	if outcome == "win":
		expected_end = first_win_cycle
	if stuck_from >= 0 and outcome == "loss":
		notes.append("stuck from cycle %d: no cash for trip, nothing sellable; no income possible" % stuck_from)
	var pace := {}
	for r in cycle_rows:
		if r[0] in [10, 20, 25]:
			pace[str(r[0])] = r[1]
	var result := {
		"strategy": strategy,
		"seed": seed_value,
		"clock": clock,
		"inject": "%d:%d" % [inject_cycle, inject_cash] if inject_cycle >= 0 else "",
		"final_cash": final_cash,
		"cycle_reached": end_cycle,
		"outcome": outcome,
		"first_win_cycle": first_win_cycle,
		"expected_end_cycle": expected_end,
		"end_cycle_ok": end_cycle == expected_end,
		"cycles_ended": ended_count,
		"ships_owned": main.ships,
		"ship_buys": ship_buys,
		"permits_bought": 0,  # no permit code exists in this build (T11 queued)
		"legs_sent": legs_sent,
		"stuck_from_cycle": stuck_from,
		"stuck_cycles": stuck_cycles,
		"cash_at": pace,
		"cash_by_cycle": cycle_rows.map(func(r): return [r[0], r[1]]),
		"issues": issues,
		"notes": notes,
	}
	print("RESULT " + JSON.stringify(result))
	quit(0)
	return true
