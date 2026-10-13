extends Node

const BIRD_SCENE = preload("res://Scenes/Bird.tscn")

@onready var spawn_l4_left: Marker2D = $SpawnLeft4
@onready var spawn_l4_right: Marker2D = $SpawnRight4
@onready var spawn_l3_left: Marker2D =  $SpawnLeft3
@onready var spawn_l3_right: Marker2D = $SpawnRight3

var spawn_points: Array[Marker2D] = []

func _ready() -> void:
	spawn_points = [
		spawn_l4_left,
		spawn_l4_right,
		spawn_l3_left,
		spawn_l3_right
	]
	spawn_bird()

func spawn_bird() -> void:
	var marker: Marker2D = spawn_points.pick_random()
	var bird = BIRD_SCENE.instantiate()

	bird.global_position = marker.global_position
	bird.level = 4 if marker in [spawn_l4_left, spawn_l4_right] else 3

	bird.direction = 1 if marker in [
		spawn_l4_left,
		spawn_l3_left
	] else -1

	add_child(bird)
