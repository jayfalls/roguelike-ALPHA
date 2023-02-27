extends ConditionLeaf

func tick(actor, _blackboard):
	if actor.chasing:
		return FAILURE
	return SUCCESS
