extends ConditionLeaf

var tick_count: int = 0

func tick(actor, _blackboard):
	if actor.stuck:
		return SUCCESS
	return FAILURE
