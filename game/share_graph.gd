## Pure helpers for the Competitors graph: per-cycle share series from volume histories.
## A cycle's share is the entity's volume over the last `window` cycles (ending at that cycle, or fewer at the
## start) divided by the total of the player and all bots over the same window; 0 when the total is 0.

## player: Array of volumes (index = cycle - 1). bots: Array of such arrays.
## Returns {"player": Array[float], "bots": Array of Array[float]}, one value per cycle of the player history.
static func series(player: Array, bots: Array, window: int) -> Dictionary:
	var n := player.size()
	var w := maxi(1, window)
	var out_p := []
	var out_b := []
	for _b in bots:
		out_b.append([])
	for i in n:
		var lo := maxi(0, i + 1 - w)
		var pv := _sum(player, lo, i)
		var bv := []
		var total := pv
		for b in bots:
			var v := _sum(b, lo, i)
			bv.append(v)
			total += v
		out_p.append(pv / total if total > 0.0 else 0.0)
		for k in bots.size():
			out_b[k].append(float(bv[k]) / total if total > 0.0 else 0.0)
	return {"player": out_p, "bots": out_b}

static func _sum(arr: Array, lo: int, hi: int) -> float:
	var t := 0.0
	for i in range(lo, mini(hi, arr.size() - 1) + 1):
		t += float(arr[i])
	return t

## Change in share points over the last `n` cycles: last value minus the value n cycles earlier
## (the start, 0, when the series is shorter). Empty series gives 0.
static func change(s: Array, n: int) -> float:
	if s.is_empty():
		return 0.0
	var last := float(s[s.size() - 1])
	var idx := s.size() - 1 - n
	return last - (float(s[idx]) if idx >= 0 else 0.0)
