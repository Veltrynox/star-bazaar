extends RefCounted
## Dead worlds (design/proposals/2026-11-02-dead-planets.md): rock planets that can be mined once their skill
## is learned, with a danger meter. A planet is a dead world when its id starts with "dead_" or its type is "dead".
## Skill gate: the mine_unlock effects in data/skills.json map a planet id to a skill id (Skills.mine_skill_for). Numbers: balance.json dead_danger_max (0..5), dead_danger_rise
## (per cycle a running route mines the world). The meter is saved by main under "danger" ({planet id: value}).
## T295: a reclaimed world has type "reclaimed" and is no longer a dead world. Mining stock and intensity (design section 3.4): each dead world has a
## finite stock (balance dead_stock, never refills; routes take from it, see route_engine). Intensity is one of STEPS (gentle, normal, hard, Minerals runs only)
## with balance keys mining_intensity_yield_<step> (multiplier on the units a line moves) and mining_intensity_danger_<step> (multiplier on dead_danger_rise
## here; clusters and later raids read danger_mult too). UI getters: stock_left(pid), stock_max(), cycles_left(pid) (-1 when nothing mined last cycle),
## intensity_of(pid), set_intensity(pid, step). Saved by main under "dead_mining" (state_to_dict / state_from_dict).

const ID_PREFIX := "dead_"
const RECLAIMED_TYPE := "reclaimed"
const STEPS := ["gentle", "normal", "hard"]
const DEFAULT_STEP := 1

var balance: Dictionary = {}
var danger: Dictionary = {}  # planet id -> 0..max
var stock: Dictionary = {}      # planet id -> units left (only worlds mined so far; others are at stock_max())
var intensity: Dictionary = {}  # planet id -> 0..2 (default DEFAULT_STEP)
var _rate: Dictionary = {}      # planet id -> units mined in the last settled cycle
var _acc: Dictionary = {}       # planet id -> units mined in the cycle being settled
var _carry: Dictionary = {}     # planet id -> fractional danger not yet counted

func setup(bal: Dictionary) -> void:
	balance = bal
	danger = {}
	stock = {}
	intensity = {}
	_rate = {}
	_acc = {}
	_carry = {}

static func is_dead(p) -> bool:
	return typeof(p) == TYPE_DICTIONARY and str(p.get("type", "")) != RECLAIMED_TYPE and (str(p.get("id", "")).begins_with(ID_PREFIX) or str(p.get("type", "")) == "dead")

## Skill needed to mine this world ("" when the world needs none or is not a dead world).
static func skill_for(p) -> String:
	return Skills.mine_skill_for(str(p.get("id", ""))) if is_dead(p) else ""

func max_danger() -> int:
	return maxi(0, int(balance.get("dead_danger_max", 5)))

func get_danger(pid: String) -> int:
	return int(danger.get(pid, 0))

func set_danger(pid: String, v: int) -> void:
	danger[pid] = clampi(v, 0, max_danger())

## Events change the meter by delta (negative to pull out or shore up). Returns the new value.
func change(pid: String, delta: int) -> int:
	set_danger(pid, get_danger(pid) + delta)
	return get_danger(pid)

## One cycle settled: each world in mining_ids (planet ids with a running route out of them) rises by dead_danger_rise
## times the intensity's danger multiplier (fractions carry over to the next cycle).
func tick(mining_ids: Array) -> void:
	for pid in mining_ids:
		var k := str(pid)
		var c := float(_carry.get(k, 0.0)) + float(balance.get("dead_danger_rise", 1)) * danger_mult(k)
		var whole := floori(c + 0.0001)
		_carry[k] = c - float(whole)
		change(k, whole)
	_rate = _acc
	_acc = {}

## ---- Mining stock and intensity (T295) ----
static func step_name(step: int) -> String:
	return STEPS[clampi(step, 0, STEPS.size() - 1)]

## Intensity is a Minerals-run lever: open when the run's branch is Minerals (or has none yet, old saves).
static func intensity_open() -> bool:
	var b := Conditions.run_branch()
	return b == "" or b == "min"

static func yield_mult_for(bal: Dictionary, step: int) -> float:
	return maxf(0.0, float(bal.get("mining_intensity_yield_" + step_name(step), 1.0)))

static func danger_mult_for(bal: Dictionary, step: int) -> float:
	return maxf(0.0, float(bal.get("mining_intensity_danger_" + step_name(step), 1.0)))

func intensity_of(pid: String) -> int:
	return clampi(int(intensity.get(pid, DEFAULT_STEP)), 0, STEPS.size() - 1)

## Returns false when the lever is closed (not a Minerals run) or the id is not a dead world's.
func set_intensity(pid: String, step: int) -> bool:
	if not intensity_open() or not pid.begins_with(ID_PREFIX):
		return false
	intensity[pid] = clampi(step, 0, STEPS.size() - 1)
	return true

func yield_mult(pid: String) -> float:
	return yield_mult_for(balance, intensity_of(pid))

func danger_mult(pid: String) -> float:
	return danger_mult_for(balance, intensity_of(pid))

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
	return {"stock": stock.duplicate(), "intensity": intensity.duplicate(), "rate": _rate.duplicate()}

func state_from_dict(d) -> void:
	stock = {}
	intensity = {}
	_rate = {}
	_acc = {}
	_carry = {}
	if typeof(d) != TYPE_DICTIONARY:
		return  # old saves: full stock, normal intensity
	for k in d.get("stock", {}):
		stock[str(k)] = clampi(int(d["stock"][k]), 0, stock_max())
	for k in d.get("intensity", {}):
		intensity[str(k)] = clampi(int(d["intensity"][k]), 0, STEPS.size() - 1)
	for k in d.get("rate", {}):
		_rate[str(k)] = maxi(0, int(d["rate"][k]))

func to_dict() -> Dictionary:
	return danger.duplicate()

func from_dict(d) -> void:
	danger = {}
	if typeof(d) != TYPE_DICTIONARY:
		return  # old saves: no meter
	for k in d:
		danger[str(k)] = clampi(int(d[k]), 0, max_danger())
