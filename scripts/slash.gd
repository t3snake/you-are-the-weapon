extends Area2D

var slash_direction = Vector2.ZERO

func _on_slash_body_entered(body: Node2D) -> void:
	if body.is_in_group("props"):
		body.queue_free()
		# TODO play explosion animation
	if body is Slime:
		body.hit()
	if body is FireGoblin:
		body.hit(slash_direction)
