extends Node

var timer: float
var is_timer_active: bool

var total_levels: int = 2
var levels_cleared: int
var current_level: int

var highscore_map: Dictionary

enum Outcome {DIED, BEAT}
var outcome: Outcome

func _ready() -> void:
	levels_cleared = 0
	timer = 0
	is_timer_active = false
	
	highscore_map = {}
	for lvl in range(total_levels):
		highscore_map[lvl] = 0
		

func _process(delta: float) -> void:
	if is_timer_active:
		timer += delta

func start_timer() -> void:
	is_timer_active = true
	timer = 0

func stop_timer() -> void:
	is_timer_active = false

func set_level(level: int) -> void:
	current_level = level
	timer = 0
	is_timer_active = false

func set_level_cleared(level: int) -> void:
	if level > levels_cleared:
		levels_cleared = level
	
	if highscore_map[level] == 0:
		highscore_map[level] = timer
	elif timer < highscore_map[level]:
		highscore_map[level] = timer
	
	timer = 0
