extends RefCounted
## Every player decision of a run, for the statistics on the end screen. Two parts, both saved under "decisions" in the main state:
##  counts: kind -> how many times (route_made, route_removed, buy_on, sell_on, order_off, skill_learned, ship_bought, permit_bought,
##          post_built, workshop_built, fabric_built, hub_made, bazaar_founded, wing_chosen, link_built,  event_choice,
##          gig_accepted, gig_choice, upgrade_bought)
##  events: the last MAX_EVENTS decisions as {c: cycle, k: kind, d: short detail}, oldest dropped first (the counts never drop)
## Only the player's own actions are logged (bots and the QA flow call the same functions and are counted too, which is harmless).
## Texts: END_DEC_HEAD and one END_DEC_<KIND> line per kind in story/screens.md ({n}); a kind with 0 is not shown.

const MAX_EVENTS := 600
const KINDS := ["route_made", "route_removed", "buy_on", "sell_on", "order_off", "ship_bought", "skill_learned", "permit_bought", "post_built",
	"workshop_built", "fabric_built", "hub_made", "link_built", "event_choice", "gig_accepted", "gig_choice", "wing_chosen", "bazaar_founded"]

var counts: Dictionary = {}
var events: Array = []

func reset() -> void:
	counts = {}
	events = []

func add(kind: String, cycle: int, detail: String = "") -> void:
	counts[kind] = int(counts.get(kind, 0)) + 1
	events.append({"c": cycle, "k": kind, "d": detail})
	if events.size() > MAX_EVENTS:
		events.pop_front()

func total() -> int:
	var n := 0
	for k in counts:
		n += int(counts[k])
	return n

## Plain data for the end screen: {counts, total, busiest_cycle, busiest_n, first_cycle, last_cycle}.
func summary() -> Dictionary:
	var per := {}
	for e in events:
		per[int(e["c"])] = int(per.get(int(e["c"]), 0)) + 1
	var bc := 0
	var bn := 0
	for c in per:
		if int(per[c]) > bn:
			bn = int(per[c])
			bc = int(c)
	return {"counts": counts.duplicate(), "total": total(), "busiest_cycle": bc, "busiest_n": bn,
		"first_cycle": int(events[0]["c"]) if not events.is_empty() else 0, "last_cycle": int(events[events.size() - 1]["c"]) if not events.is_empty() else 0}

func to_dict() -> Dictionary:
	return {"counts": counts.duplicate(), "events": events.duplicate(true)}

func from_dict(d) -> void:
	reset()
	if typeof(d) != TYPE_DICTIONARY:
		return
	if typeof(d.get("counts")) == TYPE_DICTIONARY:
		for k in d["counts"]:
			counts[str(k)] = maxi(0, int(d["counts"][k]))
	if typeof(d.get("events")) == TYPE_ARRAY:
		for e in d["events"]:
			if typeof(e) == TYPE_DICTIONARY and events.size() < MAX_EVENTS:
				events.append({"c": int(e.get("c", 0)), "k": str(e.get("k", "")), "d": str(e.get("d", ""))})
