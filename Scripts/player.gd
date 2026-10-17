
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_area = $CollisionShape2D2
@onready var tilemap: TileMapLayer = $"../TileMapLayer"


var is_hitting := false

func hitting() -> void:
	if is_hitting:
		return

	is_hitting = true
	animated_sprite.play("Hit")

	# Detecta os inimigos na área de ataque
	var hitted = hit_area.get_overlapping_bodies()

	for body in hitted:
		if body.is_in_group("Inimigos"):
			body.die()

	# Aguarda a animação terminar
	await animated_sprite.animation_finished
	is_hitting = false


func _physics_process(delta: float) -> void:
	var viewport = get_viewport_rect()

	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pulo
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimento horizontal
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Direção do personagem e área de ataque
	if direction != 0:
		animated_sprite.flip_h = direction < 0
		hit_area.position.x = 0 if direction > 0 else -20

	# Ataque
	if Input.is_action_pressed("Hit") and not is_hitting:
		hitting()

	# Outras animações, somente fora do ataque
	if not is_hitting:
		if not is_on_floor():
			animated_sprite.play("Jump")
		elif direction != 0:
			animated_sprite.play("Walk")
		else:
			animated_sprite.play("Idle")

	# Teletransporte horizontal
	if global_position.x < 0:
		global_position.x = viewport.size.x
	elif global_position.x > viewport.size.x:
		global_position.x = 0
		
	break_tile()

func break_tile() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()

		if normal.y < 0.1 or velocity.y > 0:
			continue

		if collision.get_collider() != tilemap:
			continue

		var collision_point = collision.get_position()
		var local_point = tilemap.to_local(collision_point)
		var cell = tilemap.local_to_map(local_point)

		var tile_data = tilemap.get_cell_tile_data(cell)
		if tile_data == null:
			continue

		if not tile_data.get_custom_data("Breakable"):
			continue

		# Posição global do centro do tile
		var tile_global_position = tilemap.to_global(
			tilemap.map_to_local(cell)
		)

		# O player precisa estar acima do tile
		if global_position.y > tile_global_position.y:
			print("colidiu")
			tilemap.erase_cell(cell)
			break
