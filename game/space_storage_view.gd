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
		row.add_child(Ui.good_icon(str(c), 16))
		var l := Label.new()
		l.text = "%s  %d/%d" % [Ui.good_name(str(c)), main.storage.amount(key, str(c)), cap]
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		var nc: Control = PlanetPanel.next_cycle_label(main, key, str(c))
		if nc != null:
			row.add_child(nc)  # right end of the same row
		box.add_child(row)
	_fabric_rows()
	size = Vector2.ZERO

## Fabric block, only in system 1 once MIN_1 is learned: build button with the cost, then the recipe and its status.
func _fabric_rows() -> void:
	if system_id != main.Fabric.SYSTEM or not main.has_skill("MIN_1"):
		return
	var f = main.fabric
	var unrouted: Array = [] if f.built else main.fabric_inputs_unrouted()
	var head := Label.new()
	head.name = "FabricLine"
	head.theme_type_variation = "LabelCaption"
	head.text = StoryText.get_or("SS_FABRIC", "Fabric") + ": " + f.recipe_text()
	box.add_child(head)
	if not f.built:
		var b := Button.new()
		b.name = "FabricBuild"
		b.text = StoryText.get_or("SS_FABRIC_BUILD", "Build fabric ({cost} cr)", {"cost": f.build_cost()})
		b.disabled = not main.can_build_fabric()["ok"]
		b.pressed.connect(func(): main.build_fabric(); refresh())
		box.add_child(b)
	else:
		var st := Label.new()
		st.name = "FabricStatus"
		st.text = ("made %d plate" % f.made) if f.state == "running" else (f.reason if f.state == "stalled" else "ready")
		box.add_child(st)
	var miss: Array = unrouted if not unrouted.is_empty() else _inputs_unreached(f)
	if not miss.is_empty():  # QA 2026-11-03: fabric can be built before its inputs have a route
		var ml := Label.new()
		ml.name = "FabricInputs"
		ml.theme_type_variation = "LabelCaption"
		ml.text = StoryText.get_or("SS_FABRIC_NO_INPUTS", "Missing inputs: {items}. Send them here from a dead world.", {"items": ", ".join(miss)})
		box.add_child(ml)
	var cl := Label.new()  # Null Core: plate + nullglass, one per run
	cl.name = "CoreLine"
	cl.theme_type_variation = "LabelCaption"
	cl.text = StoryText.get_or("LBL_NULL_CORE", "Null Core") + ": " + f.core_recipe_text()
	box.add_child(cl)
	if f.core_made < f.core_max():
		var cb := Button.new()
		cb.name = "CoreBuild"
		cb.text = StoryText.get_or("SS_NULL_CORE_BUILD", "Build Null Core ({cost} cr)", {"cost": f.core_cost()})
		cb.disabled = not main.can_build_core()["ok"]
		cb.pressed.connect(func(): main.build_null_core(); refresh())
		box.add_child(cb)
	else:
		var cs := Label.new()
		cs.name = "CoreStatus"
		cs.text = StoryText.get_or("LBL_NULL_CORE_BUILT", "Null Core built (one per run).")
		box.add_child(cs)


## Fabric inputs with too little stock here and no route sending them to this station: names for the panel line.
func _inputs_unreached(f) -> Array:
	var key: String = main.storage.system_key(system_id)
	var out: Array = []
	for c in f.INPUTS:
		if main.storage.amount(key, c) >= f.need_of(c):
			continue
		var fed := false
		for rec in main.engine.routes:
			if str(rec["dst"]) == key and str(rec["c"]) == c:
				fed = true
				break
		if not fed:
			out.append(c)
	return out
