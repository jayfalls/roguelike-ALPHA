extends CharacterStateMachine

# Reference all the base animations
func _init_inject() -> void:
	_add_state("CHASE")
	_add_state("ATTACK")
	_add_state("DAMAGE_RECOVERY")
	_add_state("SPAWN")

func _ready_inject() -> void:
	set_state(states.SPAWN)


func dont_flip_sprite() -> bool:
	return not parent.is_moving and parent.move_direction != Vector2.ZERO and parent.damage_recovered


## TRANSITIONS
func _transition_query() -> int:
	match state:
		states.SPAWN:
			if not parent.spawning:
				return states.IDLE
		states.STAGGERED:
			if parent.dead:
				return states.DEAD
			if not parent.staggered:
				return states.IDLE
		states.DAMAGE_RECOVERY:
			if parent.dead:
				return states.DEAD
			if parent.staggered:
				return states.STAGGERED
			if parent.damage_recovered:
				return states.IDLE
		states.TAKE_DAMAGE:
			if parent.dead:
				return states.DEAD
			if parent.staggered:
				return states.STAGGERED
			if not parent.damage_recovered:
				return states.DAMAGE_RECOVERY
		states.ATTACK:
			if parent.dead:
				return states.DEAD
			if parent.staggered:
				return states.STAGGERED
			if parent.taking_damage:
				return states.TAKE_DAMAGE
			if not parent.attacking:
				return states.IDLE
		states.CHASE:
			if parent.dead:
				return states.DEAD
			if parent.staggered:
				return states.STAGGERED
			if parent.taking_damage:
				return states.TAKE_DAMAGE
			if parent.attacking:
				return states.ATTACK
			if not parent.chasing:
				return states.WALK
			if not parent.is_moving:
				return states.IDLE
		states.WALK:
			if parent.dead:
				return states.DEAD
			if parent.staggered:
				return states.STAGGERED
			if parent.taking_damage:
				return states.TAKE_DAMAGE
			if parent.attacking:
				return states.ATTACK
			if parent.chasing:
				return states.CHASE
			if not parent.is_moving:
				return states.IDLE
		states.IDLE:
			if parent.dead:
				return states.DEAD
			if parent.staggered:
				return states.STAGGERED
			if parent.taking_damage:
				return states.TAKE_DAMAGE
			if parent.attacking:
				return states.ATTACK
			if parent.is_moving:
				return states.WALK
	return -1
