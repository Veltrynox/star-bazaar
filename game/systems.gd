extends RefCounted
## T85: systems beyond system 1 (data/systems.json). System 1 is planets.json and is always open.
## A system entry: {id, name_id, desc_id, permit_*_id, permit_cost_key, permit_points_key, requires_skill, planets}.
## Planet entries get "name" and "desc" resolved from story ids and "system" set, so every other script
## can read map.planets[i] the same way for any system. Costs are balance.json keys, never numbers here.

const StoryText := preload("res://game/story_text.gd")
const PlanetTypes := preload("res://game/planet_types.gd")
const PATH := "res://data/systems.json"
## T176: placeholder systems (data/systems_placeholder.json) join all() when they carry "on": true (system 3, live, TEMPORARY names; the game has three systems),
## or all of them while that file says "enabled": true or a test calls set_placeholders(true). set_placeholders(false) hides every one.
const PLACEHOLDER_PATH := "res://data/systems_placeholder.json"

## Sun colour per system (systems.json may override with a "sun_color": "#rrggbb" key). System 1 keeps the original orange sun.
## System 2: a blue star, hue 0.60 (216 degrees).
const SUN_COLORS := {2: Color(0.25, 0.5, 1.0)}

static func sun_color_of(id: int) -> Color:
	var s := get_system(id)
	if s.has("sun_color"):
		return Color.html(str(s["sun_color"]))
	if SUN_COLORS.has(id):
		return SUN_COLORS[id]
	return Color.from_hsv(0.09, 0.8, 1.0)  # same as sun_flare.gd BASE_HUE: the original sun

static var _cache: Array = []
static var _loaded := false

static func set_placeholders(on: bool) -> void:
	_placeholders_override = 1 if on else 0
	_loaded = false

static var _placeholders_override := -1

## Back to the data default (system 3 on). Tests call this after set_placeholders.
static func reset_placeholders() -> void:
	_placeholders_override = -1
	_loaded = false

static func all() -> Array:
	if not _loaded:
		_loaded = true
		_cache = []
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
		if typeof(parsed) == TYPE_DICTIONARY and typeof(parsed.get("systems")) == TYPE_ARRAY:
			for s in parsed["systems"]:
				if typeof(s) == TYPE_DICTIONARY and s.has("id"):
					_cache.append(s)
		var ph = JSON.parse_string(FileAccess.get_file_as_string(PLACEHOLDER_PATH)) if FileAccess.file_exists(PLACEHOLDER_PATH) else null
		if typeof(ph) == TYPE_DICTIONARY and typeof(ph.get("systems")) == TYPE_ARRAY:
			var on: bool = bool(ph.get("enabled", false)) if _placeholders_override < 0 else _placeholders_override == 1
			for s in ph["systems"]:
				# T226: a system with "on": true (3 to 5) is live in normal play; the rest join only when enabled
				if typeof(s) == TYPE_DICTIONARY and s.has("id") and (on or (_placeholders_override < 0 and bool(s.get("on", false)))):
					_cache.append(s)
	return _cache

static func get_system(id: int) -> Dictionary:
	for s in all():
		if int(s["id"]) == id:
			return s
	return {}

static func ids() -> Array:
	var out := []
	for s in all():
		out.append(int(s["id"]))
	return out

## Fresh planet dictionaries of system `id`, text resolved, "system" set.
static func planets_of(id: int) -> Array:
	var out := []
	for p in get_system(id).get("planets", []):
		var d: Dictionary = p.duplicate(true)
		d["name"] = StoryText.get_text(str(d["name_id"])) if d.has("name_id") else str(d.get("name", d.get("id", "?")))
		d["desc"] = StoryText.get_text(str(d["desc_id"])) if d.has("desc_id") else ""
		d["system"] = id
		PlanetTypes.apply(d)
		Goods.merge_prices(d)  # prices of the new goods (data/goods.json)
		out.append(d)
	return out

static func name_of(id: int) -> String:
	if id == 1:
		return StoryText.get_text("WORLD_SYS1_NAME")
	var s := get_system(id)
	return StoryText.get_text(str(s["name_id"])) if s.has("name_id") else "System %d" % id

static func permit_cost(balance: Dictionary, id: int) -> int:
	return int(balance.get(str(get_system(id).get("permit_cost_key", "")), 0))

static func permit_points(balance: Dictionary, id: int) -> int:
	return int(balance.get(str(get_system(id).get("permit_points_key", "")), 0))
