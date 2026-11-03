extends Control
## T03: cycle timer + top bar. Values come from data/balance.json at runtime.
const Juice := preload("res://game/juice.gd")

signal cycle_ended(cycle: int)
## T07: emitted at every cycle end after routes paid. results: Array of
## {id, a, b, ships, net, paid, status}; total: credits paid by all routes.
signal routes_settled(results: Array, total: int)
## T56: a route just became blocked (destination storage full or planet closed).
signal route_blocked(id: int, text: String)
signal notice_posted(text: String)
var station_systems: Array = []  # ids of systems that have a space station
var station_markers := {}  # system id -> Button
var _loading_state := false
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
const Clusters := preload("res://game/clusters.gd")
const DeadWorlds := preload("res://game/dead_worlds.gd")
const Fabric := preload("res://game/fabric.gd")

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
var _last_points: int = -1  # juice: the points shown last refresh (-1 before the first)
var skill_points: int = 0  # T82: expansion points earned (top bar label stays "Skill points")
var pts_planets: Array = []  # planet indexes that already gave a point
var pts_pairs: Array = []  # "a-b" (a<b) planet pairs that already gave points
var open_systems: Array = [1]  # T85: system ids opened by a permit (system 1 is always open), saved
var galaxy_seen := false  # T105: galaxy tutorial lines already shown, saved
var galaxy_view: Control  # T105 overlay
var galaxy_button: Button
var nav_rail: PanelContainer  # left rail, hidden with the navigation toggle
var nav_keys: Control  # key hints, bottom left, hidden with the navigation toggle
var nav_toggle: Button  # bottom left, always visible
static var nav_hidden: bool = false  # kept for the session (not saved to disk)
var system_exit: Control  # lock icon and fading line to the next locked system
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
var space_storage_view: PanelContainer  # station click, hidden until opened
var game_menu: PanelContainer  # T71, hidden until opened
var cash_label: Label
var delta_label: Label
var cash_box: HBoxContainer  # click target for the cash forecast
var points_button: MarginContainer  # top bar: the skill points figure, opens Skills
var points_hit: Button
var menu_button: Button  # top left, opens the Esc menu
var points_label: Label
var system_label: Label
var system_hint: Label

var map: Node3D
var planet_panel: PanelContainer
var cluster_info: PanelContainer  # T159: info card of the asteroid cluster clicked on the map
var cluster_info_index: int = -1
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
var tut_actions: HBoxContainer  # Skip and Next under the guided hint, as in the galaxy view tutorial
var tut_next: Button
var tut_first: Dictionary = {}  # T15: one-time triggers already used this session
## T124 guided first steps: index into TUT_GUIDE; TUT_GUIDE.size() means done. Saved.
const TUT_GUIDE := ["TUT_G1_SELECT", "TUT_G2_BUY", "TUT_G3_SEND", "TUT_G4_SELL", "TUT_G5_SKILLS", "TUT_G6_DONE"]
var tut_step: int = 0
var trade: RefCounted = Trade.new()  # price/margin logic for T07
var commodities: Array = []
var storage: RefCounted = Storage.new()  # T55 planet stock
var engine: RefCounted = RouteEngine.new()  # T07 route records and math
var fabric: RefCounted = Fabric.new()  # the fabric at the trading post, saved under "fabric"
var dead: RefCounted = DeadWorlds.new()  # dead worlds: danger meter per planet id, saved under "danger"
var clusters: RefCounted = Clusters.new()  # T156 asteroid clusters (ore sources), saved
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
var sell_offer: Dictionary = {}  # after a Send: {planet, c} while "Sell here too?" is offered at the destination; empty when none
var pending_margins: Label  # P1: per-destination margins while a plain Send to... is pending
var last_local: Array = []  # T68: local order results of the last cycle end
var income_popup: Control  # T133 green +N above planets
var mission_planet: int = -1  # planet that sells the first ship (abundant energy, scarce food)

func _ready() -> void:
	Ui.install_cursors(get_tree())
	Juice.install_press(get_tree())
	balance = _load_balance()
	cash = int(balance.get("starting_credits", 0))
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # let clicks reach the 3D map (T04)
	map = load("res://game/map.gd").new()
	add_child(map)  # T20 map, added before UI so the bar draws on top
	system_exit = load("res://game/system_exit.gd").new()  # lock and fading line to the next, locked system
	add_child(system_exit)
	system_exit.setup(self)
	_build_ui()
	planet_panel = load("res://game/planet_panel.gd").new()
	add_child(planet_panel)
	planet_panel.setup(self)
	planet_panel.order_requested.connect(_on_order)
	planet_panel.salvage_requested.connect(_on_salvage)
	planet_panel.send_requested.connect(_on_send)
	planet_panel.buy_send_requested.connect(_on_buy_send)
	planet_panel.remove_requested.connect(_remove_requested)
	map.planet_clicked.connect(_on_planet_clicked)
	map.route_clicked.connect(_on_route_clicked)
	map.cluster_clicked.connect(_on_cluster_clicked)  # T159
	map.station_clicked.connect(_on_station_clicked)
	_build_board()
	_build_pending_label()
	income_popup = load("res://game/income_popup.gd").new()  # T133
	add_child(income_popup)
	income_popup.setup(map)
	ship_panel = load("res://game/ship_panel.gd").new()
	right_col.add_child(ship_panel)
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
	clusters.setup(balance)  # T156
	dead.setup(balance)
	fabric.setup(balance)
	engine.clusters = clusters
	engine.learned = learned_skills
	engine.trade_gate = Callable(self, "system_trade_open")
	cash_forecast = load("res://game/cash_forecast.gd").new()  # T40: money text dropdown
	add_child(cash_forecast)
	cash_forecast.setup(self, cash_box)
	skill_screen = load("res://game/skill_screen.gd").new()
	add_child(skill_screen)
	skill_screen.setup(self)
	space_storage_view = load("res://game/space_storage_view.gd").new()
	add_child(space_storage_view)
	space_storage_view.setup(self)
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
		"shield": shield.to_dict(), "storage_cuts": storage.cuts_to_dict(), "price_history": price_history,
		"forecast_id": forecast_id, "surveyed": surveyed_systems, "station_systems": station_systems,
		"second_lane": second_lane_planet, "clusters": clusters.to_dict(), "danger": dead.to_dict(), "fabric": fabric.to_dict()}

func apply_state(s: Dictionary) -> void:
	_loading_state = true
	map.clear_stations()
	for m in station_markers.values():
		m.queue_free()
	station_markers.clear()
	station_systems = []
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
	clusters.from_dict(s.get("clusters"))  # T156: before the routes, which may start at a cluster; old saves: all full
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
	forecast_id = str(s.get("forecast_id", ""))
	surveyed_systems = _int_array(s.get("surveyed"))
	second_lane_planet = int(s.get("second_lane", -1))  # N11; old saves: not reached
	if second_lane_planet >= map.planets.size() or (second_lane_planet >= 0 and system_of(second_lane_planet) != SECOND_LANE_SYSTEM):
		second_lane_planet = -1
	for sid in _int_array(s.get("station_systems")):  # saved stations come back without the build-in or notice
		if not station_systems.has(sid) and _system_planets_present(sid):
			station_systems.append(sid)
			map.add_station(sid, false)
			_make_station_marker(sid)
	_ensure_posts()  # old saves with A1: stations for every open system, no notice
	_loading_state = false
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
	events.from_dict(s.get("events"))  # old saves: no events and no scheduled follow-ups
	dead.from_dict(s.get("danger"))  # old saves: no meter
	fabric.from_dict(s.get("fabric"))  # old saves: not built
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
	if b < 0:  # a send to Space Storage is not a planet pair
		return
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
	if Clusters.is_node(planet):  # T156: a cluster node belongs to its system
		return clusters.system_of(Clusters.index_of(planet))
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
		var all_goods := _commodities(map.planets)  # a system can bring a good (nullglass): add it in place, the engine and storage share this array
		for c in all_goods:
			if not commodities.has(c):
				commodities.append(c)
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
	_ensure_stations()

## Space stations: one per open system once A1 is learned; built once, kept in station_systems (saved).
## One notice per build, none while a save loads.
func _ensure_stations() -> void:
	if not has_skill("A1"):
		return
	var built := false
	for sid in open_systems:
		var id := int(sid)
		if station_systems.has(id) or not _system_planets_present(id):
			continue
		station_systems.append(id)
		map.add_station(id, not _loading_state)
		_make_station_marker(id)
		built = true
	if built and not _loading_state:
		post_notice(StoryText.get_or("LBL_STATION_BUILT", "Space station built. Click it to open Space Storage."))

func _make_station_marker(id: int) -> void:
	if station_markers.has(id):
		return
	var b := Button.new()
	b.theme_type_variation = "ButtonSmall"
	b.text = StoryText.get_or("LBL_STATION_MARKER", "Space Storage")
	b.tooltip_text = StoryText.get_or("TIP_STATION_MARKER", "Space Storage")
	b.visible = false
	b.pressed.connect(_on_station_clicked.bind(id))
	add_child(b)
	station_markers[id] = b

func _update_station_markers() -> void:
	for id in station_markers:
		var b: Button = station_markers[id]
		var p = map.station_marker_pos(int(id))
		b.visible = p != null
		if p != null:
			b.position = (p as Vector2) - Vector2(b.size.x * 0.5, b.size.y)

## Click on a station or its marker: opens the Space Storage view of that system (refused with the locked reason without a post).
func _on_station_clicked(sid: int) -> void:
	if not pending.is_empty():  # a plain Send to picks the station as its destination
		var src: int = int(pending["planet"])
		var r := send_stock_buying(src, station_dst(sid), str(pending["c"]))
		if not r["ok"]:
			post_notice_now(str(r["reason"]))  # pending stays so the player can pick another destination
			return
		var wants_buy: bool = bool(pending.get("buy", false))
		cancel_pending()
		if wants_buy and not engine.local_on(src, str(r["c"]), "buy"):
			var bo := set_local_order(src, str(r["c"]), "buy", true)
			if not bo["ok"]:
				post_notice(str(bo["reason"]))
		if bool(r.get("bought", false)):
			post_notice(StoryText.get_text("NOT_SHIP_BOUGHT"))
		post_notice(StoryText.get_text("NOT_ROUTE_MADE", {"planet_a": planet_name(src), "planet_b": StoryText.get_or("LBL_STATION_MARKER", "Space Storage")}))
		return
	if not space_post_open(sid):
		post_notice_now(trade_locked_reason())
		return
	space_storage_view.open_for(sid)

func space_post_open(system_id: int) -> bool:
	return has_skill("A1") and storage.established(Storage.system_key(system_id))

## Systems with a permit entry that is not bought yet.
func unowned_systems() -> Array:
	var out := []
	for sid in Systems.ids():
		if not open_systems.has(sid):
			out.append(sid)
	return out

## Owner 2026-11-03: trading in a system other than 1 needs that system's Space Storage post.
func system_trade_open(planet: int) -> bool:
	var sid := system_of(planet)
	return sid == 1 or space_post_open(sid)

func trade_locked_reason() -> String:
	return StoryText.get_or("LBL_TRADE_NEEDS_STATION", "Needs a Space Storage in this system.")

## Credit price of a permit: the data price, less skill C4 Colonial Rights (balance skill_C4_permit_discount).
func permit_cost(sid: int) -> int:
	var c := Systems.permit_cost(balance, sid)
	if has_skill("C4"):
		c = floori(float(c) * (1.0 - float(balance.get("skill_C4_permit_discount", 0.0))))
	return c

## N11 Second Lane: optional goal, the first sale at a planet of system 2. Saved as the planet index (-1 = not yet).
## Reads the permit price live (after the C4 discount). Pays a title and a planet note only: no cash, no points.
const SECOND_LANE_SYSTEM := 2
var second_lane_planet: int = -1

func second_lane_active() -> bool:
	return second_lane_planet < 0 and Systems.ids().has(SECOND_LANE_SYSTEM) and ships > 0 and cycle > 1

func second_lane_line() -> String:
	return StoryText.get_or("GOAL_SECOND_LANE", "Optional: open system 2 (permit {n}), then sell a lot there.", {"n": permit_cost(SECOND_LANE_SYSTEM)})

## Ticks on a sale (local Sell order or a route stop) at a system 2 planet; buying the permit never ticks it.
func _check_second_lane(r: Dictionary) -> void:
	if second_lane_planet >= 0:
		return
	var hit := -1
	for v in r["local"]:
		if str(v["role"]) == "sell" and int(v["n"]) > 0 and int(v["paid"]) > 0 and system_of(int(v["planet"])) == SECOND_LANE_SYSTEM:
			hit = int(v["planet"])
			break
	if hit < 0:
		for v in r["results"]:
			if int(v.get("stop_sale", 0)) > 0 and int(v.get("stop", -1)) >= 0 and system_of(int(v["stop"])) == SECOND_LANE_SYSTEM:
				hit = int(v["stop"])
				break
	if hit < 0:
		return
	second_lane_planet = hit
	if planet_panel != null and planet_panel.visible:
		planet_panel.rebuild()

## C2 Survey Beacon: systems whose planets have been surveyed (saved). Surveying needs the skill and is free.
var surveyed_systems: Array = []

func is_surveyed(sid: int) -> bool:
	return has_skill("C2") and surveyed_systems.has(sid)

func survey_system(sid: int) -> bool:
	if not has_skill("C2") or open_systems.has(sid) or not Systems.ids().has(sid) or surveyed_systems.has(sid):
		return false
	surveyed_systems.append(sid)
	if skill_screen != null:
		skill_screen.refresh()
	return true

## Expansion points a permit costs: the data value, one less once the system is surveyed (C2), never below 1.
func permit_points(sid: int) -> int:
	var p := Systems.permit_points(balance, sid)
	if is_surveyed(sid) and p > 1:
		p -= 1
	return p

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
	if skill_points < permit_points(sid):
		return {"ok": false, "reason": "points"}
	return {"ok": true, "reason": ""}

## Buys the permit: credits and expansion points, then the system's planets appear on the map.
func buy_permit(sid: int) -> Dictionary:
	var v := can_buy_permit(sid)
	if not v["ok"]:
		return v
	cash -= permit_cost(sid)
	skill_points -= permit_points(sid)
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

## A1 gate (owner decision 2026-11-03): Space Storage opens once the player has made two distinct routes, on any planet.
## pts_pairs gets one entry per new planet pair (see _award_route), so its size is the number of routes made.
func a1_gate_open() -> bool:
	return pts_pairs.size() >= 2

func skill_ctx() -> Dictionary:
	return {"a1_open": a1_gate_open(), "c1_learned": learned_skills.has("C1")}

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
	var learned_text := StoryText.get_text("NOT_SKILL_LEARNED", {"skill": SkillTree.skill_name(id)})
	if not long_notices.has(learned_text):
		long_notices.append(learned_text)
	post_notice(learned_text)
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

## Sell prices of each planet's goods, newest last, kept at each cycle end. Saved; no screen reads them now.
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

## B3 Price Whisper (moved from B1 in T158): text of the best route partner for c from this planet, "" when none pays.
func best_partner_line(planet: int, c: String) -> String:
	var b: Dictionary = engine.best_partner(planet, c)
	if int(b["planet"]) < 0:
		return ""
	return StoryText.get_or("LBL_BEST_PARTNER", "Best partner: {planet} ({margin} cr per unit).", {"planet": planet_name(int(b["planet"])), "margin": int(b["margin"])})

## Base game since T158: at route setup, a warning when the lane earns less per cycle than it costs. True when posted.
func route_margin_notice(src: int, dst: int, c: String) -> bool:
	if not engine.margin_below_upkeep(src, dst, c):
		return false
	post_notice(StoryText.get_or("NOT_ROUTE_BELOW_UPKEEP", "This route earns {margin} cr a cycle and costs {cost}. It will run at a loss.",
		{"margin": engine.route_margin(src, dst, c), "cost": engine.fixed_cost()}))
	return true

func open_skills() -> void:
	if preface != null or game_over:
		return
	if galaxy_view != null and galaxy_view.visible:
		galaxy_view.close_view()  # one screen at a time
	skill_screen.open_screen()

## T105: click on a system in the galaxy view: close the view and put the map camera on that system.
func _on_galaxy_system(id: int) -> void:
	galaxy_view.close_view()
	go_to_system(id)

## Moves the player into one open system (its own space: only its planets, routes and ships show).
## Returns false and does nothing when the system is locked or unknown.
func go_to_system(id: int) -> bool:
	if not open_systems.has(id):
		return false
	view_system = id
	map.set_view_system(id)
	_refresh()
	return true

## Click on a marker of another system in the 3D view: moves there when open, else says why not.
func enter_system_from_view(id: int) -> bool:
	if go_to_system(id):
		return true
	var how := StoryText.get_or("LBL_LOCKED_HOW", "permit or skill")
	post_notice(StoryText.get_or("NOT_SYSTEM_LOCKED", "{name} is locked: {how}.", {"name": Systems.name_of(id), "how": how}))
	return false

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
		go_to_system(int(t["system"]))

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
	_hide_cluster_info()  # T159
	if not sell_offer.is_empty():
		sell_offer = {}  # clicking elsewhere drops only the sell offer; the send stays
	if space_storage_view != null:
		space_storage_view.close_view()  # one view at a time
	if not pending.is_empty():
		if index < 0 or index >= map.planets.size():
			cancel_pending()
		elif index == int(pending["planet"]):
			post_notice("Pick a different planet as the destination.")
			return
		else:
			var src: int = int(pending["planet"])
			var c: String = str(pending["c"])
			var dst := index
			var stop := -1
			if pending.has("dest"):  # N9: destination already picked; this click names its stop, or the destination again sends direct
				dst = int(pending["dest"])
				if index != dst:
					if not engine.stop_candidates(src, dst, c).has(index):
						post_notice(StoryText.get_or("NOT_STOP_PICK_AGAIN", "Click a stop from the picker, or the destination again."))
						return
					stop = index
			elif not engine.stop_candidates(src, index, c).is_empty():
				pending["dest"] = index  # N9: a stop is on the way; the next click names it or sends direct
				_pending_changed()
				return
			var r := send_stock_buying(src, dst, c, stop)
			if not r["ok"]:
				post_notice_now(str(r["reason"]))  # pending stays so the player can pick another planet
				return
			var cnt: int = engine.lane_count(src, dst, str(r["c"]))
			var pending_planet: int = src
			var wants_buy: bool = bool(pending.get("buy", false))
			cancel_pending()
			if wants_buy and not engine.local_on(pending_planet, str(r["c"]), "buy"):
				var bo := set_local_order(pending_planet, str(r["c"]), "buy", true)
				if not bo["ok"]:
					post_notice(str(bo["reason"]))
			if bool(r.get("bought", false)):
				post_notice(StoryText.get_text("NOT_SHIP_BOUGHT"))
			post_notice(StoryText.get_text("NOT_ROUTE_MADE", {"planet_a": planet_name(int(pending_planet)), "planet_b": planet_name(dst)}) if cnt <= 1 else StoryText.get_text("NOT_LANE_SHIP_ADDED"))
			if stop >= 0:
				post_notice(stop_line(stop, dst))  # N9
			route_margin_notice(pending_planet, dst, str(r["c"]))  # low-margin warning, base game
			_route_beat(pending_planet, dst)
			selected_planet = dst
			if sell_offer_applies(dst, str(r["c"])):
				sell_offer = {"planet": dst, "c": str(r["c"])}
			planet_panel.show_planet(dst)
			return
	if index < 0 or index >= map.planets.size():
		selected_planet = -1
		planet_panel.visible = false
		return
	selected_planet = index
	planet_panel.show_planet(index)
	_tut_once("row", ["TUT_C1_ROW"])

## T159: story id suffix of a base cluster ("c1_1" -> "S1A"); "" for clusters made by events.
func _cluster_story_key(cl: Dictionary) -> String:
	var parts := str(cl["id"]).split("_")
	if parts.size() == 2 and parts[0].begins_with("c") and parts[1].is_valid_int() and int(parts[1]) >= 1 and int(parts[1]) <= 26:
		return "S%s%s" % [parts[0].substr(1), char(64 + int(parts[1]))]
	return ""

func _hide_cluster_info() -> void:
	cluster_info_index = -1
	if cluster_info != null:
		cluster_info.visible = false

## T159: click on an asteroid pack. Shows name, what it gives per cycle and, with B1 Prospecting, what is left. Risk: no value exists yet (open question).
func _on_cluster_clicked(index: int) -> void:
	if space_storage_view != null:
		space_storage_view.close_view()
	if not pending.is_empty():
		return
	var found := {}
	for cl in clusters.list(0):
		if int(cl["index"]) == index:
			found = cl
	if found.is_empty():
		_hide_cluster_info()
		return
	selected_planet = -1
	planet_panel.visible = false
	cluster_info_index = index
	if cluster_info == null:
		cluster_info = PanelContainer.new()
		cluster_info.position = Vector2(76, 76)
		cluster_info.custom_minimum_size = Vector2(320, 0)
		add_child(cluster_info)
	for c in cluster_info.get_children():
		cluster_info.remove_child(c)
		c.queue_free()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	cluster_info.add_child(box)
	var key := _cluster_story_key(found)
	var title := Label.new()
	title.theme_type_variation = "LabelAccent"
	title.text = StoryText.get_or("WORLD_CL_%s_NAME" % key, StoryText.get_or("LBL_CLUSTER_NAME", "Asteroid cluster {id}", {"id": str(found["id"])})) if key != "" else StoryText.get_or("LBL_CLUSTER_NAME", "Asteroid cluster {id}", {"id": str(found["id"])})
	box.add_child(title)
	if key != "" and StoryText.has_text("WORLD_CL_%s_DESC" % key):
		var d := Label.new()
		d.theme_type_variation = "LabelSmall"
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.text = StoryText.get_text("WORLD_CL_%s_DESC" % key)
		box.add_child(d)
	var info := Label.new()
	info.name = "ClusterInfoLine"
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var args := {"good": Ui.good_name(str(found["good"])), "yield": clusters.yield_per_cycle(), "left": int(found["left"]), "max": int(found["max"])}
	if can_mine():
		info.text = StoryText.get_or("LBL_CLUSTER_INFO", "{good}: {yield} per cycle, {left} of {max} left.", args)
	else:
		info.text = "%s %s" % [StoryText.get_or("LBL_CLUSTER_INFO_YIELD", "{good}: {yield} per cycle.", args), StoryText.get_or("NOT_MINING_NEEDS_SKILL", "Mining needs the Prospecting skill.")]
	box.add_child(info)
	var close := Button.new()
	close.text = StoryText.get_or("BTN_CLOSE", "Close")
	close.pressed.connect(_hide_cluster_info)
	box.add_child(close)
	cluster_info.visible = true

## T65: clicking a route line selects that connection in the panel (with Remove).
func _on_route_clicked(id: int) -> void:
	var i: int = engine.find_by_id(id)
	if i < 0:
		return
	selected_planet = int(engine.routes[i]["b"]) if RouteEngine.from_cluster(engine.routes[i]) else int(engine.routes[i]["a"])  # T156: a cluster is no planet to select
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
	if space_storage_view != null:
		space_storage_view.refresh()

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
	if storage.amount(storage.planet_key(selected_planet), c) <= 0:  # T134: allowed, but say it will wait
		post_notice(StoryText.get_text("NOT_ROUTE_STALLED", {"commodity": Ui.good_name(c), "planet": planet_name(selected_planet)}))

## Buy pressed on a resource row (shows Stop buying while the order is on): toggles a standing buy order on its own, no route and no destination needed.
## Sending is separate (Send to... on a storage row, with or without a buy order).
func _on_buy_send(c: String) -> void:
	if selected_planet < 0 or game_over:
		return
	if not pending.is_empty():
		cancel_pending()
	var r := toggle_local(selected_planet, c, "buy")  # one button: starts and stops the buy order
	if not r["ok"]:
		post_notice(str(r["reason"]))
	elif engine.local_on(selected_planet, c, "buy"):
		pending = {"planet": selected_planet, "c": c}  # chain: buying started, now click a planet to send the stock there
		_pending_changed()

## Combined path kept: buy order now plus a route once a destination is clicked.
func begin_buy_and_send(c: String) -> void:
	if selected_planet < 0 or game_over:
		return
	pending = {"planet": selected_planet, "c": c, "buy": true}
	_pending_changed()

## The destination of a Send offers a Sell order only when it buys the good, trade is open there and no Sell order exists yet.
func sell_offer_applies(planet: int, c: String) -> bool:
	return trade.price(planet, c + "_sell") >= 0 and system_trade_open(planet) and not engine.local_on(planet, c, "sell")

## "Sell <good> here too?" floats on the map just above the destination planet (the planet name is below it).
var sell_offer_box: PanelContainer
var _sell_offer_key := ""

func _update_sell_offer_box() -> void:
	if sell_offer.is_empty():
		if sell_offer_box != null:
			sell_offer_box.queue_free()
			sell_offer_box = null
			_sell_offer_key = ""
		return
	var pl: int = int(sell_offer["planet"])
	var c: String = str(sell_offer["c"])
	var key := "%d|%s" % [pl, c]
	if sell_offer_box == null or key != _sell_offer_key:
		if sell_offer_box != null:
			sell_offer_box.queue_free()
		_sell_offer_key = key
		sell_offer_box = PanelContainer.new()
		sell_offer_box.name = "SellOffer"
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 6)
		sell_offer_box.add_child(h)
		var l := Label.new()
		l.text = StoryText.get_or("LBL_SELL_OFFER", "Sell {commodity} here too?", {"commodity": Ui.good_name(c)})
		l.theme_type_variation = "LabelAccent"
		h.add_child(l)
		var yes := Button.new()
		yes.name = "SellOfferYes"
		yes.theme_type_variation = "ButtonSmall"
		yes.text = StoryText.get_or("BTN_YES", "Yes")
		yes.pressed.connect(func(): accept_sell_offer())
		h.add_child(yes)
		var no := Button.new()
		no.name = "SellOfferNo"
		no.theme_type_variation = "ButtonSmall"
		no.text = StoryText.get_or("BTN_NO", "No")
		no.pressed.connect(func(): dismiss_sell_offer())
		h.add_child(no)
		add_child(sell_offer_box)
	var visible_here: bool = map != null and map.camera != null and pl < map.positions.size() and map.planet_in_view(pl) and not map.camera.is_position_behind(map.positions[pl])
	sell_offer_box.visible = visible_here
	if visible_here:
		var sp: Vector2 = map.camera.unproject_position(map.positions[pl])
		var sz: Vector2 = sell_offer_box.get_combined_minimum_size()
		var lift: float = 16.0 + 24.0  # planet radius on screen plus a gap, so the box sits above the planet and clear of its name
		var pos := Vector2(sp.x - sz.x * 0.5, sp.y - sz.y - lift)
		var vr := get_viewport_rect()
		pos.x = clampf(pos.x, 4.0, maxf(4.0, vr.size.x - sz.x - 4.0))
		pos.y = clampf(pos.y, 4.0, maxf(4.0, vr.size.y - sz.y - 4.0))
		sell_offer_box.position = pos

func accept_sell_offer() -> void:
	if sell_offer.is_empty():
		return
	var pl: int = int(sell_offer["planet"])
	var c: String = str(sell_offer["c"])
	sell_offer = {}
	if not engine.local_on(pl, c, "sell"):
		var r := set_local_order(pl, c, "sell", true)
		if not r["ok"]:
			post_notice(str(r["reason"]))
	_refresh_panel()

## Esc: ends the whole chain (the send target pick and the sell offer). Buy orders and routes already made stay.
func cancel_chain() -> void:
	sell_offer = {}
	if pending.is_empty():
		_refresh_panel()
	else:
		cancel_pending()  # refreshes the panel

func dismiss_sell_offer() -> void:
	if sell_offer.is_empty():
		return
	sell_offer = {}
	_refresh_panel()

func cancel_pending() -> void:
	pending = {}
	_pending_changed()

func _pending_changed() -> void:
	map.set_pending(int(pending["planet"]) if not pending.is_empty() else -1)
	if pending_label != null:
		pending_label.visible = not pending.is_empty()
		if pending.has("dest"):  # N9: destination picked, a stop is on the way
			pending_label.text = "Click the stop in the picker, or %s again for a direct send. (Esc to cancel)" % planet_name(int(pending["dest"]))
		elif not pending.is_empty():
			pending_label.text = "Send %s from %s: click the destination planet. (Esc to cancel)" % [
				pending["c"], planet_name(int(pending["planet"]))]
	_refresh_pending_margins()
	_refresh_panel()

## P1: one line per reachable destination: margin per unit now, and after the price events end when one moves it.
func pending_margin_lines() -> Array:
	var out: Array = []
	if pending.is_empty():
		return out
	var src := int(pending["planet"])
	var c := str(pending["c"])
	for i in trade.planets.size():
		if i == src or not bool(engine.check_connection(src, i, c)["ok"]):
			continue
		if pending.has("dest") and i != int(pending["dest"]):  # N9: once a destination is picked, only its lines
			continue
		var now: int = trade.margin(src, i, c)
		var after: int = trade.margin_after_events(src, i, c)
		var args := {"planet": planet_name(i), "now": now, "after": after}
		if now == after:
			out.append(StoryText.get_or("LBL_MARGIN_NOW", "{planet}: margin {now} per unit", args))
		else:
			out.append(StoryText.get_or("LBL_MARGIN_AFTER_EVENT", "{planet}: margin {now} per unit now, {after} after the event", args))
		for k in engine.stop_candidates(src, i, c):  # N9: one picker line per stop on the way
			out.append(stop_line(int(k), i))
	return out

## N9: picker line for a stop on the way to dst: 'Stop at A: sell up to N here, carry the rest to B.' (A, B, N read live).
func stop_line(stop: int, dst: int) -> String:
	return StoryText.get_or("LBL_STOP_AT_LINE", "Stop at {stop}: sell up to {n} here, carry the rest to {planet}.", {"stop": planet_name(stop), "n": engine.local_amount(), "planet": planet_name(dst)})

func _refresh_pending_margins() -> void:
	if pending_margins == null:
		return
	var lines := pending_margin_lines()
	pending_margins.visible = not lines.is_empty()
	pending_margins.text = "\n".join(lines)

func _build_pending_label() -> void:
	pending_margins = Label.new()
	pending_margins.name = "PendingMargins"
	pending_margins.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	pending_margins.grow_horizontal = Control.GROW_DIRECTION_BOTH
	pending_margins.grow_vertical = Control.GROW_DIRECTION_BEGIN
	pending_margins.offset_bottom = -92  # just above the pending banner
	pending_margins.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pending_margins.theme_type_variation = "LabelSmall"
	pending_margins.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pending_margins.visible = false
	add_child(pending_margins)
	pending_label = Label.new()
	pending_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	pending_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	pending_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	pending_label.offset_bottom = -64  # route hint, just above the legend
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

## Route made: both ends ring once, so the new lane is seen to start and land.
func _route_beat(a: int, b: int) -> void:
	for idx in [a, b]:
		var sp = Juice.planet_screen(map, idx)
		if sp != null:
			Juice.ping(self, sp, Ui.col("signal_good"))

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
		return {"ok": false, "reason": "Not enough cash for a new ship (%d cr). Each route needs its own ship; wait for income or remove a route." % Ships.price(kind, balance)}
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
	if Clusters.is_node(src) and not open_systems.has(system_of(src)):  # T156: a cluster of a system without a permit
		return {"ok": false, "reason": trade_locked_reason()}
	if not system_trade_open(src) or (dst >= 0 and not system_trade_open(dst)) or (dst < 0 and not space_post_open(-dst)):
		return {"ok": false, "reason": trade_locked_reason()}
	if engine.lane_full(src, dst, c):  # T145: a full lane takes an upgrade, not one more ship
		return {"ok": false, "reason": "This lane is full. Upgrade the route instead of adding a ship."}
	if free_ships() <= 0:
		return {"ok": false, "reason": StoryText.get_text("NOT_SHIP_FREE")}
	return {"ok": true, "reason": ""}

## T145: Upgrade route (level 2) on a full lane. Ships and upgrades draw on the same cash.
func can_upgrade_route(id: int) -> Dictionary:
	if game_over:
		return {"ok": false, "reason": "The game is over."}
	var i: int = engine.find_by_id(id)
	if i < 0:
		return {"ok": false, "reason": "No such route."}
	var r: Dictionary = engine.routes[i]
	if int(r.get("level", 1)) >= 2:
		return {"ok": false, "reason": "Already upgraded."}
	if not engine.lane_full(int(r["a"]), int(r["b"]), str(r["c"])):
		return {"ok": false, "reason": "Only a full lane can be upgraded."}
	var cost := int(balance.get("upgrade_cost", 0))
	if cash < cost:
		return {"ok": false, "reason": "Not enough cash to upgrade the route (%d cr)." % cost}
	return {"ok": true, "reason": ""}

## Upgrades the whole lane of route `id` to level 2 and charges upgrade_cost once. {ok, reason}.
func upgrade_route(id: int) -> Dictionary:
	var r := can_upgrade_route(id)
	if not r["ok"]:
		return r
	var rec: Dictionary = engine.routes[engine.find_by_id(id)]
	cash -= int(balance.get("upgrade_cost", 0))
	engine.set_lane_level(int(rec["a"]), int(rec["b"]), str(rec["c"]), 2)
	_after_change()
	return r

## Destination value for a send to the Space Storage of system sid: pass it as `dst` to send_stock / can_connect.
static func station_dst(sid: int) -> int:
	return -sid

## One-way route that moves commodity c from the storage at `src` to the storage at `dst` (one auto-assigned ship).
## Returns {ok, reason, id, c}.
func send_stock(src: int, dst: int, c: String, stop: int = -1) -> Dictionary:
	var r := _connect(src, dst, c, stop)
	r["c"] = c
	return r

## "Send to..." from the planet panel: one action that buys a ship when none is free, then makes the route.
## Route problems are checked first, so no ship is bought for a route that cannot be made. {ok, reason, id, c, bought}.
func send_stock_buying(src: int, dst: int, c: String, stop: int = -1) -> Dictionary:
	var bought := false
	if stop >= 0 and not engine.stop_candidates(src, dst, c).has(stop):  # N9: checked before any ship is bought
		return {"ok": false, "reason": StoryText.get_or("NOT_STOP_PICK_AGAIN", "Click a stop from the picker, or the destination again."), "c": c, "bought": false}
	if free_ships() <= 0:
		var chk: Dictionary = can_connect(src, dst, c)
		if chk["reason"] != StoryText.get_text("NOT_SHIP_FREE"):  # a route problem other than "no ship"
			chk["c"] = c
			chk["bought"] = false
			return chk
		var b := can_buy_ship("small")
		if not b["ok"]:
			return {"ok": false, "reason": b["reason"], "c": c, "bought": false}
		buy_ship("small")
		bought = true
	var r := send_stock(src, dst, c, stop)
	r["bought"] = bought
	return r

## N2: destinations of commodity c that this planet already sends to with an assigned ship (one entry per lane).
func split_targets(planet: int, c: String) -> Array:
	var out: Array = []
	for r in engine.routes:
		var b := int(r["b"])
		if b >= 0 and int(r["a"]) == planet and str(r["c"]) == c and not out.has(b):
			out.append(b)
	return out

## Split bar: the two lanes a bar on this storage row sets: the lanes of an existing split, else the first two lanes with ships.
func split_pair(planet: int, c: String) -> Array:
	var t := split_targets(planet, c)
	if t.size() < 2:
		return []
	for d in t:
		var sp: Dictionary = engine.lane_split(planet, int(d), c)
		if not sp.is_empty() and t.has(int(sp["to"])):
			return [int(d), int(sp["to"])]
	return [t[0], t[1]]

## Split bar: the first lane's share in whole percent (50 when no split is set).
func split_percent(planet: int, c: String) -> int:
	var pair := split_pair(planet, c)
	if pair.is_empty():
		return 50
	var sp: Dictionary = engine.lane_split(planet, int(pair[0]), c)
	return 50 if sp.is_empty() else roundi(float(sp["share"]) * 100.0)

## Split bar: live setting. first_pct is the first lane's percent (each lane keeps at least 10); the second gets the rest.
func set_split_percent(planet: int, c: String, first_pct: int) -> void:
	var pair := split_pair(planet, c)
	if pair.is_empty() or game_over:
		return
	var pct := clampi(first_pct, 10, 90)
	engine.set_split(planet, int(pair[0]), int(pair[1]), c, float(pct) / 100.0)

## Split bar: "Stop split".
func clear_split(planet: int, c: String) -> void:
	engine.clear_split(planet, c)

## T68: standing local order at a planet (no ship). role "buy" or "sell". Returns {ok, reason}.
func set_local_order(planet: int, c: String, role: String, on: bool) -> Dictionary:
	if game_over:
		return {"ok": false, "reason": "The game is over."}
	if on and not system_trade_open(planet):
		return {"ok": false, "reason": trade_locked_reason()}
	var r: Dictionary = engine.set_local(planet, c, role, on)
	if r["ok"]:
		if on:
			_tut_once("order_" + role, ["TUT_C1_BUY" if role == "buy" else "TUT_C1_SELL"])
			_award_planet(planet)
			_note_system(planet)
		_after_change()
	return r

## N5: one-off salvage sale of the stock in a planet's storage. Returns {ok, reason, credits}.
func salvage_stock(planet: int, c: String) -> Dictionary:
	if game_over:
		return {"ok": false, "reason": "The game is over.", "credits": 0}
	if engine.salvage_reason(planet, c) == "":
		return {"ok": false, "reason": StoryText.get_or("LBL_SALVAGE_NA", "Salvage is not offered now."), "credits": 0}
	var offer: Dictionary = engine.salvage_offer(planet, c)
	var took: int = storage.remove(storage.planet_key(planet), c, int(offer["units"]))
	var credits: int = int(offer["n"]) if took == int(offer["units"]) else 0
	cash += credits
	_after_change()
	return {"ok": true, "reason": "", "credits": credits}

func _on_salvage(c: String) -> void:
	if selected_planet < 0:
		return
	var r := salvage_stock(selected_planet, c)
	if not r["ok"]:
		post_notice(str(r["reason"]))

func toggle_local(planet: int, c: String, role: String) -> Dictionary:
	return set_local_order(planet, c, role, not engine.local_on(planet, c, role))

func _connect(src: int, dst: int, c: String, stop: int = -1) -> Dictionary:
	var r := can_connect(src, dst, c)
	if not r["ok"]:
		return r
	var rec: Dictionary = engine.new_record(src, dst, c)
	var mining := Clusters.is_node(src)
	rec["stop"] = stop if stop >= 0 and engine.stop_candidates(src, dst, c).has(stop) else -1  # N9
	rec["id"] = engine.next_id
	rec["ship"] = pick_ship(src, dst, c)  # T58
	engine.next_id += 1
	rec["fresh"] = clampf(1.0 - cycle_elapsed / _cycle_seconds(), 0.0, 1.0)
	engine.routes.append(rec)
	if mining:  # T156: a cluster is no planet pair; only the delivery planet counts
		_award_planet(dst)
	else:
		_award_route(src, dst)
	_note_system(src)
	_note_system(dst)
	if not mining:
		storage.ensure(str(rec["src"]))  # T65: first order at a planet establishes its company storage
	storage.ensure(str(rec["dst"]))
	_tut_once("route", ["TUT_C2_ROUTE_DONE"])
	_after_change()
	_mine_event(src)
	return {"ok": true, "reason": "", "id": rec["id"]}

## Removes the connection; its ship becomes free.
func remove_connection(id: int) -> Dictionary:
	var i: int = engine.find_by_id(id)
	if i < 0:
		return {"ok": false, "reason": "No such route."}
	engine.routes.remove_at(i)
	_after_change()
	return {"ok": true, "reason": ""}

## P2: cycles the closure of a route's planet has left (0 when neither end is closed now).
func closure_left(rec: Dictionary) -> int:
	var n := 0
	for a in events.active:
		var p := int(a["planet"])
		if a["kind"] == "closed" and (p == int(rec["a"]) or p == int(rec["b"])) and engine.closed_planets.has(p):
			n = maxi(n, int(a["left"]))
	return n

## P2: the optional Move ship offer for a route blocked by a closed planet, {a, b, net, setup_lost} or {}.
func move_offer(id: int) -> Dictionary:
	var i: int = engine.find_by_id(id)
	if i < 0:
		return {}
	var rec: Dictionary = engine.routes[i]
	return engine.best_open_lane(rec, closure_left(rec))

## P2: Move ship, pressed by the player only; never automatic. Costs no cash, only the idle transit cycles. {ok, reason}.
func move_ship(id: int) -> Dictionary:
	if game_over:
		return {"ok": false, "reason": "The game is over."}
	var i: int = engine.find_by_id(id)
	if i < 0:
		return {"ok": false, "reason": "No such route."}
	var offer := move_offer(id)
	if offer.is_empty():
		return {"ok": false, "reason": "No open route pays for this ship."}
	engine.move_route(i, int(offer["a"]), int(offer["b"]))
	storage.ensure(str(engine.routes[i]["src"]))
	storage.ensure(str(engine.routes[i]["dst"]))
	_after_change()
	return {"ok": true, "reason": ""}

## Copy of one route: record fields plus status (running | stalled | blocked), reason, net (projected per cycle),
## role ("buy" if `planet` is the source, "sell" if the destination, "" without a planet argument).
func _view(rec: Dictionary, planet: int = -1) -> Dictionary:
	var d: Dictionary = rec.duplicate(true)
	d["status"] = display_status(rec)
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
	if Clusters.is_node(i):  # T156
		return StoryText.get_or("LBL_CLUSTER_NAME", "Asteroid cluster {id}", {"id": str(clusters.items[Clusters.index_of(i)]["id"])}) if clusters.valid(Clusters.index_of(i)) else "?"
	if i < 0 and i > -1000:  # a station destination, -system id
		return StoryText.get_or("LBL_SPACE_STORAGE_NAME", "Space Storage")
	if i < 0 or i >= map.planets.size():
		return "?"
	return str(map.planets[i].get("name", map.planets[i].get("id", "?")))

## T07b: tell the map which route lines to draw (cheap: restyles existing lines, adds/removes changed ones).
func _push_routes_to_map() -> void:
	var list: Array = []
	var lanes := {}  # T87: one line per lane; ships = ships on it, status = running if any ship runs
	for rec in engine.routes:
		var k := "%d|%d|%s" % [rec["a"], rec["b"], rec["c"]]
		var st: String = display_status(rec)
		if lanes.has(k):
			var e: Dictionary = lanes[k]
			e["ships"] = int(e["ships"]) + 1
			e["net"] = int(e["net"]) + engine.payout_of(rec)
			if st == "running":
				e["status"] = st
			continue
		var e2 := {"id": rec["id"], "a": rec["a"], "b": rec["b"], "c": rec["c"], "ships": 1, "status": st, "net": engine.payout_of(rec), "reason": engine.reason_of(rec)}
		lanes[k] = e2
		list.append(e2)
	map.set_routes(list)
	map.set_clusters(_all_cluster_packs())  # T157: asteroid packs follow the cluster data

## T157: clusters of every system in the cluster data, from clusters_in_system (packs of a system not yet visited stay hidden).
func _all_cluster_packs() -> Array:
	var out: Array = []
	var seen := {}
	for it in clusters.items:
		var sid := int(it["system"])
		if not seen.has(sid):
			seen[sid] = true
			out.append_array(clusters_in_system(sid))
	return out

func _after_change() -> void:
	_push_routes_to_map()
	_tut_advance()
	_refresh()
	_refresh_panel()
	save_now()

const NOTICE_QUEUE_MAX := 6
const LONG_NOTICE_ENDS := 2  # a "skill learned" notice stays through two cycle ends
var long_notices: Array = []  # texts that get LONG_NOTICE_ENDS
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

## A refusal the player just caused: shown at once (notices otherwise advance only at a cycle end, so the
## refusal sat in the queue behind "Route made" and the click looked dead).
func post_notice_now(text: String) -> void:
	last_notice = text
	if shown_notice != text:
		_show_notice(text)
	notice_posted.emit(text)

func _show_notice(text: String) -> void:
	shown_notice = text
	notice_ends_left = LONG_NOTICE_ENDS if long_notices.has(text) else 1  # advances at the next cycle end
	if notice_label != null:
		notice_label.text = text
		notice_label.visible = true
		Juice.enter(notice_label, 0.96, 0.0, true)

func _advance_notice() -> void:
	if shown_notice == "":
		return
	notice_ends_left -= 1
	if notice_ends_left > 0:
		return
	long_notices.erase(shown_notice)
	if not notice_queue.is_empty():
		_show_notice(str(notice_queue.pop_front()))
		return
	shown_notice = ""
	last_notice = ""
	notice_ends_left = 0
	if notice_label != null:
		Juice.leave(notice_label, false, Callable(self, "_clear_notice_label"))

## Runs when the board notice has faded out: the text is cleared once it is no longer seen.
func _clear_notice_label() -> void:
	if notice_label != null:
		notice_label.text = ""

## Settles every route once (called from _end_cycle). Returns the results array.
## Display grace (UI only, not saved): cycles in a row a route did not move. Reset when it moves.
const WARN_AFTER_CYCLES := 2
var idle_cycles: Dictionary = {}  # route id -> consecutive cycles not moving

func _count_idle_cycles() -> void:
	var next := {}
	for rec in engine.routes:
		var id := int(rec["id"])
		if engine.status_of(rec) == "running":
			next[id] = 0
		else:
			next[id] = int(idle_cycles.get(id, 0)) + 1
	idle_cycles = next

## Status a screen shows: a stalled or waiting route looks like running until it has not moved for two cycles in a row.
## Blocked shows at once.
func display_status(rec: Dictionary) -> String:
	var st: String = engine.status_of(rec)
	if st == "blocked" or st == "running":
		return st
	return st if int(idle_cycles.get(int(rec["id"]), 0)) >= WARN_AFTER_CYCLES else "running"

## Dead worlds: a running route out of a dead world mines it, so its danger rises by dead_danger_rise each cycle.
func _tick_danger() -> void:
	var ids: Array = []
	for rec in engine.routes:
		var a := int(rec["a"])
		if str(rec["state"]) == "running" and a >= 0 and a < map.planets.size() and DeadWorlds.is_dead(map.planets[a]):
			var pid := str(map.planets[a]["id"])
			if not ids.has(pid):  # two ships on one world raise it once
				ids.append(pid)
	dead.tick(ids)

## Fabric: can it be built now? {ok, reason}: "skill" (F1 not learned), "post" (no trading post in system 1), "built", "credits".
func can_build_fabric() -> Dictionary:
	if fabric.built:
		return {"ok": false, "reason": "built"}
	if not has_skill("F1"):
		return {"ok": false, "reason": "skill"}
	if not station_systems.has(Fabric.SYSTEM):
		return {"ok": false, "reason": "post"}
	if cash < fabric.build_cost():
		return {"ok": false, "reason": "credits"}
	return {"ok": true, "reason": ""}

## Builds the fabric: the build cost is paid once, at the trading post.
func build_fabric() -> Dictionary:
	var v := can_build_fabric()
	if not v["ok"]:
		return v
	cash -= fabric.build_cost()
	fabric.built = true
	fabric.state = "idle"
	post_notice(StoryText.get_or("NOT_FABRIC_BUILT", "Fabric built at the trading post."))
	_after_change()
	return v

## Danger meter (0 to dead_danger_max) of planet index i; 0 for a planet that is not a dead world.
func danger_of(i: int) -> int:
	return dead.get_danger(str(map.planets[i].get("id", ""))) if i >= 0 and i < map.planets.size() else 0

## First route out of a dead world: fires the part 1 event whose data says "on_mine" for it (none until the story data has one).
func _mine_event(src: int) -> void:
	if src < 0 or src >= map.planets.size() or not DeadWorlds.is_dead(map.planets[src]):
		return
	var found: Array = events.mine_events(str(map.planets[src]["id"]))
	if not found.is_empty():
		fire_event(str(found[0]))

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
	_check_second_lane(r)
	routes_settled.emit(r["results"], int(r["delta"]))
	_show_income(r)
	return r["results"]

## T133: credits each planet gained this cycle, from the engine's own results (routes pay at their
## destination, local sell orders at their planet). Only positive amounts are shown.
func _show_income(r: Dictionary) -> void:
	if income_popup == null:
		return
	var gains := {}
	for v in r["results"]:
		if int(v["paid"]) > 0:
			gains[int(v["b"])] = int(gains.get(int(v["b"]), 0)) + int(v["paid"])
	for v in r["local"]:
		if str(v["role"]) == "sell" and int(v["paid"]) > 0:
			gains[int(v["planet"])] = int(gains.get(int(v["planet"]), 0)) + int(v["paid"])
	income_popup.show_gains(gains)

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
	_update_station_markers()
	_update_sell_offer_box()
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
	_tick_danger()
	fabric.run(storage)
	_count_idle_cycles()
	# Space Storage fills only by a ship sent to it (send_stock with a station destination); planet_to_space_rate is unused.
	_check_stranded()
	_record_prices()  # price history
	_push_routes_to_map()
	_refresh_panel()
	cycle_ended.emit(cycle)
	Juice.pop(cycle_label, 1.12)  # the economy turned over: income has landed
	Juice.flash(cycle_label, Ui.col("star_warm"))
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
	if has_skill("B4") and events.due(cycle + 1):  # B4 Event Forecast: one cycle of warning, naming planet and commodity
		forecast_id = events.random_id(["EV18"] if shield.decided else [], cycle + 1)
		post_notice(forecast_text(forecast_id))
	var sched_id: String = events.take_due(cycle) if (event_notice == null and not game_over) else ""  # R1: part 2 events come from the schedule
	if sched_id != "":
		fire_event(sched_id)
	elif events.due(cycle) or (OS.is_debug_build() and debug_force_event):
		debug_force_event = false
		var fid: String = forecast_id if forecast_id != "" and events.by_id.has(forecast_id) else events.random_id(["EV18"] if shield.decided else [], cycle)
		forecast_id = ""
		fire_event(fid)
	_tut_cycle()
	save_now()

## B4 Event Forecast: the event picked ahead of its cycle (saved); it is the one that fires.
var forecast_id: String = ""

## Warning text for a coming event: names the planet and commodity when the event has them, else the plain warning.
func forecast_text(id: String) -> String:
	var eff: Dictionary = events.effect_of_event(id)
	var kind := str(eff.get("kind", ""))
	if kind in ["up", "down"]:
		return StoryText.get_or("EVT_NEXT_DUE_PRICE", StoryText.get_text("EVT_NEXT_DUE"), {"planet": planet_name(int(eff["planet"])), "commodity": Ui.good_name(str(eff["c"])), "direction": "rise" if kind == "up" else "fall"})
	if kind == "closed":
		return StoryText.get_or("EVT_NEXT_DUE_CLOSED", StoryText.get_text("EVT_NEXT_DUE"), {"planet": planet_name(int(eff["planet"]))})
	return StoryText.get_text("EVT_NEXT_DUE")

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
		"last_cycle": cycle >= int(balance.get("win_cycle", 0)),
		"shield_built": shield.built}  # T121 hidden flag

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
	var pct := roundi(events.pct(str(eff["c"])) * 100.0)
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
		"danger":
			body = StoryText.get_or("NOT_EVENT_EFFECT_DANGER", "Danger at {planet}: {amount}.", args)
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
		"danger":  # [danger: Planet, +N]: raise or lower a dead world's meter
			dead.change(str(map.planets[int(eff["planet"])].get("id", "")), int(eff["amount"]))
		"asteroid_pay":  # T109: payment to the state; the point is an event reward, not bought
			cash -= events.asteroid_cost()
			_spawn_event_cluster()  # T156: the rock is pulled apart: a fresh small cluster
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

## T156: the fresh small cluster EV20 leaves when paid. Beside an open planet picked by the cycle number (no RNG, so seeded rolls stay as they are).
func _spawn_event_cluster() -> int:
	var opts: Array = []
	for i in map.planets.size():
		if open_systems.has(system_of(i)):
			opts.append(i)
	if opts.is_empty():
		return -1
	var pl: int = int(opts[cycle % opts.size()])
	return clusters.spawn_small(system_of(pl), float(map.planets[pl].get("x", 0)), float(map.planets[pl].get("y", 0)))

## T156: the skill check that unlocks routing from a cluster. B1 is Prospecting (T158); Clusters.MINING_SKILL is the one place to change.
func can_mine() -> bool:
	return has_skill(Clusters.MINING_SKILL)

## T156 for T157 (map): clusters of a system with ore left, each {index, node, id, system, x, y, radius, count, visible, left, max, good, spawned}.
func clusters_in_system(sid: int) -> Array:
	return clusters.list(sid)

## T156 for the planet panel: clusters with ore left near a planet, nearest first.
func clusters_near_planet(planet: int) -> Array:
	if planet < 0 or planet >= map.planets.size():
		return []
	return clusters.near(system_of(planet), float(map.planets[planet].get("x", 0)), float(map.planets[planet].get("y", 0)))

## T156 for T157 and tests: starts an ore route from cluster `node` (Clusters.node_id(i)) to planet dst. Buys a ship if none is free, as Send to... does.
func send_from_cluster(node: int, dst: int) -> Dictionary:
	return send_stock_buying(node, dst, clusters.good_of(Clusters.index_of(node)))

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
	_event_beat()
	_open_event_notice(id)
	_refresh()

func _open_event_notice(id: String) -> void:
	_dismiss_event_notice()
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
	event_notice.show_event(events.title_of(id, args), events.body_of(id, args), line, labels, StoryText.get_text("MENU_CONTINUE"), off, _event_art(id))
	event_notice.confirmed.connect(_on_event_confirmed.bind(id))
	if id == "EV20":
		map.hex_ring.show_ring(true)  # T110

## Banner path for an event id; EV20 keeps its drawn asteroid when the file is missing.
func _event_art(id: String) -> String:
	var path := "res://art/event_banners/%s.webp" % id
	if ResourceLoader.exists(path):
		return path
	return "asteroid" if id == "EV20" else ""

## Closes the event notice with a short fade. The game carries on at once: the reference is cleared here.
func _dismiss_event_notice() -> void:
	if event_notice != null:
		event_notice.dismiss()
		event_notice = null

## Event beat: the top bar flashes warm and nudges, and the planet an event touches rings once.
func _event_beat() -> void:
	if top_bar != null:
		Juice.flash(top_bar, Ui.col("star_warm").lightened(0.4))
		Juice.nudge(top_bar)
	if events.pending_planet >= 0:
		var sp = Juice.planet_screen(map, events.pending_planet)
		if sp != null:
			Juice.ping(self, sp, Ui.col("signal_bad"))

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
	_dismiss_event_notice()
	event_notice = load("res://game/event_notice.gd").new()
	add_child(event_notice)
	event_notice.show_event(StoryText.get_text(title_id, args), StoryText.get_text(body_id, args), "", [], StoryText.get_text("BTN_OK"))
	event_notice.confirmed.connect(func(_c: int):
		_dismiss_event_notice()
		_refresh()
		save_now())
	save_now()

func _on_event_confirmed(choice: int, id: String) -> void:
	if id == "EV20":
		map.hex_ring.show_ring(false)  # T110
	if choice >= 0:
		var choices: Array = events.choices_of(id)
		if choice < choices.size():
			events.schedule_follow(choices[choice], cycle)  # R1: a choice may schedule a later event
			var over := _apply_effect(id, events.choice_effect(choices[choice]))
			if typeof(choices[choice]) == TYPE_DICTIONARY and choices[choice].has("popup_id"):
				_debris_popup(choices[choice], over)
				return
	events.pending_id = ""
	_dismiss_event_notice()
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

## Sets the A1 gate input: two routes made (A1 gate, owner decision 2026-11-03).
func debug_set_a1_gate(open: bool) -> void:
	if not OS.is_debug_build():
		return
	if open:
		for i in mini(3, map.planets.size()):
			if not pts_planets.has(i):
				pts_planets.append(i)
		for k in ["0-1", "0-2"]:
			if not pts_pairs.has(k):
				pts_pairs.append(k)
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
	if OS.is_debug_build() and galaxy_view != null and not galaxy_view.visible:
		galaxy_view.open_view()

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
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE and (not sell_offer.is_empty() or not pending.is_empty()):
		cancel_chain()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if game_over:
			return
		if galaxy_view.visible:
			galaxy_view.close_view()
		elif skill_screen.visible:
			skill_screen.close_screen()
		elif space_storage_view.visible:
			space_storage_view.close_view()
		elif cluster_info != null and cluster_info.visible:
			_hide_cluster_info()
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
	bar.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(bar)
	top_bar = bar
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	bar.add_child(box)
	# top left: the menu icon (opens the same menu as Esc)
	menu_button = Button.new()
	menu_button.theme_type_variation = "ButtonGhost"
	menu_button.icon = Ui.icon("mark")
	menu_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_button.add_theme_constant_override("icon_max_width", 24)
	menu_button.custom_minimum_size = Vector2(40, 40)
	menu_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	menu_button.tooltip_text = StoryText.get_or("BTN_MENU", "Menu") + " (Esc)"
	menu_button.pressed.connect(game_menu_toggle)
	box.add_child(menu_button)
	# cash with a muted per-cycle delta (click opens the forecast)
	cash_box = HBoxContainer.new()
	cash_box.add_theme_constant_override("separation", 6)
	cash_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(cash_box)
	cash_box.add_child(_bar_icon("cash"))
	cash_label = Label.new()
	cash_label.theme_type_variation = "LabelNumber"
	cash_box.add_child(cash_label)
	delta_label = Label.new()
	delta_label.theme_type_variation = "LabelNumberMuted"
	cash_box.add_child(delta_label)
	# goal: takes the free space and shortens if the window is narrow
	goal_label = Label.new()
	goal_label.theme_type_variation = "LabelMuted"
	goal_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	goal_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	goal_label.clip_text = true
	goal_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(goal_label)
	# expansion points as an inline stat (expenses live in the cash popup)
	var pt := _stat_inline("skills", "LBL_SKILL_POINTS", "Skill points")
	points_label = pt[1]
	# the skill points figure is the button that opens Skills (K); a flat button lies over the row
	var sk := HBoxContainer.new()
	sk.add_theme_constant_override("separation", 4)
	sk.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	points_button = MarginContainer.new()
	points_button.add_child(pt[0])
	var hit := Button.new()
	hit.flat = true
	hit.focus_mode = Control.FOCUS_NONE
	hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hit.pressed.connect(toggle_skills)
	points_button.add_child(hit)
	points_hit = hit
	sk.add_child(points_button)
	sk.add_child(Ui.kbd("K"))
	box.add_child(sk)
	# cycle, progress, speed
	cycle_label = Label.new()
	cycle_label.theme_type_variation = "LabelNumber"
	cycle_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(cycle_label)
	progress = ProgressBar.new()
	progress.show_percentage = false
	progress.theme_type_variation = "ProgressBarThin"
	progress.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	progress.custom_minimum_size = Vector2(90, 3)
	progress.max_value = 1.0
	box.add_child(progress)
	_build_speed_buttons(box)
	# run state, top right: one icon, pause bars while running, play triangle while paused (click or Space)
	pause_button = Button.new()
	pause_button.theme_type_variation = "ButtonSmall"
	pause_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_button.add_theme_constant_override("icon_max_width", 16)
	pause_button.custom_minimum_size = Vector2(32, 32)
	pause_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pause_button.pressed.connect(toggle_pause)
	box.add_child(pause_button)
	_build_rail()
	_build_hud()

## Icon, caption and a number, inline in the top bar. Returns [row, number label].
func _stat_inline(icon_token: String, story_id: String, fallback: String) -> Array:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_bar_icon(icon_token))
	var cap := Label.new()
	cap.text = StoryText.get_or(story_id, fallback)
	cap.theme_type_variation = "LabelMuted"
	row.add_child(cap)
	var n := Label.new()
	n.theme_type_variation = "LabelNumber"
	row.add_child(n)
	return [row, n]

## Along the edges of the system screen, as in SystemView.html: system name top middle, key hints bottom left,
## route hints bottom middle. None of it takes map clicks.
func _build_hud() -> void:
	var head := VBoxContainer.new()
	head.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	head.grow_horizontal = Control.GROW_DIRECTION_BOTH
	head.offset_top = 76
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	system_label = Label.new()
	system_label.theme_type_variation = "LabelCaption"
	system_label.add_theme_font_size_override("font_size", 14)
	system_label.add_theme_color_override("font_color", Ui.col("ink_muted"))
	system_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	system_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(system_label)
	system_hint = Label.new()
	system_hint.theme_type_variation = "LabelSmall"
	system_hint.add_theme_color_override("font_color", Ui.col("ink_subtle"))
	system_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	system_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(system_hint)
	add_child(head)
	# key hints, bottom left
	var keys := HFlowContainer.new()
	keys.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	keys.grow_vertical = Control.GROW_DIRECTION_BEGIN
	keys.offset_left = 64  # leaves room for the navigation toggle
	keys.offset_bottom = -20
	keys.custom_minimum_size = Vector2(340, 0)
	keys.add_theme_constant_override("h_separation", 16)
	keys.add_theme_constant_override("v_separation", 8)
	keys.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hints := [
		[[], "KEY_ZOOM", "Wheel Zoom"],
		[["W", "A", "S", "D"], "KEY_PAN", "Pan"],
		[[], "KEY_ORBIT", "Right-drag Orbit"],
		[["K"], "MENU_SKILLS", "Skills"],
		[["Esc"], "KEY_MENU", "Menu"]]
	for h in hints:
		var item := HBoxContainer.new()
		item.add_theme_constant_override("separation", 6)
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for k in h[0]:
			item.add_child(Ui.kbd(str(k)))
		var l := Label.new()
		l.text = StoryText.get_or(str(h[1]), str(h[2]))
		l.theme_type_variation = "LabelSmall"
		l.add_theme_color_override("font_color", Ui.col("ink_subtle"))
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.add_child(l)
		keys.add_child(item)
	add_child(keys)
	nav_keys = keys
	# navigation toggle, bottom left: hides or shows the rail and key hints, map gets the full screen
	nav_toggle = Button.new()
	nav_toggle.theme_type_variation = "ButtonSmall"
	nav_toggle.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nav_toggle.add_theme_constant_override("icon_max_width", 16)
	nav_toggle.custom_minimum_size = Vector2(32, 32)
	nav_toggle.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	nav_toggle.grow_vertical = Control.GROW_DIRECTION_BEGIN
	nav_toggle.offset_left = 20
	nav_toggle.offset_bottom = -20
	nav_toggle.pressed.connect(toggle_navigation)
	add_child(nav_toggle)
	_apply_navigation()
	# route hints, bottom middle
	var legend: HBoxContainer = load("res://game/route_legend.gd").new()
	legend.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	legend.grow_horizontal = Control.GROW_DIRECTION_BOTH
	legend.grow_vertical = Control.GROW_DIRECTION_BEGIN
	legend.offset_bottom = -30
	add_child(legend)

func toggle_navigation() -> void:
	nav_hidden = not nav_hidden
	_apply_navigation()

func _apply_navigation() -> void:
	for n in [nav_rail, nav_keys]:
		if n == null:
			continue
		if nav_hidden:
			Juice.leave(n)
		else:
			Juice.enter(n)
	nav_toggle.icon = Ui.icon("chevron" if nav_hidden else "back")
	nav_toggle.tooltip_text = StoryText.get_or("BTN_NAV_SHOW", "Show navigation") if nav_hidden else StoryText.get_or("BTN_NAV_HIDE", "Hide navigation")

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
	nav_rail = rail
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	rail.add_child(col)
	galaxy_button = _rail_button("planet", "MENU_GALAXY", "Galaxy", toggle_galaxy) 
	col.add_child(galaxy_button)  # always shown: the galaxy view also lists locked systems as uncharted

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
	goal_label.tooltip_text = ""
	if second_lane_active():  # N11: the optional line follows the goal; the full text is also the tooltip
		goal_label.tooltip_text = goal_label.text + "  " + second_lane_line()
		goal_label.text = goal_label.tooltip_text
	Juice.count_to(cash_label, cash, "%d", Ui.col("signal_good"))  # counts up; a rise flashes green
	var net: int = cash_forecast.net_forecast() if cash_forecast != null else 0
	delta_label.text = "%+d" % net
	cycle_label.text = "%d / %d" % [cycle, int(balance.get("win_cycle", 0))]
	cycle_label.tooltip_text = "Cycle"
	progress.value = cycle_elapsed / _cycle_seconds()
	pause_button.text = ""  # icon only (owner item 1)
	pause_button.disabled = game_over
	pause_button.tooltip_text = (StoryText.get_or("MENU_RESUME", "Resume") if paused else StoryText.get_or("MENU_PAUSE", "Pause")) + " (Space)"
	pause_button.icon = Ui.icon("play" if paused else "pause")
	pause_button.modulate = Ui.col("signal_warn") if paused else Color.WHITE
	for i in speed_buttons.size():
		speed_buttons[i].button_pressed = SPEEDS[i] == time_speed
	var star := " *" if SkillTree.any_affordable(learned_skills, skill_points, balance, skill_ctx()) else ""
	points_hit.tooltip_text = StoryText.get_text("MENU_SKILLS") + star
	points_button.modulate = Ui.col("star_warm") if star != "" else Color.WHITE
	if _last_points >= 0 and skill_points != _last_points:
		Juice.pop(points_label)  # points earned or spent: a small swell beside the count
	_last_points = skill_points
	Juice.count_to(points_label, skill_points, "%d", Ui.col("star_warm"))  # counts up (warm flash) and down when spent
	var sid: int = view_system
	var n_pl := 0
	for q in map.planets:
		if int(q.get("system", 1)) == sid:
			n_pl += 1
	system_label.text = Systems.name_of(sid).to_upper()
	system_hint.text = StoryText.get_or("LBL_SYSTEM_HINT", "System {n} · {count} planets", {"n": sid, "count": n_pl})
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
		mission_label.text = StoryText.get_or("LBL_MISSION_FIRST", "Mission: Send stock to another planet")

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
	if tut_actions != null:  # Skip and Next only while the guided steps run
		tut_actions.visible = tutorial_label.visible and tut_step < TUT_GUIDE.size()
		if tut_step < TUT_GUIDE.size():
			tut_next.text = StoryText.get_or("BTN_GOT_IT", "Got it") if tut_step == TUT_GUIDE.size() - 1 else StoryText.get_or("BTN_NEXT", "Next")

## Next steps the guided hint on by one line; Skip closes it. Same buttons and wording as the galaxy view tutorial.
func _tut_next() -> void:
	if tut_step < TUT_GUIDE.size():
		tut_step += 1
		_tut_show([])

func _tut_skip() -> void:
	tut_step = TUT_GUIDE.size()
	_tut_show([])

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
	scroll.offset_left = -(20.0 + 320.0 + 16.0)
	scroll.offset_right = -20
	scroll.offset_top = 76  # below the top bar, as in the design pack
	scroll.offset_bottom = -(20.0 + 56.0 + 12.0)  # above the run state card
	add_child(scroll)
	right_col = VBoxContainer.new()
	right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.add_theme_constant_override("separation", 12)
	scroll.add_child(right_col)
	var board := PanelContainer.new()
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.custom_minimum_size = Vector2(320, 0)
	right_col.add_child(board)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	board.add_child(box)
	var title := Label.new()
	title.text = StoryText.get_or("LBL_NOTIFICATIONS", "Notifications").to_upper()
	title.theme_type_variation = "LabelCaption"
	box.add_child(title)
	mission_label = Label.new()
	mission_label.text = StoryText.get_or("LBL_MISSION_FIRST", "Mission: Send stock to another planet")
	mission_label.theme_type_variation = "LabelAccent"
	mission_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(mission_label)
	tutorial_label = Label.new()
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_label.theme_type_variation = "LabelInfo"
	tutorial_label.visible = false
	box.add_child(tutorial_label)
	tut_actions = HBoxContainer.new()
	tut_actions.alignment = BoxContainer.ALIGNMENT_END
	tut_actions.add_theme_constant_override("separation", 8)
	tut_actions.visible = false
	var tut_skip := Button.new()
	tut_skip.theme_type_variation = "ButtonGhost"
	tut_skip.text = StoryText.get_or("SCR_PREFACE_SKIP", "Skip")
	tut_skip.pressed.connect(_tut_skip)
	tut_actions.add_child(tut_skip)
	tut_next = Button.new()
	tut_next.theme_type_variation = "ButtonPrimary"
	tut_next.text = StoryText.get_or("BTN_NEXT", "Next")
	tut_next.pressed.connect(_tut_next)
	tut_actions.add_child(tut_next)
	box.add_child(tut_actions)
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
