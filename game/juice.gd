extends RefCounted
## Shared game-feel vocabulary (juice). Visual only: nothing here changes game state or blocks input.
## Use it as: const Juice := preload("res://game/juice.gd")
##
## Every effect runs on a named channel of one node ("panel", "press", "count", "flash", "nudge"). Starting a new
## effect on a channel first settles the old one to its rest state, so any effect can be interrupted at any time and
## still ends clean. Effects that find the node outside the tree, or motion switched off, apply the final state at once.
##
## Tunables are the constants below. `motion` scales every duration and strength together: 1.0 as designed, 0.0 off.

# ---- tunables (the owner can dial these down) ----
static var motion: float = 1.0
const ENTER_SECONDS := 0.22      # pop-ups, notices and panels fade and grow in
const EXIT_SECONDS := 0.16       # ... and fade out
const ENTER_SCALE := 0.92        # an entering pop-up starts at this scale and grows to 1.0 (back-out ease)
const EXIT_SCALE := 0.97         # a leaving pop-up shrinks to this scale while it fades
const SLIDE_PX := 10.0           # a free-placed pop-up drops in from this far above its rest spot
const PRESS_SCALE := 0.94        # button squash while held
const PRESS_IN_SECONDS := 0.06
const PRESS_OUT_SECONDS := 0.16
const COUNT_SECONDS := 0.45      # a number counts from its shown value to the new one
const FLASH_SECONDS := 0.3       # a colour flash on a changed value or a new item
const NUDGE_PX := 3.0            # a screen nudge: horizontal shake amplitude
const NUDGE_SECONDS := 0.24
const PING_SECONDS := 0.9        # a ring opens from a planet and fades
const PING_RADIUS := 56.0
const Rings := preload("res://game/juice_rings.gd")
const POP_SCALE := 1.18          # a value pop: the label swells to this scale and settles back
const POP_SECONDS := 0.22
const HOVER_SCALE := 1.04        # a button lifts to this scale under the mouse (same lift as the skill nodes)
const HOVER_SECONDS := 0.12
const COUNT_POP_SCALE := 1.1     # a counted number swells once when it goes up (cash, credits, points)
const PANEL_SCALE := 0.965       # a screen or card that opens grows from this scale (fade only when it fills the window)
const SWAP_SCALE := 0.985        # a card that stays open but shows something else settles in from this scale
const BURST_GAP := 0.14          # a second ring follows the first this much later

const NO_TINT := Color(1.0, 1.0, 1.0, 0.0)  # alpha 0 means count_to does not flash

const CH_PANEL := "panel"
const CH_PRESS := "press"
const CH_COUNT := "count"
const CH_FLASH := "flash"
const CH_NUDGE := "nudge"
const CH_POP := "pop"

const _META_TW := "juice_tw_"
const _META_RESET := "juice_reset_"
const _META_BASE := "juice_base"
const _META_OFF := "juice_off_"
const _META_SHOWN := "juice_shown"
const _META_TARGET := "juice_target"
const _META_PRESS := "juice_press_on"
const _META_HOVER := "juice_hover_on"
const _META_PANEL := "juice_panel_hooked"

## Scripts whose nodes fade and grow in whenever they become visible (their own close stays instant).
const PANEL_SCRIPTS := ["planet_panel", "hub_panel", "ship_panel", "bazaar_panel", "flagship_panel", "gig_board",
	"game_menu", "space_storage_view", "bazaar_card", "galaxy_view", "world_growth_view", "company_setup", "end_screen"]

## Pure helpers (no node needed; the headless tests call these).

## Shake offset at t in 0..1: two and a half swings that die away, never more than px, zero at both ends.
static func shake_offset(t: float, px: float) -> Vector2:
	var fade := 1.0 - clampf(t, 0.0, 1.0)
	return Vector2(sin(clampf(t, 0.0, 1.0) * TAU * 2.5) * px * fade, 0.0)

## The value a count shows at t in 0..1 (ease out cubic), rounded to a whole number.
static func count_value(from: int, to: int, t: float) -> int:
	var e := 1.0 - pow(1.0 - clampf(t, 0.0, 1.0), 3.0)
	return roundi(lerpf(float(from), float(to), e))

## Screen point of a planet on the 3D map, or null when it is not in view. `map` is the map node (camera, positions).
static func planet_screen(map, index: int) -> Variant:
	if map == null or not is_instance_valid(map) or map.camera == null:
		return null
	if index < 0 or index >= map.positions.size() or not map.planet_in_view(index):
		return null  # a planet of another system is not on this screen
	var w: Vector3 = map.positions[index]
	if map.camera.is_position_behind(w):
		return null
	return map.camera.unproject_position(w)

## ---- T274: tiny synthesized sounds (a clamp tick, a sting). Built once, played from one pooled player each. ----
## Notes are [hertz, seconds]; each note is a sine with a quick attack and an exponential fade. No audio files needed.
const TONES := {
	"clamp": [[1320.0, 0.05]],
	"sting": [[660.0, 0.07], [880.0, 0.07], [1320.0, 0.16]],
	"chime": [[523.0, 0.09], [659.0, 0.09], [784.0, 0.09], [1047.0, 0.3]],             # T300: a world reclaimed
	"raid": [[330.0, 0.07], [220.0, 0.16]],                                              # T300: raiders strike
	"scoop": [[880.0, 0.05], [1175.0, 0.09]],                                            # T300: pods scooped
	"opening": [[523.0, 0.1], [659.0, 0.1], [784.0, 0.1], [1047.0, 0.12], [1319.0, 0.4]],  # T300: the Bazaar opens
	"coin": [[1760.0, 0.035], [2349.0, 0.14]],                                          # owner 2026-11-14: a route is made (very slight)
}
const COIN_DB := -27.0
const TONE_RATE := 22050

## 16-bit mono sound of the notes, played one after the other. Pure; the headless tests call it.
static func tone_wav(notes: Array) -> AudioStreamWAV:
	var data := PackedByteArray()
	for n in notes:
		var count := int(float(n[1]) * TONE_RATE)
		for i in count:
			var t := float(i) / TONE_RATE
			var env := minf(1.0, float(i) / 80.0) * exp(-4.0 * float(i) / maxf(1.0, count))
			var v := int(clampf(sin(TAU * float(n[0]) * t) * env * 0.6, -1.0, 1.0) * 32767.0)
			data.append(v & 0xFF)
			data.append((v >> 8) & 0xFF)
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = TONE_RATE
	w.stereo = false
	w.data = data
	return w

## Plays a named tone (see TONES) at db. Silent when motion is 0 or the node is outside the tree. Never blocks.
static func play_tone(host: Node, id: String, db: float = -14.0) -> void:
	if not _active(host) or not TONES.has(id):
		return
	var root := host.get_tree().root
	var key := "juice_tone_" + id
	var pl: AudioStreamPlayer = root.get_meta(key) if root.has_meta(key) else null
	if pl == null or not is_instance_valid(pl):
		pl = AudioStreamPlayer.new()
		pl.stream = tone_wav(TONES[id])
		root.add_child(pl)
		root.set_meta(key, pl)
	pl.volume_db = db
	pl.play()

## ---- Button and planet sounds: ceramic hover tick, firmer press click, industrial hum. Noise based, built once. ----
## All levels and shapes are here. Hover is quiet on purpose; press is clearly stronger; the hum sits under everything.
const UI_HOVER_DB := -24.0
const UI_PRESS_DB := -17.0            # owner 2026-11-14: press was too sharp; lower, low-passed and quieter
const UI_HUM_DB := -31.0              # owner 2026-11-14: the planet hum is a soft ambient bed, not a machine
const UI_HOVER_COOLDOWN_MS := 50      # sweeping across a row of tiles ticks at most this often
const UI_HOVER_SECONDS := 0.03
const UI_PRESS_SECONDS := 0.08
const UI_HUM_SECONDS := 3.2
const UI_HOVER_PARTIAL_HZ := 3000.0   # the hover blip starts here and glides down (variants drift a few % around it)
const UI_PRESS_PARTIAL_HZ := 420.0    # owner 2026-11-14: heavier, less pitchy press
const UI_PRESS_BODY_HZ := 75.0        # the low sub-tick under a press
const UI_PRESS_BODY_AMP := 0.85       # how much of the press is the low thump (was 0.5)
const UI_PRESS_STEP2 := 1.15          # pitch of the second blip vs the first (was 1.5: too chirpy)
const UI_PRESS_LOWPASS := 0.12        # one-pole low-pass on the press (smaller = more muffled)
const UI_PITCH_SPREAD := 0.05         # pitch variants run from -spread to +spread
const UI_VARIANTS := 4
const HUM_BASE_HZ := 58.0
const UI_LEARN_DB := -19.0            # a skill is learned: richer than the press, still not loud
const UI_LEARN_SECONDS := 0.9
const UI_LEARN_HZ := 130.8            # base pitch of the dark power chord (C3: root, fifth, octave)
const UI_EVENT_DB := -22.0            # an event appears: quieter in feel than the press click
const UI_EVENT_SECONDS := 0.7
const UI_EVENT_HZ := 880.0            # lowest bell partial; the others sit at inharmonic ratios above it
const UI_EVENT_STEP_SECONDS := 0.045  # each further bell partial starts this much later (a quick, soft cascade)
const UI_EVENT_COOLDOWN_MS := 1500    # several events at once chime once
const AMBIENT_PATH := "res://assets/audio/ambient_space.ogg"   # made by tools/make_ambient.py
const AMBIENT_DB := -20.0             # quiet bed under the whole game; ignores the motion setting
const AMBIENT_FADE_SECONDS := 4.0
const _UI_CACHE := "juice_ui_sound_cache"

static func _pcm(samples: PackedFloat32Array) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		var v := int(clampf(samples[i], -1.0, 1.0) * 32767.0)
		data[i * 2] = v & 0xFF
		data[i * 2 + 1] = (v >> 8) & 0xFF
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = TONE_RATE
	w.stereo = false
	w.data = data
	return w

## A clean synthetic UI blip. Hover (body_hz = 0): one soft sine that glides down about 30 %, with a faint ring-mod
## shimmer (shimmer = its depth). Press (body_hz > 0): a two-step "blip-bip" with a rising FM chirp and a short
## resonant tail, plus a low sub-tick for weight. pitch scales the partials. No noise. Pure; tests may call it.
## seed_value is kept for the call signature and is unused.
static func tick_samples(seconds: float, partial_hz: float, body_hz: float, shimmer: float, pitch: float, _seed_value: int) -> PackedFloat32Array:
	var n := int(seconds * TONE_RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var ph := 0.0
	var ph_m := 0.0
	var press := body_hz > 0.0
	for i in n:
		var t := float(i) / TONE_RATE
		var p := float(i) / maxf(1.0, float(n))
		var attack := minf(1.0, float(i) / 50.0)               # about 2 ms: soft, no hard edge
		var v := 0.0
		if not press:
			var f := partial_hz * pitch * (1.0 - 0.3 * p)      # short downward sweep
			ph += TAU * f / TONE_RATE
			ph_m += TAU * f * 1.51 / TONE_RATE
			var env := attack * exp(-5.0 * p)
			v = sin(ph) * (1.0 - shimmer * 0.5 + shimmer * 0.5 * sin(ph_m)) * env * 0.4
			v += sin(ph * 2.006 + 0.4) * env * 0.03          # a faint detuned octave: a little sheen
		else:
			var step2 := p >= 0.45                              # the second, higher blip
			var lp := (p - 0.45) / 0.55 if step2 else p / 0.45
			var f2 := partial_hz * pitch * (UI_PRESS_STEP2 if step2 else 1.0) * (1.0 + 0.04 * lp)  # slight upward chirp
			ph += TAU * f2 / TONE_RATE
			ph_m += TAU * f2 * 2.0 / TONE_RATE
			var env2 := minf(1.0, lp * (0.45 if step2 else 1.0) * float(n) / 50.0) * exp(-3.2 * lp)
			v = sin(ph + 0.6 * sin(ph_m) * exp(-6.0 * lp)) * env2 * 0.3
			var tail := 0.0 if not step2 else sin(TAU * partial_hz * pitch * 3.0 * t) * exp(-9.0 * lp) * 0.06
			v += tail
			v += sin(TAU * body_hz * 2.0 * pitch * t) * exp(-12.0 * p) * 0.04  # a short, quiet low ring after the thump
			v += sin(TAU * body_hz * pitch * t) * UI_PRESS_BODY_AMP * attack * exp(-16.0 * p)  # sub-tick: the weight
		out[i] = v
	return out

## Layered sci-fi notification for a new event: four FM bell partials at inharmonic ratios in a quick soft cascade,
## a bandpassed "data shimmer" noise gliding up, a faint low pad swell for body, and a glassy tail of decaying echoes.
## Soft attack (no sharp transient). Pure; tests may call it.
static func event_samples(seconds: float, hz: float, step_seconds: float) -> PackedFloat32Array:
	var n := int(seconds * TONE_RATE)
	var dry := PackedFloat32Array(); dry.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var ratios := [1.0, 1.34, 1.82, 2.47, 3.15]
	var gains := [0.5, 0.38, 0.28, 0.2, 0.05]  # the fifth partial is one extra quiet glint
	var low := 0.0
	var band := 0.0
	for i in n:
		var t := float(i) / TONE_RATE
		var p := float(i) / maxf(1.0, float(n))
		var v := 0.0
		for k in ratios.size():
			var lt: float = t - step_seconds * float(k)
			if lt < 0.0:
				continue
			var f: float = hz * float(ratios[k])
			var env := minf(1.0, lt / 0.01) * exp(-6.0 * lt)
			v += sin(TAU * f * lt + 1.1 * sin(TAU * f * 3.5 * lt) * exp(-10.0 * lt)) * env * float(gains[k])
		# data shimmer: state-variable bandpass over noise, centre glides 1500 -> 5000 Hz
		var fc := 1500.0 + 3500.0 * p
		var fq := 2.0 * sin(PI * fc / TONE_RATE)
		var x := rng.randf_range(-1.0, 1.0)
		low += fq * band
		var high := x - low - 0.35 * band
		band += fq * high
		v += band * 0.16 * sin(PI * p) * sin(PI * p)
		# low pad swell
		v += (sin(TAU * 196.0 * t) + sin(TAU * 198.5 * t)) * 0.07 * sin(PI * p) * sin(PI * p)
		dry[i] = v
	var out := PackedFloat32Array(); out.resize(n)
	for i in n:
		var v := dry[i]
		for e in [[0.085, 0.34], [0.17, 0.22], [0.26, 0.14], [0.36, 0.08], [0.47, 0.04]]:
			var j: int = i - int(float(e[0]) * TONE_RATE)
			if j >= 0:
				v += dry[j] * float(e[1])
		var fade := minf(1.0, float(n - i) / 400.0)  # no click at the very end
		out[i] = v * 0.42 * fade
	return out

## Skill learned, dark corporate sci-fi: a vault-lock thump with a low-passed metallic clunk, two relay ticks, a low
## saw power chord (root, fifth, octave; no third) under a closing low-pass, a faint sub swell and a dark echo tail.
## Nothing bright: everything is low-passed well under 3 kHz. Pure.
static func learn_samples(seconds: float, hz: float) -> PackedFloat32Array:
	var n := int(seconds * TONE_RATE)
	var dry := PackedFloat32Array(); dry.resize(n)
	var clunk := [[210.0, 0.5], [337.0, 0.4], [561.0, 0.3], [783.0, 0.2]]  # damped inharmonic latch partials
	var y := 0.0
	for i in n:
		var t := float(i) / TONE_RATE
		var p := float(i) / maxf(1.0, float(n))
		var v := sin(TAU * 70.0 * t * (1.0 - 0.2 * minf(t * 10.0, 1.0))) * minf(1.0, t / 0.005) * exp(-12.0 * t) * 0.7  # lock-in thump
		var lt := t - 0.03
		if lt >= 0.0:
			for c in clunk:
				v += sin(TAU * float(c[0]) * lt) * exp(-45.0 * lt) * minf(1.0, lt / 0.002) * float(c[1]) * 0.35
		for rt in [0.0, 0.065]:  # two relay ticks just before the clunk (dark: short low blips)
			var rl: float = t - rt
			if rl >= 0.0 and rl < 0.02:
				v += sin(TAU * 480.0 * rl) * exp(-220.0 * rl) * 0.12
		var pt := t - 0.1
		if pt >= 0.0:
			var env := minf(1.0, pt / 0.08) * exp(-3.4 * pt)
			var chord := 0.0
			for r in [1.0, 1.5, 2.0]:  # root, fifth, octave
				var ph := fposmod(hz * float(r) * pt, 1.0)
				chord += (2.0 * ph - 1.0) * 0.5 + sin(TAU * hz * float(r) * pt) * 0.3
			var cut := 0.04 + 0.16 * exp(-4.0 * pt)  # the low-pass closes
			y += (chord - y) * cut
			v += y * env * 0.5
		v += sin(TAU * 49.0 * t) * 0.1 * sin(PI * minf(p * 1.6, 1.0))  # faint sub swell
		dry[i] = v
	var out := PackedFloat32Array(); out.resize(n)
	var e1 := 0.0
	for i in n:
		var v := dry[i]
		for e in [[0.12, 0.28], [0.24, 0.18], [0.37, 0.1]]:
			var j: int = i - int(float(e[0]) * TONE_RATE)
			if j >= 0:
				v += dry[j] * float(e[1])
		e1 += (v - e1) * 0.25  # dark overall: nothing bright survives
		out[i] = e1 * 0.55 * minf(1.0, float(n - i) / 600.0)
	return out

## Abstract industrial hum: low fundamental with detuned harmonics, slow beating, band-limited machinery noise,
## soft fade in and out. The loop-free sound is built once.
static func hum_samples(seconds: float) -> PackedFloat32Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var n := int(seconds * TONE_RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var lp := 0.0
	var lp2 := 0.0
	for i in n:
		var t := float(i) / TONE_RATE
		var p := float(i) / maxf(1.0, float(n))
		var fade := minf(1.0, p / 0.35) * minf(1.0, (1.0 - p) / 0.5)
		fade = fade * fade * (3.0 - 2.0 * fade)
		var f := HUM_BASE_HZ
		var v := sin(TAU * f * t) * 0.5
		v += sin(TAU * (f * 2.0 + 0.9) * t) * 0.28          # a slow 0.9 Hz beat against the octave
		v += sin(TAU * (f * 3.0 - 1.3) * t) * 0.16
		v += sin(TAU * (f * 4.02) * t) * 0.08
		v += sin(TAU * (f * 6.0 + 0.5 * sin(TAU * 0.3 * t)) * t) * 0.03 * (0.5 + 0.5 * sin(TAU * 0.35 * t))  # a faint wandering harmonic shimmer
		v *= 0.88 + 0.12 * sin(TAU * 0.7 * t)                # slow, gentle swell
		var white := rng.randf_range(-1.0, 1.0)
		lp += (white - lp) * 0.10
		lp2 += (lp - lp2) * 0.02
		var mach := (lp - lp2) * (0.5 + 0.5 * sin(TAU * 5.0 * t + 1.0))  # band of noise, pulsing like machinery
		v += mach * 0.2                                       # only a trace of machinery: ambient, not industrial
		out[i] = v * fade * 0.55
	return out

## One-pole low-pass (a = 0..1, smaller = darker), level kept roughly the same. Pure.
static func lowpass(samples: PackedFloat32Array, a: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(samples.size())
	var y := 0.0
	for i in samples.size():
		y += (samples[i] - y) * a
		out[i] = y * 1.6
	return out

static func _ui_streams(root: Window, kind: String) -> Array:
	var cache: Dictionary = root.get_meta(_UI_CACHE) if root.has_meta(_UI_CACHE) else {}
	if not cache.has(kind):
		var list := []
		if kind == "hum":
			list.append(_pcm(hum_samples(UI_HUM_SECONDS)))
		elif kind == "learn":
			list.append(_pcm(learn_samples(UI_LEARN_SECONDS, UI_LEARN_HZ)))
		elif kind == "event":
			list.append(_pcm(event_samples(UI_EVENT_SECONDS, UI_EVENT_HZ, UI_EVENT_STEP_SECONDS)))
		else:
			for k in UI_VARIANTS:
				var pitch := 1.0 + UI_PITCH_SPREAD * (2.0 * float(k) / float(UI_VARIANTS - 1) - 1.0)
				if kind == "hover":
					list.append(_pcm(tick_samples(UI_HOVER_SECONDS, UI_HOVER_PARTIAL_HZ, 0.0, 0.35, pitch, 11 + k)))
				else:
					list.append(_pcm(lowpass(tick_samples(UI_PRESS_SECONDS, UI_PRESS_PARTIAL_HZ, UI_PRESS_BODY_HZ, 0.0, pitch, 31 + k), UI_PRESS_LOWPASS)))
		cache[kind] = list
		root.set_meta(_UI_CACHE, cache)
	return cache[kind]

## Plays one of the pooled players (small round robin per kind) with a random pitch variant.
static func _play_ui(host: Node, kind: String, db: float, pool_size: int) -> void:
	var root := host.get_tree().root
	var streams := _ui_streams(root, kind)
	var key := "juice_ui_pool_" + kind
	var pool: Array = root.get_meta(key) if root.has_meta(key) else []
	if pool.is_empty():
		for i in pool_size:
			var np := AudioStreamPlayer.new()
			root.add_child(np)
			pool.append(np)
		root.set_meta(key, pool)
		root.set_meta(key + "_i", 0)
	var idx: int = (int(root.get_meta(key + "_i")) + 1) % pool.size() if pool_size > 1 else 0
	root.set_meta(key + "_i", idx)
	var pl: AudioStreamPlayer = pool[idx]
	if not is_instance_valid(pl):
		return
	pl.stream = streams[randi() % streams.size()]
	pl.volume_db = db
	pl.play()

## Soft ceramic tick for a mouse over an enabled button. Global cooldown; silent when motion is 0.
static func play_hover(host: Node) -> void:
	if not _active(host):
		return
	var now := Time.get_ticks_msec()
	var root := host.get_tree().root
	if root.has_meta("juice_ui_hover_at") and now - int(root.get_meta("juice_ui_hover_at")) < UI_HOVER_COOLDOWN_MS:
		return
	root.set_meta("juice_ui_hover_at", now)
	_play_ui(host, "hover", UI_HOVER_DB, 2)

## Firmer click for a pressed button.
static func play_press(host: Node) -> void:
	if _active(host):
		_play_ui(host, "press", UI_PRESS_DB, 2)

## The planet-open hum. One player: a new planet restarts it (never stacks).
static func play_hum(host: Node) -> void:
	if _active(host):
		_play_ui(host, "hum", UI_HUM_DB, 1)

## ---- T274: crates and floating numbers (dock sheet) ----

## `count` small crates fly from `from` to `to` (both in host-local coordinates), one after another, then fade out and free themselves.
## Visual only; never takes clicks. Returns at once.
static func crates(host: Control, from: Vector2, to: Vector2, count: int, secs: float, tint: Color) -> void:
	if not _active(host) or count <= 0:
		return
	var gap := _seconds(secs) * 0.5 / maxf(1.0, float(count))
	for k in count:
		var c := ColorRect.new()
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.color = tint
		c.size = Vector2(9, 9)
		c.pivot_offset = c.size * 0.5
		c.modulate.a = 0.0
		c.position = from - c.size * 0.5
		host.add_child(c)
		var tw := c.create_tween()
		var jitter := Vector2(0.0, (float(k % 3) - 1.0) * 7.0)
		tw.tween_interval(gap * k)
		tw.tween_property(c, "modulate:a", 1.0, _seconds(0.04))
		tw.tween_property(c, "position", to - c.size * 0.5 + jitter, _seconds(secs)) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tw.parallel().tween_property(c, "scale", Vector2(0.5, 0.5), _seconds(secs)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tw.tween_property(c, "modulate:a", 0.0, _seconds(0.08))
		tw.tween_callback(c.queue_free)

## A short text rises from `at` (host-local) and fades, then frees itself. For "+120" beside a counted number.
static func float_text(host: Control, text: String, at: Vector2, tint: Color, rise_px: float = 28.0, secs: float = 0.7) -> void:
	if not _active(host):
		return
	var l := Label.new()
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.text = text
	l.modulate = tint
	l.position = at
	host.add_child(l)
	var tw := l.create_tween()
	tw.tween_property(l, "position:y", at.y - rise_px * motion, _seconds(secs)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(l, "modulate:a", 0.0, _seconds(secs)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_callback(l.queue_free)

## ---- channel plumbing ----

static func _active(n: Node) -> bool:
	return motion > 0.0 and n != null and n.is_inside_tree()

static func _seconds(s: float) -> float:
	return s * motion

## Snaps a channel to rest: kills its tween and runs the reset that the last effect stored.
static func settle(n: Node, channel: String) -> void:
	var key := _META_TW + channel
	if n.has_meta(key):
		var old = n.get_meta(key)
		if old is Tween and old.is_valid():
			old.kill()
		n.remove_meta(key)
	var rk := _META_RESET + channel
	if n.has_meta(rk):
		var r: Callable = n.get_meta(rk)
		if r.is_valid():
			r.call()

## Settles the channel, stores the reset for the next settle, and returns a fresh tween bound to the node.
static func _begin(n: Node, channel: String, reset: Callable) -> Tween:
	settle(n, channel)
	n.set_meta(_META_RESET + channel, reset)
	var tw: Tween = n.create_tween()
	n.set_meta(_META_TW + channel, tw)
	return tw

## The colour a node returns to after a tint. Stored once, as RGB at full alpha (fades use alpha separately).
static func _base(c: CanvasItem) -> Color:
	if not c.has_meta(_META_BASE):
		var m := c.modulate
		c.set_meta(_META_BASE, Color(m.r, m.g, m.b, 1.0))
	return c.get_meta(_META_BASE)

## Moves a node by a transient offset: only the offset this module added is taken away again, so layout moves
## made by the game in the meantime are kept.
static func _offset(c: Control, key: String, nxt: Vector2) -> void:
	var cur: Vector2 = c.get_meta(key, Vector2.ZERO)
	c.position += nxt - cur
	c.set_meta(key, nxt)

## Scale about the centre. The pivot is set every frame, so it stays right while the control is laid out.
static func _set_scale(c: Control, s: float) -> void:
	c.pivot_offset = c.size * 0.5
	c.scale = Vector2(s, s)

static func _panel_reset(c: Control, base: Color, fade: bool) -> Callable:
	return func() -> void:
		if not is_instance_valid(c):
			return
		_offset(c, _META_OFF + CH_PANEL, Vector2.ZERO)
		c.scale = Vector2.ONE
		if fade:
			c.modulate = base

## ---- pop-ups, notices and panels ----

## Entry: fade in, grow from scale_from to 1 (back-out), and drop in from slide_px above the rest spot.
## Pass slide_px 0 for children of containers (the layout owns their position). fade false leaves alpha alone.
static func enter(c: Control, scale_from: float = ENTER_SCALE, slide_px: float = 0.0, fade: bool = true) -> void:
	var base := _base(c)
	if not _active(c):
		settle(c, CH_PANEL)
		c.visible = true
		return
	var tw := _begin(c, CH_PANEL, _panel_reset(c, base, fade))
	c.visible = true
	var s0 := 1.0 - (1.0 - scale_from) * motion
	_set_scale(c, s0)
	if fade:
		c.modulate = Color(base.r, base.g, base.b, 0.0)
	tw.set_parallel(true)
	tw.tween_method(func(v: float) -> void: _set_scale(c, v), s0, 1.0, _seconds(ENTER_SECONDS)) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if fade:
		tw.tween_property(c, "modulate:a", 1.0, _seconds(ENTER_SECONDS * 0.8)) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if slide_px != 0.0:
		var from_y := -slide_px * motion
		_offset(c, _META_OFF + CH_PANEL, Vector2(0.0, from_y))
		tw.tween_method(func(v: float) -> void: _offset(c, _META_OFF + CH_PANEL, Vector2(0.0, v)), from_y, 0.0,
			_seconds(ENTER_SECONDS)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## Exit: shrink to EXIT_SCALE and fade out, then hide (or free when then_free). on_done runs at the end
## unless the exit is interrupted by a new entry. Input is never blocked: a leaving control keeps its own
## mouse filter, so callers set MOUSE_FILTER_IGNORE on it first when it must not catch clicks.
static func leave(c: Control, then_free: bool = false, on_done: Callable = Callable()) -> void:
	var base := _base(c)
	if not _active(c):
		settle(c, CH_PANEL)
		_finish_leave(c, then_free, on_done)
		return
	var tw := _begin(c, CH_PANEL, _panel_reset(c, base, true))
	tw.set_parallel(true)
	var s1 := 1.0 - (1.0 - EXIT_SCALE) * motion
	tw.tween_method(func(v: float) -> void: _set_scale(c, v), 1.0, s1, _seconds(EXIT_SECONDS)) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(c, "modulate:a", 0.0, _seconds(EXIT_SECONDS)) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(func() -> void: _finish_leave(c, then_free, on_done))

static func _finish_leave(c: Control, then_free: bool, on_done: Callable) -> void:
	if then_free:
		c.queue_free()
	else:
		c.visible = false
	if on_done.is_valid():
		on_done.call()

## Settles a pop-up that is being replaced or stopped, without animating it (the caller sets its final state).
static func stop(c: Control) -> void:
	settle(c, CH_PANEL)

## ---- buttons ----

## Installs the press squash on every button in the tree, now and later (same pattern as Ui.install_cursors).
static func install_press(tree: SceneTree) -> void:
	if tree == null or tree.root.has_meta("juice_press"):
		return
	tree.root.set_meta("juice_press", true)
	start_ambient(tree)
	tree.node_added.connect(_press_for)
	tree.node_added.connect(_panel_for)
	_press_walk(tree.root)

static func _press_walk(n: Node) -> void:
	_press_for(n)
	_panel_for(n)
	for ch in n.get_children():
		_press_walk(ch)

static func _press_for(n: Node) -> void:
	if n is BaseButton and not n.has_meta(_META_PRESS):
		n.set_meta(_META_PRESS, true)
		var b: BaseButton = n
		b.button_down.connect(func() -> void: press(b, true))
		b.button_down.connect(func() -> void: press(b, true))
		b.mouse_entered.connect(func() -> void:
			if not b.disabled:
				play_hover(b))
		b.button_down.connect(func() -> void:
			if not b.disabled:
				play_press(b))
		b.button_up.connect(func() -> void: press(b, false))
		b.mouse_exited.connect(func() -> void: press(b, false))
		# T222: a mouse click must not leave keyboard focus on the button, or Space would press it again
		b.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and not ev.pressed:
				b.release_focus.call_deferred())

## Squash on press, spring back on release. Interrupting it keeps the current scale, so it never jumps.
static func press(b: BaseButton, down: bool) -> void:
	if not _active(b):
		return
	var c := b as Control
	if c == null:
		return
	var tw := _begin(c, CH_PRESS, Callable())
	var rest := 1.0 + (HOVER_SCALE - 1.0) * motion if b.has_meta(_META_HOVER) else 1.0
	var target := (1.0 - (1.0 - PRESS_SCALE) * motion) if down else rest
	var secs := _seconds(PRESS_IN_SECONDS if down else PRESS_OUT_SECONDS)
	tw.tween_method(func(v: float) -> void: _set_scale(c, v), c.scale.x, target, secs) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

## Hover lift: a button grows a little under the mouse and returns on exit. Shares the press channel, so a press
## squashes from the lifted size and springs back to it. Skill-screen buttons keep their own lift.
static func hover(b: BaseButton, on: bool) -> void:
	if on and (b.disabled or _in_skill_screen(b)):
		return
	if on:
		b.set_meta(_META_HOVER, true)
	elif b.has_meta(_META_HOVER):
		b.remove_meta(_META_HOVER)
	elif b.scale == Vector2.ONE:
		return
	if not _active(b):
		return
	var tw := _begin(b, CH_PRESS, Callable())
	var target := 1.0 + (HOVER_SCALE - 1.0) * motion if on else 1.0
	tw.tween_method(func(v: float) -> void: _set_scale(b, v), b.scale.x, target, _seconds(HOVER_SECONDS)) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

static func _in_skill_screen(n: Node) -> bool:
	var p := n
	while p != null:
		var sc: Script = p.get_script()
		if sc != null and sc.resource_path.ends_with("skill_screen.gd"):
			return true
		p = p.get_parent()
	return false

## ---- screens that open ----

static func _panel_for(n: Node) -> void:
	if not (n is Control) or n.has_meta(_META_PANEL):
		return
	var sc: Script = n.get_script()
	if sc == null or not PANEL_SCRIPTS.has(sc.resource_path.get_file().get_basename()):
		return
	n.set_meta(_META_PANEL, true)
	var c: Control = n
	c.visibility_changed.connect(func() -> void:
		if c.visible and c.is_visible_in_tree() and _active(c):
			var vp := c.get_viewport_rect().size
			var full := c.size.x >= vp.x * 0.9 and c.size.y >= vp.y * 0.9  # a full-window screen only fades
			enter(c, 1.0 if full else PANEL_SCALE))

## A card that stays open but now shows something else (another planet): a short settle so the change is seen.
static func swap(c: Control) -> void:
	if _active(c) and c.is_visible_in_tree():
		enter(c, SWAP_SCALE)

## ---- numbers ----

## Shows `value` in the label, formatted with fmt ("%d", "+%d", "%+d"). A change counts from the shown number to the
## new one. The first value shows at once. Safe to call every frame: the same value does nothing.
## up_tint flashes the label that colour when the number goes up (pass NO_TINT for none).
static func count_to(label: Label, value: int, fmt: String = "%d", up_tint: Color = NO_TINT) -> void:
	if not label.has_meta(_META_TARGET):
		count_from(label, value, value, fmt)
		return
	if int(label.get_meta(_META_TARGET)) == value:
		return
	var from := int(label.get_meta(_META_SHOWN, value))
	count_from(label, from, value, fmt, up_tint)

## Counts from `from` to `to`, and shows the label's text as it goes.
static func count_from(label: Label, from: int, to: int, fmt: String = "%d", up_tint: Color = NO_TINT) -> void:
	label.set_meta(_META_TARGET, to)
	if not _active(label) or from == to:
		label.set_meta(_META_SHOWN, to)
		label.text = fmt % to
		return
	var base := _base(label)
	var tw := _begin(label, CH_COUNT, func() -> void: label.modulate = base)
	tw.tween_method(func(v: float) -> void: _show_count(label, v, fmt), float(from), float(to), _seconds(COUNT_SECONDS)) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if to > from and up_tint.a > 0.0:
		label.modulate = up_tint
		pop(label, COUNT_POP_SCALE)
		tw.parallel().tween_property(label, "modulate", base, _seconds(FLASH_SECONDS)) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

static func _show_count(label: Label, v: float, fmt: String) -> void:
	var n := roundi(v)
	label.set_meta(_META_SHOWN, n)
	label.text = fmt % n

## ---- flashes, nudges and rings ----

## Colour flash: the node jumps to tint and settles back to its own colour. Used for a value that changed.
static func flash(c: CanvasItem, tint: Color, seconds: float = FLASH_SECONDS) -> void:
	var base := _base(c)
	if not _active(c):
		return
	var tw := _begin(c, CH_FLASH, func() -> void: c.modulate = base)
	c.modulate = tint
	tw.tween_property(c, "modulate", base, _seconds(seconds)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

## Value pop: a label or icon swells about its centre and settles back (out then back-out). Marks a number that
## just changed in a way the player earned or spent. Rests at scale 1.
static func pop(c: Control, strength: float = POP_SCALE) -> void:
	if not _active(c):
		return
	var tw := _begin(c, CH_POP, func() -> void: c.scale = Vector2.ONE)
	var peak := 1.0 + (strength - 1.0) * motion
	var up := _seconds(POP_SECONDS * 0.35)
	tw.tween_method(func(v: float) -> void: _set_scale(c, v), 1.0, peak, up) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_method(func(v: float) -> void: _set_scale(c, v), peak, 1.0, _seconds(POP_SECONDS * 0.65)) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## Small screen nudge: a few quick sideways shakes that die away and leave the control where it was.
static func nudge(c: Control, px: float = NUDGE_PX) -> void:
	var key := _META_OFF + CH_NUDGE
	if not _active(c):
		return
	var tw := _begin(c, CH_NUDGE, func() -> void: _offset(c, key, Vector2.ZERO))
	var amp := px * motion
	tw.tween_method(func(t: float) -> void: _offset(c, key, shake_offset(t, amp)), 0.0, 1.0, _seconds(NUDGE_SECONDS)) \
		.set_trans(Tween.TRANS_LINEAR)

## A ring opens from a screen point on `host` and fades, then frees itself. Visual only; never takes clicks.
static func ping(host: Control, at: Vector2, tint: Color) -> void:
	if not _active(host):
		return
	var ring := Ring.new()
	ring.tint = tint
	ring.position = at
	host.add_child(ring)
	var tw := ring.create_tween()
	tw.tween_method(func(t: float) -> void: ring.set_t(t), 0.0, 1.0, _seconds(PING_SECONDS)) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_callback(ring.queue_free)

## Two rings in a row from one point: a confirmed action (a route made) reads stronger than a single ring.
static func ping_burst(host: Control, at: Vector2, tint: Color) -> void:
	if not _active(host):
		return
	ping(host, at, tint)
	var tw := host.create_tween()  # bound to host: freed with it (a tree timer outlived a freed Main and called a dead capture)
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # runs while paused, as the tree timer did
	tw.tween_interval(_seconds(BURST_GAP))
	tw.tween_callback(func() -> void:
		if host.is_inside_tree():
			ping(host, at, tint))

## Points of a rounded rectangle outline, clockwise from the top-left corner start (closed: last = first).
static func rr_points(r: Rect2, rad: float, steps: int = 5) -> PackedVector2Array:
	var pts := PackedVector2Array()
	rad = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	var cs := [r.position + Vector2(rad, rad), Vector2(r.end.x - rad, r.position.y + rad), r.end - Vector2(rad, rad), Vector2(r.position.x + rad, r.end.y - rad)]
	for q in 4:
		for k in steps + 1:
			var a := PI + q * PI * 0.5 + (PI * 0.5) * float(k) / float(steps)
			pts.append(cs[q] + Vector2(cos(a), sin(a)) * rad)
	pts.append(pts[0])
	return pts

## Part of a closed polyline between fractions f0..f1 of its length (f1 may pass 1.0 and wraps).
static func sub_polyline(pts: PackedVector2Array, f0: float, f1: float) -> PackedVector2Array:
	var total := 0.0
	for i in pts.size() - 1:
		total += pts[i].distance_to(pts[i + 1])
	var out := PackedVector2Array()
	if total <= 0.0:
		return out
	var d0 := f0 * total
	var d1 := f1 * total
	var run := 0.0
	for lap in 2:
		for i in pts.size() - 1:
			var seg := pts[i].distance_to(pts[i + 1])
			var s0 := run
			var s1 := run + seg
			run = s1
			if s1 < d0 or s0 > d1 or seg <= 0.0:
				continue
			if out.is_empty():
				out.append(pts[i].lerp(pts[i + 1], clampf((d0 - s0) / seg, 0.0, 1.0)))
			out.append(pts[i].lerp(pts[i + 1], clampf((d1 - s0) / seg, 0.0, 1.0)) if s1 >= d1 else pts[i + 1])
		if run >= d1:
			break
	return out

## Layered shock ring (see juice_rings.gd).
static func draw_shock(ci: CanvasItem, c: Vector2, r0: float, r1: float, u: float, col: Color, w: float = 3.0, sparks: int = 10) -> void:
	Rings.draw_shock(ci, c, r0, r1, u, col, w, sparks)

class Ring extends Control:
	var t := 0.0
	var tint := Color.WHITE

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func set_t(v: float) -> void:
		t = v
		queue_redraw()

	func _draw() -> void:
		var col := Color(tint, 0.9)
		Rings.draw_shock(self, Vector2.ZERO, 6.0, PING_RADIUS, t, col, 2.5, 8)
		# a second, smaller ring a beat behind, and a core dot that dies fast
		Rings.draw_shock(self, Vector2.ZERO, 4.0, PING_RADIUS * 0.6, clampf((t - 0.15) / 0.85, 0.0, 1.0), Color(tint.lerp(Color.WHITE, 0.4), 0.7), 1.5, 0)
		if t < 0.35:
			draw_circle(Vector2.ZERO, 5.0 * (1.0 - t / 0.35) + 1.0, Color(1, 1, 1, 0.5 * (1.0 - t / 0.35)))

## The ambient bed: one looping player on the root, faded in once, never restarted by panels or scenes.
static func start_ambient(tree: SceneTree) -> void:
	if tree == null or tree.root.has_meta("juice_ambient") or not ResourceLoader.exists(AMBIENT_PATH):
		return
	var st = load(AMBIENT_PATH)
	if st == null:
		return
	if "loop" in st:
		st.loop = true
	var pl := AudioStreamPlayer.new()
	pl.stream = st
	pl.volume_db = -60.0
	tree.root.add_child(pl)
	tree.root.set_meta("juice_ambient", pl)
	pl.play()
	pl.create_tween().tween_property(pl, "volume_db", AMBIENT_DB, AMBIENT_FADE_SECONDS) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

## The new-event chime. One cooldown, so a burst of events chimes once. Silent when motion is 0.
static func play_event(host: Node) -> void:
	if not _active(host):
		return
	var now := Time.get_ticks_msec()
	var root := host.get_tree().root
	if root.has_meta("juice_ui_event_at") and now - int(root.get_meta("juice_ui_event_at")) < UI_EVENT_COOLDOWN_MS:
		return
	root.set_meta("juice_ui_event_at", now)
	_play_ui(host, "event", UI_EVENT_DB, 1)

## The skill-learned reward sound. Silent when motion is 0.
static func play_learn(host: Node) -> void:
	if _active(host):
		_play_ui(host, "learn", UI_LEARN_DB, 1)
