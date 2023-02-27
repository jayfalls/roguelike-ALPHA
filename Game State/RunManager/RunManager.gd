extends Node

onready var SQLite = game_controller.SQLite
var gameTablesDBPath: String = "res://Game State/RunManager/GameTables.db" # Path to database
var gameTablesDB # Database object

onready var propertyManager = $PropertiesManager
onready var enemyManager = $EnemyManager
onready var lootManager = $LootManager
onready var roomManager = $RoomManager

var dungeonYSort = preload("res://World/DungeonYSort.tscn")
var player: Character

func _ready():
	yield(get_tree(), "idle_frame")
	gameTablesDB = SQLite.new()
	gameTablesDB.path = gameTablesDBPath
	gameTablesDB.open_db()
	
	# Sequentially loads the database into each of the managers so that its values can be stored and distributed
	lootManager.gameTablesDB = gameTablesDB
	yield(lootManager, "tables_ready")
	roomManager.lootManager = lootManager
	roomManager.gameTablesDB = gameTablesDB
	yield(roomManager, "tables_ready")
	enemyManager.gameTablesDB = gameTablesDB
	enemyManager.connect("tables_ready", self, "managers_ready")

func managers_ready():
	gameTablesDB.close_db()
	yield(get_tree(), "idle_frame")
	var DungeonYSort = dungeonYSort.instance()
	add_child(DungeonYSort)
	var HUD = UIManager.HUDScene.instance()
	UIManager.add_child(HUD)
	UIManager.HUD = HUD
	player = get_tree().get_nodes_in_group("Player").pop_front()
	yield(player, "assignment_ready")
	roomManager.dungeonYSort = DungeonYSort
	propertyManager.lootManager = lootManager
	propertyManager.player = player
