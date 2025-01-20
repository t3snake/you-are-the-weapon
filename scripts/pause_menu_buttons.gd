extends Control


var root

func _ready() -> void:
	root = get_node("/root/Game")

func _on_resume_button_pressed() -> void:
	root.toggle_pause_menu()

func _on_restart_button_pressed() -> void:
	root.toggle_pause_menu()
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	root.toggle_pause_menu()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
