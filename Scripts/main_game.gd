extends Node

const BIRD_SCENE = preload("res://Scenes/Bird.tscn")
const UGA_SCENE = preload("res://Scenes/Uga.tscn")

var spawn_points: Array[Marker2D] = []

@onready var circle_centers: Array[Marker2D] = [
	$CircleCenter1,
	$CircleCenter2,
	$CircleCenter3,
	$CircleCenter4
]

func _ready() -> void:
	spawn_bird()
	spawn_uga()

func spawn_uga() -> void:
	print("Spawnando Uga!")
	var uga = UGA_SCENE.instantiate()

	var screen_size = get_viewport().get_visible_rect().size
	var from_left = randf() < 0.5

	uga.direction = 1 if from_left else -1
	uga.global_position = Vector2(
		-50.0 if from_left else screen_size.x + 50.0,
		570.0
	)

	add_child(uga)

func spawn_bird() -> void:
	print("Spawnando passaro!")
	var bird = BIRD_SCENE.instantiate()

	var screen_size = get_viewport().get_visible_rect().size
	var from_left = randf() < 0.5

	bird.direction = 1 if from_left else -1
	bird.global_position = Vector2(
		-50.0 if from_left else screen_size.x + 50.0,
		randf_range(200.0, 500.0)
	)

	var center_marker: Marker2D = circle_centers.pick_random()
	bird.circle_center = center_marker.global_position

	add_child(bird)
