extends ConditionLeaf

func tick(actor, _blackboard):
	var distance_to_player: float = actor.global_position.distance_to(actor.player.global_position)
	if distance_to_player < actor.PLAYER_DISTANCE:
		return SUCCESS
	return FAILURE
