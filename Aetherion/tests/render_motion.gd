extends SceneTree

# Run with a renderer: godot --path . --script res://tests/render_motion.gd --fixed-fps 144
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var map = load("res://scenes/cinderhaven.tscn").instantiate()
	root.add_child(map)
	# A test-only marker measures rendered motion independently of player artwork.
	var marker := Polygon2D.new()
	marker.polygon = PackedVector2Array([Vector2(-2, -2), Vector2(2, -2), Vector2(2, 2), Vector2(-2, 2)])
	marker.color = Color.MAGENTA
	marker.z_index = 10
	map.get_node("Player").add_child(marker)
	for i in range(100):
		await process_frame
	Input.action_press("move_right")
	var positions: Array[int] = []
	for i in range(60):
		await RenderingServer.frame_post_draw
		var shot := root.get_texture().get_image()
		var left := 640
		for y in range(210, 245):
			for x in range(80, 240):
				if shot.get_pixel(x, y).is_equal_approx(Color.MAGENTA):
					left = mini(left, x)
		positions.append(left)
	Input.action_release("move_right")
	var repeats := 0
	var max_step := 0
	for i in range(10, positions.size()):
		if positions[i] == positions[i - 1]:
			repeats += 1
		max_step = maxi(max_step, absi(positions[i] - positions[i - 1]))
	var passed := not positions.has(640) and repeats <= 5 and max_step <= 2
	print("Rendered motion at 144fps / 60Hz physics: repeated frames=%d, max pixel step=%d, %s" % [repeats, max_step, "PASS" if passed else "FAIL"])
	quit(0 if passed else 1)
