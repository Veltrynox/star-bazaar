class_name Bots
extends RefCounted
## Four Markets: the three rival bots. Pure functions: volume of one bot in one market in one cycle.
## Volume = (strength x strength_mult + growth x cycle + gap growth) x tier mult x (1 +- bot_noise_pct) x bot_scale.
## Noise is seeded by (run seed, bot, market, cycle) so a run is repeatable and a reloaded save gives the same numbers.
## All numbers are balance.json keys bot_<b>_<m>_strength / _growth, bot_<b>_tier_cycle_1/2, bot_tier_mult_1..4.

const IDS := [1, 2, 3]
## TODO story: working names from the story doc; the story-designer owns the final names.
const NAMES := {1: "Harrow Combine", 2: "Velvet Concord", 3: "Ostrel Syndicate"}

static func bot_name(b: int) -> String:
	return str(NAMES.get(b, "Bot %d" % b))

## Tier 1..4: tier-ups at bot_<b>_tier_cycle_1 and _2, plus a persistent offset from events (later goal).
static func tier(bal: Dictionary, b: int, cycle: int, offset: int = 0) -> int:
	var t := 1
	if cycle >= int(bal.get("bot_%d_tier_cycle_1" % b, 9999)):
		t += 1
	if cycle >= int(bal.get("bot_%d_tier_cycle_2" % b, 9999)):
		t += 1
	return clampi(t + offset, 1, 4)

static func noise(bal: Dictionary, run_seed: int, b: int, m: String, cycle: int) -> float:
	var r := RandomNumberGenerator.new()
	r.seed = hash([run_seed, b, m, cycle])
	var n := float(bal.get("bot_noise_pct", 0.0))
	return 1.0 + r.randf_range(-n, n)

## gap: accumulated gap growth for this bot and market. strength_mult: event hits (later goal), 1.0 now.
static func volume(bal: Dictionary, run_seed: int, b: int, m: String, cycle: int, gap: float = 0.0, tier_offset: int = 0, strength_mult: float = 1.0) -> float:
	var s := float(bal.get("bot_%d_%s_strength" % [b, m], 0.0)) * strength_mult
	var g := float(bal.get("bot_%d_%s_growth" % [b, m], 0.0))
	var mult := float(bal.get("bot_tier_mult_%d" % tier(bal, b, cycle, tier_offset), 1.0))
	return (s + g * cycle + gap) * mult * noise(bal, run_seed, b, m, cycle) * float(bal.get("bot_scale", 1.0))
