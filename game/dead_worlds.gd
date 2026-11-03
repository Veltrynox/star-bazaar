extends RefCounted
## Dead worlds (design/proposals/2026-11-02-dead-planets.md): rock planets that can be mined once their skill
## is learned, with a danger meter. A planet is a dead world when its id starts with "dead_" or its type is "dead".
## Skill gate: the mine_unlock effects in data/skills.json map a planet id to a skill id (Skills.mine_skill_for). Numbers: balance.json dead_danger_max (0..5), dead_danger_rise
## (per cycle a running route mines the world). The meter is saved by main under "danger" ({planet id: value}).

const ID_PREFIX := "dead_"

var balance: Dictionary = {}
var danger: Dictionary = {}  # planet id -> 0..max

func setup(bal: Dictionary) -> void:
	balance = bal
	danger = {}

static func is_dead(p) -> bool:
	return typeof(p) == TYPE_DICTIONARY and (str(p.get("id", "")).begins_with(ID_PREFIX) or str(p.get("type", "")) == "dead")

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

## One cycle settled: each world in mining_ids (planet ids with a running route out of them) rises by dead_danger_rise.
func tick(mining_ids: Array) -> void:
	for pid in mining_ids:
		change(str(pid), int(balance.get("dead_danger_rise", 1)))

func to_dict() -> Dictionary:
	return danger.duplicate()

func from_dict(d) -> void:
	danger = {}
	if typeof(d) != TYPE_DICTIONARY:
		return  # old saves: no meter
	for k in d:
		danger[str(k)] = clampi(int(d[k]), 0, max_danger())
