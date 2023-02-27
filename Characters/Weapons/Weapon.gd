extends Node2D
class_name Weapon

# Outside References
var weaponsTable: LootTable # Weapons loot table

var parent: Character
onready var aim_pivot = get_parent()
# Child Nodes
onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite
onready var flashTimer: Timer = $Hitbox/FlashAttackTimer

# Stats
var enemy_weapon: bool = false
var damage: int setget set_damage
var attack_speed: float = 1
var attack_speed_modifier: float = 1

# States
var weapon = -1
var spritePath: String


## STATE CHANGES
# Loads a weapon from the weapon loot table
func change_weapon(choice: int) -> void:
	_change_inject(choice)
	
	if parent.sprite.visible == false:
		visible = false
	else:
		visible = true
	idle()
	weapon = choice

func _change_inject(choice: int) -> void:
	pass

func set_damage(input: int) -> void:
	damage = input


## SIGNALS
func move() -> void:
	parent.can_move = true

func stop_moving() -> void:
	parent.can_move = false

func attack_moving() -> void:
	aim_pivot.attack_movement = true

func attack_moving_stop() -> void:
	aim_pivot.attack_movement = false

func slow_move() -> void:
	parent.slow_move = true

func normal_move() -> void:
	parent.slow_move = false


## STATES
func idle() -> void:
	animation_player.play("Idle")

func wind_up() -> void:
	if weapon == -1:
		parent.state_popup.popup("No Weapon", Color(1, 0, 0))
		return
	animation_player.play("WindUp")

## ATTACK
func attack() -> void:
	if weapon == -1:
		idle()
		parent.state_popup.popup("No Weapon", Color(1, 0, 0))
		return
	
	parent.attacking = true
	animation_player.playback_speed = attack_speed
	_attack_inject()

func _attack_inject() -> void:
	pass

func attack_finished() -> void:
	parent.attacking = false
	idle()
