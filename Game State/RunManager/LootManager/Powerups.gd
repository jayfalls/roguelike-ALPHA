extends LootTable

onready var powerupUpgrades = get_parent().find_node("PowerupUpgrades")

var types: Array
var uniqueTypes: Array
var heading_names: Array
var descriptions: Array
var property_names: Array
var property_objects: Array
var property_types: Array
var values: Array
var value_types: Array
var modifier_types: Array
var ultimate_indexes: Array

func _init():
	use_custom_logic = true
	_add_property("Description", "descriptions")
	_add_property("Type", "types")
	_add_property("PropertyName", "property_names")
	_add_property("PropertyObject", "property_objects")
	_add_property("PropertyType", "property_types")
	_add_property("Value1", "values", "int")
	_add_property("ValueType", "value_types")
	_add_property("ModifierType", "modifier_types")
	_add_property("UltimateAttackIndex", "ultimate_indexes", "int")

var originalDBQuery: String 
var originalDB_table: String
func custom_logic() -> void:
	object_to_modify = powerupUpgrades
	
	DB.query("select PosIndex as i, Type as type FROM PowerupTypes;")
	for i in range(0, DB.query_result.size()):
		uniqueTypes.append(DB.query_result[i]["type"])
	
	originalDB_table = DB_table
	DB_table = "PowerupUpgrades"
	
	originalDBQuery = DB_query.replace(";", " WHERE NOT Type = 'stat';")
	DB_query = DB_query.replace(";", " WHERE Type = 'stat';")
	
	base_logic()

func custom_loaded() -> void:
	use_custom_logic = false
	object_to_modify = self
	DB_table = originalDB_table
	DB_query = originalDBQuery
	base_logic()

func inject_logic(i: int) -> void: # The return value represents a custom pngname
	object_to_modify.heading_names.append(DB.query_result[i]["name"])
	if use_custom_logic:
		pngname = "level_up.png"
	else:
		pngname = "powerup"
	object_to_modify.sprite_paths.append(object_to_modify.spriteFolder_path + pngname)

func _on_Powerups_populated_arrays():
	replace_sprites("powerup.png")
