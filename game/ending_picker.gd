class_name EndingPicker
extends RefCounted
## Inputs of a win ending (core 6): which ending id fires and the flavour lines inside it. Read at the win from the
## learned skills (Skills) and the market shares (Markets); the end screen gets the dictionary from inputs().
## The ending id is END_<MKT>_GOOD or _BAD by Chains.ending_flag (the hidden chain direction; nothing of it is shown).
## CEO endings (data/endings.json): for a Bazaar win pick() walks that file's rows in order; the first row whose visible_when and
## requires hold is the ending (END_<MKT>_<KEY>); none (or a save without run_notes) = the GOOD / BAD fallback above.
## rival_broken: a rival of that market really lost a tier through a chain option (rival_broken_bot names it).


const ENDINGS_PATH := "res://data/endings.json"
## Counters saved in Main.run_notes (six ints).
const STORED_KEYS := ["quick_routes", "card_routes", "gigs_done", "gigs_expired", "restless_cycles", "peak_ships", "space_cycles"]
## Notes derived from the live state at the end (Main.note_value); not saved.
const DERIVED_KEYS := ["explored", "established", "platforms", "worlds_city", "warm_worlds", "repossessions", "skills_min"]
const ALL_KEYS := STORED_KEYS + DERIVED_KEYS

static func rows() -> Array:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(ENDINGS_PATH)) if FileAccess.file_exists(ENDINGS_PATH) else null
	return parsed.get("endings", []) if typeof(parsed) == TYPE_DICTIONARY and typeof(parsed.get("endings")) == TYPE_ARRAY else []

## Ending id of a Bazaar win of `market`. game = the live Main (notes). Old save (no run_notes): the fallback straight away.
static func pick(market: String, game: Object) -> String:
	var mk := market.to_upper()
	var fallback := "END_%s_%s" % [mk, Chains.ending_flag(market.to_lower()).to_upper()]
	if game == null or not bool(game.get("notes_known")):
		return fallback
	for r in rows():
		if typeof(r) != TYPE_DICTIONARY or not str(r.get("id", "")).begins_with("END_%s_" % mk):
			continue
		if Conditions.visible(r) and Conditions.eval(r.get("requires", "start")):
			return str(r["id"])
	return fallback

## The key of a CEO ending id ("LONGSHIFT" of END_MIN_LONGSHIFT); "" for the GOOD / BAD fallback or a non-ending id.
static func key_of(ending_id: String, market: String) -> String:
	var pre := "END_%s_" % market.to_upper()
	if not ending_id.begins_with(pre):
		return ""
	var k := ending_id.trim_prefix(pre)
	return "" if k == "GOOD" or k == "BAD" else k

## The three original tech nodes of a market (X_2, X_4, X_6), in tree order; the later techs do not count for the ending.
static func techs_of(market: String) -> Array:
	var out := []
	for id in SkillTree.ids_in(market):
		if SkillTree.is_tech(id) and (id.ends_with("_2") or id.ends_with("_4") or id.ends_with("_6")):
			out.append(id)
	return out

## Dictionary for the end screen:
## {market, ending_id, capstone (MKT_7 learned), tech_done (0..3), rival_broken, rival_broken_bot (0 none), flag ("good"|"bad"),
##  decisive (T284: Chains.decisive_moments(), the three choices that moved the lean most),
##  stages_done (T259: Star Bazaar stages completed),
##  recap (T298: Bazaar.recap(): site, stages, wings, worlds_per_tier, reclaimed, decisive; {} when not given)}.
static func inputs(market: String, balance: Dictionary, stages_done: int = 0, recap: Dictionary = {}) -> Dictionary:
	var mk := market.to_lower()
	var done := 0
	for id in techs_of(mk):
		if Skills.is_learned(id):
			done += 1
	return {"market": mk, "ending_id": "END_%s_%s" % [mk.to_upper(), Chains.ending_flag(mk).to_upper()], "flag": Chains.ending_flag(mk), "decisive": Chains.decisive_moments(), "stages_done": stages_done, "recap": recap, "capstone": Skills.is_learned("%s_7" % mk.to_upper()),
		"tech_done": done, "rival_broken": Chains.rival_broken(mk), "rival_broken_bot": Chains.rival_broken_bot(mk)}
