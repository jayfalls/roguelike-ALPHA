extends RNGTable
class_name EnemyTable

# 
var enemy_names: Array
var enemy_healths: Array 
var scenes: Array
var scenesFolder_path: String = "res://Characters/Enemies/Normal/"
var scene_name: String


## DECLARATION
func _init():
	_add_property("Health", "enemy_healths", "int")

func inject_logic(i: int) -> void: # The return value represents a custom pngname
	var enemy_name: String = DB.query_result[i]["name"]
	enemy_names.append(enemy_name)
	scene_name = enemy_name.to_lower() + ".tscn"
	object_to_modify.scenes.append(load(object_to_modify.scenesFolder_path + scene_name))


## GET INFO
func get_scene(chosen_index: int) -> PackedScene:
	return scenes[chosen_index]
