class_name Conditions
extends RefCounted
## The ONE condition evaluator. Chain triggers (data/chains.json), availability rules (data/availability.json), workshop
## unlocks (data/goods.json) and event filters (game/events.gd) all use these trees and this atom vocabulary.
##
## Tree: an atom string "name" or "name:arg"; {"all": [...]} (every one true); {"any": [...]} (one true); {"not": cond}.
## Anything else is false. An entry (event, chain step, option, rule) hides itself with an optional "visible_when": <tree>;
## use Conditions.visible(entry, ctx). No visible_when = visible.
##
## Atom vocabulary (arg kinds: node = id in data/skills.json, workshop = id in data/goods.json, good = id in data/goods.json,
## system = system number, balance = "balance.<key>" naming a key of data/balance.json, event = event id or chain step id):
##   start                                  always true
##   skill_learned:<node>                   node is learned (skill or tech node; the old name tech_done is gone)
##   workshop_built:<workshop>              the player built that workshop (fabric|smelter|munitions|atelier|culture_lab)
##   system_open:<n>                        system n permit is bought
##   cycle_at_least:<balance>               the cycle is >= the balance value
##   stock_held:<good>                      the player holds that good in a ship, planet storage or space storage
##   good_visible:<good>                    that good's own availability rule is true
##   good_traded:<good>                     an open planet prices that good (needs ctx.planets; events use it)
##   event_fired:<event>                    that event or chain step already fired this run (saved: Events.feed / Chains.picks)
## Atoms that need a chain step in the context (ctx.step), the market and previous step come from it:
##   share_pct:<balance>                    the step's market share in percent has reached the value
##   first_sale_after_cycle:<balance>       a non-common-raw good of the step's market sold in a cycle after that
##   cycles_after_prev_step:<balance>       n cycles passed since the previous step of the SAME chain fired
## Context ctx (all optional): step (chain step id), cycle, balance (Dictionary; default the live game's), planets (Array).
## Without a bound game, game-state atoms are false (availability treats every item as visible then).

const BALANCE_PATH := "res://data/balance.json"

## name -> arg kind ("" no arg). "step" atoms need ctx.step.
const ATOMS := {
	"start": "", "skill_learned": "node", "workshop_built": "workshop", "system_open": "system", "cycle_at_least": "balance",
	"stock_held": "good", "good_visible": "good", "good_traded": "good", "event_fired": "event",
	"share_pct": "balance", "first_sale_after_cycle": "balance", "cycles_after_prev_step": "balance",
}
const STEP_ATOMS := ["share_pct", "first_sale_after_cycle", "cycles_after_prev_step"]

static var game: Object = null            # the running Main; bound by Availability.bind from Main._ready

static func live() -> bool:
	return game != null and is_instance_valid(game)

## True when the entry has no "visible_when" or it holds.
static func visible(entry, ctx: Dictionary = {}) -> bool:
	if typeof(entry) != TYPE_DICTIONARY or not entry.has("visible_when"):
		return true
	return eval(entry["visible_when"], ctx)

static func eval(cond, ctx: Dictionary = {}, depth: int = 0) -> bool:
	if depth > 12:
		return false
	if typeof(cond) == TYPE_STRING:
		return _atom(str(cond), ctx)
	if typeof(cond) == TYPE_DICTIONARY:
		if cond.has("all"):
			for c in cond["all"]:
				if not eval(c, ctx, depth + 1):
					return false
			return true
		if cond.has("any"):
			for c in cond["any"]:
				if eval(c, ctx, depth + 1):
					return true
			return false
		if cond.has("not"):
			return not eval(cond["not"], ctx, depth + 1)
	return false

static func split_atom(atom: String) -> Array:
	var i := atom.find(":")
	if i < 0:
		return [atom, ""]
	return [atom.substr(0, i), atom.substr(i + 1)]

static func _atom(atom: String, ctx: Dictionary) -> bool:
	var parts := split_atom(atom)
	var arg := str(parts[1])
	match str(parts[0]):
		"start":
			return true
		"skill_learned":
			return Skills.is_learned(arg)
		"event_fired":
			return event_fired(arg)
		"good_visible":
			return Availability.is_visible("good", arg)
		"good_traded":
			return good_traded(arg, ctx.get("planets", []))
		"share_pct":
			var m := _market(ctx)
			return m != "" and Markets.share(m) * 100.0 >= balance_value(arg, ctx)
		"first_sale_after_cycle":
			var m2 := _market(ctx)
			var after := int(balance_value(arg, ctx))
			var arr: Array = Markets.vp_active.get(m2, [])
			for i in arr.size():
				if i + 1 > after and float(arr[i]) > 0.0:
					return true
			return false
		"cycles_after_prev_step":
			var p := Chains.prev_id(str(ctx.get("step", "")))
			return p != "" and Chains.picks.has(p) and int(ctx.get("cycle", 0)) - int(Chains.picks[p]["cycle"]) >= int(balance_value(arg, ctx))
		"cycle_at_least":
			if not ctx.has("cycle") and not live():
				return false
			return int(ctx.get("cycle", game.cycle if live() else 0)) >= int(balance_value(arg, ctx))
		"workshop_built", "system_open", "stock_held":
			return live() and _game_atom(str(parts[0]), arg)
	push_error("Conditions: unknown atom '%s'" % atom)
	return false

static func _game_atom(name: String, arg: String) -> bool:
	match name:
		"workshop_built":
			if arg == "fabric":
				return game.fabric != null and bool(game.fabric.built)
			return game.workshops != null and bool(game.workshops.built.get(arg, false))
		"system_open":
			return game.open_systems.has(int(arg))
		"stock_held":
			return stock_held(arg)
	return false

static func _market(ctx: Dictionary) -> String:
	return Chains.market_of(str(ctx.get("step", "")))

## The player holds the good in any container: planet storage or space storage.
static func stock_held(c: String) -> bool:
	if not live() or game.storage == null:
		return false
	var st = game.storage
	for key in st.stock.keys():
		if int(st.stock[key].get(c, 0)) > 0:
			return true
	return false

## An open planet (of `planets`) prices the good: base_prices has <good>_buy or <good>_sell.
static func good_traded(c: String, planets: Array) -> bool:
	for p in planets:
		if typeof(p) == TYPE_DICTIONARY and typeof(p.get("base_prices")) == TYPE_DICTIONARY:
			if p["base_prices"].has(c + "_buy") or p["base_prices"].has(c + "_sell"):
				return true
	return false

## The event or chain step fired this run. Events.feed (saved) records every fired event and chain step; Chains.picks every answered step.
static func event_fired(id: String) -> bool:
	if Chains.fired(id):
		return true
	return live() and game.events != null and game.events.has_fired(id)

## "balance.<key>" (or a bare key) from ctx.balance, else the live game's balance (data/balance.json). Missing = 0.
static func balance_value(arg: String, ctx: Dictionary = {}) -> float:
	var key := arg.trim_prefix("balance.")
	var bal: Dictionary = ctx["balance"] if ctx.has("balance") else (game.balance if live() else {})
	return float(bal.get(key, 0))

# ---- lint: problems of a tree against the other data files; each entry names the context and the offending id ----

## Appends to errs. `step_ok` true where the atoms that need a chain step are allowed (chain triggers, step visible_when).
## `events` = ids of every event and chain step (see event_ids()).
static func lint(cond, where: String, errs: Array, step_ok: bool = false, bal: Dictionary = {}, events: Array = []) -> void:
	if bal.is_empty():
		bal = read_balance()
	if typeof(cond) == TYPE_STRING:
		var parts := split_atom(str(cond))
		var name := str(parts[0])
		var arg := str(parts[1])
		if not ATOMS.has(name):
			errs.append("%s: unknown atom '%s'" % [where, cond])
			return
		if STEP_ATOMS.has(name) and not step_ok:
			errs.append("%s: atom '%s' needs a chain step" % [where, cond])
		var kind := str(ATOMS[name])
		if kind == "" and arg != "":
			errs.append("%s: atom '%s' takes no argument" % [where, name])
		if kind != "" and arg == "":
			errs.append("%s: atom '%s' needs an argument" % [where, name])
			return
		match kind:
			"node":
				if not SkillTree.has(arg):
					errs.append("%s: unknown skill node '%s'" % [where, arg])
			"workshop":
				if Goods.workshop(arg).is_empty():
					errs.append("%s: unknown workshop '%s'" % [where, arg])
			"system":
				if not arg.is_valid_int() or not SystemsData.ids().has(int(arg)):
					errs.append("%s: unknown system '%s'" % [where, arg])
			"balance":
				if not arg.begins_with("balance.") or not bal.has(arg.trim_prefix("balance.")):
					errs.append("%s: unknown balance key '%s'" % [where, arg])
			"good":
				if not Goods.has(arg):
					errs.append("%s: unknown good '%s'" % [where, arg])
			"event":
				if not events.has(arg):
					errs.append("%s: unknown event or chain step '%s'" % [where, arg])
		return
	if typeof(cond) == TYPE_DICTIONARY and (cond.has("all") or cond.has("any")) and cond.size() == 1:
		for c in cond.get("all", cond.get("any", [])):
			lint(c, where, errs, step_ok, bal, events)
		return
	if typeof(cond) == TYPE_DICTIONARY and cond.has("not") and cond.size() == 1:
		lint(cond["not"], where, errs, step_ok, bal, events)
		return
	errs.append("%s: bad condition %s" % [where, str(cond)])

const SystemsData := preload("res://game/systems.gd")

static func read_balance() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(BALANCE_PATH)) if FileAccess.file_exists(BALANCE_PATH) else null
	if typeof(parsed) == TYPE_DICTIONARY and typeof(parsed.get("values")) == TYPE_DICTIONARY:
		return parsed["values"]
	return {}

## Ids of every event (data/events.json), pool event (data/chains.json pool_new) and chain step.
static func event_ids() -> Array:
	var out: Array = []
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/events.json")) if FileAccess.file_exists("res://data/events.json") else null
	var list = parsed.get("entries", []) if typeof(parsed) == TYPE_DICTIONARY else (parsed if typeof(parsed) == TYPE_ARRAY else [])
	for e in list:
		out.append(str(e.get("id", "")))
	for id in Chains.pool_new.keys():
		out.append(str(id))
	out.append_array(Chains.step_ids())
	return out
