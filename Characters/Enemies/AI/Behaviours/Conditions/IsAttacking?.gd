extends ConditionLeaf

func tick(actor, _blackboard):
	if actor.attacking:
		return SUCCESS
	return FAILURE
