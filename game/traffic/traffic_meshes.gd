extends RefCounted
## T277: low-poly proxies of the corvette and the pirate warship for instanced traffic, built in code (no import, no textures).
## Each mesh is one ship length long along -Z (forward is -Z, like the models), centred near the origin. Two surfaces:
##   0 hull: vertex colour = base colour, UV.x = part (0 hull, 1 cargo pod tinted per instance, 2 engine glow, 4 nav light)
##   1 streak: crossed quads behind the engines, UV.y = 0 at the engine to 1 at the tail (stretched in traffic_streak.gdshader)
## Triangle counts are far below the 300 per mesh budget (tri_count()). Real size comes from the shader (ship_len).

const HULL := 0.0
const POD := 1.0
const ENGINE := 2.0
const NAV := 4.0
const STREAK_W := 0.04   # half width of a streak quad, in ship lengths (art proportion, not a tuning number)

class Build:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var c := PackedColorArray()
	var u := PackedVector2Array()
	var i := PackedInt32Array()

	## One flat quad a,b,c,d; wound so its normal points away from `centre` (the part's inside).
	func quad(a: Vector3, b: Vector3, cc: Vector3, d: Vector3, centre: Vector3, col: Color, part: float) -> void:
		var nrm := (b - a).cross(cc - a).normalized()
		if nrm.dot((a + b + cc + d) * 0.25 - centre) < 0.0:
			var t := b
			b = d
			d = t
			nrm = -nrm
		var k := v.size()
		for p in [a, b, cc, d]:
			v.append(p)
			n.append(nrm)
			c.append(col)
			u.append(Vector2(part, 0.0))
		i.append_array(PackedInt32Array([k, k + 1, k + 2, k, k + 2, k + 3]))

	func box(ctr: Vector3, h: Vector3, col: Color, part: float) -> void:
		var q := func(sx: float, sy: float, sz: float) -> Vector3: return ctr + Vector3(h.x * sx, h.y * sy, h.z * sz)
		quad(q.call(-1, -1, -1), q.call(1, -1, -1), q.call(1, 1, -1), q.call(-1, 1, -1), ctr, col, part)
		quad(q.call(-1, -1, 1), q.call(1, -1, 1), q.call(1, 1, 1), q.call(-1, 1, 1), ctr, col, part)
		quad(q.call(-1, -1, -1), q.call(-1, -1, 1), q.call(-1, 1, 1), q.call(-1, 1, -1), ctr, col, part)
		quad(q.call(1, -1, -1), q.call(1, -1, 1), q.call(1, 1, 1), q.call(1, 1, -1), ctr, col, part)
		quad(q.call(-1, -1, -1), q.call(1, -1, -1), q.call(1, -1, 1), q.call(-1, -1, 1), ctr, col, part)
		quad(q.call(-1, 1, -1), q.call(1, 1, -1), q.call(1, 1, 1), q.call(-1, 1, 1), ctr, col, part)

	## Four-sided hull lofted through sections [z, half width, half height, y centre], closed at both ends.
	func loft(secs: Array, col: Color) -> void:
		var rings: Array = []
		for s in secs:
			var z: float = s[0]
			var w: float = s[1]
			var hh: float = s[2]
			var y: float = s[3]
			rings.append([Vector3(-w, y - hh, z), Vector3(w, y - hh, z), Vector3(w, y + hh, z), Vector3(-w, y + hh, z)])
		for r in rings.size() - 1:
			var a: Array = rings[r]
			var b: Array = rings[r + 1]
			var mid := Vector3(0, (secs[r][3] + secs[r + 1][3]) * 0.5, (secs[r][0] + secs[r + 1][0]) * 0.5)
			for k in 4:
				quad(a[k], a[(k + 1) % 4], b[(k + 1) % 4], b[k], mid, col, HULL)
		var first: Array = rings[0]
		var last: Array = rings[rings.size() - 1]
		quad(first[0], first[1], first[2], first[3], Vector3(0, secs[0][3], secs[0][0] + 1.0), col, HULL)
		var e: int = secs.size() - 1
		quad(last[0], last[1], last[2], last[3], Vector3(0, secs[e][3], secs[e][0] - 1.0), col, HULL)

	## Crossed streak quads (flat and upright) behind an engine at x, y, from z0 one ship length back.
	func streak(sv: PackedVector3Array, su: PackedVector2Array, si: PackedInt32Array, x: float, y: float, z0: float) -> void:
		for flat in [true, false]:
			var k := sv.size()
			for e in [[-1.0, 0.0], [1.0, 0.0], [1.0, 1.0], [-1.0, 1.0]]:
				var off: float = e[0] * STREAK_W
				sv.append(Vector3(x + (off if flat else 0.0), y + (0.0 if flat else off), z0 + e[1]))
				su.append(Vector2(0.0, e[1]))
			si.append_array(PackedInt32Array([k, k + 1, k + 2, k, k + 2, k + 3]))

static func _finish(b: Build, engines: Array) -> ArrayMesh:
	var am := ArrayMesh.new()
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = b.v
	arr[Mesh.ARRAY_NORMAL] = b.n
	arr[Mesh.ARRAY_COLOR] = b.c
	arr[Mesh.ARRAY_TEX_UV] = b.u
	arr[Mesh.ARRAY_INDEX] = b.i
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var sv := PackedVector3Array()
	var su := PackedVector2Array()
	var si := PackedInt32Array()
	for e in engines:
		b.streak(sv, su, si, e.x, e.y, e.z)
	var sa := []
	sa.resize(Mesh.ARRAY_MAX)
	sa[Mesh.ARRAY_VERTEX] = sv
	sa[Mesh.ARRAY_TEX_UV] = su
	sa[Mesh.ARRAY_INDEX] = si
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, sa)
	return am

## Cargo corvette: tapered hull, two short wings, a cargo pod under the belly, one engine, one nav light.
static func corvette() -> ArrayMesh:
	var b := Build.new()
	var hull := Color(0.62, 0.68, 0.76)
	var wing := Color(0.5, 0.56, 0.66)
	b.loft([[-0.5, 0.025, 0.025, 0.0], [-0.3, 0.08, 0.06, 0.0], [0.1, 0.1, 0.08, 0.0], [0.38, 0.09, 0.07, 0.0]], hull)
	b.box(Vector3(0, -0.09, 0.12), Vector3(0.065, 0.05, 0.15), Color.WHITE, POD)
	b.box(Vector3(-0.17, 0.0, 0.2), Vector3(0.08, 0.008, 0.1), wing, HULL)
	b.box(Vector3(0.17, 0.0, 0.2), Vector3(0.08, 0.008, 0.1), wing, HULL)
	b.box(Vector3(0, 0.0, 0.395), Vector3(0.06, 0.045, 0.015), Color.WHITE, ENGINE)
	b.box(Vector3(0, 0.085, -0.12), Vector3(0.015, 0.012, 0.015), Color.WHITE, NAV)
	return _finish(b, [Vector3(0, 0, 0.41)])

## Pirate raider: dark wedge, swept wings, a tail fin, two engines, one nav light (blinks red when blocked or hazard).
static func pirate() -> ArrayMesh:
	var b := Build.new()
	var hull := Color(0.42, 0.2, 0.18)
	var wing := Color(0.3, 0.14, 0.13)
	b.loft([[-0.5, 0.02, 0.02, 0.0], [-0.2, 0.09, 0.05, 0.0], [0.2, 0.12, 0.065, 0.0], [0.38, 0.09, 0.06, 0.0]], hull)
	b.box(Vector3(-0.2, 0.0, 0.12), Vector3(0.12, 0.007, 0.16), wing, HULL)
	b.box(Vector3(0.2, 0.0, 0.12), Vector3(0.12, 0.007, 0.16), wing, HULL)
	b.box(Vector3(0, 0.1, 0.28), Vector3(0.008, 0.07, 0.1), wing, HULL)
	b.box(Vector3(-0.055, 0.0, 0.395), Vector3(0.035, 0.035, 0.015), Color.WHITE, ENGINE)
	b.box(Vector3(0.055, 0.0, 0.395), Vector3(0.035, 0.035, 0.015), Color.WHITE, ENGINE)
	b.box(Vector3(0, 0.07, -0.15), Vector3(0.014, 0.012, 0.014), Color.WHITE, NAV)
	return _finish(b, [Vector3(-0.055, 0, 0.41), Vector3(0.055, 0, 0.41)])

static func make(kind: String) -> ArrayMesh:
	return pirate() if kind == "pirate" else corvette()

## Triangles over all surfaces of a mesh (the test and the debug readout can check the 300 budget per mesh).
static func tri_count(m: Mesh) -> int:
	var n := 0
	for s in m.get_surface_count():
		n += (m.surface_get_arrays(s)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
	return n
