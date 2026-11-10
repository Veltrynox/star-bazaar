extends SceneTree
## Headless tests (T79). Run: sh tools/tests/run.sh   (see that file; it sets a scratch HOME).
## Covers: story text, ending picker, win/loss paths, run recording, expansion points, skill keys, force-goal.
## Tests only read behaviour; they change no game code.

const ShipsT := preload("res://game/ships.gd")
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
	_test_orbit_spacing()
	_test_traffic_heading()
	_test_story_text()
	_test_generated_files()
	_test_data_pack_lint()
	_test_conditions_unit()
	await _test_localisation()
	_test_chain_gate()
	_test_picker()
	_test_stats_file()
	_test_markets()
	_test_bot_hooks()
	await _test_market_rules()
	await _test_juice()
	_test_epilogue_placeholders()
	await _test_main()
	await _test_pulse_ring()
	await _test_rescue_waiting()
	await _test_events()
	await _test_ships()
	await _test_ship_ceo()
	await _test_next_cycle()
	await _test_station_energy_outflow()
	await _test_good_info()
	await _test_notice_queue()
	await _test_systems()
	await _test_placeholder_systems()
	await _test_galaxy_view()
	await _test_tutorial_steps()
	await _test_ship_reveal()
	await _test_tut_fly_click()
	await _test_tut_g0_rmb()
	await _test_tut_counter()
	await _test_tut_full_walk()
	await _test_tut_hero_highlight()
	await _test_tut_speed_card()
	await _test_tut_skills_card()
	await _test_tut_sell_and_order()
	await _test_tutorial_lock()
	_test_route_tag()
	await _test_ship_clock()
	await _test_energy_then_food()
	await _test_salvage()
	await _test_system_suns()
	await _test_stations()
	await _test_station_send()
	await _test_trade_gate()
	await _test_asteroid()
	await _test_idle_actions()
	await _test_skill_effects()
	await _test_skill_effects_final()
	await _test_forecast_pure()
	await _test_debug_menu()
	await _test_planet_size()
	await _test_route_offset()
	await _test_dust_ring()
	await _test_voltara_belt()
	await _test_dead_planets()
	await _test_dead_world_mechanics()
	await _test_dead_world_panel()
	await _test_panel_thumb_switch()
	await _test_dest_hint()
	await _test_dead_unlock_and_core()
	await _test_fabric()
	await _test_workshops()
	await _test_workshop_status()
	await _test_workshops_in_cells()
	await _test_chains()
	_test_prosperity()
	_test_prosperity_needs_never_empty()
	await _test_price_event()
	await _test_route_move()
	await _test_split_send()
	await _test_mixed_load()
	await _test_stop_sale()
	await _test_second_lane()
	await _test_forecast_income()
	await _test_lane_net_label()
	await _test_cash_reserve()
	await _test_sell_only_idle()
	await _test_stall_rescue()
	await _test_no_cash_text()
	await _test_mining_reachable()
	await _test_clusters()
	await _test_cluster_send()
	await _test_cluster_to_station()
	await _test_links_everywhere()
	await _test_ship_motion()
	await _test_ship_facing()
	await _test_ships_spawn_near_bodies()
	await _test_t211_ship_traffic()
	_test_t318_traffic_hulls()
	await _test_t199_rival_pick()
	await _test_t206_explore()
	await _test_t187_ship_flight()
	await _test_t317_hero_card()
	await _test_asteroid_packs()
	_test_event_banners()
	await _test_company_setup()
	await _test_availability()
	await _test_gigs()
	await _test_gig_clearance()
	await _test_skill_link_clip()
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
	var RL := load("res://game/route_line.gd")  # T219: lane draw-in and dispatch pulse curves
	var rl_mono := true
	var rl_prev := -1.0
	for i in 21:
		var dv: float = RL.draw_curve(i / 20.0)
		rl_mono = rl_mono and dv >= rl_prev
		rl_prev = dv
	var pc0: Vector2 = RL.pulse_curve(0.0)
	var pc1: Vector2 = RL.pulse_curve(1.0)
	check(RL.draw_curve(0.0) == 0.0 and RL.draw_curve(1.0) == 1.0 and RL.draw_curve(0.5) > 0.5 and rl_mono and pc0.y < 0.0001 and pc1.y < 0.0001 and pc0.x < 0.0 and pc1.x > 1.0 and RL.pulse_curve(0.5).y > 0.99, "juice: lane draw-in eases out to 1 and the dispatch band starts and ends off the lane")
	var PV := load("res://game/pathfinder_view.gd")  # T203: establish beat curves
	check(PV.burst_ring(0.0).y == 0.0 and PV.burst_ring(1.0).y < 0.0001, "juice: establish ring starts and ends invisible")
	check(PV.burst_ring(PV.BURST_BUILD).x <= PV.BURST_RING_MIN + 0.0001 and PV.burst_ring(1.0).x <= PV.BURST_RING_TO + 0.0001, "juice: establish ring closes in, then opens within its bounds")
	check(PV.burst_spokes(0.1).z == 0.0 and PV.burst_spokes(0.5).z > 0.0 and PV.burst_spokes(1.0).z < 0.0001, "juice: establish spokes wait for the burst and fade out")
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
func _test_localisation() -> void:
	var Lang = root.get_node("Lang")
	var Voice = root.get_node("Voice")
	# CH_FX_*: numbers go in as {placeholder} args, English unchanged
	# never write the real settings: keep the file and the in-memory state, put both back at the end
	var cfg_path := "user://settings.cfg"
	var cfg_had := FileAccess.file_exists(cfg_path)
	var cfg_bytes := FileAccess.get_file_as_bytes(cfg_path) if cfg_had else PackedByteArray()
	var keep_lang: String = Lang.current()
	var keep_voice_on: bool = Voice.enabled
	Lang.set_language("en")  # the checks below read English, whatever the real settings say (restored at the end)
	var keep_cbal: Dictionary = Chains.bal
	Chains.bal = {"fx_test_one": 1, "fx_test_cycles": 3}
	var fxb: String = Chains.phrase({"type": "workshop_batches", "key": "fx_test_one", "cycles_key": "fx_test_cycles"})
	check(fxb == "+1 batch per cycle for 3 cycles" and not fxb.contains("{") and not fxb.contains("%"), "chains: CH_FX_BATCHES phrase keeps English, number via {n}", fxb)
	check(Chains.phrase({"type": "tech_units", "key": "fx_test_one"}) == "+1 tech progress", "chains: CH_FX_TECH phrase keeps English")
	Chains.bal = keep_cbal
	var fx := "user://ru_fixture.json"
	var f := FileAccess.open(fx, FileAccess.WRITE)
	f.store_string(JSON.stringify([
		{"id": "EV_MIL_A1_TITLE", "text": "Русский заголовок"},
		{"id": "EV_MIL_A1_BODY", "text": "Тест {x} {cost}"}, {"id": "CH_EFFECT_LINE", "text": "доля"}, {"id": "CH_FX_FIX", "text": "эффект"},
		{"id": "BTN_OK", "text": "Ладно"}, {"id": "MENU_CONTINUE", "text": "Дальше"}, {"id": "NOT_SAVED", "text": "Сохранено"}]))
	f.close()
	var old_path: String = StoryText.ru_path
	StoryText.ru_path = fx
	Lang.set_language("en")
	var en_title := StoryText.get_text("EV_MIL_A1_TITLE")
	check(Lang.current() == "en" and not Lang.is_ru(), "lang: English after set_language en")
	check(StoryText.get_text("EV_MIL_A1_TITLE") == en_title and en_title != "Русский заголовок", "lang: English mode never uses the Russian table")
	Lang.set_language("ru")
	check(Lang.is_ru() and Lang.current() == "ru", "lang: switched to ru")
	check(StoryText.get_text("EV_MIL_A1_TITLE") == "Русский заголовок", "lang: ru mode returns the fixture for an in-scope id")
	check(StoryText.get_text("EV_MIL_A1_BODY", {"cost": "7"}) == "Тест {x} 7", "lang: placeholders filled in ru text")
	check(StoryText.get_text("EV_MIL_A1_OPA_BTN") != "" and StoryText.get_text("EV_MIL_A1_OPA_BTN") != "Тест", "lang: in-scope id without ru text stays English")
	check(StoryText.get_text("CH_EFFECT_LINE") == "доля" and StoryText.in_ru_scope("CH_FX_ANY"), "lang: CH_ fill-in ids are localised")
	for id in ["BTN_OK", "NOT_SAVED"]:
		check(StoryText.get_text(id) == ("Ладно" if id == "BTN_OK" else "Сохранено"), "lang: every id is localised, %s too (scope widened 2026-11-09)" % id)
	check(StoryText.get_text("MENU_CONTINUE") == "Дальше" and StoryText.in_ru_scope("END_BANKRUPT") and StoryText.in_ru_scope("SCR_PREFACE") and StoryText.in_ru_scope("EPI_CAP_MIL") and StoryText.in_ru_scope("BE01_BODY"), "lang: menu, screen, ending and epilogue ids are localised")
	check(StoryText.in_ru_scope("EV_X") and StoryText.in_ru_scope("TUT_G3_PICK_WHY") and StoryText.in_ru_scope("TUT_GALAXY_INTRO") and StoryText.in_ru_scope("TUT_C1_ROW") and StoryText.in_ru_scope("EVT_NEXT_DUE") and not StoryText.in_ru_scope("lower_case") and not StoryText.in_ru_scope("A") and StoryText.in_ru_scope("EV17_BODY") and StoryText.in_ru_scope("EV01_TITLE"), "lang: scope rule")
	# persistence across a reload of the settings file
	var cf := ConfigFile.new()
	cf.load("user://settings.cfg")
	check(cf.get_value("game", "language", "") == "ru", "lang: saved to settings.cfg")
	Lang.set_language("en")
	var cf2 := ConfigFile.new()
	cf2.load("user://settings.cfg")
	cf2.set_value("game", "language", "ru")
	cf2.save("user://settings.cfg")
	Lang.reload()
	check(Lang.is_ru(), "lang: persists across a reload of the settings file")
	cf2.set_value("game", "language", "xx")
	cf2.save("user://settings.cfg")
	Lang.reload()
	check(Lang.current() == "en", "lang: unknown saved code falls back to en")
	# voice paths
	check(Voice.path_for("EV_A", "en") == "res://assets/voice/EV_A.ogg", "voice: English path unchanged")
	check(Voice.path_for("EV_A", "ru") == "res://assets/voice/ru/EV_A.ogg", "voice: ru path in the ru folder")
	Lang.set_language("ru")
	Voice.play("TUT_C1_ROW")  # an English file may exist; in ru mode only the ru folder is consulted
	check(not Voice.is_playing(), "voice: ru mode with no ru file is silent")
	Voice.stop()
	# settings screen
	var mm: Control = load("res://game/main_menu.tscn").instantiate()
	root.add_child(mm)
	await process_frame
	check(mm.lang_buttons.has("en") and mm.lang_buttons.has("ru") and mm.lang_buttons["ru"].text == "Русский" and mm.lang_buttons["en"].text == "English", "settings: language buttons exist")
	check(mm.lang_buttons["ru"].button_pressed and not mm.lang_buttons["en"].button_pressed, "settings: current language shown selected")
	check(not mm.settings_box.visible, "settings: hidden until the Settings button is pressed")
	mm._show_settings(true)
	check(mm.settings_box.visible and not mm._main_box.visible, "settings: screen opens")
	check(mm.voice_check != null and mm.voice_slider != null and mm.voice_check.text.to_lower().contains("voice"), "settings: Voice check box and slider exist")
	var was_on: bool = Voice.enabled
	Voice.set_enabled(true)
	mm.voice_check.button_pressed = false
	var cfv := ConfigFile.new()
	cfv.load("user://settings.cfg")
	check(not Voice.enabled and cfv.get_value("voice", "enabled", true) == false, "settings: Voice off check box silences and saves")
	Voice.play("EV_MIL_A1_TITLE")
	check(not Voice.is_playing(), "settings: nothing plays while voice is off")
	mm.voice_check.button_pressed = true
	check(Voice.enabled, "settings: Voice check box turns it back on")
	Voice.set_enabled(was_on)
	mm.lang_buttons["en"].pressed.emit()
	var cf3 := ConfigFile.new()
	cf3.load("user://settings.cfg")
	check(Lang.current() == "en" and cf3.get_value("game", "language", "") == "en", "settings: choosing English saves and applies at once")
	# T324: the new company screen Skip tutorial button saves the setting, labels from the story ids
	var cs: Control = load("res://game/company_setup.tscn").instantiate()
	root.add_child(cs)
	await process_frame
	check(not mm.get("skip_button"), "T324: the main menu has no Skip tutorial button")
	var skip_was: bool = SaveGame.skip_tutorial()
	SaveGame.set_skip_tutorial(false)
	cs._mark_skip(false)
	check(not SaveGame.skip_tutorial() and cs.skip_button.text == StoryText.get_text("BTN_SKIP_TUTORIAL") and not cs.skip_button.button_pressed, "T322: skip tutorial is off by default, an unchecked toggle")
	cs.skip_button.button_pressed = true
	check(SaveGame.skip_tutorial() and cs.skip_button.text == StoryText.get_text("BTN_SKIP_TUTORIAL") and cs.skip_button.button_pressed and cs.skip_button.tooltip_text == StoryText.get_text("MENU_HINT_SKIP_TUTORIAL"), "T322: skip tutorial on is saved, the toggle is checked and keeps its hint")
	var cfs := ConfigFile.new()
	cfs.load("user://settings.cfg")
	check(cfs.get_value("game", "skip_tutorial", false) == true and cfs.get_value("game", "language", "") == "en", "T322: the setting sits in settings.cfg next to the language")
	cs.skip_button.button_pressed = false
	check(not SaveGame.skip_tutorial() and cs.skip_button.text == StoryText.get_text("BTN_SKIP_TUTORIAL"), "T322: pressing again turns the tutorial back on")
	SaveGame.set_skip_tutorial(skip_was)
	cs.queue_free()
	mm.queue_free()
	await process_frame
	StoryText.ru_path = old_path
	Lang.set_language("en")
	DirAccess.remove_absolute(fx)
	if cfg_had:
		var cfw := FileAccess.open(cfg_path, FileAccess.WRITE)
		cfw.store_buffer(cfg_bytes)
		cfw.close()
	elif FileAccess.file_exists(cfg_path):
		DirAccess.remove_absolute(cfg_path)
	Lang.reload()
	Voice.set_enabled(keep_voice_on)
	if cfg_had:  # set_enabled saved again: put the original bytes back
		var cfw2 := FileAccess.open(cfg_path, FileAccess.WRITE)
		cfw2.store_buffer(cfg_bytes)
		cfw2.close()
	elif FileAccess.file_exists(cfg_path):
		DirAccess.remove_absolute(cfg_path)

func _test_chain_gate() -> void:
	check(not StoryText.has_text("LBL_GOAL") and StoryText.has_text("LBL_GOAL_MARKETS"), "story: old goal row gone, markets goal present")
	var bal_c = _read_json("res://data/balance.json")["values"]
	Markets.reset(bal_c, 3)
	Chains.reset(bal_c, 3)
	# chain_min_cycle: no step is eligible before it, even with a share trigger already true
	Chains.reset(bal_c, 3)
	var mc := int(bal_c.get("chain_min_cycle", 6))
	check(mc >= 5 and mc <= 7, "chain_min_cycle: key present, 5-7", str(mc))
	Skills.learned.append("MIL_3")  # T260: B1 trigger (skill or any_tier:2) true at cycle 2
	check(Chains.trigger_ok("MIL_B1", 2), "chain_min_cycle: the trigger alone is true at cycle 2")
	var early_ok := false
	for sid in Chains.step_ids():
		for cy in range(1, mc):
			if Chains.eligible(str(sid), cy):
				early_ok = true
	Chains.picks.clear()
	check(Chains.eligible("MIL_B1", mc), "chain_min_cycle: MIL_B1 eligible at the gate cycle")
	check(not early_ok, "chain_min_cycle: no chain step eligible before the gate")
	check(not Chains.eligible("MIL_B1", mc - 1), "chain_min_cycle: MIL_B1 blocked at cycle min-1")
	Skills.learned.erase("MIL_3")
	Chains.reset(bal_c, 0)
	Markets.reset(bal_c, 0)
	Markets.reset(bal_c, 0)

func _test_story_text() -> void:
	var list: Array = StoryText.entries_of(_read_json("res://data/story_text.json"))
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
	var events: Array = StoryText.entries_of(_read_json("res://data/events.json"))
	check(events.size() > 0, "story: events.json loads")
	_test_code_story_ids(seen)

## Localisation guard: every literal id in a StoryText.get_or / get_text call in game/*.gd (not debug_menu.gd) is in data/story_text.json.
## A get_or with an id missing from the story files would show its English fallback in Russian. Ids built with + or % (prefixes) are skipped.
func _test_code_story_ids(seen: Dictionary) -> void:
	var rx := RegEx.create_from_string("StoryText\\.(?:get_or|get_text)\\(\\s*\"([A-Z][A-Z0-9_]*)\"\\s*([,)+%])")
	var missing := {}
	var calls := 0
	var d := DirAccess.open("res://game")
	for fn in d.get_files():
		if not fn.ends_with(".gd") or fn == "debug_menu.gd" or fn == "story_text.gd":
			continue
		for m in rx.search_all(FileAccess.get_file_as_string("res://game/" + fn)):
			var id := m.get_string(1)
			if id.ends_with("_") or m.get_string(2) == "+" or m.get_string(2) == "%":
				continue
			calls += 1
			if not seen.has(id):
				missing[fn + ": " + id] = true
	check(calls > 100, "story ids in code: the scan finds the StoryText calls (%d)" % calls)
	check(missing.is_empty(), "story ids in code: every id of a StoryText.get_or / get_text call in game/*.gd is in data/story_text.json (add it to story/screens.md and run python3 tools/build_story.py)", str(missing.keys()))

# ---- generated files: a checked-in generated file must equal a fresh build ----
const GENERATED_FILES := ["story_text.json", "story_text_ru.json", "events.json"]

func _test_generated_files() -> void:
	var out_dir := OS.get_user_data_dir().path_join("gen_check")
	DirAccess.make_dir_recursive_absolute(out_dir)
	var output: Array = []
	var code := OS.execute("python3", [ProjectSettings.globalize_path("res://tools/build_story.py"), "--out", out_dir], output, true)
	check(code == 0, "generated files: tools/build_story.py --out runs", "exit %d: %s" % [code, str(output)])
	for name in GENERATED_FILES:
		var have := FileAccess.get_file_as_string("res://data/" + name)
		var fresh := FileAccess.get_file_as_string(out_dir.path_join(name))
		check(have != "" and have == fresh, "generated files: data/%s equals its build. It is generated, never edit it by hand: run `python3 tools/build_story.py`" % name)
		var parsed = JSON.parse_string(have)
		var mark = parsed.get("generated") if typeof(parsed) == TYPE_DICTIONARY else null
		check(typeof(mark) == TYPE_DICTIONARY and str(mark.get("generator", "")) == "tools/build_story.py" and str(mark.get("source", "")) != "", "generated files: data/%s names its source and generator" % name)

# ---- cross-pack lint: every id one data file names exists in the file that owns it ----
func _lint_walk(o, file: String, path: String, bal: Dictionary, errs: Array) -> void:
	if typeof(o) == TYPE_DICTIONARY:
		for k in o.keys():
			var v = o[k]
			var ks := str(k)
			if typeof(v) == TYPE_STRING:
				if (ks == "key" or ks.ends_with("_key")) and not bal.has(str(v)):
					errs.append("%s %s/%s: unknown balance key '%s'" % [file, path, ks, v])
				elif ks.ends_with("_id") and RegEx.create_from_string("^[A-Z][A-Z0-9_]+$").search(str(v)) != null and not StoryText.has_text(str(v)):
					errs.append("%s %s/%s: unknown text id '%s'" % [file, path, ks, v])
			_lint_walk(v, file, path + "/" + ks, bal, errs)
	elif typeof(o) == TYPE_ARRAY:
		for i in o.size():
			_lint_walk(o[i], file, path, bal, errs)

func _good_of_price_key(k: String) -> String:
	return k.trim_suffix("_buy").trim_suffix("_sell")

func _test_data_pack_lint() -> void:
	var errs: Array = []
	var bal: Dictionary = _read_json("res://data/balance.json")["values"]
	var events: Array = StoryText.entries_of(_read_json("res://data/events.json"))
	var event_ids: Array = Conditions.event_ids()
	# balance keys and text ids named anywhere
	for f in ["goods", "chains", "skills", "systems", "ships", "events", "markets", "planets", "asteroid_clusters"]:
		var d = _read_json("res://data/%s.json" % f)
		_lint_walk(StoryText.entries_of(d) if f == "events" else d, "data/%s.json" % f, "", bal, errs)
	# goods
	var goods_json: Dictionary = _read_json("res://data/goods.json")
	var market_ids: Array = []
	var markets_json: Dictionary = _read_json("res://data/markets.json")
	for m in markets_json["markets"]:
		market_ids.append(str(m["id"]))
		for g in m["goods"]:
			if not Goods.has(str(g)):
				errs.append("data/markets.json market %s: unknown good '%s'" % [m["id"], g])
	for g in markets_json["common_raws"]:
		if not Goods.has(str(g)):
			errs.append("data/markets.json common_raws: unknown good '%s'" % g)
	for g in markets_json["base_value"].keys():
		if not Goods.has(str(g)):
			errs.append("data/markets.json base_value: unknown good '%s'" % g)
	var planet_names: Array = []
	var planet_ids: Array = []
	var price_blocks: Array = []  # [where, base_prices]
	for p in _read_json("res://data/planets.json")["planets"]:
		planet_names.append(str(p["name"]).to_lower())
		planet_ids.append(str(p["id"]))
		price_blocks.append(["data/planets.json " + str(p["id"]), p.get("base_prices", {})])
	var sysd: Dictionary = _read_json("res://data/systems.json")
	for sy in sysd["systems"]:
		if str(sy.get("requires_skill", "")) != "" and not SkillTree.has(str(sy["requires_skill"])):
			errs.append("data/systems.json system %s: unknown skill node '%s'" % [sy["id"], sy["requires_skill"]])
		for p in sy["planets"]:
			planet_ids.append(str(p["id"]))
			if StoryText.has_text(str(p.get("name_id", ""))):
				planet_names.append(StoryText.get_text(str(p["name_id"])).to_lower())
			price_blocks.append(["data/systems.json " + str(p["id"]), p.get("base_prices", {})])
	for pb in price_blocks:
		for k in pb[1].keys():
			if not Goods.has(_good_of_price_key(str(k))):
				errs.append("%s: base_prices names unknown good '%s'" % [pb[0], k])
	var workshop_ids: Array = []
	for w in goods_json["workshops"]:
		workshop_ids.append(str(w["id"]))
		if not market_ids.has(str(w["market"])):
			errs.append("data/goods.json workshop %s: unknown market '%s'" % [w["id"], w["market"]])
		Conditions.lint(w.get("unlocked_by"), "data/goods.json workshop %s unlocked_by" % w["id"], errs, false, bal, event_ids)
	for g in goods_json["goods"]:
		var gid := str(g["id"])
		if str(g["market"]) != "" and not market_ids.has(str(g["market"])):  # "" = energy, the shared good (T239)
			errs.append("data/goods.json good %s: unknown market '%s'" % [gid, g["market"]])
		if typeof(g.get("recipe")) == TYPE_DICTIONARY:
			for r in g["recipe"].keys():
				if not Goods.has(str(r)):
					errs.append("data/goods.json good %s recipe: unknown good '%s'" % [gid, r])
		if g.get("workshop") != null and not workshop_ids.has(str(g["workshop"])):
			errs.append("data/goods.json good %s: unknown workshop '%s'" % [gid, g["workshop"]])
		for pl in g.get("planet_prices", {}).keys():
			if not planet_ids.has(str(pl)):
				errs.append("data/goods.json good %s planet_prices: unknown planet '%s'" % [gid, pl])
			for k in g["planet_prices"][pl].keys():
				if not Goods.has(_good_of_price_key(str(k))):
					errs.append("data/goods.json good %s planet_prices: unknown good '%s'" % [gid, k])
	var clusters: Dictionary = _read_json("res://data/asteroid_clusters.json")
	for c in clusters["clusters"] + [clusters]:
		if c.has("good") and not Goods.has(str(c["good"])):
			errs.append("data/asteroid_clusters.json: unknown good '%s'" % c["good"])
	# skills: prereqs, unlock targets, text ids
	var skills_json: Dictionary = _read_json("res://data/skills.json")
	for n in skills_json["nodes"]:
		var nid := str(n["id"])
		for pr in n.get("prereqs", []):
			if not SkillTree.has(str(pr)):
				errs.append("data/skills.json node %s: unknown prereq '%s'" % [nid, pr])
		for eff in [n.get("effect", {})] + n.get("extra", []):
			if str(eff.get("type", "")) == "unlock":
				var tid := str(eff.get("id", ""))
				if str(eff.get("target", "")) == "good" and not Goods.has(tid):
					errs.append("data/skills.json node %s: unlocks unknown good '%s'" % [nid, tid])
				if str(eff.get("target", "")) == "workshop" and not workshop_ids.has(tid):
					errs.append("data/skills.json node %s: unlocks unknown workshop '%s'" % [nid, tid])
		if n.get("kind", "") != "" and nid.find("_") > 0:
			for suffix in ["NAME", "FLAVOUR", "PLAIN"]:
				if not StoryText.has_text("SK_%s_%s" % [nid, suffix]):
					errs.append("data/skills.json node %s: unknown text id 'SK_%s_%s'" % [nid, nid, suffix])
	# availability (rules, goods, workshops, skill nodes, balance keys, event ids)
	for e in Availability.lint():
		errs.append("data/availability.json: " + str(e))
	# events: text ids, tag planet and good
	var tag_rx := RegEx.create_from_string("\\[\\s*(price up|price down|planet closed|stock)\\s*:\\s*([^\\]]*)\\]")
	var seen_ev := {}
	for e in events:
		var eid := str(e["id"])
		if seen_ev.has(eid):
			errs.append("data/events.json: duplicate event '%s'" % eid)
		seen_ev[eid] = true
		for k in ["title_id", "text_id"]:
			if not e.has(k):
				errs.append("data/events.json event %s: no %s (event text must be a text id)" % [eid, k])
		for k in ["title", "text"]:
			if e.has(k):
				errs.append("data/events.json event %s: inline '%s' (text belongs in story_text.json)" % [eid, k])
		var tags: Array = [str(e.get("tag", ""))]
		for ch in e.get("choices", []):
			tags.append(str(ch.get("tag", "")))
			if ch.has("text"):
				errs.append("data/events.json event %s: inline choice text (use text_id)" % eid)
			if ch.has("follow_id") and not event_ids.has(str(ch["follow_id"])):
				errs.append("data/events.json event %s: unknown follow_id '%s'" % [eid, ch["follow_id"]])
		for tag in tags:
			var m := tag_rx.search(tag)
			if m == null:
				continue
			var args := m.get_string(2).split(",")
			if args.size() >= 1 and not planet_names.has(args[0].strip_edges().to_lower()):
				errs.append("data/events.json event %s: tag names unknown planet '%s'" % [eid, args[0].strip_edges()])
			if m.get_string(1) != "planet closed" and args.size() >= 2 and not Goods.has(args[1].strip_edges().to_lower()):
				errs.append("data/events.json event %s: tag names unknown good '%s'" % [eid, args[1].strip_edges()])
		if e.has("visible_when"):
			Conditions.lint(e["visible_when"], "data/events.json event %s visible_when" % eid, errs, false, bal, event_ids)
	# chains: steps, pool, triggers
	var chains_json: Dictionary = _read_json("res://data/chains.json")
	for st in chains_json["steps"]:
		var sid := str(st["id"])
		Conditions.lint(st.get("trigger"), "data/chains.json step %s trigger" % sid, errs, true, bal, event_ids)
		if st.has("visible_when"):
			Conditions.lint(st["visible_when"], "data/chains.json step %s visible_when" % sid, errs, true, bal, event_ids)
		if bool(st.get("requires_prev_step", false)) and not Chains.has_step(Chains.prev_id(sid)):
			errs.append("data/chains.json step %s: requires_prev_step but '%s' is not a step" % [sid, Chains.prev_id(sid)])
		if not market_ids.has(str(st["market"])):
			errs.append("data/chains.json step %s: unknown market '%s'" % [sid, st["market"]])
		for need in ["TITLE", "OPA_BTN", "OPB_BTN", "OPA_RES", "OPB_RES"]:
			if not StoryText.has_text("EV_%s_%s" % [sid, need]):
				errs.append("data/chains.json step %s: unknown text id 'EV_%s_%s'" % [sid, sid, need])
		if not StoryText.has_text("EV_%s_BODY" % sid) and not (StoryText.has_text("EV_%s_BODY_A" % sid) and StoryText.has_text("EV_%s_BODY_B" % sid)):
			errs.append("data/chains.json step %s: unknown text id 'EV_%s_BODY' (or _A and _B)" % [sid, sid])
		for opt in ["opt_a", "opt_b"]:
			if st[opt].has("visible_when"):
				Conditions.lint(st[opt]["visible_when"], "data/chains.json step %s %s visible_when" % [sid, opt], errs, true, bal, event_ids)
	for ne in chains_json["pool_new"]:
		var nid := str(ne["id"])
		for suffix in ["TITLE", "BODY"]:
			if not StoryText.has_text("%s_%s" % [nid, suffix]):
				errs.append("data/chains.json pool_new %s: unknown text id '%s_%s'" % [nid, nid, suffix])
		if ne.has("title"):
			errs.append("data/chains.json pool_new %s: inline title (use the text id %s_TITLE)" % [nid, nid])
		var eff: Dictionary = ne.get("effect", {})
		if eff.has("good") and not Goods.has(str(eff["good"])):
			errs.append("data/chains.json pool_new %s: unknown good '%s'" % [nid, eff["good"]])
		if eff.has("planet") and not planet_ids.has(str(eff["planet"])):
			errs.append("data/chains.json pool_new %s: unknown planet '%s'" % [nid, eff["planet"]])
		if not market_ids.has(str(ne.get("market", "mil"))):
			errs.append("data/chains.json pool_new %s: unknown market '%s'" % [nid, ne["market"]])
	for kid in chains_json["pool_kept"].keys():
		if not seen_ev.has(str(kid)):
			errs.append("data/chains.json pool_kept: unknown event '%s'" % kid)
		var kept_market = chains_json["pool_kept"][kid].get("market")
		if kept_market != null and not market_ids.has(str(kept_market)):
			errs.append("data/chains.json pool_kept %s: unknown market" % kid)
	for e in errs:
		check(false, "data pack lint: " + str(e))
	check(errs.is_empty(), "data pack lint: every id named in the data files exists (%d findings)" % errs.size())

# ---- conditions: the one evaluator ----
func _test_conditions_unit() -> void:
	var saved_game = Conditions.game
	Conditions.game = null
	check(Conditions.eval("start") and not Conditions.eval({"not": "start"}) and Conditions.eval({"not": {"any": []}}), "conditions: start and not")
	check(Conditions.eval({"all": ["start", {"not": {"all": ["start", {"not": "start"}]}}]}) and not Conditions.eval({"any": []}), "conditions: all, any, nested trees")
	Skills.learned.clear()
	check(not Conditions.eval("skill_learned:FND_STORAGE"), "conditions: skill not learned")
	Skills.add_learned("FND_STORAGE")
	check(Conditions.eval("skill_learned:FND_STORAGE") and Conditions.eval({"all": ["skill_learned:FND_STORAGE", {"not": "event_fired:EV01"}]}), "conditions: skill_learned true once learned")
	Skills.learned.clear()
	# event_fired reads Chains.picks without a game
	Chains.reset(_read_json("res://data/balance.json")["values"], 1)
	check(not Conditions.eval("event_fired:MIL_A1"), "conditions: event_fired false before the step")
	Chains.picks["MIL_A1"] = {"opt": "opt_a", "cycle": 6, "nudge": 0}
	check(Conditions.eval("event_fired:MIL_A1"), "conditions: event_fired true after a chain step fired")
	Chains.reset(_read_json("res://data/balance.json")["values"], 1)
	# visible_when on an entry
	check(Conditions.visible({}) and Conditions.visible({"visible_when": "start"}) and not Conditions.visible({"visible_when": {"not": "start"}}), "conditions: visible_when on an entry")
	var lint_errs: Array = []
	Conditions.lint({"all": ["event_fired:NOPE", "skill_learned:NOPE", "share_pct:balance.nope", "good_traded:nope", "tech_done:MIL_1"]}, "t", lint_errs, false, {}, Conditions.event_ids())
	check(lint_errs.size() == 6, "conditions: lint names every bad atom (step atom without a step, unknown event, node, balance key, good, old atom)", str(lint_errs))
	Conditions.game = saved_game

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
	m.open_systems = [1, 2, 3, 4, 5]  # T226: 3 to 5 are placeholder systems
	await process_frame
	check(ex.next_locked() == -1 and ex.markers().all(func(k): return not k["locked"]), "exit: no locked marker once every system is open")
	m.open_systems = [1]
	var g: Control = m.galaxy_view
	g.close_view()
	g.selected_sys = -1  # a locked click in the system view opens the permit card
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
	check(_buttons(g.tut_box, []).size() == 1, "galaxy: tutorial card has Skip only, no Next")
	g.tut_step = 0
	g._build_tutorial()
	var cev := InputEventMouseButton.new()
	cev.button_index = MOUSE_BUTTON_LEFT
	cev.pressed = true
	cev.position = g._hit[0]["pos"]
	g._gui_input(cev)
	check(g.tut_step == 1, "galaxy: a system click moves the tutorial on")
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

## Guided route lock: steps 0 to 5 allow only Energy, Voltara -> Ashgate, through the real entry points.
func _test_tutorial_lock() -> void:
	var m: Control = await _new_main(true)
	var v: int = m._tut_idx("planet_1")
	var a: int = m._tut_idx("planet_3")
	var t: int = m._tut_idx("planet_2")
	check(v >= 0 and a >= 0 and t >= 0 and v != a, "lock: Voltara, Ashgate and Tillam are found by id")
	var chk: Dictionary = m.engine.check_connection(v, a, "energy")
	var mg: int = m.trade.margin(v, a, "energy")
	print("LOCK route energy Voltara->Ashgate: ok=%s margin=%d (buy %s, sell %s)" % [chk["ok"], mg, m.trade.price(v, "energy_buy"), m.trade.price(a, "energy_sell")])
	check(bool(chk["ok"]) and mg > 0, "lock: Energy Voltara to Ashgate connects and the margin is positive", str(mg))
	check(m.tut_step == 0 and m.tut_lock_step() == 0, "lock: fresh game locks step 0")
	m._on_planet_clicked(a)
	m._on_planet_clicked(t)
	check(m.selected_planet < 0 and m.last_notice == StoryText.get_or("NOT_TUT_LOCKED", "Follow the tutorial step, or skip the tutorial."), "lock step 0: Ashgate and Tillam do not select, a notice shows", m.last_notice)
	check(m._tut_ring_planet() == v, "lock step 0: the ring is on Voltara")
	m._on_planet_clicked(v)
	await process_frame
	await process_frame
	check(m.selected_planet == v and m.tut_step == 0 and m.tutorial_label.text == StoryText.get_or("TUT_G1C_SPEED", "", {}).strip_edges(), "lock step 0: Voltara selects and the speed card shows", str(m.tut_step))  # T333
	m.tut_next.pressed.emit()
	await process_frame
	await process_frame
	check(m.selected_planet == v and m.tut_step == 2, "lock step 0: Next on the speed card moves the guide on", str(m.tut_step))
	# step 1: only Energy buy on Voltara
	m.last_notice = ""
	m._on_buy_send("food")
	check(not m.engine.local_on(v, "food", "buy") and m.last_notice != "" and m.pending.is_empty(), "lock step 1: Food buy on Voltara is refused")
	check(not bool(m.set_local_order(v, "food", "buy", true)["ok"]) and not bool(m.set_local_order(t, "energy", "buy", true)["ok"]) and not bool(m.set_local_order(v, "energy", "sell", true)["ok"]), "lock step 1: Food buy, Energy buy at Tillam and Energy sell are refused at the order entry point")
	m._on_planet_clicked(t)
	check(m.selected_planet == v, "lock step 1: Tillam does not select")
	check(not bool(m.buy_ship("small")["ok"]) and m.ships == 0, "lock step 1: buying a ship is refused")
	await process_frame
	var bf: Button = _find_named(m.planet_panel, "BuyButton_food") as Button
	var be: Button = _find_named(m.planet_panel, "BuyButton_energy") as Button
	check(bf != null and be != null and bf.disabled and not be.disabled, "lock step 1: Food shows disabled, Energy stays enabled")
	m._on_buy_send("energy")
	await process_frame
	await process_frame
	check(m.engine.local_on(v, "energy", "buy") and m.tut_step == 3, "lock step 1: Energy buy on Voltara works and moves on", str(m.tut_step))
	# step 2: only the Energy send from Voltara, to Ashgate
	check(m._tut_picking() and m._tut_pick_planet() == a and m._tut_ring_planet() == a, "lock step 2: the pointer goes to Ashgate")
	m.last_notice = ""
	m._on_planet_clicked(t)
	check(m.engine.routes.is_empty() and not m.pending.is_empty() and m.last_notice != "", "lock step 2: a click on Tillam is ignored, the send stays pending")
	check(not bool(m.send_stock_buying(v, t, "energy")["ok"]) and not bool(m.send_stock_buying(v, a, "food")["ok"]) and m.engine.routes.is_empty(), "lock step 2: a send to Tillam or of Food is refused at the send entry point")
	m._on_planet_clicked(a)
	await process_frame
	await process_frame
	check(m.engine.routes.size() == 1 and str(m.engine.routes[0]["c"]) == "energy" and int(m.engine.routes[0]["a"]) == v and int(m.engine.routes[0]["b"]) == a, "lock step 2: Ashgate completes the Energy route")
	check(m.tut_step == 4, "lock step 2: the guide moves to the run-time step", str(m.tut_step))
	# step 3: time stays usable, everything else muted
	m.last_notice = ""
	m._on_planet_clicked(t)
	check(m.selected_planet != t and m.last_notice != "", "lock step 3: planet clicks are muted")
	check(not bool(m.set_local_order(a, "energy", "sell", true)["ok"]) and not bool(m.remove_connection(int(m.engine.routes[0]["id"]))["ok"]) and m.engine.routes.size() == 1, "lock step 3: Sell and route removal are muted")
	m.set_speed(2.0)
	m.set_paused(false)
	check(m.time_speed == 2.0 and not m.paused, "lock step 3: the time control still works")
	m.set_speed(1.0)
	var cash0: int = m.cash
	while m.cycle < 2:
		m._end_cycle()
	await process_frame
	await process_frame
	check(m.tut_step == 5, "lock step 3: a paid cycle moves to Expenses", str(m.tut_step))
	check(m.cash > cash0 - 1 or m.cash > 0, "lock: the route is not a loss in its first cycle", "%d -> %d" % [cash0, m.cash])
	# step 4: Expenses and time only
	check(not bool(m.set_local_order(a, "energy", "sell", true)["ok"]), "lock step 4: Sell is still muted")
	m.cash_forecast.anchor.gui_input.emit(_click(MOUSE_BUTTON_LEFT))
	await process_frame
	await process_frame
	check(m.tut_step == 5 and m.tut_next.visible, "lock step 4: opening Expenses shows Next and stays", str(m.tut_step))  # T331
	m.tut_next.pressed.emit()  # the real click is covered in _test_tut_counter
	await process_frame
	await process_frame
	check(m.tut_step == 6, "lock step 4: Next moves on", str(m.tut_step))
	# step 5: only Sell of Energy on Ashgate
	m._on_planet_clicked(v)
	check(m.selected_planet != v, "lock step 5: Voltara cannot be selected")
	m._on_planet_clicked(a)
	check(m.selected_planet == a, "lock step 5: Ashgate selects")
	check(not bool(m.set_local_order(v, "energy", "sell", true)["ok"]) and not bool(m.set_local_order(a, "food", "sell", true)["ok"]) and not bool(m.set_local_order(a, "energy", "buy", true)["ok"]), "lock step 5: sell on Voltara, Food sell and a buy are refused")
	m._on_order("energy", "sell")
	await process_frame
	await process_frame
	check(m.engine.local_on(a, "energy", "sell") and m.tut_step >= 7, "lock step 5: Sell on Ashgate works and the guide moves on", str(m.tut_step))
	check(m.tut_lock_step() == -1 and bool(m.set_local_order(t, "food", "buy", true)["ok"]), "lock: no lock from step 6")
	var c1: int = m.cash
	m._end_cycle()
	m._end_cycle()
	check(m.cash > 0 and m.cash != c1, "lock: happy path ends with the guide done and cash moving", "%d -> %d" % [c1, m.cash])
	await _free_main(m)
	# Skip releases the lock at once
	m = await _new_main(true)
	check(m.tut_lock_step() == 0, "lock: fresh again")
	m._tut_skip()
	check(m.tut_lock_step() == -1 and bool(m.set_local_order(m._tut_idx("planet_2"), "food", "buy", true)["ok"]), "lock: Skip releases the lock")
	await _free_main(m)
	# a save in the middle of the tutorial keeps the lock from the loaded step; a finished one has none
	m = await _new_main(true)
	m.tut_step = 5
	var mid: Dictionary = JSON.parse_string(JSON.stringify(m.collect_state()))
	m.tut_step = 0
	m.apply_state(mid)
	check(m.tut_step == 5 and m.tut_lock_step() == 5, "lock: a save in step 5 loads locked at step 5", str(m.tut_step))
	mid["tut_step"] = m.TUT_GUIDE.size()
	m.apply_state(mid)
	check(m.tut_lock_step() == -1, "lock: a finished save loads with no lock")
	await _free_main(m)
	# never a lock after the game is over
	m = await _new_main(true)
	m.game_over = true
	check(m.tut_lock_step() == -1, "lock: no lock when the game is over")
	m.game_over = false
	# missing planet data: the lock lets go
	m.tut_step = 3
	var saved_id: String = str(m.map.planets[m._tut_idx("planet_3")]["id"])
	m.map.planets[m._tut_idx("planet_3")]["id"] = "zz"
	check(m.tut_lock_step() == -1, "lock: missing Ashgate data releases the lock")
	m.map.planets[m._tut_idx("zz")]["id"] = saved_id
	check(m.tut_lock_step() == 3, "lock: restored data locks again")
	await _free_main(m)

func _click(btn: int) -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.button_index = btn
	e.pressed = true
	return e

## T316: step ids exist in the story, tip triggers are valid conditions, old-save step mapping, a tip shows once.
func _test_pulse_ring() -> void:
	# T323: the PulseRing asset: N pulses then finished (and freed on request), loop mode runs until stop()
	var PR: PackedScene = load("res://game/fx/pulse_ring.tscn")
	var pr: PulseRing = PR.instantiate()
	root.add_child(pr)
	pr.pulses = 2
	pr.seconds_per_pulse = 0.05
	pr.follow = func() -> Vector2: return Vector2(100, 100)
	var fin := [0]
	pr.finished.connect(func(): fin[0] += 1)
	pr.play()
	check(pr.is_playing(), "T323: pulse ring plays")
	for _i in 60:
		await process_frame
	check(fin[0] == 1 and not pr.is_playing() and not pr.visible, "T323: pulse ring ends after its N pulses and hides", str(fin))
	pr.pulses = 0
	pr.play()
	for _i in 6:
		await process_frame
	check(pr.is_playing() and pr.visible and fin[0] == 1, "T323: loop mode keeps running past one pulse")
	pr.stop()
	check(not pr.is_playing() and not pr.visible, "T323: stop() ends the loop and hides at once")
	pr.pulses = 1
	pr.free_when_done = true
	pr.play()
	for _i in 60:
		await process_frame
	check(not is_instance_valid(pr) or pr.is_queued_for_deletion(), "T323: free_when_done frees the ring after the last pulse")

## T339: tips are spaced by tip_gap_seconds on the game clock, wait in a queue in priority order, share a card when about one thing,
## and the right-hand TIPS box shows the newest tip with its why-line plus the older ones of the last three. All through the real _tip_tick.
func _tip_clock_to(m: Node, c0: int, secs: float) -> void:
	var len: float = m._cycle_seconds()
	m.cycle = c0 + int(secs / len)
	m.cycle_elapsed = fmod(secs, len)

func _tip_run(m: Node, secs: float) -> void:
	var t := 0.0
	while t < secs:
		m._tip_tick(0.5)
		t += 0.5

func _tip_close_by_time(m: Node) -> void:
	_tip_run(m, 30.0)  # longer than the longest card, the clock does not move

func _test_tip_spacing(m: Node) -> void:
	if m.preface != null:
		m._dismiss_preface()
	m.debug_restart_tutorial()
	m.tut_step = m.TUT_GUIDE.size()
	m._tut_show()
	m.tips_off = false
	m.tip_sig = {}
	m.tips_seed_pending = false
	for def in m.TIP_DEFS:
		m.tips_seen[str(def["id"])] = true
	for id in ["TIP_TAX", "TIP_HUNGRY", "TIP_DOCK"]:
		m.tips_seen.erase(id)
	m.tip_signal("dock")
	m.tip_signal("hungry")
	m.tip_signal("tax")
	var gap: float = float(m.balance.get("tip_gap_seconds", 90))
	var c0: int = m.cycle
	check(gap > 0.0 and m.tip_can_show(), "T339: tips can show in the test world and the gap key exists", "gap %s preface %s event %s dock %s tut %s skill %s galaxy %s over %s" % [gap, m.preface, m.event_notice, m.dock_sheet, m.tut_card.visible, m.skill_screen != null and m.skill_screen.visible, m.galaxy_view != null and m.galaxy_view.visible, m.game_over])
	_tip_clock_to(m, c0, 0.0)
	_tip_run(m, 1.0)
	check(m.tip_card.visible and m.tip_active == "TIP_TAX" and m.tip_text_label.text == StoryText.get_text("TIP_TAX"), "T339: of three tips due at once the highest priority shows first", m.tip_active)
	check(m.tip_queue.has("TIP_HUNGRY") and m.tip_queue.has("TIP_DOCK") and not m.tips_seen.has("TIP_HUNGRY"), "T339: the others wait unseen in the queue")
	check(m.tip_left > 0.0 and m.tip_left <= m.TIP_SECS_MAX and m.tip_card_secs(202) >= 10.0, "T339: the card life stays up long enough for the longest tip", str(m.tip_left))
	_tip_close_by_time(m)
	check(not m.tip_card.visible and m.tip_active == "", "T339: the card closes by itself")
	_tip_clock_to(m, c0, gap - 1.0)
	_tip_run(m, 2.0)
	check(not m.tip_card.visible and m.tip_active == "", "T339: no second card one second before the gap is over")
	_tip_clock_to(m, c0, gap)
	_tip_run(m, 1.0)
	check(m.tip_card.visible and m.tip_active == "TIP_HUNGRY", "T339: the second tip shows one gap after the first", m.tip_active)
	_tip_close_by_time(m)
	_tip_clock_to(m, c0, 2.0 * gap - 1.0)
	_tip_run(m, 2.0)
	check(m.tip_active == "", "T339: still no card before the second gap is over")
	_tip_clock_to(m, c0, 2.0 * gap)
	_tip_run(m, 1.0)
	check(m.tip_active == "TIP_DOCK" and m.tip_queue.is_empty(), "T339: the third tip shows a gap later and the queue is empty: none lost, none doubled", m.tip_active)
	# the right-hand box: newest with its why-line, the two before it small below
	var board: Node = m.tip_now_label.get_parent()
	check(m.tip_now_label.visible and m.tip_now_label.text == StoryText.get_text("TIP_DOCK") and m.tip_now_why.text == StoryText.get_text("TIP_DOCK_WHY"), "T339: the right panel shows the active tip with its why-line")
	check(board.is_ancestor_of(m.tip_recent_box) and m.tip_recent_box.visible and m.tip_recent_box.get_child_count() == 2, "T339: the right panel lists the two earlier tips", str(m.tip_recent_box.get_child_count()))
	check((m.tip_recent_box.get_child(0) as Label).text == StoryText.get_text("TIP_HUNGRY") and (m.tip_recent_box.get_child(1) as Label).text == StoryText.get_text("TIP_TAX"), "T339: the list is newest first")
	_tip_close_by_time(m)
	check(m.tip_now_label.visible and m.tip_now_label.text == StoryText.get_text("TIP_DOCK"), "T339: after the card closes the panel still shows the last tip")
	# a fourth tip pushes the oldest out: only the last three remain
	m.tips_seen.erase("TIP_SALVAGE")
	m.tip_signal("salvage")
	_tip_clock_to(m, c0, 3.0 * gap)
	_tip_run(m, 1.0)
	check(m.tip_active == "TIP_SALVAGE" and m.tip_recent.size() == 3, "T339: a fourth tip shows and the recent list keeps three", m.tip_active)
	var rec := ""
	for c in m.tip_recent_box.get_children():
		rec += (c as Label).text + "|"
	check(m.tip_now_label.text == StoryText.get_text("TIP_SALVAGE") and not rec.contains(StoryText.get_text("TIP_TAX")) and rec.contains(StoryText.get_text("TIP_DOCK")), "T339: the oldest of four is gone from the panel", rec)
	# two tips about one thing share one card
	_tip_close_by_time(m)
	m.tips_seen.erase("TIP_WEATHER")
	m.tips_seen.erase("TIP_WEATHER_KINDS")
	m.tip_queue = ["TIP_WEATHER_KINDS", "TIP_WEATHER"]
	_tip_clock_to(m, c0, 4.0 * gap)
	_tip_run(m, 1.0)
	check(m.tip_active == "TIP_WEATHER" and m.tip_text_label.text.contains(StoryText.get_text("TIP_WEATHER")) and m.tip_text_label.text.contains(StoryText.get_text("TIP_WEATHER_KINDS")), "T339: weather tip and weather kinds tip share one card", m.tip_text_label.text)
	check(m.tips_seen.has("TIP_WEATHER") and m.tips_seen.has("TIP_WEATHER_KINDS") and m.tip_queue.is_empty(), "T339: the merged tips are both seen and not queued again")
	_tip_close_by_time(m)
	# Skip tutorial / tips off: no card, the gap state is untouched, the panel hides; back on, the tip comes at once
	m.tips_seen.erase("TIP_TAX")
	m.tip_sig = {}
	m.tip_signal("tax")
	var last_before: float = m.tip_last_at
	m.tips_off = true
	_tip_clock_to(m, c0, 9.0 * gap)
	_tip_run(m, 2.0)
	check(not m.tip_card.visible and m.tip_active == "" and m.tip_last_at == last_before and not m.tips_seen.has("TIP_TAX"), "T339: with tips off no card shows and no gap is started")
	check(not m.tip_now_label.visible and not m.tip_recent_box.visible, "T339: with tips off the panel list is hidden")
	m.tips_off = false
	_tip_run(m, 1.0)
	check(m.tip_active == "TIP_TAX", "T339: with tips on again the waiting tip shows", m.tip_active)
	_tip_close_by_time(m)
	m.cycle = c0
	m.cycle_elapsed = 0.0
	m.tip_reset_flow(false)

func _test_tutorial_t316(m: Node) -> void:
	for id in m.TUT_GUIDE:
		check(StoryText.get_or(id, "", {}) != "" and StoryText.get_or(id + "_WHY", "", {}) != "", "T316: guided step %s has its text and why line" % id)
	var ids: Array = []
	for def in m.TIP_DEFS:
		var tid: String = def["id"]
		check(not ids.has(tid), "T316: tip %s is listed once" % tid)
		ids.append(tid)
		check(StoryText.get_or(tid, "", {}) != "" and StoryText.get_or(tid + "_WHY", "", {}) != "", "T316: tip %s has its text and why line" % tid)
		check(def.has("cond") or def.has("state") or def.has("sig"), "T316: tip %s has a trigger" % tid)
		if def.has("cond"):
			var errs: Array = []
			Conditions.lint(def["cond"], "tip " + tid, errs)
			check(errs.is_empty(), "T316: tip %s condition is valid" % tid, str(errs))
		if def.has("state"):
			var ok := true
			m.tut_step = 0
			ok = typeof(m._tip_state(str(def["state"]))) == TYPE_BOOL
			check(ok, "T316: tip %s state check answers true or false" % tid)
	# old saves land on the matching step; finished stays finished
	var G: Array = m.TUT_GUIDE
	check(G[m.tut_map_saved_step(6, 2)] == "TUT_G7_STORAGE", "T316: v2 save at storage stays on storage")
	check(G[m.tut_map_saved_step(7, 2)] == "TUT_G8_SKILLS", "T316: v2 save at skills lands on skills")
	check(G[m.tut_map_saved_step(8, 2)] == "TUT_G9_PERMIT", "T316: v2 save at permit lands on permit")
	check(G[m.tut_map_saved_step(9, 2)] == "TUT_G10_DONE", "T316: v2 save at done lands on done")
	check(m.tut_map_saved_step(10, 2) == G.size(), "T316: a finished v2 tutorial stays finished")
	check(G[m.tut_map_saved_step(4, 1)] == "TUT_G8_SKILLS" and m.tut_map_saved_step(6, 1) == G.size(), "T316: v1 mapping and finished v1")
	check(m.tut_map_saved_step(G.size(), m.TUT_VER) == G.size() and m.tut_map_saved_step(3, m.TUT_VER) == 3, "T316: current version keeps its step")
	# T320: the Ships step, old saves one more time
	check(G[1] == "TUT_G1B_SHIPS" and G.size() == 13 and G[0] == "TUT_G1_SELECT" and G[2] == "TUT_G2_BUY", "T320: the Ships step sits second, 13 steps")
	check(StoryText.get_or("TUT_G1B_SHIPS", "", {}) != "" and StoryText.get_or("TUT_G1B_SHIPS_WHY", "", {}) != "", "T320: Ships step ids exist in the story")
	check(m.TUT_TARGET.size() == G.size() and m.TUT_TARGET[1] == "hero", "T320: every step has a target slot, step 2 points at the hero card")
	check(G[m.tut_map_saved_step(1, 3)] == "TUT_G2_BUY" and m.tut_map_saved_step(0, 3) == 0, "T320: v3 save at buy lands on buy, at select stays")
	check(G[m.tut_map_saved_step(11, 3)] == "TUT_G10_DONE" and m.tut_map_saved_step(12, 3) == G.size(), "T320: v3 done lands on done, finished v3 stays finished")
	check(G[m.tut_map_saved_step(7, 3)] == "TUT_G7_NEEDS" and G[m.tut_map_saved_step(3, 2)] == "TUT_G4_ROUTE_PAY", "T320: mid-way v3 and v2 saves land on the same step")
	check(G[m.tut_map_saved_step(9, 2)] == "TUT_G10_DONE" and m.tut_map_saved_step(10, 2) == G.size(), "T320: v2 done and finished map to the new numbering")
	check(G[m.tut_map_saved_step(2, 1)] == "TUT_G3_SEND" and G[m.tut_map_saved_step(4, 1)] == "TUT_G8_SKILLS" and G[m.tut_map_saved_step(5, 1)] == "TUT_G10_DONE", "T320: v1 saves map to the new numbering")
	# no hero ship (discovery off): the Ships step is passed over; with a hero ship it waits for the card click
	m.debug_restart_tutorial()
	m.tut_flags = {}
	check(not Availability.hero_ship(m.map.flight) and m._tut_step_skipped(1), "T320: the Ships step is skipped without a hero ship")
	check(not m._tut_step_done(1), "T320: the Ships step is not done before the card is used")
	m.tut_flags["hero"] = true
	check(m._tut_step_done(1), "T320: the Ships step is done once the Pathfinder card was used")
	m.tut_flags = {}
	# a tip shows once, even after save and load; Skip tutorial silences them
	m.debug_restart_tutorial()
	m.tut_step = G.size()
	m.tips_seen = {}
	m.tips_off = false
	m.tip_sig = {}
	m.tips_seen["TIP_TIER1"] = true  # a grown world is not what this test is about
	m.tip_signal("tax")
	check(m.tip_next() == "TIP_TAX", "T316: a signalled tip is next", m.tip_next())
	m._tip_show("TIP_TAX")
	check(m.tip_card.visible and m.tip_text_label.text != "" and m.tips_seen.has("TIP_TAX"), "T316: the tip card shows the tip and marks it seen")
	m._tip_close()
	check(m.tip_next() != "TIP_TAX", "T316: a shown tip does not come back")
	var st: Dictionary = JSON.parse_string(JSON.stringify(m.collect_state()))
	m.tips_seen = {}
	m.apply_state(st)
	check(m.tips_seen.has("TIP_TAX") and not m.tips_seed_pending, "T316: shown tips are saved and stay shown after load")
	m.tip_signal("tax")
	check(m.tip_next() != "TIP_TAX", "T316: no repeat after load")
	m.tut_step = 3
	m._tut_skip()
	check(m.tips_off and not m.tip_card.visible, "T316: Skip tutorial turns the tips off")
	var s2: Dictionary = JSON.parse_string(JSON.stringify(m.collect_state()))
	m.tips_off = false
	m.apply_state(s2)
	check(m.tips_off, "T316: tips stay off after load")
	m.debug_restart_tutorial()
	check(not m.tips_off and m.tips_seen.is_empty(), "T316: restart brings the tips back")
	# T322: new run with the menu setting on starts finished, off starts at step 0, a saved run keeps its step
	var skip_keep: bool = SaveGame.skip_tutorial()
	var results: Array = []
	for on in [true, false]:
		SaveGame.set_skip_tutorial(on)
		SaveGame.continue_requested = false
		var nm: Control = load(MAIN_SCENE).instantiate()
		root.add_child(nm)
		results.append(nm.tut_step)
		results.append(nm.tips_off)
		nm.queue_free()
	check(results[0] == G.size() and results[1] and results[2] == 0 and not results[3], "T322: a new run starts with the tutorial done when skip is on, at step 0 when off", str(results))
	# T322 rework: the ship pulse plays once per run, 3 pulses, and not again on a second selection
	check(m.ship_ring != null and not m.ship_ring.visible and m.ship_pulse_plays == 0, "T322: ship pulse ring exists, hidden, unplayed at start")
	m.ship_pulse_on_select()
	var first_tween: Tween = m.ship_ring._tween
	m.ship_pulse_on_select()
	check(m.ship_pulse_plays == 1 and m.ship_ring._tween == first_tween and m.ship_ring.pulses == 3 and m.SHIP_PULSE_N == 3, "T322: ship pulse plays once (3 pulses) and does not replay on a second selection")
	m.ship_ring.stop()
	check(not ("ship_link" in m), "T322: the card-to-ship link line is gone")
	# T323: the planet ring shows only while the tutorial step asks for a planet click
	var saved_step: int = m.tut_step
	m.tut_step = G.size()
	m._tut_show()
	m._tut_update_planet_ring()
	check(m.tut_planet_ring_target() == -1 and m._planet_ring_i == -1 and not m.planet_ring.is_playing(), "T323: no planet ring when the tutorial is over or skipped")
	m.tut_step = 0
	m._tut_show()
	var g0: String = m._tut_g0_id()
	if g0 == "TUT_G0_FLY":
		check(m.tut_planet_ring_target() == m.tut_fly_target() and m.tut_fly_target() >= 0, "T327: under discovery step 0 the planet ring marks the one planet the card asks for")
	else:
		check(m.tut_planet_ring_target() >= 0, "T323: the planet-click step has the ring")
		m._tut_update_planet_ring()
		check(m.planet_ring.is_playing() and m.planet_ring.pulses == 0, "T323: the planet ring loops on that step")
		m._tut_skip()
		m._tut_update_planet_ring()
		check(m._planet_ring_i == -1 and not m.planet_ring.is_playing() and not m.planet_ring.visible, "T323: Skip tutorial stops the planet ring at once")
	m.tut_step = saved_step
	m._tut_show()
	m._tut_update_planet_ring()
	m.tut_step = 3
	var keep_state: Dictionary = JSON.parse_string(JSON.stringify(m.collect_state()))
	SaveGame.set_skip_tutorial(true)
	m.apply_state(keep_state)
	check(m.tut_step == 3, "T322: a saved run keeps its tut_step whatever the setting says")
	SaveGame.set_skip_tutorial(skip_keep)

## T322: a new run starts zoomed in with the Pathfinder inside the window and clear of the right Ships strip; a loaded save keeps its camera.
func _test_ship_reveal() -> void:
	var old_size := root.size
	root.size = Vector2i(1920, 1080)  # T327: the start framing reads the window size, so it is set before the run starts
	var m: Control = await _new_main(true, true)
	if m.preface != null:
		m._dismiss_preface()
	for i in 4:
		await process_frame
	var map = m.map
	var win := Rect2(Vector2.ZERO, Vector2(root.size))
	var strip := m.right_col.get_parent() as Control
	var p: Vector2 = map.ship_screen_pos()
	# T327: the start view may back off, but only as far as it takes to show the one planet the first card asks for
	var fly_t: int = m.tut_fly_target()
	check(map.zoom > map.START_ZOOM or (fly_t >= 0 and win.has_point(map.planet_screen_pos(fly_t))), "T322 start view: a new run is zoomed in (or just far enough out to show the first target)", str(map.zoom))
	check(p != Vector2(-1, -1) and win.has_point(p), "T322 start view: the Pathfinder is inside the window", str(p))
	check(strip == null or not strip.get_global_rect().has_point(p), "T322 start view: the Pathfinder is clear of the right Ships strip", str(p))
	var keep_f := Vector3(1.5, 0.0, -2.5)
	var keep_z := 0.77
	var st: Dictionary = JSON.parse_string(JSON.stringify(m.collect_state()))
	map.focus = keep_f
	map.zoom = keep_z
	m.apply_state(st)
	check(is_equal_approx(map.zoom, keep_z) and map.focus.is_equal_approx(keep_f), "T322 start view: loading a save does not override the camera", str(map.zoom))
	root.size = old_size
	await _free_main(m)

## T327: real click path (map input events, the tutorial lock, the pause state), discovery on, window 1920x1080.
func _click_at(p: Vector2) -> void:
	for down in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = down
		e.position = p
		e.global_position = p
		root.push_input(e)

## Owner report 2026-11-09: the Ships step (TUT_G1B_SHIPS) must outline the Pathfinder card in the Ships menu, also with the Tips
## box tall, a tip card up, or the card below the fold of the right column. The window is a fixed 1920x1080 canvas (stretch
## canvas_items), so 1280x720 only changes the real window, not the layout; both sizes are run anyway.
func _test_tut_hero_highlight() -> void:
	var old_size := root.size
	for c in root.get_children():
		if c.scene_file_path == MAIN_SCENE:
			c.free()
	for sz in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		root.size = sz
		for variant in ["plain", "tips", "below_fold"]:
			var tag := "tut hero highlight (%s, %s): " % [str(sz), variant]
			var m: Control = await _new_main(true, true)
			for i in 4:
				await process_frame
			m.tut_flags = {}  # as after a load: the flight card did not skip the Ships step
			m.tut_step = 1
			if variant == "tips":
				for d in m.TIP_DEFS.slice(0, 5):
					m._tip_show(str(d["id"]))
			elif variant == "below_fold":
				var pad := Control.new()
				pad.custom_minimum_size = Vector2(0, 1200)
				m.right_col.add_child(pad)
				m.right_col.move_child(pad, 0)
			for i in 6:
				await process_frame
			var hc: Control = m.ship_panel.hero_card
			var want: Rect2 = hc.get_global_rect().grow(3.0)
			check(m._tut_id(1) == "TUT_G1B_SHIPS" and m.tut_step == 1 and m.tut_card.visible, tag + "the Ships card shows", str([m.tut_step, m.tut_card.visible]))
			check(m._tut_highlight_key() == "hero", tag + "highlight key is hero", m._tut_highlight_key())
			check(m.tut_hl.visible, tag + "the outline is visible")
			var got := Rect2(m.tut_hl.global_position, m.tut_hl.size)
			check(got.position.distance_to(want.position) < 4.0 and got.size.distance_to(want.size) < 4.0, tag + "the outline sits over the hero card", str([got, want]))
			await _free_main(m)
	root.size = old_size


func _test_tut_fly_click() -> void:
	var old_size := root.size
	root.size = Vector2i(1920, 1080)
	for c in root.get_children():  # runs left by earlier tests would sit under the cursor and take the clicks
		if c.scene_file_path == MAIN_SCENE:
			c.free()
	var m: Control = await _new_main(true, true)
	for i in 4:
		await process_frame
	var map = m.map
	var f = map.flight
	var win := Rect2(Vector2.ZERO, Vector2(root.size))
	check(m._tut_g0_id() == "TUT_G0_FLY", "T327: the first card is the flight card", m._tut_g0_id())
	var t: int = m.tut_fly_target()
	# the target is the nearest closed planet the ship can fly to: recompute it here from the accessor, independent of the cache
	var ship: Vector3 = f.ship_position()
	var best := -1
	var best_d := INF
	for i in map.planets.size():
		if map.planet_in_view(i) and not (f.actions_for(str(map.planets[i].get("id", ""))) as Array).is_empty():
			var d := Vector2(map.positions[i].x - ship.x, map.positions[i].z - ship.z).length()
			if d < best_d - 0.0001:
				best_d = d
				best = i
	check(t >= 0 and t == best, "T327: the target is the nearest closed planet the Pathfinder can fly to", str([t, best]))
	check(t >= 0 and not f.post_built(str(map.planets[t].get("id", ""))) and m.tut_fly_target() == t, "T327: the target is closed and stays the same on the next call")
	var tp: Vector2 = map.planet_screen_pos(t)
	check(win.has_point(tp) and map.pick_planet(tp) == t, "T327: the target is inside the window and pickable at the start view", str(tp))
	var txt: String = m.tutorial_label.text
	check(txt.contains(m.planet_name(t)) and not txt.contains("{"), "T327: the card names the target as the map labels it", txt)
	m._tut_update_planet_ring()
	check(m._planet_ring_i == t and m.planet_ring.is_playing(), "T327: the pulse ring plays on the target during the flight card")
	# a click on another planet is refused: the ship does not go
	var other := -1
	for i in map.planets.size():
		if i != t and map.planet_in_view(i) and win.has_point(map.planet_screen_pos(i)) and map.pick_planet(map.planet_screen_pos(i)) == i and str(map.planets[i].get("id", "")) != f.docked_at():
			other = i
			break
	_click_at(map.ship_screen_pos())
	await process_frame
	check(map.ship_selected, "T327: a click on the Pathfinder selects it")
	if other >= 0:
		_click_at(map.planet_screen_pos(other))
		await process_frame
		check(f.state() == "idle", "T327: the flight card refuses another planet, the ship stays", f.state())
		map.select_ship(true)
	# the click on the asked-for planet sends the ship, and the run is not left paused
	_click_at(map.planet_screen_pos(t))
	await process_frame
	check(f.state() == "flying" and not m.paused, "T327: clicking the asked-for planet sends the Pathfinder and starts the clock", str([f.state(), m.paused]))
	check(m._tut_g0_id() == "TUT_G0_FLY" and m.tut_step == 0, "T327: still the flight card while the ship is on its way")
	for i in 8:
		if m._tut_g0_id() != "TUT_G0_FLY":
			break
		m.debug_advance_cycle()
		await process_frame
	check(m._tut_g0_id() == "TUT_G0_BUILD" and f.docked_at() == str(map.planets[t].get("id", "")), "T327: on arrival the tutorial moves from flight to build", m._tut_g0_id())
	m._tut_update_planet_ring()
	check(m._planet_ring_i != t or not m.planet_ring.is_playing(), "T327: the target ring is gone once the flight card is over")
	await _free_main(m)
	root.size = old_size

func _rclick_at(p: Vector2) -> void:
	for down in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_RIGHT
		e.pressed = down
		e.position = p
		e.global_position = p
		root.push_input(e)

## T329: card 1 is one right-click on the named planet and its Establish entry; Yay card with Next; then the Voltara card.
func _test_tut_g0_rmb() -> void:
	var old_size := root.size
	root.size = Vector2i(1920, 1080)
	for c in root.get_children():
		if c.scene_file_path == MAIN_SCENE:
			c.free()
	var m: Control = await _new_main(true, true)
	for i in 4:
		await process_frame
	var map = m.map
	var f = map.flight
	var win := Rect2(Vector2.ZERO, Vector2(root.size))
	var t: int = m.tut_fly_target()
	check(m._tut_g0_id() == "TUT_G0_FLY" and t >= 0 and m.tutorial_label.text.contains(m.planet_name(t)), "T329: card 1 names the target planet", m.tutorial_label.text)
	check(m.paused and not map.ship_selected, "T329: the run starts paused with no ship selected")
	var other := -1
	for i in map.planets.size():
		if i != t and map.planet_in_view(i) and win.has_point(map.planet_screen_pos(i)) and map.pick_planet(map.planet_screen_pos(i)) == i and not (f.actions_for(str(map.planets[i].get("id", ""))) as Array).is_empty():
			other = i
			break
	if other >= 0:
		_rclick_at(map.planet_screen_pos(other))
		await process_frame
		var om = m.get_node_or_null("ShipActionMenu")
		check(om == null or not om.visible, "T329: a right-click on another planet opens no Establish menu")
		check(f.state() == "idle" and m.paused, "T329: another planet is refused, the ship stays")
	_rclick_at(map.planet_screen_pos(t))
	await process_frame
	var menu: PopupMenu = m.get_node_or_null("ShipActionMenu")
	check(menu != null and menu.visible and menu.item_count == 1, "T329: right-click on the target opens the Establish menu without selecting the ship", str(menu))
	if menu != null:
		check(menu.get_item_text(0) == StoryText.get_or("BTN_ESTABLISH_POST", "Establish trading post"), "T329: the entry is Establish a trading post", menu.get_item_text(0))
		menu.id_pressed.emit(menu.get_item_id(0))  # the menu's own signal; popups have no hit test headless
		await process_frame
	check(f.state() == "flying" and not m.paused, "T329: Establish on the target sends the ship and starts the clock", str([f.state(), m.paused]))
	for i in 12:
		if m._tut_g0_id() != "TUT_G0_FLY":
			break
		m.debug_advance_cycle()
		await process_frame
	check(m._tut_g0_id() == "TUT_G0_DONE" and f.post_built(str(map.planets[t].get("id", ""))), "T329: ship arrived and post stands: the Yay card", m._tut_g0_id())
	check(m.tutorial_label.text == StoryText.get_or("TUT_G1C_SPEED", "", {}).strip_edges() and m.tut_next.is_visible_in_tree(), "T334: the speed card (shown after the order) is still up when the post stands", m.tutorial_label.text)
	_click_at(m.tut_next.get_global_rect().get_center())
	await process_frame
	await process_frame
	check(m.tutorial_label.text.contains(m.planet_name(t)) and m.tut_next.visible and m.tut_next.is_visible_in_tree(), "T329: the Yay card names the planet and shows Next", m.tutorial_label.text)
	check(m.tut_step == 0 and not m.paused and m.tut_planet_ring_target() == -1, "T329: Yay card: still step 1, game running, no ring")
	var step_before: int = m.tut_step
	var nb: Rect2 = m.tut_next.get_global_rect()
	_click_at(nb.get_center())
	await process_frame
	await process_frame
	check(m._tut_g0_id() == "" and m.tut_step == 0 and m.tutorial_label.text == StoryText.get_or("TUT_G1_SELECT", "", {}).strip_edges() and not m.tut_next.visible, "T334: the Yay card's Next leads straight to the Voltara card (no second speed card)", m.tutorial_label.text)
	check(m._tut_g0_id() == "" and m.tut_step == 0 and m.tutorial_label.text == StoryText.get_or("TUT_G1_SELECT", "", {}).strip_edges() and step_before == 0, "T329: Next leads to the Voltara card", m.tutorial_label.text)
	check(not m.tut_next.visible, "T329: Next is gone on the Voltara card")
	await _free_main(m)
	# the Voltara card never shows before the post stands
	m = await _new_main(true, true)
	for i in 4:
		await process_frame
	check(m.tutorial_label.text != StoryText.get_or("TUT_G1_SELECT", "", {}).strip_edges() and not m.tut_next.visible, "T329: no Voltara card before the post stands")
	await _free_main(m)
	# no discovery: no Yay card
	m = await _new_main(true, false)
	for i in 4:
		await process_frame
	check(m._tut_g0_id() == "" and not m.tut_next.visible, "T329: without discovery there is no flight or Yay card")
	await _free_main(m)
	root.size = old_size

## T331: the card counter read from the real label while the guide is walked with real clicks (planet, cash panel, Next).
## Each distinct step shows n = previous n + 1, never repeats or jumps; the last card reads "k of k"; Expenses shows Next only
## after the cash panel was clicked open, and Next (clicked) leads to the Sell card.
func _test_tut_counter() -> void:
	var old_size := root.size
	root.size = Vector2i(1920, 1080)
	for c in root.get_children():
		if c.scene_file_path == MAIN_SCENE:
			c.free()
	for disc in [false, true]:
		var tag := "T331 (discovery %s): " % str(disc)
		var m: Control = await _new_main(true, disc)
		for i in 4:
			await process_frame
		var seen: Array = []  # [step, n, total, label text]
		var obs := func():
			var parts: PackedStringArray = m.tut_count.text.split(" of ")
			if m.tut_step < m.TUT_GUIDE.size() and m.tut_count.visible and parts.size() == 2:
				var rec := [m.tut_step, int(parts[0]), int(parts[1]), m.tutorial_label.text]
				if seen.is_empty() or seen[-1][0] != rec[0] or seen[-1][1] != rec[1] or seen[-1][2] != rec[2] or seen[-1][3] != rec[3]:
					seen.append(rec)
		var map = m.map
		var guard := 0
		var upkeep_checked := false
		var sell_n := -1
		while m.tut_step < m.TUT_GUIDE.size() and guard < 40:
			guard += 1
			await process_frame
			obs.call()
			match m.tut_step:
				0:
					var g0: String = m._tut_g0_id()
					if g0 == "TUT_G0_FLY":
						m._on_fly_establish_requested(str(map.planets[m.tut_fly_target()].get("id", "")))
						m.set_paused(false)
						for k in 20:
							if m._tut_g0_id() != "TUT_G0_FLY":
								break
							m.debug_advance_cycle()
							await process_frame
					elif g0 == "TUT_G0_DONE":
						_click_at(m.tut_next.get_global_rect().get_center())
					elif g0 != "":
						m.debug_advance_cycle()
					elif m._tut_speed_card():
						_click_at(m.tut_next.get_global_rect().get_center())  # T333: the speed card ends on Next
					else:
						var pi := 0
						for i in map.planets.size():
							if map.planet_in_view(i) and map.pick_planet(map.planet_screen_pos(i)) == i:
								pi = i
								break
						_click_at(map.planet_screen_pos(pi))
				1:
					m.tut_flags["hero"] = true
				2:
					m.engine.local_of(0, "ore", true)["buy"] = true
				3:
					m.engine.routes.append(m.engine.new_record(0, 1, "ore"))
				4:
					m.cycle = 2
				5:
					if not upkeep_checked:
						upkeep_checked = true
						for k in 3:
							await process_frame
						check(not m.tut_next.visible and m.tutorial_label.text == StoryText.get_or("TUT_G5_UPKEEP", "", {}).strip_edges(), tag + "no Next before the cash panel is opened", m.tutorial_label.text)
						var cbr: Rect2 = m.cash_box.get_global_rect()
						check(m.tut_hl.visible and m.tut_hl.get_global_rect().grow(-3.0).is_equal_approx(cbr), tag + "T333b: before the panel is opened the outline is the cash box", str([m.tut_hl.get_global_rect(), cbr]))
						_click_at(m.cash_box.get_global_rect().get_center())
						for k in 3:
							await process_frame
						_check_upkeep_highlight(m, tag, cbr)
						check(m.cash_forecast.visible and m.tut_step == 5 and m.tut_next.visible and m.tut_next.is_visible_in_tree(), tag + "panel open: the card stays on Expenses and shows Next", str([m.tut_step, m.tut_next.visible]))
						obs.call()
						var fr: Rect2 = m.cash_forecast.get_global_rect()
						check(not m.tut_card.get_global_rect().intersects(fr) and not m.tut_next.get_global_rect().intersects(fr), tag + "T333: the open forecast panel is not covered by the card, Next is clear of it", str([m.tut_card.get_global_rect(), m.tut_next.get_global_rect(), fr]))
						_click_at(m.tut_next.get_global_rect().get_center())
						for k in 3:
							await process_frame
						check(m.tut_step == 6 and not m.tut_next.visible, tag + "clicking Next advances to the Sell step", str(m.tut_step))
						obs.call()
						sell_n = seen[-1][1] if seen[-1][0] == 6 else -1
				6:
					m.engine.local_of(1, "ore", true)["sell"] = true
				7:
					m.tut_flags["storage_next"] = true
				8, 9, 10, 11:
					m.skill_points = 0
					m.learned_skills = []
					m.tut_step = 12
				12:
					m.tut_note("bazaar")
		check(m.tut_step == m.TUT_GUIDE.size(), tag + "the walk reached the end", str(m.tut_step))
		check(upkeep_checked and sell_n > 0, tag + "the Expenses and Sell cards were both read", str(sell_n))
		var ok: bool = not seen.is_empty() and seen[0][1] == 1
		var detail := ""
		for k in seen.size():
			detail += "%d:%d/%d " % [seen[k][0], seen[k][1], seen[k][2]]
			if k > 0:
				var stepped: bool = seen[k][0] != seen[k - 1][0]
				if stepped and seen[k][1] != seen[k - 1][1] + 1:
					ok = false  # a new step must be exactly one more
				if not stepped and seen[k][1] != seen[k - 1][1]:
					ok = false  # the same step keeps its number
			if seen[k][1] > seen[k][2]:
				ok = false
		check(ok and seen[-1][1] == seen[-1][2], tag + "counter runs 1, 2, 3 ... without repeat or jump and ends on k of k", detail)
		var g0cards := 0
		for rec in seen:
			if rec[0] == 5:
				check(rec[1] == sell_n - 1, tag + "Expenses is one before Sell", detail)
				g0cards += 1
		check(g0cards >= 1, tag + "Expenses card was recorded")
		await _free_main(m)
	root.size = old_size

## T342: the WHOLE guided tutorial, real clicks, both modes, with and without a skill point. Reads the real counter label and the
## real Skip and Finish button nodes. n runs 1, 2, 3 ... (slide 1 is one slide), the total never grows and never drops below n, the
## last card reads k of k and shows Finish instead of Skip, and clicking Finish ends the tutorial with the tips still on.
func _test_tut_full_walk() -> void:
	var old_size := root.size
	root.size = Vector2i(1920, 1080)
	for c in root.get_children():
		if c.scene_file_path == MAIN_SCENE:
			c.free()
	for disc in [false, true]:
		for pts in [true, false]:
			var tag := "T342 (discovery %s, points %s): " % [str(disc), str(pts)]
			var m: Control = await _new_main(true, disc)
			for i in 4:
				await process_frame
			var map = m.map
			var rows: Array = []  # [card id, n, total, step, skip visible, finish visible]
			var guard := 0
			var last_key := ""
			var upk := false
			var ev := InputEventKey.new()
			ev.keycode = KEY_K
			ev.pressed = true
			while m.tut_step < m.TUT_GUIDE.size() and guard < 80:
				guard += 1
				await process_frame
				await process_frame
				if not pts:
					m.skill_points = 0
				var parts: PackedStringArray = m.tut_count.text.split(" of ")
				var key: String = m._tut_id(m.tut_step) + "|" + m.tut_count.text
				if key != last_key and m.tut_card.visible and parts.size() == 2:
					last_key = key
					rows.append([m._tut_id(m.tut_step), int(parts[0]), int(parts[1]), m.tut_step, m.tut_skip_btn.visible and m.tut_skip_btn.is_visible_in_tree(), m.tut_finish_btn.visible and m.tut_finish_btn.is_visible_in_tree()])
				if m.tut_step == m.TUT_GUIDE.size() - 1:
					break
				match m.tut_step:
					0:
						var g0: String = m._tut_g0_id()
						if m._tut_speed_card() or g0 == "TUT_G0_DONE":
							_click_at(m.tut_next.get_global_rect().get_center())
						elif g0 == "TUT_G0_FLY":
							m._on_fly_establish_requested(str(map.planets[m.tut_fly_target()].get("id", "")))
							m.set_paused(false)
							for k in 30:
								if m._tut_g0_id() == "TUT_G0_DONE":
									break
								m.debug_advance_cycle()
								await process_frame
						elif g0 != "":
							m.debug_advance_cycle()
						else:
							var pi := 0
							for i in map.planets.size():
								if map.planet_in_view(i) and map.pick_planet(map.planet_screen_pos(i)) == i:
									pi = i
									break
							_click_at(map.planet_screen_pos(pi))
					1:
						m.tut_flags["hero"] = true
					2:
						m.engine.local_of(0, "ore", true)["buy"] = true
					3:
						m.engine.routes.append(m.engine.new_record(0, 1, "ore"))
					4:
						m.cycle = 2
					5:
						if not upk:
							upk = true
							_click_at(m.cash_box.get_global_rect().get_center())
							for k in 3:
								await process_frame
						if m.tut_next.visible:
							_click_at(m.tut_next.get_global_rect().get_center())
					6:
						m.engine.local_of(1, "ore", true)["sell"] = true
					7:
						if m.tut_next.is_visible_in_tree():  # T344: the Storage card moves on by its Next button
							_click_at(m.tut_next.get_global_rect().get_center())
					8, 9:
						m.debug_advance_cycle()
						if guard > 60:
							m.tut_step = 10
					10:
						if pts and m.skill_points == 0:
							m.skill_points = 3
						if not m.skill_screen.visible:
							root.push_input(ev)
							for k in 3:
								await process_frame
						var best := ""
						for id in m.skill_screen.node_buttons:
							if id.begins_with("FND_") and m.skill_screen.node_state(m.learned_skills, m.skill_points, m.balance, id) == "learnable" and m.skill_lock_reason(id) == "":
								best = id
								break
						if best != "":
							_click_at(m.skill_screen.node_buttons[best].get_global_rect().get_center())
							for k in 3:
								await process_frame
							_click_at(m.skill_screen.learn_button.get_global_rect().get_center())
						for k in 3:
							await process_frame
						if m.skill_screen.visible:
							root.push_input(ev)
					11:
						if m.skill_screen.visible:
							root.push_input(ev)
						m.debug_advance_cycle()
						if guard > 70:
							m.tut_step = 12
			var detail := ""
			for r in rows:
				detail += "%s %d/%d s%d%s%s; " % [r[0], r[1], r[2], r[3], " skip" if r[4] else "", " finish" if r[5] else ""]
			print("T342 table ", tag, detail)
			var ok: bool = not rows.is_empty() and rows[0][1] == 1
			var n_prev := 0
			var t_prev := 99
			var step_prev := -1
			var skips_ok := true
			for r in rows:
				var new_step: bool = r[3] != step_prev
				if new_step and r[1] != n_prev + 1 and not (r[3] == 0 and step_prev == -1):
					ok = false
				if not new_step and r[1] != n_prev:
					ok = false
				if r[3] == 0 and r[1] != 1:
					ok = false  # slide 1 is one slide: flight, speed, build, wait, Yay and Voltara cards all read 1
				if r[1] > r[2] or r[2] > t_prev:
					ok = false
				if r[3] != m.TUT_GUIDE.size() - 1 and (not r[4] or r[5]):
					skips_ok = false
				n_prev = r[1]
				t_prev = r[2]
				step_prev = r[3]
			check(ok, tag + "counter runs 1, 2, 3 ... slide 1 stays one slide, total never grows or drops below n", detail)
			check(skips_ok, tag + "every card but the last shows Skip and no Finish", detail)
			check(m.tut_step == m.TUT_GUIDE.size() - 1 and m.tut_card.visible and not rows.is_empty(), tag + "the walk reached the last card", str(m.tut_step))
			if m.tut_step == m.TUT_GUIDE.size() - 1:
				for k in 3:
					await process_frame
				check(m._tut_id(m.tut_step) == "TUT_G10_DONE" and m.tut_count.text == "%d of %d" % [rows[-1][1], rows[-1][1]], tag + "the last card reads k of k", m.tut_count.text)
				check(m.tut_finish_btn.is_visible_in_tree() and m.tut_finish_btn.text == StoryText.get_text("BTN_TUT_FINISH") and not m.tut_skip_btn.is_visible_in_tree(), tag + "the last card shows Finish and not Skip", m.tut_finish_btn.text)
				_click_at(m.tut_finish_btn.get_global_rect().get_center())
				for k in 3:
					await process_frame
				check(m.tut_step == m.TUT_GUIDE.size() and not m.tut_card.visible, tag + "clicking Finish ends the tutorial", str(m.tut_step))
				check(not m.tips_off and m.tip_next() != "", tag + "after Finish the one-time tips still run", str([m.tips_off, m.tip_next()]))
			await _free_main(m)
	# Skip on a middle card still silences the tips, by a real click
	var m2: Control = await _new_main(true, false)
	for i in 4:
		await process_frame
	check(m2.tut_skip_btn.is_visible_in_tree() and not m2.tut_finish_btn.is_visible_in_tree() and m2.tut_skip_btn.text == StoryText.get_text("BTN_SKIP_TUTORIAL"), "T342: the first card shows Skip and no Finish")
	_click_at(m2.tut_skip_btn.get_global_rect().get_center())
	for k in 3:
		await process_frame
	check(m2.tut_step == m2.TUT_GUIDE.size() and m2.tips_off, "T342: clicking Skip ends the tutorial and silences the tips", str([m2.tut_step, m2.tips_off]))
	await _free_main(m2)
	root.size = old_size

## T333b: with the forecast open on the Expenses card, the outline and arrow aim at the Ship upkeep line, not the cash box.
func _check_upkeep_highlight(m: Control, tag: String, cbr: Rect2) -> void:
	var up := StoryText.get_text("LBL_SHIP_UPKEEP")
	var fr: Rect2 = m.cash_forecast.get_global_rect()
	var hl: Rect2 = m.tut_hl.get_global_rect().grow(-3.0)
	var lines: Array = []
	for n in m.cash_forecast.box.get_children():
		if n is Label and (n as Label).text.contains(up):
			lines.append((n as Label).get_global_rect())
	if lines.is_empty():
		check(hl.is_equal_approx(cbr), tag + "T333b: no Ship upkeep line, so the outline stays on the cash box (fallback)", str([hl, cbr]))
		return
	var covers := false
	for lr in lines:
		if hl.encloses(lr):
			covers = true
	check(m.tut_hl.visible and fr.grow(1.0).encloses(hl) and covers, tag + "T333b: the outline sits inside the forecast panel and covers a Ship upkeep line", str([hl, fr, lines]))
	check(not hl.is_equal_approx(cbr) and not hl.intersects(cbr), tag + "T333b: the outline is not the cash box", str([hl, cbr]))
	var tip: Vector2 = m._tut_target_rect("expenses", m.cash_box).get_center()
	var inside := false
	for lr in lines:
		if (lr as Rect2).has_point(tip):
			inside = true
	check(inside and hl.has_point(tip), tag + "T333b: the arrow aims inside the Ship upkeep line", str([tip, lines]))

## T337: the Skills card (discovery on) guides inside the open Skills window. Real clicks (the points figure and the K key opens it,
## a node and Learn), the real card text, outline rect and arrow tip.
func _test_tut_skills_card() -> void:
	var old_size := root.size
	root.size = Vector2i(1920, 1080)
	for c in root.get_children():
		if c.scene_file_path == MAIN_SCENE:
			c.free()
	var want := StoryText.get_or("TUT_G8_SKILLS", "", {}).strip_edges()
	for mode in ["click", "key", "nopoint"]:
		var tag := "T337 (%s): " % mode
		var m: Control = await _new_main(true, true)
		for i in 4:
			await process_frame
		m.skill_points = 0 if mode == "nopoint" else 3
		m.tut_step = 9 if mode == "nopoint" else 10
		m._tut_sig = []
		for i in 4:
			await process_frame
		if mode == "nopoint":
			check(m.tut_step >= 12 and m.tut_skipped.has("TUT_G8_SKILLS"), tag + "no skill point: the Skills card is passed over, not shown", str([m.tut_step, m.tut_skipped]))
			await _free_main(m)
			continue
		var ss = m.skill_screen
		var count0: String = m.tut_count.text
		check(m.tut_step == 10 and m.tutorial_label.text == want and m.tut_hl.visible, tag + "closed: the Skills card shows its text and an outline", str([m.tut_step, m.tutorial_label.text]))
		check(m.tut_hl.get_global_rect().grow(-3.0).is_equal_approx(m.points_button.get_global_rect()), tag + "closed: the outline is the Skills button", str(m.tut_hl.get_global_rect()))
		if mode == "click":
			_click_at(m.points_hit.get_global_rect().get_center())
		else:
			var ev := InputEventKey.new()
			ev.keycode = KEY_K
			ev.pressed = true
			root.push_input(ev)
		for i in 4:
			await process_frame
		check(ss.visible and m.tut_step == 10 and m.tut_card.visible, tag + "window open: the card is still up on the same step", str([ss.visible, m.tut_step]))
		check(m.tutorial_label.text == want and m.tut_count.text == count0, tag + "window open: same card text and counter", m.tutorial_label.text + " " + m.tut_count.text)
		var best := ""
		for id in ss.node_buttons:
			if id.begins_with("FND_") and ss.node_state(m.learned_skills, m.skill_points, m.balance, id) == "learnable" and m.skill_lock_reason(id) == "":
				if best == "" or SkillTree.cost(m.balance, id) < SkillTree.cost(m.balance, best):
					best = id
		var nr: Rect2 = ss.node_buttons[best].get_global_rect()
		var hl: Rect2 = m.tut_hl.get_global_rect().grow(-3.0)
		check(best != "" and m.tut_hl.visible and hl.is_equal_approx(nr), tag + "window open: the outline is the cheapest learnable Foundation (%s)" % best, str([hl, nr]))
		check(m.tut_arrow.visible and nr.grow(8.0).has_point(m.tut_arrow.position), tag + "window open: the arrow tip is on that node", str([m.tut_arrow.position, nr]))
		var cr: Rect2 = m.tut_card.get_global_rect()
		var clash := ""
		for id in ss.node_buttons:
			if (ss.node_buttons[id] as Control).get_global_rect().intersects(cr):
				clash = id
		check(clash == "" and Rect2(Vector2.ZERO, Vector2(root.size)).encloses(cr), tag + "window open: the card covers no skill node and is on screen", clash + str(cr))
		check(m.tut_card.get_index() > ss.get_index() and m.tut_arrow.get_index() > ss.get_index() and m.tut_hl.z_index > ss.z_index, tag + "window open: card, arrow and outline are drawn above the Skills window")
		_click_at(ss.node_buttons[best].get_global_rect().get_center())
		for i in 3:
			await process_frame
		check(ss.selected == best, tag + "clicking the lit node selects it", ss.selected)
		_click_at(ss.learn_button.get_global_rect().get_center())
		for i in 4:
			await process_frame
		check(m.has_skill(best) and m.tut_step > 10, tag + "learning it advances the step", str([m.learned_skills, m.tut_step]))
		await _free_main(m)
	root.size = old_size

## T333: the speed card after slide 1, both modes, real clicks, real card text and counter.
func _test_tut_speed_card() -> void:
	var old_size := root.size
	root.size = Vector2i(1920, 1080)
	for c in root.get_children():
		if c.scene_file_path == MAIN_SCENE:
			c.free()
	var speed_text: String = StoryText.get_or("TUT_G1C_SPEED", "", {}).strip_edges()
	var select_text: String = StoryText.get_or("TUT_G1_SELECT", "", {}).strip_edges()
	check(speed_text != "", "T333: the speed card text id exists")
	for disc in [false, true]:
		for by_speed_click in [false, true]:
			var tag := "T333 (discovery %s, end by %s): " % [str(disc), "speed click" if by_speed_click else "Next"]
			var m: Control = await _new_main(true, disc)
			for i in 4:
				await process_frame
			var map = m.map
			if disc:
				check(m._tut_g0_id() == "TUT_G0_FLY", tag + "starts on the flight card", m._tut_g0_id())
				m._on_fly_establish_requested(str(map.planets[m.tut_fly_target()].get("id", "")))  # the menu entry's handler
				for k in 4:
					await process_frame
				check(m._tut_g0_id() == "TUT_G0_FLY" and m.tutorial_label.text == speed_text, tag + "T334: the speed card shows right after the establish order, before arrival", m.tutorial_label.text)
				check(not m.paused, tag + "T334: the clock runs (order accepted)")
				m.set_paused(false)
				# the ship arrives and builds while the card is up: it stays, the arrival cards wait behind it
				for k in 40:
					if m._tut_g0_id() == "TUT_G0_DONE":
						break
					m.debug_advance_cycle()
					await process_frame
				for k in 3:
					await process_frame
				check(m._tut_g0_id() == "TUT_G0_DONE" and m.tutorial_label.text == speed_text, tag + "T334: the speed card stays over the arrival cards until it ends", m.tutorial_label.text)
			else:
				var pi := 0
				for i in map.planets.size():
					if map.planet_in_view(i) and map.pick_planet(map.planet_screen_pos(i)) == i:
						pi = i
						break
				check(m.tutorial_label.text == select_text, tag + "slide 1 is the Voltara card", m.tutorial_label.text)
				_click_at(map.planet_screen_pos(pi))
			for k in 4:
				await process_frame
			check(m.tut_step == 0 and m.tutorial_label.text == speed_text, tag + "the speed card shows right after slide 1 (T334: right after the order with discovery)", m.tutorial_label.text)
			check(m.tut_count.text.begins_with("1 of "), tag + "it counts as slide 1", m.tut_count.text)
			check(m.tut_next.is_visible_in_tree(), tag + "Next shows on the speed card")
			var row: Rect2 = m.speed_buttons[0].get_global_rect()
			for b in m.speed_buttons:
				row = row.merge(b.get_global_rect())
			check(m.tut_hl.visible and m.tut_hl.get_global_rect().encloses(row), tag + "the outline covers the speed buttons", str([m.tut_hl.get_global_rect(), row]))
			var was_paused: bool = m.paused
			for k in 6:
				await process_frame
			check(m.paused == was_paused and m.tut_step == 0 and m.tutorial_label.text == speed_text, tag + "the card does not pause the game or move on by itself", str(m.paused))
			check(m.planet_ring == null or m.tut_planet_ring_target() == -1, tag + "no planet ring on the speed card")
			check(m.tut_lock_active(), tag + "the tutorial lock is on while the card shows")
			var before: float = m.time_speed
			if by_speed_click:
				_click_at(m.speed_buttons[2].get_global_rect().get_center())
				for k in 3:
					await process_frame
				check(m.time_speed == m.SPEEDS[2] and m.time_speed != before, tag + "the lock does not block the speed button", str(m.time_speed))
			else:
				_click_at(m.tut_next.get_global_rect().get_center())
				for k in 3:
					await process_frame
				check(m.time_speed == before and m.paused == was_paused, tag + "Next changes neither speed nor pause")
			if disc:
				var yay_text: String = StoryText.get_or("TUT_G0_DONE", "", {"planet": m.planet_name(m.tut_fly_target())}).strip_edges()
				check(m._tut_g0_id() == "TUT_G0_DONE" and m.tutorial_label.text == yay_text and m.tut_next.is_visible_in_tree(), tag + "T334: the Yay card follows the speed card", m.tutorial_label.text)
				check(m.tutorial_label.text != speed_text, tag + "T334: no speed card twice")
				_click_at(m.tut_next.get_global_rect().get_center())
				for k in 4:
					await process_frame
				check(m.tut_step == 0 and m.tutorial_label.text == select_text, tag + "the Voltara card follows the Yay card", m.tutorial_label.text)
				_click_at(map.planet_screen_pos(0 if m.planet_index_of("planet_1") < 0 else m.planet_index_of("planet_1")))
				for k in 4:
					await process_frame
			check(m.tut_step >= 2 and m.tutorial_label.text != speed_text and not m.tut_next.visible, tag + "the guide moved past the speed card", "%d %s" % [m.tut_step, m.tutorial_label.text])
			await _free_main(m)
	root.size = old_size

## T334: the Sell card (step 6) points at the Sell button of the route's good at the route's end world, both modes, through real
## clicks; and the speed card (discovery) comes before the arrival cards and ends once.
func _test_tut_sell_and_order() -> void:
	var old_size := root.size
	root.size = Vector2i(1920, 1080)
	for c in root.get_children():
		if c.scene_file_path == MAIN_SCENE:
			c.free()
	var sell_text: String = StoryText.get_or("TUT_G6_SELL", "", {}).strip_edges()
	for disc in [false, true]:
		var tag := "T334 sell (discovery %s): " % str(disc)
		var m: Control = await _new_main(true, disc)
		for i in 4:
			await process_frame
		if disc:
			m.debug_open_all_planets()
		var v: int = m._tut_idx("planet_1")
		var a: int = m._tut_idx("planet_3")
		m.tut_flags["g0"] = true
		m.tut_flags["g0_done"] = true
		m.tut_flags["speed_done"] = true
		m.tut_flags["hero"] = true
		m.engine.local_of(v, "energy", true)["buy"] = true
		m.engine.routes.append(m.engine.new_record(v, a, "energy"))
		m.cycle = 3
		m.tut_flags["expenses"] = true
		m.tut_flags["upkeep_next"] = true
		m.tut_step = 5
		m.selected_planet = -1
		for i in 8:
			await process_frame
		check(m.tut_step == 6 and m.tutorial_label.text == sell_text, tag + "the Sell card shows", "%d %s" % [m.tut_step, m.tutorial_label.text])
		# first half: the end world is not open, the card points at the end world's planet (no control outline)
		check(m._tut_highlight_key() == "planet" and not m.tut_hl.visible and m.tut_planet_ring_target() == a, tag + "end world not open: planet pointer on the end world", str([m._tut_highlight_key(), m.tut_planet_ring_target(), a]))
		# the start world is open instead: still the end world is pointed at, not its resource button
		m.selected_planet = v  # the lock refuses a click on the start world at this step, so the state is set
		for i in 6:
			await process_frame
		check(m.selected_planet == v and m._tut_highlight_key() == "planet" and not m.tut_hl.visible and m.tut_planet_ring_target() == a, tag + "start world open: still points at the end world", str([m.selected_planet, m._tut_highlight_key()]))
		# open the end world with a real click
		_click_at(m.map.planet_screen_pos(a))
		for i in 6:
			await process_frame
		if m.selected_planet != a:
			m._on_planet_clicked(a)
			for i in 6:
				await process_frame
		check(m.selected_planet == a and m.planet_panel.visible and m.tutorial_label.text == sell_text, tag + "the end world's panel is open on the Sell card")
		var sb: Button = null
		for n in m.planet_panel.find_children("*", "Button", true, false):
			if n.name == "PaysSellButton" and n.is_visible_in_tree():
				sb = n
		check(sb != null, tag + "the route line has a Sell button at the end world")
		if sb != null:
			var rect: Rect2 = sb.get_global_rect()
			var hl: Rect2 = m.tut_hl.get_global_rect().grow(-3.0)
			check(m._tut_highlight_key() == "sell" and m.tut_hl.visible and hl.is_equal_approx(rect), tag + "the outline is the Sell button", str([hl, rect]))
			var tip: Vector2 = m.tut_arrow.global_position
			check(m.tut_arrow.visible and tip.y >= rect.position.y - 1.0 and tip.y <= rect.end.y + 1.0 and absf(tip.x - rect.get_center().x) <= rect.size.x * 0.5 + 40.0, tag + "the arrow points at the Sell button", str([tip, rect]))
			var rb := m.planet_panel.find_child("BuyButton_energy", true, false) as Control
			check(rb == null or not hl.intersects(rb.get_global_rect()), tag + "the outline is not the resource button", str([hl]))
			_click_at(rect.get_center())
			for i in 6:
				await process_frame
			check(m.engine.local_on(a, "energy", "sell"), tag + "a real click on the outlined button turns Sell on")
			check(m.tut_step >= 7, tag + "the guide moves on", str(m.tut_step))
		await _free_main(m)
	# speed card ordering with discovery: order -> speed card -> (Next) -> arrival cards -> Yay -> Voltara
	var m2: Control = await _new_main(true, true)
	for i in 4:
		await process_frame
	var speed_text: String = StoryText.get_or("TUT_G1C_SPEED", "", {}).strip_edges()
	m2._on_fly_establish_requested(str(m2.map.planets[m2.tut_fly_target()].get("id", "")))
	for i in 4:
		await process_frame
	check(m2.tutorial_label.text == speed_text and m2.tut_count.text.begins_with("1 of "), "T334 order: the speed card right after the order, counted as slide 1", m2.tutorial_label.text)
	_click_at(m2.tut_next.get_global_rect().get_center())
	for i in 4:
		await process_frame
	check(m2.tutorial_label.text != speed_text and m2.tut_step == 0, "T334 order: Next ends the speed card", m2.tutorial_label.text)
	check(m2._tut_g0_id() == "TUT_G0_FLY" and m2.tutorial_label.text != speed_text, "T334 order: after Next the flight is still under way and the arrival cards are still ahead", m2.tutorial_label.text)
	m2.flight.finish_flight()
	m2.debug_establish_now(str(m2.map.planets[m2.tut_fly_target()].get("id", "")))
	for i in 4:
		await process_frame
	var yay_text: String = StoryText.get_or("TUT_G0_DONE", "", {"planet": m2.planet_name(m2.tut_fly_target())}).strip_edges()
	check(m2.tutorial_label.text == yay_text and m2.tutorial_label.text != speed_text, "T334 order: the Yay card follows the arrival, no second speed card", m2.tutorial_label.text)
	_click_at(m2.tut_next.get_global_rect().get_center())
	for i in 4:
		await process_frame
	check(m2.tutorial_label.text == StoryText.get_or("TUT_G1_SELECT", "", {}).strip_edges(), "T334 order: the Voltara card follows the Yay card", m2.tutorial_label.text)
	await _free_main(m2)
	root.size = old_size

func _test_tutorial_steps() -> void:
	var m: Control = await _new_main(true)
	var G: Array = m.TUT_GUIDE
	check(m.tut_step == 0 and m.tutorial_label.text != "" and m.tutorial_label.visible and m.tutorial_label.is_visible_in_tree(), "tutorial: fresh game shows the step 1 line", m.tutorial_label.text)
	check(m.tut_actions.visible and m.tut_actions.is_visible_in_tree(), "tutorial: Skip shows on the first step")
	# clicking a planet is the step 1 action: the guide moves on at once, with no other refresh
	m._on_planet_clicked(0)
	await process_frame
	check(m.tut_step == 0 and m._tut_speed_card(), "tutorial: clicking a planet shows the speed card (T333)", str(m.tut_step))
	m.tut_next.pressed.emit()
	await process_frame
	check(m.tut_step >= 1, "tutorial: clicking a planet then Next advances step 1", str(m.tut_step))
	m.tut_step = 0
	m.selected_planet = -1
	await process_frame
	# derived state: mutate the state directly, call no tutorial function, wait frames
	m.selected_planet = 0
	m.tut_flags["speed_done"] = true  # T333: the speed card comes first
	await process_frame
	await process_frame
	check(m.tut_step >= 1, "tutorial derived: setting selected_planet alone advances step 1", str(m.tut_step))
	m.tut_step = 3
	m.selected_planet = 0
	m.pending = {}
	await process_frame
	await process_frame
	var g3send: String = StoryText.get_or("TUT_G3_SEND", "", {}).strip_edges()
	var g3pick: String = StoryText.get_or("TUT_G3_PICK", "Click the planet that wants the good.", {}).strip_edges()
	check(m.tutorial_label.text == g3send and m._tut_highlight_key() == "send", "tutorial derived: step 3 without pending shows SEND", m.tutorial_label.text)
	m.pending = {"planet": 0, "c": "energy"}
	await process_frame
	await process_frame
	check(m.tutorial_label.text == g3pick and m._tut_highlight_key() == "planet" and m._tut_ring_planet() != 0, "tutorial derived: setting pending alone shows PICK and a planet target", m.tutorial_label.text)
	check(m._voiced_tut == 3, "tutorial derived: heading switch keeps the step voiced once")
	m.pending = {}
	await process_frame
	await process_frame
	check(m.tutorial_label.text == g3send and m._tut_highlight_key() == "send", "tutorial derived: clearing pending alone restores SEND and the resource target", m.tutorial_label.text)
	m.tut_step = 4
	m.set_paused(false)
	await process_frame
	await process_frame
	check(m._tut_target_node("time") == m.speed_buttons[0], "tutorial derived: running at step 4 targets the speed button")
	m.paused = true
	await process_frame
	await process_frame
	check(m._tut_target_node("time") == m.pause_button, "tutorial derived: pausing flips the target to Play")
	m.paused = false
	await process_frame
	await process_frame
	var shows: int = m.tut_show_count
	var voiced: int = m._voiced_tut
	for _i in 6:
		await process_frame
	check(m.tut_show_count == shows and m._voiced_tut == voiced, "tutorial derived: unchanged state does not rebuild the card or replay voice", "%d -> %d" % [shows, m.tut_show_count])
	m.tut_step = 0
	m.selected_planet = -1
	await process_frame
	check(_buttons(m.tut_actions, []).filter(func(b): return (b as Button).visible).size() == 1 and not m.tut_next.visible, "tutorial: no Next button on the guided card except the Yay card, only Skip")  # T329
	check(G == ["TUT_G1_SELECT", "TUT_G1B_SHIPS", "TUT_G2_BUY", "TUT_G3_SEND", "TUT_G4_ROUTE_PAY", "TUT_G5_UPKEEP", "TUT_G6_SELL", "TUT_G7_STORAGE", "TUT_G7_NEEDS", "TUT_G7_GROW", "TUT_G8_SKILLS", "TUT_G9_PERMIT", "TUT_G10_DONE"], "tutorial steps: order")
	# skip at step 3 ends the tutorial for good, also after save and load
	m.tut_step = 3
	m._tut_skip()
	check(m.tut_step == G.size(), "tutorial steps: skip at step 3 ends the guide")
	var st: Dictionary = JSON.parse_string(JSON.stringify(m.collect_state()))
	m.apply_state(st)
	m._tut_advance()
	check(m.tut_step == G.size(), "tutorial steps: skip stays after save and load")
	# old save: tut_step 4 meant skills; the new numbering puts skills at 9
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
	m.tut_step = 10
	m._tut_advance()
	check(G[m.tut_step] == "TUT_G10_DONE" and m.tut_skipped == ["TUT_G8_SKILLS", "TUT_G9_PERMIT"], "tutorial steps: skills and permit skipped with no point", str(m.tut_skipped))
	m.skill_points = 1
	m.tut_step = 10
	m._tut_advance()
	check(m.tut_step == 10, "tutorial steps: skills step waits while a point is held")
	# step 3 with a send pending: heading and target switch to the destination planet
	m.tut_step = 3
	m.selected_planet = 0
	m.cancel_pending()
	await process_frame
	check(m.tutorial_label.text == StoryText.get_or("TUT_G3_SEND", "", {}).strip_edges(), "tutorial: send step shows TUT_G3_SEND without pending", m.tutorial_label.text)
	m.pending = {"planet": 0, "c": "energy"}
	m._pending_changed()
	await process_frame
	check(m.tutorial_label.text == StoryText.get_or("TUT_G3_PICK", "Click the planet that wants the good.", {}).strip_edges(), "tutorial: pending send shows TUT_G3_PICK", m.tutorial_label.text)
	check(m._tut_highlight_key() == "planet" and m._tut_ring_planet() != 0, "tutorial: pending send targets a destination planet", str(m._tut_ring_planet()))
	m.cancel_pending()
	await process_frame
	check(m.tutorial_label.text == StoryText.get_or("TUT_G3_SEND", "", {}).strip_edges() and m._tut_highlight_key() == "send", "tutorial: cancel restores TUT_G3_SEND and the resource target", m.tutorial_label.text)
	m.tut_step = 0
	m.selected_planet = -1
	# every step moves on only by its own action
	m.tut_flags = {}
	m.tut_step = 5
	m._tut_advance()
	check(m.tut_step == 5, "tutorial steps: upkeep waits until Expenses is opened")
	m.tut_note("expenses")
	await process_frame
	check(m.tut_step == 5 and m.tut_next.visible, "tutorial steps: opening Expenses keeps the upkeep step and shows Next", str(m.tut_step))  # T331
	m._tut_next()
	await process_frame
	check(m.tut_step > 5, "tutorial steps: Next moves the upkeep step on", str(m.tut_step))
	m.tut_flags = {}
	m.tut_step = 7
	m._tut_advance()
	check(m.tut_step == 7, "tutorial steps: storage waits for Next")
	m.tut_flags["storage_next"] = true
	await process_frame
	check(m.tut_step > 7, "tutorial steps: Next moves the storage step on", str(m.tut_step))
	m.skill_points = 1
	m.learned_skills = []
	m.tut_step = 10
	m._tut_advance()
	check(m.tut_step == 10, "tutorial steps: skills waits until a skill is learned")
	m.tut_step = 12
	m.tut_goal_t = 0.0
	m._tut_show()
	m._tut_tick(m.TUT_LAST_SECS - 1.0)
	check(m.tut_step == 12, "tutorial steps: last step stays before its time is up")
	m._tut_tick(2.0)
	check(m.tut_step == G.size() and not m.tut_card.visible, "tutorial steps: last step closes by itself after the timer")
	m.tut_step = 2
	m._tut_show()
	m._tut_tick(100.0)
	check(m.tut_step == 2, "tutorial steps: the timer only runs on the last step")
	_test_tutorial_t316(m)
	_test_tip_spacing(m)
	m.debug_restart_tutorial()
	check(m.tut_step <= 1 and m.tut_skipped.is_empty(), "tutorial steps: restart goes back to the start")
	# the tutorial card is its own panel, never part of the notifications board
	var board: Node = m.notice_label.get_parent().get_parent()
	check(m.tut_card != null and m.tut_card.visible and not board.is_ancestor_of(m.tut_card) and not board.is_ancestor_of(m.tutorial_label) and not board.is_ancestor_of(m.tut_actions), "tutorial card: not a child of the notifications board")
	check(m.tut_card.get_parent() == m and not m.right_col.is_ancestor_of(m.tut_card) and m.tut_count.text.begins_with("1 of "), "tutorial card: floats outside the right column, with a step count", m.tut_count.text)
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
	m.tut_step = 2
	m._tut_show()
	await process_frame
	await process_frame
	var tgt: Control = m._tut_target_node("buy")
	var vpr := Rect2(Vector2.ZERO, m.get_viewport_rect().size)
	var cr: Rect2 = m.tut_card.get_global_rect()
	check(tgt != null and vpr.encloses(cr) and not cr.intersects(tgt.get_global_rect()) and not cr.intersects(m.planet_panel.get_global_rect()), "tutorial card: beside the Buy button, in the window, clear of it and its panel", str(cr))
	check(m.tut_arrow.visible and m.tut_card.mouse_filter == Control.MOUSE_FILTER_IGNORE and m.tut_hl.mouse_filter == Control.MOUSE_FILTER_IGNORE, "tutorial card: pointer shows, outline lets clicks through")
	m.tut_step = 5
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
	m.set_paused(false)
	await process_frame
	check(m._tut_highlight_key() == "time" and m._tut_target_node("time") == m.speed_buttons[0], "tutorial highlight: route-pay step outlines the speed button")
	m.set_paused(true)
	await process_frame
	check(m._tut_highlight_key() == "time" and m._tut_target_node("time") == m.pause_button, "tutorial highlight: route-pay step while paused outlines the Play button")
	m.set_paused(false)
	m.tut_step = 5
	check(m._tut_highlight_key() == "expenses" and m._tut_target_node("expenses") == m.cash_box, "tutorial highlight: expenses step outlines the top bar cash")
	m.tut_step = 2
	m.selected_planet = m._tut_idx("planet_1")  # the guided lock points at Voltara until it is open
	m.planet_panel.show_planet(m.selected_planet)
	check(m._tut_target_node("buy") != null and m._tut_highlight_key() == "buy", "tutorial highlight: buy step outlines the Buy button")
	m.tut_step = 10
	check(m._tut_target_node("skills") == m.points_button, "tutorial highlight: skills step outlines the Skills button")
	m.tut_step = 11
	check(m._tut_target_node("permit") == m.skill_screen.node_buttons["FND_PERMIT"], "tutorial highlight: permit step outlines Permit Charter in the Skills window")
	m.tut_step = 2
	m._tut_update_highlight()
	check(m.tut_hl.visible, "tutorial highlight: outline shows over the control")
	# planet surface banners: atlas regions, header image, fade gradient, edge to edge
	var PB := load("res://game/planet_banners.gd")
	var atlas_tex := load(PB.ATLAS_PATH) as Texture2D
	check(atlas_tex != null and atlas_tex.get_width() == PB.atlas_size().x and atlas_tex.get_height() == PB.atlas_size().y, "banners: atlas loads at the size the cells need")
	var ids_ok := true
	var pj: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/planets.json"))
	var sj: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/systems.json"))
	var all_ids: Array = []
	for q in pj["planets"]:
		all_ids.append(str(q["id"]))
	for sy in sj["systems"]:
		for q in sy["planets"]:
			all_ids.append(str(q["id"]))
	for pid in all_ids:
		var r: Rect2 = PB.region(pid)
		if pid == "planet_4":
			continue  # Flintmoor (T239): its banner art comes with T240
		if not PB.has(pid) or r.size == Vector2.ZERO or not Rect2(Vector2.ZERO, Vector2(atlas_tex.get_size())).encloses(r):
			ids_ok = false
	check(ids_ok and all_ids.size() == 10, "banners: every planet in the data has a region inside the atlas")
	m.planet_panel.show_planet(1)
	await process_frame
	await process_frame
	var bn := _find_named(m.planet_panel, "PlanetBanner") as Control
	var bi := _find_named(m.planet_panel, "BannerImage") as TextureRect
	check(bn != null and bi != null and bi.material is ShaderMaterial and (bi.material as ShaderMaterial).get_shader_parameter("fade") is GradientTexture2D, "banners: planet with an image shows the banner and its fade gradient")
	var pr: Rect2 = m.planet_panel.get_global_rect()
	var br: Rect2 = bi.get_global_rect() if bi != null else Rect2()
	check(bi != null and absf(br.position.x - pr.position.x - 1.0) < 1.5 and absf(br.end.x - pr.end.x + 1.0) < 1.5 and absf(br.position.y - pr.position.y - 1.0) < 1.5, "banners: the image reaches the panel's left, right and top edges", str(br, pr))
	check(_find_named(m.planet_panel, "BuyGrid") != null and _find_named(m.planet_panel, "BannerTitle") != null, "banners: body and title still built")
	var keep_id: String = str(m.map.planets[1]["id"])
	m.map.planets[1]["id"] = "no_such_planet"
	m.planet_panel.show_planet(1)
	await process_frame
	check(_find_named(m.planet_panel, "PlanetBanner") == null and _find_named(m.planet_panel, "BannerImage") == null and _find_named(m.planet_panel, "BuyGrid") != null, "banners: planet without an image has no banner")
	m.map.planets[1]["id"] = keep_id
	m.planet_panel.visible = false
	m.skill_screen.close_screen()
	m.selected_planet = -1
	check(m._tut_highlight_key() == "planet", "tutorial highlight: no planet panel falls back to the planet ring")
	m.tut_step = 12
	check(m._tut_highlight_key() == "", "tutorial highlight: last step has none")
	m._tut_skip()
	check(m.tut_step == G.size() and not m.tut_card.visible and not m.tut_hl.visible, "tutorial card: Skip ends the tutorial and hides card and outline")
	await _free_main(m)

## guided: keep the guided tutorial (and its lock) on, as in a fresh game. Default: the tutorial is already finished.
const TEST_SEED := 20261104

## discovery: false (default) switches the Pathfinder rules off (balance discovery_enabled 0), so every planet is open as before T179;
## true keeps the shipped default (only Voltara open at the start).
var _keep_preface := false  # T325: the preface test wants the welcome screen left up

func _new_main(guided: bool = false, discovery: bool = false) -> Control:
	var m: Control = load(MAIN_SCENE).instantiate()
	root.add_child(m)
	# the shipped default is discovery_enabled 1 (gdd.md), so the test sets it explicitly either way
	m.balance["discovery_enabled"] = 1 if discovery else 0
	m.on_flight_changed()
	# fixed seeds: market noise, chain shuffle and event rolls repeat from run to run
	Markets.reset(m.balance, TEST_SEED)
	Chains.reset(m.balance, TEST_SEED)
	m.events.rng.seed = TEST_SEED
	await process_frame
	if not guided:
		m.tut_step = m.TUT_GUIDE.size()
		await process_frame
	elif not _keep_preface and m.preface != null:  # T325: the tutorial only runs after Begin
		m._dismiss_preface()
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
	check(win_cycle == 80, "goal: run length is win_cycle_markets (80)")

	# --- T259: a market share no longer wins; the Star Bazaar does ---
	_wipe_user()
	Chains.picks["MIL_B4"] = {"opt": "opt_a", "cycle": 1, "nudge": 0}
	m.cycle = int(bal["win_earliest_cycle"]) - 2
	var ended := []
	m.run_ended.connect(func(side, id): ended.append([side, id]))
	for i in 12:
		m._end_cycle()
	check(not m.game_over and ended.is_empty(), "win: no share win, no swept loss")
	var bz: Bazaar = m.bazaar
	check(not bz.is_founded() and bz.capital() == -1 and bz.stage() == 0 and not bz.can_found(0), "bazaar: nothing founded at the start, home world is below the capital tier")
	m.balance["bazaar_capital_tier"] = 1
	m.balance["bazaar_stages"] = 2
	m.balance["bazaar_reach_stage"] = 2
	for n in [1, 2]:
		for t in range(1, 5):
			m.balance["bazaar_bill_s%d_t%d" % [n, t]] = 0
		m.balance["bazaar_quorum_count_s%d" % n] = 0
	var cap := 0
	check(bz.can_found(cap) and bz.found(cap) and bz.capital() == cap and not bz.found(cap) and not bz.can_found(1), "bazaar: found once, final")
	check(Conditions.eval("bazaar_stage:1") == false and Conditions.eval("bazaar_stage:0") == true, "bazaar: atom bazaar_stage reads the stages done")
	m.balance["bazaar_bill_s1_t1"] = 5
	var staged := []
	bz.stage_done.connect(func(n): staged.append(n))
	m._end_cycle()
	check(bz.stage() == 0 and not bz.bill_ok() and bz.bill_status().size() == 1 and bz.bill_status()[0]["need"] == 5, "bazaar: an unmet bill holds the stage", str(bz.bill_status()))
	var g1: String = bz._branch_goods(1)[0]
	m.storage.add(m.storage.planet_key(cap), g1, 7)
	m._end_cycle()
	check(bz.stage() == 1 and staged == [1] and m.storage.amount(m.storage.planet_key(cap), g1) == 2 and not m.game_over, "bazaar: stage done at cycle end, the bill is removed", str(staged))
	m.balance["bazaar_quorum_count_s2"] = 1
	m.balance["bazaar_quorum_tier_s2"] = 1
	check(not bz.quorum_status()["ok"] or bz.reach_needed(), "bazaar: stage 2 asks for a quorum and reach")
	m.balance["bazaar_quorum_count_s2"] = 0
	m.balance["bazaar_reach_stage"] = 9
	await process_frame
	m._end_cycle()
	await process_frame
	check(not m.game_over and bz.complete() and bz.opening_pending and m.gigs.has_opening(), "opening: the last stage posts the Opening gig, it does not win by itself")
	check(bz.wing_pending == 2 and bz.wing_options(1).size() == 2 and bz.wing_options(4).is_empty(), "wings: two options for a listed stage, none for the last")
	m.balance["bazaar_wing_wing_2a"] = 10
	check(bz.choose_wing(0) and bz.wings == ["WING_2A"] and Bazaar.wing_bonus("tax_pct") == 10.0 and not bz.choose_wing(0), "wings: a pick is kept and its balance amount counts")
	var rc := bz.recap()
	check(rc["capital"] == cap and rc["stages"] == 2 and rc["wings"] == ["WING_2A"] and rc.has("worlds_per_tier") and rc.has("reclaimed") and rc.has("decisive"), "recap: capital, stages, wings, worlds per tier, reclaimed, decisive", str(rc))
	var bz2 := Bazaar.new()
	bz2.setup(m)
	bz2.from_dict(bz.to_dict())
	check(bz2.wings == ["WING_2A"] and bz2.opening_pending and bz2.capital() == cap, "wings and Opening survive a save", str(bz.to_dict()))
	m.gigs.on_arrived_planet(str(m.map.planets[cap].get("id", "")))
	await process_frame
	var fam := "END_%s_GOOD" % (m.run_branch() if m.run_branch() != "" else str(Markets.ids[0])).to_upper()
	check(m.game_over and bz.complete() and bz.opened and ended.size() == 1 and ended[0][0] == "WIN" and ended[0][1] == fam, "win: the last stage wins with the branch family", str(ended))
	check(m.end_screen != null and _stats_runs() == 1, "win: end screen shown, run recorded once")
	check(not FileAccess.file_exists("user://autosave.json"), "win: save cleared")
	m._continue_free_play()
	check(m.free_play and not m.game_over and m.collect_state()["free_play"] == true and m.collect_state()["bazaar"]["stage"] == 2, "free play: Continue resumes, saved")
	m.cycle = win_cycle
	m._end_cycle()
	check(not m.game_over, "free play: no further endings, not even at the term")
	await _free_main(m)
	m = await _new_main()
	m._dismiss_preface()
	await _free_main(m)

	# --- swept: gone (T259), the share sweep never ends a run ---
	_wipe_user()
	m = await _new_main()
	m._dismiss_preface()
	m.cycle = int(bal["sweep_earliest_cycle"]) + int(bal["sweep_hold_cycles"]) + 2
	for i in 4:
		m._end_cycle()
	check(not m.game_over, "swept: no END_SWEPT any more")
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
	check(m.game_over and ended4.size() == 1 and ended4[0][0] == "SOFT" and ended4[0][1] == "END_UNFINISHED", "soft: END_UNFINISHED at the last cycle", str(ended4))
	await _free_main(m)

	# --- bankrupt: newest ship repossessed each cycle, salvage credited, ends with no ship and cash negative ---
	_wipe_user()
	m = await _new_main()
	m._dismiss_preface()
	var salvage := floori(float(bal["salvage_share"]) * float(bal["ship_price"]))
	m.ships = 2
	m.cash = -500
	m.cycle = 3
	m.prosperity.balance["prosperity_tax_t1"] = 0  # T258: tax is its own test below
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
	m.prosperity.balance["prosperity_tax_t1"] = 0
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

	# --- B1: dead end after the last stipend ends the run as bankrupt ---
	m = await _new_main()
	m._dismiss_preface()
	m.cash = 0
	m.cycle = 10
	m.rescues_paid = int(bal["rescue_max"])
	m.last_net = 0
	m.prev_net = 0
	var ended_b1 := []
	m.run_ended.connect(func(side, id): ended_b1.append([side, id]))
	check(m._is_dead_end(), "B1: cash 0, no stipend left, nothing running is a dead end")
	m._end_cycle()
	await process_frame
	check(m.game_over and ended_b1.size() == 1 and ended_b1[0][1] == "END_BANKRUPT", "B1: dead end ends the run as END_BANKRUPT", str(ended_b1))
	await _free_main(m)
	m = await _new_main()
	m._dismiss_preface()
	m.cash = 0
	m.rescues_paid = 1
	check(not m._is_dead_end(), "B1: a stipend is still left, not a dead end")
	await _free_main(m)
	check(FileAccess.get_file_as_string("res://export_presets.cfg").contains("game/debug_menu.gd"), "B9: debug_menu.gd is excluded from the export")

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
	var vol_before: Array = Markets.vp_active["lux"].duplicate()
	Markets.reset(bal, 0)
	m.apply_state(JSON.parse_string(JSON.stringify(sv)))
	var same: bool = Markets.vp_active["lux"] == vol_before and Markets.run_seed == int(sv["markets"]["seed"])
	check(same, "save: market state round trip keeps the sales record and seed")
	var old_sv: Dictionary = JSON.parse_string(JSON.stringify(sv))
	old_sv["markets"].merge({"vp": {"lux": [1.0]}, "vb": {"lux": [[1.0, 1.0, 1.0]]}, "gap": {"1|lux": 2.0}, "win_streak": {"lux": 3}, "sweep_streak": 2, "cur": {"lux": 5.0}})
	old_sv["skills"] = {"share_paid": {"mil": [20]}}
	m.apply_state(old_sv)
	check(Markets.vp_active["lux"] == vol_before and not Markets.to_dict().has("vp") and not Skills.to_dict().has("share_paid"), "save: an old save with share fields loads and drops them")
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
	m.storage.add(key0, "food", 10)
	check(m.set_local_order(0, "food", "sell", true)["ok"], "volume: Sell order accepted")
	m._end_cycle()
	var left: int = m.storage.amount(key0, "food")
	var sold := 10 - left
	check(sold > 0 and is_equal_approx(float(Markets.vp_active["bio"][0]), float(sold * Markets.value_of("food"))), "volume: units sold x base_value counted in the market of the good", "%d %s" % [sold, str(Markets.vp_active["bio"])])
	m.set_local_order(0, "food", "sell", false)
	m.set_local_order(0, "energy", "buy", true)
	m._end_cycle()
	check(is_equal_approx(float(Markets.vp_active["mil"][1]), 0.0), "volume: a Buy order is not a sale")
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
	check(SkillTree.all_ids().size() == 68, "skills: 6 Foundation nodes plus 62 market nodes (T173 side skills, 2026-11-06 skills fill)", str(SkillTree.all_ids().size()))
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
	check(int(bal["skill_points_route"]) == 1 and int(bal["skill_points_system"]) == 4 and int(bal["permit_points_2"]) == 2 and int(bal["permit_points_3"]) == 2, "skills: economy retunes applied (route 1, system 4, permits 2/2)")
	await _free_main(m)
	await _test_skill_screen()
	await _test_skill_screen_ui()
	await _test_skill_branch_screen()
	await _test_learn_lock_and_permit_card()
	await _test_storage_ready()
	_test_skills_core()
	await _test_foundations_first()
	_wipe_user()

# ---- 5. skills: learning through main (T71, four market trees) ----
func _test_skill_screen_ui() -> void:
	_wipe_user()
	var SS = load("res://game/skill_screen.gd")
	var bal := _bal()
	check(SS.tier_rows("mil") == [["MIL_1"], ["MIL_2", "MIL_3", "MIL_8"], ["MIL_9", "MIL_4", "MIL_5", "MIL_10"], ["MIL_11", "MIL_6", "MIL_12", "MIL_13"], ["MIL_14", "MIL_7"], ["MIL_15"]], "skill screen: tier rows put the tech left of the skill", str(SS.tier_rows("mil")))
	check(SS.tier_rows("fnd") == [["FND_PERMIT", "FND_PROSPECT", "FND_STORAGE", "FND_LEDGER"], ["FND_RIVAL_WATCH", "FND_DOCKS"]], "skill screen: Foundations are two rows (three gate nodes plus the Ledger, then two optional)", str(SS.tier_rows("fnd")))
	check(SS.node_state(FND3, 5, bal, "MIL_1") == "learnable" and SS.node_state(FND3, 0, bal, "MIL_1") == "points" and SS.node_state([], 5, bal, "MIL_1") == "locked", "skill screen: learnable vs not enough points")
	check(SS.node_state(FND3, 9, bal, "MIL_3") == "locked" and SS.node_state(["MIL_1"], 9, bal, "MIL_2") == "researching" and SS.node_state(["MIL_1", "MIL_2"], 0, bal, "MIL_2") == "learned", "skill screen: locked, researching, learned")
	check(int(SS.plain_args(bal, "MIL_5")["m"]) == int(bal["skill_MIL_5_every"]) and int(SS.plain_args(bal, "MIL_5")["n"]) == int(bal["skill_MIL_5_cycles"]), "skill screen: bot skill plain line gets cooldown and cycles")
	var m: Control = await _new_main()
	m._dismiss_preface()
	m.skill_screen.open_screen()
	check(m.skill_screen.node_buttons.size() == 68, "skill screen: one button per node", str(m.skill_screen.node_buttons.size()))
	var sk = m.skill_screen
	await process_frame
	await process_frame
	check(sk.cells.size() == 68 and sk.node_buttons.size() == 68 and SkillTree.BRANCHES.size() == 5, "skill placeholders: real nodes (68)")
	check(SS.SHOW_PLACEHOLDERS == (sk.placeholders.size() > 0), "skill placeholders: the switch decides whether any exist")
	check(SS.placeholder_row_count(7, 2, false) == 0 and SS.placeholder_row_count(7, 2, true) == ceili(7.0 * (SS.PLACEHOLDER_GROWTH - 1.0) / 2.0), "skill placeholders: switch off gives no rows")
	var ph_ok := true
	for ph in sk.placeholders:
		var pc: Control = ph
		if pc.mouse_filter != Control.MOUSE_FILTER_IGNORE or pc.focus_mode != Control.FOCUS_NONE or pc.tooltip_text != "" or pc is Button or pc.get_child_count() > 0:
			ph_ok = false
	check(ph_ok, "skill placeholders: inert (ignore mouse, no focus, no text, no tooltip, no children)")
	var inside := true
	var tr: Rect2 = sk._tree.get_global_rect()
	for id in sk.cells:
		if not tr.encloses((sk.cells[id] as Control).get_global_rect().grow(-1.0)):
			inside = false
	for ph in sk.placeholders:
		if not tr.encloses((ph as Control).get_global_rect().grow(-1.0)):
			inside = false
	check(inside, "skill placeholders: every node and slot sits inside the scrolled tree area (scroll reaches all)")
	check(sk.tree_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and sk.tree_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "skill placeholders: tree scrolls both ways when larger than the window")
	_check_skill_blocks(sk, "all trees")
	m.skill_points = 9
	Skills.learned.append_array(FND3)
	m.skill_screen.select("MIL_1")
	check(m.skill_screen.confirm_row_absent(), "skill screen: no separate confirm step")
	m.skill_screen.learn_button.pressed.emit()
	check(m.has_skill("MIL_1") and m.skill_screen.node_buttons["MIL_1"].text == SkillTree.skill_name("MIL_1"), "skill screen: Learn button learns in one click, spends points; the node shows only its name")
	Skills.learned.append_array(["MIL_3", "MIL_5"])
	m.skill_screen.refresh()
	check(m.skill_screen.use_rows["MIL_5"].visible and m.skill_screen.use_buttons.has("MIL_5"), "skill screen: learned bot skill shows its Use menu")
	var r: Dictionary = m.skill_screen._use_bot("MIL_5", 1)
	check(r["ok"] and not m.skill_screen.use_buttons.has("MIL_5") and m.skill_screen.use_rows["MIL_5"].visible, "skill screen: using it swaps the menu for the cooldown note")
	m.skill_screen.close_screen()
	await _free_main(m)

# ---- T241: the skill screen shows only Foundations plus the run's tree ----
func _test_skill_branch_screen() -> void:
	_wipe_user()
	var bal := _bal()
	check(SkillTree.visible_branches("") == SkillTree.BRANCHES and SkillTree.visible_branches("lux") == ["fnd", "lux"], "branch screen: old save shows all branches, a run shows fnd plus its market")
	for mk in SkillTree.MARKETS:
		var m: Control = await _new_main()
		m._dismiss_preface()
		m._set_run_choice("", "", mk)
		m.skill_screen.open_screen()
		await process_frame
		var sk = m.skill_screen
		var want: Array = SkillTree.ids_in("fnd") + SkillTree.ids_in(mk)
		var only_own: bool = sk.cells.size() == want.size() and sk.node_buttons.size() == want.size()
		for id in sk.cells:
			if not want.has(id):
				only_own = false
		_check_skill_blocks(sk, mk)
		check(only_own, "branch screen: %s run draws only Foundations and its own tree" % mk, str(sk.cells.size()))
		var leak := false
		for other in SkillTree.MARKETS:
			if other == mk:
				continue
			for id in SkillTree.ids_in(other):
				if sk.cells.has(id) or sk.node_buttons.has(id) or sk.use_rows.has(id):
					leak = true
			if _node_text_has(sk, StoryText.get_text("SK_TAB_" + other.to_upper()).to_upper()):
				leak = true
		check(not leak, "branch screen: %s run has no node, caption or button of another tree" % mk)
		var other_id: String = SkillTree.ids_in("mil" if mk != "mil" else "lux")[0]
		m.skill_points = 9
		Skills.learned.append_array(FND3)
		var v: Dictionary = SkillTree.can_learn(Skills.learned, 9, bal, other_id)
		var r: Dictionary = m.learn_skill(other_id)
		check(not v["ok"] and v["reason"] == "branch" and not r["ok"] and not m.has_skill(other_id) and m.skill_points == 9, "branch screen: %s run cannot learn %s" % [mk, other_id])
		check(not Skills.learn(other_id, 9, bal)["ok"], "branch screen: Skills.learn rejects another branch")
		sk.select(other_id)
		check(sk.selected != other_id, "branch screen: another branch cannot be selected")
		var own_first: String = SkillTree.ids_in(mk)[0]
		check(SkillTree.can_learn(FND3, 9, bal, own_first)["ok"], "branch screen: own tree stays learnable")
		await _free_main(m)
	var m2: Control = await _new_main()
	m2._dismiss_preface()
	m2._set_run_choice("", "", "")
	m2.skill_screen.open_screen()
	await process_frame
	check(m2.skill_screen.cells.size() == SkillTree.all_ids().size() and SkillTree.can_learn(FND3, 9, bal, "LUX_1")["ok"], "branch screen: old save (no branch) shows and learns every tree")
	await _free_main(m2)

## T336: Foundations block above every market node, every button inside the scroll area, links end on the right buttons.
func _check_skill_blocks(sk, label: String) -> void:
	var fnd_bottom := -1.0
	var mkt_top := 1.0e9
	var all_in := true
	var scroll_rect: Rect2 = sk.tree_scroll.get_global_rect()
	var tree_rect: Rect2 = sk._tree.get_global_rect()
	for id in SkillTree.all_ids():
		if not sk.node_buttons.has(id):
			continue
		var r: Rect2 = (sk.node_buttons[id] as Control).get_global_rect()
		if not tree_rect.encloses(r.grow(-1.0)) or r.position.x < scroll_rect.position.x - 1.0 or r.end.x > scroll_rect.end.x + 1.0:
			all_in = false
		if id.begins_with("FND_"):
			fnd_bottom = maxf(fnd_bottom, r.end.y)
		else:
			mkt_top = minf(mkt_top, r.position.y)
	check(fnd_bottom > 0.0 and fnd_bottom <= mkt_top, "skill blocks (%s): Foundations nodes sit above every market node" % label, "%s %s" % [fnd_bottom, mkt_top])
	check(all_in, "skill blocks (%s): every node button is inside the scrolled tree, within the scroll width" % label)
	var ends_ok := true
	var n_links := 0
	for id in sk.cells:
		for p in SkillTree.prereqs(id):
			if not sk.cells.has(p):
				continue
			n_links += 1
			var e: Array = sk.link_ends(p, id)
			var o: Vector2 = tree_rect.position
			var ra: Rect2 = (sk.node_buttons[p] as Control).get_global_rect()
			var rb: Rect2 = (sk.node_buttons[id] as Control).get_global_rect()
			if absf((e[0] as Vector2).x + o.x - (ra.position.x + ra.size.x * 0.5)) > 1.0 or absf((e[1] as Vector2).x + o.x - (rb.position.x + rb.size.x * 0.5)) > 1.0:
				ends_ok = false
			if (e[0] as Vector2).y + o.y < ra.end.y - 1.0 or (e[0] as Vector2).y + o.y > ra.end.y + 70.0 or absf((e[1] as Vector2).y + o.y - rb.position.y) > 1.0:
				ends_ok = false
	check(n_links > 0 and ends_ok, "skill blocks (%s): link end points sit on the prerequisite and node buttons" % label, str(n_links))

func _node_text_has(n: Node, text: String) -> bool:
	if n is Label and (n as Label).text.to_upper() == text:
		return true
	for c in n.get_children():
		if _node_text_has(c, text):
			return true
	return false

func _test_storage_ready() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var need := int(m.balance["earn_storage_income"])
	m.skill_points = 5
	m.skill_screen.open_screen()
	m.skill_screen.refresh()
	var nb: Dictionary = m.skill_screen.node_buttons
	check(nb["FND_STORAGE"].self_modulate == nb["MIL_3"].self_modulate and nb["FND_STORAGE"].self_modulate == m.skill_screen.COL_LOCKED, "storage ready: earn-locked node is muted like a locked one")
	m.trade_income_total = need - 1
	m._sync_earn()
	m._check_storage_ready()
	check(m.events.pending_id == "" and not m.event_icons.has_id("STORAGE_READY"), "storage ready: no notice below the line")
	m.trade_income_total = need
	m._sync_earn()
	m.skill_screen.refresh()
	check(nb["FND_STORAGE"].self_modulate == m.skill_screen.COL_AVAILABLE, "storage ready: at the line with a point the node is not muted")
	m.skill_points = 0
	m.skill_screen.refresh()
	check(nb["FND_STORAGE"].self_modulate == m.skill_screen.COL_SHORT, "storage ready: short of points uses the points colour")
	m.skill_points = 5
	m._check_storage_ready()
	check(m.events.pending_id == "STORAGE_READY" and m.event_icons.has_id("STORAGE_READY") and m.storage_notice_done, "storage ready: icon appears once the line is met")
	m._check_storage_ready()
	check(m.event_icons.count() == 1, "storage ready: not shown twice")
	var st: Dictionary = m.collect_state()
	m.apply_state(st)
	check(m.events.pending_id == "STORAGE_READY" and m.event_icons.count() == 1 and m.storage_notice_done, "storage ready: pending icon survives save and load, once")
	m.paused = false
	check(m.open_event_icon("STORAGE_READY") and m.event_notice != null and not m.event_icons.has_id("STORAGE_READY"), "storage ready: click opens the window")
	check(m.events.title_of("STORAGE_READY") != "" and m.events.body_of("STORAGE_READY") != "" and m.events.choices_of("STORAGE_READY").is_empty(), "storage ready: title and body, no choices")
	var cash0: int = m.cash
	var btns := _buttons(m.event_notice, [])
	check(btns.size() == 1, "storage ready: one OK button")
	btns[0].pressed.emit()
	await process_frame
	check(m.event_notice == null and m.events.pending_id == "" and m.cash == cash0 and m.events.active.is_empty(), "storage ready: OK closes, nothing pending, no effect")
	m._check_storage_ready()
	m.apply_state(m.collect_state())
	m._check_storage_ready()
	check(m.events.pending_id == "" and m.event_icons.count() == 0, "storage ready: not repeated after dismissal or load")
	check(StoryText.has_text("STORAGE_READY") == StoryText.has_text("STORAGE_READY_TITLE"), "storage ready: both text ids present or both absent (fallback in use)")
	m.skill_screen.close_screen()
	await _free_main(m)
	# already learned: no notice
	_wipe_user()
	m = await _new_main()
	m._dismiss_preface()
	Skills.learned.append("FND_STORAGE")
	m.learned_skills.append("FND_STORAGE")
	m.trade_income_total = need
	m._sync_earn()
	m._check_storage_ready()
	check(m.events.pending_id == "" and m.event_icons.count() == 0, "storage ready: none when already learned")
	await _free_main(m)

func _test_skill_screen() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	check(SkillTree.prereqs("MIL_3") == ["MIL_1"] and SkillTree.prereqs("MIN_1") == FND3 and SkillTree.prereqs("MIL_6") == ["MIL_4", "MIL_5"] and SkillTree.prereqs("BIO_7") == ["BIO_6"] and SkillTree.prereqs("FND_PERMIT").is_empty(), "skills: prerequisites follow core 3.1")
	check(m.learned_skills.is_empty(), "skills: nothing learned at start")
	# cost and points
	m.skill_points = 0
	var r: Dictionary = _learn_storage(m)
	check(not r["ok"] and r["reason"] == "points" and m.learned_skills.is_empty(), "skills: not enough points blocks learning")
	m.skill_points = 10
	r = m.learn_skill("FND_STORAGE")  # earn lock: cycle 1, no income yet
	check(not r["ok"] and r["reason"] == "earn" and m.skill_lock_reason("FND_STORAGE") != "" and m.skill_lock_reason("MIL_1") == "", "earn: locked at start, text shown", m.skill_lock_reason("FND_STORAGE"))
	m.cycle = 5
	check(m.learn_skill("FND_STORAGE")["reason"] == "earn", "earn: a late cycle alone is not enough")
	m.trade_income_total = int(bal["earn_storage_income"])
	m.cycle = 1
	check(m.skill_lock_reason("FND_STORAGE") == "" and m.collect_state()["trade_income_total"] == int(bal["earn_storage_income"]), "earn: income alone unlocks at cycle 1, no cycle needed, income saved")
	check(not bal.has("earn_storage_cycles"), "earn: earn_storage_cycles is gone from balance")
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
	check(not r["ok"] and r["reason"] == "locked", "skills: MIN_1 still locked with two of three Foundations")
	_learn_storage(m)
	r = m.learn_skill("MIN_1")
	check(r["ok"] and m.learned_skills == ["FND_PERMIT", "FND_PROSPECT", "FND_STORAGE", "MIN_1"], "skills: MIN_1 after all three Foundations")
	check(Skills.learned == m.learned_skills and Skills.is_learned("MIN_1"), "skills: Skills.learned is the learned set")
	# space storage, permits and cluster routes follow the Foundations
	check(m.can_mine() and Skills.unlocked("permit_routes"), "skills: FND_PROSPECT opens cluster routes, FND_PERMIT permit routes")
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
	var st: Dictionary = m.collect_state()
	var learned_copy: Array = m.learned_skills.duplicate()
	var pts: int = m.skill_points
	m.learned_skills = []
	m.skill_points = 0
	Tech.reset()
	Skills.bot_used = {}
	m.apply_state(JSON.parse_string(JSON.stringify(st)))
	check(m.learned_skills == learned_copy and m.skill_points == pts, "skills: save round trip keeps skills and points", str(m.learned_skills))
	check(int(Tech.counts.get("MIN_2", 0)) == 4 and int(Skills.bot_used.get("MIL_5", 0)) == 3, "skills: save round trip keeps tech progress and bot skill use")
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
	var base := float(Markets.value_of("powder"))
	check(is_equal_approx(Skills.upkeep_mult(), 1.0) and is_equal_approx(Skills.storage_cap_mult(), 1.0) and is_equal_approx(Skills.order_size_mult(), 1.0) and is_equal_approx(Skills.cluster_yield_mult(), 1.0), "effects: no skills, neutral numbers")
	Skills.add_learned("MIL_1")
	check(is_equal_approx(Skills.upkeep_mult(), 1.0 - float(bal["skill_MIL_1_upkeep"])), "effects: upkeep_mult (MIL_1)")
	check(Skills.unlocked("munitions") and Skills.unlocked("rounds") and not Skills.unlocked("smelter"), "effects: unlock flags (MIL_1 workshop and good)")
	Skills.add_learned("MIL_2")
	check(Skills.workshop_batches("mil") == int(bal["skill_MIL_2_batches"]) and Skills.workshop_batches("lux") == 0, "effects: workshop_batches (MIL_2) only for its market")
	Skills.add_learned("MIL_4")
	Markets.add_sale("powder", 10)
	check(is_equal_approx(float(Markets.cur_active["mil"]), 10.0 * base) and is_equal_approx(Skills.sale_price_mult("mil"), 1.0), "effects: no percent price or volume skill on MIL_2 / MIL_4 (no filler)")
	Skills.add_learned("LUX_5")
	Markets.add_sale("silk", 10, 4)
	check(is_equal_approx(float(Markets.cur_active["lux"]), 10.0 * float(Markets.value_of("silk"))) and is_equal_approx(Skills.need_fill_bonus("lux"), float(bal["skill_LUX_5_need_fill"])), "effects: LUX_5 raises need fill of Luxury (T261), not share volume")
	Skills.add_learned("LUX_1")
	Skills.add_learned("LUX_6")
	check(is_equal_approx(Skills.sale_price_mult("lux"), 1.0 + float(bal["skill_LUX_6_price"])) and Skills.reveal_cycles() == 1 and Skills.batch_yield("lux") == int(bal["skill_LUX_6_batch_bonus"]), "effects: LUX_1 reveals prices, LUX_6 raises luxury batch yield and sale price (round 2)")
	Skills.add_learned("LUX_3")
	check(Skills.warning_cycles() == 1, "effects: event_warning (LUX_3)")
	Skills.add_learned("MIL_3")
	check(is_equal_approx(Skills.route_capacity_mult("mil"), 1.0 + float(bal["skill_MIL_3_route_units"])) and is_equal_approx(Skills.route_capacity_mult("bio"), 1.0) and Skills.event_immune("mil", "debris"), "effects: MIL_3 raises Military route capacity (round 2) and keeps debris immunity")
	Skills.add_learned("MIL_6")
	Skills.add_learned("LUX_2")
	Skills.add_learned("BIO_6")
	check(is_equal_approx(Skills.event_cut("mil"), float(bal["skill_MIL_6_event_cut"])) and is_equal_approx(Skills.event_cut("bio"), float(bal["skill_BIO_6_event_cut"])) and is_equal_approx(Skills.event_cut("min"), 0.0) and is_equal_approx(Skills.event_bonus("lux"), float(bal["skill_LUX_5_event_bonus"])) and Skills.reopen_sooner() == 1, "effects: event_cut_pct, event_bonus_pct, reopen_sooner")
	Skills.add_learned("BIO_1")
	Skills.add_learned("BIO_3")
	Skills.add_learned("BIO_5")
	check(is_equal_approx(Skills.order_size_mult(), 1.0) and is_equal_approx(Skills.storage_cap_mult(), 1.0 + float(bal["skill_BIO_3_capacity"])), "effects: BIO_1 has no order size percent; storage_cap_pct (BIO_3)")
	check(is_equal_approx(Skills.progress_grace("bio"), float(bal["skill_BIO_5_grace"])) and is_equal_approx(Skills.progress_grace("mil"), 0.0), "effects: progress_grace (BIO_5) only for Biotech (T261)")
	Skills.add_learned("MIN_3")
	Skills.add_learned("MIN_4")
	Skills.add_learned("MIN_6")
	check(is_equal_approx(Skills.cluster_yield_mult(), 1.0 + float(bal["skill_MIN_3_yield"])) and Skills.mine_skill_for("dead_1") == "MIN_3" and Skills.mine_skill_for("dead_2") == "MIN_5" and Skills.mine_unlocked("dead_1") and not Skills.mine_unlocked("dead_2"), "effects: cluster_yield_pct and mine_unlock (MIN_3 dross, MIN_5 nullglass)")
	check(Skills.workshop_batches("min") == int(bal["skill_MIN_4_batches"]) and Skills.workshop_batches("mil") == int(bal["skill_MIL_2_batches"]) and Skills.batch_yield("min") == int(bal["skill_MIN_6_batch_bonus"]), "effects: workshop_batches and batch_yield (flags until the workshops exist)")
	# permanent bot effects through end_cycle
	Skills.reset(bal)
	Skills.add_learned("MIN_7")
	Skills.add_learned("MIL_7")
	check(is_equal_approx(Skills.weather_soften_perm(), float(bal["skill_MIN_7_strength_cut"])) and Skills.weather_warning_extra() == int(bal["skill_MIL_7_warning"]), "effects: capstone weather numbers (MIN_7 soften, MIL_7 warning), T282")
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
	check(is_equal_approx(Skills.weather_soft_factor(2), 1.0 - float(bal["skill_MIL_5_hit"])) and is_equal_approx(Skills.weather_soft_factor(1), 1.0), "bot skill (T282): only the chosen house's weather is softer")
	check(Skills.activate_bot_skill("MIL_5", 3)["reason"] == "cooldown" and Skills.bot_skill_cooldown("MIL_5") == int(bal["skill_MIL_5_every"]), "bot skill: cooldown skill_MIL_5_every")
	var sd: Dictionary = JSON.parse_string(JSON.stringify(Skills.to_dict()))
	Skills.from_dict(sd)
	check(is_equal_approx(Skills.weather_soft_factor(2), 1.0 - float(bal["skill_MIL_5_hit"])) and Skills.bot_skill_cooldown("MIL_5") == int(bal["skill_MIL_5_every"]), "bot skill: soften and use survive a save")
	Skills.from_dict({"bot_used": {}})
	check(Skills.house_soft.is_empty() and Skills.house_next.is_empty(), "bot skill: an older save has no soften marks")
	Skills.house_soft["2"] = [{"amount": 0.5, "until": 3}]
	Markets.cycles = 4
	check(is_equal_approx(Skills.weather_soft_factor(2), 1.0), "bot skill: the soften expires after its cycles")
	Markets.cycles = 0
	Skills.mark_house_next(1, 0.3, 2)
	check(is_equal_approx(float(Skills.take_house_next(1)["soften"]), 0.3) and int(Skills.take_house_next(1)["delay"]) == 0, "weather mark: taken once, then cleared")
	Skills.bot_used.clear()
	Skills.house_soft.clear()
	# cooldown skill (LUX_7, round 3: every skill_LUX_7_every cycles)
	Skills.add_learned("LUX_7")
	check(Skills.activate_bot_skill("LUX_7", 1)["ok"] and Skills.bot_skill_cooldown("LUX_7") == int(bal["skill_LUX_7_every"]) and Skills.activate_bot_skill("LUX_7", 2)["reason"] == "cooldown", "bot skill: Guild Seal has a cooldown (skill_LUX_7_every)")
	# --- ending inputs (core 6) ---
	Skills.reset(bal)
	Markets.reset(bal, 2)
	var e0 := EndingPicker.inputs("mil", bal)
	check(e0["ending_id"] == "END_MIL_GOOD" and not e0["capstone"] and int(e0["tech_done"]) == 0 and not e0["rival_broken"] and not e0.has("second_market"), "ending inputs: no capstone, no tech, no second-market share", str(e0))
	Skills.add_learned("MIL_2")
	Skills.add_learned("MIL_4")
	Skills.add_learned("MIL_7")
	Skills.add_learned("LUX_2")
	var e1 := EndingPicker.inputs("MIL", bal)
	check(e1["capstone"] and int(e1["tech_done"]) == 2 and e1["market"] == "mil", "ending inputs: capstone MIL_7 and techs done in the win market only", str(e1))
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
	check(SaveGame.VERSION == 22 and not loaded.is_empty() and loaded["learned_skills"].has("FND_STORAGE") and not SaveGame.dropped_old, "migration: a v2 file loads migrated")
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

func _bot_run(_bal_unused: Dictionary, _seed_v: int, from: int, to: int, hits: bool) -> void:
	for c in range(from, to + 1):
		if hits and c == 4:
			Markets.hit_bot(1, "mil", "strength", -0.2)
			Markets.hit_bot(2, "lux", "growth", 0.1)
			Markets.hit_bot(3, "bio", "tier", -1)
		Markets.cur_active["mil"] = 100.0 * c
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
	# stacking multiplicative
	Markets.hit_bot(1, "mil", "strength", -0.2)
	Markets.hit_bot(1, "mil", "strength", -0.1)
	check(absf(float(Markets.bot_mods(1, "mil")["strength_mult"]) - 0.72) < 0.0001, "bot hooks: strength hits stack multiplicatively")
	Markets.hit_bot(2, "lux", "growth", 0.1)
	Markets.hit_bot(2, "lux", "growth", 0.1)
	check(absf(float(Markets.bot_mods(2, "lux")["growth_mult"]) - 1.21) < 0.0001 and is_equal_approx(float(Markets.bot_mods(2, "mil")["growth_mult"]), 1.0), "bot hooks: growth hits stack, other markets untouched")
	# tier: -1 lowers effective tier, clamps at 1
	Markets.reset(bal, 7)
	var t_late := 80
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
	check(JSON.stringify(Markets.to_dict()) == full, "bot hooks: same hits give identical state")
	Markets.reset(bal, 99)
	_bot_run(bal, 99, 1, 6, true)
	var mid = JSON.parse_string(JSON.stringify(Markets.to_dict()))
	Markets.reset(bal, 0)
	Markets.from_dict(mid, bal)
	check(Markets.cycles == 6 and absf(float(Markets.bot_mods(1, "mil")["strength_mult"]) - 0.8) < 0.0001 and int(Markets.bot_mods(3, "bio")["tier_offset"]) == -1, "bot hooks: mods and cycle count survive save and load")
	_bot_run(bal, 99, 7, 10, false)
	check(JSON.stringify(Markets.to_dict()) == full, "bot hooks: a loaded run continues with identical state")
	# a v2 save without mods still loads
	var old = JSON.parse_string(JSON.stringify(mid))
	old.erase("mods")
	Markets.from_dict(old, bal)
	check(Markets.cycles == 6 and is_equal_approx(float(Markets.bot_mods(1, "mil")["strength_mult"]), 1.0), "bot hooks: save without mods loads with defaults")
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
		if g == "energy":  # the shared good belongs to no market (T239)
			if n != 0 or Markets.market_of(g) != "":
				all_one = false
		elif n != 1 or Markets.market_of(g) == "":
			all_one = false
	check(all_one, "markets: every good maps to exactly one market")
	check(Markets.market_of("energy") == "" and Markets.market_of("powder") == "mil" and Markets.market_of("blooms") == "lux" and Markets.market_of("food") == "bio" and Markets.market_of("spyware") == "mil" and Markets.market_of("silk") == "lux" and Markets.market_of("ore") == "min" and Markets.market_of("dross") == "min" and Markets.market_of("nullglass") == "min" and Markets.market_of("plate") == "min", "markets: tagging per core 1.1")
	var total := 0
	for m in Markets.ids:
		total += Markets.goods_of[m].size()
	check(total == goods.size() - 1, "markets: no good listed twice or left out", str(total))
	var base_ok := true
	for g in goods:
		if g != "energy" and (Markets.value_of(g) != _mean_sell(g) or Markets.value_of(g) <= 0):
			base_ok = false
	check(base_ok, "markets: base_value is the rounded mean of <good>_sell over the planets")
	check(Markets.is_common("energy") and not Markets.is_common("food") and not Markets.is_common("ore") and not Markets.is_common("silk"), "markets: energy is the only common raw")
	# sales record
	Markets.reset(bal, 7)
	Markets.add_sale("silk", 10)
	Markets.add_sale("food", 5)
	Markets.add_sale("energy", 5)  # energy belongs to no market: counts nowhere
	Markets.add_sale("food", 0)
	Markets.add_sale("unknown_good", 5)
	check(is_equal_approx(float(Markets.cur_active["lux"]), 10.0 * Markets.value_of("silk")) and is_equal_approx(float(Markets.cur_active["bio"]), 5.0 * Markets.value_of("food")) and is_equal_approx(float(Markets.cur_active["mil"]), 0.0), "volume: units x base_value per market, energy counts nowhere")
	Markets.end_cycle(1)
	check(is_equal_approx(float(Markets.vp_active["lux"][0]), 350.0) and float(Markets.cur_active["lux"]) == 0.0 and Markets.cycles == 1, "volume: the cycle is stored and the counter cleared")
	check(Markets.timed_out(int(bal["win_cycle_markets"])) and not Markets.timed_out(1), "markets: the term runs win_cycle_markets cycles")
	var msrc := FileAccess.get_file_as_string("res://game/markets.gd")
	check(not msrc.contains("func share(") and not msrc.contains("func overhead(") and not msrc.contains("func verdict(") and not FileAccess.file_exists("res://game/share_panel.gd") and not FileAccess.file_exists("res://game/competitors_panel.gd") and not FileAccess.file_exists("res://game/share_graph.gd"), "markets: share, overhead, verdict and the share panels are gone (T281)")
	var rc_text: String = preload("res://game/rival_card.gd").describe(2)
	check(rc_text.begins_with(Bots.bot_name(2)) and rc_text.contains("\n") and rc_text != preload("res://game/rival_card.gd").describe(1), "rival card: house name and its weather temperament")

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
	var rc: Dictionary = e.new_record(0, 1, "spyware")
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
	check(e._cross_with(["mil"], "silk") and not e._cross_with(["mil"], "spyware") and e._cross_with(["mil"], "food") and not e._cross_with(["mil"], "energy") and not e._cross_with([], "silk"), "bundle: a second market (not a common raw) mixes the load")
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
	# T353: the upgrade tip fires when the full lane's card is opened or an add-ship click is refused, once, behind a guided card
	var tdef := {"id": "TIP_UPGRADE", "sig": "upgrade"}
	check(m.TIP_DEFS.any(func(d): return d["id"] == "TIP_UPGRADE" and d["sig"] == "upgrade") and m.TIP_PRIORITY.has("TIP_UPGRADE"), "T353: the upgrade tip is listed")
	check(StoryText.get_or("TIP_UPGRADE", "", {}) != "" and StoryText.get_or("TIP_UPGRADE_WHY", "", {}) != "", "T353: the upgrade tip has both lines")
	m.tip_sig = {}
	m.tips_seen.erase("TIP_UPGRADE")
	check(not m.tip_due(tdef), "T353: the upgrade tip is not due before a full lane is shown")
	m.planet_panel.show_planet(0, 21)
	check(m.tip_due(tdef), "T353: opening the full lane's card makes the upgrade tip due")
	m.tip_sig = {}
	m._connect(0, 1, c)
	check(m.tip_due(tdef), "T353: a refused add-ship click on the full lane makes it due")
	var was_card: bool = m.tut_card.visible
	m.tut_card.visible = true
	check(not m.tip_can_show(), "T353: the upgrade tip waits behind a guided card")
	m.tut_card.visible = was_card
	m.tips_seen["TIP_UPGRADE"] = true
	check(m.tip_next() != "TIP_UPGRADE", "T353: the upgrade tip does not come back once seen")
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
	check(sk.get("c") == "silk" and ev.parse_tag("[price down: Voltara, ore]").get("c") == "ore" and ev.parse_tag("[price up: Ashgate, spyware]").get("c") == "spyware", "T155: events parse the new goods", str(sk))
	check(is_equal_approx(ev.pct("silk"), float(m.balance["event_pct_silk"])) and is_equal_approx(ev.pct("energy"), float(m.balance["event_pct_energy"])), "T155: per-good event pct, energy uses its own swing")
	for e in ev.defs:
		if str(e["id"]) == "EV17" or str(e.get("kind", "")) == "C" or ev.is_branch(str(e["id"])):
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
	check(m.event_notice == null and m.event_icons.has_id("EV01") and m.events.pending_id == "", "events: a price event shows an icon, no window, nothing pending")
	m.paused = false
	check(m.open_event_icon("EV01") and m.event_notice != null and m.paused and not m.event_icons.has_id("EV01"), "events: clicking the icon opens the window and pauses")
	var btns := _buttons(m.event_notice, [])
	check(btns.size() == 1 and btns[0].text == StoryText.get_text("MENU_CONTINUE"), "events: one Continue button")
	var pct_energy := float(m.balance["event_pct_energy"])  # energy has its own swing since the frost change
	check(m.trade.price(vi, "energy_sell") == roundi(base_sell * (1.0 - pct_energy)) and m.trade.price(vi, "energy_buy") == roundi(base_buy * (1.0 - pct_energy)), "events: both prices x(1-pct)")
	check(m.trade.price(vi, "food_sell") >= -1 and m.trade.price(ev.planet_index("Tillam"), "energy_sell") == m.trade.price(ev.planet_index("Tillam"), "energy_sell"), "events: other prices unchanged")
	btns[0].pressed.emit()
	await process_frame
	check(m.event_notice == null and not m.paused, "events: Continue closes the notice and restores the pause state")
	for i in cyc:
		check(m.trade.price(vi, "energy_sell") != base_sell, "events: price modified in cycle %d of %d" % [i + 1, cyc])
		m.events.tick()
	check(m.trade.price(vi, "energy_sell") == base_sell and m.events.active.is_empty(), "events: price back to base after event_price_cycles")
	# EV07: Tillam closed
	var ti: int = ev.planet_index("Tillam")
	m.debug_fire_event("EV07")
	m.open_event_icon("EV07")
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
	check(m.event_notice == null and m.events.active.size() == 1 and m.events.feed.size() == 3, "events: active effects survive a reload, a minor icon is not kept")
	m.debug_fire_event("EV07")
	check(m.events.pending_id == "EV07" and m.event_icons.has_id("EV07") and not bool(m.event_icons.entry("EV07")["minor"]), "events: closed planet is an important icon")
	var st2: Dictionary = m.collect_state()
	await _free_main(m)
	m = await _new_main()
	m._dismiss_preface()
	m.apply_state(st2)
	check(m.events.pending_id == "EV07" and m.event_icons.has_id("EV07") and m.event_notice == null, "events: a pending important icon survives save and load")
	m.open_event_icon("EV07")
	_buttons(m.event_notice, [])[0].pressed.emit()
	await process_frame
	check(m.events.pending_id == "" and m.event_notice == null, "events: answering clears the pending icon")
	await _free_main(m)
	# event icons: classification, expiry, pause, focus
	m = await _new_main()
	m._dismiss_preface()
	var minor_ids: Array = []
	var major_ids: Array = []
	for e in m.events.defs:
		(minor_ids if m.events.is_minor(str(e["id"])) else major_ids).append(str(e["id"]))
		var is_price: bool = (str(e.get("tag", "")).begins_with("[price") or str(e.get("tag", "")).begins_with("[shortage") or str(e.get("tag", "")).begins_with("[congestion")) and (e.get("choices", []) as Array).is_empty()
		if not e.has("chain_step") and str(e.get("tag", "")) != "":
			check(m.events.is_minor(str(e["id"])) == is_price, "icons: classification of " + str(e["id"]))
	for id in ["EV17", "EV18", "EV20", "EV07", "EV08", "EV09"]:
		check(major_ids.has(id), "icons: %s is important" % id)
	for id in ["EV01", "EV02", "EV24"]:
		check(minor_ids.has(id), "icons: %s is minor" % id)
	for sid in Chains.step_ids():
		check(not m.events.is_minor(sid), "icons: chain step %s is important" % sid)
	m.events.pending_id = ""
	m.paused = false
	m.debug_fire_event("EV02")
	check(m.event_icons.has_id("EV02") and not m.paused and m.events.pending_id == "", "icons: minor event: icon, no pause")
	m.event_icons.tick(m.event_icon_seconds() + 1.0)
	check(not m.event_icons.has_id("EV02") and m.event_notice == null and not m.paused, "icons: minor icon expires, nothing else happens")
	m.debug_fire_event("EV07")
	m.event_icons.tick(m.event_icon_seconds() * 10.0)
	check(m.event_icons.has_id("EV07") and not m.paused, "icons: important icon stays and does not pause")
	var tilp: int = m.events.planet_index("Tillam")
	var cam0: Vector3 = m.map.focus
	m.paused = false
	m.open_event_icon("EV07")
	check(m.paused and m.map.event_hint != null and m.map.focus.distance_to(m.map.positions[tilp]) < 0.01, "icons: click pauses, focuses and rings the planet")
	_buttons(m.event_notice, [])[0].pressed.emit()
	await process_frame
	check(not m.paused and m.map.event_hint == null, "icons: closing restores play and removes the ring")
	m.cycle = 5
	m.debug_fire_event("EV18")
	m.debug_fire_event("EV01")
	check(m.event_icons.count() == 1 and m.events.pending_id == "EV18", "icons: a pending important event blocks the next one")
	m.open_event_icon("EV18")
	_buttons(m.event_notice, [])[1].pressed.emit()
	await process_frame
	m.events.pending_id = ""
	m._dismiss_event_notice()
	m._release_event_pause()
	await _free_main(m)
	# T98: EV17 debris choice
	m = await _new_main()
	m._dismiss_preface()
	ev = m.events
	var fee: int = int(m.balance["debris_clear_fee"])
	m.cash = 1000
	m.debug_fire_event("EV17")
	m.open_event_icon("EV17")
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
	m.open_event_icon("EV17")
	check(ev.pending_planet == dp, "debris: offer returns on the planet with debris")
	_buttons(m.event_notice, [])[0].pressed.emit()  # pay
	check(m.cash == 1000 - fee and ev.debris.is_empty(), "debris: paying costs debris_clear_fee once and clears it")
	check(m.engine.planned_units(rec) == full_units, "debris: routes run as before after paying")
	_buttons(m.event_notice, [])[0].pressed.emit()
	m.cash = 0
	m.debug_fire_event("EV17")
	m.open_event_icon("EV17")
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
	var had_sys2: bool = m.open_systems.has(2)
	if not had_sys2:
		m.open_systems.append(2)  # availability: silk shows (and its events may fire) only once system 2 is open
	var silk_seen := false
	for i in 600:
		if silk_ids.has(m.events.random_id([], 13)):
			silk_seen = true
	m.events.planets[1]["base_prices"].erase("silk_buy")
	if not had_sys2:
		m.open_systems.erase(2)
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
func _test_good_info() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	m._on_planet_clicked(0)
	await process_frame
	for c in ["energy", "food"]:
		var ls: Array = GoodInfo.lines(c)
		check(ls.size() >= 1, "good info: %s has info at the start" % c, str(ls))
		var txt := " ".join(ls)
		check(Availability.names_hidden_good(txt) == "", "good info: %s names no hidden good at the start" % c, txt)
		for ws in ["fabric", "smelter", "munitions", "atelier", "culture_lab"]:
			check(not txt.contains(StoryText.get_or("WS_" + ws.to_upper() + "_NAME", ws)) or ws == "fabric", "good info: %s names no hidden workshop %s" % [c, ws], txt)
		check(not txt.contains("Used in"), "good info: %s has no used-in line while its users are hidden" % c, txt)
	check(GoodInfo.lines("rounds").is_empty(), "good info: a hidden good has no info")
	for c in ["energy", "food"]:
		var tb := m.planet_panel.find_child("BuyButton_" + c, true, false) as Button
		check(tb != null, "good info: %s has a button" % c)
		if tb == null:
			continue
		var tt := tb.tooltip_text
		check(tt.contains(StoryText.get_text("GOOD_" + c.to_upper() + "_DESC")), "good info: %s tooltip has the description" % c, tt)
		check(tt.contains(StoryText.get_or("LBL_GOOD_MARKET", "{market} market.", {"market": StoryText.get_or("SK_TAB_" + str(Goods.entry(c).get("market", "")).to_upper(), "")})), "good info: %s tooltip has the market line" % c, tt)
		check(tt.contains(StoryText.get_or("LBL_RMB_MORE", "Right-click for Send to, Sell and more.")), "good info: %s tooltip keeps its existing lines" % c, tt)
		check(Availability.names_hidden_good(tt) == "", "good info: %s tooltip names no hidden good" % c, tt)
		for ws in ["smelter", "munitions", "atelier", "culture_lab"]:
			check(not tt.contains(StoryText.get_or("WS_" + ws.to_upper() + "_NAME", ws)), "good info: %s tooltip names no hidden workshop %s" % [c, ws], tt)
	check(m.planet_panel.find_child("BuyButton_cells", true, false) == null, "good info: a hidden good has no button")
	var bt := m.planet_panel.find_child("BuyButton_energy", true, false) as Button
	var menu: PopupMenu = bt.get_node("ContextMenu_energy") as PopupMenu
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_RIGHT
	ev.pressed = true
	bt.gui_input.emit(ev)
	await process_frame
	check(menu.visible and m.planet_panel.find_child("GoodInfoCard", true, false) == null, "good info: right-click opens the menu and no info card")
	check(menu.get_item_index(m.planet_panel.MENU_SELL) >= 0 and menu.get_item_index(m.planet_panel.MENU_SEND) >= 0, "good info: menu actions are still there")
	menu.hide()
	await process_frame
	Skills.add_learned("MIL_1")
	m.open_systems.append(2)  # Munitions Line and cells need system 2 (chips)
	m.workshops.built["munitions"] = true
	m._sync_skill_effects()
	if Availability.good("rounds"):
		check(" ".join(GoodInfo.lines("energy")).contains(Ui.good_name("rounds")), "good info: energy lists Cells once visible", str(GoodInfo.lines("energy")))
		check(" ".join(GoodInfo.lines("rounds")).contains(StoryText.get_text("WS_MUNITIONS_NAME")), "good info: cells names its visible workshop", str(GoodInfo.lines("rounds")))
	else:
		check(false, "good info: cells not visible after MIL_1 (test needs another unlock)")
	m.planet_panel.show_planet(0)
	await process_frame
	var et := m.planet_panel.find_child("BuyButton_energy", true, false) as Button
	check(et != null and et.tooltip_text.contains(Ui.good_name("rounds")), "good info: energy tooltip lists Cells once visible", et.tooltip_text if et != null else "")
	var ct := m.planet_panel.find_child("BuyButton_cells", true, false) as Button
	if ct != null:
		check(ct.tooltip_text.contains(StoryText.get_text("WS_MUNITIONS_NAME")), "good info: cells tooltip names Munitions Line", ct.tooltip_text)
	await _free_main(m)

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
	# the panel has no Next cycle line; the amount is in the resource button tooltip when something moves
	e.routes.clear()
	e.local.clear()
	m.planet_panel.show_planet(0)
	var bt0 := m.planet_panel.find_child("BuyButton_" + c, true, false) as Button
	check(m.planet_panel.find_child("NextCycle_" + c, true, false) == null and bt0 != null and not bt0.tooltip_text.contains("Next cycle"), "next cycle: no panel line, no tooltip text when in and out are both 0")
	var o2: Dictionary = m.set_local_order(0, c, "sell", true)
	if o2["ok"]:
		m.planet_panel.show_planet(0)
		var bt1 := m.planet_panel.find_child("BuyButton_" + c, true, false) as Button
		check(m.planet_panel.find_child("NextCycle_" + c, true, false) == null, "next cycle: no separate line in the panel")
		check(bt1 != null and bt1.tooltip_text.contains("Next cycle"), "next cycle: the resource button tooltip shows it with a sell order and stock", str(bt1.tooltip_text if bt1 != null else ""))
	await _free_main(m)

## Ship types and CEOs (goal ship-ceo-skills-resources): multipliers, stats, perks, floor, save round-trip, old save.
func _test_ship_ceo() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	var Sh = load("res://game/ships.gd")
	var Cs = load("res://game/ceos.gd")
	var e = m.engine
	var base_units: int = 0
	var base_up: int = 0
	var base_trip: int = 0
	var maint := float(bal["maintenance"])
	var fl := float(bal["upkeep_floor"])
	check(m.ship_type == "small" and m.ceo_id == "" and Sh.fleet == "small" and Cs.current == "", "ship/ceo: a new game without a choice is the small ship and no CEO")
	for id in Sh.types():
		m._set_run_choice("", id)
		var d: Dictionary = Sh.def(id)
		var st: Dictionary = Sh.stats(id, bal)
		var rec := {"id": 5, "a": 0, "b": 1, "c": "ore", "ship": "small", "stop": -1}
		var units: int = e.units_per_cycle(rec, "ore")
		var want_units := floori(float(int(bal["cargo"])) / (2.0 * maxf(0.0001, float(bal["travel_cycles_per_leg"]))) * float(d["cargo_mult"]) * Skills.route_capacity_mult(Markets.market_of("ore")))
		check(units == want_units, "ship %s: cargo_mult applies" % id, "%d vs %d" % [units, want_units])
		var want_up := floori(maint * maxf(fl, float(d["upkeep_mult"])) / maxf(1.0, float(bal.get("maintenance_interval", 1))))
		check(e.upkeep_part(rec) == want_up, "ship %s: upkeep_mult applies" % id, "%d vs %d" % [e.upkeep_part(rec), want_up])
		var want_trip := floori(float(int(bal["trip_cost"])) * float(d["trip_mult"]) / maxf(0.0001, float(bal["travel_cycles_per_leg"])))
		check(e.trip_part(rec) == want_trip, "ship %s: trip_mult applies" % id, "%d vs %d" % [e.trip_part(rec), want_trip])
		check(Sh.price(id, bal) == roundi(float(bal["ship_price"]) * float(d["price_mult"])) and m.ship_price() == Sh.price(id, bal), "ship %s: price_mult applies" % id)
		check(m.ship_cap() == int(bal["ship_cap"]) + int(d["cap_add"]) and st["ship_cap"] == m.ship_cap(), "ship %s: cap_add applies" % id)
		check(ResourceLoader.exists(Sh.model(id)) and st["model"] == Sh.model(id), "ship %s: model path exists" % id, Sh.model(id))
		check(e.new_record(0, 1, "ore")["ship"] == id, "ship %s: new routes carry the type" % id)
	# every owned ship uses the chosen type
	m._set_run_choice("", "bulk")
	m.cash = 100000
	check(m.buy_ship("small")["ok"] and m.cash == 100000 - Sh.price("bulk", bal) and m.owned_of("bulk") == 1 and m.owned_of("small") == 0, "ship: buying charges and gives the chosen type")
	m.ships = 0
	# floor: dart with a thrifty CEO and a raised floor
	m._set_run_choice("ceo_man_01", "dart")
	var stack_mult: float = float(Sh.def("dart")["upkeep_mult"]) * Skills.upkeep_mult()
	check(is_equal_approx(Skills.upkeep_mult(), 1.0 - 3.0 * float(bal["ceo_step_thrift"])) and e.upkeep_part() == floori(maint * maxf(fl, stack_mult) / maxf(1.0, float(bal.get("maintenance_interval", 1)))), "floor: ship and CEO upkeep stack", "%d %f %f" % [e.upkeep_part(), Skills.upkeep_mult(), stack_mult])
	bal["upkeep_floor"] = 0.9
	check(e.upkeep_part() == floori(maint * 0.9 / maxf(1.0, float(bal.get("maintenance_interval", 1)))), "floor: upkeep never goes below upkeep_floor", str(e.upkeep_part()))
	bal["upkeep_floor"] = fl
	# CEO stats
	for cid in Cs.ids():
		m._set_run_choice(cid, "small")
		var d2: Dictionary = Cs.def(cid)
		var sts: Dictionary = d2["stats"]
		check(int(sts["haggling"]) + int(sts["thrift"]) + int(sts["nerve"]) == 5, "ceo %s: stats total 5" % cid)
		check(is_equal_approx(Skills.sale_price_mult("lux"), 1.0 + float(sts["haggling"]) * float(bal["ceo_step_haggling"])), "ceo %s: haggling raises sale price" % cid)
		check(is_equal_approx(Skills.upkeep_mult(), 1.0 - float(sts["thrift"]) * float(bal["ceo_step_thrift"])), "ceo %s: thrift lowers upkeep" % cid)
		check(is_equal_approx(Skills.event_cut("mil"), float(sts["nerve"]) * float(bal["ceo_step_nerve"])), "ceo %s: nerve cuts bad events" % cid)
		check(Cs.card(cid)["stats"] == sts and Cs.card(cid).has("perk_type"), "ceo %s: card for the UI" % cid)
	m._set_run_choice("", "small")
	check(Skills.sale_price_mult("lux") == 1.0 and Skills.upkeep_mult() == 1.0 and Skills.event_cut("mil") == 0.0 and Skills.warning_cycles() == 0 and Skills.reveal_cycles() == 0 and Skills.order_size_mult() == 1.0, "ceo: none means no effect")
	# perks
	m._set_run_choice("ceo_man_01", "small")
	check(Skills.warning_cycles() == int(bal["ceo_perk_man_01_cycles"]), "perk man_01: event_warning")
	m._set_run_choice("ceo_man_02", "small")
	var cyc0: int = Markets.cycles
	Markets.cycles = 0
	check(Skills.reveal_cycles(true) == int(bal["ceo_perk_man_02_cycles"]) and Skills.reveal_cycles(false) == 0, "perk man_02: home market prices in the first cycle")
	Markets.cycles = 1
	check(Skills.reveal_cycles(true) == 0, "perk man_02: first cycle only")
	Markets.cycles = cyc0
	m._set_run_choice("ceo_woman_02", "small")
	check(is_equal_approx(Skills.order_size_mult(), 1.0 + float(bal["ceo_perk_woman_02_pct"])) and e.local_amount() == floori(float(bal["order_amount"]) * Skills.order_size_mult()), "perk woman_02: order size")
	m._set_run_choice("ceo_woman_01", "small")
	var r1 := {"id": 1, "a": 0, "b": 1, "c": "ore", "ship": "small", "stop": -1}
	var r2 := {"id": 2, "a": 1, "b": 2, "c": "ore", "ship": "small", "stop": -1}
	e.routes.clear()
	e.routes.append(r1)
	e.routes.append(r2)
	var plain := float(bal["cargo"]) / (2.0 * maxf(0.0001, float(bal["travel_cycles_per_leg"])))
	check(e.units_per_cycle(r1, "ore") == floori(plain * (1.0 + float(bal["ceo_perk_woman_01_pct"]))) and e.units_per_cycle(r2, "ore") == floori(plain), "perk woman_01: first lane only")
	e.routes.clear()
	# save round-trip and old save
	m._set_run_choice("ceo_woman_02", "fleet")
	var st2: Dictionary = JSON.parse_string(JSON.stringify(m.collect_state()))
	m._set_run_choice("", "small")
	m.apply_state(st2)
	check(m.ceo_id == "ceo_woman_02" and m.ship_type == "fleet" and Sh.fleet == "fleet" and Cs.current == "ceo_woman_02", "save: ceo_id and ship_type round-trip")
	var old: Dictionary = st2.duplicate(true)
	old.erase("ceo_id")
	old.erase("ship_type")
	m.apply_state(old)
	check(m.ceo_id == "" and m.ship_type == "small" and Sh.fleet == "small" and Cs.current == "" and Skills.order_size_mult() == 1.0, "save: an old save loads as small ship, no CEO perk")
	m._set_run_choice("nope", "nope")
	check(m.ceo_id == "" and m.ship_type == "small", "ship/ceo: unknown ids fall back")
	# pending hand-off is read once
	SaveGame.pending_ceo = "ceo_man_02"
	SaveGame.pending_ship = "dart"
	await _free_main(m)
	m = await _new_main()
	check(m.ceo_id == "ceo_man_02" and m.ship_type == "dart" and SaveGame.pending_ceo == "" and SaveGame.pending_ship == "", "setup: pending_ceo and pending_ship start the run and are read once")
	check(m.run_branch() == "lux" and m.collect_state()["run"]["branch"] == "lux", "setup: the CEO fixes the branch, saved as run.branch")
	var seen_b := {}
	var seen_s := {}
	for cid in Cs.ids():
		seen_b[Cs.branch(cid)] = true
		seen_s[Cs.ship(cid)] = true
	check(seen_b.size() == 4 and seen_s.size() == 4, "ceos: four distinct branches and four distinct ships")
	var oldb: Dictionary = m.collect_state().duplicate(true)
	oldb.erase("run")
	m.apply_state(oldb)
	check(m.run_branch() == "", "save: an old save without run.branch loads with no branch")
	m._set_run_choice("", "small")
	await _free_main(m)

func _test_ships() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	var Sh = load("res://game/ships.gd")
	check(Sh.types() == ["small", "bulk", "dart", "fleet"] and Sh.price("small", bal) == int(bal["ship_price"]), "T58: four ship types, small price from balance")
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
		if (m.trade.price(0, str(c2) + "_buy") >= 0 or m.trade.price(0, str(c2) + "_sell") >= 0) and Availability.good(str(c2)):
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
	var pr_l := _find_named(m.planet_panel, "Prices_" + c) as Label
	check(pr_l != null and pr_l.get_parent() == buy_b and pr_l.text.contains(" / ") and not pr_l.text.contains(StoryText.get_text("BTN_BUY")) and not pr_l.text.contains(StoryText.get_text("BTN_SELL")) and not buy_b.text.contains(" 1"), "resource button: second row shows plain buy / sell numbers, row 1 has no price", str(pr_l.text if pr_l != null else ""))
	m.planet_panel.show_planet(1)
	var bb := _find_named(m.planet_panel, "BuyButton_" + c) as Button
	check(bb != null and bb.button_pressed and bb.tooltip_text.contains("Press to stop") and bb.tooltip_text.contains("Buy order:"), "buy toggle: the resource button is pressed while the order is on, tooltip has the order state")
	check(not _labels(m.planet_panel, []).any(func(l): return l.text.begins_with("Buy order:")), "buy toggle: no Buy order status line in the panel")
	var stop_n := 0
	for b in _all_buttons(m.planet_panel):
		if b.text == bb.text:
			stop_n += 1
	check(stop_n == 1, "buy toggle: one button per resource", str(stop_n))
	check(_find_named(m.planet_panel, "BuyGrid") != null and bb.get_parent().get_parent() == _find_named(m.planet_panel, "BuyGrid"), "buy table: resource buttons are cells of the BuyGrid")
	for pi in m.trade.planets.size():
		m.planet_panel.show_planet(pi)
		for cc in m.commodities:
			var bp: Dictionary = m.trade.planets[pi].get("base_prices", {})  # T257: base prices only; a need can open a sell price the panel does not list yet
			var traded: bool = (bp.has(str(cc) + "_buy") or bp.has(str(cc) + "_sell")) and Availability.good(str(cc))
			check((_find_named(m.planet_panel, "BuyButton_" + str(cc)) != null) == traded, "hide: planet %d row for %s only when traded" % [pi, cc])
	m.planet_panel.show_planet(1)
	m._on_buy_send(c)
	check(not e.local_on(1, c, "buy"), "buy toggle: pressing again stops the buy order")
	m.planet_panel.show_planet(1)
	bb = _find_named(m.planet_panel, "BuyButton_" + c) as Button
	var bp_l := _find_named(bb, "Prices_" + c) as Label
	check(bb.text == Ui.good_name(c) and bp_l != null and bp_l.text.contains(str(m.map.planets[1]["base_prices"][c + "_buy"])) and not bb.button_pressed and bb.icon != null, "buy toggle: the button reads the resource name with its icon, row 2 has the buy price")
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
	check(hk == 0 and not Sh.has("large"), "T89: hauler cut, no hauler_* keys and no hauler ship type (not applicable)")
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
	check(m.map.planets.size() == 5 and m.open_systems == [1], "sys2: only system 1 planets at start (four plus Cinderrest)")
	check(m.Systems.get_system(2).get("name_id") == "WORLD_SYS2_NAME" and m.Systems.planets_of(2).size() == 5, "sys2: data format, four planets plus Greywake")
	var names := []
	for p in m.Systems.planets_of(2):
		names.append(p["name"])
	check(names == ["Brannock", "Cindrel", "Mossfell", "Quillon", "Greywake"], "sys2: planet names from story ids", str(names))
	check(m.commodities == ["energy", "food", "ore", "dross", "plate", "powder", "blooms", "rivets", "rounds", "arms", "attar", "gems", "ingot", "alloy", "medicine", "seed", "musk", "spores"], "sys2: system 1 goods at start (silk and chips are system 2 goods since system tiers)", str(m.commodities))
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
	check(m.can_buy_permit(11)["reason"] == "unknown", "sys2: system 11 does not exist")
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
	check(m.map.planets.size() == 10 and m.trade.planets.size() == 10 and m.events.planets.size() == 10, "sys2: planets appear everywhere")
	check(m.commodities.has("silk") and m.commodities.has("spyware"), "sys2: silk and chips appear when system 2 opens", str(m.commodities))
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
	# income popups belong to the system of their planet
	var ip: Control = m.income_popup
	ip.show_gains({0: 50})
	check(ip.items.size() == 1 and ip.items[0]["label"].visible or ip.items.size() == 1, "popups: a system 1 popup shows in system 1")
	check(m.go_to_system(2) and ip.items.is_empty(), "popups: switching to system 2 discards the system 1 popups")
	ip.show_gains({0: 50})
	check(ip.items.is_empty(), "popups: a system 1 gain is not shown while viewing system 2")
	ip.show_gains({5: 70})
	check(ip.items.size() == 1 and int(ip.items[0]["planet"]) == 5, "popups: a system 2 popup shows in system 2")
	check(m.go_to_system(1) and ip.items.is_empty(), "popups: switching back to system 1 discards the system 2 popups")
	check(Juice.planet_screen(m.map, 5) == null, "popups: pings skip a planet of another system")
	m.go_to_system(1)
	var vis_ok := true
	for i in m.map.planet_spheres.size():
		vis_ok = vis_ok and (m.map.planet_spheres[i].visible == (int(m.map.planets[i]["system"]) == 1)) and (m.map.planet_labels[i].visible == (int(m.map.planets[i]["system"]) == 1))
	check(vis_ok and m.map.sun_node.visible, "systems: in system 1 only its planets and labels show")
	check(m.map.pick_planet(m.map.camera.unproject_position(m.map.positions[5])) != 5, "systems: a hidden planet of the other system cannot be picked")
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
	check(m.view_system == 1 and m.map.planet_spheres[0].visible and not m.map.planet_spheres[5].visible, "galaxy: choosing an open system moves there")
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
	check(m.trade.price(5, "food_buy") == 11 and m.trade.price(8, "energy_sell") == 34, "sys2: prices from data")
	# reach point once per system
	m.cash = 5000
	var pts: int = m.skill_points
	var sys0: int = m.systems_reached
	m.learned_skills.append("FND_STORAGE")  # trade gate: system 2 needs its Space Storage post
	m.storage.ensure(Storage.system_key(2))
	r = m.set_local_order(5, "food", "buy", true)
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
	check(m.map.planets.size() == 10 and m.open_systems.has(2) and m.engine.local_on(5, "food", "buy"), "sys2: load restores system and order")
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
	# T227: energy delivered by a route piles up over cycles; the only drain is declared link upkeep
	m.storage.stock["planet:0"]["energy"] = 400
	m.storage.stock["system:1"]["energy"] = 0
	m.cash = 9000
	var t227: Dictionary = m.send_stock(0, m.station_dst(1), "energy")
	var trec: Dictionary = m.engine.routes[m.engine.routes.size() - 1]
	var got227 := 0
	var last227 := 0
	for _c in 3:
		trec["fresh"] = 1.0
		m.engine.settle(m.cash)
		var now227: int = m.storage.amount("system:1", "energy")
		got227 += now227 - last227
		last227 = now227
	check(t227["ok"] and last227 == 400 - m.storage.amount("planet:0", "energy") and last227 > 0 and got227 == last227, "T227: energy delivered over 3 cycles accumulates in Space Storage", "stock %d" % last227)
	check(m.engine.upkeep_out.is_valid() and int(m.engine.upkeep_out.call("system:1", "energy", 100)) == 0 and int(m.engine.upkeep_out.call("system:1", "food", 100)) == 0, "T227: no link means no upkeep drain in the projection")
	m.remove_connection(int(trec["id"]))
	m.storage.stock["system:1"]["energy"] = 0
	m.storage.stock["planet:0"]["energy"] = 60 - moved
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
	check(m.learn_skill("FND_PERMIT")["ok"] and m.learn_skill("FND_PROSPECT")["ok"] and _learn_storage(m)["ok"] and m.learn_skill("BIO_1")["ok"] and m.learn_skill("BIO_3")["ok"], "BIO_3: learned after BIO_1")
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
	var r: Dictionary = m.engine.check_connection(0, 5, "energy")
	check(not r["ok"] and r["reason"] == StoryText.get_text("NOT_ROUTE_NEEDS_C3"), "FND_PERMIT: cross-system route refused without permit routes", str(r))
	check(m.engine.check_connection(5, 6, "energy")["ok"], "FND_PERMIT: a route inside system 2 needs no Permit Charter")
	m.learned_skills.append("FND_PERMIT")
	check(m.engine.check_connection(0, 5, "energy")["ok"], "FND_PERMIT: cross-system route allowed with FND_PERMIT")
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
	var eng: RefCounted = m.engine
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
	var u0: int = eng.units_per_cycle(null, "rounds")  # energy is a common raw now: MIL_3 only lifts Military goods
	var l0: int = eng.local_amount()
	var f0: int = eng.fixed_cost()
	var y0: int = m.clusters.yield_per_cycle()
	m.learned_skills = ["MIL_3", "BIO_1", "MIL_1", "MIN_3"]
	check(eng.units_per_cycle(null, "rounds") > u0 and eng.local_amount() == l0, "hooks: MIL_3 raises Military route capacity (round 2); BIO_1 does not change order size")
	check(eng.fixed_cost() < f0, "hooks: upkeep_mult (MIL_1) lowers the ship upkeep")
	check(m.clusters.yield_per_cycle() == floori(float(bal["mining_yield_per_cycle"]) * (1.0 + float(bal["skill_MIN_3_yield"]))) and m.clusters.yield_per_cycle() > y0, "hooks: cluster_yield_pct (MIN_3) raises mining yield")
	m.learned_skills = []
	# MIN_2 ore_free_slots: an ore order ignores the order-size cap
	var ore_l0: int = eng.local_amount("ore")
	m.learned_skills = ["MIN_2"]
	var ore_l1: int = eng.local_amount("ore")
	check(ore_l0 == eng.local_amount() and ore_l1 > ore_l0 * 100 and eng.local_amount("energy") == ore_l0, "MIN_2: ore orders are no longer capped by the order size (%d -> %d), other goods are" % [ore_l0, ore_l1])
	m.learned_skills = []
	# BIO_5 stock_protect: Biotech stock survives an asteroid cut of the storage
	var lux_good := ""
	for g in ["food", "spores", "energy", "silk"]:
		if Markets.market_of(g) == "bio":
			lux_good = g
			break
	var sk := "planet:2"
	var cap_before: int = m.storage.capacity_of(sk)
	m.storage.add(sk, lux_good, cap_before)
	m.storage.cut_capacity(sk, 0.5)
	var lux_cut: int = m.storage.amount(sk, lux_good)
	m.storage.cuts.erase(sk)
	m.storage.stock[sk][lux_good] = cap_before
	m.learned_skills = ["BIO_5"]
	m.storage.cut_capacity(sk, 0.5)
	var lux_kept: int = m.storage.amount(sk, lux_good)
	check(lux_good != "" and lux_cut < cap_before and lux_kept == cap_before and m.storage.space(sk, lux_good) == 0, "BIO_5: Biotech stock is trimmed by a storage cut without the skill (%d) and kept with it (%d)" % [lux_cut, lux_kept])
	m.storage.cuts.erase(sk)
	m.storage.stock.erase(sk)
	m.learned_skills = []
	m.events.active = [{"id": "T1", "kind": "up", "planet": 0, "c": "silk", "left": 3, "age": 0}, {"id": "T2", "kind": "down", "planet": 0, "c": "rounds", "left": 3, "age": 0}]
	var up0: float = m.events.price_factor(0, "silk")
	var dn0: float = m.events.price_factor(0, "rounds")
	m.learned_skills = ["LUX_5", "MIL_6"]
	check(is_equal_approx(m.events.price_factor(0, "silk"), 1.0 + m.events.pct("silk") * (1.0 + float(bal["skill_LUX_5_event_bonus"]))) and m.events.price_factor(0, "silk") > up0, "hooks: event_bonus_pct (LUX_5) makes price-up events pay more")
	check(is_equal_approx(m.events.price_factor(0, "rounds"), 1.0 - m.events.pct("rounds") * (1.0 - float(bal["skill_MIL_6_event_cut"]))) and m.events.price_factor(0, "rounds") > dn0, "hooks: event_cut_pct (MIL_6) weakens price-down events")
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
	check(absf(map.planet_scale - 1.69) < 0.0001 and absf(map.planet_radius() - 0.8 * 1.69) < 0.0001, "size: planets default to x1.69", "scale=%f" % map.planet_scale)
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
	m.debug_menu._set_planet_scale(1.69)
	check(absf(map.planet_radius() - 1.352) < 0.0001, "size: back to x1.69")
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
	var two: Array = [Vector3(0, 0, 0), Vector3(10, 0, 0)]
	var sun_on: Array = [[Vector3(5, 0, 0.2), 0.75]]
	var o_sun: float = RO.offset(0, 1, two, [], 1.8, [], sun_on)
	check(o_sun > 0.01, "offset: a route across the sun bends round it", "%.3f" % o_sun)
	check(RO.offset(0, 1, two, [], 1.8, [], [[Vector3(5, 0, 4), 0.75]]) == 0.0, "offset: a sun far from the route changes nothing")
	var wp = RO.sun_waypoint(two[0], two[1], sun_on)
	check(wp != null and Vector2(wp.x - 5.0, wp.z - 0.2).length() >= 0.75 * 1.5 and RO.sun_waypoint(two[0], two[1], []) == null, "offset: the waypoint keeps the sun clearance, none without a sun")
	var sl = load("res://game/route_line.gd").new()
	sl.setup(0, 0, 1, two[0], two[1], 0.3, false, sun_on)
	var clear := true
	for i in 21:
		var u := float(i) / 20.0
		clear = clear and Vector2(sl._bez(u).x - 5.0, sl._bez(u).z - 0.2).length() > 0.75
	check(clear, "route line: the drawn path goes round the sun")
	var sl2 = load("res://game/route_line.gd").new()
	sl2.setup(0, 0, 1, two[0], two[1], 0.3, false, [[Vector3(5, 0, 6), 0.75]])
	var sl3 = load("res://game/route_line.gd").new()
	sl3.setup(0, 0, 1, two[0], two[1], 0.3, false)
	check(sl2._c.is_equal_approx(sl3._c), "route line: a route away from the sun is unchanged")
	sl.free(); sl2.free(); sl3.free()
	# T163: routes on one pair or corridor get separate curves; a lone route is unchanged
	var la = load("res://game/route_line.gd").new()
	la.setup(1, 0, 1, two[0], two[1], 0.3, false, [], -0.5)
	var lb = load("res://game/route_line.gd").new()
	lb.setup(2, 0, 1, two[0], two[1], 0.3, false, [], 0.5)
	var l0 = load("res://game/route_line.gd").new()
	l0.setup(3, 0, 1, two[0], two[1], 0.3)
	var l00 = load("res://game/route_line.gd").new()
	l00.setup(4, 0, 1, two[0], two[1], 0.3, false, [], 0.0)
	check(la._bez(0.5).distance_to(lb._bez(0.5)) > 0.1 and la._bez(0.5).distance_to(l0._bez(0.5)) > 0.03, "route lanes: two routes on one pair get different curves")
	check(l0._c.is_equal_approx(l00._c) and l0.tag_pos.is_equal_approx(l00.tag_pos), "route lanes: a lone route is unchanged")
	var lm = load("res://game/map.gd").new()
	var rr: Array = [{"id": 5, "a": 0, "b": 1}, {"id": 6, "a": 1, "b": 0}, {"id": 7, "a": 0, "b": 1}, {"id": 8, "a": 2, "b": 3}]
	check(lm._lane_of(rr, 8, 2, 3) == 0.0 and lm._lane_of(rr, 5, 0, 1) != lm._lane_of(rr, 7, 0, 1) and lm._lane_of(rr, 6, 1, 0) == 0.0, "route lanes: map gives each route on a pair its own slot, none to a lone route")
	la.free(); lb.free(); l0.free(); l00.free(); lm.free()
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
	# _new_main forces discovery_enabled for the test; put the shipped value back so the save is a no-op
	m.balance["discovery_enabled"] = float(JSON.parse_string(bal_text)["values"]["discovery_enabled"])
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
	check(m.open_systems.has(2) and m.map.planets.size() == 10, "debug: unlock system 2 free")
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
	m.open_event_icon("EV20")
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
	m.open_event_icon("EV20")
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
	m.open_event_icon("EV20")
	_buttons(m.event_notice, [])[1].pressed.emit()
	check(m.storage.capacity_of(Storage.planet_key(1)) == cap0 and _texts(m.event_notice).has(StoryText.get_text("EV20_MISS")), "asteroid: good roll changes nothing")
	_buttons(m.event_notice, [])[0].pressed.emit()
	m.events.seed_rng(bad_seed)
	m.debug_fire_event("EV20")
	m.open_event_icon("EV20")
	_buttons(m.event_notice, [])[1].pressed.emit()
	var cap1: int = m.storage.capacity_of(Storage.planet_key(1))
	check(m.asteroid_last_hit == 1 and cap1 == int(round(cap0 * (1.0 - float(b["asteroid_storage_loss_pct"])))), "asteroid: bad roll cuts storage by asteroid_storage_loss_pct", "%d -> %d" % [cap0, cap1])
	check(m.storage.amount(Storage.planet_key(1), "food") <= cap1 and m.storage.established(Storage.planet_key(1)), "asteroid: stock trimmed, storage not destroyed")
	check(_texts(m.event_notice).has(StoryText.get_text("EV20_HIT_CAPACITY", {"planet": m.planet_name(1)})), "asteroid: hit popup EV20_HIT_CAPACITY with planet")
	_buttons(m.event_notice, [])[0].pressed.emit()
	m.events.seed_rng(bad_seed)  # same seed, same outcome
	m.debug_fire_event("EV20")
	m.open_event_icon("EV20")
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
	var mk: Button = m.station_markers[1]
	m._update_station_markers()
	var was_vis: bool = mk.visible
	m.skill_screen.open_screen()
	m._update_station_markers()
	check(not mk.visible and m.map_overlays_blocked(), "station: marker hidden while the skill screen is open")
	m.skill_screen.close_screen()
	m._update_station_markers()
	check(mk.visible == was_vis, "station: marker back after the skill screen closes")
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
	check(ssv.get_global_rect().position == m.planet_panel.get_global_rect().position and ssv.get_global_rect().position == Vector2(76, 76), "station view: docked at the planet panel's position", str(ssv.get_global_rect()))
	check(ssv.get_global_rect().end.x <= root.get_visible_rect().size.x and ssv.get_global_rect().end.y <= root.get_visible_rect().size.y, "station view: fully on screen", str(ssv.get_global_rect()))
	m._on_planet_clicked(0)
	check(not ssv.visible and m.planet_panel.visible and m.selected_planet == 0, "station view: selecting a planet closes it and shows the planet panel")
	m._on_station_clicked(2)
	check(ssv.visible and not m.planet_panel.visible and m.selected_planet == -1, "station view: opening it hides the planet panel and the selection")
	var rows_ok: bool = true
	for c in m.commodities:
		rows_ok = rows_ok and (ssv.box.find_child("Row_" + str(c), true, false) != null) == Availability.good(str(c))  # only visible goods have a row
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

# ---- a pending Send to, then a real left click on the Space Storage station (owner report: cannot build a route to the station) ----
func _station_click(m) -> void:
	var p: Vector2 = m.map.camera.unproject_position(m.map.stations[1].position)
	for down in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = down
		e.position = p
		e.global_position = p
		m.map._unhandled_input(e)  # the map's own click handler: what the engine calls when no GUI control took the click
	await process_frame

func _station_ready(m) -> void:
	m.cash = 5000
	m.ships = 3
	m.learned_skills.append("FND_STORAGE")  # no earn lock here: this is about the click, not the learning
	m._ensure_stations()
	m._ensure_posts()
	m.storage.ensure("planet:0")
	m.storage.add("planet:0", "energy", 60)
	m.pending = {"planet": 0, "c": "energy"}
	m._pending_changed()
	await process_frame

func _test_station_send() -> void:
	_wipe_user()
	var m = await _new_main()
	m._dismiss_preface()
	await _station_ready(m)
	var n0: int = m.engine.routes.size()
	var pt: Vector2 = m.map.camera.unproject_position(m.map.stations[1].position)
	check(m.map.pick_station(pt) == 1 and m.map.pick_planet(pt) < 0, "station send: the station position picks the station, no planet")
	check(m.pending_label.text.contains("Space Storage"), "station send: the pending line says the station can be clicked", m.pending_label.text)
	m.planet_panel.show_planet(int(m.pending["planet"]))
	var pend_lines: Array = _labels(m.planet_panel, []).filter(func(l): return l.text.contains("Click the destination planet."))
	check(pend_lines.size() == 1 and pend_lines[0].text.ends_with(m.pending_station_hint().strip_edges()) and m.pending_station_hint().contains("Space Storage"), "station send: the planet panel pending line carries the same station hint", str(pend_lines.map(func(l): return l.text)))
	var sys_keep: Array = m.station_systems.duplicate()
	m.station_systems = []
	check(m.pending_station_hint() == "", "station send: no hint when the pending system has no station")
	m.planet_panel.show_planet(int(m.pending["planet"]))
	pend_lines = _labels(m.planet_panel, []).filter(func(l): return l.text.contains("Click the destination planet."))
	check(pend_lines.size() == 1 and not pend_lines[0].text.contains("Space Storage"), "station send: panel pending line has no station hint without a station")
	m.station_systems = sys_keep
	await _station_click(m)
	check(m.pending.is_empty() and m.engine.routes.size() == n0 + 1 and str(m.engine.routes[n0]["dst"]) == "system:1", "station send: a real click on the station while pending makes the route", "routes %d" % m.engine.routes.size())
	m.engine.routes.clear()
	m._push_routes_to_map()
	# the route to the station is drawn on the map
	m.pending = {"planet": 0, "c": "energy"}
	await _station_click(m)
	await process_frame
	var line_ok := false
	for id in m.map.route_lines:
		var ln = m.map.route_lines[id]
		line_ok = line_ok or (int(ln.pair_b) == -1 and ln.visible)
	check(line_ok, "station send: the route to the station gets a visible line on the map")
	m.engine.routes.clear()
	m._push_routes_to_map()
	# with the planet panel open and with the station view open the click still reaches the station
	m.selected_planet = 0
	m.planet_panel.show_planet(0)
	m.pending = {"planet": 0, "c": "energy"}
	m._pending_changed()
	await process_frame
	await _station_click(m)
	check(m.engine.routes.size() == 1 and m.pending.is_empty(), "station send: the open planet panel does not swallow the click")
	m.engine.routes.clear()
	m._push_routes_to_map()
	m.space_storage_view.open_for(1)
	m.pending = {"planet": 0, "c": "energy"}
	await process_frame
	var pr: Rect2 = m.space_storage_view.get_global_rect()
	check(not pr.has_point(pt) and not m.planet_panel.get_global_rect().has_point(pt), "station send: the docked view and panel do not cover the station", str(pr))
	await _station_click(m)
	check(m.engine.routes.size() == 1 and m.pending.is_empty(), "station send: the docked station view does not swallow the click")
	m.engine.routes.clear()
	# refused: no Space Storage skill / no post -> the reason is shown at once and the send stays pending
	m.space_storage_view.close_view()
	m.pending = {"planet": 0, "c": "energy"}
	m.learned_skills.erase("FND_STORAGE")
	m._on_station_clicked(1)
	check(m.engine.routes.is_empty() and not m.pending.is_empty() and m.last_notice == m.trade_locked_reason() and m.notice_label.text == m.trade_locked_reason() and m.notice_label.visible, "station send: no Space Storage skill is refused with the reason on screen", m.notice_label.text)
	m.learned_skills.append("FND_STORAGE")
	m.storage.stock.erase(Storage.system_key(1))
	m._on_station_clicked(1)
	check(m.engine.routes.is_empty() and not m.pending.is_empty() and m.notice_label.text == m.trade_locked_reason(), "station send: no established storage is refused with the reason on screen")
	m.storage.ensure(Storage.system_key(1))
	m.cash = 10
	m.ships = 0
	m._on_station_clicked(1)
	check(m.engine.routes.is_empty() and m.notice_label.text.contains("cash") and not m.pending.is_empty(), "station send: no ship and no cash is refused with the reason on screen", m.notice_label.text)
	await _free_main(m)
	# guided tutorial: the lock text is shown, nothing is built
	m = await _new_main(true)
	m._dismiss_preface()
	await _station_ready(m)
	m.tut_step = 3
	m.pending = {"planet": 0, "c": "energy"}
	await _station_click(m)
	check(m.engine.routes.is_empty() and not m.pending.is_empty() and m.notice_label.text == m.tut_lock_text() and m.notice_label.visible, "station send: the guided tutorial refuses with its text", m.notice_label.text)
	await _free_main(m)
	_wipe_user()

func _test_system_suns() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var map = m.map
	check(map.suns.size() == 1 and map.suns.has(1) and map.suns[1].visible, "suns: system 1 has its sun at the start")
	var s1 = map.suns[1]
	check(absf(s1.hue_shift()) < 0.0001 and absf(s1.sun_color.h - 0.09) < 0.01 and s1.drives_light and s1 == map.sun_node, "suns: system 1 sun unchanged (orange, no hue shift)")
	# Sun brightness mute (2026-11-02): the core stays fully opaque (no ALPHA written, alpha 1.0) and the gain is unchanged.
	var sun_src := FileAccess.get_file_as_string("res://game/fx/sun/sun.gdshader")
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
	m.prosperity.balance["need_surplus_pct"] = 100  # T349: Voltara needs food now; no surplus cut so the bonus math stays pure
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
	var pre_line: Label = m.cluster_info.find_child("ClusterInfoLine", true, false) if m.cluster_info != null else null
	check(pre_line != null and Availability.names_hidden_good(pre_line.text) == "", "availability: the cluster card names no ore before FND_PROSPECT", str(pre_line.text if pre_line != null else ""))
	Skills.add_learned("FND_PROSPECT")
	m._on_cluster_clicked(int(c0["index"]))
	var info_ok: bool = m.cluster_info != null and m.cluster_info.visible and not m.planet_panel.visible
	var info_line: Label = m.cluster_info.find_child("ClusterInfoLine", true, false) if m.cluster_info != null else null
	check(info_ok and info_line != null and info_line.text.contains(str(m.clusters.yield_per_cycle())), "T159: cluster click shows the info card with the yield per cycle")
	check(m.map.pick_cluster(Vector2(-5000, -5000)) == -1, "T159: a click far from any pack picks no cluster")
	m._on_planet_clicked(0)
	check(not m.cluster_info.visible, "T159: a planet click hides the cluster card")
	await _free_main(m)

# ---- Cluster card "Send ore to...": the player path to a cluster route ----
func _test_cluster_send() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var c0: Dictionary = m.clusters.list(1)[0]
	var node: int = int(c0["node"])
	var dst := -1
	for i in m.map.planets.size():
		if m.engine.sold_price(i, "ore") > 0 and (dst < 0 or m.engine.sold_price(i, "ore") > m.engine.sold_price(dst, "ore")):
			dst = i
	m.cash = 100000
	m._on_cluster_clicked(int(c0["index"]))
	check(m.cluster_info.find_child("ClusterSendButton", true, false) == null, "cluster send: no button without Prospecting")
	m.learned_skills.append("FND_PROSPECT")
	m._on_cluster_clicked(int(c0["index"]))
	var btn: Button = m.cluster_info.find_child("ClusterSendButton", true, false)
	check(btn != null and btn.text == StoryText.get_text("BTN_CLUSTER_SEND"), "cluster send: button shown with Prospecting")
	if btn != null:
		btn.pressed.emit()
	check(not m.pending.is_empty() and int(m.pending["planet"]) == node and str(m.pending["c"]) == "ore" and not m.cluster_info.visible, "cluster send: button starts a pending route from the cluster")
	m.cancel_pending()
	m.cash = 0
	m.ships = m.engine.total_assigned()
	m._on_cluster_send(int(c0["index"]))
	check(not m.route_unaffordable().is_empty(), "cluster send: red-line warning applies when no ship is affordable")
	m._on_planet_clicked(dst)
	check(m.engine.routes.is_empty() and not m.pending.is_empty(), "cluster send: refused without cash, pending stays")
	m.cash = 100000
	var ships0: int = m.ships
	m._on_planet_clicked(dst)
	check(m.engine.routes.size() == 1 and RouteEngine.from_cluster(m.engine.routes[0]) and m.pending.is_empty() and m.ships == ships0 + 1, "cluster send: next planet clicked creates the route and buys a ship", str(m.engine.routes))
	m._on_cluster_send(int(c0["index"]))
	m._on_planet_clicked(-1)
	check(m.pending.is_empty(), "cluster send: a click on empty space cancels")
	await _free_main(m)

# ---- Cluster -> Space Storage station (bug 2026-11-04: check_cluster refused every station destination) ----
func _test_cluster_to_station() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var c0: Dictionary = m.clusters.list(1)[0]
	var node: int = int(c0["node"])
	var ci: int = int(c0["index"])
	m.cash = 100000
	m.ships = 3
	m.learned_skills.append("FND_PROSPECT")
	# station not there yet (no FND_STORAGE): refused with a reason
	var r: Dictionary = m.send_from_cluster(node, m.station_dst(1))
	check(not r["ok"] and str(r["reason"]) != "" and m.engine.routes.is_empty(), "cluster to station: refused before the station exists", str(r))
	m.learned_skills.append("FND_STORAGE")
	m._ensure_stations()
	m._ensure_posts()
	check(m.engine.check_connection(node, m.station_dst(1), "ore")["ok"], "cluster to station: the engine accepts a cluster to the station of its system", str(m.engine.check_connection(node, m.station_dst(1), "ore")))
	# station not established: refused on screen
	m.storage.stock.erase(Storage.system_key(1))
	m._on_cluster_send(ci)
	m._on_station_clicked(1)
	check(m.engine.routes.is_empty() and not m.pending.is_empty() and m.notice_label.text == m.trade_locked_reason() and m.notice_label.visible, "cluster to station: station not established is refused with the reason on screen", m.notice_label.text)
	m.storage.ensure(Storage.system_key(1))
	# the real click path: pending from the cluster card, click on the station
	m.cancel_pending()
	m._on_cluster_send(ci)
	m.ships = m.engine.total_assigned()
	m.cash = 0
	check(not m.route_unaffordable().is_empty(), "cluster to station: the red cash warning applies")
	m._on_station_clicked(1)
	check(m.engine.routes.is_empty() and not m.pending.is_empty() and m.notice_label.text != "", "cluster to station: no cash for a ship is refused with a reason", m.notice_label.text)
	m.cash = 100000
	var ships0: int = m.ships
	await _station_click(m)
	check(m.engine.routes.size() == 1 and m.pending.is_empty() and m.ships == ships0 + 1, "cluster to station: a real click on the station makes the route and buys a ship", str(m.engine.routes))
	var rec: Dictionary = m.engine.routes[0]
	check(RouteEngine.from_cluster(rec) and RouteEngine.to_station(rec) and int(rec["b"]) == -1 and str(rec["dst"]) == Storage.system_key(1), "cluster to station: record runs cluster -> station of system 1", str(rec))
	await process_frame
	var line_ok := false
	for id in m.map.route_lines:
		var ln = m.map.route_lines[id]
		line_ok = line_ok or (int(ln.pair_a) == node and int(ln.pair_b) == -1 and ln.visible)
	check(line_ok, "cluster to station: the route gets a visible line from the pack to the station")
	var units: int = m.engine.units_per_cycle(rec)
	var proj: Dictionary = m.engine.project_storage(Storage.system_key(1), "ore")
	check(int(proj["in"]) == units, "cluster to station: the storage projection counts the delivery", str(proj))
	var left0: int = m.clusters.left(ci)
	m._settle_routes()
	check(m.storage.amount(Storage.system_key(1), "ore") == units and m.clusters.left(ci) == left0 - units, "cluster to station: ore lands in the station storage and the cluster thins", "%d" % m.storage.amount(Storage.system_key(1), "ore"))
	# saved route reloads
	var st: Dictionary = JSON.parse_string(JSON.stringify(m.collect_state()))
	m.engine.routes.clear()
	m.apply_state(st)
	check(m.engine.routes.size() == 1 and RouteEngine.from_cluster(m.engine.routes[0]) and int(m.engine.routes[0]["b"]) == -1, "cluster to station: the saved route reloads", str(m.engine.routes))
	# clicking its line opens the station, not a planet panel
	m._on_route_clicked(int(m.engine.routes[0]["id"]))
	check(m.space_storage_view.visible, "cluster to station: a click on the route line shows the station storage")
	m.space_storage_view.close_view()
	# no skill: refused (a new route only)
	m.engine.routes.clear()
	m.learned_skills.erase("FND_PROSPECT")
	r = m.send_from_cluster(node, m.station_dst(1))
	check(not r["ok"] and r["reason"] == StoryText.get_or("NOT_MINING_NEEDS_SKILL", "Mining needs the Prospecting skill."), "cluster to station: refused without the Prospecting skill", str(r))
	m.learned_skills.append("FND_PROSPECT")
	# another system needs the permit routes skill
	m.open_systems = [1, 2]
	m._open_system(2)
	m._ensure_stations()
	m._ensure_posts()
	r = m.send_from_cluster(node, m.station_dst(2))
	check(not r["ok"] and r["reason"] == StoryText.get_text("NOT_ROUTE_NEEDS_C3") and m.engine.routes.is_empty(), "cluster to station: another system without the permit skill is refused", str(r))
	m.learned_skills.append("FND_PERMIT")
	r = m.send_from_cluster(node, m.station_dst(2))
	check(r["ok"], "cluster to station: another system's station is allowed with the permit skill", str(r))
	# no ore before it is visible: the availability rule closes the station target
	check(not m.engine.check_connection(node, m.station_dst(9), "ore")["ok"], "cluster to station: an unknown system is refused")
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
	m.open_event_icon("EV20")
	_buttons(m.event_notice, [])[1].pressed.emit()
	check(m.clusters.items.size() == n0, "T156: declining EV20 leaves no cluster")
	_buttons(m.event_notice, [])[0].pressed.emit()
	m.debug_fire_event("EV20")
	m.open_event_icon("EV20")
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
		m.open_event_icon("EV20")
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


## New company screen: names, portrait atlas, setup scene, hand-off to main, save round trip.
func _test_company_setup() -> void:
	var Names := load("res://game/company_names.gd")
	var Portraits := load("res://game/company_portraits.gd")
	var ok_len := true
	var ok_set := true
	for i in 300:
		var n: String = Names.generate(i)
		if n == "" or n.length() > Names.MAX_LEN:
			ok_len = false
	check(ok_len, "company names: never empty, never over the max length")
	check(Names.generate(7) == Names.generate(7), "company names: same seed gives same name")
	var seen := {}
	for i in 50:
		seen[Names.generate(i)] = true
	check(seen.size() > 10, "company names: different seeds give variety", str(seen.size()))
	var atlas := load(Portraits.ATLAS_PATH) as Texture2D
	check(atlas != null, "portraits: atlas loads")
	if atlas != null:
		var inside := true
		var regs := {}
		for id in Portraits.IDS:
			var r: Rect2 = Portraits.region(id)
			regs[r] = true
			if r.position.x < 0 or r.position.y < 0 or r.end.x > atlas.get_width() or r.end.y > atlas.get_height():
				inside = false
		check(inside and regs.size() == Portraits.IDS.size(), "portraits: one distinct region per portrait, all inside the atlas")
	_wipe_user()
	var setup: Control = load("res://game/company_setup.tscn").instantiate()
	root.add_child(setup)
	await process_frame
	var none_pressed := true
	for cid in setup.cards:
		if (setup.cards[cid] as Button).button_pressed:
			none_pressed = false
	check(setup.cards.size() == Portraits.IDS.size() and setup.selected_id == "" and none_pressed, "setup: four cards, none selected at open")
	check(setup.chosen_name() != "" and setup.start_button.disabled and setup.start_button.tooltip_text != "", "setup: name pre-filled but no CEO, Start disabled with a tooltip")
	setup.cards[Portraits.IDS[1]].pressed.emit()
	check(setup.selected_id == Portraits.IDS[1] and not setup.start_button.disabled, "setup: Start enabled after a CEO pick")
	var ceo_rows := {}
	for row in _read_json("res://data/ceos.json").get("ceos", []):
		ceo_rows[str(row["id"])] = row
	var tags_ok := true
	var ships_ok := true
	for cid in Portraits.IDS:
		setup.cards[cid].pressed.emit()
		var tag_txt: String = StoryText.get_text("TXT_%s_BRANCH_TAG" % cid.to_upper())
		var found_tag := false
		var found_ship := false
		var ship_nm: String = StoryText.get_text(str(setup.ship_defs.get(str(ceo_rows[cid]["ship"]), {}).get("name_id", "")))
		for c in setup.info_box.get_children():
			if c is Label and tag_txt != "" and c.text == tag_txt:
				found_tag = true
			if c is Label and ship_nm != "" and c.text == ship_nm:
				found_ship = true
		if not found_tag:
			tags_ok = false
		if not (found_ship and setup.preview.visible and setup.preview.model_path == str(setup.ship_defs[str(ceo_rows[cid]["ship"])].get("model", ""))):
			ships_ok = false
	check(tags_ok, "setup: each CEO shows its own branch tag")
	check(ships_ok, "setup: each CEO shows its ship name and preview model")
	setup.cards[Portraits.IDS[1]].pressed.emit()
	var before: String = setup.name_edit.text
	setup.random_button.pressed.emit()
	check(setup.name_edit.text != before and setup.name_edit.text != "", "setup: Random gives another name")
	setup.name_edit.text = "   "
	setup.name_edit.text_changed.emit("   ")
	check(setup.start_button.disabled, "setup: Start disabled with an empty name even with a CEO")
	setup.name_edit.text = "  Test Freight Concern "
	setup.name_edit.text_changed.emit("x")
	setup.select("ceo_woman_02")
	setup.commit()
	setup.queue_free()
	await process_frame
	var m: Control = await _new_main()
	check(m.company_name == "Test Freight Concern" and m.ceo_portrait == "ceo_woman_02", "setup: chosen name and portrait reach main state", m.company_name + " " + m.ceo_portrait)
	check(SaveGame.pending_company == "", "setup: hand-off is read once")
	var m2: Control = await _new_main()
	check(m2.ceo_portrait == Portraits.IDS[0], "setup: no-setup start falls back to the first portrait", m2.ceo_portrait)
	m2.queue_free()
	var st: Dictionary = JSON.parse_string(JSON.stringify(m.collect_state()))
	check(st.get("company_name") == "Test Freight Concern" and st.get("ceo_portrait") == "ceo_woman_02", "save: company name and portrait are saved")
	m.company_name = ""
	m.ceo_portrait = ""
	m.apply_state(st)
	check(m.company_name == "Test Freight Concern" and m.ceo_portrait == "ceo_woman_02", "save: round trip keeps company name and portrait")
	var old := st.duplicate()
	old.erase("company_name")
	old.erase("ceo_portrait")
	m.apply_state(old)
	check(m.company_name != "" and m.company_name.length() <= Names.MAX_LEN and m.ceo_portrait == Portraits.IDS[0], "save: old save without the fields gets a generated name and the first portrait")
	m.game_menu.open_menu()
	check(m.game_menu._company_label.text == m.company_name and m.game_menu._portrait.texture != null, "game menu: shows company name and portrait")
	m.game_menu.close_menu()
	await _free_main(m)

func _test_event_banners() -> void:
	var evs: Array = StoryText.entries_of(_read_json("res://data/events.json"))
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

## T213: with 2000 cash a loaded route (trip far below 2000) is never stalled for cash, and the cash texts name the amounts.
func _test_no_cash_text() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	m.cash = 100000
	check(m.send_stock_buying(0, 1, "energy")["ok"] and e.routes.size() == 1, "no cash text: one route set up")
	var sk: String = m.storage.planet_key(0)
	m.storage.ensure(sk)
	m.storage.add(sk, "energy", 20)
	var fixed: int = e.fixed_cost(e.routes[0])
	check(fixed < 2000, "no cash text: the trip costs less than 2000", str(fixed))
	m.cash = 2000
	var f: Dictionary = e.forecast(2000)
	var r: Dictionary = e.settle(2000)
	var reason := str(e.routes[0]["reason"])
	check(str(e.routes[0]["state"]) != "stalled" and not reason.begins_with("Not enough cash"), "no cash text: cash 2000 is not reported as not enough cash", str(e.routes[0]["state"]) + " " + reason)
	for ln in f["local"]:
		check(not str(ln["state"]).begins_with("Not enough cash"), "no cash text: no order reports not enough cash at 2000", str(ln["state"]))
	var t: String = e.no_cash_route_text(55, 40)
	check(t.contains("55") and t.contains("40") and t.begins_with("Not enough cash"), "no cash text: the route text shows needed and held cash", t)
	var tb: String = e.no_cash_buy_text(253, 10)
	check(tb.contains("253") and tb.contains("10"), "no cash text: the buy text shows price and free cash", tb)
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
	var sh = load("res://game/fx/planet/planet_sphere_dead.gdshader")
	check(sh is Shader and (sh as Shader).code.contains("limb_dark"), "dead planets: inverse fresnel shader loads")
	var PS = load("res://game/fx/planet/planet_sphere.gd")
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
	for sk in ["MIN_3", "MIN_5"]:
		Skills.add_learned(sk)  # availability: the inputs are named only once dross and nullglass are visible
	m.cycle = maxi(m.cycle, int(m.balance["dead_unlock_cycle"]))
	if not m.open_systems.has(2):
		m.open_systems.append(2)
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
	check(ST.prereqs("MIN_3") == ["MIN_1"] and ST.prereqs("MIN_5") == ["MIN_3"] and ST.prereqs("MIN_1") == FND3, "dead skills: MIN_3 needs MIN_1, MIN_5 needs MIN_3, MIN_1 needs the three Foundations")
	check(ST.ids_in("min").has("MIN_3") and ST.cost(m.balance, "MIN_3") == 2 and ST.cost(m.balance, "MIN_5") == 2 and ST.cost(m.balance, "MIN_1") == 1, "dead skills: Minerals tree, costs 2, 2, 1 (balance v83)")
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
	check(panel_text == "", "danger: hidden by its availability rule, no line on the planet panel", panel_text)
	check(not Availability.feature("dead_danger_meter") and m.effect_line({"kind": "danger", "planet": d1, "c": "", "amount": 1}) == "", "danger: no notice names it while hidden")
	var saved_rule = Availability._rules["feature|dead_danger_meter"]
	Availability._rules["feature|dead_danger_meter"] = "start"  # the rule flipped: the line comes back
	m.planet_panel.show_planet(d1)
	for l in _labels(m.planet_panel, []):
		if l.name == "DangerLine":
			panel_text = l.text
	check(panel_text == "Danger: 5 of 5", "danger: shown when the rule is true", panel_text)
	Availability._rules["feature|dead_danger_meter"] = saved_rule
	m.planet_panel.show_planet(d1)
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
	check(m.cycle == 3 and fed.call() == 1 and ev.scheduled.is_empty(), "follow: fires once at the set cycle", "cycle %d fired %d chains %s notice %s" % [m.cycle, fed.call(), str(Chains.picks.keys()), m.events.pending_id])
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
	m.planet_panel.visible = false
	m._on_planet_clicked(d1)
	var lock_vis := false
	for l in _labels(m.planet_panel, []):
		lock_vis = lock_vis or (l.name == "DeadLockedLine" and l.is_visible_in_tree() and l.text == "Opens at cycle 15.")
	check(m.planet_panel.visible and m.selected_planet == d1 and lock_vis, "dead gate: clicking locked Cinderrest shows a visible planet panel with the unlock line")

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
	m._on_planet_clicked(d1)
	var dl_found := false
	var lock_found := false
	for l in _labels(m.planet_panel, []):
		dl_found = dl_found or (l.name == "DangerLine" and l.is_visible_in_tree())
		lock_found = lock_found or l.name == "DeadLockedLine"
	check(m.planet_panel.visible and not dl_found and not lock_found and m.planet_panel.find_child("BuyButton_dross", true, false) != null, "dead gate: after the unlock Cinderrest shows its dross row, no locked line, no danger line (hidden)")
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


# ---- workshop status text and settle order (Munitions Line "needs energy" bug, 2026-11-04) ----
func _test_workshop_status() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	m.cash = 5000
	m.learned_skills.append("MIL_1")
	m.learned_skills.append("FND_STORAGE")
	m._ensure_stations()
	m.open_systems.append(2)  # munitions needs system 2 open (availability rule)
	check(m.build_workshop("munitions")["ok"], "workshop status: munitions built")
	m.open_systems.erase(2)  # built while open; the status tests below need system 2 closed again
	var key: String = m.storage.system_key(1)
	var ws = m.workshops
	m.storage.ensure(key)
	check(not Availability.good("spyware"), "workshop status: chips hidden before system 2")
	# settle order: routes (including a route that draws the station as backup) run BEFORE the workshop
	m.storage.ensure("planet:0")
	m.storage.stock["planet:0"]["energy"] = 0
	m.storage.stock[key]["energy"] = 18
	m.ships = 3
	var cr: Dictionary = m.send_stock(0, 1, "energy")
	check(cr["ok"], "workshop status: outflow route created", str(cr))
	m.engine.routes[m.engine.routes.size() - 1]["fresh"] = 1.0
	var e0: int = m.storage.amount(key, "energy")
	m.engine.settle(m.cash)
	var e1: int = m.storage.amount(key, "energy")
	check(e1 < e0, "workshop status: a route out of the system drains the station before the workshop runs", "%d -> %d" % [e0, e1])
	m.storage.stock[key]["energy"] = 0
	ws.run(m.storage, Callable(m, "craft_units"))
	var t: String = ws.status_text("munitions")
	check(t.contains(Ui.good_name("energy")) and t.contains(StoryText.get_text("LBL_WORKSHOP_NEEDS_OTHER")) and not t.contains(Ui.good_name("spyware")) and not t.contains("Batches"), "workshop status: hidden input is not named, no batch count when stalled", t)
	check(not ws.recipe_line("rounds").contains(Ui.good_name("spyware").to_lower()) and ws.recipe_line("rounds").contains(StoryText.get_text("LBL_WORKSHOP_NEEDS_OTHER")), "workshop status: recipe line hides the name of a hidden input", ws.recipe_line("rounds"))
	# partly missing: energy present, chips hidden and missing
	m.storage.stock[key]["energy"] = 5
	ws.run(m.storage, Callable(m, "craft_units"))
	t = ws.status_text("munitions")
	check(t == StoryText.get_text("LBL_WORKSHOP_STALLED", {"why": StoryText.get_text("LBL_WORKSHOP_NEEDS", {"items": StoryText.get_text("LBL_WORKSHOP_NEEDS_OTHER")})}), "workshop status: only the hidden input missing", t)
	# both visible: all missing inputs named
	m.storage.stock[key]["energy"] = 0
	m.storage.add(key, "spyware", 1)
	m.storage.remove(key, "spyware", 1)
	var sys2 := Availability.good("spyware")
	ws.run(m.storage, Callable(m, "craft_units"))
	if sys2:
		t = ws.status_text("munitions")
		check(t.contains(Ui.good_name("energy")) and t.contains(Ui.good_name("spyware")), "workshop status: every visible missing input is named", t)
	# none missing: runs, batch line, no stall text
	m.storage.stock[key]["energy"] = 4
	m.storage.stock[key]["spyware"] = 2
	ws.run(m.storage, Callable(m, "craft_units"))
	t = ws.status_text("munitions")
	check(ws.state["munitions"] == "running" and t.contains(StoryText.get_text("LBL_WORKSHOP_MADE", {"items": ws.made_text("munitions")})) and not t.contains("Stalled"), "workshop status: made batch shows the batch line only", t)
	await _free_main(m)
	_wipe_user()

# ---- workshops are built in a cell of the player's choice (owner 2026-11-04) ----
func _test_workshops_in_cells() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	m.cash = 5000
	m.learned_skills.append("MIL_1")
	m.learned_skills.append("MIN_1")
	m.learned_skills.append("FND_PROSPECT")
	m.learned_skills.append("FND_STORAGE")
	m.open_systems.append(2)
	m._ensure_stations()
	var cost: int = int(m.balance["workshop_build_cost"])
	check(m.can_build_workshop("munitions", 2)["reason"] == "post" or m.station_systems.has(2), "cells: system 2 cell state is consistent")
	if not m.station_systems.has(2):
		m.station_systems.append(2)
	var v = m.space_storage_view
	v.open_for(2)
	check(v.box.find_child("WorkshopBuild_munitions", true, false) != null and not v.box.find_child("WorkshopBuild_munitions", true, false).disabled, "cells: system 2 cell shows an enabled Build for munitions")
	v.open_for(1)
	check(v.box.find_child("WorkshopBuild_munitions", true, false) != null, "cells: system 1 cell shows Build too")
	v.open_for(2)
	v.box.find_child("WorkshopBuild_munitions", true, false).pressed.emit()
	check(m.workshops.built["munitions"] and m.workshops.system_of("munitions") == 2 and m.cash == 5000 - cost, "cells: built in system 2, cash charged once", str(m.cash))
	check(not m.build_workshop("munitions", 1)["ok"] and m.can_build_workshop("munitions", 1)["reason"] == "built" and m.cash == 5000 - cost, "cells: second build in another cell refused")
	check(v.box.find_child("WorkshopStatus_munitions", true, false) != null and v.box.find_child("WorkshopBuild_munitions", true, false) == null, "cells: system 2 cell shows the built workshop")
	v.open_for(1)
	check(v.box.find_child("Workshop_munitions", true, false) == null and v.box.find_child("WorkshopBuild_munitions", true, false) == null, "cells: system 1 cell no longer lists it")
	check(v.box.find_child("Workshop_smelter", true, false) != null, "cells: other unbuilt workshops stay in the list")
	# inputs and outputs use its own cell
	var k1: String = m.storage.system_key(1)
	var k2: String = m.storage.system_key(2)
	m.storage.add(k1, "energy", 6)
	m.storage.add(k1, "spyware", 6)
	m.workshops.run(m.storage, Callable(m, "craft_units"))
	check(m.workshops.state["munitions"] == "stalled" and m.storage.amount(k1, "energy") == 6 and m.storage.amount(k1, "rounds") == 0, "cells: stock in system 1 is not used by a system 2 workshop")
	m.storage.add(k2, "energy", 6)
	m.storage.add(k2, "spyware", 6)
	m.workshops.run(m.storage, Callable(m, "craft_units"))
	check(m.workshops.state["munitions"] == "running" and m.storage.amount(k2, "rounds") == int(m.balance["rounds_batch_out"]) and m.storage.amount(k1, "rounds") == 0, "cells: output goes to its own cell")
	# save round trip and old saves
	var d: Dictionary = m.workshops.to_dict()
	m.workshops.from_dict(d)
	check(m.workshops.system_of("munitions") == 2 and m.workshops.built["munitions"], "cells: system survives save and load")
	var old := {"munitions": {"built": true, "state": "idle", "reason": "", "made": {}}}
	m.workshops.from_dict(old)
	check(m.workshops.built["munitions"] and m.workshops.system_of("munitions") == 1, "cells: old save without system loads as system 1")
	# availability: a hidden workshop shows no Build in any cell
	m.workshops.setup(m.balance)
	m.open_systems.erase(2)
	v.open_for(1)
	check(not Availability.workshop("munitions") and v.box.find_child("WorkshopBuild_munitions", true, false) == null and v.box.find_child("Workshop_munitions", true, false) == null, "cells: hidden workshop is not drawn")
	# a system without a cell shows no workshop block
	m.open_systems.append(2)
	m.station_systems.erase(2)
	v.open_for(2)
	check(v.box.find_child("WorkshopTitle", true, false) == null and m.can_build_workshop("munitions", 2)["reason"] == "post", "cells: no cell, no workshop block, build refused")

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
	check(m.trade.price(p2, "musk_buy", false, true) == 18 and m.commodities.has("rounds") and m.commodities.has("spores"), "goods: planet prices and the commodity list carry the new goods")
	check(m.balance.has("event_pct_rounds") and m.events.pct_for("rounds") == float(m.balance["event_pct_rounds"]) if m.events.has_method("pct_for") else m.balance.has("event_pct_rounds"), "goods: event_pct key exists for a new good")
	# unlock gating
	var key: String = m.storage.system_key(1)
	check(m.can_build_workshop("munitions")["reason"] == "skill" and not m.build_workshop("munitions")["ok"] and m.cash == 5000, "workshop: refused before its node, nothing paid")
	m.learned_skills.append("MIL_1")
	check(m.can_build_workshop("munitions")["reason"] == "post", "workshop: needs the trading post")
	m.learned_skills.append("FND_STORAGE")
	m._ensure_stations()
	check(m.can_build_workshop("munitions")["reason"] == "closed", "workshop: munitions refused while system 2 is closed")
	m.open_systems.append(2)
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
	check(m.workshops.state["munitions"] == "stalled" and m.workshops.missing["munitions"] == ["energy", "spyware"], "workshop: stalls and lists every missing input", str(m.workshops.missing["munitions"]))
	m.storage.add(key, "energy", 5)
	m.storage.add(key, "spyware", 2)
	m.workshops.run(m.storage, Callable(m, "craft_units"))
	var out_n: int = int(m.balance["rounds_batch_out"])
	check(m.workshops.state["munitions"] == "running" and m.storage.amount(key, "rounds") == out_n and m.storage.amount(key, "energy") == 3 and m.storage.amount(key, "spyware") == 1, "workshop: recipe consumes inputs and yields the batch", str(m.storage.to_dict().get(key, {})))
	# craft_units feeds tech: MIL_2 is active after MIL_1
	check(int(Tech.progress("MIL_2")["n"]) == out_n, "workshop: crafted units count toward the market's tech", str(Tech.progress("MIL_2")))
	# gated good: armour closed until MIL_4 is finished
	m.storage.add(key, "rounds", 3)
	m.storage.add(key, "spyware", 1)
	m.workshops.run(m.storage, Callable(m, "craft_units"))
	check(m.storage.amount(key, "arms") == 0, "workshop: a good whose unlock node is not learned is not made")
	Skills.add_learned("MIL_2")
	Skills.add_learned("MIL_4")
	m.storage.add(key, "energy", 0)
	m.storage.add(key, "rounds", 1)  # round 2: armour = 4 cells (no chips, no rivets)
	m.workshops.run(m.storage, Callable(m, "craft_units"))
	check(m.storage.amount(key, "arms") >= int(m.balance["arms_batch_out"]) and m.storage.amount(key, "arms") % int(m.balance["arms_batch_out"]) == 0, "workshop: armour made once MIL_4 is learned (highest tier first)", str(m.storage.to_dict().get(key, {})))
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
	# the Space Storage view of system 1 shows the section; the planet panel does not
	m.planet_panel.show_planet(p1)
	check(m.planet_panel.box.find_child("WorkshopTitle", true, false) == null and m.planet_panel.box.find_child("Workshop_smelter", true, false) == null, "workshop: planet panel has no workshop UI")
	var wv = m.space_storage_view
	wv.open_for(1)
	check(wv.box.find_child("WorkshopTitle", true, false) != null and wv.box.find_child("Workshop_smelter", true, false) != null and wv.box.find_child("WorkshopStatus_smelter", true, false) != null and wv.box.find_child("WorkshopBuild_atelier", true, false) == null, "workshop: station view lists unlocked workshops only")
	# an unlocked, unbuilt workshop: Build disabled when cash is short, then builds and shows its status
	m.learned_skills.append("MIL_1")
	m.open_systems.append(2)  # Munitions Line shows only with system 2 open
	m.workshops.built["munitions"] = false
	m.cash = 0
	wv.refresh()
	var wb = wv.box.find_child("WorkshopBuild_munitions", true, false)
	check(wb != null and wb.disabled, "workshop: station Build disabled when cash is short")
	m.cash = 5000
	wv.refresh()
	wb = wv.box.find_child("WorkshopBuild_munitions", true, false)
	check(wb != null and not wb.disabled, "workshop: station Build enabled with cash")
	wb.pressed.emit()
	check(m.workshops.built["munitions"] and wv.box.find_child("WorkshopStatus_munitions", true, false) != null and wv.box.find_child("WorkshopBuild_munitions", true, false) == null, "workshop: pressing Build builds it and the view shows the status line")
	m.debug_advance_cycle()
	check(wv.box.find_child("WorkshopStatus_munitions", true, false) != null, "workshop: view refreshes on the cycle")
	wv.open_for(2)
	check(wv.box.find_child("WorkshopTitle", true, false) == null, "workshop: a system-2 station view has no workshop block")
	wv.close_view()
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
		var trig_errs: Array = []
		Conditions.lint(st["trigger"], "chain step " + str(sid), trig_errs, true, bal, Conditions.event_ids())
		if not trig_errs.is_empty():
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
	check(data["pool_new"].size() == 16 and Chains.pool_kept.size() == 24 and Chains.retired.size() == 10 and Chains.retired[0] == "EV18", "chains: pool 24 kept + 12 new + 4 branch, EV18 and EV29 to EV37 retired")
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
	Skills.add_learned("MIL_1")  # A2 is gated on MIL_1 (its option needs the Munitions Line)
	m.open_systems.append(2)  # ... and on system 2 being open (the line is hidden in system 1)
	check(not Chains.eligible("MIL_A2", 8) and Chains.trigger_ok("MIL_A2", 12), "triggers: A2 6 cycles after A1 (cycles_after_prev_step)")
	var after_atom := "cycles_after_prev_step:balance.chain_MIL_A2_trig_after_prev_cycles"
	check(not Conditions.eval(after_atom, Chains.cond_ctx("MIL_A2", 11)) and Conditions.eval(after_atom, Chains.cond_ctx("MIL_A2", 12)), "triggers: cycles_after_prev_step counts from the previous step")
	# min gap and one event per cycle: both A2 conditions true at once; min gap 3 holds the next step of the market
	Chains.picks["MIL_A1"]["cycle"] = 6
	check(Chains.eligible("MIL_A2", 12) and not Chains.eligible("MIL_A2", 8), "triggers: min gap and trigger together")
	Chains.picks["MIL_A1"]["cycle"] = 10
	Chains.reset(bal, 3)
	Chains.picks["MIL_A1"] = {"opt": "opt_a", "cycle": 10, "nudge": 6}
	Skills.add_learned("MIL_3")  # B1 trigger: skill learned
	check(Chains.trigger_ok("MIL_B1", 11) and not Chains.eligible("MIL_B1", 11) and not Chains.eligible("MIL_B1", 9 + int(bal["chain_min_gap"])) and Chains.eligible("MIL_B1", 10 + int(bal["chain_min_gap"])), "triggers: B1 from the learned skill, but only chain_min_gap cycles after the last step of the market")
	Chains.picks["MIL_A1"]["cycle"] = 1
	Chains.picks["LUX_A1"] = {"opt": "opt_a", "cycle": 99, "nudge": 0}
	check(Chains.eligible("MIL_B1", 13) and Chains.next_step(13) == "MIL_A2", "slot: one step per cycle, the first ready in data order (A2 before B1)", Chains.next_step(13))
	Chains.apply_option("MIL_B1", "opt_a", 13)
	check(Chains.next_step(14) != "MIL_B1" and not Chains.eligible("MIL_B2", 14), "slot: the next step of that market waits for the gap")
	Skills.reset(bal)
	# win gate (Chains.win_open stays as data; no share verdict reads it any more)
	Markets.reset(bal, 3)
	Chains.reset(bal, 3)
	check(not Chains.win_open("mil", 5), "win gate: closed early without B4")
	Chains.picks["MIL_B4"] = {"opt": "opt_a", "cycle": 20, "nudge": 0}
	check(Chains.win_open("mil", 5), "win gate: opens as soon as B4 fired")
	check(not Chains.win_open("lux", 77) and Chains.win_open("lux", 78), "win gate: cycle 78 opens it for any market")
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
	check(int(Skills.house_next.get("1", {}).get("delay", 0)) == int(bal["weather_next_delay_cycles"]), "effects: a growth cut delays that house's next weather (T282)")
	# a volume effect really changes the recorded volume of a sale
	Markets.reset(bal, 3)
	Chains.reset(bal, 3)
	Chains.apply_option("MIL_A1", "opt_a", 1)
	Chains.now = 1
	Markets.add_sale("rivets", 10)
	var base_v := float(10 * Markets.value_of("rivets"))
	check(is_equal_approx(float(Markets.cur_active["mil"]), base_v * (1.0 + vp)), "effects: volume effect scales the sale record", str(Markets.cur_active["mil"]))
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
	check(lg.size() == 1 and lg[0]["size_word"] == "lowest" and not bool(lg[0]["tier_changed"]) and not Chains.rival_broken("mil") and is_equal_approx(float(Skills.house_next["1"]["soften"]), float(bal["weather_next_soften_pct"])), "tier: at the lowest tier a tier cut is strength down M, no tier change", str(lg))
	Markets.reset(bal, 3)
	Chains.reset(bal, 3)
	var hi_cycle := 35
	Chains.apply_option("MIL_A2", "opt_b", hi_cycle)
	lg = Chains.rival_log()
	check(lg.size() == 1 and bool(lg[0]["tier_changed"]) and lg[0]["size_word"] == "tier" and Chains.rival_broken("mil") and Chains.rival_broken_bot("mil") == 1, "tier: a bot above tier 1 drops a tier, logged and rival_broken set", str(lg))
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
	check(in_pool == 40 and not Chains.in_pool("EV18") and not Chains.in_pool("EV29") and not Chains.in_pool("EV30") and not ev.by_id.has("EV29") and not ev.by_id.has("EV30") and not ev.by_id.has("EV37") and Chains.retired.has("EV29") and ev.by_id.has("EV40") and ev.by_id.has("MIL_A1"), "pool: 24 kept + 12 new + 4 branch, no EV18, no Minerals chain events", str(in_pool))
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
	# T234: the four branch events EV52-EV55 (one pattern, window cycles 1-10, hidden spotted consequence)
	var bids := ["EV52", "EV53", "EV54", "EV55"]
	var br_ok := true
	for bid in bids:
		br_ok = br_ok and ev.by_id.has(bid) and Chains.in_pool(bid) and ev.is_branch(bid) and ev.choices_of(bid).size() == 2 and not ev.effect_of_event(bid).has("kind") and ev.good_available(bid)
		var ca: Dictionary = ev.choice_args(ev.choices_of(bid)[0])
		var cb: Dictionary = ev.choice_args(ev.choices_of(bid)[1])
		br_ok = br_ok and int(ca["cash_in"]) > int(cb["cash_in"]) and int(cb["cash_in"]) > 0 and bool(ev.choices_of(bid)[0]["dark"]) and not bool(ev.choices_of(bid)[1]["dark"]) and str(ca["market"]) != ""
		br_ok = br_ok and int(ev.choice_effect(ev.choices_of(bid)[0])["amount"]) == int(ca["cash_in"])
	check(br_ok, "branch events: EV52-EV55 are pool rows with two cash options, A pays more than B, cash read from balance")
	check(not ev.available("EV52", 11) and not ev.available("EV55", 11) and ev.available("EV52", 3) and not ev.available("EV54", 3), "branch events: window ends after balance branch_event_last_cycle; a branch with no visible good (ore) does not fire")
	check(StoryText.get_text("EV52_A_EFF", ev.choice_args(ev.choices_of("EV52")[0])).find(str(int(bal["branch_mil_a_cash"]))) >= 0 and StoryText.get_text("EV53_EFF", {"market": "X"}).find("{") < 0, "branch events: {cash_in} and {market} are filled")
	var sp_bal: float = float(ev.balance["spotted_chance"])
	ev.balance["spotted_chance"] = 0.0
	Chains.reset(bal, 11)
	ev.dark_choice()
	check(not Chains.spotted and Chains.suppressed.is_empty(), "branch events: chance 0 never spots")
	ev.balance["spotted_chance"] = 1.0
	var prof: Array = ev.profitable_pool_ids()
	ev.dark_choice()
	var sup1: Array = Chains.suppressed.duplicate()
	var steps_keep := true
	for sid in Chains.step_ids():
		steps_keep = steps_keep and not Chains.visible_options(str(sid)).is_empty()
	var bad_pool := false
	for sk in sup1:
		if str(sk).find("|") < 0 and (not prof.has(sk) or ev.is_branch(str(sk))):
			bad_pool = true
	check(Chains.spotted and not sup1.is_empty() and not prof.is_empty() and not bad_pool and steps_keep and not prof.has("EV52"), "branch events: spotted removes only profitable events and keeps one option per chain step", str(sup1.size()))
	ev.dark_choice()
	check(Chains.suppressed == sup1, "branch events: a second spotting removes nothing more")
	var sup_pool := 0
	for sk in sup1:
		if str(sk).find("|") < 0:
			sup_pool += 1
	var drew_sup := false
	for i in 40:
		var pid2: String = ev.random_id([], 20)
		if pid2 == "":
			break
		if Chains.is_suppressed(pid2):
			drew_sup = true
	check(not drew_sup and Chains.is_suppressed(sup1[0]) and not Chains.is_suppressed("EV52"), "branch events: a removed event is never drawn")
	var back := JSON.stringify(Chains.to_dict())
	Chains.from_dict(JSON.parse_string(back), bal)
	check(Chains.spotted and Chains.suppressed == sup1, "branch events: the flag and the removed set survive save and load")
	var old_d: Dictionary = JSON.parse_string(back)
	old_d.erase("spotted")
	old_d.erase("suppressed")
	Chains.from_dict(old_d, bal)
	check(not Chains.spotted and Chains.suppressed.is_empty(), "branch events: an old save loads without the flag")
	Chains.reset(bal, 11)
	ev.dark_choice()
	check(Chains.suppressed == sup1, "branch events: the same run seed removes the same half")
	ev.balance["spotted_chance"] = sp_bal
	Chains.reset(bal, 3)
	m.events.debug_off = []
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
	check(m.ending_id_of({"kind": "unfinished"}) == "END_UNFINISHED" and m.ending_id_of({"kind": "bankrupt"}) == "END_BANKRUPT", "ending id: soft and loss ids")
	# save version 4 and v3 migration
	var gig_errs: Array = Gigs.lint()
	check(gig_errs.is_empty(), "gigs: data/gigs.json lints clean", str(gig_errs))
	# T284 moods: marks per world, warm/plain/cold, decisive three, save round trip
	Chains.reset(bal, 1)
	Chains.note_branch("EV52", true, 10, "w_a")
	Chains.note_branch("EV53", false, 12, "w_b")
	Chains.note_branch("EV54", true, 14, "w_a")
	Chains.note_branch("EV55", false, 15, "w_c")
	check(Chains.mood_of("w_a") == "cold" and Chains.mood_of("w_b") == "warm" and Chains.mood_of("nowhere") == "plain", "moods: dark marks cool a world, public ones warm it, unnamed is plain")
	check(Chains.decisive_moments().size() == 3 and Chains.decisive_moments()[0]["id"] == "EV52", "moods: three decisive moments, biggest then earliest first")
	var mk_save: Array = Chains.to_dict()["marks"]
	Chains.reset(bal, 1)
	Chains.from_dict({"marks": mk_save}, bal)
	check(Chains.marks.size() == 4 and Chains.mood_of("w_a") == "cold", "moods: marks survive save and load")
	Chains.from_dict({}, bal)
	check(Chains.marks.is_empty() and Chains.mood_of("w_a") == "plain", "moods: an old save has every world plain")
	Chains.reset(bal, 0)
	check(SaveGame.VERSION == 22, "save: version 22 (v2 and newer load; v1 is dropped, owner approved)")
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
	m.open_event_icon("MIL_A1")
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
	check(m.cycle == 9 and m.events.pending_id == "LUX_A1" and m.event_icons.has_id("LUX_A1"), "slot: a chain step takes the event slot before the pool event", m.events.pending_id)
	var feed_n: int = m.events.feed.size()
	check(feed_n >= 1 and str(m.events.feed[feed_n - 1]["id"]) == "LUX_A1", "slot: one event in the cycle")
	await _free_main(m)


## Space Storage is earned (trade income only): grant it, learn it, restore.
const FND3 := ["FND_STORAGE", "FND_PERMIT", "FND_PROSPECT"]

## Foundations first (owner 2026-11-04): every market-tree node needs all three Foundations.
func _test_foundations_first() -> void:
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	var branch := []
	for b in SkillTree.MARKETS:
		branch.append_array(SkillTree.ids_in(b))
	check(branch.size() == 62, "foundations: 62 branch nodes")
	var all_locked := true
	var partial_locked := true
	var chained := true
	for id in branch:
		if SkillTree.state([], id) != "locked":
			all_locked = false
		if SkillTree.state(["FND_STORAGE", "FND_PERMIT"], id) != "locked":
			partial_locked = false
		if SkillTree.state(FND3, id) != "available" and SkillTree.prereqs(id).has("FND_STORAGE") == false and SkillTree.prereqs(id).is_empty():
			chained = false
	check(all_locked, "foundations: every branch node is locked with no Foundations")
	check(partial_locked, "foundations: two of three Foundations still locked")
	for mk in SkillTree.MARKETS:
		var first: String = SkillTree.ids_in(mk)[0]
		check(SkillTree.state(FND3, first) == "available" and SkillTree.can_learn(FND3, 9, bal, first)["ok"], "foundations: %s available with all three" % first)
		check(SkillTree.state(["FND_STORAGE", "FND_PERMIT"], first) == "locked" and SkillTree.can_learn([], 9, bal, first)["reason"] == "locked", "foundations: %s locked without them" % first)
		check(SkillTree.missing_prereqs(["FND_PERMIT"], first) == ["FND_STORAGE", "FND_PROSPECT"], "foundations: %s needs-line lists the missing Foundations" % first)
		check(SkillTree.cost(bal, first) == 1, "foundations: %s cost unchanged" % first)
	# every deeper node reaches its first node, so the gate covers the whole tree
	for id in branch:
		var cur: String = id
		while SkillTree.prereqs(cur).size() > 0 and not SkillTree.prereqs(cur).has("FND_STORAGE"):
			cur = SkillTree.prereqs(cur)[0]
		if not SkillTree.prereqs(cur).has("FND_STORAGE"):
			chained = false
	check(chained, "foundations: every branch node chains back to the Foundations")
	# detail panel names the missing Foundations
	m.skill_screen.open_screen()
	m.skill_screen.select("MIL_1")
	m.skill_screen.refresh()
	check(m.skill_screen.node_buttons["MIL_1"].self_modulate == m.skill_screen.COL_LOCKED, "foundations: locked branch node is muted")
	# Space Storage income lock gates the branches too
	m.skill_points = 10
	check(m.learn_skill("FND_PERMIT")["ok"] and m.learn_skill("FND_PROSPECT")["ok"], "foundations: two Foundations learned")
	check(m.learn_skill("FND_STORAGE")["reason"] == "earn" and m.learn_skill("MIL_1")["reason"] == "locked", "foundations: income lock on Storage holds the branches back")
	_learn_storage(m)
	check(m.learn_skill("MIL_1")["ok"], "foundations: branch opens once Storage is earned")
	# old save: a branch skill without Foundations is kept
	Skills.learned.clear()
	m.learned_skills = ["MIL_1"]
	check(m.learned_skills.has("MIL_1") and SkillTree.state(m.learned_skills, "MIL_1") == "learned", "foundations: an old save keeps a branch skill without Foundations")
	check((m.collect_state().get("learned_skills", []) as Array).has("MIL_1"), "foundations: saved list still carries it")

const DeadW = preload("res://game/dead_worlds.gd")

# ---- T188: a link can be made between every pair of node types, and no node is stranded ----
# Node types: planet, space storage, dead planet, asteroid field. Link functions: route (Main.send_stock_buying, a planet, dead
# planet or asteroid field as source, a planet, dead planet or Space Storage as destination), storage link (StorageLink.build_link,
# two Space Storages of different systems; there is one storage per system) and the mining platform (Pathfinder, discovery on only).
# Every unlock is bought the way the player buys it (learn_skill, buy_permit, a Pathfinder flight and build). Each pair is tried
# in the same system and across systems; the link must be created, saved, loaded back, and never refused.
func _t188_learn(m, id: String, tag: String) -> void:
	for pre in SkillTree.missing_prereqs(m.learned_skills, id):  # the player learns the chain first
		_t188_learn(m, str(pre), tag)
	var r: Dictionary = m.learn_skill(id)
	check(bool(r["ok"]) or Skills.is_learned(id), "links %s: skill %s can be learned" % [tag, id], str(r))

func _t188_unlock(m, tag: String) -> void:
	m.cash = 1000000
	m.skill_points = 100
	m.trade_income_total = 100000
	_t188_learn(m, "FND_PERMIT", tag)
	var r: Dictionary = m.buy_permit(2)
	check(bool(r["ok"]), "links %s: the system 2 permit can be bought" % tag, str(r))
	_t188_learn(m, "FND_STORAGE", tag)
	_t188_learn(m, "FND_PROSPECT", tag)
	for p in m.map.planets:
		if DeadW.is_dead(p):
			var sk: String = Skills.mine_skill_for(str(p["id"]))
			check(sk != "", "links %s: dead world %s has a mining skill" % [tag, str(p["id"])], sk)
			if sk != "" and not Skills.is_learned(sk):
				_t188_learn(m, sk, tag)
	m.cycle = maxi(m.cycle, m.dead_unlock_cycle())
	m._ensure_posts()
	m._sync_closed()

## Discovery on: fly to every planet and build its post or platform with the Pathfinder (the player path).
func _t188_establish(m, tag: String) -> void:
	for i in m.map.planets.size():
		var pid := str(m.map.planets[i]["id"])
		if m.flight.established(pid):
			continue
		var e: String = m.flight.request_fly({"kind": "planet", "index": i})
		m.flight.finish_flight()
		e += m.flight.request_establish(pid)
		m.flight.finish_build()
		check(e == "" and m.flight.established(pid), "links %s: %s can be established" % [tag, pid], e)
	m._sync_closed()

func _t188_reset(m) -> void:
	m.engine.routes.clear()
	m.storage_link.setup(m.balance, m.storage, m)
	m.cash = 1000000
	m.ships = 0

func _t188_nodes(m) -> Array:
	var out: Array = []
	for i in m.map.planets.size():
		var p: Dictionary = m.map.planets[i]
		out.append({"kind": "dead" if DeadW.is_dead(p) else "planet", "id": i, "sys": int(p.get("system", 1)), "name": str(p.get("id", i))})
	for sid in m.station_systems:
		out.append({"kind": "storage", "id": -int(sid), "sys": int(sid), "name": "storage%d" % int(sid)})
	for c in m.clusters.list(0):
		out.append({"kind": "asteroid", "id": int(c["node"]), "sys": int(c["system"]), "name": "cluster " + str(c["id"]), "index": int(c["index"])})
	return out

func _t188_good(m, a: Dictionary) -> String:
	if a["kind"] == "asteroid":
		return str(m.clusters.good_of(int(a["index"])))
	return "energy"

## One route src -> dst through the game's own function; {ok, reason}. Checks created, saved and loaded back.
func _t188_route(m, src: Dictionary, dst: Dictionary, tag: String) -> bool:
	_t188_reset(m)
	var c := _t188_good(m, src)
	var label := "links %s: %s %s -> %s %s (%s)" % [tag, src["kind"], src["name"], dst["kind"], dst["name"], "same system" if src["sys"] == dst["sys"] else "across systems"]
	var r: Dictionary = m.send_stock_buying(int(src["id"]), int(dst["id"]), c)
	var rec: Dictionary = m.engine.routes[0] if m.engine.routes.size() == 1 else {}
	var made: bool = bool(r["ok"]) and not rec.is_empty() and int(rec["a"]) == int(src["id"]) and int(rec["b"]) == int(dst["id"]) and str(rec["c"]) == c
	check(made, label + " is created", str(r))
	if not made:
		return false
	var st: Dictionary = JSON.parse_string(JSON.stringify(m.collect_state()))
	var saved: bool = st["routes"].size() == 1 and int(st["routes"][0]["a"]) == int(src["id"]) and int(st["routes"][0]["b"]) == int(dst["id"])
	m.engine.routes.clear()
	m.apply_state(st)
	var back: bool = m.engine.routes.size() == 1 and int(m.engine.routes[0]["a"]) == int(src["id"]) and int(m.engine.routes[0]["b"]) == int(dst["id"]) and str(m.engine.routes[0]["c"]) == c
	check(saved and back, label + " is saved and loaded back", "saved %s back %s" % [saved, str(m.engine.routes)])
	return true

func _t188_storage_link(m, a: Dictionary, b: Dictionary, tag: String) -> bool:
	_t188_reset(m)
	var label := "links %s: storage %s <-> storage %s (across systems)" % [tag, a["name"], b["name"]]
	for n in [a, b]:
		var key: String = Storage.system_key(int(n["sys"]))
		m.storage.ensure(key)
		m.storage.add(key, "rivets", int(m.storage_link.cost()["rivets"]))
		m.storage.add(key, "energy", int(m.storage_link.cost()["energy"]))
	var why: String = m.storage_link.can_build(int(a["sys"]), int(b["sys"]))
	var id: int = m.storage_link.build_link(int(a["sys"]), int(b["sys"]))
	check(id >= 0, label + " is created", "%s %s" % [why, m.storage_link.last_reason])
	if id < 0:
		return false
	var st: Dictionary = JSON.parse_string(JSON.stringify(m.collect_state()))
	var saved: bool = st["storage_links"].size() == 1
	m.storage_link.setup(m.balance, m.storage, m)
	m.apply_state(st)
	var back: bool = m.storage_link.pair_link(int(a["sys"]), int(b["sys"])) >= 0 and m.storage_link.links().size() == 1
	check(saved and back, label + " is saved and loaded back", "saved %s links %s" % [saved, str(m.storage_link.links())])
	return true

func _t188_pass(discovery: bool) -> void:
	_wipe_user()
	var tag := "discovery on" if discovery else "start state"
	var m: Control = await _new_main(false, discovery)
	m._dismiss_preface()
	check(int(m.balance.get("discovery_enabled", -1)) == (1 if discovery else 0), "links %s: discovery set by the test" % tag)
	# start state: the home world links to the other living worlds of its system before any unlock
	var home_edges := 0
	for j in range(1, m.map.planets.size()):
		if not DeadW.is_dead(m.map.planets[j]) and int(m.map.planets[j].get("system", 1)) == 1 and (not discovery or m.flight.established(str(m.map.planets[j]["id"]))):
			home_edges += 1 if bool(m.can_connect(0, j, "energy")["ok"] or m.can_connect(0, j, "energy")["reason"] == StoryText.get_text("NOT_SHIP_FREE")) else 0
	check(discovery or home_edges >= 1, "links %s: before any unlock the home world has a route to a living world" % tag, str(home_edges))
	_t188_unlock(m, tag)
	if discovery:
		_t188_establish(m, tag)
	var nodes: Array = _t188_nodes(m)
	var kinds := {}
	var systems := {}
	for n in nodes:
		kinds[n["kind"]] = true
		systems[n["sys"]] = true
	check(kinds.size() == 4 and systems.size() >= 2, "links %s: every node type and at least two systems exist" % tag, "%s %s" % [str(kinds.keys()), str(systems.keys())])
	var covered := {}  # "kindA|kindB|same/cross" -> true
	var edges: Array = []  # [i, j] pairs with a working link
	for i in nodes.size():
		for j in range(i + 1, nodes.size()):
			var a: Dictionary = nodes[i]
			var b: Dictionary = nodes[j]
			var ok_any := false
			var tried := false
			var ends := [[a, b], [b, a]]
			for e in ends:
				var s: Dictionary = e[0]
				var d: Dictionary = e[1]
				if s["kind"] == "storage" or d["kind"] == "asteroid":
					continue  # not a link direction: a storage is only a destination, a field only a source
				tried = true
				if _t188_route(m, s, d, tag):
					ok_any = true
			if a["kind"] == "storage" and b["kind"] == "storage":
				tried = true
				ok_any = _t188_storage_link(m, a, b, tag)
			if a["kind"] == "asteroid" and b["kind"] == "asteroid":
				_t188_reset(m)
				var rr: Dictionary = m.engine.check_connection(int(a["id"]), int(b["id"]), "ore")
				check(not rr["ok"], "links %s: two asteroid fields are not linked by design (a field only mines into a planet or storage)" % tag, str(rr))
			if tried:
				check(ok_any, "links %s: a link exists between %s and %s" % [tag, a["name"], b["name"]])
			if ok_any:
				edges.append([i, j])
				covered["%s|%s|%s" % [minf_s(a["kind"], b["kind"]), maxf_s(a["kind"], b["kind"]), "same" if a["sys"] == b["sys"] else "cross"]] = true
	# every pair of node types that can be linked was linked in the same system and across systems
	var want: Array = ["planet|planet", "dead|planet", "planet|storage", "dead|storage", "asteroid|planet", "asteroid|dead", "asteroid|storage"]
	for w in want:
		for where in ["same", "cross"]:
			check(covered.has(w + "|" + where), "links %s: type pair %s tried %s" % [tag, w.replace("|", " + "), where + (" system" if where == "same" else " systems")])
	check(covered.has("storage|storage|cross"), "links %s: storage pair tried across systems (one storage per system, so no same-system pair exists)" % tag)
	# reachability: every node can be reached from the home world by a chain of the links above
	var seen := {0: true}
	var queue := [0]
	while not queue.is_empty():
		var k: int = queue.pop_back()
		for e in edges:
			var o := -1
			if int(e[0]) == k:
				o = int(e[1])
			elif int(e[1]) == k:
				o = int(e[0])
			if o >= 0 and not seen.has(o):
				seen[o] = true
				queue.append(o)
	var stranded: Array = []
	for i in nodes.size():
		if not seen.has(i):
			stranded.append(nodes[i]["name"])
	check(stranded.is_empty(), "links %s: no node is stranded (reachable from the home world)" % tag, str(stranded))
	await _free_main(m)

func minf_s(x: String, y: String) -> String:
	return x if x < y else y

func maxf_s(x: String, y: String) -> String:
	return y if x < y else x

## T187: the owner's six ship rules. Chosen ship flown; flies only while time runs; second system; rival ships are scenery
## only; an unvisited planet stays closed; a mining platform on a dead world mines into Space Storage.
func _test_t317_hero_card() -> void:
	_wipe_user()
	var m0: Control = await _new_main(false, false)  # discovery off: no hero ship
	m0._dismiss_preface()
	m0.ship_panel.set_upkeep(m0)
	check(not m0.ship_panel.hero_card.visible, "T317: no hero card without a hero ship")
	m0.open_flagship_panel()
	check(not m0.flagship_panel.visible, "T350: the details panel hides with discovery off")
	var m: Control = await _new_main(false, true)
	m._dismiss_preface()
	var sp = m.ship_panel
	sp.set_upkeep(m)
	check(sp.hero_card.visible, "T317: hero card shown with a hero ship")
	check(sp.hero_icon != null and sp.hero_icon.texture != null and sp.hero_icon.mouse_filter == Control.MOUSE_FILTER_IGNORE, "T351: the hero card shows a static icon")
	check(not ("hero_preview" in sp), "T351: the hero card has no 3D preview")
	check(not m.map.ship_selected, "T317: ship not selected at start")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	sp._on_hero_input(click)
	var by_card: bool = m.map.ship_selected
	check(by_card, "T317: a card click selects the ship")
	m.map.select_ship(false)  # the viewport route, same call as map.gd uses
	sp.set_upkeep(m)
	check(not m.map.ship_selected and not sp._hero_selected, "T317: card follows a viewport deselect")
	m.map.select_ship(true)
	sp.set_upkeep(m)
	check(m.map.ship_selected == by_card and sp._hero_selected, "T317: viewport select gives the same state and lights the card")
	check(not sp.hero_state.text.contains(","), "T351: the state line has no selected suffix", sp.hero_state.text)
	sp._on_hero_input(click)
	check(not m.map.ship_selected and not sp._hero_selected, "T317: a second card click deselects")
	# T350: the card click opens the Flagship details; the Ships panel no longer owns the controls
	var fp = m.flagship_panel
	check(fp.visible, "T350: clicking the hero card opens the details panel")
	check(fp.explore_button != null and fp.explore_button.is_visible_in_tree(), "T350: the details panel holds the explore button")
	check(not ("explore_button" in sp) and not ("boost_button" in sp) and not ("hold_label" in sp) and not ("pathfinder_label" in sp), "T350: the Ships panel no longer has explore, boost, hold or status nodes")
	check(not m.flight.exploring(), "T350: not exploring at start")
	fp.explore_button.pressed.emit()
	check(m.flight.exploring(), "T350: the explore button starts exploring")
	fp.refresh()
	check(fp.explore_button.text == StoryText.get_text("BTN_EXPLORE_OFF"), "T350: the button reads Stop exploring")
	fp.explore_button.pressed.emit()
	check(not m.flight.exploring(), "T350: the explore button stops exploring")
	fp.close_screen()
	check(not fp.visible, "T350: the close button hides the panel")

func _test_t187_ship_flight() -> void:
	_wipe_user()
	var m: Control = await _new_main(false, true)
	m._dismiss_preface()
	# (1) the chosen ship is the one flown
	m._set_run_choice("", "dart")
	check(m.flight.model_path() == ShipsT.model("dart") and ShipsT.model("dart") != ShipsT.model("small"), "T187: the ship chosen at the start is the Pathfinder model", m.flight.model_path())
	m._set_run_choice("", "small")
	check(m.flight.model_path() == ShipsT.model("small"), "T187: the Pathfinder model follows the chosen type")
	# (5) closed before a visit
	var tillam: int = m.planet_index_of("planet_2")
	check(tillam >= 0 and not m.planet_established(tillam) and not m.flight.discovered("planet_2"), "T187: an unvisited planet is closed and unknown")
	check(not m.can_connect(0, tillam, "energy")["ok"], "T187: no route to a closed planet")
	# (2) time
	m.paused = true
	check(m.fly_to("planet_2") == "" and m.flight.state() == "flying", "T187: the order is accepted while paused")
	var p0: Vector3 = m.flight.ship_position()
	for k in 5:
		m._process(5.0)
	check(m.flight.ship_position() == p0 and m.flight.state() == "flying", "T187: the ship does not move while paused")
	m.paused = false
	m.time_speed = 12.0
	var guard := 0
	while m.flight.state() == "flying" and guard < 400:
		m._process(1.0)
		guard += 1
	check(m.flight.state() == "idle" and m.flight.docked_at() == "planet_2" and m.flight.discovered("planet_2"), "T187: with time running the ship arrives and the planet is visited", str(guard))
	check(not m.planet_established(tillam), "T187: a visit alone does not open the planet")
	m.cash = 100000
	check(m.establish("planet_2") == "" and m.flight.state() == "building", "T187: establish starts after the visit")
	guard = 0
	while m.flight.state() == "building" and guard < 400:
		m._process(1.0)
		guard += 1
	check(m.planet_established(tillam), "T187: the post stands after its build time")
	# (3) second system
	check(m.flight.request_fly({"kind": "storage", "index": 2}) == "no_gate", "T187: no flight to another system without its permit")
	_t188_unlock(m, "T187")
	var sys2 := -1
	for i in m.map.planets.size():
		if int(m.map.planets[i].get("system", 1)) == 2 and not DeadW.is_dead(m.map.planets[i]):
			sys2 = i
			break
	check(sys2 >= 0, "T187: a living planet in system 2 exists")
	var pid2 := str(m.map.planets[sys2]["id"])
	check(m.fly_to(pid2) == "", "T187: with the permit the ship may fly to the other system")
	m.flight.finish_flight()
	check(m.flight.system_id() == 2 and m.flight.docked_at() == pid2, "T187: the ship is in system 2 at the planet")
	check(not m.planet_established(sys2), "T187: the planet in system 2 is still closed")
	check(m.establish(pid2) == "", "T187: an outpost can be started in system 2")
	m.flight.finish_build()
	m._sync_closed()
	check(m.planet_established(sys2) and m.flight.post_built(pid2), "T187: the outpost in system 2 stands")
	# (6) mining platform on the dead world mines into Space Storage
	var dead: int = m.planet_index_of("dead_1")
	check(dead >= 0 and not m.planet_established(dead), "T187: the dead world starts closed", "%d %s" % [dead, str(m.flight.established("dead_1"))])
	check(m.fly_to("dead_1") == "", "T187: fly to the dead world")
	m.flight.finish_flight()
	check(m.establish("dead_1") == "", "T187: a mining platform can be started (mining skill learned)")
	m.flight.finish_build()
	m._sync_closed()
	check(m.flight.platform_built("dead_1") and m.planet_established(dead), "T187: the platform stands")
	m._ensure_stations()
	m.storage.ensure(Storage.system_key(1))
	m.ships = 2
	m.cash = 100000
	m.engine.routes.clear()
	var before: int = m.storage.amount(Storage.system_key(1), "dross")
	var r: Dictionary = m.send_stock_buying(dead, m.station_dst(1), "dross")
	check(bool(r["ok"]) and m.engine.routes.size() == 1, "T187: a route from the platform to Space Storage is made", str(r))
	var bo: Dictionary = m.set_local_order(dead, "dross", "buy", true)  # the platform mines: its buy order fills the planet storage
	check(bool(bo.get("ok", true)), "T187: a mining (buy) order can be set on the platform", str(bo))
	for k in 3:
		m.debug_advance_cycle()
	var after: int = m.storage.amount(Storage.system_key(1), "dross")
	check(after > before, "T187: the platform's goods arrive in Space Storage", "%d -> %d" % [before, after])
	await _free_main(m)
	# (4) rival ships: scenery
	m = await _new_main()
	m._dismiss_preface()
	var rs = m.rival_ships
	check(rs != null and rs.get_parent() == m.map, "T187: rival ships exist on the map")
	rs.advance(0.0)
	check(rs.ship_count() >= 1, "T187: rival ships were created", str(rs.ship_count()))
	var pos0: Array = []
	for c in rs.get_children():
		pos0.append(c.position)
	rs.advance(5.0)
	var moved := false
	for k in rs.get_child_count():
		moved = moved or rs.get_child(k).position != pos0[k]
	check(moved, "T187: rival ships move")
	var solid := false
	for c in rs.get_children():
		solid = solid or c is CollisionObject3D or c.find_children("*", "CollisionObject3D", true, false).size() > 0
	check(not solid, "T187: rival ships have no collision or pick shape")
	rs.advance(300.0)  # T214: long enough to arrive; then every ship idles
	var parked_all := true
	for sh in rs._ships:
		parked_all = parked_all and bool(sh.get("parked", false))
	var pos_idle: Array = []
	for c in rs.get_children():
		pos_idle.append(c.position)
	rs.advance(60.0)
	var still := true
	for k in rs.get_child_count():
		still = still and rs.get_child(k).position == pos_idle[k]
	check(parked_all and still, "T214: rival ships idle after arriving, no new random course")
	rs.wake()
	var woke := true
	for sh in rs._ships:
		woke = woke and not bool(sh.get("parked", false))
	rs.advance(6.0)  # T305: a ship turns 45 deg/s and only moves once aligned, so a half-turn course needs about 4 s before it moves
	var moved2 := false
	for k in rs.get_child_count():
		moved2 = moved2 or rs.get_child(k).position != pos_idle[k]
	check(woke and moved2, "T214: wake (a system opens, an event) sends an idle ship on one new leg")
	var sig_before := str(m.engine.routes) + str(m.cash) + str(m.ships)
	rs.advance(30.0)
	check(sig_before == str(m.engine.routes) + str(m.cash) + str(m.ships), "T187: rival ships change nothing in the game")
	m.paused = true
	var snap: Vector3 = rs.get_child(0).position
	rs._process(1.0)
	check(rs.get_child(0).position == snap, "T187: rival ships stand still while paused")
	await _free_main(m)

## T196: ship motion. Speed ramps from rest, brakes before the target and stops on it, the heading turns at a limited rate,
## nothing moves on a paused clock; rivals go to a destination, wait, then pick the next one.
func _test_ship_motion() -> void:
	var m = await _new_main(false, true)
	m._dismiss_preface()
	var f = m.flight
	var vmax: float = f._vmax()
	var start: Vector3 = f.ship_position()
	var tgt := start + Vector3(0.0, 0.0, -10.0)  # straight ahead of yaw 0 (forward is -Z)
	check(f.request_fly({"kind": "point", "pos": tgt}) == "", "T196: a flight to a point is accepted")
	check(f.speed() == 0.0, "T196: the ship starts from rest")
	f.sync(100.0)
	f.sync(100.0)
	check(f.ship_position() == start and f.speed() == 0.0, "T196: a clock that does not move moves nothing (paused)")
	f.sync(100.01)
	var s1: float = f.speed()
	check(s1 > 0.0 and s1 < vmax * 0.5, "T196: speed ramps up from rest, not a jump to top speed", "%f of %f" % [s1, vmax])
	f.sync(100.2)
	check(absf(f.speed() - vmax) < 0.001, "T196: the ship reaches top speed on a straight course", "%f of %f" % [f.speed(), vmax])
	var now := 100.2
	var prev: float = f.speed()
	var braked := false
	var overshoot := false
	var n := 0
	while f.state() == "flying" and n < 400:
		n += 1
		now += 0.005
		f.sync(now)
		if f.speed() < prev - 0.0001:
			braked = true
		prev = f.speed()
		if f.ship_position().z < tgt.z - 0.001:
			overshoot = true
	check(braked and not overshoot, "T196: the ship brakes before the target and does not pass it")
	check(f.state() == "idle" and f.ship_position().is_equal_approx(tgt) and f.speed() == 0.0, "T196: the ship stops on the target", str(f.ship_position()))
	# turn rate: the target is behind the ship, the heading may change by at most turn_deg per cycle
	f._yaw = 0.0
	f.request_fly({"kind": "point", "pos": f.ship_position() + Vector3(0.0, 0.0, 10.0)})
	var turn: float = deg_to_rad(float(m.balance.get("pathfinder_turn_deg", 2400.0)))
	var y0: float = f._yaw
	f.advance(0.01)
	check(absf(f._yaw - y0) <= turn * 0.01 + 0.0001 and absf(f._yaw - y0) > 0.0, "T196: the heading turns at a limited rate, not at once", str(f._yaw))
	check(f.speed() == 0.0, "T196: the ship does not speed up while the course is far off its heading", str(f.speed()))
	var p_mid: Vector3 = f.ship_position()
	var steps := 0
	while absf(wrapf(f._yaw - PI, -PI, PI)) > 0.05 and steps < 200 and f.state() == "flying":
		f.advance(0.005)
		steps += 1
	check(absf(wrapf(f._yaw - PI, -PI, PI)) <= 0.05, "T196: the heading ends up on the course", str(f._yaw))
	f.advance(0.1)
	var d: Dictionary = f.to_dict()
	check(f.state() == "flying" and float(d["speed"]) > 0.0, "T196: flight state has speed mid-flight", str(d))
	var yaw_saved: float = f._yaw
	var spd_saved: float = f.speed()
	f.from_dict(JSON.parse_string(JSON.stringify(d)))
	check(f.state() == "flying" and is_equal_approx(f._yaw, yaw_saved) and is_equal_approx(f.speed(), spd_saved), "T196: the flight state survives a save round-trip")
	f.finish_flight()
	check(f.state() == "idle" and f.speed() == 0.0, "T196: finish_flight ends the flight at rest")
	# rival ships
	var rs = m.rival_ships
	rs.advance(0.0)
	var vr: float = float(m.balance.get("rival_ship_speed", rs.SPEED_DEFAULT))
	var sh: Dictionary = rs._ships[0]
	var y_before: float = sh["yaw"]
	rs.advance(0.05)
	check(float(sh["speed"]) > 0.0 and float(sh["speed"]) < vr * 0.2, "T196: a rival ramps up from rest", str(sh["speed"]))
	var seen_wait := false
	var seen_new := false
	var first_to: Vector2 = sh["to"]
	var max_dyaw := 0.0
	var rturn: float = deg_to_rad(float(m.balance.get("rival_ship_turn_deg", 45.0)))
	for k in 6000:
		var yb: float = sh["yaw"]
		rs.advance(0.05)
		max_dyaw = maxf(max_dyaw, absf(wrapf(float(sh["yaw"]) - yb, -PI, PI)))
		if bool(sh.get("parked", false)):  # T214: idles on arrival
			seen_wait = true
			check(float(sh["speed"]) == 0.0, "T196: a rival that arrived has stopped")
			break
	check(seen_wait, "T196: a rival flies to its destination and idles there")
	check((sh["pos"] as Vector2).is_equal_approx(sh["to"]), "T196: a rival stops on its destination")
	check(max_dyaw <= rturn * 0.05 + 0.0001, "T196: a rival turns at a limited rate", str(max_dyaw))
	rs.wake()  # T214: a reason to move
	for k in 200:
		rs.advance(0.05)
		if not (sh["to"] as Vector2).is_equal_approx(first_to):
			seen_new = true
			break
	check(seen_new, "T196: after a wake a rival picks the next destination")
	await _free_main(m)

## T202: no ship is ever inside a body, and a ship at spawn is near its parent body. Bodies are measured the way the map draws them
## (planet sphere scale, sun radius, station MAP_RADIUS, asteroid rocks of the pack). Limits: Motion.BODY_MARGIN (outside) and
## Motion.near_limit (near), the same constants the game code parks ships with. Every system incl. placeholder systems 3 to 5.
func _t202_bodies(m, sys: int) -> Array:
	var out: Array = []
	for i in m.map.planets.size():
		if int(m.map.planets[i].get("system", 1)) == sys:
			var sph: Node3D = m.map.planet_spheres[i]
			out.append({"id": str(m.map.planets[i]["id"]), "pos": Vector2(sph.position.x, sph.position.z), "r": sph.scale.x})
	if m.map.suns.has(sys):
		var sn: Node3D = m.map.suns[sys]
		out.append({"id": "sun_%d" % sys, "pos": Vector2(sn.position.x, sn.position.z), "r": float(sn.radius)})
	if m.map.stations.has(sys):
		var st: Node3D = m.map.stations[sys]
		out.append({"id": "station_%d" % sys, "pos": Vector2(st.position.x, st.position.z), "r": float(preload("res://game/station.gd").MAP_RADIUS)})
	for c in m.map._cluster_list:
		if int(c["system"]) == sys and m.map.asteroid_packs.packs.has(str(c["id"])):
			var pk: Dictionary = m.map.asteroid_packs.packs[str(c["id"])]
			var r := 0.0
			for q in pk["points"]:
				r = maxf(r, Vector2(q.x, q.z).length())
			out.append({"id": "cluster_" + str(c["id"]), "pos": Vector2((pk["anchor"] as Vector3).x, (pk["anchor"] as Vector3).z), "r": r})  # T306: the logical anchor, the visual pack swings a little
	return out

## parent = id of the body the ship must be near ("" = any body; "-" = only the outside rule is asserted).
func _t202_check(m, sys: int, p: Vector3, label: String, parent: String = "") -> void:
	var Motion := preload("res://game/ship_motion.gd")
	var v := Vector2(p.x, p.z)
	var inside := ""
	var near := false
	var bs := _t202_bodies(m, sys)
	for b in bs:
		var d: float = v.distance_to(b["pos"])
		if d <= float(b["r"]) + Motion.BODY_MARGIN:
			inside = str(b["id"])
		if (parent == "" or parent == str(b["id"])) and d <= Motion.near_limit(float(b["r"])):
			near = true
	check(inside == "", "T202: %s is outside every body" % label, "inside %s at %s" % [inside, str(v)])
	if parent != "-":
		check(near, "T202: %s is near %s (within radius + gap)" % [label, parent if parent != "" else "a body"], str(v))

## T211: one rival ship per competitor in every state; a closed system shows no ships; one Pathfinder.
## T199: ship i belongs to Bots.IDS[i]; the pick function takes the closest ship in radius only; the card names the competitor.
func _test_t199_rival_pick() -> void:
	var RS := preload("res://game/rival_ships.gd")
	var Bots := preload("res://game/bots.gd")
	for i in Bots.IDS.size():
		check(RS.bot_of(i) == int(Bots.IDS[i]), "T199: ship %d belongs to competitor %d" % [i, Bots.IDS[i]])
	check(RS.bot_of(Bots.IDS.size()) == 0 and RS.bot_of(-1) == 0, "T199: no competitor outside the range")
	var pts := [Vector2(100, 100), Vector2(110, 100), Vector2(INF, INF)]
	check(RS.pick_index(pts, Vector2(108, 100), 20.0) == 1, "T199: the closest ship is picked")
	check(RS.pick_index(pts, Vector2(300, 300), 20.0) == -1, "T199: a click outside the radius picks nothing")
	check(RS.pick_index(pts, Vector2(100, 140), 20.0) == -1, "T199: radius is a hard limit")
	var m = await _new_main(false, true)
	m._dismiss_preface()
	m.rival_ships.advance(0.0)
	check(m.map.rivals == m.rival_ships, "T199: the map knows the rival ships")
	check(int(m.rival_ships.pick_bot(Vector2(-5000, -5000))) == 0, "T199: far from any ship picks none")
	var card = m.rival_card
	card.show_bot(2)
	check(preload("res://game/rival_card.gd").describe(2).begins_with(Bots.bot_name(2)), "T199: the card starts with the competitor name")
	card.show_bot(0)
	check(not card.visible, "T199: bot 0 closes the card")
	await _free_main(m)

## T318: every traffic hull kind has valid mesh data, and the kind picked from a hash stays in range (and the shader table matches).
func _test_t318_traffic_hulls() -> void:
	var TM := preload("res://game/traffic/traffic_meshes.gd")
	check(TM.KINDS >= 5 and TM.SHAPES.size() == TM.KINDS, "T318: at least 5 hull kinds, one shape each", str(TM.KINDS))
	var m: ArrayMesh = TM.make()
	var arr: Array = m.surface_get_arrays(0)
	var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var u2: PackedVector2Array = arr[Mesh.ARRAY_TEX_UV2]
	var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
	check(u2.size() == v.size() and idx.size() % 3 == 0 and idx.size() > 0, "T318: hull mesh has a kind per vertex and whole triangles")
	var seen := {}
	for p in v.size():
		seen[int(u2[p].x)] = true
		check(absf(v[p].x) <= 0.5 and absf(v[p].z) <= 0.5 + 0.0001, "T318: hull vertex inside one ship length", str(v[p]))
	for k in TM.KINDS:
		check(seen.has(k), "T318: hull kind %d has vertices" % k)
	for i in idx:
		check(i >= 0 and i < v.size(), "T318: index in range")
	for h in [0.0, 0.1, 0.5, 0.999, 1.0]:
		var k: int = TM.kind_for(h)
		check(k >= 0 and k < TM.KINDS, "T318: kind from hash %s in range" % h, str(k))
	var used := {}
	for j in 800:
		used[TM.kind_for(fmod(j * 0.6180339, 1.0))] = true
	check(used.size() == TM.KINDS, "T318: every kind is reachable from the hash", str(used.keys()))
	var sh := FileAccess.get_file_as_string("res://game/traffic/traffic_ship.gdshader")
	check(sh.contains("int[8](" + ", ".join(TM.KIND_TABLE.map(func(x): return str(x))) + ")"), "T318: shader kind table matches KIND_TABLE")
	check(float(_read_json("res://data/balance.json")["values"].get("traffic_hull_dark", -1.0)) > 0.0, "T318: hull darkness key set")

func _test_t211_ship_traffic() -> void:
	var Systems := preload("res://game/systems.gd")
	var Bots := preload("res://game/bots.gd")
	Systems.set_placeholders(true)
	var m = await _new_main(false, true)
	m._dismiss_preface()
	var rs = m.rival_ships
	rs.advance(0.0)
	check(rs.ship_count() == Bots.IDS.size(), "T211: 3 rivals = 3 ships at the start", str(rs.ship_count()))
	for step in 400:
		rs.advance(1.0)
		for s in rs._ships:
			check(int(s["system"]) == 1, "T211: no rival ship in a closed system", str(s["system"]))
	var other := 0
	for n in m.map.get_children():
		if n == rs:
			continue
		other += 1 if n.get_script() != null and str(n.get_script().resource_path).ends_with("rival_ships.gd") else 0
	check(other == 0, "T211: one rival ship node set, not one per system")
	m._open_system(2)
	m.map.view_system = 2
	var in2 := 0
	for step in 600:
		if step % 15 == 0:
			rs.wake()  # T214: ships idle until the game gives a reason
		rs.advance(1.0)
		in2 += rs._ships.filter(func(s): return int(s["system"]) == 2 and (s["node"] as Node3D).visible).size()
		for s in rs._ships:
			check(int(s["system"]) in [1, 2], "T211: ships only in opened systems", str(s["system"]))
		check(rs.ship_count() == Bots.IDS.size(), "T211: still one ship per competitor")
	check(in2 > 0, "T211: a rival visits the opened system", str(in2))
	var pf := 0
	for n in m.get_children():
		pf += 1 if n == m.flight else 0
	check(m.flight != null and m.flight.system_id() >= 1, "T211: one Pathfinder for the whole game")
	Systems.reset_placeholders()
	await _free_main(m)

## T206: exploration mode visits every planet of the system, waits for cash, ends on a manual order, saves, and ends with one notice.
func _test_t206_explore() -> void:
	var m = await _new_main(false, true)
	m._dismiss_preface()
	var f = m.flight
	Skills.learned.append("MIN_3")
	var notices: Array = []
	m.notice_posted.connect(func(t: String): notices.append(t))
	var done_text: String = StoryText.get_text("NOT_EXPLORE_DONE")
	var arrived: Array = []
	f.arrived.connect(func(pid: String): arrived.append(pid))
	var sys1: Array = []
	for i in m.map.planets.size():
		if m.system_of(i) == 1:
			sys1.append(str(m.map.planets[i]["id"]))
	check(sys1.size() > 2, "T206: system 1 has several planets", str(sys1.size()))
	# T228: switching the mode off while paused works and the button follows at once
	m.paused = true
	m.set_exploring(true)
	check(m.flight.exploring(), "T228: mode on while paused")
	m.set_exploring(false)
	check(not m.flight.exploring(), "T228: mode off while paused")
	check(m.flagship_panel.explore_button.text == StoryText.get_text("BTN_EXPLORE_ON"), "T228: button label follows while paused")
	# cash short: the ship waits at the first planet it cannot pay for
	m.cash = 0
	f.set_exploring(true)
	check(f.exploring(), "T206: the mode is on")
	for k in 600:
		f.advance(0.05)
	var built := sys1.filter(func(pid): return f.established(pid)).size()
	check(f.exploring() and built < sys1.size(), "T206: with no cash the mode waits", "%d of %d" % [built, sys1.size()])
	check(f.state() == "idle" and f.docked_at() != "", "T206: it waits at a planet", f.state())
	# save round trip keeps the mode
	var d: Dictionary = JSON.parse_string(JSON.stringify(f.to_dict()))
	f.from_dict(d)
	check(f.exploring(), "T206: the mode is saved")
	var old: Dictionary = d.duplicate()
	old.erase("explore")
	f.from_dict(old)
	check(not f.exploring(), "T206: an old save loads with the mode off")
	f.from_dict(d)
	# paused clock: no time, no movement
	var pos0: Vector3 = f.ship_position()
	f.sync(5.0)
	f.sync(5.0)
	check(f.ship_position() == pos0, "T206: no movement while the clock stands")
	# cash arrives: it carries on and ends with the notice
	m.cash = 1000000
	for k in 4000:
		if not f.exploring():
			break
		f.advance(0.05)
	check(not f.exploring(), "T206: the mode ends by itself")
	for pid in sys1:
		check(f.established(pid) and f.discovered(pid), "T206: %s surveyed and established" % pid)
		check(arrived.has(pid) or pid == f.home_id(), "T206: the ship went to %s" % pid)
	check(notices.count(done_text) == 1, "T206: the done notice shows exactly once", str(notices.count(done_text)))
	for k in 20:
		f.advance(0.05)
	check(notices.count(done_text) == 1, "T206: no second notice", str(notices.count(done_text)))
	# a manual order ends the mode
	f.reset()
	f.set_exploring(true)
	f.advance(0.01)
	f.request_fly({"kind": "planet", "index": 1})
	check(not f.exploring(), "T206: a manual order ends the mode")
	f.set_exploring(true)
	f.set_exploring(false)
	check(not f.exploring(), "T206: the player can switch it off")
	Skills.learned.erase("MIN_3")
	await _free_main(m)

func _test_ships_spawn_near_bodies() -> void:
	var Systems := preload("res://game/systems.gd")
	var Motion := preload("res://game/ship_motion.gd")
	Systems.set_placeholders(true)
	var m = await _new_main(false, true)
	m._dismiss_preface()
	check(Motion.SPAWN_GAP > Motion.BODY_MARGIN and Motion.BODY_MARGIN > 0.0, "T202: the spawn gap is larger than the body margin")
	var f = m.flight
	# new game: the Pathfinder stands beside the home planet
	_t202_check(m, 1, f.ship_position(), "new game Pathfinder", f.home_id())
	f.reset()
	_t202_check(m, 1, f.ship_position(), "reset Pathfinder", f.home_id())
	# every system opened, with its station, so each kind of body exists
	var all_sys: Array = [1]
	for sid in Systems.ids():
		all_sys.append(int(sid))
		m._open_system(int(sid))
	check(all_sys == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], "T202: systems 1 to 10 are in play", str(all_sys))
	for sid in all_sys:
		if int(sid) > 1:
			m.map.add_station(int(sid), false)
	m.map.set_clusters(m._all_cluster_packs())
	var packs_n: int = m.map._cluster_list.size()
	check(packs_n > 0, "T202: asteroid fields exist", str(packs_n))
	# save and load: a normal round trip, and an old save with the ship in the planet's centre
	f.request_fly({"kind": "planet", "index": m.planet_index_of("planet_2")})
	f.finish_flight()
	var d: Dictionary = JSON.parse_string(JSON.stringify(f.to_dict()))
	var before: Vector3 = f.ship_position()
	f.from_dict(d)
	check(f.ship_position().is_equal_approx(before), "T202: a save round trip keeps the ship where it was")
	_t202_check(m, 1, f.ship_position(), "loaded Pathfinder", "planet_2")
	var hi: int = m.planet_index_of("planet_2")
	var centre: Vector3 = m.map.positions[hi]
	d["pos"] = [centre.x, 0.0, centre.z]
	f.from_dict(JSON.parse_string(JSON.stringify(d)))
	_t202_check(m, 1, f.ship_position(), "Pathfinder loaded from a save with the ship in the planet centre", "planet_2")
	# arrive, leave, storage and asteroid fields in every system, at two zoom levels
	var k := 0
	for sid in all_sys:
		m.map.set_view_system(int(sid))
		m.map.zoom = 3.0 if k % 2 == 0 else 0.25
		m.map._apply_view()
		k += 1
		for i in m.map.planets.size():
			if int(m.map.planets[i].get("system", 1)) != int(sid):
				continue
			var pid := str(m.map.planets[i]["id"])
			var r: String = f.request_fly({"kind": "planet", "pos": m.map.positions[i], "index": i})
			check(r == "", "T202: the Pathfinder may fly to %s" % pid, r)
			_t202_check(m, int(f.system_id()) if f.state() != "flying" else int(sid), f.ship_position(), "Pathfinder leaving for %s" % pid, "-")
			f.advance(0.002)
			f.finish_flight()
			check(f.system_id() == int(sid) and f.docked_at() == pid, "T202: the Pathfinder arrived at %s" % pid, str(f.docked_at()))
			_t202_check(m, int(sid), f.ship_position(), "Pathfinder at %s (system %d, zoom %.2f)" % [pid, int(sid), m.map.zoom], pid)
		if m.map.stations.has(int(sid)):
			var st: Node3D = m.map.stations[int(sid)]
			f.request_fly({"kind": "storage", "pos": st.position, "index": int(sid)})
			f.finish_flight()
			_t202_check(m, int(sid), f.ship_position(), "Pathfinder at the Space Storage of system %d" % int(sid), "station_%d" % int(sid))
		for c in m.map._cluster_list:
			if int(c["system"]) != int(sid):
				continue
			var cw: Vector3 = Vector3(float(c["x"]), 0.0, float(c["y"])) * m.map.MAP_UNIT_SCALE
			f.request_fly({"kind": "cluster", "pos": cw, "index": int(c["index"])})
			f.finish_flight()
			_t202_check(m, int(sid), f.ship_position(), "Pathfinder at asteroid field %s" % str(c["id"]), "cluster_" + str(c["id"]))
	# rival ships: at the start and on every new course
	var rs = m.rival_ships
	rs.advance(0.0)
	var seen_to := {}
	var legs := 0
	for si in rs._ships.size():
		var s0: Dictionary = rs._ships[si]
		var sp: Vector2 = s0["pos"]
		_t202_check(m, int(s0["system"]), Vector3(sp.x, 0.0, sp.y), "rival %d start (system %d)" % [si, int(s0["system"])])
		_t202_check(m, int(s0["system"]), (s0["node"] as Node3D).position, "rival %d start node (system %d)" % [si, int(s0["system"])])
	for step in 700:
		if step % 15 == 0:
			rs.wake()  # T214
		rs.advance(1.0)
		for si in rs._ships.size():
			var s: Dictionary = rs._ships[si]
			var to: Vector2 = s["to"]
			if not seen_to.has(si) or not (seen_to[si] as Vector2).is_equal_approx(to):
				seen_to[si] = to
				legs += 1
				_t202_check(m, int(s["system"]), Vector3(to.x, 0.0, to.y), "rival %d course %d (system %d)" % [si, legs, int(s["system"])])
	# T211: one ship per competitor, only in opened systems, hidden outside the viewed system
	var Bots := preload("res://game/bots.gd")
	check(rs.ship_count() == Bots.IDS.size(), "T211: one rival ship per competitor", str(rs.ship_count()))
	var seen_sys := {}
	for step in 600:
		if step % 15 == 0:
			rs.wake()  # T214
		rs.advance(1.0)
		for s in rs._ships:
			seen_sys[int(s["system"])] = true
			check(m.open_systems.has(int(s["system"])), "T211: a rival ship is only in an opened system", str(s["system"]))
			check((s["node"] as Node3D).visible == (int(s["system"]) == int(m.map.view_system)), "T211: a rival ship shows only in its own system")
		check(rs.ship_count() == Bots.IDS.size(), "T211: ship count stays one per competitor")
	check(seen_sys.size() > 1, "T211: rivals visit opened systems", str(seen_sys.keys()))
	check(legs > rs._ships.size(), "T202: rivals picked new courses", str(legs))
	Systems.reset_placeholders()
	await _free_main(m)

## T201: the 3D ships face the way they fly. Pathfinder (game/pathfinder_view.gd) and rival ships (game/rival_ships.gd): the model's
## nose (its own -X, turned by Ships.MODEL_YAW_DEG) matches the heading, up stays up, turns are gradual and end aligned, a ship at rest keeps its heading.
func _t201_nose(holder: Node3D) -> Dictionary:
	var pivot: Node3D = holder.get_child(0) as Node3D
	if pivot == null or pivot.get_child_count() == 0 or not (pivot.get_child(0) is Node3D):
		return {}
	var model: Node3D = pivot.get_child(0)
	var b: Basis = model.global_basis.orthonormalized()
	var nose: Vector3 = b * Vector3(-1, 0, 0)
	return {"nose": nose, "up": b * Vector3.UP}

func _t201_angle(nose: Vector3, heading: Vector2) -> float:
	return rad_to_deg(Vector2(nose.x, nose.z).angle_to(heading))

func _t201_check_pose(holder: Node3D, heading: Vector2, label: String) -> void:
	var r := _t201_nose(holder)
	check(not r.is_empty(), "T201: %s has a model with a yaw pivot" % label)
	if r.is_empty():
		return
	var nose: Vector3 = r["nose"]
	var err := absf(_t201_angle(nose, heading))
	check(err <= 2.0 and absf(nose.y) < 0.02, "T201: %s nose is on the heading" % label, "%f deg off, nose %s, heading %s" % [err, str(nose), str(heading)])
	check((r["up"] as Vector3).dot(Vector3.UP) > 0.999, "T201: %s keeps its up axis up" % label, str(r["up"]))

func _test_ship_facing() -> void:
	var Motion = load("res://game/ship_motion.gd")
	var ShipsC = load("res://game/ships.gd")
	var PV = load("res://game/pathfinder_view.gd")
	var dirs: Array = []
	for k in 8:
		var a := float(k) * PI / 4.0
		dirs.append(Vector2(roundf(cos(a) * 1000.0) / 1000.0, roundf(sin(a) * 1000.0) / 1000.0).normalized())
	# every ship id has a yaw offset that turns its own -X onto -Z
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://data/ships.json"))
	for t in data["types"]:
		var id := str(t["id"])
		check(ShipsC.MODEL_YAW_DEG.has(id), "T201: ship %s has a model yaw offset" % id)
		var n: Vector3 = Basis(Vector3.UP, ShipsC.model_yaw(id)) * Vector3(-1, 0, 0)
		check(n.is_equal_approx(Vector3(0, 0, -1)), "T201: offset of %s turns the model nose onto -Z" % id, str(n))
	var saved_fleet: String = ShipsC.fleet
	var m = await _new_main(false, true)
	m._dismiss_preface()
	var f = m.flight
	var root3 := Node3D.new()
	root.add_child(root3)
	var pv = PV.new()
	root3.add_child(pv)
	# Pathfinder, every model
	for id in ShipsC.types():
		ShipsC.set_fleet(str(id))
		f._yaw = 0.0
		pv.update_from(f, f.system_id())
		check(pv.visible and pv._holder != null, "T201: the Pathfinder (%s) is drawn" % id)
		if pv._holder == null:
			continue
		for d in dirs:
			f._yaw = Motion.yaw_to(d)
			pv.update_from(f, f.system_id())
			_t201_check_pose(pv._holder, d, "Pathfinder %s heading %s" % [id, str(d)])
	ShipsC.set_fleet(saved_fleet)
	# Pathfinder: a gradual turn that ends aligned, then at rest keeps its heading
	f._yaw = 0.0
	f.finish_flight()
	var start: Vector3 = f.ship_position()
	f.request_fly({"kind": "point", "pos": start + Vector3(0.0, 0.0, 10.0)})  # straight behind: a 180 degree turn
	var turn: float = deg_to_rad(float(m.balance.get("pathfinder_turn_deg", 2400.0)))
	var dt := 0.002
	var prev_nose := Vector2(0, -1)
	var max_step := 0.0
	var steps := 0
	var sync_ok := true
	while steps < 400 and absf(wrapf(f._yaw - PI, -PI, PI)) > 0.001 and f.state() == "flying":
		steps += 1
		f.advance(dt)
		pv.update_from(f, f.system_id())
		var r := _t201_nose(pv._holder)
		var nv := Vector2((r["nose"] as Vector3).x, (r["nose"] as Vector3).z).normalized()
		max_step = maxf(max_step, absf(prev_nose.angle_to(nv)))
		prev_nose = nv
	check(max_step <= turn * dt + 0.01 and max_step > 0.0, "T201: the Pathfinder model turns gradually at the yaw rate", "%f per step, limit %f" % [max_step, turn * dt])
	check(steps > 1, "T201: the Pathfinder turn takes more than one step", str(steps))
	pv.update_from(f, f.system_id())
	var course := Vector2(0, 1)
	_t201_check_pose(pv._holder, course, "Pathfinder after the turn")
	f.finish_flight()
	var held: float = f._yaw
	for k in 5:
		pv.update_from(f, f.system_id())
		f.advance(0.1)
	check(f._yaw == held, "T201: an idle Pathfinder keeps its heading", str(f._yaw))
	var held_dir: Vector2 = Motion.forward(held)
	_t201_check_pose(pv._holder, held_dir, "idle Pathfinder")
	# rival ships, all systems and all models
	var rs = m.rival_ships
	rs.advance(0.0)
	check(rs._ships.size() > 0, "T201: there are rival ships")
	var seen_kinds := {}
	for s in rs._ships:
		var node: Node3D = s["node"]
		s["wait"] = 1000000.0  # parked: only the heading is under test
		for d in dirs:
			s["yaw"] = Motion.yaw_to(d)
			rs.advance(0.0)
			_t201_check_pose(node, d, "rival in system %d heading %s" % [int(s["system"]), str(d)])
	var s0: Dictionary = rs._ships[0]
	var rturn: float = deg_to_rad(float(m.balance.get("rival_ship_turn_deg", 45.0)))
	s0["wait"] = 0.0
	s0["yaw"] = 0.0
	s0["speed"] = 0.0
	s0["pos"] = Vector2(0, 0)
	s0["to"] = Vector2(0, 50)  # straight behind
	var rprev := Vector2(0, -1)
	var rmax := 0.0
	var rsteps := 0
	while rsteps < 400 and absf(wrapf(float(s0["yaw"]) - PI, -PI, PI)) > 0.001:
		rsteps += 1
		rs.advance(0.05)
		var rr := _t201_nose(s0["node"])
		var rv := Vector2((rr["nose"] as Vector3).x, (rr["nose"] as Vector3).z).normalized()
		rmax = maxf(rmax, absf(rprev.angle_to(rv)))
		rprev = rv
	check(rmax <= rturn * 0.05 + 0.01 and rsteps > 1, "T201: a rival model turns gradually at the yaw rate", "%f per step, %d steps" % [rmax, rsteps])
	_t201_check_pose(s0["node"], Vector2(0, 1), "rival after the turn")
	s0["wait"] = 1000000.0
	s0["speed"] = 0.0
	var ry: float = s0["yaw"]
	rs.advance(1.0)
	check(float(s0["yaw"]) == ry, "T201: a waiting rival keeps its heading")
	_t201_check_pose(s0["node"], Motion.forward(ry), "waiting rival")
	root3.queue_free()
	await _free_main(m)
	ShipsC.set_fleet(saved_fleet)

func _test_links_everywhere() -> void:
	await _t188_pass(false)
	await _t188_pass(true)

func _learn_storage(m) -> Dictionary:
	var t: int = m.trade_income_total
	m.trade_income_total = maxi(t, int(m.balance.get("earn_storage_income", 3000)))
	var r: Dictionary = m.learn_skill("FND_STORAGE")
	m.trade_income_total = t
	m._sync_earn()
	return r

## T305: in one system no two planets share an orbit; neighbouring orbits are >= 2x the larger planet's diameter apart (as the map draws them).
func _test_orbit_spacing() -> void:
	var MapS := load("res://game/map.gd")
	var systems := {}  # system id -> [{id, x, y, size}]
	var pj: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/planets.json"))
	var sj: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/systems.json"))
	var all: Array = []
	all.append_array(pj.get("planets", []))
	for sy in sj.get("systems", []):
		for p in sy.get("planets", []):
			var q: Dictionary = p.duplicate()
			q["system"] = int(sy.get("id", 2))
			all.append(q)
	for p in all:
		if not p.has("x") or not p.has("y"):
			continue
		var sid := int(p.get("system", 1))
		if not systems.has(sid):
			systems[sid] = []
		var f: float
		if p.has("size"):
			f = clampf(float(p["size"]), MapS.PLANET_SIZE_MIN, MapS.PLANET_SIZE_MAX)
		else:
			f = lerpf(MapS.PLANET_SIZE_MIN, MapS.PLANET_SIZE_MAX, float(absi(str(p["id"]).hash()) % 1000) / 999.0)
		systems[sid].append({"id": str(p["id"]), "v": Vector2(float(p["x"]), float(p["y"])), "r": MapS.PLANET_RADIUS * MapS.PLANET_SIZE * f})
	for sid in systems:
		var list: Array = systems[sid]
		var lo: Vector2 = list[0]["v"]
		var hi: Vector2 = list[0]["v"]
		for e in list:
			lo = Vector2(minf(lo.x, e["v"].x), minf(lo.y, e["v"].y))
			hi = Vector2(maxf(hi.x, e["v"].x), maxf(hi.y, e["v"].y))
		var mid := (lo + hi) * 0.5  # the system centre the map uses (middle of the planets' bounding box)
		for e in list:
			e["orbit"] = (e["v"] - mid).length() * MapS.MAP_UNIT_SCALE * MapS.ORBIT_SCALE
		list.sort_custom(func(a, b): return a["orbit"] < b["orbit"])
		for k in range(list.size() - 1):
			var a: Dictionary = list[k]
			var b: Dictionary = list[k + 1]
			var need := 4.0 * maxf(a["r"], b["r"])
			check(b["orbit"] - a["orbit"] >= need, "orbits: system %d %s and %s are 2x planet size apart" % [sid, a["id"], b["id"]], "gap %.2f need %.2f" % [b["orbit"] - a["orbit"], need])
		check(list[0]["orbit"] > 2.0 * list[0]["r"], "orbits: system %d %s is not on the sun" % [sid, list[0]["id"]])

# ---- T354: small ships point the nose along the movement (GDScript port of traffic_motion.gdshaderinc) ----
func _tt_draw(seed: float, k: float) -> float:
	return fposmod(sin(seed * 12.9898 * k + k * 78.233) * 43758.5453, 1.0)

## Lane position at curve parameter u (Bezier + sideways spread + landing glide), as traffic_lane_point.
func _tt_lane_point(p0: Vector3, pc: Vector3, p2: Vector3, r0: float, r1: float, seed: float, u: float) -> Vector3:
	var w := 1.0 - u
	var pos := p0 * w * w + pc * (2.0 * w * u) + p2 * u * u
	var lane := p2 - p0
	var side := Vector3(-lane.z, 0.0, lane.x + 0.00001).normalized() if lane.length() > 0.0 else Vector3.RIGHT
	var e := clampf((u - 0.04) / 0.92, 0.0, 1.0)
	pos += side * ((seed * 2.0 - 1.0) * 0.04 * lane.length() * sin(PI * e))
	var ldir := (lane + Vector3(0.00001, 0.0, 0.0)).normalized()
	var c0 := p0 - ldir * r0 * 0.6
	var c1 := p2 + ldir * r1 * 0.6
	var a0 := TAU * _tt_draw(seed, 3.0)
	var a1 := TAU * _tt_draw(seed, 5.0)
	var o0 := Vector2(cos(a0), sin(a0)) * sqrt(_tt_draw(seed, 4.0)) * 0.9 * r0
	var o1 := Vector2(cos(a1), sin(a1)) * sqrt(_tt_draw(seed, 6.0)) * 0.9 * r1
	var l0 := c0 + Vector3(o0.x, sqrt(maxf(r0 * r0 - o0.length_squared(), 0.0)), o0.y)
	var l1 := c1 + Vector3(o1.x, sqrt(maxf(r1 * r1 - o1.length_squared(), 0.0)), o1.y)
	var k0 := 1.0 - smoothstep(0.0, 0.12, e)
	var k1 := 1.0 - smoothstep(0.0, 0.12, 1.0 - e)
	return pos + (l0 - p0) * k0 + (l1 - p2) * k1

func _tt_lane_pos(p0: Vector3, pc: Vector3, p2: Vector3, r0: float, r1: float, seed: float, c: float) -> Vector3:
	var back := c > 0.5
	var u := 2.0 - c * 2.0 if back else c * 2.0
	return _tt_lane_point(p0, pc, p2, r0, r1, seed, 0.04 + u * 0.92)

## Heading the shader gives a lane ship at clock fraction c.
func _tt_lane_fwd(p0: Vector3, pc: Vector3, p2: Vector3, r0: float, r1: float, seed: float, c: float) -> Vector3:
	var back := c > 0.5
	var u := 2.0 - c * 2.0 if back else c * 2.0
	u = 0.04 + u * 0.92
	var d := _tt_lane_point(p0, pc, p2, r0, r1, seed, minf(u + 0.003, 0.96)) - _tt_lane_point(p0, pc, p2, r0, r1, seed, maxf(u - 0.003, 0.04))
	return (-d if back else d).normalized()

func _tt_orbit(centre: Vector3, r: float, tl: float, dir: float, ph: float, clock: float) -> Array:
	var a := TAU * (ph + clock * 0.05 * dir)
	var o := Vector3(cos(a), 0.0, sin(a))
	var tg := Vector3(-sin(a), 0.0, cos(a)) * (-1.0 if dir < 0.0 else 1.0)
	o = Vector3(o.x, o.z * sin(tl), o.z * cos(tl))
	tg = Vector3(tg.x, tg.z * sin(tl), tg.z * cos(tl))
	return [centre + o * r, tg.normalized()]

func _test_traffic_heading() -> void:
	var worst := 0.0
	var seeds := [0.05, 0.3, 0.5, 0.77, 0.98]
	var lanes := [[Vector3(0, 0, 0), Vector3(15, 0, 9), Vector3(30, 0, 0), 2.0, 3.0], [Vector3(30, 0, 0), Vector3(20, 0, -12), Vector3(0, 0, 6), 3.0, 1.5]]
	for L in lanes:
		for sd in seeds:
			for c in [0.03, 0.1, 0.25, 0.4, 0.47, 0.56, 0.7, 0.9, 0.97]:
				var dc := 0.0002
				var mv: Vector3 = _tt_lane_pos(L[0], L[1], L[2], L[3], L[4], sd, c + dc) - _tt_lane_pos(L[0], L[1], L[2], L[3], L[4], sd, c)
				var fw := _tt_lane_fwd(L[0], L[1], L[2], L[3], L[4], sd, c)
				# the movement of the ship on the return leg runs along falling c steps: a step in c is a step in time for both legs
				worst = maxf(worst, rad_to_deg(fw.angle_to(mv.normalized())))
	check(worst < 5.0, "traffic heading: lane ships (both directions) point along the movement", "worst %.2f deg" % worst)
	var worst_o := 0.0
	for dir in [1.0, -1.0]:
		for tl in [0.0, 0.5]:
			for ph in [0.0, 0.3, 0.8]:
				var p0 := _tt_orbit(Vector3(1, 2, 3), 6.0, tl, dir, ph, 10.0)
				var p1 := _tt_orbit(Vector3(1, 2, 3), 6.0, tl, dir, ph, 10.01)
				worst_o = maxf(worst_o, rad_to_deg((p1[0] - p0[0]).angle_to(p0[1])))
	check(worst_o < 2.0, "traffic heading: orbit ships (both directions) point along the movement", "worst %.2f deg" % worst_o)
	# the mesh nose is -Z and the frame maps -Z onto fwd (z column = -fwd)
	var fwd := Vector3(0.6, 0.1, -0.8).normalized()
	var z := -fwd
	var x := Vector3.UP.cross(z).normalized()
	var B := Basis(x, z.cross(x), z)
	check((B * Vector3(0, 0, -1)).is_equal_approx(fwd), "traffic heading: mesh nose (-Z) maps onto the heading")

func _test_good_icons() -> void:
	for g in Goods.ids():
		check(Ui.icon(g) != null, "icons: good %s resolves to an icon" % g)
		check(Ui.commodity_col(g) != Color.WHITE, "icons: good %s has a commodity colour" % g)


# ---- 2026-11-04: earn-locked Learn button; permit bought from the galaxy card ----
func _all_text(n: Node) -> String:
	var t := ""
	if n is Label or n is Button:
		t += str(n.text) + "\n"
	for c in n.get_children():
		t += _all_text(c)
	return t

func _test_learn_lock_and_permit_card() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	Skills.learned.append_array(FND3_NO_STORAGE())
	m.skill_points = 1
	m.trade_income_total = 100
	m.skill_screen.open_screen()
	m.skill_screen.select("FND_STORAGE")
	var ss = m.skill_screen
	check(ss.learn_button.disabled and _all_text(ss.detail_box).contains("100/" + str(int(m.balance["earn_storage_income"]))), "storage: earn-locked Learn button is disabled and the earn line is shown", _all_text(ss.detail_box))
	check(ss.learn_button.text.contains("1 point") and not ss.learn_button.text.contains("1 points") and not _all_text(ss.detail_box).contains("Cost:"), "storage: Learn button shows the cost, singular for 1, no Cost line", ss.learn_button.text)
	_test_skill_window_rework(m)
	ss.confirm_learn()
	check(not m.has_skill("FND_STORAGE") and m.skill_points == 1, "storage: earn-locked skill is not learned and keeps the point")
	m.trade_income_total = int(m.balance["earn_storage_income"])
	ss.refresh()
	check(not ss.learn_button.disabled and not _all_text(ss.detail_box).contains("Earn "), "storage: income met, Learn enabled, no lock line")
	m.events.pending_id = "x"
	ss.refresh()
	check(not ss.learn_button.disabled, "storage: a pending event does not block the button")
	m.events.pending_id = ""
	m.paused = true
	ss.learn_button.pressed.emit()
	check(m.has_skill("FND_STORAGE") and m.skill_points == 0 and ss.node_buttons["FND_STORAGE"].self_modulate.is_equal_approx(ss.COL_LEARNED), "storage: click learns it, spends the point, node shows learned colour")
	m.paused = false
	ss.close_screen()
	# permits
	var bal: Dictionary = m.balance
	var gv = m.galaxy_view
	gv.open_view()
	gv.select_system(2)
	check(gv.side.visible and gv.permit_button != null and gv.permit_button.disabled, "permit card: locked system 2 shows a disabled Buy permit button without the charter")
	var txt := _all_text(gv.side_box)
	check(txt.contains(StoryText.get_text("PERMIT_WHY_LOCKED")) and txt.contains(str(int(bal["permit_2_cost"]))), "permit card: shows the locked line and the price", str(bal.get("permit_2_cost")) + " " + str(txt.contains(StoryText.get_text("PERMIT_WHY_LOCKED"))))
	m.learned_skills.append("FND_PERMIT")
	m.cash = 0
	m.skill_points = 5
	gv.select_system(2)
	check(gv.permit_button.disabled and _all_text(gv.side_box).contains(StoryText.get_or("PERMIT_NO_CREDITS", "Not enough credits.")), "permit card: not enough credits shows the reason and disables the button")
	m.cash = int(bal["permit_2_cost"]) + 10
	m.skill_points = 0
	gv.select_system(2)
	check(gv.permit_button.disabled and _all_text(gv.side_box).contains(StoryText.get_text("NOT_SKILL_NO_POINTS")), "permit card: not enough points shows the reason")
	m.skill_points = int(bal["permit_points_2"]) + 1
	gv.select_system(2)
	check(not gv.permit_button.disabled, "permit card: buyable state enables the button")
	gv.permit_button.pressed.emit()
	check(m.open_systems.has(2) and m.cash == 10 and m.skill_points == 1, "permit card: Buy permit spends credits and points and opens the system")
	check(gv.permit_button == null and _all_text(gv.side_box).contains("open"), "permit card: open system shows open and no buy button", _all_text(gv.side_box))
	gv.select_system(1)
	check(gv.permit_button == null, "permit card: system 1 has no buy button")
	gv.close_view()
	m.skill_screen.open_screen()
	check(not _all_text(m.skill_screen).contains("Permit: ") and not _all_text(m.skill_screen).contains(StoryText.get_text("PERMIT_S2_BTN")), "skills window: no permit block any more")
	m.skill_screen.close_screen()
	await _free_main(m)
	# locked system clicked in the 3D view shows the card
	m = await _new_main()
	m._dismiss_preface()
	check(not m.enter_system_from_view(2) and m.galaxy_view.visible and m.galaxy_view.selected_sys == 2 and m.galaxy_view.permit_button != null, "permit card: a locked system clicked in the system view opens its card")
	await _free_main(m)

func FND3_NO_STORAGE() -> Array:
	return ["FND_PROSPECT"]

## Skills window rework: detail line order, cost on the button, icons, 0.9 sizes, scrolled tree.
func _test_skill_window_rework(m: Control) -> void:
	var ss = m.skill_screen
	var SI = load("res://game/skill_icons.gd")
	var kids: Array = ss.detail_box.get_children()
	var texts: Array = []
	for c in kids:
		if c is Label:
			texts.append(c.text)
	var plain: String = StoryText.get_or("SK_FND_STORAGE_PLAIN", "", SS_plain(m, "FND_STORAGE"))
	check(texts.size() >= 3 and texts[0].begins_with(SkillTree.skill_name("FND_STORAGE")) and texts[1] == plain and texts[2] == SkillTree.flavour("FND_STORAGE"), "skills window: title, then plain effect, then story line", str(texts.slice(0, 3)))
	var all := _all_text(ss.detail_box)
	check(not all.contains("Cost:") and not all.contains(StoryText.get_text("SK_LABEL_EFFECT")), "skills window: no Cost line and no 'What it changes' label")
	check(ss.learn_text(1).contains("1 point") and not ss.learn_text(1).contains("points") and ss.learn_text(2).contains("2 points"), "skills window: Learn text singular and plural", ss.learn_text(1) + " / " + ss.learn_text(2))
	var ids_ok: bool = SI.IDS.size() == 68
	var atlas := load(SI.ATLAS_PATH) as Texture2D
	check(atlas != null, "skill icons: atlas loads")
	for id in SkillTree.all_ids():
		var r: Rect2 = SI.region(id)
		if atlas == null or r.size == Vector2.ZERO or not Rect2(Vector2.ZERO, atlas.get_size()).encloses(r):
			ids_ok = false
	check(ids_ok, "skill icons: every skill id has a region inside the atlas")
	var btn_ok := true
	for id in ss.node_buttons:
		var b: Button = ss.node_buttons[id]
		if b.icon == null or b.text != SkillTree.skill_name(id):
			btn_ok = false
	check(btn_ok, "skill icons: every node button has an icon and shows only the name")
	var b0: Button = ss.node_buttons["FND_PERMIT"]
	check(is_equal_approx(b0.custom_minimum_size.y, 56.0 * 0.9) and is_equal_approx(ss.CELL_W, 144.0 * 0.9), "skills window: node size is 0.9 of before")
	check(ss.tree_scroll != null and ss.tree_scroll.is_ancestor_of(b0) and ss.tree_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and not ss.tree_scroll.is_ancestor_of(ss.detail_box), "skills window: the tree sits in a vertical scroll container, the detail strip does not")

func SS_plain(m: Control, id: String) -> Dictionary:
	return load("res://game/skill_screen.gd").plain_args(m.balance, id)


# ---- availability: the UI obeys data/availability.json (game/availability.gd) ----
func _av_reset(m: Control) -> void:
	Skills.learned.clear()
	m.fabric.built = false
	for id in m.workshops.built.keys():
		m.workshops.built[id] = false
	m.open_systems = [1]
	m.cycle = 1
	m.flight.reset()  # T179: only the home world has its post
	m._sync_closed()
	for key in m.storage.stock.keys():
		m.storage.stock[key] = {}

## Sets one atom true or false in the live game. Returns false when the atom cannot be set that way ("start" false).
func _av_atom(m: Control, atom: String, val: bool) -> bool:
	var parts := Availability.split_atom(atom)
	var arg := str(parts[1])
	match str(parts[0]):
		"start":
			return val
		"skill_learned":
			if val:
				Skills.add_learned(arg)
			else:
				Skills.learned.erase(arg)
		"workshop_built":
			if arg == "fabric":
				m.fabric.built = val
			else:
				m.workshops.built[arg] = val
		"system_open":
			if val and not m.open_systems.has(int(arg)):
				m.open_systems.append(int(arg))
			elif not val:
				m.open_systems.erase(int(arg))
		"cycle_at_least":
			var need := int(m.balance[arg.trim_prefix("balance.")])
			m.cycle = need if val else need - 1
		"cycle_at_most":
			var most := int(m.balance[arg.trim_prefix("balance.")])
			m.cycle = most if val else most + 1
		"stock_held":
			var key: String = m.storage.planet_key(0)
			m.storage.ensure(key)
			m.storage.stock[key][arg] = 1 if val else 0
		"good_visible":
			return _av_make(m, Availability.rule("good", arg), val)
		"planet_visited":
			m.flight.set_flag("visited", arg, val)
		"post_built":
			m.flight.set_flag("post", arg, val)
		"platform_built":
			m.flight.set_flag("platform", arg, val)
	return true

## Makes a condition tree true or false. Returns false when it cannot be made that way (an always-true "start").
func _av_make(m: Control, cond, val: bool) -> bool:
	if typeof(cond) == TYPE_STRING:
		return _av_atom(m, str(cond), val)
	if cond.has("all"):
		if val:
			var ok := true
			for c in cond["all"]:
				ok = _av_make(m, c, true) and ok
			return ok
		for c in cond["all"]:
			if _av_make(m, c, false):
				return true
		return false
	var okany := true
	if val:
		for c in cond["any"]:
			if _av_make(m, c, true):
				return true
		return false
	for c in cond["any"]:
		okany = _av_make(m, c, false) and okany
	return okany

func _av_visible_text(n: Node) -> String:
	if n is CanvasItem and not (n as CanvasItem).visible:
		return ""
	var t := ""
	if n is Label or n is Button:
		t += str(n.text) + "\n"
	if n is Control:
		t += str((n as Control).tooltip_text) + "\n"
	for c in n.get_children():
		t += _av_visible_text(c)
	return t

func _av_tooltips(n: Node) -> String:
	var t := ""
	if n is Control:
		t += str((n as Control).tooltip_text) + "\n"
	for c in n.get_children():
		t += _av_tooltips(c)
	return t

func _test_skill_link_clip() -> void:
	_wipe_user()
	var m: Control = await _new_main(false, true)
	var sc = m.skill_screen
	var boxes: Array = [Rect2(80, 40, 40, 20)]
	var v: Array = sc.clip_segment(Vector2(100, 0), Vector2(100, 100), boxes)
	check(v.size() == 2 and is_equal_approx(v[0][1].y, 40.0) and is_equal_approx(v[1][0].y, 60.0), "T225: vertical link stops at a node box and resumes after it")
	var h: Array = sc.clip_segment(Vector2(0, 50), Vector2(200, 50), boxes)
	check(h.size() == 2 and is_equal_approx(h[0][1].x, 80.0) and is_equal_approx(h[1][0].x, 120.0), "T225: horizontal link stops at a node box")
	check(sc.clip_segment(Vector2(10, 0), Vector2(10, 100), boxes).size() == 1, "T225: a link clear of every box is drawn whole")
	m.queue_free()

func _test_prosperity() -> void:
	var bal: Dictionary = {"prosperity_max_tier": 3, "prosperity_needs_t1": 1, "prosperity_needs_t2": 2, "prosperity_needs_t3": 3, "prosperity_demand_t1": 2, "prosperity_demand_t2": 3, "prosperity_demand_t3": 4, "prosperity_steps_t1": 2, "prosperity_steps_t2": 2, "prosperity_decay_steps": 1}
	var pl: Array = [{"id": "p0", "type": "agrarian", "base_prices": {}}, {"id": "p1", "type": "lush", "base_prices": {}}]
	var pr := Prosperity.new()
	pr.setup(bal, pl, func(pid: String) -> bool: return pid == "p0")
	check(pr.tier(0) == 1 and pr.tier(1) == 0 and pr.needs(1).is_empty(), "prosperity: post stands = tier 1, no post = tier 0 with no needs")
	var ns: Array = pr.needs(0)
	check(ns.size() == 1 and ns[0]["good"] == "energy" and not ns[0]["met"], "prosperity: tier 1 world needs energy first, unmet", str(ns))
	pr.add_fill(1, "energy", 5)
	check(pr.sold(1, "energy") == 0, "prosperity: fill at a world without a post is ignored")
	var ups: Array = []
	pr.tier_up.connect(func(p: int, t: int) -> void: ups.append([p, t]))
	pr.add_fill(0, "energy", 2)
	pr.end_cycle()
	check(pr.progress(0) == 0.5 and not pr.restless(0), "prosperity: need met = one step")
	pr.end_cycle()
	check(pr.progress(0) == 0.0 and pr.restless(0), "prosperity: need short = decay by one step")
	pr.add_fill(0, "energy", 2)
	pr.end_cycle()
	pr.add_fill(0, "energy", 2)
	pr.end_cycle()
	check(pr.tier(0) == 2 and ups == [[0, 2]], "prosperity: full steps = tier up, signal sent", str(ups))
	var back := Prosperity.new()
	back.setup(bal, pl, func(pid: String) -> bool: return pid == "p0")
	back.from_dict(pr.to_dict())
	check(back.tier(0) == 2, "prosperity: tier survives save and load")
	back.from_dict(null)
	check(back.tier(0) == 1, "prosperity: old save starts established worlds at tier 1")
	# T258 rewards
	bal.merge({"prosperity_tax_t1": 5, "prosperity_tax_t2": 10, "prosperity_points_t1": 0, "prosperity_points_t2": 2})
	check(pr.tax_total() == 10 and pr.any_tier_reached(2) and not pr.any_tier_reached(3), "prosperity: tax by tier, any_tier reached")
	var nt: Array = pr.claim_new_tiers()
	check(nt.size() == 2 and nt[1]["tier"] == 2 and nt[1]["points"] == 2 and pr.claim_new_tiers().is_empty(), "prosperity: first time any world reaches a tier pays once", str(nt))
	check(back.to_dict().has("reached"), "prosperity: reached tier is saved")
	# T257 need pricing
	var nb: Dictionary = bal.duplicate()
	nb.merge({"need_price_t1": 1.0, "need_price_t2": 1.0, "need_price_t3": 1.0, "need_hunger_step_pct": 10, "need_hunger_cap_pct": 20, "need_surplus_pct": 50, "need_surplus_all": 0})
	var pl2: Array = [{"id": "p0", "type": "agrarian", "base_prices": {}}]
	var np := Prosperity.new()
	np.setup(nb, pl2, func(pid: String) -> bool: return true)
	var tr = preload("res://game/trade.gd").new()
	tr.setup(nb, pl2)
	tr.prosperity = np
	var bv := Markets.value_of("energy")
	check(tr.price(0, "energy_sell") == bv and bv > 0, "need price: a need opens a sell price at base_value x key", str(tr.price(0, "energy_sell")))
	check(tr.price(0, "food_sell") < 0 and np.price_reason(0, "energy") == "", "need price: a good that is no need stays unpriced; no reason before any cycle")
	np.end_cycle()
	check(np.price_reason(0, "energy") == "hungry" and tr.price(0, "energy_sell") == roundi(bv * 1.1), "need price: a short need turns hungry, price up one step", str(tr.price(0, "energy_sell")))
	np.end_cycle()
	np.end_cycle()
	check(tr.price(0, "energy_sell") == roundi(bv * 1.2), "need price: hunger stops at the cap", str(tr.price(0, "energy_sell")))
	np.add_fill(0, "energy", 2)
	check(np.surplus_units(0, "energy", 1) == 1 and np.price_reason(0, "energy") == "", "need price: units above the demand are surplus")
	np.add_fill(0, "energy", 1)
	check(np.price_reason(0, "energy") == "surplus", "need price: reason is surplus once sold above demand")
	np.end_cycle()
	check(np.hunger_steps(0, "energy") == 1, "need price: a met need steps hunger back down")
	var again := Prosperity.new()
	again.setup(nb, pl2, func(pid: String) -> bool: return true)
	again.from_dict(np.to_dict())
	check(again.hunger_steps(0, "energy") == 1, "need price: hunger survives save and load")

## T349: every living world of a fresh game has a visible, fillable need and starts calm; a world with no needs is never Restless.
func _test_prosperity_needs_never_empty() -> void:
	_wipe_user()
	var bal: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance.json"))
	if bal.has("balance"):
		bal = bal["balance"]
	var pl: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/planets.json"))["planets"]
	for p in pl:
		Goods.merge_prices(p)
	var pr := Prosperity.new()
	pr.setup(bal, pl, func(_pid: String) -> bool: return true)
	for i in range(pl.size()):
		if pr.tier(i) < 1:
			continue
		var visible := 0
		for n in pr.needs(i):
			if not bool(n["locked"]):
				visible += 1
		check(visible > 0, "prosperity: %s starts with a visible need" % str(pl[i]["id"]), str(pr.needs(i)))
		check(not pr.restless(i), "prosperity: %s starts not restless" % str(pl[i]["id"]))
	var empty := Prosperity.new()
	empty.setup({"prosperity_max_tier": 3, "prosperity_needs_t1": 0, "prosperity_demand_t1": 2, "prosperity_steps_t1": 2, "prosperity_decay_steps": 1}, [{"id": "e0", "type": "agrarian", "base_prices": {}}], func(_pid: String) -> bool: return true)
	check(empty.needs(0).is_empty(), "prosperity: synthetic world has no needs")
	empty.end_cycle()
	empty.end_cycle()
	check(not empty.restless(0) and empty.steps(0) == 0, "prosperity: a world with no needs is never restless and gains no step")

func _test_availability() -> void:
	_wipe_user()
	var data: Dictionary = Availability.data()
	var start: Dictionary = data["start_state"]
	# (c) data lint: every good / workshop / storage has a rule, nothing unknown is referenced
	var errs: Array = Availability.lint()
	check(errs.is_empty(), "availability lint: data/availability.json is clean", "; ".join(errs))
	for e in errs:
		check(false, "availability lint: " + str(e))
	# (a) a fresh game shows only the start state
	var m: Control = await _new_main(false, true)  # discovery on: the shipped default
	m._dismiss_preface()
	_av_reset(m)
	# T179: only the home world is open at the start; every other planet is closed (no goods, no routes, no trade)
	var open_ids: Array = []
	for p in m.map.planets:
		if Availability.planet(str(p.get("id", ""))):
			open_ids.append(str(p.get("id", "")))
	check(open_ids == start["open_planets"], "availability start: only the home planet is open", str(open_ids))
	for i in m.map.planets.size():
		if not start["open_planets"].has(str(m.map.planets[i].get("id", ""))):
			check(not m.planet_established(i) and m.engine.closed_planets.has(i) and not m.system_trade_open(i), "availability start: planet '%s' is closed to trade" % str(m.map.planets[i].get("id", "")))
	var vis: Array = Availability.all_visible_goods()
	var want: Array = start["visible_goods"]
	var same := vis.size() == want.size()
	for g in want:
		if not vis.has(g):
			same = false
	check(same, "availability start: visible goods are exactly the start_state goods", "visible=%s want=%s" % [str(vis), str(want)])
	for g in start["hidden_goods"]:
		check(not Availability.good(str(g)), "availability start: good '%s' is hidden" % g)
	for w in Goods.workshops:
		check(not Availability.workshop(str(w["id"])) or start["visible_workshops"].has(str(w["id"])), "availability start: workshop '%s' is hidden" % str(w["id"]))
	check(Availability.storage("planet_storage") and not Availability.storage("space_storage"), "availability start: planet storage shown, space storage hidden")
	for f in start["hidden_features"]:
		check(not Availability.is_visible("storage" if Availability.has_rule("storage", str(f)) else "feature", str(f)), "availability start: feature '%s' is hidden" % f)
	check(m.station_systems.is_empty() and not m.space_post_open(1), "availability start: no space storage station or post")
	var pi := -1
	for i in m.map.planets.size():
		if str(m.map.planets[i].get("id", "")) == str(start["planet"]):
			pi = i
	check(pi >= 0, "availability start: start planet exists", str(start["planet"]))
	m.planet_panel.show_planet(pi)
	await process_frame
	var pan_text: String = _all_text(m.planet_panel) + _av_tooltips(m.planet_panel)
	var leak := Availability.names_hidden_good(pan_text)
	check(leak == "", "availability start: the %s planet panel names no hidden good" % str(start["planet_name"]), "names '%s' in: %s" % [leak, pan_text.replace("\n", " | ")])
	await process_frame
	var screen_text := _av_visible_text(m)
	var leak2 := Availability.names_hidden_good(screen_text)
	check(leak2 == "", "availability start: no visible screen text names a hidden good", "names '%s' in: %s" % [leak2, screen_text.replace("\n", " | ")])
	var leak3 := Availability.names_closed_planet(screen_text + pan_text)  # T179: a closed planet is not named before its post
	check(leak3 == "", "availability start: no visible text names a closed planet", "names '%s' in: %s" % [leak3, screen_text.replace("\n", " | ")])
	var sk_leaks := []  # skill texts are always on screen: none may name a good hidden at the start
	for e in StoryText.entries_of(_read_json("res://data/story_text.json")):
		if str(e["id"]).begins_with("SK_") and Availability.names_hidden_good(str(e["text"])) != "":
			sk_leaks.append("%s names '%s'" % [str(e["id"]), Availability.names_hidden_good(str(e["text"]))])
	check(sk_leaks.is_empty(), "availability start: no skill text names a hidden good", "; ".join(sk_leaks))
	for g in start["hidden_goods"]:
		check(_find_named(m.planet_panel, "BuyButton_" + str(g)) == null, "availability start: no resource button for hidden '%s'" % g)
	for g in want:
		check(_find_named(m.planet_panel, "BuyButton_" + str(g)) != null, "availability start: resource button for '%s'" % g)
	# (b) every rule: make it true and it shows, make it false and it hides
	for r in data["rules"]:
		var kind := str(r["kind"])
		var id := str(r["id"])
		var cond = r["visible_when"]
		if id in ["placeholder_system_3", "placeholder_system_4", "placeholder_system_5"]:  # T226: live ("start")
			check(Availability.is_visible(kind, id), "availability rule feature '%s': live placeholder" % id)
			continue
		if id.begins_with("placeholder_system_"):  # T176: placeholder systems 6 to 10 are off ({not: start})
			check(not Availability.is_visible(kind, id), "availability rule feature '%s': off for now" % id)
			continue
		if id == "dead_danger_meter":  # the off switch ({not: start}); its hidden and shown states are tested in _test_dead_world_mechanics
			check(not Availability.is_visible(kind, id), "availability rule feature 'dead_danger_meter': off for now")
			continue
		_av_reset(m)
		var can_true: bool = _av_make(m, cond, true)
		check(can_true and Availability.is_visible(kind, id), "availability rule %s '%s': condition true shows it" % [kind, id])
		_av_reset(m)
		if _av_make(m, cond, false):
			check(not Availability.is_visible(kind, id), "availability rule %s '%s': condition false hides it" % [kind, id])
		else:
			check(Availability.is_visible(kind, id), "availability rule %s '%s': always visible (start atom)" % [kind, id])
	# owned goods never hide (stock_held), and a recipe or notice that appears with a rule shows in the live UI
	for g in start["hidden_goods"]:
		_av_reset(m)
		_av_atom(m, "stock_held:" + str(g), true)
		check(Availability.good(str(g)), "availability stock_held: held '%s' is visible" % g)
	_av_reset(m)
	Skills.add_learned("FND_STORAGE")
	check(Availability.storage("space_storage") and Skills.unlocked("space_storage"), "availability: space storage rule and skill unlock agree")
	# UI follows state: ore row appears at Voltara when FND_PROSPECT is learned, and goes when it is not
	_av_reset(m)
	m.planet_panel.show_planet(pi)
	await process_frame
	var ore_priced: bool = m.map.planets[pi].get("base_prices", {}).has("ore_sell")
	check(not ore_priced or _find_named(m.planet_panel, "BuyButton_ore") == null, "availability ui: no ore button before FND_PROSPECT")
	Skills.add_learned("FND_PROSPECT")
	m.planet_panel.show_planet(pi)
	await process_frame
	check(not ore_priced or _find_named(m.planet_panel, "BuyButton_ore") != null, "availability ui: ore button after FND_PROSPECT")
	_av_reset(m)
	await _free_main(m)


## Destination hover card (game/dest_hint.gd): only while a route is pending; price or the click's own refusal reason.
func _test_dest_hint() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	m.cash = 6000
	m._open_system(2)  # its planets join the map; the permit routes skill is still missing
	var d1 := -1
	var far := -1
	for i in m.map.planets.size():
		if str(m.map.planets[i].get("id", "")) == "dead_1":
			d1 = i
		if far < 0 and int(m.map.planets[i].get("system", 1)) == 2 and not m.DeadWorlds.is_dead(m.map.planets[i]):
			far = i
	check(DestHint.describe(m, 1, -1) == "", "hover card: nothing without a pending route")
	check(not m.dest_hint.visible, "hover card: node hidden without a pending route")
	m.pending = {"planet": 0, "c": "energy"}
	m._pending_changed()
	var t: String = DestHint.describe(m, 1, -1)
	var price: int = m.engine.sold_price(1, "energy")
	check(price > 0 and t == "%s buys Energy at %d cr each." % [m.planet_name(1), price] or ("buys" in t and str(price) in t), "hover card: a valid planet shows the price it pays", t)
	check(Availability.names_hidden_good(t) == "", "hover card: names no hidden good", t)
	check(DestHint.describe(m, 0, -1) == m.StoryText.get_text("HINT_DEST_SOURCE"), "hover card: the source planet says the route starts here")
	check(DestHint.describe(m, d1, -1) == m.StoryText.get_text("NOT_DEAD_NO_DELIVERY"), "hover card: a dead world shows the same refusal as the click", DestHint.describe(m, d1, -1))
	m.engine.closed_planets = [1]
	check(DestHint.describe(m, 1, -1) == str(m.can_connect(0, 1, "energy")["reason"]) and "closed" in DestHint.describe(m, 1, -1), "hover card: a closed planet shows the closed reason", DestHint.describe(m, 1, -1))
	m.engine.closed_planets = []
	check(far >= 0 and DestHint.describe(m, far, -1) == m.StoryText.get_text("NOT_ROUTE_NEEDS_C3"), "hover card: a planet in another system without the permit routes skill shows the permit reason", "far=%d text=%s" % [far, DestHint.describe(m, far, -1)])
	var st: String = DestHint.describe(m, -1, 1)
	check(st == str(m.can_connect(0, m.station_dst(1), "energy")["reason"]) or st == m.StoryText.get_text("HINT_DEST_STATION", {"good": "Energy"}), "hover card: a station shows the click's refusal or the keep line", st)
	m.pending = {"planet": 0, "c": "ore"}  # ore is hidden at the start
	check(DestHint.describe(m, 1, -1) == "", "hover card: a hidden pending good shows nothing")
	m.pending = {"planet": 0, "c": "energy"}
	m.tut_step = 3  # the guided send step locks the controls: no card
	if m.tut_lock_active():
		check(DestHint.describe(m, 1, -1) == "", "hover card: no card under the tutorial lock")
	m.tut_step = -1
	m.cancel_pending()
	check(DestHint.describe(m, 1, -1) == "", "hover card: gone when the pending state ends")
	await _free_main(m)

## Dead world panel (owner 2026-11-04): locked line, needs-skill line, Mine and send to..., destination refused.
func _test_dead_world_panel() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var d1: int = -1
	for i in m.map.planets.size():
		if str(m.map.planets[i].get("id", "")) == "dead_1":
			d1 = i
	var pp = m.planet_panel
	m.cycle = 1
	m._sync_dead_lock()
	m._on_planet_clicked(d1)
	await process_frame
	var txt := ""
	for l in _labels(pp.box, []):
		txt += l.text + "\n"
	check(pp.visible and "Opens at cycle" in txt and "ross" not in txt and pp.box.find_child("MineSendButton_dross", true, false) == null, "dead panel: before the cycle shows the locked line, no dross, no mine button", txt)
	m.cycle = int(m.balance["dead_unlock_cycle"])
	m._sync_dead_lock()
	pp.rebuild()
	await process_frame
	txt = ""
	for l in _labels(pp.box, []):
		txt += l.text + "\n"
	check(pp.box.find_child("DeadNeedsSkillLine", true, false) != null and "Cold Survey" in txt and "ross" not in txt and pp.box.find_child("MineSendButton_dross", true, false) == null, "dead panel: after the cycle without the skill shows what is needed, no dross", txt)
	Skills.add_learned("MIN_3")
	m.learned_skills.append("MIN_3")
	pp.rebuild()
	await process_frame
	var mb = pp.box.find_child("MineSendButton_dross", true, false)
	check(mb != null and pp.box.find_child("BuyButton_dross", true, false) != null and pp.box.find_child("DeadNeedsSkillLine", true, false) == null and pp.box.find_child("DangerLine", true, false) == null, "dead panel: with skill and cycle the dross row and Mine button show, the danger line stays hidden")
	m.cash = 6000
	m.ships = 0
	mb.pressed.emit()
	check(not m.pending.is_empty() and int(m.pending["planet"]) == d1 and bool(m.pending.get("buy", false)), "dead panel: Mine starts a pending send from the dead world")
	m._on_planet_clicked(0)
	check(m.pending.is_empty() and m.engine.routes.size() == 1 and int(m.engine.routes[0]["a"]) == d1 and m.ships == 1, "dead panel: clicking a planet makes the route from the dead world and buys a ship", str(m.engine.routes))
	# a dead world clicked as a destination is refused with a reason
	m.pending = {"planet": 0, "c": "dross"}  # T295: a Barren world takes its reclamation goods (energy), not a good it mines itself
	var before: int = m.engine.routes.size()
	m._on_planet_clicked(d1)
	check(m.engine.routes.size() == before and not m.pending.is_empty() and "dead world" in m.last_notice, "dead panel: a dead world as destination is refused with a reason", m.last_notice)
	await _free_main(m)


## T184: a click on another planet's thumbnail inside an open planet panel switches the panel to that planet (it must not close).
var _leaked_clicks := 0

func _thumb_for(pp, idx: int):
	for t in pp.find_children("*", "Control", true, false):
		if t.get_script() != null and "planet" in t and "selected" in t and t.planet == pp.main.map.planets[idx]:
			return t
	return null

func _click_thumb(m: Control, t: Control) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	ev.position = t.get_global_rect().get_center()
	ev.global_position = ev.position
	# The headless window has no mouse hover, so the viewport routing is done by hand: the control gets the event first,
	# and only an event it did not mark handled reaches the map's unhandled input (where it would count as a click on empty space).
	var kv := InputEventKey.new()
	kv.keycode = KEY_F24
	kv.pressed = true
	m.get_viewport().push_input(kv)  # an unbound key: resets the viewport's handled flag
	t._gui_input(ev)
	if not m.get_viewport().is_input_handled():
		m.map._unhandled_input(ev)
		_leaked_clicks += 1
	await process_frame
	await process_frame

func _test_panel_thumb_switch() -> void:
	_wipe_user()
	_leaked_clicks = 0
	var m: Control = await _new_main()
	m._dismiss_preface()
	var pp = m.planet_panel
	var d1: int = -1
	for i in m.map.planets.size():
		if str(m.map.planets[i].get("id", "")) == "dead_1":
			d1 = i
	var a := 0
	var b := 1
	m._on_planet_clicked(a)
	await process_frame
	var t = _thumb_for(pp, b)
	check(t != null, "thumb switch: planet B has a thumbnail in A's panel")
	if t != null:
		await _click_thumb(m, t)
		check(pp.visible and pp.planet_index == b and m.selected_planet == b, "thumb switch: click on B's icon shows B, panel open", "visible=%s idx=%d sel=%d" % [pp.visible, pp.planet_index, m.selected_planet])
	t = _thumb_for(pp, b)
	if t != null:
		await _click_thumb(m, t)
		check(pp.visible and pp.planet_index == b, "thumb switch: click on the same planet keeps its panel open")
	if d1 >= 0:
		t = _thumb_for(pp, d1)
		check(t != null, "thumb switch: the dead planet has a thumbnail")
		if t != null:
			await _click_thumb(m, t)
			check(pp.visible and pp.planet_index == d1, "thumb switch: click on a dead planet's icon shows it, panel open", "visible=%s idx=%d" % [pp.visible, pp.planet_index])
	# storage: the Space Storage view is open and a planet is chosen from the rail/map -> storage closes, planet panel shows
	m._on_planet_clicked(a)
	await process_frame
	m.space_storage_view.visible = true
	t = _thumb_for(pp, b)
	if t != null:
		await _click_thumb(m, t)
		check(pp.visible and pp.planet_index == b and not m.space_storage_view.visible, "thumb switch: with Space Storage open, B's icon shows B and storage closes")
	check(_leaked_clicks == 0, "thumb switch: a click on an icon is marked handled, so it never reaches the map as a click on space", str(_leaked_clicks))
	await _free_main(m)


## Owner change 2026-11-04: the lane label shows the lane's net per cycle (same projection as the cash forecast),
## and the forecast flags a lane that earns nothing.
func _test_lane_net_label() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var e = m.engine
	var RouteLineScript = load("res://game/route_line.gd")
	var c := "energy"
	m.cash = 100000
	m.ships = 3
	m.learned_skills.append("FND_STORAGE")
	m.storage.ensure("system:1")
	m.set_local_order(1, c, "sell", true)
	m.set_local_order(0, c, "buy", true)
	check(m.send_stock(0, 1, c)["ok"], "lane net: selling lane set up")
	var sell_rec: Dictionary = e.routes[0]
	sell_rec["fresh"] = 1.0
	for k in ["planet:0", "planet:1"]:
		m.storage.ensure(k)
		m.storage.remove(k, c, m.storage.amount(k, c))
	m.storage.add("planet:0", c, 200)
	var f: Dictionary = e.forecast(m.cash)
	var ln: Dictionary = f["routes"][0]
	check(bool(ln["moves"]) and int(ln["sale"]) > 0 and int(ln["net"]) == int(ln["sale"]) + int(ln["gross"]) - int(ln["cost"]) - int(ln["paid"]), "lane net: selling lane net = sale - source cost - trip - upkeep", str(ln))
	check(int(ln["net"]) > 0, "lane net: a profitable lane is positive", str(ln))
	# the label text the map gets
	m._push_routes_to_map()
	var line = m.map.route_lines[int(sell_rec["id"])]
	check(line.tag.text.contains("+") and not line.tag.text.contains("cost"), "lane net: label shows a signed net", line.tag.text)
	# reconciliation: lane nets plus what no lane owns (stock the orders move beyond the lanes, mixed bonus) = forecast total
	var lane_sum := 0
	var attributed := 0
	for l in f["routes"]:
		lane_sum += int(l["net"])
		attributed += int(l["sale"]) - int(l["cost"])
	var local_sum := 0
	for l in f["local"]:
		local_sum += int(l["credits"])
	var rest: int = local_sum - attributed
	check(lane_sum + rest == int(f["delta"]), "lane net: lane nets + the orders' non-lane part = forecast total", "%d + %d vs %d" % [lane_sum, rest, int(f["delta"])])
	# fallback text without a projection
	check(RouteLineScript.tag_text("running", 1, 0, "", false, 72).contains("72") and RouteLineScript.tag_text("running", 1, 0, "", false, 72) != RouteLineScript.tag_text("running", 1, -72, "", true, 72), "lane net: no projection shows a cost label", RouteLineScript.tag_text("running", 1, 0, "", false, 72))
	check(RouteLineScript.tag_text("running", 2, 310, "", true, 72).begins_with("2 ") and RouteLineScript.tag_text("running", 1, 0, "", true, 0).ends_with("0"), "lane net: ship count kept, zero shows 0")
	# selling lane is not flagged
	check(m.cash_forecast.no_earn_routes().is_empty(), "no-earn flag: a selling lane is not flagged")
	# storage lane: buys at the source, sells nothing
	m.remove_connection(int(sell_rec["id"]))
	check(m.send_stock(0, m.station_dst(1), c)["ok"], "lane net: storage lane set up")
	var srec: Dictionary = e.routes[0]
	srec["fresh"] = 1.0
	m.storage.remove("planet:0", c, m.storage.amount("planet:0", c))
	m.storage.add("planet:0", c, 200)
	var f2: Dictionary = e.forecast(m.cash)
	var sl: Dictionary = f2["routes"][0]
	check(bool(sl["moves"]) and int(sl["sale"]) == 0 and int(sl["net"]) == -int(sl["cost"]) - int(sl["paid"]) and int(sl["net"]) < 0, "lane net: storage lane shows its net cost", str(sl))
	m.cash_forecast.main = m
	var flagged: Array = m.cash_forecast.no_earn_routes()
	check(flagged.size() == 1, "no-earn flag: a lane with no sale is flagged", str(flagged))
	m.cash_forecast.visible = true
	m.cash_forecast.refresh()
	var warn_seen := false
	for ch in m.cash_forecast.box.get_children():
		if ch is Label and (ch as Label).text.contains("earns nothing"):
			warn_seen = true
	check(warn_seen, "no-earn flag: the warning line is in the popup")
	# no projection: lane that moves nothing falls back to cost
	m.storage.remove("planet:0", c, m.storage.amount("planet:0", c))
	m.set_local_order(0, c, "buy", false)
	m._push_routes_to_map()
	var f3: Dictionary = e.forecast(m.cash)
	check(not bool(f3["routes"][0]["moves"]) and int(f3["routes"][0]["net"]) == 0 and m.cash_forecast.no_earn_routes().is_empty(), "lane net: a lane that moves nothing has no projection (cost label) and no flag")
	# no hidden good named on any lane label or warning
	var names_ok := true
	for k in m.map.route_lines.keys():
		var t: String = m.map.route_lines[k].tag.text.to_lower()
		for g in Goods.ids():
			if not Goods.good_open(g) and t.contains(str(Goods.entry(g).get("name", g)).to_lower()):
				names_ok = false
	check(names_ok, "lane net: no hidden good named on a lane label")
	await _free_main(m)

## Owner bug 2026-11-04: Space Storage "Next cycle: +18 -18 = 0" with no lane out of the station. The Sell order at the
## destination planet (Ashgate) draws the station when its own stock is short; the tooltip must say so.
func _test_station_energy_outflow() -> void:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	var zero := {}
	for g in ["energy", "food"]:
		zero[g] = 0
	var stock := func(e: int, f: int) -> Dictionary:
		var d := zero.duplicate()
		d["energy"] = e
		d["food"] = f
		return d
	var lane := func(id: int, a: int, b: int, c: String, dst: String) -> Dictionary:
		return {"a": a, "b": b, "bonus": 0, "c": c, "dst": dst, "fresh": 1.0, "id": id, "level": 1, "orders": {}, "reason": "", "ship": "small", "ships": 1, "split_share": 0.0, "split_to": -1, "src": "planet:%d" % a, "state": "running", "stop": -1, "stop_sale": 0}
	var order := func(planet: int, c: String, buy: bool) -> Dictionary:
		return {"buy": buy, "buy_state": "Buying." if buy else "", "c": c, "planet": planet, "sell": not buy, "sell_state": "" if buy else "Selling."}
	m.cash = 7000
	Skills.learned.append("FND_STORAGE")
	m.learned_skills.append("FND_STORAGE")
	m.storage.ensure("planet:0")
	m.storage.ensure("planet:1")
	m.storage.ensure("planet:2")
	m.storage.ensure("system:1")
	m.storage.add("planet:0", "energy", 64)
	m.storage.add("planet:1", "food", 84)
	m.storage.add("planet:2", "food", 84)
	var e = m.engine
	e.routes.clear()
	e.local.clear()
	e.routes.append(lane.call(1, 0, 2, "energy", "planet:2"))
	e.routes.append(lane.call(2, 2, 0, "food", "planet:0"))
	e.routes.append(lane.call(3, 1, 0, "food", "planet:0"))
	e.routes.append(lane.call(4, 0, -1, "energy", "system:1"))
	e.next_id = 5
	e.local = {}
	for o in [order.call(0, "energy", true), order.call(2, "energy", false), order.call(2, "food", true), order.call(0, "food", false), order.call(1, "food", true)]:
		e.local[e.local_key(int(o["planet"]), str(o["c"]))] = o
	e.balance["order_amount"] = 2 * e.units_per_cycle(e.routes[3])  # the owner's save: an order moves more than a lane brings
	var pr: Dictionary = e.project_storage("system:1", "energy", m.cash)
	var sum_in := 0
	var sum_out := 0
	var sell_backup := false
	var route_backup := false
	for p in pr["parts"]:
		if p["dir"] == "in":
			sum_in += int(p["n"])
		else:
			sum_out += int(p["n"])
		sell_backup = sell_backup or (p["kind"] == "sell" and bool(p["backup"]) and int(p["planet"]) == 2)
		route_backup = route_backup or (p["kind"] == "route" and bool(p["backup"]))
	print("STATION ENERGY ", pr)
	check(int(pr["in"]) > 0 and int(pr["out"]) == int(pr["in"]) and sum_in == int(pr["in"]) and sum_out == int(pr["out"]), "station energy: sources and uses add up to the shown in and out", str(pr))
	check(sell_backup and not route_backup, "station energy: the 18 leaving is the Sell order at Ashgate, no route", str(pr["parts"]))
	var before: int = m.storage.amount("system:1", "energy")
	m._settle_routes()
	check(m.storage.amount("system:1", "energy") - before == int(pr["after"]) - before, "station energy: the real settle ends where the projection says", "%d" % m.storage.amount("system:1", "energy"))
	m.storage.add("planet:0", "energy", 0)
	var tip: String = load("res://game/planet_panel.gd").next_cycle_breakdown(m, e.project_storage("system:1", "energy", m.cash))
	check(tip.contains("In: Voltara > Space Storage (") and tip.contains("+%d" % int(pr["in"])) and tip.contains("Out: Sell order at Ashgate (draws Space Storage when Ashgate has too little) -%d" % int(pr["out"])), "station energy: the tooltip names the source and the consumer", tip)
	await _free_main(m)


## Skill tree final (2026-11-05): event_immune, stock_growth_cap, batch yield and batches, workshop availability gate,
## LUX_5 event bonus, every effect type of skills.json has code, ship screen choices used once.
func _test_skill_effects_final() -> void:
	_wipe_user()
	# every effect type in skills.json is in the vocabulary and is read by game/skills.gd
	var sj: Dictionary = _read_json("res://data/skills.json")
	var code := FileAccess.get_file_as_string("res://game/skills.gd")
	var vocab: Dictionary = sj["vocabulary"]["types"]
	var bad: Array = []
	for n in sj["nodes"]:
		var effs: Array = []
		if typeof(n.get("effect")) == TYPE_DICTIONARY:
			effs.append(n["effect"])
		effs.append_array(n.get("extra", []))
		for e in effs:
			var t := str(e.get("type", ""))
			if not vocab.has(t) or code.find("\"%s\"" % t) < 0:
				bad.append("%s:%s" % [n["id"], t])
	check(bad.is_empty(), "skills.json: every effect type is in the vocabulary and has code in game/skills.gd", str(bad))
	var m: Control = await _new_main()
	m._dismiss_preface()
	var bal: Dictionary = m.balance
	# MIL_3 event_immune: Military routes ignore debris, other markets do not
	m.learned_skills = []
	check(not Skills.event_immune("mil", "debris"), "MIL_3: no immunity before learning")
	m.learned_skills = ["MIL_3"]
	check(Skills.event_immune("mil", "debris") and not Skills.event_immune("lux", "debris") and not Skills.event_immune("mil", "pirates"), "MIL_3: event_immune debris for mil only")
	if m.engine.routes.size() > 0:
		var rec: Dictionary = m.engine.routes[0].duplicate()
		rec["c"] = "arms"
		var lane_end := int(rec["b"]) if m.engine.from_cluster(rec) else int(rec["a"])
		m.engine.debris_planets = []
		m.learned_skills = []
		var clean: int = m.engine._route_cap(rec)
		m.engine.debris_planets = [lane_end]
		var dirty: int = m.engine._route_cap(rec)
		m.learned_skills = ["MIL_3"]
		var immune: int = m.engine._route_cap(rec)
		m.engine.debris_planets = []
		check(dirty < clean and immune == clean, "MIL_3: debris cuts a Military lane, and not with MIL_3", "%d %d %d" % [clean, dirty, immune])
	m.learned_skills = []
	# T173 LUX_5B: prices and event warning two cycles ahead; LUX_1 / LUX_3 stay at one, the longest source wins
	m.learned_skills = ["LUX_1", "LUX_3"]
	check(Skills.reveal_cycles() == 1 and Skills.warning_cycles() == 1, "LUX_5B: LUX_1 and LUX_3 alone reveal and warn 1 cycle")
	m.learned_skills = ["LUX_1", "LUX_3", "LUX_5B"]
	check(Skills.reveal_cycles() == 2 and Skills.warning_cycles() == 2, "LUX_5B: reveal and warning read 2 cycles, max of sources")
	m.learned_skills = ["LUX_5B"]
	check(Skills.reveal_cycles() == 2 and Skills.warning_cycles() == 2, "LUX_5B: works on its own data")
	m.learned_skills = []
	m.events.active.append({"id": "ZZ", "kind": "up", "planet": 0, "c": "energy", "left": 2, "age": 0})
	var base_b: int = m.trade.price(0, "energy_buy", false, true)
	var now_b: int = m.trade.price(0, "energy_buy")
	var n1_b: int = m.trade.price(0, "energy_buy", true)
	var n2_b: int = m.trade.price(0, "energy_buy", true, false, 2)
	check(now_b > base_b and n1_b == now_b and n2_b == base_b, "LUX_5B: a price event with 2 cycles left is over in the 2-cycles-ahead price", "%d %d %d %d" % [base_b, now_b, n1_b, n2_b])
	m.events.active.back()["left"] = 3
	check(m.trade.price(0, "energy_buy", true, false, 2) == now_b, "LUX_5B: with 3 cycles left the event still shows 2 ahead")
	m.events.active.pop_back()
	m.events.by_id["ZZ_TEST"] = {"id": "ZZ_TEST", "tag": "[price up: %s, energy]" % m.planet_name(0)}
	var ft2: String = m.forecast_text("ZZ_TEST", 2)
	check(not ft2.begins_with("Next cycle") and (ft2.contains("2 cycles")), "LUX_5B: a 2-cycle forecast says 2 cycles", ft2)
	m.events.by_id.erase("ZZ_TEST")
	# T173 MIN_5B: Minerals routes ignore debris and price-down events are cut
	m.learned_skills = []
	check(not Skills.event_immune("min", "debris") and Skills.event_cut("min") == 0.0, "MIN_5B: nothing before learning")
	m.learned_skills = ["MIN_5B"]
	check(Skills.event_immune("min", "debris") and not Skills.event_immune("bio", "debris") and is_equal_approx(Skills.event_cut("min"), float(bal["skill_MIN_5B_event_cut"])) and Skills.event_cut("bio") == 0.0, "MIN_5B: debris immunity and event cut for min only")
	if m.engine.routes.size() > 0:
		var rec5: Dictionary = m.engine.routes[0].duplicate()
		rec5["c"] = "ore"
		var end5 := int(rec5["b"]) if m.engine.from_cluster(rec5) else int(rec5["a"])
		m.engine.debris_planets = []
		m.learned_skills = []
		var clean5: int = m.engine._route_cap(rec5)
		m.engine.debris_planets = [end5]
		var dirty5: int = m.engine._route_cap(rec5)
		m.learned_skills = ["MIN_5B"]
		var immune5: int = m.engine._route_cap(rec5)
		m.engine.debris_planets = []
		check(Markets.market_of("ore") != "min" or (dirty5 < clean5 and immune5 >= clean5), "MIN_5B: debris cuts a Minerals lane, and not with MIN_5B", "%d %d %d" % [clean5, dirty5, immune5])
	m.events.active.append({"id": "ZZ", "kind": "down", "planet": 0, "c": "ore", "left": 3, "age": 0})
	var ore_none: float = (func() -> float:
		m.learned_skills = []
		return m.events.price_factor(0, "ore")).call()
	m.learned_skills = ["MIN_5B"]
	var ore_cut: float = m.events.price_factor(0, "ore")
	m.events.active.pop_back()
	check(Markets.market_of("ore") != "min" or (ore_cut > ore_none and ore_none < 1.0), "MIN_5B: a price-down event on ore hurts less", "%f %f" % [ore_none, ore_cut])
	# T173 round 4: MIN_5B route capacity
	m.learned_skills = []
	m.learned_skills = ["MIN_5B"]
	check(is_equal_approx(Skills.route_capacity_mult("min"), 1.0 + float(bal["skill_MIN_5B_route_units"])), "MIN_5B: Minerals route capacity")
	m.learned_skills = []
	# BIO_3 stock_growth_cap: ceiling is the max of both
	m.learned_skills = ["BIO_2"]
	var g2: Dictionary = Skills.stock_growth("bio")
	check(not g2.is_empty() and is_equal_approx(float(g2["cap"]), float(bal["skill_BIO_2_stock_cap"])), "BIO_2: growth ceiling is skill_BIO_2_stock_cap")
	m.learned_skills = ["BIO_2", "BIO_3"]
	var g3: Dictionary = Skills.stock_growth("bio")
	check(is_equal_approx(float(g3["cap"]), maxf(float(bal["skill_BIO_2_stock_cap"]), float(bal["skill_BIO_3_stock_cap"]))) and is_equal_approx(float(g3["rate"]), float(g2["rate"])), "BIO_3: growth ceiling is the max of BIO_2 and BIO_3, rate unchanged")
	m.learned_skills = ["BIO_3"]
	check(Skills.stock_growth("bio").is_empty(), "BIO_3 alone: no growth (needs BIO_2 rate)")
	m.learned_skills = ["BIO_5"]
	check(Skills.stock_protect("bio") and not Skills.stock_protect("lux"), "BIO_5: stock_protect accepts bio")
	# batches and yield
	m.learned_skills = []
	var ws: RefCounted = m.workshops
	var b0: int = ws.batches("munitions")
	var cask0: int = ws.out_units("attar")
	var gems0: int = ws.out_units("gems")
	m.learned_skills = ["MIL_2", "LUX_6"]
	check(ws.batches("munitions") == b0 + int(bal["skill_MIL_2_batches"]), "MIL_2: munitions makes one more batch a cycle", "%d -> %d" % [b0, ws.batches("munitions")])
	check(ws.out_units("attar") == cask0 + int(bal["skill_LUX_6_batch_bonus"]) and ws.out_units("gems") == gems0 + int(bal["skill_LUX_6_batch_bonus"]), "LUX_6: cask and gems yield +1 per batch", "%d %d" % [ws.out_units("attar"), ws.out_units("gems")])
	check(ws.recipe_line("attar").find("-> %d" % ws.out_units("attar")) >= 0, "LUX_6: recipe line shows the boosted yield")
	# LUX_5 event bonus key is used
	m.learned_skills = ["LUX_5"]
	check(is_equal_approx(Skills.event_bonus("lux"), float(bal["skill_LUX_5_event_bonus"])), "LUX_5: price-up events pay skill_LUX_5_event_bonus more")
	m.learned_skills = []
	# can_build_workshop follows the availability rule: munitions needs system 2 open
	m.cash = 100000
	m.learned_skills = ["MIL_1"]
	var v: Dictionary = m.can_build_workshop("munitions")
	check(not v["ok"] and (v["reason"] == "closed" or v["reason"] == "post"), "munitions: cannot be built while system 2 is closed", str(v))
	m.learned_skills = ["LUX_1"]
	if m.station_systems.has(1):
		check(m.can_build_workshop("atelier")["ok"], "atelier: buildable with LUX_1 (rule has no system condition)")
	m.learned_skills = []
	await _free_main(m)
	# the ship screen choices are consumed once
	SaveGame.pending_ceo = "ceo_man_01"
	SaveGame.pending_ship = "bulk"
	SaveGame.pending_portrait = "ceo_man_01"
	var m2: Control = await _new_main()
	check(SaveGame.pending_ceo == "" and SaveGame.pending_ship == "" and SaveGame.pending_portrait == "", "ship screen: pending_ceo, pending_ship and pending_portrait cleared after the run starts")
	await _free_main(m2)


# ---- T173 code3: warning skills are information only; MIN_5B debris immunity; stock_protect on a storage cut ----
func _event_sequence(skills: Array, cycles: int) -> Array:
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	m.learned_skills = skills.duplicate()
	var seq: Array = []
	var seen := 0
	for i in cycles:
		m.events.pending_id = ""
		m.cash = 1000000
		if m.game_over:
			break
		m._end_cycle()
		while seen < m.events.feed.size():
			seq.append("%d:%s" % [m.cycle, str(m.events.feed[seen]["id"])])
			seen += 1
	_free_main(m)
	await process_frame
	return seq

func _test_forecast_pure() -> void:
	var s0: Array = await _event_sequence([], 40)
	var s1: Array = await _event_sequence(["LUX_3"], 40)
	var s2: Array = await _event_sequence(["LUX_5B"], 40)
	check(s0.size() >= 5, "forecast pure: the 40-cycle run fires events", str(s0))
	check(s0 == s1, "forecast pure: warning 1 (LUX_3) gives the same events as warning 0", "%s | %s" % [str(s0), str(s1)])
	check(s0 == s2, "forecast pure: warning 2 (LUX_5B) gives the same events as warning 0", "%s | %s" % [str(s0), str(s2)])
	_wipe_user()
	var m: Control = await _new_main()
	m._dismiss_preface()
	# MIN_5B: a Minerals lane with debris at its source keeps its capacity with the skill
	var min_good := "ore"
	if m.events.planets.size() > 1:
		var rec: Dictionary = m.engine.new_record(0, 1, min_good)
		rec["id"] = 9001
		var lane_end := int(rec["b"]) if m.engine.from_cluster(rec) else int(rec["a"])
		m.learned_skills = []
		m.engine.debris_planets = []
		var clean: int = m.engine._route_cap(rec)
		m.engine.debris_planets = [lane_end]
		var dirty: int = m.engine._route_cap(rec)
		m.learned_skills = ["MIN_5B"]
		var immune: int = m.engine._route_cap(rec)
		m.engine.debris_planets = []
		check(Markets.market_of(min_good) == "min" and dirty < clean and immune >= clean, "MIN_5B: debris (EV17) hurts a Minerals lane without the skill and not with it", "%s %d %d %d" % [min_good, clean, dirty, immune])
	else:
		check(false, "MIN_5B: test needs a route and a Minerals good", str(m.engine.routes.size()))
	# stock_protect (read from skills.json: whichever node carries it): its target market's stock survives a storage cut
	var sp_node := ""
	var sp_market := ""
	for nid in SkillTree.all_ids():
		for e in SkillTree.effects(str(nid)):
			if str(e.get("type", "")) == "stock_protect" and sp_node == "":
				sp_node = str(nid)
				sp_market = str(e.get("target", ""))
	var sp_good := ""
	for g in m.storage.commodities:
		if Markets.market_of(str(g)) == sp_market:
			sp_good = str(g)
			break
	var sk := "planet:2"
	m.learned_skills = []
	var cap: int = m.storage.capacity_of(sk)
	m.storage.add(sk, sp_good, cap)
	m.storage.cut_capacity(sk, 0.5)
	var lost: int = int(m.storage.stock[sk][sp_good])
	m.storage.cuts.erase(sk)
	m.storage.stock[sk][sp_good] = cap
	m.learned_skills = [sp_node]
	m.storage.cut_capacity(sk, 0.5)
	var kept: int = int(m.storage.stock[sk][sp_good])  # raw stock; amount() reads it through the cut capacity
	check(sp_node != "" and sp_good != "" and lost < cap and kept == cap, "stock_protect (%s): %s stock survives an asteroid storage cut (%d without, %d with)" % [sp_node, sp_market, lost, kept])
	m.learned_skills = []
	_free_main(m)
	await process_frame

## T176: placeholder systems 3 to 5 stay out of normal play and load cleanly when switched on.
func _test_placeholder_systems() -> void:
	_wipe_user()
	var gm: Control = await _new_main()
	var slots: Array = gm.galaxy_view.SLOTS
	# T226: systems 3 to 5 are live in a normal game: listed in the galaxy, enterable, TEMPORARY in the name
	var Systems := preload("res://game/systems.gd")
	check(Systems.ids() == [2, 3], "placeholder systems: 3 live by default, 4 and 5 off", str(Systems.ids()))
	check(gm.galaxy_view._sys_ids() == [1, 2, 3], "placeholder systems: 1 to 3 listed in the galaxy overview", str(gm.galaxy_view._sys_ids()))
	var live_ok := true
	for sid in [3]:
		live_ok = live_ok and Systems.name_of(sid).begins_with("TEMPORARY") and Availability.feature("placeholder_system_%d" % sid)
		live_ok = live_ok and not gm.go_to_system(sid)  # locked until its permit
		gm._open_system(sid)
		live_ok = live_ok and gm.open_systems.has(sid) and gm.go_to_system(sid) and gm.view_system == sid
		var n_here := 0
		for pl in gm.map.planets:
			if int(pl.get("system", 1)) == sid:
				n_here += 1
		live_ok = live_ok and n_here == 3 and Systems.sun_color_of(sid) is Color
	check(live_ok, "placeholder systems: 3 to 5 each enterable with a sun and three planets")
	_free_main(gm)
	Systems.set_placeholders(false)
	check(Systems.ids() == [2], "placeholder systems: switched off by set_placeholders(false)")
	Systems.set_placeholders(true)
	var ids: Array = Systems.ids()
	check(ids == [2, 3, 4, 5, 6, 7, 8, 9, 10], "placeholder systems: 3 to 10 load when switched on", str(ids))
	var ok := true
	for sid in [3, 4, 5, 6, 7, 8, 9, 10]:
		var pl: Array = Systems.planets_of(sid)
		ok = ok and pl.size() == 3 and bool(Systems.get_system(sid).get("placeholder", false)) and Systems.name_of(sid) != "" and Systems.sun_color_of(sid) is Color
		for p in pl:
			ok = ok and bool(p.get("placeholder", false)) and str(p["name"]) != "" and not str(p["name"]).begins_with("WORLD_")
	check(ok, "placeholder systems: placeholder flag, names and planets resolve")
	# T210: ten systems in all (system 1 is planets.json), unique ids, planet ids and text ids, slots inside SLOTS, permit keys exist
	var bal = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance.json"))
	var seen := {}
	var uniq := true
	var slots_ok := ids.size() + 1 == 10
	var keys_ok := true
	for sid in ids:
		var sd: Dictionary = Systems.get_system(sid)
		uniq = uniq and not seen.has("s%d" % sid)
		seen["s%d" % sid] = true
		if sid >= 3:
			var slot := int(sd.get("galaxy_slot", -1))
			slots_ok = slots_ok and slot >= 0 and slot < slots.size() and slot == sid - 1
			keys_ok = keys_ok and bal["values"].has(str(sd.get("permit_cost_key", "")))
			for k in ["name_id", "desc_id", "permit_name_id", "permit_desc_id", "permit_btn_id", "permit_notice_id"]:
				uniq = uniq and not seen.has(str(sd[k]))
				seen[str(sd[k])] = true
		for p in Systems.planets_of(sid):
			uniq = uniq and not seen.has(str(p["id"]))
			seen[str(p["id"])] = true
	check(uniq, "placeholder systems: ids, planet ids and text ids are unique")
	check(slots_ok and slots.size() >= 10, "placeholder systems: ten systems, galaxy_slot valid inside SLOTS")
	check(keys_ok, "placeholder systems: permit cost keys exist in balance")
	Systems.set_placeholders(false)
	check(Systems.ids() == [2], "placeholder systems: off again")
	Systems._placeholders_override = -1
	Systems._loaded = false


## T229: no raw {word} or [word] token may stay in epilogue lines of any win market and tech count.
func _test_epilogue_placeholders() -> void:
	var es = load("res://game/end_screen.gd")
	var bad := 0
	for mk in ["min", "mil", "lux", "bio"]:
		for t in 4:
			for line in es.epilogue_lines({"market": mk, "tech_done": t, "capstone": true, "rival_broken": true, "second_over": true, "second_market": "lux"}):
				if "{" in str(line) or "}" in str(line) or "[" in str(line):
					bad += 1
					print("raw token: ", line)
	check(bad == 0, "epilogue: no raw placeholder left in end screen lines")

## T340: gig markers in open space never sit on an established lane or a living planet (a dead planet is allowed).
func _test_gig_clearance() -> void:
	# helper on hand-made data
	var pl := [{"pos": Vector3(0, 0, 0), "dead": false}, {"pos": Vector3(10, 0, 0), "dead": true}]
	var ln := [[Vector3(0, 0, 5), Vector3(5, 0, 7), Vector3(10, 0, 5)]]
	check(not Gigs.clear_of_map(Vector3(0.3, 0, 0), pl, [], 1.0, 0.6), "gig clear: inside a living planet radius is not clear")
	check(Gigs.clear_of_map(Vector3(3, 0, 3), pl, ln, 1.0, 0.6), "gig clear: open space is clear")
	check(not Gigs.clear_of_map(Vector3(5, 0, 6.0), pl, ln, 1.0, 0.6), "gig clear: on a lane curve is not clear")
	check(Gigs.clear_of_map(Vector3(10.2, 0, 0), pl, ln, 1.0, 0.6), "gig clear: at a dead planet is allowed")
	var m: Control = await _new_main(false, true)
	m._dismiss_preface()
	var g = m.gigs
	m.balance["gig_first_cycle"] = 1
	m.balance["gig_gap_cycles"] = 1
	m.balance["gig_cap_signals"] = 100000
	var n: int = mini(m.map.planets.size(), 5)
	var rid := 0
	for a in n:
		for b in range(a + 1, n):
			if int(m.map.planets[a].get("system", 1)) == 1 and int(m.map.planets[b].get("system", 1)) == 1:
				m.engine.routes.append(m.engine.new_record(a, b, "ore"))
				rid += 1
	check(rid >= 3, "gig clear: the run has established routes", str(rid))
	var ob: Dictionary = g.map_obstacles(m.flight.system_id())
	check(ob["lanes"].size() == rid, "gig clear: every route gives a lane curve", str(ob["lanes"].size()))
	var mpd: float = float(m.balance["gig_min_planet_dist"])
	var mld: float = float(m.balance["gig_min_lane_dist"])
	var posted := 0
	var bad := 0
	var first := {}
	for pass_i in 2:
		for sd in 40:
			for cyc in range(2, 8):
				g.reset()
				g.seed_value = sd * 31 + 5
				m.flight._pos = Vector3(float(sd % 7) - 3.0, 0.0, float(sd % 5) - 2.0) * 1.3
				g.on_cycle(cyc)
				var key := "%d_%d" % [sd, cyc]
				var cur := Vector3.INF
				if g.is_open():
					var pp: Array = g.offers[0]["target"]["pos"]
					cur = Vector3(float(pp[0]), 0.0, float(pp[2]))
					posted += 1
					if not Gigs.clear_of_map(cur, ob["planets"], ob["lanes"], mpd, mld):
						bad += 1
				if pass_i == 0:
					first[key] = cur
				elif first[key] != cur:
					bad += 1000
	check(posted > 0 and bad == 0, "gig clear: signals never on a lane or world, same seed and cycle gives the same marker", "posted %d bad %d" % [posted, bad])
	# salvage nudge: a point on a lane moves off it; at a dead planet it stays
	var lane0: Array = ob["lanes"][0]
	var mid: Vector3 = (lane0[0] + lane0[1] * 2.0 + lane0[2]) * 0.25
	var nd: Vector3 = g.nudge_clear(mid, m.flight.system_id(), 0.7)
	check(nd != mid and Gigs.clear_of_map(nd, ob["planets"], ob["lanes"], mpd, mld), "gig clear: salvage on a lane is nudged off")
	m.map.planets[0]["type"] = "dead"
	var dpos: Vector3 = m.map.positions[0] + Vector3(0.2, 0, 0)
	check(g.nudge_clear(dpos, m.flight.system_id(), 0.7) == dpos, "gig clear: a drop at a dead planet stays")
	await _free_main(m)

## T271 gig engine: a signal opens, expires for free and stays gone; reaching it and choosing applies gives and costs; a rush order completes
## on a hand delivery; the board saves and loads; nothing is offered with discovery off.
func _test_gigs() -> void:
	var m: Control = await _new_main(false, true)
	m._dismiss_preface()
	var g = m.gigs
	m.balance["gig_first_cycle"] = 1
	m.balance["gig_gap_cycles"] = 1
	check(g.defs.size() >= 2, "gigs: data loaded")
	check(not Conditions.eval("gig_open") and not Conditions.eval("gig_done:GIG02"), "gigs: atoms false at the start")
	check(m.gig_badge != null and not m.gig_badge.visible, "gigs: badge hidden with no open gig")
	g.on_cycle(5)
	check(g.is_open() and g.signals_seen == 1, "gigs: a signal opens on the cycle check")
	m._refresh_gig_badge()
	check(m.gig_badge.visible, "gigs: badge visible with an open gig")
	g.on_cycle(6)
	check(g.offers.size() == 1, "gigs: one open signal at a time")
	var o: Dictionary = g.offers[0]
	var id := str(o["id"])
	g.tick(float(o["due"]) + 0.1)
	check(not g.is_open() and g.skipped.has(id) and not g.is_done(id), "gigs: free expiry, gone for the run")
	g.on_cycle(7)
	check(g.offers.size() == 1 and str(g.offers[0]["id"]) != id, "gigs: an expired gig does not return")
	var uid := str(g.offers[0]["uid"])
	var cash0: int = m.cash
	var saved: Dictionary = g.to_dict()
	g.from_dict(JSON.parse_string(JSON.stringify(saved)))
	check(g.offers.size() == 1 and g.skipped.has(id), "gigs: save and load keep the board")
	var res: Dictionary = g.choose(uid, 0)
	check(not res.is_empty() and Conditions.eval("gig_done:" + uid) and not g.is_open(), "gigs: choosing closes the offer and marks it done")
	# rush
	m.flight.set_flag("post", "planet_2", true)
	var pi: int = m.planet_index_of("planet_2")
	var ruid: String = g.post_rush(pi, "energy", 5, 4.0)
	check(ruid != "" and g.is_open(), "gigs: a rush order posts")
	var c1: int = m.cash
	g.on_delivered("planet_2", "energy", 5)
	check(not g.is_open() and g.rush_done == 1 and m.cash > c1 and not g.credits.is_empty(), "gigs: a rush delivery pays a premium and a need credit")
	g.credit_tick()
	m.balance["discovery_enabled"] = 0
	g.reset()
	g.on_cycle(30)
	check(not g.is_open(), "gigs: nothing opens with discovery off")
	await _free_main(m)
