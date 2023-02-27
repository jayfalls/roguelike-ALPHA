extends Character
class_name Enemy

signal target_reached
signal path_changed(path) # Path Debugging


# Child Nodes
onready var nav_agent: NavigationAgent2D = $Traits/NavigationAgent2D
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var soft_collision: Area2D = $Collision/SoftCollision
onready var hitbox: Area2D = $Collision/Hitbox
onready var attack_zone: Area2D = $Collision/AttackZone
onready var attack_zone_timer: Timer = $Collision/AttackZone/AttackCooldown
onready var spawn_eff: PackedScene = preload("res://Effects/SpawnEffect.tscn")

# External Info
var room: YSort setget _room_generated
var player: Character
var player_dead: bool = false

# Stats
export(int) var PLAYER_DISTANCE: int = 40
var original_position: Vector2
var spawn_positions: Array
var damage: int = 10

# States
var spawning: bool = true
var dont_wander: bool = false
var stuck: bool = false
var idle: bool = false
var chasing: bool = false setget _chasing_switch
var pathing: bool = false
var target_position: Vector2 setget _set_target_location
var target_reached: bool = false
var attack_locked: bool = false
var damage_recovered: bool = true

# Debugging
var path_debugging: bool = false

## DECLARATION
func _ready_inject() -> void:
	sprite.visible = false
	npc = true
	_start_wander()
	yield(get_tree(), "idle_frame")
	state_reset()
	self.target_position = original_position
	hurtbox.set_deferred("monitoring", false)
	var spwn_eff: Effect = spawn_eff.instance()
	add_child(spwn_eff)
	yield(get_tree().create_timer(1.2), "timeout")
	var spwn_eff2: Effect = deathEffect.instance()
	add_child(spwn_eff2)
	spwn_eff2.global_position = sprite.global_position
	sprite.visible = true
	spawning = false

# Assigns wander variables and state
func _start_wander() -> void:
	if dont_wander:
		return
	chasing = true
	self.chasing = false

# Runs when room variable gets a reference
func _room_generated(input):
	room = input
	player = room.player


## STATE CHANGES
# Called whenever the target_position is set
func _set_target_location(input) -> void:
	target_position = input
	nav_agent.set_target_location(target_position)

# Called everytime the chasing variable is changed
func _chasing_switch(input) -> void:
	# Determines whether to execute or not
	if input == chasing:
		return # Stops execution
	
	# Changes the movement variables to the desired state
	if input:
		MAX_SPEED = slow_max_speed * 2
		ACCELERATION = slow_acceleration * 2
		attack_zone.monitoring = true
		hurtbox.monitoring = true
	else:
		MAX_SPEED = slow_max_speed
		ACCELERATION = slow_acceleration
	
	chasing = input
	_chasing_inject()

func _chasing_inject() -> void:
	pass

func _reset_inject() -> void:
	hitbox.damage_off()
	#attacking = false
	attack_locked = false
	idle = false

func lock_attack_position() -> void:
	attack_locked = true

func unlock_attack_position() -> void:
	attack_locked = false

func recovering() -> void:
	yield(get_tree().create_timer(KNOCKBACK_TIME - 0.1),"timeout")
	damage_recovered = false
	can_move = false

func recovered() -> void:
	damage_recovered = true
	can_move = true


func _physics_process(_delta):
	_soft_collision()

## MOVEMENT
# Picks a random spawn tile
func random_spawntile() -> Vector2:
	var choice: int = maths.rand_range_modulo(spawn_positions.size() - 1)
	return spawn_positions[choice]

func get_nav_farther_than(point: Vector2, distance: int) -> Vector2:
	distance *= distance
	var choice: Vector2
	for pos in spawn_positions:
		var dist: float = point.distance_squared_to(pos)
		if dist > distance:
			choice = pos
			return choice
	return random_spawntile() # If no matching points are found

func NPC_movement() -> void:
	_movement()

# Determines type of movement
func _movement() -> void:
	if idle or is_moving:
		stuck = false
	elif target_position.distance_squared_to(global_position) > 4:
		stuck = true
	
	if not pathing:
		# Normal movement
		move_direction = global_position.direction_to(target_position)
		_calc_movement()
		move_and_slide(velocity)
		return # Stops execution
	
	# Else
	_pathing()

## PATHING
func _pathing() -> void:
	if target_reached:
		move_direction = Vector2.ZERO
		emit_signal("path_changed", []) # Path Debugging
	else:
		move_direction = global_position.direction_to(nav_agent.get_next_location())
	
	_calc_movement()
	move_and_slide(velocity)

# Stops pathing to the target in the AI tree and in movement
func _on_NavigationAgent2D_target_reached():
	target_reached = true
	emit_signal("target_reached")


# Path Debugging
var pathing_line: Line2D
func _on_NavigationAgent2D_path_changed():
	if not path_debugging:
		return
	
	emit_signal("path_changed", nav_agent.get_nav_path())
func _on_Enemy_path_changed(path: Array):
	if not path_debugging:
		pathing_line.queue_free()
		return
	
	if not is_instance_valid(pathing_line):
		pathing_line = Line2D.new()
	
	if not pathing_line.is_inside_tree():
		pathing_line.width = 5
		var root = get_tree().root
		root.add_child(pathing_line)
	if path.empty():
		pathing_line.hide()
	else:
		pathing_line.show()
		pathing_line.points = path


## COLLISION
# Pushes the character away from any other softbodies it's colliding with
func _soft_collision() -> void:
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * get_physics_process_delta_time() * 400


## ATTACK DETECTION
# When the player is detected, start attacking, switching off detection
func _on_AttackZone_body_entered(_body):
	if player_dead:
		return # Stops execution
	
	attacking = true
	attack_zone.set_deferred("monitoring", false)
	attack_zone_timer.start()

# Switch detection back on after some time
func _on_AttackCooldown_timeout():
	attack_zone.set_deferred("monitoring", true)


## ATTACKING
func attack() -> void:
	if attack_locked:
		return # Stop execution
	target_position = player.global_position
	dash_position = player.global_position
	hitbox.aim_direction = move_direction


## DEATH
func NPC_death() -> void:
	queue_free()
