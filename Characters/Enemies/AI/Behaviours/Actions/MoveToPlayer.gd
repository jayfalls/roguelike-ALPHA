extends ActionLeaf

var tick_count: float = 0

func tick(actor, _blackboard):
	actor.target_reached = false
	actor.target_position = actor.player.global_position
	actor.pathing = true
	
	tick_count += get_physics_process_delta_time()
	var distance_to_player: float = actor.global_position.distance_to(actor.player.global_position)
	if actor.target_reached or distance_to_player < 5:
		tick_count = 0
		return SUCCESS
	if tick_count > 2 or distance_to_player > actor.PLAYER_DISTANCE:
		tick_count = 0
		return FAILURE
	
	return RUNNING
