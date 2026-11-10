extends RefCounted
## T76: story texts from data/story_text.json (built by tools/build_story.py from story/*.md).
## Use: StoryText.get_text("NOT_SAVED") or StoryText.get_text("NOT_ROUTE_STALLED", {"commodity": "ore", "planet": "Home"}).
## Named get_text because Object already has get(). A missing id logs an error and returns the id.

const PATH := "res://data/story_text.json"

## Russian overrides (every text id since 2026-11-09; same rule as RU_SCOPE_RE in tools/build_story.py). Used only while language is "ru" and the id is in this table.
static var ru_path: String = "res://data/story_text_ru.json"
static var language: String = "en"
static var _ru: Dictionary = {}
static var _ru_loaded: bool = false
static var _texts: Dictionary = {}
static var _places: Dictionary = {}
static var _loaded: bool = false

static func _load() -> void:
	_loaded = true
	_texts = {}
	_places = {}
	if not FileAccess.file_exists(PATH):
		push_error("StoryText: %s is missing. Run tools/build_story.py." % PATH)
		return
	var parsed = entries_of(JSON.parse_string(FileAccess.get_file_as_string(PATH)))
	if parsed.is_empty():
		push_error("StoryText: %s is not a list." % PATH)
		return
	for e in parsed:
		_texts[str(e["id"])] = str(e["text"])
		_places[str(e["id"])] = str(e.get("place", ""))

## The entry list of a generated data file: {"generated": marker, "entries": [...]} (an old plain list is accepted too).
static func entries_of(parsed) -> Array:
	if typeof(parsed) == TYPE_DICTIONARY and typeof(parsed.get("entries")) == TYPE_ARRAY:
		return parsed["entries"]
	return parsed if typeof(parsed) == TYPE_ARRAY else []

## True for ids the Russian table may hold: every text id (same rule as RU_SCOPE_RE in tools/build_story.py: ^[A-Z][A-Z0-9_]{2,}$).
static func in_ru_scope(id: String) -> bool:
	if id.length() < 3 or id[0] < "A" or id[0] > "Z":
		return false
	for i in id.length():
		var ch := id[i]
		if not ((ch >= "A" and ch <= "Z") or (ch >= "0" and ch <= "9") or ch == "_"):
			return false
	return true

static func set_language(code: String) -> void:
	language = code
	if code == "ru":
		_load_ru()

## Re-reads the Russian table (tests point ru_path at a fixture first). Out-of-scope ids in the file are ignored.
static func _load_ru() -> void:
	_ru_loaded = true
	_ru = {}
	if not FileAccess.file_exists(ru_path):
		return
	var parsed = entries_of(JSON.parse_string(FileAccess.get_file_as_string(ru_path)))
	for e in parsed:
		var id := str(e.get("id", ""))
		var t := str(e.get("text", ""))
		if in_ru_scope(id) and t != "":
			_ru[id] = t

## The Russian text to use for id now, or "" (English language, or no Russian text for it).
static func _ru_text(id: String) -> String:
	if language != "ru":
		return ""
	if not _ru_loaded:
		_load_ru()
	return _ru.get(id, "")

static func has_text(id: String) -> bool:
	if not _loaded:
		_load()
	return _texts.has(id)

## T69/T70: text for an id that may not exist yet; falls back to a plain literal without an error.
static func get_or(id: String, fallback: String, args: Dictionary = {}) -> String:
	if has_text(id):
		return get_text(id, args)
	var t := fallback
	for k in args:
		t = t.replace("{%s}" % str(k), str(args[k]))
	return t

static func get_text(id: String, args: Dictionary = {}) -> String:
	if not _loaded:
		_load()
	if not _texts.has(id):
		push_error("StoryText: missing id %s" % id)
		return id
	var t: String = _ru_text(id)
	if t == "":
		t = _texts[id]
	for k in args:
		t = t.replace("{%s}" % str(k), str(args[k]))
	return t

## T77: ending names are only in the "place" field ("Ending: The Cheapest Road"). Returns the name.
static func ending_name(id: String) -> String:
	if not _loaded:
		_load()
	var p: String = _places.get(id, "")
	return p.trim_prefix("Ending: ") if p.begins_with("Ending: ") else id
