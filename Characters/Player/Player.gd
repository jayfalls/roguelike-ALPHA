extends Character

signal assignment_ready
#signal update_stamina(recovery_time)
signal update_health(increase_maxHealth)
signal update_shield(increase_maxShield)


# Outside References
var HUD: Control
onready var lootManager = RunManager.lootManager

# Child Nodes
onready var aim_pivot_melee: AimPivot = $AimPivotMelee
#var melee_weapon: Weapon
onready var aim_pivot_ranged: AimPivot = $AimPivotRanged
#var ranged_weapon: Weapon
#var ranged_weapon: Weapon
onready var movePivot = $MovePivot
onready var dashPoint = $MovePivot/DashPoint
onready var items = $Traits/Items

# Stats
var stamina_wait: float = 2 #How long to wait before recovering stamina
var staminaRecovery_multiplier: float = 0.8 #Lower means longer recovery times
var dashCost: float = 2 #How much stamina a dash costs
var dash_cooldown_time: float = 0.9 #How long before player can dash again
var invincibility_timeout: float = 0.4
var dash_time: float = 0.4
var new_room_regen: int = 0

# States
var paused: bool = false
var stamina_blocked: bool = false
var dash_cooldown: bool = false

# Ultimate Stats/States
enum ULTIMATE_ATTACKS {
	RUSH,
	RAGE,
	TOUGH_SKIN,
	STAR_POWER,
	YOUTHFULNESS,
	SOUL_REAPER
}
var ultimate_attack_index: int = -1
var ultimate_attacking: bool = false
var ultimate_value: int
onready var ultimateExplosion_effect = $AreaExplosion


## DECLARATION
func _ready_inject():
	yield(get_tree(), "idle_frame")
	HUD = UIManager.HUD
	HUD.stats = stats
	HUD.player_items = items
	stats.HUD = HUD
	slow_max_speed = MAX_SPEED / 4
	slow_acceleration = ACCELERATION / 4
	stats.parent = self
	emit_signal("assignment_ready")

func _on_AimPivotMelee_weapon_ready():
	aim_pivot_melee.weapon.scale = Vector2(0.7,0.7)
	aim_pivot_melee.hitbox.connect("focus", self, "_focus")

func _on_AimPivotRanged_weapon_ready():
	aim_pivot_ranged.weapon.scale = Vector2(0.7,0.7)


## STATE CHANGES
# Resets the player when entering a new room
func new_room() -> void:
	move_direction = Vector2.ZERO
	velocity = Vector2.ZERO
	ultimate_attacking = false
	stats.health += new_room_regen


## STATE CHANGE FUNCTIONS
func state_reset() -> void:
	states_reset = false
	#attacking = false
	sprite.scale = Vector2.ONE
	sprite.position = Vector2(0,-6)
	sprite.rotation = 0
	states_reset = true


## INPUT
func get_input() -> void:
	if not target_dashing:
		move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		move_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	if ultimate_attacking:
		return # Stop execution
	
	if Input.is_action_just_pressed("dash"):
		if stamina_blocked or stats.stamina < dashCost:
			state_popup.popup("No Stamina", Color(0, 0.686275, 0.027451))
		if not dash_cooldown and not stats.stamina < dashCost and not stamina_blocked:
			dash()
	if Input.is_action_just_pressed("attack"):
		if stamina_blocked:
			state_popup.popup("No Stamina", Color(0, 0.686275, 0.027451))
		if not attacking and not stamina_blocked and not dashing:
			aim_pivot_melee.weapon.attack()
	if Input.is_action_just_released("shoot"):
		aim_pivot_melee.visible = true
		aim_pivot_ranged.visible = false
		aim_pivot_ranged.weapon.attack()
	elif Input.is_action_just_pressed("shoot"):
		if not attacking and not stamina_blocked and not dashing:
			aim_pivot_melee.visible = false
			aim_pivot_ranged.visible = true
			aim_pivot_ranged.weapon.wind_up()
	elif Input.is_action_just_pressed("ultimate"):
		if ultimate_attack_index == -1:
			state_popup.popup("No Ultimate", Color(0.902344, 0.692399, 0.062565))
		elif stats.focus < stats.ultimateCost:
			state_popup.popup("Not Enough Focus", Color(0.797371, 0.902344, 0.062565))
		if ultimate_attack_index >= 0 and stats.focus >= stats.ultimateCost:
			ultimate_attack()


## STAMINA
func _lose_stamina(loss: float) -> void:
	stats.stamina -= loss

func _on_Stats_staminaUnblocked():
	stamina_blocked = false


## MOVEMENT
func _move_pivot_rotation() -> void:
	if move_direction != Vector2.ZERO:
		movePivot.rotation_degrees = rad2deg(move_direction.angle())

func dash() -> void:
	_lose_stamina(dashCost)
	target_dashing = true
	dash_cooldown = true
	dash_position = dashPoint.global_position
	move_direction = global_position.direction_to(dash_position)
	hurtbox.start_invincibility(invincibility_timeout)
	yield(get_tree().create_timer(dash_time), "timeout")
	target_dashing = false
	yield(get_tree().create_timer(dash_cooldown_time - dash_time), "timeout")
	dash_cooldown = false


## ULTIMATE ATTACK
func _focus():
	stats.update_focus(false)

func ultimate_attack() -> void:
	stats.update_focus(true)
	ultimate_attacking = true
	match ultimate_attack_index:
		0:
			dashing = true
			aim_pivot_melee.hitbox.damage *= 2
			hurtbox.start_invincibility(ultimate_value)
			aim_pivot_melee.weapon.flash_attack()
			yield(get_tree().create_timer(ultimate_value), "timeout")
			aim_pivot_melee.weapon.stop_flash()
			dashing = false
			aim_pivot_melee.hitbox.damage /= 2
			ultimate_over()
		1:
			#FIX
			ultimateExplosion_effect.activate()
			ultimate_over()
		2:
			hurtbox.start_invincibility(ultimate_value)
			ultimate_over()
		3:
			pass
		4:
			stats.health += ultimate_value
			emit_signal("update_health", false)
			ultimate_over()
		5:
			pass

func ultimate_over() -> void:
	ultimate_attacking = false


## LOOT
# Determines how to handle a LootItem when interacting with it
func update_loot(chosenType_index: int, chosen_index: int) -> void:
	match chosenType_index:
		0:
			aim_pivot_melee.weapon.change_weapon(chosen_index)
		1:
			aim_pivot_ranged.weapon.change_weapon(chosen_index)
		2:
			var flasksTable = lootManager.tables[chosenType_index]
			var flaskValue: int = flasksTable.flask_values[chosen_index]
			match flasksTable.flask_types[chosen_index]:
				"Shield":
					stats.SHIELD += flaskValue
					state_popup.popup("Shields Up", Color(0, 0.6, 1))
					emit_signal("update_shield", false)
				"Health":
					stats.health += flaskValue
					state_popup.popup("Healed", Color(0, 1, 0))
					emit_signal("update_health", false)
		3:
			items.coins += lootManager.tables[chosenType_index].coin_values[chosen_index]
		4:
			items.gems += lootManager.tables[chosenType_index].gem_values[chosen_index]
		5:
			HUD.show_window()
		6:
			HUD.show_window()
