class_name Bots
extends RefCounted
const StoryText := preload("res://game/story_text.gd")
## The three houses: ids, names and tints only (T281). Houses are weather, never opponents (see game/events.gd).
## No volume curves: share and bot volumes are gone. tier() is read by the chain log wording.

const IDS := [1, 2, 3]
## TODO story: working names from the story doc; the story-designer owns the final names.
const NAMES := {1: "Harrow Combine", 2: "Velvet Concord", 3: "Ostrel Syndicate"}

static func bot_name(b: int) -> String:
	return StoryText.get_or("BOT_NAME_%d" % b, str(NAMES.get(b, "Bot %d" % b)))

## Tier 1..4: tier-ups at bot_<b>_tier_cycle_1 and _2, (the offset argument is 0 everywhere).
static func tier(bal: Dictionary, b: int, cycle: int, offset: int = 0) -> int:
	var t := 1
	if cycle >= int(bal.get("bot_%d_tier_cycle_1" % b, 9999)):
		t += 1
	if cycle >= int(bal.get("bot_%d_tier_cycle_2" % b, 9999)):
		t += 1
	return clampi(t + offset, 1, 4)
