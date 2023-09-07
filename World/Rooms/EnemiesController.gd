extends YSort

# Outside References
onready var lootManager: Object = RunManager.lootManager
onready var enemyManager: Object = RunManager.enemyManager
var room: YSort setget _room_generated
var traps_controller: Node2D
var spawn_tileset: Object setget spawn_loaded
var spawn_positions: Array

# Child Nodes
var enemies: Array

# Stats
var total_waves: int
var rarity_modifier: int = 0

# States
var chase: bool = false setget start_chase
var new_wave: bool = false
var current_wave: int = 1
var current_wave_size: int = 0


## DECLARATION
func _room_generated(input) -> void:
	room = input
	traps_controller = room.trapsController
	room.player.connect("dead", self, "enemies_idle")
	
	var previous_rarity: int  = enemyManager.wave_rarity_modifier
	if previous_rarity == 0:
		total_waves = maths.rarity_generator(0,1)
	else:
		total_waves = maths.rarity_generator(0,0)
	total_waves += 1

func spawn_loaded(input) -> void:
	spawn_tileset = input
	var positions = spawn_tileset.get_used_cells()
	for pos in positions:
		var spawn_position: Vector2 = spawn_tileset.map_to_world(pos) + Vector2(16, 16) / 2 # TileSize / 2
		spawn_positions.append(spawn_position)
	
	if spawn_positions.size() > 0 and room.ENEMY_ROOM:
		wave_start()

func wave_start() -> void:
	if lootManager.currentTable == 0:
		total_waves = maths.rarity_generator(0,0) + 1 # Need to add weapon rarity here
	rarity_modifier = total_waves - 2
	enemyManager.wave_rarity_modifier = rarity_modifier
	
	wave_spawn()


## STATE CHANGES
func start_chase(input) -> void:
	if not room.ENEMY_ROOM:
		return # Stop execution
	
	chase = input
	new_wave = true
	start_navigation()

func check_enemies() -> bool:
	enemies.clear()
	enemies = get_children()
	if enemies.size() == 0:
		return false
	else:
		return true

func start_navigation():
	if not new_wave:
		return # Stop execution
	
	traps_controller.arm()
	for enemy in enemies:
		enemy.room = room
		enemy.chasing = chase
		enemy.hurtbox.monitoring = true
		if enemy.is_connected("dead", self, "enemy_died"):
			pass
		else:
			enemy.connect("dead", self, "enemy_died")
	new_wave = false

func enemy_died() -> void:
	yield(get_tree().create_timer(0.2), "timeout")
	if not check_enemies():
		room.level_cleared()
		return # Stop execution
	
	if current_wave >= total_waves:
		return # Stop execution
	if enemies.size() < int(current_wave_size / 2) + 1:
		current_wave += 1
		new_wave = true
		wave_spawn()

func enemies_idle() -> void:
	for enemy in enemies:
		#enemy.reset()
		traps_controller.disarm()
		enemy.chasing = false
		enemy.player_dead = true


## WAVE MANAGEMENT
func wave_spawn() -> void:
	enemyManager.rand_wave(room.size)
	var enemyTable = enemyManager.tables.back()
	var enemy_names: Array = enemyManager.chosen_enemies
	var enemies_shielded: Array = enemyManager.enemies_shielded
	current_wave_size = enemy_names.size()
	
	var index: int = 0
	var chosen_positions: Array
	for enemy in enemy_names:
		var enemy_index: int = enemyTable.enemy_names.find(enemy)
		var enemy_object: Enemy =  enemyTable.get_scene(enemy_index).instance()
		if new_wave:
			enemy_object.dont_wander = true
		
		enemy_object.spawn_positions = spawn_positions
		var spawn_position: Vector2 = enemy_object.random_spawntile()
		while spawn_position in chosen_positions:
			spawn_position = enemy_object.random_spawntile()
		chosen_positions.append(spawn_position)
		
		if enemies_shielded[index] == "True":
			enemy_object.shielded = true
		add_child(enemy_object)
		enemy_object.stats.MAXHEALTH = enemyTable.enemy_healths[enemy_index]
		enemy_object.global_position = spawn_position
		enemy_object.original_position = spawn_position
		
		index += 1
	
	check_enemies()
	start_navigation()
