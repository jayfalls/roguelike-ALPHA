extends RoomTable

onready var specialRooms = get_parent().find_node("SpecialRooms")

func _init():
	use_custom_logic = true

func pre_query() -> void:
	DB_table = "SpecialRooms"

var originalDBQuery: String 
func custom_logic() -> void:
	originalDBQuery = DB_query.replace(";", " WHERE NOT Type = 'ThreeItemRoom';")
	DB_query = DB_query.replace(";", " WHERE Type = 'ThreeItemRoom';")
	
	object_to_modify = specialRooms
	object_to_modify.DB_table = DB_table
	
	base_logic()

func addon_logic() -> void:
	object_to_modify.scenesFolder_path += object_to_modify.DB_table + "/"

func custom_loaded() -> void:
	use_custom_logic = false
	object_to_modify = self
	DB_query = originalDBQuery
	DB_table = "ThreeItemRooms"
	base_logic()
