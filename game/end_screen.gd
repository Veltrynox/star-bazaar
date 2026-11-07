extends ColorRect
## Full-screen overlay for the end screens. Texts from StoryText only.
## No close button; the game below stays stopped (main.game_over is true while this is shown).

const StoryText := preload("res://game/story_text.gd")

signal new_game_pressed
signal continue_pressed
signal menu_pressed
signal quit_pressed

func _init() -> void:
	color = Ui.col("scrim")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

func _box() -> VBoxContainer:
	for c in get_children():
		c.queue_free()
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 40
	scroll.offset_right = -40
	scroll.offset_top = 20
	scroll.offset_bottom = -20
	add_child(scroll)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(620, 0)
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)
	return box

func _label(box: Control, text: String, size: int = 0, center: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if size > 0:
		l.theme_type_variation = "LabelHero" if size >= 30 else "LabelTitle"
	if center:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(l)
	return l

## Epilogue lines of a win (core 6, up to 4): capstone, techs done, a rival that lost a tier.
## Texts by id: EPI_CAP_<MKT>, EPI_TECH_0..3, EPI_RIVAL_<MKT> ({bot}). Never a count of choices or a direction.
static func epilogue_lines(fl: Dictionary) -> Array:
	var out := []
	if fl.is_empty():
		return out
	var mk := str(fl.get("market", "")).to_upper()
	var ws := _workshop_name(str(fl.get("market", "")))
	if bool(fl.get("capstone", false)) and StoryText.has_text("EPI_CAP_" + mk):
		out.append(StoryText.get_text("EPI_CAP_" + mk))
	if StoryText.has_text("EPI_TECH_%d" % int(fl.get("tech_done", 0))):
		out.append(StoryText.get_text("EPI_TECH_%d" % int(fl.get("tech_done", 0)), {"workshop": ws}))
	if bool(fl.get("rival_broken", false)) and StoryText.has_text("EPI_RIVAL_" + mk):
		out.append(StoryText.get_text("EPI_RIVAL_" + mk, {"bot": Bots.bot_name(int(fl.get("rival_broken_bot", 1)))}))
	return out

## Name of the workshop of a market ("Smelter"), lower case in running text. Fills {workshop} in epilogue texts (T229).
static func _workshop_name(market: String) -> String:
	for id in Workshops.IDS:
		if str(Goods.workshop(id).get("market", "")) == market:
			return StoryText.get_or("WS_" + id.to_upper() + "_NAME", id).to_lower()
	return "workshop"

## Ending screen. side: "WIN", "LOSS" or "SOFT". stat is one plain line (win market and share, leading rival, best market).
## TODO story: ending texts for the Four Markets ids are not written yet; a plain stub line stands in (marked TODO story).
## The readout under the text: the market (stats.market, else the first), the player's share and the three bots.
func show_ending(ending_id: String, side: String, stats: Dictionary, stat: String = "") -> void:
	var box := _box()
	var title_id := ending_id + "_TITLE"
	if not StoryText.has_text(title_id) and ending_id.ends_with("_BAD"):
		title_id = ending_id.trim_suffix("_BAD") + "_GOOD_TITLE"
	_label(box, StoryText.get_or(title_id, ending_id), 30, true)
	var body_id := ending_id
	if not StoryText.has_text(body_id) and body_id.ends_with("_BAD"):  # no Bad text written yet: the Good text of the market stands in
		body_id = body_id.trim_suffix("_BAD") + "_GOOD"
	_label(box, StoryText.get_or(body_id, "TODO story: ending text for %s." % ending_id))
	for line in epilogue_lines(stats.get("flavour", {})):
		_label(box, line)
	if stat != "":
		_label(box, stat)
	for pair in [["END_STAT_CYCLES", "cycle"], ["END_STAT_CASH", "cash"]]:
		_label(box, "%s: %s" % [StoryText.get_text(pair[0]), str(stats.get(pair[1], 0))])
	_label(box, StoryText.get_text("END_RUN_OVER"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	var first: Button = null
	for pair in [["END_BTN_CONTINUE", continue_pressed], ["END_BTN_NEW", new_game_pressed], ["END_BTN_MENU", menu_pressed], ["END_BTN_QUIT", quit_pressed]]:
		var b := Button.new()
		if first == null:
			b.theme_type_variation = "ButtonPrimary"
		b.text = StoryText.get_or(pair[0], "Continue") if pair[0] == "END_BTN_CONTINUE" else StoryText.get_text(pair[0])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sig: Signal = pair[1]
		b.pressed.connect(func(): sig.emit())
		row.add_child(b)
		if first == null:
			first = b
	first.grab_focus()
