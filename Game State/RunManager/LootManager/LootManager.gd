extends RNG

# Child Nodes
onready var preloaded_tables: Array = [$MeleeWeapons, $RangedWeapons, $Flasks, $Coins, $Gems, $Powerups, $PowerupUpgrades, "ThreeItemShop", "Random"]

# Stats
var property_objects: Array
var modifier_types: Array

# States
var previous_choice: int
var nextRooms_loot: Vector2 = Vector2(-1,-1) # Represents possible options for the next room's loot

# Return Variables
var optionsType_index: int = -1
var lootOptions_indexes: Array # Specifically for weapon upgrades, powerups and ThreeItemShop options, Keeps the indexs of the choices
var threeLootItems: Dictionary


## DECLARATION
func table_assignment() -> void:
	tables_to_populate = [0,1,2,3,4,5,6]
	tables = preloaded_tables

func custom_populate() -> void:
	# Queries all foreign tables first and stores the values in arrays in lootManager
	gameTablesDB.query("select PosIndex as i, Rarity as rare FROM Rarities;")
	for i in range(0, gameTablesDB.query_result.size()):
		var rarityName: String = gameTablesDB.query_result[i]["rare"]
		var rarityIndex: int = int(gameTablesDB.query_result[i]["i"])
		rarities[rarityName] = rarityIndex
	
	gameTablesDB.query("select PosIndex as i, Object as object FROM PropertyObjects;")
	for i in range(0, gameTablesDB.query_result.size()):
		var object: String = gameTablesDB.query_result[i]["object"]
		property_objects.append(object)
	
	gameTablesDB.query("select PosIndex as i, Type as type FROM ModifierTypes;")
	for i in range(0, gameTablesDB.query_result.size()):
		var type: String = gameTablesDB.query_result[i]["type"]
		modifier_types.append(type)
	modifier_types.pop_front()

func inject_table_populate(table: Object) -> void:
	table.rarities_ref = rarities


## LOOT TYPE
# Assigns new loot types for the next room, ensuring there are no duplicates
func determine_loot(roomSize: int) -> void:
	if not threeLootItems.empty():
		currentTable = 7
	rand_room_loot()
	if roomSize == 1:
		while currentTable == nextRooms_loot.x:
			rand_room_loot()
	else:
		while [currentTable, currentTable, nextRooms_loot.x] == [nextRooms_loot.x, nextRooms_loot.y, nextRooms_loot.y]:
			rand_room_loot()
	
	#nextRooms_loot.x = 1 # Debugging

# Randomly assign loot types to the next room's possible options
func rand_room_loot() -> void:
	nextRooms_loot.x = maths.rand_range_modulo(tables_indexCount)
	nextRooms_loot.y = maths.rand_range_modulo(tables_indexCount)

# Happens when a door is chosen
func switch_rooms(doorChosen: int) -> void:
	previous_choice = currentTable
	if doorChosen == 1:
		currentTable = nextRooms_loot.x
	else:
		currentTable = nextRooms_loot.y
	
	# If the currentLoot choice is "Random" in lootTables, randomly pick from lootTables excluding "Random"
	if currentTable == tables_indexCount: 
		randomise_currentTable([])
		while currentTable == previous_choice:
			randomise_currentTable([])


## GENERATE LOOT
# Decide on rarity, and determine which type of loot generation to use
func generate_loot(rarityChances: int, rarityGuarantee) -> void:
	threeLootItems.clear()
	# Determine rarity
	var rarity: int = maths.rarity_generator(rarityChances,rarityGuarantee)
	
	# If the current loot table has unique items, set loot_index for chosen option
	if currentTable < 5:
		_generate_uniqueItem(rarity)
	# If the table has a single item with many options, set lootOptions_indexes with 3 options
	elif currentTable > 4 and currentTable < 7: 
		_assignOptions(rarity)
	# If returning seperate items from seperate tables, generate three unique items
	else:
		_generate_threeItems(rarity)

# One loot item, with multiple options
func _assignOptions(rarity: int) -> void:
	optionsType_index = currentTable
	var itemRarities: Array = tables[optionsType_index].get_rarities()
	lootOptions_indexes.clear()
	_generate_uniqueItem(rarity)
	while lootOptions_indexes.size() < 3:
		if lootOptions_indexes.has(chosen_index):
			_generate_uniqueItem(rarity)
		else:
			lootOptions_indexes.append(chosen_index)

# Three unique loot items
func _generate_threeItems(rarity: int) -> void:
	var lootTypes: Array
	var chosenOptionsType: bool = false
	optionsType_index = -1
	for n in [0,1,2]:
		if n == 0:
			randomise_currentTable([7])
		else:
			while currentTable in lootTypes:
				randomise_currentTable([7])
		
		# Ensures that there can't be more than one options type lootTable
		var isOptionsType: bool = currentTable > 4 and currentTable < 7
		if isOptionsType and chosenOptionsType == false:
			chosenOptionsType = true
			optionsType_index = currentTable
			_assignOptions(rarity)
		elif chosenOptionsType and isOptionsType:
			var exclude_tables: Array = [7,6,5]
			randomise_currentTable(exclude_tables)
			while currentTable in lootTypes:
				randomise_currentTable(exclude_tables)
		 
		lootTypes.append(currentTable)
		_generate_uniqueItem(rarity)
		threeLootItems[lootTypes[n]] = chosen_index
	
	currentTable = 7
