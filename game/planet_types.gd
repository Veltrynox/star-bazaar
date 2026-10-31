extends RefCounted
## Planet type table (data/planet_types.json). The type decides abundant/scarce; amounts come later from the economy.

const PATH := "res://data/planet_types.json"

static var _types: Dictionary = {}
static var _loaded := false

static func table() -> Dictionary:
	if not _loaded:
		_loaded = true
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
		if typeof(parsed) == TYPE_DICTIONARY and typeof(parsed.get("types")) == TYPE_ARRAY:
			for t in parsed["types"]:
				if typeof(t) == TYPE_DICTIONARY and t.has("id"):
					_types[str(t["id"])] = t
		else:
			push_warning("planet_types.json missing or bad")
	return _types

## Sets "abundant" and "scarce" on planet dictionary p from its "type". Warns if the type is unknown.
static func apply(p: Dictionary) -> void:
	var tt: Dictionary = table()
	var id := str(p.get("type", ""))
	if not tt.has(id):
		push_warning("Planet %s has type '%s' missing from planet_types.json" % [str(p.get("id", "?")), id])
		return
	p["abundant"] = tt[id]["abundant"]
	p["scarce"] = tt[id]["scarce"]
