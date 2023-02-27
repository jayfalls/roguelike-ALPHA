extends ConditionLeaf

func tick(actor, _blackboard):
	if actor.staggered:
		return SUCCESS
	return FAILURE
