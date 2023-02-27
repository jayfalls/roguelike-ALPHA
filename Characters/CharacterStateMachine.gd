extends FiniteStateMachine
class_name CharacterStateMachine

onready var parent = get_parent().get_parent()
# Child Nodes
onready var sprite: Object = parent.get_node("Sprite")
onready var animation_player: AnimationPlayer = parent.get_node("AnimationPlayer")

# Animations
var animation_names: Array
var current_animation: int = -1

## DECLARATION
func _init() -> void:
	_add_state("IDLE")
	_add_state("WALK")
	_add_state("TAKE_DAMAGE")
	_add_state("STAGGERED")
	_add_state("DEAD")
	_init_inject()

func _init_inject() -> void:
	pass

func _add_state(new_state: String) -> void:
	states[new_state] = states.size()
	animation_names.append(new_state.capitalize())

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	set_state(states.IDLE)
	_ready_inject()

func _ready_inject() -> void:
	pass


## TICK
func _state_logic(_delta) -> void:
	if parent.dead or parent.frozen or not parent.visible:
		return # Stops execution:
	
	parent._move()
	_flip_sprite()
	_logic_inject()

func _logic_inject() -> void:
	pass

## SPRITE
# Calculates which way to fip the sprite using move direction
func _flip_sprite() -> void:
	if dont_flip_sprite():
		return
	
	var angle = parent.velocity.normalized().angle()
	var angle_deg = round(rad2deg(angle))
	if angle_deg == 90 or angle_deg == -90:
		return # Stop execution
	if angle_deg > -90 and angle_deg < 90:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

func dont_flip_sprite() -> bool:
	return not parent.is_moving and parent.move_direction != Vector2.ZERO


## TRANSITIONS
func transition_conditions(transition: int) -> bool:
	return transition != -1 and parent.states_reset

func _get_transition() -> int:
	if parent.frozen:
		return -1 # Stop execution
	
	return _transition_query()

func _transition_query() -> int:
	match state:
		states.STAGGERED:
			if parent.dead:
				return states.DEAD
			if not parent.staggered:
				return states.IDLE
		states.TAKE_DAMAGE:
			if parent.dead:
				return states.DEAD
			if parent.staggered:
				return states.STAGGERED
			if not parent.taking_damage:
				return states.IDLE
		states.WALK:
			if parent.dead:
				return states.DEAD
			if parent.staggered:
				return states.STAGGERED
			if parent.taking_damage:
				return states.TAKE_DAMAGE
			if not parent.is_moving:
				return states.IDLE
		states.IDLE:
			if parent.dead:
				return states.DEAD
			if parent.staggered:
				return states.STAGGERED
			if parent.taking_damage:
				return states.TAKE_DAMAGE
			if parent.is_moving:
				return states.WALK
	return -1

## STATE CHANGES
func _enter_state(_previous_state: int, new_state: int) -> void:
	_play_animation(new_state)
	match new_state:
		states.STAGGERED:
			parent.attacking = false
		states.TAKE_DAMAGE:
			parent.attacking = false
	_enter_inject(new_state)

func _enter_inject(new_state: int) -> void:
	pass

func _play_animation(state: int) -> void:
	if parent.frozen:
		return # Stop execution
	var animation_name = animation_names[state]
	if animation_name == animation_player.current_animation:
		return # Stop execution
	
	animation_player.stop(true)
	animation_player.play(animation_name)
	current_animation = state

func _exit_state(_state_exited: int) -> void:
	parent.state_reset()
