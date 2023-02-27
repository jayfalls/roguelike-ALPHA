extends Composite
class_name WhileComposite

func tick(actor,blackboard):
	if get_child(0).tick(actor,blackboard) == SUCCESS:
		get_child(1).tick(actor,blackboard)
		return RUNNING
	return FAILURE
