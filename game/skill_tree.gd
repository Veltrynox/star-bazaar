class_name SkillTree
extends RefCounted
## Four market skill trees: the node graph and the pure rules, read from data/skills.json (vocabulary at its top).
## Ids: FND_STORAGE, FND_PERMIT, FND_PROSPECT and <MKT>_1 .. <MKT>_7 (MIL, LUX, MIN, BIO). Costs come from balance
## skill_cost_<id> (balance is authoritative). A tech (kind "tech", cost 0) is never bought: Tech completes it by crafting.
## Text ids: SK_<id>_NAME / _FLAVOUR / _PLAIN, and SK_<id>_CRAFT for a tech.
## State lives in Skills (learned set, effects) and Tech (crafting progress); this file keeps no state.

const StoryText := preload("res://game/story_text.gd")
const PATH := "res://data/skills.json"
## Branch keys in screen order: the Foundations row, then the four markets.
const BRANCHES := ["fnd", "mil", "lux", "min", "bio"]
const MARKETS := ["mil", "lux", "min", "bio"]

## Old A/B/C/M/F ids to the new ones (core 3.5), used to read old saves and systems.json ("requires_skill": "C1").
## C2 and C4 were dropped; C1 and C3 both became FND_PERMIT.
const LEGACY := {"A1": "FND_STORAGE", "A2": "BIO_3", "A4": "MIL_3", "A5": "MIL_1", "B1": "FND_PROSPECT", "B2": "BIO_1", "B3": "LUX_1",
	"B4": "LUX_3", "C1": "FND_PERMIT", "C3": "FND_PERMIT", "M1": "MIN_3", "M2": "MIN_5", "F1": "MIN_1"}
## What each old skill cost, for the points refund of a skill that was dropped or merged (the old balance keys are gone).
const LEGACY_COST := {"A1": 1, "A2": 1, "A4": 3, "A5": 2, "B1": 1, "B2": 2, "B3": 2, "B4": 2, "C1": 1, "C2": 1, "C3": 2, "C4": 2, "M1": 1, "M2": 2, "F1": 2}
## The Foundations row, kept for the old skill screen until the screen is rebuilt.
const FIRST_ROW := ["FND_STORAGE", "FND_PERMIT", "FND_PROSPECT"]

static var _nodes: Array = []
static var _by_id: Dictionary = {}
static var _loaded := false

static func _ensure() -> void:
	if _loaded:
		return
	_loaded = true
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("SkillTree: %s missing or bad." % PATH)
		return
	_nodes = parsed.get("nodes", [])
	for n in _nodes:
		_by_id[str(n["id"])] = n

static func in_first_row(id: String) -> bool:
	return FIRST_ROW.has(id)

## New id for an old one; ids that are already new (or unknown) come back unchanged.
static func legacy_id(id: String) -> String:
	return str(LEGACY.get(id, id))

static func all_ids() -> Array:
	_ensure()
	var out := []
	for n in _nodes:
		out.append(str(n["id"]))
	return out

static func has(id: String) -> bool:
	_ensure()
	return _by_id.has(id)

## Node ids of one branch ("fnd", "mil", "lux", "min", "bio") in file order.
static func ids_in(branch: String) -> Array:
	_ensure()
	var out := []
	for n in _nodes:
		if str(n.get("market", "")) == branch.to_lower():
			out.append(str(n["id"]))
	return out

static func node(id: String) -> Dictionary:
	_ensure()
	return _by_id.get(id, {})

static func market_of(id: String) -> String:
	return str(node(id).get("market", ""))

static func tier(id: String) -> int:
	return int(node(id).get("tier", 1))

static func is_tech(id: String) -> bool:
	return str(node(id).get("kind", "")) == "tech"

static func prereqs(id: String) -> Array:
	var out := []
	for p in node(id).get("prereqs", []):
		out.append(str(p))
	return out

## Primary effect first, then the "extra" effects of the node.
static func effects(id: String) -> Array:
	var n := node(id)
	var out := []
	if typeof(n.get("effect")) == TYPE_DICTIONARY:
		out.append(n["effect"])
	for e in n.get("extra", []):
		out.append(e)
	return out

static func cost(balance: Dictionary, id: String) -> int:
	return int(balance.get("skill_cost_" + id, int(node(id).get("cost", 0))))

## Units a tech needs, from the balance key named by the node (tech_goal_2 / _4 / _6); 0 for a skill.
static func tech_goal(balance: Dictionary, id: String) -> int:
	var k := str(node(id).get("tech_goal_key", ""))
	return int(balance.get(k, 0)) if k != "" else 0

static func missing_prereqs(learned: Array, id: String) -> Array:
	var out := []
	for p in prereqs(id):
		if not learned.has(p):
			out.append(p)
	return out

static func skill_name(id: String) -> String:
	return StoryText.get_or("SK_%s_NAME" % id, id)

static func flavour(id: String) -> String:
	return StoryText.get_or("SK_%s_FLAVOUR" % id, "")

static func plain(id: String) -> String:
	return StoryText.get_or("SK_%s_PLAIN" % id, "")

## Craft line of a tech ("" for a skill).
static func craft_text(id: String) -> String:
	return StoryText.get_or("SK_%s_CRAFT" % id, "") if is_tech(id) else ""

## "learned" (a skill bought or a tech finished), "available" (prerequisites met: a skill can be bought, a tech is being
## researched) or "locked". ctx is kept for old callers and unused.
static func state(learned: Array, id: String, _ctx: Dictionary = {}) -> String:
	if learned.has(id):
		return "learned"
	return "available" if missing_prereqs(learned, id).is_empty() else "locked"

## {ok, reason}: reason is "", "unknown", "known", "locked", "tech" (techs finish by crafting) or "points".
static func can_learn(learned: Array, points: int, balance: Dictionary, id: String, ctx: Dictionary = {}) -> Dictionary:
	if not has(id):
		return {"ok": false, "reason": "unknown"}
	match state(learned, id, ctx):
		"learned":
			return {"ok": false, "reason": "known"}
		"locked":
			return {"ok": false, "reason": "locked"}
	if is_tech(id):
		return {"ok": false, "reason": "tech"}
	if points < cost(balance, id):
		return {"ok": false, "reason": "points"}
	return {"ok": true, "reason": ""}

## True when at least one skill can be bought right now (drives the mark on the Skills button).
static func any_affordable(learned: Array, points: int, balance: Dictionary, ctx: Dictionary = {}) -> bool:
	for id in all_ids():
		if can_learn(learned, points, balance, id, ctx)["ok"]:
			return true
	return false
