extends YSort

signal looted
signal exited


# Outside References
var player: Character

# Child Nodes
onready var playerStart: Position2D = $RoomProperties/PlayerStart
onready var item_spawn: Position2D = $RoomProperties/ItemSpawn
onready var exitDoor = $NavigationController/Doors/DoorExit
onready var lootController = $NavigationController/Loot
onready var trapsController = $NavigationController/Traps
onready var spawn_tileset: TileMap = $NavigationController/SpawnLocations
onready var enemyController: YSort = $EnemyController
onready var musicPlayer: AnimationPlayer = $SFX/AnimationPlayer

# Stats
export(bool) var STARTING_ROOM = false
export(bool) var ITEM_SPAWN = false
export(bool) var ENEMY_ROOM = true
export(int) var EXITS = 1
var size: String


## DECLARATION
func _ready() -> void:
	yield(get_tree(), "idle_frame")
	lootController.enemyController = enemyController
	player = get_tree().get_nodes_in_group("Player").pop_front()
	player.new_room()
	player.global_position = playerStart.position
	enemyController.room = self
	enemyController.spawn_tileset = spawn_tileset
	if STARTING_ROOM:
		var loot = lootController.spawn_loot(item_spawn.global_position, 0)
		loot.new_item = false
		loot.connect("first_weapon", self, "open_door")
	elif ITEM_SPAWN:
		lootController.spawn_three_loot(item_spawn.global_position)
		yield(get_tree().create_timer(0.1), "timeout")
		open_door()
	else:
		enemyController.room = self
	player.can_move = true


## STATE CHANGES
func level_cleared() -> void:
	lootController.unlock()
	trapsController.disarm()
	musicPlayer.play("StopMusic")

func open_door() -> void:
	if STARTING_ROOM or ITEM_SPAWN:
		emit_signal("looted")
	exitDoor.open()

func _on_DoorEntrance_passed_through():
	enemyController.chase = true
	musicPlayer.play("StartMusic")

func _on_Chests_cleared():
	if not STARTING_ROOM:
		emit_signal("looted")
		open_door()

func _on_DoorExit_exited_room():
	UIManager.HUD.hide_HUD()
	emit_signal("exited")
