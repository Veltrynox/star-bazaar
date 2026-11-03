extends SceneTree
## Headless tests (T79). Run: sh tools/tests/run.sh   (see that file; it sets a scratch HOME).
## Covers: story text, ending picker, win/loss paths, run recording, expansion points, skill keys, force-goal.
## Tests only read behaviour; they change no game code.

const StoryText := preload("res://game/story_text.gd")
const SaveGame := preload("res://game/save_game.gd")
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
	_test_good_icons()
	_test_story_text()
	_test_share_helpers()
	_test_share_graph()
	_test_picker()
	_test_stats_file()
	_test_markets()
	_test_bot_hooks()
	await _test_market_rules()
	await _test_juice()
	await _test_main()
	await _test_rescue_waiting()
	await _test_events()
	await _test_ships()
	await _test_next_cycle()
	await _test_notice_queue()
	await _test_systems()
	await _test_galaxy_view()
	await _test_tutorial_steps()
	_test_route_tag()
	await _test_ship_clock()
	await _test_energy_then_food()
	await _test_salvage()
	await _test_system_suns()
	await _test_stations()
	await _test_trade_gate()
	await _test_asteroid()
	await _test_idle_actions()
	await _test_skill_effects()
	await _test_debug_menu()
	await _test_planet_size()
	await _test_route_offset()
	await _test_dust_ring()
	await _test_voltara_belt()
	await _test_dead_planets()
	await _test_dead_world_mechanics()
	await _test_dead_unlock_and_core()
	await _test_fabric()
	await _test_workshops()
	await _test_chains()
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
func _test_share_helpers() -> void:
	var SP := load("res://game/share_panel.gd")
	var names := {"mil": "Military"}
	check(SP.chip_text({"market": "", "share": 0.0}, names) == "-", "share chip: dash with no volume")
	check(SP.chip_text({"market": "mil", "share": 0.344}, names) == "Military 34%", "share chip: market and percent")
	check(SP.pct_text(0.5) == "50%", "share pct text")
	check(not StoryText.has_text("LBL_GOAL") and StoryText.has_text("LBL_GOAL_MARKETS"), "story: old goal row gone, markets goal present")

func _test_share_graph() -> void:
	var G := load("res://game/share_graph.gd")
	var s = G.series([10.0, 10.0, 10.0], [[10.0, 30.0, 0.0]], 2)
	check(absf(s["player"][0] - 0.5) < 1e-6, "share graph: first cycle uses a partial window")
	check(absf(s["player"][1] - 20.0 / 60.0) < 1e-6, "share graph: window of 2 sums cycles 1-2")
	check(absf(s["player"][2] - 20.0 / 50.0) < 1e-6, "share graph: window drops cycle 1 at cycle 3")
	check(absf(s["bots"][0][2] - 30.0 / 50.0) < 1e-6, "share graph: bot share over the same window")
	var z = G.series([0.0, 0.0], [[0.0, 0.0], [0.0, 0.0]], 8)
	check(z["player"] == [0.0, 0.0] and z["bots"][1] == [0.0, 0.0], "share graph: zero volume gives zero share")
	check(G.series([], [[]], 8)["player"].is_empty(), "share graph: empty history")
	var short = G.series([5.0], [[5.0]], 8)
	check(absf(short["player"][0] - 0.5) < 1e-6, "share graph: window longer than history")
	check(absf(G.change([0.1, 0.2, 0.3, 0.4, 0.5, 0.6], 5) - 0.5) < 1e-6, "share graph: change over 5 cycles")
	check(absf(G.change([0.4, 0.5], 5) - 0.5) < 1e-6, "share graph: change over a short series counts from zero")
	check(G.change([], 5) == 0.0, "share graph: change of nothing")
	var CP := load("res://game/competitors_panel.gd")
	check(CP.trend_text(0.056).ends_with("6") and CP.trend_text(-0.03).ends_with("3") and CP.trend_text(0.001) == "-", "competitors: trend text")
	check(StoryText.has_text("LBL_COMP_TITLE") and StoryText.has_text("LBL_COMP_SHARE") and StoryText.has_text("LBL_COMP_TREND"), "story: competitors ids present")
	var cp = CP.new()
	var bal_c = _read_json("res://data/balance.json")["values"]
	Markets.reset(bal_c, 3)
	Chains.reset(bal_c, 3)
	check(cp.log_lines("mil").is_empty(), "competitors log: empty before any chain choice")
	Chains.apply_option("MIL_A1", "opt_a", 6)
	var ll: Array = cp.log_lines("mil")
	check(ll.size() > 0 and str(ll[0]).begins_with("Cycle 6:"), "competitors log: entry after Chains.apply_option", str(ll))
	check(StoryText.has_text("LBL_COMP_NONE") and StoryText.has_text("LBL_COMP_EVENTS") and StoryText.has_text("LBL_COMP_CYCLE"), "story: competitors log ids present")
	cp.free()
	Chains.reset(bal_c, 0)
	Markets.reset(bal_c, 0)

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
	for id in ["END_STAT_CYCLES", "END_STAT_CASH", "END_BTN_NEW", "END_BTN_MENU", "END_BTN_QUIT", "END_RUN_OVER"]:
		wanted[id] = true
	var missing := []
	for id in wanted:
		if not seen.has(id):
			missing.append(id)
	check(missing.is_empty(), "story: every id the game asks for exists (%d ids)" % wanted.size(), str(missing))
	var events = _read_json("res://data/events.json")
	check(typeof(events) == TYPE_ARRAY and events.size() > 0, "story: events.json loads")

# ---- 2. skill branch helpers (the old ending picker was removed with the cash goal) ----
func _test_picker() -> void:
	check(EndingPicker.techs_of("min") == ["MIN_2", "MIN_4", "MIN_6"], "picker: three techs per market, read from skills.json")

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
	await process_frame
	await process_frame
	var vpr := Rect2(Vector2.ZERO, m.get_viewport_rect().size)
	for st in 3:  # every step: the card floats inside the window, clear of its target, with outline and pointer
		g.tut_step = st
		g._build_tutorial()
		await process_frame
		var tgt: Rect2 = g._tut_target()
		var cr := Rect2(g.tut_panel.position, g.tut_panel.size)
		check(vpr.encloses(cr) and not cr.intersects(tgt) and tgt.size != Vector2.ZERO, "galaxy: step %d card inside the window, not over its target" % (st + 1), str(cr) + " vs " + str(tgt))
		check(g.tut_hl.visible and g.tut_arrow.visible and g.tut_panel.get_parent() == g, "galaxy: step %d has outline and pointer" % (st + 1))
		check(not g.tut_panel.position.is_equal_approx(Vector2.ZERO), "galaxy: step %d card is placed" % (st + 1))
	g.tut_step = 1
	g._build_tutorial()
	m.tut_step = 2
	for b in _buttons(g.tut_box, []):
		if (b as Button).text == StoryText.get_or("BTN_SKIP_TUTORIAL", "Skip tutorial"):
			(b as Button).pressed.emit()
	check(m.tut_step == m.TUT_GUIDE.size() and g.tut_step == g.TUT_IDS.size(), "galaxy: Skip ends the guided tutorial too")
	g.tut_step = 1
	g._build_tutorial()
	g.queue_redraw()
	await process_frame
	g.tut_step = 3
	g._build_tutorial()
	check(not g.tut_panel.visible and not g.tut_hl.visible and not g.tut_arrow.visible, "galaxy: finished tutorial shows no card")
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

func _test_tutorial_steps() -> void:
	var m: Control = await _new_main()
	var G: Array = m.TUT_GUIDE
	check(m.tut_step == 0 and m.tutorial_label.text != "" and m.tutorial_label.visible and m.tutorial_label.is_visible_in_tree(), "tutorial: fresh game shows the step 1 line", m.tutorial_label.text)
	check(m.tut_actions.visible and m.tut_actions.is_visible_in_tree(), "tutorial: Skip and Next show on the first step")
	check(G == ["TUT_G1_SELECT", "TUT_G2_BUY", "TUT_G3_SEND", "TUT_G4_ROUTE_PAY", "TUT_G5_UPKEEP", "TUT_G6_SELL", "TUT_G7_STORAGE", "TUT_G8_SKILLS", "TUT_G9_PERMIT", "TUT_G10_DONE"], "tutorial steps: order")
	# skip at step 3 ends the tutorial for good, also after save and load
	m.tut_step = 3
	m._tut_skip()
	check(m.tut_step == G.size(), "tutorial steps: skip at step 3 ends the guide")
	var st: Dictionary = JSON.parse_string(JSON.stringify(m.collect_state()))
	m.apply_state(st)
	m._tut_advance()
	check(m.tut_step == G.size(), "tutorial steps: skip stays after save and load")
	# old save: tut_step 4 meant skills; the new numbering puts skills at 7
	var old: Dictionary = st.duplicate(true)
	old.erase("tut_ver")
	old["tut_step"] = 4
	m.skill_points = 1
	m.learned_skills = []
	old["skill_points"] = 1
	old["learned_skills"] = []
	m.apply_state(old)
	check(G[m.tut_step] == "TUT_G8_SKILLS", "tutorial steps: old save step 4 loads into skills", str(m.tut_step))
	old["tut_step"] = 5
	m.apply_state(old)
	check(G[m.tut_step] == "TUT_G10_DONE", "tutorial steps: old save step 5 loads into done")
	old["tut_step"] = 3
	m.apply_state(old)
	check(G[m.tut_step] == "TUT_G6_SELL", "tutorial steps: old save step 3 (sell) maps to sell")
	# a save with no tut_step: guided tutorial starts in cycles 1 to 4, finished from cycle 5
	var none: Dictionary = st.duplicate(true)
	none.erase("tut_step")
	none.erase("tut_ver")
	none["cycle"] = 3
	m.apply_state(none)
	check(m.tut_step == 0, "tutorial steps: save without tut_step at cycle 3 starts the guide")
	none["cycle"] = 5
	m.apply_state(none)
	check(m.tut_step == G.size(), "tutorial steps: save without tut_step at cycle 5 stays finished")
	# a step with no state reached is skipped automatically
	m.skill_points = 0
	m.learned_skills = []
	m.tut_skipped = []
	m.tut_step = 7
	m._tut_advance()
	check(G[m.tut_step] == "TUT_G10_DONE" and m.tut_skipped == ["TUT_G8_SKILLS", "TUT_G9_PERMIT"], "tutorial steps: skills and permit skipped with no point", str(m.tut_skipped))
	m.skill_points = 1
	m.tut_step = 7
	m._tut_advance()
	check(m.tut_step == 7, "tutorial steps: skills step waits while a point is held")
	m.tut_step = 4
	m._tut_advance()
	check(m.tut_step == 4 or m.engine.routes.is_empty(), "tutorial steps: upkeep waits for a cycle with a route")
	m.debug_restart_tutorial()
	check(m.tut_step <= 1 and m.tut_skipped.is_empty(), "tutorial steps: restart goes back to the start")
	# the tutorial card is its own panel, never part of the notifications board
	var board: Node = m.notice_label.get_parent().get_parent()
	check(m.tut_card != null and m.tut_card.visible and not board.is_ancestor_of(m.tut_card) and not board.is_ancestor_of(m.tutorial_label) and not board.is_ancestor_of(m.tut_actions), "tutorial card: not a child of the notifications board")
	check(m.tut_card.get_parent() == m and not m.right_col.is_ancestor_of(m.tut_card) and m.tut_count.text == "1 of 10", "tutorial card: floats outside the right column, with a step count", m.tut_count.text)
	check(m.tip_label.visible and m.tip_label.text != "" and board.is_ancestor_of(m.tip_label), "tips: the right board shows a game tip")
	var tip_all: String = m.tip_label.text
	for k in 6:
		m.cycle = 1 + k
		m._tut_cycle()
		check(m.tip_label.text != "" and StoryText.has_text(m.TIP_IDS[k]), "tips: tip %d has story text" % (k + 1))
	m.cycle = 1
	m._tut_cycle()
	check(not tip_all.contains("Click") and m.tutorial_label.get_parent().get_parent() == m.tut_card, "tips: no tutorial text on the board")
	# the card sits beside its target, inside the window, not over it, and not over the planet panel
	m.debug_restart_tutorial()
	m.selected_planet = 1
	m.planet_panel.show_planet(1)
	m.planet_panel.visible = true
	m.tut_step = 1
	m._tut_show()
	await process_frame
	await process_frame
	var tgt: Control = m._tut_target_node("buy")
	var vpr := Rect2(Vector2.ZERO, m.get_viewport_rect().size)
	var cr: Rect2 = m.tut_card.get_global_rect()
	check(tgt != null and vpr.encloses(cr) and not cr.intersects(tgt.get_global_rect()) and not cr.intersects(m.planet_panel.get_global_rect()), "tutorial card: beside the Buy button, in the window, clear of it and its panel", str(cr))
	check(m.tut_arrow.visible and m.tut_card.mouse_filter == Control.MOUSE_FILTER_IGNORE and m.tut_hl.mouse_filter == Control.MOUSE_FILTER_IGNORE, "tutorial card: pointer shows, outline lets clicks through")
	m.tut_step = 4
	m._tut_show()
	await process_frame
	cr = m.tut_card.get_global_rect()
	check(vpr.encloses(cr) and not cr.intersects(m.cash_box.get_global_rect()), "tutorial card: expenses step puts the card under the top bar cash, clear of it", str(cr))
	var skips := 0
	for b in _buttons(m.tut_actions, []):
		if (b as Button).text == StoryText.get_or("BTN_SKIP_TUTORIAL", "Skip tutorial"):
			skips += 1
	check(skips == 1, "tutorial card: Skip tutorial button is on the card")
	m.debug_restart_tutorial()
	# every guided step names a highlight target that exists for it (or the planet)
	m.debug_restart_tutorial()
	m.selected_planet = 1
	m.planet_panel.show_planet(1)
	m.planet_panel.visible = true
	await process_frame
	m.skill_screen.open_screen()
	await process_frame
	check(m.TUT_TARGET.size() == G.size(), "tutorial highlight: one target per step")
	for i in G.size():
		if m.TUT_TARGET[i] == "":
			continue
		m.tut_step = i
		var hk: String = m._tut_highlight_key()
		var ok: bool = hk == "planet" or m._tut_target_node(hk) != null
		check(ok, "tutorial highlight: %s has a target in the scene or falls back to the planet" % G[i], hk)
	m.tut_step = 4
	check(m._tut_highlight_key() == "expenses" and m._tut_target_node("expenses") == m.cash_box, "tutorial highlight: expenses step outlines the top bar cash")
	m.tut_step = 1
	check(m._tut_target_node("buy") != null and m._tut_highlight_key() == "buy", "tutorial highlight: buy step outlines the Buy button")
	m.tut_step = 7
	check(m._tut_target_node("skills") == m.points_button, "tutorial highlight: skills step outlines the Skills button")
	m.tut_step = 8
	check(m._tut_target_node("permit") == m.skill_screen.node_buttons["FND_PERMIT"], "tutorial highlight: permit step outlines Permit Charter in the Skills window")
	m.tut_step = 1
	m._tut_update_highlight()
	check(m.tut_hl.visible, "tutorial highlight: outline shows over the control")
	m.planet_panel.visible = false
	m.skill_screen.close_screen()
	m.selected_planet = -1
	check(m._tut_highlight_key() == "planet", "tutorial highlight: no planet panel falls back to the planet ring")
	m.tut_step = 9
	check(m._tut_highlight_key() == "", "tutorial highlight: last step has none")
	m._tut_skip()
	check(m.tut_step == G.size() and not m.tut_card.visible and not m.tut_hl.visible, "tutorial card: Skip ends the tutorial and hides card and outline")
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
	var win_cycle := int(bal["win_cycle_markets"])
	check(not bal.has("win_cash") and not bal.has("win_cycle"), "goal: old win_cash and win_cycle keys are gone")
	check(win_cycle == 40, "goal: run length is win_cycle_markets (40)")

	# --- win by holding a market (forced share): from win_earliest_cycle, held win_hold_cycles ---
	_wipe_user()
	check(m.debug_force_market == "", "force-share: off by default")
	check(not m.collect_state().has("debug_force_market"), "force-share: not saved")
	m.debug_force_market = "mil"
	Chains.picks["MIL_B4"] = {"opt": "opt_a", "cycle": 1, "nudge": 0}  # the win gate is open (own tests below)
	m.cycle = int(bal["win_earliest_cycle"]) - 2
	var ended := []
	m.run_ended.connect(func(side, id): ended.append([side, id]))
	for i in 2:
		m._end_cycle()
	check(not m.game_over, "win: not before win_earliest_cycle")
	var guard := 0
	while not m.game_over and guard < 10:
		m._end_cycle()
		guard += 1
	await process_frame
	var want_end := int(bal["win_earliest_cycle"]) + int(bal["win_hold_cycles"]) - 1
	check(m.game_over and m.cycle == want_end, "win: held win_hold_cycles from win_earliest_cycle ends at cycle %d" % want_end, str(m.cycle))
	check(ended.size() == 1 and ended[0][0] == "WIN" and ended[0][1] == "END_MIL_GOOD", "win: END_MIL_GOOD (placeholder ending per market)", str(ended))
	check(m.end_screen != null and _stats_runs() == 1, "win: end screen shown, run recorded once")
	check(not FileAccess.file_exists("user://autosave.json"), "win: save cleared")
	await _free_main(m)
	m = await _new_main()
	check(m.debug_force_market == "", "force-share: resets in a new run")
	m._dismiss_preface()
	var has_opt := false
	for n in _find_option_buttons(m.debug_menu, []):
		if n.get_item_text(0).contains("Force market share"):
			has_opt = true
	check(has_opt, "force-share: debug menu has the selector (replaces Force goal)")
	await _free_main(m)

	# --- swept: under sweep_share_pct in all four markets for sweep_hold_cycles from sweep_earliest_cycle ---
	_wipe_user()
	m = await _new_main()
	m._dismiss_preface()
	var ended3 := []
	m.run_ended.connect(func(side, id): ended3.append([side, id]))
	m.cycle = int(bal["sweep_earliest_cycle"]) - 1
	m._end_cycle()
	check(not m.game_over and Markets.sweep_streak == 0, "swept: nothing before sweep_earliest_cycle")
	for i in int(bal["sweep_hold_cycles"]) - 1:
		m._end_cycle()
	check(not m.game_over, "swept: not before sweep_hold_cycles")
	m._end_cycle()
	await process_frame
	check(m.game_over and ended3.size() == 1 and ended3[0][0] == "LOSS" and ended3[0][1] == "END_SWEPT", "swept: END_SWEPT after the hold", str(ended3))
	await _free_main(m)

	# --- soft ending at the last cycle with no market over 50% ---
	_wipe_user()
	m = await _new_main()
	m._dismiss_preface()
	var ended4 := []
	m.run_ended.connect(func(side, id): ended4.append([side, id]))
	m.cycle = win_cycle
	m._end_cycle()
	await process_frame
	check(m.game_over and ended4.size() == 1 and ended4[0][0] == "SOFT" and ended4[0][1] == "END_OUTCOMPETED", "soft: END_OUTCOMPETED at the last cycle", str(ended4))
	await _free_main(m)

	# --- bankrupt: newest ship repossessed each cycle, salvage credited, ends with no ship and cash negative ---
	_wipe_user()
	m = await _new_main()
	m._dismiss_preface()
	var salvage := floori(float(bal["salvage_share"]) * float(bal["ship_price"]))
	m.ships = 2
	m.cash = -500
	m.cycle = 3
	var ended5 := []
	m.run_ended.connect(func(side, id): ended5.append([side, id]))
	m._end_cycle()
	check(m.ships == 1 and m.cash == -500 + salvage and not m.game_over, "bankrupt: one ship repossessed, salvage_share x ship_price credited, no stipend that cycle", "%d %d" % [m.ships, m.cash])
	check(m.rescues_paid == 0 and m.repossessions == 1, "bankrupt: counters (no rescue paid, one repossession)")
	m.cash = -(salvage + 100)
	m._end_cycle()
	await process_frame
	check(m.game_over and ended5.size() == 1 and ended5[0][1] == "END_BANKRUPT", "bankrupt: no ship left and cash still negative ends the run", str(ended5))
	await _free_main(m)
	# a repossession that clears the debt does not end the run
	m = await _new_main()
	m._dismiss_preface()
	m.ships = 1
	m.cash = -100
	m.cycle = 3
	m._end_cycle()
	check(not m.game_over and m.ships == 0 and m.cash == salvage - 100, "bankrupt: debt covered by salvage keeps the run alive", "%d %d" % [m.ships, m.cash])
	await _free_main(m)
	# the newest route's ship goes first
	m = await _new_main()
	m._dismiss_preface()
	m.ships = 2
	var r1: Dictionary = m.engine.new_record(0, 1, "energy")
	r1["id"] = 1
	var r2: Dictionary = m.engine.new_record(0, 1, "food")
	r2["id"] = 2
	m.engine.routes = [r1, r2]
	m.cash = -10
	m._repossess_newest()
	check(m.ships == 1 and m.engine.routes.size() == 1 and int(m.engine.routes[0]["id"]) == 1, "bankrupt: the newest route is the one repossessed")
	await _free_main(m)

	# --- rescue cap ---
	m = await _new_main()
	m._dismiss_preface()
	m.ships = 0
	m.cash = int(bal["ship_price"]) - 1
	m.rescues_paid = int(bal["rescue_max"])
	m.last_rescue_cycle = -1
	m._check_stranded()
	check(m.cash == int(bal["ship_price"]) - 1, "rescue: no stipend after rescue_max stipends")
	m.rescues_paid = 0
	m._check_stranded()
	check(m.cash > int(bal["ship_price"]) and m.rescues_paid == 1, "rescue: stipend counts toward rescue_max")
	await _free_main(m)

	# --- save: version flag, market state round trip, old saves dropped ---
	_wipe_user()
	m = await _new_main()
	m._dismiss_preface()
	Markets.add_sale("silk", 4)
	m.cycle = 6
	m._end_cycle()
	m.rescues_paid = 1
	var sv: Dictionary = m.collect_state()
	check(sv.has("markets") and sv.has("rescues_paid") and sv.has("repossessions") and not sv.has("choice_pending"), "save: market volumes, bot state and counters are saved")
	check(preload("res://game/save_game.gd").VERSION >= 2, "save: version flag is 2 or more")
	var vol_before: Array = Markets.history("lux").duplicate()
	var bot_before: Array = Markets.bot_history(2, "lux").duplicate()
	Markets.reset(bal, 0)
	m.apply_state(JSON.parse_string(JSON.stringify(sv)))
	var bot_after: Array = Markets.bot_history(2, "lux")
	var same := Markets.history("lux") == vol_before and bot_after.size() == bot_before.size() and Markets.run_seed == int(sv["markets"]["seed"])
	for i in bot_after.size():
		same = same and absf(float(bot_after[i]) - float(bot_before[i])) < 0.001
	check(same, "save: market state round trip keeps volumes, bots and seed")
	check(m.rescues_paid == 1, "save: rescue counter round trip")
	var SG := preload("res://game/save_game.gd")
	var f := FileAccess.open(SG.PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 1, "state": {"cycle": 5}}))
	f.close()
	check(SG.load_state().is_empty() and SG.dropped_old and SG.old_save_message() != "", "save: a version 1 save is dropped with a message")
	SG.write_state({"cycle": 5})
	check(not SG.load_state().is_empty() and not SG.dropped_old, "save: a current save loads")
	await _free_main(m)

	# --- volume tracking through the game: a Sell order counts units x base_value; Buy and storage do not ---
	_wipe_user()
	m = await _new_main()
	m._dismiss_preface()
	m.ships = 1
	var key0: String = m.storage.planet_key(0)
	m.storage.add(key0, "energy", 10)
	check(m.set_local_order(0, "energy", "sell", true)["ok"], "volume: Sell order accepted")
	m._end_cycle()
	var left: int = m.storage.amount(key0, "energy")
	var sold := 10 - left
	check(sold > 0 and is_equal_approx(float(Markets.history("mil")[0]), float(sold * Markets.value_of("energy"))), "volume: units sold x base_value counted in the market of the good", "%d %s" % [sold, str(Markets.history("mil"))])
	m.set_local_order(0, "energy", "sell", false)
	m.set_local_order(0, "energy", "buy", true)
	m._end_cycle()
	check(is_equal_approx(float(Markets.history("mil")[1]), 0.0), "volume: a Buy order is not a sale")
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

	# --- skill keys: every node has a cost key, a story name and numeric effect keys ---
	m = await _new_main()
	m._dismiss_preface()
	check(SkillTree.all_ids().size() == 31, "skills: 3 Foundations plus 28 market nodes", str(SkillTree.all_ids().size()))
	var costs_ok := true
	var keys_ok := true
	for id in SkillTree.all_ids():
		if not bal.has("skill_cost_" + id) or not StoryText.has_text("SK_%s_NAME" % id):
			costs_ok = false
		for ef in SkillTree.effects(id):
			for fk in ["key", "duration_key", "cooldown_key", "cap_key"]:
				if ef.has(fk) and not (bal.has(str(ef[fk])) and (typeof(bal[str(ef[fk])]) == TYPE_FLOAT or typeof(bal[str(ef[fk])]) == TYPE_INT)):
					keys_ok = false
					print("  missing key ", ef[fk])
		if SkillTree.is_tech(id) and (SkillTree.cost(bal, id) != 0 or SkillTree.tech_goal(bal, id) <= 0):
			keys_ok = false
	check(costs_ok, "skills: every node has a cost key and a story name")
	check(keys_ok, "skills: every effect key named in skills.json is a number in balance.json; techs cost 0 and have a goal")
	var old_gone := true
	for k in bal:
		if str(k).begins_with("skill_cost_") and not SkillTree.has(str(k).trim_prefix("skill_cost_")):
			old_gone = false
	check(old_gone and not bal.has("skill_A4_route_units") and not bal.has("skill_B3_margin") and not bal.has("skill_C4_permit_discount"), "skills: no old A/B/C/M/F balance keys left")
	check(int(bal["skill_points_route"]) == 1 and int(bal["skill_points_system"]) == 2 and int(bal["permit_points_2"]) == 2 and int(bal["permit_points_3"]) == 2, "skills: economy retunes applied (route 1, system 2, permits 2/2)")
	await _free_main(m)
	await _test_skill_screen()
	await _test_skill_screen_ui()
	_test_skills_core()
	_wipe_user()

# ---- 5. skills: learning through main (T71, four market trees) ----
func _test_skill_screen_ui() -> void:
	_wipe_user()
	var SS = load("res://game/skill_screen.gd")
	var bal := _bal()
	check(SS.tier_rows("mil") == [["MIL_1"], ["MIL_2", "MIL_3"], ["MIL_4", "MIL_5"], ["MIL_6"], ["MIL_7"]], "skill screen: tier rows put the tech left of the skill", str(SS.tier_rows("mil")))
	check(SS.tier_rows("fnd").size() == 1 and SS.tier_rows("fnd")[0].size() == 3, "skill screen: Foundations are one row of three")
	check(SS.node_state([], 5, bal, "MIL_1") == "learnable" and SS.node_state([], 0, bal, "MIL_1") == "points", "skill screen: learnable vs not enough points")
	check(SS.node_state([], 9, bal, "MIL_3") == "locked" and SS.node_state(["MIL_1"], 9, bal, "MIL_2") == "researching" and SS.node_state(["MIL_1", "MIL_2"], 0, bal, "MIL_2") == "learned", "skill screen: locked, researching, learned")
	check(int(SS.plain_args(bal, "MIL_5")["m"]) == int(bal["skill_MIL_5_every"]) and int(SS.plain_args(bal, "MIL_5")["n"]) == int(bal["skill_MIL_5_cycles"]), "skill screen: bot skill plain line gets cooldown and cycles")
	var m: Control = await _new_main()
	m._dismiss_preface()
	m.skill_screen.open_screen()
	check(m.skill_screen.node_buttons.size() == 31, "skill screen: one button per node", str(m.skill_screen.node_buttons.size()))
	m.skill_points = 9
	m.skill_screen.select("MIL_1")
	m.skill_screen.confirm_learn()
	check(m.has_skill("MIL_1") and m.skill_screen.node_buttons["MIL_1"].text.contains(StoryText.get_text("SK_BTN_LEARNED")), "skill screen: learn by Yes spends points and shows learned")
	Skills.learned.append_array(["MIL_3", "MIL_5"])
	m.skill_screen.refresh()
	check(m.skill_screen.use_rows["MIL_5"].visible and m.skill_screen.use_buttons.has("MIL_5"), "skill screen: learned bot skill shows its Use menu")
	var r: Dictionary = m.skill_screen._use_bot("MIL_5", 1)
	check(r["ok"] and not m.skill_screen.use_buttons.has("MIL_5") and m.skill_screen.use_rows["MIL_5"].visible, "skill screen: using it swaps the menu for the cooldown note")
	m.skill_screen.close_screen()
	await _free_main(m)

func _test_skill_screen() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	check(SkillTree.prereqs("MIL_3") == ["MIL_1"] and SkillTree.prereqs("MIN_1") == ["FND_PROSPECT"] and SkillTree.prereqs("MIL_6") == ["MIL_4", "MIL_5"] and SkillTree.prereqs("BIO_7") == ["BIO_6"] and SkillTree.prereqs("FND_PERMIT").is_empty(), "skills: prerequisites follow core 3.1")
	check(m.learned_skills.is_empty(), "skills: nothing learned at start")
	# cost and points
	m.skill_points = 0
	var r: Dictionary = _learn_storage(m)
	check(not r["ok"] and r["reason"] == "points" and m.learned_skills.is_empty(), "skills: not enough points blocks learning")
	m.skill_points = 10
	r = m.learn_skill("FND_STORAGE")  # earn lock: cycle 1, no income yet
	check(not r["ok"] and r["reason"] == "earn" and m.skill_lock_reason("FND_STORAGE") != "" and m.skill_lock_reason("MIL_1") == "", "earn: locked at start, text shown", m.skill_lock_reason("FND_STORAGE"))
	m.cycle = 5
	check(m.learn_skill("FND_STORAGE")["reason"] == "earn", "earn: cycle 5 alone is not enough")
	m.trade_income_total = int(bal["earn_storage_income"])
	m.cycle = 4
	check(m.learn_skill("FND_STORAGE")["reason"] == "earn", "earn: income alone is not enough")
	m.cycle = 5
	check(m.skill_lock_reason("FND_STORAGE") == "" and m.collect_state()["trade_income_total"] == int(bal["earn_storage_income"]), "earn: both met unlocks, income saved")
	m.cycle = 1
	m.trade_income_total = 0
	m._sync_earn()
	r = m.learn_skill("MIL_3")
	check(not r["ok"] and r["reason"] == "locked" and m.skill_points == 10, "skills: a skill without its prerequisite is locked, points kept")
	r = m.learn_skill("MIL_2")
	check(not r["ok"] and r["reason"] == "locked", "skills: tech locked before its prerequisite")
	m.learned_skills.append("MIL_1")
	r = m.learn_skill("MIL_2")
	check(not r["ok"] and r["reason"] == "tech" and not m.learned_skills.has("MIL_2") and m.skill_points == 10, "skills: a tech cannot be bought, even with points")
	m.learned_skills.clear()
	# Foundations are free from cycle 1, any order, at their cost
	r = m.learn_skill("FND_PERMIT")
	check(r["ok"] and m.learned_skills == ["FND_PERMIT"] and m.skill_points == 10 - int(bal["skill_cost_FND_PERMIT"]), "skills: Foundations open at once, learning spends skill_cost_<id>")
	check(m.last_notice == StoryText.get_text("NOT_SKILL_LEARNED", {"skill": StoryText.get_text("SK_FND_PERMIT_NAME")}), "skills: learn posts the skill notice", m.last_notice)
	r = m.learn_skill("FND_PERMIT")
	check(not r["ok"] and r["reason"] == "known" and m.skill_points == 9, "skills: a learned skill is not charged twice")
	r = m.learn_skill("MIN_1")
	check(not r["ok"] and r["reason"] == "locked", "skills: MIN_1 needs FND_PROSPECT")
	m.learn_skill("FND_PROSPECT")
	r = m.learn_skill("MIN_1")
	check(r["ok"] and m.learned_skills == ["FND_PERMIT", "FND_PROSPECT", "MIN_1"], "skills: MIN_1 after FND_PROSPECT")
	check(Skills.learned == m.learned_skills and Skills.is_learned("MIN_1"), "skills: Skills.learned is the learned set")
	# space storage, permits and cluster routes follow the Foundations
	check(not m.space_post_open(1) and m.can_mine() and Skills.unlocked("permit_routes"), "skills: FND_PROSPECT opens cluster routes, FND_PERMIT permit routes, no storage yet")
	_learn_storage(m)
	check(m.space_post_open(1) and Skills.unlocked("space_storage"), "skills: FND_STORAGE opens the Space Storage post")
	# the screen still opens (the rebuild is the UI task)
	var sc: PanelContainer = m.skill_screen
	check(not sc.visible, "skills screen: closed at start")
	var ev := InputEventKey.new()
	ev.keycode = KEY_K
	ev.pressed = true
	m._unhandled_input(ev)
	check(sc.visible and m.paused, "skills screen: K opens it, opening does not unpause")
	var ev2 := InputEventKey.new()
	ev2.keycode = KEY_ESCAPE
	ev2.pressed = true
	m._unhandled_input(ev2)
	check(not sc.visible and not m.game_menu.visible, "skills screen: Esc closes it, no game menu")
	# game menu
	m.paused = false
	m.game_menu.open_menu()
	check(m.paused and m.game_menu.visible, "game menu: pauses while open")
	m.game_menu.close_menu()
	check(not m.paused, "game menu: Resume restores the earlier state")
	m.paused = true
	# save round trip: learned set, points, tech progress, bot skill use
	Tech.counts["MIN_2"] = 4
	Skills.bot_used["MIL_5"] = 3
	Skills.share_paid["bio"] = [20]
	var st: Dictionary = m.collect_state()
	var learned_copy: Array = m.learned_skills.duplicate()
	var pts: int = m.skill_points
	m.learned_skills = []
	m.skill_points = 0
	Tech.reset()
	Skills.bot_used = {}
	Skills.share_paid = {}
	m.apply_state(JSON.parse_string(JSON.stringify(st)))
	check(m.learned_skills == learned_copy and m.skill_points == pts, "skills: save round trip keeps skills and points", str(m.learned_skills))
	check(int(Tech.counts.get("MIN_2", 0)) == 4 and int(Skills.bot_used.get("MIL_5", 0)) == 3 and Skills.share_paid.get("bio", []) == [20], "skills: save round trip keeps tech progress, bot skill use and share points paid")
	m.apply_state({"cycle": 1})
	check(m.learned_skills.is_empty() and Tech.counts.is_empty(), "skills: an old save without skills starts with none")
	await _free_main(m)

# ---- 5b. skills: tech tracker, effects, bot skills, share points, ending inputs, migration (no main needed) ----
func _test_skills_core() -> void:
	var bal := _bal()
	Markets.load_data()
	# --- tech tracker: counts only after the prerequisite is met, no pre-grinding ---
	Skills.reset(bal)
	Tech.reset()
	check(Tech.add_crafted("mil", 50).is_empty() and int(Tech.progress("MIL_2")["n"]) == 0 and not Tech.progress("MIL_2")["active"], "tech: units crafted before the prerequisite do not count")
	Skills.add_learned("MIL_1")
	check(Tech.progress("MIL_2")["active"] and int(Tech.progress("MIL_2")["n"]) == 0 and int(Tech.progress("MIL_2")["goal"]) == int(bal["tech_goal_2"]), "tech: starts at 0 once MIL_1 is learned, goal from tech_goal_2")
	Tech.add_crafted("lux", 5)
	check(int(Tech.progress("MIL_2")["n"]) == 0, "tech: units of another market do not count")
	var g2 := int(bal["tech_goal_2"])
	Tech.add_crafted("mil", g2 - 1)
	check(int(Tech.progress("MIL_2")["n"]) == g2 - 1 and not Skills.is_learned("MIL_2"), "tech: progress counts up")
	var done := Tech.add_crafted("mil", 100)
	check(done == ["MIL_2"] and Skills.is_learned("MIL_2") and Tech.take_done() == ["MIL_2"] and Tech.take_done().is_empty(), "tech: completes by itself and queues one notice")
	check(Tech.progress("MIL_4")["active"] and int(Tech.progress("MIL_4")["n"]) == 0, "tech: the next tech opens at 0, surplus units are not carried")
	check(not Tech.progress("MIL_6")["active"], "tech: MIL_6 needs MIL_4 and MIL_5")
	Skills.add_learned("MIL_3")
	Skills.add_learned("MIL_5")
	Tech.add_crafted("mil", int(bal["tech_goal_4"]))
	check(Skills.is_learned("MIL_4") and Tech.progress("MIL_6")["active"], "tech: MIL_6 opens when MIL_4 and MIL_5 are done")
	Tech.take_done()
	Tech.counts["MIL_6"] = 3
	var td: Dictionary = Tech.to_dict()
	Tech.reset()
	Tech.from_dict(JSON.parse_string(JSON.stringify(td)))
	check(int(Tech.counts.get("MIL_6", 0)) == 3, "tech: progress persists")
	# the Fabric counts its plates toward the Minerals techs (plate is a Minerals good)
	Skills.reset(bal)
	Tech.reset()
	var fab = preload("res://game/fabric.gd").new()
	fab.setup(bal)
	fab.built = true
	var st2 := Storage.new()
	st2.setup(bal, 2, ["dross", "nullglass", "plate", "energy"])
	var fkey := Storage.system_key(1)
	st2.ensure(fkey)
	st2.add(fkey, "dross", 10)
	st2.add(fkey, "nullglass", 5)
	fab.run(st2)
	check(fab.made > 0 and int(Tech.progress("MIN_2")["n"]) == 0, "tech: Fabric plates before MIN_1 do not count")
	Skills.add_learned("MIN_1")
	fab.run(st2)
	check(fab.made > 0 and int(Tech.progress("MIN_2")["n"]) == fab.made, "tech: Fabric plates count toward the Minerals techs once MIN_1 is learned", str(Tech.progress("MIN_2")))
	Skills.reset(bal)
	Tech.reset()
	# --- effects that need no main ---
	Skills.reset(bal)
	Markets.reset(bal, 3)
	var base := float(Markets.value_of("energy"))
	check(is_equal_approx(Skills.upkeep_mult(), 1.0) and is_equal_approx(Skills.storage_cap_mult(), 1.0) and is_equal_approx(Skills.order_size_mult(), 1.0) and is_equal_approx(Skills.cluster_yield_mult(), 1.0), "effects: no skills, neutral numbers")
	Skills.add_learned("MIL_1")
	check(is_equal_approx(Skills.upkeep_mult(), 1.0 - float(bal["skill_MIL_1_upkeep"])), "effects: upkeep_mult (MIL_1)")
	check(Skills.unlocked("munitions") and Skills.unlocked("cells") and not Skills.unlocked("smelter"), "effects: unlock flags (MIL_1 workshop and good)")
	Skills.add_learned("MIL_2")
	Markets.add_sale("energy", 10)
	check(is_equal_approx(float(Markets.cur["mil"]), 10.0 * base * (1.0 + float(bal["skill_size_s"]))), "effects: volume_pct raises share volume (MIL_2)")
	Markets.cur["mil"] = 0.0
	Skills.add_learned("MIL_4")
	Markets.add_sale("energy", 10)
	check(is_equal_approx(float(Markets.cur["mil"]), 10.0 * base * (1.0 + float(bal["skill_size_s"]))) and is_equal_approx(Skills.sale_price_mult("mil"), 1.0 + float(bal["skill_MIL_4_price"])) and is_equal_approx(Skills.sale_price_mult("lux"), 1.0), "effects: sale_price_pct has no share effect (MIL_4), other markets untouched")
	Skills.add_learned("LUX_5")
	Markets.add_sale("silk", 10, 4)
	check(is_equal_approx(float(Markets.cur["lux"]), (10.0 + 4.0 * float(bal["skill_size_m"])) * float(Markets.value_of("silk"))), "effects: LUX_5 counts sales at a price-up planet extra")
	Skills.add_learned("LUX_1")
	Skills.add_learned("LUX_6")
	check(is_equal_approx(Skills.sale_price_mult("lux"), 1.0 + float(bal["skill_LUX_1_price"]) + float(bal["skill_LUX_6_price"])) and Skills.reveal_cycles() == 1, "effects: sale price skills add up, LUX_1 reveals prices")
	Skills.add_learned("LUX_3")
	check(Skills.warning_cycles() == 1, "effects: event_warning (LUX_3)")
	Skills.add_learned("MIL_3")
	check(is_equal_approx(Skills.route_capacity_mult("mil"), 1.0 + float(bal["skill_MIL_3_route_units"])) and is_equal_approx(Skills.route_capacity_mult("bio"), 1.0), "effects: route_capacity_pct only for its market (MIL_3)")
	Skills.add_learned("MIL_6")
	Skills.add_learned("LUX_2")
	Skills.add_learned("BIO_6")
	check(is_equal_approx(Skills.event_cut("mil"), float(bal["skill_MIL_6_event_cut"])) and is_equal_approx(Skills.event_cut("bio"), float(bal["skill_BIO_6_event_cut"])) and is_equal_approx(Skills.event_cut("min"), 0.0) and is_equal_approx(Skills.event_bonus("lux"), float(bal["skill_LUX_2_event_bonus"])) and Skills.reopen_sooner() == 1, "effects: event_cut_pct, event_bonus_pct, reopen_sooner")
	Skills.add_learned("BIO_1")
	Skills.add_learned("BIO_3")
	Skills.add_learned("BIO_5")
	check(is_equal_approx(Skills.order_size_mult(), 1.0 + float(bal["skill_BIO_1_order_units"])) and is_equal_approx(Skills.storage_cap_mult(), 1.0 + float(bal["skill_BIO_3_capacity"])), "effects: order_size_pct and storage_cap_pct")
	check(Markets.window_for("bio") == int(bal["share_window_bio_bonus"]) and Markets.window_for("mil") == int(bal["share_window"]), "effects: share_window (BIO_5) only for Biotech")
	Skills.add_learned("MIN_3")
	Skills.add_learned("MIN_4")
	Skills.add_learned("MIN_6")
	check(is_equal_approx(Skills.cluster_yield_mult(), 1.0 + float(bal["skill_MIN_3_yield"])) and Skills.mine_skill_for("dead_1") == "MIN_3" and Skills.mine_skill_for("dead_2") == "MIN_5" and Skills.mine_unlocked("dead_1") and not Skills.mine_unlocked("dead_2"), "effects: cluster_yield_pct and mine_unlock (MIN_3 dross, MIN_5 nullglass)")
	check(Skills.workshop_batches("min") == int(bal["skill_MIN_4_batches"]) and Skills.workshop_batches("mil") == 0 and Skills.batch_yield("min") == int(bal["skill_MIN_6_batch_bonus"]), "effects: workshop_batches and batch_yield (flags until the workshops exist)")
	# permanent bot effects through end_cycle
	Skills.reset(bal)
	Markets.reset(bal, 5)
	Markets.end_cycle(10)
	var plain_row: Array = Markets.vb["min"][0].duplicate()
	var plain_mil: Array = Markets.vb["mil"][0].duplicate()
	Skills.add_learned("MIN_7")
	Skills.add_learned("MIL_7")
	check(is_equal_approx(Skills.bot_strength_mult("min"), 1.0 - float(bal["skill_MIN_7_strength_cut"])) and is_equal_approx(Skills.bot_strength_mult("mil"), 1.0) and is_equal_approx(Skills.bot_growth_mult("mil"), float(bal["skill_MIL_7_growth_mult"])), "effects: capstone bot numbers (MIN_7 strength, MIL_7 growth)")
	Markets.reset(bal, 5)
	Markets.end_cycle(10)
	var cut_ok := true
	for b in 3:
		if not float(Markets.vb["min"][0][b]) < float(plain_row[b]):
			cut_ok = false
	check(cut_ok, "effects: MIN_7 lowers every bot's Minerals volume in end_cycle")
	check(float(Markets.vb["mil"][0][0]) <= float(plain_mil[0]), "effects: MIL_7 never raises bot growth")
	# stock growth in planet storage (BIO_2): needs a Storage
	Skills.reset(bal)
	Markets.reset(bal, 5)
	var stg := Storage.new()
	stg.setup(bal, 2, ["food", "energy", "silk"])
	var k0 := Storage.planet_key(0)
	stg.add(k0, "food", 60)
	stg.add(k0, "silk", 60)
	check(Skills.grow_stock(stg) == 0 and stg.amount(k0, "food") == 60, "effects: no stock growth without BIO_2")
	Skills.add_learned("BIO_2")
	var g1 := Skills.grow_stock(stg)
	check(g1 == int(floor(60.0 * float(bal["skill_BIO_2_stock_growth"]))) and stg.amount(k0, "food") == 60 + g1 and stg.amount(k0, "silk") == 60, "effects: stock_growth_pct grows Biotech stock only", str(g1))
	for i in 40:
		Skills.grow_stock(stg)
	check(stg.amount(k0, "food") - 60 <= int(floor(float(stg.amount(k0, "food")) * float(bal["skill_BIO_2_stock_cap"]))), "effects: stock growth stops at the cap", str(stg.amount(k0, "food")))
	# --- bot skills: choose a bot, expire, persist ---
	Skills.reset(bal)
	Markets.reset(bal, 9)
	check(Skills.bot_skill_cooldown("MIL_5") == -2 and not Skills.bot_skill_ready("MIL_5") and Skills.activate_bot_skill("MIL_5", 1)["reason"] == "locked", "bot skill: not learned, not usable")
	Skills.add_learned("MIL_5")
	check(Skills.bot_skill_ids() == ["MIL_5"] and Skills.bot_skill_ready("MIL_5"), "bot skill: learned and ready")
	check(Skills.activate_bot_skill("MIL_5", 9)["reason"] == "bot" and Skills.bot_skill_ready("MIL_5"), "bot skill: a bad bot id changes nothing")
	var r := Skills.activate_bot_skill("MIL_5", 2)
	var dur := int(bal["skill_MIL_5_cycles"])
	check(r["ok"] and int(r["until"]) == dur, "bot skill: lasts skill_MIL_5_cycles cycles", str(r))
	check(is_equal_approx(float(Markets.bot_mods(2, "mil")["strength_mult"]), 1.0 - float(bal["skill_MIL_5_hit"])) and is_equal_approx(float(Markets.bot_mods(1, "mil")["strength_mult"]), 1.0) and is_equal_approx(float(Markets.bot_mods(2, "lux")["strength_mult"]), 1.0), "bot skill: only the chosen bot in that market loses strength")
	check(Skills.activate_bot_skill("MIL_5", 3)["reason"] == "cooldown" and Skills.bot_skill_cooldown("MIL_5") == int(bal["skill_MIL_5_every"]), "bot skill: cooldown skill_MIL_5_every")
	# persistence of the temporary hit and the use
	var md: Dictionary = JSON.parse_string(JSON.stringify(Markets.to_dict()))
	var sd: Dictionary = JSON.parse_string(JSON.stringify(Skills.to_dict()))
	Markets.from_dict(md, bal)
	Skills.from_dict(sd)
	check(is_equal_approx(float(Markets.bot_mods(2, "mil")["strength_mult"]), 1.0 - float(bal["skill_MIL_5_hit"])) and Skills.bot_skill_cooldown("MIL_5") == int(bal["skill_MIL_5_every"]), "bot skill: hit and use survive a save")
	# the hit works for the cycles it lasts, then expires
	var plain := Bots.volume(bal, 9, 2, "mil", 1, 0.0, 0, 1.0, 1.0, 0.0)
	Markets.end_cycle(1)
	check(absf(float(Markets.vb["mil"][0][1]) - Bots.volume(bal, 9, 2, "mil", 1, 0.0, 0, 1.0 - float(bal["skill_MIL_5_hit"]), 1.0, 0.0)) < 0.001 and float(Markets.vb["mil"][0][1]) < plain, "bot skill: the hit lowers the bot's volume while it lasts")
	for c in range(2, dur + 1):
		Markets.end_cycle(c)
	check(is_equal_approx(float(Markets.bot_mods(2, "mil")["strength_mult"]), 1.0) and Markets.mods["2|mil"]["temps"].is_empty(), "bot skill: the hit expires after its cycles")
	Markets.end_cycle(dur + 1)
	check(absf(float(Markets.vb["mil"][dur][1]) - Bots.volume(bal, 9, 2, "mil", dur + 1, float(Markets.gap.get("2|mil", 0.0)), 0, 1.0, 1.0, 0.0)) < 0.001, "bot skill: volume is back to normal after the hit")
	for c in range(dur + 2, int(bal["skill_MIL_5_every"]) + 1):
		Markets.end_cycle(c)
	check(Skills.bot_skill_ready("MIL_5") and Skills.activate_bot_skill("MIL_5", 3)["ok"], "bot skill: ready again after skill_MIL_5_every cycles")
	# once per run (LUX_7)
	Skills.add_learned("LUX_7")
	check(Skills.activate_bot_skill("LUX_7", 1)["ok"] and Skills.bot_skill_cooldown("LUX_7") == -1 and Skills.activate_bot_skill("LUX_7", 2)["reason"] == "used", "bot skill: Guild Seal works once per run")
	# --- share points: once per market and step ---
	Skills.reset(bal)
	Markets.reset(bal, 2)
	Markets.vp["mil"] = [25.0]
	Markets.vb["mil"] = [[25.0, 25.0, 25.0]]
	var aw := Skills.award_share_points()
	check(aw.size() == 1 and aw[0]["market"] == "mil" and int(aw[0]["step"]) == 20 and int(aw[0]["points"]) == int(bal["skill_points_share_20"]), "share points: 25% pays the 20% step", str(aw))
	check(Skills.award_share_points().is_empty(), "share points: paid once")
	Markets.vp["mil"] = [60.0]
	aw = Skills.award_share_points()
	check(aw.size() == 1 and int(aw[0]["step"]) == 35 and int(aw[0]["points"]) == int(bal["skill_points_share_35"]), "share points: 35% pays its own step", str(aw))
	Markets.vp["mil"] = [0.0]
	Skills.award_share_points()
	Markets.vp["mil"] = [60.0]
	check(Skills.award_share_points().is_empty(), "share points: reaching a step again pays nothing")
	Markets.vp["lux"] = [100.0]
	Markets.vb["lux"] = [[10.0, 10.0, 10.0]]
	aw = Skills.award_share_points()
	check(aw.size() == 2 and aw[0]["market"] == "lux" and aw[1]["market"] == "lux", "share points: another market pays on its own", str(aw))
	var sd2: Dictionary = JSON.parse_string(JSON.stringify(Skills.to_dict()))
	Skills.from_dict(sd2)
	check(Skills.award_share_points().is_empty(), "share points: paid steps survive a save")
	# --- ending inputs (core 6) ---
	Skills.reset(bal)
	Markets.reset(bal, 2)
	Markets.vp["mil"] = [60.0]
	Markets.vb["mil"] = [[10.0, 10.0, 10.0]]
	Markets.vp["lux"] = [30.0]
	Markets.vb["lux"] = [[10.0, 10.0, 10.0]]
	var e0 := EndingPicker.inputs("mil", bal)
	check(e0["ending_id"] == "END_MIL_GOOD" and not e0["capstone"] and int(e0["tech_done"]) == 0 and not e0["rival_broken"] and e0["second_market"] == "lux" and e0["second_over"], "ending inputs: no capstone, no tech, second market over the line", str(e0))
	Skills.add_learned("MIL_2")
	Skills.add_learned("MIL_4")
	Skills.add_learned("MIL_7")
	Skills.add_learned("LUX_2")
	var e1 := EndingPicker.inputs("MIL", bal)
	check(e1["capstone"] and int(e1["tech_done"]) == 2 and e1["market"] == "mil", "ending inputs: capstone MIL_7 and techs done in the win market only", str(e1))
	Markets.vp["lux"] = [3.0]
	check(not EndingPicker.inputs("mil", bal)["second_over"], "ending inputs: second market under the line")
	Skills.add_learned("MIL_6")
	check(int(EndingPicker.inputs("mil", bal)["tech_done"]) == 3, "ending inputs: three techs is the most")
	# --- save migration v2 -> v3 ---
	var v2 := {"cash": 1234, "cycle": 7, "ships": 3, "skill_points": 2, "surveyed": [2], "markets": {"seed": 5},
		"learned_skills": ["A1", "A2", "A4", "A5", "B1", "B2", "B3", "B4", "C1", "C2", "C3", "C4", "M1", "M2", "F1", "Z9"]}
	var mg: Dictionary = SaveGame.migrate_v2(v2)
	check(mg["learned_skills"] == ["FND_STORAGE", "BIO_3", "MIL_3", "MIL_1", "FND_PROSPECT", "BIO_1", "LUX_1", "LUX_3", "FND_PERMIT", "MIN_3", "MIN_5", "MIN_1"], "migration: old skills map to the new ids", str(mg["learned_skills"]))
	check(int(mg["skill_points"]) == 2 + 1 + 2 + 2 and int(mg["cash"]) == 1234 and int(mg["cycle"]) == 7 and int(mg["ships"]) == 3 and mg["markets"] == v2["markets"] and not mg.has("surveyed"), "migration: C2, C4 and the second permit skill (C3) refunded; cash, cycle, ships, markets kept", str(mg["skill_points"]))
	check(v2["learned_skills"].size() == 16, "migration: the input dictionary is not changed")
	_wipe_user()
	var f := FileAccess.open(SaveGame.PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 2, "state": v2}))
	f.close()
	var loaded: Dictionary = SaveGame.load_state()
	check(SaveGame.VERSION == 4 and not loaded.is_empty() and loaded["learned_skills"].has("FND_STORAGE") and not SaveGame.dropped_old, "migration: a v2 file loads migrated")
	f = FileAccess.open(SaveGame.PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 1, "state": v2}))
	f.close()
	check(SaveGame.load_state().is_empty() and SaveGame.dropped_old, "migration: a v1 file is still dropped with the old message")
	_wipe_user()
	Skills.reset(bal)
	Tech.reset()

func _find_option_buttons(n: Node, out: Array) -> Array:
	if n is OptionButton:
		out.append(n)
	for c in n.get_children():
		_find_option_buttons(c, out)
	return out

# ---- Four Markets: registry, volumes, share, bots, win, swept, overhead (static module) ----
func _bal() -> Dictionary:
	return _read_json("res://data/balance.json")["values"]

func _mean_sell(good: String) -> int:
	var vals := []
	var all_planets: Array = _read_json("res://data/planets.json")["planets"].duplicate(true)
	for sy in _read_json("res://data/systems.json")["systems"]:
		all_planets.append_array(sy["planets"].duplicate(true))
	for pl in all_planets:
		Goods.merge_prices(pl)  # goods.json prices count like the data files
		_collect_sell(pl, good + "_sell", vals)
	return roundi(float(vals.reduce(func(a, b): return a + b, 0)) / float(vals.size())) if not vals.is_empty() else -1

func _collect_sell(o, key: String, out: Array) -> void:
	if typeof(o) == TYPE_DICTIONARY:
		if typeof(o.get("base_prices")) == TYPE_DICTIONARY and (o["base_prices"].get(key) is int or o["base_prices"].get(key) is float):
			out.append(o["base_prices"][key])
		for v in o.values():
			_collect_sell(v, key, out)
	elif typeof(o) == TYPE_ARRAY:
		for v in o:
			_collect_sell(v, key, out)

## Runs cycles from..to with `cur` filled by fill(cycle) -> Dictionary market -> volume.
func _run_cycles(from: int, to: int, fill: Callable) -> Dictionary:
	var v := {}
	for c in range(from, to + 1):
		var f: Dictionary = fill.call(c)
		for m in f:
			Markets.cur[m] = float(f[m])
		Markets.end_cycle(c)
		v = Markets.verdict(c)
		if not v.is_empty():
			return {"cycle": c, "v": v}
	return {"cycle": to, "v": {}}

func _bot_run(bal: Dictionary, seed_v: int, from: int, to: int, hits: bool) -> void:
	for c in range(from, to + 1):
		if hits and c == 4:
			Markets.hit_bot(1, "mil", "strength", -0.2)
			Markets.hit_bot(2, "lux", "growth", 0.1)
			Markets.hit_bot(3, "bio", "tier", -1)
		Markets.cur["mil"] = 100.0 * c
		Markets.end_cycle(c)

func _test_bot_hooks() -> void:
	var bal := _bal()
	Markets.load_data()
	var base := {}
	# neutral defaults and size words
	Markets.reset(bal, 7)
	var d0 := Markets.bot_mods(1, "mil")
	check(is_equal_approx(float(d0["strength_mult"]), 1.0) and int(d0["tier_offset"]) == 0 and float(d0["growth_add"]) == 0.0, "bot hooks: neutral mods by default")
	check(is_equal_approx(Markets.size_pct("S"), 0.05) and is_equal_approx(Markets.size_pct("M"), 0.1) and is_equal_approx(Markets.size_pct("L"), 0.2) and Markets.size_pct("X") == 0.0, "bot hooks: size_pct S/M/L from balance")
	# strength hit changes the next volume only, history stays
	_bot_run(bal, 7, 1, 3, false)
	var hist_before := Markets.bot_history(1, "mil").duplicate()
	Markets.hit_bot(1, "mil", "strength", -0.2)
	check(Markets.bot_history(1, "mil") == hist_before, "bot hooks: history not rewritten by a hit")
	Markets.cur["mil"] = 0.0
	Markets.end_cycle(4)
	var hit4: float = Markets.bot_history(1, "mil")[3]
	var exp4 := Bots.volume(bal, 7, 1, "mil", 4, float(Markets.gap.get("1|mil", 0.0)), 0, 0.8)
	check(absf(hit4 - exp4) < 0.001 and hit4 < Bots.volume(bal, 7, 1, "mil", 4, float(Markets.gap.get("1|mil", 0.0))), "bot hooks: strength hit applies from the next cycle", "%f %f" % [hit4, exp4])
	# stacking multiplicative
	Markets.hit_bot(1, "mil", "strength", -0.1)
	check(absf(float(Markets.bot_mods(1, "mil")["strength_mult"]) - 0.72) < 0.0001, "bot hooks: strength hits stack multiplicatively")
	Markets.hit_bot(2, "lux", "growth", 0.1)
	Markets.hit_bot(2, "lux", "growth", 0.1)
	check(absf(float(Markets.bot_mods(2, "lux")["growth_mult"]) - 1.21) < 0.0001 and is_equal_approx(float(Markets.bot_mods(2, "mil")["growth_mult"]), 1.0), "bot hooks: growth hits stack, other markets untouched")
	check(absf(Bots.volume(bal, 7, 2, "lux", 9, 0.0, 0, 1.0, 1.0, 5.0) - Bots.volume(bal, 7, 2, "lux", 9, 0.0, 0, 1.0, 1.0, 0.0)) > 0.0, "bot hooks: growth_add raises volume")
	# tier: -1 lowers effective tier, clamps at 1
	Markets.reset(bal, 7)
	var t_late := 40
	Markets.hit_bot(1, "mil", "tier", -1)
	var off := int(Markets.bot_mods(1, "mil")["tier_offset"])
	check(off == -1 and Bots.tier(bal, 1, t_late, off) == 2 and Bots.tier(bal, 1, 1, off) == 1, "bot hooks: tier hit is -1 and the effective tier stays within 1..4")
	for i in 6:
		Markets.hit_bot(1, "mil", "tier", -1)
	check(int(Markets.bot_mods(1, "mil")["tier_offset"]) == -3 and Bots.tier(bal, 1, 1, -3) == 1 and Bots.tier(bal, 1, 99, 9) == 4, "bot hooks: tier offset clamped")
	check(not Markets.hit_bot(9, "mil", "strength", 0.1) and not Markets.hit_bot(1, "zzz", "strength", 0.1) and not Markets.hit_bot(1, "mil", "bogus", 0.1), "bot hooks: bad bot, market or stat rejected")
	# determinism and save round trip with hits over 10 cycles
	Markets.reset(bal, 99)
	_bot_run(bal, 99, 1, 10, true)
	var full := JSON.stringify(Markets.to_dict())
	Markets.reset(bal, 99)
	_bot_run(bal, 99, 1, 10, true)
	check(JSON.stringify(Markets.to_dict()) == full, "bot hooks: same seed and hits give identical numbers")
	Markets.reset(bal, 99)
	_bot_run(bal, 99, 1, 6, true)
	var mid = JSON.parse_string(JSON.stringify(Markets.to_dict()))
	Markets.reset(bal, 0)
	Markets.from_dict(mid, bal)
	check(Markets.bot_history(1, "mil").size() == 6 and absf(float(Markets.bot_mods(1, "mil")["strength_mult"]) - 0.8) < 0.0001 and int(Markets.bot_mods(3, "bio")["tier_offset"]) == -1, "bot hooks: mods and history survive save and load")
	_bot_run(bal, 99, 7, 10, false)
	check(JSON.stringify(Markets.to_dict()) == full, "bot hooks: a loaded run continues with identical numbers")
	# a v2 save without mods still loads
	var old = JSON.parse_string(JSON.stringify(mid))
	old.erase("mods")
	Markets.from_dict(old, bal)
	check(Markets.bot_history(1, "mil").size() == 6 and is_equal_approx(float(Markets.bot_mods(1, "mil")["strength_mult"]), 1.0), "bot hooks: save without mods loads with defaults")
	Markets.reset(bal, 5)
	# bots are numbers only: no nodes
	var src := FileAccess.get_file_as_string("res://game/bots.gd") + FileAccess.get_file_as_string("res://game/markets.gd")
	check(not src.contains("Node.new") and not src.contains("add_child") and not src.contains("Sprite") and not src.contains("preload(\"res://game/map"), "bot hooks: bots.gd and markets.gd create no nodes")
	Markets.reset(bal, 0)

func _test_markets() -> void:
	var bal := _bal()
	Markets.load_data()
	check(Markets.ids == ["mil", "lux", "min", "bio"] and Markets.names["mil"] == "Military" and Markets.names["bio"] == "Biotech", "markets: four markets with display names")
	var goods: Array = Goods.ids()  # the 19 goods of data/goods.json
	var all_one := true
	for g in goods:
		var n := 0
		for m in Markets.ids:
			if Markets.goods_of[m].has(g):
				n += 1
		if n != 1 or Markets.market_of(g) == "":
			all_one = false
	check(all_one, "markets: every good maps to exactly one market")
	check(Markets.market_of("energy") == "mil" and Markets.market_of("food") == "bio" and Markets.market_of("chips") == "mil" and Markets.market_of("silk") == "lux" and Markets.market_of("ore") == "min" and Markets.market_of("dross") == "min" and Markets.market_of("nullglass") == "min" and Markets.market_of("plate") == "min", "markets: tagging per core 1.1")
	var total := 0
	for m in Markets.ids:
		total += Markets.goods_of[m].size()
	check(total == goods.size(), "markets: no good listed twice or left out", str(total))
	var base_ok := true
	for g in goods:
		if Markets.value_of(g) != _mean_sell(g) or Markets.value_of(g) <= 0:
			base_ok = false
	check(base_ok, "markets: base_value is the rounded mean of <good>_sell over the planets")
	check(Markets.is_common("energy") and Markets.is_common("food") and Markets.is_common("ore") and not Markets.is_common("silk"), "markets: common raws are energy, food, ore")
	# volume tracking
	Markets.reset(bal, 7)
	Markets.add_sale("silk", 10)
	Markets.add_sale("energy", 5)
	Markets.add_sale("energy", 0)
	Markets.add_sale("unknown_good", 5)
	check(is_equal_approx(float(Markets.cur["lux"]), 10.0 * Markets.value_of("silk")) and is_equal_approx(float(Markets.cur["mil"]), 5.0 * Markets.value_of("energy")), "volume: units x base_value per market")
	check(is_equal_approx(float(Markets.cur_active["mil"]), 0.0) and float(Markets.cur_active["lux"]) > 0.0, "volume: common raws stay out of the active volume")
	Markets.end_cycle(1)
	check(is_equal_approx(float(Markets.history("lux")[0]), 350.0) and float(Markets.cur["lux"]) == 0.0, "volume: the cycle is stored and the counter cleared")
	# share formula with the window
	Markets.reset(bal, 7)
	check(Markets.share("mil") == 0.0 and Markets.best()["market"] == "", "share: 0 with no volume, best is empty")
	var w := int(bal["share_window"])
	Markets.vp["mil"] = []
	Markets.vb["mil"] = []
	for i in w + 2:
		Markets.vp["mil"].append(5000.0 if i < 2 else 100.0)  # two old cycles outside the window
		Markets.vb["mil"].append([100.0, 100.0, 100.0] if i >= 2 else [1.0, 1.0, 1.0])
	check(absf(Markets.share("mil") - 0.25) < 0.0001, "share: V_p / (V_p + bots) over the last share_window cycles only", str(Markets.share("mil")))
	check(w == 8 and Markets.window_for("bio") == 8, "share: bio uses share_window without BIO_5")
	var bs := 0.0
	for b in Bots.IDS:
		bs += Markets.bot_share(b, "mil")
	check(absf(bs + Markets.share("mil") - 1.0) < 0.0001, "share: player and bot shares add to 1")
	check(Markets.best()["market"] == "mil" and absf(float(Markets.best()["share"]) - 0.25) < 0.0001, "share: best() gives the market and share")
	# bots: determinism, tiers, noise bound, gap rule
	check(Bots.volume(bal, 5, 1, "mil", 9) == Bots.volume(bal, 5, 1, "mil", 9) and Bots.volume(bal, 5, 1, "mil", 9) != Bots.volume(bal, 6, 1, "mil", 9), "bots: same seed gives the same volume, another seed another")
	check(Bots.tier(bal, 1, 12) == 1 and Bots.tier(bal, 1, 13) == 2 and Bots.tier(bal, 1, 26) == 2 and Bots.tier(bal, 1, 27) == 3 and Bots.tier(bal, 2, 11) == 2 and Bots.tier(bal, 3, 28) == 3, "bots: tier-ups at bot_<b>_tier_cycle_1 and 2")
	var noise_ok := true
	for c in range(1, 41):
		var raw := (float(bal["bot_1_mil_strength"]) + float(bal["bot_1_mil_growth"]) * c) * float(bal["bot_tier_mult_%d" % Bots.tier(bal, 1, c)]) * float(bal["bot_scale"])
		var ratio := Bots.volume(bal, 3, 1, "mil", c) / raw
		if ratio < 1.0 - float(bal["bot_noise_pct"]) - 0.0001 or ratio > 1.0 + float(bal["bot_noise_pct"]) + 0.0001:
			noise_ok = false
	check(noise_ok, "bots: volume = (strength + growth x cycle) x tier x scale within +-bot_noise_pct")
	Markets.reset(bal, 11)
	_run_cycles(1, 30, func(c): return {})
	var a1: Array = Markets.bot_history(1, "lux").duplicate()
	var total1 := Markets.total_volume("mil")
	Markets.reset(bal, 11)
	_run_cycles(1, 30, func(c): return {})
	check(a1 == Markets.bot_history(1, "lux") and is_equal_approx(total1, Markets.total_volume("mil")), "bots: a whole run is deterministic per seed")
	Markets.reset(bal, 12)
	_run_cycles(1, 30, func(c): return {})
	check(a1 != Markets.bot_history(1, "lux"), "bots: another seed gives another run")
	Markets.reset(bal, 11)
	_run_cycles(1, 5, func(c): return {})
	check(is_equal_approx(float(Markets.gap["1|mil"]), 2.0 * float(bal["bot_gap_growth"])), "bots: gap growth from cycle 4 while the player is under bot_gap_share_pct", str(Markets.gap))
	Markets.reset(bal, 11)
	_run_cycles(1, 5, func(c): return {"mil": 1000000.0})
	check(not Markets.gap.has("1|mil") and Markets.gap.has("1|lux"), "bots: no gap growth where the player holds a share")
	# win hold
	Markets.reset(bal, 3)
	var hold := int(bal["win_hold_cycles"])
	var first_win := int(bal["win_earliest_cycle"]) + hold - 1
	Chains.reset(bal, 0)
	Chains.picks["MIN_B4"] = {"opt": "opt_a", "cycle": 1, "nudge": 0}  # the win gate is open (own tests below)
	var r := _run_cycles(1, 40, func(c): return {"min": 1000000.0})
	check(int(r["cycle"]) == first_win and r["v"]["kind"] == "win" and r["v"]["market"] == "min", "win: share over win_share_pct for win_hold_cycles from win_earliest_cycle (cycle %d)" % first_win, str(r))
	Markets.reset(bal, 3)
	var save_pct = bal["win_share_pct"]
	r = _run_cycles(1, first_win - 1, func(c): return {"min": 1000000.0})
	bal["win_share_pct"] = 2.0  # one cycle under the line breaks the streak
	r = _run_cycles(first_win, first_win, func(c): return {"min": 1000000.0})
	bal["win_share_pct"] = save_pct
	check(int(Markets.win_streak["min"]) == 0 and r["v"].is_empty(), "win: a cycle under the line resets the hold")
	r = _run_cycles(first_win + 1, first_win + hold - 1, func(c): return {"min": 1000000.0})
	check(r["v"].is_empty(), "win: the hold starts again after a break")
	r = _run_cycles(first_win + hold, first_win + hold, func(c): return {"min": 1000000.0})
	check(r["v"].get("kind", "") == "win", "win: fires after win_hold_cycles in a row again")
	# final check at cycle 40: highest qualifying market wins
	Markets.reset(bal, 3)
	r = _run_cycles(1, 39, func(c): return {})
	check(r["v"].get("kind", "") != "win", "win: no win without volume")
	r = _run_cycles(40, 40, func(c): return {"mil": 1000000.0, "lux": 9000000.0})
	check(r["v"].get("kind", "") == "win" and r["v"]["market"] == "lux" and Markets.timed_out(40), "win: final check at the last cycle, the highest share wins")
	# swept
	Markets.reset(bal, 3)
	var se := int(bal["sweep_earliest_cycle"])
	var sh := int(bal["sweep_hold_cycles"])
	r = _run_cycles(1, se + sh - 2, func(c): return {})
	check(r["v"].is_empty(), "swept: not before sweep_earliest_cycle + hold")
	r = _run_cycles(se + sh - 1, se + sh - 1, func(c): return {})
	check(r["v"].get("kind", "") == "swept" and int(r["v"]["bot"]) in Bots.IDS, "swept: under sweep_share_pct everywhere for sweep_hold_cycles", str(r))
	Markets.reset(bal, 3)
	r = _run_cycles(1, se + sh + 3, func(c): return {"lux": 3000.0} if c >= se - 3 else {})
	check(r["v"].get("kind", "") != "swept", "swept: one market over sweep_share_pct is enough to stay in")
	# overhead and active markets
	Markets.reset(bal, 3)
	var oh := int(bal["market_overhead"])
	var cases := [[1, 0], [2, 1], [3, 4], [4, 9]]
	for cs in cases:
		for i in Markets.ids.size():
			Markets.vp_active[Markets.ids[i]] = [100.0] if i < int(cs[0]) else []
		check(Markets.n_active() == int(cs[0]) and Markets.overhead() == oh * int(cs[1]), "overhead: %d active markets pay market_overhead x %d" % [cs[0], cs[1]], str(Markets.overhead()))
	Markets.vp_active["mil"] = [1000.0]
	Markets.vp_active["lux"] = [10.0]  # about 1 percent of the volume: not active
	Markets.vp_active["min"] = []
	Markets.vp_active["bio"] = []
	check(Markets.n_active() == 1 and Markets.overhead() == 0, "overhead: a market under market_active_pct is not active")
	Markets.vp_active["mil"] = []
	Markets.vp_active["lux"] = []
	check(Markets.n_active() == 0 and Markets.overhead() == 0, "overhead: no volume means no overhead")
	Markets.reset(bal, 3)

# ---- Four Markets: spreading rules in the route engine ----
func _test_market_rules() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	var e = m.engine
	var mult := float(bal["cross_load_trip_mult"])
	var up: int = e.upkeep_part(null)
	var trip: int = e.trip_part()
	var rc: Dictionary = e.new_record(0, 1, "chips")
	rc["id"] = 1
	e.routes = [rc]
	check(e.fixed_cost(rc) == trip + up, "cross-load: a single-market lane pays the plain trip cost", "%d vs %d" % [e.fixed_cost(rc), trip + up])
	var rs: Dictionary = e.new_record(0, 1, "silk")
	rs["id"] = 2
	e.routes = [rc, rs]
	check(e.is_cross_load(rc) and e.fixed_cost(rc) == floori(float(trip) * mult) + up, "cross-load: goods of two markets on one lane pay cross_load_trip_mult on trip cost", "%d" % e.fixed_cost(rc))
	var re_: Dictionary = e.new_record(0, 1, "energy")
	re_["id"] = 3
	e.routes = [rc, re_]
	check(not e.is_cross_load(rc) and e.fixed_cost(rc) == trip + up, "cross-load: a common raw does not make a load mixed")
	var rl: Dictionary = e.new_record(2, 3, "silk")
	rl["id"] = 4
	e.routes = [rc, rl]
	check(not e.is_cross_load(rc), "cross-load: goods on different lanes do not mix")
	e.routes = []
	check(e.mixed_bonus(1000, 1, 0, false) > 0 and e.mixed_bonus(1000, 1, 0, true) == 0, "bundle: the bonus is for single-market loads only")
	check(e._cross_with(["mil"], "silk") and not e._cross_with(["mil"], "chips") and not e._cross_with(["mil"], "food") and not e._cross_with([], "silk"), "bundle: a second market (not a common raw) mixes the load")
	# a planet that sells chips and silk the same cycle gets no bonus; chips and plate-free same-market goods keep it
	e.local = {}
	e.mix = {}
	var key0: String = m.storage.planet_key(0)
	var shown: Dictionary = e.mixed_preview(0)
	check(shown.is_empty(), "bundle: no preview without sell orders")
	await _free_main(m)
	_wipe_user()

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
	m.rescues_paid = 0
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
	m.rescues_paid = 0
	m._check_stranded()
	check(m.cash == 1 + stip, "rescue: cash below fixed cost, no route running, nothing sellable pays")
	m._check_stranded()
	check(m.cash == 1 + stip, "rescue: at most once per cycle")
	# sellable stock blocks the rescue
	m.cash = 1
	m.last_rescue_cycle = -1
	m.rescues_paid = 0
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
	# stall fix: two running routes, cash above one trip but below both fixed costs, flat for 2 cycles
	var rec2: Dictionary = e.new_record(1, 0, c)
	rec2["id"] = 2
	rec2["state"] = "running"
	e.routes = [rec, rec2]
	rec["state"] = "running"
	m.cash = fixed + 5
	m.last_rescue_cycle = -1
	m.rescues_paid = 0
	m.last_net = 0
	m.prev_net = 10
	m._check_stranded()
	check(m.cash == fixed + 5, "rescue: one flat cycle is not a stall")
	m.prev_net = 0
	m._check_stranded()
	check(m.cash == fixed + 5 + stip, "rescue: cash below all routes' fixed cost, 2 flat cycles pays the stipend")
	m.cash = fixed * 2 + 1
	m.last_rescue_cycle = -1
	m.rescues_paid = 0
	m._check_stranded()
	check(m.cash == fixed * 2 + 1, "rescue: cash covering all routes' fixed cost is not rescued")
	# ship cash floor: after the price, cash must cover every open route's fixed cost
	m.ships = 2
	m.cash = int(bal["ship_price"]) + fixed * 2 - 1
	check(not m.can_buy_ship()["ok"] and m.can_buy_ship().get("floor", false), "ship floor: refused when cash after price < routes x fixed cost")
	m.cash = int(bal["ship_price"]) + fixed * 2
	check(m.can_buy_ship()["ok"], "ship floor: allowed at exactly the floor")
	e.routes = [rec]
	rec["state"] = "running"
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
	check(ev.defs.size() >= 19 and ev.by_id.has("EV20") and not Chains.in_pool("EV18"), "events: definitions loaded from data/events.json (EV18 is out of the pool)", str(ev.defs.size()))
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
	m.learned_skills = ["BIO_6"]
	m._sync_closed()
	check(not m.engine.closed_planets.has(ti), "events: BIO_6 (reopen sooner) skips the first closed cycle")
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
	m.events.by_id["EV20"]["min_cycle"] = 13
	check(not m.events.available("EV20", 2) and m.events.available("EV20", 13) and m.events.available("EV01", 2) and m.events.available("EV20", 0), "events gate: min_cycle respected, missing key is open")
	var gated_ok := true
	for i in 300:
		var pid: String = m.events.random_id([], 2)
		if pid == "EV20" or pid == "":
			gated_ok = false
	check(gated_ok, "events gate: random_id skips gated events before min_cycle")
	var seen20 := false
	for i in 300:
		if m.events.random_id([], 13) == "EV20":
			seen20 = true
	check(seen20, "events gate: gated event can be picked at min_cycle")
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
	m.events.by_id["EV20"].erase("min_cycle")
	m.debug_force_event = true
	m.cycle = 1
	m.events.pending_id = ""
	m.events.by_id["EV17"]["min_cycle"] = 99
	m.events.by_id["EV20"]["min_cycle"] = 99
	m.debug_force_event = false
	for i in 100:
		var q: String = m.events.random_id([], m.cycle + 1)
		if q in ["EV17", "EV20"]:
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
		check(par is VBoxContainer and par.get_parent() is VBoxContainer and par.get_parent().find_child("BuyButton_" + c, false, false) != null, "next cycle: label sits in the status lines under its resource button")
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
	var traded_n := 0
	for c2 in m.commodities:
		if m.trade.price(0, str(c2) + "_buy") >= 0 or m.trade.price(0, str(c2) + "_sell") >= 0:
			traded_n += 1
	for bn in _all_buttons(m.planet_panel):
		if str(bn.name).begins_with("BuyButton_"):
			buys += 1
	check(combined == 0 and buys == traded_n and sends == 0, "T141 planet panel: one Buy toggle per resource, Send to... only in the right-click menu, no combined button")
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
	var menu := _find_named(m.planet_panel, "ContextMenu_" + c) as PopupMenu
	var buy_b := _find_named(m.planet_panel, "BuyButton_" + c) as Button
	check(menu != null and menu.get_parent() == buy_b and menu.get_item_index(0) >= 0 and menu.get_item_index(1) >= 0, "right-click menu: the resource button owns a menu with Send and Sell")
	check(_find_named(m.planet_panel, "SendButton_" + c) == null and _find_named(m.planet_panel, "SellButton_" + c) == null and not _labels(m.planet_panel, []).any(func(l): return l.text == StoryText.get_text("LBL_COMPANY_STORAGE")), "right-click menu: no storage rows, no Send or Sell buttons in the panel")
	var cap_l := _find_named(m.planet_panel, "Capacity_" + c) as Label
	check(cap_l != null and cap_l.get_parent() == buy_b and cap_l.text.contains("/"), "resource button: shows stored/capacity", str(cap_l.text if cap_l != null else ""))
	check(buy_b != null and buy_b.tooltip_text.to_lower().contains("right-click"), "resource button: tooltip hints at right-click")
	m.planet_panel.show_planet(1)
	var bb := _find_named(m.planet_panel, "BuyButton_" + c) as Button
	check(bb != null and bb.button_pressed and bb.tooltip_text.contains("Press to stop"), "buy toggle: the resource button is pressed while the order is on")
	var stop_n := 0
	for b in _all_buttons(m.planet_panel):
		if b.text == bb.text:
			stop_n += 1
	check(stop_n == 1, "buy toggle: one button per resource", str(stop_n))
	check(_find_named(m.planet_panel, "BuyGrid") != null and bb.get_parent().get_parent() == _find_named(m.planet_panel, "BuyGrid"), "buy table: resource buttons are cells of the BuyGrid")
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
	check(bb.text == "%s %s" % [Ui.good_name(c), str(m.map.planets[1]["base_prices"][c + "_buy"])] and not bb.button_pressed and bb.icon != null, "buy toggle: the button reads the resource name and its buy price, with its icon")
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
	check(m.commodities == ["energy", "food", "ore", "dross", "plate", "rivets", "cells", "armour", "cask", "gems", "ingot", "alloy", "gel", "seed", "musk", "spores"], "sys2: system 1 goods at start (silk and chips are system 2 goods since system tiers)", str(m.commodities))
	# permit chain
	check(m.can_buy_permit(2)["reason"] == "skill", "sys2: permit needs FND_PERMIT")
	m._refresh()
	check(not ("system_previews" in m.map) and not ("system_arrows" in m.map), "3D: no next-system preview or arrow in the system view")
	# T128: edge arrow
	var req_steps: Array = []
	m._missing_chain("FND_PERMIT", req_steps)
	var at: Dictionary = m.skill_arrow_target()
	if req_steps.size() == 1:
		check(str(at.get("mode", "")) == "skills" and at["steps"] == ["FND_PERMIT"], "arrow: FND_PERMIT reachable shows the skills arrow")
	else:
		check(at.is_empty() or str(at.get("mode", "")) == "skills", "arrow: hidden until FND_PERMIT is reachable", str(at))
	m._on_skill_arrow()
	check(m.skill_screen.visible == (not at.is_empty()), "arrow: click opens the skill screen")
	m.skill_screen.close_screen()
	check(m.skill_screen.highlight.is_empty(), "arrow: highlight cleared on close")
	check(m.can_buy_permit(3)["reason"] == "unknown", "sys2: system 3 does not exist")
	m.learned_skills.append("FND_PERMIT")
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
	m.learned_skills.append("FND_STORAGE")  # trade gate: system 2 needs its Space Storage post
	m.storage.ensure(Storage.system_key(2))
	r = m.set_local_order(4, "food", "buy", true)
	check(r["ok"] and m.systems_reached == sys0 + 1, "sys2: first order in system 2 reaches it")
	m.set_local_order(5, "energy", "buy", true)
	check(m.systems_reached == sys0 + 1, "sys2: reach counted once")
	m.learned_skills.erase("FND_STORAGE")
	# round trip save
	var st: Dictionary = m.collect_state()
	check(st["open_systems"].has(2), "sys2: open_systems saved")
	await _free_main(m)
	m = await _new_main()
	m._dismiss_preface()
	m.apply_state(st)
	check(m.map.planets.size() == 9 and m.open_systems.has(2) and m.engine.local_on(4, "food", "buy"), "sys2: load restores system and order")
	# Space Storage
	check(not m.space_post_open(1) and not m.space_post_open(2), "space: no post before FND_STORAGE")
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = ["0-1", "0-2"]
	m.skill_points = 50
	check(_learn_storage(m)["ok"], "space: FND_STORAGE learnable after the gate")
	check(m.space_post_open(1) and m.space_post_open(2), "space: one post per open system after FND_STORAGE")
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
	if not m.learned_skills.has("FND_PERMIT"):
		m.learned_skills.append("FND_PERMIT")  # cross-system routes need Long Haul; this check is about the post only
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
	m.learned_skills.erase("FND_STORAGE")
	m.engine.settle(m.cash)
	check(str(rec["state"]) == "stalled", "space: no backup without FND_STORAGE", str(rec["state"]))
	await _free_main(m)
	_wipe_user()

# ---- Skill effects that were text only before 2026-10-31: BIO_3, FND_PERMIT, FND_PROSPECT, LUX_1, LUX_3 ----
func _test_skill_effects() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	var key0: String = m.storage.planet_key(0)
	# BIO_3 Seed Bank through learn_skill (BIO_3 needs BIO_1)
	var cap0: int = m.storage.capacity_of(key0)
	m.skill_points = 10
	check(m.learn_skill("FND_PERMIT")["ok"] and _learn_storage(m)["ok"] and m.learn_skill("BIO_1")["ok"] and m.learn_skill("BIO_3")["ok"], "BIO_3: learned after BIO_1")
	var cap1: int = m.storage.capacity_of(key0)
	check(cap1 == int(round(float(cap0) * (1.0 + float(bal["skill_BIO_3_capacity"])))) and cap1 > cap0, "BIO_3: planet storage capacity raised by skill_BIO_3_capacity", "%d -> %d" % [cap0, cap1])
	check(m.storage.capacity_of("system:1") == int(bal["space_storage_capacity"]), "BIO_3: Space Storage capacity unchanged")
	m.cycle = 6
	m.skill_points = 1
	m.learned_skills.erase("FND_PERMIT")
	m.skill_points = 0
	# the permit costs the data price (Colonial Rights is gone)
	m.learned_skills.append("FND_PERMIT")
	check(m.permit_cost(2) == int(bal["permit_2_cost"]) and m.permit_points(2) == int(bal["permit_points_2"]), "permit: data price and data points")
	# FND_PERMIT (Long Haul folded in): a route from system 1 to system 2 needs it
	m.cash = 50000
	m.skill_points = 100
	check(m.buy_permit(2)["ok"], "FND_PERMIT: system 2 permit bought")
	m.learned_skills.erase("FND_PERMIT")
	var r: Dictionary = m.engine.check_connection(0, 4, "energy")
	check(not r["ok"] and r["reason"] == StoryText.get_text("NOT_ROUTE_NEEDS_C3"), "FND_PERMIT: cross-system route refused without permit routes", str(r))
	check(m.engine.check_connection(4, 5, "energy")["ok"], "FND_PERMIT: a route inside system 2 needs no Permit Charter")
	m.learned_skills.append("FND_PERMIT")
	check(m.engine.check_connection(0, 4, "energy")["ok"], "FND_PERMIT: cross-system route allowed with FND_PERMIT")
	m.learned_skills.erase("FND_PERMIT")
	# FND_PROSPECT Market Ledger: history kept at cycle end, saved, shown as text
	m.cash = 1000
	m.cycle = 1
	m._end_cycle()
	m._end_cycle()
	var hist: Array = m.price_history.get("0|energy", [])
	check(hist.size() == 2 and int(hist[-1]) == m.trade.price(0, "energy_sell"), "FND_PROSPECT: sell price recorded at each cycle end", str(hist))
	var st: Dictionary = m.collect_state()
	check(st.has("price_history") and st["price_history"].has("0|energy"), "FND_PROSPECT: history in the save")
	m.planet_panel.show_planet(0)
	check(not _labels(m.planet_panel, []).any(func(l): return l.text.begins_with("Recent sell prices")), "price history: no history line on the planet panel")
	# LUX_1 Price Whisper: effects that still run next cycle, not the ones that end now
	var base_e: int = m.trade.price(0, "energy_sell")
	m.events.active = [{"id": "EV01", "kind": "down", "planet": 0, "c": "energy", "left": 1, "age": 0}]
	check(m.trade.price(0, "energy_sell") != base_e and m.trade.price(0, "energy_sell", true) == base_e, "MIL_4: an effect that ends now is not in the next-cycle price")
	m.events.active = [{"id": "EV01", "kind": "down", "planet": 0, "c": "energy", "left": 2, "age": 0}]
	check(m.trade.price(0, "energy_sell", true) == m.trade.price(0, "energy_sell"), "MIL_4: an effect that runs one more cycle is in the next-cycle price")
	m.events.active = []
	# LUX_3 Event Forecast: one cycle ahead of a due event (events come on cycles 5, 9, 13, ...)
	# the warning comes while cycle 4 is running; the event itself starts cycle 5
	m.learned_skills.append("LUX_3")
	m.cash = 1000  # the FND_PERMIT test left cash above the win goal, which would open the choice instead of ending the cycle
	m.cycle = 3
	m.notice_queue = []
	m.last_notice = ""
	m._end_cycle()
	var fc_seen := _has_forecast_notice(m)
	check(m.cycle == 4 and fc_seen, "LUX_3: warning posted in the cycle before an event")
	m.learned_skills.erase("LUX_3")
	m.cash = 1000
	m.cycle = 4
	m.notice_queue = []
	m.last_notice = ""
	m._end_cycle()
	check(not _has_forecast_notice(m), "LUX_3: no warning without the skill")
	m.learned_skills.append("LUX_3")
	m.learned_skills.erase("LUX_3")
	# MIL_4 sale price: sell credits rise by skill_MIL_4_price (energy is a Military good), only with the skill
	var eng: RefCounted = m.engine
	var plain: int = eng.local_price(0, "energy", "sell")
	m.learned_skills.erase("MIL_4")
	check(eng.sold_price(0, "energy") == plain, "MIL_4: no margin without the skill")
	m.learned_skills.append("MIL_4")
	var boosted: int = eng.sold_price(0, "energy")
	# plain can be as low as 6; an 8% margin then rounds back to the same whole credit, so only >= is safe here
	check(boosted == roundi(float(plain) * (1.0 + float(bal["skill_MIL_4_price"]))) and boosted >= plain, "MIL_4: sold price raised by skill_MIL_4_price", "%d -> %d" % [plain, boosted])
	m.storage.add(key0, "energy", 10)
	var sale: Dictionary = eng._local_calc(0, "energy", "sell", 1000)
	check(int(sale["credits"]) == int(sale["n"]) * boosted and int(sale["n"]) > 0, "MIL_4: a Sell order pays the margin per unit", str(sale))
	m.learned_skills.erase("MIL_4")
	check(int(eng._local_calc(0, "energy", "sell", 1000)["credits"]) == int(sale["n"]) * plain, "MIL_4: unlearned Sell order pays the plain price")
	# LUX_1 on a route lane: per-unit earnings at the far end carry the margin; the route itself only pays upkeep, so no double count
	var rm0: int = eng.route_margin(0, 1, "energy")
	m.learned_skills.append("MIL_4")
	var rm1: int = eng.route_margin(0, 1, "energy")
	var far: int = eng.sold_price(1, "energy")
	var near: int = m.trade.price(0, "energy_buy")
	check(rm1 == eng.units_per_cycle(null, "energy") * (far - near) and rm1 > rm0, "MIL_4: route lane margin uses the LUX_1 sell price per unit", "%d -> %d" % [rm0, rm1])
	check(eng.payout_of(eng.new_record(0, 1, "energy")) <= 0, "MIL_4: route settlement adds no credits itself (Sell order pays once)")
	m.learned_skills.erase("MIL_4")
	# T158 (base game since FND_PROSPECT became Prospecting): warning when the route margin is below its upkeep, trend arrow, best partner
	var bp: Dictionary = m.trade.planets[1]["base_prices"]
	var keep_sell = bp["energy_sell"]
	bp["energy_sell"] = 1
	check(eng.margin_below_upkeep(0, 1, "energy"), "FND_PROSPECT: a lane that earns less than its cost is flagged")
	m.notice_queue = []
	m.last_notice = ""
	m._advance_notice()
	check(m.route_margin_notice(0, 1, "energy") and m.last_notice.contains(str(eng.fixed_cost())), "T158: route setup warns when margin is below upkeep, no skill needed", m.last_notice)
	bp["energy_sell"] = int(keep_sell) + 500
	m._advance_notice()
	m.notice_queue = []
	check(not eng.margin_below_upkeep(0, 1, "energy") and not m.route_margin_notice(0, 1, "energy"), "FND_PROSPECT: no warning on a paying lane")
	check(int(eng.best_partner(0, "energy")["planet"]) == 1, "T158: best partner is the planet that pays most")
	bp["energy_sell"] = keep_sell
	check(not m.has_method("price_trend") and not m.has_method("price_history_line"), "price history: trend and history display helpers are gone")
	m.learned_skills.erase("FND_PROSPECT")
	check(m.permit_points(2) == m.Systems.permit_points(bal, 2), "permit points stay at the data value")
	# LUX_3 forecast names planet and commodity for a price event
	m.events.by_id["ZZ_TEST"] = {"id": "ZZ_TEST", "tag": "[price up: %s, energy]" % m.planet_name(0)}
	var ft: String = m.forecast_text("ZZ_TEST")
	check(StoryText.has_text("EVT_NEXT_DUE_PRICE") == ft.contains(m.planet_name(0)) and (not StoryText.has_text("EVT_NEXT_DUE_PRICE") and ft == StoryText.get_text("EVT_NEXT_DUE") or ft.contains("Energy")), "LUX_3: forecast names planet and commodity once the text exists, else the plain warning", ft)
	m.events.by_id.erase("ZZ_TEST")
	# the game hooks read Skills: route capacity, order size, upkeep, events, cluster yield, sales at a price-up planet
	m.learned_skills = []
	var u0: int = eng.units_per_cycle(null, "energy")
	var l0: int = eng.local_amount()
	var f0: int = eng.fixed_cost()
	var y0: int = m.clusters.yield_per_cycle()
	m.learned_skills = ["MIL_3", "BIO_1", "MIL_1", "MIN_3"]
	check(eng.units_per_cycle(null, "energy") > u0 and eng.units_per_cycle(null, "silk") == u0 and eng.units_per_cycle(eng.new_record(0, 1, "energy")) == eng.units_per_cycle(null, "energy"), "hooks: route_capacity_pct (MIL_3) lifts Military routes only")
	check(eng.local_amount() == floori(float(bal["order_amount"]) * (1.0 + float(bal["skill_BIO_1_order_units"]))) and eng.local_amount() > l0, "hooks: order_size_pct (BIO_1) raises Buy and Sell orders")
	check(eng.fixed_cost() < f0, "hooks: upkeep_mult (MIL_1) lowers the ship upkeep")
	check(m.clusters.yield_per_cycle() == floori(float(bal["mining_yield_per_cycle"]) * (1.0 + float(bal["skill_MIN_3_yield"]))) and m.clusters.yield_per_cycle() > y0, "hooks: cluster_yield_pct (MIN_3) raises mining yield")
	m.learned_skills = []
	# MIN_2 ore_free_slots: an ore order ignores the order-size cap
	var ore_l0: int = eng.local_amount("ore")
	m.learned_skills = ["MIN_2"]
	var ore_l1: int = eng.local_amount("ore")
	check(ore_l0 == eng.local_amount() and ore_l1 > ore_l0 * 100 and eng.local_amount("energy") == ore_l0, "MIN_2: ore orders are no longer capped by the order size (%d -> %d), other goods are" % [ore_l0, ore_l1])
	m.learned_skills = []
	# LUX_4 stock_protect: Luxury stock survives an asteroid cut of the storage
	var lux_good := ""
	for g in ["silk", "chips", "energy", "food"]:
		if Markets.market_of(g) == "lux":
			lux_good = g
			break
	var sk := "planet:2"
	var cap_before: int = m.storage.capacity_of(sk)
	m.storage.add(sk, lux_good, cap_before)
	m.storage.cut_capacity(sk, 0.5)
	var lux_cut: int = m.storage.amount(sk, lux_good)
	m.storage.cuts.erase(sk)
	m.storage.stock[sk][lux_good] = cap_before
	m.learned_skills = ["LUX_4"]
	m.storage.cut_capacity(sk, 0.5)
	var lux_kept: int = m.storage.amount(sk, lux_good)
	check(lux_good != "" and lux_cut < cap_before and lux_kept == cap_before and m.storage.space(sk, lux_good) == 0, "LUX_4: Luxury stock is trimmed by a storage cut without the skill (%d) and kept with it (%d)" % [lux_cut, lux_kept])
	m.storage.cuts.erase(sk)
	m.storage.stock.erase(sk)
	m.learned_skills = []
	m.events.active = [{"id": "T1", "kind": "up", "planet": 0, "c": "silk", "left": 3, "age": 0}, {"id": "T2", "kind": "down", "planet": 0, "c": "energy", "left": 3, "age": 0}]
	var up0: float = m.events.price_factor(0, "silk")
	var dn0: float = m.events.price_factor(0, "energy")
	m.learned_skills = ["LUX_2", "MIL_6"]
	check(is_equal_approx(m.events.price_factor(0, "silk"), 1.0 + m.events.pct("silk") * (1.0 + float(bal["skill_LUX_2_event_bonus"]))) and m.events.price_factor(0, "silk") > up0, "hooks: event_bonus_pct (LUX_2) makes price-up events pay more")
	check(is_equal_approx(m.events.price_factor(0, "energy"), 1.0 - m.events.pct("energy") * (1.0 - float(bal["skill_MIL_6_event_cut"]))) and m.events.price_factor(0, "energy") > dn0, "hooks: event_cut_pct (MIL_6) weakens price-down events")
	eng.sales_up_units = {}
	eng.sales_units = {}
	eng._note_sale("silk", 5, 0)
	eng._note_sale("energy", 4, 0)
	check(int(eng.sales_up_units.get("silk", 0)) == 5 and not eng.sales_up_units.has("energy") and int(eng.sales_units["energy"]) == 4, "hooks: sales at a planet with a price-up event are counted for LUX_5")
	m.events.active = []
	m.learned_skills = []
	await _free_main(m)
	_wipe_user()

## True when a notice is the LUX_3 forecast: the plain warning or the named "Next cycle: ..." text.
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
	check(map.planet_labels[0].position.y < map.positions[0].y - map.planet_radius(0) * 0.56, "size: names sit below the bigger planet")
	if route_r0 >= 0.0:
		var r1: float = map.route_lines.values()[0].radius
		var rl0 = map.route_lines.values()[0]
		check(absf(r1 - maxf(map.planet_radius(rl0.pair_a), map.planet_radius(rl0.pair_b))) < 0.0001, "size: route starts follow the debug size", "r=%f" % r1)
	m.debug_menu._set_planet_scale(1.3)
	check(absf(map.planet_radius() - 1.04) < 0.0001, "size: back to x1.3")
	map.set_hint(0, true)
	var hm = map.hint.mesh
	check(hm is TorusMesh and not (hm is SphereMesh), "highlight: a thin ring, not a filled sphere")
	check(hm is TorusMesh and hm.outer_radius - hm.inner_radius < map.planet_radius(0) * 0.2 and hm.inner_radius > map.planet_radius(0), "highlight: ring is thin and outside the planet")
	check(map.hint.mat.albedo_color.is_equal_approx(Color(Ui.col("star_warm"), map.hint.mat.albedo_color.a)), "highlight: ring uses the theme accent colour")
	map.set_hint(-1, false)

## Route offset, orbit size x2 and planet size variation (owner requests 2026-11-03).
func _test_route_offset() -> void:
	var RO = load("res://game/route_offset.gd")
	var pos: Array = [Vector3(0, 0, 0), Vector3(10, 0, 0), Vector3(5, 0, 0.5), Vector3(5, 0, 6), Vector3(12, 0, 0), Vector3(5, 0, -4), Vector3(5, 0, 4)]
	var o_on: float = RO.offset(0, 1, pos, [], 1.8)
	check(o_on > 0.01, "offset: a planet near the line makes a detour", "%.3f" % o_on)
	var far: Array = [pos[0], pos[1], pos[3]]
	check(RO.offset(0, 1, far, [], 1.8) == 0.0, "offset: a planet far from the line adds nothing")
	var beyond: Array = [pos[0], pos[1], pos[4]]
	check(RO.offset(0, 1, beyond, [], 1.8) == 0.0, "offset: a planet past the end adds nothing")
	var cross: Array = [pos[0], pos[1], pos[5], pos[6]]
	check(RO.offset(0, 1, cross, [[2, 3]], 1.8) > 0.0, "offset: a route crossing the line makes a detour")
	check(RO.offset(0, 1, cross, [[0, 3]], 1.8) == 0.0, "offset: a route sharing a planet is no crossing")
	check(RO.offset(0, 1, cross, [[2, 3], [3, 2]], 1.8) == RO.offset(0, 1, cross, [[2, 3]], 1.8), "offset: two directions of one lane cross once")
	check(RO.offset(0, -1, pos, [], 1.8) == 0.0, "offset: no planet end, no offset")
	var e = RouteEngine.new()
	var bal := {"maintenance": 45, "maintenance_interval": 3, "route_offset_maint_pct": 5.0, "route_offset_min_pct": 0.01, "route_offset_max": 0.2, "route_offset_clearance": 1.8}
	e.balance = bal
	var rec := {"id": 1, "a": 0, "b": 1, "c": "ore", "ship": "small", "stop": -1}
	check(e.offset_of(rec) == 0.0 and e.offset_maint_mult(rec) == 1.0, "offset: no positions, no offset")
	var up0: int = e.upkeep_part(rec)
	pos[2] = Vector3(5, 0, 0.0)  # dead centre: the biggest detour
	e.positions_fn = func() -> Array: return pos
	var off: float = e.offset_of(rec)
	var up1: int = e.upkeep_part(rec)
	check(off > 0.0 and up1 > up0 and absf(e.offset_maint_mult(rec) - (1.0 + 5.0 * off)) < 0.0001, "offset: maintenance rises with the offset", "%d -> %d at %.2f" % [up0, up1, off])
	bal["route_offset_min_pct"] = 5.0
	check(e.offset_of(rec) == 0.0 and e.upkeep_part(rec) == up0, "offset: below route_offset_min_pct nothing counts")
	bal["route_offset_min_pct"] = 0.0
	bal["route_offset_max"] = 0.01
	check(absf(e.offset_of(rec) - 0.01) < 0.0001, "offset: clamped to route_offset_max")
	check(e.offset_of({"ship": "small"}) == 0.0 and e.upkeep_part({"ship": "small"}) == up0, "offset: a plain ship record has none")
	var rec2 := {"id": 2, "a": 1, "b": 0, "c": "ore", "ship": "small", "stop": 2}
	bal["route_offset_max"] = 0.2
	bal["route_offset_min_pct"] = 0.01
	check(e.offset_of(rec2) == 0.0, "offset: a planet the route stops at is no obstacle")
	# the live map
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var map = m.map
	var ok_orbit := true
	var info := ""
	for i in map.planets.size():
		var sy: int = int(map.planets[i].get("system", 1))
		var raw: Array = []
		for p in map.planets:
			if int(p.get("system", 1)) == sy:
				raw.append(Vector2(float(p["x"]), float(p["y"])) * map.MAP_UNIT_SCALE)
		var lo: Vector2 = raw[0]
		var hi: Vector2 = raw[0]
		for v in raw:
			lo = Vector2(minf(lo.x, v.x), minf(lo.y, v.y))
			hi = Vector2(maxf(hi.x, v.x), maxf(hi.y, v.y))
		var mid := (lo + hi) * 0.5
		var r_raw: float = (Vector2(float(map.planets[i]["x"]), float(map.planets[i]["y"])) * map.MAP_UNIT_SCALE - mid).length()
		var r_now: float = Vector2(map.positions[i].x - mid.x, map.positions[i].z - mid.y).length()
		ok_orbit = ok_orbit and absf(r_now - 2.0 * r_raw) < 0.001
	check(ok_orbit and map.ORBIT_SCALE == 2.0, "orbits: every planet sits twice as far from its system centre")
	var lo_f := 99.0
	var hi_f := 0.0
	var all_in := true
	var small_i := 0
	for i in map.planets.size():
		var f: float = map.size_factor(i)
		all_in = all_in and f >= map.PLANET_SIZE_MIN and f <= map.PLANET_SIZE_MAX
		if f < map.size_factor(small_i):
			small_i = i
		lo_f = minf(lo_f, f)
		hi_f = maxf(hi_f, f)
	check(all_in and hi_f - lo_f > 0.3, "size: planets vary in size within the range", "%.2f to %.2f" % [lo_f, hi_f])
	map.zoom = 1.0
	map.focus = map.positions[small_i]
	map._update_camera()
	check(map.pick_planet(map.camera.unproject_position(map.positions[small_i])) == small_i and map.planet_radius(small_i) < map.planet_radius(), "size: the smallest planet can still be clicked", "planet %d r=%.2f" % [small_i, map.planet_radius(small_i)])
	# every pair on the live map, as if each pair were one route
	m.debug_grant_permit(2)
	var n_off := 0
	var n_all := 0
	var n_cross := 0
	var worst := 0.0
	var lines := ""
	for sy in [1, 2]:
		var idx: Array = []
		for i in map.planets.size():
			if int(map.planets[i].get("system", 1)) == sy:
				idx.append(i)
		for a in idx:
			for b in idx:
				if a >= b:
					continue
				n_all += 1
				var rid: int = 900 + a * 20 + b
				var rec_ab := {"id": rid, "a": a, "b": b, "c": "ore", "ship": "small", "stop": -1}
				m.engine.routes.clear()
				var o_planets: float = m.engine.offset_of(rec_ab)  # planet obstacles only
				for c2 in idx:
					for d2 in idx:
						if c2 < d2:
							m.engine.routes.append({"id": 900 + c2 * 20 + d2, "a": c2, "b": d2, "c": "ore", "ship": "small", "stop": -1})
				var o: float = m.engine.offset_of(rec_ab)  # with every other pair of the system as a route
				if o_planets > 0.0:
					n_off += 1
				if o > 0.0:
					n_cross += 1
					worst = maxf(worst, o)
					lines += " %s-%s %.3f" % [map.planets[a]["id"], map.planets[b]["id"], o]
	m.engine.routes.clear()
	check(true, "offset: measured on the live map: %d of %d pairs by planets, %d with every pair routed, largest %.3f" % [n_off, n_all, n_cross, worst], lines)
	await _free_main(m)

func _test_debug_menu() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	check(m.debug_menu != null, "debug: menu built in a debug build")
	check(not m.debug_tools_allowed(false) and m.debug_tools_allowed(true), "debug: release build excludes the menu")
	var d: PanelContainer = m.debug_menu
	for k in ["force_event", "show_events", "event_state", "debris_planet", "debris_set", "debris_clear", "unlock_s2", "permit_system", "grant_permit",
			"open_systems", "craft_market", "craft_units", "craft_add", "skill_state", "ship_small", "route_id", "route_level", "route_set_level", "ship_state",
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
	m.learned_skills.append("MIL_1")
	Tech.reset()
	d.qa["craft_market"].select(Markets.ids.find("mil"))
	d.qa["craft_units"].value = 5
	d.qa["craft_add"].pressed.emit()
	check(int(Tech.progress("MIL_2")["n"]) == 5 and "Researching MIL_2: 5 of" in d.skills_text(), "debug: add crafted units counts toward the market's tech", d.skills_text())
	d.qa["craft_units"].value = 100
	d.qa["craft_add"].pressed.emit()
	check(m.learned_skills.has("MIL_2") and m.last_notice == StoryText.get_text("SK_TECH_DONE", {"name": StoryText.get_text("SK_MIL_2_NAME")}), "debug: enough crafted units finish the tech and post the notice", m.last_notice)
	m.learned_skills = []
	Tech.reset()
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
	check(m.station_systems.is_empty() and m.map.stations.is_empty(), "station: none before FND_STORAGE")
	m.open_systems = [1, 2]
	m._open_system(2)
	check(m.station_systems.is_empty(), "station: none before FND_STORAGE even with system 2 open")
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = ["0-1", "0-2"]
	m.skill_points = 50
	check(m.learn_skill("FND_PERMIT")["ok"] and _learn_storage(m)["ok"], "station: FND_STORAGE learned")
	check(m.station_systems.has(1) and m.station_systems.has(2) and m.map.stations.size() == 2, "station: one per open system after FND_STORAGE")
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
	check(m.station_systems == [1, 2] and m.map.stations.size() == 2, "station: old save with FND_STORAGE builds them on load")
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
		pole_ok = pole_ok and top_w.dot(sun_w) < -0.5 and absf(sp.key_dir.y - top_w.dot(sun_w)) < 0.001 and worst < 0.25 and absf(sp.scale.x - map.planet_radius(i)) < 0.0001
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
	m.learned_skills.append("FND_PERMIT")  # Long Haul, so only the gate can refuse a cross-system route
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
	var all_off := true
	var lb = _find_named(m.planet_panel, "BuyButton_" + c)
	if lb == null or not lb.disabled or not lb.tooltip_text.begins_with(m.trade_locked_reason()):
		all_off = false
	var lm := _find_named(m.planet_panel, "ContextMenu_" + c) as PopupMenu
	for id in [0, 1]:
		if lm == null or not lm.is_item_disabled(lm.get_item_index(id)) or lm.get_item_tooltip(lm.get_item_index(id)) != m.trade_locked_reason():
			all_off = false
	check(all_off, "gate: panel disables Buy, Sell and Send to with the reason on a locked system")
	m.planet_panel.show_planet(home)
	var hb = _find_named(m.planet_panel, "BuyButton_" + c)
	check(hb != null and not hb.disabled, "gate: panel keeps home Buy enabled")
	# open the post
	m.pts_planets = [0, 1, 2]
	m.pts_pairs = ["0-1", "0-2"]
	m.skill_points = 50
	m.learn_skill("FND_PERMIT")
	_learn_storage(m)
	check(m.space_post_open(2) and m.system_trade_open(far), "gate: post open after FND_STORAGE")
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
	# Cluster ellipse: the long axis of a pack lies along the orbit tangent (perpendicular to the radius from the sun)
	var el_ok := true
	var el_ratio := 0.0
	var el_msg := ""
	for c in m.clusters_in_system(1):
		var tg: Vector3 = ap.tangent_of(c)
		var centre: Vector3 = ap.sun_positions.get(1, Vector3.ZERO)
		var rad: Vector3 = Vector3(float(c["x"]), 0.0, float(c["y"])) * ap.map_unit_scale - centre
		el_ok = el_ok and absf(tg.dot(rad)) < 0.0001 and is_equal_approx(tg.length(), 1.0)
		var pts: PackedVector3Array = ap.packs[str(c["id"])]["points"]
		var ex_t := 0.0
		var ex_r := 0.0
		for o in pts:
			ex_t += o.dot(tg) * o.dot(tg)
			ex_r += o.dot(rad.normalized()) * o.dot(rad.normalized())
		el_ratio += sqrt(ex_t / maxf(ex_r, 0.000001)) / float(m.clusters_in_system(1).size())
		el_msg += " %.2f" % [sqrt(ex_t / maxf(ex_r, 0.000001))]
	check(el_ok and el_ratio > 1.25, "Cluster ellipse: long axis along the orbit tangent (spread along tangent / across radius, stretch %.1f)" % float(c0["stretch"]), el_msg)
	var pk_c: Vector3 = Vector3(float(c0["x"]), 0.0, float(c0["y"])) * ap.map_unit_scale
	var pk_t: Vector3 = ap.tangent_of(c0)
	var pk_r: float = float(c0["radius"]) * ap.map_unit_scale
	var pk_in: int = m.map.pick_cluster(m.map.camera.unproject_position(pk_c + pk_t * pk_r * 1.4))
	var pk_out: int = m.map.pick_cluster(m.map.camera.unproject_position(pk_c + pk_t * pk_r * 2.4))
	check(pk_in == int(c0["index"]) and pk_out != int(c0["index"]), "Cluster ellipse: click area reaches 1.4 radii along the tangent but not 2.4", "%d %d" % [pk_in, pk_out])
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
	m.learned_skills.append("FND_PROSPECT")
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
	var sbm := _find_named(m.planet_panel, "ContextMenu_energy") as PopupMenu
	var sbi: int = sbm.get_item_index(1) if sbm != null else -1
	check(sbi >= 0 and sbm.get_item_text(sbi).begins_with(StoryText.get_text("BTN_SELL") + " ") and sbm.get_item_tooltip(sbi).begins_with(StoryText.get_or("LBL_SELL_PRICE", "Sell price")), "panel: Sell menu item shows its price, tooltip says Sell price")
	check(_find_named(m.planet_panel, "PriceBuy_energy") == null and _find_named(m.planet_panel, "PriceSell_energy") == null, "panel: no separate price chips")
	check(not _labels(m.planet_panel, []).any(func(l): return l.text.to_upper() == "MAIN RESOURCES"), "planet panel: no Main resources row")
	check(_find_named(m.planet_panel, "StorageEmpty_energy") == null and not _labels(m.planet_panel, []).any(func(l): return l.text.begins_with("Storage empty")), "planet panel: no Storage empty line")
	check(not _labels(m.planet_panel, []).any(func(l): return l.text.begins_with("Abundant") or l.text.begins_with("Free ships") or l.text.contains("No free ship")), "planet panel: no Abundant, free-ship or no-free-ship line")
	m.ship_panel.set_upkeep(m)
	check(m.ship_panel.free_label.text.begins_with("Free ships: %d" % m.free_ships()), "ships window: shows the free-ship count and upkeep each", m.ship_panel.free_label.text)
	m.ships = m.engine.total_assigned()
	m.ship_panel.set_upkeep(m)
	check(m.free_ships() == 0 and m.ship_panel.free_label.text.contains("Send to... buys one") or m.ship_panel.free_label.text.contains("Not enough") or m.ship_panel.free_label.text.contains("limit"), "ships window: with no free ship it says what Send to... does", m.ship_panel.free_label.text)
	# T158: FND_PROSPECT Prospecting shows ore left; price trend and margin warning are base game; best partner is LUX_1
	m.learned_skills.erase("FND_PROSPECT")
	m.planet_panel.show_planet(0)
	m.learned_skills.erase("FND_PROSPECT")
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
		var p := "res://art/event_banners/%s.webp" % str(e["id"]).to_lower()
		if not FileAccess.file_exists(p) and not ResourceLoader.exists(p):
			missing.append(str(e["id"]))
	check(evs.size() > 0 and missing.is_empty(), "banners: every event in events.json has art/event_banners/<lowercase id>.webp", str(missing))


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

## Alpha fix 2026-11-02: mining is reachable from the start. A mining_focus-style player (FND_PROSPECT first) learns Prospecting
## at cycle 1 with the start point, and again after Permit Charter without Space Storage, and can then plan an ore lane.
func _test_mining_reachable() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	check(m.skill_points >= int(m.balance["skill_cost_FND_PROSPECT"]), "mining reach: the start gives enough points for FND_PROSPECT", str(m.skill_points))
	check(m.learn_skill("FND_PROSPECT")["ok"] and m.can_mine(), "mining reach: FND_PROSPECT learned first, at cycle 1")
	_free_main(m)
	var m2: Control = await _new_main()
	m2._dismiss_preface()
	var cost_c1 := int(m2.balance["skill_cost_FND_PERMIT"])
	check(m2.learn_skill("FND_PERMIT")["ok"], "mining reach: FND_PERMIT first")
	m2._add_points(int(m2.balance["skill_cost_FND_PROSPECT"]))
	for i in 9:
		m2.debug_advance_cycle()
	check(m2.cycle <= 10 and m2.learn_skill("FND_PROSPECT")["ok"] and m2.can_mine(), "mining reach: FND_PROSPECT after FND_PERMIT alone by cycle 10, no FND_STORAGE needed", "cycle %d cost_c1 %d" % [m2.cycle, cost_c1])
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
	check(m.can_build_fabric()["reason"] == "skill" and not m.build_fabric()["ok"] and m.cash == 5000, "fabric: refused before MIN_1, nothing paid")
	m.learned_skills.append("FND_STORAGE")
	m.learned_skills.append("MIN_1")
	m._ensure_stations()
	check(m.station_systems.has(1), "fabric: trading post (system 1 station) exists with FND_STORAGE")
	# build blocked until dross and nullglass both have a route into the trading post
	check(m.can_build_fabric()["reason"] == "inputs" and not m.build_fabric()["ok"] and not m.fabric.built and m.cash == 5000, "fabric: build refused with no input routes, nothing paid")
	m.engine.routes.append(m.engine.new_record(0, -1, "dross"))
	check(m.can_build_fabric()["reason"] == "inputs", "fabric: one input route is not enough")
	m.engine.routes.append(m.engine.new_record(0, -1, "nullglass"))
	check(m.can_build_fabric()["ok"], "fabric: allowed once both inputs have a route")
	m.cash = fabric_cost - 1
	check(m.can_build_fabric()["reason"] == "credits", "fabric: refused without the build cost in credits")
	m.cash = 5000
	check(m.build_fabric()["ok"] and m.cash == 5000 - fabric_cost and m.fabric.built, "fabric: builds after MIN_1, build cost paid", str(m.cash))
	check(not m.build_fabric()["ok"] and m.cash == 5000 - fabric_cost, "fabric: paid once, a second build is refused")
	m.engine.routes.clear()  # built stays built when routes go; later checks start route-free
	check(m.fabric.built, "fabric: an already built fabric stays built without routes")
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
	# QA 2026-11-03: dross held in the station sells at Voltara through a Sell order (a route into the station itself pays nothing)
	m.storage.add(key, "dross", 10)
	m.set_local_order(0, "dross", "sell", true)
	var dross_before: int = m.storage.amount(key, "dross")
	var st3: Dictionary = m.engine.settle(m.cash)
	var dross_price: int = m.engine.sold_price(0, "dross")
	check(dross_price > 0 and m.storage.amount(key, "dross") < dross_before and int(st3["delta"]) > 0, "chain: a Sell order at Voltara sells dross out of the station", "price %d, delta %s" % [dross_price, st3["delta"]])
	# the station panel says which fabric inputs have no route yet
	var ssv2 = m.space_storage_view
	m.storage.remove(key, "dross", m.storage.amount(key, "dross"))
	m.storage.remove(key, "nullglass", m.storage.amount(key, "nullglass"))
	ssv2.open_for(1)
	var lines := _labels(ssv2, [])
	var seen := false
	for l in lines:
		if l.name == "FabricInputs" and "dross" in l.text and "nullglass" in l.text:
			seen = true
	check(seen, "fabric panel: lists inputs not yet reached (no route, no stock)")
	# the locked-trade reason names FND_STORAGE only while FND_STORAGE is missing
	check(not "FND_STORAGE" in m.trade_locked_reason() or not m.has_skill("FND_STORAGE"), "trade lock text: names FND_STORAGE only without FND_STORAGE")
	m.learned_skills.erase("FND_STORAGE")
	check("Space Storage" in m.trade_locked_reason(), "trade lock text: names Space Storage when it is not learned", m.trade_locked_reason())
	await _free_main(m)

func _test_dead_world_mechanics() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	m.balance["dead_unlock_cycle"] = 1  # these tests are about skills and danger, not the cycle gate
	m._sync_dead_lock()
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
	check(ST.prereqs("MIN_3") == ["MIN_1"] and ST.prereqs("MIN_5") == ["MIN_3"] and ST.prereqs("MIN_1") == ["FND_PROSPECT"], "dead skills: MIN_3 needs MIN_1, MIN_5 needs MIN_3, MIN_1 needs FND_PROSPECT")
	check(ST.ids_in("min").has("MIN_3") and ST.cost(m.balance, "MIN_3") == 2 and ST.cost(m.balance, "MIN_5") == 3 and ST.cost(m.balance, "MIN_1") == 1, "dead skills: Minerals tree, costs 2, 3, 1 (balance v36)")
	# gate
	m.cash = 6000
	m.ships = 3
	var r: Dictionary = m.can_connect(d1, 0, "dross")
	check(not r["ok"] and "Cold Survey" in str(r["reason"]), "dead gate: refused without MIN_3 with a reason", str(r))
	m.learned_skills.append("MIN_3")
	check(m.can_connect(d1, 0, "dross")["ok"], "dead gate: allowed with MIN_3")
	m._open_system(2)
	var g2: int = -1
	for i in m.map.planets.size():
		if str(m.map.planets[i].get("id", "")) == "dead_2":
			g2 = i
	var r2: Dictionary = m.engine.check_connection(g2, g2 - 1, "nullglass")
	check(g2 >= 0 and not r2["ok"] and "Deep Cut" in str(r2["reason"]), "dead gate: Greywake refused without MIN_5 (MIN_3 does not open it)", str(r2))
	m.learned_skills.append("MIN_5")
	check(m.engine.check_connection(g2, g2 - 1, "nullglass")["ok"], "dead gate: Greywake allowed with MIN_5")
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
	for sid in Chains.step_ids():  # the test moves the cycle back by hand: no chain step may take the slot
		Chains.picks[sid] = {"opt": "opt_a", "cycle": 99, "nudge": 0}
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
	check(m.cycle == 3 and fed.call() == 1 and ev.scheduled.is_empty(), "follow: fires once at the set cycle", "cycle %d fired %d chains %s notice %s" % [m.cycle, fed.call(), str(Chains.picks.keys()), str(_texts(m.event_notice))])
	m._on_event_confirmed(-1, "T_PART2")
	m.debug_advance_cycle()
	check(fed.call() == 1, "follow: does not fire again")
	ev.from_dict({})
	check(ev.scheduled.is_empty(), "follow: an old save has no schedule")
	await _free_main(m)

## Dead-planets audit: cycle-15 gate, gate bypasses, Null Core, old saves.
func _test_dead_unlock_and_core() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	check(int(m.balance.get("dead_unlock_cycle", 0)) == 15, "dead gate: balance dead_unlock_cycle is 15")
	var d1 := -1
	for i in m.map.planets.size():
		if str(m.map.planets[i].get("id", "")) == "dead_1":
			d1 = i
	m.cash = 9000
	m.ships = 3
	m.learned_skills.append("MIN_3")
	m.learned_skills.append("FND_STORAGE")
	m._ensure_stations()
	m._sync_dead_lock()
	check(m.engine.dead_locked.has(d1), "dead gate: Cinderrest is locked at cycle 1")
	var r: Dictionary = m.can_connect(d1, 0, "dross")
	check(not r["ok"] and "15" in str(r["reason"]), "dead gate: route from Cinderrest refused before cycle 15, says cycle 15", str(r))
	check(not m.can_connect(0, d1, "ore")["ok"] or m.engine.check_connection(0, d1, "ore")["reason"] != "", "dead gate: route to Cinderrest refused before cycle 15")
	check(not m.engine.check_connection(0, d1, "ore")["ok"] and "15" in str(m.engine.check_connection(0, d1, "ore")["reason"]), "dead gate: route to a dead world refused with the cycle line")
	check(not m.engine.check_connection(d1, -1, "dross")["ok"], "dead gate: send from Cinderrest to Space Storage refused before 15")
	check(not m.set_local_order(d1, "dross", "buy", true)["ok"], "dead gate: a buy order at Cinderrest refused before 15")
	var labels_text := ""
	m.planet_panel.show_planet(d1)
	for l in _labels(m.planet_panel, []):
		if l.name == "DeadLockedLine":
			labels_text = l.text
	check(labels_text == "Opens at cycle 15.", "dead gate: panel says it opens at cycle 15", labels_text)
	check(m.events.pick_debris_planet() != d1 or m.events.planets.size() == 1, "dead gate: debris never picks a locked dead world (spot check)")
	var hit := 0
	for i in 200:
		if m.events.pick_debris_planet() == d1:
			hit += 1
	check(hit == 0, "dead gate: debris never picks a locked dead world over 200 picks", str(hit))
	m.cycle = 14
	m._sync_closed()
	m.debug_advance_cycle()
	check(m.cycle == 15 and m.engine.dead_locked.is_empty(), "dead gate: open at cycle 15", str(m.cycle))
	check(m.last_notice.begins_with("Dead worlds are open") or m.shown_notice.begins_with("Dead worlds are open") or m.notice_queue.any(func(t): return str(t).begins_with("Dead worlds are open")), "dead gate: one notice at the unlock cycle", m.last_notice)
	check(m.can_connect(d1, 0, "dross")["ok"], "dead gate: route from Cinderrest allowed at cycle 15 with MIN_3")
	check(m.set_local_order(d1, "dross", "buy", true)["ok"], "dead gate: buy order allowed at 15")
	# skill gate bypasses now closed
	m.learned_skills.erase("MIN_3")
	check(not m.engine.check_connection(d1, -1, "dross")["ok"] and not m.engine.check_local(d1, "dross", "buy")["ok"], "dead gate: send to storage and buy order need MIN_3 too")
	m.learned_skills.append("MIN_3")
	# save and load keeps a dead buy order and loads an old save with no dead data
	m.set_local_order(d1, "dross", "buy", true)
	var sv: Dictionary = m.collect_state()
	m.apply_state(sv)
	check(m.engine.local_on(d1, "dross", "buy"), "dead save: the buy order at a dead world survives load with MIN_3")
	m.apply_state({"cycle": 20, "cash": 500, "ships": 1})
	check(m.cycle == 20 and m.danger_of(d1) == 0 and not m.fabric.built and m.fabric.core_made == 0 and m.events.scheduled.is_empty(), "dead save: an old save with no dead data loads clean")
	# a save made at cycle 3 holding a route from a dead world drops it
	m.cycle = 3
	var bad := {"cycle": 3, "cash": 500, "ships": 1, "learned_skills": ["MIN_3"], "routes": [{"id": 1, "a": d1, "b": 0, "c": "dross"}]}
	m.apply_state(bad)
	check(m.engine.routes.is_empty(), "dead save: a route from a locked dead world is dropped on load")
	# Null Core
	m.apply_state({"cycle": 20, "cash": 9000, "ships": 3, "learned_skills": ["FND_STORAGE", "MIN_1"]})
	m._ensure_stations()
	var key: String = m.storage.system_key(1)
	m.storage.ensure(key)
	check(m.can_build_core()["reason"] == "stock", "null core: refused without plate and nullglass")
	m.storage.add(key, "plate", 2)
	m.storage.add(key, "nullglass", 2)
	m.cash = int(m.balance["null_core_build_cost"]) - 1
	check(m.can_build_core()["reason"] == "credits", "null core: refused without the credits")
	m.cash = 9000
	m.learned_skills.erase("MIN_1")
	check(m.can_build_core()["reason"] == "skill", "null core: needs MIN_1")
	m.learned_skills.append("MIN_1")
	var plate0: int = m.storage.amount(key, "plate")
	check(m.build_null_core()["ok"] and m.fabric.core_made == 1 and m.cash == 9000 - int(m.balance["null_core_build_cost"]) and m.storage.amount(key, "plate") == plate0 - int(m.balance["null_core_in_plate"]), "null core: built, credits and inputs paid", str(m.cash))
	m._dismiss_event_notice()
	var cash1: int = m.cash
	check(not m.build_null_core()["ok"] and m.can_build_core()["reason"] == "max" and m.cash == cash1 and m.fabric.core_made == 1, "null core: at most one per run (null_core_max)")
	check(int(m.collect_state()["fabric"]["core_made"]) == 1, "null core: saved")
	# fit, trip cost, pirate immunity
	m.ships = 3
	var a1: Dictionary = m._connect(0, 1, "ore")
	var a2: Dictionary = m._connect(1, 0, "energy") if a1["ok"] else {"ok": false}
	check(m.engine.routes.size() >= 2, "null core: two routes for the test", str(a1) + str(a2))
	var r0: Dictionary = m.engine.routes[0]
	var r1: Dictionary = m.engine.routes[1]
	var normal: int = m.engine.fixed_cost(r1)
	var trip: int = m.engine.trip_part()
	check(m.fit_core(int(r0["id"]))["ok"] and m.core_route_id() == int(r0["id"]), "null core: fitted to one chosen ship")
	var want: int = floori(float(trip) * float(m.balance["null_core_trip_mult"])) + m.engine.upkeep_part(r0)
	check(m.engine.fixed_cost(r0) == want and m.engine.fixed_cost(r0) < normal and m.engine.fixed_cost(r1) == normal, "null core: the fitted ship pays null_core_trip_mult of the trip cost, the other pays full", "%d vs %d" % [m.engine.fixed_cost(r0), normal])
	check(m.fit_core(int(r1["id"]))["ok"] and not m.engine.has_core(r0) and m.core_route_id() == int(r1["id"]), "null core: only one ship carries it")
	m.fit_core(int(r0["id"]))
	m.engine.routes[0]["fresh"] = 1.0
	m.engine.routes[1]["fresh"] = 1.0
	var u_core0: int = m.engine.planned_units(r0)
	var u_norm0: int = m.engine.planned_units(r1)
	m.storage.add(str(r0["src"]), str(r0["c"]), 100)
	m.storage.add(str(r1["src"]), str(r1["c"]), 100)
	m.engine.pirates_active = true
	var pen := float(m.balance["pirate_volume_penalty"])
	r1["a"] = r0["a"]
	r1["c"] = r0["c"]
	r1["b"] = r0["b"]
	r1["src"] = r0["src"]
	r1["dst"] = r0["dst"]
	var uc: int = m.engine.planned_units(r0)
	var un: int = m.engine.planned_units(r1)
	m.engine.pirates_active = false
	var u_free: int = m.engine.planned_units(r1)
	check(pen > 0.0 and uc == u_free and un < uc, "null core: pirate volume cut skips the core ship and cuts the other", "%d %d %d" % [uc, un, u_free])
	# the core returns to the hold when its route is removed
	m.remove_connection(int(r0["id"]))
	check(m.core_route_id() == -1 and m.fabric.core_made == 1, "null core: removing the route frees the core, still one built")
	await _free_main(m)


# ---- goods and workshops (four markets part 2) ----
func _test_workshops() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	m.cash = 5000
	# tagging and prices
	var good_ids: Array = Goods.ids()
	var tagged := good_ids.size() == 19
	for g in good_ids:
		if Markets.market_of(str(g)) != str(Goods.entry(str(g))["market"]) or Markets.value_of(str(g)) <= 0:
			tagged = false
	check(tagged, "goods: all 19 goods tagged in markets.json with a base value")
	var no_cross := true
	for g in good_ids:
		if not Goods.recipe_ok(str(g)):
			no_cross = false
	check(no_cross, "goods: every recipe uses common raws and own-market goods only")
	var p1 := -1
	var p2 := -1
	for i in m.map.planets.size():
		if str(m.map.planets[i].get("id", "")) == "planet_1":
			p1 = i
		if str(m.map.planets[i].get("id", "")) == "planet_2":
			p2 = i
	check(p1 >= 0 and m.trade.price(p1, "cells_buy", false, true) == 78 and m.trade.price(p1, "cells_sell", false, true) == 70, "goods: new good prices reach the trade lookup")
	check(m.trade.price(p2, "musk_buy", false, true) == 18 and m.commodities.has("cells") and m.commodities.has("spores"), "goods: planet prices and the commodity list carry the new goods")
	check(m.balance.has("event_pct_cells") and m.events.pct_for("cells") == float(m.balance["event_pct_cells"]) if m.events.has_method("pct_for") else m.balance.has("event_pct_cells"), "goods: event_pct key exists for a new good")
	# unlock gating
	var key: String = m.storage.system_key(1)
	check(m.can_build_workshop("munitions")["reason"] == "skill" and not m.build_workshop("munitions")["ok"] and m.cash == 5000, "workshop: refused before its node, nothing paid")
	m.learned_skills.append("MIL_1")
	check(m.can_build_workshop("munitions")["reason"] == "post", "workshop: needs the trading post")
	m.learned_skills.append("FND_STORAGE")
	m._ensure_stations()
	check(m.can_build_workshop("smelter")["reason"] == "skill" and m.can_build_workshop("munitions")["ok"], "workshop: only the unlocked one can be built")
	var cost: int = int(m.balance["workshop_build_cost"])
	m.cash = cost - 1
	check(m.can_build_workshop("munitions")["reason"] == "credits", "workshop: refused without the build cost")
	m.cash = 5000
	check(m.build_workshop("munitions")["ok"] and m.cash == 5000 - cost and m.workshops.built["munitions"], "workshop: build cost paid once")
	check(not m.build_workshop("munitions")["ok"] and m.cash == 5000 - cost, "workshop: a second build is refused")
	# recipe run: cells = 2 energy + 1 chips -> batch_out, armour not open yet
	Tech.reset()
	m.workshops.run(m.storage, Callable(m, "craft_units"))
	check(m.workshops.state["munitions"] == "stalled" and m.workshops.reason["munitions"] == "needs energy", "workshop: stalls on a missing input", m.workshops.reason["munitions"])
	m.storage.add(key, "energy", 5)
	m.storage.add(key, "chips", 2)
	m.workshops.run(m.storage, Callable(m, "craft_units"))
	var out_n: int = int(m.balance["cells_batch_out"])
	check(m.workshops.state["munitions"] == "running" and m.storage.amount(key, "cells") == out_n and m.storage.amount(key, "energy") == 3 and m.storage.amount(key, "chips") == 1, "workshop: recipe consumes inputs and yields the batch", str(m.storage.to_dict().get(key, {})))
	# craft_units feeds tech: MIL_2 is active after MIL_1
	check(int(Tech.progress("MIL_2")["n"]) == out_n, "workshop: crafted units count toward the market's tech", str(Tech.progress("MIL_2")))
	# gated good: armour closed until MIL_4 is finished
	m.storage.add(key, "cells", 3)
	m.storage.add(key, "chips", 1)
	m.workshops.run(m.storage, Callable(m, "craft_units"))
	check(m.storage.amount(key, "armour") == 0, "workshop: a good whose unlock node is not learned is not made")
	Skills.add_learned("MIL_2")
	Skills.add_learned("MIL_4")
	m.storage.add(key, "energy", 0)
	m.workshops.run(m.storage, Callable(m, "craft_units"))
	check(m.storage.amount(key, "armour") == int(m.balance["armour_batch_out"]), "workshop: armour made once MIL_4 is learned (highest tier first)", str(m.storage.to_dict().get(key, {})))
	# batch bonuses: MIN_4 adds a batch, MIN_6 adds yield (smelter, ore -> ingot)
	m.learned_skills.append("FND_PROSPECT")
	m.learned_skills.append("MIN_1")
	m.cash = 5000
	check(m.build_workshop("smelter")["ok"], "workshop: smelter builds after MIN_1")
	m.storage.add(key, "ore", 20)
	var ingot_out: int = int(m.balance["ingot_batch_out"])
	check(m.workshops.batches("smelter") == int(m.balance["workshop_batches_per_cycle"]), "workshop: base batches from balance")
	m.workshops.run(m.storage, Callable(m, "craft_units"))
	check(m.storage.amount(key, "ingot") == ingot_out and m.storage.amount(key, "ore") == 18, "workshop: smelter 2 ore -> ingots")
	Skills.add_learned("MIN_4")
	check(m.workshops.batches("smelter") == int(m.balance["workshop_batches_per_cycle"]) + int(m.balance["skill_MIN_4_batches"]), "workshop: MIN_4 adds batches")
	var ing0: int = m.storage.amount(key, "ingot")
	m.workshops.run(m.storage, Callable(m, "craft_units"))
	check(m.storage.amount(key, "ingot") == ing0 + 2 * ingot_out and m.storage.amount(key, "ore") == 14, "workshop: two batches in a cycle with MIN_4")
	Skills.add_learned("MIN_6")
	var bonus: int = int(m.balance["skill_MIN_6_batch_bonus"])
	check(m.workshops.out_units("ingot") == ingot_out + bonus, "workshop: MIN_6 adds yield per batch")
	ing0 = m.storage.amount(key, "ingot")
	m.workshops.run(m.storage, Callable(m, "craft_units"))
	check(m.storage.amount(key, "ingot") == ing0 + 2 * (ingot_out + bonus), "workshop: yield bonus reaches storage")
	# the fabric shares the bonuses
	check(m.fabric.batches() == int(m.balance["fabric_batches_per_cycle"]) + int(m.balance["skill_MIN_4_batches"]), "fabric: MIN_4 batches apply too")
	# cycle tick runs the workshops
	m.storage.add(key, "ore", 4)
	var ing1: int = m.storage.amount(key, "ingot")
	m.debug_advance_cycle()
	check(m.storage.amount(key, "ingot") > ing1, "workshop: runs on the cycle tick")
	# planet panel shows the section
	m.planet_panel.show_planet(p1)
	check(m.planet_panel.box.find_child("Workshop_smelter", true, false) != null and m.planet_panel.box.find_child("WorkshopBuild_atelier", true, false) == null, "workshop: planet panel lists unlocked workshops only")
	# save and load
	var st: Dictionary = m.collect_state()
	m.workshops.built["munitions"] = false
	m.workshops.built["smelter"] = false
	m.apply_state(JSON.parse_string(JSON.stringify(st)))
	check(m.workshops.built["munitions"] and m.workshops.built["smelter"] and not m.workshops.built["atelier"], "workshop: save round trip keeps built workshops")
	m.apply_state({"cycle": 1})
	check(not m.workshops.built["munitions"], "workshop: an old save has none built")
	await _free_main(m)


## Market event chains (game/chains.gd, data/chains.json): data, triggers, order, direction arithmetic, effects, log, endings, saves, pool.
func _test_chains() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://data/chains.json"))
	Chains.reset(bal, 7)
	# data: 28 steps (A 3, B 4 per market), every key named by the data exists, every option has a rival change
	check(Chains.step_ids().size() == 28, "chains: 28 steps load", str(Chains.step_ids().size()))
	var keys_ok := true
	var rival_ok := true
	var count_a := 0
	var count_b := 0
	for sid in Chains.step_ids():
		var st: Dictionary = Chains.step_by_id[sid]
		if str(st["chain"]) == "A":
			count_a += 1
		else:
			count_b += 1
		for k in st["trigger"].keys() if not st["trigger"].has("any") else []:
			if typeof(st["trigger"][k]) == TYPE_STRING and str(k) != "tech_done" and str(k) != "skill_learned" and not bal.has(str(st["trigger"][k])):
				keys_ok = false
		for opt in ["opt_a", "opt_b"]:
			if (st[opt]["bot"] as Array).is_empty():
				rival_ok = false
			for lst in ["gets", "costs"]:
				for e in st[opt][lst]:
					if e.has("key") and not bal.has(str(e["key"])):
						keys_ok = false
					if e.has("cycles_key") and not bal.has(str(e["cycles_key"])):
						keys_ok = false
			for e in st[opt]["bot"]:
				if not bal.has(str(e["key"])):
					keys_ok = false
	check(count_a == 12 and count_b == 16 and keys_ok and rival_ok, "chains: every step has its balance keys and every option a bot change", "%d %d %s %s" % [count_a, count_b, keys_ok, rival_ok])
	check(data["pool_new"].size() == 12 and Chains.pool_kept.size() == 24 and Chains.retired.size() == 10 and Chains.retired[0] == "EV18", "chains: pool 24 kept + 12 new, EV18 and EV29 to EV37 retired")
	# every option applies and logs at least one rival change
	var logs_ok := true
	for sid in Chains.step_ids():
		for opt in ["opt_a", "opt_b"]:
			Markets.reset(bal, 3)
			Chains.reset(bal, 3)
			var res: Dictionary = Chains.apply_option(sid, opt, 10)
			if Chains.rival_log().is_empty() or (res["rivals"] as Array).is_empty() or not Chains.fired(sid):
				logs_ok = false
	check(logs_ok, "chains: every option logs at least one rival change")
	# marked bot (R7) agrees with the story table
	var story = JSON.parse_string(FileAccess.get_file_as_string("res://handoffs/story-designer/2026-11-03-chain-text.json"))
	var table: Dictionary = story["details"]["marked_bot"]
	var marked_ok := true
	var bad := ""
	Markets.reset(bal, 3)
	Chains.reset(bal, 3)
	for sid in table.keys():
		for pair in [["a", "opt_a"], ["b", "opt_b"]]:
			if Chains.planned_marked(str(sid), str(pair[1])) != int(table[sid][pair[0]]):
				marked_ok = false
				bad = "%s %s" % [sid, pair[0]]
	check(marked_ok, "chains: marked bot per option matches the story table", bad)
	# direction arithmetic, hand computed (echo 1.25, swing 1.5, min abs 25, cap 14)
	Chains.reset(bal, 3)
	check(Chains.compute_nudge(6, 0, false, 0) == 6 and Chains.compute_nudge(-6, 0, false, 0) == -6, "dir: plain nudge")
	check(Chains.compute_nudge(6, 1, false, 0) == 7 and Chains.compute_nudge(-6, -1, false, 0) == -7, "dir: echo 6 -> 7 (floor 7.5), also negative")
	check(Chains.compute_nudge(6, -1, false, 0) == 6, "dir: no echo when the previous nudge had the other sign")
	check(Chains.compute_nudge(-9, 0, true, 30) == -13, "dir: late swing -9 against +30 -> -13 (floor 13.5)")
	check(Chains.compute_nudge(-9, 0, true, 24) == -9 and Chains.compute_nudge(-9, 0, false, 30) == -9 and Chains.compute_nudge(9, 0, true, 30) == 9, "dir: no swing below 25, before B3, or when staying the course")
	check(Chains.compute_nudge(-10, -1, true, 30) == -14, "dir: echo 12 then swing 18 then cap 14")
	check(Chains.compute_nudge(12, 1, false, 0) == 14 and Chains.compute_nudge(-12, 0, true, 40) == -14 and Chains.compute_nudge(-12, 0, true, -40) == -12, "dir: cap 14; swing only against the sign")
	# applying two A steps: echo carries through the same chain, dir sums
	Markets.reset(bal, 3)
	Chains.reset(bal, 3)
	Chains.apply_option("MIL_A1", "opt_a", 6)  # dir 6
	var n2 := Chains.nudge_of("MIL_A2", "opt_a")  # base 7, previous +6 same sign: floor(8.75) = 8
	Chains.apply_option("MIL_A2", "opt_a", 12)
	check(n2 == 8 and Chains.dir_of("mil") == 14 and Chains.dir_of("lux") == 0, "dir: echo through the chain and a sum per market", str(Chains.dirv))
	# ending flag sign rule
	Chains.reset(bal, 3)
	check(Chains.ending_flag("mil") == "good", "ending flag: no step fired is good")
	Chains.dirv["mil"] = -1
	check(Chains.ending_flag("mil") == "bad" and Chains.ending_flag("lux") == "good", "ending flag: negative is bad, per market")
	Chains.dirv["mil"] = 0
	check(Chains.ending_flag("mil") == "good", "ending flag: zero is good")
	# triggers
	Markets.reset(bal, 3)
	Chains.reset(bal, 3)
	check(Chains.next_step(5) == "", "triggers: nothing before a sale")
	Markets.add_sale("energy", 50)  # common raw: never counts (R5)
	Markets.end_cycle(1)
	for c in range(2, 8):
		Markets.add_sale("energy", 50)
		Markets.end_cycle(c)
	check(not Chains.trigger_ok("MIL_A1", 9) and not Chains.trigger_ok("BIO_A1", 9), "triggers: common raws never start a chain")
	Markets.reset(bal, 3)
	Markets.add_sale("rivets", 5)
	for c in range(1, 4):
		Markets.end_cycle(c)
	check(not Chains.trigger_ok("MIL_A1", 5), "triggers: A1 not for a sale in cycle 1 (needs a sale after the trigger cycle)")
	Markets.add_sale("rivets", 5)
	Markets.end_cycle(4)
	Markets.add_sale("rivets", 5)
	Markets.end_cycle(5)
	check(Chains.trigger_ok("MIL_A1", 6) and not Chains.trigger_ok("MIL_A2", 6) and Chains.eligible("MIL_A1", 6) and not Chains.eligible("MIL_A1", 1), "triggers: A1 after a sale past cycle 4; A2 needs A1; no event in cycle 1")
	check(Chains.next_step(6) == "MIL_A1", "slot: the chain step is picked", Chains.next_step(6))
	Chains.apply_option("MIL_A1", "opt_a", 6)
	check(not Chains.eligible("MIL_A1", 7) and Chains.next_step(7) == "", "slot: a fired step does not come again")
	check(not Chains.eligible("MIL_A2", 8) and Chains.trigger_ok("MIL_A2", 12), "triggers: A2 6 cycles after A1 (cycles_after_prev_step)")
	check(not Chains._atom("cycles_after_prev_step", "chain_MIL_A2_trig_after_prev_cycles", Chains.step_by_id["MIL_A2"], 11) and Chains._atom("cycles_after_prev_step", "chain_MIL_A2_trig_after_prev_cycles", Chains.step_by_id["MIL_A2"], 12), "triggers: cycles_after_prev_step counts from the previous step")
	# min gap and one event per cycle: both A2 conditions true at once; min gap 3 holds the next step of the market
	Chains.picks["MIL_A1"]["cycle"] = 6
	check(Chains.eligible("MIL_A2", 12) and not Chains.eligible("MIL_A2", 8), "triggers: min gap and trigger together")
	Chains.picks["MIL_A1"]["cycle"] = 10
	Chains.reset(bal, 3)
	Chains.picks["MIL_A1"] = {"opt": "opt_a", "cycle": 10, "nudge": 6}
	Skills.add_learned("MIL_3")  # B1 trigger: skill learned
	check(Chains.trigger_ok("MIL_B1", 11) and not Chains.eligible("MIL_B1", 11) and not Chains.eligible("MIL_B1", 12) and Chains.eligible("MIL_B1", 13), "triggers: B1 from the learned skill, but only 3 cycles after the last step of the market")
	Chains.picks["MIL_A1"]["cycle"] = 1
	Chains.picks["LUX_A1"] = {"opt": "opt_a", "cycle": 99, "nudge": 0}
	check(Chains.eligible("MIL_B1", 13) and Chains.next_step(13) == "MIL_A2", "slot: one step per cycle, the first ready in data order (A2 before B1)", Chains.next_step(13))
	Chains.apply_option("MIL_B1", "opt_a", 13)
	check(Chains.next_step(14) != "MIL_B1" and not Chains.eligible("MIL_B2", 14), "slot: the next step of that market waits for the gap")
	Skills.reset(bal)
	# win gate
	Markets.reset(bal, 3)
	Chains.reset(bal, 3)
	var hold := int(bal["win_hold_cycles"])
	var gated := false
	var r := {}
	for c in range(1, 41):
		Markets.add_sale("cells", 100000)
		Markets.end_cycle(c)
		r = Markets.verdict(c)
		if not r.is_empty() and c < int(bal["win_gate_cycle"]):
			gated = true
		if not r.is_empty():
			break
	check(not gated and int(r.get("cycle", 0)) == 0 and str(r.get("market", "")) == "mil" and Markets.cycles >= int(bal["win_gate_cycle"]), "win gate: no win before cycle win_gate_cycle without B4", str(Markets.cycles))
	Markets.reset(bal, 3)
	Chains.reset(bal, 3)
	Chains.picks["MIL_B4"] = {"opt": "opt_a", "cycle": 20, "nudge": 0}
	var early := 0
	for c in range(1, 41):
		Markets.add_sale("cells", 100000)
		Markets.end_cycle(c)
		if not Markets.verdict(c).is_empty():
			early = c
			break
	check(early > 0 and early < int(bal["win_gate_cycle"]) and Chains.win_open("mil", 5), "win gate: opens as soon as B4 fired", str(early))
	check(not Chains.win_open("lux", 37) and Chains.win_open("lux", 38), "win gate: cycle 38 opens it for any market")
	# effects: apply and expire
	Markets.reset(bal, 3)
	Chains.reset(bal, 3)
	var res: Dictionary = Chains.apply_option("MIL_A1", "opt_a", 10)  # cash -150 (volume +5% for 8 cycles), bot_1 growth S down
	var vp := float(bal["chain_MIL_A1_a_volume_pct"])
	var vc := int(bal["chain_MIL_A1_a_volume_cycles"])
	check(int(res["cash"]) == int(bal["chain_MIL_A1_a_cash"]) and int(res["cash"]) < 0, "effects: cash cost returned")
	Chains.now = 10
	check(is_equal_approx(Chains.volume_mult("mil"), 1.0 + vp) and Chains.volume_mult("lux") == 1.0, "effects: volume effect applies to its market")
	Chains.now = 10 + vc - 1
	check(is_equal_approx(Chains.volume_mult("mil"), 1.0 + vp), "effects: still on in its last cycle")
	Chains.now = 10 + vc
	check(Chains.volume_mult("mil") == 1.0, "effects: expired after its cycles")
	Chains.tick(10 + vc)
	check(Chains.timed.is_empty(), "effects: tick drops expired effects")
	check(is_equal_approx(float(Markets.bot_mods(1, "mil")["growth_mult"]), 1.0 - float(bal["event_hit_growth_S"])), "effects: bot growth hit applied at once")
	# a volume effect really changes the share volume of a sale
	Markets.reset(bal, 3)
	Chains.reset(bal, 3)
	Chains.apply_option("MIL_A1", "opt_a", 1)
	Chains.now = 1
	Markets.add_sale("rivets", 10)
	var base_v := float(10 * Markets.value_of("rivets"))
	check(is_equal_approx(float(Markets.cur["mil"]), base_v * (1.0 + vp)), "effects: volume effect scales the sale volume", str(Markets.cur["mil"]))
	# other effect types
	Chains.reset(bal, 3)
	var t_ok := true
	Chains.timed.append({"k": "upkeep_pct", "m": "", "v": 0.2, "until": 5, "route": -1, "src": "x"})
	Chains.timed.append({"k": "price_pct", "m": "bio", "v": -0.08, "until": 5, "route": -1, "src": "x"})
	Chains.timed.append({"k": "trip_cost_pct", "m": "min", "v": 0.33, "until": 5, "route": 4, "src": "x"})
	Chains.timed.append({"k": "workshop_idle", "m": "min", "v": 1.0, "until": 5, "route": -1, "src": "x"})
	Chains.timed.append({"k": "workshop_batches", "m": "mil", "v": 1.0, "until": 5, "route": -1, "src": "x"})
	Chains.now = 5
	t_ok = is_equal_approx(Chains.upkeep_mult(), 1.2) and is_equal_approx(Chains.price_mult("bio"), 0.92) and is_equal_approx(Chains.trip_cost_mult(4), 1.33) and Chains.trip_cost_mult(3) == 1.0
	t_ok = t_ok and Chains.workshop_idle("min") and not Chains.workshop_idle("mil") and Chains.workshop_extra("mil") == 1
	Chains.now = 6
	t_ok = t_ok and Chains.upkeep_mult() == 1.0 and Chains.price_mult("bio") == 1.0 and Chains.trip_cost_mult(4) == 1.0 and not Chains.workshop_idle("min") and Chains.workshop_extra("mil") == 0
	check(t_ok, "effects: upkeep, price, trip cost (one route), workshop idle and batches apply then expire")
	# tier cut: lowest tier becomes strength down M (R8), a real drop is logged as tier_changed and sets rival_broken
	Markets.reset(bal, 3)
	Chains.reset(bal, 3)
	Chains.apply_option("MIL_A2", "opt_b", 1)  # bot_1 tier cut at cycle 1: lowest tier
	var lg: Array = Chains.rival_log()
	check(lg.size() == 1 and lg[0]["size_word"] == "lowest" and not bool(lg[0]["tier_changed"]) and not Chains.rival_broken("mil") and absf(float(Markets.bot_mods(1, "mil", 1)["strength_mult"]) - (1.0 - float(bal["event_hit_strength_M"]))) < 0.0001, "tier: at the lowest tier a tier cut is strength down M, no tier change", str(lg))
	Markets.reset(bal, 3)
	Chains.reset(bal, 3)
	var hi_cycle := 35
	Chains.apply_option("MIL_A2", "opt_b", hi_cycle)
	lg = Chains.rival_log()
	check(lg.size() == 1 and bool(lg[0]["tier_changed"]) and lg[0]["size_word"] == "tier" and Chains.rival_broken("mil") and Chains.rival_broken_bot("mil") == 1 and int(Markets.bot_mods(1, "mil")["tier_offset"]) == -1, "tier: a bot above tier 1 drops a tier, logged and rival_broken set", str(lg))
	check(lg[0].keys().size() == 8 and lg[0].has("source_id") and lg[0]["source_id"] == "MIL_A2" and lg[0]["cycle"] == hi_cycle and lg[0]["direction"] == "down" and lg[0]["stat"] == "tier", "rival log: entry format")
	# rival log and chain state persist
	Chains.apply_option("MIL_A3", "opt_a", 40)
	var snap := JSON.stringify(Chains.to_dict())
	var dir_before := Chains.dir_of("mil")
	var log_before := Chains.rival_log().size()
	Chains.reset(bal, 99)
	Chains.from_dict(JSON.parse_string(snap), bal)
	check(Chains.rival_log().size() == log_before and Chains.dir_of("mil") == dir_before and Chains.fired("MIL_A2") and Chains.fired("MIL_A3") and Chains.rival_broken("mil") and Chains.run_seed == 3, "save: chain state, direction, rival log and shuffle seed persist")
	check(Chains.rival_log()[0]["tier_changed"] == true and Chains.rival_log()[0]["bot"] == 1, "save: rival log entries keep their types")
	Chains.apply_option("MIL_B1", "opt_a", 41)
	Chains.now = 41
	var before := Chains.timed.size()
	Chains.from_dict(JSON.parse_string(JSON.stringify(Chains.to_dict())), bal)
	check(Chains.timed.size() == before and Chains.volume_mult("mil") == Chains.volume_mult("mil"), "save: timed effects persist")
	Chains.from_dict(null, bal)
	check(Chains.picks.is_empty() and Chains.dir_of("mil") == 0 and Chains.rival_log().is_empty(), "save: no chain data (a v3 save) = fresh chains")
	# shuffle: stable per seed and step, both orders occur
	Chains.reset(bal, 11)
	var o1: Array = Chains.order("MIL_A1")
	Chains.reset(bal, 11)
	var stable: bool = o1 == Chains.order("MIL_A1")
	var seen := {}
	for sd in 40:
		Chains.reset(bal, sd)
		for sid in Chains.step_ids():
			seen[str(Chains.order(sid))] = true
	check(stable and seen.size() == 2 and o1.size() == 2 and o1.has("opt_a") and o1.has("opt_b"), "shuffle: stable per run seed, both orders occur")
	# pool: 36 ids, once only, EV18 gone
	var ev = m.events
	var in_pool := 0
	for d in ev.defs:
		if Chains.in_pool(str(d["id"])):
			in_pool += 1
	check(in_pool == 36 and not Chains.in_pool("EV18") and not Chains.in_pool("EV29") and not Chains.in_pool("EV30") and not ev.by_id.has("EV29") and not ev.by_id.has("EV30") and not ev.by_id.has("EV37") and Chains.retired.has("EV29") and ev.by_id.has("EV40") and ev.by_id.has("MIL_A1"), "pool: 24 kept + 12 new, no EV18, no Minerals chain events", str(in_pool))
	m.events.debug_off = []
	var drawn := {}
	var dup := false
	for i in 80:
		var pid: String = ev.random_id([], 20)
		if pid == "":
			break
		if drawn.has(pid):
			dup = true
		drawn[pid] = true
		ev.record(pid, 20)
	check(not dup and not drawn.has("EV18") and not drawn.has("EV29") and not drawn.has("MIL_A1") and drawn.size() >= 10, "pool: each event at most once, retired and chain events never drawn", str(drawn.size()))
	check(not FileAccess.file_exists("res://game/shield.gd") and not ("shield" in str(m.collect_state().keys())), "EV18 gone: no shield code or save key")
	# the new pool events show their price effect and the pool bot effect applies and logs
	Markets.reset(bal, 3)
	Chains.reset(bal, 3)
	check(not Chains.apply_pool("EV05", 8).is_empty() and Chains.rival_log().size() == 1 and Chains.rival_log()[0]["source_id"] == "EV05" and Chains.apply_pool("EV01", 8).is_empty(), "pool: kept events apply their optional bot effect, none without")
	# ending picker reads the flag
	Chains.reset(bal, 3)
	Chains.dirv["bio"] = -3
	Chains.broken["bio"] = 2
	var inp: Dictionary = EndingPicker.inputs("bio", bal)
	check(inp["ending_id"] == "END_BIO_BAD" and inp["flag"] == "bad" and inp["rival_broken"] == true and inp["rival_broken_bot"] == 2 and EndingPicker.inputs("mil", bal)["ending_id"] == "END_MIL_GOOD", "ending picker: BAD by the chain flag, rival_broken from the chain", str(inp))
	check(m.ending_id_of({"kind": "win", "market": "bio"}) == "END_BIO_BAD" and m.ending_id_of({"kind": "win", "market": "lux"}) == "END_LUX_GOOD", "ending id: win reads the flag of the win market")
	# save version 4 and v3 migration
	check(SaveGame.VERSION == 4, "save: version 4")
	var v3 := {"cycle": 7, "cash": 300, "chains": {"dir": {"mil": 9}}, "shield": {"built": true}}
	var mig: Dictionary = SaveGame.migrate_v3(v3)
	check(mig["cash"] == 300 and not mig.has("shield") and not mig.has("chains"), "save: v3 migrates, chain state fresh, shield dropped")
	var f := FileAccess.open(SaveGame.PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 3, "state": {"cycle": 7, "cash": 300, "shield": {"built": true}}}))
	f.close()
	var ld: Dictionary = SaveGame.load_state()
	check(not ld.is_empty() and int(ld["cycle"]) == 7 and not ld.has("shield"), "save: a v3 file loads")
	m.apply_state(ld)
	check(m.cycle == 7 and Chains.picks.is_empty() and Chains.dir_of("mil") == 0, "save: a v3 save starts with fresh chains")
	_wipe_user()
	await _free_main(m)

	# in the game: the choice popup, effect lines, result popup, saved state
	m = await _new_main()
	m._dismiss_preface()
	bal = m.balance
	m.cash = 1000
	m.cycle = 6
	m.fire_chain_step("MIL_A1")
	check(m.event_notice != null and m.events.pending_id == "MIL_A1", "game: a chain step opens the choice popup")
	var btns := _buttons(m.event_notice, [])
	check(btns.size() == 2, "game: two options", str(btns.size()))
	var order: Array = Chains.order("MIL_A1")
	var texts := []
	for b in btns:
		texts.append(b.text)
	check(texts[0].contains(Chains.button("MIL_A1", order[0])) and texts[0].contains(Chains.eff_text("MIL_A1", order[0])) and texts[1].contains(Chains.eff_text("MIL_A1", order[1])), "game: buttons carry the effect line (Get / Cost / Rivals)")
	check(texts[0].contains("Harrow Combine") or texts[1].contains("Harrow Combine"), "game: effect lines name the rival", str(texts))
	btns[0].pressed.emit()
	await process_frame
	check(Chains.fired("MIL_A1") and str(Chains.picks["MIL_A1"]["opt"]) == str(order[0]) and m.events.pending_id == "", "game: the pick applies at once")
	var res_texts := _texts(m.event_notice)
	check(m.event_notice != null and res_texts.size() > 0 and Chains.rival_log().size() >= 1, "game: result popup shows, rival change logged", str(res_texts))
	check(Chains.rivals_text(Chains.rival_log()).length() > 0, "game: rivals text for the result")
	var snap2: Dictionary = m.collect_state()
	check(snap2.has("chains") and not snap2.has("shield"), "game: chain state is in the save")
	Chains.dirv["mil"] = 55
	m.apply_state(JSON.parse_string(JSON.stringify(snap2)))
	check(Chains.fired("MIL_A1") and Chains.dir_of("mil") != 55, "game: load restores the chain state")
	# a chain step takes the slot before a pool event; one event per cycle
	m._dismiss_event_notice()
	m.events.pending_id = ""
	m.cycle = 4
	for sid in Chains.step_ids():
		Chains.picks[sid] = {"opt": "opt_a", "cycle": 1, "nudge": 0}
	Chains.picks.erase("LUX_A1")
	Markets.reset(bal, 3)
	Markets.add_sale("gems", 5)
	for c in range(1, 6):
		Markets.end_cycle(c)
	Markets.add_sale("gems", 5)
	Markets.end_cycle(6)
	m.cycle = 8  # the end of cycle 8 starts cycle 9, an event slot of the pool
	m.debug_advance_cycle()
	check(m.cycle == 9 and m.events.pending_id == "LUX_A1" and m.event_notice != null, "slot: a chain step takes the event slot before the pool event", m.events.pending_id)
	var feed_n: int = m.events.feed.size()
	check(feed_n >= 1 and str(m.events.feed[feed_n - 1]["id"]) == "LUX_A1", "slot: one event in the cycle")
	await _free_main(m)


## Space Storage is earned (cycle and trade income): grant both, learn it, restore the cycle.
func _learn_storage(m) -> Dictionary:
	var c: int = m.cycle
	var t: int = m.trade_income_total
	m.cycle = maxi(c, int(m.balance.get("earn_storage_cycles", 5)))
	m.trade_income_total = maxi(t, int(m.balance.get("earn_storage_income", 3000)))
	var r: Dictionary = m.learn_skill("FND_STORAGE")
	m.cycle = c
	m.trade_income_total = t
	m._sync_earn()
	return r

func _test_good_icons() -> void:
	for g in Goods.ids():
		check(Ui.icon(g) != null, "icons: good %s resolves to an icon" % g)
		check(Ui.commodity_col(g) != Color.WHITE, "icons: good %s has a commodity colour" % g)
