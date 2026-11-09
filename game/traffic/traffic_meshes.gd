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

## T318: hull kinds. Every kind is a flat shape in the same hull surface; each vertex carries its kind in UV2.x and the vertex shader
## collapses the kinds a ship does not wear (no extra draw call, no per-ship node). All tails sit at z = +0.5 so the engine and streak line up.
## Shapes are lists of convex polygons (x, z), in ship lengths; sizes differ on purpose (slab short and wide, rectangle long and thin).
const KINDS := 5
const KIND_TABLE := [0, 0, 1, 2, 3, 4, 0, 2]   # 8 hash slots to a kind (triangles stay the most common); the shader holds the same table
const SHAPES := [
	[[Vector2(0.0, -0.5), Vector2(-HALF_W, 0.5), Vector2(HALF_W, 0.5)]],                                                    # 0 triangle (the old hull)
	[[Vector2(-0.3, -0.1), Vector2(0.3, -0.1), Vector2(0.3, 0.5), Vector2(-0.3, 0.5)]],                                     # 1 square
	[[Vector2(-0.13, -0.5), Vector2(0.13, -0.5), Vector2(0.13, 0.5), Vector2(-0.13, 0.5)]],                                 # 2 long rectangle
	[[Vector2(-0.46, 0.2), Vector2(0.46, 0.2), Vector2(0.46, 0.5), Vector2(-0.46, 0.5)]],                                   # 3 wide slab
	[[Vector2(-0.3, 0.1), Vector2(0.3, 0.1), Vector2(0.3, 0.5), Vector2(-0.3, 0.5)],
	 [Vector2(-0.17, -0.4), Vector2(0.17, -0.4), Vector2(0.17, 0.06), Vector2(-0.17, 0.06)]],                               # 4 stacked box (two blocks, a thin gap)
]

## Kind index from a 0..1 hash (stable per ship). Always in 0..KINDS-1.
static func kind_for(h: float) -> int:
	return KIND_TABLE[clampi(int(floor(h * 7.999)), 0, KIND_TABLE.size() - 1)]

## One convex polygon as a fan (normal up; the shader draws both sides). UV2.x = kind.
static func _poly(v: PackedVector3Array, n: PackedVector3Array, u: PackedVector2Array, u2: PackedVector2Array, i: PackedInt32Array, pts: Array, part: float, y: float, kind: int) -> void:
	var k := v.size()
	for p in pts:
		v.append(Vector3(p.x, y, p.y))
		n.append(Vector3.UP)
		u.append(Vector2(part, clampf(p.y + 0.5, 0.0, 1.0)))
		u2.append(Vector2(float(kind), 0.0))
	for j in range(1, pts.size() - 1):
		i.append_array(PackedInt32Array([k, k + j + 1, k + j]))

## The one ship mesh: every hull kind with its engine-glow triangle (surface 0), streak quads behind the engine (surface 1).
static func ship() -> ArrayMesh:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var u := PackedVector2Array()
	var u2 := PackedVector2Array()
	var i := PackedInt32Array()
	for kind in KINDS:
		for poly in SHAPES[kind]:
			_poly(v, n, u, u2, i, poly, HULL, 0.0, kind)
		_poly(v, n, u, u2, i, [Vector2(0.0, 0.34), Vector2(-0.09, 0.5), Vector2(0.09, 0.5)], ENGINE, 0.004, kind)
	var am := ArrayMesh.new()
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = v
	arr[Mesh.ARRAY_NORMAL] = n
	arr[Mesh.ARRAY_TEX_UV] = u
	arr[Mesh.ARRAY_TEX_UV2] = u2
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
