extends Weapon

# Child Nodes
var projectile: Resource
onready var aim_arrow: Sprite = $AimArrow

# Stats
var player_path: String = "res://Characters/Player/Projectiles/"
var enemy_path: String = "res://Characters/Enemies/Projectiles & Obstacles/"

# States
var attack_drawn: bool = false

## DECLARATION
func _ready():
	yield(get_tree(),"idle_frame")
	weaponsTable = RunManager.lootManager.tables[1] # Weapons loot table


## STATE CHANGES
func _change_inject(choice: int) -> void:
	# Assign stats and states
	if not enemy_weapon:
		damage = weaponsTable.weapons_damage[choice]
	attack_speed = weaponsTable.weapons_speed[choice] * attack_speed_modifier
	spritePath = weaponsTable.sprite_paths[choice].replace(".png","_sheet.png")
	sprite.texture = load(spritePath)
	animation_player.playback_speed = 1
	
	var weaponName: String = weaponsTable.weapon_names[choice]
	var path_string: String 
	if enemy_weapon:
		path_string = enemy_path
		aim_arrow.texture = null
	else:
		path_string = player_path
	if weaponName.begins_with("Staff"):
		projectile = load(path_string + "Magic.tscn")
	else:
		projectile = load(path_string + weaponName + ".tscn")

## STATES
func idle() -> void:
	animation_player.stop()
	move()
	normal_move()
	if enemy_weapon:
		return
	visible = false
	attack_drawn = false

func wind_up() -> void:
	if weapon == -1:
		idle()
		parent.state_popup.popup("No Weapon", Color(1, 0, 0))
		return
	visible = true
	attack_drawn = false
	animation_player.stop()
	if enemy_weapon:
		animation_player.play("Drawn")
	else:
		animation_player.play("WindUp")

## ATTACK
func weapon_drawn() -> void:
	animation_player.play("Drawn")
	move()
	if enemy_weapon:
		return
	slow_move()
	attack_drawn = true

func _attack_inject() -> void:
	normal_move()
	if attack_drawn or enemy_weapon:
		var shot: Projectile = projectile.instance()
		shot.global_position = global_position
		shot.move_direction = Vector2(cos(aim_pivot.rotation), sin(aim_pivot.rotation))
		get_tree().root.add_child(shot)
		shot.hitbox.damage = damage
	attack_finished()
	attack_drawn = false
	idle()
