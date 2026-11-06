extends RefCounted
## Planet surface banners cut from one atlas (art/planet/planet_surface_banner_atlas.png), 3 columns, cells in IDS order.
## To add a planet: put its full-size source in art_source/planet_surface_<id>_<name>_full.png, add id to IDS and its
## lowercase name to NAMES, then run tools/make_planet_banner_atlas.gd (it reads this file) and Godot --import.

const ATLAS_PATH := "res://art/planet/planet_surface_banner_atlas.png"
const CELL := Vector2i(480, 160)  # 3:1
const COLUMNS := 3
const IDS: Array[String] = ["planet_1", "planet_2", "planet_3", "dead_1", "dead_2", "s2_p1", "s2_p2", "s2_p3", "s2_p4"]
const NAMES := {"planet_1": "voltara", "planet_2": "tillam", "planet_3": "ashgate", "dead_1": "cinderrest",
	"dead_2": "greywake", "s2_p1": "brannock", "s2_p2": "cindrel", "s2_p3": "mossfell", "s2_p4": "quillon"}
const HEIGHT := 120.0  # banner height in the panel (about 3:1 at 320 wide, a little crop at the sides)
const FADE_FROM := 0.40  # the fade into the panel starts at this fraction of the banner height
const CORNER := 9.0  # panel corner radius 10 minus its 1 px border

const SHADER_CODE := """
shader_type canvas_item;
uniform sampler2D fade : filter_linear;  // gradient: transparent at the top of the fade, panel fill colour at the bottom
uniform vec2 rect_size = vec2(320.0, 120.0);
uniform float fade_from = 0.3;
uniform float corner = 9.0;
varying vec2 pos;
void vertex() { pos = VERTEX; }
void fragment() {
	vec4 img = texture(TEXTURE, UV);
	float t = clamp((pos.y / rect_size.y - fade_from) / (1.0 - fade_from), 0.0, 1.0);
	vec4 g = texture(fade, vec2(0.5, t));
	// colour blends to the panel fill; alpha goes to 0 so the translucent panel body underneath shows with no seam
	vec3 rgb = mix(img.rgb, g.rgb, g.a);
	float a = img.a * (1.0 - g.a);
	// rounded top corners
	vec2 q = vec2(min(pos.x, rect_size.x - pos.x), pos.y);
	if (q.x < corner && q.y < corner) {
		float d = length(q - vec2(corner)) - corner;
		a *= clamp(0.5 - d, 0.0, 1.0);
	}
	COLOR = vec4(rgb, a);
}
"""

static func has(id: String) -> bool:
	return IDS.has(id)

static func region(id: String) -> Rect2:
	var i := IDS.find(id)
	if i < 0:
		return Rect2()
	return Rect2((i % COLUMNS) * CELL.x, (i / COLUMNS) * CELL.y, CELL.x, CELL.y)

static func atlas_size() -> Vector2i:
	return Vector2i(COLUMNS * CELL.x, int(ceil(float(IDS.size()) / COLUMNS)) * CELL.y)

static func texture(id: String) -> Texture2D:
	if not has(id):
		return null
	var atlas := load(ATLAS_PATH) as Texture2D
	if atlas == null:
		return null
	var t := AtlasTexture.new()
	t.atlas = atlas
	t.region = region(id)
	return t

## Banner Control for a planet, or null when it has no image. `width` is the panel's inner width (starting value for
## the shader; it follows the real size once laid out). Child "BannerImage" carries the fade shader whose `fade`
## parameter is a GradientTexture2D built from the theme's panel fill colour.
static func make(id: String, width: float = 320.0) -> Control:
	var tex := texture(id)
	if tex == null:
		return null
	var root := Control.new()
	root.name = "PlanetBanner"
	root.custom_minimum_size = Vector2(0, HEIGHT)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var img := TextureRect.new()
	img.name = "BannerImage"
	img.texture = tex
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	img.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fill := Color(0.051, 0.0627, 0.0863)
	var th := ThemeDB.get_project_theme()
	if th != null and th.get_stylebox("panel", "PanelContainer") is StyleBoxFlat:
		fill = Color((th.get_stylebox("panel", "PanelContainer") as StyleBoxFlat).bg_color, 1.0)
	var grad := Gradient.new()
	grad.set_color(0, Color(fill, 0.0))
	grad.set_color(1, Color(fill, 1.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill_from = Vector2(0.5, 0.0)
	gt.fill_to = Vector2(0.5, 1.0)
	gt.width = 4
	gt.height = 64
	var sh := Shader.new()
	sh.code = SHADER_CODE
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("fade", gt)
	mat.set_shader_parameter("fade_from", FADE_FROM)
	mat.set_shader_parameter("corner", CORNER)
	mat.set_shader_parameter("rect_size", Vector2(width, HEIGHT))
	img.material = mat
	img.resized.connect(func(): mat.set_shader_parameter("rect_size", img.size))
	root.add_child(img)
	return root
