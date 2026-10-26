extends PanelContainer
## T04: read-only planet panel: abundance, shortage, prices per commodity.
## Reads a planet dictionary from data/planets.json defensively; unknown fields are ignored.
## UNKNOWN values are shown as text, never replaced with invented numbers.

var title: Label
var body: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	position = Vector2(12, 56)
	custom_minimum_size = Vector2(260, 0)
	var box := VBoxContainer.new()
	add_child(box)
	title = Label.new()
	box.add_child(title)
	body = Label.new()
	box.add_child(body)
	visible = false

func show_planet(p: Dictionary, commodities: Array) -> void:
	title.text = str(p.get("name", p.get("id", "?")))
	var lines: PackedStringArray = []
	lines.append("Abundant: " + _txt(p.get("abundant")))
	lines.append("Shortage: " + _txt(p.get("scarce")))
	lines.append("")
	lines.append("Prices:")
	var prices = p.get("base_prices")
	if typeof(prices) != TYPE_DICTIONARY:
		lines.append("  " + _txt(prices))
	else:
		for c in commodities:
			var buy = prices.get(str(c) + "_buy")
			var sell = prices.get(str(c) + "_sell")
			lines.append("  %s: buy %s, sell %s" % [str(c).capitalize(),
				_price(buy), _price(sell)])
	body.text = "\n".join(lines)
	size = Vector2.ZERO
	visible = true

func _txt(v) -> String:
	if v == null:
		return "UNKNOWN"
	return str(v).capitalize() if str(v) != "UNKNOWN" else "UNKNOWN"

func _price(v) -> String:
	return "n/a" if v == null else str(v)
