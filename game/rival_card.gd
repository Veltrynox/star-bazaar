class_name RivalCard
extends Control
## T199: small card beside a rival scenery ship the player clicked: the competitor's name and the market where it is strongest.
## The map emits rival_clicked(bot); 0 (a click elsewhere) or a ship that is no longer drawn closes the card. Same look as DestHint.

const StoryText := preload("res://game/story_text.gd")
const CARD_OFFSET := Vector2(18, 20)

var main: Node
var bot := 0
var _panel: PanelContainer
var _label: Label

func setup(m: Node) -> void:
	main = m
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 20
	_panel = PanelContainer.new()
	_panel.name = "RivalCard"
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label = Label.new()
	_label.theme_type_variation = "LabelSmall"
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_label)
	_panel.visible = false
	add_child(_panel)
	visible = false
	m.map.rival_clicked.connect(show_bot)

## Card text: the competitor's name, then the market where its share is highest.
static func describe(b: int) -> String:
	var best := ""
	var top := 0.0
	for mk in Markets.ids:
		var sh := Markets.bot_share(b, str(mk))
		if sh > top:
			top = sh
			best = str(mk)
	var line2 := StoryText.get_or("HINT_RIVAL_NO_MARKET", "No market lead yet")
	if best != "":
		line2 = StoryText.get_or("HINT_RIVAL_MARKET", "Strongest in {market}", {"market": str(Markets.names.get(best, best))})
	return Bots.bot_name(b) + "\n" + line2

func show_bot(b: int) -> void:
	bot = b
	if b <= 0 or main == null or main.game_over:
		_hide()
		return
	_label.text = describe(b)
	_place()

func _place() -> void:
	var sp: Variant = main.rival_ships.screen_pos_of(bot)
	if sp == null:
		_hide()
		return
	var vp := get_viewport_rect().size
	var sz := _panel.get_combined_minimum_size()
	_panel.size = sz
	var p: Vector2 = (sp as Vector2) + CARD_OFFSET
	p.x = clampf(p.x, 4.0, maxf(4.0, vp.x - sz.x - 4.0))
	p.y = clampf(p.y, 4.0, maxf(4.0, vp.y - sz.y - 4.0))
	_panel.position = p
	visible = true
	_panel.visible = true

func _process(_delta: float) -> void:
	if bot > 0:
		_place()  # follows the ship while it flies

func _hide() -> void:
	bot = 0
	visible = false
	_panel.visible = false
