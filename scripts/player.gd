extends CharacterBody2D

class_name Player

@export var SPEED = 200.0
var speed_multiplier = 1.0

@onready var health_bar: ProgressBar = $HealthBar
@onready var cursor: Sprite2D = $Cursor
@onready var hit_invincibility: Timer = $HitInvincibility
@onready var ghost_timer = $GhostEffectTimer
@onready var dash_timer = $DashTimer
@onready var dash_hitbox = $DashHitbox

var is_knocked: bool = false # also invincible
var is_dashing: bool = false
var is_shooting: bool = false

var mouse_pos: Vector2
var attack_direction: Vector2
var dash_direction: Vector2
var knockback_direction: Vector2
var shotgun_recoil_direction: Vector2

var kbm_active: bool

# Attack animation queue
var anim_queue: Array = []

@onready var slash_hitbox := %SlashHitbox
@onready var shotgun_hitbox := %ShotgunHitbox
@export var dash_ghost_effect: PackedScene

@onready var level_state := get_node("/root/Level")

func _ready() -> void:
	slash_hitbox.disable()
	shotgun_hitbox.disable()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventKey:
		kbm_active = true
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		kbm_active = false
	
	var anim_sprite := %AnimatedSprite2D
	if Input.is_action_just_pressed("attack"):
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
		
		anim_sprite.play_attack_animation(attack_direction, true)
		slash(attack_direction)
	
	elif Input.is_action_just_pressed("dash"):
		dash()
	elif Input.is_action_just_pressed("shotgun"):
		anim_sprite.play_shotgun_animation()
		shoot_shotgun()

func _physics_process(_delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	
	var move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if is_knocked:
		velocity = knockback_direction * SPEED * speed_multiplier
	if is_shooting:
		velocity = shotgun_recoil_direction * SPEED * speed_multiplier
	elif is_dashing:
		velocity = dash_direction * SPEED * speed_multiplier
	else:
		velocity = move_direction * SPEED * speed_multiplier
	
	move_cursor()
	handle_animation()
	
	move_and_slide()

func handle_animation():
	var anim_sprite := %AnimatedSprite2D
	var isAttackingInYAxis: bool = false
	
	if anim_sprite.animation.begins_with("attack") and anim_sprite.is_playing():
		isAttackingInYAxis = !( abs(attack_direction.x) > abs(attack_direction.y) )
	elif velocity.is_zero_approx():
		anim_sprite.play_idle_animation()
	else:
		anim_sprite.play_walk_animation()
	
	if kbm_active:
		anim_sprite.set_flip_h(!isAttackingInYAxis and mouse_pos.x < self.global_position.x)
	else:
		anim_sprite.set_flip_h(!isAttackingInYAxis and attack_direction.x < 0)

func move_cursor() -> void:
	if kbm_active:
		attack_direction = (mouse_pos - self.global_position).normalized()
	else:
		var right_joy_input = Input.get_vector("look_left", "look_right", "look_up", "look_down").normalized()
		if not right_joy_input.is_zero_approx():
			attack_direction = right_joy_input 
	
	cursor.global_position = self.global_position + (attack_direction*35)

# shotgun function
func shoot_shotgun():
	is_shooting = true
	
	shotgun_hitbox.enable()
	shotgun_hitbox.set_direction(attack_direction)
	
	speed_multiplier = 3.0
	shotgun_recoil_direction = attack_direction*-1

# slash functions
func slash(direction: Vector2):
	slash_hitbox.enable()
	slash_hitbox.set_direction(direction)

func _on_attack_animation_finished() -> void:
	var anim_sprite := %AnimatedSprite2D
	if anim_sprite.animation == &"attack_shotgun":
		is_shooting = false
		speed_multiplier = 1.0
		shotgun_hitbox.disable()
		handle_animation()
	elif anim_sprite.animation.begins_with("attack"):
		slash_hitbox.disable()
		if anim_queue.is_empty():
			speed_multiplier = 1.0
			handle_animation()
		else:
			anim_sprite.play_attack_animation(attack_direction, anim_queue.pop_front())
			slash(attack_direction)

# damage to player functions
func hit(direction: Vector2) -> void:
	if not is_knocked:
		health_bar.hit()
		hit_invincibility.start()
		
		is_knocked = true
		knockback_direction = direction.normalized()
		
		speed_multiplier = 3.0

func _on_hit_invincibility_timeout() -> void:
	is_knocked = false
	knockback_direction = Vector2(0, 0)
	speed_multiplier = 1.0

# dash functions
func dash():
	is_dashing = true
	
	ghost_timer.start()
	dash_timer.start()
	
	dash_hitbox.monitoring = true
	set_collision_layer_value(2, false)
	set_collision_layer_value(6, true)
	
	speed_multiplier = 5.0
	dash_direction = attack_direction

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	dash_direction = Vector2(0, 0)
	
	ghost_timer.stop()
	dash_timer.stop()
	
	dash_hitbox.monitoring = false
	set_collision_layer_value(2, true)
	set_collision_layer_value(6, false)
	
	speed_multiplier = 1.0

func add_dash_ghosting():
	var ghost = dash_ghost_effect.instantiate()
	ghost.set_position_and_scale(position, scale)
	ghost.flip(attack_direction.x < 0)
	get_parent().add_child(ghost)

func _on_ghost_effect_timer_timeout() -> void:
	add_dash_ghosting()

func _on_dash_hitbox_body_entered(body: Node2D) -> void:
	if body is Slime:
		body.hit()
	if body is FireGoblin:
		body.hit()

func _on_health_changed(value: float) -> void:
	if value <= 0:
		level_state.register_player_death()
