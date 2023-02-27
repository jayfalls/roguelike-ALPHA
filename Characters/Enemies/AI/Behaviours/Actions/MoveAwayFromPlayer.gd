extends ActionLeaf

var chose_position: bool = false

func tick(actor, _blackboard):
	if not chose_position:
		chose_position = true
		actor.target_reached = false
		actor.target_position = actor.get_nav_farther_than(actor.player.global_position, actor.PLAYER_DISTANCE) # Make this function
	actor.idle = false
	actor.pathing = true
	
	var distance_to_player: float = actor.global_position.distance_to(actor.player.global_position)
	if actor.target_reached or distance_to_player > actor.PLAYER_DISTANCE:
		return SUCCESS
	
	return RUNNING

func _reset(actor) -> void:
	chose_position = false
