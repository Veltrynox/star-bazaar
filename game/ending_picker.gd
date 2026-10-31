extends RefCounted
## T77: picks the ending id from story/endings.md selection tables (first match wins).
## Pure functions, no state, no files. Branch letters: A = Logistics (L), B = Research (R), C = Expansion (E).
## Inputs (Dictionary):
##   learned: Array of skill ids ("A1", "B4", ...)
##   systems_reached: int (systems with a first route or storage; system 1 counts)
##   all_systems_reached: bool (every open system reached; false while only system 1 exists)
##   last_cycle: bool (goal reached on the last cycle of the window; Release only)
## Branch sizes are counted from the SK_<id>_NAME story ids, so no number is hard-coded.

const StoryText := preload("res://game/story_text.gd")
const BRANCHES := ["A", "B", "C"]
const SUFFIX := {"A": "L", "B": "R", "C": "E"}

## Skill ids of one branch that have a story name, in numeric order. Ids can have gaps
## (A3 was cut, so Logistics is A1, A2, A4, A5), so this counts real ids, not a running number.
static func branch_ids(b: String) -> Array:
	var out := []
	for n in range(1, 10):
		var id := "%s%d" % [b, n]
		if StoryText.has_text("SK_%s_NAME" % id):
			out.append(id)
	return out

static func branch_size(b: String) -> int:
	return branch_ids(b).size()

static func counts(learned: Array) -> Dictionary:
	var c := {"A": 0, "B": 0, "C": 0}
	for id in learned:
		var b := str(id).substr(0, 1)
		if c.has(b):
			c[b] += 1
	return c

## Branch letter with the strictly largest count, "" if tied or all zero.
static func dominant(learned: Array) -> String:
	var c := counts(learned)
	var best := ""
	var best_n := 0
	var tie := false
	for b in BRANCHES:
		if c[b] > best_n:
			best = b
			best_n = c[b]
			tie = false
		elif c[b] == best_n and best_n > 0:
			tie = true
	return "" if tie else best

static func fully_learned(learned: Array) -> Array:
	var c := counts(learned)
	var out := []
	for b in BRANCHES:
		var size := branch_size(b)
		if size > 0 and c[b] >= size:
			out.append(b)
	return out

static func is_bare(inp: Dictionary) -> bool:
	if int(inp.get("systems_reached", 1)) > 1:
		return false
	for id in inp.get("learned", []):
		if str(id) != "A1":
			return false
	return true

static func is_full(inp: Dictionary) -> bool:
	return bool(inp.get("all_systems_reached", false)) and not fully_learned(inp.get("learned", [])).is_empty()

## Tier for the stats record: "Bare", "Full" or "Partial" (win endings only).
static func tier(inp: Dictionary) -> String:
	if is_bare(inp):
		return "Bare"
	return "Full" if is_full(inp) else "Partial"

static func pick_release(inp: Dictionary) -> String:
	var learned: Array = inp.get("learned", [])
	if is_bare(inp):
		return "END_BARE_HANDS"
	if is_full(inp):
		var full := fully_learned(learned)
		return "END_REL_FULL_X" if full.size() >= 2 else "END_REL_FULL_" + SUFFIX[full[0]]
	if bool(inp.get("last_cycle", false)):
		return "END_LAST_LIGHT"
	var dom := dominant(learned)
	if dom == "B" and learned.has("B4"):
		return "END_COLD_LEDGER"
	if dom == "C":
		return "END_OWN_HORIZON"
	if dom == "A":
		return "END_SLOW_HARBOR"
	return "END_ENOUGH"

static func pick_corp(inp: Dictionary) -> String:
	var learned: Array = inp.get("learned", [])
	if is_bare(inp):
		return "END_CORP_BARE"
	if is_full(inp):
		var full := fully_learned(learned)
		return "END_CORP_FULL_X" if full.size() >= 2 else "END_CORP_FULL_" + SUFFIX[full[0]]
	match dominant(learned):
		"A":
			return "END_CORP_LOGI"
		"B":
			return "END_CORP_RES"
		"C":
			return "END_CORP_EXP"
	return "END_CORP_MIX"
