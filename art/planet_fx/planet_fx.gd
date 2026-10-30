@tool
extends Node2D
## Sun lens overlay for the planet. The 3D sphere is in planet_sphere.tscn; this node only holds the lens layer.
## Rarity, palette and sun direction feed the lens. Layer name and placement stay as they are.

## Palette presets: deep and mid for the body, pale for the lit surface, rim for the inside edge, glow for the atmosphere and lens.
const PRESETS := {
	"violet": {"deep": Color("1A1247"), "mid": Color("6C44E0"), "pale": Color("C8B8FF"), "rim": Color("C9B8FF"), "glow": Color("7355FF")},
	"blue": {"deep": Color("0B1B3D"), "mid": Color("1F5FB8"), "pale": Color("8FC3FF"), "rim": Color("B5E0FF"), "glow": Color("3D9BFF")},
	"magenta": {"deep": Color("2A0A2E"), "mid": Color("8E2A9C"), "pale": Color("F0A6FF"), "rim": Color("FFC8FF"), "glow": Color("E040FF")},
	"ice": {"deep": Color("101A2A"), "mid": Color("5C7AA6"), "pale": Color("E0F0FF"), "rim": Color("FFFFFF"), "glow": Color("9CC8FF")},
	"neutral": {"deep": Color("161A22"), "mid": Color("4A5566"), "pale": Color("C8D0DC"), "rim": Color("E6ECF5"), "glow": Color("8FA0B8")},
}

## Base palette for each planet type. Violet is kept for the top rarity tier only.
const TYPE_PALETTE := {"temperate": "blue", "volcanic": "magenta", "barren": "ice"}
const TOP_TIER := 0.9   ## rarity at or above this uses the violet preset
const VIOLET_PRESET := "violet"

@export var planet_type: String = "temperate":
	set(v):
		planet_type = v
		_apply()

## 0 common, 1 rarest. Sets the palette tier and the lens strength.
@export_range(0.0, 1.0) var rarity: float = 0.0:
	set(v):
		rarity = v
		_apply()

## Direction to the sun in screen space. Wire it from the sphere's key_dir when the lens is placed.
@export var sun_dir: Vector2 = Vector2(-0.6, -0.8):
	set(v):
		sun_dir = v
		_apply()

## Camera offset in planet radii. Kept for the game callers; the sphere surface does not use it, so the lens ignores it.
@export var view_offset: Vector2 = Vector2.ZERO:
	set(v):
		view_offset = v
		_apply()

## The one palette rule: top-tier rarity is violet, otherwise the planet type's palette, otherwise neutral.
static func palette_name(type: String, rarity_value: float) -> String:
	if rarity_value >= TOP_TIER:
		return VIOLET_PRESET
	return TYPE_PALETTE.get(type, "neutral")

func _ready() -> void:
	# The .tres material is shared, so each instance gets its own copy before it sets parameters.
	if not Engine.is_editor_hint():
		var node := get_node_or_null("Lens") as ColorRect
		if node and node.material:
			node.material = node.material.duplicate()
	_apply()

func _apply() -> void:
	if not is_inside_tree():
		return
	var p: Dictionary = PRESETS[palette_name(planet_type, rarity)]
	var node := get_node_or_null("Lens") as ColorRect
	if node and node.material:
		node.material.set_shader_parameter("lens_col", p.glow)
		node.material.set_shader_parameter("ghost_col", p.rim)
		node.material.set_shader_parameter("sun_dir", sun_dir)
		node.material.set_shader_parameter("rarity", rarity)
