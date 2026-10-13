extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_area = $CollisionShape2D2

func hitting():
	animated_sprite.play("Hit")
	var hitted = hit_area.get_overlapping_bodies()
	
	for body in hitted:
		if(body.is_in_group("Inimigos")):
			body.die()
	await get_tree().create_timer(2).timeout

func _physics_process(delta: float) -> void:
	var viewport = get_viewport_rect()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if not is_on_floor():
		animated_sprite.play("Jump")
	elif direction != 0:
		animated_sprite.play("Walk")
	if velocity.x == 0 and velocity.y == 0:
		animated_sprite.play("Idle")

	if direction != 0:
		animated_sprite.flip_h = direction < 0
		if direction > 0:
			hit_area.position.x = 0
		else:
			hit_area.position.x = -20
	
	if global_position.x < 0:
		global_position.x = viewport.size.x
	elif global_position.x > viewport.size.x:
		global_position.x = 0
		
	if Input.is_action_just_pressed("Hit"):
		hitting()
