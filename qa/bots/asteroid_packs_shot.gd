extends SceneTree
## QA: screenshots of the asteroid packs (2x stretch, round rocks, 80/20 small/big) and the cluster card with "Send ore to...".
const OUT := "res://qa/reports/"

func _initialize() -> void:
	var m: Control = load("res://game/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._dismiss_preface()
	m._tut_skip()
	m.learned_skills.append("FND_PROSPECT")
	var c: Dictionary = m.clusters.list(1)[1]
	m.map.focus = Vector3(float(c["x"]), 0.0, float(c["y"])) * 0.02
	m.map.zoom = 3.0
	m.map.pitch_deg = 70.0
	m.map._update_camera()
	for i in 6:
		await process_frame
	var img := root.get_texture().get_image()
	img.save_png(OUT + "2026-11-04-asteroid-packs.png")
	var crop := img.get_region(Rect2i(880, 490, 160, 100))
	crop.resize(960, 600, Image.INTERPOLATE_LANCZOS)
	crop.save_png(OUT + "2026-11-04-asteroid-packs-crop.png")
	crop.save_png(OUT + "2026-11-04-asteroid-packs-round.png")
	var c0: Dictionary = m.clusters.list(1)[1]
	m._on_cluster_clicked(int(c0["index"]))
	for i in 3:
		await process_frame
	root.get_texture().get_image().save_png(OUT + "2026-11-04-asteroid-packs-card.png")
	quit(0)
