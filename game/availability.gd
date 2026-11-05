class_name Availability
extends RefCounted
## The one place that decides what the UI may show: goods, workshops, storage features (data/availability.json).
## Hidden means not rendered at all. Call Availability.good(id), .workshop(id), .storage(id), .feature(id) or
## is_visible(kind, id). Rules are evaluated against the live game (Main) every call, so a newly true rule shows at once.
##
## Conditions (atoms and all/any/not trees) are evaluated by game/conditions.gd; its header lists the vocabulary.
## Balance keys are read from data/balance.json (Main.balance, loaded from that file). Without a bound game
## (standalone modules, tools) every item counts as visible.

const PATH := "res://data/availability.json"

static var _rules: Dictionary = {}        # "kind|id" -> visible_when
static var _data: Dictionary = {}
static var _loaded := false

static func bind(main_node: Object) -> void:
	Conditions.game = main_node

static func load_data() -> void:
	_loaded = true
	_rules = {}
	_data = {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Availability: %s missing or bad." % PATH)
		return
	_data = parsed
	for r in parsed.get("rules", []):
		_rules["%s|%s" % [str(r.get("kind", "")), str(r.get("id", ""))]] = r.get("visible_when")

static func _ensure() -> void:
	if not _loaded:
		load_data()

static func data() -> Dictionary:
	_ensure()
	return _data

static func has_rule(kind: String, id: String) -> bool:
	_ensure()
	return _rules.has("%s|%s" % [kind, id])

static func rule(kind: String, id: String):
	_ensure()
	return _rules.get("%s|%s" % [kind, id])

static func _live() -> bool:
	return Conditions.live()

## True when the item may be shown now. An item without a rule is shown (the data lint test names it).
static func is_visible(kind: String, id: String) -> bool:
	_ensure()
	if not _live() or not _rules.has("%s|%s" % [kind, id]):
		return true
	return eval(_rules["%s|%s" % [kind, id]], 0)

static func good(id: String) -> bool:
	return is_visible("good", id)

static func workshop(id: String) -> bool:
	return is_visible("workshop", id)

static func storage(id: String) -> bool:
	return is_visible("storage", id)

static func feature(id: String) -> bool:
	return is_visible("feature", id)

## Goods of `ids` that may be shown, order kept.
static func visible_goods(ids: Array) -> Array:
	var out: Array = []
	for c in ids:
		if good(str(c)):
			out.append(c)
	return out

## Every good id in data/goods.json that may be shown now.
static func all_visible_goods() -> Array:
	return visible_goods(Goods.ids())

## True when the text names a good that may not be shown yet (id or display name, whole word). For tests and notices.
static func names_hidden_good(text: String) -> String:
	var low := text.to_lower()
	for id in Goods.ids():
		if good(id):
			continue
		for needle in [id, Ui.good_name(id).to_lower()]:
			if needle == "" or not low.contains(needle):
				continue
			var at := low.find(needle)
			while at >= 0:
				var before := low[at - 1] if at > 0 else " "
				var after := low[at + needle.length()] if at + needle.length() < low.length() else " "
				if not _is_word(before) and not _is_word(after):
					return id
				at = low.find(needle, at + 1)
	return ""

static func _is_word(ch: String) -> bool:
	return ch >= "a" and ch <= "z" or ch >= "0" and ch <= "9" or ch == "_"

## Evaluates one condition tree (see Conditions).
static func eval(cond, _depth: int = 0) -> bool:
	return Conditions.eval(cond)

static func split_atom(atom: String) -> Array:
	return Conditions.split_atom(atom)

## Problems in data/availability.json against the other data files: [] when clean. Each entry names the offending id.
static func lint() -> Array:
	_ensure()
	var errs: Array = []
	var bal := Conditions.read_balance()
	var evs := Conditions.event_ids()
	var seen := {}
	for r in _data.get("rules", []):
		var kind := str(r.get("kind", ""))
		var id := str(r.get("id", ""))
		var k := "%s|%s" % [kind, id]
		if seen.has(k):
			errs.append("duplicate rule %s" % k)
		seen[k] = true
		match kind:
			"good":
				if not Goods.has(id):
					errs.append("rule for unknown good '%s'" % id)
			"workshop":
				if Goods.workshop(id).is_empty():
					errs.append("rule for unknown workshop '%s'" % id)
			"storage", "feature":
				pass
			_:
				errs.append("rule %s has unknown kind '%s'" % [id, kind])
		Conditions.lint(r.get("visible_when"), "availability %s rule '%s'" % [kind, id], errs, false, bal, evs)
	for g in Goods.ids():
		if not seen.has("good|" + g):
			errs.append("good '%s' has no availability rule" % g)
	for w in Goods.workshops:
		if not seen.has("workshop|" + str(w["id"])):
			errs.append("workshop '%s' has no availability rule" % str(w["id"]))
	for s in ["planet_storage", "space_storage"]:
		if not seen.has("storage|" + s):
			errs.append("storage feature '%s' has no availability rule" % s)
	var start: Dictionary = _data.get("start_state", {})
	for g in start.get("visible_goods", []) + start.get("hidden_goods", []):
		if not Goods.has(str(g)):
			errs.append("start_state names unknown good '%s'" % str(g))
	return errs
