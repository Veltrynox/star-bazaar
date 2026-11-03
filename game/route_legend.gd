extends HBoxContainer
## Route hints along the bottom middle of the system screen (design pack, SystemView legend): what the line colours
## and the moving dot mean. Texts come from the story loader by id, with a plain fallback until the id exists.

const StoryText := preload("res://game/story_text.gd")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", 20)
	var items := [
		["LBL_LEGEND_ENERGY", "Energy route", Ui.col("commodity_energy"), "line"],
		["LBL_LEGEND_FOOD", "Food route", Ui.col("commodity_food"), "line"],
		["LBL_LEGEND_SILK", "Silk route", Ui.commodity_col("silk"), "line"],  # T159: ids not in the story yet, plain fallback
		["LBL_LEGEND_CHIPS", "Chips route", Ui.commodity_col("chips"), "line"],
		["LBL_LEGEND_ORE", "Ore route", Ui.commodity_col("ore"), "line"],
		["LBL_LEGEND_WAITING", "Waiting for room", Ui.col("signal_warn"), "dashed"],
		["LBL_LEGEND_SHIP", "Ship", Ui.col("ink"), "ship"]]
	for it in items:
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 8)
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sw := Swatch.new()
		sw.color = it[2]
		sw.kind = str(it[3])
		h.add_child(sw)
		var l := Label.new()
		l.text = StoryText.get_or(str(it[0]), str(it[1]))
		l.theme_type_variation = "LabelSmall"
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(l)
		add_child(h)

class Swatch extends Control:
	var color: Color = Color.WHITE
	var kind := "line"  # line | dashed | ship
	func _init() -> void:
		custom_minimum_size = Vector2(22, 8)
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		var y := size.y * 0.5
		match kind:
			"dashed":
				draw_dashed_line(Vector2(0, y), Vector2(size.x, y), color, 2.0, 5.0)
			"ship":  # a dot with a fading trail, as in the design
				draw_circle(Vector2(18, y), 2.5, color)
				draw_circle(Vector2(12, y), 1.6, Color(color, 0.4))
				draw_circle(Vector2(7, y), 1.2, Color(color, 0.2))
			_:
				draw_line(Vector2(0, y), Vector2(size.x, y), color, 2.0)
