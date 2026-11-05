extends RefCounted
## Ship types from data/ships.json (4 types: small, bulk, dart, fleet). The player picks one type at the start and
## every ship of the run is that type (Ships.fleet). Multipliers are in the data file: cargo_mult, upkeep_mult,
## trip_mult, price_mult (ship_price), cap_add (+ to ship_cap); speed is display only.
##
## UI API: Ships.types() ids in file order, Ships.stats(id) card numbers, Ships.model(id), Ships.display_name(id),
## Ships.fleet (chosen type), Ships.set_fleet(id), Ships.cap(bal) (ship_cap with cap_add of the fleet).

const StoryText := preload("res://game/story_text.gd")
const PATH := "res://data/ships.json"
const DEFAULT := "small"

## Type of every ship in the current run. Set by main.gd (new game or save).
static var fleet: String = DEFAULT

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
	return _defs.get(kind, _defs.get(DEFAULT, {}))

## Ids of all ship types, in file order.
static func types() -> Array:
	if _defs.is_empty():
		_load()
	return _defs.keys()

static func has(kind: String) -> bool:
	if _defs.is_empty():
		_load()
	return _defs.has(kind)

## Unknown or empty ids give the default type.
static func normalize(kind: String) -> String:
	return kind if has(kind) else DEFAULT

static func set_fleet(kind: String) -> void:
	fleet = normalize(kind)

static func _num(kind: String, field: String, bal: Dictionary, fallback: float) -> float:
	var d := def(kind)
	if d.has(field + "_key"):
		return float(bal.get(str(d[field + "_key"]), fallback))
	return float(d.get(field, fallback))

## Price of one ship: ship_price x price_mult.
static func price(kind: String, bal: Dictionary) -> int:
	return roundi(_num(kind, "price", bal, 0.0) * float(def(kind).get("price_mult", 1.0)))

## Trip cost multiplier of the type.
static func trip_mult(kind: String) -> float:
	return float(def(kind).get("trip_mult", 1.0))

## Extra hulls the type allows on top of balance ship_cap.
static func cap_add(kind: String) -> int:
	return int(def(kind).get("cap_add", 0))

## Ship limit of the current run: balance ship_cap + cap_add of the fleet type.
static func cap(bal: Dictionary) -> int:
	return int(bal.get("ship_cap", 0)) + cap_add(fleet)

## 3D model path for the UI and the map ("" when none).
static func model(kind: String) -> String:
	return str(def(kind).get("model", ""))

## Numbers for a stat card: multipliers as in the file, price in credits, cap as the total ship limit.
static func stats(kind: String, bal: Dictionary) -> Dictionary:
	var d := def(kind)
	return {"id": str(d.get("id", kind)), "name": display_name(kind), "cargo_mult": cargo_mult(kind, bal), "upkeep_mult": upkeep_mult(kind, bal),
		"trip_mult": trip_mult(kind), "price_mult": float(d.get("price_mult", 1.0)), "price": price(kind, bal), "cap_add": cap_add(kind),
		"ship_cap": int(bal.get("ship_cap", 0)) + cap_add(kind), "speed": speed(kind), "model": model(kind),
		"role_id": str(d.get("role_id", "")), "desc_id": str(d.get("desc_id", ""))}

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
