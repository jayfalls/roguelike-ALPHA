extends Enemy
class_name WeaponEnemy

# Child nodes
onready var aim_pivot: AimPivot = $AimPivot
var weapon: Weapon

# Stats
export(int) var WEAPON_INDEX: int = 0 # The index of the weapon in the database

## DECLARATION
func _ready_extend() -> void:
	yield(get_tree(), "idle_frame")
	weapon.change_weapon(WEAPON_INDEX)
	yield(get_tree().create_timer(1.5), "timeout")
	weapon.visible = true

func _on_AimPivot_weapon_ready():
	weapon = aim_pivot.weapon
	weapon.damage = damage
	weapon.enemy_weapon = true
	weapon.hitbox.set_collision_mask_bit(2, true)
	weapon.hitbox.set_collision_mask_bit(4, false)


## STATE CHANGE FUNCTIONS
func _reset_inject() -> void:
	hitbox.damage_off()
	attack_locked = false
	idle = false
	if is_instance_valid(weapon):
		weapon.stop_slash()


## DEATH
func NPC_death() -> void:
	weapon.clear_slash_effect()
	queue_free()
