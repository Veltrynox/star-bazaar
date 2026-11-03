extends PanelContainer
## Market share readout: one row per market with the player's share bar (50% mark), the bot shares,
## the hold streak and the spreading cost. Opened from the top bar chip or M. Does not pause the game.
## Texts come from StoryText by id; the fallbacks are plain (ids listed in the handoff).

const StoryText := preload("res://game/story_text.gd")

signal closed

## Draws the player's share as a bar with a mark at the win share.
class ShareBar extends Control:
	var value := 0.0
	var mark := 0.5
	func _init() -> void:
		custom_minimum_size = Vector2(0, 14)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Ui.col("panel_200"))
		draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * clampf(value, 0.0, 1.0), size.y)), Ui.col("signal_good") if value > mark else Ui.col("star_warm"))
		var x := size.x * mark
		draw_line(Vector2(x, -2), Vector2(x, size.y + 2), Ui.col("ink_muted"), 2.0)

var main: Control
var _root: VBoxContainer
var _rows: Dictionary = {}  # market id -> {pct, bar, bots, hold}
var _spread: Label

## Whole percent text of a 0..1 share.
static func pct_text(s: float) -> String:
	return "%d%%" % roundi(s * 100.0)

## Chip text: "Military 34%", or a dash while the player has no volume. best is Markets.best().
static func chip_text(best: Dictionary, names: Dictionary) -> String:
	var m := str(best.get("market", ""))
	if m == "":
		return "-"
	return "%s %s" % [names.get(m, m), pct_text(float(best.get("share", 0.0)))]

## "Name 12%  Name 20%  Name 8%" for the bots in one market.
static func bots_text(market: String) -> String:
	var parts := []
	for b in Bots.IDS:
		parts.append("%s %s" % [Bots.bot_name(b), pct_text(Markets.bot_share(b, market))])
	return "   ".join(parts)

func setup(main_node: Control) -> void:
	main = main_node
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	custom_minimum_size = Vector2(minf(560.0, get_viewport_rect().size.x - 24.0), 0)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	_root = VBoxContainer.new()
	_root.add_theme_constant_override("separation", 10)
	Ui.scroll_wrap(self, _root, 24.0)
	var head := HBoxContainer.new()
	_root.add_child(head)
	var title := Label.new()
	title.text = StoryText.get_or("LBL_SHARE_TITLE", "Market share")
	title.theme_type_variation = "LabelTitle"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var close := Button.new()
	close.text = StoryText.get_or("SK_BTN_CLOSE", "Close")
	close.pressed.connect(close_screen)
	head.add_child(close)
	Markets.best()  # makes sure the registry is loaded
	for m in Markets.ids:
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 3)
		_root.add_child(box)
		var line := HBoxContainer.new()
		box.add_child(line)
		var name_l := Label.new()
		name_l.text = str(Markets.names.get(m, m))
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(name_l)
		var pct := Label.new()
		pct.theme_type_variation = "LabelNumber"
		line.add_child(pct)
		var bar := ShareBar.new()
		box.add_child(bar)
		var bots := Label.new()
		bots.theme_type_variation = "LabelSmall"
		bots.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(bots)
		var hold := Label.new()
		hold.theme_type_variation = "LabelSmall"
		box.add_child(hold)
		_rows[m] = {"pct": pct, "bar": bar, "bots": bots, "hold": hold}
	_spread = Label.new()
	_spread.theme_type_variation = "LabelMuted"
	_root.add_child(_spread)

func open_screen() -> void:
	visible = true
	refresh()

func close_screen() -> void:
	if visible:
		visible = false
		closed.emit()

func refresh() -> void:
	if main == null or not visible:
		return
	var win := float(main.balance.get("win_share_pct", 0.5))
	var hold_n := int(main.balance.get("win_hold_cycles", 5))
	for m in _rows:
		var r: Dictionary = _rows[m]
		var s := Markets.share(m)
		r["pct"].text = pct_text(s)
		r["bar"].value = s
		r["bar"].mark = win
		r["bar"].queue_redraw()
		r["bots"].text = bots_text(m)
		var streak := int(Markets.win_streak.get(m, 0))
		r["hold"].visible = s > win
		r["hold"].text = StoryText.get_or("LBL_SHARE_HOLD", "Held {n} of {total} cycles", {"n": streak, "total": hold_n})
	_spread.visible = Markets.n_active() > 1
	_spread.text = StoryText.get_or("LBL_SPREAD_COST", "Spreading cost per cycle: {n}", {"n": Markets.overhead()})
