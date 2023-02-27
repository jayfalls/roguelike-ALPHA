extends Position2D
class_name AimPivot

signal weapon_ready


enum WEAPON_TYPES {
	MeleeWeapon,
	RangedWeapon,
	SpawnWeapon
}
export(WEAPON_TYPES) var weapon_type = WEAPON_TYPES.MeleeWeapon
export(float) var LOOK_SMOOTHNESS: float = 0.40 # Value between 0 and 1, lower is smoother

onready var parent = get_parent()
var sprite: Sprite
var weapon: Weapon
var hitbox: Object
onready var aimArrow = $AimArrow

var look_angle: float = 0
var stored_look_position: Vector2

var snap_aim: bool = false
var attack_movement: bool = false
var target_aim: bool = false


## DECLARATION
func _ready():
	yield(get_tree(), "idle_frame")
	match weapon_type:
		WEAPON_TYPES.MeleeWeapon:
			weapon = load("res://Characters/Weapons/MeleeWeapon/MeleeWeapon.tscn").instance()
		WEAPON_TYPES.RangedWeapon:
			weapon = load("res://Characters/Weapons/RangedWeapon/RangedWeapon.tscn").instance()
	weapon.parent = parent
	add_child(weapon)
	if weapon_type == WEAPON_TYPES.MeleeWeapon:
		hitbox = weapon.hitbox
	emit_signal("weapon_ready")
	
	sprite = parent.sprite


## STATE CHANGES
func attack_movement() -> void:
	parent.move_direction = global_position.direction_to(aimArrow.global_position)

func idle() -> void:
	weapon.idle()

func wind_up() -> void:
	weapon.wind_up()

func attack() -> void:
	weapon.attack()

## TICK
func _physics_process(_delta: float) -> void:
	if parent.attacking or parent.dead or not is_instance_valid(sprite):
		return # Stop execution
	
	look()

func look() -> void:
	_look_pivot_rotation()
	_flip_direction()

# Decide on which type of aiming to use
func _look_pivot_rotation() -> void:
	if target_aim:
		_target_aim()
		return # Stop execution
	
	if snap_aim:
		_snap_aim()
		return # Stop execution
	
	_move_aim()

# For use in NPC classes that have a target, won't work without the Character having a target_position variable
func _target_aim() -> void:
	var target_pos: Vector2 = parent.target_position
	_smooth_look(global_position.direction_to(target_pos), 0.25)
	rotation_degrees = look_angle

# Snaps the aim based on how the sprite is flipped
func _snap_aim() -> void:
	if parent.sprite.flip_h:
		_smooth_look(Vector2(-1,0), 0.1)
	else:
		_smooth_look(Vector2(1,0), 0.1)
	rotation_degrees = look_angle

# Aim towards the move_direction of the Character
func _move_aim() -> void:
	rotation_degrees = look_angle
	
	if parent.move_direction == Vector2.ZERO:
		return # Stop execution
	
	_smooth_look(parent.move_direction)

# Interpolate the rotation of the pivot
func _smooth_look(look_direction: Vector2, smoothness_modifier: float = 1) -> void:
	stored_look_position = look_direction
	var look_angle_deg = lerp_angle(deg2rad(look_angle), stored_look_position.angle(), LOOK_SMOOTHNESS * smoothness_modifier)
	look_angle = rad2deg(look_angle_deg)
	if is_instance_valid(hitbox):
		hitbox.aim_direction = maths.angle_to_vector(look_angle_deg)

# Flip the whole pivot if the parent sprite is flipped
func _flip_direction() -> void:
	if not is_instance_valid(sprite):
		return
	
	if sprite.flip_h:
		scale.y = -1
	else:
		scale.y = 1
