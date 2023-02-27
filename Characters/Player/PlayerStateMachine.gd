extends CharacterStateMachine

# Child Nodes
onready var aim_pivot_melee: AimPivot = parent.get_node("AimPivotMelee")
onready var aim_pivot_ranged: AimPivot = parent.get_node("AimPivotRanged")

func _init_inject() -> void:
	_add_state("DASH")

## TICK
func _logic_inject() -> void:
	parent._move_pivot_rotation()
	if aim_pivot_melee.attack_movement:
		aim_pivot_melee.attack_movement()
	else:
		parent.get_input()


## TRANSITIONS
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
		states.DASH:
			if parent.dead:
				return states.DEAD
			if parent.staggered:
				return states.STAGGERED
			if parent.taking_damage:
				return states.TAKE_DAMAGE
			if not parent.target_dashing and not parent.dashing:
				return states.IDLE
		states.WALK:
			if parent.dead:
				return states.DEAD
			if parent.staggered:
				return states.STAGGERED
			if parent.taking_damage:
				return states.TAKE_DAMAGE
			if parent.target_dashing or parent.dashing:
				return states.DASH
			if not parent.is_moving:
				return states.IDLE
		states.IDLE:
			if parent.dead:
				return states.DEAD
			if parent.staggered:
				return states.STAGGERED
			if parent.taking_damage:
				return states.TAKE_DAMAGE
			if parent.target_dashing or parent.dashing:
				return states.DASH
			if parent.is_moving:
				return states.WALK
	return -1


## STATE CHANGES
func _enter_inject(new_state: int) -> void:
	match new_state:
		states.DEAD:
			aim_pivot_melee.visible = false
			aim_pivot_ranged.visible = false
