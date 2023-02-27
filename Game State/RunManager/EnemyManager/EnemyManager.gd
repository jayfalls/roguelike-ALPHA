extends RNG

# Child Nodes
onready var preloaded_tables: Array = [$SmallWaves, $MediumWaves, $LargeWaves, $Enemies]

# Stats
var room_sizes: Array

# States
var wave_rarity_modifier: int = 0

# Return Variables
var chosen_enemies: Array
var enemies_shielded: Array


## DECLARATION
func table_assignment() -> void:
	tables_to_populate = [0,1,2,3]
	tables = preloaded_tables

func custom_populate() -> void:
	gameTablesDB.query("select PosIndex as i, Size as size FROM RoomSizes;")
	for i in range(0, gameTablesDB.query_result.size()):
		var size: String = gameTablesDB.query_result[i]["size"]
		room_sizes.append(size)


## WAVES
func rand_wave(room_size: String) -> void:
	chosen_enemies.clear()
	enemies_shielded.clear()
	
	currentTable = room_sizes.find(room_size)
	var last_wave: int = tables[currentTable].last_wave_number
	var chosen_wave: int
	while chosen_wave == 0:
		chosen_wave = maths.rand_range_modulo(last_wave, 1)
	var wave_numbers: Array = tables[currentTable].wave_numbers
	var enemy_names: Array = tables[currentTable].enemies
	var shielded: Array = tables[currentTable].enemies_shielded
	
	for i in tables[currentTable].indexes:
		if wave_numbers[i] == chosen_wave:
			chosen_enemies.append(enemy_names[i])
			enemies_shielded.append(shielded[i])
