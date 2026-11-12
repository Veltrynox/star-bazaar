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
## Guidance (T361): next_step(), bill_lines(), step_line(rec), is_fed(good), remind_line(cycle).
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
var last_remind: int = 0           # T361: cycle of the last NOT_BAZAAR_REMIND notice, 0 = none yet (saved)

func setup(main_node: Object) -> void:
	game = main_node
	_capital = -1
	_stage = 0
	opening_pending = false
	opened = false
	wings = []
	wing_pending = 0
	last_remind = 0
	_rebuild_bonus()
	if main_node != null and main_node.get("engine") != null:
		main_node.engine.bill_need_fn = Callable(self, "bill_need_of")  # the route engine keeps the stage bill out of need fills

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

## Units of `good` at `planet` (only the capital counts) the stage being built still needs held in the capital's storage: its tier's bill minus what the tier's other
## goods already cover. 0 for a non-bill good, before founding or once complete. The route engine never sells these to a need.
func bill_need_of(planet: int, good: String) -> int:
	if planet != _capital:
		return 0
	var key := StorageScript.planet_key(_capital)
	for r in bill_status():
		var goods := _branch_goods(int(r["tier"]))
		if not goods.has(good):
			continue
		var others := 0
		for g in goods:
			if g != good:
				others += game.storage.amount(key, g)
		return maxi(0, int(r["need"]) - others)
	return 0

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

# ---- guidance (T361): the one next-step record every surface renders -----------------------------------------------------

## True when something already feeds `good` into the capital's planet storage: a Buy order for it is on at the capital, or a route delivers it there.
func is_fed(good: String) -> bool:
	if game == null or _capital < 0 or game.get("engine") == null:
		return false
	if game.engine.local_on(_capital, good, "buy"):
		return true
	for r in game.engine.routes:
		if int(r["b"]) == _capital and str(r["c"]) == good:
			return true
	return false

## Cheapest OTHER established, discovered world in the home or viewed system that sells `good`: {planet, price}, planet -1 when none.
func _source_of(good: String) -> Dictionary:
	var best := {"planet": -1, "price": 0}
	var home: int = game.system_of(_capital)
	var viewed: int = int(game.view_system)
	for i in game.map.planets.size():
		if i == _capital or not game.planet_established(i):
			continue
		var sys: int = game.system_of(i)
		if sys != home and sys != viewed:
			continue
		var pr: int = game.engine.local_price(i, good, "buy")
		if pr < 0:
			continue
		if int(best["planet"]) < 0 or pr < int(best["price"]):
			best = {"planet": i, "price": pr}
	return best

func _bill_record(r: Dictionary) -> Dictionary:
	var rec := {"kind": "bill", "stage": current_stage(), "planet": _capital, "good": "", "amount": int(r["need"]) - int(r["have"]),
		"source": -1, "source_price": 0, "local_price": 0, "fed": false}
	var best_cost := 1 << 30
	for g in r["goods"]:  # visible goods only: a hidden good is never named
		var src := _source_of(str(g))
		var local: int = maxi(0, game.engine.local_price(_capital, str(g), "buy"))
		var cost := local if int(src["planet"]) < 0 else (mini(local, int(src["price"])) if local > 0 else int(src["price"]))
		if cost <= 0:
			cost = 1 << 29  # not sold anywhere reachable: last choice
		var fed := is_fed(str(g))
		if fed:
			cost -= 1 << 28  # a good that is already fed leads
		if cost < best_cost:
			best_cost = cost
			rec["good"] = str(g)
			rec["source"] = int(src["planet"])
			rec["source_price"] = int(src["price"])
			rec["local_price"] = local
			rec["fed"] = fed
	return rec

## One record per short bill row of the stage being built (rows with no visible good are skipped).
func bill_lines() -> Array:
	var out := []
	if game == null or current_stage() == 0:
		return out
	for r in bill_status():
		if bool(r["ok"]) or (r["goods"] as Array).is_empty():
			continue
		out.append(_bill_record(r))
	return out

## The ONE main-line step: {kind: found|bill|quorum|reach|opening|done, stage, planet, good, amount, source, source_price, local_price, fed, n, tier}.
## bill: the visible short bill good with the smallest shortfall; quorum: n worlds short at tier.
func next_step() -> Dictionary:
	var rec := {"kind": "done", "stage": current_stage(), "planet": _capital, "good": "", "amount": 0, "source": -1, "source_price": 0, "local_price": 0, "fed": false, "n": 0, "tier": 0}
	if game == null:
		return rec
	if not is_founded():
		rec["kind"] = "found"
		rec["planet"] = -1
		for i in game.map.planets.size():
			if can_found(i):
				rec["planet"] = i
				break
		return rec
	if complete():
		rec["kind"] = "opening" if opening_pending else "done"
		return rec
	var lines := bill_lines()
	if not lines.is_empty():
		var pick: Dictionary = lines[0]
		for l in lines:
			if int(l["amount"]) < int(pick["amount"]):
				pick = l
		for k in pick:
			rec[k] = pick[k]
		return rec
	var q := quorum_status()
	if not bool(q["ok"]):
		rec["kind"] = "quorum"
		rec["n"] = maxi(0, int(q["need"]) - int(q["have"]))
		rec["tier"] = int(q["tier"])
	elif not reach_ok():
		rec["kind"] = "reach"
	return rec

## The instruction line of a next_step / bill_lines record (every surface and the reminder use this one helper).
func step_line(rec: Dictionary) -> String:
	var stage_name := StoryText.get_or("BAZ_STAGE_%d_NAME" % int(rec.get("stage", 0)), "")
	var cap: String = game.planet_name(int(rec.get("planet", -1))) if game != null and int(rec.get("planet", -1)) >= 0 else ""
	match str(rec.get("kind", "")):
		"bill":
			var good := Ui.good_name(str(rec["good"])).to_lower()
			var v := {"stage": stage_name, "amount": int(rec["amount"]), "good": good, "capital": cap}
			if bool(rec["fed"]):
				return StoryText.get_or("BAZ_STEP_BILL_FED", "{stage}: {amount} {good} still to arrive at {capital}. Your Buy / route is on; wait for the cycles.", v)
			if int(rec["source"]) >= 0:
				v["source"] = game.planet_name(int(rec["source"]))
				v["price"] = int(rec["source_price"])
				v["local"] = int(rec["local_price"])
				return StoryText.get_or("BAZ_STEP_BILL", "{stage} needs {amount} {good} held in {capital}'s storage. Buy it at {source} ({price} cr) and send it to {capital}, or Buy it at {capital} ({local} cr).", v)
			v["local"] = int(rec["local_price"])
			return StoryText.get_or("BAZ_STEP_BILL_LOCAL", "{stage} needs {amount} {good} held in {capital}'s storage. Buy it at {capital} ({local} cr).", v)
		"quorum":
			return StoryText.get_or("BAZ_STEP_QUORUM", "{stage} needs {n} more worlds at {tier}. Meet their needs each cycle: see Closest growth.",
				{"stage": stage_name, "n": int(rec.get("n", 0)), "tier": StoryText.get_or("PROS_TIER_%d" % int(rec.get("tier", 0)), "Tier %d" % int(rec.get("tier", 0)))})
		"reach":
			return StoryText.get_or("BAZ_STEP_REACH", "{stage} needs a world in another system. Buy a permit (Skills) and establish a post there.", {"stage": stage_name})
	return ""

## Cycle end (called by main): the gentle reminder line, or "". Only for a short bill nothing feeds, at most once every bazaar_remind_cycles; records the cycle.
func remind_line(cycle: int) -> String:
	if game == null or not is_founded() or complete():
		return ""
	var rec := next_step()
	if str(rec["kind"]) != "bill" or bool(rec["fed"]):
		return ""
	if last_remind > 0 and cycle - last_remind < _bal("bazaar_remind_cycles", 4):
		return ""
	last_remind = cycle
	return step_line(rec)

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
	return {"capital": _capital, "stage": _stage, "opening_pending": opening_pending, "opened": opened, "wings": wings.duplicate(), "wing_pending": wing_pending, "last_remind": last_remind}

## Old saves have no block: nothing founded.
func from_dict(s) -> void:
	_capital = -1
	_stage = 0
	opening_pending = false
	opened = false
	wings = []
	wing_pending = 0
	last_remind = 0
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
	last_remind = int(s.get("last_remind", 0)) if _capital >= 0 else 0  # T361: older saves have none
	_rebuild_bonus()
