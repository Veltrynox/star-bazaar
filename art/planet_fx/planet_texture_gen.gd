extends SceneTree
## Bakes the planet tone map: 2048x1024 equirectangular, sampled in planet_sphere.gdshader by the surface normal.
## The noise is 3D and sampled by direction, so the pattern is one 3D field on the sphere: no seam, no pole pinch.
## Detail is in the structure: bands with contrast, round patches, and fine grain for the streak layer.
## No swirls and no storm eyes.
## Channels: R = tone (bands, patches, streaks; contrast applied), G = unused (0), B = fine grain.
## Run headless from the project folder:
##   Godot --headless --path . --script res://art/planet_fx/planet_texture_gen.gd

const W := 2048
const H := 1024
const OUT := "res://art/planet_fx/planet_sphere_tone.png"
const BAND_COUNT := 9.0

func _init() -> void:
	var t0 := Time.get_ticks_usec()
	var n_base := FastNoiseLite.new()
	n_base.seed = 7
	n_base.fractal_octaves = 5
	var n_warp := FastNoiseLite.new()
	n_warp.seed = 11
	n_warp.frequency = 1.6
	n_warp.fractal_octaves = 3
	var n_patch := FastNoiseLite.new()
	n_patch.seed = 31
	n_patch.frequency = 1.0
	n_patch.fractal_octaves = 3
	var n_detail := FastNoiseLite.new()
	n_detail.seed = 23
	n_detail.fractal_octaves = 4
	var bytes := PackedByteArray()
	bytes.resize(W * H * 3)
	var idx := 0
	for y in H:
		var phi := (float(y) + 0.5) / H * PI
		var sphi := sin(phi)
		var cphi := cos(phi)
		for x in W:
			var theta := (float(x) + 0.5) / W * TAU - PI
			var n := Vector3(sphi * sin(theta), cphi, sphi * cos(theta))
			# Bands: nine latitude bands, bent by noise, with a hard-ish profile.
			var warp := n_warp.get_noise_3dv(n) * 0.5 + 0.5
			var bands := 0.5 + 0.5 * sin((n.y + 0.12 * (warp - 0.5)) * BAND_COUNT * PI)
			bands = smoothstep(0.2, 0.8, bands)
			# Patches: round mid-scale shapes, sharp edges.
			var patch := smoothstep(0.55, 0.7, n_patch.get_noise_3dv(n * 2.2) * 0.5 + 0.5)
			# Streaks: noise stretched along the bands.
			var streak := n_base.get_noise_3dv(n * Vector3(2.0, 9.0, 2.0)) * 0.5 + 0.5
			var tone := clampf(0.4 * bands + 0.35 * patch + 0.5 * (streak - 0.5) + 0.25, 0.0, 1.0)
			tone = smoothstep(0.15, 0.9, tone)  # contrast in the features
			var grain := n_detail.get_noise_3dv(n * 60.0) * 0.5 + 0.5
			bytes[idx] = int(tone * 255.0)
			bytes[idx + 1] = 0
			bytes[idx + 2] = int(grain * 255.0)
			idx += 3
	var t1 := Time.get_ticks_usec()
	var img := Image.create_from_data(W, H, false, Image.FORMAT_RGB8, bytes)
	var err := img.save_png(ProjectSettings.globalize_path(OUT))
	var t2 := Time.get_ticks_usec()
	print("planet tone map ", W, "x", H, " saved: ", err == OK)
	print("generate ms: ", (t1 - t0) / 1000.0, "  encode+save ms: ", (t2 - t1) / 1000.0)
	quit()
