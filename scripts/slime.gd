extends CharacterBody2D

class_name Slime

@export var SPEED = 300.0
@export var explosion: PackedScene

@onready var slime_animation: AnimatedSprite2D = $AnimatedSprite2D

var player = null

func _ready() -> void:
	slime_animation.play_spawn_animation()

func _physics_process(delta: float) -> void:
	if player:
		var collision = move_and_collide((player.position - position).normalized() * SPEED * delta)
		if collision:
			velocity = velocity.bounce(collision.get_normal())
			var collider = collision.get_collider()
			if collider is Player and collider.has_method("hit"):
				collision.get_collider().hit(velocity)
		else:
			slime_animation.play_idle_animation()
	else:
		slime_animation.play_idle_animation()
		velocity = Vector2.ZERO
		move_and_slide()

func hit() -> void:
	slime_animation.play_damaged_animation()
	set_physics_process(false)
	# queue free on animation finish

func _on_detect_radius_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body

func _on_detect_radius_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null

func _on_slime_animation_finished() -> void:
	if slime_animation.animation == "spawn":
		slime_animation.play_idle_animation()
	if slime_animation.animation == "damaged":
		var explode = explosion.instantiate()
		explode.position = global_position
		get_parent().add_child(explode)
		explode.play_explode_animation()
		queue_free()
	
