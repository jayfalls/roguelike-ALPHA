extends Weapon

# Child Nodes
var slash_effect setget load_slash
onready var trail_effect = preload("res://Effects/Trail.tscn")
var trails: Array
var trail_points: Array
onready var collisionAnimPlayer = $Hitbox/AnimationPlayer
onready var hitbox = $Hitbox
onready var swoosh = $SFX/Swoosh
onready var comboTimer = $ComboTimer

# Stats
var stamina_loss: float = 1
#var stamina_loss_modifier: float = 1 setget update_staminaCost
var collision_size: String

# States
enum SIZES {
	SMALL,
	MEDIUM,
	LARGE,
	HUGE
}
var size: String
var combo_counter: int = 1


## DECLARATION
func _ready():
	yield(get_tree(),"idle_frame")
	weaponsTable = RunManager.lootManager.tables[0] # Weapons loot table


## STATE CHANGES
func _change_inject(choice: int) -> void:
	# Assign stats and states
	if enemy_weapon:
		hitbox.damage = damage
	else:
		hitbox.damage = weaponsTable.weapons_damage[choice]
	attack_speed = weaponsTable.weapons_speed[choice] * attack_speed_modifier
	size = weaponsTable.weapons_size[choice]
	stamina_loss = weaponsTable.weapons_staminaCost[choice]# * stamina_loss_modifier
	spritePath = weaponsTable.sprite_paths[choice]
	sprite.texture = load(spritePath)
	collision_size = weaponsTable.weapons_collisionSize[choice]
	animation_player.playback_speed = 1
	collisionAnimPlayer.play(collision_size)
	
	# Load slash effect
	var weaponName: String = weaponsTable.weapon_names[choice]
	if weaponName.ends_with("Sword"):
		self.slash_effect = load("res://Characters/Weapons/MeleeWeapon/Slashes/SwordSlash.tscn")
	else:
		self.slash_effect = load("res://Characters/Weapons/MeleeWeapon/Slashes/" + weaponName + "Slash.tscn")

"""
func update_staminaCost(input) -> void:
	stamina_loss = stamina_loss / stamina_loss_modifier
	stamina_loss_modifier = input
	stamina_loss = stamina_loss * stamina_loss_modifier
"""

func _on_ComboTimer_timeout():
	combo_counter = 1


## STATES
## ATTACK
func _attack_inject() -> void:
	if parent.has_method("_lose_stamina"):
		parent._lose_stamina(stamina_loss)
	comboTimer.stop()
	comboTimer.start()
	animation_player.play(size + "Attack" + str(combo_counter))
	if combo_counter == 3:
		combo_counter = 1
	else:
		combo_counter += 1

## FLASH ATTTACK
# Periodically turn damage on and off
func flash_attack() -> void:
	flashTimer.start()
	hitbox.set_deferred("monitorable", true)

func _on_FlashAttackTimer_timeout():
	hitbox.set_deferred("monitorable", false)
	hitbox.set_deferred("monitorable", true)

func stop_flash() -> void:
	flashTimer.stop()
	hitbox.set_deferred("monitorable", false)


## SLASH EFFECT
func load_slash(input):
	clear_slash_effect()
	slash_effect = input.instance()
	sprite.add_child(slash_effect)
	
	trail_points = slash_effect.get_children()
	var count: int = 0
	for trail_point in trail_points:
		var trail = trail_effect.instance()
		trail.trail_point = trail_point
		trail.visible = false
		trail.length = slash_effect.trail_lengths[count]
		trail.width = slash_effect.trail_widths[count]
		trail.default_color = slash_effect.trail_colors[count]
		get_tree().root.add_child(trail)
		trails.append(trail)
		
		count += 1

func clear_slash_effect() -> void:
	if not !slash_effect:
		slash_effect.queue_free()
	var count: int = 0
	for trail in trails:
		trail.queue_free()
		trail_points[count].queue_free()
	trail_points.clear()
	trails.clear()

func slash() -> void:
	for trail in trails:
		trail.clear_points()
		trail.visible = true

func stop_slash() -> void:
	for trail in trails:
		trail.visible = false
