class_name Tech
extends RefCounted
## Tech tracker: a tech node (cost 0) is finished by crafting, not bought. Units crafted in a market's workshop count
## toward that market's techs only after the tech's prerequisites are met (no pre-grinding, core 3.1). Goals come from
## balance tech_goal_2 / _4 / _6 (key named by the node). A finished tech joins Skills.learned and queues a notice.
## Static state, one run at a time: Tech.reset() for a new run. Saved by main under "tech".
##
## API: Tech.add_crafted(market, units) -> ids finished now, Tech.progress(id) -> {n, goal, active, done},
## Tech.take_done() -> ids finished since the last call (main posts SK_TECH_DONE for each).

static var counts: Dictionary = {}  # tech id -> units counted so far
static var done_queue: Array = []   # finished tech ids waiting for their notice

static func reset() -> void:
	counts = {}
	done_queue = []

static func _goal(id: String) -> int:
	return SkillTree.tech_goal(Skills._bal(), id)

## True while the tech can count units: not finished and every prerequisite learned or finished.
static func is_active(id: String) -> bool:
	return SkillTree.is_tech(id) and not Skills.is_learned(id) and SkillTree.missing_prereqs(Skills.learned, id).is_empty()

static func progress(id: String) -> Dictionary:
	var goal := _goal(id)
	var done := Skills.is_learned(id)
	return {"n": goal if done else mini(int(counts.get(id, 0)), goal), "goal": goal, "active": is_active(id), "done": done}

## Counts units crafted in `market` toward each active tech of that market. Units that overshoot a goal are lost
## (they never carry to the next tech). Returns the techs finished by this call.
static func add_crafted(market: String, units: int) -> Array:
	var finished := []
	if units <= 0:
		return finished
	var active := []  # decided first, so a tech opened by one finishing now does not take part of this batch
	for id in SkillTree.ids_in(market):
		if is_active(id):
			active.append(id)
	for id in active:
		var n := int(counts.get(id, 0)) + units
		var goal := _goal(id)
		if goal > 0 and n >= goal:
			counts.erase(id)
			Skills.add_learned(id)
			done_queue.append(id)
			finished.append(id)
		else:
			counts[id] = n
	return finished

## Finished techs whose notice has not been posted; empties the queue.
static func take_done() -> Array:
	var out := done_queue.duplicate()
	done_queue.clear()
	return out

static func to_dict() -> Dictionary:
	return {"counts": counts}

static func from_dict(d) -> void:
	counts = {}
	done_queue = []
	if typeof(d) == TYPE_DICTIONARY and typeof(d.get("counts")) == TYPE_DICTIONARY:
		for k in d["counts"].keys():
			if SkillTree.is_tech(str(k)):
				counts[str(k)] = maxi(0, int(d["counts"][k]))
