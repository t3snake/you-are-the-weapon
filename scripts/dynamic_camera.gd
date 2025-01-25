extends Camera2D

var target_distance = 0
var mouse_position = Vector2.ZERO

@export var SPEED := 120

func _process(delta: float) -> void:
	mouse_position = get_local_mouse_position()
	var direction = position.direction_to(mouse_position)
	
	var new_position = position + (direction * target_distance * SPEED * delta)
	if new_position.length() < 200:
		position = new_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_distance = position.distance_to(mouse_position)
		target_distance = clamp(mouse_distance, 0, 10) * (2.0/3.0)
