extends ActionLeaf

func tick (actor,_blackboard):
	actor.idle = true
	return SUCCESS
