extends Node3D
## T132: the 3D sun. Plays the 64 cut frames of the solar flare sheet (art/sun/frames, made by
## tools/cut_sun.gd) on 12 flat grid planes (a shell around the centre, each at its own yaw and pitch, each cropping its own part of the frame), and sets the global shader parameter sun_flare from the brightness of
## the current frame. The planets' shader reads sun_flare, so the flares light the planets.
## Owner item 11 (2026-10-31). Frame rate and the flare response are below.

const FRAME_COUNT := 64
const FRAME_PATH := "res://art/sun/frames/sun_flare_%02d.png"
const FPS := 12.0          # flare animation speed, frames per second
const FLARE_SMOOTH := 6.0  # how fast sun_flare follows the frame brightness (per second)

var radius := 0.75
var key_light: DirectionalLight3D  # optional: the map's key light, lit a little by the flare too

var frame_pos := 0.0
var flare := 0.0
var flare_levels: Array = []  # 0..1 per frame, from the brightest frame
var _planes: Array = []  # [{pivot, quad, mat, spin}]
var _mats: Array = []
var _shader: Shader

const PLANES := 12          # grid planes in the shell (12 draw calls)
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
		mat.set_shader_parameter("phase", fposmod(float(i) * 64.0 * golden, 64.0))
		# Each plane crops a different part of the frame: centre and size from golden-ratio sequences.
		mat.set_shader_parameter("uv_center", Vector2(0.5 + (fposmod(float(i) * golden, 1.0) - 0.5) * 0.36, 0.5 + (fposmod(float(i) * golden * golden + 0.3, 1.0) - 0.5) * 0.36))
		mat.set_shader_parameter("uv_scale", 0.5 + fposmod(float(i) * 0.37, 1.0) * 0.12)
		mat.set_shader_parameter("uv_rot", TAU * fposmod(float(i) * golden * 2.0, 1.0))
		quad.material_override = mat
		pivot.add_child(quad)
		_mats.append(mat)
		_planes.append({"pivot": pivot, "quad": quad, "qm": qm, "dir_i": i, "spin": (0.04 + 0.03 * float(i % 4)) * (1.0 if i % 2 == 0 else -1.0)})
	_layout()
	RenderingServer.global_shader_parameter_set("sun_flare", 0.0)

func set_radius(r: float) -> void:
	radius = r
	_layout()

## Sizes the planes and sets them a little off the centre along their facing, so they read as shell layers.
func _layout() -> void:
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
	var target: float = flare_levels[int(frame_pos) % FRAME_COUNT] if flare_levels.size() == FRAME_COUNT else 0.0
	flare = lerpf(flare, target, clampf(delta * FLARE_SMOOTH, 0.0, 1.0))
	RenderingServer.global_shader_parameter_set("sun_flare", flare)
	if key_light != null:
		key_light.light_energy = lerpf(1.0, 1.5, flare)

## Loads the 64 frames as one array texture and works out each frame's brightness (flare level).
func _load_frames() -> Texture2DArray:
	var imgs: Array[Image] = []
	var lum: Array = []
	for i in FRAME_COUNT:
		var img: Image = (load(FRAME_PATH % i) as Texture2D).get_image()
		img.convert(Image.FORMAT_RGBA8)
		imgs.append(img)
		lum.append(_brightness(img))
	var lo: float = lum.min()
	var hi: float = lum.max()
	flare_levels = []
	for v in lum:
		flare_levels.append(0.0 if hi <= lo else (float(v) - lo) / (hi - lo))
	var arr := Texture2DArray.new()
	arr.create_from_images(imgs)
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
