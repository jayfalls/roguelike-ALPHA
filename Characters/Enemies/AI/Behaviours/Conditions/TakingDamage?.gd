extends ConditionLeaf

func tick(actor, _blackboard):
	if actor.taking_damage:
		return SUCCESS
	return FAILURE
