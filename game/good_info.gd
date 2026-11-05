class_name GoodInfo
extends RefCounted
## Hover text of a resource (added to its tooltip): what it is (GOOD_<ID>_DESC) and how it is used (built from data/goods.json).
## Only things that data/availability.json shows now are named.
## GoodInfo.lines(good) gives the lines; GoodInfo.block(good) the name plus lines.
const StoryText := preload("res://game/story_text.gd")

## 1 to 4 short lines: what it is, market, made at, used in, storage. Empty for a hidden or unknown good.
static func lines(c: String) -> Array:
	var out: Array = []
	if not Goods.has(c) or not Availability.good(c):
		return out
	var e: Dictionary = Goods.entry(c)
	var desc := ""
	if StoryText.has_text("GOOD_" + c.to_upper() + "_DESC"):
		desc = StoryText.get_text("GOOD_" + c.to_upper() + "_DESC")
	if desc != "":
		out.append(desc)
	var mk := str(e.get("market", ""))
	if mk != "":
		out.append(StoryText.get_or("LBL_GOOD_MARKET", "{market} market.", {"market": StoryText.get_or("SK_TAB_" + mk.to_upper(), mk.capitalize())}))
	var ws := str(e.get("workshop", "")) if e.get("workshop") != null else ""
	if ws != "" and Availability.workshop(ws):
		var wn := StoryText.get_or("SS_FABRIC", "Fabric") if ws == "fabric" else StoryText.get_or("WS_" + ws.to_upper() + "_NAME", ws.capitalize())
		out.append(StoryText.get_or("LBL_GOOD_MADE_AT", "Made at: {workshop}.", {"workshop": wn}))
	var users: Array = []
	for id in Goods.ids():
		if Goods.recipe(str(id)).has(c) and Availability.good(str(id)):
			users.append(Ui.good_name(str(id)))
	if not users.is_empty():
		out.append(StoryText.get_or("LBL_GOOD_USED_IN", "Used in: {goods}.", {"goods": ", ".join(users)}))
	if Availability.feature("space_storage_stock_rows"):
		out.append(StoryText.get_or("LBL_GOOD_STORED", "Can be kept in Space Storage and sent on routes."))
	return out

## Tooltip block of a good: its name, then lines(). Empty for a hidden or unknown good.
static func block(c: String) -> String:
	var ls := lines(c)
	if ls.is_empty():
		return ""
	return Ui.good_name(c) + "\n" + "\n".join(PackedStringArray(ls))
