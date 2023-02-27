extends Particles2D

var timeout: int = 0 setget timeout

onready var timer = $Timer

func timeout(input) -> void:
	timer.wait_time = input
	timer.start()

func _on_Timer_timeout():
	queue_free()
