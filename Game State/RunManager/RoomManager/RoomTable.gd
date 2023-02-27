extends RNGTable
class_name RoomTable

var scenes: Array
var scenesFolder_path: String = "res://World/Rooms/"
var scene_name: String

var chosen_rooms: Array

func addon_logic() -> void:
	object_to_modify.scenesFolder_path += DB_table + "/"

func inject_logic(i: int) -> void: # The return value represents a custom pngname
	scene_name =  DB.query_result[i]["name"].to_lower() + ".tscn"
	object_to_modify.scenes.append(load(object_to_modify.scenesFolder_path + scene_name))

func get_scene(chosen_index: int) -> PackedScene:
	return scenes[chosen_index]
