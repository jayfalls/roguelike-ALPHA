extends Node

onready var lootManager = RunManager.lootManager

var player: Character setget assign_nodes
var property_objects: Array
var property_object_names: Array
var modifier_types: Array

var table

var original_val: float
var new_val: float
var type: String

func assign_nodes(input) -> void:
	player = input
	property_objects = [player, player.stats, player.aim_pivot_melee.weapon, player.aim_pivot_ranged.weapon, player.aim_pivot_ranged.hitbox, player.hurtbox]
	property_object_names = lootManager.property_objects
	modifier_types = lootManager.modifier_types

func scan_tables(index: int, updating: bool = false) -> void:
	var lootType_index = lootManager.optionsType_index
	table = lootManager.tables[lootType_index]
	
	var modifier: int = table.values[index]
	
	var property_name = table.property_names[index]
	var property_object = table.property_objects[index]
	var valueType = table.value_types[index]
	
	var modifier_type: String = table.modifier_types[index]
	var ultimate_index: int = table.ultimate_indexes[index]
	
	var counter: int = 0
	for name in property_object_names:
		if name == property_object:
			var object = property_objects[counter]
			if valueType == "boolean":
				original_val = 0
				new_val = -1
			else:
				original_val = object.get(property_name)
				match valueType:
					"percentage": 
						new_val = original_val + original_val / 100 * modifier
						type = "%"
					"points":
						new_val = modifier
						type = " " + valueType
					"seconds":
						new_val = modifier
						type = " " + valueType
					"multiplier":
						new_val = original_val * modifier
						type = "X"
			if updating:
				if modifier_type in modifier_types:
					var hitbox = property_objects[property_object_names.find("hitbox")]
					var modifier_index: int = modifier_types.find(modifier_type)
					hitbox.modifier = modifier_index + 1
					hitbox.modifier_value = new_val
				elif ultimate_index >= 0:
					player.ultimate_attack_index = ultimate_index
					player.ultimate_value = new_val
				else:
					if valueType == "boolean":
						object.set_deferred(property_name, true)
					else:
						object.set_deferred(property_name, new_val)
		counter += 1

func get_values(index: int) -> Array:
	scan_tables(index)
	var val: Array = [original_val, new_val, type]
	return val

func update_property(index: int) -> void:
	scan_tables(index, true)
