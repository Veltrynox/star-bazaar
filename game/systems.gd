extends RefCounted
## T85: systems beyond system 1 (data/systems.json). System 1 is planets.json and is always open.
## A system entry: {id, name_id, desc_id, permit_*_id, permit_cost_key, permit_points_key, requires_skill, planets}.
## Planet entries get "name" and "desc" resolved from story ids and "system" set, so every other script
## can read map.planets[i] the same way for any system. Costs are balance.json keys, never numbers here.

const StoryText := preload("res://game/story_text.gd")
const PATH := "res://data/systems.json"

static var _cache: Array = []
static var _loaded := false

static func all() -> Array:
	if not _loaded:
		_loaded = true
		_cache = []
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
		if typeof(parsed) == TYPE_DICTIONARY and typeof(parsed.get("systems")) == TYPE_ARRAY:
			for s in parsed["systems"]:
				if typeof(s) == TYPE_DICTIONARY and s.has("id"):
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
		d["name"] = StoryText.get_text(str(d["name_id"])) if d.has("name_id") else str(d.get("id", "?"))
		d["desc"] = StoryText.get_text(str(d["desc_id"])) if d.has("desc_id") else ""
		d["system"] = id
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
