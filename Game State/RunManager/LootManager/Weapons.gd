extends LootTable

var weapons_damage: Array
var weapons_speed: Array
var weapons_size: Array
var weapons_staminaCost: Array
var weapons_collisionSize: Array
var weapon_names: Array

func _init():
	_add_property("Damage", "weapons_damage", "int")
	_add_property("Size", "weapons_size")
	_add_property("SpeedModifier", "weapons_speed", "float")
	_add_property("StaminaCost", "weapons_staminaCost", "float")
	_add_property("CollisionSize", "weapons_collisionSize")

func inject_logic(i: int) -> void:
	pngname =  DB.query_result[i]["name"].to_lower() + ".png"
	object_to_modify.sprite_paths.append(object_to_modify.spriteFolder_path + pngname)
	weapon_names.append(DB.query_result[i]["name"])
