extends PanelContainer
## Space Storage view for one system: capacity and one row per commodity (rating bar, name, amount/capacity).
## Opened by a click on the station (main.gd _on_station_clicked). Close button or Esc closes it.

const StoryText := preload("res://game/story_text.gd")
const PlanetPanel := preload("res://game/planet_panel.gd")
const RatingBar := PlanetPanel.RatingBar

signal closed

var main: Control
var system_id: int = -1
var box: VBoxContainer

func setup(main_node: Control) -> void:
	main = main_node
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	custom_minimum_size = Vector2(minf(360.0, get_viewport_rect().size.x - 24.0), 0)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)

func open_for(sid: int) -> void:
	system_id = sid
	visible = true
	refresh()

func close_view() -> void:
	if visible:
		visible = false
		closed.emit()

func refresh() -> void:
	if not visible or main == null:
		return
	for ch in box.get_children():
		box.remove_child(ch)
		ch.queue_free()
	var head := HBoxContainer.new()
	box.add_child(head)
	var title := Label.new()
	title.text = StoryText.get_or("SS_POST_NAME", "Space Storage")
	title.theme_type_variation = "LabelTitle"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var close := Button.new()
	close.name = "CloseButton"
	close.text = StoryText.get_or("SS_BTN_CLOSE", "Close")
	close.pressed.connect(close_view)
	head.add_child(close)
	var sys := Label.new()
	sys.text = main.Systems.name_of(system_id)
	sys.theme_type_variation = "LabelCaption"
	box.add_child(sys)
	var key: String = main.storage.system_key(system_id)
	var cap: int = main.storage.capacity_of(key)
	var cl := Label.new()
	cl.text = StoryText.get_or("SS_LBL_CAPACITY", "Capacity: {cap} per commodity", {"cap": cap})
	box.add_child(cl)
	for c in main.commodities:
		var row := HBoxContainer.new()
		row.name = "Row_" + str(c)
		row.add_theme_constant_override("separation", 8)
		var bar := RatingBar.new()
		bar.level = main.storage.rating(key, str(c))
		row.add_child(bar)
		var l := Label.new()
		l.text = "%s  %d/%d" % [str(c).capitalize(), main.storage.amount(key, str(c)), cap]
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		var nc: Control = PlanetPanel.next_cycle_label(main, key, str(c))
		if nc != null:
			row.add_child(nc)  # right end of the same row
		box.add_child(row)
	size = Vector2.ZERO
