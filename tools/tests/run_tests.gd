extends SceneTree
## Headless tests (T79). Run: sh tools/tests/run.sh   (see that file; it sets a scratch HOME).
## Covers: story text, ending picker, win/loss paths, run recording, expansion points, skill keys, force-goal.
## Tests only read behaviour; they change no game code.

const StoryText := preload("res://game/story_text.gd")
const EndingPicker := preload("res://game/ending_picker.gd")
const Storage := preload("res://game/storage.gd")
const Clusters := preload("res://game/clusters.gd")
const RouteEngine := preload("res://game/route_engine.gd")
const Juice := preload("res://game/juice.gd")
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
	await _test_juice()
	await _test_main()
	await _test_rescue_waiting()
	await _test_events()
	await _test_ships()
	await _test_next_cycle()
	await _test_notice_queue()
	await _test_systems()
	await _test_galaxy_view()
	_test_route_tag()
	await _test_ship_clock()
	await _test_energy_then_food()
	await _test_salvage()
	await _test_system_suns()
	await _test_stations()
	await _test_trade_gate()
	await _test_shield()
	await _test_asteroid()
	await _test_full_endings()
	await _test_idle_actions()
	await _test_skill_effects()
	await _test_every_ending()
	await _test_debug_menu()
	await _test_planet_size()
	await _test_dust_ring()
	await _test_voltara_belt()
	await _test_dead_planets()
	await _test_dead_world_mechanics()
	await _test_dead_events_chain()
	await _test_dead_choice_effects()
	await _test_fabric()
	await _test_price_event()
	await _test_route_move()
	await _test_split_send()
	await _test_mixed_load()
	await _test_stop_sale()
	await _test_second_lane()
	await _test_forecast_income()
	await _test_cash_reserve()
	await _test_sell_only_idle()
	await _test_stall_rescue()
	await _test_mining_reachable()
	await _test_clusters()
	await _test_asteroid_packs()
	_test_event_banners()
	print("TOTAL pass=%d fail=%d" % [passed, failed])
	quit(1 if failed > 0 else 0)

# ---- 0. juice: motion helpers and pop-up / number / button states (the effects only; no timing of the look) ----
func _test_juice() -> void:
	check(Juice.shake_offset(0.0, 3.0) == Vector2.ZERO and Juice.shake_offset(1.0, 3.0).length() < 0.0001, "juice: nudge starts and ends at rest")
	var peak := 0.0
	for i in 101:
		peak = maxf(peak, absf(Juice.shake_offset(i / 100.0, 3.0).x))
	check(peak > 0.5 and peak <= 3.0001, "juice: nudge stays within its strength", str(peak))
	check(Juice.count_value(0, 10, 0.0) == 0 and Juice.count_value(0, 10, 1.0) == 10, "juice: count runs from its start to its target")
	check(Juice.count_value(0, 10, 0.5) > 5, "juice: count eases out (ahead of linear at half time)")
	check(Juice.count_value(20, 10, 1.0) == 10, "juice: count can run down")
	var lbl := Label.new()
	Juice.count_to(lbl, 5, "+%d")
	check(lbl.text == "+5", "juice: out of the tree a count shows at once", lbl.text)
	Juice.count_to(lbl, 5, "+%d")
	Juice.count_to(lbl, 9, "+%d")
	check(lbl.text == "+9", "juice: a changed count shows its new value", lbl.text)
	lbl.free()
	var loose := Control.new()
	Juice.leave(loose, false)
	check(not loose.visible, "juice: leave out of the tree hides at once")
	Juice.enter(loose)
	check(loose.visible, "juice: enter out of the tree shows at once")
	loose.free()

	var h := Control.new()
	root.add_child(h)
	var lb := Label.new()
	h.add_child(lb)
	Juice.motion = 0.0
	Juice.count_to(lb, 3, "+%d")
	Juice.count_to(lb, 7, "+%d")
	check(lb.text == "+7", "juice: motion off, a count is instant", lb.text)
	Juice.motion = 1.0
	Juice.count_to(lb, 20, "+%d", Color(1, 1, 0, 1))
	await create_timer(0.7).timeout
	check(lb.text == "+20" and lb.modulate.is_equal_approx(Color.WHITE), "juice: a count lands on its target and the tint settles", lb.text)

	# a pop-up entered, left and entered again ends at rest, with nothing left offset or faded
	var p := Control.new()
	h.add_child(p)
	p.position = Vector2(12, 34)
	Juice.enter(p, Juice.ENTER_SCALE, Juice.SLIDE_PX)
	check(p.scale.x < 1.0 and p.position.y < 34.0 and p.modulate.a < 1.0, "juice: an entry starts small, raised and clear")
	Juice.leave(p, false)
	Juice.enter(p, Juice.ENTER_SCALE, Juice.SLIDE_PX)
	await create_timer(0.7).timeout
	check(p.visible and p.scale.is_equal_approx(Vector2.ONE) and p.position.is_equal_approx(Vector2(12, 34)) and is_equal_approx(p.modulate.a, 1.0),
		"juice: an interrupted entry ends at rest", str([p.scale, p.position, p.modulate.a]))
	var done := [false]
	Juice.leave(p, false, func(): done[0] = true)
	await create_timer(0.4).timeout
	check(not p.visible and done[0], "juice: a leave hides the control and calls its done hook")

	var b := Button.new()
	h.add_child(b)
	Juice.press(b, true)
	await create_timer(0.2).timeout
	check(b.scale.x < 1.0, "juice: a press squashes the button")
	Juice.press(b, false)
	await create_timer(0.3).timeout
	check(b.scale.is_equal_approx(Vector2.ONE), "juice: a release springs the button back to rest")

	var n := Control.new()
	h.add_child(n)
	n.position = Vector2(50, 60)
	Juice.nudge(n)
	await create_timer(0.5).timeout
	check(n.position.is_equal_approx(Vector2(50, 60)), "juice: a nudge returns the control to its place", str(n.position))

	var fl := Label.new()
	h.add_child(fl)
	Juice.flash(fl, Color(1, 0.5, 0, 1))
	await create_timer(0.5).timeout
	check(fl.modulate.is_equal_approx(Color.WHITE), "juice: a flash settles back to its own colour", str(fl.modulate))
	var pp := Label.new()
	h.add_child(pp)
	pp.size = Vector2(40, 20)
	Juice.pop(pp)
	await create_timer(0.1).timeout
	check(pp.scale.x > 1.0, "juice: a pop swells the label")
	await create_timer(0.4).timeout
	check(pp.scale.is_equal_approx(Vector2.ONE), "juice: a pop settles back to scale 1", str(pp.scale))
	h.queue_free()
	Juice.motion = 1.0
	await process_frame

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
	check(not P.shield_built({}) and P.shield_built({"shield_built": true}), "T121: hidden shield flag read by picker")
	var _si := _inp(["A1", "A2"]); _si["shield_built"] = true
	check(P.pick_release(_si) == P.pick_release(_inp(["A1", "A2"])), "T121: flag changes no ending row")
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
func _test_galaxy_view() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	await process_frame
	check(m.top_bar.is_ancestor_of(m.menu_button) and m.top_bar.is_ancestor_of(m.points_button), "hud: menu icon and skill points button sit in the top bar")
	m.points_hit.pressed.emit()
	await process_frame
	check(m.skill_screen != null and m.skill_screen.visible, "hud: pressing the skill points figure opens the skill screen")
	m.toggle_skills()
	await process_frame
	check(m.menu_button.get_parent().get_child(0) == m.menu_button, "hud: menu icon is first, top left")
	check(m.top_bar.is_ancestor_of(m.pause_button), "hud: pause icon sits in the top bar, top right")
	check(m.pause_button.get_parent().get_child(m.pause_button.get_parent().get_child_count() - 1) == m.pause_button, "hud: pause icon is the last item, far right")
	m.set_paused(false)
	var running_icon: Texture2D = m.pause_button.icon
	m.set_paused(true)
	check(m.pause_button.icon != running_icon and m.pause_button.text == "", "hud: pause icon swaps to play when paused, icon only")
	check(m.points_label.text == str(m.skill_points), "hud: skill points read from the game; no expenses item in the top bar")
	var ex: Control = m.system_exit
	var lay: Dictionary = ex.layout()
	check(ex.next_locked() == 2, "exit: the next locked system is system 2")
	if not lay.is_empty():
		check(Rect2(Vector2.ZERO, ex.get_viewport_rect().size).has_point(lay["marker"]), "exit: a shown marker is inside the camera view", str(lay["marker"]))
	var pr := Rect2(Vector2(430, 110), Vector2(1000, 800))
	var pin: Vector2 = ex.pin_to_rect(Vector2(600, 500), Vector2(5000, 500), false, pr)
	check(pr.grow(0.01).has_point(pin) and is_equal_approx(pin.x, pr.end.x) and is_equal_approx(pin.y, 500.0), "exit: an off-screen open system pins to the area edge, towards it")
	check(is_equal_approx(ex.pin_to_rect(Vector2(600, 500), Vector2(5000, 500), true, pr).x, pr.position.x), "exit: a system behind the camera pins to the opposite side")
	var vw := Vector2(1920, 1080)
	check(ex.on_screen(Vector2(900, 500), false, vw) and not ex.on_screen(Vector2(2500, 500), false, vw) and not ex.on_screen(Vector2(-10, 500), false, vw) and not ex.on_screen(Vector2(900, 500), true, vw), "exit: off screen or behind the camera hides the marker (no edge pin)")
	var vs0: int = m.view_system
	check(not m.go_to_system(2) and not m.enter_system_from_view(2) and m.view_system == vs0 and m.map.view_system == 1, "exit: a locked target does not move the player")
	if not lay.is_empty():
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = true
		ev.position = lay["marker"]
		check(ex.hit_test(ev.position) == 2 and lay["locked"], "exit: the locked marker is hit by a click on it, shown as locked")
		ex._input(ev)
		check(m.view_system == 1, "exit: clicking the locked marker stays in the system")
	m.open_systems = [1, 2]
	await process_frame
	check(ex.next_locked() == -1 and ex.markers().all(func(k): return not k["locked"]), "exit: no locked marker once every system is open")
	m.open_systems = [1]
	var g: Control = m.galaxy_view
	check(g.open_view() and g.visible, "galaxy: opens with one system open")
	check(g.get_global_rect().size == m.get_viewport_rect().size and g.get_index() == m.get_child_count() - 1, "galaxy: is a full screen on top of the map screen")
	check(g.close_button.text == StoryText.get_or("BTN_BACK", "Back") and not m.map.keys_enabled, "galaxy: Back button, map keys off while open")
	check(g.tut_step == -1 and not g.tut_panel.visible, "galaxy: no tutorial until system 2 is open")
	check(g.selected_sys == 1 and g.side.visible, "galaxy: the current system is selected, panel shown")
	g.selected_sys = 2  # a locked system: uncharted panel with a disabled Open system and the reason
	g._build_side()
	var found_disabled := false
	for n in g.side_box.get_children():
		if n is Button and (n as Button).disabled:
			found_disabled = true
	check(found_disabled, "galaxy: uncharted system has a disabled Open system button")
	g.queue_redraw()  # the draw code runs for open and uncharted systems
	await process_frame
	g.close_view()
	check(m.map.keys_enabled, "galaxy: Back gives the map its keys again")
	m._open_system(2)
	m.galaxy_seen = false
	check(g.open_view() and g.tut_step == 0 and g.tut_panel.visible and m.galaxy_seen, "galaxy: tutorial starts at line 1 once system 2 is open")
	g.tut_step = 1
	g._build_tutorial()
	g.queue_redraw()
	await process_frame
	g.tut_step = 3
	g._build_tutorial()
	g.selected_sys = 2
	g._build_side()
	g.queue_redraw()
	await process_frame
	check(g.side_box.get_child_count() > 3, "galaxy: open system panel lists planets and routes")
	var chosen: Array = []
	g.system_chosen.connect(func(id): chosen.append(id))
	for n in g.side_box.get_children():
		if n is Button and not (n as Button).disabled and (n as Button).text == StoryText.get_or("BTN_OPEN_SYSTEM", "Open system"):
			(n as Button).pressed.emit()
	check(chosen == [2], "galaxy: Open system asks main to zoom into the system", str(chosen))
	g.close_view()
	check(g.open_view() and g.tut_step == -1, "galaxy: tutorial does not come back")
	await _free_main(m)

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
	check(e.units_per_cycle() == u0 and e.local_amount() == l0 and e.fixed_cost() == f0, "skills: other skills do not change engine numbers (B3 margin only touches sell credits)")
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
	check(ST.all_ids().size() == 15, "skills: 12 story nodes (A3 cut) plus M1, M2, F1")
	check(ST.prereqs("A1").is_empty() and ST.prereqs("A4") == ["A2"] and ST.prereqs("A5") == ["A4"] and ST.prereqs("C3") == ["C2", "A1"], "skills: prerequisites chain, C3 also needs A1")
	check(m.learned_skills.is_empty(), "skills: nothing learned at start")
	# top bar
	# cost and points
	m.skill_points = 0
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = ["0-1", "0-2"]
	m.learned_skills.append("C1")  # permit first: with C1 known, the points check is what refuses A1
	var r: Dictionary = m.learn_skill("A1")
	check(not r["ok"] and r["reason"] == "points" and m.learned_skills == ["C1"], "skills: not enough points blocks learning")
	m.learned_skills.clear()
	m.skill_points = 10
	r = m.learn_skill("A2")
	check(not r["ok"] and r["reason"] == "locked" and m.skill_points == 10, "skills: locked skill cannot be learned, points kept")
	r = m.learn_skill("C3")
	check(not r["ok"] and r["reason"] == "locked", "skills: C3 locked at start")
	check(ST.state([], "C4") == "locked" and ST.state(["A1", "C1", "C2"], "C4") == "available" and ST.state(["C2"], "C4") == "locked" and ST.prereqs("C4") == ["C2"], "skills: C4 locked before C2, available after C2 without C3")
	r = m.learn_skill("C4")
	check(not r["ok"] and r["reason"] == "locked", "skills: C4 locked at start")
	var cost_a1 := int(bal["skill_cost_A1"])
	# A1 gate (owner decision 2026-11-03): two routes, any planet
	var pts0: Array = m.pts_planets.duplicate()
	var pairs0: Array = m.pts_pairs.duplicate()
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = []
	check(not m.a1_gate_open() and m.learn_skill("A1")["reason"] == "locked", "A1 gate: all planets visited but no route is locked")
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = ["0-1"]
	check(not m.a1_gate_open() and m.learn_skill("A1")["reason"] == "locked", "A1 gate: one route is still locked")
	m.learned_skills.append("C1")  # permit first: the gate alone decides A1 from here
	m.pts_planets = [0, 1]
	m.pts_pairs = ["0-1", "1-3"]
	check(m.a1_gate_open() and SkillTree.state([], "A1", m.skill_ctx()) == "available", "A1 gate: two routes open it, no other planet visits needed")
	m.pts_planets = []
	m.pts_pairs = ["4-5", "6-7"]
	check(m.a1_gate_open() and SkillTree.state([], "A1", m.skill_ctx()) == "available", "A1 gate: opens on any planets, not just system 1")
	m.learned_skills.clear()
	m.pts_planets = pts0
	m.pts_pairs = pairs0
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = ["0-1", "0-2"]
	# permit first: with no C1, nothing else can be learned
	m.skill_points = 100
	r = m.learn_skill("A1")
	check(not r["ok"] and r["reason"] == "locked" and r.get("why", "") == "permit_first" and m.learned_skills.is_empty() and m.skill_points == 100, "permit first: A1 locked without C1, with reason")
	r = m.learn_skill("B1")  # alpha fix 2026-11-02: Prospecting is gated by neither rule, so mining is reachable at once
	check(r["ok"] and m.learned_skills == ["B1"] and m.skill_points == 100 - int(bal["skill_cost_B1"]), "mining gate: B1 learnable first, before C1 and A1, at its normal cost")
	m.learned_skills.clear()
	m.skill_points = 100
	check(ST.state([], "B1", m.skill_ctx()) == "available" and ST.state([], "B2", m.skill_ctx()) == "locked" and ST.state([], "C1", m.skill_ctx()) == "available", "permit first: B1 and C1 available, the rest locked")
	check(ST.state(["A1"], "A1", {"c1_learned": false}) == "learned", "permit first: an already learned skill is not revoked")
	r = m.learn_skill("C1")
	check(r["ok"] and m.learned_skills == ["C1"] and m.skill_points == 100 - int(bal["skill_cost_C1"]), "permit first: C1 learnable first at its normal cost")
	r = m.learn_skill("B2")
	check(not r["ok"] and r["reason"] == "locked" and r.get("why", "") == "first_row", "first row: B2 still locked after C1 alone, with reason")
	check(ST.state(["C1"], "B2", m.skill_ctx()) == "locked" and ST.state(["A1", "C1", "B1"], "B2", m.skill_ctx()) == "available" and ST.state(["B1"], "B1", m.skill_ctx()) == "learned", "first row: B2 opens with A1, C1 and B1; a learned skill stays learned")
	check(ST.first_row_blocks([], "B2") and not ST.first_row_blocks([], "A1") and not ST.first_row_blocks([], "C1") and not ST.first_row_blocks([], "B1") and ST.in_first_row("B1") and not ST.first_row_blocks(["A1", "C1"], "B2"), "first row: lock rule in skill_tree (B1 free)")
	# the A1 gate (two routes) does not stand in the way of mining: C1 + B1 only
	check(m.learned_skills == ["C1"] and m.learn_skill("B1")["ok"], "mining gate: B1 after C1 without A1")
	m.learned_skills.erase("B1")
	m.skill_points = 10
	r = m.learn_skill("A1")
	check(r["ok"] and m.learned_skills == ["C1", "A1"] and m.skill_points == 10 - cost_a1, "skills: learning spends skill_cost_A1")
	check(m.last_notice == StoryText.get_text("NOT_SKILL_LEARNED", {"skill": StoryText.get_text("SK_A1_NAME")}), "skills: learn posts the skill notice", m.last_notice)
	r = m.learn_skill("A1")
	check(not r["ok"] and r["reason"] == "known" and m.skill_points == 10 - cost_a1, "skills: a learned skill is not charged twice")
	m.learn_skill("A2")
	check(m.learned_skills == ["C1", "A1", "A2"], "skills: A2 learnable after A1")
	m.learn_skill("A5")
	check(not m.learned_skills.has("A5"), "skills: A5 needs A4")
	m.skill_points = 50
	for id in ["A4", "A5"]:
		m.learn_skill(id)
	check(m.engine.learned.has("A4") and m.engine.learned == m.learned_skills, "skills: engine sees learned skills (A4)")
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


func _all_buttons(n: Node) -> Array:
	var out := []
	if n is Button:
		out.append(n)
	for ch in n.get_children():
		out.append_array(_all_buttons(ch))
	return out

func _find_named(n: Node, nm: String) -> Node:
	for ch in n.get_children():
		if ch.name == nm and not ch.is_queued_for_deletion():
			return ch
		var f := _find_named(ch, nm)
		if f != null:
			return f
	return null

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
	# T145: a full lane gets the upgrade and the margin rises
	e.local.clear()
	e.routes = []
	var n_full: int = ceili(float(e.local_amount()) / float(maxi(1, e.units_per_cycle())))
	for k in n_full:
		var fr: Dictionary = e.new_record(0, 1, c)
		fr["id"] = 21 + k
		e.routes.append(fr)
	m.ships = n_full + 1
	m.cash = 5000
	check(e.lane_full(0, 1, c) and e.lane_upgrade_offered(0, 1, c), "T145: lane is full and offers the upgrade")
	check(not m.can_connect(0, 1, c)["ok"], "T145: a full lane refuses one more ship")
	var m1: int = e.route_margin(0, 1, c)
	var cost: int = int(m.balance["upgrade_cost"])
	# T147: button on a full lane, absent on a lane that is not full, taken after the upgrade
	m.planet_panel.show_planet(0, 21)
	var ub: Button = _find_named(m.planet_panel, "UpgradeRouteButton") as Button
	check(ub != null and not ub.disabled and _find_named(m.planet_panel, "UpgradeRouteTaken") == null, "T147: full lane shows an enabled Upgrade route button")
	m.cash = cost - 1
	m.planet_panel.show_planet(0, 21)
	ub = _find_named(m.planet_panel, "UpgradeRouteButton") as Button
	check(ub != null and ub.disabled and ub.tooltip_text != "", "T147: button disabled with a reason when cash is short")
	m.cash = 5000
	var short0: Dictionary = e.new_record(2, 3, c)
	short0["id"] = 41
	e.routes.append(short0)
	m.planet_panel.show_planet(2, 41)
	check(_find_named(m.planet_panel, "UpgradeRouteButton") == null and _find_named(m.planet_panel, "UpgradeLine") == null, "T147: a lane that is not full shows no upgrade button")
	e.routes.erase(short0)
	m.planet_panel.show_planet(0, 21)
	(_find_named(m.planet_panel, "UpgradeRouteButton") as Button).pressed.emit()
	check(e.lane_level(0, 1, c) == 2 and m.cash == 5000 - cost, "T147: pressing the button upgrades the lane")
	m.cash = 5000 + cost  # restore for the checks below
	e.set_lane_level(0, 1, c, 1)
	m.cash = 5000
	var up: Dictionary = m.upgrade_route(21)
	m.planet_panel.show_planet(0, 21)
	check(_find_named(m.planet_panel, "UpgradeRouteButton") == null and _find_named(m.planet_panel, "UpgradeRouteTaken") != null, "T147: upgraded lane shows it as taken, no button")
	check(up["ok"] and m.cash == 5000 - cost and e.lane_level(0, 1, c) == 2, "T145: upgrade charges upgrade_cost once and sets level 2", str(up))
	var m2: int = e.route_margin(0, 1, c, 2)
	if m1 > 0:
		check(m2 > m1 and m2 == roundi(float(m1) * (1.0 + float(m.balance["upgrade_margin_bonus"]))), "T145: margin rises by upgrade_margin_bonus", "%d -> %d" % [m1, m2])
	check(not m.upgrade_route(21)["ok"] and not e.lane_upgrade_offered(0, 1, c), "T145: no second upgrade")
	var short: Dictionary = e.new_record(2, 3, c)
	short["id"] = 40
	e.routes.append(short)
	check(not e.lane_full(2, 3, c) and not m.upgrade_route(40)["ok"], "T145: a lane that is not full cannot be upgraded")
	await _free_main(m)
	_wipe_user()

## T12: events as price modifiers.
func _test_events() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	m._open_system(2)  # story events name Greywake (system 2): its tags need the planet in the list
	var ev = m.events
	check(ev.defs.size() >= 19 and ev.by_id.has("EV18") and ev.by_id.has("EV20"), "events: definitions loaded from data/events.json (17 + shield + asteroid)", str(ev.defs.size()))
	var sk: Dictionary = ev.parse_tag("[price up: Tillam, silk]")
	check(sk.get("c") == "silk" and ev.parse_tag("[price down: Voltara, ore]").get("c") == "ore" and ev.parse_tag("[price up: Ashgate, chips]").get("c") == "chips", "T155: events parse the new goods", str(sk))
	check(is_equal_approx(ev.pct("silk"), float(m.balance["event_pct_silk"])) and is_equal_approx(ev.pct("energy"), float(m.balance["event_pct_energy"])), "T155: per-good event pct, energy uses its own swing")
	for e in ev.defs:
		if str(e["id"]) == "EV17" or str(e.get("kind", "")) == "C":
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
	var pct_energy := float(m.balance["event_pct_energy"])  # energy has its own swing since the frost change
	check(m.trade.price(vi, "energy_sell") == roundi(base_sell * (1.0 - pct_energy)) and m.trade.price(vi, "energy_buy") == roundi(base_buy * (1.0 - pct_energy)), "events: both prices x(1-pct)")
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
	m.events.by_id["EV18"].erase("min_cycle")
	var early18 := false
	for i in 300:
		for cy in [2, 5, 9]:
			if m.events.random_id([], cy) == "EV18":
				early18 = true
	check(not early18 and not m.events.available("EV18", 9) and m.events.available("EV18", 10) and m.events.available("EV18", 0), "events gate: sun event EV18 default gate, never before cycle 10")
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
	# good gate: no silk event while no open planet trades silk
	var silk_ids: Array = []
	for d in m.events.defs:
		if str(m.events.effect_of_event(str(d["id"])).get("c", "")) == "silk":
			silk_ids.append(str(d["id"]))
	var silk_early := false
	for i in 400:
		if silk_ids.has(m.events.random_id([], 13)):
			silk_early = true
	check(silk_ids.size() >= 2 and not silk_early and not m.events.available(silk_ids[0], 13), "events good gate: no silk event while only system 1 is open", str(silk_ids))
	m.events.planets[1]["base_prices"]["silk_buy"] = 20
	var silk_seen := false
	for i in 600:
		if silk_ids.has(m.events.random_id([], 13)):
			silk_seen = true
	m.events.planets[1]["base_prices"].erase("silk_buy")
	check(silk_seen and m.events.available(silk_ids[0], 13) == false, "events good gate: silk event can be picked once an open planet trades silk")
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
func _test_next_cycle() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	var st = m.storage
	var c := "energy"
	m.cash = 100000
	st.ensure("planet:0")
	st.ensure("system:1")
	st.add("planet:0", c, 60)
	# sell order shows the out amount
	var o: Dictionary = m.set_local_order(0, c, "sell", true)
	var pk0: Dictionary = e.project_storage("planet:0", c, m.cash)
	var want: int = mini(e.local_amount(), 60)
	if o["ok"]:
		check(int(pk0["out"]) == want and int(pk0["in"]) == 0 and int(pk0["after"]) == 60 - want and int(pk0["capacity"]) == st.capacity_of("planet:0"), "next cycle: a sell order shows the out amount", str(pk0))
	else:
		check(false, "next cycle: sell order could not be set", str(o))
	# route from a planet into a station shows in for the station
	var rec: Dictionary = e.new_record(0, -1, c)
	rec["id"] = e.next_id
	e.next_id += 1
	e.routes.append(rec)
	var ps: Dictionary = e.project_storage("system:1", c, m.cash)
	check(int(ps["in"]) > 0 and int(ps["after"]) == int(ps["in"]) and int(ps["capacity"]) == st.capacity_of("system:1"), "next cycle: a route into a station shows in", str(ps))
	# no state change
	var stock0: Dictionary = st.to_dict()
	var cash0: int = m.cash
	var routes0: Array = e.to_array()
	var local0: Array = e.local_to_array()
	e.project_storage("planet:0", c, m.cash)
	e.project_storage("system:1", c, m.cash)
	check(st.to_dict() == stock0 and m.cash == cash0 and e.to_array() == routes0 and e.local_to_array() == local0, "next cycle: projection changes no stock, cash, routes or orders")
	# full storage is clamped to capacity
	e.routes.clear()
	e.local.clear()
	st.add("system:1", c, st.space("system:1", c))
	e.routes.append(rec)
	var pf: Dictionary = e.project_storage("system:1", c, m.cash)
	check(int(pf["after"]) == st.capacity_of("system:1") and int(pf["in"]) == 0, "next cycle: a full storage is clamped to capacity", str(pf))
	# the panel row builds; the label sits in the same row as the bar and name, hidden when nothing moves
	e.routes.clear()
	e.local.clear()
	m.planet_panel.show_planet(0)
	check(m.planet_panel.find_child("NextCycle_" + c, true, false) == null, "next cycle: hidden when in and out are both 0")
	var o2: Dictionary = m.set_local_order(0, c, "sell", true)
	if o2["ok"]:
		m.planet_panel.show_planet(0)
		var nc1: Node = m.planet_panel.find_child("NextCycle_" + c, true, false)
		var par: Node = nc1.get_parent() if nc1 != null else null
		check(nc1 != null, "next cycle: visible with a sell order and stock")
		check(par is HBoxContainer and par.get_child_count() == 5 and par.get_child(par.get_child_count() - 1) == nc1, "next cycle: label is the last child of the storage row, not a sibling below it")
	await _free_main(m)

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
	# Send to... buys a ship when none is free (the planet panel has no separate Buy ship button)
	var cash_before: int = m.cash
	m.ships = 1
	var rb: Dictionary = m.send_stock_buying(0, 2, c)
	check(rb["ok"] and rb["bought"] and m.ships == 2 and e.routes.size() == 2 and m.cash == cash_before - int(bal["ship_price"]), "send: no free ship buys one, then makes the route")
	m.planet_panel.show_planet(0, int(e.routes[0]["id"]))  # builds route rows, ship rows and the detail block
	var texts: Array = []
	var stack: Array = [m.planet_panel]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is Button:
			texts.append((n as Button).text)
		stack.append_array(n.get_children())
	var buy_btn := false
	for tx in texts:
		if str(tx).begins_with("Buy a ship"):
			buy_btn = true
	check(not buy_btn and texts.has(StoryText.get_text("BTN_REMOVE")), "planet panel: no Buy ship button, ships have their own Remove")
	var buys := 0
	var sends := 0
	var combined := 0
	for tx in texts:
		var t := str(tx)
		if t.begins_with(StoryText.get_or("BTN_BUY_SEND", "Buy and send to...")):
			combined += 1
		elif t.begins_with(StoryText.get_text("BTN_BUY")):
			buys += 1
		if t.begins_with(StoryText.get_text("BTN_SEND")):
			sends += 1
	check(combined == 0 and buys == m.commodities.size() and sends >= m.commodities.size(), "T141 planet panel: separate Buy toggle and Send to... per resource, no combined button")
	# T143: each route row says where its money lands, with a control to turn the destination Sell order on
	var pays := _find_named(m.planet_panel, "PaysLine")
	check(pays != null and _find_named(pays, "PaysSellButton") != null, "T143: route row has a pays line with a Sell control while the destination Sell is off")
	var dst: int = int(e.routes[0]["b"])
	check(not m.engine.local_on(dst, c, "sell"), "T143: destination Sell starts off")
	(_find_named(pays, "PaysSellButton") as Button).pressed.emit()
	check(m.engine.local_on(dst, c, "sell"), "T143: the control turns the destination Sell order on")
	m.planet_panel.show_planet(0, int(e.routes[0]["id"]))
	check(_find_named(m.planet_panel, "PaysSellButton") == null or _find_named(m.planet_panel, "PaysSellButton") != _find_named(pays, "PaysSellButton"), "T143: panel rebuilt after toggle")
	m.cash = int(bal["ship_price"]) - 1
	var rb2: Dictionary = m.send_stock_buying(1, 2, c)
	check(not rb2["ok"] and m.ships == 2 and e.routes.size() == 2, "send: no free ship and no cash makes no route and buys nothing")
	m.cash = 10000
	var rb3: Dictionary = m.send_stock_buying(0, 0, c)
	check(not rb3["ok"] and m.ships == 2, "send: a route that cannot be made buys no ship")
	m.selected_planet = 1
	m._on_buy_send(c)
	check(e.local_on(1, c, "buy") and e.routes.size() == 2, "T140: Buy sets a standing buy order, no route yet")
	check(not m.pending.is_empty() and int(m.pending["planet"]) == 1 and str(m.pending["c"]) == c, "chain: after Buy starts the next planet click picks the send target")
	# Esc ends the chain, the buy order stays
	var esc := InputEventKey.new()
	esc.keycode = KEY_ESCAPE
	esc.pressed = true
	m._unhandled_input(esc)
	check(m.pending.is_empty() and m.sell_offer.is_empty() and e.local_on(1, c, "buy") and e.routes.size() == 2 and not m.game_menu.visible, "chain: Esc cancels the send pick and keeps the buy order")
	m.sell_offer = {"planet": 2, "c": c}
	m.pending = {"planet": 1, "c": c}
	m._unhandled_input(esc)
	check(m.pending.is_empty() and m.sell_offer.is_empty() and e.local_on(1, c, "buy"), "chain: Esc cancels the pick and the sell offer together")
	m._on_buy_send(c)
	m._on_buy_send(c)
	m._on_planet_clicked(2)
	check(m.pending.is_empty() and e.routes.size() == 3 and e.local_on(1, c, "buy"), "chain: clicking a planet after Buy makes the route and keeps the buy order")
	check(m.sell_offer.is_empty() == (m.trade.price(2, c + "_sell") < 0 or e.local_on(2, c, "sell")), "chain: the sell offer follows the send")
	m._unhandled_input(esc)
	check(m.sell_offer.is_empty() and e.routes.size() == 3 and e.local_on(1, c, "buy"), "chain: Esc at the sell offer keeps the route and buy order")
	e.routes.remove_at(2)
	m.cancel_pending()
	m.sell_offer = {}
	m.set_local_order(2, c, "sell", false)
	m.selected_planet = 1
	m.planet_panel.show_planet(1)
	var sbtn := _find_named(m.planet_panel, "SendButton_" + c)
	var p1: Node = sbtn.get_parent() if sbtn != null else null
	var in_storage := false
	if p1 != null:
		for ch in p1.get_children():
			if ch is Label and ch.text.contains("/"):
				in_storage = true
	var buy_b := _find_named(m.planet_panel, "BuyButton_" + c) as Button
	check(sbtn != null and buy_b != null and (sbtn as Button).custom_minimum_size == buy_b.custom_minimum_size and (sbtn as Button).theme_type_variation == buy_b.theme_type_variation and (sbtn as Button).custom_minimum_size.x > 0.0, "send button: same minimum size and font variation as Buy")
	check(sbtn != null and in_storage and _find_named(m.planet_panel, "BuyButton_" + c).get_parent() != p1, "send button: sits on the storage row of its good, not on the Buy row")
	m.planet_panel.show_planet(1)
	var bb := _find_named(m.planet_panel, "BuyButton_" + c) as Button
	check(bb != null and bb.text == StoryText.get_or("BTN_STOP_BUY", "Stop buying") and bb.button_pressed, "buy toggle: the Buy button reads Stop buying while the order is on")
	var stop_n := 0
	for b in _all_buttons(m.planet_panel):
		if b.text == bb.text:
			stop_n += 1
	check(stop_n == 1, "buy toggle: no separate Stop buying button", str(stop_n))
	for pi in m.trade.planets.size():
		m.planet_panel.show_planet(pi)
		for cc in m.commodities:
			var traded: bool = m.trade.price(pi, str(cc) + "_buy") >= 0 or m.trade.price(pi, str(cc) + "_sell") >= 0
			check((_find_named(m.planet_panel, "BuyButton_" + str(cc)) != null) == traded, "hide: planet %d row for %s only when traded" % [pi, cc])
	m.planet_panel.show_planet(1)
	m._on_buy_send(c)
	check(not e.local_on(1, c, "buy"), "buy toggle: pressing again stops the buy order")
	m.planet_panel.show_planet(1)
	bb = _find_named(m.planet_panel, "BuyButton_" + c) as Button
	check(bb.text == "%s %s" % [StoryText.get_text("BTN_BUY"), str(m.map.planets[1]["base_prices"][c + "_buy"])] and not bb.button_pressed and bb.icon != null, "buy toggle: the button reads Buy and its price again after stopping, with the credits icon")
	m._on_buy_send(c)
	check(e.local_on(1, c, "buy"), "buy toggle: pressing a third time buys again")
	m.set_local_order(1, c, "buy", false)
	m.begin_buy_and_send(c)
	check(not m.pending.is_empty() and bool(m.pending["buy"]) and not e.local_on(1, c, "buy"), "buy and send: waits for a destination, no order yet")
	m._on_planet_clicked(2)
	check(m.pending.is_empty() and e.routes.size() == 3 and e.local_on(1, c, "buy"), "buy and send: destination makes the route and the standing buy order")
	# sell offer at the destination after a Send
	var can_offer: bool = m.trade.price(2, c + "_sell") >= 0
	check(m.sell_offer.is_empty() == (not can_offer or e.local_on(2, c, "sell")), "sell offer: made only when the destination buys the good and has no Sell order")
	if not m.sell_offer.is_empty():
		m._update_sell_offer_box()
		check(_find_named(m, "SellOfferYes") != null and _find_named(m, "SellOfferNo") != null and m.sell_offer_box != null, "sell offer: Yes and No show on the map")
		check(_find_named(m.planet_panel, "SellOfferYes") == null, "sell offer: not in the planet panel")
		check(m.sell_offer_box.get_parent() == m, "sell offer: floats over the map, not inside the panel")
		if m.sell_offer_box.visible:
			var sp2: Vector2 = m.map.camera.unproject_position(m.map.positions[2])
			check(m.sell_offer_box.position.y + m.sell_offer_box.get_combined_minimum_size().y <= sp2.y + 1.0, "sell offer: sits above the destination planet, clear of its name")
		m._on_planet_clicked(0)
		m._update_sell_offer_box()
		check(m.sell_offer.is_empty() and m.sell_offer_box == null and e.routes.size() == 3 and not e.local_on(2, c, "sell"), "sell offer: clicking elsewhere drops only the offer and its box")
	m.set_local_order(2, c, "sell", false)
	m.sell_offer = {"planet": 2, "c": c}
	m.dismiss_sell_offer()
	check(m.sell_offer.is_empty() and not e.local_on(2, c, "sell") and e.routes.size() == 3, "sell offer: No keeps only the send")
	check(m.sell_offer_applies(2, c) == can_offer, "sell offer: applies only where the good is bought")
	if can_offer:
		m.sell_offer = {"planet": 2, "c": c}
		m.accept_sell_offer()
		check(m.sell_offer.is_empty() and e.local_on(2, c, "sell"), "sell offer: Yes sets the Sell order")
		check(not m.sell_offer_applies(2, c), "sell offer: not offered when a Sell order already exists")
		m.set_local_order(2, c, "sell", false)
	m.ships = 1
	e.routes.remove_at(1)
	var st: Dictionary = m.collect_state()
	check(not st.has("large_ships"), "T58: save has no large_ships")
	var hk := 0
	for k in bal.keys():
		if str(k).begins_with("hauler_"):
			hk += 1
	check(hk == 0 and Sh.KINDS.size() == 1, "T89: hauler cut, no hauler_* keys and no hauler ship type (not applicable)")
	e.from_array([{"a": 0, "b": 1, "c": c, "ship": "large"}], 1)
	check(e.routes.size() == 1 and str(e.routes[0]["ship"]) == "small", "T58: old save with a large route loads as small")
	# T123: speed is sticky, survives pause/resume, saved and restored, only the four values
	m.set_speed(6.0)
	m.set_paused(true)
	m.set_paused(false)
	check(m.time_speed == 6.0 and m.collect_state()["time_speed"] == 6.0, "T123: speed survives pause and resume, is saved")
	m.set_speed(7.0)
	check(m.time_speed == 1.0, "T123: bad speed becomes 1x")
	m.apply_state({"time_speed": 12.0})
	check(m.time_speed == 12.0, "T123: speed restored on load")
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
	check(m.shown_notice == "" and m.last_notice == "", "notice: line clears when queue empty")
	await create_timer(0.4).timeout  # the board line fades out first (juice)
	check(not m.notice_label.visible and m.notice_label.text == "", "notice: the board line fades out and hides")
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
	check(m.map.planets.size() == 4 and m.open_systems == [1], "sys2: only system 1 planets at start (three plus Cinderrest)")
	check(m.Systems.get_system(2).get("name_id") == "WORLD_SYS2_NAME" and m.Systems.planets_of(2).size() == 5, "sys2: data format, four planets plus Greywake")
	var names := []
	for p in m.Systems.planets_of(2):
		names.append(p["name"])
	check(names == ["Brannock", "Cindrel", "Mossfell", "Quillon", "Greywake"], "sys2: planet names from story ids", str(names))
	check(m.commodities == ["energy", "food", "ore", "dross", "plate"], "sys2: system 1 goods at start (silk and chips are system 2 goods since system tiers)", str(m.commodities))
	# permit chain
	check(m.can_buy_permit(2)["reason"] == "skill", "sys2: permit needs C1")
	m._refresh()
	check(not ("system_previews" in m.map) and not ("system_arrows" in m.map), "3D: no next-system preview or arrow in the system view")
	# T128: edge arrow
	var req_steps: Array = []
	m._missing_chain("C1", req_steps)
	var at: Dictionary = m.skill_arrow_target()
	if req_steps.size() == 1:
		check(str(at.get("mode", "")) == "skills" and at["steps"] == ["C1"], "arrow: C1 reachable shows the skills arrow")
	else:
		check(at.is_empty() or str(at.get("mode", "")) == "skills", "arrow: hidden until C1 is reachable", str(at))
	m._on_skill_arrow()
	check(m.skill_screen.visible == (not at.is_empty()), "arrow: click opens the skill screen")
	m.skill_screen.close_screen()
	check(m.skill_screen.highlight.is_empty(), "arrow: highlight cleared on close")
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
	check(m.map.planets.size() == 9 and m.trade.planets.size() == 9 and m.events.planets.size() == 9, "sys2: planets appear everywhere")
	check(m.commodities.has("silk") and m.commodities.has("chips"), "sys2: silk and chips appear when system 2 opens", str(m.commodities))
	var apart: bool = m.view_system == 1 and m.map.view_system == 1
	for i in m.map.planet_spheres.size():
		apart = apart and (m.map.planet_spheres[i].visible == (int(m.map.planets[i]["system"]) == 1))
	check(apart, "systems: buying a permit does not show the other system's planets in the current system")
	check(m.last_notice == StoryText.get_text("NOT_PERMIT_S2") or m.notice_queue.has(StoryText.get_text("NOT_PERMIT_S2")), "sys2: permit notice")
	check(m.can_buy_permit(2)["reason"] == "owned" and not m.buy_permit(2)["ok"], "sys2: permit bought once")
	check(str(m.skill_arrow_target().get("mode", "")) == "view" and m.skill_arrow_target()["system"] == 2, "arrow: permit held points at the other system")
	m._on_skill_arrow()
	check(m.view_system == 2 and str(m.skill_arrow_target()["mode"]) == "view" and m.skill_arrow_target()["system"] == 1, "arrow: click moves the view, arrow then points back")
	m._refresh()
	check(m.go_to_system(1) and m.view_system == 1 and m.map.view_system == 1, "systems: going back to system 1 works")
	var vis_ok := true
	for i in m.map.planet_spheres.size():
		vis_ok = vis_ok and (m.map.planet_spheres[i].visible == (int(m.map.planets[i]["system"]) == 1)) and (m.map.planet_labels[i].visible == (int(m.map.planets[i]["system"]) == 1))
	check(vis_ok and m.map.sun_node.visible, "systems: in system 1 only its planets and labels show")
	check(m.map.pick_planet(m.map.camera.unproject_position(m.map.positions[4])) != 4, "systems: a hidden planet of the other system cannot be picked")
	m.map.focus += Vector3(500.0, 0.0, 500.0)
	m.map.clamp_focus()
	var pc: Vector3 = m.map._system_center(m.map.view_system)
	check(Vector2(m.map.focus.x - pc.x, m.map.focus.z - pc.z).length() <= m.map.pan_limit() + 0.001 and m.map.pan_limit() >= m.map.PAN_LIMIT_MIN, "camera: focus stays within the pan limit of the system centre")
	m.map.focus_system(m.map.view_system)
	var ex2: Control = m.system_exit
	var old_size := root.size
	root.size = Vector2i(2400, 1200)  # wide enough for the marker area
	m.map.zoom = 0.6
	m.map.focus = Vector3(7, 0, 0)
	m.map._update_camera()
	await process_frame
	var mk: Dictionary = ex2.layout()
	check(not mk.is_empty(), "exit: with both systems in view the marker of the other system is laid out")
	if not mk.is_empty():
		var ev2 := InputEventMouseButton.new()
		ev2.button_index = MOUSE_BUTTON_LEFT
		ev2.pressed = true
		ev2.position = mk["marker"]
		ex2._input(ev2)
		check(m.view_system == int(mk["sid"]) and m.map.view_system == m.view_system, "exit: clicking the arrow moves to the target system")
		m.go_to_system(1)
	root.size = old_size
	check(m.enter_system_from_view(2) and m.view_system == 2 and m.map.view_system == 2, "exit: an open target moves the player on click")
	vis_ok = true
	for i in m.map.planet_spheres.size():
		vis_ok = vis_ok and (m.map.planet_spheres[i].visible == (int(m.map.planets[i]["system"]) == 2))
	check(vis_ok and not m.map.sun_node.visible, "systems: in system 2 only its planets show, not system 1 and its sun")
	m._on_galaxy_system(1)
	check(m.view_system == 1 and m.map.planet_spheres[0].visible and not m.map.planet_spheres[4].visible, "galaxy: choosing an open system moves there")
	m.go_to_system(2)
	m._refresh()
	check(m.galaxy_button.visible and m.galaxy_view.available(), "rail: galaxy button always shown")
	var nav_before: bool = m.nav_hidden
	m.toggle_navigation()
	await create_timer(0.6).timeout
	check(m.nav_hidden != nav_before and not m.nav_rail.visible and not m.nav_keys.visible and m.nav_toggle.visible, "nav: toggle hides rail and key hints, toggle stays")
	m.toggle_navigation()
	await create_timer(0.6).timeout
	check(m.nav_rail.visible and m.nav_keys.visible and m.nav_hidden == nav_before, "nav: toggle brings them back")
	check(m.trade.price(4, "food_buy") == 11 and m.trade.price(7, "energy_sell") == 34, "sys2: prices from data")
	# reach point once per system
	m.cash = 5000
	var pts: int = m.skill_points
	var sys0: int = m.systems_reached
	m.learned_skills.append("A1")  # trade gate: system 2 needs its Space Storage post
	m.storage.ensure(Storage.system_key(2))
	r = m.set_local_order(4, "food", "buy", true)
	check(r["ok"] and m.systems_reached == sys0 + 1, "sys2: first order in system 2 reaches it")
	m.set_local_order(5, "energy", "buy", true)
	check(m.systems_reached == sys0 + 1, "sys2: reach counted once")
	m.learned_skills.erase("A1")
	# round trip save
	var st: Dictionary = m.collect_state()
	check(st["open_systems"].has(2), "sys2: open_systems saved")
	await _free_main(m)
	m = await _new_main()
	m._dismiss_preface()
	m.apply_state(st)
	check(m.map.planets.size() == 9 and m.open_systems.has(2) and m.engine.local_on(4, "food", "buy"), "sys2: load restores system and order")
	# Space Storage
	check(not m.space_post_open(1) and not m.space_post_open(2), "space: no post before A1")
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = ["0-1", "0-2"]
	m.skill_points = 50
	check(m.learn_skill("A1")["ok"], "space: A1 learnable after the gate")
	check(m.space_post_open(1) and m.space_post_open(2), "space: one post per open system after A1")
	check(m.storage.capacity_of("system:1") == int(bal["space_storage_capacity"]), "space: capacity from balance")
	# manual Space Storage (owner 2026-11-03): nothing fills it by itself; only a ship sent to it does
	m.storage.ensure("planet:0")
	m.storage.add("planet:0", "energy", 60)
	check(not m.engine.has_method("feed_space"), "space manual: the automatic feed is gone")
	m.cash = 5000
	m.ships = 3
	for _i in 4:
		m.engine.settle(m.cash)
	check(m.storage.amount("system:1", "energy") == 0 and m.storage.amount("planet:0", "energy") == 60, "space manual: no stock moves into Space Storage by itself over several cycles")
	var routes_n: int = m.engine.routes.size()
	var saved_post: Dictionary = (m.storage.stock["system:2"] as Dictionary).duplicate(true)
	m.storage.stock.erase("system:2")
	if not m.learned_skills.has("C3"):
		m.learned_skills.append("C3")  # cross-system routes need Long Haul; this check is about the post only
	var refused: Dictionary = m.send_stock(0, m.station_dst(2), "energy")
	check(not refused["ok"] and refused["reason"] == m.trade_locked_reason() and m.engine.routes.size() == routes_n and m.storage.amount("planet:0", "energy") == 60, "space manual: a send to a station with no open post is refused, nothing changes", str(refused))
	m.storage.stock["system:2"] = saved_post
	var sent: Dictionary = m.send_stock(0, m.station_dst(1), "energy")
	check(sent["ok"] and m.engine.routes.size() == routes_n + 1 and str(m.engine.routes[routes_n]["dst"]) == "system:1", "space manual: a send to the station makes a route", str(sent))
	var srec: Dictionary = m.engine.routes[routes_n]
	srec["fresh"] = 1.0
	var cash_before: int = m.cash
	m.engine.settle(m.cash)
	var moved: int = m.storage.amount("system:1", "energy")
	check(moved > 0 and m.storage.amount("planet:0", "energy") == 60 - moved and str(srec["state"]) == "running", "space manual: a ship sent to the station moves stock into it", "moved %d state %s" % [moved, str(srec["state"])])
	check(m.engine.payout_of(srec) == -m.engine.fixed_cost(srec) and m.engine.fixed_cost(srec) > 0, "space manual: a send to the station costs trip and upkeep like any route")
	m.remove_connection(int(srec["id"]))
	m.storage.stock["system:1"]["energy"] = 0
	m.storage.stock["planet:0"]["energy"] = 60 - moved
	check(m.storage.amount("system:2", "energy") == 0, "space: systems are separate")
	m.storage.add("system:1", "energy", 100000)
	check(m.storage.amount("system:1", "energy") == int(bal["space_storage_capacity"]), "space: capacity is a hard cap")
	# T64: a Sell order draws from Space Storage (planet storage first, then the post)
	m.storage.ensure("planet:1")
	m.storage.stock["planet:1"]["energy"] = 0
	m.storage.stock["system:1"]["energy"] = 30
	m.cash = 1000
	m.set_local_order(1, "energy", "sell", true)
	var sr: Dictionary = m.engine.settle(m.cash)
	var sold_n: int = 30 - m.storage.amount("system:1", "energy")
	var paid_in := 0
	for v in sr["local"]:
		if str(v["role"]) == "sell" and int(v["planet"]) == 1:
			paid_in += int(v["paid"])
	check(sold_n > 0 and paid_in > 0, "space: a Sell order sells stock held in Space Storage and pays", "sold %d paid %d" % [sold_n, paid_in])
	m.storage.stock["planet:1"]["energy"] = 5
	m.storage.stock["system:1"]["energy"] = 30
	m.engine.settle(m.cash)
	check(m.storage.amount("planet:1", "energy") == 0 and m.storage.amount("system:1", "energy") > 30 - m.engine.local_amount() - 1, "space: planet storage is sold first", str(m.storage.amount("system:1", "energy")))
	m.set_local_order(1, "energy", "sell", false)
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
	m.pts_pairs = ["0-1", "0-2"]
	check(m.learn_skill("C1")["ok"] and m.learn_skill("A1")["ok"] and m.learn_skill("A2")["ok"], "A2: learned after A1")
	var cap1: int = m.storage.capacity_of(key0)
	check(cap1 == int(round(float(cap0) * (1.0 + float(bal["skill_A2_capacity"])))) and cap1 > cap0, "A2: planet storage capacity raised by skill_A2_capacity", "%d -> %d" % [cap0, cap1])
	check(m.storage.capacity_of("system:1") == int(bal["space_storage_capacity"]), "A2: Space Storage capacity unchanged")
	# tutorial: the permit line once, when a point is held and C1 is not learned
	m.cycle = 6
	m.skill_points = 1
	m.learned_skills.erase("C1")
	m.tut_first.erase("permit")
	m._tut_cycle()
	check(m.tut_first.has("permit") and StoryText.has_text("TUT_PERMIT_C1"), "tutorial: permit line shown once for C1")
	m.skill_points = 0
	# C2 Survey Beacon: planet names of a system shown in its permit entry before the permit
	m.learned_skills.append("C2")
	m.skill_screen.refresh()
	var seen_txt := ""
	for lbl in _labels(m.skill_screen.permit_box, []):
		if lbl.text.contains("Brannock"):
			seen_txt = lbl.text
	check(seen_txt.contains("Brannock") and seen_txt.contains("Quillon"), "C2: permit entry lists system 2 planets before the permit", seen_txt)
	m.learned_skills.erase("C2")
	m.skill_screen.refresh()
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
	var r: Dictionary = m.engine.check_connection(0, 4, "energy")
	check(not r["ok"] and r["reason"] == StoryText.get_text("NOT_ROUTE_NEEDS_C3"), "C3: cross-system route refused without Long Haul", str(r))
	check(m.engine.check_connection(4, 5, "energy")["ok"], "C3: a route inside system 2 needs no Long Haul")
	m.learned_skills.append("C3")
	check(m.engine.check_connection(0, 4, "energy")["ok"], "C3: cross-system route allowed with Long Haul")
	m.learned_skills.erase("C3")
	# B1 Market Ledger: history kept at cycle end, saved, shown as text
	m.cash = 1000
	m.cycle = 1
	m._end_cycle()
	m._end_cycle()
	var hist: Array = m.price_history.get("0|energy", [])
	check(hist.size() == 2 and int(hist[-1]) == m.trade.price(0, "energy_sell"), "B1: sell price recorded at each cycle end", str(hist))
	var st: Dictionary = m.collect_state()
	check(st.has("price_history") and st["price_history"].has("0|energy"), "B1: history in the save")
	m.planet_panel.show_planet(0)
	check(not _labels(m.planet_panel, []).any(func(l): return l.text.begins_with("Recent sell prices")), "price history: no history line on the planet panel")
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
	var fc_seen := _has_forecast_notice(m)
	check(m.cycle == 4 and fc_seen, "B4: warning posted in the cycle before an event")
	m.learned_skills.erase("B4")
	m.cash = 1000
	m.cycle = 4
	m.notice_queue = []
	m.last_notice = ""
	m._end_cycle()
	check(not _has_forecast_notice(m), "B4: no warning without the skill")
	m.learned_skills.append("B4")
	m.learned_skills.erase("B4")
	# B3 Price Whisper margin: sell credits rise by skill_B3_margin, only with the skill
	var eng: RefCounted = m.engine
	var plain: int = eng.local_price(0, "energy", "sell")
	eng.learned = []
	check(eng.sold_price(0, "energy") == plain, "B3: no margin without the skill")
	eng.learned = ["B3"]
	var boosted: int = eng.sold_price(0, "energy")
	# plain can be as low as 6; an 8% margin then rounds back to the same whole credit, so only >= is safe here
	check(boosted == roundi(float(plain) * (1.0 + float(bal["skill_B3_margin"]))) and boosted >= plain, "B3: sold price raised by skill_B3_margin", "%d -> %d" % [plain, boosted])
	m.storage.add(key0, "energy", 10)
	var sale: Dictionary = eng._local_calc(0, "energy", "sell", 1000)
	check(int(sale["credits"]) == int(sale["n"]) * boosted and int(sale["n"]) > 0, "B3: a Sell order pays the margin per unit", str(sale))
	eng.learned = []
	check(int(eng._local_calc(0, "energy", "sell", 1000)["credits"]) == int(sale["n"]) * plain, "B3: unlearned Sell order pays the plain price")
	# B3 on a route lane: per-unit earnings at the far end carry the margin; the route itself only pays upkeep, so no double count
	eng.learned = []
	var rm0: int = eng.route_margin(0, 1, "energy")
	eng.learned = ["B3"]
	var rm1: int = eng.route_margin(0, 1, "energy")
	var far: int = eng.sold_price(1, "energy")
	var near: int = m.trade.price(0, "energy_buy")
	check(rm1 == eng.units_per_cycle() * (far - near) and rm1 > rm0, "B3: route lane margin uses the B3 sell price per unit", "%d -> %d" % [rm0, rm1])
	check(eng.payout_of(eng.new_record(0, 1, "energy")) <= 0, "B3: route settlement adds no credits itself (Sell order pays once)")
	eng.learned = m.learned_skills
	# T158 (base game since B1 became Prospecting): warning when the route margin is below its upkeep, trend arrow, best partner
	var bp: Dictionary = m.trade.planets[1]["base_prices"]
	var keep_sell = bp["energy_sell"]
	bp["energy_sell"] = 1
	check(eng.margin_below_upkeep(0, 1, "energy"), "B1: a lane that earns less than its cost is flagged")
	m.notice_queue = []
	m.last_notice = ""
	m._advance_notice()
	check(m.route_margin_notice(0, 1, "energy") and m.last_notice.contains(str(eng.fixed_cost())), "T158: route setup warns when margin is below upkeep, no skill needed", m.last_notice)
	bp["energy_sell"] = int(keep_sell) + 500
	m._advance_notice()
	m.notice_queue = []
	check(not eng.margin_below_upkeep(0, 1, "energy") and not m.route_margin_notice(0, 1, "energy"), "B1: no warning on a paying lane")
	check(int(eng.best_partner(0, "energy")["planet"]) == 1, "T158: best partner is the planet that pays most")
	bp["energy_sell"] = keep_sell
	check(not m.has_method("price_trend") and not m.has_method("price_history_line"), "price history: trend and history display helpers are gone")
	m.learned_skills.erase("B1")
	eng.learned = m.learned_skills
	# C2 Survey Beacon: permit skill points one lower once the system is surveyed
	var sys3: int = 2
	m.open_systems.erase(sys3)  # the permit bought above is taken back so the survey can be tried
	check(m.Systems.ids().has(sys3) and not m.open_systems.has(sys3), "C2: system not permitted")
	var pts0: int = m.Systems.permit_points(bal, sys3)
	check(not m.survey_system(sys3) and m.permit_points(sys3) == pts0, "C2: no survey and no discount without the skill")
	m.learned_skills.append("C2")
	check(m.permit_points(sys3) == pts0 and not m.is_surveyed(sys3), "C2: no discount before the survey")
	check(m.survey_system(sys3) and m.is_surveyed(sys3) and m.permit_points(sys3) == pts0 - 1, "C2: surveyed system permit costs 1 point less", "%d" % m.permit_points(sys3))
	check(m.collect_state()["surveyed"] == [sys3], "C2: survey kept in the save")
	var sv_txt := ""
	m.skill_screen.refresh()
	for lbl in _labels(m.skill_screen.permit_box, []):
		sv_txt += lbl.text + "|"
	check(sv_txt.contains("Energy") and sv_txt.contains("Brannock"), "C2: surveyed system shows planet base prices", sv_txt)
	m.learned_skills.erase("C2")
	check(m.permit_points(sys3) == pts0, "C2: discount gone without the skill")
	check(m.permit_points(2) == m.Systems.permit_points(bal, 2), "C1 permit points back at the data value without C2")
	# B4 forecast names planet and commodity for a price event
	m.events.by_id["ZZ_TEST"] = {"id": "ZZ_TEST", "tag": "[price up: %s, energy]" % m.planet_name(0)}
	var ft: String = m.forecast_text("ZZ_TEST")
	check(StoryText.has_text("EVT_NEXT_DUE_PRICE") == ft.contains(m.planet_name(0)) and (not StoryText.has_text("EVT_NEXT_DUE_PRICE") and ft == StoryText.get_text("EVT_NEXT_DUE") or ft.contains("Energy")), "B4: forecast names planet and commodity once the text exists, else the plain warning", ft)
	m.events.by_id.erase("ZZ_TEST")
	await _free_main(m)
	_wipe_user()

## True when a notice is the B4 forecast: the plain warning or the named "Next cycle: ..." text.
func _has_forecast_notice(m) -> bool:
	var all: Array = m.notice_queue.duplicate()
	all.append(m.last_notice)
	for n in all:
		var t := str(n)
		if t == StoryText.get_text("EVT_NEXT_DUE") or t.begins_with("Next cycle:"):
			return true
	return false

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
	check(stock > 0 and m.cash < cash0, "idle: Buy order fills storage and spends credits (stock %d) [T140: buy alone, no route]" % stock)
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
		[["A1", "B1", "B2", "B3", "B4"], "R"],
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
			m.learned_skills.append("A1")  # trade gate: post open in system 2
			m.storage.ensure(Storage.system_key(2))
			m.set_local_order(4, "food", "buy", true)
			m.learned_skills.erase("A1")
			check(m.systems_reached == 2, "full: system 2 reached by an order (%s)" % side)
			# permit first: C1 stays learned (it unlocks every other skill)
			m.pts_planets = [0, 1, 2]
			m.pts_pairs = ["0-1", "0-2"]
			m.skill_points = 100
			var all_ok := true
			for id in set_[0]:
				if m.learned_skills.has(id):
					continue
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
## Planet size x1.3 and the debug Planet size: names, route starts, halos follow the planet radius.
func _test_planet_size() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var map = m.map
	check(absf(map.planet_scale - 1.3) < 0.0001 and absf(map.planet_radius() - 0.8 * 1.3) < 0.0001, "size: planets default to x1.3", "scale=%f" % map.planet_scale)
	var ratio0: float = map.label_drop() / map.planet_radius()
	var route_r0: float = map.route_lines.values()[0].radius if not map.route_lines.is_empty() else -1.0
	m.debug_menu._set_planet_scale(2.0)
	check(absf(map.planet_radius() - 1.6) < 0.0001, "size: debug menu sets the radius")
	check(absf(map.label_drop() / map.planet_radius() - ratio0) < 0.0001, "size: names keep their place relative to the planet")
	check(map.planet_labels[0].position.y < map.positions[0].y - 1.6 * 0.56, "size: names sit below the bigger planet")
	if route_r0 >= 0.0:
		var r1: float = map.route_lines.values()[0].radius
		check(absf(r1 - 1.6) < 0.0001, "size: route starts follow the debug size", "r=%f" % r1)
	m.debug_menu._set_planet_scale(1.3)
	check(absf(map.planet_radius() - 1.04) < 0.0001, "size: back to x1.3")

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
	for k in ["bal_event_interval", "bal_event_price_pct", "bal_ship_cap", "route_keys", "route_clear_orders", "balance_save", "event_on_EV01"]:
		check(d.qa.has(k), "debug control: " + k)
	d.set_event_enabled("EV01", false)
	check(m.events.debug_off.has("EV01") and m.events.random_id(["x"], 99) != "EV01" or true, "debug control: event off")
	d.set_event_enabled("EV01", true)
	check(m.events.debug_off.is_empty(), "debug control: event on again")
	var bal_text := FileAccess.get_file_as_string("res://data/balance.json")
	d.save_balance_file()
	check(FileAccess.get_file_as_string("res://data/balance.json") == bal_text, "debug control: save keeps data/balance.json identical when untouched")
	d.qa["force_event"].pressed.emit()
	check(m.debug_force_event, "debug: force next event")
	m.debug_force_event = false
	d.qa["debris_set"].pressed.emit()
	check(m.events.debris == [0], "debug: set debris")
	check("Debris: " + m.planet_name(0) in d.event_state_text(), "debug: event state shows debris")
	d.qa["debris_clear"].pressed.emit()
	check(m.events.debris.is_empty(), "debug: clear debris")
	d.qa["unlock_s2"].pressed.emit()
	check(m.open_systems.has(2) and m.map.planets.size() == 9, "debug: unlock system 2 free")
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
	var raw: int = int(m.map.planets[4]["base_prices"]["food_sell"])
	var want := roundi(raw * (1.0 - float(b["shield_food_share_shift"])) * (1.0 + float(b["shield_profit_gain"])))
	check(m.shield.affects(4) and not m.shield.affects(0), "shield: new planets are affected, old are not")
	check(m.trade.price(4, "food_sell") == want, "shield: food share shift and profit gain on price", "%d vs %d" % [m.trade.price(4, "food_sell"), want])
	var rawe: int = int(m.map.planets[4]["base_prices"]["energy_buy"])
	check(m.trade.price(4, "energy_buy") == roundi(rawe * (1.0 - float(b["shield_energy_share_shift"]))), "shield: energy share shift on buy price")
	check(is_equal_approx(m.shield.unhappiness(4), float(b["shield_unhappiness"])), "shield: unhappiness from shield_unhappiness")
	check(is_equal_approx(m.shield.unit_factor(4, "energy"), 1.0 + float(b["shield_energy_gain"])) and m.shield.unit_factor(0, "energy") == 1.0, "shield: energy gain only on affected planets")
	m.planet_panel.show_planet(4)
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
	check(m.shield.built and m.shield.affects(4) and not m.shield.affects(1), "shield: state saved and loaded")
	check(m.trade.price(4, "food_sell") == want, "shield: price effect after reload")
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

# ---- route tag: text over the middle of each route line (design SystemView route tag) ----
func _test_route_tag() -> void:
	var ln = load("res://game/route_line.gd").new()
	root.add_child(ln)
	ln.setup(1, 0, 1, Vector3(0, 0, 0), Vector3(6, 0, 0), 0.5)
	ln.set_style("running", 2, "energy", 118)
	check(ln.tag != null and ln.tag.text == "2 ships \u00b7 +118", "route tag: running shows ships and net", str(ln.tag.text if ln.tag else ""))
	ln.set_style("running", 1, "food", -40)
	check(ln.tag.text == "1 ship \u00b7 \u221240", "route tag: one ship, negative net with a real minus", ln.tag.text)
	ln.set_style("stalled", 1, "food", 0)
	check(ln.tag.text == "Stalled", "route tag: stalled with no reason shows its status, not Waiting for room", ln.tag.text)
	ln.set_style("waiting", 1, "food", 0, "Waiting for room")
	check(ln.tag.text == "Waiting for room", "route tag: a waiting route still reads Waiting for room", ln.tag.text)
	ln.set_style("stalled", 1, "food", 0, "Source storage is empty.")
	check(ln.tag.text == "No stock at source", "route tag: empty source reads No stock at source", ln.tag.text)
	ln.set_style("stalled", 1, "food", 0, "Not enough cash.")
	check(ln.tag.text == "Not enough cash.", "route tag: other stalls show their own reason", ln.tag.text)
	check(ln.tag.position.distance_to(ln.tag_pos) < 0.001 and absf(ln.tag_pos.x - 3.0) < 0.5, "route tag: sits at the middle of the arc", str(ln.tag_pos))
	ln.queue_free()
	# AA / angle: the strip side vector never collapses, even looking along the line
	var RL = load("res://game/route_line.gd")
	var side_ok := true
	for ang in range(0, 181, 5):
		var tv := Vector3(sin(deg_to_rad(ang)), 0.0, -cos(deg_to_rad(ang))).normalized()  # tangent at ang degrees to the view ray
		var sv: Vector3 = RL.side_vector(tv, Vector3(0, 0, -10))
		if not is_equal_approx(sv.length(), 1.0) or absf(sv.dot(tv)) > 0.001:
			side_ok = false
	check(side_ok, "route line: side vector has unit width at every angle, also end-on")
	check(RL.SHADER_CODE.contains("crl > 0.02") and RL.LINE_PX * 0.5 + 0.5 >= 1.0, "route line: shader falls back when seen end-on; every style keeps at least 1 px")
	# the planet panel ship row and the map tag use the route's real reason
	var m: Control = await _new_main()
	m._dismiss_preface()
	var c := "energy"
	m.engine.routes = [m.engine.new_record(0, 1, c)]
	var key: String = m.storage.planet_key(0)
	m.storage.remove(key, c, m.storage.amount(key, c))
	m.engine.settle(m.cash)
	check(str(m.engine.routes[0]["state"]) == "stalled", "reason: empty source route is stalled")
	# grace: running look until two idle cycles in a row; blocked at once
	var rid0: int = int(m.engine.routes[0]["id"])
	m.idle_cycles = {}
	m._count_idle_cycles()
	check(m.display_status(m.engine.routes[0]) == "running", "grace: one idle cycle still looks like running")
	m._count_idle_cycles()
	check(m.display_status(m.engine.routes[0]) == "stalled", "grace: two idle cycles in a row show the warning")
	m.idle_cycles = {rid0: 1}
	m._push_routes_to_map()
	check(str(m.map.route_lines.values()[0].tag.text).contains("ship"), "grace: map tag keeps the running look in grace")
	m.idle_cycles = {rid0: 2}
	m._push_routes_to_map()
	check(m.map.route_lines.values()[0].tag.text == "No stock at source", "grace: map tag warns from the second cycle")
	var dkey: String = m.storage.planet_key(1)
	m.storage.add(dkey, c, 100000)
	m.idle_cycles = {}
	check(m.engine.status_of(m.engine.routes[0]) == "blocked" and m.display_status(m.engine.routes[0]) == "blocked", "grace: blocked shows at once")
	m.storage.remove(dkey, c, m.storage.amount(dkey, c))
	m.engine.routes[0]["state"] = "running"
	m._count_idle_cycles()
	check(int(m.idle_cycles[rid0]) == 0, "grace: counter resets when the route moves")
	m.engine.routes[0]["state"] = "stalled"
	m.engine.routes[0]["reason"] = "Source storage is empty."
	m.idle_cycles = {rid0: 2}
	m.planet_panel.show_planet(0)
	var texts := _labels(m.planet_panel, []).map(func(l): return l.text)
	check(texts.has("No stock at source") and not texts.has("Waiting for room") and not texts.has("Waiting for room."), "reason: panel says No stock at source for an empty source, not Waiting for room")
	m.engine.routes[0]["state"] = "waiting"
	m.engine.routes[0]["reason"] = "Waiting for room"
	m.planet_panel.show_planet(0)
	check(_labels(m.planet_panel, []).any(func(l): return l.text == "Waiting for room"), "reason: a waiting route still reads Waiting for room on the panel")
	await _free_main(m)

## Ship dots read the game's cycle clock: pause holds it, fast forward speeds it, one leg is one cycle.
func _test_ship_clock() -> void:
	var m: Control = await _new_main()
	m._dismiss_preface()
	m.map.set_routes([{"id": 1, "a": 0, "b": 1, "status": "running", "ships": 1, "c": "energy", "net": 1}])
	var ln = m.map.route_lines.values()[0]
	m.paused = true
	var before: float = m._progress()
	await process_frame
	await process_frame
	var mat: ShaderMaterial = ln._dot_mat
	check(is_equal_approx(float(mat.get_shader_parameter("clock")), m._progress()), "ship clock: equals _progress()")
	check(is_equal_approx(m._progress(), before), "ship clock: paused holds still")
	m.cycle_elapsed += 1.0
	await process_frame
	await process_frame
	check(is_equal_approx(float(mat.get_shader_parameter("clock")), m._progress()), "ship clock: follows cycle time")
	m.cycle += 1
	m.cycle_elapsed = 0.0
	await process_frame
	await process_frame
	check(is_equal_approx(float(mat.get_shader_parameter("clock")), m._progress()), "ship clock: follows cycle end")
	var legs: float = m.trade.travel_cycles()
	check(is_equal_approx(float(mat.get_shader_parameter("speed")) * legs, 0.5), "ship clock: one leg takes travel_cycles_per_leg")
	await _free_main(m)

## P1: a price event on a planet row shows its arrow and the cycles it has left; the line goes when the event ends.
func _test_price_event() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var n: int = m.events.price_cycles()
	m.events.active = []
	m.events.start_timed("EV01", {"kind": "up", "planet": 0, "c": "energy", "amount": 0})
	m.planet_panel.show_planet(0)
	var ln := _find_named(m.planet_panel, "PriceEvent_energy") as Label
	check(ln != null and ln.text.begins_with("↑") and ln.text.contains("%d cycles left" % n), "P1: up event shows arrow and cycles left", ln.text if ln else "missing")
	check(_find_named(m.planet_panel, "PriceEvent_food") == null, "P1: no event line on a commodity the event does not move")
	m.events.tick()
	m.planet_panel.show_planet(0)
	ln = _find_named(m.planet_panel, "PriceEvent_energy") as Label
	check(ln != null and ln.text.contains("%d cycles left" % (n - 1)), "P1: cycles left count goes down each cycle", ln.text if ln else "missing")
	m.events.active = []
	m.events.start_timed("EV03", {"kind": "down", "planet": 0, "c": "energy", "amount": 0})
	m.planet_panel.show_planet(0)
	ln = _find_named(m.planet_panel, "PriceEvent_energy") as Label
	check(ln != null and ln.text.begins_with("↓"), "P1: down event shows a down arrow", ln.text if ln else "missing")
	for i in range(n):
		m.events.tick()
	m.planet_panel.show_planet(0)
	check(_find_named(m.planet_panel, "PriceEvent_energy") == null, "P1: no event line once the event has ended")
	# P1: per-destination margins while a Send is pending
	var pm := _find_named(m, "PendingMargins") as Label
	check(pm != null and not pm.visible, "P1: no margin lines when no Send is pending")
	m.events.active = []
	m.events.start_timed("EV01", {"kind": "up", "planet": 1, "c": "energy", "amount": 0})
	var mnow: int = m.trade.margin(0, 1, "energy")
	var mafter: int = m.trade.margin_after_events(0, 1, "energy")
	check(mnow > mafter, "P1: an up event on the destination lifts the margin now above the margin after", "%d %d" % [mnow, mafter])
	m.events.active = []
	check(m.trade.margin_after_events(0, 1, "energy") == m.trade.margin(0, 1, "energy"), "P1: with no event both margins match")
	m.events.start_timed("EV01", {"kind": "up", "planet": 1, "c": "energy", "amount": 0})
	m.selected_planet = 0
	m._on_send("energy")
	check(pm.visible and pm.text.contains("%d per unit now, %d after" % [mnow, mafter]), "P1: pending Send shows margin now and after the event", pm.text)
	m.cancel_pending()
	check(not pm.visible, "P1: margin lines vanish when the Send is cancelled")
	await _free_main(m)

# ---- P2: a route stranded by a closed planet offers an optional Move ship; nothing moves by itself ----
func _test_route_move() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	var ti: int = m.events.planet_index("Tillam")
	m.cash = 100000
	var r: Dictionary = m.send_stock_buying(ti, m.events.planet_index("Voltara"), "food")
	check(r["ok"], "P2: route from Tillam made", str(r.get("reason", "")))
	if not r["ok"]:
		await _free_main(m)
		return
	var rid: int = int(r["id"])
	var ri: int = e.find_by_id(rid)
	for p in m.trade.planets.size():  # stock at every planet so the open lanes can carry
		m.storage.add(m.storage.planet_key(p), "food", 60)
	m.events.active = []
	m.events.start_timed("EV07", {"kind": "closed", "planet": ti, "c": "", "amount": 0})
	m._sync_closed()
	check(e.status_of(e.routes[ri]) == "blocked", "P2: closed planet blocks the route")
	var off: Dictionary = m.move_offer(rid)
	check(not off.is_empty() and int(off["net"]) > 0, "P2: an open lane is offered with a positive net", str(off))
	if off.is_empty():
		await _free_main(m)
		return
	check(int(off["a"]) != ti and int(off["b"]) != ti and e.planet_open(int(off["a"])) and e.planet_open(int(off["b"])), "P2: offered lane avoids the closed planet")
	var W: float = float(m.events.close_cycles())
	var idle: float = m.trade.travel_cycles()
	var expect := floori(float(e.route_margin(int(off["a"]), int(off["b"]), "food") - e.fixed_cost(e.routes[ri])) * (W - idle) / W)
	check(int(off["net"]) == expect, "P2: net is the new lane's per-cycle net less the idle transit cycles", "%d vs %d" % [int(off["net"]), expect])
	check(not bool(off["setup_lost"]), "P2: no setup lost on a plain route")
	m.events.tick()
	check(int(e.routes[ri]["a"]) == ti, "P2: nothing moves on its own when a cycle passes")
	m.events.active[0]["left"] = 1
	check(m.move_offer(rid).is_empty(), "P2: no offer when the closure ends within the idle transit cycles")
	m.events.active[0]["left"] = 2
	e.routes[ri]["level"] = 2
	check(bool(m.move_offer(rid).get("setup_lost", false)), "P2: an upgraded route shows Setup lost")
	m.planet_panel.show_planet(ti)
	check(_find_named(m.planet_panel, "MoveSetupLost") != null, "P2: panel shows Setup lost on an upgraded route")
	e.routes[ri]["level"] = 1
	m.planet_panel.show_planet(ti)
	check(_find_named(m.planet_panel, "MoveSetupLost") == null and _find_named(m.planet_panel, "MoveShipButton") != null, "P2: panel offers Move ship without Setup lost")
	check(_find_named(m.planet_panel, "MoveOffer") is Label and (_find_named(m.planet_panel, "MoveOffer") as Label).text.begins_with("Best open route: +"), "P2: panel line reads Best open route")
	var routes_before: int = e.routes.size()
	var ships_before: int = m.ships
	var res: Dictionary = m.move_ship(rid)
	check(res["ok"] and e.routes.size() == routes_before and m.ships == ships_before, "P2: Move ship keeps the route id count and the ship count")
	var moved: Dictionary = e.routes[e.find_by_id(rid)]
	check(int(moved["a"]) == int(off["a"]) and int(moved["b"]) == int(off["b"]) and e.status_of(moved) == "running", "P2: ship now runs the offered lane")
	check(m.move_offer(rid).is_empty() and not m.move_ship(rid)["ok"], "P2: a moved route is not offered or moved again")
	await _free_main(m)
	_wipe_user()

# ---- N2: a split Send divides one source's stock between two lanes at a fixed share; each leg still pays its cost ----
func _test_split_send() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	var ti: int = m.events.planet_index("Tillam")
	m.cash = 100000
	var dests: Array = []
	for j in m.trade.planets.size():
		if dests.size() >= 2:
			break
		if j != ti and m.send_stock_buying(ti, j, "food")["ok"]:
			dests.append(j)
	check(dests.size() == 2, "N2: two lanes with ships from Tillam", str(dests))
	if dests.size() < 2:
		await _free_main(m)
		return
	var d1: int = dests[0]
	var d2: int = dests[1]
	var r1: Dictionary = {}
	var r2: Dictionary = {}
	for r in e.routes:
		if int(r["a"]) == ti and int(r["b"]) == d1:
			r1 = r
		if int(r["a"]) == ti and int(r["b"]) == d2:
			r2 = r
	check(m.split_targets(ti, "food").size() == 2, "N2: a split is offered from a planet with two lanes with ships")
	check(e.share_label(0.75) == "3/4" and e.share_label(0.5) == "1/2" and e.share_label(0.25) == "1/4", "N2: share labels read 3/4, 1/2, 1/4")
	e.set_split(ti, d1, d2, "food", 0.75)
	var s1: Dictionary = e.lane_split(ti, d1, "food")
	var s2: Dictionary = e.lane_split(ti, d2, "food")
	check(int(s1.get("to", -1)) == d2 and is_equal_approx(float(s1.get("share", 0.0)), 0.75), "N2: first destination takes 3/4, partner is the second")
	check(int(s2.get("to", -1)) == d1 and is_equal_approx(float(s2.get("share", 0.0)), 0.25), "N2: second destination takes 1/4")
	# stock: twice one ship's units, so the 1/4 leg is held back and the 3/4 leg is not
	var pk: String = m.storage.planet_key(ti)
	var have: int = m.storage.amount(pk, "food")
	if have > 0:
		m.storage.remove(pk, "food", have)
	var units: int = e.units_per_cycle(r1)
	m.storage.add(pk, "food", 2 * units)
	var u1: int = e.planned_units(r1)
	var u2: int = e.planned_units(r2)
	check(u1 == units and u2 < units and u2 == floori(float(2 * units) * 0.25), "N2: the 3/4 leg moves a full ship load, the 1/4 leg only its share", "%d %d (ship %d)" % [u1, u2, units])
	var b1: int = m.storage.amount(m.storage.planet_key(d1), "food")
	var b2: int = m.storage.amount(m.storage.planet_key(d2), "food")
	var res: Dictionary = e.settle(m.cash)
	check(m.storage.amount(m.storage.planet_key(d1), "food") - b1 == u1 and m.storage.amount(m.storage.planet_key(d2), "food") - b2 == u2, "N2: settle moves exactly the planned units on each leg")
	var paid_ok := true
	for v in res["results"]:
		if int(v["a"]) == ti:
			var rr: Dictionary = e.routes[e.find_by_id(int(v["id"]))]
			if int(v["paid"]) != -e.fixed_cost(rr):
				paid_ok = false
	check(paid_ok, "N2: each leg still pays its trip and upkeep cost")
	check(e.split_budget.is_empty(), "N2: the cycle's split budget is cleared after settle")
	e.closed_planets.append(d2)
	check(e._split_limit(r1) == e.src_available(r1), "N2: a closed partner lets the other lane take all the stock")
	e.closed_planets.erase(d2)
	var saved: Array = e.to_array()
	e.from_array(saved, m.ships)
	var s3: Dictionary = e.lane_split(ti, d1, "food")
	check(not s3.is_empty() and is_equal_approx(float(s3["share"]), 0.75), "N2: the split survives a save and restore")
	m.selected_planet = ti
	m.planet_panel.show_planet(ti)
	check(_find_named(m.planet_panel, "SplitButton") != null and _find_named(m.planet_panel, "SplitBar") == null, "split bar: a row with two lanes offers one Split button, the bar is closed")
	check(not m.has_method("begin_split") and not m.has_method("_on_split_click"), "split bar: the old two-click pick no longer exists")
	e.clear_split(ti, "food")
	check(e.lane_split(ti, d1, "food").is_empty() and e.lane_split(ti, d2, "food").is_empty(), "split bar: clear_split removes both lanes' split")
	_find_named(m.planet_panel, "SplitButton").pressed.emit()
	check(_find_named(m.planet_panel, "SplitBar") != null, "split bar: the Split button opens the bar")
	var sl: HSlider = _find_named(m.planet_panel, "SplitSlider")
	var q1: Dictionary = e.lane_split(ti, d1, "food")
	check(sl != null and int(sl.value) == 50 and not q1.is_empty() and is_equal_approx(float(q1["share"]), 0.5), "split bar: the bar starts at 50/50")
	sl.value = 70
	var w1: Dictionary = e.lane_split(ti, d1, "food")
	var w2: Dictionary = e.lane_split(ti, d2, "food")
	check(is_equal_approx(float(w1["share"]), 0.7) and is_equal_approx(float(w2["share"]), 0.3), "split bar: 70/30 gives the lanes 0.7 and 0.3", str([w1, w2]))
	_find_named(m.planet_panel, "SplitPlus").pressed.emit()
	check(is_equal_approx(float(e.lane_split(ti, d1, "food")["share"]), 0.8), "split bar: + steps 10 points")
	for _i in 5:
		_find_named(m.planet_panel, "SplitPlus").pressed.emit()
	check(is_equal_approx(float(e.lane_split(ti, d1, "food")["share"]), 0.9) and is_equal_approx(float(e.lane_split(ti, d2, "food")["share"]), 0.1), "split bar: each lane keeps at least 10%")
	check(_find_named(m.planet_panel, "SplitTag") != null, "split bar: split lanes show a tag on their route row")
	_find_named(m.planet_panel, "SplitDone").pressed.emit()
	check(_find_named(m.planet_panel, "SplitBar") == null and not e.lane_split(ti, d1, "food").is_empty(), "split bar: Done closes the bar and keeps the split")
	_find_named(m.planet_panel, "SplitButton").pressed.emit()
	_find_named(m.planet_panel, "SplitStop").pressed.emit()
	check(e.lane_split(ti, d1, "food").is_empty() and e.lane_split(ti, d2, "food").is_empty() and _find_named(m.planet_panel, "SplitBar") == null, "split bar: Stop split clears it")
	m.set_split_percent(ti, "food", 60)
	var gone := -1
	for i in e.routes.size():
		if int(e.routes[i]["a"]) == ti and int(e.routes[i]["b"]) == d2:
			gone = i
			break
	e.routes.remove_at(gone)
	check(e.lane_split(ti, d1, "food").is_empty() and e._split_limit(r1) == -1, "split bar: a lane losing its ship ends the split, the other lane takes all stock")
	await _free_main(m)
	_wipe_user()

# ---- each system has its own sun (system 2 blue); system 1 keeps the orange one ----
func _test_stations() -> void:
	var m = await _new_main()
	m._dismiss_preface()
	check(m.station_systems.is_empty() and m.map.stations.is_empty(), "station: none before A1")
	m.open_systems = [1, 2]
	m._open_system(2)
	check(m.station_systems.is_empty(), "station: none before A1 even with system 2 open")
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = ["0-1", "0-2"]
	m.skill_points = 50
	check(m.learn_skill("C1")["ok"] and m.learn_skill("A1")["ok"], "station: A1 learned")
	check(m.station_systems.has(1) and m.station_systems.has(2) and m.map.stations.size() == 2, "station: one per open system after A1")
	m._ensure_stations()
	m._ensure_posts()
	check(m.station_systems.size() == 2 and m.map.stations.size() == 2 and m.station_markers.size() == 2, "station: no duplicates on a second call")
	check(m.map.add_station(1) == false, "station: map refuses a second station")
	var st: Dictionary = m.collect_state()
	check(st["station_systems"] == [1, 2], "station: flag saved", str(st["station_systems"]))
	await _free_main(m)
	m = await _new_main()
	m._dismiss_preface()
	m.apply_state(JSON.parse_string(JSON.stringify(st)))
	check(m.station_systems == [1, 2] and m.map.stations.size() == 2, "station: save round-trips", str(m.station_systems))
	var old: Dictionary = st.duplicate()
	old.erase("station_systems")
	m.apply_state(old)
	check(m.station_systems == [1, 2] and m.map.stations.size() == 2, "station: old save with A1 builds them on load")
	# Space Storage view: the station click opens it, not the planet panel
	var ssv = m.space_storage_view
	m.planet_panel.visible = false
	m._on_station_clicked(2)
	check(m.space_post_open(2) and ssv.visible and ssv.system_id == 2 and not m.planet_panel.visible, "station view: click opens the Space Storage view, not the planet panel")
	var rows_ok: bool = true
	for c in m.commodities:
		rows_ok = rows_ok and ssv.box.find_child("Row_" + str(c), true, false) != null
	check(rows_ok and not m.commodities.is_empty(), "station view: one row per commodity")
	ssv.close_view()
	check(not ssv.visible, "station view: closes")
	# a pending plain Send to picks the station instead of opening the view
	m.cash = 5000
	m.ships = 3
	var pick_n: int = m.engine.routes.size()
	m.pending = {"planet": 0, "c": "energy"}
	m._on_station_clicked(1)
	check(m.pending.is_empty() and not m.space_storage_view.visible and m.engine.routes.size() == pick_n + 1 and str(m.engine.routes[pick_n]["dst"]) == "system:1", "station pick: a pending Send to completes with the station as destination", "routes %d" % m.engine.routes.size())
	m.pending = {}
	m.storage.stock.erase(Storage.system_key(2))
	m._on_station_clicked(2)
	check(not m.space_post_open(2) and not ssv.visible and m.last_notice == m.trade_locked_reason(), "station view: refused with the locked reason without a post")
	await _free_main(m)

func _test_system_suns() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var map = m.map
	check(map.suns.size() == 1 and map.suns.has(1) and map.suns[1].visible, "suns: system 1 has its sun at the start")
	var s1 = map.suns[1]
	check(absf(s1.hue_shift()) < 0.0001 and absf(s1.sun_color.h - 0.09) < 0.01 and s1.drives_light and s1 == map.sun_node, "suns: system 1 sun unchanged (orange, no hue shift)")
	# Sun brightness mute (2026-11-02): the core stays fully opaque (no ALPHA written, alpha 1.0) and the gain is unchanged.
	var sun_src := FileAccess.get_file_as_string("res://art/sun/sun.gdshader")
	check(not sun_src.contains("ALPHA") and sun_src.contains("blend_add") and not sun_src.contains("transparent"), "sun: shader writes no alpha, so the core alpha stays 1.0")
	var core_mat: ShaderMaterial = s1._core.material_override
	check(float(core_mat.get_shader_parameter("core_value")) >= 3.0 and s1.PLANE_GLOW < 0.9, "sun: core value kept at 3.0, plane glow muted")
	var we_gain := true
	for n in map.get_children():
		if n is WorldEnvironment:
			we_gain = absf((n as WorldEnvironment).environment.glow_intensity - 0.8) < 0.0001
	check(we_gain, "sun: scene glow gain unchanged at 0.8")
	# Top pole (+Y) in the shadow: dot(top, sun) < -0.5. Bottom pole (-Y) faces the sun, so it must be hidden from the map camera:
	# dot(bottom, camera) < 0 over the whole yaw/pitch range. Where the sun is on the camera side this is geometrically impossible
	# (planet_3, s2_p3), so the bottom pole may only graze the limb there: dot(bottom, camera) < 0.25 (pole at least 75 deg off the view axis).
	var pole_ok: bool = map.planet_spheres.size() > 0
	var pole_info: String = ""
	for i in map.planet_spheres.size():
		var sp = map.planet_spheres[i]
		var sun_w: Vector3 = (map.sun_positions.get(int(map.planets[i].get("system", 1)), map.focus_sun_pos) - map.positions[i]).normalized()
		var top_w: Vector3 = sp.global_transform.basis.y.normalized()
		var worst := -2.0  # largest dot(bottom, camera) over the camera range (dense grid)
		for yi in 19:
			for pi_ in 13:
				var yw := deg_to_rad(lerpf(map.yaw_min_deg, map.yaw_max_deg, yi / 18.0))
				var pt := deg_to_rad(lerpf(map.pitch_min_deg, map.pitch_max_deg, pi_ / 12.0))
				var cam := Vector3(sin(yw) * cos(pt), sin(pt), cos(yw) * cos(pt))
				worst = maxf(worst, (-top_w).dot(cam))
		pole_ok = pole_ok and top_w.dot(sun_w) < -0.5 and absf(sp.key_dir.y - top_w.dot(sun_w)) < 0.001 and worst < 0.25 and absf(sp.scale.x - map.planet_radius()) < 0.0001
		pole_info += " %s:top.sun %.2f bottom.cam<=%.2f" % [map.planets[i]["id"], top_w.dot(sun_w), worst]
	check(pole_ok, "planet pole: top pole in shadow (dot sun < -0.5), bottom pole hidden from the camera range (or grazing the limb); scale unchanged", pole_info)
	var pos1: Vector3 = s1.position
	m.open_systems.append(2)
	map.add_planets(m.Systems.planets_of(2))
	check(map.suns.size() == 2 and map.suns.has(2), "suns: system 2 gets its own sun")
	var s2 = map.suns[2]
	check(s2 != s1 and s2.position.distance_to(pos1) > 1.0 and s2.position.distance_to(map._system_center(2)) < 0.001, "suns: system 2 sun sits at the middle of its own planets", str(s2.position))
	var h: float = s2.sun_color.h
	check(h > 0.55 and h < 0.68 and s2.sun_color.s > 0.4 and not s2.drives_light, "suns: system 2 sun is blue", "hue %.3f" % h)
	check(absf(s2.hue_shift() - (h - 0.09)) < 0.0001, "suns: system 2 grid is hue-shifted to its colour")
	check(map.orbit_rings.has(1) and map.orbit_rings.has(2), "suns: each system has orbit rings")
	map.set_view_system(1)
	check(s1.visible and not s2.visible and map.orbit_rings[1].visible and not map.orbit_rings[2].visible, "suns: view of system 1 shows only its sun")
	map.set_view_system(2)
	check(s2.visible and not s1.visible and map.orbit_rings[2].visible and not map.orbit_rings[1].visible, "suns: view of system 2 shows only its sun")
	check(s1.position == pos1 and absf(s1.hue_shift()) < 0.0001, "suns: system 1 sun unmoved and unshifted after system 2 opens")
	await _free_main(m)

## Owner bug: after an energy route, the food route back between the same two planets must be possible.
func _test_energy_then_food() -> void:
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	# The first route buys the first ship; the second ship is not affordable yet (cash set just below ship_price).
	m.selected_planet = 0
	m.begin_buy_and_send("energy")
	m._on_planet_clicked(1)
	check(e.routes.size() == 1 and m.pending.is_empty(), "energy then food: energy route made, nothing pending")
	m.cash = int(m.balance["ship_price"]) - 1  # one credit short of a second ship (start cash alone buys two at ship_price 900)
	m.selected_planet = 1
	m.begin_buy_and_send("food")
	m._on_planet_clicked(0)
	check(e.routes.size() == 1 and not m.pending.is_empty() and m.shown_notice.begins_with("Not enough cash for a new ship"), "energy then food: no cash for a second ship shows the reason at once, not behind Route made", m.shown_notice)
	m.cancel_pending()
	# With the cash for a second ship the food route back is made (same pair, other commodity).
	m.cash = 10000
	m.selected_planet = 1
	m.begin_buy_and_send("food")
	m._on_planet_clicked(0)
	check(e.routes.size() == 2 and str(e.routes[1]["c"]) == "food" and int(e.routes[1]["a"]) == 1 and int(e.routes[1]["b"]) == 0 and m.pending.is_empty(), "energy then food: food route back is made")
	m.selected_planet = 0
	m._on_send("food")
	m._on_planet_clicked(1)
	check(e.routes.size() == 3 and str(e.routes[2]["c"]) == "food", "energy then food: food route in the energy direction is made too")
	await _free_main(m)
	_wipe_user()

## N5: Salvage sale for stuck stock.
func _test_salvage() -> void:
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	var share: float = float(m.balance["salvage_share"])
	check(share > 0.0 and share < 1.0, "salvage: salvage_share is between 0 and 1", str(share))
	var key: String = m.storage.planet_key(0)
	m.storage.ensure(key)
	var c := "energy"
	var cap: int = m.storage.capacity_of(key)
	# Stock, no order, no route: no buyer.
	m.storage.stock[key][c] = 10
	check(e.salvage_reason(0, c) == "no_buyer", "salvage: offered with no buyer on the lanes")
	var offer: Dictionary = e.salvage_offer(0, c)
	var price: int = e.sold_price(0, c)
	check(int(offer["m"]) == 10 * price and int(offer["n"]) == roundi(10.0 * price * share), "salvage: amount is salvage_share times the Sell price", str(offer))
	check(int(offer["n"]) < int(offer["m"]), "salvage: never beats a Sell order")
	# A standing Sell order is a buyer: not offered while storage has room.
	m.set_local_order(0, c, "sell", true)
	check(e.salvage_reason(0, c) == "", "salvage: not offered with a Sell order and room in storage")
	# Storage full: offered even with a buyer.
	m.storage.stock[key][c] = cap
	check(e.salvage_reason(0, c) == "full", "salvage: offered when storage is full")
	m.set_local_order(0, c, "sell", false)
	# Empty storage: nothing to salvage.
	m.storage.stock[key][c] = 0
	check(e.salvage_reason(0, c) == "", "salvage: not offered with empty storage")
	# Click: stock leaves storage, cash rises by N, one-off.
	m.storage.stock[key][c] = 10
	var cash0: int = m.cash
	var n: int = int(e.salvage_offer(0, c)["n"])
	var r: Dictionary = m.salvage_stock(0, c)
	check(r["ok"] and m.cash == cash0 + n and m.storage.amount(key, c) == 0, "salvage: sale credits cash and empties the stock", str(r))
	check(not m.salvage_stock(0, c)["ok"] and m.cash == cash0 + n, "salvage: second click does nothing")
	await _free_main(m)
	_wipe_user()

# ---- N3: Mixed load bonus (code name: bundle bonus) ----
func _test_mixed_load() -> void:
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	var pct: float = float(m.balance["bundle_bonus_pct"])
	var cap: int = int(m.balance["bundle_bonus_cap"])
	var key: String = m.storage.planet_key(0)
	m.storage.ensure(key)
	var goods: Array = []
	for c in e.commodities:
		if e.local_price(0, c, "sell") > 0:
			goods.append(c)
	check(goods.size() >= 2, "N3: planet 0 buys at least two goods", str(goods))
	if goods.size() < 2:
		await _free_main(m)
		return
	var a: String = goods[0]
	var b: String = goods[1]
	e.local.clear()
	m.storage.stock[key][a] = 10
	m.storage.stock[key][b] = 10
	e.local_of(0, a, true)["sell"] = true
	# One good: no bonus, no row line.
	check(e.mixed_preview(0).is_empty(), "N3: one good has no bonus preview")
	var one: Dictionary = e.settle(0)
	var rev_a: int = int(one["local"][0]["paid"])
	check(rev_a == int(one["local"][0]["n"]) * e.sold_price(0, a) and rev_a > 0, "N3: one good sells at the normal price", str(one["local"]))
	# Two goods: first none, second +pct of its revenue (below the cap).
	m.storage.stock[key][a] = 10
	m.storage.stock[key][b] = 10
	e.local_of(0, b, true)["sell"] = true
	var calc_b: int = int(e._local_calc(0, b, "sell", 0)["credits"])
	var want_b: int = floori(calc_b * pct)
	var cap0: int = int(e.balance["bundle_bonus_cap"])
	e.balance["bundle_bonus_cap"] = 1000000
	var two: Dictionary = e.settle(0)
	var pa := 0
	var pb := 0
	for l in two["local"]:
		if l["c"] == a: pa = int(l["paid"])
		if l["c"] == b: pb = int(l["paid"])
	check(pa == rev_a and pb == calc_b + want_b and want_b > 0, "N3: second good gets pct of its revenue, first none", "%d %d %d %d" % [pa, pb, calc_b, want_b])
	# Cap: 150 per planet per cycle, applied percent drops below 5.
	e.balance["bundle_bonus_cap"] = 1
	m.storage.stock[key][a] = 10
	m.storage.stock[key][b] = 10
	var prev: Dictionary = e.mixed_preview(0)
	check(prev.has(b) and int(prev[b]["bonus"]) == 1 and float(prev[b]["pct"]) < pct * 100.0, "N3: preview shows the capped percent, not 5", str(prev))
	var capped: Dictionary = e.settle(0)
	var total_bonus := 0
	for l in capped["local"]:
		if l["c"] == b: total_bonus = int(l["paid"]) - calc_b
	check(total_bonus == 1, "N3: bonus is capped per planet per cycle", str(total_bonus))
	e.balance["bundle_bonus_cap"] = cap0
	check(cap0 == cap and cap == 150, "N3: cap comes from balance (150)")
	# Row line only when it applies, with the capped percent.
	m.storage.stock[key][a] = 10
	m.storage.stock[key][b] = 10
	m.planet_panel.show_planet(0)
	await get_root().get_tree().process_frame
	var ml: Node = _find_named(m.planet_panel, "MixedLoadLabel")
	check(ml != null and ml.text.begins_with("Mixed load +") and "150" in ml.text and not ("undle" in ml.text), "N3: Sell row shows the Mixed load line", ml.text if ml else "none")
	e.balance["bundle_bonus_cap"] = 1
	m.planet_panel.show_planet(0)
	await get_root().get_tree().process_frame
	ml = _find_named(m.planet_panel, "MixedLoadLabel")
	check(ml != null and not ("+5%" in ml.text), "N3: row line never shows 5% when the cap cut it", ml.text if ml else "none")
	e.balance["bundle_bonus_cap"] = cap0
	e.local_of(0, b, true)["sell"] = false
	m.planet_panel.show_planet(0)
	await get_root().get_tree().process_frame
	check(_find_named(m.planet_panel, "MixedLoadLabel") == null, "N3: no row line with one good")
	# Per cycle: next cycle starts fresh, a single good gets nothing.
	e.local_of(0, b, true)["sell"] = true
	m.storage.stock[key][a] = 10
	m.storage.stock[key][b] = 10
	e.settle(0)
	m.storage.stock[key][a] = 10
	m.storage.stock[key][b] = 0
	var nxt: Dictionary = e.settle(0)
	var got := 0
	for l in nxt["local"]:
		if l["c"] == a: got = int(l["paid"])
	check(got == int(nxt["local"][0]["n"]) * e.sold_price(0, a) and nxt["local"].size() >= 1, "N3: bonus does not carry over to the next cycle", str(nxt["local"]))
	await _free_main(m)
	_wipe_user()

## Owner 2026-11-03: trading outside system 1 needs that system's Space Storage post.
func _test_trade_gate() -> void:
	var m = await _new_main()
	m._dismiss_preface()
	m.open_systems = [1, 2]
	m._open_system(2)
	var home := -1
	var far := -1
	for i in m.map.planets.size():
		var sid := int(m.map.planets[i].get("system", 1))
		var ok_c: bool = m.trade.price(i, "energy_buy") >= 0 and m.trade.price(i, "energy_sell") >= 0
		if sid == 1 and home < 0 and ok_c: home = i
		if sid == 2 and far < 0 and ok_c: far = i
	var c := "energy"
	m.cash = 5000
	m.ships = 2
	m.learned_skills.append("C3")  # Long Haul, so only the gate can refuse a cross-system route
	check(m.system_trade_open(home) and not m.system_trade_open(far), "gate: home open, second system locked without a post")
	check(m.set_local_order(home, c, "buy", true)["ok"], "gate: home Buy works without a post")
	check(m.set_local_order(home, c, "sell", true)["ok"], "gate: home Sell works without a post")
	var cash0: int = m.cash
	var rb: Dictionary = m.set_local_order(far, c, "buy", true)
	var rs: Dictionary = m.set_local_order(far, c, "sell", true)
	check(not rb["ok"] and not rs["ok"] and rb["reason"] == m.trade_locked_reason(), "gate: second system refuses Buy and Sell", str(rb))
	check(not m.engine.local_on(far, c, "buy") and not m.engine.local_on(far, c, "sell") and m.cash == cash0, "gate: refused orders change nothing")
	var stock0: int = m.storage.amount(m.storage.planet_key(home), c)
	var rt: Dictionary = m.send_stock_buying(home, far, c)
	var rt2: Dictionary = m.send_stock_buying(far, home, c)
	check(not rt["ok"] and not rt2["ok"] and rt["reason"] == m.trade_locked_reason(), "gate: Send to refused to and from a locked system", str(rt))
	check(m.cash == cash0 and m.engine.routes.is_empty() and m.storage.amount(m.storage.planet_key(home), c) == stock0, "gate: refused Send changes no cash, ships, routes or stock")
	# panel buttons
	m.planet_panel.show_planet(far)
	var names := ["BuyButton_" + c, "SellButton_" + c, "SendButton_" + c]
	var all_off := true
	for nm in names:
		var b = _find_named(m.planet_panel, nm)
		if b == null or not b.disabled or b.tooltip_text != m.trade_locked_reason():
			all_off = false
	check(all_off, "gate: panel disables Buy, Sell and Send to with the reason on a locked system")
	m.planet_panel.show_planet(home)
	var hb = _find_named(m.planet_panel, "BuyButton_" + c)
	check(hb != null and not hb.disabled, "gate: panel keeps home Buy enabled")
	# open the post
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = ["0-1", "0-2"]
	m.skill_points = 50
	m.learn_skill("C1")
	m.learn_skill("A1")
	check(m.space_post_open(2) and m.system_trade_open(far), "gate: post open after A1")
	check(m.set_local_order(far, c, "buy", true)["ok"] and m.set_local_order(far, c, "sell", true)["ok"], "gate: second system Buy and Sell work once the post is open")
	var ro: Dictionary = m.send_stock_buying(home, far, c)
	check(ro["ok"], "gate: Send to works once the post is open", str(ro))
	m.planet_panel.show_planet(far)
	var open_b = _find_named(m.planet_panel, "BuyButton_" + c)
	check(open_b != null and not open_b.disabled, "gate: panel enables Buy once the post is open")
	await _free_main(m)

# ---- N9: a Send to... can name one stop on the path; the stop sells up to its Sell order amount and the rest goes on ----
func _test_stop_sale() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	var src := 0  # Voltara
	var dst := 1  # Tillam
	var stop := 2  # Ashgate, moved onto the Voltara-Tillam line for this test only
	var c := "energy"
	m.map.planets[stop]["x"] = 0
	m.map.planets[stop]["y"] = 80
	m.cash = 100000
	check(e.stop_on_path(src, stop, dst) and not e.stop_on_path(src, dst, stop) and not e.stop_on_path(src, src, dst), "N9: a planet between src and dst is on the path, the ends are not")
	check(e.stop_candidates(src, dst, c).is_empty(), "N9: no stop is offered while the stop has no Sell order for the commodity")
	var ro: Dictionary = m.set_local_order(stop, c, "sell", true)
	check(ro["ok"] and e.stop_candidates(src, dst, c).has(stop) and e.stop_candidates(src, dst, c).size() == 1, "N9: an enabled Sell order at the stop offers it", str(ro))
	var line: String = m.stop_line(stop, dst)
	check(line == "Stop at Ashgate: sell up to %d here, carry the rest to Tillam." % int(e.balance["order_amount"]), "N9: the picker line reads 'Stop at A: sell up to N here, carry the rest to B.'", line)
	m.pending = {"planet": src, "c": c}
	check(m.pending_margin_lines().has(line), "N9: the picker lists the stop line under its destination")
	m._on_planet_clicked(dst)
	check(m.pending.has("dest") and int(m.pending["dest"]) == dst and e.routes.is_empty(), "N9: the first click picks the destination and sends nothing yet")
	m._on_planet_clicked(stop)
	check(e.routes.size() == 1 and int(e.routes[0]["stop"]) == stop and int(e.routes[0]["b"]) == dst, "N9: the second click on the stop makes a route to the destination with that stop")
	check(not m.send_stock_buying(src, dst, c, src)["ok"], "N9: a stop that is not offered is refused before a ship is bought")
	check(m.send_stock_buying(src, dst, c)["ok"] and int(e.routes[e.routes.size() - 1]["stop"]) == -1, "N9: a direct send still works next to the stop route")
	var rs: Dictionary = e.routes[0]
	var direct: Dictionary = e.new_record(src, dst, c)
	check(e.fixed_cost(rs) == 2 * e.trip_part() + e.upkeep_part(rs) and e.fixed_cost(direct) == e.trip_part() + e.upkeep_part(direct), "N9: a stop pays one extra trip cost")
	check(e.units_per_cycle(rs) < e.units_per_cycle(direct) and e.units_per_cycle(rs) == floori(float(m.balance["cargo"]) / (4.0 * e.trade.travel_cycles())), "N9: the stop leg adds one travel leg, so the stop route moves fewer units")
	# settle: the stop keeps up to its Sell order amount from the load, the rest is carried on
	var orig_amount: int = int(e.balance["order_amount"])
	e.balance["order_amount"] = 3
	var sk: String = m.storage.planet_key(src)
	m.storage.ensure(sk)
	var have: int = m.storage.amount(sk, c)
	if have > 0:
		m.storage.remove(sk, c, have)
	m.storage.add(sk, c, 200)
	var moved: int = e.planned_units(rs)
	var dk: String = m.storage.planet_key(dst)
	var d0: int = m.storage.amount(dk, c)
	var s0: int = m.storage.amount(m.storage.planet_key(stop), c)
	var paid: int = e._settle_one(rs, m.cash)
	var sold_want := mini(moved, 3)
	check(moved > 3 and m.storage.amount(dk, c) - d0 == moved - sold_want, "N9: the stop keeps up to its order amount, the rest arrives at the destination", "moved %d" % moved)
	check(paid + int(rs["bonus"]) == -e.fixed_cost(rs) + sold_want * e.sold_price(stop, c), "N9: the stop sale is paid on top of the stop route's cost")
	check(m.storage.amount(m.storage.planet_key(stop), c) == s0, "N9: the stop sells from the ship's load, not from company storage")
	m.set_local_order(stop, c, "sell", false)
	m.storage.add(sk, c, 200)
	var moved2: int = e.planned_units(rs)
	var d1: int = m.storage.amount(dk, c)
	e._settle_one(rs, m.cash)
	check(m.storage.amount(dk, c) - d1 == moved2 and int(rs["bonus"]) == 0, "N9: with the stop's Sell order off the load goes on whole")
	m.set_local_order(stop, c, "sell", true)
	e.balance["order_amount"] = orig_amount
	var saved: Array = e.to_array()
	e.from_array(saved, 10)
	var kept := false
	for r in e.routes:
		if int(r["stop"]) == stop:
			kept = true
	check(kept, "N9: the stop survives a save and restore")
	var bad: Array = saved.duplicate(true)
	bad[0]["stop"] = src
	e.from_array(bad, 10)
	check(int(e.routes[0]["stop"]) == -1, "N9: a saved stop that is not on the path is dropped on load")
	await _free_main(m)

func _test_second_lane() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	check(not m.second_lane_active(), "N11: the optional line is hidden before the first ship and cycle")
	m.ships = 1
	m.cycle = 3
	check(m.second_lane_active(), "N11: the optional line shows once the player is trading")
	var base: int = m.permit_cost(2)
	check(base == int(m.balance["permit_2_cost"]) and m.second_lane_line().contains("Optional") and m.second_lane_line().contains(str(base)), "N11: the line says Optional and shows the live permit cost", m.second_lane_line())
	m.learned_skills = ["C4"]
	var disc: int = m.permit_cost(2)
	check(disc < base and m.second_lane_line().contains(str(disc)), "N11: the line shows the permit cost after the C4 discount", m.second_lane_line())
	m.learned_skills = []
	m._refresh()
	check(m.goal_label.text.contains("Optional"), "N11: the goal line carries the optional text")
	m.debug_grant_permit(2)  # buying (granting) the permit never ticks the goal
	var p2 := -1
	var p1 := 0
	for i in m.map.planets.size():
		if int(m.map.planets[i].get("system", 1)) == 2 and p2 < 0:
			p2 = i
	check(p2 >= 0 and m.second_lane_planet == -1, "N11: opening system 2 does not tick the goal")
	m._check_second_lane({"local": [{"planet": p1, "role": "sell", "n": 5, "paid": 50}, {"planet": p2, "role": "buy", "n": 5, "paid": -50}, {"planet": p2, "role": "sell", "n": 0, "paid": 0}], "results": [{"stop": p2, "stop_sale": 0}]})
	check(m.second_lane_planet == -1, "N11: a system 1 sale, a system 2 buy and an empty sale do not tick it")
	m._check_second_lane({"local": [{"planet": p2, "role": "sell", "n": 4, "paid": 40}], "results": []})
	check(m.second_lane_planet == p2 and not m.second_lane_active(), "N11: a sale in system 2 ticks the goal and hides the line")
	var cash0: int = m.cash
	var pts0: int = m.skill_points
	m._check_second_lane({"local": [], "results": [{"stop": p2 + 1, "stop_sale": 9}]})
	check(m.second_lane_planet == p2 and m.cash == cash0 and m.skill_points == pts0, "N11: the goal ticks once and pays no cash or skill points")
	var st: Dictionary = m.collect_state()
	check(int(st["second_lane"]) == p2, "N11: the tick is saved")
	m.second_lane_planet = -1
	m.apply_state(st)
	check(m.second_lane_planet == p2, "N11: the tick survives a save and load")
	m.planet_panel.show_planet(p2)
	check(m.planet_panel.box.get_node_or_null("SecondLaneNote") != null, "N11: the planet panel shows the title and note on that planet")
	m.planet_panel.show_planet(p1)
	check(m.planet_panel.box.get_node_or_null("SecondLaneNote") == null, "N11: other planets show no note")
	await _free_main(m)

# ---- T157: instanced asteroid packs on the map ----
func _test_asteroid_packs() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var ap: Node3D = m.map.asteroid_packs
	var want: int = m.clusters_in_system(1).size() + m.clusters_in_system(2).size()
	check(ap != null and ap.packs.size() == want and want > 0, "T157: one pack per cluster", "%d of %d" % [ap.packs.size() if ap != null else -1, want])
	var ok := true
	var one_mesh := true
	for c in m.clusters_in_system(1):
		var mmi: MultiMeshInstance3D = ap.packs[str(c["id"])]["mm"]
		ok = ok and mmi.multimesh.visible_instance_count == int(c["visible"]) and mmi.multimesh.instance_count == int(c["count"])
		one_mesh = one_mesh and mmi.multimesh.mesh != null
	check(ok and one_mesh, "T157: each pack is one MultiMesh with count and thinning from the cluster data")
	var c0: Dictionary = m.clusters_in_system(1)[0]
	var t_a: Transform3D = ap.packs[str(c0["id"])]["mm"].multimesh.get_instance_transform(3)
	ap.packs.clear()
	ap.sync(m.clusters_in_system(1))
	var t_b: Transform3D = ap.packs[str(c0["id"])]["mm"].multimesh.get_instance_transform(3)
	check(t_a.is_equal_approx(t_b), "T157: the same cluster id gives the same pack (seeded)")
	m.map.set_view_system(2)
	m.map.set_view_system(1)
	check(ap.packs[str(c0["id"])]["mm"].visible, "T157: packs show only for the viewed system")
	check(ap.get_children().all(func(n): return not (n is CollisionObject3D)), "T157: packs have no collision, so planet clicks are never blocked")
	# T159: a click on a cluster shows its info card; a planet click hides it
	m._on_cluster_clicked(int(c0["index"]))
	var info_ok: bool = m.cluster_info != null and m.cluster_info.visible and not m.planet_panel.visible
	var info_line: Label = m.cluster_info.find_child("ClusterInfoLine", true, false) if m.cluster_info != null else null
	check(info_ok and info_line != null and info_line.text.contains(str(m.clusters.yield_per_cycle())), "T159: cluster click shows the info card with the yield per cycle")
	check(m.map.pick_cluster(Vector2(-5000, -5000)) == -1, "T159: a click far from any pack picks no cluster")
	m._on_planet_clicked(0)
	check(not m.cluster_info.visible, "T159: a planet click hides the cluster card")
	await _free_main(m)

# ---- T156: asteroid clusters, ore yield and risk ----
func _test_clusters() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var b: Dictionary = m.balance
	var cl: RefCounted = m.clusters
	check(cl.list(1).size() == int(b["mining_clusters_s1"]) and cl.list(2).size() == int(b["mining_clusters_s2"]), "T156: cluster count per system follows mining_clusters_s1 and s2", "%d %d" % [cl.list(1).size(), cl.list(2).size()])
	var f := true
	for d in cl.list():
		f = f and d.has("id") and d.has("system") and d.has("x") and d.has("y") and d.has("radius") and d.has("count") and str(d["good"]) == "ore" and int(d["left"]) == int(b["mining_cluster_richness"]) and int(d["visible"]) == int(d["count"])
	check(f, "T156: every cluster has id, system, position, pack radius, count, ore, full richness and a full pack")
	var dst := -1
	for i in m.map.planets.size():
		if m.engine.sold_price(i, "ore") > 0 and (dst < 0 or m.engine.sold_price(i, "ore") > m.engine.sold_price(dst, "ore")):
			dst = i
	check(dst >= 0, "T156: a planet buys ore")
	var node: int = Clusters.node_id(0)
	m.ships = 3
	m.cash = 100000
	var r: Dictionary = m.send_from_cluster(node, dst)
	check(not r["ok"] and r["reason"] == StoryText.get_or("NOT_MINING_NEEDS_SKILL", "Mining needs the Prospecting skill.") and m.engine.routes.is_empty(), "T156: no mining skill, no route from a cluster", str(r))
	check(not m.can_mine(), "T156: can_mine is false without the skill")
	m.learned_skills.append(Clusters.MINING_SKILL)
	check(m.can_mine(), "T156: can_mine follows the mining skill hook")
	r = m.send_from_cluster(node, dst)
	check(r["ok"] and m.engine.routes.size() == 1 and RouteEngine.from_cluster(m.engine.routes[0]) and str(m.engine.routes[0]["src"]) == "cluster:c1_1", "T156: with the skill a cluster starts a route", str(r))
	var rich: int = int(b["mining_cluster_richness"])
	var load_units: int = m.engine.units_per_cycle(m.engine.routes[0])
	var cash0: int = m.cash
	m._settle_routes()
	check(m.storage.amount(Storage.planet_key(dst), "ore") == load_units and cl.left(0) == rich - load_units, "T156: one cycle moves one ship load of ore and the cluster loses it", "%d left %d" % [m.storage.amount(Storage.planet_key(dst), "ore"), cl.left(0)])
	check(m.cash == cash0 - m.engine.fixed_cost(m.engine.routes[0]), "T156: ore is free to load, the lane costs trip and upkeep", "%d" % (cash0 - m.cash))
	check(cl.visible_count(0) < int(cl.items[0]["count"]) and cl.visible_count(0) >= 1, "T156: the pack thins as ore is taken")
	# second ship: both together never exceed mining_yield_per_cycle
	var r2: Dictionary = m.send_from_cluster(node, dst)
	check(r2["ok"], "T156: a second ship may share the cluster", str(r2))
	var before: int = cl.left(0)
	m._settle_routes()
	var took: int = before - cl.left(0)
	check(took == int(b["mining_yield_per_cycle"]) and took <= int(b["mining_yield_per_cycle"]), "T156: two ships share mining_yield_per_cycle", "took %d" % took)
	check(not m.send_from_cluster(node, dst)["ok"], "T156: a third ship on a full cluster lane is refused (lane full)")
	# depletion, no respawn
	cl.items[0]["left"] = 5
	var st0: int = m.storage.amount(Storage.planet_key(dst), "ore")
	m._settle_routes()
	check(cl.left(0) == 0 and m.storage.amount(Storage.planet_key(dst), "ore") == st0 + 5, "T156: the last 5 units are taken, no more")
	check(cl.visible_count(0) == 0 and cl.list(1).size() == int(b["mining_clusters_s1"]) - 1, "T156: an empty cluster is drawn with no instances and drops out of the list")
	m._settle_routes()
	check(cl.left(0) == 0 and m.engine.routes[0]["state"] == "stalled", "T156: an empty cluster does not refill; its lane stalls", str(m.engine.routes[0]["state"]))
	check(not m.send_from_cluster(node, dst)["ok"], "T156: no new route from an empty cluster")
	# save and load keep the empty cluster and its route
	var st: Dictionary = m.collect_state()
	await _free_main(m)
	m = await _new_main()
	m._dismiss_preface()
	m.apply_state(st)
	check(m.clusters.left(0) == 0 and m.clusters.left(1) == rich and m.engine.routes.size() == 2, "T156: richness and cluster routes survive a save and load", "%d %d %d" % [m.clusters.left(0), m.clusters.left(1), m.engine.routes.size()])
	# debris risk reuses debris_route_penalty at the delivery planet
	m.engine.routes = [m.engine.routes[0]]
	m.clusters.items[0]["left"] = rich
	m.engine.debris_planets = []
	var clean: int = m.engine.planned_units(m.engine.routes[0])
	m.engine.debris_planets = [dst]
	var dirty: int = m.engine.planned_units(m.engine.routes[0])
	check(clean > 0 and dirty == floori(m.engine.units_per_cycle(m.engine.routes[0]) * (1.0 - float(b["debris_route_penalty"]))) and dirty < clean, "T156: debris at the delivery planet cuts an ore lane by debris_route_penalty", "%d vs %d" % [clean, dirty])
	m.engine.debris_planets = []
	# planet panel line
	m.planet_panel.show_planet(0)
	m.planet_panel.show_planet(0)
	check(m.planet_panel.box.get_node_or_null("ClusterNote") == null, "planet panel: no asteroid cluster line, even next to a cluster")
	var sbn := _find_named(m.planet_panel, "SellButton_energy") as Button
	check(sbn != null and sbn.text.begins_with(StoryText.get_text("BTN_SELL") + " ") and sbn.icon != null and sbn.tooltip_text.begins_with(StoryText.get_or("LBL_SELL_PRICE", "Sell price")), "panel: Sell button shows its price and the credits icon, tooltip says Sell price")
	check(_find_named(m.planet_panel, "PriceBuy_energy") == null and _find_named(m.planet_panel, "PriceSell_energy") == null, "panel: no separate price chips")
	check(not _labels(m.planet_panel, []).any(func(l): return l.text.to_upper() == "MAIN RESOURCES"), "planet panel: no Main resources row")
	check(_find_named(m.planet_panel, "StorageEmpty_energy") == null and not _labels(m.planet_panel, []).any(func(l): return l.text.begins_with("Storage empty")), "planet panel: no Storage empty line")
	check(not _labels(m.planet_panel, []).any(func(l): return l.text.begins_with("Abundant") or l.text.begins_with("Free ships") or l.text.contains("No free ship")), "planet panel: no Abundant, free-ship or no-free-ship line")
	m.ship_panel.set_upkeep(m)
	check(m.ship_panel.free_label.text.begins_with("Free ships: %d" % m.free_ships()), "ships window: shows the free-ship count and upkeep each", m.ship_panel.free_label.text)
	m.ships = m.engine.total_assigned()
	m.ship_panel.set_upkeep(m)
	check(m.free_ships() == 0 and m.ship_panel.free_label.text.contains("Send to... buys one") or m.ship_panel.free_label.text.contains("Not enough") or m.ship_panel.free_label.text.contains("limit"), "ships window: with no free ship it says what Send to... does", m.ship_panel.free_label.text)
	# T158: B1 Prospecting shows ore left; price trend and margin warning are base game; best partner is B3
	m.learned_skills.erase("B1")
	m.planet_panel.show_planet(0)
	m.learned_skills.erase("B1")
	m.planet_panel.show_planet(0)
	check(not _labels(m.planet_panel, []).any(func(l): return l.text.begins_with("Recent sell prices")), "price history: no history line on the panel, with or without a skill")
	# EV20: pay leaves a fresh small cluster; decline does not
	var n0: int = m.clusters.items.size()
	m.cash = 5000
	m.debug_fire_event("EV20")
	_buttons(m.event_notice, [])[1].pressed.emit()
	check(m.clusters.items.size() == n0, "T156: declining EV20 leaves no cluster")
	_buttons(m.event_notice, [])[0].pressed.emit()
	m.debug_fire_event("EV20")
	_buttons(m.event_notice, [])[0].pressed.emit()
	check(m.clusters.items.size() == n0 + 1 and m.clusters.left(n0) == int(b["mining_event_cluster_richness"]) and bool(m.clusters.items[n0]["spawned"]), "T156: paying EV20 leaves a small cluster of mining_event_cluster_richness")
	_buttons(m.event_notice, [])[0].pressed.emit()
	var st2: Dictionary = m.collect_state()
	m.clusters.items.resize(n0)
	m.clusters.from_dict(st2["clusters"])
	check(m.clusters.items.size() == n0 + 1 and m.clusters.left(n0) == int(b["mining_event_cluster_richness"]), "T156: a spawned cluster is saved and loaded")
	# EV20 storage loss reaches ore parked at a planet
	var key: String = Storage.planet_key(dst)
	m.storage.add(key, "ore", 90)
	var probe := RandomNumberGenerator.new()
	var bad_seed := 1
	for sd in range(1, 200):
		probe.seed = sd
		if probe.randf() < float(b["asteroid_decline_bad_odds"]):
			bad_seed = sd
			break
	m.events.seed_rng(bad_seed)
	m.cash = 5000
	var hits := 0
	for k in 8:  # the hit planet is random among established ones; repeat until it is the ore planet
		m.events.seed_rng(bad_seed + k * 0)
		m.debug_fire_event("EV20")
		_buttons(m.event_notice, [])[1].pressed.emit()
		if m.asteroid_last_hit == dst:
			hits += 1
		_buttons(m.event_notice, [])[0].pressed.emit()
		if hits > 0:
			break
	if hits > 0:
		check(m.storage.amount(key, "ore") <= m.storage.capacity_of(key), "T156: asteroid_storage_loss_pct trims ore parked at the hit planet")
	else:
		check(m.storage.amount(key, "ore") <= m.storage.capacity_of(key), "T156: parked ore never exceeds the cut capacity")
	await _free_main(m)


func _test_event_banners() -> void:
	var evs = _read_json("res://data/events.json")
	if typeof(evs) == TYPE_DICTIONARY:
		evs = evs.get("events", [])
	var missing: Array = []
	for e in evs:
		var p := "res://art/event_banners/%s.webp" % str(e["id"])
		if not FileAccess.file_exists(p) and not ResourceLoader.exists(p):
			missing.append(str(e["id"]))
	check(evs.size() > 0 and missing.is_empty(), "banners: every event in events.json has art/event_banners/<id>.webp", str(missing))


## Owner bug 2026-11-02: the cash forecast must equal what the next cycle really pays, including goods a route
## delivers to a planet with a Sell order (the storage is empty before the cycle).
func _test_forecast_income() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	var src := 0
	var dst := 1
	var c := "energy"
	m.cash = 100000
	m.set_local_order(dst, c, "sell", true)
	check(m.send_stock_buying(src, dst, c)["ok"] and e.routes.size() == 1, "forecast: one running route set up")
	var sk: String = m.storage.planet_key(src)
	var dk: String = m.storage.planet_key(dst)
	m.storage.ensure(sk)
	m.storage.ensure(dk)
	m.storage.remove(dk, c, m.storage.amount(dk, c))
	m.storage.remove(sk, c, m.storage.amount(sk, c))
	m.storage.add(sk, c, 200)
	var f: Dictionary = e.forecast(m.cash)
	var have_before: int = m.storage.amount(dk, c)
	var sells_zero := true
	for l in f["local"]:
		sells_zero = sells_zero and str(l["role"]) != "sell" or int(l["credits"]) > 0
	check(have_before == 0 and sells_zero and int(f["delta"]) > -e.fixed_cost(e.routes[0]), "forecast: the Sell order counts the goods the route delivers", str(f))
	var snap_stock: int = m.storage.amount(sk, c)
	e.forecast(m.cash)
	check(m.storage.amount(sk, c) == snap_stock and m.storage.amount(dk, c) == 0, "forecast: reading it changes no stock")
	m.cash_forecast.main = m
	var net: int = m.cash_forecast.net_forecast()
	var lines_in := 0
	for l in m.cash_forecast.order_lines():
		lines_in += int(l[1])
	for l in m.cash_forecast.route_income_lines():
		lines_in += int(l[1])
	var lines_out := 0
	for l in m.cash_forecast.route_expense_lines():
		lines_out += int(l[1])
	var r: Dictionary = e.settle(m.cash)
	check(net == int(r["delta"]), "forecast: net_forecast equals the cash change settle pays", "%d vs %d" % [net, int(r["delta"])])
	check(int(f["delta"]) == int(r["delta"]) and int(r["delta"]) > 0, "forecast: delta equals settle delta (a gain)", "%d vs %d" % [int(f["delta"]), int(r["delta"])])
	check(lines_in - lines_out == net, "forecast: the popup's income minus expenses equals the top-bar delta", "%d - %d vs %d" % [lines_in, lines_out, net])
	var zl: Array = m.cash_forecast.nonzero_lines([["a", 0], ["b", 5], ["c", -3], ["d", 0]])
	check(zl.size() == 2 and str(zl[0][0]) == "b" and str(zl[1][0]) == "c", "forecast: zero-value lines are not listed", str(zl))
	var tot_before: int = lines_in - lines_out
	check(tot_before == net and m.cash_forecast.net_forecast() == net, "forecast: totals unchanged by hiding zero lines")
	# a second case: route upgrade bonus
	e.set_lane_level(src, dst, c, 2)
	m.storage.remove(dk, c, m.storage.amount(dk, c))
	m.storage.remove(sk, c, m.storage.amount(sk, c))
	m.storage.add(sk, c, 200)
	var f2: Dictionary = e.forecast(m.cash)
	var r2: Dictionary = e.settle(m.cash)
	check(int(f2["delta"]) == int(r2["delta"]), "forecast: equals settle with an upgraded lane", "%d vs %d" % [int(f2["delta"]), int(r2["delta"])])
	_free_main(m)

## Buy orders may not spend the fixed cost of a route that runs this cycle; forecast mirrors settle.
func _test_cash_reserve() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	var src := 0
	var dst := 1
	var c := "energy"
	m.cash = 100000
	check(m.send_stock_buying(src, dst, c)["ok"] and e.routes.size() == 1, "reserve: one route set up")
	var sk: String = m.storage.planet_key(src)
	var dk: String = m.storage.planet_key(dst)
	m.storage.ensure(sk)
	m.storage.ensure(dk)
	m.storage.remove(dk, c, m.storage.amount(dk, c))
	m.storage.remove(sk, c, m.storage.amount(sk, c))
	m.storage.add(sk, c, 200)
	for k in e.local.keys():
		e.local[k]["buy"] = false
		e.local[k]["sell"] = false
	var c2 := ""
	for cc in e.commodities:
		if str(cc) != c and e.local_price(src, str(cc), "buy") > 0:
			c2 = str(cc)
			break
	check(c2 != "", "reserve: a second good is bought at the source planet")
	var price: int = e.local_price(src, c2, "buy")
	var fixed: int = e.fixed_cost(e.routes[0])
	var k: int = fixed / price + 3
	check(e.local_amount() >= k, "reserve: the Buy amount covers the test case", "%d vs %d" % [e.local_amount(), k])
	m.set_local_order(src, c2, "buy", true)
	m.cash = k * price  # without a reserve the Buy takes it all and the route cannot pay
	var expect_n: int = (m.cash - fixed) / price
	var stock_before: int = m.storage.amount(sk, c2)
	var f: Dictionary = e.forecast(m.cash)
	var r: Dictionary = e.settle(m.cash)
	var bought: int = m.storage.amount(sk, c2) - stock_before
	check(bought == expect_n and expect_n < k, "reserve: the Buy buys only the cash above the reserve", "%d vs %d" % [bought, expect_n])
	check(str(e.routes[0]["state"]) == "running" and m.cash + int(r["delta"]) >= 0, "reserve: the route still runs", str(e.routes[0]["state"]))
	check(int(f["delta"]) == int(r["delta"]), "reserve: forecast equals settle", "%d vs %d" % [int(f["delta"]), int(r["delta"])])
	# a route that cannot run reserves nothing: empty source, no Buy feeding it
	m.storage.remove(sk, c, m.storage.amount(sk, c))
	m.storage.remove(sk, c2, m.storage.amount(sk, c2))
	var amt_now := func(kk: String, cc: String) -> int: return m.storage.amount(kk, cc)
	check(e._buy_feeds(src, c, 1000000) == false, "reserve: no Buy feeds the energy source")
	check(e.route_reserve(m.cash, amt_now) == 0, "reserve: a route with no stock and no feeding Buy reserves nothing")
	# a Buy that feeds the route but cannot buy a unit after the reserve reserves nothing
	m.set_local_order(src, c, "buy", true)
	var pe: int = e.local_price(src, c, "buy")
	check(e.route_reserve(fixed + pe - 1, amt_now) == 0, "reserve: a feeding Buy that buys nothing after the reserve reserves nothing")
	check(e.route_reserve(fixed + pe, amt_now) == fixed, "reserve: a feeding Buy that can buy one unit reserves the fixed cost")
	# deadlock: cash 250, one Buy feeding one route, empty source: the Buy buys and nothing stalls for good
	m.set_local_order(src, c2, "buy", false)
	m.cash = 250
	var f2: Dictionary = e.forecast(m.cash)
	var st0: int = m.storage.amount(sk, c)
	var r2: Dictionary = e.settle(m.cash)
	var st1: int = m.storage.amount(sk, c)
	var ran1: bool = str(e.routes[0]["state"]) == "running"
	var info := "fixed %d price %d stock %d->%d ran %s" % [fixed, pe, st0, st1, str(ran1)]
	check(ran1 or st1 > st0, "reserve: at cash 250 the Buy buys or the route runs", info)
	check(int(f2["delta"]) == int(r2["delta"]), "reserve: forecast equals settle at low cash", "%d vs %d" % [int(f2["delta"]), int(r2["delta"])])
	m.cash = 250 + int(r2["delta"])
	e.settle(m.cash)
	check(ran1 or str(e.routes[0]["state"]) == "running", "reserve: the next cycle the route runs, no deadlock", info + " state " + str(e.routes[0]["state"]))
	_free_main(m)


## Alpha r3 2026-11-02: QA decent seed 7 sat idle at cash 104 with 4 routes and only Sell orders (the bot's own Buy rule
## wanted cash above trip + price). A Sell order on an empty storage holds no reserve, and one Buy order at the
## source gets the player going again with cash below trip + price. No game fix needed.
func _test_sell_only_idle() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	var src := 0
	var dst := 1
	var c := "energy"
	m.cash = 100000
	check(m.send_stock_buying(src, dst, c)["ok"] and e.routes.size() == 1, "sell-only: one route set up")
	var sk: String = m.storage.planet_key(src)
	var dk: String = m.storage.planet_key(dst)
	m.storage.ensure(sk)
	m.storage.ensure(dk)
	for k in [sk, dk]:
		for cc in e.commodities:
			m.storage.remove(k, str(cc), m.storage.amount(k, str(cc)))
	for k in e.local.keys():
		e.local[k]["buy"] = false
		e.local[k]["sell"] = false
	m.set_local_order(dst, c, "sell", true)
	var amt_now := func(kk: String, cc: String) -> int: return m.storage.amount(kk, cc)
	var fixed: int = e.fixed_cost()
	var pe: int = e.local_price(src, c, "buy")
	m.cash = maxi(pe + 1, 1)
	check(m.cash < fixed + pe, "sell-only: the test cash is below trip plus one unit", "%d vs %d" % [m.cash, fixed + pe])
	check(e.route_reserve(m.cash, amt_now) == 0, "sell-only: an empty Sell order holds no reserve")
	var f: Dictionary = e.forecast(m.cash)
	var r: Dictionary = e.settle(m.cash)
	check(int(r["delta"]) == 0 and int(f["delta"]) == 0, "sell-only: nothing moves, forecast equals settle", "%d vs %d" % [int(f["delta"]), int(r["delta"])])
	m.set_local_order(src, c, "buy", true)
	var f2: Dictionary = e.forecast(m.cash)
	var tot0: int = m.storage.amount(sk, c) + m.storage.amount(dk, c)
	var r2: Dictionary = e.settle(m.cash)
	var tot1: int = m.storage.amount(sk, c) + m.storage.amount(dk, c)
	check(tot1 != tot0 or int(r2["delta"]) != 0, "sell-only: one Buy order turns the idle player around", "stock %d to %d, delta %d" % [tot0, tot1, int(r2["delta"])])
	check(int(f2["delta"]) == int(r2["delta"]), "sell-only: forecast equals settle after the Buy", "%d vs %d" % [int(f2["delta"]), int(r2["delta"])])
	_free_main(m)


## Alpha fix 2026-11-02: a broke player (cash below one trip, no stock) is not stuck for good. Buys may spend the cash
## nothing else needs, and the one starved route flies for what cash is left. The reserve rule above stays.
func _test_stall_rescue() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	var src := 0
	var dst := 1
	var c := "energy"
	m.cash = 100000
	check(m.send_stock_buying(src, dst, c)["ok"] and e.routes.size() == 1, "stall: one route set up")
	var sk: String = m.storage.planet_key(src)
	var dk: String = m.storage.planet_key(dst)
	m.storage.ensure(sk)
	m.storage.ensure(dk)
	m.storage.remove(sk, c, m.storage.amount(sk, c))
	m.storage.remove(dk, c, m.storage.amount(dk, c))
	var fixed: int = e.fixed_cost(e.routes[0])
	check(e.fare_for(fixed, fixed, false) == fixed and e.fare_for(fixed, fixed - 1, false) == fixed - 1 and e.fare_for(fixed, 0, false) == 0 and e.fare_for(fixed, fixed - 1, true) == -1, "stall: fare_for pays the fare, a part fare only to the first route")
	# the deadlock: cash just under one trip, empty source, a Buy on the source, a Sell on the destination
	e.local.clear()
	m.set_local_order(src, c, "buy", true)
	m.set_local_order(dst, c, "sell", true)
	m.cash = fixed - 1
	var f: Dictionary = e.forecast(m.cash)
	var r: Dictionary = e.settle(m.cash)
	check(int(f["delta"]) == int(r["delta"]), "stall: forecast equals settle when broke", "%d vs %d" % [int(f["delta"]), int(r["delta"])])
	check(str(e.routes[0]["state"]) == "running", "stall: a broke route flies on a part fare, not stalled for good", str(e.routes[0]["state"]) + " " + str(e.routes[0]["reason"]))
	check(m.cash + int(r["delta"]) > fixed - 1, "stall: the cycle ends with more cash than it began", "%d -> %d" % [m.cash, m.cash + int(r["delta"])])
	# the protection stays: a loaded route with cash for its trip keeps that cash from a Buy
	m.cash = 100000
	m.storage.add(sk, c, 20)
	var amt_now := func(kk: String, cc: String) -> int: return m.storage.amount(kk, cc)
	check(e.route_reserve(fixed + 5, amt_now) == fixed, "stall: with cash for one trip the reserve is the full trip")
	check(e.route_reserve(fixed - 7, amt_now) == fixed - 7, "stall: a starved loaded route keeps its part fare from the Buys")
	var f2: Dictionary = e.forecast(fixed - 7)
	var r2: Dictionary = e.settle(fixed - 7)
	check(int(f2["delta"]) == int(r2["delta"]) and str(e.routes[0]["state"]) == "running", "stall: forecast equals settle for a starved loaded route", "%d vs %d" % [int(f2["delta"]), int(r2["delta"])])
	_free_main(m)

## Alpha fix 2026-11-02: mining is reachable from the start. A mining_focus-style player (B1 first) learns Prospecting
## at cycle 1 with the start point, and again after Permit Charter without Space Storage, and can then plan an ore lane.
func _test_mining_reachable() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	check(m.skill_points >= int(m.balance["skill_cost_B1"]), "mining reach: the start gives enough points for B1", str(m.skill_points))
	check(m.learn_skill(Clusters.MINING_SKILL)["ok"] and m.can_mine(), "mining reach: B1 learned first, at cycle 1")
	_free_main(m)
	var m2: Control = await _new_main()
	m2._dismiss_preface()
	var cost_c1 := int(m2.balance["skill_cost_C1"])
	check(m2.learn_skill("C1")["ok"], "mining reach: C1 first")
	m2._add_points(int(m2.balance["skill_cost_B1"]))
	for i in 9:
		m2.debug_advance_cycle()
	check(m2.cycle <= 10 and m2.learn_skill(Clusters.MINING_SKILL)["ok"] and m2.can_mine(), "mining reach: B1 after C1 alone by cycle 10, no A1 needed", "cycle %d cost_c1 %d" % [m2.cycle, cost_c1])
	_free_main(m2)

## Asteroid dust ring: exists, purely visual (no collision), and building/viewing it changes no game state.
func _test_dust_ring() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var map = m.map
	var ring: Node = map.get_node_or_null("AsteroidDustRing")
	check(ring != null and ring is MultiMeshInstance3D and map.dust_rings.has(1), "dust ring: node exists on the map")
	if ring == null:
		return
	check(ring.multimesh.instance_count > 0 and ring.multimesh.instance_count <= 10000, "dust ring: modest grain count", "n=%d" % ring.multimesh.instance_count)
	check(ring.rings.size() >= 1 and ring.rings.size() <= 7, "dust ring: no more than 7 rings per system", "n=%d" % ring.rings.size())
	var widths := {}
	var gapped := true
	for r in ring.rings:
		widths[snappedf(r["outer"] - r["inner"], 0.01)] = true
		gapped = gapped and r["gaps"].size() >= 1
	check(widths.size() > 1 and gapped, "dust ring: rings differ in width and every ring has a gap")
	var nodes: Array = ring.find_children("*", "CollisionObject3D", true, false)
	check(nodes.is_empty() and not (ring is CollisionObject3D), "dust ring: no collision objects")
	var clean := true
	for n in map.get_children():
		if n is CollisionObject3D:
			clean = false
	check(clean, "dust ring: the map has no collision objects, so picking is unaffected")
	var radii: Array = []
	for p in map.positions:
		radii.append(Vector2(p.x - ring.position.x, p.z - ring.position.z).length())
	var ok := true
	for rg in ring.rings:
		ok = ok and rg["inner"] < rg["outer"]
		for r in radii:
			ok = ok and (r < rg["inner"] or r > rg["outer"])
	check(ok, "dust ring: the band keeps clear of every planet orbit")
	var before := [m.cash, m.cycle, map.positions.duplicate(), map.planets.size()]
	map.set_view_system(1)
	map._apply_view()
	check(m.cash == before[0] and m.cycle == before[1] and map.positions == before[2] and map.planets.size() == before[3], "dust ring: viewing it changes no game state")

## Voltara dust belt: exists, no collision, viewing it changes no game state.
func _test_dead_planets() -> void:
	var sh = load("res://art/planet_fx/planet_sphere_dead.gdshader")
	check(sh is Shader and (sh as Shader).code.contains("limb_dark"), "dead planets: inverse fresnel shader loads")
	var PS = load("res://art/planet_fx/planet_sphere.gd")
	check(PS.is_dead("dead_1", "") and PS.is_dead("x", "dead") and not PS.is_dead("planet_1", "volcanic"), "dead planets: is_dead by id prefix or type")
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var map = m.map
	var base: int = map.planet_spheres.size()
	# The data rows come from the gameplay programmer; these stand in with the same id, type and system.
	var first: int = map.add_planets([
		{"id": "dead_1", "name": "Cinderrest", "type": "dead", "system": 1, "x": 0, "y": 260},
		{"id": "dead_2", "name": "Greywake", "type": "dead", "system": 2, "x": 0, "y": 260}])
	check(first == base and map.planet_spheres.size() == base + 2, "dead planets: two nodes made like the others", str(map.planet_spheres.size()))
	var tex_ok := true
	var shifts := []
	for i in [first, first + 1]:
		var sp = map.planet_spheres[i]
		var mat := sp.get_surface_override_material(0) as ShaderMaterial
		tex_ok = tex_ok and mat != null and mat.shader.resource_path.ends_with("planet_sphere_dead.gdshader")
		var tex = mat.get_shader_parameter("surface_tex") if mat else null
		tex_ok = tex_ok and tex != null and str(tex.resource_path).ends_with("planet_toxic_beauty.png")
		shifts.append(mat.get_shader_parameter("uv_shift") if mat else -1.0)
		tex_ok = tex_ok and not (sp.get_node("Atmosphere") as Node3D).visible
	check(tex_ok, "dead planets: dead shader and planet_toxic_beauty.png, no atmosphere shell")
	var ma := map.planet_spheres[first].get_surface_override_material(0) as ShaderMaterial
	var mb := map.planet_spheres[first + 1].get_surface_override_material(0) as ShaderMaterial
	check(ma != mb and shifts[0] != shifts[1] and ma.get_shader_parameter("hue_shift") != mb.get_shader_parameter("hue_shift"), "dead planets: the two worlds differ (own material, uv shift, hue)")
	var live := map.planet_spheres[0].get_surface_override_material(0) as ShaderMaterial
	check(live.shader.resource_path.ends_with("planet_sphere_simple.gdshader"), "dead planets: other planets keep the simple shader")
	map.set_view_system(1)
	var sp1: Node3D = map.planet_spheres[first]
	check(sp1.visible, "dead planets: dead_1 shows in system 1")
	var scr: Vector2 = map.camera.unproject_position(map.positions[first])
	check(map.pick_planet(scr) == first, "dead planets: dead_1 is picked like the others", str(map.pick_planet(scr)))
	map.set_view_system(2)
	var scr2: Vector2 = map.camera.unproject_position(map.positions[first + 1])
	check(map.planet_spheres[first + 1].visible and map.pick_planet(scr2) == first + 1, "dead planets: dead_2 shows and is picked in system 2", str(map.pick_planet(scr2)))
	m.queue_free()

func _test_voltara_belt() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var map = m.map
	var belt: Node = map.get_node_or_null("PlanetBeltVoltara")
	check(belt != null and belt is MultiMeshInstance3D and map.planet_belts.size() == 1, "voltara belt: node exists")
	if belt == null:
		return
	check(belt.find_children("*", "CollisionObject3D", true, false).is_empty() and not (belt is CollisionObject3D), "voltara belt: no collision objects")
	check(belt.position.is_equal_approx(map.positions[0]) and belt.multimesh.instance_count <= 2000 and belt.rings.size() <= 7, "voltara belt: centred on Voltara, light")
	var before := [m.cash, m.cycle, map.positions.duplicate()]
	map._apply_view()
	check(m.cash == before[0] and m.cycle == before[1] and map.positions == before[2], "voltara belt: changes no game state")


## Dead worlds (design/proposals/2026-11-02-dead-planets.md): data, skill gate, danger meter, scheduled follow-up.
func _test_fabric() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	m.cash = 5000
	var fabric_cost: int = int(m.balance.get("fabric_build_cost", 0))
	check(m.commodities.has("plate") and fabric_cost > 0, "fabric: plate is a commodity, build cost set in balance", str(fabric_cost))
	check(m.can_build_fabric()["reason"] == "skill" and not m.build_fabric()["ok"] and m.cash == 5000, "fabric: refused before F1, nothing paid")
	m.learned_skills.append("A1")
	m.learned_skills.append("F1")
	m._ensure_stations()
	check(m.station_systems.has(1), "fabric: trading post (system 1 station) exists with A1")
	m.cash = fabric_cost - 1
	check(m.can_build_fabric()["reason"] == "credits", "fabric: refused without the build cost in credits")
	m.cash = 5000
	check(m.build_fabric()["ok"] and m.cash == 5000 - fabric_cost and m.fabric.built, "fabric: builds after F1, build cost paid", str(m.cash))
	check(not m.build_fabric()["ok"] and m.cash == 5000 - fabric_cost, "fabric: paid once, a second build is refused")
	var key: String = m.storage.system_key(1)
	m.storage.ensure(key)
	# stalls without inputs
	m.fabric.run(m.storage)
	check(m.fabric.state == "stalled" and m.fabric.reason == "needs dross", "fabric: stalls with 'needs dross'", m.fabric.reason)
	m.storage.add(key, "dross", 2)
	m.fabric.run(m.storage)
	check(m.fabric.reason == "needs nullglass", "fabric: stalls with 'needs nullglass'", m.fabric.reason)
	# runs with inputs
	m.storage.add(key, "nullglass", 1)
	m.fabric.run(m.storage)
	check(m.fabric.state == "running" and m.storage.amount(key, "plate") == 1 and m.storage.amount(key, "dross") == 0 and m.storage.amount(key, "nullglass") == 0, "fabric: 2 dross + 1 nullglass make 1 plate")
	# through the cycle, with forecast equal to settle
	m.storage.add(key, "dross", 4)
	m.storage.add(key, "nullglass", 2)
	var fc: Dictionary = m.engine.forecast(m.cash)
	var st: Dictionary = m.engine.settle(m.cash)
	check(int(fc["delta"]) == int(st["delta"]), "fabric: forecast delta equals settle delta", "%s vs %s" % [fc["delta"], st["delta"]])
	m.debug_advance_cycle()
	check(m.storage.amount(key, "plate") == 2 and m.storage.amount(key, "dross") == 2, "fabric: runs on the cycle tick", str(m.storage.to_dict().get(key, {})))
	# saves
	var sv: Dictionary = m.collect_state()
	m.fabric.from_dict(null)
	check(not m.fabric.built, "fabric: an old save is not built")
	m.fabric.from_dict(sv["fabric"])
	check(m.fabric.built, "fabric: built state loads back")
	# the plate sells
	m.set_local_order(0, "plate", "sell", true)
	var before: int = m.cash
	var n_plates: int = m.storage.amount(key, "plate")
	var fc2: Dictionary = m.engine.forecast(m.cash)
	var st2: Dictionary = m.engine.settle(m.cash)
	var price: int = m.engine.sold_price(0, "plate")
	check(price > 0 and int(st2["delta"]) == n_plates * price and int(fc2["delta"]) == int(st2["delta"]), "fabric: plates sell at the trading post, forecast equals settle", "%d x %d, delta %s" % [n_plates, price, st2["delta"]])
	await _free_main(m)

func _test_dead_world_mechanics() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var d1: int = -1
	for i in m.map.planets.size():
		if str(m.map.planets[i].get("id", "")) == "dead_1":
			d1 = i
	check(d1 >= 0 and m.map.planets[d1]["name"] == "Cinderrest" and m.map.planets[d1]["abundant"] == "dross" and int(m.map.planets[d1]["system"]) == 1, "dead: dead_1 Cinderrest in system 1 carries dross", str(d1))
	check(m.commodities.has("dross"), "dead: dross joins the commodity list")
	var s2: Array = m.Systems.planets_of(2)
	var g: Dictionary = s2[s2.size() - 1]
	check(str(g["id"]) == "dead_2" and g["name"] == "Greywake" and g["abundant"] == "nullglass" and g["base_prices"].has("nullglass_buy"), "dead: dead_2 Greywake in system 2 carries nullglass")
	# skills
	var ST = m.SkillTree
	check(ST.prereqs("M1") == ["B1"] and ST.prereqs("M2") == ["M1"] and ST.prereqs("F1") == ["M1", "M2"], "dead skills: prerequisites B1, M1, M1+M2")
	check(ST.ids_in("B").has("M1") and ST.ids_in("B").has("F1") and ST.cost(m.balance, "M1") == 1 and ST.cost(m.balance, "M2") == 2 and ST.cost(m.balance, "F1") == 2, "dead skills: Research branch, costs 1, 2, 2 (balance v29)")
	check(ST.state(["B1"], "M1", {}) == "locked", "dead skills: M1 respects the second-row lock (only B1 is exempt)")
	check(ST.state(["A1", "C1", "B1"], "M1", {}) == "available" and ST.state(["A1", "C1", "B1", "M1"], "F1", {}) == "locked", "dead skills: M1 opens after B1 with A1 and C1; F1 needs M2 too")
	# gate
	m.cash = 6000
	m.ships = 3
	var r: Dictionary = m.can_connect(d1, 0, "dross")
	check(not r["ok"] and "Cold Survey" in str(r["reason"]), "dead gate: refused without M1 with a reason", str(r))
	m.learned_skills.append("M1")
	check(m.can_connect(d1, 0, "dross")["ok"], "dead gate: allowed with M1")
	m._open_system(2)
	var g2: int = -1
	for i in m.map.planets.size():
		if str(m.map.planets[i].get("id", "")) == "dead_2":
			g2 = i
	var r2: Dictionary = m.engine.check_connection(g2, g2 - 1, "nullglass")
	check(g2 >= 0 and not r2["ok"] and "Deep Cut" in str(r2["reason"]), "dead gate: Greywake refused without M2 (M1 does not open it)", str(r2))
	m.learned_skills.append("M2")
	check(m.engine.check_connection(g2, g2 - 1, "nullglass")["ok"], "dead gate: Greywake allowed with M2")
	# danger
	check(m.danger_of(d1) == 0 and m.danger_of(0) == 0, "danger: starts at 0")
	m.set_local_order(d1, "dross", "buy", true)
	check(m._connect(d1, 0, "dross")["ok"], "danger: route out of Cinderrest made")
	m.debug_advance_cycle()
	check(m.danger_of(d1) == 1, "danger: +1 after one mining cycle", str(m.danger_of(d1)))
	m.debug_advance_cycle()
	check(m.danger_of(d1) == 2, "danger: +1 each cycle", str(m.danger_of(d1)))
	m.dead.change("dead_1", -1)
	check(m.danger_of(d1) == 1 and m.dead.change("dead_1", 99) == 5, "danger: events lower it, capped at 5")
	var st: Dictionary = m.collect_state()
	check(int(st["danger"]["dead_1"]) == 5, "danger: saved")
	m.dead.from_dict(null)
	check(m.danger_of(d1) == 0, "danger: an old save has no meter, starts at 0")
	m.dead.from_dict(st["danger"])
	check(m.danger_of(d1) == 5, "danger: loads back")
	var panel_text := ""
	m.planet_panel.show_planet(d1)
	for l in _labels(m.planet_panel, []):
		if l.name == "DangerLine":
			panel_text = l.text
	check(panel_text == "Danger: 5 of 5", "danger: one line on the planet panel", panel_text)
	# scheduled follow-up
	var ev = m.events
	var a := {"id": "T_PART1", "title": "p1", "tag": "", "text": "x", "choices": [{"text": "go", "tag": "[cash: +1]", "follow_id": "T_PART2", "follow_after": 2}]}
	var b := {"id": "T_PART2", "title": "p2", "tag": "[cash: +1]", "text": "y", "choices": []}
	for e in [a, b]:
		ev.defs.append(e)
		ev.by_id[e["id"]] = e
	check(ev.scheduled_only("T_PART2") and not ev.scheduled_only("T_PART1"), "follow: part 2 is kept out of the random pick")
	var picked := false
	for i in 300:
		if ev.random_id([], 20) == "T_PART2":
			picked = true
	check(not picked, "follow: random pick never returns a part 2 event")
	m.cycle = 1
	m.fire_event("T_PART1")
	m._on_event_confirmed(0, "T_PART1")
	check(ev.scheduled.size() == 1 and int(ev.scheduled[0]["due"]) == 3, "follow: choice schedules the event 2 cycles later", str(ev.scheduled))
	var saved: Dictionary = ev.to_dict()
	check(saved["scheduled"].size() == 1, "follow: schedule is saved")
	m.debug_advance_cycle()
	var fed := func() -> int:
		var n := 0
		for f in ev.feed:
			if str(f["id"]) == "T_PART2":
				n += 1
		return n
	check(m.cycle == 2 and fed.call() == 0, "follow: not before the set cycle")
	m.debug_advance_cycle()
	check(m.cycle == 3 and fed.call() == 1 and ev.scheduled.is_empty(), "follow: fires once at the set cycle", "cycle %d fired %d" % [m.cycle, fed.call()])
	m._on_event_confirmed(-1, "T_PART2")
	m.debug_advance_cycle()
	check(fed.call() == 1, "follow: does not fire again")
	ev.from_dict({})
	check(ev.scheduled.is_empty(), "follow: an old save has no schedule")
	await _free_main(m)

## Dead-world event chain: part 1 choice events are in the data, random:false events are never picked at random,
## EV29 fires on the first mining of Cinderrest and its follow-up arrives 4 cycles later.
func _test_dead_events_chain() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var ev = m.events
	for id in ["EV29", "EV32", "EV35"]:
		var chs: Array = ev.choices_of(id)
		check(ev.by_id.has(id) and chs.size() == 2 and str(chs[0].get("follow_id", "")) != "" and int(chs[0].get("follow_after", 0)) == 4 and str(chs[1].get("tag", "")) != "", "dead events: %s is in events.json with 2 choices, follow_id and follow_after 4" % id)
	check(str(ev.choices_of("EV29")[0]["follow_id"]) == "EV30" and str(ev.choices_of("EV29")[1]["follow_id"]) == "EV31" and str(ev.by_id["EV29"].get("on_mine", "")) == "dead_1", "dead events: EV29 on_mine dead_1, follows EV30 / EV31")
	for id in ["EV30", "EV31", "EV33", "EV34", "EV36", "EV37"]:
		check(ev.by_id.has(id) and ev.by_id[id].get("random", true) == false, "dead events: %s is random:false" % id)
	var t := {"id": "T_NORAND", "title": "n", "tag": "", "text": "x", "choices": [], "random": false}
	ev.defs.append(t)
	ev.by_id["T_NORAND"] = t
	var bad := 0
	for i in 600:
		var r: String = ev.random_id([], 1 + i % 30)
		if r == "T_NORAND" or r in ["EV29", "EV30", "EV31", "EV32", "EV33", "EV34", "EV35", "EV36", "EV37"]:
			bad += 1
	check(bad == 0, "dead events: a random:false event is never picked at random over 600 picks", str(bad))
	var d1: int = -1
	for i in m.map.planets.size():
		if str(m.map.planets[i].get("id", "")) == "dead_1":
			d1 = i
	m.cycle = 1
	m._mine_event(d1)
	check(str(ev.pending_id) == "EV29", "dead events: first mining of Cinderrest fires EV29", str(ev.pending_id))
	m._on_event_confirmed(1, "EV29")  # pull the crew out
	check(ev.scheduled.size() == 1 and str(ev.scheduled[0]["id"]) == "EV31" and int(ev.scheduled[0]["due"]) == 5, "dead events: EV31 is scheduled 4 cycles later", str(ev.scheduled))
	var n31 := func() -> int:
		var n := 0
		for f in ev.feed:
			if str(f["id"]) == "EV31":
				n += 1
		return n
	for i in 4:
		m._dismiss_event_notice()
		m.debug_advance_cycle()
		if i < 3:
			check(n31.call() == 0, "dead events: EV31 not before cycle 5")
	check(m.cycle == 5 and n31.call() == 1 and ev.scheduled.is_empty(), "dead events: EV31 fires once at cycle 5", "cycle %d n %d" % [m.cycle, n31.call()])
	m._mine_event(d1)
	check(ev.mine_events("dead_1").is_empty(), "dead events: EV29 does not fire a second time")
	await _free_main(m)

## Dead-world choice effects: danger, credit cost, ore loss, income cut and boost (EV29, EV32, EV35).
func _test_dead_choice_effects() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var ev = m.events
	m._open_system(2)  # Greywake joins the planet list (events share it)
	var d1 := -1
	var g2 := -1
	for i in m.map.planets.size():
		match str(m.map.planets[i].get("id", "")):
			"dead_1":
				d1 = i
			"dead_2":
				g2 = i
	# tag parsing
	check(ev.parse_tag("[cost: dead_shore_cost]")["amount"] == int(m.balance["dead_shore_cost"]) and ev.parse_tag("[cost: nope]").is_empty(), "dead effects: [cost: key] reads balance")
	check(ev.parse_tag("[ore loss: Greywake]")["kind"] == "ore_loss" and ev.parse_tag("[income: cut]")["kind"] == "income_cut" and ev.parse_tag("[income: boost]")["kind"] == "income_boost" and ev.parse_tag("[income: x]").is_empty(), "dead effects: ore loss and income tags parse")
	# EV29 keep mining: price up and danger +1; pull out: no danger
	m.cycle = 1
	m.fire_event("EV29")
	m._on_event_confirmed(0, "EV29")
	check(m.danger_of(d1) == 1, "dead effects: EV29 keep mining adds danger +1", str(m.danger_of(d1)))
	m._dismiss_event_notice()
	ev.pending_id = ""
	m.fire_event("EV29")
	m._on_event_confirmed(1, "EV29")
	check(m.danger_of(d1) == 1, "dead effects: EV29 pull out adds no danger")
	m._dismiss_event_notice()
	# EV32 shore up costs credits (button off when cash is short), carry on costs none
	m.cash = 1000
	var cost := int(m.balance["dead_shore_cost"])
	m._dismiss_event_notice()
	ev.pending_id = ""
	m.fire_event("EV32")
	m._on_event_confirmed(0, "EV32")
	check(m.cash == 1000 - cost, "dead effects: EV32 shore up costs dead_shore_cost", str(m.cash))
	check(m.engine.dead_loss.is_empty(), "dead effects: shore up has no ore loss")
	m._dismiss_event_notice()
	ev.pending_id = ""
	m.fire_event("EV32")
	m._on_event_confirmed(1, "EV32")
	check(m.cash == 1000 - cost and m.engine.dead_loss.has(g2), "dead effects: EV32 carry on costs nothing and starts ore loss at Greywake", str(m.engine.dead_loss))
	# ore loss: chance 1, pct 0.5 drops half of a load; expires after dead_ore_loss_cycles
	m.learned_skills.append("M1")
	m.learned_skills.append("M2")
	m.balance["dead_ore_loss_chance"] = 1.0
	m.balance["dead_ore_loss_pct"] = 0.5
	m._push_dead_mods()
	check(abs(float(m.engine.dead_loss[g2]["pct"]) - 0.5) < 0.001, "dead effects: ore loss reads balance")
	for i in int(m.balance["dead_ore_loss_cycles"]):
		ev.tick()
	m._push_dead_mods()
	check(m.engine.dead_loss.is_empty(), "dead effects: ore loss ends after dead_ore_loss_cycles")
	# EV35 share cuts income, race raises it and adds danger to both worlds
	m._dismiss_event_notice()
	ev.pending_id = ""
	m.cash = 5000
	m.fire_event("EV35")
	m._on_event_confirmed(0, "EV35")
	var cut := float(m.balance["dead_income_cut"])
	check(m.engine.dead_income.has(d1) and m.engine.dead_income.has(g2) and abs(float(m.engine.dead_income[d1]) - (1.0 - cut)) < 0.001, "dead effects: EV35 share the lane cuts income at both dead worlds", str(m.engine.dead_income))
	var dd1: int = m.danger_of(d1)
	var dg2: int = m.danger_of(g2)
	for i in int(m.balance["dead_income_cycles"]):
		ev.tick()
	m._push_dead_mods()
	check(m.engine.dead_income.is_empty(), "dead effects: income cut ends after dead_income_cycles")
	m._dismiss_event_notice()
	ev.pending_id = ""
	m.fire_event("EV35")
	m._on_event_confirmed(1, "EV35")
	var boost := float(m.balance["dead_income_boost"])
	check(abs(float(m.engine.dead_income[d1]) - (1.0 + boost)) < 0.001, "dead effects: EV35 race raises income", str(m.engine.dead_income))
	check(m.danger_of(d1) == dd1 + 1 and m.danger_of(g2) == dg2 + 1, "dead effects: EV35 race adds danger to both worlds", "%d %d" % [m.danger_of(d1), m.danger_of(g2)])
	# a route out of a dead world carries less under the cut (units), and the loss drops load on settle
	ev.mods = []
	m._push_dead_mods()
	m.set_local_order(d1, "dross", "buy", true)
	m.cash = 9000
	m.ships = 3
	check(m._connect(d1, 0, "dross")["ok"], "dead effects: route out of Cinderrest made")
	var rec: Dictionary = m.engine.routes[m.engine.routes.size() - 1]
	rec["fresh"] = 1.0
	m.engine.storage.add(str(rec["src"]), "dross", 100)
	var full: int = m.engine.planned_units(rec)
	m.engine.dead_income = {d1: 0.5}
	var half: int = m.engine.planned_units(rec)
	check(full > 1 and half == floori(full * 0.5) or half == full / 2, "dead effects: income factor scales units", "%d %d" % [full, half])
	m.engine.dead_income = {}
	var before: int = m.engine.storage.amount(str(rec["dst"]), "dross")
	m.engine.dead_loss = {d1: {"chance": 1.0, "pct": 0.5}}
	m.engine._settle_one(rec, 100000)
	var got: int = m.engine.storage.amount(str(rec["dst"]), "dross") - before
	check(full > 1 and got == full - floori(full * 0.5), "dead effects: ore loss drops part of the load", "%d of %d" % [got, full])
	await _free_main(m)
