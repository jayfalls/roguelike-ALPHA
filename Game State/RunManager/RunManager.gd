extends Node

onready var SQLite = game_controller.SQLite
var gameTablesDBPath: String = "res://Game State/RunManager/GameTables.db" # Path to database
var gameTablesDB # Database object

onready var propertyManager = $PropertiesManager
onready var enemyManager = $EnemyManager
onready var lootManager = $LootManager
onready var roomManager = $RoomManager

var dungeonYSort: PackedScene = preload("res://World/DungeonYSort.tscn")
var dungeon: YSort
var player: Character


# INITIALISATION
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
	start_game()


# GAME CONTROL
func start_game()  -> void:
	dungeon = dungeonYSort.instance()
	add_child(dungeon)
	var game_HUD = UIManager.HUDScene.instance()
	UIManager.add_child(game_HUD)
	UIManager.HUD = game_HUD
	game_HUD.connect("restart", self, "restart_game")
	player = get_tree().get_nodes_in_group("Player").pop_front()
	player.connect("dead", game_HUD, "pause")
	yield(player, "assignment_ready")
	roomManager.dungeonYSort = dungeon
	propertyManager.lootManager = lootManager
	propertyManager.player = player

func restart_game() -> void:
	dungeon.queue_free()
	yield(get_tree(), "idle_frame")
	start_game()
