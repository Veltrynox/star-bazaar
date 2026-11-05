extends RefCounted
## T196: one step of ship motion shared by the Pathfinder and the rival ships. Pure functions, no clock of their own: the caller
## passes the time step (game time, so paused means no call and no movement). Plane x/z as Vector2(x, z). Heading is a yaw in
## the same convention as the models: yaw = atan2(-dx, -dz), forward is (-sin yaw, -cos yaw).
## Speed ramps up from rest at `accel`, brakes at `brake` so that it reaches 0 at the target (arrive and stop), the heading turns
## at most `turn` rad per time unit toward the course, and the ship only speeds up once the heading is within ALIGN of the course.

const ALIGN := 0.35          # rad (about 20 degrees): the ship holds back (brakes) while the course is further off than this
const ARRIVE_EPS := 0.01     # world units
const MAX_SUBSTEP := 0.01    # callers split larger time steps into pieces of at most this (in their own unit, see substep())

static func yaw_to(d: Vector2) -> float:
	return atan2(-d.x, -d.y)

static func forward(yaw: float) -> Vector2:
	return Vector2(-sin(yaw), -cos(yaw))

## s = {pos: Vector2, yaw: float, speed: float}; returns the same dictionary updated plus "arrived": bool.
static func step(s: Dictionary, target: Vector2, vmax: float, accel: float, brake: float, turn: float, h: float) -> Dictionary:
	var pos: Vector2 = s["pos"]
	var yaw: float = s["yaw"]
	var speed: float = s["speed"]
	var d := target - pos
	var dist := d.length()
	if dist <= ARRIVE_EPS:
		return {"pos": target, "yaw": yaw, "speed": 0.0, "arrived": true}
	var err := wrapf(yaw_to(d) - yaw, -PI, PI)
	var dturn := clampf(err, -turn * h, turn * h)
	yaw = wrapf(yaw + dturn, -PI, PI)
	err -= dturn
	var vd := vmax if absf(err) <= ALIGN else 0.0
	vd = minf(vd, sqrt(2.0 * maxf(brake, 0.0001) * dist))
	if speed < vd:
		speed = minf(vd, speed + accel * h)
	else:
		speed = maxf(vd, speed - brake * h)
	var run := speed * h
	if run >= dist:
		return {"pos": target, "yaw": yaw, "speed": 0.0, "arrived": true}
	pos += forward(yaw) * run
	return {"pos": pos, "yaw": yaw, "speed": speed, "arrived": false}
