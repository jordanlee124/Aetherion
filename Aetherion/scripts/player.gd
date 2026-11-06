extends CharacterBody2D

@export var run_speed := 180.0
@export var acceleration := 1400.0
@export var braking := 1800.0
@export var gravity := 1100.0
@export var jump_speed := 480.0
@export var max_fall_speed := 600.0
@export var coyote_time := 0.10
@export var jump_buffer_time := 0.12

var coyote_remaining := 0.0
var jump_buffer_remaining := 0.0
var jumps_used := 0
var facing := 1.0


func _physics_process(delta: float) -> void:
	update_velocity(delta, is_on_floor(), Input.get_axis("move_left", "move_right"),
		Input.is_action_just_pressed("jump"), Input.is_action_just_released("jump"))
	move_and_slide()
	queue_redraw()


func update_velocity(delta: float, grounded: bool, axis: float, pressed: bool, released: bool) -> void:
	velocity.x = move_toward(velocity.x, axis * run_speed, (acceleration if axis else braking) * delta)
	if axis:
		facing = signf(axis)
	coyote_remaining = coyote_time if grounded else maxf(0.0, coyote_remaining - delta)
	jump_buffer_remaining = jump_buffer_time if pressed else maxf(0.0, jump_buffer_remaining - delta)
	if grounded:
		jumps_used = 0
		velocity.y = 0
	else:
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
		# Walking off a ledge consumes the ground jump once grace expires.
		if coyote_remaining <= 0 and jumps_used == 0:
			jumps_used = 1
	if jump_buffer_remaining > 0 and (coyote_remaining > 0 or jumps_used < 2):
		velocity.y = -jump_speed
		jumps_used += 1
		coyote_remaining = 0
		jump_buffer_remaining = 0
	if released and velocity.y < 0:
		velocity.y *= 0.45


func reset_movement() -> void:
	velocity = Vector2.ZERO
	coyote_remaining = 0
	jump_buffer_remaining = 0
	jumps_used = 0
	facing = 1


func _draw() -> void:
	# Geometric Vanguard stand-in; replace when the character art is approved.
	draw_rect(Rect2(-8, -13, 16, 22), Color("233e53"))
	draw_rect(Rect2(-9, -6, 18, 9), Color("bc9358"))
	draw_rect(Rect2(-7, -14, 14, 8), Color("ded4bc"))
	draw_rect(Rect2(1 if facing > 0 else -6, -12, 5, 3), Color("6ce8e0"))
	draw_rect(Rect2(-7, 9, 5, 5), Color("152638"))
	draw_rect(Rect2(2, 9, 5, 5), Color("152638"))
	draw_rect(Rect2(-2, -4, 4, 4), Color("6ce8e0"))
