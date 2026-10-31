extends Control
## T03: cycle timer + top bar. Values come from data/balance.json at runtime.

signal cycle_ended(cycle: int)
## T07: emitted at every cycle end after routes paid. results: Array of
## {id, a, b, ships, net, paid, status}; total: credits paid by all routes.
signal routes_settled(results: Array, total: int)
## T56: a route just became blocked (destination storage full or planet closed).
signal route_blocked(id: int, text: String)
signal notice_posted(text: String)
## T77: the single place T78 listens to. side is "RELEASE", "CORP" or "LOSS"; ending_id is the END_* id.
signal run_ended(side: String, ending_id: String)

const BALANCE_PATH := "res://data/balance.json"
const SaveGame := preload("res://game/save_game.gd")
const Trade := preload("res://game/trade.gd")
const RouteEngine := preload("res://game/route_engine.gd")
const Storage := preload("res://game/storage.gd")
const StoryText := preload("res://game/story_text.gd")
const EndingPicker := preload("res://game/ending_picker.gd")
const SkillTree := preload("res://game/skill_tree.gd")
const Events := preload("res://game/events.gd")
const Shield := preload("res://game/shield.gd")
const Ships := preload("res://game/ships.gd")
const Systems := preload("res://game/systems.gd")

var balance: Dictionary = {}
var cash: int = 0
var cycle: int = 1          # current cycle, 1-based
var cycle_elapsed: float = 0.0  # seconds into current cycle
var debug_force_goal: bool = false  # T78: debug-only, runtime only, never saved
var debug_force_event: bool = false  # T13: debug-only, fire a random event at the next cycle start, then clears
var run_recorded: bool = false  # T78: a run is recorded once
var time_speed: float = 1.0  # clock multiplier chosen in the top bar (1, 2, 6 or 12); saved, sticky until changed
const SPEEDS := [1.0, 2.0, 6.0, 12.0]
var speed_buttons: Array = []
var paused: bool = true  # T23: game starts paused after the preface
var game_over: bool = false
var choice_pending: bool = false  # T77: win choice shown and not answered yet (saved)
var end_screen: ColorRect  # T77 overlay, null when none
var learned_skills: Array = []  # T77/T71: learned skill ids ("A1"...), saved
var systems_reached: int = 1  # T77: systems with a first route or storage; only system 1 exists today
var skill_points: int = 0  # T82: expansion points earned (top bar label stays "Skill points")
var pts_planets: Array = []  # planet indexes that already gave a point
var pts_pairs: Array = []  # "a-b" (a<b) planet pairs that already gave points
var open_systems: Array = [1]  # T85: system ids opened by a permit (system 1 is always open), saved
var galaxy_seen := false  # T105: galaxy tutorial lines already shown, saved
var galaxy_view: Control  # T105 overlay
var galaxy_button: Button
var skill_arrow: Button  # T128: edge arrow in the 3D view: permit steps, or go to the other system
var view_system := 1  # T128: system the map camera was last put on
var reached_ids: Array = []  # T85: systems past the first that already gave the reach point, saved

## T77/T85: systems in the game (system 1 plus every entry in data/systems.json); Full endings need all reached.
func systems_in_game() -> int:
	return 1 + Systems.ids().size()

var events: RefCounted = Events.new()  # T12 random events and active price effects
var shield: RefCounted = Shield.new()  # T101 solar shield state
const ASTEROID_REWARD_POINTS := 1  # T109: EV20_PAID gives one expansion point (no balance key)
var asteroid_last_hit: int = -1  # T109: planet hit by the last asteroid (-1 none), runtime only
var event_notice: ColorRect  # T12 paused event notification, null when none
var event_feed_label: Label  # T12 this run's events on the board

var skill_screen: PanelContainer  # T71, hidden until opened
var game_menu: PanelContainer  # T71, hidden until opened
var cash_label: Label
var delta_label: Label
var state_label: Label
var cash_box: HBoxContainer  # click target for the cash forecast
var skills_button: Button

var map: Node3D
var planet_panel: PanelContainer
var goal_label: Label
var cycle_label: Label
var pause_button: Button
var progress: ProgressBar
var preface: Control  # T23 preface overlay; null once dismissed
var ships: int = 0  # T28 abstract ship count (all types)
var ship_panel: PanelContainer
var top_bar: PanelContainer
var right_col: VBoxContainer  # holds the notification board and the ship panel
var cash_forecast: PanelContainer  # T40
var mission_label: Label
var tutorial_label: Label  # T15: first 4 cycles hint on the board
var tut_first: Dictionary = {}  # T15: one-time triggers already used this session
## T124 guided first steps: index into TUT_GUIDE; TUT_GUIDE.size() means done. Saved.
const TUT_GUIDE := ["TUT_G1_SELECT", "TUT_G2_BUY", "TUT_G3_SEND", "TUT_G4_SELL", "TUT_G5_SKILLS", "TUT_G6_DONE"]
var tut_step: int = 0
var trade: RefCounted = Trade.new()  # price/margin logic for T07
var commodities: Array = []
var storage: RefCounted = Storage.new()  # T55 planet stock
var engine: RefCounted = RouteEngine.new()  # T07 route records and math
var notice_label: Label
var last_notice: String = ""
var last_summary: String = ""  # T69: gross, upkeep, net of the last cycle
var last_rescue_cycle: int = -1  # T95: at most one rescue per cycle
var last_net: int = 0  # net credits of the last settled cycle (stranded check: a route that pays nothing is not healthy)
var notice_ends_left: int = 0  # cycle ends until the board notice is cleared
var debug_menu: PanelContainer  # T33: null in release builds; T34 adds its button via debug_menu.add_tool()
var selected_planet: int = -1
var pending: Dictionary = {}  # T68: "Send to..." waiting for a destination {planet, c}; empty when none
var pending_label: Label
var last_local: Array = []  # T68: local order results of the last cycle end
var mission_planet: int = -1  # planet that sells the first ship (abundant energy, scarce food)

func _ready() -> void:
	Ui.install_cursors(get_tree())
	balance = _load_balance()
	cash = int(balance.get("starting_credits", 0))
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # let clicks reach the 3D map (T04)
	map = load("res://game/map.gd").new()
	add_child(map)  # T20 map, added before UI so the bar draws on top
	_build_ui()
	planet_panel = load("res://game/planet_panel.gd").new()
	add_child(planet_panel)
	planet_panel.setup(self)
	planet_panel.order_requested.connect(_on_order)
	planet_panel.send_requested.connect(_on_send)
	planet_panel.remove_requested.connect(_remove_requested)
	map.planet_clicked.connect(_on_planet_clicked)
	map.route_clicked.connect(_on_route_clicked)
	_build_board()
	_build_pending_label()
	ship_panel = load("res://game/ship_panel.gd").new()
	right_col.add_child(ship_panel)
	planet_panel.buy_ship_requested.connect(_buy_ship)
	ship_panel.buy_requested.connect(_buy_ship_kind)
	mission_planet = _find_mission_planet()
	commodities = _commodities(map.planets)
	trade.setup(balance, map.planets)
	events.setup(balance, map.planets)
	trade.events = events
	shield.setup(balance, map.planets)  # T101
	trade.shield = shield
	engine.shield = shield
	storage.setup(balance, map.planets.size(), commodities)
	engine.setup(balance, trade, commodities, storage)
	engine.learned = learned_skills
	cash_forecast = load("res://game/cash_forecast.gd").new()  # T40: money text dropdown
	add_child(cash_forecast)
	cash_forecast.setup(self, cash_box)
	skill_screen = load("res://game/skill_screen.gd").new()
	add_child(skill_screen)
	skill_screen.setup(self)
	game_menu = load("res://game/game_menu.gd").new()
	add_child(game_menu)
	game_menu.setup(self)
	galaxy_view = load("res://game/galaxy_view.gd").new()  # T105
	add_child(galaxy_view)
	galaxy_view.setup(self)
	galaxy_view.system_chosen.connect(_on_galaxy_system)
	game_menu.skills_requested.connect(open_skills)
	game_menu.main_menu_requested.connect(_to_menu)
	game_menu.quit_requested.connect(func(): save_now(); get_tree().quit())
	var saved := SaveGame.load_state() if SaveGame.continue_requested else {}
	SaveGame.continue_requested = false
	if saved.is_empty():
		_quiet_points = true
		_award_planet(maxi(mission_planet, 0))  # T82: the home planet counts at start
		_quiet_points = false
		_build_preface()
		_tut_show(["TUT_C1_PLANET"])
	else:
		apply_state(saved)  # T26: resume paused, no preface
		post_notice(StoryText.get_text("NOT_LOADED"))
		_tut_cycle()
	if debug_tools_allowed():  # T33: debug menu is never created in release exports
		debug_menu = load("res://game/debug_menu.gd").new()
		add_child(debug_menu)
		debug_menu.setup(self)
		debug_menu.add_next_cycle_button()
		debug_menu.add_routes_dump()
		debug_menu.add_force_goal()
		debug_menu.add_event_trigger()
		debug_menu.add_qa_tools()  # T13
	_push_routes_to_map()
	_refresh()

## T26: state written to the autosave. Add new keys here (see save_game.gd).
## Tuning values from balance.json are never saved.
func collect_state() -> Dictionary:
	return {"cycle": cycle, "cycle_elapsed": cycle_elapsed, "cash": cash, "paused": paused, "ships": ships,
		"routes": engine.to_array(), "storage": storage.to_dict(), "orders": engine.local_to_array(),
		"choice_pending": choice_pending, "learned_skills": learned_skills, "systems_reached": systems_reached,
		"time_speed": time_speed, "skill_points": skill_points, "pts_planets": pts_planets, "pts_pairs": pts_pairs, "events": events.to_dict(),
			"open_systems": open_systems, "reached_ids": reached_ids, "galaxy_seen": galaxy_seen, "tut_step": tut_step,
		"shield": shield.to_dict(), "storage_cuts": storage.cuts_to_dict(), "price_history": price_history}

func apply_state(s: Dictionary) -> void:
	shield.from_dict(s.get("shield"))  # T101: old saves: no shield
	storage.cuts_from_dict(s.get("storage_cuts"))  # T109: old saves: no cuts
	for sid in _int_array(s.get("open_systems")):  # T85: permitted systems first, so planet indexes exist for routes
		if sid > 1 and Systems.ids().has(sid):
			_open_system(sid)
	reached_ids = _int_array(s.get("reached_ids"))
	galaxy_seen = bool(s.get("galaxy_seen", false))
	tut_step = int(s.get("tut_step", TUT_GUIDE.size()))  # old saves: guided steps skipped (already past cycle 1)
	cycle = maxi(1, int(s.get("cycle", 1)))
	cycle_elapsed = clampf(float(s.get("cycle_elapsed", 0.0)), 0.0, _cycle_seconds())
	time_speed = _speed_or_default(s.get("time_speed", 1.0))  # old saves: x1
	cash = int(s.get("cash", cash))
	ships = clampi(int(s.get("ships", 0)), 0, int(balance.get("ship_cap", 0)))
	engine.from_array(s.get("routes", []), ships)  # old saves: no key = zero routes
	storage.from_dict(s.get("storage"), map.planets.size())  # old saves: fresh stock
	engine.local_from_array(s.get("orders"))  # old saves: no local orders
	# T51: old saves may hold cargo, ship_planet, dest, flight_left, mission_step; ignored.
	learned_skills = []
	if typeof(s.get("learned_skills")) == TYPE_ARRAY:
		for id in s["learned_skills"]:
			if SkillTree.all_ids().has(str(id)) and not learned_skills.has(str(id)):
				learned_skills.append(str(id))
	# Saves without a skills key start with none: Space Storage must be earned via skill A1.
	engine.learned = learned_skills
	_sync_skill_effects()
	price_history = s.get("price_history", {}) if typeof(s.get("price_history")) == TYPE_DICTIONARY else {}
	_ensure_posts()
	systems_reached = maxi(1, int(s.get("systems_reached", 1)))
	skill_points = maxi(0, int(s.get("skill_points", 0)))
	pts_planets = _int_array(s.get("pts_planets"))
	pts_pairs = s.get("pts_pairs", []) if typeof(s.get("pts_pairs")) == TYPE_ARRAY else []
	if not s.has("pts_planets"):  # old save: award what the existing orders and routes would have given
		_quiet_points = true
		_award_planet(maxi(mission_planet, 0))
		for o in engine.local.values():
			_award_planet(int(o["planet"]))
		for r in engine.routes:
			_award_route(int(r["a"]), int(r["b"]))
		_quiet_points = false
	events.from_dict(s.get("events"))  # old saves: no events
	_sync_closed()
	_refresh_event_feed()
	paused = true  # always resume paused
	if events.pending_id != "":  # T12: an unconfirmed event notice comes back (effects already applied unless a choice)
		_open_event_notice(events.pending_id)
	if bool(s.get("choice_pending", false)):  # T77: an unanswered choice comes back
		_show_choice()

func _int_array(v) -> Array:
	var out: Array = []
	if typeof(v) == TYPE_ARRAY:
		for x in v:
			out.append(int(x))
	return out

## T82: expansion points, each source once. Keys skill_points_planet / _route / _system.
var _pending_pts := 0  # points earned since the last pop-up (T126)
var skill_point_pop: Control  # T126 pop-up, created on first use

func _add_points(n: int) -> void:
	skill_points += n
	_pending_pts += n
	if skill_screen != null and skill_screen.visible:
		skill_screen.refresh()

var _quiet_points := false  # no notice while the start state or an old save is being built

func _point_notice(reason: String) -> void:
	var earned := _pending_pts
	_pending_pts = 0
	if _quiet_points:
		return
	post_notice(StoryText.get_text("NOT_SKILL_POINT", {"reason": reason}))
	if earned > 0:
		_show_point_pop(earned, reason)

## T126: the visible pop-up, drawn over the top of the screen; never blocks play.
func _show_point_pop(earned: int, reason: String) -> void:
	if skill_point_pop == null:
		skill_point_pop = load("res://game/skill_point_pop.gd").new()
		add_child(skill_point_pop)
	skill_point_pop.show_points(earned, reason, StoryText.get_text("NOT_SKILL_POP_TITLE", {"points": earned}))

func _award_planet(p: int) -> void:
	if p < 0 or pts_planets.has(p):
		return
	pts_planets.append(p)
	_add_points(int(balance.get("skill_points_planet", 0)))
	_point_notice(StoryText.get_text("NOT_SKILL_REASON_PLANET", {"planet": planet_name(p)}))

func _award_route(a: int, b: int) -> void:
	_award_planet(a)
	_award_planet(b)
	var k := "%d-%d" % [mini(a, b), maxi(a, b)]
	if pts_pairs.has(k):
		return
	pts_pairs.append(k)
	_add_points(int(balance.get("skill_points_route", 0)))
	_point_notice(StoryText.get_text("NOT_SKILL_REASON_ROUTE", {"planet_a": planet_name(a), "planet_b": planet_name(b)}))

## T82: call when a first route or storage opens in a new system (system 1 gives none). Not used until system 2 exists.
func reach_system() -> void:
	systems_reached += 1
	_add_points(int(balance.get("skill_points_system", 0)))
	_point_notice(StoryText.get_text("NOT_SKILL_REASON_SYSTEM"))

## ---- T85 systems, permits, Space Storage ----

func system_of(planet: int) -> int:
	return int(map.planets[planet].get("system", 1)) if planet >= 0 and planet < map.planets.size() else 1

## Appends the planets of a system to the live map (no-op for system 1 or planets already present).
func _open_system(id: int) -> bool:
	if id == 1:
		return false
	if not open_systems.has(id):
		open_systems.append(id)
	var added := false
	if not _system_planets_present(id):
		map.add_planets(Systems.planets_of(id).filter(func(p): return Shield.habitable(p)))  # T101: habitable flag
		added = true
	_ensure_posts()
	return added

func _system_planets_present(id: int) -> bool:
	for p in map.planets:
		if int(p.get("system", 1)) == id:
			return true
	return false

## Space Storage post: one per open system, exists once skill A1 is learned (the A1 gate itself is unchanged).
func _ensure_posts() -> void:
	if not has_skill("A1"):
		return
	for sid in open_systems:
		storage.ensure(Storage.system_key(int(sid)))

func space_post_open(system_id: int) -> bool:
	return has_skill("A1") and storage.established(Storage.system_key(system_id))

## Systems with a permit entry that is not bought yet.
func unowned_systems() -> Array:
	var out := []
	for sid in Systems.ids():
		if not open_systems.has(sid):
			out.append(sid)
	return out

## Credit price of a permit: the data price, less skill C4 Colonial Rights (balance skill_C4_permit_discount).
func permit_cost(sid: int) -> int:
	var c := Systems.permit_cost(balance, sid)
	if has_skill("C4"):
		c = floori(float(c) * (1.0 - float(balance.get("skill_C4_permit_discount", 0.0))))
	return c

## {ok, reason}; reason is "", "owned", "skill", "credits", "points", "over" or "unknown".
func can_buy_permit(sid: int) -> Dictionary:
	if not Systems.ids().has(sid):
		return {"ok": false, "reason": "unknown"}
	if game_over:
		return {"ok": false, "reason": "over"}
	if open_systems.has(sid):
		return {"ok": false, "reason": "owned"}
	if not has_skill(str(Systems.get_system(sid).get("requires_skill", "C1"))):
		return {"ok": false, "reason": "skill"}
	if cash < permit_cost(sid):
		return {"ok": false, "reason": "credits"}
	if skill_points < Systems.permit_points(balance, sid):
		return {"ok": false, "reason": "points"}
	return {"ok": true, "reason": ""}

## Buys the permit: credits and expansion points, then the system's planets appear on the map.
func buy_permit(sid: int) -> Dictionary:
	var v := can_buy_permit(sid)
	if not v["ok"]:
		return v
	cash -= permit_cost(sid)
	skill_points -= Systems.permit_points(balance, sid)
	_open_system(sid)
	post_notice(StoryText.get_text(str(Systems.get_system(sid).get("permit_notice_id", "NOT_PERMIT_S2"))))
	if skill_screen != null:
		skill_screen.refresh()
	_after_change()
	return v

## First order or route that touches a planet of a new system gives the system point (once per system).
func _note_system(planet: int) -> void:
	var sid := system_of(planet)
	if sid > 1 and not reached_ids.has(sid):
		reached_ids.append(sid)
		reach_system()

## Owner decision 2026-10-28: A1 needs every system 1 planet visited (pts_planets) and one route made (pts_pairs).
func a1_gate_open() -> bool:
	var n := mini(3, map.planets.size())
	for i in n:
		if not pts_planets.has(i):
			return false
	return not pts_pairs.is_empty()

func skill_ctx() -> Dictionary:
	return {"a1_open": a1_gate_open()}

## T71: learn a skill. Spends skill points, saves, posts the notice. Returns {ok, reason}.
func learn_skill(id: String) -> Dictionary:
	var v := SkillTree.can_learn(learned_skills, skill_points, balance, id, skill_ctx())
	if not v["ok"]:
		return v
	skill_points -= SkillTree.cost(balance, id)
	learned_skills.append(id)
	_sync_skill_effects()
	_sync_closed()
	_ensure_posts()
	post_notice(StoryText.get_text("NOT_SKILL_LEARNED", {"skill": SkillTree.skill_name(id)}))
	if skill_screen != null:
		skill_screen.refresh()
	_after_change()
	return v

## T71: effect hook. Systems ask main.has_skill("A4") etc.; effect numbers stay in balance.json.
func has_skill(id: String) -> bool:
	return learned_skills.has(id)

## Skill effects that live on other objects: A2 Deep Holds raises planet storage capacity.
func _sync_skill_effects() -> void:
	storage.capacity_mult = 1.0 + float(balance.get("skill_A2_capacity", 0.0)) if has_skill("A2") else 1.0

## B1 Market Ledger: the last few sell prices of a planet's commodity, newest last. Kept at each cycle end.
const PRICE_HISTORY_LEN := 5
var price_history: Dictionary = {}  # "<planet>|<commodity>" -> Array of ints (runtime, saved)

func _record_prices() -> void:
	for i in trade.planets.size():
		for c in commodities:
			var p: int = trade.price(i, str(c) + "_sell")
			if p < 0:
				continue
			var k := "%d|%s" % [i, str(c)]
			var arr: Array = price_history.get(k, [])
			arr.append(p)
			while arr.size() > PRICE_HISTORY_LEN:
				arr.pop_front()
			price_history[k] = arr

func price_history_line(planet: int, c: String) -> String:
	var arr: Array = price_history.get("%d|%s" % [planet, c], [])
	if arr.is_empty():
		return StoryText.get_text("LBL_PRICE_HISTORY_NONE")
	var parts := []
	for v in arr:
		parts.append(str(v))
	return StoryText.get_text("LBL_PRICE_HISTORY", {"prices": ", ".join(parts)})

func open_skills() -> void:
	if preface != null or game_over:
		return
	skill_screen.open_screen()

## T105: click on a system in the galaxy view: close the view and put the map camera on that system.
func _on_galaxy_system(id: int) -> void:
	galaxy_view.close_view()
	view_system = id
	map.focus_system(id)

func toggle_galaxy() -> void:
	if preface != null or game_over:
		return
	galaxy_view.toggle_view()

## T128: what the edge arrow does now. {} = hidden; {"mode": "skills", "steps": [...]} = open Skills with those steps lit;
## {"mode": "view", "system": id} = move the camera to the other open system.
func skill_arrow_target() -> Dictionary:
	if preface != null or game_over:
		return {}
	var open := unowned_systems()
	if not open.is_empty():
		var req := str(Systems.get_system(int(open[0])).get("requires_skill", "C1"))
		if has_skill(req):
			return {"mode": "skills", "steps": []}
		if SkillTree.state(learned_skills, req, skill_ctx()) == "available":
			var steps := []
			_missing_chain(req, steps)
			return {"mode": "skills", "steps": steps}
	if open_systems.size() > 1:
		var i := open_systems.find(view_system)
		return {"mode": "view", "system": int(open_systems[(i + 1) % open_systems.size()])}
	return {}

func _missing_chain(id: String, out: Array) -> void:
	for p in SkillTree.missing_prereqs(learned_skills, id):
		_missing_chain(p, out)
	if not learned_skills.has(id) and not out.has(id):
		out.append(id)

func _on_skill_arrow() -> void:
	var t := skill_arrow_target()
	if t.is_empty():
		return
	if str(t["mode"]) == "skills":
		if preface == null and not game_over:
			skill_screen.open_highlight(t["steps"])
	else:
		view_system = int(t["system"])
		map.focus_system(view_system)
		_refresh()

func toggle_skills() -> void:
	if skill_screen.visible:
		skill_screen.close_screen()
	else:
		open_skills()

func save_now() -> void:
	if preface != null or (game_over and not choice_pending):
		return
	SaveGame.write_state(collect_state())

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_now()

func _to_menu() -> void:
	save_now()
	get_tree().change_scene_to_file("res://game/main_menu.tscn")

func _on_planet_clicked(index: int) -> void:
	if not pending.is_empty():
		if index < 0 or index >= map.planets.size():
			cancel_pending()
		elif index == int(pending["planet"]):
			post_notice("Pick a different planet as the destination.")
			return
		else:
			var r := send_stock(int(pending["planet"]), index, str(pending["c"]))
			if not r["ok"]:
				post_notice(str(r["reason"]))  # pending stays so the player can pick another planet
				return
			var cnt: int = engine.lane_count(int(pending["planet"]), index, str(r["c"]))
			var pending_planet: int = int(pending["planet"])
			cancel_pending()
			post_notice(StoryText.get_text("NOT_ROUTE_MADE", {"planet_a": planet_name(int(pending_planet)), "planet_b": planet_name(index)}) if cnt <= 1 else StoryText.get_text("NOT_LANE_SHIP_ADDED"))
			selected_planet = index
			planet_panel.show_planet(index)
			return
	if index < 0 or index >= map.planets.size():
		selected_planet = -1
		planet_panel.visible = false
		return
	selected_planet = index
	planet_panel.show_planet(index)
	_tut_once("row", ["TUT_C1_ROW"])

## T65: clicking a route line selects that connection in the panel (with Remove).
func _on_route_clicked(id: int) -> void:
	var i: int = engine.find_by_id(id)
	if i < 0:
		return
	selected_planet = int(engine.routes[i]["a"])
	planet_panel.show_planet(selected_planet, id)

## T28: first planet with abundant energy and scarce food, or -1.
func _find_mission_planet() -> int:
	for i in map.planets.size():
		var p = map.planets[i]
		if typeof(p) == TYPE_DICTIONARY and p.get("abundant") == "energy" and p.get("scarce") == "food":
			return i
	return -1

## Rebuilds the planet panel (rows, connections, ship button) for the selected planet.
func _refresh_panel() -> void:
	_tut_advance()  # T124: selecting a planet is a guided step
	if selected_planet >= 0:
		planet_panel.rebuild()

## T68: Buy / Sell toggled on a resource row of the selected planet (standing local order, no ship).
func _on_order(c: String, role: String) -> void:
	if selected_planet < 0 or game_over:
		return
	var r := toggle_local(selected_planet, c, role)
	if not r["ok"]:
		post_notice(str(r["reason"]))

## T68: "Send to..." pressed on a storage row: the next planet clicked becomes the destination.
func _on_send(c: String) -> void:
	if selected_planet < 0 or game_over:
		return
	if not pending.is_empty() and pending["planet"] == selected_planet and pending["c"] == c:
		cancel_pending()
		return
	pending = {"planet": selected_planet, "c": c}
	_pending_changed()

func cancel_pending() -> void:
	pending = {}
	_pending_changed()

func _pending_changed() -> void:
	map.set_pending(int(pending["planet"]) if not pending.is_empty() else -1)
	if pending_label != null:
		pending_label.visible = not pending.is_empty()
		if not pending.is_empty():
			pending_label.text = "Send %s from %s: click the destination planet. (Esc to cancel)" % [
				pending["c"], planet_name(int(pending["planet"]))]
	_refresh_panel()

func _build_pending_label() -> void:
	pending_label = Label.new()
	pending_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	pending_label.position.y = 64
	pending_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	pending_label.theme_type_variation = "LabelAccent"
	pending_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pending_label.visible = false
	add_child(pending_label)

func _remove_requested(id: int) -> void:
	var i: int = engine.find_by_id(id)
	var a := ""
	var b := ""
	if i >= 0:
		a = planet_name(int(engine.routes[i]["a"]))
		b = planet_name(int(engine.routes[i]["b"]))
	var r := remove_connection(id)
	if r["ok"]:
		post_notice(StoryText.get_text("NOT_ROUTE_REMOVED", {"planet_a": a, "planet_b": b}))

func _buy_ship() -> void:
	_buy_ship_kind("small")

func _buy_ship_kind(kind: String) -> void:
	var r := buy_ship(kind)
	post_notice(StoryText.get_text("NOT_SHIP_BOUGHT") if r["ok"] else str(r["reason"]))

## ---- T07 engine API (UI and bots). Ships are owned (ships) and either free or assigned. ----

func free_ships() -> int:
	return ships - engine.total_assigned()

## T58: owned and free ships of one type (only "small" remains).
func owned_of(kind: String) -> int:
	return ships if kind == "small" else 0

func free_of(kind: String) -> int:
	return owned_of(kind) - engine.assigned_of(kind)

## Buys one free ship of a type (default small, at ship_price). Returns {ok, reason}.
func buy_ship(kind: String = "small") -> Dictionary:
	var r := can_buy_ship(kind)
	if not r["ok"]:
		return r
	cash -= Ships.price(kind, balance)
	ships += 1
	_after_change()
	return r

func can_buy_ship(kind: String = "small") -> Dictionary:
	if game_over:
		return {"ok": false, "reason": "The game is over."}
	if ships >= int(balance.get("ship_cap", 0)):
		return {"ok": false, "reason": "Ship cap reached."}
	if cash < Ships.price(kind, balance):
		return {"ok": false, "reason": "Not enough cash for a ship."}
	return {"ok": true, "reason": ""}

## T58: auto-assignment. One ship type remains (small).
func pick_ship(_src: int, _dst: int, _c: String) -> String:
	return "small"

## ---- T56 one-way route API (T57 UI and bots). One ship per route, auto-assigned from the free pool. ----

## Setup check for a connection src -> dst carrying c. One reason when refused.
func can_connect(src: int, dst: int, c: String) -> Dictionary:
	if game_over:
		return {"ok": false, "reason": "The game is over."}
	var r: Dictionary = engine.check_connection(src, dst, c)
	if not r["ok"]:
		return r
	if free_ships() <= 0:
		return {"ok": false, "reason": StoryText.get_text("NOT_SHIP_FREE")}
	return {"ok": true, "reason": ""}

## One-way route that moves commodity c from the storage at `src` to the storage at `dst` (one auto-assigned ship).
## Returns {ok, reason, id, c}.
func send_stock(src: int, dst: int, c: String) -> Dictionary:
	var r := _connect(src, dst, c)
	r["c"] = c
	return r

## T68: standing local order at a planet (no ship). role "buy" or "sell". Returns {ok, reason}.
func set_local_order(planet: int, c: String, role: String, on: bool) -> Dictionary:
	if game_over:
		return {"ok": false, "reason": "The game is over."}
	var r: Dictionary = engine.set_local(planet, c, role, on)
	if r["ok"]:
		if on:
			_tut_once("order_" + role, ["TUT_C1_BUY" if role == "buy" else "TUT_C1_SELL"])
			_award_planet(planet)
			_note_system(planet)
		_after_change()
	return r

func toggle_local(planet: int, c: String, role: String) -> Dictionary:
	return set_local_order(planet, c, role, not engine.local_on(planet, c, role))

func _connect(src: int, dst: int, c: String) -> Dictionary:
	var r := can_connect(src, dst, c)
	if not r["ok"]:
		return r
	var rec: Dictionary = engine.new_record(src, dst, c)
	rec["id"] = engine.next_id
	rec["ship"] = pick_ship(src, dst, c)  # T58
	engine.next_id += 1
	rec["fresh"] = clampf(1.0 - cycle_elapsed / _cycle_seconds(), 0.0, 1.0)
	engine.routes.append(rec)
	_award_route(src, dst)
	_note_system(src)
	_note_system(dst)
	storage.ensure(str(rec["src"]))  # T65: first order at a planet establishes its company storage
	storage.ensure(str(rec["dst"]))
	_tut_once("route", ["TUT_C2_ROUTE_DONE"])
	_after_change()
	return {"ok": true, "reason": "", "id": rec["id"]}

## Removes the connection; its ship becomes free.
func remove_connection(id: int) -> Dictionary:
	var i: int = engine.find_by_id(id)
	if i < 0:
		return {"ok": false, "reason": "No such route."}
	engine.routes.remove_at(i)
	_after_change()
	return {"ok": true, "reason": ""}

## Copy of one route: record fields plus status (running | stalled | blocked), reason, net (projected per cycle),
## role ("buy" if `planet` is the source, "sell" if the destination, "" without a planet argument).
func _view(rec: Dictionary, planet: int = -1) -> Dictionary:
	var d: Dictionary = rec.duplicate(true)
	d["status"] = engine.status_of(rec)
	d["reason"] = engine.reason_of(rec)
	d["net"] = engine.payout_of(rec)
	d["role"] = "buy" if rec["a"] == planet else ("sell" if rec["b"] == planet else "")
	return d

## Connections that touch a planet (as buy or sell side), optionally for one commodity.
func connections_at(planet: int, c: String = "") -> Array:
	var out: Array = []
	for rec in engine.routes:
		if (rec["a"] == planet or rec["b"] == planet) and (c == "" or rec["c"] == c):
			out.append(_view(rec, planet))
	return out

func get_routes() -> Array:
	var out: Array = []
	for rec in engine.routes:
		out.append(_view(rec))
	return out

func route_net(id: int) -> int:
	var i: int = engine.find_by_id(id)
	return engine.payout_of(engine.routes[i]) if i >= 0 else 0

func planet_name(i: int) -> String:
	if i < 0 or i >= map.planets.size():
		return "?"
	return str(map.planets[i].get("name", map.planets[i].get("id", "?")))

## T07b: tell the map which route lines to draw (cheap: restyles existing lines, adds/removes changed ones).
func _push_routes_to_map() -> void:
	var list: Array = []
	var lanes := {}  # T87: one line per lane; ships = ships on it, status = running if any ship runs
	for rec in engine.routes:
		var k := "%d|%d|%s" % [rec["a"], rec["b"], rec["c"]]
		var st: String = engine.status_of(rec)
		if lanes.has(k):
			var e: Dictionary = lanes[k]
			e["ships"] = int(e["ships"]) + 1
			if st == "running":
				e["status"] = st
			continue
		var e2 := {"id": rec["id"], "a": rec["a"], "b": rec["b"], "ships": 1, "status": st}
		lanes[k] = e2
		list.append(e2)
	map.set_routes(list)

func _after_change() -> void:
	_push_routes_to_map()
	_tut_advance()
	_refresh()
	_refresh_panel()
	save_now()

const NOTICE_QUEUE_MAX := 6
var notice_queue: Array = []  # texts waiting behind the one on screen
var shown_notice: String = ""  # text on the notice line now ("" when none)

## Shows one notice at a time. While one is up (it lives one cycle), later ones wait in a short queue.
func post_notice(text: String) -> void:
	last_notice = text  # the most recent post
	if shown_notice != "":
		if text != shown_notice and not notice_queue.has(text):
			notice_queue.append(text)
			if notice_queue.size() > NOTICE_QUEUE_MAX:
				notice_queue.pop_front()
	else:
		_show_notice(text)
	notice_posted.emit(text)

func _show_notice(text: String) -> void:
	shown_notice = text
	notice_ends_left = 1  # advances at the next cycle end
	if notice_label != null:
		notice_label.text = text
		notice_label.visible = true

func _advance_notice() -> void:
	if shown_notice == "":
		return
	if not notice_queue.is_empty():
		_show_notice(str(notice_queue.pop_front()))
		return
	shown_notice = ""
	last_notice = ""
	notice_ends_left = 0
	if notice_label != null:
		notice_label.text = ""
		notice_label.visible = false

## Settles every route once (called from _end_cycle). Returns the results array.
func _settle_routes() -> Array:
	var r: Dictionary = engine.settle(cash)
	last_local = r["local"]
	cash += int(r["delta"])
	last_net = int(r["delta"])
	last_summary = "%s %d, %s %d, %s %+d" % [StoryText.get_text("LBL_GROSS"), int(r["gross"]),
		StoryText.get_text("LBL_SHIP_UPKEEP"), int(r["upkeep"]), StoryText.get_text("LBL_NET"), int(r["delta"])]
	for rec in r["newly_blocked"]:
		var text := _blocked_text(rec)
		post_notice(text)
		route_blocked.emit(int(rec["id"]), text)
	for rec in r["newly_stalled"]:
		post_notice(StoryText.get_text("NOT_ROUTE_STALLED", {"commodity": str(rec["c"]), "planet": planet_name(int(rec["a"]))}))
	routes_settled.emit(r["results"], int(r["delta"]))
	return r["results"]

## Story text for a route that just became blocked: closed planet, else full destination storage.
func _blocked_text(rec: Dictionary) -> String:
	for p in [rec["a"], rec["b"]]:
		if engine.closed_planets.has(int(p)):
			return StoryText.get_text("NOT_ROUTE_BLOCKED_CLOSED", {"planet": planet_name(int(p))})
	return StoryText.get_text("NOT_ROUTE_BLOCKED_FULL", {"planet": planet_name(int(rec["b"]))})

## T46 / T95: stranded = (no ships and cash below ship_price) OR (cash below one route's fixed cost,
## no net income last cycle or no route running, and no local Sell order with stock). Pays rescue_stipend, once per cycle, never a loss.
func _check_stranded() -> void:
	if last_rescue_cycle == cycle:
		return
	var stuck := ships == 0 and cash < int(balance.get("ship_price", 0))
	if not stuck and cash < engine.fixed_cost() and (last_net <= 0 or not _any_route_running()) and not _any_sellable():
		stuck = true
	if stuck:
		last_rescue_cycle = cycle
		var amount := int(balance.get("rescue_stipend", 0))
		cash += amount
		post_notice(StoryText.get_text("NOT_DEAD_RESCUE", {"amount": amount}))

func _any_route_running() -> bool:
	for rec in engine.routes:
		if str(rec["state"]) == "running":
			return true
	return false

## True when an enabled local Sell order has stock in its storage.
func _any_sellable() -> bool:
	for o in engine.local.values():
		if o["sell"] and storage.amount(storage.planet_key(int(o["planet"])), str(o["c"])) > 0:
			return true
	return false

## T07 HOOK: the offer of an automated route belongs here (GDD: "asks if we want to
## establish an automated trade route"). Nothing calls it since T51 removed the manual
## first-trade mission; T07 decides the trigger.
func _on_trade_mission_complete() -> void:
	pass

## Cycle progress (cycle number plus time within the cycle), unaffected by pausing.
func _progress() -> float:
	return float(cycle - 1) + cycle_elapsed / _cycle_seconds()

## Commodity names found in the planet data (abundant/scarce and *_buy/*_sell keys).
func _commodities(planets: Array) -> Array:
	var out: Array = []
	for p in planets:
		if typeof(p) != TYPE_DICTIONARY:
			continue
		for k in ["abundant", "scarce"]:
			var v = p.get(k)
			if typeof(v) == TYPE_STRING and not ["UNKNOWN", "none", "both"].has(v) and not out.has(v):
				out.append(v)
		var prices = p.get("base_prices")
		if typeof(prices) == TYPE_DICTIONARY:
			for key in prices.keys():
				var s := str(key)
				for suffix in ["_buy", "_sell"]:
					if s.ends_with(suffix):
						var c := s.trim_suffix(suffix)
						if not out.has(c):
							out.append(c)
	return out

func _load_balance()-> Dictionary:
	var f := FileAccess.open(BALANCE_PATH, FileAccess.READ)
	if f == null:
		push_error("Cannot open " + BALANCE_PATH)
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("values"):
		push_error("Bad balance.json")
		return {}
	return parsed["values"]

func _cycle_seconds() -> float:
	return float(balance.get("cycle_minutes", 2)) * 60.0

func _process(delta: float) -> void:
	if paused or game_over:
		return
	cycle_elapsed += delta * time_speed
	var length := _cycle_seconds()
	while cycle_elapsed >= length and not game_over and not paused:
		cycle_elapsed -= length
		_end_cycle()
	_refresh()

## Debug only (no-op in release): jump to the end of the current cycle and run the normal
## _process path once, so end-of-cycle processing happens as on the timer.
## Works while paused. Returns the cycle number after the call.
func debug_advance_cycle() -> int:
	if not OS.is_debug_build() or game_over:
		return cycle
	var was_paused := paused
	paused = false
	cycle_elapsed = _cycle_seconds()
	_process(0.0)
	paused = was_paused or event_notice != null
	return cycle

func _end_cycle() -> void:
	_advance_notice()  # the board notice lives for one cycle, then the next queued one shows
	_settle_routes()
	engine.feed_space()  # T85: planet storage into Space Storage at planet_to_space_rate
	_check_stranded()
	_record_prices()  # B1 Market Ledger history
	_push_routes_to_map()
	_refresh_panel()
	cycle_ended.emit(cycle)
	var win_cash := int(balance.get("win_cash", 0))
	var win_cycle := int(balance.get("win_cycle", 0))
	if OS.is_debug_build() and debug_force_goal:  # T78: QA reaches the choice
		cash = maxi(cash, win_cash)
	if cash >= win_cash:  # T77: pause and ask
		_show_choice()
		save_now()  # keeps the unanswered choice for a reload
		return
	if cycle >= win_cycle:  # T77: window ended without the goal
		_finish("LOSS", "END_LOSS", StoryText.get_text("END_LOSS_STAT", {"cash": cash, "goal": win_cash}))
		return
	events.tick()  # T12: effects that ran this cycle age
	cycle += 1
	_sync_closed()
	if has_skill("B4") and events.due(cycle + 1):  # B4 Event Forecast: one cycle of warning
		post_notice(StoryText.get_text("EVT_NEXT_DUE"))
	if events.due(cycle) or (OS.is_debug_build() and debug_force_event):
		debug_force_event = false
		fire_event(events.random_id(["EV18"] if shield.decided else [], cycle))
	_tut_cycle()
	save_now()

## T77: pause and show the win choice. The cycle stays the cycle the goal was reached in.
func _show_choice() -> void:
	game_over = true
	choice_pending = true
	_open_end_screen().show_choice()
	end_screen.chosen.connect(_on_choice)

func _open_end_screen() -> ColorRect:
	if end_screen != null:
		end_screen.queue_free()
	end_screen = load("res://game/end_screen.gd").new()
	add_child(end_screen)
	end_screen.new_game_pressed.connect(func(): get_tree().reload_current_scene())
	end_screen.menu_pressed.connect(_to_menu)
	end_screen.quit_pressed.connect(func(): get_tree().quit())
	return end_screen

func ending_inputs() -> Dictionary:
	return {"learned": learned_skills, "systems_reached": systems_reached,
		"all_systems_reached": systems_reached >= systems_in_game() and systems_in_game() > 1,
		"last_cycle": cycle >= int(balance.get("win_cycle", 0))}

func _on_choice(side: String) -> void:
	choice_pending = false
	var ending := EndingPicker.pick_release(ending_inputs()) if side == "RELEASE" else EndingPicker.pick_corp(ending_inputs())
	_finish(side, ending, "")

## T77: the run is over. An answered choice is not kept: the save is cleared.
func _finish(side: String, ending_id: String, stat: String) -> void:
	game_over = true
	choice_pending = false
	SaveGame.clear()
	var names := []
	var counts := EndingPicker.counts(learned_skills)
	for b in EndingPicker.BRANCHES:
		if int(counts[b]) > 0:
			names.append(StoryText.get_text("SK_BRANCH_" + b))
	# FALLBACK: story id for "None" is requested from story-designer; used once it exists
	var none_id := "END_STAT" + "_NONE"
	var none_text: String = StoryText.get_text(none_id) if StoryText.has_text(none_id) else "None"
	var branches: String = ", ".join(names) if not names.is_empty() else none_text
	var stats := {"cycle": cycle, "cash": cash, "branches": branches, "systems": systems_reached}
	_open_end_screen().show_ending(ending_id, side, stats, stat)
	if not run_recorded:  # T78: local record, once per run
		run_recorded = true
		var tier := "" if side == "LOSS" else EndingPicker.tier(ending_inputs())
		RunStats.record(side, ending_id, cycle, cash, tier)
	run_ended.emit(side, ending_id)

## ---- T12 events ----

## Closed cycles covered by skills: Space Storage (A1), Deep Holds (A2), Event Forecast (B4).
func _closed_bridge() -> int:
	var n := 0
	for id in ["A1", "A2", "B4"]:
		if has_skill(id):
			n += 1
	return n

func _sync_closed() -> void:
	engine.closed_planets = events.closed_list(_closed_bridge())
	engine.debris_planets = events.debris.duplicate()

## Signed credits, e.g. "+120 cr" or "-80 cr".
func signed_cr(v: int) -> String:
	return "%s%d cr" % ["+" if v >= 0 else "-", absi(v)]

## Plain effect line: NOT_EVENT_EFFECT_UP / _DOWN / _CLOSED / _CASH / _STOCK.
func effect_line(eff: Dictionary) -> String:
	if eff.is_empty():
		return ""
	var pct := roundi(events.pct() * 100.0)
	var args := {"planet": planet_name(int(eff["planet"])), "commodity": str(eff["c"]), "pct": pct,
		"cycles": events.close_cycles() if eff["kind"] == "closed" else events.price_cycles(), "amount": signed_cr(int(eff["amount"])) if eff["kind"] == "cash" else "%+d" % int(eff["amount"])}
	var body := ""
	match str(eff["kind"]):
		"up":
			body = StoryText.get_text("NOT_EVENT_EFFECT_UP", args)
		"down":
			body = StoryText.get_text("NOT_EVENT_EFFECT_DOWN", args)
		"closed":
			body = StoryText.get_text("NOT_EVENT_EFFECT_CLOSED", args)
		"cash":
			body = StoryText.get_text("NOT_EVENT_EFFECT_CASH", args)
		"stock":
			body = StoryText.get_text("NOT_EVENT_EFFECT_STOCK", args)
	return "%s: %s" % [StoryText.get_text("NOT_EVENT_PREFIX"), body]

## One-off effects (cash, stock). Timed ones go through events.start_timed.
## Returns a popup override {title_id, id, args} when the outcome decides the popup (asteroid decline), else {}.
func _apply_effect(id: String, eff: Dictionary) -> Dictionary:
	var popup := {}
	match str(eff.get("kind", "")):
		"cash":
			cash += int(eff["amount"])
		"debris_pay":
			cash -= events.debris_fee()
			events.debris.erase(events.pending_planet)
		"debris_leave":
			if not events.debris.has(events.pending_planet):
				events.debris.append(events.pending_planet)
		"shield_build":  # T101: planets in the game now stay as they are
			cash -= shield.cost()
			shield.build(map.planets)
		"shield_skip":
			shield.skip()
		"asteroid_pay":  # T109: payment to the state; the point is an event reward, not bought
			cash -= events.asteroid_cost()
			_add_points(ASTEROID_REWARD_POINTS)
			_pending_pts = 0
			post_notice(StoryText.get_text("EV20_REWARD"))
			_show_point_pop(ASTEROID_REWARD_POINTS, StoryText.get_text("EV20_REWARD"))
		"asteroid_decline":  # T109: seeded roll, bad = storage cut at one established planet, else nothing
			asteroid_last_hit = -1
			if events.asteroid_roll():
				var hit := _pick_storage_planet()
				if hit >= 0:
					asteroid_last_hit = hit
					storage.cut_capacity(Storage.planet_key(hit), float(balance.get("asteroid_storage_loss_pct", 0.0)))
					popup = {"title_id": "EV20_HIT_TITLE", "id": "EV20_HIT_CAPACITY", "args": {"planet": planet_name(hit)}}
		"stock":
			var key: String = storage.planet_key(int(eff["planet"]))
			if int(eff["amount"]) >= 0:
				storage.add(key, str(eff["c"]), int(eff["amount"]))
			else:
				storage.remove(key, str(eff["c"]), -int(eff["amount"]))
		_:
			events.start_timed(id, eff)
	_sync_closed()
	_push_routes_to_map()
	_refresh()
	_refresh_panel()
	return popup

## T109: the planet whose company storage an asteroid hits (random among established ones), -1 if none.
func _pick_storage_planet() -> int:
	var opts: Array = []
	for i in map.planets.size():
		if storage.established(Storage.planet_key(i)):
			opts.append(i)
	return int(opts[events.rng.randi_range(0, opts.size() - 1)]) if not opts.is_empty() else -1

## Fires an event by id: pauses and shows the notice. Non-choice events apply their effect now.
func fire_event(id: String) -> void:
	if id == "" or not events.by_id.has(id) or game_over or event_notice != null:
		return
	if id == "EV18" and shield.decided:  # T101: offered once
		return
	events.pending_planet = events.pick_debris_planet() if id == "EV17" else -1
	if id == "EV17" and events.pending_planet < 0:
		return
	events.record(id, cycle, events.pending_planet)
	events.pending_id = id
	if events.choices_of(id).is_empty():
		_apply_effect(id, events.effect_of_event(id))
	paused = true
	_refresh_event_feed()
	_open_event_notice(id)
	_refresh()

func _open_event_notice(id: String) -> void:
	if event_notice != null:
		event_notice.queue_free()
	var ev: Dictionary = events.by_id[id]
	var choices: Array = events.choices_of(id)
	var args := {"planet": planet_name(events.pending_planet)} if events.pending_planet >= 0 else {}
	var labels: Array = []
	var off: Array = []
	var effs: Array = []
	for ch in choices:
		var lbl: String = events.choice_text(ch, args)
		var kind := str(events.choice_effect(ch).get("kind", ""))
		var fee := _choice_fee(kind)
		if fee > 0:
			lbl = "%s (%d)" % [lbl, fee]
		labels.append(lbl)
		off.append(fee > 0 and cash < fee)
		if typeof(ch) == TYPE_DICTIONARY and ch.has("eff_id"):
			effs.append(StoryText.get_text(str(ch["eff_id"]), args))
	var line := effect_line(events.effect_of_event(id)) if choices.is_empty() else "\n".join(effs)
	event_notice = load("res://game/event_notice.gd").new()
	add_child(event_notice)
	event_notice.show_event(events.title_of(id, args), events.body_of(id, args), line, labels, StoryText.get_text("MENU_CONTINUE"), off, "asteroid" if id == "EV20" else "")
	event_notice.confirmed.connect(_on_event_confirmed.bind(id))

## Credits a choice costs (debris fee, shield, asteroid deflection), 0 when free.
func _choice_fee(kind: String) -> int:
	match kind:
		"debris_pay":
			return events.debris_fee()
		"shield_build":
			return shield.cost()
		"asteroid_pay":
			return events.asteroid_cost()
	return 0

## T98: after a debris choice: popup with the outcome text, closed with OK.
func _debris_popup(ch, override: Dictionary = {}) -> void:
	if typeof(ch) != TYPE_DICTIONARY or not ch.has("popup_id"):
		return
	var args := {"planet": planet_name(events.pending_planet)}
	var title_id := str(ch["popup_title_id"])
	var body_id := str(ch["popup_id"])
	if not override.is_empty():  # T109: outcome decided by the roll
		title_id = str(override["title_id"])
		body_id = str(override["id"])
		args = override["args"]
	events.pending_id = ""
	events.pending_planet = -1
	if event_notice != null:
		event_notice.queue_free()
	event_notice = load("res://game/event_notice.gd").new()
	add_child(event_notice)
	event_notice.show_event(StoryText.get_text(title_id, args), StoryText.get_text(body_id, args), "", [], StoryText.get_text("BTN_OK"))
	event_notice.confirmed.connect(func(_c: int):
		event_notice.queue_free()
		event_notice = null
		_refresh()
		save_now())
	save_now()

func _on_event_confirmed(choice: int, id: String) -> void:
	if choice >= 0:
		var choices: Array = events.choices_of(id)
		if choice < choices.size():
			var over := _apply_effect(id, events.choice_effect(choices[choice]))
			_debris_popup(choices[choice], over)
			return
	events.pending_id = ""
	if event_notice != null:
		event_notice.queue_free()
		event_notice = null
	_refresh()
	save_now()

func _refresh_event_feed() -> void:
	if event_feed_label == null:
		return
	var lines: Array = [StoryText.get_text("LBL_EVENT_FEED")]
	var shown := 0
	for i in range(events.feed.size() - 1, -1, -1):
		if shown >= 6:
			break
		lines.append("Cycle %d: %s" % [int(events.feed[i]["cycle"]), events.title_of(str(events.feed[i]["id"]), {"planet": planet_name(int(events.feed[i].get("planet", -1)))})])
		shown += 1
	event_feed_label.text = "\n".join(lines)
	event_feed_label.visible = not events.feed.is_empty()

## Debug only (no-op in release): fire any event by id right now.
func debug_fire_event(id: String) -> void:
	if OS.is_debug_build():
		fire_event(id)

## T13: the debug and game-control menu exists only in debug builds. Release exports pass false.
static func debug_tools_allowed(is_debug: bool = OS.is_debug_build()) -> bool:
	return is_debug

## T13 QA hooks (debug builds only; each is a no-op in release). Runtime only except what the normal autosave keeps.
func debug_set_debris(planet: int, on: bool) -> void:
	if not OS.is_debug_build() or planet < 0 or planet >= map.planets.size():
		return
	if on and not events.debris.has(planet):
		events.debris.append(planet)
	elif not on:
		events.debris.erase(planet)
	_sync_closed()
	_after_change()

## Opens a system's planets without paying cost or points (permit shows as owned).
func debug_grant_permit(sid: int) -> bool:
	if not OS.is_debug_build() or not Systems.ids().has(sid) or open_systems.has(sid):
		return false
	_open_system(sid)
	post_notice(StoryText.get_text(str(Systems.get_system(sid).get("permit_notice_id", "NOT_PERMIT_S2"))))
	if skill_screen != null:
		skill_screen.refresh()
	_after_change()
	return true

## Adds one ship of a kind (respects ship_cap, ignores cash).
func debug_add_ship(kind: String) -> bool:
	if not OS.is_debug_build() or game_over or ships >= int(balance.get("ship_cap", 0)):
		return false
	ships += 1
	_after_change()
	return true

func debug_add_cash(n: int) -> void:
	if OS.is_debug_build():
		cash += n
		_after_change()

func debug_add_points(n: int) -> void:
	if OS.is_debug_build():
		_add_points(n)
		_pending_pts = 0
		_show_point_pop(n, "Debug: points added")
		_after_change()

func debug_set_route_level(id: int, level: int) -> bool:
	var i: int = engine.find_by_id(id)
	if not OS.is_debug_build() or i < 0:
		return false
	engine.routes[i]["level"] = maxi(1, level)
	_after_change()
	return true

## Sets the A1 gate inputs: planets visited and a route made.
func debug_set_a1_gate(open: bool) -> void:
	if not OS.is_debug_build():
		return
	if open:
		for i in mini(3, map.planets.size()):
			if not pts_planets.has(i):
				pts_planets.append(i)
		if pts_pairs.is_empty():
			pts_pairs.append("0-1")
	else:
		pts_planets = []
		pts_pairs = []
	if skill_screen != null:
		skill_screen.refresh()
	_after_change()

func debug_restart_tutorial() -> void:
	if not OS.is_debug_build():
		return
	tut_first = {}
	tut_step = 0
	galaxy_seen = false
	cycle = 1
	cycle_elapsed = 0.0
	_tut_show(["TUT_C1_PLANET"])
	_refresh()

func debug_open_galaxy() -> void:
	if OS.is_debug_build() and galaxy_view != null:
		galaxy_view.visible = true
		galaxy_view.queue_redraw()

## Fresh run: reloads the scene as a new game (the autosave is not read).
func debug_reset_run() -> void:
	if not OS.is_debug_build():
		return
	SaveGame.continue_requested = false
	get_tree().reload_current_scene()

## Player pause toggle (button, Space): posts the paused notice.
## Top bar speed selector: 1x, 2x, 6x, 12x. Sticky: it stays until the player picks another.
func _build_speed_buttons(box: HBoxContainer) -> void:
	var group := ButtonGroup.new()
	for i in SPEEDS.size():
		var b := Button.new()
		b.text = "%dx" % int(SPEEDS[i])
		b.toggle_mode = true
		b.button_group = group
		b.theme_type_variation = "ButtonGhost"
		b.tooltip_text = "Game speed %dx" % int(SPEEDS[i])
		b.custom_minimum_size = Vector2(34, 28)
		b.pressed.connect(set_speed.bind(SPEEDS[i]))
		box.add_child(b)
		speed_buttons.append(b)

func set_speed(value: float) -> void:
	time_speed = _speed_or_default(value)

## Only the four speeds are allowed; anything else (old or bad saves) becomes x1.
func _speed_or_default(value) -> float:
	var v := float(value)
	return v if SPEEDS.has(v) else 1.0

func toggle_pause() -> void:
	set_paused(not paused)
	post_notice(StoryText.get_text("NOT_PAUSED" if paused else "NOT_RESUMED"))

func set_paused(value: bool) -> void:
	paused = value
	_refresh()
	save_now()

func _unhandled_input(event: InputEvent) -> void:
	if preface != null or event_notice != null:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE and not pending.is_empty():
		cancel_pending()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if game_over:
			return
		if galaxy_view.visible:
			galaxy_view.close_view()
		elif skill_screen.visible:
			skill_screen.close_screen()
		elif game_menu.visible:
			game_menu.close_menu()
		else:
			game_menu.open_menu()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_G:
		toggle_galaxy()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_K:
		toggle_skills()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE and not game_menu.visible:
		toggle_pause()

func _build_ui() -> void:
	var bar := PanelContainer.new()
	bar.theme_type_variation = "PanelBar"
	bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	add_child(bar)
	top_bar = bar
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 20)
	bar.add_child(box)
	# left: resource counters (cash with a muted per-cycle delta, expansion points)
	cash_box = HBoxContainer.new()
	cash_box.add_theme_constant_override("separation", 6)
	box.add_child(cash_box)
	cash_box.add_child(_bar_icon("cash"))
	cash_label = Label.new()
	cash_label.theme_type_variation = "LabelNumber"
	cash_box.add_child(cash_label)
	delta_label = Label.new()
	delta_label.theme_type_variation = "LabelNumberMuted"
	cash_box.add_child(delta_label)
	# right: goal, cycle, state, pause (amber). The goal text takes the free space and shortens if the window is narrow.
	goal_label = Label.new()
	goal_label.theme_type_variation = "LabelSmall"
	goal_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	goal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	goal_label.clip_text = true
	goal_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(goal_label)
	cycle_label = Label.new()
	cycle_label.theme_type_variation = "LabelNumber"
	box.add_child(cycle_label)
	progress = ProgressBar.new()
	progress.show_percentage = false
	progress.theme_type_variation = "ProgressBarThin"
	progress.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	progress.custom_minimum_size = Vector2(90, 3)
	progress.max_value = 1.0
	box.add_child(progress)
	state_label = Label.new()
	state_label.theme_type_variation = "LabelCaption"
	box.add_child(state_label)
	_build_speed_buttons(box)
	pause_button = Button.new()
	pause_button.theme_type_variation = "ButtonPrimary"
	pause_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_button.expand_icon = true
	pause_button.custom_minimum_size = Vector2(36, 28)
	pause_button.pressed.connect(toggle_pause)
	box.add_child(pause_button)
	var menu_button := Button.new()
	menu_button.theme_type_variation = "ButtonGhost"
	menu_button.text = StoryText.get_text("MENU_MAIN")
	menu_button.pressed.connect(_to_menu)
	box.add_child(menu_button)
	_build_rail()

func _bar_icon(token: String) -> TextureRect:
	var t := TextureRect.new()
	t.texture = Ui.icon(token)
	t.custom_minimum_size = Vector2(16, 16)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	t.modulate = Ui.col("ink_muted")
	return t

## Narrow glass rail on the left edge: opens the screens the old top-bar buttons opened.
func _build_rail() -> void:
	var rail := PanelContainer.new()
	rail.theme_type_variation = "PanelRail"
	rail.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	rail.offset_left = 10
	add_child(rail)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	rail.add_child(col)
	skills_button = _rail_button("skills", "MENU_SKILLS", "Skills", toggle_skills)
	col.add_child(skills_button)
	galaxy_button = _rail_button("planet", "MENU_GALAXY", "Galaxy", toggle_galaxy)  # T105: shown once system 2 is open
	galaxy_button.visible = false
	col.add_child(galaxy_button)
	skill_arrow = Button.new()  # T128: sits left of the right column, mid-height, clear of the planet ring
	skill_arrow.theme_type_variation = "ButtonRail"
	skill_arrow.icon = Ui.icon("chevron")  # placeholder: the artist makes the real arrow
	skill_arrow.custom_minimum_size = Vector2(44, 44)
	skill_arrow.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	skill_arrow.offset_left = -(12.0 + 240.0 + 16.0 + 8.0 + 44.0)
	skill_arrow.offset_right = -(12.0 + 240.0 + 16.0 + 8.0)
	skill_arrow.offset_top = -22
	skill_arrow.offset_bottom = 22
	skill_arrow.visible = false
	skill_arrow.pressed.connect(_on_skill_arrow)
	add_child(skill_arrow)
	var menu_rail := _rail_button("mark", "MENU_MAIN", "Menu", game_menu_toggle)
	col.add_child(menu_rail)

func game_menu_toggle() -> void:
	if game_menu == null:
		return
	if game_menu.visible:
		game_menu.close_menu()
	else:
		game_menu.open_menu()

func _rail_button(icon_token: String, story_id: String, fallback: String, cb: Callable) -> Button:
	var b := Button.new()
	b.theme_type_variation = "ButtonRail"
	b.icon = Ui.icon(icon_token)
	b.tooltip_text = StoryText.get_or(story_id, fallback)
	b.custom_minimum_size = Vector2(44, 44)
	b.pressed.connect(cb)
	return b

func _refresh() -> void:
	if goal_label == null:
		return
	_tut_advance()
	goal_label.text = StoryText.get_text("LBL_GOAL", {"goal": int(balance.get("win_cash", 0)),
		"cycle": int(balance.get("win_cycle", 0)), "cash": cash})
	cash_label.text = str(cash)
	var net: int = cash_forecast.net_forecast() if cash_forecast != null else 0
	delta_label.text = "%+d" % net
	cycle_label.text = "%d / %d" % [cycle, int(balance.get("win_cycle", 0))]
	cycle_label.tooltip_text = "Cycle"
	if game_over:
		state_label.text = StoryText.get_or("LBL_GAME_OVER", "Game over").to_upper()
	elif paused:
		state_label.text = StoryText.get_or("LBL_PAUSED", "Paused").to_upper()
	else:
		state_label.text = StoryText.get_or("LBL_RUNNING", "Running").to_upper()
	progress.value = cycle_elapsed / _cycle_seconds()
	pause_button.text = ""  # icon only (owner item 1)
	pause_button.tooltip_text = StoryText.get_or("MENU_RESUME", "Resume") if paused else StoryText.get_or("MENU_PAUSE", "Pause")
	pause_button.icon = Ui.icon("play" if paused else "pause")
	for i in speed_buttons.size():
		speed_buttons[i].button_pressed = SPEEDS[i] == time_speed
	var star := " *" if SkillTree.any_affordable(learned_skills, skill_points, balance, skill_ctx()) else ""
	skills_button.tooltip_text = StoryText.get_text("MENU_SKILLS") + star
	skills_button.icon = Ui.icon("skills")
	skills_button.modulate = Ui.col("star_warm") if star != "" else Color.WHITE
	if galaxy_button != null:
		galaxy_button.visible = open_systems.size() > 1
	if skill_arrow != null:
		var at := skill_arrow_target()
		skill_arrow.visible = not at.is_empty()
		if not at.is_empty():
			skill_arrow.tooltip_text = StoryText.get_or("MAP_ARROW_PERMIT" if str(at["mode"]) == "skills" else "MAP_ARROW_SYSTEM",
				"Open Skills" if str(at["mode"]) == "skills" else "Go to the other system")
	if galaxy_view != null:
		galaxy_view.refresh()
	if cash_forecast != null:
		cash_forecast.refresh()  # T40: live while open
	if ship_panel != null:
		ship_panel.set_count(ships, int(balance.get("ship_cap", 0)))
		ship_panel.set_upkeep(self)
		var target: int = mission_planet if ships == 0 else -1  # halo on the planet that sells the first ship
		map.set_hint(target, target >= 0)
		mission_label.visible = ships == 0
		mission_label.text = "Mission: Buy a ship"

## T15: tutorial line(s) on the board, cycles 1 to 4 only. Ids load from the story loader.
func _tut_show(ids: Array) -> void:
	if tutorial_label == null:
		return
	var parts: Array = []
	if tut_step < TUT_GUIDE.size():  # T124: while the guided steps run, their line is the only tutorial line
		ids = [TUT_GUIDE[tut_step]]
	for id in ids:
		parts.append(StoryText.get_or(str(id), "", {}))
	var t := "\n".join(parts).strip_edges()
	tutorial_label.text = t
	tutorial_label.visible = t != "" and (cycle <= 4 or tut_step < TUT_GUIDE.size()) and not game_over

## T124: moves the guided tutorial on when the player has done the current step. Called on every change.
func _tut_advance() -> void:
	var moved := false
	while tut_step < TUT_GUIDE.size() and _tut_step_done(tut_step):
		tut_step += 1
		moved = true
	if moved:
		_tut_show([])

func _tut_step_done(i: int) -> bool:
	match i:
		0:
			return selected_planet >= 0
		1:
			return engine.local.values().any(func(o): return bool(o["buy"]))
		2:
			return not engine.routes.is_empty()
		3:
			return engine.local.values().any(func(o): return bool(o["sell"]))
		4:
			return not learned_skills.is_empty()
	return false

## Shows `ids` the first time `key` fires (cycles 1 to 4).
func _tut_once(key: String, ids: Array) -> void:
	if cycle > 4 or tut_first.has(key):
		return
	tut_first[key] = true
	_tut_show(ids)

## Called at the start of each cycle (and after a load): the line set for that cycle.
func _tut_cycle() -> void:
	match cycle:
		2:
			_tut_show(["TUT_C2_UPKEEP"] if ships > 0 else [])
		3:
			_tut_show(["TUT_C3_STORAGE", "TUT_C3_ONEWAY"])
		4:
			_tut_show((["TUT_C4_SKILLS"] if skill_points > 0 else []) + ["TUT_C4_FREE"])
		_:
			if not tut_first.has("permit") and skill_points > 0 and not has_skill("C1"):  # the way to system 2, once
				tut_first["permit"] = true
				_tut_show(["TUT_PERMIT_C1"])
			else:
				_tut_show([])

## T24: notification board, right side, text only. GDD section 2 'First 4 cycles'.
func _build_board() -> void:
	# Right column: board and ship panel stacked in one scrolling strip that stays inside the window.
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	# 240 px of content plus room for the scrollbar, so the board is never clipped at its right edge.
	scroll.offset_left = -(12.0 + 240.0 + 16.0)
	scroll.offset_right = -12
	scroll.offset_top = 56
	scroll.offset_bottom = -12
	add_child(scroll)
	if top_bar != null:  # start below the top bar, whatever height the theme gives it
		var fit_top := func() -> void:
			scroll.offset_top = top_bar.size.y + 8.0
		top_bar.resized.connect(fit_top)
		fit_top.call_deferred()
	right_col = VBoxContainer.new()
	right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.add_theme_constant_override("separation", 12)
	scroll.add_child(right_col)
	var board := PanelContainer.new()
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.custom_minimum_size = Vector2(240, 0)
	right_col.add_child(board)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	board.add_child(box)
	var title := Label.new()
	title.text = "Notifications"
	title.theme_type_variation = "LabelTitle"
	box.add_child(title)
	mission_label = Label.new()
	mission_label.text = "Mission: Buy a ship"
	mission_label.theme_type_variation = "LabelAccent"
	mission_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(mission_label)
	tutorial_label = Label.new()
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_label.theme_type_variation = "LabelInfo"
	tutorial_label.visible = false
	box.add_child(tutorial_label)
	notice_label = Label.new()
	notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice_label.visible = false
	box.add_child(notice_label)
	event_feed_label = Label.new()
	event_feed_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_feed_label.visible = false
	box.add_child(event_feed_label)

func _build_preface() -> void:
	# Map must not react (camera/picking) while the preface is open.
	map.set_process(false)
	map.set_process_input(false)
	map.set_process_unhandled_input(false)
	var layer := ColorRect.new()
	layer.color = Ui.col("scrim")
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	preface = layer
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(560, 0)
	box.add_theme_constant_override("separation", 20)
	var title := Label.new()
	title.text = StoryText.get_text("SCR_TITLE_NAME")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.theme_type_variation = "LabelHero"
	box.add_child(title)
	var body := Label.new()
	body.text = StoryText.get_text("SCR_PREFACE")
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body)
	var start := Button.new()
	start.theme_type_variation = "ButtonPrimary"
	start.text = StoryText.get_text("SCR_PREFACE_BTN")
	start.pressed.connect(_dismiss_preface)
	box.add_child(start)
	var skip := Button.new()
	skip.theme_type_variation = "ButtonGhost"
	skip.text = StoryText.get_text("SCR_PREFACE_SKIP")
	skip.pressed.connect(_dismiss_preface)
	box.add_child(skip)
	Ui.scroll_wrap(center, box, 48.0)  # long preface text scrolls instead of leaving the window
	start.grab_focus()

func _dismiss_preface() -> void:
	if preface != null:
		preface.queue_free()
		preface = null
	map.set_process(true)
	map.set_process_input(true)
	map.set_process_unhandled_input(true)
	paused = true
	_refresh()
