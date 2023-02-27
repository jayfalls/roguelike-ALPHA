extends Node
class_name RNG

signal tables_ready


var gameTablesDB setget db_assigned # Database object

# Loot Tables
var tables: Array
var tables_to_populate: Array = []
var tables_indexCount: int

# Return Variables
var currentTable: int = -1 # Represents the position in the lootTable array
var chosen_index: int
var itemScene: PackedScene

# Misc
export(bool) var RARITY_APPLIES: bool = false
var rarities: Dictionary


## DECLARATION
func _ready() -> void:
	yield(get_tree(), "idle_frame")
	table_assignment()
	tables_indexCount = tables.size() - 1
	if RARITY_APPLIES:
		rarity_applies()

func table_assignment() -> void:
	pass

func rarity_applies() -> void:
	# Makes a copy of tables and removes the "Random" string at the end on the copy
	var tables_copy: Array = tables.duplicate()
	tables_copy.pop_back()
	for table in tables_copy:
		if is_instance_valid(table):
			table.rarity_applies = RARITY_APPLIES


## DB LOADED
func db_assigned(input):
	gameTablesDB = input
	populate_arrays()

# Accesses the database's tables, assigning values to arrays
func populate_arrays() -> void:
	custom_populate()
	
	# Passes the reference of the database to all nodes referenced in tables up until tables_to_populate
	for i in tables_to_populate:
		var table: Object = tables[i]
		table.connect("populated_arrays", self, "tablesReady")
		table.DB_table = tables[i].name
		
		inject_table_populate(table)
		
		table.DB = gameTablesDB
		yield(table, "populated_arrays") # Waits for the query and loading of variables in the node to before passing the reference

func custom_populate() -> void:
	pass

func inject_table_populate(table: Object) -> void:
	pass

# Wait until all variables are assigned, and the close the database
var unloadDBs_counter: int = 0
func tablesReady() -> void:
	unloadDBs_counter += 1
	if unloadDBs_counter == tables_to_populate.size():
		emit_signal("tables_ready")


## TABLES
func randomise_currentTable(exclude_tables: Array) -> void:
	var tables_copy: Array
	
	# Creates a copy of tables, containing all the indexes
	var temp_index: int = 0
	for n in tables:
		tables_copy.append(temp_index)
		temp_index += 1
	tables_copy.pop_back()
	
	# Removes any indexes included in exclude_tables
	if not exclude_tables.empty():
		for n in exclude_tables:
			tables_copy.erase(n)
	
	# Randomises the copy of indexes and returns the first one
	tables_copy.shuffle()
	currentTable = int(tables_copy[0])

func _generate_uniqueItem(rarity: int = -1) -> void:
	var chosenItem_indexes: Array
	
	# Determines if rarity applies, and adds the relevant indexes to the choices
	var counter: int = 0
	if rarity != -1:
		var itemRarities: Array = tables[currentTable].get_rarities()
		for itemRarity in itemRarities:
			if itemRarity == rarity:
				chosenItem_indexes.append(counter)
			counter += 1
	else:
		for index in tables[currentTable].indexes:
			chosenItem_indexes.append(index)
	
	var random_choice: int = maths.rand_range_modulo(chosenItem_indexes.size() - 1)
	chosen_index = chosenItem_indexes[random_choice]
	#chosen_index = 1
	itemScene = tables[currentTable].get_scene(chosen_index)
