extends Node3D
## T132: the 3D sun. Plays the 64 cut frames of the three solar sheets (art/sun/frames, made by
## tools/cut_sun.gd, centred by tools/sun_center) on a few flat grid planes, one sheet per plane (a shell around the centre, each at its own yaw, pitch and
## frame offset, each showing the whole frame at a slightly different scale and turn), and sets the global shader parameter sun_flare from the brightness of
## the current frame. The planets' shader reads sun_flare, so the flares light the planets.
## Owner item 11 (2026-10-31). Frame rate and the flare response are below.

const FRAME_COUNT := 64
## The three sheets: "sun_flare" (v02, a few flares), "sun_storm" (v01, strongest flares), "sun_calm" (v03, almost none).
## One array texture holds all 192 frames: layer = sheet index * 64 + frame.
const SETS := ["sun_flare", "sun_storm", "sun_calm"]
## Sheet of each plane (index into SETS): storm, flare, calm, flare, storm, calm, storm, flare. Planes that share a sheet get
## phases 15+ frames apart (see _phase), so repeats never show the same frame at the same time.
const PLANE_SETS := [1, 0, 2, 0, 1, 2, 1, 0]
const FRAME_PATH := "res://art/sun/frames/%s_%02d.png"
const FPS := 3.0           # burn speed, frames per second; the shader blends between neighbouring frames
const FLARE_SMOOTH := 6.0  # how fast sun_flare follows the frame brightness (per second)

## Hue of the original (orange) frames, in turns. A sun with another colour is the same grid rotated in hue.
const BASE_HUE := 0.09

var radius := 0.75
var drives_light := true  # only one sun sets the global sun_flare and the key light; the others are looks only
var sun_color := Color.from_hsv(BASE_HUE, 0.8, 1.0)  # set before add_child, or call set_sun_color after
static var _frames_cache: Texture2DArray = null
static var _levels_cache: Array = []
var key_light: DirectionalLight3D  # optional: the map's key light, lit a little by the flare too

var frame_pos := 0.0
var flare := 0.0
var flare_levels: Array = []  # 0..1 per frame, from the brightest frame
var _planes: Array = []  # [{pivot, quad, mat, spin}]
var _mats: Array = []
var _core: MeshInstance3D
var _shader: Shader

const PLANES := 8           # grid planes in the shell (8 draw calls); fewer planes keep the structure visible
const PLANE_GLOW := 0.65    # per-plane brightness (was 0.9, muted 2026-11-02); planes add up (8 x 0.65 = 5.2 at full overlap), above 1.0 feeds the glow
const CORE_VALUE := 3.0     # white core brightness at the centre (HDR, above 1.0); radius and falloff are CORE_RADIUS and CORE_FALLOFF in sun.gdshader
const PLANE_SPAN := 3.0     # plane size in sun radii (flares reach past the disc)

func _ready() -> void:
	var frames := _load_frames()
	_shader = load("res://art/sun/sun.gdshader")
	var golden := 0.61803398875
	for i in PLANES:
		# Directions spread over the sphere (Fibonacci), so every plane has its own yaw and pitch.
		var y := 1.0 - 2.0 * (float(i) + 0.5) / float(PLANES)
		var ring := sqrt(1.0 - y * y)
		var az := TAU * golden * float(i)
		var dir := Vector3(cos(az) * ring, y, sin(az) * ring)
		var pivot := Node3D.new()
		pivot.basis = Basis.looking_at(-dir, Vector3.UP if absf(y) < 0.95 else Vector3.RIGHT)
		add_child(pivot)
		var quad := MeshInstance3D.new()
		var qm := QuadMesh.new()
		quad.mesh = qm
		var mat := ShaderMaterial.new()
		mat.shader = _shader
		mat.set_shader_parameter("frames", frames)
		mat.set_shader_parameter("layer_base", float(PLANE_SETS[i] * FRAME_COUNT))  # first layer of this plane's sheet
		mat.set_shader_parameter("phase", _phase(i))
		mat.set_shader_parameter("hue_shift", hue_shift())
		mat.set_shader_parameter("glow", PLANE_GLOW)  # was never set before: the shader default 0.4 was used
		# Each plane shows the whole frame (scale 0.9..1.0), nudged a little (centre +-0.02) so the planes do not line up.
		mat.set_shader_parameter("uv_center", Vector2(0.5 + (fposmod(float(i) * golden, 1.0) - 0.5) * 0.04, 0.5 + (fposmod(float(i) * golden * golden + 0.3, 1.0) - 0.5) * 0.04))
		mat.set_shader_parameter("uv_scale", 0.9 + fposmod(float(i) * 0.37, 1.0) * 0.1)
		mat.set_shader_parameter("uv_rot", TAU * fposmod(float(i) * golden * 2.0, 1.0))
		quad.material_override = mat
		pivot.add_child(quad)
		_mats.append(mat)
		_planes.append({"pivot": pivot, "quad": quad, "qm": qm, "dir_i": i, "spin": (0.04 + 0.03 * float(i % 4)) * (1.0 if i % 2 == 0 else -1.0)})
	_core = MeshInstance3D.new()  # white core: a camera-facing quad, drawn by the same shader (core_on)
	_core.mesh = QuadMesh.new()
	var cm := ShaderMaterial.new()
	cm.shader = _shader
	cm.set_shader_parameter("frames", frames)
	cm.set_shader_parameter("core_on", 1.0)
	cm.set_shader_parameter("core_value", CORE_VALUE)
	_core.material_override = cm
	add_child(_core)
	_layout()
	if drives_light:
		RenderingServer.global_shader_parameter_set("sun_flare", 0.0)

## Hue turn from the orange frames to sun_color.
func hue_shift() -> float:
	var d := fposmod(sun_color.h - BASE_HUE, 1.0)
	return 0.0 if d < 0.0001 or d > 0.9999 else d

func set_sun_color(c: Color) -> void:
	sun_color = c
	for m in _mats:
		(m as ShaderMaterial).set_shader_parameter("hue_shift", hue_shift())

## Frame offset of plane i: golden-ratio spread, so planes sharing a sheet are 15+ frames apart (storm 0,4,6; flare 1,3,7; calm 2,5).
func _phase(i: int) -> float:
	return fposmod(float(i) * float(FRAME_COUNT) * 0.61803398875, float(FRAME_COUNT))

func set_radius(r: float) -> void:
	radius = r
	_layout()

## Sizes the planes and sets them a little off the centre along their facing, so they read as shell layers.
func _layout() -> void:
	if _core != null:
		(_core.mesh as QuadMesh).size = Vector2.ONE * radius * PLANE_SPAN
	for i in _planes.size():
		var p: Dictionary = _planes[i]
		(p["qm"] as QuadMesh).size = Vector2.ONE * radius * PLANE_SPAN
		(p["quad"] as MeshInstance3D).position = Vector3(0.0, 0.0, -radius * (0.05 + 0.06 * float(i % 3)))

func _process(delta: float) -> void:
	if _mats.is_empty():
		return
	frame_pos = fmod(frame_pos + delta * FPS, float(FRAME_COUNT))
	for m in _mats:
		(m as ShaderMaterial).set_shader_parameter("frame_pos", frame_pos)
	for p in _planes:  # slow turn of each plane in its own plane, so the layers slide over each other
		(p["pivot"] as Node3D).rotate_object_local(Vector3.FORWARD, p["spin"] * delta)
	var target := 0.0  # brightness blended between the two frames, like the picture
	if flare_levels.size() == FRAME_COUNT:
		var f0 := int(frame_pos) % FRAME_COUNT
		target = lerpf(flare_levels[f0], flare_levels[(f0 + 1) % FRAME_COUNT], frame_pos - floorf(frame_pos))
	flare = lerpf(flare, target, clampf(delta * FLARE_SMOOTH, 0.0, 1.0))
	if not drives_light:
		return
	RenderingServer.global_shader_parameter_set("sun_flare", flare)
	if key_light != null:
		key_light.light_energy = lerpf(1.0, 1.5, flare)

## Loads all 192 frames (3 sheets x 64) as one array texture and works out the flare level of the sun.
## Flare level: each plane shows its own sheet at its own phase, so the sun's brightness at burn position
## frame_pos is the mean of the brightness of the frames the planes show then (storm lifts it most, calm least).
## The 64 values of one loop are scaled to 0..1, so sun_flare keeps its full range.
func _load_frames() -> Texture2DArray:
	if _frames_cache != null:  # every sun shares one texture and one set of levels
		flare_levels = _levels_cache
		return _frames_cache
	var imgs: Array[Image] = []
	var lum: Array = []  # [sheet][frame]
	for s in SETS.size():
		var l: Array = []
		for i in FRAME_COUNT:
			var img: Image = (load(FRAME_PATH % [SETS[s], i]) as Texture2D).get_image()
			img.convert(Image.FORMAT_RGBA8)
			imgs.append(img)
			l.append(_brightness(img))
		lum.append(l)
	var mix: Array = []
	for k in FRAME_COUNT:
		var sum := 0.0
		for i in PLANES:
			var f := float(k) + _phase(i)
			var f0 := int(floorf(f)) % FRAME_COUNT
			var l: Array = lum[PLANE_SETS[i]]
			sum += lerpf(l[f0], l[(f0 + 1) % FRAME_COUNT], f - floorf(f))
		mix.append(sum / float(PLANES))
	var lo: float = mix.min()
	var hi: float = mix.max()
	flare_levels = []
	for v in mix:
		flare_levels.append(0.0 if hi <= lo else (float(v) - lo) / (hi - lo))
	var arr := Texture2DArray.new()
	arr.create_from_images(imgs)
	_frames_cache = arr
	_levels_cache = flare_levels
	return arr

## Mean brightness of an image, sampled on a grid (cheap enough to run once at start).
func _brightness(img: Image) -> float:
	var total := 0.0
	var n := 0
	var step := 4
	for y in range(0, img.get_height(), step):
		for x in range(0, img.get_width(), step):
			var c := img.get_pixel(x, y)
			total += c.r * 0.3 + c.g * 0.59 + c.b * 0.11
			n += 1
	return total / float(maxi(n, 1))
