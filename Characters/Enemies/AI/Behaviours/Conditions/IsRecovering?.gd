extends ConditionLeaf

func tick(actor, _blackboard):
	if actor.damage_recovered:
		return FAILURE
	return SUCCESS
