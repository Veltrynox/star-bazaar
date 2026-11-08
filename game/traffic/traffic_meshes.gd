extends RefCounted
## T310: the traffic ship is one flat triangle (a nose vertex and two rear vertices, in the map plane, one ship length long along -Z,
## forward is -Z like the models), plus a tiny engine-glow triangle at the tail. Built in code, no import, no textures.
## Two surfaces:
##   0 hull: UV.x = part (0 hull, 2 engine glow), UV.y = 0 at the nose to 1 at the tail (grain coordinates in the shader)
##   1 streak: crossed quads behind the engine, UV.y = 0 at the engine to 1 at the tail (stretched in traffic_streak.gdshader)
## One mesh for every kind (corvette, pirate, convoy): the colour comes from the shader (traffic_ship.gdshader). Real size comes from ship_len.

const HULL := 0.0
const ENGINE := 2.0
const STREAK_W := 0.04   # half width of a streak quad, in ship lengths (art proportion, not a tuning number)
const HALF_W := 0.32     # half width of the rear edge, in ship lengths (art proportion)

static func _tri(v: PackedVector3Array, n: PackedVector3Array, u: PackedVector2Array, i: PackedInt32Array, pts: Array, part: float, y: float) -> void:
	var k := v.size()
	for p in pts:
		v.append(Vector3(p.x, y, p.y))
		n.append(Vector3.UP)
		u.append(Vector2(part, clampf(p.y + 0.5, 0.0, 1.0)))
	i.append_array(PackedInt32Array([k, k + 2, k + 1]))  # normal up; the shader draws both sides

## The one ship mesh: hull triangle and engine-glow triangle (surface 0), streak quads behind the engine (surface 1).
static func ship() -> ArrayMesh:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var u := PackedVector2Array()
	var i := PackedInt32Array()
	_tri(v, n, u, i, [Vector2(0.0, -0.5), Vector2(-HALF_W, 0.5), Vector2(HALF_W, 0.5)], HULL, 0.0)
	_tri(v, n, u, i, [Vector2(0.0, 0.34), Vector2(-0.09, 0.5), Vector2(0.09, 0.5)], ENGINE, 0.004)
	var am := ArrayMesh.new()
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = v
	arr[Mesh.ARRAY_NORMAL] = n
	arr[Mesh.ARRAY_TEX_UV] = u
	arr[Mesh.ARRAY_INDEX] = i
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var sv := PackedVector3Array()
	var su := PackedVector2Array()
	var si := PackedInt32Array()
	for flat in [true, false]:
		var k := sv.size()
		for e in [[-1.0, 0.0], [1.0, 0.0], [1.0, 1.0], [-1.0, 1.0]]:
			var off: float = e[0] * STREAK_W
			sv.append(Vector3(off if flat else 0.0, 0.0 if flat else off, 0.5 + e[1]))
			su.append(Vector2(0.0, e[1]))
		si.append_array(PackedInt32Array([k, k + 1, k + 2, k, k + 2, k + 3]))
	var sa := []
	sa.resize(Mesh.ARRAY_MAX)
	sa[Mesh.ARRAY_VERTEX] = sv
	sa[Mesh.ARRAY_TEX_UV] = su
	sa[Mesh.ARRAY_INDEX] = si
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, sa)
	return am

static func make(_kind: String = "") -> ArrayMesh:
	return ship()

## Triangles over all surfaces of a mesh (the test and the debug readout can check the 300 budget per mesh).
static func tri_count(m: Mesh) -> int:
	var n := 0
	for s in m.get_surface_count():
		n += (m.surface_get_arrays(s)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
	return n
