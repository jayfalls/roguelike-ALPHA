extends ActionLeaf

func tick(actor, _blackboard):
	actor.pathing = false
	actor.attack()
	return RUNNING
