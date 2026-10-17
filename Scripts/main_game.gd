extends Node

const BIRD_SCENE = preload("res://Scenes/Bird.tscn")
const UGA_SCENE = preload("res://Scenes/Uga.tscn")

const DISTANCIA_NIVEL_UGA: float = 160.0
const DISTANCIA_LATERAL: float = 30.0

@onready var circle_centers: Array[Marker2D] = [
	$CircleCenter1,
	$CircleCenter2,
	$CircleCenter3,
	$CircleCenter4,
	$CircleCenter5
]

# Guarda as referências das Ugas que ainda existem.
var ugas: Dictionary = {}


func _ready() -> void:
	spawn_bird()

	spawn_uga(0)
	spawn_uga(1)


func spawn_uga(nivel: int) -> void:
	var uga = UGA_SCENE.instantiate()

	add_child(uga)

	var id = uga.get_instance_id()
	ugas[id] = uga

	uga.tree_exited.connect(_on_uga_tree_exited.bind(id))

	var player: CharacterBody2D = $CharacterBody2D
	var camera: Camera2D = $Camera2D

	var viewport_size = get_viewport().get_visible_rect().size
	var center = camera.get_screen_center_position()
	var half_width = viewport_size.x / (2.0 * camera.zoom.x)

	var left = center.x - half_width
	var right = center.x + half_width

	var from_left = randf() < 0.5
	var spawn_x = left + DISTANCIA_LATERAL if from_left else right - DISTANCIA_LATERAL
	var spawn_y = player.global_position.y - (DISTANCIA_NIVEL_UGA * nivel)

	uga.global_position = Vector2(spawn_x, spawn_y)
	uga.direction = 1 if from_left else -1
	uga.update_direction()


func _on_uga_tree_exited(id_morto: int) -> void:
	ugas.erase(id_morto)

	# Espera a remoção da Uga terminar antes de escolher o novo nível.
	call_deferred("_spawn_uga_nivel_livre")


func _spawn_uga_nivel_livre() -> void:
	var player: CharacterBody2D = $CharacterBody2D
	var niveis_ocupados: Array[int] = []

	for uga in ugas.values():
		if is_instance_valid(uga):
			var nivel_relativo = roundi(
				(player.global_position.y - uga.global_position.y)
				/ DISTANCIA_NIVEL_UGA
			)
			niveis_ocupados.append(nivel_relativo)

	# Procura um nível livre acima do jogador.
	var novo_nivel = 0

	while novo_nivel in niveis_ocupados:
		novo_nivel += 1

	spawn_uga(novo_nivel)


func spawn_bird() -> void:
	var bird = BIRD_SCENE.instantiate()

	var screen_size = get_viewport().get_visible_rect().size
	var from_left = randf() < 0.5

	bird.direction = 1 if from_left else -1
	bird.global_position = Vector2(
		-50.0 if from_left else screen_size.x + 50.0,
		randf_range(-400.0, 300.0)
	)

	var center_marker: Marker2D = circle_centers[0]

	for marker in circle_centers:
		if bird.global_position.distance_to(marker.global_position) < bird.global_position.distance_to(center_marker.global_position):
			center_marker = marker

	bird.circle_center = center_marker.global_position

	add_child(bird)
	bird.tree_exited.connect(spawn_bird)
