extends Node
class_name RNGTable

signal populated_arrays


var use_custom_logic: bool = false # If enabled, allows you to use a seperate function to handle the database

var DB setget populate_arrays # Database object 
var DB_query: String = ""
var first_query_added: bool = false
var DB_table: String 
var properties: Dictionary # List of arrays in the RNGTable with the corresponding in the database
var properties_formats: Array # List of formats to use when loading the DB tables into the arrays
var object_to_modify: Object = self
var indexes: Array
var rarity_applies: bool = false
var rarities: Array
var rarities_ref: Dictionary


## DECLARATION
func _add_property(new_property: String, array: String, type: String = ".") -> void:
	if not first_query_added:
		first_query_added = true
		DB_query = ", "
	properties[array] = new_property.to_lower()
	properties_formats.append(type)
	DB_query += new_property + " as " + new_property.to_lower() + ", "


## DB LOADED
func populate_arrays(input) -> void:
	yield(get_tree().create_timer(0.01), "timeout")
	DB = input
	pre_query()
	prep_query()
	
	if use_custom_logic:
		custom_logic()
	else:
		base_logic()

# Prepare SQL query
func prep_query() -> void:
	var comma_pos: int = DB_query.find_last(",")
	DB_query.erase(comma_pos, 2)
	DB_query = "select PosIndex as i, Name as name" + DB_query
	if rarity_applies:
		DB_query += ", Rarity as rarity"
	DB_query += " FROM " + DB_table + ";"

# Custom logic for loading from the database
func custom_loaded() -> void:
	pass

# Regular logic for loading from the database
func base_logic() -> void:
	addon_logic()
	
	DB.query(DB_query)
	for i in range(0, DB.query_result.size()):
		inject_logic(i)
		
		object_to_modify.indexes.append(i)
		
		if rarity_applies:
			var rarityString: String = DB.query_result[i]["rarity"]
			var rarityIndex: int = rarities_ref[rarityString]
			object_to_modify.rarities.append(rarityIndex)
		
		auto_populate_arrays(i)
	
	if use_custom_logic:
		custom_loaded()
	else:
		variables_loaded()

# Uses the information specified using _add_property() to load the each specified table into each specified array
func auto_populate_arrays(i: int) -> void:
	var property_counter = 0
	var properties_arrays = properties.keys()
	object_to_modify.properties = properties
	for property in properties.values():
		var qry_rslt = DB.query_result[i][property]
		# Uses the optional type hint when using _add_property() during initialisation, to format the variable
		match properties_formats[property_counter]:
			"float":
				qry_rslt = float(qry_rslt)
			"int":
				qry_rslt = int(qry_rslt)
		object_to_modify[properties_arrays[property_counter]].append(qry_rslt)
		property_counter += 1

## ADDON LOGIC
# Used to manipulate the SQL query
func pre_query() -> void:
	pass

# Added logic at the beginning of base_logic()
func addon_logic() -> void:
	pass

# Added logic when cycling through the query results in base_logic()
func inject_logic(i: int) -> void:
	pass

# An alternative to base_logic(), for use if loading many objects from one DB Table
func custom_logic() -> void:
	pass


## DONE LOADING
func variables_loaded() -> void:
	emit_signal("populated_arrays")


## GET INFO
func get_scene(chosen_index: int) -> PackedScene:
	return PackedScene.new()

func get_rarities() -> Array:
	return rarities
