extends SceneTree
## QA-only headless check of the T132 sun script (not a visual check). Reads the sun's own flare value,
## because the RenderingServer global parameter is not readable under the headless renderer.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var sun = load("res://art/sun/sun_flare.gd").new()
	root.add_child(sun)
	var lo := 9.0
	var hi := -9.0
	var last_pos := 0.0
	var pos_steps := 0
	for i in 240:
		await process_frame
		lo = minf(lo, sun.flare)
		hi = maxf(hi, sun.flare)
		if sun.frame_pos != last_pos:
			pos_steps += 1
		last_pos = sun.frame_pos
	print("SUNCHK flare_min=%.3f flare_max=%.3f frame_pos_now=%.2f frame_pos_changes=%d levels=%d" % [lo, hi, sun.frame_pos, pos_steps, sun.flare_levels.size()])
	quit(0)
