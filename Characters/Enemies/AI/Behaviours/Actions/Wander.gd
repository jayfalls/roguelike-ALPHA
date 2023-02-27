extends ActionLeaf

var target_reached = false
var tick_count: int = 0
var time_threshold: int

func tick(actor, _blackboard):
	if not actor.is_connected("target_reached", self, "_target_reached"):
		actor.connect("target_reached", self, "_target_reached")
		actor.target_position = actor.random_spawntile()
		time_threshold = actor.global_position.distance_squared_to(actor.target_position) 
		actor.target_reached = false
		actor.idle = false
		actor.pathing = true
	
	if self.target_reached:
		target_reached = false
		actor.disconnect("target_reached", self, "_target_reached")
		return SUCCESS
	
	if tick_count > time_threshold:
		tick_count = 0
		actor.disconnect("target_reached", self, "_target_reached")
		return SUCCESS
	tick_count += 1
	
	return RUNNING

func _target_reached():
	target_reached = true
