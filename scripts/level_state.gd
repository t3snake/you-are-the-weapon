extends Node2D

var enemy_count: int
var is_paused = false
var is_start = true

@onready var pause_menu_ui: CanvasLayer = %PauseMenu

func _ready() -> void:
	GameState.set_level(1)
	pause_menu_ui.hide()

func register_enemy_spawn():
	is_start = false
	enemy_count += 1
	
func register_enemy_death():
	enemy_count -= 1
	print("Enemies remaining " + str(enemy_count))

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause_menu()

func _process(_delta: float) -> void:
	if !is_start and is_level_finished():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func is_level_finished() -> bool:
	return enemy_count == 0

func toggle_pause_menu():
	if is_paused:
		pause_menu_ui.hide()
		Engine.time_scale = 1
		set_physics_process(true)
		set_process(true)
	else:
		pause_menu_ui.show()
		Engine.time_scale = 0
		set_physics_process(false)
		
	
	is_paused = !is_paused
