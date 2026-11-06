class_name EndingPicker
extends RefCounted
## Inputs of a win ending (core 6): which ending id fires and the flavour lines inside it. Read at the win from the
## learned skills (Skills) and the market shares (Markets); the end screen gets the dictionary from inputs().
## The ending id is END_<MKT>_GOOD or _BAD by Chains.ending_flag (the hidden chain direction; nothing of it is shown).
## rival_broken: a rival of that market really lost a tier through a chain option (rival_broken_bot names it).

const SECOND_KEY := "ending_second_market_pct"  # balance: the second-best market counts from this share (0.25)

## The three original tech nodes of a market (X_2, X_4, X_6), in tree order; the later techs do not count for the ending.
static func techs_of(market: String) -> Array:
	var out := []
	for id in SkillTree.ids_in(market):
		if SkillTree.is_tech(id) and (id.ends_with("_2") or id.ends_with("_4") or id.ends_with("_6")):
			out.append(id)
	return out

## Dictionary for the end screen:
## {market, ending_id, capstone (MKT_7 learned), tech_done (0..3), rival_broken, rival_broken_bot (0 none), flag ("good"|"bad"),
##  second_market ("" when none), second_share, second_over (second-best market over ending_second_market_pct)}.
static func inputs(market: String, balance: Dictionary) -> Dictionary:
	var mk := market.to_lower()
	var done := 0
	for id in techs_of(mk):
		if Skills.is_learned(id):
			done += 1
	var second := ""
	var second_share := 0.0
	for m in Markets.ids:
		if m == mk:
			continue
		var s := Markets.share(m)
		if s > second_share:
			second = m
			second_share = s
	return {"market": mk, "ending_id": "END_%s_%s" % [mk.to_upper(), Chains.ending_flag(mk).to_upper()], "flag": Chains.ending_flag(mk), "capstone": Skills.is_learned("%s_7" % mk.to_upper()),
		"tech_done": done, "rival_broken": Chains.rival_broken(mk), "rival_broken_bot": Chains.rival_broken_bot(mk), "second_market": second, "second_share": second_share,
		"second_over": second != "" and second_share > float(balance.get(SECOND_KEY, 0.25))}
