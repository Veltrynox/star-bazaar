extends Node
## Narration playback (autoload "Voice"). One player; play(id) stops the line before it. Files are
## res://assets/voice/<ID>.ogg (English) or res://assets/voice/ru/<ID>.ogg (language ru; never falls back to English), loaded on demand; a missing file or voice off is a silent no-op.
## Settings (on, volume 0..1) persist in user://settings.cfg.

const DIR := "res://assets/voice/"
const DIR_RU := "res://assets/voice/ru/"
const CFG := "user://settings.cfg"

var enabled := true
const DEFAULT_VOLUME := 0.5  # default for new installs; a saved value is kept
var volume := DEFAULT_VOLUME
var current_id := ""  # id of the line now playing, "" when none
var _player: AudioStreamPlayer
var _next := ""  # line queued to follow the current one (a tutorial _WHY line)

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)
	_player.finished.connect(_on_finished)
	var cf := ConfigFile.new()
	if cf.load(CFG) == OK:
		enabled = bool(cf.get_value("voice", "enabled", true))
		volume = clampf(float(cf.get_value("voice", "volume", DEFAULT_VOLUME)), 0.0, 1.0)
	_apply_volume()

func play(id: String, then_id: String = "") -> void:
	stop()
	if not enabled or id == "":
		return
	var path := path_for(id, Lang.current())
	if not ResourceLoader.exists(path):
		return
	var s = load(path)
	if not (s is AudioStream):
		return
	_player.stream = s
	_player.play()
	current_id = id
	_next = then_id

## File path of a line for a language code. Russian uses only the ru folder.
static func path_for(id: String, lang: String) -> String:
	return (DIR_RU if lang == "ru" else DIR) + id + ".ogg"

func _on_finished() -> void:
	var n := _next
	_next = ""
	current_id = ""
	if n != "":
		play(n)

## Stops only when the current line's id starts with prefix (a closing tutorial must not cut an event line).
func stop_prefix(prefix: String) -> void:
	if current_id.begins_with(prefix):
		stop()

func stop() -> void:
	_next = ""
	if _player != null:
		_player.stop()
	current_id = ""

func is_playing() -> bool:
	return _player != null and _player.playing

func set_enabled(on: bool) -> void:
	enabled = on
	if not on:
		stop()
	_save()

func set_volume(v: float) -> void:
	volume = clampf(v, 0.0, 1.0)
	_apply_volume()
	_save()

func _apply_volume() -> void:
	if _player != null:
		_player.volume_db = linear_to_db(maxf(volume, 0.0001))

func _save() -> void:
	var cf := ConfigFile.new()
	cf.load(CFG)
	cf.set_value("voice", "enabled", enabled)
	cf.set_value("voice", "volume", volume)
	cf.save(CFG)
