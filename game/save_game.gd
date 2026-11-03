extends RefCounted
## T26: single automatic save file. JSON, versioned, tuning values never stored.
##
## Layout: {"version": int, "state": {...}}. To add future state (ships, routes,
## permits, events): put a new key in the dict built by main.gd
## collect_state(), read it with a default in apply_state(). Missing keys fall back
## to defaults, so old saves keep loading. Bump VERSION and add a step to
## _migrate() only when an existing key changes meaning or shape.

const StoryText := preload("res://game/story_text.gd")
const PATH := "user://autosave.json"
## Version 2 = Four Markets (market volumes, bot state, counters). Version 3 = the four market skill trees: a v2 save is
## migrated (old skill ids mapped, points refunded). Version 4 = market event chains (chains, rival log, timed effects); a v3 save has
## none of that and starts with fresh chain state; the old shield state is dropped. Version 1 saves are dropped, not migrated (owner approved).
const VERSION := 4
const MIN_VERSION := 2

## True after load_state() found a save older than MIN_VERSION; the menu shows old_save_message().
static var dropped_old: bool = false

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
	if version < MIN_VERSION:
		dropped_old = true  # written before Four Markets: the goal changed, so the run cannot continue
		return {}
	dropped_old = false
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

## Plain message for the main menu when an old save was dropped. TODO story: id NOT_OLD_SAVE not in the story files yet.
static func old_save_message() -> String:
	return StoryText.get_or("NOT_OLD_SAVE", "Your old save is from before Four Markets and cannot continue. Start a new game.")

## Old (v2) skill ids to the new ones. The only place old ids live. C2 and C4 were dropped; C1 and C3 both became FND_PERMIT.
const LEGACY := {"A1": "FND_STORAGE", "A2": "BIO_3", "A4": "MIL_3", "A5": "MIL_1", "B1": "FND_PROSPECT", "B2": "BIO_1", "B3": "LUX_1",
	"B4": "LUX_3", "C1": "FND_PERMIT", "C3": "FND_PERMIT", "M1": "MIN_3", "M2": "MIN_5", "F1": "MIN_1"}
## What each old skill cost, for the refund of one that was dropped or merged.
const LEGACY_COST := {"A1": 1, "A2": 1, "A4": 3, "A5": 2, "B1": 1, "B2": 2, "B3": 2, "B4": 2, "C1": 1, "C2": 1, "C3": 2, "C4": 2, "M1": 1, "M2": 2, "F1": 2}

static func _migrate(state: Dictionary, from_version: int) -> Dictionary:
	var st := state
	if from_version < 3:
		st = migrate_v2(st)
	if from_version < 4:
		st = migrate_v3(st)
	return st

## v3 -> v4: no chain state (fresh chains), the solar shield is gone. Everything else stays.
static func migrate_v3(state: Dictionary) -> Dictionary:
	var out: Dictionary = state.duplicate(true)
	out.erase("chains")
	out.erase("shield")
	return out

## v2 -> v3: cash, cycle, ships, markets and bot state stay as they are. Learned old skills map to the new ids (LEGACY);
## a skill that was dropped (C2, C4), merged into one already held (C3 with C1) or unknown gives its old cost back as points.
static func migrate_v2(state: Dictionary) -> Dictionary:
	var out: Dictionary = state.duplicate(true)
	var learned := []
	var refund := 0
	var old = out.get("learned_skills", [])
	if typeof(old) == TYPE_ARRAY:
		for id in old:
			var to := str(LEGACY.get(str(id), ""))
			if to == "" or learned.has(to):
				refund += int(LEGACY_COST.get(str(id), 0))
			else:
				learned.append(to)
	out["learned_skills"] = learned
	out["skill_points"] = maxi(0, int(out.get("skill_points", 0))) + refund
	out.erase("surveyed")
	return out
