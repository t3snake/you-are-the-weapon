extends CanvasLayer

func update_time_elapsed(time: float):
	%TimeElapsed.text = "Time elapsed: %.2f s" % time
	
func update_enemies_remaining(count: int):
	%EnemiesRemaining.text = "Enemies remaining: %d" % count
