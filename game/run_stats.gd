class_name RunStats
extends RefCounted
## T78: local-only record of answered runs in user://stats.json. No network, no ids.
## {"schema_version":1,"runs":N,"choices":{side:N},"endings":{id:N},"tiers":{Bare|Partial|Full:N},"last":{...}}

const PATH := "user://stats.json"
const TMP := "user://stats.json.tmp"
const BAD := "user://stats.bad.json"

static func _fresh() -> Dictionary:
	return {"schema_version": 1, "runs": 0, "choices": {}, "endings": {}, "tiers": {}, "last": {}}

static func load_stats() -> Dictionary:
	if not FileAccess.file_exists(PATH):
		return _fresh()
	var f := FileAccess.open(PATH, FileAccess.READ)
	var d = JSON.parse_string(f.get_as_text()) if f != null else null
	if f != null:
		f.close()
	if typeof(d) != TYPE_DICTIONARY or typeof(d.get("choices")) != TYPE_DICTIONARY or typeof(d.get("endings")) != TYPE_DICTIONARY:
		DirAccess.rename_absolute(PATH, BAD)  # unreadable: keep it aside, start fresh
		return _fresh()
	return d

## side is RELEASE, CORP or LOSS. tier is Bare, Partial or Full for wins, "" for a loss.
static func record(side: String, ending_id: String, cycle: int, cash: int, tier: String = "") -> bool:
	var d := load_stats()
	d["runs"] = int(d.get("runs", 0)) + 1
	d["choices"][side] = int(d["choices"].get(side, 0)) + 1
	d["endings"][ending_id] = int(d["endings"].get(ending_id, 0)) + 1
	if tier != "":
		if typeof(d.get("tiers")) != TYPE_DICTIONARY:
			d["tiers"] = {}
		d["tiers"][tier] = int(d["tiers"].get(tier, 0)) + 1
	d["last"] = {"side": side, "ending": ending_id, "tier": tier, "cycle": cycle, "cash": cash}
	var f := FileAccess.open(TMP, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(d, "\t"))
	f.close()
	return DirAccess.rename_absolute(TMP, PATH) == OK

static func global_path() -> String:
	return ProjectSettings.globalize_path(PATH)
