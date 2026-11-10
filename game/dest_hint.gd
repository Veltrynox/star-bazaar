class_name DestHint
extends Control
## Hover card at the cursor while a route waits for a destination click (main.pending is not empty): says whether the planet,
## dead world or Space Storage station under the cursor can take the pending good, with the price it pays, or the SAME refusal
## text the click would post. Nothing is shown when no route is pending, under the tutorial lock, or over a panel.
## DestHint.describe(main, planet, station) gives the text (empty = no card). Stacks below the red unaffordable-ship warning.

const StoryText := preload("res://game/story_text.gd")
const CARD_OFFSET := Vector2(18, 20)
const STACK_DROP := 26.0  # when the red ship warning is also showing, this card sits below it

var main: Node
var _panel: PanelContainer
var _label: Label

func setup(m: Node) -> void:
	main = m
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 20
	_panel = PanelContainer.new()
	_panel.name = "DestHintCard"
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label = Label.new()
	_label.theme_type_variation = "LabelSmall"
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_label)
	_panel.visible = false
	add_child(_panel)
	visible = false

## The card text for the destination under the cursor (planet index or -1, station system id or -1). "" = show nothing.
static func describe(m: Node, planet: int, station: int) -> String:
	if m == null or m.pending.is_empty() or m.game_over or m.tut_lock_active() or m.pending.has("dest"):
		return ""
	var c := str(m.pending["c"])
	if not Availability.good(c):  # never name or price a hidden good
		return ""
	var src := int(m.pending["planet"])
	var good: String = Ui.good_name(c)
	if planet >= 0 and planet < m.map.planets.size():
		if planet == src:
			return StoryText.get_or("HINT_DEST_SOURCE", "The route starts here. Pick another planet.")
		if m.DeadWorlds.is_dead(m.map.planets[planet]):
			return StoryText.get_or("NOT_DEAD_NO_DELIVERY", "Nothing is delivered to a dead world. Pick another planet.")
		var r: Dictionary = m.can_connect(src, planet, c)
		if not r["ok"] and str(r["reason"]) != StoryText.get_text("NOT_SHIP_FREE"):  # no free ship: the click buys one
			return str(r["reason"])
		var price: int = m.engine.sold_price(planet, c)
		if price > 0:
			return StoryText.get_or("HINT_DEST_BUYS", "{planet} buys {good} at {price} cr each.", {"planet": m.planet_name(planet), "good": good, "price": price})
		return StoryText.get_or("HINT_DEST_NO_BUYER", "{planet} does not buy {good}.", {"planet": m.planet_name(planet), "good": good})
	if station >= 0:
		var r2: Dictionary = m.can_connect(src, m.station_dst(station), c)
		if not r2["ok"] and str(r2["reason"]) != StoryText.get_text("NOT_SHIP_FREE"):
			return str(r2["reason"])
		return StoryText.get_or("HINT_DEST_STATION", "Space Storage keeps {good} for later.", {"good": good})
	return ""

## Hover card with no route pending: the good the planet wants most (its first short need, with this cycle's count against the
## demand), else its tier and that every need is met. "" for a world not established yet, a dead world, a locked good or a blocked view.
static func describe_hover(m: Node, planet: int) -> String:
	if m == null or m.game_over or m.preface != null or m.map_overlays_blocked() or planet < 0 or planet >= m.map.planets.size():
		return ""
	if not m.planet_established(planet) or m.DeadWorlds.is_dead(m.map.planets[planet]):
		return ""
	var pr = m.prosperity
	var t: int = pr.tier(planet)
	if t <= 0:
		return ""
	var wanted: Array = []
	for n in pr.needs(planet):
		if not bool(n["locked"]) and not bool(n["met"]):
			wanted.append(Ui.good_name(str(n["good"])))
	var nm: String = m.planet_name(planet)
	if not wanted.is_empty():
		return StoryText.get_or("HINT_PLANET_WANTS", "{planet} wants {goods}.", {"planet": nm, "goods": ", ".join(PackedStringArray(wanted))})
	return StoryText.get_or("HINT_PLANET_FED", "{planet}: {tier}. Every need is met.", {"planet": nm, "tier": StoryText.get_or("PROS_TIER_%d" % t, "Tier %d" % t)})

func _process(_delta: float) -> void:
	if main == null:
		_hide()
		return
	var mouse := get_viewport().get_mouse_position()
	var hov := get_viewport().gui_get_hovered_control()
	if hov != null and hov != main and not (hov is DestHint):  # the cursor is over a panel or button, not the map
		_hide()
		return
	var hit: int = main.map.pick_planet(mouse)
	var sid := -1
	if hit < 0:
		sid = main.map.pick_station(mouse)
	var t := describe(main, hit, sid) if not main.pending.is_empty() else describe_hover(main, hit)
	if t == "":
		_hide()
		return
	_label.text = t
	var vp := get_viewport_rect().size
	var sz := _panel.get_combined_minimum_size()
	_panel.size = sz
	var p := mouse + CARD_OFFSET
	if not main.route_unaffordable().is_empty():
		p.y += STACK_DROP
	p.x = clampf(p.x, 4.0, maxf(4.0, vp.x - sz.x - 4.0))
	p.y = clampf(p.y, 4.0, maxf(4.0, vp.y - sz.y - 4.0))
	_panel.position = p
	visible = true
	_panel.visible = true

func _hide() -> void:
	if visible:
		visible = false
		_panel.visible = false
