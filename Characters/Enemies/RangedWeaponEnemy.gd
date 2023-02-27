extends WeaponEnemy
class_name RangedWeaponEnemy

onready var attack_timer: Timer = $Traits/AttackTimer


func _chasing_inject() -> void:
	if chasing:
		attack_timer.start()
	else:
		attack_timer.stop()

func _on_AimPivot_weapon_ready():
	weapon = aim_pivot.weapon
	weapon.damage = damage
	weapon.enemy_weapon = true


## STATE CHANGE FUNCTIONS
func _reset_inject() -> void:
	attack_locked = false
	idle = false
	if is_instance_valid(weapon):
		weapon.visible = true
		weapon.idle()


func _on_AttackTimer_timeout():
	attacking = true
	attack_timer.wait_time = rand_range(2,6)
	attack_timer


## DEATH
func NPC_death() -> void:
	queue_free()
