extends ActionLeaf

var random_position: Vector2 = Vector2.ZERO
var target_reached = false

func tick(actor, _blackboard):
	if not actor.is_connected("target_reached", self, "_target_reached"):
		actor.connect("target_reached", self, "_target_reached")
		random_position = _determine_random_position(actor)
		actor.target_position = random_position
		actor.target_reached = false
	
	if self.target_reached:
		target_reached = false
		random_position = Vector2.ZERO
		actor.disconnect("target_reached", self, "_target_reached")
		return SUCCESS
	
	actor.pathing = true
	return RUNNING

func _determine_random_position(actor) -> Vector2:
	var player_position: Vector2 = actor.player.global_position
	var player_distance: int = actor.PLAYER_DISTANCE - 1
	var randedge =  maths.randedge_around_vector(player_position, player_distance)
	return randedge

func _target_reached():
	target_reached = true

func _reset(actor) -> void:
	actor.disconnect("target_reached", self, "_target_reached")
