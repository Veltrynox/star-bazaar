extends PanelContainer
const StoryText := preload("res://game/story_text.gd")
## T04 / T68: planet panel. Per commodity a row: name, prices, order status and Buy / Sell toggles
## (standing local orders, no ship needed). Company storage rows (once established) have a 5-line
## bar and "Send to..." (creates a one-way route to another planet's storage; it buys a ship first when none is
## free, so there is no separate Buy ship button). Then connections: a row per route, a row per ship.
## Content is rebuilt on demand (planet click, any route change, cycle end), never per frame.
## Reads everything from main (set via setup()). Unknown values are shown as text, never invented.

const RouteLineScript := preload("res://game/route_line.gd")
## Buy and Send share one size so they line up (Buy sits on the order row, Send on the storage row).
const ACTION_BTN_MIN := Vector2(104, 28)
const BUY_COLUMNS := 2  # resource buy buttons per grid row (panel is 320 wide)
const BUY_CELL_W := 144.0  # 2 cells + 4 px gap = 292 px in the 320 px panel
const BUY_CELL_H := 46.0  # row 1: icon, name, capacity; row 2: tiny prices
const PRICE_ROW_H := 14.0
const CAP_MARGIN := 46.0  # room kept at the right end of a resource button for its stored/capacity text
const MENU_SEND := 0
const MENU_SELL := 1
const MENU_SALVAGE := 2
signal salvage_requested(commodity: String)  # N5
signal tip_seen(key: String)  # T316: a one-time tip trigger was drawn (hungry chip)
signal order_requested(commodity: String, role: String)  # role: "buy" or "sell" (toggles the local order)
signal mine_requested(commodity: String)  # dead world: "Mine and send to..." (buy order plus a route to the clicked planet)
signal send_requested(commodity: String)  # "Send to..." on a storage row
signal buy_send_requested(commodity: String)  # Buy toggle on a resource row: standing buy order only
signal remove_requested(route_id: int)
signal found_bazaar_requested(planet: int)  # T262: confirmed in the dialog; main founds the Bazaar
signal make_hub_requested(planet: int)  # T291
signal hub_panel_requested(planet: int)  # T291

var COL_LIT: Color = Ui.col("star_warm")
var COL_DIM: Color = Ui.col("panel_300")
var COL_RED: Color = Ui.col("signal_bad")

var main: Control
var planet_index: int = -1
var split_open: String = ""  # commodity whose split bar is open ("" = none)
var _split_bar: Control = null
var _split_tags: Dictionary = {}  # lane destination -> its "Split 60%" tag label
var selected_route: int = -1  # T65: connection picked by clicking its line
var box: VBoxContainer  # body: everything under the banner
var outer: VBoxContainer  # banner (when the planet has one) + body margin
var body_margin: MarginContainer
var banner: Control = null
const Banners := preload("res://game/planet_banners.gd")
const PathfinderView := preload("res://game/pathfinder_view.gd")  # T180: flight accessor helpers; interface documented at its top
var _sig := ""  # T180: last flight signature of the shown planet; a change rebuilds the panel
var _prog_bar: ProgressBar = null
var _prog_label: Label = null
const GUTTER := 14.0  # Ui.scroll_wrap keeps this much clear for the scrollbar; the banner runs under it

func setup(m: Control) -> void:
	main = m

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	position = Vector2(76, 76)  # right of the icon rail, below the top bar
	custom_minimum_size = Vector2(320, 0)
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_margin = MarginContainer.new()
	body_margin.add_child(box)
	outer = VBoxContainer.new()
	outer.add_theme_constant_override("separation", 0)
	outer.add_child(body_margin)
	Ui.scroll_wrap(self, outer, 76.0 + 70.0)  # clear of the top bar and the key hints  # long panels scroll instead of leaving the window
	visible = false

## T180: flight accessor of the map, or null (discovery off: nothing in this file changes behaviour).
func _flight():
	return main.map.flight if main != null and main.map != null else null

func _pid() -> String:
	return str(main.map.planets[planet_index].get("id", ""))

func _process(_delta: float) -> void:
	if not visible or planet_index < 0 or main == null:
		return
	var f = _flight()
	if not PathfinderView.active(f):
		if _sig != "":
			_sig = ""
			rebuild()
		return
	var sg := PathfinderView.signature(f, _pid())
	if sg != _sig:
		rebuild()  # sets _sig
		return
	if _prog_bar != null and is_instance_valid(_prog_bar):  # build running here: keep the bar and the text current
		_prog_bar.value = PathfinderView.build_progress(f)
		_prog_label.text = _progress_text(f)

func show_planet(index: int, route_id: int = -1) -> void:
	if index != planet_index:
		split_open = ""
	var was_open := visible and index != planet_index  # another planet while open: a short settle
	planet_index = index
	selected_route = route_id
	visible = true
	if was_open:
		load("res://game/juice.gd").swap(self)
	rebuild()

func rebuild() -> void:
	if main == null or planet_index < 0 or box == null:
		return
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()
	var fl = _flight()
	_sig = PathfinderView.signature(fl, _pid())
	_prog_bar = null
	_prog_label = null
	var shown_known := PathfinderView.discovered(fl, _pid())
	_set_banner(_pid() if shown_known else "")  # an unknown world has no banner (it would show the planet)
	_split_bar = null
	_split_tags = {}
	var p: Dictionary = main.map.planets[planet_index]
	_header(p)
	if not PathfinderView.established(fl, _pid()):  # T180: closed or reached-but-not-built world: no goods, no routes, only Fly / Establish
		_closed_section(p, fl)
		_tut_mute()
		size = Vector2.ZERO
		return
	if main.second_lane_planet == planet_index:  # N11: the first sale in system 2 happened here
		var sl := _label("%s: %s" % [StoryText.get_or("TITLE_SECOND_LANE", "Cross-system trader"), StoryText.get_or("NOTE_SECOND_LANE", "Your first sale here crossed the system line.")])
		sl.name = "SecondLaneNote"
		sl.theme_type_variation = "LabelAccent"
		box.add_child(sl)
	var pend: Dictionary = main.pending
	if not pend.is_empty():
		var pl := _label(StoryText.get_or("LBL_PANEL_SENDING", "Sending {good} from {planet}. Click the destination planet.{hint}", {"good": Ui.good_name(str(pend["c"])).to_lower(), "planet": main.planet_name(int(pend["planet"])), "hint": main.pending_station_hint()}))
		pl.theme_type_variation = "LabelAccent"
		box.add_child(pl)
	var prices = p.get("base_prices")
	var mined: Array = []  # dead world: goods shown as rows, each gets a "Mine and send to..." button
	var grid := GridContainer.new()
	grid.name = "BuyGrid"
	grid.columns = BUY_COLUMNS
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 6)
	for c in main.commodities:
		var pd: Dictionary = prices if typeof(prices) == TYPE_DICTIONARY else {}
		if pd.get(str(c) + "_buy") == null and pd.get(str(c) + "_sell") == null:
			continue  # a good this planet does not trade has no row
		if not Availability.good(str(c)):
			continue  # data/availability.json: not visible yet means no row at all
		grid.add_child(_row(str(c), prices if typeof(prices) == TYPE_DICTIONARY else {}, pend))
		mined.append(str(c))
	if main.DeadWorlds.is_dead(p) and grid.get_child_count() > 0:  # dead world: the rows are mining rows, with a caption
		var mh := _label(StoryText.get_or("SCR_MINE_HEADER", "Mining"))
		mh.name = "MineHeader"
		mh.theme_type_variation = "LabelCaption"
		mh.text = mh.text.to_upper()
		box.add_child(mh)
	box.add_child(grid)
	if _dead_minable(p):
		for c in mined:
			box.add_child(_mine_button(str(c)))
	_growth_section()
	_lane_splits()
	_connections()
	_tut_mute()
	size = Vector2.ZERO

## T262: growth block under the goods grid: tier name and progress bar, need rows, Restless line, Found the Bazaar button.
## A locked need shows only '?' (never the good); goods named here follow Availability (Prosperity.needs already hides locked ones).
func _growth_section() -> void:
	var pr = main.prosperity
	var t: int = pr.tier(planet_index)
	if t == 0:
		return
	var sep := HSeparator.new()
	sep.name = "GrowthSeparator"
	box.add_child(sep)
	var wrap := VBoxContainer.new()
	wrap.name = "GrowthSection"
	wrap.add_theme_constant_override("separation", 4)
	var tier_id := "PROS_TIER_BARREN" if t < 0 else "PROS_TIER_%d" % t
	var tl := _label(StoryText.get_or(tier_id, "Barren" if t < 0 else "Tier %d" % t))
	tl.name = "TierLabel"
	tl.theme_type_variation = "LabelAccent"
	wrap.add_child(tl)
	if t < 0:
		box.add_child(wrap)
		return
	var bar := ProgressBar.new()
	bar.name = "GrowthBar"
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.value = pr.progress(planet_index)
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, float(main.balance.get("planet_growth_bar_px", 10)))
	bar.tooltip_text = "%s: %d / %d" % [StoryText.get_or("PROS_LBL_PROGRESS", "Growth progress"), pr.steps(planet_index), pr.steps_needed(planet_index)]
	bar.visible = pr.progress(planet_index) > 0.0  # no bar until the growth actually starts
	wrap.add_child(bar)
	var hdr := _label(StoryText.get_or("PROS_LBL_NEEDS", "Needs"))
	hdr.theme_type_variation = "LabelCaption"
	hdr.text = hdr.text.to_upper()
	wrap.add_child(hdr)
	for n in pr.needs(planet_index):
		wrap.add_child(_need_row(n))
	if pr.restless(planet_index):
		var rl := _label(StoryText.get_or("PROS_RESTLESS", "Restless. A short need is costing it progress. Meet every need to stop it."))
		rl.name = "RestlessLine"
		rl.theme_type_variation = "LabelAccent"
		wrap.add_child(rl)
	_hub_controls(wrap)
	if main.bazaar.can_found(planet_index):
		var fb := Button.new()
		fb.name = "FoundBazaarButton"
		fb.text = StoryText.get_or("BAZ_FOUND_BTN", "Found the Bazaar here")
		fb.pressed.connect(_ask_found_bazaar)
		wrap.add_child(fb)
	box.add_child(wrap)

## T291: 'Make hub' on an eligible world, 'Open hub panel' on a hub, the reason when the world cannot be one yet.
func _hub_controls(wrap: VBoxContainer) -> void:
	var hs = main.hubs
	if hs.is_hub(planet_index):
		var ob := Button.new()
		ob.name = "OpenHubButton"
		ob.text = StoryText.get_or("ST_HUB_OPEN", "Hub panel")
		ob.pressed.connect(func(): hub_panel_requested.emit(planet_index))
		wrap.add_child(ob)
		return
	if main.prosperity.tier(planet_index) < int(main.balance.get("hub_tier", 3)):
		return  # not a candidate yet: no clutter
	var can: Dictionary = hs.can_designate(planet_index)
	if bool(can["ok"]):
		var mb := Button.new()
		mb.name = "MakeHubButton"
		mb.text = StoryText.get_or("ST_HUB_MAKE", "Make hub")
		mb.tooltip_text = StoryText.get_or("ST_HUB_MAKE_TIP", "A hub keeps the needs of worlds in its reach fed, with ships from its own pool.")
		var idx := planet_index
		mb.pressed.connect(func(): make_hub_requested.emit(idx))
		wrap.add_child(mb)
	else:
		var rl := _label(str(can["reason"]))
		rl.name = "HubReason"
		rl.theme_type_variation = "LabelMuted"
		wrap.add_child(rl)

func _need_row(n: Dictionary) -> Control:
	var pr = main.prosperity
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var locked: bool = bool(n["locked"])
	var g := str(n["good"])
	row.name = "NeedRow_" + ("locked" if locked else g)
	var tip := PackedStringArray()
	var icon: Control
	if locked:
		icon = Label.new()
		(icon as Label).text = "?"  # never the good
		tip.append(StoryText.get_or("PROS_NEED_LOCKED", "? Not known yet"))
	else:
		icon = Ui.good_icon(g)
		tip.append(Ui.good_name(g))
		var reason: String = pr.price_reason(planet_index, g)
		if reason != "":
			if reason == "hungry":
				tip_seen.emit("hungry")
			tip.append(StoryText.get_or("PROS_CHIP_HUNGRY" if reason == "hungry" else "PROS_CHIP_SURPLUS", reason.capitalize()))
		var code: String = main.hubs.status_of(planet_index, g)
		if code != "" and code != Hubs.STATUS_MET:
			tip.append(main.hubs.status_text(code))
	var num := Label.new()
	num.name = "NeedCount"
	if not locked:
		num.text = "%d / %d" % [int(n["sold"]), int(n["demand"])]
		tip.append("%s: %d  |  %s: %d" % [StoryText.get_or("PROS_LBL_SOLD", "Sold this cycle"), int(n["sold"]), StoryText.get_or("PROS_LBL_DEMAND", "Demand per cycle"), int(n["demand"])])
	tip.append(StoryText.get_or("PROS_NEED_MET", "Met") if (bool(n["met"]) and not locked) else StoryText.get_or("PROS_NEED_SHORT", "Short"))
	var full := "\n".join(tip)
	icon.tooltip_text = full
	icon.mouse_filter = Control.MOUSE_FILTER_PASS
	num.tooltip_text = full
	num.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_child(icon)
	row.add_child(num)
	return row

func _ask_found_bazaar() -> void:
	var dlg := ConfirmationDialog.new()
	dlg.name = "FoundBazaarDialog"
	dlg.dialog_text = StoryText.get_or("BAZ_FOUND_PROMPT", "Found the Star Bazaar at {planet}? This is final. A run has one capital.", {"planet": main.planet_name(planet_index)})
	dlg.ok_button_text = StoryText.get_or("BAZ_FOUND_CONFIRM", "Found it")
	dlg.cancel_button_text = StoryText.get_or("BAZ_FOUND_CANCEL", "Not yet")
	var idx := planet_index
	dlg.confirmed.connect(func(): found_bazaar_requested.emit(idx))
	dlg.canceled.connect(dlg.queue_free)
	dlg.confirmed.connect(dlg.queue_free)
	add_child(dlg)
	dlg.popup_centered()

## Guided tutorial lock: every button but the resource rows, the pending Cancel and the Sell-here button shows disabled.
## The rows and the Sell-here button decide for themselves (see _row and _pays_line); main.tut_allows is what refuses a click.
func _tut_mute() -> void:
	if not main.tut_lock_active():
		return
	for b in _buttons_in(box, []):
		var n := str(b.name)
		if n.begins_with("BuyButton_") or n == "CancelPending" or n == "PaysSellButton":
			continue
		(b as Button).disabled = true

func _buttons_in(n: Node, out: Array) -> Array:
	if n is Button:
		out.append(n)
	for c in n.get_children():
		_buttons_in(c, out)
	return out

## Surface banner at the top, edge to edge: the panel's side and top margins drop to the 1 px border, the body keeps
## the old margins on its own. A planet without a banner keeps the plain panel.
func _set_banner(planet_id: String) -> void:
	if banner != null:
		outer.remove_child(banner)
		banner.queue_free()
		banner = null
	remove_theme_stylebox_override("panel")  # read the theme style, not our own earlier copy (a rebuild lost the side margins)
	var base := get_theme_stylebox("panel", "PanelContainer")
	banner = Banners.make(planet_id, custom_minimum_size.x)
	if banner == null or not (base is StyleBoxFlat):
		banner = null
		remove_theme_stylebox_override("panel")
		body_margin.add_theme_constant_override("margin_left", 0)
		body_margin.add_theme_constant_override("margin_right", 0)
		body_margin.add_theme_constant_override("margin_top", 0)
		return
	var sb := (base as StyleBoxFlat).duplicate() as StyleBoxFlat
	var m := float(sb.border_width_left)
	var side := sb.content_margin_left - m
	sb.content_margin_left = m
	sb.content_margin_right = m
	sb.content_margin_top = m
	add_theme_stylebox_override("panel", sb)
	body_margin.add_theme_constant_override("margin_left", int(side))
	body_margin.add_theme_constant_override("margin_right", int(side))
	body_margin.add_theme_constant_override("margin_top", 4)
	(banner.get_node("BannerImage") as Control).offset_right = GUTTER  # runs under the scrollbar gutter to the panel edge
	outer.add_child(banner)
	outer.move_child(banner, 0)

## Title, subtitle, description, planet thumbnails.
func _header(p: Dictionary) -> void:
	var fl = _flight()
	var known := PathfinderView.discovered(fl, str(p.get("id", "")))
	var estab := PathfinderView.established(fl, str(p.get("id", "")))
	var title := Label.new()
	title.text = str(p.get("name", p.get("id", "?"))) if known else StoryText.get_or("LBL_UNKNOWN_DARK_WORLD" if main.DeadWorlds.is_dead(p) else "LBL_UNKNOWN_WORLD", "Unknown world")
	title.theme_type_variation = "LabelTitle"
	var face: Control = null  # T285: mood face, established worlds only (a face, never a number)
	if known and estab and main.prosperity != null:
		face = MoodFace.new()
		face.mood = main.prosperity.mood(planet_index)
		face.px = float(main.balance.get("face_px", 16))
		face.tooltip_text = "%s. %s" % [Ui.mood_name(face.mood), Ui.mood_tip(face.mood)]
	if banner != null:  # the name sits on the lower, faded part of the banner
		title.name = "BannerTitle"
		title.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		title.offset_left = 16
		title.offset_right = -16
		title.offset_bottom = -2
		title.offset_top = -34
		title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		title.add_theme_constant_override("shadow_offset_x", 1)
		title.add_theme_constant_override("shadow_offset_y", 1)
		banner.add_child(title)
		if face != null:
			face.name = "MoodFace"
			banner.add_child(face)
			face.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
			face.offset_left = -16.0 - face.px
			face.offset_right = -16.0
			face.offset_top = -10.0 - face.px
			face.offset_bottom = -10.0
			title.offset_right = -16.0 - face.px - 8.0
	elif face != null:
		var trow := HBoxContainer.new()
		trow.add_theme_constant_override("separation", 8)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		face.name = "MoodFace"
		face.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		trow.add_child(title)
		trow.add_child(face)
		box.add_child(trow)
	else:
		box.add_child(title)
	_weather_row()
	if main.systems_in_game() > 1:  # T85: system name once more than one system exists
		var sys_l := _label(main.Systems.name_of(int(p.get("system", 1))))
		sys_l.theme_type_variation = "LabelCaption"
		sys_l.text = sys_l.text.to_upper()
		box.add_child(sys_l)
	if known and str(p.get("desc", "")) != "":
		var d := _label(str(p["desc"]))
		d.theme_type_variation = "LabelSmall"
		box.add_child(d)
	if not estab:
		pass  # T180: no mining or lock lines before the post or platform exists
	elif main.DeadWorlds.is_dead(p) and main.engine.dead_locked.has(planet_index):  # not open before dead_unlock_cycle
		var ll := _label(StoryText.get_or("PLANET_DEAD_LOCKED", "Opens at cycle {n}.", {"n": main.dead_unlock_cycle()}))
		ll.name = "DeadLockedLine"
		ll.theme_type_variation = "LabelAccent"
		box.add_child(ll)
	elif main.DeadWorlds.is_dead(p):  # dead world: what is missing for mining (if anything)
		var need_s: String = main.engine.dead_skill_reason(planet_index)
		if need_s != "":
			var nl := _label(need_s)
			nl.name = "DeadNeedsSkillLine"
			nl.theme_type_variation = "LabelAccent"
			box.add_child(nl)
	var thumbs := HBoxContainer.new()
	thumbs.add_theme_constant_override("separation", 8)
	var sid: int = int(p.get("system", 1))
	for i in main.map.planets.size():
		var q: Dictionary = main.map.planets[i]
		if int(q.get("system", 1)) != sid:
			continue
		if not PathfinderView.discovered(fl, str(q.get("id", ""))):
			continue  # T180: an unknown world has no thumbnail (its type and name stay hidden)
		var t := Thumb.new()
		t.planet = q
		t.selected = i == planet_index
		t.tooltip_text = str(q.get("name", q.get("id", "?")))
		var idx: int = i
		t.pressed.connect(func(): main._on_planet_clicked(idx))
		if main.tut_lock_active() and not main.tut_allows("select", idx):
			t.modulate.a = 0.4  # guided tutorial: only the named planet can be picked
		thumbs.add_child(t)
	box.add_child(thumbs)

## T285: one chip per live weather row at this world (house tint, kind, good if visible, cycles left); nothing when calm or not established.
func _weather_row() -> void:
	var fl = _flight()
	if main.events == null or not PathfinderView.established(fl, _pid()):
		return
	var wrap := VBoxContainer.new()
	wrap.name = "WeatherRow"
	wrap.add_theme_constant_override("separation", 3)
	for a in main.events.active:
		if int(a["planet"]) != planet_index:
			continue
		var chip := WeatherChip.new()
		chip.setup(a, float(main.balance.get("weather_chip_px", 15)), int(main.balance.get("weather_chip_font_px", 11)), float(main.balance.get("weather_chip_alpha", 0.88)))
		var hn := Ui.house_name(int(a.get("house", 0))) if int(a.get("house", 0)) > 0 else ""
		var pl := str(main.map.planets[planet_index].get("name", ""))
		chip.tooltip_text = (hn + ". " if hn != "" else "") + StoryText.get_or("HINT_HOUSE_ACTIVE", "Weather at {planet} for {n} more cycles", {"planet": pl, "n": int(a["left"])})
		wrap.add_child(chip)
	if wrap.get_child_count() == 0:
		wrap.queue_free()
	else:
		box.add_child(wrap)

## T180: panel body of a world without a post or platform. Unknown: one flavour line, flight time, Fly here.
## Reached (discovered): the Establish button with cost and what it unlocks, or the build progress. Texts are story ids.
func _closed_section(p: Dictionary, f) -> void:
	var pid := str(p.get("id", ""))
	var dead: bool = main.DeadWorlds.is_dead(p)
	var known := PathfinderView.discovered(f, pid)
	if not known:
		var fl := _label(StoryText.get_or("LBL_UNKNOWN_DARK_LINE" if dead else "LBL_UNKNOWN_WORLD_LINE", "Fly closer to learn more."))
		fl.name = "UnknownLine"
		fl.theme_type_variation = "LabelSmall"
		box.add_child(fl)
	var eta := PathfinderView.eta_cycles(f, pid)
	if eta >= 0.0 and PathfinderView.docked_at(f) != pid:
		var el := _label(StoryText.get_or("LBL_FLIGHT_TIME", "Flight time: {cycles} cycles", {"cycles": "%.1f" % eta}))
		el.name = "FlightTime"
		el.theme_type_variation = "LabelAccent"
		box.add_child(el)
	var here: bool = PathfinderView.docked_at(f) == pid
	if not here:
		var fb := Button.new()
		fb.name = "FlyHereButton"
		fb.text = StoryText.get_or("BTN_FLY_HERE", "Fly here")
		fb.custom_minimum_size = ACTION_BTN_MIN
		var tgt := {"kind": "planet", "pos": main.map.positions[planet_index], "index": planet_index}
		fb.pressed.connect(func(): main.map.fly_requested.emit(tgt))
		box.add_child(fb)
	if not known:
		return
	var building: bool = PathfinderView.build_target(f) == pid
	if dead and not PathfinderView.can_platform(f, pid):
		return  # availability: no platform button before the mining skill is learned
	if building:
		_prog_label = _label(_progress_text(f))
		_prog_label.name = "BuildProgressLabel"
		_prog_label.theme_type_variation = "LabelAccent"
		box.add_child(_prog_label)
		_prog_bar = ProgressBar.new()
		_prog_bar.name = "BuildProgress"
		_prog_bar.min_value = 0.0
		_prog_bar.max_value = 1.0
		_prog_bar.show_percentage = false
		_prog_bar.custom_minimum_size = Vector2(0, 12)
		_prog_bar.value = PathfinderView.build_progress(f)
		box.add_child(_prog_bar)
		return
	var eb := Button.new()
	eb.name = "EstablishButton"
	eb.text = StoryText.get_or("BTN_ESTABLISH_PLATFORM" if dead else "BTN_ESTABLISH_POST", "Establish mining platform" if dead else "Establish trading post")
	eb.custom_minimum_size = ACTION_BTN_MIN
	var busy: bool = PathfinderView.state(f) == "building"
	if not here:
		eb.disabled = true  # why: the ship is elsewhere
		eb.tooltip_text = StoryText.get_or("NOT_FLY_FIRST", "Fly the Pathfinder here first.")
	elif busy:
		eb.disabled = true
		eb.tooltip_text = StoryText.get_or("NOT_POST_BUSY", "The Pathfinder is already building. One build at a time.")
	eb.pressed.connect(func(): main.map.establish_requested.emit(pid))
	box.add_child(eb)
	var c := PathfinderView.cost(f, pid)
	if not c.is_empty():
		var cl: Label
		if bool(c.get("free", false)):
			cl = _label(StoryText.get_or("LBL_POST_COST_FREE", "First post is free. Build time: {cycles} cycles.", {"cycles": "%.1f" % float(c.get("cycles", 0.0))}))
		else:
			cl = _label(StoryText.get_or("LBL_POST_COST", "Cost: {cash} cr. Build time: {cycles} cycles.", {"cash": int(c.get("cash", 0)), "cycles": "%.1f" % float(c.get("cycles", 0.0))}))
		cl.name = "EstablishCost"
		cl.theme_type_variation = "LabelSmall"
		box.add_child(cl)
	var ul := _label(StoryText.get_or("LBL_PLATFORM_UNLOCKS" if dead else "LBL_POST_UNLOCKS", ""))
	ul.name = "EstablishUnlocks"
	ul.theme_type_variation = "LabelSmall"
	box.add_child(ul)

func _progress_text(f) -> String:
	var dead: bool = main.DeadWorlds.is_dead(main.map.planets[planet_index])
	return StoryText.get_or("LBL_PLATFORM_PROGRESS" if dead else "LBL_POST_PROGRESS", "{cycles} cycles left", {"cycles": "%.1f" % PathfinderView.build_cycles_left(f)})

## Dead world that can be mined now: open (cycle) and its skill learned.
func _dead_minable(p: Dictionary) -> bool:
	return main.DeadWorlds.is_dead(p) and not main.engine.dead_locked.has(planet_index) and main.engine.dead_skill_reason(planet_index) == ""

## The primary action of a dead world: like Send to..., but the ship mines the good first.
func _mine_button(c: String) -> Button:
	var b := Button.new()
	b.name = "MineSendButton_" + c
	b.text = StoryText.get_or("BTN_MINE_SEND", "Mine {good} and send to...", {"good": Ui.good_name(c)})
	b.theme_type_variation = "ButtonSmall"
	b.custom_minimum_size = Vector2(ACTION_BTN_MIN.x, ACTION_BTN_MIN.y)
	b.icon = Ui.icon(c)
	b.expand_icon = true
	b.add_theme_constant_override("icon_max_width", 18)
	b.clip_text = true
	if not main.system_trade_open(planet_index):
		b.disabled = true
		b.tooltip_text = main.trade_locked_reason()
	elif main.tut_lock_active() and not main.tut_allows("send_start", planet_index, c):
		b.disabled = true
	b.pressed.connect(func(): mine_requested.emit(c))
	return b

func _row(c: String, prices: Dictionary, pend: Dictionary) -> Control:
	# One grid cell per resource: the resource itself (icon, name, buy price) is the Buy toggle; small status lines sit under it.
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 2)
	wrap.custom_minimum_size = Vector2(BUY_CELL_W, 0)
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 0)
	var buy = prices.get(c + "_buy")
	for a in main.events.active:  # P1: a price event on this row shows its direction and the cycles it has left
		if str(a["kind"]) in ["up", "down"] and int(a["planet"]) == planet_index and str(a["c"]) == str(c):
			var ev := Label.new()
			ev.name = "PriceEvent_" + str(c)
			var arrow := "↑" if str(a["kind"]) == "up" else "↓"
			ev.text = StoryText.get_or("LBL_PRICE_EVENT", "{arrow} Event, {cycles} cycles left", {"arrow": arrow, "cycles": int(a["left"])})
			ev.theme_type_variation = "LabelAccent"
			info.add_child(ev)
	if Skills.reveal_cycles(main.system_of(planet_index) == 1) > 0:  # LUX_1 Price Whisper: best partner and the prices the next cycle starts with
		var bpl: String = main.best_partner_line(planet_index, c)
		if bpl != "":
			var bl := Label.new()
			bl.text = bpl
			bl.theme_type_variation = "LabelSmall"
			info.add_child(bl)
		var nb: int = main.trade.price(planet_index, c + "_buy", true)
		var ns: int = main.trade.price(planet_index, c + "_sell", true)
		if nb >= 0 and ns >= 0:
			var nx := Label.new()
			nx.text = StoryText.get_text("LBL_NEXT_PRICE", {"buy": nb, "sell": ns})
			nx.theme_type_variation = "LabelSmall"
			info.add_child(nx)
		if Skills.reveal_cycles(main.system_of(planet_index) == 1) >= 2:  # LUX_5B Deep Read: two cycles ahead
			var nb2: int = main.trade.price(planet_index, c + "_buy", true, false, 2)
			var ns2: int = main.trade.price(planet_index, c + "_sell", true, false, 2)
			if nb2 >= 0 and ns2 >= 0:
				var nx2 := Label.new()
				nx2.name = "NextPrice2_" + str(c)
				nx2.text = StoryText.get_or("LBL_NEXT_PRICE_2", "In 2 cycles: {buy} cr to buy, {sell} cr to sell.", {"buy": nb2, "sell": ns2})
				nx2.theme_type_variation = "LabelSmall"
				info.add_child(nx2)
	for role in ["sell"]:  # the buy order state is in the resource button tooltip and its pressed toggle
		if main.engine.local_on(planet_index, c, role):
			var st := Label.new()
			st.text = StoryText.get_or("LBL_SELL_ORDER_STATE", "Sell order: {state}", {"state": main.engine.local_state(planet_index, c, role)})
			st.theme_type_variation = "LabelAccent"
			info.add_child(st)
	var nc_line: String = _buy_no_cash_line(planet_index, c)
	if nc_line != "":  # a Buy order that cannot afford one unit: say so on the card, not only in the tooltip
		var nl := Label.new()
		nl.name = "BuyNoCash_" + str(c)
		nl.text = nc_line
		nl.theme_type_variation = "LabelSmall"
		nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.add_child(nl)
	var mp: Dictionary = main.engine.mixed_preview(planet_index)
	if mp.has(c):
		var ml := Label.new()
		var pct: float = float(mp[c]["pct"])
		ml.text = StoryText.get_or("LBL_MIXED_LOAD", "Mixed load +{n}% (max {cap} credits)", {"n": str(int(pct)) if is_equal_approx(pct, floorf(pct)) else str(pct), "cap": int(main.balance.get("bundle_bonus_cap", 0))})
		ml.name = "MixedLoadLabel"
		ml.theme_type_variation = "LabelAccent"
		info.add_child(ml)
	# The resource is the Buy button: it buys here every cycle and sends the goods on a route.
	var sell_p = prices.get(c + "_sell")
	var buy_on: bool = main.engine.local_on(planet_index, c, "buy")
	var locked: bool = not main.system_trade_open(planet_index)
	var bs := Button.new()
	bs.set_script(load("res://game/head_tip_button.gd"))  # tooltip: resource name in bold on the first line
	bs.theme_type_variation = "ButtonSmall"
	bs.custom_minimum_size = Vector2(BUY_CELL_W, BUY_CELL_H)
	bs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bs.toggle_mode = true
	bs.button_pressed = buy_on
	bs.alignment = HORIZONTAL_ALIGNMENT_LEFT  # no name on the button (it did not fit): the name is the bold head of the tooltip
	bs.clip_text = true
	bs.icon = Ui.icon(c)
	bs.expand_icon = true
	bs.add_theme_constant_override("icon_max_width", 22)
	if Ui.commodity_col(str(c)) != Color.WHITE:
		bs.add_theme_color_override("font_color", Ui.commodity_col(str(c)))  # Energy amber, Food green
	bs.disabled = buy == null
	var buy_tip: String = StoryText.get_or("LBL_BUY_PRICE", "Buy price") + ": " + _price(buy)
	bs.tooltip_text = StoryText.get_or("RT_STATE_NOT_TRADED", "Not traded here.") if buy == null else (StoryText.get_or("LBL_BUY_TIP_ON", "{tip}. Standing buy order. Press to stop.", {"tip": buy_tip}) if buy_on else StoryText.get_or("LBL_PRICE_TIP", "{tip}.", {"tip": buy_tip}))
	if locked:
		bs.disabled = true
		bs.tooltip_text = main.trade_locked_reason()
	if buy != null and not locked and _dead_minable(main.map.planets[planet_index]):
		buy_tip = StoryText.get_or("LBL_MINE_ROW_TIP", "Mine here every cycle. Press to stop.")
		bs.tooltip_text = buy_tip
	bs.name = "BuyButton_" + str(c)
	if main.tut_lock_active() and not (main.tut_allows("buy", planet_index, str(c)) or main.tut_allows("send_start", planet_index, str(c)) or main.tut_allows("sell", planet_index, str(c))):
		bs.disabled = true  # guided tutorial: this resource is not part of the step
	bs.pressed.connect(func(): buy_send_requested.emit(c))
	if sell_p != null and buy != null and not main.DeadWorlds.is_dead(main.map.planets[planet_index]):
		bs.tooltip_text += "\n" + StoryText.get_or("LBL_SELL_PRICE", "Sell price") + ": " + _price(sell_p)
	if buy_on:
		bs.tooltip_text += "\n" + StoryText.get_or("LBL_BUY_ORDER_STATE", "Buy order: {state}", {"state": str(main.engine.local_state(planet_index, c, "buy"))})
	var nc_tip := next_cycle_text(main, main.storage.planet_key(planet_index), str(c))
	if nc_tip != "":
		bs.tooltip_text += "\n" + nc_tip
	var salv_t: String = _salvage_text(c)  # the Salvage offer shows on hover; the action is in the right-click menu
	if salv_t != "":
		bs.tooltip_text += "\n" + salv_t
	bs.tooltip_text += "\n" + StoryText.get_or("LBL_RMB_MORE", "Right-click for Send to, Sell and more.")
	var gl := GoodInfo.lines(str(c))  # what the good is and how it is used, above the existing lines (below the lock reason)
	var gi := "\n".join(PackedStringArray(gl))
	if gi != "":
		bs.tooltip_text = (bs.tooltip_text + "\n\n" + gi) if locked else (gi + "\n\n" + bs.tooltip_text)
	bs.tooltip_text = Ui.good_name(c) + "\n" + bs.tooltip_text  # first line = the resource name, drawn bold
	_reserve_right(bs, CAP_MARGIN, PRICE_ROW_H)
	var key: String = main.storage.planet_key(planet_index)
	var cap_l := Label.new()  # stored/capacity of this good in the company storage here, at the right end of the button
	cap_l.name = "Capacity_" + str(c)
	cap_l.text = "%d/%d" % [main.storage.amount(key, str(c)), main.storage.capacity_of(key)]
	cap_l.theme_type_variation = "LabelSmall"
	cap_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap_l.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	cap_l.offset_left = -CAP_MARGIN
	cap_l.offset_right = -4
	cap_l.offset_bottom = -PRICE_ROW_H
	cap_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cap_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bs.add_child(cap_l)
	var pr_l := Label.new()  # row 2: tiny buy and sell prices (what the player pays and receives)
	pr_l.name = "Prices_" + str(c)
	var mining: bool = main.DeadWorlds.is_dead(main.map.planets[planet_index])
	pr_l.text = "%s / %s" % [_price(buy), _price(sell_p)]
	if mining:  # dead world: row 2 shows the yield per trip (what one ship hauls), not buy and sell prices
		pr_l.text = StoryText.get_or("SCR_MINE_YIELD", "{n} per trip", {"n": main.engine.units_per_cycle(null, str(c))})
		pr_l.name = "Yield_" + str(c)
	pr_l.theme_type_variation = "LabelSmall"
	pr_l.add_theme_font_size_override("font_size", 10)
	pr_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pr_l.clip_text = true
	pr_l.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	pr_l.offset_top = -PRICE_ROW_H - 3
	pr_l.offset_bottom = -3
	pr_l.offset_left = 8
	pr_l.offset_right = -4
	pr_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT  # under the stored/capacity number
	pr_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bs.add_child(pr_l)
	var menu := _context_menu(str(c), prices)
	bs.add_child(menu)
	bs.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_RIGHT:
			menu.popup_on_parent(Rect2i(Vector2i(bs.get_global_mouse_position()), Vector2i.ZERO))
			bs.accept_event())
	wrap.add_child(bs)
	if mining and buy != null:  # what mining costs per unit, under the row
		var mc := Label.new()
		mc.name = "MineCost_" + str(c)
		mc.text = StoryText.get_or("SCR_MINE_COST", "Mining cost: {price} per unit", {"price": str(int(buy)) if is_equal_approx(float(buy), floorf(float(buy))) else _price(buy)})
		mc.theme_type_variation = "LabelSmall"
		mc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.add_child(mc)
	if info.get_child_count() > 0:
		wrap.add_child(info)
	return wrap

## Extra right padding inside a button's styleboxes so its text stops before the capacity label.
func _reserve_right(b: Button, px: float, bottom_px: float = 0.0) -> void:
	for sn in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		var sb: StyleBox = b.get_theme_stylebox(sn)
		if sb == null:
			continue
		var d: StyleBox = sb.duplicate()
		d.content_margin_right = maxf(sb.get_margin(SIDE_RIGHT), 0.0) + px
		b.add_theme_stylebox_override(sn, d)

## Right-click menu of a resource: Send to, Sell (a toggle) and Salvage when it applies. Item ids are MENU_*.
func _context_menu(c: String, prices: Dictionary) -> PopupMenu:
	var m := PopupMenu.new()
	m.name = "ContextMenu_" + c
	var open: bool = main.system_trade_open(planet_index)
	var pend: Dictionary = main.pending
	var sending: bool = not pend.is_empty() and int(pend["planet"]) == planet_index and str(pend["c"]) == c
	m.add_item(StoryText.get_text("BTN_SEND") + ("*" if sending else ""), MENU_SEND)
	var i_send := m.get_item_index(MENU_SEND)
	m.set_item_tooltip(i_send, StoryText.get_or("LBL_SEND_TIP", "Move this stock to another planet's storage with a ship.") if open else main.trade_locked_reason())
	m.set_item_disabled(i_send, not open or not main.tut_allows("send_start", planet_index, c))
	var sell = prices.get(c + "_sell")
	var sell_on: bool = main.engine.local_on(planet_index, c, "sell")
	m.add_check_item(StoryText.get_text("BTN_SELL") + (" " + _price(sell) if sell != null else "") + (": " + StoryText.get_or("LBL_ORDER_ON", "on") if sell_on else ""), MENU_SELL)
	var i_sell := m.get_item_index(MENU_SELL)
	m.set_item_checked(i_sell, sell_on)
	var sell_tip: String = StoryText.get_or("LBL_SELL_PRICE", "Sell price") + ": " + _price(sell)
	m.set_item_tooltip(i_sell, StoryText.get_or("RT_STATE_NOT_TRADED", "Not traded here.") if sell == null else (StoryText.get_or("LBL_SELL_TIP_ON", "{tip}. Standing sell order. Press to stop.", {"tip": sell_tip}) if sell_on else StoryText.get_or("LBL_SELL_TIP_OFF", "{tip}. Standing sell order each cycle.", {"tip": sell_tip})))
	m.set_item_disabled(i_sell, sell == null or not open or not main.tut_allows("sell", planet_index, c))
	if not open:
		m.set_item_tooltip(i_sell, main.trade_locked_reason())
	if main.engine.salvage_reason(planet_index, c) != "":  # N5: stuck stock can be sold off for a share of the Sell price
		m.add_item(StoryText.get_or("BTN_SALVAGE", "Salvage"), MENU_SALVAGE)
		m.set_item_disabled(m.get_item_index(MENU_SALVAGE), main.tut_lock_active())
	m.id_pressed.connect(func(id: int):
		if id == MENU_SEND:
			send_requested.emit(c)
		elif id == MENU_SELL:
			order_requested.emit(c, "sell")
		elif id == MENU_SALVAGE:
			salvage_requested.emit(c))
	return m

## N5: the Salvage offer text of a resource ("" when it does not apply). Shown in the resource tooltip; the action is in the right-click menu.
func _salvage_text(c: String) -> String:
	var salv: String = main.engine.salvage_reason(planet_index, c)
	if salv == "":
		return ""
	var so: Dictionary = main.engine.salvage_offer(planet_index, c)
	if salv == "full":
		return StoryText.get_or("LBL_SALVAGE_STORAGE_FULL", "Salvage: {n} now (storage full). Sell order pays {m}.", {"n": so["n"], "m": so["m"]})
	return StoryText.get_or("LBL_SALVAGE_NO_BUYER", "Salvage: {n} now (no buyer on your lanes). Sell order pays {m}.", {"n": so["n"], "m": so["m"]})

## A missing price is a data gap (planets.json), shown as text, never invented.
## The engine's not-enough-cash state text for a running Buy order, else "". Recognised by the text's fixed start.
func _buy_no_cash_line(planet_index: int, c) -> String:
	if not main.engine.local_on(planet_index, c, "buy"):
		return ""
	var st: String = main.engine.local_state(planet_index, c, "buy")
	var tpl: String = StoryText.get_or("ST_NO_CASH_BUY", "Not enough cash: one unit costs {price} cr, {free} cr free after trips.", {"price": "\u0001", "free": "\u0001"})
	var head: String = tpl.split("\u0001")[0]
	return st if head != "" and st.begins_with(head) else ""

func _price(v) -> String:
	return str(v) if v != null else "\u2013"  # compact: no unit, no data shown as a dash

## Split rows (N2) for goods with two lanes with ships. The per-planet storage rows are gone: stock shows on each resource button.
func _lane_splits() -> void:
	for c in main.commodities:
		if not Availability.good(str(c)):
			continue
		if main.split_targets(planet_index, str(c)).size() >= 2:
			box.add_child(_split_row(str(c)))
			if split_open == str(c):
				box.add_child(_split_bar_for(str(c)))
		elif split_open == str(c):
			split_open = ""

## Owner 2026-11-03: small label "Next cycle: +12 -5 = 47" (in green, out red). Used by the storage view.
## Null when nothing moves. Read-only: uses RouteEngine.project_storage.
static func next_cycle_label(main_node: Control, key: String, c: String) -> Control:
	var pr: Dictionary = main_node.engine.project_storage(key, c, int(main_node.cash))
	var n_in := int(pr["in"])
	var n_out := int(pr["out"])
	if n_in <= 0 and n_out <= 0:
		return null
	var rt := RichTextLabel.new()
	rt.name = "NextCycle_" + c
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.scroll_active = false
	rt.autowrap_mode = TextServer.AUTOWRAP_OFF
	rt.size_flags_horizontal = Control.SIZE_SHRINK_END
	rt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rt.add_theme_font_size_override("normal_font_size", 12)
	rt.add_theme_color_override("default_color", Ui.col("ink_muted"))
	var good := "[color=#%s]%d[/color]" % [Ui.col("signal_good").to_html(false), n_in]
	var bad := "[color=#%s]%d[/color]" % [Ui.col("signal_bad").to_html(false), n_out]
	var t: String = StoryText.get_or("LBL_NEXT_CYCLE", "Next cycle: +{in} -{out} = {after}")
	rt.text = t.replace("{in}", good).replace("{out}", bad).replace("{after}", str(int(pr["after"])))
	rt.mouse_filter = Control.MOUSE_FILTER_STOP
	rt.tooltip_text = next_cycle_breakdown(main_node, pr)
	return rt

## Hover text of the Next cycle line: every source (In) and use (Out) of the stock with its amount, one line each.
## `pr` is RouteEngine.project_storage; the listed amounts add up to its in and out.
static func next_cycle_breakdown(main_node: Control, pr: Dictionary) -> String:
	var lines: Array = []
	for dir in ["in", "out"]:
		var items: Array = []
		for p in pr.get("parts", []):
			if str(p["dir"]) != dir:
				continue
			var planet: String = main_node.planet_name(int(p["planet"]))
			var vars := {"n": str(int(p["n"])), "planet": planet}
			var key := ""
			match str(p["kind"]):
				"buy":
					key = "TIP_NC_BUY"
				"sell":
					key = "TIP_NC_SELL_BACKUP" if bool(p["backup"]) else "TIP_NC_SELL"
				"upkeep":
					key = "TIP_NC_UPKEEP"
				_:
					var rec: Dictionary = {}
					for r in main_node.engine.routes:
						if int(r["id"]) == int(p["route"]):
							rec = r
					vars["route"] = "%s > %s (%s)" % [planet, main_node.planet_name(int(rec.get("b", -1))), Ui.good_name(str(rec.get("c", "")))]
					key = "TIP_NC_ROUTE_BACKUP" if bool(p["backup"]) else ("TIP_NC_ROUTE_IN" if dir == "in" else "TIP_NC_ROUTE_OUT")
			items.append(StoryText.get_text(key, vars))
		if not items.is_empty():
			lines.append(StoryText.get_text("TIP_NC_IN" if dir == "in" else "TIP_NC_OUT", {"list": ", ".join(items)}))
	return "\n".join(lines)

## Owner 2026-11-03: next-cycle line for the resource button tooltip, "Next cycle: +12 -5 = 47".
## Empty when nothing moves. Read-only: uses RouteEngine.project_storage.
static func next_cycle_text(main_node: Control, key: String, c: String) -> String:
	var pr: Dictionary = main_node.engine.project_storage(key, c, int(main_node.cash))
	var n_in := int(pr["in"])
	var n_out := int(pr["out"])
	if n_in <= 0 and n_out <= 0:
		return ""
	var t: String = StoryText.get_or("LBL_NEXT_CYCLE", "Next cycle: +{in} -{out} = {after}")
	return t.replace("{in}", str(n_in)).replace("{out}", str(n_out)).replace("{after}", str(int(pr["after"])))

## Split bar: the colour of the first (0) or second (1) lane of a split.
func _lane_colour(i: int) -> Color:
	return Ui.col("commodity_energy" if i == 0 else "commodity_food")

## Split bar: the "Split" toggle on a storage row with two lanes with ships.
func _split_row(c: String) -> Control:
	var row := HBoxContainer.new()
	row.name = "SplitRow"
	var b := Button.new()
	b.name = "SplitButton"
	b.theme_type_variation = "ButtonSmall"
	b.text = StoryText.get_or("BTN_SPLIT_BAR", "Split")
	b.toggle_mode = true
	b.button_pressed = split_open == c
	b.pressed.connect(func():
		split_open = "" if split_open == c else c
		if split_open == c and main.engine.lane_split(planet_index, int(main.split_pair(planet_index, c)[0]), c).is_empty():
			main.set_split_percent(planet_index, c, 50)  # the bar starts at 50/50
		rebuild())
	row.add_child(b)
	return row

## Split bar: "Ore 12/40", the two lane names with their shares, a slider with [-] and [+], Done and Stop split.
func _split_bar_for(c: String) -> Control:
	var pair: Array = main.split_pair(planet_index, c)
	var vb := VBoxContainer.new()
	vb.name = "SplitBar"
	vb.add_theme_constant_override("separation", 4)
	_split_bar = vb
	var key: String = main.storage.planet_key(planet_index)
	var head := _label("%s  %d/%d" % [Ui.good_name(c), main.storage.amount(key, c), main.storage.capacity_of(key)])
	head.theme_type_variation = "LabelSmall"
	vb.add_child(head)
	var names := HBoxContainer.new()
	var l1 := Label.new()
	l1.name = "SplitFirstLabel"
	l1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l1.clip_text = true
	l1.add_theme_color_override("font_color", _lane_colour(0))
	names.add_child(l1)
	var l2 := Label.new()
	l2.name = "SplitSecondLabel"
	l2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l2.clip_text = true
	l2.add_theme_color_override("font_color", _lane_colour(1))
	names.add_child(l2)
	vb.add_child(names)
	var ctl := HBoxContainer.new()
	ctl.add_theme_constant_override("separation", 6)
	var minus := Button.new()
	minus.name = "SplitMinus"
	minus.theme_type_variation = "ButtonSmall"
	minus.text = "\u2212"
	ctl.add_child(minus)
	var sl := HSlider.new()
	sl.name = "SplitSlider"
	sl.min_value = 10
	sl.max_value = 90
	sl.step = 1
	sl.value = main.split_percent(planet_index, c)
	sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sl.custom_minimum_size = Vector2(120, 20)
	ctl.add_child(sl)
	var plus := Button.new()
	plus.name = "SplitPlus"
	plus.theme_type_variation = "ButtonSmall"
	plus.text = "+"
	ctl.add_child(plus)
	vb.add_child(ctl)
	var acts := HBoxContainer.new()
	acts.add_theme_constant_override("separation", 8)
	var stop := Button.new()
	stop.name = "SplitStop"
	stop.theme_type_variation = "ButtonSmall"
	stop.text = StoryText.get_or("LBL_SPLIT_BAR_STOP", "Stop split")
	acts.add_child(stop)
	var done := Button.new()
	done.name = "SplitDone"
	done.theme_type_variation = "ButtonSmall"
	done.text = StoryText.get_or("BTN_SPLIT_DONE", "Done")
	acts.add_child(done)
	vb.add_child(acts)
	var n1: String = main.planet_name(int(pair[0]))
	var n2: String = main.planet_name(int(pair[1]))
	var refresh := func(v: float):
		l1.text = "%s %d%%" % [n1, int(v)]
		l2.text = "%d%% %s" % [100 - int(v), n2]
		_update_split_tags(c)
	refresh.call(sl.value)
	sl.value_changed.connect(func(v: float):
		main.set_split_percent(planet_index, c, int(v))
		refresh.call(float(main.split_percent(planet_index, c))))
	minus.pressed.connect(func(): sl.value = maxf(10.0, sl.value - 10.0))
	plus.pressed.connect(func(): sl.value = minf(90.0, sl.value + 10.0))
	stop.pressed.connect(func():
		main.clear_split(planet_index, c)
		split_open = ""
		rebuild())
	done.pressed.connect(func():
		split_open = ""
		rebuild())
	return vb

## Split bar: re-text the lane tags in place (the slider must not be rebuilt while it is dragged).
func _update_split_tags(c: String) -> void:
	for d in _split_tags:
		var t: Label = _split_tags[d]
		var sp: Dictionary = main.engine.lane_split(planet_index, int(d), c)
		if not sp.is_empty():
			t.text = StoryText.get_or("LBL_SPLIT_TAG", "Split {share}%", {"share": roundi(float(sp["share"]) * 100.0)})

## Real minus sign and a plus on positive numbers (design pack).
func _signed(n: int) -> String:
	if n > 0:
		return "+%d" % n
	if n < 0:
		return "\u2212%d" % -n
	return "0"

## Connections as in the design pack: one row per route (to / from planet, net, click to open its costs), then one
## row per ship ("Ship k of N", status, its own Remove). Records of the same lane (same source, destination, goods)
## are the ships of one route.
func _connections() -> void:
	var list: Array = main.connections_at(planet_index)
	var lanes: Array = []  # [{first: record view, ships: [views]}] in order of first appearance
	for v in list:
		var key := "%d|%d|%s" % [int(v["a"]), int(v["b"]), str(v["c"])]
		var found := false
		for ln in lanes:
			if ln["key"] == key:
				ln["ships"].append(v)
				found = true
				break
		if not found:
			lanes.append({"key": key, "ships": [v]})
	var cap := Label.new()
	cap.text = StoryText.get_or("LBL_CONNECTIONS", "Connections").to_upper()
	cap.theme_type_variation = "LabelCaption"
	box.add_child(HSeparator.new())
	box.add_child(cap)
	if lanes.is_empty():
		var none := _label(StoryText.get_or("LBL_NO_ROUTES", "No routes yet."))
		none.theme_type_variation = "LabelSmall"
		box.add_child(none)
		selected_route = -1
		return
	var selected_ok := false
	for ln in lanes:
		var ships: Array = ln["ships"]
		var first: Dictionary = ships[0]
		var out: bool = int(first["a"]) == planet_index
		var other: String = main.planet_name(int(first["b"]) if out else int(first["a"]))
		var net := 0
		for s in ships:
			net += int(s["net"])
		var row := RouteRow.new()
		row.set_meta("tut_target", "route")  # the guided tutorial outlines this row
		row.tooltip_text = StoryText.get_or("LBL_ROUTE_ROW_TIP", "Show this route's costs.")
		var ic := TextureRect.new()
		ic.texture = Ui.icon(str(first["c"]))
		ic.custom_minimum_size = Vector2(18, 18)
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var cc := Ui.commodity_col(str(first["c"]))
		ic.modulate = cc if cc != Color.WHITE else Ui.col("ink")
		row.add_child(ic)
		var l := Label.new()
		l.text = StoryText.get_or("LBL_ROUTE_TO" if out else "LBL_ROUTE_FROM", "To {planet}" if out else "From {planet}", {"planet": other})
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.clip_text = true
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(l)
		if out:
			var sp: Dictionary = main.engine.lane_split(planet_index, int(first["b"]), str(first["c"]))
			if not sp.is_empty():
				var pair: Array = main.split_pair(planet_index, str(first["c"]))
				var tag := Label.new()
				tag.name = "SplitTag"
				tag.theme_type_variation = "LabelSmall"
				tag.text = StoryText.get_or("LBL_SPLIT_TAG", "Split {share}%", {"share": roundi(float(sp["share"]) * 100.0)})
				tag.add_theme_color_override("font_color", _lane_colour(0 if not pair.is_empty() and int(pair[0]) == int(first["b"]) else 1))
				tag.mouse_filter = Control.MOUSE_FILTER_PASS
				tag.mouse_entered.connect(func(): if _split_bar != null: _split_bar.modulate = Color(1.4, 1.4, 1.4))
				tag.mouse_exited.connect(func(): if _split_bar != null: _split_bar.modulate = Color.WHITE)
				row.add_child(tag)
				if str(first["c"]) == split_open:
					_split_tags[int(first["b"])] = tag
		var nl := Label.new()
		nl.text = _signed(net)
		nl.theme_type_variation = "LabelGood" if net > 0 else ("LabelBad" if net < 0 else "LabelNumberMuted")
		nl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(nl)
		var first_id: int = int(first["id"])
		row.pressed.connect(func():
			selected_route = -1 if selected_route == first_id else first_id
			rebuild())
		box.add_child(row)
		if int(first["b"]) >= 0:
			box.add_child(_pays_line(int(first["b"]), str(first["c"])))
		for k in ships.size():
			var v: Dictionary = ships[k]
			box.add_child(_ship_row(v, k + 1, ships.size()))
			var mv: Dictionary = main.move_offer(int(v["id"])) if str(v["status"]) == "blocked" else {}
			if not mv.is_empty():
				box.add_child(_move_line(int(v["id"]), mv))
			if int(v["id"]) == selected_route:
				selected_ok = true
		if main.engine.lane_full(int(first["a"]), int(first["b"]), str(first["c"])):
			box.add_child(_upgrade_line(first))
		if selected_route == first_id or _lane_has(ships, selected_route):
			_route_detail(first)
	if not selected_ok:
		selected_route = -1

## T143: where the route's money lands. A route pays only when its destination has a standing Sell order for the goods.
## One control turns that order on (the existing local-order toggle at the destination).
func _pays_line(dest: int, c: String) -> Control:
	var on: bool = main.engine.local_on(dest, c, "sell")
	var row := HBoxContainer.new()
	row.name = "PaysLine"
	# One credit icon replaces the sentence: green = the destination has a standing Sell order (the route pays), red = it does not.
	# A click turns that Sell order on or off; the full sentence is the tooltip.
	var state: String = StoryText.get_or("LBL_ORDER_ON", "on") if on else StoryText.get_or("LBL_ORDER_OFF", "off")
	var sentence: String = StoryText.get_or("LBL_ROUTE_PAYS", "Pays when {planet} has a standing Sell order: {state}", {"planet": main.planet_name(dest), "state": state})
	var b := Button.new()
	b.name = "PaysSellButton"
	b.set_meta("sell_dest", dest)  # T334: the guided Sell card finds the button for its route
	b.set_meta("sell_good", c)
	b.theme_type_variation = "ButtonGhost"
	b.flat = true
	b.icon = Ui.icon("credit")
	b.expand_icon = true
	b.add_theme_constant_override("icon_max_width", 20)
	b.custom_minimum_size = Vector2(30, 26)
	var col: Color = Ui.col("signal_good") if on else Ui.col("signal_bad")
	for k in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_hover_pressed_color", "icon_focus_color", "icon_disabled_color"]:
		b.add_theme_color_override(k, col)
	var blocked: bool = main.engine.check_local(dest, c, "sell")["ok"] == false
	b.disabled = (not on and blocked) or not main.tut_allows("sell", dest, c)
	b.tooltip_text = sentence if not b.disabled else StoryText.get_or("LBL_ROUTE_PAYS_NO", "Not traded there.")
	if not on and not b.disabled:
		b.tooltip_text += "\n" + StoryText.get_or("LBL_ROUTE_PAYS_TIP", "Turn on the Sell order at {planet}.", {"planet": main.planet_name(dest)})
	b.pressed.connect(func():
		var r: Dictionary = main.toggle_local(dest, c, "sell")
		if not r["ok"]:
			main.post_notice(str(r["reason"])))
	row.add_child(b)
	return row

## T147: shown only on a full lane (the caller checks engine.lane_full). Enable and tooltip come from
## main.can_upgrade_route; once the lane is level 2 it reads as taken.
func _upgrade_line(first: Dictionary) -> Control:
	var cost: int = main.upgrade_cost()
	var bonus_pct := roundi(float(main.balance.get("upgrade_margin_bonus", 0.0)) * 100.0)
	var row := HBoxContainer.new()
	row.name = "UpgradeLine"
	row.add_theme_constant_override("separation", 8)
	var l := Label.new()
	l.theme_type_variation = "LabelSmall"
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(150, 0)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if main.engine.lane_level(int(first["a"]), int(first["b"]), str(first["c"])) >= 2:
		l.name = "UpgradeRouteTaken"
		l.text = StoryText.get_or("LBL_ROUTE_UPGRADED", "Route upgraded: +{pct}% margin.", {"pct": bonus_pct})
		row.add_child(l)
		return row
	l.text = StoryText.get_or("LBL_ROUTE_UPGRADE_INFO", "Full lane. Upgrade: {cost} credits for +{pct}% margin.", {"cost": cost, "pct": bonus_pct})
	row.add_child(l)
	tip_seen.emit("upgrade")  # T353: the Upgrade route button is drawn on a lane not yet level 2
	var rid: int = int(first["id"])
	var chk: Dictionary = main.can_upgrade_route(rid)
	var b := Button.new()
	b.name = "UpgradeRouteButton"
	b.text = StoryText.get_or("BTN_UPGRADE_ROUTE", "Upgrade route")
	b.disabled = not chk["ok"]
	b.tooltip_text = StoryText.get_or("LBL_ROUTE_UPGRADE_TIP", "Raise this lane's margin for {cost} credits.", {"cost": cost}) if chk["ok"] else str(chk["reason"])
	b.pressed.connect(func():
		var r: Dictionary = main.upgrade_route(rid)
		if not r["ok"]:
			main.post_notice(str(r["reason"])))
	row.add_child(b)
	return row

## P2: under a ship stranded by a closed planet. The player may press Move ship; nothing moves by itself.
func _move_line(id: int, offer: Dictionary) -> Control:
	var box_m := VBoxContainer.new()
	box_m.name = "MoveLine"
	box_m.add_theme_constant_override("separation", 4)
	var l := Label.new()
	l.name = "MoveOffer"
	l.theme_type_variation = "LabelSmall"
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.text = StoryText.get_or("LBL_BEST_OPEN_ROUTE", "Best open route: +{net} per cycle", {"net": int(offer["net"])})
	box_m.add_child(l)
	if bool(offer["setup_lost"]):
		var lost := Label.new()
		lost.name = "MoveSetupLost"
		lost.theme_type_variation = "LabelWarn"
		lost.text = StoryText.get_or("LBL_SETUP_LOST", "Setup lost")
		box_m.add_child(lost)
	var b := Button.new()
	b.name = "MoveShipButton"
	b.theme_type_variation = "ButtonSmall"
	b.text = StoryText.get_or("BTN_MOVE_SHIP", "Move ship")
	b.pressed.connect(func():
		var r: Dictionary = main.move_ship(id)
		if not r["ok"]:
			main.post_notice(str(r["reason"])))
	box_m.add_child(b)
	return box_m

func _lane_has(ships: Array, id: int) -> bool:
	for v in ships:
		if int(v["id"]) == id:
			return true
	return false

## One ship of a route: icon, "Ship k of N", status, Remove.
func _ship_row(v: Dictionary, k: int, n: int) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(12, 0)
	row.add_child(pad)
	var ic := TextureRect.new()
	ic.texture = Ui.icon("ship")
	ic.custom_minimum_size = Vector2(16, 16)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ic.modulate = Ui.col("ink_muted")
	row.add_child(ic)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_l := Label.new()
	name_l.text = StoryText.get_or("LBL_SHIP_K_OF_N", "Ship {k} of {n}", {"k": k, "n": n})
	info.add_child(name_l)
	var st: String = v["status"]
	var sl := Label.new()
	sl.theme_type_variation = "LabelSmall"
	sl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sl.custom_minimum_size = Vector2(150, 0)
	if st == "running":
		sl.text = StoryText.get_or("LBL_SHIP_RUNNING", "Running.")
	elif st == "stalled" or st == "waiting":
		sl.text = RouteLineScript.reason_text(st, str(v["reason"]))  # the route's real reason; Waiting for room only when waiting
		sl.theme_type_variation = "LabelWarn"
	else:
		sl.text = str(v["reason"]) if str(v["reason"]) != "" else st.capitalize()
		sl.theme_type_variation = "LabelBad"
	info.add_child(sl)
	row.add_child(info)
	var rm := Button.new()
	rm.theme_type_variation = "ButtonSmall"
	rm.text = StoryText.get_text("BTN_REMOVE")
	var rid: int = int(v["id"])
	rm.pressed.connect(func(): remove_requested.emit(rid))
	row.add_child(rm)
	return row

## Costs of the route picked in the list (same figures the game already used per connection).
func _route_detail(v: Dictionary) -> void:
	var st: String = v["status"]
	var l := _label("")
	l.theme_type_variation = "LabelSmall"
	if st != "running" and str(v["reason"]) != "":
		l.text = str(v["reason"])
	elif st == "running":
		var ri: int = main.engine.find_by_id(int(v["id"]))
		var rec = main.engine.routes[ri] if ri >= 0 else null
		var up: int = main.engine.upkeep_part(rec)
		var trip: int = main.engine.trip_part()
		var paying: bool = int(v["net"]) < 0
		l.text = StoryText.get_or("LBL_COST_LINE", "{label}: \u2212{n}", {"label": StoryText.get_text("LBL_TRIP_COST"), "n": trip if paying else 0})
		l.text += "\n" + StoryText.get_or("LBL_COST_LINE", "{label}: \u2212{n}", {"label": StoryText.get_text("LBL_SHIP_UPKEEP"), "n": up if paying else 0})
		l.text += "\n" + StoryText.get_or("LBL_NET_LINE", "{label}: {n} / cycle", {"label": StoryText.get_text("LBL_NET"), "n": _signed(int(v["net"]))})
		var off: float = main.engine.offset_of(rec)
		if off > 0.0:  # one line: the detour round other planets or routes and what it adds to the upkeep
			l.text += "\n" + StoryText.get_or("ROUTE_OFFSET_MAINT", "Route detour +{offset}%: upkeep +{maint}%", {"offset": roundi(off * 100.0), "maint": roundi(float(main.balance.get("route_offset_maint_pct", 0.0)) * off * 100.0)})
	if l.text != "":
		box.add_child(l)

func _label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(288, 0)
	return l


## A clickable route row: hover highlights it, click emits pressed.
class RouteRow extends HBoxContainer:
	signal pressed
	var _hover := false
	func _init() -> void:
		add_theme_constant_override("separation", 8)
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		custom_minimum_size = Vector2(0, 28)
		mouse_entered.connect(func(): _hover = true; queue_redraw())
		mouse_exited.connect(func(): _hover = false; queue_redraw())
	func _draw() -> void:
		if _hover:
			draw_rect(Rect2(Vector2(-4, 0), size + Vector2(8, 0)), Ui.col("panel_200"), true)
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			accept_event()  # before emit: pressed rebuilds the panel and removes this node, and a removed node cannot mark the event handled
			pressed.emit()

## Vertical rating bar: 5 stacked lines, bottom first lit, 5 lit = full storage.
class RatingBar extends Control:
	var level: int = 0
	func _init() -> void:
		custom_minimum_size = Vector2(16, 40)
	func _draw() -> void:
		for i in 5:
			var y := size.y - 4.0 - float(i) * 8.0
			var col: Color = Ui.col("star_warm") if i < level else Ui.col("panel_300")
			draw_line(Vector2(1, y), Vector2(size.x - 1, y), col, 3.0)

## Round planet thumbnail. Uses art/ui/ui_thumb_<type>.png when present, else a plain disc.
class Thumb extends Control:
	signal pressed
	var planet: Dictionary = {}
	var selected := false
	var tex: Texture2D
	func _ready() -> void:
		custom_minimum_size = Vector2(40, 40)
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tex = Ui.ui_texture("ui_thumb_%s" % str(planet.get("type", "")).to_lower())
		mouse_entered.connect(func(): _hover = true; queue_redraw())
		mouse_exited.connect(func(): _hover = false; queue_redraw())
	var _hover := false
	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.5 - 3.0
		if tex != null:
			draw_texture_rect(tex, Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0), false)
		else:
			var cc := Ui.commodity_col(str(planet.get("abundant", "")))
			draw_circle(c, r, (cc if cc != Color.WHITE else Ui.col("ink_muted")).darkened(0.35))
		draw_arc(c, r + 1.0, 0.0, TAU, 40, Ui.col("star_warm") if selected else Color(1, 1, 1, 0.22), 2.0 if selected else 1.0, true)
		if _hover:  # the shared clickable cue: a warm outline
			draw_arc(c, r + 2.0, 0.0, TAU, 40, Ui.col("star_warm"), 2.0, true)
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			accept_event()  # before emit: pressed rebuilds the panel and removes this node, and a removed node cannot mark the event handled
			pressed.emit()

## T285: mood face in the card header: three drawn variants (Ui.draw_mood_face); hover shows its tip.
class MoodFace extends Control:
	var mood := "plain"
	var px := 16.0
	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_PASS
	func _ready() -> void:
		custom_minimum_size = Vector2(px, px)
	func _draw() -> void:
		Ui.draw_mood_face(self, size * 0.5, minf(size.x, size.y) * 0.5 - 1.0, mood)

## T285: a weather chip in the card: tint bar, kind, the good name (only when Availability shows it) and cycles left.
class WeatherChip extends Control:
	var row: Dictionary = {}
	var h := 15.0
	var fs := 11
	var alpha := 0.88
	var _w := 0.0
	func setup(a: Dictionary, chip_h: float, font_px: int, bg_alpha: float) -> void:
		row = a
		h = chip_h
		fs = font_px
		alpha = bg_alpha
		mouse_filter = Control.MOUSE_FILTER_PASS
		size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		var tw := Ui.mono_font().get_string_size(_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var bar := maxf(2.0, h * 0.2)
		var pad := h * 0.35
		_w = bar + pad + tw + pad
		custom_minimum_size = Vector2(_w, h)
	func _text() -> String:
		return Ui.weather_text(row, true)
	func _draw() -> void:
		Ui.draw_chip(self, Vector2.ZERO, _text(), Ui.house_col(int(row.get("house", 0))), Ui.mono_font(), fs, h, alpha)
