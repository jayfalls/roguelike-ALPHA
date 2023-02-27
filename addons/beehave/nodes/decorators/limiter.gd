extends Decorator

class_name LimiterDecorator, "../../icons/limiter.svg"

export (float) var max_time: float = 0
var tick_time: float = 0

func tick(actor, blackboard):
	if tick_time <= max_time:
		tick_time += get_physics_process_delta_time()
		return self.get_child(0).tick(actor, blackboard)
	else:
		tick_time = 0
		self.get_child(0)._reset(actor)
		return FAILED
