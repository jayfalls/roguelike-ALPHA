extends RNGTable

var wave_numbers: Array
var last_wave_number: int = 0
var enemies: Array
var enemies_shielded: Array

func _init():
	_add_property("WaveNumber", "wave_numbers", "int")
	_add_property("Enemy", "enemies")
	_add_property("Shielded", "enemies_shielded")

func inject_logic(i: int) -> void:
	var wavenumber: int = int(DB.query_result[i]["wavenumber"])
	if  wavenumber > last_wave_number:
		last_wave_number = wavenumber
