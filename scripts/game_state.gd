extends Node

var timer: int
var is_timer_active: bool

var levels_cleared: int
var current_level: int

var highscore_map: Dictionary

func _ready() -> void:
	levels_cleared = 0
	highscore_map = {}
	timer = 0
	is_timer_active = false

func start_timer() -> void:
	is_timer_active = true

func stop_timer() -> void:
	is_timer_active = false

func set_level(level: int) -> void:
	current_level = level
	timer = 0
	is_timer_active = false

func set_level_cleared(level: int) -> void:
	if level > levels_cleared:
		levels_cleared = level
	
	if level not in highscore_map:
		highscore_map[level] = timer
	elif timer > highscore_map[level]:
		highscore_map[level] = timer
	
	timer = 0
