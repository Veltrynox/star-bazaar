extends SceneTree
## Headless tests (T79). Run: sh tools/tests/run.sh   (see that file; it sets a scratch HOME).
## Covers: story text, ending picker, win/loss paths, run recording, expansion points, skill keys, force-goal.
## Tests only read behaviour; they change no game code.

const StoryText := preload("res://game/story_text.gd")
const EndingPicker := preload("res://game/ending_picker.gd")
const Storage := preload("res://game/storage.gd")
const MAIN_SCENE := "res://game/main.tscn"

var passed := 0
var failed := 0

func check(ok: bool, name: String, detail: String = "") -> void:
	if ok:
		passed += 1
		print("PASS ", name)
	else:
		failed += 1
		print("FAIL ", name, "  ", detail)

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_test_story_text()
	_test_picker()
	_test_stats_file()
	await _test_main()
	await _test_rescue_waiting()
	await _test_events()
	await _test_ships()
	await _test_notice_queue()
	await _test_systems()
	await _test_shield()
	await _test_asteroid()
	await _test_full_endings()
	await _test_idle_actions()
	await _test_skill_effects()
	await _test_every_ending()
	await _test_debug_menu()
	print("TOTAL pass=%d fail=%d" % [passed, failed])
	quit(1 if failed > 0 else 0)

func _read_json(path: String):
	return JSON.parse_string(FileAccess.get_file_as_string(path))

func _wipe_user() -> void:
	for f in ["stats.json", "stats.json.tmp", "stats.bad.json", "autosave.json"]:
		if FileAccess.file_exists("user://" + f):
			DirAccess.remove_absolute("user://" + f)

# ---- 1. story text ----
func _test_story_text() -> void:
	var list = _read_json("res://data/story_text.json")
	check(typeof(list) == TYPE_ARRAY and list.size() > 0, "story: data loads")
	var seen := {}
	var dup := 0
	var too_long := []
	var open_ph := []
	for e in list:
		var id := str(e["id"])
		if seen.has(id):
			dup += 1
		seen[id] = true
		if e.has("max") and str(e["text"]).length() > int(e["max"]):
			too_long.append(id)
		# fill every {placeholder} and make sure none remain
		var args := {}
		var rx := RegEx.create_from_string("\\{(\\w+)\\}")
		for m in rx.search_all(str(e["text"])):
			args[m.get_string(1)] = "7"
		var out := StoryText.get_text(id, args)
		if out.contains("{") or out.contains("}"):
			open_ph.append(id)
		if out == id and str(e["text"]) != id:
			open_ph.append(id)
	check(dup == 0, "story: no duplicate ids")
	check(too_long.is_empty(), "story: all texts within max", str(too_long))
	check(open_ph.is_empty(), "story: placeholders fill", str(open_ph))
	# ids the game asks for: literal ids in game/*.gd plus the built ones
	var wanted := {}
	var rx2 := RegEx.create_from_string("(?:get_text|has_text)\\(\"([A-Z][A-Z0-9_]+)\"")
	var d := DirAccess.open("res://game")
	for fn in d.get_files():
		if fn.ends_with(".gd"):
			for m in rx2.search_all(FileAccess.get_file_as_string("res://game/" + fn)):
				if not m.get_string(1).ends_with("_"):  # prefixes (END_TITLE_ + side) are added below
					wanted[m.get_string(1)] = true
	for k in ["REL", "CORP"]:
		for p in ["END_TITLE_", "END_SIGN_"]:
			wanted[p + k] = true
	for id in ["CHOICE_RELEASE", "CHOICE_CORP", "CHOICE_RELEASE_EFFECT", "CHOICE_CORP_EFFECT",
			"END_STAT_CYCLES", "END_STAT_CASH", "END_STAT_BRANCHES", "END_STAT_SYSTEMS",
			"END_BTN_NEW", "END_BTN_MENU", "END_BTN_QUIT", "END_LOSS"]:
		wanted[id] = true
	for ending in _all_endings():
		wanted[ending] = true
	var missing := []
	for id in wanted:
		if not seen.has(id):
			missing.append(id)
	check(missing.is_empty(), "story: every id the game asks for exists (%d ids)" % wanted.size(), str(missing))
	check(StoryText.get_text("LBL_GOAL", {"goal": 9000}).contains("9000"), "story: LBL_GOAL fills goal")
	check(StoryText.ending_name("END_ENOUGH") != "END_ENOUGH", "story: ending_name reads place field")
	var events = _read_json("res://data/events.json")
	check(typeof(events) == TYPE_ARRAY and events.size() > 0, "story: events.json loads")

func _all_endings() -> Array:
	var out := ["END_BARE_HANDS", "END_LAST_LIGHT", "END_COLD_LEDGER", "END_OWN_HORIZON", "END_SLOW_HARBOR", "END_ENOUGH",
		"END_CORP_BARE", "END_CORP_LOGI", "END_CORP_RES", "END_CORP_EXP", "END_CORP_MIX"]
	for s in ["L", "R", "E", "X"]:
		out.append("END_REL_FULL_" + s)
		out.append("END_CORP_FULL_" + s)
	return out

# ---- 2. ending picker ----
func _full(b: String) -> Array:
	var out := []
	for i in EndingPicker.branch_size(b):
		out.append("%s%d" % [b, i + 1])
	return out

func _inp(learned: Array, sys: int = 2, all_sys: bool = false, last: bool = false) -> Dictionary:
	return {"learned": learned, "systems_reached": sys, "all_systems_reached": all_sys, "last_cycle": last}

func _test_picker() -> void:
	check(EndingPicker.branch_size("A") > 0 and EndingPicker.branch_size("B") > 0 and EndingPicker.branch_size("C") > 0, "picker: branch sizes read from story ids")
	var P := EndingPicker
	# Release tiers
	check(P.pick_release(_inp(["A1"], 1)) == "END_BARE_HANDS", "release: bare hands (A1 only, 1 system)")
	check(P.pick_release(_inp([], 1)) == "END_BARE_HANDS", "release: bare hands (nothing learned)")
	check(P.pick_release(_inp(_full("A"), 3, true)) == "END_REL_FULL_L", "release: full L")
	check(P.pick_release(_inp(_full("B"), 3, true)) == "END_REL_FULL_R", "release: full R")
	check(P.pick_release(_inp(_full("C"), 3, true)) == "END_REL_FULL_E", "release: full E")
	check(P.pick_release(_inp(_full("A") + _full("B"), 3, true)) == "END_REL_FULL_X", "release: full X (two branches)")
	check(P.pick_release(_inp(["A1", "A2"], 2, false, true)) == "END_LAST_LIGHT", "release: last light")
	check(P.pick_release(_inp(["B1", "B2", "B3", "B4"])) == "END_COLD_LEDGER", "release: cold ledger (B dominant with B4)")
	check(P.pick_release(_inp(["B1", "B2"])) == "END_ENOUGH", "release: B dominant without B4 falls to enough")
	check(P.pick_release(_inp(["C1", "C2"])) == "END_OWN_HORIZON", "release: own horizon")
	check(P.pick_release(_inp(["A1", "A2"])) == "END_SLOW_HARBOR", "release: slow harbor")
	check(P.pick_release(_inp(["A2", "B1"])) == "END_ENOUGH", "release: default when tied")
	# first match wins
	check(P.pick_release(_inp(_full("A"), 3, true, true)) == "END_REL_FULL_L", "release: full beats last light")
	check(P.pick_release(_inp(["A1"], 1, false, true)) == "END_BARE_HANDS", "release: bare beats last light")
	check(P.pick_release(_inp(["B1", "B4"], 2, false, true)) == "END_LAST_LIGHT", "release: last light beats cold ledger")
	# Corp
	check(P.pick_corp(_inp(["A1"], 1)) == "END_CORP_BARE", "corp: bare")
	check(P.pick_corp(_inp(_full("A"), 3, true)) == "END_CORP_FULL_L", "corp: full L")
	check(P.pick_corp(_inp(_full("B"), 3, true)) == "END_CORP_FULL_R", "corp: full R")
	check(P.pick_corp(_inp(_full("C"), 3, true)) == "END_CORP_FULL_E", "corp: full E")
	check(P.pick_corp(_inp(_full("B") + _full("C"), 3, true)) == "END_CORP_FULL_X", "corp: full X")
	check(P.pick_corp(_inp(["A2", "A3"])) == "END_CORP_LOGI", "corp: logistics")
	check(P.pick_corp(_inp(["B2", "B3"])) == "END_CORP_RES", "corp: research")
	check(P.pick_corp(_inp(["C2", "C3"])) == "END_CORP_EXP", "corp: expansion")
	check(P.pick_corp(_inp(["A2", "B2"])) == "END_CORP_MIX", "corp: mix default")
	check(P.pick_corp(_inp(_full("A"), 3, false)) == "END_CORP_LOGI", "corp: full branch but not all systems -> not full")
	# every ending id the picker can return exists in story text
	var all_ok := true
	for e in _all_endings():
		if not StoryText.has_text(e):
			all_ok = false
	check(all_ok, "picker: every ending id has story text")

# ---- 3. stats file ----
func _test_stats_file() -> void:
	_wipe_user()
	var s: Dictionary = RunStats.load_stats()
	check(int(s["runs"]) == 0, "stats: missing file gives fresh record")
	check(RunStats.record("RELEASE", "END_ENOUGH", 12, 9100), "stats: record returns ok")
	var d = _read_json("user://stats.json")
	check(typeof(d) == TYPE_DICTIONARY and int(d["runs"]) == 1 and int(d["choices"]["RELEASE"]) == 1 and int(d["endings"]["END_ENOUGH"]) == 1, "stats: one record, counts 1", str(d))
	check(not FileAccess.file_exists("user://stats.json.tmp"), "stats: atomic write leaves no .tmp")
	RunStats.record("CORP", "END_CORP_MIX", 13, 9200)
	RunStats.record("RELEASE", "END_ENOUGH", 14, 9300)
	d = _read_json("user://stats.json")
	check(int(d["runs"]) == 3 and int(d["choices"]["RELEASE"]) == 2 and int(d["choices"]["CORP"]) == 1 and int(d["endings"]["END_ENOUGH"]) == 2, "stats: counts accumulate", str(d))
	check(RunStats.load_stats()["runs"] == 3, "stats: reload keeps counts")
	RunStats.record("RELEASE", "END_BARE_HANDS", 5, 5, "Bare")
	RunStats.record("RELEASE", "END_ENOUGH", 5, 5, "Bare")
	d = _read_json("user://stats.json")
	check(int(d["tiers"]["Bare"]) == 2 and d["last"]["tier"] == "Bare", "stats: tier count and last tier", str(d))
	_wipe_user()
	RunStats.record("RELEASE", "END_ENOUGH", 12, 9100)
	RunStats.record("CORP", "END_CORP_MIX", 13, 9200)
	RunStats.record("RELEASE", "END_ENOUGH", 14, 9300)
	# stale tmp must not matter
	var t := FileAccess.open("user://stats.json.tmp", FileAccess.WRITE)
	t.store_string("junk")
	t.close()
	RunStats.record("CORP", "END_CORP_MIX", 15, 9400)
	check(int(_read_json("user://stats.json")["runs"]) == 4, "stats: stale .tmp is overwritten")
	# corrupt file
	var f := FileAccess.open("user://stats.json", FileAccess.WRITE)
	f.store_string("{not json")
	f.close()
	s = RunStats.load_stats()
	check(int(s["runs"]) == 0, "stats: corrupt file reads as fresh")
	check(FileAccess.file_exists("user://stats.bad.json") and not FileAccess.file_exists("user://stats.json"), "stats: corrupt file moved to stats.bad.json")
	RunStats.record("RELEASE", "END_ENOUGH", 1, 1)
	check(int(_read_json("user://stats.json")["runs"]) == 1, "stats: recreated after corrupt")
	# valid JSON, wrong shape
	f = FileAccess.open("user://stats.json", FileAccess.WRITE)
	f.store_string("[1,2]")
	f.close()
	check(int(RunStats.load_stats()["runs"]) == 0, "stats: wrong-shape JSON reads as fresh")

# ---- 4. main scene ----
func _new_main() -> Control:
	var m: Control = load(MAIN_SCENE).instantiate()
	root.add_child(m)
	await process_frame
	return m

func _free_main(m: Control) -> void:
	m.queue_free()
	await process_frame

func _stats_runs() -> int:
	if not FileAccess.file_exists("user://stats.json"):
		return 0
	return int(_read_json("user://stats.json")["runs"])

func _buttons(n: Node, out: Array) -> Array:
	if n is Button:
		out.append(n)
	for c in n.get_children():
		_buttons(c, out)
	return out

func _test_main() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	var win_cash := int(bal["win_cash"])
	var win_cycle := int(bal["win_cycle"])

	# --- choice screen ---
	m.cash = win_cash
	m._end_cycle()
	await process_frame
	check(m.game_over and m.choice_pending, "win: goal at cycle end opens the choice and stops the game")
	check(m.end_screen != null, "win: end screen shown")
	var btns := _buttons(m.end_screen, [])
	var texts := []
	for b in btns:
		texts.append(b.text)
	check(btns.size() == 2 and texts.has(StoryText.get_text("CHOICE_RELEASE")) and texts.has(StoryText.get_text("CHOICE_CORP")), "win: choice screen has exactly Release and Corporation", str(texts))
	check(_stats_runs() == 0, "win: nothing recorded while choice is open")
	check(FileAccess.file_exists("user://autosave.json"), "win: unanswered choice is saved")
	var cyc: int = m.cycle
	var ended := []
	m.run_ended.connect(func(side, id): ended.append([side, id]))
	btns[0].pressed.emit()
	await process_frame
	check(ended.size() == 1 and ended[0][0] == "RELEASE" and ended[0][1] == "END_BARE_HANDS", "win: Release answered gives ending", str(ended))
	check(_stats_runs() == 1, "win: answered choice adds exactly one run")
	check(m.cycle == cyc, "win: cycle unchanged after answer")
	check(not FileAccess.file_exists("user://autosave.json"), "win: save cleared after answer")
	m._on_choice("RELEASE")
	m._finish("RELEASE", "END_ENOUGH", "")
	await process_frame
	check(_stats_runs() == 1, "win: repeated finish in the same run does not double count")
	var d = _read_json("user://stats.json")
	check(int(d["choices"].get("RELEASE", 0)) == 1, "win: choice side counted once", str(d))
	await _free_main(m)

	# corp path with skills
	m = await _new_main()
	m._dismiss_preface()
	m.learned_skills = ["C1", "C2"]
	m.cash = win_cash
	m._end_cycle()
	await process_frame
	var ended2 := []
	m.run_ended.connect(func(side, id): ended2.append([side, id]))
	m.end_screen.chosen.emit("CORP")
	await process_frame
	check(ended2.size() == 1 and ended2[0][1] == "END_CORP_EXP", "win: Corporation answered gives corp ending", str(ended2))
	check(_stats_runs() == 2, "win: second run recorded, total 2")
	await _free_main(m)

	# reload of an unanswered choice does not record
	m = await _new_main()
	m._dismiss_preface()
	m.cash = win_cash
	m._end_cycle()
	await process_frame
	var before := _stats_runs()
	await _free_main(m)
	root.get_node_or_null("x")
	m = load(MAIN_SCENE).instantiate()
	m.set_meta("x", 1)
	preload("res://game/save_game.gd").continue_requested = true
	root.add_child(m)
	await process_frame
	check(m.choice_pending and m.end_screen != null, "win: unanswered choice returns after reload")
	check(_stats_runs() == before, "win: reload does not record")
	await _free_main(m)

	# --- loss path ---
	_wipe_user()
	m = await _new_main()
	m._dismiss_preface()
	m.cash = 100
	m.cycle = win_cycle
	var ended3 := []
	m.run_ended.connect(func(side, id): ended3.append([side, id]))
	m._end_cycle()
	await process_frame
	check(m.game_over and not m.choice_pending, "loss: window end without goal ends the run, no choice")
	check(ended3.size() == 1 and ended3[0][0] == "LOSS" and ended3[0][1] == "END_LOSS", "loss: END_LOSS reached", str(ended3))
	var ld = _read_json("user://stats.json")
	check(_stats_runs() == 1 and int(ld["choices"].get("LOSS", 0)) == 1 and int(ld["endings"].get("END_LOSS", 0)) == 1 and str(ld["last"]["side"]) == "LOSS", "loss: recorded as choices.LOSS / endings.END_LOSS (owner decision)", str(ld))
	await _free_main(m)

	# --- not the end yet: cycle advances ---
	m = await _new_main()
	m._dismiss_preface()
	m.cash = 100
	m.cycle = 3
	m._end_cycle()
	check(not m.game_over and m.cycle == 4, "cycle: below goal and before window end just advances")
	await _free_main(m)

	# --- force goal ---
	_wipe_user()
	m = await _new_main()
	m._dismiss_preface()
	check(m.debug_force_goal == false, "force-goal: off by default")
	check(not m.collect_state().has("debug_force_goal"), "force-goal: not saved")
	m.cash = 10
	m.cycle = 2
	m._end_cycle()
	check(not m.choice_pending, "force-goal off: low cash gives no choice")
	m.debug_force_goal = true
	m._end_cycle()
	await process_frame
	check(m.choice_pending and m.cash >= win_cash, "force-goal on: cash raised to win_cash and choice opens")
	await _free_main(m)
	m = await _new_main()
	check(m.debug_force_goal == false, "force-goal: resets in a new run")
	m._dismiss_preface()
	var has_toggle := false
	for b in _buttons(m.debug_menu, []):
		if b is CheckButton and b.text.contains("Force goal"):
			has_toggle = true
	check(has_toggle, "force-goal: debug menu has the toggle")
	await _free_main(m)

	# --- expansion points ---
	_wipe_user()
	m = await _new_main()
	m._dismiss_preface()
	var pp := int(bal["skill_points_planet"])
	var pr := int(bal["skill_points_route"])
	var home: int = maxi(m.mission_planet, 0)
	check(m.pts_planets.has(home) and m.skill_points == pp, "points: home planet gives planet points at start", "pts=%d" % m.skill_points)
	var start: int = m.skill_points
	var a := home
	var b: int = (home + 1) % m.map.planets.size()
	m._award_planet(a)
	check(m.skill_points == start, "points: same planet twice adds nothing")
	m._award_route(a, b)
	check(m.skill_points == start + pp + pr, "points: new pair gives route points plus the new planet's point", "pts=%d" % m.skill_points)
	var after1: int = m.skill_points
	m._award_route(b, a)
	m._award_route(a, b)
	check(m.skill_points == after1, "points: same pair again (either order) adds nothing")
	var c: int = (home + 2) % m.map.planets.size()
	m._award_route(a, c)
	check(m.skill_points == after1 + pp + pr, "points: second pair with one known planet gives route points + one planet point")
	var sys_before: int = m.skill_points
	m.reach_system()
	check(m.skill_points == sys_before + int(bal["skill_points_system"]) and m.systems_reached == 2, "points: reach_system gives system points")
	# round trip through save state
	var st: Dictionary = m.collect_state()
	check(st["skill_points"] == m.skill_points and st["pts_pairs"].size() == 2, "points: saved in state")
	m.skill_points = 0
	m.pts_planets = []
	m.pts_pairs = []
	m.apply_state(st)
	check(m.skill_points == st["skill_points"] and m.pts_planets.size() == st["pts_planets"].size(), "points: restored from state")
	m._award_route(a, b)
	check(m.skill_points == st["skill_points"], "points: no re-award after reload")
	await _free_main(m)

	# real actions award points
	m = await _new_main()
	m._dismiss_preface()
	var n: int = m.map.planets.size()
	var other := -1
	for i in n:
		if i != m.mission_planet and not m.pts_planets.has(i):
			other = i
			break
	var p0: int = m.skill_points
	var comm: String = m.commodities[0] if m.commodities.size() > 0 else ""
	var r: Dictionary = m.set_local_order(other, comm, "buy", true)
	if r["ok"]:
		check(m.skill_points == p0 + pp, "points: placing a local order at a new planet gives planet points")
		m.set_local_order(other, comm, "buy", false)
		m.set_local_order(other, comm, "buy", true)
		check(m.skill_points == p0 + pp, "points: toggling the same order again adds nothing")
	else:
		check(false, "points: local order could be placed", str(r))
	await _free_main(m)

	# --- skill effect keys ---
	m = await _new_main()
	m._dismiss_preface()
	var keys := []
	for k in bal:
		if str(k).begins_with("skill_") and not str(k).begins_with("skill_cost_") and not str(k).begins_with("skill_points_"):
			keys.append(k)
	check(keys.size() > 0, "skills: effect keys present in balance.json", str(keys))
	var allnum := true
	for k in keys:
		if typeof(bal[k]) != TYPE_FLOAT and typeof(bal[k]) != TYPE_INT:
			allnum = false
	check(allnum, "skills: effect keys are numbers")
	var costs_ok := true
	for s in ["A1", "A2", "A4", "A5", "B1", "B2", "B3", "B4", "C1", "C2", "C3", "C4"]:
		if not bal.has("skill_cost_" + s) or not StoryText.has_text("SK_%s_NAME" % s):
			costs_ok = false
	check(costs_ok, "skills: every skill has a cost key and a story name")
	var e = m.engine
	e.learned = []
	var u0: int = e.units_per_cycle()
	var l0: int = e.local_amount()
	var f0: int = e.fixed_cost()
	e.learned = ["A4"]
	check(e.units_per_cycle() == floori(float(m.trade.capacity()) / (2.0 * maxf(0.0001, m.trade.travel_cycles())) * (1.0 + float(bal["skill_A4_route_units"]))) and e.units_per_cycle() > u0, "skills: A4 raises route units by skill_A4_route_units")
	e.learned = ["B2"]
	check(e.local_amount() == floori(float(bal["order_amount"]) * (1.0 + float(bal["skill_B2_order_units"]))) and e.local_amount() > l0, "skills: B2 raises order units by skill_B2_order_units")
	e.learned = ["A5"]
	check(e.fixed_cost() < f0, "skills: A5 lowers upkeep")
	e.learned = ["A1", "A2", "B1", "B3", "B4", "C1", "C2", "C3", "C4"]
	check(e.units_per_cycle() == u0 and e.local_amount() == l0 and e.fixed_cost() == f0, "skills: other skills do not change engine numbers (B3 margin is not wired in code yet)")
	e.learned = m.learned_skills
	await _free_main(m)
	await _test_skill_screen()
	_wipe_user()

# ---- 5. skill screen and learning (T71) ----
func _test_skill_screen() -> void:
	const ST := preload("res://game/skill_tree.gd")
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	check(ST.all_ids().size() == 12, "skills: 12 nodes from story ids (A3 cut)")
	check(ST.prereqs("A1").is_empty() and ST.prereqs("A4") == ["A2"] and ST.prereqs("A5") == ["A4"] and ST.prereqs("C3") == ["C2", "A1"], "skills: prerequisites chain, C3 also needs A1")
	check(m.learned_skills.is_empty(), "skills: nothing learned at start")
	# top bar
	# cost and points
	m.skill_points = 0
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = ["0-1"]
	var r: Dictionary = m.learn_skill("A1")
	check(not r["ok"] and r["reason"] == "points" and m.learned_skills.is_empty(), "skills: not enough points blocks learning")
	m.skill_points = 10
	r = m.learn_skill("A2")
	check(not r["ok"] and r["reason"] == "locked" and m.skill_points == 10, "skills: locked skill cannot be learned, points kept")
	r = m.learn_skill("C3")
	check(not r["ok"] and r["reason"] == "locked", "skills: C3 locked at start")
	var cost_a1 := int(bal["skill_cost_A1"])
	# A1 gate (owner decision 2026-10-28)
	var pts0: Array = m.pts_planets.duplicate()
	var pairs0: Array = m.pts_pairs.duplicate()
	m.pts_planets = [0, 1]
	m.pts_pairs = []
	check(not m.a1_gate_open() and not m.learn_skill("A1")["ok"] and m.learn_skill("A1")["reason"] == "locked", "A1 gate: locked before visits and route")
	m.pts_planets = [0, 1, 2]
	check(not m.a1_gate_open() and m.learn_skill("A1")["reason"] == "locked", "A1 gate: all planets but no route is still locked")
	m.pts_planets = [0, 1]
	m.pts_pairs = ["0-1"]
	check(not m.a1_gate_open() and m.learn_skill("A1")["reason"] == "locked", "A1 gate: route but a planet unvisited is still locked")
	m.pts_planets = [0, 1, 2]
	check(m.a1_gate_open() and SkillTree.state([], "A1", m.skill_ctx()) == "available", "A1 gate: available after all planets and a route")
	m.pts_planets = pts0
	m.pts_pairs = pairs0
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = ["0-1"]
	r = m.learn_skill("A1")
	check(r["ok"] and m.learned_skills == ["A1"] and m.skill_points == 10 - cost_a1, "skills: learning spends skill_cost_A1")
	check(m.last_notice == StoryText.get_text("NOT_SKILL_LEARNED", {"skill": StoryText.get_text("SK_A1_NAME")}), "skills: learn posts the skill notice", m.last_notice)
	r = m.learn_skill("A1")
	check(not r["ok"] and r["reason"] == "known" and m.skill_points == 10 - cost_a1, "skills: a learned skill is not charged twice")
	m.learn_skill("A2")
	check(m.learned_skills == ["A1", "A2"], "skills: A2 learnable after A1")
	m.learn_skill("A5")
	check(not m.learned_skills.has("A5"), "skills: A5 needs A4")
	m.skill_points = 50
	for id in ["A4", "A5"]:
		m.learn_skill(id)
	check(m.engine.learned.has("A4") and m.engine.learned == m.learned_skills, "skills: engine sees learned skills (A4)")
	m.learn_skill("C1")
	m.learn_skill("C2")
	m.learn_skill("C3")
	check(m.learned_skills.has("C3"), "skills: C3 after C2 and A1")
	# screen
	var sc: PanelContainer = m.skill_screen
	check(not sc.visible, "skills screen: closed at start")
	var ev := InputEventKey.new()
	ev.keycode = KEY_K
	ev.pressed = true
	m._unhandled_input(ev)
	check(sc.visible, "skills screen: K opens it")
	check(m.paused, "skills screen: opening does not unpause (game was paused)")
	var ev2 := InputEventKey.new()
	ev2.keycode = KEY_ESCAPE
	ev2.pressed = true
	m._unhandled_input(ev2)
	check(not sc.visible and not m.game_menu.visible, "skills screen: Esc closes it, no game menu")
	sc.open_screen()
	sc.select("B1")
	var bt := _buttons(sc, [])
	var has := {}
	for b in bt:
		has[b.text] = true
	check(has.has(StoryText.get_text("BTN_LEARN")), "skills screen: Learn button for an available skill")
	var before: int = m.skill_points
	sc.confirm_learn()
	check(m.learned_skills.has("B1") and m.skill_points == before - int(bal["skill_cost_B1"]), "skills screen: confirm learns and spends")
	check(sc.node_buttons["B1"].text.contains(StoryText.get_text("SK_STATE_LEARNED")), "skills screen: node shows Learned")
	check(sc.node_buttons["B3"].text.contains(StoryText.get_text("SK_STATE_LOCKED")), "skills screen: node shows Locked")
	check(sc.points_label.text.ends_with(str(m.skill_points)), "skills screen: header shows points left")
	sc.close_screen()
	# game menu
	m.paused = false
	m.game_menu.open_menu()
	check(m.paused and m.game_menu.visible, "game menu: pauses while open")
	m.game_menu.close_menu()
	check(not m.paused, "game menu: Resume restores the earlier state")
	m.paused = true
	# save round trip
	var st: Dictionary = m.collect_state()
	var learned_copy: Array = m.learned_skills.duplicate()
	var pts: int = m.skill_points
	m.learned_skills = []
	m.skill_points = 0
	m.apply_state(JSON.parse_string(JSON.stringify(st)))
	check(m.learned_skills == learned_copy and m.skill_points == pts, "skills: save round trip keeps skills and points", str(m.learned_skills))
	check(m.engine.learned == m.learned_skills, "skills: engine learned follows after load")
	m.apply_state({"cycle": 1})
	check(m.learned_skills.is_empty(), "skills: old save starts with no skills (A1 must be earned)")
	# ending picker feed
	m.learned_skills = ["A1", "A2", "B1"]
	check(m.ending_inputs()["learned"] == ["A1", "A2", "B1"], "skills: ending picker sees learned skills")
	m.cash = int(bal["win_cash"])
	m._end_cycle()
	await process_frame
	var picked := []
	m.run_ended.connect(func(side, id): picked.append(id))
	m.end_screen.chosen.emit("RELEASE")
	await process_frame
	check(picked.size() == 1 and picked[0] == EndingPicker.pick_release(m.ending_inputs()), "skills: choice still resolves through the picker", str(picked))
	var all_text := ""
	for b in _labels(m.end_screen, []):
		all_text += b.text + "|"
	check(all_text.contains("%s: %s, %s" % [StoryText.get_text("END_STAT_BRANCHES"), StoryText.get_text("SK_BRANCH_A"), StoryText.get_text("SK_BRANCH_B")]), "skills: end screen lists learned branch names", all_text)
	var tiers = _read_json("user://stats.json")
	check(typeof(tiers) == TYPE_DICTIONARY and tiers["last"]["tier"] == "Partial" and int(tiers["tiers"]["Partial"]) >= 1, "stats: win records tier Partial", str(tiers))
	check(EndingPicker.tier({"learned": ["A1"]}) == "Bare" and EndingPicker.tier({"learned": ["A1", "A2"]}) == "Partial", "picker: tier Bare/Partial")
	await _free_main(m)

func _labels(n: Node, out: Array) -> Array:
	if n is Label:
		out.append(n)
	for c in n.get_children():
		_labels(c, out)
	return out


func _texts(n: Node) -> Array:
	var out := []
	for l in _labels(n, []):
		out.append(l.text)
	return out

# ---- 6. rescue rule (T95), route waiting (T70), upkeep split (T69) ----
func _test_rescue_waiting() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	var st = m.storage
	var bal: Dictionary = m.balance
	var c: String = m.commodities[0]
	var stip := int(bal["rescue_stipend"])
	var fixed: int = e.fixed_cost()
	check(e.trip_part() + e.upkeep_part() == fixed and e.upkeep_part() > 0, "T69: fixed cost is trip cost plus visible upkeep")
	# default decent start: 1600, one ship, no route yet -> never rescued
	m.ships = 1
	m.cash = int(bal["starting_credits"])
	m.last_rescue_cycle = -1
	m._check_stranded()
	check(m.cash == int(bal["starting_credits"]), "rescue: default start cash is never rescued")
	# no ships and cash below a ship
	m.ships = 0
	m.cash = int(bal["ship_price"]) - 1
	m._check_stranded()
	check(m.cash == int(bal["ship_price"]) - 1 + stip, "rescue: no ships and cash < ship_price pays the stipend")
	# two ships, no route, cash below fixed cost, nothing to sell
	m.ships = 2
	m.cash = 1
	m.last_rescue_cycle = -1
	m._check_stranded()
	check(m.cash == 1 + stip, "rescue: cash below fixed cost, no route running, nothing sellable pays")
	m._check_stranded()
	check(m.cash == 1 + stip, "rescue: at most once per cycle")
	# sellable stock blocks the rescue
	m.cash = 1
	m.last_rescue_cycle = -1
	st.ensure(st.planet_key(0))
	st.add(st.planet_key(0), c, 5)
	e.local_of(0, c, true)["sell"] = true
	m._check_stranded()
	check(m.cash == 1, "rescue: a Sell order with stock means no rescue")
	e.local.clear()
	# a running route blocks the rescue
	var rec: Dictionary = e.new_record(0, 1, c)
	rec["id"] = 1
	rec["state"] = "running"
	e.routes = [rec]
	m.last_net = 10  # a running route that pays is healthy
	m._check_stranded()
	check(m.cash == 1, "rescue: a running route means no rescue")
	rec["state"] = "stalled"
	m._check_stranded()
	check(m.cash == 1 + stip, "rescue: only stalled routes count as not running")
	# T70 waiting vs blocked
	m.cash = 5000
	e.routes = [rec]
	rec["state"] = "running"
	rec["fresh"] = 1.0
	var a_key: String = st.planet_key(0)
	var b_key: String = st.planet_key(1)
	st.ensure(a_key)
	st.ensure(b_key)
	st.add(a_key, c, 40)
	st.add(b_key, c, st.space(b_key, c))
	check(st.is_full(b_key, c), "T70 setup: destination full")
	var r: Dictionary = e.settle(5000)
	check(rec["state"] == "blocked" and r["newly_blocked"].size() == 1, "T70: full destination without outflow blocks with one notice")
	e.local_of(1, c, true)["sell"] = true
	r = e.settle(5000)
	check(rec["state"] == "waiting" and r["newly_blocked"].size() == 0, "T70: with a Sell order the route waits, no notice")
	st.add(b_key, c, st.space(b_key, c))  # the Sell order drained some; fill again
	e.local.clear()
	e.local_of(1, c, true)["sell"] = true
	check(e.status_of(rec) == "waiting" and e.reason_of(rec) == e.waiting_text(), "T70: waiting status and text")
	check(e.payout_of(rec) == 0, "T70: waiting route forecast moves nothing")
	st.remove(b_key, c, 3)
	check(e.payout_of(rec) == -fixed and e.planned_units(rec) == 3, "T70: partial load, forecast pays the cost for 3 units")
	e.local.clear()  # keep the Sell order out of this settle, check only the route
	var before: int = st.amount(a_key, c)
	r = e.settle(5000)
	check(before - st.amount(a_key, c) == 3 and rec["state"] == "running", "T70: partial load moves only what fits and keeps running")
	check(int(r["upkeep"]) == e.upkeep_part() and int(r["gross"]) == int(r["delta"]) + e.upkeep_part(), "T69: settle reports upkeep and gross")
	e.local.clear()
	e.routes = [rec]
	var other: Dictionary = e.new_record(1, 0, c)
	other["id"] = 2
	e.routes.append(other)
	check(e.has_outflow(1, c), "T70: an outgoing route counts as outflow")
	st.remove(a_key, c, st.amount(a_key, c))
	rec["state"] = "running"
	e.settle(5000)
	check(rec["state"] == "stalled", "T70: empty source still stalls")
	# T87: several ships on one identical lane share the source pool
	e.local.clear()
	e.routes = []
	check(e.check_connection(0, 1, c)["ok"], "T87: lane check ok")
	var l1: Dictionary = e.new_record(0, 1, c)
	l1["id"] = 11
	e.routes.append(l1)
	check(e.check_connection(0, 1, c)["ok"], "T87: second ship on the same lane is allowed")
	var l2: Dictionary = e.new_record(0, 1, c)
	l2["id"] = 12
	e.routes.append(l2)
	check(e.lane_count(0, 1, c) == 2 and e.lane_index(l2) == 2 and e.lane_index(l1) == 1, "T87: lane count and ship index")
	var u: int = e.units_per_cycle()
	st.remove(b_key, c, st.amount(b_key, c))
	st.remove(a_key, c, st.amount(a_key, c))
	st.add(a_key, c, mini(u + 1, st.space(a_key, c)))
	var pool: int = st.amount(a_key, c)
	var rr: Dictionary = e.settle(5000)
	check(st.amount(b_key, c) == pool, "T87: two ships move the shared pool, never more than it holds", "moved=%d pool=%d" % [st.amount(b_key, c), pool])
	check(int(rr["gross"]) - int(rr["delta"]) >= 0 and e.routes.size() == 2, "T87: both ships kept")
	await _free_main(m)
	_wipe_user()

## T12: events as price modifiers.
func _test_events() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var ev = m.events
	check(ev.defs.size() >= 19 and ev.by_id.has("EV18") and ev.by_id.has("EV20"), "events: definitions loaded from data/events.json (17 + shield + asteroid)", str(ev.defs.size()))
	for e in ev.defs:
		if str(e["id"]) == "EV17":
			continue  # choice event: effects come from its choices
		if ev.effect_of_event(str(e["id"])).is_empty():
			check(false, "events: tag parses for " + str(e["id"]), str(e["tag"]))
	var pct := float(m.balance["event_price_pct"])
	var cyc := int(m.balance["event_price_cycles"])
	# EV01: Voltara energy price down
	var vi: int = ev.planet_index("Voltara")
	var base_sell: int = m.trade.price(vi, "energy_sell")
	var base_buy: int = m.trade.price(vi, "energy_buy")
	m.debug_fire_event("EV01")
	check(m.event_notice != null and m.paused, "events: notice shown and game paused")
	var btns := _buttons(m.event_notice, [])
	check(btns.size() == 1 and btns[0].text == StoryText.get_text("MENU_CONTINUE"), "events: one Continue button")
	check(m.trade.price(vi, "energy_sell") == roundi(base_sell * (1.0 - pct)) and m.trade.price(vi, "energy_buy") == roundi(base_buy * (1.0 - pct)), "events: both prices x(1-pct)")
	check(m.trade.price(vi, "food_sell") >= -1 and m.trade.price(ev.planet_index("Tillam"), "energy_sell") == m.trade.price(ev.planet_index("Tillam"), "energy_sell"), "events: other prices unchanged")
	btns[0].pressed.emit()
	await process_frame
	check(m.event_notice == null and m.paused, "events: Continue closes the notice")
	for i in cyc:
		check(m.trade.price(vi, "energy_sell") != base_sell, "events: price modified in cycle %d of %d" % [i + 1, cyc])
		m.events.tick()
	check(m.trade.price(vi, "energy_sell") == base_sell and m.events.active.is_empty(), "events: price back to base after event_price_cycles")
	# EV07: Tillam closed
	var ti: int = ev.planet_index("Tillam")
	m.debug_fire_event("EV07")
	check(m.engine.closed_planets.has(ti), "events: Tillam closed")
	check(not m.engine.check_connection(ti, vi, "food")["ok"], "events: cannot route from closed planet")
	_buttons(m.event_notice, [])[0].pressed.emit()
	await process_frame
	m.learned_skills = ["A1"]
	m._sync_closed()
	check(not m.engine.closed_planets.has(ti), "events: A1 bridges the first closed cycle")
	m.learned_skills = []
	m._sync_closed()
	m.events.tick()
	m.events.tick()
	m.events.tick()
	m._sync_closed()
	check(m.engine.closed_planets.is_empty(), "events: planet reopens after event_close_cycles")
	check(m.events.feed.size() == 2, "events: feed lists this run's events")
	# save and reload
	m.debug_fire_event("EV02")
	var st: Dictionary = m.collect_state()
	await _free_main(m)
	m = await _new_main()
	m._dismiss_preface()
	m.apply_state(st)
	check(m.event_notice != null and m.events.active.size() == 1 and m.events.feed.size() == 3, "events: pending notice and active effects survive a reload")
	await _free_main(m)
	# T98: EV17 debris choice
	m = await _new_main()
	m._dismiss_preface()
	ev = m.events
	var fee: int = int(m.balance["debris_clear_fee"])
	m.cash = 1000
	m.debug_fire_event("EV17")
	var dp: int = ev.pending_planet
	var dbtn := _buttons(m.event_notice, [])
	check(m.event_notice != null and m.paused and dbtn.size() == 2, "debris: choice screen with two buttons")
	check(dbtn[0].text.begins_with(StoryText.get_text("EV17_PAY_BTN")) and dbtn[1].text == StoryText.get_text("EV17_LEAVE_BTN"), "debris: button texts from story ids")
	var src: String = m.storage.planet_key(dp)
	var dst: String = m.storage.planet_key((dp + 1) % m.map.planets.size())
	m.storage.add(src, "food", 1000)
	var rec := {"a": dp, "b": (dp + 1) % m.map.planets.size(), "c": "food", "src": src, "dst": dst, "fresh": 1.0}
	var full_units: int = m.engine.planned_units(rec)
	dbtn[1].pressed.emit()  # leave
	check(ev.debris.has(dp) and m.cash == 1000, "debris: leaving keeps the debris and costs nothing")
	var cut: int = m.engine.planned_units(rec)
	var want := floori(m.engine.units_per_cycle() * (1.0 - float(m.balance["debris_route_penalty"])))
	check(cut == want and cut <= full_units, "debris: route units cut by debris_route_penalty", "%d vs %d (full %d)" % [cut, want, full_units])
	check(m.event_notice != null and _buttons(m.event_notice, [])[0].text == StoryText.get_text("BTN_OK"), "debris: outcome popup with OK")
	_buttons(m.event_notice, [])[0].pressed.emit()
	check(m.event_notice == null, "debris: popup closes")
	m.debug_fire_event("EV17")  # the offer comes back on the same planet
	check(ev.pending_planet == dp, "debris: offer returns on the planet with debris")
	_buttons(m.event_notice, [])[0].pressed.emit()  # pay
	check(m.cash == 1000 - fee and ev.debris.is_empty(), "debris: paying costs debris_clear_fee once and clears it")
	check(m.engine.planned_units(rec) == full_units, "debris: routes run as before after paying")
	_buttons(m.event_notice, [])[0].pressed.emit()
	m.cash = 0
	m.debug_fire_event("EV17")
	check(_buttons(m.event_notice, [])[0].disabled, "debris: pay button disabled without the cash")
	await _free_main(m)
	# cadence
	m = await _new_main()
	m._dismiss_preface()
	check(not m.events.due(1) and m.events.due(1 + int(m.balance["event_interval"])), "events: first event after the tutorial cycles, then every event_interval")
	var itv := int(m.balance["event_interval"])
	check(not m.events.due(2) and not m.events.due(itv) and m.events.due(itv + 1) and m.events.due(2 * itv + 1), "events: nothing due at cycle 2")
	m.events.by_id["EV18"]["min_cycle"] = 9
	m.events.by_id["EV20"]["min_cycle"] = 13
	check(not m.events.available("EV18", 2) and m.events.available("EV18", 9) and m.events.available("EV01", 2) and m.events.available("EV18", 0), "events gate: min_cycle respected, missing key is open")
	var gated_ok := true
	for i in 300:
		var pid: String = m.events.random_id([], 2)
		if pid == "EV18" or pid == "EV20" or pid == "":
			gated_ok = false
	check(gated_ok, "events gate: random_id skips gated events before min_cycle")
	var seen18 := false
	for i in 300:
		if m.events.random_id([], 13) == "EV18":
			seen18 = true
	check(seen18, "events gate: gated event can be picked at min_cycle")
	m.events.by_id["EV18"].erase("min_cycle")
	m.events.by_id["EV20"].erase("min_cycle")
	m.debug_force_event = true
	m.cycle = 1
	m.events.pending_id = ""
	m.events.by_id["EV17"]["min_cycle"] = 99
	m.events.by_id["EV18"]["min_cycle"] = 99
	m.events.by_id["EV20"]["min_cycle"] = 99
	m.debug_force_event = false
	for i in 100:
		var q: String = m.events.random_id([], m.cycle + 1)
		if q in ["EV17", "EV18", "EV20"]:
			gated_ok = false
	check(gated_ok, "events gate: no choice event at cycle 2")
	await _free_main(m)

## T58: ship types, purchase, auto-assignment, upkeep and cargo per type, save and restore.
func _test_ships() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	var Sh = load("res://game/ships.gd")
	check(Sh.KINDS == ["small"] and Sh.price("small", bal) == int(bal["ship_price"]), "T58: one ship type, price from balance")
	check(Sh.display_name("small") == "Skerrit", "T58: plain fallback name")
	m.cash = 10000
	check(m.buy_ship()["ok"] and m.ships == 1 and m.cash == 10000 - int(bal["ship_price"]), "T58: buy charges ship_price")
	var e = m.engine
	check(e.upkeep_part() == e.upkeep_part({"ship": "small"}), "T58: default upkeep is the small ship")
	var c := "energy"
	var key: String = m.storage.planet_key(0)
	m.storage.ensure(key)
	m.storage.ensure(m.storage.planet_key(1))
	m.storage.add(key, c, m.storage.space(key, c))
	var r: Dictionary = m.send_stock(0, 1, c)
	check(r["ok"] and e.routes.size() == 1 and str(e.routes[0]["ship"]) == "small", "T58: route auto-assigned the small ship")
	check(not m.can_connect(0, 1, c)["ok"], "T58: no free ship, no route")
	var st: Dictionary = m.collect_state()
	check(not st.has("large_ships"), "T58: save has no large_ships")
	e.from_array([{"a": 0, "b": 1, "c": c, "ship": "large"}], 1)
	check(e.routes.size() == 1 and str(e.routes[0]["ship"]) == "small", "T58: old save with a large route loads as small")
	await _free_main(m)
	_wipe_user()

# ---- notice queue ----
func _test_notice_queue() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	m.shown_notice = ""
	m.notice_queue.clear()
	m.post_notice("first")
	m.post_notice("second")
	m.post_notice("third")
	m.post_notice("second")
	check(m.shown_notice == "first" and m.notice_label.text == "first" and m.notice_queue == ["second", "third"], "notice: second post waits, duplicates dropped", str(m.notice_queue))
	m._advance_notice()
	check(m.notice_label.text == "second" and m.notice_queue == ["third"], "notice: next shows in order")
	m._advance_notice()
	check(m.notice_label.text == "third", "notice: third shows last")
	m._advance_notice()
	check(m.shown_notice == "" and not m.notice_label.visible and m.last_notice == "", "notice: line clears when queue empty")
	for i in 10:
		m.post_notice("n%d" % i)
	check(m.notice_queue.size() <= m.NOTICE_QUEUE_MAX, "notice: queue is capped")
	m.shown_notice = ""
	m.notice_queue.clear()
	m.toggle_pause()
	m.toggle_pause()
	var both: Array = [m.shown_notice] + m.notice_queue
	check(both.has(StoryText.get_text("NOT_PAUSED")) and both.has(StoryText.get_text("NOT_RESUMED")) and both.size() == 2, "notice: pause and resume notices both kept", str(both))

# ---- T85: Space Storage and system 2 ----
func _test_systems() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	check(m.map.planets.size() == 3 and m.open_systems == [1], "sys2: only system 1 planets at start")
	check(m.Systems.get_system(2).get("name_id") == "WORLD_SYS2_NAME" and m.Systems.planets_of(2).size() == 4, "sys2: data format, four planets")
	var names := []
	for p in m.Systems.planets_of(2):
		names.append(p["name"])
	check(names == ["Brannock", "Cindrel", "Mossfell", "Quillon"], "sys2: planet names from story ids", str(names))
	check(m.commodities.size() == 2, "sys2: Quillon none/both do not add commodities", str(m.commodities))
	# permit chain
	check(m.can_buy_permit(2)["reason"] == "skill", "sys2: permit needs C1")
	check(m.can_buy_permit(3)["reason"] == "unknown", "sys2: system 3 does not exist")
	m.learned_skills.append("C1")
	m.cash = 0
	m.skill_points = 100
	check(m.can_buy_permit(2)["reason"] == "credits", "sys2: permit needs credits")
	m.cash = int(bal["permit_2_cost"]) + 50
	m.skill_points = 0
	check(m.can_buy_permit(2)["reason"] == "points", "sys2: permit needs points")
	m.skill_points = int(bal["permit_points_2"]) + 1
	var r: Dictionary = m.buy_permit(2)
	check(r["ok"] and m.cash == 50 and m.skill_points == 1 and m.open_systems.has(2), "sys2: permit spends permit_2_cost and permit_points_2")
	check(m.map.planets.size() == 7 and m.trade.planets.size() == 7 and m.events.planets.size() == 7, "sys2: planets appear everywhere")
	check(m.last_notice == StoryText.get_text("NOT_PERMIT_S2") or m.notice_queue.has(StoryText.get_text("NOT_PERMIT_S2")), "sys2: permit notice")
	check(m.can_buy_permit(2)["reason"] == "owned" and not m.buy_permit(2)["ok"], "sys2: permit bought once")
	check(m.trade.price(3, "food_buy") == 11 and m.trade.price(6, "energy_sell") == 34, "sys2: prices from data")
	# reach point once per system
	m.cash = 5000
	var pts: int = m.skill_points
	var sys0: int = m.systems_reached
	r = m.set_local_order(3, "food", "buy", true)
	check(r["ok"] and m.systems_reached == sys0 + 1, "sys2: first order in system 2 reaches it")
	m.set_local_order(4, "energy", "buy", true)
	check(m.systems_reached == sys0 + 1, "sys2: reach counted once")
	# round trip save
	var st: Dictionary = m.collect_state()
	check(st["open_systems"].has(2), "sys2: open_systems saved")
	await _free_main(m)
	m = await _new_main()
	m._dismiss_preface()
	m.apply_state(st)
	check(m.map.planets.size() == 7 and m.open_systems.has(2) and m.engine.local_on(3, "food", "buy"), "sys2: load restores system and order")
	# Space Storage
	check(not m.space_post_open(1) and not m.space_post_open(2), "space: no post before A1")
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = ["0-1"]
	m.skill_points = 50
	check(m.learn_skill("A1")["ok"], "space: A1 learnable after the gate")
	check(m.space_post_open(1) and m.space_post_open(2), "space: one post per open system after A1")
	check(m.storage.capacity_of("system:1") == int(bal["space_storage_capacity"]), "space: capacity from balance")
	# feed at planet_to_space_rate, after sells
	m.storage.ensure("planet:0")
	m.storage.add("planet:0", "energy", 60)
	m.engine.feed_space()
	var rate := int(bal["planet_to_space_rate"])
	check(m.storage.amount("system:1", "energy") == rate and m.storage.amount("planet:0", "energy") == 60 - rate, "space: planet feeds the post at planet_to_space_rate")
	check(m.storage.amount("system:2", "energy") == 0, "space: systems are separate")
	m.storage.add("system:1", "energy", 100000)
	check(m.storage.amount("system:1", "energy") == int(bal["space_storage_capacity"]), "space: capacity is a hard cap")
	# backup: route runs with an empty source planet storage
	m.storage.stock["planet:0"]["energy"] = 0
	m.storage.stock["system:1"]["energy"] = 100
	m.cash = 5000
	m.ships = 3
	m.set_local_order(1, "energy", "sell", true)
	var cr: Dictionary = m.send_stock(0, 1, "energy")
	check(cr["ok"], "space: route created", str(cr))
	var rec: Dictionary = m.engine.routes[m.engine.routes.size() - 1]
	var before: int = m.storage.amount("system:1", "energy")
	m.engine.settle(m.cash)
	check(str(rec["state"]) == "running" and m.storage.amount("system:1", "energy") < before, "space: post backs a route with an empty source", str(rec["state"]))
	m.learned_skills.erase("A1")
	m.engine.settle(m.cash)
	check(str(rec["state"]) == "stalled", "space: no backup without A1", str(rec["state"]))
	await _free_main(m)
	_wipe_user()

# ---- Every ending class reachable through the game's own win path (end of cycle -> choice -> answer) ----
func _test_every_ending() -> void:
	# [side, learned skills, last cycle?, expected ending]
	var cases := [
		["RELEASE", ["A1"], false, "END_BARE_HANDS"],
		["RELEASE", ["A1", "A2"], true, "END_LAST_LIGHT"],
		["RELEASE", ["B1", "B2", "B3", "B4"], false, "END_COLD_LEDGER"],
		["RELEASE", ["B1", "B2"], false, "END_ENOUGH"],
		["RELEASE", ["C1", "C2"], false, "END_OWN_HORIZON"],
		["RELEASE", ["A1", "A2"], false, "END_SLOW_HARBOR"],
		["CORP", ["A1"], false, "END_CORP_BARE"],
		["CORP", ["A1", "A2"], false, "END_CORP_LOGI"],
		["CORP", ["B1", "B2"], false, "END_CORP_RES"],
		["CORP", ["C1", "C2"], false, "END_CORP_EXP"],
		["CORP", ["A2", "B2"], false, "END_CORP_MIX"],
	]
	for c in cases:
		_wipe_user()
		var m: Control = await _new_main()
		m._dismiss_preface()
		var bal: Dictionary = m.balance
		m.learned_skills = c[1].duplicate()
		m.cash = int(bal["win_cash"])
		if c[2]:
			m.cycle = int(bal["win_cycle"])
		m._end_cycle()
		var ended := []
		m.run_ended.connect(func(sd, id): ended.append([sd, id]))
		m._on_choice(c[0])
		var ok: bool = ended.size() == 1 and ended[0][1] == c[3] and StoryText.has_text(c[3])
		check(ok, "endings: %s with %s -> %s" % [c[0], str(c[1]), c[3]], str(ended))
		await _free_main(m)
	_wipe_user()

# ---- Skill effects that were text only before 2026-10-31: A2, C3, C4, B1, B3, B4 ----
func _test_skill_effects() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	var key0: String = m.storage.planet_key(0)
	# A2 Deep Holds through learn_skill (A2 needs A1)
	var cap0: int = m.storage.capacity_of(key0)
	m.skill_points = 10
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = ["0-1"]
	check(m.learn_skill("A1")["ok"] and m.learn_skill("A2")["ok"], "A2: learned after A1")
	var cap1: int = m.storage.capacity_of(key0)
	check(cap1 == int(round(float(cap0) * (1.0 + float(bal["skill_A2_capacity"])))) and cap1 > cap0, "A2: planet storage capacity raised by skill_A2_capacity", "%d -> %d" % [cap0, cap1])
	check(m.storage.capacity_of("system:1") == int(bal["space_storage_capacity"]), "A2: Space Storage capacity unchanged")
	# C4 Colonial Rights: permit price, through the same function the permit uses
	m.learned_skills.append("C1")
	check(m.permit_cost(2) == int(bal["permit_2_cost"]), "C4: permit at data price without C4")
	m.learned_skills.append("C4")
	check(m.permit_cost(2) == floori(float(bal["permit_2_cost"]) * (1.0 - float(bal["skill_C4_permit_discount"]))), "C4: permit price lowered by skill_C4_permit_discount")
	m.learned_skills.erase("C4")
	# C3 Long Haul: a route from system 1 to system 2 needs it
	m.cash = 50000
	m.skill_points = 100
	check(m.buy_permit(2)["ok"], "C3: system 2 permit bought")
	var r: Dictionary = m.engine.check_connection(0, 3, "energy")
	check(not r["ok"] and r["reason"] == StoryText.get_text("NOT_ROUTE_NEEDS_C3"), "C3: cross-system route refused without Long Haul", str(r))
	check(m.engine.check_connection(3, 4, "energy")["ok"], "C3: a route inside system 2 needs no Long Haul")
	m.learned_skills.append("C3")
	check(m.engine.check_connection(0, 3, "energy")["ok"], "C3: cross-system route allowed with Long Haul")
	m.learned_skills.erase("C3")
	# B1 Market Ledger: history kept at cycle end, saved, shown as text
	check(m.price_history_line(0, "energy") == StoryText.get_text("LBL_PRICE_HISTORY_NONE"), "B1: no history before a cycle closes")
	m.cash = 1000
	m.cycle = 1
	m._end_cycle()
	m._end_cycle()
	var hist: Array = m.price_history.get("0|energy", [])
	check(hist.size() == 2 and int(hist[-1]) == m.trade.price(0, "energy_sell"), "B1: sell price recorded at each cycle end", str(hist))
	var st: Dictionary = m.collect_state()
	check(st.has("price_history") and st["price_history"].has("0|energy"), "B1: history in the save")
	check(m.price_history_line(0, "energy").contains(str(hist[0])), "B1: history line shows the prices")
	# B3 Price Whisper: effects that still run next cycle, not the ones that end now
	var base_e: int = m.trade.price(0, "energy_sell")
	m.events.active = [{"id": "EV01", "kind": "down", "planet": 0, "c": "energy", "left": 1, "age": 0}]
	check(m.trade.price(0, "energy_sell") != base_e and m.trade.price(0, "energy_sell", true) == base_e, "B3: an effect that ends now is not in the next-cycle price")
	m.events.active = [{"id": "EV01", "kind": "down", "planet": 0, "c": "energy", "left": 2, "age": 0}]
	check(m.trade.price(0, "energy_sell", true) == m.trade.price(0, "energy_sell"), "B3: an effect that runs one more cycle is in the next-cycle price")
	m.events.active = []
	# B4 Event Forecast: one cycle ahead of a due event (events come on cycles 5, 9, 13, ...)
	# the warning comes while cycle 4 is running; the event itself starts cycle 5
	m.learned_skills.append("B4")
	m.cash = 1000  # the C3 test left cash above the win goal, which would open the choice instead of ending the cycle
	m.cycle = 3
	m.notice_queue = []
	m.last_notice = ""
	m._end_cycle()
	check(m.cycle == 4 and (m.last_notice == StoryText.get_text("EVT_NEXT_DUE") or m.notice_queue.has(StoryText.get_text("EVT_NEXT_DUE"))), "B4: warning posted in the cycle before an event")
	m.learned_skills.erase("B4")
	m.cash = 1000
	m.cycle = 4
	m.notice_queue = []
	m.last_notice = ""
	m._end_cycle()
	check(not (m.last_notice == StoryText.get_text("EVT_NEXT_DUE") or m.notice_queue.has(StoryText.get_text("EVT_NEXT_DUE"))), "B4: no warning without the skill")
	m.learned_skills.append("B4")
	m.learned_skills.erase("B4")
	await _free_main(m)
	_wipe_user()

# ---- Idle state is not a softlock: a standing order is a legal income action with one ship and no route ----
func _test_idle_actions() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	m.cash = 1068
	m.ships = 1
	m.skill_points = 0
	var key: String = m.storage.planet_key(0)
	var r: Dictionary = m.set_local_order(0, "energy", "buy", true)
	check(r["ok"], "idle: a Buy order is accepted with one ship and no routes", str(r))
	var cash0: int = m.cash
	m._end_cycle()
	var stock: int = m.storage.amount(key, "energy")
	check(stock > 0 and m.cash < cash0, "idle: Buy order fills storage and spends credits (stock %d)" % stock)
	m.set_local_order(0, "energy", "buy", false)
	var sell: Dictionary = m.set_local_order(0, "energy", "sell", true)
	check(sell["ok"], "idle: a Sell order at the stocked planet is accepted")
	var cash1: int = m.cash
	m._end_cycle()
	check(m.cash > cash1 or m.storage.amount(key, "energy") < stock, "idle: Sell order turns stock into credits")
	await _free_main(m)
	_wipe_user()

# ---- Full-tier endings reachable in play: system 2 opened and reached, a branch fully learned ----
func _test_full_endings() -> void:
	# [skills to learn in order, expected id suffix]; each set fully learns its branch (X = two branches)
	var sets := [
		[["A1", "A2", "A4", "A5"], "L"],
		[["B1", "B2", "B3", "B4"], "R"],
		[["A1", "C1", "C2", "C3", "C4"], "E"],
		[["A1", "A2", "A4", "A5", "B1", "B2", "B3", "B4"], "X"],
	]
	for side in ["RELEASE", "CORP"]:
		for set_ in sets:
			_wipe_user()
			var m: Control = await _new_main()
			m._dismiss_preface()
			var bal: Dictionary = m.balance
			m.cash = 50000
			m.skill_points = 100
			m.learned_skills.append("C1")
			var pr: Dictionary = m.buy_permit(2)
			check(pr["ok"] and m.open_systems.has(2), "full: system 2 permit bought (%s)" % side, str(pr))
			m.set_local_order(3, "food", "buy", true)
			check(m.systems_reached == 2, "full: system 2 reached by an order (%s)" % side)
			m.learned_skills.erase("C1")
			m.pts_planets = [0, 1, 2]
			m.pts_pairs = ["0-1"]
			m.skill_points = 100
			var all_ok := true
			for id in set_[0]:
				if not m.learn_skill(id)["ok"]:
					all_ok = false
			check(all_ok, "full: %s set learned in tree order (%s)" % [set_[1], side], str(m.learned_skills))
			check(m.ending_inputs()["all_systems_reached"], "full: all open systems reached (%s)" % side)
			m.cash = int(bal["win_cash"])
			m._end_cycle()
			await process_frame
			var ended := []
			m.run_ended.connect(func(sd, id): ended.append([sd, id]))
			m._on_choice(side)
			var key := "REL" if side == "RELEASE" else "CORP"
			var want := "END_%s_FULL_%s" % [key, set_[1]]
			check(ended.size() == 1 and ended[0][1] == want, "full: %s with %s ends with %s" % [side, set_[1], want], str(ended))
			check(StoryText.has_text(want) and StoryText.has_text(want + "_EPI") and m.end_screen != null, "full: text and epilogue exist (%s %s)" % [side, set_[1]])
			await _free_main(m)
	_wipe_user()

# ---- T13: debug menu QA controls ----
func _test_debug_menu() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	check(m.debug_menu != null, "debug: menu built in a debug build")
	check(not m.debug_tools_allowed(false) and m.debug_tools_allowed(true), "debug: release build excludes the menu")
	var d: PanelContainer = m.debug_menu
	for k in ["force_event", "show_events", "event_state", "debris_planet", "debris_set", "debris_clear", "unlock_s2", "permit_system", "grant_permit",
			"open_systems", "gate_open", "gate_reset", "gate_state", "ship_small", "route_id", "route_level", "route_set_level", "ship_state",
			"cash_add", "points_add", "reset_run", "notice_next", "tut_restart", "tutorial_state", "galaxy_open", "save_now", "save_state"]:
		check(d.qa.has(k), "debug: control " + k)
	d.qa["force_event"].pressed.emit()
	check(m.debug_force_event, "debug: force next event")
	m.debug_force_event = false
	d.qa["debris_set"].pressed.emit()
	check(m.events.debris == [0], "debug: set debris")
	check("Debris: " + m.planet_name(0) in d.event_state_text(), "debug: event state shows debris")
	d.qa["debris_clear"].pressed.emit()
	check(m.events.debris.is_empty(), "debug: clear debris")
	d.qa["unlock_s2"].pressed.emit()
	check(m.open_systems.has(2) and m.map.planets.size() == 7, "debug: unlock system 2 free")
	d.qa["gate_open"].pressed.emit()
	check(m.a1_gate_open() and "OPEN" in d.gate_text(), "debug: A1 gate set")
	d.qa["gate_reset"].pressed.emit()
	check(not m.a1_gate_open(), "debug: A1 gate cleared")
	m.cash = 0
	d.qa["ship_small"].pressed.emit()
	check(m.ships == 1, "debug: free ships")
	d.qa["cash_add"].pressed.emit()
	d.qa["points_add"].pressed.emit()
	check(m.cash == 1000 and m.skill_points >= 5, "debug: cash and points")
	d.qa["notice_next"].pressed.emit()
	check(m.shown_notice != "", "debug: notice posted")
	d.qa["tut_restart"].pressed.emit()
	check(m.cycle == 1 and "Cycle 1" in d.tutorial_text(), "debug: tutorial restart")
	d.qa["galaxy_open"].pressed.emit()
	check(m.galaxy_view.visible, "debug: galaxy view opens")
	d.qa["save_now"].pressed.emit()
	check(FileAccess.file_exists("user://autosave.json") and "autosave.json" in d.qa["save_state"].text, "debug: save forced, path shown")
	await _free_main(m)
	_wipe_user()


## T101: solar shield (EV18). Build cost, planets bought later only, save and load.
func _test_shield() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var b: Dictionary = m.balance
	m.cash = 5000
	var base_e: int = m.trade.price(0, "energy_sell")
	m.debug_fire_event("EV18")
	var btns := _buttons(m.event_notice, [])
	check(m.event_notice != null and btns.size() == 2, "shield: choice screen with two buttons")
	check(btns[0].text.begins_with(StoryText.get_text("EV18_BUILD_BTN")) and btns[1].text == StoryText.get_text("EV18_SKIP_BTN"), "shield: button texts from story ids")
	check(StoryText.has_text("EV18_BUILT") and StoryText.has_text("EV18_SKIPPED"), "shield: popup ids exist")
	btns[0].pressed.emit()  # build
	check(m.shield.built and m.cash == 5000 - int(b["shield_build_cost"]), "shield: build costs shield_build_cost")
	check(_texts(m.event_notice).has(StoryText.get_text("EV18_BUILT")), "shield: built popup text by id")
	_buttons(m.event_notice, [])[0].pressed.emit()
	check(m.trade.price(0, "energy_sell") == base_e and m.shield.unhappiness(0) == 0.0, "shield: planets owned at build time do not change")
	m.debug_fire_event("EV18")
	check(m.event_notice == null, "shield: offered once")
	# system 2 opens after the shield
	m.learned_skills.append("C1")
	m.cash = 5000
	m.skill_points = 10
	m.buy_permit(2)
	var raw: int = int(m.map.planets[3]["base_prices"]["food_sell"])
	var want := roundi(raw * (1.0 - float(b["shield_food_share_shift"])) * (1.0 + float(b["shield_profit_gain"])))
	check(m.shield.affects(3) and not m.shield.affects(0), "shield: new planets are affected, old are not")
	check(m.trade.price(3, "food_sell") == want, "shield: food share shift and profit gain on price", "%d vs %d" % [m.trade.price(3, "food_sell"), want])
	var rawe: int = int(m.map.planets[3]["base_prices"]["energy_buy"])
	check(m.trade.price(3, "energy_buy") == roundi(rawe * (1.0 - float(b["shield_energy_share_shift"]))), "shield: energy share shift on buy price")
	check(is_equal_approx(m.shield.unhappiness(3), float(b["shield_unhappiness"])), "shield: unhappiness from shield_unhappiness")
	check(is_equal_approx(m.shield.unit_factor(3, "energy"), 1.0 + float(b["shield_energy_gain"])) and m.shield.unit_factor(0, "energy") == 1.0, "shield: energy gain only on affected planets")
	m.planet_panel.show_planet(3)
	var found := false
	for l in _texts(m.planet_panel):
		if l.contains("15%"):
			found = true
	check(found, "shield: unhappiness shown in planet panel")
	var st: Dictionary = m.collect_state()
	await _free_main(m)
	m = await _new_main()
	m._dismiss_preface()
	m.apply_state(st)
	check(m.shield.built and m.shield.affects(3) and not m.shield.affects(1), "shield: state saved and loaded")
	check(m.trade.price(3, "food_sell") == want, "shield: price effect after reload")
	await _free_main(m)
	# skip path and old save
	m = await _new_main()
	m._dismiss_preface()
	m.cash = 5000
	m.debug_fire_event("EV18")
	_buttons(m.event_notice, [])[1].pressed.emit()
	check(not m.shield.built and m.shield.decided and m.cash == 5000, "shield: skipping costs nothing and changes nothing")
	_buttons(m.event_notice, [])[0].pressed.emit()
	m.cash = 0
	m.shield.reset()
	m.debug_fire_event("EV18")
	check(_buttons(m.event_notice, [])[0].disabled, "shield: build disabled without the cash")
	check(m.Shield.habitable({}) and not m.Shield.habitable({"habitable": false}), "shield: habitable flag defaults to true")
	await _free_main(m)

## T109: asteroid approach (EV20). Pay or decline, seeded roll, storage cut, save and load.
func _test_asteroid() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var b: Dictionary = m.balance
	var cost: int = int(b["asteroid_deflect_cost"])
	m.cash = 2000
	m.debug_fire_event("EV20")
	var btns := _buttons(m.event_notice, [])
	check(m.event_notice != null and btns.size() == 2, "asteroid: choice screen with two buttons")
	check(btns[0].text.begins_with(StoryText.get_text("EV20_PAY_BTN")) and btns[1].text == StoryText.get_text("EV20_DECLINE_BTN"), "asteroid: button texts from story ids")
	var pts: int = m.skill_points
	btns[0].pressed.emit()  # pay
	check(m.cash == 2000 - cost and m.skill_points == pts + 1, "asteroid: paying costs asteroid_deflect_cost and gives one expansion point")
	check(_texts(m.event_notice).has(StoryText.get_text("EV20_PAID")), "asteroid: paid popup by id")
	check(m.last_notice == StoryText.get_text("EV20_REWARD") or m.notice_queue.has(StoryText.get_text("EV20_REWARD")), "asteroid: reward notice EV20_REWARD")
	_buttons(m.event_notice, [])[0].pressed.emit()
	m.cash = 0
	m.debug_fire_event("EV20")
	check(_buttons(m.event_notice, [])[0].disabled, "asteroid: pay disabled without the cash")
	_buttons(m.event_notice, [])[1].pressed.emit()  # decline with no storage: nothing to hit
	check(m.asteroid_last_hit == -1 and _texts(m.event_notice).has(StoryText.get_text("EV20_MISS")), "asteroid: decline with no storage shows EV20_MISS")
	_buttons(m.event_notice, [])[0].pressed.emit()
	# seeded roll: find one seed for each outcome, replay it
	m.storage.add(Storage.planet_key(1), "food", 90)
	var cap0: int = m.storage.capacity_of(Storage.planet_key(1))
	var bad_seed := -1
	var good_seed := -1
	var probe := RandomNumberGenerator.new()
	for s in range(1, 200):
		probe.seed = s
		if probe.randf() < float(b["asteroid_decline_bad_odds"]):
			if bad_seed < 0: bad_seed = s
		elif good_seed < 0:
			good_seed = s
	m.events.seed_rng(good_seed)
	m.debug_fire_event("EV20")
	_buttons(m.event_notice, [])[1].pressed.emit()
	check(m.storage.capacity_of(Storage.planet_key(1)) == cap0 and _texts(m.event_notice).has(StoryText.get_text("EV20_MISS")), "asteroid: good roll changes nothing")
	_buttons(m.event_notice, [])[0].pressed.emit()
	m.events.seed_rng(bad_seed)
	m.debug_fire_event("EV20")
	_buttons(m.event_notice, [])[1].pressed.emit()
	var cap1: int = m.storage.capacity_of(Storage.planet_key(1))
	check(m.asteroid_last_hit == 1 and cap1 == int(round(cap0 * (1.0 - float(b["asteroid_storage_loss_pct"])))), "asteroid: bad roll cuts storage by asteroid_storage_loss_pct", "%d -> %d" % [cap0, cap1])
	check(m.storage.amount(Storage.planet_key(1), "food") <= cap1 and m.storage.established(Storage.planet_key(1)), "asteroid: stock trimmed, storage not destroyed")
	check(_texts(m.event_notice).has(StoryText.get_text("EV20_HIT_CAPACITY", {"planet": m.planet_name(1)})), "asteroid: hit popup EV20_HIT_CAPACITY with planet")
	_buttons(m.event_notice, [])[0].pressed.emit()
	m.events.seed_rng(bad_seed)  # same seed, same outcome
	m.debug_fire_event("EV20")
	_buttons(m.event_notice, [])[1].pressed.emit()
	check(m.asteroid_last_hit == 1, "asteroid: same seed replays the same outcome")
	_buttons(m.event_notice, [])[0].pressed.emit()
	var st: Dictionary = m.collect_state()
	await _free_main(m)
	m = await _new_main()
	m._dismiss_preface()
	m.apply_state(st)
	check(m.storage.capacity_of(Storage.planet_key(1)) < cap1 and m.storage.capacity_of(Storage.planet_key(2)) == cap0, "asteroid: cuts saved and loaded")
	await _free_main(m)
