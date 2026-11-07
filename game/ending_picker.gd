class_name EndingPicker
extends RefCounted
## Inputs of a win ending (core 6): which ending id fires and the flavour lines inside it. Read at the win from the
## learned skills (Skills) and the market shares (Markets); the end screen gets the dictionary from inputs().
## The ending id is END_<MKT>_GOOD or _BAD by Chains.ending_flag (the hidden chain direction; nothing of it is shown).
## rival_broken: a rival of that market really lost a tier through a chain option (rival_broken_bot names it).


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
##  recap (T298: Bazaar.recap(): capital, stages, wings, worlds_per_tier, reclaimed, decisive; {} when not given)}.
static func inputs(market: String, balance: Dictionary, stages_done: int = 0, recap: Dictionary = {}) -> Dictionary:
	var mk := market.to_lower()
	var done := 0
	for id in techs_of(mk):
		if Skills.is_learned(id):
			done += 1
	return {"market": mk, "ending_id": "END_%s_%s" % [mk.to_upper(), Chains.ending_flag(mk).to_upper()], "flag": Chains.ending_flag(mk), "decisive": Chains.decisive_moments(), "stages_done": stages_done, "recap": recap, "capstone": Skills.is_learned("%s_7" % mk.to_upper()),
		"tech_done": done, "rival_broken": Chains.rival_broken(mk), "rival_broken_bot": Chains.rival_broken_bot(mk)}
