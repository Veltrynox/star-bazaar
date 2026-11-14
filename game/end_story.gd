extends RefCounted
## The chronicle on the end screen (owner 2026-11-13): the run told as a story instead of a list of counters.
## paragraphs(side, stats) returns the paragraphs in order; each is one string of full sentences. A topic with nothing to say is left out.
## Input (all optional): stats.recap (Bazaar.recap() + site_name), stats.decisions (DecisionLog.summary()), stats.notes
## ({peak_ships, repossessions, gigs_done, gigs_expired, restless_cycles}), stats.cycle. Texts: END_STORY_* and EPI_WING_* in story/endings.md.
## A count of 1 uses the _ONE text, more the _MANY text with {n}. No number is ever written here: they all go through placeholders.

const StoryText := preload("res://game/story_text.gd")

## "<base>_ONE" for 1, "<base>_MANY" ({n}) for more, "" for 0 or a missing text.
static func counted(base: String, n: int) -> String:
	if n <= 0:
		return ""
	var id := base + ("_ONE" if n == 1 else "_MANY")
	return StoryText.get_text(id, {"n": n}) if StoryText.has_text(id) else ""

static func _join(parts: Array) -> String:
	var out: Array = []
	for p in parts:
		if str(p) != "":
			out.append(str(p))
	return " ".join(out)

## True when the ending has a scene kit (<ID>_OPEN text): the kit then replaces the old ending body, its epilogue and the generic chronicle.
static func has_kit(ending_id: String) -> bool:
	return ending_id != "" and StoryText.has_text(ending_id + "_OPEN")

## "A", "A and B", "A, B and C" from world names.
static func name_list(names: Array) -> String:
	var n := names.size()
	if n == 0:
		return ""
	if n == 1:
		return str(names[0])
	return "%s %s %s" % [", ".join(names.slice(0, n - 1)), StoryText.get_or("END_KIT_AND", "and"), str(names[n - 1])]

## Scene kit (owner 2026-11-13): <ID>_OPEN, the beats of the run in the CEO's voice (ENDB_<MKT>_*, only those with a non-zero count),
## then on a win the lean line, then <ID>_CLOSE. Placeholders: {company} {ceo} {system} {m} {n} {cycles} {names} {ship}.
static func kit_paragraphs(side: String, stats: Dictionary) -> Array:
	var id := str(stats.get("ending_id", ""))
	var mk := str(stats.get("market", "")).to_upper()
	var rc: Dictionary = stats.get("recap", {})
	var dc: Dictionary = stats.get("decisions", {}).get("counts", {})
	var nt: Dictionary = stats.get("notes", {})
	var base := {"company": str(stats.get("company", "")), "ceo": str(stats.get("ceo", "")), "cycles": int(stats.get("cycle", 0)), "m": int(rc.get("stages_total", 0)), "ship": str(stats.get("ship", "")),
		"system": str(rc.get("site_name", "")), "n": int(rc.get("stages", 0))}
	var out: Array = []
	out.append(StoryText.get_or(id + "_OPEN", "", base))
	var b := "ENDB_%s_" % mk
	var add := func(key: String, args: Dictionary = {}) -> void:
		var a := base.duplicate()
		a.merge(args, true)
		if StoryText.has_text(b + key):
			out.append(StoryText.get_text(b + key, a))
	var counted_beat := func(key: String, n: int, args: Dictionary = {}) -> void:
		if n <= 0:
			return
		var a := args.duplicate()
		a["n"] = n
		add.call(key + ("_ONE" if n == 1 else "_MANY"), a)
	# the Bazaar
	var site := int(rc.get("site", -1))
	if site < 0:
		add.call("BAZAAR_NEVER")
	elif side == "WIN":
		add.call("BAZAAR_WIN")
	else:
		add.call("BAZAAR_PART" if int(rc.get("stages", 0)) > 0 else "BAZAAR_BARE")
	for w in rc.get("wings", []):
		add.call("WING_" + str(w).trim_prefix("WING_"))
	# the worlds, small to large
	var per: Dictionary = rc.get("worlds_per_tier", {})
	var names: Dictionary = rc.get("worlds_names", {})
	var tiers := per.keys()
	tiers.sort_custom(func(x, y): return int(x) < int(y))
	for t in tiers:
		counted_beat.call("TIER_%d" % int(t), int(per[t]), {"names": name_list(names.get(t, []))})
	if tiers.is_empty():
		add.call("WORLDS_NONE")
	var rn: Array = rc.get("reclaimed_names", [])
	counted_beat.call("RECLAIMED", rn.size(), {"names": name_list(rn)})
	# the company
	counted_beat.call("POSTS", int(dc.get("post_built", 0)))
	if int(stats.get("systems", 1)) >= 2:
		add.call("SYSTEMS_MANY", {"n": int(stats.get("systems", 1))})
	counted_beat.call("FLEET", int(nt.get("peak_ships", 0)))
	var routes := int(dc.get("route_made", 0))
	counted_beat.call("ROUTES", routes)
	if routes > 0:
		counted_beat.call("ROUTES_CLOSED", mini(routes, int(dc.get("route_removed", 0))))
	counted_beat.call("SKILLS", int(dc.get("skill_learned", 0)))
	counted_beat.call("WORKS", int(dc.get("workshop_built", 0)) + int(dc.get("fabric_built", 0)) + int(dc.get("hub_made", 0)))
	var gigs := int(nt.get("gigs_done", 0))
	counted_beat.call("GIGS", gigs)
	if gigs > 0:
		counted_beat.call("GIGS_LOST", int(nt.get("gigs_expired", 0)))
	counted_beat.call("RESTLESS", int(nt.get("restless_cycles", 0)))
	counted_beat.call("RESCUES", int(stats.get("rescues", 0)))
	counted_beat.call("REPO", int(nt.get("repossessions", 0)))
	# decisive moments
	var moments: Array = []
	for m in rc.get("decisive", []):
		var mid := str(m.get("id", ""))
		var txt := StoryText.get_or("END_MOMENT_" + mid, StoryText.get_or(mid + "_TITLE", ""))
		if txt != "":
			moments.append(StoryText.get_or("END_STORY_MOMENT", "", {"cycle": int(m.get("cycle", 0)), "moment": txt.trim_suffix(".")}))
	if not moments.is_empty() and StoryText.has_text(b + "MOMENTS_LEAD"):
		out.append(_join([StoryText.get_text(b + "MOMENTS_LEAD", base)] + moments))
	if side == "WIN":
		add.call("LEAN_" + str(stats.get("flavour", {}).get("flag", "good")).to_upper())
	out.append(StoryText.get_or(id + "_CLOSE", "", base))
	return out.filter(func(x): return str(x) != "")

static func paragraphs(side: String, stats: Dictionary) -> Array:
	if has_kit(str(stats.get("ending_id", ""))):
		return kit_paragraphs(side, stats)
	var out: Array = []
	for p in [_bazaar(side, stats), _wings(stats), _worlds(stats), _company(stats), _moments(stats), _close(stats)]:
		if str(p) != "":
			out.append(p)
	return out

## The Bazaar: opened, part built, founded only, or never founded.
static func _bazaar(side: String, stats: Dictionary) -> String:
	var rc: Dictionary = stats.get("recap", {})
	var site := int(rc.get("site", -1))
	if site < 0:
		return StoryText.get_or("END_STORY_BAZAAR_NEVER", "")
	var args := {"system": str(rc.get("site_name", "#%d" % site)), "n": int(rc.get("stages", 0)), "m": int(rc.get("stages_total", 0)), "cycles": int(stats.get("cycle", 0))}
	if side == "WIN":
		return StoryText.get_or("END_STORY_BAZAAR_WIN", "", args)
	return StoryText.get_or("END_STORY_BAZAAR_PART" if int(args["n"]) > 0 else "END_STORY_BAZAAR_BARE", "", args)

## One line per wing (EPI_WING_<id>): what the wing is, in the story's words, after one lead sentence.
static func _wings(stats: Dictionary) -> String:
	var lines: Array = []
	for w in stats.get("recap", {}).get("wings", []):
		var id := "EPI_" + str(w)
		if StoryText.has_text(id):
			lines.append(StoryText.get_text(id))
	if lines.is_empty():
		return ""
	return _join([StoryText.get_or("END_STORY_WINGS_LEAD", "")] + lines)

## Worlds grown, small to large, then the dead worlds brought back.
static func _worlds(stats: Dictionary) -> String:
	var rc: Dictionary = stats.get("recap", {})
	if rc.is_empty():
		return ""
	var per: Dictionary = rc.get("worlds_per_tier", {})
	var tiers := per.keys()
	tiers.sort_custom(func(a, b): return int(a) < int(b))
	var lines: Array = []
	for t in tiers:
		lines.append(counted("END_STORY_TIER_%d" % int(t), int(per[t])))
	lines.append(counted("END_STORY_RECLAIMED", (rc.get("reclaimed", []) as Array).size()))
	if _join(lines) == "":
		return StoryText.get_or("END_STORY_WORLDS_NONE", "")
	return _join([StoryText.get_or("END_STORY_WORLDS_LEAD", "")] + lines)

## What the company did: routes, fleet, posts, permits, skills, workshops and hubs, signals, hungry cycles, choices.
static func _company(stats: Dictionary) -> String:
	var c: Dictionary = stats.get("decisions", {}).get("counts", {})
	var nt: Dictionary = stats.get("notes", {})
	var routes := int(c.get("route_made", 0))
	var lines: Array = [counted("END_STORY_ROUTES", routes)]
	if routes > 0:
		lines.append(counted("END_STORY_ROUTES_CLOSED", mini(routes, int(c.get("route_removed", 0)))))
	lines.append(counted("END_STORY_FLEET", int(nt.get("peak_ships", 0))))
	lines.append(counted("END_STORY_REPO", int(nt.get("repossessions", 0))))
	lines.append(counted("END_STORY_POSTS", int(c.get("post_built", 0))))
	lines.append(counted("END_STORY_PERMITS", int(c.get("permit_bought", 0))))
	lines.append(counted("END_STORY_SKILLS", int(c.get("skill_learned", 0))))
	lines.append(counted("END_STORY_WORKS", int(c.get("workshop_built", 0)) + int(c.get("fabric_built", 0)) + int(c.get("hub_made", 0))))
	var gigs := int(nt.get("gigs_done", 0))
	lines.append(counted("END_STORY_GIGS", gigs))
	if gigs > 0:
		lines.append(counted("END_STORY_GIGS_LOST", int(nt.get("gigs_expired", 0))))
	lines.append(counted("END_STORY_RESTLESS", int(nt.get("restless_cycles", 0))))
	lines.append(counted("END_STORY_CHOICES", int(c.get("event_choice", 0)) + int(c.get("gig_choice", 0))))
	return _join(lines)

## The (up to three) decisive moments, each named by its story title.
static func _moments(stats: Dictionary) -> String:
	var lines: Array = []
	for m in stats.get("recap", {}).get("decisive", []):
		var id := str(m.get("id", ""))
		var txt := StoryText.get_or("END_MOMENT_" + id, StoryText.get_or(id + "_TITLE", ""))
		if txt != "":
			lines.append(StoryText.get_or("END_STORY_MOMENT", "", {"cycle": int(m.get("cycle", 0)), "moment": txt.trim_suffix(".")}))
	if lines.is_empty():
		return ""
	return _join([StoryText.get_or("END_STORY_MOMENTS_LEAD", "")] + lines)

## The closing lines: how many decisions, and the cycle that held the most.
static func _close(stats: Dictionary) -> String:
	var d: Dictionary = stats.get("decisions", {})
	var total := int(d.get("total", 0))
	if total <= 1:
		return ""
	var lines: Array = [StoryText.get_or("END_STORY_TOTAL", "", {"n": total})]
	if int(d.get("busiest_n", 0)) > 1 and int(d.get("busiest_n", 0)) < total:
		lines.append(StoryText.get_or("END_STORY_BUSIEST", "", {"cycle": int(d.get("busiest_cycle", 0)), "n": int(d.get("busiest_n", 0))}))
	return _join(lines)
