extends CharacterBody2D

class_name Slime

@export var SPEED = 300.0
@onready var health_bar: ProgressBar = $HealthBar
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
	health_bar.hit()
	slime_animation.play_damaged_animation()

func _on_health_changed(value: float) -> void:
	if value <= 0:
		queue_free()

func _on_detect_radius_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body

func _on_detect_radius_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null


func _on_slime_animation_finished() -> void:
	if slime_animation.animation == "spawn" or slime_animation.animation == "damaged":
		slime_animation.play_idle_animation()
	
