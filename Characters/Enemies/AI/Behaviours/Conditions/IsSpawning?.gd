extends ConditionLeaf

func tick(actor, _blackboard):
	if actor.spawning:
		return SUCCESS
	return FAILURE
