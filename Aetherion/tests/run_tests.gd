extends SceneTree

var failures := 0
var checks := 0
var player_script: Script


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)


func run() -> void:
	if not ResourceLoader.exists("res://scripts/player.gd"):
		push_error("Sprint 001 player controller is missing")
		quit(1)
		return
	player_script = load("res://scripts/player.gd")
	for rate in [60, 120]:
		test_movement(1.0 / rate)
	await test_map()
	print("Sprint 001: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func test_movement(dt: float) -> void:
	var p = player_script.new()
	p.update_velocity(dt, true, 1.0, false, false)
	check(p.velocity.x > 0, "Run accelerates right")
	for i in range(60):
		p.update_velocity(dt, true, 1.0, false, false)
	check(is_equal_approx(p.velocity.x, p.run_speed), "Run reaches capped speed")
	for i in range(60):
		p.update_velocity(dt, true, 0.0, false, false)
	check(is_zero_approx(p.velocity.x), "Release brakes to a stop")
	p.update_velocity(dt, true, -1.0, true, false)
	check(p.velocity.y == -p.jump_speed and p.jumps_used == 1, "Ground jump")
	p.update_velocity(dt, false, 0.0, true, false)
	check(p.velocity.y == -p.jump_speed and p.jumps_used == 2, "Double jump")
	p.velocity.y = 50
	p.update_velocity(dt, false, 0.0, true, false)
	check(p.velocity.y > 0 and p.jumps_used == 2, "Third jump rejected")
	p.update_velocity(dt, true, 0.0, false, false)
	check(p.velocity.y == -p.jump_speed, "Third press buffers into landing")
	p.reset_movement()
	p.update_velocity(dt, true, 0.0, false, false)
	p.update_velocity(dt, false, 0.0, false, false)
	p.update_velocity(dt, false, 0.0, true, false)
	check(p.jumps_used == 1 and p.velocity.y < 0, "Coyote jump preserves air jump")
	p.reset_movement()
	p.update_velocity(dt, true, 0.0, false, false)
	for i in range(30):
		p.update_velocity(dt, false, 0.0, false, false)
	p.update_velocity(dt, false, 0.0, true, false)
	check(p.jumps_used == 2, "Leaving ledge past coyote allows only one air jump")
	p.update_velocity(dt, false, 0.0, true, false)
	for i in range(30):
		p.update_velocity(dt, false, 0.0, false, false)
	p.update_velocity(dt, true, 0.0, false, false)
	check(p.velocity.y == 0, "Expired buffer does not jump on landing")
	p.update_velocity(dt, true, 0.0, true, false)
	p.update_velocity(dt, false, 0.0, false, true)
	check(p.velocity.y > -p.jump_speed * 0.6, "Early release cuts jump height")
	for i in range(180):
		p.update_velocity(dt, false, 0.0, false, false)
	check(p.velocity.y <= p.max_fall_speed, "Fall speed capped")
	p.reset_movement()
	check(p.velocity == Vector2.ZERO and p.jump_buffer_remaining == 0, "Respawn clears movement")
	p.free()


func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame


func test_map() -> void:
	var map = load("res://scenes/cinderhaven.tscn").instantiate()
	root.add_child(map)
	var p = map.get_node("Player")
	check(ProjectSettings.get_setting("display/window/size/viewport_width") == 640, "640 viewport width")
	check(ProjectSettings.get_setting("display/window/size/viewport_height") == 360, "360 viewport height")
	for action in ["move_left", "move_right", "jump", "respawn", "toggle_debug"]:
		check(InputMap.has_action(action) and not InputMap.action_get_events(action).is_empty(), "Mapped: " + action)
	await frames(60)
	check(p.is_on_floor(), "Player spawns and lands on solid ground")
	var start_x: float = p.position.x
	Input.action_press("move_right")
	await frames(30)
	Input.action_release("move_right")
	check(p.position.x > start_x + 40, "Input moves real player in scene")
	await frames(20)
	var stopped_x: float = p.position.x
	await frames(10)
	check(absf(p.position.x - stopped_x) < 0.1, "Real player stops after release")
	# Launch through the first catwalk from below, then land on its top.
	p.reset_movement()
	p.position = Vector2(310, 301)
	await frames(4)
	Input.action_press("jump")
	var highest: float = p.position.y
	for i in range(80):
		await frames(1)
		highest = minf(highest, p.position.y)
	Input.action_release("jump")
	check(highest < 211, "Jump passes through one-way platform from below")
	check(p.is_on_floor() and absf(p.position.y - 211) < 1.0, "Land on one-way platform from above")
	var camera: Camera2D = p.get_node("Camera2D")
	var camera_start := camera.get_screen_center_position()
	p.position = Vector2(1800, 300)
	p.reset_movement()
	await frames(90)
	check(camera.get_screen_center_position().x > camera_start.x + 500, "Camera follows across map")
	check(camera.get_screen_center_position().x <= 1601, "Camera respects right world limit")
	p.position = Vector2(820, 800)
	await frames(2)
	check(p.position.distance_to(map.spawn_position) < 10, "Falling into gap respawns player")
	check(p.jumps_used == 0, "Respawn restores jumps")
	check(p.get_node("Camera2D").enabled, "Tracking camera enabled")
	Input.action_press("toggle_debug")
	await frames(1)
	Input.action_release("toggle_debug")
	check(map.get_node("HUD/Debug").visible, "Debug toggle opens overlay")
	check("velocity" in map.get_node("HUD/Debug").text, "Overlay shows live diagnostics")
	Input.action_press("respawn")
	await frames(1)
	Input.action_release("respawn")
	check(p.position.distance_to(map.spawn_position) < 10, "Manual respawn input")
	map.queue_free()
	await process_frame
