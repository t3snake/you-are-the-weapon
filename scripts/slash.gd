extends Area2D


func set_direction(direction: Vector2):
	rotation = direction.angle()

func _on_slash_body_entered(body: Node2D) -> void:
	if body is Slime:
		body.hit()
	if body is FireGoblin:
		body.hit()
