extends Node

const BIRD_SCENE = preload("res://Scenes/Bird.tscn")
const UGA_SCENE = preload("res://Scenes/Uga.tscn")

var spawn_points: Array[Marker2D] = []

@onready var circle_centers: Array[Marker2D] = [
	$CircleCenter1,
	$CircleCenter2,
	$CircleCenter3,
	$CircleCenter4,
	$CircleCenter5
]

func _ready() -> void:
	spawn_bird()
	spawn_uga()
	

func spawn_uga() -> void:
	var uga = UGA_SCENE.instantiate()
	add_child(uga)
	var player = $CharacterBody2D
	var camera: Camera2D = $Camera2D
	var viewport_size = get_viewport().get_visible_rect().size
	var center = camera.get_screen_center_position()
	var half_width = viewport_size.x / (2.0 * camera.zoom.x)

	var left = center.x - half_width
	var right = center.x + half_width

	var from_left = false
	var spawn_x = left + 30.0 if from_left else right - 30.0

	# Nasce na altura do jogador ou um pouco acima.
	var spawn_y = player.global_position.y
	if randf() < 0.5:
		spawn_y -= 160 * randi_range(0, 3)

	uga.global_position = Vector2(spawn_x, spawn_y)
	uga.direction = 1 if from_left else -1
	uga.update_direction()

func spawn_bird() -> void:
	var bird = BIRD_SCENE.instantiate()

	var screen_size = get_viewport().get_visible_rect().size
	var from_left = randf() < 0.5

	bird.direction = 1 if from_left else -1
	bird.global_position = Vector2(
		-50.0 if from_left else screen_size.x + 50.0,
		randf_range(300.0, -400.0)
	)

	var center_marker: Marker2D = circle_centers[0]

	for marker in circle_centers:
		if bird.global_position.distance_to(marker.global_position) < bird.global_position.distance_to(center_marker.global_position):
			center_marker = marker

	bird.circle_center = center_marker.global_position

	add_child(bird)
