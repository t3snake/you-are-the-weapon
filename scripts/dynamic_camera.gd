extends Camera2D

var target_distance = 0

@export var SPEED := 120


func _process(delta: float) -> void:
	var direction = position.direction_to(get_local_mouse_position())
	
	position += direction * target_distance * SPEED * delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		target_distance = position.distance_to(get_local_mouse_position()) * (2.0/3.0)
	
