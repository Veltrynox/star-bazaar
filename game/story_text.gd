extends RefCounted
## T76: story texts from data/story_text.json (built by tools/build_story.py from story/*.md).
## Use: StoryText.get_text("NOT_SAVED") or StoryText.get_text("LBL_GOAL", {"goal": 9000}).
## Named get_text because Object already has get(). A missing id logs an error and returns the id.

const PATH := "res://data/story_text.json"

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
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if typeof(parsed) != TYPE_ARRAY:
		push_error("StoryText: %s is not a list." % PATH)
		return
	for e in parsed:
		_texts[str(e["id"])] = str(e["text"])
		_places[str(e["id"])] = str(e.get("place", ""))

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
	var t: String = _texts[id]
	for k in args:
		t = t.replace("{%s}" % str(k), str(args[k]))
	return t

## T77: ending names are only in the "place" field ("Ending: The Cheapest Road"). Returns the name.
static func ending_name(id: String) -> String:
	if not _loaded:
		_load()
	var p: String = _places.get(id, "")
	return p.trim_prefix("Ending: ") if p.begins_with("Ending: ") else id
