
extends Area2D

@export var descent_distance: float = 70.0
@export var descent_speed: float = 100.0
@export var exit_speed: float = 180.0
@export var radius_x: float = 300.0
@export var radius_y: float = 80.0
@export var circle_speed: float = 2.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var hit_fall_speed: float = 250.0
@export var hit_rotation_speed: float = 8.0
@export var exit_up_speed: float  = 15.0

var is_hit: bool = false

enum State {
	DESCENDING,
	CIRCLING,
	EXITING
}

var direction: int = 1
var state: State = State.DESCENDING

var descent_target: Vector2
var circle_center: Vector2
var angle: float = 0.0
var circles_completed: int = 0
var angular_direction: float = 1.0
var exit_direction: int = 1
var entry_angle: float = 0.0


func _ready() -> void:
	sprite.play("Fly")
	
	sprite.flip_h = direction < 0
	angular_direction = 1.0 if direction > 0 else -1.0

	entry_angle = PI if direction > 0 else 0.0

	var entry_point = circle_center + Vector2(
		radius_x * cos(entry_angle),
		radius_y * sin(entry_angle)
	)

	# Desce na diagonal até a entrada sda trajetória.
	descent_target = Vector2(
		entry_point.x,
		global_position.y + descent_distance
	)

	circles_completed = 0
	angle = entry_angle
	state = State.DESCENDING

	update_sprite_direction()


func _process(delta: float) -> void:
	if is_hit:
		fall_after_hit(delta)
		return
	match state:
		State.DESCENDING:
			move_down_diagonal(delta)
		State.CIRCLING:
			move_in_circles(delta)
		State.EXITING:
			move_out(delta)


func move_down_diagonal(delta: float) -> void:
	global_position = global_position.move_toward(
		descent_target,
		descent_speed * delta
	)

	if global_position.distance_to(descent_target) < 2.0:
		global_position = descent_target
		angle = entry_angle
		state = State.CIRCLING


func move_in_circles(delta: float) -> void:
	var previous_angle = angle
	angle -= angular_direction * circle_speed * delta

	global_position = circle_center + Vector2(
		radius_x * cos(angle),
		radius_y * sin(angle)
	)
	
	update_sprite_direction()

	var previous_turn = floor(
		abs(previous_angle - entry_angle) / TAU
	)
	var current_turn = floor(
		abs(angle - entry_angle) / TAU
	)
	
	if current_turn > previous_turn:
		circles_completed += 1

	if circles_completed >= 2:
		var horizontal_velocity = -sin(angle) * angular_direction
		exit_direction = -1 if horizontal_velocity >= 0.0 else 1
		state = State.EXITING
		update_sprite_direction()

func update_sprite_direction() -> void:
	if state == State.EXITING:
		sprite.flip_h = exit_direction < 0
		return

	var horizontal_velocity = -sin(angle) * angular_direction

	if abs(horizontal_velocity) > 0.05:
		sprite.flip_h = horizontal_velocity > 0.0


func move_out(delta: float) -> void:
	global_position.x += exit_direction * exit_speed * delta
	global_position.y -= exit_up_speed * delta

	var screen_width = get_viewport_rect().size.x

	if exit_direction < 0 and global_position.x < -100.0:
		queue_free()
	elif exit_direction > 0 and global_position.x > screen_width + 100.0:
		queue_free()
		
func take_hit() -> void:
	if is_hit:
		return

	is_hit = true
	state = State.EXITING

	sprite.play("Hit")
	
func fall_after_hit(delta: float) -> void:
	global_position.y += hit_fall_speed * delta

	sprite.rotation += hit_rotation_speed * delta

	var screen_height = get_viewport_rect().size.y

	if global_position.y > screen_height + 100.0:
		queue_free()
	
