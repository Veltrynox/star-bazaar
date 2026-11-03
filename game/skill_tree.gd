class_name SkillTree
extends RefCounted
## T71: skill tree rules (gdd-skills.md sections 3, 6). Ids are "A1".."C4"; names and texts come from
## story text (SK_<id>_NAME ...), costs from balance.json skill_cost_<id>. Pure functions, no state.

const StoryText := preload("res://game/story_text.gd")
const EndingPicker := preload("res://game/ending_picker.gd")
const BRANCHES := ["A", "B", "C"]
## Owner feedback 2026-11-02: the first row is Space Storage (A1), Permit Charter (C1) and Prospecting (B1).
## Every other skill is the second row and stays locked until A1 and C1 are both learned (ROW_KEYS).
## B1 is a basic skill (BASIC): permit-first and the second-row lock never apply to it, so mining is reachable
## at cycle 1 with the start point, as the QA runs showed.
const FIRST_ROW := ["A1", "C1", "B1"]
const ROW_KEYS := ["A1", "C1"]
const BASIC := ["B1"]
## Dead-planets spec (design/proposals/2026-11-02-dead-planets.md): M1 Cold Survey, M2 Deep Cut and F1 Fabrication Licence
## sit in the Research branch (B) but keep their own ids. They respect the normal rule (only B1 is exempt).
## EXTRA maps a branch to these ids; EXTRA_PREREQS gives their prerequisites; EXTRA_NAMES is the text until story ids exist.
const EXTRA := {"B": ["M1", "M2", "F1"]}
const EXTRA_PREREQS := {"M1": ["B1"], "M2": ["M1"], "F1": ["M1", "M2"]}
const EXTRA_NAMES := {"M1": "Cold Survey", "M2": "Deep Cut", "F1": "Fabrication Licence"}

static func in_first_row(id: String) -> bool:
	return FIRST_ROW.has(id)

## True when id is a second-row skill and A1 and C1 are not both learned. Needs only the learned list, so
## it also holds for saves (skills already learned stay learned: state() checks that first).
static func first_row_blocks(learned: Array, id: String) -> bool:
	if in_first_row(id):
		return false
	for f in ROW_KEYS:
		if not learned.has(f):
			return true
	return false

static func ids_in(branch: String) -> Array:
	var out: Array = EndingPicker.branch_ids(branch)
	out.append_array(EXTRA.get(branch, []))
	return out

static func all_ids() -> Array:
	var out := []
	for b in BRANCHES:
		out.append_array(ids_in(b))
	return out

## Each node needs the one before it in its branch's id list; C3 also needs A1.
static func prereqs(id: String) -> Array:
	var out := []
	if EXTRA_PREREQS.has(id):
		return EXTRA_PREREQS[id].duplicate()
	var chain := EndingPicker.branch_ids(id.substr(0, 1))
	var at := chain.find(id)
	if id == "C4":  # owner/main decision 2026-10-31: Colonial Rights needs only Survey Beacon, so it is reachable before the second permit
		return ["C2"]
	if at > 0:
		out.append(chain[at - 1])
	if id == "C3":
		out.append("A1")
	return out

static func cost(balance: Dictionary, id: String) -> int:
	return int(balance.get("skill_cost_" + id, 0))

static func missing_prereqs(learned: Array, id: String) -> Array:
	var out := []
	for p in prereqs(id):
		if not learned.has(p):
			out.append(p)
	return out

## A1 gate (owner decision 2026-11-03): A1 Space Storage opens only after two routes are made, on any planet.
## ctx = {"a1_open": bool}; no key means open (pure callers and old tests).
static func gate_open(ctx: Dictionary, id: String) -> bool:
	return id != "A1" or bool(ctx.get("a1_open", true))

## Permit first (owner decision 2026-11-03): until C1 Permit Charter is learned, every other skill is locked.
## ctx = {"c1_learned": bool}; no key means open (pure callers and old tests). Already learned skills stay learned.
static func permit_first_blocks(learned: Array, ctx: Dictionary, id: String) -> bool:
	return id != "C1" and not BASIC.has(id) and not bool(ctx.get("c1_learned", true)) and not learned.has("C1")

## "learned", "available" (prerequisites met) or "locked".
static func state(learned: Array, id: String, ctx: Dictionary = {}) -> String:
	if learned.has(id):
		return "learned"
	if not gate_open(ctx, id):
		return "locked"
	if permit_first_blocks(learned, ctx, id) or first_row_blocks(learned, id):
		return "locked"
	return "available" if missing_prereqs(learned, id).is_empty() else "locked"

static func skill_name(id: String) -> String:
	return StoryText.get_or("SK_%s_NAME" % id, str(EXTRA_NAMES.get(id, id)))

## {ok, reason} where reason is "", "known", "locked" or "points".
static func can_learn(learned: Array, points: int, balance: Dictionary, id: String, ctx: Dictionary = {}) -> Dictionary:
	if not all_ids().has(id):
		return {"ok": false, "reason": "unknown"}
	match state(learned, id, ctx):
		"learned":
			return {"ok": false, "reason": "known"}
		"locked":
			var out := {"ok": false, "reason": "locked"}
			if permit_first_blocks(learned, ctx, id):
				out["why"] = "permit_first"
			elif first_row_blocks(learned, id):
				out["why"] = "first_row"
			return out
	if points < cost(balance, id):
		return {"ok": false, "reason": "points"}
	return {"ok": true, "reason": ""}

## True when at least one skill can be bought right now (drives the mark on the Skills button).
static func any_affordable(learned: Array, points: int, balance: Dictionary, ctx: Dictionary = {}) -> bool:
	for id in all_ids():
		if can_learn(learned, points, balance, id, ctx)["ok"]:
			return true
	return false
