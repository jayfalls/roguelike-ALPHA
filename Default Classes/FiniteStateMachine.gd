extends Node
class_name FiniteStateMachine

# States
var states: Dictionary = {}
var previous_state: int = -1
var state: int = -1 setget set_state


## DECLARATION
func _add_state(new_state: String) -> void:
	states[new_state] = states.size()


## TICK
func _physics_process(delta) -> void:
	if state != -1:
		_state_logic(delta)
		var transition: int = _get_transition()
		if transition_conditions(transition):
			
			set_state(transition)

func _state_logic(_delta: float) -> void:
	pass

func transition_conditions(transition: int) -> bool:
	return transition != -1

func _get_transition() -> int:
	return -1


## STATE CHANGES
func set_state(new_state: int) -> void:
	_exit_state(state)
	previous_state = state
	state = new_state
	_enter_state(previous_state, state)

func _enter_state(_previous_state: int, new_state: int) -> void:
	pass

func _exit_state(_state_exited: int) -> void:
	pass
