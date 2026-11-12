class_name Bazaar
extends RefCounted
## The Star Bazaar (design/proposals/2026-11-06-empire-growth-v2.md section 4): the run is won by raising it at a capital.
## found(planet): once per run, final, when that world's prosperity tier >= bazaar_capital_tier. Stages (bazaar_stages) each
## have a bill (units of the run branch's goods of a goods-tier, any mix, in the capital's planet storage), a quorum (other
## worlds at a tier) and, from bazaar_reach_stage, a quorum world in another system than the capital. At cycle end
## end_cycle() completes the stage when all three hold: the bill is removed, stage_done(n) is emitted. The last stage
## sets opening_pending and emits opening_ready (T298): the Opening gig (kind "opening", game/gigs.gd) asks the Flagship to fly the charter
## cargo to the capital; docking there calls open(), which returns the win outcome {kind: "bazaar"}. end_cycle() itself never wins.
## Wings (T298): each stage listed in data/bazaar.json "wings" offers two perks (wing_pending = the stage to choose for; choose_wing(idx)).
## A wing has an effect (hold_units | hub_reach | tax_pct | workshop_cost_pct) and its amount is the balance key bazaar_wing_<id> (placeholder).
## wing_bonus(effect) sums the chosen wings (static, so hold, hubs, tax and workshops read it without a Main handle).
## recap() is the end recap data: capital, stages, wings, worlds per tier, reclaimed worlds, decisive moments.
## Numbers: only data/balance.json (placeholders; see data/bazaar.json for the key names). Saved by main under "bazaar".
## Condition atom bazaar_stage:<n> (game/conditions.gd): n stages are done.
## UI API: capital(), can_found(i), stage(), stages_total(), bill_status(), quorum_status(), reach_ok(), reach_needed().

const StoryText := preload("res://game/story_text.gd")
const StorageScript := preload("res://game/storage.gd")

signal stage_done(n: int)
signal founded(planet: int)
signal opening_ready(planet: int)  # T298: the last stage is done, the Opening gig may be posted at the capital
signal wing_offered(stage: int)    # T298: a stage is done and has wings to choose from
signal wing_chosen(id: String)

const DATA_PATH := "res://data/bazaar.json"
static var _bonus: Dictionary = {}  # effect -> summed amount of the chosen wings (rebuilt by _rebuild_bonus)

var game: Object = null        # the running Main (storage, prosperity, map, balance, system_of)
var _capital: int = -1         # planet index of the capital, -1 until founded
var _stage: int = 0            # stages completed
var opening_pending: bool = false  # last stage done: the Opening flight is still to fly
var opened: bool = false           # T298: the Opening flew (docked at the capital)
var wings: Array = []              # chosen wing ids, in stage order
var wing_pending: int = 0          # stage whose wing is still to choose, 0 = none

func setup(main_node: Object) -> void:
	game = main_node
	_capital = -1
	_stage = 0
	opening_pending = false
	opened = false
	wings = []
	wing_pending = 0
	_rebuild_bonus()

func _bal(key: String, fallback: int) -> int:
	return int(game.balance.get(key, fallback)) if game != null else fallback

func capital() -> int:
	return _capital

func is_founded() -> bool:
	return _capital >= 0

func stage() -> int:
	return _stage

func stages_total() -> int:
	return maxi(1, _bal("bazaar_stages", 4))

func complete() -> bool:
	return is_founded() and _stage >= stages_total()

func capital_tier() -> int:
	return _bal("bazaar_capital_tier", 2)

## True when the Bazaar may be founded at world i: none yet, and the world stands at the capital tier.
func can_found(i: int) -> bool:
	return game != null and not is_founded() and i >= 0 and i < game.map.planets.size() and game.prosperity.tier(i) >= capital_tier()

func found(i: int) -> bool:
	if not can_found(i):
		return false
	_capital = i
	founded.emit(i)
	return true

## The stage being built (1-based), 0 before founding, or after the last one.
func current_stage() -> int:
	return _stage + 1 if is_founded() and not complete() else 0

func _branch_goods(tier: int) -> Array:
	var out := []
	var b: String = game.run_branch() if game != null else ""
	for g in Goods.ids():
		var e := Goods.entry(g)
		var m := str(e.get("market", ""))
		if m == "" or int(e.get("tier", 1)) != tier:
			continue
		if b == "" or m == b:
			out.append(g)
	return out

## Bill of the stage being built: [{tier, need, have, goods (visible ones only), ok}] for tiers with need > 0.
func bill_status() -> Array:
	var out := []
	var n := current_stage()
	if n == 0:
		return out
	for t in range(1, 9):
		var need := _bal("bazaar_bill_s%d_t%d" % [n, t], 0)
		if need <= 0:
			continue
		var goods := _branch_goods(t)
		var have := 0
		for g in goods:
			have += game.storage.amount(StorageScript.planet_key(_capital), g)
		out.append({"tier": t, "need": need, "have": have, "goods": Availability.visible_goods(goods), "ok": have >= need})
	return out

func bill_ok() -> bool:
	for r in bill_status():
		if not bool(r["ok"]):
			return false
	return true

## Quorum of the stage being built: {tier, need, have, ok, worlds (planet indexes of the quorum, capital left out)}.
func quorum_status() -> Dictionary:
	var n := current_stage()
	if n == 0:
		return {"tier": 0, "need": 0, "have": 0, "ok": false, "worlds": []}
	var tier := _bal("bazaar_quorum_tier_s%d" % n, 1)
	var need := _bal("bazaar_quorum_count_s%d" % n, 0)
	var worlds := []
	for i in game.map.planets.size():
		if i != _capital and game.prosperity.tier(i) >= tier:
			worlds.append(i)
	return {"tier": tier, "need": need, "have": worlds.size(), "ok": worlds.size() >= need, "worlds": worlds}

## True once the stage being built must also have a quorum world in another system.
func reach_needed() -> bool:
	return current_stage() >= _bal("bazaar_reach_stage", 3) and current_stage() > 0

## Reach holds when it is not needed yet, or a quorum world stands in another system than the capital.
func reach_ok() -> bool:
	if not is_founded():
		return false
	if not reach_needed():
		return true
	var home: int = game.system_of(_capital)
	for i in quorum_status()["worlds"]:
		if game.system_of(int(i)) != home:
			return true
	return false

func stage_ready() -> bool:
	return is_founded() and not complete() and bill_ok() and bool(quorum_status()["ok"]) and reach_ok()

## Cycle end: completes the stage being built when it is ready (never wins by itself: the last stage posts the Opening). Returns {}.
func end_cycle() -> Dictionary:
	if not stage_ready():
		return {}
	_consume_bill()
	_stage += 1
	stage_done.emit(_stage)
	if not wing_options(_stage).is_empty():
		wing_pending = _stage
		wing_offered.emit(_stage)
	if complete():
		opening_pending = true
		opening_ready.emit(_capital)
	return {}

## The Flagship docked at the capital with the charter cargo: the win outcome {kind: "bazaar"}, {} when there is no Opening to fly.
func open() -> Dictionary:
	if not opening_pending:
		return {}
	opening_pending = false
	opened = true
	return {"kind": "bazaar"}

# ---- wings -----------------------------------------------------------------------------------------------------------

static func read_data() -> Dictionary:
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	if f == null:
		return {}
	var d = JSON.parse_string(f.get_as_text())
	return d if typeof(d) == TYPE_DICTIONARY else {}

## The wings of a stage: [{id, effect, key (balance key of the amount), name, text}], empty when the stage has none.
static func wing_options(stage_n: int) -> Array:
	var out := []
	for row in read_data().get("wings", []):
		if int(row.get("stage", 0)) != stage_n:
			continue
		for w in row.get("options", []):
			var id := str(w.get("id", ""))
			out.append({"id": id, "effect": str(w.get("effect", "")), "key": "bazaar_wing_" + id.to_lower(),
				"name": StoryText.get_or("BAZ_%s_NAME" % id, id), "text": StoryText.get_or("BAZ_%s_LINE" % id, "")})
	return out

static func wing_def(id: String) -> Dictionary:
	for row in read_data().get("wings", []):
		for w in row.get("options", []):
			if str(w.get("id", "")) == id:
				return {"id": id, "effect": str(w.get("effect", "")), "key": "bazaar_wing_" + id.to_lower(), "stage": int(row.get("stage", 0))}
	return {}

## Summed amount of the chosen wings with that effect (0 with none).
static func wing_bonus(effect: String) -> float:
	return float(_bonus.get(effect, 0.0))

func _rebuild_bonus() -> void:
	_bonus = {}
	for id in wings:
		var d := wing_def(str(id))
		if d.is_empty():
			continue
		var amount := float(game.balance.get(str(d["key"]), 0.0)) if game != null else 0.0
		_bonus[str(d["effect"])] = float(_bonus.get(str(d["effect"]), 0.0)) + amount

## Picks option `idx` (0 or 1) of the pending wing. False when none is pending or idx is out of range.
func choose_wing(idx: int) -> bool:
	var opts := wing_options(wing_pending)
	if wing_pending <= 0 or idx < 0 or idx >= opts.size():
		return false
	var id := str(opts[idx]["id"])
	wings.append(id)
	wing_pending = 0
	_rebuild_bonus()
	wing_chosen.emit(id)
	return true

# ---- end recap -------------------------------------------------------------------------------------------------------

## Data for the end screen: {capital (planet index or -1), stages, stages_total, wings (ids), worlds_per_tier {tier: count} (tier 1..top),
## reclaimed (planet indexes), decisive (Chains.decisive_moments())}. Counts are for the screen; epilogue text never shows them.
func recap() -> Dictionary:
	var per := {}
	var reclaimed := []
	if game != null:
		for i in game.map.planets.size():
			var t: int = game.prosperity.tier(i)
			if t >= 1:
				per[t] = int(per.get(t, 0)) + 1
			if game.prosperity.is_reclaimed(i):
				reclaimed.append(i)
	return {"capital": _capital, "stages": _stage, "stages_total": stages_total(), "wings": wings.duplicate(), "worlds_per_tier": per,
		"reclaimed": reclaimed, "decisive": Chains.decisive_moments()}

func _consume_bill() -> void:
	var key := StorageScript.planet_key(_capital)
	for r in bill_status():
		var left := int(r["need"])
		for g in _branch_goods(int(r["tier"])):
			if left <= 0:
				break
			left -= game.storage.remove(key, g, left)

func to_dict() -> Dictionary:
	return {"capital": _capital, "stage": _stage, "opening_pending": opening_pending, "opened": opened, "wings": wings.duplicate(), "wing_pending": wing_pending}

## Old saves have no block: nothing founded.
func from_dict(s) -> void:
	_capital = -1
	_stage = 0
	opening_pending = false
	opened = false
	wings = []
	wing_pending = 0
	if typeof(s) != TYPE_DICTIONARY:
		_rebuild_bonus()
		return
	_capital = int(s.get("capital", -1))
	_stage = clampi(int(s.get("stage", 0)), 0, stages_total()) if _capital >= 0 else 0
	opening_pending = bool(s.get("opening_pending", false))
	opened = bool(s.get("opened", false))
	for w in s.get("wings", []):
		if not wing_def(str(w)).is_empty() and not wings.has(str(w)):
			wings.append(str(w))
	wing_pending = int(s.get("wing_pending", 0)) if _capital >= 0 else 0
	_rebuild_bonus()
