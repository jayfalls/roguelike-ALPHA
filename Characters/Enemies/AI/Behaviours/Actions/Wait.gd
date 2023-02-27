extends ActionLeaf

var done_waiting: bool = false

onready var timer: Timer = $Timer
var timer_started: bool = false

func tick(actor, _blackboard):
	if not timer_started:
		actor.idle = true
		timer_started = true
		timer.wait_time = rand_range(1.5,6)
		timer.start()
	
	if done_waiting:
		actor.idle = false
		done_waiting = false
		return SUCCESS
	
	return RUNNING


func _on_Timer_timeout():
	timer_started = false
	done_waiting = true
