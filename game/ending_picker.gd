extends RefCounted
## Skill branch helpers (A = Logistics, B = Research, C = Expansion), used by skill_tree.gd until the skill-tree rewrite.
## The old Release/Corporation ending picker was removed with the cash goal (Four Markets); endings come from main.gd.
## Branch sizes are counted from the SK_<id>_NAME story ids, so no number is hard-coded.

const StoryText := preload("res://game/story_text.gd")
const BRANCHES := ["A", "B", "C"]

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
