extends RefCounted
## T26: single automatic save file. JSON, versioned, tuning values never stored.
##
## Layout: {"version": int, "state": {...}}. To add future state (ships, routes,
## permits, events): put a new key in the dict built by main.gd
## collect_state(), read it with a default in apply_state(). Missing keys fall back
## to defaults, so old saves keep loading. Bump VERSION and add a step to
## _migrate() only when an existing key changes meaning or shape.

const PATH := "user://autosave.json"
const VERSION := 1

## Set by the main menu; read once by main.gd on start.
static var continue_requested: bool = false

static func exists() -> bool:
	return not load_state().is_empty()

## Returns the saved state dictionary, or {} if there is no usable save.
static func load_state() -> Dictionary:
	if not FileAccess.file_exists(PATH):
		return {}
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("version") or typeof(parsed.get("state")) != TYPE_DICTIONARY:
		return {}
	var version := int(parsed["version"])
	if version > VERSION:
		return {}  # written by a newer build; ignore rather than misread
	return _migrate(parsed["state"], version)

static func write_state(state: Dictionary) -> bool:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		push_warning("Cannot write save " + PATH)
		return false
	f.store_string(JSON.stringify({"version": VERSION, "state": state}))
	return true

## Used on win/loss so Continue never resumes a finished game.
static func clear() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))

static func _migrate(state: Dictionary, _from_version: int) -> Dictionary:
	# No migrations yet. Add: if _from_version < 2: ... when VERSION is bumped.
	return state
