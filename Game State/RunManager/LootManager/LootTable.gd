extends RNGTable
class_name LootTable

var scene: PackedScene = preload("res://Game State/RunManager/LootManager/LootItems/LootItem.tscn")
var pngname: String
var spriteFolder_path: String = "res://Game State/RunManager/LootManager/LootItems/"
var sprite_paths: Array

## DB LOADED
func addon_logic() -> void:
	object_to_modify.spriteFolder_path += DB_table + "/"

func inject_logic(i: int) -> void: # The return value represents a custom pngname
	pngname =  DB.query_result[i]["name"].to_lower() + ".png"
	object_to_modify.sprite_paths.append(object_to_modify.spriteFolder_path + pngname)


## LOADING FINISHED
func replace_sprites(texture_name: String) -> void:
	for count in range(0, sprite_paths.size()):
		sprite_paths[count] = object_to_modify.spriteFolder_path + texture_name

## GET INFO
func get_scene(chosen_index: int) -> PackedScene:
	return scene
