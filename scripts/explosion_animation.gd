extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	
func play_explode_animation():
	self.show()
	play('default')
	

func _on_explosion_animation_finished() -> void:
	queue_free()
