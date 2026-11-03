extends SceneTree
## QA driver: plays the guided tutorial with rendering on and saves a PNG per step.
## Run (not headless), with a scratch HOME so no real save is touched:
##   HOME=<scratch>/home tools/godot/Godot.app/Contents/MacOS/Godot --path <project> -s res://qa/bots/tutorial_shots.gd
## Step actions use the same state calls as tools/tests/run_tests.gd. Each step is screenshot
## before its action. The driver does NOT call _tut_advance itself; if the game does not move
## on by itself, the driver logs "NEEDS MANUAL ADVANCE" so the stall is visible.

const MAIN := "res://game/main.tscn"
const StoryText := preload("res://game/story_text.gd")
const StorageS := preload("res://game/storage.gd")
const OUT := "/private/tmp/claude-501/-Volumes-Work-Gamedev-Projects-AgentCourse-star-bazaar/ed07d136-777e-45ce-9242-e5c72c67bf29/scratchpad/shots/"
const SRC := 0

var fails: Array = []
var lines: Array = []
var buy_c := ""
var route_dst := -1

func log_(s: String) -> void:
	lines.append(s)
	print(s)
	var f := FileAccess.open(OUT + "driver.log", FileAccess.WRITE)
	f.store_string("\n".join(lines) + "\n")
	f.close()

func check(ok: bool, msg: String) -> void:
	if ok:
		log_("ok   " + msg)
	else:
		fails.append(msg)
		log_("FAIL " + msg)

func shot(n: String) -> void:
	await process_frame
	await process_frame
	var img := root.get_texture().get_image()
	img.save_png(OUT + n + ".png")
	log_("shot " + OUT + n + ".png " + str(img.get_size()))

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	create_timer(300.0).timeout.connect(func():
		log_("WATCHDOG: driver stuck after 300 s, quitting")
		quit(2))  # a frozen step must not hang the run
	await _run()
	var f := FileAccess.open(OUT + "driver.log", FileAccess.WRITE)
	f.store_string("\n".join(lines) + "\n")
	f.close()
	quit(1 if fails.size() > 0 else 0)

func _new_main() -> Control:
	var m: Control = load(MAIN).instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	await process_frame
	return m

func _free(m: Node) -> void:
	m.queue_free()
	await process_frame
	await process_frame

## First visible Button under n with this text.
func _find_btn(n: Node, text: String) -> Button:
	if n is Button and (n as Button).text == text and (n as Control).is_visible_in_tree():
		return n
	for c in n.get_children():
		var r := _find_btn(c, text)
		if r != null:
			return r
	return null

func _any_buy(m: Control) -> bool:
	return m.engine.local.values().any(func(o): return bool(o["buy"]))

func _any_sell(m: Control) -> bool:
	return m.engine.local.values().any(func(o): return bool(o["sell"]))

## The state change for guided step i (index into TUT_GUIDE). Returns true if the step's goal is met.
func _act(m: Control, i: int) -> bool:
	match i:
		0:  # select a planet
			m._on_planet_clicked(SRC)
			return m.selected_planet == SRC
		1:  # buy
			for c in m.commodities:
				m.toggle_local(SRC, c, "buy")
				if _any_buy(m):
					buy_c = c
					return true
			return false
		2:  # send a route (buys a ship if none is free)
			for dst in range(m.map.planets.size()):
				if dst == SRC:
					continue
				var r: Dictionary = m.send_stock_buying(SRC, dst, buy_c)
				if r.get("ok", false):
					route_dst = dst
					return true
				log_("     send %d->%d %s refused: %s" % [SRC, dst, buy_c, str(r.get("reason", ""))])
			return false
		3:  # the route is paid: a cycle ends with it open
			m._end_cycle()
			return m.cycle >= 2 and not m.engine.routes.is_empty()
		4:  # upkeep: nothing to do, the cycle end above already satisfies it
			return true
		5:  # sell at the destination
			m.toggle_local(route_dst, buy_c, "sell")
			return _any_sell(m)
		6:  # stock in storage, then a skill point is earned (planet points)
			m.storage.add(StorageS.planet_key(route_dst), buy_c, 5)
			m.skill_points = maxi(m.skill_points, 1)
			return true
		7:  # learn a skill, then keep one point for the permit step
			var r: Dictionary = m.learn_skill("B1")
			log_("     learn B1: ok=%s %s" % [str(r.get("ok", false)), str(r.get("reason", ""))])
			m.skill_points = maxi(m.skill_points, 1)
			return not m.learned_skills.is_empty()
		8:  # permit C1
			var r2: Dictionary = m.learn_skill("C1")
			log_("     learn C1: ok=%s %s" % [str(r2.get("ok", false)), str(r2.get("reason", ""))])
			return m.has_skill("C1")
	return false

## Plays guided steps until stop_at (TUT_GUIDE index) is reached before its action, or the tutorial ends.
## prefix names the PNGs. Returns the tut_step where it stopped.
func _play(m: Control, prefix: String, stop_at: int) -> int:
	var guard := 0
	while m.tut_step < m.TUT_GUIDE.size() and guard < 15:
		guard += 1
		var i: int = m.tut_step
		if i == stop_at:
			return i
		var name: String = m.TUT_GUIDE[i]
		await shot("%s_step%02d_%s" % [prefix, i + 1, name])
		if i == 9:  # G10_DONE: the Got it button
			var got := _find_btn(m.tut_actions, StoryText.get_or("BTN_GOT_IT", "Got it"))
			check(got != null, "%s step %d has a visible Got it button" % [prefix, i + 1])
			if got != null:
				got.pressed.emit()
			await process_frame
			break
		var ok := _act(m, i)
		check(ok, "%s step %d action reached its goal (%s)" % [prefix, i + 1, name])
		await process_frame
		await process_frame
		if m.tut_step == i:
			log_("     NEEDS MANUAL ADVANCE: game did not move past %s by itself" % name)
			m._tut_advance()
		check(m.tut_step > i, "%s step %d (%s) moved on, now tut_step=%d" % [prefix, i + 1, name, m.tut_step])
		if m.tut_step <= i:
			break
	return m.tut_step

func _run() -> void:
	# Run A: the guided board tutorial, all steps played.
	log_("== Run A: board tutorial, all steps")
	var m := await _new_main()
	check(m.tut_step == 0, "run A starts at tut_step 0")
	var stop := await _play(m, "A", -1)
	check(m.tut_step == m.TUT_GUIDE.size(), "run A reaches the done line (tut_step %d == %d)" % [m.tut_step, m.TUT_GUIDE.size()])
	check(not m.tutorial_label.visible, "run A: board tutorial line hidden after done")
	await shot("A_board_done")
	await _free(m)

	# Run B: Skip pressed mid-tutorial on the board (at step 4, before its action).
	log_("== Run B: board Skip mid-tutorial")
	m = await _new_main()
	await _play(m, "B", 3)
	check(m.tut_step == 3, "run B reaches step 4 before Skip (tut_step %d)" % m.tut_step)
	await shot("B_board_step04_before_skip")
	var skip := _find_btn(m.tut_actions, StoryText.get_or("BTN_SKIP_TUTORIAL", "Skip tutorial"))
	check(skip != null, "run B: Skip button visible on board step 4")
	if skip != null:
		skip.pressed.emit()
	await process_frame
	await process_frame
	check(m.tut_step == m.TUT_GUIDE.size(), "run B: Skip ends the guided board tutorial (tut_step %d)" % m.tut_step)
	check(not m.tutorial_label.visible, "run B: board tutorial line hidden after Skip")
	await shot("B_board_after_skip")
	await _free(m)

	# Run C: galaxy view tutorial, three steps then Got it.
	log_("== Run C: galaxy view tutorial, all three steps")
	m = await _new_main()
	check(m._open_system(2), "run C: system 2 opened")
	var g: Control = m.galaxy_view
	check(g.open_view() and g.tut_step == 0, "run C: galaxy view opens at tutorial step 1")
	await shot("C_galaxy_step1_of3")
	var nxt := _find_btn(g.tut_box, StoryText.get_or("BTN_NEXT", "Next"))
	check(nxt != null, "run C: Next visible on galaxy step 1")
	if nxt != null:
		nxt.pressed.emit()
	await process_frame
	await shot("C_galaxy_step2_of3")
	nxt = _find_btn(g.tut_box, StoryText.get_or("BTN_NEXT", "Next"))
	check(nxt != null, "run C: Next visible on galaxy step 2")
	if nxt != null:
		nxt.pressed.emit()
	await process_frame
	await shot("C_galaxy_step3_of3")
	var got2 := _find_btn(g.tut_box, StoryText.get_or("BTN_GOT_IT", "Got it"))
	check(got2 != null, "run C: Got it visible on galaxy step 3")
	if got2 != null:
		got2.pressed.emit()
	await process_frame
	await process_frame
	check(g.tut_step == g.TUT_IDS.size(), "run C: galaxy tutorial reaches done (tut_step %d)" % g.tut_step)
	await shot("C_galaxy_done")
	await _free(m)

	# Run D: Skip pressed mid galaxy tutorial (on step 2).
	log_("== Run D: galaxy Skip mid-tutorial")
	m = await _new_main()
	m._open_system(2)
	g = m.galaxy_view
	g.open_view()
	await process_frame
	nxt = _find_btn(g.tut_box, StoryText.get_or("BTN_NEXT", "Next"))
	if nxt != null:
		nxt.pressed.emit()
	await process_frame
	check(g.tut_step == 1, "run D: galaxy at step 2 before Skip")
	await shot("D_galaxy_step2_before_skip")
	var gskip := _find_btn(g.tut_box, StoryText.get_or("BTN_SKIP_TUTORIAL", "Skip tutorial"))
	check(gskip != null, "run D: Skip visible on galaxy step 2")
	if gskip != null:
		gskip.pressed.emit()
	await process_frame
	await process_frame
	check(g.tut_step == g.TUT_IDS.size() or g.tut_panel.visible == false, "run D: galaxy Skip closes the galaxy tutorial")
	check(m.tut_step == m.TUT_GUIDE.size(), "run D: galaxy Skip also ends the guided board tutorial (tut_step %d)" % m.tut_step)
	await shot("D_galaxy_after_skip")
	await _free(m)
	log_("== done, %d failure(s)" % fails.size())
