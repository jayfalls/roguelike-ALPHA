extends Weapon

enum SPAWN_TYPES {
	DIRECTED = 0,
	RANDOM = 1
}

var spawn_type: int = SPAWN_TYPES.DIRECTED

var projectile_names: Array = [""]

# Child Nodes
var projectile: Resource


## STATE CHANGES
func _change_inject(choice: int) -> void:
	# Assign stats and states
	damage = weaponsTable.weapons_damage[choice]
	attack_speed = 1 * attack_speed_modifier
	
	# Load slash effect
	var weaponName: String = weaponsTable.weapon_names[choice]
	var path_string: String 
	if weaponName.begins_with("Staff"):
		projectile = load(path_string + "Magic.tscn")
	else:
		projectile = load(path_string + weaponName + ".tscn")

## STATES
func idle() -> void:
	animation_player.stop()


## ATTACK
func _attack_inject() -> void:
	var shot: Projectile = projectile.instance()
	shot.global_position = global_position
	shot.hitbox.damage = damage
	shot.move_direction = Vector2(cos(aim_pivot.rotation), sin(aim_pivot.rotation))
	get_tree().root.add_child(shot)
	attack_finished()
	idle()
