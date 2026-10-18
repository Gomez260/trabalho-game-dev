extends Camera2D

@export var player: Node2D
@export var adjustment_speed : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var player_screen_number = int((player.position.y - limit_bottom))
	var camera_screen_number = int((position.y - limit_bottom))
	
	#print("Player: ", player_screen_number, " - Camera: ", camera_screen_number)
	
	if player_screen_number != camera_screen_number:
		position.y += adjustment_speed * delta * (player_screen_number - camera_screen_number)
