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

## T197: each GLB's nose points along its own -X (measured: long axis X, narrow end at -X), not Godot's -Z. Yaw in degrees
## added to the model so its nose points along the ship's heading (-Z at rotation.y = 0). Keyed by ship id of data/ships.json.
const MODEL_YAW_DEG := {"small": -90.0, "bulk": -90.0, "dart": -90.0, "fleet": -90.0}

## T205: where the engine exhaust sits, as a fraction of the ship's footprint radius behind its centre (along the model's tail).
## Per model type, next to MODEL_YAW_DEG; the owner can move a trail by editing one number.
const ENGINE_BACK := {"small": 0.9, "bulk": 0.9, "dart": 0.9, "fleet": 0.9}

static var _defs: Dictionary = {}
static var _scale: float = -1.0

## T252: global ship size multiplier (data/balance.json ship_scale). Applies to every ship model on the map (player, rival,
## traffic, later pirates, which multiply their own ratio on top), its selection ring, trail width and engine offset.
static func ship_scale() -> float:
	if _scale < 0.0:
		var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance.json")) if FileAccess.file_exists("res://data/balance.json") else null
		_scale = maxf(0.05, float((parsed.get("values", {}) as Dictionary).get("ship_scale", 1.0))) if parsed is Dictionary else 1.0
	return _scale


## Yaw offset (radians) of a ship type's model; 0 for an unknown id.
static func model_yaw(kind: String) -> float:
	return deg_to_rad(float(MODEL_YAW_DEG.get(kind, 0.0)))

static func engine_back(kind: String) -> float:
	return float(ENGINE_BACK.get(kind, 0.9))

static func engine_back_for_path(path: String) -> float:
	for k in types():
		if model(str(k)) == path:
			return engine_back(str(k))
	return 0.9

## Same, found by GLB path (for views that only know the model path).
static func model_yaw_for_path(path: String) -> float:
	for k in types():
		if model(str(k)) == path:
			return model_yaw(str(k))
	return 0.0

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

## Price of one ship: ship_price x price_mult. `owned` (ships already owned; -1 = ignore): the first and the second ship after the first
## cost ship_price_step_1 and ship_price_step_2 of the price (economy check 3.5); later ships pay full price. Main.ship_price() is the one caller that passes it.
static func price(kind: String, bal: Dictionary, owned: int = -1) -> int:
	var step := 1.0
	if owned == 1:
		step = float(bal.get("ship_price_step_1", 1.0))
	elif owned == 2:
		step = float(bal.get("ship_price_step_2", 1.0))
	return roundi(_num(kind, "price", bal, 0.0) * float(def(kind).get("price_mult", 1.0)) * Skills.ship_price_mult() * step)

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
