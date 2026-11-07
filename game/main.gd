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
## The single place QA listens to. side is "WIN", "LOSS" or "SOFT"; ending_id is the END_* id.
signal run_ended(side: String, ending_id: String)

const BALANCE_PATH := "res://data/balance.json"
const SaveGame := preload("res://game/save_game.gd")
const Trade := preload("res://game/trade.gd")
const RouteEngine := preload("res://game/route_engine.gd")
const Storage := preload("res://game/storage.gd")
const StoryText := preload("res://game/story_text.gd")
const SkillTree := preload("res://game/skill_tree.gd")
const Events := preload("res://game/events.gd")
const Ships := preload("res://game/ships.gd")
const Ceos := preload("res://game/ceos.gd")
const PathfinderView := preload("res://game/pathfinder_view.gd")  # T180 flight accessor helpers
const RivalShips := preload("res://game/rival_ships.gd")  # T187
const Pathfinder := preload("res://game/pathfinder.gd")  # T179 the scout ship: flight, discovery, posts and platforms
const Systems := preload("res://game/systems.gd")
const Clusters := preload("res://game/clusters.gd")
const DeadWorlds := preload("res://game/dead_worlds.gd")
const Fabric := preload("res://game/fabric.gd")
const WorkshopsScript := preload("res://game/workshops.gd")
const CompanyNames := preload("res://game/company_names.gd")
const CompanyPortraits := preload("res://game/company_portraits.gd")

var balance: Dictionary = {}
var company_name: String = ""  # chosen on the new company screen, saved
var ceo_portrait: String = ""  # id from company_portraits.gd, saved
var ceo_id: String = ""  # CEO of the run (data/ceos.json, = a portrait id); "" = none (old saves), saved
var branch: String = ""  # market id (mil, lux, min, bio) fixed by the CEO at the start; saved as run.branch; "" = old save
var ship_type: String = "small"  # ship type of every ship of the run (data/ships.json), saved
var cash: int = 0
var cycle: int = 1          # current cycle, 1-based
var storage_notice_done: bool = false  # the Space Storage availability notice was made this run (saved)
var trade_income_total: int = 0  # cumulative gross trade income this run (gates Space Storage), saved
var cycle_elapsed: float = 0.0  # seconds into current cycle
var debug_force_event: bool = false  # T13: debug-only, fire a random event at the next cycle start, then clears
var run_recorded: bool = false  # T78: a run is recorded once
var free_play: bool = false  # T259: after any ending the player chose Continue: no further endings, saved
var time_speed: float = 1.0  # clock multiplier chosen in the top bar (1, 2, 6 or 12); saved, sticky until changed
const SPEEDS := [1.0, 2.0, 6.0, 12.0]
var speed_buttons: Array = []
var paused: bool = true  # T23: game starts paused after the preface
var game_over: bool = false
var rescues_paid: int = 0  # Four Markets: stranded stipends paid this run (capped by rescue_max), saved
var repossessions: int = 0  # ships repossessed this run, saved
var repossessed_cycle: int = -1  # cycle of the last repossession (no stipend in that cycle)
var end_screen: ColorRect  # T77 overlay, null when none
## Learned skill ids (FND_STORAGE, MIL_1 ... finished techs included), saved. The array is Skills.learned itself: appending
## or assigning here changes the real set (the setter copies into it).
var learned_skills: Array:
	get:
		return Skills.learned
	set(v):
		Skills.set_learned(v.duplicate())
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
const ASTEROID_REWARD_POINTS := 1  # T109: EV20_PAID gives one expansion point (no balance key)
var asteroid_last_hit: int = -1  # T109: planet hit by the last asteroid (-1 none), runtime only
var dock_sheet: ColorRect  # T270 dock sheet (game/dock_sheet.gd), null when closed
var _dock_was_paused := false
var _dock_after := ""  # T270: planet id of a 'Dock and trade' order still in flight
var event_notice: ColorRect  # T12 event window (opened from an icon), null when none
var event_icons: HBoxContainer  # strip of event icons (game/event_icons.gd)
var _event_pause_held := false  # the open event window holds the pause
var _event_prev_paused := false  # pause state to restore when it closes
var _event_hint_planet := -1
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
var rival_ships: Node3D  # T187 rival ships flying on the map, visual only (game/rival_ships.gd)
var _action_menu: PopupMenu  # T200: right-click menu of the selected ship
var flight: RefCounted  # T179 the Pathfinder (game/pathfinder.gd); the map reads it as map.flight; saved under "pathfinder"
var planet_panel: PanelContainer
var cluster_info: PanelContainer  # T159: info card of the asteroid cluster clicked on the map
var cluster_info_index: int = -1
var goal_label: Label
var bazaar_panel: PanelContainer  # T263 the Bazaar panel (M, rail button)
var next_up: HBoxContainer  # T263 the Next Up strip in the top bar
var bazaar_button: Button
var gig_panel: PanelContainer  # T273 the gig board (J, rail button)
var gig_button: Button
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
var tutorial_label: Label  # the current step's line on the floating tutorial card
var tip_label: Label  # game tip on the right board
var tut_arrow: Polygon2D  # pointer from the card to the target
var tut_actions: HBoxContainer  # Skip only: every guided step moves on by the player's own action
var tut_card: PanelContainer  # the guided tutorial card: floats beside the control the step is about
var tut_count: Label  # "2 of 10"
var tut_why: Label  # the step's why line (story id <step id>_WHY), hidden when the story has none
var tut_hl: Panel  # pulsing accent outline over the control the current step is about
var tut_first: Dictionary = {}  # T15: one-time triggers already used this session
var tut_show_count := 0  # card rebuilds, for tests
var _tut_lock_seen := -1  # lock step the panels were last drawn for
var _tut_sig: Array = []  # last state the card was built from
var _voiced_tut := -1  # guided step last spoken
## T124 guided first steps: index into TUT_GUIDE; TUT_GUIDE.size() means done. Saved.
const TUT_GUIDE := ["TUT_G1_SELECT", "TUT_G2_BUY", "TUT_G3_SEND", "TUT_G4_ROUTE_PAY", "TUT_G5_UPKEEP", "TUT_G6_SELL", "TUT_G7_STORAGE", "TUT_G8_SKILLS", "TUT_G9_PERMIT", "TUT_G10_DONE"]
## Old saves (no tut_ver) counted 6 steps: select, buy, send, sell, skills, done. Old index -> new index.
const TUT_OLD_MAP := [0, 1, 2, 5, 7, 9]
const TUT_VER := 2
## English fallbacks until the story text ids exist in the story files.
const TUT_FALLBACK := {
	"TUT_G3_PICK": "Click the planet that wants the good.",
	"TUT_G4_ROUTE_PAY": "A route earns when its goods sell at the destination. Wait for the cycle to end and watch your cash.",
	"TUT_G5_UPKEEP": "Each ship has upkeep every cycle. It is listed under Expenses.",
	"TUT_G6_SELL": "Turn Sell on at the other planet. The company sells what arrives, at that planet's price.",
	"TUT_G7_STORAGE": "Company storage holds your stock at each planet. When it is full, Buy waits until there is room.",
	"TUT_G8_SKILLS": "Skill points come from planets, routes and systems. Open Skills and learn one.",
	"TUT_G9_PERMIT": "The Permit Charter lets you open a new system. Learn it when you are ready to expand.",
	"TUT_G10_DONE": "That is the loop: buy, move, sell, learn. The guidance stops here.",
}
var tut_step: int = 0
var tut_flags: Dictionary = {}  # actions seen this session: "expenses" (forecast opened), "storage" (resource button right-clicked)
var tut_goal_t: float = 0.0  # real seconds the last guided step has been shown
const TUT_LAST_SECS := 12.0
var tut_skipped: Array = []  # ids of guided steps passed over automatically (their state was never reached)
var trade: RefCounted = Trade.new()  # price/margin logic for T07
var commodities: Array = []
var storage: RefCounted = Storage.new()  # T55 planet stock
var storage_link: RefCounted = preload("res://game/storage_link.gd").new()  # T171: links between Space Storages
var engine: RefCounted = RouteEngine.new()  # T07 route records and math
var workshops: RefCounted = WorkshopsScript.new()  # smelter, munitions, atelier, culture lab; saved under "workshops"
var fabric: RefCounted = Fabric.new()  # the fabric at the trading post, saved under "fabric"
var prosperity: Prosperity = Prosperity.new()  # T256 world tiers and needs, saved under "prosperity"
var hubs: Hubs = Hubs.new()  # T289 hubs keep neighbours fed, saved under "hubs"
var raids: Raids = Raids.new()  # T296 raids from unreclaimed dead worlds, saved under "raids"
var gigs: Gigs = Gigs.new()  # T271 the gig board (signals, rush orders), saved under "gigs"
var bazaar: Bazaar = Bazaar.new()  # T259 the Star Bazaar: capital, stages, saved under "bazaar"
var dead: RefCounted = DeadWorlds.new()  # dead worlds: danger meter per planet id, saved under "danger"
var clusters: RefCounted = Clusters.new()  # T156 asteroid clusters (ore sources), saved
var notice_label: Label
var last_notice: String = ""
var last_summary: String = ""  # T69: gross, upkeep, net of the last cycle
var last_rescue_cycle: int = -1  # T95: at most one rescue per cycle
var prev_net: int = 0  # net of the cycle before last_net (rescue needs 2 flat cycles)
var last_net: int = 0  # net credits of the last settled cycle (stranded check: a route that pays nothing is not healthy)
var notice_ends_left: int = 0  # cycle ends until the board notice is cleared
var debug_menu: PanelContainer  # T33: null in release builds; T34 adds its button via debug_menu.add_tool()
var selected_planet: int = -1
var pending: Dictionary = {}  # T68: "Send to..." waiting for a destination {planet, c}; empty when none
var pending_label: Label
var route_warning: Control
var dest_hint: Control
var rival_card: Control  # T199
var sell_offer: Dictionary = {}  # after a Send: {planet, c} while "Sell here too?" is offered at the destination; empty when none
var pending_margins: Label  # P1: per-destination margins while a plain Send to... is pending
var last_local: Array = []  # T68: local order results of the last cycle end
var income_popup: Control  # T133 green +N above planets
var mission_planet: int = -1  # planet that sells the first ship (abundant energy, scarce food)

func _ready() -> void:
	Ui.install_cursors(get_tree())
	Juice.install_press(get_tree())
	balance = _load_balance()
	Availability.bind(self)  # data/availability.json decides what the UI shows (game/availability.gd)
	cash = int(balance.get("starting_credits", 0))
	Skills.reset(balance)  # four market skills: new run; a loaded save overwrites it
	Tech.reset()
	Markets.reset(balance, Markets.default_seed())  # Four Markets: new run; a loaded save overwrites it
	Chains.reset(balance, Markets.run_seed)  # event chains: new run (shuffle seed from the run seed); a loaded save overwrites it
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # let clicks reach the 3D map (T04)
	map = load("res://game/map.gd").new()
	add_child(map)  # T20 map, added before UI so the bar draws on top
	rival_ships = RivalShips.new()  # T187: scenery ships, a visual only
	rival_ships.setup(self, map)
	map.add_child(rival_ships)
	map.rivals = rival_ships  # T199
	flight = Pathfinder.new()  # T179: needs the map's planets; discovery_enabled in balance.json switches it on or off live
	flight.setup(self)
	map.flight = flight
	flight.arrived.connect(_on_flight_arrived)
	flight.build_done.connect(_on_flight_build_done)
	flight.build_cancelled.connect(_on_flight_build_cancelled)
	flight.establish_failed.connect(_on_flight_establish_failed)  # T200
	flight.exploration_done.connect(_on_exploration_done)  # T206
	events.established_fn = Callable(self, "planet_established")
	events.need_fn = func(pl: int, g: String) -> bool: return prosperity != null and prosperity.is_need(pl, g)  # T280
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
	planet_panel.mine_requested.connect(begin_buy_and_send)
	planet_panel.remove_requested.connect(_remove_requested)
	planet_panel.found_bazaar_requested.connect(_on_found_bazaar)  # T262
	map.planet_clicked.connect(_on_planet_clicked)
	map.route_clicked.connect(_on_route_clicked)
	map.cluster_clicked.connect(_on_cluster_clicked)  # T159
	map.station_clicked.connect(_on_station_clicked)
	map.fly_requested.connect(_on_fly_requested)  # T180: both do nothing while map.flight is null or off
	map.establish_requested.connect(_on_establish_requested)
	map.action_menu_requested.connect(_on_action_menu_requested)  # T200
	map.fly_establish_requested.connect(_on_fly_establish_requested)
	_build_board()
	_build_pending_label()
	route_warning = load("res://game/route_warning.gd").new()  # red line + cursor warning when no ship can be bought
	add_child(route_warning)
	route_warning.setup(self)
	dest_hint = load("res://game/dest_hint.gd").new()  # hover card over a destination while a route is pending
	add_child(dest_hint)
	dest_hint.setup(self)
	rival_card = load("res://game/rival_card.gd").new()  # T199: click card of a rival ship
	add_child(rival_card)
	rival_card.setup(self)
	income_popup = load("res://game/income_popup.gd").new()  # T133
	add_child(income_popup)
	income_popup.setup(map)
	ship_panel = load("res://game/ship_panel.gd").new()
	right_col.add_child(ship_panel)
	ship_panel.buy_requested.connect(_buy_ship_kind)
	ship_panel.boost_toggled.connect(set_flagship_boost)  # T270
	ship_panel.explore_toggled.connect(func(): set_exploring(not flight.exploring()))  # T206
	mission_planet = _find_mission_planet()
	commodities = _commodities(map.planets)
	trade.setup(balance, map.planets)
	events.setup(balance, map.planets)
	trade.events = events
	storage.setup(balance, map.planets.size(), commodities)
	storage_link.setup(balance, storage, self)
	if not storage_link.link_notice.is_connected(_on_link_notice):
		storage_link.link_notice.connect(_on_link_notice)
	engine.setup(balance, trade, commodities, storage)
	clusters.setup(balance)  # T156
	dead.setup(balance)
	prosperity.setup(balance, map.planets, func(pid: String) -> bool: return flight != null and flight.established(pid))
	engine.prosperity = prosperity
	prosperity.weather = events  # T280: shortages change demand and hunger
	bazaar.setup(self)  # T259
	hubs.setup(balance, engine, prosperity, trade, storage)  # T289
	hubs.owned_ships_fn = func() -> int: return ships
	gigs.setup(self)  # T271
	gigs.arrival.connect(_on_gig_arrival)
	raids.setup(self)  # T296
	if not raids.hit.is_connected(_on_raid_hit):
		raids.hit.connect(_on_raid_hit)  # T300 juice
	if not gigs.scooped.is_connected(_on_salvage_scooped):
		gigs.scooped.connect(_on_salvage_scooped)  # T300 juice
	engine.raids = raids
	map.prosperity = prosperity  # T264 growth ring and need icons
	map.events = events  # T285 weather chips
	if not prosperity.reclaimed.is_connected(_on_prosperity_reclaimed):
		prosperity.reclaimed.connect(_on_prosperity_reclaimed)
	if not prosperity.tier_up.is_connected(_on_prosperity_tier_up):
		prosperity.tier_up.connect(_on_prosperity_tier_up)
	if not bazaar.stage_done.is_connected(_on_bazaar_stage_done):
		bazaar.stage_done.connect(_on_bazaar_stage_done)
	if not bazaar.wing_offered.is_connected(_on_bazaar_wing_offered):
		bazaar.wing_offered.connect(_on_bazaar_wing_offered)
	if not bazaar.opening_ready.is_connected(_on_bazaar_opening_ready):
		bazaar.opening_ready.connect(_on_bazaar_opening_ready)
	fabric.setup(balance)
	workshops.setup(balance)
	engine.clusters = clusters
	engine.dead_worlds = dead  # T295
	engine.trade_gate = Callable(self, "system_trade_open")
	engine.upkeep_out = func(k: String, g: String, have: int) -> int: return storage_link.upkeep_drain(k, g, have)
	engine.positions_fn = func() -> Array: return map.positions  # route offset: planet world positions
	engine.suns_fn = func() -> Array: return map.sun_list()  # route offset: the suns are obstacles
	_sync_closed()  # dead worlds still shut, worlds without a post or platform closed (T179)
	cash_forecast = load("res://game/cash_forecast.gd").new()  # T40: money text dropdown
	add_child(cash_forecast)
	cash_forecast.setup(self, cash_box)
	skill_screen = load("res://game/skill_screen.gd").new()
	add_child(skill_screen)
	skill_screen.setup(self)
	bazaar_panel = load("res://game/bazaar_panel.gd").new()  # T263
	add_child(bazaar_panel)
	bazaar_panel.setup(self)
	gig_panel = load("res://game/gig_board.gd").new()  # T273
	add_child(gig_panel)
	gig_panel.setup(self)
	for n in [tut_card, tut_arrow]:  # above the Skills window (the permit step points into it), below menus and popups
		move_child(n, skill_screen.get_index() + 1)
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
		company_name = SaveGame.pending_company.strip_edges().left(CompanyNames.MAX_LEN) if SaveGame.pending_company.strip_edges() != "" else CompanyNames.generate()
		ceo_portrait = CompanyPortraits.normalize(SaveGame.pending_portrait)
		_set_run_choice(SaveGame.pending_ceo if SaveGame.pending_ceo != "" else SaveGame.pending_portrait, SaveGame.pending_ship, SaveGame.pending_branch if SaveGame.pending_branch != "" else Ceos.branch(SaveGame.pending_ceo if SaveGame.pending_ceo != "" else SaveGame.pending_portrait))
		SaveGame.pending_company = ""
		SaveGame.pending_portrait = ""
		SaveGame.pending_ceo = ""
		SaveGame.pending_ship = ""
		SaveGame.pending_branch = ""
		_quiet_points = true
		_award_planet(maxi(mission_planet, 0))  # T82: the home planet counts at start
		_quiet_points = false
		_build_preface()
		_tut_show()
		_tut_cycle()
	else:
		apply_state(saved)  # T26: resume paused, no preface
		post_notice(StoryText.get_text("NOT_LOADED"))
		_tut_cycle()
	SaveGame.pending_company = ""  # the ship screen choices are used once, on a new game or not
	SaveGame.pending_portrait = ""
	SaveGame.pending_ceo = ""
	SaveGame.pending_ship = ""
	SaveGame.pending_branch = ""
	if debug_tools_allowed() and ResourceLoader.exists("res://game/debug_menu.gd"):  # T33: never in release exports (B9: the script is also left out of the export)
		debug_menu = load("res://game/debug_menu.gd").new()
		add_child(debug_menu)
		debug_menu.setup(self)
		debug_menu.add_next_cycle_button()
		debug_menu.add_routes_dump()
		debug_menu.add_stats_path()
		debug_menu.add_event_trigger()
		debug_menu.add_qa_tools()  # T13
	_push_routes_to_map()
	_refresh()

## CEO and ship type of the run. Unknown or empty ids: no CEO, small ship.
func _set_run_choice(ceo: String, ship: String, branch_id: String = "") -> void:
	ceo_id = ceo if Ceos.has(ceo) else ""
	Markets._ensure()
	branch = branch_id if Markets.ids.has(branch_id) else ""
	SkillTree.run_branch = branch
	ship_type = Ships.normalize(ship)
	Ceos.set_current(ceo_id)
	Ships.set_fleet(ship_type)

## Branch of the run: the market id fixed by the CEO ("" for an old save without one).
func run_branch() -> String:
	return branch

## Ship limit of this run: balance ship_cap plus the cap_add of the ship type.
func ship_cap() -> int:
	return Ships.cap(balance)

## Price of the next ship: ship_price x price_mult of the ship type.
func ship_price() -> int:
	return Ships.price(Ships.fleet, balance)

## T26: state written to the autosave. Add new keys here (see save_game.gd).
## Tuning values from balance.json are never saved.
func collect_state() -> Dictionary:
	return {"company_name": company_name, "ceo_portrait": ceo_portrait, "ceo_id": ceo_id, "ship_type": ship_type, "run": {"branch": branch}, "cycle": cycle, "trade_income_total": trade_income_total, "storage_notice_done": storage_notice_done, "cycle_elapsed": cycle_elapsed, "cash": cash, "paused": paused, "ships": ships,
		"routes": engine.to_array(), "storage": storage.to_dict(), "orders": engine.local_to_array(),
		"markets": Markets.to_dict(), "rescues_paid": rescues_paid, "repossessions": repossessions, "learned_skills": learned_skills.duplicate(), "skills": Skills.to_dict(), "tech": Tech.to_dict(), "systems_reached": systems_reached,
		"time_speed": time_speed, "skill_points": skill_points, "pts_planets": pts_planets, "pts_pairs": pts_pairs, "events": events.to_dict(),
			"open_systems": open_systems, "reached_ids": reached_ids, "galaxy_seen": galaxy_seen, "tut_step": tut_step, "tut_ver": TUT_VER,
		"chains": Chains.to_dict(), "storage_cuts": storage.cuts_to_dict(), "price_history": price_history,
		"forecast_id": forecast_id, "forecast_slot": forecast_slot, "forecast_noted": forecast_noted, "station_systems": station_systems,
		"second_lane": second_lane_planet, "clusters": clusters.to_dict(), "danger": dead.to_dict(), "dead_mining": dead.state_to_dict(), "fabric": fabric.to_dict(), "workshops": workshops.to_dict(),
			"pathfinder": flight.to_dict(), "storage_links": storage_link.to_array(), "prosperity": prosperity.to_dict(), "bazaar": bazaar.to_dict(), "gigs": gigs.to_dict(), "hubs": hubs.to_array(), "raids": raids.to_dict(), "free_play": free_play}

func apply_state(s: Dictionary) -> void:
	_loading_state = true
	company_name = str(s.get("company_name", "")).strip_edges().left(CompanyNames.MAX_LEN)  # old saves: no company yet
	if company_name == "":
		company_name = CompanyNames.generate()
	ceo_portrait = CompanyPortraits.normalize(str(s.get("ceo_portrait", "")))
	_set_run_choice(str(s.get("ceo_id", "")), str(s.get("ship_type", "")), str(s.get("run", {}).get("branch", "")) if typeof(s.get("run")) == TYPE_DICTIONARY else "")  # old saves: small ship, no CEO
	map.clear_stations()
	for m in station_markers.values():
		m.queue_free()
	station_markers.clear()
	station_systems = []
	storage.cuts_from_dict(s.get("storage_cuts"))  # T109: old saves: no cuts
	for sid in _int_array(s.get("open_systems")):  # T85: permitted systems first, so planet indexes exist for routes
		if sid > 1 and Systems.ids().has(sid):
			_open_system(sid)
	reached_ids = _int_array(s.get("reached_ids"))
	galaxy_seen = bool(s.get("galaxy_seen", false))
	if not s.has("tut_step"):  # no saved step: guided tutorial starts in cycles 1 to 4, stays finished later
		tut_step = 0 if int(s.get("cycle", 1)) <= 4 else TUT_GUIDE.size()
	else:
		tut_step = int(s["tut_step"])
		if int(s.get("tut_ver", 1)) < TUT_VER:  # old numbering: map to the new steps
			tut_step = TUT_OLD_MAP[maxi(0, tut_step)] if tut_step < TUT_OLD_MAP.size() else TUT_GUIDE.size()
	tut_step = clampi(tut_step, 0, TUT_GUIDE.size())
	cycle = maxi(1, int(s.get("cycle", 1)))
	trade_income_total = maxi(0, int(s.get("trade_income_total", 0)))  # old saves: 0, earned again
	_sync_earn()
	storage_notice_done = bool(s.get("storage_notice_done", trade_income_total >= int(balance.get("earn_storage_income", 2000))))  # old saves: no notice for an already earned line
	Markets.from_dict(s.get("markets"), balance)
	Chains.from_dict(s.get("chains"), balance)  # a v3 save has no chain state: fresh
	Chains.now = cycle
	rescues_paid = int(s.get("rescues_paid", 0))
	repossessions = int(s.get("repossessions", 0))
	cycle_elapsed = clampf(float(s.get("cycle_elapsed", 0.0)), 0.0, _cycle_seconds())
	time_speed = _speed_or_default(s.get("time_speed", 1.0))  # old saves: x1
	cash = int(s.get("cash", cash))
	ships = clampi(int(s.get("ships", 0)), 0, ship_cap())
	Skills.reset(balance)
	if typeof(s.get("learned_skills")) == TYPE_ARRAY:
		learned_skills = s["learned_skills"]  # unknown ids are dropped by the setter
	Skills.from_dict(s.get("skills"))
	Tech.from_dict(s.get("tech"))
	# Saves without a skills key start with none: Space Storage must be earned via FND_STORAGE.
	_sync_skill_effects()
	_sync_dead_lock()  # dead worlds still shut at this cycle: saved routes and orders to them are dropped
	clusters.from_dict(s.get("clusters"))  # T156: before the routes, which may start at a cluster; old saves: all full
	engine.from_array(s.get("routes", []), ships)  # old saves: no key = zero routes
	storage.from_dict(s.get("storage"), map.planets.size())  # old saves: fresh stock
	engine.local_from_array(s.get("orders"))  # old saves: no local orders
	# T51: old saves may hold cargo, ship_planet, dest, flight_left, mission_step; ignored.
	price_history = s.get("price_history", {}) if typeof(s.get("price_history")) == TYPE_DICTIONARY else {}
	forecast_id = str(s.get("forecast_id", ""))
	forecast_slot = int(s.get("forecast_slot", 0))
	forecast_noted = bool(s.get("forecast_noted", true))
	second_lane_planet = int(s.get("second_lane", -1))  # N11; old saves: not reached
	if second_lane_planet >= map.planets.size() or (second_lane_planet >= 0 and system_of(second_lane_planet) != SECOND_LANE_SYSTEM):
		second_lane_planet = -1
	for sid in _int_array(s.get("station_systems")):  # saved stations come back without the build-in or notice
		if not station_systems.has(sid) and _system_planets_present(sid):
			station_systems.append(sid)
			map.add_station(sid, false)
			_make_station_marker(sid)
	_ensure_posts()  # old saves with FND_STORAGE: stations for every open system, no notice
	storage_link.from_array(s.get("storage_links"))  # T171; old saves: no links
	prosperity.from_dict(s.get("prosperity"))  # T256; old saves: established worlds at tier 1
	bazaar.from_dict(s.get("bazaar"))  # T259; old saves: nothing founded
	free_play = bool(s.get("free_play", false))
	if typeof(s.get("prosperity")) != TYPE_DICTIONARY or not s["prosperity"].has("reached"):
		prosperity.claim_new_tiers()  # T258: a save from before tier rewards gets no back pay
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
	dead.state_from_dict(s.get("dead_mining"))  # T295; old saves: full stock, normal intensity
	fabric.from_dict(s.get("fabric"))  # old saves: not built
	workshops.from_dict(s.get("workshops"))
	flight.from_dict(s.get("pathfinder"))  # T179: a save without it (from before discovery) opens every planet
	raids.from_dict(s.get("raids"))  # T296; old saves: nothing active
	gigs.from_dict(s.get("gigs"))  # T271; old saves: empty board
	gigs.ensure_opening()  # T298: an Opening still to fly is on the board
	if bazaar.wing_pending > 0 and bazaar_panel != null:
		bazaar_panel.show_wing_choice.call_deferred()  # T299: a wing choice left open when the save was made
	hubs.from_array(s.get("hubs"))  # T289; old saves: no hubs
	flight.resync(game_time())
	_sync_closed()
	_refresh_event_feed()
	paused = true  # always resume paused
	_dismiss_event_notice()
	_release_event_pause()
	while event_icons != null and event_icons.count() > 0:
		event_icons.remove_icon(str(event_icons.entries[0]["id"]))
	if events.pending_id != "":  # an unanswered important event comes back as its icon (effects already applied unless a choice)
		_add_event_icon(events.pending_id, false)

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
		map.add_planets(Systems.planets_of(id))  # T101: habitable flag
		added = true
		var all_goods := _commodities(map.planets)  # a system can bring a good (nullglass): add it in place, the engine and storage share this array
		for c in all_goods:
			if not commodities.has(c):
				commodities.append(c)
	_ensure_posts()
	_sync_closed()  # T179: the new planets are closed until a post or platform stands
	return added

func _system_planets_present(id: int) -> bool:
	for p in map.planets:
		if int(p.get("system", 1)) == id:
			return true
	return false

## Space Storage post: one per open system, exists once skill FND_STORAGE is learned.
func _ensure_posts() -> void:
	if not Availability.storage("space_storage"):
		return
	for sid in open_systems:
		storage.ensure(Storage.system_key(int(sid)))
	_ensure_stations()

## Space stations: one per open system once FND_STORAGE is learned; built once, kept in station_systems (saved).
## One notice per build, none while a save loads.
func _ensure_stations() -> void:
	if not Availability.storage("space_storage"):
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
	selected_planet = -1  # one view at a time: the planet panel and its selection give way to Space Storage
	planet_panel.visible = false
	space_storage_view.open_for(sid)

func space_post_open(system_id: int) -> bool:
	return Availability.storage("space_storage") and storage.established(Storage.system_key(system_id))

## Systems with a permit entry that is not bought yet.
func unowned_systems() -> Array:
	var out := []
	for sid in Systems.ids():
		if not open_systems.has(sid):
			out.append(sid)
	return out

## Owner 2026-11-03: trading in a system other than 1 needs that system's Space Storage post.
func system_trade_open(planet: int) -> bool:
	if not planet_established(planet):  # T179: a world with no post or platform
		return false
	var sid := system_of(planet)
	return sid == 1 or space_post_open(sid)

func trade_locked_reason() -> String:
	var t := StoryText.get_or("LBL_TRADE_NEEDS_STATION", "Needs a Space Storage in this system.")
	if not has_skill("FND_STORAGE"):  # QA 2026-11-03: the post comes with Space Storage; say so, a permit alone does not open trade
		t += " " + StoryText.get_or("LBL_TRADE_NEEDS_A1", "Learn Space Storage first.")
	return t

## Credit price of a permit: the data price (Colonial Rights is gone: no discount).
func permit_cost(sid: int) -> int:
	return Systems.permit_cost(balance, sid)

## N11 Second Lane: optional goal, the first sale at a planet of system 2. Saved as the planet index (-1 = not yet).
## Reads the permit price live. Pays a title and a planet note only: no cash, no points.
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

## Expansion points a permit costs: the data value.
func permit_points(sid: int) -> int:
	return Systems.permit_points(balance, sid)

## {ok, reason}; reason is "", "owned", "skill", "credits", "points", "over" or "unknown".
func can_buy_permit(sid: int) -> Dictionary:
	if not Systems.ids().has(sid):
		return {"ok": false, "reason": "unknown"}
	if game_over:
		return {"ok": false, "reason": "over"}
	if open_systems.has(sid):
		return {"ok": false, "reason": "owned"}
	if not has_skill(required_skill(sid)):
		return {"ok": false, "reason": "skill"}
	if cash < permit_cost(sid):
		return {"ok": false, "reason": "credits"}
	if skill_points < permit_points(sid):
		return {"ok": false, "reason": "points"}
	return {"ok": true, "reason": ""}

## Buys the permit: credits and expansion points, then the system's planets appear on the map.
func buy_permit(sid: int) -> Dictionary:
	if not tut_gate("other"):
		return {"ok": false, "reason": tut_lock_text()}
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

## Skill a system's permit needs: systems.json names it.
func required_skill(sid: int) -> String:
	return str(Systems.get_system(sid).get("requires_skill", "FND_PERMIT"))

## First order or route that touches a planet of a new system gives the system point (once per system).
func _note_system(planet: int) -> void:
	var sid := system_of(planet)
	if sid > 1 and not reached_ids.has(sid):
		reached_ids.append(sid)
		reach_system()

## Pushes trade income to SkillTree for the Space Storage earn lock.
func _sync_earn() -> void:
	SkillTree.earn_income = trade_income_total

## Once per run, when trade income first meets the Space Storage line (skill not learned): an important icon that stays
## until clicked. If another important icon is waiting, it is tried again next call (income and cycle start).
func _check_storage_ready() -> void:
	if storage_notice_done or game_over:
		return
	if learned_skills.has("FND_STORAGE"):
		storage_notice_done = true
		return
	if skill_lock_reason("FND_STORAGE") != "" or events.pending_id != "" or event_notice != null:
		return
	storage_notice_done = true
	events.pending_planet = -1
	events.pending_id = Events.NOTICE_STORAGE
	_add_event_icon(Events.NOTICE_STORAGE, false)
	save_now()

## Lock line for a skill ("" = free to learn), for the skill screen.
func skill_lock_reason(id: String) -> String:
	_sync_earn()
	return SkillTree.earn_lock_reason(balance, id)

## T71: learn a skill. Spends skill points, saves, posts the notice. Returns {ok, reason}.
func learn_skill(id: String) -> Dictionary:
	if not tut_gate("other"):
		return {"ok": false, "reason": tut_lock_text()}
	_sync_earn()
	var v := SkillTree.can_learn(learned_skills, skill_points, balance, id)
	if not v["ok"]:
		return v
	skill_points -= SkillTree.cost(balance, id)
	Skills.add_learned(id)
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

## Effect hook for ids: main.has_skill("FND_STORAGE"). Effect numbers stay in balance.json (see Skills).
func has_skill(id: String) -> bool:
	return Skills.is_learned(id)

## Posts the SK_TECH_DONE notice for every tech finished since the last call, and refreshes what the skills drive.
func _post_tech_done() -> void:
	var ids := Tech.take_done()
	for id in ids:
		post_notice(StoryText.get_text("SK_TECH_DONE", {"name": SkillTree.skill_name(str(id))}))
	if not ids.is_empty():
		_sync_skill_effects()
		_sync_closed()
		if skill_screen != null:
			skill_screen.refresh()

## Units crafted in a market's workshop count toward that market's techs (Tech.add_crafted), with the notice.
## Workshops call this; the debug menu has an action for testing.
func craft_units(market: String, units: int) -> void:
	Tech.add_crafted(market, units)
	_post_tech_done()

## Skill effects that live on other objects: storage_cap_pct (BIO_3) raises planet storage capacity.
func _sync_skill_effects() -> void:
	storage.capacity_mult = Skills.storage_cap_mult()

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

## LUX_1 Price Whisper: text of the best route partner for c from this planet, "" when none pays.
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
	if bazaar_panel != null:
		bazaar_panel.close_screen()
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
	if income_popup != null:
		income_popup.prune()  # popups of the system just left do not follow
	_refresh()
	return true

## Click on a marker of another system in the 3D view: moves there when open, else says why not.
func enter_system_from_view(id: int) -> bool:
	if go_to_system(id):
		return true
	var how := StoryText.get_or("LBL_LOCKED_HOW", "permit or skill")
	post_notice(StoryText.get_or("NOT_SYSTEM_LOCKED", "{name} is locked: {how}.", {"name": Systems.name_of(id), "how": how}))
	if galaxy_view != null and Systems.ids().has(id):  # the locked system's permit window (galaxy card)
		galaxy_view.open_view()
		galaxy_view.select_system(id)
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
	var open := unowned_systems().filter(func(sid): return not bool(Systems.get_system(int(sid)).get("placeholder", false)))  # T226: TEMPORARY systems never steer the arrow
	if not open.is_empty():
		var req := required_skill(int(open[0]))
		if has_skill(req):
			return {"mode": "skills", "steps": []}
		if SkillTree.state(learned_skills, req) == "available":
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

## T273: J and the rail button open the gig board (only while the Flagship exists).
func toggle_gig_board() -> void:
	if gig_panel.visible:
		gig_panel.close_screen()
	elif preface == null and not game_over and flight != null and flight.is_enabled():
		if galaxy_view != null and galaxy_view.visible:
			galaxy_view.close_view()
		if skill_screen.visible:
			skill_screen.close_screen()
		gig_panel.open_screen()

func toggle_bazaar_panel() -> void:
	if bazaar_panel.visible:
		bazaar_panel.close_screen()
	elif preface == null and not game_over:
		if galaxy_view != null and galaxy_view.visible:
			galaxy_view.close_view()
		if skill_screen.visible:
			skill_screen.close_screen()
		bazaar_panel.open_screen()

## T263: a Next Up slot was clicked: put the map camera on that world.
func focus_next_up(planet: int) -> void:
	if preface != null or game_over or planet < 0:
		return
	if galaxy_view != null and galaxy_view.visible:
		galaxy_view.close_view()
	_focus_event_planet(planet)

func toggle_skills() -> void:
	if skill_screen.visible:
		skill_screen.close_screen()
	else:
		open_skills()

func save_now() -> void:
	if preface != null or game_over:
		return
	SaveGame.write_state(collect_state())

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_now()

func _to_menu() -> void:
	save_now()
	get_tree().change_scene_to_file("res://game/main_menu.tscn")

func _on_planet_clicked(index: int) -> void:
	if index >= 0 and not tut_gate("select", index):
		return
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
		elif DeadWorlds.is_dead(map.planets[index]) and not (prosperity.is_barren(index) and prosperity.is_need(index, str(pending["c"]))):  # a dead world has no market: it can only be a source (T295: a Barren world takes its reclamation goods)
			post_notice_now(StoryText.get_or("NOT_DEAD_NO_DELIVERY", "Nothing is delivered to a dead world. Pick another planet."))
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
			if sell_offer_applies(dst, str(r["c"])) and not tut_lock_active():  # the guided Sell step teaches the order
				sell_offer = {"planet": dst, "c": str(r["c"])}
			planet_panel.show_planet(dst)
			return
	if index < 0 or index >= map.planets.size():
		selected_planet = -1
		planet_panel.visible = false
		return
	selected_planet = index
	planet_panel.show_planet(index)

## T159: story id suffix of a base cluster ("c1_1" -> "S1A"); "" for clusters made by events.
func _cluster_story_key(cl: Dictionary) -> String:
	var parts := str(cl["id"]).split("_")
	if parts.size() == 2 and parts[0].begins_with("c") and parts[1].is_valid_int() and int(parts[1]) >= 1 and int(parts[1]) <= 26:
		return "S%s%s" % [parts[0].substr(1), char(64 + int(parts[1]))]
	return ""

## "Send ore to..." on the cluster card: same pending state as a planet's Send to..., source = the cluster node.
## The next planet clicked becomes the destination (_on_planet_clicked -> send_stock_buying); Esc or a click on empty space cancels.
func _on_cluster_send(index: int) -> void:
	if game_over or not clusters.valid(index):
		return
	var node := Clusters.node_id(index)
	_hide_cluster_info()
	pending = {"planet": node, "c": clusters.good_of(index)}
	_pending_changed()

func _hide_cluster_info() -> void:
	cluster_info_index = -1
	if cluster_info != null:
		cluster_info.visible = false

## T159: click on an asteroid pack. Shows name, what it gives per cycle and, with FND_PROSPECT, what is left. Risk: no value exists yet (open question).
func _on_cluster_clicked(index: int) -> void:
	if not tut_gate("other"):
		return
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
	if not Availability.feature("cluster_routes") or not Availability.good(str(found["good"])):  # data/availability.json: the ore readout waits for Prospecting
		info.text = StoryText.get_or("NOT_MINING_NEEDS_SKILL", "Mining needs the Prospecting skill.")
	elif can_mine():
		info.text = StoryText.get_or("LBL_CLUSTER_INFO", "{good}: {yield} per cycle, {left} of {max} left.", args)
	else:
		info.text = "%s %s" % [StoryText.get_or("LBL_CLUSTER_INFO_YIELD", "{good}: {yield} per cycle.", args), StoryText.get_or("NOT_MINING_NEEDS_SKILL", "Mining needs the Prospecting skill.")]
	box.add_child(info)
	if Availability.feature("cluster_routes") and can_mine() and int(found["left"]) > 0 and not game_over:
		var send := Button.new()
		send.name = "ClusterSendButton"
		send.text = StoryText.get_or("BTN_CLUSTER_SEND", "Send ore to...")
		send.pressed.connect(_on_cluster_send.bind(int(found["index"])))
		box.add_child(send)
	var close := Button.new()
	close.text = StoryText.get_or("BTN_CLOSE", "Close")
	close.pressed.connect(_hide_cluster_info)
	box.add_child(close)
	cluster_info.visible = true

## T65: clicking a route line selects that connection in the panel (with Remove).
func _on_route_clicked(id: int) -> void:
	if not tut_gate("other"):
		return
	var i: int = engine.find_by_id(id)
	if i < 0:
		return
	if space_storage_view != null:
		space_storage_view.close_view()  # one view at a time
	if RouteEngine.from_cluster(engine.routes[i]) and int(engine.routes[i]["b"]) < 0:  # ore into a station: no planet at either end, show the station's storage
		var sid := -int(engine.routes[i]["b"])
		if space_post_open(sid):
			selected_planet = -1
			planet_panel.visible = false
			space_storage_view.open_for(sid)
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
	if selected_planet >= 0:
		planet_panel.rebuild()
	if space_storage_view != null:
		space_storage_view.refresh()

## T68: Buy / Sell toggled on a resource row of the selected planet (standing local order, no ship).
func _on_order(c: String, role: String) -> void:
	if selected_planet < 0 or game_over:
		return
	if not tut_gate_order(selected_planet, c, role):
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
	if not tut_gate("send_start", selected_planet, c):
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
	if not tut_gate_order(selected_planet, c, "buy"):
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
	if not tut_gate("send_start", selected_planet, c):
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

## " Or click the Space Storage station." (leading space) when the pending send's system has a station, else "". Shared by the top line and the planet panel.
func pending_station_hint() -> String:
	if pending.is_empty() or not station_systems.has(system_of(int(pending["planet"]))):
		return ""
	return " " + StoryText.get_or("LBL_PENDING_OR_STATION", "Or click the Space Storage station.")

func _pending_changed() -> void:
	map.set_pending(int(pending["planet"]) if not pending.is_empty() else -1)
	if pending_label != null:
		pending_label.visible = not pending.is_empty()
		if pending.has("dest"):  # N9: destination picked, a stop is on the way
			pending_label.text = "Click the stop in the picker, or %s again for a direct send. (Esc to cancel)" % planet_name(int(pending["dest"]))
		elif not pending.is_empty():
			pending_label.text = "Send %s from %s: click the destination planet. (Esc to cancel)" % [
				pending["c"], planet_name(int(pending["planet"]))]
			pending_label.text += pending_station_hint()
	_refresh_pending_margins()
	_refresh_panel()

## P1: one line per reachable destination: margin per unit now, and after the price events end when one moves it.
func pending_margin_lines() -> Array:
	var out: Array = []
	if pending.is_empty() or Clusters.is_node(int(pending["planet"])):  # a cluster source has no planet margin lines
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
	pending_label.offset_bottom = -64  # pending banner near the bottom
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
	return ships - engine.total_assigned() - hubs.pool_total()  # T289: hub pool ships are not free

## T58: owned and free ships of one type (only "small" remains).
func owned_of(kind: String) -> int:
	return ships if kind == Ships.fleet else 0

func free_of(kind: String) -> int:
	return owned_of(kind) - engine.assigned_of(kind)

## Buys one free ship of a type (default small, at ship_price). Returns {ok, reason}.
func buy_ship(kind: String = "") -> Dictionary:
	if not tut_gate("other"):
		return {"ok": false, "reason": tut_lock_text()}
	return _buy_ship_now(kind)

func _buy_ship_now(kind: String = "") -> Dictionary:
	kind = Ships.fleet  # one ship type per run
	var r := can_buy_ship(kind)
	if not r["ok"]:
		return r
	cash -= Ships.price(kind, balance)
	ships += 1
	_after_change()
	return r

func can_buy_ship(kind: String = "") -> Dictionary:
	kind = Ships.fleet  # one ship type per run
	if game_over:
		return {"ok": false, "reason": "The game is over."}
	if ships >= ship_cap():
		return {"ok": false, "reason": "Ship cap reached."}
	if cash < Ships.price(kind, balance):
		return {"ok": false, "reason": "Not enough cash for a new ship (%d cr). Each route needs its own ship; wait for income or remove a route." % Ships.price(kind, balance)}
	var floor_cash := ship_cash_floor()
	if cash - Ships.price(kind, balance) < floor_cash:  # stall fix: keep working capital for the trips of every open route
		return {"ok": false, "floor": true, "reason": StoryText.get_or("NOT_SHIP_KEEP_CASH", "Keep cash for trips: {floor} cr after the price.", {"floor": floor_cash})}
	return {"ok": true, "reason": ""}

## Route start the player cannot pay for: {planet, need, have} while a connection is pending, no free ship exists and
## cash is short of a new ship (price plus the working-capital floor); {} otherwise (free ship, enough cash, cap, game over).
func route_unaffordable() -> Dictionary:
	if pending.is_empty() or game_over or free_ships() > 0:
		return {}
	if ships >= ship_cap() or bool(can_buy_ship()["ok"]):
		return {}
	return {"planet": int(pending["planet"]), "need": Ships.price(Ships.fleet, balance) + ship_cash_floor(), "have": cash}

## Cash that must remain after buying a ship: the fixed cost of every open route.
func ship_cash_floor() -> int:
	return engine.routes.size() * engine.fixed_cost()

## T58: auto-assignment. One ship type remains (small).
func pick_ship(_src: int, _dst: int, _c: String) -> String:
	return Ships.fleet

## ---- T56 one-way route API (T57 UI and bots). One ship per route, auto-assigned from the free pool. ----

## Setup check for a connection src -> dst carrying c. One reason when refused.
func can_connect(src: int, dst: int, c: String) -> Dictionary:
	if game_over:
		return {"ok": false, "reason": "The game is over."}
	if not planet_established(src) or (dst >= 0 and not planet_established(dst)):  # T179: both ends need a post or platform
		return {"ok": false, "reason": closed_world_reason()}
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
	if not tut_gate("other"):
		return {"ok": false, "reason": tut_lock_text()}
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
	if not tut_gate("send", src, c, dst):
		return {"ok": false, "reason": tut_lock_text(), "c": c, "bought": false}
	var bought := false
	if stop >= 0 and not engine.stop_candidates(src, dst, c).has(stop):  # N9: checked before any ship is bought
		return {"ok": false, "reason": StoryText.get_or("NOT_STOP_PICK_AGAIN", "Click a stop from the picker, or the destination again."), "c": c, "bought": false}
	if free_ships() <= 0:
		var chk: Dictionary = can_connect(src, dst, c)
		if chk["reason"] != StoryText.get_text("NOT_SHIP_FREE"):  # a route problem other than "no ship"
			chk["c"] = c
			chk["bought"] = false
			return chk
		var b := can_buy_ship()
		if not b["ok"]:
			return {"ok": false, "reason": b["reason"], "c": c, "bought": false}
		_buy_ship_now("small")
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
	if not tut_gate("other"):
		return
	var pct := clampi(first_pct, 10, 90)
	engine.set_split(planet, int(pair[0]), int(pair[1]), c, float(pct) / 100.0)

## Split bar: "Stop split".
func clear_split(planet: int, c: String) -> void:
	if not tut_gate("other"):
		return
	engine.clear_split(planet, c)

## T68: standing local order at a planet (no ship). role "buy" or "sell". Returns {ok, reason}.
func set_local_order(planet: int, c: String, role: String, on: bool) -> Dictionary:
	if game_over:
		return {"ok": false, "reason": "The game is over."}
	if not tut_gate(role if on else "other", planet, c):
		return {"ok": false, "reason": tut_lock_text()}
	if on and not planet_established(planet):  # T179
		return {"ok": false, "reason": closed_world_reason()}
	if on and not system_trade_open(planet):
		return {"ok": false, "reason": trade_locked_reason()}
	var r: Dictionary = engine.set_local(planet, c, role, on)
	if r["ok"]:
		if on:
			_award_planet(planet)
			_note_system(planet)
		_after_change()
	return r

## N5: one-off salvage sale of the stock in a planet's storage. Returns {ok, reason, credits}.
func salvage_stock(planet: int, c: String) -> Dictionary:
	if game_over:
		return {"ok": false, "reason": "The game is over.", "credits": 0}
	if not tut_gate("other"):
		return {"ok": false, "reason": tut_lock_text(), "credits": 0}
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
	if mining:  # T156: a cluster is no planet pair; only the delivery planet counts (a station is no planet)
		if dst >= 0:
			_award_planet(dst)
	else:
		_award_route(src, dst)
	_note_system(src)
	_note_system(dst)
	if not mining:
		storage.ensure(str(rec["src"]))  # T65: first order at a planet establishes its company storage
	storage.ensure(str(rec["dst"]))
	_after_change()
	return {"ok": true, "reason": "", "id": rec["id"]}

## Removes the connection; its ship becomes free.
func remove_connection(id: int) -> Dictionary:
	if not tut_gate("other"):
		return {"ok": false, "reason": tut_lock_text()}
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
	if not tut_gate("other"):
		return {"ok": false, "reason": tut_lock_text()}
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
	var p: Dictionary = map.planets[i]
	if not PathfinderView.discovered(map.flight, str(p.get("id", i))):  # T180: the one place a closed planet's real name is hidden
		return StoryText.get_or("LBL_UNKNOWN_DARK_WORLD" if DeadWorlds.is_dead(p) else "LBL_UNKNOWN_WORLD", "Unknown world")
	return str(p.get("name", p.get("id", "?")))

## T07b: tell the map which route lines to draw (cheap: restyles existing lines, adds/removes changed ones).
func _push_routes_to_map() -> void:
	var list: Array = []
	var lanes := {}  # T87: one line per lane; ships = ships on it, status = running if any ship runs
	var fc := {}  # route id -> forecast line: the lane label shows the same projection as the cash forecast
	for fl in engine.forecast(cash)["routes"]:
		fc[int(fl["id"])] = fl
	for rec in engine.routes:
		var k := "%d|%d|%s" % [rec["a"], rec["b"], rec["c"]]
		var st: String = display_status(rec)
		var fl: Dictionary = fc.get(int(rec["id"]), {})
		var moves := bool(fl.get("moves", false))
		if lanes.has(k):
			var e: Dictionary = lanes[k]
			e["ships"] = int(e["ships"]) + 1
			e["cost"] = int(e["cost"]) + engine.fixed_cost(rec)
			if moves:
				e["net"] = int(e["net"]) + int(fl["net"])
				e["net_ok"] = true
			if st == "running":
				e["status"] = st
			continue
		var e2 := {"id": rec["id"], "a": rec["a"], "b": rec["b"], "c": rec["c"], "ships": 1, "status": st, "net": int(fl["net"]) if moves else 0, "net_ok": moves, "cost": engine.fixed_cost(rec), "reason": engine.reason_of(rec)}
		lanes[k] = e2
		list.append(e2)
	map.set_clusters(_all_cluster_packs())  # T157: asteroid packs follow the cluster data (before the lines: a cluster route starts at its pack)
	map.set_routes(list)

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
## T295: a reclaimed world turns living: its post counts as built.
func _on_prosperity_reclaimed(i: int) -> void:
	if flight != null and i >= 0 and i < map.planets.size():
		flight.set_flag("post", str(map.planets[i].get("id", "")), true)

func _tick_danger() -> void:
	var ids: Array = []
	for rec in engine.routes:
		var a := int(rec["a"])
		if str(rec["state"]) == "running" and a >= 0 and a < map.planets.size() and DeadWorlds.is_dead(map.planets[a]):
			var pid := str(map.planets[a]["id"])
			if not ids.has(pid):  # two ships on one world raise it once
				ids.append(pid)
	dead.tick(ids)

## Fabric inputs (dross, nullglass) with no route into the system 1 Space Storage. Routes only, stock does not count.
func fabric_inputs_unrouted() -> Array:
	var key: String = storage.system_key(Fabric.SYSTEM)
	var out: Array = []
	for c in Fabric.INPUTS:
		var fed := false
		for rec in engine.routes:
			if str(rec["dst"]) == key and str(rec["c"]) == c:
				fed = true
				break
		if not fed:
			out.append(c)
	return out

## Fabric: can it be built now? {ok, reason}: "skill" (MIN_1 not learned), "post" (no trading post in system 1), "built", "inputs" (a input has no route here), "credits".
func can_build_fabric() -> Dictionary:
	if fabric.built:
		return {"ok": false, "reason": "built"}
	if not has_skill("MIN_1"):
		return {"ok": false, "reason": "skill"}
	if not station_systems.has(Fabric.SYSTEM):
		return {"ok": false, "reason": "post"}
	if not fabric_inputs_unrouted().is_empty():
		return {"ok": false, "reason": "inputs"}
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

## Workshop (smelter, munitions, atelier, culture_lab): can it be built now in the cell of system sid? {ok, reason}: "unknown", "built" (once per run, anywhere), "skill", "post" (no established cell there), "closed" (availability rule, e.g. system 2 shut), "credits".
func can_build_workshop(id: String, sid: int = WorkshopsScript.SYSTEM) -> Dictionary:
	if not WorkshopsScript.IDS.has(id):
		return {"ok": false, "reason": "unknown"}
	if workshops.built[id]:
		return {"ok": false, "reason": "built"}
	if not workshops.is_unlocked(id):
		return {"ok": false, "reason": "skill"}
	if not station_systems.has(sid):
		return {"ok": false, "reason": "post"}
	if not Availability.workshop(id):  # data/availability.json rule (munitions and culture lab need system 2 open)
		return {"ok": false, "reason": "closed"}
	if cash < workshops.build_cost(id):
		return {"ok": false, "reason": "credits"}
	return {"ok": true, "reason": ""}

func build_workshop(id: String, sid: int = WorkshopsScript.SYSTEM) -> Dictionary:
	if not tut_gate("other"):
		return {"ok": false, "reason": tut_lock_text()}
	var v := can_build_workshop(id, sid)
	if not v["ok"]:
		return v
	cash -= workshops.build_cost(id)
	workshops.built[id] = true
	workshops.system[id] = sid
	workshops.state[id] = "idle"
	post_notice(StoryText.get_or("NOT_WORKSHOP_BUILT", "{workshop} built in {system}.", {"workshop": StoryText.get_or("WS_" + id.to_upper() + "_NAME", id.capitalize()), "system": Systems.name_of(sid)}))
	_after_change()
	return v

## Null Core: can it be built now? {ok, reason}: "max" (one per run), "skill" (MIN_1), "post", "stock" (plate and nullglass at the trading post), "credits".
func can_build_core() -> Dictionary:
	if fabric.core_made >= fabric.core_max():
		return {"ok": false, "reason": "max"}
	if not has_skill("MIN_1"):
		return {"ok": false, "reason": "skill"}
	if not station_systems.has(Fabric.SYSTEM):
		return {"ok": false, "reason": "post"}
	var key: String = storage.system_key(Fabric.SYSTEM)
	for c in ["plate", "nullglass"]:
		if storage.amount(key, c) < fabric.core_in(c):
			return {"ok": false, "reason": "stock"}
	if cash < fabric.core_cost():
		return {"ok": false, "reason": "credits"}
	return {"ok": true, "reason": ""}

## Builds the Null Core: plate and nullglass leave the trading post storage, credits are paid. One popup, once per run.
func build_null_core() -> Dictionary:
	var v := can_build_core()
	if not v["ok"]:
		return v
	var key: String = storage.system_key(Fabric.SYSTEM)
	for c in ["plate", "nullglass"]:
		storage.remove(key, c, fabric.core_in(c))
	cash -= fabric.core_cost()
	fabric.core_made += 1
	var title := StoryText.get_or("NULL_CORE_BUILD_TITLE", "The core is built")
	var body := StoryText.get_or("NULL_CORE_BUILD", "The Null Core is built.")
	if event_notice == null:
		event_notice = load("res://game/event_notice.gd").new()
		add_child(event_notice)
		event_notice.show_event(title, body, "", [], StoryText.get_text("BTN_OK"))
		event_notice.confirmed.connect(func(_c: int):
			_dismiss_event_notice()
			_refresh())
	else:
		post_notice(body)
	_after_change()
	return v

## Route id whose ship carries the Null Core, -1 when none.
func core_route_id() -> int:
	for r in engine.routes:
		if RouteEngine.has_core(r):
			return int(r["id"])
	return -1

## Fits the built Null Core to the ship of route `id` (it leaves any other ship). {ok, reason}.
func fit_core(id: int) -> Dictionary:
	if not tut_gate("other"):
		return {"ok": false, "reason": tut_lock_text()}
	if fabric.core_made <= 0:
		return {"ok": false, "reason": "no core"}
	var i: int = engine.find_by_id(id)
	if i < 0:
		return {"ok": false, "reason": "No such route."}
	for r in engine.routes:
		r["core"] = false
	engine.routes[i]["core"] = true
	_after_change()
	return {"ok": true, "reason": ""}

## Danger meter (0 to dead_danger_max) of planet index i; 0 for a planet that is not a dead world.
func danger_of(i: int) -> int:
	return dead.get_danger(str(map.planets[i].get("id", ""))) if i >= 0 and i < map.planets.size() else 0

func _settle_routes() -> Array:
	cash -= hubs.plan(cash)  # T289: hub deliveries buy their goods, then settle with the routes
	hubs.begin_settle()
	var r: Dictionary = engine.settle(cash)
	var hub_ids: Array = []
	for rec in hubs.records:
		hub_ids.append(int(rec["id"]))
	var kept_results: Array = []
	for row in r["results"]:
		if not hub_ids.has(int(row["id"])):
			kept_results.append(row)
	r["results"] = kept_results
	var hub_net := hubs.end_settle()
	cash += hub_net
	last_local = r["local"]
	cash += int(r["delta"])
	trade_income_total += maxi(0, int(r["gross"]))
	_sync_earn()
	_check_storage_ready()
	for c in engine.sales_units:  # Four Markets: Sell orders and stop sales count toward share
		Markets.add_sale(str(c), int(engine.sales_units[c]), int(engine.sales_up_units.get(c, 0)))
	prev_net = last_net
	last_net = int(r["delta"])
	last_summary = "%s %d, %s %d, %s %+d" % [StoryText.get_text("LBL_GROSS"), int(r["gross"]),
		StoryText.get_text("LBL_SHIP_UPKEEP"), int(r["upkeep"]), StoryText.get_text("LBL_NET"), int(r["delta"])]
	for rec in r["newly_blocked"]:
		if str(rec.get("owner", "")) != "":
			continue  # T289: a hub delivery has no route row to blame
		var text := _blocked_text(rec)
		post_notice(text)
		route_blocked.emit(int(rec["id"]), text)
	for rec in r["newly_stalled"]:
		if str(rec.get("owner", "")) != "":
			continue
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
	if last_rescue_cycle == cycle or repossessed_cycle == cycle or rescues_paid >= int(balance.get("rescue_max", 2)):
		return  # Four Markets: no stipend in a repossession cycle, and only the first rescue_max are paid
	var stuck := ships == 0 and cash < Ships.price(Ships.fleet, balance)
	if not stuck and cash < engine.fixed_cost() and (last_net <= 0 or not _any_route_running()) and not _any_sellable():
		stuck = true
	# stall fix: cash below the summed fixed cost of all open routes and no net income for 2 cycles in a row
	if not stuck and not engine.routes.is_empty() and cash < _routes_fixed_total() and last_net <= 0 and prev_net <= 0 and not _any_sellable():
		stuck = true
	if stuck:
		last_rescue_cycle = cycle
		rescues_paid += 1
		var amount := int(balance.get("rescue_stipend", 0))
		cash += amount
		post_notice(StoryText.get_text("NOT_DEAD_RESCUE", {"amount": amount}))

## B1: true when the run cannot recover: every rescue stipend is spent, cash is below one route's fixed cost, no income for
## 2 cycles, no route running and nothing to sell (or no ship and cash below a ship). Buying needs cash, so nothing can restart.
func _is_dead_end() -> bool:
	if rescues_paid < int(balance.get("rescue_max", 2)) or last_rescue_cycle == cycle or repossessed_cycle == cycle:
		return false
	if ships == 0 and cash < Ships.price(Ships.fleet, balance):
		return true
	return cash < engine.fixed_cost() and last_net <= 0 and prev_net <= 0 and not _any_route_running() and not _any_sellable()

func _routes_fixed_total() -> int:
	var t := 0
	for rec in engine.routes:
		t += engine.fixed_cost(rec)
	return t

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
	_tut_poll()
	_tut_update_highlight()
	_tut_tick(delta)
	if event_icons != null:
		event_icons.tick(delta)  # real time, also while paused
	_update_station_markers()
	_update_sell_offer_box()
	if paused or game_over:
		return
	var slow := 1.0
	if _beat_slow_left > 0.0:
		_beat_slow_left -= delta
		slow = clampf(float(balance.get("beat_slow_scale", 0.25)), 0.05, 1.0)
	if _beat_banner_left > 0.0:
		_beat_banner_left -= delta
		_beat_banner.modulate.a = clampf(_beat_banner_left / 0.6, 0.0, 1.0)  # fades over its last 0.6 s
		if _beat_banner_left <= 0.0:
			_beat_banner.visible = false
	cycle_elapsed += delta * time_speed * slow
	flight.sync(game_time())  # T179: the Pathfinder moves with the game clock only (nothing while paused)
	gigs.tick(game_time())  # T271: deadlines on the game clock
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

func _on_link_notice(text_id: String, vars: Dictionary) -> void:
	post_notice(StoryText.get_or(text_id, text_id, vars))

## T262: the planet card's confirmed 'Found the Bazaar here'.
func _on_found_bazaar(planet: int) -> void:
	if bazaar.found(planet):
		post_notice(StoryText.get_or("BAZ_FOUNDED", "The Star Bazaar is founded at {planet}.", {"planet": planet_name(planet)}))
		if planet_panel != null and planet_panel.visible:
			planet_panel.rebuild()

func _on_prosperity_tier_up(planet: int, tier: int) -> void:
	_beat_slow_left = float(balance.get("beat_slow_seconds", 0.4)) * Juice.motion  # T266: a short slow-motion beat, game clock only
	if map != null:
		map.beat_tier_up(planet, tier)
	post_notice(StoryText.get_or("NOT_PROSPERITY_TIER_UP", "{planet} has grown to tier {tier}.", {"planet": planet_name(planet), "tier": tier}))

## T298: the last stage is done: the Opening gig waits at the capital.
func _on_bazaar_opening_ready(planet: int) -> void:
	gigs.post_opening(planet)
	post_notice(StoryText.get_or("NOT_BAZAAR_OPENING", "The charter cargo is ready. Fly it to {planet} to open the Star Bazaar.", {"planet": planet_name(planet)}))

## T299: a stage with wings is done: the choice popup (two cards) opens.
func _on_bazaar_wing_offered(_stage: int) -> void:
	if bazaar_panel != null:
		bazaar_panel.show_wing_choice()

## T298: the Flagship docked at the capital with the charter cargo (Gigs.on_arrived_planet): the Bazaar opens, the run is won.
func on_opening_flown() -> void:
	var outcome := bazaar.open()
	if outcome.is_empty() or game_over:
		return
	if Juice.motion <= 0.0 or map == null or not is_inside_tree():
		_finish_outcome(outcome)
		return
	# T300: the Opening beat. The win is recorded now (game_over stops the clock, the save is cleared); only the end screen waits for the beat.
	map.beat_opening(bazaar.capital())
	_show_opening_banner()
	if DisplayServer.get_name() != "headless":
		_end_screen_hold = float(balance.get("beat_opening_hold_seconds", 3.4)) * Juice.motion
	_finish_outcome(outcome)

## T300: the banner of the Opening. Real-time tween (the game clock is stopped); never takes a click.
func _show_opening_banner() -> void:
	var l := Label.new()
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	l.grow_horizontal = Control.GROW_DIRECTION_BOTH
	l.position.y = 110
	l.add_theme_font_size_override("font_size", 34)
	l.add_theme_color_override("font_color", Ui.col("star_warm"))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 8)
	l.text = StoryText.get_or("BAZ_OPENING_BANNER", "The Star Bazaar is open.")
	add_child(l)
	Juice.enter(l, 0.8, 0.0)
	var hold := float(balance.get("beat_opening_hold_seconds", 3.4)) * Juice.motion
	get_tree().create_timer(maxf(0.1, hold - Juice.EXIT_SECONDS)).timeout.connect(func() -> void:
		if is_instance_valid(l):
			Juice.leave(l, true))

## T300: a raid hit a lane: raiders, flash, pods on the map (lane route id, nest planet index, where the pods dropped).
func _on_raid_hit(lane: int, nest: int, pods_at: Vector3) -> void:
	if map == null:
		return
	var idx: int = engine.find_by_id(lane)
	if idx >= 0:
		var rec: Dictionary = engine.routes[idx]
		map.beat_raid(int(rec["a"]), int(rec["b"]), nest, pods_at)

## T300: the Flagship scooped pods: they zip into it.
func _on_salvage_scooped() -> void:
	if map != null and flight != null:
		map.beat_scoop(flight.ship_position())

## T266: a Bazaar stage is done: flash and ring at the capital, and a banner that holds for beat_banner_seconds of game time.
func _on_bazaar_stage_done(n: int) -> void:
	if map != null:
		map.beat_stage(bazaar.capital())
	if Juice.motion <= 0.0:
		return
	if _beat_banner == null:
		_beat_banner = Label.new()
		_beat_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_beat_banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
		_beat_banner.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_beat_banner.position.y = 110
		_beat_banner.add_theme_font_size_override("font_size", 28)
		_beat_banner.add_theme_color_override("font_color", Ui.col("star_warm"))
		_beat_banner.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
		_beat_banner.add_theme_constant_override("outline_size", 6)
		add_child(_beat_banner)
	var stage_name := StoryText.get_or("BAZ_STAGE_%d_NAME" % n, "")
	_beat_banner.text = StoryText.get_or("BAZ_STAGE_DONE", "Bazaar stage done: {stage}.", {"stage": stage_name})
	_beat_banner.visible = true
	_beat_banner.modulate.a = 1.0
	_beat_banner_left = float(balance.get("beat_banner_seconds", 3.0)) * Juice.motion

var _beat_slow_left := 0.0   # T266: seconds of game-clock slow left (counts down only while the game runs)
var _beat_banner: Label = null
var _beat_banner_left := 0.0

## T258: growth pays. Tax by tier for every world (one summary notice), skill points the first time any world reaches a tier.
func _pay_prosperity() -> void:
	var tax := roundi(float(prosperity.tax_total()) * (1.0 + Bazaar.wing_bonus("tax_pct") / 100.0))  # T298 wings
	if tax > 0:
		cash += tax
		post_notice(StoryText.get_or("NOT_PROSPERITY_TAX", "Your worlds paid {n} credits in tax.", {"n": tax}))
	for r in prosperity.claim_new_tiers():
		if int(r["points"]) > 0:
			_add_points(int(r["points"]))
			_point_notice(StoryText.get_or("NOT_SKILL_REASON_TIER", "A world of yours reached tier {tier}.", {"tier": int(r["tier"])}))

func _end_cycle() -> void:
	_advance_notice()  # the board notice lives for one cycle, then the next queued one shows
	_settle_routes()
	gigs.credit_tick()  # T271: a rush delivery counts as its need met for some cycles
	prosperity.end_cycle()  # T256: needs met = progress, short = decay, full = tier up
	_tick_danger()
	fabric.run(storage)
	storage_link.settle()  # T171: standing link orders and upkeep
	workshops.run(storage, Callable(self, "craft_units"))
	Skills.grow_stock(storage)  # BIO_2: Biotech stock in planet storage grows
	_post_tech_done()  # techs the fabric just finished
	_count_idle_cycles()
	# Space Storage fills only by a ship sent to it (send_stock with a station destination); planet_to_space_rate is unused.
	Markets.end_cycle(cycle)  # sales record per market, house hits age
	_pay_prosperity()  # T258: tax per world, skill points for a tier reached first
	var outcome := bazaar.end_cycle()  # T259: a Bazaar stage completes; the last one wins. No share win, no swept loss, no market overhead.
	if outcome.is_empty():
		outcome = _bankrupt_step()
		if outcome.is_empty() and Markets.timed_out(cycle) and not free_play:
			outcome = {"kind": "unfinished", "stages_done": bazaar.stage()}  # the term ended first: kind soft ending
	if outcome.is_empty() or str(outcome["kind"]) == "repossessed":
		_check_stranded()
		if outcome.is_empty() and _is_dead_end():
			outcome = {"kind": "bankrupt"}  # B1: no stipend left and no way to earn: end the run as bankrupt, not 6 idle cycles
	_record_prices()  # price history
	_push_routes_to_map()
	_refresh_panel()
	cycle_ended.emit(cycle)
	Juice.pop(cycle_label, 1.12)  # the economy turned over: income has landed
	Juice.flash(cycle_label, Ui.col("star_warm"))
	if free_play and not outcome.is_empty() and str(outcome["kind"]) != "repossessed":
		outcome = {}  # T259 free play: no further endings
	if not outcome.is_empty() and str(outcome["kind"]) != "repossessed":
		_finish_outcome(outcome)
		return
	events.tick()  # T12: effects that ran this cycle age
	cycle += 1
	gigs.on_cycle(cycle)  # T271: perks age, a signal may open
	raids.on_cycle(cycle)  # T296: malus ages, a raid may be chosen
	_sync_earn()
	Chains.tick(cycle)  # chain effects that ran through the last cycle expire
	_sync_closed()
	if dead_unlock_cycle() > 1 and cycle == dead_unlock_cycle():  # the dead worlds open now
		post_notice(StoryText.get_or("DEAD_UNLOCK", "Dead worlds are open."))
	# The slot's pool event is always drawn FORECAST_HORIZON cycles ahead, whatever the warning skills; a skill only
	# decides when the notice shows. So LUX_3 / LUX_5B / ceo man_01 never change which events happen (T173).
	if forecast_id == "":
		for ahead in range(FORECAST_HORIZON, 0, -1):
			if events.due(cycle + ahead):
				forecast_id = events.random_id([], cycle + ahead)
				forecast_slot = cycle + ahead
				forecast_noted = false
				break
	var warn := mini(Skills.warning_cycles(), FORECAST_HORIZON)  # LUX_3 Event Forecast: 1 cycle of warning; LUX_5B: 2 (the longest source wins)
	if forecast_id != "" and not forecast_noted and warn > 0 and forecast_slot - cycle <= warn and forecast_slot > cycle:
		forecast_noted = true
		post_notice(forecast_text(forecast_id, forecast_slot - cycle))
	# One event per cycle: a chain step first, then a scheduled flavour popup, then the pool event of the slot.
	_check_storage_ready()
	var chain_id: String = Chains.next_step(cycle) if (event_notice == null and events.pending_id == "" and not game_over) else ""
	var sched_id: String = events.take_due(cycle) if (chain_id == "" and event_notice == null and events.pending_id == "" and not game_over) else ""  # R1: flavour popups come from the schedule
	if chain_id != "":
		forecast_id = ""  # the chain step took the slot of the forecast pool event
		fire_chain_step(chain_id)
	elif sched_id != "":
		forecast_id = ""  # the forecast promised a random event for this slot; the scheduled one took it
		fire_event(sched_id)
	elif events.due(cycle) or (OS.is_debug_build() and debug_force_event):
		debug_force_event = false
		var fid: String = forecast_id if forecast_id != "" and events.by_id.has(forecast_id) and not Chains.is_suppressed(forecast_id) else events.random_id([], cycle)
		forecast_id = ""
		fire_event(fid)
	_tut_cycle()
	save_now()

## Event forecast: the event picked ahead of its cycle (saved); it is the one that fires.
var forecast_id: String = ""
var forecast_slot: int = 0  # the cycle the forecast event fires in
var forecast_noted: bool = false  # the warning notice was shown
const FORECAST_HORIZON := 5  # the longest warning any skill gives (LUX_5B + the weather_warning nodes, T282); the draw happens this early for everyone

## Warning text for a coming event: names the planet and commodity when the event has them, else the plain warning.
func forecast_text(id: String, ahead: int = 1) -> String:
	if ahead >= 2:
		var e2: Dictionary = events.effect_of_event(id)
		var k2 := str(e2.get("kind", ""))
		if k2 in ["up", "down"]:
			return StoryText.get_or("EVT_NEXT_DUE_PRICE_2", StoryText.get_text("EVT_NEXT_DUE_2"), {"planet": planet_name(int(e2["planet"])), "commodity": Ui.good_name(str(e2["c"])), "direction": "rise" if k2 == "up" else "fall"})
		if k2 == "closed":
			return StoryText.get_or("EVT_NEXT_DUE_CLOSED_2", StoryText.get_text("EVT_NEXT_DUE_2"), {"planet": planet_name(int(e2["planet"]))})
		return StoryText.get_text("EVT_NEXT_DUE_2")
	var eff: Dictionary = events.effect_of_event(id)
	var kind := str(eff.get("kind", ""))
	if kind in ["up", "down"]:
		return StoryText.get_or("EVT_NEXT_DUE_PRICE", StoryText.get_text("EVT_NEXT_DUE"), {"planet": planet_name(int(eff["planet"])), "commodity": Ui.good_name(str(eff["c"])), "direction": "rise" if kind == "up" else "fall"})
	if kind == "closed":
		return StoryText.get_or("EVT_NEXT_DUE_CLOSED", StoryText.get_text("EVT_NEXT_DUE"), {"planet": planet_name(int(eff["planet"]))})
	return StoryText.get_text("EVT_NEXT_DUE")

func _open_end_screen() -> ColorRect:
	if end_screen != null:
		end_screen.queue_free()
	end_screen = load("res://game/end_screen.gd").new()
	add_child(end_screen)
	end_screen.new_game_pressed.connect(func(): get_tree().reload_current_scene())
	end_screen.menu_pressed.connect(_to_menu)
	end_screen.continue_pressed.connect(_continue_free_play)
	end_screen.quit_pressed.connect(func(): get_tree().quit())
	return end_screen

## Bankrupt step (after upkeep and overhead): cash below zero repossesses the newest ship and credits salvage_share x
## ship_price; the run ends when no ship is left and cash is still negative. Returns {} (fine), {kind: "repossessed"} or {kind: "bankrupt"}.
func _bankrupt_step() -> Dictionary:
	if cash >= 0:
		return {}
	var out := {}
	if ships > 0:
		_repossess_newest()
		out = {"kind": "repossessed"}
	if ships <= 0 and cash < 0:
		return {"kind": "bankrupt"}
	return out

## Removes the newest ship: a free one first, else the route with the highest id (its ship).
func _repossess_newest() -> void:
	if free_ships() <= 0 and not engine.routes.is_empty():
		var newest := 0
		for i in engine.routes.size():
			if int(engine.routes[i]["id"]) > int(engine.routes[newest]["id"]):
				newest = i
		engine.routes.remove_at(newest)
	ships = maxi(0, ships - 1)
	var credit := floori(float(balance.get("salvage_share", 0.4)) * float(Ships.price(Ships.fleet, balance)))
	cash += credit
	repossessions += 1
	repossessed_cycle = cycle
	post_notice(StoryText.get_or("NOT_REPOSSESSED", "Cash ran out. The newest ship was repossessed: +{n} credits.", {"n": credit}))
	_after_change()

## Ending id for an outcome (T259). A Bazaar win is the run branch's family, GOOD or BAD by the hidden chain lean:
## END_<BRANCH>_GOOD / _BAD. The term ending is END_UNFINISHED; the loss is END_BANKRUPT.
func ending_id_of(outcome: Dictionary) -> String:
	match str(outcome.get("kind", "")):
		"bazaar":
			var b := run_branch() if run_branch() != "" else str(Markets.ids[0])
			return "END_%s_%s" % [b.to_upper(), Chains.ending_flag(b).to_upper()]
		"bankrupt":
			return "END_BANKRUPT"
	return "END_UNFINISHED"

func _finish_outcome(outcome: Dictionary) -> void:
	var kind := str(outcome["kind"])
	var stat := ""
	var side := "LOSS"
	var stages := "%s: %d / %d" % [StoryText.get_or("END_STAT_STAGES", "Bazaar stages"), bazaar.stage(), bazaar.stages_total()]
	if kind == "bazaar":
		side = "WIN"
		stat = stages
	elif kind == "unfinished":
		side = "SOFT"
		stat = stages
	_finish(side, ending_id_of(outcome), stat, run_branch())

var _end_screen_hold := 0.0  # T300: seconds the end screen waits for the Opening beat

## The run is over: the save is cleared, the end screen shows the ending.
func _finish(side: String, ending_id: String, stat: String, win_market: String = "") -> void:
	game_over = true
	SaveGame.clear()
	var stats := {"cycle": cycle, "cash": cash, "market": win_market}
	if side == "WIN":  # core 6: capstone, techs done, second market ... for the flavour lines of the win ending
		stats["flavour"] = EndingPicker.inputs(str(stats["market"]), balance, bazaar.stage(), bazaar.recap())
	if bazaar_panel != null:
		bazaar_panel.close_screen()
		bazaar_panel.close_wing_choice()
	stats["stages_done"] = bazaar.stage()
	stats["recap"] = bazaar.recap()  # T298: capital, stages, wings, worlds per tier, reclaimed worlds, decisive moments
	if bazaar.is_founded():
		stats["recap"]["capital_name"] = planet_name(bazaar.capital())  # T299
	if _end_screen_hold > 0.0 and is_inside_tree():  # T300: let the Opening beat play first
		var hold := _end_screen_hold
		_end_screen_hold = 0.0
		get_tree().create_timer(hold).timeout.connect(func() -> void:
			if is_instance_valid(self) and is_inside_tree():
				_open_end_screen().show_ending(ending_id, side, stats, stat))
	else:
		_open_end_screen().show_ending(ending_id, side, stats, stat)	if not run_recorded:  # local record, once per run
		run_recorded = true
		RunStats.record(side, ending_id, cycle, cash, "")
	run_ended.emit(side, ending_id)

## T259: Continue on the end screen: free play, no further endings. The save resumes with the next autosave.
func _continue_free_play() -> void:
	free_play = true
	game_over = false
	if end_screen != null:
		end_screen.queue_free()
		end_screen = null
	_refresh_panel()

## ---- T12 events ----

## Closed cycles a skill skips: reopen_sooner (BIO_6 Hardy Strains).
func _closed_bridge() -> int:
	return Skills.reopen_sooner()

## Dead worlds open at balance dead_unlock_cycle (15). Before it they are locked: no route, order or send from or to them.
func dead_unlock_cycle() -> int:
	return int(balance.get("dead_unlock_cycle", 0))

func _sync_dead_lock() -> void:
	var out: Array = []
	if cycle < dead_unlock_cycle():
		for i in map.planets.size():
			if DeadWorlds.is_dead(map.planets[i]):
				out.append(i)
	engine.dead_locked = out
	var shut: Array = out.duplicate()  # T179: no random event picks a world without a post or platform either
	for i in _discovery_closed():
		if not shut.has(i):
			shut.append(i)
	events.locked = shut

func _sync_closed() -> void:
	_sync_dead_lock()
	engine.closed_planets = events.closed_list(_closed_bridge())
	for i in _discovery_closed():  # T179: no trade, order, route or send touches a world without a post or platform
		if not engine.closed_planets.has(i):
			engine.closed_planets.append(i)
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
			if not Availability.feature("dead_danger_meter"):  # the meter is hidden: no notice names it
				return ""
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
		if open_systems.has(system_of(i)) and not engine.dead_locked.has(i):
			opts.append(i)
	if opts.is_empty():
		return -1
	var pl: int = int(opts[cycle % opts.size()])
	return clusters.spawn_small(system_of(pl), float(map.planets[pl].get("x", 0)), float(map.planets[pl].get("y", 0)))

## T156: the skill check that unlocks routing from a cluster: FND_PROSPECT (feature cluster_routes).
func can_mine() -> bool:
	return Skills.unlocked("cluster_routes")

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
		if storage.established(Storage.planet_key(i)) and planet_established(i):
			opts.append(i)
	return int(opts[events.rng.randi_range(0, opts.size() - 1)]) if not opts.is_empty() else -1

## Fires an event by id: shows its icon (no pause, no window). Non-choice events apply their effect now.
## A minor (price change) icon fades out; an important one waits for a click and blocks the next event until answered.
func fire_event(id: String) -> void:
	if id == "" or not events.by_id.has(id) or game_over or event_notice != null or events.pending_id != "":
		return
	events.pending_planet = events.pick_debris_planet() if id == "EV17" else -1
	if id == "EV17" and events.pending_planet < 0:
		return
	events.record(id, cycle, events.pending_planet)
	var minor: bool = events.is_minor(id)
	events.pending_id = "" if minor else id
	if events.choices_of(id).is_empty():
		_apply_effect(id, events.effect_of_event(id))
	if Chains.in_pool(id):  # shared pool: the optional small bot effect applies at once and is logged
		Chains.apply_pool(id, cycle)
	_refresh_event_feed()
	_event_beat()
	_add_event_icon(id, minor)
	_refresh()

## Icon seconds for a minor event, from balance (event_icon_seconds).
func event_icon_seconds() -> float:
	return float(balance.get("event_icon_seconds", 12.0))

func _event_planet(id: String) -> int:
	var p: int = events.named_planet(id)
	if p < 0 and id == events.pending_id:
		p = events.pending_planet
	return p

func _add_event_icon(id: String, minor: bool) -> void:
	if event_icons == null:
		return
	var args := {"planet": planet_name(events.pending_planet)} if events.pending_planet >= 0 else {}
	event_icons.add_icon(id, minor, events.title_of(id, args), event_icon_seconds(), _event_planet(id))

## Click on an event icon (also the QA hook): opens the event window, moves the map to the planet it names and rings that planet.
## The window pauses the game; closing it restores the earlier pause state. Returns false when nothing opened.
func open_event_icon(id: String) -> bool:
	if event_notice != null or game_over or not events.by_id.has(id):
		return false
	var planet := -1
	if event_icons != null:
		planet = int(event_icons.entry(id).get("planet", -1))
		event_icons.remove_icon(id)
	if planet < 0:
		planet = _event_planet(id)
	if not _event_pause_held:
		_event_prev_paused = paused
		_event_pause_held = true
	paused = true
	_focus_event_planet(planet)
	_open_event_notice(id)
	_refresh()
	return true

## T271: the gig arrival window may open now (no event window up, no important event waiting, run going).
func gig_window_free() -> bool:
	return event_notice == null and events.pending_id == "" and not game_over

## T271: the Flagship reached a signal marker. Reuses the event window: pauses like an event, two neutral options (none for a pure story gig).
func _on_gig_arrival(uid: String) -> void:
	var o: Dictionary = gigs.offer(uid)
	if o.is_empty() or not gig_window_free():
		return
	var g: Dictionary = {}
	for d in gigs.defs:
		if str(d.get("id", "")) == str(o["id"]):
			g = d
	var labels: Array = []
	for op in g.get("options", []):
		labels.append(StoryText.get_or(str(op.get("text", "")), str(op.get("id", ""))))
	if not _event_pause_held:
		_event_prev_paused = paused
		_event_pause_held = true
	paused = true
	event_notice = load("res://game/event_notice.gd").new()
	add_child(event_notice)
	event_notice.show_event(StoryText.get_or(str(g.get("title", "")), "Signal"), StoryText.get_or(str(g.get("body", "")), ""), "", labels, StoryText.get_text("MENU_CONTINUE"))
	event_notice.confirmed.connect(_on_gig_confirmed.bind(uid))
	_refresh()

func _on_gig_confirmed(choice: int, uid: String) -> void:
	var res: Dictionary = gigs.choose(uid, choice)
	_dismiss_event_notice()
	if res.is_empty():
		_release_event_pause()
		_refresh()
		return
	var text := StoryText.get_or(str(res["outcome"]), "") if str(res["outcome"]) != "" else ""
	var epi := StoryText.get_or(str(res["epilogue"]), "") if str(res["epilogue"]) != "" else ""
	event_notice = load("res://game/event_notice.gd").new()
	add_child(event_notice)
	event_notice.show_event(StoryText.get_or("GIG_DONE_TITLE", "Signal"), (text + "\n\n" + epi).strip_edges(), "\n".join(PackedStringArray(res["lines"])), [], StoryText.get_text("BTN_OK"))
	event_notice.confirmed.connect(func(_c: int):
		_dismiss_event_notice()
		_release_event_pause()
		_refresh()
		save_now())
	_refresh_panel()

## Moves the camera to a planet (its system when it is another one) and shows the halo on it.
func _focus_event_planet(planet: int) -> void:
	_event_hint_planet = -1
	map.set_event_hint(-1)
	if planet < 0 or planet >= map.planets.size() or planet >= map.positions.size():
		return
	var sys := int(map.planets[planet].get("system", 1))
	if sys != view_system and open_systems.has(sys):
		go_to_system(sys)
	if not map.planet_in_view(planet):
		return
	map.focus = map.positions[planet]
	map.clamp_focus()
	map._update_camera()
	_event_hint_planet = planet
	map.set_event_hint(planet)

## The event window closed for good: the halo goes and the pause state from before the click comes back.
func _release_event_pause() -> void:
	map.set_event_hint(-1)
	_event_hint_planet = -1
	if _event_pause_held:
		_event_pause_held = false
		paused = _event_prev_paused

## Id of the important event waiting for a click (icon up, window closed), "" when none.
func pending_event_icon() -> String:
	return events.pending_id if event_notice == null else ""

func _open_event_notice(id: String) -> void:
	_dismiss_event_notice()
	if events.is_chain_step(id):
		_open_chain_notice(id)
		return
	var ev: Dictionary = events.by_id[id]
	var choices: Array = events.choices_of(id)
	var args := {"planet": planet_name(events.pending_planet)} if events.pending_planet >= 0 else {}
	var labels: Array = []
	var off: Array = []
	var effs: Array = []
	for ch in choices:
		var cargs: Dictionary = args.duplicate()
		cargs.merge(events.choice_args(ch))  # branch option: {cash_in}, {market}
		var lbl: String = events.choice_text(ch, cargs)
		var fee := 0
		for e in events.choice_effects(ch):
			fee += _choice_fee(str(e.get("kind", "")), int(e.get("amount", 0)))
		if fee > 0:
			lbl = "%s (%d)" % [lbl, fee]
		labels.append(lbl)
		off.append(fee > 0 and cash < fee)
		if typeof(ch) == TYPE_DICTIONARY and ch.has("eff_id"):
			effs.append(StoryText.get_text(str(ch["eff_id"]), cargs))
	var line := effect_line(events.effect_of_event(id)) if choices.is_empty() else "\n".join(effs)
	var rv := Chains.pool_rivals_line(id)
	if events.is_branch(id):  # the written rivals line (EV<nn>_EFF) with {market}
		rv = StoryText.get_text(id + "_EFF", {"market": str(Markets.names.get(str(events.by_id[id]["branch"]), ""))})
	if rv != "":
		line = (line + "\n" + rv).strip_edges()
	event_notice = load("res://game/event_notice.gd").new()
	add_child(event_notice)
	event_notice.show_event(events.title_of(id, args), events.body_of(id, args), line, labels, StoryText.get_text("MENU_CONTINUE"), off, _event_art(id))
	event_notice.confirmed.connect(_on_event_confirmed.bind(id))
	if id == "EV20":
		map.hex_ring.show_ring(true)  # T110

## Banner path for an event id; EV20 keeps its drawn asteroid when the file is missing.
func _event_art(id: String) -> String:
	var path := "res://art/event_banners/%s.webp" % id.to_lower()  # files are lowercase; ids stay uppercase
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

## Credits a choice costs (debris fee, asteroid deflection), 0 when free.
func _choice_fee(kind: String, amount: int = 0) -> int:
	match kind:
		"debris_pay":
			return events.debris_fee()
		"asteroid_pay":
			return events.asteroid_cost()
	return 0

## T98: after a debris choice: popup with the outcome text, closed with OK.
func _debris_popup(ch, override: Dictionary = {}) -> void:
	if typeof(ch) != TYPE_DICTIONARY or not ch.has("popup_id"):
		return
	var args := {"planet": planet_name(events.pending_planet)}
	args.merge(events.choice_args(ch))
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
		_release_event_pause()
		_refresh()
		save_now())
	save_now()

## ---- market chains ----

## A chain step takes the event slot: records it, pauses, shows the two options (seeded order) with their effect lines.
func fire_chain_step(id: String) -> void:
	if game_over or event_notice != null or not Chains.has_step(id) or Chains.fired(id):
		return
	events.pending_planet = -1
	events.record(id, cycle, -1)
	events.pending_id = id
	_refresh_event_feed()
	_event_beat()
	_add_event_icon(id, false)
	_refresh()

func _open_chain_notice(id: String) -> void:
	var labels: Array = []
	for opt in Chains.visible_options(id):
		labels.append("%s\n%s" % [Chains.button(id, opt), Chains.eff_text(id, opt)])
	event_notice = load("res://game/event_notice.gd").new()
	add_child(event_notice)
	event_notice.show_event(events.title_of(id), events.body_of(id), "", labels, StoryText.get_text("MENU_CONTINUE"), [], "", Chains.body_id(id))
	event_notice.confirmed.connect(_on_event_confirmed.bind(id))

## The busiest route of a market for trip-cost effects: most ships, then level, then the lowest id. -1 when it has none.
func _busiest_route(market: String) -> int:
	var best := -1
	var key := [-1, -1]
	for rec in engine.routes:
		if Markets.market_of(str(rec["c"])) != market:
			continue
		var k := [int(rec.get("ships", 1)), int(rec.get("level", 1))]
		if best < 0 or k[0] > key[0] or (k[0] == key[0] and k[1] > key[1]):
			best = int(rec["id"])
			key = k
	return best

## T284: the world a market choice names for moods: where the market's busiest route ends ("" when it has none or ends at a cluster).
func _mood_world(market: String) -> String:
	var r := _busiest_route(market)
	if r < 0:
		return ""
	for rec in engine.routes:
		if int(rec["id"]) == r:
			var b := int(rec["b"])
			return str(map.planets[b].get("id", "")) if b >= 0 and b < map.planets.size() else ""
	return ""

## A button of a chain step was pressed (index in the shown order): the option applies at once, the result popup follows.
func _apply_chain_choice(choice: int, id: String) -> void:
	var order: Array = Chains.visible_options(id)
	if choice < 0 or choice >= order.size():
		return
	var opt := str(order[choice])
	var res: Dictionary = Chains.apply_option(id, opt, cycle, Callable(self, "_busiest_route"), _mood_world(Chains.market_of(id)))
	cash += int(res["cash"])
	for t in res["tech"]:
		craft_units(str(t[0]), int(t[1]))
	events.pending_id = ""
	_dismiss_event_notice()
	event_notice = load("res://game/event_notice.gd").new()
	add_child(event_notice)
	event_notice.show_event(Chains.result_title(id, opt), Chains.result_text(id, opt, res["rivals"]), "", [], StoryText.get_text("BTN_OK"), [], "", Chains.result_id(id, opt))
	event_notice.confirmed.connect(func(_c: int):
		_dismiss_event_notice()
		_release_event_pause()
		_refresh()
		save_now())
	_refresh()
	_refresh_panel()
	save_now()

func _on_event_confirmed(choice: int, id: String) -> void:
	if id != events.pending_id:  # a minor event read from its icon: nothing to answer, nothing pending to clear
		_dismiss_event_notice()
		_release_event_pause()
		_refresh()
		return
	if events.is_chain_step(id):
		_apply_chain_choice(choice, id)
		return
	if id == "EV20":
		map.hex_ring.show_ring(false)  # T110
	if choice >= 0:
		var choices: Array = events.choices_of(id)
		if choice < choices.size():
			events.schedule_follow(choices[choice], cycle)  # R1: a choice may schedule a later event
			if events.is_branch(id) and typeof(choices[choice]) == TYPE_DICTIONARY:
				Chains.note_branch(id, bool(choices[choice].get("dark", false)), cycle, _mood_world(str(choices[choice].get("market", ""))))  # T284 mood mark
			if typeof(choices[choice]) == TYPE_DICTIONARY and bool(choices[choice].get("dark", false)):
				events.dark_choice()  # hidden: may mark the run as spotted (see Events.dark_choice); nothing is shown
			var over := {}
			for eff in events.choice_effects(choices[choice]):
				var o := _apply_effect(id, eff)
				if not o.is_empty():
					over = o
			if typeof(choices[choice]) == TYPE_DICTIONARY and choices[choice].has("popup_id"):
				_debris_popup(choices[choice], over)
				return
	events.pending_id = ""
	_dismiss_event_notice()
	_release_event_pause()
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
	if not OS.is_debug_build() or game_over or ships >= ship_cap():
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

func debug_restart_tutorial() -> void:
	if not OS.is_debug_build():
		return
	tut_first = {}
	tut_step = 0
	tut_skipped = []
	tut_flags = {}
	tut_goal_t = 0.0
	galaxy_seen = false
	cycle = 1
	trade_income_total = 0
	storage_notice_done = false
	_sync_earn()
	_sync_dead_lock()
	cycle_elapsed = 0.0
	_tut_show()
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
	if event is InputEventKey and event.keycode == KEY_B and not event.echo and flight != null and flight.is_enabled():  # T270: hold B to boost
		set_flagship_boost(event.pressed and dock_sheet == null)
		return
	if dock_sheet != null:  # T270: the dock sheet is modal; Esc undocks, Space does not unpause
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			dock_sheet.close_sheet()
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
		elif bazaar_panel.visible:
			bazaar_panel.close_screen()
		elif gig_panel.visible:
			gig_panel.close_screen()
		elif space_storage_view.visible:
			space_storage_view.close_view()
		elif cluster_info != null and cluster_info.visible:
			_hide_cluster_info()
		elif game_menu.visible:
			game_menu.close_menu()
		elif map.ship_selected:  # T200: Esc deselects the Pathfinder first
			map.ship_selected = false
		else:
			game_menu.open_menu()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_G:
		toggle_galaxy()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_K:
		toggle_skills()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
		toggle_bazaar_panel()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_J:
		toggle_gig_board()
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
	goal_label.visible = false  # T263: the market-share goal line gives way to the Next Up strip
	next_up = load("res://game/next_up.gd").new()
	box.add_child(next_up)
	next_up.setup(self)
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

## Along the edges of the system screen, as in SystemView.html: system name top middle, key hints bottom left. None of it takes map clicks.
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
	event_icons = load("res://game/event_icons.gd").new()
	event_icons.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	event_icons.grow_horizontal = Control.GROW_DIRECTION_BOTH
	event_icons.offset_top = 120
	event_icons.clicked.connect(open_event_icon)
	add_child(event_icons)
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
	bazaar_button = _rail_button("mark", "BAZ_PANEL_TITLE", "The Star Bazaar", toggle_bazaar_panel)  # T263: where the share panel button was
	bazaar_button.tooltip_text += " (M)"
	col.add_child(bazaar_button)
	gig_button = _rail_button("planet", "GIG_BOARD_TITLE", "Gig board", toggle_gig_board)  # T273
	gig_button.tooltip_text += " (J)"
	col.add_child(gig_button)

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
	goal_label.text = StoryText.get_or("LBL_GOAL_MARKETS", "Goal: more than {pct}% of one market", {"pct": roundi(float(balance.get("win_share_pct", 0.5)) * 100.0)})
	if bazaar_panel != null:
		bazaar_panel.refresh()
	if gig_button != null:
		gig_button.visible = flight != null and flight.is_enabled()
	if next_up != null:
		next_up.refresh()
	goal_label.tooltip_text = ""
	if second_lane_active():  # N11: the optional line follows the goal; the full text is also the tooltip
		goal_label.tooltip_text = goal_label.text + "  " + second_lane_line()
		goal_label.text = goal_label.tooltip_text
	Juice.count_to(cash_label, cash, "%d", Ui.col("signal_good"))  # counts up; a rise flashes green
	var net: int = cash_forecast.net_forecast() if cash_forecast != null else 0
	delta_label.text = "%+d" % net
	cycle_label.text = "%d / %d" % [cycle, int(balance.get("win_cycle_markets", 0))]
	cycle_label.tooltip_text = "Cycle"
	progress.value = cycle_elapsed / _cycle_seconds()
	pause_button.text = ""  # icon only (owner item 1)
	pause_button.disabled = game_over
	pause_button.tooltip_text = (StoryText.get_or("MENU_RESUME", "Resume") if paused else StoryText.get_or("MENU_PAUSE", "Pause")) + " (Space)"
	pause_button.icon = Ui.icon("play" if paused else "pause")
	pause_button.modulate = Ui.col("signal_warn") if paused else Color.WHITE
	for i in speed_buttons.size():
		speed_buttons[i].button_pressed = SPEEDS[i] == time_speed
	var star := " *" if SkillTree.any_affordable(learned_skills, skill_points, balance) else ""
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
		ship_panel.set_count(ships, ship_cap())
		ship_panel.set_upkeep(self)
		var target: int = mission_planet if ships == 0 else -1  # halo on the planet that sells the first ship
		if tut_card != null and tut_card.visible and _tut_ring_planet() >= 0:
			target = _tut_ring_planet()  # the guided step is about the map planet
		map.set_hint(target, target >= 0)
		mission_label.visible = ships == 0
		mission_label.text = StoryText.get_or("LBL_MISSION_FIRST", "Mission: Send stock to another planet")

## The guided tutorial card: text of the current step, step count, Skip and Next. Ids load from the story loader.
## T180: with discovery on, the first guided step shows the Pathfinder card (fly, build, wait) until the first post beyond
## the home world stands. "" when discovery is off or the flight steps are over. Read from the accessor on every call.
func _tut_g0_id() -> String:
	var f = map.flight if map != null else null
	if tut_step != 0 or not PathfinderView.active(f):
		return ""
	var built := 0
	for p in map.planets:
		if PathfinderView.established(f, str(p.get("id", ""))):
			built += 1
	if built > 1:
		return ""
	if PathfinderView.state(f) == "building":
		return "TUT_G0_WAIT"
	var here := PathfinderView.docked_at(f)
	if here != "" and not PathfinderView.established(f, here):
		return "TUT_G0_BUILD"
	return "TUT_G0_FLY"

## Story id of guided step i (the flight card replaces step 0 while it applies).
func _tut_id(i: int) -> String:
	var g := _tut_g0_id() if i == 0 else ""
	return g if g != "" else TUT_GUIDE[i]

## T180: map orders go to the flight accessor; its refusal reason becomes a NOT_* notice. No accessor: nothing happens.
func _on_fly_requested(target: Dictionary) -> void:
	_dock_after = ""  # T270: a new order cancels a pending dock
	var f = map.flight
	if not PathfinderView.active(f):
		return
	var r = PathfinderView._call(f, "request_fly", [target], "")
	_flight_notice(r)
	on_flight_changed()  # T228: a manual order ends exploration mode; the panel must show it while paused

## T200: right-click menu on a planet with the ship selected: one item per allowed action (flight.actions_for), nothing else drawn.
## Choosing one flies there and establishes on arrival (the accessor starts the build when the ship docks).
func _on_action_menu_requested(planet_id: String, screen_pos: Vector2) -> void:
	var f = map.flight
	if not PathfinderView.active(f):
		return
	var acts: Array = PathfinderView._call(f, "actions_for", [planet_id], [])
	if PathfinderView.established(f, planet_id):  # T270: an established world offers Dock and trade
		acts = acts.duplicate()
		acts.append("dock")
	if acts.is_empty():
		return
	if _action_menu != null:
		_action_menu.queue_free()
	_action_menu = PopupMenu.new()
	_action_menu.name = "ShipActionMenu"
	for k in acts.size():
		var a := str(acts[k])
		var txt := StoryText.get_or("BTN_ESTABLISH_PLATFORM" if a == "establish_platform" else "BTN_ESTABLISH_POST",
			"Establish mining platform" if a == "establish_platform" else "Establish trading post")
		if a == "dock":
			txt = StoryText.get_or("BTN_DOCK", "Dock and trade")
		_action_menu.add_item(txt, k)
	_action_menu.id_pressed.connect(func(id: int):
		if id >= 0 and id < acts.size():
			if str(acts[id]) == "dock":
				request_dock(planet_id)
			else:
				_dock_after = ""
				_on_fly_establish_requested(planet_id))
	add_child(_action_menu)
	_action_menu.popup_on_parent(Rect2i(Vector2i(screen_pos), Vector2i.ZERO))

## T270: 'Dock and trade'. Docked there: open the sheet now; otherwise fly there and open it on arrival.
func request_dock(planet_id: String) -> void:
	var f = map.flight
	if not PathfinderView.active(f):
		return
	if not PathfinderView.established(f, planet_id):
		post_notice_now(StoryText.get_or("NOT_DOCK_NO_POST", "Establish a trading post here to dock and trade."))
		return
	if flight.state() == "idle" and flight.docked_at() == planet_id:
		_dock_after = ""
		open_dock_sheet()
		return
	var r = PathfinderView._call(f, "request_fly", [{"kind": "planet", "pos": map.positions[planet_index_of(planet_id)], "index": planet_index_of(planet_id)}], "")
	_flight_notice(r)
	_dock_after = planet_id if r == "" else ""
	on_flight_changed()

## T270: opens the dock sheet at the world the Flagship is docked at; pauses like the event window. False when it cannot.
func open_dock_sheet() -> bool:
	if dock_sheet != null or game_over or event_notice != null or preface != null:
		return dock_sheet != null
	var i: int = flight.dock_planet()
	if i < 0:
		post_notice_now(StoryText.get_or("NOT_DOCK_FAR", "Fly the Flagship here first."))
		return false
	dock_sheet = load("res://game/dock_sheet.gd").new()
	add_child(dock_sheet)
	_dock_was_paused = paused
	paused = true
	dock_sheet.open(self, i)
	dock_sheet.closed.connect(_on_dock_closed)
	_refresh()
	return true

func _on_dock_closed() -> void:
	dock_sheet = null
	paused = _dock_was_paused
	_refresh()
	save_now()

## T270: boost on/off (hold key B or the ship panel button). A refusal becomes a notice.
func set_flagship_boost(on: bool) -> void:
	var r: String = flight.set_boost(on) if flight != null and flight.is_enabled() else ""
	if r == "no_fuel":
		post_notice_now(StoryText.get_or("NOT_BOOST_NO_ENERGY", "No energy in the hold to boost."))
	elif r == "no_charges":
		post_notice_now(StoryText.get_or("NOT_BOOST_EMPTY", "Boost is recharging."))

func _on_fly_establish_requested(planet_id: String) -> void:
	var f = map.flight
	if not PathfinderView.active(f):
		return
	var r = PathfinderView._call(f, "request_fly_establish", [planet_id], "")
	_flight_notice(r)
	on_flight_changed()  # T228

func _on_flight_establish_failed(_planet_id: String, reason: String) -> void:
	_flight_notice(reason)

func _on_establish_requested(planet_id: String) -> void:
	var f = map.flight
	if not PathfinderView.active(f):
		return
	var r = PathfinderView._call(f, "request_establish", [planet_id], "")
	_flight_notice(r)

## ---- T179: the Pathfinder, discovery and the headless API --------------------------------------------------------------

## Game time in cycles: whole cycles done plus the part of this one. The flight clock; it only moves while the game runs.
func game_time() -> float:
	return float(cycle - 1) + cycle_elapsed / maxf(0.001, _cycle_seconds())

func planet_index_of(planet_id: String) -> int:
	for i in map.planets.size():
		if str(map.planets[i].get("id", "")) == planet_id:
			return i
	return -1

## True when the planet may be traded, ordered, routed, sent to or stored on: its availability rule "planet" holds (a trading
## post or mining platform stands, or discovery is off). Clusters, stations and unknown indexes are never closed by this.
func planet_established(i: int) -> bool:
	if flight == null or i < 0 or i >= map.planets.size():
		return true
	return Availability.planet(str(map.planets[i].get("id", "")))

func _discovery_closed() -> Array:
	var out: Array = []
	for i in map.planets.size():
		if not planet_established(i):
			out.append(i)
	return out

func closed_world_reason() -> String:
	return StoryText.get_or("NOT_FLY_FIRST", "Fly the Pathfinder here first.")

## Condition atoms planet_visited, post_built, platform_built (game/conditions.gd). True for every planet while discovery is off.
func planet_atom(kind: String, planet_id: String) -> bool:
	if flight == null or not flight.is_enabled():
		return true
	match kind:
		"planet_visited":
			return flight.discovered(planet_id)
		"post_built":
			return flight.post_built(planet_id)
		"platform_built":
			return flight.platform_built(planet_id)
	return false

## The Pathfinder changed what is open (arrival, post, platform, a debug flag): engine gates, panel and map follow.
func on_flight_changed() -> void:
	_sync_closed()
	_push_routes_to_map()
	_refresh_panel()
	_refresh()

func _on_flight_arrived(planet_id: String) -> void:
	if _dock_after == planet_id:  # T270: the ordered dock opens its sheet on arrival
		_dock_after = ""
		if open_dock_sheet():
			return
	post_notice(StoryText.get_or("NOT_PATHFINDER_ARRIVED", "The Pathfinder arrived at {planet}.", {"planet": planet_name(planet_index_of(planet_id))}))

func _on_flight_build_done(planet_id: String) -> void:
	var i := planet_index_of(planet_id)
	var dead: bool = i >= 0 and DeadWorlds.is_dead(map.planets[i])
	post_notice(StoryText.get_or("NOT_PLATFORM_DONE" if dead else "NOT_POST_DONE", "Established at {planet}.", {"planet": planet_name(i)}))
	on_flight_changed()
	map.establish_beat(i, Ui.col("star_warm" if dead else "signal_good"))  # T203: ring, sparkle, label pop, soft nudge
	save_now()

## T206: exploration mode. Button in the ship panel; tests and bots call set_exploring directly.
func set_exploring(on: bool) -> void:
	flight.set_exploring(on)
	on_flight_changed()  # T228: label and button update at once, also while paused

func _on_exploration_done() -> void:
	post_notice(StoryText.get_text("NOT_EXPLORE_DONE"))
	save_now()
	_refresh_panel()

func _on_flight_build_cancelled(_planet_id: String) -> void:
	post_notice_now(StoryText.get_or("NOT_POST_LEAVE", "Leaving cancels the build."))

## QA bots and tests: order the Pathfinder to a planet by id. "" accepted, else a reason (see game/pathfinder.gd). Quiet: no notice.
func fly_to(planet_id: String) -> String:
	var i := planet_index_of(planet_id)
	if i < 0:
		return "bad_target"
	return str(flight.request_fly({"kind": "planet", "pos": map.positions[i], "index": i}))

## QA bots and tests: start the post or platform at the planet the Pathfinder is docked at. "" accepted, else the reason.
func establish(planet_id: String) -> String:
	return str(flight.request_establish(planet_id))

## QA bots: {enabled, state, docked, build, target, eta (to each planet id), post, platform} of the Pathfinder.
func flagship_state() -> Dictionary:
	var eta := {}
	var post := {}
	var plat := {}
	for p in map.planets:
		var pid := str(p.get("id", ""))
		eta[pid] = flight.eta_cycles(pid)
		post[pid] = flight.post_built(pid)
		plat[pid] = flight.platform_built(pid)
	return {"enabled": flight.is_enabled(), "state": flight.state(), "docked": flight.docked_at(), "build": flight.build_target(), "target": flight.target(), "eta": eta, "post": post, "platform": plat}

## Debug only (QA bots): fly there and arrive at once. Returns "" or the reason.
func debug_fly_now(planet_id: String) -> String:
	if not debug_tools_allowed():
		return "debug_off"
	var r := fly_to(planet_id)
	if r == "":
		flight.finish_flight()
	return r

## Debug only (QA bots): fly there, establish (cost is paid as normal) and finish the build at once. Returns "" or the reason.
func debug_establish_now(planet_id: String) -> String:
	if not debug_tools_allowed():
		return "debug_off"
	var r := debug_fly_now(planet_id)
	if r != "":
		return r
	r = establish(planet_id)
	if r == "":
		flight.finish_build()
	return r

## Debug only: every planet gets its post or platform (same as discovery off, but the ship stays).
func debug_open_all_planets() -> void:
	if debug_tools_allowed():
		flight.open_all()

## The accessor returns "" for success or a refusal reason: "fly_first", "no_cash_post", "no_cash_platform", "busy".
func _flight_notice(reason) -> void:
	var ids := {"fly_first": ["NOT_FLY_FIRST", "Fly the Pathfinder here first."],
		"no_cash_post": ["NOT_POST_NO_CASH", "Not enough credits to establish a trading post here."],
		"no_cash_platform": ["NOT_PLATFORM_NO_CASH", "Not enough credits to establish a mining platform here."],
		"busy": ["NOT_POST_BUSY", "The Pathfinder is already building. One build at a time."]}
	var k := str(reason)
	if ids.has(k):
		post_notice_now(StoryText.get_or(ids[k][0], ids[k][1]))

func _tut_show(_ids: Array = []) -> void:
	if tutorial_label == null:
		return
	tut_show_count += 1
	var guided: bool = tut_step < TUT_GUIDE.size()
	var t := ""
	if guided:
		var id: String = _tut_id(tut_step)
		if _tut_picking():
			id = "TUT_G3_PICK"  # heading only; the why line and voice stay on the step
		t = StoryText.get_or(id, str(TUT_FALLBACK.get(id, "")), {}).strip_edges()
	tutorial_label.text = t
	if guided and t != "" and not game_over:
		if _voiced_tut != tut_step:  # _tut_show runs often; speak a step once
			_voiced_tut = tut_step
			Voice.play(_tut_id(tut_step) + "_WHY")  # the heading is on screen; only the why line is spoken
	else:
		_voiced_tut = -1
		Voice.stop_prefix("TUT_")
	tutorial_label.visible = t != "" and guided and not game_over
	if tut_card != null:
		tut_card.visible = tutorial_label.visible
		tut_count.visible = guided
		tut_why.text = StoryText.get_or(_tut_id(tut_step) + "_WHY", "", {}) if guided else ""
		tut_why.visible = tut_why.text != ""
		if guided:
			tut_count.text = StoryText.get_or("TUT_STEP_COUNT", "{n} of {total}", {"n": tut_step + 1, "total": TUT_GUIDE.size()})
	if tut_actions != null:  # Skip only while the guided steps run
		tut_actions.visible = tutorial_label.visible
	_tut_update_highlight()

## A guided step's action happened (key: "expenses", "storage"): remember it and move the tutorial on.
func tut_note(key: String) -> void:
	tut_flags[key] = true  # _tut_poll sees the flag change and moves the card

## The last step has no action: it closes by itself after TUT_LAST_SECS real seconds (called from _process).
func _tut_tick(delta: float) -> void:
	if tut_step != TUT_GUIDE.size() - 1 or tut_card == null or not tut_card.visible:
		tut_goal_t = 0.0
		return
	tut_goal_t += delta
	if tut_goal_t >= TUT_LAST_SECS:
		tut_goal_t = 0.0
		tut_step = TUT_GUIDE.size()
		_tut_show()

## Skip ends the whole tutorial, the galaxy view one too (it never starts once skipped). Saved as tut_step = size.
func _tut_skip() -> void:
	tut_step = TUT_GUIDE.size()
	galaxy_seen = true
	if galaxy_view != null and galaxy_view.tut_step >= 0 and galaxy_view.tut_step < galaxy_view.TUT_IDS.size():
		galaxy_view.tut_step = galaxy_view.TUT_IDS.size()
		galaxy_view._build_tutorial()
	_tut_show()

## Which control each guided step is about. "planet" = the pulsing ring on the map planet, "" = nothing.
const TUT_TARGET := ["planet", "buy", "send", "time", "expenses", "sell", "storage", "skills", "permit", ""]

func _tut_first_named(root: Node, prefix: String) -> Control:
	var found: Control = null
	for n in root.find_children(prefix + "*", "Control", true, false):
		var c := n as Control
		if c == null or not c.is_visible_in_tree():
			continue
		if c is BaseButton and (c as BaseButton).disabled:
			found = found if found != null else c  # an enabled one is preferred
			continue
		return c
	return found

## The control for a target key, or null when it is not on screen at this moment.
func _tut_target_node(key: String) -> Control:
	var c: Control = null
	match key:
		"buy": c = _tut_first_named(planet_panel, "BuyButton_")
		"send", "sell", "storage": c = _tut_first_named(planet_panel, "BuyButton_")  # Send, Sell and the stock figure now live on the resource button (right-click menu)
		"route":
			for n in planet_panel.find_children("*", "HBoxContainer", true, false):
				if n.has_meta("tut_target") and n.get_meta("tut_target") == "route" and (n as Control).is_visible_in_tree():
					c = n
					break
			if c == null and ship_panel != null and ship_panel.label != null and ship_panel.label.is_visible_in_tree():
				c = ship_panel.label  # no planet panel route row: the ship panel line
		"time":
			if paused:
				c = pause_button  # time is stopped: the speed buttons do not resume it, so point at Play
			else:
				for i in speed_buttons.size():
					if SPEEDS[i] == time_speed:
						c = speed_buttons[i]
		"expenses": c = cash_box
		"skills": c = points_button
		"permit":
			if skill_screen != null and skill_screen.visible and skill_screen.node_buttons.has("FND_PERMIT"):
				c = skill_screen.node_buttons["FND_PERMIT"]
			else:
				c = points_button  # the Skills window is closed: point at the button that opens it
	if c != null and c.is_visible_in_tree() and c.size.x > 0.0:
		var sc := right_col.get_parent() as Control if right_col != null else null
		if sc != null and sc.is_ancestor_of(c) and not sc.get_global_rect().encloses(c.get_global_rect()):
			return null  # scrolled out of the column
		return c
	return null

## "planet" when the step is about the map planet, or when its control is not on screen now. "" = no highlight.
func _tut_highlight_key() -> String:
	if _tut_picking():
		return "planet"
	if tut_step >= TUT_TARGET.size() or TUT_TARGET[tut_step] == "":
		return ""
	var key: String = TUT_TARGET[tut_step]
	var lt := tut_lock_target()
	if lt >= 0 and selected_planet != lt and key in ["buy", "send", "sell"]:
		return "planet"  # the right planet is not open yet: point at it first
	if key != "planet" and _tut_target_node(key) == null:
		return "planet"
	return key

## ---- Guided route lock: while steps 0 to 5 run, only the one profitable route is allowed (Energy, Voltara -> Ashgate). ----
## Derived from tut_step and state on every call; no handler switches it. Ends on skip, finish (step >= 6) and game over.
const TUT_PLANET_FROM := "planet_1"
const TUT_PLANET_TO := "planet_3"
const TUT_GOOD := "energy"

## Map index of a planet by its data id, or -1.
func _tut_idx(id: String) -> int:
	if map == null:
		return -1
	for i in map.planets.size():
		if typeof(map.planets[i]) == TYPE_DICTIONARY and str(map.planets[i].get("id", "")) == id:
			return i
	return -1

## True when the guided step cannot be done as locked (data missing, trade closed, no ship), so the lock lets go instead of blocking.
func _tut_lock_released() -> bool:
	var v := _tut_idx(TUT_PLANET_FROM)
	var a := _tut_idx(TUT_PLANET_TO)
	if v < 0 or a < 0 or not commodities.has(TUT_GOOD):
		return true
	match tut_step:
		1:
			return not (system_trade_open(v) and bool(engine.check_local(v, TUT_GOOD, "buy")["ok"]))
		2:
			if not bool(engine.check_connection(v, a, TUT_GOOD)["ok"]):
				return true
			return free_ships() <= 0 and not bool(can_buy_ship()["ok"])
		3:
			return engine.routes.is_empty()  # nothing to wait for
		5:
			return not (system_trade_open(a) and bool(engine.check_local(a, TUT_GOOD, "sell")["ok"]))
	return false

## The guided step the lock holds (0 to 5), or -1 when nothing is locked.
func tut_lock_step() -> int:
	if game_over or tut_step < 0 or tut_step > 5 or map == null or engine == null:
		return -1
	return -1 if _tut_lock_released() else tut_step

func tut_lock_active() -> bool:
	return tut_lock_step() >= 0

## May the player do this now? Actions: select (planet), buy / sell (planet, good), send_start (planet, good),
## send (src planet, good, dst), other (everything else). Time, Expenses, Skip and cancel are never locked.
func tut_allows(action: String, planet: int = -1, good: String = "", dst: int = -1) -> bool:
	var s := tut_lock_step()
	if s < 0:
		return true
	var v := _tut_idx(TUT_PLANET_FROM)
	var a := _tut_idx(TUT_PLANET_TO)
	var e := good == TUT_GOOD
	match action:
		"select":
			match s:
				0, 1:
					return planet == v
				2:
					return planet == (a if not pending.is_empty() else v)
				5:
					return planet == a
			return false
		"buy":
			return e and planet == v and (s == 1 or s == 2)
		"sell":
			return e and planet == a and s == 5
		"send_start":
			return s == 2 and e and planet == v
		"send":
			return s == 2 and e and planet == v and dst == a
	return false

func tut_lock_text() -> String:
	return StoryText.get_or("NOT_TUT_LOCKED", "Follow the tutorial step, or skip the tutorial.")

## Allowed: true. Refused: posts the one short notice and returns false.
func tut_gate(action: String, planet: int = -1, good: String = "", dst: int = -1) -> bool:
	if tut_allows(action, planet, good, dst):
		return true
	post_notice_now(tut_lock_text())
	return false

## A Buy or Sell toggle: only turning the allowed order ON passes.
func tut_gate_order(planet: int, c: String, role: String) -> bool:
	return tut_gate(role if not engine.local_on(planet, c, role) else "other", planet, c)

## Planet the locked step points at, or -1: Voltara for select/buy/send, Ashgate for the destination and the sell.
func tut_lock_target() -> int:
	match tut_lock_step():
		0, 1:
			return _tut_idx(TUT_PLANET_FROM)
		2:
			return _tut_idx(TUT_PLANET_TO if not pending.is_empty() else TUT_PLANET_FROM)
		5:
			return _tut_idx(TUT_PLANET_TO)
	return -1

## Guided send step (index 2) with a send pending: the player now has to click a destination planet.
func _tut_picking() -> bool:
	return tut_step == 2 and tut_step < TUT_GUIDE.size() and not pending.is_empty()

## A planet that takes the pending good (same system first), or -1. Uses the engine's connection check and the trade margin.
func _tut_pick_planet() -> int:
	if pending.is_empty():
		return -1
	var src := int(pending["planet"])
	var c := str(pending["c"])
	if tut_lock_step() == 2:
		return _tut_idx(TUT_PLANET_TO)  # the guided route goes to Ashgate only
	var best := -1
	for i in trade.planets.size():
		if i == src or not bool(engine.check_connection(src, i, c)["ok"]) or trade.margin(src, i, c) <= 0:
			continue
		if system_of(i) == system_of(src):
			return i
		if best < 0:
			best = i
	return best

## Map planet the ring marks for the current step: the selected one, else the mission planet.
func _tut_ring_planet() -> int:
	if _tut_picking():
		return _tut_pick_planet()
	if _tut_highlight_key() != "planet":
		return -1
	var lt := tut_lock_target()
	if lt >= 0:
		return lt
	return selected_planet if selected_planet >= 0 else mission_planet

func _tut_update_highlight() -> void:
	if tut_hl == null:
		return
	var key := _tut_highlight_key()
	var c: Control = _tut_target_node(key) if key != "" and key != "planet" else null
	var shown: bool = tut_card != null and tut_card.visible and not game_over and not (galaxy_view != null and galaxy_view.visible)
	if c == null or not shown:
		tut_hl.visible = false
	else:
		var r := c.get_global_rect().grow(3.0)
		tut_hl.visible = true
		tut_hl.global_position = r.position
		tut_hl.size = r.size
		var k := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * 3.0)
		tut_hl.modulate.a = lerpf(0.55, 1.0, k)
	_tut_place_card(key, c)

const TUT_CARD_W := 300.0
const TUT_GAP := 18.0  # card to target; the pointer sits in this gap
const TUT_EDGE := 8.0

## Screen rect the card keeps clear: the target, or the whole panel the target sits in.
func _tut_anchor_rect(key: String, c: Control) -> Rect2:
	if c != null:
		if planet_panel != null and planet_panel.visible and planet_panel.is_ancestor_of(c):
			return planet_panel.get_global_rect().grow(4.0)
		var sc := right_col.get_parent() as Control if right_col != null else null
		if sc != null and sc.is_ancestor_of(c):
			return sc.get_global_rect().grow(4.0)
		return c.get_global_rect().grow(6.0)
	if key == "planet":
		var i := _tut_ring_planet()
		if i >= 0 and map.camera != null and i < map.positions.size() and map.planet_in_view(i) and not map.camera.is_position_behind(map.positions[i]):
			var p: Vector2 = map.camera.unproject_position(map.positions[i])
			return Rect2(p - Vector2(40, 40), Vector2(80, 80))
	return Rect2()

## Puts the card beside the target on a side with room, inside the window, clear of the other panels, with a pointer.
func _tut_place_card(key: String, c: Control) -> void:
	if tut_card == null or not tut_card.visible:
		if tut_arrow != null:
			tut_arrow.visible = false
		return
	tut_card.size = Vector2(TUT_CARD_W, 0.0)  # height shrinks to what the text needs
	var cs := tut_card.size
	var vp := get_viewport_rect().size
	var a := _tut_anchor_rect(key, c)
	if a.size == Vector2.ZERO:  # nothing to point at: a fixed spot under the top bar, middle of the window
		tut_card.position = Vector2((vp.x - cs.x) * 0.5, 84.0)
		tut_arrow.visible = false
		return
	var avoid: Array = [a]
	if planet_panel != null and planet_panel.visible and not planet_panel.get_global_rect().intersects(a):
		avoid.append(planet_panel.get_global_rect().grow(4.0))
	var sc := right_col.get_parent() as Control if right_col != null else null
	if sc != null and not sc.get_global_rect().intersects(a):
		avoid.append(sc.get_global_rect().grow(4.0))
	var tpt: Vector2 = c.get_global_rect().get_center() if c != null else a.get_center()
	var order: Array = ["below", "right", "left", "above"] if a.position.y < 90.0 and a.size.y < 120.0 else ["right", "left", "below", "above"]
	tut_place_beside(tut_card, tut_arrow, a, avoid, tpt, order)

## Shared by the board card and the galaxy view card: puts `card` beside the rect `a` on the first side in `order` with
## room (inside the window, clear of every rect in `avoid`), and points `arrow` from the gap at `tpt`. Both use window coordinates.
func tut_place_beside(card: Control, arrow: Polygon2D, a: Rect2, avoid: Array, tpt: Vector2, order: Array) -> void:
	var cs := card.size
	var vp := get_viewport_rect().size
	var field := Rect2(Vector2(TUT_EDGE, TUT_EDGE), vp - Vector2(TUT_EDGE, TUT_EDGE) * 2.0)
	var tx := tpt.x
	var ty := tpt.y
	var best := Vector2.ZERO
	var best_side := ""
	for side in order:
		var pos := Vector2.ZERO
		match side:
			"right": pos = Vector2(a.end.x + TUT_GAP, ty - cs.y * 0.5)
			"left": pos = Vector2(a.position.x - TUT_GAP - cs.x, ty - cs.y * 0.5)
			"below": pos = Vector2(tx - cs.x * 0.5, a.end.y + TUT_GAP)
			"above": pos = Vector2(tx - cs.x * 0.5, a.position.y - TUT_GAP - cs.y)
		pos.x = clampf(pos.x, field.position.x, maxf(field.position.x, field.end.x - cs.x))
		pos.y = clampf(pos.y, field.position.y, maxf(field.position.y, field.end.y - cs.y))
		var r := Rect2(pos, cs)
		var clear := true
		for av in avoid:
			if r.intersects(av):
				clear = false
				break
		if best_side == "" or clear:
			best = pos
			best_side = side
		if clear:
			break
	card.position = best
	# pointer: a small triangle in the gap, tip toward the target
	var tip := Vector2.ZERO
	var rot := 0.0
	match best_side:
		"right":
			tip = Vector2(a.end.x + 2.0, clampf(ty, best.y + 14.0, best.y + cs.y - 14.0)); rot = PI
		"left":
			tip = Vector2(a.position.x - 2.0, clampf(ty, best.y + 14.0, best.y + cs.y - 14.0)); rot = 0.0
		"below":
			tip = Vector2(clampf(tx, best.x + 14.0, best.x + cs.x - 14.0), a.end.y + 2.0); rot = -PI * 0.5
		"above":
			tip = Vector2(clampf(tx, best.x + 14.0, best.x + cs.x - 14.0), a.position.y - 2.0); rot = PI * 0.5
	arrow.visible = true
	arrow.position = tip
	arrow.rotation = rot

## The pulsing outline panel and the pointer triangle, built once per owner (board and galaxy view look the same).
func tut_make_hl() -> Panel:
	var hl := Panel.new()
	hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hl.z_index = 50
	hl.visible = false
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = Ui.col("star_warm")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(4)
	hl.add_theme_stylebox_override("panel", sb)
	return hl

func tut_make_arrow() -> Polygon2D:
	var ar := Polygon2D.new()  # triangle with its tip at the origin, pointing along +x before rotation
	ar.polygon = PackedVector2Array([Vector2(0, 0), Vector2(-14, -9), Vector2(-14, 9)])
	ar.color = Ui.col("star_warm")
	ar.visible = false
	return ar

## The card is derived from game state: every frame a cheap signature of what it depends on is compared with the last one;
## only when it differs does the tutorial advance and the card refresh. No handler has to call the tutorial.
func _tut_sig_now() -> Array:
	var sig: Array = [tut_step, game_over, tutorial_label == null, _tut_g0_id()]
	sig.append(tut_lock_step())
	if tut_step >= TUT_GUIDE.size():
		return sig
	var buys := 0
	var sells := 0
	for o in engine.local.values():
		buys += int(bool(o["buy"]))
		sells += int(bool(o["sell"]))
	sig.append_array([
		pending.is_empty(), str(pending.get("c", "")), int(pending.get("planet", -1)), selected_planet, paused, time_speed,
		engine.routes.size(), buys, sells, tut_flags.size(), learned_skills.size(), skill_points, cycle,
		planet_panel != null and planet_panel.visible, skill_screen != null and skill_screen.visible,
		galaxy_view != null and galaxy_view.visible, tut_card != null and tut_card.visible])
	if tut_step == 6:  # the only step that reads storage stock
		var held := 0
		for k in storage.stock.keys():
			if not str(k).begins_with("system"):
				for n in storage.stock[k].values():
					held += int(n)
		sig.append(held)
	return sig

func _tut_poll() -> void:
	var sig := _tut_sig_now()
	if sig == _tut_sig:
		return
	_tut_sig = sig
	_tut_advance()
	_tut_show()
	var ls := tut_lock_step()
	if ls != _tut_lock_seen:  # the lock moved: dim or free the panel buttons
		_tut_lock_seen = ls
		_refresh_panel()
		if ship_panel != null:
			ship_panel.set_upkeep(self)
	_tut_sig = _tut_sig_now()  # the advance may have moved the step

## T124: moves the guided tutorial on when the player has done the current step. Run by _tut_poll when the state it reads changes.
func _tut_advance() -> void:
	var moved := false
	while tut_step < TUT_GUIDE.size():
		if _tut_step_done(tut_step):
			tut_step += 1
		elif _tut_step_skipped(tut_step):
			tut_skipped.append(TUT_GUIDE[tut_step])
			tut_step += 1
		else:
			break
		moved = true
	if moved:
		_tut_show([])

## Every step is decided from game state, never from a timer.
func _tut_step_done(i: int) -> bool:
	match i:
		0:
			return selected_planet >= 0 and _tut_g0_id() == ""  # T180: with discovery on, the flight steps come first
		1:
			return engine.local.values().any(func(o): return bool(o["buy"]))
		2:
			return not engine.routes.is_empty()
		3:  # the route was paid: a cycle ended with it open, or its destination already has a Sell order
			if engine.routes.is_empty():
				return false
			if cycle >= 2:
				return true
			var dsts: Array = engine.routes.map(func(r): return str(r["dst"]))
			return engine.local.keys().any(func(k): return dsts.has(str(k)) and bool(engine.local[k]["sell"]))
		4:  # the Expenses forecast (top bar cash) was opened
			return bool(tut_flags.get("expenses", false))
		5:
			return engine.local.values().any(func(o): return bool(o["sell"]))
		6:  # the resource button was right-clicked, or some planet's storage holds stock
			if bool(tut_flags.get("storage", false)):
				return true
			for k in storage.stock.keys():
				if not str(k).begins_with("system") and storage.stock[k].values().any(func(n): return int(n) > 0):
					return true
			return false
		7:
			return not learned_skills.is_empty()
		8:
			return has_skill("FND_PERMIT")
	return false

## A step whose state can never be reached from here is passed over, so the tutorial never blocks.
func _tut_step_skipped(i: int) -> bool:
	match i:
		7:  # no skill point held and nothing learned: nothing to teach yet
			return skill_points <= 0 and learned_skills.is_empty()
		8:  # the permit line needs a held point
			return skill_points <= 0 and not has_skill("FND_PERMIT")
	return false

## Game tips on the right board: one short tip per cycle, rotating. Never tutorial text.
const TIP_IDS := ["TIP_BOARD_1", "TIP_BOARD_2", "TIP_BOARD_3", "TIP_BOARD_4", "TIP_BOARD_5", "TIP_BOARD_6"]

func _tip_text() -> String:
	var i: int = (maxi(cycle, 1) - 1) % TIP_IDS.size()
	return StoryText.get_or(TIP_IDS[i], "", {})

## Called at the start of each cycle (and after a load): the tip for that cycle.
func _tut_cycle() -> void:
	if tip_label != null:
		tip_label.text = _tip_text()
		tip_label.visible = tip_label.text != "" and not game_over

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
	title.text = StoryText.get_or("LBL_TIPS", "Tips").to_upper()
	title.theme_type_variation = "LabelCaption"
	box.add_child(title)
	mission_label = Label.new()
	mission_label.text = StoryText.get_or("LBL_MISSION_FIRST", "Mission: Send stock to another planet")
	mission_label.theme_type_variation = "LabelAccent"
	mission_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(mission_label)
	tip_label = Label.new()
	tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip_label.theme_type_variation = "LabelMuted"
	box.add_child(tip_label)
	# The guided tutorial is its own floating card, placed beside the control the step is about (see _tut_place_card).
	tut_card = PanelContainer.new()
	tut_card.mouse_filter = Control.MOUSE_FILTER_IGNORE  # the buttons inside still take clicks
	tut_card.custom_minimum_size = Vector2(TUT_CARD_W, 0)
	tut_card.visible = false
	add_child(tut_card)
	var cbox := VBoxContainer.new()
	cbox.add_theme_constant_override("separation", 8)
	tut_card.add_child(cbox)
	var head := HBoxContainer.new()
	var cap := Label.new()
	cap.text = StoryText.get_or("TUT_HEADER", "Tutorial").to_upper()
	cap.theme_type_variation = "LabelCaption"
	cap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(cap)
	tut_count = Label.new()
	tut_count.theme_type_variation = "LabelNumberMuted"
	head.add_child(tut_count)
	cbox.add_child(head)
	tutorial_label = Label.new()
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_label.visible = false  # default Label, as the current step text in the galaxy view tutorial
	cbox.add_child(tutorial_label)
	tut_why = Label.new()
	tut_why.theme_type_variation = "LabelMuted"
	tut_why.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tut_why.visible = false
	cbox.add_child(tut_why)
	tut_actions = HBoxContainer.new()
	tut_actions.alignment = BoxContainer.ALIGNMENT_END
	tut_actions.add_theme_constant_override("separation", 8)
	tut_actions.visible = false
	var tut_skip := Button.new()
	tut_skip.theme_type_variation = "ButtonGhost"
	tut_skip.text = StoryText.get_or("BTN_SKIP_TUTORIAL", "Skip tutorial")
	tut_skip.pressed.connect(_tut_skip)
	tut_actions.add_child(tut_skip)
	cbox.add_child(tut_actions)
	# pulsing outline drawn over the control the step is about
	tut_hl = tut_make_hl()
	add_child(tut_hl)
	tut_arrow = tut_make_arrow()
	add_child(tut_arrow)
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
