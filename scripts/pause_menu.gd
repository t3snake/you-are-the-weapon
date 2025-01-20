extends Node2D


@onready var pause_menu_ui: Control = $Player/PauseMenu
var paused = false

func _ready() -> void:
	pause_menu_ui.hide()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause_menu()

func _process(_delta: float) -> void:
	pass

func toggle_pause_menu():
	if paused:
		pause_menu_ui.hide()
		Engine.time_scale = 1
		set_physics_process(true)
	else:
		pause_menu_ui.show()
		Engine.time_scale = 0
		set_physics_process(false)
	
	paused = !paused
