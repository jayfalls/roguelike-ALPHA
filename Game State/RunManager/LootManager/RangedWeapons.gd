extends LootTable

var weapons_damage: Array
var weapons_speed: Array
var weapon_names: Array

func _init():
	_add_property("Damage", "weapons_damage", "int")
	_add_property("SpeedModifier", "weapons_speed", "float")

func inject_logic(i: int) -> void:
	pngname =  DB.query_result[i]["name"].to_lower() + ".png"
	object_to_modify.sprite_paths.append(object_to_modify.spriteFolder_path + pngname)
	weapon_names.append(DB.query_result[i]["name"])
