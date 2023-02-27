extends KinematicBody2D
class_name Character

signal taken_damage
signal taken_shielddamage
signal dead
signal weak
signal unweak


# Child Nodes
onready var stats: Node = $Traits/Stats
onready var sprite = $Sprite
onready var hurtbox = $Collision/Hurtbox
onready var deathSFX = $SFX/Death
onready var hurtSFX = $SFX/Hurt
onready var animationPlayer = $AnimationPlayer
onready var state_popup : StatePopup = $StatePopup

# Damage Effects
const hitEffect: PackedScene = preload("res://Effects/HitEffect.tscn")
const deathEffect: PackedScene = preload("res://Effects/SmokePoof.tscn")
onready var shieldShader: ShaderMaterial = preload("res://Effects/Shaders/shieldMaterial.tres")
onready var fireEffect: PackedScene = preload("res://Effects/Fire.tscn")
onready var weakEffect: PackedScene = preload("res://Effects/Weakness.tscn")
onready var chainHitbox: PackedScene = preload("res://Characters/Collision Detection/ChainHitbox.tscn")

# Stats
var old_position: Vector2 = Vector2.ZERO
export(int) var ACCELERATION: int = 700
export(int) var MAX_SPEED: int = 100
export(int) var slow_modifier: int = 2
onready var slow_max_speed: int = int(MAX_SPEED / slow_modifier)
onready var slow_acceleration: int = int(ACCELERATION / slow_modifier)
const FRICTION: float = 0.15
const dash_slow_down: float = 0.8
export(float) var KNOCKBACK_TIME: float = 0.4
var knockback_acceleration: int = 800
var knockback_maxspeed: int = 60
var npc: bool = false
var trap_resistant: bool = false
var shield_break_invincibility: int = 0
var low_health_invincibility: int = 0
var boss_shieldDamage_modifier: int = 0

# States
var tick_time: float = 0
var move_direction: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var can_move: bool = true
var is_moving: bool = false
var slow_move: bool = false setget move_slow
var frozen: bool = false setget _freeze # Pauses animation changes
var dashing: bool = false
var target_dashing = false
var invincible: bool = false
var shielded: bool = false
var attacking: bool = false
var taking_damage: bool = false
var staggered: bool = false
var on_fire: bool = false
var weak: bool = false
var dead: bool = false

# Logic Info
var dash_position: Vector2
var damaging_hitbox: Node2D
var damage_to_take: int
var knockback_direction: Vector2
var knockback_multiplier: float
var states_reset: bool = true

## DECLARATION
func _ready():
	yield(get_tree(), "idle_frame")
	_character_initialisation()
	_ready_inject()
	_ready_extend()

func _character_initialisation() -> void:
	if stats.SHIELD > 0:
		shielded = true
	if shielded:
		stats.MAXSHIELD = stats.MAXHEALTH / 2
		stats.SHIELD = stats.MAXHEALTH
		sprite.material = shieldShader

func _ready_inject() -> void:
	pass

func _ready_extend() -> void:
	pass


## STATE CHANGES
# Happens when frozen variable is assigned
func _freeze(input) -> void:
	# Determines whether to execute or not
	var switch: bool = input != frozen
	if not switch:
		return # Stops execution
	
	# Pauses or starts animation
	if input:
		animationPlayer.stop(false)
	else:
		animationPlayer.play()
	
	frozen = input

func move_slow(input) -> void:
	# Determines whether to execute or not
	if input == slow_move:
		return # Stops execution
	
	# Changes the movement variables to the desired state
	if input:
		MAX_SPEED = slow_max_speed
		ACCELERATION = slow_acceleration
	else:
		MAX_SPEED = slow_max_speed * slow_modifier
		ACCELERATION = slow_acceleration * slow_modifier
	
	slow_move = input

## STATE CHANGE FUNCTIONS
func state_reset() -> void:
	states_reset = false
	sprite.flip_v = false
	can_move = true
	dashing = false
	target_dashing = false
	sprite.scale = Vector2.ONE
	sprite.rotation = 0
	_reset_inject()
	states_reset = true

func _reset_inject() -> void:
	pass

func stop_moving() -> void:
	can_move = false

func start_moving() -> void:
	can_move = true

func stop_attacking() -> void:
	attacking = false

func target_dash() -> void:
	target_dashing = true


## MOVEMENT
func _move() -> void:
	if can_move and not staggered:
		if npc:
			NPC_movement()
		else:
			_calc_movement()
			move_and_slide(velocity)
	
	# Friction
	velocity = velocity.linear_interpolate(Vector2.ZERO, FRICTION)


func NPC_movement() -> void:
	pass

# Calculates movement vectors
func _calc_movement() -> void:
	move_direction = move_direction.normalized()
	tick_time += get_physics_process_delta_time()
	if tick_time > 0.1:
		tick_time = 0
		_moving()
	
	velocity += move_direction * ACCELERATION * get_physics_process_delta_time()
	velocity = velocity.limit_length(MAX_SPEED)
	
	if taking_damage:
		_knockback()
	elif dashing:
		_dash()
	elif target_dashing:
		_dash_target()

# Is the character moving?
func _moving() -> void:
	if global_position.distance_squared_to(old_position) < 3:
		is_moving = false
	else:
		is_moving = true
	old_position = global_position


## DASHING
# Double speed, slowing down exponentially to a fraction of the original velocity as you reach a target
func _dash_target() -> void:
	velocity = lerp(velocity * dash_slow_down, velocity * 2, range_lerp(global_position.distance_to(dash_position), 0, 30, 0, 1))

# Modify speed by a set amount
func _dash() -> void:
	velocity = velocity * 1.5


## KNOCKBACK
# Calculate knockback direction and force
func _knockback() -> void:
	if is_instance_valid(damaging_hitbox): 
		velocity += knockback_direction * knockback_acceleration * knockback_multiplier * get_physics_process_delta_time()
		velocity = velocity.limit_length(knockback_maxspeed)


## DAMAGE DETECTION
func _on_Hurtbox_area_entered(area):
	damaging_hitbox = area
	damage_to_take = damaging_hitbox.damage
	
	var no_trap_damage: bool = damaging_hitbox.TRAP and trap_resistant
	if invincible or no_trap_damage:
		return # Stops execution
	
	damage_sequence()

func _on_Hurtbox_invincibility_started():
	invincible = true

func _on_Hurtbox_invincibility_ended():
	invincible = false


## TAKING DAMAGE
func damage_sequence() -> void:
	move_direction = Vector2.ZERO
	velocity = Vector2.ZERO
	
	_hitbox_checks()
	_calc_stagger(damaging_hitbox.staggerChance)
	_modifier_damage()
	_standard_damage()

# Misc things to do after taking damage
func _hitbox_checks() -> void:
	var attacked_by_player: bool = npc and damaging_hitbox.PLAYER_WEAPON_HITBOX
	if attacked_by_player:
		damaging_hitbox.playerFocus()
	if damaging_hitbox.CHAIN_HITBOX:
		state_popup.popup("Chain Damage", Color(0.043137, 0.752941, 0))
	elif not damaging_hitbox.CHAIN_HITBOX:
		damaging_hitbox.damage_off()
	if not damaging_hitbox.non_character:
		_hitStop(attacked_by_player)


## REGULAR DAMAGE
func _standard_damage() -> void:
	hurtSFX.play()
	velocity = Vector2.ZERO
	if not shielded:
		knockback_direction = damaging_hitbox.aim_direction.normalized()
		knockback_multiplier = damaging_hitbox.KNOCKBACK_MULTIPLIER
		taking_damage = true
		stop_attacking()
	_spawn_hiteffect()
	
	if stats.SHIELD > 0:
		_shieldDamage()
	else:
		_healthDamage(damage_to_take)

func _shieldDamage() -> void:
	if damaging_hitbox.BOSS == true and boss_shieldDamage_modifier != 0:
		state_popup.popup("Boss Damage Reduced", Color(0, 0.6, 1))
		damage_to_take += damage_to_take / 100 * boss_shieldDamage_modifier
	
	if damaging_hitbox.half_shieldDamage:
		stats.SHIELD -= damage_to_take / 2
	elif not damaging_hitbox.half_shieldDamage and damaging_hitbox.PLAYER_WEAPON_HITBOX:
		state_popup.popup("Double Shield Damage", Color(0, 0.6, 1))
	else:
		stats.SHIELD -= damage_to_take
	state_popup.popup(str(damage_to_take / 2), Color(0, 0.736328, 1))
	
	emit_signal("taken_shielddamage")
	if stats.SHIELD <= 0:
		state_popup.popup("ShieldBroken", Color(0, 0.6, 1))
		state_popup.popup(str(stats.SHIELD), Color(1, 0, 0))
		stats.health += stats.SHIELD
		stats.SHIELD = 0
		emit_signal("taken_damage")
		hurtbox.start_invincibility(shield_break_invincibility)
		sprite.set_material(null) 
		shielded = false
	
	_health_check()

func _healthDamage(damage: int) -> void:
	stats.health -= damage
	state_popup.popup(str(damage), Color(1, 0, 0))
	emit_signal("taken_damage")
	_health_check()

# Determines if dead
func _health_check() -> void:
	if stats.health <= 0:
		deathSFX.play()
		hurtbox.set_deferred("monitoring", false)
		yield(deathSFX, "finished")
		death()
		return # Stops execution
	
	if stats.health < stats.MAXHEALTH * 0.1:
		hurtbox.start_invincibility(low_health_invincibility)
	
	yield(get_tree().create_timer(KNOCKBACK_TIME), "timeout")
	taking_damage = false


## MODIFIER DAMAGE
func _modifier_damage() -> void:
	var modifier = damaging_hitbox.modifier
	if modifier < 1:
		return # Stop execution
	if stats.SHIELD > 0 and modifier == 4:
		damage_to_take *= damaging_hitbox.modifier_value
		state_popup.popup("Shield Damage", Color(0, 0.684265, 0.867188))
		_shieldDamage()
		return # Stop execution
	elif shielded:
		state_popup.popup("Deflected", Color(0, 0.6, 1))
		return # Stop execution
	
	match modifier:
		1:
			if not on_fire:
				state_popup.popup("On Fire", Color(1, 0.4, 0))
				_catch_fire()
		2:
			if not weak:
				state_popup.popup("Weak", Color(0.71875, 0, 0.572754))
				_weakness()
		3:
			var parent = get_tree().root
			var chainBox = chainHitbox.instance()
			chainBox.damage = damaging_hitbox.modifier_value
			chainBox.global_position = position
			parent.add_child(chainBox)
		5:
			if not staggered:
				_calc_stagger(damaging_hitbox.modifier_value)


# Fire Damage
func _catch_fire() -> void:
	on_fire = true
	var timeout: float = damaging_hitbox.modifier_value
	var fire = fireEffect.instance()
	sprite.add_child(fire)
	fire.global_position = sprite.global_position
	fire.timeout = timeout
	var timer = get_tree().create_timer(timeout)
	timer.connect("timeout", self, "stop_fire")
	while on_fire:
		_healthDamage(1)
		yield(get_tree().create_timer(0.5), "timeout")

func stop_fire() -> void:
	on_fire = false


# Weakness
func _weakness() -> void:
	weak = true
	var timeout: float = damaging_hitbox.modifier_value
	var weakEff = weakEffect.instance()
	sprite.add_child(weakEff)
	weakEff.global_position = sprite.global_position
	weakEff.timeout = timeout
	var timer = get_tree().create_timer(timeout)
	timer.connect("timeout", self, "stop_weak")
	emit_signal("weak")

func stop_weak() -> void:
	weak = false
	emit_signal("unweak")


## STAGGER
func _calc_stagger(staggerChance: int) -> void:
	if staggered:
		return # Stop execution
	var starting_point: int = maths.rand_range_modulo(100 - staggerChance)
	var choice_range: Array = range(starting_point, starting_point + staggerChance)
	var choice: int = maths.rand_range_modulo(100)
	if choice in choice_range:
		_stagger()

func _stagger() -> void:
	state_popup.popup("Staggered", Color(0.972656, 0.934662, 0))
	can_move = false
	staggered = true
	yield(get_tree().create_timer(damaging_hitbox.STAGGER_DURATION), "timeout")
	can_move = true
	staggered = false


## HIT EFFECTS
func _hitStop(attacked_by_player: bool) -> void:
	# Freeze characters
	can_move = false
	self.frozen = true
	
	
	var otherChar: Character
	var otherCharWeapon
	if attacked_by_player:
		otherCharWeapon = damaging_hitbox.get_parent()
		otherChar = get_tree().get_nodes_in_group("Player").pop_front()
		otherCharWeapon.animation_player.stop(false)
		otherChar.can_move = false
		otherChar.frozen = true
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	# Reanimate characters
	can_move = true
	self.frozen = false
	
	if attacked_by_player:
		otherCharWeapon.animation_player.play()
		otherChar.can_move = true
		otherChar.frozen = false

func _spawn_hiteffect():
	var effect = hitEffect.instance()
	var parent = get_tree().root
	parent.add_child(effect)
	effect.global_position = sprite.global_position


## DEATH
func death() -> void:
	var effect = deathEffect.instance()
	var parent = get_tree().root
	parent.add_child(effect)
	effect.position = sprite.global_position
	can_move = false
	dead = true
	emit_signal("dead")
	if npc:
		NPC_death()

func NPC_death() -> void:
	pass
