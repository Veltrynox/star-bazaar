extends RefCounted
## Where the exits between solar systems lie, on the ground plane (y = 0). One source for the exit marker (system_exit.gd)
## and the Pathfinder's flight (pathfinder.gd), so the marker and the ship always agree.
##
## The exit of system `to`, seen from system `from`, lies on the galaxy-view bearing from `from` to `to`, outside the outermost
## orbit of `from`:  origin(from) + galaxy_dir(from, to) * (outer(from) * EXIT_RADIUS_MULT + EXIT_RADIUS_PAD).
## origin = the sun of that system (main.map.sun_positions), else the middle of its planets; outer = the largest ground-plane
## distance from the origin to a planet of that system. Planets come from main.map.positions (every open system is loaded
## there); when a system has none loaded the Systems data (x, y x MAP_UNIT_SCALE) stands in.

const Systems := preload("res://game/systems.gd")
const GalaxyView := preload("res://game/galaxy_view.gd")
const MAP_UNIT_SCALE := 0.02 * 1.4  # same as map.gd (0.02 x MAP_SCALE_UP)
const EXIT_RADIUS_MULT := 1.18  # exit distance from the sun, times the outermost planet's orbit radius
const EXIT_RADIUS_PAD := 2.0  # plus this many map units

## System 1 (planets.json, always open) and every system of systems.json.
static func all_ids() -> Array:
	return [1] + Systems.ids()

## Unit direction on the ground plane from system `from` towards system `sid` in the galaxy view (galaxy screen right = map x,
## galaxy screen down = map z); ZERO when unknown or on the same slot.
static func galaxy_dir(from: int, sid: int) -> Vector3:
	var ids := all_ids()
	var kf := ids.find(from)
	var kt := ids.find(sid)
	if kf < 0 or kt < 0:
		return Vector3.ZERO
	var slots: Array = GalaxyView.SLOTS
	var d: Vector2 = (slots[kt % slots.size()] as Vector2) - (slots[kf % slots.size()] as Vector2)
	if d.length() < 0.001:
		return Vector3.ZERO
	d = d.normalized()
	return Vector3(d.x, 0.0, d.y)

## Ground-plane positions of the planets of system `sid`: the live map when loaded, else the Systems data.
static func planet_points(main: Node, sid: int) -> Array:
	var pts: Array = []
	if main != null and main.map != null:
		for i in main.map.planets.size():
			if int(main.map.planets[i].get("system", 1)) == sid and i < main.map.positions.size():
				var p: Vector3 = main.map.positions[i]
				pts.append(Vector3(p.x, 0.0, p.z))
	if pts.is_empty():
		for p in Systems.get_system(sid).get("planets", []):
			if p.has("x") and p.has("y"):
				pts.append(Vector3(float(p["x"]), 0.0, float(p["y"])) * MAP_UNIT_SCALE)
	return pts

## Middle of the bounding box of the system's planets (ground plane), or null when it has none.
static func center(main: Node, sid: int) -> Variant:
	var pts := planet_points(main, sid)
	if pts.is_empty():
		return null
	var lo: Vector3 = pts[0]
	var hi: Vector3 = pts[0]
	for p in pts:
		lo = Vector3(minf(lo.x, p.x), 0.0, minf(lo.z, p.z))
		hi = Vector3(maxf(hi.x, p.x), 0.0, maxf(hi.z, p.z))
	return (lo + hi) * 0.5

## Origin of the system's exit ring: its sun (y = 0), else the middle of its planets, else ZERO.
static func origin(main: Node, sid: int) -> Vector3:
	if main != null and main.map != null:
		var sp = main.map.sun_positions.get(sid)
		if sp != null:
			return Vector3(sp.x, 0.0, sp.z)
	var c = center(main, sid)
	return c if c != null else Vector3.ZERO

## Largest ground-plane distance from `origin` to a planet of the system.
static func outer_radius(main: Node, sid: int, origin_pt: Vector3) -> float:
	var outer := 0.0
	for pp in planet_points(main, sid):
		outer = maxf(outer, Vector2(pp.x - origin_pt.x, pp.z - origin_pt.z).length())
	return outer

## Exit point of system `from` that leads to system `to` (ground plane, y = 0). The ship leaves `from` here and appears at
## exit_point(main, to, from) in `to`. With no bearing known it is the system's origin.
static func exit_point(main: Node, from_sys: int, to_sys: int) -> Vector3:
	var o := origin(main, from_sys)
	var gd := galaxy_dir(from_sys, to_sys)
	if gd == Vector3.ZERO:
		return o
	return o + gd * (outer_radius(main, from_sys, o) * EXIT_RADIUS_MULT + EXIT_RADIUS_PAD)
