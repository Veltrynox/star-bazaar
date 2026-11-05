extends Node
## Localisation setting (autoload "Lang"). "en" or "ru", persisted in user://settings.cfg section "game", key "language".
## Only event texts (EV_, EV<digit>, BE<digit>, CH_), tutorial and warning texts (TUT_G<digit>*, TUT_GALAXY_*, WARN_) and the menu and screen texts (MENU_, SCR_, END_, EPI_) follow it; the rest of the interface stays English (see StoryText.in_ru_scope).

signal changed(code: String)

const CFG := "user://settings.cfg"
const CODES := ["en", "ru"]

var _code := "en"

func _ready() -> void:
	reload()

## Reads the setting from the settings file again (default "en"). Does not emit unless the language changed.
func reload() -> void:
	var cf := ConfigFile.new()
	var c := "en"
	if cf.load(CFG) == OK:
		c = str(cf.get_value("game", "language", "en"))
	_apply(c if c in CODES else "en")

func current() -> String:
	return _code

func is_ru() -> bool:
	return _code == "ru"

## Saves immediately and applies at once.
func set_language(code: String) -> void:
	if not (code in CODES):
		return
	var cf := ConfigFile.new()
	cf.load(CFG)
	cf.set_value("game", "language", code)
	cf.save(CFG)
	_apply(code)

func _apply(code: String) -> void:
	var was := _code
	_code = code
	var st = load("res://game/story_text.gd")
	st.set_language(code)
	if was != code:
		changed.emit(code)
