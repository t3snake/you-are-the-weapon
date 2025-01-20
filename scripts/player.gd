extends CharacterBody2D

class_name Player


@export var SPEED = 200.0
var speed_multiplier = 1.0

@onready var health_bar: ProgressBar = $HealthBar
@onready var cursor: Sprite2D = $Cursor
@onready var hit_invincibility: Timer = $HitInvincibility
@onready var ghost_timer = $GhostEffectTimer
@onready var dash_timer = $DashTimer

var is_knocked: bool = false # also invincible
var is_dashing: bool = false

var mouse_pos: Vector2
var shoot_direction: Vector2
var dash_direction: Vector2
var knockback_direction: Vector2

var kbm_active: bool

# Attack animation queue
var anim_queue: Array = []

@export var Slash: PackedScene
@export var DashGhostEffect: PackedScene

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventKey:
		kbm_active = true
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		kbm_active = false
		
	if Input.is_action_just_pressed("shoot"):
		var anim_sprite = %AnimatedSprite2D
		# half player speed while shooting
		speed_multiplier = 0.5
		
		if anim_sprite.animation.begins_with("attack") and anim_sprite.is_playing():
			if len(anim_queue) >= 2:
				return
			# combo start playing or end
			if anim_sprite.animation.ends_with("1"):
				anim_queue.push_back(false)
			elif anim_sprite.animation.ends_with("2"):
				anim_queue.push_back(true)
			return
		
		anim_sprite.play_attack_animation(shoot_direction, true)
		shoot_slash(shoot_direction)
	
	elif Input.is_action_just_pressed("dash"):
		dash()

func _physics_process(_delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	
	var move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if is_knocked:
		velocity = knockback_direction * SPEED * speed_multiplier
	elif is_dashing:
		velocity = dash_direction * SPEED * speed_multiplier
	else:
		velocity = move_direction * SPEED * speed_multiplier
	
	move_cursor()
	handle_animation()
	
	move_and_slide()

func handle_animation():
	var anim_sprite = %AnimatedSprite2D
	var isAttackingInYAxis: bool = false
	
	if anim_sprite.animation.begins_with("attack") and anim_sprite.is_playing():
		isAttackingInYAxis = !( abs(shoot_direction.x) > abs(shoot_direction.y) )
	elif velocity.is_zero_approx():
		anim_sprite.play_idle_animation()
	else:
		anim_sprite.play_walk_animation()
	
	if kbm_active:
		anim_sprite.set_flip_h(!isAttackingInYAxis and mouse_pos.x < self.global_position.x)
	else:
		anim_sprite.set_flip_h(!isAttackingInYAxis and shoot_direction.x < 0)

func move_cursor() -> void:
	if kbm_active:
		shoot_direction = (mouse_pos - self.global_position).normalized()
	else:
		var right_joy_input = Input.get_vector("look_left", "look_right", "look_up", "look_down").normalized()
		if not right_joy_input.is_zero_approx():
			shoot_direction = right_joy_input 
	
	cursor.global_position = self.global_position + (shoot_direction*35)

func shoot_slash(direction: Vector2):
	var slash = Slash.instantiate()
	slash.initially_hide()
	get_parent().add_child(slash)
	slash.start(direction, cursor.global_transform)

func _on_attack_animation_finished() -> void:
	var anim_sprite = %AnimatedSprite2D
	if anim_sprite.animation.begins_with("attack"):
		if anim_queue.is_empty():
			speed_multiplier = 1.0
			handle_animation()
		else:
			anim_sprite.play_attack_animation(shoot_direction, anim_queue.pop_front())
			shoot_slash(shoot_direction)

func hit(direction: Vector2) -> void:
	if not is_knocked:
		health_bar.hit()
		hit_invincibility.start()
		
		is_knocked = true
		knockback_direction = direction.normalized()
		
		speed_multiplier = 3.0

func _on_health_changed(value: float) -> void:
	if value <= 0:
		get_tree().call_deferred("reload_current_scene")
	

func _on_hit_invincibility_timeout() -> void:
	is_knocked = false
	knockback_direction = Vector2(0, 0)
	speed_multiplier = 1.0
	
func dash():
	is_dashing = true
	ghost_timer.start()
	dash_timer.start()
	speed_multiplier = 5.0
	dash_direction = shoot_direction
	
func add_dash_ghosting():
	var ghost = DashGhostEffect.instantiate()
	ghost.set_position_and_scale(position, scale)
	get_parent().add_child(ghost)

func _on_ghost_effect_timer_timeout() -> void:
	add_dash_ghosting()

func _on_dash_timer_timeout() -> void:
	dash_timer.stop()
	is_dashing = false
	dash_direction = Vector2(0, 0)
	
	ghost_timer.stop()
	
	speed_multiplier = 1.0
