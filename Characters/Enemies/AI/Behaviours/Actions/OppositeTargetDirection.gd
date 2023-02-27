extends ActionLeaf

var tick_count: int = 0

func tick(actor, _blackboard):
	if actor.is_moving:
		actor.pathing = true
	else:
		actor.pathing = false
	
	if tick_count < 2:
		print("unstucking")
		actor.target_position = actor.random_spawntile()
	if tick_count > 100:
		tick_count = 0
	tick_count += 1
	
	actor.move_anims()
	return RUNNING
