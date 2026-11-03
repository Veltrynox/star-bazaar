extends RefCounted
## Route offset: how far a route's straight line has to bend to get round other planets and other routes.
## Pure maths on the ground plane (x, z of the world positions). No node, no state.
## A planet within `clearance` of the segment a-b forces a detour a -> q -> b, q = the planet pushed out to `clearance`
## on the side the line lies. A route that crosses the segment is treated the same way at the crossing point.
## offset = (extra length of the detours) / (straight length), so 0.25 means the routed path is 25 percent longer.

static func _xz(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)

## Extra path length of a -> q -> b over a -> b, for an obstacle at p (clearance c) next to the segment.
static func _detour(a: Vector2, b: Vector2, p: Vector2, c: float) -> float:
	var ab := b - a
	var len2 := ab.length_squared()
	if len2 <= 0.0001:
		return 0.0
	var t := (p - a).dot(ab) / len2
	if t <= 0.0 or t >= 1.0:  # beside or behind an end: the segment never passes it
		return 0.0
	var foot := a + ab * t
	var d := p.distance_to(foot)
	if d >= c:
		return 0.0
	var away := (foot - p)
	if away.length() < 0.001:
		away = Vector2(-ab.y, ab.x)  # dead centre: bend to the left
	var q := p + away.normalized() * c
	return a.distance_to(q) + q.distance_to(b) - sqrt(len2)

## Proper crossing point of segments a-b and c-d, or null when they do not cross.
static func _cross(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> Variant:
	var r := b - a
	var s := d - c
	var den := r.cross(s)
	if absf(den) < 0.00001:
		return null
	var t := (c - a).cross(s) / den
	var u := (c - a).cross(r) / den
	if t <= 0.0 or t >= 1.0 or u <= 0.0 or u >= 1.0:
		return null
	return a + r * t

## Offset of a route a -> b (planet indexes into pos). `others` = other routes as [a, b] pairs of planet indexes.
## `skip` = planet indexes that never count (a stop the route calls at). Returns 0.0 when a or b has no position.
static func offset(a: int, b: int, pos: Array, others: Array, clearance: float, skip: Array = []) -> float:
	if a < 0 or b < 0 or a >= pos.size() or b >= pos.size() or a == b or clearance <= 0.0:
		return 0.0
	var pa := _xz(pos[a])
	var pb := _xz(pos[b])
	var len := pa.distance_to(pb)
	if len < 0.01:
		return 0.0
	var extra := 0.0
	for i in pos.size():
		if i == a or i == b or skip.has(i):
			continue
		extra += _detour(pa, pb, _xz(pos[i]), clearance)
	var seen := []
	for o in others:
		var oa := int(o[0])
		var ob := int(o[1])
		if oa < 0 or ob < 0 or oa >= pos.size() or ob >= pos.size() or oa == a or oa == b or ob == a or ob == b:
			continue  # shares an end: it meets this route at a planet, which is no crossing
		var key := "%d|%d" % [mini(oa, ob), maxi(oa, ob)]
		if seen.has(key):  # both directions or several ships on one lane cross only once
			continue
		seen.append(key)
		var x = _cross(pa, pb, _xz(pos[oa]), _xz(pos[ob]))
		if x != null:  # bend round the crossing point as if it were a planet dead on the line
			extra += _detour(pa, pb, x + (pb - pa).orthogonal().normalized() * 0.0001, clearance)
	return extra / len
