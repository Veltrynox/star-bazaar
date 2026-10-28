extends RefCounted
## T58: ship types from data/ships.json (small, large). Numbers: price, cargo and upkeep multipliers
## come from balance.json keys named in the file; speed is abstract and display only.
## Ships are for hauling only: they move stock along routes.

const StoryText := preload("res://game/story_text.gd")
const PATH := "res://data/ships.json"
const KINDS := ["small", "large"]

static var _defs: Dictionary = {}

static func _load() -> void:
	_defs = {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
	if typeof(parsed) == TYPE_DICTIONARY and typeof(parsed.get("types")) == TYPE_ARRAY:
		for t in parsed["types"]:
			if typeof(t) == TYPE_DICTIONARY and t.has("id"):
				_defs[str(t["id"])] = t
	if _defs.is_empty():
		push_error("Ships: %s missing or bad." % PATH)

static func def(kind: String) -> Dictionary:
	if _defs.is_empty():
		_load()
	return _defs.get(kind, _defs.get("small", {}))

static func _num(kind: String, field: String, bal: Dictionary, fallback: float) -> float:
	var d := def(kind)
	if d.has(field + "_key"):
		return float(bal.get(str(d[field + "_key"]), fallback))
	return float(d.get(field, fallback))

static func price(kind: String, bal: Dictionary) -> int:
	return int(_num(kind, "price", bal, 0.0))

static func cargo_mult(kind: String, bal: Dictionary) -> float:
	return _num(kind, "cargo_mult", bal, 1.0)

static func upkeep_mult(kind: String, bal: Dictionary) -> float:
	return _num(kind, "upkeep_mult", bal, 1.0)

static func speed(kind: String) -> float:
	return float(def(kind).get("speed", 1.0))

## Name from the story id when it exists, else the plain name from the data file.
static func display_name(kind: String) -> String:
	var d := def(kind)
	return StoryText.get_or(str(d.get("name_id", "")), str(d.get("name", kind.capitalize())))
