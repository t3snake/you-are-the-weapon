extends Node

var current_level: int

var enemyCount: int

func reset_state(level: int):
	current_level = level
	enemyCount = 0

func isLevelFinished() -> bool:
	return enemyCount == 0
