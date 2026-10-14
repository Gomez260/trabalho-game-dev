extends CharacterBody2D

@export var speed: float = 40.0
@export var gravity: float = 980.0
@export var edge_check_distance: float = 12.0
@export var hit_fall_speed: float = 250.0
@export var hit_rotation_speed: float = 8.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var floor_ray: RayCast2D = $RayCast2D

var is_hit: bool = false
var direction: int = 1
var origin_position: Vector2

enum State {
	WALKING,
	EXITING
}

var state: State = State.WALKING

func _ready() -> void:
	floor_ray.enabled = true
	origin_position = global_position
	update_direction()
	sprite.play("Walk")

func _physics_process(delta: float) -> void:
	if is_hit:
		fall_after_hit(delta)
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	if state == State.WALKING:
		floor_ray.position.x = direction * edge_check_distance
		floor_ray.force_raycast_update()

		if is_on_floor() and not floor_ray.is_colliding():
			direction *= -1
			update_direction()

		velocity.x = direction * speed

	move_and_slide()

	if is_on_wall() and state == State.WALKING:
		direction *= -1
		update_direction()

func update_direction() -> void:
	sprite.flip_h = direction > 0

func take_hit() -> void:
	if is_hit:
		return

	is_hit = true
	state = State.EXITING
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	direction *= -1
	sprite.play("Hit")

func fall_after_hit(delta: float) -> void:
	var screen_width = get_viewport_rect().size.x
	var camera = get_viewport().get_camera_2d()

	var half_width = screen_width / (2.0 * camera.zoom.x)
	var camera_x = camera.get_screen_center_position().x

	var target_x = camera_x + (half_width + 100.0) * direction

	if abs(global_position.x - target_x) < 5.0:
		print("removed")
		queue_free()
		return

	global_position.x = move_toward(
		global_position.x,
		target_x,
		speed * 2.0 * delta
	)

func _process(_delta: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera == null:
		return

	var screen_height = get_viewport_rect().size.y
	var camera_bottom = camera.get_screen_center_position().y + screen_height / (2.0 * camera.zoom.y)
		
	if global_position.y > camera_bottom + 300.0:
		print("Uga removido! Y: ", global_position.y, " | Limite: ", camera_bottom)
		queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		take_hit()
