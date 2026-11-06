class_name Bazaar
extends RefCounted
## The Star Bazaar (design/proposals/2026-11-06-empire-growth-v2.md section 4): the run is won by raising it at a capital.
## found(planet): once per run, final, when that world's prosperity tier >= bazaar_capital_tier. Stages (bazaar_stages) each
## have a bill (units of the run branch's goods of a goods-tier, any mix, in the capital's planet storage), a quorum (other
## worlds at a tier) and, from bazaar_reach_stage, a quorum world in another system than the capital. At cycle end
## end_cycle() completes the stage when all three hold: the bill is removed, stage_done(n) is emitted. The last stage
## returns the win outcome {kind: "bazaar"} and sets opening_pending (hook for the Opening flight added later).
## Numbers: only data/balance.json (placeholders; see data/bazaar.json for the key names). Saved by main under "bazaar".
## Condition atom bazaar_stage:<n> (game/conditions.gd): n stages are done.
## UI API: capital(), can_found(i), stage(), stages_total(), bill_status(), quorum_status(), reach_ok(), reach_needed().

const StorageScript := preload("res://game/storage.gd")

signal stage_done(n: int)
signal founded(planet: int)

var game: Object = null        # the running Main (storage, prosperity, map, balance, system_of)
var _capital: int = -1         # planet index of the capital, -1 until founded
var _stage: int = 0            # stages completed
var opening_pending: bool = false  # last stage done: the Opening flight is still to fly (hook for a later task)

func setup(main_node: Object) -> void:
	game = main_node
	_capital = -1
	_stage = 0
	opening_pending = false

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

## Cycle end: completes the stage being built when it is ready. Returns the win outcome {kind: "bazaar"} on the last one, else {}.
func end_cycle() -> Dictionary:
	if not stage_ready():
		return {}
	_consume_bill()
	_stage += 1
	stage_done.emit(_stage)
	if complete():
		opening_pending = true
		return {"kind": "bazaar"}
	return {}

func _consume_bill() -> void:
	var key := StorageScript.planet_key(_capital)
	for r in bill_status():
		var left := int(r["need"])
		for g in _branch_goods(int(r["tier"])):
			if left <= 0:
				break
			left -= game.storage.remove(key, g, left)

func to_dict() -> Dictionary:
	return {"capital": _capital, "stage": _stage, "opening_pending": opening_pending}

## Old saves have no block: nothing founded.
func from_dict(s) -> void:
	_capital = -1
	_stage = 0
	opening_pending = false
	if typeof(s) != TYPE_DICTIONARY:
		return
	_capital = int(s.get("capital", -1))
	_stage = clampi(int(s.get("stage", 0)), 0, stages_total()) if _capital >= 0 else 0
	opening_pending = bool(s.get("opening_pending", false))
