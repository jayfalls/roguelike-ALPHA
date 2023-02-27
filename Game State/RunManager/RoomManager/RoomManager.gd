extends RNG

# Child Nodes
onready var preloaded_tables: Array = [$SmallRooms, $MediumRooms, $LargeRooms, $ThreeItemRooms, $SpecialRooms, $BossRooms]
onready var lootIndicator: PackedScene = preload("res://Game State/RunManager/RoomManager/RoomIcons/RoomIndicator.tscn")

# Outside Refs
var lootManager: Object
var dungeonYSort: Object setget start_room
var currentRoom: Object

# References
var spriteFolder_path: String = "res://Game State/RunManager/RoomManager/RoomIcons/"
var indicator_spritePaths: Array
var indicator_index: int
onready var starting_room: PackedScene = preload("res://World/Rooms/StartingRoom.tscn")

# Stats
var visited_rooms: Array = [-1,-1]
var beaten_bosses: Array = []

# States
var boss_room: bool = false
var lucky: bool = false
var game_beaten: bool = false


## DECLARATION
func table_assignment() -> void:
	tables_to_populate = [0,3,5]
	tables = preloaded_tables

func custom_populate() -> void:
	var name: String
	for table in lootManager.tables:
		if is_instance_valid(table):
			name = table.name.to_lower()
		else:
			name = table.to_lower()
		name += ".png"
		indicator_spritePaths.append(spriteFolder_path + name)
	indicator_spritePaths.append(spriteFolder_path + "bossroom.png")

# Spawns the starting room
func start_room(input) -> void:
	lootManager.currentTable = 0
	lootManager.generate_loot(0,0)
	dungeonYSort = input
	var startRoom = starting_room.instance()
	currentRoom = startRoom
	dungeonYSort.add_child(startRoom)
	startRoom.connect("looted", self, "prep_loot")
	startRoom.connect("exited", self, "new_room")


## STATE CHANGES
func determine_indicator() -> void:
	if boss_room:
		indicator_index = indicator_spritePaths.size() - 1
	else:
		indicator_index = lootManager.nextRooms_loot.x

# Spawn a new room
func new_room() -> void:
	if not game_beaten:
		lootManager.switch_rooms(1)
		determine_room()

# Prepares the loot for the next room
func prep_loot() -> void:
	if beaten_bosses.size() != tables[tables_indexCount].scenes.size():
		lootManager.determine_loot(currentRoom.EXITS)
		if currentRoom.EXITS == 1:
			determine_indicator()
			var indicator = lootIndicator.instance()
			currentRoom.add_child(indicator)
			indicator.global_position = currentRoom.exitDoor.marker.global_position
			indicator.sprite.texture = load(indicator_spritePaths[indicator_index])
		"""
		else:
			var lootIndicator1 = lootIndicators_table.lootItems[lootManager.nextRooms_loot.x].instance()
			var lootIndicator2 = lootIndicators_table.lootItems[lootManager.nextRooms_loot.y].instance()
		"""
	else:
		game_beaten = true


## NEW ROOM
# Assigns next room type
func determine_room() -> void:
	# Stores the names of the rooms loaded in tables
	var roomType_names: Array
	for type in tables:
		roomType_names.append(type.name)
	
	# Determines which room to go to next
	var chosenTable = lootManager.tables[lootManager.currentTable]
	if boss_room:
		currentTable = roomType_names.find("BossRooms")
	elif not is_instance_valid(chosenTable):
		if chosenTable == "ThreeItemShop":
			currentTable = roomType_names.find("ThreeItemRooms")
		elif lucky:
			currentTable = roomType_names.find("SpecialRooms")
	else:
		var excluded_rooms: Array = visited_rooms + [3, 4, 5]
		randomise_currentTable(excluded_rooms)
		visited_rooms.pop_front()
		visited_rooms.append(currentTable)
	
	#currentTable = 0 # Debugging
	
	if boss_room:
		while chosen_index in beaten_bosses:
			_generate_uniqueItem()
		beaten_bosses.append(chosen_index)
	else:
		if tables[currentTable].chosen_rooms.size() == tables[currentTable].scenes.size():
			tables[currentTable].chosen_rooms.clear()
		_generate_uniqueItem()
		while chosen_index in tables[currentTable].chosen_rooms:
			_generate_uniqueItem()
		tables[currentTable].chosen_rooms.append(chosen_index)
	
	finalise_new_room()

func finalise_new_room() -> void:
	currentRoom.queue_free()
	var new_room = itemScene.instance()
	dungeonYSort.add_child(new_room)
	currentRoom = new_room
	currentRoom.size = tables[currentTable].name.replace("Rooms", "")
	currentRoom.connect("looted", self, "prep_loot")
	currentRoom.connect("exited", self, "new_room")
