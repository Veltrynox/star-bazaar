extends RefCounted
## Dead worlds (design/proposals/2026-11-02-dead-planets.md): rock planets that can be mined once their skill
## is learned. A planet is a dead world when its id starts with "dead_" or its type is "dead".
## Skill gate: the mine_unlock effects in data/skills.json map a planet id to a skill id (Skills.mine_skill_for).
## T295: a reclaimed world has type "reclaimed" and is no longer a dead world. Mining stock (design section 3.4): each dead world has a
## finite stock (balance dead_stock, never refills; routes take from it, see route_engine). UI getters: stock_left(pid), stock_max(),
## cycles_left(pid) (-1 when nothing mined last cycle). Saved by main under "dead_mining" (state_to_dict / state_from_dict).

const ID_PREFIX := "dead_"
const RECLAIMED_TYPE := "reclaimed"

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

## One cycle settled: last cycle's mining counts become the rate cycles_left reads.
func tick() -> void:
	_rate = _acc
	_acc = {}

func stock_max() -> int:
	return maxi(0, int(balance.get("dead_stock", 0)))

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
