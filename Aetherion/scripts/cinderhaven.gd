extends Node2D

const GROUND := [Rect2(0, 320, 760, 220), Rect2(880, 320, 1040, 220)]
const CATWALKS := [Rect2(240, 225, 160, 10), Rect2(450, 155, 150, 10),
	Rect2(650, 230, 100, 10), Rect2(900, 225, 130, 10),
	Rect2(1090, 150, 150, 10), Rect2(1290, 70, 160, 10), Rect2(1540, 225, 200, 10)]
const spawn_position := Vector2(96, 286)

@onready var player: CharacterBody2D = $Player
@onready var debug_label: Label = $HUD/Debug


func _ready() -> void:
	for rect in GROUND:
		add_platform(rect, false)
	for rect in CATWALKS:
		add_platform(rect, true)
	add_platform(Rect2(-20, -180, 20, 720), false)
	add_platform(Rect2(1920, -180, 20, 720), false)
	respawn()


func add_platform(rect: Rect2, one_way: bool) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	body.collision_layer = 1
	body.collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	collision.one_way_collision = one_way
	collision.one_way_collision_margin = 4.0
	body.add_child(collision)
	add_child(body)


func _physics_process(_delta: float) -> void:
	if player.position.y > 650 or Input.is_action_just_pressed("respawn"):
		respawn()
	if Input.is_action_just_pressed("toggle_debug"):
		debug_label.visible = not debug_label.visible
	if debug_label.visible:
		debug_label.text = "FPS %d  |  %s\nposition %.1f, %.1f  velocity %.1f, %.1f\njumps %d/2  coyote %.3fs  buffer %.3fs" % [
			Engine.get_frames_per_second(), "GROUNDED" if player.is_on_floor() else "AIRBORNE",
			player.position.x, player.position.y, player.velocity.x, player.velocity.y,
			player.jumps_used, player.coyote_remaining, player.jump_buffer_remaining]


func respawn() -> void:
	player.position = spawn_position
	player.reset_movement()
	player.reset_physics_interpolation()
	player.get_node("Camera2D").reset_smoothing()


func _draw() -> void:
	draw_rect(Rect2(0, -180, 1920, 720), Color("101e30"))
	for x in range(40, 1920, 140):
		draw_rect(Rect2(x, 70 + (x % 3) * 25, 72, 250), Color("172a3a"))
		draw_rect(Rect2(x + 26, 45 + (x % 3) * 25, 20, 30), Color("172a3a"))
		for y in range(115, 290, 40):
			draw_rect(Rect2(x + 16, y, 8, 12), Color("244759"))
	# A placeholder Arcane Engine anchors the yard's magitech theme.
	draw_circle(Vector2(1650, 160), 66, Color("243d4d"))
	draw_arc(Vector2(1650, 160), 52, 0, TAU, 48, Color("bc9358"), 5)
	draw_circle(Vector2(1650, 160), 25, Color("69d9dc"))
	for rect in GROUND:
		draw_rect(rect, Color("263844"))
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 5)), Color("bd955e"))
		for x in range(int(rect.position.x) + 12, int(rect.end.x), 32):
			draw_rect(Rect2(x, 338, 16, 2), Color("3d525b"))
	for rect in CATWALKS:
		draw_rect(rect, Color("365264"))
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 3)), Color("73ded9"))
		for x in range(int(rect.position.x) + 8, int(rect.end.x), 24):
			draw_rect(Rect2(x, rect.position.y + 5, 3, 3), Color("b7a078"))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(230, 205), "01 / JUMP THROUGH", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("91bfc7"))
	draw_string(font, Vector2(648, 290), "02 / MIND THE GAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("d3ad74"))
	draw_string(font, Vector2(1100, 130), "03 / DOUBLE JUMP", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("91bfc7"))
	draw_string(font, Vector2(1550, 300), "ARCANE ENGINE / TEST LIMIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("d3ad74"))
