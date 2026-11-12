extends RefCounted
## Dead worlds (design/proposals/2026-11-02-dead-planets.md): rock planets that can be mined once their skill
## is learned. A planet is a dead world when its id starts with "dead_" or its type is "dead".
## Skill gate: Prospecting (FND_PROSPECT) opens every dead world (Skills.mine_skill_for).
## Mine good: each company mines its own tier-2 raw (data/planets.json mines_by_branch: branch -> planet id -> good), bought at
## round(base_value x balance dead_mine_price_pct); the mine sells nothing. mine_good / mine_price / apply_mine are the one place for it.
## T295: a reclaimed world has type "reclaimed" and is no longer a dead world. Mining stock (design section 3.4): each dead world has a
## finite stock (balance dead_stock, never refills; routes take from it, see route_engine). UI getters: stock_left(pid), stock_max(),
## cycles_left(pid) (-1 when nothing mined last cycle). Saved by main under "dead_mining" (state_to_dict / state_from_dict).

const ID_PREFIX := "dead_"
const RECLAIMED_TYPE := "reclaimed"
const PLANETS_PATH := "res://data/planets.json"
const FALLBACK_BRANCH := "min"  # old saves with no branch keep the Minerals mines

static var _mines: Dictionary = {}

var balance: Dictionary = {}
var stock: Dictionary = {}      # planet id -> units left (only worlds mined so far; others are at stock_max())
var _rate: Dictionary = {}      # planet id -> units mined in the last settled cycle
var _acc: Dictionary = {}       # planet id -> units mined in the cycle being settled

func setup(bal: Dictionary) -> void:
	balance = bal
	stock = {}
	_rate = {}
	_acc = {}

static func is_dead(p) -> bool:
	return typeof(p) == TYPE_DICTIONARY and str(p.get("type", "")) != RECLAIMED_TYPE and (str(p.get("id", "")).begins_with(ID_PREFIX) or str(p.get("type", "")) == "dead")

## Skill needed to mine this world ("" when the world needs none or is not a dead world).
static func skill_for(p) -> String:
	return Skills.mine_skill_for(str(p.get("id", ""))) if is_dead(p) else ""

## data/planets.json mines_by_branch (branch -> planet id -> good), read once.
static func mines_table() -> Dictionary:
	if _mines.is_empty():
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(PLANETS_PATH)) if FileAccess.file_exists(PLANETS_PATH) else null
		if typeof(parsed) == TYPE_DICTIONARY and typeof(parsed.get("mines_by_branch")) == TYPE_DICTIONARY:
			_mines = parsed["mines_by_branch"]
	return _mines

## Good this dead world yields for the run branch ("" = the current run branch; "" when the world has no mine).
static func mine_good(pid: String, branch: String = "") -> String:
	var b := branch if branch != "" else SkillTree.run_branch
	var t := mines_table()
	if not t.has(b):
		b = FALLBACK_BRANCH
	var row = t.get(b, {})
	return str(row.get(pid, "")) if typeof(row) == TYPE_DICTIONARY else ""

## Buy price of the mine good: round(base_value x dead_mine_price_pct), at least 1. 0 when the world has no mine.
static func mine_price(pid: String, bal: Dictionary, branch: String = "") -> int:
	var g := mine_good(pid, branch)
	if g == "":
		return 0
	return maxi(1, roundi(float(Markets.value_of(g)) * float(bal.get("dead_mine_price_pct", 0.3))))

## Writes the mine good and its single buy price onto a dead world's planet row (safe to call again). No sell price.
## Returns the good ("" when p is not a dead world or has no mine).
static func apply_mine(p: Dictionary, bal: Dictionary, branch: String = "") -> String:
	if not is_dead(p):
		return ""
	var pid := str(p.get("id", ""))
	var g := mine_good(pid, branch)
	if g == "":
		return ""
	p["abundant"] = g
	p["base_prices"] = {g + "_buy": mine_price(pid, bal, branch)}
	return g

## One cycle settled: last cycle's mining counts become the rate cycles_left reads.
func tick() -> void:
	_rate = _acc
	_acc = {}

func stock_max() -> int:
	return maxi(0, roundi(float(balance.get("dead_stock", 0)) * Skills.dead_stock_mult()))  # MIN_5 raises the cap

func stock_left(pid: String) -> int:
	return clampi(int(stock.get(pid, stock_max())), 0, stock_max())

func exhausted(pid: String) -> bool:
	return stock_left(pid) <= 0

## Route engine: a ship took n units out of this world. Returns the units counted (never more than is left).
func take(pid: String, n: int) -> int:
	var got := mini(maxi(0, n), stock_left(pid))
	stock[pid] = stock_left(pid) - got
	_acc[pid] = int(_acc.get(pid, 0)) + got
	return got

## Cycles the stock lasts at last cycle's mining rate; -1 when nothing was mined (unknown).
func cycles_left(pid: String) -> int:
	var r := int(_rate.get(pid, 0))
	return -1 if r <= 0 else ceili(float(stock_left(pid)) / float(r))

func state_to_dict() -> Dictionary:
	return {"stock": stock.duplicate(), "rate": _rate.duplicate()}

func state_from_dict(d) -> void:
	stock = {}
	_rate = {}
	_acc = {}
	if typeof(d) != TYPE_DICTIONARY:
		return  # old saves: full stock
	for k in d.get("stock", {}):
		stock[str(k)] = clampi(int(d["stock"][k]), 0, stock_max())
	for k in d.get("rate", {}):
		_rate[str(k)] = maxi(0, int(d["rate"][k]))
