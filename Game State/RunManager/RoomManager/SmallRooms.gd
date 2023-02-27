extends RoomTable

onready var mediumRooms = get_parent().find_node("MediumRooms")
onready var largeRooms = get_parent().find_node("LargeRooms")
var roomTables: Array

var uniqueSizes: Array
var sizes: Array
var doors: Array

func _init():
	use_custom_logic = true
	_add_property("NumOfDoors", "doors", "int")
	_add_property("Size", "sizes")

func pre_query() -> void:
	DB_table = "RegularRooms"
	roomTables = [self, mediumRooms, largeRooms]

var DBQueries: Array 
var DBTables: Array
func custom_logic() -> void:
	DBTables = ["SmallRooms", "MediumRooms", "LargeRooms"]
	
	DB.query("select PosIndex as i, Size as size FROM RoomSizes;")
	for i in range(0, DB.query_result.size()):
		uniqueSizes.append(DB.query_result[i]["size"])
	for size in uniqueSizes:
		DBQueries.append(DB_query.replace(";", " WHERE Size = '" + size + "';"))
	
	var counter = 0
	for roomTable in roomTables:
		object_to_modify = roomTable
		object_to_modify.DB_table = DBTables[counter]
		DB_query = DBQueries[counter]
		counter += 1
		base_logic()

func addon_logic() -> void:
	object_to_modify.scenesFolder_path += object_to_modify.DB_table + "/"

var tables_loaded: int = 0
func custom_loaded() -> void:
	tables_loaded += 1
	if tables_loaded == roomTables.size():
		emit_signal("populated_arrays")
