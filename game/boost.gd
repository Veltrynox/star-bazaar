class_name Boost
extends RefCounted
## T371: the production boost. A charter (a charge) lets the player boost ONE world for the rest of the run: every Buy order there
## takes balance boost_order_pct more per cycle (RouteEngine.buy_amount) and the world's storage room is boost_storage_pct bigger
## (Storage.capacity_of). Sell orders are not boosted.
##
## Charges: one per learned node with the boost_charge effect (Skills.boost_charges(), live), plus one per entry of `grants`
## ("event:EV97", "gig:GIG03"; saved). Charges held = skill charges + grants - boosted worlds. One world per charge, one boost per world.
## API (main.boost): charges() int, can_boost(planet) Dictionary {ok, reason}, use_boost(planet) Dictionary {ok, reason},
## is_boosted(planet) bool, grant(source), boosted_count(). `planet` is a planet index. Save: main collect_state() run.boost
## {grants: [], planets: [planet ids]}; an older save has no key and loads with nothing.
## Notices (StoryText.get_or, plain English fallback): PB_NOTICE_GAINED first charge, PB_NOTICE_STACK another charge while one is held,
## PB_NOTICE_USED a world boosted, PB_NOTICE_SECOND_<MKT> the second world boosted. {planet} placeholder.

const StoryText := preload("res://game/story_text.gd")
const Clusters := preload("res://game/clusters.gd")
const DeadWorlds := preload("res://game/dead_worlds.gd")

var main: Object = null
var grants: Array = []
var planets: Array = []  # planet ids of boosted worlds

func setup(m: Object) -> void:
	main = m

func reset() -> void:
	grants = []
	planets = []
	sync()

func boosted_count() -> int:
	return planets.size()

func charges() -> int:
	return maxi(0, Skills.boost_charges() + grants.size() - planets.size())

func is_boosted(planet: int) -> bool:
	return planets.has(_pid(planet))

func _pid(planet: int) -> String:
	if main == null or planet < 0 or planet >= main.map.planets.size():
		return ""
	return str(main.map.planets[planet].get("id", ""))

## Why a world cannot take a charter now: {ok: true} or {ok: false, reason}.
func can_boost(planet: int) -> Dictionary:
	if charges() <= 0:
		return {"ok": false, "reason": StoryText.get_or("PB_NO_CHARGE", "No production charter held.")}
	var pid := _pid(planet)
	if pid == "" or Clusters.is_node(planet):
		return {"ok": false, "reason": StoryText.get_or("PB_NO_WORLD", "Not a world.")}
	if planets.has(pid):
		return {"ok": false, "reason": StoryText.get_or("PB_ALREADY", "Already boosted.")}
	var p: Dictionary = main.map.planets[planet]
	if DeadWorlds.is_dead(p) or not main.planet_atom("post_built", pid):
		return {"ok": false, "reason": StoryText.get_or("PB_NO_POST", "Needs a trading post.")}
	if not main.engine.planet_open(planet):
		return {"ok": false, "reason": StoryText.get_or("PB_CLOSED", "The planet is closed.")}
	for c in main.commodities:
		if main.engine.local_price(planet, str(c), "buy") >= 0 and Availability.good(str(c)):
			return {"ok": true, "reason": ""}
	return {"ok": false, "reason": StoryText.get_or("PB_NO_GOODS", "Nothing to buy here yet.")}

## Spends one charge on the world. Returns {ok, reason}.
func use_boost(planet: int) -> Dictionary:
	var v := can_boost(planet)
	if not v["ok"]:
		return v
	var second := not planets.is_empty()
	planets.append(_pid(planet))
	sync()
	var args := {"planet": main.planet_name(planet)}
	if second:
		var mk := str(Conditions.run_branch()).to_upper()
		main.post_notice(StoryText.get_or("PB_NOTICE_SECOND_" + mk, StoryText.get_or("PB_NOTICE_USED", "{planet} now takes more every cycle.", args), args))
	else:
		main.post_notice(StoryText.get_or("PB_NOTICE_USED", "{planet} now takes more every cycle.", args))
	main._after_change()
	main.save_now()
	return {"ok": true, "reason": ""}

## One charter from an event or gig. source = "event:<id>" or "gig:<id>".
func grant(source: String) -> void:
	var held := charges()
	grants.append(source)
	_gained(held)

## A node with the boost_charge effect was just learned (main.learn_skill).
func on_skill_learned() -> void:
	_gained(charges() - 1)

func _gained(held_before: int) -> void:
	if main == null:
		return
	var args := {"planet": _example_planet()}
	if held_before >= 1:
		main.post_notice(StoryText.get_or("PB_NOTICE_STACK", "You hold another production charter.", args))
	else:
		main.post_notice(StoryText.get_or("PB_NOTICE_GAINED", "You hold a production charter. Open a world's card to spend it.", args))
	if main.has_method("_refresh_panel"):
		main._refresh_panel()

## A world that could take a charter now (the first one), else the home world: the {planet} of the stack story.
func _example_planet() -> String:
	for i in main.map.planets.size():
		if can_boost(i)["ok"]:
			return main.planet_name(i)
	return main.planet_name(maxi(main.mission_planet, 0))

## Pushes the boosted worlds to the route engine and the storage (main calls it after a load too).
func sync() -> void:
	if main == null:
		return
	var idx: Array = []
	var keys: Array = []
	for pid in planets:
		var i: int = main.planet_index_of(str(pid))
		if i >= 0:
			idx.append(i)
			keys.append(main.storage.planet_key(i))
	main.engine.boosted_planets = idx
	main.storage.boosted = keys

func to_dict() -> Dictionary:
	return {"grants": grants.duplicate(), "planets": planets.duplicate()}

func from_dict(d) -> void:
	grants = []
	planets = []
	if typeof(d) == TYPE_DICTIONARY:
		for g in d.get("grants", []):
			grants.append(str(g))
		for p in d.get("planets", []):
			if not planets.has(str(p)):
				planets.append(str(p))
	sync()
