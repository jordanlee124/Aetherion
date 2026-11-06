extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	root.add_child(load("res://scenes/cinderhaven.tscn").instantiate())
	for i in range(60):
		await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://builds")
	var result := root.get_texture().get_image().save_png("res://builds/sprint_001.png")
	quit(0 if result == OK else 1)
