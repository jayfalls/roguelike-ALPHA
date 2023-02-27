extends ActionLeaf

var tick_count: float = 0

func tick(actor, _blackboard):
	actor.pathing = false
	if actor.is_moving:
		actor.pathing = true
		return SUCCESS
	
	if tick_count < 2:
		actor.target_position = actor.random_spawntile()
	if tick_count > 2:
		tick_count = 0
	tick_count +=  get_physics_process_delta_time()
	
	return RUNNING
